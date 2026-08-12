(** Per-identifier checked shape for the official JP object-pool definition. *)

From Coq Require Import List PArith.
From compcert Require Import AST Clight Ctypes Maps.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CheckedLinkedDefinitionShape CleanedClightPrograms
  JPDestinationChronologyCertificate NormalizedClightPrograms.

Lemma jp_object_pool_source_checker_at_identifier :
  forall candidate,
    jp_object_pool_source_entry_ok
      (jp_object_list_processor._gObjectPool, candidate) =
    jp_object_pool_global_shape candidate.
Proof.
  intros candidate.
  unfold jp_object_pool_source_entry_ok.
  cbn [fst]. now rewrite Pos.eqb_refl.
Qed.

Theorem jp_official_object_pool_linked_definition_has_checked_shape :
  forall linked_definition,
    (prog_defmap jp_official_cleaned_slice) !
      jp_object_list_processor._gObjectPool = Some linked_definition ->
    jp_object_pool_global_shape linked_definition = true.
Proof.
  intros linked_definition Hlinked.
  exact (@checked_provenance_supplies_linked_definition_shape
    (unit_global_definitions jp_cleaned_units)
    jp_official_cleaned_slice
    jp_object_list_processor._gObjectPool
    jp_object_pool_source_entry_ok
    jp_object_pool_global_shape
    linked_definition
    jp_object_pool_source_checker_at_identifier
    jp_cleaned_object_pool_declarations_checked
    (fun candidate Hcandidate =>
      jp_official_cleaned_definition_provenance
        jp_object_list_processor._gObjectPool candidate Hcandidate)
    Hlinked).
Qed.
