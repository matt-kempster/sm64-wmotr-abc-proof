"""Verify the two G-labelled film editions and preserve their existing AAC scores."""
import argparse, hashlib, json, re, shutil, subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
PROOF = HERE.parent.parent
WORKSPACE = PROOF.parents[2]
OLD = {'crawl': '05e95712e7c5728b6cce453fbffe909bb8e4d550c73643dd0c3a099cafb3e4a1',
       'vpu': 'e9ad1add20d2b4736385470dca919944aeaabc5ba2ab3fbd81dcc4fa09afdd12'}
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def run(*args): return subprocess.run(list(map(str,args)),check=True,capture_output=True)
def read(p): return json.loads(p.read_text(encoding='utf-8-sig'))

def main():
    ap=argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--original-directory',required=True,type=Path)
    ap.add_argument('--crawl-directory',required=True,type=Path)
    ap.add_argument('--vpu-directory',required=True,type=Path)
    ap.add_argument('--ffmpeg',type=Path)
    ap.add_argument('--check-only',action='store_true')
    a=ap.parse_args()
    ff=a.ffmpeg or next((Path.home()/'AppData/Local/Overwolf/Extensions').rglob('ffmpeg.exe'))
    probe=ff.with_name('ffprobe.exe')
    def metadata(p):return json.loads(run(probe,'-v','error','-show_streams','-of','json',p).stdout)
    def packets(p):return json.loads(run(probe,'-v','error','-select_streams','a:0','-show_packets','-show_entries','packet=pts,dts,duration,flags,side_data_list','-of','json',p).stdout)
    def elementary(p,k):return hashlib.sha256(run(ff,'-v','error','-i',p,'-map','0:'+k+':0','-c','copy','-f',('adts' if k=='a' else 'h264'),'-').stdout).hexdigest()
    receipt={'schema':1,'date':'2026-11-14','scope':'Presentation only: D is renamed G = Stored Graphics in the two current films. Native images, input histories, timing and music are unchanged. Historical traces may retain the key D. No new gameplay or proof result.',
             'sourceProofCommit':'c1b643cab2963f8b7af18fd71a6089b24c847f44','films':{}}
    for name,directory,silentname,frames in [('crawl',a.crawl_directory,'crawl-caption-corrected.mp4',3742),('vpu',a.vpu_directory,'ink-vpu-actions.mp4',7398)]:
        old=a.original_directory/(name+'-with-music.mp4')
        assert sha(old)==OLD[name],(name,'wrong source')
        silent=directory/silentname
        scored=directory/(name+'-with-music.mp4')
        if not a.check_only:
            run(ff,'-v','error','-y','-i',silent,'-i',old,'-map','0:v:0','-map','1:a:0','-c','copy','-movflags','+faststart',scored)
        om,nm=metadata(old),metadata(scored)
        ov=next(s for s in om['streams'] if s['codec_type']=='video')
        nv=next(s for s in nm['streams'] if s['codec_type']=='video')
        for key in ['width','height','pix_fmt','r_frame_rate','nb_frames','duration']:
            assert ov[key]==nv[key],(name,key)
        assert (nv['width'],nv['height'],int(nv['nb_frames']),nv['r_frame_rate'])==(1600,900,frames,'30/1')
        run(ff,'-v','error','-xerror','-i',scored,'-f','null','-')
        oh,nh=elementary(old,'a'),elementary(scored,'a')
        assert oh==nh
        op,np=packets(old),packets(scored)
        assert op==np,(name,'audio packet timings changed')
        assert elementary(silent,'v')==elementary(scored,'v')
        assert elementary(old,'v')!=elementary(scored,'v')
        receipt['films'][name]={'oldScoredSha256':sha(old),'silentSha256':sha(silent),'scoredSha256':sha(scored),'frameCount':frames,'durationSeconds':float(nv['duration']),'width':1600,'height':900,'fullDecodePassed':True,'exactPreviousAACPreserved':True,'aacElementarySha256':nh,'audioPacketTimingIdentical':True,'audioPacketCount':len(np['packets']),'newSilentAndScoredVideoIdentical':True,'newVideoDiffersFromPrevious':True}
    # All video-panel gameplay pixels and timings must survive the label change.
    shell=shutil.which('pwsh') or shutil.which('powershell')
    checks=read(a.crawl_directory/'caption-correction-receipt.json')
    assert checks['verification']['all66GameplayPanelCropsPixelIdentical']
    receipt['films']['crawl']['gameplayCropsPixelIdentical']=66
    olddir=WORKSPACE/'build/ink-vpu-actions-video'
    assert (olddir/'frames.txt').read_bytes()==(a.vpu_directory/'frames.txt').read_bytes()
    # The VPU renderer overlays its badge at y597. Compare only the visible
    # native-image rectangle, excluding newly rasterized caption glyphs.
    crops=json.loads(run(shell,'-NoProfile','-File',PROOF/'instrumentation/ink-crawl-caption-fix/check-gameplay-panels.ps1','-OriginalPanels',olddir,'-CorrectedPanels',a.vpu_directory,'-CropHeight',398).stdout.decode('utf-8-sig'))
    assert len(crops)==562
    previous=read(PROOF/'docs/media/ink-vpu-actions/ink-vpu-actions-video-receipt.json')
    current=read(a.vpu_directory/'ink-vpu-actions-video-receipt.json')
    assert previous['panels']==current['panels']
    # Object key order in PowerShell output is irrelevant.
    assert sorted(previous['uniqueOriginalFrames'],key=lambda x:x['path'])==sorted(current['uniqueOriginalFrames'],key=lambda x:x['path'])
    receipt['films']['vpu'].update(gameplayCropsPixelIdentical=562,visibleGameplayCrop=[109,199,560,398],captionBadgeExcluded=True,concatTimingIdentical=True,sourceFramesAndInputJoinsIdentical=True,uniqueNativeFrames=544,sourceReceipts=6,textFitChecks=current['textFitChecks'])
    for rel in ['instrumentation/ink-crawl-caption-fix/render.ps1','instrumentation/jp-ink-vpu-actions-demo/render_video.ps1','instrumentation/jp-ink-vpu-actions-demo/timeline.json']:
        text=(PROOF/rel).read_text(encoding='utf-8-sig')
        assert not re.search(r'\bD\b|\bMCD\b',text),rel
        assert 'G' in text
    transcript=(a.vpu_directory/'ink-vpu-actions-transcript.md').read_text(encoding='utf-8-sig')
    assert not re.search(r'\bD\b',transcript)
    receipt['currentRenderersAndCommentaryUseG']=True
    receipt['visualReview']='Inspected full-size crawl gap and VPU gap panels; G legend, explanatory labels, source gameplay panel, and stored-graphics-versus-rendering caveat are legible. No listening review claimed.'
    receipt['verifierSha256']=sha(Path(__file__))
    receipt['ffmpegVersion']=run(ff,'-version').stdout.decode().splitlines()[0]
    target=a.crawl_directory/'g-label-update-receipt.json'
    target.write_bytes((json.dumps(receipt,indent=2)+'\n').encode())
    print(json.dumps(receipt,indent=2))
if __name__=='__main__':main()
