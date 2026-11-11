"""Place Mario outside SSL collision bounds and observe the next warp."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from replay import Observer, create_game, load_capture, set_input


OUTSIDE = (9000, 768, -1024)
PORTAL = (-2048, 768, -1024)
LOW = (-2200, 768, -1024)
TOP = (-2200, 1938.8648681640625, -1024)
NEUTRAL = dict(buttons=0, stick=[0, 0])
UPPER_WARP_SLOT = 64
DISAPPEARED = 0x1300
OBJECT_WARP = 4
DEATH_WARP = 18


def position(g, movement, collision, display):
    g.write('gMarioState.pos', list(movement))
    for axis, value in zip('XYZ', collision):
        g.write('gMarioObject.oPos' + axis, value)
    g.write('gMarioObject.header.gfx.pos', list(display))


def observe(g, observer):
    read = g.read
    obj = observer.slot(read('gMarioObject'))
    floor = read('gMarioState.floor')
    return dict(
        timer=read('gGlobalTimer'), level=read('gCurrLevelNum'),
        area=read('gCurrAreaIndex'), debugLevelSelect=read('gDebugLevelSelect'),
        playMode=read('sCurrPlayMode'), specialDestination=read('D_80339EE0'),
        warpOp=read('sDelayedWarpOp'), countdown=read('sDelayedWarpTimer'),
        sourceNode=read('sSourceWarpNodeId'), warpDestination=read('sWarpDest'),
        lives=read('gMarioState.numLives'), action=read('gMarioState.action'),
        actionArg=read('gMarioState.actionArg'), used=observer.slot(read('gMarioState.usedObj')),
        floor=not floor.is_null(), floorY=read('gMarioState.floorHeight'),
        floorOwner=observer.slot(read('gMarioState.floor?.object')),
        platform=observer.slot(read('gMarioPlatform')), marioObject=obj,
        movement=read('gMarioState.pos'),
        collision=None if obj < 0 else [read('gMarioObject.oPos'+axis) for axis in 'XYZ'],
        display=None if obj < 0 else read('gMarioObject.header.gfx.pos'),
    )


def scenarios():
    yield 'outside', (OUTSIDE, OUTSIDE, OUTSIDE), None
    yield 'outside-normal-death', (OUTSIDE, OUTSIDE, OUTSIDE), None
    yield 'outside-then-portal', (OUTSIDE, OUTSIDE, OUTSIDE), 'death-queued'
    yield 'accepted-then-outside', (PORTAL, PORTAL, PORTAL), 'contact-accepted'
    yield 'queued-then-outside', (PORTAL, PORTAL, PORTAL), 'portal-queued'
    yield 'contact-two-misses', (OUTSIDE, PORTAL, OUTSIDE), None
    yield 'contact-static-retry', (OUTSIDE, PORTAL, PORTAL), None
    yield 'contact-top-retry', (OUTSIDE, LOW, TOP), None
    yield 'ink-control', (LOW, LOW, TOP), None
    yield 'ink-queued-then-outside', (LOW, LOW, TOP), 'portal-queued'


def event_reached(condition, row):
    if condition == 'contact-accepted':
        return (row['used'] == UPPER_WARP_SLOT and row['action'] == DISAPPEARED
                and row['actionArg'] == 0x40001 and row['warpOp'] == 0)
    if condition == 'portal-queued':
        return row['warpOp'] == OBJECT_WARP and row['sourceNode'] == 0x1e
    return row['warpOp'] == DEATH_WARP


def reach_after_pillars(capture):
    rows = load_capture(capture)
    g = create_game()
    observer = Observer(g)
    for row in rows[:2548]:
        assert not row['buttons'] & 0x8000
        if 'positions' in row:
            seen = observer.snapshot()
            assert seen['timer'] == row['timer'] + 1
            assert all(seen[k] == v for k, v in row.items()
                       if k not in ('poll', 'timer', 'buttons', 'stick'))
        set_input(g, row)
        g.advance()
    assert g.read('gObjectPool[61].oPyramidTopPillarsTouched') == 4
    return g, observer


def run(capture):
    g, observer = reach_after_pillars(capture)
    for _ in range(180):
        if g.read('gObjectPool[61].oAction') == 1 and g.read('gObjectPool[61].oTimer') == 131:
            break
        set_input(g, NEUTRAL)
        g.advance()
    else:
        raise RuntimeError('The top did not reach timer 131')
    start = observe(g, observer)
    assert (start['level'], start['area'], start['platform'], start['warpOp']) == (8, 1, -1, 0)
    assert start['action'] == 0x0c400201 and start['lives'] > 0
    assert observer.slot(g.read('gMarioState.heldObj')) == -1
    save = g.save_state()
    trials = {}
    for name, initial, second in scenarios():
        g.load_state(save)
        assert observe(g, observer) == start
        if name == 'outside-normal-death':
            g.write('gDebugLevelSelect', 0)
        position(g, *initial)
        edits = [observe(g, observer)]
        samples = []
        for _ in range(90):
            set_input(g, NEUTRAL)
            g.advance()
            row = observe(g, observer)
            assert not g.read('gMarioState.input') & 0x82
            samples.append(row)
            if second and len(edits) == 1 and event_reached(second, row):
                next_pos = PORTAL if second == 'death-queued' else OUTSIDE
                position(g, next_pos, next_pos, next_pos)
                edits.append(observe(g, observer))
        if second:
            assert len(edits) == 2, (name, second)
        trials[name] = dict(edits=edits, samples=samples)
    return dict(start=start, trials=trials)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    with args.output.open('x', encoding='utf-8') as f:
        json.dump(run(args.capture), f, indent=2, allow_nan=False)
        f.write('\n')


if __name__ == '__main__':
    main()
