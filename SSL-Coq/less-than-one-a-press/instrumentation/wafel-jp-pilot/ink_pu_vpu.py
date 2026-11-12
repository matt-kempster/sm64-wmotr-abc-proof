"""Bounded supplied-state PU/VPU handoff diagnostics, not route witnesses.

No mid-trial gameplay writes. Reuse the authenticated four-pillar prefix;
retain native actor behavior, floor cache, surface loader, RNG and allocator.
All initial edits and every controller input are retained in the receipt.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, NEUTRAL, set_input
from ink_timer130_crawl import snapshot, frame_events, CRAWLING
from ink_crawl_predecessors import pose, write


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def advance(g, control):
    assert not control['buttons'] & 0x8000
    set_input(g, control)
    g.advance()
    assert not g.read('gMarioState.input') & 0x82


def sample(g, observer):
    r = snapshot(g, observer)
    r['topSurfaceCount'] = sum(
        g.read('sSurfacePool[%d].object' % i) == g.address('gObjectPool[61]')
        for i in range(g.read('gNumStaticSurfaces'), g.read('gSurfacesAllocated')))
    r['topDistanceCache'] = g.read('gObjectPool[61].oDistanceToMario')
    r['topCollisionDistance'] = g.read('gObjectPool[61].oCollisionDistance')
    r['topPosition'] = [g.read('gObjectPool[61].oPos' + a) for a in 'XYZ']
    r['ceilingPresent'] = not g.read('gMarioState.ceil').is_null()
    r['ceilingOwner'] = observer.slot(g.read('gMarioState.ceil?.object'))
    r['collisionSlots'] = [observer.slot(g.read('gMarioObject.collidedObjs[%d]' % i))
                           for i in range(g.read('gMarioObject.numCollidedObjs'))]
    r['actor'] = {k: g.read('gObjectPool[49].' + k) for k in (
        'oPosX', 'oPosY', 'oPosZ', 'oAction', 'oHeldState', 'oForwardVel',
        'oVelX', 'oVelY', 'oVelZ', 'oMoveFlags', 'oFloorHeight', 'oIntangibleTimer',
        'activeFlags', 'hitboxRadius', 'hitboxHeight', 'hitboxDownOffset')}
    return r


def recipes():
    # x/z shifts alias in floor queries but do not relocate the warp.
    for name, delta in [('ordinary', (0, 0, 0)), ('vpu', (0, 65536, 0)),
                        ('pu-x', (65536, 0, 0)), ('pu-z', (0, 0, 65536)),
                        ('pu-vpu', (65536, 65536, 0))]:
        for actor in [True, False]:
            yield dict(name=name + ('-box' if actor else '-no-box'), delta=delta,
                       actor=actor, action=CRAWLING, seed=[-1950, 1741, -939])
    for name, action in [('start-crawl', 0x0c008223), ('crouching', 0x0c008220),
                         ('freefall', 0x0100088c)]:
        for actor in [True, False]:
            yield dict(name='vpu-' + name + ('-box' if actor else '-no-box'),
                       delta=(0, 65536, 0), actor=actor,
                       action=action, seed=[-1950, 1741, -939])
    yield dict(name='vpu-direct-target', delta=(0, 65536, 0), actor=False,
               action=CRAWLING, seed=[-1882, 1741, -939])
    for velocity in [-262144, -1000, 1000, 262144]:
        yield dict(name='vpu-speed-' + str(velocity), delta=(0, 65536, 0),
                   actor=False, action=CRAWLING, seed=[-1950, 1741, -939],
                   velocity=velocity)


def run(capture):
    g, observer = reach_after_pillars(capture)
    for _ in range(180):
        if g.read('gObjectPool[61].oAction') == 1 and g.read('gObjectPool[61].oTimer') == 130:
            break
        advance(g, NEUTRAL)
    else:
        raise AssertionError('phase 130 not reached')
    assert g.read('gObjectPool[49].behavior') == g.address('bhvJumpingBox')
    state = g.save_state()
    trials = []
    for recipe in recipes():
        g.load_state(state)
        edits = []
        xyz = [a+b for a, b in zip(recipe['seed'], recipe['delta'])]
        pose(g, xyz, edits)
        for field, value in [('action', recipe['action']), ('actionState', 0),
                             ('actionTimer', 0), ('forwardVel', recipe.get('velocity', 5)),
                             ('vel', [4, 0, 0]),
                             ('faceAngle', [0, 0x4000, 0])]:
            write(g, 'gMarioState.' + field, value, edits)
        if recipe['actor']:
            for a, v, d in zip('XYZ', [-1989, 1741, -939], recipe['delta']):
                write(g, 'gObjectPool[49].oPos' + a, v+d, edits)
        initial = sample(g, observer)
        rows, controls, events = [], [], []
        for i in range(32):
            control = dict(buttons=0x2000, stick=[0, 64]) if i == 0 else NEUTRAL
            advance(g, control)
            controls.append(control)
            rows.append(sample(g, observer))
            events.append(frame_events(g))
            if rows[-1]['area'] != 1:
                break
        arrival = next((r for r in rows if r['area'] == 2), None)
        useful = arrival is not None and not (-460 <= arrival['movement'][0] <= 461
                                              and -204 <= arrival['movement'][2] <= 717)
        trials.append(dict(recipe=recipe, edits=edits, initial=initial, controls=controls,
                           samples=rows, events=events, usefulArrival=useful,
                           topCapture=any(r['floorOwner'] == 61 and r['platform'] == 61
                                          and r['used'] == 64 for r in rows)))
    return dict(schema=1, scope='Supplied synchronized poses/actions and optional actor XYZ; not reachability',
                observationLimit='Native field and surface-pool samples plus frame log; no local query/quarter-return hook',
                baselineSha256=digest(capture), scriptSha256=digest(__file__),
                runtimeSha256=digest('build/wafel-pilot/sm64_jp.dll'), trials=trials)


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path)
    p.add_argument('output', type=Path)
    a = p.parse_args()
    result = run(a.capture)
    with a.output.open('x', encoding='utf-8') as f:
        json.dump(result, f, indent=2, allow_nan=False)
        f.write('\n')
    print(json.dumps([dict(name=t['recipe']['name'], after=t['samples'][0]['movement'],
                           display=t['samples'][0]['display'], action=t['samples'][0]['action'],
                           topSurfaces=[r['topSurfaceCount'] for r in t['samples'][:2]],
                           capture=t['topCapture'], useful=t['usefulArrival'])
                      for t in result['trials']], indent=2))
