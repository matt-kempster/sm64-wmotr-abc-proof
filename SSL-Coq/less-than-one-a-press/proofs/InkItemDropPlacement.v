(** Actual non-null item-drop placement.  The earlier helper/music calls are
    retained as real reached prefixes; none is silently assumed to preserve
    the Mario/actor storage.  The placement tail reads movement Y, not HOLP Y.
    This does not establish a reachable high drop or released-actor lifetime.
    Throwing and later object-callback floor clamping are outside this boundary. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import GameTypes InkCopyCaller
  InkBackwardSource InkBackwardExecution InkFloorResetExecution InkBodyResetFrame
  InkRawCopySource InkRawCopyExpressions InkRawCopyStores InkRawCopyCompletion
  TeleporterNullRelease TeleporterBobombRegrab TeleporterHeldOwnership TeleporterDestinationReset
  ObjectContactNecessity ObjectContactReadback ContactConsumerExecution
  EyerokRank15LiveMovement Area1PostCopyChildFrame Area2Rank12BContact
  OrdinaryArea1EntryMemory SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.
Module IDP := us_interaction.

Definition idp_function version := tnr_function version TNRDrop.
Definition idp_effects version := tnr_effects version TNRDrop.
Definition idp_before_placement version := ocn_prefix_items 2 (idp_effects version).
Definition idp_placement version := rank12b_drop_sequences 2 (idp_effects version).
Definition idp_x version := ibk_head (idp_placement version).
Definition idp_y version := ibk_head (rank12b_drop_sequences 1 (idp_placement version)).
Definition idp_z version := ibk_head (rank12b_drop_sequences 2 (idp_placement version)).
Definition idp_yaw version := ibk_head (rank12b_drop_sequences 3 (idp_placement version)).
Definition idp_clear version := rank12b_drop_sequences 4 (idp_placement version).
Definition idp_state := Ederef (Etempvar IDP._m (tptr (Tstruct IDP._MarioState noattr)))
  (Tstruct IDP._MarioState noattr).
Definition idp_position := Efield idp_state IDP._pos (tarray tfloat 3).
Definition idp_source_y := Ederef (Ebinop Oadd idp_position
  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat.
Definition idp_index n := Ebinop Oadd (Econst_int (Int.repr 6) tint)
  (Econst_int (Int.repr n) tint) tint.
Definition idp_y_locals le ob oo height :=
  PTree.set IDP._t'9 (Vsingle height) (PTree.set IDP._t'8 (Vptr ob oo) le).

Theorem idp_generated_cuts : forall version,
  idp_effects version = ocn_prepend (idp_before_placement version) (idp_placement version) /\
  forallb ibk_normal (idp_before_placement version) = true /\
  ifr_keeps_temp IDP._m (ocn_prepend (idp_before_placement version) Sskip) = true /\
  idp_placement version = Ssequence (idp_x version)
    (Ssequence (idp_y version) (Ssequence (idp_z version)
      (Ssequence (idp_yaw version) (idp_clear version)))) /\
  idp_y version = Ssequence (Sset IDP._t'8 tnr_held_read)
    (Ssequence (Sset IDP._t'9 idp_source_y)
      (Sassign (rank15_raw_float_expression version IDP._t'8 (idp_index 1))
        (Etempvar IDP._t'9 tfloat))) /\
  idp_clear version = Sassign tnr_held_read
    (Ecast (Econst_int Int.zero tint) (tptr tvoid)).
Proof. intros []; repeat split; reflexivity. Qed.

Lemma idp_y_read_construct : forall version e le m mb height,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le m
    idp_source_y (Vsingle height).
Proof.
  intros version e le m mb height Htemp Hload.
  destruct (ibcc_field_ok_sound _ _ _ _ (proj1 (ibcc_selected_fields version)))
    as (co & Hco & Hoff).
  unfold idp_source_y. eapply eval_Elvalue with (ofs := Ptrofs.repr 64) (bf := Full).
  - apply eval_Ederef. eapply eval_Ebinop.
    + unfold idp_position, idp_state. eapply eval_Elvalue.
      * eapply eval_Efield_struct with (co := co).
        -- eapply eval_Elvalue.
           ++ apply eval_Ederef. apply eval_Etempvar. exact Htemp.
           ++ apply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- exact Hco.
        -- exact Hoff.
      * apply deref_loc_reference. reflexivity.
    + constructor.
    + reflexivity.
  - eapply deref_loc_value with (chunk := Mfloat32); [reflexivity|exact Hload].
Qed.

Lemma idp_raw_float_array_construct : forall version e le m receiver ob oo,
  le ! receiver = Some (Vptr ob oo) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le m
    (irc_raw_array version receiver) (Vptr ob (Ptrofs.add oo (Ptrofs.repr 136))).
Proof.
  intros version e le m receiver ob oo Htemp.
  destruct (rank15_selected_raw_layout version)
    as (object_type & raw_type & Hobject & Hraw & HobjectOffset & HrawOffset).
  unfold irc_raw_array, irc_raw_union, irc_raw_object.
  rewrite <- (Ptrofs.add_zero (Ptrofs.add oo (Ptrofs.repr 136))).
  eapply eval_Elvalue.
  - eapply eval_Efield_union with (co := raw_type).
    + eapply eval_Elvalue.
      * eapply eval_Efield_struct with (co := object_type).
        -- eapply eval_Elvalue.
           ++ apply eval_Ederef. apply eval_Etempvar. exact Htemp.
           ++ apply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- exact Hobject.
        -- exact HobjectOffset.
      * apply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hraw.
    + exact HrawOffset.
  - apply deref_loc_reference. reflexivity.
Qed.

Lemma idp_y_location_construct : forall version e le m ob oo,
  le ! IDP._t'8 = Some (Vptr ob oo) ->
  eval_lvalue (Clight.globalenv (selected_clight_target version)) e le m
    (rank15_raw_float_expression version IDP._t'8 (idp_index 1)) ob
    (Ptrofs.add oo (Ptrofs.repr 164)) Full.
Proof.
  intros version e le m ob oo Htemp. unfold rank15_raw_float_expression.
  apply eval_Ederef. eapply eval_Ebinop.
  - eapply idp_raw_float_array_construct. exact Htemp.
  - unfold idp_index. eapply eval_Ebinop; [constructor|constructor|reflexivity].
  - change (Some (Vptr ob (Ptrofs.add (Ptrofs.add oo (Ptrofs.repr 136))
      (Ptrofs.repr 28))) = Some (Vptr ob (Ptrofs.add oo (Ptrofs.repr 164)))).
    rewrite Ptrofs.add_assoc. reflexivity.
Qed.

(** Construct the actual generated Y stage from ordinary readable/writable
    cells. No execution oracle and no HOLP-Y hypothesis is present. *)
Theorem idp_y_placement_executes : forall version e le m mb ob oo height after,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob oo) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  Mem.store Mfloat32 m ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 164)))
    (Vsingle height) = Some after ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (idp_y version) E0 (idp_y_locals le ob oo height) after Out_normal.
Proof.
  intros version e le m mb ob oo height after Htemp Hheld Hheight Hstore.
  destruct (idp_generated_cuts version) as (_ & _ & _ & _ & Hy & _).
  rewrite Hy. unfold idp_y_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply tnr_actual_held_read; [exact Htemp|exact Hheld].
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply idp_y_read_construct.
      * rewrite PTree.gso by discriminate. exact Htemp.
      * exact Hheight.
    + eapply exec_Sassign with (v := Vsingle height) (v2 := Vsingle height)
        (loc := ob) (ofs := Ptrofs.add oo (Ptrofs.repr 164)) (bf := Full).
      * apply idp_y_location_construct. rewrite PTree.gso by discriminate. apply PTree.gss.
      * apply eval_Etempvar. apply PTree.gss.
      * reflexivity.
      * eapply assign_loc_value with (chunk := Mfloat32); [reflexivity|exact Hstore].
Qed.

Definition InkItemDropYStageExists : Prop := forall version e le m mb ob oo height,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob oo) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  Mem.valid_access m Mfloat32 ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 164))) Writable ->
  exists after, ocn_exec (Clight.globalenv (selected_clight_target version))
    e le m (idp_y version) E0 (idp_y_locals le ob oo height) after Out_normal /\
    Mem.load Mfloat32 after ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 164))) =
      Some (Vsingle height).
