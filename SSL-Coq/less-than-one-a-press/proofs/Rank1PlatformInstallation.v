(** The successful half of the final platform update. The owner comes from
    the returned Surface; both stores and their frames are derived from the
    actual generated statements. No active-owner test or equality of Mario's
    State, display and raw positions is added. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Proofs Require Import GameTypes Rank1FinalPlatformQuery
  InkPlatformSource InkPlatformDeparture InkPlatformDistance InkBackwardExecution
  InkCopyCaller InkFloorListEffects InkBodyResetFrame InkBodyResetConstruction
  ObjectContactNecessity ContactConsumerExecution Area2Rank12BContact
  InkCopyCompletion UpperElevatorQueryResolution
  SelectedClightTarget.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.

Definition r1o_install version := match ipd_owner_choice version with
| Sifthenelse _ yes _ => yes | _ => Sskip end.
Definition r1o_first := Ssequence (Sset IPD._t'8 (Evar IPD._floor ipd_surface))
  (Ssequence (Sset IPD._t'9 (ibr_field IPD._t'8 IPD._Surface IPD._object ipd_object))
    (Sassign (Evar IPD._gMarioPlatform ipd_object) (Etempvar IPD._t'9 ipd_object))).
Definition r1o_second := Ssequence (Sset IPD._t'5 (Evar IPD._gMarioObject ipd_object))
  (Ssequence (Sset IPD._t'6 (Evar IPD._floor ipd_surface))
    (Ssequence (Sset IPD._t'7 (ibr_field IPD._t'6 IPD._Surface IPD._object ipd_object))
      (Sassign (ibr_field IPD._t'5 IPD._Object IPD._platform ipd_object)
        (Etempvar IPD._t'7 ipd_object)))).
Lemma r1o_generated_install : forall version,
  ipd_owner_choice version = Sifthenelse (Etempvar IPD._t'3 tint)
    (r1o_install version) (ipd_clear version) /\
  r1o_install version = Ssequence r1o_first r1o_second.
Proof. intros []; split; reflexivity. Qed.

Lemma r1o_nonnull_pointer : forall ge e le m id tag b ofs answer,
  le ! id = Some (Vptr b ofs) ->
  eval_expr ge e le m (ipd_nonnull id (tptr (Tstruct tag noattr))) answer ->
  answer = Vint Int.one.
Proof.
  intros ge e le m id tag b ofs answer Htemp Hr. unfold ipd_nonnull in Hr.
  inversion Hr; subst.
  - match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
      assert (v = Vptr b ofs) by (eapply ocn_temp_value; eauto); subst v end.
    match goal with H : eval_expr _ _ _ _ ipd_null ?v |- _ =>
      assert (v = Vint Int.zero) by (eapply ipd_null_value; eauto); subst v end.
    match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some answer |- _ =>
      change (option_map Val.of_bool
        (Val.cmpu_bool (Mem.valid_pointer m) Cne (Vptr b ofs) (Vint Int.zero)) = Some answer) in H;
      cbn [Val.cmpu_bool] in H;
      repeat match type of H with context [if ?test then _ else _] =>
        destruct test eqn:?; cbn in H; try discriminate end;
      inversion H; reflexivity end.
  - match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion H end.
Qed.


Lemma r1o_owned_guard : forall version e le m fb sb so owner offset t le' m' out,
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Mem.load Mptr m fb 0 = Some (Vptr sb so) ->
  Mem.load Mptr m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipd_owner_guard version) t le' m' out ->
  t = E0 /\ m' = m /\ le' ! IPD._t'3 = Some (Vint Int.one).
Proof.
  intros version e le m fb sb so owner offset t le' m' out Hlocal Hfloor Howner Hrun.
  destruct (ipd_source version) as (_ & _ & Hguard & _). rewrite Hguard in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: repeat match goal with H : eval_expr _ _ _ _ (Evar IPD._floor _) ?v |- _ =>
    assert (v = Vptr sb so) by (eapply ipd_local_floor_value; eauto); subst v; clear H end.
  all: match goal with H : eval_expr _ _ ?temps _ (ipd_nonnull IPD._t'10 _) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply r1o_nonnull_pointer; [apply PTree.gss|exact H]); subst v end.
  all: match goal with H : bool_val (Vint Int.one) _ _ = Some _ |- _ =>
    cbn in H; try discriminate end.
  all: lazymatch goal with H : eval_expr _ _ ?temps ?memory
      (ibr_field IPD._t'11 IPD._Surface IPD._object ipd_object) ?v |- _ =>
    assert (temps ! IPD._t'11 = Some (Vptr sb so)) as Htemp by apply PTree.gss;
    pose proof (ibr_field_read_value (Clight.globalenv (selected_clight_target version))
      e temps memory IPD._t'11 IPD._Surface IPD._object ipd_object 44 Mptr sb so
      (Vptr owner offset) v Htemp (proj1 (ipd_fields version)) eq_refl Howner H) as Hvalue;
    subst v; clear H Htemp end.
  all: match goal with H : eval_expr _ _ _ _ (Ecast (ipd_nonnull IPD._t'12 _) tbool) _ |- _ =>
    inversion H; subst; clear H end.
  all: try solve [match goal with H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion H end].
  all: match goal with H : eval_expr _ _ _ _ (ipd_nonnull IPD._t'12 _) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply r1o_nonnull_pointer; [apply PTree.gss|exact H]); subst v end.
  all: match goal with H : sem_cast _ _ _ _ = Some _ |- _ => cbn in H; inversion H; subst end.
  all: repeat split; try reflexivity; apply PTree.gss.
Qed.

Lemma r1o_pointer_store : forall ge e le m lhs id valueb valueofs b ofs t le' m' out,
  typeof lhs = ipd_object -> le ! id = Some (Vptr valueb valueofs) ->
  (forall loc off bf, eval_lvalue ge e le m lhs loc off bf -> loc = b /\ off = ofs /\ bf = Full) ->
  ocn_exec ge e le m (Sassign lhs (Etempvar id ipd_object)) t le' m' out ->
  t = E0 /\ le' = le /\ out = Out_normal /\
  Mem.store Mptr m b (Ptrofs.unsigned ofs) (Vptr valueb valueofs) = Some m'.
Proof.
  intros ge e le m lhs id valueb valueofs b ofs t le' m' out Htype Htemp Hloc Hrun.
  inversion Hrun; subst; clear Hrun.
  match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => destruct (Hloc _ _ _ H) as (-> & -> & ->) end.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    assert (v = Vptr valueb valueofs) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with H : sem_cast _ _ _ _ = Some _ |- _ => rewrite Htype in H; cbn in H; inversion H; subst end.
  match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => rewrite Htype in H; inversion H; subst; try discriminate end.
  match goal with H : access_mode _ = By_value _ |- _ => cbn in H; inversion H; subst end.
  repeat split; assumption.
Qed.

Lemma r1o_first_store : forall version e le m fb sb so owner offset pb t le' m' out,
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Mem.load Mptr m fb 0 = Some (Vptr sb so) ->
  Mem.load Mptr m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
  e ! IPD._gMarioPlatform = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioPlatform = Some pb ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m r1o_first t le' m' out ->
  t = E0 /\ out = Out_normal /\ Mem.store Mptr m pb 0 (Vptr owner offset) = Some m'.
Proof.
  intros version e le m fb sb so owner offset pb t le' m' out Hlocal Hfloor Howner Hpl Hps Hrun.
  unfold r1o_first, ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  match goal with H : eval_expr _ _ _ _ (Evar IPD._floor _) ?v |- _ =>
    assert (v = Vptr sb so) by (eapply ipd_local_floor_value; eauto); subst v end.
  lazymatch goal with H : eval_expr _ _ ?temps ?memory (ibr_field _ _ _ _) ?v |- _ =>
    assert (temps ! IPD._t'8 = Some (Vptr sb so)) as Htemp by apply PTree.gss;
    pose proof (ibr_field_read_value (Clight.globalenv (selected_clight_target version))
      e temps memory IPD._t'8 IPD._Surface IPD._object ipd_object 44 Mptr sb so
      (Vptr owner offset) v Htemp (proj1 (ipd_fields version)) eq_refl Howner H) as Hv;
    subst v end.
  match goal with H : ClightBigstep.exec_stmt _ _ _ ?temps ?memory (Sassign _ _) _ _ _ _ |- _ =>
    destruct (r1o_pointer_store (Clight.globalenv (selected_clight_target version)) e temps memory
      (Evar IPD._gMarioPlatform ipd_object) IPD._t'9 owner offset pb Ptrofs.zero _ _ _ _
      eq_refl (PTree.gss _ _ _)
      ltac:(intros loc off bf Hl; inversion Hl; subst; try congruence;
        assert (loc = pb) by congruence; subst; auto) H) as (-> & -> & -> & Hstore) end.
  repeat split; try reflexivity; assumption.
Qed.

Lemma r1o_second_store : forall version e le m fb sb so owner offset gb ob oo t le' m' out,
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Mem.load Mptr m fb 0 = Some (Vptr sb so) ->
  Mem.load Mptr m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
  e ! IPD._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m r1o_second t le' m' out ->
  t = E0 /\ out = Out_normal /\
  Mem.store Mptr m ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 532))) (Vptr owner offset) = Some m'.
Proof.
  intros version e le m fb sb so owner offset gb ob oo t le' m' out Hlocal Hfloor Howner Hml Hms Hm Hrun.
  unfold r1o_second, ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  match goal with H : eval_expr _ _ _ _ (Evar IPD._gMarioObject _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ipd_global_value; eauto); subst v end.
  match goal with H : eval_expr _ _ _ _ (Evar IPD._floor _) ?v |- _ =>
    assert (v = Vptr sb so) by (eapply ipd_local_floor_value; eauto); subst v end.
  lazymatch goal with H : eval_expr _ _ ?temps ?memory (ibr_field _ _ _ _) ?v |- _ =>
    assert (temps ! IPD._t'6 = Some (Vptr sb so)) as Htemp by apply PTree.gss;
    pose proof (ibr_field_read_value (Clight.globalenv (selected_clight_target version))
      e temps memory IPD._t'6 IPD._Surface IPD._object ipd_object 44 Mptr sb so
      (Vptr owner offset) v Htemp (proj1 (ipd_fields version)) eq_refl Howner H) as Hv;
    subst v end.
  match goal with H : ClightBigstep.exec_stmt _ _ _ ?temps ?memory (Sassign _ _) _ _ _ _ |- _ =>
    destruct (r1o_pointer_store (Clight.globalenv (selected_clight_target version)) e temps memory
      (ibr_field IPD._t'5 IPD._Object IPD._platform ipd_object) IPD._t'7 owner offset
      ob (Ptrofs.add oo (Ptrofs.repr 532)) _ _ _ _ eq_refl (PTree.gss _ _ _)
      ltac:(intros loc off bf Hl;
        eapply (ibcc_field_location (Clight.globalenv (selected_clight_target version))
          e temps memory (ibr_base IPD._t'5 IPD._Object) IPD._Object IPD._platform
          ipd_object ob oo 532 loc off bf);
        [reflexivity| |exact (proj2 (ipd_fields version))|exact Hl];
        intros; eapply ibcc_deref_struct; [|eassumption];
        repeat rewrite PTree.gso by discriminate; apply PTree.gss) H)
      as (-> & -> & -> & Hstore) end.
  repeat split; try reflexivity; assumption.
Qed.

Definition Rank1OwnerInstallation : Prop :=
  forall version e le m fb sb so owner offset pb gb ob oo t le' m' out,
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Mem.load Mptr m fb 0 = Some (Vptr sb so) ->
  Mem.load Mptr m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
  e ! IPD._gMarioPlatform = None -> e ! IPD._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioPlatform = Some pb ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  pb <> fb -> pb <> sb -> pb <> ob ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipd_owner_branch version) t le' m' out ->
  t = E0 /\ out = Out_normal /\
  Mem.load Mptr m' pb 0 = Some (Vptr owner offset) /\
  Mem.load Mptr m' ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 532))) = Some (Vptr owner offset) /\
  forall chunk b ofs,
    ifl_disjoint pb 0 4 chunk b ofs ->
    ifl_disjoint ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 532))) 4 chunk b ofs ->
    Mem.load chunk m' b ofs = Mem.load chunk m b ofs.

Theorem r1o_owned_floor_installs_both_pointers : Rank1OwnerInstallation.
Proof.
  intros version e le m fb sb so owner offset pb gb ob oo t le' m' out
    Hlocal Hfloor Howner Hpl Hml Hps Hms Hpf Hpsurface Hpo Hm Hrun.
  assert (pb <> gb) as Hpg.
  { eapply Genv.global_addresses_distinct; [|exact Hps|exact Hms]. discriminate. }
  destruct (ipd_source version) as (_ & Hbranch & _). rewrite Hbranch in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (ipd_owner_guard version) _ _ _ _ _ ltac:(destruct version; reflexivity) Hrun)
    as (guarded & mg & tg & ts & -> & Hguard & Hchoice).
  destruct (r1o_owned_guard _ _ _ _ _ _ _ _ _ _ _ _ _ Hlocal Hfloor Howner Hguard)
    as (-> & -> & Hone).
  destruct (r1o_generated_install version) as (HchoiceShape & Hinstall).
  rewrite HchoiceShape in Hchoice. inversion Hchoice; subst.
  match goal with H : eval_expr _ _ _ _ (Etempvar IPD._t'3 _) ?v |- _ =>
    assert (v = Vint Int.one) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with H : bool_val (Vint Int.one) _ _ = Some ?take |- _ =>
    change (Some true = Some take) in H; inversion H; subst end.
  cbn beta iota in *.
  match goal with H : ClightBigstep.exec_stmt _ _ _ _ _ (r1o_install _) _ _ _ _ |- _ =>
    rewrite Hinstall in H;
    destruct (ibk_split_sequence _ _ _ _ r1o_first _ _ _ _ _ eq_refl H)
      as (middle & m1 & first & second & -> & Hfirst & Hsecond) end.
  destruct (r1o_first_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hlocal Hfloor Howner Hpl Hps Hfirst)
    as (-> & _ & Hstore).
  assert (Mem.load Mptr m1 fb 0 = Some (Vptr sb so)) as Hfloor1 by
    (rewrite <- Hfloor; eapply Mem.load_store_other; [exact Hstore|left; congruence]).
  assert (Mem.load Mptr m1 sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) =
    Some (Vptr owner offset)) as Howner1 by
    (rewrite <- Howner; eapply Mem.load_store_other; [exact Hstore|left; congruence]).
  assert (Mem.load Mptr m1 gb 0 = Some (Vptr ob oo)) as Hm1 by
    (rewrite <- Hm; eapply Mem.load_store_other; [exact Hstore|left; congruence]).
  destruct (r1o_second_store _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hfloor1 Howner1 Hml Hms Hm1 Hsecond) as (-> & -> & Hstore2).
  split; [reflexivity|]. split; [reflexivity|]. split.
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore2 Mptr pb 0) by (left; congruence).
    exact (Mem.load_store_same _ _ _ _ _ _ Hstore).
  - split; [exact (Mem.load_store_same _ _ _ _ _ _ Hstore2)|].
    intros chunk b ofs Houtside1 Houtside2.
    transitivity (Mem.load chunk m1 b ofs);
      eapply Mem.load_store_other; [exact Hstore2|exact Houtside2|exact Hstore|exact Houtside1].
Qed.

Definition Rank1OwnedDistanceSelection : Prop :=
  forall version e le m y height fb sb so owner offset pb gb ob oo t le' m' out,
  e ! ipdist_abs_id = None ->
  le ! IPD._marioY = Some (Vsingle y) -> le ! IPD._floorHeight = Some (Vsingle height) ->
  e ! IPD._floor = Some (fb, ipd_surface) ->
  Mem.load Mptr m fb 0 = Some (Vptr sb so) ->
  Mem.load Mptr m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
  e ! IPD._gMarioPlatform = None -> e ! IPD._gMarioObject = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioPlatform = Some pb ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  pb <> fb -> pb <> sb -> pb <> ob -> Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipdist_tail version) t le' m' out ->
  let selected := if Float32.cmp Clt (ipdist_abs (Float32.sub y height)) ipdist_four
    then Vptr owner offset else Vint Int.zero in
  t = E0 /\ out = Out_normal /\ Mem.load Mptr m' pb 0 = Some selected /\
  Mem.load Mptr m' ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 532))) = Some selected /\
  forall chunk b ofs,
    ifl_disjoint pb 0 4 chunk b ofs ->
    ifl_disjoint ob (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 532))) 4 chunk b ofs ->
    Mem.load chunk m' b ofs = Mem.load chunk m b ofs.

Theorem r1o_returned_owner_selected_exactly_when_near : Rank1OwnedDistanceSelection.
Proof.
  intros version e le m y height fb sb so owner offset pb gb ob oo t le' m' out
    Habs Hy Hheight Hlocal Hfloor Howner Hpl Hml Hps Hms Hpf Hpsurface Hpo Hm Hrun.
  cbn zeta. destruct (Float32.cmp Clt (ipdist_abs (Float32.sub y height)) ipdist_four) eqn:Hnear.
  2: exact (ipdist_failed_distance_clears_support _ _ _ _ _ _ _ _ _ _ _ _ _ _
    Habs Hy Hheight Hnear Hpl Hml Hps Hms Hpo Hm Hrun).
  destruct (ipdist_tail_source version) as (Htail & _ & Hswitch & _ & Hnormal).
  rewrite Htail in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (checked & middle & pre & suf & -> & Htest & Hchoose).
  destruct (ipdist_guard_value _ _ _ _ _ _ _ _ _ _ Habs Hy Hheight Htest)
    as (-> & -> & Hzero). rewrite Hnear in Hzero.
  rewrite Hswitch in Hchoose. inversion Hchoose; subst; clear Hchoose.
  match goal with H : eval_expr _ _ _ _ (Etempvar IPD._awayFromFloor _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with H : sem_switch_arg _ _ = Some ?n |- _ =>
    change (Some 0 = Some n) in H; inversion H; subst end.
  assert (seq_of_labeled_statement (select_switch 0 (ipdist_cases version)) =
    Ssequence (ipd_near version) Sskip) as Hcase by (destruct version; reflexivity).
  match goal with H : ClightBigstep.exec_stmt _ _ _ _ _
    (seq_of_labeled_statement (select_switch _ _)) _ _ _ _ |- _ =>
    rewrite Hcase, (proj1 (ipd_source version)) in H end.
  cce_unroll_loop_free_exec.
  all: match goal with H : ClightBigstep.exec_stmt _ _ _ _ _ (ipd_owner_branch ?ver) _ _ _ _ |- _ =>
    destruct (r1o_owned_floor_installs_both_pointers ver _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
      Hlocal Hfloor Howner Hpl Hml Hps Hms Hpf Hpsurface Hpo Hm H)
      as (-> & Ho & Hp & Hmp & Hframe); try discriminate Ho end.
  all: subst; repeat split; auto.
Qed.

(** This eliminates a preservation assumption *inside* the query consumer.
    All properties of the returned floor and Mario pointer below are stated
    at the actual returned memory, not silently imported from call entry. *)
Definition Rank1FinalQueryOwnerConnection : Prop :=
  forall version e le m fb gb ob oo values t le' m' out,
  e ! IPD._gMarioObject = None -> e ! IPD._find_floor = None -> e ! ipdist_abs_id = None ->
  e ! IPD._gMarioPlatform = None -> e ! IPD._floor = Some (fb, ipd_surface) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioObject = Some gb ->
  Mem.load Mptr m gb 0 = Some (Vptr ob oo) ->
  (forall axis, Mem.load Mfloat32 m ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr (160 + 4 * icp_number axis)))) = Some (Vsingle (values axis))) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (ipd_body version IPDUpdate)) t le' m' out ->
  exists query_trace tail_trace query_m result,
    t = query_trace ++ tail_trace /\
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version)) m
      (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle (values ICPX); Vsingle (values ICPY); Vsingle (values ICPZ); Vptr fb Ptrofs.zero]
      query_trace query_m result /\
    (forall height sb so owner offset pb currentb currentofs,
      result = Vsingle height ->
      Mem.load Mptr query_m fb 0 = Some (Vptr sb so) ->
      Mem.load Mptr query_m sb (Ptrofs.unsigned (Ptrofs.add so (Ptrofs.repr 44))) = Some (Vptr owner offset) ->
      Genv.find_symbol (Clight.globalenv (selected_clight_target version)) IPD._gMarioPlatform = Some pb ->
      pb <> fb -> pb <> sb -> pb <> currentb ->
      Mem.load Mptr query_m gb 0 = Some (Vptr currentb currentofs) ->
      let selected := if Float32.cmp Clt (ipdist_abs (Float32.sub (values ICPY) height)) ipdist_four
        then Vptr owner offset else Vint Int.zero in
      tail_trace = E0 /\ out = Out_normal /\ Mem.load Mptr m' pb 0 = Some selected /\
      Mem.load Mptr m' currentb (Ptrofs.unsigned (Ptrofs.add currentofs (Ptrofs.repr 532))) = Some selected /\
      forall chunk b ofs,
        ifl_disjoint pb 0 4 chunk b ofs ->
        ifl_disjoint currentb (Ptrofs.unsigned (Ptrofs.add currentofs (Ptrofs.repr 532))) 4 chunk b ofs ->
        Mem.load chunk m' b ofs = Mem.load chunk query_m b ofs).

Theorem r1o_final_query_connects_raw_position_to_owner : Rank1FinalQueryOwnerConnection.
Proof.
  intros version e le m fb gb ob oo values t le' m' out
    Hml Hfind Habs Hpl Hfloor Hms Hobj Hvalues Hrun.
  pose proof (r1q_nonnull_body_reaches_segment _ _ _ _ _ _ _ _ _ _ _
    Hml Hms Hobj Hrun) as Hsegment.
  destruct (r1q_final_query_uses_raw_position _ _ _ _ _ _ _ _ _ _ _ _ _
    Hml Hfind Hfloor Hms Hobj Hvalues Hsegment)
    as (tq & ts & mq & result & Htrace & Hcall & Htail).
  exists tq, ts, mq, result. split; [exact Htrace|]. split; [exact Hcall|].
  intros height sb so owner offset pb currentb currentofs Hresult Hselected Howner Hps Hpf Hpsurface Hpo Hcurrent.
  subst result. eapply r1o_returned_owner_selected_exactly_when_near;
    [exact Habs| | |exact Hfloor|exact Hselected|exact Howner|exact Hpl|exact Hml|
     exact Hps|exact Hms|exact Hpf|exact Hpsurface|exact Hpo|exact Hcurrent|exact Htail];
    unfold r1q_temps; repeat rewrite PTree.gso by discriminate; apply PTree.gss.
Qed.
