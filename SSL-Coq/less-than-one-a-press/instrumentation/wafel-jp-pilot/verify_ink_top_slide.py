"""Audit and package the finite native top-slide experiment; no game writes.

This checks receipts, recorded fresh comparisons, source hashes and a prior
positive crawl control. It does not repeat the search or prove completeness.
"""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_top_slide_to_crawl as study


def run(raw_path,output):
    raw=json.loads(raw_path.read_text(encoding='utf-8'))
    source=json.loads(study.SOURCE.read_text(encoding='utf-8'))
    assert raw['scriptSha256']==study.sha(Path(study.__file__))
    assert raw['sourceReceiptSha256']==study.sha(study.SOURCE)
    assert raw['runtimeSha256']==study.sha(study.ROOT/'build/wafel-pilot/sm64_jp.dll')
    for name,digest in raw['dependencies'].items():
        assert study.sha(Path(study.__file__).with_name(name))==digest,name
    names=source['controls']['actionNames']
    constants={name:int(value) for value,name in names.items() if name in study.NAMES}
    assert set(constants)==set(study.NAMES)
    expected=source['controls']['selected']['topRecapture']
    for root,batch in raw['batches'].items():
        setup=batch['setup']; count=2 if root=='landing113' else 6
        assert setup['exterior']==expected['initial']
        assert setup['suppliedEdits']==expected['suppliedEdits']
        assert setup['recipe']==expected['recipe']
        assert setup['exactInitialFeetClearance']>0
        assert setup['prefix']==[{k:v for k,v in r.items() if k!='squishTimer'} for r in expected['records'][:count]]
        rows=batch['results']; counts=Counter(policies=len(rows),frames=len(rows)*(39-count))
        for row in rows:
            for k,v in row['outcome'].items():
                if isinstance(v,bool):counts[k]+=v
        assert dict(counts)==batch['counts']
        beam=raw['beams'][root]
        assert len(beam['menu'])==100 and beam['width']==64
        assert sum(l['expanded'] for l in beam['layers'])==beam['expandedFrames']
        assert len(beam['layers'])==39-count
    histories={}; categories={}; observed=Counter(); minima={}
    for name,w in raw['selected'].items():
        setup=raw['batches'][w['root'].replace('_beam','')]['setup']
        v=raw['validations'][name]
        assert v['passed'] and v['prefixFrames']==len(setup['prefix'])
        assert len(w['records'])==v['comparedContinuationFrames']==len(v['meshes'])
        assert study.assess(w['records'],constants)==w['outcome']
        for index,(r,detail) in enumerate(zip(w['records'],v['meshes'])):
            s=r['state']
            assert r['executedTopTimer']==setup['rootState']['topTimer']+index
            assert r['executedTopAction']==1
            assert not r['input']['buttons']&0x8000
            assert not s['buttons']&0x8000 and not s['buttonsPressed']&0x8000
            assert not s['input']&0x82
            for key,value in detail['after']['native'].items():
                assert s[key]==value,(name,index,key)
            assert detail['after']['collision']==s['collision']
            assert detail['before']['native']['topTimer']==r['executedTopTimer']
            for e in r['entries']:observed[names.get(str(e['action']),str(e['action']))]+=1
        all_rows=setup['prefix']+w['records']
        pads=[r['input'] for r in all_rows]
        digest=hashlib.sha256(json.dumps(pads,sort_keys=True,separators=(',',':')).encode()).hexdigest()
        categories[name]=digest
        if digest in histories:
            for old,new in zip(histories[digest]['records'],all_rows):
                for key in ['executedTopTimer','input','entries']:assert old[key]==new[key]
                for key in old['state'].keys() & new['state'].keys():
                    assert old['state'][key]==new['state'][key]
        else:
            histories[digest]=dict(representative=name,frames=len(all_rows),records=all_rows)
        if w['outcome']['minimumTopSlideSpeed']:
            minima[name]=w['outcome']['minimumTopSlideSpeed']
    # Independent observed positive control: native crawl on the low roof,
    # already freshly replayed in the previous investigation. Not a new start.
    positive=[r for r in source['controls']['selected']['squish100']['records']
              if r['executedTopTimer']>=126]
    control=study.assess(positive,constants)
    assert control['crawl'] and not control['crawlOnTop'] and not control['deepCrawl']
    source_root=study.ROOT.parents[1].parent/'reference-sm64-decomp'
    source_paths=['src/game/mario_actions_moving.c','src/game/mario.c',
        'src/game/mario_actions_stationary.c','src/game/mario_actions_object.c',
        'src/game/behaviors/pyramid_top.inc.c']
    # ROOT is SSL-Coq/less-than-one-a-press; its third parent is workspace.
    assert source_root.is_dir(),source_root
    summary=dict(passed=True,rawReportSha256=study.sha(raw_path),
        uniqueFreshHistories=len(histories),
        comparedFramesInUniqueHistories=sum(w['frames'] for w in histories.values()),
        categoryToHistory=categories,
        uniqueHistories={k:{'representative':v['representative'],'frames':v['frames']} for k,v in histories.items()},
        selectedActionEntryOccurrences=dict(observed),selectedMinima=minima,
        priorPositiveControl=dict(source='controls.selected.squish100',reused=True,
            behaviorRange=[126,129],crawl=True,crawlOnTop=False,deepCrawl=False),
        meaning='Finite native observations and recorded fresh comparisons; not whole-memory equivalence or an all-input proof')
    raw['verificationSummary']=summary
    raw['actionNames']=names
    raw['sourceReferences']={p:study.sha(source_root/p) for p in source_paths}
    raw['additionalDependencySha256']={n:study.sha(Path(study.__file__).with_name(n)) for n in
        ['ink_crawl_predecessors.py','verify_ink_top_slide.py']}
    raw['prefixSha256']=study.sha(study.ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl')
    raw['inheritedSetup']='Accepted pre-game debug level select; 2,548 recorded A-off inputs and native neutral waiting. No normal-play approach to the supplied exterior pose is claimed.'
    with output.open('x',encoding='utf-8') as f:
        json.dump(raw,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),bytes=output.stat().st_size,
        uniqueFreshHistories=summary['uniqueFreshHistories'],
        comparedFrames=summary['comparedFramesInUniqueHistories'],
        counts={k:v['counts'] for k,v in raw['batches'].items()},
        beamFrames={k:v['expandedFrames'] for k,v in raw['beams'].items()},
        minima=minima)))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('raw',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();run(a.raw,a.output)
