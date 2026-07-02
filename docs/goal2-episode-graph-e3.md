# GOAL 2 / E3 — the mid-air action-transition (episode) graph under no-A in WMotR

**Task:** E3 of `docs/goal2-strategy-v2-2026-07-01.md` §4 (the "episode graph"
= P6a re-scoped). Enumerate every reachable-under-no-A airborne / attached
action node, every **mid-air** edge between them (a transition that fires
*without* an `AIR_STEP_LANDED` attach), and give each live edge a **potential
verdict** (preserve / spend / credit). Answer the six named adjudications.
Produce the definitive per-mechanism `Δ_pot` and re-check it against E1's
robustness thresholds. **C-source reading only** (`vendor/sm64`), no Coq.
Composition authority for E2's deferred items.

Model version: **VERSION_US** (`Makefile:23` `-DVERSION_US=1`) — matters for the
ledge-climb `A_DOWN` guard (§4e).

`Pot(m) = B2R(pos[1]) + ballistic(vel[1]) + windup_credit(m)`, with
`ballistic(v) = Σ (v, v−4, v−8, …)` over strictly-positive terms (E2's discrete
recurrence; gravity `−4`, `mario_step.c:576`), `ballistic(v)=0` for `v ≤ 0`.

---

## HEADLINE RESULTS (read first)

1. **The dominant no-A attach mechanism is NOT ledge-grab — it is the
   butt-slide-air / slide-kick *landing bounce*** (`vel[1] = -vel[1]/2`,
   `airborne.c:1445` / `:1604`), which E2's launch census missed (it enumerated
   *constant* `vel[1] :=` writes; the bounce is data-dependent). Terminal
   velocity is clamped at `−75` (`mario_step.c:577`), so the bounce re-launches
   at up to `vel[1] = 37.5`, `ballistic(37.5) = 195`, + landing snap `78` ⇒
   **raw single-episode `Δ_pot = +273`** — above E2's `+238` (ledge) and `+206`
   (rollout apex + snap). Under the *coupled* invariant (bounce recovers only ¼
   of the fall it came from) it contracts to **≤ +138**; under terminal-velocity
   only it is **+273**. Either bound is `< 337` (E1 gap) and `< 668` (E1
   coin-safe). **Verdict holds; the driving constant changes.**

2. **The `+316` GP-composition chain is confirmed dead** (E2 point 2). No
   ballistic-carrying no-A action exposes a mid-air `Z→ground-pound`. The
   `Z→GP` cancel exists only in `act_freefall` (`:532`) and the hold/hang
   families, and freefall is **only ever entered descending or at `vel≈0`**
   (every mid-air `→ACT_FREEFALL` edge — `airborne.c:1437`, `:1587`,
   ground-leave — carries `vel[1] ≤ 0`). So GP windup (`+110`) never composes
   with a positive ballistic apex. GP's own episode maxes at **`+176`** (windup
   `110` + first-descent snap `65.5`).

3. **The graph has NO potential-increasing *cycle*.** Every positive `vel[1]`
   write is either (a) an episode-*start* launch from a floor `≤ H*` (dive 20,
   rollout 30, slide-kick 12), (b) a once-per-episode landing bounce
   (contraction), or (c) `A`/`A_DOWN`-gated / object-gated / absent. No
   reachable airborne action re-sets a positive `vel[1]` to a constant mid-air
   (the only such site, `act_air_hit_wall:1316` `vel=52`, is `INPUT_A_PRESSED`).

4. **New reachable node E2 mis-classified: `ACT_SLIDE_KICK` is no-A reachable**
   (`act_crouch_slide:1467` `INPUT_B_PRESSED → ACT_SLIDE_KICK`), not A-gated.
   Apex 42 (gravity `−2`), sub-dominant, but it carries the landing bounce (see
   result 1).

5. **Ledge-climb-up is no-A reachable** (auto-fast when floor `< 100` below,
   `automatic.c:585`; slow-climb needs only analog on VERSION_US, `:570`). The
   hang family is triple-dead (needs `A`-jump to reach a hangable ceiling, needs
   `INPUT_A_DOWN` to persist, and WMotR's hangable ceilings sit at y=1536 <
   spawn 1675). `ACT_SQUISHED` confirmed dead (no other entry path).

---

## 1. NODE SET

Exhaustive over `mario_execute_airborne_action`'s switch
(`airborne.c:2074-2119`), plus the attached states (ledge/hang/pole), squished,
and the spawn/exit airborne cutscene actions. Verdict key: **R** = reachable
no-A · **A** = A/A_DOWN-gated (dead via GOAL-1 `input_grounds_noA`, the A bit is
never set) · **X** = absent (needs an object/surface WMotR lacks, cite E1) ·
**⊘** = dead by other census (squish).

### 1a. Airborne-group dispatch nodes (`ACT_GROUP_AIRBORNE`, `ACT_FLAG_AIR`)

