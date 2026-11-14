"""Exact selected-field comparison; no claim of whole-memory equivalence."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
    p=argparse.ArgumentParser();p.add_argument('prepared',type=Path);p.add_argument('capture',type=Path);p.add_argument('--output',type=Path);a=p.parse_args()
    raw=(a.capture/'raw.log').read_bytes()if(a.capture/'raw.log').exists()else gzip.decompress((a.capture/'raw.log.gz').read_bytes())
    lines=raw.decode(errors='replace').splitlines()
    pilot=[json.loads(x.split(',',1)[1])for x in lines if x.startswith('WAFEL_PILOT,')]
    extra=[json.loads(x.split(',',1)[1])for x in lines if x.startswith('FLY_NATIVE,')]
    inputs=[json.loads(x)for x in(a.prepared/'inputs.jsonl').read_text().splitlines()]
    assert [[r['buttons'],r['stick']]for r in pilot]==[[r['buttons'],r['stick']]for r in inputs]
    assert not any(r['buttons']&0x8000 for r in inputs)
    expected=json.loads(gzip.decompress((a.prepared/'wafel-trace.json.gz').read_bytes()));expected={r['poll']:r for r in expected}
    bad=[];offsets=set();checked=added=0
    for r in pilot:
        if r['poll']not in expected:continue
        e=expected[r['poll']]['observation'];offsets.add(e['timer']-r['timer']);checked+=1
        for k,v in r.items():
            if k not in('poll','timer','buttons','stick')and e.get(k)!=v:bad.append((r['poll'],k,v,e.get(k)))
    for r in extra:
        if r['poll']not in expected:continue
        e=expected[r['poll']];added+=1
        for k,v in r.items():
            if k not in('timer','flyBehavior')and e.get(k)!=v:bad.append((r['poll'],k,v,e.get(k)))
    assert checked==added==len(expected)
    result=dict(passed=not bad and offsets=={1},inputCount=len(inputs),comparedObservations=checked,
        exactlyMatchingObservations=checked-len({r[0]for r in bad}),mismatchCount=len(bad),firstMismatches=bad[:12],
        WafelMinusNativeTimer=sorted(offsets),AInputs=0,gameplayMemoryWrites=0,
        scope='Finite controller-produced western Fire Fly Guy history; success milestones are interpreted separately from field equivalence',
        romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',nativeBehaviorPointers=sorted({r['flyBehavior']for r in extra}),
        hashes=dict(rawLog=hashlib.sha256(raw).hexdigest(),inputs=sha(a.prepared/'inputs.jsonl'),controller=sha(a.prepared/'controller.inputs'),wafelTrace=sha(a.prepared/'wafel-trace.json.gz'),probe=sha(HERE/'native-probe.c'),checker=sha(Path(__file__))))
    out=a.output or a.prepared/'receipt.json';out.write_bytes((json.dumps(result,indent=2)+'\n').encode())
    print(json.dumps({k:v for k,v in result.items()if k not in('firstMismatches','hashes')},indent=2));assert result['passed']
if __name__=='__main__':main()
