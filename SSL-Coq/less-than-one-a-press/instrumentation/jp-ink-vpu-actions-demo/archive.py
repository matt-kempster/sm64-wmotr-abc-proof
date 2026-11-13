"""Preserve compact durable evidence, without ROMs, binaries or screenshots."""
import hashlib
import json
from pathlib import Path

script = Path(__file__).resolve().parent
project = script.parents[1]

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

for name in ['crawl', 'slide', 'walk', 'x-slide', 'x-walk', 'xy-slide']:
    source = project / f'build/jp-ink-vpu-actions-{name}-20261113'
    dest = script / 'records' / name
    dest.mkdir(parents=True, exist_ok=True)
    receipt = json.loads((source / 'receipt.json').read_text())
    lines = []
    for line in (source / 'raw.log').read_text(errors='replace').splitlines():
        if line.startswith(('VPU_', 'RESULT,')):
            lines.append(line)
        elif 'Core: Captured screenshot for frame ' in line:
            lines.append(line[line.index('Core: Captured screenshot'):])
    (dest / 'trace.txt').write_text('\n'.join(lines) + '\n')
    for frame in receipt['frameMap']:
        frame.pop('state', None)  # State is losslessly keyed by completedInput.
    receipt['archive'] = dict(
        originalDirectory=str(source.relative_to(project)),
        originalReceiptSha256=sha(source / 'receipt.json'),
        traceSha256=sha(dest / 'trace.txt'),
        traceContents='All VPU records, screenshot core records, and final RESULT; unrelated prefix telemetry omitted.',
        screenshotContents='Hashes and time joins only. Original screenshots remain in the build directory.',
        validation='Read-only archived check validates preserved state transitions and frame joins; original image bytes require original-output check.')
    (dest / 'receipt.json').write_text(json.dumps(receipt, separators=(',', ':')) + '\n')
    print(dest)
