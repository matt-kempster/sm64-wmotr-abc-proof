"""Check a fresh native replay against the committed original native trace."""
import hashlib
from pathlib import Path
import sys

mode, directory = sys.argv[1:]
assert mode in ('clean', 'supplied-handsfree', 'supplied-handoff')
root = Path(__file__).resolve().parents[2]
reference = root/'docs/media/ink-handsfree-native'/f'{mode}-trace.txt'
actual = Path(directory)/'trace.txt'
left, right = reference.read_text().splitlines(), actual.read_text().splitlines()
assert left == right, next(((i+1,a,b) for i,(a,b) in enumerate(zip(left,right)) if a!=b),
                          ('line-count',len(left),len(right)))
print(f'Native replay trace matches {len(left)} committed lines; '
      f'reference SHA256 {hashlib.sha256(reference.read_bytes()).hexdigest()}')
