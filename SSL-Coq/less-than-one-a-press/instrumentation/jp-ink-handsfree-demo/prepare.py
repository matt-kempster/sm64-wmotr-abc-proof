"""Extract the recorded, position-only hands-free witness; no new state search."""
import hashlib
import json
from pathlib import Path
import sys

source, output = map(Path, sys.argv[1:])
record = json.loads(source.read_text())
focused = record['focusedDive']
trial = next(t for t in focused['trials']
             if (t['height'], t['boxDistance'], t['boxYOffset']) == (1741, 70, 0))
pads = focused['runup']['controls'] + trial['controls']
assert len(pads) == 146 and all(not p['buttons'] & 0x8000 for p in pads)
rows = [f"    {{{p['buttons']}, {p['stick'][0]}, {p['stick'][1]}}}," for p in pads]
(output / 'controls.h').write_text(
    'static const struct { unsigned buttons; int x, y; } demo_pads[] = {\n'
    + '\n'.join(rows) + '\n};\n')
(output / 'expected.json').write_text(json.dumps(dict(
    sourceSha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    baselineSha256=record['baselineSha256'], runup=focused['runup'], trial=trial
), indent=2) + '\n')
