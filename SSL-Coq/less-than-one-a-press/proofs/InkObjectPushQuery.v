(** Extend the actual object-push handoff across its destination floor query.
    This query writes a stack-local floor pointer; it does not refresh Mario's
    remembered floor. Earlier angle/wall work and gameplay reachability remain
    separate obligations, rather than silently assumed memory frames. *)
From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Floats Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes InkObjectPushHandoff
  InkBackwardSource InkBackwardExecution InkCopyEntry InkCopyCaller
  InkFloorResetExecution InkFloorHistorySource InkFloorHistoryQuery
  InkFloorListEffects InkFloorCallEffects InkPlatformWriteFrame ObjectContactNecessity
  ContactConsumerExecution SecretContactExecution Area2Rank12BContact
  UpperElevatorQueryResolution SelectedClightTarget.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque selected_clight_target.

Definition ipq_surface := tptr (Tstruct IPH._Surface noattr).
Definition ipq_after_wall version := rank12b_drop_sequences 4 (iph_inside version).
Definition ipq_query version := ibk_head (ipq_after_wall version).
Definition ipq_call := Scall None
  (Evar IPH._find_floor
    (Tfunction [tfloat; tfloat; tfloat; tptr ipq_surface] tfloat cc_default))
  [Etempvar IPH._t'6 tfloat; Etempvar IPH._t'7 tfloat; Etempvar IPH._t'8 tfloat;
   Eaddrof (Evar IPH._floor ipq_surface) (tptr ipq_surface)].

