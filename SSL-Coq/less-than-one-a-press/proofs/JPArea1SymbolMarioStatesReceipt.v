(** One-lookup JP [gMarioStates] source receipt and symbol transport. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Maps.
From LessThanOneAPress.Generated Require Import jp_level_update.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPSourceSymbolTransport LinkedClightPrograms.

Lemma jp_level_update_is_mario_states_source_unit :
  nIn jp_level_update.prog jp_units.
Proof. unfold jp_units. do 28 right. now left. Qed.

Theorem jp_level_update_gMarioStates_defmap_checked :
  (AST.prog_defmap (Ctypes.program_of_program jp_level_update.prog)) !
      jp_level_update._gMarioStates =
    Some (Gvar jp_level_update.v_gMarioStates).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_official_area1_state_storage_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_level_update._gMarioStates = Some block.
Proof.
  eapply (jp_source_definition_has_official_symbol jp_level_update.prog).
  - exact jp_level_update_is_mario_states_source_unit.
  - pose proof jp_level_update_gMarioStates_defmap_checked as H.
    apply AST.in_prog_defmap in H. exact H.
Qed.
