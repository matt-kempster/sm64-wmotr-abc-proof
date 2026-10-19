(** The real object scheduler reaches terrain updates immediately before its
    first scheduled platform-displacement call. Terrain's two scheduler-owned writes
    target gObjectCounter; their separation from a protected pointer cell is
    proved here. The remaining effects are exposed as the two actual list
    executions, not silently assumed harmless. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor
  jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  InkBackwardExecution InkPlatformSource InkPlatformWriteFrame InkPlatformDeparture
  TeleporterWrongWarpBoundary Rank1ObjectUpdateSchedule SecretContactExecution
  SelectedClightTarget UpperElevatorQueryResolution CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural JPSourceSymbolTransport
  JPWarpLevelEntryResolution LinkedClightPrograms NormalizedClightPrograms
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Local Open Scope Z_scope.
Module TTI := us_object_list_processor.

Inductive TTICallee := TTITerrain | TTIList.
Definition tti_ident c := match c with
| TTITerrain => TTI._update_terrain_objects
| TTIList => TTI._update_objects_in_list end.
Definition tti_body version c := match version, c with
| VersionUS, TTITerrain => us_object_list_processor.f_update_terrain_objects
| VersionJP, TTITerrain => jp_object_list_processor.f_update_terrain_objects
| VersionUS, TTIList => us_object_list_processor.f_update_objects_in_list
| VersionJP, TTIList => jp_object_list_processor.f_update_objects_in_list end.

Lemma tti_us_source : forall c,
  nth_error TTI.global_definitions
    (ueqr_definition_index (tti_ident c) TTI.global_definitions) =
    Some (tti_ident c, Gfun (Internal (tti_body VersionUS c))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tti_us_member : forall c,
  In (tti_ident c, Gfun (Internal (tti_body VersionUS c)))
    (unit_global_definitions us_units).
Proof.
  intro c. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 13 us_units).
  - exact (us_nlist_at_nIn _ 13 us_units).
  - eapply nth_error_In. exact (tti_us_source c).
Qed.
Lemma tti_us_selection : forall c,
  us_normalized_global_definition_map ! (tti_ident c) =
    Some (Gfun (Internal (tti_body VersionUS c))).
Proof.
  intro c. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (tti_us_member c).
Qed.
Lemma tti_us_selected_member : forall c,
  In (tti_ident c, Gfun (Internal (tti_body VersionUS c)))
    us_viewport_repaired_global_definitions.
Proof.
  intro c. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (tti_ident c, Gfun (Internal (tti_body VersionUS c))) = false) as Hrepair
      by (destruct c; vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (tti_us_selection c).
Qed.
Lemma tti_jp_source : forall c,
  (prog_defmap (nlist_at 13 jp_cleaned_units)) ! (tti_ident c) =
    Some (Gfun (Internal (tti_body VersionJP c))).
Proof. intros []; vm_compute; reflexivity. Qed.
Theorem tti_selected_bodies_resolve : forall version c,
  exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (tti_ident c) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tti_body version c)).
Proof.
  intros [] c.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (tti_us_selected_member c).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at 13 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 13 jp_cleaned_units).
    + exact (tti_jp_source c).
Qed.
Local Opaque selected_clight_target.

Definition tti_before version := ocn_prefix_items 11 (fn_body (r1s_body version)).
Definition tti_after version := tww_drop_sequence_prefix 13 (fn_body (r1s_body version)).
Definition tti_terrain_call := Scall None
  (Evar TTI._update_terrain_objects (Tfunction [] tvoid cc_default)) [].
Definition tti_apply_call := Scall None
  (Evar TTI._apply_mario_platform_displacement (Tfunction [] tvoid cc_default)) [].
Lemma tti_generated_order : forall version,
  fn_body (r1s_body version) = ocn_prepend (tti_before version)
    (Ssequence tti_terrain_call (Ssequence tti_apply_call (tti_after version))) /\
  forallb ibk_normal (tti_before version) = true.
Proof. intros []; split; reflexivity. Qed.

Lemma tti_direct_call_resolves : forall version e le m t last after out
  id f,
  e ! id = None ->
  (exists b,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version)) id = Some b /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
      Some (Internal f)) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (Scall None (Evar id (Tfunction [] tvoid cc_default)) [])
    t last after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) m (Internal f) []
      t after result /\ last = le /\ out = Out_normal.
