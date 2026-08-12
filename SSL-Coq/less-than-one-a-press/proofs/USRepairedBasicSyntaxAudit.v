(** Direct-Sbuiltin and external-constructor audit for repaired US syntax. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  ClightLinkExecution DefinitionListSyntaxTransport
  LinkedClightPrograms NormalizedClightPrograms
  USViewportRepairDefinitionListSyntax USViewportRepairedProgramSelection
  USWholeASTTagRepair.

Import ListNotations.

Theorem us_repaired_target_has_no_direct_sbuiltin :
  program_direct_sbuiltins us_viewport_repaired_program = [].
Proof.
  unfold program_direct_sbuiltins.
  rewrite us_viewport_repaired_program_definitions_checked.
  unfold us_viewport_repaired_global_definitions.
  rewrite repair_definition_list_preserves_direct_sbuiltins.
  eapply definition_list_provenance_transfers_no_direct_sbuiltin.
  - exact us_selected_definitions_have_source_provenance.
  - exact us_source_union_has_no_direct_sbuiltin.
Qed.

Theorem us_repaired_external_constructors_supported :
  forallb external_global_has_supported_constructor
    (prog_defs us_viewport_repaired_program) = true.
Proof.
  rewrite us_viewport_repaired_program_definitions_checked.
  unfold us_viewport_repaired_global_definitions.
  rewrite repair_definition_list_preserves_external_constructors.
  eapply definition_list_provenance_transfers_supported_constructors.
  - exact us_selected_definitions_have_source_provenance.
  - exact us_source_global_external_constructors_complete.
Qed.
