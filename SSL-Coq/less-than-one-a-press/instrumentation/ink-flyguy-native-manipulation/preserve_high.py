"""Preserve the controller-reached intact-top high slide; no supplied gameplay state."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from search import ROOT,Guard,create_game,Observer,advance,sample,dump,record

def main():
 d=json.load(gzip.open(record('flyguy-pre-fourth-brake-v1.json.gz')))
 t=next(t for t in d['trials']if t['recipe']==dict(divisor=15,target=[-2150,-920]))
 controls=d['prefixInputs']+t['inputs'][:65]
 g=Guard(create_game());o=Observer(g);ss=[]
 for n,p in enumerate(controls):
  advance(g,p)
  if n>=348:ss.append(sample(g,o,n+1))
  if n+1>=2804:assert sample(g,o,n+1)==t['samples'][n+1-2804],n
 dest=HERE/'native-high-slide-inputs.jsonl';dest.write_bytes((''.join(json.dumps(p,separators=(',',':'))+'\n'for p in controls)).encode())
 trace=HERE/'native-high-slide-samples.json.gz'
 if trace.exists():assert json.load(gzip.open(trace))==ss
 else:dump(trace,ss)
 receipt=dict(inputs=len(controls),observations=len(ss),AInputs=0,gameplayWrites=0,
  startupGrant='debug level selection',source='actual controller replay, Wafel JP; original-ROM comparison recorded separately',
  creditedEarlierPrefix='ink-box-delivery.md before-fourth native Fire Fly Guy bounce to Y2099.5149',
  inputsSha256=hashlib.sha256(dest.read_bytes()).hexdigest(),traceSha256=hashlib.sha256(trace.read_bytes()).hexdigest(),
  milestones=[s for s in ss if s['n']in [2804,2823,2855,2866,2867,2869]],final=ss[-1])
 (HERE/'native-high-slide-receipt.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
 print('PASS',len(controls),'inputs',len(ss),'observations; high slide at',[(s['n'],s['M'],s['actionName'])for s in receipt['milestones']])

if __name__=='__main__':main()
