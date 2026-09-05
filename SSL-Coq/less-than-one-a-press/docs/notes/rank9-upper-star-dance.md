# Rank 9 — Upper Act-3 star-dance continuation

## Result

**Parked pending an independently demonstrated no-A elevator escape.**
This is a conditional continuation after Mario is already outside the upper
elevator, not a way to escape it. Even a fully successful continuation would
still leave one A press if Mario uses the ordinary elevator jump. The local
results below remain useful supporting evidence, but do not remove that
bottleneck or establish a zero-A route. Prioritize a clean elevator bypass;
resume this continuation only once that bypass supplies a compatible starting
state, including the required coin history and unspent 100-coin reward.

**Conditional local result.** Starting from a granted airborne coin pickup,
the diagnostic carries the same Mario and star positions through spawning,
the freeze, remaining ground-pound lifts, first star contact, rear-wall catch
and landing. Coq executes the actual star-home Y stores and checks the
Float32 timing; it already executes the caught-floor commit and the caller's
decision to retain the ledge result. The clean arrival, live whole-frame
execution and final Act-3 collection are still missing.

This is Rank **9**, not the Rank-9A proposal to spend the 100-coin star at the
elevator or second pole. Rank 9 assumes an earlier successful upper-gate
crossing and asks how to finish Act 3. It does not supply that crossing.
The work uses ordinary source logic and in-bounds gameplay-glitch arithmetic;
it does not modify game memory or run an emulator.

## Why the rear wall matters

The Act-3 platform has a raised rim along only part of its western edge.
The new candidate uses the wall at X=387, behind that rim at Z=-850. This
allows the lower wall sample to touch the platform while the upper sample
passes above the wall. The ledge routine then looks 60 units through the
wall and finds the flat platform at Y=4815.

All values below are from the checked static diagnostic, starting in the
falling-star action with horizontal speed zero and vertical speed -50.
The starting action, position, speed, and absence of relevant dynamic
surfaces are **granted inputs**, not a recorded game state.

| Point | Position or result |
| --- | --- |
| Before the ordinary geometry-input wall checks | `(340,4700,-850)` |
| After those two checks | `(337,4700,-850)`; first check selects wall 680 |
| Intended first air quarter | `(337,4687.5,-850)` |
| Upper and lower action wall queries | no upper wall; lower wall 680, with no further push |
| Ordinary floor and ceiling | floor 1406 at 4429; ceiling 99 at 5222 |
| Ledge-floor query | `(397,4847.5,-850)` selects floor 1400 at 4815 |
| Successful ledge result | `(397,4815,-850)`, a 127.5-unit rise from the quarter sample |
| Next geometry-input checks | position unchanged; floor 1400 retained |
| Next air quarter | intended Y `4801.7001953125`; lands at 4815 |

Triangle numbers are source-order labels, not live memory addresses.
The wall's exact generated vertices are `(387,4687,-409)`,
`(387,4815,-1125)`, `(387,4687,-1125)`. Floor 1400 is
`(387,4815,-409)`, `(643,4815,-1125)`, `(387,4815,-1125)`.
The destination is strictly inside that floor's horizontal projection.

The diagnostic includes the geometry-input wall checks that occur before
Mario's action, both action wall queries, the ordinary floor, the ceiling
query at **floor height + 80**, the ledge lookup at **quarter Y + 160**,
and the following landing. It preserves source insertion order for walls
and the first-vertex height sorting for floors and ceilings. It does not
replace that sorting with a highest-geometric-floor oracle.

## The finite height window

For fixed initial X/Z=`(340,-850)` and velocity `(0,-50,0)`, the diagnostic
tests all 201 integer initial heights from 4600 through 4800. Exactly
**4678 through 4727**, inclusive, catch the ledge; all 50 then land on the
same platform. Coq checks the same finite interval against the exact
Float32 height inequalities. It is not an exhaustive controller search,
and no claim is made that those are the endpoints for every fractional
height, horizontal position, speed, or live list.

