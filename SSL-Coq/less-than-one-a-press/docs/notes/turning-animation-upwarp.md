# Turning Part 2 and the reported upwarps

## Verdict

Marbler found a real numerical coincidence, but it is not an upwarp
mechanism.

`MARIO_ANIM_TURNING_PART2` is animation-table index `0xBD` (189).
`MarioState.unkB0` is initialized to `0xBD` (189) and copied to
`AnimInfo.animYTrans` when an animation changes.  Those values have different
roles:

- the animation ID selects table entry 189;
- `unkB0` supplies the numerator of a rendering translation scale; and
- animation 189, like every pinned Mario animation, has translation divisor
  189.

The renderer therefore evaluates binary32 `189.0f / 189.0f = 1.0f`.  It does
not add 189 to Mario's Y coordinate.

No animation-induced retail upwarp or target-star counterexample was found.
The observed correlation with turning is credible because a real ground step
occurs in the same action processing, but the collision/floor operation—not
the animation metadata write—is the possible displacement source.

## Exact source path

The audit uses decomp revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` for `VERSION_US` and
`VERSION_JP`.

In `src/game/mario_actions_moving.c`, `act_turning_around` does this after its
early exits:

1. call `perform_ground_step(m)`;
2. read `m->forwardVel`;
3. select `MARIO_ANIM_TURNING_PART1` (188) when
   `forwardVel >= 18.0f`; otherwise
4. select `MARIO_ANIM_TURNING_PART2` (189).

The source spelling is `MARIO_ANIM_TURNING_PART2`, not
`MARIO_ANIM_TURNING_PART_2`.

There are two local schedules to keep separate:

| Handler | Relevant order |
| --- | --- |
| non-stopping `act_turning_around` | ground step, then animation selection |
| `act_finish_turning_around` | animation 189 selection, then ground step |

The second ordering does not revive the hypothesis: the setter preserves the
three gameplay coordinate views in the project model, so the later ground
step is still the only coordinate-changing operation in that pair.

`act_walking` can change to `ACT_TURNING_AROUND`, and the Mario action loop can
process the new action in the same frame.  That explains why a floor snap may
look synchronized with the first turning frame.  In the ordinary
non-stopping handler, however, the snap has already happened before
`set_mario_animation` is called.

## What `load_patchable_table` does

`src/game/memory.c` implements an on-demand ROM-data cache:

1. cast the requested index to unsigned and require it to be below the table
   count;
2. compute the animation's source address and payload size;
3. if that source differs from the cached source, synchronously DMA the bytes
   to `list->bufTarget`;
4. cache the source address and return true; otherwise return false.

It does not patch executable code or interpret `unkB0`.  The generated US and
JP Clight bodies have one direct callee, `dma_read`, and read `bufTarget`
without directly assigning that field.

At normal startup, `setup_game_memory` reserves `0x4000` bytes for Mario
animation data and installs that allocation as `gMarioAnimsBuf.bufTarget`.
`init_mario_from_save_file` points `MarioState.animList` at
`gMarioAnimsBuf`.

The pinned converter input has 209 animation entries.  ID 189 is valid, its
converted payload is 1,804 bytes, and therefore it fits in the 16,384-byte
allocation.  The project does not silently turn those source-data
observations into a linked-memory theorem: exact converter/table projection
and allocation separation remain named obligations.

## What animation 189 contains

`assets/anims/anim_BC_BD.inc.c` gives Part 2 this header:

- flags `1` (`ANIM_FLAG_NOLOOP` only);
- Y-translation divisor `189`;
- start frame `1`;
- loop start `0`;
- loop end `18`.

Its root X and Z values are zero.  Its root Y samples are:

```text
87, 88, 90, 93, 96, 101, 108, 131, 165,
204, 241, 271, 286, 280, 257, 228, 203, 192
```

With Mario's ordinary one-quarter model scale, their extrema are exactly
`21.75f` and `71.5f`.  These values translate a child skeleton matrix relative
to `header.gfx.pos`.  They do not assign that base position.

Part 2 has none of `ANIM_FLAG_HOR_TRANS`, `ANIM_FLAG_VERT_TRANS`, or
`ANIM_FLAG_6`.  Thus even the separate gameplay root-motion helper would not
apply its root translation.  More importantly, neither turning handler calls
that helper.

A fresh switch sets `animFrame` to `startFrame - 1 = 0`; the immediate
`is_anim_at_end` comparison is `0 + 1 = 18`, which is false.  There is no
first-frame animation-ID/frame alias.

## Which coordinates matter

The proposed SSL/OOB mechanisms distinguish at least these positions:

| View | Consumer |
| --- | --- |
| `MarioState.pos` | floor, wall, and movement processing |
| Mario object's `oPosX/Y/Z` | object hitbox and warp collision |
| `MarioObject.header.gfx.pos` | graphical anchor and the null-floor fallback |
| animated child matrix | rendered skeleton and held-object rendering |

`set_mario_animation` directly writes animation-buffer pointers and
`AnimInfo` fields (`animID`, `curAnim`, acceleration, `animYTrans`, and
frame).  It does not directly write the first three rows.

The newly generated `rendering_graph_node.c` Clight modules check the sole
`animYTrans` consumer.  `geo_set_animation_globals` assigns
`gCurrAnimTranslationMultiplier` from
`animYTrans / animYTransDivisor`; `geo_process_animated_part` consumes it
while constructing matrix-stack entries.  The inspected renderer bodies do
not directly assign `pos` or raw Object data.  The shadow path uses only
horizontal root offset and builds a shadow display list; it does not replace
Mario's gameplay floor or position.

The OOB fallback copies `header.gfx.pos`, not the animated child matrix.
Consequently the 22–71.5-unit visual root offset cannot create Ink's required
State/Object/Graphics-anchor split.

## Important non-global caveats

“Animations never affect gameplay” would be false:

- four cutscene paths explicitly call `update_mario_pos_for_anim`;
- pole actions call `return_mario_anim_y_translation`;
- animation frames control action duration; and
- the rendered hand matrix can update HOLP
  (`MarioBodyState.heldObjLastPosition`), which later throw/drop code may use
  for a held object.

Those facts do not supply a Turning-Part-2 upwarp.  The turning call graph
does not call either physical root-motion helper, Part 2 has no physical
translation flags, and the walking path that selects turning first calls
`mario_drop_held_object`.  The current AST receipt for that last statement is
an ordered source-shape anchor, not a linked proof of every later pointer
state.

## Rocq results

`proofs/TurningAnimation.v` proves without admissions:

- exact binary32 `189 / 189 = 1`;
- the Part-2 ID/payload arithmetic bounds;
- absence of gameplay translation flags;
- bounded root-Y data and exact scaled extrema;
- the fresh-frame non-end result;
- a three-view metadata transition that preserves State, Object, and
  Graphics-anchor positions;
- preservation of every observer that depends only on those three samples;
- impossibility of creating the Ink split from synchronized samples in that
  model; and
- `turning_animation_source_kernel_checked`, which packages the US/JP
  generated-AST receipts and arithmetic.

`proofs/MainTheorem.v` exposes the narrow capstone
`turning_part2_animation_metadata_boundary_excludes_ink_split`.

This is not yet an end-to-end Clight small-step noninterference theorem.

## Model counterexample and remaining obligations

An unconditional DMA frame rule is false for arbitrary C states.  If an
over-permissive model lets `animList->bufTarget` alias a Mario coordinate,
`dma_read` can overwrite that coordinate.  Rocq gives an explicit one-cell
alias witness in
`over_permissive_animation_dma_alias_counterexample`.  This is a
counterexample to the over-permissive abstraction, not a state reachable in a
target ROM.

The remaining narrow obligations are:

- `TurningPart2AssetMappingObligation`: connect converter-produced US/JP table
  entry 189 to the pinned header/root data;
- `MarioAnimationBufferSeparationObligation`: prove the dedicated animation
  DMA range does not overlap projected MarioState, Object, or graphics-anchor
  memory;
- `TurningAnimationCoordinateFootprintRefinementObligation`: execute the
  actual setter/loader transition and project its before/after coordinates;
  and
- `TurningGroundStepUpwarpClassificationObligation`: classify any coordinate
  change in a turning frame through the real motion, floor, platform, or OOB
  writer path.

The practical Layer-B consequence is narrow but useful: the `0xBD`
assignment is not a new bypass constructor.  Any upwarp seen when turning
must return to the existing ordinary-motion/platform/OOB collision
obligations, especially the real `perform_ground_step` and surface-selection
semantics.  The ultimate less-than-one-A theorem remains incomplete.
