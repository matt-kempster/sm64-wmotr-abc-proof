(** Area ownership, rather than Mario's heldObj, controls the object-unload
    selection.  The semantic statements below concern a reached matching
    scan node and a reached real unload call.  They do not supply the entire
    area's list invariant, a reachable wrong-warp history, or a frame theorem
    for every callback after the deactivation checkpoint. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_object_list_processor
  jp_object_list_processor us_spawn_object jp_spawn_object us_area jp_area
  us_ssl_script jp_ssl_script us_ssl_area2_macro jp_ssl_area2_macro
  us_level_update jp_level_update.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  ObjectContactNecessity ObjectContactReadback InkBackwardExecution
  InkCopyCaller TeleporterWarpClassification Area1AllocationSource
  Area1EntryDepthClosure EyerokRank15LiveMovement SecretContactExecution SelectedClightTarget
  UpperElevatorQueryResolution CleanedClightPrograms ClightLinkExecution
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TOL := us_spawn_object.

Definition tol_scan_function version := match version with
| VersionUS => us_object_list_processor.f_unload_objects_from_area
| VersionJP => jp_object_list_processor.f_unload_objects_from_area end.
Definition tol_unload_function version := match version with
| VersionUS => us_spawn_object.f_unload_object
| VersionJP => jp_spawn_object.f_unload_object end.
Definition tol_scan_iteration version := match fn_body (tol_scan_function version) with
| Ssequence _ (Ssequence _
    (Sloop (Ssequence _ (Ssequence _
      (Ssequence _ (Sloop (Ssequence _ body) _)))) _)) => body
| _ => Sskip end.
Definition tol_match_choice version := match tol_scan_iteration version with
| Ssequence _ (Ssequence _ choice) => choice | _ => Sskip end.
Definition tol_object := Ederef
  (Etempvar TOL._obj (tptr (Tstruct TOL._Object noattr)))
  (Tstruct TOL._Object noattr).
Definition tol_header := Efield tol_object TOL._header (Tstruct TOL._ObjectNode noattr).
Definition tol_graphics := Efield tol_header TOL._gfx (Tstruct TOL._GraphNodeObject noattr).
Definition tol_area_read := Efield tol_graphics TOL._activeAreaIndex tschar.
Definition tol_area_guard := Ebinop Oeq
  (Etempvar us_object_list_processor._t'1 tschar)
  (Etempvar us_object_list_processor._areaIndex tint) tint.
Definition tol_unload_call := Scall None
  (Evar TOL._unload_object
    (Tfunction [tptr (Tstruct TOL._Object noattr)] tvoid cc_default))
  [Etempvar TOL._obj (tptr (Tstruct TOL._Object noattr))].
Definition tol_deactivate := Sassign
  (Efield tol_object TOL._activeFlags tshort) (Econst_int Int.zero tint).
Definition tol_unload_tail version := match fn_body (tol_unload_function version) with
| Ssequence _ tail => tail | _ => Sskip end.

Theorem tol_generated_unload_cuts_exact : forall version,
  tol_match_choice version =
    Ssequence (Sset us_object_list_processor._t'1 tol_area_read)
      (Sifthenelse tol_area_guard tol_unload_call Sskip) /\
  fn_body (tol_unload_function version) =
    Ssequence tol_deactivate (tol_unload_tail version) /\
  fn_vars (tol_unload_function version) = [] /\
  fn_params (tol_unload_function version) =
    [(TOL._obj, tptr (Tstruct TOL._Object noattr))].
Proof. intros []; repeat split; reflexivity. Qed.

(** These are exact finite source facts.  The scan's entire generated body
    neither mentions heldObj nor accesses the rawData union containing the
    object's held-state word.  A held object has no exemption in this test. *)
Definition TOLAreaUnloadSource : Prop := forall version,
  statement_mentions_ident_s us_object_list_processor._heldObj
    (fn_body (tol_scan_function version)) = false /\
  statement_mentions_ident_s us_object_list_processor._rawData
    (fn_body (tol_scan_function version)) = false /\
  calls_ident_s TOL._unload_object (fn_body (tol_scan_function version)) = true /\
  calls_ident_s us_area._unload_objects_from_area
    (fn_body (match version with
      | VersionUS => us_area.f_unload_area | VersionJP => jp_area.f_unload_area end)) = true /\
  calls_ident_s us_area._unload_area
    (fn_body (match version with
      | VersionUS => us_area.f_change_area | VersionJP => jp_area.f_change_area end)) = true /\
  calls_ident_s us_area._unload_mario_area
    (fn_body (match version with
      | VersionUS => us_level_update.f_warp_area
      | VersionJP => jp_level_update.f_warp_area end)) = true /\
  calls_ident_s us_area._unload_objects_from_area
    (fn_body (match version with
      | VersionUS => us_area.f_unload_mario_area
      | VersionJP => jp_area.f_unload_mario_area end)) = true /\
  calls_ident_s us_area._unload_area
    (fn_body (match version with
      | VersionUS => us_area.f_unload_mario_area
      | VersionJP => jp_area.f_unload_mario_area end)) = true /\
  calls_ident_s TOL._deallocate_object
    (fn_body (tol_unload_function version)) = true.
Theorem tol_area_unload_source_checked : TOLAreaUnloadSource.
Proof. intros []; repeat split; reflexivity. Qed.

(** Packed retail records, with no claim that this finite receipt executes
    the level-script interpreter. The normal lower source node is 0x14 and
    its destination is SSL (level 8), Area 2, node 0x0A, with checkpoint bit. *)
Definition TOLLowerEntranceData : Prop :=
  firstn 2 (skipn 82 (gvar_init us_ssl_script.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 638063624); Init_int32 (Int.repr 34242560)] /\
  firstn 2 (skipn 82 (gvar_init jp_ssl_script.v_level_ssl_entry)) =
    [Init_int32 (Int.repr 638063624); Init_int32 (Int.repr 34242560)] /\
  638063624 = 38 * 16777216 + 8 * 65536 + 20 * 256 + 8 /\
  34242560 = 2 * 16777216 + 10 * 65536 + 128 * 256 /\
  us_area1_macro_mentions_behavior us_macro_special_objects._bhvBobomb = true /\
  jp_area1_macro_mentions_behavior jp_macro_special_objects._bhvBobomb = true /\
  macro_list_mentions_behavior us_macro_special_objects._bhvBobomb
    (gvar_init us_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs)
    (gvar_init us_macro_special_objects.v_sMacroObjectPresets) = false /\
  macro_list_mentions_behavior jp_macro_special_objects._bhvBobomb
    (gvar_init jp_ssl_area2_macro.v_ssl_seg7_area_2_macro_objs)
    (gvar_init jp_macro_special_objects.v_sMacroObjectPresets) = false.
Theorem tol_lower_entrance_data_checked : TOLLowerEntranceData.
Proof. vm_compute; repeat split; reflexivity. Qed.

Lemma tol_selected_layout : forall version,
  let ge := Clight.globalenv (selected_clight_target version) in
  ibcc_field_ok ge TOL._Object TOL._header 0 = true /\
  ibcc_field_ok ge TOL._ObjectNode TOL._gfx 0 = true /\
  ibcc_field_ok ge TOL._GraphNodeObject TOL._activeAreaIndex 25 = true /\
  ibcc_field_ok ge TOL._Object TOL._activeFlags 116 = true.
Proof.
  intro version. cbn zeta.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
      TOL._Object TOL._header 0 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version))
      TOL._ObjectNode TOL._gfx 0 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version))
      TOL._GraphNodeObject TOL._activeAreaIndex 25 = true /\
    ibcc_field_ok (prog_comp_env (selected_clight_target version))
      TOL._Object TOL._activeFlags 116 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; repeat split; reflexivity.
