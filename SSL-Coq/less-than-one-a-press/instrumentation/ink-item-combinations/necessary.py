"""Targeted actor geometry with per-actor necessity checks; ground state supplied.

This is NOT an action-entry search. It asks whether two/three stock actors
can each matter once a high butt slide already exists. All positive recipes
and each removal are continued independently through the Area2/death window.
"""
import argparse,json,sys,math,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import ROOT,roots,trial,digest
from fixtures import f32

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();g,o,base,inv,catalog,prep=roots(a.capture);start=time.time();screens=[];triples=[];full=[];cases=[];found=set();fullAttempts={}
    baseRecipe=dict(kind='supplied-ground-control',height=25000,flavor='native',geometry='east',buttons=0,action='ACT_BUTT_SLIDE',speed=20,vy=0)
    firstCenters=[[-39,-39],[-39,0],[-39,39],[-60,-20],[-60,20]];boxCenters=[[x,z] for x in [-10,-30,-50] for z in [-70,-50,-30,0,30,50,70]]
    def evaluate(r,group):
        t=trial(g,o,base,catalog,r);row=dict(group=group,recipe=r,samples=t['samples'],firstEvents=t['firstEvents'],capture=t['capture'],removals=[]);screens.append(row)
        if t['capture']:
            removals=[]
            for name in r['actors']:
                rr=dict(r,actors=[n for n in r['actors'] if n!=name],removedActor=name);u=trial(g,o,base,catalog,rr);row['removals'].append(dict(actor=name,capture=u['capture'],samples=u['samples']));removals.append(rr)
            if not any(x['capture'] for x in row['removals']) and group not in found and fullAttempts.get(group,0)<10:
                fullAttempts[group]=fullAttempts.get(group,0)+1;tt=trial(g,o,base,catalog,r,True);us=[trial(g,o,base,catalog,rr,True) for rr in removals];full.extend([tt]+us)
                if tt['useful'] and not any(u['useful'] for u in us):
                    found.add(group);cases.append(dict(group=group,recipe=r,original=tt,removals=us));print('ALL_NECESSARY',group,r,flush=True)
        return t
    for first,group,family in [('shell','pair_shell_box','shell_box'),('buddy','pair_buddy_box','buddy_box')]:
      for dx,dz in firstCenters:
       for bx,bz in boxCenters:
        positions={first:[-1950+dx,24990 if first=='shell' else 25000,-939+dz],'box':[-1950+bx,25000,-939+bz]}
        r=dict(baseRecipe,family=family,actors=[first,'box'],positions=positions);t=evaluate(r,group)
        if first=='shell' and not t['capture'] and t['samples'][0]['movement'][1]==768 and t['samples'][0]['display'][1]>20000:
            pos=t['samples'][0]['display']
            for tx,tz in [(-1882,-949),(-1882,-939),(-1882,-929)]:
                dxq,dzq=tx-pos[0],tz-pos[2];d=math.hypot(dxq,dzq)
                if not .5<d<126.5:continue
                buddy=[f32(tx-127*dxq/d),25000,f32(tz-127*dzq/d)]
                if math.hypot(buddy[0]+1950,buddy[2]+939)>=136.9:continue
                rr=dict(baseRecipe,family='buddy_shell_box',actors=['shell','box','buddy'],positions=dict(positions,buddy=buddy));triples.append(rr)
    for r in triples:evaluate(r,'triple_shell_box_buddy')
    vpuCases=[]
    for case,height in [(case,height) for case in cases for height in [67277,90536]]:
        original=case['recipe'];shift=height-original['height'];r=dict(original,height=height,positions={n:[p[0],f32(p[1]+shift),p[2]] for n,p in original['positions'].items()})
        tt=trial(g,o,base,catalog,r,True);us=[trial(g,o,base,catalog,dict(r,actors=[n for n in r['actors'] if n!=name],removedActor=name),True) for name in r['actors']];full.extend([tt]+us)
        vpuCases.append(dict(group=case['group'],recipe=r,original=tt,removals=us,allNecessary=tt['useful'] and not any(u['useful'] for u in us)))
        print('VPU_MATCH',case['group'],height,'useful',tt['useful'],'allNecessary',vpuCases[-1]['allNecessary'],flush=True)
    # Repeat every selected positive and removal from an independently booted
    # native prefix; statuses are never reset during a continuation.
    q,qo,qbase,qinv,qcat,qprep=roots(a.capture);assert qprep==prep and qinv==inv
    for t in full:assert t==trial(q,qo,qbase,qcat,t['recipe'],True)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),helperSha256=digest(ROOT/'instrumentation/ink-item-combinations/search.py'),fixtureSha256=digest(ROOT/'instrumentation/ink-item-clone-controls/fixtures.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),shellPreparation=prep,menu=dict(firstRelativeCenters=firstCenters,boxRelativeCenters=boxCenters,buddyTargetXZ=[[-1882,-949],[-1882,-939],[-1882,-929]],maxFullNecessityAttemptsPerFamily=10,height=25000,matchedVpuHeights=[67277,90536]),counts=dict(primaryGeometryRecipes=len(screens),pairRecipes=210,tripleRecipes=len(triples),captureRecipes=sum(t['capture'] for t in screens),necessaryFamilies=len(cases),removalScreens=sum(len(t['removals']) for t in screens),matchedVpuRecipes=len(vpuCases),matchedVpuAllNecessary=sum(c['allNecessary'] for c in vpuCases),fullHistories=len(full)),screens=screens,necessaryCases=cases,matchedVpuCases=vpuCases,fullTrials=full,freshBoundaries=sum(len(t['samples']) for t in full),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',result['counts'],'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
