From LessThanOneAPress.Generated Require Import
  jp_behavior_data jp_area jp_level_update.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_behavior_data_initializers_aligned :
  ProgramInitializersAligned jp_behavior_data.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_area_initializers_aligned :
  ProgramInitializersAligned jp_area.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_level_update_initializers_aligned :
  ProgramInitializersAligned jp_level_update.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
