"""High unloaded-top shell mount, delayed controls and later box-only shove.

Mario FREEFALL/XYZ/velocity and shell XYZ are supplied once. No ground action,
action timer, animation progress, floor cache or platform is written. After
the initial air cut only controller pads and the declared Crazy Box XYZ cut
are writable. A remains unheld/unpressed. No actor delivery is claimed.
"""
import argparse,json,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from ink_floorless_warp import reach_after_pillars,NEUTRAL
from ink_slide_handoff import advance,rich_sample
from ink_crawl_predecessors import pose,write
from ink_timer130_crawl import frame_events
from ink_pu_vpu import digest

MODES=['neutral','z-held','bz-held','z-pulse','z-analog-right','b-held','late-z-pulse','late-bz-pulse']

class Guard:
    def __init__(self,g):self.g=g;self.mode='controls'
    def __getattr__(self,k):return getattr(self.g,k)
    def write(self,p,v):
        if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
        if self.mode=='actor':assert p in {'gObjectPool[49].oPos'+a for a in 'XYZ'},p
        self.g.write(p,v)

def roots(capture,phases=(126,128,129)):
    g,o=reach_after_pillars(capture);g=Guard(g)
    spawnPhase=min(phases)-3
    while not(g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')==spawnPhase):advance(g,NEUTRAL)
    g.mode='setup';prep=[];write(g,'gObjectPool[32].oAction',4,prep);g.mode='controls';advance(g,NEUTRAL);advance(g,NEUTRAL)
    shells=[i for i in range(240) if g.read(f'gObjectPool[{i}].activeFlags') and g.read(f'gObjectPool[{i}].behavior')==g.address('bhvKoopaShell')];assert len(shells)==1
    states={}
    while g.read('gObjectPool[61].oTimer')<=max(phases):
        phase=g.read('gObjectPool[61].oTimer')
        if phase in phases:states[phase]=g.save_state()
        advance(g,NEUTRAL)
    return g,o,states,shells[0],dict(edits=prep,controls=[NEUTRAL,NEUTRAL],spawnPhase=spawnPhase,slot=shells[0])

def pad(mode,i):
    if i==0 or mode=='neutral':return NEUTRAL
    if mode=='z-held':return dict(buttons=0x2000,stick=[0,0])
    if mode=='bz-held':return dict(buttons=0x6000,stick=[0,0])
    if mode=='z-analog-right':return dict(buttons=0x2000,stick=[64,0])
    if mode=='b-held':return dict(buttons=0x4000,stick=[0,0])
    if mode=='z-pulse':return dict(buttons=0x2000 if i%2 else 0,stick=[0,0])
    if mode=='late-z-pulse':return dict(buttons=0x2000 if i>=24 and i%2 else 0,stick=[0,0])
    if mode=='late-bz-pulse':return dict(buttons=0x6000 if i>=24 and i%2 else 0,stick=[0,0])
    raise AssertionError(mode)

def small(g,o):
    return dict(timer=g.read('gGlobalTimer'),movement=g.read('gMarioState.pos'),collision=[g.read('gMarioObject.oPos'+a) for a in 'XYZ'],display=g.read('gMarioObject.header.gfx.pos'),action=g.read('gMarioState.action'),floorY=g.read('gMarioState.floorHeight'),floorOwner=o.slot(g.read('gMarioState.floor?.object')),platform=o.slot(g.read('gMarioPlatform')),used=o.slot(g.read('gMarioState.usedObj')),area=g.read('gCurrAreaIndex'),topPhase=g.read('gObjectPool[61].oTimer'),topActive=g.read('gObjectPool[61].activeFlags'))

def trial(g,o,states,slot,r,full=False):
    g.load_state(states[r['phase']]);g.mode='setup';edits=[];pos=[-1950,r['height'],-939];pose(g,pos,edits)
    for k,v in [('action',g.constant('ACT_FREEFALL')),('forwardVel',20),('vel',[20,-16,0]),('faceAngle',[0,16384,0])]:write(g,'gMarioState.'+k,v,edits)
    for a,v in zip('XYZ',[-1950,r['height']-10,-939]):write(g,f'gObjectPool[{slot}].oPos'+a,v,edits)
    g.mode='controls';initial=rich_sample(g,o) if full else small(g,o);rows=[];events=[];pads=[];actorEdits=[];actors=[];highSlide=[];changes=[]
    groundSlides={g.constant(n) for n in ['ACT_CROUCH_SLIDE','ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_DIVE_SLIDE','ACT_CRAWLING']}
    for i in range(70):
        if r['boxPhase'] is not None and i==r['boxPhase']-r['phase']:
            g.mode='actor'
            for a,v in zip('XYZ',[-1989,r['height'],-939]):write(g,'gObjectPool[49].oPos'+a,v,actorEdits)
            g.mode='controls'
        control=pad(r['mode'],i);advance(g,control);s=rich_sample(g,o) if full else small(g,o);es=frame_events(g);rows.append(s)
        for e in es:
            if e['type']=='FLT_EXECUTE_ACTION' and e['action'] in groundSlides and e['pos'][1]>20000:highSlide.append(dict(update=i+1,event=e))
            if e['type']=='FLT_CHANGE_ACTION':changes.append(dict(update=i+1,event=e))
        if full:
            events.append(es);pads.append(control);actors.append({str(k):{f:g.read(f'gObjectPool[{k}].'+f) for f in ['oPosX','oPosY','oPosZ','oAction','activeFlags','oIntangibleTimer','oInteractStatus']} for k in [slot,49]})
        if s['area']!=1:break
    cap=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows);arrival=next((s for s in rows if s['area']==2),None);useful=arrival is not None and not(-460<=arrival['movement'][0]<=461 and -204<=arrival['movement'][2]<=717)
    return dict(recipe=r,initial=initial,edits=edits if full else None,actorEdits=actorEdits,controls=pads,samples=rows,events=events,actors=actors,actionChanges=changes,highSlideExecutions=highSlide,capture=cap,useful=useful)

