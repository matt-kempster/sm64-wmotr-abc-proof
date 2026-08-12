(** Exact normalized-definition receipt for US [_warp_level].  The expensive
    global boolean inventories are imported as opaque theorems; this module
    performs only their structural specialization to the focused source
    member. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Maps.
From LessThanOneAPress.Generated Require Import us_level_update.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms GlobalInterfaceStructural
  USWarpLevelSourceUnionReceipt.

Theorem us_warp_level_normalized_selection_checked :
  PTree.get us_level_update._warp_level
    us_normalized_global_definition_map =
  Some (Gfun (Internal us_level_update.f_warp_level)).
Proof.
  eapply (checked_internal_selection_is_exact
    (unit_global_definitions us_units)
    us_normalized_global_definition_map).
  - exact us_internal_identifiers_are_unique_checked.
  - exact us_all_internal_identifiers_selected_checked.
  - exact (normalized_definition_map_has_source_provenance
      (unit_global_definitions us_units)).
  - exact us_warp_level_source_union_member.
Qed.

Theorem us_warp_level_normalized_definition_member :
  In (us_level_update._warp_level,
      Gfun (Internal us_level_update.f_warp_level))
    us_normalized_global_definitions.
Proof.
  unfold us_normalized_global_definitions.
  eapply every_selected_internal_body_is_preserved_verbatim.
  exact us_warp_level_normalized_selection_checked.
Qed.
