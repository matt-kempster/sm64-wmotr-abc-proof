# Ordinary-gameplay route coverage review

Review date: 2026-09-04.  Return to the
[route atlas](../no-a-route-atlas.md#at-a-glance-ranking).

## Verdict and evidence boundary

The atlas is a broad inventory, **not an exhaustive proof of all no-A routes**.
Its generic writer and collision categories can accommodate new ideas, but
that does not mean their ordinary gameplay instances have been investigated.
This review adds four explicit obligations: a 100-coin-star interruption at a
gate (9A), ground-pound startup combined with moving geometry (10A), target or
secret contact across a barrier (12B), and secret progress across area revisits
(7A).  None is a newly demonstrated controller route.  Their ingredients are
in the selected source; the useful placement, chronology, or reachability is
still missing.

The review uses the project's pinned decompile revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af`, its generated US/JP Clight bodies,
and the existing route notes and receipts.  The local experimental build
checkout is not the authority for stock behavior.  The complete generated
Area-2 collision initializer was compared across versions: both have the same
8,098 words and 1,080 vertices.  The new findings below are **source inspection
and arithmetic, not new Coq theorems or newly executed retail trajectories**.
Existing conditional proofs and finite replays retain their stated scope;
this review does not independently reprove their execution bridges.

Only controller-reachable ordinary behavior in successful, defined, in-bounds
execution is being investigated here.  Existing ACE, out-of-bounds, arbitrary
memory/code modification, DMA, and post-undefined-behavior proposals remain
deferred, outside-model entries.  No method for producing those effects was
developed.  Ordinary deletion, reuse, respawn bookkeeping, collision ordering,
and existing game-controlled references are not automatically outside-model
just because they involve an object's lifetime.

## Coverage map

| Mechanism checked | Atlas disposition | What this review does and does not establish |
|---|---|---|
| Area-1 top activation, warp, platform motion, retry, and later copies | 1–6, 13/13A/13B, 17–21, 25, 26A–26E, 27 | Already explicit; the successful four-pillar trace is one history, not a universal no-go. No new clean installer was found here. |
| B rollout, held-A jump-kick, pole release, ordinary air/ground motion | 10, 11, 24 | Existing bounds remain useful for their actions. Ground-pound startup is a different body, now 10A, not another quarter of the same rollout. |
| Animation changing actual position versus appearance | 10A, 11, 24; retired animation rows | Ground-pound startup and pole/ledge actions contain real position changes. The generic animation-translation helper has only the three door-action callers and `jumbo_star_cutscene_taking_off` in the inspected source, not an arbitrary SSL animation selector. |
| Ceiling hanging and ordinary ledge climbs | 24; lower itinerary 8 | Six hangable Area-2 triangles exist, at Y 957 and 1853. They merit explicit topology coverage, but are not a high ceiling reaching the second-pole ring at Y 3942. |
| Stock enemy damage, shock, moving owners, carrying, and speed sources | 11, 12, 15/16, 22–30 | The Area-2 roster and the existing ordinary-Goomba/Amp audits already cover the obvious actors. A loaded model alone does not install an absent cannon, shell, Tweester, or throwing enemy. |
| Ordinary warps and area reloads | 12A; lower itinerary 8 | Include the two Area-2 fading-warp nodes as well as the upper/lower entrances and the zero-offset Area-2/3 instant warps. Normal alternate entry is not the same question as changing a destination. |
| Star placement, action interruption, and time stop | New 9A; existing 7–9 and 26 | The earlier atlas used the 100-coin star downstream or with negative depth. Using it at the gate is a distinct placement/resource problem. Time stop has separate Mario/object flags; it cannot be assumed to freeze only the desired actor. |
| Object overlap without a terrain visibility test | New 12B | Ordinary contact can be recognized across intervening geometry if the collision cylinders overlap. Reachability of such a pose, tangibility, list capacity, and handler execution must still be shown. |
| Secret deactivation, respawn records, and the hidden-star initializer | New 7A | The initializer reconstructs credit from the number of remaining triggers. Proof coverage must connect that credit to earlier real contacts, not demand five contacts in the current visit. |
| Object allocation and capacity limits | 17, 26B/26D, 31; 7A accounting | Allocation normally succeeds or reclaims an unimportant object; with no reclaimable slot it loops. This is not a demonstrated way to silently omit secrets. The four-contact limit in object collision drops extra contacts, not terrain walls. |
| Star identity, pickup, and save result | 7–9, 12B, 26 | Other SSL stars and the 100-coin reward do not substitute for target indices 2 or 5. A gate-separator theorem remains an obligation, not a condition that can be imposed on every candidate counterexample. |
| Inputs, caps, and earlier starts | 10, 15, 31/32; atlas scope | Held A needs its real predecessor; a later A press is not free. Normal Area-2 entry removes Wing. Castle-origin states remain outside the accepted SSL start unless the boundary is explicitly extended. |

This is a review of named mechanisms, the SSL data, and the relevant action,
interaction, loader, and lifecycle bodies.  It is not an exhaustive traversal
of every live state, every transitive call, or every controller schedule in the
entire game.  A complete no-go still needs the linked coverage obligations in
[route exhaustiveness](route-exhaustiveness.md).

## Rank 9A — Spend the 100-coin star at a gate

Follow-up: the [Rank 9A Coq investigation](rank9a-coin-star-gate.md) now
checks the attached-pole action split, cached-height snap, and immediate
rising-ledge rejection. A descending west-ring setup has consistent local
geometry but no clean star installation or live collision sequence. The
15 individually placed yellow-coin records are all away from the shaft.
The original review below describes the wider route and resource question.

The ordinary coin handler creates the no-exit star when the coin total crosses
100.  Its spawn helper uses star index 6, not either target index.  The spawned
star's normal initial home uses Mario's raw position with Y increased by 250;
the subsequent animation, camera completion, and tangibility timing matter.
It is not a star that can be placed freely at an arbitrary point.

`interact_star_or_key` chooses a no-exit dance, or `ACT_FALL_AFTER_STAR_GRAB`
when the interrupted action has the airborne flag.  That airborne setter
clears forward speed rather than supplying a jump.  The falling action uses
`perform_air_step(m, 1)`, enabling the ledge-grab check.  The ordinary standing
dance instead calls `stop_and_set_height_to_floor` every update.  Therefore
neither the star's visible movement nor its pickup proves that Mario keeps a
pole bonus, gets a fresh upward impulse, or moves through a wall.

This is distinct from the downstream star-dance itinerary: it asks whether
normal coin collection can create a useful interruption **before the gate is
crossed**, possibly with a changing elevator/ledge.  The lower published
itinerary already spends its 100-coin star at the earlier big steps.  Moving
that use to the second pole requires an alternative earlier climb, or a
separate justified way to obtain the required resource again.  An upper-entry
variant likewise must preserve the later Act-3 continuation; the same star
cannot be budgeted twice.  Area transitions and the spawned star's lifetime
must be part of the route.

The first useful experiment is a controller-derived 100th-coin placement and
later pickup while Mario is still on the source side of a gate.  If no such
coin/pose/lifetime combination exists, close that subcase before testing the
interruption.  Otherwise record the action choice, inherited velocity,
floor/ledge selection, time-stop flags, and final target-side motion together.
No useful at-gate placement was constructed in this review.

Source anchors: `f_interact_coin`, `f_interact_star_or_key` in
[US](../../generated/us_interaction.v) / [JP](../../generated/jp_interaction.v);
`f_set_home_to_mario`, `f_bhv_spawned_star_loop`,
`f_bhv_spawn_star_no_level_exit` in
[US](../../generated/us_behavior_actions.v) / [JP](../../generated/jp_behavior_actions.v);
`f_set_mario_action_cutscene` in
[US](../../generated/us_mario.v) / [JP](../../generated/jp_mario.v);
`f_act_star_dance`, `f_act_fall_after_star_grab`,
`f_general_star_dance_handler` in
[US](../../generated/us_mario_actions_cutscene.v) / [JP](../../generated/jp_mario_actions_cutscene.v).

## Rank 10A — Ground-pound startup and moving geometry

The follow-up [source-linked proof and timing audit](rank10a-ground-pound-moving-geometry.md)
now checks the height window and its limits: the normal fifteen-update pause
can reach relative Y=260 in a granted steady-descent scenario, but zeros
sideways speed and does not skip the earlier wall/floor queries. A clean
eligible entry and useful departure remain missing. The simple ten-unit
floor-lag-to-freefall entry is excluded when the actual base is followed.

The startup branch of `act_ground_pound` changes **MarioState Y**, not just
Graphics Y.  For timers 0 through 9, its attempted offsets are
`20,18,16,14,12,10,8,6,4,2`: at most 110 units in total if all headroom checks
pass.  Each addition requires `posY + offset + 160 < ceilHeight`.  During
startup the body does not call `perform_air_step`; it sets vertical speed to
-50 and forward speed to zero.  The ordinary air step resumes in the downward
phase.  This narrow body fact does not say that the enclosing Mario update
performs no other floor/ceiling work.

Meanwhile, the elevator's constant-velocity action lowers it by 10 per
terrain update.  A source-backed question is therefore whether a reachable
startup can gain useful **relative** height while the elevator moves, followed
by a normal interruption, contact, or collision response that lets Mario
depart.  The two motions must be synchronized in a real run; their totals
cannot simply be added to an unrelated rollout maximum.

There are immediate negative controls.  `act_freefall` accepts Z to request
ground pound, but neither `act_forward_rollout`, `act_backward_rollout`, nor
`act_jump_kick` has that direct Z transition.  Finishing the rollout animation
changes its substate, not its action to a freely cancellable fall.  The normal
upper-entry `act_spawn_no_spin_airborne` also has no direct Z cancellation.
Thus “press Z at the checked rollout's apex” and “press Z during the initial
upper drop” are not established entry methods.  A different ordinary
predecessor is needed before the 110-unit mechanism can help.

Close by enumerating reachable cancellable actions and positions on the source
side, then executing every startup headroom check, real elevator phase,
platform update, interruption, and first post-startup collision.  Proving that
none of those predecessors exists is sufficient for that entry family; a
staged ground-pound state is not a route.  The relevant update ordering is
terrain, platform displacement, object collision, Mario/non-terrain updates,
unload, and final platform selection.  Time-stop variants must use the actual
flags in `update_objects_during_time_stop`, not a freely chosen freeze.

Source anchors: the four action bodies and `f_act_freefall` in
[US](../../generated/us_mario_actions_airborne.v) / [JP](../../generated/jp_mario_actions_airborne.v);
`f_act_spawn_no_spin_airborne` in
[US](../../generated/us_mario_actions_cutscene.v) / [JP](../../generated/jp_mario_actions_cutscene.v);
`f_bhv_pyramid_elevator_loop` in
[US](../../generated/us_obj_behaviors.v) / [JP](../../generated/jp_obj_behaviors.v);
`f_update_objects`, `f_update_objects_during_time_stop` in
[US](../../generated/us_object_list_processor.v) / [JP](../../generated/jp_object_list_processor.v).

## Rank 12B — Contact across a barrier, not a prescribed floor crossing

The [source-linked contact and whole-mesh follow-up](rank12b-cross-barrier-contact.md)
now rules out standard contact from either unchanged gate footprint at any
height. It leaves only the highest secret's own platform as a static standing
candidate, checks its 128-unit-thick underside, and finds a positive Act-3
sloped-rim contact sample. None supplies a clean controller predecessor or a
global live-floor projection; the original flat-floor gaps below remain
sample-specific.

`detect_object_hitbox_overlap` compares X/Z distance with the sum of the
interaction radii, checks overlap of the vertical intervals, and checks the
two four-entry contact arrays.  Its sole direct callee in both generated
versions is `sqrtf`: it does not ask whether a wall or ceiling lies between the
objects.  The surrounding collision pass still requires tangible objects and
the right live lists.  Secret triggers then inspect that collision list;
stars use the normal interaction handler.

The relevant route question is whether Mario can reach a contact cylinder
from a source-side neighboring surface or airborne pose **without** passing
the usual elevator/pole separator.  This does not move a star, enlarge a
hitbox, invent a collision, or allow interaction at an arbitrary distance.
Nor does it assume that Mario can move through terrain just because object
contact lacks a visibility test.

The existing standing samples already give two negative controls: the Act-3
star is 75 units above standing Mario's hitbox, and the checked Act-6 sample
misses by 11.  Those are individual samples, not bounds over every adjacent
floor, moving support, or airborne approach.  For Act 6, all five secrets
still need genuine credit, potentially using the revisit bookkeeping in 7A;
collecting an already supplied Puzzle star does not solve its spawn.

Close by comparing each target/required-secret collision volume with the
complete reachable source-side pose set, including same-frame ordering and
nearby floor/ceiling choices.  If an overlap survives, execute the real
contact, spawn/pickup, and save-bit path from the accepted start.  Otherwise
derive the separator theorem from these exclusions.  No qualifying pose was
found or executed in this review.

Source anchors: `f_detect_object_hitbox_overlap`,
`f_check_player_object_collision` in
[US](../../generated/us_object_collision.v) / [JP](../../generated/jp_object_collision.v);
`f_bhv_hidden_star_trigger_loop` in
[US](../../generated/us_obj_behaviors.v) / [JP](../../generated/jp_obj_behaviors.v);
the [target-gap audit](area2-downstream-continuations.md),
[Area-2 quicksand samples](area2-negative-quicksand-star-hypothesis.md), and
[pending lower separator](area2-lower-target-cut.md).

## Rank 7A — Secret progress across ordinary area revisits

`bhv_hidden_star_init` counts the remaining `bhvHiddenStarTrigger` objects.  It
sets the counter to `5 - count`; if the count is zero, it immediately spawns
the ordinary star with the controller's target parameters.  That is a second
normal spawn path in addition to five increments followed by the timed loop.
The trigger loop increments the nearby controller on Mario contact and
deactivates the trigger.  The hidden-star controller has persistent-respawn
behavior; the individual triggers do not.  Ordinary deactivation records the
trigger's no-respawn bits, and the macro loader skips those records on a later
area load.  Mere area unload uses a separate path and is not itself a secret
collection.

Thus the proof needs a **per-secret history**, not five collisions in the
latest Area-2 visit.  A controller route might assemble progress over visits
or combine it with a different support/entry history.  The important invariant
is that every credited missing trigger corresponds to a distinct earlier
real contact in the same scoped run.  A credit without such a contact would
need its own concrete ordinary lifecycle explanation; none is known here.

Two tempting shortcuts do not follow from the code.  The count is a behavior
list traversal, not a distance-to-Mario or camera visibility count, so walking
away does not make an existing trigger count as collected.  The object
allocator reclaims an unimportant object or loops when no such object exists;
it does not normally return success with a secret silently skipped.  The
trigger script is not marked unimportant.  This review did not construct any
capacity-based credit or investigate out-of-bounds continuation.

Close by following the five fixed macro records, each legitimate contact,
deactivation/respawn update, both area unload/load sequences, the controller's
initial count, and either star-spawn path in one execution.  Correct ordinary
bookkeeping cannot turn repeated contact with one secret into five different
secrets.  If every omitted trigger has that legitimate history, revisiting
does not avoid the hard secret; it only changes when the work is done.

Source anchors: `f_bhv_hidden_star_init`, `f_bhv_hidden_star_loop`,
`f_bhv_hidden_star_trigger_loop` in
[US](../../generated/us_obj_behaviors.v) / [JP](../../generated/jp_obj_behaviors.v);
`v_bhvHiddenStar`, `v_bhvHiddenStarTrigger` in
[US](../../generated/us_behavior_data.v) / [JP](../../generated/jp_behavior_data.v);
`f_count_objects_with_behavior` in
[US](../../generated/us_object_helpers.v) / [JP](../../generated/jp_object_helpers.v);
`f_unload_deactivated_objects_in_list`, `f_set_object_respawn_info_bits`,
`f_unload_objects_from_area` in
[US](../../generated/us_object_list_processor.v) / [JP](../../generated/jp_object_list_processor.v);
`f_spawn_macro_objects` in
[US](../../generated/us_macro_special_objects.v) / [JP](../../generated/jp_macro_special_objects.v);
`f_allocate_object` in
[US](../../generated/us_spawn_object.v) / [JP](../../generated/jp_spawn_object.v).

## Existing routes clarified rather than duplicated

The stock Area-2 fading warps connect node `0x15` at `(3070,1280,2900)` to
node `0x16` at `(2546,1150,-2647)` and back.  These are normal alternate
positions, unlike the zero-offset Area-2/3 instant warps.  They are already
part of the lower itinerary and now explicit in 12A.  Neither destination
record itself lands Mario beyond the second-pole ring; the complete
floor/entry chronology still needs execution coverage.

The six hangable triangles use vertices 18–27 of the generated Area-2 mesh:
four are at Y 957 and two at Y 1853, giving ordinary hanging Mario Y 797 or
1693.  `act_start_hanging` accepts continued A-down, not a new A edge, and
`act_ledge_grab` has analog/geometry-based climbs as well as its A branch.
These are explicit subcases of 24 and the known mesh/teleporter prelude, not
an independently discovered upper bridge.  Real ceiling acquisition, every
wall/floor/ceiling choice, the transition off the mesh, and the authenticated
held-A history remain necessary.

Source anchors: [US SSL script](../../generated/us_ssl_script.v) /
[JP](../../generated/jp_ssl_script.v),
[US collision data](../../generated/us_ssl_collision.v) /
[JP](../../generated/jp_ssl_collision.v), and `f_perform_hanging_step`,
`f_act_start_hanging`, `f_act_ledge_grab` in
[US automatic actions](../../generated/us_mario_actions_automatic.v) /
[JP](../../generated/jp_mario_actions_automatic.v).

## Counterexample search priorities

No full clean route currently deserves a high-confidence likelihood label.
The best **new bounded searches** are 9A and 10A: real action mechanisms with
unconstructed entry/placement, now separated from the old negative tests.
12B is a useful next geometry audit.  This order is a research judgment, not
a measured probability or evidence that any new entry already works.

Rank 11 has the strongest demonstrated gate-crossing payoff, but its ordinary
Goomba installer has been excluded in the reviewed source-mesh envelope.
Rank 15 has a real local hand ride but strong height/speed obstructions.  Both
need a specific new controller history, not repetition of their tested setup.
Ranks 1 and 2 retain large conditional payoffs and high theorem value, but no
known ordinary producer; rank 3 is still weaker as a clean installation.
Ranks 7 and 8 remain the strongest continuation work **after** a bypass, not
high-likelihood independent counterexamples.  Rank 7A is chiefly a low-promise
completeness obligation.
