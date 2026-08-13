(** Focused generated-source receipt for US [update_mario_platform].

    The exact body is definition 107 (zero based) in the platform translation
    unit.  The second theorem transports that one receipt into the source
    union consumed by normalization, without evaluating the whole union. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Linking.
From LessThanOneAPress.Generated Require Import us_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  JPSourceSymbolTransport LinkedClightPrograms NormalizedClightPrograms
  USWarpLevelSourceUnionReceipt.

Theorem us_platform_update_nth_error_checked :
  nth_error us_platform_displacement.global_definitions 107%nat =
    Some (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform)).
Proof. vm_compute. reflexivity. Qed.

Corollary us_platform_update_prog_defs_member :
  In (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform))
    (prog_defs us_platform_displacement.prog).
Proof.
  eapply nth_error_In.
  exact us_platform_update_nth_error_checked.
Qed.

(** [us_platform_displacement] is unit 29 in the zero-based 38-unit order. *)
Theorem us_platform_update_source_union_member :
  In (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform))
    (unit_global_definitions us_units).
Proof.
  assert (Hunit :
    us_nlist_at 29%nat us_units = us_platform_displacement.prog).
  { reflexivity. }
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 29%nat us_units).
  - exact (us_nlist_at_nIn _ 29%nat us_units).
  - rewrite Hunit.
    exact us_platform_update_prog_defs_member.
Qed.
