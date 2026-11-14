"""Authenticate archived shell-bridge sources/logs, then reconstruct every receipt."""
import gzip,hashlib,json,subprocess,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
def sha(b):return hashlib.sha256(b).hexdigest()
v=json.loads((HERE/'verification.json').read_text())
for n,h in v['filesSha256'].items():assert sha((HERE/n).read_bytes())==h,n
assert sha((ROOT/'docs/notes/ink-cloned-shell-bridge-rom.md').read_bytes())==v['noteSha256']
for name in v['records']:
 p=HERE/'records'/name;m=json.loads((p/'manifest.json').read_text())
 assert sha((p/'manifest.json').read_bytes())==v['recordManifestSha256'][name]
 for filename,hashes in m['files'].items():
  raw=(p/(filename+'.gz')).read_bytes();assert sha(raw)==hashes['compressedSha256']
  expanded=gzip.decompress(raw);assert sha(expanded)==hashes['uncompressedSha256']and len(expanded)==hashes['uncompressedBytes']
 subprocess.run([sys.executable,str(HERE/'check.py'),str(p),'--archived'],check=True)
print('PASS all three native receipts, raw logs, source hashes, exact Wafel expectations and note hash')
