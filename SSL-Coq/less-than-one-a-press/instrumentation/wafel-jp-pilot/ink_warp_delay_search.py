"""Test controller delay after supplied Ink capture; isolate timer-edit controls.

The main menu writes only one initial nine-word Mario position setup, then
controller inputs. Counterfactual rows explicitly add one later countdown
write; they are timing diagnostics, never controller-produced candidates.
"""
import argparse
from collections import Counter
import hashlib
import itertools
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_below_cap_phase_search import prepare, digest
from ink_below_cap_capture_lifetime import names, snap
from ink_floorless_warp import position, NEUTRAL
from ink_low_fixture_producers import advance, events
from ink_near_warp import PHASE_PROBES
from replay import RUNTIME

PHASES = [0, 60, 100, 120, 124, 126, 128, 129, 130, 131]
STICKS = [[0,0], [0,127], [127,127], [127,0], [127,-127],
          [0,-127], [-127,-127], [-127,0], [-127,127]]
BUTTON_BITS = [0x4000,0x2000,0x1000,0x800,0x400,0x200,0x100,0x20,0x10,8,4,2,1]
ALL_BUTTONS = sum(BUTTON_BITS)
INPUT_FIELDS = {'gControllerPads[0].button', 'gControllerPads[0].stick_x',
                'gControllerPads[0].stick_y'}


class ControllerOnly:
    def __init__(self, game): self.game = game
    def __getattr__(self, name): return getattr(self.game, name)
    def write(self, path, value):
        assert path in INPUT_FIELDS, ('forbidden suffix write', path)
        self.game.write(path, value)


def tick(g, pad):
    advance(ControllerOnly(g), pad)
    assert not g.read('gPlayer1Controller.buttonDown') & 0x8000
    assert not g.read('gPlayer1Controller.buttonPressed') & 0x8000


def observation(g, o, bnames):
    r = snap(g, o, bnames)
    r.update(playMode=g.read('sCurrPlayMode'),
             transitionTimer=g.read('sTransitionTimer'),
             transitionActive=g.read('gWarpTransition.isActive'),
             sourceNode=g.read('sSourceWarpNodeId'),
             timeStop=g.read('gTimeStopState'),
             buttonsDown=g.read('gPlayer1Controller.buttonDown'),
             buttonsPressed=g.read('gPlayer1Controller.buttonPressed'),
             menuOption=g.read('gMenuOptSelectIndex'))
    return r


def projected(g):
    fields = ['gCurrLevelNum', 'gCurrAreaIndex', 'sCurrPlayMode',
              'sDelayedWarpOp', 'sDelayedWarpTimer', 'sTransitionTimer',
              'gWarpTransition.isActive', 'gMarioState.action',
              'gMarioState.actionArg', 'gObjectPool[61].activeFlags',
              'gObjectPool[61].oAction', 'gObjectPool[61].oTimer']
    return [g.read(f) for f in fields]


def is_capture(r):
    return (r['action'] == 0x1300 and r['actionArg'] == 0x40001 and
            r['used'] == 64 and r['floorOwner'] == 61 and r['platform'] == 61)


def outside(r):
    if r is None: return False
    x, _, z = r['movement']
    return not (-460 <= x <= 461 and -204 <= z <= 717)


def set_pose(g, state, low, high):
    g.load_state(state)
    writes = []
    def put(path, value):
        writes.append(dict(path=path, before=g.read(path), after=value))
        g.write(path, value)
    put('gMarioState.pos', list(low))
    for a, v in zip('XYZ', low): put('gMarioObject.oPos'+a, v)
    put('gMarioObject.header.gfx.pos', list(high))
    return writes


def thresholds(g, o, states, bnames):
    result = []
    for phase, low in itertools.product(PHASES, PHASE_PROBES):
        set_pose(g, states[phase], low, [low[0],2300.,low[2]])
        tick(g, NEUTRAL); high = observation(g,o,bnames)
        assert is_capture(high)
        base = math.ceil(high['floor'] - 78.)
        probes = []
        for y in (base-1,base,base+1):
            set_pose(g,states[phase],low,[low[0],float(y),low[2]])
            tick(g,NEUTRAL); r=observation(g,o,bnames)
            probes.append(dict(height=y,captures=is_capture(r),observed=r))
        passing = [q for q in probes if q['captures']]
        assert passing
        q = passing[0]
        assert any(p['height']==q['height']-1 and not p['captures'] for p in probes)
        result.append(dict(phase=phase,low=list(low),display=[low[0],q['height'],low[2]],
                           verticalGap=q['height']-low[1],floorHeight=high['floor'],
                           thresholdProbes=probes))
    return result


