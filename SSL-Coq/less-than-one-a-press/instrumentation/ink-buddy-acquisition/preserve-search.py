"""Preserve and freshly replay the finite pilot branches and their exact inputs."""
import gzip,hashlib,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,advance,sample
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 archive=HERE/'search-records.json.gz'
 if '--prepare'in sys.argv:
  names=['talk','talk-v2','carry','transport','aftertalk']
  records={n:json.loads((ROOT/('build/wafel-pilot/buddy-acquisition-'+n+'.json')).read_text())for n in names}
  with gzip.GzipFile(filename=str(archive),mode='wb',mtime=0)as f:f.write((json.dumps(records,separators=(',',':'))+'\n').encode())
 else:records=json.loads(gzip.decompress(archive.read_bytes()))
 checks=[]
 for name,r in records.items():
  assert len(r['prefixInputs'])==r['prefixPolls']
  g=Guard(create_game());o=Observer(g)
  for p in r['prefixInputs']:advance(g,p)
  assert len(r['inputs'])==len(r['samples'])
  for i,(p,e)in enumerate(zip(r['inputs'],r['samples'])):
   advance(g,p);assert sample(g,o)==e,(name,i)
  checks.append(dict(name=name,prefixInputs=len(r['prefixInputs']),suffixInputs=len(r['inputs']),exactSampleCount=len(r['samples']),final=r['samples'][-1]))
 capture=ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl'
 sourcePrefix=dict(rows=2852,sha256='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72')
 if capture.exists():assert len(capture.read_text().splitlines())==sourcePrefix['rows']and digest(capture)==sourcePrefix['sha256']
 receipt=dict(passed=True,AInputs=0,postStartupGameWrites=0,sourcePrefix=sourcePrefix,archiveSha256=digest(archive),checks=checks)
 (HERE/'search-check.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode());print('PASS',len(checks),'fresh A-off histories',sum(x['exactSampleCount']for x in checks),'exact suffix samples')
if __name__=='__main__':main()
