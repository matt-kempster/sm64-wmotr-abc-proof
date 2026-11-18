"""Replace only the last pusher in the low, carried-Bob shell handoff.

Replay the established shell preparation and held-Bob cut. Supply a carry
of the initialized stock small crate before update 126 and let Mario drop it.
All test continuations are controller-only after the prior Bob approach cut.
"""
import argparse
import gzip
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
OLD = HERE.parent / 'ink-shell-carried-bob-mount'
spec = importlib.util.spec_from_file_location('low_carried_bob', OLD / 'check.py')
c = importlib.util.module_from_spec(spec)
spec.loader.exec_module(c)
CRATE = 23
USEFUL = [365.5927734375, 5500, -1096.8026123046875]
ORDINARY = [0, 5500, 256]
BASE = c.b.BOX


def replay_grants(game, observer, commands):
    edits = []
    for command in commands:
        value = command['after']
        if isinstance(value, str):
            value = game.address(value)
        c.cb.write(game, observer, command['path'], value, edits)
    return edits


def sample(game, observer):
    state = c.snap(game, observer)
    state['actors'][str(CRATE)] = c.iso.actor_snapshot(game, CRATE)
    state['smallReleased'] = game.read('gObjectPool[23].oBreakableBoxSmallReleased')
    state['smallSinceRelease'] = game.read('gObjectPool[23].oBreakableBoxSmallFramesSinceReleased')
    return state


def trial(game, observer, start, reference, placement, stop=45):
    game.load_state(start)
    assert game.read('gObjectPool[23].behavior') == game.address('bhvBreakableBoxSmall')
    assert game.read('gObjectPool[23].hitboxRadius') == 60
    initial = []
    height = placement[1] if placement else 1920
    action = 'ACT_HOLD_FREEFALL' if placement else 'ACT_FREEFALL'
    c.cb.mario_cut(game, observer, [5900, height, 3440], action, initial)
    if placement:
        c.cb.write(game, observer, 'gMarioState.heldObj', game.address('gObjectPool[23]'), initial)
        c.cb.write(game, observer, 'gObjectPool[23].oHeldState', game.constant('HELD_HELD'), initial)
        c.cb.write(game, observer, 'gMarioState.marioBodyState.heldObjLastPosition', placement, initial)
    rows = []
    events = []
    pads = []
    cuts = []
    for i in range(stop):
        phase = game.read('gObjectPool[61].oTimer')
        if i == 2:
            assert phase == 128
            edits = replay_grants(game, observer, reference['cuts'][0]['edits'])
            cuts.append(dict(phase=phase, edits=edits))
        pad = c.iso.Z if i in (0, 2) else c.iso.NEUTRAL
        c.iso.advance(game, pad)
        pads.append(pad)
        rows.append(sample(game, observer))
        events.append(c.iso.frame_events(game))
        if rows[-1]['area'] != 1:
            break
    capture = next((i for i, row in enumerate(rows) if row['used'] == 64
                    and row['floorOwner'] == row['platform'] == 61), None)
    retained = (all(row['platform'] == 61 for row in rows[capture:] if row['area'] == 1)
                if capture is not None else None)
    arrival = next((row['M'] for row in rows if row['area'] == 2), None)
    return dict(placement=placement, initialEdits=initial, cuts=cuts, samples=rows,
                controls=pads, events=events, captureStep=capture, retained=retained,
                arrival=arrival, useful=arrival == USEFUL)


def describe(result):
    r = result['samples']
    return dict(drop=result['placement'], crateAt130=r[3]['actors']['23']['position'],
                contacts129=r[3]['collisions'], contacts130=r[4]['collisions'],
                M129=r[3]['M'], M130=r[4]['M'], G130=r[4]['G'], floor130=r[4]['floorY'],
                capture=result['captureStep'], arrival=result['arrival'])


def export(result, reference, name):
    value = {key: reference[key] for key in ['seedPhase', 'shellPreparationHOLP', 'shellTarget']}
    value.update(name=name, initialEdits=result['initialEdits'], cuts=result['cuts'],
                 controls=result['controls'], expected=result['samples'],
                 expectedRichSamples=result['samples'], sourceArtifact='instrumentation/ink-low-small-box-final/results.json.gz',
                 provenance=dict(scope=__doc__, crateSlot=23, drop126=result['placement'],
                                 nativeShellThrow=True, suppliedShellPickupRetarget=True,
                                 suppliedHOLP=True, suppliedBobCarry128=True, subsequentGameplayEdits=[]))
    return value