| node | verdict | entry (no-A) or gate |
|---|---|---|
| ACT_FREEFALL | **R** | ground `GROUND_STEP_LEFT_GROUND → ACT_FREEFALL` (moving.c:818,864,948,989,1026,1054…); butt-slide-air `:1437`; slide-kick `:1587` |
| ACT_DIVE | **R** | ground speed-kick `moving.c:491` (`B`∧fVel≥29∧stickMag>48, sets vel=20); air `B` from freefall `:528` (no vel reset) |
| ACT_FORWARD_ROLLOUT | **R** | `B` from `act_dive_slide:1557` / `stomach_slide_action:1521` (sets vel=30, `:1355`) |
| ACT_BACKWARD_ROLLOUT | **R** | same, when `forwardVel < 0` (sets vel=30, `:1396`) |
| ACT_GROUND_POUND | **R** | `Z` from `act_freefall:532` (windup `+110`, `:924-932`) |
| ACT_BUTT_SLIDE_AIR | **R** | `act_butt_slide` leaves ground `moving.c:1433` (airAction) |
| ACT_SLIDE_KICK | **R** | `act_crouch_slide:1467` `B`∧fVel≥10 (sets vel=12, `mario.c:875`) — **E2 said A-gated; corrected** |
| ACT_AIR_HIT_WALL | **R** | `common_air_action_step` HIT_WALL, `airborne.c:397`, fVel>16 ∧ wall≠NULL |
| ACT_BACKWARD_AIR_KB | **R** | wall bonks: `air_hit_wall:1325`, dive `:785`, GP `:980`, slide-kick `:1620`, butt-slide-air `:1457`, `common_air_action_step:414` |
| ACT_SOFT_BONK | **R** | `air_hit_wall:1336` (fVel≤38); `common_air_action_step:419` |
| ACT_FORWARD_AIR_KB | **X** | only `determine_knockback_action` (damage source); WMotR has no enemies (E1 §6) |
| ACT_HARD_BACKWARD_AIR_KB / ACT_HARD_FORWARD_AIR_KB | **X** | big knockback (enemy/thrown); fall-damage routes to *ground* KB (`airborne.c:92`) |
| ACT_JUMP / DOUBLE_JUMP / TRIPLE_JUMP / BACKFLIP / SIDE_FLIP / WALL_KICK_AIR / LONG_JUMP / STEEP_JUMP | **A** | all set via A-gated jumps (`mario.c:786-865`; GOAL-1 one-writer `INPUT_A_PRESSED`) |
| ACT_JUMP_KICK | **A** | `check_kick_or_dive_in_air:109` (only from A-jumps) or `act_crawling:846` `INPUT_A_DOWN`; sets vel=20 `mario.c:882` |
| ACT_FLYING_TRIPLE_JUMP / SPECIAL_TRIPLE_JUMP | **A** | wing-cap A-jumps |
| ACT_TWIRLING | **A/X** | A double-jump, or twirl-object bounce (`interaction.c:1352`, absent) |
| ACT_HOLD_JUMP / HOLD_FREEFALL / HOLD_BUTT_SLIDE_AIR / AIR_THROW | **X** | need a held object (no grabbable NPC/object in WMotR) |
| ACT_WATER_JUMP / HOLD_WATER_JUMP | **X** | no water (E1) |
| ACT_RIDING_SHELL_JUMP / RIDING_SHELL_FALL | **X** | no shell |
| ACT_SHOT_FROM_CANNON / ACT_FLYING | **A+X** | cannon fire A-gated + GOAL-1 taint T (`automatic.c:729`); wing cap unobtainable (box tops unreachable, E1) |
| ACT_LAVA_BOOST | **X** | no lava |
| ACT_BURNING_JUMP / BURNING_FALL | **X** | no fire |
| ACT_GETTING_BLOWN / ACT_VERTICAL_WIND | **X** | no wind volume / `SURFACE_VERTICAL_WIND` (E1 §1,§6) |
| ACT_CRAZY_BOX_BOUNCE | **X** | `bhvJumpingBox` absent (E1); would set vel 45/60/100 (`airborne.c:1039-1049`) |
| ACT_THROWN_FORWARD / THROWN_BACKWARD | **X** | Chuckya/thrown (absent) |
| ACT_RIDING_HOOT | **X** | no hoot (E1) |
| ACT_TOP_OF_POLE_JUMP | **X** | pole absent/across void (E1 §6) |

### 1b. Attached / on-pole / hanging / squished nodes

| node | verdict | note |
|---|---|---|
| ACT_LEDGE_GRAB | **R** | `common_air_action_step` GRABBED_LEDGE `:429`; the `+238` attach (§4e) |
| ACT_LEDGE_CLIMB_SLOW_1 / _2 | **R** | `act_ledge_grab:570-578` (analog ∧ timer==10; VERSION_US has no `A_DOWN` guard) |
| ACT_LEDGE_CLIMB_FAST | **R** | auto: `act_ledge_grab:585-587` (floor <100 below), no input |
| ACT_LEDGE_CLIMB_DOWN | **R** | from standing near a down-ledge; ends on the lower floor |
| ACT_START_HANGING / HANGING / HANG_MOVING | **A+X** | entry needs `AIR_STEP_CHECK_HANG` (only A-gated `act_jump:457`) ∧ `SURFACE_HANGABLE`; nodes require `INPUT_A_DOWN` (`automatic.c:398,427,451`); WMotR ceilings at 1536 < spawn (§4f) |
| ACT_HOLDING_POLE / GRAB_POLE_* / CLIMBING_POLE / TOP_OF_POLE* | **X** | poles across the death void (E1 §6) |
| ACT_SQUISHED | **⊘** | `INPUT_SQUISHED` needs a reachable ≤150 dynamic gap — none in WMotR (prior squish census; §4d confirms no other entry) |

