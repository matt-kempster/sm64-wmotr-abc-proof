# `WMotRRequiresA/` — GOAL 2: WMotR cannot be done with 0 A presses

**Status: height form on the spine** (`HeightFrame.v`, capstone
`wmotr_noA_height_bound_linked12`). It is a conditional theorem whose open rows are named.

## The claim

> For every run that collects the WMotR (Wing Mario over the Rainbow) red-coin
> star, the input sequence contains at least one A press.

## The argument (strategy v2, `docs/goal2-strategy-v2-2026-07-01.md`)

```
star needs all 8 red coins → coin #2 (y = 3140) must be touched
  └─ touching needs pos[1] ≥ 3140 − 160 (hitbox)
       └─ a no-A run keeps pos[1] ≤ 2796 < 2980          ← HeightFrame.v + HeightInvariant.v
            └─ Mario's own frame preserves GOAL 1's invariant   ← GOAL 1 (frame_ok_linked12)
```

## What `HeightFrame.v` proves

One game frame = controller poll ∘ platform displacement ∘ **one real
`execute_mario_action` over any twelve-TU link** ∘ level phase ∘ objects. The
Mario segment's preservation of GOAL 1's invariant is the proved
`NoAImpliesNoFlyTwelve.frame_ok_linked12`, not an assumption. The composition is proved.

## What is still open

"One real Mario frame preserves Φ" is the lemma `seg_action_phi`. It rests on:

- `Hseg_call` / `Hseg_any`: one row per call in `execute_mario_action`'s real body
  (`FrameSplit.v`; the call list is computed from the generated AST by `FrameCalls.cl`).
  Each says the call keeps the frame world (action in `R_noA`, W, the anim and
  Mario-object layout facts, A not held) and moves Φ's cells by a `HeightMoveCatalog`
  chain. The body's two stores to Mario's object are proved, and the old whole-frame
  rows `Hframe_stays_noA` / `Hframe_keeps_world` / `Hframe_is_move_chain` are lemmas
  derived from these (`FrameSplit.frame_split`). The airborne dispatcher's row is proved too
  (`AirSplit.air_seg`): it splits into its two prologue calls and one row per no-A
  case, with the action cell equal to the case label (`Hair_pro` / `Hair_case`). The value walk discharges them call
  by call; the airborne dispatcher's freefall case is `Unwired/FfRun.ff_move`.
- `wmotr_gap`, `wmotr_poles`: WMotR level data, **proved** in `WMotRLevel.v` (`wmotr_gap_proved`, `wmotr_poles_proved`).

Also open:

- The four flank specs (TRUST.md 0.7) are labeled trust, because that code isn't linked.
- The coin/star link at the top of the chain (TRUST.md 0.3).

## Done

- **Φ is concrete** (`HeightInvariant.v`, `height_invariant`). It is the budget y + credit ≤ 2424 + 372,
  over real MarioState cells plus `gfx.pos[1]`, with offsets and action ids pinned against
  the generated AST.
- **`Hphi_y` is proved**, so YMAX = 2796.
- **Level data is generated and the rows are proved** (`WMotRLevel.v`): `wmotr_floor` and `wmotr_pole` are
  decoded from clightgen'd terrain, macro objects and level script; the gap fact and the pole row are
  `vm_compute` checks. It found that exclamation boxes are scaled ×2 (K 2372 → 2424).
- **`HeightMoveCatalog.v`** defines the moves a frame can make (air step, ceiling cut, slide-kick
  signed energy, ground-pound windup, E3 switches, attach, floor refresh, OOB). Its
  `chain_keeps_budget` proves the budget for each one in binary32, using `HeightFloatSteps.v`
  (float32 arithmetic) and `HeightBudgetArith.v` (real arithmetic).

Prototypes still live in `playground/` (T1 PlatformInert, T2 FloatBrick, T3 ValueWalk).

## The act_freefall walk (on the spine since 2026-10-20)

`FfWorld.v` is the carried start condition `ffw` (a conjunct of `FrameSplit.fworld` and
`HeightFrame.PhiW`), and `FfRow.v` builds the walk's start state from it (`ff_moves`): the
freefall case's MoveChain is proved. The walk's files:

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
- `CeilList.v`: the value contracts of the real `find_ceil_from_list`
  (`fcl_value_contract`) and `find_ceil` (`fc_value_contract`), built the same way as
  FloorList and reusing its list predicates. `*pceil` gets NULL or a surface from a
  partition list. The only static written is `gNumCalls.ceil` (bytes 2..4 of
  `gNumCalls`). `FloorExec`'s `Wff` now asks for all 6 bytes of `gNumCalls` to be
  writable, so the ceiling executor contract can reuse it.
- `CeilExec.v`: the executor's `find_ceil` contract `c_fc`, proved sound (`c_fc_sound`)
  under the same world fact as `c_ff`. The lab inlines the real `vec3f_find_ceil` and
  contracts `find_ceil` with it. Counts unchanged.
- `TerrainSound.v`: the real `mario_get_terrain_sound_addend` leaves memory unchanged
  and returns an int, for any genv (`terrain_sound_value_contract`). That is the
  `xc_fresh` shape.
- `WallList.v`: the value contract of the real `find_wall_collisions_from_list`
  (`wfl_contract`). For some count c ≥ 0 it returns c. `numWalls` becomes
  `min(nw0 + c, 4)`, every newly recorded wall is a surface read off the list, and
  nothing else changes except `data->x`, `data->z`, `numWalls` and the wall slots from
  `nw0` on. Proved by triples over the loop body (`tri_head`, `tri_push`, `tri_tail`,
  `solve_w`).
- `WallFind.v`: the value contract of the real `find_wall_collisions`
  (`fwc_contract`). It chains `wfl_contract` over the dynamic and static partition
  lists of the cell. For some total c ≥ 0 it returns c, `numWalls = min(c, 4)`, and
  each recorded wall is a surface on a partition list of the entry memory. Only
  `x`, `z`, `numWalls`, the wall slots and `gNumCalls.wall` change. Proved with a body
  triple (`solve_wf`) and `rx_out`: every return returns `numCollisions`.
  It also proves that the wall-slot bytes past the final count are untouched and that
  `x`/`z` are read at entry, so both are readable.
- `WallExec.v`: the executor's `find_wall_collisions` contract `c_fwc`, proved sound
  (`c_fwc_sound`) through `fwc_contract`. There are five outcomes, n = min(count, 4):
  - `x`, `z` and `gNumCalls.wall` get fresh values, `numWalls := n`, and slots 0..n-1
    get fresh world surfaces (Fworld);
  - the result is n for n < 4, and a fresh value at n = 4.

  It is built on a reusable tool, `sstores_havoc`. A contract can describe the
  callee's result memory without replaying its stores on the caller's memory (which
  needs writability the executor does not track). It needs only the value of each
  written cell and that every other cell is unchanged. This replaces the lab's false
  `c_walls` stand-in.
- `AirXc.v`: the contract table for the value walk of the real `perform_air_step`
  (`air_xc`), with SymExec2's `xc_sound` proved for it (`air_xc_sound`). It covers
  `find_floor`/`find_ceil`/`find_wall_collisions` through their executor contracts, and
  `find_water_level`/`atan2s`/`mario_get_terrain_sound_addend` through `xc_fresh` and
  their value contracts. What it assumes is only genv facts (each callee resolves to its
  generated body, `cenv_has`, the `gtab` entries) and the world fact's meaning `HU`.
  The lab (`playground/SymExec2Lab.v`) now runs on exactly this table.
