"""Stop the native slide after the recorded behavior-113 top landing.

The exterior freefall setup at 112 is the only supplied Mario state.
Two roots replay either through landing 113 or through stomach slide 117.
All continuation writes are A-off controller pads. Finite policies and a
bounded per-frame beam test stopping, crawling, then rotational re-entry.
"""
import argparse
from collections import Counter
import hashlib
import json
import math
from pathlib import Path
import sys
import time

sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_crawl_edge_entry import ROOT, CRAWL, controller, sha, is_supported_crawl
from ink_air_entry_to_crawl import advance as basic_advance, state as basic_state, beam_menu
from ink_early_air_entry_crawl import exact_upper
from ink_top_entry_witnesses import setup_fresh, rich_state

SOURCE=ROOT/'docs/notes/ink-early-air-entry-crawl-receipt.json'
Z=0x2000
B=0x4000
AIR=0x800
SLIDE_NAMES=['ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CROUCH_SLIDE','ACT_BUTT_SLIDE']
NAMES=SLIDE_NAMES+['ACT_STOMACH_SLIDE_STOP','ACT_BUTT_SLIDE_STOP',
    'ACT_SLIDE_KICK_SLIDE_STOP','ACT_CROUCHING','ACT_START_CROUCHING',
    'ACT_START_CRAWLING','ACT_IDLE','ACT_WALKING','ACT_BRAKING',
    'ACT_FORWARD_ROLLOUT','ACT_BACKWARD_ROLLOUT','ACT_FREEFALL_LAND_STOP']
DIRECTIONS=list(range(0,65536,4096))+['uphill','next-uphill','brake',
    'next-brake','inward','outward','left','right','neutral']


def extra_state(g,s):
    s.update(slideVelocity=[g.read('gMarioState.slideVelX'),g.read('gMarioState.slideVelZ')],
             slideYaw=g.read('gMarioState.slideYaw'),
             intendedYaw=g.read('gMarioState.intendedYaw'),
             intendedMagnitude=g.read('gMarioState.intendedMag'),
             cameraYaw=g.read('gMarioState.area.camera.yaw'),
             cameraMode=g.read('gMarioState.area.camera.mode'),
             squishTimer=g.read('gMarioState.squishTimer'))
    return s


def advance(g,o,pad):
    before_action=g.read('gObjectPool[61].oAction')
    r=basic_advance(g,o,pad)
    s=extra_state(g,r['state'])
    assert not s['buttons']&0x8000 and not s['buttonsPressed']&0x8000
    if s['topAction']==before_action==1:
        assert s['topTimer']==r['executedTopTimer']+1
    r['executedTopAction']=before_action
    return r


def root_state(which):
    ref=json.loads(SOURCE.read_text(encoding='utf-8'))['controls']['selected']['topRecapture']
    g,o,edits=setup_fresh(ref['recipe'])
    initial=rich_state(g,o)
    assert initial==ref['initial'] and edits==ref['suppliedEdits']
    clearance=ref['recipe']['pos'][1]-exact_upper(initial['topMesh'],ref['recipe']['pos'])
    assert clearance>0
    count=2 if which=='landing113' else 6
    prefix=[]
    for expected in ref['records'][:count]:
        r=basic_advance(g,o,expected['input'])
        assert r=={k:v for k,v in expected.items() if k!='squishTimer'}
        assert g.read('gMarioState.squishTimer')==expected['squishTimer']
        prefix.append(r)
    s=extra_state(g,basic_state(g,o))
    assert s['floorOwner']==s['platform']==61
    assert abs(s['position'][1]-s['floorY'])<0.05
    assert s['action']==g.constant('ACT_FREEFALL_LAND' if count==2 else 'ACT_STOMACH_SLIDE')
    return g,o,g.save_state(),dict(root=which,recipe=ref['recipe'],suppliedEdits=edits,
        exactInitialFeetClearance=clearance,exterior=initial,prefix=prefix,rootState=s)


