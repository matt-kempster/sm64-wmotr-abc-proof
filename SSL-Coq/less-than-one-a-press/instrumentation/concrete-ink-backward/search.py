"""Bounded, concrete reverse proposals from the timer-131 Ink checkpoint.

No SMT and no forward input tree. Target-derived finite inverse moves are
validated against Wafel, using separately supplied full scene contexts.
Selected-field equality, supplied histories and a finite move menu are
explicit limitations. Rejection is never an all-gameplay exclusion.
"""
import argparse
from collections import Counter
from dataclasses import dataclass, replace
import hashlib
import json
from pathlib import Path
import statistics
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(ROOT / 'instrumentation/wafel-jp-pilot'))
from backward_validation import Input, bits, f32, number
from backward_wafel import WafelBackend
from replay import create_game, Observer, load_capture, set_input, RUNTIME
from controller_inputs import A_BUTTON, AXES, InputSpace

IDLE, WALKING, FREEFALL, DIALOG, DISAPPEARED = (
    0x0C400201, 0x04000440, 0x0100088C, 0x20001305, 0x1300)
CONTROLS = tuple(InputSpace())
POSE_FIELDS = ('movement', 'collision', 'display', 'action', 'depth')
END_FIELDS = POSE_FIELDS + ('actionArg', 'usedSlot', 'floorHeight',
                           'floorOwner', 'platform')


def accepted_target(name):
    low = [bits(-2200.), bits(768.), bits(-1024.)]
    if name == 'low-display':
        movement = [low[0], bits(1861.), low[2]]
        display = list(low)
    elif name == 'raised-display':
        movement = [low[0], 1156733869, low[2]]
        display = list(movement)
    else:
        raise ValueError('Unknown installation target')
    return dict(movement=movement, collision=low, display=display)


def target_fixture(accepted):
    # This supplied control recognizes installation; it does not establish
    # that gameplay can construct the initial disagreement.
    movement = (accepted['movement'] if accepted['display'] == accepted['collision']
                else accepted['collision'])
    return dict(movement=list(movement), collision=list(accepted['collision']),
                display=list(accepted['display']), depth=bits(0.), vy=bits(0.),
                action=IDLE, actionState=0, actionArg=0, actionTimer=0)


def expand_templates(templates, controls):
    templates = tuple(templates)
    if getattr(controls, 'wide', False):
        for control in controls:
            for move in templates:
                yield replace(move, control=control)
    else:
        for move in templates:
            for control in controls:
                yield replace(move, control=control)


def target_install_moves(accepted, name, controls=CONTROLS):
    seen = set()
    templates = []
    for move in installation_templates(accepted):
        # Remove duplicate declared pose templates before lazy input expansion;
        # do not equate different hidden states or different inputs.
        if name == 'low-display':
            key = json.dumps(move.patch, sort_keys=True)
            if key in seen:
                continue
            seen.add(key)
        templates.append(move)
    yield from expand_templates(templates, controls)


@dataclass
class Saved:
    frame: int
    observation: dict
    state: object


@dataclass
class Move:
    name: str
    patch: dict
    control: Input
    role: str


class Backend(WafelBackend):
    def observe(self):
        result = super().observe()
        result['movement'] = [result.pop('x'), result.pop('y'), result.pop('z')]
        result.update(depth=bits(self.game.read('gMarioState.quicksandDepth')),
                      actionState=self.game.read('gMarioState.actionState'),
                      usedSlot=self.observer.slot(self.game.read('gMarioState.usedObj')))
        return result

    def capture(self):
        return Saved(self.frame(), self.observe(), self.save_state())

    def restore(self, saved):
        self.load_state(saved.state)
        if self.frame() != saved.frame or self.observe() != saved.observation:
            raise RuntimeError('Context restore failed; abort this backend')

    def patch(self, patch):
        allowed = {'movement', 'collision', 'display', 'vy', 'depth', 'action',
                   'actionState', 'actionArg', 'actionTimer'}
        if not set(patch) <= allowed:
            raise ValueError('Undeclared patch field')
        for key in ('movement', 'collision', 'display'):
            if key not in patch:
                continue
            for axis, word in enumerate(patch[key]):
                path = ('gMarioState.pos[%d]' % axis if key == 'movement' else
                        'gMarioObject.oPos' + 'XYZ'[axis] if key == 'collision' else
                        'gMarioObject.header.gfx.pos[%d]' % axis)
                self.game.write(path, number(word))
        for key, path in (('vy', 'vel[1]'), ('depth', 'quicksandDepth'),
                          ('action', 'action'), ('actionState', 'actionState'),
                          ('actionArg', 'actionArg'), ('actionTimer', 'actionTimer')):
            if key in patch:
                self.game.write('gMarioState.' + path,
                                number(patch[key]) if key in ('vy', 'depth') else patch[key])
        actual = self.observe()
        if any(actual[key] != value for key, value in patch.items()):
            raise RuntimeError('Declared patch failed its readback')


