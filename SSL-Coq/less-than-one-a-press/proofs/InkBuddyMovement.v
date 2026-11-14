(** Stock cannon Buddy: HOLDABLE pickup preserves its native script and XYZ.
    Pickup actions also fail the native NPC-dialog readiness gate. These are
    actual generated-Clight execution claims, not a proof that a player can
    obtain the required heldObj/usedObj pointer or transport the Buddy. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_behavior_data jp_behavior_data
  us_mario_actions_cutscene jp_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  TeleporterHeldOwnership InkItemDropPlacement InkActionPassStart
  InkBackwardExecution InkBackwardSource InkCopyCaller InkRawCopySource
  ObjectContactNecessity ObjectContactReadback ReadOnlyClightPaths
  EyerokRank15LiveMovement Area1PostCopyChildFrame OrdinaryArea1EntryMemory
  SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module IBMC := us_mario_actions_cutscene.

(** The script word is OR_INT(oFlags, 0x6449): HOLDABLE is 0x400.
    Its native loop remains in the generated behavior initializer. This is a
    finite source certificate, not a behavior-interpreter execution theorem. *)
Definition ibm_buddy_script version := match version with
| VersionUS => us_behavior_data.v_bhvBobombBuddyOpensCannon
| VersionJP => jp_behavior_data.v_bhvBobombBuddyOpensCannon end.
Definition IBMBuddySource : Prop := forall version,
  nth_error (gvar_init (ibm_buddy_script version)) 1 =
    Some (Init_int32 (Int.repr 285303881)) /\
  Int.and (Int.repr 285303881) (Int.repr 65535) = Int.repr 25673 /\
  Int.and (Int.repr 25673) (Int.repr 1024) = Int.repr 1024 /\
  initializer_list_mentions_addrof us_behavior_data._bhv_bobomb_buddy_loop
    (gvar_init (ibm_buddy_script version)) = true.
Theorem ibm_stock_buddy_holdable_source : IBMBuddySource.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Definition IBMBuddyLayout : Prop := forall version,
  ibcc_field_ok (tho_ge version) THO._Object THO._curBhvCommand 460 = true /\
  ibcc_field_ok (tho_ge version) THO._Object THO._bhvStackIndex 464 = true.
Theorem ibm_buddy_layout : IBMBuddyLayout.
Proof.
  intro version. unfold tho_ge.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    THO._Object THO._curBhvCommand 460 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version))
    THO._Object THO._bhvStackIndex 464 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; split; reflexivity.
Qed.

Lemma ibm_address_no_wrap : forall oo delta,
  Ptrofs.unsigned oo + 468 <= Ptrofs.modulus -> 0 <= delta <= 464 ->
  tho_address oo delta = Ptrofs.unsigned oo + delta.
Proof.
  intros oo delta Hspan Hdelta.
  assert (Ptrofs.unsigned (Ptrofs.repr delta) = delta) as Hd.
  { apply Ptrofs.unsigned_repr. change (0 <= delta <= Ptrofs.modulus - 1).
    pose proof (Ptrofs.unsigned_range oo). lia. }
  unfold tho_address, Ptrofs.add. rewrite Hd. apply Ptrofs.unsigned_repr.
  change (0 <= Ptrofs.unsigned oo + delta <= Ptrofs.modulus - 1).
  pose proof (Ptrofs.unsigned_range oo). lia.
Qed.

