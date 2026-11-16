"""Check hands-free HOLP observations, actual release kinds and finite limits."""
import argparse,collections,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 data=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()));ts=data['trials']
 retained=[t for t in ts if t['samples'][0]['held']==49]
 assert len(retained)==24 and all(t['samples'][0]['HOLP']!=t['beforeInitial']['HOLP']for t in retained)
 release_counts=collections.Counter()
 for t in ts:
  assert not t['laterGameplayEdits']and not t['capture']and not t['useful']
  f=t['firstRelease']
  if f is None:release_counts['stillHeld']+=1;continue
  b=f['sample']['actors']['49'];assert b['behavior']=='bhvJumpingBox'and b['oForwardVel']in[0,40]
  release_counts['throw'if b['oForwardVel']==40 else'drop']+=1
 immediate=[t for t in ts if t['recipe']['phase']==128]
 for t in immediate:
  assert t['samples'][0]['HOLP']==t['beforeInitial']['HOLP']
  assert t['samples'][0]['held']==-1 and t['samples'][0]['actionName']=='ACT_BUTT_SLIDE'
  b=t['samples'][1]['actors']['49'];assert b['behavior']=='bhvJumpingBox'and b['activeFlags']==0
  assert t['samples'][1]['boxMoveFlags']&1
  assert t['samples'][2]['floorY']==768 and 49 not in t['samples'][2]['collisions']
  assert t['arrival']['M']==[0,5500,256]
 counts=dict(cases=len(ts),distinctInitialAndControlHistories=len({json.dumps([t['initialEdits'],t['controls']],sort_keys=True)for t in ts}),
  boundaries=sum(len(t['samples'])for t in ts),freshRoots=data['independentFreshRoots'],heldAfterFirstUpdate=len(retained),firstUpdateHOLPOverwrites=len(retained),
  releaseKinds=dict(release_counts),useful=0,capture=0,ordinary=sum(t['arrival']is not None for t in ts))
 assert counts==dict(cases=48,distinctInitialAndControlHistories=44,boundaries=2016,freshRoots=2,heldAfterFirstUpdate=24,firstUpdateHOLPOverwrites=24,releaseKinds=dict(drop=45,stillHeld=1,throw=2),useful=0,capture=0,ordinary=8)
 sources=['src/game/mario_misc.c','src/game/rendering_graph_node.c','actors/mario/geo.inc.c','src/game/mario_actions_airborne.c','src/game/interaction.c','src/game/behaviors/jumping_box.inc.c']
 out=dict(schema=1,scope=__doc__,counts=counts,
  initialActionCases=[dict(recipe=t['recipe'],initialHOLP=t['beforeInitial']['HOLP'],firstHOLP=t['samples'][0]['HOLP'],firstAction=t['samples'][0]['actionName'],firstHeld=t['samples'][0]['held'],firstRelease=t['firstRelease']['update']if t['firstRelease']else None)for t in ts],
  sourceSha256={s:sha(ROOT.parents[2]/'reference-sm64-decomp'/s)for s in sources},
  files={n:sha(HERE/n)for n in ['check.py','results.json.gz','README.md','analyze.py','.gitattributes']})
 dst=HERE/'analysis.json'
 if a.verify:assert json.loads(dst.read_bytes())==out
 else:assert not dst.exists();dst.write_bytes((json.dumps(out,indent=2)+'\n').encode())
 print(json.dumps(counts));print('PASS hands-free HOLP, actual releases, deletion and source/artifact hashes')
if __name__=='__main__':main()