def differences(actual, target, fields):
    return {key: {'expected': target[key], 'actual': actual[key]}
            for key in fields if actual[key] != target[key]}


def replay(backend, context, move, checkpoints, controls, endpoint_event=None, held_a=False):
    """One initial context restore and patch; no intermediate state operations."""
    if len(checkpoints) != len(controls) or controls[0] != move.control:
        raise ValueError('Invalid continuous suffix')
    caller = backend.capture()
    try:
        backend.restore(context)
        backend.patch(move.patch)
        predecessor = backend.capture()
        ledger = [{'op': 'restore-context', 'frame': context.frame},
                  {'op': 'patch', 'frame': context.frame, 'fields': move.patch}]
        samples = []
        if held_a and not predecessor.observation.get('buttonDown', 0) & A_BUTTON:
            return {'status': 'rejected-a-history', 'reason': 'A was not already down',
                    'ledger': ledger}, None
        for i, (target, control) in enumerate(zip(checkpoints, controls)):
            before = backend.frame()
            timer = backend.observe()['timer']
            backend.advance(control)
            if backend.frame() != before + 1 or backend.observe()['timer'] != timer + 1:
                raise RuntimeError('Unexpected update boundary')
            actual = backend.observe()
            diff = differences(actual, target.observation,
                               END_FIELDS if i == len(checkpoints) - 1 else POSE_FIELDS)
            samples.append({'frame': backend.frame(), 'differences': diff})
            ledger.append({'op': 'advance', 'frame': before, 'input': control.record()})
            if held_a:
                samples[-1]['aHistory'] = {key: actual[key] for key in ('buttonDown', 'buttonPressed')}
                if not actual['buttonDown'] & A_BUTTON or actual['buttonPressed'] & A_BUTTON:
                    return {'status': 'rejected-a-history', 'reason': 'A released or newly pressed',
                            'samples': samples, 'ledger': ledger}, None
            if diff:
                return {'status': 'rejected', 'samples': samples, 'ledger': ledger}, None
        events = [e for e in backend.game.frame_log()
                  if e['type'] == 'FLT_EXECUTE_ACTION' and e['action'] == DISAPPEARED]
        if len(events) != 1 or (endpoint_event is not None and
                                [bits(v) for v in events[0]['pos']] != endpoint_event):
            return {'status': 'rejected-event', 'events': events, 'ledger': ledger}, None
        return {'status': 'accepted-projection', 'samples': samples, 'ledger': ledger,
                'actionEntryWords': [bits(v) for v in events[0]['pos']]}, predecessor
    finally:
        backend.restore(caller)


def install_moves(accepted, controls=CONTROLS):
    yield from expand_templates(installation_templates(accepted), controls)


def installation_templates(accepted):
    """Invert the supplied retry checkpoint, rather than loading its earlier pose."""
    for y in (number(accepted['collision'][1]), 767., 769., 1201., 1202., 1861.):
        movement = list(accepted['collision']); movement[1] = bits(y)
        patch = dict(movement=movement, collision=accepted['collision'],
                     display=accepted['display'], depth=bits(0.), vy=bits(0.),
                     action=IDLE, actionState=0, actionArg=0, actionTimer=0)
        yield Move('pre-action-retry-y-%g' % y, patch, Input(), 'inherits supplied display')
    # Successful first lookup does not read the old display. Keep this separate
    # State-only split rather than imposing an unnecessary high display.
    patch = dict(movement=[accepted['collision'][0], bits(1861.), accepted['collision'][2]],
                 collision=accepted['collision'], display=accepted['collision'],
                 depth=bits(0.), vy=bits(0.), action=IDLE, actionState=0,
                 actionArg=0, actionTimer=0)
    yield Move('successful-query-state-only-y-1861', patch, Input(),
               'high movement with low collision and normal low display')