def heading(g,direction):
    if isinstance(direction,int):return direction
    if direction=='neutral':return 0
    p=g.read('gMarioState.pos')
    inward=round(math.atan2(g.read('gObjectPool[61].oPosX')-p[0],
        g.read('gObjectPool[61].oPosZ')-p[2])*65536/math.tau)&0xffff
    if direction in ['inward','outward','left','right']:
        return (inward+dict(inward=0,outward=32768,left=16384,right=49152)[direction])&0xffff
    if 'uphill' in direction:
        n=g.read('gMarioState.floor.normal')
        yaw=round(math.atan2(-n['x'],-n['z'])*65536/math.tau)&0xffff
    else:
        x,z=g.read('gMarioState.slideVelX'),g.read('gMarioState.slideVelZ')
        if x*x+z*z<0.0001:return heading(g,'uphill')
        yaw=round(math.atan2(-x,-z)*65536/math.tau)&0xffff
    if direction.startswith('next-'):
        yaw=(yaw+g.read('gObjectPool[61].oAngleVelYaw'))&0xffff
    return yaw


def policy_menu():
    for direction in DIRECTIONS:
        magnitudes=[0] if direction=='neutral' else [16,32,64]
        for mag in magnitudes:
            for mode,delay in [('settle',0),('z',0),('pulse-b-z',0),
                ('b-z',0),('b-z',4),('b-z',8),('bz-z',0),('bz-z',4),
                ('z-delay',4),('z-delay',8),('z-pulse',0),('z-pulse',4)]:
                yield dict(direction=direction,magnitude=mag,mode=mode,delay=delay)


def policy_pad(g,recipe,k,constants):
    mode=recipe['mode'];d=recipe['delay'];a=g.read('gMarioState.action')
    mag=recipe['magnitude'];buttons=0
    stops=[constants[n] for n in ['ACT_STOMACH_SLIDE_STOP','ACT_BUTT_SLIDE_STOP',
        'ACT_SLIDE_KICK_SLIDE_STOP','ACT_FREEFALL_LAND_STOP','ACT_IDLE']]
    crouches=[constants[n] for n in ['ACT_CROUCHING','ACT_START_CROUCHING']]
    if a in stops or a in crouches:
        buttons=Z;mag=0 if a!=constants['ACT_CROUCHING'] else max(32,mag)
    elif a==CRAWL or a==constants['ACT_START_CRAWLING']:
        buttons=Z;mag=max(32,mag)
    elif mode=='z':buttons=Z
    elif mode=='pulse-b-z':buttons=Z|(B if k%2==0 else 0)
    elif mode in ['b-z','bz-z']:
        buttons=(B|(Z if mode=='bz-z' else 0)) if k==d else Z if k>d else 0
    elif mode=='z-delay':buttons=Z if k>=d else 0
    elif mode=='z-pulse':buttons=Z if k==d else 0
    return controller(g,heading(g,recipe['direction']),buttons,mag)


