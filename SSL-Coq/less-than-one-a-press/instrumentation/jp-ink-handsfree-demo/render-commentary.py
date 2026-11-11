"""Caption authentic ROM frames in margins; make cuts and supplied setups explicit.

Run in Ubuntu-24.04 with ffmpeg. The manifest resolves paths from the SSL
project root. This is video assembly only: no emulator or gameplay writes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory
import textwrap

ROOT = Path(__file__).resolve().parents[2]
FPS = 30


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def timestamp(frame):
    millis=round(frame*1000/FPS)
    return f'{millis//3600000:02}:{millis//60000%60:02}:{millis//1000%60:02}.{millis%1000:03}'


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('manifest',type=Path)
    p.add_argument('output',type=Path)
    p.add_argument('--receipt',type=Path,required=True)
    p.add_argument('--transcript',type=Path,required=True)
    args=p.parse_args()
    for path in [args.output,args.receipt,args.transcript]:
        if path.exists():raise FileExistsError(path)
        path.parent.mkdir(parents=True,exist_ok=True)
    manifest=json.loads(args.manifest.read_text(encoding='utf-8'))
    font='/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
    sources={};segments=[];n=0
    with TemporaryDirectory(prefix='ink-commentary-') as scratch:
        temp=Path(scratch)
        filters=['scale=960:720:flags=neighbor','pad=960:1008:0:88:color=0x10151e']
        def text(label,content,y,size,first,last,color='white'):
            (temp/(label+'.txt')).write_text(content,encoding='utf-8')
            filters.append(f"drawtext=fontfile={font}:textfile={label}.txt:expansion=none:fontsize={size}:fontcolor={color}:x=(w-tw)/2:y={y}:line_spacing=6:enable='between(n,{first},{last})'")
        for i,s in enumerate(manifest['segments']):
            source=(ROOT/s['source']).resolve()
            shots=sorted(source.glob('super_mario_64-*.png'),key=lambda f:int(f.stem.rsplit('-',1)[1]))
            start,stop,repeat=s['start'],s['stop'],s.get('repeat',1)
            assert 0<=start<stop<=len(shots),(i,start,stop,len(shots))
            assert repeat>0
            first=n
            for index in range(start,stop):
                shot=shots[index]
                if str(shot) not in sources:
                    sources[str(shot)]=dict(source=str(shot.relative_to(ROOT)),sha256=sha(shot))
                for _ in range(repeat):
                    (temp/f'{n:06}.png').symlink_to(shot)
                    n+=1
            last=n-1
            text(f'title-{i}',manifest['title'],14,24,first,last)
            text(f'label-{i}',s['label'],51,19,first,last,s.get('labelColor','0xffd475'))
            text(f'headline-{i}',s['headline'],825,27,first,last)
            detail='\n'.join(textwrap.fill(line,84) for line in s['detail'].split('\n'))
            assert len(detail.splitlines())<=4,(i,detail)
            text(f'detail-{i}',detail,866,21,first,last,'0xd4deec')
            text(f'footer-{i}',s['footer'],981,16,first,last,'0xa8b5c7')
            segments.append(dict(**s,firstVideoFrame=first,lastVideoFrame=last,
                                 startTime=timestamp(first),endTime=timestamp(n)))
        subprocess.run(['ffmpeg','-nostdin','-hide_banner','-loglevel','warning',
                        '-framerate',str(FPS),'-i','%06d.png','-vf',','.join(filters),
                        '-frames:v',str(n),'-c:v','libx264','-crf','18','-preset','medium',
                        '-pix_fmt','yuv420p','-movflags','+faststart',str(args.output.resolve())],
                       cwd=temp,check=True)
    probe=json.loads(subprocess.check_output(['ffprobe','-v','error','-select_streams','v:0',
        '-show_entries','stream=width,height,r_frame_rate,nb_frames,duration','-of','json',str(args.output)],text=True))
    stream=probe['streams'][0]
    assert int(stream['nb_frames'])==n and (stream['width'],stream['height'])==(960,1008)
    result=dict(schema=1,scope='Original-ROM frames with labeled cuts, pauses and text outside the game image; no clean full-route claim',
                videoSha256=sha(args.output),manifestSha256=sha(args.manifest),rendererSha256=sha(Path(__file__)),
                fps=FPS,frames=n,durationSeconds=n/FPS,probe=probe,segments=segments,
                uniqueSourceFrames=list(sources.values()),audio='silent')
    args.receipt.write_text(json.dumps(result,indent=2)+'\n',encoding='utf-8')
    lines=['# Video commentary: hands-free holding and the supplied Ink tests','',
           'The video uses authentic original-JP ROM frames. Text is added outside the game image.',
           'Pauses and slow motion repeat recorded frames. Different runs are explicitly separated.',
           'No A inputs are used; marked supplied-state edits are not controller gameplay.',
           'This demonstrates component behavior, not a complete clean no-A SSL Pyramid route.','']
    for s in segments:
        lines += [f"## {s['startTime']}–{s['endTime']}: {s['headline']}",'',s['label'],'',s['detail'],'',s['footer'],'']
    args.transcript.write_text('\n'.join(lines),encoding='utf-8')
    print(json.dumps({k:result[k] for k in ['videoSha256','frames','durationSeconds','audio']}))


if __name__=='__main__':main()