def previous_moves(target, controls=CONTROLS):
    yield from expand_templates(previous_templates(target), controls)


def previous_templates(target):
    """Finite stock ground/freefall/dialog arithmetic hypotheses, not coverage.

    The full update decides floor selection, clamps, interaction, action
    cancellation and movement; these inverse proposals do not override them.
    Mario is unmounted in the supplied contexts. No sound/callback is skipped.
    """
    movement, collision, display = [list(target[k]) for k in
                                    ('movement', 'collision', 'display')]
    y = number(movement[1]); gap = number(display[1]) - y
    depths = (0., f32(-gap))
    for old_y in (y, 1202., 1280.):
        old_pos = list(movement); old_pos[1] = bits(old_y)
        for old_display in (old_pos, display):
            for depth in depths:
                patch = dict(movement=old_pos, collision=collision, display=old_display,
                             action=IDLE, actionState=0, actionArg=0, actionTimer=0,
                             depth=bits(depth), vy=bits(0.))
                yield Move('ground-copy-y-%g-depth-%g' % (old_y, depth), patch, Input(),
                           'normal ground copy plus final sink hypothesis')
    for speed in (-75., -16., -4., 0., 4.):
        old_y = y
        for _ in range(4):
            old_y = f32(old_y - f32(speed / 4.))
        old_pos = list(movement); old_pos[1] = bits(old_y)
        for old_display in (old_pos, display):
            for depth in depths:
                patch = dict(movement=old_pos, collision=collision, display=old_display,
                             action=FREEFALL, actionState=0, actionArg=0, actionTimer=0,
                             depth=bits(depth), vy=bits(speed))
                yield Move('freefall-copy-v-%g-depth-%g' % (speed, depth), patch, Input(),
                           'four air quarters followed by copy/sink hypothesis')
    for depth in (0., f32(-gap / 30.), f32(-gap)):
        old_display = list(display)
        old_display[1] = bits(f32(number(display[1]) + depth))
        patch = dict(movement=movement, collision=collision, display=old_display,
                     action=DIALOG, actionState=24, actionTimer=0, actionArg=0,
                     depth=bits(depth), vy=bits(0.))
        yield Move('dialog-final-sink-depth-%g' % depth, patch, Input(),
                   'final automatic-dialog update and its sink hypothesis')


def prepare(backend, rows, horizon, context_control=Input(), history_log=None):
    for row in rows[:360]:
        set_input(backend.game, row); backend.game.advance()
    if backend.game.read('gCurrAreaIndex') != 1:
        raise RuntimeError('Expected accepted SSL entry context')
    backend.game.write('gObjectPool[61].oPyramidTopPillarsTouched', 4)
    saved = []
    while True:
        saved.append(backend.capture())
        g = backend.game
        if g.read('gObjectPool[61].oAction') == 1 and g.read('gObjectPool[61].oTimer') == 131:
            break
        backend.advance(context_control)
        if history_log is not None and backend.observe()['buttonPressed'] & A_BUTTON:
            history_log.append(dict(frame=backend.frame(), buttonPressed=backend.observe()['buttonPressed']))
        if backend.frame() > 600:
            raise RuntimeError('No timer-131 context')
    if len(saved) < horizon or not backend.game.read('gMarioPlatform').is_null():
        raise RuntimeError('Missing unmounted scene contexts')
    result = saved[-horizon:]
    if context_control.buttons & A_BUTTON and any(
            not s.observation['buttonDown'] & A_BUTTON for s in result):
        raise RuntimeError('Selected context does not already hold A')
    return result


