(** Cached US/JP syntax receipt for [ssl_script]. *)
From LessThanOneAPress.Generated Require Import us_ssl_script jp_ssl_script.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_ssl_script_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_ssl_script.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_ssl_script.prog = true.
Proof. watsc_compute_pair. Qed.
