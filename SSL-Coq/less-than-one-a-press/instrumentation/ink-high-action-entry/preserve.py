"""Combine already checked search outputs without rerunning native trials."""
import json,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
files={'shellPad':'ink-high-shell-pad-20261114.json','shellEdges':'ink-high-shell-edges-final-20261114.json','supportedPrelude':'ink-high-shell-prelude-20261114.json','supportedSeeds':'ink-high-shell-seeds-20261114.json'}
scripts=['search.py','edges.py','prelude.py','seeds.py']
helpers=['ink_slide_handoff.py','ink_floorless_warp.py','ink_crawl_predecessors.py','ink_timer130_crawl.py','ink_pu_vpu.py','replay.py']
batches={k:json.loads((ROOT/'build/wafel-pilot'/v).read_text()) for k,v in files.items()}
for k,s in zip(files,scripts):assert batches[k]['scriptSha256']==sha(ROOT/'instrumentation/ink-high-action-entry'/s)
r=dict(schema=1,date='2026-11-14',scope='Finite native JP Wafel supplied-air and actor experiments; no controller-reachable initial air/shell state or useful handoff established by these batches.',proofBase='651c180e594e45c6825f9c4800da11f4afef0773',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtime='Wafel0.8.5 JP; Python3.9.13',runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),rawOutputs={str(Path('build/wafel-pilot')/v):sha(ROOT/'build/wafel-pilot'/v) for v in files.values()},scripts={s:sha(ROOT/'instrumentation/ink-high-action-entry'/s) for s in scripts},helpers={s:sha(ROOT/'instrumentation/wafel-jp-pilot'/s) for s in helpers},batches=batches)
out=ROOT/'docs/notes/ink-high-action-entry-receipt.json'
with out.open('x',encoding='utf-8') as f:json.dump(r,f,separators=(',',':'),allow_nan=False);f.write('\n')
print(out, out.stat().st_size)
