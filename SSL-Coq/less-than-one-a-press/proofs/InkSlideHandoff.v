(** Common ground slides: the actual stopped-result switch reaches floor
    alignment after its real bonk/reflection branch.  Branch effects are
    retained, not assumed harmless.  This is a reached-source checkpoint,
    not clean entry, a whole update, or a warp/platform lifecycle theorem. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario_actions_moving jp_mario_actions_moving.
From LessThanOneAPress.Proofs Require Import ASTFacts GameTypes InkBackwardSource
  InkBackwardExecution InkStoppedCrawlAlignment InkGroundBackwardSource
  InkGroundCallBackward InkGroundReturnFrame InkMovingBackwardSource
  InkFloorAlignmentBackward InkFloorHistoryExecution InkPuVpu InkCopyCaller InkFloorResetSource
  ObjectContactNecessity ContactConsumerExecution Area2Rank12BContact
  SecretContactExecution SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition isl_body version := match version with
| VersionUS => us_mario_actions_moving.f_common_slide_action
| VersionJP => jp_mario_actions_moving.f_common_slide_action end.
Definition isl_ground_dispatch version := rank12b_drop_sequences 3 (fn_body (isl_body version)).
Definition isl_dispatch version := match isl_ground_dispatch version with
| Ssequence _ dispatch => dispatch | _ => Sskip end.
Definition isl_cases version := match isl_dispatch version with
| Sswitch _ cases => cases | _ => LSnil end.
Definition isl_two version := seq_of_labeled_statement (select_switch 2 (isl_cases version)).
Definition isl_before_align version := match isl_two version with
| Ssequence (Ssequence first _) _ => first | _ => Sskip end.
Definition isl_ground_call := Scall (Some IMB._t'1)
  (Evar IMB._perform_ground_step (Tfunction
    [tptr (Tstruct IMB._MarioState noattr)] tint cc_default))
  [Etempvar IMB._m (tptr (Tstruct IMB._MarioState noattr))].

Theorem isl_source_cuts_checked : forall version,
  isl_ground_dispatch version = Ssequence isl_ground_call (isl_dispatch version) /\
  isl_dispatch version = Sswitch (Etempvar IMB._t'1 tint) (isl_cases version) /\
  isl_two version = Ssequence
    (Ssequence (isl_before_align version) (Ssequence isca_align_call Sbreak)) Sskip /\
  ibk_normal (isl_before_align version) = true /\
  cce_keeps_temp IMB._m (isl_before_align version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** Resolve the ground call; the switch result is its actual return value. *)
Lemma isl_actual_ground_call_sets_its_result :
  forall version e le m mb t le' after out,
  e ! IMB._perform_ground_step = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    isl_ground_call t le' after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) m
      (Internal (igb_body version)) [Vptr mb Ptrofs.zero] t after result /\
    le' = PTree.set IMB._t'1 result le /\ out = Out_normal.
Proof.
  intros version e le m mb t le' after out Hlocal Hm Hrun.
  destruct (igb_selected_body_resolves version) as (fb & Hsymbol & Hfun).
  unfold isl_ground_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by
      (eapply sce_function_name_value; eauto); subst v end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) fb = Some fd)
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

Definition InkSlideStoppedAlignmentCheckpoint : Prop :=
  forall version e le m mb t le' after out,
  let ge := Clight.globalenv (selected_clight_target version) in
  e ! IMB._align_with_floor = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  le ! IMB._t'1 = Some (Vint (Int.repr 2)) ->
  ocn_exec ge e le m (isl_dispatch version) t le' after out ->
  exists align_le align_m prefix_t align_t result,
    t = prefix_t ++ align_t /\
    ocn_exec ge e le m (isl_before_align version) prefix_t align_le align_m Out_normal /\
    align_le ! IMB._m = Some (Vptr mb Ptrofs.zero) /\
    ClightBigstep.Clight2.eval_funcall ge align_m (Internal (imb_body version IMBAlign))
      [Vptr mb Ptrofs.zero] align_t after result /\
    (forall ob floor,
      Genv.find_symbol ge us_object_list_processor._gMarioStates = Some mb ->
      Genv.find_symbol ge us_object_list_processor._gObjectPool = Some ob ->
      Mem.load Mfloat32 align_m mb 112 = Some (Vsingle floor) ->
      exists snap_m,
        Mem.store Mfloat32 align_m mb 64 (Vsingle floor) = Some snap_m /\
        Mem.load Mfloat32 snap_m mb 64 = Some (Vsingle floor) /\
        (forall chunk offset, Mem.load chunk snap_m ob offset =
          Mem.load chunk align_m ob offset)).

Theorem isl_stopped_slide_reaches_real_alignment : InkSlideStoppedAlignmentCheckpoint.
Proof.
  unfold InkSlideStoppedAlignmentCheckpoint. cbn zeta.
  intros version e le m mb t le' after out Hname Hm Htwo Hrun.
  destruct (isl_source_cuts_checked version) as (_ & Hdispatch & Hcase & Hnormal & Hkeep).
  rewrite Hdispatch in Hrun. inversion Hrun; subst.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar IMB._t'1 _) ?v |- _ =>
    assert (v = Vint (Int.repr 2)) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hswitch : sem_switch_arg _ _ = Some ?n |- _ =>
    change (Some 2 = Some n) in Hswitch; inversion Hswitch; subst n end.
  lazymatch goal with Hr : ClightBigstep.exec_stmt _ ?ge ?env ?temps ?memory
    (seq_of_labeled_statement (select_switch 2 _)) ?rt ?rl ?rm ?ro |- _ =>
    change (ocn_exec ge env temps memory (isl_two version) rt rl rm ro) in Hr;
    rewrite Hcase in Hr;
    apply ifh_sequence_reassociate in Hr;
    destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hr)
      as (align_le & align_m & prefix_t & rest_t & Htrace & Hprefix & Hrest) end.
  assert (align_le ! IMB._m = Some (Vptr mb Ptrofs.zero)) as HalignM.
  { rewrite (cce_argument_temporary_is_preserved _ _ _ _ _ _ _ _ _ _ Hprefix Hkeep).
    exact Hm. }
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrest.
  cce_unroll_loop_free_exec.
  all: try solve [match goal with Hcall : ClightBigstep.exec_stmt _ _ _ _ _
    isca_align_call _ _ _ ?bad, Hbad : ?bad <> Out_normal |- _ =>
    inversion Hcall; subst; contradiction end].
  all: match goal with Hcall : ClightBigstep.exec_stmt _ _ _ _ _
    isca_align_call ?call_t _ ?call_after _ |- _ =>
    destruct (isca_actual_align_call version e align_le align_m mb call_t _ call_after _
      Hname HalignM Hcall) as [result Hreal];
    exists align_le, align_m, prefix_t, call_t, result end.
  all: repeat apply conj; try assumption; try (rewrite E0_right; reflexivity).
  all: intros ob floor Hstate Hpool Hfloor;
    destruct (imb_alignment_copies_entry_floor_and_preserves_object version align_m
      mb ob floor _ _ result Hstate Hpool Hfloor Hreal)
      as (snap_le & snap_m & final_le & final_out & Hstore & Hsnap & Hobject & _);
    exists snap_m; repeat split; assumption.
