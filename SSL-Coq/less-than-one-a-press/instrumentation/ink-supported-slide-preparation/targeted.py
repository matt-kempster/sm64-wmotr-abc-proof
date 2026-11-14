"""Small integer-boundary follow-up to the observed native landing/slide."""
import json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import roots,run_one,apply,advance,NEUTRAL,frame_events,f32,digest,ROOT
capture=Path(sys.argv[1]);g,o,states,meshes=roots(capture)
r=dict(phase=128,pos=[-1930,1837.8726806640625,-880],yaw=0,speed=20,feetClearance=1)
g.load_state(states[128]);apply(g,r);advance(g,NEUTRAL);p=g.read('gMarioState.pos');advance(g,NEUTRAL)
native=[e for e in frame_events(g) if e['type']=='FLT_EXECUTE_ACTION'][0]['pos']
trials=[]
for qx,qz in [(-1947,-1000),(-1950,-1000),(-1955,-1000),(-1960,-1000),(-1947,-970),(-1950,-970)]:
    vx,vz=qx-native[0],qz-native[2];d=math.hypot(vx,vz)
    box=[f32(qx-107*vx/d),p[1],f32(qz-107*vz/d)]
    t=run_one(g,o,states[128],r,box,True);trials.append(t)
    print('TARGET',qx,qz,'BOX',box)
    for s in t['samples'][:5]:print(s['topTimer'],s['actionName'],s['movement'],s['display'],s['floorY'],s['platform'],s['used'])
q,qo,qs,qm=roots(capture)
for t in trials:assert t==run_one(q,qo,qs[128],t['recipe'],t['boxAt129'],True)
source=ROOT.parents[2]/'reference-sm64-decomp'
result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='921e4d1954d79f3b4deb6958c88419a8f4bd5a28',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchScriptSha256=digest(Path(__file__).with_name('search.py')),baselineSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),pythonVersion=sys.version,sourceSha256={p:digest(source/p) for p in ['src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/mario.c','src/game/mario_step.c','src/game/interaction.c','src/game/platform_displacement.c','src/engine/surface_collision.c']},startingPhase=128,oldMesh=meshes[128],editStages='First 11 ledger writes are the initial supplied airborne Mario cut before128; final3 are actor-only XYZ before129, after native landing. Guard disallows all other non-controller writes.',nativePostCarryWithoutActor=native,proposedTargets=[[-1947,-1000],[-1950,-1000],[-1955,-1000],[-1960,-1000],[-1947,-970],[-1950,-970]],trials=trials,verifiedFreshTrials=len(trials),verifiedFreshBoundaries=sum(len(t['samples']) for t in trials))
with Path(sys.argv[2]).open('x') as f:json.dump(result,f,indent=2);f.write('\n')
