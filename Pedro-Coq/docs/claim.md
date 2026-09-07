# Claim and theorem boundary

## Active ultimate claim

For `VERSION_US` and `VERSION_JP` only:

> It is possible to enter a Pedro spot formed by the Tic Tock Clock cogs at
> suitable rotations, then manipulate RNG while Mario remains in that spot,
> keeping the relevant cogs frozen.

This is `bhvTTCCog`, whose RANDOM branch can select zero target speed. Exact
cog yaw preservation is the target. The older spinner results below concern a
different object behavior and do not establish or refute the cog claim. The
previous every-stock-spot claim is outside the current scope. See
[`ttc-cog-plan.md`](ttc-cog-plan.md) for the execution plan.
The [gameplay restrictions](goal.md#gameplay-restrictions) require legal
controller input and prohibit ACE, corruption, cheats, and arbitrary changes
to game memory or code throughout discovery and validation.

## What the checked capstones prove

`MainTheorem.checked_ttc_cog_local_mechanism_us_jp` combines five distinct results:

- Exact generated US/JP cog inventory and a pairwise geometry certificate:
  hexagonal cogs 0 and 3, yaw 57344 and 0, query `(1330, -1025)`, floor height
  -2088 and ceiling height -1934. The gap is 154 units and passes the ceiling
  query buffer check. Full collision-query selection and entry are open.
- The exact generated `bhv_ttc_cog_update`, approach helper, `random_sign`,
  and both nested `random_u16` calls have a silent Clight big-step under
  explicit symbol, composite-layout, and memory premises. Starting with RANDOM
  mode, direction +1, speed/target +0, yaw 57344, and seed 16, the update returns
  with unchanged yaw, zero speed/target/yaw velocity, and seed 54874. There is
  no assumed callee execution, but the initial memory is not proved reachable.
- A separate exact recurrence calculation shows that four draws from seed 18
  reach seed 4409, changing an isolated pair of cog target selections from
  failing to keep both targets zero to keeping both zero. The selected cogs
  are not consecutive in the real schedule. This calculation proves neither
  accepted dust production nor an actual frame schedule or repeated stasis.
- A finite direct-dust syntax inventory in the generated moving/airborne units,
  a no-write execution of the ground-gap suffix, checked structure offsets,
  and the generated slide-kick sliding caller's wall-stop dust request. The
  caller retains seven actual-helper execution premises and conditional
  preservation at their boundaries. These are not a reachable in-spot event
  or an exhaustive proof about all preserving RNG sources. See
  [the exact slide-kick boundary](ttc-cog-slide-kick.md).
- Complete direct-RNG, computed-call and particle-field-write syntax coverage
  in 41 generated units per version, all 18 Mario particle table entries,
  and a full generated NONE-mode environmental update with both real callees
  and identical memory. Source-token/include coverage is separately checked
  against the pin. Runtime linkage/aliasing, TTC environmental entry premises,
  action preservation and accepted particles remain open. See
  [the all-RNG boundary](ttc-cog-all-rng.md).

`checked_ttc_cog_source_geometry_us_jp` exposes the geometry component alone.
`checked_ttc_cog_dust_action_frontier_us_jp` exposes the new action component.
`checked_ttc_cog_rng_source_frontier_us_jp` exposes the expanded source and
environmental execution component.
None of these cog capstones is the requested gameplay theorem.

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
It also proves a concrete collision certificate for pitch values 15,664 through
16,031 and includes the random-mode timer/direction model.

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

`checked_dust_frontier_reductions_us_jp` adds three narrower results at that
boundary. First, the exact generated scalar `random_u16` function has a real
CompCert big-step from a writable zero seed cell to return/store `57460` in
both supported versions. Second, generated TTC level-script and loader receipts
count 110 macro descriptors, 9 area object descriptors, and Mario; this is a
source inventory and nominal 120-slot headroom calculation, not a simultaneous
live-pool theorem. Third, arbitrary certified interference is represented
exactly: two dust pairs contribute four calls and a non-dust count `k` gives
`R^(4+k)(seed)`. The generated prefixes before spinner 0 and spinner 7 have
conditional conservative non-dust bounds of 80 and 94 calls, respectively.
The live snapshot and no-unaccounted-call premises of those bounds are retained.

`checked_dust_linked_runtime_census_frontier_us_jp` combines three stronger
evidence areas in four conjuncts, still carefully separated:

- a typed official CompCert link and an actual generated-Clight big-step for
  one WhitePuff2 `cur_obj_update` dispatch cycle in US and JP, including
  opcode fetch, `BehaviorCmdTable[12]`, the indirect `CALL_NATIVE`, native loop,
  random X/Z translation, two nested `random_float`/`random_u16` calls, seed
  `0 -> 57460 -> 55882`, the X/Z stores, cursor advance `20 -> 28`, and the
  genuine CONTINUE branch;
- a complete 240-slot debug-replay pool boundary with reserve 116, a clear
  active-dust bit, a dust request, and normal time; and
- a fail-closed static TTC RNG census plus a ten-call dynamic `F`/`F+1`
  receipt. Each observed frame has one list-2 Bob-omb call and four dust-owned
  calls, with exact contiguous call indices and seed transitions.

`DustParentBitClearExecution.v` adds a generated-Clight big-step for the US/JP
`bhv_cmd_parent_bit_clear` handler under explicit arbitrary-`genv` symbol,
layout, and memory premises. The handler follows the Mist spawner's parent,
masks value 1 (bit zero) from Mario's raw-data word at byte 224, proves the
result has that bit clear, and advances the behavior cursor `4 -> 12`;
typed-link instantiation remains open. `checked_static_terminal_frontier_us_jp`
pairs the static TTC
census with a complete four-instruction retail receipt for `sqrtf`: the US
and JP leaves are `jr ra; sqrt.s f0,f12; nop; nop`, with no recognized nested
call or store.

`checked_spawn_particle_caller_and_segmented_boundary_us_jp` promotes the two
previous draft obligations into one checked main capstone. Its first two
conjuncts execute the exact generated US and JP `spawn_particle` accepted
branches: the clear guard succeeds, raw-data word 22 is ORed with mask 1 (bit
zero), and the generated calls use Mario, model 142, the supplied behavior
pointer, and the returned particle pointer. Each regional claim also includes
the exact table receipt that names `bhvMistParticleSpawner` for the dust entry.
The allocation and copy callees remain explicit `eval_funcall`/preservation
premises. Its third conjunct proves, from the exact US/JP generated first
expression, that standard 32-bit CompCert preserves a
symbolic `Vptr` through the pointer-to-unsigned cast and therefore cannot
evaluate the following integer shift in `segmented_to_virtual`.

The theorems retain the critical qualifications: the Clight executors start
from explicit memory images, the replay origin is proved non-stock, the
observed TTC setting is SLOW rather than RANDOM, and the observed Bob-omb
address bridge is a checked projection rather than a proved
source/linker/retail refinement. The `sqrtf` byte theorem is a finite opcode
receipt, not a MIPS semantic contract for CompCert's declared external.

These are reduction theorems, not relabeled versions of the ultimate claims.

## What is not proved yet

- The relevant Clight paths execute from a reachable retail state.
- Every stock Pedro spot has been enumerated from retail collision data.
- Each stock spot admits the flat-floor/no-slope-acceleration premise used by
  the arithmetic tap, or has a separately proved slope-aware tap.
- The linked Clight proof reaches one real WhitePuff2 `cur_obj_update` dispatch
  cycle, but not the following `ADD_INT`/`END_REPEAT`, function tail, object-list
  scheduler, Mario particle dispatch, Mist script dispatch, Puff allocation and
  initialization, or WhitePuff1 path. The `spawn_particle` caller and
  parent-bit-clear handler are now conditionally executed in arbitrary
  generated-compatible `genv`s, but neither is yet reached from that full
  scheduler execution.
- A reachable tap has not been shown to start with the dust bit clear or to
  retain at least three reserve units after every competing allocation.
- The finite pool and exact `F`/`F+1` receipts use debug level-select entry and
  SLOW mode. A controller-only stock TTC/Pedro/RANDOM-mode certificate has not
  instantiated the DEFAULT/UNIMPORTANT gap or the conditional 80/94-call
  spinner-window bounds.
- The selected Clight call closure terminates at declared-external `sqrtf`.
  Its authenticated retail leaf has no recognized nested call/store, but no
  theorem yet gives MIPS semantics to that external or refines authenticated
  retail addresses/traces to the linked CompCert memory image.
- A Mario entry state reaches the proved TTC spinner Pedro geometry.
- A finite controller/RNG schedule preserves that geometry interval on random
  mode.

The fixed-point certificate now covers pitches 15,664 through 16,031.  It can
contain one selected 200-unit movement: from pitch 15,864, direction `-1`
reaches the lower endpoint.  It cannot support a complete random-mode run,
however.  After the pause through timers 1--5, the next two movement frames
reach `pitch + 400 * direction`; `no_dust_tap_schedule_keeps_this_interval`
proves that value is outside the 368-unit interval for either legal direction,
regardless of RNG draws.  A multi-interval or moving-position witness is still
required.

Those obligations remain visible in `docs/checklist.md` rather than being
packaged as assumptions whose names restate the conclusion.
