(** Exact selected-program resolution of the generated movement helper.
    Bounded source receipts and existing link transport avoid computing the
    entire IDO-unrelated Clight program just to identify this one body. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Linking Maps.
From LessThanOneAPress.Generated Require Import us_object_helpers jp_object_helpers.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution GameTypes GlobalInterfaceStructural
  JPSourceSymbolTransport JPWarpLevelEntryResolution LinkedClightPrograms
  NormalizedClightPrograms SelectedClightTarget SuccessfulMakeProgramResolution
  USViewportRepairedNamesNorepet USViewportRepairedProgramSelection
  USWarpLevelRepairReceipt USWarpLevelSourceUnionReceipt USWholeASTTagRepair.

Theorem rank15_us_movement_nth_source_receipt :
  nth_error us_object_helpers.global_definitions 266%nat =
    Some (us_object_helpers._cur_obj_move_y_and_get_water_level,
      Gfun (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level)).
Proof. vm_compute. reflexivity. Qed.

Lemma rank15_us_movement_source_union_member :
  In (us_object_helpers._cur_obj_move_y_and_get_water_level,
      Gfun (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level))
    (unit_global_definitions us_units).
Proof.
  eapply source_unit_definition_enters_source_union
    with (unit := us_nlist_at 19%nat us_units).
  - exact (us_nlist_at_nIn _ 19%nat us_units).
  - eapply nth_error_In. exact rank15_us_movement_nth_source_receipt.
Qed.

Lemma rank15_us_movement_normalized_selection :
  us_normalized_global_definition_map !
    us_object_helpers._cur_obj_move_y_and_get_water_level =
    Some (Gfun (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level)).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units) us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact rank15_us_movement_source_union_member.
Qed.

Lemma rank15_us_movement_needs_no_repair :
  us_selected_definition_needs_viewport_repair
    (us_object_helpers._cur_obj_move_y_and_get_water_level,
      Gfun (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level)) = false.
Proof. vm_compute. reflexivity. Qed.

Lemma rank15_us_movement_repaired_definition_member :
  In (us_object_helpers._cur_obj_move_y_and_get_water_level,
      Gfun (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  apply fixed_point_enters_mapped_list.
  - unfold repair_us_selected_global_definition.
    rewrite rank15_us_movement_needs_no_repair. reflexivity.
  - apply every_selected_internal_body_is_preserved_verbatim.
    exact rank15_us_movement_normalized_selection.
Qed.

Theorem rank15_us_selected_movement_body_resolves :
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionUS))
      us_object_helpers._cur_obj_move_y_and_get_water_level = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target VersionUS))
      function_block =
      Some (Internal us_object_helpers.f_cur_obj_move_y_and_get_water_level).
Proof.
  eapply program_definitions_resolve_internal_globalenv.
  - exact us_viewport_repaired_program_definitions_checked.
  - exact us_viewport_repaired_definition_names_norepet.
  - exact rank15_us_movement_repaired_definition_member.
Qed.

Definition rank15_jp_helpers_cleaned_unit : Clight.program :=
  nlist_at 19%nat jp_cleaned_units.

Theorem rank15_jp_movement_cleaned_defmap_receipt :
  (prog_defmap rank15_jp_helpers_cleaned_unit) !
    jp_object_helpers._cur_obj_move_y_and_get_water_level =
    Some (Gfun (Internal jp_object_helpers.f_cur_obj_move_y_and_get_water_level)).
Proof. vm_compute. reflexivity. Qed.

Theorem rank15_jp_selected_movement_body_resolves :
  exists function_block,
    Genv.find_symbol (Clight.globalenv (selected_clight_target VersionJP))
      jp_object_helpers._cur_obj_move_y_and_get_water_level = Some function_block /\
    Genv.find_funct_ptr (Clight.globalenv (selected_clight_target VersionJP))
      function_block =
      Some (Internal jp_object_helpers.f_cur_obj_move_y_and_get_water_level).
Proof.
  eapply (official_link_resolves_internal_globalenv jp_cleaned_units
    jp_official_cleaned_slice jp_cleaned_units_official_link
    rank15_jp_helpers_cleaned_unit).
  - exact (nlist_at_nIn _ 19%nat jp_cleaned_units).
  - exact rank15_jp_movement_cleaned_defmap_receipt.
Qed.