The lower bound comes from putting the upper wall sample above Y=4815.
The upper bound comes from the ledge routine requiring a rise **strictly
greater than 100**, not merely a positive rise. The floor lookup's 78-unit
allowance and the ceiling test also pass. Disabling the ledge flag rejects
the sample, so an ordinary falling ground pound is not interchangeable
with falling after a star pickup.

## A nearby ordinary coin candidate

The stock vertical coin row is at `(290,4479,-940)`. Its second child is
128 units higher, at `(290,4607,-940)`. The generated macro/preset census
identifies this row; the new Coq receipt checks the yellow-coin hitbox and
the actual vertical-offset expression, including its double-to-integer
conversion for child index one.

With standard hitboxes, Mario at `(340,4600,-850)` overlaps that coin.
If the star subsequently samples Mario at this same position, the existing
settled-star arithmetic places it at Y=4845, where Mario at Y=4700 can touch
it. These are **compatible conditional samples**, not a completed
installation. Coin contact does not force the later home-position sample
to occur at the same pose, and there is no proved trajectory from the
coin sample to the falling-star entry.

This candidate avoids needing a transported Goomba coin just to identify a
local resource. It still requires reaching the coin with exactly 99 coins,
preserving its uncollected child, the actual star spawn/home/tangibility
sequence, and arranging the first star contact late enough. A star collected
too early stops the intended movement before the useful ledge window.
The same reward cannot also be spent at an earlier Rank-9A gate.

## What Coq proves

The new [module](../../proofs/Area2Rank9UpperStarDance.v) uses the real US/JP
generated bodies already resolved in the selected programs by
`Area2Rank9AStarSource.v`. Its main execution results are:

- `rank9_fall_enables_the_ledge_check`: the actual falling-star call passes
  air-step argument one, enabling the ledge check.
- `rank9_ledge_commits_same_floor_and_height`: after the position-copy call,
  the actual two load/store pairs take the returned local floor pointer and
  height and record both in MarioState. Their execution preserves the
  action, position, and velocity cells. The writable destinations and
  separate local-height storage are explicit memory premises.
- `rank9_ledge_result_smallsteps`: at the actual post-air-step decision,
  result three skips the landing branch with unchanged memory. It does not
  turn the result into an ordinary hanging action or overwrite the snap.
  The later animation call is **not** covered by this fragment's frame.
- `rank9_wall_and_destination_are_generated`,
  `rank9_fifty_integral_height_samples`, and `rank9_sample_exact_snap`:
  exact generated vertices, a floor-interior destination, the finite
  Float32 height window, and the representative snap arithmetic.
- `rank9_coin_descriptor_and_offset_are_generated` and
  `rank9_nearby_coin_and_star_vertical_window`: the nearby coin's source
  recipe and the conditional contact/settled-height arithmetic above.

`MainTheorem.v` consumes the memory execution and geometry package as
`current_rank9_upper_star_dance_boundary`. This sharpens the transcript's
unresolved ledge stage into exact source program points, memory loads and
stores, wall/floor identities, and test poses. It does **not** construct
`UpperTranscriptAct3ContinuationObligation` or discharge the global
upper-entrance reachability premise.

## The coin/startup timing connection

The new [timing module](../../proofs/Area2Rank9StarTiming.v) and
[`timing.js`](../../instrumentation/rank9-upper-star-dance/timing.js) examine
a **same-attempt variant**: collect the 100th coin in the update that first
starts the ground pound. This is not a claim that the transcript's separate
prepare-star-then-conserve-speed itinerary must use this timing.

The granted arrival need not be rising: ordinary freefall accepts Z, and
ground-pound startup sets vertical speed to -50 regardless of its incoming
value. A controlled descent from a sufficiently high post-gate state is
therefore another candidate predecessor; stored rollout speed is not a
necessary premise of this **local** timing test. Neither predecessor has
been constructed, and the nearby upper row coins must not trigger an earlier
100-coin spawn during the descent.

