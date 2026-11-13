"""Denser walking-edge search from the same native 117 walking boundary.

The first beam sometimes retained fewer than its maximum width. This
follow-up fills 64 places when available and uses 64 stick headings.
Sliding states are pruned while supported; loss-of-floor and crouch/crawl
states remain eligible. It is a separate finite, heuristic experiment.
"""
import argparse
from collections import Counter
import json
import math
from pathlib import Path
import sys
import time
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_walk_edge_crawl as study


def menu():
    pads=[dict(buttons=0,stick=[0,0])]
    for magnitude in [32,64,127]:
        for yaw in range(0,65536,1024):
            pads.append(dict(buttons=0,stick=[round(math.sin(yaw*math.tau/65536)*magnitude),round(math.cos(yaw*math.tau/65536)*magnitude)]))
    pads += [dict(buttons=study.Z,stick=p['stick']) for p in pads if p['stick']==[0,0] or max(map(abs,p['stick']))>100]
    return list({json.dumps(p,sort_keys=True):p for p in pads}.values())


def run(output,width):
    g,o,saved,setup=study.root_state(117)
    constants={n:g.constant(n) for n in study.prior.NAMES}
    slides={constants[n] for n in study.prior.SLIDE_NAMES}
    frontier=[dict(saved=saved,records=[],state=setup['rootState'])]
    selected={};layers=[];counts=Counter();start=time.monotonic();pads=menu()
    for depth in range(1,34):
        candidates={};expanded=0;pruned=0
        for parent in frontier:
            for pad in pads:
                g.load_state(parent['saved']);r=study.advance(g,o,pad);expanded+=1
                chain=parent['records']+[r];s=r['state'];result=study.assess(setup['rootState'],chain,constants)
                for k,v in result.items():
                    if isinstance(v,bool) and v:counts[k]+=1
                study.keep(selected,117,dict(refinedBeam=True,depth=depth),chain,result)
                if s['area']!=1 or not s['topLive'] or s['topAction']!=1:continue
                if s['floorOwner']==61 and s['action'] in slides:pruned+=1;continue
                key=json.dumps([s,result['lostUpperFloor']],sort_keys=True,separators=(',',':'))
                if key not in candidates:candidates[key]=dict(parent=parent,pad=pad,record=r,result=result)
        def rank(c):
            s=c['record']['state'];result=c['result'];d=(s['edge'] or {'clearance':-1000})['clearance']
            stage={study.prior.CRAWL:4,constants['ACT_START_CRAWLING']:3,constants['ACT_CROUCHING']:2,constants['ACT_START_CROUCHING']:1}.get(s['action'],0)
            return (result['caughtCrawler'],stage,result['lostFromWalk'],result['lostUpperFloor'],-d,s['forward'])
        ordered=sorted(candidates.values(),key=rank,reverse=True);kept=[];buckets=Counter()
        for c in ordered:
            s=c['record']['state'];bucket=(s['action'],s['floorOwner'],s['faceAngle'][1]//2048,round(s['forward']/4))
            if buckets[bucket]>=max(2,width//16):continue
            buckets[bucket]+=1;kept.append(c)
            if len(kept)>=width:break
        if len(kept)<width:
            used={id(c) for c in kept};kept.extend(c for c in ordered if id(c) not in used);kept=kept[:width]
        nxt=[]
        for c in kept:
            g.load_state(c['parent']['saved']);r=study.advance(g,o,c['pad']);assert r==c['record']
            nxt.append(dict(saved=g.save_state(),records=c['parent']['records']+[r],state=r['state']))
        frontier=nxt
        layers.append(dict(depth=depth,behavior=117+depth,expanded=expanded,uniqueObserved=len(candidates),slidingPruned=pruned,retained=len(nxt),
            minRetainedEdge=min((c['state']['edge']['clearance'] for c in nxt if c['state']['edge']),default=None)))
        if depth%2==0 or not frontier:print(json.dumps(dict(layer=layers[-1],observations=dict(counts),seconds=time.monotonic()-start)),flush=True)
        if not frontier:break
    validations={key:study.verify(w) for key,w in selected.items()}
    report=dict(schema=1,scope=__doc__,setup=setup,width=width,menu=pads,layers=layers,
        expanded=sum(l['expanded'] for l in layers),pathObservations=dict(counts),selected=selected,validations=validations,
        aInputs=0,postSetupWrites='Controller fields only; whole-state restores separate alternatives',
        scriptSha256=study.prior.sha(__file__),dependencies={'ink_walk_edge_crawl.py':study.prior.sha(study.__file__)})
    with output.open('x',encoding='utf-8') as f:json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),expanded=report['expanded'],observations=dict(counts),
        selected={k:v['outcome'] for k,v in selected.items()})),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--width',type=int,default=64);a=p.parse_args();run(a.output,a.width)
