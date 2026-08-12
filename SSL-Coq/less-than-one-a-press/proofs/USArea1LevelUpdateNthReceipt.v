(** Fixed-position source receipts for selected-US Area-1 level-update globals. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_level_update.

Theorem us_level_update_sWarpDest_nth_error_checked :
  nth_error us_level_update.global_definitions 251%nat =
    Some (us_level_update._sWarpDest, Gvar us_level_update.v_sWarpDest).
Proof. vm_compute. reflexivity. Qed.

Theorem us_level_update_sDelayedWarpOp_nth_error_checked :
  nth_error us_level_update.global_definitions 253%nat =
    Some (us_level_update._sDelayedWarpOp,
      Gvar us_level_update.v_sDelayedWarpOp).
Proof. vm_compute. reflexivity. Qed.

Theorem us_level_update_gMarioState_nth_error_checked :
  nth_error us_level_update.global_definitions 260%nat =
    Some (us_level_update._gMarioState, Gvar us_level_update.v_gMarioState).
Proof. vm_compute. reflexivity. Qed.

Corollary us_level_update_sWarpDest_prog_defs_member :
  In (us_level_update._sWarpDest, Gvar us_level_update.v_sWarpDest)
    (prog_defs us_level_update.prog).
Proof. eapply nth_error_In; exact us_level_update_sWarpDest_nth_error_checked. Qed.

Corollary us_level_update_sDelayedWarpOp_prog_defs_member :
  In (us_level_update._sDelayedWarpOp,
      Gvar us_level_update.v_sDelayedWarpOp)
    (prog_defs us_level_update.prog).
Proof. eapply nth_error_In; exact us_level_update_sDelayedWarpOp_nth_error_checked. Qed.

Corollary us_level_update_gMarioState_prog_defs_member :
  In (us_level_update._gMarioState, Gvar us_level_update.v_gMarioState)
    (prog_defs us_level_update.prog).
Proof. eapply nth_error_In; exact us_level_update_gMarioState_nth_error_checked. Qed.
