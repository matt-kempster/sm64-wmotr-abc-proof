(** Actual source executions from the area-load guard to platform clearing.
    The US reset is reached before the object-allocation loop.  This file
    deliberately does not assume that a later callback preserves the null
    platform, and does not give JP the reset absent from its source. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_area jp_area
  us_object_list_processor jp_object_list_processor
  us_platform_displacement.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  InkBackwardExecution TeleporterWrongWarpBoundary TeleporterDestinationReset
  UpperElevatorQueryResolution CleanedClightPrograms ClightLinkExecution
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SelectedClightTarget
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair SecretContactExecution.
Import ListNotations.
Local Open Scope Z_scope.

Definition tpr_load_body version := fn_body (tdr_callee_body version TDRLoadMarioArea).
Definition tpr_load_prefix version := ocn_prefix_items 6 (tpr_load_body version).
Definition tpr_load_tail version := tww_drop_sequence_prefix 6 (tpr_load_body version).
Definition tpr_area_guard := Ebinop Oeq (Etempvar us_area._t'2 tschar)
  (Etempvar us_area._t'4 tschar) tint.
Definition tpr_spawn_branch version := match tpr_load_tail version with
  | Sifthenelse _ yes _ => yes | _ => Sskip end.
Definition tpr_before_spawn version := ocn_prefix_items 2 (tpr_spawn_branch version).
Definition tpr_spawn_call version :=
  tww_drop_sequence_prefix 2 (tpr_spawn_branch version).
Definition tpr_spawn_args := [Econst_int Int.zero tint;
  Etempvar us_area._t'5 (tptr (Tstruct us_area._SpawnInfo noattr))].
Definition tpr_spawn_call_type := Tfunction
  [tint; tptr (Tstruct us_area._SpawnInfo noattr)] tvoid cc_default.

Theorem tpr_generated_load_cuts : forall version,
  tpr_load_body version = ocn_prepend (tpr_load_prefix version)
    (Sifthenelse tpr_area_guard (tpr_spawn_branch version) Sskip) /\
  forallb ibk_normal (tpr_load_prefix version) = true /\
  tpr_spawn_branch version = ocn_prepend (tpr_before_spawn version)
    (tpr_spawn_call version) /\
  forallb ibk_normal (tpr_before_spawn version) = true /\
  tpr_spawn_call version = Scall None
    (Evar us_area._spawn_objects_from_info tpr_spawn_call_type) tpr_spawn_args.
Proof. intros []; repeat split; reflexivity. Qed.

(** A failed area-index match has the false branch, even if the surrounding
    Clight function completed.  Successful completion alone is not silently
    equated with successfully loading the requested destination area. *)
Definition TPRGuardedSpawnExecution : Prop :=
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tpr_load_body version) t last after out ->
  exists cut_le cut_m chosen pre branch,
    t = pre ++ branch /\
    ocn_exec ge e le m (ocn_prepend (tpr_load_prefix version) Sskip)
      pre cut_le cut_m Out_normal /\
    ocn_test_value ge e cut_le cut_m tpr_area_guard chosen /\
    ocn_exec ge e cut_le cut_m
      (if chosen then tpr_spawn_branch version else Sskip)
      branch last after out /\
    (chosen = true -> exists call_le call_m assign_t call_t,
      branch = assign_t ++ call_t /\
      ocn_exec ge e cut_le cut_m (ocn_prepend (tpr_before_spawn version) Sskip)
        assign_t call_le call_m Out_normal /\
      ocn_exec ge e call_le call_m (tpr_spawn_call version) call_t last after out).
Theorem tpr_actual_area_load_has_guarded_spawn : TPRGuardedSpawnExecution.
Proof.
  unfold TPRGuardedSpawnExecution.
  intros version ge e le m t last after out Hrun.
  destruct (tpr_generated_load_cuts version)
    as (Hbody & Hprefix & Hbranch & Hnormal & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hprefix Hrun)
    as (cl & cm & pre & branch & Et & Hp & Hb).
  inversion Hb; subst. exists cl, cm, b, pre, branch.
  repeat split; try assumption.
  - unfold ocn_test_value. eauto.
  - intros ->. assert (ocn_exec ge e cl cm (tpr_spawn_branch version)
      branch last after out) as Hexec by assumption.
    rewrite Hbranch in Hexec.
    destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hexec)
      as (ll & lm & assign_t & ct & E & Ha & Hc).
    exists ll, lm, assign_t, ct. auto.
Qed.

Inductive TPRCallee := TPRSpawn | TPRClear.
Definition tpr_callee_ident callee := match callee with
  | TPRSpawn => us_area._spawn_objects_from_info
  | TPRClear => us_object_list_processor._clear_mario_platform end.
Definition tpr_callee_body callee := match callee with
  | TPRSpawn => us_object_list_processor.f_spawn_objects_from_info
  | TPRClear => us_platform_displacement.f_clear_mario_platform end.
Definition tpr_spawn_body version := match version with
  | VersionUS => us_object_list_processor.f_spawn_objects_from_info
  | VersionJP => jp_object_list_processor.f_spawn_objects_from_info end.
Definition tpr_callee_unit callee := match callee with
  | TPRSpawn => 13%nat | TPRClear => 29%nat end.
Definition tpr_us_definitions callee := match callee with
  | TPRSpawn => us_object_list_processor.global_definitions
  | TPRClear => us_platform_displacement.global_definitions end.
Lemma tpr_us_source : forall callee,
  nth_error (tpr_us_definitions callee)
    (ueqr_definition_index (tpr_callee_ident callee) (tpr_us_definitions callee)) =
  Some (tpr_callee_ident callee, Gfun (Internal (tpr_callee_body callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tpr_us_member : forall callee,
  In (tpr_callee_ident callee, Gfun (Internal (tpr_callee_body callee)))
    (unit_global_definitions us_units).
Proof.
  intro callee.
  assert (prog_defs (us_nlist_at (tpr_callee_unit callee) us_units) =
    tpr_us_definitions callee) as Hunit by (destruct callee; reflexivity).
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (tpr_callee_unit callee) us_units).
  - exact (us_nlist_at_nIn _ (tpr_callee_unit callee) us_units).
  - rewrite Hunit. eapply nth_error_In. exact (tpr_us_source callee).
Qed.
Lemma tpr_us_selection : forall callee,
  us_normalized_global_definition_map ! (tpr_callee_ident callee) =
    Some (Gfun (Internal (tpr_callee_body callee))).
Proof.
  intro callee. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact (tpr_us_member callee).
Qed.
Lemma tpr_us_no_repair : forall callee,
  us_selected_definition_needs_viewport_repair
    (tpr_callee_ident callee, Gfun (Internal (tpr_callee_body callee))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.
Local Opaque normalize_global_definition_map.
Lemma tpr_us_selected_member : forall callee,
  In (tpr_callee_ident callee, Gfun (Internal (tpr_callee_body callee)))
    us_viewport_repaired_global_definitions.
Proof.
  intro callee. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition. rewrite tpr_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact (tpr_us_selection callee).
Qed.
Lemma tpr_jp_spawn_source :
  (prog_defmap (nlist_at 13 jp_cleaned_units)) !
    (tpr_callee_ident TPRSpawn) =
    Some (Gfun (Internal (tpr_spawn_body VersionJP))).
Proof. vm_compute; reflexivity. Qed.
Theorem tpr_selected_callees_resolve : forall callee, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
    (tpr_callee_ident callee) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target VersionUS)) b =
    Some (Internal (tpr_callee_body callee)).
Proof.
  intro callee. eapply program_definitions_resolve_internal_globalenv.
  - exact us_viewport_repaired_program_definitions_checked.
  - exact us_viewport_repaired_definition_names_norepet.
  - exact (tpr_us_selected_member callee).
Qed.
Theorem tpr_selected_spawn_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (tpr_callee_ident TPRSpawn) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tpr_spawn_body version)).
Proof.
  intros [].
  - exact (tpr_selected_callees_resolve TPRSpawn).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at 13 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 13 jp_cleaned_units).
    + exact tpr_jp_spawn_source.
