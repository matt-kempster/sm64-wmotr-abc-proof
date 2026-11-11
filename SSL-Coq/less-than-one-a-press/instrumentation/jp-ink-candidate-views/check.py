#!/usr/bin/env python3
"""Validate held render records and inventory; no gameplay claim."""
import hashlib
import json
import pathlib
import re
import sys

capture = pathlib.Path(sys.argv[1]).resolve()
log = (capture / "raw.log").read_text()
renders = [line for line in log.splitlines() if line.startswith("CANDIDATE_RENDER,")]
requests = [line for line in log.splitlines() if line.startswith("CANDIDATE_VIEW,")]
assert len(renders) == 18 and len(requests) == 6
expected_positions = ["-1950,1741,-939", "-1882,1741,-939", "-1882,768,-939"]
shot_frames = list(map(int, re.findall(r"Captured screenshot for frame (\d+)\.", log)))
assert len(shot_frames) == 7 and shot_frames[-1] == 2700
def number(line, name):
    return int(re.search(rf"(?:^|,){name}=(\d+)", line)[1])
receipt = {
    "claim": "Native original-JP render-only visualization; not a gameplay or reachability experiment",
    "rom_sha256": "9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317",
    "capture_latency": "Request on third held render; preceding completed framebuffer has same pose and phase",
    "raw_log_sha256": hashlib.sha256((capture / "raw.log").read_bytes()).hexdigest(),
    "probe_binary_sha256": hashlib.sha256((capture / "probe.so").read_bytes()).hexdigest(),
    "views": []
}
for index in range(6):
    request = requests[index]
    phase, pose = 130 + index % 2, index // 2
    same = renders[3 * index:3 * index + 3]
    request_timer = number(request, "requestTimer")
    assert number(request, "index") == index
    assert number(request, "phase") == phase and number(request, "pose") == pose
    assert number(request, "previousRenderedTimer") == request_timer - 1
    assert shot_frames[index] == request_timer
    for offset, render in enumerate(same):
        assert number(render, "index") == index
        assert number(render, "phase") == phase and number(render, "pose") == pose
        assert number(render, "globalTimer") == request_timer - 2 + offset
        assert f"renderMario=({expected_positions[pose]})" in render
        assert "nativeState=(-5883.07373,1024,819.564392)" in render
        assert number(render, "cutaway") == number(request, "cutaway")
        assert number(render, "topYaw") == [37888, 44032][index % 2]
        expected_top = ["-2047,1778.07104,-1023", "-2087,1783.07104,-1023"][index % 2]
        assert f"renderTop=({expected_top})" in render
    filename = f"super_mario_64-{index:03}.png"
    data = (capture / "shots" / filename).read_bytes()
    assert data.startswith(b"\x89PNG\r\n\x1a\n")
    receipt["views"].append({
        "file": filename, "sha256": hashlib.sha256(data).hexdigest(),
        "render_position": list(map(int, expected_positions[pose].split(","))),
        "top_behavior_phase": phase, "request_frame": request_timer,
        "previous_completed_frame": request_timer - 1,
        "top_render_hidden": bool(number(request, "cutaway"))
    })
(capture / "receipt.json").write_text(json.dumps(receipt, indent=2) + "\n")
(capture / "trace.txt").write_text("\n".join(line for line in log.splitlines()
    if line.startswith(("CANDIDATE_RENDER,", "CANDIDATE_VIEW,"))) + "\n")
print(f"PASS: six held original-ROM visualization captures: {capture}")
