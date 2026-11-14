"""Bind all delivery/release/low-entry artifacts without claiming reachability."""
import argparse,hashlib,json
from pathlib import Path
HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');a=p.parse_args()
files={x.relative_to(HERE).as_posix():hashlib.sha256(x.read_bytes()).hexdigest()for x in sorted(HERE.rglob('*'))if x.is_file()and '__pycache__'not in x.parts and x!=HERE/'verification.json'}
out=dict(schema=1,scope='Controller-only delivery failures and separately granted native-release/low-entry positives; no joined route',files=files)
target=HERE/'verification.json'
if a.check:assert json.loads(target.read_bytes())==out
else:target.write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS',len(files),'delivery/release/entry artifact hashes')
