(** Focused JP [game_init] receipt for the Area-1 symbol boundary. *)

From Coq Require Import List.
From compcert Require Import AST Clight Coqlib Ctypes Globalenvs Maps.
From LessThanOneAPress.Generated Require Import jp_game_init.
From LessThanOneAPress.Proofs Require Import
  CleanedClightPrograms JPSourceSymbolTransport LinkedClightPrograms.

Theorem jp_game_init_is_area1_symbol_source_unit :
  nIn jp_game_init.prog jp_units.
Proof. now left. Qed.

Theorem jp_game_init_gControllers_defmap_checked :
  (AST.prog_defmap (Ctypes.program_of_program jp_game_init.prog)) !
      jp_game_init._gControllers =
    Some (Gvar jp_game_init.v_gControllers).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_game_init_gPlayer1Controller_defmap_checked :
  (AST.prog_defmap (Ctypes.program_of_program jp_game_init.prog)) !
      jp_game_init._gPlayer1Controller =
    Some (Gvar jp_game_init.v_gPlayer1Controller).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_official_area1_controller_storage_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_game_init._gControllers = Some block.
Proof.
  eapply (jp_source_definition_has_official_symbol jp_game_init.prog).
  - exact jp_game_init_is_area1_symbol_source_unit.
  - pose proof jp_game_init_gControllers_defmap_checked as Hreceipt.
    apply AST.in_prog_defmap in Hreceipt. exact Hreceipt.
Qed.

Theorem jp_official_player1_controller_pointer_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv jp_official_cleaned_slice)
      jp_game_init._gPlayer1Controller = Some block.
Proof.
  eapply (jp_source_definition_has_official_symbol jp_game_init.prog).
  - exact jp_game_init_is_area1_symbol_source_unit.
  - pose proof jp_game_init_gPlayer1Controller_defmap_checked as Hreceipt.
    apply AST.in_prog_defmap in Hreceipt. exact Hreceipt.
Qed.
