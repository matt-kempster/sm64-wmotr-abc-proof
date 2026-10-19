(** Execution cuts in the generated destination initializer.

    These theorems concern completed executions of the actual US/JP Clight
    statements, rather than a call-name census.  They do not identify a Wii
    VC exceptional continuation with Clight, or assume that a platform
    remains null through arbitrary destination object callbacks. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight ClightBigstep Clightdefs Cop Ctypes
  Events Globalenvs Integers Maps Memory Values.
From LessThanOneAPress.Generated Require Import
  us_level_update jp_level_update us_mario jp_mario us_area jp_area.
From LessThanOneAPress.Proofs Require Import GameTypes ObjectContactNecessity
  InkBackwardExecution TeleporterWrongWarpBoundary InkActionTimerReset
  InkCopyCaller Area1AllocationSource UpperElevatorQueryResolution
  CleanedClightPrograms ClightLinkExecution GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair
  SecretContactExecution EyerokRank15LiveMovement.
Import ListNotations.
Local Open Scope Z_scope.

Definition tdr_warp_body version := fn_body
  (match version with VersionUS => us_level_update.f_init_mario_after_warp
   | VersionJP => jp_level_update.f_init_mario_after_warp end).
Definition tdr_active_branch version :=
  match tww_drop_sequence_prefix 2 (tdr_warp_body version) with
  | Ssequence (Ssequence _ (Ssequence _ (Sifthenelse _ yes _))) _ => yes
  | _ => Sskip end.
Definition tdr_before_load version := ocn_prefix_items 7 (tdr_active_branch version).
Definition tdr_after_before_load version :=
  tww_drop_sequence_prefix 7 (tdr_active_branch version).
Definition tdr_load_choice version :=
  match tdr_after_before_load version with Ssequence choice _ => choice
  | _ => Sskip end.
Definition tdr_init_call := Scall None
  (Evar us_level_update._init_mario (Tfunction [] tvoid cc_default)) [].
Definition tdr_after_init version :=
  match tdr_after_before_load version with
  | Ssequence _ (Ssequence _ tail) => tail | _ => Sskip end.
Definition tdr_load_call := Scall None
  (Evar us_level_update._load_mario_area (Tfunction [] tvoid cc_default)) [].
Definition tdr_load_effects version :=
  match tdr_load_choice version with Ssequence _ (Sifthenelse _ yes _) => yes
  | _ => Sskip end.
Definition tdr_load_guard := Etempvar us_level_update._t'3 tint.
Definition tdr_before_load_guard version :=
  match tdr_load_choice version with Ssequence prefix _ => prefix
  | _ => Sskip end.
Definition tdr_set_spawn_area version :=
  match tdr_load_effects version with Ssequence prefix _ => prefix
  | _ => Sskip end.

Theorem tdr_generated_active_cuts_exact : forall version,
  tdr_active_branch version = ocn_prepend (tdr_before_load version)
    (Ssequence (tdr_load_choice version)
      (Ssequence tdr_init_call (tdr_after_init version))) /\
  forallb ibk_normal (tdr_before_load version) = true /\
  ibk_normal (tdr_load_choice version) = true /\
  tdr_load_choice version = Ssequence (tdr_before_load_guard version)
    (Sifthenelse tdr_load_guard (tdr_load_effects version) Sskip) /\
  ibk_normal (tdr_before_load_guard version) = true /\
  tdr_load_effects version = Ssequence (tdr_set_spawn_area version) tdr_load_call /\
  ibk_normal (tdr_set_spawn_area version) = true.
Proof. intros []; repeat split; reflexivity. Qed.

(** The load choice is executed before the init call in one and the same
    completed execution.  No effect specification for either callee is
    assumed by this sequencing theorem. *)
Theorem tdr_actual_active_path_executes_init :
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tdr_active_branch version) t last after out ->
  exists load_le load_m init_le init_m done_le done_m pre load_t init_t suf,
    t = pre ++ (load_t ++ (init_t ++ suf)) /\
    ocn_exec ge e le m (ocn_prepend (tdr_before_load version) Sskip)
      pre load_le load_m Out_normal /\
    ocn_exec ge e load_le load_m (tdr_load_choice version)
      load_t init_le init_m Out_normal /\
    ocn_exec ge e init_le init_m tdr_init_call
      init_t done_le done_m Out_normal /\
    ocn_exec ge e done_le done_m (tdr_after_init version) suf last after out.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tdr_generated_active_cuts_exact version)
    as (Hbody & Hprefix & Hchoice & _).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hprefix Hrun)
    as (ll & lm & pre & rest & Et & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hchoice Hr)
    as (il & im & lt & tail & Er & Hl & Hi).
  destruct (ibk_split_sequence _ _ _ _ tdr_init_call _ _ _ _ _ eq_refl Hi)
    as (dl & dm & it & suf & Ei & Hinit & Hsuf).
  exists ll, lm, il, im, dl, dm, pre, lt, it, suf.
  repeat split; try assumption. now subst.
