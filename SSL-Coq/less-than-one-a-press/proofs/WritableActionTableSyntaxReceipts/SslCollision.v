(** Cached US/JP syntax receipt for [ssl_collision]. *)
From LessThanOneAPress.Generated Require Import us_ssl_collision jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_ssl_collision_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_ssl_collision.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_ssl_collision.prog = true.
Proof. watsc_compute_pair. Qed.
