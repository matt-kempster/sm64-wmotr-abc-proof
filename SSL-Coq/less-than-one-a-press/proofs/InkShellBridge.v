(** High shell bridge: constructive execution of the actual quarter-step tail,
    and the actual JP riding-shell result-two branch.  Query-prefix, helper
    executions, scheduler timing and reachable entry remain explicit. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import jp_mario_actions_moving.
From LessThanOneAPress.Proofs Require Import GameTypes InkCrawlQuarterHandoff
  InkFloorHistorySource InkFloorHistoryExecution InkBackwardSource
  InkBackwardExecution InkMovingBackwardSource InkGroundBackwardSource
  InkGroundCallBackward InkSlideHandoff
  InkLandingHistoryReturn ObjectContactNecessity ContactConsumerExecution
  Area2Rank12BContact SecretContactExecution SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition isb_stop_locals le y := PTree.set IFH._t'18 (Vsingle y)
  (PTree.set IFH._t'16 (Vsingle y) le).

Lemma isb_leave_guard_evaluates : forall ge e le m y floor,
  le ! IFH._t'16 = Some (Vsingle y) ->
  le ! IFH._floorHeight = Some (Vsingle floor) ->
  Float32.cmp Cgt y (Float32.add floor ifh_100) = true ->
  eval_expr ge e le m ifh_leave_guard (Vint Int.one).
Proof.
  intros ge e le m y floor Hy Hfloor Hcmp. unfold ifh_leave_guard.
  eapply eval_Ebinop.
  - apply eval_Etempvar. exact Hy.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hfloor.
    + constructor.
    + reflexivity.
  - change (Some (Val.of_bool (Float32.cmp Cgt y
      (Float32.add floor ifh_100))) = Some (Vint Int.one)).
    rewrite Hcmp. reflexivity.
Qed.

Lemma isb_ceiling_guard_evaluates : forall ge e le m y ceiling,
  le ! IFH._t'18 = Some (Vsingle y) ->
  le ! IFH._ceilHeight = Some (Vsingle ceiling) ->
  Float32.cmp Cge (Float32.add y ifh_160) ceiling = true ->
  eval_expr ge e le m ifh_y_ceil_guard (Vint Int.one).
Proof.
  intros ge e le m y ceiling Hy Hceil Hcmp. unfold ifh_y_ceil_guard.
  eapply eval_Ebinop.
  - eapply eval_Ebinop.
    + apply eval_Etempvar. exact Hy.
    + constructor.
    + reflexivity.
  - apply eval_Etempvar. exact Hceil.
  - change (Some (Val.of_bool (Float32.cmp Cge
      (Float32.add y ifh_160) ceiling)) = Some (Vint Int.one)).
    rewrite Hcmp. reflexivity.
Qed.

Definition InkShellHighQuarterExecution : Prop :=
  forall version ge e le m nb no y floor ceiling,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle floor) ->
  le ! IFH._ceilHeight = Some (Vsingle ceiling) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle y) ->
  Float32.cmp Cgt y (Float32.add floor ifh_100) = true ->
  Float32.cmp Cge (Float32.add y ifh_160) ceiling = true ->
  ocn_exec ge e le m (ifh_post_water version) E0
    (isb_stop_locals le y) m (ifh_returned 2).

(** No execution premise: construct the reached, query-free tail itself.
    Entire memory is preserved, hence any entry floor cache is preserved. *)
