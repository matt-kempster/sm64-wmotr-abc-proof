"""Measure staged Ink splits near the stock upper warp in Japanese Wafel."""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import (
    DEATH_WARP, DISAPPEARED, LOW, NEUTRAL, PORTAL, UPPER_WARP_SLOT,
    observe, position, reach_after_pillars, set_input,
)


TOP = 61
HIGH_QUERY_Y = 2300
HEIGHTS = (818, 816, 800, 784, 768, 752, 736, 720, 704, 690, 689, 672, 640, 609)
PHASE_PROBES = (LOW, (-2048, 689, -1024), (-1882, 818, -939),
                (-2208, 818, -1104), (-1936, 818, -1144), (-2152, 818, -872))
FOOTPRINT = (-460, 461, -204, 717)


def initial_update(g, state, low, display):
    g.load_state(state)
    position(g, low, low, display)
    set_input(g, NEUTRAL)
    g.advance()
    assert not g.read('gMarioState.input') & 0x82


def accepted(g, observer):
    return (g.read('gMarioState.action') == DISAPPEARED
            and observer.slot(g.read('gMarioState.usedObj')) == UPPER_WARP_SLOT)


def captured(g, observer):
    return (accepted(g, observer)
            and g.read('gMarioState.actionArg') == 0x40001
            and observer.slot(g.read('gMarioState.floor?.object')) == TOP
            and observer.slot(g.read('gMarioPlatform')) == TOP)


def initial_floorless(g, observer):
    return (accepted(g, observer) and g.read('gMarioState.floor').is_null()
            and g.read('sDelayedWarpOp') == DEATH_WARP)


def finish(g, observer):
    for _ in range(28):
        set_input(g, NEUTRAL)
        g.advance()
        assert not g.read('gMarioState.input') & 0x82
        if g.read('gCurrAreaIndex') == 2 and g.read('gCurrLevelNum') == 8:
            row = observe(g, observer)
            x, _, z = row['movement']
            outside = not (FOOTPRINT[0] <= x <= FOOTPRINT[1] and FOOTPRINT[2] <= z <= FOOTPRINT[3])
            return dict(position=row['movement'], timer=row['timer'], outsideElevator=outside,
                        entryFloorY=row['floorY'])
    return None


def phases(g, observer):
    viable, trials = {}, []
    for _ in range(160):
        if g.read('gObjectPool[61].oAction') == 1:
            timer = g.read('gObjectPool[61].oTimer')
            state = g.save_state()
            if timer < 150:
                for low in PHASE_PROBES:
                    initial_update(g, state, low, low)
                    if not initial_floorless(g, observer):
                        continue
                    initial_update(g, state, low, (low[0], HIGH_QUERY_Y, low[2]))
                    if not captured(g, observer):
                        continue
                    arrival = finish(g, observer)
                    trials.append(dict(topTimer=timer, low=low, arrival=arrival))
                    if arrival and arrival['outsideElevator']:
                        viable[timer] = state
                        break
            g.load_state(state)
        set_input(g, NEUTRAL)
        g.advance()
    return viable, trials


def distance_to_warp(pose):
    return math.hypot(pose[0] - PORTAL[0], pose[2] - PORTAL[2])


def floorless_poses(g, observer, state, points, counts):
    for x, z in sorted(points):
        for y in HEIGHTS:
            low = (x, y, z)
            counts['floorlessChecks'] += 1
            initial_update(g, state, low, low)
            if initial_floorless(g, observer):
                yield low
                break


def raised_floor(g, observer, state, low, x, z, counts):
    initial_update(g, state, low, (x, HIGH_QUERY_Y, z))
    counts['raisedChecks'] += 1
    if not captured(g, observer):
        return None
    floor_y = g.read('gMarioState.floorHeight')
    threshold = math.ceil(floor_y - 78)
    # The retail query rounds floorY - 78 in binary32 before comparison.
    for y in (threshold - 1, threshold, threshold + 1):
        display = (x, y, z)
        counts['thresholdChecks'] += 1
        initial_update(g, state, low, display)
        if captured(g, observer):
            return display, floor_y
    raise RuntimeError(f'No captured floor at the measured threshold: {low}, {x}, {z}, {floor_y}')


def candidate(timer, low, hit):
    display, floor_y = hit
    return dict(topTimer=timer, low=low, display=display, floorY=floor_y,
                verticalGap=display[1] - low[1], gap=math.dist(low, display),
                contactDistance=distance_to_warp(low))


