# GOAL-1 state of the union — 2026-07-09

A refresh of `director-roadmap-2026-07-01.md`, which predates essentially
all of the last week's work. Written for the director: what is proved, what
is honestly assumed, and what remains.

## The theorem, and its two forms

**GOAL 1** — under never-A, no-spawn-flying inputs, Mario never reaches a
flying action — now stands in **two** audited forms:

- `noA_no_spawn_never_flying_real_mwf` (`NoAImpliesNoFlyLinked.v`) — the
  MWF-grounded capstone over an abstract link `lp`.
- `noA_no_spawn_never_flying_linked12` (`NoAImpliesNoFlyTwelve.v`) — the
  **sharpest** form: *any* CompCert link of THE twelve mechanically
  clightgen'd SM64 translation units. Its link premise is no longer
  assumed abstractly — see below.

Plus the standalone structural theorem that makes the second form
non-vacuous:

- `linked12_inhabited` (`Linked12Sat.v`) — **the twelve TUs provably
  link.** A closed theorem, no hypotheses.

All six capstone targets (the four lineage capstones + `linked12` +
`linked12_inhabited`) pass the discipline audit: compile, no
admit/axiom/sorry, **standard CompCert axioms only**, firewall clean.

## What got proved since 07-01 (the week's landslide)

**Four intended-model vacuities found and repaired.** Each was a row that
was true-in-isolation but false of the real semantics — the exact failure
class the discipline skill exists to catch:
- `vec3f_find_ceil` was Internal in mario.prog yet on the "stays external"
  whitelist → the negative pin was refutable, the capstone vacuous. Walked
  as a proved rest case (#95).
- The two bully rows aliased `BullyCollisionData.posZ` with
  `MarioState.action` at struct offset 12 → gated (#97).
- `play_sound_if_no_flag` ORed an adversary-controlled value into
  `m->flags`, live on *both* the stationary and moving external rows →
  the whole sound cluster marg-gated (#98).
- `Hret_unsafe` demanded every reached function's pointer return avoid
  `bm`, but the reached vec3 helpers (`(tptr tvoid)` externals) return
  their Mario-interior destination `= Vptr bm` → the row was
  unsatisfiable, the same false-`forall ef` shape as the deleted
  `Hret_ext`. Turned out to be **dead plumbing** (the census forces
  call-result temps untabled, so the taint tracker never consumed the
  return fact) → deleted outright, −35 lines, zero residuals (#99).
Two standing rules, now load-bearing: **(1) audit-by-comment is worthless;
only per-store classification against the generated AST is sound** (every
"pure external, writes no Mario state" comment checked, 3/3, was false);
**(2) every row over an abstract `external_call` or a `forall`-quantified
reachable set is a vacuity suspect until its satisfiability is checked
against a concrete witness.** Four vacuities, all found by asking one
question of an assumed row: *is this actually satisfiable in the intended
model?* Green-and-audited never meant non-vacuous.

**P3 complete — the link is real and inhabited.** `linked12_inhabited`
closes the last structural question: the capstone quantifies over a
provably nonempty class. Getting there forced three deterministic pipeline
normalizations, each *discovered by running the certificate and reading
the counterexample* — stringlit renaming, anonymous-composite
canonicalization (`_317`@mario ≡ `_381`@cutscene = the same `OSContStatus`),
and one extern-incomplete-array completion. All 16 TUs regenerated; the
whole proof tree recompiled green underneath them, unchanged.

**P5 complete — bucket B is discharged or named.** The runtime-layout
assumptions collapsed:
- `bm` is the `gMarioStates` symbol block (a link-scope fact the old
  runtime-block model missed) → distinctness is `genv_vars_inj`.
- The 8 `SafeB` rows consolidated to **one** honest boundary
  (`HSafeB_sym_iff`), with a zero-axiom satisfiability certificate proving
  it a real refinement.
- `Hglob_valid`, `Hbc_bm`, `Hbc_sym`, `Hspawn`'s `init_mem` residual — all
  discharged (the last via `linked12_init_mem`, a second certificate-shaped
  theorem).
- The **dynamics are confirmed complete**: R6/R7 (SafeB contains Mario's
  chased objects; SafeB is load-closed) are carried-and-preserved MWF
  clauses, and `frame_preserves_mem_ok_lp` is proved — so no
  "no-new-allocation" lemma is needed.

**All class-B walk debt cleared** (#96): the mislabeled-external Internal
bodies are walked or (bully/sound/spawn-star) correctly gated/documented.

## What remains assumed — the honest boundary

After all the above, GOAL-1's entire trust surface is:

1. **The `mem_ok_lp` antecedent** — "the run starts in a well-formed WMotR
   spawn state." This is the theorem's *conditional*, not a hole.
   Discharging it would mean modeling the boot/level-load/object-spawn
   sequence outside the twelve action TUs — the deepest un-tethering
   (inventing the initial state). The honest form is the conditional we
   have.
2. **Three symbol pins** (`bm`/`bc`/`oc0` are the `gMarioStates`/
   `gControllers` blocks at offset 0) — the caller's run-block layout
   choice. Optionally tightenable by existentially binding `bm`/`bc`.
3. **The external-object-system boundary** (`HSafeB_sym_iff`,
   `Hglob_obj_root`) — the object pool is genuinely external to the twelve
   TUs (`spawn_object` is `EF_external`). Co-equal with the accepted
   `spawn_object` external rows.
4. **CompCert's external-call model** for the named audio / dialog / save /
   `spawn_object` / math boundary — the permanent, labeled edge.

## What's actually left to *do* (all off the honest boundary)

- **P1'** — grow the faithful link to fourteen TUs (add math_util +
  surface_collision, walking their bodies), retiring ~9 exempt-callee rows
  the 12-TU pin currently covers only because those TUs aren't linked. The
  canonicalizer already handles both new TUs. **The main remaining
  structural front.**
- **Optional** — the `bm`/`bc` existential tightening (#2 above);
  `Hglob_obj_root` full concretization (only via the rejected 230-site
  engine change or a cutscene re-walk — not worth it for a boundary row).

(#50/`Hret_unsafe` is **done** — it was a dead-plumbing vacuity, deleted in
#99, not a residual to discharge.)

## Bottom line

GOAL-1's structural spine is finished: the program links (proved), the link
is inhabited and its init memory exists (proved), the frame preserves the
full invariant including object-reachability (proved), and every vacuity
and mislabeled-external has been found and repaired. What the theorem asks
you to believe is now exactly three things: the program is the twelve
clightgen'd TUs, the run starts at a well-formed spawn, and CompCert's
external model holds at the labeled boundary. #50 and P1' shrink the
engine/exempt surface further but change none of that shape.
