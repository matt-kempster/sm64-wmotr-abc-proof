(** The final platform query is made from raw Object coordinates, not from
    State or display coordinates. Extract its real callee and memory effects
    from the selected generated body. No relation between the three views,
    live-floor result, or frame for find_floor is assumed. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes InkPlatformSource
  InkPlatformDeparture InkPlatformDistance InkRawCopyExpressions InkCopyCompletion
  InkBackwardSource InkBackwardExecution InkCopyCaller InkFloorResetExecution
  ObjectContactNecessity ContactConsumerExecution SecretContactExecution
  EyerokRank15LiveMovement Area2Rank12BContact UpperElevatorQueryResolution
  SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition r1q_receiver axis := match axis with
| ICPX => IPD._t'16 | ICPY => IPD._t'15 | ICPZ => IPD._t'14 end.
Definition r1q_coordinate axis := match axis with
| ICPX => IPD._marioX | ICPY => IPD._marioY | ICPZ => IPD._marioZ end.
Definition r1q_index axis := Ebinop Oadd (Econst_int (Int.repr 6) tint)
  (Econst_int (Int.repr (icp_number axis)) tint) tint.
Definition r1q_read version axis := rank15_raw_float_expression version
  (r1q_receiver axis) (r1q_index axis).
Definition r1q_stage version axis := Ssequence
  (Sset (r1q_receiver axis) (Evar IPD._gMarioObject ipd_object))
  (Sset (r1q_coordinate axis) (r1q_read version axis)).
Definition r1q_call := Scall (Some IPD._t'1)
  (Evar IPD._find_floor (Tfunction
    [tfloat; tfloat; tfloat; tptr ipd_surface] tfloat cc_default))
  [Etempvar IPD._marioX tfloat; Etempvar IPD._marioY tfloat;
   Etempvar IPD._marioZ tfloat; Eaddrof (Evar IPD._floor ipd_surface) (tptr ipd_surface)].
Definition r1q_query := Ssequence r1q_call
  (Sset IPD._floorHeight (Etempvar IPD._t'1 tfloat)).
Definition r1q_segment version := rank12b_drop_sequences 1
  (fn_body (ipd_body version IPDUpdate)).
Definition r1q_temps le ob oo values :=
  PTree.set IPD._marioZ (Vsingle (values ICPZ))
    (PTree.set IPD._t'14 (Vptr ob oo)
      (PTree.set IPD._marioY (Vsingle (values ICPY))
        (PTree.set IPD._t'15 (Vptr ob oo)
          (PTree.set IPD._marioX (Vsingle (values ICPX))
            (PTree.set IPD._t'16 (Vptr ob oo) le))))).

Lemma r1q_generated_segment : forall version,
  r1q_segment version = Ssequence (r1q_stage version ICPX)
    (Ssequence (r1q_stage version ICPY)
      (Ssequence (r1q_stage version ICPZ)
        (Ssequence r1q_query (ipdist_tail version)))).
Proof. intros []; reflexivity. Qed.

Lemma r1q_raw_value : forall version e le m axis ob oo value answer,
  le ! (r1q_receiver axis) = Some (Vptr ob oo) ->
  Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)))) =
      Some (Vsingle value) ->
  eval_expr (Clight.globalenv (selected_clight_target version)) e le m
    (r1q_read version axis) answer -> answer = Vsingle value.
Proof.
  intros version e le m axis ob oo value answer Htemp Hload Hr.
  assert (forall b ofs bf,
    eval_lvalue (Clight.globalenv (selected_clight_target version)) e le m
      (r1q_read version axis) b ofs bf ->
    b = ob /\ ofs = Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)) /\ bf = Full) as Hloc.
  { intros b ofs bf Hl. inversion Hl; subst.
    match goal with H : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ => inversion H; subst; clear H end.
    - match goal with H : eval_expr _ _ _ _ (Efield _ _ _) ?v |- _ =>
        assert (v = Vptr ob (Ptrofs.add oo (Ptrofs.repr 136))) by
          (eapply irc_raw_array_value; eauto); subst v end.
      lazymatch goal with H : eval_expr _ _ _ _ (r1q_index axis) ?v |- _ =>
        assert (v = Vint (Int.repr (6 + icp_number axis))) by
          (eapply (irc_constant_read _ _ _ _ (r1q_index axis));
            [destruct axis; reflexivity|exact H]); subst v end.
      match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
        cbn [typeof r1q_index] in H; cbn in H; inversion H; subst end.
      rewrite Ptrofs.add_assoc. destruct axis; repeat split; reflexivity.
    - match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion H end. }
  inversion Hr; subst.
  match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => destruct (Hloc _ _ _ H) as (-> & -> & ->) end.
  match goal with H : deref_loc _ _ _ _ _ _ |- _ => inversion H; subst; try discriminate end.
  match goal with H : access_mode _ = By_value _ |- _ => cbn in H; inversion H; subst end.
  match goal with H : Mem.loadv _ _ _ = Some answer |- _ =>
    change (Mem.load Mfloat32 m ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)))) = Some answer) in H;
    congruence end.
