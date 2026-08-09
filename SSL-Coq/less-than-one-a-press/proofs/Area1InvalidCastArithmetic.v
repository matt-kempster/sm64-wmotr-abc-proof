(** Isolated CompCert conversion receipts for invalid terrain-cast inputs.

    Each executable binary32 check is sealed as its own opaque theorem.  This
    keeps checker memory bounded while closing the concrete classification
    premise used by [Area1NonlocalCastSemantics]. *)

From Coq Require Import ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import Area1NonlocalCastSemantics.

Local Open Scope Z_scope.

Theorem cast_qnan_compcert_conversion_fails :
  Float32.to_int cast_qnan = None.
Proof. vm_compute. reflexivity. Qed.

Theorem cast_positive_infinity_compcert_conversion_fails :
  Float32.to_int cast_positive_infinity = None.
Proof. vm_compute. reflexivity. Qed.

Theorem cast_negative_infinity_compcert_conversion_fails :
  Float32.to_int cast_negative_infinity = None.
Proof. vm_compute. reflexivity. Qed.

Theorem cast_positive_two_to_31_compcert_conversion_fails :
  Float32.to_int cast_positive_two_to_31 = None.
Proof. vm_compute. reflexivity. Qed.

Theorem cast_below_negative_two_to_31_compcert_conversion_fails :
  Float32.to_int cast_below_negative_two_to_31 = None.
Proof. vm_compute. reflexivity. Qed.

(** The adjacent representable endpoints do not fail.  They are extreme but
    genuine signed-word-to-signed-halfword aliases, sharply separating the
    useful finite case from overflow. *)
Theorem cast_largest_positive_word_float_succeeds_and_aliases :
  Float32.to_int cast_largest_positive_word_float =
      Some (Int.repr 2147483520) /\
  terrain_s16_from_float cast_largest_positive_word_float = Some (-128).
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem cast_negative_two_to_31_succeeds_and_aliases :
  Float32.to_int cast_negative_two_to_31 =
      Some (Int.repr (-2147483648)) /\
  terrain_s16_from_float cast_negative_two_to_31 = Some 0.
Proof.
  vm_compute. split; reflexivity.
Qed.

Theorem signed_word_boundary_casts_checked :
  terrain_s16_from_float cast_largest_positive_word_float = Some (-128) /\
  terrain_s16_from_float cast_negative_two_to_31 = Some 0.
Proof.
  split.
  - exact (proj2 cast_largest_positive_word_float_succeeds_and_aliases).
  - exact (proj2 cast_negative_two_to_31_succeeds_and_aliases).
Qed.

Theorem representative_failed_cast_classification_checked :
  RepresentativeFailedCastClassificationObligation.
Proof.
  unfold RepresentativeFailedCastClassificationObligation.
  split; [exact cast_qnan_compcert_conversion_fails |].
  split; [exact cast_positive_infinity_compcert_conversion_fails |].
  split; [exact cast_negative_infinity_compcert_conversion_fails |].
  split; [exact cast_positive_two_to_31_compcert_conversion_fails |].
  exact cast_below_negative_two_to_31_compcert_conversion_fails.
Qed.

Theorem representative_failed_casts_trap_checked :
  target_terrain_cast_prefix true cast_qnan = TargetCastTrap /\
  target_terrain_cast_prefix true cast_positive_infinity = TargetCastTrap /\
  target_terrain_cast_prefix true cast_negative_infinity = TargetCastTrap /\
  target_terrain_cast_prefix true cast_positive_two_to_31 = TargetCastTrap /\
  target_terrain_cast_prefix true cast_below_negative_two_to_31 =
    TargetCastTrap.
Proof.
  apply representative_failed_casts_trap_if_classified.
  exact representative_failed_cast_classification_checked.
Qed.