### 1c. Spawn / exit / death airborne (`ACT_GROUP_CUTSCENE`, intangible)

| node | verdict | note |
|---|---|---|
| **ACT_SPAWN_NO_SPIN_AIRBORNE** | **R (entry)** | **the WMotR level-entry action.** `bhvAirborneWarp` → index 7 in `sWarpBhvSpawnTable` (`area.c:62`) → `MARIO_SPAWN_AIRBORNE` (`sSpawnTypeFromWarpBhv`) → `set_mario_action(ACT_SPAWN_NO_SPIN_AIRBORNE)` (`level_update.c:324`). Handler `cutscene.c:1260` = `launch_mario_until_land(…, forwardVel 0.0f)`: a **pure fall** from y≈2669 (E1 §5b), `vel[1]=0` at init (`mario.c:1828`), no input edges, `→ACT_SPAWN_NO_SPIN_LANDING → ACT_IDLE`. No lift, no anim translation. |
| ACT_SPAWN_SPIN_AIRBORNE | **X** | different warp bhv (spin circle); not WMotR's entry |
| ACT_EXIT_AIRBORNE / DEATH_EXIT / FALLING_DEATH_EXIT / SPECIAL_* | **R (exit)** | leave the level or death-respawn; pure `launch_mario_until_land` falls, no trick edges. Death warp re-inits at spawn (Φ re-established, v2 §6.5). |
| ACT_FALL_AFTER_STAR_GRAB | **(target)** | only after grabbing a star — the event G2 proves impossible; excluded non-circularly |

**Soundness note:** the airborne switch (`:2074-2119`) has 43 cases; every one is
classified above. A node reachable no-A that we mis-marked would surface as an
unclosable branch in the per-handler engine walk (v2 §3), not a silent hole.

---

## 2. EDGE SET (mid-air transitions among reachable nodes)

Only edges that fire **without** `AIR_STEP_LANDED` (no attach) are "mid-air".
Landing edges are noted separately because a landing *is* an attach (episode
end) — but the two landing **bounces** re-open the episode and are the crux, so
they get rows. Gates quoted verbatim. Button reachability under no-A: **B yes,
Z yes, C yes** (analog/stick), **A_PRESSED / A_DOWN dead**.

| from | to | site | gate (quoted) | Pot verdict |
|---|---|---|---|---|
| FREEFALL | DIVE | `airborne.c:528` | `if (m->input & INPUT_B_PRESSED)` | preserve (DIVE case sets no vel[1], `mario.c:856`); vel carried ≤0 |
| FREEFALL | GROUND_POUND | `airborne.c:532` | `if (m->input & INPUT_Z_PRESSED)` | **credit +110** (windup), but from `vel≤0` — see §3, §4c |
| FREEFALL | LEDGE_GRAB | `airborne.c:548` (`common_air_action_step`, arg `AIR_STEP_CHECK_LEDGE_GRAB`) | attach-class `AIR_STEP_GRABBED_LEDGE`; `check_ledge_grab` gates (§4e) | **spend/attach +238** (episode end) |
| DIVE | BACKWARD_AIR_KB | `airborne.c:785` (`drop_and_set…`) | `AIR_STEP_HIT_WALL` ∧ (implicit); `if (m->vel[1] > 0) m->vel[1] = 0` first (`:780`) | preserve↓ (zeroes upward vel) |
| ROLLOUT (fwd/bwd) | — | — | no mid-air `set_mario_action`; only LANDED→`FREEFALL_LAND_STOP` (`:1375/1416`), WALL→`mario_set_forward_vel 0` | (launch only; apex 128) |
| GROUND_POUND | BACKWARD_AIR_KB | `airborne.c:980` | `AIR_STEP_HIT_WALL`; `if (m->vel[1] > 0) m->vel[1] = 0` (`:975`) | preserve↓ |
| BUTT_SLIDE_AIR | FREEFALL | `airborne.c:1437` | `if (++actionTimer > 30 && m->pos[1] - m->floorHeight > 500.0f)` | preserve (vel carried, `≤0` here) |
| BUTT_SLIDE_AIR | BUTT_SLIDE_AIR (**bounce**) | `airborne.c:1444-1446` | `AIR_STEP_LANDED` ∧ `actionState==0 && m->vel[1] < 0.0f && m->floor->normal.y >= 0.9848077f` ⇒ `m->vel[1] = -m->vel[1]/2` | **spend/re-launch** vel≤37.5 (contraction; §3, §4a-note) |
| BUTT_SLIDE_AIR | BACKWARD_AIR_KB | `airborne.c:1457` | `AIR_STEP_HIT_WALL`; `if (vel[1]>0) vel[1]=0` (`:1454`) | preserve↓ |
| SLIDE_KICK | FREEFALL | `airborne.c:1587` | `if (++actionTimer > 30 && m->pos[1] - m->floorHeight > 500.0f)` | preserve (vel ≤0) |
| SLIDE_KICK | SLIDE_KICK (**bounce**) | `airborne.c:1602-1605` | `AIR_STEP_LANDED` ∧ `actionState==0 && m->vel[1] < 0.0f` ⇒ `m->vel[1] = -m->vel[1]/2` | **spend/re-launch** vel≤37.5 (contraction) |
| SLIDE_KICK | BACKWARD_AIR_KB | `airborne.c:1620` | `AIR_STEP_HIT_WALL`; `if (vel[1]>0) vel[1]=0` | preserve↓ |
| AIR_HIT_WALL | BACKWARD_AIR_KB | `airborne.c:1325` | `else if (m->forwardVel >= 38.0f)` ∧ `if (vel[1]>0) vel[1]=0` | preserve↓ |
| AIR_HIT_WALL | SOFT_BONK | `airborne.c:1336` | `else` (fVel<38) ∧ `if (vel[1]>0) vel[1]=0` | preserve↓ |
| AIR_HIT_WALL | WALL_KICK_AIR | `airborne.c:1314-1318` | `if (m->input & INPUT_A_PRESSED) { m->vel[1] = 52.0f; … }` | **DEAD (A)** — the only mid-air positive-const vel set |
| {BACKWARD_AIR_KB, SOFT_BONK} | WALL_KICK_AIR | `check_wall_kick`, `airborne.c:1148` | `if ((m->input & INPUT_A_PRESSED) && m->wallKickTimer != 0 && m->prevAction == ACT_AIR_HIT_WALL)` | **DEAD (A)** |
| any (cancel) | SQUISHED | `airborne.c:2052` | `if (m->input & INPUT_SQUISHED)` | **DEAD (⊘)** no ≤150 spot |
| any (cancel) | VERTICAL_WIND | `airborne.c:2056` | `if (m->floor->type == SURFACE_VERTICAL_WIND && …)` | **DEAD (X)** no wind |
| any (cancel) | water plunge | `airborne.c:2047` | `if (m->pos[1] < m->waterLevel - 100)` | **DEAD (X)** no water |
| LEDGE_GRAB | LEDGE_CLIMB_FAST | `automatic.c:587` | `if (hasSpaceForMario && heightAboveFloor < 100.0f)` (no input) | attach to ledge floor (§4e) |
| LEDGE_GRAB | LEDGE_CLIMB_SLOW_1 | `automatic.c:578` | `if (m->actionTimer == 10 && (m->input & INPUT_NONZERO_ANALOG))` (VERSION_US: no A_DOWN guard) | attach to ledge floor |
| LEDGE_GRAB | FREEFALL (`let_go`) | `automatic.c:556` etc. | `if (m->input & (INPUT_Z_PRESSED | INPUT_OFF_FLOOR))` / steep floor | preserve↓ |
| LEDGE_GRAB | LEDGE_CLIMB_FAST | `automatic.c:560` | `if ((m->input & INPUT_A_PRESSED) && hasSpaceForMario)` | (A path; slow/auto cover no-A) |

