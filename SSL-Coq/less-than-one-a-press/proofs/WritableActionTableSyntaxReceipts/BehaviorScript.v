(** Cached US/JP syntax receipt for [behavior_script]. *)
From LessThanOneAPress.Generated Require Import us_behavior_script jp_behavior_script.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_behavior_script_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_behavior_script.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_behavior_script.prog = true.
Proof. watsc_compute_pair. Qed.
