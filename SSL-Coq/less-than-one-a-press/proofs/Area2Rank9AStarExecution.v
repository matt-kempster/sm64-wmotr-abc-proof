(** Memory-executed Rank 9A subcases, in the selected US/JP global environment.
    These start at named internal program points, NOT at a controller-derived
    star contact.  In particular, no harmlessness of intervening calls or
    correctness of a cached floor is smuggled into the result. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Coqlib
  Ctypes Errors Events Floats Globalenvs Integers Maps Memory Smallstep Values.
From LessThanOneAPress.Proofs Require Import GameTypes SelectedClightTarget
  Area2Rank11PoleExitSplit Area2Rank11LivePoleExit Area2Rank11HandstandDamage
  EyerokRank15LiveMovement Area2Rank9AStarSource.

Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition rank9a_mask bit := Int.shl Int.one (Int.repr bit).
Definition rank9a_test_locals locals action temporary bit chosen :=
  let loaded := PTree.set temporary (Vint action) locals in
  if Int.eq (Int.and action (rank9a_mask bit)) Int.zero then loaded
  else PTree.set R9I._starGrabAction (Vint (Int.repr chosen)) loaded.

Definition rank9a_selection_locals locals action :=
  rank9a_test_locals
    (rank9a_test_locals
      (rank9a_test_locals
        (PTree.set R9I._starGrabAction (Vint (Int.repr 4871)) locals)
        action R9I._t'11 13 4867)
      action R9I._t'10 14 4867)
    action R9I._t'9 11 6404.

Lemma rank9a_test_preserves_receiver : forall locals action temporary bit chosen,
  temporary <> R9M._m ->
  (rank9a_test_locals locals action temporary bit chosen) ! R9M._m =
    locals ! R9M._m.
Proof.
  intros. unfold rank9a_test_locals.
  destruct (Int.eq _ _);
    repeat rewrite PTree.gso by (first [congruence | discriminate]); reflexivity.
Qed.

Section EXECUTE_SELECTION.
Variable version : GameVersion.
Let ge := Clight.globalenv (selected_clight_target version).

Lemma rank9a_flag_expression_evaluates : forall environment locals memory bit,
  In bit [11; 13; 14] ->
  eval_expr ge environment locals memory (rank11_flag_expression bit)
    (Vint (rank9a_mask bit)).
Proof.
  intros environment locals memory bit Hbit.
  unfold rank11_flag_expression. eapply eval_Ebinop;
    [constructor | constructor |].
  destruct Hbit as [<- | [<- | [<- | []]]]; reflexivity.
Qed.

Lemma rank9a_flag_test_executes : forall environment locals memory mario action
    temporary bit chosen,
  In bit [11; 13; 14] -> temporary <> R9M._m ->
  locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 memory mario 12 = Some (Vint action) ->
  ClightBigstep.Clight2.exec_stmt ge environment locals memory
    (rank9a_select_flag temporary bit chosen) E0
    (rank9a_test_locals locals action temporary bit chosen) memory Out_normal.
Proof.
  intros environment locals memory mario action temporary bit chosen
    Hbit Htemporary Hm Haction.
  unfold rank9a_select_flag, rank9a_test_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sset with (v := Vint action).
    eapply rank11_mario_field_read; eauto; try reflexivity; cbn; auto.
  - eapply exec_Sifthenelse with
      (v1 := Vint (Int.and action (rank9a_mask bit)))
      (b := negb (Int.eq (Int.and action (rank9a_mask bit)) Int.zero)).
    + eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * apply rank9a_flag_expression_evaluates. exact Hbit.
      * reflexivity.
    + reflexivity.
    + destruct (Int.eq _ _) eqn:Hzero; cbn.
      * constructor.
      * apply exec_Sset. constructor.
Qed.

Theorem rank9a_no_exit_selection_executes :
  forall environment locals memory mario action,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! R9I._noExit = Some (Vint Int.one) ->
    Mem.load Mint32 memory mario 12 = Some (Vint action) ->
    ClightBigstep.Clight2.exec_stmt ge environment locals memory
      (rank9a_selection_fragment version) E0
      (rank9a_selection_locals locals action) memory Out_normal.
Proof.
  intros environment locals memory mario action Hm Hnoexit Haction.
  rewrite rank9a_selection_is_generated.
  unfold rank9a_selection_statement, rank9a_selection_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + apply eval_Etempvar. exact Hnoexit.
    + reflexivity.
    + apply exec_Sset. constructor.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply rank9a_flag_test_executes; eauto; try discriminate; try (cbn; auto).
      rewrite PTree.gso by discriminate. exact Hm.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply rank9a_flag_test_executes; eauto; try discriminate; try (cbn; auto).
        rewrite rank9a_test_preserves_receiver by discriminate.
        rewrite PTree.gso by discriminate. exact Hm.
      * eapply rank9a_flag_test_executes; eauto; try discriminate; try (cbn; auto).
        repeat rewrite rank9a_test_preserves_receiver by discriminate.
        rewrite PTree.gso by discriminate. exact Hm.
Qed.

Theorem rank9a_selection_smallsteps :
  forall environment locals memory mario action continuation,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! R9I._noExit = Some (Vint Int.one) ->
    Mem.load Mint32 memory mario 12 = Some (Vint action) ->
    @Smallstep.star _ _ Clight.step2 ge
      (State (rank9a_body version R9Collect) (rank9a_selection_fragment version)
        continuation environment locals memory) E0
      (State (rank9a_body version R9Collect) Sskip continuation environment
        (rank9a_selection_locals locals action) memory).
Proof.
  intros environment locals memory mario action continuation Hm Hnoexit Haction.
  pose proof (rank9a_no_exit_selection_executes environment locals memory mario
    action Hm Hnoexit Haction) as Hexecute.
  destruct (ClightBigstep.exec_stmt_steps Clight.function_entry2
    (selected_clight_target version) _ _ _ _ _ _ _ _ Hexecute
    (rank9a_body version R9Collect) continuation) as (last & Hsteps & Houtcome).
  inversion Houtcome; subst. exact Hsteps.
Qed.
End EXECUTE_SELECTION.

Theorem rank9a_every_attached_pole_pose_selects_standing_dance : forall locals action,
  In action rank9a_attached_actions ->
  (rank9a_selection_locals locals action) ! R9I._starGrabAction =
    Some (Vint (Int.repr 4871)).
Proof.
  intros locals action Haction.
  destruct (rank9a_attached_masks action Haction) as (Hswim & Hmetal & Hair).
  unfold rank9a_selection_locals, rank9a_test_locals, rank9a_mask.
  change (Int.shl Int.one (Int.repr 13)) with (Int.repr 8192).
  change (Int.shl Int.one (Int.repr 14)) with (Int.repr 16384).
  change (Int.shl Int.one (Int.repr 11)) with (Int.repr 2048).
  rewrite Hswim, Hmetal, Hair.
  replace (Int.eq Int.zero Int.zero) with true by reflexivity.
  cbn. rank11_temp.
Qed.

Theorem rank9a_air_flag_always_selects_falling : forall locals action,
  Int.and action (Int.repr 2048) <> Int.zero ->
  (rank9a_selection_locals locals action) ! R9I._starGrabAction =
    Some (Vint (Int.repr 6404)).
Proof.
  intros locals action Hair.
  unfold rank9a_selection_locals, rank9a_test_locals at 1.
  change (rank9a_mask 11) with (Int.repr 2048).
  rewrite Int.eq_false by exact Hair. apply PTree.gss.
Qed.

(** This is the ENTIRE cutscene initializer for the attached-pickup action,
    with arbitrary memory and locals.  It does not touch memory or call out. *)
Theorem rank9a_standing_initializer_is_memory_identity :
  forall version environment locals memory,
    locals ! R9M._action = Some (Vint (Int.repr 4871)) ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (fn_body (rank9a_body version R9Initialize)) E0 locals memory
      (Out_return (Some (Vint (Int.repr 4871), tuint))).
Proof.
  intros version environment locals memory Haction.
  assert (Hshape : fn_body (rank9a_body version R9Initialize) =
    Ssequence (Sswitch (Etempvar R9M._action tuint) (rank9a_initializer_cases version))
      (Sreturn (Some (Etempvar R9M._action tuint)))) by (destruct version; reflexivity).
  rewrite Hshape. eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - eapply exec_Sswitch with (v := Vint (Int.repr 4871)) (n := 4871)
      (out := Out_normal).
    + apply eval_Etempvar. exact Haction.
    + reflexivity.
    + rewrite rank9a_dance_initializer_has_no_selected_case. constructor.
  - apply exec_Sreturn_some. apply eval_Etempvar. exact Haction.
Qed.

(** Two additional real layout facts. *)
Definition rank9a_fields : list (ident * Z) := [(R9M._vel, 72); (R9M._floorHeight, 112)].
Definition rank9a_layout_check environment :=
  match environment ! R9M._MarioState with
  | Some description => forallb (fun entry =>
      rank11_field_offset_check environment (co_members description)
        (fst entry) (snd entry)) rank9a_fields
  | None => false end.

Lemma rank9a_layout_checked : forall version,
  rank9a_layout_check (rank15_selected_header_environment version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma rank9a_field_layout : forall version field offset,
  In (field, offset) rank9a_fields ->
  exists description,
    (genv_cenv (Clight.globalenv (selected_clight_target version))) !
      R9M._MarioState = Some description /\
    field_offset (Clight.globalenv (selected_clight_target version)) field
      (co_members description) = OK (offset, Full).
Proof.
  intros version field offset Hin. pose proof (rank9a_layout_checked version) as H.
  rewrite rank15_selected_header_environment_exact in H.
  unfold rank9a_layout_check in H.
  destruct ((prog_comp_env (selected_clight_target version)) ! R9M._MarioState)
    as [description |] eqn:E; try discriminate.
  exists description. split; [exact E |]. apply rank11_field_offset_check_sound.
  rewrite forallb_forall in H. exact (H (field, offset) Hin).
Qed.

Lemma rank9a_field_lvalue : forall version environment locals memory mario field ty offset,
  locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
  In (field, offset) rank9a_fields ->
  eval_lvalue (Clight.globalenv (selected_clight_target version)) environment locals memory
    (rank11_mario_field_expression field ty) mario (Ptrofs.repr offset) Full.
Proof.
  intros version environment locals memory mario field ty offset Hm Hin.
  destruct (rank9a_field_layout version field offset Hin) as (description & Hco & Hoff).
  replace (Ptrofs.repr offset) with
    (Ptrofs.add Ptrofs.zero (Ptrofs.repr offset)) by
    (rewrite Ptrofs.add_zero_l; reflexivity).
  unfold rank11_mario_field_expression. eapply eval_Efield_struct with (co := description).
  - eapply eval_Elvalue.
    + apply eval_Ederef. apply eval_Etempvar. exact Hm.
    + apply deref_loc_copy. reflexivity.
  - reflexivity.
  - exact Hco.
  - exact Hoff.
Qed.

Theorem rank9a_dance_snap_executes_cached_height :
  forall version environment locals memory mario floor_height,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mfloat32 memory mario 112 = Some (Vsingle floor_height) ->
    Mem.valid_access memory Mfloat32 mario 64 Writable ->
    exists after,
      ClightBigstep.Clight2.exec_stmt
        (Clight.globalenv (selected_clight_target version)) environment locals memory
        (rank9a_snap_fragment version) E0
        (PTree.set R9S._t'2 (Vsingle floor_height) locals) after Out_normal /\
      Mem.load Mfloat32 after mario 64 = Some (Vsingle floor_height) /\
      (forall offset, In offset [60; 68; 76; 112] ->
        Mem.load Mfloat32 after mario offset = Mem.load Mfloat32 memory mario offset).
Proof.
  intros version environment locals memory mario floor_height Hm Hfloor Haccess.
  destruct (Mem.valid_access_store memory Mfloat32 mario 64 (Vsingle floor_height)
    Haccess) as [after Hstore].
  exists after. split.
  - rewrite rank9a_snap_is_generated. unfold rank9a_snap_statement.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply eval_Elvalue with (ofs := Ptrofs.repr 112) (bf := Full).
      * eapply rank9a_field_lvalue; [exact Hm | cbn; auto].
      * eapply deref_loc_value with (chunk := Mfloat32); eauto.
    + eapply exec_Sassign with (loc := mario) (ofs := Ptrofs.repr 64)
        (bf := Full) (v2 := Vsingle floor_height) (v := Vsingle floor_height).
      * unfold rank11_mario_y_expression. apply eval_Ederef. eapply eval_Ebinop.
        -- eapply eval_Elvalue.
           ++ eapply rank11_mario_field_lvalue; [| cbn; auto].
              rewrite PTree.gso by discriminate. exact Hm.
           ++ apply deref_loc_reference. reflexivity.
        -- constructor.
        -- reflexivity.
      * apply eval_Etempvar. apply PTree.gss.
      * reflexivity.
      * eapply assign_loc_value with (chunk := Mfloat32); [reflexivity | exact Hstore].
  - split.
    + erewrite Mem.load_store_same by exact Hstore. reflexivity.
    + intros offset Hoffset. eapply Mem.load_store_other; [exact Hstore |].
      cbn in Hoffset. repeat destruct Hoffset as [<- | Hoffset];
        try contradiction; right; cbn; lia.
Qed.

(** The early return runs the whole ledge-check body, without inspecting any
    wall, intended position or selected floor.  No external effect is needed
    on this branch.  The local variables belong to an already entered call. *)
Theorem rank9a_rising_ledge_check_returns_without_writes :
  forall version environment locals memory mario velocity,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mfloat32 memory mario 76 = Some (Vsingle velocity) ->
    Float32.cmp Cgt velocity Float32.zero = true ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (fn_body (rank9a_body version R9Ledge)) E0
      (PTree.set R9S._t'27 (Vsingle velocity) locals) memory
      (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version environment locals memory mario velocity Hm Hvelocity Hrising.
  assert (Hshape : exists tail, fn_body (rank9a_body version R9Ledge) =
      Ssequence rank9a_ledge_prefix_statement tail)
    by (destruct version; eexists; reflexivity).
  destruct Hshape as [tail Hshape]. rewrite Hshape.
  apply exec_Sseq_2; [| discriminate].
  unfold rank9a_ledge_prefix_statement.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. unfold rank9a_velocity_y_expression.
    eapply eval_Elvalue with (ofs := Ptrofs.repr 76) (bf := Full).
    + apply eval_Ederef. eapply eval_Ebinop.
      * eapply eval_Elvalue.
        -- eapply rank9a_field_lvalue; [exact Hm | cbn; auto].
        -- apply deref_loc_reference. reflexivity.
      * constructor.
      * reflexivity.
    + eapply deref_loc_value with (chunk := Mfloat32); eauto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + eapply eval_Ebinop.
      * apply eval_Etempvar. apply PTree.gss.
      * constructor.
      * change (Some (Val.of_bool (Float32.cmp Cgt velocity Float32.zero)) =
          Some (Vint Int.one)). rewrite Hrising. reflexivity.
    + reflexivity.
    + apply exec_Sreturn_some. constructor.
Qed.

Definition Rank9ASelectedStarBoundary : Prop :=
  (forall version native, exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (rank9a_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank9a_body version native))) /\
  (forall version environment locals memory mario action continuation,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    locals ! R9I._noExit = Some (Vint Int.one) ->
    Mem.load Mint32 memory mario 12 = Some (Vint action) ->
    In action rank9a_attached_actions ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv (selected_clight_target version))
      (State (rank9a_body version R9Collect) (rank9a_selection_fragment version)
        continuation environment locals memory) E0
      (State (rank9a_body version R9Collect) Sskip continuation environment
        (rank9a_selection_locals locals action) memory) /\
    (rank9a_selection_locals locals action) ! R9I._starGrabAction =
      Some (Vint (Int.repr 4871))) /\
  (forall version environment locals memory mario floor_height,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mfloat32 memory mario 112 = Some (Vsingle floor_height) ->
    Mem.valid_access memory Mfloat32 mario 64 Writable ->
    exists after,
      ClightBigstep.Clight2.exec_stmt
        (Clight.globalenv (selected_clight_target version)) environment locals memory
        (rank9a_snap_fragment version) E0
        (PTree.set R9S._t'2 (Vsingle floor_height) locals) after Out_normal /\
      Mem.load Mfloat32 after mario 64 = Some (Vsingle floor_height) /\
      (forall offset, In offset [60; 68; 76; 112] ->
        Mem.load Mfloat32 after mario offset = Mem.load Mfloat32 memory mario offset)) /\
  (forall version environment locals memory mario velocity,
    locals ! R9M._m = Some (Vptr mario Ptrofs.zero) ->
    Mem.load Mfloat32 memory mario 76 = Some (Vsingle velocity) ->
    Float32.cmp Cgt velocity Float32.zero = true ->
    ClightBigstep.Clight2.exec_stmt
      (Clight.globalenv (selected_clight_target version)) environment locals memory
      (fn_body (rank9a_body version R9Ledge)) E0
      (PTree.set R9S._t'27 (Vsingle velocity) locals) memory
      (Out_return (Some (Vint Int.zero, tint)))).

Theorem rank9a_selected_star_boundary_holds : Rank9ASelectedStarBoundary.
Proof.
  split; [exact rank9a_selected_body_resolves |]. split.
  - intros. split; [eapply rank9a_selection_smallsteps; eauto |
      apply rank9a_every_attached_pole_pose_selects_standing_dance; assumption].
  - split; [exact rank9a_dance_snap_executes_cached_height |
      exact rank9a_rising_ledge_check_returns_without_writes].
Qed.