Theorem isb_high_quarter_tail_executes : InkShellHighQuarterExecution.
Proof.
  unfold InkShellHighQuarterExecution.
  intros version ge e le m nb no y floor ceiling Hnext Hfloor Hceil Hload Hgap Hblock.
  assert (ifh_post_water version = Ssequence (ifh_vertical version)
    (Ssequence (ifh_floor_ceil version) (ifh_accept version))) as Hpost
    by (destruct version; reflexivity).
  destruct (ifh_quarter_source_cuts version)
    as (_ & _ & _ & _ & _ & _ & _ & Hvertical & Hleave & _).
  rewrite Hpost, Hvertical, Hleave. unfold isb_stop_locals.
  eapply exec_Sseq_2; [|discriminate].
  eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
  - apply exec_Sset. eapply icqh_next_y_evaluates; eauto.
  - eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
    + eapply isb_leave_guard_evaluates.
      * apply PTree.gss.
      * rewrite PTree.gso by discriminate. exact Hfloor.
      * exact Hgap.
    + reflexivity.
    + eapply exec_Sseq_2; [|discriminate].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * apply exec_Sset. eapply icqh_next_y_evaluates.
        -- rewrite PTree.gso by discriminate. exact Hnext.
        -- exact Hload.
      * eapply exec_Sifthenelse with (v1 := Vint Int.one) (b := true).
        -- eapply isb_ceiling_guard_evaluates.
           ++ apply PTree.gss.
           ++ repeat rewrite PTree.gso by discriminate. exact Hceil.
           ++ exact Hblock.
        -- reflexivity.
        -- apply exec_Sreturn_some. constructor.
Qed.

Definition isb_samples : list (Z * Z) :=
  [(19840,768);(19840,1280);(19900,768);(19900,1280);
   (25000,768);(25000,1280);(67277,768);(67277,1280);
   (90536,768);(90536,1280)].

Lemma isb_sample_comparisons_checked : forall y floor,
  In (y,floor) isb_samples ->
  Float32.cmp Cgt (icqh_f32 y) (Float32.add (icqh_f32 floor) ifh_100) = true /\
  Float32.cmp Cge (Float32.add (icqh_f32 y) ifh_160) (icqh_f32 20000) = true.
Proof.
  intros y floor Hin. unfold isb_samples in Hin.
  repeat (destruct Hin as [Hin|Hin];
    [inversion Hin; subst; vm_compute; split; reflexivity|]).
  contradiction.
Qed.

Definition InkShellDefaultCeilingIntegerEdge : Prop :=
  Float32.cmp Cge (Float32.add (icqh_f32 19839) ifh_160) (icqh_f32 20000) = false /\
  Float32.cmp Cge (Float32.add (icqh_f32 19840) ifh_160) (icqh_f32 20000) = true /\
  Float32.cmp Cge (Float32.add (icqh_f32 19900) ifh_160) (icqh_f32 20000) = true.
Lemma isb_default_ceiling_integer_edge_checked : InkShellDefaultCeilingIntegerEdge.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition InkShellHighQuarterSamples : Prop :=
  forall y floor, In (y,floor) isb_samples ->
  forall ge e le m nb no,
  le ! IFH._nextPos = Some (Vptr nb no) ->
  le ! IFH._floorHeight = Some (Vsingle (icqh_f32 floor)) ->
  le ! IFH._ceilHeight = Some (Vsingle (icqh_f32 20000)) ->
  Mem.load Mfloat32 m nb
    (Ptrofs.unsigned (Ptrofs.add no (Ptrofs.repr 4))) = Some (Vsingle (icqh_f32 y)) ->
  ocn_exec ge e le m (ifh_post_water VersionJP) E0
    (isb_stop_locals le (icqh_f32 y)) m (ifh_returned 2).

Theorem isb_sample_quarter_tails_execute : InkShellHighQuarterSamples.
Proof.
  intros y floor Hin ge e le m nb no Hnext Hfloor Hceil Hload.
  destruct (isb_sample_comparisons_checked y floor Hin) as [Hgap Hblock].
  eapply isb_high_quarter_tail_executes; eauto.
Qed.

(** Small cuts of the genuine JP shell handler.  The result variable differs
    from the common-slide helper: this is the shell's own _t'4 switch. *)
Definition isb_ground_dispatch := ibk_head (rank12b_drop_sequences 5
  (fn_body jp_mario_actions_moving.f_act_riding_shell_ground)).
Definition isb_dispatch := match isb_ground_dispatch with
| Ssequence _ dispatch => dispatch | _ => Sskip end.
Definition isb_ground_call := Scall (Some IMB._t'4)
  (Evar IMB._perform_ground_step (Tfunction
    [tptr (Tstruct IMB._MarioState noattr)] tint cc_default))
  [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr))].
