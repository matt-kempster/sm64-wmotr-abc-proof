# Proof checklist

Checked source-reduction items mean the corresponding recognizer and theorem
have been authored against a pinned-source inspection and passed the pipeline
audits below.

## Active TTC cog target

The active target is `bhvTTCCog` entry, in-spot RNG control, and fixed cog yaw
for US/JP. See [the cog plan](ttc-cog-plan.md). The spinner checklist below is
retained as prior work, and enumerating every stock Pedro spot is outside the
current request.

- [x] Audit the existing capstone statements and identify the cog/spinner
      distinction in pinned source.
- [x] Record the implementation plan and update the goal to the requested cogs.
- [x] Record the controller-only, no-ACE/no-corruption/no-arbitrary-game-edits
      restriction and retire the legacy cheat-enabled emulator launcher.
- [x] Verify that the placement observer uses controller input and read-only
      observation, with loaded instruction checks and cheats disabled.
- [ ] Obtain ordinary save/checkpoint provenance for a normal-entry experiment.
- [x] Review the user-supplied cog video and record its overlays and limitations.
- [x] Run the authorized near-cog placement experiment in US and JP with three
      declared initial setups and stock behavior functions; record failed entries.
- [x] Export and replay the US ledge-to-lower-cog controller sequence, reproducing
      all 2250 input/Mario/cog records from the declared placement.
- [x] Replay that approach independently in JP; compare the complete logical
      event sequence, including all RNG and air-step returns, with US.
- [x] Record the US approach replay as normal-speed and half-speed silent MP4s;
      confirm its complete trace is byte-identical to the verified US replay.
- [x] Review the wall obstruction identified by the user; test a detour with
      a jump around the mesh end and reach its back side in the US placement.
- [x] Export that detour's controller sequence, replay it in US and JP, and
      compare all logical events; keep the zero-Pedro-branch result explicit.
- [x] Export the corrected detour at normal and half speed, verify both videos
      decode and match the recorded frame counts, and inspect the preview.
- [x] Trace source-level floor selection and landing cancellation; record
      [alternative particle-action candidates](ttc-cog-floor-actions.md).
- [x] Observe and check actual close-gap air returns from the `inner_rim`
      test placement in US and JP, including a far-below retained floor and
      the off-floor cancellation path. Keep cog motion and placement premises explicit.
- [x] Compare dive and ground-pound continuations in US/JP; record their
      failure to produce preserving in-spot RNG control.
- [x] Add checked action-path and selected-triangle observations; confirm
      transparency against the earlier inner-rim replay.
- [x] Complete 48 bounded detour/phase/braking/tip searches and retain their
      inputs, observations and [negative receipts](ttc-cog-detour-followup.md).
- [x] Connect the detour to a ground-pound close-gap landing branch in US/JP,
      record its particle requests, and check the complete path's failure to
      preserve Mario/cog state. Do not classify this as a trapped entry.
- [ ] Connect that controller approach to sustained actual close-gap returns
      with the relevant cog poses and Mario state preserved.
- [x] Add a successive-update observation check that excludes supporting-floor
      impacts and ground-pound startup; reject eight recorded full paths in
      both the strict and weaker diagnostic modes.
- [x] Complete 35 further bounded route searches and independently replay an
      ordinary off-floor return in US/JP; record the failure of the following
      update to preserve the Pedro state in the
      [successive-update report](ttc-cog-successive-updates.md).
- [ ] Validate the observation check's acceptance path on a successful
      gameplay trace; no positive witness is currently available.
- [ ] Only after preservation, compare input continuations and their ordered
      RNG draws; then instantiate the linked execution obligations.
- [x] Enumerate direct literal dust writers in the generated moving/airborne
      units (11 and 2 functions) with a finite Coq syntax check for US/JP.
- [x] Execute the generated ground-gap suffix at heights -2088/-1934 and
      prove its return-2 branch leaves memory unchanged; preceding queries open.
- [x] Execute the generated slide-kick sliding caller's wall-stop dust path
      with OFF_FLOOR input, retaining seven actual-helper execution premises.
      Check generated field offsets and prove its own stores preserve the
      position/floor fields, with helper-boundary preservation conditional.
- [x] Run six slide-kick timing trials in US and compare one in JP; retain
      [recipes and negative results](ttc-cog-slide-kick.md). No Pedro return or
      sliding-phase witness; all 5,257 compared logical events agree.
- [x] Execute the generated US/JP sound request for every bounded queue index;
      construct all three stores and prove preservation outside the queue/count.
- [x] Execute the real animation-cache hit, cached slide-kick setter and
      non-ended animation test with unchanged memory and checked field offsets.
- [x] Consume these results in the active cog capstone, removing three of seven
      helper-execution/preservation premises; record the remaining four in the
      [helper execution report](ttc-cog-helper-execution.md).