Qed.

(** Keep the selected whole-program constant opaque during local symbolic
    execution: resolving a pointer must not normalize the complete program. *)
Local Opaque selected_clight_target.

Definition TPRRealSpawnCalleeExecution : Prop :=
  forall version e le m t last after out,
  e ! us_area._spawn_objects_from_info = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (tpr_spawn_call version) t last after out ->
  exists args result,
    eval_exprlist (Clight.globalenv (selected_clight_target version)) e le m
      tpr_spawn_args [tint; tptr (Tstruct us_area._SpawnInfo noattr)] args /\
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) m
      (Internal (tpr_spawn_body version)) args t after result /\
    last = le /\ out = Out_normal.
Theorem tpr_reached_spawn_call_uses_real_body : TPRRealSpawnCalleeExecution.
Proof.
  unfold TPRRealSpawnCalleeExecution.
  intros version e le m t last after out Hlocal Hrun.
  destruct (tpr_selected_spawn_resolves version) as (b & Hsymbol & Hfunction).
  destruct (tpr_generated_load_cuts version) as (_ & _ & _ & _ & Hsource).
  rewrite Hsource in Hrun. unfold tpr_spawn_call_type in Hrun.
  inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      b = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  eauto 9.
Qed.

Definition tpr_spawn_prefix := ocn_prefix_items 4
  (fn_body us_object_list_processor.f_spawn_objects_from_info).