Corollary idp_y_placement_exists : InkItemDropYStageExists.
Proof.
  intros version e le m mb ob oo height Htemp Hheld Hheight Hvalid.
  destruct (Mem.valid_access_store _ _ _ _ (Vsingle height) Hvalid) as [after Hstore].
  exists after. split.
  - eapply idp_y_placement_executes; eauto.
  - rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore). reflexivity.
Qed.

Theorem idp_actual_y_placement : forall version e le m mb ob oo height t last after out,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob oo) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (idp_y version) t last after out ->
  Mem.store Mfloat32 m ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 164)))
    (Vsingle height) = Some after /\
  last = idp_y_locals le ob oo height /\ t = E0 /\ out = Out_normal.
Proof.
  intros version e le m mb ob oo height t last after out Hm Hheld Hy Hrun.
  destruct (idp_generated_cuts version) as (_ & _ & _ & _ & Hshape & _).
  rewrite Hshape in Hrun. unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: match goal with Hr : eval_expr _ _ _ _ tnr_held_read ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocr_expr_unique; [exact Hr|
      eapply tnr_actual_held_read; [exact Hm|exact Hheld]]); subst v end.
  all: match goal with Hr : eval_expr _ _ _ _ idp_source_y ?v |- _ =>
    assert (v = Vsingle height) by (eapply ocr_expr_unique; [exact Hr|
      eapply idp_y_read_construct; [rewrite PTree.gso by discriminate; exact Hm|exact Hy]]);
    subst v end.
  all: match goal with Ha : ClightBigstep.exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  all: try contradiction.
  lazymatch goal with Hl : eval_lvalue _ ?actual_e ?actual_le ?actual_m _ _ _ _ |- _ =>
    assert (actual_le ! IDP._t'8 = Some (Vptr ob oo)) as Hreceiver
      by (rewrite PTree.gso by discriminate; apply PTree.gss);
    destruct (irc_raw_location version actual_e actual_le actual_m IDP._t'8 (idp_index 1) 7 ob oo _ _ _
      Hreceiver eq_refl eq_refl
      ltac:(cbn; auto) Hl) as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IDP._t'9 _) ?v |- _ =>
    assert (v = Vsingle height) by (eapply ocn_temp_value; [exact Hr|apply PTree.gss]);
    subst v end.
  match goal with Hcast : sem_cast _ _ _ _ = Some ?v |- _ =>
    change (Some (Vsingle height) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn in Hmode; inversion Hmode; subst end.
  repeat split; try reflexivity; assumption.
Qed.

Definition idp_other_stage version receiver prefix angle index rhs :=
  Ssequence (Sset receiver tnr_held_read)
    (ocn_prepend prefix (Sassign (ircc_lhs version receiver angle index) rhs)).
Definition idp_stage_ok version number s : Prop :=
  exists receiver prefix angle index rhs,
    s = idp_other_stage version receiver prefix angle index rhs /\
    forallb ibk_normal prefix = true /\
    cce_readonly_keep receiver (ocn_prepend prefix Sskip) = true /\
    typeof index = tint /\ irc_constant index = Some (Int.repr number) /\
    (angle = false /\ number = 6 \/ In number ircc_numbers).

Ltac idp_stage_receipt prefix_count angle number :=
  lazymatch goal with |- idp_stage_ok _ _ ?s =>
    let body := eval cbv [idp_x idp_z idp_yaw idp_placement idp_effects
      tnr_effects tnr_function fn_body rank12b_drop_sequences ibk_head
      us_interaction.f_mario_drop_held_object jp_interaction.f_mario_drop_held_object] in s in
    lazymatch body with Ssequence (Sset ?receiver _) ?rest =>
      let count := eval compute in (Z.to_nat prefix_count) in
      let prefix := eval cbn [ocn_prefix_items] in (ocn_prefix_items count rest) in
      let store := eval cbn [rank12b_drop_sequences] in (rank12b_drop_sequences count rest) in
      lazymatch store with Sassign ?lhs ?rhs =>
        let index := lazymatch lhs with Ederef (Ebinop Oadd _ ?idx _) _ => idx end in
        unfold idp_stage_ok; exists receiver, prefix, angle, index, rhs;
        repeat split; try reflexivity; cbv [ircc_numbers In]; auto 12
      end
    end
  end.

Lemma idp_other_stages_checked : forall version,
  idp_stage_ok version 6 (idp_x version) /\
  idp_stage_ok version 8 (idp_z version) /\
  idp_stage_ok version 16 (idp_yaw version) /\
  ibk_normal (idp_x version) = true /\ ibk_normal (idp_y version) = true /\
  ibk_normal (idp_z version) = true /\ ibk_normal (idp_yaw version) = true /\
  ifr_keeps_temp IDP._m (idp_x version) = true /\
  ifr_keeps_temp IDP._m (idp_z version) = true /\
  ifr_keeps_temp IDP._m (idp_yaw version) = true.
Proof.
  intros [].
  all: split; [idp_stage_receipt 2 false 6|].
  all: split; [idp_stage_receipt 2 false 8|].
  all: split; [idp_stage_receipt 1 true 16|].
  all: repeat split; reflexivity.
Qed.

Lemma idp_other_stage_store : forall version e le m mb ob oo number s t last after out,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob oo) ->
  idp_stage_ok version number s ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m s t last after out ->
  exists chunk value, size_chunk chunk = 4 /\
    Mem.store chunk m ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (136 + 4 * number))))
      value = Some after.
