(** Cached US/JP syntax receipt for [debug]. *)
From LessThanOneAPress.Generated Require Import us_debug jp_debug.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_debug_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_debug.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_debug.prog = true.
Proof. watsc_compute_pair. Qed.
