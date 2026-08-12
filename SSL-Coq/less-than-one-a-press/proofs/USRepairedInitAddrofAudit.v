(** Concrete repaired-US specialization of abstract Init_addrof resolution. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution LinkedClightPrograms NormalizedClightPrograms
  RepairedInitAddrofResolutionTransport USRepairedSymbolTransport
  USViewportRepairDefinitionListSyntax USViewportRepairedProgramSelection
  USWholeASTTagRepair.

Lemma us_repaired_init_addrof_identifiers_checked :
  program_init_addrof_identifiers us_viewport_repaired_program =
  concat (map global_definition_init_addrof_identifiers
    us_normalized_global_definitions).
Proof.
  unfold program_init_addrof_identifiers.
  rewrite us_viewport_repaired_program_definitions_checked.
  unfold us_viewport_repaired_global_definitions.
  apply repair_definition_list_preserves_init_addrofs.
Qed.

Theorem us_repaired_init_addrof_identifier_resolves :
  forall global_id,
    In global_id
      (program_init_addrof_identifiers us_viewport_repaired_program) ->
    exists block,
      Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
        global_id = Some block.
Proof.
  eapply (@repaired_init_addrofs_resolve_from_source
    us_units us_normalized_global_definitions
    us_viewport_repaired_program).
  - exact us_repaired_init_addrof_identifiers_checked.
  - exact us_selected_definitions_have_source_provenance.
  - exact us_source_union_all_init_addrof_identifiers_resolve.
  - exact us_source_definition_has_repaired_symbol.
Qed.
