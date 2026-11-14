# User-supplied Fly Guy video review

This package records a visual review of the user's *The B Button Challenge*
attachment. It supplies a manipulation lead, not a controller replay or an
A-free SSL witness. The source video and extracted images are not redistributed.

Run from the SSL project root with the user's original file available:

```powershell
python instrumentation/ink-flyguy-video-review/inspect.py 'C:/Users/tariq/Downloads/YTDown.com_YouTube_Media__IuC9Ci57Hs_The-B-Button-Challenge_001_1080p.mp4' --ffmpeg 'C:/Users/tariq/AppData/Local/Overwolf/Extensions/ncfplpkmiejjaklknfnkgcpapnhkggmlcppckhcb/315.0.15/obs/bin/64bit/ffmpeg.exe' --output build/ink-flyguy-video-review-fresh
```

The extractor refuses to overwrite existing frames. It requests one decoded
frame at each timestamp in `inspect.py`, hashes the input and frames, and writes
`frame-receipt.json` under the requested ignored output directory. Use a fresh
directory for reproduction. Other FFmpeg versions may encode JPEG bytes
differently; the input-video hash and requested seek times remain authoritative.

Metadata was obtained with Ubuntu-24.04's `ffprobe` using
`-show_entries format=duration,size:stream=index,codec_name,codec_type,width,height,r_frame_rate -of json`.
The Windows Overwolf FFmpeg build supplied the actual extracted images.

The local inspection also used two coarse sheets with filter
`fps=1/15,scale=320:-1,tile=5x6`. Their indices are only a navigation aid;
the exact-seek files support the timestamped report. An initial WSL shell-quoting
attempt failed, and the Windows build lacks `drawtext`; neither failed command
produced an inspected final artifact. The resulting successful extractor avoids
shell-built filter quoting.

Read [the timestamped review](../../docs/notes/ink-flyguy-video-review.md).
The important limitations are deliberate: no audio transcription, no full
frame-by-frame input reconstruction, no authenticated source ROM, and no
claim that the long-jump/sliding-jump/BLJ demonstrations are A-free.
