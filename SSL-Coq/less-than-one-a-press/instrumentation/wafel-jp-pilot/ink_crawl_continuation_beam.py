"""Bounded controller-only continuation of a position-only roof seed.

The initial roof seed is supplied, not reached from the accepted start. The
prefix then establishes crawling and top support with controller input. This
search restores complete native states, makes no gameplay edits, and retains
only branches whose final action remains ACT_CRAWLING. Its width pruning and
finite controller menu do not establish an exclusion of other inputs.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_crawl_predecessors import CRAWLING, advance, pose
from ink_floorless_warp import NEUTRAL, reach_after_pillars
from ink_timer130_crawl import snapshot

WIDTH, HORIZON, START_PHASE = 16, 52, 79


def menu(g):
    result = [dict(buttons=0x2000, stick=[0, 0])]
    camera = g.read('gMarioState.area.camera.yaw') * 2 * math.pi / 65536
    for magnitude in (32, 64):
        for yaw in range(0, 65536, 8192):
            angle = yaw * 2 * math.pi / 65536 - camera
            result.append(dict(buttons=0x2000,
                               stick=[round(math.sin(angle) * magnitude),
                                      round(-math.cos(angle) * magnitude)]))
    return result


def reconstruct(capture, witness):
    g, observer = reach_after_pillars(capture)
    while not (g.read('gObjectPool[61].oAction') == 1
               and g.read('gObjectPool[61].oTimer') == witness['summary']['phase']):
        advance(g, NEUTRAL)
    edits = []
    pose(g, witness['summary']['seed'], edits)
    prefix = []
    for control in witness['controls']:
        if g.read('gObjectPool[61].oTimer') == START_PHASE:
            break
        advance(g, control)
        prefix.append(control)
    start = snapshot(g, observer)
    expected = next(c for c in witness['checkpoints'] if c['topTimer'] == START_PHASE)
    assert start == expected
    assert start['action'] == CRAWLING and start['floorOwner'] == 61
    return g, observer, edits, prefix, start


def run(capture, source):
    data = json.loads(source.read_text())
    witness = data['bestRoofWitnesses'][0]
    g, observer, edits, prefix, start = reconstruct(capture, witness)
    names = g.mario_action_names()
    first = dict(state=g.save_state(), controls=[], snapshots=[], peakY=start['movement'][1])
    beam, best, longest = [first], first, first
    rows, rejected, tested, reached = [], Counter(), 0, 0
    for depth in range(1, HORIZON + 1):
        candidates = []
        for parent in beam:
            g.load_state(parent['state'])
            controls = menu(g)
            for control in controls:
                g.load_state(parent['state'])
                advance(g, control)
                tested += 1
                snap = snapshot(g, observer)
                if snap['action'] != CRAWLING:
                    rejected[names.get(snap['action'], hex(snap['action']))] += 1
                    continue
                if snap['area'] != 1 or g.read('gMarioState.area.camera').is_null():
                    rejected['invalid-area-or-camera'] += 1
                    continue
                reached += snap['movement'][1] >= 1741
                candidate = dict(state=g.save_state(),
                                 controls=parent['controls']+[control],
                                 snapshots=parent['snapshots']+[snap],
                                 peakY=max(parent['peakY'], snap['movement'][1]))
                candidates.append(candidate)
                if (candidate['peakY'], len(candidate['controls'])) > (best['peakY'], len(best['controls'])):
                    best = candidate
        # Prefer current top support/height. Within this order, keep one path
        # per coarse position/yaw/speed cell, then fill from remaining paths.
        candidates.sort(key=lambda c: (c['snapshots'][-1]['floorOwner']==61,
                                        c['snapshots'][-1]['movement'][1],
                                        c['snapshots'][-1]['forwardVelocity']), reverse=True)
        beam, overflow, cells = [], [], set()
        for candidate in candidates:
            s = candidate['snapshots'][-1]
            cell = (round(s['movement'][0]/20), round(s['movement'][2]/20),
                    s['faceAngle'][1]//2048, round(s['forwardVelocity']*2))
            if cell not in cells and len(beam) < WIDTH:
                beam.append(candidate); cells.add(cell)
            else:
                overflow.append(candidate)
        beam += overflow[:WIDTH-len(beam)]
        rows.append(dict(depth=depth, storedTopTimer=START_PHASE+depth,
                         testedThisDepth=17 if depth == 1 else rows[-1]['retained']*17,
                         crawlingCandidates=len(candidates), retained=len(beam),
                         topSupportedCandidates=sum(c['snapshots'][-1]['floorOwner']==61 for c in candidates),
                         highestCrawlY=max((c['snapshots'][-1]['movement'][1] for c in candidates),default=None)))
        if not beam:
            break
        longest = max(beam, key=lambda c: (len(c['controls']), c['peakY']))

    trails = []
    for label, candidate in [('highest-crawling-Y', best), ('longest-retained-crawl', longest)]:
        fresh, obs, fresh_edits, fresh_prefix, fresh_start = reconstruct(capture, witness)
        assert fresh_edits == edits and fresh_prefix == prefix and fresh_start == start
        for control, expected in zip(candidate['controls'], candidate['snapshots']):
            advance(fresh, control)
            assert snapshot(fresh, obs) == expected
        trails.append(dict(label=label, controls=prefix+candidate['controls'],
                           branchControls=candidate['controls'], snapshots=candidate['snapshots'],
                           peakY=candidate['peakY'],
                           freshBootValidation=dict(passed=True, initialEdits=fresh_edits,
                                                    continuousUpdates=len(prefix)+len(candidate['controls']),
                                                    comparedBranchCheckpoints=len(candidate['snapshots']),
                                                    intermediateEdits=0)))
    return dict(schema=1, scope=__doc__, initialEdits=edits, initialSeed=witness['summary'],
                sourceReceiptSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
                baselineSha256=data['baselineSha256'], runtimeSha256=data['runtimeSha256'],
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                predecessorScriptSha256=data['scriptSha256'], start=start,
                prefixControls=prefix, menu=dict(buttons='Z', worldYaws=list(range(0,65536,8192)),
                                                stickMagnitudes=[32,64], includesNeutral=True),
                width=WIDTH, horizon=HORIZON, depthResults=rows, rejectedActions=dict(rejected),
                summary=dict(testedContinuations=tested, reachedHighCrawlCandidates=reached,
                             maximumCrawlY=best['peakY'], completedDepths=len(rows),
                             longestRetainedCrawlUpdates=len(longest['controls']),
                             stoppingReason='beam-empty' if not beam else 'horizon'),
                trails=trails)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path); p.add_argument('source',type=Path); p.add_argument('output',type=Path)
    args=p.parse_args(); result=run(args.capture,args.source)
    with args.output.open('x',encoding='utf-8') as f:
        json.dump(result,f,indent=2,allow_nan=False); f.write('\n')
    print(json.dumps(result['summary'],indent=2))


if __name__=='__main__': main()