Coin collisions use the preceding raw Mario-object position. The coin
handler runs before Mario's action, but the newly spawned LEVEL-list star
runs after Mario's PLAYER-list update and `copy_mario_state_to_object`.
Consequently, its home samples **post-action** Mario, not the coin-contact
height. Time stop starts after this update; it does not undo that first lift.
The existing generated list-order/behavior receipts support this scheduling
explanation, but executing the complete linked scheduler remains necessary.

The following sequence has one shared state throughout. The initial
freefall pose, 99 coins, unspent reward and surviving row coin are premises;
they have not been reached from the accepted upper cut by controller inputs.

| Event | Mario / star result |
| --- | --- |
| Coin-contact phase, with Z requesting the first ground pound | Mario `(340,4578,-850)` overlaps the child at `(290,4607,-940)`; 99 becomes 100 |
| Same update's first startup lift | Mario Y becomes 4598; vertical speed becomes -50; startup timer becomes 1 |
| Later star update samples Mario | Home Y becomes 4848; initial star X/Z and home X/Z coincide, so no horizontal flight is needed |
| Star movement while Mario is frozen | After 77 object updates it waits at `(340,4843,-850)`; Mario remains at Y=4598, timer 1 |
| Camera completion clears time stop | This branch does not yet install the hitbox |
| First unfrozen Mario update | Mario rises to 4616; the later star update installs the hitbox |
| Subsequent startup heights | 4632, 4646, 4658, 4668, 4676, 4682, 4686; geometry pushes X from 340 to 337 before the 4646 sample |
| Last missed contact | At Y=4682, Mario's hitbox ends at 4842: **one unit below** the star |
| First star contact | `(337,4686,-850)`, timer 9; the star-fall action retains vertical speed -50 |
| First star-fall quarter | Intended Y=4673.5; wall 680 and floor 1400 produce `(397,4815,-850)` |
| Next update | Lands on floor 1400 at the same position |

The diagnostic performs both pre-action wall checks and the floor/ceiling
queries on **every** startup update. It also tests 61 integer initial
freefall heights: exactly 4570..4619 catch. Camera completion and preservation
of the frozen Mario/star state are granted, not simulated or proved. The 77
updates count the star's own movement, not controller polls or the complete
camera cutscene duration. Other coincident row coins can be picked
up later, but cannot retrigger the already-crossed 100-coin threshold.

### Why collecting the coin later fails in this variant

The settled star is 245 units above the sampled Mario height; Mario's
160-unit hitbox therefore needs another 85 units of rise. If the sample is
taken after the first startup lift, 90 units remain. After the second lift,
only 72 remain, and the later samples leave progressively less. At the
checked base height, all nine coin-collection controls with startup timer
1..9 fail even if every remaining lift is granted: the best late case misses
by 13 units. This closes those **same-startup timing controls**, not routes
using another launch, a moving support, or an independently prepared star.

`rank9t_home_y_executes` executes the actual three consecutive Clight
operations: copy raw Mario Y to star home Y, add the generated 250.0f
constant, then copy home Y to star position Y. It works with Mario and star
in separate subranges of the **same object-pool block**; it does not assume
the two objects have different memory blocks. The output frame protects
every byte range disjoint from the two written cells. The prior home-X/Z
copies, later `sqrtf` and motion, allocator and scheduler are outside this
fragment. `rank9t_orbit_and_first_contact`, `rank9t_timed_contacts_checked`
and `rank9t_late_collection_cannot_use_same_startup` check the Float32 orbit,
contact samples and late-case arithmetic separately; they are not a proof
that the real loop executes the whole diagnostic. The integrated Rank-9
boundary consumes the new memory execution and timing package.

### An arrival shortcut that must not be assumed

The floor under the catch is Y=4429. The nearby Y=4480 shelf, triangles
1404/1405, occupies X=-204..131 and Z=-767..-716. Moving off its east or rear
edge onto the 4429 floor drops only 51 units, below the ground step's strict
100-unit departure test; its ordinary outcome is a grounded snap, not the
freefall needed to reactivate conserved speed. Simply adding a rollout's
stored ascent and 110 units of ground-pound lift to **4480** therefore does
not establish the desired arrival. A front-edge departure, different
support or other ordinary approach needs its actual movement and early
coin-contact checks. The supplied 2013 upper-entry video, rechecked using
its existing contact sheets, collects no coins and does not show this
100-coin timing setup.

