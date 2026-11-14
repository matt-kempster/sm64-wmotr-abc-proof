"""Reconstruct every preserved full history from the durable controller prefix."""
import argparse,gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
sys.path.insert(0,str(HERE))
from experiment import roots,full,ground_trial,advance

FILES=['substitutions.json.gz','shell-box-coarse.json.gz','shell-box-refined.json.gz','supplied-ground-controls.json.gz','supplied-clone-controls.json.gz','native-fly-contacts.json.gz']

def main():
 p=argparse.ArgumentParser();p.add_argument('--capture',type=Path);a=p.parse_args()
 capture=a.capture
 if capture is None:
  capture=ROOT/'build/wafel-pilot/buddy-replacement-verification-prefix.jsonl'
  data=gzip.decompress((ROOT/'instrumentation/ink-buddy-movement/original-prefix.jsonl.gz').read_bytes())
  assert hashlib.sha256(data).hexdigest()=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
  if capture.exists():assert capture.read_bytes()==data
  else:capture.write_bytes(data)
 g,o,states,slot,prep=roots(capture);histories=boundaries=0
 for name in FILES:
  data=json.load(gzip.open(HERE/name));assert data['prefixSha256']==hashlib.sha256(capture.read_bytes()).hexdigest();assert data['preparation']==prep
  for saved in data['trials']:
   r=saved['recipe'];runner=ground_trial if r.get('kind','').startswith('supplied-ground') else full
   assert runner(g,o,states,r)==saved,(name,r)
   histories+=1;boundaries+=len(saved['samples'])+1
  print('MATCH',name,len(data['trials']),'histories',data['freshBoundaries'],'boundaries',flush=True)
 import held_component
 data=json.load(gzip.open(HERE/'held-component-probe.json.gz'))
 hg,ho,hs,hprep=held_component.root(capture);assert json.loads(json.dumps(hprep))==data['preparation']
 for saved in data['trials']:
  hg.load_state(hs[saved['phase']]);edits=held_component.relocate(hg,saved['edits'][0]['after']);assert edits==saved['edits']
  for pad,s in zip(saved['controls'],saved['samples']):advance(hg,pad);assert held_component.snap(hg,ho)==s
 print('MATCH held component: 7 five-update trials, plus native pickup/travel preparation',flush=True)
 print('PASS',histories,'full histories;',boundaries,'boundaries; held component separately matched',flush=True)

if __name__=='__main__':main()
