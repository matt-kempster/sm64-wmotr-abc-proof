"""Initialized native/carry-script single-actor controls for combination search.

Position and FREEFALL grants are not a controller or clone lineage. The
HOLDABLE Crazy Box forced_frozen case is separately a diagnostic override.
"""
import json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from fixtures import ROOT,roots,place_actor,actor_snapshot,advance,NEUTRAL,pose,write,rich_sample,frame_events,digest

class Guard:
    def __init__(self,g):self.g=g;self.setup=False
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        assert self.setup or p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        self.g.write(p,v)

def trial(g,o,base,r):
    g.load_state(base);g.setup=True;edits=[];y=r['y'];pose(g,[-1950,y,-939],edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    actorCut=place_actor(g,r['slot'],r['position'],edits,r['mode']);g.setup=False
    initial=rich_sample(g,o);samples=[];actors=[];events=[];pads=[]
    for _ in range(8):
        advance(g,NEUTRAL);samples.append(rich_sample(g,o));actors.append(actor_snapshot(g,r['slot']));events.append(frame_events(g));pads.append(NEUTRAL)
        if samples[-1]['area']!=1:break
    return dict(recipe=r,edits=edits,actorCut=actorCut,initial=initial,controls=pads,samples=samples,actors=actors,events=events,capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in samples))

def recipes(inv):
    for name in ['bhvGoomba','bhvFlyGuy','bhvKlepto','bhvJumpingBox','bhvKoopaShell']:
        row=next(r for r in inv if r['behavior']==name and r['intangible']==0 and r['radius']>0)
        for y in [25000,67277]:
          for contact in (['top','side'] if name in ['bhvGoomba','bhvFlyGuy','bhvKlepto'] else ['push'] if name=='bhvJumpingBox' else ['top']):
           for mode in ['native','forced_frozen' if row['holdable'] else 'carry_clone']:
            position=[-1989,y+5,-939] if contact=='side' else [-1950,y-10,-939] if contact=='top' else [-1989,y,-939]
            yield dict(behavior=name,slot=row['slot'],y=y,contact=contact,position=position,mode=mode)

def main():
    capture=Path(sys.argv[1]);out=Path(sys.argv[2]);g,o,base,inv,prep=roots(capture);g=Guard(g);q,qo,qbase,qinv,qprep=roots(capture);q=Guard(q);assert inv==qinv and prep==qprep
    trials=[]
    for r in recipes(inv):
        t=trial(g,o,base,r);assert t==trial(q,qo,qbase,r);trials.append(t)
        print(r['behavior'],r['y'],r['contact'],r['mode'],t['samples'][0]['actionName'],t['samples'][0]['movement'],'status',[a['oInteractStatus'] for a in t['actors'][:3]],flush=True)
    source=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),fixtureSha256=digest(Path(__file__).with_name('fixtures.py')),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),sourceSha256={p:digest(source/p) for p in ['src/game/object_helpers.c','src/game/object_collision.c','src/engine/behavior_script.c','data/behavior_data.c','src/game/interaction.c','src/game/behaviors/goomba.inc.c','src/game/behaviors/fly_guy.inc.c','src/game/behaviors/klepto.inc.c','src/game/behaviors/jumping_box.inc.c']},inventory=inv,shellPreparation=prep,trials=trials,freshBoundaries=sum(len(t['samples']) for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('TRIALS',len(trials),'FRESH',result['freshBoundaries'],'CAPTURE',sum(t['capture'] for t in trials),flush=True)

if __name__=='__main__':main()
