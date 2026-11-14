"""Preserve completed pair/triple, necessity and floor-null controls.

The necessity batch's duplicated full histories are replaced by explicit
indices into its fullTrials array. No observations are discarded.
"""
import hashlib,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
files={'airAndControls':('ink-item-combinations-20261114-final.json','ink-item-combinations/search.py'),'necessaryGeometry':('ink-item-necessary-20261114-preserved.json','ink-item-combinations/necessary.py'),'floorNullPrimer':('ink-floor-null-primer-20261114.json','ink-high-delayed-shell/floor_null_primer.py')};batches={}
for key,(name,script) in files.items():
    raw=ROOT/'build/wafel-pilot'/name;batch=json.loads(raw.read_text())
    assert batch['scriptSha256']==sha(ROOT/'instrumentation'/script)
    if key=='necessaryGeometry':
        assert batch['helperSha256']==sha(ROOT/'instrumentation/ink-item-combinations/search.py')
        index={json.dumps(t['recipe'],sort_keys=True):i for i,t in enumerate(batch['fullTrials'])}
        for group in ['necessaryCases','matchedVpuCases']:
            rows=[]
            for case in batch[group]:
                row={k:v for k,v in case.items() if k not in ['original','removals']}
                row['originalTrial']=index[json.dumps(case['original']['recipe'],sort_keys=True)]
                row['removalTrials']=[index[json.dumps(t['recipe'],sort_keys=True)] for t in case['removals']]
                rows.append(row)
            batch[group]=rows
        batch['fullHistoryIndexConvention']='originalTrial/removalTrials index this batch fullTrials array, zero-based'
    batches[key]=dict(rawOutput=str(raw.relative_to(ROOT)),rawSha256=sha(raw),batch=batch)
source=ROOT.parents[2]/'reference-sm64-decomp'
r=dict(schema=1,date='2026-11-14',scope='Finite native JP Wafel item combinations. Primary high airborne-entry menu has no handoff; supplied butt-slide pair/triple geometries include useful handoffs with per-actor removal necessity. A separate native-entry/original-ROM branch is reported elsewhere.',proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',runtime='Wafel0.8.5 JP; Python3.9.13',fixtureSha256=sha(ROOT/'instrumentation/ink-item-clone-controls/fixtures.py'),sourceSha256={s:sha(source/s) for s in ['src/game/interaction.c','src/game/object_collision.c','src/game/mario.c','src/game/mario_step.c','src/game/mario_actions_moving.c','src/game/mario_actions_airborne.c','src/game/mario_actions_stationary.c','src/game/object_list_processor.c','src/game/platform_displacement.c','src/game/level_update.c','src/engine/surface_collision.c']},batches=batches)
out=ROOT/'docs/notes/ink-item-combinations-receipt.json'
with out.open('x',encoding='utf-8') as f:json.dump(r,f,separators=(',',':'),allow_nan=False);f.write('\n')
print(out,out.stat().st_size)
