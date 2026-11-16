"""Controls removing the final supplied carried approach or the fresh Z edge."""
import argparse,gzip,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
s=importlib.util.spec_from_file_location('carried_frontier',HERE/'check.py');c=importlib.util.module_from_spec(s);s.loader.exec_module(c)
def unedited(g,o,state):
 g.load_state(state);e=[];c.cb.mario_cut(g,o,[5900,1920,3440],'ACT_HOLD_FREEFALL',e)
 for p,v in [('gMarioState.heldObj',g.address('gObjectPool[49]')),('gObjectPool[49].oHeldState',1),('gMarioState.marioBodyState.heldObjLastPosition',[c.b.BOX[0],1920,c.b.BOX[2]])]:c.cb.write(g,o,p,v,e)
 before=c.snap(g,o);controls=[c.iso.Z]+[c.iso.NEUTRAL]*47;rows=[];events=[];g.mode='controls'
 for p in controls:c.r.advance(g,o,p,True);rows.append(c.snap(g,o));events.append(c.iso.frame_events(g))
 return dict(name='omit-final-carried-approach',initialEdits=e,beforeInitial=before,cuts=[],controls=controls,samples=rows,events=events,
  laterGameplayEdits=[],capture=any(s['used']==64 and s['floorOwner']==s['platform']==61 for s in rows),
  useful=any(s['area']==2 and s['M']==[365.5927734375,5500,-1096.8026123046875]for s in rows))
def run():
 g,o,st,f,prep=c.root();return dict(preparation=prep,trials=[unedited(g,o,st),c.trial(g,o,st,f,dict(boxY=1920,marioY=1810,phase=128,vy=-16,forced=False,zPhase=-1))])
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();data=run();assert data==run()
 out=dict(schema=1,scope=__doc__,independentFreshReconstructions=2,allAReleased=True,results=data)
 p=HERE/'frontier-results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(p.read_bytes()))==json.loads(json.dumps(out))
 else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 for t in data['trials']:
  print(t.get('name',t.get('recipe')),'capture',t['capture'],'useful',t['useful'],'last',t['samples'][-1]['M'],flush=True)
  for s in t['samples'][:5]:print(s['topPhase'],s['M'],s['actionName'],s['held'],flush=True)
if __name__=='__main__':main()