Proof.
  intros version e le m mb ob oo number s t last after out Hm Hheld
    (receiver & prefix & angle & index & rhs & -> & Hnormal & Hpure & Htype & Hconstant & Hnumber)
    Hrun.
  unfold idp_other_stage in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset receiver tnr_held_read)
    _ _ _ _ _ eq_refl Hrun) as (read_le & read_m & pre & rest & _ & Hread & Hrest).
  inversion Hread; subst.
  match goal with Hr : eval_expr _ _ _ _ tnr_held_read ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocr_expr_unique; [exact Hr|
      eapply tnr_actual_held_read; [exact Hm|exact Hheld]]); subst v end.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrest)
    as (store_le & store_m & prefix_t & store_t & _ & Hprefix & Hstore).
  destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ _ Hprefix Hpure)
    as (_ & -> & Hreceiver).
  assert (store_le ! receiver = Some (Vptr ob oo)) as Hptr
    by (rewrite Hreceiver; apply PTree.gss).
  inversion Hstore; subst.
  lazymatch goal with Hl : eval_lvalue ?ge ?env ?temps ?memory _ _ _ _ |- _ =>
    assert (forall b ofs bf, eval_lvalue ge env temps memory
      (ircc_lhs version receiver angle index) b ofs bf ->
      b = ob /\ ofs = Ptrofs.add oo (Ptrofs.repr (136 + 4 * number)) /\ bf = Full)
      as Hlocation end.
  { intros target_block target_offset target_bits Hl. destruct Hnumber as [[-> ->]|Hnumber].
    - eapply irc_raw_location; eauto. cbn; auto.
    - eapply ircc_raw_location; eauto. }
  match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    destruct (Hlocation _ _ _ Hl) as (-> & -> & ->) end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => inversion Ha; subst end.
  - destruct angle.
    all: match goal with Hmode : access_mode _ = By_value _ |- _ =>
      cbn [ircc_lhs pcc_scalar access_mode] in Hmode; inversion Hmode; subst end.
    all: do 2 eexists; split; [|eassumption]; reflexivity.
  - match goal with Hmode : access_mode _ = By_copy |- _ =>
      destruct angle; cbn [ircc_lhs pcc_scalar access_mode] in Hmode; discriminate end.