Lemma ipq_source : forall version,
  ipq_after_wall version = Ssequence (ipq_query version) (iph_tail version) /\
  ipq_query version = Ssequence (Sset IPH._t'6 (Evar IPH._newMarioX tfloat))
    (Ssequence (Sset IPH._t'7 (ifh_state_coord 1))
      (Ssequence (Sset IPH._t'8 (Evar IPH._newMarioZ tfloat)) ipq_call)) /\
  ibk_normal (ipq_query version) = true /\
  ifr_keeps_temp IPH._m (ipq_query version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Lemma ipq_local_output_address : forall ge e le m fb answer,
  e ! IPH._floor = Some (fb, ipq_surface) ->
  eval_expr ge e le m
    (Eaddrof (Evar IPH._floor ipq_surface) (tptr ipq_surface)) answer ->
  answer = Vptr fb Ptrofs.zero.
Proof.
  intros ge e le m fb answer Hlocal Hread. inversion Hread; subst.
  - lazymatch goal with Hl : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ =>
      destruct (ibc_local_location _ _ _ _ _ _ _ _ _ _ Hlocal Hl) as (-> & -> & _) end.
    reflexivity.
  - match goal with Hl : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inversion Hl end.
Qed.

Theorem ipq_actual_destination_query : forall version e le m mb fb height t last after out,
  e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipq_query version) t last after out ->
  exists x z result,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
      m (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle x; Vsingle height; Vsingle z; Vptr fb Ptrofs.zero] t after result /\
    out = Out_normal.
Proof.
  intros version e le m mb fb height t last after out Hlocal Hfloor Hm Hy Hrun.
  destruct (ipq_source version) as (_ & Hquery & _). rewrite Hquery in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  cce_unroll_loop_free_exec.
  all: try contradiction.
  all: lazymatch goal with Hr : eval_expr ?ge ?env ?temps ?memory (ifh_state_coord 1) ?v |- _ =>
    assert (v = Vsingle height) by (eapply (ifh_movement_y_read version env temps memory mb height v);
      [rewrite PTree.gso by discriminate; exact Hm|exact Hy|exact Hr]); subst v end.
  lazymatch goal with Hc : ClightBigstep.exec_stmt _ _ _ _ _ ipq_call _ _ _ _ |- _ =>
    inversion Hc; subst; clear Hc end.
  match goal with Hclass : classify_fun _ = _ |- _ => cbn in Hclass; inversion Hclass; subst end.
  destruct (upper_elevator_selected_query_body_resolves version UEQRFindFloor)
    as (callee & Hsymbol & Hfunction).
  match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr callee Ptrofs.zero) by (eapply sce_function_name_value; eauto); subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) callee = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  repeat match goal with Hr : eval_exprlist _ _ _ _ _ _ _ |- _ => inversion Hr; subst; clear Hr end.
  match goal with Hr : eval_expr _ _ ?temps _ (Etempvar IPH._t'7 _) ?v |- _ =>
    assert (v = Vsingle height) by (eapply ocn_temp_value;
      [exact Hr|rewrite PTree.gso by discriminate; apply PTree.gss]); subst v end.
  lazymatch goal with Hr : eval_expr _ _ _ _ (Eaddrof _ _) ?v |- _ =>
    assert (v = Vptr fb Ptrofs.zero) by (eapply ipq_local_output_address; eauto); subst v end.
  repeat match goal with Hcast : sem_cast ?value ?ty tfloat ?memory = Some ?answer |- _ =>
    change (sem_cast value tfloat tfloat memory = Some answer) in Hcast;
    destruct (ifh_float_cast_identity _ _ _ Hcast) as (? & ? & ?); subst; clear Hcast end.
  repeat match goal with Heq : Vsingle _ = Vsingle _ |- _ => inversion Heq; subst; clear Heq end.
  match goal with Hcast : sem_cast (Vptr _ _) _ _ _ = Some _ |- _ =>
    cbn in Hcast; inversion Hcast; subst end.
  do 3 eexists. split; [eassumption|reflexivity].
Qed.

(** Unlike the preparation query's output argument MarioState+104, this
    output points to a distinct local block. All MarioState observations,
    including the floor pointer and action, therefore survive the actual
    complete floor search, its internal allocations and its cleanup. *)
Theorem ipq_actual_query_frames_mario : forall version e le m mb fb height t last after out,
  e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb -> mb <> fb ->
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipq_query version) t last after out ->
  t = E0 /\ out = Out_normal /\ last ! IPH._m = Some (Vptr mb Ptrofs.zero) /\
  forall chunk offset, Mem.load chunk after mb offset = Mem.load chunk m mb offset.
Proof.
  intros version e le m mb fb height t last after out Hlocal Hfloor Hsymbol Hapart Hm Hy Hrun.
  destruct (ipq_actual_destination_query _ _ _ _ _ _ _ _ _ _ _ Hlocal Hfloor Hm Hy Hrun)
    as (x & z & result & Hcall & Hout).
  assert (forall chunk offset, t = E0 /\
    Mem.load chunk after mb offset = Mem.load chunk m mb offset) as Hframe.
  { intros chunk offset. eapply ifc_completed_floor_preserves_other_cells; [| | |exact Hcall].
    - eapply ibcc_loaded_block_valid; exact Hy.
    - intros id Hin Hsame.
      assert (us_object_list_processor._gMarioStates <> id) as Hids by
        (destruct Hin as [<-|[<-|[<-|[]]]]; discriminate).
      assert (mb <> mb) as Hbad by (eapply Genv.global_addresses_distinct; eauto).
      exact (Hbad eq_refl).
    - left. exact Hapart. }
  split; [exact (proj1 (Hframe Mfloat32 64))|]. split; [exact Hout|].
  split.
  - rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hrun
      (proj2 (proj2 (proj2 (ipq_source version))))). exact Hm.
  - intros. exact (proj2 (Hframe _ _)).
Qed.

Lemma ipq_actual_tail_frames : forall version e le m mb ob t last after out,
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) -> mb <> ob ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (iph_tail version) t last after out ->
  Mem.load Mfloat32 after mb 64 = Mem.load Mfloat32 m mb 64 /\
  Mem.load Mint32 after mb 104 = Mem.load Mint32 m mb 104 /\
  Mem.load Mfloat32 after mb 112 = Mem.load Mfloat32 m mb 112 /\
  Mem.load Mint32 after mb 12 = Mem.load Mint32 m mb 12.
