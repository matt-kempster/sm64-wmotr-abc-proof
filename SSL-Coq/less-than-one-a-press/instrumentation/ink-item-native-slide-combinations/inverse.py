"""Place the second push toward pad points before the first ground quarter.

Each proposed Buddy position is derived from an actual native box-only
or shell-plus-box first-action position and filtered by old-C registration.
The radial calculation proposes states; the native engine decides results.
"""
import sys,json,math,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import *

def main():
    capture,out=map(Path,sys.argv[1:3]);g,o,states,slot,prep=roots(capture);start=time.time()
    ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING','ACT_WALKING']}
    counts=dict(nativeSeeds=0,firstPushTrials=0,feasibleBuddyCandidates=0,firstActionPad=0,endPad=0,endLowPad=0,producerTrials=0,captures=0,useful=0)
    bases=[];screens=[];producer=[];best=[];positives=[]
    for dx in [0,-2]:
        near=NEAR[0];sr=dict(near['seed'],pos=[-1920+dx,21700,-1210]);make_seed(g,o,states[128],slot,sr);before=small(g,o);c=before['collision'];state=g.save_state();counts['nativeSeeds']+=1
        for family in ['box-buddy','shell-box-buddy']:
          for radius in [80,100,111]:
           for yaw in range(40960,49153,256):
            a=yaw*math.tau/65536
            base=dict(name='south-inverse-refinement',seed=sr,family=family,box129=[f32(c[0]+radius*math.sin(a)),c[1],f32(c[2]+radius*math.cos(a))])
            if family=='shell-box-buddy':base['shell129']=[near['shell129'][0]+dx,c[1],near['shell129'][2]]
            g.load_state(state);cut(g,base);advance(g,NEUTRAL);e=event(g);counts['firstPushTrials']+=1
            bases.append(dict(recipe=base,event=e,after129=small(g,o)))
            if e is None:continue
            proposals=[]
            for tx in [-2147,-2140,-2130]:
              for tz in [-1123,-1115,-1105]:
                b=to_target(e['pos'],c,[tx,tz],127,137)
                if b is not None and b not in proposals:proposals.append(b)
            for b in proposals:
                r=dict(base,buddy129=b);g.load_state(state);cut(g,r);advance(g,NEUTRAL);s=small(g,o);ev=event(g);counts['feasibleBuddyCandidates']+=1
                epad=ev is not None and distance(ev['pos'])<.01;pad=s['action'] in ground and distance(s['movement'])<.01;low=1740<=s['movement'][1]<=1801
                counts['firstActionPad']+=epad;counts['endPad']+=pad;counts['endLowPad']+=pad and low
                row=dict(recipe=r,before129=before,event=ev,after129=s,firstActionPad=epad,padDistance=distance(s['movement']));screens.append(row)
                score=(int(pad and low),int(epad),int(pad),-distance(s['movement']));best.append((score,r));best.sort(key=lambda v:v[0],reverse=True);best=best[:8]
                if not pad:continue
                state130=g.save_state();advance(g,NEUTRAL);ue=event(g);boxes=[None]
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
        print('SEED',dx,counts,'BEST',best[0][0] if best else None,flush=True)
    q,qo,qs,qslot,qprep=roots(capture);assert qprep==prep;trials=[];seen=set();selected=positives+[r for _,r in best]
    closest=best[0][1] if best else None
    if closest:
        keys=[k for k in ['shell129','box129','buddy129'] if k in closest]
        for mask in range(1<<len(keys)):
            r={k:v for k,v in closest.items() if k not in keys};r['ablationMask']=mask
            for i,k in enumerate(keys):
                if mask&(1<<i):r[k]=closest[k]
            selected.append(r)
    for r in selected:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,r);assert t==full(q,qo,qs,r);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,proofRevision='08b72af44fbb54aaef3ed7f8be399868ba75db98',decompileRevision='36fbf8d693a9fc2bdec0c77402f8e96d07d2f461',scriptSha256=digest(__file__),searchSha256=digest(Path(__file__).with_name('search.py')),captureSha256=digest(capture),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),preparation=prep,menu=dict(seedXOffsets=[0,-2],boxRadii=[80,100,111],boxAngles=list(range(40960,49153,256)),buddyInverseTargets=[[x,z] for x in [-2147,-2140,-2130] for z in [-1123,-1115,-1105]]),counts=counts,bases=bases,screens=screens,producerScreens=producer,closest=closest,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start)
    with out.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],'CLOSEST',closest,flush=True)

if __name__=='__main__':main()
