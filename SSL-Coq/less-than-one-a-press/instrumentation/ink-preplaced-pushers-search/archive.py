"""Hash the independent preplacement result and direct reconstruction inputs."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def record(p):return dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--verify',action='store_true');a=ap.parse_args()
 local=['.gitattributes','check.py','waiting.py','archive.py','README.md','positive-case.json','results.json.gz','waiting-results.json.gz']
 inputs=['instrumentation/ink-enlarged-bob-handoff/search.py','instrumentation/ink-enlarged-bob-handoff/positive-case.json','instrumentation/ink-bobomb-retimed-shoves/search.py','instrumentation/ink-enlarged-bob-profile/profile.py','instrumentation/ink-shell-clone-isolation/test.py','instrumentation/ink-preplaced-pushers-controls/results.json.gz']
 out=dict(schema=1,scope='Exact pre128 placement plus finite leads0/1/2, each independently reconstructed twice; no placement grid. Archive verification is separate from runtime replay.',files=[record(HERE/n)for n in local],directInputs=[record(ROOT/n)for n in inputs])
 data=(json.dumps(out,indent=2)+'\n').encode();path=HERE/'verification.json'
 if a.verify:assert path.read_bytes()==data
 else:path.write_bytes(data)
 print('PASS archive',len(local),'local files,',len(inputs),'direct input hashes')
if __name__=='__main__':main()
