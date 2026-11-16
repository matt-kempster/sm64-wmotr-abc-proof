"""Preserve native remote-shell evidence without ROM or runtime binaries."""
import argparse,gzip,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('name');a=p.parse_args()
d=HERE/'records'/a.name;d.mkdir(parents=True,exist_ok=False)
for n in ['case.json','raw.log','trace.txt','receipt.json','remote-receipt.json','probe-source.c','prefix-source.c','run-source.sh']:
 (d/(n+'.gz')).write_bytes(gzip.compress((a.directory/n).read_bytes(),mtime=0))
for path,name in [(HERE/'check.py','checker-source.py'),(HERE.parent/'jp-ink-mario-pusher-release/check.py','comparator-source.py')]:
 (d/(name+'.gz')).write_bytes(gzip.compress(path.read_bytes(),mtime=0))
files={x.name:hashlib.sha256(x.read_bytes()).hexdigest()for x in sorted(d.iterdir())}
(d/'archive-hashes.json').write_bytes((json.dumps(files,indent=2)+'\n').encode())
