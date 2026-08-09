(** Exact finite receipt for the next frame of a prepared Area-1 fixture.

    [instrumentation/area1-long-jump-next-frame/run.sh] prepares a timer-3
    [ACT_LONG_JUMP_LAND] state, executes one authentic US or JP retail frame,
    and then executes its immediate successor without another memory write.
    The four quarter-step records below are from that successor (frame G).

    This is deliberately only a prepared-fixture certificate.  It does not
    prove that the prepared state is reachable from a clean entry, that the
    long jump has no-A provenance, or that this emulator execution refines a
    linked CompCert/Clight execution.  The 100-coin candidate-star words below
    are supplied by the separate finite orbit model; they were not captured
    by this ground-step probe. *)

From Coq Require Import List NArith ZArith.

Import ListNotations.
Local Open Scope N_scope.

Inductive A1LJQGVersion : Type :=
| A1LJQGUS
| A1LJQGJP.

(** Floating-point fields are raw IEEE-754 binary32 words represented as
    unsigned naturals.  Pointer zero is NULL. *)
Record A1LJQGQuarterReceipt : Type := {
  a1ljqg_index : N;
  a1ljqg_intended_x_bits : N;
  a1ljqg_intended_y_bits : N;
  a1ljqg_intended_z_bits : N;
  a1ljqg_lower_wall_ptr : N;
  a1ljqg_upper_wall_ptr : N;
  a1ljqg_floor_height_bits : N;
  a1ljqg_floor_type : N;
  a1ljqg_floor_flags : N;
  a1ljqg_floor_owner_ptr : N;
  a1ljqg_ceil_ptr : N;
  a1ljqg_ceil_height_bits : N;
  a1ljqg_raw_x_bits : N;
  a1ljqg_raw_y_bits : N;
  a1ljqg_raw_z_bits : N
}.

Definition a1ljqg_x_5760_bits : N := 1169424384. (* 0x45b40000 *)
Definition a1ljqg_ceil_20000_bits : N := 1184645120. (* 0x469c4000 *)

Definition a1ljqg_q1 : A1LJQGQuarterReceipt :=
  {| a1ljqg_index := 1;
     a1ljqg_intended_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_intended_y_bits := 3237756945; (* 0xc0fc4011 *)
     a1ljqg_intended_z_bits := 1167687424; (* 0x45997f00 *)
     a1ljqg_lower_wall_ptr := 0;
     a1ljqg_upper_wall_ptr := 0;
     a1ljqg_floor_height_bits := 3240713873; (* 0xc1295e91 *)
     a1ljqg_floor_type := 37;
     a1ljqg_floor_flags := 0;
     a1ljqg_floor_owner_ptr := 0;
     a1ljqg_ceil_ptr := 0;
     a1ljqg_ceil_height_bits := a1ljqg_ceil_20000_bits;
     a1ljqg_raw_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_raw_y_bits := 3240713873;
     a1ljqg_raw_z_bits := 1167687424 |}.

Definition a1ljqg_q2 : A1LJQGQuarterReceipt :=
  {| a1ljqg_index := 2;
     a1ljqg_intended_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_intended_y_bits := 3240713873; (* 0xc1295e91 *)
     a1ljqg_intended_z_bits := 1167713397; (* 0x4599e475 *)
     a1ljqg_lower_wall_ptr := 0;
     a1ljqg_upper_wall_ptr := 0;
     a1ljqg_floor_height_bits := 3243783970; (* 0xc1583722 *)
     a1ljqg_floor_type := 37;
     a1ljqg_floor_flags := 0;
     a1ljqg_floor_owner_ptr := 0;
     a1ljqg_ceil_ptr := 0;
     a1ljqg_ceil_height_bits := a1ljqg_ceil_20000_bits;
     a1ljqg_raw_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_raw_y_bits := 3243783970;
     a1ljqg_raw_z_bits := 1167713397 |}.

Definition a1ljqg_q3 : A1LJQGQuarterReceipt :=
  {| a1ljqg_index := 3;
     a1ljqg_intended_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_intended_y_bits := 3243783970; (* 0xc1583722 *)
     a1ljqg_intended_z_bits := 1167739370; (* 0x459a49ea *)
     a1ljqg_lower_wall_ptr := 0;
     a1ljqg_upper_wall_ptr := 0;
     a1ljqg_floor_height_bits := 3246622747; (* 0xc183881b *)
     a1ljqg_floor_type := 37;
     a1ljqg_floor_flags := 0;
     a1ljqg_floor_owner_ptr := 0;
     a1ljqg_ceil_ptr := 0;
     a1ljqg_ceil_height_bits := a1ljqg_ceil_20000_bits;
     a1ljqg_raw_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_raw_y_bits := 3246622747;
     a1ljqg_raw_z_bits := 1167739370 |}.

