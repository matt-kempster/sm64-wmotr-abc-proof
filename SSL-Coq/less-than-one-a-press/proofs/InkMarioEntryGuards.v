(** Entry/retention checkpoints from the actual generated Mario bodies.
    A null floor after interactions retains memory but returns before action
    dispatch.  LEFT_GROUND is distinct from a stopped quarter: its caller
    branch selects an air action, rather than the caller's floor alignment.
    These are local execution boundaries, not global route exclusions. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario jp_mario.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes InkBackwardSource
  InkBackwardExecution InkActionPassHistory InkActionPassStart InkCopyCaller
  InkBodyResetHistory InkControllerEdge
  InkFloorHistoryQuery InkFloorHistoryExecution InkStoppedCrawlAlignment InkSlideHandoff
  InkMovingBackwardSource InkGroundCallBackward InkLandingHistoryReturn
  ObjectContactNecessity ContactConsumerExecution Area2Rank12BContact
  SecretContactExecution SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition imeg_mtemp version := match version with
| VersionUS => us_mario._t'42 | VersionJP => jp_mario._t'38 end.
Definition imeg_ftemp version := match version with
| VersionUS => us_mario._t'43 | VersionJP => jp_mario._t'39 end.
Definition imeg_guard version := ibk_head (iap_after_preparation version).
Definition imeg_after_guard version := match iap_after_preparation version with
| Ssequence _ rest => rest | _ => Sskip end.
Definition imeg_test version := Ebinop Oeq
  (Etempvar (imeg_ftemp version) (tptr (Tstruct IBM._Surface noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.
Definition imeg_return := Sreturn (Some (Econst_int Int.zero tint)).
Definition imeg_null_locals version le mario :=
  PTree.set (imeg_ftemp version) Vnullptr
    (PTree.set (imeg_mtemp version) (Vptr mario Ptrofs.zero) le).

Lemma imeg_generated_floor_gate : forall version,
  iap_after_preparation version =
    Ssequence (imeg_guard version) (imeg_after_guard version) /\
  imeg_guard version = Ssequence (Sset (imeg_mtemp version) ias_global)
    (Ssequence
      (Sset (imeg_ftemp version)
        (ias_field (imeg_mtemp version) IBM._floor (tptr (Tstruct IBM._Surface noattr))))
      (Sifthenelse (imeg_test version) imeg_return Sskip)) /\
  cce_readonly_keep IBM._inLoop (imeg_guard version) = true /\
  calls_ident_s IBM._mario_execute_moving_action (imeg_guard version) = false /\
  calls_ident_s IBM._mario_execute_moving_action (imeg_after_guard version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Lemma imeg_null_test_evaluates_true : forall version ge e le m,
  le ! (imeg_ftemp version) = Some Vnullptr ->
  eval_expr ge e le m (imeg_test version) (Vint Int.one).
Proof.
  intros version ge e le m Hfloor. unfold imeg_test.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hfloor.
  - eapply eval_Ecast; [constructor|reflexivity].
  - reflexivity.
Qed.

(** Construct the actual guard execution from real global/field loads; no
    completed action execution or floor-miss reachability is assumed. *)
Theorem imeg_null_floor_constructs_guard_return : forall version le m cell mario,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IBM._gMarioState = Some cell ->
  Mem.load Mint32 m cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 104 = Some Vnullptr ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
    (imeg_guard version) E0 (imeg_null_locals version le mario) m
    (Out_return (Some (Vint Int.zero, tint))).
Proof.
  intros version le m cell mario Hsymbol Hglobal Hfloor.
  rewrite (proj1 (proj2 (imeg_generated_floor_gate version))).
  unfold imeg_null_locals.
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply ias_global_read; eauto.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + apply exec_Sset. eapply ias_field_read with (chunk := Mint32) (offset := 104).
      * exact (ifh_selected_floor_pointer_field version).
      * reflexivity.
      * apply PTree.gss.
      * exact Hfloor.
    + eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
      * apply imeg_null_test_evaluates_true. apply PTree.gss.
      * reflexivity.
      * apply exec_Sreturn_some. constructor.
Qed.

Definition InkMarioNullFloorConstruction : Prop :=
  forall version le m cell mario,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IBM._gMarioState = Some cell ->
  Mem.load Mint32 m cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 104 = Some Vnullptr ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
    (iap_after_preparation version) E0 (imeg_null_locals version le mario) m
    (Out_return (Some (Vint Int.zero, tint))).

Theorem imeg_null_floor_bypasses_action_dispatch : InkMarioNullFloorConstruction.
Proof.
  intros version le m cell mario Hsymbol Hglobal Hfloor.
  rewrite (proj1 (imeg_generated_floor_gate version)).
  apply exec_Sseq_2; [eapply imeg_null_floor_constructs_guard_return; eauto|discriminate].
Qed.

Lemma imeg_null_test_value : forall version ge e le m answer,
  le ! (imeg_ftemp version) = Some Vnullptr ->
  eval_expr ge e le m (imeg_test version) answer -> answer = Vint Int.one.
Proof.
  intros version ge e le m answer Hfloor Hr.
  unfold imeg_test in Hr. inversion Hr; subst.
  2: match goal with Hbad : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hbad end.
  match goal with Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    assert (v = Vnullptr) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inversion Hcast; subst end.
  2: match goal with Hbad : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion Hbad end.
  match goal with Hconst : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    apply ocn_const_int_value in Hconst; subst end.
  match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ =>
    cbn in Hcast; inversion Hcast; subst end.
  match goal with Hsem : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    change (Some (Vint Int.one) = Some answer) in Hsem; congruence end.
Qed.

Lemma imeg_null_floor_guard_is_forced : forall version le m cell mario t le' after out,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IBM._gMarioState = Some cell ->
  Mem.load Mint32 m cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 104 = Some Vnullptr ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
    (imeg_guard version) t le' after out ->
  t = E0 /\ le' = imeg_null_locals version le mario /\ after = m /\
  out = Out_return (Some (Vint Int.zero, tint)).
Proof.
  intros version le m cell mario t le' after out Hsymbol Hglobal Hfloor Hrun.
  rewrite (proj1 (proj2 (imeg_generated_floor_gate version))) in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (Sset (imeg_mtemp version) ias_global)
    _ _ _ _ _ eq_refl Hrun) as (middle & memory & pre & suf & Htrace & Hread & Hrest).
  inversion Hread; subst; clear Hread.
  match goal with Hr : eval_expr _ _ _ _ ias_global ?v |- _ =>
    assert (v = Vptr mario Ptrofs.zero) by (eapply ibr_global_read_value; eauto); subst v end.
  destruct (ibk_split_sequence _ _ _ _
    (Sset (imeg_ftemp version) (ias_field (imeg_mtemp version) IBM._floor
      (tptr (Tstruct IBM._Surface noattr)))) _ _ _ _ _ eq_refl Hrest)
    as (middle2 & memory2 & pre2 & suf2 & Htrace2 & Hread & Hbranch).
  inversion Hread; subst; clear Hread.
  match goal with Hr : eval_expr _ _ _ _ (ias_field _ _ _) ?v |- _ =>
    assert (v = Vnullptr) by (eapply ice_field_read with
      (id := imeg_mtemp version) (tag := IBM._MarioState)
      (field := IBM._floor) (ty := tptr (Tstruct IBM._Surface noattr))
      (b := mario) (ofs := Ptrofs.zero) (delta := 104) (chunk := Mint32);
      [apply PTree.gss|exact (ifh_selected_floor_pointer_field version)|reflexivity|
       exact Hfloor|exact Hr]); subst v end.
  inversion Hbranch; subst; clear Hbranch.
  match goal with Hr : eval_expr _ _ _ _ (imeg_test version) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply imeg_null_test_value; [apply PTree.gss|exact Hr]); subst v end.
  match goal with Hb : bool_val (Vint Int.one) _ _ = Some ?choice |- _ =>
    change (Some true = Some choice) in Hb; inversion Hb; subst end.
  cbn beta iota in *.
  match goal with Hr : ClightBigstep.exec_stmt _ _ _ _ _ imeg_return _ _ _ _ |- _ =>
    inversion Hr; subst end.
  match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    apply ocn_const_int_value in Hr; subst end.
  repeat split; reflexivity.
Qed.

Definition InkMarioNullFloorExclusion : Prop :=
  forall version le m cell mario t le' after out,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IBM._gMarioState = Some cell ->
  Mem.load Mint32 m cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 m mario 104 = Some Vnullptr ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
    (iap_after_preparation version) t le' after out ->
  t = E0 /\ after = m /\ out = Out_return (Some (Vint Int.zero, tint)).

Theorem imeg_null_floor_forces_return_before_dispatch : InkMarioNullFloorExclusion.
Proof.
  intros version le m cell mario t le' after out Hsymbol Hglobal Hfloor Hrun.
  rewrite (proj1 (imeg_generated_floor_gate version)) in Hrun.
  inversion Hrun; subst.
  all: match goal with Hg : ClightBigstep.exec_stmt _ _ _ _ _ (imeg_guard ?ver) _ _ _ _ |- _ =>
    destruct (imeg_null_floor_guard_is_forced ver _ _ _ _ _ _ _ _
      ltac:(eassumption) ltac:(eassumption) ltac:(eassumption) Hg)
      as (Ht & Hl & Hm & Ho) end.
  - discriminate.
  - repeat split; assumption.
Qed.

(** Reattach to the shared real preparation history, including interactions.
    The null premise concerns its resulting memory, not an earlier query. *)
Definition InkMarioPreparedNullPass : Prop :=
  forall version le m ready ready_m pre cell mario,
  iap_stage_chain (Clight.globalenv (selected_clight_target version)) empty_env
    le m (iap_stages version) pre ready ready_m ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IBM._gMarioState = Some cell ->
  Mem.load Mint32 ready_m cell 0 = Some (Vptr mario Ptrofs.zero) ->
  Mem.load Mint32 ready_m mario 104 = Some Vnullptr ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le m
    (iap_enabled version) pre (imeg_null_locals version ready mario) ready_m
    (Out_return (Some (Vint Int.zero, tint))).

Lemma imeg_append_stage_chain : forall ge e le m items pre ready ready_m suffix
  post final final_m out,
  iap_stage_chain ge e le m items pre ready ready_m ->
  ocn_exec ge e ready ready_m suffix post final final_m out ->
  ocn_exec ge e le m (ocn_prepend items suffix) (pre ++ post) final final_m out.
Proof.
  intros ge e le m items pre ready ready_m suffix post final final_m out Hchain.
  induction Hchain; intro Hsuffix; [exact Hsuffix|].
  cbn [ocn_prepend]. rewrite <- app_assoc.
  eapply exec_Sseq_1; [exact H|apply IHHchain; exact Hsuffix].
Qed.

Theorem imeg_actual_preparation_then_null_floor_returns : InkMarioPreparedNullPass.
Proof.
  intros version le m ready ready_m pre cell mario Hchain Hsymbol Hglobal Hfloor.
  rewrite (proj1 (iap_generated_preparation version)).
  replace pre with (pre ++ E0) by apply app_nil_r.
  eapply imeg_append_stage_chain; [exact Hchain|].
  eapply imeg_null_floor_bypasses_action_dispatch; eauto.
Qed.

(** The LEFT_GROUND caller branch is a different reached cut from the
    stopped-result alignment checkpoint.  The actual selected switch executes
    the request for FREEFALL (crawl) or its airAction parameter (common slide),
    then breaks before the other cases.  We retain all callee effects; absence
    below concerns the caller's direct align_with_floor call, not transitive
    effects of arbitrary callees or the rest of a Mario update. *)
Definition imeg_move_dispatch version (crawl : bool) :=
  if crawl then isca_dispatch version else isl_dispatch version.
Definition imeg_move_cases version (crawl : bool) :=
  if crawl then isca_cases version else isl_cases version.
Definition imeg_move_temp (crawl : bool) := if crawl then IMB._t'8 else IMB._t'1.
Definition imeg_left_sequence version crawl :=
  seq_of_labeled_statement (select_switch 0 (imeg_move_cases version crawl)).
Definition imeg_left_branch version crawl := ibk_head (imeg_left_sequence version crawl).
Definition imeg_left_unused version crawl := match imeg_left_sequence version crawl with
| Ssequence _ rest => rest | _ => Sskip end.
Definition imeg_left_items version (crawl : bool) :=
  ocn_prefix_items (if crawl then 1%nat else 2%nat) (imeg_left_branch version crawl).
Definition imeg_air_request (crawl : bool) := Scall None
  (Evar IMB._set_mario_action (Tfunction
    [tptr (Tstruct IMB._MarioState noattr); tuint; tuint] tuint cc_default))
  [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr));
   if crawl then Econst_int (Int.repr 16779404) tint else Etempvar IMB._airAction tuint;
   Econst_int Int.zero tint].

Lemma imeg_generated_left_ground_cases : forall version crawl,
  imeg_move_dispatch version crawl =
    Sswitch (Etempvar (imeg_move_temp crawl) tint) (imeg_move_cases version crawl) /\
  imeg_left_sequence version crawl =
    Ssequence (imeg_left_branch version crawl) (imeg_left_unused version crawl) /\
  imeg_left_branch version crawl = ocn_prepend (imeg_left_items version crawl) Sbreak /\
  forallb ibk_normal (imeg_left_items version crawl) = true /\
  hd Sskip (imeg_left_items version crawl) = imeg_air_request crawl /\
  calls_ident_s IMB._align_with_floor (imeg_left_branch version crawl) = false /\
  calls_ident_s IMB._align_with_floor (imeg_left_unused version crawl) = true.
Proof. intros [] []; repeat split; reflexivity. Qed.

Lemma imeg_left_branch_executes_then_breaks : forall version crawl ge e le m t le' after out,
  ocn_exec ge e le m (imeg_left_branch version crawl) t le' after out ->
  out = Out_break /\
  ocn_exec ge e le m (ocn_prepend (imeg_left_items version crawl) Sskip)
    t le' after Out_normal.
Proof.
  intros version crawl ge e le m t le' after out Hrun.
  destruct (imeg_generated_left_ground_cases version crawl)
    as (_ & _ & Hshape & Hnormal & _).
  rewrite Hshape in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & pre & suf & Htrace & Hprefix & Hbreak).
  inversion Hbreak; subst. rewrite E0_right. split; [reflexivity|exact Hprefix].
