"""Controller-only Crazy Box release predecessor and bounded local steering.

The existing accepted route and native pickup are replayed, with no position,
action, actor, HOLP, pointer, RNG or phase writes. Only the established debug
level-select bootstrap precedes the write guard. This does not assume a
castle-to-SSL history, a frozen shell, or the enlarged Bob profile.
"""
import argparse,gzip,hashlib,importlib.util,json,math,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]
sys.path.insert(0,str(ROOT/'instrumentation/wafel-jp-pilot'))
import ink_box_delivery as b
from replay import create_game,Observer,load_capture,set_input
TARGET=[-2102.720703125,1839.447265625,-1119.5618896484375]
RECEIPT=ROOT/'docs/notes/ink-box-delivery-receipt.json'
PREFIX=ROOT/'instrumentation/ink-high-item-nudge/prefix.jsonl.gz'
class Guard:
 def __init__(self,g):self.g=g
 def __getattr__(self,k):return getattr(self.g,k)
 def write(self,p,v):
  assert p in {'gControllerPads[0].button','gControllerPads[0].stick_x','gControllerPads[0].stick_y'},p
  if p.endswith('.button'):assert not v&0x8000
  self.g.write(p,v)
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def snap(g,o,n):
 s=b.snap(g,o,n);s['actionName']=g.mario_action_names().get(s['action']);s['G']=s.pop('display');s['M']=s.pop('pos');s['C']=s.pop('collision')
 s['holp']=g.read('gMarioState.marioBodyState.heldObjLastPosition');s['box'].update({k:g.read('gObjectPool[49].'+k)for k in ['hitboxRadius','hitboxHeight','hitboxDownOffset','oInteractType','oInteractStatus']})
 return s
def root():
 raw=gzip.decompress(PREFIX.read_bytes());assert hashlib.sha256(raw).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
 rows=[json.loads(line)for line in raw.splitlines()if line];prefix=[dict(buttons=x['buttons'],stick=x['stick'])for x in rows[:2500]]
 record=json.loads(RECEIPT.read_text());chosen=next(t for t in record['selected']if t['policy']['seed']==2500)
 g=Guard(create_game());o=Observer(g);b.accepted_prefix(g,o,rows,2500)
 initial=snap(g,o,0);pre=[]
 for n,pad in enumerate(chosen['inputs'][:280]):b.advance(g,pad);pre.append(snap(g,o,n+1))
 assert pre[-1]['held']==49 and pre[-1]['action']==b.BOUNCE and pre[-1]['arg']==2
 return g,o,dict(prefixInputs=prefix,branchPrefixInputs=chosen['inputs'][:280],initial=initial,prefixSamples=pre,originalPolicy=chosen['policy']),chosen
def live_free(s):return s['boxBehavior']and bool(s['box']['activeFlags'])and s['held']!=49 and s['box']['oHeldState']==0 and s['box']['oIntangibleTimer']==0
def xyz(s):return [s['box']['oPos'+a]for a in 'XYZ']
def summary(samples):
 releases=[s for s in samples if live_free(s)]
 first=releases[0]if releases else None
 return dict(firstFreeRelease=first,highestFreeRelease=max(releases,key=lambda s:xyz(s)[1],default=None),closestFreeToTarget=min(releases,key=lambda s:math.dist(xyz(s),TARGET),default=None),minimumFreeDistance=min((math.dist(xyz(s),TARGET)for s in releases),default=None),freeSamples=len(releases),boxDeletion=next((s for s in samples if not s['boxBehavior']or not s['box']['activeFlags']),None),final=samples[-1])
def run():
 g,o,prep,chosen=root();state=g.save_state();trials=[]
 menu=[None]+[(x,z)for x in [-3600,-3300,-3000,-2700]for z in [-1400,-1100,-800]]
 for target in menu:
  g.load_state(state);samples=[snap(g,o,280)];inputs=[]
  for i in range(100):
   if samples[-1]['area']!=1 or samples[-1]['level']!=8 or g.read('gMarioState.area.camera').is_null():break
   pad=chosen['inputs'][280+i]if target is None else b.steer(g,target,0)
   inputs.append(dict(buttons=pad['buttons'],stick=pad['stick']));b.advance(g,pad);samples.append(snap(g,o,281+i))
  trials.append(dict(target=target,inputs=inputs,samples=samples,summary=summary(samples)))
 baseline=trials[0];release=baseline['summary']['firstFreeRelease']
 assert release['n']==304 and release['action']==b.TWIRLING and release['box']['oAction']==1
 assert release['box']['oPosY']==1259.514892578125
 return dict(preparation=prep,trials=trials)
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args();data=run();fresh=run();assert data==fresh
 result=dict(schema=1,scope=__doc__,targetReference=TARGET,onlyStartupGrant='gDebugLevelSelect=1 before entry',laterGameplayWrites=[],allAReleased=True,independentlyReconstructed=2,coverage=dict(seed=2500,existingBranchPrefix=280,steeringRecipes=12,originalContinuationControls=1,horizon=100,updates=sum(len(t['inputs'])for t in data['trials'])),inputs=dict(prefixSha256=sha(PREFIX),priorReceiptSha256=sha(RECEIPT),runtimeSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll')),results=data)
 path=HERE/'results.json.gz';encoded=(json.dumps(result,separators=(',',':'))+'\n').encode()
 if a.verify:assert json.loads(gzip.decompress(path.read_bytes()))==json.loads(encoded)
 else:assert not path.exists();path.write_bytes(gzip.compress(encoded,mtime=0))
 for t in data['trials']:
  s=t['summary'];f=s['firstFreeRelease'];print(t['target'],'release',None if f is None else dict(n=f['n'],M=f['M'],box=xyz(f),action=f['actionName'],boxAction=f['box']['oAction'],pillars=f['pillars']), 'distance',s['minimumFreeDistance'],'deleted',None if s['boxDeletion']is None else s['boxDeletion']['n'],flush=True)
 print('PASS two fresh controller-only reconstructions,',result['coverage'])
if __name__=='__main__':main()
