"""Conditional actor transport after a real hands-free teleport and return.

The normal setup supplies Mario/actor translation to a stock teleporter.
The bloated setup additionally supplies a second translation and ACT_IDLE
eligibility after native bloat. All later return/carry/roof-crawl inputs are
native and no-A, with no additional gameplay edits. Neither setup produces
the first teleporter approach or a complete Ink route.
"""
import argparse,hashlib,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from ink_handsfree_teleport import prepare_orphan,prepare_bloated_orphan,snap,NEUTRAL
from ink_box_delivery import advance,steer

PADS={'east':(6930,-4871),'west':(-5943,-4903)}
ROUTES={
 'west':[
  [(-6500,-4903),(-6500,-3500),(-6200,-2000),(-5200,2200),(-3400,2400),(-2200,2300),(-2200,1200),(-2048,-1024)],
  [(-6500,-4903),(-6400,-3500),(-6400,-1200),(-6200,2000),(-5200,2200),(-3400,2400),(-2200,1200),(-2048,-1024)],
  [(-5943,-4000),(-5400,-3000),(-5200,-4200),(-3000,-4400),(-2200,-4100),(-2200,-3000),(-2048,-1024)],
  [(-6500,-4903),(-6500,-3500),(-6200,-2000),(-6200,2000),(-5200,2500),(-3000,2400),(-2200,1200),(-2048,-1024)],
 ],
 'east':[
  [(6930,-6000),(6000,-6500),(3500,-6500),(0,-6500),(-3000,-4400),(-2200,-3000),(-2048,-1024)],
  [(6930,-6000),(6000,-6000),(3500,-5600),(0,-5000),(-3000,-4400),(-2200,-3000),(-2048,-1024)],
  [(6930,-5400),(5000,-5400),(2500,-5000),(0,-4400),(-2200,-4100),(-2200,-3000),(-2048,-1024)],
  [(6930,-6000),(7600,-6000),(7600,5000),(4000,6000),(-1000,4000),(-2200,2300),(-2200,1200),(-2048,-1024)],
 ]}

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()

def record(g,o,n):
 r=snap(g,o,[39]);r['n']=n
 top=g.read('gObjectPool[61].behavior')==g.address('bhvPyramidTop')
 r.update(topIsPyramid=top,topAction=g.read('gObjectPool[61].oAction') if top else None,
  topTimer=g.read('gObjectPool[61].oTimer') if top else None,
  pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched') if top else None,
  level=g.read('gCurrLevelNum'),health=g.read('gMarioState.health'),floorType=g.read('gMarioState.floor?.type'),
  floorNormal=g.read('gMarioState.floor?.normal'))
 return r

def round_trip(g,o,source):
 destination='west' if source=='east' else 'east';x,z=PADS[destination]
 leave=(x-300,z) if destination=='west' else (x,z-300)
 controls=[];samples=[record(g,o,0)];stage='depart'
 for k in range(250):
  p=g.read('gMarioState.pos');action=g.read('gMarioState.action')
  if stage=='depart' and math.hypot(p[0]-leave[0],p[2]-leave[1])<60:stage='settle'
  if stage=='settle' and action==0x0c400201:stage='return'
  if stage=='return' and math.hypot(p[0]-x,p[2]-z)<60:stage='wait'
  pad=steer(g,leave if stage=='depart' else (x,z),0) if stage in ('depart','return') else NEUTRAL.copy()
  controls.append(pad);advance(g,pad);r=record(g,o,k+1);samples.append(r)
  if stage=='wait' and abs(r['movement'][0]-PADS[source][0])<100 and r['action']==0x0c400201:break
 assert abs(samples[-1]['movement'][0]-PADS[source][0])<100
 assert samples[-1]['held']==-1 and samples[-1]['actors'][0]['oHeldState']==1
 return dict(controls=controls,samples=samples,gameplayEdits=[])

