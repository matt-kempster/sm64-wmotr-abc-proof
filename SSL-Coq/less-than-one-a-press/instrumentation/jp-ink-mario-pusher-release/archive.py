"""Preserve exact local ROM-run recipes, probes and traces; no ROM/binaries."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('name');a=p.parse_args()
out=HERE/'records'/a.name;out.mkdir(parents=True,exist_ok=False)
for name in ['case.json','raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh']:
 (out/(name+'.gz')).write_bytes(gzip.compress((a.directory/name).read_bytes(),mtime=0))
(out/'checker-source.py.gz').write_bytes(gzip.compress((HERE/'check.py').read_bytes(),mtime=0))
files={x.name:hashlib.sha256(x.read_bytes()).hexdigest()for x in sorted(out.iterdir())}
(out/'archive-hashes.json').write_bytes((json.dumps(files,indent=2)+'\n').encode())
