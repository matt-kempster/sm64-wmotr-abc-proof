"""Read-only provenance, receipt and finite-history audit; no gameplay replay."""
import ast
import hashlib
import json
import math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SCRIPT=ROOT/'instrumentation/wafel-jp-pilot/ink_bobomb_regrab_transport.py'
RAW_NAME='build/wafel-pilot/ink-bobomb-regrab-transport-20261112-final.json'


def main():
    raw_path=ROOT/RAW_NAME;raw=json.loads(raw_path.read_text())
    receipt=json.loads((ROOT/'docs/notes/ink-bobomb-regrab-transport-receipt.json').read_text())
    sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
    assert raw['scriptSha256']==sha(SCRIPT)
    assert raw['runtimeSha256']==sha(ROOT/'build/wafel-pilot/sm64_jp.dll')
    assert raw['baselineSha256']==sha(ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl')
    assert all(value==sha(SCRIPT.with_name(name))for name,value in raw['helperSha256'].items())
    assert raw['gameplayEdits']==raw['seed']['gameplayEdits']==raw['recoverySeed']['gameplayEdits']==[]
    assert raw['seed']['prefixLength']==350 and len(raw['seed']['controls'])==len(raw['seed']['samples'])==197
    capture=[json.loads(line)for line in (ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl').read_text().splitlines()]
    prefix=[dict(buttons=p['buttons'],stick=p['stick'])for p in capture[:350]]
    assert raw['fullControllerPrefix']==prefix+raw['seed']['controls']
    tree=ast.parse(SCRIPT.read_text());wanted={'compact','summary','alive','distance','ihash'}
    pure=ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name in wanted],type_ignores=[])
    ns=dict(hashlib=hashlib,json=json,math=math,GOAL=(6930,-4871),sha=lambda p:sha(ROOT/p))
    exec(compile(pure,str(SCRIPT),'exec'),ns)
    assert ns['compact'](raw,Path(RAW_NAME))==receipt
    assert len(raw['trials'])==200 and len(raw['recoveryTrials'])==56
    assert sum(len(t['inputs'])for t in raw['trials'])==21049
    assert sum(len(t['inputs'])for t in raw['recoveryTrials'])==12164
    assert len({(t['policy']['startAfterAcquisition'],ns['ihash'](t['inputs']))for t in raw['trials']})==118
    for family,horizon in(('trials',500),('recoveryTrials',800)):
        for trial in raw[family]:
            assert trial['summary']==ns['summary'](trial)
            assert len(trial['samples'])==len(trial['inputs'])+1<=horizon+1
            assert trial['summary']['maximumPillars']==trial['summary']['spinningTopSamples']==0
            assert not trial['summary']['actorSurvives']
            assert all(s['area']==1 for s in trial['samples'])
    base=next(t for t in raw['trials']if t['policy']==raw['recoverySeed']['basePolicy'])
    assert raw['recoverySeed']['acquisitionInputs']==115
    assert raw['recoverySeed']['baseInputs']==base['inputs'][:151]
    assert all(t['samples'][0]==base['samples'][151]for t in raw['recoveryTrials'])
    assert len(raw['selected'])==5
    for witness in raw['selected']:
        family=raw['recoveryTrials']if witness['label'].startswith('recovery-')else raw['trials']
        trial=next(t for t in family if t['policy']==witness['policy'])
        assert all(witness[k]==trial[k]for k in('inputs','samples','events','summary'))
        expected=(raw['fullControllerPrefix'][:465]+base['inputs'][:151] if family is raw['recoveryTrials']
                  else raw['fullControllerPrefix'][:350+witness['policy']['startAfterAcquisition']])
        assert witness['fullControllerPrefix']==expected
        assert witness['freshReplay']==dict(passed=True,comparedSnapshots=len(witness['samples']),gameplayEdits=[])
    assert sum(t['freshReplay']['comparedSnapshots']for t in raw['selected'])==1927
    assert len({ns['ihash'](t['fullControllerPrefix']+t['inputs'])for t in raw['selected']})==3
    best=next(t for t in raw['selected']if t['label']=='recovery-nearest')
    full=best['fullControllerPrefix']+best['inputs']
    canonical=''.join(json.dumps(p,separators=(',',':'))+'\n'for p in full).encode()
    assert len(full)==938
    assert canonical==SCRIPT.with_name('ink-bobomb-regrab-transport-inputs.jsonl').read_bytes()
    assert best['summary']['regrabs']==18 and best['summary']['expiredRegrabs']==18
    assert base['summary']['firstRegrab']['actors'][0]['fuse']==139
    counts=[0,0]
    def scan(value):
        if isinstance(value,dict):
            if isinstance(value.get('buttons'),int):
                assert not value['buttons']&0x8000
                assert all(isinstance(x,int)and -128<=x<=127 for x in value['stick']);counts[0]+=1
            if isinstance(value.get('input'),int):assert not value['input']&0x82;counts[1]+=1
            for child in value.values():scan(child)
        elif isinstance(value,list):
            for child in value:scan(child)
    scan(raw)
    assert b'\r'not in SCRIPT.read_bytes()and b'\r'not in Path(__file__).read_bytes()
    print(json.dumps(dict(passed=True,mode=__doc__,rawSha256=sha(raw_path),scriptSha256=sha(SCRIPT),
        summary=raw['summary'],bestFullInputCount=len(full),bestCanonicalJsonlSha256=hashlib.sha256(canonical).hexdigest(),
        retainedButtonRecords=counts[0],retainedMarioInputRecords=counts[1]),indent=2))


if __name__=='__main__':main()
