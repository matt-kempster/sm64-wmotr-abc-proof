# GOAL 2 — WMotR floor/object inventory + ladder-fixpoint numeric gate (task E1)

**Status:** numeric sanity check, 2026-07-01. Executes E1 of
[goal2-strategy-v2-2026-07-01.md](goal2-strategy-v2-2026-07-01.md) §7. **No Coq.**
This is the gate the strategy demands *before* any GOAL-2 capstone Coq is written
(§7: "if the gap fact fails numerically, everything above is moot — run this first").

All numbers are produced by [`tools/goal2_ladder.py`](../tools/goal2_ladder.py), which
parses the WMotR collision mesh **directly** from decomp source and reproduces the
game's floor classification (`surface_load.c`) exactly. Re-run: `python3 tools/goal2_ladder.py`.

## VERDICT

> **GAP FACT: HOLDS.** No WMotR floor lies in `(H*, H* + Δ_pot]` for any of
> Δ_pot ∈ {316, 366, 400}.
>
> - **Δ_pot = 316** (real-physics best estimate): **H\* = 1675** (spawn island max),
>   first floor above = **2012** (wing-cap box #1 top), **gap = 337 > 316**. Holds
>   by **21 units** — exactly the thin margin the strategy doc predicted.
> - **Δ_pot = 366 and 400**: the ladder climbs two rungs (spawn 1675 → box#1 /
>   island-B 2012–2017 → box#6 top 2372), so **H\* = 2372**; the next floor is the
>   NW summit at **4535**, **gap = 2163**. Holds by a wide margin.
>
> **The highest coins stay unreachable in every case.** The binding coin is coin#2
> (`y=3140`); its margin above the airborne envelope `H*+Δ_pot` is **+1049** (Δ=316),
> **+302** (Δ=366), **+268** (Δ=400) — all > 200. So the red-coin star never spawns.

Robustness (see §5): the *floor* gap fact survives any Δ_pot < **2163**; the stronger
*coin-collection* safety survives any Δ_pot < **668**. The real Δ_pot ≈ 316..366 sits
comfortably below both. The strategy's "holds by ~21 units" worry is real but concerns
only *which rung H\* lands on*, not whether the coins are reachable — the coins keep
hundreds of units of slack throughout.

---

## 1. Floor-height inventory (static collision mesh)

Source: `vendor/sm64/levels/wmotr/areas/1/collision.inc.c` (694 vertices, 1352
triangles). Format macros are pass-through — **no vertex scaling**
(`include/surface_terrains.h:197` `COL_VERTEX(x,y,z) ⇒ x,y,z`;
`:203` `COL_TRI(v1,v2,v3) ⇒ v1,v2,v3`).

**Floor test — reproduced exactly** from `surface_load.c`:
`read_surface_data` (`:296-378`) computes the un-normalized normal from the vertex
winding `(v2−v1)×(v3−v2)` (`:322-325`), drops the triangle if `mag < 0.0001`
(`:346`), normalizes; `add_surface_to_cell` (`:113-126`) classifies
`normal.y > 0.01 ⇒ FLOOR`, `< −0.01 ⇒ CEILING`, else `WALL`. A floor triangle's
max standing height at any interior (x,z) equals its **max vertex y** (linear plane
over a convex hull), so the ladder uses per-triangle `maxY`.

Whole-mesh classification: **778 floor, 414 ceiling, 160 wall** triangles.

Per-surface-type (COL_TRI_INIT sections at collision.inc.c:699/768/807/810/2031):

| surface type (value) | tris | floor / ceil / wall | y-range | role |
|---|---|---|---|---|
| `SURFACE_DEFAULT` (0x0000) | 68 | 4 / 16 / 48 | −3557 … 824 | environment default |
| `SURFACE_HANGABLE` (0x0005) | 38 | 0 / **38** / 0 | 1536 (flat) | climbable **ceiling**; grab needs a jump (A); at spawn-island level, no lift |
| `SURFACE_DEATH_PLANE` (0x000A) | 2 | 2 / 0 / 0 | −8191 | kill floor (below everything) |
| `SURFACE_NOT_SLIPPERY` (0x0015) | 1220 | 748 / 360 / 112 | −1535 … 4542 | the bulk terrain (climbable, non-slippery) |
| `SURFACE_HARD_NOT_SLIPPERY` (0x0037) | 24 | 24 / 0 / 0 | −2738 … 824 | hard, always fall damage |

Surface-type constants: `include/surface_terrains.h:5,8,10,17,44`. **No
`SURFACE_VERTICAL_WIND` (0x0038), no water/lava/slippery/moving surface types.**

Floor-triangle `maxY` histogram (static mesh, 500u buckets):

```
[ -8500,-8000)   2   death plane
[ -3500,-3000)   2   SE low island + pole area
[ -3000,-2500)  12
[ -1500,-1000) 104   S island (D)
[     0,  500)  68   E island (C)
[   500, 1000)  12   W cannon island (E)
[  1500, 2000) 256   central/spawn island (A) — tops at 1675
[  2000, 2500)  66   NW spire base (B) — top 2017
[  4500, 5000) 256   NW summit (F) — 4535..4542
```

**Spawn floor.** Spawn = `MARIO_POS(area 1, yaw 270, pos −67, 1669, −16)`
(`script.c:65`), corroborated by `special_null_start` at the same point
(`collision.inc.c:2058`). Under spawn xz `(−67,−16)` exactly two floor triangles
project: the spawn island at plane-height **1669.00** (`SURFACE_NOT_SLIPPERY`) and
the death plane at −8191. `find_floor` returns the highest floor ≤ y+78 buffer
(`surface_collision.c:459`) ⇒ **spawn_floor_height = 1669**; the spawn island's max
floor within +100 is **1675** (matches the prior ~1675 estimate).

## 2. Dynamic floors (the 6 wing-cap `!` boxes)

`macro_box_wing_cap` objects (`macro.inc.c:15-20`). Each loads the exclamation-box
collision model (`exclamation_box.inc.c:101 load_object_collision_model`, only in the
solid `oAction == 2` state; the loaded surfaces get `SURFACE_FLAG_DYNAMIC` at
`surface_load.c:715`). The box model
(`actors/exclamation_box_outline/collision.inc.c:7-14`) spans `y ∈ [+30, +52]` about
its origin, x/z ∈ ±26; its **top face is a floor at oHomeY + 52**. For a macro object
`oHomeY = oPosY = ` the macro pos y. Box tops:

| box (macro.inc.c) | home pos | **top floor y = pos_y+52** |
|---|---|---|
| :15 | (−400, **1960**, −120) | **2012** (only box near the spawn island height) |
| :16 | (−240, −1080, 4520) | −1028 |
| :17 | (3600, −2480, 5440) | −2428 |
| :18 | (3960, 520, 440) | 572 |
| :19 | (−3200, **4880**, −4040) | **4932** (above the highest coin) |
| :20 | (−2760, **2320**, −4080) | **2372** |

These 6 tops are the *only* dynamic floors in WMotR (confirmed by the squish census:
only `bhvExclamationBox` calls `load_object_collision_model`). They are added to the
floor set for the ladder.

## 3. Ladder fixpoint (`tools/goal2_ladder.py`)

Start set = floors with height ≤ spawn_floor + 100 = 1769 ⇒ start_max **1675**.
Iterate: absorb any floor ≤ `H + Δ`, take max, repeat to fixpoint. Distinct floor-top
heights in the reachable band and the gaps between them:

```
1668,1669,1670,1671,1675   spawn island (A)
   ↑ gap 337
2012   box#1 top  (dynamic)
   ↑ gap 5
2017   NW spire base (B)
   ↑ gap 355
2372   box#6 top  (dynamic)
   ↑ gap 2163            <-- the moat that saves the theorem
4535,4537,4538,4542   NW summit (F, where the high coins float)
   ↑ gap 390
4932   box#5 top  (dynamic, above everything)
```

| Δ_pot | H\* | first floor above H\* | floor gap | gap-fact |
|---|---|---|---|---|
| **316** | **1675** | 2012 (box#1) | **337** | **HOLDS** (need >316; +21) |
| **366** | **2372** | 4535 (summit) | **2163** | **HOLDS** (need >366) |
| **400** | **2372** | 4535 (summit) | **2163** | **HOLDS** (need >400) |

Δ_pot = 316 = rollout apex 128 + GP windup 110 + landing snap 78;
366 = apex 128 + ledge window 238; 400 = safety probe (all per strategy §2).

## 4. Red-coin margins (all 8, exact positions)

`macro_red_coin` objects. Margin = coin_y − (H\*+Δ_pot), the airborne envelope.

| coin | pos (x,y,z) | macro.inc.c | Δ=316 margin | Δ=366 margin | Δ=400 margin |
|---|---|---|---|---|---|
| 1 | (−2980, **3990**, −4248) | :9 | +1999 | +1252 | +1218 |
| 2 | ( 2735, **3140**, −3085) | :10 | **+1149** | **+402** | **+368** |
| 3 | (−3640, **4600**, −4200) | :11 | +2609 | +1862 | +1828 |
| 4 | ( 4400, 240, 80) | :12 | −1751 (below; off-island) | −2498 | −2532 |
| 5 | ( 3440, −2680, 5240) | :13 | −4671 (below; off-island) | −5418 | −5452 |
| 6 | ( −600, −1360, 5040) | :14 | −3351 (below; off-island) | −4098 | −4132 |
| 7 | (  320, **1725**, 40) | :22 | −266 (**on spawn island — collectible**) | −1013 | −1047 |
| 8 | (−2560, **4600**, −4800) | :23 | +2609 | +1862 | +1828 |

The 4 "high" coins **1, 2, 3, 8** (y ≥ 3140) stay ≥ **+368** above the envelope in
every case (binding = coin#2 at 3140). Any one of them blocks the 8/8 red-coin count.
Coins 4/5/6 sit *below* the envelope but on far islands across the death void
(horizontal, not height — outside this pure-height model, discharged by prior
containment analysis). Coin#7 is on the spawn island and *is* collectible — but it is
1 of 8, so the star still never spawns.

**Box-top margins** vs the ledge-grab airborne envelope `H*+238`: at Δ=316, box#1
(2012) clears `1675+238 = 1913` by only **+99**, and box#6 (2372) by +459 — the boxes
are *just* out of ledge-grab reach, corroborating the thin-margin story.

## 5. Robustness: the true breaking DELTAs

The pure-height ladder climbs whenever Δ_pot ≥ the next gap:

- Δ_pot ≥ **337** → H\* climbs off the spawn island to 2012/2017.
- Δ_pot ≥ **355** → H\* reaches box#6 top 2372.
- **H\* pins at 2372 for all 355 ≤ Δ_pot < 2163** (the 2163 moat up to the summit).
- Δ_pot ≥ **2163** → H\* climbs to the summit (4535) → the high coins' floor becomes
  reachable → **the floor gap fact would fail.**

Coin collection (the actual theorem) is airborne, so the binding threshold is when
`H* + Δ_pot ≥ coin#2_y − 100 = 3040`. With H\* pinned at 2372 that is **Δ_pot ≥ 668**.

So: **floor gap fact holds ∀ Δ_pot < 2163; coin-collection safety holds ∀ Δ_pot < 668.**
Real Δ_pot ≈ 316..366 ⇒ safe with ~300u of headroom on the tighter (coin) bound.

## 6. Object / hazard checklist (definitive, from script.c + macro.inc.c)

Every WMotR object, with a no-A-height verdict and cite:

| object / feature | present? | cite | matters to height? |
|---|---|---|---|
| water volumes | **NO** | no water surface type in collision.inc.c; `moving_texture.h` in geo.c/leveldata.c is only the animated cloud-**floor texture**, not a water box | — |
| vertical wind / draft | **NO** | no `SURFACE_VERTICAL_WIND` (0x0038) in mesh (§1); `apply_vertical_wind` dead (y-census §1) | — |
| hangable ceilings | **yes (38 tris)** | `SURFACE_HANGABLE` @ collision.inc.c:768, all ceilings at y=1536 | grab needs a jump (A); below spawn floor ⇒ no lift |
| poles / trees | **6 poles** | `bhvPoleGrabbing` script.c:19-24, at (3996,−2739,5477) + five on the NW spire | across the death void (>1900u), unreachable without a jump (A) — prior doc §4 |
| enemies / bully / tweester / Chuckya / Heave-Ho | **NONE** | no such behavior in script.c or macro.inc.c | no bounce/throw/tweester lift |
| moving platforms | **NONE** | no moving-surface type; no platform behavior | — |
| quicksand / lava / fire | **NONE** | terrain `TERRAIN_SNOW` (script.c:61); no such surface type | no squish/boost |
| cannons | **2 (closed)** | `macro_cannon_closed` macro.inc.c:3 (−4456,827,191, W island E) & :4 (3712,−2740,5200, SE); opener bob-omb macro.inc.c:5 | enter+fire A-gated + in GOAL-1 taint T; barrel at cannon pos, off spawn island |
| airborne warp | **1** | `bhvAirborneWarp` @ (−67, **2669**, −16) script.c:51, self-loop to WARP_NODE_0A :52 | at spawn xz, y=2669; benign reset, not a lift — see OPEN item |
| red-coin star | 1 | `bhvHiddenRedCoinStar` @ (−160,1950,−470) script.c:29 | the target: needs 8/8 red coins |
| success / death / floor warps | 3 | script.c:53-55 (→ Castle / Castle / Castle Grounds) | leave the level; death warp re-inits at spawn |
| 1-up boxes / hidden 1-ups | 4 | macro.inc.c:7,8,21,28 | no height effect |
| coin rings (yellow) | 5 | macro.inc.c:6,24-27 | not required for the star |

## 7. OPEN items / caveats (not massaged)

1. **Airborne warp vs. the Δ≥366 envelope (horizontal caveat).** At Δ_pot ≥ 366 the
   height envelope reaches 2738 > the airborne-warp y (2669). The warp sits at the
   *spawn* xz (−67,−16), where the local envelope is only `1675+Δ ≤ 2075 < 2669`, so
   it is never entered — but that is a *horizontal* argument the pure-height ladder
   cannot make. Low risk (the warp is a same-area self-loop, not a lift), but it is
   the one place Δ≥366 pokes above an object the height model alone can't dismiss.
   Flag for the eventual Coq: either keep Δ_pot < 355 (so H\*=1675 and the envelope
   never nears 2669) or add the spawn-xz containment for this warp.
2. **Δ_pot itself is E2's job.** This gate *assumes* the 316/366/400 census values;
   E2 must pin the exact per-mechanism windows (esp. whether the GP-then-land chain is
   really ≤316 and whether ledge-grab's +238 is gated out). If E2 returns Δ_pot ≥ 668,
   re-run this gate — coin#2 would then be at risk from box#6.
3. **Box `oHomeY = oPosY` assumption.** Taken from the macro pos (boxes are static, no
   motion — corroborated by the squish census). If any box's runtime `oPosY` differed
   from its macro y this would shift a box-top; low risk (static level, no elevator).
4. **Death-plane floor included but inert.** The 2 death-plane triangles (y=−8191)
   classify as floors and enter the start set (≤ spawn+100) but never raise H\*;
   standing on them is fatal, not a real stance. Noted, harmless to the fixpoint.

---

### Three most surprising findings

1. **The gap fact's fragility is about H\*'s rung, not the coins.** At the real Δ_pot
   the spawn-island story (H\*=1675) holds by only 21 units, but even if it breaks
   (Δ_pot ≥ 337) H\* only climbs to 2372 and the coins stay ≥368 above — a **2163-unit
   moat** between box#6 (2372) and the summit (4535) is what actually protects the
   theorem. The architecture is robust to Δ_pot < 668 (coins) / < 2163 (floors), far
   past the 316..366 estimate.
2. **A wing-cap box top (4932) sits *above the highest red coin* (4600),** and box#6
   (2372) is the single highest ladder-reachable-by-height floor short of the summit —
   the dynamic boxes, not the static mesh, define the middle of the ladder.
3. **The binding high coin is #2 at y=3140, not the y=4600 coins.** Prior docs aimed
   at the 4600 coin for slack; numerically the *lowest* high coin (3140) is the true
   constraint, and at Δ_pot=400 its margin is only +368 — the place to watch if E2
   grows Δ_pot.
