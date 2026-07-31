# JP timer-131 stale-top lifecycle and first Area-2 apply

This note records a hash-gated original-JP ROM experiment and the
admission-free Rocq facts extracted from it. It closes the explosion,
deallocation, delayed-warp retention, true-first-apply, and upper-trigger
continuation questions **from an injected timer-131 three-view fixture**. It
does not prove that clean retail play can construct the fixture. It therefore
is not yet a counterexample to the less-than-one-A claim.

The source revision is `9921382a68bb0c865e5e45eb594d9c64db59b1af` with
`VERSION_JP`. The probe accepts only the original JP ROM identified by:

- MD5 `85d61f5525af708c9f1e84dce6dc10e9`;
- SHA-256 `9cf7a80db321b07a8d461fe536c02c87b7412433953891cdec9191bfad2db317`.

## Exact injected boundary

The probe enters SSL through the retail level-select path. It performs two
explicit fixture interventions:

1. it writes the pyramid top's pillar counter to four so the retail top
   behavior reaches its spin-and-explode sequence; and
2. when that live top reaches object timer 131, it writes only these position
   views and clears `gMarioPlatform`:

| View | Coordinates | binary32 bits |
|---|---|---|
| Mario State | `(-2200, 768, -1024)` | `(c5098000, 44400000, c4800000)` |
| Mario Object | upper-warp center `(-2048, 768, -1024)` | `(c5000000, 44400000, c4800000)` |
| Mario Graphics | `(-1862, 1778, -902)` | `(c4e8c000, 44de4000, c4618000)` |

The probe does **not** write Mario's action, action argument, `usedObj`, floor,
surface lists, throw matrix, top transform, free list, warp state, or any
Area-2 object. The following retail frame produces all three synchronized
views at:

```text
(-1862, 1783.940186, -902)
(c4e8c000, 44defe16, c4618000)
```

That frame also produces `ACT_DISAPPEARED`, action argument `0x00040001`, the
upper warp as `usedObj`, a top-owned floor, and `gMarioPlatform` equal to the
top. Thus the State miss, Object warp collision, Graphics retry, top surface
selection, and platform capture are mutually compatible for this exact
injected three-view sample.

What remains open is the important part: whether ordinary or glitched clean
Area-1 gameplay can create the three views simultaneously. In particular,
the fixture requires a Graphics-to-warp-center Y gap of 1010 units, or at
least 960 units above the warp's maximum contact height. The experiment does
not supply that gap.

## Source and generated-Clight order

`JPLifecycleTrace.v` checks these generated-JP AST anchors:

1. `act_disappeared` calls `stop_and_set_height_to_floor` before
   `level_trigger_warp`;
2. `bhv_pyramid_top_loop` calls the explosion helper, whose generated body
   calls `spawn_object`, contains the 30-fragment bound, and clears an
   object's `activeFlags`;
3. `update_objects` orders terrain updates, platform displacement, object
   collision detection, non-terrain updates, deactivated-object unload, and
   final platform capture;
4. `play_mode_normal` calls `warp_area` before the destination area object
   update;
5. `warp_area` orders old-area unload, new-area load, and Mario
   initialization;
6. `unload_object` calls `deallocate_object`; and
7. `apply_mario_platform_displacement` reads `gMarioPlatform`,
   `gTimeStopState`, and `gMarioObject`, then calls
   `apply_platform_displacement`; and
8. the Mario branch reaches `set_mario_pos`, whose generated body mentions
   `gMarioStates` but not `gMarioObject`.

These are generated-Clight syntax facts. The executable trace is stronger
than a controller-poll inference, but it is still not a linked Clight-memory
execution theorem.

## Authentic function-boundary receipt

The dirty local decomp map put `apply_mario_platform_displacement` at the
wrong address. A signature scan and raw disassembly of the hash-gated retail
ROM locate it at `0x802c83f0`. The relevant instructions are:

```text
802c83f0  addiu sp,sp,-32
802c83f8  lui   t6,0x8033
802c83fc  lw    t6,-300(t6)       # gMarioPlatform = 0x8032fed4
802c8404  lui   t7,0x8034
802c8408  lw    t7,-16112(t7)     # gTimeStopState = 0x8033c110
802c840c  andi  t8,t7,0x40
802c8418  lui   t9,0x8036
802c841c  lw    t9,-536(t9)       # gMarioObject = 0x8035fde8
802c8434  li    a0,1
802c8438  jal   0x802c80f8        # apply_platform_displacement
802c8448  lw    ra,20(sp)
802c8450  jr    ra
```

The reproducible receipt command is:

```sh
mips-linux-gnu-objdump -D -b binary -m mips:4300 -EB \
  --adjust-vma=0x80245000 \
  --start-address=0x802c83f0 --stop-address=0x802c8460 \
  /path/to/baserom.jp.z64
```

