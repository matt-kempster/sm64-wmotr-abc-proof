"""Finite native mount/Z/remount status controls; all return approaches supplied."""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('shell_distance_shared',HERE/'check.py');d=importlib.util.module_from_spec(sp);sp.loader.exec_module(d);iso=d.iso

def advance(g,o,slot,t,pad):
 iso.advance(g,pad);s=d.snapshot(g,o,slot);t['controls'].append(pad);t['samples'].append(s);t['events'].append(iso.frame_events(g));assert not s['input']&0x82;return s

def trial(g,o,slot,state,mode,immediate,low):
 g.load_state(state);edits=[]
 if mode=='live':iso.position(g,o,slot,low,edits)
 p=d.snapshot(g,o,slot)['shell']['position'];iso.mario(g,o,[p[0],p[1]+10,p[2]],edits,speed=0)
 t=dict(mode=mode,immediateZ=immediate,initialEdits=edits,initial=d.snapshot(g,o,slot),controls=[],samples=[],events=[])
 advance(g,o,slot,t,iso.Z if immediate else iso.NEUTRAL)
 advance(g,o,slot,t,iso.NEUTRAL if immediate else iso.Z)
 advance(g,o,slot,t,iso.NEUTRAL)
 a=t['samples'][-1]['shell']
 if a['behavior']=='bhvKoopaShell' and a['activeFlags']&1:
  p=a['position'];e=[];iso.mario(g,o,[p[0],p[1]+10,p[2]],e,speed=0)
  t['secondApproach']=dict(beforeUpdate=4,edits=e);advance(g,o,slot,t,iso.Z)
 return t

def run():
 g,o,slot,base,prep=iso.roots();pick,held=iso.pickup(g,o,slot,base);drop,frozen=iso.release(g,o,slot,held,'drop')
 low=drop['samples'][-1]['shell']['position'];trials=[]
 for mode,state in [('live',base),('frozen',frozen)]:
  for immediate in [True,False]:trials.append(trial(g,o,slot,state,mode,immediate,low))
 for t in trials:
  assert any(e['type']=='FLT_CHANGE_ACTION' and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for e in t['events'][0])
  if t['mode']=='live' and not t['immediateZ']:
   assert not t['samples'][1]['shell']['activeFlags']&1 and 'secondApproach'not in t
  else:
   assert 'secondApproach'in t
   assert any(e['type']=='FLT_CHANGE_ACTION' and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for e in t['events'][3])
 return dict(preparation=prep,pickup=pick,drop=drop,trials=trials)

def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args();r=run();assert r==run()
 out=dict(schema=1,scope=__doc__,independentFreshReconstructions=2,results=r);f=HERE/'status-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(f.read_bytes()))==out
 else:assert not f.exists();f.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in r['trials']:
  print(t['mode'],'sameUpdateZ',t['immediateZ'],[(s['actionName'],s['shell']['activeFlags'],s['shell']['oAction'],s['shell']['oInteractStatus'],s['ridden'])for s in t['samples']],flush=True)
 print('PASS four twice-reconstructed mount/Z status histories; remount approach remains supplied')
if __name__=='__main__':main()
