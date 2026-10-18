# `WMotRRequiresA/Unwired/` — staging for GOAL 2

Pieces of the WMotR-requires-A argument (see `../README.md`) that are proved but not
yet wired into a GOAL 2 capstone. Their paths are in `_CoqProject`, so they are
compiled. Mirrors `../../NoAImpliesNoFly/Unwired/`.

- `GravitySlice.v`: the first executor slice (apply_gravity), from the symbolic walk.
- `FloorList.v`: the value contract of the real `find_floor_from_list`. It returns
  NULL with memory unchanged, or a surface read from a node of the list, with one
  float written through `pheight`. This is the first brick of the executor's
  `find_floor` contract (`docs/goal2-value-walk-plan.md` §9).
  `ff_value_contract` is the contract of the real `find_floor` built on it.
  Assuming the partition lists are well formed, `*pfloor` gets NULL or a surface from a
  partition list, and nothing outside the statics and that cell changes.
- `FloorExec.v`: the executor's `find_floor` contract `c_ff`, proved sound against the
  real body (`c_ff_sound`). The three static cells get fresh values; `*pfloor` gets NULL,
  or a world surface (an `Fworld` fact). The world facts it needs (writable statics,
  well-formed partition lists, surfaces outside the consumer's regions) come from a
  consumer fact `Fuser kW (wargs R0)` whose meaning is `Wff` on the frame's entry
  memory. That is a frame invariant for a later layer to prove, not a TRUST row. The
  lab (`playground/SymExec2Lab.v`) now uses `c_ff`, and the counts are unchanged:
  7328 / 225 / 4.
