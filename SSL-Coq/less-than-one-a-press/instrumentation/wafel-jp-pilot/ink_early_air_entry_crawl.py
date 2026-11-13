"""Earlier supplied exterior freefall entries, then A-off controller inputs.

Scan each behavior timer before 130 using the prior air-entry seed menu.
Retain every completed deep entry, regardless of its resulting action.
Continue those entries without pruning exits, through the boundary before
behavior 130. This finite policy menu is not a reachability theorem.
"""
import argparse
from collections import Counter
import json
from pathlib import Path
import sys
import time

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_crawl_edge_entry import (ROOT, TrialGame, Observer, load_capture,
    NEUTRAL, top_snapshot, recipes, seed_pose, controller, sha, CRAWL)
from ink_air_entry_to_crawl import state, advance, policy_pad, AIR, Z
from ink_top_entry_witnesses import setup_fresh, rich_state, rich_advance
from ink_crawl_top_entry import contains

CAPTURE = ROOT / 'build/wafel-pilot/capture.bKv95w/inputs.jsonl'
NAMES = ['ACT_CRAWLING', 'ACT_START_CRAWLING', 'ACT_CROUCHING',
         'ACT_START_CROUCHING', 'ACT_IDLE']


def exact_upper(top, pos):
    """Geometric plane through native integer vertices, without X/Z rounding.

    The game's rounded floor query still classifies the subsequent events.
    This extra check prevents nominal +1 query-height starts from already
    penetrating the actual collision triangle by a fraction of a unit.
    """
    heights=[]
    for face in top['faces']:
        if face['normal']['y'] <= 0.01 or not contains(face,pos[0],pos[2]):
            continue
        a,b,c=face['vertices']
        u=[b[i]-a[i] for i in range(3)];v=[c[i]-a[i] for i in range(3)]
        n=[u[1]*v[2]-u[2]*v[1],u[2]*v[0]-u[0]*v[2],u[0]*v[1]-u[1]*v[0]]
        heights.append(a[1]-(n[0]*(pos[0]-a[0])+n[2]*(pos[2]-a[2]))/n[1])
    assert heights, 'Face-derived seed must lie in the old collision footprint'
    return max(heights)


def contexts():
    g = TrialGame()
    o = Observer(g)
    prefix = load_capture(CAPTURE)[:2548]
    for pad in prefix:
        g.advance_pad(pad)
    states, meshes = {}, {}
    for _ in range(155):
        if g.read('gObjectPool[61].oAction') == 1:
            phase = g.read('gObjectPool[61].oTimer')
            if 0 <= phase <= 130 and phase not in states:
                states[phase] = g.save_state()
                meshes[phase] = top_snapshot(g)
        g.advance_pad(NEUTRAL)
    assert set(states) == set(range(131))
    return g, o, states, meshes


def checked_advance(g, o, pad):
    r = advance(g, o, pad)
    assert not r['state']['buttons'] & 0x8000
    assert not r['state']['buttonsPressed'] & 0x8000
    assert r['state']['topTimer'] == r['executedTopTimer'] + 1
    return r


