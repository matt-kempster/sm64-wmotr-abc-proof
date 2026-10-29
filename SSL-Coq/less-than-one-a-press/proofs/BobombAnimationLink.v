(** Real Bob-omb animation data in both selected targets. The source wrapper
    includes the pinned common0.c animation files with its N64 const policy.
    This closes a data-link gap, not object execution, survival or wrong warp. *)
From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Clightdefs Coqlib Ctypes Globalenvs
  Integers Linking Maps Memory Values.
From LessThanOneAPress.Generated Require Import us_behavior_data jp_behavior_data
  us_bobomb_animation_data jp_bobomb_animation_data.
From LessThanOneAPress.Proofs Require Import GameTypes SelectedClightTarget
  LinkedClightPrograms NormalizedClightPrograms CleanedClightPrograms
  ClightLinkExecution GlobalInterfaceStructural ConcreteDefinitionSelection
  JPSourceSymbolTransport USWarpLevelSourceUnionReceipt LinkedGlobalInitialMemory
  USWholeASTTagRepair USViewportRepairedProgramSelection USViewportRepairedNamesNorepet
  USWarpLevelRepairReceipt.
Import ListNotations.
Local Open Scope Z_scope.

Definition bal_table_id : ident := us_behavior_data._bobomb_seg8_anims_0802396C.
Definition bal_anim0_id : ident := us_bobomb_animation_data._bobomb_seg8_anim_080237FC.
Definition bal_anim1_id : ident := us_bobomb_animation_data._bobomb_seg8_anim_08023954.
Definition bal_asset_unit version := match version with
| VersionUS => us_bobomb_animation_data.prog
| VersionJP => jp_bobomb_animation_data.prog end.
Definition bal_source_table version := match version with
| VersionUS => us_bobomb_animation_data.v_bobomb_seg8_anims_0802396C
| VersionJP => jp_bobomb_animation_data.v_bobomb_seg8_anims_0802396C end.
Definition bal_source_script version := match version with
| VersionUS => us_behavior_data.v_bhvBobomb
| VersionJP => jp_behavior_data.v_bhvBobomb end.

Definition bal_assets version : list (ident * globvar type) :=
  match version with
  | VersionUS =>
    [(us_bobomb_animation_data._bobomb_seg8_animvalue_08023528,
      us_bobomb_animation_data.v_bobomb_seg8_animvalue_08023528);
     (us_bobomb_animation_data._bobomb_seg8_animindex_08023754,
      us_bobomb_animation_data.v_bobomb_seg8_animindex_08023754);
     (bal_anim0_id, us_bobomb_animation_data.v_bobomb_seg8_anim_080237FC);
     (us_bobomb_animation_data._bobomb_seg8_animvalue_08023814,
      us_bobomb_animation_data.v_bobomb_seg8_animvalue_08023814);
     (us_bobomb_animation_data._bobomb_seg8_animindex_080238AC,
      us_bobomb_animation_data.v_bobomb_seg8_animindex_080238AC);
     (bal_anim1_id, us_bobomb_animation_data.v_bobomb_seg8_anim_08023954);
     (bal_table_id, bal_source_table VersionUS)]
  | VersionJP =>
    [(jp_bobomb_animation_data._bobomb_seg8_animvalue_08023528,
      jp_bobomb_animation_data.v_bobomb_seg8_animvalue_08023528);
     (jp_bobomb_animation_data._bobomb_seg8_animindex_08023754,
      jp_bobomb_animation_data.v_bobomb_seg8_animindex_08023754);
     (bal_anim0_id, jp_bobomb_animation_data.v_bobomb_seg8_anim_080237FC);
     (jp_bobomb_animation_data._bobomb_seg8_animvalue_08023814,
      jp_bobomb_animation_data.v_bobomb_seg8_animvalue_08023814);
     (jp_bobomb_animation_data._bobomb_seg8_animindex_080238AC,
      jp_bobomb_animation_data.v_bobomb_seg8_animindex_080238AC);
     (bal_anim1_id, jp_bobomb_animation_data.v_bobomb_seg8_anim_08023954);
     (bal_table_id, bal_source_table VersionJP)] end.
