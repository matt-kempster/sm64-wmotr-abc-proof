"""Finite controller-only approach screen from the accepted fourth pillar.

This tests a small policy family, not all no-A inputs. Save states come from
the checked controller prefix; no gameplay field is patched in any trial.
The goal is the Mario prerequisite, not a supplied or inferred shell.
"""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import reach_after_pillars, observe, set_input
from replay import load_capture

CRAWLING = 0x04008448
GOAL = [-1950, 1741, -939]


def snap(g, observer):
    r = observe(g, observer)
    r.update(topAction=g.read('gObjectPool[61].oAction'),
             topTimer=g.read('gObjectPool[61].oTimer'),
             velocity=g.read('gMarioState.vel'),
             forwardVelocity=g.read('gMarioState.forwardVel'),
             held=observer.slot(g.read('gMarioState.heldObj')))
    return r


def control(g, bias, buttons):
    x, _, z = g.read('gMarioState.pos')
    yaw = g.read('gMarioState.area.camera.yaw')
    angle = math.atan2(GOAL[0]-x, GOAL[2]-z) - yaw*math.tau/65536 + bias*math.tau/65536
    magnitude = min(127, 2*math.hypot(GOAL[0]-x, GOAL[2]-z))
    return dict(buttons=buttons, stick=[round(math.sin(angle)*magnitude), round(-math.cos(angle)*magnitude)])


def run(capture):
    g, observer = reach_after_pillars(capture)
    state = g.save_state()
    initial = snap(g, observer)
    rows = load_capture(capture)
    policies = [(bias, btime, ztime) for bias in (-4096, 0, 4096)
                for btime in (None, 0, 8, 20, 40, 64)
                for ztime in (None, 0, 100, 115, 123)]
    trials = []
    for bias, btime, ztime in policies:
        g.load_state(state)
        assert snap(g, observer) == initial
        samples, inputs = [], []
        for frame in range(133):
            r = snap(g, observer)
            samples.append(r)
            if r['area'] != 1 or r['level'] != 8 or g.read('gMarioState.area.camera').is_null():
                break
            buttons = (0x4000 if frame == btime else 0) | (0x2000 if ztime is not None and frame >= ztime else 0)
            pad = control(g, bias, buttons)
            assert not pad['buttons'] & 0x8000
            inputs.append(pad)
            set_input(g, pad)
            g.advance()
            assert not g.read('gMarioState.input') & 0x82
        phase = next((r for r in samples if r['topAction']==1 and r['topTimer']==130), None)
        compatible = phase is not None and phase['action']==CRAWLING and 1700 <= phase['movement'][1] <= 1810 and -2149 <= phase['movement'][0] <= -1945 and -1125 <= phase['movement'][2] <= -921
        trial = dict(policy=dict(yawBias=bias,bPressFrame=btime,zHoldFrom=ztime),
                     updates=len(inputs), inputs=inputs, phase130=phase,
                     marioPrerequisite=compatible,
                     maxY=max(r['movement'][1] for r in samples),
                     maxYNearPyramid=max((r['movement'][1] for r in samples if math.hypot(r['movement'][0]+2048,r['movement'][2]+1024)<1000),default=None),
                     topSupportedSamples=sum(r['floorOwner']==61 for r in samples),
                     crawlSamples=sum(r['action']==CRAWLING for r in samples),
                     closest=min(samples,key=lambda r: math.dist(r['movement'],GOAL)),
                     final=samples[-1])
        trials.append(trial)
    # The best screen is independently replayed from a fresh accepted boot,
    # not from a pasted target projection or an intermediate saved state.
    best=min(trials,key=lambda t: math.dist((t['phase130'] or t['final'])['movement'],GOAL))
    fresh, fresh_observer=reach_after_pillars(capture)
    assert snap(fresh,fresh_observer)==initial
    observed_phase=None
    for pad in best['inputs']:
        r=snap(fresh,fresh_observer)
        if r['topAction']==1 and r['topTimer']==130: observed_phase=r
        set_input(fresh,pad);fresh.advance()
        assert not fresh.read('gMarioState.input')&0x82
    assert observed_phase==best['phase130']
    return dict(schema=1,scope='90 finite controller policies after the accepted fourth pillar; Mario approach only',
                suppliedGameplayWrites=[],initial=initial,
                prefixInputCount=2548,prefixAFrames=sum(bool(r['buttons']&0x8000) for r in rows[:2548]),
                baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                trials=trials,bestPolicy=best['policy'],freshBootBestPhase130Matches=True,
                stoppingReason='Completed the predeclared finite policy grid; no exhaustive input claim')


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    args=p.parse_args();r=run(args.capture)
    with args.output.open('x',encoding='utf-8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(trials=len(r['trials']),prerequisites=sum(t['marioPrerequisite'] for t in r['trials']),
                         topSupportedTrials=sum(t['topSupportedSamples']>0 for t in r['trials']),
                         bestPolicy=r['bestPolicy'],freshBootReplay=r['freshBootBestPhase130Matches'])))