Definition isb_cases := match isb_dispatch with
| Sswitch _ cases => cases | _ => LSnil end.
Definition isb_two := seq_of_labeled_statement (select_switch 2 isb_cases).
Definition isb_case := ibk_head isb_two.
Definition isb_sound := ibk_head (rank12b_drop_sequences 1 isb_case).
Definition isb_particle := ibk_head (rank12b_drop_sequences 2 isb_case).
Definition isb_stop := Scall None
  (Evar IMB._mario_stop_riding_object (Tfunction
    [tptr (Tstruct IMB._MarioState noattr)] tvoid cc_default))
  [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr))].
Definition isb_request := Scall None
  (Evar IMB._set_mario_action ilh_set_action_type)
  [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr));
   Econst_int (Int.repr 132194) tint; Econst_int Int.zero tint].

Lemma isb_source_cuts_checked :
  isb_dispatch = Sswitch (Etempvar IMB._t'4 tint) isb_cases /\
  isb_two = Ssequence
    (Ssequence isb_stop (Ssequence isb_sound
      (Ssequence isb_particle (Ssequence isb_request Sbreak)))) Sskip /\
  ibk_normal isb_stop = true /\ ibk_normal isb_sound = true /\
  ibk_normal isb_particle = true /\
  cce_keeps_temp IMB._m isb_stop = true /\
  cce_keeps_temp IMB._m isb_sound = true /\
  cce_keeps_temp IMB._m isb_particle = true.
Proof. repeat split; reflexivity. Qed.

Lemma isb_actual_ground_call_sets_its_result :
  forall e le m mb t le' after out,
  e ! IMB._perform_ground_step = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target VersionJP)) e le m
    isb_ground_call t le' after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target VersionJP)) m
      (Internal (igb_body VersionJP)) [Vptr mb Ptrofs.zero] t after result /\
    le' = PTree.set IMB._t'4 result le /\ out = Out_normal.
Proof.
  intros e le m mb t le' after out Hlocal Hm Hrun.
  destruct (igb_selected_body_resolves VersionJP) as (fb & Hsymbol & Hfun).
  unfold isb_ground_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by
      (eapply sce_function_name_value; eauto); subst v end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target VersionJP)) fb = Some fd)
      in Hfind; rewrite Hfun in Hfind; inversion Hfind; subst fd end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IMB._m _) ?v |- _ =>
    assert (v = Vptr mb Ptrofs.zero) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : sem_cast (Vptr mb Ptrofs.zero) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr mb Ptrofs.zero) = Some v) in Hcast;
    inversion Hcast; subst end.
  eexists. split; [eassumption|]. split; reflexivity.
Qed.

Definition InkShellActualGroundResult : Prop :=
  forall e le m mb t le' after out,
  let ge := Clight.globalenv (selected_clight_target VersionJP) in
  e ! IMB._perform_ground_step = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec ge e le m isb_ground_dispatch t le' after out ->
  exists result returned caller_le ground_t dispatch_t,
    t = ground_t ++ dispatch_t /\
    ClightBigstep.Clight2.eval_funcall ge m (Internal (igb_body VersionJP))
      [Vptr mb Ptrofs.zero] ground_t returned result /\
    caller_le = PTree.set IMB._t'4 result le /\
    caller_le ! IMB._m = Some (Vptr mb Ptrofs.zero) /\
    ocn_exec ge e caller_le returned isb_dispatch dispatch_t le' after out.

Theorem isb_real_ground_return_drives_switch : InkShellActualGroundResult.
Proof.
  unfold InkShellActualGroundResult. cbn zeta.
  intros e le m mb t le' after out Hname Hm Hrun.
  assert (isb_ground_dispatch = Ssequence isb_ground_call isb_dispatch)
    as Hshape by reflexivity. rewrite Hshape in Hrun.
  destruct (ibk_split_sequence _ _ _ _ isb_ground_call _ _ _ _ _ eq_refl Hrun)
    as (caller_le & returned & ground_t & dispatch_t & Htrace & Hcall & Hdispatch).
  destruct (isb_actual_ground_call_sets_its_result e le m mb
    ground_t caller_le returned Out_normal Hname Hm Hcall)
    as (result & Hreal & Hcaller & _).
  exists result, returned, caller_le, ground_t, dispatch_t.
  repeat apply conj; try assumption.
  rewrite Hcaller, PTree.gso by discriminate. exact Hm.
