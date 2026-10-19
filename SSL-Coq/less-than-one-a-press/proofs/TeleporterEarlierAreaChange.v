(** The earlier area change matters even when the last warp is same-area.
    These are chronological cuts of the actual generated area functions.
    They establish unload-before-load, not a global object-list invariant or
    an assertion that a freed allocation can never be reused. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_area jp_area.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  ObjectContactReadback InkBackwardExecution InkCopyCaller SelectedClightTarget
  TeleporterDestinationReset TeleporterWarpClassification TeleporterObjectLifetime
  UpperElevatorQueryResolution CleanedClightPrograms ClightLinkExecution
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair
  SecretContactExecution.
Import ListNotations.
Local Open Scope Z_scope.
Local Opaque normalize_global_definition_map.
Module TEA := us_area.

Definition tea_change_function version := match version with
| VersionUS => us_area.f_change_area | VersionJP => jp_area.f_change_area end.
Definition tea_unload_function version := match version with
| VersionUS => us_area.f_unload_area | VersionJP => jp_area.f_unload_area end.
Definition tea_change_setup version := match fn_body (tea_change_function version) with
| Ssequence setup _ => setup | _ => Sskip end.
Definition tea_change_after version := match fn_body (tea_change_function version) with
| Ssequence _ (Ssequence _ after) => after | _ => Sskip end.
Definition tea_changed_branch version := match fn_body (tea_change_function version) with
| Ssequence _ (Ssequence (Ssequence _ (Sifthenelse _ branch _)) _) => branch
| _ => Sskip end.
Definition tea_after_load version := match tea_changed_branch version with
| Ssequence _ (Ssequence _ after) => after | _ => Sskip end.
Definition tea_unload_call := Scall None
  (Evar TEA._unload_area (Tfunction [] tvoid cc_default)) [].
Definition tea_load_call := Scall None
  (Evar TEA._load_area (Tfunction [tint] tvoid cc_default))
  [Etempvar TEA._index tint].
Definition tea_cached_index := Evar TEA._gCurrAreaIndex tshort.
Definition tea_change_guard := Ebinop One (Etempvar TEA._t'3 tshort)
  (Etempvar TEA._index tint) tint.
Definition tea_current_read := Evar TEA._gCurrentArea
  (tptr (Tstruct TEA._Area noattr)).
Definition tea_unload_guard := Ebinop One
  (Etempvar TEA._t'1 (tptr (Tstruct TEA._Area noattr)))
  (Ecast (Econst_int Int.zero tint) (tptr tvoid)) tint.
Definition tea_scan_prefix version := match fn_body (tea_unload_function version) with
| Ssequence _ (Sifthenelse _ (Ssequence scan _) _) => scan | _ => Sskip end.
Definition tea_after_scan version := match fn_body (tea_unload_function version) with
| Ssequence _ (Sifthenelse _ (Ssequence _ after) _) => after | _ => Sskip end.
Definition tea_scan_index := Efield
  (Ederef (Etempvar TEA._t'5 (tptr (Tstruct TEA._Area noattr)))
    (Tstruct TEA._Area noattr)) TEA._index tschar.
Definition tea_scan_call := Scall None
  (Evar TEA._unload_objects_from_area (Tfunction [tint;tint] tvoid cc_default))
  [Econst_int Int.zero tint; Etempvar TEA._t'6 tschar].

Theorem tea_generated_cuts_exact : forall version,
  fn_body (tea_change_function version) =
    Ssequence (tea_change_setup version)
      (Ssequence (Ssequence (Sset TEA._t'3 tea_cached_index)
        (Sifthenelse tea_change_guard (tea_changed_branch version) Sskip))
        (tea_change_after version)) /\
  tea_changed_branch version = Ssequence tea_unload_call
    (Ssequence tea_load_call (tea_after_load version)) /\
  fn_body (tea_unload_function version) =
    Ssequence (Sset TEA._t'1 tea_current_read)
      (Sifthenelse tea_unload_guard
        (Ssequence (tea_scan_prefix version) (tea_after_scan version)) Sskip) /\
  tea_scan_prefix version = Ssequence (Sset TEA._t'5 tea_current_read)
    (Ssequence (Sset TEA._t'6 tea_scan_index) tea_scan_call) /\
  ibk_normal (tea_change_setup version) = true /\
  ibk_normal (tea_changed_branch version) = true /\
  ibk_normal (tea_scan_prefix version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** The changed and unchanged alternatives are retained. In particular,
    calling change_area does not by itself prove that its unload ran. *)
Definition TEAChangeAreaChronology : Prop := forall version ge e le before
    tr last after out,
  ocn_exec ge e le before (fn_body (tea_change_function version))
    tr last after out ->
  exists setup_le setup_mem setup_trace current chosen branch_trace branch_le branch_mem suffix,
    tr = setup_trace ++ (branch_trace ++ suffix) /\
    ocn_exec ge e le before (tea_change_setup version)
      setup_trace setup_le setup_mem Out_normal /\
    eval_expr ge e setup_le setup_mem tea_cached_index current /\
    ocn_test_value ge e (PTree.set TEA._t'3 current setup_le)
      setup_mem tea_change_guard chosen /\
    ocn_exec ge e (PTree.set TEA._t'3 current setup_le) setup_mem
      (if chosen then tea_changed_branch version else Sskip)
      branch_trace branch_le branch_mem Out_normal /\
    ocn_exec ge e branch_le branch_mem (tea_change_after version)
      suffix last after out.
Theorem tea_actual_change_area_chronology : TEAChangeAreaChronology.
Proof.
  intros version ge e le before tr last after out Hrun.
  destruct (tea_generated_cuts_exact version)
    as (Hbody & _ & _ & _ & Hsetup & Hbranch & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hsetup Hrun)
    as (sl & sm & st & rest & Htrace & Hpre & Hrest).
  assert (ibk_normal (Ssequence (Sset TEA._t'3 tea_cached_index)
    (Sifthenelse tea_change_guard (tea_changed_branch version) Sskip)) = true)
    as Hnormal by (cbn; rewrite Hbranch; reflexivity).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrest)
    as (bl & bm & bt & suffix & Hresttrace & Hchoice & Hsuffix).
  destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hchoice)
    as (current & Hread & Hif).
  inversion Hif; subst.
  exists sl, sm, st, current, b, bt, bl, bm, suffix.
  repeat split; try assumption; try congruence.
  unfold ocn_test_value; eauto.
Qed.

Definition TEAChangedBranchUnloadBeforeLoad : Prop := forall version ge e le before
    tr last after out,
  ocn_exec ge e le before (tea_changed_branch version) tr last after out ->
  exists unload_le unloaded unload_trace load_le loaded load_trace rest,
    tr = unload_trace ++ (load_trace ++ rest) /\
    ocn_exec ge e le before tea_unload_call
      unload_trace unload_le unloaded Out_normal /\
    ocn_exec ge e unload_le unloaded tea_load_call
      load_trace load_le loaded Out_normal /\
    ocn_exec ge e load_le loaded (tea_after_load version) rest last after out.
Theorem tea_changed_branch_unloads_before_loading : TEAChangedBranchUnloadBeforeLoad.
Proof.
  intros version ge e le before tr last after out Hrun.
  rewrite (proj1 (proj2 (tea_generated_cuts_exact version))) in Hrun.
  destruct (ibk_split_sequence _ _ _ _ tea_unload_call _ _ _ _ _ eq_refl Hrun)
    as (ul & um & ut & tail & Htrace & Hu & Htail).
  destruct (ibk_split_sequence _ _ _ _ tea_load_call _ _ _ _ _ eq_refl Htail)
    as (ll & lm & lt & rest & Htailtrace & Hl & Hr).
  exists ul, um, ut, ll, lm, lt, rest. repeat split; try assumption; congruence.
Qed.

(** No game callback precedes the scan in unload_area. The index argument
    is read from the current area in its entry memory, before that area is
    cleared and before the later graph callback. *)
Definition TEAUnloadAreaChronology : Prop := forall version ge e le before
    tr last after out,
  ocn_exec ge e le before (fn_body (tea_unload_function version))
    tr last after out ->
  exists current,
    eval_expr ge e le before tea_current_read current /\
    ((ocn_test_value ge e (PTree.set TEA._t'1 current le) before
        tea_unload_guard false /\ after = before) \/
     (ocn_test_value ge e (PTree.set TEA._t'1 current le) before
        tea_unload_guard true /\
      exists current_again index scanned_le scanned_mem scan_trace suffix,
        eval_expr ge e (PTree.set TEA._t'1 current le) before
          tea_current_read current_again /\
        eval_expr ge e (PTree.set TEA._t'5 current_again
          (PTree.set TEA._t'1 current le)) before tea_scan_index index /\
        tr = scan_trace ++ suffix /\
        ocn_exec ge e (PTree.set TEA._t'6 index
          (PTree.set TEA._t'5 current_again (PTree.set TEA._t'1 current le)))
          before tea_scan_call scan_trace scanned_le scanned_mem Out_normal /\
        ocn_exec ge e scanned_le scanned_mem (tea_after_scan version)
          suffix last after out)).
Theorem tea_actual_unload_area_chronology : TEAUnloadAreaChronology.
Proof.
  intros version ge e le before tr last after out Hrun.
  destruct (tea_generated_cuts_exact version)
    as (_ & _ & Hbody & Hprefix & _ & _ & Hnormal).
  rewrite Hbody in Hrun.
  destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hrun)
    as (current & Hread & Hchoice).
  exists current. split; [exact Hread|].
  inversion Hchoice; subst. destruct b.
  - right. split; [unfold ocn_test_value; eauto|].
    match goal with Hbranch : ClightBigstep.exec_stmt _ _ _ _ _
      (Ssequence (tea_scan_prefix _) _) _ _ _ _ |- _ =>
      destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hbranch)
        as (cl & cm & ct & suffix & Htrace & Hscan & Htail) end.
    rewrite Hprefix in Hscan.
    destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hscan)
      as (area & Harea & Hindexrun).
    destruct (twc_read_prefix_exec _ _ _ _ _ _ _ _ _ _ _ Hindexrun)
      as (index & Hindex & Hcall).
    exists area, index, cl, cm, ct, suffix. repeat split; assumption.
  - left. split; [unfold ocn_test_value; eauto|].
    match goal with Hskip : ClightBigstep.exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ =>
      inversion Hskip; reflexivity end.
Qed.

Definition TEACompleteUnloadCallChronology : Prop := forall version before
    tr after result,
  ClightBigstep.Clight2.eval_funcall
    (Clight.globalenv (selected_clight_target version)) before
    (Internal (tea_unload_function version)) [] tr after result ->
  exists entry last out,
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      entry before (fn_body (tea_unload_function version)) tr last after out.
Theorem tea_complete_unload_call_has_body : TEACompleteUnloadCallChronology.
Proof.
  intros version before tr after result Hcall.
  assert (fn_vars (tea_unload_function version) = []) as Hvars
    by (destruct version; reflexivity).
  inversion Hcall; subst.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
    inversion He; subst; clear He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    rewrite Hvars in Ha; inversion Ha; subst; clear Ha end.
  match goal with Hfree : Mem.free_list ?m (blocks_of_env _ empty_env) = Some ?m' |- _ =>
    change (Some m = Some m') in Hfree; inversion Hfree; subst end.
  eauto.
Qed.

Inductive TEACallee := TEAUnload | TEAScan.
Definition tea_ident callee := match callee with
| TEAUnload => TEA._unload_area | TEAScan => TEA._unload_objects_from_area end.
Definition tea_function version callee := match callee with
| TEAUnload => tea_unload_function version | TEAScan => tol_scan_function version end.
Definition tea_unit callee := match callee with
| TEAUnload => 27%nat | TEAScan => 13%nat end.
Definition tea_us_definitions callee := match callee with
| TEAUnload => us_area.global_definitions
| TEAScan => us_object_list_processor.global_definitions end.
Lemma tea_us_source : forall callee,
  nth_error (tea_us_definitions callee)
    (ueqr_definition_index (tea_ident callee) (tea_us_definitions callee)) =
  Some (tea_ident callee, Gfun (Internal (tea_function VersionUS callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tea_us_member : forall callee,
  In (tea_ident callee, Gfun (Internal (tea_function VersionUS callee)))
    (unit_global_definitions us_units).
Proof.
  intro callee.
  assert (prog_defs (us_nlist_at (tea_unit callee) us_units) =
    tea_us_definitions callee) as Hunit by (destruct callee; reflexivity).
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (tea_unit callee) us_units).
  - exact (us_nlist_at_nIn _ (tea_unit callee) us_units).
  - rewrite Hunit. eapply nth_error_In. exact (tea_us_source callee).
Qed.
Lemma tea_us_selection : forall callee,
  us_normalized_global_definition_map ! (tea_ident callee) =
    Some (Gfun (Internal (tea_function VersionUS callee))).
Proof.
  intro callee. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact (tea_us_member callee).
Qed.
Lemma tea_us_no_repair : forall callee,
  us_selected_definition_needs_viewport_repair
    (tea_ident callee, Gfun (Internal (tea_function VersionUS callee))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tea_us_selected_member : forall callee,
  In (tea_ident callee, Gfun (Internal (tea_function VersionUS callee)))
    us_viewport_repaired_global_definitions.
Proof.
  intro callee. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition. rewrite tea_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact (tea_us_selection callee).
Qed.
Lemma tea_jp_source : forall callee,
  (prog_defmap (nlist_at (tea_unit callee) jp_cleaned_units)) ! (tea_ident callee) =
    Some (Gfun (Internal (tea_function VersionJP callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Theorem tea_selected_callees_resolve : forall version callee, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (tea_ident callee) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tea_function version callee)).
Proof.
  intros [] callee.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (tea_us_selected_member callee).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at (tea_unit callee) jp_cleaned_units)).
    + exact (nlist_at_nIn _ (tea_unit callee) jp_cleaned_units).
    + exact (tea_jp_source callee).
Qed.

Definition TEAReachedUnloadUsesRealBody : Prop := forall version e le before
    tr last after out,
  e ! TEA._unload_area = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tea_unload_call tr last after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tea_unload_function version)) [] tr after result /\
    last = le /\ out = Out_normal.
Theorem tea_reached_unload_uses_real_body : TEAReachedUnloadUsesRealBody.
Proof.
  intros version e le before tr last after out Hlocal Hrun.
  destruct (tea_selected_callees_resolve version TEAUnload)
    as (b & Hsymbol & Hfunction).
  unfold tea_unload_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      b = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hargs : eval_exprlist _ _ _ _ [] [] ?args |- _ =>
    inversion Hargs; subst args end.
  eauto 8.
Qed.

Definition TEAReachedScanUsesRealBody : Prop := forall version e le before area
    tr last after out,
  e ! TEA._unload_objects_from_area = None ->
  le ! TEA._t'6 = Some (Vint area) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    tea_scan_call tr last after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) before
      (Internal (tol_scan_function version)) [Vint Int.zero;Vint area] tr after result.
Theorem tea_reached_scan_uses_real_body : TEAReachedScanUsesRealBody.
Proof.
  intros version e le before area tr last after out Hlocal Harea Hrun.
  destruct (tea_selected_callees_resolve version TEAScan)
    as (b & Hsymbol & Hfunction).
  unfold tea_scan_call in Hrun. inversion Hrun; subst.
  match goal with Hclass : classify_fun _ = _ |- _ =>
    cbn in Hclass; inversion Hclass; subst end.
  match goal with Hexpr : eval_expr _ _ _ _ (Evar _ (Tfunction _ _ _)) ?vf |- _ =>
    assert (vf = Vptr b Ptrofs.zero) by (eapply sce_function_name_value; eauto);
    subst vf end.
  match goal with Hfind : Genv.find_funct _ (Vptr _ _) = Some ?fd |- _ =>
    change (Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      b = Some fd) in Hfind;
    rewrite Hfunction in Hfind; inversion Hfind; subst fd end.
  match goal with Hty : type_of_fundef _ = _ |- _ =>
    assert (type_of_fundef (Internal (tol_scan_function version)) =
      Tfunction [tint;tint] tvoid cc_default) as Ety by (destruct version; reflexivity);
    rewrite Ety in Hty; inversion Hty; subst end.
  repeat match goal with Ha : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; clear Ha end.
  match goal with Hr : eval_expr _ _ _ _ (Econst_int _ _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply ocn_const_int_value; eauto); subst v end.
  match goal with Hr : eval_expr _ _ _ _ (Etempvar TEA._t'6 _) ?v |- _ =>
    assert (v = Vint area) by (eapply ocn_temp_value; eauto); subst v end.
  repeat match goal with Hcast : sem_cast (Vint ?i) _ _ _ = Some ?v |- _ =>
    change (Some (Vint i) = Some v) in Hcast; inversion Hcast; subst v; clear Hcast end.
  eauto.
Qed.

Definition TEAChangedBranchHasActualUnloadBody : Prop :=
  forall version e le before tr last after out,
  e ! TEA._unload_area = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le before
    (tea_changed_branch version) tr last after out ->
  exists unload_le unloaded unload_trace load_le loaded load_trace rest
      body_entry body_last body_out,
    tr = unload_trace ++ (load_trace ++ rest) /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) empty_env
      body_entry before (fn_body (tea_unload_function version))
      unload_trace body_last unloaded body_out /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e unload_le
      unloaded tea_load_call load_trace load_le loaded Out_normal /\
    ocn_exec (Clight.globalenv (selected_clight_target version)) e load_le
      loaded (tea_after_load version) rest last after out.
Theorem tea_changed_branch_has_actual_unload_body : TEAChangedBranchHasActualUnloadBody.
Proof.
  intros version e le before tr last after out Hlocal Hrun.
  destruct (tea_changed_branch_unloads_before_loading _ _ _ _ _ _ _ _ _ Hrun)
    as (ul & um & ut & ll & lm & lt & rest & Htrace & Hunload & Hload & Htail).
  destruct (tea_reached_unload_uses_real_body _ _ _ _ _ _ _ _ Hlocal Hunload)
    as (result & Hcall & Htemps & Hout).
  destruct (tea_complete_unload_call_has_body _ _ _ _ _ Hcall)
    as (entry & final & outcome & Hbody).
  exists ul, um, ut, ll, lm, lt, rest, entry, final, outcome.
  repeat split; assumption.
Qed.

Definition TeleporterEarlierAreaChangeBoundary : Prop :=
  TEAChangeAreaChronology /\ TEAChangedBranchUnloadBeforeLoad /\
  TEAUnloadAreaChronology /\ TEACompleteUnloadCallChronology /\
  TEAReachedUnloadUsesRealBody /\ TEAReachedScanUsesRealBody /\
  TEAChangedBranchHasActualUnloadBody /\ TWCSameAreaIntegerValuesMatch.
Theorem teleporter_earlier_area_change_boundary_checked :
  TeleporterEarlierAreaChangeBoundary.
Proof.
  split; [exact tea_actual_change_area_chronology|].
  split; [exact tea_changed_branch_unloads_before_loading|].
  split; [exact tea_actual_unload_area_chronology|].
  split; [exact tea_complete_unload_call_has_body|].
  split; [exact tea_reached_unload_uses_real_body|].
  split; [exact tea_reached_scan_uses_real_body|].
  split; [exact tea_changed_branch_has_actual_unload_body|].
  exact twc_same_area_integer_values_match.
Qed.
