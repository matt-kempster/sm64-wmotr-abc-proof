# SSL spawning displacement proof

This project targets the Japanese (`VERSION_JP`) Super Mario 64 behavior behind
spawning displacement.  It is intentionally separate from
`ssl-pyramid-item-proof/`, whose generated Clight artifacts target the US
configuration.

The goal is not to prove a full star route.  The first capstone is the engine
mechanism:

- JP area spawning preserves `gMarioPlatform`.
- `apply_mario_platform_displacement()` uses the current pointer value when it
  is non-null.
- Object deallocation pushes a slot to the front of `gFreeObjectList`, and
  later allocation pops from the front.
- Therefore a JP stale `gMarioPlatform` pointer can survive an area transition
  and then name either stale object memory or a newly allocated object in the
  same slot.
- For SSL, the first pass records the outside seed platforms, the area-2 macro
  count, the regular spawn order, and the Spindel fields that make it the most
  interesting target.

## Source configuration

The generated Clight files are JP-specific and live under `generated/jp_*.v`.
They must be regenerated with `VERSION_JP=1` and `F3D_OLD=1`; do not substitute
the US generated files from `ssl-pyramid-item-proof/`.

The Makefile searches for the SM64 decompilation source in the same locations
as the sibling proof project.  Override it with:

```sh
make SM64=/path/to/sm64 generated
```

The JP Clight flags used by the Makefile are:

```text
-normalize -nostdinc -fstruct-passing
-I$(SM64)/include
-I$(SM64)/build/jp
-I$(SM64)/build/jp/include
-I$(SM64)/src
-I$(SM64)/src/game
-I$(SM64)
-I$(SM64)/include/libc
-DVERSION_JP=1
-DF3D_OLD=1
-D_FINALROM=1
-DTARGET_N64=1
-DNON_MATCHING=1
-DAVOID_UB=1
-D_LANGUAGE_C=1
```

## Included C modules

The JP generation targets cover:

- `src/game/platform_displacement.c`
- `src/game/object_list_processor.c`
- `src/game/spawn_object.c`
- `src/game/area.c`
- `src/game/level_update.c`
- `src/game/mario.c`
- `src/game/interaction.c`
- `src/engine/surface_load.c`
- `src/game/macro_special_objects.c`
- `src/game/behavior_actions.c`
- `src/game/obj_behaviors.c`
- `data/behavior_data.c`
- `src/engine/level_script.c`
- `levels/ssl/script.c`
- wrapper inputs for `levels/ssl/areas/1/macro.inc.c`,
  `levels/ssl/areas/2/macro.inc.c`, and `include/macro_presets.inc.c`

## Build

Use the same opam switch as the existing proof:

```sh
source pipeline/env.sh
make generated
make proofs
bash pipeline/check.sh
```

## Current proof shape

The hand-written files under `proofs/` mirror the sibling project's style:
small AST walkers, a compact specification/model layer, and named theorems for
each source fact.  The current capstone is conditional rather than a full route
theorem: if the old platform slot is reused by the SSL Spindel and Spindel is in
an active movement state, the first object update applies displacement from
Spindel fields before `update_mario_platform()` recomputes the pointer.

The generated-Clight grounding is kept in the build pipeline and source census.
Future work should replace the remaining model-level source certificates with
`vm_compute` facts over the generated JP modules, following the pattern in
`ssl-pyramid-item-proof/proofs/*Facts.v`.