(** 160/164/168 are raw position XYZ; 460/464 are the checked script fields.
    This consumes the complete helper's two-store execution theorem. *)
Definition IBMHoldablePickupFrame : Prop :=
  forall version before ob oo cb pb po flags carry fourth fifth trace after result
    chunk delta,
  tho_inputs version before ob oo cb pb po flags carry fourth fifth ->
  Ptrofs.unsigned oo + 468 <= Ptrofs.modulus ->
  In delta [160;164;168;460;464] -> 0 < size_chunk chunk <= 4 ->
  ClightBigstep.Clight2.eval_funcall (tho_ge version) before
    (Internal (tho_function version)) [Vptr ob oo; Vptr carry Ptrofs.zero]
    trace after result ->
  Mem.load chunk after ob (tho_address oo delta) =
    Mem.load chunk before ob (tho_address oo delta).
Theorem ibm_holdable_pickup_preserves_position_and_script : IBMHoldablePickupFrame.
Proof.
  intros version before ob oo cb pb po flags carry fourth fifth trace after result
    chunk delta Hinputs Hspan Hdelta Hchunk Hcall.
  destruct (tho_complete_helper_exact_stores _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hinputs Hcall)
    as (_ & _ & middle & Hstore1 & Hstore2).
  assert (0 <= delta <= 464) as Hr by
    (destruct Hdelta as [<-|[<-|[<-|[<-|[<-|[]]]]]]; lia).
  rewrite (ibm_address_no_wrap oo delta Hspan Hr).
  rewrite (ibm_address_no_wrap oo 104 Hspan ltac:(lia)) in Hstore1.
  rewrite (ibm_address_no_wrap oo 292 Hspan ltac:(lia)) in Hstore2.
  rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore2 chunk ob (Ptrofs.unsigned oo + delta)).
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore1 chunk ob (Ptrofs.unsigned oo + delta));
      [reflexivity|right; right; cbn; destruct Hdelta as [<-|[<-|[<-|[<-|[<-|[]]]]]]; lia].
  - destruct Hdelta as [<-|[<-|[<-|[<-|[<-|[]]]]]];
      (right; left; cbn; lia) || (right; right; cbn; lia).
Qed.

Definition ibm_ready_function version := match version with
| VersionUS => us_mario_actions_cutscene.f_mario_ready_to_speak
| VersionJP => jp_mario_actions_cutscene.f_mario_ready_to_speak end.
Definition ibm_ready_prefix version :=
  ocn_prefix_items 3 (fn_body (ibm_ready_function version)).
Definition ibm_ready_return := Sreturn (Some (Etempvar IBMC._isReadyToSpeak tint)).
Definition ibm_pickup_action (action : Z) := In action [899;901;912].

Lemma ibm_ready_shape : forall version,
  fn_body (ibm_ready_function version) =
    ocn_prepend (ibm_ready_prefix version) ibm_ready_return /\
  forallb ibk_normal (ibm_ready_prefix version) = true.
Proof. intros []; split; reflexivity. Qed.

(** Each field read is from the actual selected MarioState action offset.
    All comparisons below are the generated expressions, not a replacement
    high-level model of the dialog gate. *)
Ltac ibm_temp := first [apply PTree.gss |
  rewrite PTree.gso by discriminate; ibm_temp].
