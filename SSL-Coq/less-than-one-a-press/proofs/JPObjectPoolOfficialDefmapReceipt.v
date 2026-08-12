(** Exact official JP object-pool definition-map receipt. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Maps.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPObjectPoolLinkorderShape
  JPObjectPoolOfficialLinkorderReceipt JPObjectPoolOfficialShapeReceipt.

Import ListNotations.
Theorem jp_official_object_pool_exact_variable_defmap :
  (prog_defmap jp_official_cleaned_slice) !
      jp_object_list_processor._gObjectPool =
    Some (Gvar jp_object_list_processor.v_gObjectPool).
Proof.
  destruct jp_official_object_pool_linkorder_receipt
    as [linked_definition [Hlinked Horder]].
  pose proof (jp_official_object_pool_linked_definition_has_checked_shape
    linked_definition Hlinked) as Hshape.
  pose proof (jp_object_pool_linkorder_and_shape_are_exact
    linked_definition Horder Hshape) as ->.
  exact Hlinked.
Qed.
