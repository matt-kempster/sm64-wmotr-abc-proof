"""Export native shell-created slide seeds before behavior129 for actor studies."""
import argparse,json,sys,math
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from prelude import ROOT,roots,advance,NEUTRAL,pose,write,f32,rich_sample,frame_events,digest

def make_seed(g,o,base,slot,r,full=False):
    g.load_state(base);g.mode='setup';edits=[];x,y,z=r['pos'];pose(g,[x,y,z],edits)
    yaw=r['yaw'];speed=r['speed'];a=yaw*math.tau/65536
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[f32(speed*math.sin(a)),-16,f32(speed*math.cos(a))]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0])]:write(g,'gMarioState.'+k,v,edits)
    for axis,v in zip('XYZ',[x,y-10,z]):write(g,f'gObjectPool[{slot}].oPos'+axis,v,edits)
    g.mode='controls';initial=rich_sample(g,o) if full else None;advance(g,dict(buttons=0x2000,stick=[0,0]))
    return dict(recipe=r,edits=edits if full else None,initial=initial,after=rich_sample(g,o) if full else dict(movement=g.read('gMarioState.pos'),action=g.read('gMarioState.action'),platform=o.slot(g.read('gMarioPlatform')),floorY=g.read('gMarioState.floorHeight')),events=frame_events(g) if full else None)

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    g,o,states,slot,prep=roots(a.capture);kept=[];tested=0
    for x in range(-2300,-1699,20):
      for z in range(-1350,-749,20):
       for yaw in [0,16384,32768,49152]:
        r=dict(phase=128,pos=[x,21700,z],yaw=yaw,speed=20);t=make_seed(g,o,states[128],slot,r);tested+=1;s=t['after']
        if s['action']==g.constant('ACT_BUTT_SLIDE') and s['platform']==61 and 1740<=s['movement'][1]<=1801:kept.append(dict(recipe=r,after=s))
    selected=[]
    if kept:
      # A small spread over starting coordinates and heights, not a claimed optimum.
      chosen=sorted(kept,key=lambda t:(abs(t['after']['movement'][0]+1950)+abs(t['after']['movement'][2]+939),t['recipe']['yaw']))[:12]
      q,qo,qs,qslot,qprep=roots(a.capture);assert qprep==prep
      for k in chosen:
        t=make_seed(g,o,states[128],slot,k['recipe'],True);assert t==make_seed(q,qo,qs[128],qslot,k['recipe'],True);selected.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),supportSha256=digest(ROOT/'instrumentation/ink-high-action-entry/prelude.py'),prefixSha256=digest(a.capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),shellPreparation=prep,menu=dict(phase=128,y=21700,x=[-2300,-1700,20],z=[-1350,-750,20],yaw=[0,16384,32768,49152],speed=20),candidateCount=tested,seedCount=len(kept),seeds=kept,trials=selected,verifiedFreshBoundaries=len(selected))
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('COUNTS',tested,len(kept),'fresh',len(selected));print(json.dumps(chosen if kept else [],indent=2))

if __name__=='__main__':main()
