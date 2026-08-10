# JP first Area-2 platform apply

This note fixes the control-point boundary for the proposed Japanese-version
stale-`gMarioPlatform` spawning displacement.  It also separates two questions
that must not be collapsed:

1. how a useful Area-1 platform pointer could be installed; and
2. what happens to that pointer and its object-pool slot before the first
   Area-2 platform-displacement call.

No clean retail counterexample has been found.  In particular, the successful
boundary fixture begins too late to prove that its injected state can arise in
a stock execution.  The ultimate less-than-one-A theorem remains incomplete.

The source revision used by the project is
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, with `VERSION_JP` selected for
the facts in this note.

## Evidence labels

The labels below are deliberate:

- **Source fact** means a fact read from the pinned decomp or its generated
  Clight AST.  A call or assignment found syntactically is not, by itself, a
  proof that a particular retail execution reaches it.
- **Rocq fact** means a theorem checked by the current project without an
  admission.  Existing syntax recognizers and finite-list lemmas do not imply
  their still-pending linked-memory refinements.
- **Fixture observation** means a result observed with the hash-gated authentic
  JP ROM fixture.  A fixture that writes memory establishes the engine effect
  after that write, not gameplay reachability of the written state.
- **Pending obligation** means that the project has named, but has not proved,
  the required linked-Clight execution or reachability statement.

## Corrected chronology

The true first Area-2 call of `apply_mario_platform_displacement` occurs before
the first controller poll at which the existing fixture observes Area 2.

The relevant normal-frame order is:

1. `play_mode_normal` calls `warp_area`;
2. `warp_area` unloads Area 1 and loads Area 2;
3. `play_mode_normal` calls `area_update_objects`;
4. `update_objects` clears dynamic surfaces and updates terrain objects;
5. `update_objects` calls `apply_mario_platform_displacement`;
6. collision detection and non-terrain object updates run;
7. `update_objects` eventually calls `update_mario_platform`.

This ordering is a **source fact**.  The generated-JP checks in
`JPSlotLifetime.v` mechanically confirm the two relevant direct-callee
subsequences:

```text
play_mode_normal: warp_area ... area_update_objects
update_objects:   apply_mario_platform_displacement ... update_mario_platform
```

Those checks are **Rocq facts about the generated AST**.  Proving the complete
call execution and memory state for a clean delayed warp is still a **pending
linked-Clight obligation**.

The existing successful `AREA2_POST_FIRST_APPLY_STAGED` fixture writes its
pointer and payload
at the first controller poll whose sampled area is Area 2.  By then the
preceding normal update has already executed the warp/load frame and the true
first destination apply.  The injected payload therefore affects the
**second** Area-2 apply.  Its later displacement and upper-trigger consumption
are genuine **fixture observations**, but they do not witness the true first
destination apply.

## Pointer retention before the true first apply

On the candidate schedule, the last ordinary Area-1
`update_mario_platform` is the final opportunity to capture or recapture a
platform owner.  The two intervening change-area frames do not update objects.
On the following normal frame, `warp_area` performs the unload/load before the
destination `update_objects` call.

For JP, the generated `spawn_objects_from_info` body does not call
`clear_mario_platform`.  Neither the generated `load_area` body nor the
generated `load_area_terrain` body calls `update_mario_platform`.  The first
destination `apply_mario_platform_displacement` is earlier than the next
`update_mario_platform`.  These are mechanically checked **Rocq source-shape
facts**.

Consequently, there is no ordinary platform *recapture* between the final
Area-1 query and the true first Area-2 apply.  The raw pointer value can be
retained on the JP path while unloading, free-list operations, allocation,
initialization, and the first terrain-object update mutate the slot to which
it points.  Establishing those statements as concrete memory preservation and
loads on the particular clean run is not a completed whole-program theorem.
`JPFirstApplySourceProjectionObligation` scopes the load/allocation census from
a caller-identified destination `warp_area` entry to the true first apply,
while requiring the projected pre-displacement state there to satisfy
`CleanPyramidEntry`.  `JPFirstArea2PlatformApplyMemoryRefinementObligation`
separately names the pointer/block/payload extraction for the clean run.  A
sound boundary bridge between those views is still required.

## Fresh destination allocation order

The following is the exact source-derived order for a fresh Area-2 load in
which none of the 50 macro records is suppressed by respawn state and no saved
cap object is present.  The list uses one-based allocation ordinals.  Macro
objects appear in packed-file order; the static SpawnInfo objects appear in
the reverse order in which the level script declares them.  The elevator's
first terrain update then creates ten marker balls before the first platform
apply.

