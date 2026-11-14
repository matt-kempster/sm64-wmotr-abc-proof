"""Fresh controller replays of all retained Fly Guy branch histories.

The actor-only diagnostic replays its explicit three-XYZ cut; primary histories
allow no gameplay edits. Original-ROM validation is a separate root task.
"""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
sys.path.insert(0,str(HERE))
from search import ROOT,Guard,create_game,Observer,advance,sample

def read(p):return json.load(gzip.open(p))
def equal(actual,expected,context):
 assert set(actual)-set(expected) in [set(),{'topNative','topActive'}],context
 assert all(actual[k]==v for k,v in expected.items()),context

def main():
 checks=[]
 for path in sorted((HERE/'records').glob('*.json.gz')):
  d=read(path);rows=d['prefixInputs'];trials=d['trials']
  g=Guard(create_game());o=Observer(g);states={};count=0
  box='stationary-box' in path.name
  prefixes={t['recipe']['prefix']for t in trials}if 'approaches-v1' in path.name else {len(rows)}
  for n,pad in enumerate(rows):
   advance(g,pad)
   if n+1 in prefixes:states[n+1]=g.save_state()
  if box:
   for n,pad in enumerate(d['parentInputs'][:65]):
    advance(g,pad)
    if n+1 in [62,63,64,65]:states[len(rows)+n+1]=g.save_state()
  for j,t in enumerate(trials):
   n0=t['samples'][0]['n'];g.load_state(states[n0])
   if box:
    for edit in t['edits']:
     assert edit['path'] in {'gObjectPool[23].oPosX','gObjectPool[23].oPosY','gObjectPool[23].oPosZ'}
     assert g.read(edit['path'])==edit['before'],(path.name,j,edit)
     g.g.write(edit['path'],edit['after'])
   equal(sample(g,o,n0),t['samples'][0],(path.name,j,'initial'));count+=1
   assert len(t['inputs'])+1==len(t['samples'])
   for i,pad in enumerate(t['inputs']):
    advance(g,pad);equal(sample(g,o,n0+i+1),t['samples'][i+1],(path.name,j,i));count+=1
  checks.append(dict(file=path.name,histories=len(trials),matchedObservations=count,
   suppliedState='small box23 XYZ once per trial'if box else 'none after inherited debug level selection'))
  print('MATCH',path.name,len(trials),count,flush=True)
 for name in ['native-roof','native-high-slide']:
  rows=[json.loads(line)for line in(HERE/(name+'-inputs.jsonl')).read_text().splitlines()]
  expected=read(HERE/(name+'-samples.json.gz'));g=Guard(create_game());o=Observer(g);count=0
  for n,pad in enumerate(rows):
   advance(g,pad)
   if n>=348:equal(sample(g,o,n+1),expected[n-348],(name,n+1));count+=1
  checks.append(dict(file=name,histories=1,matchedObservations=count,suppliedState='none after inherited debug level selection'))
  print('MATCH',name,len(rows),count,flush=True)
 receipt=dict(passed=True,AInputs=0,primaryGameplayWrites=0,checks=checks,
  histories=sum(c['histories']for c in checks),matchedObservations=sum(c['matchedObservations']for c in checks),
  limitations='Finite controller menus and actor-only component cuts; no exhaustive route claim. Original-ROM receipts are separate.')
 (HERE/'verification.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
 print('PASS',receipt['histories'],'histories',receipt['matchedObservations'],'observations')

if __name__=='__main__':main()
