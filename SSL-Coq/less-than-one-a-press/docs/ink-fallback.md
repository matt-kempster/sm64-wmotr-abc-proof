# Ink graphical-fallback investigation

## Verdict

Ink's proposed engine primitive is **conditionally valid**.  The frame order
does not rule it out.

A single frame can use three different Mario coordinate samples:

1. `MarioObject.oPos` for object collision with Area-1 warp node `0x1E`;
2. `MarioState.pos` for the wall and first floor queries; and
3. `MarioObject.header.gfx.pos` after the first floor query returns `NULL`.

The fallback is in `update_mario_geometry_inputs` and is gated by the null
floor result; it is not a special branch inside the wall-push routine.  A wall
push is one candidate way to produce the floorless State sample, not a proved
or uniquely required producer.

If the object sample overlaps the warp, the State sample is floorless, and the
graphical sample makes the retry select a loaded pyramid-top surface, the
already cached warp interaction can coexist with the later top-floor snap.
Whether the subsequent State-to-Object copy survives the remaining object
lists and whether the final query sees the active or inactive same-epoch owner
are separate lifecycle obligations.

No clean US or JP retail execution constructing those three samples has been
found.  The project therefore records two conditional coordinate witnesses
for a handwritten pipeline, not a game counterexample, a Clight execution, or
a proof of the final two-star claim.

## Which earlier analysis was right?

Both chatbot analyses contained correct local facts, but neither stated the
complete answer.

The following statements are correct:

- `find_floor` narrows X, Y, and Z to signed 16-bit terrain coordinates.
- warp hitbox collision uses the full binary32 `MarioObject.oPos` values;
  Parallel-Universe wrapping does not make a far-away object overlap the warp.
- one coordinate cannot simultaneously overlap the stock upper warp and be
  close enough to stand on the stock pyramid top;
- platform displacement cannot newly move `MarioObject` into the warp before
  that frame's object-collision pass; and
- Mario's rendered/object position is updated later.  This is not an invisible
  permanent displacement.

The incorrect inference was that those facts eliminate every schedule.  They
eliminate a **one-coordinate** schedule.  They do not eliminate the
State/Object/Graphics schedule above.  Object collision may cache the warp
from the old Object sample, while a failed State floor query later copies the
independently stale graphical sample and retries.

## Exact frame order

For the pinned US and JP source, the relevant normal object-update frame is:

1. clear old dynamic surfaces;
2. update spawner and surface objects and rebuild dynamic surfaces; on the
   pyramid-top explosion frame the top marks itself deactivated and its
   behavior interpreter continues to `load_object_collision_model`;
3. apply Mario's platform displacement to `MarioState.pos`;
4. detect object collisions from the old full-float `MarioObject.oPos`;
5. begin non-terrain updates, with the pole-like list before the player list;
6. run Mario's behavior in the player list;
7. perform two wall queries and the first `find_floor` on `MarioState.pos`;
8. if the floor pointer is null, copy `header.gfx.pos` to `MarioState.pos` and
   retry `find_floor`;
9. process the collision array, including the warp cached at step 4;
10. execute `ACT_DISAPPEARED`, snap State Y to the retry floor, and copy State
   to Graphics;
11. run the unconditional `sink_mario_in_quicksand`, which writes Graphics Y
    and may also write `gfx.throwMatrix[3][1]`;
12. copy State coordinates to raw `MarioObject.oPos`;
13. update the pushable, genactor, destructive, level, default, and
    unimportant object lists;
14. unload deactivated objects; the source deallocates an exploding top's
    slot without clearing that frame's previously loaded dynamic surface; and
15. perform the final platform query, which tests `floor->object != NULL` but
    does not test the owner's active flags.

The generated receipts prove the literal deactivation, callback order,
deallocation call, and typed `Surface.object` read.  They do not themselves
prove behavior-interpreter execution, free-list membership at the later cut,
or retention and selection of one concrete surface.

This explains two superficially conflicting facts:

- platform displacement cannot create the same-frame warp collision; but
- a warp collision that was already present can survive a later State and
  Graphics change.

The generated-AST theorem
`graphical_floor_fallback_source_shape_{us,jp}` recognizes the same temporary
loaded from `m->floor`, its equality comparison with `NULL`, the true-branch
`m->marioObj` temporary, `vec3f_copy(m->pos, marioObj->header.gfx.pos)`, and a
later `find_floor` result temporary stored to `m->floorHeight`.
`upper_warp_phase_pipeline_source_shape_{us,jp}` checks the surrounding
call/assignment anchors.
`ink_post_copy_lifecycle_source_shape_{us,jp}` additionally checks the
non-terrain/unload/final-query order, top deactivation and collision-loader
anchors, slot deallocation, and absence of an active-flags read in
`update_mario_platform`.  These are syntax/dataflow receipts, not a Clight
small-step memory proof.

