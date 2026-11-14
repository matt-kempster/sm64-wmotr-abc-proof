"""Bounded source-mesh coverage check, not a native engine execution.

Usage: python check_static_pad_cover.py PATH_TO_DECOMPILE
The deliberately enlarged integer rectangle contains the 107-unit neighborhood
of the pad and the neighboring truncation-to-integer coordinates.
"""
import hashlib
import json
import re
import sys
from collections import Counter
from pathlib import Path

root = Path(sys.argv[1])
source = root / "levels/ssl/areas/1/collision.inc.c"
data = source.read_bytes()
vertices = []
faces = []
kind = None
for line_no, line in enumerate(data.decode().splitlines(), 1):
    match = re.search(r"COL_VERTEX\((-?\d+), (-?\d+), (-?\d+)\)", line)
    if match:
        vertices.append(tuple(map(int, match.groups())))
    match = re.search(r"COL_TRI_INIT\((\w+),", line)
    if match:
        kind = match.group(1)
    match = re.search(r"COL_TRI\((\d+), (\d+), (\d+)\)", line)
    if not match:
        continue
    ids = tuple(map(int, match.groups()))
    points = [vertices[i] for i in ids]
    heights = {p[1] for p in points}
    if len(heights) != 1 or next(iter(heights)) not in (768, 1280):
        continue
    if not all(-2559 <= p[0] <= -1535 and -1535 <= p[2] <= -511
               for p in points):
        continue
    a, b, c = points
    ny = (b[2] - a[2]) * (c[0] - b[0]) - (b[0] - a[0]) * (c[2] - b[2])
    if ny > 0:
        faces.append(dict(line=line_no, ids=ids, points=points, type=kind,
                          height=a[1]))


def contains(face, x, z):
    a, b, c = face["points"]
    return all((p[2] - z) * (q[0] - p[0])
               - (p[0] - x) * (q[2] - p[2]) >= 0
               for p, q in ((a, b), (b, c), (c, a)))


counts = Counter()
misses = []
for x in range(-2260, -1830 + 1):
    for z in range(-1240, -810 + 1):
        heights = sorted({f["height"] for f in faces if contains(f, x, z)})
        counts[",".join(map(str, heights)) or "none"] += 1
        if not heights:
            misses.append([x, z])

result = dict(
    evidence="finite integer source-mesh coverage; no engine execution",
    source=str(source.relative_to(root)),
    sha256=hashlib.sha256(data).hexdigest(),
    x_inclusive=[-2260, -1830], z_inclusive=[-1240, -810],
    points_checked=sum(counts.values()), coverage_counts=dict(counts),
    misses=misses, faces=faces,
    query_y_examples={"25000": 25000, "67277": 1741},
    both_query_y_values_at_least_1280_minus_78=True,
    caveat="Does not execute surface loading, list selection, wall correction, "
           "action handlers, warp scheduling or any controller history.",
)
print(json.dumps(result, indent=2))
assert faces and not misses
assert all(f["type"] not in ("SURFACE_CAMERA_BOUNDARY", "SURFACE_INTANGIBLE")
           for f in faces)