def summarize(samples,inputs,terminal):
 alive=lambda r:r['actors'][0]['behavior']=='bhvBobomb' and r['actors'][0]['activeFlags']!=0
 near=lambda r:math.hypot(r['movement'][0]+2048,r['movement'][2]+1024)
 living=[r for r in samples if alive(r)];crawls=[r for r in living if r['action']==0x04008448]
 carrier=lambda r:alive(r) and r['held']==-1 and r['actors'][0]['oHeldState']==1 and r['actors'][0]['owner']==r['area'] and math.hypot(r['movement'][0]-r['actors'][0]['xyz'][0],r['movement'][2]-r['actors'][0]['xyz'][2])<=200 and abs(r['movement'][1]-r['actors'][0]['xyz'][1])<=200
 carriers=[r for r in samples if carrier(r)];carrier_crawls=[r for r in carriers if r['action']==0x04008448]
 return dict(updates=len(inputs),samples=len(samples),terminal=terminal,maximumY=max(r['movement'][1]for r in living),
  closest=min(living,key=near),minimumPyramidDistance=min(map(near,living)),
  crawlSamples=len(crawls),maximumCrawlY=max((r['movement'][1]for r in crawls),default=None),
  maximumGroundedY=max((r['movement'][1] for r in living if abs(r['movement'][1]-r['floorY'])<0.01),default=None),
  carrierDefinition='Original active Bobomb, same area, Mario held=-1, actor HELD_HELD=1, X/Z and absolute Y offsets each<=200; proximity screen, not an interaction theorem',
  maximumCarrier=max(carriers,key=lambda r:r['movement'][1],default=None),
  maximumCarrierCrawl=max(carrier_crawls,key=lambda r:r['movement'][1],default=None),
  maximumPillars=max(r['pillars']or 0 for r in samples),
  spinningSamples=sum(r['topIsPyramid'] and r['topAction']==1 for r in samples),
  orphanSamples=sum(r['held']==-1 and r['actors'][0]['oHeldState']==1 and alive(r) for r in samples),
  firstLostActor=next((r for r in samples if not alive(r)),None),final=samples[-1])

def control(g,target,mode):
 p=g.read('gMarioState.pos')
 if mode.startswith('reverse'):
  target=(2*p[0]-target[0],2*p[2]-target[1])
  if mode=='reverse-idle':
   wanted=round(math.atan2(target[0]-p[0],target[1]-p[2])*65536/math.tau)
   difference=(wanted-g.read('gMarioState.faceAngle')[1]+32768)%65536-32768
   if abs(difference)<1024:return NEUTRAL.copy()
 return steer(g,target,0x2000 if 'crawl' in mode else 0)

def tornado_search(capture,base_trial):
 g,o,setup=prepare_orphan(capture,'west');back=round_trip(g,o,'west')
 prefix=base_trial['inputs'][:250]
 for n,pad in enumerate(prefix):
  advance(g,pad);assert record(g,o,n+1)==base_trial['samples'][n+1]
 initial=record(g,o,0);state=g.save_state();trials=[];names=g.mario_action_names()
 for delay in (0,15,30,45,60,90):
  for target in ((-2200,-800),(-2048,-1024),(-2300,-600)):
   g.load_state(state);inputs=[];samples=[initial];events=[];previous=None;launched=False;terminal='horizon';stage=3
   for k in range(450):
    p=g.read('gMarioState.pos');action=g.read('gMarioState.action')
    launched |= action in (0x10020372,0x108008a4)
    route=base_trial['route']
    if not launched and math.hypot(p[0]-route[stage][0],p[2]-route[stage][1])<150 and stage<len(route)-1:stage+=1
    pad=NEUTRAL.copy() if k<delay else steer(g,target if launched else route[stage],0x2000 if launched else 0)
    inputs.append(pad);advance(g,pad)
    if g.read('gMarioObject').is_null() or g.read('gCurrAreaIndex')!=1 or g.read('gCurrLevelNum')!=8:
     terminal='left valid SSL Area1 Mario context';break
    r=record(g,o,k+1);samples.append(r);key=(r['action'],r['actors'][0]['behavior'],r['actors'][0]['activeFlags'])
    if key!=previous:events.append(dict(n=k+1,entries=[names.get(e['action'],hex(e['action'])) for e in g.frame_log() if e['type']=='FLT_EXECUTE_ACTION'],sample=r));previous=key
    if r['actors'][0]['behavior']!='bhvBobomb' or not r['actors'][0]['activeFlags']:
     terminal='original Bobomb inactive or replaced';break
   t=dict(delay=delay,target=target,inputs=inputs,samples=samples,events=events,launched=launched,summary=summarize(samples,inputs,terminal));trials.append(t)
   print('tornado',delay,target,'maxY',t['summary']['maximumY'],'ground',t['summary']['maximumGroundedY'],'crawl',t['summary']['maximumCrawlY'],flush=True)
 selected=[]
 for t in [max(trials,key=lambda t:t['summary']['maximumGroundedY'] or -1),max(trials,key=lambda t:t['summary']['maximumCrawlY'] or -1)]:
  fresh,fo,recreated=prepare_orphan(capture,'west');assert recreated==setup;assert round_trip(fresh,fo,'west')==back
  for pad in prefix:advance(fresh,pad)
  assert record(fresh,fo,0)==initial
  for n,pad in enumerate(t['inputs']):
   advance(fresh,pad)
   if n+1<len(t['samples']):assert record(fresh,fo,n+1)==t['samples'][n+1]
   else:assert fresh.read('gMarioObject').is_null() or fresh.read('gCurrAreaIndex')!=1 or fresh.read('gCurrLevelNum')!=8
  selected.append(dict(trialIndex=trials.index(t),matchedSnapshots=len(t['samples']),terminalMatched=True))
 return dict(scope='Continuous suffix from normal-west route0 after250 native carry inputs; no new edits',prefix=prefix,initial=initial,
             delays=[0,15,30,45,60,90],targets=[[-2200,-800],[-2048,-1024],[-2300,-600]],horizon=450,
             trials=trials,selectedFreshReplays=selected,summary=dict(trials=len(trials),updates=sum(len(t['inputs'])for t in trials),
              maximumY=max(t['summary']['maximumY']for t in trials),maximumGroundedY=max(t['summary']['maximumGroundedY']for t in trials),
              maximumCrawlY=max((t['summary']['maximumCrawlY']for t in trials if t['summary']['maximumCrawlY']is not None),default=None)))

