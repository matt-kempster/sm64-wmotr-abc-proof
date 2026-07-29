# Ink graphical-fallback investigation

## Verdict

Ink's proposed schedule is **consistent with the inspected source order and is
not ruled out by the current proofs**.  No linked Clight engine execution of
the schedule has been proved.

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
require a future replacement lifecycle interface.

No clean US or JP retail execution constructing those three samples has been
found.  The project therefore records two conditional coordinate witnesses
for a handwritten pipeline, not a game counterexample, a Clight execution, or
a proof of the final two-star claim.

## Five-obligation audit checkpoint

The five requested Ink obligations no longer all have the same status:

1. `InkFallbackSurfaceRefinementObligation` is not itself the retail theorem.
   Its current two predicate arguments can make the proposition true or false
   by definition; `ink_surface_refinement_schema_is_predicate_sensitive`
   proves that it is a schema, not a closed live-list theorem.  It must be
   replaced by concrete `find_floor` call segments.
2. `Area1InkPrestateReachabilityObligation` is also a predicate schema.
   `area1_ink_prestate_requires_at_least_973_graphics_y_gap` proves that either
   exact proposed prestate needs at least `973` units of
   Graphics-minus-Object Y separation.  This is stronger than the generic
   signed-range `385`-unit retry lower bound.
3. `Area1InkWriterCoverageObligation` is likewise predicate-sensitive rather
   than a concrete retail coverage statement.  The closed theorem
   `audited_writer_coverage_refutes_area1_ink_prestate` proves that an audited
   synchronized entry plus complete audited writer-execution coverage rules
   out the exact Ink prestate.  The missing work is deriving that coverage
   from reachable US/JP Clight execution.
4. The original `InkFallbackSinkMemoryRefinementObligation` was **false**.
   An unrestricted `Smallstep.star` could return from the sink, resume a
   caller loop, invoke the sink again, and choose the second return as its
   endpoint.  Its aggregate linear slice test also missed a 32-bit pointer
   wrap where Graphics Y and `throwMatrix[3][1]` are the same address.
   `ink_linear_slice_disjointness_misses_pointer_wrap_alias` is the checked
   modular-address counterexample.  The current record is repaired to stop at
   the first matching return and to require disjoint individual modular
   four-byte cells; the repaired obligation is open.
5. `InkFallbackPostCopyLifecycleRefinementObligation` is **not a sound proof
   target as currently stated**.  It can be unsafe with an arbitrary
   `project_state` or hostile extra linked definitions, while the exact
   current translation can make its interior Mario-copy cut vacuous because
   `behavior_script.c` is not imported and `cur_obj_update` remains external.
   It also lacks pointer-to-pool-slot/epoch linkage, writer and external-call
   frame conditions, and finite-float premises.  The checked theorem
   `equal_binary32_samples_do_not_imply_platform_tolerance` supplies a quiet
   NaN counterexample to inferring the `< 4.0f` platform branch from equal Coq
   values.

These are formal-specification counterexamples, not retail gameplay
counterexamples.  No clean US/JP trace reaching either target star was found.

## OOB death check and delayed-warp priority

The second floor lookup matters for more than platform capture.  In both
generated versions, if the retry also leaves `m->floor == NULL`,
`update_mario_geometry_inputs` calls:

```c
level_trigger_warp(m, WARP_OP_DEATH);
```

This happens before `mario_process_interactions` consumes the already cached
upper-warp collision.  That interaction does not immediately request the
object warp: it selects `ACT_DISAPPEARED` with a two-count action argument, and
`act_disappeared` calls `level_trigger_warp` when the count reaches zero.
`level_trigger_warp` only writes while
`sDelayedWarpOp == WARP_OP_NONE`.  At zero lives it changes the stored death
operation to `WARP_OP_GAME_OVER`; both outcomes are nonzero fatal operations.

