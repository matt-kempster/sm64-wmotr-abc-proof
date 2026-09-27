"""Gate a requested update horizon on its real last-query prerequisite.

This is deliberately a coverage gate, not a timing curve for partial frames.
It expands the original final query instead of giving find_floor a free result.
An unsupported effect or undischarged runtime domain stops the calculation. The
requested longer horizons are not run by this prerequisite diagnostic; use
search_updates.py for actual horizon composition. Memory/layout interpretation is inherited from engine.py;
none of this is a formally verified CompCert interpreter.
"""
import argparse
import ctypes
from dataclasses import dataclass
import hashlib
import json
import os
from pathlib import Path
import platform
import subprocess
import sys
import time

from clight import ROOT, Term, outer_items, seq, walk, items
from engine import Engine, Scope, Path as Branch, Unsupported, MEM, OBJECT, TOP, word, read, z
from search import HEIGHT, bits


@dataclass
class CoverageBlock(Exception):
    detail: dict


def peak_working_set():
    """OS process high-water mark, including native Z3 allocations."""
    if os.name == 'nt':
        class Counters(ctypes.Structure):
            _fields_ = [('cb', ctypes.c_ulong), ('PageFaultCount', ctypes.c_ulong)] + [
                (name, ctypes.c_size_t) for name in ('PeakWorkingSetSize', 'WorkingSetSize',
                'QuotaPeakPagedPoolUsage', 'QuotaPagedPoolUsage', 'QuotaPeakNonPagedPoolUsage',
                'QuotaNonPagedPoolUsage', 'PagefileUsage', 'PeakPagefileUsage')]
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.GetCurrentProcess.restype = ctypes.c_void_p
        psapi = ctypes.WinDLL('psapi', use_last_error=True)
        psapi.GetProcessMemoryInfo.argtypes = [ctypes.c_void_p, ctypes.POINTER(Counters), ctypes.c_ulong]
        value = Counters(); value.cb = ctypes.sizeof(value)
        if not psapi.GetProcessMemoryInfo(kernel.GetCurrentProcess(), ctypes.byref(value), value.cb):
            raise ctypes.WinError(ctypes.get_last_error())
        return value.PeakWorkingSetSize
    import resource
    value = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
    return value if sys.platform == 'darwin' else value * 1024


