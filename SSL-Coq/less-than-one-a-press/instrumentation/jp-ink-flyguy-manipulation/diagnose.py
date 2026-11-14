"""Report a strict mismatch without silently weakening the strict checker.

Separates observed trajectory reproduction from exact internal-field equality.
The only accepted diagnostic difference is the explicitly reported subtype bit2.
It is never claimed irrelevant to every possible history.
"""
import argparse,collections,gzip,hashlib,json
from pathlib import Path
def ranges(values):
    out=[]
    for v in values:
        if out and out[-1][1]+1==v:out[-1][1]=v
        else:out.append([v,v])
    return out
def main():
    p=argparse.ArgumentParser();p.add_argument('prepared',type=Path);p.add_argument('capture',type=Path);a=p.parse_args()
    raw=(a.capture/'raw.log').read_bytes()if(a.capture/'raw.log').exists()else gzip.decompress((a.capture/'raw.log.gz').read_bytes())
    lines=raw.decode(errors='replace').splitlines()
    expected={r['poll']:r for r in json.loads(gzip.decompress((a.prepared/'wafel-trace.json.gz').read_bytes()))}
    fields=json.loads((a.prepared/'fields.json').read_text());diffs=[];primary=[];offsets=set();polls=[];epolls=[]
    for line in lines:
        if line.startswith('WAFEL_PILOT,'):
            r=json.loads(line.split(',',1)[1])
            if r['poll']not in expected:continue
            polls.append(r['poll']);e=expected[r['poll']]['observation'];offsets.add(e['timer']-r['timer'])
            for k,v in r.items():
                if k not in('timer','poll','buttons','stick')and e.get(k)!=v:primary.append([r['poll'],k,v,e.get(k)])
        elif line.startswith('FLY_NATIVE,'):
            r=json.loads(line.split(',',1)[1]);e=expected[r['poll']];epolls.append(r['poll'])
            for k in ['used','held','flyActive']:
                if r[k]!=e[k]:diffs.append([r['poll'],k,r[k],e[k]])
            for i,(v,w)in enumerate(zip(r['flyWords'],e['flyWords'])):
                if v!=w:diffs.append([r['poll'],fields[i][0],v,w])
    assert sorted(expected)==polls==epolls
    known=all(k=='oInteractionSubtype'and v==130 and w==128 for _,k,v,w in diffs)
    counts=collections.Counter(d[1]for d in diffs)
    report=dict(strictComparisonPassed=not diffs and not primary and offsets=={1},
        marioTrajectoryFieldsMatch=not primary and offsets=={1},
        extraFieldsMatchExceptReportedSubtype=known,observations=len(polls),
        primaryMismatchCount=len(primary),extraMismatchCount=len(diffs),
        extraMismatchFields=dict(counts),mismatchPollRanges=ranges([d[0]for d in diffs]),
        firstDifferences=diffs[:3],lastDifferences=diffs[-3:],primaryDifferences=primary[:10],
        matchedScope='Exact recorded Mario M/C/stored-graphics, action/input, floor/cache and platform; Fly Guy XYZ, velocity, action, home, activation, headings and scale',
        limit='The delayed-invincibility subtype differs and affects the damage guard in general. This diagnostic does not establish whole-state equivalence or the cause of that difference.',
        rawLogSha256=hashlib.sha256(raw).hexdigest(),scriptSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    (a.prepared/'diagnostic.json').write_bytes((json.dumps(report,indent=2)+'\n').encode());print(json.dumps(report,indent=2))
    assert report['marioTrajectoryFieldsMatch']and known
if __name__=='__main__':main()
