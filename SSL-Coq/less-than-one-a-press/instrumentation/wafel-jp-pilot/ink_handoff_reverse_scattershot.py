"""Reverse proposals from the timer-130 handoff, validated by continuous JP play.

This is a bounded heuristic, not an inverse semantics or a Coq certificate.
Each trial restores one controller-reached phase context, applies ONE declared
initial setup, and replays every input through handoff/capture/Area-2 arrival.
No later pose, cache, timer, RNG, allocator or action correction is allowed.
Only successful COMPLETE suffixes may become backward parents. Different
parent observations are allowed if the new complete suffix still works.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import random
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(ROOT / 'instrumentation/concrete-ink-backward'))
from work_limits import WorkLimits, LimitReached

CRAWLING = 0x04008448
NEUTRAL = dict(buttons=0, stick=[0, 0])
Z_UP = dict(buttons=0x2000, stick=[0, 64])
PAD = [-1950., 1741., -939.]
ACTORS = {'box': (49, 'bhvJumpingBox', -39.),
          'bobomb': (39, 'bhvBobomb', -29.)}
FAMILIES = ('crawl', 'top-supported-crawl', 'start-crawl', 'crouch',
            'idle-release', 'handsfree-slide', 'airborne-held',
            'lower-release', 'native-actor', 'native-mario', 'clean-context')


def digest(value):
    return hashlib.sha256(json.dumps(value, sort_keys=True, separators=(',', ':'),
                                    allow_nan=False).encode()).hexdigest()


def validate_recipe(recipe):
    phase = recipe['phase']
    if not 0 <= phase <= 130 or len(recipe['controls']) != 131 - phase:
        raise ValueError('The continuous suffix must end after behavior timer130')
    for pad in recipe['controls']:
        if pad['buttons'] & 0x8000 or not 0 <= pad['buttons'] <= 0xffff:
            raise ValueError('A must remain released')
        if len(pad['stick']) != 2 or any(type(v) is not int or not -128 <= v <= 127
                                       for v in pad['stick']):
            raise ValueError('Invalid controller stick')
    if recipe['actorKind'] not in ACTORS:
        raise ValueError('Unsupported native actor')
    if recipe['family'] not in FAMILIES + ('root-control', 'missing-actor-control'):
        raise ValueError('Unknown proposal family')


def is_handoff(before, after):
    """A functional useful-split target; not exact equality to a supplied parent."""
    return (before['area'] == after['area'] == 1 and before['topTimer'] == 130
            and before['topAction'] == 1 and before['action'] == CRAWLING
            and before['actor']['live']
            and before['actor']['slot'] in after['collidedSlots']
            and after['action'] == CRAWLING and after['floorY'] == 768.
            and after['movement'] == after['collision']
            and after['movement'][1] == 768. and after['display'][1] > 1280.
            and after['display'][0] == after['movement'][0]
            and after['display'][2] == after['movement'][2])


def is_capture(row):
    return (row['area'] == 1 and row['action'] == 0x1300 and row['used'] == 64
            and row['floorOwner'] == 61 and row['platform'] == 61)


def outside_elevator(row):
    return (row is not None and row['area'] == 2
            and not (-460 <= row['movement'][0] <= 461
                     and -204 <= row['movement'][2] <= 717))


def replay_suffix(backend, recipe, tick=lambda: None):
    """The sole begin/setup is outside this function's advance-only interval."""
    validate_recipe(recipe)
    initial, edits = backend.begin(recipe)
    samples, event_log = [initial], []
    before130 = after130 = None
    for pad in recipe['controls']:
        tick()
        prior = samples[-1]
        row, events = backend.advance(pad)
        samples.append(row); event_log.append(events)
        if prior['area'] == 1 and prior['topAction'] == 1 and prior['topTimer'] == 130:
            before130, after130 = prior, row
        if row['area'] != 1:
            break
    handoff = before130 is not None and is_handoff(before130, after130)
    next_update = arrival = None
    captured = False
    if handoff:
        tick(); next_update, events = backend.advance(NEUTRAL)
        samples.append(next_update); event_log.append(events)
        captured = is_capture(next_update)
        if captured:
            for _ in range(27):
                tick(); row, events = backend.advance(NEUTRAL)
                samples.append(row); event_log.append(events)
                if row['area'] == 2:
                    arrival = row
                    break
    success = handoff and captured and outside_elevator(arrival)
    heights = [r['movement'][1] for r in samples if r['area'] == 1 and r['action'] == CRAWLING]
    status = ('useful-handoff' if success else 'no-handoff' if not handoff else
              'capture-failed' if not captured else 'payoff-failed')
    return dict(status=status, success=success, cleanGameplay=(success and not edits),
                initialEdits=edits, initial=initial, before130=before130, after130=after130,
                nextUpdate=next_update, firstArea2=arrival, handoff=handoff,
                capture=captured, outsideElevator=outside_elevator(arrival),
                updates=len(samples)-1, maxCrawlY=max(heights) if heights else None,
                historyDigest=digest([samples, event_log]), samples=samples, events=event_log)


