(** Abstract Evar-resolution transport for a repaired definition list. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution NormalizedClightPrograms.

Theorem repaired_internal_evars_resolve_from_source :
  forall (source_units : nlist Clight.program)
      (normalized_definitions repaired_definitions :
        list (ident * globdef Clight.fundef type))
      (program : Clight.program),
    prog_defs program = repaired_definitions ->
    (forall function_id repaired_body,
      In (function_id, Gfun (Internal repaired_body)) repaired_definitions ->
      exists source_body,
        In (function_id, Gfun (Internal source_body))
          normalized_definitions /\
        statement_evar_identifiers (fn_body repaired_body) =
          statement_evar_identifiers (fn_body source_body) /\
        function_local_identifiers repaired_body =
          function_local_identifiers source_body) ->
    incl normalized_definitions (unit_global_definitions source_units) ->
    all_source_internal_body_evars_resolved source_units = true ->
    (forall id definition,
      In (id, definition) (unit_global_definitions source_units) ->
      exists block,
        Genv.find_symbol (Clight.globalenv program) id = Some block) ->
    forall function_id body global_id,
      In (function_id, Gfun (Internal body)) (prog_defs program) ->
      In global_id (statement_evar_identifiers (fn_body body)) ->
      ~ In global_id (function_local_identifiers body) ->
      exists block,
        Genv.find_symbol (Clight.globalenv program) global_id = Some block.
Proof.
  intros source_units normalized_definitions repaired_definitions program
    Hprogram Hpreimage Hprovenance Hcensus Hsymbol
    function_id body global_id Hbody Hoccurs Hnotlocal.
  rewrite Hprogram in Hbody.
  destruct (Hpreimage function_id body Hbody) as
    [source_body [Hnormalized [Hevars Hlocals]]].
  assert (Hsource_body :
    In (function_id, Gfun (Internal source_body))
      (unit_global_definitions source_units)).
  { exact (Hprovenance _ Hnormalized). }
  rewrite Hevars in Hoccurs.
  assert (Hnotlocal_source :
    ~ In global_id (function_local_identifiers source_body)).
  { rewrite <- Hlocals. exact Hnotlocal. }
  destruct (checked_source_internal_body_global_evar_has_source_definition
    source_units function_id source_body global_id Hcensus Hsource_body
    Hoccurs Hnotlocal_source) as [definition Hdefinition].
  exact (Hsymbol global_id definition Hdefinition).
Qed.
