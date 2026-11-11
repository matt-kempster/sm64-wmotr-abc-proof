"""Convert an already validated complete controller sequence to C data."""
import hashlib
import json
from pathlib import Path
import sys

source, out = map(Path, sys.argv[1:])
pads = [json.loads(line) for line in source.read_text().splitlines() if line.strip()]
assert pads and all(not p['buttons'] & 0x8000 for p in pads)
rows = [f"    {{{p['buttons']}, {p['stick'][0]}, {p['stick'][1]}}}," for p in pads]
(out/'controls.h').write_text('static const struct { unsigned buttons; int x, y; } demo_pads[] = {\n'+'\n'.join(rows)+'\n};\n')
(out/'controller-source.json').write_text(json.dumps(dict(
    source=str(source), sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
    inputs=len(pads), aInputs=0, gameplayWrites=0), indent=2)+'\n')
(out/'inputs.jsonl').write_bytes(source.read_bytes())
