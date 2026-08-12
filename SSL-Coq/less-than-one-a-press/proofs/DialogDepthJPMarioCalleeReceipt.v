(** Identifier-only direct-callee receipts for the three JP [mario.c]
    bodies on the dialog/depth spine.  These are body-local syntax facts. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import jp_mario.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_JPMario := jp_mario.

Definition jp_set_mario_action_cutscene_direct_callee_receipt : list ident :=
  [DD_JPMario._mario_set_forward_vel;
   DD_JPMario._mario_set_forward_vel].

Definition jp_set_mario_action_direct_callee_receipt : list ident :=
  [DD_JPMario._set_mario_action_moving;
   DD_JPMario._set_mario_action_airborne;
   DD_JPMario._set_mario_action_submerged;
   DD_JPMario._set_mario_action_cutscene].

Definition jp_sink_mario_in_quicksand_direct_callee_receipt : list ident :=
  [].

Theorem jp_set_mario_action_cutscene_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_JPMario.f_set_mario_action_cutscene) =
  jp_set_mario_action_cutscene_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_set_mario_action_direct_callees_exact :
  statement_direct_callees (fn_body DD_JPMario.f_set_mario_action) =
  jp_set_mario_action_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_sink_mario_in_quicksand_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_JPMario.f_sink_mario_in_quicksand) =
  jp_sink_mario_in_quicksand_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
