(** The focused US [_warp_level] body is a fixed point of the viewport repair. *)

From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import
  USWholeASTTagRepair USWarpLevelViewportReceipt.

Theorem us_warp_level_repair_is_identity :
  repair_us_selected_global_definition
    (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level)) =
    (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level)).
Proof.
  unfold repair_us_selected_global_definition.
  rewrite us_warp_level_needs_no_viewport_repair_checked.
  reflexivity.
Qed.
