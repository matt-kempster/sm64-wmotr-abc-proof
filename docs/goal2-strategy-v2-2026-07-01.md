# GOAL 2, strategy v2 — the attach-window / floor-ladder architecture

*2026-07-01, fresh-eyes rewrite. **Supersedes** `goal2-general-height-invariant.md`
(v1). v1's skeleton (one-frame induction, y as the target, Mario as a state
machine, finite-census discipline) survives; its load-bearing middle — the
scalar `C_pos` invariant and the "grounded ⇒ floor ≤ reachable-floor-max"
dominator row — does not. This doc says what's wrong, what replaces it, and
what the real hard problems are.*

## 0. What v1 got wrong (the autopsy)

1. **The grounded row was circular.** v1's dominator table discharged grounded
   launches with "launch height ≤ reachable-floor-max (level data)". But
   *which floors are reachable* is exactly the theorem. A scalar `pos[1] ≤
   C_pos` conjunct cannot break the circle, because it doesn't say *why* Mario
   can't stand on a 4600-unit cloud — level data alone doesn't either (the
   clouds are real floors; they're just not *attachable* from below).
2. **"Apex" was the wrong envelope.** v1 reasoned about ballistic apex
   (`+max(0,vel)²/8`, ≈ +112..128). But height is banked by **attaching** to a
   floor, and the attachment mechanisms reach *above* Mario's head:
   - **Landing snap-up:** `perform_air_quarter_step` lands whenever the floor
     at the new (x,z) is above `nextPos[1]` — and `find_floor` returns floors
     up to **y + 78** (`surface_collision.c:459`). Window: **+78**.
   - **Ledge grab:** `check_ledge_grab` (`mario_step.c:348`) searches the
     ledge floor at `nextPos[1] + 160` — plus the same 78 buffer. The code
     comments it itself: *"we will sometimes grab a higher ledge than
     expected (glitchy ledge grab)"*. Window: **+238** (gated: `vel[1] ≤ 0`,
     a wall hit at the upper probe, displacement against velocity,
     ledge − y > 100).
   - **Ground step-up:** grounded y is *always* a `find_floor` return, and
     each quarter-step can step onto a floor up to **+78** higher
     (`mario_step.c:287,302` + the find_floor buffer). Walking climbs any
     78-laddered floor sequence.
3. **The worst case chains mechanisms.** Rollout launch (`vel[1]=30`,
   discrete apex **+128**) → mid-air ground-pound windup (**+110** over 10
   frames, `yOffset = 20−2·timer`, ceiling-gated but WMotR's sky has no
   ceiling) → landing snap **+78** ⇒ attachable floor up to
   **launch + 316**. The WMotR wing-cap box tops (the only dynamic floors)
   sit at oHomeY+52 ≈ **+337** above the spawn floor — the theorem holds by
   **~21 units**, and only because ledge-grab (+238 window) requires a wall
   hit at `y+150` that the box underside (+315) stays above at rollout apex,
   and the GP-then-land chain tops out at +316 < +337. v1's constants were
   not merely imprecise; they were *the wrong kind of object*. The margins
   are real and thin, so the mechanism windows must be first-class.
4. **Floats were never mentioned.** `pos`/`vel` are f32. Every bound is a
   statement about CompCert/Flocq `binary32` arithmetic, not ℤ. GOAL 1 never
   had to bound a float; GOAL 2 is *made of* float bounds. This is the
   biggest qualitative jump and it needs its own layer, designed up front.
5. **Wrong target coin.** v1 aimed at the lowest high coin (3140). We need
   only ONE uncollectable coin — aim at the *highest* (4600) and the numeric
   slack is ~2700 units instead of ~1200. (If the ladder fixpoint tops out at
   the spawn island, all four high coins die at once; but state the capstone
   against the most-slack coin.)

**Kept from v1:** the chain-is-the-induction principle (one-frame invariant,
tricks become branches); y as the sole tracked quantity (no (x,z) in Φ — see
§2, this is now *derived*, not assumed); the finite-census discipline; the
squish-cancel kill (it survives unchanged as one dead attach mechanism);
Mario-as-state-machine (now formalized as the episode graph, §4).

## 1. The shape of the theorem

**G2-I (the numeric core):** for every no-A run from the WMotR spawn state,
every reachable memory satisfies `B2R(pos[1]) ≤ Y_MAX`, where
`Y_MAX = H* + Δ_pot` (≈ 1675 + 238 = **1913**, to be pinned exactly).

