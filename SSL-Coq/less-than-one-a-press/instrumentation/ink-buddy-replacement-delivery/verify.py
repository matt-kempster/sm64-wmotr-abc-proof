"""Fresh A-off replays of preserved delivery trials; no gameplay-state writes."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance
from replay import bits
HERE=Path(__file__).resolve().parent
def read(p):return json.loads(gzip.decompress(p.read_bytes()))
def compare(g,o,expected):
 actual=sample(g,o,23)
 if 'floorNormal'in expected:actual['floorNormal']=g.read('gMarioState.floor?.normal')
 if 'HOLP'in expected:actual['HOLP']=g.read('gMarioState.marioBodyState.heldObjLastPosition')
 assert actual==expected,(expected,actual)
def seed(inputs):
 g=Guard(create_game());o=Observer(g)
 for p in inputs:advance(g,p)
 return g,o
def suffix(g,o,inputs,samples):
 assert len(samples)==len(inputs)+1
 compare(g,o,samples[0])
 for p,s in zip(inputs,samples[1:]):advance(g,p);compare(g,o,s)
 return len(samples)
def main():
 checks=[]
 for path in sorted((HERE/'records').glob('*.json.gz')):
  r=read(path);matched=0;histories=0
  if path.stem.startswith('smallbox-v'):
   for t in r['trials']:
    g,o=seed(t['prefixInputs']);matched+=suffix(g,o,t['inputs'],t['samples']);histories+=1
    state=g.save_state()
    for c in t.get('carries',[]):
     g.load_state(state);matched+=suffix(g,o,c['inputs'],c['samples']);histories+=1
  elif path.stem.startswith('smallbox-beam'):
   g,o=seed(r['prefixInputs']);matched+=suffix(g,o,r['acquisition']['inputs'],r['acquisition']['samples'])
   matched+=suffix(g,o,r['selected']['inputs'],r['selected']['samples']);histories=1
  elif path.stem=='smallbox-perimeter-v1.json':
   g,o=seed(r['prefixInputs']);matched+=suffix(g,o,r['acquisition']['inputs'],r['acquisition']['samples']);state=g.save_state()
   for t in r['trials']:g.load_state(state);matched+=suffix(g,o,t['inputs'],t['samples']);histories+=1
  elif path.stem=='smallbox-release-v1.json':
   for t in r['trials']:
    g,o=seed(t['prefixInputs']);matched+=suffix(g,o,t['inputs'],t['samples']);histories+=1
  else:
   g,o=seed(r['prefixInputs']);compare(g,o,r['initial']);state=g.save_state()
   for t in r['trials']:g.load_state(state);matched+=suffix(g,o,t['inputs'],t['samples']);histories+=1
  checks.append(dict(file=path.name,matchedSuffixObservations=matched,replayedHistories=histories))
  print(path.name,matched,histories,flush=True)
 inputs=[json.loads(x)for x in(HERE/'inputs.jsonl').read_text().splitlines()]
 expected=read(HERE/'wafel-trace.json.gz');by={x['poll']:x for x in expected};g=Guard(create_game());o=Observer(g);native_matched=0
 for i,p in enumerate(inputs):
  if i+1 in by:
   s=sample(g,o,23);s.update(poll=i+1,observation=o.snapshot(),boxBits=[bits(v)for v in s['actor']['xyz']],boxHeld=s['actor']['oHeldState'],boxActive=s['actor']['activeFlags'],boxAction=s['actor']['oAction'])
   assert s==by[i+1];native_matched+=1
  advance(g,p)
 receipt=dict(passed=True,scope='Finite native controller histories; not successful Ink delivery',AInputs=0,gameplayWrites=0,checks=checks,
  matchedSuffixObservations=sum(x['matchedSuffixObservations']for x in checks),replayedHistories=sum(x['replayedHistories']for x in checks),
  selectedNativeInputCount=len(inputs),selectedNativeWafelMatched=native_matched)
 (HERE/'verification.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode());print(json.dumps(receipt,indent=2))
if __name__=='__main__':main()
