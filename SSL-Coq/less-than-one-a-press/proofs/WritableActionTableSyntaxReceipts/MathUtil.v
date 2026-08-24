(** Cached US/JP syntax receipt for [math_util]. *)
From LessThanOneAPress.Generated Require Import us_math_util jp_math_util.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_math_util_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_math_util.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_math_util.prog = true.
Proof. watsc_compute_pair. Qed.
