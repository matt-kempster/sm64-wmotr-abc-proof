(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_interaction us_save_file us_object_collision us_object_list_processor.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_interaction_initializers_aligned :
  ProgramInitializersAligned us_interaction.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_save_file_initializers_aligned :
  ProgramInitializersAligned us_save_file.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_object_collision_initializers_aligned :
  ProgramInitializersAligned us_object_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_object_list_processor_initializers_aligned :
  ProgramInitializersAligned us_object_list_processor.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

