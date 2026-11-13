"""Independently check finite height receipts and optionally freshly replay traces."""
import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_height_map import sha,prepare,trial

def validate(data,replay=False):
    assert data['runtimeSha256']==sha('build/wafel-pilot/sm64_jp.dll')
    assert data['prefixSha256']==sha('build/wafel-pilot/capture.bKv95w/inputs.jsonl')
    assert data['finalScriptSha256']==sha(Path(__file__).with_name('ink_height_map.py'))
    expected={'main':{'crawl':[(1741,1803),(21778,32767)],'butt':[(1741,1801),(21778,32767)]},
              'vpu1':{'crawl':[(67277,98303)],'butt':[(67277,98303)]}}
    for name,actmap in expected.items():
        part=data['integerMaps'][name]
        for act,windows in actmap.items():
            summary=part['summaries'][act];runs=summary['runs']
            assert summary['count']==65536
            assert [(int(r['first']),int(r['last'])) for r in runs if r['value']]==windows
            assert all(r['last']-r['first']+1==r['count'] for r in runs)
            assert all(a['last']+1==b['first'] for a,b in zip(runs,runs[1:]))
            assert sum(r['count'] for r in runs)==65536
            assert sum(r['count'] for r in runs if r['value'])==summary['useful']
    for q in data['retained']:
        assert not any(c['buttons']&0x8000 for c in q['controls'])
        assert len(q['samples'])==q['updates']==len(q['events'])==len(q['controls'])
        assert q['initial']['movement']==q['initial']['collision']==q['initial']['display']
        assert all(b['timer']==a['timer']+1 for a,b in zip([q['initial']]+q['samples'],q['samples']))
        if q['capture']:
            n=q['samples'][1]
            assert (n['action'],n['actionArg'],n['used'],n['floorOwner'],n['platform'])==(0x1300,0x40001,64,61,61)
        if q['useful']:
            assert q['capture'] and q['retainedUntilAreaChange']
            assert q['samples'][-1]['area']==2 and q['arrival']['M']==[365.5927734375,5500.,-1096.8026123046875]
            assert all(s['platform']==61 for s in q['samples'][1:] if s['area']==1)
    if replay:
        g,o,states=prepare({q['recipe']['phase'] for q in data['retained']})
        for q in data['retained']:
            assert trial(g,o,states[q['recipe']['phase']],q['recipe'],full=True)==q
    return dict(retainedCases=len(data['retained']),retainedUpdates=sum(q['updates'] for q in data['retained']),freshReplay=replay)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('receipt',type=Path);p.add_argument('--replay',action='store_true');a=p.parse_args()
    print(json.dumps(validate(json.loads(a.receipt.read_text()),a.replay),indent=2))
