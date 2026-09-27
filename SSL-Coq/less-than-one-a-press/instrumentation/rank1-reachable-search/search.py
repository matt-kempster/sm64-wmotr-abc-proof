"""Finite JP controller search from the checked four-pillar replay.

Only the pilot's controller adapter and accepted pre-entry level select write
game state. Checkpoints are reached by replay, never supplied poses or RNG.
After-update metrics shortlist replays; they do not certify transient events.
"""
import argparse
import hashlib
import json
import math
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / 'instrumentation/wafel-jp-pilot'))
from replay import create_game, load_capture, Observer, set_input, bits


def xyz(words):
    return [struct.unpack('>f', struct.pack('>I', v))[0] for v in words]


def write_json(path, value):
    path.write_text(json.dumps(value, indent=2) + '\n', encoding='utf-8')


def sample(g, observer):
    s = observer.snapshot()
    s['level'] = g.read('gCurrLevelNum')
    if 'positions' in s:
        s.update(depth=bits(g.read('gMarioState.quicksandDepth')),
                 speed=g.read('gMarioState.forwardVel'),
                 actionArg=g.read('gMarioState.actionArg'),
                 objectPlatform=observer.slot(g.read('gMarioObject.platform')),
                 usedObject=observer.slot(g.read('gMarioState.usedObj')),
                 topBehaviorMatches=g.read('gObjectPool[61].behavior') == g.address('bhvPyramidTop'),
                 topY=g.read('gObjectPool[61].oPosY'),
                 rng=g.read('gRandomSeed16'))
    return s


def steer(g, target, strength=127):
    x, _, z = g.read('gMarioState.pos')
    dx, dz = target[0] - x, target[1] - z
    yaw = g.read('gMarioState.area.camera.yaw') * (2 * math.pi / 65536)
    angle = math.atan2(dx, dz) - yaw
    magnitude = min(strength, 2 * math.hypot(dx, dz))
    return [max(-128, min(127, round(math.sin(angle) * magnitude))),
            max(-128, min(127, round(-math.cos(angle) * magnitude)))]


def configurations(batch):
    if batch == 'box':
        for first in (2540, 2549):
            for label, alignment in [('direct', None), ('original', [-5580, 2030]),
                                     ('short', [-5500, 1900]), ('east', [-5350, 1900]),
                                     ('west', [-5500, 1750])]:
                for strength in (60, 90, 127):
                    for pickup in (100, 135):
                        yield dict(id='%d-box-%s-%d-%d' % (first, label, strength, pickup),
                                   firstPoll=first, policy='box', alignment=alignment,
                                   strength=strength, pickup=pickup, horizon=420)
        return
    # Four distinct path proposals; no claim these exhaust controller choices.
    paths = [('direct', []), ('south', [[-4000, 1000]]),
             ('west-face', [[-3500, -1024]]), ('north', [[-4000, -2400]])]
    buttons = [('none', -1, 0), ('b0', 0, 0x4000), ('b8', 8, 0x4000),
               ('b16', 16, 0x4000), ('b32', 32, 0x4000), ('z16', 16, 0x2000)]
    for first in (2549, 2555, 2561):
        for path, via in paths:
            for name, offset, value in buttons:
                yield dict(id='%d-%s-%s' % (first, path, name), firstPoll=first,
                           waypoints=via + [[-2200, -1024]], buttonAt=offset,
                           button=value, horizon=240)


