From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Coqlib Cop
  Ctypes Errors Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_update jp_level_update us_ingame_menu.
From Demo.Proofs Require Import DemoStartExecution DemoGameplayBoundary DemoPauseExclusion
  DemoStartWarpExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module D := us_level_update.

(** The exact suffix after initiate_delayed_warp in play_mode_normal. *)
Definition normal_decision_suffix (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _
      (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ suffix)))))))) => suffix
  | _ => Sskip
  end.

Lemma generated_normal_decision_suffix_identical_us_jp :
  normal_decision_suffix (fn_body D.f_play_mode_normal) =
  normal_decision_suffix (fn_body jp_level_update.f_play_mode_normal).
Proof. reflexivity. Qed.

Lemma generated_normal_decision_suffix_not_empty :
  normal_decision_suffix (fn_body D.f_play_mode_normal) <> Sskip.
Proof. discriminate. Qed.

(** All entries are actual symbol/layout/load facts required by the already
    proved complete pressed_pause call; no callee execution is assumed. *)
Record normal_pause_resources (ge : Clight.genv) (m : mem) : Type := {
  decision_dialog_global : block;
  decision_query_global : block;
  decision_mario_global : block;
  decision_mario : block;
  decision_transition : block;
  decision_operation : block;
  decision_dialog : int;
  decision_action : int;
  decision_op : int;
  decision_active : bool;
  decision_mario_co : composite;
  decision_transition_co : composite;
  decision_dialog_symbol : Genv.find_symbol ge us_ingame_menu._gDialogID =
    Some decision_dialog_global;
  decision_dialog_read : Mem.load Mint16signed m decision_dialog_global 0 =
    Some (Vint decision_dialog);
  decision_query_symbol : Genv.find_symbol ge D._get_dialog_id = Some decision_query_global;
  decision_query_body : Genv.find_funct_ptr ge decision_query_global =
    Some (Internal us_ingame_menu.f_get_dialog_id);
  decision_mario_symbol : Genv.find_symbol ge D._gMarioState = Some decision_mario_global;
  decision_mario_read : Mem.load Mptr m decision_mario_global 0 =
    Some (Vptr decision_mario Ptrofs.zero);
  decision_mario_layout : (genv_cenv ge) ! D._MarioState = Some decision_mario_co;
  decision_action_offset : field_offset (genv_cenv ge) D._action
    (co_members decision_mario_co) = OK (12, Full);
  decision_action_read : Mem.load Mint32 m decision_mario 12 = Some (Vint decision_action);
  decision_transition_symbol : Genv.find_symbol ge D._gWarpTransition = Some decision_transition;
  decision_operation_symbol : Genv.find_symbol ge D._sDelayedWarpOp = Some decision_operation;
  decision_transition_layout : (genv_cenv ge) ! D._WarpTransition = Some decision_transition_co;
  decision_active_offset : field_offset (genv_cenv ge) D._isActive
    (co_members decision_transition_co) = OK (0, Full);
  decision_active_read : Mem.load Mint8unsigned m decision_transition 0 =
    Some (Val.of_bool decision_active);
  decision_operation_read : Mem.load Mint16signed m decision_operation 0 = Some (Vint decision_op);
  decision_pause_blocked : decision_active = true \/ Int.eq decision_op Int.zero = false
}.

Lemma normal_pause_resources_execute : forall ge m,
  normal_pause_resources ge m ->
  eval_funcall function_entry2 ge m (Internal D.f_pressed_pause) [] E0 m Vzero.
Proof.
  intros ge m resources. destruct resources.
  destruct (generated_demo_complete_pause_exclusion_us_jp ge m
    decision_dialog_global0 decision_query_global0 decision_mario_global0
    decision_mario0 decision_transition0 decision_operation0 decision_dialog0
    decision_action0 decision_op0 decision_active0 decision_mario_co0
    decision_transition_co0) as [Hus Hjp]; try assumption.
Qed.

Definition normal_unpaused_decision_temps (le : temp_env) : temp_env :=
  PTree.set D._t'5 Vzero (PTree.set D._t'8 Vzero
    (PTree.set D._t'7 Vzero (PTree.set D._t'6 Vzero le))).

Ltac decision_expr := pause_expr.

Ltac decision_call :=
  eapply exec_Scall with (vargs := []) (vres := Vzero);
    [reflexivity | demo_expr | constructor | cbn; eassumption |
     reflexivity | eassumption].

