From Coq Require Import Lia Lra Reals ZArith.
From Flocq Require Import Core.FLX Core.Raux Core.Zaux IEEE754.Binary.
From compcert Require Import Floats Integers.

Local Open Scope Z_scope.
Local Transparent Float32.add Float32.of_bits Float32.to_bits Float32.to_int.

(** Exact IEEE-754 binary32 encodings used by the boundary checks below. *)
Definition f32_100 : float32 :=
  Float32.of_bits (Int.repr 1120403456). (* 0x42c80000 *)

Definition f32_2p31 : float32 :=
  Float32.of_bits (Int.repr 1325400064). (* 0x4f000000 *)

(** At [2^31], adjacent binary32 values are 256 apart.  Round-to-nearest
    therefore discards an attempted addition of 100. *)
Lemma f32_2p31_plus_100_fixed :
  Float32.add f32_2p31 f32_100 = f32_2p31.
Proof.
  rewrite <- (Float32.of_to_bits (Float32.add f32_2p31 f32_100)).
  rewrite <- (Float32.of_to_bits f32_2p31).
  f_equal.
Qed.

Fixpoint add100_after (frames : nat) (y : float32) : float32 :=
  match frames with
  | O => y
  | S n => add100_after n (Float32.add y f32_100)
  end.

Lemma add100_from_2p31_stagnates :
  forall frames, add100_after frames f32_2p31 = f32_2p31.
Proof.
  induction frames as [|frames IH]; simpl; auto.
  rewrite f32_2p31_plus_100_fixed.
  exact IH.
Qed.

(** CompCert's checked source-level conversion is undefined at [2^31].
    This is a Clight boundary fact, not a theorem about the IDO-generated
    MIPS instruction in the original ROM. *)
Lemma f32_2p31_float_to_int_is_undefined :
  Float32.to_int f32_2p31 = None.
Proof.
  vm_compute.
  reflexivity.
Qed.

Local Open Scope R_scope.

Definition binary32_real_height (f : float32) : R := B2R 24 128 f.

Definition binary32_max_finite_height : R :=
  bpow radix2 128 - bpow radix2 (128 - 24).

Definition finite_binary32_stream (run : nat -> float32) : Prop :=
  forall frame, is_finite 24 128 (run frame) = true.

Definition binary32_stream_rises_unboundedly
    (run : nat -> float32) : Prop :=
  forall bound : R,
    exists frame, bound < binary32_real_height (run frame).

Definition binary32_stream_has_unbounded_finite_heights
    (run : nat -> float32) : Prop :=
  forall bound : R,
    exists frame,
      is_finite 24 128 (run frame) = true /\
      bound < binary32_real_height (run frame).

(** Every stream whose observations remain finite is bounded by the largest
    finite binary32 value.  No recurrence-specific invariant is required. *)
Theorem finite_binary32_stream_not_unbounded :
  forall run,
    finite_binary32_stream run ->
    ~ binary32_stream_rises_unboundedly run.
Proof.
  intros run _ Hunbounded.
  destruct (Hunbounded binary32_max_finite_height) as [frame Hhigher].
  pose proof
    (abs_B2R_le_emax_minus_prec 24 128
       ltac:(constructor; lia) (run frame)) as Habs.
  assert (binary32_real_height (run frame) <=
          binary32_max_finite_height) as Hbounded.
  {
    unfold binary32_real_height, binary32_max_finite_height.
    eapply Rle_trans; [apply Rle_abs | exact Habs].
  }
  lra.
Qed.

(** The same ceiling rules out unbounded *finite* observations even if an
    arbitrary stream also contains infinities or NaNs.  Non-finite bit
    patterns are not treated as physical heights. *)
Theorem no_binary32_stream_has_unbounded_finite_heights :
  forall run, ~ binary32_stream_has_unbounded_finite_heights run.
Proof.
  intros run Hunbounded.
  destruct (Hunbounded binary32_max_finite_height)
    as [frame [_ Hhigher]].
  pose proof
    (abs_B2R_le_emax_minus_prec 24 128
       ltac:(constructor; lia) (run frame)) as Habs.
  assert (binary32_real_height (run frame) <=
          binary32_max_finite_height) as Hbounded.
  {
    unfold binary32_real_height, binary32_max_finite_height.
    eapply Rle_trans; [apply Rle_abs | exact Habs].
  }
  lra.
Qed.

Definition binary32_boundary_certificate : Prop :=
  Float32.add f32_2p31 f32_100 = f32_2p31 /\
  (forall frames, add100_after frames f32_2p31 = f32_2p31) /\
  (forall run, ~ binary32_stream_has_unbounded_finite_heights run) /\
  Float32.to_int f32_2p31 = None.

Theorem binary32_boundary_certificate_holds :
  binary32_boundary_certificate.
Proof.
  unfold binary32_boundary_certificate.
  refine (conj f32_2p31_plus_100_fixed _).
  refine (conj add100_from_2p31_stagnates _).
  exact (conj no_binary32_stream_has_unbounded_finite_heights
    f32_2p31_float_to_int_is_undefined).
Qed.