Proof.
  intros version e le m t last after out id f Hlocal
    (fb & Hsymbol & Hfunction) Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ => cbn in Hclass;
    inversion Hclass; subst end.
  match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr fb Ptrofs.zero) by
      (eapply sce_function_name_value; eauto); subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target version)) fb = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hr : eval_exprlist _ _ _ _ [] _ _ |- _ => inversion Hr; subst end.
  eexists. repeat split; try reflexivity; eassumption.
Qed.

(** All memory cuts below belong to one completed actual update_objects body.
    No relation between arbitrary reset and apply memories is substituted. *)
Definition TTIFirstApplyFollowsTerrain : Prop :=
  forall version e le m t last after out,
  e ! TTI._update_terrain_objects = None ->
  e ! TTI._apply_mario_platform_displacement = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (r1s_body version)) t last after out ->
  exists cut_le cut_m terrain_m applied_m terrain_result apply_result
    pre terrain_t apply_t suf,
    t = pre ++ (terrain_t ++ (apply_t ++ suf)) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (ocn_prepend (tti_before version) Sskip) pre cut_le cut_m Out_normal /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) cut_m
      (Internal (tti_body version TTITerrain)) [] terrain_t terrain_m terrain_result /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) terrain_m
      (Internal (ipd_body version IPDApply)) [] apply_t applied_m apply_result /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e cut_le applied_m
      (tti_after version) suf last after out.
Theorem tti_actual_update_reaches_terrain_then_first_apply :
  TTIFirstApplyFollowsTerrain.
Proof.
  intros version e le m t last after out Hterrain Happly Hrun.
  destruct (tti_generated_order version) as [Hbody Hnormal]. rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cl & cm & pre & rest & Et & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _ tti_terrain_call _ _ _ _ _ eq_refl Hr)
    as (tl & tm & tt & tail & Er & Ht & Ha).
  destruct (ibk_split_sequence _ _ _ _ tti_apply_call _ _ _ _ _ eq_refl Ha)
    as (al & am & apply_trace & suf & Ea & Happ & Hs).
  destruct (tti_direct_call_resolves version e cl cm tt tl tm Out_normal
    _ _ Hterrain (tti_selected_bodies_resolve version TTITerrain) Ht)
    as (tr & Htr & -> & _).
  destruct (tti_direct_call_resolves version e cl tm apply_trace al am Out_normal
    _ _ Happly (ipd_selected_bodies_resolve version IPDApply) Happ)
    as (ar & Har & -> & _).
  exists cl, cm, tm, am, tr, ar, pre, tt, apply_trace, suf.
  split; [rewrite Et, Er, Ea; reflexivity|]. repeat split; assumption.
Qed.

Definition tti_stage version (second : bool) :=
  match fn_body (tti_body version TTITerrain) with
  | Ssequence a b => if second then b else a | _ => Sskip end.
Definition tti_stage_prepare version second :=
  match tti_stage version second with
  | Ssequence (Ssequence prepare _) _ => prepare | _ => Sskip end.
Definition tti_stage_call version second :=
  match tti_stage version second with
  | Ssequence (Ssequence _ call) _ => call | _ => Sskip end.
Definition tti_stage_store version second :=
  match tti_stage version second with
  | Ssequence _ store => store | _ => Sskip end.
Lemma tti_exact_terrain_list_indices : forall version second,
  tti_stage_call version second = Scall
    (Some (if second then TTI._t'2 else TTI._t'1))
    (Evar TTI._update_objects_in_list
      (Tfunction [tptr (Tstruct TTI._ObjectNode noattr)] tint cc_default))
    [Ebinop Oadd
      (Etempvar (if second then TTI._t'3 else TTI._t'4)
        (tptr (Tstruct TTI._ObjectNode noattr)))
      (Econst_int (Int.repr (if second then 9 else 11)) tint)
      (tptr (Tstruct TTI._ObjectNode noattr))].
Proof. intros [] []; reflexivity. Qed.
Lemma tti_terrain_generated_stages : forall version second,
  fn_body (tti_body version TTITerrain) =
    Ssequence (tti_stage version false) (tti_stage version true) /\
  tti_stage version second = Ssequence
    (Ssequence (tti_stage_prepare version second) (tti_stage_call version second))
    (tti_stage_store version second) /\
  ibk_normal (tti_stage_prepare version second) = true /\
  ibk_normal (tti_stage_call version second) = true.
