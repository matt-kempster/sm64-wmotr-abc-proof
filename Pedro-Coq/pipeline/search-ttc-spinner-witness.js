#!/usr/bin/env node
"use strict";

// Witness discovery only. The accepted witness is restated and proved in Coq
// from the same generated initializers; this script is not part of the TCB.

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");

function definitionBody(file, name) {
  const text = fs.readFileSync(path.join(root, file), "utf8");
  const start = text.indexOf(`Definition ${name} :=`);
  if (start < 0) throw new Error(`missing ${name} in ${file}`);
  const end = text.indexOf("\n|}.", start);
  if (end < 0) throw new Error(`unterminated ${name} in ${file}`);
  return text.slice(start, end);
}

function int16Initializers(file, name) {
  const body = definitionBody(file, name);
  const values = [];
  const pattern = /Init_int16 \(Int\.repr (?:(-?\d+)|\((-?\d+)\))\)/g;
  for (const match of body.matchAll(pattern)) {
    const value = Number(match[1] === undefined ? match[2] : match[1]);
    values.push((value << 16) >> 16);
  }
  return values;
}

function float32Initializers(file, name) {
  const body = definitionBody(file, name);
  const values = [];
  const pattern = /Init_float32 \(Float32\.of_bits \(Int\.repr (?:(-?\d+)|\((-?\d+)\))\)\)/g;
  const buffer = new ArrayBuffer(4);
  const view = new DataView(buffer);
  for (const match of body.matchAll(pattern)) {
    const bits = Number(match[1] === undefined ? match[2] : match[1]);
    view.setUint32(0, bits >>> 0, false);
    values.push(view.getFloat32(0, false));
  }
  return values;
}

const f32 = Math.fround;
const fadd = (a, b) => f32(f32(a) + f32(b));
const fmul = (a, b) => f32(f32(a) * f32(b));

const collisionWords = int16Initializers(
  "generated/us_ttc_spinner_collision.v",
  "v_ttc_seg7_collision_rotating_clock_platform2",
);
const macroWords = int16Initializers(
  "generated/us_ttc_area1_macro.v",
  "v_ttc_seg7_macro_objs",
);
const sineTable = float32Initializers(
  "generated/us_math_util.v",
  "v_gSineTable",
);

if (collisionWords.length !== 170) {
  throw new Error(`expected 170 collision words, found ${collisionWords.length}`);
}
if (sineTable.length !== 5120) {
  throw new Error(`expected 5120 sine-table entries, found ${sineTable.length}`);
}

const vertexCount = collisionWords[1];
const sourceVertices = [];
for (let index = 0; index < vertexCount; index += 1) {
  const offset = 2 + index * 3;
  sourceVertices.push(collisionWords.slice(offset, offset + 3));
}

let cursor = 2 + vertexCount * 3;
const sourceTriangles = [];
while (collisionWords[cursor] !== 65) {
  const surfaceType = collisionWords[cursor++];
  const triangleCount = collisionWords[cursor++];
  for (let index = 0; index < triangleCount; index += 1) {
    sourceTriangles.push({
      surfaceType,
      indices: collisionWords.slice(cursor, cursor + 3),
    });
    cursor += 3;
  }
}

const spinners = [];
for (let offset = 0; offset + 4 < macroWords.length; offset += 5) {
  const head = macroWords[offset];
  if (((head & 0xffff) & 0x1ff) !== 356) continue;
  spinners.push({
    record: offset / 5,
    yaw: (head & 0xffff) & 0xfe00,
    x: macroWords[offset + 1],
    y: macroWords[offset + 2],
    z: macroWords[offset + 3],
  });
}

if (spinners.length !== 14) {
  throw new Error(`expected 14 spinner placements, found ${spinners.length}`);
}

function trig(angle) {
  const index = (angle & 0xffff) >>> 4;
  return { sin: sineTable[index], cos: sineTable[index + 0x400] };
}

function terrainCast(value) {
  return (Math.trunc(value) << 16) >> 16;
}

function transformVertex(vertex, spinner, pitch) {
  const px = trig(pitch);
  const py = trig(spinner.yaw);
  const sx = px.sin;
  const cx = px.cos;
  const sy = py.sin;
  const cy = py.cos;

  const m00 = cy;
  const m10 = fmul(sx, sy);
  const m20 = fmul(cx, sy);
  const m01 = f32(0);
  const m11 = cx;
  const m21 = f32(-sx);
  const m02 = f32(-sy);
  const m12 = fmul(sx, cy);
  const m22 = fmul(cx, cy);

  const [vx, vy, vz] = vertex.map(f32);
  const x = fadd(
    fadd(fadd(fmul(vx, m00), fmul(vy, m10)), fmul(vz, m20)),
    f32(spinner.x),
  );
  const y = fadd(
    fadd(fadd(fmul(vx, m01), fmul(vy, m11)), fmul(vz, m21)),
    f32(spinner.y),
  );
  const z = fadd(
    fadd(fadd(fmul(vx, m02), fmul(vy, m12)), fmul(vz, m22)),
    f32(spinner.z),
  );
  return [terrainCast(x), terrainCast(y), terrainCast(z)];
}

