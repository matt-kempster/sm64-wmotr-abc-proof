"""Freshly replay the native Fly Guy bounce and roof-crawl continuation."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from search import ROOT,Guard,create_game,Observer,advance,sample,dump,record

def main():
 d=json.load(gzip.open(record('flyguy-twirl-land-v1.json.gz')))
 t=next(t for t in d['trials']if t['recipe']==dict(prefix=2857,delay=0,target=[-2000,-1500]))
 controls=d['prefixInputs']+t['inputs']
 g=Guard(create_game());o=Observer(g);ss=[]
 for n,p in enumerate(controls):
  advance(g,p)
  if n>=348:ss.append(sample(g,o,n+1))
  if n+1>=2857:
   actual=sample(g,o,n+1);expected=t['samples'][n+1-2857]
   assert all(actual[k]==v for k,v in expected.items()),n
 dest=HERE/'native-roof-inputs.jsonl';dest.write_bytes((''.join(json.dumps(p,separators=(',',':'))+'\n'for p in controls)).encode())
 trace=HERE/'native-roof-samples.json.gz'
 if trace.exists():
  old=json.load(gzip.open(trace));assert len(old)==len(ss)
  assert all(all(a[k]==v for k,v in e.items())for a,e in zip(ss,old))
 else:dump(trace,ss)
 identity=HERE/'native-roof-identity.json.gz'
 if not identity.exists():dump(identity,[dict(n=s['n'],topNative=s['topNative'],topActive=s['topActive'],flyNative=s['fly']['native'],flyActive=s['fly']['active'])for s in ss])
 receipt=dict(inputs=len(controls),observations=len(ss),AInputs=0,gameplayWrites=0,
  startupGrant='debug level selection',source='actual controller replay, Wafel JP; original-ROM comparison recorded separately',
  inputsSha256=hashlib.sha256(dest.read_bytes()).hexdigest(),traceSha256=hashlib.sha256(trace.read_bytes()).hexdigest(),
  maxMarioY=max(s['M'][1]for s in ss if s['n']>=2740),
  final=ss[-1])
 (HERE/'native-roof-receipt.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
 print(json.dumps(receipt,indent=2))

if __name__=='__main__':main()