Proof. intros [] []; repeat split; reflexivity. Qed.

Lemma tti_stage_prepare_leaves_memory : forall version second ge e le m t last after out,
  ocn_exec ge e le m (tti_stage_prepare version second) t last after out ->
  after = m /\ out = Out_normal.
Proof. intros [] [] ge e le m t last after out Hrun;
  inversion Hrun; subst; split; reflexivity. Qed.

Lemma tti_counter_store_frames_other_block : forall version second (ge : genv) e le m
  t last after out cb protected,
  e ! TTI._gObjectCounter = None ->
  Genv.find_symbol ge TTI._gObjectCounter = Some cb ->
  cb <> protected ->
  ocn_exec ge e le m (tti_stage_store version second) t last after out ->
  ipw_frame protected m after.
Proof.
  intros version second ge e le m t last after out cb protected Hlocal Hsymbol Hother Hrun.
  assert (ipw_context ge e le protected [TTI._gObjectCounter] [] []) as Hctx.
  { split.
    - intros id [<-|[]]. unfold ipw_root_safe. split.
      + intros b ty Hbinding. congruence.
      + intros _ b Hfind. assert (b = cb) by congruence. subst; exact Hother.
    - split; intros id []. }
  assert (tti_stage_store version second = Sassign
    (Evar TTI._gObjectCounter tuint)
    (Etempvar (if second then TTI._t'2 else TTI._t'1) tint)) as Hshape
    by (destruct version, second; reflexivity).
  rewrite Hshape in Hrun.
  exact (proj2 (ipw_write_frame ge e le protected [TTI._gObjectCounter] [] []
    (Evar TTI._gObjectCounter tuint)
    (Etempvar (if second then TTI._t'2 else TTI._t'1) tint)
    m t last after out Hctx eq_refl Hrun)).
Qed.

(** A source-level receipt identifies the actual list call, with its evaluated
    arguments and actual returned memory. It does not assume that list's object
    behavior callbacks preserve any pointer. *)
Definition TTIListReceipt version e second before after : Prop :=
  exists le last trace args result,
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
      (tti_stage_call version second) trace last after Out_normal /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tti_body version TTIList)) args trace after result.

Lemma tti_stage_real_list_call : forall version second e le m t last after out,
  e ! TTI._update_objects_in_list = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tti_stage_call version second) t last after out ->
  exists args result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) m
      (Internal (tti_body version TTIList)) args t after result.
Proof.
  intros version second e le m t last after out Hlocal Hrun.
  destruct (tti_selected_bodies_resolve version TTIList) as (fb & Hsymbol & Hfunction).
  rewrite tti_exact_terrain_list_indices in Hrun.
  unfold ocn_exec, ClightBigstep.Clight2.exec_stmt in Hrun.
  destruct second; inversion Hrun; subst;
  try match goal with Hclass : classify_fun _ = _ |- _ => cbn in Hclass;
    inversion Hclass; subst end;
  try match goal with Hr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr fb Ptrofs.zero) by
      (eapply sce_function_name_value; eauto); subst vf end;
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr
      (Clight.globalenv (selected_clight_target version)) fb = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end;
  eauto.
Qed.

Definition TTITerrainStoreFrameBoundary : Prop :=
  forall version e le m t last after out cb protected,
  e ! TTI._gObjectCounter = None ->
  e ! TTI._update_objects_in_list = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TTI._gObjectCounter = Some cb ->
  cb <> protected ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (tti_body version TTITerrain)) t last after out ->
  exists first_return second_entry second_return,
    TTIListReceipt version e false m first_return /\
    TTIListReceipt version e true second_entry second_return /\
    ipw_frame protected first_return second_entry /\
    ipw_frame protected second_return after /\
    (ipw_frame protected m first_return ->
     ipw_frame protected second_entry second_return ->
     ipw_frame protected m after).
Theorem tti_terrain_only_counter_stores_between_real_list_calls :
  TTITerrainStoreFrameBoundary.
