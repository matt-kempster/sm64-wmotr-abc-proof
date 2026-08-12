(** Abstract Init_addrof-resolution transport for a repaired program. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution DefinitionListSyntaxTransport
  NormalizedClightPrograms.

Theorem repaired_init_addrofs_resolve_from_source :
  forall (source_units : nlist Clight.program)
      (normalized_definitions :
        list (ident * globdef Clight.fundef type))
      (program : Clight.program),
    program_init_addrof_identifiers program =
      concat (map global_definition_init_addrof_identifiers
        normalized_definitions) ->
    incl normalized_definitions (unit_global_definitions source_units) ->
    all_source_union_init_addrof_identifiers_resolved source_units = true ->
    (forall id definition,
      In (id, definition) (unit_global_definitions source_units) ->
      exists block,
        Genv.find_symbol (Clight.globalenv program) id = Some block) ->
    forall global_id,
      In global_id (program_init_addrof_identifiers program) ->
      exists block,
        Genv.find_symbol (Clight.globalenv program) global_id = Some block.
Proof.
  intros source_units normalized_definitions program Hidentifiers
    Hprovenance Hcensus Hsymbol global_id Hin.
  rewrite Hidentifiers in Hin.
  assert (Hsource :
    In global_id (source_union_init_addrof_identifiers source_units)).
  {
    eapply definition_list_provenance_transfers_init_addrof_occurrence.
    - exact Hprovenance.
    - exact Hin.
  }
  destruct (checked_source_union_init_addrof_identifier_has_definition
    source_units global_id Hcensus Hsource) as [definition Hdefinition].
  exact (Hsymbol global_id definition Hdefinition).
Qed.