Qed.

Lemma idp_other_stage_frames : forall version e le m mb ob slot number s t last after out,
  (slot < object_pool_capacity)%nat -> mb <> ob ->
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))) ->
  In number [6;8;16] -> idp_stage_ok version number s ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m s t last after out ->
  Mem.load Mptr after mb 124 = Mem.load Mptr m mb 124 /\
  Mem.load Mfloat32 after mb 64 = Mem.load Mfloat32 m mb 64 /\
  Mem.load Mfloat32 after ob (object_slot_offset slot + 164) =
    Mem.load Mfloat32 m ob (object_slot_offset slot + 164).
Proof.
  intros version e le m mb ob slot number s t last after out Hslot Hdistinct Hm Hheld
    Hnumber Hshape Hrun.
  destruct (idp_other_stage_store _ _ _ _ _ _ _ _ _ _ _ _ _ Hm Hheld Hshape Hrun)
    as (chunk & value & Hsize & Hstore).
  assert (0 <= 136 + 4 * number <= 288) as Hrange
    by (destruct Hnumber as [<-|[<-|[<-|[]]]]; lia).
  rewrite ircc_slot_address in Hstore by assumption.
  split; [eapply Mem.load_store_other; [exact Hstore|left; exact Hdistinct]|].
  split; [eapply Mem.load_store_other; [exact Hstore|left; exact Hdistinct]|].
  eapply Mem.load_store_other; [exact Hstore|]. right.
  rewrite Hsize. cbn [size_chunk].
  destruct Hnumber as [<-|[<-|[<-|[]]]]; [right|left|left]; lia.
