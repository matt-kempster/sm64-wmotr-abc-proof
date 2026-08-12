From LessThanOneAPress.Generated Require Import
  jp_spawn_object jp_object_helpers jp_debug jp_memory jp_mario_misc.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_spawn_object_initializers_aligned :
  ProgramInitializersAligned jp_spawn_object.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_object_helpers_initializers_aligned :
  ProgramInitializersAligned jp_object_helpers.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_debug_initializers_aligned :
  ProgramInitializersAligned jp_debug.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_memory_initializers_aligned :
  ProgramInitializersAligned jp_memory.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_mario_misc_initializers_aligned :
  ProgramInitializersAligned jp_mario_misc.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
