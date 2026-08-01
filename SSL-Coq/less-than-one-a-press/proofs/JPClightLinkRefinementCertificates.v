From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms CompositeLayoutRefinement
  JPCompositeCompatibilityCertificate JPDeclarationCompatibilityCertificate.

Import ListNotations.

(** This lightweight module aggregates independently compiled JP composite
    and declaration receipts.  Its projections do not reevaluate the generated
    programs. *)
Theorem jp_core_declaration_composite_audit_checked :
  JPCoreDeclarationCompositeAudit.
Proof.
  split.
  - exact jp_composite_compatibility_audit_checked.
  - exact jp_declaration_compatibility_audit_checked.
Qed.

Theorem jp_exact_residual_composite_mismatches_checked :
  jp_residual_composite_mismatches =
    jp_expected_residual_composite_mismatches.
Proof. exact (proj1 jp_composite_compatibility_audit_checked). Qed.

Theorem jp_named_residuals_have_equal_checked_storage_layouts :
  all_named_tags_storage_compatible
    jp_normalized_composite_env jp_unit_composite_environments
    jp_named_residual_composite_tags = true.
Proof. exact (proj2 jp_composite_compatibility_audit_checked). Qed.

Theorem jp_all_gvar_declarations_compatible_except_gdisplaylisthead_checked :
  all_gvar_declarations_compatible_except
    jp_normalized_global_definition_map [jp_game_init._gDisplayListHead]
    (unit_global_definitions jp_units) = true.
Proof.
  exact (proj1 jp_declaration_compatibility_audit_checked).
Qed.

Theorem jp_all_function_declarations_have_equal_call_abi_checked :
  all_function_declarations_abi_compatible
    jp_normalized_global_definition_map (unit_global_definitions jp_units) = true.
Proof.
  exact (proj1 (proj2 jp_declaration_compatibility_audit_checked)).
Qed.

Theorem jp_exact_residual_function_signature_mismatches_checked :
  jp_residual_function_signature_mismatches =
    jp_expected_residual_function_signature_mismatches.
Proof.
  exact (proj2 (proj2 jp_declaration_compatibility_audit_checked)).
Qed.

Theorem jp_three_residual_function_signatures_are_viewport_functions_checked :
  In jp_game_init._clear_viewport jp_residual_function_signature_mismatches /\
  In jp_game_init._make_viewport_clip_rect
     jp_residual_function_signature_mismatches /\
  In jp_rendering_graph_node._geo_process_root
     jp_residual_function_signature_mismatches.
Proof.
  rewrite jp_exact_residual_function_signature_mismatches_checked.
  unfold jp_expected_residual_function_signature_mismatches.
  repeat split; simpl; auto.
Qed.