Qed.

Definition InkSlideActualGroundResult : Prop :=
  forall version e le m mb t le' after out,
  let ge := Clight.globalenv (selected_clight_target version) in
  e ! IMB._perform_ground_step = None ->
  le ! IMB._m = Some (Vptr mb Ptrofs.zero) ->
  ocn_exec ge e le m (isl_ground_dispatch version) t le' after out ->
  exists result returned caller_le ground_t dispatch_t,
    t = ground_t ++ dispatch_t /\
    ClightBigstep.Clight2.eval_funcall ge m (Internal (igb_body version))
      [Vptr mb Ptrofs.zero] ground_t returned result /\
    caller_le = PTree.set IMB._t'1 result le /\
    caller_le ! IMB._m = Some (Vptr mb Ptrofs.zero) /\
    ocn_exec ge e caller_le returned (isl_dispatch version) dispatch_t le' after out.
Theorem isl_real_ground_return_drives_switch : InkSlideActualGroundResult.
Proof.
  unfold InkSlideActualGroundResult. cbn zeta.
  intros version e le m mb t le' after out Hname Hm Hrun.
  rewrite (proj1 (isl_source_cuts_checked version)) in Hrun.
  destruct (ibk_split_sequence _ _ _ _ isl_ground_call _ _ _ _ _ eq_refl Hrun)
    as (caller_le & returned & ground_t & dispatch_t & Htrace & Hcall & Hdispatch).
  destruct (isl_actual_ground_call_sets_its_result version e le m mb
    ground_t caller_le returned Out_normal Hname Hm Hcall)
    as (result & Hreal & Hcaller & _).
  exists result, returned, caller_le, ground_t, dispatch_t.
  repeat apply conj; try assumption.
  rewrite Hcaller, PTree.gso by discriminate. exact Hm.
Qed.

(** Finite sample casts of the REAL floor/ceiling Y statement.  The negative
    VPU aliases equally but does not inherit the raw-height ceiling stop. *)
Definition isl_y_samples : list (Z * Z) :=
  [(-129331,1741);(-63795,1741);(1741,1741);(67277,1741);(132813,1741);
   (-32769,32767);(-32768,-32768);(32767,32767);(32768,-32768)].
Definition InkSlideVpuSampleConversions : Prop :=
  forall actual aliased, In (actual,aliased) isl_y_samples ->
  forall version ceiling ge e le m,
  le ! (ipv_y_input ceiling) = Some (Vsingle (ipv_f32 actual)) ->
  ocn_exec ge e le m (ipv_y_statement version ceiling) E0
    (PTree.set IPV._y (Vint (Int.repr aliased)) le) m Out_normal.
