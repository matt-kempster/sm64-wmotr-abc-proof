(**
  Generated-source receipts and a bounded chronology result for the stock
  pole/tree push in SSL Area 1.

  [cur_obj_push_mario_away] is initially tempting as a late State-only
  position writer: it reads Mario's raw Object X/Z and conditionally writes
  MarioState X/Z without writing the raw Object position.  The retail object
  list order defeats that interpretation for [bhvTree] and
  [bhvPoleGrabbing].  Both behaviors begin in list 10 (POLELIKE), list 10 is
  processed before list 0 (PLAYER), and [bhv_mario_update] later calls
  [copy_mario_state_to_object].  Thus an ordinary completed player update
  copies the pushed State X/Z back to raw Object X/Z.

  The generated call uses radius 70.0f (binary32 bits 1116471296), not 75.0f.
  Every generated-AST theorem below is a syntax/data receipt.  The small
  value model proves only the conditional resynchronization consequence; it
  does not prove that a tree/pole overlap occurs, that the behavior-script
  interpreter executes either callback, or that no unrelated post-player
  writer, alias, external call, or memory corruption creates a later split.
*)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_behavior_data us_object_helpers
  us_object_list_processor
  jp_behavior_actions jp_behavior_data jp_object_helpers
  jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module A1PPS_USBA := us_behavior_actions.
Module A1PPS_USBD := us_behavior_data.
Module A1PPS_USOH := us_object_helpers.
Module A1PPS_USOL := us_object_list_processor.
Module A1PPS_JPBA := jp_behavior_actions.
Module A1PPS_JPBD := jp_behavior_data.
Module A1PPS_JPOH := jp_object_helpers.
Module A1PPS_JPOL := jp_object_list_processor.

Fixpoint a1pps_init_int8_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int8 value :: rest =>
      Int.signed value :: a1pps_init_int8_values rest
  | _ :: rest => a1pps_init_int8_values rest
  end.

(** The two behavior-script initializers and the scheduler array pin the
    relevant order numerically: POLELIKE is 10 and PLAYER is 0.  The leading
    behavior word is [list << 16].  Initializer order remains data until the
    behavior-script interpreter is connected to a linked execution. *)
Definition area1_pole_push_list_order_source_claim : Prop :=
  a1pps_init_int8_values
    (gvar_init A1PPS_USOL.v_sObjectListUpdateOrder) =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
  a1pps_init_int8_values
    (gvar_init A1PPS_JPOL.v_sObjectListUpdateOrder) =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
  hd_error (gvar_init A1PPS_USBD.v_bhvTree) =
    Some (Init_int32 (Int.repr 655360)) /\
  hd_error (gvar_init A1PPS_JPBD.v_bhvTree) =
    Some (Init_int32 (Int.repr 655360)) /\
  hd_error (gvar_init A1PPS_USBD.v_bhvPoleGrabbing) =
    Some (Init_int32 (Int.repr 655360)) /\
  hd_error (gvar_init A1PPS_JPBD.v_bhvPoleGrabbing) =
    Some (Init_int32 (Int.repr 655360)) /\
  hd_error (gvar_init A1PPS_USBD.v_bhvMario) =
    Some (Init_int32 (Int.repr 0)) /\
  hd_error (gvar_init A1PPS_JPBD.v_bhvMario) =
    Some (Init_int32 (Int.repr 0)) /\
  initializer_list_mentions_addrof A1PPS_USBD._bhv_pole_base_loop
    (gvar_init A1PPS_USBD.v_bhvTree) = true /\
  initializer_list_mentions_addrof A1PPS_JPBD._bhv_pole_base_loop
    (gvar_init A1PPS_JPBD.v_bhvTree) = true /\
  initializer_list_mentions_addrof A1PPS_USBD._bhv_mario_update
    (gvar_init A1PPS_USBD.v_bhvMario) = true /\
  initializer_list_mentions_addrof A1PPS_JPBD._bhv_mario_update
    (gvar_init A1PPS_JPBD.v_bhvMario) = true.

Theorem area1_pole_push_list_order_source_checked :
  area1_pole_push_list_order_source_claim.
Proof.
  unfold area1_pole_push_list_order_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The helper's footprint is deliberately checked component by component.
    [_pos] is the MarioState array field; [_asF32] is raw Object data.  The
    negative raw-Object checks matter: merely finding [_gMarioStates] would
    not establish a State/Object phase split. *)
Definition pole_push_state_only_xz_source_claim : Prop :=
  assigns_array_slot_s A1PPS_USOH._pos 0
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = true /\
  assigns_array_slot_s A1PPS_USOH._pos 1
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_USOH._pos 2
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = true /\
  assigns_array_slot_s A1PPS_USOH._asF32 6
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_USOH._asF32 7
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_USOH._asF32 8
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = false /\
  statement_mentions_ident_s A1PPS_USOH._gMarioStates
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = true /\
  statement_mentions_ident_s A1PPS_USOH._gMarioObject
    (fn_body A1PPS_USOH.f_cur_obj_push_mario_away) = true /\
  assigns_array_slot_s A1PPS_JPOH._pos 0
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = true /\
  assigns_array_slot_s A1PPS_JPOH._pos 1
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_JPOH._pos 2
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = true /\
  assigns_array_slot_s A1PPS_JPOH._asF32 6
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_JPOH._asF32 7
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = false /\
  assigns_array_slot_s A1PPS_JPOH._asF32 8
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = false /\
  statement_mentions_ident_s A1PPS_JPOH._gMarioStates
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = true /\
  statement_mentions_ident_s A1PPS_JPOH._gMarioObject
    (fn_body A1PPS_JPOH.f_cur_obj_push_mario_away) = true.

Theorem pole_push_state_only_xz_source_checked :
  pole_push_state_only_xz_source_claim.