def choose_input(g, before, config, state, i):
    pos = xyz(before['positions'])
    if config.get('policy') == 'box':
        action = before['action']
        box = 'gObjectPool[49]'
        if g.read('gMarioState.heldObj') == g.address(box) or action == 0x8ae:
            state['phase'] = 2
        if before['pillars'] < 4 and before['topBehaviorMatches']:
            return steer(g, [-5883, 764]), 0
        if state['phase'] == 0 and config['alignment'] is not None:
            target = config['alignment']
            if math.hypot(pos[0]-target[0], pos[2]-target[1]) < 80:
                state['phase'] = 1
        else:
            state['phase'] = max(1, state['phase'])
        buttons = 0
        if state['phase'] < 2:
            assert g.read(box+'.behavior') == g.address('bhvJumpingBox')
            target = config['alignment'] if state['phase'] == 0 else [g.read(box+'.oPosX'), g.read(box+'.oPosZ')]
            distance = math.hypot(pos[0]-g.read(box+'.oPosX'), pos[2]-g.read(box+'.oPosZ'))
            if state['phase'] == 1 and distance < config['pickup'] and i-state['lastB'] >= 20:
                buttons = 0x4000
        else:
            target = [-2048, -1024]
            distance = math.hypot(pos[0]-target[0], pos[2]-target[1])
            rollout = (action == 0x008c0453 and before['actionTimer'] == 5 and distance < 1600
                       or action == 0x00880456 and distance < 1200)
            speed_kick = action == 0x04000440 and before['speed'] >= 29 and 300 < distance < 1600
            if rollout and i-state['lastB'] >= 5 or speed_kick and i-state['lastB'] >= 20:
                buttons = 0x4000
        if buttons:
            state['lastB'] = i
        return steer(g, target, config['strength'] if state['phase'] == 0 else 127), buttons
    waypoint = state['waypoint']
    target = config['waypoints'][waypoint]
    if waypoint + 1 < len(config['waypoints']) and math.hypot(pos[0]-target[0], pos[2]-target[1]) < 180:
        state['waypoint'] += 1
        target = config['waypoints'][state['waypoint']]
    return steer(g, target), config['button'] if i == config['buttonAt'] else 0


