# Roadmap: where we are, and the path to the WMotR ABC impossibility theorem

> ⚠️ **This doc WILL go stale.** It is a snapshot of intent and status as of **2026-05-29**.
> Commit hashes, "DONE/NEXT" labels, and file lists drift as work lands. When in doubt, trust
> the code (`proofs/*.v`, `git log`) and the focused docs over this overview. Treat this as the
> map, not the territory — re-read the linked docs for anything load-bearing.

## 1. The end goal (one sentence)

Prove, in Rocq over CompCert-Clight, that **Wing Mario Over the Rainbow's star is unobtainable
without ever pressing the A button** — a formal A-Button-Challenge (ABC) impossibility result for
one SM64 star. See [wmotr-argument-shape](../) memory note / `must-press-a-to-fly.md` for the
gameplay argument.

## 2. The argument, top down

```
WMotR star is A-free-impossible
  └─ need all 8 red coins to spawn bhvHiddenRedCoinStar  (level fact)
      └─ need the two high coins (y = 4600) → need wing-cap ALTITUDE
          └─ altitude requires ACT_FLYING (wing-cap flight)        ◄── the limb we are proving
              └─ "you cannot enter ACT_FLYING without pressing A"   = the "must press A to fly" goal
          └─ (ALT routes to altitude, e.g. raw jump height) → the Mario-y ENERGY BOUND  ◄── separate, super-hard, deferred
```

We are building the **"must press A to fly"** limb. The quantitative **y-energy bound** (that no
non-flying moveset reaches y=4600 either) is a separate, much harder limb, deliberately not
started. Both are needed for the full theorem; the flight limb is the tractable beachhead.

## 3. Two layers of the project

**Layer A — generic verified machinery** (reusable, TU-agnostic):

| File | What it gives | Status |
|------|---------------|--------|
| `proofs/Frame.v` | syntactic "does function f directly assign global g?" (`writes_global`) | done |
| `proofs/Reach.v` | whole-TU "formal grep + callgraph": `direct_writers`, `reaches`, `cannot_write_g` | done |
| `proofs/Escape.v` | syntactic address-taken / escape analysis (`addr_taken_anywhere`) | done |
| `proofs/Havoc.v` | semantic separation: distinct globals don't alias (derived, not assumed) | done (regime 1) |
| `proofs/FrameTrace.v` | the temporal trace-invariant HARNESS (`noA_run_not_flying`) | done (abstract) |

**Layer B — facts about real SM64 code** (instantiate Layer A on clightgen'd TUs):

| File | What it proves | Status |
|------|----------------|--------|
| `proofs/ToyFrame.v`, `ToyReach.v` | M0/M2 spine on a toy TU (semantic preservation crux) | done |
| `proofs/ShadowFrame.v`, `ShadowSpec.v` | real `shadow.c`: frame facts + a functional spec (`dim_shadow`) | done |
| `proofs/Flying.v` | the R1/R2 + behavior-layer facts for the flight goal (see §4) | done |

Generated Clight (via `pipeline/clightgen.sh`, byte-reproducible): `toy`, `shadow`, `mario`,
`mario_actions_airborne`, `mario_actions_moving`, `level_update`, `behavior_actions`.

## 4. The "must press A to fly" rungs (R1–R4) — status

Tracked in detail in [must-press-a-to-fly.md](must-press-a-to-fly.md). Summary:

- **R1 — setter enumeration. ✅ DONE** (`Flying.v`). Over the 4 action TUs, the only functions
  that feed a flying constant into a call are exactly 5 sites; the `set_mario_action` group
  helpers never fabricate flying. Also: `no_behavior_is_a_flying_setter` over the whole
  `behavior_actions.c` (113k-line TU) = `[]`. (Found the stale `ACT_FLYING` header value.)
- **R2 — guard classification. ✅ DONE, as a verified NEGATIVE** (`Flying.v`). No flying site is
  locally A-gated (4/5 read no input; the 5th reads input only for B/Z cancels). So the A-gate is
  necessarily *upstream* — which is exactly why R3 is needed.
- **R3 — the temporal closure. 🔨 STARTED, the hard core.** `FrameTrace.v` is the harness
  (`noA_run_not_flying`); see §5. This is the shelve-able research rung.
- **R4 — retire class 3 for WMotR. ✅ ESTABLISHED textually** (no `bhvFlyingWarp` in the level;
  enumerated). Not mechanized — clightgen rejects the level-script object macros.

## 5. R3: the temporal core — plan and what's left

The property "in ACT_FLYING ⟹ a prior A press" is a trace invariant over the per-frame action
loop. Anatomy in [the-frame.md](the-frame.md); the harness is `FrameTrace.v`.

What's done: the abstract harness — give it an invariant Φ that (a) holds at spawn, (b) survives
any no-A frame, (c) excludes flying, and it yields whole-run safety. Φ is **proof-internal** (the
worked trust-model example, [trust-model.md](trust-model.md)).

What's left, in order:
1. **Define `frame_step` over the real action loop** — instantiate `FrameTrace`'s `S`/`step` with
   the clightgen'd `mario.v` `execute_mario_action` (the inner action-shift `while` loop,
   fuel-bounded). **This is where model-faithfulness review lives** (the audited artifact).