def retain(entries, limit):
    """Diversity schedules exact recipes; it never merges native states."""
    ordered = sorted(entries, key=lambda e: (e['recipe']['phase'], -e['id']))
    chosen, buckets = [], set()
    for entry in ordered:
        r = entry['recipe']; key = (r['phase'], r['family'], r['actorKind'])
        if key not in buckets:
            chosen.append(entry); buckets.add(key)
        if len(chosen) == limit:
            break
    return chosen


def root_recipe(kind='box', missing=False):
    dx = ACTORS[kind][2]
    return dict(phase=130, actorKind=kind,
                family='missing-actor-control' if missing else 'root-control',
                mario=dict(pos=list(PAD), action='ACT_CRAWLING', speed=0., yaw=208,
                           velocity=[0., 0., 0.], hitbox=100.),
                actor=None if missing else dict(pos=[PAD[0]+dx, PAD[1], PAD[2]], mode='native'),
                platform=False, controls=[Z_UP], parent=None)


def proposal(parent, serial, rng, earliest):
    """Heuristic earlier values are proposals; native replay decides validity."""
    old = parent['recipe']; family = FAMILIES[serial % len(FAMILIES)]
    distance = (1, 2, 4, 8, 16)[(serial // len(FAMILIES)) % 5]
    phase = max(earliest, old['phase'] - distance)
    if phase >= old['phase']:
        return None
    distance = old['phase'] - phase
    base = old['mario']['pos'] if old['mario'] else list(PAD)
    kind = ('box', 'bobomb')[(serial // (len(FAMILIES)*5)) % 2]
    dx = ACTORS[kind][2]
    yaw = rng.randrange(0, 65536, 4096)
    speed = rng.choice([-1., 0., 2., 4., 12., 24., 48.])
    angle = yaw * math.pi / 32768
    pos = [base[0] - math.sin(angle)*speed*distance + rng.choice([-32., 0., 0., 32.]),
           base[1], base[2] - math.cos(angle)*speed*distance + rng.choice([-32., 0., 0., 32.])]
    action = {'crawl':'ACT_CRAWLING','top-supported-crawl':'ACT_CRAWLING',
              'start-crawl':'ACT_START_CRAWLING','crouch':'ACT_CROUCHING',
              'idle-release':'ACT_IDLE','handsfree-slide':'ACT_BUTT_SLIDE',
              'airborne-held':'ACT_FREEFALL','lower-release':'ACT_CRAWLING',
              'native-actor':'ACT_CRAWLING','native-mario':'ACT_CRAWLING',
              'clean-context':'ACT_CRAWLING'}[family]
    if family == 'top-supported-crawl':
        # Source yaw-only rotation inverse, not an assumed translation or exact inverse.
        delta = distance*6144*math.pi/32768
        x, z = base[0]+2047, base[2]+1023
        pos = [-2047+math.cos(delta)*x-math.sin(delta)*z, base[1],
               -1023+math.sin(delta)*x+math.cos(delta)*z]
    elif family in ('start-crawl','crouch','idle-release','handsfree-slide','airborne-held'):
        pos[1] = rng.choice([1280., 1408., 1650., 1741., 1800., 1905.])
    actor_y = (1650. if family == 'lower-release' else
               pos[1] + rng.choice([0., 0., 2.*distance*(distance-1)]))
    mode = ('held' if family in ('idle-release','handsfree-slide','airborne-held') else
            'dropped' if family == 'lower-release' else 'native')
    actor = dict(pos=[pos[0]+dx, actor_y, pos[2]], mode=mode)
    mario = dict(pos=pos, action=action, speed=speed,
                 yaw=yaw if yaw < 32768 else yaw-65536,
                 velocity=[math.sin(angle)*speed, rng.choice([-12.,0.,12.]) if
                           family=='airborne-held' else 0., math.cos(angle)*speed],
                 hitbox=100. if action=='ACT_CRAWLING' else 160.)
    sticks = [(0,0),(0,64),(64,0),(-64,0),(0,-64),(45,45),(-45,45),(45,-45),(-45,-45)]
    if family == 'native-actor': actor = None
    if family == 'native-mario': mario = None
    if family == 'clean-context': mario = actor = None
    mask = rng.choice([0x2000,0x2000,0x2000,0,0x4000,0x6000])
    pad = dict(buttons=mask, stick=list(rng.choice(sticks)))
    # Exact retained suffix, with only earlier inputs prepended.
    return dict(phase=phase, actorKind=kind, family=family, mario=mario, actor=actor,
                platform=family=='top-supported-crawl',
                controls=[pad for _ in range(distance)] + old['controls'], parent=parent['id'])


class NativeBackend:
    def __init__(self, capture, earliest, limits):
        from ink_floorless_warp import reach_after_pillars
        from ink_crawl_predecessors import loaded_top_floor
        self.loaded_top_floor = loaded_top_floor
        self.g, self.observer = reach_after_pillars(capture)
        self.contexts = {}; self.total_updates = 2548
        for _ in range(180):
            limits.check()
            t = self.g.read('gObjectPool[61].oTimer')
            if self.g.read('gObjectPool[61].oAction') == 1 and earliest <= t <= 130:
                self.contexts[t] = self.g.save_state()
            if t == 130 and 130 in self.contexts: break
            self.advance(NEUTRAL, capture_events=False)
        if set(self.contexts) != set(range(earliest,131)):
            raise RuntimeError('Incomplete native phase contexts')

    def observation(self):
        from ink_timer130_crawl import snapshot
        g, o = self.g, self.observer
        r = snapshot(g,o)
        kind = getattr(self, 'kind', 'box'); slot, behavior, _ = ACTORS[kind]
        p = 'gObjectPool[%d].' % slot
        collided = g.read('gMarioObject.numCollidedObjs')
        if not 0 <= collided <= 4: raise RuntimeError('Unexpected collision-list length')
        r.update(held=o.slot(g.read('gMarioState.heldObj')),
                 collidedSlots=[o.slot(g.read('gMarioObject.collidedObjs[%d]'%i)) for i in range(collided)],
                 hitboxHeight=g.read('gMarioObject.hitboxHeight'),
                 actor=dict(slot=slot, kind=kind,
                    live=bool(g.read(p+'activeFlags')) and g.read(p+'behavior')==g.address(behavior),
                    tangible=g.read(p+'oIntangibleTimer')==0,
                    intangibleTimer=g.read(p+'oIntangibleTimer'),
                    held=g.read(p+'oHeldState'), action=g.read(p+'oAction'), timer=g.read(p+'oTimer'),
                    pos=[g.read(p+'oPos'+ax) for ax in 'XYZ'],
                    velocity=[g.read(p+'oVel'+ax) for ax in 'XYZ'],
                    floorY=g.read(p+'oFloorHeight')))
        return r

    def begin(self, recipe):
        g=self.g; g.load_state(self.contexts[recipe['phase']]); self.kind=recipe['actorKind']
        slot, behavior, _ = ACTORS[self.kind]; p='gObjectPool[%d].' % slot
        if g.read(p+'behavior') != g.address(behavior) or not g.read(p+'activeFlags'):
            raise RuntimeError('Expected original live actor absent')
        edits=[]
        def write(path,value,pointer=False):
            before=g.read(path)
            edits.append(dict(path=path, before=self.observer.slot(before) if pointer else before,
                              after=self.observer.slot(value) if pointer else value))
            g.write(path,value)
        m=recipe['mario']; a=recipe['actor']
        if m:
            pos=list(m['pos'])
            if recipe['platform']:
                plane=self.loaded_top_floor(g,pos[0],pos[2])
                if plane is not None: pos[1]=plane['height']
            for path,value in [('gMarioState.pos',pos),('gMarioObject.header.gfx.pos',pos)]+[
                    ('gMarioObject.oPos'+ax,v) for ax,v in zip('XYZ',pos)]: write(path,value)
            for field,value in [('action',g.constant(m['action'])),('actionState',0),
                                ('actionTimer',0),('forwardVel',m['speed']),
                                ('vel',m['velocity']),('faceAngle',[0,m['yaw'],0])]:
                write('gMarioState.'+field,value)
            write('gMarioObject.hitboxHeight',m['hitbox'])
        if recipe['platform']:
            write('gMarioPlatform',g.address('gObjectPool[61]'),True)
        if a:
            for ax,value in zip('XYZ',a['pos']): write(p+'oPos'+ax,value)
            if a['mode']=='held':
                write('gMarioState.heldObj',g.address('gObjectPool[%d]'%slot),True)
                write(p+'oHeldState',1)
            elif a['mode']=='dropped':
                write(p+'oHeldState',3); write(p+'oIntangibleTimer',-1)
        return self.observation(),edits

    def advance(self,pad,capture_events=True):
        from replay import set_input
        from ink_timer130_crawl import frame_events
        g=self.g
        if pad['buttons'] & 0x8000: raise ValueError('A input')
        timer=g.read('gGlobalTimer'); set_input(g,pad); g.advance(); self.total_updates+=1
        if g.read('gGlobalTimer') != timer+1: raise RuntimeError('Unexpected native update')
        if g.read('gControllers[0].buttonDown') & 0x8000 or g.read('gControllers[0].buttonPressed') & 0x8000:
            raise RuntimeError('A held/pressed readback')
        if g.read('gMarioState.input') & 0x82: raise RuntimeError('Mario A input')
        if not capture_events: return None,None
        return self.observation(),frame_events(g)


def compact(result):
    return {k:v for k,v in result.items() if k not in ('samples','events')}


def run(args):
    if args.output.exists(): raise FileExistsError(args.output)
    if args.trials < 0 or args.seconds < 0: raise ValueError('Negative search budget')
    if not 1 <= args.archive <= 64 or not 1 <= args.max_depth <= 64:
        raise ValueError('Use archive/depth limits between 1 and 64')
    limits=WorkLimits(setup=120,verification=120,search=args.seconds,overall=args.seconds+300)
    earliest=131-args.max_depth
    backend=NativeBackend(args.capture,earliest,limits)
    limits.enter('verification')
    controls=[]; entries=[]
    for i,(kind,missing) in enumerate([('box',False),('bobomb',False),('box',True)]):
        recipe=root_recipe(kind,missing)
        result=replay_suffix(backend,recipe,limits.check)
        if result['success'] == missing: raise RuntimeError('Root/missing-actor control failed')
        controls.append(dict(recipe=recipe,result=compact(result)))
        if not missing: entries.append(dict(id=i,recipe=recipe,result=compact(result),attempts=0))
    limits.enter('search'); rng=random.Random(args.seed); trials=[]; counts=Counter()
    stop='trial-limit'; complete=0; incomplete=None
    for serial in range(args.trials):
        recipe = None
        try:
            limits.check()
            eligible=[e for e in entries if e['recipe']['phase']>earliest]
            if not eligible: stop='depth-limit'; break
            eligible.sort(key=lambda e:(e['recipe']['phase'],e['id']))
            # Keep exploring shorter successful branches every fourth proposal.
            parent=eligible[-1-(serial//4)%len(eligible)] if serial%4==3 else eligible[(serial//4)%len(eligible)]
            recipe=proposal(parent,parent['attempts'],rng,earliest); parent['attempts']+=1
            if recipe is None: continue
            result=replay_suffix(backend,recipe,limits.check); complete+=1
            counts[(recipe['family'],result['status'])]+=1
            row=dict(id=serial+3,recipe=recipe,result=compact(result)); trials.append(row)
            if result['success']:
                entries=retain(entries+[dict(row,attempts=0)],args.archive)
        except LimitReached:
            stop='time-limit'; incomplete=dict(serial=serial, recipe=recipe)
            break
    limits.enter('verification')
    # Recreate every initial scene from a NEW game, not a saved search memory.
    selected=sorted(entries,key=lambda e:(e['recipe']['phase'],e['id']))[:4]
    distinct={digest(e['recipe']):e for e in selected}
    fresh=NativeBackend(args.capture,earliest,limits); verified=[]
    for entry in distinct.values():
        result=replay_suffix(fresh,entry['recipe'],limits.check)
        if result['historyDigest'] != entry['result']['historyDigest']:
            raise RuntimeError('Fresh replay mismatch')
        verified.append(dict(id=entry['id'],phase=entry['recipe']['phase'],
                             updates=result['updates'],historyDigest=result['historyDigest'],
                             success=result['success'],samples=result['samples'],events=result['events']))
    # Diagnose high crawlers separately; failed suffixes NEVER become parents.
    diagnostic_entries = [t for t in trials if t['recipe']['actor'] is not None
        and t['result']['before130'] is not None
        and t['result']['before130']['action'] == CRAWLING
        and t['result']['before130']['movement'][1] > 1280.
        and t['result']['before130']['actor']['live']
        and t['result']['before130']['actor']['tangible']][:4]
    diagnostics = []
    for entry in diagnostic_entries:
        result = replay_suffix(fresh, entry['recipe'], limits.check)
        if result['historyDigest'] != entry['result']['historyDigest']:
            raise RuntimeError('Fresh diagnostic replay mismatch')
        diagnostics.append(dict(id=entry['id'], recipe=entry['recipe'], result=result))
    limits.enter('finalization')
    result=dict(schema=1,scope=__doc__,baseProofCommit='3d9db857bd078f554e269f608dbd896667e71f17',
        scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
        runtimeSha256=hashlib.sha256((ROOT/'build/wafel-pilot/sm64_jp.dll').read_bytes()).hexdigest(),
        captureSha256=hashlib.sha256(args.capture.read_bytes()).hexdigest(),
        options=dict(seed=args.seed,trials=args.trials,maxDepth=args.max_depth,archive=args.archive,seconds=args.seconds),
        observationLimit='Frame events and end-update fields; no live floor/ceiling-return hook or full-memory equality.',
        controls=controls,trials=trials,archive=entries,freshReplays=verified,
        diagnosticReplays=diagnostics,incompleteTrial=incomplete,
        summary=dict(completed=complete,stopReason=stop,successes=sum(t['result']['success'] for t in trials),
            cleanGameplaySuccesses=sum(t['result']['cleanGameplay'] for t in trials),
            earliestSuccessfulPhase=min(e['recipe']['phase'] for e in entries),
            deepestContinuousHandoffSuffix=131-min(e['recipe']['phase'] for e in entries),
            familyCounts=[dict(family=f,status=s,count=n) for (f,s),n in sorted(counts.items())],
            nativeUpdates=backend.total_updates+fresh.total_updates,
            freshReplayUpdates=sum(r['updates'] for r in verified),
            diagnosticReplayUpdates=sum(r['result']['updates'] for r in diagnostics)),timing=limits.finish())
    args.output.parent.mkdir(parents=True,exist_ok=True)
    with args.output.open('x',encoding='utf-8') as stream:
        json.dump(result,stream,indent=2,allow_nan=False); stream.write('\n')
    print(json.dumps(result['summary'],indent=2))
    return result


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path); p.add_argument('output',type=Path)
    p.add_argument('--trials',type=int,default=2200); p.add_argument('--seconds',type=float,default=120)
    p.add_argument('--seed',type=int,default=20261111); p.add_argument('--archive',type=int,default=16)
    p.add_argument('--max-depth',type=int,default=33)
    run(p.parse_args())


if __name__=='__main__': main()
