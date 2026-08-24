(** Cached US/JP syntax receipt for [graph_node]. *)
From LessThanOneAPress.Generated Require Import us_graph_node jp_graph_node.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_graph_node_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_graph_node.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_graph_node.prog = true.
Proof. watsc_compute_pair. Qed.
