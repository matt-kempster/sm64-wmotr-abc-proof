"""Conditional actor-release predecessors for the timer130 jumping-box push.

This is NOT a joined gameplay route: an initial release-state cut is supplied
for the box; ordinary-location Mario is supplied CRAWLING at129 and executes
one update to obtain the real100-unit hitbox; high Mario position is supplied
at130. Between those cuts the actor follows native updates, with no actor edits.
The separate ledgers keep actor survival separate from Mario reachability.
"""
import argparse, hashlib, json, sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, set_input, NEUTRAL
from ink_timer130_crawl import snapshot, CRAWLING

PHASES=[110,118,122,126,128,129,130]
HEIGHTS=[1500,1600,1625,1650,1700,1741,1800,1900]


def actor(g):
    p='gObjectPool[49].'
    return dict(isJumpingBox=g.read(p+'behavior')==g.address('bhvJumpingBox'),**{k:g.read(p+k) for k in ['activeFlags','oHeldState','oAction','oTimer',
        'oIntangibleTimer','oPosX','oPosY','oPosZ','oVelX','oVelY','oVelZ',
        'oForwardVel','oMoveAngleYaw','oMoveFlags','oFloorHeight']})


def advance(g,pad=NEUTRAL):
    assert not pad['buttons']&0x8000
    set_input(g,pad);g.advance()
    assert not g.read('gMarioState.input')&0x82


def run(capture):
    g,o=reach_after_pillars(capture);states={};contexts={}
    for _ in range(133):
        t=g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction')==1 and t in PHASES:
            states[t]=g.save_state();contexts[t]=dict(mario=snapshot(g,o),box=actor(g))
        if len(states)==len(PHASES):break
        advance(g)
    assert set(states)==set(PHASES)
    prepared130={};prepared_ledgers={}
    def supplied_pose(xyz,ledger):
        for path,value in [('gMarioState.pos',xyz),('gMarioObject.header.gfx.pos',xyz)]+[('gMarioObject.oPos'+ax,v) for ax,v in zip('XYZ',xyz)]:
            ledger.append(dict(path=path,before=g.read(path),after=value));g.write(path,value)
    for context in ['far-prefix','near-spectator']:
        g.load_state(states[129]);prep=[]
        if context=='near-spectator':supplied_pose([-2559,1280,-1535],prep)
        prep.append(dict(path='gMarioState.action',before=g.read('gMarioState.action'),after=CRAWLING,storedTimer=129))
        g.write('gMarioState.action',CRAWLING);advance(g,dict(buttons=0x2000,stick=[0,64]))
        assert g.read('gMarioState.action')==CRAWLING and g.read('gMarioObject.hitboxHeight')==100, (context,g.mario_action_names().get(g.read('gMarioState.action')),g.read('gMarioObject.hitboxHeight'),g.read('gMarioState.pos'))
        prepared130[context]=g.save_state();prepared_ledgers[context]=prep
    trials=[]
    cases=[]
    for phase in PHASES:
        for kind,held in [('dropped',3),('thrown',2)]:
            for y in HEIGHTS:
                offsets=[0] if kind=='dropped' else [-80,-40,0,40,80]
                for offset in offsets:
                    x=-1989 if kind=='dropped' else -1989-40*max(0,129-phase)+offset
                    for context in ['far-prefix','near-spectator']:cases.append((context,phase,kind,held,[x,y,-939]))
    for context in ['far-prefix','near-spectator']:cases.append((context,130,'original-free-control',0,[-1989,1741,-939]))
    for context,phase,kind,held,xyz in cases:
        g.load_state(prepared130[context] if phase==130 else states[phase]);edits=[];spectator=[]
        def write(path,value,ledger):
            ledger.append(dict(path=path,before=g.read(path),after=value));g.write(path,value)
        if context=='near-spectator' and phase<130:supplied_pose([-2559,1280,-1535],spectator)
        for ax,v in zip('XYZ',xyz):write('gObjectPool[49].oPos'+ax,v,edits)
        for field,value in [('oHeldState',held),('oAction',0),('oIntangibleTimer',0 if held==0 else -1),('oMoveAngleYaw',0x4000)]:
            write('gObjectPool[49].'+field,value,edits)
        samples=[];preparation=prepared_ledgers[context] if phase==130 else []
        for _ in range(130-phase):
            t=g.read('gObjectPool[61].oTimer')
            if t==129:
                write('gMarioState.action',CRAWLING,preparation)
                advance(g,dict(buttons=0x2000,stick=[0,64]))
            else:advance(g)
            samples.append(dict(storedTimer=g.read('gObjectPool[61].oTimer'),box=actor(g)))
        at130=actor(g);mario_edits=[]
        # Conditional second cut: do not mislabel this as controller delivery.
        assert g.read('gMarioState.action')==CRAWLING and g.read('gMarioObject.hitboxHeight')==100, (context,g.mario_action_names().get(g.read('gMarioState.action')),g.read('gMarioObject.hitboxHeight'),g.read('gMarioState.pos'))
        write('gMarioState.pos',[-1950,1741,-939],mario_edits)
        for ax,v in zip('XYZ',[-1950,1741,-939]):write('gMarioObject.oPos'+ax,v,mario_edits)
        write('gMarioObject.header.gfx.pos',[-1950,1741,-939],mario_edits)
        before=snapshot(g,o);before_height=g.read('gMarioObject.hitboxHeight');advance(g,dict(buttons=0x2000,stick=[0,64]));after=snapshot(g,o)
        box_after=actor(g);advance(g);next_update=snapshot(g,o)
        split=after['display'][1]-after['movement'][1]
        captured=next_update['action']==0x1300 and next_update['platform']==61 and next_update['floorOwner']==61 and next_update['used']==64
        if captured:assert at130['isJumpingBox'] and at130['activeFlags'] and at130['oIntangibleTimer']==0
        arrival=None;continuation=[]
        if captured:
            for _ in range(27):
                advance(g);r=snapshot(g,o);continuation.append(r)
                if r['area']==2:arrival=r;break
        outside=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
        if kind=='original-free-control':assert captured and outside and split==973
        trials.append(dict(context=context,phase=phase,kind=kind,initialXYZ=xyz,actorEdits=edits,spectatorEdits=spectator,
            actorSamples=samples,actorAt130=at130,marioPreparation=preparation,marioCutEdits=mario_edits,
            marioCollisionHeightBefore130=before_height,
            before=before,after=after,boxAfter130=box_after,nextUpdate=next_update,
            verticalSplit=split,topCapture=captured,arrival=arrival,outsideElevator=outside,
            continuationUpdates=len(continuation)))
    return dict(schema=1,scope=__doc__,baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
        runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
        scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),contexts=contexts,
        phases=PHASES,heights=HEIGHTS,trials=trials,
        summary=dict(trials=len(trials),actorPredecessorUpdates=sum(130-t['phase'] for t in trials),
            aliveAt130=sum(bool(t['actorAt130']['activeFlags']) and t['actorAt130']['isJumpingBox'] for t in trials),
            topCaptures=sum(t['topCapture'] for t in trials),outsideArrivals=sum(t['outsideElevator'] for t in trials)))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    result=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(result,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(result['summary']))
    for t in result['trials']:
        if t['topCapture']:print(json.dumps({k:t[k] for k in ['context','phase','kind','initialXYZ','verticalSplit','outsideElevator']}))
