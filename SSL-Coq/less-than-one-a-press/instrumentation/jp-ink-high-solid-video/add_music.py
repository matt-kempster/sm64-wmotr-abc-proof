"""Reuse the original Ink score, trimmed/faded and measured for this film.

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
silent=args.render/'live-box-handoff-silent.mp4'
info=probe(silent); v=next(s for s in info['streams'] if s['codec_type']=='video'); duration=float(v['duration'])
assert int(v['nb_read_frames'])==5281 and v['width']==1600 and v['height']==900
trim=args.render/'score-trim.wav'
run(['ffmpeg','-v','error','-y','-i',str(score),'-t',str(duration),'-af',f'afade=t=out:st={duration-7}:d=7','-c:a','pcm_s24le',str(trim)])
m=loud(trim)
norm=('loudnorm=I=-19:TP=-2:LRA=8:measured_I={input_i}:measured_TP={input_tp}:measured_LRA={input_lra}:measured_thresh={input_thresh}:offset={target_offset}:linear=true:print_format=json').format(**m)
master=args.render/'score-master.wav'
run(['ffmpeg','-v','error','-y','-i',str(trim),'-af',norm,'-ar','48000','-c:a','pcm_s24le',str(master)])
target=args.render/'live-box-handoff.mp4'
run(['ffmpeg','-v','error','-y','-i',str(silent),'-i',str(master),'-map','0:v:0','-map','1:a:0','-c:v','copy','-c:a','aac','-b:a','192k','-ar','48000','-t',str(duration),'-metadata','comment=Original instrumental: Stored in the Dark. Visual commentary uses G = Stored Graphics. Conditional supplied-state original-JP replay.','-movflags','+faststart',str(target)])
run(['ffmpeg','-v','error','-i',str(target),'-f','null','-'])
final=probe(target); fv=next(s for s in final['streams'] if s['codec_type']=='video'); fa=next(s for s in final['streams'] if s['codec_type']=='audio')
assert fv['nb_read_frames']==v['nb_read_frames'] and fv['duration']==v['duration']
assert abs(float(fa['duration'])-duration)<.03
before,after=h264(silent),h264(target); assert before==after
measured=loud(target)
assert -20.1<float(measured['input_i'])<-17.9 and float(measured['input_tp'])<-1.5
report=dict(schema=1,title='Stored in the Dark — live-box edit',sourcePolicy='Original procedural composition, no downloaded music/samples or voice. Trimmed from the existing VPU score master; new ending fade and loudness normalization.',scoreMasterSha256=sha(score),compositionReceiptSha256=sha(score.parent/'soundtrack-receipt.json'),compositionSeed=vpu['seed'],sourceComposition='instrumentation/ink-film-soundtrack/compose.py',audioEditSha256=sha(Path(__file__)),durationSeconds=duration,frames=int(fv['nb_read_frames']),videoSha256=sha(target),videoElementarySha256=after,videoUnchangedByMux=True,fullDecodePassed=True,audioCodec=fa['codec_name'],sampleRate=int(fa['sample_rate']),integratedLUFS=float(measured['input_i']),truePeakDBTP=float(measured['input_tp']),loudnessRangeLU=float(measured['input_lra']),finalFadeSeconds=7,ffmpegVersion=run(['ffmpeg','-version']).stdout.splitlines()[0],review='Objective format, full decode, duration, bitstream, loudness and true-peak checks; no human listening review claimed.')
(args.render/'music-receipt.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
