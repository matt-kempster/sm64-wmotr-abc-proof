"""Archive logs and scoped check results; no ROM, save state, or plugin binary."""
import argparse,gzip,json,hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('capture',type=Path);p.add_argument('case',choices=['timely','late']);a=p.parse_args()
d=HERE/a.case/'native-record';d.mkdir(exist_ok=True)
raw=(a.capture/'raw.log').read_bytes();check=(a.capture/'check.json').read_bytes();assert json.loads(check)['passed']
(d/'raw.log.gz').write_bytes(gzip.compress(raw,mtime=0));(d/'check.json').write_bytes(check)
files=[HERE/'probe.c',HERE/'prepare.py',HERE/'run.sh',HERE/'check.py',HERE/'archive.py']+list((HERE/a.case).glob('*.*'))+list(d.glob('*'))
(d/'archive-hashes.json').write_bytes((json.dumps({p.relative_to(HERE).as_posix():hashlib.sha256(p.read_bytes()).hexdigest()for p in files if p.is_file()and p.name!='archive-hashes.json'},indent=2)+'\n').encode())
print('Archived',a.case,len(raw),'raw bytes')
