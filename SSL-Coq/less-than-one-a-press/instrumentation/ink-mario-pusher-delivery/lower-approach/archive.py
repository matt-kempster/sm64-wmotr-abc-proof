"""Verify immutable local lower-approach inputs, scripts and saved results."""
import hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2]

def main():
 local=sorted(p for p in HERE.iterdir()if p.is_file()and p.name not in ['verification.json','.gitattributes'])
 deps=[ROOT/p for p in ['instrumentation/ink-preplaced-pushers-search/positive-case.json',
       'instrumentation/ink-enlarged-bob-handoff/search.py','instrumentation/ink-enlarged-bob-profile/profile.py',
       'instrumentation/ink-bobomb-retimed-shoves/search.py','instrumentation/ink-shell-clone-isolation/test.py']]
 entries=[dict(path=p.relative_to(ROOT).as_posix(),bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest())for p in local+deps]
 data=dict(schema=1,scope=__doc__,files=entries);out=HERE/'verification.json'
 if '--verify'in sys.argv:
  assert json.loads(out.read_bytes())==data
 else:
  assert not out.exists();out.write_text(json.dumps(data,indent=2)+'\n')
 print('PASS',len(entries),'archived source/result/input hashes')
if __name__=='__main__':main()
