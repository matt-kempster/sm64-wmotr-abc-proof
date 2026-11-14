"""Controller-only perimeter carries of the natively acquired small box."""
import gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import seed,acquire,carry,advance,sample

def run():
 capture=Path('build/wafel-pilot/capture.bKv95w/inputs.jsonl');g,o,prefix=seed(capture,500)
 pick=acquire(g,o,23,[5900,3440],[(4800,4200),(5300,4000)],110,divePeriod=24);assert pick['acquired'];state=g.save_state()
 routes=[[(5000,3440),(4000,3500),(3000,4500),(3000,7000),(0,7400),(-5000,7000),(-6500,3500),(-6500,-3000),(-4500,-4000),(-2200,-3000),(-2048,-1024)],
 [(5000,3440),(4000,3500),(2500,4500),(2500,7000),(0,7400),(-5000,7000),(-6500,3500),(-6500,-3000),(-4500,-4000),(-2200,-3000),(-2048,-1024)],
 [(5000,3440),(4000,3500),(2500,6000),(0,7400),(-5000,7000),(-6500,3500),(-6500,-3000),(-4500,-4000),(-2200,-3000),(-2048,-1024)],
 [(5000,3440),(4000,3500),(3000,4500),(3000,7000),(0,7400),(-5000,7000),(-5000,4000),(-3500,2500),(-2200,1200),(-2048,-1024)]]
 trials=[]
 for route in routes:
  g.load_state(state);t=carry(g,o,23,route,3000);trials.append(t)
  print('perimeter',t['finalStage'],len(t['inputs']),t['maximumHeldY'],t['minimumPyramidDistance'],t['samples'][-1]['M'],t['samples'][-1]['actionName'],flush=True)
 out=dict(scope=__doc__,startupGrant='gDebugLevelSelect=1 only',gameplayWrites=[],AInputs=0,prefixInputs=prefix,acquisition=pick,trials=trials)
 with gzip.GzipFile(filename='build/wafel-pilot/buddy-replacement-smallbox-perimeter-v1.json.gz',mode='wb',mtime=0)as f:f.write((json.dumps(out,separators=(',',':'))+'\n').encode())
if __name__=='__main__':run()