def summarize(config, samples, input_hash):
    valid = [s for s in samples if 'positions' in s and s['level'] == 8]
    positions = [(s, xyz(s['positions'])) for s in valid]
    near = [(s, v) for s, v in positions if math.hypot(v[0]+2200, v[2]+1024) < 250]
    live = [(s, v) for s, v in positions if s['topBehaviorMatches'] and s['topActive'] != 0]
    distance = lambda pair: math.hypot(pair[1][0]+2200, pair[1][2]+1024)
    nearest = min(positions, key=distance) if positions else None
    nearest_live = min(live, key=distance) if live else None
    return dict(config=config, inputSha256=input_hash, updates=len(samples),
        area1Samples=len(valid), reachedOtherArea=any(s['area'] != 1 for s in samples),
        floorNullSamples=sum(s['floorNull'] for s in valid),
        anyPositionSplit=sum(s['positions'][:3] != s['positions'][3:6]
                             or s['positions'][:3] != s['positions'][6:] for s in valid),
        maxDisplayMinusStateY=max((v[7]-v[1] for _, v in positions), default=None),
        maxDisplayMinusCollisionY=max((v[7]-v[4] for _, v in positions), default=None),
        minDisplayMinusStateY=min((v[7]-v[1] for _, v in positions), default=None),
        minDepth=min((xyz([s['depth']])[0] for s in valid), default=None),
        originalTopPlatformSamples=sum(s['platform'] == 61 and s['topBehaviorMatches'] for s in valid),
        # A disappearing action after update is only a flag for exact observation.
        disappearedSamples=sum(s['action'] == 0x1300 for s in valid),
        nearTargetSamples=len(near),
        nearest=None if nearest is None else dict(distance=distance(nearest), sample=nearest[0]),
        nearestWhileTopActive=None if nearest_live is None else
            dict(distance=distance(nearest_live), sample=nearest_live[0]),
        actions=sorted({s['action'] for s in valid}), final=samples[-1])


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path)
    p.add_argument('--output', type=Path, required=True)
    p.add_argument('--batch', choices=['approach', 'box'], default='approach')
    args = p.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    rows = load_capture(args.capture)
    assert [r['poll'] for r in rows] == list(range(1, len(rows)+1))
    assert all(not r['buttons'] & 0x8000 for r in rows)
    configs = list(configurations(args.batch))
    manifest = dict(captureSha256=hashlib.sha256(args.capture.read_bytes()).hexdigest(),
                    scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                    configurations=configs, inputScope='A never held; narrower than all no-new-A histories',
                    observation='After-update Wafel samples, not exact warp acceptance',
                    pruning='None; no merging of gameplay states or controller histories')
    manifest_file = args.output / 'manifest.json'
    if manifest_file.exists():
        assert json.loads(manifest_file.read_text()) == manifest, 'Use a new output directory after changing the search.'
    else:
        write_json(manifest_file, manifest)
    g = create_game()
    observer = Observer(g)
    reached = {}
    required = {c['firstPoll'] for c in configs}
    checked = 0
    for row in rows[:max(required)]:
        seen = observer.snapshot()
        if 'positions' in row:
            assert seen['timer'] == row['timer'] + 1
            assert all(seen.get(k) == v for k, v in row.items()
                       if k not in ('poll', 'timer', 'buttons', 'stick'))
            checked += 1
        if row['poll'] in required:
            assert g.read('gObjectPool[61].behavior') == g.address('bhvPyramidTop')
            reached[row['poll']] = (g.save_state(), sample(g, observer))
        set_input(g, row)
        g.advance()
    reports = []
    for config in configs:
        destination = args.output / config['id']
        report_file = destination.with_suffix('.json')
        if report_file.exists():
            result = json.loads(report_file.read_text())
            assert result['config'] == config
            assert hashlib.sha256(destination.with_suffix('.inputs').read_bytes()).hexdigest() == result['inputSha256']
            reports.append(result)
            continue
        saved, initial = reached[config['firstPoll']]
        g.load_state(saved)
        assert sample(g, observer) == initial
        commands, samples = [], []
        policy_state = dict(waypoint=0, phase=0, lastB=-1000)
        for i in range(config['horizon']):
            before = sample(g, observer)
            stick, buttons = [0, 0], 0
            if 'positions' in before and before['level'] == 8:
                stick, buttons = choose_input(g, before, config, policy_state, i)
            command = dict(poll=config['firstPoll']+i, buttons=buttons, stick=stick)
            assert not buttons & 0x8000
            commands.append(command)
            set_input(g, command)
            g.advance()
            seen = sample(g, observer)
            seen['afterPoll'] = command['poll']
            samples.append(seen)
        # Final poll observes the last output in the emulator input observer.
        all_inputs = rows[:config['firstPoll']-1] + commands + [dict(
            poll=config['firstPoll']+config['horizon'], buttons=0, stick=[0, 0])]
        text = ''.join('%d %d %d %d\n' % (r['poll'], r['buttons'], *r['stick']) for r in all_inputs)
        destination.with_suffix('.inputs').write_bytes(text.encode('ascii'))
        write_json(destination.with_suffix('.samples.json'), samples)
        result = summarize(config, samples, hashlib.sha256(text.encode('ascii')).hexdigest())
        result['initial'] = initial
        write_json(report_file, result)
        reports.append(result)
    write_json(args.output / 'results.json', dict(manifest=manifest, baselineSnapshotsChecked=checked,
        trials=len(reports), updates=sum(r['updates'] for r in reports), results=reports,
        verdict='Finite search only; replay selected inputs with the exact emulator observer.'))
    print(json.dumps(dict(trials=len(reports), updates=sum(r['updates'] for r in reports),
        splitTrials=sum(bool(r['anyPositionSplit']) for r in reports),
        nullFloorTrials=sum(bool(r['floorNullSamples']) for r in reports),
        topPlatformTrials=sum(bool(r['originalTopPlatformSamples']) for r in reports),
        nearest=[dict(id=r['config']['id'], distance=r['nearest']['distance'],
                      topLiveDistance=r['nearestWhileTopActive']['distance'] if r['nearestWhileTopActive'] else None)
                 for r in sorted(reports, key=lambda r:r['nearest']['distance'])[:8]]), indent=2))


if __name__ == '__main__':
    main()
