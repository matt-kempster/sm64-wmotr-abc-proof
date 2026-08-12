(** Concrete repaired-US specialization of abstract Evar resolution. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution LinkedClightPrograms NormalizedClightPrograms
  RepairedEvarResolutionTransport USRepairedSymbolTransport
  USViewportRepairedDefinitionPreimage
  USViewportRepairedProgramSelection USWholeASTTagRepair.

Theorem us_repaired_internal_body_evar_resolves :
  forall function_id body global_id,
    In (function_id, Gfun (Internal body))
      (prog_defs us_viewport_repaired_program) ->
    In global_id (statement_evar_identifiers (fn_body body)) ->
    ~ In global_id (function_local_identifiers body) ->
    exists block,
      Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
        global_id = Some block.
Proof.
  eapply (@repaired_internal_evars_resolve_from_source
    us_units us_normalized_global_definitions
    us_viewport_repaired_global_definitions
    us_viewport_repaired_program).
  - exact us_viewport_repaired_program_definitions_checked.
  - exact repaired_internal_definition_has_normalized_preimage.
  - exact us_selected_definitions_have_source_provenance.
  - exact us_source_union_all_internal_body_evars_resolve.
  - exact us_source_definition_has_repaired_symbol.
Qed.
