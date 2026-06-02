---
name: proof-discipline
description: READ FIRST before continuing, extending, discharging, finishing, or "advancing" any Rocq/Coq proof in this repo, and before adding a Definition/Lemma/Axiom. Guards against the LLM failure mode of proving disconnected, vacuous, or self-invented things instead of advancing the real theorem. Triggers — "continue/finish/work on the proof", "discharge this hypothesis / sorry / Admitted", "prove <lemma>", "make it compile", anything touching proofs/ or the Unwired/ regime. Pairs with the run-sm64-wmotr-abc-proof build skill.
---

# Proof discipline: prove the RIGHT thing, and hook it in

**Why this exists.** The dominant way LLM proof work goes wrong is not a failed
`Qed` — it's *la-la land*: the model invents a plausible definition, proves a
tower of self-consistent lemmas on top of it, and reports progress, while the
tower is disconnected from the real theorem (or the definition doesn't mean what
its name says, or the statement is vacuous). A green build is **not** evidence
you proved anything useful. See the Lean community's
[*Did you actually prove what you think you proved?*](https://leanprover-community.github.io/did_you_prove_it.html)
— its checklist (it builds, it's actually compiled, axioms are only the standard
set, **the statement is the one you claim**) is exactly what this skill enforces
for this repo.

Paths below are relative to the repo root.

## Step 1 — run the audit (the mechanical half)

After ANY proof work, before claiming the proof advanced:

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

It checks, and exits non-zero on any failure:

1. **BUILD** — the tree actually compiles (`pipeline/build.sh proofs`). A claim is not a check.
2. **NO HOLES** — no `Admitted` / `Axiom` / `sorry` / `Abort` vernacular in `proofs/`. Any of those = you did not prove it; you assumed it.
3. **AXIOMS** — each goal capstone rests *only* on the 4 standard CompCert axioms (`Print Assumptions`). A stray axiom — or a downstream `Admitted` — surfaces here as a non-standard axiom and fails.
4. **HOOKED IN** — `pipeline/check_unwired.py`: nothing in the spine imports from `Unwired/`, and no file outside `Unwired/` is an unmarked orphan.

It also prints the **residual-hypothesis surface** — the abstract `Prop`
parameters (`reach_body_avoids`, `reach_ext_preserves`, `reach_value_preserves`,
`assign_avoids`) that are currently *assumed*, not proved. These are the honest
gaps. Audit a different/new capstone with:

```bash
bash .claude/skills/proof-discipline/discipline_check.sh SM64.Proofs.<Path>.<Module> <theorem> [more pairs...]
```

A green audit is necessary, not sufficient. Step 2 is the part the script can't do.

## Step 2 — how to think when told to "continue the proof"

The instinct to resist: *open a file, find something true-looking, prove it, move
on.* That is how the Unwired ball got big. Instead:

1. **Anchor on the capstone.** The only thing that counts as progress is the goal
   capstone getting closer to proved-and-connected. GOAL 1 is
   `NoAImpliesNoFly/NoAImpliesNoFly.v : noA_no_spawn_never_flying`; GOAL 2 is
   `WMotRRequiresA/` (not started). Read the capstone's statement and its current
   `Print Assumptions` *first* — that tells you the real target and the real gaps.

2. **Discharge a load-bearing obligation — not a new abstraction.** A lemma whose
   *statement assumes* a residual hypothesis (`reach_body_avoids P ge -> ...`) is
   **not progress** until that hypothesis is itself proved for the *real* program.
   Proving more consequences of an undischarged assumption is the tower-building
   trap. The win is to *eliminate* an assumption (prove a `reach_*` for the actual
   Mario genv), shrinking what the capstone rests on.

3. **The `Unwired/` rule is the firewall against drift.** `Unwired/` = "proved but
   the spine doesn't use it." If you prove something there, it is **not done** —
   the same turn, wire it in: have a spine file import/use it, `git mv` it into the
   spine, and re-run the audit. If you *can't* wire it in yet, say so explicitly
   and treat it as scaffolding, not as a result. Never leave a session reporting
   "I proved X" when X sits unreferenced in `Unwired/`. (CI's firewall will reject
   a spine file that reaches into `Unwired/`, so the only way to "use" Unwired work
   is to promote it.)

4. **Don't invent the statement.** This repo's whole credibility rests on the
   **PIPELINE-not-bespoke** rule: every fact about SM64 must be derived from the
   mechanically-`clightgen`'d AST in `generated/`, never a hand-written model. A
   new `Definition mario_is_flying := ...` that you wrote, rather than one that
   reads the real `action` field at the real offset of the real `MarioState`
   composite (`vm_compute` over `prog_comp_env mario.prog`), is a fiction you will
   then "prove" things about. If you must introduce a definition, tie it to the
   generated AST and check it computes to what you expect.

## Step 3 — "Did you prove the right thing?" (the judgement)

Before claiming a lemma/capstone is done, answer these out loud:

- **Statement fidelity.** Does the *statement* say what its name and your summary
  claim? Re-read it adversarially. `mem_flying`, `noA_run_real`, `step` — do these
  abstractions correspond to the real frame step / real input semantics / real
  memory, or are they stand-ins you (or a prior session) introduced? An abstract
  `step` proved correct is a true theorem about a fiction until `step` is the real
  one.
- **Non-vacuity.** Can the hypotheses all hold at once? A frame lemma guarded by a
  hypothesis that is never satisfiable proves nothing. Sanity-check by exhibiting a
  witness, or by confirming the hypothesis is *discharged* downstream (not just
  assumed forever).
- **No silent definitional override.** You didn't redefine a constant
  (`ACT_FLYING`, an offset) to make a goal close. Constants come from the AST /
  the scouted ground truth, not from what makes the proof go through.
- **The gap moved.** Compare `Print Assumptions` / the residual-hypothesis list
  before and after. Did an assumption get eliminated, or did you just add lemmas
  beside it?

If you can't answer these cleanly, you are not done — say what's still open rather
than rounding up to "proved."

## Gotchas (this repo)

- **"No Admitted" ≠ no gaps.** This project surfaces residuals as explicit
  `Prop`-valued hypotheses (`reach_*`, `*_avoids`, `*_ok`) instead of `Admitted`.
  So the tree can be 100% `Qed` and the capstone still rest on big undischarged
  assumptions. The honest progress metric is *which residual hypotheses are proved
  for the real program*, not the admit count. The audit's `[info]` section lists them.
- **`Print Assumptions` is the lie detector.** An `Admitted` lemma anywhere in a
  capstone's dependency cone shows up as a non-standard axiom in the capstone's
  assumptions — the audit's check [3] is exactly this. Trust it over any prose
  claim (including your own).
- **`coqc` off-switch false-green.** Always build/check through `pipeline/*.sh`
  (they activate the opam switch); a bare `coqc` can report RC 0 falsely. The audit
  uses the pipeline drivers.
- **Don't `vm_compute`/link a whole program** (OOMs) — see `Generic/SymbolicLinking.v`
  for the bounded pattern.

## When you genuinely add something to `Unwired/`

Allowed, but it is staging, not a result. State plainly: "this is in `Unwired/`,
nothing consumes it yet, the wiring step is _____." Then either do the wiring this
session or leave it clearly flagged as unfinished. The failure mode this whole
skill exists to prevent is reporting Unwired lemmas as if they advanced the theorem.