Qed.

Definition InkShellStoppedBranchExecution : Prop :=
  forall ge e le m stop_le stop_m sound_le sound_m request_le request_m le' after
    stop_t sound_t particle_t request_t,
  le ! IMB._t'4 = Some (Vint (Int.repr 2)) ->
  ocn_exec ge e le m isb_stop stop_t stop_le stop_m Out_normal ->
  ocn_exec ge e stop_le stop_m isb_sound sound_t sound_le sound_m Out_normal ->
  ocn_exec ge e sound_le sound_m isb_particle particle_t request_le request_m Out_normal ->
  ocn_exec ge e request_le request_m isb_request request_t le' after Out_normal ->
  ocn_exec ge e le m isb_dispatch
    (stop_t ++ sound_t ++ particle_t ++ request_t) le' after Out_normal.

(** Actual helper effects are premises, never replaced by no-op helpers. *)
Theorem isb_stopped_branch_executes : InkShellStoppedBranchExecution.
Proof.
  intros ge e le m stop_le stop_m sound_le sound_m request_le request_m le' after
    stop_t sound_t particle_t request_t Htwo Hstop Hsound Hparticle Hrequest.
  destruct isb_source_cuts_checked as [Hdispatch [Hcase _]]. rewrite Hdispatch.
  eapply exec_Sswitch with (n := 2) (out := Out_break).
  - apply eval_Etempvar. exact Htwo.
  - reflexivity.
  - change (ocn_exec ge e le m isb_two
      (stop_t ++ sound_t ++ particle_t ++ request_t) le' after Out_break).
    rewrite Hcase.
    eapply exec_Sseq_2; [|discriminate].
    eapply exec_Sseq_1; [exact Hstop|].
    eapply exec_Sseq_1; [exact Hsound|].
    eapply exec_Sseq_1; [exact Hparticle|].
    rewrite <- (E0_right request_t).
    eapply exec_Sseq_1; [exact Hrequest|constructor].
Qed.

Lemma isb_request_calls_real_knockback_action :
  forall e le m mb t le' after out,
  e ! IMB._set_mario_action = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target VersionJP)) e le m
    isb_request t le' after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target VersionJP)) m
      (Internal (ilh_set_action_body VersionJP))
      [Vptr mb Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
      t after result /\ le' = le /\ out = Out_normal.
Proof.
  intros e le m mb t le' after out Hlocal Hm Hrun.
  destruct (ilh_selected_set_action_resolves VersionJP) as (fb & Hsymbol & Hfun).
  unfold isb_request, ilh_set_action_type in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by
      (eapply sce_function_name_value; eauto); subst v end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target VersionJP)) fb = Some fd)
      in Hfind; rewrite Hfun in Hfind; inversion Hfind; subst fd end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IMB._m _) ?v |- _ =>
    assert (v = Vptr mb Ptrofs.zero) by (eapply ocn_temp_value; eauto); subst v end.
  repeat match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    apply ocn_const_int_value in Hr; subst end.
  repeat match goal with Hcast : sem_cast ?v _ _ _ = Some ?answer |- _ =>
    change (Some v = Some answer) in Hcast; inversion Hcast; subst; clear Hcast end.
  eexists. split; [eassumption|]. split; reflexivity.
Qed.

Definition InkShellStoppedKnockbackCheckpoint : Prop :=
  forall e le m mb t le' after out,
  let ge := Clight.globalenv (selected_clight_target VersionJP) in
  e ! IMB._set_mario_action = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  le ! IMB._t'4 = Some (Vint (Int.repr 2)) ->
  ocn_exec ge e le m isb_dispatch t le' after out ->
  exists stop_le stop_m sound_le sound_m request_le request_m
    stop_t sound_t particle_t request_t result,
  t = stop_t ++ sound_t ++ particle_t ++ request_t /\
  ocn_exec ge e le m isb_stop stop_t stop_le stop_m Out_normal /\
  ocn_exec ge e stop_le stop_m isb_sound sound_t sound_le sound_m Out_normal /\
  ocn_exec ge e sound_le sound_m isb_particle particle_t request_le request_m Out_normal /\
  request_le ! IMB._m = Some (Vptr mb Ptrofs.zero) /\
  ClightBigstep.Clight2.eval_funcall ge request_m
    (Internal (ilh_set_action_body VersionJP))
    [Vptr mb Ptrofs.zero; Vint (Int.repr 132194); Vint Int.zero]
    request_t after result /\ out = Out_normal.

