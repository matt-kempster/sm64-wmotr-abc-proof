(** Fixed-position source receipts for the two selected US game-init globals.

    These checks traverse only the spine of [global_definitions].  In
    particular, they avoid constructing the translation unit's [prog_defmap]. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import us_game_init.

Theorem us_game_init_gControllers_nth_error_checked :
  nth_error us_game_init.global_definitions 146%nat =
    Some (us_game_init._gControllers,
      Gvar us_game_init.v_gControllers).
Proof. vm_compute. reflexivity. Qed.

Theorem us_game_init_gPlayer1Controller_nth_error_checked :
  nth_error us_game_init.global_definitions 170%nat =
    Some (us_game_init._gPlayer1Controller,
      Gvar us_game_init.v_gPlayer1Controller).
Proof. vm_compute. reflexivity. Qed.

Corollary us_game_init_gControllers_prog_defs_member :
  In (us_game_init._gControllers, Gvar us_game_init.v_gControllers)
    (prog_defs us_game_init.prog).
Proof.
  eapply nth_error_In.
  exact us_game_init_gControllers_nth_error_checked.
Qed.

Corollary us_game_init_gPlayer1Controller_prog_defs_member :
  In (us_game_init._gPlayer1Controller,
      Gvar us_game_init.v_gPlayer1Controller)
    (prog_defs us_game_init.prog).
Proof.
  eapply nth_error_In.
  exact us_game_init_gPlayer1Controller_nth_error_checked.
Qed.
