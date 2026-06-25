# GOAL 2 deep-dive — can we prove "Mario is never in ACT_JUMP under no-A"?

**Status:** exploration, 2026-06-24. Companion to [goal2-y-value-census.md](goal2-y-value-census.md).
Reads real source (`vendor/sm64/src/game/*.c`) + a map of the GOAL-1 taint engine
(`Taint.v` / `AGates.v` / `ActionValueFrame.v` / `EngineV2Consumer.v`). **No Coq
written.** Verdict marks: **[VERIFIED]** read in source; **[LIKELY]** strongly
indicated but not exhaustively checked.

There is no `ACT_SINGLE_JUMP` in SM64 — the plain single jump **is** `ACT_JUMP`
(`0x03000880`, `sm64.h:256`). The question is whether `gMarioState->action` can
ever equal `ACT_JUMP` over a no-A run.

## TL;DR

1. **"Never ACT_JUMP under no-A" is FALSE.  [VERIFIED]** `ACT_JUMP` is the engine's
   universal *downgrade sink*: `set_mario_action_airborne` rewrites a requested
   `ACT_DOUBLE_JUMP` **or `ACT_TWIRLING`** to `ACT_JUMP` whenever Mario is squished
   or in quicksand (`mario.c:779-782`). And `ACT_TWIRLING` has **non-A, object-driven
   producers** (`interaction.c:1352/1390`, twirl-bounce). So a twirl-bounce while
   squished/in-quicksand lands Mario in `ACT_JUMP` with no A press.
2. **The right invariant shape is "entry-closed under A-gating."** The taint technique
   that proves "never flying" needs *every* write of the target to the action field
   to be dominated by an `INPUT_A_PRESSED` check. Flying satisfies this; `ACT_JUMP`
   does **not** (the squish remap is a non-A writer). This is a clean, general
   criterion for "which actions can we prove unreachable."
3. **The *higher* jumps ARE provable** ("never ACT_DOUBLE_JUMP / ACT_TRIPLE_JUMP /
   ACT_BACKFLIP / …") — they are entry-closed under A-gating; the squish remap only
   *consumes* them. Reuses GOAL-1's engine + a small new A-gate census.
4. **But none of these "never-jump" proofs are needed for GOAL 2's height bound** —
   every jump's yVel is a *bounded constant* (≤84, and squish halves it), so each
   gives a bounded apex. The only action that needs a "never X" proof is the unique
   *unbounded* climber, **flying — already done by GOAL 1.** The remaining non-A
   climbers (tornado/tweester lift) are object-driven and bounded by level geometry,
   which no "never X" proof can establish.

So: the exercise is illuminating, the technique is real and reusable, but `ACT_JUMP`
is the one jump you *can't* (and needn't) exclude.

## 1. Why ACT_JUMP specifically is unprovable — the witness path  [VERIFIED]

`set_mario_action_airborne` (`mario.c:776`) opens with a remap:

```c
if ((m->squishTimer != 0 || m->quicksandDepth >= 1.0f)
    && (action == ACT_DOUBLE_JUMP || action == ACT_TWIRLING)) {
    action = ACT_JUMP;                       // mario.c:779-782
}
```

`set_mario_action` (`mario.c:979`) routes every AIRBORNE-group request through this
function before writing `m->action = action` (`:1007`). So `ACT_JUMP` is *written*
whenever someone requests `ACT_DOUBLE_JUMP` or `ACT_TWIRLING` while squished or in
quicksand. The two source actions:

- **`ACT_DOUBLE_JUMP`** — A-gated (only producer is `set_jump_from_landing`, whose 3
  callers are all behind `INPUT_A_PRESSED`: `moving.c:791`, `moving.c:1081`,
  `stationary.c:848`). So the remap *from* double-jump is still A-gated. Not a problem.
- **`ACT_TWIRLING`** — **NOT A-gated.** Producers:
  - `interaction.c:1352` and `interaction.c:1390` — `drop_and_set_mario_action(m,
    ACT_TWIRLING, 0)`, fired when Mario bounces on an object from above whose
    `oInteractionSubtype & INT_SUBTYPE_TWIRL_BOUNCE` is set. Pure object interaction;
    **no A.**  [VERIFIED — read the handler bodies]
  - `automatic.c:788` — tornado/tweester lift (`set_mario_action(m, ACT_TWIRLING, 1)`).
    Object-driven; **no A.**

⇒ **Witness:** Mario, squished (`squishTimer != 0`) or sinking in quicksand
(`quicksandDepth >= 1.0`), bounces from above onto a twirl-bounce object →
`set_mario_action(ACT_TWIRLING)` → squish remap → `m->action = ACT_JUMP`, with the A
button never pressed. (`set_mario_y_vel_based_on_fspeed` then *halves* the launch
yVel because squished/quicksand — `mario.c:768-770` — so the resulting jump is yVel
≤ 21. Bounded; see §4.)