Qed.

Lemma tol_us_unload_source :
  nth_error us_spawn_object.global_definitions
    (ueqr_definition_index TOL._unload_object us_spawn_object.global_definitions) =
  Some (TOL._unload_object, Gfun (Internal (tol_unload_function VersionUS))).
Proof. vm_compute; reflexivity. Qed.
Lemma tol_us_unload_member :
  In (TOL._unload_object, Gfun (Internal (tol_unload_function VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union with (unit := us_nlist_at 18 us_units).
  - exact (us_nlist_at_nIn _ 18 us_units).
  - change (In (TOL._unload_object, Gfun (Internal (tol_unload_function VersionUS)))
      us_spawn_object.global_definitions).
    eapply nth_error_In. exact tol_us_unload_source.
Qed.
Lemma tol_us_unload_selection :
  us_normalized_global_definition_map ! TOL._unload_object =
    Some (Gfun (Internal (tol_unload_function VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact tol_us_unload_member.
Qed.
Lemma tol_us_unload_selected_member :
  In (TOL._unload_object, Gfun (Internal (tol_unload_function VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions. apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    assert (us_selected_definition_needs_viewport_repair
      (TOL._unload_object, Gfun (Internal (tol_unload_function VersionUS))) = false)
      as Hrepair by (vm_compute; reflexivity).
    rewrite Hrepair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact tol_us_unload_selection.
Qed.
Theorem tol_selected_unload_resolves : forall version, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    TOL._unload_object = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tol_unload_function version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact tol_us_unload_selected_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link (nlist_at 18 jp_cleaned_units)).
    + exact (nlist_at_nIn _ 18 jp_cleaned_units).
    + vm_compute; reflexivity.
Qed.

Lemma tol_actual_area_read_value : forall version e le before ob oo index answer,
  le ! TOL._obj = Some (Vptr ob oo) ->
  Mem.load Mint8signed before ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 25))) = Some index ->
  eval_expr (Clight.globalenv (selected_clight_target version))
    e le before tol_area_read answer -> answer = index.
Proof.
  intros version e le before ob oo index answer Hobj Hload Hread.
  destruct (tol_selected_layout version) as (Hheader & Hgfx & Harea & _).
  assert (forall v, eval_expr (Clight.globalenv (selected_clight_target version))
    e le before tol_object v -> v = Vptr ob oo) as Hobject.
  { intros; eapply ibcc_deref_struct; eauto. }
  assert (forall v, eval_expr (Clight.globalenv (selected_clight_target version))
    e le before tol_header v -> v = Vptr ob oo) as Hhead.
  { intros v Hr. unfold tol_header in Hr.
    pose proof (ibcc_aggregate_field _ _ _ _ tol_object TOL._Object TOL._header
      (Tstruct TOL._ObjectNode noattr) ob oo 0 v eq_refl Hobject Hheader
      (or_intror eq_refl) Hr) as E. now rewrite Ptrofs.add_zero in E. }
  assert (forall v, eval_expr (Clight.globalenv (selected_clight_target version))
    e le before tol_graphics v -> v = Vptr ob oo) as Hgraphics.
  { intros v Hr. unfold tol_graphics in Hr.
    pose proof (ibcc_aggregate_field _ _ _ _ tol_header TOL._ObjectNode TOL._gfx
      (Tstruct TOL._GraphNodeObject noattr) ob oo 0 v eq_refl Hhead Hgfx
      (or_intror eq_refl) Hr) as E. now rewrite Ptrofs.add_zero in E. }
  unfold tol_area_read in Hread. inversion Hread; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _ tol_graphics TOL._GraphNodeObject
      TOL._activeAreaIndex tschar ob oo 25 _ _ _ eq_refl Hgraphics Harea Hl)
      as (-> & -> & ->) end.
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inversion Hd; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hr : Mem.loadv _ _ _ = Some _ |- _ =>
    change (Mem.load Mint8signed before ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 25))) = Some answer) in Hr;
    congruence end.
Qed.

(** A reached Area-1-owned node MUST take the unload arm when Area 1 is being
    unloaded. No condition on Mario's pointer or this object's held state is
    assumed. This stops at the actual call; the whole list traversal is not
    replaced by this one-node result. *)
Definition TOLMatchingAreaForcesUnload : Prop := forall version e le before
    ob oo trace last after out,
  le ! TOL._obj = Some (Vptr ob oo) ->
  le ! us_object_list_processor._areaIndex = Some (Vint Int.one) ->
  Mem.load Mint8signed before ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 25))) = Some (Vint Int.one) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_match_choice version) trace last after out ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e
    (PTree.set us_object_list_processor._t'1 (Vint Int.one) le) before
    tol_unload_call trace last after out.
Theorem tol_matching_area_forces_unload : TOLMatchingAreaForcesUnload.
Proof.
  intros version e le before ob oo trace last after out Hobj Hindex Hload Hrun.
  rewrite (proj1 (tol_generated_unload_cuts_exact version)) in Hrun.
  destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hrun)
    as (index & Hread & Hrest).
  pose proof (tol_actual_area_read_value _ _ _ _ _ _ _ _ Hobj Hload Hread) as E.
  subst index.
  assert (eval_expr (Clight.globalenv (selected_clight_target version)) e
    (PTree.set us_object_list_processor._t'1 (Vint Int.one) le) before
    tol_area_guard (Vint Int.one)) as Hguard.
  { unfold tol_area_guard. eapply eval_Ebinop.
    - apply eval_Etempvar. apply PTree.gss.
    - apply eval_Etempvar. rewrite PTree.gso by discriminate. exact Hindex.
    - reflexivity. }
  inversion Hrest; subst.
  match goal with Hv : eval_expr _ _ _ _ tol_area_guard ?v |- _ =>
    assert (v = Vint Int.one) by (eapply ocr_expr_unique; eauto); subst v end.
  match goal with Hb : bool_val (Vint Int.one) _ _ = Some ?b |- _ =>
    change (Some true = Some b) in Hb; inversion Hb; subst b end.
  assumption.
Qed.

(** The first real unload store is computed with the selected Object layout.
    This is a deactivation checkpoint, not a whole-warp lifetime theorem. *)
Definition TOLActualDeactivationStore : Prop := forall version e le before ob oo
    trace last after out,
  le ! TOL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tol_deactivate trace last after out ->
  trace = E0 /\ last = le /\ out = Out_normal /\
  Mem.store Mint16signed before ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) (Vint Int.zero) = Some after /\
  Mem.load Mint16signed after ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) = Some (Vint Int.zero).
