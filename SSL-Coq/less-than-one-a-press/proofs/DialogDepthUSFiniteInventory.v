(** US half of the finite dialog/depth direct-callee inventory.

    The expensive statement walkers have already been reduced in three
    translation-unit-local receipt modules.  This file rewrites to those
    identifier-only lists before classifying selected unresolved externals.
    The result is direct-call syntax only, not transitive reachability and not
    a writable-memory frame. *)

From Coq Require Import List.
From compcert Require Import AST Coqlib.
From LessThanOneAPress.Proofs Require Import
  RetailExternalFrameReachability
  DialogDepthUSMarioCalleeReceipt
  DialogDepthUSCutsceneCalleeReceipt
  DialogDepthUSStepCalleeReceipt.

Import ListNotations.

Definition us_dialog_depth_spine_direct_callee_receipt : list ident :=
  nodup peq
    (us_set_mario_action_cutscene_direct_callee_receipt ++
     us_set_mario_action_direct_callee_receipt ++
     us_sink_mario_in_quicksand_direct_callee_receipt ++
     us_general_star_dance_handler_direct_callee_receipt ++
     us_act_star_dance_direct_callee_receipt ++
     us_act_reading_automatic_dialog_direct_callee_receipt ++
     us_stop_and_set_height_to_floor_direct_callee_receipt).

Theorem us_dialog_depth_spine_direct_callees_exact :
  us_dialog_depth_spine_direct_callees =
  us_dialog_depth_spine_direct_callee_receipt.
Proof.
  unfold us_dialog_depth_spine_direct_callees,
    us_dialog_depth_spine_direct_callee_receipt.
  rewrite us_set_mario_action_cutscene_direct_callees_exact.
  rewrite us_set_mario_action_direct_callees_exact.
  rewrite us_sink_mario_in_quicksand_direct_callees_exact.
  rewrite us_general_star_dance_handler_direct_callees_exact.
  rewrite us_act_star_dance_direct_callees_exact.
  rewrite us_act_reading_automatic_dialog_direct_callees_exact.
  rewrite us_stop_and_set_height_to_floor_direct_callees_exact.
  reflexivity.
Qed.

Definition USDialogDepthFiniteInventory : Prop :=
  same_ident_set us_dialog_depth_spine_unresolved
    us_dialog_depth_expected_unresolved = true /\
  List.length us_dialog_depth_spine_unresolved = 10%nat.

Theorem us_dialog_depth_finite_inventory_closed :
  USDialogDepthFiniteInventory.
Proof.
  unfold USDialogDepthFiniteInventory,
    us_dialog_depth_spine_unresolved,
    us_dialog_depth_spine_definition_map.
  rewrite us_dialog_depth_spine_direct_callees_exact.
  vm_compute. split; reflexivity.
Qed.
