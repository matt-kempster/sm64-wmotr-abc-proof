"""Compare original-JP read-only logs with exact Wafel binary32/reference fields."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def digest(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
 rawbytes=(a.capture/'raw.log').read_bytes()if(a.capture/'raw.log').exists()else gzip.decompress((a.capture/'raw.log.gz').read_bytes())
 raw=rawbytes.decode(errors='replace')
 native=[json.loads(x.split(',',1)[1])for x in raw.splitlines()if x.startswith('BUDDY_ACQUIRE,')]
 pilot=[json.loads(x.split(',',1)[1])for x in raw.splitlines()if x.startswith('WAFEL_PILOT,')]
 expected=json.loads(gzip.decompress((HERE/'wafel-trace.json.gz').read_bytes()));by_poll={x['poll']:x for x in expected}
 inputs=[json.loads(x)for x in (HERE/'inputs.jsonl').read_text().splitlines()]
 assert len(pilot)==len(inputs)==3471
 assert [[r['buttons'],r['stick']]for r in pilot]==[[r['buttons'],r['stick']]for r in inputs]
 assert all(not r['buttons']&0x8000 for r in pilot)
 mismatches=[];offsets=set();checked=0
 for r in pilot:
  if r['poll']not in by_poll:continue
  e=by_poll[r['poll']]['observation'];offsets.add(e['timer']-r['timer']);checked+=1
  for k,v in r.items():
   if k not in ('poll','timer','buttons','stick')and e.get(k)!=v:mismatches.append(dict(poll=r['poll'],field=k,native=v,wafel=e.get(k)))
 extra=0
 for r in native:
  if r['poll']not in by_poll:continue
  e=by_poll[r['poll']];extra+=1
  for k,v in r.items():
   if k in ('timer','buddyBehavior','boxBehavior'):continue
   if e.get(k)!=v:mismatches.append(dict(poll=r['poll'],field=k,native=v,wafel=e.get(k)))
 assert extra==checked==3123
 behavior=dict(buddy=sorted({x['buddyBehavior']for x in native}),box=sorted({x['boxBehavior']for x in native}))
 assert behavior['buddy']==[0x800eb528] and len(behavior['box'])==1
 assert all(x['buddyActive']and x['held']!=15 and x['buddyHeld']==0 for x in native)
 receipt=dict(passed=not mismatches and offsets=={1},scope='Original Japanese ROM, complete controller-only history after debug-level-select startup; conversation and native donor pickup, no Buddy grab/clone or Ink delivery',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',romMd5='85d61f5525af708c9f1e84dce6dc10e9',inputCount=len(inputs),nativeObservedPolls=extra,WafelMinusNativeGlobalTimer=sorted(offsets),AInputs=0,gameplayMemoryWrites=0,behaviorPointers=behavior,comparison='Exact binary32 M/C/D/floor, action/input/platform/top and buddy/box XYZ/action/activity/held/reference fields at before-controller-poll boundaries; not whole-memory equivalence',mismatchCount=len(mismatches),firstMismatches=mismatches[:20],hashes=dict(rawLog=hashlib.sha256(rawbytes).hexdigest(),inputs=digest(HERE/'inputs.jsonl'),controllerInputs=digest(HERE/'controller.inputs'),wafelTrace=digest(HERE/'wafel-trace.json.gz'),probe=digest(HERE/'native-probe.c'),checker=digest(__file__),plugin=digest(a.capture/'probe.so')if(a.capture/'probe.so').exists()else None),milestones=[x for x in native if x['poll']in[2340,2360,2669,3466,3467,3468,3469,3470,3471]])
 out=a.output or a.capture/'buddy-acquisition-check.json';out.write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
 print(json.dumps({k:receipt[k]for k in('passed','nativeObservedPolls','WafelMinusNativeGlobalTimer','mismatchCount','firstMismatches')},indent=2))
 assert receipt['passed'],'Original-JP mismatch; this is not a validated native acquisition history'
if __name__=='__main__':main()