function cross(a, b, c) {
  const x = (b[1] - a[1]) * (c[2] - b[2]) - (b[2] - a[2]) * (c[1] - b[1]);
  const y = (b[2] - a[2]) * (c[0] - b[0]) - (b[0] - a[0]) * (c[2] - b[2]);
  const z = (b[0] - a[0]) * (c[1] - b[1]) - (b[1] - a[1]) * (c[0] - b[0]);
  return [x, y, z];
}

function polygonArea(polygon) {
  let twice = 0;
  for (let i = 0; i < polygon.length; i += 1) {
    const a = polygon[i];
    const b = polygon[(i + 1) % polygon.length];
    twice += a[0] * b[1] - a[1] * b[0];
  }
  return twice / 2;
}

function lineIntersection(a, b, c, d) {
  const abx = b[0] - a[0];
  const abz = b[1] - a[1];
  const cdx = d[0] - c[0];
  const cdz = d[1] - c[1];
  const denominator = abx * cdz - abz * cdx;
  if (Math.abs(denominator) < 1e-12) return b;
  const t = ((c[0] - a[0]) * cdz - (c[1] - a[1]) * cdx) / denominator;
  return [a[0] + t * abx, a[1] + t * abz];
}

function clipPolygon(subject, clip) {
  let output = subject.slice();
  const sign = polygonArea(clip) >= 0 ? 1 : -1;
  for (let edge = 0; edge < clip.length; edge += 1) {
    const c = clip[edge];
    const d = clip[(edge + 1) % clip.length];
    const input = output;
    output = [];
    if (input.length === 0) break;
    const inside = (p) =>
      sign * ((d[0] - c[0]) * (p[1] - c[1]) - (d[1] - c[1]) * (p[0] - c[0])) >= -1e-7;
    for (let index = 0; index < input.length; index += 1) {
      const a = input[index];
      const b = input[(index + 1) % input.length];
      const ain = inside(a);
      const bin = inside(b);
      if (ain && bin) output.push(b);
      else if (ain && !bin) output.push(lineIntersection(a, b, c, d));
      else if (!ain && bin) {
        output.push(lineIntersection(a, b, c, d));
        output.push(b);
      }
    }
  }
  return output;
}

function pointInsideConvex(point, polygon) {
  const sign = polygonArea(polygon) >= 0 ? 1 : -1;
  for (let index = 0; index < polygon.length; index += 1) {
    const a = polygon[index];
    const b = polygon[(index + 1) % polygon.length];
    const side = sign *
      ((b[0] - a[0]) * (point[1] - a[1]) -
       (b[1] - a[1]) * (point[0] - a[0]));
    if (side <= 0) return false;
  }
  return true;
}

function surfaceHeight(surface, x, z) {
  const [nx, ny, nz] = surface.normal;
  const [vx, vy, vz] = surface.vertices[0];
  return vy - (nx * (x - vx) + nz * (z - vz)) / ny;
}

function surfacesAtPitch(pitch) {
  return spinners.map((spinner, spinnerIndex) => {
    const vertices = sourceVertices.map((vertex) =>
      transformVertex(vertex, spinner, pitch));
    return sourceTriangles.map((triangle, triangleIndex) => {
      const points = triangle.indices.map((index) => vertices[index]);
      const normal = cross(points[0], points[1], points[2]);
      const magnitude = Math.hypot(...normal);
      const normalY = normal[1] / magnitude;
      const projection = points.map((point) => [point[0], point[2]]);
      const xs = projection.map((point) => point[0]);
      const zs = projection.map((point) => point[1]);
      return {
        spinnerIndex,
        triangleIndex,
        surfaceType: triangle.surfaceType,
        vertices: points,
        projection,
        bounds: {
          minX: Math.min(...xs),
          maxX: Math.max(...xs),
          minZ: Math.min(...zs),
          maxZ: Math.max(...zs),
        },
        normal,
        normalY,
      };
    });
  });
}