**G2-II (the completion chain, GOAL-1-shaped):** `pos[1] ≤ Y_MAX` ⇒ the
highest red coin (y = 4600, interaction window ~±100) is never collected ⇒
`gRedCoinsCollected` never reaches 8 ⇒ the hidden-red-coin-star behavior
never spawns the star ⇒ `interact_star_or_key` never fires for it ⇒ the
WMotR star bit is never set. Every link is a one-writer/gating census of
exactly the kind GOAL 1's machinery already does (bit-taint, not numerics).
G2-II is *deferrable and delegable*; G2-I is the research contribution.

## 2. The two-constant architecture: H* and Δ_pot

Everything hangs on two numbers and one geometric fact.

- **Δ_pot (dynamics, level-independent):** the maximum height above the
  launch floor at which Mario can *attach* to a new floor, under no-A.
  Computed from the **attach-window census** (§3) + the **episode potential
  budget** (§4). Current best estimate: `max(apex 128 + GP 110 + land 78,
  apex 128 + ledge 238 [wall-gated], …) = 316..366`, to be pinned per
  mechanism.
- **H\* (geometry, one decidable computation):** the least fixpoint of the
  floor ladder: start from the spawn floor set; a floor F' is ladder-reachable
  from F if `h(F') ≤ h(F) + Δ_pot` (air) or `h(F') ≤ h(F) + 78`-chained
  (walk — subsumed by the air window). H* = the max floor height in the
  closure, over the **full WMotR floor inventory: static collision mesh +
  the 6 exclamation-box collision models** (tops at oHomeY+52).
- **The gap fact:** *no WMotR floor has height in `(H*, H* + Δ_pot]`.* This
  single leveldata lemma is what makes the frame induction close without any
  horizontal reasoning: any floor Mario can attach to from height ≤ H* is
  itself ≤ H*.

