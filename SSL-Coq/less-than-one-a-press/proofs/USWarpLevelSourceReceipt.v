(** Focused source receipt for the US [_warp_level] definition.

    The generated translation unit contains 299 global definitions, and
    [_warp_level] is definition 276 (zero based).  Checking [nth_error]
    traverses only the list spine up to that fixed position; it does not build
    or reduce the translation unit's full [prog_defmap]. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_level_update.

Theorem us_level_update_warp_level_nth_error_checked :
  nth_error us_level_update.global_definitions 276%nat =
    Some (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level)).
Proof. vm_compute. reflexivity. Qed.

Theorem us_level_update_warp_level_source_member :
  In (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level))
    us_level_update.global_definitions.
Proof.
  eapply nth_error_In.
  exact us_level_update_warp_level_nth_error_checked.
Qed.

(** The same receipt in the [prog_defs] form consumed by the normalization
    and linking transport lemmas. *)
Corollary us_level_update_warp_level_prog_defs_member :
  In (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level))
    (prog_defs us_level_update.prog).
Proof.
  exact us_level_update_warp_level_source_member.
Qed.
