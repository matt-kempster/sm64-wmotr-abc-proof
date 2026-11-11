"""Read-only verification of the bounded box delivery/crawl/release studies.

No Wafel import, gameplay, save-state load or experiment replay occurs here.
The named raw reports must already exist. Only the explicit
--write-release-receipt option writes a deterministic compact release receipt;
the default verifies existing receipts. Paths resolve from this script.
"""
import argparse
import ast
import hashlib
import json
import math
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
P = ROOT / 'instrumentation/wafel-jp-pilot'
B = ROOT / 'build/wafel-pilot'
N = ROOT / 'docs/notes'


def sha(path):
    path = Path(path)
    return hashlib.sha256((path if path.is_absolute() else ROOT/path).read_bytes()).hexdigest()


def read(path):
    return json.loads(path.read_text(encoding='utf-8'))


def provenance(report, script):
    ast.parse((P/script).read_text(encoding='utf-8'))
    assert report['scriptSha256'] == sha(P/script), script
    assert report['runtimeSha256'] == sha(B/'sm64_jp.dll')
    assert report['baselineSha256'] == sha(B/'capture.bKv95w/inputs.jsonl')


def paths(edits):
    return {e['path'] for e in edits}


MARIO_XYZ = {'gMarioState.pos', 'gMarioObject.header.gfx.pos'} | {'gMarioObject.oPos'+a for a in 'XYZ'}
BOX_XYZ = {'gObjectPool[49].oPos'+a for a in 'XYZ'}


def no_a_records(data, counts):
    if isinstance(data, dict):
        if isinstance(data.get('buttons'), int):
            assert not data['buttons'] & 0x8000
            counts['retainedButtonRecords'] += 1
        if isinstance(data.get('input'), int):
            assert not data['input'] & 0x82
            counts['retainedMarioInputRecords'] += 1
        for value in data.values():
            no_a_records(value, counts)
    elif isinstance(data, list):
        for value in data:
            no_a_records(value, counts)


def verify_delivery():
    receipt = read(N/'ink-box-delivery-receipt.json')
    raw_path = Path(receipt['rawPath'])
    raw = read(ROOT/raw_path)
    provenance(raw, 'ink_box_delivery.py')
    assert receipt['rawSha256'] == sha(raw_path)
    for source, expected in raw['sourceSha256'].items():
        assert sha(ROOT/'../../../reference-sm64-decomp'/source) == expected, source
    # Execute only these pure formatting functions, not the module/imports/run.
    tree = ast.parse((P/'ink_box_delivery.py').read_text(encoding='utf-8'))
    pure = ast.Module(body=[n for n in tree.body if isinstance(n, ast.FunctionDef)
                           and n.name in ('summarize', 'compact')], type_ignores=[])
    namespace = dict(sha=sha, hashlib=hashlib, math=math, json=json, CRAWLING=0x04008448, BOUNCE=0x8AE)
    exec(compile(pure, '<delivery pure receipt projection>', 'exec'), namespace)
    assert namespace['compact'](raw, raw_path) == receipt
    assert raw['gameplaySetupWrites'] == []
    assert len(raw['trials']) == 110
    assert sum(len(t['inputs']) for t in raw['trials']) == 34590
    assert [s['trials'] for s in receipt['screens']] == [60, 50]
    assert [s['updates'] for s in receipt['screens']] == [13800, 20790]
    assert [s['pickupTrials'] for s in receipt['screens']] == [57, 50]
    assert [s['freeReleaseTrials'] for s in receipt['screens']] == [12, 1]
    assert all(s['crawlSamples'] == s['handsFreeSamples'] == 0 for s in receipt['screens'])
    for witness in raw['selected']:
        trial = next(t for t in raw['trials'] if t['policy'] == witness['policy'])
        assert witness['inputs'] == trial['inputs']
        assert witness['freshReplayMatchingSnapshots'] == len(trial['samples']) == 431
        assert all(r in trial['samples'] for r in witness['milestoneCheckpoints'])
    assert len(raw['selected']) == 2
    assert len(raw['heldBounceButtonControls']) == 4
    assert all(t['updates'] == 23 and t['matchesZeroButtonMarioAndActors'] for t in raw['heldBounceButtonControls'])
    assert all(t['endpoint'] == raw['heldBounceButtonControls'][0]['endpoint'] for t in raw['heldBounceButtonControls'])
    return raw, dict(trials=110, screenUpdates=34590, freshReplaySnapshots=862, buttonControlUpdates=92)


