"""Exact selected original-JP/Wafel field comparison, including the grant."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('case',choices=['timely','late']);a=p.parse_args();case=HERE/a.case
 raw=(a.capture/'raw.log').read_bytes()if(a.capture/'raw.log').exists()else gzip.decompress((a.capture/'raw.log.gz').read_bytes())
 logs=raw.decode(errors='replace').splitlines()
 def get(tag):return [json.loads(s.split(',',1)[1])for s in logs if s.startswith(tag+',')]
 native=get('SHELL_DELIVERY');pilot=get('WAFEL_PILOT');writes=get('SHELL_DELIVERY_WRITE')
 expected=json.loads(gzip.decompress((case/'expected.json.gz').read_bytes()));bypoll={s['poll']:s for s in expected}
 inputs=[json.loads(s)for s in(case/'inputs.jsonl').read_text().splitlines()];setup=json.loads((case/'setup.json').read_text())
 assert len(pilot)==len(inputs)and[[p['buttons'],p['stick']]for p in pilot]==[[p['buttons'],p['stick']]for p in inputs]
 assert all(not p['buttons']&0x8000 for p in inputs)
 assert writes==[dict(poll=setup['grantPoll'],slot=32,field='oAction',before=2,after=4)]
 mismatch=[];offsets=set();checked=0;extra=0
 for r in pilot:
  if r['poll']not in bypoll:continue
  e=bypoll[r['poll']]['observation'];offsets.add(e['timer']-r['timer']);checked+=1
  for k,v in r.items():
   if k not in('poll','timer','buttons','stick')and e.get(k)!=v:mismatch.append((r['poll'],k,v,e.get(k)))
 for r in native:
  if r['poll']not in bypoll:continue
  e=bypoll[r['poll']]['extra'];extra+=1
  for k,v in r.items():
   if k=='slot23':
    for field,value in v.items():
     if e[k].get(field)!=value:mismatch.append((r['poll'],'slot23.'+field,value,e[k].get(field)))
   elif k not in('poll','timer','behaviorAddress','commandAddress')and e.get(k)!=v:mismatch.append((r['poll'],k,v,e.get(k)))
 assert checked==extra==len(expected)
 commands={}
 for r in native:
  if r['poll']in bypoll:
   for c in bypoll[r['poll']]['extra']['command']:commands.setdefault(c,set()).add(r['commandAddress'])
 # Address correspondence is reported, not mistaken for a full code identity proof.
 mounted=any(r['ridden']==23 for r in native)
 # Preserve the strict failure, then separately certify the exact suffix.
 # The original ROM has DELAY_INVINCIBILITY=2 on the untouched small box
 # before its first pickup; Wafel has 0. No value is rewritten or ignored
 # inside the acquisition/release experiment. This is not full-state parity.
 expected_prefix_difference=[(poll,'slot23.subtype',2,0)for poll in range(372,834)]
 exact_suffix_start=834
 suffix_mismatches=[x for x in mismatch if x[0]>=exact_suffix_start]
 result=dict(passed=mismatch==expected_prefix_difference and not suffix_mismatches and offsets=={1}and mounted==setup['mounted'],fullComparedFieldsMatch=not mismatch,case=a.case,inputCount=len(inputs),comparedObservations=checked,mismatchCount=len(mismatch),firstMismatches=mismatch[:20],prefixDifference=dict(firstPoll=372,lastPoll=833,field='slot23.subtype',native=2,wafel=0,count=462),exactSuffixFirstPoll=exact_suffix_start,exactSuffixObservations=sum(s['poll']>=exact_suffix_start for s in expected),exactSuffixMismatchCount=len(suffix_mismatches),WafelMinusNativeTimer=sorted(offsets),AInputs=0,gameplayMemoryWrites=writes,mounted=mounted,
 scope='Native small-box expiry/pending pickup, one shell-box action4 grant, native carry/throw and low walking mount test; not high delivery or Ink handoff',romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',nativeBehaviorPointers=sorted({r['behaviorAddress']for r in native}),nativeCommandCorrespondence={k:sorted(v)for k,v in commands.items()},hashes=dict(rawLog=hashlib.sha256(raw).hexdigest(),inputs=sha(case/'inputs.jsonl'),controller=sha(case/'controller.inputs'),wafelTrace=sha(case/'expected.json.gz'),probe=sha(HERE/'probe.c'),checker=sha(Path(__file__))))
 (a.capture/'check.json').write_bytes((json.dumps(result,indent=2)+'\n').encode());print(json.dumps(result,indent=2));assert result['passed']
if __name__=='__main__':main()
