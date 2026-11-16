"""Pin remote-release experiments and their exact direct predecessor inputs."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
def row(x):return dict(path=x.relative_to(ROOT).as_posix(),bytes=x.stat().st_size,sha256=hashlib.sha256(x.read_bytes()).hexdigest())
local=[x for x in sorted(HERE.iterdir())if x.is_file()and x.name!='verification.json']
deps=[ROOT/x for x in ['instrumentation/ink-shell-delivery/pending_slot.py','instrumentation/ink-buddy-replacement-delivery/inputs.jsonl','instrumentation/ink-shell-clone-isolation/test.py','instrumentation/ink-high-item-nudge/prefix.jsonl.gz','instrumentation/ink-enlarged-bob-handoff/search.py','instrumentation/ink-bobomb-retimed-shoves/search.py','instrumentation/ink-enlarged-bob-profile/profile.py']]
decomp=ROOT.parents[2]/'reference-sm64-decomp'
sources=[]
for name in ['src/game/interaction.c','src/game/mario_actions_moving.c','src/game/behaviors/koopa_shell.inc.c','src/game/object_helpers.c','data/behavior_data.c']:
 x=decomp/name;sources.append(dict(path='../../../reference-sm64-decomp/'+name,bytes=x.stat().st_size,sha256=hashlib.sha256(x.read_bytes()).hexdigest()))
out=dict(schema=1,scope=__doc__,files=[row(x)for x in local+deps],sources=sources);target=HERE/'verification.json';raw=(json.dumps(out,indent=2)+'\n').encode()
if a.verify:assert json.loads(target.read_bytes())==out
else:target.write_bytes(raw)
print('PASS',len(local),'local files,',len(deps),'direct dependencies and',len(sources),'native sources')