function candidateAtPitch(pitch) {
  const objects = surfacesAtPitch(pitch);
  let best = null;
  for (let floorObject = 0; floorObject < objects.length; floorObject += 1) {
    for (const floor of objects[floorObject]) {
      if (!(floor.normalY > 0.01)) continue;
      for (let ceilingObject = 0; ceilingObject < objects.length; ceilingObject += 1) {
        if (ceilingObject === floorObject) continue;
        const floorSpinner = spinners[floorObject];
        const ceilingSpinner = spinners[ceilingObject];
        const dx = floorSpinner.x - ceilingSpinner.x;
        const dz = floorSpinner.z - ceilingSpinner.z;
        if (dx * dx + dz * dz > 1000 * 1000) continue;
        if (Math.abs(floorSpinner.y - ceilingSpinner.y) > 1000) continue;
        for (const ceiling of objects[ceilingObject]) {
          if (!(ceiling.normalY < -0.01)) continue;
          if (floor.bounds.maxX < ceiling.bounds.minX ||
              ceiling.bounds.maxX < floor.bounds.minX ||
              floor.bounds.maxZ < ceiling.bounds.minZ ||
              ceiling.bounds.maxZ < floor.bounds.minZ) continue;
          const overlap = clipPolygon(floor.projection, ceiling.projection);
          const area = Math.abs(polygonArea(overlap));
          if (overlap.length < 3 || area < 4) continue;
          const centroid = overlap.reduce(
            (sum, point) => [sum[0] + point[0] / overlap.length, sum[1] + point[1] / overlap.length],
            [0, 0],
          );
          const samples = overlap.concat([centroid]);
          for (const [x, z] of samples) {
            const floorY = surfaceHeight(floor, x, z);
            const ceilingY = surfaceHeight(ceiling, x, z);
            const gap = ceilingY - floorY;
            if (!(gap >= 2 && gap <= 160)) continue;
            const edgeMargin = Math.min(gap - 2, 160 - gap);
            const score = Math.min(area, 10000) + edgeMargin * 100;
            if (best === null || score > best.score) {
              best = {
                pitch,
                floorObject,
                floorTriangle: floor.triangleIndex,
                ceilingObject,
                ceilingTriangle: ceiling.triangleIndex,
                x,
                z,
                floorY,
                ceilingY,
                gap,
                area,
                score,
              };
            }
          }
        }
      }
    }
  }
  return best;
}

const groups = [];
let active = null;
let matchCount = 0;
for (let index = 0; index < 0x1000; index += 1) {
  const pitch = index << 4;
  const candidate = candidateAtPitch(pitch);
  if (candidate === null) {
    if (active !== null) groups.push(active);
    active = null;
    continue;
  }
  matchCount += 1;
  const key = [
    candidate.floorObject,
    candidate.floorTriangle,
    candidate.ceilingObject,
    candidate.ceilingTriangle,
  ].join(":");
  if (active === null || active.key !== key || active.endIndex + 1 !== index) {
    if (active !== null) groups.push(active);
    active = { key, startIndex: index, endIndex: index, best: candidate };
  } else {
    active.endIndex = index;
    if (candidate.score > active.best.score) active.best = candidate;
  }
}
if (active !== null) groups.push(active);

groups.sort((a, b) =>
  (b.endIndex - b.startIndex) - (a.endIndex - a.startIndex) ||
  b.best.score - a.best.score,
);

console.log(`generated collision words: ${collisionWords.length}`);
console.log(`generated sine entries: ${sineTable.length}`);
console.log(`generated spinner placements: ${spinners.length}`);
console.log(`pitch table entries with a Pedro overlap candidate: ${matchCount}`);
for (const group of groups.slice(0, 30)) {
  const best = group.best;
  console.log(JSON.stringify({
    tableIndexInterval: [group.startIndex, group.endIndex],
    pitchInterval: [group.startIndex << 4, group.endIndex << 4],
    floor: [best.floorObject, best.floorTriangle],
    ceiling: [best.ceilingObject, best.ceilingTriangle],
    bestPitch: best.pitch,
    witnessXZ: [Number(best.x.toFixed(4)), Number(best.z.toFixed(4))],
    heights: [Number(best.floorY.toFixed(4)), Number(best.ceilingY.toFixed(4))],
    gap: Number(best.gap.toFixed(4)),
    overlapArea: Number(best.area.toFixed(2)),
  }));
}