Qed.

Lemma idp_clear_actual_store : forall version e le m mb t last after out,
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (idp_clear version) t last after out ->
  Mem.store Mptr m mb 124 (Vint Int.zero) = Some after /\
  last = le /\ t = E0 /\ out = Out_normal.
Proof.
  intros version e le m mb t last after out Hm Hrun.
  destruct (idp_generated_cuts version) as (_ & _ & _ & _ & _ & Hclear).
  rewrite Hclear in Hrun. inversion Hrun; subst.
  lazymatch goal with Hl : eval_lvalue _ _ _ _ tnr_held_read _ _ _ |- _ =>
    unfold tnr_held_read in Hl;
    destruct (ibcc_field_location (Clight.globalenv (selected_clight_target version))
      _ _ _ idp_state IDP._MarioState IDP._heldObj
      (tptr (Tstruct IDP._Object noattr)) mb Ptrofs.zero 124 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Hm|eassumption])
      (tdr_selected_held_field_layout version) Hl) as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
    apply cce_cast_zero_value in Hr; subst end.
  match goal with Hcast : sem_cast _ _ _ _ = Some ?v |- _ =>
    change (Some (Vint Int.zero) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn in Hmode; inversion Hmode; subst end.
  repeat split; try reflexivity; assumption.
Qed.

(** Completed placement, from the real post-helper memory.  The X/Z source
    values need not be constrained: their actual stores cannot change the
    movement-Y read or the final actor-Y cell under this ordinary separation. *)
Definition InkItemDropPlacementTail : Prop := forall version e le m mb ob slot
    height t last after out,
  (slot < object_pool_capacity)%nat -> mb <> ob ->
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (idp_placement version) t last after out ->
  Mem.load Mfloat32 after ob (object_slot_offset slot + 164) = Some (Vsingle height) /\
  Mem.load Mfloat32 after mb 64 = Some (Vsingle height) /\
  Mem.load Mptr after mb 124 = Some (Vint Int.zero).

Theorem idp_drop_tail_places_at_movement_y : InkItemDropPlacementTail.
Proof.
  intros version e le m mb ob slot height t last after out Hslot Hdistinct Hm Hheld Hy Hrun.
  destruct (idp_generated_cuts version) as (_ & _ & _ & Htail & _).
  destruct (idp_other_stages_checked version)
    as (Hxshape & Hzshape & HangleShape & Hxnormal & Hynormal & Hznormal &
      HangleNormal & Hxkeep & Hzkeep & HangleKeep).
  rewrite Htail in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hxnormal Hrun)
    as (xl & xm & xt & xrest & _ & Hx & Hafterx).
  destruct (idp_other_stage_frames version e le m mb ob slot 6 _ _ _ _ _
    Hslot Hdistinct Hm Hheld ltac:(cbn; auto) Hxshape Hx) as (Hxheld & Hxy & _).
  assert (xl ! IDP._m = Some (Vptr mb Ptrofs.zero)) as Hxm
    by (rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hx Hxkeep); exact Hm).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hynormal Hafterx)
    as (yl & ym & yt & yrest & _ & Hystage & Haftery).
  destruct (idp_actual_y_placement version e xl xm mb ob _ height _ _ _ _
    Hxm ltac:(rewrite Hxheld; exact Hheld) ltac:(rewrite Hxy; exact Hy) Hystage)
    as (Hystore & Hyl & _).
  assert (yl ! IDP._m = Some (Vptr mb Ptrofs.zero)) as Hym.
  { rewrite Hyl. unfold idp_y_locals. repeat rewrite PTree.gso by discriminate. exact Hxm. }
  assert (Mem.load Mptr ym mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))))
    as Hyheld by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hystore)
      by (left; exact Hdistinct); rewrite Hxheld; exact Hheld).
  assert (Mem.load Mfloat32 ym mb 64 = Some (Vsingle height)) as Hystate
    by (rewrite (Mem.load_store_other _ _ _ _ _ _ Hystore)
      by (left; exact Hdistinct); rewrite Hxy; exact Hy).
  assert (Mem.load Mfloat32 ym ob (object_slot_offset slot + 164) = Some (Vsingle height))
    as Hyactor.
  { rewrite ircc_slot_address in Hystore by (auto; lia).
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hystore). reflexivity. }
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hznormal Haftery)
    as (zl & zm & zt & zrest & _ & Hz & Hafterz).
  destruct (idp_other_stage_frames version e yl ym mb ob slot 8 _ _ _ _ _
    Hslot Hdistinct Hym Hyheld ltac:(cbn; auto) Hzshape Hz) as (Hzheld & Hzy & Hza).
  assert (zl ! IDP._m = Some (Vptr mb Ptrofs.zero)) as Hzm
    by (rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hz Hzkeep); exact Hym).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ HangleNormal Hafterz)
    as (al & am & angle_trace & arest & _ & Hangle & Hclear).
  destruct (idp_other_stage_frames version e zl zm mb ob slot 16 _ _ _ _ _
    Hslot Hdistinct Hzm ltac:(rewrite Hzheld; exact Hyheld)
    ltac:(cbn; auto) HangleShape Hangle) as (_ & Hay & Haa).
  assert (al ! IDP._m = Some (Vptr mb Ptrofs.zero)) as Ham
    by (rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hangle HangleKeep); exact Hzm).
  destruct (idp_clear_actual_store _ _ _ _ _ _ _ _ _ Ham Hclear) as (Hnull & _).
  split.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hnull) by (left; congruence).
    rewrite Haa, Hza. exact Hyactor.
  - split.
    + rewrite (Mem.load_store_other _ _ _ _ _ _ Hnull)
        by (right; left; cbn [size_chunk]; lia).
      rewrite Hay, Hzy. exact Hystate.
    + rewrite (Mem.load_store_same _ _ _ _ _ _ Hnull). reflexivity.
