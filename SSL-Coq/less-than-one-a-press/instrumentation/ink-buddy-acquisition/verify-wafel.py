"""Replay the complete stored controller history without any gameplay writes."""
import argparse,gzip,hashlib,json,platform,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,advance,sample,create_game,Observer
from replay import bits
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def rich(g,o,poll):
 s=sample(g,o);s['poll']=poll;s['observation']=o.snapshot()
 for label,slot,script in [('buddy',15,'bhvBobombBuddyOpensCannon'),('box',49,'bhvJumpingBox')]:
  p='gObjectPool[%d].'%slot
  s[label+'Bits']=[bits(g.read(p+'oPos'+a)) for a in 'XYZ']
  s[label+'Held']=g.read(p+'oHeldState');s[label+'Action']=g.read(p+'oAction');s[label+'Active']=g.read(p+'activeFlags')
  s[label+'NativeBehavior']=g.read(p+'behavior')==g.address(script)
 return s
def run(inputs):
 g=Guard(create_game());o=Observer(g);rows=[]
 for i,p in enumerate(inputs):
  if i>=348:rows.append(rich(g,o,i+1))
  advance(g,p)
 return rows
def main():
 p=argparse.ArgumentParser();p.add_argument('--prepare',type=Path);p.add_argument('--output',type=Path,default=HERE/'wafel-check.json');a=p.parse_args()
 if a.prepare:
  r=json.loads(a.prepare.read_text());assert r['prefixPolls']==len(r['prefixInputs'])==2668 and len(r['inputs'])==801 and r['acquired']
  inputs=r['prefixInputs']+r['inputs']+[dict(buttons=0,stick=[0,0])]*2
  (HERE/'inputs.jsonl').write_bytes((''.join(json.dumps(x,separators=(',',':'))+'\n' for x in inputs)).encode())
  (HERE/'controller.inputs').write_bytes((''.join('%d %d %d %d\n'%(i+1,p['buttons'],*p['stick']) for i,p in enumerate(inputs))).encode())
 else:inputs=[json.loads(x)for x in (HERE/'inputs.jsonl').read_text().splitlines()]
 assert len(inputs)==3471 and all(not p['buttons']&0x8000 for p in inputs)
 rows=run(inputs)
 if a.prepare:
  for i,s in enumerate(r['samples']):
   got=rows[(2668+i+1)-348]
   assert all(got[k]==v for k,v in s.items()),(i,s,got)
  with gzip.GzipFile(filename=str(HERE/'wafel-trace.json.gz'),mode='wb',mtime=0)as f:f.write((json.dumps(rows,separators=(',',':'))+'\n').encode())
 else:assert rows==json.loads(gzip.decompress((HERE/'wafel-trace.json.gz').read_bytes()))
 assert all(x['buddyNativeBehavior'] and x['boxNativeBehavior'] and x['buddyBits']==[bits(-5990),bits(0),bits(-3871)]and x['held']!=15 for x in rows)
 assert rows[2360-1-348]['used']==15 # before poll2360, after input2359
 assert rows[3468-1-348]['used']==49 and rows[3470-1-348]['held']==49
 receipt=dict(passed=True,scope='Finite controller-only JP Wafel history after debug level-select startup; no Buddy grab or clone',inputCount=len(inputs),observationCount=len(rows),lastMeaningfulInput=3469,neutralTailInputs=2,AInputs=0,heldA=False,gameplayWrites=0,startupWrites=[dict(path='gDebugLevelSelect',value=1)],writeGuard='Reject every post-startup write except the three controller-pad fields; reject held or pressed A',runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),pythonVersion=platform.python_version(),inputSha256=digest(HERE/'inputs.jsonl'),traceSha256=digest(HERE/'wafel-trace.json.gz'),searchSha256=digest(HERE/'search.py'),verifierSha256=digest(__file__),milestones=[x for x in rows if x['poll']in[2340,2360,2669,3466,3467,3468,3469,3470,3471]])
 a.output.write_bytes((json.dumps(receipt,indent=2)+'\n').encode());print('PASS',len(inputs),'all-A-off inputs,',len(rows),'exact before-poll observations')
if __name__=='__main__':main()
