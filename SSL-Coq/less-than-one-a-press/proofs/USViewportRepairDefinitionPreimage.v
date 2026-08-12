(** Abstract preimage of an internal definition under the viewport repair. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution USViewportRepairSyntaxPreservation
  USWholeASTTagRepair.

Lemma repaired_internal_definition_has_preimage :
  forall definitions function_id repaired_body,
    In (function_id, Gfun (Internal repaired_body))
      (map repair_us_selected_global_definition definitions) ->
    exists source_body,
      In (function_id, Gfun (Internal source_body)) definitions /\
      statement_evar_identifiers (fn_body repaired_body) =
        statement_evar_identifiers (fn_body source_body) /\
      function_local_identifiers repaired_body =
        function_local_identifiers source_body.
Proof.
  intros definitions function_id repaired_body Hin.
  apply in_map_iff in Hin.
  destruct Hin as [[source_id source_definition] [Hrepair Hsource]].
  unfold repair_us_selected_global_definition in Hrepair.
  destruct (us_selected_definition_needs_viewport_repair
    (source_id, source_definition)).
  - destruct source_definition as
      [[source_body | external arguments result convention] | variable];
      cbn [rename_globdef_tag rename_fundef_tag] in Hrepair;
      try discriminate.
    inversion Hrepair; subst source_id repaired_body.
    exists source_body. split; [exact Hsource |]. split.
    + apply rename_statement_tag_preserves_evar_identifiers.
    + apply rename_function_tag_preserves_local_identifiers.
  - inversion Hrepair; subst source_id source_definition.
    exists repaired_body. repeat split; auto.
Qed.
