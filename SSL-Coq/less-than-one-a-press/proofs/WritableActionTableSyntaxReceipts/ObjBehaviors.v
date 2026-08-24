(** Cached US/JP syntax receipt for [obj_behaviors]. *)
From LessThanOneAPress.Generated Require Import us_obj_behaviors jp_obj_behaviors.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_obj_behaviors_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_obj_behaviors.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_obj_behaviors.prog = true.
Proof. watsc_compute_pair. Qed.
