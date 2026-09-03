#!/usr/bin/env node
"use strict";

// Source-mesh diagnostic for the Rank-11 Goomba installer.  This deliberately
// does not simulate Mario or claim controller reachability.  It answers the
// narrower question whether a regular Goomba's stock floor movement is
// separated from the second-pole ring by the static collision topology.

const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "../../../..");
const cliArguments = process.argv.slice(2);
const checkExpected = cliArguments.includes("--check");
const compactOutput = checkExpected || cliArguments.includes("--compact");
const sourceArgument = cliArguments.find((argument) => !argument.startsWith("--"));
const source = sourceArgument || path.join(
  root, "build/tmp/sm64-clean-map-20260813/levels/ssl/areas/2/collision.inc.c"
);
const text = fs.readFileSync(source, "utf8");
const macroSource = path.join(
  root, "build/tmp/sm64-clean-map-20260813/levels/ssl/areas/2/macro.inc.c"
);
const trigSource = path.join(
  root, "build/tmp/sm64-clean-map-20260813/include/trig_tables.inc.c"
);

const vertices = [];
const triangles = [];
let surface = "";

for (const line of text.split(/\r?\n/)) {
  let match = line.match(/COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)/);
  if (match) {
    vertices.push(match.slice(1).map(Number));
    continue;
  }
  match = line.match(/COL_TRI_INIT\(\s*([^,]+)\s*,/);
  if (match) {
    surface = match[1].trim();
    continue;
  }
  match = line.match(/COL_TRI(?:_SPECIAL)?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/);
  if (match) {
    triangles.push({
      indices: match.slice(1).map(Number),
      surface,
    });
  }
}

