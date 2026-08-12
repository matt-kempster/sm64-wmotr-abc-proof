(** Concrete specialization of abstract normalized/repair name transport to
    the successfully constructed viewport-repaired US selected program. *)

From Coq Require Import List.
From compcert Require Import AST Clight Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms
  NormalizedRepairedSymbolTransport USViewportRepairedProgramSelection
  USWholeASTTagRepair.

Theorem us_source_definition_has_repaired_symbol :
  forall id definition,
    In (id, definition) (unit_global_definitions us_units) ->
    exists block,
      Genv.find_symbol (Clight.globalenv us_viewport_repaired_program) id =
        Some block.
Proof.
  intros id definition Hin.
  eapply source_definition_has_normalized_repaired_symbol
    with (definitions := unit_global_definitions us_units)
         (definition := definition).
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
  - exact Hin.
Qed.
