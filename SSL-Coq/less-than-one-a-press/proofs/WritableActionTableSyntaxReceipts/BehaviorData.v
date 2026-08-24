(** Cached US/JP syntax receipt for [behavior_data]. *)
From LessThanOneAPress.Generated Require Import us_behavior_data jp_behavior_data.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_behavior_data_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_behavior_data.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_behavior_data.prog = true.
Proof. watsc_compute_pair. Qed.
