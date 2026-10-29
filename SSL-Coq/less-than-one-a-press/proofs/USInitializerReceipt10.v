(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_behavior_data us_area us_level_update.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_behavior_data_initializers_aligned :
  ProgramInitializersAligned us_behavior_data.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_area_initializers_aligned :
  ProgramInitializersAligned us_area.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_level_update_initializers_aligned :
  ProgramInitializersAligned us_level_update.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

