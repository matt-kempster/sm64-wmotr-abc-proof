(** Cached US/JP syntax receipt for [area]. *)
From LessThanOneAPress.Generated Require Import us_area jp_area.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_area_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_area.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_area.prog = true.
Proof. watsc_compute_pair. Qed.
