# GOAL 2 — concrete per-site census of Mario y-changers, with WMotR-no-A verdicts

**Status:** exploration, 2026-06-24. Exhaustive grep of every `m->pos[1]` (gameplay
y) and `m->vel[1]` (the climb fuel that integrates into y) write in
`vendor/sm64/src/`, each adjudicated: **reachable in WMotR under no-A?** and if not,
**why not.** Companion to [goal2-wmotr-leveldata.md](goal2-wmotr-leveldata.md). **No
Coq.** Verdict tags: **A** = A-gated (dead under no-A, via the one-writer
`INPUT_A_PRESSED` fact); **ABSENT** = needs an object/surface WMotR doesn't have;
**DEAD** = uncalled code; **PIN** = sets y to an existing floor/ceiling (no climb);
**REACH** = reachable non-A and *does* move y up (then bounded — see §3); **N/A** =
not Mario's gameplay y (camera/object/gfx).

## 0. Headline

Contrary to the first-pass "no lift at all," WMotR-no-A *does* admit a small
**bounded** airborne kit — the **B-button ground dive** and what follows it (forward
rollout, ground pound). Every *other* y-raiser is A-gated or needs an absent
object/surface. The dive kit lifts Mario at most ~**112 units** above his floor, so
the height ceiling is `~1675 + 112 + ε ≈ 1790` — still ~1350 units below the lowest
"high" red coin (`y = 3140`). The conclusion (4 red coins unreachable ⇒ star never
spawns) stands; it just rests on a *bounded-impulse* bound, not a zero-lift one.

The one way that bound could fail — **squish cancel**, which drops Mario to idle
mid-air and lets him re-launch (dive/jump/ledge-grab) without landing, chaining
the raisers — is disproved in §5. The cancel requires entering `ACT_SQUISHED`,
which requires `INPUT_SQUISHED`, which requires a `SURFACE_FLAG_DYNAMIC` surface
within a `≤150` ceil-floor gap. WMotR's *only* dynamic surfaces are the 6 static
wing-cap `!` boxes; the one island-reachable box floats ~315 u above the spawn
floor (collision `y ≈ 1990–2012` vs floor `1675`), so **no reachable `≤150` squish
spot exists** — the cancel can never trigger. The separate fall-damage `squishTimer`
path needs a `>1150` fall the height bound precludes. No squish ⇒ no ratchet.

## 1. The climb fuel — every `m->vel[1]` write (positive/relevant)

`pos[1] += vel[1]/4` per quarter-step (`mario_step.c`), so positive `vel[1]` is the
only thing that lifts Mario. Gravity-only writes (`mario_step.c:513-578`: `-=4`, caps
at `-65/-75`) only ever *decrease* vel and are omitted. Zeroing writes (`= 0.0f`) are
omitted — they can't climb.

