# GOAL 2 / E2 — attach-window + launch-constant census (re-audit with exact constants)

**Task:** E2 of `docs/goal2-strategy-v2-2026-07-01.md` (§7). Re-audit the prior
y-changer census (`docs/goal2-wmotr-y-changer-census.md`) under the v2
attach-window framing, with **exact constants cited to `vendor/sm64` file:line**
and every gate **quoted**, not paraphrased. No Coq. Sources read in full where
load-bearing: `mario_step.c`, `surface_collision.c` (find_floor/wall), and the
relevant `mario.c` / `mario_actions_airborne.c` / `mario_actions_moving.c` /
`mario_actions_cutscene.c` bodies.

**Headline results (read these first):**

1. **The ledge-grab wall gate in the v2 doc is BACKWARDS.** `check_ledge_grab`
   is reached only when the **upper** wall probe (`y+150`) returns **NULL** and
   the **lower** wall probe (`y+30`) returns **non-NULL** (`mario_step.c:471`).
   The v2 doc (§0.3, §3 table) says ledge-grab "requires a wall hit at y+150" —
   the opposite of the code. The margin argument built on that must be redone.
2. **The +316 chain (rollout 128 + GP 110 + land 78) is not realizable under
   no-A.** No no-A airborne action that carries ballistic height (dive, forward/
   backward rollout) exposes a `Z→ground-pound` cancel — only the *freefall*
   family does (`airborne.c:532`), and freefall launches at `vel[1]≈0`. So the
   ballistic apex (rollout +128) and the GP windup (+110) live in **separate
   episodes** and cannot compose. **Max single-episode attach height Δ_pot ≈
   +238 (ledge grab) or +206 (rollout apex 128 + land snap 78)** — not +316.
   This *matches the v2 doc's own §1 figure* (`Y_MAX ≈ H*+238`) and contradicts
   its §2 figure (`Δ_pot = 316..366`). The margin to the box top (+337) grows
   from the doc's ~21 units to **~99 units**. (E3 is the authority on episode
   composition; this is flagged there.)
3. **Discrete apex ≠ v²/8.** The prior census used the continuous `v²/8` (dive
   ≈50). The real per-frame recurrence gives dive apex **60**, rollout **128**.
4. **Anim y-translation into gameplay `pos[1]` is cutscene-only.** The only
   writer, `update_mario_pos_for_anim` (`mario.c:213`), is called from **4
   cutscene actions only** (doors + intro). No airborne/ground gameplay action
   applies anim vertical translation. The `return_mario_anim_y_translation`
   family is pole-only (absent). v2 §6.2's kill-risk is **resolved: ε = 0** in
   the airborne episode.
5. **Vertical layer is trig-free under no-A** (Census C: YES).

---

## The per-frame air recurrence (order of operations)

`perform_air_step` (`mario_step.c:610-655`) does, **per frame**:
1. loop `i=0..3`: `intendedPos[1] = m->pos[1] + m->vel[1]/4` then quarter-step
   (`mario_step.c:618-621`) — i.e. `pos += vel[1]` total over the 4 qsteps,
   using the **current** `vel[1]`;
2. **then** `apply_gravity(m)` (`mario_step.c:647`), which for the default case
   does `m->vel[1] -= 4.0f; if (m->vel[1] < -75.0f) m->vel[1] = -75.0f;`
   (`mario_step.c:576-579`).

So the launch velocity moves Mario on its **own** frame before gravity bites.
The height recurrence is `pos_{n+1} = pos_n + v_n`, `v_{n+1} = v_n − 4`, and

> **`apex(v0) = Σ (v0, v0−4, v0−8, …)` over strictly-positive terms** (a `0`
> term adds nothing). For `v0=4q`: `apex = 2q(q+1)`. For `v0=4q+2`:
> `apex = (v0+2)(q+1)/2`.

`apply_gravity` variants (all gate on `m->action`): cannon `−1` term `−75`
(`:539`); LONG_JUMP/SLIDE_KICK/BBH `−2` term `−75` (`:545`); LAVA_BOOST/
FALL_AFTER_STAR_GRAB `−3.2` term `−65` (`:550`); metal-water `−1.6` term `−16`
(`:563`); wing-cap+A-down `−2` clamp `−37.5` (`:569`, needs `INPUT_A_DOWN`);
**default `−4` term `−75`** (`:576`). No-A airborne uses the default `−4`.

---

## CENSUS A — ATTACH WINDOWS