Theorem tol_actual_unload_deactivates : TOLActualDeactivationStore.
Proof.
  intros version e le before ob oo trace last after out Hobj Hrun.
  unfold tol_deactivate in Hrun. inversion Hrun; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _ tol_object TOL._Object
      TOL._activeFlags tshort ob oo 116 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Hobj|eassumption])
      (proj2 (proj2 (proj2 (tol_selected_layout version)))) Hl)
      as (-> & -> & ->) end.
  match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
    apply ocn_const_int_value in Hr; subst end.
  match goal with Hcast : sem_cast _ _ _ _ = Some ?v |- _ =>
    change (Some (Vint Int.zero) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hstore : Mem.storev _ _ _ _ = Some after |- _ =>
    change (Mem.store Mint16signed before ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116)))
      (Vint Int.zero) = Some after) in Hstore;
    repeat split; try assumption; try reflexivity;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore); reflexivity end.
Qed.

Definition TOLActualUnloadCheckpoint : Prop := forall version e le before ob oo
    trace last after out,
  le ! TOL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (fn_body (tol_unload_function version)) trace last after out ->
  exists deactivated tail_trace,
    trace = tail_trace /\
    Mem.store Mint16signed before ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) (Vint Int.zero) =
        Some deactivated /\
    Mem.load Mint16signed deactivated ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) = Some (Vint Int.zero) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e le deactivated
      (tol_unload_tail version) tail_trace last after out.