Proof.
  intros version e le m mb ob t last after out Hm Hapart Hrun.
  rewrite (proj1 (iph_generated_tail version)) in Hrun.
  destruct (ibk_split_sequence _ _ _ _
    (Sset IPH._t'3 (Evar IPH._floor ipq_surface)) _ _ _ _ _ eq_refl Hrun)
    as (middle & memory & pre & suf & _ & Hread & Hchoice).
  inversion Hread; subst. inversion Hchoice; subst. destruct b.
  - lazymatch goal with Hcommit : ClightBigstep.exec_stmt _ _ ?env ?temps ?memory (iph_commit version) ?events ?final_locals ?final_memory ?outcome |- _ =>
      destruct (iph_commit_preserves_height_cache_action_and_object version env temps memory mb ob
        events final_locals final_memory outcome
        ltac:(rewrite PTree.gso by discriminate; exact Hm) Hapart Hcommit)
        as (Hy & Hp & Hh & Ha & _); repeat split; assumption end.
  - cbn beta iota in *.
    lazymatch goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      inversion Hskip; subst end. repeat split; reflexivity.
Qed.

Definition InkObjectPushQueryFrame : Prop :=
  forall version e le m mb fb height t last after out,
  e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb -> mb <> fb ->
  le ! IPH._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ipq_after_wall version) t last after out ->
  Mem.load Mfloat32 after mb 64 = Some (Vsingle height) /\
  Mem.load Mint32 after mb 104 = Mem.load Mint32 m mb 104 /\
  Mem.load Mfloat32 after mb 112 = Mem.load Mfloat32 m mb 112 /\
  Mem.load Mint32 after mb 12 = Mem.load Mint32 m mb 12.

Theorem ipq_destination_query_and_commit_preserve_cache : InkObjectPushQueryFrame.
Proof.
  intros version e le m mb fb height t last after out Hlocal Hfloor Hsymbol Hapart Hm Hy Hrun.
  destruct (ipq_source version) as (Hshape & _ & Hnormal & _). rewrite Hshape in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (middle & memory & pre & suf & _ & Hquery & Htail).
  destruct (ipq_actual_query_frames_mario _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hfloor Hsymbol Hapart Hm Hy Hquery) as (_ & _ & Hmiddle & Hframe).
  destruct (ipq_actual_tail_frames _ _ _ _ mb fb _ _ _ _ Hmiddle Hapart Htail)
    as (Hheight & Hpointer & Hcache & Haction).
  rewrite Hheight, Hpointer, Hcache, Haction. repeat rewrite Hframe.
  repeat split; try reflexivity; exact Hy.
Qed.

(** The fresh preparation cache is an output of the actual first query,
    followed by the actual generated floorHeight assignment. In particular
    the action and movement height below are derived from the same input
    memory, while the floor pointer is the search's actual output cell. *)
Definition InkPrimaryFreshCache : Prop :=
  forall version e le m mb height t last fresh out,
  e ! IBM._find_floor = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    us_object_list_processor._gMarioStates = Some mb ->
  le ! IBM._m = Some (Vptr mb Ptrofs.zero) ->
  Mem.load Mfloat32 m mb 64 = Some (Vsingle height) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (ifh_geometry_query version) t last fresh out ->
  exists x z floor queried,
    ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
      m (Internal (ueqr_native_body version UEQRFindFloor))
      [Vsingle x; Vsingle height; Vsingle z; Vptr mb (Ptrofs.repr 104)]
      E0 queried (Vsingle floor) /\
    Mem.store Mfloat32 queried mb 112 (Vsingle floor) = Some fresh /\
    Mem.load Mfloat32 fresh mb 112 = Some (Vsingle floor) /\
    Mem.load Mint32 fresh mb 104 = Mem.load Mint32 queried mb 104 /\
    Mem.load Mint32 fresh mb 12 = Mem.load Mint32 m mb 12 /\
    Mem.load Mfloat32 fresh mb 64 = Some (Vsingle height).

Theorem ipq_primary_query_supplies_fresh_cache : InkPrimaryFreshCache.
Proof.
  intros version e le m mb height t last fresh out Hlocal Hsymbol Hm Hy Hrun.
  destruct (ifh_primary_floor_query_uses_movement_y_and_stores_result
    _ _ _ _ _ _ _ _ _ _ Hlocal Hm Hy Hrun)
    as (x & z & floor & queried & Hcall & Hstore & Hcache & Hmovement & Hout).
  assert (forall chunk offset, offset + size_chunk chunk <= 104 ->
    t = E0 /\ Mem.load chunk queried mb offset = Mem.load chunk m mb offset) as Hframe.
  { intros chunk offset Hrange.
    eapply ifc_completed_floor_preserves_other_cells; [| | |exact Hcall].
    - eapply ibcc_loaded_block_valid; exact Hy.
    - intros id Hin Hsame.
      assert (us_object_list_processor._gMarioStates <> id) as Hids by
        (destruct Hin as [<-|[<-|[<-|[]]]]; discriminate).
      assert (mb <> mb) as Hbad by (eapply Genv.global_addresses_distinct; eauto).
      exact (Hbad eq_refl).
    - right; left. exact Hrange. }
  destruct (Hframe Mfloat32 64 ltac:(cbn; lia)) as [Ht Hheight]. subst t.
  exists x, z, floor, queried. repeat apply conj; try assumption.
  - eapply Mem.load_store_other; [exact Hstore|right; left; cbn; lia].
  - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore) by (right; left; cbn; lia).
    exact (proj2 (Hframe Mint32 12 ltac:(cbn; lia))).
  - rewrite Hmovement, Hheight. exact Hy.
Qed.

Definition ipq_before_choice version := ocn_prefix_items 4 (fn_body (iph_body version)).
Definition ipq_before_query version := ocn_prefix_items 4 (iph_inside version).
Definition ipq_distance_guard := Ebinop Olt (Etempvar IPH._distance tfloat)
  (Etempvar IPH._minDistance tfloat) tint.

Lemma ipq_call_source : forall version,
  fn_params (iph_body version) =
    [(IPH._m, tptr (Tstruct IPH._MarioState noattr));
     (IPH._o, tptr (Tstruct IPH._Object noattr)); (IPH._padding, tfloat)] /\
  fn_body (iph_body version) = ocn_prepend (ipq_before_choice version)
    (Sifthenelse ipq_distance_guard (iph_inside version) Sskip) /\
  iph_inside version = ocn_prepend (ipq_before_query version) (ipq_after_wall version) /\
  forallb ibk_normal (ipq_before_choice version) = true /\
  forallb ibk_normal (ipq_before_query version) = true /\
  ifr_keeps_temp IPH._m (ocn_prepend (ipq_before_choice version) Sskip) = true /\
  ifr_keeps_temp IPH._m (ocn_prepend (ipq_before_query version) Sskip) = true.
Proof. intros []; repeat split; reflexivity. Qed.

Lemma ipq_entry_m : forall version ge start mb actor padding e entry_le entry_m,
  function_entry2 ge (iph_body version) [Vptr mb Ptrofs.zero; actor; padding]
    start e entry_le entry_m -> entry_le ! IPH._m = Some (Vptr mb Ptrofs.zero).
Proof.
  intros version ge start mb actor padding e entry_le entry_m Hentry.
  inversion Hentry; subst.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    rewrite (proj1 (ipq_call_source version)) in Hb;
    cbn [bind_parameter_temps] in Hb; inversion Hb; subst end.
  repeat rewrite PTree.gso by discriminate. apply PTree.gss.
Qed.

Lemma ipq_entry_locals_separate : forall version ge start mb actor padding e entry_le entry_m,
  Mem.valid_block start mb ->
  function_entry2 ge (iph_body version) [Vptr mb Ptrofs.zero; actor; padding]
    start e entry_le entry_m ->
  forall id b ty, e ! id = Some (b,ty) -> b <> mb.
Proof.
  intros version ge start mb actor padding e entry_le entry_m Hvalid Hentry.
  inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    exact (proj1 (ipw_alloc_frame _ _ _ _ _ _ Ha mb Hvalid
      ltac:(intros id b ty Hread; rewrite PTree.gempty in Hread; discriminate))) end.
Qed.

Lemma ipq_env_free_blocks : forall ge e mb,
  (forall id b ty, e ! id = Some (b,ty) -> b <> mb) ->
  Forall (fun '(b,_,_) => b <> mb) (blocks_of_env ge e).
Proof.
  intros ge e mb Hlocals. unfold blocks_of_env. apply Forall_map.
  apply Forall_forall. intros [id [b ty]] Hin. cbn.
  eapply Hlocals. apply PTree.elements_complete. exact Hin.
Qed.

(** A cut in one completed actual push call. The false-distance alternative
    is retained. On the entered branch, the actual math and wall prefix is
    exposed, and only its successor floor-query/commit is framed. Cleanup
    of this call's freshly allocated locals also preserves MarioState. *)
Definition InkObjectPushActualCallCut : Prop :=
  forall version start mb actor padding trace after result,
  Mem.valid_block start mb ->
  ClightBigstep.Clight2.eval_funcall (Clight.globalenv (selected_clight_target version))
    start (Internal (iph_body version)) [Vptr mb Ptrofs.zero; actor; padding]
    trace after result ->
  exists e entry_le entry_m choice_le choice_m pre rest body_m,
    function_entry2 (Clight.globalenv (selected_clight_target version))
      (iph_body version) [Vptr mb Ptrofs.zero; actor; padding] start e entry_le entry_m /\
    trace = pre ++ rest /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e entry_le entry_m
      (ocn_prepend (ipq_before_choice version) Sskip) pre choice_le choice_m Out_normal /\
    Mem.free_list body_m (blocks_of_env
      (Clight.globalenv (selected_clight_target version)) e) = Some after /\
    ((ocn_test_value (Clight.globalenv (selected_clight_target version))
        e choice_le choice_m ipq_distance_guard false /\ body_m = choice_m) \/
     exists cut_le cut_m wall_trace query_trace last out,
      rest = wall_trace ++ query_trace /\
      ocn_test_value (Clight.globalenv (selected_clight_target version))
        e choice_le choice_m ipq_distance_guard true /\
      ocn_exec (Clight.globalenv (selected_clight_target version)) e choice_le choice_m
        (ocn_prepend (ipq_before_query version) Sskip) wall_trace cut_le cut_m Out_normal /\
      ocn_exec (Clight.globalenv (selected_clight_target version)) e cut_le cut_m
        (ipq_after_wall version) query_trace last body_m out /\
      cut_le ! IPH._m = Some (Vptr mb Ptrofs.zero) /\
      (forall fb height,
        e ! IPH._find_floor = None -> e ! IPH._floor = Some (fb, ipq_surface) ->
        Genv.find_symbol (Clight.globalenv (selected_clight_target version))
          us_object_list_processor._gMarioStates = Some mb ->
        Mem.load Mfloat32 cut_m mb 64 = Some (Vsingle height) ->
        Mem.load Mfloat32 after mb 64 = Some (Vsingle height) /\
        Mem.load Mint32 after mb 104 = Mem.load Mint32 cut_m mb 104 /\
        Mem.load Mfloat32 after mb 112 = Mem.load Mfloat32 cut_m mb 112 /\
        Mem.load Mint32 after mb 12 = Mem.load Mint32 cut_m mb 12)).

Theorem ipq_completed_push_exposes_actual_query_cut : InkObjectPushActualCallCut.
Proof.
  intros version start mb actor padding trace after result Hvalid Hcall.
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    pose proof (ipq_entry_m _ _ _ _ _ _ _ _ _ Hentry) as Hm;
    pose proof (ipq_entry_locals_separate _ _ _ _ _ _ _ _ _ Hvalid Hentry) as Hlocals end.
  destruct (ipq_call_source version)
    as (_ & Hbody & Hinside & Hnormal & HinnerNormal & Hkeep & HinnerKeep).
  lazymatch goal with Hrun : ClightBigstep.exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
    rewrite Hbody in Hrun;
    destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
      as (choice_le & choice_m & pre & rest & Htrace & Hprefix & Hchoice) end.
  assert (choice_le ! IPH._m = Some (Vptr mb Ptrofs.zero)) as HchoiceM
    by (rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hprefix Hkeep); exact Hm).
  inversion Hchoice; subst. destruct b.
  - lazymatch goal with HinsideRun : ClightBigstep.exec_stmt _ _ _ _ _ (iph_inside version) _ _ _ _ |- _ =>
      rewrite Hinside in HinsideRun;
      destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ HinnerNormal HinsideRun)
        as (cut_le & cut_m & wall_trace & query_trace & Hsplit & Hwall & Hquery) end.
    assert (cut_le ! IPH._m = Some (Vptr mb Ptrofs.zero)) as HcutM
      by (rewrite (ifr_execution_keeps_temp _ _ _ _ _ _ _ _ _ _ Hwall HinnerKeep); exact HchoiceM).
    do 8 eexists. split; [eassumption|]. split; [reflexivity|].
    split; [exact Hprefix|]. split; [eassumption|]. right.
    exists cut_le, cut_m, wall_trace, query_trace. do 2 eexists.
    split; [exact Hsplit|]. split; [unfold ocn_test_value; eauto|].
    split; [exact Hwall|]. split; [exact Hquery|]. split; [exact HcutM|].
    intros fb height Hlocal Hfloor Hsymbol Hy.
    assert (mb <> fb) as Hapart by (pose proof (Hlocals _ _ _ Hfloor); congruence).
    destruct (ipq_destination_query_and_commit_preserve_cache _ _ _ _ _ _ _ _ _ _ _
      Hlocal Hfloor Hsymbol Hapart HcutM Hy Hquery) as (Hheight & Hpointer & Hcache & Haction).
    lazymatch goal with Hfree : Mem.free_list ?before (blocks_of_env ?ge ?env) = Some after |- _ =>
      pose proof (ifc_free_list_frame (blocks_of_env ge env) before after
        Mfloat32 mb 64 (ipq_env_free_blocks _ _ _ Hlocals) Hfree) as Fy;
      pose proof (ifc_free_list_frame (blocks_of_env ge env) before after
        Mint32 mb 104 (ipq_env_free_blocks _ _ _ Hlocals) Hfree) as Fp;
      pose proof (ifc_free_list_frame (blocks_of_env ge env) before after
        Mfloat32 mb 112 (ipq_env_free_blocks _ _ _ Hlocals) Hfree) as Fh;
      pose proof (ifc_free_list_frame (blocks_of_env ge env) before after
        Mint32 mb 12 (ipq_env_free_blocks _ _ _ Hlocals) Hfree) as Fa end.
    rewrite Fy, Fp, Fh, Fa. auto.
  - cbn beta iota in *.
    lazymatch goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      inversion Hskip; subst end.
    do 8 eexists. split; [eassumption|]. split; [reflexivity|].
    split; [exact Hprefix|]. split; [eassumption|]. left.
    split; [unfold ocn_test_value; eauto|reflexivity].
Qed.

Definition InkObjectPushQueryBoundary : Prop :=
  InkObjectPushQueryFrame /\ InkPrimaryFreshCache /\ InkObjectPushActualCallCut.
Theorem ipq_object_push_query_checked : InkObjectPushQueryBoundary.
Proof.
  split; [exact ipq_destination_query_and_commit_preserve_cache|].
  split; [exact ipq_primary_query_supplies_fresh_cache|
    exact ipq_completed_push_exposes_actual_query_cut].
Qed.