Definition a1ljqg_q4 : A1LJQGQuarterReceipt :=
  {| a1ljqg_index := 4;
     a1ljqg_intended_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_intended_y_bits := 3246622747; (* 0xc183881b *)
     a1ljqg_intended_z_bits := 1167765343; (* 0x459aaf5f *)
     a1ljqg_lower_wall_ptr := 0;
     a1ljqg_upper_wall_ptr := 0;
     a1ljqg_floor_height_bits := 3248039710; (* 0xc199271e *)
     a1ljqg_floor_type := 37;
     a1ljqg_floor_flags := 0;
     a1ljqg_floor_owner_ptr := 0;
     a1ljqg_ceil_ptr := 0;
     a1ljqg_ceil_height_bits := a1ljqg_ceil_20000_bits;
     a1ljqg_raw_x_bits := a1ljqg_x_5760_bits;
     a1ljqg_raw_y_bits := 3248039710;
     a1ljqg_raw_z_bits := 1167765343 |}.

Definition a1ljqg_four_quarters : list A1LJQGQuarterReceipt :=
  [a1ljqg_q1; a1ljqg_q2; a1ljqg_q3; a1ljqg_q4].

Definition a1ljqg_static_shallow (q : A1LJQGQuarterReceipt) : Prop :=
  a1ljqg_floor_type q = 37 /\
  a1ljqg_floor_flags q = 0 /\
  a1ljqg_floor_owner_ptr q = 0.

Definition a1ljqg_query_clear (q : A1LJQGQuarterReceipt) : Prop :=
  a1ljqg_lower_wall_ptr q = 0 /\
  a1ljqg_upper_wall_ptr q = 0 /\
  a1ljqg_ceil_ptr q = 0 /\
  a1ljqg_ceil_height_bits q = a1ljqg_ceil_20000_bits.

Theorem a1ljqg_receipt_has_exactly_four_quarters :
  length a1ljqg_four_quarters = 4%nat /\
  map a1ljqg_index a1ljqg_four_quarters = [1; 2; 3; 4].
Proof. vm_compute. split; reflexivity. Qed.

Theorem a1ljqg_every_selected_floor_is_static_shallow :
  Forall a1ljqg_static_shallow a1ljqg_four_quarters.
Proof. vm_compute; repeat constructor. Qed.

Theorem a1ljqg_every_wall_and_ceiling_query_is_clear :
  Forall a1ljqg_query_clear a1ljqg_four_quarters.
Proof. vm_compute; repeat constructor. Qed.

Theorem a1ljqg_exact_committed_position_words :
  map (fun q =>
    (a1ljqg_raw_x_bits q, a1ljqg_raw_y_bits q,
      a1ljqg_raw_z_bits q)) a1ljqg_four_quarters =
  [(1169424384, 3240713873, 1167687424);
   (1169424384, 3243783970, 1167713397);
   (1169424384, 3246622747, 1167739370);
   (1169424384, 3248039710, 1167765343)].
Proof. reflexivity. Qed.

Definition a1ljqg_selected_floor_pointer (version : A1LJQGVersion) : N :=
  match version with
  | A1LJQGUS => 2149151216 (* 0x801971f0 *)
  | A1LJQGJP => 2149139312 (* 0x80194370 *)
  end.

Theorem a1ljqg_selected_floor_pointer_is_nonnull :
  forall version, a1ljqg_selected_floor_pointer version <> 0.
Proof. intros []; discriminate. Qed.

Record A1LJQGRunReceipt : Type := {
  a1ljqg_run_version : A1LJQGVersion;
  a1ljqg_action : N;
  a1ljqg_action_timer : N;
  a1ljqg_input_bits : N;
  a1ljqg_button_down_bits : N;
  a1ljqg_button_pressed_bits : N;
  a1ljqg_final_raw_x_bits : N;
  a1ljqg_final_raw_y_bits : N;
  a1ljqg_final_raw_z_bits : N;
  a1ljqg_final_graphics_x_bits : N;
  a1ljqg_final_graphics_y_bits : N;
  a1ljqg_final_graphics_z_bits : N;
  a1ljqg_quicksand_depth_bits : N;
  a1ljqg_final_wall_ptr : N;
  a1ljqg_final_ceil_ptr : N;
  a1ljqg_final_floor_ptr : N;
  a1ljqg_final_platform_ptr : N;
  a1ljqg_total_query_count_per_kind : N;
  a1ljqg_total_commit_count : N;
  a1ljqg_a_pressed_poll_count : N;
  a1ljqg_a_down_poll_count : N
}.

