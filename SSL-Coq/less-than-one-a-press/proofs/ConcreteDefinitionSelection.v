(** Concrete US/JP instances of the checked cleaned-definition selector. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Maps.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms CleanedClightPrograms
  GlobalInterfaceStructural.

Local Opaque us_units jp_units us_normalized_semantic_slice
  jp_normalized_semantic_slice unit_global_definitions
  clean_translation_units normalize_global_definition_map.

Theorem us_cleaned_definition_selection_exact_checked :
  forall id definition,
    In (id, definition)
      (unit_global_definitions
        (clean_translation_units us_units us_normalized_semantic_slice)) ->
    PTree.get id
      (normalize_global_definition_map (unit_global_definitions us_units)) =
      Some definition.
Proof.
  intros id definition Hin.
  exact (generic_checked_cleaned_definition_exactness_capstone
    us_units us_normalized_semantic_slice
    us_internal_identifiers_are_unique_checked
    us_definitive_identifiers_are_unique_checked
    us_all_internal_identifiers_selected_checked
    us_all_definitive_identifiers_selected_checked id definition Hin).
Qed.

Theorem jp_cleaned_definition_selection_exact_checked :
  forall id definition,
    In (id, definition)
      (unit_global_definitions
        (clean_translation_units jp_units jp_normalized_semantic_slice)) ->
    PTree.get id
      (normalize_global_definition_map (unit_global_definitions jp_units)) =
      Some definition.
Proof.
  intros id definition Hin.
  exact (generic_checked_cleaned_definition_exactness_capstone
    jp_units jp_normalized_semantic_slice
    jp_internal_identifiers_are_unique_checked
    jp_definitive_identifiers_are_unique_checked
    jp_all_internal_identifiers_selected_checked
    jp_all_definitive_identifiers_selected_checked id definition Hin).
Qed.