| site | value | what / guard | WMotR-no-A verdict |
|---|---|---|---|
| `mario.c:766` | 30–82 + fwd·m | jump table (`set_mario_y_vel_based_on_fspeed`) | **A** — every jump entry A-gated (census-doc §3b) |
| `mario.c:769` | ×0.5 | squish-halves an existing jump vel | **A** — only on the jump path |
| `mario.c:813` | 31.5 | `ACT_BURNING_JUMP` | **ABSENT** — needs fire/flame contact; none |
| `mario.c:850` | 84 | `ACT_LAVA_BOOST` | **ABSENT** — needs lava; none (snow level) |
| `mario.c:876` | 12 | `ACT_SLIDE_KICK` (B in air) | **A** — needs prior A-airborne |
| `mario.c:883` | 20 | `ACT_JUMP_KICK` (air B) | **A** — needs prior A-airborne |
| `mario.c:943` | 32 | metal-water-jump (`set_mario_action_submerged`) | **ABSENT** — needs water + metal cap |
| `mario.c:955` | 52 | `ACT_EMERGE_FROM_PIPE` (cutscene) | **ABSENT** — no pipe; spawn isn't this (§4) |
| `mario.c:968` | 64 | special exit / death-exit airborne | **ABSENT** — exit-triggered, leaves level |
| `automatic.c:732` | 100·sin | tweester/tornado lift | **ABSENT** — no tweester |
| `automatic.c:778/786` | +1 / 20 | tornado | **ABSENT** — no tweester |
| `airborne.c:364` | fwd·sin | **`ACT_FLYING`** (the unbounded climb) | **A** + taint-T (GOAL 1) |
| `airborne.c:1039/44/49` | 45/60/**100** | `act_crazy_box_bounce` | **ABSENT** — needs `heldObj == bhvJumpingBox`; none (§2) |
| `airborne.c:1316` | 52 | `act_air_hit_wall`, inside `if (INPUT_A_PRESSED)` | **A** (verbatim A-branch) |
| `airborne.c:1355` | 30 | `act_forward_rollout` | **REACH** — via the dive chain (§3) |
| `airborne.c:1396` | 30 | `act_backward_rollout` | **REACH** — via dive chain, ≤30 (§3) |
| `airborne.c:1534` | 84 | `ACT_LAVA_BOOST` body | **ABSENT** — no lava |
| `airborne.c:2022` | 42 | `act_special_triple_jump` (on land) | **A** — triple-jump variant |
| `mario_step.c:598` | +maxVelY/8 | `apply_vertical_wind`, gated `floor->type == SURFACE_VERTICAL_WIND` | **ABSENT** — no such surface in WMotR |
| `mario_step.c:661` | fwd·sin | `set_vel_from_pitch_and_yaw` | **DEAD** — zero callers (decomp confirms) |
| `interaction.c:517` | velY | `bounce_off_object` | **ABSENT** — no enemy/bounce object |
| `interaction.c:592` | 20 | hoot-related bounce | **ABSENT** — no hoot |
| `interaction.c:1148` | 12 | twirl-bounce velY | **ABSENT** — no twirl object |
| `moving.c:491` | **20** | `check_ground_dive_or_punch`, inside `if (INPUT_B_PRESSED)` | **REACH** — non-A ground dive (§3) |
| `cutscene.c:1303/1377/1701` | sqrt/60/60 | star-grab / scripted launches | **ABSENT** — star never spawns (no 8 coins) |
| `submerged.c:221/251/499/1071` | buoyancy/62/… | swimming/metal water | **ABSENT** — no water |
| `behaviors/heave_ho.inc.c:24` | 95 | Heave-Ho throws Mario | **ABSENT** — no Heave-Ho |
| `behaviors/chuckya.inc.c:29/36` | var/10 | Chuckya throws Mario | **ABSENT** — no Chuckya |

## 2. `act_crazy_box_bounce` — the vel-100 scare, killed

Both roots require Mario to be *holding the jumping box*:
`act_hold_idle` (`stationary.c:441`) and `act_hold_walking` (`moving.c:877`) each do
`if (m->heldObj->behavior == bhvJumpingBox) → ACT_CRAZY_BOX_BOUNCE`. The third site
(`airborne.c:1072`) is the self-rebounce (`actionArg+1`). No object *behavior* sets it.
**WMotR spawns no `bhvJumpingBox`** (its holdables/boxes are 1-up and wing-cap boxes,
`macro_box_1up` / `macro_box_wing_cap`, plus poles/coins/cannons/star). So
`ACT_CRAZY_BOX_BOUNCE` is unreachable — the largest non-A impulse (100) never fires.
(Even if it did: apex `≈100²/8 = 1250`, peak `1675+1250 = 2925 < 3140`, still short.)

## 3. The reachable non-A kit (the honest exceptions) and its bound

These three *are* reachable without A in WMotR and *do* raise y. All are
one-shot-from-the-floor and bounded; none ratchet:

1. **Ground dive** — `check_ground_dive_or_punch` (`moving.c:491`): `if (INPUT_B_PRESSED)
   && forwardVel ≥ 29 && stickMag > 48` → `vel[1] = 20`, `ACT_DIVE`. Mario can reach
   `forwardVel ≥ 29` running on the flat start island, so this **is** reachable.
   Apex `≈ 20²/8 = 50` units. Lands back on the island. The other ~13 `ACT_DIVE`
   setters are all *inside airborne actions* (need a prior jump/dive), so this B-dive
   is the only **root** under no-A.
2. **Forward / backward rollout** — `act_forward_rollout` (`airborne.c:1355`,
   `vel[1]=30`) / `act_backward_rollout` (`:1396`, ≤30), reached from the dive-slide
   landing (`moving.c:1562`). Apex `≈ 30²/8 = 112` units — the **kit maximum**.
3. **Ground pound rise** — `act_ground_pound` (`airborne.c:928`): for the first ≤10
   frames `pos[1] += (20 − 2·timer)`, i.e. ~110 units total, **but** guarded by
   `pos[1] + yOffset + 160 < ceilHeight` and immediately followed by a slam back down.
   Reached by pressing Z while airborne (i.e. after the B-dive or a fall). Net peak
   ~110, no ratchet.

**No chaining ratchet.** Each launch sets `vel[1]` to a constant *once*, from whatever
floor Mario is on; he then lands back on that floor. Dive→land→rollout→land→… never
accumulates — every apex is measured from the (bounded) island floor.

**No horizontal escape.** A dive keeps `forwardVel ≤ 48`; airtime at `vel=20` is short,
giving a horizontal reach of **~1400 units** before Mario falls to the death plane. The
nearest other island is **~2400 units** away (central island corner to island B/C/D/E),
so a dive cannot bridge any gap — Mario falls into the void and dies. Containment holds.

## 4. Gameplay `pos[1]` writes — every site, adjudicated

| site | what | verdict |
|---|---|---|
| `mario_step.c:230/249/416/442/461` | `= floorHeight` (step snap) | **PIN** — to the floor below; ≤ reachable-island max |
| `mario_step.c:420/465` | `= nextPos[1]` (the integration result) | the §1/§3 channel — bounded by `vel[1]` (≤ dive kit) |
| `mario.c:1835`, `moving.c:89`, `automatic.c:88/503/819`, `cutscene.c:569`, `stationary.c:819/821` | `= floorHeight` (± small idle bob) | **PIN** — floor-bounded |
| `cutscene.c:2162` | `= find_floor(...)` | **PIN** — floor value |
| `mario.c:219` | `+= anim translation[1]` | **REACH (tiny)** — bounded anim offset, the `ε` (§7 of leveldata doc) |
| `airborne.c:928` | `+= yOffset` (ground pound) | **REACH** — §3, ≤110, ceiling-gated |
| `mario.c:1178`, `submerged.c:1503` | `= waterLevel − 100/80` | **ABSENT** — no water |
| `submerged.c:1086` | `= whirlpool->oPosY + …` | **ABSENT** — no whirlpool/water |
| `airborne.c:1863` | `= usedObj->oPosY − 92.5` (riding hoot) | **ABSENT** — no hoot |
| `automatic.c:75/82/92/380/817/819` | pole / ceiling-grab pin | **ABSENT** — poles unreachable across the void (leveldata §4) |
| `automatic.c:501` | `−= 100` (ledge pull-down) | **PIN/down** — decreases y |
| `automatic.c:690` | `= usedObj->oPosY + 350` | **ABSENT** — needs a grabbed object (none reachable) |
| `automatic.c:735` | `+= 120·sin` (tornado) | **ABSENT** — no tweester |
| `interaction.c:516` | `= o->oPosY + hitboxHeight` (land on object) | **ABSENT** — needs to be airborne above an object; the only over-spawn box is *above* Mario, others off-island |
| `platform_displacement.c:83` | `= y` (moving platform carries Mario) | **ABSENT** — no moving platforms |
| `level_update.c:547` | `+= warp->displacement[1]` | **ABSENT** — airborne warp at `y=2669` unreachable; death/success warps leave the level |
| `cutscene.c:553/556` | `± 16·speed` (scripted) | **ABSENT** — cutscene needs star/exit trigger |
| `mario.c:536` | `pos[1] = collisionData.y` | **N/A** — writes a *local* collision out-param, not `m->pos` |
| `automatic.c:526` | `statusForCamera->pos[1]` | **N/A** — camera mirror |
| all `camera.c`, `coin.inc.c`, `graph_node.c`, `paintings.c`, `tilting_inverted_pyramid` | camera / object / gfx pos | **N/A** — not Mario gameplay y |

## 5. The ratchet question — squish cancel (disproved)

The bounds in §3 are *per action*. They only bound the *reachable set* if no
mechanism **chains** the raisers so the rises accumulate without a return to the
floor between them — per-action bounds do **not** by themselves imply a chain
bound. The known chaining mechanism is the **squish cancel** (mechanism as
described by the ABC community, reconciled here against the source):

> If Mario gets squished and **un-squished in the same frame**, he drops into the
> **idle** action state mid-air, from which he can immediately dive, ledge-grab,
> or jump — *even if* he was diving, dive-rollout-ing, ground-pounding, or in
> knockback. The un-squish happens when a **steep surface (≥60°, `normal.y <
> 0.5`)** pushes Mario by the surface-normal's horizontal component (≤10 u, or
> ≤2.5 with quarter-frames) far enough to **escape** the squish spot. A *squish
> spot* is a unit square where floor and ceiling are close together vertically;
> the squish must appear **where Mario already is** (a ceiling descending onto
> him, or a spontaneously-exposed dynamic ceiling) — he cannot enter a ceiling
> hitbox from the side without bonking.

This is exactly `act_squished`'s steep-surface branch
(`cutscene.c:1547-1569`): `m->floor->normal.y < 0.5` / `-0.5 < m->ceil->normal.y`
→ `vel = sins/coss(surfAngle)*10` → if `perform_ground_step ==
GROUND_STEP_LEFT_GROUND` then `squishTimer = 0; set_mario_action(ACT_IDLE, 0)`.
So the cancel **requires Mario to be in `ACT_SQUISHED`**. That is the bottleneck,
and it is closed.

**Kill 1 (primary) — no squish spot is reachable, so `ACT_SQUISHED` is never entered.**
Mario enters `ACT_SQUISHED` only via the four `check_common_*_cancels`
(stationary `:1094`, airborne `:2052`, object `:448`, moving `:1963`), **each
guarded by `if (m->input & INPUT_SQUISHED)`**. `INPUT_SQUISHED` is set at exactly
one site, `mario.c:1344-1350`:
```c
if ((m->floor->flags & SURFACE_FLAG_DYNAMIC) || (m->ceil && m->ceil->flags & SURFACE_FLAG_DYNAMIC)) {
    ceilToFloorDist = m->ceilHeight - m->floorHeight;
    if ((0.0f <= ceilToFloorDist) && (ceilToFloorDist <= 150.0f))
        m->input |= INPUT_SQUISHED;
}
```
It needs a **`SURFACE_FLAG_DYNAMIC`** floor/ceil *and* a `≤150` ceil-floor gap. (A
purely *static* "exposed ceiling / invisible wall" never qualifies — the dynamic
flag is mandatory.) In WMotR:
- `SURFACE_FLAG_DYNAMIC` is set at one site (`surface_load.c:715`, in
  `load_object_surfaces ← load_object_collision_model`), and **of every WMotR
  object only `bhvExclamationBox` (the 6 wing-cap `!` boxes) ever calls
  `load_object_collision_model`** (`exclamation_box.inc.c:101`, only in solid
  `oAction == 2`). Poles, cannons, coins, 1-ups, the red-coin star, the warp —
  none load collision. So the *only* dynamic surfaces are these 6 boxes, and they
  are **static** (`oPosY = oHomeY`, no motion) — never a *descending* or
  *spontaneous* ceiling, exactly the geometry the trick needs.
- **The boxes never form a `≤150` gap.** The `!`-box collision model spans only
  `y ∈ [oPosY+30, oPosY+52]` (`exclamation_box_outline/collision.inc.c`) — a
  ~22 u cube floating *above* its origin. Five boxes sit over far islands across
  the death void (unreachable without a jump = A). The one island-reachable box,
  #1 at `oHomeY = 1960`, has its collision at `y ≈ 1990–2012` — **≈ 315 u above**
  the spawn-island floor (`y ≈ 1675`). Standing on the island, `ceilToFloorDist ≈
  315 ≫ 150`; standing on the box, there is no ceiling at all. No unit square in
  WMotR has a dynamic surface within 150 u of a reachable floor.

⇒ `INPUT_SQUISHED` is never set under no-A in WMotR ⇒ `ACT_SQUISHED` is never
entered ⇒ **the squish cancel can never trigger.**

**Kill 2 — the fall-damage `squishTimer` path (separate) — coupled induction.**
The *other* way `squishTimer` goes non-zero is `check_fall_damage`
(`airborne.c:95`, `= 30`), needing `fallHeight = peakHeight − pos[1] > 1150` (the
`damageHeight = 600` branch is dead, `//! Never true`). This sets the timer but
**does not enter `ACT_SQUISHED`** (it falls through to `GROUND_POUND_LAND`), so it
doesn't even grant the cancel — but it is killed anyway: a *survivable* fall must
land on a solid floor, the only reachable solid floor is the spawn island (`y ≈
1536–1675`), and the §3/§4 peak is `≤ ~1790`, so `fallHeight ≤ ~254 < 1150`. The
only `>1150` drop is off the island into the death plane (`y = -8191`) = death,
not squish. *Bounded height ⇒ bounded survivable fall ⇒ no fall-squish ⇒ height
stays bounded.* (The remaining `squishTimer` writer, `cutscene.c:1346` `=0xFF`, is
`act_bbh_enter_spin` — BBH cage cutscene, absent object.)

**Backstop — even if a squish cancel *did* fire, no unbounded ratchet under no-A.**
The idle-mid-air menu the trick unlocks is, with A held off: **jump → A-gated,
dead**; **dive → `vel[1] = 20`, bounded (apex +50)**; **ledge-grab → no height
gain beyond the ledge**. The Squish Push itself is **horizontal** (≤10 u). The
Bully-speed-transfer variant needs a Bully — absent. So the worst case is a chain
of bounded dives, each launching from near a *fixed* box height (~1990), giving
`≤ ~2040` — still ~1100 u below the lowest high coin (`y = 3140`). There is no
higher squish spot to escalate to, because the boxes are at fixed positions and
do not move.

*(Secondary remark, a different chaining model: were the chain instead trying to
pump the ground-pound rise* while *squished, that too is gated off — the rise
needs `pos[1] + yOffset + 160 < ceilHeight` i.e. `>160` headroom, but a squish
spot is a `≤150` gap, so in the gap the rise is skipped. True, but not the
mechanism above; the real cancel escapes to idle rather than rising in place.)*

*Still owed (honesty):* the no-squish **grounding invariant** — that *every*
no-A-reachable airborne action self-terminates to a landed state or is itself
height-bounded — is checked for the ground pound and the dive kit, not yet
enumerated over the full air-transition graph. And the exact frame-timing of the
trick is not pinned — only its precondition (`ACT_SQUISHED`, i.e. a reachable
`≤150` dynamic squish spot), which Kill 1 removes outright. Both flagged for the
eventual Coq formalization.

## 6. Conclusion

In WMotR under no-A, every `m->vel[1]`/`m->pos[1]` raiser is one of:
- **A-gated** (all jumps, wall-kick, air-hit-wall, special triple, slide/jump-kick) —
  dead via the one-writer `INPUT_A_PRESSED` fact;
- **ABSENT-gated** (lava, fire, water, vertical wind, tweester, bounce/twirl objects,
  crazy box, heave-ho, chuckya, hoot, whirlpool, moving platforms, poles-across-void,
  star cutscenes) — the trigger object/surface does not exist in this level;
- **DEAD** (`set_vel_from_pitch_and_yaw`);
- **PIN** to an existing floor/ceiling (no climb, floor ≤ reachable-island max); or
- the **bounded non-A dive kit** (dive 20 / rollout 30 / ground-pound ~110), apex
  **≤ ~112** above the floor, no ratchet, no horizontal escape.

⇒ **Height ceiling under no-A ≈ floor (≤1675) + 112 + anim-ε ≈ 1790.** The four "high"
red coins sit at `y = 3140 / 3990 / 4600 / 4600` — **≥ 1350 units above the ceiling.**
None can be collected, so the 8-red-coin star never spawns, so WMotR cannot be
completed without A. The margin is large and robust.

## 7. Residual checks (honesty)

- **Spawn/entry velocity** — confirm the WMotR entry action imparts no upward `vel[1]`
  (it should be an idle/spawn, not `ACT_EMERGE_FROM_PIPE`); §4 of leveldata doc.
- **forwardVel cap for the dive apex** — the rollout apex uses `vel=30` (constant), so
  the ≤112 bound is exact and independent of forwardVel; only the *horizontal* reach
  uses `forwardVel ≤ 48` (capped in `set_mario_action_airborne`).
- **anim-translation ε** — `return_mario_anim_y_translation` adds a small per-frame,
  non-accumulating offset; quantify from WMotR-reachable animations to make `ε` concrete.

See [[goal2-y-census]], [[goal2-wmotr-leveldata]] is the level-data writeup.
