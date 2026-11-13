"""Collect checked independent original-ROM runs for the video renderer."""
import hashlib
import json
import subprocess
from pathlib import Path

project = Path(__file__).resolve().parents[2]
names = ['crawl', 'slide', 'walk', 'x-slide', 'x-walk', 'xy-slide']
out = project / 'build/vpu-video/original-rom-captures.json'
runs = []
for name in names:
    directory = project / f'build/jp-ink-vpu-actions-{name}-20261113'
    receipt_path = directory / 'receipt.json'
    receipt = json.loads(receipt_path.read_text())
    rows = receipt['renderStates']
    inactive = next((int(r['step']) for r in rows
                     if r['area'] == '1' and r['topActive'] == '0'
                     and r['platform'] == '803451f8'), None)
    keyframes = {}
    for label, step in [('walkingPreparation', 5), ('producer', 6),
                        ('captureOrFailure', 7), ('inactiveRetained', inactive),
                        ('firstArea2', receipt['milestones']['firstArea2Input']),
                        ('visibleUpperWalkway', 87)]:
        if step is None:
            continue
        image = next((f for f in receipt['frameMap'] if f['completedInput'] == step), None)
        if image:
            keyframes[label] = dict(completedInput=step, file=image['file'],
                                    framebufferTimer=image['framebufferTimer'],
                                    state=image['state'])
    runs.append(dict(name=name, directory=str(directory.relative_to(project)),
                     receipt=str(receipt_path.relative_to(project)),
                     receiptSha256=hashlib.sha256(receipt_path.read_bytes()).hexdigest(),
                     mode=receipt['mode'], setupWrites=receipt['setupWrites'],
                     milestones=receipt['milestones'], keyframes=keyframes))

def head(path):
    return subprocess.check_output(['git', '-C', str(path), 'rev-parse', 'HEAD'], text=True).strip()

payload = dict(schema=1, projectDirectory=str(project),
               proofRevision=head(project),
               decompileRevision=head(project.parents[2] / 'reference-sm64-decomp'),
               scope='Six fresh original JP-ROM emulator recordings with explicit supplied-state cuts; no clean controller route claim.',
               rendererAdvice='Use receipt.frameMap joins, not image index. First Area2 image is black during transition. Image085/input87 clearly shows the upper walkway in each successful run. High producer Mario is outside the stock camera; explain with a labeled schematic.',
               runs=runs)
out.parent.mkdir(parents=True, exist_ok=True)
out.write_text(json.dumps(payload, indent=2) + '\n')
print(out)
