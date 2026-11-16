"""Check the initial cap flag, native hand model and exact HOLP preservation."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 d=json.loads(gzip.decompress((HERE/'cap-results.json.gz').read_bytes()));ts=d['trials']
 for t in ts:
  assert not t['laterGameplayEdits']and not t['capture']and not t['useful']
  i=t['firstRelease']['update']-t['recipe']['phase'];b=t['firstRelease']['sample']['actors']['49']
  assert b['behavior']=='bhvJumpingBox'and b['oForwardVel']==40
  if t['recipe']['capInHand']:
   assert all(s['HOLP']==t['beforeInitial']['HOLP']and s['bodyHandState']==3 for s in t['samples'][:i+1])
  else:assert t['samples'][0]['HOLP']!=t['beforeInitial']['HOLP']
 assert len(ts)==5 and sum(len(t['samples'])for t in ts)==225
 files=['cap-control.py','cap-results.json.gz','CAP-CONTROL.md','analyze-cap.py','check.py']
 sources=['src/game/mario.c','src/game/mario_misc.c','src/game/rendering_graph_node.c','actors/mario/geo.inc.c']
 out=dict(schema=1,cases=5,boundaries=225,freshRoots=d['independentFreshRoots'],capHOLPPreservations=4,ordinaryHOLPOverwrite=1,useful=0,
  files={n:sha(HERE/n)for n in files},sources={n:sha(ROOT.parents[2]/'reference-sm64-decomp'/n)for n in sources})
 dst=HERE/'cap-verification.json'
 if a.verify:assert json.loads(dst.read_bytes())==out
 else:assert not dst.exists();dst.write_bytes((json.dumps(out,indent=2)+'\n').encode())
 print('PASS four cap-preserved real throws/one ordinary changed-HOLP throw;225 boundaries twice;artifact/source hashes')
if __name__=='__main__':main()
