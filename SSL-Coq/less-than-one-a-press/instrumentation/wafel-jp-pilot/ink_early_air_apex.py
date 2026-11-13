"""Extend the earlier air-entry test towards the cap apex and low pad.

The original seed menu stops halfway up a face. These exterior starts
sample its higher part, where the underlying remembered floor may differ.
They are supplied freefall, never supplied crawl. All later writes are pads.
"""
import argparse
import json
import math
from pathlib import Path
import sys
sys.path.insert(0,str(Path(__file__).resolve().parent))
import ink_early_air_entry_crawl as test
from ink_crawl_top_entry import upper_floor
from ink_crawl_predecessors import f32


def apex_recipes(top, phase, mode):
    if phase < 60:
        return
    assert mode == 'air'
    faces=[f for f in top['faces'] if f['normal']['y']>0.01]
    for fi, face in enumerate(faces):
        base=[v for v in face['vertices'] if v[1]==top['underside']]
        apex=max(face['vertices'],key=lambda v:v[1])
        n=face['normal']
        uphill=round(math.atan2(-n['x'],-n['z'])*65536/math.tau)&0xffff
        for along in [0.05,0.25,0.5,0.75,0.95]:
            edge=[base[0][j]*(1-along)+base[1][j]*along for j in range(3)]
            for inset in [320,352,384,416,448,480]:
                t=inset/512
                x=f32(edge[0]*(1-t)+apex[0]*t)
                z=f32(edge[2]*(1-t)+apex[2]*t)
                y=upper_floor(top['faces'],x,z)
                if y is None:continue
                for height in [1,80]:
                    for yaw_offset in [0,0x4000,0x8000,0xc000]:
                        for speed in [0,32,64]:
                            yield dict(phase=phase,face=fi,along=along,inset=inset,
                                pos=[x,f32(y+height),z],yaw=(uphill+yaw_offset)&0xffff,
                                speed=speed,verticalSpeed=-16,action=0x0100088c,
                                heightAboveFace=height)


def run(output, survey_path):
    g,o,states,meshes=test.contexts()
    constants={n:g.constant(n) for n in test.NAMES}
    selected={}
    if survey_path:
        prior=json.loads(survey_path.read_text(encoding='utf-8'))
        assert prior['generatorSha256']==test.sha(__file__)
        assert prior['scriptSha256']==test.sha(test.__file__)
        survey=prior['survey']
        policies=test.continue_entries(g,o,states,survey,constants,selected,None)
    else:
        test.recipes=apex_recipes
        survey=test.survey(g,o,states,meshes,130)
        policies=None
    validations={name:test.verify(w) for name,w in selected.items()}
    report=dict(schema=1,scope='Supplied higher-face exterior freefall, A off thereafter',
        activePhases=[60,129],survey=survey,policies=policies,selected=selected,
        validations=validations,actionNames=g.mario_action_names(),
        aInputs=0,postSetupWrites='Only three controller-pad fields; state loads between alternative trials',
        preEntrySetup='Accepted pre-game debug level select; 2548 recorded no-A inputs then neutral wait',
        scriptSha256=test.sha(test.__file__),generatorSha256=test.sha(__file__),
        runtimeSha256=test.sha(test.ROOT/'build/wafel-pilot/sm64_jp.dll'),
        captureSha256=test.sha(test.CAPTURE),
        surveyFileSha256=test.sha(survey_path) if survey_path else None,
        limits='Finite higher-face seed menu and 42 controller policies; completed deep first-frame entries only')
    with output.open('x',encoding='utf-8') as f:
        json.dump(report,f,indent=2,allow_nan=False);f.write('\n')
    print(json.dumps(dict(saved=str(output),survey=survey['counts'],
        continuations=policies['counts'] if policies else None,
        validated={n:v['comparedFrames'] for n,v in validations.items()})),flush=True)


if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path)
    p.add_argument('--survey',type=Path)
    args=p.parse_args()
    run(args.output,args.survey)
