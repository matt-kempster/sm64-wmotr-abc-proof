"""Fresh A-off continuations of the native walking alternative at 117.

Only the inherited exterior freefall at 112 is supplied. The first four
post-landing inputs match the finite beam's native walking witness.
"""
import argparse
import json
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_top_slide_to_crawl as study


def run(output):
    source_path=study.ROOT/'build/wafel-pilot/ink-top-slide-to-crawl-full.json'
    source=json.loads(source_path.read_text())
    walking=source['selected']['landing113_beam_slowestTopSlide']['records'][:4]
    cases={}
    for mode in ['neutral-z','uphill-z','uphill-wait4-z']:
        g,o,_,setup=study.root_state('landing113')
        constants={n:g.constant(n) for n in study.NAMES}
        rows=[]
        for expected in walking:
            r=study.advance(g,o,expected['input']);assert r==expected;rows.append(r)
        assert g.read('gMarioState.action')==g.constant('ACT_WALKING')
        assert g.read('gObjectPool[61].oTimer')==118
        k=0
        while g.read('gCurrAreaIndex')==1 and g.read('gObjectPool[61].oAction')==1 and g.read('gObjectPool[61].oTimer')<=150:
            buttons=study.Z if mode!='uphill-wait4-z' or k>=4 else 0
            pad=dict(buttons=buttons,stick=[0,0]) if mode=='neutral-z' else study.controller(g,study.heading(g,'next-uphill'),buttons,64)
            rows.append(study.advance(g,o,pad));k+=1
        w=dict(root='landing113',policy=dict(control=mode),records=rows,
            outcome=study.assess(rows,constants))
        cases[mode]=dict(setup=setup,witness=w,validation=study.verify(w))
    report=dict(schema=1,scope=__doc__,cases=cases,aInputs=0,
        postSetupWrites='Controller pad fields only',
        sourceSha256=study.sha(source_path),scriptSha256=study.sha(__file__),
        dependencies={n:study.sha(Path(study.__file__).with_name(n)) for n in
            ['ink_top_slide_to_crawl.py','ink_crawl_edge_entry.py','ink_air_entry_to_crawl.py',
             'ink_early_air_entry_crawl.py','ink_top_entry_witnesses.py']})
    with output.open('x',encoding='utf-8') as f:json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    names=g.mario_action_names()
    print(json.dumps(dict(saved=str(output),cases={n:dict(outcome=c['witness']['outcome'],
        frames=len(c['witness']['records'])+len(c['setup']['prefix']),
        timeline=[dict(behavior=r['executedTopTimer'],action=names.get(r['state']['action']),
            input=r['input'],nativeInput=r['state']['input'],position=r['state']['position'])
            for r in c['witness']['records'] if r['executedTopTimer'] in [117,118,119,122,129,130,150]])
        for n,c in cases.items()})))


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    run(p.parse_args().output)