def verify_crawl():
    receipt = read(N/'ink-box-crawl-predecessors-receipt.json')
    raw = read(ROOT/receipt['rawReportName'])
    provenance(raw, 'ink_box_crawl_predecessors.py')
    assert sha(receipt['rawReportName']) == receipt['rawReportSha256']
    for key in raw.keys() - {'trials', 'witnesses'}:
        assert receipt[key] == raw[key], key
    trials = raw['trials']
    assert len(trials) == len(receipt['trials']) == 168
    for actual, projected in zip(trials, receipt['trials']):
        assert projected == {k:v for k,v in actual.items() if k != 'transitions'}
        assert paths(actual['initialEdits']) == MARIO_XYZ | BOX_XYZ
    summary = dict(trials=len(trials), updates=sum(t['updates'] for t in trials),
        pickups=sum(t['pickupAfterUpdates'] is not None for t in trials),
        bounceTrials=sum(t['seenBounce'] for t in trials),
        crawlTrials=sum(t['maxCrawlY'] is not None for t in trials),
        highCrawlTrials=sum(t['highCrawl'] for t in trials),
        area2Arrivals=sum(t['final']['area']==2 for t in trials),
        maxArea1Y=max(t['maxY'] for t in trials),
        maxBefore130Y=max(t['maxBefore130Y'] for t in trials if t['maxBefore130Y'] is not None),
        maxCrawlY=max(t['maxCrawlY'] for t in trials if t['maxCrawlY'] is not None))
    assert summary == raw['summary'] == receipt['summary']
    assert (summary['updates'],summary['pickups'],summary['crawlTrials'],summary['highCrawlTrials']) == (29677,156,1,0)
    assert len(raw['witnesses']) == len(receipt['witnesses']) == 4
    for witness, short in zip(raw['witnesses'], receipt['witnesses']):
        for key, value in short.items():
            if key == 'selectedSamples':
                assert value and all(sample in witness['samples'] for sample in value)
            elif key == 'allSnapshotCount':
                assert value == len(witness['samples'])
            else:
                assert value == witness[key], key
        check = witness['freshBootValidation']
        assert check['passed'] and check['intermediateEdits'] == 0
        assert check['comparedSnapshots'] == check['continuousUpdates'] == len(witness['samples']) == len(witness['controls']) == 180
        assert paths(check['initialEdits']) == MARIO_XYZ | BOX_XYZ
        assert check['initialEdits'] == witness['summary']['initialEdits']
        assert witness['peak']['area'] == 1 and witness['peakBefore130']['timer'] <= raw['handoffGlobalTimer']
    assert receipt['replayChecks'] == dict(selectedWitnesses=4, allPassed=True, totalComparedSnapshots=720)
    return raw, summary


