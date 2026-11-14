"""Eight high-air enemy-damage comparisons; no ground action is supplied.

Mario FREEFALL pose/velocity and optionally one existing stock Goomba's XYZ
are supplied once before top130. All subsequent writes are A-off controls.
"""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

class Guard:
    def __init__(self,g):self.g=g;self.setup=False
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        assert self.setup or p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        self.g.write(p,v)

def root(capture):
    g,o=reach_after_pillars(capture);g=Guard(g)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==130):advance(g,NEUTRAL)
    slots=[i for i in range(240) if g.read(f'gObjectPool[{i}].activeFlags') and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvGoomba')]
    assert slots
    return g,o,g.save_state(),slots[0]

def actor(g,slot):
    return {k:g.read(f'gObjectPool[{slot}].'+k) for k in ['oPosX','oPosY','oPosZ','oInteractType','oInteractStatus','oAction','activeFlags','oIntangibleTimer','hitboxRadius','hitboxHeight','hurtboxRadius','hurtboxHeight']}

def trial(g,o,base,slot,r):
    g.load_state(base);g.setup=True;edits=[];y=r['y'];pose(g,[-1950,y,-939],edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    if r['goomba']:
        for a,v in zip('XYZ',[-1989,y+5,-939]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.setup=False;initial=rich_sample(g,o);before=actor(g,slot);rows=[];events=[];actors=[]
    for _ in range(r['updates']):
        advance(g,NEUTRAL);rows.append(rich_sample(g,o));events.append(frame_events(g));actors.append(actor(g,slot))
        assert rows[-1]['topSurfaceCount']==0, 'Loaded top is outside this study'
        if rows[-1]['area']!=1:break
    actionEvents=[e for frame in events for e in frame if e['type']=='FLT_EXECUTE_ACTION']
    ground={g.constant(s) for s in ['ACT_CRAWLING','ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_DIVE_SLIDE','ACT_WALKING','ACT_FORWARD_GROUND_KB','ACT_BACKWARD_GROUND_KB','ACT_HARD_FORWARD_GROUND_KB','ACT_HARD_BACKWARD_GROUND_KB','ACT_FREEFALL_LAND']}
    return dict(recipe=r,edits=edits,initial=initial,actorBefore=before,actorSlot=slot,controls=[NEUTRAL]*len(rows),samples=rows,events=events,actors=actors,groundActionExecuted=any(e['action'] in ground for e in actionEvents),capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows))

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,base,slot=root(capture);q,qo,qbase,qslot=root(capture);assert qslot==slot
    trials=[]
    for y in [21778,25000,32767,67277]:
      for goomba in [False,True]:
        r=dict(y=y,goomba=goomba,updates=1 if y==21778 else 40);t=trial(g,o,base,slot,r);assert t==trial(q,qo,qbase,qslot,r);trials.append(t)
        print(r,t['samples'][0]['actionName'],t['samples'][0]['movement'],'ground',t['groundActionExecuted'],'top',t['samples'][0]['topSurfaceCount'],flush=True)
    sources=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='77ed7515d9ddce96fe00a030a26aae8663b590b0',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(capture),sourceSha256={p:digest(sources/p) for p in ['src/game/interaction.c','src/game/mario_actions_airborne.c','src/game/mario_actions_automatic.c','src/game/mario_actions_cutscene.c','src/game/mario_actions_moving.c','src/game/mario_step.c','src/game/mario.c','levels/ssl/areas/1/macro.inc.c']},trials=trials,freshBoundaries=sum(len(t['samples']) for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
