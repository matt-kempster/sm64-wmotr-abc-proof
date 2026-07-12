# Working claim and scope

Last updated: 2026-07-12 (closed-world proof commit).

## Game and source boundary

- Super Mario 64, North American release (`VERSION_US=1`).
- Canonical reference source baseline:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Available sibling checkout:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
- The Eyerok implementation, object fields, action constants, and movement
  helper are checked byte-for-byte against the baseline before generation.
  The sibling SSL script contains later conditional instrumentation, so the
  pipeline extracts the canonical script directly from the pinned Git object.
- Coq 8.16.1; CompCert 3.15 configured for 32-bit big-endian `ppc-eabi`.

## Definitions

- **Eyerok** means either spawned Eyerok hand unless a statement explicitly
  names the non-moving boss controller.
- **Height** means the hand's Y coordinate relative to its spawn/home Y.
- **Player strategy** includes every sequence of Mario positions, legal eye
  attacks, wall/edge outcomes caused by movement, and boss random selections
  represented by the source action graph.
- **Rises indefinitely** means that the heights along one infinite execution
  are unbounded above. A single high but finite jump is not an infinite rise.
- **Partial update** is the `cur_obj_move_standard` path where far-away or
  different-room flags suppress physical movement after the behavior state
  has updated.

## Target theorem and proof boundary

The first capstone will prove a closed-world statement:

```text
every execution of the player-adversarial Eyerok vertical model
  -> every reachable hand height is at most one uniform bound
  -> the execution is not unbounded above
```

Generated Clight and source-audit facts will justify the model's constants and
transition surface. They are not automatically a whole-program CompCert
simulation theorem. The final gameplay claim additionally requires a bridge
showing that every authentic Eyerok hand frame is simulated by the model.

## Current verdict

Proved for the source-shaped, player-adversarial closed-world model; direct
whole-program Clight refinement remains open. The source permits an
unbounded local lasso if `DOUBLE_POUND` enters its velocity-100 grounded branch
while gravity is zero. The audit supports, but does not itself prove, the
reachable-state invariant excluding that seed:

```text
reachable hand && action = DOUBLE_POUND && gravity = 0
  -> velocity <= 0 && not grounded
```

The formal scheduler now proves this invariant for every reachable modeled
state and proves the stronger grounded form has gravity at most `-15`. The
vertical model proves the conservative absolute-height envelope: 1196 for the
earlier surface-list hand and 2003 for the later hand, from static vertex
ceiling 896, upward-flight allowance 300, and scaled hand-collision top offset
507. Every modeled infinite run is therefore not unbounded above.

The object-helper Clight input applies the sibling project's seven literal-
suffix compatibility edits because CompCert 3.15 rejects long-double
constants. None of those edits occurs in the audited vertical integration,
ground comparison, or `cur_obj_move_standard` control path.

The executable C model is an explicit abstraction boundary. Its
`ascentBudget` and surface rank are ghost-style proof state, not SM64 object
fields. The budgets 98, 288, and 285 are the sums of the positive post-gravity
vertical increments for the source's `30/-4`, `50/-4`, and `100/-15`
impulses. The uniform budget 300 is conservative. The model's safety predicate
requires `Y + ascentBudget` to stay below 1196 for the first hand or 2003 for
the second and excludes the explicit runaway mode.

`proofs/EyerokManipulation.v` packages generated-model shape, authentic-source
shape, scheduler unreachability, finite height boundedness, infinite-run
boundedness, and the runaway-lasso counterfactual. Generated shape facts are
syntactic Clight certificates, not whole-program execution semantics.

`proofs/GlobalBoundary.v` quantifies over an abstract authentic run and proves
that a per-frame refinement to reachable model states implies absolute Y <=
2003 and rules out unbounded rise. The project does not yet inhabit that
refinement premise, so the unqualified original-binary theorem is not claimed.

No `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent project-added proof
hole may enter a capstone.
