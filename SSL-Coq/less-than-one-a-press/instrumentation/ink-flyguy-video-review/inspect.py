"""Extract timestamped reference frames; never modifies or republishes the input video."""
import argparse
import hashlib
import json
import subprocess
from pathlib import Path

TIMES = [0, 255, 270, 280, 290, 300, 310, 320, 330, 340, 350, 360,
         375, 390, 405, 420, 435, 450, 465, 480]

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('video', type=Path)
    parser.add_argument('--ffmpeg', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    hashes = {}
    for seconds in TIMES:
        frame = args.output / ('frame-%04d.jpg' % seconds)
        subprocess.run([str(args.ffmpeg), '-nostdin', '-hide_banner', '-loglevel', 'error',
                        '-n', '-ss', str(seconds), '-i', str(args.video),
                        '-frames:v', '1', '-q:v', '2', str(frame)], check=True)
        hashes[frame.name] = hashlib.sha256(frame.read_bytes()).hexdigest()
    receipt = dict(inputFile=args.video.name, bytes=args.video.stat().st_size,
                   sha256=hashlib.sha256(args.video.read_bytes()).hexdigest(),
                   exactSeekSeconds=TIMES, frameSha256=hashes,
                   method='FFmpeg input seek followed by one decoded frame at each requested timestamp',
                   limitation='Visual inspection only; no controller movie, ROM provenance, or narration transcription')
    (args.output / 'frame-receipt.json').write_bytes((json.dumps(receipt, indent=2)+'\n').encode())
    print(json.dumps(receipt, indent=2))

if __name__ == '__main__':
    main()
