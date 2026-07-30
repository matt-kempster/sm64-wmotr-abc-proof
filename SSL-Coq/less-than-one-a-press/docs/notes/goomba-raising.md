# Goomba raising and the proposed PU/Spindel route

## Verdict

The regular-Goomba mechanism is real, but neither supplied chatbot response
establishes a stock no-A route in SSL.

The checked result is narrower:

| Question | Result |
| --- | --- |
| Can a primed regular Goomba gain height through a repeating collision cycle? | Yes, conditionally: the modeled H/F/R cycle leaves velocity `21.0f` and updates Y with binary32 `Y + 21.0f`. The position delta is not exactly 21 for every possible float. |
| Is the repeating ready state walking? | No. After the first productive rise it is airborne jump action `2`, with vertical velocity `25.0f`. |
| Does the formal Y `51` orbit rise indefinitely? | Not proved. Rocq exhibits a binary32 fixed point because `2^29 + 21.0f` rounds back to `2^29`, but does not prove that the selected orbit reaches it. |
| Does FAR status itself prevent player collision testing? | No direct FAR guard occurs in the generated player/list/hitbox bodies, but tangibility, list membership, and collision capacity are still required. |
| Does a local Spindel automatically provide the repeated PU shuttle? | No. Collision loading is distance-gated in full-float object coordinates, and a usable platform must be captured again after an ejection. |
| Can the Area-2 singleton at integer Y `778` directly use the audited Spindel height band in the current abstraction? | No. The integer collision band begins at Goomba Y `1961`; linked binary32 collision bounds remain open. |
| Does the audited post-collision H/F/R schedule raise the Area-1 Y `51` singleton to the Y `1791` top floor during the finite spin? | No: its idealized one-hit-per-three-frames bound allows only 31 productive hits. Other schedules remain open. |
| Was a clean US/JP retail counterexample found? | No. |

Chatbot A was right that the state machine contains a useful conditional
primitive, but it overstates literal unboundedness, universal exact-21
position growth, and readiness of the Spindel ejector.  Chatbot B was right to
emphasize PU platform displacement and the stale State/Object phase ordering,
but its conclusion that only TAS construction remained omitted the decisive
same-segment collision capture, physical Goomba transport, repeatability, and
horizontal handoff obligations.

The attached transcript and chatbot responses supplied hypotheses.  All
accepted facts below were checked against the pinned decomp revision and the
generated US/JP Clight files.

## The corrected collision cycle

The one-time setup and the repeating cycle are different.

### Selected priming branch

A regular Goomba begins grounded in walk action `0`, normally with vertical
velocity zero.  The following is the selected branch in which walk action does
not first choose a notice or random jump:

1. A damaging side collision changes the action to attacked-Mario action `1`.
   With no armed upward velocity, the grounded move does not produce the
   desired `+21`.
2. On a FAR update, action `1` calls `goomba_begin_jump`, which writes jump
   action `2`, forward velocity zero, and vertical velocity `25.0f`; movement
   is suppressed by the old FAR flag.
3. Because the old move flags still say on-ground, the next suppressed jump
   action can return to walk action `0` while retaining `25.0f`.

This branch produces the special first productive ready state: walk action
`0`, vertical velocity `25.0f`, near, and not FAR.  Because walk action runs
before attack handling, another branch can call `goomba_begin_jump` first and
may make the initial collision productive.  The project does not claim the
priming branch is exhaustive.

### First productive hit and repeating H/F/R

On the first productive hit, gravity changes `25.0f` to `21.0f` and the active
move updates Goomba Y with binary32 `Y + 21.0f`.  That move changes the
retained movement flags to airborne.  The numeric position delta can differ
slightly from 21 for a non-integral stored Y; for example, the formal audit
found an in-band value whose delta is `21.0001220703125`.  Therefore later R
frames do **not** return to walk:

1. **H — hit and depart.** Collision is cached while Mario's raw object
   overlaps the Goomba. Before the Goomba update, Mario's current object
   position must become more than the Goomba's drawing distance away. The
   attack handler selects action `1`; the still-active movement uses velocity
   `21.0f`; the end-of-update distance test sets FAR.
2. **F — far reset.** Action `1` calls `goomba_begin_jump`, producing action
   `2` and velocity `25.0f`. The old FAR flag suppresses physical movement.
3. **R — near rearm.** Collision detection started too far away to hit the
   Goomba, but Mario ends near it. Action `2` remains action `2` because the
   retained move flags are airborne. Movement is still suppressed, and the
   end-of-update distance test clears FAR.
4. On the next frame, collision detection can cache the next H interaction.

The repeating ready state is consequently action `2`, velocity `25.0f`,
airborne, and not FAR. An earlier draft incorrectly requested action `0` at
this endpoint. The source audit refuted that state, and
`FullFloatHFRShuttleObligation` now requires separate R and next-H collision
phase boundaries so a cached attack cannot coexist incorrectly with an
unchanged action-2 endpoint.

