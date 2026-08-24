(** Cached US/JP syntax receipt for [object_collision]. *)
From LessThanOneAPress.Generated Require Import us_object_collision jp_object_collision.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_object_collision_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_object_collision.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_object_collision.prog = true.
Proof. watsc_compute_pair. Qed.
