From LessThanOneAPress.Generated Require Import jp_behavior_actions.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_behavior_actions_initializers_aligned :
  ProgramInitializersAligned jp_behavior_actions.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
