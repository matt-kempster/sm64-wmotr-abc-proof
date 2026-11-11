"""Validate the native capture and compare its logged projection to Wafel."""
import hashlib
import json
from pathlib import Path
import re
import struct
import sys

out = Path(sys.argv[1])
raw = (out / 'raw.log').read_text(errors='replace')
expected = json.loads((out / 'expected.json').read_text())
def fields(line):
    return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)', line))
def xyz(value):
    return [float(x) for x in value.strip('()').split(',')]
def f32(value):
    return struct.pack('>f', value)
def slot(value):
    address = int(value, 16)
    return -1 if address == 0 else (address-0x8033c118)//0x260

renders = [fields(l) for l in raw.splitlines() if l.startswith('HANDS_RENDER,')]
inputs = [fields(l) for l in raw.splitlines() if l.startswith('HANDS_INPUT,')]
writes = [fields(l) for l in raw.splitlines() if l.startswith('HANDS_WRITE,')]
assert 'HANDS_ERROR' not in raw
assert len(inputs) == 146 and len(writes) == 12
assert all(int(r['A']) == 0 and not int(r['buttons']) & 0x8000 for r in inputs)
assert all(not int(r['input']) & 0x82 for r in renders)
samples = expected['runup']['samples'] + expected['trial']['samples']
comparisons = []
timer_offsets = []
for index, want in enumerate(samples, 1):
    got = next(r for r in renders if int(r['step']) == index)
    differences = []
    timer_offsets.append(want['timer']-int(got['timer']))
    for field in ['area', 'topTimer', 'topAction']:
        if int(got[field]) != want[field]:
            differences.append(field)
    if int(got['action'], 16) != want['action']:
        differences.append('action')
    if slot(got['held']) != want['held']:
        differences.append('held')
    for key, target in [('state', 'movement'), ('collision', 'collision'),
                        ('display', 'display'), ('boxXYZ', 'boxPosition')]:
        if list(map(f32, xyz(got[key]))) != list(map(f32, want[target])):
            differences.append(target)
    if f32(float(got['floorY'])) != f32(want['floorY']):
        differences.append('floorY')
    comparisons.append(dict(step=index, differences=differences))
assert set(timer_offsets) == {2}, 'camera callback timer convention changed'

assert slot(next(r for r in renders if int(r['step']) == 7)['held']) == 49
assert int(next(r for r in renders if int(r['step']) == 24)['action'], 16) == 0x385
assert int(next(r for r in renders if int(r['step']) == 25)['action'], 16) == 0x840452
assert slot(next(r for r in renders if int(r['step']) == 25)['held']) == 49
assert not any(int(r['action'], 16) == 0x8ae for r in renders)
shots = sorted((out / 'shots').glob('*.png'))
receipt = dict(schema=1, scope='Original JP position-only fixture; not a clean no-A route',
    originalRomSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
    sourceWitnessSha256=expected['sourceSha256'],
    rawLogSha256=hashlib.sha256((out/'raw.log').read_bytes()).hexdigest(),
    traceSha256=hashlib.sha256((out/'trace.txt').read_bytes()).hexdigest(),
    inputUpdates=len(inputs), setupWordWrites=len(writes), cameraWrites=0,
    globalTimerConvention='Wafel after-advance timer equals this native camera-callback timer + 2 in all146 compared rows; absolute timer excluded from the equal projection.',
    globalTimerOffsets=sorted(set(timer_offsets)),
    comparisonFields=['area','topTimer','topAction','action','held',
        'movement','collision','display','boxPosition','floorY'],
    matchingProjectionSnapshots=sum(not c['differences'] for c in comparisons),
    comparedProjectionSnapshots=len(comparisons), differences=[c for c in comparisons if c['differences']],
    screenshotLatency='Requested at camera callback; image is preceding completed framebuffer. Image index1 corresponds to render row0. Initial image0 predates the runup.',
    screenshots=[dict(file=p.name, sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in shots],
    milestones=dict(nativeDiveAfterInput=6, suppliedPositionCutBeforeInput=7,
        nativePickupAfterInput=7, divePickingUpAfterInput=24,
        handsfreeButtSlideAfterInput=25, noCrazyBoxBounce=True),
    conclusion='Local hands-free carry reproduced from a supplied position cut; no high crawl or warp route established.')
(out/'receipt.json').write_text(json.dumps(receipt, indent=2)+'\n')
print(json.dumps({k:receipt[k] for k in ['inputUpdates','setupWordWrites','matchingProjectionSnapshots','comparedProjectionSnapshots','differences']}, indent=2))
