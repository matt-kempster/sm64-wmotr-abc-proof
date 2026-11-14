"""Preserve original-JP read-only hook evidence, excluding ROM and binaries."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('name',choices=['positive','retime']);a=ap.parse_args()
r=json.loads((a.directory/'receipt.json').read_text());assert r['selectedFieldsMatchExceptClock']
out=HERE/'records'/a.name;out.mkdir(parents=True,exist_ok=True)
for name in['raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh']:
 (out/(name+'.gz')).write_bytes(gzip.compress((a.directory/name).read_bytes(),mtime=0))
(out/'checker-source.py.gz').write_bytes(gzip.compress((HERE/'check.py').read_bytes(),mtime=0))
(out/'archive-hashes.json').write_bytes((json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(out.iterdir())if p.name!='archive-hashes.json'},indent=2)+'\n').encode())
print('Archived',a.name)