function subtract(a, b) {
  return [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
}

function cross(a, b) {
  return [
    a[1] * b[2] - a[2] * b[1],
    a[2] * b[0] - a[0] * b[2],
    a[0] * b[1] - a[1] * b[0],
  ];
}

function coordinateKey(vertex) {
  return vertex.join(",");
}

function edgeKey(a, b) {
  const ka = coordinateKey(a);
  const kb = coordinateKey(b);
  return ka < kb ? `${ka}|${kb}` : `${kb}|${ka}`;
}

for (const triangle of triangles) {
  triangle.vertices = triangle.indices.map((index) => vertices[index]);
  const normal = cross(
    subtract(triangle.vertices[1], triangle.vertices[0]),
    subtract(triangle.vertices[2], triangle.vertices[0])
  );
  const length = Math.hypot(...normal);
  triangle.normalY = length === 0 ? 0 : normal[1] / length;
  // surface_load.c inserts every face above this threshold into a floor list.
  // Use that broader set for connectivity: an airborne object may land on a
  // steep floor even though grounded movement would reject walking onto it.
  triangle.floor = triangle.normalY > 0.01;
  triangle.walkable = triangle.normalY > Math.cos(78 * Math.PI / 180);
}

const floorSurfaces = triangles.filter((triangle) => triangle.floor);
const edgeOwners = new Map();
for (let index = 0; index < floorSurfaces.length; index++) {
  const vs = floorSurfaces[index].vertices;
  for (const [a, b] of [[0, 1], [1, 2], [2, 0]]) {
    const key = edgeKey(vs[a], vs[b]);
    if (!edgeOwners.has(key)) edgeOwners.set(key, []);
    edgeOwners.get(key).push(index);
  }
}

const adjacency = Array.from({ length: floorSurfaces.length }, () => []);
for (const owners of edgeOwners.values()) {
  for (const a of owners) {
    for (const b of owners) {
      if (a !== b) adjacency[a].push(b);
    }
  }
}

const component = Array(floorSurfaces.length).fill(-1);
const components = [];
for (let start = 0; start < floorSurfaces.length; start++) {
  if (component[start] !== -1) continue;
  const id = components.length;
  const members = [];
  const queue = [start];
  component[start] = id;
  while (queue.length) {
    const current = queue.pop();
    members.push(current);
    for (const next of adjacency[current]) {
      if (component[next] === -1) {
        component[next] = id;
        queue.push(next);
      }
    }
  }
  components.push(members);
}

function signedArea2(a, b, x, z) {
  return (b[0] - a[0]) * (z - a[2]) - (b[2] - a[2]) * (x - a[0]);
}

function containsXZ(triangle, x, z) {
  const [a, b, c] = triangle.vertices;
  const p = [signedArea2(a, b, x, z), signedArea2(b, c, x, z), signedArea2(c, a, x, z)];
  return p.every((v) => v >= 0) || p.every((v) => v <= 0);
}

function heightAt(triangle, x, z) {
  const [a, b, c] = triangle.vertices;
  const n = cross(subtract(b, a), subtract(c, a));
  return a[1] - (n[0] * (x - a[0]) + n[2] * (z - a[2])) / n[1];
}

function pointSegmentClosest(px, pz, a, b) {
  const dx = b[0] - a[0];
  const dz = b[2] - a[2];
  const denominator = dx * dx + dz * dz;
  const unclamped = denominator === 0 ? 0
    : ((px - a[0]) * dx + (pz - a[2]) * dz) / denominator;
  const t = Math.max(0, Math.min(1, unclamped));
  const x = a[0] + t * dx;
  const z = a[2] + t * dz;
  return { distance: Math.hypot(px - x, pz - z), first: [px, pz], second: [x, z] };
}

function segmentClosest(a, b, c, d) {
  // Checking both endpoint projections is enough for disjoint 2-D segments;
  // projected intersections are separately detected by the orientation test.
  const orientations = [
    signedArea2(a, b, c[0], c[2]),
    signedArea2(a, b, d[0], d[2]),
    signedArea2(c, d, a[0], a[2]),
    signedArea2(c, d, b[0], b[2]),
  ];
  const abx = b[0] - a[0];
  const abz = b[2] - a[2];
  const cdx = d[0] - c[0];
  const cdz = d[2] - c[2];
  const denominator = abx * cdz - abz * cdx;
  if (denominator !== 0 && orientations[0] * orientations[1] <= 0
      && orientations[2] * orientations[3] <= 0) {
    const acx = c[0] - a[0];
    const acz = c[2] - a[2];
    const t = (acx * cdz - acz * cdx) / denominator;
    const point = [a[0] + t * abx, a[2] + t * abz];
    return { distance: 0, first: point, second: point };
  }
  const candidates = [
    pointSegmentClosest(a[0], a[2], c, d),
    pointSegmentClosest(b[0], b[2], c, d),
    (() => { const r = pointSegmentClosest(c[0], c[2], a, b); return {
      distance: r.distance, first: r.second, second: r.first,
    }; })(),
    (() => { const r = pointSegmentClosest(d[0], d[2], a, b); return {
      distance: r.distance, first: r.second, second: r.first,
    }; })(),
  ];
  return candidates.reduce((best, candidate) => candidate.distance < best.distance ? candidate : best);
}

function triangleClosest(first, second) {
  // Segment intersection alone misses the case where one projected triangle
  // sits wholly inside the other.  Treat every such overlap as zero distance
  // and evaluate both floor heights at the shared X/Z point.
  for (const vertex of first.vertices) {
    if (containsXZ(second, vertex[0], vertex[2])) {
      const point = [vertex[0], vertex[2]];
      return { distance: 0, first: point, second: point };
    }
  }
  for (const vertex of second.vertices) {
    if (containsXZ(first, vertex[0], vertex[2])) {
      const point = [vertex[0], vertex[2]];
      return { distance: 0, first: point, second: point };
    }
  }
  const firstEdges = [[0, 1], [1, 2], [2, 0]];
  const secondEdges = [[0, 1], [1, 2], [2, 0]];
  let best = { distance: Infinity };
  for (const [a, b] of firstEdges) {
    for (const [c, d] of secondEdges) {
      const candidate = segmentClosest(
        first.vertices[a], first.vertices[b], second.vertices[c], second.vertices[d]
      );
      if (candidate.distance < best.distance) best = candidate;
    }
  }
  return best;
}

function floorCandidates(x, y, z) {
  return floorSurfaces
    .map((triangle, index) => ({ triangle, index, height: heightAt(triangle, x, z) }))
    .filter(({ triangle, height }) => containsXZ(triangle, x, z) && height <= y + 78)
    .sort((a, b) => b.height - a.height);
}

const goalSamples = [[0, 4000, 1000], [0, 4000, 1200]];
const goalFloors = goalSamples.map(([x, y, z]) => floorCandidates(x, y, z)[0]);
const goalComponents = [...new Set(goalFloors.filter(Boolean).map((floor) => component[floor.index]))];

// Derive the six singleton positions and the triplet parent from macro.inc.c.
// The child offsets are then evaluated through the pinned Float32 sine table,
// including C's truncating s16 conversion.  The spawner is not itself a
// damaging actor and is deliberately absent from the resulting list.
const macroText = fs.readFileSync(macroSource, "utf8");
const macroPosition = /\/\*pos\*\/\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)/;
const singletonPoints = [];
const tripletParents = [];
for (const line of macroText.split(/\r?\n/)) {
  const position = line.match(macroPosition);
  if (!position) continue;
  const point = position.slice(1).map(Number);
  if (/\/\*preset\*\/\s*macro_goomba\s*,/.test(line)) singletonPoints.push(point);
  if (/\/\*preset\*\/\s*macro_goomba_triplet_spawner\s*,/.test(line)) {
    tripletParents.push(point);
  }
}
if (singletonPoints.length !== 6 || tripletParents.length !== 1) {
  throw new Error(`unexpected Goomba macro roster: ${singletonPoints.length} singleton, ${tripletParents.length} triplet`);
}