Qed.

(** An explicit branch choice locates the area-load execution, including
    its preceding spawn-area assignment.  The false alternative is retained
    rather than silently assuming every teleport changes areas. *)
Definition TDRGuardedAreaLoadExecution : Prop :=
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tdr_load_choice version) t last after out ->
  exists cut_le cut_m chosen pre branch,
    t = pre ++ branch /\
    ocn_exec ge e le m (tdr_before_load_guard version)
      pre cut_le cut_m Out_normal /\
    ocn_test_value ge e cut_le cut_m tdr_load_guard chosen /\
    ocn_exec ge e cut_le cut_m
      (if chosen then tdr_load_effects version else Sskip)
      branch last after out /\
    (chosen = true -> exists call_le call_m assign_t call_t,
      branch = assign_t ++ call_t /\
      ocn_exec ge e cut_le cut_m (tdr_set_spawn_area version)
        assign_t call_le call_m Out_normal /\
      ocn_exec ge e call_le call_m tdr_load_call call_t last after out).
Theorem tdr_actual_load_choice_has_guarded_call : TDRGuardedAreaLoadExecution.
Proof.
  unfold TDRGuardedAreaLoadExecution.
  intros version ge e le m t last after out Hrun.
  destruct (tdr_generated_active_cuts_exact version)
    as (_ & _ & _ & Hbody & Hnormal & Heffects & Hassign).
  rewrite Hbody in Hrun.
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cl & cm & pre & branch & Et & Hp & Hb).
  inversion Hb; subst.
  exists cl, cm, b, pre, branch.
  repeat split; try assumption.
  - unfold ocn_test_value. eauto.
  - intros ->.
    assert (ocn_exec ge e cl cm (tdr_load_effects version)
      branch last after out) as Hexec by assumption.
    rewrite Heffects in Hexec.
    destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hassign Hexec)
      as (ll & lm & assign_t & ct & E & Ha & Hc).
    exists ll, lm, assign_t, ct. auto.
Qed.

Inductive TDRCallee := TDRInitMario | TDRLoadMarioArea.
Definition tdr_callee_ident callee := match callee with
  | TDRInitMario => us_mario._init_mario
  | TDRLoadMarioArea => us_area._load_mario_area end.
Definition tdr_callee_body version callee := match version, callee with
  | VersionUS, TDRInitMario => us_mario.f_init_mario
  | VersionJP, TDRInitMario => jp_mario.f_init_mario
  | VersionUS, TDRLoadMarioArea => us_area.f_load_mario_area
  | VersionJP, TDRLoadMarioArea => jp_area.f_load_mario_area end.
Definition tdr_callee_unit callee := match callee with
  | TDRInitMario => 1%nat | TDRLoadMarioArea => 27%nat end.
Definition tdr_us_definitions callee := match callee with
  | TDRInitMario => us_mario.global_definitions
  | TDRLoadMarioArea => us_area.global_definitions end.