The adjustment follows from ROM offset `0x1000` loading at virtual address
`0x80246000`. Rocq records the 26 exact instruction words and checks their
finite receipt, including the `jal` word and return instruction. That checked
list is evidence about the recorded bytes; it is not a theorem that reads the
ROM file inside Rocq.

## Exact lifecycle and allocation lineage

The watched pyramid top is object-pool slot 61.

| Global timer | Event | Top and pointer state |
|---:|---|---|
| 492 | three-view fixture installed | top active at object timer 131; `gMarioPlatform = NULL` |
| 493 | retail retry/warp frame | all views on top; floor owner and `gMarioPlatform` are slot 61 |
| 513 | explosion and early free | slot 61 inactive at free-list depth 0, list length 109; pointer still slot 61 |
| 514 | first change-area tick | inactive depth 0; pointer and payload unchanged |
| 515 | second change-area tick | inactive depth 0; pointer and payload unchanged |
| 515 | true first Area-2 apply entry | inactive depth 47, list length 156; pointer still slot 61 |
| 515 | apply caller return | Mario State displaced; Object and Graphics still at spawn |
| 516 | first Area-2 poll | all views synchronized; final platform update has cleared the pointer |

At timer 513, the top's retained payload is:

```text
position = (-2047, 1878.071045, -1023)
velocity = (0, 5, 0)
face angles = (0, 488448, 0)
angular velocity = (0, 6144, 0)
```

Mario's State/Object/Graphics coordinates are all
`(-2003.265869, 1924.981323, -791.183044)`, with exact bits
`(c4fa6882, 44f09f67, c445cbb7)`. The observed floor is top-owned even though
the object has been deactivated and put on the free list. This is the concrete
recapture that keeps the pointer through `ACT_DISAPPEARED` and the delayed
warp in this fixture.

Area teardown pushes 131 slots ahead of the early-freed top. The destination
performs 84 fresh allocations before the true first apply:

```text
131 - 84 = 47
109 + 131 = 240
240 - 84 = 156
```

`jp_top_survives_true_first_apply_allocations_at_depth_47` proves the generic
LIFO fact in Rocq. The instruction-boundary probe confirms the concrete slot,
depth, list length, inactive flag, retained pointer, and payload at the actual
retail function entry.

## True first apply and the retail phase split

The debugger callback now stops at the authentic function entry and at the
observed caller return address `0x8029cfc8`.

| Boundary | Mario State bits | Mario Object bits | Mario Graphics bits |
|---|---|---|---|
| entry | `(00000000, 45abe000, 43800000)` | same | same |
| caller return | `(43b6cbe0, 45abe000, c48919af)` | entry bits | entry bits |
| first controller poll | return-State bits | return-State bits | return-State bits |

In printed coordinates the State change is:

```text
(0, 5500, 256)
  -> (365.592773, 5500, -1096.802612)
```

The stale top pointer is still present at entry and return. The platform
function changes only Mario State. Mario Object and Graphics remain at the
spawn until the later Mario update, after which all three views synchronize
and `update_mario_platform` clears the stale pointer.

This proves a real three-dimensional State/Object/Graphics phase split in the
retail continuation **from the injected fixture**. It does not prove that the
upstream Area-1 three-view fixture is clean-reachable. It also records exact
binary32 inputs and outputs, but does not yet replay the floating-point helper
instruction by instruction in CompCert.

## Zero-A continuation to the upper hidden trigger

From the first Area-2 poll, the default continuation holds stick `(-127,-96)`
for 60 polls and then returns to neutral. It never supplies A. The trace
counts zero `A_BUTTON_PRESSED` frames, zero `A_BUTTON_DOWN` frames, and zero
controller polls with A set.

At timer 594 the collision-phase Mario Object sample is:

```text
(43c335e4, 457a9000, c414712a)
= (390.421021, 4009, -593.768188)
```

At timer 595 the upper hidden-star trigger is inactive and the hidden-star
controller counter has changed from 0 to 1. The post-update Mario State is:

```text
(43c3ef84, 4576d000, c41334be)
= (391.871216, 3949, -588.824097)
```

The trigger slot is reused on the next frame, so the controller's monotone
counter transition is the identity-stable evidence of consumption.

This continuation reaches one of the five Act-6 trigger regions without an A
edge. It does **not** consume the other four triggers, spawn the Act-6 star,
interact with the star, or set the Act-6 save bit. It says nothing by itself
about the Act-3 star.

