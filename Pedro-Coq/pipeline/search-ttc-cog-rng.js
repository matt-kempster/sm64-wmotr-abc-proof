#!/usr/bin/env node
"use strict";

// Finite discovery in DustPRNG's recurrence projection, not retail execution.
// The model has two zero-speed/zero-target cogs with consecutive RNG pairs,
// then k other calls and either zero or four accepted dust-owned calls.
function R(seed) {
  if (seed === 22026) seed = 0;
  let t = (((seed & 255) << 8) ^ seed) & 65535;
  seed = (((t & 255) << 8) + ((t & 65280) >>> 8)) & 65535;
  t = (((t & 255) << 1) ^ seed) & 65535;
  const u = ((t >>> 1) ^ 65408) & 65535;
  return (t & 1) === 0 ? (u === 43605 ? 0 : (u ^ 8180)) : (u ^ 33152);
}
function steps(s, n) { while (n--) s = R(s); return s; }
if (R(0) !== 57460 || R(57460) !== 55882 || R(22026) !== R(0))
  throw new Error("recurrence sanity check failed");
function canFreezePair(s) { return R(s) % 7 === 0 && steps(s, 3) % 7 === 0; }
let tap, leaf;
for (let s = 0; s < 65536; ++s) {
  if (leaf === undefined && R(s) % 7 === 0 && steps(s, 2) >= 32767)
    leaf = { seed: s, magnitudeDraw: R(s), signDraw: steps(s,2) };
  if (tap === undefined && !canFreezePair(s) && canFreezePair(steps(s,4)))
    tap = { seed: s, dustSeed: steps(s,4),
      neutralDraws: [1,2,3,4].map(n=>steps(s,n)),
      dustDraws: [5,6,7,8].map(n=>steps(s,n)) };
}
function graph(k) {
  const vertices = Array.from({length:65536},(_,s)=>s).filter(canFreezePair);
  const valid = new Set(vertices);
  const edges = new Map(vertices.map(s => [s, [0,4].map(d => ({dust:d, next:steps(s,4+k+d)}))
    .filter(e => valid.has(e.next))]));
  const reverse = new Map(vertices.map(s=>[s,[]]));
  const degree = new Map(), longest = new Map(vertices.map(s=>[s,1]));
  for (const s of vertices) {
    degree.set(s,edges.get(s).length);
    for (const e of edges.get(s)) reverse.get(e.next).push(s);
  }
  const queue = vertices.filter(s=>degree.get(s)===0);
  for (let i=0;i<queue.length;++i) for (const prev of reverse.get(queue[i])) {
    longest.set(prev,Math.max(longest.get(prev),longest.get(queue[i])+1));
    degree.set(prev,degree.get(prev)-1);
    if (degree.get(prev)===0) queue.push(prev);
  }
  const recurrent = vertices.filter(s=>degree.get(s)>0);
  return { otherCalls:k, validPairSeeds:vertices.length,
    seedsWithInfiniteContinuation:recurrent.length,
    maxConsecutiveZeroTargetUpdates:recurrent.length ? null : Math.max(...longest.values()) };
}
console.log(JSON.stringify({ scope: "isolated recurrence projection; other calls are a parameter",
  leaf, tap, graphs:Array.from({length:9},(_,k)=>graph(k)) },null,2));
