"""Controller-only jumping-box acquisition, transport and lifetime diagnostics.

The sole non-controller write is create_game's accepted pre-entry level-select
flag. Branches restore complete states reached by the accepted input prefix;
they never write Mario/actor positions, actions, held pointers or RNG.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, Observer, load_capture, set_input

BOUNCE = 0x8AE
TWIRLING = 0x108008A4
CRAWLING = 0x04008448
SEEDS = (2390, 2420, 2460, 2500, 2520, 2548)
WAYPOINTS = ((-5500, 2000), (-5400, 1800), (-5400, 1900),
             (-5300, 1900), (-5500, 2300))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def snap(g, o, n):
    read = g.read
    top = read('gObjectPool[61].behavior') == g.address('bhvPyramidTop')
    mario_present = o.slot(read('gMarioObject')) >= 0
    q = 'gObjectPool[49].'
    r = dict(n=n, timer=read('gGlobalTimer'), level=read('gCurrLevelNum'),
             area=read('gCurrAreaIndex'), pos=read('gMarioState.pos'),
             action=read('gMarioState.action'), arg=read('gMarioState.actionArg'),
             actionState=read('gMarioState.actionState'), actionTimer=read('gMarioState.actionTimer'),
             velocity=read('gMarioState.vel'), forward=read('gMarioState.forwardVel'),
             held=o.slot(read('gMarioState.heldObj')), used=o.slot(read('gMarioState.usedObj')),
             floorY=read('gMarioState.floorHeight'),
             floorOwner=o.slot(read('gMarioState.floor?.object')),
             platform=o.slot(read('gMarioPlatform')),
             collision=[read('gMarioObject.oPos'+a) for a in 'XYZ'] if mario_present else None,
             display=read('gMarioObject.header.gfx.pos') if mario_present else None,
             topBehavior=top, topActive=read('gObjectPool[61].activeFlags'),
             topAction=read('gObjectPool[61].oAction') if top else None,
             topTimer=read('gObjectPool[61].oTimer') if top else None,
             pillars=read('gObjectPool[61].oPyramidTopPillarsTouched') if top else None,
             boxBehavior=read(q+'behavior') == g.address('bhvJumpingBox'),
             box={f: read(q+f) for f in ('oPosX', 'oPosY', 'oPosZ', 'oAction', 'oHeldState',
                  'activeFlags', 'oIntangibleTimer', 'oForwardVel', 'oVelY', 'oMoveFlags')})
    r['flyGuy45'] = dict(behavior=read('gObjectPool[45].behavior') == g.address('bhvFlyGuy'),
                         xyz=[read('gObjectPool[45].oPos'+a) for a in 'XYZ'],
                         height=read('gObjectPool[45].hitboxHeight'),
                         active=read('gObjectPool[45].activeFlags'))
    return r


def advance(g, pad):
    assert not pad['buttons'] & 0x8000
    set_input(g, pad)
    g.advance()
    assert not g.read('gMarioState.input') & 0x82


def accepted_prefix(g, o, rows, count):
    for row in rows[:count]:
        if 'positions' in row:
            seen = o.snapshot()
            assert seen['timer'] == row['timer'] + 1
            assert all(seen[k] == v for k, v in row.items()
                       if k not in ('poll', 'timer', 'buttons', 'stick'))
        advance(g, row)


def steer(g, target, buttons):
    x, _, z = g.read('gMarioState.pos')
    yaw = g.read('gMarioState.area.camera.yaw')
    a = math.atan2(target[0]-x, target[1]-z) - yaw*math.tau/65536
    return dict(buttons=buttons, stick=[round(127*math.sin(a)), round(-127*math.cos(a))])


def summarize(t):
    samples = t['samples']
    pickup = next((r for r in samples if r['held'] == 49), None)
    alive = [r for r in samples if r['boxBehavior'] and r['box']['activeFlags']]
    released = next((r for r in alive if pickup is not None and r['n'] > pickup['n']
                     and r['held'] != 49 and r['box']['oHeldState'] == 0
                     and r['box']['oIntangibleTimer'] == 0), None)
    deleted = next((r for r in samples if pickup is not None and r['n'] > pickup['n']
                    and (not r['boxBehavior'] or not r['box']['activeFlags'])), None)
    near = [r for r in samples if math.hypot(r['pos'][0]+2048, r['pos'][2]+1024) < 1400]
    phase = next((r for r in samples if r['topBehavior'] and r['topAction'] == 1
                  and r['topTimer'] == 130), None)
    return dict(policy=t['policy'], updates=len(t['inputs']),
                inputSha256=hashlib.sha256(json.dumps(t['inputs'], separators=(',', ':')).encode()).hexdigest(),
                pickup=pickup, bounceStarts=[next((r for r in samples if r['held']==49 and
                    r['action']==BOUNCE and r['arg']==a), None) for a in range(3)],
                freeRelease=released, firstDeletion=deleted,
                firstFour=next((r for r in samples if r['topBehavior'] and r['pillars']==4), None),
                phase130=phase, maxNearPyramid=max(near, key=lambda r:r['pos'][1], default=None),
                crawlSamples=sum(r['action']==CRAWLING for r in samples),
                handsFreeSamples=sum(r['held']==49 and r['action'] not in
                    (0x383, 0x385, 0x8AE, 0x0188088A, 0x08000207) for r in samples),
                final=samples[-1])


def run(capture):
    rows = load_capture(capture)
    g = create_game(); o = Observer(g); seeds = {}; baseline = []
    for i, row in enumerate(rows):
        accepted_prefix(g, o, [row], 1)
        if i+1 in SEEDS:
            seeds[i+1] = g.save_state()
        if i+1 >= 350 and g.read('gCurrAreaIndex') == 1 and g.read('gCurrLevelNum') == 8:
            baseline.append(snap(g, o, i+1))
    assert len(seeds) == len(SEEDS)
    trials = []
    # Family 1 is a short fourth-pillar approach control. Family 2 goes back
    # before activation and approaches the box from selected south/west points.
    policies = [dict(family='after-fourth', seed=2548, dive=d, near=near, target=target)
                for d in (None, 0, 8, 16, 24) for near in (80, 120, 180, 240)
                for target in ((-2200,-900), (-2550,-650), (-2000,-1300))]
    policies += [dict(family='before-fourth', seed=seed, waypoint=wp, destination=dest)
                 for seed in SEEDS[:-1] for wp in WAYPOINTS for dest in ('roof', 'fourth')]
    for policy in policies:
        g.load_state(seeds[policy['seed']]); samples = []; inputs = []; got = False; wp_done = False
        horizon = 230 if policy['family'] == 'after-fourth' else 430
        for n in range(horizon):
            r = snap(g, o, n); samples.append(r)
            if r['area'] != 1 or r['level'] != 8 or g.read('gMarioState.area.camera').is_null():
                break
            x, _, z = r['pos']; distance = math.hypot(x+5200, z-1700)
            got |= r['held'] == 49
            if policy['family'] == 'after-fourth':
                target = policy['target'] if got else (-5200, 1700)
                press = n == policy['dive'] or (not got and distance < policy['near'] and n % 10 == 0)
            else:
                wp = policy['waypoint']
                wp_done |= math.hypot(x-wp[0], z-wp[1]) < 60
                target = (-5200, 1700) if wp_done else wp
                if got:
                    target = (-5888,768) if policy['destination']=='fourth' and r['pillars']==3 else (-2048,-1024)
                press = wp_done and not got and distance < 200 and n % 10 == 0
            pad = steer(g, target, 0x4000 if press else 0)
            inputs.append(pad); advance(g, pad)
        samples.append(snap(g, o, len(inputs)))
        trials.append(dict(policy=policy, inputs=inputs, samples=samples))
    selected = []
    for seed, wp in ((2500, (-5500,2300)), (2390, (-5500,2000))):
        t = next(t for t in trials if t['policy'].get('seed')==seed and
                 t['policy'].get('waypoint')==wp and t['policy'].get('destination')=='roof')
        fresh = create_game(); fo = Observer(fresh); accepted_prefix(fresh, fo, rows, seed)
        checkpoints = []
        for n, pad in enumerate(t['inputs']):
            assert snap(fresh, fo, n) == t['samples'][n]
            advance(fresh, pad)
            if seed==2500 and n+1==280:
                button_state = fresh.save_state()
        assert snap(fresh, fo, len(t['inputs'])) == t['samples'][-1]
        s = summarize(t)
        for key in ('pickup', 'freeRelease', 'firstDeletion', 'maxNearPyramid'):
            if s[key] is not None:
                k=s[key]['n']; checkpoints.extend(t['samples'][max(0,k-1):k+2])
        selected.append(dict(policy=t['policy'], inputs=t['inputs'], summary=s,
                             freshReplayMatchingSnapshots=len(t['samples']),
                             milestoneCheckpoints=checkpoints))
        if seed==2500:
            button_trials = []
            for mask in (0, 0x2000, 0x4000, 0x6000):
                fresh.load_state(button_state)
                for n in range(280,303):
                    pad = dict(t['inputs'][n]); pad['buttons'] = mask
                    advance(fresh, pad)
                end = snap(fresh, fo, 303)
                assert end == t['samples'][303]
                button_trials.append(dict(buttonMask=mask, updates=23, endpoint=end,
                    matchesZeroButtonMarioAndActors=True))
    decomp = Path('../../../reference-sm64-decomp')
    source_paths = ['src/game/behaviors/jumping_box.inc.c', 'src/game/mario_actions_airborne.c',
                    'src/game/mario_actions_moving.c', 'src/game/mario_actions_stationary.c',
                    'src/game/interaction.c', 'levels/ssl/areas/1/macro.inc.c']
    return dict(schema=1, scope='Finite controller-only box transport branches; no clean Ink handoff',
                gameplaySetupWrites=[], preEntrySetup='create_game writes gDebugLevelSelect=1 before level entry',
                baselineSha256=sha(capture), runtimeSha256=sha(Path('build/wafel-pilot/sm64_jp.dll')),
                scriptSha256=sha(Path(__file__)), sourceSha256={p:sha(decomp/p) for p in source_paths},
                acceptedInputRows=len(rows), acceptedAFrames=sum(bool(r['buttons']&0x8000) for r in rows),
                baseline=baseline, trials=trials, selected=selected, heldBounceButtonControls=button_trials,
                stoppingRule='Completed 60 after-fourth and 50 before-fourth policies; all selected trails independently replayed; no exhaustive claim')


def compact(raw, raw_path):
    summaries = [summarize(t) for t in raw['trials']]
    baseline = raw['baseline']
    changes = []
    previous = None
    for r in baseline:
        key = (r['held'], r['action'] if r['held']==49 else None,
               r['arg'] if r['held']==49 else None, r['topBehavior'], r['topAction'],
               r['boxBehavior'], bool(r['box']['activeFlags']) if r['boxBehavior'] else None)
        if key != previous or r['n'] in (2548,2679,2700,2776,2777):
            changes.append(r)
        previous = key
    return {**{k:v for k,v in raw.items() if k not in ('baseline','trials')},
            'rawPath':str(raw_path).replace('\\','/'), 'rawSha256':sha(raw_path),
            'baselineMilestones':changes,
            'screens':[dict(family=family, trials=sum(t['policy']['family']==family for t in summaries),
                updates=sum(t['updates'] for t in summaries if t['policy']['family']==family),
                pickupTrials=sum(t['pickup'] is not None for t in summaries if t['policy']['family']==family),
                freeReleaseTrials=sum(t['freeRelease'] is not None for t in summaries if t['policy']['family']==family),
                phase130Trials=sum(t['phase130'] is not None for t in summaries if t['policy']['family']==family),
                crawlSamples=sum(t['crawlSamples'] for t in summaries if t['policy']['family']==family),
                handsFreeSamples=sum(t['handsFreeSamples'] for t in summaries if t['policy']['family']==family))
                for family in ('after-fourth','before-fourth')],
            'trialSummaries':[{**{k:s[k] for k in ('policy','updates','inputSha256','crawlSamples','handsFreeSamples')},
                **{k:(None if s[k] is None else dict(n=s[k]['n'], timer=s[k]['timer'],
                    pos=s[k]['pos'], action=s[k]['action'], held=s[k]['held'],
                    pillars=s[k]['pillars'], topAction=s[k]['topAction'], topTimer=s[k]['topTimer'],
                    boxBehavior=s[k]['boxBehavior'], box=s[k]['box']))
                   for k in ('pickup','freeRelease','firstDeletion','firstFour','phase130','maxNearPyramid')}}
                  for s in summaries]}


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path); p.add_argument('output', type=Path)
    p.add_argument('--receipt', type=Path, required=True); a=p.parse_args()
    raw=run(a.capture)
    with a.output.open('x', encoding='utf-8') as f:
        json.dump(raw, f, indent=2, allow_nan=False); f.write('\n')
    receipt=compact(raw,a.output)
    with a.receipt.open('x', encoding='utf-8') as f:
        json.dump(receipt, f, indent=2, allow_nan=False); f.write('\n')
    print(json.dumps(dict(screens=receipt['screens'], selected=[dict(policy=t['policy'],
        replaySnapshots=t['freshReplayMatchingSnapshots'],
        freeRelease=t['summary']['freeRelease'], peak=t['summary']['maxNearPyramid']) for t in raw['selected']]),indent=2))
