(** Cached US/JP syntax receipt for [interaction]. *)
From LessThanOneAPress.Generated Require Import us_interaction jp_interaction.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_interaction_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_interaction.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_interaction.prog = true.
Proof. watsc_compute_pair. Qed.
