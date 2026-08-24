(** Cached US/JP syntax receipt for [save_file]. *)
From LessThanOneAPress.Generated Require Import us_save_file jp_save_file.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_save_file_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_save_file.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_save_file.prog = true.
Proof. watsc_compute_pair. Qed.
