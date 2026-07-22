#!/usr/bin/env python3
"""Summarize SSL Area 2 collision facts relevant to BLJ recycle setups.

The script intentionally reports small, source-backed mesh certificates instead
of trying to become a collision engine.  Its output is used as an audit aid for
the Coq model in this folder.
"""

from __future__ import annotations

import argparse
import math
import re
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Triangle:
    line: int
    surface: str
    indices: tuple[int, int, int]
    points: tuple[tuple[int, int, int], tuple[int, int, int], tuple[int, int, int]]
    normal: tuple[float, float, float]

    @property
    def bbox(self) -> tuple[int, int, int, int, int, int]:
        xs = [point[0] for point in self.points]
        ys = [point[1] for point in self.points]
        zs = [point[2] for point in self.points]
        return min(xs), max(xs), min(ys), max(ys), min(zs), max(zs)

    @property
    def is_floor_like(self) -> bool:
        return abs(self.normal[1]) > 0.9

    @property
    def is_sloped_floor_like(self) -> bool:
        return 0.1 < abs(self.normal[1]) < 0.99 and self.bbox[3] > self.bbox[2]

    @property
    def is_in_area2_bounds(self) -> bool:
        min_x, max_x, _min_y, _max_y, min_z, max_z = self.bbox
        return max(abs(min_x), abs(max_x), abs(min_z), abs(max_z)) <= 8192


def triangle_normal(
    points: tuple[tuple[int, int, int], tuple[int, int, int], tuple[int, int, int]],
) -> tuple[float, float, float]:
    ax, ay, az = points[0]
    bx, by, bz = points[1]
    cx, cy, cz = points[2]
    ux, uy, uz = bx - ax, by - ay, bz - az
    vx, vy, vz = cx - ax, cy - ay, cz - az
    nx = uy * vz - uz * vy
    ny = uz * vx - ux * vz
    nz = ux * vy - uy * vx
    norm = math.sqrt(nx * nx + ny * ny + nz * nz) or 1.0
    return nx / norm, ny / norm, nz / norm


def point_in_triangle_xz(point: tuple[int, int], triangle: Triangle) -> bool:
    """Match find_floor_from_list's three projected edge tests."""
    x, z = point
    projected = [(vertex[0], vertex[2]) for vertex in triangle.points]
    for index, (x1, z1) in enumerate(projected):
        x2, z2 = projected[(index + 1) % 3]
        if (z1 - z) * (x2 - x1) - (x1 - x) * (z2 - z1) < 0:
            return False
    return True


def parse_collision(path: Path) -> tuple[list[tuple[int, int, int]], list[Triangle]]:
    vertices: list[tuple[int, int, int]] = []
    triangles: list[Triangle] = []
    surface = "SURFACE_UNKNOWN"
    vertex_re = re.compile(r"COL_VERTEX\((-?\d+),\s*(-?\d+),\s*(-?\d+)\)")
    tri_init_re = re.compile(r"COL_TRI_INIT\(([^,]+),\s*(\d+)\)")
    tri_re = re.compile(
        r"COL_TRI(?:_SPECIAL)?\((\d+),\s*(\d+),\s*(\d+)(?:,\s*[^)]*)?\)"
    )

    for line_no, line in enumerate(path.read_text().splitlines(), 1):
        vertex_match = vertex_re.search(line)
        if vertex_match:
            vertices.append(tuple(map(int, vertex_match.groups())))
            continue

        tri_init_match = tri_init_re.search(line)
        if tri_init_match:
            surface = tri_init_match.group(1)
            continue

        tri_match = tri_re.search(line)
        if tri_match:
            indices = tuple(map(int, tri_match.groups()))
            points = tuple(vertices[index] for index in indices)
            triangles.append(
                Triangle(
                    line=line_no,
                    surface=surface,
                    indices=indices,
                    points=points,
                    normal=triangle_normal(points),
                )
            )

    return vertices, triangles


def print_horizontal_levels(triangles: list[Triangle]) -> None:
    levels: dict[int, list[Triangle]] = defaultdict(list)
    for triangle in triangles:
        min_y = triangle.bbox[2]
        max_y = triangle.bbox[3]
        if triangle.is_floor_like and min_y == max_y:
            levels[min_y].append(triangle)

    print("horizontal floor-like levels with at least two triangles:")
    for y in sorted(levels):
        tris = levels[y]
        if len(tris) < 2:
            continue
        xs = [point[0] for tri in tris for point in tri.points]
        zs = [point[2] for tri in tris for point in tri.points]
        print(
            f"  y={y:5d} tris={len(tris):3d} "
            f"x=[{min(xs):5d},{max(xs):5d}] z=[{min(zs):5d},{max(zs):5d}]"
        )


def print_narrow_tread_rectangles(triangles: list[Triangle]) -> None:
    rectangles: set[tuple[int, int, int, int, int]] = set()
    for triangle in triangles:
        min_x, max_x, min_y, max_y, min_z, max_z = triangle.bbox
        if not triangle.is_floor_like or min_y != max_y:
            continue
        width_x = max_x - min_x
        width_z = max_z - min_z
        if width_x > 1200 or width_z > 1200:
            continue
        if not triangle.is_in_area2_bounds:
            continue
        rectangles.add((min_y, min_x, max_x, min_z, max_z))

    print("narrow horizontal tread rectangles inside modeled Area 2 bounds:")
    for y, min_x, max_x, min_z, max_z in sorted(rectangles):
        print(
            f"  y={y:5d} x=[{min_x:5d},{max_x:5d}] "
            f"z=[{min_z:5d},{max_z:5d}]"
        )


def print_stair_candidates(triangles: list[Triangle], limit: int) -> None:
    candidates = [
        triangle
        for triangle in triangles
        if triangle.is_sloped_floor_like and triangle.is_in_area2_bounds
    ]
    print("sloped floor-like candidates inside modeled Area 2 bounds:")
    for tri in sorted(candidates, key=lambda item: item.bbox)[:limit]:
        min_x, max_x, min_y, max_y, min_z, max_z = tri.bbox
        nx, ny, nz = tri.normal
        print(
            f"  line={tri.line:4d} {tri.surface:28s} idx={tri.indices} "
            f"x=[{min_x:5d},{max_x:5d}] y=[{min_y:5d},{max_y:5d}] "
            f"z=[{min_z:5d},{max_z:5d}] "
            f"normal=({nx:+.3f},{ny:+.3f},{nz:+.3f})"
        )


def print_vertex_band(vertices: list[tuple[int, int, int]]) -> None:
    interesting = [
        (index, point)
        for index, point in enumerate(vertices)
        if -700 <= point[0] <= 700 and -4200 <= point[2] <= -3300
    ]
    print("lower-entry stair-band vertices:")
    for index, (x, y, z) in interesting:
        print(f"  v{index:04d}=({x:5d},{y:5d},{z:5d})")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("collision", type=Path)
    parser.add_argument("--limit", type=int, default=80)
    args = parser.parse_args()

    vertices, triangles = parse_collision(args.collision)
    print(f"vertices={len(vertices)} triangles={len(triangles)}")
    print_horizontal_levels(triangles)
    print()
    print_narrow_tread_rectangles(triangles)
    print()
    print_vertex_band(vertices)
    print()
    print_stair_candidates(triangles, args.limit)


if __name__ == "__main__":
    main()