def policies():
    for buttons, stick in itertools.product([0,0x1000,0x4000,0x2000,0x6000,0x7000,0x3f,ALL_BUTTONS],STICKS):
        yield dict(kind='constant',buttons=buttons,stick=stick)
    for when in range(1,24): yield dict(kind='start-pulse',when=when)
    for period in [2,3,4]: yield dict(kind='start-alternating',period=period)
    yield dict(kind='alternating-all')


def pad_for(policy, update):
    kind=policy['kind']
    if kind=='constant': return dict(buttons=policy['buttons'],stick=policy['stick'])
    if kind=='start-pulse': return dict(buttons=0x1000 if update==policy['when'] else 0,stick=[0,0])
    if kind=='start-alternating': return dict(buttons=0x1000 if update%policy['period']==1 else 0,stick=[0,0])
    if kind=='alternating-all': return dict(buttons=ALL_BUTTONS if update%2 else 0,stick=STICKS[update%9])
    raise ValueError(policy)


def run_case(g,o,state,recipe,policy,bnames,extra_delay=0,full=False):
    writes=set_pose(g,state,recipe['low'],recipe['display'])
    initial=observation(g,o,bnames); samples=[]; projection=[]; pads=[]; event_logs=[]; edits=[]
    for update in range(1,49):
        pad=NEUTRAL if update==1 else pad_for(policy,update-1)
        tick(g,pad); r=observation(g,o,bnames)
        samples.append(r);projection.append(projected(g));pads.append(pad);event_logs.append(events(g))
        if extra_delay and update==2:
            assert r['delayedWarp']==4 and r['warpCountdown']==19
            edit=dict(afterUpdate=2,path='sDelayedWarpTimer',before=r['warpCountdown'],after=r['warpCountdown']+extra_delay)
            g.write(edit['path'],edit['after']);edits.append(edit)
        if r['area']!=1 or r['level']!=8: break
    arrival=next((r for r in samples if r['area']==2 and r['level']==8),None)
    result=dict(recipeIndex=recipe['index'],phase=recipe['phase'],low=recipe['low'],display=recipe['display'],
                gap=recipe['verticalGap'],policy=policy,extraDelay=extra_delay,
                captured=is_capture(samples[0]),updates=len(samples),
                pauseUpdates=sum(r['playMode']==2 for r in samples),
                firstQueued=next((i+1 for i,r in enumerate(samples) if r['delayedWarp']!=0),None),
                firstChangeArea=next((i+1 for i,r in enumerate(samples) if r['playMode']==3),None),
                firstInactive=next((i+1 for i,r in enumerate(samples) if not r['topSlot']['active']),None),
                firstArea2Update=next((i+1 for i,r in enumerate(samples) if r['area']==2),None),
                arrival=arrival,outsideElevator=outside(arrival),
                timingDigest=digest(projection),historyDigest=digest([initial,samples,pads,event_logs,edits]),
                suffixGameEdits=len(edits),AInputs=0)
    if full: result.update(initial=initial,writes=writes,samples=samples,pads=pads,events=event_logs,edits=edits,projection=projection)
    return result


def exhaustive(g,o,state,recipe,bnames):
    set_pose(g,state,recipe['low'],recipe['display']); checkpoints=[]
    for update in range(1,14):
        tick(g,NEUTRAL)
        if update in (1,12): checkpoints.append((update,g.save_state(),observation(g,o,bnames)))
    masks=[sum(bit for i,bit in enumerate(BUTTON_BITS) if selection>>i&1) for selection in range(1<<len(BUTTON_BITS))]
    out=[]
    for previous,state0,initial in checkpoints:
        g.load_state(state0);tick(g,NEUTRAL);expected=projected(g)
        counts=Counter(); diffs=[]; sample_digest=hashlib.sha256()
        for buttons,stick in itertools.product(masks,STICKS):
            g.load_state(state0);tick(g,dict(buttons=buttons,stick=stick));q=projected(g)
            counts['trials']+=1;counts['matches']+=q==expected
            if q!=expected:diffs.append(dict(buttons=buttons,stick=stick,projection=q))
            sample_digest.update(json.dumps([buttons,stick,q],separators=(',',':')).encode())
        out.append(dict(afterCaptureUpdate=previous,initial=initial,expected=expected,
                        counts=dict(counts),differences=diffs,enumerationDigest=sample_digest.hexdigest()))
        print(json.dumps(dict(exhaustiveCheckpoint=previous,counts=dict(counts))),flush=True)
    return dict(buttonBits=BUTTON_BITS,buttonMasks=len(masks),sticks=STICKS,checkpoints=out,
                scope='All subsets of 13 recognized non-A buttons, nine sticks, at two fixed reached postcapture checkpoints; not every input history')


