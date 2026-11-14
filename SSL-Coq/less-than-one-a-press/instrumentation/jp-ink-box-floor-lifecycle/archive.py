"""Archive original-JP clone/floor text evidence without ROM, plugin or media."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
source=Path(sys.argv[1]);dest=HERE/'records'/'native-clone-stopped-old-floor';dest.mkdir(parents=True,exist_ok=False)
for name in ['trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','checker-source.py']:(dest/name).write_bytes((source/name).read_bytes())
(dest/'raw.log.gz').write_bytes(gzip.compress((source/'raw.log').read_bytes(),mtime=0))
d=dict(sourceDirectory=str(source),romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',files={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(dest.iterdir())if p.is_file()},scope='Conditional native fakepickup after usedObj cut, supplied time stop/high HOLP. Native throw moves actor high while 12 old low triangles remain; resume clears them. No reachable clone route.')
(dest/'manifest.json').write_bytes((json.dumps(d,indent=2)+'\n').encode());print('Archived',dest)
