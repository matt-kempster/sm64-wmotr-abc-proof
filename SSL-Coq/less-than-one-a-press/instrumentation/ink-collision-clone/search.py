"""Conditional fixed collision-only Crazy Box diagnostics; not a clone route.

Crazy Box is HOLDABLE, so assigning its native carry-script command is an
explicit diagnostic override, not a demonstrated fake-pickup outcome.
No physics or hitbox fields are written; normal object flags/collision run.
"""
import json,sys,math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/ink-supported-slide-preparation'))
from search import roots,apply,advance,NEUTRAL,frame_events,f32,digest,rich_sample,write

AIR=dict(phase=128,pos=[-1930,1837.8726806640625,-880],yaw=0,speed=20,feetetClearance=1)
OLDXZ=[-1857.8465576171875,-940.83349609375]

def actor(g):
    row={k:g.read('gObjectPool[49].'+k) for k in ['oPosX','oPosY','oPosZ','oFlags','oHeldState','oAction','oTimer','oIntangibleTimer','oInteractType','oInteractStatus','oVelX','oVelY','oVelZ','oForwardVel','activeFlags','hitboxRadius','hitboxHeight','hitboxDownOffset','bhvStackIndex']}
    cmd=g.read('gObjectPool[49].curBhvCommand')
    row['commandAtCarryStart']=cmd==g.address('bhvCarrySomething5')
    row['commandAtCarryBreak']=cmd==g.address('bhvCarrySomething5[1]')
    row['behaviorStillJumpingBox']=g.read('gObjectPool[49].behavior')==g.address('bhvJumpingBox')
    return row

def trial(g,o,base,r,full=False):
    g.load_state(base);edits=apply(g,AIR);g.mode='initial'
    for a,v in zip('XYZ',r['box']):write(g,'gObjectPool[49].oPos'+a,v,edits)
    if r['frozen']:
        edits.append(dict(path='gObjectPool[49].curBhvCommand',before='native jumping-box loop',afterSymbol='bhvCarrySomething5'))
        g.write('gObjectPool[49].curBhvCommand',g.address('bhvCarrySomething5'))
        write(g,'gObjectPool[49].bhvStackIndex',0,edits)
    g.mode='controls';initial=rich_sample(g,o) if full else None;initialActor=actor(g) if full else None
    rows=[];events=[];actors=[]
    for i in range(33 if full else 4):
        advance(g,NEUTRAL)
        if full:
            s=rich_sample(g,o);events.append(frame_events(g));actors.append(actor(g))
        else:
            s=dict(action=g.read('gMarioState.action'),movement=g.read('gMarioState.pos'),display=g.read('gMarioObject.header.gfx.pos'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),collisions=[o.slot(g.read('gMarioObject.collidedObjs[%d]'%j)) for j in range(g.read('gMarioObject.numCollidedObjs'))])
        rows.append(s)
        if g.read('gCurrAreaIndex')!=1:break
    if r['frozen']:
        assert [g.read('gObjectPool[49].oPos'+a) for a in 'XYZ']==r['box']
    return dict(recipe=r,airCut=AIR,edits=edits if full else None,initial=initial,initialActor=initialActor,samples=rows,events=events,actorSamples=actors,controls=[NEUTRAL]*len(rows))

def score(t):
    a,b,c,d=t['samples'][:4];gap=c['display'][1]-c['movement'][1]
    return (int(d['used']==64 and d['platform']==61),int(c['floorY']==768 and gap>800),int(b['action']==0x00840452),int(a['action']==0x04000471),gap)

def main():
    capture=Path(sys.argv[1]);g,o,states,meshes=roots(capture);base=states[128]
    recipes=[]
    for frozen in [False,True]:
        for y in [1716.883544921875,1721.883544921875,1723,1725.337646484375,1729.791748046875,1839.883544921875]:
            recipes.append(dict(name=('fixed' if frozen else 'native')+'-same-XZ-Y'+str(y),frozen=frozen,box=[OLDXZ[0],y,OLDXZ[1]],menu='vertical-controls'))
    # Collision-before-carry gate: actor is just outside Mario's initial
    # horizontal circle but inside the postlanding circle. Y stays fixed.
    for angle in range(0,65536,256):
      a=angle*math.tau/65536
      for radius in [108,110,111,111.5,111.9]:
        x=f32(-1930+radius*math.sin(a));z=f32(-875.0875244140625+radius*math.cos(a))
        d0=math.hypot(x+1930,z+880);d1=math.hypot(x+1930,z+875.0875244140625)
        if d0<112 or d1>=112:continue
        for y in [1725.337646484375,1839.883544921875]:
            recipes.append(dict(name=f'fixed-contact-gate-{angle}-{radius}-{y}',frozen=True,box=[x,y,z],menu='horizontal-late-contact-gate',angle=angle,radius=radius,initialDistance=d0,landingDistance=d1))
    summaries=[];best=[]
    for idx,r in enumerate(recipes):
        t=trial(g,o,base,r);sc=score(t);summaries.append(dict(recipe=r,score=sc,samples=t['samples']))
        if len(best)<6 or sc>best[-1][0]:best.append((sc,r));best.sort(reverse=True,key=lambda a:a[0]);best=best[:6]
        if idx<12 or sc[0] or sc[1]:print('CASE',r['name'],sc,[s['movement'] for s in t['samples']],flush=True)
    selected=recipes[:12]+[r for sc,r in best if r not in recipes[:12]]
    q,qo,qs,qm=roots(capture);details=[]
    for r in selected:
        t=trial(g,o,base,r,True);other=trial(q,qo,qs[128],r,True);assert t==other,r;details.append(t)
    source=ROOT.parents[2]/'reference-sm64-decomp'
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='a1df2746333da67c3d4034eba71ad092fbd4103b',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),supportScriptSha256=digest(ROOT/'instrumentation/ink-supported-slide-preparation/search.py'),baselineSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),sourceSha256={p:digest(source/p) for p in ['src/game/behaviors/jumping_box.inc.c','src/game/object_helpers.c','src/game/object_collision.c','src/engine/behavior_script.c','data/behavior_data.c','src/game/interaction.c']},counts=dict(candidates=len(recipes),candidateUpdates=4*len(recipes),gaps=sum(s['score'][1] for s in summaries),captures=sum(s['score'][0] for s in summaries)),trials=details,screenSummaries=summaries,verifiedFreshTrials=len(details),verifiedFreshBoundaries=sum(len(t['samples']) for t in details))
    with Path(sys.argv[2]).open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print(json.dumps({k:result[k] for k in ['counts','verifiedFreshTrials','verifiedFreshBoundaries']},indent=2))

if __name__=='__main__':main()
