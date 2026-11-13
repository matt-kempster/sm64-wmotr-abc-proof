"""Fresh controls: an early squish, top recapture, and residence until 130.

All cases start at a declared supplied EXTERIOR freefall pose. No further
Mario, actor, timer, floor or platform writes are permitted. The early
squish control also checks whether ordinary crawl can occur below the cap.
"""
import argparse
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_early_air_entry_crawl as test

SOURCE=test.ROOT/'build/wafel-pilot/ink-early-air-entry-exterior.json'


def advance(g,o,pad):
    r=test.checked_advance(g,o,pad)
    r['squishTimer']=g.read('gMarioState.squishTimer')
    return r


def record(recipe, first_pad, policy):
    g,o,edits=test.setup_fresh(recipe)
    constants={n:g.constant(n) for n in test.NAMES}
    initial=test.rich_state(g,o)
    assert not initial['native']['geometry']['inside']
    clearance=recipe['pos'][1]-test.exact_upper(initial['topMesh'],recipe['pos'])
    assert clearance>0
    rows=[advance(g,o,first_pad)]
    ground_age=0;stage='settle'
    while g.read('gObjectPool[61].oTimer')<130:
        ground_age=ground_age+1 if not g.read('gMarioState.action')&test.AIR else 0
        pad,stage=test.choose_pad(g,policy,len(rows)-1,ground_age,stage,constants)
        rows.append(advance(g,o,pad))
    return dict(recipe=recipe,suppliedEdits=edits,initial=initial,policy=policy,
                exactInitialFeetClearance=clearance,
                records=rows,outcome=test.outcome(rows,constants))


def verify(w):
    g,o,edits=test.setup_fresh(w['recipe'])
    assert edits==w['suppliedEdits']
    assert test.rich_state(g,o)==w['initial']
    rich=[]
    for expected in w['records']:
        before=test.rich_state(g,o)
        assert advance(g,o,expected['input'])==expected
        rich.append(dict(before=before,after=test.rich_state(g,o)))
    return dict(passed=True,comparedFrames=len(rich),meshes=rich)


def run(output):
    source=json.loads(SOURCE.read_text(encoding='utf-8'))
    entries=source['survey']['retained']
    rows=source['policies']['results']
    selected={}
    for name,predicate in [
        ('continuousInsideTo130',lambda r:r['outcome']['insideAt130'] and r['outcome']['firstExit'] is None),
        ('continuousDeepAt130',lambda r:r['outcome']['deepAt130'] and r['outcome']['firstExit'] is None)]:
        choices=[r for r in rows if predicate(r)]
        r=min(choices,key=lambda r:entries[r['entryIndex']]['recipe']['phase'])
        entry=entries[r['entryIndex']]
        selected[name]=record(entry['recipe'],entry['entry']['input'],r['policy'])
        assert selected[name]['outcome']==r['outcome']
    w=source['selected']['topLanding']
    selected['topRecapture']=record(w['entry']['recipe'],w['entry']['entry']['input'],w['policy'])
    g,o,states,meshes=test.contexts()
    for phase in [68,100,111]:
        for recipe in test.recipes(meshes[phase],phase,'air'):
            if recipe['pos'][1] <= test.exact_upper(meshes[phase],recipe['pos']):
                continue
            g.load_state(states[phase]);test.seed_pose(g,recipe)
            pad=test.controller(g,recipe['yaw'],0)
            r=advance(g,o,pad)
            if any(e['geometry'] and e['geometry']['deep'] for e in r['entries']):
                policy=dict(mode='settle-z',direction='inward',magnitude=32,delay=0,brakeGroundFrames=0)
                selected['squish'+str(phase)]=record(recipe,pad,policy)
                break
    validations={name:verify(w) for name,w in selected.items()}
    report=dict(schema=1,scope='Supplied exterior freefall; native entry and controller-only continuations',
        selected=selected,validations=validations,actionNames=g.mario_action_names(),
        aInputs=0,postSetupWrites='Controller-pad fields only',
        scriptSha256=test.sha(__file__),sourceSha256=test.sha(SOURCE),
        dependencies={n:test.sha(Path(__file__).with_name(n)) for n in
            ['ink_early_air_entry_crawl.py','ink_air_entry_to_crawl.py','ink_crawl_edge_entry.py',
             'ink_crawl_top_entry.py','ink_top_entry_witnesses.py','replay.py']})
    with output.open('x',encoding='utf-8') as f:
        json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),results={n:w['outcome'] for n,w in selected.items()},
        validated={n:v['comparedFrames'] for n,v in validations.items()})),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    run(p.parse_args().output)
