(** Cached US/JP syntax receipt for [mario_actions_cutscene]. *)
From LessThanOneAPress.Generated Require Import us_mario_actions_cutscene jp_mario_actions_cutscene.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_mario_actions_cutscene_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_mario_actions_cutscene.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_mario_actions_cutscene.prog = true.
Proof. watsc_compute_pair. Qed.