Theorem isb_stopped_shell_reaches_real_knockback_request :
  InkShellStoppedKnockbackCheckpoint.
Proof.
  unfold InkShellStoppedKnockbackCheckpoint. cbn zeta.
  intros e le m mb t le' after out Hlocal Hm Htwo Hrun.
  destruct isb_source_cuts_checked as
    (Hdispatch & Hcase & HstopN & HsoundN & HparticleN & HstopK & HsoundK & HparticleK).
  rewrite Hdispatch in Hrun. inversion Hrun; subst.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IMB._t'4 _) ?v |- _ =>
    assert (v = Vint (Int.repr 2)) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hswitch : sem_switch_arg _ _ = Some ?n |- _ =>
    change (Some 2 = Some n) in Hswitch; inversion Hswitch; subst n end.
  lazymatch goal with Hr : ClightBigstep.exec_stmt _ ?ge ?env ?temps ?memory
    (seq_of_labeled_statement (select_switch 2 _)) ?rt ?rl ?rm ?ro |- _ =>
    change (ocn_exec ge env temps memory isb_two rt rl rm ro) in Hr;
    rewrite Hcase in Hr; apply ifh_sequence_reassociate in Hr;
    destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ HstopN Hr)
      as (stop_le & stop_m & stop_t & rest_t & Htrace & Hstop & Hrest) end.
  apply ifh_sequence_reassociate in Hrest.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ HsoundN Hrest)
    as (sound_le & sound_m & sound_t & rest_t' & Htrace' & Hsound & Hrest').
  apply ifh_sequence_reassociate in Hrest'.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ HparticleN Hrest')
    as (request_le & request_m & particle_t & request_t' & Htrace'' & Hparticle & Hrest'').
  assert (request_le ! IMB._m = Some (Vptr mb Ptrofs.zero)) as HrequestM.
  { rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ _ Hparticle HparticleK).
    rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ _ Hsound HsoundK).
    rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ _ Hstop HstopK).
    exact Hm. }
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrest''.
  cce_unroll_loop_free_exec.
  all: try solve [match goal with Hcall : ClightBigstep.exec_stmt _ _ _ _ _
    isb_request _ _ _ ?bad, Hbad : ?bad <> Out_normal |- _ =>
    inversion Hcall; subst; contradiction end].
  all: match goal with Hcall : ClightBigstep.exec_stmt _ _ _ _ _
    isb_request ?call_t _ ?call_after _ |- _ =>
    destruct (isb_request_calls_real_knockback_action e request_le request_m mb
      call_t _ call_after _ Hlocal HrequestM Hcall) as (result & Hreal & _);
    exists stop_le, stop_m, sound_le, sound_m, request_le, request_m,
      stop_t, sound_t, particle_t, call_t, result end.
  all: repeat apply conj; try assumption; try reflexivity.
  all: repeat rewrite E0_right; reflexivity.
Qed.

Definition InkShellBridgeBoundary : Prop :=
  InkShellHighQuarterExecution /\ InkShellHighQuarterSamples /\
  InkShellDefaultCeilingIntegerEdge /\
  InkShellActualGroundResult /\ InkShellStoppedBranchExecution /\
  InkShellStoppedKnockbackCheckpoint /\
  InkSlideStoppedAlignmentCheckpoint.

Theorem isb_shell_bridge_boundary_checked : InkShellBridgeBoundary.
Proof.
  split; [exact isb_high_quarter_tail_executes|].
  split; [exact isb_sample_quarter_tails_execute|].
  split; [exact isb_default_ceiling_integer_edge_checked|].
  split; [exact isb_real_ground_return_drives_switch|].
  split; [exact isb_stopped_branch_executes|].
  split; [exact isb_stopped_shell_reaches_real_knockback_request|
    exact isl_stopped_slide_reaches_real_alignment].
Qed.