Every code path by which an airborne (or step-taking) Mario becomes anchored to
a floor/surface, with the exact window above the probed position.

| # | mechanism | site | window | gate (quoted below) |
|---|---|---|---|---|
| A1 | landing snap-up | `perform_air_quarter_step` land branch, `mario_step.c:431,442` | **+78** above `nextPos[1]` (find_floor buffer) | `nextPos[1] <= floorHeight`, any air step |
| A2 | ledge grab | `check_ledge_grab`, `mario_step.c:348-386`, entered `:471` | **+238** above `nextPos[1]` (`160` search + `78` buffer), floor must be in `(+100, +238]` | `vel[1] <= 0` ∧ **upperWall(`+150`)==NULL** ∧ **lowerWall(`+30`)!=NULL** ∧ displacement-against-vel ∧ `ledge−nextPos > 100` ∧ stepArg has `LEDGE_GRAB` |
| A3 | ground step-up | `perform_ground_quarter_step`, `mario_step.c:302` | **+78** per qstep (×4/frame), onto real floors | grounded; `nextPos[1] <= floorHeight+100` ∧ `floorHeight+160 < ceilHeight` |
| A4 | ground "left-ground" snap | `mario_step.c:287-295` | sets `m->floor`/`floorHeight` (no up-teleport of pos beyond nextPos) | `nextPos[1] > floorHeight+100` ∧ `nextPos[1]+160 < ceilHeight` |
| A5 | ceiling hang grab | `perform_air_quarter_step`, `mario_step.c:451-454` | pins to hangable ceiling | `stepArg & AIR_STEP_CHECK_HANG` ∧ `m->ceil->type == SURFACE_HANGABLE` — **absent in WMotR** |
| A6 | ledge-grab teleport | `check_ledge_grab` `mario_step.c:377` + `common_air_action_step:431` | `m->pos := ledgePos` (the A2 floor), action→`ACT_LEDGE_GRAB` | consequence of A2 |
| A7 | squish steep-escape / up-warp | `act_squished`, `mario_actions_cutscene.c:1547-1571` | horizontal push `10`, `vel[1]=0`; escape→`ACT_IDLE` | needs `ACT_SQUISHED` ⇐ `INPUT_SQUISHED` ⇐ dynamic surface ≤150 gap — **dead in WMotR** (prior census §5) |
| A8 | object land / bounce pin | `bounce_off_object` `interaction.c:516` | `m->pos[1] = o->oPosY + o->hitboxHeight` | object-gated (Census B object section) |

### A1 — landing snap (window +78)
`mario_step.c:404` `floorHeight = find_floor(nextPos[0], nextPos[1], nextPos[2], &floor);`
— query y = `nextPos[1]`. `find_floor_from_list` accepts a floor iff
`surface_collision.c:459`:
```c
// Checks for floor interaction with a 78 unit buffer.
if (y - (height + -78.0f) < 0.0f) {   // skip iff  y < height - 78
    continue;
}
```
so the returned `height` satisfies `height <= y + 78 = nextPos[1] + 78`. Then
`mario_step.c:431-443`:
```c
if (nextPos[1] <= floorHeight) {
    ...
    m->pos[1] = floorHeight;          // snap UP, up to nextPos[1]+78
    return AIR_STEP_LANDED;
}
```
Confirms the **+78** window (v2 §3 correct). Note the "surface cucking" caveat
(`surface_collision.c:468`): only the *first* qualifying floor is returned, so
the snap-up realizes only when the higher floor precedes lower ones in the list;
+78 is the correct **upper bound**.

### A2 — ledge grab (window +238, gate CORRECTED)
Entry condition in `perform_air_quarter_step` (`mario_step.c:401-402, 471`):
```c
upperWall = resolve_and_return_wall_collisions(nextPos, 150.0f, 50.0f);
lowerWall = resolve_and_return_wall_collisions(nextPos, 30.0f, 50.0f);
...
if ((stepArg & AIR_STEP_CHECK_LEDGE_GRAB) && upperWall == NULL && lowerWall != NULL) {
    if (check_ledge_grab(m, lowerWall, intendedPos, nextPos)) {
        return AIR_STEP_GRABBED_LEDGE;
```
`resolve_and_return_wall_collisions(pos, offset, radius)` (`mario.c:521-529`)
probes walls at `y = pos[1] + offset` (via `collision.offsetY`, consumed at
`surface_collision.c:25` `y = data->y + data->offsetY`). So **upperWall = a wall
whose vertical span covers `nextPos[1]+150`; lowerWall = one covering
`nextPos[1]+30`.** The gate requires **upperWall == NULL** (no wall at head
height +150) and **lowerWall != NULL** (a wall at knee height +30) — i.e. a
*low* wall / ledge. This is the **opposite** of the v2 doc's "requires a wall hit
at y+150".

