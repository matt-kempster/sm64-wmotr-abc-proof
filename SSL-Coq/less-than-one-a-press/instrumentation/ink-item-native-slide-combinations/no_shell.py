"""Remove the initial shell relocation from the low-air positive.

The native shell still exists at its untouched remote position. The same
Mario AIR cut and later stock Buddy/box XYZ cuts are retained. Two nearby
input controls distinguish Z in air from Z after an ordinary landing.
"""
import sys,json,copy
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import *
from prelude import pose

def run(g,o,states,base,initial_buttons,later_buttons):
    r=copy.deepcopy(base);r['name']='no-initial-shell-relocation';r['initialButtons']=initial_buttons;r['phase129Buttons']=later_buttons
    g.load_state(states[128]);g.mode='setup';edits=[];pos=r['seed']['pos'];pose(g,pos,edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[0,-16,20]),('faceAngle',[0,0,0])]:write(g,'gMarioState.'+k,v,edits)
    g.mode='controls';initial=rich_sample(g,o);shell=actor_snapshot(g,g.slot)
    advance(g,dict(buttons=initial_buttons,stick=[0,0]));seed=dict(recipe=r['seed'],edits=edits,initial=initial,after=rich_sample(g,o),events=frame_events(g),shellWithoutRelocation=shell)
    cuts=[dict(phase=129,edits=cut(g,r))];rows=[];events=[];actors=[];controls=[]
    for i in range(35):
        if i==1:cuts.append(dict(phase=130,edits=cut(g,dict(box129=r['box130']))))
        control=dict(buttons=later_buttons if i==0 else 0,stick=[0,0]);controls.append(control);advance(g,control)
        rows.append(rich_sample(g,o));events.append(frame_events(g));actors.append({str(s):actor_snapshot(g,s) for s in [49,15,g.slot]})
        if rows[-1]['area']!=1:break
    arrival=next((s for s in rows if s['area']==2),None)
    return dict(recipe=r,seed=seed,actorCuts=cuts,samples=rows,events=events,actors=actors,controls=controls,capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))

def main():
    capture,low,out=map(Path,sys.argv[1:4]);base=json.loads(low.read_text())['selected'];g,o,s,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep;trials=[]
    for initial,later in [(0x2000,0),(0,0),(0,0x2000)]:
        t=run(g,o,s,base,initial,later);assert t==run(q,qo,qs,base,initial,later);trials.append(t)
        print(initial,later,'native128',t['seed']['after']['actionName'],t['seed']['after']['movement'],'129',t['samples'][0]['actionName'],t['samples'][0]['movement'],'capture',t['capture'],'useful',t['useful'],flush=True)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchSha256=digest(Path(__file__).with_name('search.py')),lowEntrySha256=digest(low),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',len(trials),'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
