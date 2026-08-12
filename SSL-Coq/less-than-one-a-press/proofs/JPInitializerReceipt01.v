From LessThanOneAPress.Generated Require Import jp_game_init jp_mario.
From LessThanOneAPress.Proofs Require Import
  ClightInitialMemoryFacts LinkedClightPrograms.

From compcert Require Import AST Clight Coqlib Ctypes Maps.

Theorem jp_game_init_initializers_aligned :
  ProgramInitializersAligned jp_game_init.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_initializers_aligned :
  ProgramInitializersAligned jp_mario.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_game_init_thread5_game_loop_defmap_checked :
  (AST.prog_defmap (Ctypes.program_of_program jp_game_init.prog)) !
      jp_game_init._thread5_game_loop =
    Some (Gfun (Internal jp_game_init.f_thread5_game_loop)).
Proof. vm_compute. reflexivity. Qed.

Theorem jp_game_init_is_first_jp_unit :
  nIn jp_game_init.prog jp_units.
Proof. now left. Qed.