Qed.

Lemma r1q_stage_execution : forall version e le m axis gb ob oo value t le' m' out,
  e ! IPD._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)))) = Some (Vsingle value) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (r1q_stage version axis) t le' m' out ->
  t = E0 /\ m' = m /\ out = Out_normal /\
  le' = PTree.set (r1q_coordinate axis) (Vsingle value)
    (PTree.set (r1q_receiver axis) (Vptr ob oo) le).
Proof.
  intros version e le m axis gb ob oo value t le' m' out Hlocal Hsymbol Hobj Hvalue Hrun.
  unfold r1q_stage, ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: match goal with H : eval_expr _ _ _ _ (Evar IPD._gMarioObject _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ipd_global_value; eauto); subst v end.
  all: match goal with H : eval_expr _ _ _ _ (r1q_read _ _) ?v |- _ =>
    assert (v = Vsingle value) by (eapply r1q_raw_value; [apply PTree.gss|exact Hvalue|exact H]); subst v end.
  all: repeat split; reflexivity.
Qed.

Lemma r1q_local_address : forall ge e le m fb answer,
  e ! IPD._floor = Some (fb, ipd_surface) ->
  eval_expr ge e le m (Eaddrof (Evar IPD._floor ipd_surface) (tptr ipd_surface)) answer ->
  answer = Vptr fb Ptrofs.zero.
Proof.
  intros ge e le m fb answer Hlocal Hr. inversion Hr; subst.
  - match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inversion H; subst; try congruence end.
  - match goal with H : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inversion H end.
Qed.

