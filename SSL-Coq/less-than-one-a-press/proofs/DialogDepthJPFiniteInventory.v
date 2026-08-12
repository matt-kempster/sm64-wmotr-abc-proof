(** JP half of the finite dialog/depth direct-callee inventory.

    This combines body-local identifier receipts before evaluating the
    selected unresolved-external filter.  It deliberately says nothing about
    transitive call paths, callsite arguments, or external memory effects. *)

From Coq Require Import List.
From compcert Require Import AST Coqlib.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability
  DialogDepthJPMarioCalleeReceipt
  DialogDepthJPCutsceneCalleeReceipt
  DialogDepthJPStepCalleeReceipt.

Import ListNotations.

Definition jp_dialog_depth_spine_direct_callee_receipt : list ident :=
  nodup peq
    (jp_set_mario_action_cutscene_direct_callee_receipt ++
     jp_set_mario_action_direct_callee_receipt ++
     jp_sink_mario_in_quicksand_direct_callee_receipt ++
     jp_general_star_dance_handler_direct_callee_receipt ++
     jp_act_star_dance_direct_callee_receipt ++
     jp_act_reading_automatic_dialog_direct_callee_receipt ++
     jp_stop_and_set_height_to_floor_direct_callee_receipt).

Theorem jp_dialog_depth_spine_direct_callees_exact :
  jp_dialog_depth_spine_direct_callees =
  jp_dialog_depth_spine_direct_callee_receipt.
Proof.
  unfold jp_dialog_depth_spine_direct_callees,
    jp_dialog_depth_spine_direct_callee_receipt.
  rewrite jp_set_mario_action_cutscene_direct_callees_exact.
  rewrite jp_set_mario_action_direct_callees_exact.
  rewrite jp_sink_mario_in_quicksand_direct_callees_exact.
  rewrite jp_general_star_dance_handler_direct_callees_exact.
  rewrite jp_act_star_dance_direct_callees_exact.
  rewrite jp_act_reading_automatic_dialog_direct_callees_exact.
  rewrite jp_stop_and_set_height_to_floor_direct_callees_exact.
  reflexivity.
Qed.

Definition JPDialogDepthFiniteInventory : Prop :=
  same_ident_set jp_dialog_depth_spine_unresolved
    jp_dialog_depth_expected_unresolved = true /\
  List.length jp_dialog_depth_spine_unresolved = 10%nat.

Theorem jp_dialog_depth_finite_inventory_closed :
  JPDialogDepthFiniteInventory.
Proof.
  unfold JPDialogDepthFiniteInventory,
    jp_dialog_depth_spine_unresolved,
    jp_dialog_depth_spine_definition_map.
  rewrite jp_dialog_depth_spine_direct_callees_exact.
  vm_compute. split; reflexivity.
Qed.