def placement_menu(ref):
    # Native Crazy Box drop position, then smaller radii and offsets about Mario's
    # observed position after the first shove. Use float32 coordinates in-game.
    mx, _, mz = ref['expected'][3]['M']
    placements = [[BASE[0], 1920, BASE[2]], None]
    offsets = [(1,-0.5),(3,-1),(6,-3),(10,-5),(15,-7),(22,-10),(30,-14),
               (1,0),(5,0),(10,0),(5,-5),(10,-10),(0,-5),(0,5),(-5,0)]
    placements.extend([[mx+dx, 1920, mz+dz] for dx,dz in offsets])
    for distance in [0.7, 1, 2, 3, 5, 7, 10, 15, 20]:
        for ratio in [0.35, 0.45, 0.55]:
            placements.append([mx + 5.93701171875 + distance, 1920,
                               mz + 7.3560791015625 - distance * ratio])
    return placements


def persist(path, value, verify):
    if verify:
        data = path.read_bytes()
        if path.suffix == '.gz':
            data = gzip.decompress(data)
        assert json.loads(data) == value, path
    else:
        raw = (json.dumps(value, separators=(',', ':')) + '\n').encode()
        if path.suffix == '.gz':
            raw = gzip.compress(raw, mtime=0)
        path.write_bytes(raw)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--verify', action='store_true')
    args = parser.parse_args()
    game, observer, state, _, prep = c.root()
    ref = json.loads((OLD / 'positive.json').read_bytes())
    selected = {21: 'positive', 0: 'control', 1: 'no-crate', 17: 'top-floor'}
    placements = placement_menu(ref)
    rows = []
    detailed = {}
    for i, placement in enumerate(placements):
        result = trial(game, observer, state, ref, placement)
        rows.append(describe(result))
        if i in selected:
            name = selected[i]
            detailed[name] = result
            if name in ['positive', 'control']:
                persist(HERE / (name + '.json'), export(result, ref, name), args.verify)
    assert [i for i,row in enumerate(rows) if row['arrival'] == USEFUL] == [18, 21]
    assert all(row['M129'] == ref['expected'][3]['M'] and row['contacts129'] == [71,39] for row in rows)
    positive = detailed['positive']
    assert positive['captureStep'] == 5 and positive['retained'] and positive['useful']
    assert detailed['control']['arrival'] == detailed['no-crate']['arrival'] == ORDINARY
    assert detailed['top-floor']['samples'][4]['floorY'] != 768
    assert all(t['captureStep'] is None for key,t in detailed.items() if key != 'positive')
    assert positive['samples'][0]['smallReleased'] == 1 and positive['samples'][0]['held'] == -1
    assert positive['samples'][0]['actors']['23']['oHeldState'] == 0
    assert positive['samples'][2]['actionName'] == 'ACT_BUTT_SLIDE'
    assert positive['samples'][4]['collisions'] == [23,39]
    assert positive['samples'][4]['floorY'] == 768
    # Save state restores test branches; independently rebuild the shell release,
    # stock crate and Bob-donor state and compare all tested results.
    again, obs2, state2, _, prep2 = c.root()
    assert prep == prep2
    for i, placement in enumerate(placements):
        repeat = trial(again, obs2, state2, ref, placement)
        assert describe(repeat) == rows[i]
        if i in selected:
            assert repeat == detailed[selected[i]]
    out = dict(schema=1, preparation=prep, startingProofRevision='01c1109e31216f854fe30bfa70866e62bcc00614',
               runtimeSha256=c.iso.sha(c.ROOT / 'build/wafel-pilot/sm64_jp.dll'),
               jpSourceRevision='9921382a68bb0c865e5e45eb594d9c64db59b1af', noNewA=True,
               independentPreparations=2, scope=__doc__, placements=rows, detailed=detailed)
    persist(HERE / 'results.json.gz', out, args.verify)
    print('PASS', len(rows), 'drop/control cases from two independent roots; useful indices 18, 21')


if __name__ == '__main__':
    main()
