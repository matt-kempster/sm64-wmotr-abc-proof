"""Small JP runtime check of encoded sticks, declared buttons and held A."""
import argparse
import hashlib
import json
from pathlib import Path
import sys
import time

sys.path.insert(0,str(Path(__file__).resolve().parent))
from search import (Backend, Input, Observer, ROOT, RUNTIME, accepted_target,
                    create_game, load_capture, prepare, target_fixture)
from controller_inputs import A_BUTTON, NON_A_BITS

PAIRS = ((0,0),(13,-27),(-128,-128),(-128,127),(127,-128),(127,127))


def run():
    started = time.perf_counter()
    reports = []
    for mode in ('released','held'):
        g = create_game()
        b = Backend(g,Observer(g))
        history = []
        a = A_BUTTON if mode == 'held' else 0
        contexts = prepare(b,load_capture(RUNTIME/'capture.bKv95w/inputs.jsonl'),30,Input(a),history)
        scene = contexts[-1]
        if a:
            assert history and all(e['frame'] < contexts[0].frame for e in history)
        probes = []
        controls = [('stick',Input(a,x,y)) for x,y in PAIRS]
        controls += [('button',Input(a|bit)) for bit in NON_A_BITS]
        for kind,control in controls:
            if time.perf_counter()-started > 60:
                raise RuntimeError('Diagnostic time limit')
            b.restore(scene)
            b.patch(target_fixture(accepted_target('low-display')))
            prior_down = b.observe()['buttonDown']
            b.advance(control)
            raw = [g.read('gControllers[0].'+key) for key in ('rawStickX','rawStickY')]
            down = g.read('gControllers[0].buttonDown')
            pressed = g.read('gControllers[0].buttonPressed')
            assert raw == [control.x,control.y]
            assert down == control.buttons
            assert pressed & A_BUTTON == 0
            assert bool(prior_down&A_BUTTON) == bool(a)
            probes.append(dict(kind=kind,input=control.record(),rawStick=raw,
                               previousButtonDown=prior_down,buttonDown=down,buttonPressed=pressed,
                               area=g.read('gCurrAreaIndex'),action=g.read('gMarioState.action')))
        if mode == 'released':
            b.restore(scene)
            b.patch(target_fixture(accepted_target('low-display')))
            b.advance(Input(A_BUTTON))
            new_edge = g.read('gControllers[0].buttonPressed')
            assert new_edge & A_BUTTON
        reports.append(dict(aMode=mode,contextsAlreadyDown=bool(a),
                            earliestSearchFrame=contexts[0].frame,preparationAPresses=history,probes=probes))
    return dict(schema=1,status='checked-input-options',backend='Wafel 0.8.5 JP',
                encodedPairs=65536,bzChoices=262144,fullNonAChoices=536870912,
                modes=reports,controlWithoutHeldHistory={'buttonPressed':new_edge,'isNewAPress':True},
                elapsedSeconds=time.perf_counter()-started,
                scope='Finite input readback checks from supplied low-display fixtures; no gap producer or controller-reachable route',
                sourceHashes={name:hashlib.sha256((ROOT/name).read_bytes()).hexdigest() for name in
                              ('generated/us_game_init.v','generated/jp_game_init.v',
                               'instrumentation/concrete-ink-backward/controller_inputs.py',
                               'instrumentation/concrete-ink-backward/search.py')},
                dllSha256=hashlib.sha256((RUNTIME/'sm64_jp.dll').read_bytes()).hexdigest())


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    report = run()
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps({k:report[k] for k in ('status','elapsedSeconds','encodedPairs','bzChoices','fullNonAChoices')}))
