# Working claim and scope

Last updated: 2026-07-12 (project scaffold commit).

## Game and source boundary

- Super Mario 64, North American release (`VERSION_US=1`).
- Canonical reference source baseline:
  `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- Local source checkout used for generation:
  `36fbf8d693a9fc2bdec0c77402f8e96d07d2f461`; the relevant pole, Mario-action,
  and Area 2 collision files match the baseline, while `levels/ssl/script.c`
  contains unrelated compile-time spawning-displacement instrumentation that
  is disabled by the normal preprocessing flags.
- CompCert 3.15, `ppc-eabi`, 32-bit big-endian target; Coq 8.16.1.

## Definitions

- **Fifth-floor pole:** the Area 2 `bhvPoleGrabbing` object at
  `(0, 3200, 1331)` with behavior parameter 92.
- **Pole top:** behavior hitbox height `92 * 10 = 920`, minus the source's
  100-unit pole-top offset, for absolute Y `3200 + 820 = 4020` before animation
  translation.
- **Sixth floor:** the upward-facing static Area 2 floor band at Y `3942`
  surrounding the pole shaft. The downward-facing Y `3712` triangles are the
  underside of this structure, not the landing floor.
- **A press:** a controller `A_BUTTON` press that
  `update_mario_button_inputs` maps to `INPUT_A_PRESSED`.
- **Zero-A trace:** a trace whose complete bottom-to-sixth input history has no
  A press, including its preparation prefix.

## Target theorems

The first capstone will be a closed-world pole-route result:

```text
reachable sixth-floor state from normalized fifth-floor pole entry
  -> at least one A-press edge occurred
```

It will be paired with an exact one-A witness. This is not, by itself, the
unqualified gameplay theorem. The final global statement additionally needs a
completeness bridge showing that every bottom-reachable zero-A route reaching
the sixth floor is represented by the model, including attempts that bypass
the pole or carry prepared motion/object/platform state into the region.

## Current verdict

Open. No zero-A counterexample is established. No global impossibility theorem
is claimed at scaffold time.

The source audit already identifies the ordinary route's key asymmetry: A from
the pole selects `ACT_WALL_KICK_AIR` or `ACT_TOP_OF_POLE_JUMP`, whereas the
US non-A Z/low-health exit selects `ACT_SOFT_BONK` with forward speed `-2`.
Those observations become machine-checked claims only after the generated AST
and proof commits land.

## Known boundaries to keep explicit

- Generated-AST shape facts do not automatically prove whole-program Clight
  execution semantics.
- A collision-mesh certificate must justify the modeled sixth-floor hole.
- Arbitrary prepared fifth-floor states, object/platform displacement,
  moving geometry, warps, and parallel-universe routes remain in scope for the
  global bypass audit.
- No `Admitted`, `Axiom`, or equivalent project-added proof hole may enter a
  capstone.
