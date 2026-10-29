(** Bounded initializer-alignment checks for actual generated US units. *)

From LessThanOneAPress.Generated Require Import
  us_behavior_script us_level_script us_graph_node us_rendering_graph_node.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem us_behavior_script_initializers_aligned :
  ProgramInitializersAligned us_behavior_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_level_script_initializers_aligned :
  ProgramInitializersAligned us_level_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_graph_node_initializers_aligned :
  ProgramInitializersAligned us_graph_node.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem us_rendering_graph_node_initializers_aligned :
  ProgramInitializersAligned us_rendering_graph_node.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

