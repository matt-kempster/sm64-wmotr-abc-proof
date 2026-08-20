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
   `project_state` or hostile extra linked definitions.  The generator now
   imports `behavior_script.c`, but the current link record still does not
   construct the exact link or prove that the indirect `cur_obj_update`
   callback reaches the one intended Mario update.
   It also lacks pointer-to-pool-slot/epoch linkage, writer and external-call
   frame conditions, and finite-float premises.  The checked theorem
   `equal_binary32_samples_do_not_imply_platform_tolerance` supplies a quiet
   NaN counterexample to inferring the `< 4.0f` platform branch from equal Coq
   values.

These are formal-specification counterexamples, not retail gameplay
counterexamples.  No clean US/JP trace reaching either target star was found.

## OOB death check and delayed-warp priority

Thadortin's three-way summary is substantially correct after tightening two
phrases.  The first branch is not a “failsafe to Mario's position”; it is the
ordinary successful query at the post-wall MarioState position.  Also,
touching the warp does not immediately change areas.  It first selects
`ACT_DISAPPEARED` with two ticks remaining.

| First State floor query | Graphics retry | Exact consequence |
| --- | --- | --- |
| non-`NULL` | not performed | retain State; no death request; cached warp may select disappeared |
| `NULL` | non-`NULL` | copy Graphics to State; no death request; cached warp may select disappeared |
| `NULL` | `NULL` | request death/game-over before interactions; cached warp may still select disappeared, but floor-null skips action dispatch |

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

`thadortin_floor_case_split_checked` proves the three abstract outcomes above.
`ink_successful_retry_is_only_first_disappeared_tick` proves that the
non-null-retry frame changes the count from two to one but does not request the
object warp.  `ink_second_supported_tick_can_request_upper_warp` proves the
second supported tick can issue it, while
`ink_second_null_frame_latches_fatal_before_upper_warp` proves the second-null
alternative cannot.

`RetailFatalLatch.v` now formalizes the audited scheduler cases rather than
leaving the block-or-reset disjunction as informal prose.  Starting after an
accepted both-`NULL` fatal request,
`retail_fatal_persists_or_reset_destroys_disappeared` proves for every modeled
event suffix that either the fatal operation remains installed or the old
continuation has been destroyed, and that the upper request remains
unaccepted.  The direct two-supported-tick race is computed separately.

The generated source kernel is deliberately separate.  It checks syntax and
packed data, but does not prove that a concrete Clight trace refines the event
steps.  In particular, the address census covers explicit address-taking in
the generated `level_update.c` unit; it is not a whole-program memory-safety
theorem.  The clear-site receipts check call presence/callee order and
separate clear presence; they do not relate assignment position to the calls
and are not small-step proofs.
A linked execution must establish the clear/reset order, the accepted fatal
call-boundary state, and the concrete both-`NULL` results.  Subject to that
refinement, Ink's surviving shape requires the first query to be null and the
graphical retry to return a non-null floor; a top-owned retry is still
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
formal gap is precise: `behavior_script.c` is now imported, but the current
generated link interface does not construct the exact link or prove one
indirect `bhv_mario_update` per well-formed Mario-object visit.  A full theorem
also needs shared-global linking, the clear-to-reset barrier executions,
external frame conditions, clean normal-play scheduler invariants, valid
pointers/no undefined behavior, and the compiled float-to-s16/`find_floor`
refinement that establishes the two null results.

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
   interaction processing; the checked event invariant proves that an accepted
   fatal request either blocks the later object warp or a reset destroys the
   old continuation, while concrete event projection remains open;
10. process the collision array in either case, including the warp cached at
    step 4; this may select `ACT_DISAPPEARED`, but its later delayed-warp
    request cannot replace an uncleared fatal latch;
11. on the useful non-null-retry branch, execute `ACT_DISAPPEARED` in that
    frame, snap State Y to the retry floor, and copy State to Graphics.  On the
    retry-null branch, the floor-null early return defers action dispatch.  A
    later request is blocked if the fatal latch is still occupied; if a clear
    occurs first, the open retail refinement must project it to a reset/init
    barrier that destroys the old continuation, as required by the checked
    event system;
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

