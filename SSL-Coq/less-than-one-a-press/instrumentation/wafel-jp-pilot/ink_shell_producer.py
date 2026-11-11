"""Bounded no-A shell-component investigation, with every setup edit exposed.

The approach screen starts from a controller-reached state. Other trials
explicitly supply Mario's approach or a shell release/position; they do not
establish a clean producer for the 973-unit Ink handoff.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import create_game, load_capture, Observer, set_input
from ink_floorless_warp import reach_after_pillars, NEUTRAL, observe


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def advance(g, controller=NEUTRAL):
    assert not controller['buttons'] & 0x8000
    set_input(g, controller)
    g.advance()
    assert not g.read('gMarioState.input') & 0x82


def write(g, path, value, edits):
    edits.append(dict(path=path, before=g.read(path), after=value))
    g.write(path, value)


def mario_setup(g, pos, action, edits, forward=0, velocity=(0, 0, 0), yaw=0):
    write(g, 'gMarioState.pos', list(pos), edits)
    for axis, value in zip('XYZ', pos):
        write(g, 'gMarioObject.oPos' + axis, value, edits)
    write(g, 'gMarioObject.header.gfx.pos', list(pos), edits)
    for field, value in [('action', action), ('actionState', 0), ('actionTimer', 0),
                         ('forwardVel', forward), ('vel', list(velocity)),
                         ('faceAngle', [0, yaw, 0])]:
        write(g, 'gMarioState.' + field, value, edits)


def shells(g):
    return [i for i in range(240) if g.read('gObjectPool[%d].activeFlags' % i)
            and g.read('gObjectPool[%d].behavior' % i) == g.address('bhvKoopaShell')]


def actor(g, slot):
    p = 'gObjectPool[%d].' % slot
    return dict(slot=slot, isShell=g.read(p + 'behavior') == g.address('bhvKoopaShell'),
                active=g.read(p + 'activeFlags'), action=g.read(p + 'oAction'),
                position=[g.read(p + 'oPos' + a) for a in 'XYZ'],
                velocity=[g.read(p + 'oVel' + a) for a in 'XYZ'],
                forward=g.read(p + 'oForwardVel'), floorY=g.read(p + 'oFloorHeight'),
                interact=g.read(p + 'oInteractStatus'))


def sample(g, observer, slot=None):
    row = observe(g, observer)
    row.update(topTimer=g.read('gObjectPool[61].oTimer'),
               topAction=g.read('gObjectPool[61].oAction'),
               ridden=observer.slot(g.read('gMarioState.riddenObj')),
               shell=None if slot is None else actor(g, slot))
    return row


def steer(g, target):
    x, _, z = g.read('gMarioState.pos')
    dx, dz = target[0] - x, target[1] - z
    yaw = g.read('gMarioState.area.camera.yaw') * (2 * math.pi / 65536)
    angle = math.atan2(dx, dz) - yaw
    magnitude = min(127, 2 * math.hypot(dx, dz))
    return [max(-128, min(127, round(math.sin(angle) * magnitude))),
            max(-128, min(127, round(-math.cos(angle) * magnitude)))]


def clean_approach_screen(capture):
    rows = load_capture(capture)
    g = create_game()
    observer = Observer(g)
    for row in rows[:650]:
        assert not row['buttons'] & 0x8000
        if 'positions' in row:
            seen = observer.snapshot()
            assert seen['timer'] == row['timer'] + 1
            assert all(seen[k] == v for k, v in row.items()
                       if k not in ('poll', 'timer', 'buttons', 'stick'))
        advance(g, row)
    initial = sample(g, observer)
    state = g.save_state()
    ways = [[], [[6400, 4200]], [[6400, 3200]], [[6200, 1900]],
            [[5600, 1800]], [[5200, 2500]], [[5800, 4200]], [[6800, 1000]]]
    results = []
    for via in ways:
        g.load_state(state)
        path = via + [[5840, 2500]]
        waypoint, last_b = 0, -100
        inputs, snapshots = [], []
        for frame in range(600):
            p = g.read('gMarioState.pos')
            target = path[waypoint]
            if waypoint < len(path)-1 and math.hypot(p[0]-target[0], p[2]-target[1]) < 100:
                waypoint += 1
                target = path[waypoint]
            near = math.hypot(p[0]-5840, p[2]-2500) < 200
            buttons = 0x4000 if near and frame-last_b >= 20 else 0
            if buttons:
                last_b = frame
            controller = dict(buttons=buttons, stick=steer(g, target))
            inputs.append(controller)
            advance(g, controller)
            if frame % 100 == 0:
                snapshots.append(sample(g, observer))
            if g.read('gObjectPool[32].oAction') >= 3:
                break
        results.append(dict(via=via, inputs=inputs, samples=snapshots,
                            final=sample(g, observer),
                            boxAction=g.read('gObjectPool[32].oAction'),
                            activeShells=shells(g)))
        assert results[-1]['boxAction'] == 2 and not results[-1]['activeShells']
    return dict(prefixPolls=650, initial=initial, nonControllerEdits=[],
                testedUpdates=sum(len(r['inputs']) for r in results), trials=results)


def run(capture):
    g, observer = reach_after_pillars(capture)
    after_pillars = g.save_state()
    prefix_edits = []
    while g.read('gObjectPool[61].oTimer') != 128:
        advance(g)
    assert g.read('gObjectPool[32].oBhvParams2ndByte') == 3
    write(g, 'gObjectPool[32].oAction', 4, prefix_edits)
    advance(g)
    advance(g)
    assert g.read('gObjectPool[61].oTimer') == 130
    slot, = shells(g)
    state = g.save_state()
    ablations = []
    for mode in ['old-zero-velocities', 'retain-native-velocities', 'xz-only']:
        g.load_state(state)
        edits = []
        mario_setup(g, (-1950, 1741, -939), 0x04008448, edits, 5, (4, 0, 0), 0x4000)
        for axis, value in zip('XYZ', (-1971, 1741, -939)):
            if mode != 'xz-only' or axis != 'Y':
                write(g, 'gObjectPool[%d].oPos%s' % (slot, axis), value, edits)
        if mode == 'old-zero-velocities':
            for field in ['oForwardVel', 'oVelX', 'oVelY', 'oVelZ']:
                write(g, 'gObjectPool[%d].%s' % (slot, field), 0, edits)
        before = sample(g, observer, slot)
        advance(g, dict(buttons=0x2000, stick=[0, 64]))
        after = sample(g, observer, slot)
        continuation = []
        for _ in range(28):
            advance(g)
            continuation.append(sample(g, observer, slot))
            if g.read('gCurrAreaIndex') == 2:
                break
        capture_top = continuation[0]['floorOwner'] == 61 and continuation[0]['platform'] == 61
        assert capture_top == (mode != 'xz-only')
        if capture_top:
            assert after['movement'] == [-1882.0, 768.0, -939.0]
            assert after['display'] == [-1882.0, 1741.0, -939.0]
            assert continuation[-1]['area'] == 2
        ablations.append(dict(mode=mode, edits=edits, before=before, after=after,
                              capturesTop=capture_top, continuation=continuation))

    coasts = []
    for mode in ['native-release-position', 'supplied-high-position']:
        g.load_state(state)
        edits = []
        if mode == 'supplied-high-position':
            for axis, value in zip('XYZ', (-1971, 1741, -939)):
                write(g, 'gObjectPool[%d].oPos%s' % (slot, axis), value, edits)
        initial = actor(g, slot)
        trail = []
        for _ in range(120):
            advance(g)
            trail.append(actor(g, slot))
        coasts.append(dict(mode=mode, edits=edits, initial=initial, samples=trail,
                           maximumY=max(x['position'][1] for x in [initial]+trail),
                           maximumHorizontalDisplacement=max(math.hypot(
                               x['position'][0]-initial['position'][0],
                               x['position'][2]-initial['position'][2]) for x in trail)))

    # Real no-A ground pound releases the shell, but the elevated Mario
    # approach is supplied. No box/actor field is changed in this component.
    g.load_state(after_pillars)
    release_edits = []
    mario_setup(g, (5840, 1250, 2500), 0x0100088c, release_edits)
    release_samples = []
    release_frame = None
    release_slot = None
    for frame in range(100):
        advance(g, dict(buttons=0x2000 if frame == 0 else 0, stick=[0, 0]))
        active = shells(g)
        if active and release_frame is None:
            release_frame, release_slot = frame + 1, active[0]
        row = sample(g, observer, release_slot)
        row['boxAction'] = g.read('gObjectPool[32].oAction')
        release_samples.append(row)
    assert release_frame == 31

    # Mount through the actual interaction, then issue Z only after it lands.
    g.load_state(state)
    for _ in range(35):
        advance(g)
    settled = actor(g, slot)
    mount_edits = []
    p = settled['position']
    mario_setup(g, (p[0]+20, p[1], p[2]), 0x04000440, mount_edits)
    mount_samples = []
    dismounted = False
    for frame in range(12):
        button = 0
        if g.read('gMarioState.action') == 0x20810446 and not dismounted:
            button, dismounted = 0x2000, True
        advance(g, dict(buttons=button, stick=[0, 0]))
        row = sample(g, observer, slot)
        row['buttons'] = button
        mount_samples.append(row)
    assert any(r['ridden'] == slot for r in mount_samples)
    assert dismounted
    assert not mount_samples[-1]['shell']['active'] or not mount_samples[-1]['shell']['isShell']

    return dict(schema=1, runtime='Pinned Wafel 0.8.5 JP',
                runtimeSha256=digest(Path('build/wafel-pilot/sm64_jp.dll')),
                baselineSha256=digest(capture), noA=True,
                scope='Finite component investigation; no clean 973-unit producer',
                fixturePrefixEdits=prefix_edits, ablations=ablations, coasts=coasts,
                suppliedApproachRelease=dict(edits=release_edits,
                    shellReleasedAfterUpdates=release_frame, shellSlot=release_slot,
                    samples=release_samples),
                mountThenZ=dict(edits=mount_edits, samples=mount_samples),
                cleanApproachScreen=clean_approach_screen(capture))


def compact(result, raw):
    r = dict(result)
    r['scriptSha256'] = digest(Path(__file__))
    r['rawReportSha256'] = digest(raw)
    r['ablations'] = [{**{k: v for k, v in x.items() if k != 'continuation'},
                       'nextUpdate': x['continuation'][0],
                       'lastUpdate': x['continuation'][-1],
                       'continuationUpdates': len(x['continuation'])} for x in result['ablations']]
    r['coasts'] = [{**{k: v for k, v in x.items() if k != 'samples'},
                   'sampledUpdates': len(x['samples']),
                   'selectedSamples': [x['samples'][i] for i in [0, 1, 3, 7, 15, 31, 63, 119]]}
                  for x in result['coasts']]
    release = result['suppliedApproachRelease']
    r['suppliedApproachRelease'] = {**{k: v for k, v in release.items() if k != 'samples'},
        'selectedSamples': [release['samples'][i] for i in [0, 20, 21, 29, 30, 31, 40, 60, 99]],
        'maximumShellY': max(x['shell']['position'][1] for x in release['samples'] if x['shell'])}
    screen = result['cleanApproachScreen']
    r['cleanApproachScreen'] = {**{k: v for k, v in screen.items() if k != 'trials'},
        'trials': [{**{k: v for k, v in x.items() if k != 'inputs'},
                    'inputCount': len(x['inputs']),
                    'inputSha256': hashlib.sha256(json.dumps(x['inputs'], sort_keys=True).encode()).hexdigest()}
                   for x in screen['trials']]}
    return r


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--receipt', type=Path)
    args = parser.parse_args()
    result = run(args.capture)
    with args.output.open('x', encoding='utf8') as stream:
        json.dump(result, stream, indent=2, allow_nan=False)
        stream.write('\n')
    if args.receipt:
        with args.receipt.open('x', encoding='utf8') as stream:
            json.dump(compact(result, args.output), stream, indent=2, allow_nan=False)
            stream.write('\n')
    print(json.dumps(dict(ablations=[(x['mode'], x['capturesTop']) for x in result['ablations']],
        coasts=[(x['mode'], x['maximumY'], x['maximumHorizontalDisplacement']) for x in result['coasts']],
        suppliedApproachReleaseUpdates=result['suppliedApproachRelease']['shellReleasedAfterUpdates'],
        cleanApproachUpdates=result['cleanApproachScreen']['testedUpdates']), indent=2))


if __name__ == '__main__':
    main()