Proof.
  intros version e le m t last after out cb protected Hlocal Hlist Hsymbol Hother Hrun.
  destruct (tti_terrain_generated_stages version false) as (Hbody & Hfirst & Hfp & Hfc).
  destruct (tti_terrain_generated_stages version true) as (_ & Hsecond & Hsp & Hsc).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ (tti_stage version false) _ _ _ _ _
    ltac:(destruct version; reflexivity) Hrun)
    as (mid_le & mid_m & first_t & second_t & Et & Hfirst_run & Hsecond_run).
  rewrite Hfirst in Hfirst_run. rewrite Hsecond in Hsecond_run.
  destruct (ibk_split_sequence _ _ _ _
    (Ssequence (tti_stage_prepare version false) (tti_stage_call version false)) _ _ _ _ _
    ltac:(destruct version; reflexivity) Hfirst_run)
    as (first_le & first_m & first_call_t & first_store_t & Efirst & Hfirst_call & Hfirst_store).
  destruct (ibk_split_sequence _ _ _ _ (tti_stage_prepare version false) _ _ _ _ _ Hfp Hfirst_call)
    as (prepared_le & prepared_m & prep_t & list_t & Eprep & Hprep & Hlist_run).
  destruct (tti_stage_prepare_leaves_memory _ _ _ _ _ _ _ _ _ _ Hprep) as [-> _].
  destruct (tti_stage_real_list_call _ _ _ _ _ _ _ _ _ Hlist Hlist_run)
    as (args1 & result1 & Hreal1).
  destruct (ibk_split_sequence _ _ _ _
    (Ssequence (tti_stage_prepare version true) (tti_stage_call version true)) _ _ _ _ _
    ltac:(destruct version; reflexivity) Hsecond_run)
    as (second_le & second_m & second_call_t & second_store_t & Esecond & Hsecond_call & Hsecond_store).
  destruct (ibk_split_sequence _ _ _ _ (tti_stage_prepare version true) _ _ _ _ _ Hsp Hsecond_call)
    as (prepared2_le & prepared2_m & prep2_t & list2_t & Eprep2 & Hprep2 & Hlist2_run).
  destruct (tti_stage_prepare_leaves_memory _ _ _ _ _ _ _ _ _ _ Hprep2) as [-> _].
  destruct (tti_stage_real_list_call _ _ _ _ _ _ _ _ _ Hlist Hlist2_run)
    as (args2 & result2 & Hreal2).
  pose proof (tti_counter_store_frames_other_block _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hsymbol Hother Hfirst_store) as Hframe1.
  pose proof (tti_counter_store_frames_other_block _ _ _ _ _ _ _ _ _ _ _ _
    Hlocal Hsymbol Hother Hsecond_store) as Hframe2.
  exists first_m, mid_m, second_m.
  split; [unfold TTIListReceipt; eauto 8|].
  split; [unfold TTIListReceipt; eauto 8|].
  split; [exact Hframe1|]. split; [exact Hframe2|].
  intros Hlist1 Hlist2 chunk ofs.
  rewrite Hframe2, Hlist2, Hframe1, Hlist1. reflexivity.
Qed.

Definition TTITerrainCallStoreFrameBoundary : Prop :=
  forall version before t after result cb protected,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TTI._gObjectCounter = Some cb ->
  cb <> protected ->
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tti_body version TTITerrain)) [] t after result ->
  exists first_return second_entry second_return,
    TTIListReceipt version empty_env false before first_return /\
    TTIListReceipt version empty_env true second_entry second_return /\
    ipw_frame protected first_return second_entry /\
    ipw_frame protected second_return after.
Theorem tti_completed_terrain_call_has_store_frames :
  TTITerrainCallStoreFrameBoundary.
Proof.
  intros version before t after result cb protected Hsymbol Hother Hcall.
  assert (fn_vars (tti_body version TTITerrain) = []) as Hvars
    by (destruct version; reflexivity).
  inversion Hcall; subst.
  match goal with Hentry : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion Hentry; subst; clear Hentry end.
  match goal with Halloc : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Halloc; inversion Halloc; subst; clear Halloc end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?after |- _ =>
    change (Some before = Some after) in Hfree; inversion Hfree; subst end.
  lazymatch goal with Hrun : ClightBigstep.exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
    destruct (tti_terrain_only_counter_stores_between_real_list_calls version
      empty_env _ _ _ _ _ _ cb protected
      (PTree.gempty (block * type) TTI._gObjectCounter)
      (PTree.gempty (block * type) TTI._update_objects_in_list) Hsymbol Hother Hrun)
      as (r1 & e2 & r2 & Hreceipt1 & Hreceipt2 & HstoreFrame1 & HstoreFrame2 & _) end.
  exists r1, e2, r2. auto.