Ltac decision_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [decision_stmt | decision_stmt]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
    first
      [eapply exec_Sifthenelse with (v1 := Vzero) (b := false);
        [decision_expr | reflexivity | decision_stmt]
      |eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true);
        [decision_expr | reflexivity | decision_stmt]]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ => eapply exec_Sset; decision_expr
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ => decision_call
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
    eapply exec_Sreturn_some; decision_expr
  | |- ?g => idtac "DECISION STATEMENT FAILED" g; fail 1000
  end.

Theorem generated_normal_pending_decision_executes_us_jp :
  forall (ge : Clight.genv) (us : bool) le m mode warp warp_co transition_timer pause_function,
    Genv.find_symbol ge D._sCurrPlayMode = Some mode ->
    Mem.load Mint16signed m mode 0 = Some Vzero ->
    Genv.find_symbol ge D._sWarpDest = Some warp ->
    (genv_cenv ge) ! D._WarpDest = Some warp_co ->
    field_offset (genv_cenv ge) D._type (co_members warp_co) = OK (0, Full) ->
    Mem.load Mint8unsigned m warp 0 = Some Vzero ->
    Genv.find_symbol ge D._sTransitionTimer = Some transition_timer ->
    Mem.load Mint16signed m transition_timer 0 = Some Vzero ->
    Genv.find_symbol ge D._pressed_pause = Some pause_function ->
    Genv.find_funct_ptr ge pause_function = Some (Internal D.f_pressed_pause) ->
    normal_pause_resources ge m ->
    exec_stmt function_entry2 ge empty_env le m
      (normal_decision_suffix (fn_body
        (if us then D.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
      E0 (normal_unpaused_decision_temps le) m (Out_return (Some (Vzero, tint))).
Proof.
  intros ge us le m mode warp warp_co transition_timer pause_function
    Hmode_symbol Hmode Hwarp_symbol Hwarp_co Htype Hwarp
    Htransition_symbol Htransition Hpause_symbol Hpause_body Hresources.
  pose proof (normal_pause_resources_execute ge m Hresources) as Hpause.
  destruct us; unfold normal_unpaused_decision_temps;
    cbn [normal_decision_suffix D.f_play_mode_normal jp_level_update.f_play_mode_normal fn_body];
    decision_stmt.
Qed.

(** Once the delayed demo call has installed change-level mode4, the caller
    bypasses all ordinary warp/transition/pause choices and returns zero. *)
Theorem generated_normal_exit_decision_executes_us_jp :
  forall (ge : Clight.genv) (us : bool) le m mode,
    Genv.find_symbol ge D._sCurrPlayMode = Some mode ->
    Mem.load Mint16signed m mode 0 = Some (Vint (Int.repr 4)) ->
    exec_stmt function_entry2 ge empty_env le m
      (normal_decision_suffix (fn_body
        (if us then D.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
      E0 (PTree.set D._t'6 (Vint (Int.repr 4)) le) m
      (Out_return (Some (Vzero, tint))).
Proof.
  intros ge us le m mode Hsymbol Hmode.
  destruct us; cbn [normal_decision_suffix D.f_play_mode_normal
    jp_level_update.f_play_mode_normal fn_body]; decision_stmt.
Qed.

Lemma normal_pause_resources_load_frame : forall ge before after written,
  forall resources : normal_pause_resources ge before,
  ~ In written [decision_dialog_global ge before resources;
    decision_mario_global ge before resources; decision_mario ge before resources;
    decision_transition ge before resources; decision_operation ge before resources] ->
  (forall chunk b ofs, b <> written ->
    Mem.load chunk after b ofs = Mem.load chunk before b ofs) ->
  normal_pause_resources ge after.
Proof.
  intros ge before after written resources Hseparate Hframe.
  destruct resources.
  cbn in Hseparate.
  refine {| decision_dialog_global := decision_dialog_global0;
    decision_query_global := decision_query_global0;
    decision_mario_global := decision_mario_global0;
    decision_mario := decision_mario0;
    decision_transition := decision_transition0;
    decision_operation := decision_operation0;
    decision_dialog := decision_dialog0;
    decision_action := decision_action0;
    decision_op := decision_op0;
    decision_active := decision_active0;
    decision_mario_co := decision_mario_co0;
    decision_transition_co := decision_transition_co0 |}; try assumption;
    (rewrite Hframe; [assumption | intro Heq; subst; apply Hseparate; cbn; tauto]).
Qed.

Lemma decision_loaded_block_valid : forall chunk m b ofs v,
  Mem.load chunk m b ofs = Some v -> Mem.valid_block m b.
Proof.
  intros chunk m b ofs v Hload.
  eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
  - eapply Mem.load_valid_access; exact Hload.
  - constructor.
Qed.

Lemma normal_pause_resources_preserved_reads : forall ge before after,
  normal_pause_resources ge before ->
  (forall chunk b ofs v, Mem.load chunk before b ofs = Some v ->
    Mem.load chunk after b ofs = Some v) ->
  normal_pause_resources ge after.
Proof.
  intros ge before after resources Hreads. destruct resources.
  refine {| decision_dialog_global := decision_dialog_global0;
    decision_query_global := decision_query_global0;
    decision_mario_global := decision_mario_global0;
    decision_mario := decision_mario0;
    decision_transition := decision_transition0;
    decision_operation := decision_operation0;
    decision_dialog := decision_dialog0;
    decision_action := decision_action0;
    decision_op := decision_op0;
    decision_active := decision_active0;
    decision_mario_co := decision_mario_co0;
    decision_transition_co := decision_transition_co0 |};
    first [assumption | eapply Hreads; eassumption].
Defined.

Definition painting_stack_env (stack : block) : env :=
  PTree.set D._warpNode (stack, Tstruct D._WarpNode noattr) empty_env.

Lemma generated_painting_null_complete_call :
  forall (ge : Clight.genv) m current area area_co,
    Genv.find_symbol ge D._gCurrentArea = Some current ->
    Mem.load Mptr m current 0 = Some (Vptr area Ptrofs.zero) ->
    (genv_cenv ge) ! D._Area = Some area_co ->
    field_offset (genv_cenv ge) D._paintingWarpNodes (co_members area_co) = OK (24, Full) ->
    Mem.load Mptr m area 24 = Some Vzero ->
    exists after,
      eval_funcall function_entry2 ge m (Internal D.f_initiate_painting_warp) [] E0 after Vundef /\
      (forall chunk b ofs, Mem.valid_block m b ->
        Mem.load chunk after b ofs = Mem.load chunk m b ofs) /\
      (forall chunk b ofs permission, Mem.valid_access m chunk b ofs permission ->
        Mem.valid_access after chunk b ofs permission).
Proof.
  intros ge m current area area_co Hcurrent Harea Hco Hoffset Htable.
  set (extent := sizeof (genv_cenv ge) (Tstruct D._WarpNode noattr)).
  destruct (Mem.alloc m 0 extent) as [allocated stack] eqn:Halloc.
  destruct (Mem.range_perm_free allocated stack 0 extent
    ltac:(intros ofs Hrange; eapply Mem.perm_alloc_2; eassumption)) as [after Hfree].
  exists after; split.
  - eapply eval_funcall_internal with (e := painting_stack_env stack)
      (le1 := create_undef_temps (fn_temps D.f_initiate_painting_warp))
      (m1 := allocated) (m2 := allocated) (out := Out_normal).
    + apply function_entry2_intro.
      * constructor; [cbn; tauto | constructor].
      * constructor.
      * unfold list_disjoint; cbn; tauto.
      * eapply alloc_variables_cons with (m1 := allocated) (b1 := stack).
        -- exact Halloc.
        -- constructor.
      * reflexivity.
    + eapply generated_painting_warp_null_table_from_loads with
      (global := current) (area := area) (offset := Ptrofs.zero)
        (co := area_co) (field_offset := 24); try eassumption;
        first [reflexivity | eapply Mem.load_alloc_other; eassumption].
    + reflexivity.
    + change (Mem.free_list allocated [(stack, 0, extent)] = Some after).
      cbn -[Mem.free extent]; rewrite Hfree; reflexivity.
  - split.
    + intros chunk b ofs Hvalid.
      assert (Hdistinct : b <> stack).
      { intro Heq; subst; exact (Mem.fresh_block_alloc _ _ _ _ _ Halloc Hvalid). }
      rewrite (Mem.load_free _ _ _ _ _ Hfree) by (left; exact Hdistinct).
      eapply Mem.load_alloc_unchanged; eassumption.
    + intros chunk b ofs permission Haccess.
      assert (Hvalid : Mem.valid_block m b).
      { eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies.
        - exact Haccess.
        - destruct permission; constructor. }
      eapply Mem.valid_access_free_1; [exact Hfree | |].
      * eapply Mem.valid_access_alloc_other; eassumption.
      * left. intro Heq; subst; exact (Mem.fresh_block_alloc _ _ _ _ _ Halloc Hvalid).
Qed.

Definition normal_postcamera_suffix (body : statement) : statement :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _ (Ssequence _
      (Ssequence _ (Ssequence _ suffix)))))) => suffix
  | _ => Sskip
  end.

Lemma generated_normal_postcamera_suffix_identical_us_jp :
  normal_postcamera_suffix (fn_body D.f_play_mode_normal) =
  normal_postcamera_suffix (fn_body jp_level_update.f_play_mode_normal).
Proof. reflexivity. Qed.

(** A contiguous real caller interval: painting-null call, pending Demo Next
    countdown, ordinary-mode choices, complete pause query, and return. The
    real store's frame supplies the post-countdown pause resources. *)
Definition demo_normal_postcamera_execution_claim : Prop :=
  forall (ge : Clight.genv) (us : bool) le before
    current area area_co painting_function delayed_function
    operation timer mode warp warp_co transition_timer pause_function,
    forall resources : normal_pause_resources ge before,
    Genv.find_symbol ge D._gCurrentArea = Some current ->
    Mem.load Mptr before current 0 = Some (Vptr area Ptrofs.zero) ->
    (genv_cenv ge) ! D._Area = Some area_co ->
    field_offset (genv_cenv ge) D._paintingWarpNodes (co_members area_co) = OK (24, Full) ->
    Mem.load Mptr before area 24 = Some Vzero ->
    Genv.find_symbol ge D._initiate_painting_warp = Some painting_function ->
    Genv.find_funct_ptr ge painting_function = Some (Internal D.f_initiate_painting_warp) ->
    Genv.find_symbol ge D._initiate_delayed_warp = Some delayed_function ->
    Genv.find_funct_ptr ge delayed_function = Some (Internal D.f_initiate_delayed_warp) ->
    Genv.find_symbol ge D._sDelayedWarpOp = Some operation ->
    Genv.find_symbol ge D._sDelayedWarpTimer = Some timer ->
    operation <> timer ->
    Mem.load Mint16signed before operation 0 = Some (Vint (Int.repr 22)) ->
    Mem.load Mint16signed before timer 0 = Some (Vint (Int.repr 20)) ->
    Mem.valid_access before Mint16signed timer 0 Writable ->
    Genv.find_symbol ge D._sCurrPlayMode = Some mode ->
    Mem.load Mint16signed before mode 0 = Some Vzero ->
    Genv.find_symbol ge D._sWarpDest = Some warp ->
    (genv_cenv ge) ! D._WarpDest = Some warp_co ->
    field_offset (genv_cenv ge) D._type (co_members warp_co) = OK (0, Full) ->
    Mem.load Mint8unsigned before warp 0 = Some Vzero ->
    Genv.find_symbol ge D._sTransitionTimer = Some transition_timer ->
    Mem.load Mint16signed before transition_timer 0 = Some Vzero ->
    Genv.find_symbol ge D._pressed_pause = Some pause_function ->
    Genv.find_funct_ptr ge pause_function = Some (Internal D.f_pressed_pause) ->
    mode <> timer -> warp <> timer -> transition_timer <> timer ->
    ~ In timer [decision_dialog_global ge before resources;
      decision_mario_global ge before resources; decision_mario ge before resources;
      decision_transition ge before resources; decision_operation ge before resources] ->
    exists after,
      exec_stmt function_entry2 ge empty_env le before
        (normal_postcamera_suffix (fn_body
          (if us then D.f_play_mode_normal else jp_level_update.f_play_mode_normal)))
        E0 (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint))) /\
      Mem.load Mint16signed after operation 0 = Some (Vint (Int.repr 22)) /\
      Mem.load Mint16signed after timer 0 = Some (Vint (Int.repr 19)) /\
      (forall chunk b ofs, Mem.valid_block before b -> b <> timer ->
        Mem.load chunk after b ofs = Mem.load chunk before b ofs).

Theorem generated_normal_postcamera_interval_executes_us_jp :
  demo_normal_postcamera_execution_claim.
Proof.
  intros ge us le before current area area_co painting_function delayed_function
    operation timer mode warp warp_co transition_timer pause_function resources
    Hcurrent Harea Harea_co Hpainting_offset Hnull Hpainting_symbol Hpainting_body
    Hdelayed_symbol Hdelayed_body Hoperation Htimer Hseparate Hop Htick Hwritable
    Hmode_symbol Hmode Hwarp_symbol Hwarp_co Htype Hwarp Htransition_symbol
    Htransition Hpause_symbol Hpause_body Hmode_sep Hwarp_sep Htransition_sep Hresource_sep.
  destruct (generated_painting_null_complete_call ge before current area area_co
    Hcurrent Harea Harea_co Hpainting_offset Hnull)
    as (painted & Hpainting & Hpainting_frame & Hpainting_access).
  assert (Hpainting_reads : forall chunk b ofs v, Mem.load chunk before b ofs = Some v ->
    Mem.load chunk painted b ofs = Some v).
  { intros chunk b ofs v Hread. rewrite Hpainting_frame.
    - exact Hread.
    - eapply decision_loaded_block_valid; exact Hread. }
  destruct (generated_scheduled_demo_warp_stays_pending_us_jp ge painted operation timer
    Hoperation Htimer Hseparate (Hpainting_reads _ _ _ _ Hop)
    (Hpainting_reads _ _ _ _ Htick) (Hpainting_access _ _ _ _ Hwritable))
    as (after & Hdelayed & Hdelayed_jp & Hop_after & Htick_after & Hframe).
  pose (Hpainted_resources := normal_pause_resources_preserved_reads ge before painted resources
    Hpainting_reads).
  assert (Hpainted_sep : ~ In timer
    [decision_dialog_global ge painted Hpainted_resources;
      decision_mario_global ge painted Hpainted_resources; decision_mario ge painted Hpainted_resources;
      decision_transition ge painted Hpainted_resources; decision_operation ge painted Hpainted_resources]).
  { unfold Hpainted_resources, normal_pause_resources_preserved_reads.
    destruct resources; exact Hresource_sep. }
  pose proof (normal_pause_resources_load_frame ge painted after timer Hpainted_resources
    Hpainted_sep Hframe) as Hafter_resources.
  assert (Hdecision : exec_stmt function_entry2 ge empty_env le after
    (normal_decision_suffix (fn_body D.f_play_mode_normal)) E0
    (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint)))).
  { apply (generated_normal_pending_decision_executes_us_jp ge true le after mode warp
      warp_co transition_timer pause_function); try assumption;
      rewrite Hframe by assumption; apply Hpainting_reads; assumption. }
  exists after; split.
  - assert (Hselected : normal_postcamera_suffix (fn_body
      (if us then D.f_play_mode_normal else jp_level_update.f_play_mode_normal)) =
      normal_postcamera_suffix (fn_body D.f_play_mode_normal)).
    { destruct us; reflexivity. }
    rewrite Hselected.
    change (exec_stmt function_entry2 ge empty_env le before
      (Ssequence
        (Scall None (Evar D._initiate_painting_warp (Tfunction [] tvoid cc_default)) [])
        (Ssequence
          (Scall None (Evar D._initiate_delayed_warp (Tfunction [] tvoid cc_default)) [])
          (normal_decision_suffix (fn_body D.f_play_mode_normal))))
      E0 (normal_unpaused_decision_temps le) after (Out_return (Some (Vzero, tint)))).
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (le1 := le) (m1 := painted).
    + eapply exec_Scall with (vargs := []) (vres := Vundef);
        [reflexivity | demo_expr | constructor | cbn; exact Hpainting_body |
         reflexivity | exact Hpainting].
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0) (le1 := le) (m1 := after).
      * eapply exec_Scall with (vargs := []) (vres := Vundef);
          [reflexivity | demo_expr | constructor | cbn; exact Hdelayed_body |
           reflexivity | exact Hdelayed].
      * exact Hdecision.
  - split; [exact Hop_after | split; [exact Htick_after |]].
    intros chunk b ofs Hvalid Hother.
    rewrite Hframe by exact Hother; apply Hpainting_frame; exact Hvalid.
Qed.