Definition bal_entries version : list (ident * globdef Clight.fundef type) :=
  map (fun '(id, variable) => (id, Gvar variable)) (bal_assets version).

Theorem bal_generated_dependency_checked : forall version,
  gvar_init (bal_source_table version) =
    [Init_addrof bal_anim0_id (Ptrofs.repr 0);
     Init_addrof bal_anim1_id (Ptrofs.repr 0); Init_int32 Int.zero] /\
  nth_error (gvar_init (bal_source_script version)) 2 =
    Some (Init_int32 (Int.repr 656801792)) /\
  nth_error (gvar_init (bal_source_script version)) 3 =
    Some (Init_addrof bal_table_id (Ptrofs.repr 0)) /\
  nth_error (gvar_init (bal_source_script version)) 5 =
    Some (Init_int32 (Int.repr 671088640)).
Proof. intros []; repeat split; reflexivity. Qed.

Theorem bal_asset_sizes_checked : forall version,
  map (fun entry => init_data_list_size (gvar_init (snd entry)))
    (bal_assets version) = [556;168;24;152;168;24;12].
Proof. intros []; vm_compute; reflexivity. Qed.

Lemma bal_asset_properties_checked : forall version,
  forallb (fun entry => definitive_variable (snd entry) &&
    negb (gvar_volatile (snd entry)) &&
    (0 <? init_data_list_size (gvar_init (snd entry)))) (bal_assets version) = true.
Proof. intros []; vm_compute; reflexivity. Qed.
Lemma bal_asset_definitive : forall version id variable,
  In (id, variable) (bal_assets version) -> definitive_variable variable = true.
Proof.
  intros version id variable Hin.
  pose proof (bal_asset_properties_checked version) as H.
  rewrite forallb_forall in H. specialize (H _ Hin).
  apply andb_true_iff in H. destruct H as [H _].
  apply andb_true_iff in H. exact (proj1 H).
Qed.
Lemma bal_asset_nonempty : forall version id variable,
  In (id, variable) (bal_assets version) ->
  (0 <? init_data_list_size (gvar_init variable)) = true.
Proof.
  intros version id variable Hin.
  pose proof (bal_asset_properties_checked version) as H.
  rewrite forallb_forall in H. specialize (H _ Hin).
  apply andb_true_iff in H. exact (proj2 H).
Qed.
Lemma bal_table_in_assets : forall version,
  In (bal_table_id, bal_source_table version) (bal_assets version).
Proof. intros []; do 6 right; left; reflexivity. Qed.

Lemma bal_generated_asset_tail : forall version,
  skipn 95 (prog_defs (bal_asset_unit version)) = bal_entries version.
Proof. intros []; reflexivity. Qed.
Lemma bal_skipn_incl : forall (A : Type) count (values : list A),
  incl (skipn count values) values.
Proof.
  intros A count. induction count as [|count IH]; intros [|head rest]; cbn;
    try apply incl_refl; try (intros item H; contradiction).
  intros item Hin. right. exact (IH rest item Hin).
Qed.
Lemma bal_asset_source_member : forall version id variable,
  In (id, variable) (bal_assets version) ->
  In (id, Gvar variable)
    (unit_global_definitions (selected_original_units version)).
Proof.
  intros version id variable Hin.
  assert (Hunit : In (id, Gvar variable) (prog_defs (bal_asset_unit version))).
  { apply (bal_skipn_incl _ 95 _). rewrite bal_generated_asset_tail.
    unfold bal_entries. apply in_map_iff. exists (id, variable). now split. }
  destruct version.
  - eapply source_unit_definition_enters_source_union
      with (unit := us_nlist_at 38%nat us_units).
    + exact (us_nlist_at_nIn _ 38%nat us_units).
    + exact Hunit.
  - eapply source_unit_definition_enters_source_union
      with (unit := us_nlist_at 38%nat jp_units).
    + exact (us_nlist_at_nIn _ 38%nat jp_units).
    + exact Hunit.
Qed.

Local Opaque unit_global_definitions normalize_global_definition_map
  clean_translation_units us_normalized_semantic_slice jp_normalized_semantic_slice.

Lemma bal_us_asset_selection : forall id variable,
  In (id, variable) (bal_assets VersionUS) ->
  us_normalized_global_definition_map ! id = Some (Gvar variable).
Proof.
  intros id variable Hin.
  eapply (checked_definitive_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_definitive_identifiers_are_unique_checked.
  - exact us_all_definitive_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance _).
  - exact (bal_asset_definitive _ _ _ Hin).
  - exact (bal_asset_source_member _ _ _ Hin).
Qed.
Lemma bal_jp_asset_selection : forall id variable,
  In (id, variable) (bal_assets VersionJP) ->
  jp_normalized_global_definition_map ! id = Some (Gvar variable).
Proof.
  intros id variable Hin.
  eapply (checked_definitive_selection_is_exact
    (unit_global_definitions jp_units) jp_normalized_global_definition_map).
  - exact jp_definitive_identifiers_are_unique_checked.
  - exact jp_all_definitive_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance _).
  - exact (bal_asset_definitive _ _ _ Hin).
  - exact (bal_asset_source_member _ _ _ Hin).
