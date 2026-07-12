# Working claim and scope

Last updated: 2026-07-12 (pinned source-ingestion commit).

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

Open, with the only syntactic runaway seed isolated. The source permits an
unbounded local lasso if `DOUBLE_POUND` enters its velocity-100 grounded branch
while gravity is zero. The audit supports, but does not itself prove, the
reachable-state invariant excluding that seed:

```text
reachable hand && action = DOUBLE_POUND && gravity = 0
  -> velocity <= 0 && not grounded
```

The generated Clight surface and audit receipt are now reproducible. The
planned conservative absolute-height envelope is 1196 for the earlier surface-
list hand and 2003 for the later hand: static vertex ceiling 896, upward-flight
allowance 300, and scaled hand-collision top offset 507. These numbers are not
yet a proved reachable-state theorem.

The object-helper Clight input applies the sibling project's seven literal-
suffix compatibility edits because CompCert 3.15 rejects long-double
constants. None of those edits occurs in the audited vertical integration,
ground comparison, or `cur_obj_move_standard` control path.

No `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent project-added proof
hole may enter a capstone.
