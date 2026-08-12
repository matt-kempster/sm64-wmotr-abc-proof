(** One-lookup JP [gFreeObjectList] source receipt and symbol transport. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Maps.
From LessThanOneAPress.Generated Require Import jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPSourceSymbolTransport LinkedClightPrograms.

Lemma jp_object_list_processor_is_free_object_list_source_unit :
  nIn jp_object_list_processor.prog jp_units.
Proof. unfold jp_units. do 13 right. now left. Qed.

Theorem jp_object_list_processor_gFreeObjectList_defmap_checked :
  (AST.prog_defmap
      (Ctypes.program_of_program jp_object_list_processor.prog)) !
      jp_object_list_processor._gFreeObjectList =
    Some (Gvar jp_object_list_processor.v_gFreeObjectList).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_official_area1_free_list_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_object_list_processor._gFreeObjectList = Some block.
Proof.
  eapply (jp_source_definition_has_official_symbol
    jp_object_list_processor.prog).
  - exact jp_object_list_processor_is_free_object_list_source_unit.
  - pose proof jp_object_list_processor_gFreeObjectList_defmap_checked as H.
    apply AST.in_prog_defmap in H. exact H.
Qed.