Proof.
  unfold pole_push_state_only_xz_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** This checks the exact call at [bhv_pole_base_loop].  It is not a caller
    census; direct-caller exhaustiveness for this helper and for the broader
    [cur_obj_push_mario_away_from_cylinder] wrapper is a separate question. *)
Definition pole_base_exact_radius_source_claim : Prop :=
  calls_ident_with_float32_arg_s
    A1PPS_USBA._cur_obj_push_mario_away 1116471296
    (fn_body A1PPS_USBA.f_bhv_pole_base_loop) = true /\
  calls_ident_with_float32_arg_s
    A1PPS_JPBA._cur_obj_push_mario_away 1116471296
    (fn_body A1PPS_JPBA.f_bhv_pole_base_loop) = true /\
  calls_ident_with_float32_arg_s
    A1PPS_USBA._cur_obj_push_mario_away 1117126656
    (fn_body A1PPS_USBA.f_bhv_pole_base_loop) = false /\
  calls_ident_with_float32_arg_s
    A1PPS_JPBA._cur_obj_push_mario_away 1117126656
    (fn_body A1PPS_JPBA.f_bhv_pole_base_loop) = false.

Theorem pole_base_exact_radius_source_checked :
  pole_base_exact_radius_source_claim.
Proof.
  unfold pole_base_exact_radius_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The player callback executes Mario's action and then performs the copy.
    The copy writes all three raw Object position components.  This is an AST
    call/assignment receipt, not a theorem that the calls return normally. *)
Definition player_copy_after_action_source_claim : Prop :=
  ident_subsequenceb
    [A1PPS_USOL._execute_mario_action;
     A1PPS_USOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body A1PPS_USOL.f_bhv_mario_update)) = true /\
  assigns_array_slot_s A1PPS_USOL._asF32 6
    (fn_body A1PPS_USOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s A1PPS_USOL._asF32 7
    (fn_body A1PPS_USOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s A1PPS_USOL._asF32 8
    (fn_body A1PPS_USOL.f_copy_mario_state_to_object) = true /\
  ident_subsequenceb
    [A1PPS_JPOL._execute_mario_action;
     A1PPS_JPOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body A1PPS_JPOL.f_bhv_mario_update)) = true /\
  assigns_array_slot_s A1PPS_JPOL._asF32 6
    (fn_body A1PPS_JPOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s A1PPS_JPOL._asF32 7
    (fn_body A1PPS_JPOL.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s A1PPS_JPOL._asF32 8
    (fn_body A1PPS_JPOL.f_copy_mario_state_to_object) = true.

Theorem player_copy_after_action_source_checked :
  player_copy_after_action_source_claim.
Proof.
  unfold player_copy_after_action_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Bounded value-level chronology *)

Record StateObjectXZ (coordinate : Type) : Type := {
  schedule_state_x : coordinate;
  schedule_state_z : coordinate;
  schedule_object_x : coordinate;
  schedule_object_z : coordinate
}.

Arguments schedule_state_x {coordinate} _.
Arguments schedule_state_z {coordinate} _.
Arguments schedule_object_x {coordinate} _.
Arguments schedule_object_z {coordinate} _.

Definition state_only_set_xz {coordinate : Type}
    (next_x next_z : coordinate) (before : StateObjectXZ coordinate) :
    StateObjectXZ coordinate :=
  {| schedule_state_x := next_x;
     schedule_state_z := next_z;
     schedule_object_x := schedule_object_x before;
     schedule_object_z := schedule_object_z before |}.

Definition copy_state_xz_to_object {coordinate : Type}
    (before : StateObjectXZ coordinate) : StateObjectXZ coordinate :=
  {| schedule_state_x := schedule_state_x before;
     schedule_state_z := schedule_state_z before;
     schedule_object_x := schedule_state_x before;
     schedule_object_z := schedule_state_z before |}.

Definition state_object_xz_synchronized {coordinate : Type}
    (snapshot : StateObjectXZ coordinate) : Prop :=
  schedule_state_x snapshot = schedule_object_x snapshot /\
  schedule_state_z snapshot = schedule_object_z snapshot.

Theorem player_copy_resynchronizes_any_state_only_xz_write :
  forall (coordinate : Type) (next_x next_z : coordinate)
         (before : StateObjectXZ coordinate),
    state_object_xz_synchronized
      (copy_state_xz_to_object (state_only_set_xz next_x next_z before)).
Proof. intros; split; reflexivity. Qed.

Theorem preplayer_pole_push_cannot_survive_completed_player_copy :
  forall (coordinate : Type) (after_push after_player : StateObjectXZ coordinate),
    after_player = copy_state_xz_to_object after_push ->
    ~ (schedule_state_x after_player <> schedule_object_x after_player \/
       schedule_state_z after_player <> schedule_object_z after_player).
Proof.
  intros coordinate after_push after_player Hcopy Hsplit.
  subst after_player. destruct Hsplit as [Hsplit | Hsplit];
    apply Hsplit; reflexivity.
Qed.

(** Consequently this writer family can explain an observed final-frame X/Z
    split only if the modeled chronology is escaped: the player copy did not
    complete, or some later State/Object/alias/external writer intervened.
    This disjunction is a logical classification, not a reachability claim. *)
Theorem observed_split_requires_copy_or_postcopy_escape :
  forall (coordinate : Type) (after_push observed : StateObjectXZ coordinate),
    (schedule_state_x observed <> schedule_object_x observed \/
     schedule_state_z observed <> schedule_object_z observed) ->
    observed <> copy_state_xz_to_object after_push.
Proof.
  intros coordinate after_push observed Hsplit Hcopy.
  eapply preplayer_pole_push_cannot_survive_completed_player_copy;
    eauto.
Qed.