// Under AVOID_UB the conditional initializer is one combined sine array; the
// cosine view begins at element 0x400, exactly as math_util.h specifies.
const trigText = fs.readFileSync(trigSource, "utf8");
const trigValues = [...trigText.matchAll(/(-?\d+\.\d+)f/g)]
  .map((match) => Math.fround(Number(match[1])));
function pinnedSin(angle) {
  return trigValues[(angle & 0xffff) >> 4];
}
function pinnedCos(angle) {
  return trigValues[((angle & 0xffff) >> 4) + 0x400];
}
const tripletStep = Math.trunc(0x10000 / 3);
const [tripletX, tripletY, tripletZ] = tripletParents[0];
const tripletPoints = [0, tripletStep, 2 * tripletStep].map((angle) => {
  const dx = Math.trunc(Math.fround(Math.fround(500) * pinnedCos(angle)));
  const dz = Math.trunc(Math.fround(Math.fround(500) * pinnedSin(angle)));
  return [tripletX + dx, tripletY, tripletZ + dz];
});
const goombaSpawns = [
  ...singletonPoints.map((point, index) => ({ origin: `singleton-${index + 1}`, point })),
  ...tripletPoints.map((point, index) => ({ origin: `triplet-${index}`, point })),
];

const movingOwnerSamples = [
  { name: "grindel", point: [3297, 5000, 95] },
  { name: "upper-horizontal-grindel", point: [-870, 6000, 105] },
  { name: "lower-horizontal-grindel", point: [-3362, 3000, -1385] },
  { name: "spindel", point: [-2458, 4000, -1430] },
  { name: "wall-858", point: [858, 4000, -2307] },
  { name: "wall-730", point: [730, 4000, -2307] },
  { name: "wall-1473", point: [1473, 5000, -2307] },
  { name: "wall-1345", point: [1345, 5000, -2307] },
  { name: "elevator", point: [0, 7000, 256] },
];

const movingOwnerStaticFloors = movingOwnerSamples.map(({ name, point: [x, y, z] }) => ({
  name,
  x,
  z,
  staticFloors: floorCandidates(x, y, z).slice(0, 5).map((floor) => ({
    height: floor.height,
    component: component[floor.index],
    triangle: floor.triangle.indices,
  })),
}));

function rectangleTriangles(minX, maxX, minZ, maxZ) {
  return [
    { vertices: [[minX, 0, minZ], [maxX, 0, minZ], [maxX, 0, maxZ]], indices: [] },
    { vertices: [[minX, 0, minZ], [maxX, 0, maxZ], [minX, 0, maxZ]], indices: [] },
  ];
}

