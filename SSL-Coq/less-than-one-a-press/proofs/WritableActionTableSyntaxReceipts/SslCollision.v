(** Cached US/JP syntax receipt for [ssl_collision]. *)
From LessThanOneAPress.Generated Require Import us_ssl_collision jp_ssl_collision
  us_bobomb_animation_data jp_bobomb_animation_data.
From LessThanOneAPress.Proofs Require Import WritableActionTableSyntaxBase.

Theorem watsc_ssl_collision_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_ssl_collision.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_ssl_collision.prog = true.
Proof. watsc_compute_pair. Qed.

(** Data-only actor input appended after the collision input. *)
Theorem watsc_bobomb_animation_data_unit_receipt :
  watsc_program_access_safe watsc_us_table_ids us_bobomb_animation_data.prog = true /\
  watsc_program_access_safe watsc_jp_table_ids jp_bobomb_animation_data.prog = true.
Proof. watsc_compute_pair. Qed.