Lemma tdr_us_source : forall callee,
  nth_error (tdr_us_definitions callee)
    (ueqr_definition_index (tdr_callee_ident callee) (tdr_us_definitions callee)) =
  Some (tdr_callee_ident callee, Gfun (Internal (tdr_callee_body VersionUS callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma tdr_us_member : forall callee,
  In (tdr_callee_ident callee, Gfun (Internal (tdr_callee_body VersionUS callee)))
    (unit_global_definitions us_units).
Proof.
  intro callee.
  assert (prog_defs (us_nlist_at (tdr_callee_unit callee) us_units) =
    tdr_us_definitions callee) as Hunit by (destruct callee; reflexivity).
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (tdr_callee_unit callee) us_units).
  - exact (us_nlist_at_nIn _ (tdr_callee_unit callee) us_units).
  - rewrite Hunit. eapply nth_error_In. exact (tdr_us_source callee).
Qed.
Lemma tdr_us_selection : forall callee,
  us_normalized_global_definition_map ! (tdr_callee_ident callee) =
    Some (Gfun (Internal (tdr_callee_body VersionUS callee))).
Proof.
  intro callee. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance (unit_global_definitions us_units)).
  - exact (tdr_us_member callee).
Qed.
Lemma tdr_us_no_repair : forall callee,
  us_selected_definition_needs_viewport_repair
    (tdr_callee_ident callee, Gfun (Internal (tdr_callee_body VersionUS callee))) = false.
Proof. intros []; vm_compute; reflexivity. Qed.
Local Opaque normalize_global_definition_map.
Lemma tdr_us_selected_member : forall callee,
  In (tdr_callee_ident callee, Gfun (Internal (tdr_callee_body VersionUS callee)))
    us_viewport_repaired_global_definitions.
Proof.
  intro callee. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition. rewrite tdr_us_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim. exact (tdr_us_selection callee).
Qed.
Lemma tdr_jp_source : forall callee,
  (prog_defmap (nlist_at (tdr_callee_unit callee) jp_cleaned_units)) !
    (tdr_callee_ident callee) = Some (Gfun (Internal (tdr_callee_body VersionJP callee))).
Proof. intros []; vm_compute; reflexivity. Qed.
Theorem tdr_selected_callees_resolve : forall version callee, exists b,
  Genv.find_symbol (Clight.globalenv (selected_clight_target version))
    (tdr_callee_ident callee) = Some b /\
  Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version)) b =
    Some (Internal (tdr_callee_body version callee)).
Proof.
  intros [] callee.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (tdr_us_selected_member callee).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (nlist_at (tdr_callee_unit callee) jp_cleaned_units)).
    + exact (nlist_at_nIn _ (tdr_callee_unit callee) jp_cleaned_units).
    + exact (tdr_jp_source callee).
Qed.

Definition TDRRealInitializerCalleeExecution : Prop :=
  forall version callee e le m t last after out,
  e ! (tdr_callee_ident callee) = None ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    (Scall None (Evar (tdr_callee_ident callee) (Tfunction [] tvoid cc_default)) [])
    t last after out ->
  exists result,
    ClightBigstep.Clight2.eval_funcall
      (Clight.globalenv (selected_clight_target version)) m
      (Internal (tdr_callee_body version callee)) [] t after result /\
    last = le /\ out = Out_normal.
Theorem tdr_reached_initializer_call_uses_real_body : TDRRealInitializerCalleeExecution.
Proof.
  unfold TDRRealInitializerCalleeExecution.
  intros version callee e le m t last after out Hlocal Hrun.
  destruct (tdr_selected_callees_resolve version callee) as (b & Hsymbol & Hfunction).
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
  match goal with Hargs : eval_exprlist _ _ _ _ [] [] ?args |- _ =>
    inversion Hargs; subst args end.
  eauto 8.
Qed.

Definition tdr_action_dispatch version :=
  match tww_drop_sequence_prefix 2 (tdr_warp_body version) with
  | Ssequence dispatch _ => dispatch | _ => Sskip end.
Definition tdr_after_action version :=
  match tww_drop_sequence_prefix 2 (tdr_warp_body version) with
  | Ssequence _ tail => tail | _ => Sskip end.