class StrictEngine(Engine):
    # Explicit original-body links. No other callback receives an assumed frame.
    INLINE = dict(Engine.INLINE, update_mario_platform='platform_displacement',
                  find_floor='surface_collision', find_floor_from_list='surface_collision')

    def __init__(self, version, max_visits=10000, max_paths=4096):
        super().__init__(version)
        self.stack = []
        self.visits = 0
        self.max_visits, self.path_limit = max_visits, max_paths
        self.max_paths = 0
        self.expanded_calls = []
        self.finished_functions = []
        self.target_floor_call = True
        self.conversion_guards = []
        self.float_integer_conversions = 0

    def cast(self, value, source, target):
        if z.is_fp(value) and source.tag == 'tfloat' and target.tag in ('tint', 'tshort'):
            # CompCert Cop.sem_cast/cast_single_int: first truncate to signed
            # int32, rejecting an undefined conversion, then narrow to int16.
            # For binary32, adjacent values at these endpoints are integral.
            valid = z.And(z.Not(z.fpIsNaN(value)), z.Not(z.fpIsInf(value)),
                z.fpGEQ(value, z.FPVal(-2147483648, z.Float32())),
                z.fpLT(value, z.FPVal(2147483648, z.Float32())))
            if not self.conversion_guards:
                raise Unsupported('Float conversion outside a guarded statement')
            self.conversion_guards[-1].append(valid)
            self.float_integer_conversions += 1
            converted = z.fpToSBV(z.RTZ(), value, z.BitVecSort(32))
            return super().cast(converted, Term('tint'), target)
        return super().cast(value, source, target)

    def block(self, reason, scope, path, node, **extra):
        raise CoverageBlock(dict(reason=reason, function=scope.function.name,
            file=str(scope.function.unit.path.relative_to(ROOT)), definitionLine=scope.function.line,
            statementPath=path, constructor=node.tag,
            callStack=[s.function.name for s in self.stack], **extra))

    def close_scope(self, paths, child):
        return paths

    def wp(self, statement, normal, scope, returned=None, broken=None, path='body'):
        guards = []
        self.conversion_guards.append(guards)
        try:
            result = self.traverse(statement, normal, scope, returned, broken, path)
            return self.guard(result, z.And(*guards), 'defined-single-to-int-cast') if guards else result
        finally:
            self.conversion_guards.pop()

    def traverse(self, statement, normal, scope, returned=None, broken=None, path='body'):
        new_scope = not self.stack or self.stack[-1] is not scope
        if new_scope: self.stack.append(scope)
        try:
            self.visits += 1
            self.max_paths = max(self.max_paths, len(normal))
            if self.visits > self.max_visits:
                self.block('statement-budget', scope, path, statement, limit=self.max_visits)
            if len(normal) > self.path_limit:
                self.block('path-budget', scope, path, statement, limit=self.path_limit)
            if statement.tag in ('Sloop', 'Swhile', 'Sfor', 'Sdowhile'):
                self.block('unimplemented-live-loop', scope, path, statement,
                    explanation='The real loop has not been interpreted or given a checked complete summary. It is not replaced by zero iterations or a fixed arbitrary bound.')
            if statement.tag == 'Scall':
                dest, callee, actual = statement.args
                if callee.tag != 'Evar':
                    self.block('unresolved-indirect-call', scope, path, statement)
                name = callee.args[0].tag.removeprefix('_')
                if name not in self.INLINE:
                    self.block('unexpanded-call', scope, path, statement, callee=name)
                child = Scope(self, self.function(self.INLINE[name], name))
                self.expanded_calls.append(dict(caller=scope.function.name, callee=name, path=path))
                values = [self.eval(v, scope) for v in items(actual)]
                if len(values) != len(child.function.params):
                    self.block('argument-count', scope, path, statement, callee=name)
                tail = self.substitute(normal, (scope.temps[dest.args[0].tag], child.result)) if dest.tag == 'Some' else normal
                # This is an output TARGET at the actual final query, not a
                # granted floor result. It must be propagated through the body.
                target_query = self.target_floor_call and scope.function.name == 'update_mario_platform' and name == 'find_floor'
                if target_query:
                    tail = [Branch(z.And(p.condition, z.fpToIEEEBV(child.result) == word(HEIGHT)), p.decisions, p.calls) for p in tail]
                paths = self.wp(child.function.body, tail, child, tail, None, 'body')
                paths = self.close_scope(paths, child)
                paths = self.substitute(paths, *[(child.temps[p], value) for p, value in zip(child.function.params, values)])
                if target_query:
                    target = z.And(z.fpToIEEEBV(values[0]) == word(bits(-2200)), z.fpToIEEEBV(values[2]) == word(bits(-1024)))
                    paths = self.guard(paths, target, 'requested-final-query-XZ')
                self.finished_functions.append(name)
                return paths
            return super().wp(statement, normal, scope, returned, broken, path)
        except Unsupported as error:
            self.block('unsupported-semantics', scope, path, statement, explanation=str(error))
        finally:
            if new_scope: self.stack.pop()


def retention_prefix(function):
    """Original object-update statements through the original retention call."""
    parts = outer_items(function.body)
    locations = [i for i, statement in enumerate(parts)
                 if statement.tag == 'Scall' and statement.args[1].tag == 'Evar'
                 and statement.args[1].args[0].tag == '_update_mario_platform']
    if len(locations) != 1: raise ValueError('Expected one outer final platform call')
    stop = locations[0]
    return seq(parts[:stop+1]), dict(outerStatements=len(parts), included=stop+1,
        excludedAfterTarget=len(parts)-stop-1,
        meaning='Actual object-update prefix ending at top retention; a necessary portion of one full controller update, not the whole frame.')


def inventory(function, body):
    calls = []
    loops = 0
    for path, node in walk(body):
        if node.tag in ('Sloop','Swhile','Sfor','Sdowhile'): loops += 1
        if node.tag == 'Scall':
            callee = node.args[1]
            calls.append(dict(callee=callee.args[0].tag.removeprefix('_') if callee.tag == 'Evar' else '<indirect>', path=list(path)))
    return dict(function=function.name, file=str(function.unit.path.relative_to(ROOT)),
                definitionLine=function.line, sourceSHA256=function.digest, loops=loops, calls=calls)


