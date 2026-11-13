"""Finite JP supplied-slide handoff diagnostics. No claim of controller reachability.

Uses the existing authenticated four-pillar prefix and unedited native surfaces,
cache, warp, top behavior, RNG and allocator. Every gameplay setup edit is logged.
After the last setup edit only controller pads are written until trial end.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, NEUTRAL, set_input
from ink_pu_vpu import sample, digest
from ink_timer130_crawl import frame_events
from ink_crawl_predecessors import pose, write

ROOT = Path(__file__).resolve().parents[2]
ACTIONS = ['ACT_CRAWLING', 'ACT_BUTT_SLIDE', 'ACT_STOMACH_SLIDE',
           'ACT_CROUCH_SLIDE', 'ACT_DIVE_SLIDE', 'ACT_SLIDE_KICK_SLIDE',
           'ACT_HOLD_BUTT_SLIDE', 'ACT_HOLD_STOMACH_SLIDE',
           'ACT_BUTT_SLIDE_AIR', 'ACT_SLIDE_KICK']

def advance(g, pad):
    assert not pad['buttons'] & 0x8000
    timer = g.read('gGlobalTimer')
    set_input(g, pad)
    g.advance()
    assert g.read('gGlobalTimer') == timer + 1
    assert not g.read('gMarioState.input') & 0x82

def rich_sample(g, o):
    r = sample(g, o)
    r.update(actionName=g.mario_action_names().get(r['action']),
             actionTimer=g.read('gMarioState.actionTimer'),
             actionState=g.read('gMarioState.actionState'),
             slideVelocity=[g.read('gMarioState.slideVelX'),g.read('gMarioState.slideVelZ')],
             slideYaw=g.read('gMarioState.slideYaw'),
             held=o.slot(g.read('gMarioState.heldObj')),
             wallPresent=not g.read('gMarioState.wall').is_null(),
             warpPosition=[g.read('gObjectPool[64].oPos'+a) for a in 'XYZ'],
             warpHitbox=[g.read('gObjectPool[64].'+f) for f in ('hitboxRadius','hitboxHeight','hitboxDownOffset')],
             marioHitbox=[g.read('gMarioObject.'+f) for f in ('hitboxRadius','hitboxHeight','hitboxDownOffset')])
    return r

def roots(capture):
    g,o=reach_after_pillars(capture)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==129):
        advance(g,NEUTRAL)
    state129=g.save_state()
    advance(g,NEUTRAL)
    ordinary=g.save_state()
    g.load_state(state129)
    edits=[]
    assert g.read('gObjectPool[39].behavior')==g.address('bhvBobomb')
    edits.append(dict(path='gMarioState.heldObj',beforeSlot=o.slot(g.read('gMarioState.heldObj')),afterSlot=39))
    g.write('gMarioState.heldObj',g.address('gObjectPool[39]'))
    write(g,'gObjectPool[39].oHeldState',1,edits)
    for a,v in zip('XYZ',g.read('gMarioState.pos')):
        write(g,'gObjectPool[39].oPos'+a,v,edits)
    write(g,'gMarioState.action',g.constant('ACT_THROWING'),edits)
    write(g,'gMarioState.actionTimer',0,edits)
    advance(g,NEUTRAL)
    held=rich_sample(g,o)
    assert held['held']==39 and g.read('gObjectPool[39].oHeldState')==1
    return g,o,ordinary,g.save_state(),dict(edits=edits,control=NEUTRAL,after=held)

def recipes():
    for action in ACTIONS:
        for height in [1741,67277]:
            for speed in [0,5,20,60]:
                for pad_name,pad in [('neutral',NEUTRAL),('z-up',dict(buttons=0x2000,stick=[0,64]))]:
                    yield dict(name=f'{action}-y{height}-v{speed}-{pad_name}',action=action,height=height,speed=speed,pad=pad,box=True)
            yield dict(name=f'{action}-y{height}-v20-no-box',action=action,height=height,speed=20,pad=NEUTRAL,box=False)

def trial(g,o,base,held_base,recipe):
    g.load_state(held_base if 'HOLD_' in recipe['action'] else base)
    edits=[]
    pose(g,[-1950,recipe['height'],-939],edits)
    for field,value in [('action',g.constant(recipe['action'])),('actionState',0),('actionTimer',0),
                        ('forwardVel',recipe['speed']),('vel',[recipe['speed'],0,0]),
                        ('faceAngle',[0,0x4000,0]),('slideVelX',recipe['speed']),('slideVelZ',0),('slideYaw',0x4000)]:
        write(g,'gMarioState.'+field,value,edits)
    actor_slot=recipe.get('actorSlot',49)
    if recipe['box']:
        for a,v in zip('XYZ',[recipe.get('actorX',-1989),recipe['height'],-939]):
            write(g,f'gObjectPool[{actor_slot}].oPos'+a,v,edits)
    initial=rich_sample(g,o)
    rows=[];events=[];pads=[];actors=[]
    for i in range(32):
        pad=recipe['pad'] if i==0 else NEUTRAL
        advance(g,pad);pads.append(pad);rows.append(rich_sample(g,o));events.append(frame_events(g))
        actors.append({f:g.read(f'gObjectPool[{actor_slot}].'+f) for f in ['oPosX','oPosY','oPosZ','oHeldState','oIntangibleTimer','oAction','activeFlags','oForwardVel','oVelX','oVelY','oVelZ','oFloorHeight','hitboxRadius','hitboxHeight','hitboxDownOffset']})
        if rows[-1]['area']!=1:break
    arrival=next((r for r in rows if r['area']==2),None)
    useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    top_capture=any(r['floorOwner']==r['platform']==61 and r['used']==64 for r in rows)
    return dict(recipe=recipe,edits=edits,initial=initial,controls=pads,samples=rows,events=events,actorSamples=actors,
                topCapture=top_capture,usefulArrival=useful,firstGap=rows[0]['display'][1]-rows[0]['movement'][1])

def shell_root(capture):
    g,o=reach_after_pillars(capture)
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==128):
        advance(g,NEUTRAL)
    edits=[]
    assert g.read('gObjectPool[32].behavior')==g.address('bhvExclamationBox')
    assert g.read('gObjectPool[32].oBhvParams2ndByte')==3
    write(g,'gObjectPool[32].oAction',4,edits)
    advance(g,NEUTRAL);advance(g,NEUTRAL)
    shells=[i for i in range(240) if g.read(f'gObjectPool[{i}].activeFlags') and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')]
    assert len(shells)==1
    return g,o,g.save_state(),dict(edits=edits,controls=[NEUTRAL,NEUTRAL],slot=shells[0],after=rich_sample(g,o))

def entry_trials():
    import ink_top_slide_to_crawl as study
    from collections import Counter
    g,o,base,setup=study.root_state('slide117')
    summaries=[];selected=[];counts=Counter();total=0
    # Exactly the previously reproduced landing/freefall root; no new state
    # supply at the grounded slide. Steer it for the remaining top lifetime.
    for direction in list(range(0,65536,4096))+['inward','outward','left','right','next-uphill','next-brake']:
        for magnitude in [32,64,127]:
            for buttons in [0,0x2000]:
                g.load_state(base);rows=[]
                while g.read('gCurrAreaIndex')==1 and g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')<=150:
                    pad=study.controller(g,study.heading(g,direction),buttons,magnitude)
                    r=study.advance(g,o,pad);rows.append(r);total+=1
                gs=[r for r in rows if r['state']['action'] in [g.constant(a) for a in ACTIONS[1:8]]]
                deep=[r for r in gs if r['state']['geometry'] and r['state']['geometry']['deep']]
                gaps=[r for r in rows if abs(r['state']['display'][1]-r['state']['position'][1])>1]
                record=dict(direction=direction,magnitude=magnitude,buttons=buttons,frames=len(rows),groundSlideFrames=len(gs),deepGroundSlideFrames=len(deep),gapFrames=len(gaps),last=rows[-1]['state'])
                summaries.append(record)
                counts['groundSlideFrames']+=len(gs);counts['deepGroundSlideFrames']+=len(deep);counts['gapFrames']+=len(gaps)
                if deep or gaps or (direction=='inward' and magnitude==64 and buttons==0):
                    selected.append(dict(policy={k:record[k] for k in ['direction','magnitude','buttons']},records=rows))
    return dict(setup=setup,scope='Controller-only suffix after prior supplied exterior freefall; no pusher supplied; finite policies, not a complete route or exclusion.',policies=summaries,selected=selected,counts=dict(counts),frames=total)

def validate_positive(t):
    if not t['usefulArrival']:return
    rows=t['samples']
    assert rows[0]['movement']==rows[0]['collision']==[-1882,768,-939]
    assert rows[0]['display']==[-1882,t['initial']['movement'][1],-939]
    assert rows[1]['action']==0x1300 and rows[1]['actionArg']==0x40001 and rows[1]['used']==64
    assert rows[1]['floorOwner']==rows[1]['platform']==61
    assert rows[1]['topSurfaceCount']==6 and rows[1]['collisionSlots']==[64]
    assert rows[2]['warpOp']==4 and rows[2]['countdown']==19
    assert all(r['floorOwner']==r['platform']==61 for r in rows[1:-1])
    assert rows[-2]['topActive']==0 and rows[-2]['platform']==61
    assert rows[-1]['area']==2 and rows[-1]['movement']==[365.5927734375,5500,-1096.8026123046875]

def boundary_trials(g,o,base,held_base,sg,so,sbase,shell_slot):
    heights=list(range(1738,1807))+[19839,19840,20000,21776,21777,21778,21779,25000,32766,32767,32768]
    result=[]
    for action in ['ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_HOLD_BUTT_SLIDE','ACT_HOLD_STOMACH_SLIDE','ACT_DIVE_SLIDE']:
        for y in heights:
            recipe=dict(name=f'{action}-boundary-y{y}',action=action,height=y,speed=20,pad=NEUTRAL,box=True)
            if action=='ACT_DIVE_SLIDE':
                recipe.update(actorSlot=shell_slot,actorX=-1971)
                t=trial(sg,so,sbase,sbase,recipe)
            else:t=trial(g,o,base,held_base,recipe)
            validate_positive(t)
            result.append(t)
    for speed in [4,4.25,4.3478,4.347826,4.347827,4.35,4.5,17.39,17.4]:
        recipe=dict(name=f'ACT_BUTT_SLIDE-speed-v{speed}',action='ACT_BUTT_SLIDE',height=1741,speed=speed,pad=NEUTRAL,box=True)
        t=trial(g,o,base,held_base,recipe);validate_positive(t);result.append(t)
    return result

def run(capture):
    g,o,base,held_base,held_preparation=roots(capture)
    trials=[trial(g,o,base,held_base,r) for r in recipes()]
    # Fresh native loads reproduce every observed handoff and one relevant
    # negative per action; this checks the full recorded projection and log.
    selected=[t for t in trials if t['usefulArrival'] or t['recipe']['speed']==20]
    for t in selected:
        assert trial(g,o,base,held_base,t['recipe'])==t
    extras=[]
    for height in [1741,67277]:
        recipe=dict(name=f'ACT_DIVE_SLIDE-y{height}-v20-bobomb',action='ACT_DIVE_SLIDE',height=height,speed=20,pad=NEUTRAL,box=True,actorSlot=39,actorX=-1979)
        extras.append(trial(g,o,base,held_base,recipe))
    sg,so,sbase,shell_preparation=shell_root(capture)
    for height in [1741,67277]:
        for action in ['ACT_DIVE_SLIDE','ACT_SLIDE_KICK_SLIDE','ACT_STOMACH_SLIDE']:
            recipe=dict(name=f'{action}-y{height}-v20-shell',action=action,height=height,speed=20,pad=NEUTRAL,box=True,actorSlot=shell_preparation['slot'],actorX=-1971)
            t=trial(sg,so,sbase,sbase,recipe)
            assert trial(sg,so,sbase,sbase,recipe)==t
            extras.append(t)
    boundaries=boundary_trials(g,o,base,held_base,sg,so,sbase,shell_preparation['slot'])
    for t in trials+extras:validate_positive(t)
    sources=ROOT.parents[2]/'reference-sm64-decomp'
    files=['src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/mario.c',
           'src/game/mario_step.c','src/game/interaction.c','src/engine/surface_collision.c',
           'src/engine/surface_load.c','src/game/object_collision.c','src/game/platform_displacement.c']
    return dict(schema=1,scope=__doc__,baselineSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),
                scriptSha256=digest(__file__),sourceSha256={f:digest(sources/f) for f in files},
                dependenciesSha256={f:digest(Path(__file__).with_name(f)) for f in ['ink_pu_vpu.py','ink_floorless_warp.py','ink_timer130_crawl.py','ink_crawl_predecessors.py','replay.py']},
                observationLimit='Native completed frame fields and Wafel action/movement event log; no direct query or quarter-return hook.',
                heldPreparation=held_preparation,shellPreparation=shell_preparation,verifiedTrials=len(selected)+6,verifiedFrames=sum(len(t['samples']) for t in selected)+sum(len(t['samples']) for t in extras[2:]),trials=trials,alternateActorTrials=extras,boundaryTrials=boundaries,entry=entry_trials())

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(output=str(a.output),trials=len(r['trials']),verifiedTrials=r['verifiedTrials'],summary=[dict(name=t['recipe']['name'],gap=t['firstGap'],action=t['samples'][0]['actionName'],movement=t['samples'][0]['movement'],capture=t['topCapture'],useful=t['usefulArrival']) for t in r['trials']]),indent=2))
