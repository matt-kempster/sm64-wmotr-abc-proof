From LessThanOneAPress.Generated Require Import
  jp_behavior_script jp_level_script jp_graph_node jp_rendering_graph_node.
From LessThanOneAPress.Proofs Require Import ClightInitialMemoryFacts.

Theorem jp_behavior_script_initializers_aligned :
  ProgramInitializersAligned jp_behavior_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
Theorem jp_level_script_initializers_aligned :
  ProgramInitializersAligned jp_level_script.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_graph_node_initializers_aligned :
  ProgramInitializersAligned jp_graph_node.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.

Theorem jp_rendering_graph_node_initializers_aligned :
  ProgramInitializersAligned jp_rendering_graph_node.prog.
Proof. apply program_initializers_alignment_ok_sound. vm_compute. reflexivity. Qed.