Definition tdr_before_action version := ocn_prefix_items 2 (tdr_warp_body version).
Definition tdr_action_reads version := ocn_prefix_items 2 (tdr_action_dispatch version).
Definition tdr_action_test version := Ebinop One
  (Etempvar (match version with VersionUS => us_level_update._t'37
    | VersionJP => jp_level_update._t'21 end) tuint)
  (Econst_int Int.zero tint) tint.

(** The active-branch cut is anchored in the complete generated initializer.
    This also exposes the uninitialized-action alternative explicitly. *)
Definition TDRInitializerActionPartition : Prop :=
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tdr_warp_body version) t last after out ->
  exists action_le action_m cut_le cut_m done_le done_m chosen pre reads branch suf,
    t = pre ++ ((reads ++ branch) ++ suf) /\
    ocn_exec ge e le m (ocn_prepend (tdr_before_action version) Sskip)
      pre action_le action_m Out_normal /\
    ocn_exec ge e action_le action_m (ocn_prepend (tdr_action_reads version) Sskip)
      reads cut_le cut_m Out_normal /\
    ocn_test_value ge e cut_le cut_m (tdr_action_test version) chosen /\
    ocn_exec ge e cut_le cut_m
      (if chosen then tdr_active_branch version else Sskip)
      branch done_le done_m Out_normal /\
    ocn_exec ge e done_le done_m (tdr_after_action version) suf last after out.
Theorem tdr_actual_initializer_action_partition : TDRInitializerActionPartition.
Proof.
  unfold TDRInitializerActionPartition.
  intros version ge e le m t last after out Hrun.
  assert (tdr_warp_body version = ocn_prepend (tdr_before_action version)
    (Ssequence (tdr_action_dispatch version) (tdr_after_action version))) as Hbody
    by (destruct version; reflexivity).
  assert (forallb ibk_normal (tdr_before_action version) = true) as Hprefix
    by (destruct version; reflexivity).
  assert (ibk_normal (tdr_action_dispatch version) = true) as Hnormal
    by (destruct version; reflexivity).
  assert (tdr_action_dispatch version = ocn_prepend (tdr_action_reads version)
    (Sifthenelse (tdr_action_test version) (tdr_active_branch version) Sskip)) as Hdispatch
    by (destruct version; reflexivity).
  assert (forallb ibk_normal (tdr_action_reads version) = true) as Hreads
    by (destruct version; reflexivity).
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hprefix Hrun)
    as (al & am & pre & rest & Et & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _ _ _ _ _ _ _ Hnormal Hr)
    as (dl & dm & dispatch & suf & Er & Hd & Hs).
  rewrite Hdispatch in Hd.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hreads Hd)
    as (cl & cm & reads & branch & Ed & Hread & Hb).
  inversion Hb; subst.
  exists al, am, cl, cm, dl, dm, b, pre, reads, branch, suf.
  repeat split; try assumption; try (now subst).
  unfold ocn_test_value. eauto.
Qed.

Definition tdr_credits_body version := fn_body
  (match version with VersionUS => us_level_update.f_warp_credits
   | VersionJP => jp_level_update.f_warp_credits end).
Definition tdr_credits_selector version :=
  match tdr_credits_body version with Ssequence selector _ => selector
  | _ => Sskip end.
Definition tdr_credits_after_selector version :=
  tww_drop_sequence_prefix 1 (tdr_credits_body version).
Definition tdr_credits_before_load version :=
  ocn_prefix_items 5 (tdr_credits_after_selector version).
Definition tdr_credits_after_init version :=
  tww_drop_sequence_prefix 7 (tdr_credits_after_selector version).

