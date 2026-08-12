From LessThanOneAPress.Generated Require Import
  jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_mario_actions_airborne_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_airborne.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_mario_actions_automatic_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_automatic.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_actions_cutscene_initializers_aligned :
  ProgramInitializersAligned jp_mario_actions_cutscene.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