Theorem tol_completed_unload_reaches_deactivation : TOLActualUnloadCheckpoint.
Proof.
  intros version e le before ob oo trace last after out Hobj Hrun.
  destruct (tol_generated_unload_cuts_exact version) as (_ & Hbody & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ tol_deactivate _ _ _ _ _ eq_refl Hrun)
    as (middle & deactivated & pre & tail & Htrace & Hfirst & Htail).
  destruct (tol_actual_unload_deactivates _ _ _ _ _ _ _ _ _ _ Hobj Hfirst)
    as (-> & -> & _ & Hstore & Hload).
  exists deactivated, tail. repeat split; assumption.
Qed.

Lemma tol_reached_call_uses_real_unload : forall version e le before ob oo
    trace last after out,
  e ! TOL._unload_object = None ->
  le ! TOL._obj = Some (Vptr ob oo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tol_unload_call trace last after out ->
  exists result, ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tol_unload_function version)) [Vptr ob oo] trace after result.
Proof.
  intros version e le before ob oo trace last after out Hlocal Hobj Hrun.
  destruct (tol_selected_unload_resolves version) as (b & Hsymbol & Hfunction).
  inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b = Some fd)
      in Hfind; rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hty : type_of_fundef _ = _ |- _ =>
    assert (type_of_fundef (Internal (tol_unload_function version)) =
      Tfunction [tptr (Tstruct TOL._Object noattr)] tvoid cc_default) as Ety
      by (destruct version; reflexivity);
    rewrite Ety in Hty; inversion Hty; subst end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar TOL._obj _) ?v |- _ =>
    assert (v = Vptr ob oo) by (eapply ocn_temp_value; eauto); subst v end.
  match goal with Hcast : sem_cast (Vptr ob oo) _ _ _ = Some ?v |- _ =>
    change (Some (Vptr ob oo) = Some v) in Hcast; inversion Hcast; subst v end.
  eauto.
