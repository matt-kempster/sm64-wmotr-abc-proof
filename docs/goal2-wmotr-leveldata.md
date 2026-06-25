# GOAL 2 — WMotR level data and the "no-lift / inescapable island" argument

**Status:** exploration, 2026-06-24. Reads the actual WMotR level data
(`vendor/sm64/levels/wmotr/`). Companion to
[goal2-y-value-census.md](goal2-y-value-census.md) and
[goal2-act-jump-reachability.md](goal2-act-jump-reachability.md). **No Coq written.**
All coordinates are `(x, y, z)` in level units; `y` is up.

## TL;DR

WMotR is tiny and made entirely of plain floating floors over a kill plane. Two
results fall straight out of the data:

1. **No-lift.** Under no-A, **WMotR contains no usable positive-yVel source.** Every
   yVel-raiser in the census is either A-gated (all jumps, cannon, flight) or needs an
   object/surface WMotR doesn't have (no lava, no fire, no enemies/bounces, no
   tweester, no quicksand, no vertical wind, no moving platforms, no water). The one
   non-A height mechanism physically present — the 6 climbable **poles** — sits across
   the void, unreachable (see §4). So under no-A Mario's `vel[1]` is never positive,
   and his height is pinned to the start island, `pos[1] ≤ ~1675 + ε`.
2. **The star never spawns.** The 8 red coins gate a `bhvHiddenRedCoinStar`. **4 of the
   8 sit at `y ≥ 3140`** (up to 4600) — thousands of units above the no-lift ceiling.
   Under no-A those 4 can never be touched, so the 8/8 count is never met, so the star
   never appears. **WMotR is uncompletable without A.**

This is the *right shape* of argument, and it dodges the trap you flagged:

- Not "Mario stays below the coins" — false, some red coins are *below* spawn (`y` down
  to −2680).
- Not "the highest surface is below the coins" — false, the top platform (`y ≈ 4537`)
  sits right among the coins.
- **It is: "the highest *reachable* surface (the start island, `y ≈ 1675`) is below the
  high coins," and reachability is capped by no-lift.** The surface above the coins is a
  *disconnected higher island* Mario can't lift up to, so its height is irrelevant.

**Bonus (per-level twirl disproof).** "Never ACT_JUMP" is *false in general* (the squish
remap of object-driven `ACT_TWIRLING`, see the act-jump doc) but **true in WMotR**: there
is no twirl-bounce object, no quicksand, and no crushing hazard, so the squish/quicksand
remap that is `ACT_JUMP`'s only non-A producer can never fire (§5).

## 1. The level (`levels/wmotr/`)

**Spawn:** `MARIO_POS(area 1, yaw 270, pos -67, 1669, -16)` (`script.c:65`), confirmed by
`COL_SPECIAL_INIT` `special_null_start` at the same point (`collision.inc.c:2058`). Mario
starts on the **central island**.

**Floors (collision clusters, by y).** WMotR is a handful of disjoint floating islands:

| island | y range | x range | z range | role |
|---|---|---|---|---|
| **A — central (start)** | **1536 – 1675** | −1150 … 1090 | −1130 … 1000 | spawn; the rainbow |
| B | 2017 (top) | −2300 … −3550 | −3500 … −4800 | NW spire base |
| C | 0 – 174 | 3500 … 4783 | −500 … 750 | E island |
| D | −1415 … −1535 | −1200 … 200 | 3900 … 5400 | S island |
| E | 312 – 824 | −3941 … −4965 | −321 … 702 | W cannon island |
| F — **top** | **4403 – 4537** | −2000 … −4220 | −3100 … −5200 | NW summit (above coins) |
| (low) | −2738 … −3557 | 2787 … 4631 | 4278 … 6121 | SE island + pole |
| death | −8191 | ±8192 | ±8192 | `SURFACE_DEATH_PLANE` kill floor |

**Surfaces (whole level):** only `SURFACE_DEFAULT` (68), `SURFACE_HANGABLE` (38),
`SURFACE_DEATH_PLANE` (2), `SURFACE_NOT_SLIPPERY` (1220), `SURFACE_HARD_NOT_SLIPPERY`
(24). **No** vertical-wind, water box, lava/burning, slippery, or moving-surface types.

**Objects (every one):** 6 `bhvPoleGrabbing` poles (`script.c:19-24`); 1
`bhvHiddenRedCoinStar` at `(-160, 1950, -470)`; 1 `bhvAirborneWarp` at `(-67, 2669, -16)`;
and the macro objects (`macro.inc.c`): 2 closed cannons + 1 bob-omb buddy (E and SE
islands), 8 red coins, 2 flying coin *rings* (yellow, not required), 6 wing-cap boxes,
3 `1up`/`box_1up`/`hidden_1up_in_pole`. **No enemies. No moving platforms. No
twirl-bounce objects. No quicksand. No lava/fire.** Terrain type `TERRAIN_SNOW`.