def assess(records,constants):
    out=dict(slide=False,stop=False,stopOnTop=False,crouch=False,startCrawl=False,
        crawl=False,crawlOnTop=False,deepCrawl=False,caughtAfterTopCrawl=False,
        deepCrawlBefore130=False,readyAt130=False,leftTop=False,
        rollout=False,firstStop=None,firstCrawl=None,minimumTopSlideSpeed=None)
    slides={constants[n] for n in SLIDE_NAMES}
    stops={constants[n] for n in ['ACT_STOMACH_SLIDE_STOP','ACT_BUTT_SLIDE_STOP','ACT_SLIDE_KICK_SLIDE_STOP']}
    saw_top_crawl=False
    for r in records:
        s=r['state'];acts=[e['action'] for e in r['entries']]+[s['action']]
        phase=r['executedTopTimer']
        out['slide'] |= any(a in slides for a in acts)
        on_top=s['floorOwner']==s['platform']==61 and abs(s['position'][1]-s['floorY'])<0.05
        out['leftTop'] |= not on_top
        out['rollout'] |= any(a in [constants['ACT_FORWARD_ROLLOUT'],constants['ACT_BACKWARD_ROLLOUT']] for a in acts)
        if any(a in stops for a in acts):
            out['stop']=True
            if out['firstStop'] is None:out['firstStop']=dict(behavior=phase,position=s['position'],floor=s['floorOwner'],platform=s['platform'])
        out['stopOnTop'] |= s['action'] in stops and on_top
        out['crouch'] |= any(a in [constants['ACT_CROUCHING'],constants['ACT_START_CROUCHING']] for a in acts)
        out['startCrawl'] |= constants['ACT_START_CRAWLING'] in acts
        if CRAWL in acts:
            out['crawl']=True
            if out['firstCrawl'] is None:out['firstCrawl']=dict(behavior=phase,position=s['position'])
        for a,q in [(e['action'],e['geometry']) for e in r['entries']]+[(s['action'],s['geometry'])]:
            if a==CRAWL and q and q['deep']:
                out['deepCrawl']=True
                out['deepCrawlBefore130'] |= phase<130
                out['caughtAfterTopCrawl'] |= saw_top_crawl
        supported=is_supported_crawl(s)
        out['crawlOnTop'] |= supported
        saw_top_crawl |= supported
        out['readyAt130'] |= bool(s['topAction']==1 and s['topTimer']==130 and
            s['action']==CRAWL and s['geometry'] and s['geometry']['deep'])
        if s['action'] in slides and on_top:
            speed=math.hypot(*s['slideVelocity'])
            if out['minimumTopSlideSpeed'] is None or speed<out['minimumTopSlideSpeed']['speed']:
                out['minimumTopSlideSpeed']=dict(speed=speed,forward=s['forward'],behavior=phase,
                    position=s['position'],input=s['input'],floorType=s['floorType'],normal=s['floorNormal'])
    return out


def keep(selected,root,recipe,records,result):
    witness=dict(root=root,policy=recipe,records=records,outcome=result)
    if root+'_first' not in selected:selected[root+'_first']=witness
    for key in ['stop','stopOnTop','crouch','startCrawl','crawl','crawlOnTop',
                'deepCrawl','caughtAfterTopCrawl','deepCrawlBefore130','readyAt130','rollout']:
        if result[key] and root+'_'+key not in selected:selected[root+'_'+key]=witness
    key=root+'_slowestTopSlide';low=result['minimumTopSlideSpeed']
    if low and (key not in selected or low['speed']<selected[key]['outcome']['minimumTopSlideSpeed']['speed']):
        selected[key]=witness


def policies(which,selected,limit):
    g,o,root,setup=root_state(which);constants={n:g.constant(n) for n in NAMES}
    counts=Counter();rows=[];start=time.monotonic()
    for index,recipe in enumerate(policy_menu()):
        if limit is not None and index>=limit:break
        g.load_state(root);records=[]
        while g.read('gCurrAreaIndex')==1 and g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')<=150:
            records.append(advance(g,o,policy_pad(g,recipe,len(records),constants)))
        result=assess(records,constants)
        counts['policies']+=1;counts['frames']+=len(records)
        for k,v in result.items():
            if isinstance(v,bool):counts[k]+=v
        rows.append(dict(policy=recipe,outcome=result))
        keep(selected,which,recipe,records,result)
        if (index+1)%200==0:print(json.dumps(dict(root=which,policies=index+1,counts=dict(counts),seconds=time.monotonic()-start)),flush=True)
    return dict(setup=setup,counts=dict(counts),results=rows)


def score(s,constants):
    stage={CRAWL:8,constants['ACT_START_CRAWLING']:7,constants['ACT_CROUCHING']:6,
        constants['ACT_START_CROUCHING']:5,constants['ACT_STOMACH_SLIDE_STOP']:4,
        constants['ACT_BUTT_SLIDE_STOP']:4,constants['ACT_IDLE']:3,
        constants['ACT_WALKING']:2}.get(s['action'],0)
    on_top=s['floorOwner']==s['platform']==61
    high=s['geometry'] and s['geometry']['underside'] is not None and s['position'][1]>s['geometry']['underside']
    return (stage>=4 and high,stage>=4,on_top,high,stage,-math.hypot(*s['slideVelocity']),s['position'][1])