function componentsNearRectangle(minX, maxX, minZ, maxZ, limit) {
  const rectangle = rectangleTriangles(minX, maxX, minZ, maxZ);
  return components.map((members, id) => {
    let best = { distance: Infinity };
    for (const index of members) {
      for (const target of rectangle) {
        const closest = triangleClosest(floorSurfaces[index], target);
        if (closest.distance < best.distance) {
          best = {
            ...closest,
            height: heightAt(floorSurfaces[index], ...closest.first),
            triangle: floorSurfaces[index].indices,
          };
        }
      }
    }
    return { component: id, distanceXZ: best.distance, height: best.height, triangle: best.triangle };
  }).filter((entry) => entry.distanceXZ <= limit)
    .sort((a, b) => a.distanceXZ - b.distanceXZ || a.height - b.height);
}

const grindelTopRectangle = { minX: 3073, maxX: 3521, minZ: -129, maxZ: 319 };
const grindelNearbyStaticComponents = componentsNearRectangle(
  grindelTopRectangle.minX, grindelTopRectangle.maxX,
  grindelTopRectangle.minZ, grindelTopRectangle.maxZ, 250
);

const spawnReport = goombaSpawns.map(({ origin, point: [x, y, z] }) => {
  const floor = floorCandidates(x, y, z)[0];
  return {
    origin,
    spawn: [x, y, z],
    floorY: floor ? floor.height : null,
    component: floor ? component[floor.index] : null,
    reachesGoalStaticComponent: floor ? goalComponents.includes(component[floor.index]) : false,
  };
});

const componentReport = components.map((members, id) => {
  const vs = members.flatMap((index) => floorSurfaces[index].vertices);
  const xs = vs.map((vertex) => vertex[0]);
  const ys = vs.map((vertex) => vertex[1]);
  const zs = vs.map((vertex) => vertex[2]);
  return {
    id,
    triangles: members.length,
    minX: Math.min(...xs),
    maxX: Math.max(...xs),
    minY: Math.min(...ys),
    maxY: Math.max(...ys),
    minZ: Math.min(...zs),
    maxZ: Math.max(...zs),
  };
}).sort((a, b) => b.triangles - a.triangles);

function componentBoundary(firstMembers, secondMembers) {
  let best = { distance: Infinity };
  for (const firstIndex of firstMembers) {
    for (const secondIndex of secondMembers) {
      const closest = triangleClosest(floorSurfaces[firstIndex], floorSurfaces[secondIndex]);
      const firstHeight = heightAt(floorSurfaces[firstIndex], ...closest.first);
      const secondHeight = heightAt(floorSurfaces[secondIndex], ...closest.second);
      const score = closest.distance * 100000 + Math.abs(secondHeight - firstHeight);
      const bestScore = best.distance * 100000
        + Math.abs((best.secondHeight || 0) - (best.firstHeight || 0));
      if (score < bestScore) {
        best = {
          ...closest,
          firstIndex,
          secondIndex,
          firstHeight,
          secondHeight,
        };
      }
    }
  }
  return best;
}

const goalMembers = goalComponents.flatMap((id) => components[id]);
const nearestGoalComponents = components
  .map((members, id) => {
    if (goalComponents.includes(id)) return null;
    const boundary = componentBoundary(members, goalMembers);
    const best = {
      ...boundary,
      sourceIndex: boundary.firstIndex,
      goalIndex: boundary.secondIndex,
      sourceHeight: boundary.firstHeight,
      goalHeight: boundary.secondHeight,
    };
    return {
      component: id,
      distanceXZ: best.distance,
      sourceHeight: best.sourceHeight,
      goalHeight: best.goalHeight,
      upwardGap: best.goalHeight - best.sourceHeight,
      sourceTriangle: floorSurfaces[best.sourceIndex].indices,
      goalTriangle: floorSurfaces[best.goalIndex].indices,
    };
  })
  .filter(Boolean)
  .sort((a, b) => a.distanceXZ - b.distanceXZ || Math.abs(a.upwardGap) - Math.abs(b.upwardGap));

