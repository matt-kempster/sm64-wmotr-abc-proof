From LessThanOneAPress.Generated Require Import jp_obj_behaviors_2.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_obj_behaviors_2_initializers_aligned :
  ProgramInitializersAligned jp_obj_behaviors_2.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
