"""Supply the box before the native air landing, never after it."""
import json,sys,math
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import roots,apply,advance,NEUTRAL,frame_events,f32,digest,ROOT,rich_sample,write

AIR=dict(phase=128,pos=[-1930,1837.8726806640625,-880],yaw=0,speed=20,feetClearance=1)
BOX=[-1857.8465576171875,1839.883544921875,-940.83349609375]

def trial(g,o,states,r,full=False):
    g.load_state(states[r['boxPhase']]);g.mode='actor';edits=[]
    for a,v in zip('XYZ',r['box']):write(g,'gObjectPool[49].oPos'+a,v,edits)
    g.mode='controls';prior=[]
    while g.read('gObjectPool[61].oTimer')<128:
        advance(g,NEUTRAL)
        if full:prior.append(rich_sample(g,o))
    edits+=apply(g,AIR);initial=rich_sample(g,o) if full else None;rows=[];events=[]
    for k in range(33 if full else 4):
        advance(g,NEUTRAL)
        if full:s=rich_sample(g,o);events.append(frame_events(g))
        else:s=dict(action=g.read('gMarioState.action'),movement=g.read('gMarioState.pos'),display=g.read('gMarioObject.header.gfx.pos'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')))
        rows.append(s)
        if g.read('gCurrAreaIndex')!=1:break
    return dict(recipe=r,airCut=AIR,edits=edits if full else None,initial=initial,prior=prior,samples=rows,events=events,controls=[NEUTRAL]*(len(prior)+len(rows)))

capture=Path(sys.argv[1]);g,o,states,meshes=roots(capture)
recipes=[]
for phase in [128,127,126]:
 for dy in [0,-8.454086303710938,-12.908172607421875,-32,-64,-125,-124,-123,-122,-121,-120,-119,-118,-117,-116,32]:
    recipes.append(dict(boxPhase=phase,box=[BOX[0],f32(BOX[1]+dy),BOX[2]],menu='same-XYZ-height-adjustment'))
for x in [-1830,-1820,-1810,-1850,-1870]:
 for z in [-910,-890,-870,-850,-830]:
    recipes.append(dict(boxPhase=128,box=[x,BOX[1],z],menu='prelanding-contact-edge'))
for phase in [127,126]:
    provisional=dict(boxPhase=phase,box=[BOX[0],1716.883544921875,BOX[2]],menu='inverse-native-box-rise')
    seen=trial(g,o,states,provisional,True)['initial']['actor']['oPosY']
    for finalY in [1716.883544921875+i for i in range(6)]+[1725.337646484375+i for i in range(6)]:
        recipes.append(dict(boxPhase=phase,box=[BOX[0],f32(1716.883544921875+finalY-seen),BOX[2]],menu='inverse-native-box-rise',targetBefore128Y=finalY))
best=[];summaries=[];counts=dict(trials=0,gaps=0,captures=0)
for r in recipes:
    t=trial(g,o,states,r);a,b,c,d=t['samples'];gap=c['display'][1]-c['movement'][1]
    score=(int(d['used']==64 and d['platform']==61),int(c['floorY']==768 and gap>800),int(b['action']==g.constant('ACT_BUTT_SLIDE')),-abs(c['movement'][1]-768),gap)
    counts['trials']+=1;counts['gaps']+=score[1];counts['captures']+=score[0]
    summaries.append(dict(recipe=r,score=score,samples=t['samples']))
    if len(best)<6 or score>best[-1][0]:best.append((score,r));best.sort(reverse=True,key=lambda x:x[0]);best=best[:6]
    print('TRIAL',json.dumps(dict(recipe=r,score=score,actions=[x['action'] for x in t['samples']],positions=[x['movement'] for x in t['samples']])),flush=True)
selected=[recipes[0]]+[r for s,r in best if r!=recipes[0]]
for phase in [127,126]:
    candidates=[s for s in summaries if s['recipe']['boxPhase']==phase]
    chosen=max(candidates,key=lambda s:s['score'])['recipe']
    if chosen not in selected:selected.append(chosen)
q,qo,qs,qm=roots(capture);details=[]
for r in selected:
    t=trial(g,o,states,r,True);assert t==trial(q,qo,qs,r,True);details.append(t)
source=ROOT.parents[2]/'reference-sm64-decomp'
result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='921e4d1954d79f3b4deb6958c88419a8f4bd5a28',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),supportScriptSha256=digest(Path(__file__).with_name('search.py')),baselineSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),pythonVersion=sys.version,sourceSha256={p:digest(source/p) for p in ['src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/mario.c','src/game/mario_step.c','src/game/interaction.c','src/game/platform_displacement.c','src/engine/surface_collision.c','src/game/behaviors/jumping_box.inc.c']},editStages='First3 actorXYZ writes at recipe.boxPhase. Then11 Mario airborne writes at phase128. No non-controller writes afterward, enforced by Guard.',counts=counts,recipes=recipes,best=[dict(score=s,recipe=r) for s,r in best],trials=details,verifiedFreshTrials=len(details),verifiedFreshBoundaries=sum(len(t['samples'])+len(t['prior']) for t in details))
result['screenSummaries']=summaries
with Path(sys.argv[2]).open('x') as f:json.dump(result,f,indent=2);f.write('\n')
print(json.dumps(dict(counts=counts,best=result['best'],verifiedFreshBoundaries=result['verifiedFreshBoundaries']),indent=2))
