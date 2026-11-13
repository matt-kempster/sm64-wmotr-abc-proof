"""Walk toward the rotating cap edge, lose its floor, then try to crawl.

Exact native walking roots at 117 and 121 come from the single supplied
exterior freefall at 112. Only A-off controller inputs follow that setup.
This is a finite native-JP experiment, not an all-input proof.
"""
import argparse
from collections import Counter
import json
import math
from pathlib import Path
import sys
import time
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_top_slide_to_crawl as prior
from ink_crawl_edge_entry import events,top_snapshot
from ink_crawl_top_entry import projected_base,cross

SOURCE=prior.ROOT/'docs/notes/ink-top-slide-controls-receipt.json'
WALK=0x04000440
Z=0x2000
MODES=['never','loss-z','loss-neutral-z','clear-z','clear-neutral-z',
       'edge32-z','edge8-z','edge8-neutral-z','phase122-z','phase126-z',
       'phase130-z','phase126-neutral-z']


def edge(top,pos):
    if not top or not top['faces']:return None
    polygon=projected_base(top); values=[]
    for a,b in zip(polygon,polygon[1:]+polygon[:1]):
        dx,dz=b[0]-a[0],b[1]-a[1]
        length=math.hypot(dx,dz)
        distance=cross(a,b,[pos[0],pos[2]])/length
        yaw=round(math.atan2(dz,-dx)*65536/math.tau)&0xffff
        values.append((distance,yaw,a,b))
    d,yaw,a,b=min(values)
    return dict(clearance=d,outwardYaw=yaw,segment=[a,b],
                definition='Signed distance to nearest supporting line of actual native base polygon; negative means outside footprint')


def state(g,o,top=None):
    top=top_snapshot(g) if top is None else top
    s=prior.extra_state(g,prior.basic_state(g,o,top))
    s['edge']=edge(top,s['position'])
    return s


def advance(g,o,pad):
    clock=g.read('gGlobalTimer');phase=g.read('gObjectPool[61].oTimer')
    action=g.read('gObjectPool[61].oAction')
    g.advance_pad(pad)
    assert g.read('gGlobalTimer')==clock+1
    top=top_snapshot(g);s=state(g,o,top)
    assert not s['buttons']&0x8000 and not s['buttonsPressed']&0x8000
    if action==s['topAction']==1:assert s['topTimer']==phase+1
    return dict(executedTopTimer=phase,executedTopAction=action,input=pad,
                state=s,entries=events(g,top))


def root_state(which):
    ref=json.loads(SOURCE.read_text(encoding='utf-8'))['cases']['uphill-wait4-z']
    g,o,_,setup=prior.root_state('landing113')
    count=4 if which==117 else 8
    prefix=[]
    for expected in ref['witness']['records'][:count]:
        r=prior.advance(g,o,expected['input']);assert r==expected;prefix.append(r)
    s=state(g,o)
    assert s['action']==g.constant('ACT_WALKING')==WALK
    assert s['topTimer']==which+1 and s['floorOwner']==s['platform']==61
    return g,o,g.save_state(),dict(root=which,exteriorSetup=setup,prefix=prefix,rootState=s)


def recipes():
    for system in ['world','edge','next-edge','next-face']:
        for offset in range(0,65536,4096):
            for mag in [32,64,127]:
                for mode in MODES:
                    yield dict(system=system,offset=offset,magnitude=mag,mode=mode)


def heading(g,s,recipe):
    mode=recipe['system']
    if mode=='world':yaw=0
    elif mode=='next-face':yaw=prior.heading(g,'uphill')
    else:yaw=s['edge']['outwardYaw'] if s['edge'] else prior.heading(g,'outward')
    if mode.startswith('next-'):yaw+=g.read('gObjectPool[61].oAngleVelYaw')
    return (yaw+recipe['offset'])&0xffff