Definition tpr_spawn_after_clear := tww_drop_sequence_prefix 5
  (fn_body us_object_list_processor.f_spawn_objects_from_info).
Theorem tpr_generated_us_clear_execution_cut :
  fn_body us_object_list_processor.f_spawn_objects_from_info =
    ocn_prepend tpr_spawn_prefix
      (Ssequence tww_clear_platform_call tpr_spawn_after_clear) /\
  forallb ibk_normal tpr_spawn_prefix = true /\
  tww_direct_call_count us_object_list_processor._clear_mario_platform
    (fn_body jp_object_list_processor.f_spawn_objects_from_info) = 0%nat.
Proof. repeat split; reflexivity. Qed.

Definition TPRClearFunctionNullStore : Prop :=
  forall m t after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target VersionUS)) m
    (Internal us_platform_displacement.f_clear_mario_platform) [] t after result ->
  exists platform_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._gMarioPlatform = Some platform_block /\
    Mem.store Mptr m platform_block 0 (Vint Int.zero) = Some after /\
    Mem.load Mptr after platform_block 0 = Some (Vint Int.zero).
Lemma tpr_bigstep_clear_is_actual_step :
  forall ge le m t last after out,
  ocn_exec ge empty_env le m tww_clear_platform_statement t last after out ->
  Clight.step2 ge
    (State us_platform_displacement.f_clear_mario_platform
      tww_clear_platform_statement Kstop empty_env le m) E0
    (State us_platform_displacement.f_clear_mario_platform
      Sskip Kstop empty_env le after).
Proof.
  intros ge le m t last after out Hrun.
  inversion Hrun; subst. econstructor; eauto.
Qed.
Lemma tpr_clear_function_semantic_null : forall (ge : genv) m t after result,
  ClightBigstep.Clight2.eval_funcall ge m
    (Internal us_platform_displacement.f_clear_mario_platform) [] t after result ->
  exists platform_block,
    Genv.find_symbol ge us_platform_displacement._gMarioPlatform = Some platform_block /\
    Mem.store Mptr m platform_block 0 (Vint Int.zero) = Some after /\
    Mem.load Mptr after platform_block 0 = Some (Vint Int.zero).
Proof.
  intros ge m t after result Hcall. inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [us_platform_displacement.f_clear_mario_platform fn_vars] in Ha;
    inversion Ha; subst; try clear Ha end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?after |- _ =>
    change (Some before = Some after) in Hfree; inversion Hfree; subst end.
  eapply (tww_generated_clear_platform_stores_null ge
    us_platform_displacement.f_clear_mario_platform Kstop).
  eapply tpr_bigstep_clear_is_actual_step; eassumption.