**Reachability caveat.** This is "false" iff the two predicates can co-occur — a
twirl-bounce object hittable while squished or in quicksand. Quicksand levels (SSL,
HMC) and crushing hazards are both real; co-occurrence is plausible but I have not
pinned a specific in-game spot. Even if that exact co-occurrence were somehow
unreachable, **the proof obligation does not go away**: a clean "never ACT_JUMP"
proof would have to *discharge* this path, i.e. prove "never (twirl-requested while
squished/quicksand)", which is itself a hard reachability/geometry fact — not the
cheap control-flow A-gate the flying proof enjoys. So `ACT_JUMP` is at best far
harder, at worst false. Either way it's the wrong target.

## 2. The general criterion: "entry-closed under A-gating"

GOAL 1's "never flying" is a **taint-closure** invariant (`Taint.v`): a small set
`T` of action ids, proved to satisfy `action ∉ T` for every no-A reachable state,
because **every write of a `T`-value to the action field is dominated by an
`INPUT_A_PRESSED` check** (so under no-A the writes are dead), and `T` is closed
(no `T`-member is produced un-gated from outside `T`). Call this property
**entry-closed under A-gating.**

The decision procedure for "can we prove `never X`?" is therefore:

> Enumerate every writer of `X` to `m->action` (raw `Sassign`, and every
> `set_mario_action(m, X, …)` *after* the group-remap in `set_mario_action_{airborne,
> moving,submerged,cutscene}`). If **all** are A-gated → provable by the taint
> engine. If **any** is reachable under no-A → `never X` is false.

| target | entry-closed under A-gating? | provable "never X" under no-A? |
|---|---|---|
| **ACT_FLYING** | yes (GOAL-1 `Taint.v`) — DONE | ✅ proved |
| **ACT_FLYING_TRIPLE_JUMP** | yes (in `T`) — DONE | ✅ proved (gateway to flying) |
| **ACT_SHOT_FROM_CANNON** | yes (in `T`) — DONE | ✅ proved |
| **ACT_JUMP** | **NO** — squish remap from object-driven ACT_TWIRLING | ❌ **false** (§1) |
| ACT_DOUBLE_JUMP | [LIKELY] yes — only `set_jump_from_landing` (A-gated); squish only *consumes* it | ✅ likely provable |
| ACT_TRIPLE_JUMP | [LIKELY] yes — `set_jump_from_landing` + `set_triple_jump_action` (both A-gated) | ✅ likely provable |
| ACT_BACKFLIP | [LIKELY] yes — `set_jumping_action` under `INPUT_A_PRESSED` (`stationary.c:534/703/728`) | ✅ likely provable |
| ACT_SIDE_FLIP / WALL_KICK_AIR / LONG_JUMP / STEEP_JUMP | [LIKELY] yes (per §3b of the census doc) | ✅ likely provable |
| **ACT_TWIRLING** | NO — object-driven (`interaction.c:1352/1390`, `automatic.c:788`) | ❌ false |
| **ACT_LAVA_BOOST / ACT_BURNING_JUMP** | NO — hazard contact (`interaction.c`) | ❌ false |

The pattern: **the bottom of the jump tree (`ACT_JUMP`) and the object/hazard-driven
actions are *not* exclusive to A; the A-gated jumps are exactly the ones you reach
"on purpose."** `ACT_JUMP` sits at the bottom because the engine deliberately funnels
degenerate cases into it (squish, quicksand) — it is the safe sink, by design.

This squares with the engine map: in the GOAL-1 proof, `ACT_JUMP` (`50333824`) is
relied on as a **non-tainted downgrade output** — e.g. `set_mario_action_airborne_result`
(ActionValue.v) proves the airborne setter never fabricates a flying action *because*
its squish remap lands on `ACT_JUMP`, a non-flying constant. Making `ACT_JUMP`
tainted would break that load-bearing non-fabrication lemma. The proof architecture
already "knows" `ACT_JUMP` is the sink.

## 3. What it would take to prove a "never X" for a provable jump (e.g. DOUBLE_JUMP)

From the engine map, the harness splits cleanly:

**Reusable as-is (the hard 90%):**
- The generic engine `ActionValueFrame.v` — parametric in a carried value-predicate
  `Q : int -> Prop` (`action_sat Q m bm := ∀v, load action = Vint v → Q v`); the
  funcall induction `exec_funcall_reach_value_v2`; the call-resolution closure,
  censused-body dispatch, writer-refutation — all `Q`-generic.
- The three A-gate branch-selection theorems in `AGates.v`
  (`input_a_gate_takes_else_lp`, `ctl_a_gate_takes_else_lp`,
  `ctl_a_gate_eq_takes_else_lp`) and the `ctl_a_clear` no-A input model — these
  mention no action value at all. Zero changes.
- The capstone scaffolding (`NoAImpliesNoFlyLinked.v` MWF grounding, reachability
  induction) — re-instantiable at a new `Q`.
- The action-field writer enumeration machinery (`*_action_writers` reflexivity
  walkers) — re-runnable.

