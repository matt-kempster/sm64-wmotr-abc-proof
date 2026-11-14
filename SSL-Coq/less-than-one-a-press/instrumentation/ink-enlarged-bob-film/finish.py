"""Reuse the original Ink score for the three-actor film; no spoken audio.

Run in Ubuntu-24.04 with ffmpeg/ffprobe. No downloads or voice synthesis.
"""
from pathlib import Path
import argparse, hashlib, json, re, subprocess
p=argparse.ArgumentParser()
p.add_argument('--workspace',type=Path,required=True)
p.add_argument('--render',type=Path,required=True)
args=p.parse_args()
def run(argv): return subprocess.run(argv,check=True,capture_output=True,text=True)
def sha(p): return hashlib.sha256(p.read_bytes()).hexdigest()
def probe(p): return json.loads(run(['ffprobe','-v','error','-count_frames','-show_streams','-show_format','-of','json',str(p)]).stdout)
def loud(p):
    r=run(['ffmpeg','-hide_banner','-i',str(p),'-vn','-af','loudnorm=I=-19:TP=-2:LRA=8:print_format=json','-f','null','-'])
    return json.loads(re.findall(r'\{\s*"input_i"[\s\S]*?\}',r.stderr)[-1])
def h264(p):
    return run(['ffmpeg','-v','error','-i',str(p),'-map','0:v:0','-c:v','copy','-bsf:v','h264_mp4toannexb','-f','hash','-hash','sha256','-']).stdout.strip()
score=args.workspace/'build/ink-film-soundtrack/vpu-score.wav'
old=json.loads((score.parent/'soundtrack-receipt.json').read_text())
vpu=next(x for x in old['films'] if x['name']=='vpu')
assert sha(score)==vpu['scoreMasterSha256']
silent=args.render/'enlarged-bob-handoff-silent.mp4'
info=probe(silent); v=next(s for s in info['streams'] if s['codec_type']=='video'); duration=float(v['duration'])
render=json.loads((args.render/'render-receipt.json').read_text())
assert int(v['nb_read_frames'])==render['frames'] and v['width']==1600 and v['height']==900
trim=args.render/'score-trim.wav'
run(['ffmpeg','-v','error','-y','-i',str(score),'-t',str(duration),'-af',f'afade=t=out:st={duration-7}:d=7','-c:a','pcm_s24le',str(trim)])
m=loud(trim)
norm=('loudnorm=I=-19:TP=-2:LRA=8:measured_I={input_i}:measured_TP={input_tp}:measured_LRA={input_lra}:measured_thresh={input_thresh}:offset={target_offset}:linear=true:print_format=json').format(**m)
master=args.render/'score-master.wav'
run(['ffmpeg','-v','error','-y','-i',str(trim),'-af',norm,'-ar','48000','-c:a','pcm_s24le',str(master)])
target=args.render/'enlarged-bob-handoff.mp4'
run(['ffmpeg','-v','error','-y','-i',str(silent),'-i',str(master),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','192k','-ar','48000','-t',str(duration),'-metadata','comment=Original instrumental: Stored in the Dark. Visual commentary uses G = Stored Graphics. Conditional supplied-state original-JP replay.','-movflags','+faststart',str(target)])
run(['ffmpeg','-v','error','-i',str(target),'-f','null','-'])
final=probe(target); fv=next(s for s in final['streams'] if s['codec_type']=='video'); fa=next(s for s in final['streams'] if s['codec_type']=='audio')
assert fv['nb_read_frames']==v['nb_read_frames'] and fv['duration']==v['duration']
assert abs(float(fa['duration'])-duration)<.03
before,after=h264(silent),h264(target); assert before==after
measured=loud(target)
assert -20.1<float(measured['input_i'])<-17.9 and float(measured['input_tp'])<-1.5
report=dict(schema=1,title='Stored in the Dark - three-actor edit',sourcePolicy='Original procedural composition, no downloaded music/samples or voice. Trimmed from the existing VPU score master; new ending fade and loudness normalization.',scoreMasterSha256=sha(score),compositionReceiptSha256=sha(score.parent/'soundtrack-receipt.json'),compositionSeed=vpu['seed'],sourceComposition='instrumentation/ink-film-soundtrack/compose.py',audioEditSha256=sha(Path(__file__)),durationSeconds=duration,frames=int(fv['nb_read_frames']),videoSha256=sha(target),videoElementarySha256=after,videoUnchangedByMux=True,fullDecodePassed=True,audioCodec=fa['codec_name'],sampleRate=int(fa['sample_rate']),integratedLUFS=float(measured['input_i']),truePeakDBTP=float(measured['input_tp']),loudnessRangeLU=float(measured['input_lra']),finalFadeSeconds=7,ffmpegVersion=run(['ffmpeg','-version']).stdout.splitlines()[0],review='Objective format, full decode, duration, bitstream, loudness and true-peak checks; no human listening review claimed.')
def stamp(t):
    ms=round(t*1000);return f'{ms//3600000:02}:{ms//60000%60:02}:{ms//1000%60:02}.{ms%1000:03}'
vtt=['WEBVTT','']
transcript=['# Three actors, one useful Ink handoff','',render['scope'],'','On-screen commentary with original instrumental music. No spoken narration. G means Stored Graphics (gfx.pos), not the visibly drawn pose.','']
for c in render['chapters']:
    vtt += [f"{stamp(c['startSeconds'])} --> {stamp(c['endSeconds'])}",*c['lines'],'']
    transcript += [f"## {stamp(c['startSeconds'])}–{stamp(c['endSeconds'])}: {c['title']}",'',c['tag'],'',*c['lines'],'',c['footer'],'']
(args.render/'enlarged-bob-handoff-commentary.vtt').write_text('\n'.join(vtt),encoding='utf-8')
(args.render/'enlarged-bob-handoff-transcript.md').write_text('\n'.join(transcript),encoding='utf-8')
report.update(scope=render['scope'],width=int(fv['width']),height=int(fv['height']),videoCodec=fv['codec_name'],narration=False,posterSha256=sha(args.render/'enlarged-bob-handoff-poster.png'),transcriptSha256=sha(args.render/'enlarged-bob-handoff-transcript.md'),vttSha256=sha(args.render/'enlarged-bob-handoff-commentary.vtt'),renderReceiptSha256=sha(args.render/'render-receipt.json'),coordinateLabels=render['coordinateLabels'],chapters=[{k:c[k] for k in ['id','title','startSeconds','endSeconds']} for c in render['chapters']])
raw=target.read_bytes();assert raw.index(b'moov')<raw.index(b'mdat');report['fastStart']=True
(args.render/'enlarged-bob-video-receipt.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps({k:report[k] for k in ['durationSeconds','frames','videoSha256','fullDecodePassed','integratedLUFS','truePeakDBTP']}))
