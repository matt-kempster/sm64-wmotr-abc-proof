"""Finite no-A pickup/bounce/landing probes from supplied roof positions.

Only synchronized Mario positions and existing jumping-box XYZ are supplied.
Mario action, held/ridden references, box held state, speeds, floor caches,
platform references, RNG and allocator state are not edited. All subsequent
updates use controller input only. This is not a clean approach to the seed.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_crawl_predecessors import advance, pose, steer, write
from ink_floorless_warp import NEUTRAL, reach_after_pillars
from ink_timer130_crawl import snapshot

PHASES = [0, 16, 32, 48, 64, 80, 96]
CRAWLING = 0x04008448
BOUNCE = 0x000008AE
SEED = [-2559, 1280, -1535]
POLICIES = ['center', 'pad', 'roof-corner', 'brake-release']


def snap(g, observer):
    r = snapshot(g, observer)
    r.update(held=observer.slot(g.read('gMarioState.heldObj')),
             ridden=observer.slot(g.read('gMarioState.riddenObj')),
             topBehaviorIsPyramid=g.read('gObjectPool[61].behavior') == g.address('bhvPyramidTop'),
             boxHeldState=g.read('gObjectPool[49].oHeldState'),
             boxActive=g.read('gObjectPool[49].activeFlags'),
             boxBehaviorIsJumping=g.read('gObjectPool[49].behavior') == g.address('bhvJumpingBox'),
             boxPosition=[g.read('gObjectPool[49].oPos'+a) for a in 'XYZ'],
             boxVelocity=[g.read('gObjectPool[49].oVel'+a) for a in 'XYZ'],
             boxInteract=g.read('gObjectPool[49].oInteractStatus'))
    return r


def seed(g, distance):
    edits = []
    pose(g, SEED, edits)
    for axis, value in zip('XYZ', [SEED[0], 1280, SEED[2]+distance]):
        write(g, 'gObjectPool[49].oPos'+axis, value, edits)
    return edits


def run(capture):
    g, observer = reach_after_pillars(capture)
    states, contexts = {}, {}
    for _ in range(115):
        t = g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction') == 1 and t in PHASES:
            states[t] = g.save_state(); contexts[t] = snap(g, observer)
        advance(g, NEUTRAL)
    assert set(states) == set(PHASES)
    handoff_global_timer = contexts[0]['timer'] + 130
    names = g.mario_action_names()
    trials, selected = [], {}
    for phase in PHASES:
        for distance in [70, 95, 110]:
            for btime in [0, 4]:
                for policy in POLICIES:
                    g.load_state(states[phase]); assert snap(g, observer) == contexts[phase]
                    assert g.read('gObjectPool[49].behavior') == g.address('bhvJumpingBox')
                    edits = seed(g, distance)
                    controls, samples, transitions = [], [], []
                    action_counts = Counter()
                    max_y = None; max_before130 = None; max_crawl = None; high_crawl = False
                    pickup = None; release = None; release_event = None; seen_bounce = False
                    last_key = None; phase130 = None
                    for k in range(180):
                        before = snap(g, observer)
                        if before['timer'] == handoff_global_timer:
                            assert before['topBehaviorIsPyramid'] and before['topAction']==1 and before['topTimer']==130
                            phase130 = before
                        if before['action'] == BOUNCE:
                            seen_bounce = True
                        if pickup is None and before['held'] == 49:
                            pickup = k
                        if release is None and seen_bounce and before['held'] != 49:
                            release = k
                        target = ([-2559, -1425] if k < 8 else
                                  [-1950, -939] if policy == 'pad' else
                                  [-2559, -1535] if policy == 'roof-corner' else
                                  [-2047, -1023])
                        pad = steer(g, target, 64)
                        pad['buttons'] = 0x4000 if k == btime else 0
                        if release is not None:
                            pad['buttons'] |= 0x2000
                            if policy == 'brake-release' and k-release < 16:
                                pad['stick'] = [0, 0]
                        controls.append(pad); advance(g, pad)
                        r = snap(g, observer); samples.append(r)
                        if release_event is None and before['held'] == 49 and r['held'] != 49:
                            release_event = dict(update=k+1,before=before,after=r)
                        action_counts[names.get(r['action'],hex(r['action']))] += 1
                        key = (r['action'],r['actionArg'],r['held'],r['floorOwner'],r['boxActive'])
                        if key != last_key:
                            transitions.append(dict(update=k+1, actionName=names.get(r['action']), sample=r))
                            last_key = key
                        if r['area'] == 1 and (max_y is None or r['movement'][1] > max_y['movement'][1]):
                            max_y = r
                        if (r['area'] == 1 and r['timer']<=handoff_global_timer
                                and (max_before130 is None or r['movement'][1]>max_before130['movement'][1])):
                            max_before130 = r
                        if r['action'] == CRAWLING:
                            if max_crawl is None or r['movement'][1] > max_crawl['movement'][1]:max_crawl = r
                            high_crawl |= r['movement'][1] >= 1741
                        if (r['area'] != 1 or g.read('gMarioState.area').is_null()
                                or g.read('gMarioState.area.camera').is_null()):break
                    row = dict(phase=phase,boxDistance=distance,bPressFrame=btime,policy=policy,
                               updates=len(controls),pickupAfterUpdates=pickup,
                               seenBounce=seen_bounce,releaseAfterUpdates=release,releaseEvent=release_event,
                               actionCounts=dict(action_counts),maxY=max_y['movement'][1],
                               maxBefore130Y=None if max_before130 is None else max_before130['movement'][1],
                               maxCrawlY=None if max_crawl is None else max_crawl['movement'][1],
                               highCrawl=high_crawl,phase130=phase130,final=samples[-1],
                               initialEdits=edits,transitions=transitions)
                    trials.append(row)
                    candidate=dict(summary=row,controls=controls,samples=samples,
                                   peak=max_y,peakBefore130=max_before130,crawlPeak=max_crawl)
                    rankings={'maximum-area1-height':row['maxY'],
                              'maximum-height-before-handoff':(-1e9 if max_before130 is None else max_before130['movement'][1]),
                              'maximum-crawl':-1e9 if row['maxCrawlY'] is None else row['maxCrawlY'],
                              'highest-top-third-landing-before132':(
                                  release_event['after']['movement'][1]
                                  if release_event is not None
                                  and release_event['before']['action']==BOUNCE
                                  and release_event['before']['actionArg']==2
                                  and release_event['after']['action']==g.constant('ACT_STOMACH_SLIDE')
                                  and release_event['after']['floorOwner']==61
                                  and release_event['after']['topBehaviorIsPyramid']
                                  and release_event['after']['timer']<=handoff_global_timer+1 else -1)}
                    for label,rank in rankings.items():
                        if label not in selected or rank > selected[label]['rank']:
                            selected[label]=dict(rank=rank,witness=candidate)
    witnesses=[]
    for label,choice in selected.items():
        witness=choice['witness']; row=witness['summary']
        fresh,obs=reach_after_pillars(capture)
        while not(fresh.read('gObjectPool[61].oAction')==1 and fresh.read('gObjectPool[61].oTimer')==row['phase']):
            advance(fresh,NEUTRAL)
        assert snap(fresh,obs)==contexts[row['phase']]
        edits=seed(fresh,row['boxDistance']);assert edits==row['initialEdits']
        for pad,expected in zip(witness['controls'],witness['samples']):
            advance(fresh,pad);assert snap(fresh,obs)==expected
        witnesses.append(dict(label=label,rank=choice['rank'],**witness,
                              freshBootValidation=dict(passed=True,comparedSnapshots=len(witness['samples']),
                                  continuousUpdates=len(witness['controls']),initialEdits=edits,intermediateEdits=0)))
    return dict(schema=1,scope=__doc__,baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                contexts=contexts,phases=PHASES,seed=SEED,policies=POLICIES,
                handoffGlobalTimer=handoff_global_timer,
                trials=trials,witnesses=witnesses,
                summary=dict(trials=len(trials),updates=sum(t['updates'] for t in trials),
                             pickups=sum(t['pickupAfterUpdates'] is not None for t in trials),
                             bounceTrials=sum(t['seenBounce'] for t in trials),
                             crawlTrials=sum(t['maxCrawlY'] is not None for t in trials),
                             highCrawlTrials=sum(t['highCrawl'] for t in trials),
                             area2Arrivals=sum(t['final']['area']==2 for t in trials),
                             maxArea1Y=max(t['maxY'] for t in trials),
                             maxBefore130Y=max((t['maxBefore130Y'] for t in trials if t['maxBefore130Y'] is not None),default=None),
                             maxCrawlY=max((t['maxCrawlY'] for t in trials if t['maxCrawlY'] is not None),default=None)))


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();result=run(a.capture)
    with a.output.open('x',encoding='utf-8') as f:json.dump(result,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(result['summary'],indent=2))


if __name__=='__main__':main()
