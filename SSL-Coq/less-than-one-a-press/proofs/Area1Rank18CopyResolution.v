(** Resolve the copy used by Rank 18 in the actual selected US/JP programs.
    Source membership alone would not authenticate the executed callee. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Proofs Require Import
  Area1Rank18CopyRead Area1Rank18StateArrayBound
  CleanedClightPrograms ClightLinkExecution GameTypes
  GlobalInterfaceStructural JPSourceSymbolTransport JPWarpLevelEntryResolution
  LinkedClightPrograms NormalizedClightPrograms SelectedClightTarget
  SuccessfulMakeProgramResolution USViewportRepairedNamesNorepet
  USViewportRepairedProgramSelection USWarpLevelRepairReceipt
  USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Fixpoint rank18_definition_index (id : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : nat :=
  match definitions with
  | nil => O
  | (candidate, _) :: rest =>
      if Pos.eqb id candidate then O else S (rank18_definition_index id rest)
  end.

Definition rank18_copy_source_index : nat :=
  rank18_definition_index R18U._copy_mario_state_to_object R18U.global_definitions.

Lemma rank18_us_copy_source_receipt :
  nth_error R18U.global_definitions rank18_copy_source_index =
    Some (R18U._copy_mario_state_to_object,
      Gfun (Internal (rank18_copy_body VersionUS))).
Proof. vm_compute; reflexivity. Qed.

Lemma rank18_us_copy_source_union_member :
  In (R18U._copy_mario_state_to_object,
      Gfun (Internal (rank18_copy_body VersionUS)))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 13 us_units).
  - exact (us_nlist_at_nIn _ 13 us_units).
  - eapply nth_error_In. exact rank18_us_copy_source_receipt.
Qed.

Lemma rank18_us_copy_normalized_selection :
  us_normalized_global_definition_map ! R18U._copy_mario_state_to_object =
    Some (Gfun (Internal (rank18_copy_body VersionUS))).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact rank18_us_copy_source_union_member.
Qed.

Lemma rank18_us_copy_needs_no_repair :
  us_selected_definition_needs_viewport_repair
    (R18U._copy_mario_state_to_object,
      Gfun (Internal (rank18_copy_body VersionUS))) = false.
Proof. vm_compute; reflexivity. Qed.

Lemma rank18_us_normalized_copy_member :
  In (R18U._copy_mario_state_to_object,
      Gfun (Internal (rank18_copy_body VersionUS)))
    us_normalized_global_definitions.
Proof.
  change (In (R18U._copy_mario_state_to_object,
    Gfun (Internal (rank18_copy_body VersionUS)))
    (PTree.elements us_normalized_global_definition_map)).
  apply PTree.elements_correct. exact rank18_us_copy_normalized_selection.
Qed.

Lemma rank18_us_selected_copy_member :
  In (R18U._copy_mario_state_to_object,
      Gfun (Internal (rank18_copy_body VersionUS)))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank18_us_copy_needs_no_repair. reflexivity.
  - exact rank18_us_normalized_copy_member.
Qed.

Definition rank18_jp_copy_unit : Clight.program := nlist_at 13 jp_cleaned_units.

Lemma rank18_jp_copy_defmap_receipt :
  (prog_defmap rank18_jp_copy_unit) ! R18U._copy_mario_state_to_object =
    Some (Gfun (Internal (rank18_copy_body VersionJP))).
Proof. vm_compute; reflexivity. Qed.

Theorem rank18_selected_copy_body_resolves : forall version,
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target version))
      R18U._copy_mario_state_to_object = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
      function_block = Some (Internal (rank18_copy_body version)).
Proof.
  intros [].
  - eapply program_definitions_resolve_internal_globalenv.
    + exact us_viewport_repaired_program_definitions_checked.
    + exact us_viewport_repaired_definition_names_norepet.
    + exact rank18_us_selected_copy_member.
  - eapply (official_link_resolves_internal_globalenv jp_cleaned_units
      jp_official_cleaned_slice jp_cleaned_units_official_link rank18_jp_copy_unit).
    + exact (nlist_at_nIn _ 13 jp_cleaned_units).
    + exact rank18_jp_copy_defmap_receipt.
Qed.

Record Area1Rank18CopyCheckedBoundary : Prop := {
  rank18_boundary_resolves_real_copy : forall version,
    exists function_block,
      Genv.find_symbol (Clight.globalenv (selected_clight_target version))
        R18U._copy_mario_state_to_object = Some function_block /\
      Genv.find_funct_ptr (Clight.globalenv (selected_clight_target version))
        function_block = Some (Internal (rank18_copy_body version));
  rank18_boundary_checks_real_prefix : forall version, Rank18CopyFirstReadPrefix version;
  rank18_boundary_no_local_array_shadow :
    forall version ge arguments memory environment temporaries after,
      function_entry2 ge (rank18_copy_body version) arguments memory
        environment temporaries after ->
      environment = empty_env /\ after = memory;
  rank18_boundary_wrong_index_has_no_step : Rank18ReachedIndexOneReadHasNoStep
}.

Theorem area1_rank18_copy_checked_boundary_holds : Area1Rank18CopyCheckedBoundary.
Proof.
  constructor.
  - exact rank18_selected_copy_body_resolves.
  - exact rank18_first_read_is_the_generated_copy_prefix.
  - exact rank18_copy_entry_has_empty_locals.
  - exact rank18_reached_index_one_copy_read_has_no_step.
Qed.