def verify_handsfree():
    receipt=read(N/'ink-box-handsfree-receipt.json')
    raw=read(ROOT/receipt['rawReportName'])
    provenance(raw,'ink_box_handsfree.py')
    assert sha(receipt['rawReportName'])==receipt['rawReportSha256']
    assert raw['snapshotHelperSha256']==sha(P/'ink_box_crawl_predecessors.py')
    for key in raw.keys()-{'trials','focusedDive'}:
        assert receipt[key]==raw[key], key
    trials=raw['trials']
    assert len(trials)==len(receipt['trials'])==288
    for trial,short in zip(trials,receipt['trials']):
        assert short=={k:v for k,v in trial.items() if k!='events'}
        assert paths(trial['initialEdits'])==MARIO_XYZ|BOX_XYZ
    summary=dict(trials=len(trials),updates=sum(t['updates'] for t in trials),
        diveTrials=sum(t['hasDive'] for t in trials),
        pickupTrials=sum(t['firstHeldAfterUpdates'] is not None for t in trials),
        divePickingUpTrials=sum(t['divePickingUpExecutionUpdates']>0 for t in trials),
        handsfreeExitTrials=sum(t['firstHandsfreeExit'] is not None for t in trials),
        crawlAfterPickupTrials=sum(t['firstHeldAfterUpdates'] is not None and t['maxCrawlY'] is not None for t in trials),
        highCrawlTrials=sum(t['maxCrawlY'] is not None and t['maxCrawlY']>=1741 for t in trials))
    assert summary==raw['summary']
    assert (summary['updates'],summary['diveTrials'],summary['pickupTrials'])==(42966,32,0)
    focused=raw['focusedDive']; short_focused=receipt['focusedDive']
    for key in focused.keys()-{'trials'}:
        assert focused[key]==short_focused[key]
    runup=focused['runup']
    assert runup['nonControllerEdits']==[]
    assert len(runup['controls'])==len(runup['samples'])==6
    assert runup['samples'][-1]['action']==0x0188088A and runup['samples'][-1]['held']==-1
    assert len(focused['trials'])==len(short_focused['trials'])==18
    for trial,short in zip(focused['trials'],short_focused['trials']):
        full_samples=trial['height'] in (1400,1741) and trial['boxDistance']==70 and trial['boxYOffset']==0
        expected={k:v for k,v in trial.items() if full_samples or k!='samples'}
        assert short==expected
        assert paths(trial['initialEdits'])==MARIO_XYZ|BOX_XYZ
        assert len(trial['controls'])==len(trial['samples'])==140
        entry=trial['firstHandsfreeExit']
        assert 'ACT_DIVE_PICKING_UP' in entry['actionEntries']
        assert entry['sample']==trial['samples'][entry['update']-1]
        assert entry['sample']['held']==49 and entry['sample']['action']==0x00840452
        assert trial['heldUpdates']==sum(r['held']==49 for r in trial['samples'])
        assert trial['crawlUpdates']==sum(r['action']==0x04008448 for r in trial['samples'])==0
        assert all(r['action']!=0x8AE for r in trial['samples'])
        assert all('ACT_CRAZY_BOX_BOUNCE' not in event['actionEntries'] for event in trial['events'])
    focused_summary=dict(trials=18,postCutUpdates=sum(len(t['controls']) for t in focused['trials']),
        handsfreeExits=sum(t['firstHandsfreeExit'] is not None for t in focused['trials']),
        crawlUpdates=sum(t['crawlUpdates'] for t in focused['trials']),
        crazyBoxBounceUpdates=sum(r['action']==0x8AE for t in focused['trials'] for r in t['samples']),
        minimumHeldUpdates=min(t['heldUpdates'] for t in focused['trials']),
        maximumHeldUpdates=max(t['heldUpdates'] for t in focused['trials']))
    assert focused_summary==focused['summary']
    assert focused_summary==dict(trials=18,postCutUpdates=2520,handsfreeExits=18,crawlUpdates=0,
                                crazyBoxBounceUpdates=0,minimumHeldUpdates=70,maximumHeldUpdates=79)
    validations=focused['freshBootValidations']
    assert len(validations)==2
    for check in validations:
        assert check['passed'] and check['postCutNonControllerEdits']==0
        assert (check['preCutControllerUpdates'],check['postCutControllerUpdates'],check['comparedSnapshots'])==(6,140,146)
        trial=next(t for t in focused['trials'] if all(t[k]==check[k] for k in ('height','boxDistance','boxYOffset')))
        assert check['setupEdits']==trial['initialEdits']
    extras=[]; extra_summary=[]
    for control in receipt['exploratoryControls']:
        assert sha(control['rawReportName'])==control['rawReportSha256']
        extra=read(ROOT/control['rawReportName']); extras.append(extra)
        et=extra if isinstance(extra,list) else extra['trials']
        assert len(et)==control['trials']
        assert control['initialEdits']==[t['edits'] for t in et]
        assert control['runup']==(None if isinstance(extra,list) else extra['runup'])
        assert all(paths(t['edits'])==MARIO_XYZ|BOX_XYZ for t in et)
        assert all(sample['held']!=49 for t in et for sample in t['samples'])
        extra_summary.append(dict(trials=len(et),updates=sum(len(t['controls']) for t in et),pickups=0))
    assert [s['trials'] for s in extra_summary]==[24,18]
    return [raw]+extras,dict(unexercisedRunway=summary,focusedException=focused_summary,
                            freshReplaySnapshots=292,otherUnexercisedControls=extra_summary)


RELEASE_RAW = 'build/wafel-pilot/ink-box-release-handoff-final-20261111.json'
RELEASE_REPLAY = 'build/wafel-pilot/ink-box-release-handoff-final-replay-20261111.json'
RELEASE_COLUMNS = ['context', 'phase', 'kind', 'initialXYZ', 'actorAt130ActiveFlags',
    'actorAt130IsJumpingBox', 'actorAt130XYZ', 'actorAt130FarAwayFlag',
    'marioCollisionHeightBefore130', 'verticalSplit', 'topCapture', 'outsideElevator', 'arrivalXYZ']


