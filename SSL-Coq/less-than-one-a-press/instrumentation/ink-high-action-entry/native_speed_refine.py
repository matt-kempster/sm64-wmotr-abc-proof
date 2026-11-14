"""48 velocity refinements with a real airborne update before shell mounting.

Initial FREEFALL is supplied before127 at Y21716. Neutral update127 runs
native air-speed/slide-velocity code; only shell XYZ is placed before128.
Z128 and supplied actor XYZ129 follow. No Mario field is edited after127.
"""
import argparse,json,sys,math,time
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from actor_cuts import create,small,cut,action_event,pad_distance,box_to,actor
from prelude import ROOT,advance,NEUTRAL,pose,write,f32,rich_sample,frame_events,digest

def initializer(g,o,state,slot,r):
    g.load_state(state);g.mode='setup';edits=[];pose(g,r['pos'],edits);yaw=r['yaw'];speed=r['speed'];ang=yaw*math.tau/65536
    for k,v in [('action',g.constant('ACT_FREEFALL')),('actionState',0),('actionTimer',0),('forwardVel',speed),('vel',[f32(speed*math.sin(ang)),-16,f32(speed*math.cos(ang))]),('faceAngle',[0,yaw if yaw<32768 else yaw-65536,0])]:write(g,'gMarioState.'+k,v,edits)
    g.mode='controls';initial=rich_sample(g,o);advance(g,NEUTRAL);after127=rich_sample(g,o);events127=frame_events(g)
    m=g.read('gMarioState.pos');shell=[m[0],f32(m[1]-10),m[2]];shellEdits=cut(g,shell=shell);advance(g,dict(buttons=0x2000,stick=[0,0]))
    return dict(recipe=r,initial=initial,edits=edits,controls=[NEUTRAL,dict(buttons=0x2000,stick=[0,0])],after127=after127,events127=events127,shellBefore128=shell,shellEdits=shellEdits,after128=rich_sample(g,o),events128=frame_events(g))

def full(g,o,states,slot,r):
    seed=initializer(g,o,states[127],slot,r['seed']);t=dict(recipe=r,seed=seed,actorCuts=[dict(beforePhase=129,edits=cut(g,r['box129'],r['shell129']))],samples=[],events=[],actors=[],controls=[])
    for i in range(35):
        if i==1 and r.get('box130') is not None:t['actorCuts'].append(dict(beforePhase=130,edits=cut(g,r['box130'])))
        advance(g,NEUTRAL);s=rich_sample(g,o);t['samples'].append(s);t['events'].append(frame_events(g));t['actors'].append(dict(box=actor(g,49),shell=actor(g,slot)));t['controls'].append(NEUTRAL)
        if s['area']!=1:break
    t['capture']=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in t['samples']);arrival=next((s for s in t['samples'] if s['area']==2),None);t['useful']=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return t

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();source=ROOT/'build/wafel-pilot/ink-high-shell-actor-cuts-20261114-preserved.json';bases=[s['recipe'] for s in json.loads(source.read_text())['selectedBothPushed']]
    g,o,states,slot,prep=create(a.capture);start=time.time();rows=[];seconds=[];positive=[];best=[];ground={g.constant(n) for n in ['ACT_BUTT_SLIDE','ACT_CROUCH_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING']}
    counts=dict(initialAirRecipes=0,nativeSlide128=0,groundPad129AnyY=0,highGroundPadWithoutPlatform129=0,secondActorCuts130=0,captures=0,useful=0)
    for bi,base in enumerate(bases):
      for speed in [24,40,64,100,160,256]:
       for yaw in [0,16384,32768,49152]:
        sr=dict(base['seed'],phase=127,pos=[base['seed']['pos'][0],21716,base['seed']['pos'][2]],speed=speed,yaw=yaw);r=dict(base,seed=sr);seed=initializer(g,o,states[127],slot,sr);counts['initialAirRecipes']+=1;counts['nativeSlide128']+=seed['after128']['action']==g.constant('ACT_BUTT_SLIDE')
        edits=cut(g,r['box129'],r['shell129']);advance(g,NEUTRAL);after129=rich_sample(g,o);events129=frame_events(g);state130=g.save_state();advance(g,NEUTRAL);e130=action_event(g);p130=rich_sample(g,o);advance(g,NEUTRAL);a131=rich_sample(g,o);cap=a131['used']==64 and a131['floorOwner']==a131['platform']==61
        row=dict(baseIndex=bi,recipe=r,seed=seed,actorEdits=edits,after129=after129,events129=events129,firstAction130=e130,after130=p130,after131=a131,capture=cap);rows.append(row)
        inpad=after129['action'] in ground and pad_distance(after129['movement'])<=.1;counts['groundPad129AnyY']+=inpad;gate=inpad and 1700<=after129['movement'][1]<=2000 and after129['platform']==-1;counts['highGroundPadWithoutPlatform129']+=gate
        score=(int(gate),int(inpad),int(after129['action'] in ground),int(1740<=after129['movement'][1]<=1801),-pad_distance(after129['movement']));best.append((score,r));best.sort(key=lambda x:x[0],reverse=True);best=best[:4]
        if cap:
            t=full(g,o,states,slot,r);positive.append(r);counts['captures']+=1;counts['useful']+=t['useful'];print('CAPTURE',r,'useful',t['useful'],flush=True)
        if gate:
          print('PAD_GATE',r,after129['movement'],flush=True);proposals=[]
          for origin in [after129['movement']]+([e130['pos']] if e130 else []):
           for target in [(x,z) for x in [-1890,-1882,-1874] for z in [-970,-939,-925]]:
            b=box_to(origin,after129['collision'],target)
            if b is not None and b not in proposals:proposals.append(b)
          for b in proposals:
            if counts['secondActorCuts130']>=152:break
            rr=dict(r,box130=b);g.load_state(state130);ee=cut(g,b);advance(g,NEUTRAL);pp=rich_sample(g,o);advance(g,NEUTRAL);aa=rich_sample(g,o);counts['secondActorCuts130']+=1;cap=aa['used']==64 and aa['floorOwner']==aa['platform']==61;seconds.append(dict(recipe=rr,edits=ee,after130=pp,after131=aa,capture=cap))
            if cap:
                t=full(g,o,states,slot,rr);positive.append(rr);counts['captures']+=1;counts['useful']+=t['useful'];print('CAPTURE',rr,'useful',t['useful'],flush=True)
    selected=positive+[r for _,r in best]+[r['recipe'] for r in rows if r['baseIndex']==0 and r['recipe']['seed']['speed']==256]
    q,qo,qs,qslot,qprep=create(a.capture);assert prep==qprep;trials=[];seen=set()
    for r in selected:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=full(g,o,states,slot,r);assert t==full(q,qo,qs,qslot,r);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),actorHelperSha256=digest(ROOT/'instrumentation/ink-high-action-entry/actor_cuts.py'),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),sourceReceiptSha256=digest(source),shellPreparation=prep,menu=dict(initialSpeeds=[24,40,64,100,160,256],headings=[0,16384,32768,49152],bases=bases,initialY=21716,neutralAirUpdate=127,shellPlacementAndZ=128,secondCutLimit=152,producerGateY=[1700,2000]),counts=counts,screenRows=rows,secondCuts=seconds,trials=trials,freshBoundaries=sum(len(t['samples'])+2 for t in trials),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',counts,'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
