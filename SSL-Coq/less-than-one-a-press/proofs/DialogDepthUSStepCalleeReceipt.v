(** Identifier-only direct-callee receipt for the US ground-step helper on
    the dialog/depth spine. *)

From Coq Require Import List.
From compcert Require Import AST Clight.
From LessThanOneAPress.Generated Require Import us_mario_step.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability.

Import ListNotations.
Module DD_USStep := us_mario_step.

Definition us_stop_and_set_height_to_floor_direct_callee_receipt : list ident :=
  [DD_USStep._mario_set_forward_vel;
   DD_USStep._vec3f_copy;
   DD_USStep._vec3s_set].

Theorem us_stop_and_set_height_to_floor_direct_callees_exact :
  statement_direct_callees
    (fn_body DD_USStep.f_stop_and_set_height_to_floor) =
  us_stop_and_set_height_to_floor_direct_callee_receipt.
Proof. vm_compute. reflexivity. Qed.
