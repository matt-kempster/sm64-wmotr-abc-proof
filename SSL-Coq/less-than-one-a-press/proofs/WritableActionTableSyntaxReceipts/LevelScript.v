(** Cached US/JP syntax receipt for [level_script]. *)
From LessThanOneAPress.Generated Require Import us_level_script jp_level_script.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_level_script_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_level_script.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_level_script.prog = true.
Proof. watsc_compute_pair. Qed.
