(** Cached US/JP syntax receipt for [platform_displacement]. *)
From LessThanOneAPress.Generated Require Import us_platform_displacement jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_platform_displacement_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_platform_displacement.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_platform_displacement.prog = true.
Proof. watsc_compute_pair. Qed.
