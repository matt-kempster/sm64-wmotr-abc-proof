"""Test alternative gap creation below the cap, from synchronized positions.

The conditional matrix supplies an established crawl and actor placement, not
a display gap or floor cache. The independent controller suffixes supply no
gameplay state. This is finite native JP evidence, not a reachability proof.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))
from ink_floorless_warp import NEUTRAL, reach_after_pillars, set_input, position
from ink_timer130_crawl import snapshot
from replay import RUNTIME, load_capture, create_game, Observer

CRAWL = 0x04008448
PHASES = [0, 32, 64, 96, 112, 122, 126, 128, 130]
HEIGHTS = [768, 819, 1201, 1202, 1280, 1363, 1380, 1381, 1400,
           1418, 1423, 1741, 1861, 1939]
ACTORS = {'box': (49, 'bhvJumpingBox', 39.),
          'bobomb': (39, 'bhvBobomb', 29.)}


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'),
                                    allow_nan=False).encode()).hexdigest()


def events(g):
    return [{k: v for k, v in e.items() if k not in ('reason', '_placeholder')}
            for e in g.frame_log()]


def cap_box(g):
    """Conservative loaded collision AABB, not rendered Mario or call tracing."""
    if not g.read('gObjectPool[61].activeFlags'):
        return None
    vertices = []
    for i in range(g.read('gNumStaticSurfaces'), g.read('gSurfacesAllocated')):
        p = 'sSurfacePool[%d].' % i
        if g.read(p+'object') == g.address('gObjectPool[61]'):
            vertices += [g.read(p+'vertex%d' % k) for k in (1, 2, 3)]
    if not vertices:
        return None
    return dict(min=[min(v[k] for v in vertices) for k in range(3)],
                max=[max(v[k] for v in vertices) for k in range(3)])


def clear_box(pos, height, box):
    if box is None:
        return True
    lo, hi = box['min'], box['max']
    # Radius37 and observed hitbox height give a deliberately over-broad box.
    # Equality at a boundary counts as contact and does not pass this screen.
    return (pos[0]+37 < lo[0] or pos[0]-37 > hi[0] or
            pos[2]+37 < lo[2] or pos[2]-37 > hi[2] or
            pos[1]+height < lo[1] or pos[1] > hi[1])


def observation(g, o):
    r = snapshot(g, o)
    r.update(depth=g.read('gMarioState.quicksandDepth'),
             hitbox=g.read('gMarioObject.hitboxHeight'),
             held=o.slot(g.read('gMarioState.heldObj')))
    return r


def advance(g, pad):
    assert not pad['buttons'] & 0x8000
    set_input(g, pad); g.advance()
    assert not g.read('gMarioState.input') & 0x82


def contexts(capture):
    g, o = reach_after_pillars(capture)
    states, rows = {}, {}
    for _ in range(150):
        t = g.read('gObjectPool[61].oTimer')
        if g.read('gObjectPool[61].oAction') == 1 and t in PHASES:
            states[t] = g.save_state(); rows[t] = observation(g, o)
        if len(states) == len(PHASES):
            break
        advance(g, NEUTRAL)
    assert set(states) == set(PHASES)
    return g, o, states, rows


def recipes():
    for target in ['original-west', '973-east']:
        for kind in ACTORS:
            for y in HEIGHTS:
                yield dict(phase=130, target=target, actor=kind, height=y,
                           action='ACT_CRAWLING', depth=0., policy=0)
    for action in ['ACT_IDLE', 'ACT_CROUCHING', 'ACT_START_CRAWLING']:
        for target in ['original-west', '973-east']:
            yield dict(phase=130, target=target, actor='box', height=1400,
                       action=action, depth=0., policy=0)
    # Test whether an inherited negative seed boosts this crawl-generated gap.
    # These seeds are supplied diagnostic assumptions, never clean acquisitions.
    for depth in [-.5, -538.8648681640625, -1000.]:
        yield dict(phase=130, target='original-west', actor='box', height=1400,
                   action='ACT_CRAWLING', depth=depth, policy=0)
    for phase in PHASES[3:-1]:
        for target in ['original-west', '973-east']:
            # The prefix's previous loaded bottom is measured, not presumed here.
            yield dict(phase=phase, target=target, actor='box', height='below-cap',
                       action='ACT_CRAWLING', depth=0., policy=0)


def begin(g, o, state, recipe):
    g.load_state(state)
    b = cap_box(g)
    y = b['min'][1]-101 if recipe['height'] == 'below-cap' else recipe['height']
    west = recipe['target'] == 'original-west'
    pos = [-2132., float(y), -1024.] if west else [-1950., float(y), -939.]
    slot, behavior, offset = ACTORS[recipe['actor']]
    assert g.read('gObjectPool[%d].behavior'%slot) == g.address(behavior)
    assert g.read('gObjectPool[%d].activeFlags'%slot)
    edits = []
    def write(p, v):
        edits.append(dict(path=p, before=g.read(p), after=v)); g.write(p, v)
    for p in ['gMarioState.pos', 'gMarioObject.header.gfx.pos']:
        write(p, pos)
    for ax, v in zip('XYZ', pos): write('gMarioObject.oPos'+ax, v)
    for f, v in [('action', g.constant(recipe['action'])), ('actionState', 0),
                 ('actionTimer', 0), ('forwardVel', 0.), ('vel', [0., 0., 0.]),
                 ('faceAngle', [0, 208, 0])]:
        write('gMarioState.'+f, v)
    write('gMarioObject.hitboxHeight', 100. if recipe['action']=='ACT_CRAWLING' else 160.)
    if recipe['depth']:
        write('gMarioState.quicksandDepth', recipe['depth'])
    for ax, v in zip('XYZ', [pos[0] + (offset if west else -offset), y, pos[2]]):
        write('gObjectPool[%d].oPos%s'%(slot, ax), float(v))
    for f in ['oForwardVel', 'oVelX', 'oVelY', 'oVelZ']:
        write('gObjectPool[%d].%s'%(slot, f), 0.)
    initial = observation(g, o)
    assert initial['movement'] == initial['collision'] == initial['display']
    return initial, edits, b


def run_case(g, o, state, recipe):
    initial, edits, b0 = begin(g, o, state, recipe)
    samples, log = [initial], []
    advance(g, dict(buttons=0x2000, stick=[0,64]))
    after = observation(g, o); b1 = cap_box(g); first_events = events(g)
    samples.append(after); log.append(first_events)
    gap = after['display'][1] - after['movement'][1]
    entry_positions = [e['pos'] for e in first_events if e['type']=='FLT_EXECUTE_ACTION']
    screen = clear_box(initial['movement'], initial['hitbox'], b0)
    screen = screen and all(clear_box(p, initial['hitbox'], b1) for p in entry_positions)
    screen = screen and clear_box(after['movement'], after['hitbox'], b1)
    advance(g, NEUTRAL)
    second = observation(g, o); samples.append(second); log.append(events(g))
    captured = second['platform']==61 and second['floorOwner']==61 and second['used']==64
    arrival = None
    for _ in range(28):
        if samples[-1]['area'] == 2:
            arrival = samples[-1]; break
        if samples[-1]['level'] != 8 or samples[-1]['area'] != 1:
            break
        advance(g, NEUTRAL); samples.append(observation(g, o)); log.append(events(g))
    outside = arrival is not None and not (-460<=arrival['movement'][0]<=461 and
                                          -204<=arrival['movement'][2]<=717)
    return dict(recipe=recipe, edits=edits, initial=initial, after=after, next=second,
                capBefore=b0, capPrepared=b1, initialAndProducerBodyClear=screen,
                gap=gap, createdPositiveGap=gap>0, capturedTop=captured,
                firstArea2=arrival, outsideElevator=outside, updates=len(samples)-1,
                firstUpdateEvents=first_events, historyDigest=digest([samples,log]),
                intermediateEdits=0)


def clean_policy(g, index, frame):
    directions = [(0,0),(0,64),(64,0),(0,-64),(-64,0),
                  (45,45),(45,-45),(-45,-45),(-45,45)]
    direction, mode = divmod(index,4)
    buttons = [0,0x2000,0x4000 if frame%8==0 else 0,
               0x2000|(0x4000 if frame%8==0 else 0)][mode]
    if direction < len(directions):
        stick = directions[direction]
    else:
        target = [-2200.,-1024.] if direction == 9 else [-2048.,-1024.]
        p = g.read('gMarioState.pos'); yaw=g.read('gMarioState.area.camera.yaw')*math.pi/32768
        angle=math.atan2(target[0]-p[0],target[1]-p[2])-yaw
        stick=[round(math.sin(angle)*64),round(-math.cos(angle)*64)]
    return dict(buttons=buttons,stick=list(stick))


def run_clean(g, o, state, phase, policy, horizon):
    g.load_state(state)
    initial=observation(g,o); samples=[initial]; logs=[]; pads=[]
    max_gap=initial['display'][1]-initial['movement'][1]
    min_distance=math.dist(initial['movement'],[-2200.,768.,-1024.])
    stop='horizon'; capture=False
    for i in range(horizon):
        before = samples[-1]; b0=cap_box(g)
        if not clear_box(before['movement'],before['hitbox'],b0):
            stop='cap-screen';break
        pad=clean_policy(g,policy,i);pads.append(pad);advance(g,pad)
        r=observation(g,o);ev=events(g);samples.append(r);logs.append(ev);b1=cap_box(g)
        positions=[e['pos'] for e in ev if e['type']=='FLT_EXECUTE_ACTION']
        if not all(clear_box(p, before['hitbox'], b1) for p in positions) or not clear_box(r['movement'],r['hitbox'],b1):
            stop='cap-screen';break
        max_gap=max(max_gap,r['display'][1]-r['movement'][1])
        min_distance=min(min_distance,math.dist(r['movement'],[-2200.,768.,-1024.]))
        capture |= r['platform']==61 and r['floorOwner']==61 and r['used']==64
        if r['level']!=8 or r['area']!=1 or g.read('gMarioState.area.camera').is_null():
            stop='left-area';break
    return dict(phase=phase,policy=policy,initial=initial,final=samples[-1],
                updates=len(pads),maxPositiveDisplayGap=max_gap,minDistanceToOriginal=min_distance,
                stop=stop,capturedTop=capture,historyDigest=digest([samples,logs,pads]),
                initialEdits=0,intermediateEdits=0,AInputs=0)


def run(capture, horizon):
    g,o,states,rows=contexts(capture)
    matrix=[run_case(g,o,states[r['phase']],r) for r in recipes()]
    clean=[run_clean(g,o,states[p],p,k,horizon) for p in PHASES for k in range(44)]
    # Freshly boot and replay prefix; compare selected complete native histories.
    fresh,fo,fstates,_=contexts(capture)
    selected=[i for i,r in enumerate(matrix) if r['recipe']['actor']=='box' and
              r['recipe']['target']=='original-west' and r['recipe']['height'] in (1280,1380,1381,1400,1418)]
    selected += [i for i,r in enumerate(matrix) if r['recipe']['depth']]
    selected = sorted(set(selected))
    checks=[]
    for i in selected:
        r=matrix[i]; repeated=run_case(fresh,fo,fstates[r['recipe']['phase']],r['recipe'])
        assert repeated==r
        checks.append(dict(kind='supplied-state-producer',index=i,updates=r['updates'],matched=True))
    best=sorted(range(len(clean)),key=lambda i:(-clean[i]['maxPositiveDisplayGap'],clean[i]['minDistanceToOriginal']))[:3]
    for i in best:
        r=clean[i];repeated=run_clean(fresh,fo,fstates[r['phase']],r['phase'],r['policy'],horizon)
        assert repeated==r
        checks.append(dict(kind='controller-suffix',index=i,updates=r['updates'],matched=True))
    summary=dict(matrixTrials=len(matrix),matrixUpdates=sum(r['updates'] for r in matrix),
                 outsideCapPositiveGaps=sum(r['initialAndProducerBodyClear'] and r['gap']>0 for r in matrix),
                 outsideCapUsefulCaptures=sum(r['initialAndProducerBodyClear'] and r['capturedTop'] for r in matrix),
                 cleanTrials=len(clean),cleanUpdates=sum(r['updates'] for r in clean),
                 cleanStopCounts=dict(Counter(r['stop'] for r in clean)),
                 maxCleanDisplayGap=max(r['maxPositiveDisplayGap'] for r in clean),
                 cleanTopCaptures=sum(r['capturedTop'] for r in clean),
                 freshReplayChecks=len(checks),freshReplayUpdates=sum(r['updates'] for r in checks))
    return dict(schema=1,runtime='Pinned Wafel 0.8.5 JP native DLL',
                runtimeSha256=hashlib.sha256((RUNTIME/'sm64_jp.dll').read_bytes()).hexdigest(),
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                summary=summary,contexts=rows,matrix=matrix,clean=clean,freshChecks=checks,
                scope='Finite conditional gap creation and controller suffixes, no clean route or all-history exclusion',
                screen='Conservative radius37/observed-hitbox AABB separation at update boundaries and action-entry logs; not every internal position write or rendered mesh',
                horizon=horizon)


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path);p.add_argument('--horizon',type=int,default=160)
    a=p.parse_args();r=run(a.capture,a.horizon)
    with a.output.open('x',encoding='utf8') as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
    if a.receipt:
        # Every conditional producer is retained; clean rows are compact summaries.
        receipt=dict(r);receipt['rawSha256']=hashlib.sha256(a.output.read_bytes()).hexdigest()
        receipt['clean']=[{k:v for k,v in row.items() if k not in ('initial','final')} for row in r['clean']]
        receipt['cleanBest']=[row for row in r['clean'] if any(c['kind']=='controller-suffix' and
                             r['clean'][c['index']]==row for c in r['freshChecks'])]
        with a.receipt.open('x',encoding='utf8') as f:json.dump(receipt,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(r['summary'],indent=2))


if __name__=='__main__':main()
