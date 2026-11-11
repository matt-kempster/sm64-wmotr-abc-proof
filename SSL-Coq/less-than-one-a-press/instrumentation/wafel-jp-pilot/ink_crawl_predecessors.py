"""Finite no-A predecessor probes for the 973-unit handoff.

All initial gameplay edits are reported. Position-only roof seeds retain the
prefix's actual action and cache, then use controller inputs exclusively.
Top-support diagnostic seeds additionally supply action/speed/platform and
are explicitly not controller-reached predecessors. No intermediate patch
is permitted after a trial starts.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import struct
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import NEUTRAL, reach_after_pillars, set_input
from ink_timer130_crawl import snapshot

PAD = [-1950, 1741, -939]
CRAWLING = 0x04008448
PHASES = [0, 8, 24, 48, 64, 80, 96, 112, 120, 128, 129, 130]


def f32(v):
    return struct.unpack('<f', struct.pack('<f', v))[0]


def advance(g, control):
    assert not control['buttons'] & 0x8000
    set_input(g, control)
    g.advance()
    assert not g.read('gMarioState.input') & 0x82


def write(g, path, value, ledger):
    ledger.append(dict(path=path, before=g.read(path), after=value))
    g.write(path, value)


def pose(g, value, ledger):
    write(g, 'gMarioState.pos', value, ledger)
    for axis, number in zip('XYZ', value):
        write(g, 'gMarioObject.oPos' + axis, number, ledger)
    write(g, 'gMarioObject.header.gfx.pos', value, ledger)


def steer(g, target, magnitude):
    pos = g.read('gMarioState.pos')
    dx, dz = target[0] - pos[0], target[1] - pos[2]
    yaw = g.read('gMarioState.area.camera.yaw') * 2 * math.pi / 65536
    angle = math.atan2(dx, dz) - yaw
    return dict(buttons=0x2000, stick=[round(math.sin(angle) * magnitude),
                                      round(-math.cos(angle) * magnitude)])


def loaded_top_floor(g, x, z):
    """Read the existing native loaded planes and evaluate their integer XZ.

    This calculation supplies a support-height proposal; it is not a new
    hooked find_floor return. Its normal/offset/vertices are saved below.
    """
    x, z = int(x), int(z)
    for i in range(g.read('gNumStaticSurfaces'), g.read('gSurfacesAllocated')):
        p = 'sSurfacePool[%d].' % i
        if g.read(p + 'object') != g.address('gObjectPool[61]'):
            continue
        n = g.read(p + 'normal')
        if n['y'] <= 0.01:
            continue
        vertices = [g.read(p + 'vertex%d' % k) for k in (1, 2, 3)]
        edges = [(a[2]-z)*(b[0]-a[0]) - (a[0]-x)*(b[2]-a[2])
                 for a, b in zip(vertices, vertices[1:] + vertices[:1])]
        if min(edges) < 0:
            continue
        d = g.read(p + 'originOffset')
        height = f32(-f32(f32(f32(n['x'] * x) + f32(n['z'] * z)) + d) / n['y'])
        return dict(index=i, height=height, normal=n, originOffset=d, vertices=vertices)
    return None


def run(capture):
    g, observer = reach_after_pillars(capture)
    states, contexts = {}, {}
    for _ in range(155):
        t = g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction') == 1 and t in PHASES:
            states[t] = g.save_state()
            contexts[t] = snapshot(g, observer)
        advance(g, NEUTRAL)
    assert set(states) == set(PHASES)
    names = g.mario_action_names()
    surfaces = g.surfaces()[:g.read('gNumStaticSurfaces')]
    static_floors = [s for s in surfaces if s.normal[1] > 0.01]
    static_inventory = dict(loadedSurfaceCount=len(surfaces),floorCount=len(static_floors),
                            maxFloorVertexY=max(v[1] for s in static_floors for v in s.vertices),
                            scope='Loaded native mesh inventory, not an all-query height proof')
    entry = []
    for phase in [128, 129, 130]:
        for action in ['ACT_IDLE', 'ACT_CROUCHING', 'ACT_START_CRAWLING', 'ACT_CRAWLING']:
            g.load_state(states[phase])
            assert snapshot(g, observer) == contexts[phase]
            edits = []
            pose(g, PAD, edits)
            for field, value in [('action', g.constant(action)), ('actionState', 0),
                                 ('actionTimer', 0), ('forwardVel', 5),
                                 ('faceAngle', [0, 0x4000, 0]), ('vel', [4, 0, 0])]:
                write(g, 'gMarioState.' + field, value, edits)
            before = snapshot(g, observer)
            control = dict(buttons=0x2000, stick=[0, 64])
            advance(g, control)
            after = snapshot(g, observer)
            entry.append(dict(phase=phase, initialAction=action, edits=edits,
                              controller=control, before=before, after=after,
                              afterActionName=names.get(after['action'])))

    # Inverse of the source's yaw-only rotation about CURRENT phase130 center.
    # Computed real trig supplies proposals; actual full frames validate them.
    delta = 6144 * 2 * math.pi / 65536
    cx, cz = -2047, -1023
    inverse_x = cx + math.cos(delta)*(PAD[0]-cx) - math.sin(delta)*(PAD[2]-cz)
    inverse_z = cz + math.sin(delta)*(PAD[0]-cx) + math.cos(delta)*(PAD[2]-cz)
    g.load_state(states[130])
    support = loaded_top_floor(g, inverse_x, inverse_z)
    assert support is not None
    top_trials = []
    for height in [1741, support['height']]:
        for yaw in range(0, 65536, 8192):
            for speed in [4, 20]:
                g.load_state(states[130])
                assert snapshot(g, observer) == contexts[130]
                edits = []
                pose(g, [inverse_x, height, inverse_z], edits)
                for field, value in [('action', CRAWLING), ('actionState', 0),
                                     ('actionTimer', 0), ('forwardVel', speed),
                                     ('faceAngle', [0, yaw if yaw < 32768 else yaw-65536, 0])]:
                    write(g, 'gMarioState.' + field, value, edits)
                write(g, 'gMarioPlatform', g.address('gObjectPool[61]'), edits)
                # Addresses are represented by the declared slot in JSON.
                edits[-1]['before'] = contexts[130]['platform']
                edits[-1]['after'] = 61
                control = dict(buttons=0x2000, stick=[0, 64])
                advance(g, control)
                after = snapshot(g, observer)
                top_trials.append(dict(initialY=height, yaw=yaw, speed=speed,
                                       edits=edits, controller=control, after=after,
                                       afterActionName=names.get(after['action']),
                                       actionEntries=[{k:v for k,v in e.items() if k != 'reason'}
                                                      for e in g.frame_log() if e['type']=='FLT_EXECUTE_ACTION']))

    roof_trials, best = [], []
    roof_phases = [0, 8, 24, 48, 64, 80, 96, 112, 120]
    roof_points = [(x,z) for x in [-2500,-2300,-2100,-1900,-1700,-1550]
                   for z in [-1500,-1300,-1100,-900,-700,-550]]
    roof_points += [(x,-1023) for x in [-2559,-2558,-2540,-1570,-1537,-1536]]
    roof_points += [(-2047,z) for z in [-1535,-1534,-1516,-550,-512,-511]]
    roof_points += [(-2559,-1535),(-2559,-512),(-1536,-1535),(-1536,-512)]
    for phase in roof_phases:
        for x,z in roof_points:
                for target in [[-2047, -1023], [-1950, -939]]:
                    g.load_state(states[phase])
                    assert snapshot(g, observer) == contexts[phase]
                    edits = []
                    pose(g, [x, 1280, z], edits)
                    action_counts = Counter()
                    controls, checkpoints = [], []
                    max_crawl_y, crawl_updates, top_crawl_updates = None, 0, 0
                    reached_high = False
                    for k in range(132-phase):
                        control = (dict(buttons=0x2000, stick=[0, 0]) if k < 8
                                   else steer(g, target, 64))
                        controls.append(control)
                        advance(g, control)
                        action = g.read('gMarioState.action')
                        action_counts[names.get(action, hex(action))] += 1
                        pos_now = g.read('gMarioState.pos')
                        if action == CRAWLING:
                            crawl_updates += 1
                            max_crawl_y = pos_now[1] if max_crawl_y is None else max(max_crawl_y,pos_now[1])
                            if observer.slot(g.read('gMarioState.floor?.object')) == 61:
                                top_crawl_updates += 1
                            if pos_now[1] >= 1741:
                                reached_high = True
                        if k == 0 or action == CRAWLING or g.read('gObjectPool[61].oTimer') in [129,130,131]:
                            checkpoints.append(snapshot(g, observer))
                        if (g.read('gCurrAreaIndex') != 1 or g.read('gMarioState.area').is_null()
                                or g.read('gMarioState.area.camera').is_null()):
                            break
                    row = dict(phase=phase, seed=[x,1280,z], target=target,
                               inheritedAction=names.get(contexts[phase]['action']),
                               actionCounts=dict(action_counts), crawlUpdates=crawl_updates,
                               topCrawlUpdates=top_crawl_updates,maxCrawlY=max_crawl_y,
                               reachedHighCrawl=reached_high,updates=len(controls),
                               final=snapshot(g,observer))
                    roof_trials.append(row)
                    if crawl_updates and (not best or (max_crawl_y,crawl_updates) > (best[0]['summary']['maxCrawlY'],best[0]['summary']['crawlUpdates'])):
                        best=[dict(summary=row,edits=edits,controls=controls,checkpoints=checkpoints)]
    # Independent fresh boot: no saved-state restore, one position patch,
    # then the entire best controller suffix without any intermediate edit.
    fresh, fresh_observer = reach_after_pillars(capture)
    witness = best[0]
    phase = witness['summary']['phase']
    while not (fresh.read('gObjectPool[61].oAction') == 1
               and fresh.read('gObjectPool[61].oTimer') == phase):
        advance(fresh, NEUTRAL)
    assert snapshot(fresh,fresh_observer) == contexts[phase]
    edits=[]
    pose(fresh,witness['summary']['seed'],edits)
    expected={row['timer']:row for row in witness['checkpoints']}
    checked=0
    for control in witness['controls']:
        advance(fresh,control)
        timer=fresh.read('gGlobalTimer')
        if timer in expected:
            assert snapshot(fresh,fresh_observer)==expected[timer]
            checked+=1
    assert snapshot(fresh,fresh_observer)==witness['summary']['final']
    witness['freshBootValidation']=dict(passed=True,comparedCheckpoints=checked,
                                        continuousUpdates=len(witness['controls']),
                                        initialEdits=edits,intermediateEdits=0)
    return dict(schema=1, scope='Finite supplied-context predecessor probes; no clean gameplay producer or all-history exclusion',
                baselineSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                runtimeSha256=hashlib.sha256(Path('build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                contexts=contexts, staticInventory=static_inventory,entryControls=entry,
                inverseProposal=dict(x=inverse_x,z=inverse_z,
                                     previousLoadedSupport=support),
                inverseTopTrials=top_trials, roofTrials=roof_trials, bestRoofWitnesses=best,
                summary=dict(entryTrials=len(entry),inverseTrials=len(top_trials),roofTrials=len(roof_trials),
                             roofTrialsWithCrawl=sum(r['crawlUpdates']>0 for r in roof_trials),
                             roofTrialsWithTopCrawl=sum(r['topCrawlUpdates']>0 for r in roof_trials),
                             roofTrialsWithHighCrawl=sum(r['reachedHighCrawl'] for r in roof_trials),
                             highestRoofSeedCrawlY=max((r['maxCrawlY'] for r in roof_trials if r['maxCrawlY'] is not None),default=None)))


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    args=p.parse_args(); result=run(args.capture)
    with args.output.open('x',encoding='utf-8') as f:
        json.dump(result,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(result['summary'],indent=2))


if __name__=='__main__':main()
