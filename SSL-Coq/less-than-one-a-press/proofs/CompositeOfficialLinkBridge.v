From Coq Require Import ZArith.
From compcert Require Import Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms CleanedClightPrograms
  CompositeLayoutRefinement
  USViewportCollisionCertificate.

(** Kernel bridges from the lightweight composite-environment audits to the
    programs produced by the official cleaned links.  The structural link
    inhabitants are established first in [CleanedClightPrograms]; only their
    checked header equalities are used here. *)

Theorem us_normalized_semantic_composite_env_exact :
  us_normalized_composite_env =
    prog_comp_env us_normalized_semantic_slice.
Proof.
  apply us_lightweight_normalized_composite_env_exact_if_types_exact.
  exact us_normalized_slice_types_are_normalized_composites.
Qed.

Theorem jp_normalized_semantic_composite_env_exact :
  jp_normalized_composite_env =
    prog_comp_env jp_normalized_semantic_slice.
Proof.
  apply jp_lightweight_normalized_composite_env_exact_if_types_exact.
  exact jp_normalized_slice_types_are_normalized_composites.
Qed.

Theorem us_official_cleaned_composite_env_exact :
  us_normalized_composite_env = prog_comp_env us_official_cleaned_slice.
Proof.
  apply normalized_composite_env_matches_program_types.
  rewrite us_official_cleaned_slice_uses_normalized_composite_header.
  exact us_normalized_slice_types_are_normalized_composites.
Qed.

Theorem jp_official_cleaned_composite_env_exact :
  jp_normalized_composite_env = prog_comp_env jp_official_cleaned_slice.
Proof.
  apply normalized_composite_env_matches_program_types.
  rewrite jp_official_cleaned_slice_uses_normalized_composite_header.
  exact jp_normalized_slice_types_are_normalized_composites.
Qed.

Theorem us_structural_link_precedes_composite_environment_bridge :
  NormalizedCleanedUnitsOfficialLinkStructuralObligation
    us_units us_official_cleaned_slice /\
  us_normalized_composite_env = prog_comp_env us_official_cleaned_slice.
Proof.
  split.
  - exact us_normalized_cleaned_units_official_link_structural.
  - exact us_official_cleaned_composite_env_exact.
Qed.

Theorem jp_structural_link_precedes_composite_environment_bridge :
  NormalizedCleanedUnitsOfficialLinkStructuralObligation
    jp_units jp_official_cleaned_slice /\
  jp_normalized_composite_env = prog_comp_env jp_official_cleaned_slice.
Proof.
  split.
  - exact jp_normalized_cleaned_units_official_link_structural.
  - exact jp_official_cleaned_composite_env_exact.
Qed.

(** The structural witness is therefore not yet a composite semantic
    refinement for US: its official target inherits the wrong anonymous
    [__538] layout selected by the canonical header. *)
Theorem us_official_cleaned_viewport_layout_is_incompatible_with_area :
  composite_env_tag_storage_compatible
    (prog_comp_env us_official_cleaned_slice) us_area.__538
    (prog_comp_env us_area.prog) = false.
Proof.
  rewrite <- us_official_cleaned_composite_env_exact.
  exact (proj2 (proj2 us_538_collision_has_different_checked_layout)).
Qed.

Theorem us_official_cleaned_viewport_wrapper_has_wrong_size :
  sizeof (prog_comp_env us_official_cleaned_slice)
    (Tunion us_area.__540 noattr) = 8%Z.
Proof.
  rewrite <- us_official_cleaned_composite_env_exact.
  exact (proj2 (proj2
    us_viewport_wrapper_size_is_corrupted_by_538_selection_checked)).
Qed.
