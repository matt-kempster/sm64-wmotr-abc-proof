From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Floats Integers.
From Pedro.Generated Require Import
  us_obj_behaviors_2 jp_obj_behaviors_2 us_behavior_script jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts DustPRNG TTCCogApproachExecution.

Import ListNotations.
Open Scope Z_scope.

(** Both generated cog bodies have these ordered direct call lists, including
    the sign draw even when the magnitude's remainder is zero. The execution
    theorem for the complete caller must still establish when this branch runs. *)
Definition cog_random_call_order_claim : Prop :=
  direct_callees_s (fn_body us_obj_behaviors_2.f_bhv_ttc_cog_update) =
    [us_obj_behaviors_2._approach_f32_ptr;
     us_obj_behaviors_2._random_u16; us_obj_behaviors_2._random_sign] /\
  direct_callees_s (fn_body jp_obj_behaviors_2.f_bhv_ttc_cog_update) =
    [jp_obj_behaviors_2._approach_f32_ptr;
     jp_obj_behaviors_2._random_u16; jp_obj_behaviors_2._random_sign] /\
  us_behavior_script.f_random_sign = jp_behavior_script.f_random_sign /\
  direct_callees_s (fn_body us_behavior_script.f_random_sign) =
    [us_behavior_script._random_u16].

Theorem cog_random_call_order_us_jp : cog_random_call_order_claim.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition cog_target_from_draws (magnitude_draw sign_draw : Z) : float32 :=
  Float32.mul
    (Float32.mul (Float32.of_bits (Int.repr 1128792064))
      (Float32.of_int (Int.mods (Int.repr magnitude_draw) (Int.repr 7))))
    (Float32.of_int (Int.repr (if 32767 <=? sign_draw then 1 else -1))).

Definition cog_target_from_seed (seed : Z) : float32 :=
  cog_target_from_draws (rng_steps 1 seed) (rng_steps 2 seed).

Definition cog_zero_targetb (seed : Z) : bool :=
  Float32.cmp Ceq (cog_target_from_seed seed) Float32.zero.

(** A finite, isolated two-cog observation projection. The concrete pair in
    the level is separated by other SURFACE objects, so adjacency of these
    RNG pairs remains a runtime obligation; this is not a scheduler theorem. *)
Definition consecutive_cog_pair_zero_targetb (seed : Z) : bool :=
  cog_zero_targetb seed && cog_zero_targetb (rng_steps 2 seed).

Theorem concrete_zero_cog_draw_pair :
  rng_steps 1 16 = 59500 /\ rng_steps 2 16 = 54874 /\
  cog_target_from_seed 16 = Float32.zero.
Proof. vm_compute; repeat split; reflexivity. Qed.

(** Four dust-owned calls have the right arithmetic effect in this selected
    recurrence window. Real dust acceptance, interference, reachability, and
    persistence are separate from this exact binary32/PRNG calculation. *)
Theorem four_rng_advances_select_two_zero_cog_targets :
  rng_steps 4 18 = 4409 /\
  consecutive_cog_pair_zero_targetb 18 = false /\
  consecutive_cog_pair_zero_targetb 4409 = true /\
  map (fun n => rng_steps n 4409) [1%nat; 2%nat; 3%nat; 4%nat] =
    [64729; 4683; 23527; 37709].
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition ttc_cog_rng_reduction_claim : Prop :=
  cog_random_call_order_claim /\
  us_obj_behaviors_2.f_approach_f32_ptr =
    jp_obj_behaviors_2.f_approach_f32_ptr /\
  cog_approach_zero_execution_claim /\
  rng_steps 4 18 = 4409 /\
  consecutive_cog_pair_zero_targetb 18 = false /\
  consecutive_cog_pair_zero_targetb 4409 = true.

Theorem checked_ttc_cog_rng_reduction_us_jp :
  ttc_cog_rng_reduction_claim.
Proof.
  destruct four_rng_advances_select_two_zero_cog_targets as [Hseed [Hno [Hyes _]]].
  exact (conj cog_random_call_order_us_jp
    (conj cog_approach_function_identical_us_jp
    (conj generated_cog_approach_zero_executes
      (conj Hseed (conj Hno Hyes))))).
Qed.
