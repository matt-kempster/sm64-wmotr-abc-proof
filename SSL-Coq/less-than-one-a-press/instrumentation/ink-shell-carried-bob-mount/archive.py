"""Pin the final carried-Bob approach tests and exact direct predecessors."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
def row(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
local=[p for p in sorted(HERE.iterdir())if p.is_file()and p.name not in ['verification.json','pilot.json.gz']]
dependencies=[ROOT/x for x in ['instrumentation/ink-shell-remote-functionality/handoff.py','instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py','instrumentation/ink-mario-pusher-delivery/controlled-bob/test.py','instrumentation/ink-mario-pusher-delivery/controlled-box/check.py','instrumentation/ink-enlarged-bob-handoff/search.py','instrumentation/ink-bobomb-retimed-shoves/search.py','instrumentation/ink-shell-clone-isolation/test.py','instrumentation/ink-enlarged-bob-target/native.py','instrumentation/ink-enlarged-bob-profile/profile.py','instrumentation/ink-high-item-nudge/prefix.jsonl.gz']]
decomp=ROOT.parents[2]/'reference-sm64-decomp'
sources=[]
for name in ['src/game/interaction.c','src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/behaviors/bobomb.inc.c','src/game/behaviors/jumping_box.inc.c','src/game/object_helpers.c']:
 p=decomp/name;sources.append(dict(path='../../../reference-sm64-decomp/'+name,bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
out=dict(schema=1,scope=__doc__,files=[row(p)for p in local+dependencies],sources=sources);target=HERE/'verification.json'
if a.verify:assert json.loads(target.read_bytes())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS',len(local),'packet files,',len(dependencies),'dependencies,',len(sources),'native sources')
