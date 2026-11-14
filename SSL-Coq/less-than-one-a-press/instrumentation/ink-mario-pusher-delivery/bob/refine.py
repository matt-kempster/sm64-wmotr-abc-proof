"""Small terrain-route follow-up to the first eight native Bob policies."""
import argparse,gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import search as s

def policies():
 routes=[('direct',[[s.TARGET[0],s.TARGET[2]]]),
  ('far-south',[[4000,6000],[0,6500],[-5000,5500],[-6000,0],[s.TARGET[0],s.TARGET[2]]]),
  ('southwest',[[2000,5500],[-4500,5500],[-6000,0],[s.TARGET[0],s.TARGET[2]]]),
  ('west-first',[[-5000,4400],[-6000,0],[s.TARGET[0],s.TARGET[2]]])]
 return [dict(name=name+f'-turn{turn}-phase{phase}',route=route,turnLimit=turn,period=2,phase=phase,horizon=1200)
  for name,route in routes for turn in [8192,16384]for phase in [0,1]]

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');args=ap.parse_args()
 g,o,prefix=s.root();state=g.save_state();trials=[]
 for p in policies():
  t=s.trial(g,o,state,p);trials.append(t);r=t['summary']
  print(p['name'],r['updates'],'distance',round(r['minimumDistance'],2),'heldY',r['maximumHeldY'],'regrabs',r['regrabs'],'final',r['final']['movement'],flush=True)
 result=dict(schema=1,scope=__doc__,prefixControls=prefix,gameplayEdits=[],preEntryEdits=[dict(path='gDebugLevelSelect',value=1)],trials=trials)
 out=s.HERE/'refined-results.json.gz'
 if args.verify:assert result==json.loads(gzip.decompress(out.read_bytes()))
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 best=min(trials,key=lambda t:t['summary']['minimumDistance']);g,o,prefix=s.root()
 for p,row in zip(best['controls'],best['samples'][1:]):s.advance(g,p);assert s.snap(g,o)==row
 print('PASS closest complete controller-only replay',flush=True)
if __name__=='__main__':main()
