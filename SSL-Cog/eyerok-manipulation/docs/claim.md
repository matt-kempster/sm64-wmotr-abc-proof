# Working claim and scope

Last updated: 2026-07-12 (project scaffold).

## Game and source boundary

- Super Mario 64, North American release (`VERSION_US=1`).
- Canonical reference source baseline:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Available sibling checkout:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`.
- The Eyerok implementation, object fields, action constants, and movement
  helper must be verified identical to the baseline before generated Clight
  from the sibling checkout is admitted as evidence. The sibling SSL script
  is known to contain later conditional instrumentation and is not silently
  treated as the pinned script.
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

Open. The scaffold contains no boundedness theorem and no counterexample.

No `Admitted`, `Axiom`, `admit`, `sorry`, or equivalent project-added proof
hole may enter a capstone.
