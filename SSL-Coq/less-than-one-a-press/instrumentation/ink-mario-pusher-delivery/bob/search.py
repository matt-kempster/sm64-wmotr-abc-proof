"""Bounded controller-only Bob-omb transport toward Ink from the native donor.

No gameplay writes: only the established pre-entry level-select flag and pads.
Whole-state restores select branches reached through the recorded input prefix.
"""
import argparse, gzip, hashlib, json, math, sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer
from ink_box_delivery import advance,steer
from ink_handsfree_teleport import snap as base_snap

TARGET=(-2080.06005859375,1809.2066650390625,-1230.322021484375)
PREFIX=ROOT/'instrumentation/wafel-jp-pilot/ink-bobomb-regrab-transport-inputs.jsonl'
NEUTRAL=dict(buttons=0,stick=[0,0])

def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,path,value):
  assert path in ['gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'],path
  self.g.write(path,value)

def snap(g,o):
 s=base_snap(g,o,[39]);s['graphics']=s.pop('display')
 s.update(holp=g.read('gMarioState.marioBodyState.heldObjLastPosition'),
  topAction=g.read('gObjectPool[61].oAction'),topTimer=g.read('gObjectPool[61].oTimer'),
  pillars=g.read('gObjectPool[61].oPyramidTopPillarsTouched'),
  floorType=g.read('gMarioState.floor?.type'),quicksandDepth=g.read('gMarioState.quicksandDepth'),
  hurtCounter=g.read('gMarioState.hurtCounter'),interact=o.slot(g.read('gMarioState.interactObj')))
 return s

def root():
 assert sha(PREFIX)=='5fbabbad20efe0353072ac401279b81cc696415dd87621d905755b8dcf3e641b'
 pads=[json.loads(s)for s in PREFIX.read_text().splitlines()][:616]
 g=Guard(create_game());o=Observer(g)
 for p in pads:advance(g,p)
 s=snap(g,o);assert s['held']==39 and s['actors'][0]['hitboxRadius']==91
 return g,o,pads

def policies():
 routes=[('direct',[[TARGET[0],TARGET[2]]]),
  ('south-east-then-roof',[[2500,3500],[0,2000],[TARGET[0],TARGET[2]]]),
  ('south-west',[[2500,5000],[-4000,4000],[-4000,0],[TARGET[0],TARGET[2]]]),
  ('south-center',[[0,4500],[-2500,2000],[TARGET[0],TARGET[2]]])]
 return [dict(name=name+f'-turn{turn}',route=route,turnLimit=turn,period=2,phase=0,horizon=850)
   for name,route in routes for turn in [1024,4096]]

def distance(s):
 a=s['actors'][0]['xyz'];return math.sqrt(sum((a[i]-TARGET[i])**2 for i in range(3)))
def alive(s):return s['actors'][0]['behavior']=='bhvBobomb' and s['actors'][0]['activeFlags']!=0

def control(g,s,k,p,stage):
 pos=s['movement'];held=s['held']==39;a=s['actors'][0]
 while stage<len(p['route'])-1 and math.hypot(pos[0]-p['route'][stage][0],pos[2]-p['route'][stage][1])<180:stage+=1
 target=p['route'][stage]
 if held:
  # Held enlarged actor pushes backwards; face away from desired travel.
  desired=math.atan2(pos[0]-target[0],pos[2]-target[1]);current=s['face'][1]*math.tau/65536
  change=(desired-current+math.pi)%math.tau-math.pi;cap=p['turnLimit']*math.tau/65536
  angle=current+max(-cap,min(cap,change));target=(pos[0]+1000*math.sin(angle),pos[2]+1000*math.cos(angle))
 else:target=(a['xyz'][0],a['xyz'][2])
 buttons=0
 if (not held or s['action']==0x0c400201) and (k-p['phase'])%p['period']==0:buttons=0x4000
 if s['action'] in (0x08000207,0x00000442) and s['marioInteract']&8:buttons=0x4000
 return steer(g,target,buttons),stage

def summarize(t):
 rows=t['samples'];held=[s for s in rows if s['held']==39 and alive(s)]
 free=[s for s in rows if s['held']!=39 and alive(s) and s['actors'][0]['oHeldState']==0]
 return dict(updates=len(t['controls']),closestLive=min((s for s in rows if alive(s)),key=distance),
  closestFree=min(free,key=distance,default=None),minimumDistance=min(distance(s)for s in rows if alive(s)),
  maximumHeldY=max((s['movement'][1]for s in held),default=None),
  maximumLiveActorY=max(s['actors'][0]['xyz'][1]for s in rows if alive(s)),
  regrabs=sum(a['held']!=39 and b['held']==39 for a,b in zip(rows,rows[1:])),
  freeTransitions=sum(a['held']==39 and b['held']!=39 for a,b in zip(rows,rows[1:])),
  maxPillars=max(s['pillars']for s in rows),maxHeldFuse=max((s['actors'][0]['fuse']for s in held),default=None),
  final=rows[-1],survives=alive(rows[-1]))

def trial(g,o,state,p):
 g.load_state(state);rows=[snap(g,o)];pads=[];events=[];stage=0
 for k in range(p['horizon']):
  if not alive(rows[-1]) or rows[-1]['area']!=1:break
  pad,stage=control(g,rows[-1],k,p,stage);pads.append(pad);advance(g,pad);s=snap(g,o);rows.append(s)
  if (s['action'],s['held'],s['actors'][0]['oHeldState'],s['actors'][0]['activeFlags']) != (rows[-2]['action'],rows[-2]['held'],rows[-2]['actors'][0]['oHeldState'],rows[-2]['actors'][0]['activeFlags']):
   events.append(dict(update=k+1,entries=[dict(action=e['action'],name=g.mario_action_names().get(e['action'],hex(e['action'])))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']))
 t=dict(policy=p,controls=pads,samples=rows,events=events);t['summary']=summarize(t);return t

def run():
 g,o,prefix=root();state=g.save_state();trials=[]
 for p in policies():
  t=trial(g,o,state,p);trials.append(t);s=t['summary']
  print(p['name'],s['updates'],'distance',round(s['minimumDistance'],2),'heldY',s['maximumHeldY'],'actorY',s['maximumLiveActorY'],'regrabs',s['regrabs'],'final',s['final']['movement'],flush=True)
 return dict(schema=1,scope=__doc__,sourceRevision='9921382a68bb0c865e5e45eb594d9c64db59b1af',
  proofRevision='0605d842cedb55151e70952d56064553c4970f60',runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll'),
  prefixSha256=sha(PREFIX),prefixControls=prefix,gameplayEdits=[],preEntryEdits=[dict(path='gDebugLevelSelect',value=1)],
  target=list(TARGET),trials=trials)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 data=run();out=HERE/'results.json.gz'
 if a.verify:assert data==json.loads(gzip.decompress(out.read_bytes()))
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(data,separators=(',',':'))+'\n').encode(),mtime=0))
 # Fresh reconstruction of each selected full input history; no restored game supplied.
 selected=sorted(data['trials'],key=lambda t:t['summary']['minimumDistance'])[:2]
 for t in selected:
  g,o,prefix=root();assert snap(g,o)==t['samples'][0]
  for p,s in zip(t['controls'],t['samples'][1:]):advance(g,p);assert snap(g,o)==s
 print('PASS selected two complete controller-only replays',flush=True)
if __name__=='__main__':main()
