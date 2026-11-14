"""Check archived original-JP fields against the controller-only Wafel history."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
 raw=(a.capture/'raw.log').read_bytes()if(a.capture/'raw.log').exists()else gzip.decompress((a.capture/'raw.log.gz').read_bytes())
 logs=raw.decode(errors='replace').splitlines();native=[json.loads(x.split(',',1)[1])for x in logs if x.startswith('SMALLBOX_DELIVERY,')]
 pilot=[json.loads(x.split(',',1)[1])for x in logs if x.startswith('WAFEL_PILOT,')]
 expected=json.loads(gzip.decompress((HERE/'wafel-trace.json.gz').read_bytes())); bypoll={s['poll']:s for s in expected}
 inputs=[json.loads(x)for x in(HERE/'inputs.jsonl').read_text().splitlines()]
 assert len(pilot)==len(inputs)and[[p['buttons'],p['stick']]for p in pilot]==[[p['buttons'],p['stick']]for p in inputs]
 assert all(not p['buttons']&0x8000 for p in inputs)
 mismatch=[];offsets=set();checked=0;extra=0
 for r in pilot:
  if r['poll']not in bypoll:continue
  e=bypoll[r['poll']]['observation'];offsets.add(e['timer']-r['timer']);checked+=1
  for k,v in r.items():
   if k not in('poll','timer','buttons','stick')and e.get(k)!=v:mismatch.append((r['poll'],k,v,e.get(k)))
 for r in native:
  if r['poll']not in bypoll:continue
  e=bypoll[r['poll']];extra+=1
  for k,v in r.items():
   if k not in('timer','boxBehavior')and e.get(k)!=v:mismatch.append((r['poll'],k,v,e.get(k)))
 assert checked==extra==len(expected)
 result=dict(passed=not mismatch and offsets=={1},inputCount=len(inputs),matchedObservations=checked,mismatchCount=len(mismatch),firstMismatches=mismatch[:20],WafelMinusNativeTimer=sorted(offsets),AInputs=0,gameplayMemoryWrites=0,
 scope='Actual no-A small-box acquisition, carry to a low dune and throw; not Ink delivery or spawning displacement',
 romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',
 nativeBehaviorPointers=sorted({r['boxBehavior']for r in native}),
 hashes=dict(rawLog=hashlib.sha256(raw).hexdigest(),inputs=sha(HERE/'inputs.jsonl'),controller=sha(HERE/'controller.inputs'),wafelTrace=sha(HERE/'wafel-trace.json.gz'),probe=sha(HERE/'native-probe.c'),checker=sha(Path(__file__))))
 out=a.output or a.capture/'smallbox-delivery-check.json';out.write_bytes((json.dumps(result,indent=2)+'\n').encode());print(json.dumps(result,indent=2));assert result['passed']
if __name__=='__main__':main()
