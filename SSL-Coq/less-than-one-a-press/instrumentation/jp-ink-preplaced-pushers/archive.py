"""Archive exact recipe, compiled sources and native logs; never ROM/binaries."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
ap=argparse.ArgumentParser();ap.add_argument('directory',type=Path);ap.add_argument('name');a=ap.parse_args()
out=HERE/'records'/a.name;out.mkdir(parents=True,exist_ok=False)
for name in ['case.json','raw.log','trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh']:
 (out/(name+'.gz')).write_bytes(gzip.compress((a.directory/name).read_bytes(),mtime=0))
(out/'checker-source.py.gz').write_bytes(gzip.compress((HERE/'check.py').read_bytes(),mtime=0))
hashes={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(out.iterdir())}
(out/'archive-hashes.json').write_bytes((json.dumps(hashes,indent=2)+'\n').encode())