Qed.
Theorem tpr_actual_clear_function_stores_null : TPRClearFunctionNullStore.
Proof. exact (tpr_clear_function_semantic_null _). Qed.

Definition TPRReachedClearCallNullStore : Prop :=
  forall e le m t last after out,
  e ! us_object_list_processor._clear_mario_platform = None ->
  ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le m
    tww_clear_platform_call t last after out ->
  exists platform_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._gMarioPlatform = Some platform_block /\
    Mem.store Mptr m platform_block 0 (Vint Int.zero) = Some after /\
    Mem.load Mptr after platform_block 0 = Some (Vint Int.zero).
Lemma tpr_clear_call_semantic_null : forall (ge : genv) e le m t last after out b,
  e ! us_object_list_processor._clear_mario_platform = None ->
  Genv.find_symbol ge us_object_list_processor._clear_mario_platform = Some b ->
  Genv.find_funct_ptr ge b =
    Some (Internal us_platform_displacement.f_clear_mario_platform) ->
  ocn_exec ge e le m tww_clear_platform_call t last after out ->
  exists platform_block,
    Genv.find_symbol ge us_platform_displacement._gMarioPlatform = Some platform_block /\
    Mem.store Mptr m platform_block 0 (Vint Int.zero) = Some after /\
    Mem.load Mptr after platform_block 0 = Some (Vint Int.zero).
Proof.
  intros ge e le m t last after out b Hlocal Hsymbol Hfunction Hrun.
  unfold tww_clear_platform_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr ge b = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hargs : eval_exprlist _ _ _ _ [] [] ?args |- _ =>
    inversion Hargs; subst args end.
  eapply tpr_clear_function_semantic_null; eassumption.
Qed.
Theorem tpr_reached_clear_call_stores_null : TPRReachedClearCallNullStore.
Proof.
  unfold TPRReachedClearCallNullStore.
  intros e le m t last after out Hlocal Hrun.
  destruct (tpr_selected_callees_resolve TPRClear) as (b & Hsymbol & Hfunction).
  exact (tpr_clear_call_semantic_null _ _ _ _ _ _ _ _ _
    Hlocal Hsymbol Hfunction Hrun).
Qed.

Definition TPRUSSpawnExecutionCheckpoint e le m t last after out : Prop :=
  exists clear_le clear_m done_le cleared_m platform_block pre clear_t suf,
    t = pre ++ (clear_t ++ suf) /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le m
      (ocn_prepend tpr_spawn_prefix Sskip) pre clear_le clear_m Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e clear_le clear_m
      tww_clear_platform_call clear_t done_le cleared_m Out_normal /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
      us_platform_displacement._gMarioPlatform = Some platform_block /\
    Mem.load Mptr cleared_m platform_block 0 = Some (Vint Int.zero) /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e done_le cleared_m
      tpr_spawn_after_clear suf last after out.
Definition TPRUSSpawnBodyNullCheckpoint : Prop :=
  forall e le m t last after out,
  e ! us_object_list_processor._clear_mario_platform = None ->
  ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le m
    (fn_body us_object_list_processor.f_spawn_objects_from_info) t last after out ->
  TPRUSSpawnExecutionCheckpoint e le m t last after out.
Theorem tpr_actual_us_spawn_body_has_null_checkpoint : TPRUSSpawnBodyNullCheckpoint.
Proof.
  unfold TPRUSSpawnBodyNullCheckpoint, TPRUSSpawnExecutionCheckpoint.
  intros e le m t last after out Hlocal Hrun.
  destruct tpr_generated_us_clear_execution_cut as (Hbody & Hnormal & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cl & cm & pre & rest & Et & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _ tww_clear_platform_call _ _ _ _ _ eq_refl Hr)
    as (dl & dm & ct & suf & Er & Hclear & Hsuf).
  destruct (tpr_reached_clear_call_stores_null _ _ _ _ _ _ _ Hlocal Hclear)
    as (pb & Hsymbol & Hstore & Hload).
  exists cl, cm, dl, dm, pb, pre, ct, suf.
  repeat split; try assumption. now subst.