**Ground↔air boundary launches (episode starts, not mid-air edges), for
completeness:** run→DIVE (`moving.c:491`, vel 20); dive-slide/stomach→ROLLOUT
(`moving.c:1557/1521`, vel 30); crouch-slide→SLIDE_KICK (`moving.c:1467`, vel
12); butt-slide→BUTT_SLIDE_AIR (`moving.c:1433`); any ground leave→FREEFALL.

---

## 3. PER-EDGE POTENTIAL DELTA

`apex(v)` (discrete, gravity `−4` unless noted):

| v | 12 (g−2) | 20 | 30 | 37.5 |
|---|---|---|---|---|
| apex | 42 | 60 | 128 | **195** |

GP windup `Σ(20−2t), t=0..9 = 110`.  Landing snap `+78` (`surface_collision.c:459`).

**(a) preserve** — pure transitions (FREEFALL→DIVE, →FREEFALL edges, all
wall→KB/SOFT_BONK which additionally *zero* any upward vel). `Δ Pot = 0` or `< 0`.

**(b) spend** — launch/re-launch that sets `vel[1] := c > 0`:
- Episode-start launches from floor `h₀ ≤ H*`: new `Pot = h₀ + apex(c)`.
  - dive `c=20`: `Pot = h₀+60`; attach ≤ `h₀+60+78 = h₀+138`.
  - rollout `c=30`: `Pot = h₀+128`; attach ≤ `h₀+128+78 = h₀+206`.
  - slide-kick `c=12` (g−2): `Pot = h₀+42`; attach ≤ `h₀+42+78 = h₀+120`.
- **Landing bounce** (BUTT_SLIDE_AIR `:1445`, SLIDE_KICK `:1604`), the E2 miss:
  bounce floor `fH ≤ H*`, re-launch `vel = |v_in|/2`, `|v_in| ≤ 75` (terminal
  clamp `mario_step.c:577`) ⇒ `vel ≤ 37.5`, `apex(37.5)=195`, attach `≤ fH +
  195 + 78 = fH + 273`.
  - **Raw bound (terminal-velocity only): `Δ_pot = +273`.**
  - **Coupled bound:** the bounce turns descending kinetic energy into height,
    recovering `(|v|/2)²/8 = ¼·(|v|²/8) = ¼` of the fall it just made. If the
    fall started within the envelope (`apex ≤ H*+Δ_pot`), then post-bounce
    height above `fH` `≤ ¼(H*+Δ_pot − fH)`; maximized at `fH=H*` and with the
    `+78` snap this is `H* + ¼Δ_pot + 78 ≈ H* + 138` (Δ_pot=238). So the bounce
    is a **contraction** and does not exceed the ballistic bounds — **but only
    if the invariant carries a descending-speed / fall-height bound.** With the
    naive `Pot = pos + ballistic(vel)` (which is `0` on descent, so does *not*
    bound `|v|`), the bounce is a **Pot-increasing edge**; closing it needs
    either the coupled invariant or the terminal-velocity `+273` allowance.

