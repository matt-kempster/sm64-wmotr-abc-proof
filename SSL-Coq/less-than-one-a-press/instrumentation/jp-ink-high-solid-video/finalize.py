"""Preserve reviewed film outputs and a portable final receipt; run from any OS."""
from pathlib import Path
import argparse, hashlib, json, re, shutil
p=argparse.ArgumentParser();p.add_argument('--render',type=Path,required=True);args=p.parse_args()
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
DEST=ROOT/'docs/media/ink-high-solid-video';DEST.mkdir(exist_ok=True,parents=True)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
render=json.loads((args.render/'render-receipt.json').read_text(encoding='utf-8'))
music=json.loads((args.render/'music-receipt.json').read_text(encoding='utf-8'))
checks=json.loads((args.render/'text-fit-checks.json').read_text(encoding='utf-8'))
assert not any(re.search(r'\bD\b',x['text']) for x in checks)
assert any('G  Stored Graphics'==x['text'] for x in checks)
assert music['frames']==render['frames']==5281
mapping=json.loads((HERE/'frame-map.json').read_text(encoding='utf-8'))
by_name={m['file']:m for m in mapping['frameMap']}
for panel in render['panels']:
    m=by_name[panel['source']]
    assert sha(HERE/'frames'/m['file'])==panel['sourceSha256']==m['sha256']
    assert panel['nativeStep']==m['completedInput'] and panel['framebufferTimer']==m['framebufferTimer']
for name in ['live-box-handoff.mp4','live-box-handoff-poster.png','live-box-handoff-transcript.md','live-box-handoff-commentary.vtt']:
    data=(args.render/name).read_bytes()
    if name.endswith(('.md','.vtt')):data=data.replace(b'\r\n',b'\n')
    (DEST/name).write_bytes(data)
(DEST/'.gitattributes').write_bytes(b'* text eol=lf\n*.json -text whitespace=cr-at-eol\n*.md whitespace=-blank-at-eof\n*.vtt whitespace=-blank-at-eof\n*.mp4 binary\n*.png binary\n')
assert sha(DEST/'live-box-handoff.mp4')==music['videoSha256']
receipt=dict(schema=1,scope=render['scope'],proofEvidenceRevision='c1b643cab2963f8b7af18fd71a6089b24c847f44',newGameplayRun=False,
    durationSeconds=render['durationSeconds'],frames=render['frames'],width=1600,height=900,fps=30,
    chapters=render['chapters'],panels=render['panels'],coordinateLabels=render['coordinateLabels'],
    textFitChecks=render['textFitChecks'],textPositionLabelCheckPassed=True,sourceImageJoinCheckPassed=True,
    music=music,visualReview='Independent source/trace join, 18-chapter contact sheet and full-size setup/cache/gap/clone/closing panels reviewed; one initial overlap corrected. No human audio listening review claimed.',
    comparisonLimits='1035/1080 source replay components match; 45 interaction-subtype differences retained. Native transition steps28/29 unobserved. No new original-ROM negative control.',
    filesSha256={q.name:sha(q) for q in DEST.iterdir() if q.is_file() and q.name!='video-receipt.json'},
    sourceFilesSha256={str(q.relative_to(HERE)).replace('\\','/'):sha(q) for q in HERE.rglob('*') if q.is_file() and q.name!='video-receipt.json' and '__pycache__' not in q.parts})
data=(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n').encode()
(DEST/'video-receipt.json').write_bytes(data);(HERE/'video-receipt.json').write_bytes(data)
print('Final film:',DEST/'live-box-handoff.mp4')
print('SHA256:',music['videoSha256'])
print('Chapters:',[(c['startSeconds'],c['title']) for c in render['chapters']])