def survey(g, o, states, meshes, stop):
    counts, by_phase, retained = Counter(), {}, []
    start = time.monotonic()
    for phase in range(stop):
        pc, chosen = Counter(), []
        for recipe in recipes(meshes[phase], phase, 'air'):
            pc['proposedStarts'] += 1
            clearance=recipe['pos'][1]-exact_upper(meshes[phase],recipe['pos'])
            if clearance <= 0:
                pc['rejectedInitialTriangleOverlap'] += 1
                continue
            g.load_state(states[phase])
            edits = seed_pose(g, recipe)
            initial = state(g, o, meshes[phase])
            assert not initial['geometry']['inside']
            assert initial['platform'] == -1
            pad = controller(g, recipe['yaw'], 0)
            r = checked_advance(g, o, pad)
            pc['exteriorStarts'] += 1
            q = r['state']['geometry']
            entry_deep = any(e['geometry'] and e['geometry']['deep']
                             for e in r['entries'])
            if entry_deep:
                pc['deepActionEntries'] += 1
            if not (q and q['deep']):
                continue
            pc['completedDeepEntries'] += 1
            pc['completedDeepAirEntries' if r['state']['action'] & AIR else
               'completedDeepGroundEntries'] += 1
            w = dict(recipe=recipe, suppliedEdits=edits, initial=initial,
                     entry=r, exactInitialFeetClearance=clearance)
            chosen.append(w)
        retained.extend(chosen)
        pc['retainedEntries'] = len(chosen)
        by_phase[str(phase)] = dict(pc)
        counts.update(pc)
        if phase % 10 == 9 or phase == stop - 1:
            print(json.dumps(dict(stage='entry-survey',phase=phase,
                                  counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
    return dict(counts=dict(counts), byPhase=by_phase, retained=retained)


def menus():
    # Settling uses native action transitions, not a fixed wait assumption.
    for direction in ['inward', 'outward', 'left', 'right']:
        for magnitude in [32, 64]:
            yield dict(mode='settle-z', direction=direction, magnitude=magnitude,
                       delay=0, brakeGroundFrames=0)
        yield dict(mode='land-z', direction=direction, magnitude=32,
                   delay=0, brakeGroundFrames=3)
    for mode in ['z-hold', 'z-pulse', 'b-z', 'b-land-z', 'bz-z']:
        for delay in [0, 3, 6]:
            for direction in ['inward', 'outward']:
                yield dict(mode=mode, direction=direction, magnitude=32,
                           delay=delay, brakeGroundFrames=3)


def choose_pad(g, policy, k, ground_age, stage, constants):
    if policy['mode'] != 'settle-z':
        return policy_pad(g, policy, k, ground_age), stage
    action = g.read('gMarioState.action')
    if stage == 'settle' and action == constants['ACT_IDLE']:
        stage = 'crouch'
    if stage == 'crouch' and action == constants['ACT_CROUCHING']:
        stage = 'crawl'
    if stage != 'crawl':
        return dict(buttons=0 if stage == 'settle' else Z, stick=[0, 0]), stage
    from ink_air_entry_to_crawl import yaw_for
    return controller(g, yaw_for(g, policy['direction']), Z, policy['magnitude']), stage


def outcome(records, constants):
    result = dict(crouch=False, startCrawl=False, crawl=False,
                  executedCrawl=False, crawlInside=False, crawlDeep=False,
                  completedDeepCrawl=False, deepCrawlBeforeFirstExit=False,
                  readyAt130=False, insideAt130=False, deepAt130=False,
                  topLanding=False, firstExit=None,
                  firstCrawl=None, firstInsideCrawl=None, lastInside=None,
                  maxInteriorRun=0)
    exited = False
    streak = 0
    for frame, r in enumerate(records, 1):
        s = r['state']; t = r['executedTopTimer']; q = s['geometry']
        assert t < 130
        acts = [e['action'] for e in r['entries']] + [s['action']]
        result['crouch'] |= any(a in [constants['ACT_START_CROUCHING'],
                                     constants['ACT_CROUCHING']] for a in acts)
        result['startCrawl'] |= constants['ACT_START_CRAWLING'] in acts
        if CRAWL in acts:
            result['crawl'] = True
            if result['firstCrawl'] is None:
                result['firstCrawl'] = dict(frame=frame, behavior=t, position=s['position'])
        result['executedCrawl'] |= any(e['action'] == CRAWL for e in r['entries'])
        for a, geom in [(e['action'], e['geometry']) for e in r['entries']] + [(s['action'], q)]:
            if a == CRAWL and geom and geom['inside']:
                result['crawlInside'] = True
                result['crawlDeep'] |= geom['deep']
                result['deepCrawlBeforeFirstExit'] |= geom['deep'] and not exited
                if result['firstInsideCrawl'] is None:
                    result['firstInsideCrawl'] = dict(frame=frame, behavior=t, deep=geom['deep'])
        completed = bool(q and q['deep'] and s['action'] == CRAWL and s['hitboxHeight'] == 100)
        result['completedDeepCrawl'] |= completed
        result['readyAt130'] |= completed and s['topTimer'] == 130
        result['insideAt130'] |= bool(q and q['inside'] and s['topTimer'] == 130)
        result['deepAt130'] |= bool(q and q['deep'] and s['topTimer'] == 130)
        result['topLanding'] |= s['platform'] == 61 and not s['action'] & AIR
        if q and q['inside']:
            result['lastInside'] = dict(frame=frame, behavior=t, action=s['action'], position=s['position'])
            streak += 1
            result['maxInteriorRun'] = max(streak, result['maxInteriorRun'])
        else:
            if result['firstExit'] is None:
                result['firstExit'] = dict(frame=frame, behavior=t, position=s['position'])
            exited = True
            streak = 0
    return result


def continue_entries(g, o, states, survey_result, constants, selected, limit):
    counts, rows = Counter(), []
    policies = list(menus())
    start = time.monotonic()
    for index, entry in enumerate(survey_result['retained'][:limit]):
        g.load_state(states[entry['recipe']['phase']])
        assert seed_pose(g, entry['recipe']) == entry['suppliedEdits']
        assert checked_advance(g, o, entry['entry']['input']) == entry['entry']
        root = g.save_state()
        for policy in policies:
            g.load_state(root)
            records = [entry['entry']]
            ground_age = 0; stage = 'settle'
            while g.read('gObjectPool[61].oTimer') < 130:
                ground_age = ground_age+1 if not g.read('gMarioState.action') & AIR else 0
                pad, stage = choose_pad(g, policy, len(records)-1, ground_age, stage, constants)
                records.append(checked_advance(g, o, pad))
            result = outcome(records, constants)
            counts['policies'] += 1
            counts['continuationFrames'] += len(records)-1
            for key, value in result.items():
                if isinstance(value, bool):
                    counts[key] += value
            rows.append(dict(entryIndex=index, policy=policy, outcome=result))
            w = dict(entry=entry, policy=policy, records=records, outcome=result)
            if not selected:
                selected['earliestEntry'] = w
            for key in ['crawlDeep', 'completedDeepCrawl', 'readyAt130', 'crawlInside',
                        'crawl', 'startCrawl', 'crouch', 'topLanding', 'insideAt130', 'deepAt130']:
                if result[key] and key not in selected:
                    selected[key] = w
            if ('longestInterior' not in selected or
                result['maxInteriorRun'] > selected['longestInterior']['outcome']['maxInteriorRun']):
                selected['longestInterior'] = w
        if (index+1) % 20 == 0 or index+1 == len(survey_result['retained'][:limit]):
            print(json.dumps(dict(stage='continuations',entries=index+1,
                counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
    return dict(counts=dict(counts), menu=policies, results=rows)


def verify(w):
    g, o, edits = setup_fresh(w['entry']['recipe'])
    assert edits == w['entry']['suppliedEdits']
    assert state(g, o) == w['entry']['initial']
    initial = rich_state(g, o)
    details = []
    for expected in w['records']:
        before = rich_state(g, o)
        actual = checked_advance(g, o, expected['input'])
        assert actual == expected
        details.append(dict(before=before, input=expected['input'],
                            after=rich_state(g, o), actionEntries=actual['entries'],
                            executedTopTimer=actual['executedTopTimer']))
    return dict(passed=True, comparedFrames=len(details), initial=initial, updates=details)


def run(output, phase_stop, limit):
    assert 1 <= phase_stop <= 130
    g, o, states, meshes = contexts()
    constants = {n:g.constant(n) for n in NAMES}
    survey_result = survey(g, o, states, meshes, phase_stop)
    selected = {}
    policies = continue_entries(g, o, states, survey_result, constants, selected, limit)
    validations = {name:verify(w) for name,w in selected.items()}
    report = dict(schema=1, scope='Earlier supplied exterior freefall; A off and controller-only thereafter',
        preEntrySetup='Accepted debug level select before gameplay; 2548 recorded no-A pads, then neutral wait',
        phaseRange=[0,phase_stop-1], survey=survey_result, policies=policies,
        selected=selected, validations=validations, aInputs=0,
        postSetupWrites='Only the three controller-pad fields; state loads occur between alternative trials',
        actionNames=g.mario_action_names(), scriptSha256=sha(__file__),
        runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'), captureSha256=sha(CAPTURE),
        dependencies={n:sha(Path(__file__).with_name(n)) for n in
            ['ink_crawl_edge_entry.py','ink_crawl_top_entry.py','ink_air_entry_to_crawl.py',
             'ink_top_entry_witnesses.py','ink_crawl_predecessors.py','replay.py']},
        limits='Finite exterior seed and controller menus; first-frame completed deep entries only; no whole-state or global reachability proof')
    with output.open('x', encoding='utf-8') as f:
        json.dump(report, f, indent=2, allow_nan=False); f.write('\n')
    print(json.dumps(dict(saved=str(output), survey=survey_result['counts'],
        continuations=policies['counts'], validated={n:v['comparedFrames'] for n,v in validations.items()})),flush=True)


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path)
    p.add_argument('--phase-stop',type=int,default=130)
    p.add_argument('--entry-limit',type=int,default=None)
    a=p.parse_args()
    run(a.output,a.phase_stop,a.entry_limit)