Qed.

Lemma bal_us_asset_repair_identity : forall id variable,
  In (id, variable) (bal_assets VersionUS) ->
  repair_us_selected_global_definition (id, Gvar variable) = (id, Gvar variable).
Proof.
  assert (Hcheck : forallb (fun entry =>
    negb (us_selected_definition_needs_viewport_repair entry))
    (bal_entries VersionUS) = true) by (vm_compute; reflexivity).
  rewrite forallb_forall in Hcheck.
  intros id variable Hin.
  assert (Hentry : In (id, Gvar variable) (bal_entries VersionUS)).
  { unfold bal_entries. apply in_map_iff. exists (id, variable). now split. }
  specialize (Hcheck _ Hentry). apply negb_true_iff in Hcheck.
  unfold repair_us_selected_global_definition. now rewrite Hcheck.
Qed.

Lemma bal_us_selected_member : forall id variable,
  In (id, variable) (bal_assets VersionUS) ->
  In (id, Gvar variable) us_viewport_repaired_global_definitions.
Proof.
  intros id variable Hin. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - exact (bal_us_asset_repair_identity _ _ Hin).
  - apply every_selected_definitive_initializer_is_preserved_verbatim.
    exact (bal_us_asset_selection _ _ Hin).
Qed.
Lemma bal_jp_selected_member : forall id variable,
  In (id, variable) (bal_assets VersionJP) ->
  In (id, Gvar variable) (prog_defs jp_official_cleaned_slice).
Proof.
  intros id variable Hin.
  apply jp_official_preserves_source_strong_definitions_verbatim.
  apply filter_In. split.
  - exact (bal_asset_source_member _ _ _ Hin).
  - change (definitive_variable variable = true).
    exact (bal_asset_definitive _ _ _ Hin).
Qed.

(** Resolve exact variables abstractly, without reducing a whole program. *)
Lemma bal_variable_member_resolves : forall (program : Clight.program) definitions id variable,
  prog_defs program = definitions -> list_norepet (map fst definitions) ->
  In (id, Gvar variable) definitions ->
  exists block, Genv.find_symbol (Clight.globalenv program) id = Some block /\
    Genv.find_var_info (Clight.globalenv program) block = Some variable.
Proof.
  intros program definitions id variable Hdefs Hunique Hin.
  apply variable_definition_map_resolves_globalenv. eapply prog_defmap_norepet.
  - change (list_norepet (map fst (prog_defs program))). now rewrite Hdefs.
  - change (In (id, Gvar variable) (prog_defs program)). now rewrite Hdefs.
Qed.
Lemma bal_variable_unique_payload_resolves : forall (program : Clight.program) id variable,
  In (id, Gvar variable) (prog_defs program) ->
  (forall definition, In (id, definition) (prog_defs program) ->
    definition = Gvar variable) ->
  exists block, Genv.find_symbol (Clight.globalenv program) id = Some block /\
    Genv.find_var_info (Clight.globalenv program) block = Some variable.
Proof.
  intros program id variable Hin Hunique.
  destruct (@Genv.find_symbol_exists Clight.fundef type
    (Ctypes.program_of_program program) id (Gvar variable) Hin) as [block Hsymbol].
  pose proof (@Genv.find_symbol_inversion Clight.fundef type
    (Ctypes.program_of_program program) id block Hsymbol) as Hdomain.
  destruct (@AST.prog_defmap_dom Clight.fundef type
    (Ctypes.program_of_program program) id Hdomain) as [definition Hget].
  pose proof Hget as Hmember. apply AST.in_prog_defmap in Hmember.
  pose proof (Hunique definition Hmember) as ->.
  exact (variable_definition_map_resolves_globalenv _ _ _ Hget).
Qed.

Local Opaque us_viewport_repaired_program jp_official_cleaned_slice.

Theorem selected_bobomb_animation_assets_exact : forall version id variable,
  In (id, variable) (bal_assets version) ->
  exists block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version)) id = Some block /\
    Genv.find_var_info (Clight.globalenv (selected_clight_target version)) block =
      Some variable.
