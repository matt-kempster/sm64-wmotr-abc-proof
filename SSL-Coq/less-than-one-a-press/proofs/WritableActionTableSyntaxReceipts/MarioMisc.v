(** Cached US/JP syntax receipt for [mario_misc]. *)
From LessThanOneAPress.Generated Require Import us_mario_misc jp_mario_misc.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_mario_misc_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_mario_misc.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_mario_misc.prog = true.
Proof. watsc_compute_pair. Qed.