| Allocation | Phase | Object |
|---:|---|---|
| 1 | special geometry | `special_level_geo_04` #1 |
| 2 | special geometry | `special_level_geo_04` #2 |
| 3 | special geometry | `special_level_geo_04` #3 |
| 4 | macro #1 | Goomba at `(3263, 778, 3157)` |
| 5 | macro #2 | wooden signpost at `(2196, 640, -3329)` |
| 6 | macro #3 | 1-Up box at `(-3536, 252, -3705)` |
| 7 | macro #4 | Goomba at `(3389, 0, -1978)` |
| 8 | macro #5 | Goomba at `(-3638, 0, 1928)` |
| 9 | macro #6 | 1-Up box at `(-1242, 252, -3957)` |
| 10 | macro #7 | yellow coin preset 2 at `(1873, 0, -3495)` |
| 11 | macro #8 | yellow coin preset 2 at `(1200, 0, -3495)` |
| 12 | macro #9 | circling Amp at `(3056, 736, -3267)` |
| 13 | macro #10 | Goomba at `(3263, 652, 2200)` |
| 14 | macro #11 | Goomba at `(3431, 673, -1373)` |
| 15 | macro #12 | horizontal flying coin line at `(-2, 1774, 2794)` |
| 16 | macro #13 | horizontal flying coin ring at `(2694, 850, -2889)` |
| 17 | macro #14 | recovery heart at `(-400, 1978, -2250)` |
| 18 | macro #15 | yellow coin preset 1 at `(736, 2652, -2250)` |
| 19 | macro #16 | yellow coin preset 1 at `(736, 2546, -2250)` |
| 20 | macro #17 | yellow coin preset 1 at `(1368, 3263, -2250)` |
| 21 | macro #18 | yellow coin preset 1 at `(1368, 3135, -2250)` |
| 22 | macro #19 | homing Amp at `(1621, 3368, -1142)` |
| 23 | macro #20 | homing Amp at `(1621, 3389, 478)` |
| 24 | macro #21 | horizontal coin line at `(-210, 4521, -994)` |
| 25 | macro #22 | Goomba at `(-2100, 0, 3316)` |
| 26 | macro #23 | blue-coin switch at `(-719, 0, 4772)` |
| 27 | macro #24 | hidden blue coin at `(0, 0, 2381)` |
| 28 | macro #25 | hidden blue coin at `(0, 100, 2381)` |
| 29 | macro #26 | hidden blue coin at `(0, 200, 2381)` |
| 30 | macro #27 | hidden-1-Up trigger at `(2064, -81, -1901)` |
| 31 | macro #28 | hidden-1-Up trigger at `(2569, -81, -2022)` |
| 32 | macro #29 | hidden-1-Up trigger at `(2698, -81, -2535)` |
| 33 | macro #30 | hidden-1-Up trigger at `(2698, -81, -3049)` |
| 34 | macro #31 | hidden 1-Up at `(1940, -81, -1360)` |
| 35 | macro #32 | hidden-star trigger at `(-260, 2940, -600)` |
| 36 | macro #33 | hidden-star trigger at `(260, 1967, -600)` |
| 37 | macro #34 | hidden-star trigger at `(-1940, 1229, -600)` |
| 38 | macro #35 | hidden-star trigger at `(-1940, 1229, 2320)` |
| 39 | macro #36 | vertical flying coin line at `(290, 4479, -940)` |
| 40 | macro #37 | wooden signpost at `(-3560, 0, -4065)` |
| 41 | macro #38 | upper hidden-star trigger at `(260, 3913, -600)` |
| 42 | macro #39 | yellow coin preset 1 at `(-260, 2950, -600)` |
| 43 | macro #40 | yellow coin preset 1 at `(260, 1977, -600)` |
| 44 | macro #41 | yellow coin preset 1 at `(-1940, 1239, -600)` |
| 45 | macro #42 | yellow coin preset 1 at `(-1940, 1239, 2320)` |
| 46 | macro #43 | yellow coin preset 1 at `(260, 3923, -600)` |
| 47 | macro #44 | Goomba-triplet spawner at `(3181, 0, 3587)` |
| 48 | macro #45 | 1-Up at `(-3350, 980, -1240)` |
| 49 | macro #46 | 1-Up at `(2870, 1050, -2640)` |
| 50 | macro #47 | yellow coin preset 2 at `(-2047, 1664, 3076)` |
| 51 | macro #48 | yellow coin preset 2 at `(-2047, 1536, 2870)` |
| 52 | macro #49 | yellow coin preset 2 at `(-1840, 1357, 3076)` |
| 53 | macro #50 | yellow coin preset 2 at `(-1840, 1408, 2870)` |
| 54 | SpawnInfo | Act 6 hidden-star controller |
| 55 | SpawnInfo | Act 3 static star |
| 56 | SpawnInfo | high sand-sound loop at `(7, 4317, -708)` |
| 57 | SpawnInfo | middle sand-sound loop at `(7, 1229, -708)` |
| 58 | SpawnInfo | low sand-sound loop at `(1198, -133, 2396)` |
| 59 | SpawnInfo | pyramid elevator |
| 60 | SpawnInfo | low moving pyramid wall at `(1345, 2567, -2307)` |
| 61 | SpawnInfo | middle moving pyramid wall at `(1473, 2567, -2307)` |
| 62 | SpawnInfo | middle moving pyramid wall at `(730, 1927, -2307)` |
| 63 | SpawnInfo | high moving pyramid wall at `(858, 1927, -2307)` |
| 64 | SpawnInfo | Spindel at `(-2458, 2109, -1430)` |
| 65 | SpawnInfo | horizontal Grindel at `(-3362, 0, -1385)` |
| 66 | SpawnInfo | horizontal Grindel at `(-870, 3840, 105)` |
| 67 | SpawnInfo | regular Grindel at `(3297, 0, 95)` |
| 68 | SpawnInfo | upper pole at `(0, 3200, 1331)` |
| 69 | SpawnInfo | lower pole at `(2867, 640, 2867)` |
| 70 | SpawnInfo | fading warp node `0x16` |
| 71 | SpawnInfo | fading warp node `0x15` |
| 72 | SpawnInfo | upper-entry airborne warp node `0x14` |
| 73 | SpawnInfo | lower-entry airborne warp node `0x0A` |
| 74 | Mario | Mario object |
| 75 | first terrain update | elevator marker ball #1 |
| 76 | first terrain update | elevator marker ball #2 |
| 77 | first terrain update | elevator marker ball #3 |
| 78 | first terrain update | elevator marker ball #4 |
| 79 | first terrain update | elevator marker ball #5 |
| 80 | first terrain update | elevator marker ball #6 |
| 81 | first terrain update | elevator marker ball #7 |
| 82 | first terrain update | elevator marker ball #8 |
| 83 | first terrain update | elevator marker ball #9 |
| 84 | first terrain update | elevator marker ball #10 |