## 2. The 8 red coins and their reachability

| # | red coin pos | island / where | y vs ceiling (~1675) | reachable no-A? |
|---|---|---|---|---|
| 1 | (−2980, **3990**, −4248) | over NW summit (F) | **+2315** | ❌ height |
| 2 | (2735, **3140**, −3085) | open air, NE | **+1465** | ❌ height |
| 3 | (−3640, **4600**, −4200) | over NW summit (F) | **+2925** | ❌ height |
| 4 | (4400, 240, 80) | E island (C) | −1435 | ❌ off-island |
| 5 | (3440, −2680, 5240) | SE low island | far below | ❌ off-island |
| 6 | (−600, −1360, 5040) | S island (D) | below | ❌ off-island |
| 7 | (320, 1725, 40) | **on central island (A)** | +56 | ✅ **walk into it** |
| 8 | (−2560, **4600**, −4800) | over NW summit (F) | **+2925** | ❌ height |

Coin **7** is on the start island, ~390 units from spawn and ~56 above the floor —
collectible by simply walking (Mario's standing hitbox is ~160 tall). But that is 1 of
8. Coins **1, 2, 3, 8** sit `y ≥ 3140`, far above any height Mario can reach without a
lift. **Any single one of them blocks the star** — the cleanest witness is coin 3 or 8
at `y = 4600`.

## 3. The no-lift census (why `vel[1]` is never positive under no-A in WMotR)

Cross the general yVel-source census (other doc §3 / `set_mario_action_airborne`,
`mario.c:776-885`) against what WMotR actually contains:

| yVel source | value | why dead in WMotR under no-A |
|---|---|---|
| jump table (`set_mario_y_vel_based_on_fspeed`) | 30…82 | every jump entry is A-gated (other doc §3b) |
| `ACT_LAVA_BOOST` | 84 | needs lava contact — **no lava** (snow terrain) |
| `ACT_BURNING_JUMP` | 31.5 | needs fire/flame — **no fire objects** |
| `ACT_JUMP_KICK` / `SLIDE_KICK` | 20 / 12 | B in air — needs already-airborne-via-A |
| metal-water-jump (`set_mario_action_submerged`) | 32 | needs water + metal cap — **no water** |
| pipe/exit cutscene (`set_mario_action_cutscene`) | 52 / 64 | needs pipe / special exit — none (entry is a spawn, §7) |
| `bounce_off_object` | ≤20 | needs an enemy/bounce object — **none** |
| tweester/tornado | 100·sin,+1,20 | needs a tweester — **none** |
| cannon (`ACT_SHOT_FROM_CANNON`) | 100·sin | A-gated (enter+fire) and in taint T (GOAL 1) |
| flight (`ACT_FLYING`) | fwd·sin | A-gated and in taint T (GOAL 1) — the only *unbounded* climb |
| vertical wind | — | needs `SURFACE_VERTICAL_WIND` — **absent** |
| moving platform carries Mario up | — | **no moving platforms** |
| **pole climb** | — | present (6 poles) but **unreachable** — see §4 |
| `apply_gravity` | −4/frame | only ever *decreases* `vel[1]` |

So with poles set aside (§4), **no reachable code path makes `vel[1] > 0`.** Mario can
walk on floor, hang (only after a jump he can't make), or fall. His height never
increases beyond the start island's own max (`y ≈ 1675`) plus the bounded animation
y-wobble (`return_mario_anim_y_translation`, tens of units).

## 4. The poles, and why the height bound needs a thin containment step

The 6 poles are the only non-A lift *physically present*. But every pole is on/near a
**different island**, across the void from the start:
`(3996,−2739,5477)` and five at `x ≈ −2900…−3290, z ≈ −3946…−4477` (the NW spire).
Horizontal distance from the central island edge to the nearest pole is **> 1900 units**,
over open death-plane void.

To reach a pole Mario must traverse that open space — i.e. be airborne over the void.
Without A he cannot jump, and the only other way to be over the void is to walk off an
edge, after which he is *falling* (negative `vel[1]`) toward the kill plane, not gaining
the height/horizontal reach a pole grab needs. So: **reaching a pole requires a lift,
lift requires a jump, jumps need A.** The poles are therefore unreachable, and the
no-lift conclusion stands. (This is the one place the argument is *containment*, not pure
height — but it is a one-line containment: "can't cross the void without a jump.")

No lower island lies beneath the central island's footprint either (checked: C/D/E/low
are all outside `x ∈ [−1150,1090], z ∈ [−1130,1000]`), so walking off an edge is always
fatal, never a transfer.

## 5. "Never ACT_JUMP" is TRUE in WMotR (the per-level twirl disproof)

In general `ACT_JUMP` is reachable without A via the squish/quicksand remap of an
object-driven `ACT_TWIRLING` (act-jump doc §1):
`set_mario_action_airborne` (`mario.c:779-782`) rewrites a requested `ACT_TWIRLING`/`
ACT_DOUBLE_JUMP` to `ACT_JUMP` when `squishTimer != 0 || quicksandDepth >= 1.0`.

In WMotR every input to that path is absent:
- **No `ACT_TWIRLING` source:** no object carries `INT_SUBTYPE_TWIRL_BOUNCE` (no
  enemies/bounce objects at all), and no tweester. So `ACT_TWIRLING` is never requested.
- **No quicksand:** terrain is `TERRAIN_SNOW`; no quicksand floor ⇒ `quicksandDepth`
  stays 0.
- **No crusher:** no Thwomp/falling object/closing hazard ⇒ `squishTimer` stays 0.

So the remap guard `(squishTimer != 0 || quicksandDepth >= 1.0)` is permanently false,
and `ACT_JUMP`'s only producers in WMotR are the A-gated direct setters — all dead under
no-A. **In WMotR, `action` is never `ACT_JUMP`.** (And likewise never any other jump,
never twirling, never lava-boost/burning, never tornado — none of their triggers exist.)
The per-level invariant the general analysis couldn't give us holds here, for free, from
the object table.

## 6. What a Coq proof would need

This is the first GOAL-2 argument that *requires level data in the pipeline* — the prior
work was all control flow. Concretely:

1. **Ingest WMotR collision + macro/script** as generated constants (a `clightgen`/data
   step analogous to `generated/`): the floor triangle set, the red-coin positions, the
   object list. The reachability facts (max floor `y`, coin `y`, void gaps) become
   `vm_compute`-checkable over those constants.
2. **The no-lift lemma:** under no-A in *this level*, `vel[1]` is never positive. Built
   from the existing yVel-setter census (each A-gated → dead via `input_grounds_noA`; each
   object-gated → dead because the object set is empty by the macro-table constant) plus
   the §4 pole-containment step.
3. **Height-ceiling corollary:** `pos[1] ≤ maxReachableFloorY + ε` (≈ 1675 + anim bound).
   Needs: grounded ⇒ `pos[1] = floorHeight`; airborne ⇒ `vel[1] ≤ 0` so `pos[1]`
   non-increasing; the reachable floor set is the start island (no lift to a higher one).
4. **The capstone:** red coin 3 (`y = 4600`) is never within Mario's hitbox ⇒ its
   `oRedCoinFlag`/collection never fires ⇒ `bhvHiddenRedCoinStar` never spawns ⇒ no star.
   This couples Mario's bounded `pos` to the coin-collection interaction (the same
   `interaction.c` machinery already walked for GOAL 1).

