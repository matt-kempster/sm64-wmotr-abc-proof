(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_macro_special_objects us_ssl_script us_ssl_area1_macro us_ssl_area2_macro us_ssl_collision us_bobomb_animation_data.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_macro_special_objects_initializers_aligned :
  ProgramInitializersAligned us_macro_special_objects.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_ssl_script_initializers_aligned :
  ProgramInitializersAligned us_ssl_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_ssl_area1_macro_initializers_aligned :
  ProgramInitializersAligned us_ssl_area1_macro.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_ssl_area2_macro_initializers_aligned :
  ProgramInitializersAligned us_ssl_area2_macro.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_ssl_collision_initializers_aligned :
  ProgramInitializersAligned us_ssl_collision.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_bobomb_animation_data_initializers_aligned :
  ProgramInitializersAligned us_bobomb_animation_data.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

