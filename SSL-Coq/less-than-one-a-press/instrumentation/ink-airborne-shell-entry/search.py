"""Bounded JP airborne shell-entry controls; all state cuts are explicit.

Tests the proposed simultaneous shell-mount/Z-cancel/Crazy-Box shove.
The accepted original prefix is retained; a high airborne pose and actor
coordinates are supplied. No reachability claim follows from these cuts.
"""
import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HELPERS = ROOT / 'instrumentation/wafel-jp-pilot'
sys.path.insert(0, str(HELPERS))
from ink_slide_handoff import shell_root, rich_sample, advance, trial
from ink_floorless_warp import NEUTRAL
from ink_crawl_predecessors import pose, write
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest


def actor(g, o, slot):
    return dict(slot=slot, behavior=str(g.read(f'gObjectPool[{slot}].behavior')),
                position=[g.read(f'gObjectPool[{slot}].oPos'+a) for a in 'XYZ'],
                **{f:g.read(f'gObjectPool[{slot}].'+f) for f in
                   ['oAction','oHeldState','oInteractStatus','oIntangibleTimer',
                    'activeFlags','oVelX','oVelY','oVelZ','hitboxRadius','hitboxHeight']},
                riddenSlot=o.slot(g.read('gMarioState.riddenObj')))


def one(g, o, base, slot, recipe):
    g.load_state(base)
    edits=[]
    y=recipe['height']
    pose(g, [-1950,y,-939], edits)
    for field,value in [('action',g.constant('ACT_FREEFALL')),('actionState',0),
                        ('actionTimer',0),('forwardVel',20),('vel',[20,-16,0]),
                        ('faceAngle',[0,0x4000,0])]:
        write(g,'gMarioState.'+field,value,edits)
    if recipe['shell']:
        for a,v in zip('XYZ',[-1950,y-10,-939]):
            write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    if recipe['box']:
        for a,v in zip('XYZ',[-1989,y,-939]):
            write(g,'gObjectPool[49].oPos'+a,v,edits)
    initial=rich_sample(g,o)
    rows=[]; events=[]; controls=[]; actors=[]
    for i in range(40):
        pad=dict(buttons=0x2000,stick=[0,0]) if i==recipe['zDelay'] else NEUTRAL
        advance(g,pad)
        rows.append(rich_sample(g,o));events.append(frame_events(g));controls.append(pad)
        actors.append([actor(g,o,j) for j in [49,slot]])
        if rows[-1]['area']!=1: break
    arrival=next((r for r in rows if r['area']==2),None)
    return dict(recipe=recipe,edits=edits,initial=initial,controls=controls,
                samples=rows,events=events,actors=actors,
                firstGap=rows[0]['display'][1]-rows[0]['movement'][1],
                topCapture=any(r['floorOwner']==r['platform']==61 and r['used']==64 for r in rows),
                usefulArrival=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717))


def run(capture):
    g,o,base,prep=shell_root(capture)
    cases=[]
    for height in [1741,67277]:
        for name,shell,box,delay in [('shell-z',True,False,0),
                                    ('shell-box-z',True,True,0),
                                    ('shell-box-delayed-z',True,True,1),
                                    ('box-freefall-z',False,True,0)]:
            cases.append(dict(name=name,height=height,shell=shell,box=box,zDelay=delay))
    trials=[one(g,o,base,prep['slot'],r) for r in cases]
    controls=[]
    for height in [1741,67277]:
        r=dict(name=f'butt-control-{height}',action='ACT_BUTT_SLIDE',height=height,
               speed=20,pad=NEUTRAL,box=True)
        controls.append(trial(g,o,base,base,r))
    # A new boot and prefix, not just restoring the first root, checks the
    # recorded boundary/event projection for every new trial and control.
    q,qo,qbase,qprep=shell_root(capture)
    assert qprep==prep
    for old,r in zip(trials,cases):
        assert one(q,qo,qbase,qprep['slot'],r)==old
    for old in controls:
        assert trial(q,qo,qbase,qbase,old['recipe'])==old
        assert old['topCapture'] and old['usefulArrival']
    source=ROOT.parents[2]/'reference-sm64-decomp'
    return dict(schema=1,date='2026-11-14',scope=__doc__,
                evidence='Wafel 0.8.5 native JP supplied-state experiments; not original-ROM replay or controller route',
                proofBaseRevision='921e4d1954d79f3b4deb6958c88419a8f4bd5a28',
                sourceRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',
                scriptSha256=digest(__file__),baselineSha256=digest(capture),
                runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),
                sourceSha256={f:digest(source/f) for f in ['src/game/interaction.c','src/game/mario.c','src/game/mario_actions_moving.c','src/game/mario_step.c']},
                dependenciesSha256={f:digest(HELPERS/f) for f in ['ink_slide_handoff.py','ink_pu_vpu.py','ink_floorless_warp.py','ink_crawl_predecessors.py','ink_timer130_crawl.py','replay.py']},
                shellPreparation=prep,trials=trials,positiveControls=controls,
                verification=dict(freshInstances=2,trialsMatched=len(trials)+len(controls),
                                  boundariesMatched=sum(len(t['samples']) for t in trials+controls),
                                  allInputsAOff=True,gameTimerIncrementsOne=True,
                                  observationLimit='Native completed fields and Wafel events; no direct interaction-loop or quarter-return hook.'))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();result=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(result,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps([dict(name=t['recipe'],first=t['samples'][0]['movement'],
                          action=t['samples'][0]['actionName'],gap=t['firstGap'],
                          collisions=t['samples'][0]['collisionSlots'],
                          capture=t['topCapture'],useful=t['usefulArrival'])
                      for t in result['trials']+result['positiveControls']],indent=2))
