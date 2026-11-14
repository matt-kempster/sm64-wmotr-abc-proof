"""Fresh selected positive, actor-removal controls, and lower initial air Y.

The height menu changes only the single initial FREEFALL pose and matching
shell Y placement in make_seed. Phase129/130 actor cuts remain numerically
identical to the positive recipe, including their actual Y coordinates.
"""
import sys,json,copy,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import *

def main():
    capture,raw,out=map(Path,sys.argv[1:4]);parent=json.loads(raw.read_text());witness=next(t['recipe'] for t in parent['trials'] if t['useful'])
    g,o,states,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep
    menu=[1809.2869873046875,1810,1830,1870,1900,2000,2500,19900,20100,21700]
    recipes=[]
    for y in menu:
        r=copy.deepcopy(witness);r['name']='same-actor-cuts-air-y-control';r['seed']['pos'][1]=y;recipes.append(r)
    for key in ['box129','buddy129','box130']:
        r=copy.deepcopy(witness);del r[key];r['name']='positive-without-'+key;recipes.append(r)
    r=copy.deepcopy(witness);r['name']='positive-without-later-actor-cuts'
    for key in ['box129','buddy129','box130']:del r[key]
    recipes.append(r)
    trials=[]
    for r in recipes:
        t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
        print(r['name'],r['seed']['pos'][1],'native',t['seed']['after']['actionName'],t['seed']['after']['movement'],'capture',t['capture'],'useful',t['useful'],flush=True)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchSha256=digest(Path(__file__).with_name('search.py')),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),rawInverseSha256=digest(raw),rawInverseCounts=parent['counts'],rawInverseFreshBoundaries=parent['freshBoundaries'],positiveRecipes=[t['recipe'] for t in parent['trials'] if t['useful']],preparation=prep,initialHeightMenu=menu,witness=witness,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',len(trials),'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