Definition a1ljqg_run_receipt (version : A1LJQGVersion) :
    A1LJQGRunReceipt :=
  {| a1ljqg_run_version := version;
     a1ljqg_action := 1145; (* 0x00000479 *)
     a1ljqg_action_timer := 5;
     a1ljqg_input_bits := 32; (* INPUT_UNKNOWN_5: 0x0020 *)
     a1ljqg_button_down_bits := 0;
     a1ljqg_button_pressed_bits := 0;
     a1ljqg_final_raw_x_bits := 1169424384;
     a1ljqg_final_raw_y_bits := 3248039710; (* 0xc199271e *)
     a1ljqg_final_raw_z_bits := 1167765343;
     a1ljqg_final_graphics_x_bits := 1169424384;
     a1ljqg_final_graphics_y_bits := 3246650347; (* 0xc183f3eb *)
     a1ljqg_final_graphics_z_bits := 1167765343;
     a1ljqg_quicksand_depth_bits := 3223951770; (* 0xc029999a *)
     a1ljqg_final_wall_ptr := 0;
     a1ljqg_final_ceil_ptr := 0;
     a1ljqg_final_floor_ptr := a1ljqg_selected_floor_pointer version;
     a1ljqg_final_platform_ptr := 0;
     a1ljqg_total_query_count_per_kind := 8;
     a1ljqg_total_commit_count := 8;
     a1ljqg_a_pressed_poll_count := 0;
     a1ljqg_a_down_poll_count := 0 |}.

Definition a1ljqg_no_a_receipt (r : A1LJQGRunReceipt) : Prop :=
  N.land (a1ljqg_input_bits r) 2 = 0 /\
  N.land (a1ljqg_button_down_bits r) 32768 = 0 /\
  N.land (a1ljqg_button_pressed_bits r) 32768 = 0 /\
  a1ljqg_a_pressed_poll_count r = 0 /\
  a1ljqg_a_down_poll_count r = 0.

Definition a1ljqg_run_well_formed (r : A1LJQGRunReceipt) : Prop :=
  a1ljqg_action r = 1145 /\
  a1ljqg_action_timer r = 5 /\
  a1ljqg_final_wall_ptr r = 0 /\
  a1ljqg_final_ceil_ptr r = 0 /\
  a1ljqg_final_floor_ptr r =
    a1ljqg_selected_floor_pointer (a1ljqg_run_version r) /\
  a1ljqg_final_platform_ptr r = 0 /\
  a1ljqg_total_query_count_per_kind r = 8 /\
  a1ljqg_total_commit_count r = 8 /\
  a1ljqg_no_a_receipt r.

Theorem a1ljqg_us_and_jp_run_receipts_are_exact_and_well_formed :
  map
    (fun version =>
      (version, a1ljqg_final_floor_ptr (a1ljqg_run_receipt version),
       a1ljqg_final_raw_y_bits (a1ljqg_run_receipt version),
       a1ljqg_final_graphics_y_bits (a1ljqg_run_receipt version),
       a1ljqg_quicksand_depth_bits (a1ljqg_run_receipt version)))
    [A1LJQGUS; A1LJQGJP] =
  [(A1LJQGUS, 2149151216, 3248039710, 3246650347, 3223951770);
   (A1LJQGJP, 2149139312, 3248039710, 3246650347, 3223951770)] /\
  Forall
    (fun version => a1ljqg_run_well_formed (a1ljqg_run_receipt version))
    [A1LJQGUS; A1LJQGJP].
Proof. vm_compute; repeat constructor. Qed.

(** Raw-word-backed vertical-separation calculation.

    Both Mario Y words have exponent field 131, hence denominator 2^19;
    both prepared-star words have exponent field 134, hence denominator
    2^16.  Multiplying each star significand by 8 puts every exact decoded
    value over the common positive denominator 2^19. *)
Definition a1ljqg_binary32_sign (word : N) : N :=
  N.land (N.shiftr word 31) 1.

Definition a1ljqg_binary32_exponent (word : N) : N :=
  N.land (N.shiftr word 23) 255.

Definition a1ljqg_binary32_fraction (word : N) : N :=
  N.land word 8388607.

Definition a1ljqg_binary32_significand (word : N) : N :=
  8388608 + a1ljqg_binary32_fraction word.

