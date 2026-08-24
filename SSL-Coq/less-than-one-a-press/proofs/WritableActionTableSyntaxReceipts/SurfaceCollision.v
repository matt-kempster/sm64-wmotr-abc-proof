(** Cached US/JP syntax receipt for [surface_collision]. *)
From LessThanOneAPress.Generated Require Import us_surface_collision jp_surface_collision.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_surface_collision_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_surface_collision.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_surface_collision.prog = true.
Proof. watsc_compute_pair. Qed.
