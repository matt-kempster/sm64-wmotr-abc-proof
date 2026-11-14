"""Eight native shell controls at/inside the real X world floor boundary.

Initial airborne pose/shell and one following box XYZ cut are supplied.
No cache/action/position edits follow the air cut. Pending death is observed.
"""
import argparse,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,roots,pose,write,advance,NEUTRAL,rich_sample,frame_events,digest
def one(g,o,state,slot,r):
    g.load_state(state);g.mode='setup';edits=[];x,y=r['x'],r['y'];pose(g,[x,y,-939],edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    for a,v in zip('XYZ',[x,y-10,-939]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.mode='controls';initial=rich_sample(g,o);samples=[];events=[];controls=[];actorEdits=[]
    for i in range(4):
        if i==1:
            g.mode='actor'
            for a,v in zip('XYZ',[x+(95 if x>0 else -95),y,-939]):write(g,'gObjectPool[49].oPos'+a,v,actorEdits)
            g.mode='controls'
        pad=dict(buttons=0x2000,stick=[0,0]) if i==2 else NEUTRAL;advance(g,pad);samples.append(rich_sample(g,o));events.append(frame_events(g));controls.append(pad)
    return dict(recipe=r,edits=edits,initial=initial,actorEdits=actorEdits,controls=controls,samples=samples,events=events)
def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();g,o,ss,slot,prep=roots(a.capture,(129,));q,qo,qs,qslot,qprep=roots(a.capture,(129,));assert prep==qprep;trials=[]
    for x in [-8192,-8180,8180,8192]:
      for y in [25000,67277]:
        r=dict(x=x,y=y);t=one(g,o,ss[129],slot,r);assert t==one(q,qo,qs[129],qslot,r);trials.append(t);print(r,[(s['floor'],s['actionName'],s['movement'],s['warpOp'],s['countdown']) for s in t['samples']],flush=True)
    result=dict(schema=1,date='2026-11-14',scriptSha256=digest(__file__),helperSha256=digest(ROOT/'instrumentation/ink-high-delayed-shell/search.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),shellPreparation=prep,trials=trials,freshBoundaries=32)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
if __name__=='__main__':main()
