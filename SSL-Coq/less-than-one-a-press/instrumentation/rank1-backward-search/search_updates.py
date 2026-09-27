"""Attempt N actual object-update checkpoints through the real game-thread loop.

Unlike benchmark_updates.py's prerequisite gate, the requested depth is part of
the transition formula. Unknown calls and unproved library domains still stop
coverage. No fixture, known gap, floor list, action or script pointer is seeded.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time
from clight import ROOT, walk
from engine import MEM, OBJECT, TOP, Unsupported, read, word, z
from horizon_engine import HorizonEngine
from benchmark_updates import CoverageBlock, peak_working_set


def game_loop(e):
    fn = e.function('game_init','thread5_game_loop')
    loops = [node for _,node in walk(fn.body) if node.tag in ('Swhile','Sloop')]
    if len(loops) != 1:
        raise Unsupported('Expected one actual thread5 main loop')
    loop = loops[0]
    if loop.tag == 'Swhile' and str(loop.args[0]) != '(Econst_int (Int.repr 1) tint)':
        raise Unsupported('Unexpected main-loop guard: '+str(loop.args[0]))
    if loop.tag == 'Sloop' and loop.args[1].tag != 'Sskip':
        raise Unsupported('Unexpected main-loop increment')
    return fn,loop


def worker(version, updates, output, supplemental, solver_seconds, emulator_capture=None, lazy_calls=False):
    start = time.perf_counter()
    engine=HorizonEngine
    extra={}
    if emulator_capture is not None:
        from emulator_oracle import EmulatorOracle
        from hybrid_engine import HybridHorizonEngine
        engine=HybridHorizonEngine
        extra['oracle']=EmulatorOracle(emulator_capture)
        extra['lazy_calls']=lazy_calls
    e = engine(version,updates=updates,runtime_audio=True,sqrtf_binding=True,
               supplemental=supplemental,max_visits=250000,**extra)
    result = dict(version=version,requestedUpdates=updates,nominalGameSeconds=updates/30,
                  completedExhaustiveUpdates=0,solverCheckPerformed=False,
                  suppliedScene=False,suppliedGap=False,entryScriptPointerSupplied=False,
                  lazyCallAbstraction=lazy_calls)
    last_progress=[0.0]
    if emulator_capture is not None:
        def progress(name):
            now=time.perf_counter()
            if now-last_progress[0]<5:return
            last_progress[0]=now
            output.with_suffix('.progress.json').write_text(json.dumps(dict(
                status='constructing-hybrid-query',lastReferencedFunction=name,
                definedFunctions=len(e.relation_receipts),visitedStatements=e.visits,
                pendingFunctions=[r['function'].name for r in e.pending],
                deferredCalls=e.deferred,horizonCheckpoints=e.horizon_receipts,
                seconds=now-start),indent=2)+'\n',encoding='utf-8')
        e.progress_callback=progress
    try:
        fn,body = game_loop(e)
        target = z.And(read(MEM,word(e.global_address('_gMarioPlatform'))) == word(TOP),
                       read(MEM,word(e.global_address('_gMarioObject'))) == word(OBJECT),
                       read(MEM,word(OBJECT+532)) == word(TOP))
        # A bounded SSL-entry domain, with unknown positions, objects, script
        # pointers, floor lists and prior history. These two scalars alone do
        # not characterize reachable initialized gameplay.
        entry = z.And(read(MEM,word(e.global_address('_gCurrLevelNum')),2) == z.BitVecVal(8,16),
                      read(MEM,word(e.global_address('_gCurrAreaIndex')),2) == z.BitVecVal(1,16))
        result['root'] = dict(function=fn.name,source=fn.digest,
            cut='Actual main loop after startup. Stop after the Nth completed update_mario_platform call in update_objects.',
            priorIterations='Full caller returns, display/vsync, audio, controller read and level scheduling remain in the formula.',
            entry='Level SSL, Area 1; no live data/script invariant assumed.',
            target='Both remembered platform fields equal TOP after the final actual query at checked X/Z and height.',
            inputs='The real player-1 pressed-A edge is zero after every reached read_controller_inputs call. Already-held A is not silently excluded. Earlier no-A history and OS input semantics are not granted.')
        _,paths = e.start_horizon(fn,target,body,entry_condition=entry)
        result['formulaBuilt'] = True
        s = z.Solver()
        s.set(timeout=int(solver_seconds*1000))
        s.add(paths[0].condition)
        smt = s.to_smt2()
        output.with_suffix('.smt2').write_text(smt,encoding='utf-8')
        result['querySHA256'] = hashlib.sha256(smt.encode()).hexdigest()
        result['solverCheckPerformed'] = True
        status = s.check()
        result['solverResult'] = str(status)
        result['status'] = 'solver-'+str(status)
        if emulator_capture is not None and (e.deferred or e.library_domains):
            result['status']='unverified-proposal' if status==z.sat else 'unresolved-'+str(status)
            result['proposalWarning']='Pending call effects and checkpoint counts are unvalidated; this is not an executed 30-update trajectory.'
        if status==z.sat:
            model=s.model().sexpr()
            output.with_suffix('.model.smt2').write_text(model,encoding='utf-8')
            result['modelSHA256']=hashlib.sha256(model.encode()).hexdigest()
        if status == z.unknown:
            result['solverReason'] = s.reason_unknown()
        # SAT needs a validated execution; UNSAT needs the execution-model
        # connection. Neither is rounded into an allowed-gameplay theorem.
    except CoverageBlock as error:
        result.update(status='incomplete-coverage',blocker=error.detail)
    except Unsupported as error:
        result.update(status='incomplete-semantics',blocker=dict(reason=str(error)))
    if emulator_capture is not None:
        result.update(emulatorCaptureSHA256=e.oracle.digest,
            replayAnchorsSupplied=False,matchedEmulatorReplies=e.replies,
            deferredCalls=e.deferred,
            runtimeReason='The broad symbolic entry has no exact replay-event anchors. Observed cases cannot exclude its unmatched complement.')
    result.update(seconds=time.perf_counter()-start,peakWorkingSetBytes=peak_working_set(),
                  visitedStatements=e.visits,definedFunctions=len(e.relation_receipts),
                  pendingFunctions=[r['function'].name for r in e.pending],
                  liveDispatch=e.dispatch_receipts,horizonCheckpoints=e.horizon_receipts,
                  functions=e.functions,
                  sources={str(unit.path.relative_to(ROOT)):unit.digest for unit in e.units.values()})
    output.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    print(f"{version}: {result['status']}; {updates}-checkpoint request; complete coverage not claimed.",flush=True)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--updates',type=int,required=True)
    p.add_argument('--versions',nargs='+',choices=('us','jp'),default=['us','jp'])
    p.add_argument('--timeout',type=float,default=180)
    p.add_argument('--solver-seconds',type=float,default=30)
    p.add_argument('--supplemental',type=Path,default=ROOT/'build/rank1-backward-search/supplemental-generated')
    p.add_argument('--output',type=Path,required=True)
    p.add_argument('--worker',choices=('us','jp'))
    p.add_argument('--emulator-capture',type=Path,
                   help='Enable deferred calls and an exact-event emulator oracle; unanchored states stay unresolved.')
    p.add_argument('--lazy-calls',action='store_true',help='Build a source-spine proposal with named pending calls; never complete coverage.')
    a = p.parse_args()
    if a.updates < 1 or a.timeout <= 0 or a.solver_seconds <= 0:
        p.error('Depth and time limits must be positive')
    if a.lazy_calls and a.emulator_capture is None:p.error('--lazy-calls requires --emulator-capture')
    if a.worker:
        worker(a.worker,a.updates,a.output,a.supplemental,a.solver_seconds,a.emulator_capture,a.lazy_calls)
        return
    a.output.mkdir(parents=True,exist_ok=True)
    runs = {}
    for version in a.versions:
        output = a.output/(version+'.json')
        cmd = [sys.executable,'-X','utf8',str(Path(__file__).resolve()),'--worker',version,
               '--updates',str(a.updates),'--output',str(output.resolve()),
               '--supplemental',str(a.supplemental.resolve()),'--solver-seconds',str(a.solver_seconds)]
        if a.emulator_capture is not None:
            cmd += ['--emulator-capture',str(a.emulator_capture.resolve())]
        if a.lazy_calls:cmd+=['--lazy-calls']
        began = time.perf_counter()
        try:
            proc = subprocess.run(cmd,capture_output=True,text=True,timeout=a.timeout)
            if proc.returncode:
                runs[version] = dict(status='worker-error',requestedUpdates=a.updates,
                                     error=proc.stderr[-6000:],completedExhaustiveUpdates=0)
            else:
                runs[version] = json.loads(output.read_text(encoding='utf-8'))
                print(proc.stdout.strip(),flush=True)
        except subprocess.TimeoutExpired:
            partial=output.with_suffix('.progress.json')
            runs[version] = json.loads(partial.read_text()) if partial.exists() else {}
            runs[version].update(status='worker-timeout',requestedUpdates=a.updates,
                timeoutSeconds=a.timeout,completedExhaustiveUpdates=0,
                solverCheckPerformed=False,formulaBuilt=False)
        runs[version]['workerSeconds'] = time.perf_counter()-began
    report = dict(requestedUpdates=a.updates,nominalGameSeconds=a.updates/30,runs=runs,
        status='Exploratory horizon attempt; no completed exhaustive gameplay classification.',
        completedExhaustiveUpdates=0,
        largerHorizonCost=None,
        costReason='Incomplete coverage or solver classification gives no complete-update rate.',
        implementationHashes={name:hashlib.sha256(Path(__file__).with_name(name).read_bytes()).hexdigest()
                              for name in ('search_updates.py','horizon_engine.py','hybrid_engine.py','emulator_oracle.py','live_dispatch.py',
                                           'relational_engine.py','loop_engine.py','engine.py','clight.py')})
    (a.output/'report.json').write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    raise SystemExit(2)


if __name__ == '__main__':
    main()
