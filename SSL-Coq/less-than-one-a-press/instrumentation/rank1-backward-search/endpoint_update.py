"""One original game-loop iteration, backward from the retention checkpoint.

No recorded prefix, fixture, controller sampling or emulator result is used.
The program counter is the start of thread5's original loop iteration. Paths
that continue/finish the iteration without the target are not predecessors.
Unimplemented memory effects and state validity are conditions for candidate
generation, never successful coverage. Any proposal still needs validation.
"""
import argparse
import faulthandler
import hashlib
import json
from pathlib import Path as FilePath
import subprocess
import sys
import threading
import time
from clight import ROOT, Term, is_variadic
from engine import MEM, Path, Scope, Unsupported, read, word, z
from benchmark_updates import CoverageBlock, peak_working_set
from checkpoint_graph import CheckpointGraph
from hybrid_engine import HybridHorizonEngine
from search_updates import game_loop
from loop_engine import get_vars
from global_storage import GlobalStorage
from candidate_policy import SEARCH_POLICY, interpret_solver_result, conditional_exit_code


class EndpointEngine(HybridHorizonEngine):
    RUNTIME_BOUNDARIES = set()

    def __init__(self, version, **kwargs):
        self.target_mario=z.BitVec(version+'.endpoint.mario_identity',32)
        self.target_top=z.BitVec(version+'.endpoint.top_identity',32)
        super().__init__(version, updates=1, lazy_calls=False,
                         sqrtf_binding=False, fresh_call_frames=True, target_specific_query=True,
                         context_parameters=[self.target_mario,self.target_top], **kwargs)
        self.dead_calls = []
        self.shared_continuations = []
        self.share_counts = {}
        self.checkpoint_graph = CheckpointGraph(self, self.checkpoint)
        self.global_storage=GlobalStorage(self.units.values())

    def global_address(self,name):
        return self.global_storage.address(name)

    def retention_target(self):
        fields=self.unit('platform_displacement').layout('_Object')[2]
        return z.And(read(MEM,word(self.global_address('_gMarioPlatform')))==self.target_top,
            read(MEM,word(self.global_address('_gMarioObject')))==self.target_mario,
            read(MEM,self.target_mario+word(fields['_platform']))==self.target_top,
            read(MEM,self.target_top+word(fields['_behavior']))==word(self.global_address('_bhvPyramidTop')),
            self.target_top!=word(0),self.target_mario!=word(0),self.target_top!=self.target_mario,
            read(MEM,word(self.global_address('_gCurrAreaIndex')),2)==z.BitVecVal(1,16))

    def wp(self, st, normal, scope, returned=None, broken=None, path='body'):
        result = super().wp(st, normal, scope, returned, broken, path)
        self.share_counts[scope.name] = self.share_counts.get(scope.name,0)+1
        # Every memory write gets an exact name: repeated writes through a
        # memory-loaded pointer otherwise expand each earlier Store into all
        # later addresses (especially generated display-list macros).
        if st.tag=='Sassign' or (self.share_counts[scope.name] >= 32 and st.tag in ('Ssequence', 'Scall', 'Sswitch', 'Sloop', 'Swhile', 'Sfor', 'Sdowhile')):
            self.share_counts[scope.name] = 0
            return self.share_continuation(result, scope, path)
        return result

    def share_continuation(self, paths, scope, path):
        """Name an exact predicate, without changing it or adding an axiom.

        Repeated substitutions otherwise copy a large caller continuation
        into every call and switch arm. Each fresh definition captures ALL
        free constants, including memory and the checkpoint observer.
        """
        expression = paths[0].condition
        if syntactically_false(expression) or z.is_true(expression):
            return paths
        variables = get_vars(expression)
        name = scope.name+'.continuation.'+str(len(self.shared_continuations))
        relation = z.RecFunction(name, *[v.sort() for v in variables], z.BoolSort())
        z.RecAddDefinition(relation, variables, expression)
        self.definitions.append((relation, variables, expression))
        self.shared_continuations.append(dict(function=scope.function.name, path=path,
                                              parameters=len(variables)))
        return [Path(relation(*variables), calls=paths[0].calls)]

    def traverse(self, st, normal, scope, returned=None, broken=None, path='body'):
        if st.tag == 'Scall':
            # A false continuation and no checkpoint inside this call means
            # no successful prefix can use it. No memory-frame claim is made.
            # Do not call the general SMT simplifier here: it may unfold
            # recursive function/loop definitions just to test dead code.
            if all(syntactically_false(p.condition) for p in normal) and not self.checkpoint_graph.may_cross(st, scope):
                self.dead_calls.append(dict(caller=scope.function.name, path=path,
                    targets=list(self.checkpoint_graph.targets(st,scope.function.unit))))
                return [Path(z.BoolVal(False))]
            dest, callee, args = st.args
            if callee.tag=='Evar':
                signature=callee.args[-1]
                if is_variadic(signature):
                    result=self.external_call(st,normal,scope,path)
                    self.deferred[-1]['reason']='Variadic argument/va_list runtime binding remains unimplemented; all actual arguments retained.'
                    return result
            if callee.tag != 'Evar':
                # Enumerate the WHOLE compatible linkage, not stock-table
                # initializers or three favored native callbacks.
                pointer = self.eval(callee, scope)
                cases = []
                targets = self.image.compatible(self.typeof(callee),scope.function.unit)
                for symbol in targets:
                    call = Term('Scall',(dest,Term('Evar',(Term('_'+symbol.name),symbol.signature)),args))
                    pre = self.wp(call, normal, scope, returned, broken, path+'.target.'+symbol.name)
                    cases.append(z.And(pointer==word(self.function_address(symbol.name)),pre[0].condition))
                self.dispatch_receipts.append(dict(caller=scope.function.name,path=path,
                    selected=[s.name for s in targets], initializersAssumed=False,
                    method='all type-compatible linked symbols, each guarded by the actual live pointer'))
                return [Path(z.Or(*cases))]
        return super().traverse(st, normal, scope, returned, broken, path)

    def start_iteration(self, fn, loop, target, entry):
        self.target, self.stop_post = target, z.BoolVal(True)
        body = loop.args[1] if loop.tag == 'Swhile' else loop.args[0]
        scope = Scope(self, fn)
        self.prepare_frame(scope)
        self.dispatch_entry = (scope,entry,body)
        self.continues.append((scope,[Path(z.BoolVal(False))]))
        try:
            paths = self.wp(body,[Path(z.BoolVal(False))],scope,[Path(z.BoolVal(False))],
                            [Path(z.BoolVal(False))],path='original-iteration')
        finally:
            self.continues.pop()
            self.dispatch_entry = None
        self.compile_pending()
        return scope, self.guard(self.substitute(paths,(self.remaining,z.IntVal(1)),
                                                (scope.frame_base,word(0x80000000))),
                                 entry,'SSL-Area-1-entry-domain')


