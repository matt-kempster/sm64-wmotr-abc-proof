(** Fixed-position source receipt for the selected-US platform global. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_platform_displacement.

Theorem us_platform_displacement_gMarioPlatform_nth_error_checked :
  nth_error us_platform_displacement.global_definitions 106%nat =
    Some (us_platform_displacement._gMarioPlatform,
      Gvar us_platform_displacement.v_gMarioPlatform).
Proof. vm_compute. reflexivity. Qed.

Corollary us_platform_displacement_gMarioPlatform_prog_defs_member :
  In (us_platform_displacement._gMarioPlatform,
      Gvar us_platform_displacement.v_gMarioPlatform)
    (prog_defs us_platform_displacement.prog).
Proof. eapply nth_error_In; exact us_platform_displacement_gMarioPlatform_nth_error_checked. Qed.
