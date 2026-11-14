"""Actual input-only release controls on the native Bob pickup histories."""
import argparse,gzip,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import search as s

def run_case(seed,press,buttons):
 pads=[json.loads(x)for x in s.PREFIX.read_text().splitlines()][:seed]
 g=s.Guard(s.create_game());o=s.Observer(g)
 for p in pads:s.advance(g,p)
 rows=[s.snap(g,o)];controls=[];events=[]
 for k in range(40):
  if not s.alive(rows[-1]):break
  p=dict(buttons=buttons if seed+k+1==press else 0,stick=[0,0]);controls.append(p);s.advance(g,p);rows.append(s.snap(g,o))
  events.append(dict(completedInputs=seed+k+1,actions=[dict(action=e['action'],name=g.mario_action_names().get(e['action'],hex(e['action'])))for e in g.frame_log()if e['type']=='FLT_EXECUTE_ACTION']))
 release=next((dict(completedInputs=seed+i,sample=r)for i,r in enumerate(rows)if r['held']!=39),None)
 return dict(seed=seed,pressInput=press,buttons=buttons,prefixControls=pads,controls=controls,samples=rows,events=events,
  firstRelease=release,gameplayEdits=[],final=rows[-1])

def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');args=ap.parse_args()
 recipes=[(616,None,0)]+[(616,p,b)for p in[627,628]for b in[0x4000,0x2000]]+[(597,609,0x4000),(597,609,0x2000)]
 results=[run_case(*r)for r in recipes]
 for r,expected in zip(recipes,results):assert run_case(*r)==expected
 result=dict(schema=1,scope=__doc__,cases=results,independentlyVerified=True,preEntryEdits=[dict(path='gDebugLevelSelect',value=1)])
 out=s.HERE/'release-results.json.gz'
 if args.verify:assert result==json.loads(gzip.decompress(out.read_bytes()))
 else:
  assert not out.exists();out.write_bytes(gzip.compress((json.dumps(result,separators=(',',':'))+'\n').encode(),mtime=0))
 for r in results:
  q=r['firstRelease'];a=q['sample']['actors'][0]
  print('seed',r['seed'],'press',r['pressInput'],hex(r['buttons']),'release',q['completedInputs'],'M',q['sample']['movement'],'Bob',a['xyz'],'radius',a['hitboxRadius'],'action',a['oAction'],'fuse',a['fuse'],flush=True)
 print('PASS seven twice-fresh actual release histories',flush=True)
if __name__=='__main__':main()
