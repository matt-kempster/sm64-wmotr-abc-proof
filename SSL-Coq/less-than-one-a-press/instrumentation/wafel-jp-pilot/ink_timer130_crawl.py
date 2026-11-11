"""Bounded, explicitly supplied-state timer-130 crawling/shell diagnostic.

This is not a controller-produced Ink route.  The authenticated replay
prefix supplies the level and top phase.  The writes logged below supply
the shell's release/placement and Mario's high crawling state.  No cached
floor, surface, platform, collision list, RNG or allocator pointer is set.
"""
import argparse
import hashlib
import json
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import NEUTRAL, observe, reach_after_pillars, set_input


CRAWLING = 0x04008448
PAD = (-1950, 1741, -939)
TARGET = (-1882, 1741, -939)
SHELL = (-1971, 1741, -939)


def f32(x):
    return struct.unpack('<f', struct.pack('<f', x))[0]


def snapshot(g, observer):
    row = observe(g, observer)
    row.update(topTimer=g.read('gObjectPool[61].oTimer'),
               topAction=g.read('gObjectPool[61].oAction'),
               topActive=g.read('gObjectPool[61].activeFlags'),
               velocity=g.read('gMarioState.vel'),
               forwardVelocity=g.read('gMarioState.forwardVel'),
               faceAngle=g.read('gMarioState.faceAngle'),
               input=g.read('gMarioState.input'),
               ceilingY=g.read('gMarioState.ceilHeight'),
               floorVertices=[g.read('gMarioState.floor?.vertex%d' % i)
                              for i in (1, 2, 3)])
    return row


def frame_events(g):
    # Omit process-local code addresses; they are not observations of a
    # program branch.  The stock Wafel log has no floor/ceiling return hook.
    return [{k: v for k, v in event.items() if k != 'reason'}
            for event in g.frame_log()]


