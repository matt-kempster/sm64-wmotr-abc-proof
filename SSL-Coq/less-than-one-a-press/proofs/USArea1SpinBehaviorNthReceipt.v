(** Fixed-position source receipt for the selected-US spin-warp behavior. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_ssl_script.

Theorem us_ssl_script_bhvSpinAirborneWarp_nth_error_checked :
  nth_error us_ssl_script.global_definitions 103%nat =
    Some (us_ssl_script._bhvSpinAirborneWarp,
      Gvar us_ssl_script.v_bhvSpinAirborneWarp).
Proof. vm_compute. reflexivity. Qed.

Corollary us_ssl_script_bhvSpinAirborneWarp_prog_defs_member :
  In (us_ssl_script._bhvSpinAirborneWarp,
      Gvar us_ssl_script.v_bhvSpinAirborneWarp)
    (prog_defs us_ssl_script.prog).
Proof. eapply nth_error_In; exact us_ssl_script_bhvSpinAirborneWarp_nth_error_checked. Qed.
