# Slide-kick dust and the remaining RNG-source proof

US/JP only, source pin `9921382a68bb0c865e5e45eb594d9c64db59b1af`.

The sliding phase of a slide kick has a dust-request path even when the
ground step reports a wall stop. The generated Clight caller now has a
conditional execution proof of this fact. It does not yet prove that Mario
can reach this phase inside the cog Pedro spot, remain there through the
helpers and following updates, or cause an accepted particle and RNG draw.
No theorem currently proves or disproves all preserving RNG sources there.

The [execution follow-up](ttc-cog-helper-execution.md) now discharges the
animation setter/end test and sound request from the active caller, leaving
four helper executions and their preservation facts. The original seven-helper
caller proof described below remains available as the composition lemma.

## Original caller proof

The original four components are described here. The active
`MainTheorem.checked_ttc_cog_dust_action_frontier_us_jp` now consumes the
stronger caller and additional layout receipts as well.

1. `MarioDustSources.v` computes the complete list recognized by a finite
   syntax predicate over the generated moving and airborne translation units.
   It finds 11 moving functions and two airborne functions with an explicit
   `particleFlags |= PARTICLE_DUST` form. This inventory is exhaustive for that
   predicate and those two units, not for all effects or all gameplay RNG.
2. `GroundGapReturn.v` executes the actual ground-quarter-step suffix beginning
   at `floorHeight + 160.0f >= ceilHeight`. With queried heights -2088 and
   -1934, exact CompCert binary32 arithmetic takes the return-2 branch and the
   suffix leaves memory unchanged. The preceding collision queries, earlier
   guards and outer ground-step function are not executed by this theorem.
3. `SlideKickDustExecution.v` checks the relevant structure offsets in both
   generated programs, then executes the full `act_slide_kick_slide` caller
   under the seven actual generated-helper execution premises below. Its
   initial input is exactly `INPUT_OFF_FLOOR` (4), so A is clear. The animation
   end test returns false. The ground helper returns 2. Starting with clear
   particle flags at the reflection return, the caller sets vertical-star
   mask 2 and then dust mask 1, ending with mask 3 and returning false.
4. Its two particle-flag stores preserve Mario's X/Y/Z, referenced floor and
   stored floor height. If the seven helper calls also preserve those values
   at their return boundaries, all ten specified memory boundaries have the
   initial values. This is conditional boundary preservation; it does not
   assert preservation inside helpers, of cog yaw, or across another update.

The proof uses `Internal` versions of the mechanically generated functions
and ordinary CompCert big-step rules. It does not substitute helper bodies.
The residual helper calls, in execution order, are:

| Actual generated helper | Required result on this caller path |
| --- | --- |
| `set_mario_animation(m, MARIO_ANIM_SLIDE_KICK)` | A real execution; return value ignored |
| `is_anim_at_end(m)` | Returns false |
| `update_sliding(m, 1.0f)` | A real execution; return value ignored |
| `perform_ground_step(m)` | Returns `GROUND_STEP_HIT_WALL` (2) |
| `mario_bonk_reflection(m, TRUE)` | Completes before the star request |
| `set_mario_action(m, ACT_BACKWARD_GROUND_KB, 0)` | Returns true after the star request |
| `play_sound(SOUND_MOVING_TERRAIN_SLIDE, cameraToObject)` | Completes before the dust request, with the specified terrain/pointer loads |

These execution premises have not been instantiated together in a reachable
cog state. The suffix proof alone does not discharge `perform_ground_step`:
the full function must calculate the intended position using the retained
floor, execute wall resolution and surface selection, and complete its tail.
The stock ground-quarter-step prefix also writes `m->wall`; the no-write
result deliberately applies only to the selected suffix.

The positive caller result has no `forwardVel > 16` gate. A pressed A button
can return before it, and an ended animation with speed below 1 can stop the
slide early. A wall stop changes the action to backward ground knockback
before the dust request, so repeating the same sliding-phase body on the next
frame is not justified.

Reaching the handler also requires the moving-action dispatcher's common
cancellation and quicksand checks. On return, the dispatcher clears dust if
`INPUT_IN_WATER` is set and the handler returned false. Finally, the Mario
particle dispatcher must accept the request with the relevant active bit and
pool reserve. The existing conditional dust-to-RNG results have not yet been
composed with this new caller execution.

## Why the airborne phase remains relevant

Pinned `act_slide_kick` does not directly request dust. On an air landing,
if `actionState == 0` and vertical velocity is negative, it first reverses
half that velocity, sets state 1, and resets the action timer. Otherwise it
selects `ACT_SLIDE_KICK_SLIDE`. Consequently, a slide kick aimed toward the
gap need not immediately enter its sliding phase. The entire bounce/landing
path must be checked for preservation. These observations are source
analysis; the new caller theorem starts at the sliding handler itself.

## Inventory for the broader request

The generated syntax inventory contains the following functions. The gate
column is source analysis at the pin; it is not a proof that a cog state
reaches or excludes that gate.

| Direct dust writer(s) | Local request gate or context |
| --- | --- |
| `push_or_sidle_wall` | Sidling branch and animation frame below 20 |
| `act_walking` | Ground-step result NONE and intended magnitude minus speed above 16; it can also call the sidling helper |
| `act_move_punching`, `act_turning_around`, `act_braking` | Their explicit dust assignment is in the ground-step NONE case |
| `act_hold_walking` | `0.4f * intendedMag - forwardVel > 10.0f` after its step/animation calls |
| `act_decelerating`, `act_hold_decelerating` | Very-slippery floor-class branch |
| `common_slide_action` | Ground-step NONE case; the close-gap wall-stop case does not reach this direct assignment |
| `act_slide_kick_slide` | Tail after its ground-step switch, including the wall-stop case proved above |
| `common_landing_action` | Speed above 16 after acceleration and the ground step, provided its caller did not cancel |
| `act_shot_from_cannon` | Positive vertical velocity at the final dust test |
| `act_flying` | Pitch above `0x800` and speed at least 48 at the final dust test |