def main():
    p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);a=p.parse_args();g,o,states,slot,prep=roots(a.capture);start=time.time();screens=[];positive=[]
    for phase in [126,128,129]:
      for height in [25000,67277]:
       for mode in MODES:
        for boxPhase in dict.fromkeys([None,phase+1,130]):
            r=dict(phase=phase,height=height,mode=mode,boxPhase=boxPhase);t=trial(g,o,states,slot,r);screens.append(t)
            if t['capture'] or t['highSlideExecutions']:positive.append(r);print('PROMISING',r,'highSlide',t['highSlideExecutions'],'capture',t['capture'],'useful',t['useful'],flush=True)
    selected=positive+[dict(phase=128,height=y,mode=m,boxPhase=130) for y in [25000,67277] for m in ['neutral','bz-held','late-bz-pulse']]
    q,qo,qs,qslot,qprep=roots(a.capture);assert prep==qprep;trials=[];seen=set()
    for r in selected:
        key=json.dumps(r,sort_keys=True)
        if key in seen:continue
        seen.add(key);t=trial(g,o,states,slot,r,True);assert t==trial(q,qo,qs,qslot,r,True);trials.append(t)
    result=dict(schema=1,date='2026-11-14',scope=__doc__,scriptSha256=digest(__file__),runtimeSha256=digest(ROOT/'build/wafel-pilot/sm64_jp.dll'),captureSha256=digest(a.capture),shellPreparation=prep,menu=dict(phases=[126,128,129],heights=[25000,67277],modes=MODES,boxCuts=['none','first update after mount','phase130'],initialPosXZ=[-1950,-939],initialForward=20,initialVelocity=[20,-16,0],initialFaceYaw=16384,boxXZ=[-1989,-939],updates=70),counts=dict(recipes=len(screens),screenedUpdates=sum(len(t['samples']) for t in screens),highSlideRecipes=sum(bool(t['highSlideExecutions']) for t in screens),captureRecipes=sum(t['capture'] for t in screens),usefulRecipes=sum(t['useful'] for t in screens)),screens=screens,trials=trials,freshBoundaries=sum(len(t['samples']) for t in trials),elapsed=time.time()-start)
    with a.output.open('x') as f:json.dump(result,f,indent=2);f.write('\n')
    print('FINAL',result['counts'],'FRESH',result['freshBoundaries'],flush=True)

if __name__=='__main__':main()
