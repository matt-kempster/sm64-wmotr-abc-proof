#!/usr/bin/env node
"use strict";

// Discovery only. Coq rechecks accepted geometry from generated initializers.
// A pairwise collision certificate is not a Mario entry or scheduler proof.
const fs = require("fs");
const path = require("path");
const root = path.resolve(__dirname, "..");
function definition(file, name) {
  const text = fs.readFileSync(path.join(root, file), "utf8");
  const start = text.indexOf(`Definition ${name} :=`);
  const end = text.indexOf("\n|}.", start);
  if (start < 0 || end < 0) throw new Error(`missing ${file}:${name}`);
  return text.slice(start, end);
}
function ints(file, name) {
  return [...definition(file, name).matchAll(
    /Init_int16 \(Int\.repr (?:(-?\d+)|\((-?\d+)\))\)/g
  )].map(m => (Number(m[1] ?? m[2]) << 16) >> 16);
}
function floats(file, name) {
  const view = new DataView(new ArrayBuffer(4));
  return [...definition(file, name).matchAll(
    /Init_float32 \(Float32\.of_bits \(Int\.repr (?:(-?\d+)|\((-?\d+)\))\)\)/g
  )].map(m => {
    view.setUint32(0, Number(m[1] ?? m[2]) >>> 0);
    return view.getFloat32(0);
  });
}
const f = Math.fround;
const mul = (a, b) => f(f(a) * f(b));
const add = (a, b) => f(f(a) + f(b));
const sum4 = (a, b, c, d) => add(add(add(a, b), c), d);
const cast = n => (Math.trunc(n) << 16) >> 16;
const edge = (a, b, x, z) => (b[0]-a[0])*(z-a[2])-(b[2]-a[2])*(x-a[0]);
function inside(t, x, z, sign) {
  return [0, 1, 2].every(i => sign * edge(t[i], t[(i+1)%3], x, z) > 0);
}
function readVersion(version) {
  const hex = ints(`generated/${version}_ttc_cog_collision.v`, "v_ttc_seg7_collision_07015584");
  const tri = ints(`generated/${version}_ttc_cog_collision.v`, "v_ttc_seg7_collision_07015650");
  const macro = ints(`generated/${version}_ttc_area1_macro.v`, "v_ttc_seg7_macro_objs");
  const sine = floats(`generated/${version}_math_util.v`, "v_gSineTable");
  if (hex.length !== 102 || tri.length !== 129 || sine.length !== 5120)
    throw new Error("unexpected cog input layout");
  const cogs = [];
  for (let i = 0; i + 4 < macro.length; i += 5) {
    const preset = macro[i] & 511;
    if (preset === 350 || preset === 351) cogs.push({
      macroIndex: i / 5, preset, pos: macro.slice(i + 1, i + 4),
      initialYaw: macro[i] & 65024,
    });
  }
  if (cogs.length !== 8 || cogs.filter(c => c.preset === 350).length !== 6)
    throw new Error("unexpected cog inventory");
  return { hex, tri, cogs, sine };
}
const us = readVersion("us"), jp = readVersion("jp");
if (JSON.stringify(us) !== JSON.stringify(jp)) throw new Error("US/JP input mismatch");
function triangles(cog, yaw) {
  const words = cog.preset === 350 ? us.hex : us.tri;
  const sy = us.sine[(yaw & 65535) >>> 4];
  const cy = us.sine[((yaw & 65535) >>> 4) + 1024];
  const vertices = Array.from({length: words[1]}, (_, i) => {
    const [x, y, z] = words.slice(2 + i * 3, 5 + i * 3);
    return [cast(sum4(mul(x,cy),mul(y,0),mul(z,sy),cog.pos[0])),
      cast(sum4(mul(x,0),mul(y,1),mul(z,-0),cog.pos[1])),
      cast(sum4(mul(x,-sy),mul(y,0),mul(z,cy),cog.pos[2]))];
  });
  const offset = 2 + words[1] * 3;
  if (words[offset] !== 21) throw new Error("unexpected surface type");
  return Array.from({length: words[offset+1]}, (_, i) =>
    words.slice(offset+2+i*3, offset+5+i*3).map(j => vertices[j]));
}
const floorIndex = 0, ceilingIndex = 3;
const floorCog = us.cogs[floorIndex], ceilingCog = us.cogs[ceilingIndex];
let witness;
for (const fyaw of [0, 8192, 16384, 24576, 32768, 40960, 49152, 57344]) {
  for (const cyaw of [0, 8192, 16384, 24576, 32768, 40960, 49152, 57344]) {
    const floors = triangles(floorCog, fyaw), ceilings = triangles(ceilingCog, cyaw);
    for (let x = 1250; x <= 1450; x += 5) for (let z = -1150; z <= -950; z += 5) {
      // Include the vertical difference in the stock 400-unit load-distance check.
      if ([floorCog, ceilingCog].some(c =>
        (x-c.pos[0])**2+(floorCog.pos[1]-c.pos[1])**2+(z-c.pos[2])**2 >= 400**2)) continue;
      for (let fi = 0; fi < floors.length; ++fi) for (let ci = 0; ci < ceilings.length; ++ci) {
        const ft = floors[fi], ct = ceilings[ci];
        if (!ft.every(v => v[1] === floorCog.pos[1]) ||
            !ct.every(v => v[1] === ceilingCog.pos[1]-153) ||
            !inside(ft, x, z, -1) || !inside(ct, x, z, 1)) continue;
        const margin = Math.min(...[ft,ct].flatMap(t => [0,1,2].map(i =>
          Math.abs(edge(t[i],t[(i+1)%3],x,z)) /
          Math.hypot(t[(i+1)%3][0]-t[i][0],t[(i+1)%3][2]-t[i][2]))));
        if (!witness || margin > witness.horizontalEdgeMargin) witness = {
          floorCog: floorIndex, ceilingCog: ceilingIndex, floorYaw: fyaw, ceilingYaw: cyaw,
          floorTriangle: fi, ceilingTriangle: ci, x, z, floor: ft, ceiling: ct,
          gap: ct[0][1]-ft[0][1], horizontalEdgeMargin: margin,
        };
      }
    }
  }
}
if (!witness) throw new Error("no pairwise cog witness found");
console.log(JSON.stringify({ scope: "US/JP pairwise geometry discovery only", cogs: us.cogs, witness }, null, 2));
