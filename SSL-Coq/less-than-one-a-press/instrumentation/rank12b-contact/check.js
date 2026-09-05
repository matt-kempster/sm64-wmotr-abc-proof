/* Offline stock-source contact geometry. This does not run the game or write
 * game memory. A geometric sample is not a controller-reachability receipt. */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');
const source = path.join(root, 'build/pinned-sm64');
const read = p => fs.readFileSync(path.join(source, p), 'utf8');
const vertices = [], triangles = [];
let surface;
for (const line of read('levels/ssl/areas/2/collision.inc.c').split(/\r?\n/)) {
  let m = /COL_VERTEX\(\s*(-?\d+)\s*,\s*(-?\d+)\s*,\s*(-?\d+)\s*\)/.exec(line);
  if (m) { vertices.push(m.slice(1).map(Number)); continue; }
  m = /COL_TRI_INIT\(\s*([^,]+),/.exec(line);
  if (m) { surface = m[1].trim(); continue; }
  m = /COL_TRI(?:_SPECIAL)?\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)/.exec(line);
  if (m) triangles.push({id: triangles.length, surface, indices: m.slice(1).map(Number)});
}
assert.equal(vertices.length, 1080);
assert.equal(triangles.length, 1558);
const sub = (a, b) => a.map((v, i) => v - b[i]);
const cross = (a, b) => [a[1]*b[2]-a[2]*b[1], a[2]*b[0]-a[0]*b[2], a[0]*b[1]-a[1]*b[0]];
for (const t of triangles) {
  t.v = t.indices.map(i => vertices[i]);
  t.n = cross(sub(t.v[1], t.v[0]), sub(t.v[2], t.v[0]));
}
const triggers = [...read('levels/ssl/areas/2/macro.inc.c').matchAll(
  /MACRO_OBJECT\s*\(\/\*preset\*\/ macro_hidden_star_trigger,\s*\/\*yaw\*\/\s*0,\s*\/\*pos\*\/\s*(-?\d+),\s*(-?\d+),\s*(-?\d+)/g)]
  .map((m, i) => ({name: `secret-${i+1}`, position: m.slice(1).map(Number), radius: 137, height: 100}));
assert.equal(triggers.length, 5);
const targets = [
  {name: 'act3-star', position: [500,5050,-500], radius:117, height:50},
  {name: 'act6-settled-star', position: [900,1400,2350], radius:117, height:50},
  ...triggers
];
const expectedCandidates = [[1092,1093,1094,1095,1096,1097],[],[647,659],
  [636,640],[1377,1378,1379],[1375,1377,1378],[668,669]];
const behavior = read('data/behavior_data.c');
const starSource = read('src/game/behaviors/spawn_star.inc.c');
assert.match(behavior, /bhvHiddenStarTrigger\[\][\s\S]*?SET_HITBOX\(\/\*Radius\*\/ 100, \/\*Height\*\/ 100\)/);
assert.match(behavior, /bhvMario\[\][\s\S]*?SET_HITBOX\(\/\*Radius\*\/ 37, \/\*Height\*\/ 160\)/);
assert.match(starSource, /\/\* radius:\s*\*\/ 80,[\s\S]*?\/\* height:\s*\*\/ 50,/);
const script = read('levels/ssl/script.c').replace(/\/\*[\s\S]*?\*\//g, '');
assert(/MODEL_STAR,\s*500,\s*5050,\s*-500,/.test(script), 'Act-3 source position changed');
assert(/MODEL_NONE,\s*900,\s*1400,\s*2350,/.test(script), 'Act-6 source position changed');
const f = Math.fround;
function overlap(p, target) {
  const [x,y,z] = p.map(f), [tx,ty,tz] = target.position;
  const dx = f(x-tx), dz = f(z-tz);
  const distance = f(Math.sqrt(f(f(dx*dx)+f(dz*dz))));
  return distance < target.radius && !(y > f(ty+target.height)) && !(f(160+y) < ty);
}
// Broad phase: conservatively enlarge each cylinder into an axis-aligned box.
// Include EVERY positive-upward face, not merely comfortably walkable floors.
// This is a static mesh filter, not the game's live find_floor selection.
function candidates(target, padding = 1) {
  const [x,y,z] = target.position, r = target.radius + padding;
  const lo = [x-r,y-160-padding,z-r], hi = [x+r,y+target.height+padding,z+r];
  return triangles.filter(t => t.n[1] > 0 && [0,1,2].every(axis =>
    Math.min(...t.v.map(v => v[axis])) <= hi[axis] &&
    Math.max(...t.v.map(v => v[axis])) >= lo[axis]));
}
const boxes = [
  {name:'elevator-cage-footprint', lo:[-460,-204], hi:[461,717]},
  {name:'second-pole-aperture', lo:[-101,1229], hi:[102,1434]}
];
for (const [i, target] of targets.entries()) {
  assert.deepEqual(candidates(target).map(t => t.id), expectedCandidates[i]);
  assert.deepEqual(candidates(target, 0).map(t => t.id), expectedCandidates[i]);
}
const report = targets.map(target => ({
  name: target.name,
  position: target.position,
  marioY: [target.position[1]-160, target.position[1]+target.height],
  floorCandidates: candidates(target).map(t => process.argv.includes('--verbose')
    ? {id:t.id, surface:t.surface, indices:t.indices, vertices:t.v} : t.id),
  boxDistances: boxes.map(box => {
    const p = [0, target.position[1], 0];
    for (const [j,axis] of [0,2].entries()) p[axis] = Math.max(box.lo[j], Math.min(box.hi[j], target.position[axis]));
    assert.equal(overlap(p, target), false);
    return {name:box.name, closestXZ:[p[0],p[2]], distance:Math.hypot(p[0]-target.position[0],p[2]-target.position[2])};
  })
}));
const rim = triangles[1093], sample = [400,4914,-500];
assert.deepEqual(rim.v, [[387,4927,-716],[387,4927,-409],[427,4887,-450]]);
const edges = rim.v.map((a,i) => {
  const b = rim.v[(i+1)%3];
  return (b[0]-a[0])*(sample[2]-a[2])-(b[2]-a[2])*(sample[0]-a[0]);
});
assert(edges.every(e => e <= 0));
assert.equal(rim.n.reduce((sum,n,i) => sum+n*(sample[i]-rim.v[0][i]), 0), 0);
assert.equal(overlap(sample, targets[0]), true);
assert.equal(overlap([500,4815,-500], targets[0]), false);
assert.equal(overlap([900,1229,2350], targets[1]), false);
assert.equal(overlap([260,3753,-600], targets[6]), true);
assert.equal(overlap([260,3752,-600], targets[6]), false);
assert.deepEqual(triangles[664].v, [[387,3785,-716],[131,3785,-460],[131,3785,-716]]);
assert.deepEqual(triangles[665].v, [[387,3785,-716],[387,3785,-460],[131,3785,-460]]);
assert.equal(3913-3785, 128);
assert.equal(overlap([260,3625,-600], targets[6]), false);
assert.equal(overlap([397,3913,-600], targets[6]), false); // exact radial boundary is excluded
assert.equal(overlap([396,3913,-600], targets[6]), true);
console.log(JSON.stringify({vertices:vertices.length, triangles:triangles.length,
  padding:1, report, conditionalAct3RimSample:sample,
  ...(process.argv.includes('--verbose') ? {upperSecretSolids: triangles.filter(t => {
    const lo = [122,3752,-738], hi = [398,4014,-462];
    return [0,1,2].every(axis => Math.min(...t.v.map(v=>v[axis])) <= hi[axis] &&
      Math.max(...t.v.map(v=>v[axis])) >= lo[axis]);
  }).map(t => ({id:t.id, surface:t.surface, vertices:t.v, normal:t.n}))} : {}),
  scope:'Static source geometry and Float32 checks only; no live controller route or star collection.'}, null, 2));
