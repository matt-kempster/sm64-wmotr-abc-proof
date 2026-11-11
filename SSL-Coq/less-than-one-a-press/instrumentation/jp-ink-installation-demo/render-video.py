"""Encode selected original emulator frames with captions in separate margins."""

import argparse
import json
from pathlib import Path
import subprocess
from tempfile import TemporaryDirectory


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("screenshots", type=Path)
    parser.add_argument("timeline", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--title", default="Ink Installation  |  Original Japanese ROM")
    args = parser.parse_args()
    shots = sorted(args.screenshots.glob("super_mario_64-*.png"),
                   key=lambda shot: int(shot.stem.rsplit("-", 1)[1]))
    timeline = json.loads(args.timeline.read_text(encoding="utf-8"))
    font = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    extra_lines = max(event["detail"].count("\n")
                      for section in timeline for event in section["captions"])
    extra_height = 24 * extra_lines
    with TemporaryDirectory(prefix="ink-render-", dir=args.output.parent) as tmp:
        folder = Path(tmp)
        filters = [f"pad=iw:ih+{140 + extra_height}:0:58:color=0x10151e"]

        def caption(name, label, y, size, first=None, last=None, color="white"):
            (folder / f"{name}.txt").write_text(label, encoding="utf-8")
            overlay = (f"drawtext=fontfile={font}:textfile={name}.txt:expansion=none:"
                       f"fontsize={size}:fontcolor={color}:x=(w-tw)/2:y={y}:line_spacing=6")
            if first is not None:
                overlay += f":enable='between(n,{first},{last})'"
            filters.append(overlay)

        caption("title", args.title, 16, 23)
        next_frame = 0
        for index, section in enumerate(timeline):
            start, stop = section["start"], section["stop"]
            repetitions = section.get("repetitions", 1)
            first_frame = next_frame
            if stop > len(shots):
                raise ValueError("A requested screenshot is missing")
            for shot in shots[start:stop]:
                for _ in range(repetitions):
                    (folder / f"{next_frame:05}.png").symlink_to(shot.resolve())
                    next_frame += 1
            for event_index, event in enumerate(section["captions"]):
                first = first_frame + event["start"] * repetitions
                last = first_frame + event["stop"] * repetitions - 1
                name = f"section-{index}-{event_index}"
                caption(name, event["headline"], f"h-{67 + extra_height}", 21, first, last)
                caption(name + "-detail", event["detail"], f"h-{35 + extra_height}", 16, first, last,
                        color="0xb8c4d6")
        subprocess.run([
            "ffmpeg", "-nostdin", "-hide_banner", "-loglevel", "warning", "-y",
            "-framerate", "30", "-i", "%05d.png", "-vf", ",".join(filters),
            "-c:v", "libx264", "-crf", "18", "-preset", "medium", "-pix_fmt", "yuv420p",
            "-movflags", "+faststart", str(args.output.resolve()),
        ], cwd=folder, check=True)


if __name__ == "__main__":
    main()
