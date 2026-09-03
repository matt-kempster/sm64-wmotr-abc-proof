(** Rank 11 bodies are the actual selected US/JP bodies, not independently
    interpreted source snippets.  Per-definition receipts and symbolic link
    transport keep this check bounded. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import
  Area2Rank11PoleExitSplit CleanedClightPrograms ClightLinkExecution GameTypes
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SelectedClightTarget
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Inductive Rank11NativeBody :=
| R11PoleNative (handler : Rank11PoleHandler)
| R11AirborneInitializer
| R11KnockbackSelector.

Definition rank11_native_body version native : function :=
  match native with
  | R11PoleNative handler => rank11_pole_body version handler
  | R11AirborneInitializer => rank11_airborne_body version
  | R11KnockbackSelector => match version with
      | VersionUS => us_interaction.f_determine_knockback_action
      | VersionJP => jp_interaction.f_determine_knockback_action
      end
  end.

Definition rank11_native_ident native : ident :=
  match native with
  | R11PoleNative handler => rank11_pole_ident handler
  | R11AirborneInitializer => R11MU._set_mario_action_airborne
  | R11KnockbackSelector => us_interaction._determine_knockback_action
  end.

Definition rank11_source_unit_index native : nat :=
  match native with
  | R11PoleNative _ => 3 | R11AirborneInitializer => 1
  | R11KnockbackSelector => 10
  end.

Definition rank11_us_source_definitions native :=
  match native with
  | R11PoleNative _ => R11U.global_definitions
  | R11AirborneInitializer => R11MU.global_definitions
  | R11KnockbackSelector => us_interaction.global_definitions
  end.

Fixpoint rank11_definition_index (id : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : nat :=
  match definitions with
  | nil => O
  | (candidate, _) :: rest =>
      if Pos.eqb id candidate then O else S (rank11_definition_index id rest)
  end.

Definition rank11_source_definition_index native : nat :=
  rank11_definition_index (rank11_native_ident native)
    (rank11_us_source_definitions native).

Lemma rank11_us_source_definition_receipt : forall native,
  nth_error (rank11_us_source_definitions native)
    (rank11_source_definition_index native) =
    Some (rank11_native_ident native,
      Gfun (Internal (rank11_native_body VersionUS native))).
Proof. intros [[] | |]; vm_compute; reflexivity. Qed.

Lemma rank11_us_source_union_member : forall native,
  In (rank11_native_ident native,
      Gfun (Internal (rank11_native_body VersionUS native)))
    (unit_global_definitions us_units).
Proof.
  intro native. eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at (rank11_source_unit_index native) us_units).
  - exact (us_nlist_at_nIn _ (rank11_source_unit_index native) us_units).
  - destruct native as [handler | |].
    + eapply nth_error_In. exact (rank11_us_source_definition_receipt
        (R11PoleNative handler)).
    + eapply nth_error_In. exact (rank11_us_source_definition_receipt
        R11AirborneInitializer).
    + eapply nth_error_In. exact (rank11_us_source_definition_receipt
        R11KnockbackSelector).
Qed.

Lemma rank11_us_normalized_selection : forall native,
  us_normalized_global_definition_map ! (rank11_native_ident native) =
    Some (Gfun (Internal (rank11_native_body VersionUS native))).
Proof.
  intro native. eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact (rank11_us_source_union_member native).
Qed.

Lemma rank11_us_native_needs_no_repair : forall native,
  us_selected_definition_needs_viewport_repair
    (rank11_native_ident native,
      Gfun (Internal (rank11_native_body VersionUS native))) = false.
Proof. intros [[] | |]; vm_compute; reflexivity. Qed.

Lemma rank11_us_selected_member : forall native,
  In (rank11_native_ident native,
      Gfun (Internal (rank11_native_body VersionUS native)))
    us_viewport_repaired_global_definitions.
Proof.
  intro native. unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank11_us_native_needs_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact (rank11_us_normalized_selection native).
Qed.

Definition rank11_jp_cleaned_unit native : Clight.program :=
  nlist_at (rank11_source_unit_index native) jp_cleaned_units.

Lemma rank11_jp_cleaned_defmap_receipt : forall native,
  (prog_defmap (rank11_jp_cleaned_unit native)) ! (rank11_native_ident native) =
    Some (Gfun (Internal (rank11_native_body VersionJP native))).
Proof. intros [[] | |]; vm_compute; reflexivity. Qed.

Theorem rank11_selected_native_body_resolves : forall version native,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      (rank11_native_ident native) = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank11_native_body version native)).
Proof.
  intros [] native.
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact (rank11_us_selected_member native).
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link
      (rank11_jp_cleaned_unit native)).
    + exact (nlist_at_nIn _ (rank11_source_unit_index native) jp_cleaned_units).
    + exact (rank11_jp_cleaned_defmap_receipt native).
Qed.