Lemma tdr_credits_selector_finishes_normally :
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tdr_credits_selector version) t last after out ->
  out = Out_normal.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct version; cbn [tdr_credits_selector tdr_credits_body fn_body] in Hrun;
    inversion Hrun; subst.
  all: try match goal with Hset : ClightBigstep.exec_stmt _ _ _ _ _
    (Sset _ _) _ _ _ _ |- _ => inversion Hset; subst; contradiction end.
  all: eapply iar_switch_normal; [|eassumption].
  all: intro selector;
    cbv [select_switch select_switch_case select_switch_default
      seq_of_labeled_statement iar_normal_or_break];
    repeat match goal with |- context [if ?test then _ else _] => destruct test end;
    reflexivity.
Qed.

Lemma tdr_split_normal_execution : forall ge e le m first rest t last after out,
  (forall u lu mu ou, ocn_exec ge e le m first u lu mu ou -> ou = Out_normal) ->
  ocn_exec ge e le m (Ssequence first rest) t last after out ->
  exists middle memory pre suf, t = pre ++ suf /\
    ocn_exec ge e le m first pre middle memory Out_normal /\
    ocn_exec ge e middle memory rest suf last after out.
Proof.
  intros ge e le m first rest t last after out Hnormal Hrun.
  inversion Hrun; subst; [eauto 8|].
  match goal with Hfirst : ClightBigstep.exec_stmt _ _ _ _ _ first _ _ _ _ |- _ =>
    pose proof (Hnormal _ _ _ _ Hfirst) end. contradiction.
Qed.

(** Credits initialization is an independent path: it executes both loads
    without testing Mario's action.  Its credits-data prerequisites are not
    replaced by a claim that a stale ordinary warp reaches this path. *)
Definition TDRCreditsInitializerExecution : Prop :=
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tdr_credits_body version) t last after out ->
  exists load_le load_m init_le init_m done_le done_m pre load_t init_t suf,
    t = pre ++ (load_t ++ (init_t ++ suf)) /\
    ocn_exec ge e load_le load_m tdr_load_call
      load_t init_le init_m Out_normal /\
    ocn_exec ge e init_le init_m tdr_init_call
      init_t done_le done_m Out_normal /\
    ocn_exec ge e done_le done_m (tdr_credits_after_init version)
      suf last after out.
Theorem tdr_actual_credits_path_executes_both_initializers : TDRCreditsInitializerExecution.
Proof.
  unfold TDRCreditsInitializerExecution.
  intros version ge e le m t last after out Hrun.
  assert (tdr_credits_body version = Ssequence (tdr_credits_selector version)
    (tdr_credits_after_selector version)) as Hbody by (destruct version; reflexivity).
  rewrite Hbody in Hrun.
  destruct (tdr_split_normal_execution _ _ _ _ _ _ _ _ _ _
    (tdr_credits_selector_finishes_normally version ge e le m) Hrun)
    as (al & am & selector_t & rest & Et & Hselector & Hr).
  assert (tdr_credits_after_selector version =
    ocn_prepend (tdr_credits_before_load version)
      (Ssequence tdr_load_call
        (Ssequence tdr_init_call (tdr_credits_after_init version)))) as Htail
    by (destruct version; reflexivity).
  rewrite Htail in Hr.
  destruct (ibk_split_prefix _ _ (tdr_credits_before_load version) _ _ _ _ _ _ _
    ltac:(destruct version; reflexivity) Hr)
    as (ll & lm & pre & rest_t & Ep & Hp & Hl).
  destruct (ibk_split_sequence _ _ _ _ tdr_load_call _ _ _ _ _ eq_refl Hl)
      as (il & im & lt & tail & El & Hload & Hi).
  destruct (ibk_split_sequence _ _ _ _ tdr_init_call _ _ _ _ _ eq_refl Hi)
      as (dl & dm & it & suf & Ei & Hinit & Hsuf).
  exists ll, lm, il, im, dl, dm, (selector_t ++ pre), lt, it, suf.
  repeat split; try assumption. subst. rewrite <- app_assoc. reflexivity.
Qed.

Definition tdr_init_before_held version :=
  ocn_prefix_items 12 (tww_init_mario_body version).
Definition tdr_init_held_and_tail version :=
  tww_drop_sequence_prefix 12 (tww_init_mario_body version).
