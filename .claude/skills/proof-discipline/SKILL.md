---
name: proof-discipline
description: READ FIRST before continuing, extending, discharging, finishing, or "advancing" any Rocq/Coq proof in this repo, and before adding a Definition/Lemma/Axiom/Hypothesis. The bottom line is advancing the REAL theorem (tethering the proof to the real SM64 program) — NOT a green build, NOT axiom-cleanliness, NOT proving another true-but-disconnected lemma. Guards against the LLM failure mode of doing clean, careful, axiom-free work that moves the real theorem nowhere. Triggers — "continue/finish/work on the proof", "discharge this hypothesis / sorry / Admitted", "prove <lemma>", "make it compile", anything touching proofs/ or the Unwired/ regime. Pairs with the run-sm64-wmotr-abc-proof build skill.
---

# Proof discipline: advance the REAL theorem, or you did not make progress

## The one question

After any proof work, the only thing that matters:

> **Is the capstone now closer to a TRUE statement about the REAL SM64 program
> than it was before?**

Not "does it build." Not "is it axiom-clean." Not "did I prove a new lemma."
Those are **hygiene** (necessary, cheap to satisfy, and below). The bottom line
is **tethering** — how much of the real theorem the proof actually pins down.

**The failure mode this exists to stop (la-la-land).** It is *not* a red `Qed`.
It is a session of green, axiom-free, fully-`Qed`'d, carefully-structured work
that is **disconnected from the real theorem** — a tower of true lemmas about
placeholders, or a definition that doesn't mean what its name says. This skill
exists because exactly that happened: four green, axiom-clean, no-new-axiom
commits, all inside `Unwired/`, advancing the real theorem **nowhere**. The
metrics all passed; the bottom line did not move. See the Lean community's
[*Did you actually prove what you think you proved?*](https://leanprover-community.github.io/did_you_prove_it.html).

Paths below are relative to the repo root.

## Step 1 — find the bottom line, and what is still a fiction

Read the capstone's *statement* and its current `Print Assumptions` **first** —
that is the bottom line you must move, and it tells you what is still a fiction.

- GOAL 1: `NoAImpliesNoFly/NoAImpliesNoFly.v : noA_no_spawn_never_flying`.
  Today it rests on an **abstract** `step : Inp -> mem -> mem -> Prop` and a
  black-box `frame_preserves_nonflying` hypothesis — i.e. it is a true theorem
  about a **fiction** until `step` is the real clightgen'd frame. That gap *is*
  the work.
- GOAL 2: `WMotRRequiresA/` (not started).

The honest scoreboard is the **residual-hypothesis surface** the audit prints
(`reach_body_avoids`, `reach_ext_preserves`, `reach_value_preserves`,
`assign_avoids`, the abstract `step`/`frame_preserves_nonflying`). The question
that measures a session: *which of these is now proved for, or sharpened toward,
the REAL program?*

## Step 2 — what counts as progress (tethering)

Exactly one of these. Each *increases tethering* — makes the capstone say more
about the real program, or makes a residual sharper and closer to removable.

1. **ELIMINATE a residual.** Prove a `reach_*` / `*_avoids` for the real Mario
   genv, shrinking what the capstone rests on. Strongest.

2. **REFINE a vague assumption into precise, real, removable ones — even if the
   assumption COUNT goes UP.** Replacing the black-box `step` +
   `frame_preserves_nonflying` with a *concrete* clightgen'd `step` plus a
   *precise* `reach_frame_preserves` over the real callgraph is **progress**:
   the proof now talks about SM64, and the new residuals have discharge paths.
   Fewer-assumptions is *not* the metric; more-tethered is.

3. **PARTIAL but spine-aimed work** toward (1) or (2). A half-built reach closure
   **on the spine** beats a complete, polished lemma in `Unwired/`. It is fine to
   leave a big step partway done and pick it up next session (goal mode continues
   it). Direction beats completion — a correctly-aimed fragment of the real work
   is worth more than a finished disconnected one.

## Step 3 — adding assumptions can be progress (the guardrail)

Counterintuitive but true: **more** assumptions can mean **more** tethering. An
added `Hypothesis`/`Variable`/`Definition` is *good* iff it is:

- **(a) about REAL program objects** — named functions / fields / offsets from
  `generated/`, the real genv, the real callgraph — not a fresh abstract
  placeholder;
- **(b) strictly MORE PRECISE** than what it replaced;
- **(c) credibly DISCHARGEABLE** — a decidable check, a finite enumeration, a
  standard CompCert lemma, a localized aliasing fact;
- **(d) a NET INCREASE in tethering ON THE SPINE** — not a precise-but-disconnected
  new island. (Precision alone is not enough: an exact assumption that nothing on
  the capstone's path consumes is still la-la-land.)

The line to hold: **decompose the gap, never collapse it.** "Assume
`the_program_never_flies_without_A`" is precise and real-named — and worthless,
because it is the conclusion. Refinement breaks the gap into smaller real pieces;
laundering wishes it away. If an added assumption restates the goal, or pushes the
hard part into a new abstraction, it is the failure mode wearing a precise costume.

## What does NOT count as progress (hygiene, not the point)

These are necessary, and they are the **floor**, not the goal. Satisfying every
one while staying in `Unwired/` is precisely the trap:

- a **green build**;
- **no** `Admitted` / `Axiom` / `sorry`;
- the capstone resting on **only the standard CompCert axioms**;
- a **new true lemma** — if it sits unreferenced in `Unwired/`, it is *staging*,
  not a result;
- **"completing"** something — completion of disconnected work is still disconnected.

`Unwired/` means "proved but the spine does not use it." Proving something there is
**not done**. The same session: wire it into the spine (`git mv` it onto the
capstone's path and have a spine file use it), **or** say plainly — "this is
`Unwired/` scaffolding, nothing on the capstone consumes it yet, the wiring step is
_____, I did not advance the capstone." Never report an `Unwired/` lemma as if it
moved the theorem. (CI's firewall rejects a spine file that reaches into `Unwired/`,
so the only way to *use* `Unwired/` work is to promote it.)

## Don't invent the statement (PIPELINE-not-bespoke)

This repo's credibility rests on it: every fact about SM64 must come from the
mechanically-`clightgen`'d AST in `generated/`, never a hand-written model. A new
`Definition mario_is_flying := ...` that *you* wrote — rather than one that reads
the real `action` field at the real offset of the real `MarioState` composite
(`vm_compute` over `prog_comp_env mario.prog`) — is a fiction you will then "prove"
things about. If you must introduce a definition, tie it to the generated AST and
check it computes to what you expect. Inventing the statement is the deepest form
of un-tethering.

## The mechanical audit — the hygiene gate (passing it ≠ progress)

```bash
bash .claude/skills/proof-discipline/discipline_check.sh
```

It checks build / no-holes / axiom-footprint / firewall+orphans, and **prints the
residual-hypothesis surface**. Run it after any proof work — but understand what it
answers: *"is the tree clean and hooked in,"* **not** *"did the bottom line move."*
A green audit is the floor. The residual list it prints is the real scoreboard;
moving an item on it is the goal. Audit a different capstone with:

```bash
bash .claude/skills/proof-discipline/discipline_check.sh SM64.Proofs.<Path>.<Module> <theorem> [more pairs...]
```

## Step 4 — "Did you advance the bottom line?" (the judgment the script cannot do)

Answer out loud before claiming progress:

- **Tethering.** Does the capstone now pin down more of the real program than
  before? Name the *specific* thing that got more real — a placeholder became a
  generated-AST object, a residual got discharged or sharpened. If you cannot name
  it, you did not make progress.
- **Added an assumption?** Does it pass (a)–(d)? Is it a *refinement* (decompose) or
  a *laundering* (collapse / restate the goal)?
- **Spine, not island.** Is the new work reachable from the capstone, or did it land
  in `Unwired/`? If `Unwired/`, say so and give the wiring step — do not round up.
- **Statement fidelity.** Does the statement still mean what its name claims?
  `step`, `mem_flying`, `noA_run_real` — the real notions, or stand-ins?
- **Non-vacuity.** Hypotheses jointly satisfiable; not secretly the conclusion.

If you can't point at the real thing that got more tethered, say what is still open
rather than rounding up to "proved."

## Gotchas (this repo)

- **"No Admitted" ≠ no gaps.** This project surfaces residuals as explicit
  `Prop`-valued hypotheses (`reach_*`, `*_avoids`, `*_ok`) instead of `Admitted`.
  So the tree can be 100% `Qed` and the capstone still rest on big undischarged
  assumptions. The honest progress metric is *which residuals are proved for the
  real program*, not the admit count — this is the same point as Step 1, baked into
  the project's style.
- **`Print Assumptions` is the lie detector** for *holes* (an `Admitted` in a
  capstone's cone shows up as a non-standard axiom). It is **not** a tethering
  meter: a capstone over abstract placeholders can be axiom-clean and still be
  about a fiction. Cleanliness and tethering are different axes; this skill is about
  the second.
- **`coqc` off-switch false-green.** Always build/check through `pipeline/*.sh`
  (they activate the opam switch); a bare `coqc` can report RC 0 falsely.
- **Don't `vm_compute`/link a whole program** (OOMs) — see
  `Generic/SymbolicLinking.v` for the bounded pattern.
