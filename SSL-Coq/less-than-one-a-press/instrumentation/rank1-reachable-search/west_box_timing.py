"""Test input-only changes to the west Crazy Box approach and bounce."""
import argparse
import hashlib
import itertools
import math
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from search import (
    Observer, create_game, load_capture, sample, set_input, steer, write_json, xyz,
)


WARP = (-2048, -1024)
BOX = 'gObjectPool[49]'
WARP_SLOT = 64
LAST_PILLAR = (-5883, 764)
ACT_BOUNCE = 0x008AE
ACT_STOMACH_SLIDE = 0x008C0453
ACT_WALKING = 0x04000440


def configurations(box_first):
    if box_first:
        detours = [(-6140, 1420), (-5660, 1440), (-5530, 1540)]
        for first, detour, via, pickup in itertools.product(
                (2441, 2471, 2501), detours, (None, (-5070, 1900)), (100, 135, 175)):
            yield dict(first=first, via=via, speed=127, pickup=pickup,
                       target=WARP, exit_z=False, detour=detour)
        return
    approaches = [None, (-5700, 1300), (-5550, 1680), (-5580, 2030)]
    for first, via, speed, pickup in itertools.product(
            (2549, 2557, 2575, 2600, 2641, 2660), approaches, (85, 127), (100, 135, 175)):
        yield dict(first=first, via=via, speed=speed, pickup=pickup, target=WARP, exit_z=False)
    targets = [WARP, (-2200, -1024), (-2200, -1240), (-2200, -800), (-2390, -1024)]
    for first, target, exit_z in itertools.product(
            (2676, 2682, 2688, 2694, 2700), targets, (False, True)):
        yield dict(first=first, via=None, speed=127, pickup=None, target=target, exit_z=exit_z)


def choose(g, before, config, route, step, box_behavior, box_address):
    x, _, z = xyz(before['positions'][:3])
    act = before['action']
    route['grabbed'] |= act == ACT_BOUNCE or g.read('gMarioState.heldObj') == box_address
    if before['pillars'] < 4 and before['topBehaviorMatches']:
        if route['grabbed'] or 'detour' not in config:
            return steer(g, LAST_PILLAR), 0
        if not route['past_detour']:
            dx, dz = config['detour']
            route['past_detour'] = math.hypot(x - dx, z - dz) < 100
            if not route['past_detour']:
                return steer(g, (dx, dz)), 0
    if config['pickup'] is not None and not route['grabbed']:
        if g.read(BOX + '.behavior') != box_behavior or not g.read(BOX + '.activeFlags'):
            return [0, 0], 0
        via = config['via']
        if via and not route['aligned']:
            route['aligned'] = math.hypot(x - via[0], z - via[1]) < 85
            if not route['aligned']:
                return steer(g, via, config['speed']), 0
        bx, bz = (g.read(BOX + '.oPos' + axis) for axis in 'XZ')
        can_try = math.hypot(x - bx, z - bz) < config['pickup'] and step - route['last_b'] >= 10
        if can_try:
            route['last_b'] = step
        return steer(g, (bx, bz), config['speed']), 0x4000 if can_try else 0
    distance = math.hypot(x - WARP[0], z - WARP[1])
    if act == ACT_STOMACH_SLIDE and before['actionTimer'] >= 5:
        return steer(g, config['target']), 0 if config['exit_z'] else 0x4000
    z_button = config['exit_z'] and act == ACT_WALKING and distance < 900
    return steer(g, config['target']), 0x2000 if z_button else 0


def closest(sample_row, v, distance, poll):
    return dict(poll=poll, timer=sample_row['timer'] - 1,
                topTimer=sample_row['topTimer'], collision=v[3:6], distance=distance)


