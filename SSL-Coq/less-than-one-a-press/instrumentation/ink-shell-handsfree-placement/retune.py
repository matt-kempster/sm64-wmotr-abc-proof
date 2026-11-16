"""Twelve actual remote shell heights; Box drop at native mount, no later edits."""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
sp=importlib.util.spec_from_file_location('handsfree_retune_base',HERE/'check.py');b=importlib.util.module_from_spec(sp);sp.loader.exec_module(b)
r=b.r;iso=b.iso;h=b.h
HEIGHTS=[1800,1840,1860,1880,1900,1920,1940,1960,1980,2010,19900,24990]
def run():
 raw,o,slot,base,spawn=iso.roots();pickup,held=iso.pickup(raw,o,slot,base)
 profiles=h.h.p.native_profiles();profile=profiles['profiles']['released91'];trials=[]
 for y in HEIGHTS:
  target=[b.AIR[0],y,b.AIR[2]];release=h.release(raw,o,slot,held,target);wait=[]
  while raw.read('gObjectPool[61].oTimer')<128:iso.advance(raw,iso.NEUTRAL);wait.append(iso.NEUTRAL)
  assert [raw.read(f'gObjectPool[{slot}].oPos'+a)for a in'XYZ']==target
  g=r.Guard(raw,slot);q=dict(phase=128,y=y+10,action='ACT_FREEFALL',first='neutral')
  t=b.trial(g,o,{128:raw.save_state()},profile,q)
  assert not any(e['path'].startswith(f'gObjectPool[{slot}]')for e in t['initialEdits'])
  trials.append(dict(shellY=y,shellTarget=target,nativeRelease=release,waitControls=wait,continuation=t))
 return dict(preparation=dict(spawn=spawn,pickup=pickup,donor=profiles),trials=trials)
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args();data=run();assert data==run()
 out=dict(schema=1,scope=__doc__,independentFreshRoots=2,allAReleased=True,results=data)
 dst=HERE/'retune-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(dst.read_bytes()))==out
 else:assert not dst.exists();dst.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 for x in data['trials']:
  t=x['continuation'];print('RETUNE shellY',x['shellY'],'useful',t['useful'],'capture',t['capture'],'arrival',t['arrival']['M']if t['arrival']else None,flush=True)
  for i,s in enumerate(t['samples'][:4]):print(128+i,s['M'],s['actionName'],'G',s['G'],'floor',s['floorY'],'Box',s['actors']['49']['position'],s['actors']['49']['activeFlags'],s['actors']['49']['behavior'],'collisions',s['collisions'],flush=True)
 print('PASS',len(data['trials']),'shell heights twice; actual shell throw plus native mount Box drop',flush=True)
if __name__=='__main__':main()
