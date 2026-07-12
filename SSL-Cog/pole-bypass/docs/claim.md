# Working claim and scope

Last updated: 2026-07-12 (global boundary interface commit).

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

The collision audit identifies the sixth floor as eight exact
`SURFACE_CAMERA_FREE_ROAM` triangles. Their inner boundary is the rectangle
`x=[-101,102]`, `z=[1229,1434]`; from the pole center the four cardinal
clearances are 101, 102, 102, and 103. Therefore radial distance below 101 is
sufficient to prove Mario remains in the hole. Radial distance at least 101 is
not sufficient for an arbitrary direction, so the one-A witness will use the
westward direction explicitly.

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

The ordinary, normalized pole route has machine-checked minimum A count one in
the project's closed-world transition system. No zero-A counterexample is
established. The unqualified bottom-to-sixth gameplay claim remains open
because global bypass/model completeness is not yet proved.

The source audit already identifies the ordinary route's key asymmetry: A from
the pole selects `ACT_WALL_KICK_AIR` or `ACT_TOP_OF_POLE_JUMP`, whereas the
US non-A Z/low-health exit selects `ACT_SOFT_BONK` with forward speed `-2`.
Those observations become machine-checked claims only after the generated AST
and proof commits land. The committed `inputs/pole_model.c` now makes the
local abstraction executable. Its non-A branch over-approximates the pole
object's radial push by snapping any sub-70-unit radius to 70 before adding the
two-unit soft-bonk motion; the proof must justify this bound against the real
push formula and update order. Its A branch uses horizontal speed 22 as a
five-frame lower bound rather than treating the source's initial minimum speed
24 as constant through airborne drag.

The generated source surface is intentionally wider than the model: it
contains the authentic SSL script, pole behavior, pole actions, button/action
setup, pole interaction, airborne actions, air step, and object-list update
order. This supports source-shape certificates but is not yet a linked
whole-program execution proof.

`pipeline/audit_pole_transfer.py` now checks all collision group counts, exact
fifth/sixth triangle indices and vertices, the rectangular opening, pole
placement/height, authentic velocity clearing, A/Z action branches, jump
setup, air drag/gravity, pole push formula, and object-list update order. Its
committed receipt pins normalized SHA-256 hashes of every audited source file.

`proofs/PoleArithmetic.v` grants the non-A exit the maximum pole height and a
conservative radial over-approximation: 70 units of pole push plus two units
per eligible air frame. Gravity puts the last above-floor frame at index 6,
so radius is at most 82, below the 101-unit nearest hole edge. The one-A
witness faces west, has a five-frame displacement lower bound 110, remains
above the ring, and crosses the Y=3942 plane between frames 33 and 34 while
its 24-per-frame displacement upper bound remains inside the west outer edge.

`proofs/PoleRoute.v` proves every modeled route to `SixthFloor` contains an A
edge and constructs a route with exactly one. `proofs/PoleBypass.v` packages
that theorem with generated Clight shape certificates. This capstone is not a
simulation theorem for every authentic state/action from the Pyramid bottom.

`proofs/GlobalBoundary.v` formalizes the missing implication. Its
`bypass_model_complete` premise quantifies over an abstract type of authentic
runs and requires every bottom-starting sixth-floor run to produce a modeled
`SixthFloor` trace with modeled A count no larger than the physical count.
`global_lower_bound_from_bypass_model_complete` then proves the global lower
bound. The project does not inhabit that premise yet; no axiom is introduced
to pretend otherwise.

## Known boundaries to keep explicit

- Generated-AST shape facts do not automatically prove whole-program Clight
  execution semantics.
- A collision-mesh certificate must justify the modeled sixth-floor hole.
- Arbitrary prepared fifth-floor states, object/platform displacement,
  moving geometry, warps, and parallel-universe routes remain in scope for the
  global bypass audit.
- No `Admitted`, `Axiom`, or equivalent project-added proof hole may enter a
  capstone.