## Concrete floor-miss diagnostic

`InkFallback.v` uses the integer-exact State query:

```text
q = (-2200, 768, -1024)
```

It is still inside the standard Mario/warp horizontal overlap radius.  The
generated Area-1 collision initializer supplies these exact nearby results:

- floor `(498,500,501)` has edge values
  `[52020, 20604, -31008]` and is rejected;
- floor `(498,501,502)` has
  `[31008, -10404, 21012]` and is rejected;
- upper floor `(265,266,372)` has
  `[63140, 10404, 10096]`, but
  `768 - (1280 - 78) = -434`, so the upward floor buffer rejects it;
- the west wall plane offset is `-51`, outside both wall radii `50` and `24`;
  the other nearby axis-aligned offsets have magnitudes `255`, `101`, and
  `103`.

The module checks the supporting US/JP vertex and triangle-word receipts
directly from the generated initializers.  It also checks that the two y=768
static support triangles occur at the tail of the 58-triangle
`SURFACE_WALL_MISC` group, that upper face `(265,266,372)` occurs inside the
288-triangle `SURFACE_HARD` group, and that all three Area-1 water-box records
exclude the stock upper-warp coordinate.  This is initializer evidence; live
floor ownership and list selection are still open.

Under the existing fifteen-owner stock Area-1 abstraction,
`ink_first_query_has_no_modeled_stock_dynamic_floor_candidate` excludes every
dynamic owner at `q`: the top is too high for the 78-unit query allowance and
every non-top owner is horizontally disjoint.

This still does **not** prove that a live retail query returns `NULL`.
Completeness and order of the real static and dynamic partition lists remain a
Clight refinement obligation.

## Conditional local and PU coordinate witnesses

The local graphical sample is:

```text
Object   = (-2048,  768, -1024)   // cached warp collision
State    = (-2200,  768, -1024)   // first-query diagnostic
Graphics = (-2048, 1791, -1024)   // top-face sample
```

The PU graphical variant changes only X:

```text
Graphics = (63488, 1791, -1024)
signed16(63488) = -2048
```

For both variants, Rocq checks the top-face edge/arithmetic witness, the
78-unit retry condition, a handwritten disappeared-action/sink/copy pipeline,
and the final modeled platform proximity.  The witness uses zero for the
intervening projected Graphics-position sink.  A separate theorem proves that
any modeled sink value leaves the copied Object coordinate unchanged inside
`MarioThreeView`.  It does not model the conditional `throwMatrix` store or
the later object-list/unload window.  The coordinate witnesses are:

```coq
ink_local_conditional_pipeline_coordinate_witness
ink_pu_conditional_pipeline_coordinate_witness
modeled_graphics_sink_does_not_change_pipeline_object
```

The branch is conditional on the real first query returning `NULL` and the
retry selecting a loaded top-owned surface.  The coordinate theorems themselves
do not assume or prove those outcomes; they evaluate the handwritten pipeline.
They do not prove allocation ownership, list selection, branch reachability,
collision-array retention, sink/throw-matrix memory refinement, post-copy
object/lifecycle preservation, final owner epoch, or delayed-warp continuation.

Both closed coordinate witnesses use the zero-yaw home top and floor Y
`1791`.  They do not instantiate the explosion/inactive-slot branch.  A
handwritten minimum-pose recurrence starts at home Y and yields the
conservative top-center target `1871` by timer `150`; it does not execute the
timer-59 smooth-rise state or establish the corresponding generated-Clight
binary32 lower bound.  The top is also rotated, so that branch must recover the
actual later transformed surface and selected floor height through the
generalized lifecycle refinement.

The remaining sink and lifecycle statements are not oracle predicates.
`InkFallbackSinkMemoryRefinementObligation` quantifies over a complete concrete
Clight call segment with explicit MarioState, Object, Graphics, depth, and
optional throw-matrix loads.  `InkFallbackPostCopyLifecycleRefinementObligation`
quantifies over exact call/return cuts through the copy, unload, final platform
query, and internal `find_floor` return, with concrete memory and projection
links.  No inhabitant or proof of either record is currently supplied.

## What ordinary and PU movement can and cannot create

`MarioThreeView` separates State, Object, and Graphics.  A State-only writer
may choose an arbitrary next State coordinate while leaving Object and
Graphics untouched.  No locality or displacement-magnitude assumption is
used.

The proved invariant is:

```coq
state_only_prefix_preserves_collision_and_fallback_samples
```

Consequently:

```coq
state_only_prefix_cannot_create_object_graphics_split
arbitrary_ordinary_or_pu_state_only_prefix_needs_preexisting_split
```

