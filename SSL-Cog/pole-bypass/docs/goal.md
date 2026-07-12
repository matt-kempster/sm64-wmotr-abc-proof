# Goal recovery note

Last updated: 2026-07-12 (Clight model and generation commit).

## Objective

Build an isolated Rocq/Coq + CompCert Clight project that decides the following
minimum-A question for the US version of the Shifting Sand Land Pyramid:

> Can Mario get from the fifth floor to the sixth floor with zero A presses?

If not, prove that at least one A press is necessary and exhibit the ordinary
one-A pole-jump witness. If the statement is false, replace the impossibility
target with a concrete zero-A counterexample trace.

## Quantification over preparation

The final gameplay claim must not silently assume that Mario arrives at the
fifth floor in an ordinary walking state. A prefix may start at the Pyramid
bottom and prepare any game-reachable state. The formal work therefore keeps
two statements distinct:

- the **pole-route theorem**, beginning after pole interaction has normalized
  Mario's vertical and forward velocity; and
- the **global bypass theorem**, quantifying over every prepared fifth-floor
  entry state reachable from the bottom.

An A press used anywhere in a proposed zero-A counterexample still counts. The
prepared-state quantifier permits arbitrary zero-A preparation, not free A
presses hidden in the prefix.

## Proof route

1. Pin the pole placement, behavior parameter, hitbox-height calculation,
   fifth-floor top, sixth-floor mesh, and input/action code in generated Clight
   and a reproducible collision audit.
2. Prove the non-A pole exit cannot clear the sixth-floor hole before falling
   below it.
3. Prove the A-gated pole jump clears the hole and supplies a one-A witness.
4. Prove an inductive minimum-A result for the closed-world pole-route model.
5. Audit bypass mechanisms and either derive model completeness from reachable
   gameplay states or produce a concrete zero-A counterexample.

The executable C model now uses a conservative pole-object push abstraction:
while Mario is inside the source's 70-unit push radius, the model may place
him at the radius before applying the two-unit soft-bonk motion. This
over-approximates radial escape for the local no-A calculation. The one-A
witness uses a 22-unit per-frame lower bound for the first five frames, below
the source's 24-unit launch minimum after allowing for air drag.

## Repository constraints

- Work only in `SSL-Cog/pole-bypass/`, except for the required project-list
  update in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Do not push without explicit user approval.
