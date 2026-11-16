"""Hash the immutable joined-release records and directly inherited sources."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
OWN=['check.py','README.md','archive.py','results.json.gz','positive.json','no-box.json','no-entry.json','.gitattributes']
DEPENDENCIES=['instrumentation/ink-shell-remote-functionality/handoff.py',
 'instrumentation/ink-mario-pusher-delivery/controlled-bob/joint.py',
 'instrumentation/ink-mario-pusher-delivery/controlled-bob/test.py',
 'instrumentation/ink-mario-pusher-delivery/controlled-box/check.py',
 'instrumentation/ink-shell-clone-isolation/test.py',
 'instrumentation/ink-bobomb-retimed-shoves/search.py',
 'instrumentation/ink-enlarged-bob-handoff/search.py',
 'instrumentation/ink-enlarged-bob-profile/profile.py']
def main():
 p=argparse.ArgumentParser();p.add_argument('--verify',action='store_true');a=p.parse_args()
 files=[HERE/x for x in OWN]+[ROOT/x for x in DEPENDENCIES]
 data=dict(schema=1,scope='Artifact hashes, not a gameplay or proof theorem',
  sha256={str(x.relative_to(ROOT)).replace('\\','/'):hashlib.sha256(x.read_bytes()).hexdigest()for x in files})
 out=HERE/'verification.json'
 if a.verify:assert json.loads(out.read_bytes())==data
 else:assert not out.exists();out.write_bytes((json.dumps(data,indent=2)+'\n').encode())
 print('PASS',len(files),'artifact/source hashes')
if __name__=='__main__':main()