Additional gates and window in `check_ledge_grab` (`mario_step.c:348-386`):
```c
if (m->vel[1] > 0) { return FALSE; }                                  // :354  vel[1] <= 0 (==0 passes)
...
if (displacementX * m->vel[0] + displacementZ * m->vel[2] > 0.0f) {   // :363  wall pushed against velocity
    return FALSE;
}
//! Since the search for floors starts at y + 160, we will sometimes grab
// a higher ledge than expected (glitchy ledge grab)
ledgePos[1] = find_floor(ledgePos[0], nextPos[1] + 160.0f, ledgePos[2], &ledgeFloor);  // :371
if (ledgePos[1] - nextPos[1] <= 100.0f) { return FALSE; }             // :373  ledge must be > 100 above
```
find_floor query y = `nextPos[1]+160`, +78 buffer ⇒ `ledgePos[1] <=
nextPos[1]+238`. Combined with `:373`, the grabbed floor lies in
`(nextPos[1]+100, nextPos[1]+238]` → **window +238**. `check_ledge_grab` also
teleports (A6): `mario_step.c:377` `vec3f_copy(m->pos, ledgePos)`.

**Which airborne actions enable ledge grab?** `AIR_STEP_CHECK_LEDGE_GRAB`
(`= 0x1`, `sm64.h:75`) is passed by `perform_air_step`/`common_air_action_step`
at: `act_jump` (`:457`), `act_double_jump` (`:475`), **`act_freefall` (`:548`)**,
`act_hold_jump` (`:566`), `act_hold_freefall` (`:591`), `act_side_flip` (`:606`),
`act_wall_kick_air` (`:628`), `act_long_jump` (`:647`), `act_water_jump` (`:832`),
`act_top_of_pole_jump` (`:1964`), and cutscene sites (`cutscene.c:671,1469,1823`,
`perform_air_step(m, 1)`). **Under no-A only `act_freefall` (and hold-freefall,
needs a held object) qualifies** — all the jump-family entries are A-gated
(prior census §3b one-writer `INPUT_A_PRESSED`), water/pole are absent. Freefall
is reachable no-A (walk off an edge) and its `vel[1] <= 0` satisfies the gate.
The rollouts (`:1363,1404`) and dive (`:743`) pass **`0`** — **no ledge grab**.

### A3 — ground step-up (window +78/qstep, real floors)
`perform_ground_quarter_step` (`mario_step.c:258-320`): `floorHeight =
find_floor(nextPos[0], nextPos[1], nextPos[2], &floor)` with `nextPos[1] =
m->pos[1]` (`:330`), +78 buffer. If `nextPos[1] <= floorHeight+100` (`:287`
false) and `floorHeight+160 < ceilHeight` (`:298` false), then
`mario_step.c:302` `vec3f_set(m->pos, nextPos[0], floorHeight, nextPos[2])`
snaps `pos[1]` up to `floorHeight <= pos[1]+78`. The loop (`:327`) re-reads
`m->pos[1]` each of 4 qsteps, so a frame climbs up to `+4×78` over successive
real floors. Ladder-subsumed by the air window (v2 §3 correct).

### A5 — ceiling hang (absent)
`mario_step.c:446-454`: `if (nextPos[1] + 160.0f > ceilHeight) { if (m->vel[1]
>= 0.0f) { m->vel[1] = 0.0f; if ((stepArg & AIR_STEP_CHECK_HANG) && m->ceil !=
NULL && m->ceil->type == SURFACE_HANGABLE) return AIR_STEP_GRABBED_CEILING; ...`.
`AIR_STEP_CHECK_HANG` (`= 0x2`) is passed only by `act_jump` (`:457`, A-gated).
Needs `SURFACE_HANGABLE` — absent in WMotR (leveldata; confirm in E1).

### A7 — squish escape (dead)
`act_squished` (`mario_actions_cutscene.c`): steep-surface branch `:1559-1561`
`m->vel[0] = sins(surfAngle)*10; m->vel[2] = coss(surfAngle)*10; m->vel[1] = 0;`
then `if (perform_ground_step(m) == GROUND_STEP_LEFT_GROUND) { m->squishTimer =
0; set_mario_action(m, ACT_IDLE, 0); }` (`:1564-1568`). Push is **horizontal**
(`vel[1]=0`). Reaching `ACT_SQUISHED` needs `INPUT_SQUISHED` (dynamic surface,
≤150 gap) — **no reachable squish spot in WMotR** (prior census §5, kill 1;
carried unchanged). Dead.

