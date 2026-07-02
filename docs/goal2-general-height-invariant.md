# GOAL 2 — the general height bound: a one-frame inductive invariant, not a catalogue of tricks

> **SUPERSEDED (2026-07-01) by `goal2-strategy-v2-2026-07-01.md`.** The
> one-frame-induction skeleton and the y-target survive, but this doc's
> scalar `C_pos` invariant and its "grounded ⇒ reachable-floor-max" dominator
> row are circular, its apex-based envelope misses the attach windows
> (landing snap +78 / ledge grab +238), and it never addresses f32
> arithmetic. See v2 §0 for the autopsy. Kept for history.

*Exploratory strategy note (no Coq yet). This is the methodological backbone that
makes GOAL 2 a theorem instead of an endless "what about mechanism Z" hunt. It
supersedes the per-mechanism framing of the squish-cancel dig (`§5` of
`goal2-wmotr-y-changer-census.md`), which is now just **one discharged row** of the
scheme below.*

## 0. The problem with per-mechanism disproofs

We killed the squish-cancel ground-pound chain by reading its exact precondition and
showing it's unreachable. Good — but that method **does not terminate**: there is
always another candidate (dive-rollout chaining, some other cancel, an
object-launch we under-counted). Enumerating *tricks* is whack-a-mole. The fix is to
stop reasoning about chains and reason about **one frame**.

## 1. The principle: the chain *is* the induction

A run is a sequence of frames `m0 → m1 → … → mk`, each one application of the real
clightgen'd step (`execute_mario_action` + the surrounding loop). Find a predicate
`Φ(mem)` with:

1. **Init:** `Φ(m0)` at the WMotR spawn.
2. **Preservation:** `∀ m m'. Φ(m) ∧ noA ∧ step(m, m') ⟹ Φ(m')` — *for every frame,
   every action handler, every branch.*
3. **Strength:** `Φ(m) ⟹ pos[1] < y_coin` (the lowest "high" red coin, `y = 3140`).

Then `Φ` holds at **every reachable state** by induction on the frame count — for
*any* sequence of actions, named trick or not. The "mechanisms" are no longer
theorems to defeat one at a time; they are **branches inside the single preservation
proof**. A trick we never named is handled the moment its handler/branch is walked.

This is exactly the **GOAL-1 architecture**: GOAL 1 carries `action ∉ T` and proves
the real frame preserves it via a census engine that walks every handler body
(`Taint.v` / `AGates.v` / `EngineV2Consumer.v` / the `*LeafSurface.v` walks). GOAL 2
is **the same engine carrying a stronger `Φ`.**

## 2. `Φ` is a coupled conjunction (why no single conjunct is inductive)

`pos[1] ≤ C` alone is *not* inductive — one frame integrates velocity, sets vel to a
constant, etc. Strengthen until the *conjunction* survives even though no conjunct
does alone (standard induction-hypothesis strengthening):

```
Φ(m) ≜  action ∉ T          -- GOAL-1 taint (flying/cannon/FTJ); reuse VERBATIM
      ∧ pos[1]      ≤ C_pos  -- the target quantity
      ∧ vel[1]      ≤ C_vel  -- because pos integrates vel (§2a integration lemma)
      ∧ forwardVel  ≤ C_fwd  -- because dive entry needs fwdVel ≥ 29; speed feeds launches
      ∧ squishTimer == 0     -- because squish unlocks mid-air relaunch (the §5 dig)
      ∧ LEVELDATA(WMotR)     -- no water / no Bully / no tweester / no dynamic ≤150 squish-spot / …
```

**Mutually load-bearing** (this is the whole point):
- `pos[1] ≤ C_pos` needs `vel[1] ≤ C_vel` (no big launch) **and** `squishTimer == 0`
  (no relaunch) **and** `action ∉ T` (flying is unbounded).
- `squishTimer == 0` needs `pos[1] ≤ C_pos` (no `>1150` *survivable* fall) **and**
  `LEVELDATA` (no reachable dynamic `≤150` squish-spot).
- `vel[1] ≤ C_vel` needs every vel-setter to be grounded/A-gated/absent (next section).

That circular support is the coupled induction; you prove the package preserved as a
whole. (The squish dig already found one instance: `squishTimer==0` and `pos[1]` bound
hold each other up — fall-damage squish needs a fall the height bound forbids.)

## 3. The reduction that makes preservation FINITE — launch-site dominator classification

Every per-frame height *increase* enters through a **finite, enumerable set of write
sites** — the `m->vel[1]` writes (census §1) and the `m->pos[1]` writes (census §4).
SM64 is *one* program: there is no "∀ mechanisms," only a finite list of writers
(this is the proof-discipline "no phantom ∀ — enumerate the real finite set" rule).
For each writer, classify the **dominator** — what must hold to reach it:

| dominator of the height-gaining write | verdict | discharge |
|---|---|---|
| **grounded** (entered from a floor: `AIR_STEP_LANDED`, stationary/moving handlers) | OK | launch height = floorHeight ≤ reachable-floor-max (level data) |
| **`INPUT_A_PRESSED`** | dead | GOAL-1 one-writer `input_grounds_noA` (verbatim) |
| **absent object/surface** | dead | `LEVELDATA(WMotR)` constant (the new pipeline step) |
| **mid-air re-entry, no A, no object** | ⚠ DANGER | must be enumerated and killed — *this is the real work* |

