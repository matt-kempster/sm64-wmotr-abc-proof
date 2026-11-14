"""Tiny actual-world-edge shell persistence and untouched death-queue test.

Two initial edge positions at raw Y25000. One positive-edge variant places
only the Crazy Box after the first update to try pushing Mario back inward.
No warp, cache, action, or Mario position writes follow the initial cut.
"""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_slide_handoff import shell_root,advance,rich_sample
from ink_floorless_warp import NEUTRAL
from ink_crawl_predecessors import pose,write
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    def __init__(self,g):self.g=g;self.mode='controls'
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        if self.mode=='box':assert p in {f'gObjectPool[49].oPos'+a for a in 'XYZ'},p
        if self.mode=='initial':assert p.startswith('gMarioState.') or p.startswith('gMarioObject.') or p in {f'gObjectPool[{self.slot}].oPos'+a for a in 'XYZ'},p
        self.g.write(p,v)

def roots(capture):
    g,o,base,prep=shell_root(capture);g=Guard(g);g.slot=prep['slot'];return g,o,base,prep

def sample(g,o):
    if g.read('gMarioObject').is_null():
        return dict(marioObjectCleared=True,level=g.read('gCurrLevelNum'),area=g.read('gCurrAreaIndex'),warpOp=g.read('sDelayedWarpOp'),countdown=g.read('sDelayedWarpTimer'),sourceNode=g.read('sSourceWarpNodeId'),playMode=g.read('sCurrPlayMode'),warpDestination=g.read('sWarpDest'))
    r=rich_sample(g,o);r['ridden']=o.slot(g.read('gMarioState.riddenObj'));r['shellSlot']=g.slot
    r['shell']={k:g.read(f'gObjectPool[{g.slot}].'+k) for k in ['oPosX','oPosY','oPosZ','oAction','oInteractStatus','activeFlags']}
    r['box']={k:g.read('gObjectPool[49].'+k) for k in ['oPosX','oPosY','oPosZ','oAction','oHeldState','activeFlags']}
    return r

def trial(g,o,base,r):
    g.load_state(base);g.mode='initial';edits=[];x=r['x'];pose(g,[x,25000,0],edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    for a,v in zip('XYZ',[x,24990,0]):write(g,f'gObjectPool[{g.slot}].oPos'+a,v,edits)
    g.mode='controls';initial=sample(g,o);rows=[];events=[];pads=[];actorEdits=[]
    for i in range(60):
        if i==1 and r['box']:
            g.mode='box'
            for a,v in zip('XYZ',[x+39,25000,0]):write(g,'gObjectPool[49].oPos'+a,v,actorEdits)
            g.mode='controls'
        pad=dict(buttons=0x2000,stick=[0,0]) if r['box'] and i==2 else NEUTRAL
        advance(g,pad);rows.append(sample(g,o));events.append(frame_events(g));pads.append(pad)
        if rows[-1].get('marioObjectCleared') or rows[-1]['level']!=initial['level']:break
    return dict(recipe=r,initialEdits=edits,actorEditsAfterFirstUpdate=actorEdits,initial=initial,controls=pads,samples=rows,events=events)

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,base,prep=roots(capture);q,qo,qbase,qprep=roots(capture);assert prep==qprep
    trials=[]
    for r in [dict(x=8192,box=False),dict(x=-8192,box=False),dict(x=8192,box=True)]:
        t=trial(g,o,base,r);assert t==trial(q,qo,qbase,r);trials.append(t)
        print(r,[(s['movement'],s['actionName'],s['floor'],s['warpOp'],s['countdown'],s['sourceNode']) for s in t['samples'][:4]],'last',(t['samples'][-1]['level'],t['samples'][-1]['area'],t['samples'][-1]['warpOp'],t['samples'][-1]['playMode']),flush=True)
    sources=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='77ed7515d9ddce96fe00a030a26aae8663b590b0',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),helperSha256=digest(ROOT/'instrumentation/wafel-jp-pilot/ink_slide_handoff.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(capture),sourceSha256={p:digest(sources/p) for p in ['src/game/mario.c','src/game/interaction.c','src/game/level_update.c','src/engine/surface_collision.c']},shellPreparation=prep,trials=trials,freshBoundaries=sum(len(t['samples']) for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