This covers ordinary wall pushes, platform displacement, and PU-sized State
endpoints **when they are State-only**.  Starting from `Object = Graphics`,
none of them can manufacture the Object/Graphics split Ink's schedule needs.
PU floor aliasing changes surface lookup; it is not itself a full-float Object
or Graphics writer.

The retry needs less separation than final platform capture.  Because
`find_floor` accepts a floor up to 78 units above its query, a warp-overlapping
Object and a graphical query for a top floor at Y at least `1281` require:

```text
GraphicsY - ObjectY >= 385
```

`ink_ready_requires_at_least_385_graphics_y_separation` proves this for
signed-16-range graphical Y.  The dry ordinary source census finds a largest
relevant positive visual offset of `45`, and
`dry_graphics_offset_cannot_supply_top_retry` proves the corresponding closed
arithmetic exclusion.

For context, the source audit motivates a deliberately conservative generic
relation bound of `208`: water pitch of at most `60` and swimming bob below
`148` can compose across the floor-hit branch.  The upper warp is outside the
checked water boxes, so `208` is not the route-specific audit target.  The
formal theorem excludes Ink readiness **if** retail writers refine to that
relation; `Area1InkWriterCoverageObligation` still has to prove they do.

A prepared `ACT_LONG_JUMP_LAND` state with pre-frame `actionTimer = 4` is a
precision exception to any claim that quicksand always lowers Graphics.  The
moving-action update first clamps/adds the depth from `1.1f` to
`1.350000023841858f`; later the landing cancellation increments the timer from
`4` to `5`, and the landing adjustment subtracts `4.0f`, producing the
negative operand `-2.6500000953674316f`.  Rocq checks that operand and checks
that subtracting it from a zero Graphics base yields
`2.6500000953674316f`; the actual delta at an arbitrary binary32 Graphics Y is
base-dependent.  In the normal action graph, the prepared state requires a
prior A edge.  The stock static upper-warp
support is `SURFACE_WALL_MISC`, not quicksand, but that fact does not clear a
negative depth prepared earlier.  Excluding such persisted state still
requires clean no-A action/state closure.

## Writer census and its formal boundary

The source audit found no stock clean-SSL-Area-1 writer that independently
moves Mario Graphics by the required amount:

- normal ground, air, stationary, pole, hanging, and tornado action helpers
  synchronize Graphics from State inside the action handler, before the
  unconditional post-action sink can break equality;
- shell rendering contributes `+42` in air or `+45` on the ground;
- the large full-XYZ anchor writer is used by Chuckya/King Bob-omb anchoring,
  neither of which belongs to stock SSL Area 1;
- `bhvMario` does not set `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE`;
- allocation initialization and SpawnInfo setup occur before `init_mario`,
  which synchronizes State, Object, and Graphics; and
- a stale `gMarioPlatform` pointer writes State, not Graphics.

`mario_entry_coordinate_sync_source_shape_{us,jp}` checks ordered initializer
and raw-slot syntax anchors.  It is deliberately not advertised as a memory
equality theorem.  The behavior-script interpreter and graph-node spawn
writer are outside the current generated translation-unit set.

The remaining source-to-semantics obligation is
`Area1InkWriterCoverageObligation`: every reachable clean no-A Area-1
position transition must refine to the audited State-only, synchronization,
or bounded-Graphics writer relation.  The related entry-memory equality and
action/spawn closure must also be proved.

## Remaining obligations

The decisive unfinished work is:

1. prove entry-time Object/Graphics synchronization and relevant action/depth
   state in live US/JP Clight memory;
2. prove complete clean Area-1 writer/action/spawn closure, including bodies
   outside current generated coverage;
3. execute the real wall and surface-list code to prove or refute the first
   `NULL` result at a reachable State sample;
4. execute the retry over a loaded top-owned surface and prove actual
   selection;
5. prove collision-array retention through the fallback and action change,
   including the Graphics-position and conditional `throwMatrix` writes in the
   quicksand sink (`InkFallbackSinkMemoryRefinementObligation`);
6. prove the copied raw Object survives later object lists and decide the
   final floor owner across active-top and same-frame inactive-owner cases,
   including concrete surface identity, transformed explosion pose, selected
   floor height, and preservation across the explicit unload-function call
   (`InkFallbackPostCopyLifecycleRefinementObligation`);
7. if a top platform is captured, separately prove that the top is actually
   scanned/deallocated, establish any claimed free-list membership, and prove
   its allocation epoch, unload/reuse, delayed-warp retention or recapture, and
   destination-area first apply; and
8. continue to a target collision and newly set Act 3 or Act 6 bit.

`Area1InkPrestateReachabilityObligation` names the missing constructor.  No
reachable clean constructor and no retail target-bit counterexample was found.
The ultimate theorem remains unproved.
