"""Measure actual HOLP and native release after a controller-produced uphill carry."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import Guard,create_game,Observer,sample,advance
r=json.loads(gzip.decompress(Path('build/wafel-pilot/buddy-replacement-smallbox-perimeter-pulse-v1.json.gz').read_bytes()))
t=r['trials'][4];prefix=r['prefixInputs']+t['inputs'][:1508]
def snap(g,o):
 s=sample(g,o,23);s['HOLP']=g.read('gMarioState.marioBodyState.heldObjLastPosition');s['floorNormal']=g.read('gMarioState.floor?.normal');return s
g=Guard(create_game());o=Observer(g)
for p in prefix:advance(g,p)
assert sample(g,o,23)=={k:v for k,v in t['samples'][1508].items()if k!='floorNormal'}
initial=snap(g,o);state=g.save_state();trials=[]
for mask in [0,0x2000,0x4000]:
 g.load_state(state);inputs=[];samples=[initial]
 for n in range(60):
  pad=dict(buttons=mask if n==0 else 0,stick=[0,0]);inputs.append(pad);advance(g,pad);samples.append(snap(g,o))
 trials.append(dict(button=mask,inputs=inputs,samples=samples))
 print(hex(mask),'HOLPstart',initial['HOLP'],'firstrelease',next(((i,s['M'],s['actor']['xyz'],s['HOLP'])for i,s in enumerate(samples)if s['held']!=23),None),flush=True)
out=dict(scope=__doc__,startupGrant='gDebugLevelSelect=1 only',gameplayWrites=[],AInputs=0,prefixInputs=prefix,initial=initial,trials=trials)
with gzip.GzipFile(filename='build/wafel-pilot/buddy-replacement-smallbox-holp-release-v1.json.gz',mode='wb',mtime=0)as f:f.write((json.dumps(out,separators=(',',':'))+'\n').encode())