// A regular Goomba's stock jump starts at +25 and applies -4 before moving,
// so its exact integer-aligned heights are +21,+38,+51,+60,+65,+66.  The
// floor query admits a floor up to 78 units above the pre-move Y.  Therefore
// a directly overlapping upper floor at most 144 units above is visible at
// the +66 pre-move sample (the source comparison admits equality).
const jumpSnapLimit = 144;
const jumpEdges = Array.from({ length: components.length }, () => []);
const jumpWitnesses = [];
for (let first = 0; first < components.length; first++) {
  for (let second = 0; second < components.length; second++) {
    if (first === second) continue;
    const boundary = componentBoundary(components[first], components[second]);
    const rise = boundary.secondHeight - boundary.firstHeight;
    if (boundary.distance < 1e-7 && rise > 0 && rise <= jumpSnapLimit) {
      jumpEdges[first].push(second);
      jumpWitnesses.push({
        from: first,
        to: second,
        rise,
        x: boundary.first[0],
        z: boundary.first[1],
        fromTriangle: floorSurfaces[boundary.firstIndex].indices,
        toTriangle: floorSurfaces[boundary.secondIndex].indices,
      });
    }
  }
}

function shortestJumpPath(start, goals) {
  const previous = new Map([[start, null]]);
  const queue = [start];
  for (let offset = 0; offset < queue.length; offset++) {
    const current = queue[offset];
    if (goals.includes(current)) {
      const path = [];
      for (let node = current; node !== null; node = previous.get(node)) path.push(node);
      return path.reverse();
    }
    for (const next of jumpEdges[current]) {
      if (!previous.has(next)) {
        previous.set(next, current);
        queue.push(next);
      }
    }
  }
  return null;
}

const spawnJumpPaths = spawnReport.map((spawn) => ({
  spawn: spawn.spawn,
  startComponent: spawn.component,
  jumpOnlyPath: spawn.component === null ? null
    : shortestJumpPath(spawn.component, goalComponents),
}));

function transitionBoundary(firstMembers, secondMembers, predicate) {
  let best = null;
  for (const firstIndex of firstMembers) {
    for (const secondIndex of secondMembers) {
      const closest = triangleClosest(floorSurfaces[firstIndex], floorSurfaces[secondIndex]);
      const firstHeight = heightAt(floorSurfaces[firstIndex], ...closest.first);
      const secondHeight = heightAt(floorSurfaces[secondIndex], ...closest.second);
      const rise = secondHeight - firstHeight;
      if (predicate(closest.distance, rise)) {
        const candidate = {
          ...closest, firstIndex, secondIndex, firstHeight, secondHeight, rise,
        };
        if (best === null || candidate.distance < best.distance
            || (candidate.distance === best.distance && Math.abs(candidate.rise) < Math.abs(best.rise))) {
          best = candidate;
        }
      }
    }
  }
  return best;
}

// At chase speed a regular Goomba approaches 20*1.5 = 30 units/update.
// cur_obj_move_xz permits a grounded edge crossing when the destination floor
// is no more than 78 above and no more than 50 below.  This is a permissive
// source-level graph: it does not claim the required point/yaw is reachable.
const ordinaryStepLimit = 30;
const combinedEdges = Array.from({ length: components.length }, () => []);
const combinedWitnesses = [];
for (let first = 0; first < components.length; first++) {
  for (const second of jumpEdges[first]) {
    combinedEdges[first].push(second);
    const witness = jumpWitnesses.find((edge) => edge.from === first && edge.to === second);
    combinedWitnesses.push({ ...witness, kind: "jump-snap" });
  }
  for (let second = 0; second < components.length; second++) {
    if (first === second || combinedEdges[first].includes(second)) continue;
    const boundary = transitionBoundary(components[first], components[second],
      (distance, rise) => distance <= ordinaryStepLimit && rise >= -50 && rise <= 78);
    if (boundary) {
      combinedEdges[first].push(second);
      combinedWitnesses.push({
        from: first,
        to: second,
        kind: "ordinary-step",
        distanceXZ: boundary.distance,
        rise: boundary.rise,
        fromPoint: boundary.first,
        toPoint: boundary.second,
        fromTriangle: floorSurfaces[boundary.firstIndex].indices,
        toTriangle: floorSurfaces[boundary.secondIndex].indices,
      });
    }
  }
}

