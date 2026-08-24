(** Cached US/JP syntax receipt for [level_update]. *)
From LessThanOneAPress.Generated Require Import us_level_update jp_level_update.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_level_update_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_level_update.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_level_update.prog = true.
Proof. watsc_compute_pair. Qed.
