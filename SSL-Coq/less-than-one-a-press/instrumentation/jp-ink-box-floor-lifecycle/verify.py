"""Check frozen source/text hashes, then reconstruct the archived native receipt."""
import hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
v=json.loads((HERE/'verification.json').read_text())
for name,h in v['filesSha256'].items():assert sha(HERE/name)==h,name
assert sha(ROOT/'docs/notes/ink-box-floor-rom.md')==v['noteSha256']
record=HERE/'records/native-clone-stopped-old-floor'
manifest=json.loads((record/'manifest.json').read_text())
for name,h in manifest['files'].items():assert sha(record/name)==h,name
subprocess.run([sys.executable,str(HERE/'check.py'),str(record),'--archived'],check=True)
print('PASS package, note, archived-source and raw-log hashes; native receipt reconstructed')