def entrance_roof_crawl(capture,base_trial):
 g,o,setup=prepare_orphan(capture,'west');back=round_trip(g,o,'west');prefix=base_trial['inputs'][:487]
 for n,pad in enumerate(prefix):
  advance(g,pad);assert record(g,o,n+1)==base_trial['samples'][n+1]
 initial=record(g,o,0);state=g.save_state();trials=[]
 assert initial['movement'][1]==256 and initial['held']==-1 and initial['actors'][0]['oHeldState']==1
 for heading in (None,0,90,180,270):
  g.load_state(state);inputs=[];samples=[initial]
  for k in range(90):
   action=g.read('gMarioState.action');pad=dict(buttons=0x2000,stick=[0,0])
   if heading is not None and action in [g.constant('ACT_CROUCHING'),g.constant('ACT_START_CRAWLING'),g.constant('ACT_CRAWLING')]:
    p=g.read('gMarioState.pos');angle=heading*math.pi/180
    pad=steer(g,(p[0]+1000*math.sin(angle),p[2]+1000*math.cos(angle)),0x2000)
    pad['stick']=[round(v*32/127) for v in pad['stick']]
   inputs.append(pad);advance(g,pad);samples.append(record(g,o,k+1))
  trials.append(dict(heading=heading,inputs=inputs,samples=samples,summary=summarize(samples,inputs,'horizon')))
 selected=[]
 for index in (0,1):
  t=trials[index];fresh,fo,recreated=prepare_orphan(capture,'west');assert recreated==setup;assert round_trip(fresh,fo,'west')==back
  for pad in prefix:advance(fresh,pad)
  assert record(fresh,fo,0)==initial
  for n,pad in enumerate(t['inputs']):advance(fresh,pad);assert record(fresh,fo,n+1)==t['samples'][n+1]
  selected.append(dict(trialIndex=index,matchedSnapshots=len(t['samples']),terminalMatched=True))
 return dict(scope='Continuous suffix from normal-west route0 after487 native carry inputs; no new edits',prefix=prefix,initial=initial,
             headings=[None,0,90,180,270],horizon=90,trials=trials,selectedFreshReplays=selected,
             summary=dict(trials=5,updates=450,crawlingTrials=sum(t['summary']['crawlSamples']>0 for t in trials),maximumCrawlY=256.0))

