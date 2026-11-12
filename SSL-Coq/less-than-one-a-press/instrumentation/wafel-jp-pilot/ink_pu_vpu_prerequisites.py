"""Local prerequisite probes; no claim to produce a PU entry or a high HOLP.

Probe ordinary crawl establishment after a position-only PU seed; separately
probe actual release callbacks from supplied holding/action/HOLP cuts.
"""
import argparse
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_pu_vpu import advance, digest, sample
from ink_floorless_warp import reach_after_pillars, NEUTRAL
from ink_crawl_predecessors import pose, write


def actor_sample(g, o, slot):
    return dict(held=o.slot(g.read('gMarioState.heldObj')),
                holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),
                mario=g.read('gMarioState.pos'), action=g.read('gMarioState.action'),
                actor={k:g.read('gObjectPool[%d].%s' % (slot, k)) for k in
                       (('oPosX','oPosY','oPosZ','oAction','oHeldState','oIntangibleTimer',
                        'oForwardVel','oVelY','oFloorHeight','activeFlags',
                        'hitboxRadius','hitboxHeight') +
                        (('oBobombFuseLit','oBobombFuseTimer') if slot==39 else ()))})


def run(capture):
    g, o = reach_after_pillars(capture)
    release_state=None
    while not (g.read('gObjectPool[61].oAction') == 1 and g.read('gObjectPool[61].oTimer') == 130):
        if g.read('gObjectPool[61].oAction') == 1 and g.read('gObjectPool[61].oTimer') == 110:
            release_state=g.save_state()
        advance(g, NEUTRAL)
    assert release_state is not None
    state=g.save_state(); crawls=[]; releases=[]
    for name, xyz in [('horizontal-pad',[63586,768,-939]),
                      ('vertical-high',[-1950,67277,-939])]:
        g.load_state(state); edits=[];pose(g, xyz, edits)
        initial=sample(g,o);rows=[];controls=[]
        for _ in range(48):
            pad=dict(buttons=0x2000,stick=[0,32]);advance(g,pad)
            rows.append(sample(g,o));controls.append(pad)
        crawls.append(dict(name=name,edits=edits,initial=initial,controls=controls,samples=rows))
    for slot, behavior in [(49,'bhvJumpingBox'), (39,'bhvBobomb')]:
        for kind, action, timer, holp in [
                ('throw-valid',0x80000588,6,[-2021,67277,-939]),
                ('drop-valid',0x387,7,[-2021,67277,-939]),
                ('throw-null-floor',0x80000588,6,[9000,67277,-939])]:
            if slot==39 and kind!='throw-null-floor':
                # Bob-omb's smaller native hitbox needs the existing
                # alternative-push X=-1979, rather than box X=-1989.
                holp=[holp[0]+10,holp[1],holp[2]]
            g.load_state(release_state); edits=[]
            pose(g,[-5883,1024,764],edits)
            assert g.read('gObjectPool[%d].behavior'%slot)==g.address(behavior)
            edits.append(dict(path='gMarioState.heldObj',beforeSlot=o.slot(g.read('gMarioState.heldObj')),afterSlot=slot))
            g.write('gMarioState.heldObj',g.address('gObjectPool[%d]'%slot))
            write(g,'gObjectPool[%d].oHeldState'%slot,1,edits)
            # Avoid HOLD_IDLE's native Crazy Box bounce. A pre-release
            # throwing cut still executes the actor's ordinary held callback.
            write(g,'gMarioState.action',0x80000588,edits)
            write(g,'gMarioState.actionTimer',0,edits)
            write(g,'gMarioState.forwardVel',0,edits)
            # In particular the Bob-omb callback has a real 4000-unit gate.
            # Supply actor proximity so this is an initialized held cut,
            # rather than a distant pointer with no executed held callback.
            for axis,value in zip('XYZ',[-5383,1024,764]):
                write(g,'gObjectPool[%d].oPos%s'%(slot,axis),value,edits)
            preparation_edit_count=len(edits)
            # A real held callback initializes invisibility/intangibility.
            advance(g,NEUTRAL)
            held=actor_sample(g,o,slot)
            for f,v in [('action',action),('actionTimer',timer),('actionState',0),
                        ('faceAngle',[0,0x4000,0])]:
                write(g,'gMarioState.'+f,v,edits)
            write(g,'gMarioState.marioBodyState.heldObjLastPosition',holp,edits)
            initial=actor_sample(g,o,slot);rows=[]
            for _ in range(12):
                advance(g,NEUTRAL);rows.append(actor_sample(g,o,slot))
            joined=None
            if kind=='throw-valid':
                waiting=[]
                while g.read('gObjectPool[61].oTimer') < 130:
                    advance(g,NEUTRAL);waiting.append(actor_sample(g,o,slot))
                assert g.read('gObjectPool[61].oTimer') == 130
                join_edits=[]
                # A second, explicit conditional cut supplies ONLY Mario's
                # still-unproduced VPU crawl. The thrown actor is untouched.
                pose(g,[-1950,67277,-939],join_edits)
                for field,value in [('action',0x04008448),('actionState',0),
                                    ('actionTimer',0),('forwardVel',5),('vel',[4,0,0]),
                                    ('faceAngle',[0,0x4000,0])]:
                    write(g,'gMarioState.'+field,value,join_edits)
                jinitial=sample(g,o);jrows=[];jactors=[];jcontrols=[]
                for i in range(32):
                    pad=dict(buttons=0x2000,stick=[0,64]) if i==0 else NEUTRAL
                    advance(g,pad);jcontrols.append(pad);jrows.append(sample(g,o))
                    jactors.append(actor_sample(g,o,slot))
                    if g.read('gCurrAreaIndex')!=1:break
                joined=dict(waitingInputs=[NEUTRAL]*len(waiting),waiting=waiting,
                            marioOnlyEdits=join_edits,initial=jinitial,controls=jcontrols,
                            samples=jrows,actorSamples=jactors)
            releases.append(dict(slot=slot,behavior=behavior,kind=kind,edits=edits,
                                 preparationEditCount=preparation_edit_count,
                                 heldPreparationInput=NEUTRAL,heldPreparationResult=held,
                                 initial=initial,controls=[NEUTRAL]*12,samples=rows,
                                 joinedSuppliedCrawler=joined))
    return dict(schema=1,scope='Position-only PU/VPU entry cuts and separately supplied holding/HOLP/action-timer cuts',
                baselineSha256=digest(capture),runtimeSha256=digest('build/wafel-pilot/sm64_jp.dll'),
                scriptSha256=digest(__file__),crawlTrials=crawls,releaseTrials=releases)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(crawls=[dict(name=t['name'],firstCrawl=next((i+1 for i,s in enumerate(t['samples'])if s['action']==0x04008448),None),final=t['samples'][-1]['movement'])for t in r['crawlTrials']],
                         releases=[dict(kind=t['kind'],slot=t['slot'],first=t['samples'][0],last=t['samples'][-1])for t in r['releaseTrials']]),indent=2))
