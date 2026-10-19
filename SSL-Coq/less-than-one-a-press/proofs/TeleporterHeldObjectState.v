(** Mario's heldObj and an object's own held-state word are separate storage.
    This consumes the real initializer reset. It does not assert a reachable
    full-warp counterexample or preservation through the remaining initializer. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_helpers jp_object_helpers
  us_obj_behaviors jp_obj_behaviors us_mario.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  ObjectContactNecessity TeleporterWrongWarpBoundary TeleporterDestinationReset
  InkRawCopyExpressions InkRawCopySource InkCopyCaller EyerokRank15LiveMovement
  Area1PostCopyChildFrame SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition thos_set_held_function version := match version with
| VersionUS => us_object_helpers.f_obj_set_held_state
| VersionJP => jp_object_helpers.f_obj_set_held_state end.
Definition thos_first_held_assignment version :=
  match fn_body (thos_set_held_function version) with
  | Ssequence _ (Ssequence _
      (Sifthenelse _ (Ssequence (Sifthenelse _ assignment _) _) _)) => assignment
  | _ => Sskip end.
Definition thos_held_lvalue version := Ederef
  (Ebinop Oadd
    (Efield (irc_raw_union version us_object_helpers._obj)
      us_object_helpers._asU32 (tarray tuint 80))
    (Econst_int (Int.repr 39) tint) (tptr tuint)) tuint.

Theorem thos_generated_held_assignment_exact : forall version,
  thos_first_held_assignment version =
    Sassign (thos_held_lvalue version) (Econst_int Int.one tint).
Proof. intros []; reflexivity. Qed.

(** The observed slot39 is the real rawData union at byte136, with its asU32
    member at byte0 and four-byte elements. No whole selected program reduces. *)
Definition THOSSelectedHeldStorageLayout : Prop := forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_object_helpers._Object us_object_helpers._rawData 136 = true /\
  pcc_union_check (prog_comp_env (selected_clight_target version))
    (rank15_raw_union_tag version) us_object_helpers._asU32 = true /\
  136 + 0 + sizeof (Clight.globalenv (selected_clight_target version)) tuint * 39 = 292.
Theorem thos_selected_held_storage_layout : THOSSelectedHeldStorageLayout.
Proof.
  intro version.
  split.
  - change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
      us_object_helpers._Object us_object_helpers._rawData 136 = true).
    rewrite <- rank15_selected_header_environment_exact.
    destruct version; vm_compute; reflexivity.
  - split.
    + rewrite <- rank15_selected_header_environment_exact.
      destruct version; vm_compute; reflexivity.
    + reflexivity.
Qed.

Definition thos_bobomb_loop version := fn_body (match version with
| VersionUS => us_obj_behaviors.f_bhv_bobomb_loop
| VersionJP => jp_obj_behaviors.f_bhv_bobomb_loop end).
Definition thos_bobomb_held_loop version := fn_body (match version with
| VersionUS => us_obj_behaviors.f_bobomb_held_loop
| VersionJP => jp_obj_behaviors.f_bobomb_held_loop end).

(** These are finite source facts, not a theorem executing all Bob-omb behavior. *)
Theorem thos_bobomb_held_follow_source_calls : forall version,
  tww_direct_call_count us_obj_behaviors._bobomb_held_loop
    (thos_bobomb_loop version) = 1%nat /\
  tww_direct_call_count us_obj_behaviors._cur_obj_set_pos_relative
    (thos_bobomb_held_loop version) = 1%nat /\
  statement_mentions_ident_s us_mario._heldObj
    (thos_bobomb_held_loop version) = false.
Proof. intros []; repeat split; reflexivity. Qed.

Definition THOSActualResetPreservesSeparateObjectState : Prop :=
  forall version e le before mb mo ob object_base state trace last after out,
  le ! us_mario._t'90 = Some (Vptr mb mo) ->
  mb <> ob ->
  Mem.load Mint32 before ob (object_base + 292) = Some state ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tww_held_object_reset_statement trace last after out ->
  Mem.load Mptr after mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) /\
  Mem.load Mint32 after ob (object_base + 292) = Some state.

Theorem thos_actual_reset_preserves_separate_object_state :
  THOSActualResetPreservesSeparateObjectState.
Proof.
  intros version e le before mb mo ob object_base state trace last after out
    Htemp Hseparate Hstate Hrun.
  destruct (tdr_reached_held_reset_stores_null version e le before mb mo
    trace last after out Htemp Hrun) as (_ & _ & _ & Hstore & Hnull).
  split; [exact Hnull|].
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore
    Mint32 ob (object_base + 292) ltac:(left; congruence)). exact Hstate.
Qed.

Theorem thos_actual_reset_can_leave_object_held :
  forall version e le before mb mo ob object_base trace last after out,
  le ! us_mario._t'90 = Some (Vptr mb mo) ->
  mb <> ob ->
  Mem.load Mint32 before ob (object_base + 292) = Some (Vint Int.one) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tww_held_object_reset_statement trace last after out ->
  Mem.load Mptr after mb
    (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) = Some (Vint Int.zero) /\
  Mem.load Mint32 after ob (object_base + 292) = Some (Vint Int.one).
Proof. intros; eapply thos_actual_reset_preserves_separate_object_state; eauto. Qed.

Definition TeleporterHeldObjectStateBoundary : Prop :=
  THOSSelectedHeldStorageLayout /\
  (forall version, thos_first_held_assignment version =
    Sassign (thos_held_lvalue version) (Econst_int Int.one tint)) /\
  (forall version,
    tww_direct_call_count us_obj_behaviors._bobomb_held_loop
      (thos_bobomb_loop version) = 1%nat /\
    tww_direct_call_count us_obj_behaviors._cur_obj_set_pos_relative
      (thos_bobomb_held_loop version) = 1%nat /\
    statement_mentions_ident_s us_mario._heldObj
      (thos_bobomb_held_loop version) = false) /\
  THOSActualResetPreservesSeparateObjectState.

Theorem teleporter_held_object_state_boundary_checked : TeleporterHeldObjectStateBoundary.
Proof.
  split; [exact thos_selected_held_storage_layout|].
  split; [exact thos_generated_held_assignment_exact|].
  split; [exact thos_bobomb_held_follow_source_calls|].
  exact thos_actual_reset_preserves_separate_object_state.
Qed.
