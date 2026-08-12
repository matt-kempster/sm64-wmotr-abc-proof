From LessThanOneAPress.Generated Require Import
  jp_interaction jp_save_file jp_object_collision jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_interaction_initializers_aligned :
  ProgramInitializersAligned jp_interaction.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_save_file_initializers_aligned :
  ProgramInitializersAligned jp_save_file.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_object_collision_initializers_aligned :
  ProgramInitializersAligned jp_object_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_object_list_processor_initializers_aligned :
  ProgramInitializersAligned jp_object_list_processor.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
