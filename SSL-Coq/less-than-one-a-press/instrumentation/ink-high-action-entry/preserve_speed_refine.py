"""Preserve both checked 48-recipe velocity batches without rerunning them."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
files={'directAirVelocity':('ink-high-shell-speed-refine-20261114.json','speed_refine.py'),'nativeAirPrelude':('ink-high-shell-native-speed-20261114.json','native_speed_refine.py')}
batches={}
for key,(name,script) in files.items():
    raw=ROOT/'build/wafel-pilot'/name;batch=json.loads(raw.read_text())
    assert batch['scriptSha256']==sha(ROOT/'instrumentation/ink-high-action-entry'/script)
    assert batch['actorHelperSha256']==sha(ROOT/'instrumentation/ink-high-action-entry/actor_cuts.py')
    batches[key]=dict(rawOutput=str(raw.relative_to(ROOT)),rawSha256=sha(raw),batch=batch)
source=ROOT.parents[2]/'reference-sm64-decomp'
receipt=dict(schema=1,date='2026-11-14',scope='Finite velocity refinements after supplied high airborne states and actor XYZ cuts. Direct initial forward/Cartesian edits do not initialize slideVelocity; the corrected batch runs one native airborne update before shell mounting. Neither batch reaches the target pad or useful handoff.',proofRevision='651c180e594e45c6825f9c4800da11f4afef0773',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtime='Wafel0.8.5 JP; Python3.9.13',sourceSha256={s:sha(source/s) for s in ['src/game/mario.c','src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/mario_step.c']},batches=batches)
out=ROOT/'docs/notes/ink-high-action-entry-speed-receipt.json'
with out.open('x',encoding='utf-8') as f:json.dump(receipt,f,separators=(',',':'),allow_nan=False);f.write('\n')
print(out,out.stat().st_size)
