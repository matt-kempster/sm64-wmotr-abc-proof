"""Verify the discrete shell-height retune and bind its records."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 d=json.loads(gzip.decompress((HERE/'retune-results.json.gz').read_bytes()));ts=d['results']['trials'];rows=[]
 for t in ts:
  c=t['continuation'];assert not c['laterGameplayEdits']and not c['capture']and not c['useful']
  assert not any(e['path'].startswith('gObjectPool[71]')for e in c['initialEdits'])
  assert c['samples'][0]['held']==-1 and c['samples'][0]['actors']['49']['oHeldState']==0
  assert t['nativeRelease']['samples'][-1]['shell']['position']==t['shellTarget']
  rows.append(dict(shellY=t['shellY'],marioY=c['recipe']['y'],firstAction=c['samples'][0]['actionName'],
   firstFloor=c['samples'][0]['floorY'],producerFloor=c['samples'][2]['floorY'],
   box128=c['samples'][0]['actors']['49'],box129=c['samples'][1]['actors']['49'],box130=c['samples'][2]['actors']['49'],
   arrival=c['arrival']['M']if c['arrival']else None))
 assert len(rows)==12 and sum(len(t['continuation']['samples'])for t in ts)==468
 assert [r['shellY']for r in rows if r['arrival']]==[1800,1840,1860,1880]
 assert all(r['arrival']is None or r['arrival']==[0,5500,256]for r in rows)
 out=dict(schema=1,scope=__doc__,cases=12,boundaries=468,independentFreshRoots=d['independentFreshRoots'],rows=rows,
  files={n:sha(HERE/n)for n in ['retune.py','retune-results.json.gz','RETUNE.md','analyze-retune.py','check.py']})
 dst=HERE/'retune-analysis.json'
 if a.verify:assert json.loads(dst.read_bytes())==out
 else:assert not dst.exists();dst.write_bytes((json.dumps(out,indent=2)+'\n').encode())
 print('PASS12 actual shell throws,468 suffix boundaries,4 ordinary/8 no arrival,zero captures; source/artifact hashes')
if __name__=='__main__':main()
