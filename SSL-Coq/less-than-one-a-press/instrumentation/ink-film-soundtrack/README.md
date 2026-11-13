# Original music editions of the Ink films

The soundtrack **Stored in the Dark** is an original procedural instrumental
composition authored for these two films. It uses an 84 BPM pulse in D minor,
with soft detuned bowed pads, a rounded bass ostinato, warm delayed plucks,
quiet brushed metallic ticks, and airy transition swells. Four-bar harmonies
move through Dm(add9), Bbmaj7, Gm(add9), and A7sus(b9). Slow builds and chapter
breaths make it tense without a continuous alarm or loud impacts. Each film
gets its own deterministic arrangement and ending fade.

No downloaded track, audio sample, existing melody or synthesized voice is
used.

This is a presentation-only change. The source videos remain intact. FFmpeg
copies their existing H264 video streams and adds stereo AAC at 192 kb/s;
the canonical elementary H264 SHA256 is checked before and after muxing.
Video duration, frame count, complete decode, audio duration, integrated
loudness and true peak are also checked. Gameplay, supplied-state labels,
commentary, timing, and the proof's route assessment do not change.

The target is −19 LUFS integrated with at least 2 dB true-peak headroom.
Four-second starts and seven-second ending fades avoid abrupt entrances or
exits. Source synthesis uses 44.1 kHz stereo; the final AAC uses 48 kHz.
The preserved receipt records the actual measured results, source/output
hashes, seeds, note-event counts, cue times and tool versions.

## Reproduce

Use Python 3 with **NumPy 1.26.4**, FFmpeg, and FFprobe. The script accepts
the workspace parent containing the proof checkout and the root `build`
folder. In Ubuntu-24.04 WSL:

```sh
python3 instrumentation/ink-film-soundtrack/compose.py \
  --workspace '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof'
```

For the task-local extracted NumPy wheel, add:

```sh
  --deps '/mnt/c/Users/tariq/OneDrive/Documents/sm64 - the item-grab proof/build/ink-film-soundtrack/python-deps'
```

The wheel is the official CPython 3.12 Linux x86_64 NumPy 1.26.4 wheel, SHA256
`675d61ffbfa78604709862923189bad94014bef562cc35cf61d3a07bba02a7ed`.
The implementation does not modify a global Python, proof, or emulator
environment. The local virtual-environment setup was unavailable because
`ensurepip` was missing, so the pinned wheel was hash-checked and extracted
only into this task's ignored build folder.

Required silent source videos:

- Workspace `build/crazy-box-explainer/crazy-box-handoff.mp4`.
- Proof `SSL-Coq/less-than-one-a-press/docs/media/ink-vpu-actions/ink-vpu-actions.mp4`.

The first film's original renderer, storyboard and checks are separately
preserved under `source-crawl/`. Restore the original silent film to its
listed path before running this exact script on another checkout. No ROM
or gameplay re-execution is needed to add the score.

Outputs are in workspace `build/ink-film-soundtrack/`:

- `crawl-with-music.mp4` and `vpu-with-music.mp4`.
- `crawl-score.wav` and `vpu-score.wav`, normalized 24-bit masters.
- `*-score-source.wav` and `*-score-filtered.wav`, reproducible intermediate audio.
- `*-music-preview.m4a`, 20-second excerpts from each score.
- `soundtrack-receipt.json`, the measured results and provenance.

The master/intermediate WAVs and downloaded dependency remain local build
outputs. The final films, receipt and composition script are the durable
deliverables. Different FFmpeg versions may change AAC bytes, while the
canonical video-stream identity check must still pass.

Checks are objective signal/format/provenance checks. No human listening
review is claimed. The short previews are available for direct listening.