Lemma r1q_real_call : forall version e le m fb values t le' m' out,
  e ! IPD._find_floor = None -> e ! IPD._floor = Some (fb, ipd_surface) ->
  (forall axis, le ! (r1q_coordinate axis) = Some (Vsingle (values axis))) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m r1q_query t le' m' out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
      (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle (values ICPX); Vsingle (values ICPY); Vsingle (values ICPZ); Vptr fb Ptrofs.zero]
      t m' result /\ out = Out_normal /\
    le' = PTree.set IPD._floorHeight result (PTree.set IPD._t'1 result le).
Proof.
  intros version e le m fb values t le' m' out Hfind Hfloor Hvalues Hrun.
  unfold r1q_query, r1q_call, ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: try solve [match goal with H : ClightBigstep.exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
    inversion H; subst; contradiction end].
  match goal with H : ClightBigstep.exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ =>
    inversion H; subst; clear H end.
  match goal with H : classify_fun _ = _ |- _ => cbn in H; inversion H; subst end.
  destruct (upper_elevator_selected_query_body_resolves version UEQRFindFloor)
    as (code & Hsymbol & Hfunction).
  match goal with H : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?v |- _ =>
    assert (v = Vptr code Ptrofs.zero) by (eapply sce_function_name_value; eauto); subst v end.
  match goal with H : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) code = Some fd) in H;
    rewrite Hfunction in H; inversion H; subst fd end.
  repeat match goal with H : eval_exprlist _ _ _ _ _ _ _ |- _ => inversion H; subst; clear H end.
  match goal with H : eval_expr _ _ _ _ (Etempvar IPD._marioX _) ?v |- _ =>
    assert (v = Vsingle (values ICPX)) by (eapply ocn_temp_value; [exact H|exact (Hvalues ICPX)]); subst v end.
  match goal with H : eval_expr _ _ _ _ (Etempvar IPD._marioY _) ?v |- _ =>
    assert (v = Vsingle (values ICPY)) by (eapply ocn_temp_value; [exact H|exact (Hvalues ICPY)]); subst v end.
  match goal with H : eval_expr _ _ _ _ (Etempvar IPD._marioZ _) ?v |- _ =>
    assert (v = Vsingle (values ICPZ)) by (eapply ocn_temp_value; [exact H|exact (Hvalues ICPZ)]); subst v end.
  match goal with H : eval_expr _ _ _ _ (Eaddrof _ _) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by (eapply r1q_local_address; eauto); subst v end.
  repeat match goal with H : sem_cast (Vsingle _) _ _ _ = Some _ |- _ => cbn in H; inversion H; subst; clear H end.
  match goal with H : sem_cast (Vptr _ _) _ _ _ = Some _ |- _ => cbn in H; inversion H; subst end.
  lazymatch goal with H : eval_expr _ _ (set_opttemp _ ?result _) _ (Etempvar IPD._t'1 _) ?v |- _ =>
    assert (v = result) by (eapply ocn_temp_value; [exact H|cbn [set_opttemp]; apply PTree.gss]); subst v end.
  subst. unfold Eapp, E0. rewrite ?app_nil_r.
  eexists. split; [eassumption|]. split; reflexivity.
Qed.

(** The actual query and its continuation share the returned memory. In
    particular the continuation is not allowed to use the pre-query floor
    pointer or assume that find_floor preserved the queried Object. *)
Definition Rank1FinalRawQuery : Prop := forall version e le m fb gb ob oo values t le' m' out,
  e ! IPD._gMarioObject = None -> e ! IPD._find_floor = None ->
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  (forall axis, Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)))) =
      Some (Vsingle (values axis))) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (r1q_segment version) t le' m' out ->
  exists query_trace tail_trace query_m result,
    t = query_trace ++ tail_trace /\
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
      (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle (values ICPX); Vsingle (values ICPY); Vsingle (values ICPZ); Vptr fb Ptrofs.zero]
      query_trace query_m result /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e
      (PTree.set IPD._floorHeight result (PTree.set IPD._t'1 result (r1q_temps le ob oo values)))
      query_m (ipdist_tail version) tail_trace le' m' out.

Theorem r1q_final_query_uses_raw_position : Rank1FinalRawQuery.
Proof.
  intros version e le m fb gb ob oo values t le' m' out Hobjlocal Hfind Hfloor Hsymbol Hobj Hvalues Hrun.
  rewrite r1q_generated_segment in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (r1q_stage version ICPX) _ _ _ _ _ eq_refl Hrun)
    as (lx & mx & tx & restx & -> & Hx & Hrestx).
  destruct (r1q_stage_execution _ _ _ _ ICPX _ _ _ _ _ _ _ _
    Hobjlocal Hsymbol Hobj (Hvalues ICPX) Hx) as (-> & -> & _ & ->).
  destruct (ibk_split_sequence _ _ _ _ (r1q_stage version ICPY) _ _ _ _ _ eq_refl Hrestx)
    as (ly & my & ty & resty & -> & Hy & Hresty).
  destruct (r1q_stage_execution _ _ _ _ ICPY _ _ _ _ _ _ _ _
    Hobjlocal Hsymbol Hobj (Hvalues ICPY) Hy) as (-> & -> & _ & ->).
  destruct (ibk_split_sequence _ _ _ _ (r1q_stage version ICPZ) _ _ _ _ _ eq_refl Hresty)
    as (lz & mz & tz & restz & -> & Hz & Hrestz).
  destruct (r1q_stage_execution _ _ _ _ ICPZ _ _ _ _ _ _ _ _
    Hobjlocal Hsymbol Hobj (Hvalues ICPZ) Hz) as (-> & -> & _ & ->).
  destruct (ibk_split_sequence _ _ _ _ r1q_query _ _ _ _ _ eq_refl Hrestz)
    as (lq & mq & tq & ts & -> & Hq & Htail).
  destruct (r1q_real_call version e (r1q_temps le ob oo values) m fb values _ _ _ _ Hfind Hfloor
    ltac:(intros []; unfold r1q_temps; cbn [r1q_coordinate];
      repeat rewrite PTree.gso by discriminate; apply PTree.gss) Hq) as (result & Hcall & _ & ->).
  exists tq, ts, mq, result. split; [reflexivity|]. split; assumption.
Qed.

Lemma r1q_nonnull_body_reaches_segment : forall version e le m gb ob oo t le' m' out,
  e ! IPD._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (ipd_body version IPDUpdate)) t le' m' out ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e
    (PTree.set IPD._t'17 (Vptr ob oo) le) m (r1q_segment version) t le' m' out.
Proof.
  intros version e le m gb ob oo t le' m' out Hlocal Hsymbol Hobj Hrun.
  assert (fn_body (ipd_body version IPDUpdate) = Ssequence
    (Ssequence (Sset IPD._t'17 (Evar IPD._gMarioObject ipd_object))
      (Sifthenelse (Ebinop Oeq (Etempvar IPD._t'17 ipd_object) ipd_null tint)
        (Sreturn None) Sskip)) (r1q_segment version)) as Hshape by (destruct version; reflexivity).
  rewrite Hshape in Hrun. unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: match goal with H : eval_expr _ _ _ _ (Evar IPD._gMarioObject _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ipd_global_value; eauto); subst v end.
  all: match goal with H : eval_expr _ _ _ _ (Ebinop Oeq _ _ _) _ |- _ => inversion H; subst; clear H end.
  all: try solve [match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion H end].
  all: match goal with H : eval_expr _ _ _ _ (Etempvar IPD._t'17 _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocn_temp_value; [exact H|apply PTree.gss]); subst v end.
  all: match goal with H : eval_expr _ _ _ _ ipd_null ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ipd_null_value; eauto); subst v end.
  all: match goal with H : sem_binary_operation _ _ _ _ _ _ ?memory = Some ?v |- _ =>
    change (option_map Val.of_bool (Val.cmpu_bool (Mem.valid_pointer memory)
      Ceq (Vptr ob oo) (Vint Int.zero)) = Some v) in H;
    cbn [Val.cmpu_bool] in H;
    repeat match type of H with context [if ?test then _ else _] =>
      destruct test eqn:?; cbn in H; try discriminate end;
    inversion H; subst end.
  all: try match goal with H : bool_val _ _ _ = Some _ |- _ => cbn in H; try discriminate end.
  all: assumption.
Qed.
