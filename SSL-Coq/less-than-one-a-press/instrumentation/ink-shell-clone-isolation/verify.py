"""Verify preserved bytes; pass --rerun to repeat both independent Wafel roots."""
import gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
v=json.loads((HERE/'verification.json').read_text())
for n,h in v['filesSha256'].items():assert hashlib.sha256((HERE/n).read_bytes()).hexdigest()==h,n
assert hashlib.sha256((ROOT/'docs/notes/ink-shell-clone-isolation.md').read_bytes()).hexdigest()==v['noteSha256']
r=json.loads(gzip.decompress((HERE/'results.json.gz').read_bytes()))
assert r['independentlyVerified']and r['boundaries']==228
if '--rerun'in sys.argv:subprocess.run([sys.executable,str(HERE/'test.py'),'--verify',str(HERE/'results.json.gz')],check=True)
print('PASS preserved package/note hashes; 228 independently verified boundaries recorded')
