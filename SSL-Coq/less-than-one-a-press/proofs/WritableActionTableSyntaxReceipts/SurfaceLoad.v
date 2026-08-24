(** Cached US/JP syntax receipt for [surface_load]. *)
From LessThanOneAPress.Generated Require Import us_surface_load jp_surface_load.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_surface_load_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_surface_load.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_surface_load.prog = true.
Proof. watsc_compute_pair. Qed.