The newer Rocq initializer parser reads the actual generated US/JP words,
obtains all 574 vertices and 962 triangle records, mirrors the source-shaped
partition insertion order, and computes exactly 17 wall and 26 floor
candidates in cell `(5,7)`.  Its pure source-shaped evaluator computes all
four static-wall and both static-floor decision lists as all-rejection, then
packages zero-push and `Area1FloorNull`/`-11000.0f` records.  The record is not
an independently executed collision traversal.  Counting its rejection trace derives
`12 + 8 + 5 + 1 = 26`, with the only X/Z-accepted face rejected by the height
buffer.  It also kernel-checks signed-32 intermediate bounds and exact
CompCert-binary32 planes, offsets, roof height, and `-434` buffer result for
the decisive axis-aligned faces.  At `x=-2199`, offset `-50` is accepted and
pushes to `-2099`; at `x=-2200`, offset `-51` is rejected.
The theorem `area1_q_static_all_rejection_checks_computed` exposes the six
decisive computations directly: both wall passes for both versions and the
complete static-floor list for both versions evaluate to all-rejection.

This still does **not** prove a live retail query theorem.  The exact-list
construction/evaluator is not yet refined to Clight-memory execution,
dynamic-list completeness and irrelevance are separate, cast/pointer effects
remain open, and no clean trajectory has been proved to reach `q`.  The point
also lies below the Y=1280 roof, so ordinary falling from above lands on the
roof instead of reaching it.

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

### Can a wall increase the shell's positive Graphics Y?

Not as an additional Graphics-only term in the pinned source.  A wall can
change X/Z, alter the floor subsequently selected, and therefore change the
**absolute** State and Graphics height reached by a shell step.  That is
different from enlarging the Graphics-minus-raw-Object gap needed by Ink's
next-frame fallback:

| Scheduling point | Wall-related effect | Relevant Y-gap consequence |
| --- | --- | --- |
| `update_mario_geometry_inputs` before interactions | Wall resolution changes the State sample's X/Z and can make the first floor query miss | It does not write Graphics Y; under the State-only refinement its direct Graphics-Y delta is zero |
| `perform_air_step` inside `act_riding_shell_air` | Wall resolution changes local `nextPos` X/Z and can indirectly change floor selection; `AIR_STEP_HIT_WALL` clears forward speed and the lava case changes action/velocity | The step copies final State to Graphics and the action executes one `+42`; there is no wall-dependent second Graphics add |
| `perform_ground_step` inside `act_riding_shell_ground` | The same X/Z/floor-selection distinction applies; `GROUND_STEP_HIT_WALL` stops shell riding and selects knockback | Control still reaches `tilt_body_ground_shell`, so this source path executes one `+45`, not `45 + wall bonus` |
| End of Mario's behavior | `copy_mario_state_to_object` copies final State XYZ to raw Object XYZ | Any absolute wall/floor lift is copied to Object too; only the shell visual offset remains as a gap |
| A frame with successful cached upper-warp contact | Warp interaction runs before action dispatch and selects `ACT_DISAPPEARED` in the inspected source schedule | The shell action is not dispatched, so a wall inside that shell action cannot create a new same-frame `+42`/`+45`; only a gap retained from the preceding frame could be consumed |
| Generic behavior tail | If Mario's live `oFlags` unexpectedly contains bit 0, `obj_update_gfx_pos_and_angle` can overwrite Graphics Y with `oPosY + oGraphYOffset` | All stock behavior-data offsets are now checked at `<=240`, so timer 131 requires a non-stock value, alias/lifetime failure, or another writer |

The Rocq theorems
`abstract_state_only_writer_has_zero_graphics_y_delta` and
`abstract_wall_or_floor_selected_height_cannot_enlarge_shell_gap` prove the
first and fourth distinctions in the handwritten three-view model, for an
arbitrary wall/floor-selected State height.  The latter still ends with a gap
at most `45`.  `riding_shell_offsets_do_not_accumulate_across_normal_frames`
threads two such abstract frames and reanchors the second one.  None of these
theorems is yet the missing live Clight pointer/dataflow refinement.

The Rocq theorem `shell_graphics_y_offsets_fit_dry_audit_bound` checks
`42 <= 45` and `45 <= 45`; the US/JP source kernel pins the two binary32
literals in `act_riding_shell_air` and `tilt_body_ground_shell`.  Those
occurrence checks do not prove the destination field, exact binary32 delta for
arbitrary inputs, shell reachability, or a complete interaction/action census
for every clean retail frame; the field/formula interpretation comes from the
separate pinned-source audit.