The 50-record macro count and the generic LIFO free-list recurrence are already
**Rocq facts**.  The complete 1-through-84 order above is a **source-derived
fresh-load fact** whose execution over linked Clight memory remains pending.
Respawn suppression can remove macro allocations, so this table must not be
used unchanged for a state whose macro respawn bits differ from the stated
fresh case.

If Mario has a saved cap to respawn in the course, one additional cap object is
allocated immediately after Mario.  It is allocation 75, the ten marker balls
shift to allocations 76 through 85, and the fresh total becomes 85.  This
optional branch also has to be selected from the concrete clean-entry save
state rather than silently discarded.

### Why Spindel is depth 63, not allocation 60

In the fresh table, Spindel is allocation **64** and therefore consumes
zero-based free-list depth **63**.  Allocations 60 through 63 are the four
moving pyramid walls.  Any argument that calls allocation/depth 60 “Spindel”
is off by both object identity and indexing convention.

Object-pool slot numbers are a different coordinate again.  “slot 60” means
the 61st `struct Object` storage cell; it says nothing by itself about where
that cell occurs in the current free list.  In the authentic fixture's fresh
destination load, numeric slot 60 is at zero-based free-list depth **7** and
is therefore reused by allocation 8, macro #5, the Goomba at
`(-3638, 0, 1928)`.  That identity and resulting Area-2 object state are
**fixture observations**.

## Why the pre-transition test does not close the hybrid

The fixture's pre-transition mode repeatedly stages a pointer to numeric slot
60 and overwrites that slot's raw platform fields while Area 1 is still
observed.  On the fresh destination load, slot 60 is popped at depth 7,
cleared, and initialized as macro #5.  The staged payload therefore does not
survive in the form used by the successful boundary injection, and the test
does not consume the upper trigger.

That negative result is useful, but it is not an exclusion of the proposed
early-freed pyramid-top hybrid.  The pre-transition fixture does not:

- make slot 60 the live pyramid-top allocation;
- arrange a final top-owned platform capture;
- deactivate the top at the required time;
- execute the top's 30-fragment explosion before the later bulk unload; or
- reproduce the resulting free-list burial depth and replacement identity.

An early-freed top can therefore occupy a different free-list depth and be
reused by a different destination allocation.  The exact top slot, every
subsequent free-list push/pop, and the payload read at the true first apply are
still pending.  The pre-transition result refutes only its own repeated
slot-60 staging schedule.

## Two-layer installer classification

Ink's graphics gap is not a competing final route.  It is one proposed way to
install the Area-1 pointer/payload that the JP stale-slot route would later
consume.

