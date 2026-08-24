(** Cached US/JP syntax receipt for [behavior_actions]. *)
From LessThanOneAPress.Generated Require Import us_behavior_actions jp_behavior_actions.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_behavior_actions_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_behavior_actions.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_behavior_actions.prog = true.
Proof. watsc_compute_pair. Qed.