Why no (x,z) tracking is *sound* (not just convenient): we over-approximate
by ignoring horizontal feasibility entirely — if a floor's height is within
the window, we assume Mario can reach it. The ladder closure is then a pure
computation over the sorted height multiset. If the gap fact fails (some
floor at H*+200 that's horizontally unreachable), *then* we'd need regions —
first compute the inventory and check; I expect the WMotR clouds to be
hundreds of units apart vertically.

**The invariant (sketch):**

```
Φ(m) ≜  Φ_act:     action(m) ∈ R_noA            -- GOAL-1 taint ∪ the episode-graph action set
      ∧ Φ_ground:  grounded(m) ⇒ pos[1] = h(m->floor) ∧ h(m->floor) ≤ H*
      ∧ Φ_air:     airborne(m) ⇒ Pot(m) ≤ H* + Δ_pot
      ∧ Φ_special: cannon-loaded ⇒ pos = barrel-pos; ledge-hang/climb ⇒ anchored to a ≤H* floor;
                   squishTimer = 0; death/warp modes ⇒ re-init to spawn
```

with `Pot(m) = B2R(pos[1]) + ballistic(vel[1]) + windup_credit(m)` where
`ballistic(v) = discrete sum of the +v, v−=4 recurrence (≤ v²/8 + v/2)` and
`windup_credit` = the remaining GP windup allowance (110 − f(actionTimer) when
`action = ACT_GROUND_POUND` in windup, else 0). `Pot` is the ranking function:
ballistic frames preserve it (gravity), launches from ground re-set it to
`h(floor) + budget ≤ H* + Δ_pot`, and §4 shows no mid-air edge increases it.

LEVELDATA facts (gap fact, no water / wind volumes / hangable ceilings /
enemies / tweester / Bully, box geometry, coin positions, spawn/warp data)
are **static lemmas consumed by the induction, not conjuncts** — v1 wrongly
put "LEVELDATA(WMotR)" inside Φ where it did no inductive work.

## 3. The attach-window census (finite, decidable, the heart of soundness)

Every way an airborne Mario becomes anchored to geometry, with its window
above the current airborne y — each row verified against the real step code:

| mechanism | site | gate | window above airborne y |
|---|---|---|---|
| landing snap | `paqs` `nextPos[1] ≤ floorHeight` branch | always during air steps | **+78** (find_floor buffer) |
| ledge grab | `check_ledge_grab` | `vel[1] ≤ 0` ∧ upper-wall hit (probe y+150) ∧ displacement-against-vel ∧ ledge−y ∈ (100, 238] | **+238** |
| ground step-up | `pgqs` snap | grounded | **+78** per quarter-step, onto real floors (ladder-subsumed) |
| ceiling hang | `paqs` AIR_STEP_GRABBED_CEILING | hangable ceiling exists | **absent in WMotR** (leveldata) |
| squish up/down-warp | act_squished | reachable ≤150 dynamic squish spot | **dead** (census: none reachable) |
| wall-kick re-launch | A-gated | dead (GOAL-1 `input_grounds_noA`) | — |
| cannon shot | A-gated fire | dead (GOAL-1 taint incl. cannon) | — |
| pole/tree grab | ACT_HOLDING_POLE entry | pole/tree object exists | **absent in WMotR** (verify in object list) |
| warp/teleport nodes | level script | WMotR warp set (death/entry only?) | leveldata row |

The census is *self-policing the same way GOAL 1's was*: the per-handler walk
of the air-step family must classify every path that sets `m->floor`/returns
`AIR_STEP_LANDED`-class results; a mechanism we missed shows up as an
unclosable branch, not a silent hole.

## 4. The episode graph (the "action cycles" formalization)

An **episode** is a maximal airborne interval: launch (leaving a floor at
height h₀ ≤ H*) → attach. Within an episode, the reachable-under-no-A
airborne actions form a finite directed graph (nodes: ACT_DIVE,
ACT_FORWARD_ROLLOUT, ACT_FREEFALL, ACT_GROUND_POUND, ACT_JUMP_KICK,
knockback/steep-slide re-airs, …). Each edge either:
- preserves `Pot` (pure ballistic continuation),
- **spends** (sets `vel[1]` to a constant ≤ current potential: needs the
  per-edge check `h + ballistic(c) ≤ Pot`), or
- **credits** (GP windup +110; anim y-translation ε — see §6.2).

**The theorem's combinatorial core: the episode graph has no
potential-increasing edge and no credit-edge reachable twice within one
episode** (GP cannot be re-entered mid-air once in GP; nothing else credits).
This is where "another action could also cause this" gets its once-and-for-all
answer — not a per-trick disproof but a per-EDGE obligation over a finite
graph that the dispatch census already enumerates. Every mid-air `vel[1] :=
c > 0` write (v1's "danger class") is an edge here; squish-cancel was one
(dead); object-bounces (GP-on-box bounce, `interact` bounce rows) are edges
gated on *being above the object* — they only fire above box tops, which the
ladder already excludes (non-circular: the invariant excludes reaching box
height, so bounce edges are vacuous under Φ).

Deliverable: the edge table with per-edge dominators (A-gated / spend /
credit / object-gated / absent), C line cites, and the `Pot`-preservation
obligation each row generates. **This is P6a re-scoped** — it replaces v1's
flat "danger-class enumeration".

## 5. The float layer (the genuinely new verification problem)

All of §2–4 is arithmetic over **binary32**. Plan:

1. **One brick, used everywhere:** an interval lemma family over Flocq's
   `Bplus/Bminus/Bmult` at binary32: if `B2R x ∈ [a,b]` and `B2R y ∈ [c,d]`
   (finite, no overflow in range), then `B2R (Bplus x y) ∈ [round_down(a+c),
   round_up(b+d)]` — by rounding monotonicity. Same for the specific
   constants (`/4` is exact; `−4` exact on the magnitudes involved;
   `20−2·timer` exact small ints). The magnitudes here (≤ ~10⁴, integers and
   quarter-integers) are *exactly representable* territory — most steps are
   exact, which should keep the intervals tight and the automation simple.
2. **NaN/Inf hygiene:** Φ's bounds imply finiteness inductively (bounded op
   on bounded finite inputs is finite); state it inside the interval brick.
3. **Where it bites:** `pos[1] += vel[1]/4` (×4), `vel[1] −= 4` +
   terminal-velocity clamp, the launch constant sets, GP `yOffset`, the
   ledge/land comparisons (`+100`, `+160`, `+78` — comparisons of floats
   need only monotonicity, not error analysis). The `sins/coss` table lookups
   feed only *horizontal* velocity under no-A launches (verify in census) —
   if so, the vertical layer never touches trig. **Check early**: if some
   no-A vertical launch is `fwdVel · sins(pitch)`-shaped, the census must
   bound that product (table values ∈ [−1,1] — still easy, but table data
   must be ingested).
4. **Prototype first:** before any capstone work, prove ONE end-to-end lemma:
   "one `apply_gravity` + quarter-step sequence maps `Pot ≤ K` to
   `Pot ≤ K`" against the real walked paqs body. This is the GOAL-2 analogue
   of GOAL 1's M0 toy spine — it de-risks the whole float layer in one slice
   and is the first Coq artifact worth writing.

## 6. Honest hard-problem list (fresh)

1. **find_floor's value contract.** The ladder argument needs "the returned
   height is the height of a real surface in the loaded lists (or −11000)"
   — a *value* walk of `find_floor_from_list`'s `height = -(x·nx + z·nz +
   oo)/ny` computation, i.e. the returned float is bounded by the mesh's
   max plane-height over the cell. This is a new *kind* of contract (value
   provenance from static data), enabled by the just-landed
   `surface_collision` TU (P1). It also needs the **surface-list
   provenance**: loaded surfaces come from the WMotR mesh + the 6 boxes
   (the `SURFACE_FLAG_DYNAMIC` load path already census'd for squish).
2. **Anim y-translation.** Some actions apply animation-driven `pos[1]`
   deltas (`set_mario_anim_...`/`return_mario_anim_y_translation` family).
   Data-dependent (anim binary). Hope: it applies only in grounded/anchored
   states where Φ_ground re-snaps y each frame, or is absent in the airborne
   episode actions. **Must be adjudicated early** — if an airborne action
   applies anim translation, the anim data table enters the trust/ingestion
   surface.
3. **Level-data ingestion.** The gap fact needs the WMotR collision mesh in
   Coq. Route: `clightgen` the level's `collision.inc.c`/`macro.inc.c` data
   arrays as a data-TU (PIPELINE-not-bespoke: the initializers ARE the AST)
   and `vm_compute` the height multiset out of `gvar_init`. Prototype on one
   array. Same route ingests coin positions and box home positions.
4. **The paqs wall/ceiling pushback details** (downwarp family, quarter-frame
   `−2.5` pushes): must show none *raises* y past the envelope (they're
   horizontal or downward; verify each site).
5. **Death/respawn threading.** Falling off WMotR → death warp → re-spawn:
   the induction must survive `level_update`'s warp path (TU already
   generated) — Φ re-established at spawn. Multi-life runs are still one
   induction.
6. **The GOAL-1 dependency is real but partial:** Φ_act reuses the taint
   machinery; the *step-function* walks (paqs/pgqs/pas/pws already walked
   for non-interference) need a second, *value-tracking* pass over the ~30
   y-relevant stores (the census exists). The other ~570 walked stores need
   only "doesn't touch the y cells" — the existing engine's watched-cell
   parameter extended from `{action@12}` to the y-cell set.

## 7. Execution order (and who)

1. **E1 — WMotR inventory** (delegable now): full floor-height multiset
   (static mesh + box models), object list (confirm: no pole/tree/enemy/
   wind/water/hangable-ceiling; cannon barrel position; coin positions;
   spawn + death-warp data). Output: a checked table + a *Python* ladder
   fixpoint sanity-run (is the gap fact true numerically? what is H*?).
   **Gate: if the gap fact fails numerically, everything above is moot —
   run this first.**
2. **E2 — attach-window + launch-constant census re-audit** (delegable):
   §3's table + every no-A `vel[1] := c` with exact constants and the
   discrete apex sums; the sins/coss check of §5.3; the anim-translation
   adjudication of §6.2.
3. **E3 — episode graph** (delegate sweep, Fable adjudicates): §4's edge
   table with dominators.
4. **E4 — float brick prototype** (Fable): §5.4's one-frame Pot lemma
   against the real paqs body.
5. **E5 — find_floor value contract** (Fable design, then delegate): §6.1,
   on the new surface_collision TU.
6. **E6 — leveldata ingestion prototype** (delegate after E1 fixes the
   target arrays).
7. Only after E1–E4 all hold: write the `WMotRRequiresA/` capstone skeleton
   with named residuals (the G2 analogue of NoAFlyingSpine) and start
   wiring. **Do not write capstone Coq before the numeric sanity gate E1
   passes.**