## What Rocq proves

[`GoombaRaising.v`](../../proofs/GoombaRaising.v) proves:

- `goomba_velocity_after_gravity_binary32_checked`: CompCert binary32 computes
  the velocity update `25.0f + (-4.0f) = 21.0f`;
- `goomba_position_delta_need_not_be_exact_21`: a concrete in-band binary32 Y
  witness produces stored delta `21.0001220703125`, refuting a universal exact
  position-delta claim;
- `goomba_binary32_raising_stagnates_at_2p29`: binary32
  `2^29 + 21.0f = 2^29`, exhibiting a fixed point without proving that the
  selected Y `51` orbit reaches it;
- `selected_grounded_hit_branch_primes_without_raising` and
  `selected_priming_far_reset_and_rearm_produce_ready_state`: the bounded
  no-fresh-walk-jump priming branch;
- `first_productive_cycle_enters_repeating_ready_state` and
  `goomba_hfr_productive_cycle`: the first and repeating phase transitions;
- `finite_goomba_productive_cycles`: after `n` repeating productive cycles,
  the deliberately idealized integer-position model is `y + 21*n`;
- `pyramid_top_y51_after_31_float32_rises_checked` and
  `pyramid_top_y51_after_83_float32_rises_checked`: the two selected
  integer-aligned Area-1 computations remain exact in binary32 (`702.0f` and
  `1794.0f`), without asserting an arbitrary-Y recurrence;
- `spindel_capture_imposes_goomba_collision_band`: in the integer hitbox
  abstraction, if Mario's base Y is in the audited conditional Spindel
  interval `[2036,2336]`, overlap constrains Goomba base Y to
  `[1961,2496]`;
- `final_productive_hit_stays_below_2518`: one idealized integer-model final
  hit leaves that station at no more than Y `2517`;
- `goomba_y_778_cannot_overlap_spindel_capture_mario`: the selected Area-2
  singleton cannot use that station directly at its spawn height;
- `pyramid_top_hfr_window_allows_at_most_31_productive_hits`: a 91-frame
  window permits at most 31 productive hits for the specific
  post-collision-return H/F/R schedule;
- `pyramid_top_hfr_window_cannot_raise_y51_to_y1791`: under that schedule,
  `51 + 31*21 = 702`, below `1791`; and
- `eighty_three_productive_hits_are_the_first_arithmetic_crossing`: 83 is the
  first integer hit count that reaches or exceeds `1791` from `51`.

The `[2036,2336]` Spindel floor envelope and the 91-frame top window are
audited inputs to these arithmetic theorems. They are not yet linked
surface-selection, binary32 hitbox/addition, or behavior-timer execution
theorems.  The 31-hit result is not route-exhaustive: a separate pre-collision
raw-Object return schedule is now named as an open obligation and may have
different frame cost.

`goomba_raising_bounded_kernel` exports only the unconditional arithmetic and
finite-model facts. It does not consume any retail reachability obligation.

## Generated Clight coverage

`ClightFacts.v` now computes matching US and JP source-shape receipts:

- the regular property-table prefix contains scale `1.5` and drawing distance
  `4000`;
- `bhvGoomba` references the init and update callbacks;
- attacked-Mario handling calls `goomba_begin_jump`;
- `goomba_begin_jump` writes raw action slot 49 to `2`;
- update case `2` calls the jump action, whose body mentions move-flag slot 25
  and contains an action-0 write.  The receipt does not yet prove the
  `OBJ_MOVE_MASK_ON_GROUND` guard dataflow/polarity; the retail observation and
  missing trace schemas therefore record the on-ground condition explicitly;
- the generated update body has the lexical action/attack/movement call order;
- `cur_obj_move_standard` mentions `activeFlags` and calls `cur_obj_move_y`;
- `cur_obj_update` computes object distance and directly updates FAR status;
- the player collision chain reaches the generic list and hitbox-overlap
  bodies, the caller contains literal `5`, those inspected bodies have no
  direct FAR test, and hitbox position reads use raw binary32 X/Y/Z slots
  rather than signed-16 object aliases.  The current recognizer does not
  couple literal `5` to the call argument; identifying it as the pushable list
  is still a pinned-source audit fact;
- `bhvSpindel` references its init, loop, and collision-loader callbacks;
- the loop writes the pitch-angular-velocity slot and contains the `1024`
  numerator;
- generic object allocation writes exact binary32 collision distance
  `1000.0f` in slot 67; the generated receipt does not itself prove that a
  live Spindel follows that allocation path without a later overwrite;
- moving-collision loading reads full-float object distance and collision
  distance before transformation; and
- vertex transformation uses a float matrix but explicitly narrows transformed
  coordinates to signed-16 `TerrainData`.

