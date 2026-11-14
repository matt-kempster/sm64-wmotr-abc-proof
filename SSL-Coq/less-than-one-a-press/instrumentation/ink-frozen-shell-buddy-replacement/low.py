"""Low frozen shell stays at its initial position after native mount/Z.

Finite 3x3 initial shell offsets; no Buddy or later shell/Mario writes.
"""
import argparse,gzip,itertools,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from test import HERE,ROOT,iso,roots,snap,place,BOX129,BOX130

def trial(w,o,state,offset):
 g=w.g;g.load_state(state);initial=snap(w,o);edits=[]
 p=[-1922.4404296875,1810,-1223.34130859375]
 iso.mario(g,o,p,edits);iso.write(g,o,'gMarioState.vel',[0,-16,20],edits);iso.write(g,o,'gMarioState.faceAngle',[0,0,0],edits)
 iso.position(g,o,w.slot,[p[0]+offset[0],1800,p[2]+offset[1]],edits)
 t=dict(offset=offset,initial=initial,edits=edits,before=snap(w,o),cuts=[],samples=[],events=[],controls=[])
 for i in range(36):
  cut=[]
  if i==1:place(g,49,BOX129,cut)
  if i==2:place(g,49,BOX130,cut)
  if cut:t['cuts'].append(dict(beforeUpdate=i+1,edits=cut))
  pad=iso.Z if i==0 else iso.NEUTRAL;iso.advance(g,pad)
  s=snap(w,o);t['samples'].append(s);t['events'].append(iso.frame_events(g));t['controls'].append(pad)
  assert not s.get('input',0)&0x82
  if s['area']!=1:break
 t['mounted']=any(e['type']=='FLT_CHANGE_ACTION'and e.get('to')==g.constant('ACT_RIDING_SHELL_GROUND')for e in t['events'][0])
 t['capture']=any(s.get('used')==64 and s.get('floorOwner')==s.get('platform')==61 for s in t['samples'])
 arrival=next((s for s in t['samples']if s['area']==2),None)
 t['useful']=arrival is not None and arrival['M']==[365.5927734375,5500,-1096.8026123046875]
 t['firstAction129']=next((e for e in t['events'][1]if e['type']=='FLT_EXECUTE_ACTION'),None)
 return t

def run():
 g,o,state,prep=roots(1810);ts=[trial(g,o,state,list(off))for off in itertools.product([-60,0,60],repeat=2)]
 for t in ts:print(t['offset'],'mounted',t['mounted'],'collision129',t['samples'][1]['collisions'],'entry',t['firstAction129']['pos'],'after129',t['samples'][1]['M'],'capture',t['capture'],'useful',t['useful'],flush=True)
 assert all(t['mounted']and not t['capture']and not t['useful']for t in ts)
 assert sum(71 in t['samples'][1]['collisions']for t in ts)==7
 for t in ts:assert all(s['shell']['position']==t['before']['shell']['position']for s in t['samples'])
 return dict(preparation=prep,trials=ts)

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',type=Path);a=ap.parse_args();r=run();q=run();assert r==q
 out=dict(schema=1,proofStart='c1f31bff1365055745d08fdd2728ac501378c4df',independentlyVerified=True,checkedBoundaries=sum(len(t['samples'])for t in r['trials']),results=r)
 if a.verify:assert json.loads(gzip.decompress(a.verify.read_bytes()))==json.loads(json.dumps(out))
 else:
  p=HERE/'low-results.json.gz';assert not p.exists();p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS low',out['checkedBoundaries'],flush=True)
if __name__=='__main__':main()
