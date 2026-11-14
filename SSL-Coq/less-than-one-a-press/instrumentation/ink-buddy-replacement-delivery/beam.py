"""Finite controller-only small-box carry beam, branching only reached states."""
import argparse,gzip,json,math,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import seed,acquire,sample,advance,steer

def score(s):
 d=math.hypot(s['M'][0]+2048,s['M'][2]+1024)
 return d-0.4*s['M'][1]+25*s['quicksand']

def run(a):
 g,o,prefix=seed(a.capture,500)
 pick=acquire(g,o,23,[5900,3440],[(4800,4200),(5300,4000)],110,divePeriod=24)
 assert pick['acquired']
 base=sample(g,o,23);front=[dict(state=g.save_state(),inputs=[],s=base)];rows=[];best=front[0];bestfull=[]
 attempted=0;updates=0;maxheld=base['M'][1]
 for depth in range(a.rounds):
  candidates=[]
  for b in front:
   p=b['s']['M']
   toward=math.atan2(-2048-p[0],-1024-p[2])
   for offset in [0,-0.4,0.4,-0.8,0.8,-1.4,1.4,math.pi]:
    g.load_state(b['state']);local=[];alive=True
    angle=toward+offset;target=(p[0]+2000*math.sin(angle),p[2]+2000*math.cos(angle))
    for k in range(a.step):
     pad=steer(g,target,0);local.append(pad);advance(g,pad);updates+=1
     s=sample(g,o,23)
     if not s['marioPresent']or s['held']!=23 or s['health']<256 or s['level']!=8 or s['area']!=1 or s['actor']['behavior']!='bhvBreakableBoxSmall' or not s['actor']['activeFlags']:
      alive=False;break
     maxheld=max(maxheld,s['M'][1])
    attempted+=1
    if alive:candidates.append(dict(state=g.save_state(),inputs=b['inputs']+local,s=s))
  if not candidates:break
  candidates.sort(key=lambda x:score(x['s']));seen=set();front=[]
  for b in candidates:
   s=b['s'];key=(round(s['M'][0]/120),round(s['M'][1]/120),round(s['M'][2]/120),s['action'])
   if key in seen:continue
   seen.add(key);front.append(b)
   if len(front)>=a.width:break
  if score(front[0]['s'])<score(best['s']):best=front[0];bestfull=best['inputs'][:]
  r=dict(depth=depth+1,candidates=len(candidates),retained=len(front),best=front[0]['s'],bestScore=score(front[0]['s']))
  rows.append(r)
  if depth%5==0:print('beam',depth+1,len(front),score(front[0]['s']),front[0]['s']['M'],front[0]['s']['actionName'],flush=True)
  if math.hypot(front[0]['s']['M'][0]+2048,front[0]['s']['M'][2]+1024)<100:break
 fresh,fo,originalprefix=seed(a.capture,500);assert originalprefix==prefix
 recreated=acquire(fresh,fo,23,[5900,3440],[(4800,4200),(5300,4000)],110,divePeriod=24);assert recreated==pick
 samples=[sample(fresh,fo,23)]
 for pad in bestfull:advance(fresh,pad);samples.append(sample(fresh,fo,23))
 assert samples[-1]==best['s']
 result=dict(scope=__doc__,gameplayWrites=[],AInputs=0,startupGrant='gDebugLevelSelect=1',
  menu=dict(offsets=[0,-0.4,0.4,-0.8,0.8,-1.4,1.4,math.pi],width=a.width,step=a.step,rounds=a.rounds,score='XZ distance to(-2048,-1024) minus0.4Y plus25quicksand; bucket120xyz+action'),
  attemptedBranches=attempted,branchUpdates=updates,maximumHeldY=maxheld,rounds=rows,prefixInputs=prefix,
  acquisition=pick,selected=dict(inputs=bestfull,samples=samples,freshReplayMatched=len(samples)),final=best['s'])
 with gzip.GzipFile(filename=str(a.output),mode='wb',mtime=0)as f:f.write((json.dumps(result,separators=(',',':'))+'\n').encode())
 print('complete',attempted,updates,'best',best['s']['M'],'maxheldY',maxheld,flush=True)

if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('output',type=Path);p.add_argument('--rounds',type=int,default=60);p.add_argument('--step',type=int,default=20);p.add_argument('--width',type=int,default=10);a=p.parse_args();run(a)