The generated-AST claims
`ink_retry_null_death_preemption_source_shape_{us,jp}` check the guarded death
call with the exact `(m, 18)` argument shape, check that every direct AST
assignment to the delayed-warp cell in `level_trigger_warp` lies under its zero
guard, and record the lexical geometry-before-interaction call order.
`ink_retry_null_fatal_latch_blocks_later_upper_request` proves the corresponding
closed latch transition using `InkFatalWarp`, which abstracts death and
game-over.  The current generated recognizers do not themselves check the
zero-lives rewrite or exact two-count action argument; those are
pinned-source audit facts pending linked execution.

This is strong source/transition evidence, but not yet a linked Clight
exclusion.  The remaining refinement must prove that the delayed-warp cell is
empty when this geometry call begins and establish the scheduler-aware
disjunction: either the fatal value is still pending when the later
`act_disappeared` request occurs, or every earlier clear belongs to a
reset/initialization interval that destroys the disappeared-action
continuation before another Mario update can use it.  The concrete call/return
path must also refine to the small latch model.  Under those source-backed
premises, the **both-queries-null** scheduling shape cannot be the Area-1
upper-warp route.  Ink's surviving shape requires the first query to be null
and the graphical retry to return a non-null floor; a top-owned retry is still
unproved.

The full source timing audit gives a sharper reason:

- the cached interaction still runs on the retry-null frame and sets
  `ACT_DISAPPEARED` with action argument `(WARP_OP_WARP_OBJECT << 16) + 2`;
- `execute_mario_action` then returns early because `m->floor == NULL`, so it
  does not dispatch that new action in the same frame;
- on later frames with a usable floor, the action decrements the low counter
  once per Mario update and requests the object warp when it reaches zero;
- normal-play `initiate_delayed_warp` runs after the object update, decrements
  the fatal timer, and has no direct assignment to `sDelayedWarpOp`; and
- relevant clear sites have one of two source orderings: warp-arrival/credits
  paths reset the action before clearing, while `init_level` and
  `lvl_init_from_save_file` clear first but reset before the next normal Mario
  update.  In either case a useful proof needs the scheduler fact that no
  disappeared-action dispatch occurs in the intervening initialization
  interval.

This source audit found no retail scheduling counterexample.  The remaining
formal gap is precise: `behavior_script.c` is not imported, so `cur_obj_update`
is external and the current generated link does not prove one
`bhv_mario_update` per well-formed Mario-object visit.  A full theorem also
needs shared-global linking, external frame conditions, clean normal-play
scheduler invariants, valid pointers/no undefined behavior, and the compiled
float-to-s16/`find_floor` refinement that establishes the two null results.

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
9. if the retry is also null, request the death/game-over warp before
   interaction processing; under the pending scheduler-aware refinement, that
   first request either blocks the later object warp or is cleared only by an
   initialization/reset path that destroys the continuation first;
10. process the collision array in either case, including the warp cached at
    step 4; this may select `ACT_DISAPPEARED`, but its later delayed-warp
    request cannot replace an uncleared fatal latch;
11. on the useful non-null-retry branch, execute `ACT_DISAPPEARED` in that
    frame, snap State Y to the retry floor, and copy State to Graphics.  On the
    retry-null branch, the floor-null early return defers action dispatch.  A
    later request is blocked if the fatal latch is still occupied; if a clear
    occurs first, the retail exclusion instead requires the reset/init
    scheduling proof described above;
12. on the non-null/action-dispatch branch, run the unconditional
    `sink_mario_in_quicksand`, which writes Graphics Y and may also write
    `gfx.throwMatrix[3][1]`; the retry-null early return skips this call;
13. copy State coordinates to raw `MarioObject.oPos`;
14. update the pushable, genactor, destructive, level, default, and
    unimportant object lists;
15. unload deactivated objects; the source deallocates an exploding top's
    slot without clearing that frame's previously loaded dynamic surface; and
16. perform the final platform query, which tests `floor->object != NULL` but
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
future replacement lifecycle refinement.

The repaired sink statement is not an oracle predicate:
`InkFallbackSinkMemoryRefinementObligation` now quantifies over a concrete
first-return Clight call segment with explicit MarioState, Object, Graphics,
depth, optional throw-matrix loads, and disjoint modular cells.  It remains
unproved.  The lifecycle record does quantify over concrete call/return cuts,
but its current link and projection interfaces are too weak for the universal
postcondition; it must not be counted as a valid open theorem until the defects
listed above are repaired.

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

