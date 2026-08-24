(** Cached US/JP syntax receipt for [ssl_area1_macro]. *)
From LessThanOneAPress.Generated Require Import us_ssl_area1_macro jp_ssl_area1_macro.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_ssl_area1_macro_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_ssl_area1_macro.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_ssl_area1_macro.prog = true.
Proof. watsc_compute_pair. Qed.