def run(capture):
 trials=[];seeds={};selected=[];names=None
 for family,side,bloated in [('normal-west','west',False),('normal-east','east',False),('bloated-east','east',True)]:
  g,o,setup=prepare_bloated_orphan(capture) if bloated else prepare_orphan(capture,side)
  back=round_trip(g,o,side);state=g.save_state()
  initial=record(g,o,0);names=g.mario_action_names();seeds[family]=dict(setup=setup,returnTrail=back,initial=initial)
  local=[]
  for route in ROUTES[side]:
   for mode in (('walk','reverse-walk','reverse-crawl','reverse-idle') if bloated else ('walk','crawl')):
    g.load_state(state);inputs=[];samples=[initial];events=[];prior=None;stage=0;terminal='horizon'
    for k in range(2400):
     p=g.read('gMarioState.pos')
     if math.hypot(p[0]-route[stage][0],p[2]-route[stage][1])<150 and stage<len(route)-1:stage+=1
     pad=control(g,route[stage],mode)
     inputs.append(pad);advance(g,pad)
     if g.read('gMarioObject').is_null() or g.read('gCurrAreaIndex')!=1 or g.read('gCurrLevelNum')!=8:
      terminal='left valid SSL Area1 Mario context';break
     r=record(g,o,k+1);samples.append(r)
     key=(r['action'],r['actors'][0]['behavior'],r['actors'][0]['activeFlags'],r['actors'][0]['oHeldState'])
     if key!=prior:events.append(dict(n=k+1,entries=[names.get(e['action'],hex(e['action']))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION'],sample=r));prior=key
     if r['actors'][0]['behavior']!='bhvBobomb' or not r['actors'][0]['activeFlags']:
      terminal='original Bobomb inactive or replaced';break
    t=dict(family=family,side=side,bloated=bloated,route=route,mode=mode,stage=stage,inputs=inputs,samples=samples,events=events,summary=summarize(samples,inputs,terminal))
    local.append(t);trials.append(t)
    print(family,mode,len(inputs),'maxY',t['summary']['maximumY'],'distance',t['summary']['minimumPyramidDistance'],'stage',stage,flush=True)
  for t in [min(local,key=lambda t:t['summary']['minimumPyramidDistance']),max(local,key=lambda t:t['summary']['maximumCrawlY']or -1)]:
   fresh,fo,recreated=prepare_bloated_orphan(capture) if bloated else prepare_orphan(capture,side)
   assert recreated==setup
   assert round_trip(fresh,fo,side)==back
   assert record(fresh,fo,0)==initial
   for k,pad in enumerate(t['inputs']):
    advance(fresh,pad)
    if k+1<len(t['samples']):assert record(fresh,fo,k+1)==t['samples'][k+1]
    else:assert fresh.read('gMarioObject').is_null() or fresh.read('gCurrAreaIndex')!=1 or fresh.read('gCurrLevelNum')!=8
   selected.append(dict(trialIndex=trials.index(t),matchedSnapshots=len(t['samples']),terminalMatched=True))
 tornado=tornado_search(capture,trials[0]);roof=entrance_roof_crawl(capture,trials[0])
 return dict(schema=1,scope=__doc__,baselineSha256=sha(capture),runtimeSha256=sha('build/wafel-pilot/sm64_jp.dll'),
  scriptSha256=sha(__file__),helperSha256={p:sha(Path(__file__).with_name(p))for p in ('ink_handsfree_teleport.py','ink_box_delivery.py','replay.py')},
  bounds=dict(routesPerSide=4,normalModes=['walk','crawl'],bloatedModes=['walk','reverse-walk','reverse-crawl','reverse-idle'],horizon=2400,waypointRadius=150),seeds=seeds,trials=trials,selectedFreshReplays=selected,tornadoFollowup=tornado,entranceRoofCrawl=roof,
  sourceSha256={p:sha(Path('../../../reference-sm64-decomp')/p)for p in ['src/game/interaction.c','src/game/mario_actions_automatic.c','src/game/mario_actions_airborne.c','src/game/behaviors/tweester.inc.c']},
  summary=dict(trials=len(trials),updates=sum(len(t['inputs'])for t in trials),maximumY=max(t['summary']['maximumY']for t in trials),
   maximumCrawlY=max((t['summary']['maximumCrawlY']for t in trials if t['summary']['maximumCrawlY']is not None),default=None),
   minimumPyramidDistance=min(t['summary']['minimumPyramidDistance']for t in trials),maximumPillars=max(t['summary']['maximumPillars']for t in trials)))

def compact(raw,path):
 result={**{k:v for k,v in raw.items()if k not in ('trials','tornadoFollowup','entranceRoofCrawl')},'rawReportName':str(path).replace('\\','/'),'rawReportSha256':sha(path),
  'trials':[{**{k:v for k,v in t.items()if k!='samples'}}for t in raw['trials']]}
 followup=raw['tornadoFollowup'];result['tornadoFollowup']={**{k:v for k,v in followup.items()if k!='trials'},
  'trials':[{k:v for k,v in t.items()if k!='samples'}for t in followup['trials']]}
 roof=raw['entranceRoofCrawl'];result['entranceRoofCrawl']={**{k:v for k,v in roof.items()if k!='trials'},
  'trials':[{k:v for k,v in t.items()if k!='samples'}for t in roof['trials']]}
 return result

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--receipt',type=Path,required=True);a=p.parse_args()
 r=run(a.capture)
 with a.output.open('x',encoding='utf-8',newline='\n')as f:json.dump(r,f,indent=2,allow_nan=False);f.write('\n')
 with a.receipt.open('x',encoding='utf-8',newline='\n')as f:json.dump(compact(r,a.output),f,indent=2,allow_nan=False);f.write('\n')
 print(json.dumps(r['summary'],indent=2))
