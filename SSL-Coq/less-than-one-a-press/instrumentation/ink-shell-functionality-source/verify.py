"""Pin this source review and its actual C, generated AST and proof references.

Hash verification is evidence provenance, not a new semantic proof or build.
"""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
DECOMP=ROOT.parents[2]/'reference-sm64-decomp'
def record(path,base):
 return dict(path=path.relative_to(base).as_posix(),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest())
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
c=['data/behavior_data.c','src/game/behaviors/koopa_shell.inc.c',
   'src/game/object_helpers.c','src/game/interaction.c','src/game/interaction.h',
   'src/game/object_collision.c','src/game/mario_actions_moving.c',
   'src/engine/behavior_script.c','src/game/spawn_object.c','include/object_constants.h']
ast=['jp_behavior_data.v','jp_behavior_actions.v','jp_behavior_script.v',
     'jp_interaction.v','jp_object_helpers.v','jp_object_collision.v','jp_mario_actions_moving.v']
proofs=['InkBoxFloor.v','InkBoxFloorFrame.v','InkShellBridge.v','InkMarioEntryGuards.v','MainTheorem.v']
out=dict(schema=1,scope=__doc__,proofStart='4adf8faf311d1d271c57f288f51b06bf357874d1',
 stockJP='9921382a68bb0c865e5e45eb594d9c64db59b1af',localDecompile='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',
 local=[record(HERE/n,HERE)for n in ['README.md','.gitattributes','verify.py']],
 nativeSource=[record(DECOMP/n,DECOMP)for n in c],
 generated=[record(ROOT/'generated'/n,ROOT)for n in ast],
 existingProofs=[record(ROOT/'proofs'/n,ROOT)for n in proofs])
t=HERE/'verification.json'
if a.check:assert json.loads(t.read_bytes())==out
else:t.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS source-review provenance: 3 local files,10 native sources,7 generated ASTs,5 existing proof files')
