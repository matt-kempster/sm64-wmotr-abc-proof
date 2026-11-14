"""Package selected verified histories, menus, raw hashes, and all positives."""
import sys,json
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,digest

NAMES={'initial':'ink-item-native-slide-combinations-20261114.json','tangent':'ink-item-native-slide-refine-20261114.json','inverse':'ink-item-native-slide-inverse-20261114.json','height':'ink-item-native-slide-controls-20261114.json','low':'ink-item-native-slide-low-entry-20261114.json','noShell':'ink-item-native-slide-no-shell-20261114.json'}

def summary(t):
    def small(s):return {k:s[k] for k in ['movement','collision','display','actionName','floorY','floorOwner','platform','used','area']}
    return dict(recipe=t['recipe'],after128=small(t['seed']['after']),after129=small(t['samples'][0]),after130=small(t['samples'][1]),after131=small(t['samples'][2]),capture=t['capture'],useful=t['useful'],final=small(t['samples'][-1]))

def main():
    out=Path(sys.argv[1]);data={k:json.loads((ROOT/'build/wafel-pilot'/v).read_text()) for k,v in NAMES.items()}
    batches={k:dict(path='build/wafel-pilot/'+NAMES[k],sha256=digest(ROOT/'build/wafel-pilot'/NAMES[k]),counts=v.get('counts'),menu=v.get('menu'),freshHistories=len(v['trials']),freshBoundaries=v['freshBoundaries'],scriptSha256=v['scriptSha256']) for k,v in data.items()}
    selected=[]
    for k in ['initial','tangent']:selected.append(dict(batch=k,history=data[k]['trials'][0]))
    for t in data['height']['trials']:
        if t['recipe']['name']=='same-actor-cuts-air-y-control' and t['recipe']['seed']['pos'][1] in [19900,21700]:selected.append(dict(batch='height',history=t))
    for t in data['low']['trials']:
        if 'without' in t['recipe']['name'] or t['recipe'].get('iteration')==1 or (t['recipe']['seed']['pos'][1]==1810 and t['recipe'].get('iteration')==0):selected.append(dict(batch='low',history=t))
    selected.extend(dict(batch='noShell',history=t) for t in data['noShell']['trials'])
    result=dict(schema=1,date='2026-11-14',proofRevision=data['low']['proofRevision'],decompileRevision=data['low']['decompileRevision'],runtime='Wafel 0.8.5 / Python 3.9.13 / JP instrumented native DLL',runtimeSha256=data['low']['runtimeSha256'],captureSha256=data['low']['captureSha256'],helpersSha256=data['initial']['helpersSha256'],sourceSha256=data['initial']['sourceSha256'],packageScriptSha256=digest(__file__),batches=batches,totalFreshHistories=sum(v['freshHistories'] for v in batches.values()),totalFreshBoundaries=sum(v['freshBoundaries'] for v in batches.values()),lowWitness=data['low']['selected'],positiveInverseRecipes=data['height']['positiveRecipes'],heightResults=[summary(t) for t in data['height']['trials']],lowResults=[summary(t) for t in data['low']['trials']],noShellResults=[summary(t) for t in data['noShell']['trials']],selectedHistories=selected)
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('PACKAGED',len(selected),'histories;',result['totalFreshHistories'],'fresh runs;',result['totalFreshBoundaries'],'boundaries;',out.stat().st_size,'bytes;',digest(out))

if __name__=='__main__':main()
