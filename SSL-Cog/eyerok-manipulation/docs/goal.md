# Goal recovery note

Last updated: 2026-07-12 (pinned source-ingestion commit).

## Objective

Build an isolated Rocq/Coq + CompCert Clight project that decides the claim:

> It is not possible to trigger a glitch and manipulate Eyerok's movements so
> that an Eyerok hand rises indefinitely above the floor triangles that toggle
> the Pyramid interior and Eyerok arena.

The intended proof must quantify over adversarial player position, attacks,
timing, and boss random choices. If the statement is false, replace the
impossibility target with a concrete action and movement trace.

## Proof route

1. Pin the US source revision and audit the Eyerok action handlers, object
   movement helper, paired SSL instant warps, and transition triangles.
2. Generate CompCert Clight for an executable vertical model and the authentic
   Eyerok translation unit.
3. Prove generated-AST shape facts for every source mechanism that can assign
   Y, vertical velocity, or gravity.
4. Define a player-adversarial transition relation that over-approximates the
   authentic action choices and partial-update behavior.
5. Prove a uniform home-relative height invariant and derive that no modeled
   infinite run has unbounded height.
6. Keep the source-to-model simulation boundary explicit; close it against
   generated Clight execution or leave the global gameplay theorem conditional.

The source audit has identified the exact counterexample fork for steps 3--5.
If `DOUBLE_POUND` is reached while grounded with gravity zero, its velocity-100
branch creates an unbounded ascent. The intended impossibility proof therefore
has to derive that this state is unreachable from the authentic hand/boss
schedule, including dynamic hand collision and partial-update cases. The audit
now checks the static facts supporting that derivation.

## Repository constraints

- Work only in `SSL-Cog/eyerok-manipulation/`, except for the required project
  entry in `SSL-Cog/README.md`.
- Inspect but do not modify `SSL-Cog/ssl-pyramid-item-proof/`.
- Update `docs/goal.md`, `docs/claim.md`, and `docs/checklist.md` in every
  commit.
- Commit each coherent change.
- Do not push without explicit user approval.