Qed.

Lemma tpr_spawn_entry_does_not_shadow_clear :
  forall ge args m e le allocated,
  function_entry2 ge us_object_list_processor.f_spawn_objects_from_info
    args m e le allocated ->
  e ! us_object_list_processor._clear_mario_platform = None.
Proof.
  intros ge args m e le allocated Hentry. inversion Hentry; subst.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [us_object_list_processor.f_spawn_objects_from_info fn_vars] in Ha;
    inversion Ha; subst; try clear Ha end.
  match goal with Ha : alloc_variables _ _ _ [] _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  rewrite PTree.gso by discriminate. apply PTree.gempty.
Qed.

Definition TPRUSSpawnCallCheckpoint (m : mem) (args : list val) (t : trace)
    (after : mem) (result : val) : Prop :=
  exists e le allocated body_last body_after body_out,
    function_entry2 (Clight.globalenv (selected_clight_target VersionUS))
      us_object_list_processor.f_spawn_objects_from_info args m e le allocated /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le allocated
      (fn_body us_object_list_processor.f_spawn_objects_from_info)
      t body_last body_after body_out /\
    outcome_result_value body_out
      (fn_return us_object_list_processor.f_spawn_objects_from_info) result body_after /\
    Mem.free_list body_after
      (blocks_of_env (Clight.globalenv (selected_clight_target VersionUS)) e) = Some after /\
    TPRUSSpawnExecutionCheckpoint e le allocated t body_last body_after body_out.
Definition TPRUSSpawnFuncallNullCheckpoint : Prop :=
  forall m args t after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target VersionUS)) m
    (Internal us_object_list_processor.f_spawn_objects_from_info) args t after result ->
  TPRUSSpawnCallCheckpoint m args t after result.
Theorem tpr_actual_us_spawn_function_has_null_checkpoint : TPRUSSpawnFuncallNullCheckpoint.
Proof.
  unfold TPRUSSpawnFuncallNullCheckpoint, TPRUSSpawnCallCheckpoint.
  intros m args t after result Hcall. inversion Hcall; subst.
  do 6 eexists. split; [eassumption|]. split; [eassumption|].
  split; [eassumption|]. split; [eassumption|].
  eapply tpr_actual_us_spawn_body_has_null_checkpoint.
  - eapply tpr_spawn_entry_does_not_shadow_clear; eassumption.
  - eassumption.
Qed.

(** Composition starts with one completed real area-load body and retains
    its actual guard.  Taking that guard reaches the real spawn function
    and hence its null platform checkpoint before object allocation. *)
Definition TPRUSAreaLoadExecutionCheckpoint (e : env) (le : temp_env) (m : mem)
    (t : trace) (last : temp_env) (after : mem) (out : outcome) : Prop :=
  exists cut_le cut_m chosen pre branch,
    t = pre ++ branch /\
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le m
      (ocn_prepend (tpr_load_prefix VersionUS) Sskip)
      pre cut_le cut_m Out_normal /\
    ocn_test_value (Clight.globalenv (selected_clight_target VersionUS)) e
      cut_le cut_m tpr_area_guard chosen /\
    (chosen = true -> exists call_le call_m assign_t call_t args result,
      branch = assign_t ++ call_t /\
      ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e cut_le cut_m
        (ocn_prepend (tpr_before_spawn VersionUS) Sskip)
        assign_t call_le call_m Out_normal /\
      ClightBigstep.Clight2.eval_funcall
        (Clight.globalenv (selected_clight_target VersionUS)) call_m
        (Internal us_object_list_processor.f_spawn_objects_from_info)
        args call_t after result /\
      TPRUSSpawnCallCheckpoint call_m args call_t after result).
