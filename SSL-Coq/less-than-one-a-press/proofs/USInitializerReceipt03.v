(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_mario_actions_moving us_mario_actions_object us_mario_actions_stationary us_mario_actions_submerged us_mario_step.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_mario_actions_moving_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_moving.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_actions_object_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_object.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_actions_stationary_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_stationary.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_actions_submerged_initializers_aligned :
  ProgramInitializersAligned us_mario_actions_submerged.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_step_initializers_aligned :
  ProgramInitializersAligned us_mario_step.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