### Sweep: every `m->pos[1] =` / `m->floorHeight =` upward write in the step + airborne code
- `mario_step.c:230,249,442,461,416` `pos[1] = floorHeight`/`m->floorHeight`
  (step snaps, downwarps) — **PIN**, ≤ probed floor (+78 for A1).
- `mario_step.c:420,465` `pos[1] = nextPos[1]` (HIT_WALL, integration result) —
  bounded by the ballistic envelope (Census B).
- `airborne.c:928` `m->pos[1] += yOffset` — **ground-pound windup**, Census B.
- `airborne.c:1863` `m->pos[1] = m->usedObj->oPosY - 92.5f` (riding hoot) —
  **ABSENT** (no hoot).
- `airborne.c:676` `m->marioObj->header.gfx.pos[1] += 42.0f` — **gfx only**, N/A.
- No other airborne `pos[1]`/`floorHeight` up-writes.

---

## CENSUS B — LAUNCH CONSTANTS (no-A)

Every site that writes `m->vel[1]` to a positive value (the only lift channel:
`pos += vel[1]/4` per qstep), plus the two non-`vel[1]` lifters (GP windup, anim
translation). Apex computed with the discrete recurrence (gravity `−4`).

### B.1 — Reachable without A (the honest kit)

| # | site | constant | action / entry (no-A) | apex |
|---|---|---|---|---|
| B1 | `moving.c:491` | `vel[1] = 20.0f` | ground B-dive → `ACT_DIVE` | **+60** |
| B2 | `airborne.c:1355` | `vel[1] = 30.0f` | `act_forward_rollout` | **+128** |
| B3 | `airborne.c:1396` | `vel[1] = 30.0f` | `act_backward_rollout` | **+128** |
| B4 | `airborne.c:926-928` | `pos[1] += (20 − 2·actionTimer)` | `act_ground_pound` windup | **+110** (Σ, not ballistic) |

**B1 (ground dive, vel=20).** `check_ground_dive_or_punch` (`moving.c:485-496`):
```c
if (m->input & INPUT_B_PRESSED) {
    //! Speed kick (shoutouts to SimpleFlips)
    if (m->forwardVel >= 29.0f && m->controller->stickMag > 48.0f) {
        m->vel[1] = 20.0f;
        return set_mario_action(m, ACT_DIVE, 1);
    }
    return set_mario_action(m, ACT_MOVE_PUNCHING, 0);
}
```
Gate: `INPUT_B_PRESSED` ∧ `forwardVel >= 29.0f` ∧ `stickMag > 48.0f` — no A.
Reachable running on the spawn island. `set_mario_action_airborne`'s `ACT_DIVE`
case (`mario.c:856-861`) sets only forwardVel (cap 48), **not vel[1]** — the
`vel[1]=20` here is the only upward dive impulse. apex(20) = `20+16+12+8+4 =`
**60**. (Air-dive entries — `act_freefall:528` B-press, `check_kick_or_dive_in_air`
— do **not** re-set `vel[1]`, so they keep the pre-existing ≤0 vel: no lift.)

**B2/B3 (rollout, vel=30).** `act_forward_rollout` (`airborne.c:1353-1357`):
```c
if (m->actionState == 0) {
    m->vel[1] = 30.0f;
    m->actionState = 1;
}
```
(identical `:1396` for backward). apex(30) = `30+26+22+18+14+10+6+2 =` **128**.
Entered **without A** from a grounded slide via B: `act_dive_slide`
(`moving.c:1557-1563`) `if (!(m->input & INPUT_ABOVE_SLIDE) && (m->input &
(INPUT_A_PRESSED | INPUT_B_PRESSED))) return set_mario_action(m, m->forwardVel >
0.0f ? ACT_FORWARD_ROLLOUT : ACT_BACKWARD_ROLLOUT, 0);` — **B works**; likewise
`stomach_slide_action` (`moving.c:1521-1528`). Chain: run → B-dive (B1) → land
→ `ACT_DIVE_SLIDE` (`act_dive:768`) → B → rollout. (`act_slide_kick_slide:1490`
`→ ACT_FORWARD_ROLLOUT` is `INPUT_A_PRESSED`-gated — that path is A-gated, but
the dive-slide/stomach-slide paths are not.)

