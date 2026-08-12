From LessThanOneAPress.Generated Require Import
  jp_mario_actions_moving jp_mario_actions_object
  jp_mario_actions_stationary jp_mario_actions_submerged jp_mario_step.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_mario_actions_moving_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_moving.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_mario_actions_object_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_object.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_stationary_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_stationary.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_submerged_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_submerged.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_step_initializers_aligned :
  ProgramInitializersAligned jp_mario_step.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
