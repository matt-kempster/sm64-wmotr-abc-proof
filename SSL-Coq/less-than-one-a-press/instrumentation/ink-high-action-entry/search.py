"""Native shell-mount/cancel entry at high raw Y; every setup grant is explicit.

No ground-action write is used. Initial FREEFALL and actor placement remain
supplied. An immediate capture is continued through Area2 before success.
"""
import argparse,json,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_slide_handoff import shell_root,advance,rich_sample
from ink_floorless_warp import NEUTRAL
from ink_crawl_predecessors import pose,write
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    def __init__(self,g):self.g=g;self.setup=False
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,path,value):
        if not self.setup:assert path in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},path
        self.g.write(path,value)

def sample(g,o):
    return dict(movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'),topPhase=g.read('gObjectPool[61].oTimer'))

def one(g,o,base,slot,r,full=False):
    g.load_state(base);g.setup=True;edits=[];x,y,z=r['pos'];pose(g,[x,y,z],edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',r.get('speed',20)),('vel',[r.get('speed',20),-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    for a,v in zip('XYZ',[x,y-10,z]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.setup=False;initial=rich_sample(g,o) if full else None;rows=[];events=[];pads=[]
    for i in range(34 if full else 2):
        pad=dict(buttons=0x2000,stick=[0,0]) if i==0 else NEUTRAL
        advance(g,pad);rows.append(rich_sample(g,o) if full else sample(g,o));pads.append(pad)
        if full:events.append(frame_events(g))
        if rows[-1]['area']!=1:break
    capture=any(s['floorOwner']==s['platform']==61 and s['used']==64 for s in rows)
    arrival=next((s for s in rows if s['area']==2),None)
    useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return dict(recipe=r,initial=initial,edits=edits if full else None,controls=pads,samples=rows,events=events,capture=capture,useful=useful)

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--fine',action='store_true');a=p.parse_args()
    g,o,base,prep=shell_root(a.capture);g=Guard(g);summaries=[];interesting=[];start=time.time()
    step=2 if a.fine else 4
    for y in [25000,67277]:
      for x in range(-2140,-1839,step):
       for z in range(-1170,-789,step):
        r=dict(name=f'shell-only-{x}-{y}-{z}',pos=[x,y,z]);t=one(g,o,base,prep['slot'],r);s0,s1=t['samples']
        if s0['floorY']==768 or t['capture']:summaries.append(dict(recipe=r,samples=t['samples'],capture=t['capture']))
        if t['capture']:
            detail=one(g,o,base,prep['slot'],r,True);interesting.append(detail);print('CAPTURE',r,'useful',detail['useful'],flush=True)
      print('HEIGHT',y,'elapsed',time.time()-start,'padCases',len(summaries),'captures',len(interesting),flush=True)
    controls=[dict(name='old-shell-control-'+str(y),pos=[-1950,y,-939]) for y in [1741,21777,21778,25000,32767,67277]]
    selected=interesting+[one(g,o,base,prep['slot'],r,True) for r in controls]
    q,qo,qbase,qprep=shell_root(a.capture);q=Guard(q);assert qprep==prep
    for t in selected:assert one(q,qo,qbase,qprep['slot'],t['recipe'],True)==t
    source=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofBase='651c180e594e45c6825f9c4800da11f4afef0773',sourceRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),prefixSha256=digest(a.capture),sourceHashes={k:digest(source/k) for k in ['src/game/mario.c','src/game/mario_step.c','src/game/mario_actions_moving.c','src/game/interaction.c']},shellPreparation=prep,menu=dict(x=[-2140,-1840,step],z=[-1170,-790,step],y=[25000,67277],allInputsAOff=True),candidateCount=2*len(range(-2140,-1839,step))*len(range(-1170,-789,step)),padScreens=summaries,trials=selected,verifiedFreshBoundaries=sum(len(t['samples']) for t in selected),captureCount=len(interesting),usefulCount=sum(t['useful'] for t in interesting),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps({k:result[k] for k in ['candidateCount','captureCount','usefulCount','verifiedFreshBoundaries','elapsed']},indent=2))

if __name__=='__main__':main()
