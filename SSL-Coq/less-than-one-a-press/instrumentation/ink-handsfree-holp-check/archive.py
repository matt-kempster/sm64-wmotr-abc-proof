"""Pin the real hands-free HOLP control, accepted inputs and native render source."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
def row(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
local=[p for p in sorted(HERE.iterdir())if p.is_file()and p.name!='verification.json']
deps=[ROOT/x for x in ['docs/notes/ink-clean-handsfree-receipt.json','instrumentation/wafel-jp-pilot/replay.py','instrumentation/wafel-jp-pilot/ink_box_delivery.py','instrumentation/wafel-jp-pilot/ink_clean_handsfree.py']]
native=ROOT.parents[2]/'reference-sm64-decomp/src/game/mario_misc.c'
out=dict(schema=1,scope=__doc__,files=[row(p)for p in local+deps],native=dict(path='../../../reference-sm64-decomp/src/game/mario_misc.c',bytes=native.stat().st_size,sha256=hashlib.sha256(native.read_bytes()).hexdigest()))
p=HERE/'verification.json'
if a.verify:assert json.loads(p.read_bytes())==out
else:p.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS',len(local),'packet files,',len(deps),'direct dependencies and native render source')