In fact, “the endpoint moved by at most the source operand” is false for
unrestricted binary32 inputs.  A binade crossing gives checked deltas of
`42.00006103515625f` and `45.00006103515625f` for concrete inputs near Y=979.
`shell_binary32_endpoint_delta_can_exceed_source_operand` proves the exact
CompCert bit patterns.  Those two witnesses themselves are small; they do
**not** prove a general upper bound on arbitrary binary32 endpoint
differences.  The route-specific proof is intentionally split:
`ShellUpperWarpFloat32DeltaArithmeticObligation` asks for exact `42`/`45`
endpoint differences when Y is in `608..818`, while
`ShellUpperWarpFloat32LiveRangeRefinementObligation` is a
predicate-parameterized schema.  It becomes a live US/JP obligation only when
instantiated with a concrete linked shell-frame predicate that must derive
that range.

The handwritten integer normal-frame model expresses an intended
non-accumulation property under its explicit reanchor transition.  Its
two-step theorem threads the first frame through an arbitrary State-only
interframe write; the second abstract shell step then replaces the prior
Object/Graphics views from current State and installs one 42/45 gap.  This is
a property of that handwritten transition, not a proof that Clight takes it.
Separate generated-AST receipts put each shell step before its fixed source
literal.  The moving dispatcher
calls `mario_update_quicksand` before its ground-shell case, and the callee's
riding-shell branch assigns binary32 zero to `quicksandDepth`.  The airborne
dispatcher similarly runs `check_common_airborne_cancels`, whose continuing
path assigns binary32 zero before selecting the shell-air body.  These source
paths are the expected reason negative depth cannot amplify the normal `+45`
and `+42` writers.  Generated-AST receipts check the assignments and call
order, but linked branch/dataflow execution remains open.  In the wall loop, accepted walls
mutate only the collision record's X/Z.  The `f32_find_wall_collision` wrapper
copies X/Y/Z back through its caller pointers, but its Y value is the unchanged
input record field.  The audited shell step calls use a local `nextPos`, and
the interaction push uses State Y plus local X/Z; neither directly passes
Graphics.  A wall can still be a **schedule enabler** by changing X/Z or making
a later floor query miss.  It is not, in the audited source, a positive
Graphics-Y writer.  Generated receipts do not yet prove all call arguments,
pointer disjointness, or every caller.  The
abstract State-only relation can preserve an existing gap but cannot enlarge
it.  Pointer aliasing, the exact call arguments, every caller, and binary32
small-step execution remain open.  Direct source inspection says that if
cached warp contact succeeds, interaction processing selects
`ACT_DISAPPEARED` before action dispatch.  The small abstract selector records
that expected control result, but the generated receipts do not yet prove the
indirect dispatch and break/dataflow path.
The interaction table orders `INTERACT_WARP` before `INTERACT_KOOPA_SHELL`,
and direct source inspection finds that the loop stops after a successful
handler.  On that source-level path, simultaneous raw warp and shell collision
processes the nonfading warp first and never reaches the shell handler.
Generated initializer receipts check the table subsequence and named bodies;
indirect-call and break/dataflow execution remain open.
Inside `act_riding_shell_ground` itself, `GROUND_STEP_HIT_WALL` changes the
next action but control still reaches `tilt_body_ground_shell`.  Direct source
inspection therefore gives that frame one `+45`, not an extra wall-dependent
addition, and shows the next non-shell action re-synchronizing through its own
step/action path.  The occurrence/order receipts do not yet prove that path as
a linked Clight execution.

One compiled-semantics caveat precedes the ground `+45`: the tilt helper makes
float-to-integer casts used for body angles, and the source flags a possible
speed crash when their intermediates reach signed-32 limits.  Positive shell
speed is capped, but backward “shell hyperspeed” is not.  A total theorem must
derive a reachable speed/yaw bound or model the retail compiled behavior
directly.  This cannot enlarge the Graphics-Y add; it can instead make an ISO
C/Clight execution fail to represent the retail path before that add.  The
air-shell body has no analogous cast before `+42`.

## Writer census and its formal boundary

The source audit found no stock clean-SSL-Area-1 writer that independently
moves Mario Graphics by the required amount:

- normal ground, air, stationary, pole, hanging, and tornado action helpers
  synchronize Graphics from State inside the action handler, before the
  unconditional post-action sink can break equality;
- shell rendering contributes `+42` in air or `+45` on the ground;
- the large full-XYZ anchor writer is used by Chuckya/King Bob-omb anchoring,
  neither of which belongs to stock SSL Area 1;
- the `bhvMario` script ORs bit 8 and does not itself introduce
  `OBJ_FLAG_UPDATE_GFX_POS_AND_ANGLE` bit 0;
