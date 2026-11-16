"""Observe HOLP on the genuinely controller-reached eastern hands-free box.

The remote-HOLP diagnostic changes only HOLP once after clean acquisition.
It does not supply an action, pointer, actor coordinate or Mario coordinate.
"""
import argparse,gzip,hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
from replay import create_game,Observer
from ink_box_delivery import advance
SOURCE=ROOT/'docs/notes/ink-clean-handsfree-receipt.json'
def inputs():
 d=json.loads(SOURCE.read_bytes());t=d['selected'][0];p=t['fullInputs']
 raw=''.join(json.dumps(x,separators=(',',':'))+'\n'for x in p).encode()
 assert len(p)==610 and hashlib.sha256(raw).hexdigest()=='f1cb547ac44de4044c6f174ce972fac23610a8fa3f2429347e9af4d84e919cb8'
 assert all(not x['buttons']&0x8000 for x in p)
 return p
def snap(g,o,n):
 return dict(completedInputs=n,timer=g.read('gGlobalTimer'),M=g.read('gMarioState.pos'),G=g.read('gMarioObject.header.gfx.pos'),
  action=g.read('gMarioState.action'),actionName=g.mario_action_names()[g.read('gMarioState.action')],held=o.slot(g.read('gMarioState.heldObj')),
  handState=g.read('gMarioState.marioBodyState.handState'),grabPos=g.read('gMarioState.marioBodyState.grabPos'),HOLP=g.read('gMarioState.marioBodyState.heldObjLastPosition'),
  boxHeld=g.read('gObjectPool[47].oHeldState'),boxActive=g.read('gObjectPool[47].activeFlags'),boxBehavior=g.read('gObjectPool[47].behavior')==g.address('bhvJumpingBox'),
  boxXYZ=[g.read('gObjectPool[47].oPos'+a)for a in 'XYZ'])
def run():
 pads=inputs();g=create_game();o=Observer(g);rows=[]
 for i,p in enumerate(pads[:436]):
  advance(g,p)
  if i+1>=410:rows.append(snap(g,o,i+1))
 assert rows[-1]['actionName']=='ACT_STOMACH_SLIDE'and rows[-1]['held']==47 and rows[-1]['boxHeld']==1
 state=g.save_state();branches=[]
 for remote in [False,True]:
  g.load_state(state);edits=[]
  if remote:
   path='gMarioState.marioBodyState.heldObjLastPosition';value=[-1962.4404296875,67277,-1243.34130859375]
   edits=[dict(path=path,before=g.read(path),after=value)];g.write(path,value)
  seen=[snap(g,o,436)]
  for n,p in enumerate(pads[436:456],437):advance(g,p);seen.append(snap(g,o,n))
  branches.append(dict(remoteHOLPDiagnostic=remote,edits=edits,inputs=pads[436:456],samples=seen))
 assert all(s['held']==47 and s['boxHeld']==1 and s['actionName']=='ACT_STOMACH_SLIDE'and s['handState']==0 and s['grabPos']==1 for b in branches for s in b['samples'])
 assert all(len(set(tuple(s['HOLP'])for s in b['samples']))==21 for b in branches)
 assert branches[0]['samples'][1:]==branches[1]['samples'][1:]
 return dict(scope=__doc__,preEntrySetup='create_game gDebugLevelSelect=1',acquisitionInputs=pads[:436],acquisitionObservations=rows,branches=branches)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();data=run();assert data==run()
 out=dict(schema=1,independentFreshReconstructions=2,results=data);p=HERE/'results.json.gz'
 if a.verify:assert json.loads(gzip.decompress(p.read_bytes()))==json.loads(json.dumps(out))
 else:p.write_bytes(gzip.compress((json.dumps(out,separators=(',',':'))+'\n').encode(),mtime=0))
 print('ACQUISITION',[(s['completedInputs'],s['actionName'],s['held'],s['handState'],s['grabPos'],s['HOLP'])for s in data['acquisitionObservations']if s['completedInputs']in[410,423,424,435,436]])
 for b in data['branches']:print('BRANCH',b['remoteHOLPDiagnostic'],'distinctHOLP',len(set(tuple(s['HOLP'])for s in b['samples'])),'first',b['samples'][0],'next',b['samples'][1],'last',b['samples'][-1])
if __name__=='__main__':main()
