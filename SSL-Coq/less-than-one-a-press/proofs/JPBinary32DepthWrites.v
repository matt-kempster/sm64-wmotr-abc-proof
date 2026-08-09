(** Exact binary32 sign closure for the JP quicksand-depth writer equations.

    This file deliberately stops short of a linked-program reachability or
    pointer/non-aliasing theorem.  It supplies the floating-point arithmetic
    layer needed by such a theorem: finite nonnegative operands remain finite
    and nonnegative across a non-overflowing binary32 addition. *)

From Coq Require Import Reals ZArith Lia Lra Psatz Logic.ProofIrrelevance.
From compcert Require Import Floats Integers.
From Flocq Require Import BinarySingleNaN Binary Core.

Open Scope R_scope.
Local Open Scope Z_scope.

Local Transparent Float32.add Float32.cmp Float32.compare.

Local Instance jp_binary32_prec_positive : Prec_gt_0 24.
Proof. constructor; lia. Defined.

Local Instance jp_binary32_prec_lt_emax : Prec_lt_emax 24 128.
Proof. constructor; lia. Defined.

Definition JPBinary32FiniteNonnegative (x : float32) : Prop :=
  is_finite 24 128 x = true /\ (0 <= B2R 24 128 x)%R.

Definition JPBinary32AddNoOverflow (x y : float32) : Prop :=
  Rlt_bool
    (Rabs
      (round radix2 (SpecFloat.fexp 24 128) (round_mode mode_NE)
        (B2R 24 128 x + B2R 24 128 y)))
    (bpow radix2 128) = true.

Lemma jp_binary32_add_preserves_finite_nonnegative :
  forall x y,
    JPBinary32FiniteNonnegative x ->
    JPBinary32FiniteNonnegative y ->
    JPBinary32AddNoOverflow x y ->
    JPBinary32FiniteNonnegative (Float32.add x y).
Proof.
  intros x y [Hfx Hx] [Hfy Hy] Hno.
  unfold JPBinary32AddNoOverflow in Hno.
  pose proof
    (Binary.Bplus_correct 24 128 _ _ Float32.binop_nan mode_NE x y
      Hfx Hfy) as Hplus.
  rewrite Hno in Hplus.
  destruct Hplus as [Hvalue [Hfinite _]].
  assert (Hadd :
      Float32.add x y =
      Binary.Bplus 24 128 jp_binary32_prec_positive
        jp_binary32_prec_lt_emax Float32.binop_nan mode_NE x y).
  {
    unfold Float32.add.
    f_equal; apply proof_irrelevance.
  }
  rewrite Hadd.
  split; [exact Hfinite|].
  rewrite Hvalue.
  rewrite <- (round_0 radix2 (SpecFloat.fexp 24 128)
    (round_mode mode_NE)).
  apply round_le.
  - typeclasses eauto.
  - typeclasses eauto.
  - apply Rplus_le_le_0_compat; assumption.
Qed.

Lemma jp_binary32_finite_not_lt_preserves_lower_bound :
  forall x lower,
    is_finite 24 128 x = true ->
    is_finite 24 128 lower = true ->
    Float32.cmp Clt x lower = false ->
    (B2R 24 128 lower <= B2R 24 128 x)%R.
Proof.
  intros x lower Hfx Hflower Hnotlt.
  unfold Float32.cmp, Float32.compare in Hnotlt.
  assert (Hcompare :
      Binary.Bcompare 24 128 x lower =
      Some (Rcompare (B2R 24 128 x) (B2R 24 128 lower))).
  {
    apply Binary.Bcompare_correct; assumption.
  }
  rewrite Hcompare in Hnotlt.
  destruct (Rcompare (B2R 24 128 x) (B2R 24 128 lower)) eqn:Horder;
    simpl in Hnotlt.
  - apply Req_le. symmetry. apply Rcompare_Eq_inv; exact Horder.
  - discriminate.
  - apply Rlt_le, Rcompare_Gt_inv; exact Horder.
Qed.

(** Literal encodings copied from the generated JP Clight bodies. *)
Definition jp_b32_zero : float32 :=
  Float32.of_bits (Int.repr 0).
Definition jp_b32_quarter : float32 :=
  Float32.of_bits (Int.repr 1048576000).
Definition jp_b32_half : float32 :=
  Float32.of_bits (Int.repr 1056964608).
Definition jp_b32_eight_tenths : float32 :=
  Float32.of_bits (Int.repr 1061997773).
Definition jp_b32_one : float32 :=
  Float32.of_bits (Int.repr 1065353216).
Definition jp_b32_one_point_one : float32 :=
  Float32.of_bits (Int.repr 1066192077).