- [ ] Discharge the remaining four slide-kick helper execution/preservation premises and execute
      the dispatcher, entry/bounce path and following knockback update in the
      actual cog state. Account for downstream dust clearing and acceptance.
- [x] Generate all seven Mario action groups, interaction, camera, environmental
      effects and supporting dialog/geometry units for US/JP: 41 units each.
- [x] Prove structural coverage and exact lists for 282 direct RNG sites,
      16 computed-call callers and 53 particle-field writers per version.
      Retain runtime indirect resolution and aliasing as semantic obligations.
- [x] Decode and check all 18 Mario particle rows plus their terminal sentinel;
      prove source table-selection coverage for arbitrary request masks.
- [x] Authenticate all 81 pinned RNG-bearing C/header files and their
      generated-unit include coverage, with hashes of all 82 generated files.
- [x] Execute the real NONE-mode environmental update and both real callees,
      proving identical memory under the stated global-value/binding premises.
      Separately check TTC's geometry callback argument zero.
- [ ] Prove preserving RNG possibilities or exclusions for a precise legal
      in-spot state family, using the [expanded inventory](ttc-cog-all-rng.md).
      Resolve indirect targets, native/script spawns, TTC environment entry,
      the runtime table/allocator and all ordered draws. Source coverage alone
      does not discharge these execution/preservation obligations.
- [x] Review the repeated content notice and record the known facts,
      uncertainty and [continued gameplay scope](content-notice-review.md).
- [x] Replay the back-of-cog jump attempt with internal call tracing; record
      its failed entry and passing recurrence/continuity check.
- [x] Compare the US/JP back-of-cog and edge traces after normalizing addresses;
      check every recorded RNG transition and air-step branch classification.
- [x] Generate both stock cog collision arrays for US and JP.
- [x] Check cog macro placements, preset mapping, behavior, and update order.
- [x] Certify a concrete pairwise cog floor/ceiling geometry witness in Coq.
- [x] Pin the exact zero-target RANDOM branch and yaw-update ordering.
- [x] Execute the generated zero-speed cog update and approach helper, including
      both RNG calls, under explicit function/layout/memory-image premises.
- [x] Search the simplified consecutive-pair RNG model with fixed non-dust
      consumer counts 0 through 8; distinguish its finite result from gameplay.
- [ ] Instantiate the actual intervening-object schedule for cogs 0 and 3.
- [ ] Obtain a legal US/JP entry replay and both preserving input choices.
- [ ] Trace the landing cancellation path at a successful Pedro entry; prove
      that the proposed dust-producing action is reached before using its
      velocity calculation. Investigate other actions if it is cancelled.
- [ ] Instantiate floor/ceiling selection, wall resolution, referenced floor,
      action/speed repeatability, pool reserve, and accepted dust requests.
- [ ] Compose linked Clight frame execution and address refinement.
- [ ] Prove the requested cog entry/control theorem with an explicit duration.

## Pipeline and scope

