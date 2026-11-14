"""Preserve checked high delayed-shell batches without rerunning them."""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
files={'lateMenu':('ink-high-delayed-shell-20261114-final.json','search.py'),'earlyControl':('ink-high-delayed-shell-early-20261114.json','early.py')};batches={}
for key,(name,script) in files.items():
    raw=ROOT/'build/wafel-pilot'/name;batch=json.loads(raw.read_text())
    assert batch['scriptSha256']==sha(ROOT/'instrumentation/ink-high-delayed-shell'/script)
    if key=='earlyControl':assert batch['helperSha256']==sha(ROOT/'instrumentation/ink-high-delayed-shell/search.py')
    batches[key]=dict(rawOutput=str(raw.relative_to(ROOT)),rawSha256=sha(raw),batch=batch)
source=ROOT.parents[2]/'reference-sm64-decomp'
result=dict(schema=1,date='2026-11-14',scope='Native JP Wafel high unloaded-top delayed shell cancellation/recovery; supplied initial airborne Mario/shell and optional later box XYZ only. No high common-slide/crawl execution or useful handoff in the bounded menu.',proofRevision='77ed7515d9ddce96fe00a030a26aae8663b590b0',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtime='Wafel0.8.5 JP; Python3.9.13',sourceSha256={s:sha(source/s) for s in ['src/game/mario.c','src/game/mario_step.c','src/game/mario_actions_moving.c','src/game/mario_actions_stationary.c','src/game/mario_actions_airborne.c','src/game/interaction.c','src/game/behaviors/koopa_shell.inc.c']},helpersSha256={s:sha(ROOT/'instrumentation/wafel-jp-pilot'/s) for s in ['ink_floorless_warp.py','ink_slide_handoff.py','ink_crawl_predecessors.py','ink_timer130_crawl.py','ink_pu_vpu.py','replay.py']},batches=batches)
out=ROOT/'docs/notes/ink-high-delayed-shell-receipt.json'
with out.open('x',encoding='utf-8') as f:json.dump(result,f,separators=(',',':'),allow_nan=False);f.write('\n')
print(out,out.stat().st_size)
