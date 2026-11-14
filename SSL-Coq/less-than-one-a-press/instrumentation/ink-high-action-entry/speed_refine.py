"""48 initial-air velocity refinements of two confirmed native two-push misses.

All Mario writes remain in the initial FREEFALL seed. Exact shell/box XYZ
cuts before129 are reused. A box-only cut before130 is permitted if a native
grounded high pad endpoint without a platform is reached. No delivery claim.
"""
import argparse,json,sys,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from actor_cuts import create,make_seed,small,cut,action_event,pad_distance,box_to,full
from prelude import ROOT,advance,NEUTRAL,rich_sample,frame_events,digest

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    source=ROOT/'build/wafel-pilot/ink-high-shell-actor-cuts-20261114-preserved.json';prior=json.loads(source.read_text());bases=[s['recipe'] for s in prior['selectedBothPushed']]
    g,o,states,slot,prep=create(a.capture);start=time.time();rows=[];seconds=[];positive=[];best=[]
    ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING']}
    counts=dict(initialAirRecipes=0,nativeSlide128=0,groundPad129AnyY=0,highGroundPadWithoutPlatform129=0,secondActorCuts130=0,captures=0,useful=0)
    for bi,base in enumerate(bases):
      for speed in [24,40,64,100,160,256]:
       for yaw in [0,16384,32768,49152]:
        r=dict(base,seed=dict(base['seed'],speed=speed,yaw=yaw));seed=make_seed(g,o,states[128],slot,r['seed'],True);counts['initialAirRecipes']+=1;counts['nativeSlide128']+=seed['after']['action']==g.constant('ACT_BUTT_SLIDE')
        actorEdits=cut(g,r['box129'],r['shell129']);advance(g,NEUTRAL);after129=rich_sample(g,o);events129=frame_events(g);state130=g.save_state();advance(g,NEUTRAL);event130=action_event(g);producer=rich_sample(g,o);advance(g,NEUTRAL);accept=rich_sample(g,o)
        cap=accept['used']==64 and accept['floorOwner']==accept['platform']==61
        row=dict(baseIndex=bi,recipe=r,seed=seed,actorEdits=actorEdits,after129=after129,events129=events129,firstAction130=event130,after130=producer,after131=accept,capture=cap);rows.append(row)
        inpad=after129['action'] in ground and pad_distance(after129['movement'])<=.1;counts['groundPad129AnyY']+=inpad
        gate=inpad and 1700<=after129['movement'][1]<=2000 and after129['platform']==-1;counts['highGroundPadWithoutPlatform129']+=gate
        sc=(int(gate),int(inpad),int(after129['action'] in ground),int(1740<=after129['movement'][1]<=1801),-pad_distance(after129['movement']))
        best.append((sc,r));best.sort(key=lambda x:x[0],reverse=True);best=best[:4]
        if cap:
            t=full(g,o,states,slot,r);counts['captures']+=1;counts['useful']+=t['useful'];positive.append(r);print('CAPTURE',r,'useful',t['useful'],flush=True)
        if gate:
          print('PAD_GATE',r,after129['movement'],flush=True);proposals=[]
          for origin in [after129['movement']]+([event130['pos']] if event130 else []):
           for target in [(x,z) for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]:
            b=box_to(origin,after129['collision'],target)
            if b is not None and b not in proposals:proposals.append(b)
          for b in proposals:
            if counts['secondActorCuts130']>=152:break
            rr=dict(r,box130=b);g.load_state(state130);edits=cut(g,b);advance(g,NEUTRAL);p130=rich_sample(g,o);advance(g,NEUTRAL);a131=rich_sample(g,o);counts['secondActorCuts130']+=1
            cap=a131['used']==64 and a131['floorOwner']==a131['platform']==61;seconds.append(dict(recipe=rr,edits=edits,after130=p130,after131=a131,capture=cap))
            if cap:
                t=full(g,o,states,slot,rr);counts['captures']+=1;counts['useful']+=t['useful'];positive.append(rr);print('CAPTURE',rr,'useful',t['useful'],flush=True)
    selected=positive+[r for _,r in best]
    # Also preserve the highest-speed continuation in each heading at the
    # closest-pad base: these expose action/quarter-step failures directly.
    selected += [row['recipe'] for row in rows if row['baseIndex']==0 and row['recipe']['seed']['speed']==256]
    q,qo,qs,qslot,qprep=create(a.capture);assert qprep==prep;trials=[];seen=set()
    for r in selected:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,slot,r);assert t==full(q,qo,qs,qslot,r);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),actorHelperSha256=digest(ROOT/'instrumentation/ink-high-action-entry/actor_cuts.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),sourceReceiptSha256=digest(source),menu=dict(initialSpeeds=[24,40,64,100,160,256],headings=[0,16384,32768,49152],bases=bases,secondCutLimit=152,producerGateY=[1700,2000]),counts=counts,screenRows=rows,secondCuts=seconds,trials=trials,freshBoundaries=sum(len(t['samples'])+1 for t in trials),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