- [x] Pin decomp commit `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- [x] Generate only `VERSION_US` and `VERSION_JP` Clight units.
- [x] Record the exact `clightgen -normalize` command and preprocessing flags.
- [x] Reject `Admitted`, `Axiom`, `Parameter`, `Conjecture`, `Abort`, and tactic
      escape hatches.
- [x] Complete the current two-pass CompCert 3.15 reproducibility check in an
      authenticated temporary Linux copy. Both passes agree, and all 82 outputs
      match the workspace byte for byte (`build/all-rng-generate-text.log`, exit 0).
- [x] Compile the complete `_CoqProject` in the configured CompCert proof switch.
- [x] Validate the expanded all-RNG frontier: 82 reproducible outputs, full
      Pedro build, no holes, authenticated source coverage, three missing-unit
      rejection checks, standard assumptions for both expanded cog capstones,
      and the separate root discipline audit. Retain the
      [validation receipt](../inputs/rng-frontier-validation.json).
- [x] Inspect the new cog execution capstone with `Print Assumptions` (standard
      Coq/CompCert axioms only).
- [x] Validate the animation/sound discharges: full Pedro build, no-hole check,
      unchanged source-coverage receipt for 82 generated files, identical
      before/after active-capstone assumptions and clean root discipline audit.
      Keep the [separate receipt](../inputs/helper-execution-validation.json).
- [x] Inspect every named capstone with `Print Assumptions`, completing the
      interrupted batch with individual pipeline invocations. Only standard
      Coq/CompCert axioms appear; the two schedule results are closed.
- [x] Run the separate root proof-discipline audit with the installed
      `sm64-item-proof` switch; exit 0. This is additional repository hygiene,
      not a replacement for the Pedro checks.
- [x] Validate the slide-kick additions: final proof/no-hole checks, both
      regeneration passes matching all 56 outputs, all 12 named assumption
      checks and the root discipline audit. Complete interrupted batches via
      Linux-local regeneration and individual assumption invocations; see
      [the verification receipt](ttc-cog-slide-kick.md#verification-receipt).

## Generic Pedro mechanism

- [x] Couple the `nextPos[1] <= floorHeight` test to the `160.0f` gap test.
- [x] Check that only the `> 160.0f` branch updates horizontal position,
      referenced floor, and referenced floor height.
- [x] Check that the surrounding branch still writes vertical position and
      returns `AIR_STEP_LANDED` (`1`).
- [x] Couple analog bit `1` to `apply_landing_accel(m, 0.98f)`.
- [x] Couple the neutral branch to the `>= 16.0f` test and
      `apply_slope_decel(m, 2.0f)`.
- [x] Tie floor classes 19, 20, default, and 21 to the generated binary32
      factors 0.2, 0.7, 2.0, and 3.0 in `apply_slope_decel`.
- [x] Check the analog and neutral helpers' slope calls and `forwardVel`
      writes in generated Clight.
- [x] Couple the post-step strict `> 16.0f` test to setting particle bit zero.
- [x] Compute binary32 input-tap witnesses for every flat-floor deceleration
      class (0.4, 1.4, 4.0, and 6.0 speed units).
- [ ] Prove Clight big-step execution for the Pedro landing branch.
- [ ] Prove Clight big-step execution for `common_landing_action` under each
      applicable floor class, including `apply_slope_accel` effects.
- [ ] Enumerate every stock US/JP Pedro spot and classify its referenced floor.
- [ ] Prove repeatability: both chosen inputs preserve Mario's in-spot state.

## Dust to PRNG

- [x] Check particle bit zero maps to `bhvMistParticleSpawner`.
- [x] Check the spawner behavior names both white-puff children.
- [x] Check both white-puff behavior scripts name their native loop functions.
- [x] Check each white-puff initializer calls `obj_translate_xz_random`.
- [x] Check `obj_translate_xz_random` has two direct `random_float` calls.
- [x] Check `random_float` directly calls `random_u16`.
- [x] Check `random_u16` writes `gRandomSeed16` and contains the pinned
      recurrence constants.
- [ ] Link and execute the behavior-script/object-list chain.
  - [x] Select the generated dust-chain definitions verbatim and obtain a
        CompCert `Linking.link` witness for a symbol-level structural slice.
  - [x] Decode the stock behavior words and execute a source-derived normal-list
        projection with explicit accepted-dust, normal-frame, and allocation
        premises.
  - [x] Construct a genuine CompCert Clight big-step for the exact generated
        scalar `random_u16` leaf at the initialized zero seed, returning and
        storing `57460`.
  - [x] Build typed US/JP links with the generated composite environment and
        execute `obj_translate_xz_random`, both nested `random_float` calls,
        and both nested `random_u16` calls, including the object X/Z stores.
  - [x] Execute the exact generated WhitePuff2 timer-zero native and its
        `bhv_cmd_call_native` wrapper, including cursor advance `20 -> 28` and
        seed advance `0 -> 57460 -> 55882`, in both supported versions.
  - [x] Execute one exact generated `cur_obj_update` loop cycle: fetch opcode
        `0x0C`, load `BehaviorCmdTable[12]`, indirectly call the linked handler,
        store result zero, and take the CONTINUE branch in both versions.
  - [x] Execute the exact generated US/JP `bhv_cmd_parent_bit_clear` handler
        under explicit symbol, composite-layout, and memory premises; prove the
        Mario word's mask-1 bit (bit zero) clear and advance the Mist cursor
        `4 -> 12`.
  - [x] Execute the exact generated US/JP `spawn_particle` accepted branch:
        read a clear active-particle bit, set mask 1 (bit zero) in raw-data
        word 22, call `spawn_object_at_origin` with model 142 and the supplied
        behavior argument, then call `obj_copy_pos_and_angle`, under explicit
        callee-execution and memory-preservation premises. The paired exact
        table receipt names `bhvMistParticleSpawner` for the dust entry.
  - [x] Prove the exact standard-Clight boundary in US/JP
        `segmented_to_virtual`: the generated pointer-to-`u32` cast preserves a
        symbolic `Vptr`, so its first integer right shift cannot evaluate.
  - [ ] Execute `cur_obj_update`'s complete command loop, list traversal,
        Mario particle dispatch, Mist/Puff spawn/allocation, and WhitePuff1.
        The next WhitePuff2 commands are `ADD_INT` and `END_REPEAT`; the
        downward chain additionally reaches pointer-to-integer arithmetic in
        generated `segmented_to_virtual`, which standard CompCert cannot
        evaluate from a symbolic global `Vptr`. It needs a proved N64
        flat-address refinement and a concrete CompCert memory realization of
        the object/free-list topology.
- [ ] Prove object-pool and active-particle-flag premises for a reachable tap.
  - [x] Prove the isolated D/D/U allocation trace succeeds iff
        `free + unimportant >= 3`.
  - [x] Prove the active-bit guard accepts a clear bit, sets it, and the spawned
        mist clears it in the same-frame projection.
  - [x] Execute the generated parent-bit-clear store itself in US/JP arbitrary
        compatible `genv`s, including the parent load, byte-224 mask,
        bit-clear postcondition, and cursor store.
  - [x] Execute the generated `spawn_particle` clear-bit guard and byte-224
        OR-store in US/JP, proving the stored bit set across its two explicitly
        premised callees.
  - [x] Generate the TTC level-script and loader units, count the exact source
        inventory `110` macro descriptors + `9` area object descriptors +
        Mario, and reduce the nominal later-competitor allowance to `117`.
  - [x] Prove the normal-frame reduction keeps a freshly clear dust bit clear
        across any finite request sequence.
  - [x] Check a complete 240-slot US/JP debug-replay census with reserve 116,
        a dust request, a clear active-dust bit, normal time, and identical
        normalized object-list state in both versions.
  - [ ] Derive a clear bit, sufficient reserve after competing allocations, and
        list integrity at a controller-only reachable US and JP TTC tap. The
        checked finite census uses level-select debug entry and SLOW mode.
- [ ] Prove the exact number and frame timing of seed advances.
  - [x] In the conditional source-derived dust-only projection, derive Puff1-X,
        Puff1-Z, Puff2-X, and Puff2-Z as four dust-owned calls on the tap frame.
  - [x] Prove `R^4(seed)` under an explicit no-intervening-RNG-consumer premise
        and that the spinner's next observation opportunity is frame `F + 1`.
  - [x] Generalize the seed equation to exact `R^(4+k)` composition for any
        certified finite non-dust call counts before, between, and after the
        two dust pairs.
  - [x] Derive the US/JP generated macro prefixes before spinner 0 and spinner
        7, check their Clight RNG call sites, and prove conditional conservative
        non-dust bounds of `80` and `94` calls respectively.
  - [x] Parse the generated TTC level/behavior scripts, close the selected
        post-PLAYER forward/reverse call graphs, decode the one reached
        indirect Heave-Ho dispatch, and prove `random_u16` is the unique
        syntactic writer of `gRandomSeed16`. The fail-closed terminal frontier
        records declared-external `sqrtf`.
  - [x] Authenticate and check the complete US/JP retail `sqrtf` byte leaves as
        `jr ra; sqrt.s f0,f12; nop; nop`, with no conservatively recognized
        nested call or memory store. This is an opcode receipt, not an external
        semantics refinement.
  - [x] Check the debug replay's exact ten contiguous calls on `F` and `F+1`:
        one list-2 Bob-omb call then four dust calls per frame, including every
        seed transition and the US/JP behavior-address projection.
  - [ ] Establish those timing facts for linked Clight/retail execution and
        supply a controller-only stock/Pedro/RANDOM-mode snapshot, a CompCert
        contract for declared externals, and a runtime-address-to-Clight
        refinement needed to instantiate the finite window bounds.

## TTC spinner witness

- [x] Check the stock spinner speed table `[200; 600; 200; 0]`.
- [x] Check random-mode spinner update names `random_sign` and
      `random_mod_offset`.
- [x] Check behavior data ties `bhvTTCSpinner` to the spinner collision and
      native update function.
- [x] Check the area-one macro stream contains exactly fourteen spinner records.
- [x] Check the spinner collision stream is identical in US and JP and has the
      expected 170 words.
- [x] Derive transformed collision planes from the generated vertex/triangle
      stream with target binary32/MIPS-compatible arithmetic.
- [x] Find and prove a concrete spinner pitch interval with a floor/ceiling gap
      in `(0, 160]` and sufficient horizontal overlap.
- [ ] Exhibit a reachable Mario entry state for both versions.
- [x] Model the random-setting timer/direction schedule.
- [ ] Search for and prove a dust-tap schedule that keeps the spinner inside the
      proved angle interval.
  - [x] Strengthen the fixed `(1045, 1603)` collision witness to the 368-unit
        pitch interval `[15664, 16031]` in both supported versions.
  - [x] Prove that a selected `-1` direction can keep pitch `15864` inside for
        the first 200-unit motion.
  - [x] Prove that no dust/RNG schedule can preserve this fixed interval through
        the second post-pause motion, which reaches `pitch +/- 400`.
- [ ] State and prove the final TTC Clight execution theorem.