A separate downstream probe under `instrumentation/jp-full-route/` starts from
the same injected timer-131 boundary and extends this result. Its authenticated
zero-A trace consumes all five triggers. A refined B/Z continuation reaches
counter five at timer 945 and spawns the Act-6 star at timer 949 in slot 29
(`0x803405f8`) at `(900,1400,2350)`. At timer 1342 a slide kick overlaps the
star by one vertical unit; at timer 1343 `usedObj` equals the spawned pointer,
the action is `ACT_FALL_AFTER_STAR_GRAB`, and the primary SSL byte changes
`00 -> 20` while every A counter remains zero. Therefore the stronger
continuation proves conditional trigger
exhaustion and star spawn, but still not star overlap or collection. Those
downstream observations are not fields of `JPLifecycleBoundaryTrace`; they
are documented here to keep the current route status explicit.

## A useful negative comparison

The alternate Graphics sample `(-1641,1456,-783)` also makes the retail retry
select a top-owned surface and capture the top at timer 493. It does not
remain supported. By timer 498 Mario is on a static floor at
`(-2519.361572,1280,-1089.895752)` and `gMarioPlatform` is null. At the true
first Area-2 apply, entry and return are both the stock spawn
`(0,5500,256)`, and the hidden counter remains zero.

Thus "the retry selected the top once" is insufficient. A successful
installer must preserve or recapture support through the disappearance
countdown and explosion timing.

## Checked Rocq results and remaining route work

The central checked results are:

```coq
Theorem observed_true_first_apply_creates_state_object_graphics_phase_split :
  trace_after_first_apply authenticated_jp_lifecycle_boundary_trace <>
    trace_return_object_view authenticated_jp_lifecycle_boundary_trace /\
  trace_return_object_view authenticated_jp_lifecycle_boundary_trace =
    trace_return_graphics_view authenticated_jp_lifecycle_boundary_trace /\
  trace_first_poll_synchronized_view
      authenticated_jp_lifecycle_boundary_trace =
    trace_after_first_apply authenticated_jp_lifecycle_boundary_trace.

Theorem observed_boundary_closes_lifecycle_and_upper_trigger_continuation :
  boundary_trace_is_internally_consistent
    authenticated_jp_lifecycle_boundary_trace /\
  trace_after_first_apply authenticated_jp_lifecycle_boundary_trace =
    jp_true_first_apply_after /\
  trace_collision_object_sample authenticated_jp_lifecycle_boundary_trace =
    jp_upper_trigger_collision_object_sample /\
  trace_final_hidden_counter authenticated_jp_lifecycle_boundary_trace = 1.

Theorem conditional_jp_full_route_reaches_spawn_but_not_collection :
  full_route_max_counter authenticated_jp_full_route_observation = 5 /\
  full_route_saw_star authenticated_jp_full_route_observation = true /\
  full_route_saw_star_interaction
    authenticated_jp_full_route_observation = false /\
  full_route_saw_star_dance authenticated_jp_full_route_observation = false /\
  full_route_initial_ssl_star_byte
    authenticated_jp_full_route_observation = 0 /\
  full_route_final_ssl_star_byte
    authenticated_jp_full_route_observation = 0 /\
  full_route_act6_bit_transition
    authenticated_jp_full_route_observation = false /\
  full_route_a_pressed_frames authenticated_jp_full_route_observation = 0 /\
  full_route_a_down_frames authenticated_jp_full_route_observation = 0 /\
  full_route_controller_a_frames authenticated_jp_full_route_observation = 0.
```

These prove finite facts about the exact recorded trace. The following remain
open and block a real counterexample:

- reach the timer-131 three-view sample from a clean JP Area-1 entry by normal
  gameplay or a concrete glitch, without debugger position writes;
- reach the explosion premise without the fixture's counter write, or prove a
  clean source route to the same top lifecycle;
- refine the executable function-boundary trace into linked Clight memory and
  prove the exact binary32 helper execution;
- overlap and collect the conditionally spawned Act-6 star, and show its
  initially-clear save bit becomes set rather than the observed `0 -> 0`;
- separately reach and collect the Act-3 star if this avenue is meant to
  refute both halves of the ultimate claim.

The evidence changes the search priority: the downstream stale-pointer,
allocation, first-apply, all-five-trigger, and star-spawn mechanics work.
Search can now focus on instilling the Area-1 three-view payload and closing
the final star pickup, whether by ordinary motion, Ink's graphical fallback
idea, PU/platform displacement, interaction writers, or another schedule.

## Reproduction

With the authentic JP ROM available locally:

```sh
bash instrumentation/jp-lifecycle/run.sh /path/to/baserom.jp.z64
```

The default run fails unless it hits the authentic entry and return
breakpoints and observes the exact zero-A counter transition. To reproduce the
negative comparison:

```sh
bash instrumentation/jp-lifecycle/run.sh /path/to/baserom.jp.z64 \
  -127 -96 131 60 three-view -2200 768 -1024 -1641 1456 -783
```

Concise milestones are in
`instrumentation/jp-lifecycle/expected-trace.txt`; generated logs stay under
the ignored `build/` directory.
