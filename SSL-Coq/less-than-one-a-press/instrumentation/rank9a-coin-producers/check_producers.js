#!/usr/bin/env node
"use strict";

// Read-only diagnostic, NOT a retail or Clight execution. Inputs come from
// generated initializers, not the experimental game checkout. The formation
// mirror covers stock recipes and yaw; the toss mirror deliberately excludes
// floors, walls, water, moving supports, partial updates and collection.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const root = path.resolve(__dirname, "../..");
const f = Math.fround;
const storage = new DataView(new ArrayBuffer(4));
function fromBits(bits) {
  storage.setUint32(0, bits >>> 0);
  return storage.getFloat32(0);
}
function initializer(version, unit, name) {
  const text = fs.readFileSync(path.join(root, "generated", `${version}_${unit}.v`), "utf8");
  const start = text.indexOf(`Definition v_${name} :=`);
  assert(start >= 0, `Missing initializer: ${version}/${name}`);
  const end = text.indexOf("gvar_readonly", start);
  assert(end > start);
  return text.slice(start, end);
}
function signedWords(text) {
  return [...text.matchAll(/Init_int16 \(Int\.repr (?:\((-?\d+)\)|(-?\d+))\)/g)]
    .map(match => Number(match[1] ?? match[2]));
}
function outside([x, , z]) {
  return x < -302 || x > 302 || z < 1029 || z > 1634;
}
function inventory(version) {
  const words = signedWords(initializer(version, "ssl_area2_macro", "ssl_seg7_area_2_macro_objs"));
  assert.equal(words.length, 251);
  assert.equal(words.at(-1), 30);
  const records = Array.from({ length: 50 }, (_, i) => words.slice(i * 5, i * 5 + 5));
  const trig = [...initializer(version, "math_util", "gSineTable")
    .matchAll(/Init_float32 \(Float32\.of_bits \(Int\.repr (?:\((-?\d+)\)|(-?\d+))\)\)/g)]
    .map(match => fromBits(Number(match[1] ?? match[2])));
  assert.equal(trig.length, 5120);
  const sin = angle => trig[(angle & 65535) >>> 4];
  const cos = angle => trig[1024 + ((angle & 65535) >>> 4)];
  const formations = [];
  const fixed = [];
  for (const [tag, x, y, z] of records) {
    const preset = (tag & 511) - 31;
    if ([0, 1, 54].includes(preset)) fixed.push([x, y, z]);
    if (![6, 9, 10, 11].includes(preset)) continue;
    // Only stock 0/90-degree yaw appears in these four records.
    const yaw = tag & 0xfe00;
    assert([0, 16384].includes(yaw));
    const count = preset === 11 ? 8 : 5;
    const children = [];
    for (let index = 0; index < count; index++) {
      let dx = 0, dy = 0, dz = 0;
      if (preset === 10) dy = Math.trunc(160 * index * 0.8);
      else if (preset === 11) {
        dx = Math.trunc(f(sin(index << 13) * 300));
        dz = Math.trunc(f(cos(index << 13) * 300));
      } else dz = 160 * (index - 2);
      const wx = f(x + f(f(cos(yaw) * dx) + f(sin(yaw) * dz)));
      const wz = f(z + f(f(-sin(yaw) * dx) + f(cos(yaw) * dz)));
      const child = [wx, f(y + dy), wz];
      assert(Math.abs(wx - x) <= 640 && Math.abs(wz - z) <= 640);
      assert(outside(child));
      children.push(child);
    }
    formations.push({ parent: [x, y, z], groundSnapPending: preset === 6, children });
  }
  assert.equal(formations.length, 4);
  assert.equal(formations.reduce((sum, entry) => sum + entry.children.length, 0), 23);
  assert.equal(fixed.length, 18); // 15 yellow + 3 switched blue actors, not coin VALUE.
  assert(fixed.every(outside));
  return { fixedActors: fixed.length, formationActors: 23, formations };
}

// Exhaust all 16-bit random RETURN VALUES, not all RNG histories/controller
// schedules. Vertical and horizontal draws are different calls; this is not
// a claim that every pair can be chosen independently in a live run.
let minLaunch = Infinity, maxLaunch = -Infinity, maxForward = 0, maxRise = 0;
let minFirstFalling = Infinity, maxFirstFalling = 0;
for (let word = 0; word < 65536; word++) {
  const random = f(word / 65536);
  const launch = f(f(f(random * 10) + 30) + 20);
  minLaunch = Math.min(minLaunch, launch);
  maxLaunch = Math.max(maxLaunch, launch);
  maxForward = Math.max(maxForward, f(random * 10));
  let y = 0, vy = launch, firstFalling = 0;
  for (let step = 1; step <= 16; step++) {
    vy = f(vy - 4);
    y = f(y + vy);
    maxRise = Math.max(maxRise, y);
    if (vy < 0 && firstFalling === 0) firstFalling = step;
  }
  assert(firstFalling > 0);
  minFirstFalling = Math.min(minFirstFalling, firstFalling);
  maxFirstFalling = Math.max(maxFirstFalling, firstFalling);
}
assert.equal(minLaunch, 50);
assert.equal(maxLaunch, 59.999847412109375);
assert(maxForward < 10 && maxRise < 420);
assert.equal(minFirstFalling, 13);
assert.equal(maxFirstFalling, 15);
const us = inventory("us"), jp = inventory("jp");
assert.deepEqual(us, jp);
console.log(JSON.stringify({
  scope: "Generated-data/Float32 diagnostic; no collision, scheduling or reachability claim",
  versionsIdentical: true,
  inventory: us,
  isolatedToss: { testedRandomReturns: 65536, minLaunch, maxLaunch, maxForward,
    maxRiseFromZero: maxRise, firstFallingStep: [minFirstFalling, maxFirstFalling] }
}, null, 2));