def pause_control(g,o,state,bnames):
    g.load_state(state);samples=[];pads=[]
    for update in range(40):
        pad=dict(buttons=0x1000 if update in (0,31) else 0,stick=[0,0])
        tick(g,pad);samples.append(observation(g,o,bnames));pads.append(pad)
    return dict(initialState='Unedited native phase128 context, far from upper warp; no supplied gameplay fields',
                pads=pads,samples=samples,historyDigest=digest([pads,samples]),
                scope='Pause before capture: inspect whether top progresses while ordinary play is paused')


def run(capture):
    g,o,states,geo=prepare(capture);bnames=names(g)
    recipes=thresholds(g,o,states,bnames)
    for i,r in enumerate(recipes):r['index']=i
    menu=list(policies()); rows=[];baseline={}
    for r in recipes:
        for pi,p in enumerate(menu):
            q=run_case(g,o,states[r['phase']],r,p,bnames)
            if pi==0:baseline[r['index']]=q['timingDigest']
            q['timingMatchesNeutral']=q['timingDigest']==baseline[r['index']]
            rows.append(q)
        print(json.dumps(dict(completedRecipes=r['index']+1,phase=r['phase'],trials=len(rows))),flush=True)
    counter=[]
    for r in recipes:
        if r['phase'] in (120,124,126,128,129,130):
            delay=131-r['phase']
            for delta in sorted(set([max(1,delay-1),delay,delay+1])):
                counter.append(run_case(g,o,states[r['phase']],r,menu[0],bnames,extra_delay=delta,full=True))
    exrecipe=next(r for r in recipes if r['phase']==130 and r['low']==list(PHASE_PROBES[2]))
    exhaustive_result=exhaustive(g,o,states[130],exrecipe,bnames)
    pause=pause_control(g,o,states[128],bnames)
    selected=[(r,menu[i]) for r in recipes if r['low']==list(PHASE_PROBES[0]) for i in (0,len(menu)-1)]
    retained=[run_case(g,o,states[r['phase']],r,p,bnames,full=True) for r,p in selected]
    fresh,fo,fs,_=prepare(capture);fn=names(fresh);fresh_checks=[]
    for q in retained:
        r=recipes[q['recipeIndex']];v=run_case(fresh,fo,fs[r['phase']],r,q['policy'],fn,full=True)
        assert v==q
        fresh_checks.append(dict(kind='controller',recipe=r['index'],policy=q['policy'],updates=v['updates'],matched=True))
    for phase in (120,128,129,130):
        q=next(q for q in counter if q['phase']==phase and q['extraDelay']==131-phase)
        r=recipes[q['recipeIndex']];v=run_case(fresh,fo,fs[phase],r,q['policy'],fn,extra_delay=q['extraDelay'],full=True)
        assert v==q
        fresh_checks.append(dict(kind='counterfactual',recipe=r['index'],extraDelay=q['extraDelay'],updates=v['updates'],matched=True))
    summary=dict(recipes=len(recipes),policies=len(menu),trials=len(rows),updates=sum(r['updates'] for r in rows),
                 initialCaptures=sum(r['captured'] for r in rows),pausedTrials=sum(r['pauseUpdates']>0 for r in rows),
                 neutralTimingMatches=sum(r['timingMatchesNeutral'] for r in rows),
                 earlierUseful=sum(r['phase']<131 and r['outsideElevator'] for r in rows),
                 phase131Useful=sum(r['phase']==131 and r['outsideElevator'] for r in rows),
                 counterfactualTrials=len(counter),counterfactualUseful=sum(r['outsideElevator'] for r in counter),
                 counterfactualUpdates=sum(r['updates'] for r in counter),
                 exhaustiveTrials=sum(q['counts']['trials'] for q in exhaustive_result['checkpoints']),
                 exhaustiveMatches=sum(q['counts']['matches'] for q in exhaustive_result['checkpoints']),
                 freshCases=len(fresh_checks),freshUpdates=sum(q['updates'] for q in fresh_checks))
    return dict(schema=1,scope='Controller-only suffixes from supplied smaller-gap Ink captures; separate counterfactual countdown extensions are not gameplay',
                summary=summary,recipes=recipes,policies=menu,rows=rows,retained=retained,
                exhaustive=exhaustive_result,pauseControl=pause,counterfactuals=counter,fresh=fresh_checks,
                observationLimit='After-update observations, not exact first-apply/free/allocation hooks or all-memory equivalence',
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256((RUNTIME/'sm64_jp.dll').read_bytes()).hexdigest(),
                sourceSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path);a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf8') as f:json.dump(r,f,separators=(',',':'));f.write('\n')
    if a.receipt:
        compact={k:v for k,v in r.items() if k!='rows'}
        compact.update(rawSha256=hashlib.sha256(a.output.read_bytes()).hexdigest(),rowsDigest=digest(r['rows']))
        with a.receipt.open('x',encoding='utf8') as f:json.dump(compact,f,indent=2);f.write('\n')
    print(json.dumps(r['summary'],indent=2))


if __name__=='__main__':main()
