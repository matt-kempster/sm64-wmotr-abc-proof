# GOAL 2: the height invariant Φ, concretely (2026-09-27)

> **Update (as built, `HeightInvariant.v` / `HeightMoveCatalog.v`):**
> - Φ reads its cells as `budget_ok`, which adds `gfx.pos[1]` and its own budget.
> - `GP_RESERVE` is 111.
> - `windup_left` carries EPS per frame left.
> - `sk_bounced_credit` gains +1/4 while v > −1, so the bounce apex is 371.707 ≤ 372.
> - The slide-kick clause is rounding-aware, and there is a new ground-pound clause.
>
> Why each change was needed: `docs/goal2-crux-decomposition.md` §"As built".
> The table below is the original design.

`HeightFrame.v` takes Φ as a parameter with two rows: `Hphi_y` (Φ ⇒ y ≤ YMAX)
and `Hseg_action_phi` (one real `execute_mario_action` preserves Φ). This doc
defines Φ over real `MarioState` fields. Writing it down turned up two errors in
E3's height budget, so it starts with the corrected numbers.

## 1. Corrected budget (`tools/goal2_budget.py`, exact binary32)

Heights are relative to the floor the episode launched or bounced from (a floor ≤ H*).

| chain | top | attach |
|---|---|---|
| ground dive, vel 20 | 60 | 138 |
| rollout, vel 30 | 128 | 206 |
| slide-kick launch, vel 12, g 2 | 42 | 120 |
| walk off a ledge → freefall → GP / ledge grab | 110 | 239 |
| butt-slide-air bounce (g 4) → freefall → GP / ledge grab | **305** | 434 |
| **slide-kick bounce (g 2) → freefall → GP / ledge grab** | **370.5** | **494** |

E3 said Δ_pot = 273 (the bounce at g 4, plus the +78 snap). It had two errors:

1. **Slide kick flies under gravity −2** (`apply_gravity`, `mario_step.c:543`).
   A terminal-speed bounce (`vel = 75/2 = 37.5`, `airborne.c:1604`) climbs
   37.5 + 35.5 + … + 1.5 = **370.5**, not 195. E3 used g −2 for the slide-kick
   *launch* (apex 42) but g −4 for its bounce.
2. **Butt-slide-air does not reset `actionTimer` on its bounce** (`airborne.c:1445`,
   while slide kick does at `:1606`). So its `→FREEFALL` edge (`:1436`, timer > 30
   and more than 500 above the floor) can fire while Mario is still *rising*. E3's
   "freefall is only entered descending, so GP never stacks on an apex" is false
   for this edge: bounce apex 195 + GP windup 110 = **305**.

**Update 2026-09-27 (level data in generated/):** the exclamation box is scaled ×2, so its top is
y + 104, not y + 52. H* is **2424** (the wing-cap box at y = 2320), YMAX = **2796**, the coin #2 margin
is **+184** and the pole-window margin **+198**. The gap fact still holds (no floor in (2424, 3046)).
The numbers below predate this.

**Consequences.** H* is unchanged (2372, entry-seeded): with attach 494 the ladder
still stops below the next rung at 2994.

- YMAX = H* + 370.5 = **2742.5**. Coin #2 needs y ≥ 3140 − 160 = 2980, so the
  margin is **+237.5**.
- Max attach = H* + 494. The moat is 622, so the margin is **+128** (was 349).

The theorem survives with less slack. Re-run both tools whenever a mechanism is
added.

## 2. Φ

Fields, with offsets from `include/types.h` (to be pinned by `vm_compute` against
`mario.prog`, like `pos` @ 60 in `HeightFrame.v`):

- `action` @ 0x0C
- `actionState` @ 0x18 (u16)
- `actionTimer` @ 0x1A (u16)
- `pos[1]` @ 0x40
- `vel[1]` @ 0x4C
- `floorHeight` @ 0x70

Constants: K = H* = 2424 (was 2372; see the update above) and A = 372: the SK-bounce apex 370.5625 in the
energy form below, plus the rounding allowance (0.89 at the bounce). YMAX = K + A = **2796**.

