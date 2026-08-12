(** Abstract name-domain transport from one source translation unit through
    normalization, viewport repair, and successful program construction. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.
From LessThanOneAPress.Proofs Require Import
  JPSourceSymbolTransport NormalizedClightPrograms
  NormalizedRepairedSymbolTransport USWholeASTTagRepair.

Theorem source_unit_definition_has_normalized_repaired_symbol :
  forall (units : nlist Clight.program) (unit program : Clight.program)
      id definition,
    nIn unit units ->
    In (id, definition) (prog_defs unit) ->
    prog_defs program =
      map repair_us_selected_global_definition
        (normalize_global_definitions (unit_global_definitions units)) ->
    exists block,
      Genv.find_symbol (Clight.globalenv program) id = Some block.
Proof.
  intros units unit program id definition Hunit Hdefinition Hprogram.
  eapply source_definition_has_normalized_repaired_symbol
    with (definitions := unit_global_definitions units)
         (definition := definition).
  - exact Hprogram.
  - eapply source_unit_definition_enters_source_union; eauto.
Qed.