Proof.
  intros [] id variable Hin.
  - eapply bal_variable_member_resolves.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (bal_us_selected_member _ _ Hin).
  - apply bal_variable_unique_payload_resolves.
    + exact (bal_jp_selected_member _ _ Hin).
    + intros definition Hmember.
      pose proof (jp_official_cleaned_definition_provenance _ _ Hmember) as Hcleaned.
      change (In (id, definition) (unit_global_definitions
        (clean_translation_units jp_units jp_normalized_semantic_slice))) in Hcleaned.
      pose proof (jp_cleaned_definition_selection_exact_checked _ _ Hcleaned) as Hselected.
      pose proof (bal_jp_asset_selection _ _ Hin) as Hactual.
      unfold jp_normalized_global_definition_map in Hactual.
      rewrite Hactual in Hselected. now inversion Hselected.
Qed.

Definition selected_bobomb_animation_data_linked version : bool :=
  existsb (fun entry => Pos.eqb (fst entry) bal_table_id &&
    match snd entry with
    | Gvar variable => 0 <? init_data_list_size (gvar_init variable)
    | _ => false end) (prog_defs (selected_clight_target version)).

Theorem selected_bobomb_animation_data_check_passes : forall version,
  selected_bobomb_animation_data_linked version = true.
Proof.
  intro version. apply existsb_exists.
  exists (bal_table_id, Gvar (bal_source_table version)). split.
  - destruct version.
    + change (In (bal_table_id, Gvar (bal_source_table VersionUS))
        (prog_defs us_viewport_repaired_program)).
      rewrite us_viewport_repaired_program_definitions_checked.
      exact (bal_us_selected_member _ _ (bal_table_in_assets VersionUS)).
    + exact (bal_jp_selected_member _ _ (bal_table_in_assets VersionJP)).
  - cbn [fst snd]. rewrite Pos.eqb_refl.
    exact (bal_asset_nonempty _ _ _ (bal_table_in_assets version)).
Qed.

Theorem selected_bobomb_animation_initial_entries : forall version memory,
  Genv.init_mem (selected_clight_target version) = Some memory ->
  exists table_block anim0_block anim1_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_table_id = Some table_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim0_id = Some anim0_block /\
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      bal_anim1_id = Some anim1_block /\
    Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
    Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
    Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero).
Proof.
  intros version memory Hinit.
  destruct (selected_bobomb_animation_assets_exact version _ _ (bal_table_in_assets version))
    as [table_block [Hsymbol Hvariable]].
  pose proof (@Genv.init_mem_characterization Clight.fundef type
    (selected_clight_target version) table_block (bal_source_table version)
    memory Hvariable Hinit) as [_ [_ [Hloads _]]].
  assert (Hnonvolatile : gvar_volatile (bal_source_table version) = false)
    by (destruct version; reflexivity).
  specialize (Hloads Hnonvolatile).
  rewrite (proj1 (bal_generated_dependency_checked version)) in Hloads.
  cbn [Genv.load_store_init_data] in Hloads.
  destruct Hloads as [[anim0_block [Hanim0 Hload0]]
    [[anim1_block [Hanim1 Hload1]] [Hnull _]]].
  exists table_block, anim0_block, anim1_block. repeat split; assumption.
Qed.

Definition BobombAnimationLinkBoundary : Prop :=
  (forall version, selected_bobomb_animation_data_linked version = true) /\
  (forall version id variable, In (id, variable) (bal_assets version) ->
    exists block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version)) id = Some block /\
      Genv.find_var_info (Clight.globalenv (selected_clight_target version)) block = Some variable) /\
  (forall version memory,
    Genv.init_mem (selected_clight_target version) = Some memory ->
    exists table_block anim0_block anim1_block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_table_id = Some table_block /\
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_anim0_id = Some anim0_block /\
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        bal_anim1_id = Some anim1_block /\
      Mem.load Mptr memory table_block 0 = Some (Vptr anim0_block Ptrofs.zero) /\
      Mem.load Mptr memory table_block 4 = Some (Vptr anim1_block Ptrofs.zero) /\
      Mem.load Mint32 memory table_block 8 = Some (Vint Int.zero)).

Theorem bobomb_animation_link_boundary_checked : BobombAnimationLinkBoundary.
Proof.
  split; [exact selected_bobomb_animation_data_check_passes|].
  split; [exact selected_bobomb_animation_assets_exact|
    exact selected_bobomb_animation_initial_entries].
Qed.
