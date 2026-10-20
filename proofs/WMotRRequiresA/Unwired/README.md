# `WMotRRequiresA/Unwired/` — staging for GOAL 2

Pieces of the WMotR-requires-A argument (see `../README.md`) that are proved but not
yet wired into a GOAL 2 capstone. Their paths are in `_CoqProject`, so they are
compiled. Mirrors `../../NoAImpliesNoFly/Unwired/`.

- `GravitySlice.v`: the first executor slice (apply_gravity), from the symbolic walk.

The act_freefall walk's files (FloorList ... AirStart, 24 files) were promoted to the
spine on 2026-10-20, when `FfRow.ff_moves` put the walk under the GOAL-2 capstone;
their descriptions moved to `../README.md`.