def pad_for(g,s,recipe,latch):
    mode=recipe['mode'];d=s['edge']['clearance'] if s['edge'] else 1e9
    trigger=(mode.startswith('loss') and s['floorOwner']!=61) or (
        mode.startswith('clear') and not s['input']&8) or (
        mode.startswith('edge32') and d<=32) or (
        mode.startswith('edge8') and d<=8) or (
        mode.startswith('phase') and s['topTimer']>=int(mode[5:8]))
    latch |= trigger
    if latch and 'neutral' in mode:
        mag=32 if s['action'] in [g.constant('ACT_CROUCHING'),g.constant('ACT_START_CRAWLING'),prior.CRAWL] else 0
    else:mag=recipe['magnitude']
    return prior.controller(g,heading(g,s,recipe),Z if latch else 0,mag),latch


def assess(root,records,constants):
    out=dict(lostUpperFloor=False,lostFromWalk=False,supportLoss=False,
        slipperyCleared=False,insideAfterLoss=False,deepAfterLoss=False,
        crouch=False,startCrawl=False,crawl=False,crawlAfterLoss=False,
        deepCrawl=False,caughtCrawler=False,readyAt130=False,
        firstLoss=None,firstClear=None,firstInsideAfterLoss=None,firstCrawl=None,
        minimumEdge=None,minimumWalkingEdge=None,firstSlide=None)
    old=root;lost=False;crawled_after_loss=False
    slides={constants[n] for n in prior.SLIDE_NAMES}
    for r in records:
        s=r['state'];phase=r['executedTopTimer'];acts=[e['action'] for e in r['entries']]+[s['action']]
        prior_lost=lost
        if out['firstSlide'] is None and any(a in slides for a in acts):out['firstSlide']=phase
        supported=s['floorOwner']==s['platform']==61 and abs(s['position'][1]-s['floorY'])<0.05
        out['supportLoss'] |= not supported
        if s['floorOwner']!=61:
            if not lost:
                out['firstLoss']=dict(behavior=phase,previousAction=old['action'],action=s['action'],
                    actions=acts,position=s['position'],floorY=s['floorY'],floorOwner=s['floorOwner'],
                    platform=s['platform'],input=s['input'],edge=s['edge'])
                out['lostFromWalk']=old['action']==WALK and WALK in acts and out['firstSlide'] is None
            lost=True;out['lostUpperFloor']=True
        if not s['input']&8:
            out['slipperyCleared']=True
            if out['firstClear'] is None:out['firstClear']=dict(behavior=phase,action=s['action'],position=s['position'],floorY=s['floorY'],input=s['input'])
        out['crouch'] |= any(a in [constants['ACT_CROUCHING'],constants['ACT_START_CROUCHING']] for a in acts)
        out['startCrawl'] |= constants['ACT_START_CRAWLING'] in acts
        out['crawl'] |= prior.CRAWL in acts
        if prior.CRAWL in acts:
            if out['firstCrawl'] is None:out['firstCrawl']=dict(behavior=phase,position=s['position'],floorY=s['floorY'])
            out['crawlAfterLoss'] |= prior_lost or (lost and s['action']==prior.CRAWL)
        # An action entry can precede the first floor loss inside this frame.
        # Do not put that entry after a loss known only at the final boundary.
        samples=[(e['action'],e['geometry'],prior_lost) for e in r['entries']]+[(s['action'],s['geometry'],lost)]
        for action,q,loss_known in samples:
            if q and q['inside'] and loss_known:
                out['insideAfterLoss']=True
                if out['firstInsideAfterLoss'] is None:out['firstInsideAfterLoss']=dict(behavior=phase,action=action,geometry=q)
            if q and q['deep']:
                out['deepAfterLoss'] |= loss_known
                out['deepCrawl'] |= action==prior.CRAWL
                out['caughtCrawler'] |= action==prior.CRAWL and crawled_after_loss
        crawled_after_loss |= bool(lost and s['action']==prior.CRAWL and s['hitboxHeight']==100
            and s['geometry'] and not s['geometry']['inside'])
        out['readyAt130'] |= bool(s['topAction']==1 and s['topTimer']==130 and s['action']==prior.CRAWL and s['geometry'] and s['geometry']['deep'])
        if s['edge']:
            value=dict(clearance=s['edge']['clearance'],behavior=phase,action=s['action'],position=s['position'])
            for key,ok in [('minimumEdge',True),('minimumWalkingEdge',s['action']==WALK)]:
                if ok and (out[key] is None or value['clearance']<out[key]['clearance']):out[key]=value
        old=s
    return out