def worker(version, output, *, program_dispatch=False, supplemental=None, live_dispatch=False):
    began = time.perf_counter()
    from relational_engine import RelationalEngine
    from benchmark_updates import CoverageBlock as EngineCoverageBlock
    e = RelationalEngine(version, runtime_audio=True, sqrtf_binding=True,
                         program_dispatch=program_dispatch,
                         live_dispatch=live_dispatch,
                         supplemental=supplemental, max_visits=200000)
    fn = e.function('object_list_processor', 'update_objects')
    body, cut = retention_prefix(fn)
    target = z.And(read(MEM, word(e.global_address('_gMarioPlatform'))) == word(TOP),
                   read(MEM, word(e.global_address('_gMarioObject'))) == word(OBJECT),
                   read(MEM, word(OBJECT + 532)) == word(TOP))
    prepared = time.perf_counter()
    result = dict(version=version, cut=cut, requestedUpdates=1, completeUpdates=0,
        survivingPossibilities=None, solverCheckPerformed=False, solver=z.get_version_string(),
        target='The ordinary Mario Object is present and both saved platform pointers name TOP, with the real final floor call returning the checked binary32 height at X=-2200,Z=-1024. No floor list or returned height is assumed.',
        model='Exploratory flat byte memory; actual generated bodies, explicit supplemental audio linkage, and domain-limited sqrtf binding. These additions do not refine the old Coq external oracle or prove runtime conditions.',
        dispatch='all compatible symbols in selected generated linkage' if program_dispatch else 'source command table with live-domain obligations',
        suppliedScene=False, suppliedGap=False,
        sourceUnits={})
    try:
        scope, paths = e.start(fn, target, body)
        if e.calls: raise AssertionError('Unexpanded call escaped strict gate')
        result.update(status='local-prerequisite-only', localPaths=len(paths),
            blocker=dict(reason='outer-frame-not-connected', explanation='Completing this prefix would still leave controller sampling, level scheduling and inter-update effects to connect.'))
    except (CoverageBlock, EngineCoverageBlock) as error:
        result.update(status='blocked-before-one-update', blocker=error.detail)
    finished = time.perf_counter()
    result.update(elapsedSeconds=finished-began, parseSetupSeconds=prepared-began,
        attemptedBackwardSeconds=finished-prepared, peakWorkingSetBytes=peak_working_set(),
        visitedStatements=e.visits, maxPartialPaths=e.max_paths,
        expandedCallSites=e.expanded_calls, finishedHelperTraversals=e.finished_functions,
        guardedFloatIntegerConversions=e.float_integer_conversions,
        loopRelations=e.loops, sharedFunctionRelations=e.relation_receipts,
        unresolvedIndirectDomains=e.indirect_domains, unresolvedLibraryDomains=e.library_domains,
        liveDispatch=e.dispatch_receipts,
        pendingFunctions=[r['function'].name for r in e.pending],
        generatedFunctions=e.functions,
        objectUpdateInventory=inventory(fn, body))
    # The following is a source inventory, not additional symbolic execution.
    result['floorQueryInventory'] = inventory(e.function('surface_collision','find_floor'), e.function('surface_collision','find_floor').body)
    result['floorListInventory'] = inventory(e.function('surface_collision','find_floor_from_list'), e.function('surface_collision','find_floor_from_list').body)
    result['sourceUnits'] = {str(unit.path.relative_to(ROOT)):unit.digest for unit in e.units.values()}
    if e.image is not None:
        result['linkedSymbols'] = dict(total=len(e.image.symbols),
            internal=sum(entry.internal for entry in e.image.symbols.values()),
            external=sum(not entry.internal for entry in e.image.symbols.values()))
        # Diagnose the excess type-compatible domain without narrowing it.
        # Source operands do not prove that every live script pointer belongs
        # to them; the search must still report its original coverage blocker.
        native_fn = e.function('behavior_script','bhv_cmd_call_native')
        native_call = next(node for _,node in walk(native_fn.body)
                           if node.tag == 'Scall' and node.args[1].tag == 'Etempvar')
        e.catalog_native = True
        source_names = e.source_table_targets(Scope(e,native_fn),native_call.args[1])
        missing_bodies = [name for name in source_names
                          if name not in e.image.symbols or not e.image.symbols[name].internal]
        result['nativeSourceCensus'] = dict(
            source=str(e.unit('behavior_data').path.relative_to(ROOT)),
            sourceSHA256=e.unit('behavior_data').digest,
            distinctInitializerOperands=len(source_names),
            names=source_names, missingInternalBodies=missing_bodies,
            blockerDeclarationsAlsoInCensus=sorted(set(result['blocker'].get('missing',[])) & set(source_names)),
            scope='Actual CALL_NATIVE initializer operands across the emitted behavior data. A source census, not a proof of live script/pointer reachability; no target is removed from the search.')
    output.write_text(json.dumps(result, indent=2)+'\n', encoding='utf-8')
    print(version+': '+result['status']+' at '+result['blocker']['reason'], flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, default=ROOT/'build/rank1-backward-search/update-benchmark')
    parser.add_argument('--worker', choices=('us','jp'))
    parser.add_argument('--worker-output', type=Path)
    parser.add_argument('--timeout', type=float, default=60)
    parser.add_argument('--updates', type=int, nargs='+', default=[1,2,4],
                        help='Requested horizons in nominal game updates; 30 is one second. No horizon is marked complete merely by selecting it.')
    parser.add_argument('--program-dispatch', action='store_true',
                        help='Use actual linked function signatures, retaining missing external alternatives as coverage errors.')
    parser.add_argument('--live-dispatch', action='store_true',
                        help='Resolve compatible targets using the actual pointer-load preimage; unresolved alternatives stay open.')
    parser.add_argument('--supplemental', type=Path,
                        help='Directory of additional pipeline-generated US/JP Clight units, never handwritten replacements.')
    args = parser.parse_args()
    if any(n < 1 for n in args.updates):
        parser.error('--updates must contain positive integers')
    if args.timeout <= 0:
        parser.error('--timeout must be positive')
    if args.live_dispatch and not args.program_dispatch:
        parser.error('--live-dispatch requires --program-dispatch')
    if args.worker:
        worker(args.worker, args.worker_output, program_dispatch=args.program_dispatch,
               supplemental=args.supplemental,live_dispatch=args.live_dispatch)
        return
    args.output.mkdir(parents=True, exist_ok=True)
    runs = {}
    for version in ('us','jp'):
        output = args.output/(version+'.json')
        command = [sys.executable, '-X', 'utf8', str(Path(__file__).resolve()), '--worker', version, '--worker-output', str(output.resolve())]
        if args.program_dispatch:
            command.append('--program-dispatch')
        if args.live_dispatch:
            command.append('--live-dispatch')
        if args.supplemental is not None:
            command.extend(['--supplemental',str(args.supplemental.resolve())])
        start = time.perf_counter()
        try:
            proc = subprocess.run(command, capture_output=True, text=True, timeout=args.timeout)
            if proc.returncode:
                raise RuntimeError(f'{version}: worker failed (not a coverage result): {proc.stderr}')
            runs[version] = json.loads(output.read_text(encoding='utf-8'))
            runs[version]['workerProcessSeconds'] = time.perf_counter()-start
            print(proc.stdout.strip(), flush=True)
        except subprocess.TimeoutExpired:
            runs[version] = dict(version=version, status='worker-timeout', completeUpdates=0,
                survivingPossibilities=None, elapsedSeconds=time.perf_counter()-start,
                blocker=dict(reason='worker-time-limit', seconds=args.timeout))
    report = dict(status='No complete one-update preimage; requested horizons were not reached.',
        method='Merged finite-execution loop preimages and shared actual-body call relations within the real object-update prefix. Unknown native receivers and undischarged runtime domains block completion; no arbitrary call gets an identity frame.',
        runtime=dict(python=platform.python_version(), system=platform.system()),
        requestedUpdates=args.updates, nominalUpdatesPerSecond=30,
        requestedGameSeconds=[n/30 for n in args.updates],
        completedUpdates=0, survivingPossibilities=None,
        priceEstimates={str(n):None for n in (90,150,300)},
        priceEstimateReason='No complete update or growth measurement. Do not extrapolate the failed prerequisite duration.',
        programDispatch=args.program_dispatch, liveDispatch=args.live_dispatch, oneUpdatePrerequisite=runs,
        laterUpdates=[dict(updates=n,status='not-run',reason='The one-update coverage gate did not complete.',survivingPossibilities=None) for n in args.updates if n != 1],
        interpretation='Reported time/memory measure the failed prerequisite attempt only. Partial path counts are syntax states, not surviving gameplay possibilities. This diagnoses missing execution coverage, not computational impossibility of gameplay or of a complete solver.',
        implementationHashes={name:hashlib.sha256(Path(__file__).with_name(name).read_text(encoding='utf-8').encode()).hexdigest()
            for name in ('clight.py','engine.py','search.py','benchmark_updates.py','loop_engine.py','relational_engine.py','program_image.py','live_dispatch.py','loop_probe.py','test_benchmark.py','test_loops.py','test_relational.py')})
    if any(run['completeUpdates'] != 0 for run in runs.values()):
        raise RuntimeError('Extend the real frame composition before reporting multi-update coverage')
    (args.output/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print('RECORDED: coverage blocker; complete-update timings and surviving counts remain unavailable.',flush=True)
    # A saved diagnostic is not a successful search. Supervising jobs must not
    # mistake a cleanly reported blocker for completion of the requested depth.
    raise SystemExit(2)


if __name__ == '__main__': main()
