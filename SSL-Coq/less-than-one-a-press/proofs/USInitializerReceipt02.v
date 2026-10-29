(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_mario_actions_airborne us_mario_actions_automatic us_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_mario_actions_airborne_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_airborne.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_actions_automatic_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_automatic.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_actions_cutscene_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_cutscene.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