def run(capture):
    g, observer = reach_after_pillars(capture)
    prefix_writes = []

    def write(path, value, ledger):
        ledger.append(dict(path=path, before=g.read(path), after=value))
        g.write(path, value)

    def advance(controller=NEUTRAL):
        assert not controller['buttons'] & 0x8000
        set_input(g, controller)
        g.advance()
        assert not g.read('gMarioState.input') & 0x82

    for _ in range(180):
        if (g.read('gObjectPool[61].oAction') == 1
                and g.read('gObjectPool[61].oTimer') == 128):
            break
        advance()
    else:
        raise RuntimeError('Top phase 128 not reached')
    shell_box = 'gObjectPool[32]'
    assert g.read(shell_box + '.behavior') == g.address('bhvExclamationBox')
    assert g.read(shell_box + '.oBhvParams2ndByte') == 3
    before_release = snapshot(g, observer)
    # Release the contents through the real box behavior.  This supplied
    # action changes subsequent allocation history; it is not a box break
    # reached with controller input.
    write(shell_box + '.oAction', 4, prefix_writes)
    advance()
    advance()
    assert g.read('gObjectPool[61].oTimer') == 130
    shells = [i for i in range(240)
              if g.read('gObjectPool[%d].activeFlags' % i)
              and g.read('gObjectPool[%d].behavior' % i) == g.address('bhvKoopaShell')]
    assert len(shells) == 1, shells
    shell = shells[0]
    shell_path = 'gObjectPool[%d].' % shell
    state = g.save_state()
    trials = []
    cases = [('shell-' + name, PAD, True, stick)
             for name, stick in [('up', [0, 64]), ('right', [64, 0]),
                                 ('left', [-64, 0]), ('down', [0, -64])]]
    cases += [('no-nearby-shell', PAD, False, [0, 64]),
              ('direct-high-target', TARGET, False, [0, 64])]
    for name, pose, move_shell, stick in cases:
        g.load_state(state)
        edits = []
        write('gMarioState.pos', list(pose), edits)
        for axis, value in zip('XYZ', pose):
            write('gMarioObject.oPos' + axis, value, edits)
        write('gMarioObject.header.gfx.pos', list(pose), edits)
        for field, value in [('action', CRAWLING), ('actionState', 0),
                             ('actionTimer', 0), ('forwardVel', 5),
                             ('vel', [4, 0, 0]), ('faceAngle', [0, 0x4000, 0])]:
            write('gMarioState.' + field, value, edits)
        if move_shell:
            for axis, value in zip('XYZ', SHELL):
                write(shell_path + 'oPos' + axis, value, edits)
            for field in ('oForwardVel', 'oVelX', 'oVelY', 'oVelZ'):
                write(shell_path + field, 0, edits)
        before = snapshot(g, observer)
        controller = dict(buttons=0x2000, stick=stick)
        advance(controller)
        after = snapshot(g, observer)
        events = frame_events(g)
        action_events = [e for e in events if e['type'] == 'FLT_EXECUTE_ACTION']
        steps = [e for e in events if e['type'] == 'FLT_BEGIN_MOVEMENT_STEP']
        intended = None
        if action_events:
            # This is a calculation from observed fields, not a query hook.
            pos = action_events[0]['pos']
            vel = after['velocity']
            intended = [f32(pos[0] + f32(vel[0] / 4)), pos[1],
                        f32(pos[2] + f32(vel[2] / 4))]
        continuation = []
        for _ in range(28):
            advance()
            continuation.append(snapshot(g, observer))
            if g.read('gCurrAreaIndex') == 2:
                break
        handoff = (after['movement'] == [-1882.0, 768.0, -939.0]
                   and after['collision'] == after['movement']
                   and after['display'] == list(TARGET)
                   and after['floorY'] == 768 and after['action'] == CRAWLING)
        capture_row = continuation[0]
        capture_top = (capture_row['action'] == 0x1300 and capture_row['used'] == 64
                       and capture_row['floorOwner'] == 61 and capture_row['platform'] == 61)
        arrival = next((r for r in continuation if r['area'] == 2), None)
        outside = None if arrival is None else not (
            -460 <= arrival['movement'][0] <= 461 and -204 <= arrival['movement'][2] <= 717)
        if move_shell:
            assert before['floorY'] == 1024  # inherited, never overwritten
            assert handoff and capture_top and outside
            assert len(steps) == 1 and steps[0]['stepType'] == 2
            assert action_events[0]['pos'] == list(TARGET)
        else:
            assert not handoff and not capture_top
        trials.append(dict(name=name, edits=edits, controller=controller,
                           before=before, after=after, events=events,
                           calculatedFirstQuarterIntended=intended,
                           calculatedQueryIntegers=None if intended is None else list(map(int, intended)),
                           handoff=handoff, nextUpdateTopCapture=capture_top,
                           continuation=continuation, arrivalOutsideElevator=outside))
    return dict(schema=1, runtime='Pinned Wafel 0.8.5 JP DLL (hash checked by create_game)',
                runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
                baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                scope='Supplied high crawl and supplied real-shell release/placement; no clean producer',
                observationLimit='Frame log plus after-update samples; no new floor/ceiling or first-apply call hook',
                beforeRelease=before_release, prefixEdits=prefix_writes,
                shellSlot=shell, trials=trials)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--receipt', type=Path)
    args = parser.parse_args()
    result = run(args.capture)
    with args.output.open('x', encoding='utf-8') as stream:
        json.dump(result, stream, indent=2, allow_nan=False)
        stream.write('\n')
    if args.receipt:
        receipt = compact_receipt(result, args.output)
        with args.receipt.open('x', encoding='utf-8') as stream:
            json.dump(receipt, stream, indent=2, allow_nan=False)
            stream.write('\n')
    print(json.dumps({r['name']: dict(handoff=r['handoff'],
                                     nextUpdateTopCapture=r['nextUpdateTopCapture'],
                                     arrivalOutsideElevator=r['arrivalOutsideElevator'])
                      for r in result['trials']}, indent=2))


def compact_receipt(result, raw_path):
    receipt = {k: v for k, v in result.items() if k != 'trials'}
    receipt['scriptSha256'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    receipt['rawReportSha256'] = hashlib.sha256(raw_path.read_bytes()).hexdigest()
    receipt['trials'] = []
    for trial in result['trials']:
        row = {k: v for k, v in trial.items() if k != 'continuation'}
        continuation = trial['continuation']
        retired = next((r for r in continuation if r['topActive'] == 0), None)
        row.update(nextUpdate=continuation[0],
                   firstInactiveTopSample=retired,
                   firstArea2Sample=next((r for r in continuation if r['area'] == 2), None),
                   continuationUpdates=len(continuation))
        receipt['trials'].append(row)
    return receipt


if __name__ == '__main__':
    main()
