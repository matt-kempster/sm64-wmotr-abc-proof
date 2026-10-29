(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_game_init us_mario.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_game_init_initializers_aligned :
  ProgramInitializersAligned us_game_init.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_initializers_aligned :
  ProgramInitializersAligned us_mario.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

