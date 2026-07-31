# JP delayed-warp platform-slot boundary

This note records what the current Rocq development proves about the
Japanese-version raw `gMarioPlatform` pointer during the delayed upper warp.
It does **not** claim a playable spawning-displacement route or a
counterexample to the less-than-one-A claim.

## Why the JP case is different

On the first normal frame after an area change, `play_mode_normal` runs
`warp_area` before `area_update_objects`. Loading Area 2 therefore occurs
before `update_objects`. Within `update_objects`, terrain objects update and
then `apply_mario_platform_displacement` runs; `update_mario_platform` is
later in the same function.

The US `spawn_objects_from_info` calls `clear_mario_platform`. The JP body
does not. Also, `apply_mario_platform_displacement` reads the raw
`gMarioPlatform` object pointer without checking the pointed-to object's
`activeFlags`, `behavior`, or `collisionData`. These facts make a retained JP
pointer a real engine-semantic case that cannot be dismissed as an invalid
abstract state.

The project now translates `src/engine/surface_load.c` for both US and JP.
Consequently, `load_area_terrain` is an internal generated Clight function,
not an unconstrained external call. Its generated body checks the calls that
spawn special and macro objects during destination-area loading.

## Exact classification now proved

The null-inclusive theorem
`clean_jp_upper_platform_cases_are_exhaustive` proves that every clean JP upper
entry has one of four abstract pointer states:

1. `gMarioPlatform` is null; or
2. it points at a live slot in the capture epoch; or
3. it points at an inactive slot in the capture epoch; or
4. its numeric slot has been reused and now has a different epoch.

There is no fifth abstract slot-lifetime case. The proof follows from the
well-formed object-pool invariant in `CleanPyramidEntry`.
`clean_jp_upper_retained_slot_exact_classification` is the narrower theorem for
the non-null `Some platform` branch and proves only the final three cases. This
classification is about the abstract pool model; it does not derive a slot or
ghost epoch from a C pointer.

Path-insensitive recognizers over the generated Clight directly check:

- `unload_object` calls `deallocate_object`, and neither checked body directly
  mentions the `rawData` field;
- `deallocate_object` contains the expected free-list-head read and the two
  assignments used by a head push;
- `try_allocate_object` contains the expected head/next reads and head
  assignment used by a head pop;
- `allocate_object` contains a loop, the literal `80`, and the indexed
  `rawData.asS32 = 0` write shape expected for the clear; these syntax facts do
  not by themselves prove 80 executed writes;
- the Area-2 packed macro list has exactly 50 complete five-word records in
  both US and JP.

The first four bullets do not prove execution order or memory preservation.
In particular, absence of a direct field mention does not by itself prove that
a call preserves the old payload. The linked memory trace below must establish
those effects.

## Corrected control point and finite destination census

The first controller poll that observes Area 2 is **not** the first
destination platform-application boundary.  On the first normal frame after
the two change-area frames, `play_mode_normal` runs `warp_area`, loads Area 2,
initializes Mario, and then calls `area_update_objects`.  The terrain-object
phase reaches `apply_mario_platform_displacement` before the Mario update and
its controller-input read.  The successful fixture write at that first poll
therefore affects the second Area-2 application.  It is useful engine evidence,
but it is not a witness for the true first application.

For a fresh Area-2 load with all listed objects permitted to spawn, enough free
slots, and no saved cap, the source census has 84 successful allocations before
that true first application:

| Allocation | Object(s) |
|---:|---|
| 1–3 | three non-null special-geometry objects |
| 4–53 | fifty macro objects |
| 54–73 | the twenty reversed `SpawnInfo` objects |
| 74 | Mario |
| 75–84 | ten elevator marker balls |

The first spawner pass creates no coin children: the old zero `oFlags` value is
snapshotted before the behavior script installs its distance-computation flag,
so the initialized distance `19000` fails the first `< 2000` test.  A saved cap
adds one allocation after Mario, giving 85 total.

Within the twenty `SpawnInfo` objects, the elevator is allocation 59, the four
moving walls are 60–63, and Spindel is allocation 64.  Thus Spindel consumes
zero-based free-list depth 63, not depth 60.  Its first terrain tick is the
immediate three-dimensional replacement candidate: Z velocity `5`, pitch
angular velocity `256`, and pitch `256`.  Without a saved cap, depths 0–83 are
popped and depths at least 84 remain; with a saved cap, depths 0–84 are popped
and depths at least 85 remain.

These counts are source-backed under the stated fresh-load premises and their
finite arithmetic is checked in `JPFirstApply.v`.  Constructing the ordered
linked-Clight allocation certificate, proving the premises from a clean retail
history, and executing the resulting object payload remain open.

