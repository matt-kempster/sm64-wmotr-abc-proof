"""Preserve the checked actor-cut batch without rerunning it."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
raw=ROOT/'build/wafel-pilot/ink-high-shell-actor-cuts-20261114-preserved.json'
batch=json.loads(raw.read_text())
assert batch['scriptSha256']==sha(ROOT/'instrumentation/ink-high-action-entry/actor_cuts.py')
source=ROOT.parents[2]/'reference-sm64-decomp'
receipt=dict(schema=1,date='2026-11-14',scope='Finite supplied-air and actor-XYZ cuts after a native shell-created slide; no controller-reachable initial setup or useful handoff found.',proofRevision='651c180e594e45c6825f9c4800da11f4afef0773',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtime='Wafel0.8.5 JP; Python3.9.13',rawOutput=str(raw.relative_to(ROOT)),rawSha256=sha(raw),sourceSha256={s:sha(source/s) for s in ['src/game/platform_displacement.c','src/game/object_list_processor.c','src/game/object_collision.c','src/game/interaction.c','src/game/mario.c','src/game/mario_step.c','src/game/mario_actions_moving.c','src/game/behaviors/pyramid_top.inc.c','src/game/behaviors/koopa_shell.inc.c']},batch=batch)
out=ROOT/'docs/notes/ink-high-action-entry-actor-cuts-receipt.json'
with out.open('x',encoding='utf-8') as f:json.dump(receipt,f,separators=(',',':'),allow_nan=False);f.write('\n')
print(out,out.stat().st_size)
