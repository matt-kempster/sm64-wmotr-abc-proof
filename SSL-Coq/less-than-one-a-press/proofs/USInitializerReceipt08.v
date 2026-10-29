(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_obj_behaviors_2.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_obj_behaviors_2_initializers_aligned :
  ProgramInitializersAligned us_obj_behaviors_2.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