def run(args):
    started = time.perf_counter()
    capture = RUNTIME / 'capture.bKv95w/inputs.jsonl'
    input_space = InputSpace(getattr(args, 'sticks', 'sampled'),
                             getattr(args, 'buttons', 'bz'), getattr(args, 'a_mode', 'released'))
    context_control = Input(A_BUTTON if input_space.a_mode == 'held' else 0)
    history_log = []
    game = create_game(); backend = Backend(game, Observer(game))
    contexts = prepare(backend, load_capture(capture), args.depth, context_control, history_log)
    preparation_seconds = time.perf_counter() - started
    scene = contexts[-1]
    target_name = getattr(args, 'target', 'raised-display')
    accepted = accepted_target(target_name)
    # Supplied mechanics control, used only to recognize the target outcome.
    backend.restore(scene); backend.patch(target_fixture(accepted))
    setup = backend.capture(); backend.advance(context_control); endpoint = backend.capture()
    events = [e for e in game.frame_log() if e['type'] == 'FLT_EXECUTE_ACTION']
    if (len(events) != 1 or events[0]['action'] != DISAPPEARED
            or [bits(v) for v in events[0]['pos']] != accepted['movement']
            or endpoint.observation['floorOwner'] != 61 or endpoint.observation['platform'] != 61
            or endpoint.observation['usedSlot'] != 64
            or endpoint.observation['actionArg'] != 0x40001):
        raise RuntimeError('Conditional Ink endpoint control failed')
    retention = []
    for _ in range(23):
        backend.advance(context_control)
        retention.append(dict(frame=backend.frame(), timer=game.read('gGlobalTimer'),
                              area=game.read('gCurrAreaIndex'),
                              platform=backend.observer.slot(game.read('gMarioPlatform')),
                              movement=[bits(v) for v in game.read('gMarioState.pos')]))
    if not any(r['area'] == 2 and r['movement'] ==
               [bits(365.5927734375), bits(5500.), bits(-1096.8026123046875)] for r in retention):
        raise RuntimeError('Conditional first Area-2 displacement control failed')
    backend.restore(scene)
    counts = Counter(); durations = []; first_rejections = []; accepted_edges = []
    frontier = []; distinct = set(); search_start = time.perf_counter()
    deadline = search_start + args.seconds
    stopped = None; deepest = 0

    rejection_counts = Counter()

    def trial(context, move, targets, controls, expected_event=None):
        nonlocal stopped
        if sum(counts.values()) >= args.candidates or time.perf_counter() >= deadline:
            stopped = 'candidate-budget' if sum(counts.values()) >= args.candidates else 'time-budget'
            return None, None
        before = time.perf_counter()
        result, predecessor = replay(backend, context, move, targets, controls, expected_event,
                                     held_a=input_space.a_mode == 'held')
        durations.append(time.perf_counter() - before); counts[result['status']] += 1
        if result['status'].startswith('rejected') and rejection_counts[len(targets)] < 8:
            rejection_counts[len(targets)] += 1
            first_rejections.append(dict(depth=len(targets), move=move.name, role=move.role,
                                         input=move.control.record(), result=result))
        return result, predecessor

    for move in target_install_moves(accepted, target_name, input_space):
        expected_event = accepted['movement'] if target_name == 'low-display' else None
        result, predecessor = trial(scene, move, [endpoint], [move.control], expected_event)
        if stopped:
            break
        if predecessor:
            key = tuple(tuple(predecessor.observation[k]) if isinstance(predecessor.observation[k], list)
                        else predecessor.observation[k] for k in POSE_FIELDS)
            if key not in distinct:
                distinct.add(key)
                if len(frontier) < args.beam:
                    frontier.append((predecessor, [endpoint], [move.control], result['actionEntryWords']))
                    accepted_edges.append(dict(depth=1, move=move.name, patch=move.patch,
                                               input=move.control.record(), result=result))
                deepest = 1
    layer_reports = [dict(depth=1, retained=len(frontier), distinctAccepted=len(distinct),
                          tested=sum(counts.values()), statuses=dict(counts))]
    for depth in range(2, args.depth + 1):
        if stopped or not frontier:
            break
        next_frontier = []; seen = set(); before_count = counts.copy()
        for target, suffix, suffix_controls, expected_event in frontier:
            context = contexts[-depth]
            for move in previous_moves(target.observation, input_space):
                result, predecessor = trial(context, move, [target] + suffix,
                                             [move.control] + suffix_controls, expected_event)
                if stopped:
                    break
                if predecessor:
                    key = tuple(tuple(predecessor.observation[k]) if isinstance(predecessor.observation[k], list)
                                else predecessor.observation[k] for k in POSE_FIELDS)
                    if key not in seen:
                        seen.add(key)
                        if len(next_frontier) < args.beam:
                            next_frontier.append((predecessor, [target] + suffix,
                                                  [move.control] + suffix_controls, expected_event))
                            accepted_edges.append(dict(depth=depth, move=move.name, patch=move.patch,
                                                       result=result))
                    deepest = depth
            if stopped:
                break
        layer_counts = counts - before_count
        layer_reports.append(dict(depth=depth, retained=len(next_frontier),
                                  distinctAccepted=len(seen), tested=sum(layer_counts.values()),
                                  statuses=dict(layer_counts)))
        frontier = next_frontier
    search_seconds = time.perf_counter() - search_start
    return dict(schema=1, backend='Wafel 0.8.5 JP', targetName=target_name,
                inputSpace=input_space.record(), aPreparationPresses=history_log,
                searchedContextButtonDown=[s.observation['buttonDown'] for s in contexts],
                aHistoryCondition=('One actual preparation press precedes the searched window; '
                                  'A remains down without another press in validated suffixes. '
                                  'This is not an A-never-pressed route.' if input_space.a_mode == 'held'
                                  else 'A released in the selected search alphabet'),
                requestedUpdates=args.depth,
                nominalSeconds=args.depth / 30., deepestValidatedUpdates=deepest,
                status=stopped or ('depth-reached' if deepest == args.depth else 'finite-frontier-empty'),
                preparationSeconds=preparation_seconds, searchSeconds=search_seconds,
                totalSeconds=time.perf_counter() - started,
                candidateLimit=args.candidates, timeLimitSeconds=args.seconds, beamLimit=args.beam,
                tested=sum(counts.values()), statuses=dict(counts), layers=layer_reports,
                trialSeconds=dict(min=min(durations), median=statistics.median(durations),
                                  max=max(durations), sum=sum(durations)),
                endpoint=dict(acceptedCheckpoint=accepted, actionEntryEvent=events[0],
                              setupFrame=setup.frame, endpointFrame=endpoint.frame,
                              setup=setup.observation, afterUpdate=endpoint.observation,
                              retention=retention), acceptedEdges=accepted_edges,
                firstRejections=first_rejections,
                compared=dict(parentFields=POSE_FIELDS, finalFields=END_FIELDS,
                              actionEntry='ACT_DISAPPEARED and exact movement words from frame log'),
                boundaryCaveat='Wafel logs movement at disappeared-action entry. Collision/display at '
                               'the accepted return require the separate exact emulator observer.',
                contextCondition='Other full-state values use the scene prepared with centered stick '
                                 'and the configured A setting at corresponding times after supplied '
                                 'pillar completion. The pose/depth/action patches '
                                 'are conditional proposals, not controller-reached states.',
                coverage='Selected lazy controller alphabet and finite pose menu. Budgets and pose '
                         'grouping restrict the tested subset. Not all binary32 values, actions, '
                         'support, prior scene histories or physically realizable controller histories.',
                grouping='Equal declared predecessor poses retain the first validated input suffix. '
                         'Other suffixes are sampled but not proved equivalent in omitted state.',
                pricing='Measured price of this context-conditioned finite tree only. An empty frontier '
                        'does not price or exclude every one-second Ink predecessor.',
                sourceHashes={name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in
                              ('instrumentation/concrete-ink-backward/controller_inputs.py',
                               'generated/jp_game_init.v', 'generated/us_game_init.v',
                               'generated/jp_mario.v', 'generated/us_mario.v',
                               'generated/jp_mario_actions_cutscene.v', 'generated/us_mario_actions_cutscene.v',
                               'generated/jp_object_list_processor.v', 'generated/us_object_list_processor.v')},
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                dllSha256=hashlib.sha256((RUNTIME / 'sm64_jp.dll').read_bytes()).hexdigest())


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--target', choices=('raised-display', 'low-display'), default='raised-display')
    p.add_argument('--depth', type=int, default=30)
    p.add_argument('--candidates', type=int, default=9000)
    p.add_argument('--seconds', type=float, default=90)
    p.add_argument('--beam', type=int, default=6)
    p.add_argument('--sticks', choices=('sampled', 'encoded'), default='sampled')
    p.add_argument('--buttons', choices=('bz', 'all-non-a'), default='bz')
    p.add_argument('--a-mode', choices=('released', 'held'), default='released')
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    if not 1 <= args.depth <= 30 or args.candidates < 1 or args.seconds <= 0 or args.beam < 1:
        p.error('Positive budgets, with depth between one and thirty')
    report = run(args)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps({k: report[k] for k in ('status', 'inputSpace', 'aPreparationPresses',
                                          'requestedUpdates', 'deepestValidatedUpdates',
                                           'tested', 'searchSeconds', 'totalSeconds', 'layers')}))


if __name__ == '__main__':
    main()