These are executable AST/source-shape facts. They do not prove indirect
behavior-script callback execution, live object-list membership, a concrete
FAR branch, or any linked H/F/R frame.

## Why the Spindel proposal remains conditional

The engine bug behind the proposal is genuine. Terrain lookup narrows query
X/Y/Z before spatial-partition lookup and floor testing, while platform
displacement uses Mario's and the platform's ordinary full-float positions. A
rotating platform mistakenly selected at a PU alias can therefore apply a very
large displacement.

That does not by itself build the proposed route:

- Pinned source gives the Spindel the generic default `1000.0f` collision
  distance and `load_object_collision_model` uses full-float object distance.
  The current AST receipt checks the pieces separately rather than proving the
  live branch or absence of an overwrite. A PU-distant Mario does not load the
  local collision merely because terrain coordinates alias.
- The locally transformed Spindel vertices are narrowed to signed-16 terrain
  data and remain in range.  The distinct out-of-range PU query conversion
  still needs the compiled-target refinement tracked elsewhere in the project.
- A large ejection moves Mario away from the loaded platform. The later
  platform query clears or replaces the platform pointer unless a valid
  surface is recaptured. Repeating the technique therefore needs a fresh
  local-load-to-alias capture, not merely one successful ejection.
- Goomba collision is full-float. A local Goomba does not collide with a
  PU-distant Mario through coordinate aliasing. The same singleton must be
  transported physically to the useful PU and, for the proposed pole route,
  transported back or handed to a proven continuation.
- The conditional Spindel collision station has finite height. Even granting
  capture, it is not an arbitrary-height elevator.

The vertical-only `1664 -> 1874` arithmetic from one chatbot is insufficient:
the candidate surfaces are horizontally separated, and
`goomba_begin_jump` writes forward velocity zero. Likewise, later moving-wall
and pole handoffs remain geometric reachability problems, not consequences of
the vertical sums.

## Area 1 consequences

The proposal does not currently construct Ink's graphical fallback:

- Area-1 Tox Boxes update face angles directly rather than the angular-velocity
  fields consumed by platform displacement, so their visible rotation is not
  automatically PU-amplified platform rotation.
- The pyramid top supplies genuine yaw angular velocity, but only for a finite
  scripted interval. The audited post-collision-return H/F/R schedule supplies
  at most 31 productive hits, far below the 83-hit arithmetic minimum from the
  selected Y `51` singleton to the Y `1791` top floor.  This does not yet
  exclude the separately named pre-collision raw-Object writer schedule.
- Mario geometry fallback runs before cached Goomba interactions. A Goomba hit
  therefore cannot create the already-needed Graphics sample on that same
  frame.

This rejects these particular Area-1 constructors. It is not a complete
impossibility theorem for every conceivable Goomba or PU route.

## Remaining named obligations

The module leaves concrete, uninhabited witness schemas:

- `FullFloatHFRShuttleObligation`: one same-allocation, no-A repeating cycle
  with the corrected collision/update phase boundaries and trace-wide no-A
  projection;
- `PreCollisionRawObjectReturnRaisingObligation`: the alternative schedule in
  which a classified raw-Object writer trace changes Object while State stays
  fixed and changes non-overlap to overlap, collision then caches both the
  retail `INTERACTED` and `ATTACKED_MARIO` status bits, the Goomba update
  consumes that cache without moving the Goomba, and a separately classified
  departure-writer trace changes overlap to non-overlap before the
  no-collision upward move;
- `SpindelSameSegmentPUCaptureObligation`: begin after collision is already
  loaded locally and capture the corresponding PU-aliased Spindel platform in
  one linked trace, with the PU gap imposed on Mario Object and State/Object
  synchronized at capture;
- `GoombaParallelUniverseTransportObligation`: transport the same live
  singleton allocation into the useful PU while every projected trace state
  remains no-A in Area 2; and
- `RaisedGoombaToSpindelHandoffObligation`: connect a real collision in the
  pre-hit `[1961,2496]` band to a real loaded/captured Spindel state while
  preserving the live singleton allocation at every projected trace state and
  ending with the same Goomba still in-band and geometrically overlapping.

Every schema additionally requires a functional memory projection and an
external certificate that its listed states cover every modeled frame.  This
prevents sparse endpoints from hiding an A edge or other intermediate frame.
In the H/F/R, pre-collision, transport, and handoff schemas, a trace-wide
live-allocation predicate also excludes deactivation or a slot/epoch change.
In the formal observation, the cached-hit Boolean means the conjunction of
`INTERACTED` and `ATTACKED_MARIO`; geometric overlap is recorded separately.

A complete pole-bypass route would additionally need collision-preserving
transport out of the station, every intermediate horizontal/vertical handoff,
health/invulnerability scheduling, collision-list capacity, and a final pole
escape that continues to a target region without an A edge.

No assumption, axiom, or admitted theorem inhabits any of these obligations.
No clean retail counterexample was found.