The staged Rocq finite-list recurrence proves that if the watched pyramid-top slot
is freed before a later bulk unload, it is exactly `length bulk` entries deep
in the resulting LIFO free list. The first `length bulk` successful pops take
the reversed bulk list; the following pop takes the watched slot. This turns
the vague `maybe the stale slot is reused` concern into an exact counting
question. A Clight memory-trace refinement still has to connect this recurrence
to the real object list and prove its no-duplicate invariant at each step.

## What this says about the proposed technique

The pinned source suggests that an inactive same-epoch slot can retain the old
object payload because the direct unload/deallocation bodies do not write
`rawData`. The current Rocq result does **not** yet prove that memory effect or
identify the payload at the first Area-2 apply. If the pending memory trace
does establish unchanged stock pyramid-top data, the source path writes yaw
rotation rather than pitch or roll. The existing arithmetic then excludes
only the explicitly Y-preserving stock-yaw family; it is not yet a formal
global exclusion for the inactive slot.

A reused slot is materially different. Allocation zeros the old payload, and
the newly allocated object's initialization and first terrain update may
write new position, velocity, pitch, yaw, or roll fields before the retained
pointer is consumed. A useful three-dimensional payload would have to be
shown in the exact reused object state. This development does not invent such
a payload and does not assert that one is reachable. Nonzero pitch or roll
angular velocity is only one sufficient writer family: a fixed nonzero face
pitch/roll combined with a yaw delta could also change Y.

## Remaining narrow obligations

The concrete refinement tasks now are:

1. Extract the exact Area-1 post-top deallocation order and prove the actual
   early-freed top depth.  Then project the destination source census above to
   an ordered linked-Clight trace.  If the count equals the depth, the watched
   slot is the *next* free-list head; it is reused only when the count is
   greater.  Respawn bytes, pool capacity, cap state, behavior-script indirect
   calls, and every first terrain update must be proved rather than inferred.
2. `JPFirstArea2PlatformApplyMemoryRefinementObligation` (also exposed under
   the compatibility name
   `JPCleanUpperPlatformApplyMemoryRefinementObligation`): given an explicit
   control-point witness that a finite run contains its first destination-area
   entry into `apply_mario_platform_displacement`, extract the linked memory
   evidence there.  Constructing that control-point witness from delayed-warp
   source order is a separate pending task; this premise deliberately excludes
   truncated runs that never reach the call.  The memory evidence must:

   - align that function-entry state with one indexed projected frame and
     prove no earlier entry is reachable on the same run;
   - load `gMarioPlatform` from concrete CompCert memory;
   - prove that the loaded block is the linked `gObjectPool` block and that
     its byte offset is `slot * sizeof(struct Object)`;
   - transfer the mechanically checked
     `jp_spawn_object_size_checked` fact that `struct Object` is 608 bytes in
     the generated JP spawn unit to the arbitrary linked
     `projection_program`; that linked-program size equality remains a
     required evidence field rather than a proved link-layout fact;
   - identify the exact abstract pool element at that slot and match its
     position to the concrete payload;
   - justify the ghost captured/current epoch case from the projected reuse
     history; and
   - prove the concrete loads for position, velocity, face angles, and angular
     velocities.

`JPFirstApplySourceProjectionObligation` supplies the corrected companion
interface for the preload trace: a caller identifies the destination
`warp_area` entry and the true first apply, the projected state at that apply
must be a clean JP upper entry, and the ordered allocation census is complete
only over that destination interval.  This avoids the impossible requirement
that an Area-1 prelude contain no earlier platform applications.  Relating that
preload certificate to the clean-run pointer/payload evidence above remains a
separate boundary refinement.

If the exact count leaves the slot inactive, the remaining payload is the
stock yaw-only top payload only after the pending memory-preservation and
lineage evidence establishes that fact; it is not a conclusion of the current
syntax checks. If the count reuses the slot, the proof must identify the
actual replacement object and its exact 3D payload. A reachable replacement
payload would be a candidate bypass constructor, not yet a route to a target:
it would still need continuation through collision and target collection.

The checked capstone for the work completed here is
`jp_delayed_warp_slot_boundary_checked`. It is compiled and assumption-audited
staging. `MainTheorem.current_verified_evidence_and_collection_reduction`
exposes it only as a separate conjunct on the verification spine, without
claiming a semantic bridge to collection. It intentionally stops before the
two obligations above and before any target-star reachability conclusion.

The existing pre-transition fixture is not a general predecessor test.  Its
numerical pool slot 60 sits at free-list depth 7 in that observed history and
is reused by Area-2 macro object #5.  Allocation clears the fields relevant to
the true first apply; the Goomba velocity/Yaw shown at the later controller poll
was written afterward.  A top that explodes before bulk unload is buried by a
different set of later frees, including its fragments, so this negative result
does not refute the timed Ink-to-early-freed-top composition.
