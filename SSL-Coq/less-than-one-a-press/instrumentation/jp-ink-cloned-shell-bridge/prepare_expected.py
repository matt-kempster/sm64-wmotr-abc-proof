"""Select Wafel controls and independently replay the exact no-pusher same-Z control."""
import argparse,gzip,hashlib,importlib.util,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 path=ROOT/'instrumentation/ink-cloned-shell-bridge/results.json.gz';r=json.loads(gzip.decompress(path.read_bytes()))
 assert r['independentlyVerified']
 p=next(t for t in r['trials']if t['recipe']==dict(family='relocated-rider-control',height=25000,shellMode='clone',pusher='bobomb',z=[0],pushAt=0))
 n=next(t for t in r['trials']if t['recipe']==dict(height=25000,shellMode='clone',pusher='bobomb',z=[1]))
 script=ROOT/'instrumentation/ink-cloned-shell-bridge/search.py';spec=importlib.util.spec_from_file_location('shell_bridge',script);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
 g,o,states,slot,prep=m.roots();z=m.trial(g,o,states,dict(height=25000,shellMode='clone',pusher=None,z=[0],phase=130))
 q,qo,qs,qslot,qp=m.roots();assert prep==qp and z==m.trial(q,qo,qs,z['recipe'])
 assert not z['capture']and not z['useful']and z['samples'][-1]['area']==2 and z['samples'][-1]['M']==[0,5500,256]
 data=dict(schema=1,scope=__doc__,height=25000,preparation=prep,trials={'1':p,'2':n,'3':z},sourceSha256=sha(path),searchSha256=sha(script),dependencySha256=sha(ROOT/'instrumentation/ink-shell-clone-isolation/test.py'),sameZIndependentlyVerified=True)
 data=json.loads(json.dumps(data));target=HERE/'expected.json.gz'
 if a.verify:assert json.loads(gzip.decompress(target.read_bytes()))==data
 else:assert not target.exists();target.write_bytes(gzip.compress((json.dumps(data,separators=(',',':'))+'\n').encode(),mtime=0))
 print('PASS expected positive, delayed-Z negative, and exact no-pusher same-Z control')
if __name__=='__main__':main()