The danger class is precisely **"convert a mid-air position into a new launch without
landing on a real floor."** Squish-cancel is *one* member (idle mid-air →
dive/jump/ledge-grab); we killed it by removing its precondition (no reachable
dynamic `≤150` squish-spot). The framework's job is to prove the danger class is
**empty** under `Φ`: enumerate every action transition that sets `vel[1] > 0` or does
an unconditional `pos[1] +=`, and show each is dominated by *grounded ∨ A ∨ absent*.
If one isn't, the per-handler walk **won't close** — the proof self-polices, so we
cannot "miss" a trick the way a prose census can.

Your two example generalisations land exactly here:
- *dive-rollout instead of ground-pound* → both are entries in the **same finite
  launch census**; the `vel[1] ≤ C_vel` conjunct + the §2a integration lemma bound
  **all** of them at once. No per-action ad-hoc bound.
- *some other action causing the cancel* → it would be another member of the danger
  class; the enumeration is what surfaces it. We are not trusting "squish is the only
  one" — we are obligated to walk every launch entry.

## 4. The numeric core (§2a, made concrete)

The height-relevant projection of the state is `(pos[1], vel[1], action, squishTimer,
grounded?)`. Per frame:
- **Ballistic:** `vel[1] -= 4` (gravity, terminal −75), `pos[1] += vel[1]/4` ×4
  quarter-steps, clamped by floor/ceiling. Apex `= pos[1] + max(0,vel[1])²/8`.
- **Velocity-set:** actions assign `vel[1]` to a *constant from a finite list*
  (census §1). Under no-A/no-object the max positive is the dive's `20` (rollout `30`,
  jump-kick `20`, bounces `≤20`) — all `≤ C_vel`.
- **Unconditional `pos +=`:** only the ground-pound windup (`airborne.c:928`,
  `≤110` total, ceiling-gated) and the anim-translation `ε`. Everything else is a
  PIN (to floor/ceil/object) or absent.

A convenient single scalar is the **ballistic ceiling** `B(m) = pos[1] +
max(0,vel[1])²/8`. It is ~invariant across a ballistic frame (energy, modulo the −4
discretisation) and, across a velocity-set from a grounded state at floor `f`, becomes
`f + c²/8 ≤ f_max + C_vel²/8`. The **ratchet question is exactly "can `B` increase
across a frame"** — and it can only do so via (a) a larger vel-set (bounded constant),
(b) the GP windup (`+110`, ceiling-gated and self-terminating), or (c) a mid-air
relaunch from altitude (the §3 danger class). Bounding all three = bounding `B` =
the height bound.

## 5. Execution in the pipeline (what's reuse, what's new)

**Reuse from GOAL 1 (large):**
- `input_grounds_noA` / the taint set `T` / the A-gate branch lemmas — verbatim.
- The per-handler **body walkers** and the census coverage machinery
  (`*LeafSurface.v`, `DispatchKit.v`, the engine) — re-run carrying the bigger `Φ`.
- The frame/induction skeleton (`NoAImpliesNoFlyLinked.v`'s shape).

**New work:**
1. **Strengthen the carried invariant** from `not_tainted` to the §2 conjunction; add
   the numeric conjuncts to the engine's per-store/per-call obligations.
2. **The §2a integration lemma** over the already-walked `perform_air_step` /
   `perform_air_quarter_step` (apex from `vel[1]`; bounded climb). The air-step walks
   already exist (`paqs`, `pgqs`).
3. **Level-data ingestion (the genuinely new pipeline step):** `clightgen` / parse
   the WMotR collision + macro AST into Coq constants — reachable floor heights, the
   8 red-coin positions, the 6 box positions + box collision span `y∈[oPosY+30,+52]`,
   the surface-type table — to discharge `LEVELDATA(WMotR)` (no water, no Bully, no
   dynamic `≤150` squish-spot, no tweester) and the reachable-floor-max.
4. **The danger-class enumeration** (§3): the per-launch-entry dominator proofs. The
   squish-cancel row is the template; the rest are grounded/A/absent and should be
   mechanical given the walks.

## 6. Honest scope & the crux

- **Sound by construction:** if `Φ` is genuinely preserved by the *real* frame and
  implies the bound, the general result follows — *no* mechanism enumeration needed.
  The danger of la-la-land is choosing a `Φ` that *isn't* inductive and "proving"
  preservation by skipping a branch; GOAL-1's exhaustive census + `check_unwired`
  firewall is what prevents that (every handler must be covered to close).
- **The crux is `Φ`'s exact constants + the danger-class emptiness**, not the
  skeleton. Getting `C_pos/C_vel/C_fwd` right is a fixpoint: pick them, run
  preservation, tighten where a branch breaks it.
- **Still genuinely open** (carried from §5): the no-squish **grounding invariant**
  over the *full* air-transition graph (only GP + dive kit checked by hand so far) —
  that is precisely the §3 danger-class enumeration, not yet done; and the level-data
  ingestion is unbuilt.

See [[goal2-y-census]], `goal2-wmotr-y-changer-census.md` (the launch-site census
this scheme consumes), `goal2-wmotr-leveldata.md` (the `LEVELDATA` source).
