(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_behavior_actions.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_behavior_actions_initializers_aligned :
  ProgramInitializersAligned us_behavior_actions.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