function shortestCombinedPath(start, goals) {
  const previous = new Map([[start, null]]);
  const queue = [start];
  for (let offset = 0; offset < queue.length; offset++) {
    const current = queue[offset];
    if (goals.includes(current)) {
      const path = [];
      for (let node = current; node !== null; node = previous.get(node)) path.push(node);
      return path.reverse();
    }
    for (const next of combinedEdges[current]) {
      if (!previous.has(next)) {
        previous.set(next, current);
        queue.push(next);
      }
    }
  }
  return null;
}

function reachableComponents(start) {
  const seen = new Set([start]);
  const queue = [start];
  for (let offset = 0; offset < queue.length; offset++) {
    for (const next of combinedEdges[queue[offset]]) {
      if (!seen.has(next)) {
        seen.add(next);
        queue.push(next);
      }
    }
  }
  return [...seen].sort((a, b) => a - b);
}

const spawnCombinedPaths = spawnReport.map((spawn) => {
  const componentPath = spawn.component === null ? null
    : shortestCombinedPath(spawn.component, goalComponents);
  const reachable = spawn.component === null ? [] : reachableComponents(spawn.component);
  const reachableHeights = reachable.flatMap((id) => components[id]
    .flatMap((index) => floorSurfaces[index].vertices.map((vertex) => vertex[1])));
  const frontier = nearestGoalComponents.find((candidate) => reachable.includes(candidate.component));
  return {
    spawn: spawn.spawn,
    startComponent: spawn.component,
    componentPath,
    reachableComponents: reachable,
    reachableMaxVertexY: reachableHeights.length ? Math.max(...reachableHeights) : null,
    nearestReachableComponentToGoal: frontier || null,
    witnesses: componentPath === null ? [] : componentPath.slice(1).map((to, index) =>
      combinedWitnesses.find((edge) => edge.from === componentPath[index] && edge.to === to)),
  };
});

// A collision resolver can separate two regular radius-108 Goombas in X/Z.
// The very loose 216 bound below asks only whether component geometry leaves
// a pair-assisted candidate; it is NOT a proof that two live Goombas, their
// cached collision, the erroneous atan2 ordering, and a controller schedule
// realize the edge (or carry both actors onward).
const pairSeparationLimit = 216;
const pairEdges = Array.from({ length: components.length }, () => []);
const pairWitnesses = [];
for (let first = 0; first < components.length; first++) {
  for (let second = 0; second < components.length; second++) {
    if (first === second) continue;
    const boundary = transitionBoundary(components[first], components[second],
      (distance, rise) => distance <= pairSeparationLimit && rise <= jumpSnapLimit);
    if (boundary) {
      pairEdges[first].push(second);
      pairWitnesses.push({
        from: first,
        to: second,
        distanceXZ: boundary.distance,
        rise: boundary.rise,
        fromPoint: boundary.first,
        toPoint: boundary.second,
        fromTriangle: floorSurfaces[boundary.firstIndex].indices,
        toTriangle: floorSurfaces[boundary.secondIndex].indices,
      });
    }
  }
}

function shortestPathWithEdges(start, goals, edges) {
  const previous = new Map([[start, null]]);
  const queue = [start];
  for (let offset = 0; offset < queue.length; offset++) {
    const current = queue[offset];
    if (goals.includes(current)) {
      const path = [];
      for (let node = current; node !== null; node = previous.get(node)) path.push(node);
      return path.reverse();
    }
    for (const next of edges[current]) {
      if (!previous.has(next)) {
        previous.set(next, current);
        queue.push(next);
      }
    }
  }
  return null;
}

const pairAbstractPaths = spawnReport.map((spawn) => {
  const componentPath = spawn.component === null ? null
    : shortestPathWithEdges(spawn.component, goalComponents, pairEdges);
  return {
    spawn: spawn.spawn,
    startComponent: spawn.component,
    componentPath,
    witnesses: componentPath === null ? [] : componentPath.slice(1).map((to, index) =>
      pairWitnesses.find((edge) => edge.from === componentPath[index] && edge.to === to)),
  };
});

