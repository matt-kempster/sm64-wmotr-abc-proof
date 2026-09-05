#!/usr/bin/env node
"use strict";

// A read-only vertical-physics diagnostic, NOT a controller movie or an
// emulator fixture. The Coq module separately proves the Float32 envelope.
// Grant the full knockback apex (even when the enemy would die earlier), a
// further 78-unit loot-floor lift, every 16-bit random return, and later
// bounces on that same floor. No claim about reaching the initial heights,
// X/Z, moving to higher floors, water, or the star's later home sample.
const assert = require("node:assert/strict");
const f = Math.fround;
const step = (y, v) => {
  v = f(v - 4);
  if (v < -78) v = -78;
  return [f(y + v), v];
};
const cases = [];
for (const origin of [-101, 0, 640, 1145, 2517]) {
  let enemyPeak = origin;
  for (const launch of [30, 50]) {
    let y = origin, v = launch;
    for (let n = 0; n < 40; n++) {
      [y, v] = step(y, v);
      enemyPeak = Math.max(enemyPeak, y);
      assert(y <= origin + 312);
    }
  }
  assert.equal(enemyPeak, origin + 288);
  const grantedSpawn = enemyPeak + 78;
  let coinPeak = grantedSpawn, fallingPeak = grantedSpawn;
  for (let word = 0; word < 65536; word++) {
    let v = f(f(f(f(word / 65536) * 10) + 30) + 20);
    let y = grantedSpawn;
    let tangible = false;
    for (let n = 0; n < 120; n++) {
      [y, v] = step(y, v);
      if (y < grantedSpawn) {
        y = grantedSpawn;
        if (v < 0) v = f(v * f(-0.7));
      }
      // Keep bounciness forever, a favorable over-approximation of the coin
      // loop's later switch to zero. Neither a copied floor nor a re-jump is
      // hidden in this test.
      if (v < 0) tangible = true;
      coinPeak = Math.max(coinPeak, y);
      if (tangible) fallingPeak = Math.max(fallingPeak, y);
      assert(y <= origin + 810);
      assert(v <= 60 && v >= -78);
    }
  }
  cases.push({
    origin, enemyPeak, grantedSpawn, coinPeak, tangibleCoinPeak: fallingPeak,
    coqCoinCeiling: origin + 810,
    coqContactMarioCeiling: origin + 874,
    minimumExtraRiseToHome3505: 3505 - (origin + 874),
  });
}
console.log(JSON.stringify({
  scope: "Vertical projection diagnostic only; gameplay reachability remains open",
  randomReturnsPerOrigin: 65536,
  movingUpdatesPerToss: 120,
  pausedUpdates: "Omitting movement leaves this projection unchanged",
  cases,
}, null, 2));