Definition a1ljqg_frame_g_raw_y_word : N := 3248039710. (* 0xc199271e *)
Definition a1ljqg_frame_g_graphics_y_word : N := 3246650347. (* 0xc183f3eb *)
Definition a1ljqg_prepared_star_home_y_word : N := 1131552255. (* 0x43721dff *)
Definition a1ljqg_prepared_star_first_hitbox_y_word : N :=
  1131224575. (* 0x436d1dff *)

Theorem a1ljqg_prepared_vertical_words_decode_exactly :
  (a1ljqg_binary32_sign a1ljqg_frame_g_raw_y_word,
   a1ljqg_binary32_exponent a1ljqg_frame_g_raw_y_word,
   a1ljqg_binary32_significand a1ljqg_frame_g_raw_y_word) =
    (1, 131, 10037022) /\
  (a1ljqg_binary32_sign a1ljqg_frame_g_graphics_y_word,
   a1ljqg_binary32_exponent a1ljqg_frame_g_graphics_y_word,
   a1ljqg_binary32_significand a1ljqg_frame_g_graphics_y_word) =
    (1, 131, 8647659) /\
  (a1ljqg_binary32_sign a1ljqg_prepared_star_home_y_word,
   a1ljqg_binary32_exponent a1ljqg_prepared_star_home_y_word,
   a1ljqg_binary32_significand a1ljqg_prepared_star_home_y_word) =
    (0, 134, 15867391) /\
  (a1ljqg_binary32_sign a1ljqg_prepared_star_first_hitbox_y_word,
   a1ljqg_binary32_exponent a1ljqg_prepared_star_first_hitbox_y_word,
   a1ljqg_binary32_significand
     a1ljqg_prepared_star_first_hitbox_y_word) =
    (0, 134, 15539711).
Proof. vm_compute; repeat split; reflexivity. Qed.

Local Open Scope Z_scope.

Definition a1ljqg_vertical_denominator : Z := 524288. (* 2^19 *)

Definition a1ljqg_frame_g_raw_y_numerator : Z :=
  - Z.of_N (a1ljqg_binary32_significand a1ljqg_frame_g_raw_y_word).

Definition a1ljqg_frame_g_graphics_y_numerator : Z :=
  - Z.of_N
      (a1ljqg_binary32_significand a1ljqg_frame_g_graphics_y_word).

Definition a1ljqg_prepared_star_home_y_numerator : Z :=
  8 * Z.of_N
    (a1ljqg_binary32_significand a1ljqg_prepared_star_home_y_word).

Definition a1ljqg_prepared_star_first_hitbox_y_numerator : Z :=
  8 * Z.of_N (a1ljqg_binary32_significand
    a1ljqg_prepared_star_first_hitbox_y_word).

Theorem a1ljqg_prepared_star_first_hitbox_is_home_minus_five :
  a1ljqg_prepared_star_home_y_numerator -
    a1ljqg_prepared_star_first_hitbox_y_numerator =
  5 * a1ljqg_vertical_denominator.
Proof. vm_compute; reflexivity. Qed.

(** Exact raw-word interpretation of
    [frame-G MarioState/Object Y + 160 < prepared star first-hitbox Y]. *)
Theorem a1ljqg_prepared_raw_mario_top_is_below_star_first_hitbox :
  a1ljqg_frame_g_raw_y_numerator +
      160 * a1ljqg_vertical_denominator <
    a1ljqg_prepared_star_first_hitbox_y_numerator.
Proof. vm_compute; reflexivity. Qed.

(** The strict raw-vertical margin is more than 96 units. *)
Theorem a1ljqg_prepared_raw_vertical_margin_exceeds_96 :
  a1ljqg_frame_g_raw_y_numerator +
      (160 + 96) * a1ljqg_vertical_denominator <
    a1ljqg_prepared_star_first_hitbox_y_numerator.
Proof. vm_compute; reflexivity. Qed.

(** Even the higher Graphics Y sample plus 160 remains below the supplied
    first-hitbox Y.  This is a separation fact about this prepared fixture,
    not a proof that object collision reads Graphics Y. *)
Theorem a1ljqg_prepared_graphics_top_is_below_star_first_hitbox :
  a1ljqg_frame_g_graphics_y_numerator +
      160 * a1ljqg_vertical_denominator <
    a1ljqg_prepared_star_first_hitbox_y_numerator.
Proof. vm_compute; reflexivity. Qed.

Theorem a1ljqg_prepared_raw_vertical_gap_numerator_is_exact :
  a1ljqg_prepared_star_first_hitbox_y_numerator -
    (a1ljqg_frame_g_raw_y_numerator +
      160 * a1ljqg_vertical_denominator) = 50468630.
Proof. vm_compute; reflexivity. Qed.
