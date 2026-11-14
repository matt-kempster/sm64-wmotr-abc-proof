"""Correct initial airborne X/Z to the known native post-128 predecessor.

This is a bounded native initializer comparison, not a controller route:
the initial airborne Mario and shell, then the named actors, are supplied.
"""
import sys,json,copy,math
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import *

def main():
    capture,controls,out=map(Path,sys.argv[1:4]);old=json.loads(controls.read_text());base=old['witness']
    g,o,states,slot,prep=roots(capture);q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep
    trials=[];selected=None
    for y in [1810,1830,1900]:
        x,z=-1920.,-1210.
        for iteration in range(3):
            r=copy.deepcopy(base);r['name']='low-air-position-correction';r['iteration']=iteration;r['seed']['pos']=[x,y,z]
            t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
            s=t['seed']['after'];print(y,iteration,'initial',x,z,'native',s['movement'],s['actionName'],'capture',t['capture'],'useful',t['useful'],flush=True)
            if t['useful'] and selected is None:selected=r
            x=f32(x+(-1920-s['movement'][0]));z=f32(z+(-1210-s['movement'][2]))
    if selected:
        for key in ['box129','buddy129','box130','all']:
            r=copy.deepcopy(selected);r['name']='low-positive-without-'+key
            for k in ['box129','buddy129','box130'] if key=='all' else [key]:del r[k]
            t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
            print(r['name'],'capture',t['capture'],'useful',t['useful'],flush=True)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchSha256=digest(Path(__file__).with_name('search.py')),controlsSha256=digest(controls),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,menu=dict(initialY=[1810,1830,1900],iterationsPerY=3,targetPost128XZ=[-1920,-1210],correction='next initial X/Z = current initial X/Z + target minus observed native post128 X/Z, rounded binary32'),selected=selected,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials))
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',len(trials),'FRESH',result['freshBoundaries'],'SELECTED',selected,flush=True)

if __name__=='__main__':main()