Qed.

Lemma tol_unload_call_entry : forall version before ob oo trace after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tol_unload_function version)) [Vptr ob oo] trace after result ->
  exists le last out,
    le ! TOL._obj = Some (Vptr ob oo) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env le before
      (fn_body (tol_unload_function version)) trace last after out.
Proof.
  intros version before ob oo trace after result Hcall.
  destruct (tol_generated_unload_cuts_exact version) as (_ & _ & Hvars & Hparams).
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hfree : Mem.free_list ?m (blocks_of_env _ empty_env) = Some ?m' |- _ =>
    change (Some m = Some m') in Hfree; inversion Hfree; subst end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?temps |- _ =>
    rewrite Hparams in Hb; cbn [bind_parameter_temps] in Hb; inversion Hb; subst temps end.
  match goal with Hr : ClightBigstep.exec_stmt _ _ _ ?temps _ _ _ ?last _ ?out |- _ =>
    exists temps, last, out end.
  split; [apply PTree.gss|eassumption].
Qed.

Definition TOLActualMatchedAreaCheckpoint : Prop := forall version e le before ob oo
    trace last after out,
  e ! TOL._unload_object = None ->
  le ! TOL._obj = Some (Vptr ob oo) ->
  le ! us_object_list_processor._areaIndex = Some (Vint Int.one) ->
  Mem.load Mint8signed before ob
    (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 25))) = Some (Vint Int.one) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tol_match_choice version) trace last after out ->
  exists deactivated,
    Mem.store Mint16signed before ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) (Vint Int.zero) =
        Some deactivated /\
    Mem.load Mint16signed deactivated ob
      (Ptrofs.unsigned (Ptrofs.add oo (Ptrofs.repr 116))) = Some (Vint Int.zero).
Theorem tol_matched_area_reaches_real_deactivation : TOLActualMatchedAreaCheckpoint.
Proof.
  intros version e le before ob oo trace last after out Hlocal Hobj Hindex Hload Hrun.
  pose proof (tol_matching_area_forces_unload _ _ _ _ _ _ _ _ _ _
    Hobj Hindex Hload Hrun) as Hcall.
  destruct (tol_reached_call_uses_real_unload version e
    (PTree.set us_object_list_processor._t'1 (Vint Int.one) le)
    before ob oo trace last after out Hlocal
    ltac:(rewrite PTree.gso by discriminate; exact Hobj) Hcall) as (result & Hreal).
  destruct (tol_unload_call_entry _ _ _ _ _ _ _ Hreal)
    as (entry & final & outcome & Hentry & Hbody).
  destruct (tol_completed_unload_reaches_deactivation _ _ _ _ _ _ _ _ _ _ Hentry Hbody)
    as (deactivated & tail & _ & Hstore & Hzero & _).
  exists deactivated. auto.
Qed.

Definition TeleporterObjectLifetimeBoundary : Prop :=
  TOLAreaUnloadSource /\ TOLLowerEntranceData /\ TOLMatchingAreaForcesUnload /\
  TOLActualDeactivationStore /\ TOLActualUnloadCheckpoint /\ TOLActualMatchedAreaCheckpoint.
Theorem teleporter_object_lifetime_boundary_checked : TeleporterObjectLifetimeBoundary.
Proof.
  split; [exact tol_area_unload_source_checked|].
  split; [exact tol_lower_entrance_data_checked|].
  split; [exact tol_matching_area_forces_unload|].
  split; [exact tol_actual_unload_deactivates|].
  split; [exact tol_completed_unload_reaches_deactivation|].
  exact tol_matched_area_reaches_real_deactivation.
Qed.