A finite source inventory is only the first part of an all-ways proof.
Computed masks, other action translation units, transitive helpers, non-dust
particles, interactions with objects such as Bob-ombs, object updates and
camera effects remain outside this particular inventory. The existing TTC
RNG census has its own stated roots and external-call boundaries. Neither
census supplies the reachable-state restrictions needed to exclude all
other actions or consumers here. Audio randomness also has to remain
distinct from the gameplay seed used by the cogs.

To prove impossibility, quantify over every legal preserving continuation
from an explicitly defined in-spot state, and prove that none creates an
input-dependent difference in the ordered gameplay RNG draws. To prove a
usable option, supply two preserving continuations from the same state with
different draw sequences. A frame containing an ambient RNG call, a particle
request, or approach dust is not enough for either result.

## Completed controller trials

The [receipt](../../instrumentation/ttc-cog-placement/results/slide-kick-discovery.json)
records six US trials and one JP comparison. They use the existing declared
ledge initialization, unchanged behavior functions and read-only observer,
with ordinary controller inputs afterward. Cogs continue their natural RANDOM
updates. These trials do not assume or force a four-frame stationary interval.

Each trial jumps around the mesh using A on frames 76-80, follows the saved
waypoint policy, presses Z at the listed start, and Z+B one frame later.
All runs contain 180 observed TTC frames, complete without observer errors,
and pass the existing call/seed/selected-surface consistency checker.

| Trial suffix | Z frame | Airborne slide kick at Mario-action exit | Sliding phase observed | Pedro returns |
| --- | ---: | --- | --- | ---: |
| `00_us` | 118 | None | None | 0 |
| `01_us` | 122 | None | None | 0 |
| `02_us` | 126 | None | None | 0 |
| `03_us` | 128 | None | None | 0 |
| `04_us` | 130 | 131-160 | None | 0 |
| `05_us` | 132 | 133-162 | None | 0 |
| `04_jp` | 130 | 131-160 | None | 0 |

The US/JP `04` trials agree over all 5,257 normalized observed events. This
compares the same waypoint policy; it is not an exported fixed-input replay.
Dust requests in these traces occur outside any observed Pedro return. In
the trials that reach an airborne slide kick, the sole request from the
button-start frame onward occurs before that kick, at frame 130 or 132.
None supplies an in-spot dust witness. Failed trials do not establish that a
different slide-kick entry is impossible.

The receipt includes exact controller/waypoint rows, ROM/ELF/observer/runner
hashes, trace hashes, event counts and action/dust frame lists. Raw traces and
build outputs remain under ignored `build/cog-placement/`.

## Remaining proof work

- Define and instantiate the actual in-spot Mario state, selected surfaces,
  natural cog phase and permissible controller continuations.
- Execute slide-kick entry and the seven helpers above, discharging the
  preservation conditions instead of assuming them. Check the resulting
  knockback action and the next geometry refresh as well.
- Compose action dispatch, accepted particle creation, the existing dust
  execution/refinement obligations and all intervening object/RNG updates.
- Extend the census to every relevant gameplay RNG source, then give a
  preserving witness or a state-specific exclusion proof for each category.
  Keep exhaustive source coverage separate from gameplay reachability.

Validation uses `pipeline/build.sh check` (including reproducible generation,
proof compilation, no-hole and named assumption checks) and the separate root
discipline audit with `SM64_PROOF_SWITCH=sm64-item-proof`. The new modules are
listed in `_CoqProject`, imported into `MainTheorem.v`, and the new capstone is
included in the `Makefile` assumption target. Passing these checks does not
discharge the explicit residual premises above.

## Verification receipt

All required check components completed successfully on 2026-09-06:

- Final proof rebuild and no-hole check: `build/slide-kick-final-build.log`.
- Two generation passes in an authenticated Linux-local copy: all 56 outputs
  agree with each other and the workspace, `build/slide-kick-repro-local.log`.
- Existing runtime-receipt check: `build/slide-kick-checked-components.log`.
  This checks historical receipt data; it does not run the retired launcher.
- All 12 named assumption checks: standard Coq/CompCert axioms only; the two
  existing schedule theorems are closed. The final caller/layout capstones
  were rechecked after the last proof edit. The per-theorem log map and
  reviewed axiom names are in `build/slide-kick-assumptions-reviewed.json`.
- Separate repository discipline audit: `build/slide-kick-discipline.log`.
- Seven controller-trace checks, one complete US/JP logical comparison and
  input/observer hash checks: the committed experiment receipt above.
- `git diff --check` reports no whitespace errors.

The single mounted-workspace `check` run and a subsequent batch of assumption
checks ended during WSL interruptions, without a reported Coq proof error.
The generation check completed in the Linux-local copy, and individual
pipeline invocations completed the remaining assumption checks. This is a
component-wise verification result, not a claim that the interrupted command
returned success. A measured particle-capstone retry completed in 12.36 seconds
with maximum resident memory 2,468,336 KiB; the precise interruption cause
remains unconfirmed.
