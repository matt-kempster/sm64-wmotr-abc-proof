"""Conditional cap-in-hand flag distinguishes rendering suppression from action holding.

The initial cap flag is a diagnostic grant, not a controller-reached state.
Native updates derive the hand model; no body, renderer or HOLP writes follow.
"""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('cap_control_base',HERE/'check.py');b=importlib.util.module_from_spec(sp);sp.loader.exec_module(b)
r=b.r;iso=b.iso;h=b.h;cb=b.cb
def snap(g,o):
 t=b.snap(g,o);t['marioFlags']=g.read('gMarioState.flags');return t
def trial(g,o,states,profile,q):
 g.load_state(states[q['phase']]);edits=list(h.h.p.install_profile(g.g,o,profile)['writes']);edits+=r.place(g,39,b.BOB)
 cb.mario_cut(g,o,[b.AIR[0],q['y'],b.AIR[2]],'ACT_HOLD_FREEFALL',edits)
 cb.write(g,o,'gMarioState.heldObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioState.usedObj',g.address('gObjectPool[49]'),edits)
 cb.write(g,o,'gMarioObject.oInteractStatus',0,edits)
 cb.write(g,o,'gObjectPool[49].oHeldState',g.constant('HELD_HELD'),edits)
 edits+=r.place(g,49,[b.AIR[0],q['y']+60,b.AIR[2]+100])
 cb.write(g,o,'gMarioState.marioBodyState.heldObjLastPosition',[b.BOX[0],b.BOX[1],b.BOX[2]-32],edits)
 if q['capInHand']:cb.write(g,o,'gMarioState.flags',(g.read('gMarioState.flags')&~0x10)|0x20,edits)
 before=snap(g,o);g.mode='controls';rows=[];events=[];pads=[]
 for i in range(45):
  phase=g.read('gObjectPool[61].oTimer');pad=iso.B if i==0 else iso.Z if phase==128 else iso.NEUTRAL
  r.advance(g,o,pad,True);rows.append(snap(g,o));events.append(iso.frame_events(g));pads.append(pad)
  if rows[-1]['area']!=1:break
 release=next((dict(update=q['phase']+i,sample=x)for i,x in enumerate(rows)if x['held']==-1),None)
 cap=any(x['used']==64 and x['platform']==x['floorOwner']==61 for x in rows)
 arrival=next((x for x in rows if x['area']==2),None)
 return dict(recipe=q,initialEdits=edits,beforeInitial=before,controls=pads,samples=rows,events=events,laterGameplayEdits=[],firstRelease=release,
  capture=cap,arrival=arrival,useful=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875])
def menu():return [dict(phase=p,y=y,capInHand=c)for p,y,c in [(120,1930,True),(120,1930,False),(120,2000,True),(123,1930,True),(124,2000,True)]]
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 g,o,states,profile,prep=b.root();trials=[trial(g,o,states,profile,q)for q in menu()]
 q,qo,qs,qp,qr=b.root();assert prep==qr
 for t in trials:assert t==trial(q,qo,qs,qp,t['recipe'])
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,allAReleased=True,preparation=prep,trials=trials)
 dst=HERE/'cap-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in trials:
  print('CAP',t['recipe'],'capture',t['capture'],'useful',t['useful'],'release',t['firstRelease']['update']if t['firstRelease']else None,flush=True)
  for i,x in enumerate(t['samples'][:6]):print(t['recipe']['phase']+i,x['M'],x['actionName'],'held',x['held'],'HOLP',x['HOLP'],'hand',x['bodyHandState'],'flags',hex(x['marioFlags']),'Box',x['actors']['49']['position'],x['actors']['49']['oForwardVel'],x['actors']['49']['activeFlags'],flush=True)
 print('PASS five cap controls independently reconstructed twice')
if __name__=='__main__':main()