Definition tdr_init_after_held version :=
  match tdr_init_held_and_tail version with Ssequence _ tail => tail
  | _ => Sskip end.
Definition tdr_held_pointer_read := Sset us_mario._t'90
  (Evar us_mario._gMarioState (tptr (Tstruct us_mario._MarioState noattr))).

Theorem tdr_generated_init_held_cut_exact : forall version,
  tww_init_mario_body version = ocn_prepend (tdr_init_before_held version)
    (Ssequence (Ssequence tdr_held_pointer_read tww_held_object_reset_statement)
      (tdr_init_after_held version)) /\
  forallb ibk_normal (tdr_init_before_held version) = true.
Proof. intros []; split; reflexivity. Qed.

(** A completed init_mario execution necessarily reaches the actual heldObj
    assignment after loading its Mario pointer.  Prefix callbacks may mutate
    state: the theorem uses the pointer read here, not an assumed entry value. *)
Theorem tdr_actual_init_mario_reaches_held_reset :
  forall version ge e le m t last after out,
  ocn_exec ge e le m (tww_init_mario_body version) t last after out ->
  exists cut_le cut_m store_le stored_m pre reset_t suf,
    t = pre ++ (reset_t ++ suf) /\
    ocn_exec ge e le m (ocn_prepend (tdr_init_before_held version) Sskip)
      pre cut_le cut_m Out_normal /\
    ocn_exec ge e cut_le cut_m
      (Ssequence tdr_held_pointer_read tww_held_object_reset_statement)
      reset_t store_le stored_m Out_normal /\
    ocn_exec ge e store_le stored_m (tdr_init_after_held version)
      suf last after out.
Proof.
  intros version ge e le m t last after out Hrun.
  destruct (tdr_generated_init_held_cut_exact version) as [Hbody Hnormal].
  rewrite Hbody in Hrun.
  destruct (ibk_split_prefix _ _ _ _ _ _ _ _ _ _ Hnormal Hrun)
    as (cl & cm & pre & rest & Et & Hp & Hr).
  destruct (ibk_split_sequence _ _ _ _
    (Ssequence tdr_held_pointer_read tww_held_object_reset_statement)
    _ _ _ _ _ eq_refl Hr)
    as (sl & sm & rt & suf & Er & Hreset & Hsuf).
  exists cl, cm, sl, sm, pre, rt, suf. repeat split; try assumption. now subst.
Qed.

Lemma tdr_selected_held_field_layout : forall version,
  ibcc_field_ok (Clight.globalenv (selected_clight_target version))
    us_mario._MarioState us_mario._heldObj 124 = true.
Proof.
  intro version.
  change (ibcc_field_ok (prog_comp_env (selected_clight_target version))
    us_mario._MarioState us_mario._heldObj 124 = true).
  rewrite <- rank15_selected_header_environment_exact.
  destruct version; vm_compute; reflexivity.
Qed.

(** This exact generated heldObj statement writes the zero pointer at the
    selected program's computed MarioState field offset, not a supplied
    arbitrary address.  Its temporary premise is at the reached statement. *)
Definition TDRHeldResetStoreExecution : Prop :=
  forall version e le m mb mo t last after out,
  le ! us_mario._t'90 = Some (Vptr mb mo) ->
  ocn_exec (Clight.globalenv (selected_clight_target version)) e le m
    tww_held_object_reset_statement t last after out ->
  t = E0 /\ last = le /\ out = Out_normal /\
  Mem.store Mptr m mb (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124)))
    (Vint Int.zero) = Some after /\
  Mem.load Mptr after mb (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124))) =
    Some (Vint Int.zero).
