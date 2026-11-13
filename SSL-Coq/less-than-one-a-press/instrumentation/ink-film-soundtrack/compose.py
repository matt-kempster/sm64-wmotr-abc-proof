"""Deterministic original instrumental music, composed for two Ink films.

No samples, downloaded music or pretrained audio model. Requires NumPy 1.26.4,
FFmpeg and FFprobe. Run on Linux/WSL; --workspace is the common parent folder.
"""
import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import re
import subprocess
import sys
import wave

parser = argparse.ArgumentParser()
parser.add_argument('--workspace', type=Path, required=True)
parser.add_argument('--deps', type=Path)
args = parser.parse_args()
if args.deps:
    sys.path.insert(0, str(args.deps))
import numpy as np

ROOT = args.workspace.resolve()
OUT = ROOT / 'build/ink-film-soundtrack'
OUT.mkdir(parents=True, exist_ok=True)
SR = 44100
BPM = 84
BEAT = 60.0 / BPM
BAR = BEAT * 4
SEED = 20261113
TITLE = 'Stored in the Dark'
PROGRESSION = [
    {'name': 'Dm(add9)', 'bass': 38, 'notes': [50, 57, 60, 64, 65]},
    {'name': 'Bbmaj7', 'bass': 34, 'notes': [46, 53, 57, 62, 65]},
    {'name': 'Gm(add9)', 'bass': 31, 'notes': [43, 50, 57, 58, 62]},
    {'name': 'A7sus(b9)', 'bass': 33, 'notes': [45, 52, 55, 58, 62]},
]

def run(argv):
    return subprocess.run(argv, check=True, stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, text=True)

def sha(path):
    h = hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda: f.read(1048576), b''):
            h.update(block)
    return h.hexdigest()

def probe(path):
    return json.loads(run(['ffprobe', '-v', 'error', '-count_frames',
        '-show_streams', '-show_format', '-of', 'json', str(path)]).stdout)

def midi(note):
    return 440.0 * 2.0 ** ((note - 69) / 12.0)

def curve(t, duration):
    # Gentle builds followed by breaths; never a continuously rising alarm.
    return np.interp(t / duration,
        [0, .08, .23, .35, .43, .57, .66, .80, .91, 1],
        [.44, .54, .74, .83, .51, .77, .53, .85, .72, .38])