Definition jp_b32_three_point_five : float32 :=
  Float32.of_bits (Int.repr 1080033280).
Definition jp_b32_five : float32 :=
  Float32.of_bits (Int.repr 1084227584).
Definition jp_b32_ten : float32 :=
  Float32.of_bits (Int.repr 1092616192).
Definition jp_b32_twenty_five : float32 :=
  Float32.of_bits (Int.repr 1103626240).
Definition jp_b32_sixty : float32 :=
  Float32.of_bits (Int.repr 1114636288).

Definition jp_b32_common_landing_delta (timer : Z) : float32 :=
  Float32.sub
    (Float32.mul
      (Float32.of_int (Int.repr (4 - timer)))
      jp_b32_three_point_five)
    jp_b32_half.

Theorem jp_binary32_safe_literal_constants :
  JPBinary32FiniteNonnegative jp_b32_zero /\
  JPBinary32FiniteNonnegative jp_b32_quarter /\
  JPBinary32FiniteNonnegative jp_b32_half /\
  JPBinary32FiniteNonnegative jp_b32_eight_tenths /\
  JPBinary32FiniteNonnegative jp_b32_one /\
  JPBinary32FiniteNonnegative jp_b32_one_point_one /\
  JPBinary32FiniteNonnegative jp_b32_three_point_five /\
  JPBinary32FiniteNonnegative jp_b32_five /\
  JPBinary32FiniteNonnegative jp_b32_ten /\
  JPBinary32FiniteNonnegative jp_b32_twenty_five /\
  JPBinary32FiniteNonnegative jp_b32_sixty.
Proof.
  unfold JPBinary32FiniteNonnegative,
    jp_b32_zero, jp_b32_quarter, jp_b32_half,
    jp_b32_eight_tenths, jp_b32_one, jp_b32_one_point_one,
    jp_b32_three_point_five, jp_b32_five, jp_b32_ten,
    jp_b32_twenty_five, jp_b32_sixty.
  vm_compute.
  repeat split; nra.
Qed.

Theorem jp_binary32_non_long_jump_landing_deltas_checked :
  Float32.to_bits (jp_b32_common_landing_delta 1) =
    Int.repr 1092616192 /\ (* 10.0f *)
  Float32.to_bits (jp_b32_common_landing_delta 2) =
    Int.repr 1087373312 /\ (* 6.5f *)
  Float32.to_bits (jp_b32_common_landing_delta 3) =
    Int.repr 1077936128.   (* 3.0f *)
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_binary32_non_long_jump_landing_deltas_are_safe :
  JPBinary32FiniteNonnegative (jp_b32_common_landing_delta 1) /\
  JPBinary32FiniteNonnegative (jp_b32_common_landing_delta 2) /\
  JPBinary32FiniteNonnegative (jp_b32_common_landing_delta 3).
Proof.
  unfold JPBinary32FiniteNonnegative, jp_b32_common_landing_delta,
    jp_b32_three_point_five, jp_b32_half.
  vm_compute.
  repeat split; nra.
Qed.

(** Exact operation trees mirrored from the generated Clight expressions. *)
Definition jp_b32_clamp_to_one_point_one (before : float32) : float32 :=
  if Float32.cmp Clt before jp_b32_one_point_one
  then jp_b32_one_point_one
  else before.

Definition jp_b32_quicksand_jump_raw
    (before : float32) (timer : Z) : float32 :=
  Float32.sub before
    (Float32.mul
      (Float32.of_int (Int.repr (7 - timer)))
      jp_b32_eight_tenths).

Definition jp_b32_quicksand_jump_outcome
    (before : float32) (timer : Z) : float32 :=
  let raw := jp_b32_quicksand_jump_raw before timer in
  if Float32.cmp Clt raw jp_b32_one
  then jp_b32_one_point_one
  else raw.

Inductive JPRetailQuicksandSpeed : float32 -> Prop :=
| JPRetailQuarterSpeed : JPRetailQuicksandSpeed jp_b32_quarter
| JPRetailHalfSpeed : JPRetailQuicksandSpeed jp_b32_half.

Inductive JPRetailPositiveDepthCap : float32 -> Prop :=
| JPRetailTenCap : JPRetailPositiveDepthCap jp_b32_ten
| JPRetailTwentyFiveCap : JPRetailPositiveDepthCap jp_b32_twenty_five
| JPRetailSixtyCap : JPRetailPositiveDepthCap jp_b32_sixty.

Lemma jp_retail_quicksand_speed_is_binary32_safe :
  forall speed,
    JPRetailQuicksandSpeed speed ->
    JPBinary32FiniteNonnegative speed.
