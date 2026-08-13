(** Exact transport of US [update_mario_platform] through normalization and
    the targeted whole-program viewport-tag repair. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Maps.
From LessThanOneAPress.Generated Require Import us_platform_displacement.
From LessThanOneAPress.Proofs Require Import
  GlobalInterfaceStructural LinkedClightPrograms NormalizedClightPrograms
  PlatformUpdateSourceReceipt USWholeASTTagRepair
  USWarpLevelRepairReceipt.

Theorem us_platform_update_normalized_selection_checked :
  PTree.get us_platform_displacement._update_mario_platform
    us_normalized_global_definition_map =
  Some (Gfun (Internal us_platform_displacement.f_update_mario_platform)).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units)
    us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact us_platform_update_source_union_member.
Qed.

Theorem us_platform_update_normalized_definition_member :
  In (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform))
    us_normalized_global_definitions.
Proof.
  unfold us_normalized_global_definitions.
  eapply every_selected_internal_body_is_preserved_verbatim.
  exact us_platform_update_normalized_selection_checked.
Qed.

(** This is the only body-sized computation in the US resolution chain. *)
Theorem us_platform_update_needs_no_viewport_repair_checked :
  us_selected_definition_needs_viewport_repair
    (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform)) =
    false.
Proof. vm_compute. reflexivity. Qed.

Theorem us_platform_update_repair_is_identity :
  repair_us_selected_global_definition
    (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform)) =
    (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform)).
Proof.
  unfold repair_us_selected_global_definition.
  rewrite us_platform_update_needs_no_viewport_repair_checked.
  reflexivity.
Qed.

Theorem us_platform_update_repaired_definition_member :
  In (us_platform_displacement._update_mario_platform,
      Gfun (Internal us_platform_displacement.f_update_mario_platform))
    us_viewport_repaired_global_definitions.
Proof.
  unfold us_viewport_repaired_global_definitions.
  eapply fixed_point_enters_mapped_list.
  - exact us_platform_update_repair_is_identity.
  - exact us_platform_update_normalized_definition_member.
Qed.