**Rounding allowance EPS = 1/64 per remaining ascent frame.** Real arithmetic conserves
y + energy exactly. In binary32 each rising frame (4 roundings of `pos += vel/4`, one of
`vel -= g`) can add up to ~1/128, and a per-frame invariant cannot absorb that
repeatedly. So `bal_g(v) = energy + EPS·(v/g + 1)` for v > 0. Post-bounce slide kick
carries EPS·((v+75)/2 + 1), counted until the −75 clamp. Descending frames round
down-safely (y' ≤ y exactly) and need nothing. `Unwired/HeightFloatSteps.v`,
`ballistic_frame`, proves the rising and falling air frame against this budget, in
binary32, over the real operations.

```
Φ(m) ≜ Φ_act ∧ Φ_pot ∧ Φ_side

Φ_act:  action ∈ R_noA         -- the no-A-reachable action set (see §3; NOT just GOAL 1's ∉ T)

Φ_pot:  y + credit(m) ≤ K + A, with credit(m) ≥ 0:
  grounded (no ACT_FLAG_AIR; stationary/moving) credit = A           (⇔ y ≤ K: stands on a laddered floor)
  ACT_FREEFALL                                  credit = bal4(v) + 110   (Z→GP reserve)
  ACT_BUTT_SLIDE_AIR (either state)             credit = bal4(v) + 110   (can freefall while rising)
  ACT_SLIDE_KICK, actionState 0                 credit = bal2(v) + 110
  ACT_SLIDE_KICK, actionState 1 (post-bounce)   credit = E2(v)           (signed energy, see below)
  ACT_GROUND_POUND, actionState 0               credit = Σ_{t=timer}^{9} (20 − 2t)   (windup left)
  ACT_GROUND_POUND, actionState 1               credit = 0
  ACT_DIVE, rollouts, KB/soft-bonk/air-hit-wall credit = bal4(v)
  ACT_LEDGE_GRAB / climbs                       credit = A, anchored: floorHeight ≤ K
  ACT_SPAWN_NO_SPIN_AIRBORNE (level entry)      credit = bal4(v)   (2669 ≤ K + A: margin 74)

Φ_side: vel[1] ≥ −75 (terminal clamp; the bounces need it)
        ACT_SLIDE_KICK ∧ state 1 ⇒ vel[1] + 2·actionTimer ≤ 37.5
        finiteness of y, v
```

Here `bal_g(v)` is the ballistic credit, zero for v ≤ 0 and (v + g/2)²/(2g) for
v > 0. `E_g(v) = (v + g/2)²/(2g)` is its signed version.

**Why the signed energy for post-bounce slide kick.** Its `→FREEFALL` edge needs
30 frames after the bounce, so Mario enters freefall *descending*, at vel ≤ −22.5
(the `Φ_side` timer clause). `E2` is exactly conserved by a g-2 frame:
`E2(v−2) = E2(v) − v`. Hence y ≤ K + A − E2(−22.5) = K + 255, and
freefall's y + 110 ≤ K + 365 ≤ K + A. The positive-part credit loses that
information. A plain "+110 reserve" there would force A = 480.5, which leaves
a ledge-attach margin of 12.5.

**`Hphi_y` is immediate:** credit ≥ 0, so y ≤ K + A = YMAX.

## 3. Obligations `Hseg_action_phi` decomposes into

1. **Φ_act (action whitelist).** One frame from Φ keeps the action in R_noA.
   This is the GOAL-1 action-value engine with a different predicate:
   `action_sat` is already parametric in Q. **Φ without Φ_act makes the crux
   row FALSE.** The row quantifies over every memory in Φ ∧ mem_ok, and GOAL 1
   excludes only T. For example, ACT_JUMP with a large vel is allowed by mem_ok
   and flies past the budget. That would be the phantom-∀ failure. R_noA =
   E3's node table (airborne) plus the ground/automatic census (not yet done).
2. **Ballistic frames** (T3): `perform_air_step` keeps y + bal_g(v)
   (resp. E2) within the budget. The ESBMC finding 6 (`experiments/esbmc`,
   gain ≤ max(v,0) + 239 per frame) is the falsifier-checked prototype.
3. **Credit-switching edges**, one per row of E3's edge table, re-checked
   with g −2 for slide kick: launches (ground → air sets v to a constant from
   y ≤ K), bounces (floor ≤ K, |v| ≤ 75), →FREEFALL (reserve), →GP (reserve →
   windup), wall bonks (v zeroed).
4. **Attach edges** (landing, ledge grab, climb): the new floor is a real
   WMotR floor ≤ y + 78 (landing) or ≤ y + 239 (ledge). With y ≤ K + A that
   means a floor ≤ K + 494 < K + 622, so by the gap fact it is ≤ K. This needs:
   - the **find_floor value contract**: the returned height is a WMotR floor
     height (or −11000);
   - the **gap fact** as a level-data lemma.

   `find_floor` is *external* in the twelve-TU link. `external_call` is an
   abstract Parameter, so its return value is unconstrained. **Obligation 4
   cannot be proved over `linked12` without a value row for find_floor.**
   That row (arg-aware: result ≤ (s16)y + 78, and in the WMotR floor multiset)
   is a named boundary until P1′ links surface_collision. So P1′ is shared
   infrastructure for GOAL 1 and GOAL 2.

## 4. What to check before proving (cheap falsifiers)

- ESBMC, per mode: "Φ_pot(m) ∧ one `act_*` handler ⇒ Φ_pot(m')" with the
  collision stubs of `experiments/esbmc`. Start with `act_slide_kick` state 1
  (the tight energy argument) and `act_butt_slide_air`. Run a control first:
  A = 305 must FAIL on slide kick.
- Oracle (tether 5.1): record a real slide-kick bounce off a ledge and compare
  the measured apex with the table.
