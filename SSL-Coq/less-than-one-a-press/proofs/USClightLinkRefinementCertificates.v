From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms CompositeLayoutRefinement
  USCompositeCompatibilityCertificate USDeclarationCompatibilityCertificate
  USViewportLayoutCertificates USViewportFreshTagCertificate.

Import ListNotations.

(** This lightweight module aggregates independently compiled US composite,
    declaration, fresh-tag, and viewport-layout receipts.  Its projections do
    not reevaluate the generated programs. *)
Theorem us_core_declaration_composite_audit_checked :
  USCoreDeclarationCompositeAudit.
Proof.
  split.
  - exact us_composite_compatibility_audit_checked.
  - exact us_declaration_compatibility_audit_checked.
Qed.

Definition USCompleteLinkRefinementAudit : Prop :=
  USCoreDeclarationCompositeAudit /\
  USFreshTagGloballyUnused us_area_viewport_fresh_tag.

Theorem us_complete_link_refinement_audit_checked :
  USCompleteLinkRefinementAudit.
Proof.
  split.
  - exact us_core_declaration_composite_audit_checked.
  - exact us_area_viewport_fresh_tag_is_globally_unused_receipt.
Qed.

Theorem us_exact_residual_composite_mismatches_checked :
  us_residual_composite_mismatches =
    us_expected_residual_composite_mismatches.
Proof. exact (proj1 us_composite_compatibility_audit_checked). Qed.

Theorem us_named_residuals_have_equal_checked_storage_layouts :
  all_named_tags_storage_compatible
    us_normalized_composite_env us_unit_composite_environments
    us_named_residual_composite_tags = true.
Proof. exact (proj2 us_composite_compatibility_audit_checked). Qed.

Theorem us_all_gvar_declarations_compatible_except_gdisplaylisthead_checked :
  all_gvar_declarations_compatible_except
    us_normalized_global_definition_map [us_game_init._gDisplayListHead]
    (unit_global_definitions us_units) = true.
Proof.
  exact (proj1 us_declaration_compatibility_audit_checked).
Qed.

Theorem us_all_function_declarations_have_equal_call_abi_checked :
  all_function_declarations_abi_compatible
    us_normalized_global_definition_map (unit_global_definitions us_units) = true.
Proof.
  exact (proj1 (proj2 us_declaration_compatibility_audit_checked)).
Qed.

Theorem us_exact_residual_function_signature_mismatches_checked :
  us_residual_function_signature_mismatches =
    us_expected_residual_function_signature_mismatches.
Proof.
  exact (proj2 (proj2 us_declaration_compatibility_audit_checked)).
Qed.

Theorem us_three_residual_function_signatures_are_viewport_functions_checked :
  In us_game_init._clear_viewport us_residual_function_signature_mismatches /\
  In us_game_init._make_viewport_clip_rect
     us_residual_function_signature_mismatches /\
  In us_rendering_graph_node._geo_process_root
     us_residual_function_signature_mismatches.
Proof.
  rewrite us_exact_residual_function_signature_mismatches_checked.
  unfold us_expected_residual_function_signature_mismatches.
  repeat split; simpl; auto.
Qed.

Theorem us_area_viewport_fresh_tag_is_globally_unused_checked :
  USFreshTagGloballyUnused us_area_viewport_fresh_tag.
Proof. exact us_area_viewport_fresh_tag_is_globally_unused_receipt. Qed.

Theorem us_all_viewport_538_alpha_renaming_layout_constructed :
  USAllViewport538AlphaRenamingLayoutObligation.
Proof.
  split.
  - exact us_area_viewport_fresh_tag_is_globally_unused_checked.
  - split.
    + exact us_area_viewport_tag_alpha_renaming_layout_constructed.
    + exact us_cutscene_viewport_tag_alpha_renaming_layout_constructed.
Qed.