Definition TPRUSGuardedLoadNullCheckpoint : Prop :=
  forall e le m t last after out,
  e ! us_area._spawn_objects_from_info = None ->
  ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) e le m
    (tpr_load_body VersionUS) t last after out ->
  TPRUSAreaLoadExecutionCheckpoint e le m t last after out.
Theorem tpr_actual_us_area_load_has_guarded_null_checkpoint :
  TPRUSGuardedLoadNullCheckpoint.
Proof.
  unfold TPRUSGuardedLoadNullCheckpoint, TPRUSAreaLoadExecutionCheckpoint.
  intros e le m t last after out Hlocal Hrun.
  destruct (tpr_actual_area_load_has_guarded_spawn VersionUS _ _ _ _ _ _ _ _ Hrun)
    as (cl & cm & chosen & pre & branch & Et & Hp & Hguard & Hb & Htaken).
  exists cl, cm, chosen, pre, branch. repeat split; try assumption.
  intros Htrue.
  destruct (Htaken Htrue) as (call_le & call_m & assign_t & call_t & Eb & Ha & Hspawn).
  destruct (tpr_reached_spawn_call_uses_real_body VersionUS _ _ _ _ _ _ _ Hlocal Hspawn)
    as (args & result & Hargs & Hcall & Hlast & Hout).
  exists call_le, call_m, assign_t, call_t, args, result.
  repeat split; try assumption.
  eapply tpr_actual_us_spawn_function_has_null_checkpoint; exact Hcall.
Qed.

Definition TPRUSLoadFuncallGuardedCheckpoint : Prop :=
  forall m t after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target VersionUS)) m
    (Internal us_area.f_load_mario_area) [] t after result ->
  exists le last out,
    ocn_exec (Clight.globalenv (selected_clight_target VersionUS)) empty_env le m
      (tpr_load_body VersionUS) t last after out /\
    TPRUSAreaLoadExecutionCheckpoint empty_env le m t last after out.
Theorem tpr_actual_us_load_function_has_guarded_null_checkpoint :
  TPRUSLoadFuncallGuardedCheckpoint.
Proof.
  unfold TPRUSLoadFuncallGuardedCheckpoint.
  intros m t after result Hcall. inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [us_area.f_load_mario_area fn_vars] in Ha;
    inversion Ha; subst; try clear Ha end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?after |- _ =>
    change (Some before = Some after) in Hfree; inversion Hfree; subst end.
  do 3 eexists. split; [eassumption|].
  eapply tpr_actual_us_area_load_has_guarded_null_checkpoint.
  - apply PTree.gempty.
  - eassumption.
Qed.

Definition TeleporterPlatformResetExecutionBoundary : Prop :=
  TPRGuardedSpawnExecution /\ TPRRealSpawnCalleeExecution /\
  TPRClearFunctionNullStore /\ TPRReachedClearCallNullStore /\
  TPRUSSpawnBodyNullCheckpoint /\ TPRUSSpawnFuncallNullCheckpoint /\
  TPRUSGuardedLoadNullCheckpoint /\ TPRUSLoadFuncallGuardedCheckpoint /\
  tww_direct_call_count us_object_list_processor._clear_mario_platform
    (fn_body jp_object_list_processor.f_spawn_objects_from_info) = 0%nat.
Theorem teleporter_platform_reset_execution_boundary_checked :
  TeleporterPlatformResetExecutionBoundary.
Proof.
  split; [exact tpr_actual_area_load_has_guarded_spawn|].
  split; [exact tpr_reached_spawn_call_uses_real_body|].
  split; [exact tpr_actual_clear_function_stores_null|].
  split; [exact tpr_reached_clear_call_stores_null|].
  split; [exact tpr_actual_us_spawn_body_has_null_checkpoint|].
  split; [exact tpr_actual_us_spawn_function_has_null_checkpoint|].
  split; [exact tpr_actual_us_area_load_has_guarded_null_checkpoint|].
  split; [exact tpr_actual_us_load_function_has_guarded_null_checkpoint|].
  exact (proj2 (proj2 tpr_generated_us_clear_execution_cut)).
Qed.