Qed.

(** The implication's only callback frames are the two list executions
    witnessed in this SAME update_objects run. Incoming null is explicitly
    required at terrain entry; initialization-to-entry is a separate interval. *)
Definition TTINullTerrainEntryMakesFirstApplyIdle : Prop :=
  forall version e le m t last after out cb pb,
  e ! TTI._update_terrain_objects = None ->
  e ! TTI._apply_mario_platform_displacement = None ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TTI._gObjectCounter = Some cb ->
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    IPD._gMarioPlatform = Some pb ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (fn_body (r1s_body version)) t last after out ->
  exists cut_le cut_m terrain_m applied_m terrain_result apply_result
    pre terrain_t apply_t suf first_return second_entry second_return,
    t = pre ++ (terrain_t ++ (apply_t ++ suf)) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
      (ocn_prepend (tti_before version) Sskip) pre cut_le cut_m Out_normal /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) cut_m
      (Internal (tti_body version TTITerrain)) [] terrain_t terrain_m terrain_result /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) terrain_m
      (Internal (ipd_body version IPDApply)) [] apply_t applied_m apply_result /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e cut_le applied_m
      (tti_after version) suf last after out /\
    TTIListReceipt version empty_env false cut_m first_return /\
    TTIListReceipt version empty_env true second_entry second_return /\
    ipw_frame pb first_return second_entry /\
    ipw_frame pb second_return terrain_m /\
    (Mem.load Mptr cut_m pb 0 = Some (Vint Int.zero) ->
      Mem.load Mptr first_return pb 0 = Mem.load Mptr cut_m pb 0 ->
      Mem.load Mptr second_return pb 0 = Mem.load Mptr second_entry pb 0 ->
      Mem.load Mptr terrain_m pb 0 = Some (Vint Int.zero) /\
      apply_t = E0 /\ applied_m = terrain_m).
Theorem tti_same_run_null_terrain_entry_and_list_frames_make_first_apply_idle :
  TTINullTerrainEntryMakesFirstApplyIdle.
Proof.
  intros version e le m t last after out cb pb Hterrain Happly Hcounter Hplatform Hrun.
  destruct (tti_actual_update_reaches_terrain_then_first_apply version e le m t last
    after out Hterrain Happly Hrun)
    as (cl & cm & tm & am & tr & ar & pre & tt & apply_trace & suf &
      Et & Hp & Ht & Ha & Hs).
  assert (cb <> pb) as Hseparate by
    (eapply Genv.global_addresses_distinct; eauto; discriminate).
  destruct (tti_completed_terrain_call_has_store_frames version cm tt tm tr
    cb pb Hcounter Hseparate Ht) as (r1 & e2 & r2 & H1 & H2 & F1 & F2).
  exists cl, cm, tm, am, tr, ar, pre, tt, apply_trace, suf, r1, e2, r2.
  split; [exact Et|].
  split; [exact Hp|].
  split; [exact Ht|].
  split; [exact Ha|].
  split; [exact Hs|].
  split; [exact H1|].
  split; [exact H2|].
  split; [exact F1|].
  split; [exact F2|].
  intros Hnull Flist1 Flist2.
  assert (Mem.load Mptr tm pb 0 = Some (Vint Int.zero)) as Hend by
    (rewrite F2, Flist2, F1, Flist1; exact Hnull).
  split; [exact Hend|].
  exact (ipd_null_platform_call_cannot_depart version tm pb apply_trace am ar Hplatform Hend Ha).
Qed.

Definition TeleporterTerrainIntervalBoundary : Prop :=
  TTIFirstApplyFollowsTerrain /\ TTITerrainStoreFrameBoundary /\
  TTINullTerrainEntryMakesFirstApplyIdle.
Theorem teleporter_terrain_interval_boundary_checked :
  TeleporterTerrainIntervalBoundary.
Proof.
  split; [exact tti_actual_update_reaches_terrain_then_first_apply|].
  split; [exact tti_terrain_only_counter_stores_between_real_list_calls|].
  exact tti_same_run_null_terrain_entry_and_list_frames_make_first_apply_idle.
Qed.
