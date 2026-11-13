"""Read-only audit and packaging of the walking-edge native receipts."""
import argparse
import hashlib
import json
import math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_walk_edge_crawl as study


def segment_distance(p,a,b):
    vx,vz=b[0]-a[0],b[1]-a[1]
    t=max(0,min(1,((p[0]-a[0])*vx+(p[2]-a[1])*vz)/(vx*vx+vz*vz)))
    return math.hypot(p[0]-(a[0]+t*vx),p[2]-(a[1]+t*vz))


def run(main_path,refined_path,output):
    main=json.loads(main_path.read_text(encoding='utf-8'))
    refined=json.loads(refined_path.read_text(encoding='utf-8'))
    source=json.loads(study.SOURCE.read_text(encoding='utf-8'))
    sha=study.prior.sha;folder=Path(study.__file__).parent
    assert main['scriptSha256']==sha(study.__file__)
    assert main['sourceSha256']==sha(study.SOURCE)
    assert main['runtimeSha256']==sha(study.prior.ROOT/'build/wafel-pilot/sm64_jp.dll')
    assert refined['scriptSha256']==sha(folder/'ink_walk_edge_refine.py')
    for data in [main,refined]:
        for name,digest in data['dependencies'].items():assert sha(folder/name)==digest,name
    groups=[]
    for kind,group in [('policies',main['batches']),('beam',main['beams'])]:
        for root,batch in group.items():groups.append((kind+root,batch,main['validations'][kind+root]))
    groups.append(('refined117',refined,refined['validations']))
    histories={};categories={};minima={};geometry_checks=0
    for label,group,validations in groups:
        setup=group['setup']
        assert setup['exteriorSetup']==source['cases']['uphill-wait4-z']['setup']
        prefix=setup['exteriorSetup']['prefix']+setup['prefix']
        assert setup['prefix']==source['cases']['uphill-wait4-z']['witness']['records'][:len(setup['prefix'])]
        if 'results' in group:
            assert len(group['results'])==group['counts']['policies']
            assert group['counts']['frames']==len(group['results'])*(150-setup['root'])
            for key,value in group['counts'].items():
                if key not in ['policies','frames']:assert value==sum(r['outcome'][key] for r in group['results'])
        if 'expanded' in group:assert group['expanded']==sum(v['expanded'] for v in group['layers'])
        for key,w in group['selected'].items():
            v=validations[key];assert v['passed']
            assert v['prefixFrames']==len(prefix)
            assert v['comparedContinuationFrames']==len(w['records'])==len(v['meshes'])
            for i,(r,detail) in enumerate(zip(w['records'],v['meshes'])):
                s=r['state'];assert r['executedTopTimer']==setup['root']+1+i
                assert not r['input']['buttons']&0x8000 and not s['input']&0x82
                assert not s['buttons']&0x8000 and not s['buttonsPressed']&0x8000
                for field,value in detail['after']['native'].items():assert s[field]==value
                assert s['collision']==detail['after']['collision']
                top=detail['after']['topMesh'];base=study.projected_base(top)
                # Independent point-to-segment calculation for all retained
                # interior-footprint samples, rather than the search's cross product.
                if s['edge'] and s['edge']['clearance']>=0:
                    d=min(segment_distance(s['position'],a,b) for a,b in zip(base,base[1:]+base[:1]))
                    assert abs(d-s['edge']['clearance'])<1e-7
                    geometry_checks+=1
            rows=prefix+w['records'];pads=[r['input'] for r in rows]
            assert all(not p['buttons']&0x8000 for p in pads)
            digest=hashlib.sha256(json.dumps(pads,sort_keys=True,separators=(',',':')).encode()).hexdigest()
            categories[label+'.'+key]=digest
            histories.setdefault(digest,dict(representative=label+'.'+key,frames=len(rows)))
            minima[label+'.'+key]=w['outcome'][key]
    decomp=study.prior.ROOT.parents[1].parent/'reference-sm64-decomp'
    sources=['src/game/mario_step.c','src/game/mario.c','src/game/mario_actions_moving.c',
             'src/game/mario_actions_stationary.c','src/game/mario_actions_airborne.c']
    audit=dict(passed=True,uniqueFreshHistories=len(histories),comparedFrames=sum(h['frames'] for h in histories.values()),
        histories=histories,categories=categories,minima=minima,independentEdgeDistanceChecks=geometry_checks,
        scope='Recorded fresh projections and derived edge distances; not whole-memory equivalence or exhaustive input coverage')
    report=dict(schema=1,main=main,refined=refined,audit=audit,
        rawHashes={main_path.name:sha(main_path),refined_path.name:sha(refined_path)},
        sourceHashes={name:sha(decomp/name) for name in sources},auditScriptSha256=sha(__file__),
        prefixSha256=sha(study.prior.ROOT/'build/wafel-pilot/capture.bKv95w/inputs.jsonl'))
    with output.open('x',encoding='utf-8') as f:json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),bytes=output.stat().st_size,audit=audit)))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('main',type=Path);p.add_argument('refined',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();run(a.main,a.refined,a.output)