**B4 (ground-pound windup, +110).** `act_ground_pound` (`airborne.c:924-932`):
```c
if (m->actionState == 0) {
    if (m->actionTimer < 10) {
        yOffset = 20 - 2 * m->actionTimer;
        if (m->pos[1] + yOffset + 160.0f < m->ceilHeight) {
            m->pos[1] += yOffset;
            m->peakHeight = m->pos[1];
            ...
```
`yOffset` over `actionTimer = 0..9` is `20,18,…,2`, `Σ = 2·(1+…+10) =` **110**.
Ceiling gate `pos[1] + yOffset + 160 < ceilHeight`: in WMotR open sky
`ceilHeight = CELL_HEIGHT_LIMIT = 20000` (`surface_collision.h:13`) ⇒ passes.
No horizontal integration during windup (`perform_air_step` runs only in
`actionState==1`, `:951`).

**GP entry under no-A.** `ACT_GROUND_POUND` is set on `INPUT_Z_PRESSED` inside
the jump family (`airborne.c:451,470,489,510,561,600,623` — all A-gated) and
**inside `act_freefall` (`airborne.c:532`)**:
```c
if (m->input & INPUT_Z_PRESSED) {
    return set_mario_action(m, ACT_GROUND_POUND, 0);   // airborne.c:532-533, act_freefall
}
```
Freefall is no-A reachable. So **GP is reachable no-A, but only from freefall**
(and hold-freefall `:587`). Because freefall launches at `vel[1] ≈ 0`, the GP
windup adds +110 to a near-floor height. **Crucially: `act_dive` and the
rollouts contain no `INPUT_Z_PRESSED` check** (verified `:725-793`, `:1353-1392`,
`:1394-1432`) and never transition to freefall mid-air — so **the ballistic
apex cannot feed a GP windup within one episode.** (See DISCREPANCIES.)

### B.2 — A-gated (dead via one-writer `INPUT_A_PRESSED`; prior census §3b)

All routed through `set_mario_action_airborne` (`mario.c:788-891`) via A-gated
jump transitions, or explicit A-branches. Constants + apex (gravity `−4` unless
noted); `set_mario_y_vel_based_on_fspeed(m, base, mult)` adds `forwardVel·mult`
(`mario.c:767-770`).

| site | vel[1] | action | apex(base) |
|---|---|---|---|
| `mario.c:824` | `42 + 0.25·fVel` | ACT_JUMP / HOLD_JUMP | 242 |
| `mario.c:808` | `42` | ACT_WATER_JUMP (arg0) | 242 |
| `mario.c:818` | `42 + 0.25·fVel` | ACT_RIDING_SHELL_JUMP | 242 |
| `mario.c:845` | `42 + 0.25·fVel` | ACT_STEEP_JUMP | 242 |
| `mario.c:786`* | `52 + 0.25·fVel` | ACT_DOUBLE_JUMP | 364 |
| `mario.c:793`* | `62` | ACT_BACKFLIP | 512 |
| `mario.c:798`* | `69` | ACT_TRIPLE_JUMP | 630 |
| `mario.c:830` | `62` | ACT_WALL_KICK_AIR / TOP_OF_POLE_JUMP | 512 |
| `mario.c:838` | `62` | ACT_SIDE_FLIP | 512 |
| `mario.c:802` | `82` | ACT_FLYING_TRIPLE_JUMP | 882 |
| `mario.c:813` | `31.5` | ACT_BURNING_JUMP | 140 (absent: fire) |
| `mario.c:865` | `30` | ACT_LONG_JUMP (gravity `−2`!) | **240** |
| `mario.c:876` | `12` | ACT_SLIDE_KICK (gravity `−2`!) | **42** |
| `mario.c:883` | `20` | ACT_JUMP_KICK | 60 |
| `airborne.c:1316` | `52` | `act_air_hit_wall`, in `if (INPUT_A_PRESSED)` | 364 |
| `airborne.c:2022` | `42` | `act_special_triple_jump` (on land) | 242 |
| `airborne.c:364` | `fVel·sins(pitch)` | ACT_FLYING / twirl vel | (flying; A + taint-T) |

*\* base constants at `mario.c:786/793/798` are inside `set_mario_action_airborne`
cases ACT_DOUBLE_JUMP/ACT_BACKFLIP/ACT_TRIPLE_JUMP (lines 785-799).*

