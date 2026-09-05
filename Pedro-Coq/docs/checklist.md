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
- [x] Inspect every named capstone with `Print Assumptions`.

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
- [x] Prove that no dust/RNG schedule can preserve the current 96-unit interval:
      the first post-pause movement is 200 units in either direction.
- [ ] State and prove the final TTC Clight execution theorem.