def release_projection(raw):
    rows = []
    selected = []
    for trial in raw['trials']:
        a = trial['actorAt130']
        rows.append([trial['context'], trial['phase'], trial['kind'], trial['initialXYZ'],
            a['activeFlags'], a['isJumpingBox'], [a['oPos'+axis] for axis in 'XYZ'],
            bool(a['activeFlags'] & 2), trial['marioCollisionHeightBefore130'],
            trial['verticalSplit'], trial['topCapture'], trial['outsideElevator'],
            None if trial['arrival'] is None else trial['arrival']['movement']])
        if (trial['topCapture'] or
            (trial['context']=='near-spectator' and trial['kind']=='dropped' and
             ((trial['initialXYZ'][1]==1741 and trial['phase'] in (128,129,130)) or
              (trial['initialXYZ'][1]==1650 and trial['phase']==118)))):
            selected.append(trial)
    return {**{k:v for k,v in raw.items() if k != 'trials'},
            'rawReportName':RELEASE_RAW, 'rawReportSha256':sha(RELEASE_RAW),
            'replayReportName':RELEASE_REPLAY, 'replayReportSha256':sha(RELEASE_REPLAY),
            'fullReportsByteIdentical':True,
            'observationLimits':'Supplied actor-release cut, supplied crawl preparation at129 and supplied high Mario pose at130; no joined gameplay route. Replay equality checks the two complete serialized reports, not every hidden native state field.',
            'trialColumns':RELEASE_COLUMNS, 'trialRows':rows,
            'selectedTrials':selected}


def verify_release(write_receipt):
    raw_path = ROOT/RELEASE_RAW
    replay_path = ROOT/RELEASE_REPLAY
    assert raw_path.read_bytes() == replay_path.read_bytes()
    raw = read(raw_path)
    assert raw == read(replay_path)
    provenance(raw, 'ink_box_release_handoff.py')
    trials = raw['trials']
    assert len(trials) == 674
    actor_paths = BOX_XYZ | {'gObjectPool[49].'+f for f in
                           ('oHeldState','oAction','oIntangibleTimer','oMoveAngleYaw')}
    for t in trials:
        assert paths(t['actorEdits']) == actor_paths
        assert paths(t['marioCutEdits']) == MARIO_XYZ
        assert paths(t['spectatorEdits']) <= MARIO_XYZ
        assert paths(t['marioPreparation']) <= MARIO_XYZ | {'gMarioState.action'}
        assert any(e['path']=='gMarioState.action' and e['after']==0x04008448 for e in t['marioPreparation'])
        assert t['marioCollisionHeightBefore130'] == 100
        assert len(t['actorSamples']) == 130-t['phase']
        if t['topCapture']:
            a=t['actorAt130']
            assert a['isJumpingBox'] and a['activeFlags'] and a['oIntangibleTimer']==0
            assert t['verticalSplit']==973 and t['outsideElevator']
    summary = dict(trials=len(trials), actorPredecessorUpdates=sum(130-t['phase'] for t in trials),
        aliveAt130=sum(bool(t['actorAt130']['activeFlags']) and t['actorAt130']['isJumpingBox'] for t in trials),
        topCaptures=sum(t['topCapture'] for t in trials), outsideArrivals=sum(t['outsideElevator'] for t in trials))
    assert summary == raw['summary']
    assert summary == dict(trials=674,actorPredecessorUpdates=4512,aliveAt130=471,topCaptures=20,outsideArrivals=20)
    assert sum(t['topCapture'] and t['kind']=='original-free-control' for t in trials)==2
    compact = release_projection(raw)
    assert len(compact['trialRows'])==674 and len(compact['selectedTrials'])==24
    target = N/'ink-box-release-handoff-receipt.json'
    if write_receipt:
        target.write_text(json.dumps(compact,indent=2,allow_nan=False)+'\n',encoding='utf-8')
    assert read(target) == compact
    return raw, {**summary, 'releasePredecessorSuccesses':18, 'originalFreeControlSuccesses':2,
                 'selectedFullTrials':24, 'fullReportsByteIdentical':True}


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write-release-receipt',action='store_true')
    args=parser.parse_args()
    delivery, delivery_result=verify_delivery()
    crawl, crawl_result=verify_crawl()
    release, release_result=verify_release(args.write_release_receipt)
    handsfree, handsfree_result=verify_handsfree()
    counts=dict(retainedButtonRecords=0,retainedMarioInputRecords=0)
    for raw in [delivery,crawl,release]+handsfree:
        no_a_records(raw,counts)
    prefix=(B/'capture.bKv95w/inputs.jsonl').read_text(encoding='utf-8').splitlines()
    prefix=[json.loads(line) for line in prefix if line.strip()]
    assert len(prefix)==2852 and all(not row['buttons']&0x8000 for row in prefix)
    print(json.dumps(dict(passed=True, gameplayRerun=False,
        releaseReceiptWritten=args.write_release_receipt, delivery=delivery_result,
        conditionalCrawl=crawl_result, conditionalRelease=release_result,
        conditionalHandsfree=handsfree_result,
        noAChecks={**counts,'acceptedCaptureRows':len(prefix)},
        limits='Counts cover retained records; fresh replay assertions are checked as recorded evidence. No new gameplay or Coq proof is performed.'),indent=2))


if __name__=='__main__':
    main()