Note `mario.c:769` `m->vel[1] *= 0.5f` (squish/quicksand halving) only scales an
existing jump vel. LONG_JUMP and SLIDE_KICK use the `−2` gravity branch
(`mario_step.c:543-548`), so their apexes differ (240, 42) — but both A-gated.

### B.3 — ABSENT (needs an object/surface WMotR lacks) — constants for the record

| site | vel[1] | mechanism | why absent |
|---|---|---|---|
| `mario.c:850`, `airborne.c:1534` | `84` | ACT_LAVA_BOOST | no lava (apex 924) |
| `mario.c:943` | `32` | metal-water jump | no water |
| `mario.c:955` | `52` | ACT_EMERGE_FROM_PIPE | no pipe |
| `mario.c:968` | `64` | special/death exit airborne | leaves level |
| `airborne.c:1039/1044/1049` | `45/60/100` | `act_crazy_box_bounce` | no `bhvJumpingBox` (prior §2); apex 276/480/1300 |
| `automatic.c:732/778/786` | `100·sin / +1 / 20` | tweester/tornado | no tweester |
| `mario_step.c:598` | `+= maxVelY/8` | `apply_vertical_wind` | needs `SURFACE_VERTICAL_WIND` |
| `mario_step.c:661` | `fVel·sins(pitch)` | `set_vel_from_pitch_and_yaw` | **DEAD** (0 callers) |
| `interaction.c:592` | `20` | hoot bounce | no hoot |
| `interaction.c:1148` | `12` | twirl bounce | no twirl object |
| `submerged.c:*`, `cutscene.c:*`, `heave_ho`, `chuckya` | various | swim/scripted/enemy | absent |

### B.4 — OBJECT-GATED (kept separate per task; reachability ⇐ E1 inventory)

`bounce_off_object` (`interaction.c:515-518`): `m->pos[1] = o->oPosY +
o->hitboxHeight; m->vel[1] = velY;`. Callers:

| site | velY | handler | interaction type | apex |
|---|---|---|---|---|
| `interaction.c:1347` | `80` | `interact_hit_from_below` | INTERACT_HIT_FROM_BELOW | 924 |
| `interaction.c:1354` | `30` | `interact_hit_from_below` | " | 128 |
| `interaction.c:1385` | `80` | `interact_bounce_top` | INTERACT_BOUNCE_TOP/TOP2/KOOPA | 924 |
| `interaction.c:1392` | `30` | `interact_bounce_top` | " | 128 |
| `interaction.c:1446` | `30` | `interact_breakable` | INTERACT_BREAKABLE | 128 |

`interact_bounce_top` is enemy-stomp (Goomba/Koopa/…) — **WMotR has no enemies**
⇒ absent. `interact_hit_from_below` (hit-from-below objects) and
`interact_breakable` (breakable blocks) need the corresponding objects — the
WMotR object list (E1) must confirm none present. Note `bounce_off_object` also
*pins* `pos[1]` to the object top (`oPosY + hitboxHeight`), gated on Mario being
above the object; the ladder already excludes reaching box tops (v2 §4,
non-circular). Also `interaction.c:590-593` (`vel[1]>=20` clamp on landing on an
object) is object-land, same gating.

### B.5 — anim y-translation (v2 §6.2 kill-risk — RESOLVED)

The sole writer of gameplay `pos[1]` from animation is
`update_mario_pos_for_anim` (`mario.c:207-217`):
```c
if (flags & (ANIM_FLAG_VERT_TRANS | ANIM_FLAG_6)) {
    m->pos[1] += (f32) translation[1];
}
```
Its **only** callers are 4 cutscene actions: `act_unlocking_key_door`
(`cutscene.c:799`), `act_unlocking_star_door` (`:852`), `act_going_through_door`
(`:933`), `act_intro_cutscene` (`:1881`). **No airborne or moving/stationary
gameplay action calls it.** The `return_mario_anim_y_translation` family
(`mario.c:226`) is called only from `set_pole_position` (`automatic.c:278,295`)
— pole-only, absent. **Conclusion:** in the no-A airborne episode (dive /
rollout / GP / freefall) the anim vertical translation `ε = 0`. The door/intro
sites are A/key/star-gated or one-time spawn, and grounded (Φ_ground re-snaps y).
This closes v2 §6.2 and the prior census §7 "anim-ε" honesty item for the
airborne bound.

---

## CENSUS C — sins/coss VERTICAL CHECK (v2 §5.3)

For every no-A vertical launch (B.1): is the assigned `vel[1]` ever a product of
`sins`/`coss` table lookups?