def run(args):
    args.output.mkdir(parents=True, exist_ok=False)
    rows = load_capture(args.capture)
    assert [r['poll'] for r in rows] == list(range(1, len(rows) + 1))
    assert all(not r['buttons'] & 0x8000 for r in rows)
    configs = list(configurations(args.box_before_fourth))
    horizon = 420 if args.box_before_fourth else 210
    required = {c['first'] for c in configs}
    g = create_game()
    observer = Observer(g)
    states = {}
    checked = 0
    for row in rows[:max(required)]:
        if 'positions' in row:
            seen = observer.snapshot()
            assert seen['timer'] == row['timer'] + 1
            assert all(seen[k] == value for k, value in row.items()
                       if k not in ('poll', 'timer', 'buttons', 'stick'))
            checked += 1
        if row['poll'] in required:
            states[row['poll']] = g.save_state()
        set_input(g, row)
        g.advance()
    box_behavior = g.address('bhvJumpingBox')
    box_address = g.address(BOX)
    results = []
    for number, config in enumerate(configs):
        g.load_state(states[config['first']])
        before = sample(g, observer)
        route = dict(grabbed=False, aligned=False, last_b=-1000, past_detour=False)
        commands = []
        result = dict(config=config, closestLive=None, closestLiveInHeightBand=None,
                      area1=0, live=0, gapSamples=0, maxDisplayMinusCollision=0,
                      maxMovementMinusCollision=0, missingStoredFloor=0, topPlatform=0,
                      negativeDepth=0, contactProxyLive=0, acceptedUpperWarpSamples=0,
                      firstBoxBounce=None, firstBoxBouncePillars=None, firstSpinTimer=None)
        for i in range(horizon):
            stick, buttons = [0, 0], 0
            if 'positions' in before and before['level'] == 8:
                stick, buttons = choose(g, before, config, route, i, box_behavior, box_address)
            command = dict(poll=config['first'] + i, buttons=buttons, stick=stick)
            assert not buttons & 0x8000
            commands.append(command)
            set_input(g, command)
            g.advance()
            before = sample(g, observer)
            if 'positions' not in before or before['level'] != 8:
                continue
            assert not before['input'] & 0x0082
            result['area1'] += 1
            v = xyz(before['positions'])
            result['maxDisplayMinusCollision'] = max(result['maxDisplayMinusCollision'], v[7] - v[4])
            result['maxMovementMinusCollision'] = max(result['maxMovementMinusCollision'], v[1] - v[4])
            result['gapSamples'] += v[:3] != v[3:6] or v[:3] != v[6:]
            result['negativeDepth'] += xyz([before['depth']])[0] < 0
            result['missingStoredFloor'] += before['floorNull']
            result['topPlatform'] += before['platform'] == 61 and before['topBehaviorMatches']
            result['acceptedUpperWarpSamples'] += before['action'] == 0x1300 and before['usedObject'] == WARP_SLOT
            if before['action'] == ACT_BOUNCE and result['firstBoxBounce'] is None:
                result['firstBoxBounce'] = before['timer'] - 1
                result['firstBoxBouncePillars'] = before['pillars']
            if not (before['topActive'] and before['topBehaviorMatches'] and before['topAction'] == 1):
                continue
            result['live'] += 1
            if result['firstSpinTimer'] is None:
                result['firstSpinTimer'] = before['timer'] - 1
            d = math.hypot(v[3] - WARP[0], v[5] - WARP[1])
            height_band = 608 <= v[4] <= 818
            result['contactProxyLive'] += d < 187 and height_band
            for key, eligible in (('closestLive', True), ('closestLiveInHeightBand', height_band)):
                if eligible and (result[key] is None or d < result[key]['distance']):
                    result[key] = closest(before, v, d, command['poll'])
        end = config['first'] + horizon
        schedule = rows[:config['first'] - 1] + commands + [dict(poll=end, buttons=0, stick=[0, 0])]
        contents = ''.join('%d %d %d %d\n' % (r['poll'], r['buttons'], *r['stick']) for r in schedule)
        name = 'branch-%03d.inputs' % number
        (args.output / name).write_bytes(contents.encode('ascii'))
        result.update(inputs=name, inputSha256=hashlib.sha256(contents.encode('ascii')).hexdigest())
        results.append(result)
    write_json(args.output / 'results.json', dict(
        baselineSha256=hashlib.sha256(args.capture.read_bytes()).hexdigest(),
        checkedPrefixSamples=checked, updates=horizon * len(results), branches=results))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--box-before-fourth', action='store_true')
    run(parser.parse_args())


if __name__ == '__main__':
    main()