For the two exact local/PU prestates proposed here, the stronger checked bound
is:

```text
GraphicsY - ObjectY >= 973
```

The object must remain at or below Y `818` to overlap the warp, while both
graphics samples use Y `1791`.

The displacement figures are easiest to compare in one table.  Here “gap”
means raw collision-Object Y subtracted from graphical Y; a State-only writer
does not change either column.

| Case | Collision Object Y | Graphics Y | `GraphicsY - ObjectY` | Status |
| --- | ---: | ---: | ---: | --- |
| Synchronized entry | same as Graphics | same as Object | `0` | Required initial relation still needs a linked-memory proof |
| Dry source-audit envelope | arbitrary | arbitrary | at most `45` | Conditional source-audit target |
| Conservative modeled writer envelope | arbitrary | arbitrary | at most `208` | Proved invariant for covered abstract writers; retail coverage open |
| Signed-range generic top-query minimum | at most `818` | at least `1203` | at least `385` | Proved necessary arithmetic bound for a floor at least `1281` with the 78-unit query allowance |
| Exact Ink prestate schema, worst warp-overlap Y | at most `818` | `1791` | at least `973` | Proved by `area1_ink_prestate_requires_at_least_973_graphics_y_gap` |
| Displayed local/PU coordinate witness | `768` | `1791` | exactly `1023` | Handwritten-pipeline coordinate witness, not a reachable trace |

For context, the source audit motivates a deliberately conservative generic
relation bound of `208`: water pitch of at most `60` and swimming bob below
`148` can compose across the floor-hit branch.  The upper warp is outside the
checked water boxes, so `208` is not the route-specific audit target.  The
formal theorem excludes Ink readiness **if** retail writers refine to that
relation.  A concrete linked-run replacement for the predicate-sensitive
`Area1InkWriterCoverageObligation` schema still has to derive that coverage.

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

## Interaction and action displacement census

There are two different notions of “shell displacement,” and conflating them
would make the proof unsound:

1. `interact_koopa_shell` may change Mario's action or push Mario out of the
   shell hitbox.  That affects MarioState/collision physics.
2. The later riding-shell action adds a small Y offset only to the rendered
   Graphics coordinate.  It does not lift MarioState or the raw collision
   Object by `42` or `45`.

A manual audit of the pinned `interaction.c` found only three helper families
that directly assign MarioState position during interaction processing.  This
is not yet an exhaustive Clight theorem:

| Interaction-stage writer | Direct coordinate effect | Numeric amount or formula | Current proof status |
| --- | --- | --- | --- |
| Bully collision response | Replaces State X/Z with the two-body collision solver's `marioData.posX/posZ` | Depends on both radii, positions, yaw, and speed; there is no source constant giving a global maximum | Not bounded for all clean SSL states |
| `bounce_off_object` | Sets State Y to `objectY + hitboxHeight` | The snap distance depends on the previous Mario/object geometry; callers set vertical velocity to `30` or `80`, which is velocity, not immediate displacement | Formula is source-backed; retail reachability/bounds remain open |
| `push_mario_out_of_object` | Moves State X/Z to a radial target, then runs wall collision | `target radius = objectRadius + MarioRadius + padding`; call-site paddings include `5`, `2`, `-5`, and `-10` | Formula is source-backed; wall resolution and object census are needed for a total bound |

For the stock scale-1 Koopa shell, the shell radius is `50`, Mario's behavior
radius is `37`, and the shell call uses padding `2`, so the pre-wall target
radius is:

```text
50 + 37 + 2 = 89
```

If Mario starts at the shell center, the raw radial correction can be as large
as `89`; at ordinary overlap distances it is smaller.  This is **not** a
proved total one-frame displacement bound, because
`f32_find_wall_collision` may alter the target and the proof has not yet
classified the live walls.  On the successful ride branch, the audited source
performs no direct Mario State/Object/Graphics position assignment—it changes
the action and object references.  The `0` immediate-write statement assumes
the ordinary well-formed, non-aliasing memory relation and is not yet a Clight
call-segment theorem.