- allocation initialization and SpawnInfo setup occur before `init_mario`,
  which synchronizes State, Object, and Graphics; and
- a stale `gMarioPlatform` pointer writes State, not Graphics.

The retail debug callback contains a controller/page/config-guarded relative
spawn path.  Its generated body is now visible, but clean live execution has
not yet proved the guard false.  It is therefore an explicit spawn-closure
obligation rather than silently omitted behavior.

The generic behavior-interpreter tail is another important model boundary.
If the Mario object had bit 0 set, `obj_update_gfx_pos_and_angle` would replace
Graphics with raw Object position plus `oGraphYOffset`.  Retail allocation
clears the raw-data words, `bhvMario` only ORs bit 8 and has no offset command,
and the corrected bilateral census finds no flag/offset writer anywhere in
the recursively closed ordinary direct-call graph of Mario's three callbacks,
including literal writes through alternate raw-data union views.  The
complete behavior-data decoder now proves more: all 40 commands targeting the
offset field are fixed values no larger than `+240`, below the generic `+632`
timer-131 threshold.  It also checks an exact non-stock counterstate: bit 0
plus `oGraphYOffset = 1160` puts Graphics at a timer-131 accepted point over
the warp-center Object.  The project does not yet link the benign stock facts
through allocation, slot reuse, interpreter execution, and all live mutations;
the counterstate therefore identifies the remaining indirect, external,
alias, corruption, and lifetime escape classes rather than a retail route.

`mario_entry_coordinate_sync_source_shape_{us,jp}` checks ordered initializer
and raw-slot syntax anchors.  It is deliberately not advertised as a memory
equality theorem.  The behavior-script interpreter and graph-node spawn
writer are now generated, and the project checks their relevant flag/write
shapes.  Exact entry call execution, allocation/non-aliasing, and live memory
equality remain open.

The remaining source-to-semantics work is to replace
`Area1InkWriterCoverageObligation` with a concrete linked-run relation under
which every reachable clean no-A Area-1 position transition refines to the
audited State-only, synchronization, or bounded-Graphics writer relation.  The
related entry-memory equality and action/spawn closure must also be proved.
`area1_ink_writer_coverage_schema_is_predicate_sensitive` exhibits both
accepting and rejecting instantiations of the current schema.

## Entry-memory boundary

`EntryMemory.v` now computes and proves the relevant generated US/JP layouts:
`MarioState` is 200 bytes, `Object` is 608, and `Controller` is 28.  It checks
State position at offsets `60/64/68`, raw Object position at `160/164/168`,
Graphics position at `32/36/40`, throw matrix at `80`, action fields at
`12/24/26/28`, quicksand depth at `192`, and controller down/pressed at
`16/18`.

Its concrete CompCert-memory postcondition implies:

- State, raw Object, and Graphics carry the same three `float32` values;
- action is `6450` and action state/timer/argument are zero;
- XYZ velocity, forward velocity, and quicksand depth are positive zero;
- `framesSinceA` and `framesSinceB` are 255; and
- the throw-matrix pointer is null.

This closes layout and projection, not execution.  The named US/JP obligations
still have to execute `init_mario_after_warp` from a valid retail predecessor
and derive those loads.  That bridge includes level-script/segmented-address
semantics, object allocation and non-aliasing, the nonzero incoming-action
guard, destination warp identity, floor initialization, and external frame
conditions.

The controller model was repaired at this boundary.  `read_controller_inputs`
runs before the area warp, so the same residual frame already has a live
`buttonPressed`.  Clean entry now carries the current down word, the actual
previous-down word, and the pressed word related by the source edge formula.
It does not equate current and previous merely to force no edge; the no-A
hypothesis must test the live pressed bit.

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
6. construct an exact no-extra-definitions link over the now-imported
   `behavior_script.c`, anchor the run to a clean `update_objects` frame, certify the concrete
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
9. construct the linked US/JP refinement proving that the concrete
   accepted-fatal state and every subsequent scheduler interval project to
   `RetailFatalLatch.v`, including the clear-to-reset barriers and latch-memory
   frame condition; and
10. continue to a target collision and newly set Act 3 or Act 6 bit.

`Area1InkPrestateReachabilityObligation` is the legacy schema marking the
missing constructor, not a concrete reachability proposition.  No reachable
clean constructor and no retail target-bit counterexample was found.  The
ultimate theorem remains unproved.
