"""Position-only, below-cap roof starts for alternative gap producers.

All eight positions are supplied. Action, cache, item and depth are inherited
from the authenticated controller prefix; subsequent updates use only input.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_low_fixture_producers import (contexts, observation, cap_box, clear_box,
    advance, clean_policy, events, digest, CRAWL)
from ink_floorless_warp import position

SEEDS = [[x,1280.,z] for x,z in [(-2200.,-1024.),(-2200.,-939.),(-2200.,-1125.),
    (-1882.,-939.),(-1882.,-1024.),(-1936.,-1144.),(-2152.,-872.),(-2208.,-1104.)]]


def trial(g,o,state,seed,policy):
    g.load_state(state);position(g,seed,seed,seed)
    initial=observation(g,o);samples=[initial];logs=[];pads=[]
    max_gap=0.;max_crawl=None;stop='horizon';first_gap=None
    for i in range(60):
        before=samples[-1];b0=cap_box(g)
        if not clear_box(before['movement'],before['hitbox'],b0):stop='cap-screen';break
        pad=clean_policy(g,policy,i);pads.append(pad);advance(g,pad)
        row=observation(g,o);log=events(g);samples.append(row);logs.append(log)
        b1=cap_box(g)
        entry=[e['pos'] for e in log if e['type']=='FLT_EXECUTE_ACTION']
        if not all(clear_box(p,before['hitbox'],b1) for p in entry) or not clear_box(row['movement'],row['hitbox'],b1):
            stop='cap-screen';break
        gap=row['display'][1]-row['movement'][1]
        max_gap=max(max_gap,gap)
        if gap>0 and first_gap is None:first_gap=row
        if row['action']==CRAWL:
            max_crawl=row['movement'][1] if max_crawl is None else max(max_crawl,row['movement'][1])
        if row['level']!=8 or row['area']!=1 or g.read('gMarioState.area.camera').is_null():
            stop='left-area';break
    return dict(seed=seed,policy=policy,updates=len(pads),initial=initial,final=samples[-1],
                firstPositiveGap=first_gap,maxPositiveDisplayGap=max_gap,maxCrawlY=max_crawl,
                stop=stop,initialEdits=['Mario movement XYZ','Mario collision XYZ','Mario display XYZ'],
                intermediateEdits=0,AInputs=0,historyDigest=digest([samples,logs,pads]))


def run(capture):
    g,o,states,_=contexts(capture)
    rows=[trial(g,o,states[130],s,k) for s in SEEDS for k in range(44)]
    # Three distinct seeds: best gap/crawl per seed, then select representative seeds.
    best=[]
    for seed in SEEDS:
        candidates=[i for i,r in enumerate(rows) if r['seed']==seed]
        best.append(max(candidates,key=lambda i:(rows[i]['maxPositiveDisplayGap'],
                    rows[i]['maxCrawlY'] if rows[i]['maxCrawlY'] is not None else -20000)))
    selected=best[:2]+best[-1:]
    fresh,fo,fs,_=contexts(capture);checks=[]
    for i in selected:
        r=rows[i];repeat=trial(fresh,fo,fs[130],r['seed'],r['policy'])
        assert repeat==r
        checks.append(dict(index=i,updates=r['updates'],matched=True))
    summary=dict(trials=len(rows),updates=sum(r['updates'] for r in rows),
                 positiveGapTrials=sum(r['maxPositiveDisplayGap']>0 for r in rows),
                 maxPositiveDisplayGap=max(r['maxPositiveDisplayGap'] for r in rows),
                 crawlingTrials=sum(r['maxCrawlY'] is not None for r in rows),
                 maxCrawlY=max((r['maxCrawlY'] for r in rows if r['maxCrawlY'] is not None),default=None),
                 stopCounts=dict(Counter(r['stop'] for r in rows)),
                 freshReplayUpdates=sum(r['updates'] for r in checks))
    return dict(schema=1,scope='Eight supplied roof positions, inherited action/cache/items/depth, no-A input-only continuation',
                summary=summary,rows=rows,freshChecks=checks,
                sourceHashes={p:hashlib.sha256(Path(__file__).with_name(p).read_bytes()).hexdigest() for p in
                              ['ink_low_fixture_roof.py','ink_low_fixture_producers.py']},
                captureSha256=hashlib.sha256(capture.read_bytes()).hexdigest(),
                screen='Same conservative cap AABB update/action-entry screen as producer matrix; not internal-write tracing')


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--receipt',type=Path)
    a=p.parse_args();r=run(a.capture)
    with a.output.open('x',encoding='utf8') as f:json.dump(r,f,indent=2);f.write('\n')
    if a.receipt:
        compact=dict(r);compact['rawSha256']=hashlib.sha256(a.output.read_bytes()).hexdigest()
        compact['rows']=[{k:v for k,v in row.items() if k not in ('initial','final')} for row in r['rows']]
        compact['representatives']=[r['rows'][c['index']] for c in r['freshChecks']]
        with a.receipt.open('x',encoding='utf8') as f:json.dump(compact,f,indent=2);f.write('\n')
    print(json.dumps(r['summary'],indent=2))


if __name__=='__main__':main()