def best_continuation(g, observer, states, candidates, sort_key, counts):
    for row in sorted(candidates, key=sort_key):
        counts['continuations'] += 1
        initial_update(g, states[row['topTimer']], row['low'], row['display'])
        assert captured(g, observer)
        arrival = finish(g, observer)
        if arrival and arrival['outsideElevator']:
            x, y, z = row['display']
            initial_update(g, states[row['topTimer']], row['low'], (x, y-1, z))
            return dict(row, arrival=arrival, oneUnitLowerCaptures=captured(g, observer))
    return None


def disk(radius, step):
    return {(PORTAL[0]+x, PORTAL[2]+z)
            for x in range(-radius+1, radius, step) for z in range(-radius+1, radius, step)
            if x*x + z*z < radius*radius}


def neighbours(pose, radius):
    x, _, z = pose
    return {(i, j) for i in range(x-radius, x+radius+1)
            for j in range(z-radius, z+radius+1)}


def oblique_candidates(g, observer, state, timer, seed, points, lows, counts):
    for x, z in sorted(points):
        hit = raised_floor(g, observer, state, seed, x, z, counts)
        if hit is None:
            continue
        display, _ = hit
        low = min(lows, key=lambda p: ((p[0]-x)**2 + (p[1]-display[1])**2 + (p[2]-z)**2, p))
        initial_update(g, state, low, display)
        counts['obliqueChecks'] += 1
        if captured(g, observer):
            yield candidate(timer, low, hit)


def run(capture):
    g, observer = reach_after_pillars(capture)
    states, phase_trials = phases(g, observer)
    assert 131 in states
    # Keep all observed payoff phases if few. Otherwise test the first
    # viable timing, then every eighth viable timing and the known control.
    timers = sorted(states)
    selected = sorted(set(timers if len(timers) < 12 else timers[::8] + [timers[-1], 131]))
    counts = Counter()
    points = disk(187, 16) | {(low[0], low[2]) for low in PHASE_PROBES}
    points.update(((-2150, -1024), (-2048, -1126), (-1944, -1024)))
    lows = {t: list(floorless_poses(g, observer, states[t], points, counts)) for t in selected}
    vertical = []
    for timer in selected:
        for low in lows[timer]:
            hit = raised_floor(g, observer, states[timer], low, low[0], low[2], counts)
            if hit:
                vertical.append(candidate(timer, low, hit))
    best = best_continuation(g, observer, states, vertical, lambda r: r['gap'], counts)
    assert best
    # Refine the integer X/Z neighbourhood of the smallest passing vertical split.
    timer = best['topTimer']
    fine = {p for p in neighbours(best['low'], 16)
            if distance_to_warp((p[0], 0, p[1])) < 187}
    fine_lows = list(floorless_poses(g, observer, states[timer], fine - points, counts))
    for low in fine_lows:
        hit = raised_floor(g, observer, states[timer], low, low[0], low[2], counts)
        if hit:
            vertical.append(candidate(timer, low, hit))
    best = best_continuation(g, observer, states, vertical, lambda r: r['gap'], counts)
    closest = best_continuation(
        g, observer, states, vertical, lambda r: (r['contactDistance'], r['gap']), counts)
    closest_high = best_continuation(
        g, observer, states, (r for r in vertical if r['low'][1] == 818),
        lambda r: (r['contactDistance'], r['gap']), counts)
    display_points = disk(510, 16)
    raw_lows = lows[timer] + fine_lows
    oblique = list(oblique_candidates(
        g, observer, states[timer], timer, best['low'], display_points, raw_lows, counts))
    oblique_best = best_continuation(g, observer, states, oblique, lambda r: r['gap'], counts)
    if oblique_best:
        raw_fine = {p for p in neighbours(oblique_best['low'], 16)
                    if distance_to_warp((p[0], 0, p[1])) < 187}
        more_lows = list(floorless_poses(g, observer, states[timer], raw_fine - points - fine, counts))
        raw_lows += more_lows
        oblique_fine = neighbours(oblique_best['display'], 16)
        oblique.extend(oblique_candidates(
            g, observer, states[timer], timer, best['low'], oblique_fine, raw_lows, counts))
        oblique_best = best_continuation(g, observer, states, oblique, lambda r: r['gap'], counts)
    return dict(baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                phaseProbes=phase_trials, passingProbeTimers=timers, gridTimers=selected,
                heights=HEIGHTS, counts=counts, coarsePoints=len(points), finePoints=len(fine-points),
                initialCaptureCandidates=len(vertical), smallestVertical=best,
                nearestToWarp=closest, nearestAt818=closest_high,
                obliqueGridPoints=len(display_points), obliqueCaptureCandidates=len(oblique),
                smallestOblique=oblique_best)


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
