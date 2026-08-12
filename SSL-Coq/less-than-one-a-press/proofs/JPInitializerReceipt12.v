From LessThanOneAPress.Generated Require Import
  jp_macro_special_objects jp_ssl_script jp_ssl_area1_macro
  jp_ssl_area2_macro jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_macro_special_objects_initializers_aligned :
  ProgramInitializersAligned jp_macro_special_objects.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_ssl_script_initializers_aligned :
  ProgramInitializersAligned jp_ssl_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_ssl_area1_macro_initializers_aligned :
  ProgramInitializersAligned jp_ssl_area1_macro.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_ssl_area2_macro_initializers_aligned :
  ProgramInitializersAligned jp_ssl_area2_macro.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_ssl_collision_initializers_aligned :
  ProgramInitializersAligned jp_ssl_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
