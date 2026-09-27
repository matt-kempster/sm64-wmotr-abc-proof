"""Diagnostic runs of the merged, finite-execution backward interpreter."""
import argparse
import faulthandler
import json
import time
from pathlib import Path

from clight import ROOT
from engine import MEM, word, read, OBJECT, TOP, z
from loop_engine import LoopEngine
from benchmark_updates import retention_prefix, CoverageBlock, peak_working_set


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--version', choices=('us','jp'), default='jp')
    ap.add_argument('--cut', choices=('floor','platform','objects'), default='objects')
    ap.add_argument('--output', type=Path)
    ap.add_argument('--solve', action='store_true')
    ap.add_argument('--runtime-audio', action='store_true')
    ap.add_argument('--shared-calls', action='store_true')
    ap.add_argument('--sqrtf-binding', action='store_true')
    ap.add_argument('--catalog-native', action='store_true',help='Diagnostic all-game callback catalog; not an SSL reachability claim')
    args = ap.parse_args()
    faulthandler.dump_traceback_later(50)
    start = time.perf_counter()
    if args.shared_calls:
        from relational_engine import RelationalEngine
        engine = RelationalEngine(args.version,runtime_audio=args.runtime_audio,sqrtf_binding=args.sqrtf_binding,catalog_native=args.catalog_native,max_visits=200000)
    else:
        engine = LoopEngine(args.version, auto_calls=True, runtime_audio=args.runtime_audio, max_visits=200000)
    module, name = dict(floor=('surface_collision','find_floor'),
                       platform=('platform_displacement','update_mario_platform'),
                       objects=('object_list_processor','update_objects'))[args.cut]
    fn = engine.function(module,name)
    body = retention_prefix(fn)[0] if args.cut == 'objects' else fn.body
    goal = z.And(read(MEM,word(engine.global_address('_gMarioPlatform'))) == word(TOP),
                 read(MEM,word(engine.global_address('_gMarioObject'))) == word(OBJECT),
                 read(MEM,word(OBJECT+532)) == word(TOP))
    if args.cut == 'floor':
        goal = z.BoolVal(True)
    report = dict(version=args.version, cut=args.cut, completeControllerUpdates=0)
    try:
        scope, paths = engine.start(fn,goal,body)
        report.update(status='cut-formula-built', paths=len(paths))
        if args.solve:
            answer, model, why = engine.solve(paths[0].condition)
            report.update(solverResult=answer, reasonUnknown=why)
    except CoverageBlock as error:
        report.update(status='coverage-blocked', blocker=error.detail)
    except Exception as error:
        import traceback
        traceback.print_exc(limit=6)
        report.update(status='implementation-error', exception=repr(error))
    report.update(seconds=time.perf_counter()-start, peakWorkingSetBytes=peak_working_set(),
                  visitedStatements=engine.visits, loops=engine.loops,
                  finishedHelpers=engine.finished_functions,
                  lastCalls=engine.expanded_calls[-20:], sources=engine.functions)
    if args.shared_calls:
        report.update(indirectDomains=engine.indirect_domains,libraryDomains=engine.library_domains,
                      pendingFunctions=[r['function'].name for r in engine.pending])
    faulthandler.cancel_dump_traceback_later()
    if args.output:
        args.output.parent.mkdir(parents=True,exist_ok=True)
        args.output.write_text(json.dumps(report,indent=2)+'\n',encoding='utf-8')
    print(json.dumps({k:v for k,v in report.items() if k not in ('sources','finishedHelpers','lastCalls','loops')},indent=2),flush=True)
    print('loops:',len(engine.loops),'helpers:',len(engine.finished_functions),flush=True)


if __name__ == '__main__':
    main()
