"""Audit saved slide experiments, replay selected projections, retain compact evidence.

No query hook, emulator/ROM equivalence or controller-reachability theorem is
claimed. Output includes every supplied recipe, all outcomes, and full traces for
selected positive and negative cases. Raw files are hashed and retained locally.
"""
import argparse,json,sys
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_slide_handoff as study
import ink_slide_handoff_entry as entry_study
from ink_pu_vpu import digest

def compact(t):
    fields=['timer','area','action','actionName','actionArg','actionState','actionTimer','movement','collision','display','velocity','forwardVelocity','slideVelocity','slideYaw','floorY','floorOwner','ceilingY','ceilingPresent','platform','topTimer','topAction','topActive','topSurfaceCount','used','held','warpOp','countdown','collisionSlots']
    project=lambda row:{k:row[k] for k in fields if k in row}
    return dict(recipe=t['recipe'],edits=t['edits'],initial=project(t['initial']),first=project(t['samples'][0]),next=project(t['samples'][1]),last=project(t['samples'][-1]),
                firstGap=t['firstGap'],topCapture=t['topCapture'],usefulArrival=t['usefulArrival'],frames=len(t['samples']))

def run(raw_path,entry_path,capture):
    r=json.loads(raw_path.read_text());e=json.loads(entry_path.read_text())
    assert r['scriptSha256']==digest(study.__file__) and e['scriptSha256']==digest(entry_study.__file__)
    assert r['baselineSha256']==e['baselineSha256']==digest(capture)=='9bcc451964025d9f0bb1344c45957b6bfd095451b44bfb9a01f8584a75db6a72'
    assert r['runtimeSha256']==digest(study.ROOT/'build/wafel-pilot/sm64_jp.dll')=='960fe979068b78e6733b3ddb87741833fbf4eb29b2a21a2bba871977427c2d0f'
    all_trials=r['trials']+r['alternateActorTrials']+r['boundaryTrials']
    assert len(r['trials'])==180 and len(r['alternateActorTrials'])==8 and len(r['boundaryTrials'])==489
    assert len(e['trials'])==14
    for t in e['trials']:
        if t['recipe']['name']=='freefall-z-shell':
            assert all(s['active'] and s['action']==0 and s['isShell'] and s['ridden']==-1 for s in t['shellSamples'][:-1])
            assert not t['topCapture'] and not t['usefulArrival']
    for t in all_trials+e['trials']:
        assert len(t['samples'])==len(t['controls'])==len(t['events'])
        for pad,row in zip(t['controls'],t['samples']):
            assert not pad['buttons']&0x8000 and not row['input']&0x82
        assert t['initial']['movement']==t['initial']['collision']==t['initial']['display']
        study.validate_positive(t)
    assert r['entry']['counts']==dict(groundSlideFrames=4356,deepGroundSlideFrames=0,gapFrames=0)
    # Validate all six action-specific scans independently: every integer in
    # [1738,1806], then the explicitly listed large-height probes.
    for action in ['ACT_BUTT_SLIDE','ACT_STOMACH_SLIDE','ACT_CROUCH_SLIDE','ACT_HOLD_BUTT_SLIDE','ACT_HOLD_STOMACH_SLIDE','ACT_DIVE_SLIDE']:
        rows=[t for t in r['boundaryTrials'] if t['recipe']['action']==action and 'boundary' in t['recipe']['name']]
        good=[t['recipe']['height'] for t in rows if t['usefulArrival']]
        assert good==list(range(1741,1802))+[21778,21779,25000,32766,32767]
    selected=[]
    for t in all_trials:
        rec=t['recipe'];n=rec['name']
        keep=(n.endswith('-v20-neutral') or n.endswith('-v20-no-box') or n.endswith('-v5-neutral') or 'shell' in n or 'bobomb' in n or 'speed-v' in n)
        keep=keep or(rec['action'] in ['ACT_BUTT_SLIDE','ACT_DIVE_SLIDE'] and 'boundary' in n and rec['height'] in [1740,1741,1801,1802,21777,21778,32767,32768])
        if keep:selected.append(t)
    g,o,base,held,held_prep=study.roots(capture)
    sg,so,sbase,shell_prep=study.shell_root(capture)
    assert r['heldPreparation']==held_prep and r['shellPreparation']==shell_prep
    for t in selected:
        rec=t['recipe'];shell=rec.get('actorSlot')==shell_prep['slot']
        actual=study.trial(sg,so,sbase,sbase,rec) if shell else study.trial(g,o,base,held,rec)
        assert actual==t,rec['name']
    assert entry_study.run(capture)==e
    return dict(schema=1,scope=__doc__,rawReportSha256=digest(raw_path),entryRawSha256=digest(entry_path),
                sourceAndRuntime={k:v for k,v in r.items() if k not in ['trials','alternateActorTrials','boundaryTrials','entry']},
                verification=dict(scriptSha256=digest(__file__),freshReplayedMainTrials=len(selected),freshReplayedMainFrames=sum(len(t['samples']) for t in selected),freshReplayedEntryTrials=14,freshReplayedEntryFrames=sum(len(t['samples']) for t in e['trials'])),
                trials=[compact(t) for t in r['trials']],alternateActorTrials=r['alternateActorTrials'],boundaryTrials=[compact(t) for t in r['boundaryTrials']],
                selectedFullTraces=selected,entry=r['entry'],entryCuts=e)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('raw',type=Path);p.add_argument('entry',type=Path);p.add_argument('capture',type=Path);p.add_argument('receipt',type=Path);a=p.parse_args();r=run(a.raw,a.entry,a.capture)
    with a.receipt.open('x',encoding='utf-8') as f:json.dump(r,f,separators=(',',':'),allow_nan=False);f.write('\n')
    print(json.dumps(r['verification'],indent=2))