### Layer 1: final Area-1 owner installation

Every candidate must explain what owner the final relevant Area-1 platform
query records, or why that query is skipped:

1. **Ink graphics-retry installation.**  The cached Mario Object overlaps the
   upper warp; the first Mario State floor query fails; a distinct graphical
   position makes the retry select a pyramid-top surface.
2. **State-first installation.**  A three-dimensional State writer makes the
   first floor query select the top, so no graphics retry is needed.  The
   injected `(-1862,67314,-902)` JP boundary now validates this outcome and
   its retained-slot continuation; the clean writer/pointer origin remains
   unproved.
3. **Physical co-location.**  Move or clone the warp to the top, or move or
   clone collision owned by the top to the warp, while preserving the required
   warp and surface semantics.
4. **Post-commit transport.**  After the object warp is pending, a later
   source-backed writer moves Mario onto a dynamic owner before the final
   platform query.
5. **Other-owner installation.**  Capture a different dynamic Area-1 owner
   whose slot later acquires a useful destination payload.
6. **Frozen carry.**  Preserve an older non-null pointer by proving that the
   normal final query is skipped.

No constructor in this Layer-1 list is currently proved reachable from a clean
retail Area-1 entry.  Nor has the project proved linked-Clight exhaustiveness of
the list.

### Layer 2: pointer and slot fate before the first Area-2 apply

Independently of how Layer 1 installed the owner, the first destination apply
must fall into one of these cases:

1. the pointer is null;
2. the US loader clears it;
3. JP retains a pointer to an inactive, unreused slot and reads its retained
   payload;
4. JP retains the numeric pointer but the slot is reused, so it reads the new
   object's initialized/first-updated payload; or
5. the abstract slot remains live in the same allocation epoch, a case that is
   present in the abstract classification but is expected to be excluded by a
   proved complete Area-1 unload.

The null/live/inactive/reused abstract classification and the finite LIFO
counting lemmas are **Rocq facts**.  Connecting a concrete CompCert pointer to
an object-pool slot, allocation epoch, and exact raw payload at the true first
apply is still a **pending obligation**.

## Exact Ink/top timer alignment

For the specific hybrid in which the Ink retry captures the top and the final
Area-1 update both explodes and recaptures the freed top slot, the candidate
schedule is:

| Frame | Pyramid-top action state | Required event |
|---|---|---|
| `F0` | spinning, timer `131` | cached upper-warp interaction; State floor miss; Graphics retry selects the transformed top surface |
| `F19` | spinning, timer `150` | spinning action changes the top to the explosion action; the behavior interpreter resets its action timer |
| `F20` | explosion, timer `0` | top deactivates and creates 30 fragments; its collision must still be selected by the final platform query before the area transition |

The `131 -> 150 -> explode 0` arithmetic follows from the source action change,
timer reset, and ordinary one-step timer progression.  It is a **source-derived
schedule constraint**, not a proof that the Ink State/Object/Graphics split or
the required transformed top floor is reachable.  The earlier home-pose
`Graphics.y = 1791` witness cannot simply be reused: timer 131 has a rotated,
raised top, so the exact binary32 transform, selected triangle, and required
view separation must be recomputed.

The remaining Layer-1 work is therefore narrower than “find any graphics
gap”: execute the timer-131 matrix and surface helpers, prove that the State
query returns null while the Graphics retry returns a live top-owned surface,
carry support through the disappeared-action/delayed-warp frames, and prove
the timer-0 post-deactivation surface selection.  Alternative installers can
avoid the graphics retry, but they must establish the same final owner/pointer
postcondition.

## What remains to settle the counterexample family

The decisive pending work is:

1. prove or refute at least one Layer-1 installer from a clean JP Area-1 entry;
2. execute the exact final top deactivation, fragment allocations, later bulk
   unload, and destination allocations over linked Clight memory;
3. identify the true first Area-2 apply and load its concrete
   `gMarioPlatform`, slot, allocation epoch, and raw transform payload;
4. execute the actual binary32 platform matrix/displacement for that payload;
5. continue the result through retail collision and interaction semantics to a
   target region with no `A_BUTTON_PRESSED` frame; and
6. if a target is reached, continue through collection provenance to a newly
   set Act 3 or Act 6 save bit.

The successful second-apply fixture proves that a staged JP raw payload can
displace Mario out of the upper shaft and consume the upper hidden-star
trigger with zero A edges.  It does not prove any item above.  Conversely, the
failed repeated slot-60 pre-transition fixture does not prove the early-freed
top hybrid impossible.  At present there is neither a retail counterexample
nor a complete exclusion of this family, and the ultimate theorem must remain
reported as incomplete.
