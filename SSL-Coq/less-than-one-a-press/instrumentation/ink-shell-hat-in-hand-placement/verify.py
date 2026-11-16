"""Hash completed records and count stored observations; does not run the game."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args();runs=[]
 for name in ['results.json.gz','refine-results.json.gz']:
  d=json.loads(gzip.decompress((HERE/name).read_bytes()));ts=d['trials']
  assert all(not t['capture']and not t['useful']and not t['laterGameplayEdits']for t in ts)
  runs.append(dict(file=name,cases=len(ts),boundaries=sum(len(t['samples'])for t in ts),freshRoots=d['independentFreshRoots'],
   captures=0,useful=0,ordinaryArrivals=sum(t['arrival']is not None for t in ts)))
 out=dict(schema=1,scope='Completed evidence archived after user requested stopping; this checker never runs gameplay',runs=runs,
  sha256={n:sha(HERE/n)for n in ['search.py','refine.py','results.json.gz','refine-results.json.gz','README.md','.gitattributes','verify.py']})
 dst=HERE/'verification.json'
 if a.check:assert json.loads(dst.read_bytes())==out
 else:assert not dst.exists();dst.write_bytes((json.dumps(out,indent=2)+'\n').encode())
 print(json.dumps(runs));print('PASS stored-observation counts and artifact hashes; no gameplay executed')
if __name__=='__main__':main()
