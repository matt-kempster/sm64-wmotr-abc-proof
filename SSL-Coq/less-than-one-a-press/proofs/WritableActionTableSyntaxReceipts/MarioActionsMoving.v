(** Cached US/JP syntax receipt for [mario_actions_moving]. *)
From LessThanOneAPress.Generated Require Import us_mario_actions_moving jp_mario_actions_moving.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_mario_actions_moving_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_mario_actions_moving.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_mario_actions_moving.prog = true.
Proof. watsc_compute_pair. Qed.
