(** Cached US/JP syntax receipt for [spawn_object]. *)
From LessThanOneAPress.Generated Require Import us_spawn_object jp_spawn_object.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_spawn_object_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_spawn_object.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_spawn_object.prog = true.
Proof. watsc_compute_pair. Qed.