Proof.
  intros speed Hspeed; inversion Hspeed; subst;
    pose proof jp_binary32_safe_literal_constants as H;
    tauto.
Qed.

Lemma jp_retail_positive_depth_cap_is_binary32_safe :
  forall cap,
    JPRetailPositiveDepthCap cap ->
    JPBinary32FiniteNonnegative cap.
Proof.
  intros cap Hcap; inversion Hcap; subst;
    pose proof jp_binary32_safe_literal_constants as H;
    tauto.
Qed.

Lemma jp_binary32_clamp_to_one_point_one_is_safe :
  forall before,
    JPBinary32FiniteNonnegative before ->
    JPBinary32FiniteNonnegative
      (jp_b32_clamp_to_one_point_one before).
Proof.
  intros before Hbefore.
  unfold jp_b32_clamp_to_one_point_one.
  destruct (Float32.cmp Clt before jp_b32_one_point_one);
    [pose proof jp_binary32_safe_literal_constants as H; tauto|exact Hbefore].
Qed.

Lemma jp_binary32_non_long_jump_landing_delta_is_safe :
  forall timer,
    timer = 1 \/ timer = 2 \/ timer = 3 ->
    JPBinary32FiniteNonnegative (jp_b32_common_landing_delta timer).
Proof.
  intros timer [-> | [-> | ->]];
    pose proof jp_binary32_non_long_jump_landing_deltas_are_safe as H;
    tauto.
Qed.

Lemma jp_binary32_quicksand_jump_outcome_is_safe :
  forall before timer,
    is_finite 24 128 (jp_b32_quicksand_jump_raw before timer) = true ->
    JPBinary32FiniteNonnegative
      (jp_b32_quicksand_jump_outcome before timer).
Proof.
  intros before timer Hfinite.
  unfold jp_b32_quicksand_jump_outcome.
  destruct
    (Float32.cmp Clt (jp_b32_quicksand_jump_raw before timer)
      jp_b32_one) eqn:Hclamp.
  - pose proof jp_binary32_safe_literal_constants as H; tauto.
  - split; [exact Hfinite|].
    eapply Rle_trans.
    + pose proof jp_binary32_safe_literal_constants as Hsafe.
      destruct Hsafe as
        (_ & _ & _ & _ & Hone & _).
      exact (proj2 Hone).
    + eapply jp_binary32_finite_not_lt_preserves_lower_bound;
        [exact Hfinite| |exact Hclamp].
      pose proof jp_binary32_safe_literal_constants as Hsafe.
      tauto.
Qed.

(** One constructor denotes the final, sink-visible depth after one complete
    generated writer routine.  The quicksand-jump helper's raw subtraction is
    intentionally paired with its immediately following clamp.  There is no
    call or return between those two generated statements; linking that AST
    fact to small-step non-interleaving remains outside this arithmetic file. *)
Inductive JPBinary32SafeDepthWriterOutcome :
    float32 -> float32 -> Prop :=
| JPB32DepthReset :
    forall before,
      JPBinary32SafeDepthWriterOutcome before jp_b32_zero
| JPB32DepthClampMinimum :
    forall before,
      JPBinary32SafeDepthWriterOutcome before jp_b32_one_point_one
| JPB32DepthQuicksandIncrement :
    forall before speed,
      JPRetailQuicksandSpeed speed ->
      JPBinary32FiniteNonnegative before ->
      JPBinary32AddNoOverflow
        (jp_b32_clamp_to_one_point_one before) speed ->
      JPBinary32SafeDepthWriterOutcome before
        (Float32.add (jp_b32_clamp_to_one_point_one before) speed)
| JPB32DepthPositiveCap :
    forall before cap,
      JPRetailPositiveDepthCap cap ->
      JPBinary32SafeDepthWriterOutcome before cap
| JPB32DepthNonLongJumpLanding :
    forall before timer,
      (timer = 1 \/ timer = 2 \/ timer = 3) ->
      JPBinary32FiniteNonnegative before ->
      JPBinary32AddNoOverflow before
        (jp_b32_common_landing_delta timer) ->
      JPBinary32SafeDepthWriterOutcome before
        (Float32.add before (jp_b32_common_landing_delta timer))
| JPB32DepthQuicksandJumpClamp :
    forall before timer,
      (1 <= timer <= 6)%Z ->
      is_finite 24 128 (jp_b32_quicksand_jump_raw before timer) = true ->
      JPBinary32SafeDepthWriterOutcome before
        (jp_b32_quicksand_jump_outcome before timer)
| JPB32DepthDeathIncrement :
    forall before,
      JPBinary32FiniteNonnegative before ->
      JPBinary32AddNoOverflow before jp_b32_five ->
      JPBinary32SafeDepthWriterOutcome before
        (Float32.add before jp_b32_five)
