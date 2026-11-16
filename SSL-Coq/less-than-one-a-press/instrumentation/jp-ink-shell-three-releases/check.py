"""Compose the strict handoff comparator with direct native shell-throw checks."""
import argparse,gzip,hashlib,importlib.util,json,sys
from pathlib import Path
HERE=Path(__file__).resolve().parent
path=HERE/'compare.py'
spec=importlib.util.spec_from_file_location('remote_handoff_compare',path);c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
c.main()
p=argparse.ArgumentParser();p.add_argument('directory',type=Path);p.add_argument('--archived',action='store_true');a=p.parse_args();d=a.directory
case=json.loads(c.data(d/'case.json'));base=json.loads(c.data(d/'receipt.json'));raw=c.data(d/'raw.log').decode(errors='replace')
setup=[c.fields(s)for s in raw.splitlines()if s.startswith('SC_AFTER_RELEASE_SETUP,')]
setup128=[s for s in setup if int(s['bridge'])==2]
assert len(setup128)==1 and c.slot(setup128[0]['held'])==39
assert int(setup128[0]['action'],16)==0x10008a1
status_writes=[e for cut in case['cuts']for e in cut['edits']if e['path']=='gMarioObject.oInteractStatus']
assert status_writes[-1]['after']==0  # no forced-drop bit at execution
mount=next(c.fields(s)for s in raw.splitlines()if s.startswith('SC_STATE,')and c.fields(s)['bridge']=='3')
assert c.slot(mount['held'])==-1 and c.slot(mount['ridden'])==-1
assert int(mount['shellStatus'])==0x400000  # actual native Z dismount
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
out=dict(schema=1,scope='Native remote shell throw, actual Box drop and shell-contact Bob drop; two carrying/approach cuts and HOLP remain supplied',shellPreparationHOLP=case['shellPreparationHOLP'],shellTarget=case['shellTarget'],stationaryReleasedObservations=len(released),shellRows=shells,noPostThrowShellXYZWrites=True,heldBobBefore128=setup128[0],nativeDismountAfter128=mount,forcedDropStatusAtExecution=False,baseReceiptSha256=hashlib.sha256(c.data(d/'receipt.json')).hexdigest(),checkerSha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),comparatorSha256=hashlib.sha256(path.read_bytes()).hexdigest())
if a.archived:assert json.loads(c.data(d/'remote-receipt.json'))==out
else:(d/'remote-receipt.json').write_bytes((json.dumps(out,indent=2)+'\n').encode())
print('PASS native remote throw,',len(released),'fixed-position/tangible-shell observations, no later shell XYZ writes')
