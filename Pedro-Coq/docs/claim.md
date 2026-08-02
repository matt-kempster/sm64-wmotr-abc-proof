# Claim and theorem boundary

## Ultimate claims

For `VERSION_US` and `VERSION_JP` only:

> It is possible to manipulate RNG while in any stock Pedro spot.

> It is possible to enter a Pedro spot formed by the Tic Tock Clock spinners at
> the required rotation, and then manipulate RNG while Mario remains in that
> spot, maintaining the required spinner-angle regime.

The wording "maintaining the required spinner-angle regime" is the
source-faithful formal replacement for "keeping the spinners frozen." Exact
random-mode stasis is not the behavior implemented by
`bhv_ttc_spinner_update`.

## What the checked capstones prove

`checked_pedro_rng_mechanism_us_jp` is an unconditional theorem combining:

- US and JP generated-AST receipts for the Pedro branch in
  `perform_air_quarter_step`;
- US and JP generated-AST receipts for the landing-input and dust-gate control
  flow in `common_landing_action`;
- US and JP generated-AST receipts for the dust particle, white-puff, and PRNG
  source chain; and
- executable CompCert binary32 arithmetic witnesses for all four flat-floor
  deceleration classes.

`checked_ttc_spinner_source_reduction_us_jp` adds unconditional generated-AST
receipts for the spinner speed table, random-mode update calls, behavior-data
links, fourteen stock macro placements, and the 170-element collision stream.
It also proves a concrete collision certificate for pitch values 15,856 through
15,951 and includes the random-mode timer/direction model.

`checked_dust_source_projection_us_jp` combines a CompCert structural-link
witness with the executable, source-derived dust projection. Given an isolated
object reserve of at least three and an initially clear active-dust bit, the
projection decodes and schedules Mist, WhitePuff1, and WhitePuff2, derives the
four dust-owned sites Puff1-X, Puff1-Z, Puff2-X, and Puff2-Z on the tap frame,
and clears the active bit. The first two calls are consecutive in DEFAULT and
the last two are consecutive in UNIMPORTANT. The overall seed is exactly
`R^4(seed)` only when no other object consumes RNG between those phases.

The structural-link witness uses selected generated definitions with a shared
symbol namespace. It is not a complete executable whole-game program: the
slice does not establish a composite-layout refinement, resolve every external,
or supply a Clight big-step derivation. The source-derived scheduler is a
separate executable reduction, and the capstone deliberately keeps that
distinction visible.

These are reduction theorems, not relabeled versions of the ultimate claims.

## What is not proved yet

- The relevant Clight paths execute from a reachable retail state.
- Every stock Pedro spot has been enumerated from retail collision data.
- Each stock spot admits the flat-floor/no-slope-acceleration premise used by
  the arithmetic tap, or has a separately proved slope-aware tap.
- The dust projection has not been lifted to linked Clight big-step execution.
- A reachable tap has not been shown to start with the dust bit clear or to
  retain at least three reserve units after every competing allocation.
- Non-dust RNG consumers between DEFAULT and UNIMPORTANT have not been bounded,
  so an unconditional global `R^4(seed)` result is not available.
- A Mario entry state reaches the proved TTC spinner Pedro geometry.
- A finite controller/RNG schedule preserves that geometry interval on random
  mode.

The current interval itself cannot support that schedule: after a direction
change the spinner pauses through timers 1--5, then moves by 200 at timer 6.
`no_dust_tap_schedule_keeps_this_interval` proves that this first motion exits
the 96-unit certified interval for either direction, regardless of RNG draws.
A wider or multi-interval collision witness is therefore required.

Those obligations remain visible in `docs/checklist.md` rather than being
packaged as assumptions whose names restate the conclusion.
