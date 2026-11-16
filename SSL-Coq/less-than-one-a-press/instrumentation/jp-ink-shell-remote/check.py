"""Compose the strict handoff comparator with direct native shell-throw checks."""
import argparse,gzip,hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
path=HERE.parent/'jp-ink-mario-pusher-release/check.py'
spec=importlib.util.spec_from_file_location('remote_handoff_compare',path);c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
c.main()
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--archived',action='store_true');a=p.parse_args();d=a.directory
case=json.loads(c.data(d/'case.json'));base=json.loads(c.data(d/'receipt.json'));raw=c.data(d/'raw.log').decode(errors='replace')
shells=[c.fields(s)for s in raw.splitlines()if s.startswith('SF_SHELL,')]
released=[s for s in shells if int(s['step'])>=26 and int(s['bridge'])<=0]
assert released
target=list(map(c.bits,case['shellTarget']))
assert all(list(map(c.bits,c.xyz(s['pos'])))==target for s in released)
assert all(int(s['type'])==524288 and int(s['intangible'])==0 and float(s['radius'])==float(s['height'])==50 for s in released)
assert all(s['command']=='800eb778'for s in released),released[:2]
writes=base['stateWrites'];holp=[s for s in writes if s['field']=='highHOLP'];assert len(holp)==3
assert [int(s['after'],16)for s in holp]==list(map(c.bits,case['shellPreparationHOLP']))
assert all(s['step']=='25'for s in holp)
shell_addresses={0x8033c118+71*0x260+x for x in [0xa0,0xa4,0xa8]}
assert not any(int(s['step'])>=25 and int(s['address'],16)in shell_addresses for s in writes)
assert not any(e['path'].startswith('gObjectPool[71]')for e in case['initialEdits'])
out=dict(schema=1,scope='Native remote throw after conditional fake pickup; HOLP, Mario approach and pushers supplied',shellPreparationHOLP=case['shellPreparationHOLP'],shellTarget=case['shellTarget'],stationaryReleasedObservations=len(released),shellRows=shells,noPostThrowShellXYZWrites=True,baseReceiptSha256=hashlib.sha256(c.data(d/'receipt.json')).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),comparatorSha256=hashlib.sha256(path.read_bytes()).hexdigest())
if a.archived:assert json.loads(c.data(d/'remote-receipt.json'))==out
else:(d/'remote-receipt.json').write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS native remote throw,',len(released),'fixed-position/tangible-shell observations, no later shell XYZ writes')
