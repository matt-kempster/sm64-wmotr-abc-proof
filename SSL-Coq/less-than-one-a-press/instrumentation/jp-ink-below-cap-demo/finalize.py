"""Archive and verify the two captured runs and their honest video boundary.

The default --verify mode checks stored evidence, not new gameplay. Creation
requires --write and two capture directories. Run from any directory.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parents[2]
HERE=Path(__file__).resolve().parent
MEDIA=ROOT/'docs/media'
OUT=MEDIA/'ink-below-cap-native'

def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def read(p): return json.loads(p.read_text(encoding='utf-8'))
def fields(line): return dict(re.findall(r'(\w+)=((?:\([^)]*\))|[^,\n]+)',line))
def xyz(s): return [float(v) for v in s.strip('()').split(',')]

def audit(directory,prefix=''):
    receipt=read(directory/(prefix+'receipt.json'))
    raw=directory/(prefix+'raw.log'); trace=directory/(prefix+'trace.txt')
    text=raw.read_text(encoding='utf-8',errors='replace')
    def rows(tag): return [fields(l) for l in text.splitlines() if l.startswith(tag+',')]
    assert receipt['rawLogSha256']==sha(raw) and receipt['traceSha256']==sha(trace)
    assert receipt['renderStates']==rows('HANDS_RENDER')
    assert receipt['extraStates']==[r for r in rows('HANDS_EXTRA') if r['tag']=='HANDS_RENDER']
    assert receipt['renderMatrixStates']==[r for r in rows('HANDS_MATRIX') if r['tag']=='HANDS_RENDER']
    assert receipt['writes']==rows('HANDS_WRITE') and len(receipt['writes'])==13
    assert receipt['initial']==rows('HANDS_AFTER_CUT')[0]
    assert receipt['controllerSummary']==rows('RESULT')[-1]
    assert all(receipt['controllerSummary'][k]=='0' for k in ('aPressedFrames','aDownFrames','controllerAFrames'))
    r={int(v['step']):v for v in receipt['renderStates']}
    assert xyz(r[6]['state'])==xyz(r[6]['collision'])==[-2200,768,-1024]
    assert xyz(r[6]['display'])==[-2200,1400,-1024]
    assert r[7]['floorY']=='1280' and r[7]['platform']==r[7]['floorOwner']=='00000000'
    assert xyz(r[30]['state'])==[0,5500,256] and r[30]['area']=='2'
    m={int(v['step']):v for v in receipt['renderMatrixStates']}
    assert xyz(m[6]['translation'])==[-2200,768,-1024] and m[7]['pointer']=='00000000'
    assert receipt['setupWordWrites']==13 and receipt['floorCacheWrites']==0
    assert receipt['renderIllustrations']==rows('HANDS_ILLUSTRATION')
    assert receipt['camera'] in ('stock','display')
    assert len(receipt['renderIllustrations'])==(2 if receipt['camera']=='display' else 0)
    assert len(receipt['frameMap'])==len(rows('HANDS_SCREENSHOT'))==146
    assert receipt['frameMap'][5]['completedInput']==5
    assert receipt['frameMap'][6]['completedInput']==6
    assert receipt['frameMap'][7]['completedInput']==7
    assert receipt['frameMap'][27]['completedInput'] is None
    assert receipt['frameMap'][28]['completedInput']==30
    assert 'HANDS_ERROR' not in text
    return receipt

def verify():
    p=read(OUT/'provenance.json')
    for item in p['files']:
        assert sha(ROOT/item['path'])==item['sha256'],item['path']
    a=audit(OUT,'stock-');b=audit(OUT,'display-')
    for key in p['identicalLoggedFields']:
        assert a[key]==b[key],key
    for receipt in (a,b):
        assert receipt['probeSourceSha256']==sha(OUT/'probe-source.c')
        assert receipt['prefixSourceSha256']==sha(OUT/'prefix-source.c')
        assert receipt['runnerSha256']==sha(OUT/'run-source.sh')
    for file in HERE.iterdir():
        if file.suffix in ('.py','.c','.sh','.json'):
            assert b'\r' not in file.read_bytes(),file
    video=read(MEDIA/'ink-below-cap-demo-receipt.json')
    assert video['videoSha256']==sha(MEDIA/'ink-below-cap-demo.mp4')
    assert video['manifestSha256']==sha(HERE/'video-timeline.json')
    assert video['rendererSha256']==sha(HERE/'render-commentary.py')
    assert video['frames']==1884 and video['durationSeconds']==62.8
    assert p['scope'].startswith('Conditional')
    print(json.dumps(dict(result='PASS',kind='stored evidence verification; no new gameplay',
        nativeRuns=2,matchingLoggedRenderSnapshots=len(a['renderStates']),
        setupWordWritesPerRun=13,AInputs=0,split=632,storedDisplayY=1400,
        nativeRenderMatrixY=768,nextFloorY=1280,firstArea2=[0,5500,256],
        videoFrames=video['frames'],videoSeconds=video['durationSeconds']),indent=2))

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--write',action='store_true')
    p.add_argument('--stock',type=Path);p.add_argument('--display',type=Path)
    args=p.parse_args()
    if args.write:
        assert args.stock and args.display
        assert not OUT.exists(),OUT
        a=audit(args.stock);b=audit(args.display)
        same=['renderStates','extraStates','renderMatrixStates','writes','initial','controllerSummary']
        assert all(a[k]==b[k] for k in same)
        OUT.mkdir()
        (OUT/'.gitattributes').write_bytes(b'*.json text eol=lf\n*.txt text eol=lf\n*.log text eol=lf\n*.c text eol=lf\n*.sh text eol=lf\n')
        for name,source in [('stock',args.stock),('display',args.display)]:
            for file in ['receipt.json','trace.txt','raw.log']:
                shutil.copyfile(source/file,OUT/(name+'-'+file))
        for file in ['probe-source.c','prefix-source.c','run-source.sh']:
            assert sha(args.stock/file)==sha(args.display/file)
            shutil.copyfile(args.stock/file,OUT/file)
        for name,source,index in [('stock-gap',args.stock,6),('illustrated-start',args.display,5),
                                  ('illustrated-display',args.display,6),('elevator',args.stock,46)]:
            shutil.copyfile(source/'shots'/f'super_mario_64-{index:03}.png',OUT/(name+'.png'))
        paths=list(OUT.iterdir())+list(HERE.iterdir())+[
            MEDIA/'ink-below-cap-demo.mp4',MEDIA/'ink-below-cap-demo-receipt.json',
            MEDIA/'ink-below-cap-demo-transcript.md',MEDIA/'ink-below-cap-demo-poster.png']
        paths=[v for v in paths if v.is_file()]
        result=dict(schema=1,scope='Conditional supplied-crawl and position test; not a clean producer or useful top installation',
            romSha256=a['romSha256'],romMd5=a['romMd5'],
            emulator='Mupen64Plus2.5.9 interpreter; Rice2.5.9; HLE RSP2.5.9; dummy audio; Ubuntu24.04; debug level-select cheat6',
            sourceCheckout=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
            sourceCaptureDirectories=[str(args.stock),str(args.display)],
            identicalLoggedFields=same,matchingLoggedRenderSnapshots=len(a['renderStates']),
            gameplayClaims='13 supplied words: action once, then12XYZwords; no floor cache/hitbox/velocity/depth/top/RNG writes; no A',
            visualBoundary='Stock run has no render edits. Illustration replay changes camera plus starting graphics positions and throwMatrix. Restore native post-render NULL, not pre-render matrix; all logged gameplay and matrix records match.',
            suppliedStartingPosition=[-2132,1400,-1024],suppliedBoxPosition=[-2093,1400,-1024],
            split=dict(movement=[-2200,768,-1024],collision=[-2200,768,-1024],storedDisplay=[-2200,1400,-1024],nativeRenderMatrixTranslation=[-2200,768,-1024]),
            outcome=dict(nextStaticFloor=1280,topCaptured=False,firstArea2=[0,5500,256]),
            imageMapping='Previous framebuffer; explicit frameMap joins to logged camera timer. PNG27 transition has no logged prior camera state. PNG28 is first Area2 state.',
            poster=dict(source='docs/media/ink-below-cap-demo.mp4',timeSeconds=12,
                method='ffmpeg -ss12 -frames:v1; captioned render-only starting-coordinate illustration'),
            files=[dict(path=str(v.relative_to(ROOT)).replace('\\','/'),sha256=sha(v)) for v in sorted(paths)])
        (OUT/'provenance.json').write_bytes((json.dumps(result,indent=2)+'\n').encode('utf-8'))
    verify()

if __name__=='__main__':main()
