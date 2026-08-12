(** Official-link output and linkorder receipt for JP [gObjectPool]. *)

From compcert Require Import AST Clight Ctypes Linking Maps.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms ClightLinkExecution
  JPObjectPoolCleanedUnitDefmapReceipt.

Theorem jp_official_object_pool_linkorder_receipt :
  exists linked_definition,
    (prog_defmap jp_official_cleaned_slice) !
      jp_object_list_processor._gObjectPool = Some linked_definition /\
    linkorder (Gvar jp_object_list_processor.v_gObjectPool)
      linked_definition.
Proof.
  exact (official_link_preserves_definition
    jp_cleaned_units jp_official_cleaned_slice
    jp_cleaned_units_official_link
    jp_object_pool_cleaned_unit
    jp_object_list_processor._gObjectPool
    (Gvar jp_object_list_processor.v_gObjectPool)
    (jp_pool_nlist_at_nIn _ 13%nat jp_cleaned_units)
    jp_object_pool_cleaned_unit_exact_variable_checked).
Qed.
