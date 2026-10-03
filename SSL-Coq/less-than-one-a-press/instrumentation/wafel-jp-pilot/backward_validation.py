"""Concrete, context-conditioned inverse proposals and forward validation.

No symbolic engine and no input branching. The inverse mapper sees only the
target projection. Full prior contexts supply everything outside its two-field
patch. Acceptance means exact projection equality, never full-state equality
or controller reachability. Python 3.9+, standard library only.
"""
from copy import deepcopy
from dataclasses import dataclass, field
import math
import struct


FREEFALL = 0x0100088C
PATCH_FIELDS = frozenset(('y', 'vy'))


def bits(value):
    return struct.unpack('>I', struct.pack('>f', value))[0]


def number(word):
    if type(word) is not int or not 0 <= word <= 0xFFFFFFFF:
        raise ValueError('Expected a binary32 word')
    return struct.unpack('>f', struct.pack('>I', word))[0]


def f32(value):
    return number(bits(value))


@dataclass(frozen=True)
class Input:
    buttons: int = 0
    x: int = 0
    y: int = 0

    def __post_init__(self):
        if not (type(self.buttons) is int and 0 <= self.buttons <= 0xFFFF
                and type(self.x) is int and -128 <= self.x <= 127
                and type(self.y) is int and -128 <= self.y <= 127):
            raise ValueError('Invalid controller sample')

    def record(self):
        return dict(buttons=self.buttons, stick=[self.x, self.y])


@dataclass
class Checkpoint:
    frame: int
    observation: dict
    state: object = field(repr=False)  # Opaque FULL backend state, not the projection.


@dataclass(frozen=True)
class Candidate:
    name: str
    patch: dict  # binary32 words for exactly y, vy
    control: Input = Input()

    def __post_init__(self):
        if set(self.patch) != PATCH_FIELDS:
            raise ValueError('Every proposal must overwrite both inverse fields')
        if not all(math.isfinite(number(v)) for v in self.patch.values()):
            raise ValueError('Non-finite inverse proposal')


def freefall_predecessors(target, radius=2):
    """Finite hypotheses, NOT an exhaustive floating-point preimage.

    Generated JP perform_air_step has four rounded y += vy/4 quarters;
    apply_gravity's ordinary branch then subtracts 4. Invert those arithmetic
    operations approximately, enumerate nearby binary32 words, and let the
    real full-frame backend reject collisions, wind, clamps, and other paths.
    Nothing is read from the old y/vy or a recorded predecessor.
    """
    if type(radius) is not int or not 0 <= radius <= 4:
        raise ValueError('Keep the ULP search radius between zero and four')
    if target['area'] != 1 or target['action'] != FREEFALL:
        return []
    y, vy = number(target['y']), number(target['vy'])
    if not (math.isfinite(y) and -75.0 < vy < -4.0):
        return []  # Deliberately exclude terminal speed and the apex.
    center_v = bits(f32(vy + 4.0))
    offsets = [0] + [v for n in range(1, radius + 1) for v in (-n, n)]
    candidates = []
    for dv in offsets:
        old_v = number(center_v + dv)
        old_y = y
        for _ in range(4):
            old_y = f32(old_y - f32(old_v / 4.0))
        center_y = bits(old_y)
        for dy in offsets:
            word_y = center_y + dy
            if not 0 <= word_y <= 0xFFFFFFFF or not math.isfinite(number(word_y)):
                continue
            candidates.append(Candidate('freefall-ulp-v%+d-y%+d' % (dv, dy),
                                        dict(y=word_y, vy=bits(old_v))))
    return candidates


class RestoreFailure(RuntimeError):
    """The backend is no longer safe to reuse; do not continue searching."""


