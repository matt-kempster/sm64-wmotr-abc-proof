(** Cached US/JP syntax receipt for [mario_step]. *)
From LessThanOneAPress.Generated Require Import us_mario_step jp_mario_step.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_mario_step_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_mario_step.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_mario_step.prog = true.
Proof. watsc_compute_pair. Qed.