def synth(duration, seed, cue_times):
    rng = np.random.default_rng(seed)
    mix = np.zeros((round(duration * SR), 2), dtype=np.float32)
    events = {'padVoices': 0, 'bassPulses': 0, 'plucks': 0,
              'ticks': 0, 'swells': 0}

    def place(sig, start, amp, pan=0):
        pos = round(start * SR)
        if pos < 0 or pos >= len(mix):
            return
        count = min(len(sig), len(mix) - pos)
        theta = (pan + 1) * math.pi / 4
        sig = np.asarray(sig[:count] * amp, dtype=np.float32)
        mix[pos:pos+count, 0] += sig * math.cos(theta)
        mix[pos:pos+count, 1] += sig * math.sin(theta)

    def pad(start, duration, note, amp, pan, phase):
        t = np.arange(round(duration * SR), dtype=np.float64) / SR
        f = midi(note)
        signal = np.zeros(len(t), dtype=np.float64)
        # A softened, slightly detuned bowed spectrum; deliberately little top end.
        for k in range(1, 7):
            signal += np.sin(2*np.pi*f*k*t + phase) / k**1.8
            signal += .27*np.sin(2*np.pi*f*k*1.0017*t + phase*.7) / k**1.8
            signal += .23*np.sin(2*np.pi*f*k*.9989*t + phase*.3) / k**1.8
        env = np.minimum(t/1.7, 1)**2 * np.minimum((duration-t)/2.7, 1)**2
        env *= .88 + .12*np.sin(2*np.pi*.13*t + phase)
        place(signal * env, start, amp, pan)
        events['padVoices'] += 1

    chord_len = BAR * 4
    for index, start in enumerate(np.arange(0, duration, chord_len)):
        chord = PROGRESSION[index % 4]
        energy = float(curve(start + chord_len/2, duration))
        for voice, note in enumerate(chord['notes']):
            pad(start, chord_len + 2.0, note, .0088*energy,
                [-.65, .4, -.2, .7, .05][voice], .61*voice + .19*index)

    # Soft ostinato: low rounded pulses, with sparse anticipation at bar ends.
    for index, start in enumerate(np.arange(0, duration, BEAT)):
        chord = PROGRESSION[int(start/chord_len) % 4]
        energy = float(curve(start, duration))
        note = chord['bass'] + (12 if index % 8 == 6 else 0)
        t = np.arange(round(.53*SR), dtype=np.float64) / SR
        f = midi(note)
        signal = (np.sin(2*np.pi*f*t + .21*np.exp(-t*35))
                  + .20*np.sin(2*np.pi*2*f*t) + .07*np.sin(2*np.pi*3*f*t))
        env = (1-np.exp(-t*150))*np.exp(-t*9.5)
        place(signal*env, start, .063*energy*(1 if index%4==0 else .73), 0)
        events['bassPulses'] += 1

    # Short warm plucks, changing with the harmony. Long gaps leave room for text.
    patterns = [[0, 2, 1, 3, 2, 4, 1, 2], [0, 1, 3, 2, 4, 2, 1, 3]]
    for index, start in enumerate(np.arange(12, duration-6, BEAT/2)):
        chord_index = int(start/chord_len)
        chord = PROGRESSION[chord_index % 4]
        energy = float(curve(start, duration))
        if index % 16 in (7, 15) or (energy < .6 and index % 2):
            continue
        note = chord['notes'][patterns[(chord_index//4)%2][index%8]] + 12
        t = np.arange(round(.64*SR), dtype=np.float64) / SR
        f = midi(note)
        signal = np.sin(2*np.pi*f*t + .55*np.exp(-t*9)*np.sin(2*np.pi*f*2*t))
        signal += .20*np.sin(2*np.pi*2*f*t)*np.exp(-t*8)
        env = (1-np.exp(-t*350))*np.exp(-t*8.5)
        pan = .34 if index%2 else -.34
        amp = .017*energy
        place(signal*env, start, amp, pan)
        place(signal*env, start + BEAT*.75, amp*.27, -pan)
        place(signal*env, start + BEAT*1.5, amp*.13, pan)
        events['plucks'] += 1

    # Tiny brushed/metallic ticks, alternating stereo, never an alarm beep.
    for index, start in enumerate(np.arange(4, duration-4, BEAT/2)):
        if index%8 == 7:
            continue
        t = np.arange(round(.072*SR), dtype=np.float64) / SR
        noise = rng.normal(0, .8, len(t))
        noise = np.convolve(noise, np.ones(7)/7, mode='same')
        signal = .55*noise + .28*np.sin(2*np.pi*1831*t) + .12*np.sin(2*np.pi*2473*t)
        env = np.minimum(t/.002, 1)*np.exp(-t*78)
        amp = .011*float(curve(start, duration))*(1 if index%2 else .6)
        place(signal*env, start, amp, -.5 if index%2 else .5)
        events['ticks'] += 1

    # Airy transition swells. Smooth low-pass noise plus a quiet bowed fifth.
    for cue in cue_times:
        start = max(0, cue-3.5)
        dur = 5.8
        t = np.arange(round(dur*SR), dtype=np.float64)/SR
        noise = rng.normal(0, 1, len(t))
        noise = np.convolve(noise, np.hanning(71)/np.hanning(71).sum(), mode='same')
        env = np.sin(np.pi*t/dur)**2
        signal = .8*noise + .05*np.sin(2*np.pi*220*t)
        place(signal*env, start, .035, -.15)
        events['swells'] += 1

    # Four-second fade-in, seven-second fade-out; chapter breaths are smooth.
    t = np.arange(len(mix), dtype=np.float64)/SR
    final_env = np.minimum(t/4, 1)**1.3 * np.minimum((duration-t)/7, 1)**1.4
    for cue in cue_times:
        final_env *= 1 - .23*np.exp(-((t-cue)/2.1)**2)
    mix *= final_env[:, None].astype(np.float32)
    peak = float(np.max(np.abs(mix)))
    mix *= .65/max(peak, .00001)
    return mix, events

def write_wav(path, audio):
    data = np.clip(audio * 32767, -32768, 32767).astype('<i2')
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(SR)
        out.writeframes(data.tobytes())

def loudness(path):
    proc = run(['ffmpeg', '-hide_banner', '-i', str(path), '-vn', '-af',
        'loudnorm=I=-19:TP=-2:LRA=8:print_format=json', '-f', 'null', '-'])
    return json.loads(re.findall(r'\{\s*"input_i"[\s\S]*?\}', proc.stderr)[-1])

def video_hash(path):
    # Canonical elementary H264 hash proves encoded frames unchanged by muxing.
    return run(['ffmpeg', '-v', 'error', '-i', str(path), '-map', '0:v:0',
        '-c:v', 'copy', '-bsf:v', 'h264_mp4toannexb', '-f', 'hash',
        '-hash', 'sha256', '-']).stdout.strip()

films = [
    ('crawl', ROOT/'build/crazy-box-explainer/crazy-box-handoff.mp4',
     [31, 63, 84, 99, 114]),
    ('vpu', ROOT/'reference-sm64-wmotr-abc-proof/SSL-Coq/less-than-one-a-press/docs/media/ink-vpu-actions/ink-vpu-actions.mp4',
     [54, 84, 110, 148, 189, 213, 237]),
]
receipts = []
for index, (name, original, cues) in enumerate(films):
    before = probe(original)
    video = next(s for s in before['streams'] if s['codec_type']=='video')
    duration = float(video['duration'])
    print('Composing', name, duration, flush=True)
    music, events = synth(duration, SEED + index, cues)
    source = OUT / (name+'-score-source.wav')
    write_wav(source, music)
    del music
    measured = loudness(source)
    norm = ('highpass=f=38,lowpass=f=6500,'
            'loudnorm=I=-19:TP=-2:LRA=8:measured_I={input_i}:'
            'measured_TP={input_tp}:measured_LRA={input_lra}:'
            'measured_thresh={input_thresh}:offset={target_offset}:'
            'linear=true:print_format=json').format(**measured)
    # Measure the filtered signal for a true two-pass normalization.
    filtered = OUT / (name+'-score-filtered.wav')
    run(['ffmpeg', '-v', 'error', '-y', '-i', str(source), '-af',
         'highpass=f=38,lowpass=f=6500', str(filtered)])
    measured = loudness(filtered)
    norm = ('loudnorm=I=-19:TP=-2:LRA=8:measured_I={input_i}:'
            'measured_TP={input_tp}:measured_LRA={input_lra}:'
            'measured_thresh={input_thresh}:offset={target_offset}:'
            'linear=true:print_format=json').format(**measured)
    master = OUT / (name+'-score.wav')
    run(['ffmpeg', '-v', 'error', '-y', '-i', str(filtered), '-af', norm,
         '-ar', '48000', '-c:a', 'pcm_s24le', str(master)])
    target = OUT/(name+'-with-music.mp4')
    run(['ffmpeg', '-v', 'error', '-y', '-i', str(original), '-i', str(master),
         '-map', '0:v:0', '-map', '1:a:0', '-c:v', 'copy', '-c:a', 'aac',
         '-b:a', '192k', '-ar', '48000', '-t', str(duration),
         '-metadata', 'comment=Original instrumental score: Stored in the Dark. Video stream copied unchanged.',
         '-movflags', '+faststart', str(target)])
    after = probe(target)
    after_video = next(s for s in after['streams'] if s['codec_type']=='video')
    after_audio = next(s for s in after['streams'] if s['codec_type']=='audio')
    assert after_video['nb_read_frames'] == video['nb_read_frames']
    assert after_video['duration'] == video['duration']
    assert abs(float(after_audio['duration'])-duration) < .03
    h_before, h_after = video_hash(original), video_hash(target)
    assert h_before == h_after
    run(['ffmpeg', '-v', 'error', '-i', str(target), '-f', 'null', '-'])
    final_loudness = loudness(target)
    assert -20.1 < float(final_loudness['input_i']) < -17.9
    assert float(final_loudness['input_tp']) < -1.5
    preview = OUT/(name+'-music-preview.m4a')
    run(['ffmpeg', '-v', 'error', '-y', '-ss', '25', '-i', str(master),
         '-t', '20', '-af', 'afade=t=in:d=1,afade=t=out:st=18:d=2',
         '-c:a', 'aac', '-b:a', '192k', str(preview)])
    receipt = dict(name=name, original=str(original.relative_to(ROOT)),
        originalSha256=sha(original), output=target.name, outputSha256=sha(target),
        scoreSourceSha256=sha(source), scoreMasterSha256=sha(master),
        seed=SEED+index, durationSeconds=duration, frameCount=int(video['nb_read_frames']),
        videoCodec=after_video['codec_name'], width=video['width'], height=video['height'],
        fps=video['r_frame_rate'], videoElementarySha256=h_after,
        videoStreamIdentical=True, fullDecodePassed=True,
        audioCodec=after_audio['codec_name'], audioSampleRate=after_audio['sample_rate'],
        audioDurationSeconds=float(after_audio['duration']), audioBitRate=int(after_audio['bit_rate']),
        integratedLUFS=float(final_loudness['input_i']), truePeakDBTP=float(final_loudness['input_tp']),
        loudnessRangeLU=float(final_loudness['input_lra']), cueTimesSeconds=cues,
        events=events, bytes=target.stat().st_size)
    receipts.append(receipt)
    print(json.dumps(receipt), flush=True)

report = dict(schema=1, title=TITLE, composer='Original procedural composition authored for the Ink films',
    sourcePolicy='No downloaded music, samples, existing melody or generated voice.',
    scope='Presentation-only soundtrack editions. No gameplay run, proof, coordinate, input or video-frame changes.',
    tempoBPM=BPM, meter='4/4', tonalCenter='D minor', progression=PROGRESSION,
    soundPalette=['soft detuned bowed pads', 'rounded bass pulse', 'warm delayed plucks',
                  'quiet brushed metallic ticks', 'airy transition swells'],
    sampleRate=SR, outputSampleRate=48000, targetIntegratedLUFS=-19, targetTruePeakDBTP=-2,
    implementationSha256=sha(Path(__file__)), numpyVersion=np.__version__,
    ffmpegVersion=run(['ffmpeg','-version']).stdout.splitlines()[0],
    ffprobeVersion=run(['ffprobe','-version']).stdout.splitlines()[0],
    review='Objective loudness, true-peak, decode, duration and video-bitstream checks. No human listening review claimed.',
    films=receipts)
(OUT/'soundtrack-receipt.json').write_text(json.dumps(report, indent=2)+'\n')
print('DONE', OUT/'soundtrack-receipt.json', flush=True)