2. **Define Φ** — "action ∉ flying-reachable set"; per R2 it must also track the jump-sequence
   actions (JUMP→DOUBLE→TRIPLE). This is the runtime-transition analogue of `Reach` and the bulk
   of the work.
3. **Discharge the 3 obligations** using R1 (bounds the case split), R2 (gate is upstream), R4
   (WMotR base case).
4. **Resolve the function-pointer hop** `common_landing_cancels(m, …, set_triple_jump_action)`
   (leak #2 on the path; target set is static/enumerable).

## 6. The known leaks / trusted edges (the honest "not done" list)

These are the soundness gaps we track explicitly (see [trust-model.md](trust-model.md),
[pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md),
[whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md)):

1. **Leak #1 — indirect/pointer & array writes.** Syntactic `writes_global` sees only direct
   `Sassign` to a named global. Discharge path: escape analysis (`Escape.v`) + havoc separation
   (`Havoc.v`); done for separable shadow globals, open for aliased Mario/object state (regime 2).
2. **Leak #2 — function pointers / indirect dispatch.** Static callgraph drops indirect calls.
   Concentrated in the behavior/level interpreters (the "dragon"); one instance sits on the flight
   path (`set_triple_jump_action` via `common_landing_cancels`). Plan: enumerate the static target
   set (CALL_NATIVE tables) + an interpreter frame meta-theorem.
3. **Leak #3 — closed-world / multi-TU.** No CompCert `Linking` step yet; each TU analyzed alone.
   "Sole writer in this TU" ≠ "sole writer in the program." `no_behavior_is_a_flying_setter`
   narrows but doesn't close this (no flying *constant* in behaviors, but cross-TU calls to
   `set_mario_action` aren't linked).
4. **TCB (irreducible):** Coq kernel; CompCert's Clight semantics; **clightgen**; and the
   **C-vs-ROM** seam (decomp matches under IDO; we reason under CompCert + `NON_MATCHING`/`AVOID_UB`).
5. **The interpreter/scheduler abstraction** (frame model): trusts "the engine calls
   `execute_mario_action` once/frame and otherwise doesn't touch `m->action`" until discharged.

## 7. How we stay honest at scale (don't lose this)

- Audit the **statement**, not the proof body (de Bruijn). Analyses are **verified, not trusted**:
  a weak analysis = a failed proof, not a false theorem.
- `Print Assumptions <thm>` = "Closed under the global context" on every result (CI gate intent).
- The eventual top theorem goes in an **import-restricted** spec file so analysis names
  (`reaches`, Φ, …) physically cannot leak into the statement.
- A **non-vacuity witness** ships alongside (flying IS reachable WITH A) so we can't prove an
  empty precondition. Full rationale: [trust-model.md](trust-model.md).

## 8. Milestones beyond the flight limb (rough, unstarted)

- **Interpreter frame meta-theorem** (tames the behavior/level engines as a whole; unlocks
  red-coins→star and "must press Start").
- **CompCert `Linking`** of the reachable TUs → genuine whole-program statements (closes leak #3).
- **The Mario-y energy bound** — the quantitative, super-hard limb; needs float reasoning and a
  conservative abstract interpreter over the physics. Deferred indefinitely.
- **Top-level theorem** assembling: (flight ⇒ need A) + (no flight ⇒ y-bound ⇒ can't reach high
  coins) ⇒ star unobtainable A-free.

## 9. Doc index (focused docs this overview compresses)

- [must-press-a-to-fly.md](must-press-a-to-fly.md) — the flight goal, entry-point table, R1–R4.
- [the-frame.md](the-frame.md) — what one in-game frame is; loop taxonomy; R3 plan.
- [trust-model.md](trust-model.md) — why we believe the eventual statement; Φ-internal vs the model.
- [pointer-writes-and-block-disjointness.md](pointer-writes-and-block-disjointness.md) — leak #1.
- [whole-program-and-the-interpreters.md](whole-program-and-the-interpreters.md) — stubbing,
  the dragon, leak #2/#3.
- [object-set-and-glitches.md](object-set-and-glitches.md) — Spiny Adoption; bound behaviors +
  perturbation, not pristine state.
- [open-vs-closed-world.md](open-vs-closed-world.md), [two-axes-syntactic-vs-semantic.md](two-axes-syntactic-vs-semantic.md) — framing of soundness/closed-world.
- [M0-proof-explained.md](M0-proof-explained.md) — the toy spine, for onboarding.
