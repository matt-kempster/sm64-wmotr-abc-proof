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
- [x] Inspect both capstones with `Print Assumptions`.

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
- [ ] Prove object-pool and active-particle-flag premises for a reachable tap.
- [ ] Prove the exact number and frame timing of seed advances.

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