| JPB32DepthPreserved :
    forall before,
      JPBinary32SafeDepthWriterOutcome before before.

Theorem jp_binary32_safe_writer_outcome_preserves_nonnegative :
  forall before after,
    JPBinary32FiniteNonnegative before ->
    JPBinary32SafeDepthWriterOutcome before after ->
    JPBinary32FiniteNonnegative after.
Proof.
  intros before after Hbefore Hwrite.
  inversion Hwrite; subst.
  - pose proof jp_binary32_safe_literal_constants as Hconstants; tauto.
  - pose proof jp_binary32_safe_literal_constants as Hconstants; tauto.
  - apply jp_binary32_add_preserves_finite_nonnegative.
    + apply jp_binary32_clamp_to_one_point_one_is_safe; assumption.
    + apply jp_retail_quicksand_speed_is_binary32_safe; assumption.
    + assumption.
  - apply jp_retail_positive_depth_cap_is_binary32_safe; assumption.
  - apply jp_binary32_add_preserves_finite_nonnegative.
    + assumption.
    + apply jp_binary32_non_long_jump_landing_delta_is_safe; assumption.
    + assumption.
  - apply jp_binary32_quicksand_jump_outcome_is_safe; assumption.
  - apply jp_binary32_add_preserves_finite_nonnegative.
    + assumption.
    + pose proof jp_binary32_safe_literal_constants as Hconstants; tauto.
    + assumption.
  - assumption.
Qed.

Inductive JPBinary32SafeDepthWriterTrace :
    float32 -> float32 -> Prop :=
| JPB32DepthTraceRefl :
    forall depth,
      JPBinary32SafeDepthWriterTrace depth depth
| JPB32DepthTraceStep :
    forall before middle after,
      JPBinary32SafeDepthWriterOutcome before middle ->
      JPBinary32SafeDepthWriterTrace middle after ->
      JPBinary32SafeDepthWriterTrace before after.

Theorem jp_binary32_safe_writer_trace_preserves_nonnegative :
  forall before after,
    JPBinary32FiniteNonnegative before ->
    JPBinary32SafeDepthWriterTrace before after ->
    JPBinary32FiniteNonnegative after.
Proof.
  intros before after Hsafe Htrace.
  induction Htrace.
  - exact Hsafe.
  - apply IHHtrace.
    eapply jp_binary32_safe_writer_outcome_preserves_nonnegative; eauto.
Qed.

Corollary jp_binary32_safe_writer_trace_from_clean_zero_is_nonnegative :
  forall depth,
    JPBinary32SafeDepthWriterTrace jp_b32_zero depth ->
    JPBinary32FiniteNonnegative depth.
Proof.
  intros depth Htrace.
  apply (jp_binary32_safe_writer_trace_preserves_nonnegative
    jp_b32_zero depth).
  - pose proof jp_binary32_safe_literal_constants as Hconstants; tauto.
  - exact Htrace.
Qed.

(** The real-valued invariant implies the exact comparison used by Clight's
    [depth < 0.0f] tests.  Negative zero is accepted, as in C. *)
Lemma jp_binary32_finite_nonnegative_is_not_clight_negative :
  forall depth,
    JPBinary32FiniteNonnegative depth ->
    Float32.cmp Clt depth jp_b32_zero = false.
Proof.
  intros depth [Hfinite Hnonnegative].
  assert (Hzero_finite : is_finite 24 128 jp_b32_zero = true).
  {
    pose proof jp_binary32_safe_literal_constants as Hconstants.
    exact (proj1 (proj1 Hconstants)).
  }
  assert (Hzero_value : B2R 24 128 jp_b32_zero = 0%R).
  {
    unfold jp_b32_zero.
    vm_compute.
    reflexivity.
  }
  unfold Float32.cmp, Float32.compare.
  rewrite Binary.Bcompare_correct by assumption.
  destruct (Rcompare (B2R 24 128 depth)
      (B2R 24 128 jp_b32_zero)) eqn:Horder; simpl; auto.
  exfalso.
  apply Rcompare_Lt_inv in Horder.
  rewrite Hzero_value in Horder.
  lra.
Qed.

Corollary jp_binary32_safe_writer_trace_from_clean_zero_is_not_clight_negative :
  forall depth,
    JPBinary32SafeDepthWriterTrace jp_b32_zero depth ->
    Float32.cmp Clt depth jp_b32_zero = false.
Proof.
  intros depth Htrace.
  apply jp_binary32_finite_nonnegative_is_not_clight_negative.
  now apply jp_binary32_safe_writer_trace_from_clean_zero_is_nonnegative.
Qed.
