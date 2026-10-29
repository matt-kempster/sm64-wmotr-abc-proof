(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_platform_displacement us_math_util us_surface_collision us_surface_load.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_platform_displacement_initializers_aligned :
  ProgramInitializersAligned us_platform_displacement.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_math_util_initializers_aligned :
  ProgramInitializersAligned us_math_util.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_surface_collision_initializers_aligned :
  ProgramInitializersAligned us_surface_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_surface_load_initializers_aligned :
  ProgramInitializersAligned us_surface_load.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