The follow-on Graphics-only writers relevant to the Ink gap are:

| Follow-on writer | Coordinate written | Positive Y amount | Meaning |
| --- | --- | ---: | --- |
| Ordinary action/step synchronization | Graphics := State | resulting gap `0` at that point | Copy, not an independent displacement |
| Riding shell in air | Graphics Y only in the source audit | `+42` source operand/model offset | US/JP receipt proves the literal occurs in the named body; statement-level Clight semantics remain open |
| Riding shell on ground | Graphics Y only in the source audit | `+45` source operand/model offset | Same occurrence-level receipt; largest dry audited positive source operand |
| Positive water pitch | Graphics Y only | source expression at most about `+60` | Part of the conservative model, not a global linked theorem |
| Surface-swim bob | Graphics Y only | positive contribution below `148` under the audited s16 conditions | Part of the conservative model |
| Water pitch plus bob | Graphics Y only | modeled integer envelope `<=208` | Proved only for transitions classified by the abstract writer relation |
| Quicksand sink | Graphics Y and possibly throw-matrix Y | `-quicksandDepth`; can raise Graphics if depth is negative | No global bound without clean action/depth closure; checked prepared example is about `+2.65` from a zero base |
| Chuckya/King Bob-omb anchor | Full Graphics XYZ | no fixed bound from Mario's prior position | Writer exists, but neither actor is stock SSL Area 1 |
| Stale platform displacement | State XYZ only | Graphics change `0` in that phase | Cannot itself manufacture the Object/Graphics split |

The Rocq theorem `shell_graphics_y_offsets_fit_dry_audit_bound` checks
`42 <= 45` and `45 <= 45`; the US/JP source kernel pins the two binary32
literals in `act_riding_shell_air` and `tilt_body_ground_shell`.  Those
occurrence checks do not prove the destination field, exact binary32 delta for
arbitrary inputs, shell reachability, or a complete interaction/action census
for every clean retail frame; the field/formula interpretation comes from the
separate pinned-source audit.

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

The remaining source-to-semantics work is to replace
`Area1InkWriterCoverageObligation` with a concrete linked-run relation under
which every reachable clean no-A Area-1 position transition refines to the
audited State-only, synchronization, or bounded-Graphics writer relation.  The
related entry-memory equality and action/spawn closure must also be proved.
`area1_ink_writer_coverage_schema_is_predicate_sensitive` exhibits both
accepting and rejecting instantiations of the current schema.

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
5. prove the repaired first-return, modular-cell sink obligation, including
   the Graphics-position and conditional `throwMatrix` writes
   (`InkFallbackSinkMemoryRefinementObligation`);
6. import `behavior_script.c`, construct an exact no-extra-definitions link,
   anchor the run to a clean `update_objects` frame, certify the concrete
   memory projection and pointer-to-slot/epoch map, and replace the invalid
   lifecycle statement with a sound exact-link interface;
7. prove the copied raw Object survives later object lists and decide the
   final floor owner across active-top and same-frame inactive-owner cases,
   including concrete surface identity, transformed explosion pose, selected
   floor height, and preservation across the explicit unload-function call,
   using that replacement interface.  The legacy
   `InkFallbackPostCopyLifecycleRefinementObligation` name remains only as a
   marker for the interface that must not be proved in its current form;
8. if a top platform is captured, separately prove that the top is actually
   scanned/deallocated, establish any claimed free-list membership, and prove
   its allocation epoch, unload/reuse, delayed-warp retention or recapture, and
   destination-area first apply;
9. prove the retry-null latch starts empty and the scheduler-aware exclusion:
   either its fatal/game-over value persists through the later
   `ACT_DISAPPEARED` object-warp request, or every earlier clear resets that
   continuation before another Mario update can issue a useful request; and
10. continue to a target collision and newly set Act 3 or Act 6 bit.

`Area1InkPrestateReachabilityObligation` is the legacy schema marking the
missing constructor, not a concrete reachability proposition.  No reachable
clean constructor and no retail target-bit counterexample was found.  The
ultimate theorem remains unproved.
