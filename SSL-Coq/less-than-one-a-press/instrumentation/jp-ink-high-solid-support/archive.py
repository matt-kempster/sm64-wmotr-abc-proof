"""Preserve original-JP text evidence and source snapshots, never ROM/plugin/media."""
import gzip,hashlib,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
source=Path(sys.argv[1]);dest=HERE/'records'/'large-box-shell-25000';dest.mkdir(parents=True,exist_ok=False)
for name in ['trace.txt','receipt.json','probe-source.c','prefix-source.c','run-source.sh','checker-source.py']:(dest/name).write_bytes((source/name).read_bytes())
(dest/'raw.log.gz').write_bytes(gzip.compress((source/'raw.log').read_bytes(),mtime=0))
d=dict(sourceDirectory=str(source),romSha256='9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317',files={p.name:hashlib.sha256(p.read_bytes()).hexdigest()for p in sorted(dest.iterdir())if p.is_file()},scope='Original-JP high supplied-air/live-solid native landing and shell fallback; no supplied ground action or later Mario edits; placement/delivery remain supplied.')
(dest/'manifest.json').write_bytes((json.dumps(d,indent=2)+'\n').encode());print('Archived',dest)