def keep(selected,which,recipe,records,result):
    w=dict(root=which,policy=recipe,records=records,outcome=result)
    for key in ['lostUpperFloor','lostFromWalk','slipperyCleared','insideAfterLoss','deepAfterLoss','crouch','startCrawl','crawl','deepCrawl','caughtCrawler']:
        if result[key] and key not in selected:selected[key]=w
    for key in ['minimumEdge','minimumWalkingEdge']:
        v=result[key]
        if v and (key not in selected or v['clearance']<selected[key]['outcome'][key]['clearance']):selected[key]=w


def policies(which,limit):
    g,o,saved,setup=root_state(which);constants={n:g.constant(n) for n in prior.NAMES}
    counts=Counter();rows=[];selected={};start=time.monotonic()
    for i,recipe in enumerate(recipes()):
        if limit is not None and i>=limit:break
        g.load_state(saved);s=setup['rootState'];records=[];latch=False
        while g.read('gCurrAreaIndex')==1 and g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')<=150:
            pad,latch=pad_for(g,s,recipe,latch)
            r=advance(g,o,pad);records.append(r);s=r['state']
        result=assess(setup['rootState'],records,constants)
        counts['policies']+=1;counts['frames']+=len(records)
        for k,v in result.items():
            if isinstance(v,bool):counts[k]+=v
        rows.append(dict(policy=recipe,outcome=result));keep(selected,which,recipe,records,result)
        if (i+1)%384==0:print(json.dumps(dict(root=which,policies=i+1,counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
    return dict(setup=setup,counts=dict(counts),results=rows,selected=selected)


def beam_menu(g,s):
    pads=[]
    for button in [0,Z]:
        pads.append(dict(buttons=button,stick=[0,0]))
        for magnitude in [16,32,64,127]:
            for yaw in range(0,65536,8192):
                pads.append(dict(buttons=button,stick=[round(math.sin(yaw*math.tau/65536)*magnitude),round(math.cos(yaw*math.tau/65536)*magnitude)]))
        for offset in range(0,65536,4096):
            recipe=dict(system='next-edge',offset=offset)
            pads.append(prior.controller(g,heading(g,s,recipe),button,127))
    return list({json.dumps(p,sort_keys=True):p for p in pads}.values())


def scores(s,result,constants):
    d=s['edge']['clearance'] if s['edge'] else -1000
    stage={prior.CRAWL:5,constants['ACT_START_CRAWLING']:4,constants['ACT_CROUCHING']:3,constants['ACT_START_CROUCHING']:2}.get(s['action'],0)
    high=bool(s['geometry'] and s['geometry']['underside'] is not None and s['position'][1]>s['geometry']['underside'])
    # Separate exit, walking-edge and crawl lanes; no reward for staying supported.
    return [(result['caughtCrawler'],stage>0 and high,result['lostUpperFloor'],high,stage,-d),
            (result['lostFromWalk'],result['firstSlide'] is None,s['action']==WALK,-d,s['forward']),
            (result['caughtCrawler'],stage,-d,s['forward'])]


def beam(which,width):
    g,o,saved,setup=root_state(which);constants={n:g.constant(n) for n in prior.NAMES}
    frontier=[dict(saved=saved,records=[],state=setup['rootState'])]
    selected={};layers=[];counts=Counter();start=time.monotonic()
    for depth in range(1,151-setup['rootState']['topTimer']+1):
        candidates={};expanded=0
        for parent in frontier:
            g.load_state(parent['saved']);menu=beam_menu(g,parent['state'])
            for pad in menu:
                g.load_state(parent['saved']);r=advance(g,o,pad);expanded+=1
                chain=parent['records']+[r];s=r['state'];result=assess(setup['rootState'],chain,constants)
                for k,v in result.items():
                    if isinstance(v,bool) and v:counts[k]+=1
                keep(selected,which,dict(beam=True,depth=depth),chain,result)
                if s['area']!=1 or not s['topLive'] or s['topAction']!=1:continue
                key=json.dumps([s,result['lostUpperFloor'],result['firstSlide'] is None],sort_keys=True,separators=(',',':'))
                if key not in candidates:candidates[key]=dict(parent=parent,pad=pad,record=r,result=result,scores=scores(s,result,constants))
        orders=[sorted(candidates.values(),key=lambda c:c['scores'][i],reverse=True) for i in range(3)]
        kept=[];seen=set();buckets=Counter();indices=[0,0,0]
        while len(kept)<width:
            advanced=False
            for lane,order in enumerate(orders):
                while indices[lane]<len(order):
                    c=order[indices[lane]];indices[lane]+=1
                    if id(c) in seen:continue
                    s=c['record']['state'];bucket=(lane,s['action'],s['floorOwner'],s['faceAngle'][1]//8192,round((s['edge'] or {'clearance':-1000})['clearance']/16))
                    if buckets[bucket]>=max(2,width//16):continue
                    kept.append(c);seen.add(id(c));buckets[bucket]+=1;advanced=True;break
                if len(kept)>=width:break
            if not advanced:break
        nxt=[]
        for c in kept:
            g.load_state(c['parent']['saved']);r=advance(g,o,c['pad']);assert r==c['record']
            nxt.append(dict(saved=g.save_state(),records=c['parent']['records']+[r],state=r['state']))
        frontier=nxt;layers.append(dict(depth=depth,expanded=expanded,uniqueObserved=len(candidates),retained=len(nxt)))
        if depth%4==0 or not frontier:print(json.dumps(dict(root=which,beam=layers[-1],counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
        if not frontier:break
    return dict(setup=setup,width=width,layers=layers,expanded=sum(l['expanded'] for l in layers),pathObservations=dict(counts),selected=selected)


def verify(w):
    g,o,_,setup=root_state(w['root']);details=[]
    for r in w['records']:
        before=prior.rich_state(g,o);actual=advance(g,o,r['input']);assert actual==r
        details.append(dict(before=before,after=prior.rich_state(g,o)))
    return dict(passed=True,prefixFrames=len(setup['exteriorSetup']['prefix'])+len(setup['prefix']),
                comparedContinuationFrames=len(details),meshes=details)


def run(output,limit,width):
    batches={str(root):policies(root,limit) for root in [117,121]}
    beams={str(root):beam(root,width) for root in [117,121]} if width else {}
    validations={}
    for kind,group in [('policies',batches),('beam',beams)]:
        for root,batch in group.items():
            validations[kind+root]={key:verify(w) for key,w in batch['selected'].items()}
    report=dict(schema=1,scope=__doc__,batches=batches,beams=beams,validations=validations,
        aInputs=0,postSetupWrites='Three controller fields only; whole-state restores separate alternatives',
        sourceSha256=prior.sha(SOURCE),scriptSha256=prior.sha(__file__),
        runtimeSha256=prior.sha(prior.ROOT/'build/wafel-pilot/sm64_jp.dll'),
        dependencies={n:prior.sha(Path(__file__).with_name(n)) for n in
          ['ink_top_slide_to_crawl.py','ink_crawl_edge_entry.py','ink_crawl_top_entry.py',
           'ink_crawl_predecessors.py','ink_air_entry_to_crawl.py','ink_early_air_entry_crawl.py',
           'ink_top_entry_witnesses.py','replay.py']})
    with output.open('x',encoding='utf-8') as f:json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),counts={k:v['counts'] for k,v in batches.items()},
        beams={k:dict(expanded=v['expanded'],observations=v['pathObservations']) for k,v in beams.items()},
        selections={kind+root:list(v['selected']) for kind,group in [('policies',batches),('beam',beams)] for root,v in group.items()})),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--limit',type=int);p.add_argument('--beam-width',type=int,default=64)
    a=p.parse_args();run(a.output,a.limit,a.beam_width)
