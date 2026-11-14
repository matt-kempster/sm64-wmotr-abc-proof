"""Check archive/source/reference hashes and reconstruct both native receipts."""
import hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
v=json.loads((HERE/'verification.json').read_text())
for name,h in v['filesSha256'].items():assert sha(HERE/name)==h,name
assert sha(ROOT/'docs/notes/ink-shell-lower-boundary-rom.md')==v['noteSha256']
assert sha(HERE.parent/'ink-shell-lower-boundary/results.json.gz')==v['expectedSha256']
for name in v['records']:
 p=HERE/'records'/name;m=p/'archive-hashes.json';assert sha(m)==v['recordManifestSha256'][name]
 for filename,h in json.loads(m.read_text()).items():assert sha(p/filename)==h,filename
 subprocess.run([sys.executable,str(HERE/'check.py'),str(p),'--archived'],check=True)
print('PASS both native receipts, archived sources/logs, Wafel reference and note hash')