| row | `vel[1]` expression | trig? |
|---|---|---|
| B1 dive | `20.0f` (constant, `moving.c:491`) | no |
| B2/B3 rollout | `30.0f` (constant, `airborne.c:1355/1396`) | no |
| B4 GP windup | `20 − 2·actionTimer` (integer, `airborne.c:926`) | no |
| gravity | `vel[1] −= 4.0f` (`mario_step.c:576`) | no |

The `sins`/`coss`-shaped **vertical** writes are all A-gated / absent / dead:
`airborne.c:364` `vel[1] = forwardVel·sins(faceAngle[0])` (ACT_FLYING/twirl,
A + taint-T); `mario_step.c:661` `set_vel_from_pitch_and_yaw` (DEAD, 0 callers).
The squish steep-push (`cutscene.c:1559-1561`) sets `vel[0]/vel[2]` from trig but
`vel[1]=0` (horizontal), and is dead anyway. Steep-slope re-launch, bully
knockback, water, lava boost — all absent (E1 surface census; snow level, no
lava/water/wind volumes).

> **VERDICT: the vertical layer is trig-free under no-A in WMotR: YES.**
> (Trig feeds only horizontal `vel[0]/vel[2]` on the no-A reachable paths; the
> only trig-vertical writes — `act_flying`, `set_vel_from_pitch_and_yaw`,
> squish-push — are A-gated, dead, or horizontal.) The float layer (v2 §5) may
> ignore the `sins/coss` table for the height bound; it needs only the exact
> constants `{20, 30, 4, (20−2t)}` and the comparison thresholds
> `{78, 100, 160, 150, 30}`.

---

## CONSTANTS SUMMARY (exact, cited)

| constant | value | site |
|---|---|---|
| find_floor buffer | **+78** | `surface_collision.c:459` |
| find_ceil buffer | −78 | `surface_collision.c:288` |
| ledge-grab search offset | **+160** | `mario_step.c:371` |
| ledge-grab min height | **> +100** | `mario_step.c:373` |
| ledge-grab window (160+78) | **+238**, floor ∈ (+100,+238] | `mario_step.c:371,373` |
| air wall probes (offset,radius) | upper **150**/50, lower **30**/50 | `mario_step.c:401-402` |
| ground wall probes | lower **30**/24, upper **60**/50 | `mario_step.c:267-268` |
| ceiling-block headroom (air) | +160 | `mario_step.c:446` |
| ground step-up gate | +100 / +160 | `mario_step.c:287,298` |
| gravity (default) | **−4.0**, term **−75.0** | `mario_step.c:576-577` |
| gravity (long jump/slide kick) | −2.0, term −75.0 | `mario_step.c:545-546` |
| GP windup total | **+110** (`Σ 20−2t`, t=0..9) | `airborne.c:926-928` |
| dive impulse | **20** | `moving.c:491` |
| rollout impulse | **30** | `airborne.c:1355/1396` |
| CELL_HEIGHT_LIMIT | 20000 | `surface_collision.h:13` |
| FLOOR_LOWER_LIMIT | −11000 | `surface_collision.h:14` |

**Discrete apex table** (`apex(v0) = Σ positive (v0, v0−4, …)`, gravity −4):

| v0 | 12 | 20 | 30 | 31.5 | 42 | 45 | 52 | 60 | 62 | 69 | 82 | 84 | 100 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| apex | 24 | **60** | **128** | 140 | 242 | 276 | 364 | 480 | 512 | 630 | 882 | 924 | 1300 |

(gravity −2 variants: apex(30)=240 [long jump], apex(12)=42 [slide kick].)

**No-A Δ_pot roll-up (single episode, from a launch floor h₀ ≤ H\*):**
- landing snap after ballistic: `max ballistic apex + 78 = 128 (rollout) + 78 =` **+206**
- ledge grab (freefall, if grabbable geometry exists): **+238**
- GP windup + descent snap: `110` then a first-descent snap ≤ `+78` above a
  lower point ⇒ ≲ **+175**
- dive apex + snap: `60 + 78 =` **+138**

⇒ **Δ_pot ≈ +238** (ledge grab dominant), else **+206** if WMotR has no
grabbable ledge. `Y_MAX ≈ h₀ + 238 ≈ 1675 + 238 = 1913`.

---

## DISCREPANCIES vs the prior docs