def beam(which,selected,width):
    g,o,root,setup=root_state(which);constants={n:g.constant(n) for n in NAMES}
    frontier=[dict(saved=root,records=[])];menu=beam_menu();layers=[];expanded=0;start=time.monotonic()
    # No below-cap or support-loss pruning: leaving and returning may be relevant.
    horizon=151-setup['rootState']['topTimer']
    observations=Counter()
    for depth in range(1,horizon+1):
        candidates={};terminal=0
        for parent in frontier:
            for pad in menu:
                g.load_state(parent['saved']);r=advance(g,o,pad);expanded+=1
                s=r['state'];chain=parent['records']+[r]
                result=assess(chain,constants)
                for k,v in result.items():
                    if isinstance(v,bool) and v:observations[k]+=1
                keep(selected,which+'_beam',dict(beam=True,depth=depth),chain,result)
                if s['area']!=1 or not s['topLive'] or s['topAction']!=1:
                    terminal+=1;continue
                key=json.dumps(s,sort_keys=True,separators=(',',':'))
                if key not in candidates:candidates[key]=dict(parent=parent,pad=pad,record=r,score=score(s,constants))
        ordered=sorted(candidates.values(),key=lambda c:c['score'],reverse=True)
        kept=[];buckets=Counter()
        for c in ordered:
            s=c['record']['state'];bucket=(s['action'],s['actionTimer'],s['buttons'],s['floorOwner'],s['platform'])
            if buckets[bucket]>=max(2,width//8):continue
            kept.append(c);buckets[bucket]+=1
            if len(kept)>=width:break
        if len(kept)<width:
            seen={id(c) for c in kept};kept.extend(c for c in ordered if id(c) not in seen);kept=kept[:width]
        nxt=[]
        for c in kept:
            g.load_state(c['parent']['saved']);r=advance(g,o,c['pad']);assert r==c['record']
            nxt.append(dict(saved=g.save_state(),records=c['parent']['records']+[r]))
        layers.append(dict(depth=depth,expanded=len(frontier)*len(menu),uniqueObservedStates=len(candidates),retained=len(nxt),terminal=terminal))
        frontier=nxt
        if depth%4==0 or not frontier:print(json.dumps(dict(root=which,beam=layers[-1],total=expanded,seconds=time.monotonic()-start)),flush=True)
        if not frontier:break
    return dict(width=width,menu=menu,layers=layers,expandedFrames=expanded,
        pathObservationCounts=dict(observations),limits='Finite pads, width, observed-state merging and heuristic ranking; not exhaustive; path observations repeat prefixes')


def verify(w):
    root=w['root'].replace('_beam','')
    g,o,_,setup=root_state(root)
    details=[]
    for r in w['records']:
        before=rich_state(g,o);actual=advance(g,o,r['input']);assert actual==r
        details.append(dict(before=before,after=rich_state(g,o)))
    return dict(passed=True,prefixFrames=len(setup['prefix']),comparedContinuationFrames=len(details),meshes=details)


def run(output,limit,width):
    selected={};batches={};searches={}
    for root in ['landing113','slide117']:
        batches[root]=policies(root,selected,limit)
        if width:searches[root]=beam(root,selected,width)
    validations={n:verify(w) for n,w in selected.items()}
    report=dict(schema=1,scope='Fixed supplied exterior entry at 112; native landing 113 and slide 117; A-off inputs only thereafter',
        batches=batches,beams=searches,selected=selected,validations=validations,
        aInputs=0,postSetupWrites='Three controller pad fields only; complete states restored between alternatives',
        scriptSha256=sha(__file__),sourceReceiptSha256=sha(SOURCE),
        runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),
        dependencies={n:sha(Path(__file__).with_name(n)) for n in ['ink_crawl_edge_entry.py',
            'ink_air_entry_to_crawl.py','ink_early_air_entry_crawl.py','ink_top_entry_witnesses.py',
            'ink_crawl_top_entry.py','replay.py']})
    with output.open('x',encoding='utf-8') as f:json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),counts={k:v['counts'] for k,v in batches.items()},
        beams={k:v['expandedFrames'] for k,v in searches.items()},validated={n:v['comparedContinuationFrames'] for n,v in validations.items()})),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--limit',type=int);p.add_argument('--beam-width',type=int,default=64)
    a=p.parse_args();run(a.output,a.limit,a.beam_width)
