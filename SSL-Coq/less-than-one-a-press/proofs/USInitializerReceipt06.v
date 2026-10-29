(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_spawn_object us_object_helpers us_debug us_memory us_mario_misc.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_spawn_object_initializers_aligned :
  ProgramInitializersAligned us_spawn_object.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_object_helpers_initializers_aligned :
  ProgramInitializersAligned us_object_helpers.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_debug_initializers_aligned :
  ProgramInitializersAligned us_debug.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_memory_initializers_aligned :
  ProgramInitializersAligned us_memory.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_mario_misc_initializers_aligned :
  ProgramInitializersAligned us_mario_misc.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

