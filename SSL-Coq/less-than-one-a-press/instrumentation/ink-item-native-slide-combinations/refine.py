"""Targeted near-tangent Buddy placements around the named south predecessor.

The native initializer and phase-129 actor XYZ cuts are the only edits.
Selected pad arrivals also receive a disclosed box-only XYZ cut at phase130.
"""
import json,math,sys,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import *

def main():
    capture,out=map(Path,sys.argv[1:3]);g,o,states,slot,prep=roots(capture)
    start=time.time();screens=[];producer=[];best=[];positives=[];seeds=[]
    ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING','ACT_WALKING']}
    counts=dict(nativeSeeds=0,lowNativeSeeds=0,buddyCombinations=0,padAnyHeight=0,padLowHeight=0,producerTrials=0,captures=0,useful=0)
    near=NEAR[0]
    offsets=[(0,0)]+[(d,0) for d in [-8,-4,-2,2,4,8]]+[(0,d) for d in [-8,-4,-2,2,4,8]]
    for dx,dz in offsets:
        sr=dict(near['seed'],pos=[near['seed']['pos'][0]+dx,21700,near['seed']['pos'][2]+dz])
        seed=make_seed(g,o,states[128],slot,sr);before=small(g,o);seeds.append(dict(recipe=sr,after128=before));counts['nativeSeeds']+=1
        if before['action'] not in ground or before['platform']!=61 or not 1740<=before['movement'][1]<=1801:continue
        counts['lowNativeSeeds']+=1;state=g.save_state();c=before['collision']
        for family in ['box-buddy','shell-box-buddy']:
            r0=dict(name='south-tangent-refinement',seed=sr,family=family,box129=[near['box129'][0]+dx,c[1],near['box129'][2]+dz])
            if family=='shell-box-buddy':r0['shell129']=[near['shell129'][0]+dx,c[1],near['shell129'][2]+dz]
            for radius in [132,136,136.9]:
              for yaw in range(47104,51201,256):
                a=yaw*math.tau/65536;r=dict(r0,buddy129=[f32(c[0]+radius*math.sin(a)),c[1],f32(c[2]+radius*math.cos(a))])
                g.load_state(state);cut(g,r);advance(g,NEUTRAL);s=small(g,o);e=event(g);counts['buddyCombinations']+=1
                pad=s['action'] in ground and distance(s['movement'])<.01;low=1740<=s['movement'][1]<=1801
                counts['padAnyHeight']+=pad;counts['padLowHeight']+=pad and low
                row=dict(recipe=r,before129=before,after129=s,event=e,padDistance=distance(s['movement']));screens.append(row)
                score=(int(pad and low),int(pad),-distance(s['movement']),int(low));best.append((score,r));best.sort(key=lambda v:v[0],reverse=True);best=best[:8]
                if not pad:continue
                state130=g.save_state();advance(g,NEUTRAL);ue=event(g)
                boxes=[None]
                for p in [s['movement']]+([ue['pos']] if ue else []):
                  for tx in [-2220,-2210,-2190,-1890,-1882,-1874]:
                   for tz in [-1120,-1075,-1023,-970,-939,-925]:
                    b=to_target(p,s['collision'],[tx,tz],107,112)
                    if b is not None and b not in boxes:boxes.append(b)
                for b in boxes:
                    g.load_state(state130)
                    if b:cut(g,dict(box129=b))
                    advance(g,NEUTRAL);p=small(g,o);pe=event(g);advance(g,NEUTRAL);accept=small(g,o);counts['producerTrials']+=1
                    rr=dict(r,box130=b) if b else r
                    producer.append(dict(recipe=rr,producer=p,producerEvent=pe,accept=accept))
                    if accept['used']==64 and accept['floorOwner']==accept['platform']==61:
                        counts['captures']+=1;t=full(g,o,states,rr);counts['useful']+=t['useful'];positives.append(rr)
                        print('CAPTURE',rr,'useful',t['useful'],flush=True)
        print('SEED',dx,dz,counts,'best',best[0][0],flush=True)
    q,qo,qs,qslot,qprep=roots(capture);assert prep==qprep;trials=[];seen=set()
    closest=best[0][1];keys=[k for k in ['shell129','box129','buddy129'] if k in closest]
    ablations=[]
    for mask in range(1<<len(keys)):
        r={k:v for k,v in closest.items() if k not in keys};r['ablationMask']=mask
        for i,k in enumerate(keys):
            if mask&(1<<i):r[k]=closest[k]
        ablations.append(r)
    for r in positives+[r for _,r in best]+ablations:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchSha256=digest(Path(__file__).with_name('search.py')),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,menu=dict(offsets=offsets,buddyRadii=[132,136,136.9],buddyAngles=list(range(47104,51201,256))),counts=counts,seeds=seeds,screens=screens,producerScreens=producer,closest=closest,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start)
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],'CLOSEST',closest,flush=True)

if __name__=='__main__':main()