1. **Ledge-grab wall gate is inverted (v2 §0.3, §3 table).** v2 says ledge grab
   "requires a wall hit at y+150"; the code requires **upperWall(+150)==NULL and
   lowerWall(+30)!=NULL** (`mario_step.c:471`). Any margin argument that relied
   on "the box underside at +315 stays above the y+150 wall probe" is void — the
   correct question is whether WMotR geometry presents a *low* wall (span reaches
   +30 but not +150) with a floor 100–238 above and displacement-against-vel.
   That is a leveldata question for E1/E3.

2. **The +316 chain is not realizable under no-A (v2 §0.3, §2).** v2's worst case
   "rollout `vel=30` apex +128 → mid-air GP windup +110 → land +78 = +316" needs
   GP to follow a rollout within one airborne episode. But **no ballistic-
   carrying no-A action exposes `Z→GP`**: `act_dive` (`:725-793`) and both
   rollouts (`:1353-1432`) have no `INPUT_Z_PRESSED` check and never enter
   freefall mid-air; only `act_freefall` (`:532`) has the Z→GP cancel, and it
   launches at `vel[1]≈0`. So apex and GP windup are **disjoint episodes**.
   **Corrected Δ_pot ≈ +238, not +316.** This *agrees with v2 §1*
   (`Y_MAX ≈ H*+238`) — so the v2 doc is internally inconsistent (§1 vs §2); §1
   is right. **The box-top margin grows from ~21 to ~99 units** (box top +337 −
   Δ_pot 238). *E3 (episode graph) is the authority on composition — this is
   flagged there, with the code evidence above.*

3. **Discrete apex vs `v²/8` (prior census §3, §7).** Prior census used
   continuous `v²/8`: dive ≈50, rollout ≈112. The real discrete recurrence gives
   **dive 60, rollout 128** (higher by ~20% and ~14%). v2 §0.3 already used 128
   for rollout (correct); the old y-changer census's "≤112 kit maximum" and
   "≈1790 ceiling" are slightly low and should read rollout apex **128**, kit
   ballistic max **128**, and the attach-inclusive ceiling **h₀ + 238 ≈ 1913**.

4. **Anim-ε is zero in the airborne episode (v2 §6.2, prior §7).** Both docs flag
   anim y-translation as an open kill-risk / "ε". It is **cutscene-only**
   (`update_mario_pos_for_anim` callers are 4 door/intro actions), so ε = 0 for
   dive/rollout/GP/freefall. The remaining honest item is only that the door/
   intro/spawn cutscenes (if any run under no-A entry) apply a bounded, grounded
   anim delta — not a per-frame airborne ratchet.

5. **Box collision span 315–337 (prior §5 "≈315", v2 "≈337").** The two docs cite
   different numbers for the same box; they are the **two faces** of the box
   collision cube: underside `oHomeY+30 = +315`, top `oHomeY+52 = +337` above the
   spawn floor (1675). The *attach target* (landing on / grabbing the box) is the
   **top at +337**. Δ_pot 238 < 337 with ~99 units to spare. (Exact box home Ys
   and floor height are E1's to pin.)

---

## OPEN ITEMS (could not resolve in a pure C read)

- **Grabbable-ledge geometry in WMotR (A2).** Δ_pot=238 assumes some reachable
  configuration with a low wall (spans +30, not +150), a floor 100–238 above,
  and the displacement/velocity condition. Whether WMotR's mesh + box models
  present such a config near a reachable floor is **leveldata (E1/E3)**. If none
  exists, Δ_pot drops to +206 (rollout apex + land snap).
- **Freefall never rises (episode-graph obligation).** I confirmed dive/rollout
  don't expose Z→GP and don't fall into freefall mid-air, but a *full* proof that
  no no-A airborne action re-enters freefall (or any Z→GP / ledge-grab state)
  while `vel[1] > 0` is E3's edge-by-edge job. My claim rests on reading the four
  relevant bodies, not the whole air-action transition graph.
- **WMotR entry/spawn vel & action (prior §7).** Confirm the WMotR spawn action
  imparts no upward `vel[1]` and is not a cutscene applying anim translation —
  E1 inventory (spawn/warp data).
- **`m->ceilHeight` staleness in GP windup gate.** During `actionState==0` no air
  step runs, so `m->ceilHeight` is whatever the last step set. In open sky this
  is large (gate passes, +110 realized); under a real ceiling the gate could clip
  the windup. Not height-relevant for the upper bound (open sky is worst case).
- **Object-gated bounces (B.4).** Final reachability needs the E1 object list to
  confirm no `INTERACT_HIT_FROM_BELOW` / `INTERACT_BREAKABLE` / bounce-top object
  is present and reachable in WMotR.
