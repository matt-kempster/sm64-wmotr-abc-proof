"""Check the neutral continuation of the supplied final-dialog near match.

One initial conditional patch, then 24 uninterrupted JP updates. This is a
finite gameplay diagnostic, not a reachable dialog predecessor or no-A proof.
"""
import argparse
import hashlib
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent))

from search import Backend, Input, Observer, accepted_target, create_game, load_capture
from search import previous_moves, prepare, target_fixture, RUNTIME, ROOT, number, IDLE


def run():
    game = create_game()
    backend = Backend(game, Observer(game))
    contexts = prepare(backend, load_capture(RUNTIME / 'capture.bKv95w/inputs.jsonl'), 30)
    accepted = accepted_target('low-display')
    backend.restore(contexts[-1])
    backend.patch(target_fixture(accepted))
    parent = backend.capture()
    move = next(m for m in previous_moves(parent.observation)
                if m.name == 'dialog-final-sink-depth-0' and m.control == Input())
    backend.restore(contexts[-2])
    backend.patch(move.patch)
    warp = {field: game.read('gObjectPool[64].' + field) for field in
            ('oPosX', 'oPosY', 'oPosZ', 'hitboxHeight', 'hitboxRadius',
             'hitboxDownOffset', 'oIntangibleTimer', 'oInteractType', 'oBhvParams')}
    assert warp['oPosY'] == 768. and warp['hitboxHeight'] == 50.
    assert warp['hitboxDownOffset'] == 0. and warp['hitboxRadius'] == 150.
    assert game.read('gObjectPool[64].behavior') == game.address('bhvWarp')
    steps = []
    for index in range(1, 25):
        backend.advance(Input())
        assert game.read('gCurrAreaIndex') == 1
        obs = backend.observe()
        actions = [e for e in game.frame_log() if e['type'] == 'FLT_EXECUTE_ACTION']
        assert obs['usedSlot'] == -1 and all(e['action'] != 0x1300 for e in actions)
        steps.append(dict(update=index, frame=backend.frame(), observation=obs, actions=actions,
                          marioHitboxDownOffset=game.read('gMarioObject.hitboxDownOffset')))
    first, second = steps[0]['observation'], steps[1]['observation']
    assert first['action'] == IDLE and first['movement'] == first['collision']
    assert first['movement'][1] == accepted['movement'][1]
    assert first['display'] == accepted['display']
    assert steps[0]['marioHitboxDownOffset'] == 0.
    assert second['movement'] == second['collision'] == second['display']
    return dict(schema=1, status='checked-finite-dialog-continuation',
                backend='Wafel 0.8.5 JP',
                condition='Supplied final-dialog predecessor, one initial patch, neutral continuation',
                patch=move.patch, upperWarpSlot=64, upperWarp=warp, steps=steps,
                intermediatePatches=0, intermediateRestores=0,
                area2Reached=False, disappearedReached=False,
                scope='No warp in these 24 updates, not every later history or dialog route',
                sourceHashes={name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest() for name in
                              ('generated/jp_object_collision.v', 'generated/us_object_collision.v',
                               'generated/jp_object_list_processor.v', 'generated/us_object_list_processor.v',
                               'generated/jp_interaction.v', 'generated/us_interaction.v',
                               'generated/jp_behavior_actions.v', 'generated/us_behavior_actions.v')},
                dllSha256=hashlib.sha256((RUNTIME / 'sm64_jp.dll').read_bytes()).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    report = run()
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(dict(status=report['status'], completedUpdates=len(report['steps']),
                         area2Reached=report['area2Reached'], disappearedReached=report['disappearedReached'],
                         firstHeights={key: number(report['steps'][0]['observation'][key][1]) for key in
                                       ('movement', 'collision', 'display')},
                         upperWarp=report['upperWarp'])))


if __name__ == '__main__':
    main()