Steps 2–3 are control-flow + arithmetic over level constants (tractable, GOAL-1-flavored);
step 1 is the genuinely new pipeline input; step 4 reuses the interaction engine.

## 7. Caveats / residual checks (honesty)

- **Spawn entry velocity.** Mario enters WMotR via spawn at `(-67,1669,-16)` (plus a
  self-looping `bhvAirborneWarp` 1000 units overhead, only hit if already airborne high).
  Confirm the spawn action imparts no upward `vel[1]` (it should be an idle/spawn-spin,
  not a pipe-emerge). Low risk; worth a read of the WMotR entry warp/act.
- **Anim y-translation** (`return_mario_anim_y_translation`, `mario.c:219`,
  `pos[1] += translation[1]`) adds a small per-frame offset from animation data; must be
  bounded (it is small — tens of units — and does not accumulate), so the `ε` in the
  ceiling is a real but tiny constant. Quantify from the WMotR-reachable animations.
- **Hangable ceilings** let Mario move along a ceiling at fixed `y` *below* it; grabbing
  one needs a jump (A) anyway, and they are at the central-island level — no net lift.
- The argument shows the star never *spawns*; pair with "no other WMotR exit gives the
  star" (the success warp is gated on the star) for the full "can't complete" statement.

## 8. One-line summary

WMotR under no-A is a **lift-free inescapable island**: no jump (A-gated), no lava/fire/
enemy/tweester/quicksand/wind/moving-platform (none exist), and the only present lift —
poles — is across an un-crossable void. So Mario is pinned at `y ≲ 1675` on the start
platform, 4 of the 8 red coins float at `y ≥ 3140`, the red-coin star never spawns, and
the level cannot be completed — **and as a bonus, `ACT_JUMP` (and twirling) are provably
unreachable in this specific level.**

See [[goal2-y-census]], [[wmotr-argument-shape]], [[flying-action-entries]].
