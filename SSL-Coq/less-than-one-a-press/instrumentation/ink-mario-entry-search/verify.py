"""Fresh-boot replay of retained upper-face/actor-push predecessor trials."""
import argparse,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,Guard,digest,run_trial
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance
from ink_crawl_predecessors import write
from ink_crawl_top_entry import top_snapshot

def root(capture,report):
    g,o=reach_after_pillars(capture);g=Guard(g)
    if report['mode']['shell']:
        while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==127):advance(g,NEUTRAL)
        ledger=[];write(g,'gObjectPool[32].oAction',4,ledger)
        assert ledger==report['shellPreparation']
        advance(g,NEUTRAL);advance(g,NEUTRAL)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
    assert top_snapshot(g)==report['oldMesh']
    return g,o,g.save_state()

def main(paths,out):
    capture=ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl'
    reports=[];checks=0;frames=0
    for path in paths:
        path=path.resolve()
        r=json.loads(path.read_text())
        assert r['scriptSha256']==digest(Path(__file__).with_name('search.py'))
        assert r['captureSha256']==digest(capture)
        g,o,base=root(capture,r)
        for t in r['trials']:
            actual=run_trial(g,o,base,t['recipe'],True)
            assert actual==t
            assert all(not c['buttons']&0x8000 for c in t['controls'])
            checks+=1;frames+=len(t['samples'])
        reports.append(dict(rawFile=str(path.relative_to(ROOT)),rawSha256=digest(path),mode=r['mode'],trialCount=r['trialCount'],immediateCaptureCount=r['selectedCount'],retained=r['trials'],oldMesh=r['oldMesh'],newMesh=r['newMesh'],nextMesh=r['nextMesh'],shellPreparation=r['shellPreparation']))
    receipt=dict(schema=1,date='2026-11-14',scope='Finite supplied upper-face action/pose/velocity and actor position cuts; not a complete controller route or an exhaustive exclusion',sourceRevision=r['sourceRevision'],runtimeSha256=r['runtimeSha256'],pythonVersion=r['pythonVersion'],captureSha256=digest(capture),searchScriptSha256=digest(Path(__file__).with_name('search.py')),verifierSha256=digest(__file__),sourceSha256=r['sourceSha256'],prefix=dict(inputs=2548,preEntryDebugLevelSelect=1,AOff=True),coverage=dict(trials=sum(x['trialCount'] for x in reports),candidateUpdates=3*sum(x['trialCount'] for x in reports),retainedFreshReplayHistories=checks,retainedFreshReplayUpdates=frames,immediateCaptureCount=sum(x['immediateCaptureCount'] for x in reports)),verification=dict(passed=True,comparison='Exact retained native-field and frame-event projection from newly replayed four-pillar roots; not whole-memory equivalence',afterCutWrites='Controller pads only, guarded',heldA=False,APressed=False),reports=reports)
    with out.open('x',encoding='utf-8') as f:json.dump(receipt,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(receipt['coverage'],indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('reports',nargs='+',type=Path);p.add_argument('--output',required=True,type=Path);a=p.parse_args();main(a.reports,a.output)