**New / changed (the targeted 10%):**
- Define the new target set `T'` (or a standalone `is_double_jump`) and its
  `is_T_label` analogue — currently three hardcoded literals (`AGates.v:644`).
- **Re-run the reflexivity censuses** (`Taint.v` `tainted_edges`,
  `tainted_action_writers`, `ungated_tainted_feeders`; `AGates.v` dispatch census)
  at `T'` — they return different sites, exposing the DOUBLE_JUMP entries, each of
  which must hit an A-gate.
- **Re-prove the value-tracking lemma** `set_mario_action_airborne_result` at the new
  predicate. For DOUBLE_JUMP this is fine (the setter never *fabricates* a double
  jump — it only consumes it via the squish remap). For `ACT_JUMP` this step is where
  the proof **fails**, because the setter *does* fabricate `ACT_JUMP`.

So a single "never DOUBLE_JUMP" is a few hundred lines of mostly-mechanical census
re-running over a fully reusable engine — cheap *relative to* the GOAL-1 build, but
not free, and it buys nothing the bound needs (§4).

## 4. The punchline for GOAL 2 — "never jump" is not load-bearing

The height bound (census doc §2a) needs to dominate the **climb**, and the climb is
governed by the launch yVel, not by which action label Mario wears. Reading the full
yVel-setter switch (`set_mario_action_airborne`, `mario.c:784-885`) confirms **every
jump yVel is a bounded constant** (plus `forwardVel·mult`, `mult ≤ 0.25`, `forwardVel`
itself capped, e.g. 48):

```
DOUBLE 52  BACKFLIP 62  TRIPLE 69  FLYING_TRIPLE 82  WATER 42  BURNING 31.5
SHELL 42  JUMP/HOLD_JUMP 42  WALLKICK/POLEJUMP 62  SIDEFLIP 62  STEEP 42
LAVA_BOOST 84  LONG 30  SLIDE_KICK 12  JUMP_KICK 20      (squish/quicksand ⇒ ×0.5)
```

Max ≈ 84 (lava). By the §2a apex bound `≈ V²/8`, the largest single-launch rise is
~880 units above the launch floor — **a constant.** So:

- The **only** action whose climb is *unbounded* (yVel re-generated every frame from
  forwardVel, `vel[1] = forwardVel·sin(pitch)`, `airborne.c:364`) is **ACT_FLYING**.
  That is exactly the one GOAL 1 excludes by a "never X" proof. **Flying is the
  unique action for which "never X" is both necessary and true.**
- Every other positive-yVel action — including all jumps and the non-A hazard/bounce
  impulses — contributes a **bounded** apex. They need *bounding*, not *exclusion*.
  A "never ACT_DOUBLE_JUMP" proof would remove one bounded contributor; it does not
  change that the bound is a max-over-constants.
- The remaining non-A *sustained* lift is the **tornado/tweester** (`automatic.c:732`
  `vel[1]=100·sin`, `:778 +=1`, `:786 =20`; the same `ACT_TWIRLING`/`ACT_TORNADO_TWIRLING`
  family). It is object-driven, so **no "never X" proof applies** (you can't gate it
  on A). It is bounded only by the tweester's own vertical range = **level/behavior
  data** = the cat-5 geometry residual. (WMotR likely has no tweester, which would
  void it *in that level* — but that's a per-level fact.)

**Conclusion.** The clean lever for GOAL 2 is **not** "prove Mario can't jump." It is:
(a) reuse GOAL 1's flying exclusion (the only unbounded climber — done); (b) prove the
*bounded-impulse* classification — every non-flying yVel setter writes a value ≤ C and
is not regenerated — which is a finite census of the `set_mario_action_airborne` switch
+ the forwardVel caps, **no action-exclusion needed**; (c) the §2a integration
arithmetic; (d) the per-level floor/tornado geometry (the honest hard part).

## 5. Recommendation

- **Do not pursue "never ACT_JUMP."** It is false (§1) and unnecessary (§4), and it
  fights the proof architecture (ACT_JUMP is the deliberate non-tainted sink).
- **"Never X" is the right tool only for unbounded climbers that are entry-closed
  under A-gating.** In SM64 that set is `{flying, flying-triple-jump, cannon}` = the
  existing `T`. There is no *other* action that is both unbounded and A-exclusive, so
  GOAL 1 already captured all the mileage this technique offers.
- **The reusable asset** is real: `ActionValueFrame.v` is `Q`-generic, so if a future
  need arises to exclude some specific entry-closed action, the engine carries over;
  only the censuses + the one value-tracking lemma are per-target. Worth remembering,
  not worth spending now.
- **Spend GOAL-2 effort on the bound, not the labels:** the bounded-impulse census
  (§4b) and the §2a integration lemma are the high-leverage, control-flow-only next
  steps; level geometry is the deferred hard residual.

See [[goal2-y-census]], [[taint-invariant-grounded]], [[flying-action-entries]].