Qed.

Lemma idp_nonnull_guard : forall ge e le m ob oo,
  le ! IDP._t'2 = Some (Vptr ob oo) ->
  ~ ocn_test_value ge e le m tnr_guard false.
Proof.
  intros ge e le m ob oo Hheld [answer [Hexpr Hbool]].
  unfold tnr_guard in Hexpr. inversion Hexpr; subst.
  - match goal with Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
      assert (v = Vptr ob oo) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with Hcast : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      apply cce_cast_zero_value in Hcast; subst end.
    match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some answer |- _ =>
      change (option_map Val.of_bool (Val.cmpu_bool (Mem.valid_pointer m) Cne
        (Vptr ob oo) (Vint Int.zero)) = Some answer) in Hsem;
      cbn [Val.cmpu_bool] in Hsem;
      repeat match type of Hsem with context [if ?test then _ else _] =>
        destruct test eqn:?; cbn in Hsem; try discriminate end;
      inversion Hsem; subst; discriminate end.
  - match goal with Hl : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hl end.
Qed.

(** The whole actual call supplies the placement cut and its Mario argument.
    Its earlier callbacks are kept as actual executions, not read-only claims.
    The useful postcondition is then conditional on the cut's concrete loads. *)
Definition InkItemDropActualCallBoundary : Prop := forall version memory mb ob oo
    trace after result,
  Mem.load Mptr memory mb 124 = Some (Vptr ob oo) ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (idp_function version)) [Vptr mb Ptrofs.zero] trace after result ->
  exists cut_le cut_m last pre suf out,
    trace = pre ++ suf /\
    cut_le ! IDP._m = Some (Vptr mb Ptrofs.zero) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      (PTree.set IDP._t'2 (Vptr ob oo) (tnr_entry_temps version TNRDrop mb Ptrofs.zero))
      memory (ocn_prepend (idp_before_placement version) Sskip)
      pre cut_le cut_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      cut_le cut_m (idp_placement version) suf last after out /\
    (forall slot height,
      (slot < object_pool_capacity)%nat -> mb <> ob ->
      Mem.load Mptr cut_m mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))) ->
      Mem.load Mfloat32 cut_m mb 64 = Some (Vsingle height) ->
      Mem.load Mfloat32 after ob (object_slot_offset slot + 164) = Some (Vsingle height) /\
      Mem.load Mfloat32 after mb 64 = Some (Vsingle height) /\
      Mem.load Mptr after mb 124 = Some (Vint Int.zero)).

