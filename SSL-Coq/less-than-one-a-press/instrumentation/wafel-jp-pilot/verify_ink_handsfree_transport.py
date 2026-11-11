"""Read-only receipt/hash/count audit; verifies stored replay evidence, not new gameplay."""
import ast
import hashlib
import json
import math
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SCRIPT=ROOT/'instrumentation/wafel-jp-pilot/ink_handsfree_transport.py'
RAW_NAME='build/wafel-pilot/ink-handsfree-transport-20261112-final.json'


def main():
    raw_path=ROOT/RAW_NAME;raw=json.loads(raw_path.read_text())
    receipt=json.loads((ROOT/'docs/notes/ink-handsfree-transport-receipt.json').read_text())
    sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
    assert raw['scriptSha256']==sha(SCRIPT)
    assert raw['runtimeSha256']==sha(ROOT/'build/wafel-pilot/sm64_jp.dll')
    assert raw['baselineSha256']==sha(ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl')
    assert raw['sourceReport']['sha256']==sha(ROOT/raw['sourceReport']['path'])
    assert all(digest==sha(SCRIPT.with_name(name))for name,digest in raw['helperSha256'].items())
    assert raw['gameplayEdits']==[]and all(s['initialEdits']==[]for s in raw['seeds'])
    tree=ast.parse(SCRIPT.read_text())
    wanted={'compact','summarize','holding','distance','ihash'}
    pure=ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef)and n.name in wanted],type_ignores=[])
    ns=dict(hashlib=hashlib,json=json,math=math,sha=lambda p:sha(ROOT/p))
    exec(compile(pure,str(SCRIPT),'exec'),ns)
    assert ns['compact'](raw,Path(RAW_NAME))==receipt
    assert len(raw['trials'])==90
    assert len({(t['sourceTrial'],ns['ihash'](t['inputs']))for t in raw['trials']})==45
    assert sum(len(t['inputs'])for t in raw['trials'])==9202
    for trial in raw['trials']:
        assert trial['summary']==ns['summarize'](trial)
        assert len(trial['samples'])==len(trial['inputs'])+1
        assert len(trial['inputs'])<=700
        assert trial['summary']['firstRelease']is not None
        assert trial['summary']['firstDeletion']['n']-trial['summary']['firstRelease']['after']['n']==1
    assert len(raw['beams'])==15
    evaluated=0
    for beam in raw['beams']:
        assert (beam['horizon'],beam['block'],beam['menuSize'])==(360,4,14)
        assert beam['width']==(24 if beam['objective']=='momentum'else 12)
        retained=1;tested=0
        for depth,row in enumerate(beam['depths'],1):
            tested+=retained*14
            assert row['depth']==depth<=90
            assert 0<=row['retained']<=min(beam['width'],row['passing'])<=retained*14
            retained=row['retained']
        assert tested==beam['testedBranches']and retained==0
        assert set(beam['rejectedBranches'])=={'lost-live-held-box'}
        assert set(beam['evaluatedHeldActionSamples'])<= {'ACT_STOMACH_SLIDE','ACT_STOMACH_SLIDE_STOP','ACT_IDLE'}
        assert beam['maximumPillars']==beam['spinningTopSamples']==beam['highCrawlSamples']==0
        evaluated+=sum(beam['evaluatedActionSamples'].values())
    assert sum(b['testedBranches']for b in raw['beams'])==66906
    assert evaluated==263494
    assert sum(b['nativeUpdatesIncludingRetainedReconstruction']for b in raw['beams'])==282550
    assert len(raw['selected'])==25
    assert len({ns['ihash'](t['fullControllerPrefix']+t['inputs'])for t in raw['selected']})==23
    for witness in raw['selected']:
        assert witness['summary']==ns['summarize'](witness)
        fresh=witness['freshReplay']
        assert fresh['passed']and fresh['gameplayEdits']==[]
        assert fresh['comparedSnapshots']==len(witness['samples'])==len(witness['inputs'])+1
        assert fresh['prefixInputCount']==len(witness['fullControllerPrefix'])
        seed=next(s for s in raw['seeds']if s['sourceTrial']==witness['sourceTrial'])
        assert witness['fullControllerPrefix']==seed['fullControllerPrefix']and witness['samples'][0]==seed['start']
    assert sum(t['freshReplay']['comparedSnapshots']for t in raw['selected'])==802
    counts=[0,0]
    def scan(value):
        if isinstance(value,dict):
            if isinstance(value.get('buttons'),int):
                assert not value['buttons']&0x8000
                assert all(isinstance(v,int)and -128<=v<=127 for v in value['stick'])
                counts[0]+=1
            if isinstance(value.get('input'),int):
                assert not value['input']&0x82;counts[1]+=1
            for child in value.values():scan(child)
        elif isinstance(value,list):
            for child in value:scan(child)
    scan(raw)
    assert b'\r'not in SCRIPT.read_bytes()and b'\r'not in Path(__file__).read_bytes()
    print(json.dumps(dict(passed=True,mode=__doc__,rawSha256=sha(raw_path),scriptSha256=sha(SCRIPT),
        summary=raw['summary'],retainedButtonRecords=counts[0],retainedMarioInputRecords=counts[1]),indent=2))


if __name__=='__main__':main()
