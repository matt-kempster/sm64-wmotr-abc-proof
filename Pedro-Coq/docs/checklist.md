# Proof checklist

Checked source-reduction items mean the corresponding recognizer and theorem
have been authored against a pinned-source inspection and passed the pipeline
audits below.

## Pipeline and scope

- [x] Pin decomp commit `9921382a68bb0c865e5e45eb594d9c64db59b1af`.
- [x] Generate only `VERSION_US` and `VERSION_JP` Clight units.
- [x] Record the exact `clightgen -normalize` command and preprocessing flags.
- [x] Reject `Admitted`, `Axiom`, `Parameter`, `Conjecture`, `Abort`, and tactic
      escape hatches.
- [x] Regenerate with CompCert 3.15 and verify byte-for-byte stability.
- [x] Compile the complete `_CoqProject` in the configured CompCert proof switch.
- [x] Inspect all three capstones with `Print Assumptions`.

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
  - [ ] Lift that projection to Clight big-step execution with a complete
        composite environment, resolved globals, and behavior-command calls.
- [ ] Prove object-pool and active-particle-flag premises for a reachable tap.
  - [x] Prove the isolated D/D/U allocation trace succeeds iff
        `free + unimportant >= 3`.
  - [x] Prove the active-bit guard accepts a clear bit, sets it, and the spawned
        mist clears it in the same-frame projection.
  - [ ] Derive a clear bit, sufficient reserve after competing allocations, and
        list integrity at a reachable US and JP TTC tap.
- [ ] Prove the exact number and frame timing of seed advances.
  - [x] In the conditional source-derived dust-only projection, derive Puff1-X,
        Puff1-Z, Puff2-X, and Puff2-Z as four dust-owned calls on the tap frame.
  - [x] Prove `R^4(seed)` under an explicit no-intervening-RNG-consumer premise
        and that the spinner's next observation opportunity is frame `F + 1`.
  - [ ] Establish those timing facts for linked Clight/retail execution and
        account for all non-dust RNG consumers between object-list phases.

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
- [x] Prove that no dust/RNG schedule can preserve the current 96-unit interval:
      the first post-pause movement is 200 units in either direction.
- [ ] State and prove the final TTC Clight execution theorem.
