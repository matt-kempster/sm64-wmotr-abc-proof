"""Preserve the finite shell approach menu and replay selected outcomes afresh."""
import gzip, hashlib, json, sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent))
from search import ROOT, Guard, create_game, Observer, advance, sample, shells

HERE = Path(__file__).resolve().parent
def sha(p):
    return hashlib.sha256(p.read_bytes()).hexdigest()

def main():
    source = ROOT / 'build/buddy-replacement-shell-approach.json'
    artifact = HERE / 'approaches.json.gz'
    if source.exists() and not artifact.exists():
        artifact.write_bytes(gzip.compress(source.read_bytes(), mtime=0))
    data = json.loads(gzip.decompress(artifact.read_bytes()))
    trials = data['trials']
    selected = sorted({0, min(range(len(trials)), key=lambda i: trials[i]['minDistance']),
                       max(range(len(trials)), key=lambda i: trials[i]['maxY'])})
    boundaries = 0
    for index in selected:
        trial = trials[index]
        game = Guard(create_game())
        observer = Observer(game)
        for pad in data['prefixInputs'][:trial['prefix']]:
            advance(game, pad)
        for i, (pad, expected) in enumerate(zip(trial['inputs'], trial['samples'])):
            advance(game, pad)
            actual = sample(game, observer, trial['prefix'] + i + 1)
            assert actual == expected, (index, i, actual, expected)
            boundaries += 1
        assert shells(game) == trial['shells'], index
        assert len(trial['inputs']) == len(trial['samples'])
    for trial in trials:
        assert not any(p['buttons'] & 0x8000 for p in trial['inputs'])
        assert not trial['released']
        assert all(s['boxAction'] != 4 for s in trial['samples'])
    assert len(trials) == 72
    receipt = dict(schema=1, evidence='finite Wafel JP controller-only search; no original-ROM replay',
        startupGrant='create_game debug level selection; thereafter controller writes only, A released',
        proofRevision='1222ab0ee82b870ba5efe1a8afd7f3ea7e78b1bf',
        captureSha256=data['prefixSha256'], trials=len(trials),
        searchUpdates=sum(len(t['inputs']) for t in trials), releases=0,
        selectedFreshReplays=selected, matchedBoundaries=boundaries,
        nearest=min(t['minDistance'] for t in trials),
        observedMaxMarioY=max(t['maxY'] for t in trials),
        files={p.name:sha(p) for p in [HERE/'search.py', Path(__file__), artifact]},
        dependencies={str(p.relative_to(ROOT)):sha(p) for p in [
            ROOT/'instrumentation/wafel-jp-pilot/replay.py',
            ROOT/'instrumentation/wafel-jp-pilot/ink_crawl_predecessors.py']},
        corrections=['Pilot inactive-object detector falsely labeled area-exit deletion as release; final run requires native shell-box action4.',
                     'Final menu stops at missing area/camera, area departure, low health or death action.'],
        limit='72 specified waypoint/prefix combinations; not a proof that the native shell box is unreachable without A')
    (HERE/'receipt.json').write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
    print(json.dumps(receipt, indent=2))

if __name__ == '__main__':
    main()