Theorem idp_actual_drop_call_exposes_placement : InkItemDropActualCallBoundary.
Proof.
  intros version memory mb ob oo trace after result Hheld Hcall.
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    destruct (tnr_actual_entry version TNRDrop _ memory mb Ptrofs.zero _ _ _ Hentry)
      as (-> & -> & Hm) end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?final |- _ =>
    change (Some before = Some final) in Hfree; inversion Hfree; subst end.
  assert (forall actual_le,
    function_entry2 (Clight.globalenv (selected_clight_target version))
      (idp_function version) [Vptr mb Ptrofs.zero] memory empty_env actual_le memory ->
    actual_le = tnr_entry_temps version TNRDrop mb Ptrofs.zero) as HentryTemps.
  { intros actual_le Hentry. inversion Hentry; subst.
    match goal with Hbind : bind_parameter_temps _ _ _ = Some actual_le |- _ =>
      destruct version; cbn in Hbind; inversion Hbind; reflexivity end. }
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    pose proof (HentryTemps _ Hentry) as Hle; subst end.
  destruct (tnr_generated_shape version TNRDrop) as (_ & _ & _ & Hbody).
  lazymatch goal with Hrun : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    unfold idp_function in Hrun; rewrite Hbody in Hrun;
    destruct (ibk_split_sequence _ _ _ _ (Sset IDP._t'2 tnr_held_read)
      _ _ _ _ _ eq_refl Hrun) as (checked & checked_m & check_t & rest_t & Htrace & Hread & Hchoice)
  end.
  inversion Hread; subst.
  match goal with Hr : eval_expr _ _ _ _ tnr_held_read ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocr_expr_unique; [exact Hr|
      eapply tnr_actual_held_read; [exact Hm|exact Hheld]]); subst v end.
  inversion Hchoice; subst. destruct b.
  - destruct (idp_generated_cuts version) as (Heffects & Hnormal & Hkeep & _).
    lazymatch goal with Haccepted : ClightBigstep.exec_stmt _ ?ge ?env ?locals ?memory
      (tnr_effects version TNRDrop) ?events ?final_locals ?final_memory ?outcome |- _ =>
      change (ocn_exec ge env locals memory (idp_effects version)
        events final_locals final_memory outcome) in Haccepted;
      rewrite Heffects in Haccepted;
      destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Haccepted)
        as (cut_le & cut_m & pre & suf & Hsplit & Hprefix & Htail) end.
    assert (cut_le ! IDP._m = Some (Vptr mb Ptrofs.zero)) as HcutM.
    { rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hprefix Hkeep).
      rewrite PTree.gso by discriminate. exact Hm. }
    do 6 eexists. split; [exact Hsplit|].
    split; [exact HcutM|]. split; [exact Hprefix|]. split; [exact Htail|].
    intros. eapply idp_drop_tail_places_at_movement_y; eauto.
  - exfalso. eapply idp_nonnull_guard; [apply PTree.gss|].
    unfold ocn_test_value. eauto.
Qed.

Definition InkItemDropDifferentHeightExcluded : Prop := forall version e le m mb ob slot
    height desired t last after out,
  (slot < object_pool_capacity)%nat -> mb <> ob -> height <> desired ->
  le ! IDP._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mptr m mb 124 = Some (Vptr ob (Ptrofs.repr (object_slot_offset slot))) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (idp_placement version) t last after out ->
  Mem.load Mfloat32 after ob (object_slot_offset slot + 164) <> Some (Vsingle desired).

Theorem idp_drop_cannot_substitute_a_different_holp_height : InkItemDropDifferentHeightExcluded.
Proof.
  intros version e le m mb ob slot height desired t last after out
    Hslot Hdistinct Hdifferent Hm Hheld Hheight Hrun.
  destruct (idp_drop_tail_places_at_movement_y version e le m mb ob slot height t last after out
    Hslot Hdistinct Hm Hheld Hheight Hrun) as [Hy _].
  rewrite Hy. intro Heq. inversion Heq. contradiction.
Qed.

Definition InkItemDropPlacementBoundary : Prop :=
  InkItemDropYStageExists /\ InkItemDropPlacementTail /\
  InkItemDropActualCallBoundary /\ InkItemDropDifferentHeightExcluded.
Theorem ink_item_drop_placement_checked : InkItemDropPlacementBoundary.
Proof.
  split; [exact idp_y_placement_exists|].
  split; [exact idp_drop_tail_places_at_movement_y|].
  split; [exact idp_actual_drop_call_exposes_placement|
    exact idp_drop_cannot_substitute_a_different_holp_height].
Qed.