const report = {
  source: path.relative(root, source).replaceAll("\\", "/"),
  vertexCount: vertices.length,
  triangleCount: triangles.length,
  floorTriangleCount: floorSurfaces.length,
  staticWalkableComponentCount: components.length,
  goalFloors: goalFloors.map((floor) => floor ? {
    height: floor.height,
    component: component[floor.index],
    indices: floor.triangle.indices,
  } : null),
  goalComponents,
  goombaSpawns: spawnReport,
  movingOwnerStaticFloors,
  grindelTopRectangle,
  grindelNearbyStaticComponents,
  largestComponents: componentReport.slice(0, 12),
  spawnAndGoalComponents: componentReport.filter((entry) =>
    [0, 45, 46, 47, 56, 58, 59, 60, 61, 62, 63, 71, 73, 74].includes(entry.id)),
  nearestGoalComponents: nearestGoalComponents.slice(0, 12),
  jumpSnapLimit,
  jumpSnapEdgeCount: jumpWitnesses.length,
  spawnJumpPaths,
  jumpWitnessesOnShortestPaths: spawnJumpPaths.flatMap((entry) => {
    if (!entry.jumpOnlyPath) return [];
    return entry.jumpOnlyPath.slice(1).map((to, index) =>
      jumpWitnesses.find((edge) => edge.from === entry.jumpOnlyPath[index] && edge.to === to));
  }).filter(Boolean),
  ordinaryStepLimit,
  combinedStaticPaths: spawnCombinedPaths,
  pairSeparationLimit,
  pairAbstractPaths,
  scope: "Shared-edge topology over every static face classified as a floor (normalY > 0.01); no controller, wall, dynamic-surface, room, list-order, or live-execution claim.",
};

const compactReport = {
  source: report.source,
  rosterSources: [
    path.relative(root, macroSource).replaceAll("\\", "/"),
    path.relative(root, trigSource).replaceAll("\\", "/"),
  ],
  counts: {
    vertices: report.vertexCount,
    triangles: report.triangleCount,
    floorTriangles: report.floorTriangleCount,
    components: report.staticWalkableComponentCount,
  },
  goal: report.goalFloors[0],
  spawns: report.goombaSpawns,
  combined: report.combinedStaticPaths.map((entry) => ({
    origin: report.goombaSpawns.find((spawn) =>
      JSON.stringify(spawn.spawn) === JSON.stringify(entry.spawn)).origin,
    startComponent: entry.startComponent,
    reachesGoal: entry.componentPath !== null,
    reachableComponents: entry.reachableComponents,
    reachableMaxVertexY: entry.reachableMaxVertexY,
  })),
  pairAbstract: report.pairAbstractPaths.map((entry) => ({
    origin: report.goombaSpawns.find((spawn) =>
      JSON.stringify(spawn.spawn) === JSON.stringify(entry.spawn)).origin,
    startComponent: entry.startComponent,
    reachesGoal: entry.componentPath !== null,
  })),
  grindel: {
    topRectangle: report.grindelTopRectangle,
    nearbyStatic: report.grindelNearbyStaticComponents.map((entry) => ({
      component: entry.component,
      distanceXZ: entry.distanceXZ,
      height: entry.height,
    })),
  },
  limits: {
    ordinaryStep: report.ordinaryStepLimit,
    jumpSnap: report.jumpSnapLimit,
    pairSeparation: report.pairSeparationLimit,
  },
};