Theorem isl_actual_vpu_sample_y_conversions : InkSlideVpuSampleConversions.
Proof.
  assert (forall m actual aliased, In (actual,aliased) isl_y_samples ->
    sem_cast (Vsingle (ipv_f32 actual)) tfloat tshort m = Some (Vint (Int.repr aliased))) as Hcast.
  { intros m actual aliased Hin. unfold isl_y_samples in Hin.
    repeat (destruct Hin as [Hin|Hin]; [inversion Hin; subst; vm_compute; reflexivity|]).
    contradiction. }
  intros actual aliased Hin version ceiling ge e le m Hy. rewrite ipv_y_source.
  apply exec_Sset. eapply eval_Ecast.
  - eapply eval_Ecast; [apply eval_Etempvar; exact Hy|exact (Hcast m actual aliased Hin)].
  - unfold isl_y_samples in Hin.
    repeat (destruct Hin as [Hin|Hin]; [inversion Hin; subst; vm_compute; reflexivity|]).
    contradiction.
Qed.

(** Finite direct-call census, not reachability.  It pins the six common
    ground-slide paths and the separate slide-kick-slide implementation to
    the generated bodies. Absence of a direct align call does not frame
    arbitrary callees or later updates. *)
Definition isl_source_edges version : list (Clight.function * ident) :=
  match version with
  | VersionUS =>
    [(us_mario_actions_moving.f_act_butt_slide, IMB._common_slide_action_with_jump);
     (us_mario_actions_moving.f_act_hold_butt_slide, IMB._common_slide_action_with_jump);
     (us_mario_actions_moving.f_act_crouch_slide, IMB._common_slide_action_with_jump);
     (us_mario_actions_moving.f_common_slide_action_with_jump, IMB._common_slide_action);
     (us_mario_actions_moving.f_act_stomach_slide, IMB._stomach_slide_action);
     (us_mario_actions_moving.f_act_hold_stomach_slide, IMB._stomach_slide_action);
     (us_mario_actions_moving.f_stomach_slide_action, IMB._common_slide_action);
     (us_mario_actions_moving.f_act_dive_slide, IMB._common_slide_action);
     (us_mario_actions_moving.f_common_slide_action, IMB._align_with_floor);
     (us_mario_actions_moving.f_act_slide_kick_slide, IMB._perform_ground_step)]
  | VersionJP =>
    [(jp_mario_actions_moving.f_act_butt_slide, IMB._common_slide_action_with_jump);
     (jp_mario_actions_moving.f_act_hold_butt_slide, IMB._common_slide_action_with_jump);
     (jp_mario_actions_moving.f_act_crouch_slide, IMB._common_slide_action_with_jump);
     (jp_mario_actions_moving.f_common_slide_action_with_jump, IMB._common_slide_action);
     (jp_mario_actions_moving.f_act_stomach_slide, IMB._stomach_slide_action);
     (jp_mario_actions_moving.f_act_hold_stomach_slide, IMB._stomach_slide_action);
     (jp_mario_actions_moving.f_stomach_slide_action, IMB._common_slide_action);
     (jp_mario_actions_moving.f_act_dive_slide, IMB._common_slide_action);
     (jp_mario_actions_moving.f_common_slide_action, IMB._align_with_floor);
     (jp_mario_actions_moving.f_act_slide_kick_slide, IMB._perform_ground_step)]
  end.
Definition isl_kick_body version := match version with
| VersionUS => us_mario_actions_moving.f_act_slide_kick_slide
| VersionJP => jp_mario_actions_moving.f_act_slide_kick_slide end.
Definition InkSlideSourceCensus : Prop := forall version,
  map (fun edge => calls_ident_s (snd edge) (fn_body (fst edge)))
    (isl_source_edges version) = repeat true 10 /\
  calls_ident_s IMB._align_with_floor (fn_body (isl_kick_body version)) = false /\
  calls_ident_s IMB._common_slide_action (fn_body (isl_kick_body version)) = false.
Theorem isl_slide_source_census_checked : InkSlideSourceCensus.
Proof. intros []; vm_compute; repeat split; reflexivity. Qed.

Definition InkSlideHandoffBoundary : Prop :=
  InkSlideActualGroundResult /\ InkSlideStoppedAlignmentCheckpoint /\
  InkSlideVpuSampleConversions /\ InkSlideSourceCensus.
Theorem isl_slide_handoff_boundary_checked : InkSlideHandoffBoundary.
Proof.
  split; [exact isl_real_ground_return_drives_switch|].
  split; [exact isl_stopped_slide_reaches_real_alignment|].
  split; [exact isl_actual_vpu_sample_y_conversions|
    exact isl_slide_source_census_checked].
Qed.
