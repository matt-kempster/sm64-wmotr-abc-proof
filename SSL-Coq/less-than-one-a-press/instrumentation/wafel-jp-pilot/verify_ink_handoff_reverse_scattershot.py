"""Audit reverse-search bookkeeping and emit a compact native-evidence receipt.

This checks recorded observations, recipes and digests, not Coq semantics or
complete native memory. The search itself performs independent native replays.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0, str(Path(__file__).resolve().parent))
import ink_handoff_reverse_scattershot as rss


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def audit(data):
    controls, trials = data['controls'], data['trials']
    assert [c['result']['success'] for c in controls] == [True, True, False]
    entries = {i: c for i, c in enumerate(controls[:2])}
    families = Counter()
    ledger = []
    for t in trials:
        recipe, result = t['recipe'], t['result']
        rss.validate_recipe(recipe)
        parent = entries[recipe['parent']]
        assert parent['result']['success']
        distance = parent['recipe']['phase'] - recipe['phase']
        assert distance > 0
        assert recipe['controls'][distance:] == parent['recipe']['controls']
        assert result['cleanGameplay'] == (result['success'] and not result['initialEdits'])
        before, after = result['before130'], result['after130']
        assert result['handoff'] == (before is not None and rss.is_handoff(before, after))
        assert result['success'] == (result['handoff'] and result['capture']
                                     and rss.outside_elevator(result['firstArea2']))
        assert result['status'] != 'useful-handoff' or result['success']
        if result['success']: entries[t['id']] = t
        families[(recipe['family'], result['status'])] += 1
        ledger.append(dict(id=t['id'], parent=recipe['parent'], phase=recipe['phase'],
            actor=recipe['actorKind'], family=recipe['family'], status=result['status'],
            recipeDigest=rss.digest(recipe), historyDigest=result['historyDigest'],
            initialEditCount=len(result['initialEdits']), updates=result['updates']))
    summary = data['summary']
    assert summary['completed'] == len(trials)
    assert summary['successes'] == sum(t['result']['success'] for t in trials)
    assert summary['cleanGameplaySuccesses'] == sum(t['result']['cleanGameplay'] for t in trials)
    assert summary['familyCounts'] == [dict(family=f, status=s, count=n)
                                       for (f,s),n in sorted(families.items())]
    assert all(e['result']['success'] for e in data['archive'])
    lookup = {i:c for i,c in enumerate(controls)} | {t['id']:t for t in trials}
    for replay in data['freshReplays']:
        assert rss.digest([replay['samples'], replay['events']]) == replay['historyDigest']
        assert replay['historyDigest'] == lookup[replay['id']]['result']['historyDigest']
        assert replay['success'] and replay['updates'] == len(replay['samples'])-1
    for replay in data['diagnosticReplays']:
        r = replay['result']
        assert rss.digest([r['samples'], r['events']]) == r['historyDigest']
        assert r['historyDigest'] == lookup[replay['id']]['result']['historyDigest']
        assert r['updates'] == len(r['samples'])-1
    assert summary['freshReplayUpdates'] == sum(r['updates'] for r in data['freshReplays'])
    assert summary['diagnosticReplayUpdates'] == sum(r['result']['updates'] for r in data['diagnosticReplays'])
    high = [t for t in trials if t['result']['before130'] is not None
            and t['result']['before130']['action'] == rss.CRAWLING
            and t['result']['before130']['movement'][1] > 1280.]
    return ledger, dict(highCrawlBefore130=len(high),
        highCrawlWithLiveTangibleActor=sum(t['result']['before130']['actor']['live'] and
            t['result']['before130']['actor']['tangible'] for t in high),
        allHighCrawlersRememberTop=all(t['result']['before130']['floorOwner']==61 for t in high),
        highCrawlFloorHeightRange=[min(t['result']['before130']['floorY'] for t in high),
                                  max(t['result']['before130']['floorY'] for t in high)] if high else None,
        phases=[dict(phase=k,count=v) for k,v in sorted(Counter(t['recipe']['phase'] for t in trials).items())])


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('raw',type=Path); p.add_argument('receipt',type=Path)
    p.add_argument('--compare',type=Path)
    args=p.parse_args()
    if args.receipt.exists(): raise FileExistsError(args.receipt)
    data=json.loads(args.raw.read_text(encoding='utf-8'))
    assert data['scriptSha256']==sha(Path(rss.__file__))
    assert data['runtimeSha256']==sha(rss.ROOT/'build/wafel-pilot/sm64_jp.dll')
    ledger, diagnostic_summary=audit(data)
    repeated=None
    if args.compare:
        old=json.loads(args.compare.read_text(encoding='utf-8'))
        assert data['options']==old['options']
        for name in ['controls','trials']:
            assert len(data[name])==len(old[name])
            for a,b in zip(data[name],old[name]):
                assert a['recipe']==b['recipe']
                assert a['result']['historyDigest']==b['result']['historyDigest']
        repeated=dict(rawSha256=sha(args.compare), controls=len(old['controls']),
                      proposals=len(old['trials']), equality='recipe and observation/event history digest')
    receipt={k:data[k] for k in ['schema','scope','baseProofCommit','scriptSha256','runtimeSha256',
        'captureSha256','options','observationLimit','controls','archive','freshReplays',
        'diagnosticReplays','incompleteTrial','summary','timing']}
    receipt.update(rawSha256=sha(args.raw), rawBytes=args.raw.stat().st_size,
        rawPath='build/wafel-pilot/'+args.raw.name, verifierSha256=sha(Path(__file__)),
        repeatedBatch=repeated,diagnostics=diagnostic_summary,trialLedger=ledger,
        verdict='No earlier successful parent in this finite sample; supplied roots only; clean route remains open.')
    args.receipt.write_text(json.dumps(receipt,indent=2,allow_nan=False)+'\n',encoding='utf-8')
    print(json.dumps(dict(checkedTrials=len(ledger), diagnostics=diagnostic_summary,
                         repeatedBatch=repeated, receiptSha256=sha(args.receipt)),indent=2))


if __name__=='__main__': main()