**(c) credit** — GP windup only (`+110`, `airborne.c:926-928`):
```c
if (m->actionState == 0) {
    if (m->actionTimer < 10) {
        yOffset = 20 - 2 * m->actionTimer;
        if (m->pos[1] + yOffset + 160.0f < m->ceilHeight) {   // WMotR open sky: ceilHeight≈20000, passes
            m->pos[1] += yOffset;
            m->peakHeight = m->pos[1];
```
Then `m->vel[1] = -50.0f;` (`:934`) every windup frame — GP inherits a
**downward** vel; no air step runs in `actionState==0` (`:951`). Peak = entry
pos `+110`. First `actionState==1` air step: `intendedPos[1] = pos − 12.5`, land
snap grabs floor `≤ peak − 12.5 + 78 = peak + 65.5`. So GP episode attach `≤
h_entry + 110 + 65.5 = h_entry + 175.5`. Because GP is only reached from
`vel≤0` freefall (§4c), `h_entry ≤ H*` ⇒ **GP `Δ_pot ≈ +176`** (< 238, < 273).

---

## 4. THE SIX NAMED ADJUDICATIONS

### (a) rollout → freefall mid-air?  **NO.**
`act_forward_rollout` (`airborne.c:1353-1392`) and `act_backward_rollout`
(`:1394-1432`) have exactly these `set_mario_action` sites:
```c
case AIR_STEP_LANDED:
    set_mario_action(m, ACT_FREEFALL_LAND_STOP, 0);   // :1375 / :1416  — a LANDED (attach) edge, NOT mid-air
case AIR_STEP_HIT_WALL:
    mario_set_forward_vel(m, 0.0f);                    // no action change
```
There is **no** `INPUT_Z_PRESSED`, **no** `INPUT_B_PRESSED`, and **no**
mid-air `→ACT_FREEFALL` in either body (the only `ACT_FREEFALL` reference is
`FREEFALL_LAND_STOP` on landing). So the rollout apex (`+128`) **cannot** reach
an airborne `ACT_FREEFALL` and therefore cannot expose the `Z→GP` cancel while
`vel[1] > 0`. The rollout episode is: launch `vel=30` → ballistic → attach.
Worst-case episode `Pot = h₀ + 128`, attach `≤ h₀ + 206`. **`Δ_pot(rollout) =
+206 < 238`.** The `+316` chain does **not** compose. (Confirms E2 point 2; E3
is the authority — verified against both rollout bodies in full.)

### (b) dive mid-air transitions.  Only wall→KB.
`act_dive` (`airborne.c:725-793`) mid-air (`AIR_STEP_NONE`) only adjusts
`faceAngle` (`:745-751`); on `AIR_STEP_HIT_WALL` it `drop_and_set_mario_action(
m, ACT_BACKWARD_AIR_KB, 0)` after `if (m->vel[1] > 0) m->vel[1] = 0` (`:780`).
There is **no** `B`, **no** `Z`, **no** jump-kick, **no** rollout edge inside
`act_dive`. (B→rollout lives in the *ground* `act_dive_slide`, a separate
episode after landing.) So a dive stays a dive until it lands (`→ACT_DIVE_SLIDE`)
or hits a wall. `Δ_pot(dive) = 60 + 78 = +138`.

### (c) any positive-vel re-entry / net-positive cycle?  **NO.**
Enumerate every mid-air positive `vel[1]` write reachable no-A:
- Episode-start launches (dive/rollout/slide-kick): occur once, at the ground→air
  boundary from a floor `≤ H*`. Not mid-air, not a cycle.
- Landing bounces (butt-slide-air `:1445`, slide-kick `:1604`): gated
  `actionState==0`; the bounce sets `actionState=1`, and the *next* landing in
  either body takes the `else` branch to a **ground** action (`ACT_BUTT_SLIDE`
  `:1448`, `ACT_SLIDE_KICK_SLIDE` `:1608`). ⇒ **at most one bounce per
  episode**, no amplification.
- `act_air_hit_wall:1316` `vel=52`: `INPUT_A_PRESSED`. Dead.
- `check_wall_kick` / `act_*_air_kb`→WALL_KICK_AIR: `INPUT_A_PRESSED`. Dead.
- GP windup `+110`: `actionState 0→1` monotone; GP cannot re-enter windup, and
  GP is not reachable from any positive-vel state (§4c below).
