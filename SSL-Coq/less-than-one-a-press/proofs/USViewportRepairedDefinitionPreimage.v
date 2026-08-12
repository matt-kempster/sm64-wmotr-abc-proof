(** Concrete specialization of the abstract viewport-repair preimage. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution NormalizedClightPrograms
  USViewportRepairDefinitionPreimage USWholeASTTagRepair.

Lemma repaired_internal_definition_has_normalized_preimage :
  forall function_id repaired_body,
    In (function_id, Gfun (Internal repaired_body))
      us_viewport_repaired_global_definitions ->
    exists source_body,
      In (function_id, Gfun (Internal source_body))
        us_normalized_global_definitions /\
      statement_evar_identifiers (fn_body repaired_body) =
        statement_evar_identifiers (fn_body source_body) /\
      function_local_identifiers repaired_body =
        function_local_identifiers source_body.
Proof.
  intros function_id repaired_body Hin.
  unfold us_viewport_repaired_global_definitions in Hin.
  exact (repaired_internal_definition_has_preimage
    us_normalized_global_definitions function_id repaired_body Hin).
Qed.
