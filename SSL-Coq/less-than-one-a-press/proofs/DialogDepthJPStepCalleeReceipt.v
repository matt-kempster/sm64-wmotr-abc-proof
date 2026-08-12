(** Identifier-only direct-callee receipt for the JP ground-step helper on
    the dialog/depth spine. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_JPStep := jp_mario_step.

Definition jp_stop_and_set_height_to_floor_direct_callee_receipt : list ident :=
  [DD_JPStep._mario_set_forward_vel;
   DD_JPStep._vec3f_copy;
   DD_JPStep._vec3s_set].

Theorem jp_stop_and_set_height_to_floor_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_JPStep.f_stop_and_set_height_to_floor) =
  jp_stop_and_set_height_to_floor_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
