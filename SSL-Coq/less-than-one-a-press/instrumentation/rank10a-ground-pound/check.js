/* Offline source/Float32 diagnostic. No emulator, controller fixture, or
 * game-memory modification. A granted startup is NOT a reachable route. */
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');
const root = path.resolve(__dirname, '../..');
const source = path.join(root, 'build/pinned-sm64');
const read = relative => fs.readFileSync(path.join(source, relative), 'utf8');
const f = Math.fround;
const add = (a, b) => f(f(a) + f(b));
const sub = (a, b) => f(f(a) - f(b));
const mul = (a, b) => f(f(a) * f(b));

function body(text, name) {
  const match = new RegExp(`\\b${name}\\([^;]*?\\)\\s*\\{`).exec(text);
  assert(match, `missing function ${name}`);
  const begin = match.index + match[0].length;
  let depth = 1;
  for (let i = begin; i < text.length; ++i) {
    if (text[i] === '{') ++depth;
    if (text[i] === '}' && --depth === 0) return text.slice(begin, i);
  }
  assert.fail(`unterminated function ${name}`);
}
const airborne = read('src/game/mario_actions_airborne.c');
const gp = body(airborne, 'act_ground_pound');
assert.match(gp, /yOffset = 20 - 2 \* m->actionTimer/);
assert.match(gp, /m->pos\[1\] \+ yOffset \+ 160\.0f < m->ceilHeight/);
assert.match(gp, /m->vel\[1\] = -50\.0f/);
assert.match(gp, /mario_set_forward_vel\(m, 0\.0f\)/);
assert.match(gp, /m->actionTimer >= m->marioObj->header\.gfx\.animInfo\.curAnim->loopEnd \+ 4/);
assert.doesNotMatch(gp, /INPUT_[ABZ]_|update_air_(with|without)_turn/);
for (const name of ['act_forward_rollout', 'act_backward_rollout', 'act_jump_kick', 'act_dive']) {
  assert.doesNotMatch(body(airborne, name), /ACT_GROUND_POUND\b/);
}
assert.match(body(airborne, 'act_freefall'), /INPUT_Z_PRESSED[\s\S]*ACT_GROUND_POUND, 0/);
const mario = read('src/game/mario.c');
const geometry = body(mario, 'update_mario_geometry_inputs');
assert.match(geometry, /f32_find_wall_collision[\s\S]*f32_find_wall_collision[\s\S]*find_floor/);
assert.match(geometry, /m->pos\[1\] > m->floorHeight \+ 100\.0f/);
const elevator = read('src/game/behaviors/pyramid_elevator.inc.c');
assert.match(elevator, /o->oVelY = -10\.0f;\s*o->oPosY \+= o->oVelY/);

const animationFiles = ['assets/anims/anim_3C_3D.inc.c', 'assets/anims/anim_3B.inc.c'];
const loopEnds = animationFiles.map(relative => {
  const match = /static const struct Animation \w+\[\]\s*=\s*\{([\s\S]*?)ANIMINDEX_NUMPARTS/.exec(read(relative));
  assert(match);
  const fields = match[1].split(',').map(s => s.trim()).filter(Boolean).map(Number);
  assert.equal(fields.length, 5);
  return fields[4];
});
assert.deepEqual(loopEnds, [11, 16]);

function startup(mask, frames) {
  let y = f(4966), elevatorY = f(4966);
  const trace = [];
  for (let timer = 0; timer < frames; ++timer) {
    elevatorY = add(elevatorY, -10); // terrain before Mario
    if (timer < 10 && (mask & (1 << timer))) y = add(y, 20 - 2 * timer);
    trace.push({timer, y, elevatorY, relativeY: sub(y, elevatorY)});
  }
  return trace;
}
const normal = startup(1023, loopEnds[0] + 4);
assert.deepEqual(normal.map(p => p.relativeY),
  [30, 58, 84, 108, 130, 150, 168, 184, 198, 210, 220, 230, 240, 250, 260]);
for (let mask = 0; mask < 1024; ++mask) {
  for (const p of startup(mask, 15)) {
    assert(p.y <= 5076);
    assert(p.relativeY <= 260);
  }
}
const last = normal[normal.length - 1];
let y = last.y;
const elevatorY = add(last.elevatorY, -10);
const firstFall = [];
for (let quarter = 0; quarter < 4; ++quarter) {
  y = add(y, f(-50 / 4));
  firstFall.push(sub(y, elevatorY));
}
assert.deepEqual(firstFall, [257.5, 245, 232.5, 220]);

// Guard against overstating the general Coq theorem as an exact +110 bound
// relative to every fractional start. Crossing a Float32 binade can round up.
const fractionalEntry = f(4095.999755859375);
let fractionalEnd = fractionalEntry;
for (let timer = 0; timer < 10; ++timer) fractionalEnd = add(fractionalEnd, 20 - 2 * timer);
assert.equal(fractionalEnd, 4206);
assert(fractionalEnd - fractionalEntry > 110);
assert(fractionalEnd <= Math.ceil(fractionalEntry) + 110);

// Pure translation does not move Mario sideways. Test both zero signs: the
// standard speed setter may produce -0 from negative sine/cosine entries.
for (const trig of [-1, -0.75, -0, 0, 0.75, 1]) {
  const velocity = mul(trig, 0);
  assert.equal(velocity === 0, true);
  for (const position of [-410, 0, 411, 256]) assert.equal(add(position, f(velocity / 4)), position);
}
// This is a numeric floor-following control, not proof of live floor selection.
let floorCases = 0;
for (let bin = -16000; bin <= 16000; ++bin) {
  for (const fraction of [0, 0.125, 0.5, 0.875]) {
    const before = add(bin, fraction);
    const after = add(before, -10);
    assert(before < add(after, 100));
    ++floorCases;
  }
}
console.log(JSON.stringify({
  scope: 'offline conditional gameplay diagnostic; no clean entry asserted',
  animationLoopEnds: loopEnds,
  normalStartupUpdates: 15,
  maximalStartupRise: 110,
  normalRelativeHeights: normal.map(p => p.relativeY),
  firstDownwardQuarterHeights: firstFall,
  headroomSchedulesChecked: 1024,
  floorFollowingSamples: floorCases,
  fractionalRoundingControl: {entry: fractionalEntry, end: fractionalEnd},
  sourceHashes: Object.fromEntries(animationFiles.map(relative =>
    [relative, crypto.createHash('sha256').update(read(relative)).digest('hex')])),
}, null, 2));
