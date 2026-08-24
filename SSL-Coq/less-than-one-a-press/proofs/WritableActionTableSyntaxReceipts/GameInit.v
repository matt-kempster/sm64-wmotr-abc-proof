(** Cached US/JP syntax receipt for [game_init]. *)
From LessThanOneAPress.Generated Require Import us_game_init jp_game_init.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_game_init_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_game_init.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_game_init.prog = true.
Proof. watsc_compute_pair. Qed.
