"""Bind finite shell distance/status evidence and actual source dependencies."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1];DECOMP=ROOT.parents[2]/'reference-sm64-decomp'
def record(p,base):return dict(path=p.relative_to(base).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
local=[x for x in sorted(HERE.iterdir())if x.is_file()and x.name!='verification.json']
deps=[ROOT/'instrumentation/ink-shell-clone-isolation/test.py',ROOT/'instrumentation/ink-item-clone-controls/fixtures.py',ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz']
sources=[DECOMP/x for x in ['data/behavior_data.c','src/engine/behavior_script.c','src/game/behaviors/koopa_shell.inc.c','src/game/object_helpers.c','src/game/object_collision.c','src/game/interaction.c','src/game/mario_actions_moving.c']]
out=dict(schema=1,scope=__doc__,local=[record(x,ROOT)for x in local],inputs=[record(x,ROOT)for x in deps],source=[record(x,DECOMP)for x in sources])
target=HERE/'verification.json'
if a.verify:assert json.loads(target.read_bytes())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS',len(local),'local files,',len(deps),'inputs,',len(sources),'native source hashes')