// This receipt is intentionally small enough to review in a diff.  --check
// recomputes it from the pinned collision source and fails on any discrepancy.
const expectedCompactReport = {
  source: "build/tmp/sm64-clean-map-20260813/levels/ssl/areas/2/collision.inc.c",
  rosterSources: [
    "build/tmp/sm64-clean-map-20260813/levels/ssl/areas/2/macro.inc.c",
    "build/tmp/sm64-clean-map-20260813/include/trig_tables.inc.c",
  ],
  counts: { vertices: 1080, triangles: 1558, floorTriangles: 534, components: 81 },
  goal: { height: 3942, component: 74, indices: [283, 298, 284] },
  spawns: [
    { origin: "singleton-1", spawn: [3263, 778, 3157], floorY: 640, component: 47, reachesGoalStaticComponent: false },
    { origin: "singleton-2", spawn: [3389, 0, -1978], floorY: 0, component: 0, reachesGoalStaticComponent: false },
    { origin: "singleton-3", spawn: [-3638, 0, 1928], floorY: 0, component: 0, reachesGoalStaticComponent: false },
    { origin: "singleton-4", spawn: [3263, 652, 2200], floorY: 640, component: 46, reachesGoalStaticComponent: false },
    { origin: "singleton-5", spawn: [3431, 673, -1373], floorY: 640, component: 45, reachesGoalStaticComponent: false },
    { origin: "singleton-6", spawn: [-2100, 0, 3316], floorY: 0, component: 0, reachesGoalStaticComponent: false },
    { origin: "triplet-0", spawn: [3681, 0, 3587], floorY: 0, component: 0, reachesGoalStaticComponent: false },
    { origin: "triplet-1", spawn: [2932, 0, 4020], floorY: 0, component: 0, reachesGoalStaticComponent: false },
    { origin: "triplet-2", spawn: [2931, 0, 3155], floorY: 0, component: 0, reachesGoalStaticComponent: false },
  ],
  combined: [
    { origin: "singleton-1", startComponent: 47, reachesGoal: false, reachableComponents: [46, 47], reachableMaxVertexY: 640 },
    { origin: "singleton-2", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
    { origin: "singleton-3", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
    { origin: "singleton-4", startComponent: 46, reachesGoal: false, reachableComponents: [46, 47], reachableMaxVertexY: 640 },
    { origin: "singleton-5", startComponent: 45, reachesGoal: false, reachableComponents: [20, 21, 22, 23, 24, 25, 26, 45, 48, 49, 51, 52, 53], reachableMaxVertexY: 640 },
    { origin: "singleton-6", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
    { origin: "triplet-0", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
    { origin: "triplet-1", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
    { origin: "triplet-2", startComponent: 0, reachesGoal: false, reachableComponents: [0, 56, 58, 59, 60, 61, 62, 63], reachableMaxVertexY: 113 },
  ],
  pairAbstract: [
    { origin: "singleton-1", startComponent: 47, reachesGoal: false },
    { origin: "singleton-2", startComponent: 0, reachesGoal: false },
    { origin: "singleton-3", startComponent: 0, reachesGoal: false },
    { origin: "singleton-4", startComponent: 46, reachesGoal: false },
    { origin: "singleton-5", startComponent: 45, reachesGoal: false },
    { origin: "singleton-6", startComponent: 0, reachesGoal: false },
    { origin: "triplet-0", startComponent: 0, reachesGoal: false },
    { origin: "triplet-1", startComponent: 0, reachesGoal: false },
    { origin: "triplet-2", startComponent: 0, reachesGoal: false },
  ],
  grindel: {
    topRectangle: { minX: 3073, maxX: 3521, minZ: -129, maxZ: 319 },
    nearbyStatic: [
      { component: 0, distanceXZ: 0, height: 0 },
      { component: 66, distanceXZ: 1, height: -101 },
      { component: 59, distanceXZ: 91, height: 72 },
      { component: 56, distanceXZ: 92, height: 72 },
      { component: 45, distanceXZ: 154, height: 640 },
      { component: 46, distanceXZ: 154, height: 640 },
    ],
  },
  limits: { ordinaryStep: 30, jumpSnap: 144, pairSeparation: 216 },
};

if (checkExpected) {
  if (JSON.stringify(compactReport) !== JSON.stringify(expectedCompactReport)) {
    throw new Error("Rank-11 Goomba installer receipt mismatch");
  }
  process.stdout.write("Rank-11 Goomba installer receipt: OK\n");
} else {
  process.stdout.write(`${JSON.stringify(compactOutput ? compactReport : report, null, 2)}\n`);
}
