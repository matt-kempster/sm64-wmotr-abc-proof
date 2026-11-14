"""Preserve text evidence and source snapshots; no ROM, plugin binary or media."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
source=Path(sys.argv[1]);name=sys.argv[2]
assert name in ['small-25000','bobomb-67277']
dest=HERE/'records'/name;dest.mkdir(parents=True,exist_ok=False)
names=['trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','checker-source.py']
for n in names:(dest/n).write_bytes((source/n).read_bytes())
(dest/'raw.log.gz').write_bytes(gzip.compress((source/'raw.log').read_bytes(),mtime=0))
manifest=dict(sourceDirectory=str(source),romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',files={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(dest.iterdir())if p.is_file()},scope='Original-JP conditional high rider compatibility; explicit low air and high relocation cuts remain.')
(dest/'manifest.json').write_bytes((json.dumps(manifest,indent=2)+'\n').encode())
print('Archived',dest)
