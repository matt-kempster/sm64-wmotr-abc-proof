(** Two real read-only initializer callbacks, with selected-callee resolution.
    The water query is a reached post-held-reset suffix event.  Its frame is
    discharged here for every memory cell, rather than assumed as a callback
    condition.  Other suffix stores and callbacks remain separate obligations. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_mario
  us_surface_collision jp_surface_collision us_save_file jp_save_file.
From LessThanOneAPress.Proofs Require Import GameTypes ASTFacts
  ObjectContactNecessity TeleporterDestinationReset TeleporterInitializerFrame
  ContactConsumerExecution UpperElevatorQueryResolution
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair
  SecretContactExecution InkSharedReadings.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.

Inductive THIReadOnlyCallee := THIFindWater | THIGetFlags.
Definition thi_ident callee := match callee with
  | THIFindWater => us_mario._find_water_level
  | THIGetFlags => us_mario._save_file_get_flags end.
Definition thi_body version callee := match version, callee with
  | VersionUS, THIFindWater => us_surface_collision.f_find_water_level
  | VersionJP, THIFindWater => jp_surface_collision.f_find_water_level
  | VersionUS, THIGetFlags => us_save_file.f_save_file_get_flags
  | VersionJP, THIGetFlags => jp_save_file.f_save_file_get_flags end.
Definition thi_unit callee := match callee with
  | THIFindWater => 31%nat | THIGetFlags => 11%nat end.
Definition thi_us_definitions callee := match callee with
  | THIFindWater => us_surface_collision.global_definitions
  | THIGetFlags => us_save_file.global_definitions end.

Lemma thi_us_source : forall callee,
  nth_error (thi_us_definitions callee)
    (ueqr_definition_index (thi_ident callee) (thi_us_definitions callee)) =
  Some (thi_ident callee, Gfun (Internal (thi_body VersionUS callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma thi_us_member : forall callee,
  In (thi_ident callee, Gfun (Internal (thi_body VersionUS callee)))
    (unit_global_definitions us_units).
Proof.
  intro callee.
  assert (prog_defs (us_nlist_at (thi_unit callee) us_units) =
    thi_us_definitions callee) as Hunit by (destruct callee; reflexivity).
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (thi_unit callee) us_units).
  - exact (us_nlist_at_nIn _ (thi_unit callee) us_units).
  - rewrite Hunit. eapply nth_error_In. exact (thi_us_source callee).
Qed.
Lemma thi_us_selection : forall callee,
  us_normalized_global_definition_map ! (thi_ident callee) =
    Some (Gfun (Internal (thi_body VersionUS callee))).
Proof.
  intro callee. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact (thi_us_member callee).
Qed.
Lemma thi_us_no_repair : forall callee,
  us_selected_definition_needs_viewport_repair
    (thi_ident callee, Gfun (Internal (thi_body VersionUS callee))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma thi_us_selected_member : forall callee,
  In (thi_ident callee, Gfun (Internal (thi_body VersionUS callee)))
    us_viewport_repaired_global_definitions.
Proof.
  intro callee. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition. rewrite thi_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact (thi_us_selection callee).
Qed.
Lemma thi_jp_source : forall callee,
  (prog_defmap (nlist_at (thi_unit callee) jp_cleaned_units)) !
    (thi_ident callee) = Some (Gfun (Internal (thi_body VersionJP callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Theorem thi_selected_callees_resolve : forall version callee, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (thi_ident callee) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (thi_body version callee)).
Proof.
  intros [] callee.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (thi_us_selected_member callee).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at (thi_unit callee) jp_cleaned_units)).
    + exact (nlist_at_nIn _ (thi_unit callee) jp_cleaned_units).
    + exact (thi_jp_source callee).
Qed.

Lemma thi_readonly_source : forall version callee,
  fn_vars (thi_body version callee) = [] /\
  cce_readonly_keep us_mario._m (fn_body (thi_body version callee)) = true.
Proof. intros [] []; split; reflexivity. Qed.

Theorem thi_complete_call_preserves_memory : forall version callee memory args
    trace after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) memory
    (Internal (thi_body version callee)) args trace after result ->
  trace = E0 /\ after = memory.
Proof.
  intros version callee memory args trace after result Hcall.
  destruct (thi_readonly_source version callee) as [Hvars Hshape].
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hbody : ClightBigstep.exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (cce_readonly_frame _ _ _ _ _ _ _ _ _ _ Hbody Hshape)
      as (-> & -> & _) end.
  match goal with Hfree : Mem.free_list ?before (blocks_of_env _ empty_env) = Some ?last |- _ =>
    change (Some before = Some last) in Hfree; inversion Hfree; subst end.
  split; reflexivity.
Qed.

(** This theorem uses the actual callee expression, function resolution,
    arguments and entry/return memories retained by TIF's event receipt. *)
Theorem thi_reached_readonly_event_preserves_memory : forall version callee
    e temps opt tyargs tyres actuals before after fd args trace result,
  e ! (thi_ident callee) = None ->
  tif_event_valid (Clight.globalenv (selected_clight_target version)) e
    (TIFCall temps opt
      (Evar (thi_ident callee) (Tfunction tyargs tyres cc_default)) actuals
      before after fd args trace result) ->
  trace = E0 /\ after = before.
Proof.
  intros version callee e temps opt tyargs tyres actuals before after fd args
    trace result Hlocal Hvalid.
  cbn [tif_event_valid] in Hvalid.
  destruct Hvalid as (tys & ret & cc & vf & Hclass & Hexpr & Hargs & Hfind & Htype & Hcall).
  destruct (thi_selected_callees_resolve version callee) as (fb & Hsymbol & Hfunction).
  assert (forall vf, eval_expr (Clight.globalenv (selected_clight_target version))
    e temps before (Evar (thi_ident callee) (Tfunction tyargs tyres cc_default)) vf ->
    vf = Vptr fb Ptrofs.zero) as Hvalue.
  { intros. eapply sce_function_name_value; eauto. }
  apply Hvalue in Hexpr. subst.
  change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
    fb = Some fd) in Hfind.
  rewrite Hfunction in Hfind. inversion Hfind; subst fd.
  eapply thi_complete_call_preserves_memory; eauto.
Qed.

Definition THIReadOnlyInitializerEventFrame : Prop :=
  forall version callee e temps opt tyargs tyres actuals before after fd args trace result cell,
  e ! (thi_ident callee) = None ->
  tif_event_valid (Clight.globalenv (selected_clight_target version)) e
    (TIFCall temps opt
      (Evar (thi_ident callee) (Tfunction tyargs tyres cc_default)) actuals
      before after fd args trace result) ->
  tif_event_guard cell (TIFCall temps opt
    (Evar (thi_ident callee) (Tfunction tyargs tyres cc_default)) actuals
    before after fd args trace result).

Theorem thi_readonly_initializer_event_frame : THIReadOnlyInitializerEventFrame.
Proof.
  intros version callee e temps opt tyargs tyres actuals before after fd args
    trace result cell Hlocal Hvalid.
  destruct (thi_reached_readonly_event_preserves_memory version callee e temps opt
    tyargs tyres actuals before after fd args trace result Hlocal Hvalid) as [_ ->].
  reflexivity.
Qed.

(** Known read-only calls need no protected-cell frame premise. The fallback
    constructor retains the exact old guard for every other reached effect. *)
Inductive THIReducedEventGuard (cell : InkReadCell) : TIFMemoryEvent -> Prop :=
| thi_reduced_readonly_call : forall callee temps opt tyargs tyres actuals
    before after fd args trace result,
    THIReducedEventGuard cell (TIFCall temps opt
      (Evar (thi_ident callee) (Tfunction tyargs tyres cc_default)) actuals
      before after fd args trace result)
| thi_reduced_other_effect : forall event,
    tif_event_guard cell event -> THIReducedEventGuard cell event.

Lemma thi_reduced_event_supplies_guard : forall version e cell event,
  (forall callee, e ! (thi_ident callee) = None) ->
  tif_event_valid (Clight.globalenv (selected_clight_target version)) e event ->
  THIReducedEventGuard cell event -> tif_event_guard cell event.
Proof.
  intros version e cell event Hlocal Hvalid Hguard.
  inversion Hguard; subst.
  - eapply thi_readonly_initializer_event_frame; eauto.
  - assumption.
Qed.

Lemma thi_reduced_guards_supply_guards : forall version e cell events,
  (forall callee, e ! (thi_ident callee) = None) ->
  Forall (tif_event_valid (Clight.globalenv (selected_clight_target version)) e) events ->
  Forall (THIReducedEventGuard cell) events ->
  Forall (tif_event_guard cell) events.
Proof.
  intros version e cell events Hlocal Hvalid Hguard.
  rewrite Forall_forall in Hvalid, Hguard |- *.
  intros event Hin. eapply (thi_reduced_event_supplies_guard version e cell event).
  - exact Hlocal.
  - apply Hvalid. exact Hin.
  - apply Hguard. exact Hin.
Qed.

(** The frame reduction is consumed by the actual complete initializer
    suffix, with precisely the real event receipts exposed by TIF. *)
Definition THIActualInitializerSuffixReducedFrame : Prop :=
  forall version e le before trace last after out,
  (forall callee, e ! (thi_ident callee) = None) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tdr_init_after_held version) trace last after out ->
  exists events,
    TIFMemoryChain before events after /\
    Forall (tif_event_valid
      (Clight.globalenv (selected_clight_target version)) e) events /\
    Forall (fun event => In (tif_event_node event)
      (tif_leaves (tdr_init_after_held version))) events /\
    (forall cell, Forall (THIReducedEventGuard cell) events ->
      ink_read after cell = ink_read before cell).

Theorem thi_actual_initializer_suffix_reduced_frame :
  THIActualInitializerSuffixReducedFrame.
Proof.
  intros version e le before trace last after out Hlocal Hrun.
  destruct (tif_actual_initializer_suffix_frame version e le before trace last
    after out Hrun) as (events & Hchain & Hvalid & Hnodes & Hframe).
  exists events. split; [exact Hchain|]. split; [exact Hvalid|].
  split; [exact Hnodes|]. intros cell Hguard.
  apply Hframe. eapply (thi_reduced_guards_supply_guards version e cell events); eauto.
Qed.

Definition TeleporterHeldInitializerBoundary : Prop :=
  THIActualInitializerSuffixReducedFrame /\
  THIReadOnlyInitializerEventFrame /\
  (forall version callee memory args trace after result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) memory
      (Internal (thi_body version callee)) args trace after result ->
    trace = E0 /\ after = memory).

Theorem teleporter_held_initializer_boundary_checked : TeleporterHeldInitializerBoundary.
Proof.
  split; [exact thi_actual_initializer_suffix_reduced_frame|].
  split; [exact thi_readonly_initializer_event_frame|].
  exact thi_complete_call_preserves_memory.
Qed.