// Emit exact TerrainData vertices for the selected top-ranked interval.  A
// single integer X/Z point strictly inside all twelve triangles makes the Coq
// certificate small and avoids trusting polygon clipping in the proof.
if (groups.length > 0) {
  const chosen = groups[0];
  const [floorObject, floorTriangle, ceilingObject, ceilingTriangle] =
    chosen.key.split(":").map(Number);
  const details = [];
  for (let index = chosen.startIndex; index <= chosen.endIndex; index += 1) {
    const surfaces = surfacesAtPitch(index << 4);
    details.push({
      index,
      floor: surfaces[floorObject][floorTriangle],
      ceiling: surfaces[ceilingObject][ceilingTriangle],
    });
  }
  let common = details[0].floor.projection;
  for (const detail of details) {
    common = clipPolygon(common, detail.floor.projection);
    common = clipPolygon(common, detail.ceiling.projection);
  }
  if (common.length < 3) throw new Error("selected interval has no common open overlap");
  const commonCentroid = common.reduce(
    (sum, point) => [sum[0] + point[0] / common.length,
      sum[1] + point[1] / common.length],
    [0, 0],
  );
  let integerWitness = null;
  for (let radius = 0; radius <= 32 && integerWitness === null; radius += 1) {
    for (let dx = -radius; dx <= radius && integerWitness === null; dx += 1) {
      for (let dz = -radius; dz <= radius; dz += 1) {
        const point = [Math.round(commonCentroid[0]) + dx,
          Math.round(commonCentroid[1]) + dz];
        if (details.every((detail) =>
          pointInsideConvex(point, detail.floor.projection) &&
          pointInsideConvex(point, detail.ceiling.projection))) {
          integerWitness = point;
          break;
        }
      }
    }
  }
  if (integerWitness === null) throw new Error("no common integer witness found");
  console.log("exact selected-interval certificate:");
  console.log(JSON.stringify({
    tableIndexInterval: [chosen.startIndex, chosen.endIndex],
    fullPitchInterval: [chosen.startIndex << 4, (chosen.endIndex << 4) + 15],
    floor: [floorObject, floorTriangle],
    ceiling: [ceilingObject, ceilingTriangle],
    floorSourceTriangle: sourceTriangles[floorTriangle],
    ceilingSourceTriangle: sourceTriangles[ceilingTriangle],
    floorSpinner: spinners[floorObject],
    ceilingSpinner: spinners[ceilingObject],
    witnessXZ: integerWitness,
    entries: details.map((detail) => ({
      tableIndex: detail.index,
      floorVertices: detail.floor.vertices,
      ceilingVertices: detail.ceiling.vertices,
      floorNormal: detail.floor.normal,
      ceilingNormal: detail.ceiling.normal,
      floorHeight: surfaceHeight(detail.floor, ...integerWitness),
      ceilingHeight: surfaceHeight(detail.ceiling, ...integerWitness),
      gap: surfaceHeight(detail.ceiling, ...integerWitness) -
        surfaceHeight(detail.floor, ...integerWitness),
    })),
  }, null, 2));

  function fixedPointCertificate(tableIndex) {
    const pitch = tableIndex << 4;
    const floorVertices = sourceTriangles[floorTriangle].indices.map((vertexIndex) =>
      transformVertex(sourceVertices[vertexIndex], spinners[floorObject], pitch));
    const ceilingVertices = sourceTriangles[ceilingTriangle].indices.map((vertexIndex) =>
      transformVertex(sourceVertices[vertexIndex], spinners[ceilingObject], pitch));
    const floorNormal = cross(...floorVertices);
    const ceilingNormal = cross(...ceilingVertices);
    const floorNormalY = floorNormal[1] / Math.hypot(...floorNormal);
    const ceilingNormalY = ceilingNormal[1] / Math.hypot(...ceilingNormal);
    if (!(floorNormalY > 0.01 && ceilingNormalY < -0.01)) return false;
    const floorProjection = floorVertices.map((point) => [point[0], point[2]]);
    const ceilingProjection = ceilingVertices.map((point) => [point[0], point[2]]);
    if (!pointInsideConvex(integerWitness, floorProjection) ||
        !pointInsideConvex(integerWitness, ceilingProjection)) return false;
    const floor = { normal: floorNormal, vertices: floorVertices };
    const ceiling = { normal: ceilingNormal, vertices: ceilingVertices };
    const gap = surfaceHeight(ceiling, ...integerWitness) -
      surfaceHeight(floor, ...integerWitness);
    return gap > 0 && gap <= 160;
  }

  const fixedIntervals = [];
  let fixedStart = null;
  for (let index = 0; index <= 0x1000; index += 1) {
    const valid = index < 0x1000 && fixedPointCertificate(index);
    if (valid && fixedStart === null) fixedStart = index;
    if (!valid && fixedStart !== null) {
      fixedIntervals.push([fixedStart, index - 1]);
      fixedStart = null;
    }
  }
  fixedIntervals.sort((a, b) => (b[1] - b[0]) - (a[1] - a[0]));
  console.log("fixed-witness validity intervals:");
  for (const interval of fixedIntervals.slice(0, 20)) {
    console.log(JSON.stringify({
      tableIndexInterval: interval,
      fullPitchInterval: [interval[0] << 4, (interval[1] << 4) + 15],
      width: ((interval[1] - interval[0] + 1) << 4),
    }));
  }
}
