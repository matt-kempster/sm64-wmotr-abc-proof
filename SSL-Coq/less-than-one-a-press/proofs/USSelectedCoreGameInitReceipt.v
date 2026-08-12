(** Repaired-program symbols for the two game-init core globals. *)

From compcert Require Import AST Clight Coqlib Ctypes Globalenvs.
From LessThanOneAPress.Generated Require Import us_game_init.
From LessThanOneAPress.Proofs Require Import
  LinkedClightPrograms NormalizedClightPrograms SourceUnitRepairedSymbol
  USSelectedCoreGameInitNthReceipt
  USViewportRepairedProgramSelection USWholeASTTagRepair.

Lemma us_game_init_is_core_symbol_source_unit :
  nIn us_game_init.prog us_units.
Proof. now left. Qed.

Theorem us_repaired_controller_storage_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_game_init._gControllers = Some block.
Proof.
  eapply source_unit_definition_has_normalized_repaired_symbol
    with (unit := us_game_init.prog)
         (definition := Gvar us_game_init.v_gControllers).
  - exact us_game_init_is_core_symbol_source_unit.
  - exact us_game_init_gControllers_prog_defs_member.
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
Qed.

Theorem us_repaired_player1_controller_pointer_symbol_exists :
  exists block,
    Genv.find_symbol (Clight.globalenv us_viewport_repaired_program)
      us_game_init._gPlayer1Controller = Some block.
Proof.
  eapply source_unit_definition_has_normalized_repaired_symbol
    with (unit := us_game_init.prog)
         (definition := Gvar us_game_init.v_gPlayer1Controller).
  - exact us_game_init_is_core_symbol_source_unit.
  - exact us_game_init_gPlayer1Controller_prog_defs_member.
  - rewrite us_viewport_repaired_program_definitions_checked.
    reflexivity.
Qed.
