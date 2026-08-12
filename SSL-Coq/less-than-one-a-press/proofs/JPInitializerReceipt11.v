From LessThanOneAPress.Generated Require Import
  jp_platform_displacement jp_math_util jp_surface_collision jp_surface_load.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_platform_displacement_initializers_aligned :
  ProgramInitializersAligned jp_platform_displacement.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_math_util_initializers_aligned :
  ProgramInitializersAligned jp_math_util.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_surface_collision_initializers_aligned :
  ProgramInitializersAligned jp_surface_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_surface_load_initializers_aligned :
  ProgramInitializersAligned jp_surface_load.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
