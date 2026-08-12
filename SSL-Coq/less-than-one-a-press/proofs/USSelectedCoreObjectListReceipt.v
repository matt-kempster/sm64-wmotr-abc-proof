(** Repaired-program symbols for the three object-state core globals. *)

From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.
From LessThanOneAPress.Generated Require Import us_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms SourceUnitRepairedSymbol
  USSelectedCoreObjectListNthReceipt
  USViewportRepairedProgramSelection USWholeASTTagRepair.

Lemma us_object_list_processor_is_core_symbol_source_unit :
  nIn us_object_list_processor.prog us_units.
Proof. unfold us_units. do 13 right. now left. Qed.

Theorem us_repaired_state_storage_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_object_list_processor._gMarioStates = Some block.
Proof.
  eapply source_unit_definition_has_normalized_repaired_symbol
    with (unit := us_object_list_processor.prog)
         (definition := Gvar us_object_list_processor.v_gMarioStates).
  - exact us_object_list_processor_is_core_symbol_source_unit.
  - exact us_object_list_processor_gMarioStates_prog_defs_member.
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
Qed.

Theorem us_repaired_object_pool_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_object_list_processor._gObjectPool = Some block.
Proof.
  eapply source_unit_definition_has_normalized_repaired_symbol
    with (unit := us_object_list_processor.prog)
         (definition := Gvar us_object_list_processor.v_gObjectPool).
  - exact us_object_list_processor_is_core_symbol_source_unit.
  - exact us_object_list_processor_gObjectPool_prog_defs_member.
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
Qed.

Theorem us_repaired_mario_object_pointer_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_object_list_processor._gMarioObject = Some block.
Proof.
  eapply source_unit_definition_has_normalized_repaired_symbol
    with (unit := us_object_list_processor.prog)
         (definition := Gvar us_object_list_processor.v_gMarioObject).
  - exact us_object_list_processor_is_core_symbol_source_unit.
  - exact us_object_list_processor_gMarioObject_prog_defs_member.
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
Qed.