def syntactically_false(expression):
    if z.is_false(expression):return True
    if z.is_and(expression):return any(syntactically_false(c) for c in expression.children())
    if z.is_or(expression):return all(syntactically_false(c) for c in expression.children())
    return False


def archive_definitions(engine, output, goal):
    """Stream exact, named AST definitions without expanding the whole SCC.

    This is an inspection/reproduction archive, not a standalone SMT-LIB
    script. The actual solver receives the original in-memory formula.
    """
    digest=hashlib.sha256()
    with output.open('wb') as stream:
        def emit(record):
            encoded=(json.dumps(record,separators=(',',':'))+'\n').encode('utf-8')
            stream.write(encoded);digest.update(encoded)
        emit(dict(kind='format',format='rank1-source-preimage-definitions-v1',
                  meaning='Exact AST definitions; pending relations are not discharged.'))
        for relation,parameters,body in engine.definitions:
            emit(dict(kind='definition',name=str(relation.name()),
                parameters=[[str(p.decl().name()),p.sort().sexpr()] for p in parameters],
                body=body.sexpr()))
        emit(dict(kind='goal',variables=[[str(v.decl().name()),v.sort().sexpr()] for v in get_vars(goal)],
                  body=goal.sexpr()))
    return digest.hexdigest()


def worker(version, output, solver_seconds, archive=False):
    began=time.perf_counter()
    stack_log=output.with_suffix('.stack.log').open('w')
    faulthandler.enable(file=stack_log)
    z.set_param('memory_max_size', 6144)
    e=EndpointEngine(version,runtime_audio=True,program_dispatch=True,live_dispatch=True,
        supplemental=ROOT/'build/rank1-backward-search/supplemental-generated',max_visits=250000)
    report=dict(version=version,requestedUpdates=1,completedExhaustiveUpdates=0,
        searchPolicy=SEARCH_POLICY,conditionalQueryCompleted=False,
        controllerTrials=0,suppliedGap=False,suppliedScene=False,recordedPrefix=False,
        start='Beginning of one original thread5_game_loop iteration; SSL Area 1, otherwise symbolic memory and retained thread locals.',
        stop='After the original update_objects -> update_mario_platform call at checked X/Z and height; both platform pointers name the designated pyramid-top Object.',
        domain='Exploratory flat-memory source model. No initialized-script or live-list invariant supplied; defined storage/provenance and runtime correspondence remain outside this interpreter.',
        semantics='Continue/end without this checkpoint is failure for this iteration. No next iteration or later checkpoint is substituted.')
    report.update(checkpointGraph=e.checkpoint_graph.receipt(),
        sourceUnits={str(u.path.relative_to(ROOT)):u.digest for u in e.units.values()},
        implementationHashes={n:hashlib.sha256(FilePath(__file__).with_name(n).read_bytes()).hexdigest()
                              for n in ('endpoint_update.py','checkpoint_graph.py','hybrid_engine.py','horizon_engine.py',
                                        'relational_engine.py','loop_engine.py','engine.py','clight.py','program_image.py','global_storage.py',
                                        'candidate_policy.py')})
    output.with_suffix('.context.json').write_text(json.dumps(report,indent=2)+'\n')
    last=[0.0]
    def progress(name):
        now=time.perf_counter()
        if now-last[0]<3:return
        last[0]=now
        output.with_suffix('.progress.json').write_text(json.dumps(dict(
            status='constructing-one-iteration-predecessor',seconds=now-began,
            lastFunction=name,currentFunction=getattr(e,'compiling_function',None),
            definedFunctions=len(e.relation_receipts),pendingFunctions=len(e.pending),
            deferredCalls=e.deferred,deadCalls=e.dead_calls,
            visitedStatements=e.visits,sharedContinuations=len(e.shared_continuations),
            peakWorkingSetBytes=peak_working_set()),indent=2)+'\n')
    e.progress_callback=progress
    def capture():
        report.update(sourceBodiesCompleted=e.relation_receipts,
            pendingFunctions=[r['function'].name for r in e.pending],deferredCalls=e.deferred,
            deadCalls=e.dead_calls,dispatch=e.dispatch_receipts,visitedStatements=e.visits,
            sharedContinuations=e.shared_continuations,globalStorage=e.global_storage.receipt(),
            peakWorkingSetBytes=peak_working_set())
    try:
        fn,loop=game_loop(e)
        report['rootSource']=fn.digest
        target=e.retention_target()
        entry=z.And(read(MEM,word(e.global_address('_gCurrLevelNum')),2)==z.BitVecVal(8,16),
                    read(MEM,word(e.global_address('_gCurrAreaIndex')),2)==z.BitVecVal(1,16))
        _,paths=e.start_iteration(fn,loop,target,entry)
        report['formulaBuilt']=True
        capture()
        report.update(status='formula-built-awaiting-solver',seconds=time.perf_counter()-began)
        output.write_text(json.dumps(report,indent=2)+'\n')
        s=z.Solver();s.set(timeout=int(solver_seconds*1000));s.add(paths[0].condition)
        output.with_suffix('.stage.json').write_text(json.dumps(dict(stage='solving-formula',
            seconds=time.perf_counter()-began))+'\n')
        result=s.check();report.update(interpret_solver_result(result))
        if result==z.unknown:report['solverReason']=s.reason_unknown()
        # Never let optional diagnostic printing prevent the solver result.
        report['seconds']=time.perf_counter()-began
        output.write_text(json.dumps(report,indent=2)+'\n')
        if archive:
            output.with_suffix('.stage.json').write_text(json.dumps(dict(stage='archiving-definitions',
                seconds=time.perf_counter()-began))+'\n')
            report['definitionArchiveSHA256']=archive_definitions(e,output.with_suffix('.definitions.jsonl'),paths[0].condition)
    except CoverageBlock as exc:
        report.update(status='incomplete-coverage',blocker=exc.detail)
    except (Unsupported, ValueError, RuntimeError, z.Z3Exception) as exc:
        report.update(status='incomplete-semantics',blocker=dict(reason=str(exc),
            function=getattr(e,'compiling_function',None)))
    capture()
    report['seconds']=time.perf_counter()-began
    output.write_text(json.dumps(report,indent=2)+'\n')
    print(version+': '+report['status']+'; conditional search, gameplay unvalidated.',flush=True)
    faulthandler.disable()
    stack_log.close()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--output',type=FilePath,required=True)
    p.add_argument('--versions',nargs='+',choices=('us','jp'),default=['us','jp'])
    p.add_argument('--worker',choices=('us','jp'))
    p.add_argument('--timeout',type=float,default=180)
    p.add_argument('--solver-seconds',type=float,default=30)
    p.add_argument('--archive-definitions',action='store_true',
                   help='After solving, also export exact AST text; may be very large/slow.')
    a=p.parse_args()
    if a.worker:
        # Formula traversal in native Z3 also uses this stack. Use a bounded
        # explicit stack instead of Windows' small default main-thread stack.
        threading.stack_size(64*1024*1024)
        errors=[]
        def run_worker():
            try:worker(a.worker,a.output,a.solver_seconds,a.archive_definitions)
            except BaseException as exc:errors.append(exc)
        thread=threading.Thread(target=run_worker)
        thread.start();thread.join()
        if errors:raise errors[0]
        return
    a.output.mkdir(parents=True,exist_ok=False)
    report=dict(requestedUpdates=1,completedExhaustiveUpdates=0,controllerTrials=0,
                searchPolicy=SEARCH_POLICY,runs={})
    for version in a.versions:
        output=a.output/(version+'.json')
        cmd=[sys.executable,'-X','utf8',__file__,'--worker',version,'--output',str(output),
             '--solver-seconds',str(a.solver_seconds)]
        if a.archive_definitions:cmd.append('--archive-definitions')
        try:
            run=subprocess.run(cmd,capture_output=True,text=True,encoding='utf-8',timeout=a.timeout)
            if run.returncode:result=dict(status='worker-error',returnCode=run.returncode,error=run.stderr[-5000:])
            else:result=json.loads(output.read_text());print(run.stdout.strip(),flush=True)
        except subprocess.TimeoutExpired:
            progress=output.with_suffix('.progress.json')
            result=(json.loads(output.read_text()) if output.exists() else
                    json.loads(progress.read_text()) if progress.exists() else {})
            result.update(status='worker-timeout',timeoutSeconds=a.timeout)
        context=output.with_suffix('.context.json')
        if context.exists():
            result={**json.loads(context.read_text()),**result}
        stage=output.with_suffix('.stage.json')
        if stage.exists():result['lastStage']=json.loads(stage.read_text())
        report['runs'][version]=result
    report['conditionalQueriesCompleted']=sum(
        r.get('conditionalQueryCompleted') is True for r in report['runs'].values())
    (a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n')
    raise SystemExit(conditional_exit_code(report['runs']))


if __name__=='__main__':main()
