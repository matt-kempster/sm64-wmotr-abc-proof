"""Archive and freshly reconstruct every actual native lure continuation."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(HERE))
from harness import Guard,create_game,Observer,advance,sample
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 receipts=[];total=0
 for name,build in [('lures.json.gz','flyguy-native-lure-v1.json.gz'),('burn-roof.json.gz','flyguy-native-burn-roof-v1.json.gz'),
                    ('pre-fourth-late.json.gz','flyguy-native-lure-pre-fourth-v1.json.gz'),('pre-fourth-early.json.gz','flyguy-native-lure-pre-fourth-v2.json.gz')]:
  path=HERE/name
  if not path.exists():path.write_bytes((ROOT/'build'/build).read_bytes())
  data=json.load(gzip.open(path));game=Guard(create_game());observer=Observer(game)
  cuts=sorted({t['recipe'].get('cut',len(data['prefixInputs']))for t in data['trials']});states={}
  for i,pad in enumerate(data['prefixInputs']):
   advance(game,pad)
   if i+1 in cuts:states[i+1]=game.save_state()
  if 'initial'in data:assert sample(game,observer,len(data['prefixInputs']))==data['initial']
  checked=0
  for trial in data['trials']:
   cut=trial['recipe'].get('cut',len(data['prefixInputs']));game.load_state(states[cut]);assert sample(game,observer,cut)==trial['samples'][0]
   for i,(pad,expected)in enumerate(zip(trial['inputs'],trial['samples'][1:])):
    advance(game,pad);assert sample(game,observer,cut+i+1)==expected,(name,trial['recipe'],i)
    checked+=1
  receipts.append(dict(archive=name,trials=len(data['trials']),matchedSuffixObservations=checked,sha256=sha(path)))
  total+=checked
  if name=='burn-roof.json.gz':
   best=next(t for t in data['trials']if t['recipe']==dict(radius=350,lead=.4,direction=1))
   inputs=data['prefixInputs']+best['inputs']
   (HERE/'native-flame-roof-inputs.jsonl').write_bytes((''.join(json.dumps(p,separators=(',',':'))+'\n'for p in inputs)).encode())
   (HERE/'native-flame-roof-receipt.json').write_bytes((json.dumps(dict(inputCount=len(inputs),AInputs=0,gameplayWrites=[],startupGrant='inherited debug level selection only',recipe=best['recipe'],final=best['samples'][-1],
    maxFlySample=max(best['samples'],key=lambda s:s['fly']['xyz'][1]),firstCrawl=next((s for s in best['samples']if s['actionName']=='ACT_CRAWLING'),None),scope=__doc__),indent=2)+'\n').encode())
 summary=dict(passed=True,trials=sum(r['trials']for r in receipts),matchedSuffixObservations=total,archives=receipts,
  files={p.name:sha(p)for p in HERE.iterdir()if p.is_file()and p.name not in ['verification.json']},
  scope='Controller-only post-top-expiry luring and flame-assisted roof action; no usable Ink handoff or original-ROM result in this receipt')
 (HERE/'verification.json').write_bytes((json.dumps(summary,indent=2)+'\n').encode());print(json.dumps({k:v for k,v in summary.items()if k!='files'},indent=2))
if __name__=='__main__':main()
