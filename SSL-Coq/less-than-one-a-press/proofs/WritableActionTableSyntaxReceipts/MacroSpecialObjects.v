(** Cached US/JP syntax receipt for [macro_special_objects]. *)
From LessThanOneAPress.Generated Require Import us_macro_special_objects jp_macro_special_objects.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_macro_special_objects_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_macro_special_objects.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_macro_special_objects.prog = true.
Proof. watsc_compute_pair. Qed.
