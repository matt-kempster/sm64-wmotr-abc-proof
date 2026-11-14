"""Check preserved final media, selected native image joins and source hashes."""
from pathlib import Path
import argparse, hashlib, json

p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');args=p.parse_args()
here=Path(__file__).resolve().parent;root=here.parents[1]
media=root/'docs/media/ink-enlarged-bob-video'
capture=here.parent/'jp-ink-enlarged-bob-video'
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p):return json.loads(p.read_text(encoding='utf-8'))
receipt=read(media/'enlarged-bob-video-receipt.json');render=read(here/'render-receipt.json');story=read(here/'storyboard.json')
assert receipt['durationSeconds']==175 and receipt['frames']==5250
assert receipt['narration'] is False and receipt['fullDecodePassed'] and receipt['fastStart']
assert receipt['renderReceiptSha256']==sha(here/'render-receipt.json')
assert render['rendererSha256']==sha(here/'render.ps1')
assert render['storyboardSha256']==sha(here/'storyboard.json')
assert receipt['audioEditSha256']==sha(here/'finish.py')
for key,name in [('videoSha256','enlarged-bob-handoff.mp4'),('posterSha256','enlarged-bob-handoff-poster.png'),('transcriptSha256','enlarged-bob-handoff-transcript.md'),('vttSha256','enlarged-bob-handoff-commentary.vtt')]:
    assert sha(media/name)==receipt[key],name
maps={'positive':read(capture/'positive-closeup-frame-map.json'),'no-final-box':read(capture/'no-final-box-frame-map.json')}
frame=0
for panel in render['panels']:
    assert panel['firstFrame']==frame and panel['frames']>0
    frame+=panel['frames']
    m=next(m for m in maps[panel['case']]['frameMap'] if m['file']==panel['source'])
    assert m['completedBridge'] is not None and m['completedBridge']==panel['nativeBridge']
    assert m['sha256']==panel['sourceSha256']==sha(capture/m['file'])
assert frame==5250
for c,s in zip(render['chapters'],story['segments']):
    assert c['id']==s['id'] and c['lines']==s['lines'] and c['footer']==s['footer']
    assert abs(c['endSeconds']-c['startSeconds']-s['seconds'])<1e-7
assert len(render['chapters'])==14
result=dict(schema=1,scope='Film artifact/provenance checks, not a gameplay reachability theorem',durationSeconds=175,frames=5250,chapters=14,panels=len(render['panels']),textFitChecks=render['textFitChecks'],nativeImages='All selected image hashes and joined native bridges match preserved maps',narration=False,videoSha256=receipt['videoSha256'],captureVerificationSha256=sha(capture/'capture-receipt.json'),files={str(p.relative_to(root)).replace('\\','/'):sha(p) for p in [here/'render.ps1',here/'finish.py',here/'storyboard.json',here/'render-receipt.json',here/'facts.json',media/'enlarged-bob-video-receipt.json',root/'docs/notes/ink-enlarged-bob-film.md']})
out=here/'verification.json'
if args.check:assert read(out)==result
else:out.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
print(f"PASS 175-second film: {len(render['panels'])} joined panels, 14 chapters, final media/source hashes; music only")