Theorem tdr_reached_held_reset_stores_null : TDRHeldResetStoreExecution.
Proof.
  unfold TDRHeldResetStoreExecution.
  intros version e le m mb mo t last after out Htemp Hrun.
  unfold tww_held_object_reset_statement in Hrun. inversion Hrun; subst.
  match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
    destruct (ibcc_field_location _ _ _ _
      (Ederef (Etempvar us_mario._t'90 (tptr (Tstruct us_mario._MarioState noattr)))
        (Tstruct us_mario._MarioState noattr))
      us_mario._MarioState us_mario._heldObj (tptr (Tstruct us_mario._Object noattr))
      mb mo 124 _ _ _ eq_refl
      ltac:(intros; eapply ibcc_deref_struct; [exact Htemp|eassumption])
      (tdr_selected_held_field_layout version) Hl) as (-> & -> & ->)
  end.
  match goal with Hr : eval_expr _ _ _ _ (Ecast _ _) ?v |- _ =>
    assert (v = Vint Int.zero) by (eapply tww_null_cast_has_null_value; exact Hr);
    subst v end.
  match goal with Hcast : sem_cast _ _ _ _ = Some ?v |- _ =>
    change (Some (Vint Int.zero) = Some v) in Hcast; inversion Hcast; subst v end.
  match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ =>
    inversion Ha; subst; try discriminate end.
  match goal with Hmode : access_mode _ = By_value _ |- _ =>
    cbn [access_mode] in Hmode; inversion Hmode; subst end.
  match goal with Hstore : Mem.storev _ _ _ _ = Some after |- _ =>
    change (Mem.store Mptr m mb
      (Ptrofs.unsigned (Ptrofs.add mo (Ptrofs.repr 124)))
      (Vint Int.zero) = Some after) in Hstore;
    repeat split; try assumption; try reflexivity;
    rewrite (Mem.load_store_same _ _ _ _ _ _ Hstore); reflexivity
  end.
Qed.

(** This is an execution decomposition boundary, not the VC gameplay claim.
    The separate reset-store lemma can consume the reached assignment; a
    complete arrival result must still connect these resolved calls to the
    VC continuation, preserve the
    null fields through the remaining callbacks, and cover the VC fault. *)
Definition TeleporterDestinationExecutionBoundary : Prop :=
  (forall version ge e le m t last after out,
    ocn_exec ge e le m (tdr_active_branch version) t last after out ->
    exists load_le load_m init_le init_m done_le done_m pre load_t init_t suf,
      t = pre ++ (load_t ++ (init_t ++ suf)) /\
      ocn_exec ge e le m (ocn_prepend (tdr_before_load version) Sskip)
        pre load_le load_m Out_normal /\
      ocn_exec ge e load_le load_m (tdr_load_choice version)
        load_t init_le init_m Out_normal /\
      ocn_exec ge e init_le init_m tdr_init_call
        init_t done_le done_m Out_normal /\
      ocn_exec ge e done_le done_m (tdr_after_init version) suf last after out) /\
  (forall version ge e le m t last after out,
    ocn_exec ge e le m (tww_init_mario_body version) t last after out ->
    exists cut_le cut_m store_le stored_m pre reset_t suf,
      t = pre ++ (reset_t ++ suf) /\
      ocn_exec ge e le m (ocn_prepend (tdr_init_before_held version) Sskip)
        pre cut_le cut_m Out_normal /\
      ocn_exec ge e cut_le cut_m
        (Ssequence tdr_held_pointer_read tww_held_object_reset_statement)
        reset_t store_le stored_m Out_normal /\
      ocn_exec ge e store_le stored_m (tdr_init_after_held version)
        suf last after out) /\
  TDRInitializerActionPartition /\
  TDRGuardedAreaLoadExecution /\
  TDRCreditsInitializerExecution /\
  TDRRealInitializerCalleeExecution /\
  TDRHeldResetStoreExecution.

Theorem teleporter_destination_execution_boundary_checked :
  TeleporterDestinationExecutionBoundary.
Proof.
  split; [exact tdr_actual_active_path_executes_init|].
  split; [exact tdr_actual_init_mario_reaches_held_reset|].
  split; [exact tdr_actual_initializer_action_partition|].
  split; [exact tdr_actual_load_choice_has_guarded_call|].
  split; [exact tdr_actual_credits_path_executes_both_initializers|].
  split; [exact tdr_reached_initializer_call_uses_real_body|].
  exact tdr_reached_held_reset_stores_null.
Qed.