## What still closes the route

First demonstrate an independent elevator escape without a new A press and
connect its actual endpoint to the proposed continuation. Starting with Mario
already outside the elevator does not discharge this obligation. Rank 9 is
parked, not disproved: the existing timing and ledge results are retained for
that future connection, but further suffix work is not the current search
priority. A standalone continuation proof would settle only the downstream
subproblem, not the complete zero-A route.

Reach the specified first-startup coin-contact boundary, or another useful
placement, from a useful upper-cut state with zero new A presses and the
necessary 99-coin history. Preserve the nearby coin until the correct
collision phase; the previous frame must not already collect it. Then
realize the diagnostic's wall/list/floor/ceiling choices in live memory,
including any moving geometry,
and connect the position copy, angle calculations, animation, gravity, next
landing, and standing dance. A rollout cannot request a ground pound directly:
the proposed conservation/reactivation must genuinely reach an action that
accepts Z. Adding separate maximum rises is not a substitute for that action
history.

Finally execute a useful departure on the platform and collect Act 3, with
the correct save-bit update. Standing on its flat floor still misses by 75
units; the separate Rank-12B rim-contact sample is another possible final
approach, not a proved continuation from this catch. This tranche does not
change the Act-6 obligations or authenticate an upper-route input movie.

## Reproduction and trust boundary

From the repository root, use the installed proof switch and wrappers:

```sh
SM64_PROOF_SWITCH=sm64-item-proof bash pipeline/build.sh \
  -C SSL-Coq/less-than-one-a-press check-rank9

SM64_PROOF_SWITCH=sm64-item-proof bash pipeline/build.sh \
  -C SSL-Coq/less-than-one-a-press check-rank9-timing
```

From the SSL project directory:

```sh
node instrumentation/rank9-upper-star-dance/check.js
node instrumentation/rank9-upper-star-dance/timing.js
```

The diagnostic reads pinned decompile revision
`9921382a68bb0c865e5e45eb594d9c64db59b1af` and all 1080 vertices/1558 triangles.
Its software Float32 collision reconstruction is diagnostic evidence, not a
verified translation: in particular `sqrtf` is represented by `Math.sqrt`
followed by Float32 rounding. Actual surface allocation, transformed dynamic
lists, live ownership, and query execution remain outside that receipt.

Initial ledge-tranche validation on 2026-09-05: the new module and integrated `MainTheorem.v`
compiled with Coq 8.16.1 / CompCert 3.15. The no-hole and link-hygiene checks,
all eleven focused/boundary/overall assumption audits, the offline collision
regressions, and atlas paragraph/link checks passed. The mesh's Git blob
hash matches the pinned revision (`2a960a73bf6422241927cf5e6647b7b102d79236`).
WSL interrupted the combined target during its audits, so the audits were
completed individually, with unchanged-command retries after service exits;
this is not a claim that one uninterrupted `check-rank9` invocation passed.
The repository-wide discipline audit still cannot build the legacy root
project because its `sm64-proof` switch is absent; the active SSL validation
uses the installed `sm64-item-proof` switch. No project-local axiom was added.

Timing follow-up validation on 2026-09-05: `Area2Rank9StarTiming.v` and the
final `MainTheorem.v` compile; all six `check-rank9-timing` assumption audits
pass, with only the standard foundational/CompCert assumptions. The combined
target built Main and passed no-hole/link-hygiene checks, but WSL stopped
during its second audit; the remaining audits were completed individually.
Both diagnostics and the atlas's three-paragraph/45-anchor navigation checks
pass. The mesh hash is unchanged. The Float32 orbit checker keeps bit patterns
between updates to avoid duplicating large intermediate proof terms; its
successful leaf check uses a 4-GiB cap, while Main uses the standard 6.5-GiB
cap. The final repository-wide discipline audit retains the same missing
legacy `sm64-proof` switch limitation described above.

[Back to Rank 9](../no-a-route-atlas.md#route-rank-9)
