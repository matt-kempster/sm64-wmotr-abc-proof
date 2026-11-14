"""Native held-small-box component after explicit Mario-XYZ travel grants.

Real A-off pickup is replayed. No actor/reference/action/velocity/cache/HOLP
field is supplied. Mario M/C/gfx XYZ relocations are conditional travel cuts.
"""
import argparse,gzip,importlib.util,json,math,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('delivery_search',ROOT/'instrumentation/ink-buddy-replacement-delivery/search.py')
delivery=importlib.util.module_from_spec(spec);spec.loader.exec_module(delivery)
sys.path.insert(0,str(ROOT/'instrumentation/ink-high-action-entry'))
sys.path.insert(0,str(ROOT/'instrumentation/ink-item-clone-controls'))
from prelude import advance,NEUTRAL,rich_sample,frame_events,digest
from ink_crawl_predecessors import pose,loaded_top_floor,steer,f32
from fixtures import actor_snapshot

class Guard:
 def __init__(self,g):self.g=g;self.mode='controls'
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  if self.mode=='controls':assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  else:assert p in {'gMarioState.pos','gMarioObject.oPosX','gMarioObject.oPosY','gMarioObject.oPosZ','gMarioObject.header.gfx.pos'},p
  self.g.write(p,v)

def snap(g,o):
 s=rich_sample(g,o);s.update(box=actor_snapshot(g,23),HOLP=g.read('gBodyStates[0].heldObjLastPosition'))
 return s

def relocate(g,xyz):
 g.mode='travel';edits=[];pose(g,xyz,edits);g.mode='controls';return edits

def root(capture):
 g,o,prefix=delivery.seed(capture,500);a=delivery.acquire(g,o,23,[5900,3440],[(4800,4200),(5300,4000)],110,divePeriod=24)
 assert a['acquired'] and len(a['inputs'])==342
 g=Guard(g.g);ledger=[];inputs=prefix+a['inputs']
 for _ in range(20):advance(g,NEUTRAL);inputs.append(NEUTRAL)
 assert g.read('gMarioState.action')==g.constant('ACT_HOLD_IDLE')
 for xyz in [[1789,1024,764],[1789,896,-2579],[-5883,1024,-2579],[-5883,1024,764]]:
  edits=relocate(g,xyz);rows=[]
  for _ in range(3):advance(g,NEUTRAL);rows.append(snap(g,o))
  ledger.append(dict(edits=edits,controls=[NEUTRAL]*3,samples=rows))
 assert g.read('gObjectPool[61].oPyramidTopPillarsTouched')==4
 states={};count=0
 while g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')<=130:
  phase=g.read('gObjectPool[61].oTimer')
  if phase>=110:states[phase]=g.save_state()
  advance(g,NEUTRAL);count+=1
 assert 128 in states
 return g,o,states,dict(prefixInputs=inputs,acquisition=a,travel=ledger,waitNeutralUpdates=count,scope=__doc__)

def probe(capture,out):
 g,o,states,prep=root(capture);rows=[]
 for phase in [110,120,125,127,128,129,130]:
  g.load_state(states[phase]);s=snap(g,o);p=loaded_top_floor(g,-1920,-1210)
  print('ROOT',phase,s['actionName'],s['movement'],s['held'],'floorproposal',p,flush=True)
  if p is None:continue
  edits=relocate(g,[-1920,p['height'],-1210]);samples=[];pads=[]
  for i in range(5):
   pad=steer(g,[-1920,-1110],64);pad['buttons']=0x2000 if i==1 else 0
   advance(g,pad);pads.append(pad);samples.append(snap(g,o))
  rows.append(dict(phase=phase,edits=edits,controls=pads,samples=samples))
  print('RESULT',[(s['actionName'],s['movement'],s['held'],s['box']['position'],s['HOLP'])for s in samples],flush=True)
 with gzip.GzipFile(filename=str(out),mode='xb',mtime=0)as f:f.write((json.dumps(dict(scope=__doc__,preparation=prep,trials=rows),separators=(',',':'))+'\n').encode())

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('out',type=Path);a=p.parse_args();probe(a.capture,a.out)
