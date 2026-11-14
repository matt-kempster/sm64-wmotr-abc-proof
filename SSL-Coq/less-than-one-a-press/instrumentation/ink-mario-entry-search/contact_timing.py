"""Bounded vertical-separation/second-shove refinement; actor positions supplied."""
import argparse,copy,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,Guard,digest,run_trial,setup
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_timer130_crawl import frame_events

RECIPE=dict(target=[-1946,-970],push=106,angleIndex=48,pos=[-1840,1830.5751953125,-970],expectedFreshY=1857.76904296875,box=[-1839,1830.5751953125,-970],action='ACT_BUTT_SLIDE',yaw=49152,speed=20)

def root():
    g,o=reach_after_pillars(ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl');g=Guard(g)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):advance(g,NEUTRAL)
    return g,o,g.save_state()

def detail(g,o,base,recipe):
    g.load_state(base);g.setup=True;edits=setup(g,recipe);g.setup=False
    def sample():
        s=rich_sample(g,o)
        s['secondActorState']={f:g.read('gObjectPool[39].'+f) for f in ['oPosX','oPosY','oPosZ','oAction','oHeldState','oVelX','oVelY','oVelZ','oIntangibleTimer','activeFlags','hitboxRadius','hitboxHeight','hitboxDownOffset']}
        return s
    initial=sample();samples=[];events=[];controls=[]
    for _ in range(32):
        advance(g,NEUTRAL);controls.append(NEUTRAL);samples.append(sample());events.append(frame_events(g))
        if samples[-1]['area']!=1:break
    return dict(recipe=recipe,edits=edits,initial=initial,samples=samples,events=events,controls=controls)

def run(out):
    g,o,base=root();results=[];positives=[]
    for dy in [-124,-120,-115,-110,-105,-100,-80,0]:
      for sep in [1,10,39,60,68,70,71,71.5,90,92,94,95,96,96.5,97,98,100,104]:
       for dy2 in [-120,-100,0]:
        p=copy.deepcopy(RECIPE);p['box'][1]+=dy;p['secondActor']=[-1946-sep,p['expectedFreshY']+dy2,-970]
        t=run_trial(g,o,base,p)
        a,b,c=t['samples'];row=dict(dy=dy,secondSeparation=sep,secondDy=dy2,recipe=p,samples=t['samples']);results.append(row)
        if c['used']==64 and c['floorOwner']==c['platform']==61:
            positives.append(p);print('CAPTURE',json.dumps(p),flush=True)
    picked=positives or [t['recipe'] for t in sorted(results,key=lambda t:(t['samples'][1]['display'][1]-t['samples'][1]['movement'][1],t['samples'][1]['movement'][0]),reverse=True)[:4]]
    picked += [t['recipe'] for t in results if t['dy']==-110 and t['secondDy']==0 and t['secondSeparation']==70]
    full=[detail(g,o,base,p) for p in picked]
    fresh,fo,fb=root()
    for t in full:assert t==detail(fresh,fo,fb,t['recipe'])
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),helperSha256=digest(Path(__file__).with_name('search.py')),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl'),coverage=dict(trials=len(results),candidateUpdates=3*len(results),captures=len(positives),freshReplayedHistories=len(full),freshReplayedUpdates=sum(len(t['samples']) for t in full)),results=results,selected=full)
    with out.open('x',encoding='utf-8') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps(result['coverage'],indent=2))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('output',type=Path);a=p.parse_args();run(a.output)
