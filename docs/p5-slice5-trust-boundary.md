# P5 slice 5 — where the trust honestly bottoms out (Fable, 2026-07-09)

This is a director's analysis, not a walk. After slices 0–4 shrank the
bucket-B assumed surface, slice 5's question is: **what genuinely remains
assumed, and is any of it a phantom hiding as a boundary?** The answer
reframes the whole bucket, and it is good news.

## The two kinds of "assumption" — don't conflate them

The GOAL-1 capstone has two distinct trust surfaces, and P5 has been
conflating them under "bucket B":

1. **Section hypotheses** — ambient facts about the *fixed* objects
   `lp, bm, bc, SafeB` that the frame engine consumes to prove
   preservation. These are the "assumed rows" we have been shrinking
   (`HSafeB_sym_iff`, `Hspawn`, `Hbc_bm`, …). They are about the
   *program and its layout*, not about any particular run.

2. **`mem_ok_lp init`** — the *per-run precondition* the caller supplies:
   `mem_ok_lp m := valid_block m bm ∧ action_sat not_tainted m bm ∧
   MWF_real m` (`NoAImpliesNoFlyLinked.v:92`). This is not an "assumed
   row"; it is the antecedent of the theorem. The capstone reads: *for any
   `init` satisfying `mem_ok_lp`, any no-A / no-spawn run stays non-flying.*

## The load-bearing discovery (verified 2026-07-09)

`frame_preserves_mem_ok_lp` (`NoAImpliesNoFlyLinked.v:185`) is a **proved
`Lemma`** (Qed, via the re-rooted value engine), and **R6/R7 live inside
`MWF_real`** as carried invariant clauses (`MWFReal.v:251–262`):

- **R6**: every tabled chase-root cell (`marioObj`, `usedObj`,
  `interactObj`, …, `chase_root_fields`) holds a `SafeB` pointer.
- **R7**: `SafeB` is closed under pointer-load.

Because preservation of the *whole* `MWF_real` — R6 and R7 included — is
already discharged, **the dynamics are done**: no separate "the no-A loop
allocates no new Mario-reachable block" lemma is needed. If a frame stores
a freshly-spawned object pointer into `marioObj`, R6-preservation already
forces that pointer to be `SafeB`, and that obligation is met by the
engine's existing `spawn_object`-family `SafeB`-return rows
(`Hchase_safe` / `Hstore_safe` / `Hcp_spawn_real`). The load-bearing
consequence: **slice 5 is not a dynamics proof.** The `SafeB` inhabitation
worry from the design memo was about the initial state only.

## So what actually remains, and its honest classification

After slices 0–4 (and the `Hbc_bm`/`Hbc_sym` discharge now in flight), the
surviving bucket-B section hypotheses are exactly:

| Row | Status | Class |
|---|---|---|
| `HSafeB_sym_iff` | assumed | **honest boundary** — the object pool is *external* to the twelve TUs (verified: `gObjectPool`/`gObjectLists` absent, `spawn_object` `EF_external`). Same trust class as `Hcp_spawn_real`. Non-vacuous (`safeb_wit_sat`, axiom-free). |
| `Hglob_obj_root` | assumed | **honest boundary** — same object-system boundary (`#94` proved the alternative is the rejected 230-site engine change). |
| `Hspawn` (`∃ init, spawn_ok`) | assumed | contains **one** residual: `∃ init, init_mem lp = Some init`. The symbol pins are proved (`spawn_symbols_resolve`, ∀ linked12). |
| C-class externals (audio/dialog/save/`spawn_object`/math) | assumed | **honest boundary** — CompCert's abstract external-call model; the permanent, labeled edge. |

Everything else in bucket B is now a **lemma**.

The `mem_ok_lp init` precondition is *not* a hole — it is the theorem's
honest antecedent. "There exists a well-formed WMotR spawn state" is true
by playing the game to its start; formalizing it would mean modeling the
entire boot + level-load + object-spawn sequence, which lives outside the
twelve action TUs and is precisely what the model boundary is *for*.

## The one remaining *discharageable* residual: `init_mem` existence

`∃ init, Genv.init_mem lp = Some init` is the only remaining bucket-B item
that is provable-in-principle rather than a genuine boundary. It is not
derivable from `linked12` alone (init_mem of the abstract `lp` is not
computable), but it has a **certificate-shaped discharge** identical to the
`linked12_inhabited` arc: `Genv.init_mem` succeeds iff every global's
init-data is well-formed (`Genv.init_mem_exists`-style: each
`init_data`'s symbols resolve and sizes fit). That is a per-TU
`vm_compute` check plus a "`link_prog` preserves init-data WF" meta-lemma —
the exact shape of `pair_ok`/`twelve_cert`. **This is the natural next
mechanical arc** (call it slice 6 / an `InitMemSat.v`), and it would move
`Hspawn` from "assumed modulo init_mem" to "assumed modulo the honest
symbol pins only" — i.e. fully grounded except the model boundary.

## Verdict / recommendation

- **Slice 5 proper is a documentation + classification result, not a
  proof obligation**: R6/R7 are carried-and-preserved (done); the residual
  `SafeB`/object rows are the honest external-object-system boundary,
  co-equal with the already-accepted `spawn_object` external. Record this
  in the capstone header so the boundary is *named*, not silently assumed.
- **The one worth mechanizing is `init_mem` existence** (slice 6), because
  it is genuinely dischargeable by the certificate pattern we already own.
- **Do not** attempt to "prove" `mem_ok_lp` inhabited by constructing a
  boot-sequence memory — that is modeling code outside the twelve TUs and
  would be the deepest un-tethering (inventing the initial state). The
  honest form is the conditional the capstone already has.

Net: after slice 6, GOAL-1's entire trust surface is (a) `linked12` —
proved inhabited; (b) the `mem_ok_lp` antecedent — the honest "starts in a
well-formed WMotR spawn" precondition; (c) CompCert's external-call model
for the named audio/dialog/save/object boundary. Nothing else.
