"""Preserve checked original-JP traces and source, excluding binaries and ROM."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('name',choices=['positive','no-buddy']);a=p.parse_args()
receipt=json.loads((a.directory/'receipt.json').read_text());assert receipt['semanticSelectedFieldsMatch']
out=HERE/'records'/a.name;out.mkdir(parents=True)
for name in ['raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','checker-source.py']:
 source=(a.directory/name).read_bytes();(out/(name+'.gz')).write_bytes(gzip.compress(source,mtime=0))
(out/'archive-hashes.json').write_bytes((json.dumps({p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in out.iterdir()},indent=2)+'\n').encode())
print('Archived',a.name)
