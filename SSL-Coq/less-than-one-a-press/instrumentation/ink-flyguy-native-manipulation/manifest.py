"""Record exact local research artifact hashes; contains no game/runtime binary."""
import hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def main():
 files={str(p.relative_to(HERE)).replace('\\','/'):sha(p)for p in sorted(HERE.rglob('*'))if p.is_file()and '__pycache__'not in p.parts and p.name!='manifest.json'}
 note=ROOT/'docs/notes/ink-flyguy-native-manipulation-runtime.md'
 result=dict(proofRevision='4813e95d33286a30882caf0759dd838c95ee48f2',date='2026-11-14',
  runtime=dict(version='Wafel 0.8.5 JP',python=sys.version,dllSha256=sha(ROOT/'build/wafel-pilot/sm64_jp.dll')),
  evidence='Primary controller-only histories plus explicitly separate single-small-box XYZ cuts; finite coverage',
  noteSha256=sha(note),filesSha256=files,
  helperSha256={str(p.relative_to(ROOT)).replace('\\','/'):sha(p)for p in [ROOT/'instrumentation/wafel-jp-pilot/replay.py',ROOT/'instrumentation/wafel-jp-pilot/ink_crawl_predecessors.py']},
  verification=json.loads((HERE/'verification.json').read_text()))
 (HERE/'manifest.json').write_bytes((json.dumps(result,indent=2)+'\n').encode())
 print('manifest',len(files),'files; verification',result['verification']['passed'])
if __name__=='__main__':main()
