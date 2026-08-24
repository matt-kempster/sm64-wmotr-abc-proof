(** Cached US/JP syntax receipt for [mario]. *)
From LessThanOneAPress.Generated Require Import us_mario jp_mario.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_mario_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_mario.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_mario.prog = true.
Proof. watsc_compute_pair. Qed.