- crazy-box 45/60/100, flying, cannon, lava-boost 84, jump-kick 20 (A_DOWN),
  burning 31.5: all **A**/**X**.

**Every directed cycle** in the live graph passes through a wall-bonk (which
*zeroes* upward vel: `if (vel[1]>0) vel[1]=0` at `:401,780,975,1298,1322,1454,
1615`) or a landing (attach → episode end) or a pure `→FREEFALL`/`→DIVE`
(vel-preserving, `≤0`). The only place descending speed becomes upward height is
the single-shot bounce, a contraction. **No cycle has net-positive `Pot`.**

Why GP never inherits a positive apex: `ACT_GROUND_POUND` is reached only via
`INPUT_Z_PRESSED` from `act_freefall:532` (or hold/hang, A_DOWN/held). Every
mid-air `→ACT_FREEFALL` edge carries `vel[1] ≤ 0`:
- ground `GROUND_STEP_LEFT_GROUND → ACT_FREEFALL` (vel≈0 on the ground);
- `act_butt_slide_air:1437` and `act_slide_kick:1587` fire the `→FREEFALL` only
  after `actionTimer>30 && pos[1]−floorHeight>500` — a *descending* over-a-drop
  condition;
- hold-family drops (A/held, dead).
No `→ACT_FREEFALL` edge exists inside any positive-apex action (dive, rollout,
slide-kick-rising). So GP's `h_entry` is always a `vel≤0` height ⇒ GP credit
never stacks on a live apex. **`Δ_pot(GP) = +176`.**

### (d) squish family — any OTHER entry to `ACT_SQUISHED`?  **NO.**
`ACT_SQUISHED` is set at exactly two sites: `check_common_airborne_cancels:2052`
(`if (m->input & INPUT_SQUISHED)`) and the analogous cancels in the
moving/stationary/submerged dispatchers — **all** gated on `INPUT_SQUISHED`.
`INPUT_SQUISHED` is set only by `mario_update_hitbox_and_cap_model` when a
dynamic surface pins Mario in a `≤150`-unit vertical gap (prior squish census,
kill 1). E1 confirms WMotR has **no reachable dynamic `≤150` gap** (box
collision spans `y+[30,52]`, box#1 ~315u above spawn floor, unreachable). No
handler sets `ACT_SQUISHED` directly (grep: only the `INPUT_SQUISHED` cancels).
**`ACT_SQUISHED` is dead; the one attach mechanism it gates (steep-escape push,
`cutscene.c:1559`, horizontal, `vel[1]=0`) is vacuous.** (Confirms E2 A7.)

### (e) ledge-grab exits under no-A — Mario ends on the ledge floor (`≤ H*`).
`act_ledge_grab` (`automatic.c:543-598`). Climb-up under no-A:
```c
if ((m->input & INPUT_A_PRESSED) && hasSpaceForMario) {            // :560  A path (dead)
    return set_mario_action(m, ACT_LEDGE_CLIMB_FAST, 0);
}
...
if (m->actionTimer == 10 && (m->input & INPUT_NONZERO_ANALOG)      // :570  slow climb — VERSION_US:
    // (EU-only `&& !(m->input & INPUT_A_DOWN)` is #ifdef VERSION_EU, NOT compiled)
) { ... return set_mario_action(m, ACT_LEDGE_CLIMB_SLOW_1, 0); }   // :578  NO A needed
...
heightAboveFloor = m->pos[1] - find_floor_height_relative_polar(m, -0x8000, 30.0f);
if (hasSpaceForMario && heightAboveFloor < 100.0f) {              // :585  auto — NO input
    return set_mario_action(m, ACT_LEDGE_CLIMB_FAST, 0);
}
```
So ledge climb-up is **no-A reachable** (auto-fast when the ledge floor is
`<100` below Mario's grab height; slow-climb by pushing the analog stick toward
the ledge). `climb_up_ledge` (`:509`) writes **only horizontal** pos:
```c
m->pos[0] += 14.0f * sins(m->faceAngle[1]);
m->pos[2] += 14.0f * coss(m->faceAngle[1]);   // no pos[1] write
```
and `update_ledge_climb` → `stop_and_set_height_to_floor` sets `pos[1] =
floorHeight` — the **ledge floor found during the grab**, i.e. `ledgePos[1] ≤
nextPos[1] + 238` (E2 A2: `find_floor` at `nextPos+160`, +78 buffer). That floor
is a real surface `≤ H*` (ladder). **No height gain beyond the `+238` already
counted; Mario ends standing on a `≤ H*` floor.** Under no-A the grab itself
requires `vel[1] ≤ 0` (`mario_step.c:354`), upper-wall(`+150`)==NULL ∧
lower-wall(`+30`)!=NULL (`:471`), displacement-against-vel, ledge `∈(+100,+238]`
— an E1/geometry question (does WMotR present such a low-wall config near a
reachable floor?). **`Δ_pot(ledge) = +238`** if such geometry exists, else this
node is unreachable and the bound drops to the bounce/rollout.

### (f) hangable ceiling (WMotR ceilings at y=1536) — triple-dead, no lift.
Entry `ACT_START_HANGING` comes from `common_air_action_step`
`AIR_STEP_GRABBED_CEILING` (`airborne.c:433 → set_mario_action(m,
ACT_START_HANGING, 0)`), which requires `perform_air_quarter_step` to return
`GRABBED_CEILING`: `stepArg & AIR_STEP_CHECK_HANG` (only `act_jump` passes it,
`:457`, **A-gated**) ∧ `m->vel[1] >= 0` ∧ `nextPos[1]+160 > ceilHeight` ∧
`m->ceil->type == SURFACE_HANGABLE` (`mario_step.c:446-454`). Then every hang
node self-terminates without A:
```c
if (!(m->input & INPUT_A_DOWN)) {                    // start_hanging :398, hanging :427, hang_moving :451
    return set_mario_action(m, ACT_FREEFALL, 0);
}
```
So hanging is dead **three ways**: (1) reaching a hangable ceiling needs an
A-gated jump; (2) the nodes require `INPUT_A_DOWN` to persist (flagged §5 as an
`A_DOWN` edge the no-A model must cover); (3) WMotR's 38 `SURFACE_HANGABLE`
triangles are ceilings at **y=1536**, *below* the spawn floor 1675 (E1 §1). Even
if reached, hang pos is `m->pos[1] = m->ceilHeight - 160` (`automatic.c:380`) =
`1536 − 160 = 1376`, and traversal (`perform_hanging_step`) moves along the
**flat** 1536 ceiling — `nextPos[1] = m->pos[1]` (`:366`), no rise. **Hanging
cannot end above its start and is unreachable no-A.** The `Z→GP` cancel inside
the hang nodes (`:402,432,456`) is dead with them.

---

## 5. CYCLE ANALYSIS (the combinatorial core)

Live no-A graph (episode-internal, mid-air edges only), positive-vel launches as
roots:

```
        [ground] --B--> DIVE(20) --wall--> BACKWARD_AIR_KB --A--> (WALL_KICK_AIR) [DEAD]
        [ground] --B--> {F,B}_ROLLOUT(30) --land--> [ground]           (no mid-air out)
        [ground] --B--> SLIDE_KICK(12) --bounce(≤37.5, once)--> SLIDE_KICK --land--> [ground]
                                        \--(>500 & desc)--> FREEFALL
        [ground] --slide--> BUTT_SLIDE_AIR --bounce(≤37.5, once)--> BUTT_SLIDE_AIR --land--> [ground]
                                        \--(>500 & desc)--> FREEFALL
        [ground] --leave--> FREEFALL --B--> DIVE
                                     --Z--> GROUND_POUND(+110, vel:=-50) --wall--> BACKWARD_AIR_KB
                                     --grab--> LEDGE_GRAB --climb--> [ground floor ≤H*]
        AIR_HIT_WALL --{fVel}--> {BACKWARD_AIR_KB, SOFT_BONK}   (upward vel zeroed)
```

**Every cycle is broken:**
- back into `[ground]` = episode end (attach). New launch re-seeds `Pot ≤ H* +
  apex(c)`, not increasing across episodes (each launch floor `≤ H*`).
- through a wall bonk: `if (m->vel[1] > 0) m->vel[1] = 0` on every HIT_WALL
  path ⇒ any airborne cycle that revisits a node has strictly non-increasing
  upward vel.
- the two `bounce` self-loops are **single-shot** (`actionState 0→1`) and
  **contracting** (recover ¼ of the fall).
- `FREEFALL→DIVE→(wall)→KB→…` carries only `vel≤0`.

There is **no edge that sets `vel[1]` to a positive constant mid-air** (the sole
candidate, `air_hit_wall:1316`, is A-gated), and **no credit edge reachable
twice** (GP windup is monotone `actionState`). **⇒ the episode graph has no
potential-increasing cycle.** (This is v2 §4's "once-and-for-all" obligation,
discharged over the finite live graph.)

---

## 6. Δ_pot VERDICT

```
┌─────────────────────────────────────────────────────────────────────────┐
│  PER-MECHANISM Δ_pot (max attach height above a launch floor h₀ ≤ H*)     │
│                                                                           │
│    dive apex + land snap ............... 60 + 78  = +138                   │
│    slide-kick apex + land snap ......... 42 + 78  = +120                   │
│    rollout apex + land snap ............ 128 + 78 = +206                   │
│    GP windup + first-descent snap ...... 110 + 66 = +176                   │
│    ledge grab (if geometry present) .............. +238                    │
│    butt-slide/slide-kick BOUNCE (raw, terminal-v) . +273   ◄── DOMINANT    │
│    butt-slide/slide-kick BOUNCE (coupled invariant) ≤ +138                 │
│                                                                           │
│  EPISODE-COMPOSITION MAX (no cross-episode chaining; §4a,§4c,§5):          │
│                                                                           │
│    Δ_pot  =  +273   (raw, terminal-velocity bound — simplest to prove)     │
│    Δ_pot  =  +238   (if the bounce is closed via the coupled invariant     │
│                      AND WMotR presents grab-able ledge geometry)          │
│                                                                           │
│  IS Δ_pot ≤ 238 ?  →  NOT under the raw bound: the bounce gives +273.      │
│                       ≤ 238 requires the coupled fall-height invariant.    │
│                       BUT the theorem does not need 238:                   │
└─────────────────────────────────────────────────────────────────────────┘
```

**Cross-check vs E1 robustness (both bounds pass):**

| Δ_pot | E1 floor gap (337, need `<`) | E1 coin-safe (668, need `<`) | H\* rung | coin#2 margin |
|---|---|---|---|---|
| **+273** (raw) | **337 − 273 = +64 margin** ✅ | **668 − 273 = +395 margin** ✅ | H\*=1675 (spawn island) | ≈ +1092 |
| **+238** (coupled) | 337 − 238 = +99 ✅ | 668 − 238 = +430 ✅ | H\*=1675 | ≈ +1127 |

Both keep H\* pinned to the spawn island (1675; the raw +273 < 337 gap does not
climb to box#1 at 2012), and both leave coin#2 (y=3140) hundreds of units above
the airborne envelope. **The red-coin star never spawns; the WMotR ABC
impossibility height core holds.** The E1 verdict is unchanged; only the driving
constant moves from E2's `238` to **`273` (raw)**, still comfortably inside E1's
`<337` / `<668` moats.

---

## 7. DISCREPANCIES vs E2 / v2

1. **NEW DOMINANT MECHANISM — butt-slide-air / slide-kick landing bounce
   (`Δ=+273` raw).** E2's launch census (CENSUS B) enumerated *constant*
   `vel[1] :=` writes and so **missed** the data-dependent bounces `vel[1] =
   -vel[1]/2` (`airborne.c:1445`, `:1604`). With the terminal-velocity clamp
   (`−75`) this re-launches at `37.5` (apex 195), attach `+273` — **above E2's
   headline `Δ_pot ≈ +238`**. It is a *contraction* (recovers ¼ of the fall), so
   the coupled invariant keeps it ≤ 138, but the *naive* `Pot = pos +
   ballistic(vel)` does not bound descending `|v|`, so this is a real new
   obligation for the invariant/float layer. Net: E2's `238` should read
   **`273` (raw)** or be defended by the coupled argument.

2. **`ACT_SLIDE_KICK` is no-A reachable (E2 mis-classified as A-gated).**
   `act_crouch_slide:1467` `INPUT_B_PRESSED ∧ forwardVel≥10 → ACT_SLIDE_KICK`.
   E2's B.2 table lists `mario.c:876 vel=12 ACT_SLIDE_KICK` under "A-gated". The
   *constant* is set in `set_mario_action_airborne`, but the *caller* is
   B-gated. Apex 42 (sub-dominant), but it carries the bounce (item 1).

3. **`Δ_pot ≈ 238` vs the composition max — resolved.** E2 deferred episode
   composition to E3. Confirmed: the `+316` GP chain is dead (§4a,§4c — no
   ballistic action reaches airborne freefall / `Z→GP`), so mechanisms do **not**
   chain; the single-episode max is the bounce (`273`) or ledge (`238`), not
   `316`. E2 point 2 stands, refined.

4. **GP episode is `+176`, not the loose `≲175`** (E2 CONSTANTS roll-up). Exact:
   windup `110` + first-descent snap `65.5` = `175.5` from a `vel≤0` entry.

5. **v2 §3 census row "ledge grab window +238" is conditional.** Under no-A the
   grab needs a *low-wall* geometry (upper-`+150`==NULL, lower-`+30`!=NULL, E2's
   corrected gate) near a reachable floor with a `(+100,+238]` ledge — an
   E1/geometry existence question. If WMotR has none, the ledge node is
   unreachable and `Δ_pot` is set by the bounce (`273`) / rollout (`206`).

6. **v2 §4 "squish-cancel was one (dead)" — confirmed, and no other entry**
   (§4d). v2 §6.2 anim-ε = 0 in the airborne episode — confirmed (the entry
   action `ACT_SPAWN_NO_SPIN_AIRBORNE` uses `MARIO_ANIM_GENERAL_FALL` via
   `launch_mario_until_land`, no `update_mario_pos_for_anim` call).

---

## 8. OPEN ITEMS

1. **The bounce and the invariant (the one real new design task).** Decide
   between: (i) carry `Δ_pot = 273` (raw, terminal-velocity — simplest, still
   inside all E1 moats), or (ii) strengthen the airborne invariant with a
   descending-kinetic bound so the bounce provably contracts (`Δ_pot=238`). The
   float layer (v2 §5) must handle `vel[1] = -vel[1]/2` (exact: `/2` is exact in
   binary32) and the `≥ 0.9848077f` flat-floor gate either way. **Recommend (i)**
   — `273 < 337` needs no coupling and no horizontal reasoning.

2. **Grab-able ledge geometry in WMotR (A2, §4e).** Whether the `+238` ledge
   window is *live* depends on a reachable low-wall+ledge config — E1/leveldata.
   Not needed for the verdict (bounce `273` already dominates ledge `238`), but
   pin it if the invariant uses `238`.

3. **`INPUT_A_DOWN` edges flagged for the no-A input model** (task §2): the hang
   family (`automatic.c:398,427,451`), `act_twirling` yaw target (`airborne.c:
   681`, cosmetic), `act_crawling:846` `→JUMP_KICK`, and the wing-cap apply-A
   gravity (`mario_step.c:569`). GOAL-1's `input_grounds_noA` asserts the A bit
   is never set under no-A input, which covers `A_DOWN` as well as `A_PRESSED`;
   each of these edges is then a dead branch, but the model must *cover* them
   (they read `A_DOWN`, not `A_PRESSED`).

4. **Object-gated edges (separate per task §2), all vacuous or absent under Φ:**
   `bounce_off_object` (`interaction.c:515`, pins `pos[1]=oPosY+hitboxHeight`,
   vel 30/80) fires only when Mario is *above* the object — the ladder excludes
   reaching the 6 box tops (`≥ +337`, E1), so these edges are vacuous under Φ
   (v2 §4, non-circular). `interact_bounce_top` (enemy stomp) and
   `interact_hit_from_below` / `interact_breakable` need enemies/blocks WMotR
   lacks (E1 §6). `interact_cap` (wing-cap box) sets no airborne action and no
   lift, and the boxes are untouchable no-A anyway. Twirl/tornado/whirlpool/
   getting-blown/bully/Bubba interactions (`interaction.c:1107,1130,1152,1217,
   1266`) all need absent objects.

5. **Death/exit airborne threading.** `ACT_DEATH_EXIT` / `FALLING_DEATH_EXIT`
   (fall into the void) are pure `launch_mario_until_land` falls that leave the
   level or re-init at spawn (`init_mario`, `vel=0`, `mario.c:1828`); Φ is
   re-established at the spawn island. No trick edges. (v2 §6.5.)
