"""Lazy raw-controller alphabets for concrete backward proposals."""
from dataclasses import dataclass
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'wafel-jp-pilot'))
from backward_validation import Input

A_BUTTON = 0x8000
AXES = ((0, 0), (-127, 0), (127, 0), (0, -127), (0, 127),
        (-127, -127), (-127, 127), (127, -127), (127, 127))
BZ_MASKS = (0, 0x4000, 0x2000, 0x6000)
# Actual declared N64 button bits, excluding A and reserved bits 6/7.
NON_A_BITS = (0x4000, 0x2000, 0x1000, 0x0800, 0x0400, 0x0200, 0x0100,
              0x0020, 0x0010, 0x0008, 0x0004, 0x0002, 0x0001)


def encoded_sticks():
    """Every signed-byte pair exactly once, with neutral first."""
    yield (0, 0)
    for x in range(-128, 128):
        for y in range(-128, 128):
            if x or y:
                yield (x, y)


def button_masks(mode):
    if mode == 'bz':
        yield from BZ_MASKS
    elif mode == 'all-non-a':
        for code in range(1 << len(NON_A_BITS)):
            yield sum(bit for index, bit in enumerate(NON_A_BITS) if code & (1 << index))
    else:
        raise ValueError('Unknown button alphabet')


@dataclass(frozen=True)
class InputSpace:
    sticks: str = 'sampled'
    buttons: str = 'bz'
    a_mode: str = 'released'

    def __post_init__(self):
        if self.sticks not in ('sampled', 'encoded'):
            raise ValueError('Unknown stick alphabet')
        if self.buttons not in ('bz', 'all-non-a'):
            raise ValueError('Unknown button alphabet')
        if self.a_mode not in ('released', 'held'):
            raise ValueError('Unknown A mode')

    @property
    def count(self):
        return (9 if self.sticks == 'sampled' else 65536) * (4 if self.buttons == 'bz' else 8192)

    @property
    def wide(self):
        return self.count > 36

    def __iter__(self):
        a = A_BUTTON if self.a_mode == 'held' else 0
        # Keep the historical 36 representatives first, without building
        # the much larger Cartesian product or dropping the rest.
        seeds = {(b | a, x, y) for b in BZ_MASKS for x, y in AXES}
        for b in BZ_MASKS:
            for x, y in AXES:
                yield Input(b | a, x, y)
        if not self.wide:
            return
        for b in button_masks(self.buttons):
            pairs = encoded_sticks() if self.sticks == 'encoded' else iter(AXES)
            for x, y in pairs:
                if (b | a, x, y) not in seeds:
                    yield Input(b | a, x, y)

    def record(self):
        return dict(sticks=self.sticks, buttons=self.buttons, aMode=self.a_mode,
                    stickPairs=9 if self.sticks == 'sampled' else 65536,
                    nonAMasks=4 if self.buttons == 'bz' else 8192,
                    choicesPerPose=self.count, lazy=True,
                    order='36 representatives first, then remaining encoded product',
                    widePoseOrder='all pose templates for each input',
                    coverage='Encoded samples, not physical-controller realizability or gameplay-history coverage')
