(** Cached US/JP syntax receipt for [object_list_processor]. *)
From LessThanOneAPress.Generated Require Import us_object_list_processor jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_object_list_processor_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_object_list_processor.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_object_list_processor.prog = true.
Proof. watsc_compute_pair. Qed.