Qed.

Definition InkMarioLeftGroundCallerCheckpoint : Prop :=
  forall version crawl ge e le m t le' after out,
  le ! (imeg_move_temp crawl) = Some (Vint Int.zero) ->
  ocn_exec ge e le m (imeg_move_dispatch version crawl) t le' after out ->
  out = Out_normal /\
  ocn_exec ge e le m (imeg_left_branch version crawl) t le' after Out_break /\
  ocn_exec ge e le m (ocn_prepend (imeg_left_items version crawl) Sskip)
    t le' after Out_normal /\
  hd Sskip (imeg_left_items version crawl) = imeg_air_request crawl /\
  calls_ident_s IMB._align_with_floor (imeg_left_branch version crawl) = false /\
  calls_ident_s IMB._align_with_floor (imeg_left_unused version crawl) = true.

Theorem imeg_left_ground_breaks_before_caller_alignment : InkMarioLeftGroundCallerCheckpoint.
Proof.
  intros version crawl ge e le m t le' after out Hzero Hrun.
  destruct (imeg_generated_left_ground_cases version crawl)
    as (Hdispatch & Hselected & _ & _ & Hrequest & Hnoalign & Hunused).
  rewrite Hdispatch in Hrun. inversion Hrun; subst.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar (imeg_move_temp crawl) _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Harg : sem_switch_arg _ _ = Some ?n |- _ =>
    change (Some 0 = Some n) in Harg; inversion Harg; subst n end.
  lazymatch goal with Hr : ClightBigstep.exec_stmt _ ?rge ?renv ?rle ?rm
    (seq_of_labeled_statement (select_switch 0 _)) ?rt ?rl ?ram ?ro |- _ =>
    change (ocn_exec rge renv rle rm (imeg_left_sequence version crawl) rt rl ram ro) in Hr;
    rewrite Hselected in Hr; inversion Hr; subst end.
  all: match goal with Hb : ClightBigstep.exec_stmt _ _ _ _ _
    (imeg_left_branch ?ver ?cr) _ _ _ _ |- _ =>
    destruct (imeg_left_branch_executes_then_breaks ver cr _ _ _ _ _ _ _ _ Hb)
      as (Hout & Hprefix) end.
  - discriminate.
  - subst. repeat split; assumption || reflexivity.
Qed.

Definition InkMarioEntryGuardBoundary : Prop :=
  InkMarioNullFloorConstruction /\ InkMarioNullFloorExclusion /\
  InkMarioPreparedNullPass /\ InkMarioLeftGroundCallerCheckpoint.
Theorem imeg_mario_entry_guards_checked : InkMarioEntryGuardBoundary.
Proof.
  split; [exact imeg_null_floor_bypasses_action_dispatch|].
  split; [exact imeg_null_floor_forces_return_before_dispatch|].
  split; [exact imeg_actual_preparation_then_null_floor_returns|
    exact imeg_left_ground_breaks_before_caller_alignment].
Qed.
