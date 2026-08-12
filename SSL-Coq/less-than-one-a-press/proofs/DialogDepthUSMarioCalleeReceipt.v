(** Identifier-only direct-callee receipts for the three US [mario.c]
    bodies on the dialog/depth spine.  These are body-local syntax facts:
    they do not compute a transitive call graph or assert an external frame. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import us_mario.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_USMario := us_mario.

Definition us_set_mario_action_cutscene_direct_callee_receipt : list ident :=
  [DD_USMario._mario_set_forward_vel;
   DD_USMario._mario_set_forward_vel].

Definition us_set_mario_action_direct_callee_receipt : list ident :=
  [DD_USMario._set_mario_action_moving;
   DD_USMario._set_mario_action_airborne;
   DD_USMario._set_mario_action_submerged;
   DD_USMario._set_mario_action_cutscene].

Definition us_sink_mario_in_quicksand_direct_callee_receipt : list ident :=
  [].

Theorem us_set_mario_action_cutscene_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_USMario.f_set_mario_action_cutscene) =
  us_set_mario_action_cutscene_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem us_set_mario_action_direct_callees_exact :
  statement_direct_callees (fn_body DD_USMario.f_set_mario_action) =
  us_set_mario_action_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.

Theorem us_sink_mario_in_quicksand_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_USMario.f_sink_mario_in_quicksand) =
  us_sink_mario_in_quicksand_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
