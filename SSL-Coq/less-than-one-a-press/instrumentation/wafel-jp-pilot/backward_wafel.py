"""Opt-in Wafel JP two-frame pilot. Never launches or installs an emulator.

Run only with the existing authenticated Wafel runtime and a private capture.
This module can be imported for API-contract tests without importing Wafel.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

# The installed Windows embeddable Python omits the script directory from
# sys.path. Add only this adapter's directory, without changing the runtime.
sys.path.insert(0, str(Path(__file__).resolve().parent))

from backward_validation import (FREEFALL, PATCH_FIELDS, Candidate, Input,
                                 Validator, bits, freefall_predecessors, number,
                                 public_trial, search_two_edges)


ROOT = Path(__file__).resolve().parents[2]


class WafelBackend:
    """Verified v0.8.5 Game API; exact comparison of a named projection only."""
    def __init__(self, game, observer):
        self.game, self.observer = game, observer

    def frame(self):
        return self.game.frame()

    def save_state(self):
        return self.game.save_state()

    def load_state(self, state):
        self.game.load_state(state)

    def observe(self):
        g = self.game
        result = self.observer.snapshot()
        if 'positions' not in result:
            raise ValueError('Pilot requires a live Mario in Area 1')
        positions = result.pop('positions')
        result.update(x=positions[0], y=positions[1], z=positions[2],
                      collision=positions[3:6], display=positions[6:9],
                      level=g.read('gCurrLevelNum'),
                      vx=bits(g.read('gMarioState.vel[0]')),
                      vy=bits(g.read('gMarioState.vel[1]')),
                      vz=bits(g.read('gMarioState.vel[2]')),
                      forwardVel=bits(g.read('gMarioState.forwardVel')),
                      flags=g.read('gMarioState.flags'),
                      actionArg=g.read('gMarioState.actionArg'),
                      rng=g.read('gRandomSeed16'),
                      buttonDown=g.read('gControllers[0].buttonDown'),
                      buttonPressed=g.read('gControllers[0].buttonPressed'),
                      pad=[g.read('gControllerPads[0].' + field)
                           for field in ('button', 'stick_x', 'stick_y')])
        return result

    def patch(self, patch):
        if set(patch) != PATCH_FIELDS:
            raise ValueError('Only the declared y/vy subset may be patched')
        for key, path in (('y', 'gMarioState.pos[1]'), ('vy', 'gMarioState.vel[1]')):
            self.game.write(path, number(patch[key]))

    def advance(self, control):
        for field, value in (('button', control.buttons), ('stick_x', control.x),
                             ('stick_y', control.y)):
            self.game.write('gControllerPads[0].' + field, value)
        self.game.advance()


def require_ordinary_ssl(observation):
    if (observation['level'] != 8 or observation['area'] != 1
            or observation['action'] != FREEFALL
            or not -71.0 < number(observation['vy']) < 0.0):
        raise ValueError('Choose an ordinary descending SSL Area-1 ACT_FREEFALL boundary')


def invalid_height_control(validator, context, target):
    """Perturb a target-derived proposal; require a concrete mismatch, not an error."""
    proposals = freefall_predecessors(target.observation, radius=0)
    if not proposals:
        raise ValueError('No ordinary freefall proposal for the rejection control')
    patch = dict(proposals[0].patch)
    patch['y'] = bits(number(patch['y']) + 64.0)
    invalid = Candidate('deliberate-invalid-height-plus-64', patch)
    trial = public_trial(validator.replay(context, invalid, [target]))
    if trial['status'] != 'rejected':
        raise ValueError('Invalid-height control did not produce a concrete rejection: '
                         + json.dumps(trial))
    return trial


def run_pilot(game, observer, rows, first_poll, radius=2):
    # Importing replay here intentionally requires the user's existing runtime.
    from benchmark_loop import require_match
    from replay import set_input
    if first_poll < 2 or first_poll + 2 > len(rows):
        raise ValueError('Need the reached prefix plus two advances and endpoint')
    if [r['poll'] for r in rows] != list(range(1, len(rows) + 1)):
        raise ValueError('Capture polls are not consecutive')
    prefix_checks = 0
    for row in rows[:first_poll - 1]:
        if 'positions' in row:
            require_match(observer.snapshot(), row)
            prefix_checks += 1
        set_input(game, row)
        game.advance()
    require_match(observer.snapshot(), rows[first_poll - 1])
    backend = WafelBackend(game, observer)
    validator = Validator(backend)
    reached = validator.capture()
    try:
        require_ordinary_ssl(reached.observation)
        # Short neutral forward trace is an ORACLE and context provider only.
        # Its y/vy predecessor values are not given to the inverse mapper.
        contexts = []
        for _ in range(2):
            contexts.append(validator.capture())
            backend.advance(Input())
            require_ordinary_ssl(backend.observe())
        target = validator.capture()
        # Determinism/restoration control: no pose write, same two inputs.
        validator.restore(reached)
        for expected in (contexts[1], target):
            backend.advance(Input())
            if backend.frame() != expected.frame or backend.observe() != expected.observation:
                raise ValueError('Unpatched baseline restore/replay did not match')
        result = search_two_edges(validator, contexts, target, radius)
        rejection_control = invalid_height_control(validator, contexts[1], target)
        return dict(schema=1, backend='Wafel 0.8.5 JP (concrete DLL runtime)',
                    verification='exact named projection; no full-state equality',
                    firstPoll=first_poll, startWafelFrame=reached.frame,
                    endWafelFrame=target.frame, prefixComparedSnapshots=prefix_checks,
                    oracle='two neutral advances from a controller-reached prefix',
                    restoreReplayControl='passed', projection=sorted(target.observation),
                    initialProjection=reached.observation, targetProjection=target.observation,
                    inverseFields=sorted(PATCH_FIELDS),
                    contextCondition='All other state comes from the respective full saved context',
                    reachability='Selected-field validation in supplied contexts; no claim of '
                                 'controller reachability for arbitrary patched candidates or Ink',
                    invalidPredecessorControl=rejection_control,
                    limits=dict(inverseUlpRadius=radius,
                                maxCandidatesPerInverse=(2 * radius + 1) ** 2,
                                prefixAdvances=first_poll - 1,
                                oracleAdvances=2, continuousReplayAdvances=2),
                    result=result)
    finally:
        validator.restore(reached)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path)
    p.add_argument('--first-poll', type=int, required=True,
                   help='Pre-input poll beginning two ordinary freefall updates')
    p.add_argument('--radius', type=int, choices=range(5), default=2)
    p.add_argument('--output', type=Path, required=True)
    args = p.parse_args()
    from replay import Observer, RUNTIME, create_game, load_capture
    game = create_game()  # Existing DLL SHA256 check and accepted startup only.
    report = run_pilot(game, Observer(game), load_capture(args.capture),
                       args.first_poll, args.radius)
    report.update(captureSha256=hashlib.sha256(args.capture.read_bytes()).hexdigest(),
                  librarySha256=hashlib.sha256((RUNTIME / 'sm64_jp.dll').read_bytes()).hexdigest(),
                  sourceSha256={name: hashlib.sha256(Path(__file__).with_name(name).read_bytes()).hexdigest()
                                for name in ('backward_wafel.py', 'backward_validation.py',
                                             'replay.py', 'benchmark_loop.py')})
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(report['result']['status'])
    if report['result']['status'] != 'two-edge-projection-chain':
        raise SystemExit(1)


if __name__ == '__main__':
    main()