Ltac ibm_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Evar _ _) _ => eapply ias_global_read; eassumption
  | |- eval_expr (tho_ge ?version) _ _ _ (Efield _ _ _) _ =>
    eapply ias_field_read with (offset := 12) (chunk := Mint32);
      [exact (ias_selected_action_field version)|reflexivity|
       apply PTree.gss|eassumption]
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
    apply eval_Etempvar; ibm_temp
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => apply eval_Econst_int
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
    eapply eval_Ebinop; [ibm_expr|ibm_expr|reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ => eapply eval_Ecast; [ibm_expr|reflexivity]
  end.

Ltac ibm_path :=
  lazymatch goal with
  | |- readonly_path _ _ _ _ (Ssequence _ _) _ =>
    eapply ro_seq; [ibm_path|ibm_path]
  | |- readonly_path _ _ _ _ (Sset _ _) _ => eapply ro_set; ibm_expr
  | |- readonly_path ?ge ?e ?m ?le (Sifthenelse _ _ ?no) ?final =>
    eapply ro_if with (v := Vint Int.zero) (choice := false);
      [ibm_expr|reflexivity|
        change (readonly_path ge e m le no final); ibm_path]
  | |- readonly_path _ _ _ _ Sskip _ => apply ro_skip
  end.

Lemma ibm_ready_pickup_path : forall version le memory cell mario action,
  Genv.find_symbol (tho_ge version) IBMC._gMarioState = Some cell ->
  Mem.load Mint32 memory cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 memory mario 12 = Some (Vint (Int.repr action)) ->
  ibm_pickup_action action ->
  exists final,
    readonly_path (tho_ge version) empty_env memory le
      (ocn_prepend (ibm_ready_prefix version) Sskip) final /\
    final ! IBMC._isReadyToSpeak = Some (Vint Int.zero).
Proof.
  intros version le memory cell mario action Hsymbol Hpointer Haction Hpickup.
  destruct Hpickup as [<-|[<-|[<-|[]]]]; destruct version;
    (eexists; split;
    [ cbn [ibm_ready_prefix ibm_ready_function ocn_prefix_items ocn_prepend
        us_mario_actions_cutscene.f_mario_ready_to_speak
        jp_mario_actions_cutscene.f_mario_ready_to_speak fn_body];
      ibm_path
    | ibm_temp ]).
Qed.

Definition IBMReadyPickupExclusion : Prop :=
  forall version le memory cell mario action trace final after out,
  Genv.find_symbol (tho_ge version) IBMC._gMarioState = Some cell ->
  Mem.load Mint32 memory cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 memory mario 12 = Some (Vint (Int.repr action)) ->
  ibm_pickup_action action ->
  ocn_exec (tho_ge version) empty_env le memory
    (fn_body (ibm_ready_function version)) trace final after out ->
  trace = E0 /\ after = memory /\
    out = Out_return (Some (Vint Int.zero, tint)).
Theorem ibm_pickup_actions_cannot_pass_npc_readiness : IBMReadyPickupExclusion.
Proof.
  intros version le memory cell mario action trace final after out
    Hsymbol Hpointer Haction Hpickup Hrun.
  destruct (ibm_ready_pickup_path version le memory cell mario action
    Hsymbol Hpointer Haction Hpickup) as (ready & Hpath & Hzero).
  destruct (ibm_ready_shape version) as [Hbody Hnormal]. rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cut & cutmem & pre & post & Htrace & Hprefix & Hreturn).
  destruct (readonly_path_forces_every_execution _ _ _ _ _ _ Hpath _ _ _ _ Hprefix)
    as (-> & -> & -> & _).
  unfold ibm_ready_return in Hreturn. inversion Hreturn; subst.
  match goal with Hvalue : eval_expr _ _ _ _ (Etempvar IBMC._isReadyToSpeak _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocn_temp_value; [exact Hvalue|exact Hzero]);
    subst v end.
  repeat split; reflexivity.
Qed.

(** Applies to a Buddy if its slot is the live heldObj. The conclusion is a
    changed coordinate at the end of the drop-placement tail, not permanent placement or
    a claim that the required pointer arose through legitimate gameplay. *)
Definition IBMDropChangesHeight : Prop := forall version e le memory mb ob slot
    old height trace last after out,
  (slot < object_pool_capacity)%nat -> mb <> ob -> old <> height ->
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr memory mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))) ->
  Mem.load Mfloat32 memory mb 64 = Some (Vsingle height) ->
  Mem.load Mfloat32 memory ob (object_slot_offset slot + 164) = Some (Vsingle old) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le memory
    (idp_placement version) trace last after out ->
  Mem.load Mfloat32 after ob (object_slot_offset slot + 164) = Some (Vsingle height) /\
  Mem.load Mfloat32 after ob (object_slot_offset slot + 164) <>
    Mem.load Mfloat32 memory ob (object_slot_offset slot + 164).
Theorem ibm_actual_drop_changes_actor_height : IBMDropChangesHeight.
Proof.
  intros version e le memory mb ob slot old height trace last after out
    Hslot Hdistinct Hheight Hm Hheld Hy Hold Hrun.
  destruct (idp_drop_tail_places_at_movement_y version e le memory mb ob slot height
    trace last after out Hslot Hdistinct Hm Hheld Hy Hrun) as [Hnew _].
  split; [exact Hnew|]. rewrite Hnew, Hold. congruence.
Qed.

Definition InkBuddyMovementBoundary : Prop :=
  IBMBuddySource /\ IBMBuddyLayout /\ IBMHoldablePickupFrame /\
  IBMReadyPickupExclusion /\ IBMDropChangesHeight /\ InkItemDropPlacementBoundary.
Theorem ibm_buddy_movement_checked : InkBuddyMovementBoundary.
Proof.
  split; [exact ibm_stock_buddy_holdable_source|].
  split; [exact ibm_buddy_layout|].
  split; [exact ibm_holdable_pickup_preserves_position_and_script|].
  split; [exact ibm_pickup_actions_cannot_pass_npc_readiness|].
  split; [exact ibm_actual_drop_changes_actor_height|
    exact ink_item_drop_placement_checked].
Qed.
