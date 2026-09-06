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

// Bounded ordinary-wall response, not a live collision or reachability proof.
// The no-floor/low-ceiling HIT_WALL returns do not use this yaw test.
const step = body(read('src/game/mario_step.c'), 'perform_air_quarter_step');
assert.match(step, /wallDYaw = atan2s\(m->wall->normal.z, m->wall->normal.x\) - m->faceAngle\[1\]/);
assert.match(step, /wallDYaw < -0x6000 \|\| wallDYaw > 0x6000/);
assert.match(gp, /stepResult == AIR_STEP_HIT_WALL[\s\S]*mario_set_forward_vel\(m, -16\.0f\)/);
const speedSetter = body(mario, 'mario_set_forward_vel');
assert.match(speedSetter, /sins\(m->faceAngle\[1\]\) \* m->forwardVel/);
assert.match(speedSetter, /coss\(m->faceAngle\[1\]\) \* m->forwardVel/);
// Read the intended overlapping sine/cosine VALUES, not runtime addresses.
const trig = [...read('include/trig_tables.inc.c').matchAll(/(-?\d+\.\d+)f/g)]
  .map(m => f(Number(m[1])));
assert.equal(trig.length, 5120);
const mesh = read('levels/ssl/pyramid_elevator/collision.inc.c');
const vertices = [...mesh.matchAll(/COL_VERTEX\((-?\d+),\s*(-?\d+),\s*(-?\d+)\)/g)]
  .map(m => m.slice(1).map(Number));
const faces = [...mesh.matchAll(/COL_TRI\((\d+),\s*(\d+),\s*(\d+)\)/g)]
  .map(m => m.slice(1).map(Number).map(i => vertices[i]));
const normals = new Map();
let innerTriangles = 0;
for (const [a, b, c] of faces) {
  const axis = [0, 2].find(i => a[i] === b[i] && b[i] === c[i] && Math.abs(a[i]) < 500);
  if (axis === undefined) continue;
  const u = b.map((v, i) => v - a[i]), v = c.map((n, i) => n - b[i]);
  const cross = [u[1]*v[2]-u[2]*v[1], u[2]*v[0]-u[0]*v[2], u[0]*v[1]-u[1]*v[0]];
  const sign = Math.sign(cross[axis]);
  assert(sign * a[axis] < 0, 'inner face must point into the elevator');
  normals.set(`${axis}:${sign}`, {axis, sign});
  ++innerTriangles;
}
assert.equal(innerTriangles, 8);
assert.equal(normals.size, 4);
let wallKickCases = 0, minInwardSpeed = Infinity;
for (const {axis, sign} of normals.values()) {
  const normalYaw = axis === 0 ? (sign > 0 ? 0x4000 : 0xc000) : (sign > 0 ? 0 : 0x8000);
  let accepted = 0;
  for (let yaw = 0; yaw < 65536; ++yaw) {
    const dyaw = ((normalYaw - yaw + 32768) & 65535) - 32768;
    if (!(dyaw < -0x6000 || dyaw > 0x6000)) continue;
    const velocity = mul(trig[(yaw >>> 4) + (axis === 2 ? 1024 : 0)], -16);
    const inward = mul(velocity, sign);
    assert(inward > 0, 'ordinary wall response must not launch through that inner face');
    minInwardSpeed = Math.min(minInwardSpeed, inward);
    ++accepted; ++wallKickCases;
  }
  assert.equal(accepted, 16383);
}

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
  innerWallResponse: {innerTriangles, facingsTested: 4 * 65536,
    acceptedWallHitCases: wallKickCases, minInwardSpeed,
    scope: 'same-face ordinary wall yaw return only; other returns and later collisions excluded'},
  fractionalRoundingControl: {entry: fractionalEntry, end: fractionalEnd},
  sourceHashes: Object.fromEntries(animationFiles.map(relative =>
    [relative, crypto.createHash('sha256').update(read(relative)).digest('hex')])),
}, null, 2));