class Validator:
    """Backend: frame(), save_state(), load_state(), observe(), patch(), advance()."""
    def __init__(self, backend):
        self.backend = backend
        self.poisoned = False

    def capture(self):
        if self.poisoned:
            raise RestoreFailure('Validator is poisoned after a failed restore')
        return Checkpoint(self.backend.frame(), deepcopy(self.backend.observe()),
                          self.backend.save_state())

    def restore(self, saved):
        try:
            self.backend.load_state(saved.state)
            if (self.backend.frame() != saved.frame
                    or self.backend.observe() != saved.observation):
                raise ValueError('Restored boundary/projection mismatch')
        except Exception as exc:
            self.poisoned = True
            raise RestoreFailure('Full context restoration failed; stop this backend') from exc

    def replay(self, context, candidate, targets, controls=None):
        """Patch ONCE, run a continuous suffix, restore caller even on failure.

        Each target is a Checkpoint at the next exact frame boundary. Only its
        projection is compared. Its state token is NEVER loaded during replay.
        """
        if not targets:
            raise ValueError('At least one target is required')
        controls = tuple(controls) if controls is not None else (candidate.control,)
        if len(controls) != len(targets) or controls[0] != candidate.control:
            raise ValueError('Explicit controller suffix must match all edges')
        if any(t.frame != context.frame + i + 1 for i, t in enumerate(targets)):
            raise ValueError('Targets must be consecutive post-advance boundaries')
        caller = self.capture()
        ledger, samples = [], []
        predecessor = None
        try:
            self.restore(context)
            ledger.append(dict(op='restore-full-context', frame=context.frame))
            before = self.backend.observe()
            self.backend.patch(candidate.patch)
            ledger.append(dict(op='patch', frame=context.frame, mapping=candidate.name,
                               before={k: before[k] for k in sorted(PATCH_FIELDS)},
                               after=deepcopy(candidate.patch)))
            patched = self.backend.observe()
            expected = dict(before, **candidate.patch)
            if patched != expected:
                raise ValueError('Patch altered the projection outside its declared fields')
            predecessor = self.capture()
            for control, target in zip(controls, targets):
                begin = self.backend.frame()
                timer = self.backend.observe()['timer']
                ledger.append(dict(op='input-and-advance', frame=begin,
                                   input=control.record()))
                self.backend.advance(control)
                actual = self.backend.observe()
                if (self.backend.frame() != begin + 1
                        or actual['timer'] != ((timer + 1) & 0xFFFFFFFF)):
                    raise ValueError('Advance crossed an unexpected frame/timer boundary')
                differences = {k: dict(expected=target.observation.get(k), actual=actual.get(k),
                                       expectedPresent=k in target.observation, actualPresent=k in actual)
                               for k in sorted(set(actual) | set(target.observation))
                               if (k not in actual or k not in target.observation
                                   or actual[k] != target.observation[k])}
                samples.append(dict(frame=self.backend.frame(), differences=differences))
                if differences:
                    return dict(status='rejected', predecessor=predecessor,
                                ledger=ledger, samples=samples)
            return dict(status='accepted-projection', predecessor=predecessor,
                        ledger=ledger, samples=samples)
        except RestoreFailure:
            raise
        except Exception as exc:
            return dict(status='error', error=type(exc).__name__ + ': ' + str(exc),
                        predecessor=predecessor, ledger=ledger, samples=samples)
        finally:
            # Also restore when a write/advance/read raises or an edge rejects.
            self.restore(caller)


def public_trial(result):
    """Runtime state handles cannot be serialized or confused with observations."""
    return {key: value for key, value in result.items() if key != 'predecessor'}


def search_two_edges(validator, contexts, target, radius=2):
    """N -> N-1 -> N-2; accepted local edges still require unpatched replay.

    contexts are full states at N-2 and N-1. Their y/vy values are never passed
    to the inverse mapper. Their unmodified complement is a supplied condition.
    Try alternatives if an accepted local pair fails continuous replay.
    """
    if len(contexts) != 2 or [c.frame for c in contexts] != [target.frame-2, target.frame-1]:
        raise ValueError('Need exactly the two prior full-frame contexts')
    report = dict(status='no-chain-in-candidate-budget', trials=[], chain=None)
    for last in freefall_predecessors(target.observation, radius):
        edge1 = validator.replay(contexts[1], last, [target])
        report['trials'].append(dict(stage='N-1', candidate=last.name, **public_trial(edge1)))
        if edge1['status'] == 'error':
            report['status'] = 'backend-error'; return report
        if edge1['status'] != 'accepted-projection':
            continue
        intermediate = edge1['predecessor']
        for first in freefall_predecessors(intermediate.observation, radius):
            edge2 = validator.replay(contexts[0], first, [intermediate])
            report['trials'].append(dict(stage='N-2', candidate=first.name, **public_trial(edge2)))
            if edge2['status'] == 'error':
                report['status'] = 'backend-error'; return report
            if edge2['status'] != 'accepted-projection':
                continue
            chain = validator.replay(contexts[0], first, [intermediate, target],
                                     [first.control, last.control])
            report['trials'].append(dict(stage='continuous-replay', **public_trial(chain)))
            if chain['status'] == 'error':
                report['status'] = 'backend-error'; return report
            if chain['status'] == 'accepted-projection':
                report.update(status='two-edge-projection-chain', chain=public_trial(chain))
                return report
    return report
