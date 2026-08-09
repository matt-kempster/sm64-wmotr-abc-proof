(** Exact finite receipt for the prepared Area-1 long-jump landing probe.

    [instrumentation/area1-long-jump-crossing/run.sh] executes authentic US
    and JP ROMs in the pure interpreter and installs instruction breakpoints
    at the matching retail [perform_ground_quarter_step] query/commit sites.
    The transparent data below is the version-independent semantic projection
    of all four observed runs (US/JP, pre-action timer 3/4).

    This module proves consequences of that finite receipt.  It does not turn
    an emulator trace into a CompCert execution, prove that the injected
    prestate is reachable from a clean entry, prove no-A long-jump provenance,
    or supply the later no-exit-star/dialog bridge.  Those remain separate
    live-execution obligations. *)

From Coq Require Import List NArith.

Import ListNotations.
Local Open Scope N_scope.

Inductive A1LJQRetailTraceVersion : Type :=
| A1LJQTraceUS
| A1LJQTraceJP.

(** All floating-point fields are raw IEEE-754 binary32 words represented as
    unsigned naturals.  Pointer zero is NULL. *)
Record A1LJQQuarterReceipt : Type := {
  a1ljqrt_index : N;
  a1ljqrt_intended_x_bits : N;
  a1ljqrt_intended_y_bits : N;
  a1ljqrt_intended_z_bits : N;
  a1ljqrt_lower_wall_ptr : N;
  a1ljqrt_upper_wall_ptr : N;
  a1ljqrt_floor_height_bits : N;
  a1ljqrt_floor_type : N;
  a1ljqrt_floor_flags : N;
  a1ljqrt_floor_owner_ptr : N;
  a1ljqrt_ceil_ptr : N;
  a1ljqrt_ceil_height_bits : N;
  a1ljqrt_raw_x_bits : N;
  a1ljqrt_raw_y_bits : N;
  a1ljqrt_raw_z_bits : N
}.

Definition a1ljqrt_x_5760_bits : N := 1169424384. (* 0x45b40000 *)
Definition a1ljqrt_ceil_20000_bits : N := 1184645120. (* 0x469c4000 *)

Definition a1ljqrt_q1 : A1LJQQuarterReceipt :=
  {| a1ljqrt_index := 1;
     a1ljqrt_intended_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_intended_y_bits := 0;
     a1ljqrt_intended_z_bits := 1167595520; (* 0x45981800: 4867 *)
     a1ljqrt_lower_wall_ptr := 0;
     a1ljqrt_upper_wall_ptr := 0;
     a1ljqrt_floor_height_bits := 3207395875; (* 0xbf2cfa23 *)
     a1ljqrt_floor_type := 37;
     a1ljqrt_floor_flags := 0;
     a1ljqrt_floor_owner_ptr := 0;
     a1ljqrt_ceil_ptr := 0;
     a1ljqrt_ceil_height_bits := a1ljqrt_ceil_20000_bits;
     a1ljqrt_raw_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_raw_y_bits := 3207395875;
     a1ljqrt_raw_z_bits := 1167595520 |}.

Definition a1ljqrt_q2 : A1LJQQuarterReceipt :=
  {| a1ljqrt_index := 2;
     a1ljqrt_intended_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_intended_y_bits := 3207395875;
     a1ljqrt_intended_z_bits := 1167617497; (* 0x45986dd9 *)
     a1ljqrt_lower_wall_ptr := 0;
     a1ljqrt_upper_wall_ptr := 0;
     a1ljqrt_floor_height_bits := 3225117252; (* 0xc03b6244 *)
     a1ljqrt_floor_type := 37;
     a1ljqrt_floor_flags := 0;
     a1ljqrt_floor_owner_ptr := 0;
     a1ljqrt_ceil_ptr := 0;
     a1ljqrt_ceil_height_bits := a1ljqrt_ceil_20000_bits;
     a1ljqrt_raw_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_raw_y_bits := 3225117252;
     a1ljqrt_raw_z_bits := 1167617497 |}.

Definition a1ljqrt_q3 : A1LJQQuarterReceipt :=
  {| a1ljqrt_index := 3;
     a1ljqrt_intended_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_intended_y_bits := 3225117252;
     a1ljqrt_intended_z_bits := 1167639474; (* 0x4598c3b2 *)
     a1ljqrt_lower_wall_ptr := 0;
     a1ljqrt_upper_wall_ptr := 0;
     a1ljqrt_floor_height_bits := 3232561436; (* 0xc0acf91c *)
     a1ljqrt_floor_type := 37;
     a1ljqrt_floor_flags := 0;
     a1ljqrt_floor_owner_ptr := 0;
     a1ljqrt_ceil_ptr := 0;
     a1ljqrt_ceil_height_bits := a1ljqrt_ceil_20000_bits;
     a1ljqrt_raw_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_raw_y_bits := 3232561436;
     a1ljqrt_raw_z_bits := 1167639474 |}.

Definition a1ljqrt_q4 : A1LJQQuarterReceipt :=
  {| a1ljqrt_index := 4;
     a1ljqrt_intended_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_intended_y_bits := 3232561436;
     a1ljqrt_intended_z_bits := 1167661451; (* 0x4599198b *)
     a1ljqrt_lower_wall_ptr := 0;
     a1ljqrt_upper_wall_ptr := 0;
     a1ljqrt_floor_height_bits := 3237756945; (* 0xc0fc4011 *)
     a1ljqrt_floor_type := 37;
     a1ljqrt_floor_flags := 0;
     a1ljqrt_floor_owner_ptr := 0;
     a1ljqrt_ceil_ptr := 0;
     a1ljqrt_ceil_height_bits := a1ljqrt_ceil_20000_bits;
     a1ljqrt_raw_x_bits := a1ljqrt_x_5760_bits;
     a1ljqrt_raw_y_bits := 3237756945;
     a1ljqrt_raw_z_bits := 1167661451 |}.

Definition a1ljqrt_four_quarters : list A1LJQQuarterReceipt :=
  [a1ljqrt_q1; a1ljqrt_q2; a1ljqrt_q3; a1ljqrt_q4].

Definition a1ljqrt_static_shallow (q : A1LJQQuarterReceipt) : Prop :=
  a1ljqrt_floor_type q = 37 /\
  a1ljqrt_floor_flags q = 0 /\
  a1ljqrt_floor_owner_ptr q = 0.

Definition a1ljqrt_query_clear (q : A1LJQQuarterReceipt) : Prop :=
  a1ljqrt_lower_wall_ptr q = 0 /\
  a1ljqrt_upper_wall_ptr q = 0 /\
  a1ljqrt_ceil_ptr q = 0 /\
  a1ljqrt_ceil_height_bits q = a1ljqrt_ceil_20000_bits.

Theorem a1ljqrt_receipt_has_exactly_four_quarters :
  length a1ljqrt_four_quarters = 4%nat /\
  map a1ljqrt_index a1ljqrt_four_quarters = [1; 2; 3; 4].
Proof. vm_compute. split; reflexivity. Qed.

Theorem a1ljqrt_every_selected_floor_is_static_shallow :
  Forall a1ljqrt_static_shallow a1ljqrt_four_quarters.
Proof.
  unfold a1ljqrt_four_quarters, a1ljqrt_static_shallow,
    a1ljqrt_q1, a1ljqrt_q2, a1ljqrt_q3, a1ljqrt_q4.
  repeat constructor.
Qed.

Theorem a1ljqrt_every_wall_and_ceiling_query_is_clear :
  Forall a1ljqrt_query_clear a1ljqrt_four_quarters.
Proof.
  unfold a1ljqrt_four_quarters, a1ljqrt_query_clear,
    a1ljqrt_q1, a1ljqrt_q2, a1ljqrt_q3, a1ljqrt_q4,
    a1ljqrt_ceil_20000_bits.
  repeat constructor.
Qed.

Theorem a1ljqrt_exact_committed_position_words :
  map (fun q =>
    (a1ljqrt_raw_x_bits q, a1ljqrt_raw_y_bits q,
      a1ljqrt_raw_z_bits q)) a1ljqrt_four_quarters =
  [(1169424384, 3207395875, 1167595520);
   (1169424384, 3225117252, 1167617497);
   (1169424384, 3232561436, 1167639474);
   (1169424384, 3237756945, 1167661451)].
Proof. reflexivity. Qed.

(** [4900.0f] has binary32 word [0x45992000 = 1167663104].  The
    authentic four-quarter endpoint is about [4899.19287], word
    [0x4599198b].  Thus an obligation requiring the exact endpoint 4900 is
    false for this prepared-state trace; it must use the observed binary32
    endpoint (or a suitable region predicate) instead. *)
Definition a1ljqrt_float_4900_bits : N := 1167663104.

Theorem a1ljqrt_prepared_trace_does_not_end_at_exact_4900 :
  a1ljqrt_raw_z_bits a1ljqrt_q4 = 1167661451 /\
  a1ljqrt_raw_z_bits a1ljqrt_q4 <> a1ljqrt_float_4900_bits.
Proof. split; [reflexivity | discriminate]. Qed.

(** Surface addresses differ by version, while type, flags, owner, plane and
    all committed coordinate words above are identical. *)
Definition a1ljqrt_selected_floor_pointer
    (version : A1LJQRetailTraceVersion) : N :=
  match version with
  | A1LJQTraceUS => 2149151216 (* 0x801971f0 *)
  | A1LJQTraceJP => 2149139312 (* 0x80194370 *)
  end.

Theorem a1ljqrt_selected_floor_pointer_is_nonnull :
  forall version, a1ljqrt_selected_floor_pointer version <> 0.
Proof. intros []; discriminate. Qed.

Record A1LJQRunSummary : Type := {
  a1ljqrt_pre_timer : N;
  a1ljqrt_post_timer : N;
  a1ljqrt_quicksand_depth_bits : N;
  a1ljqrt_lower_query_count : N;
  a1ljqrt_upper_query_count : N;
  a1ljqrt_floor_query_count : N;
  a1ljqrt_ceil_query_count : N;
  a1ljqrt_commit_count : N;
  a1ljqrt_final_platform_ptr : N;
  a1ljqrt_pre_input_bits : N;
  a1ljqrt_pre_button_down_bits : N;
  a1ljqrt_pre_button_pressed_bits : N;
  a1ljqrt_a_pressed_poll_count : N;
  a1ljqrt_a_down_poll_count : N
}.

Definition a1ljqrt_timer3_summary : A1LJQRunSummary :=
  {| a1ljqrt_pre_timer := 3;
     a1ljqrt_post_timer := 4;
     a1ljqrt_quicksand_depth_bits := 3204448256; (* 0xbf000000 *)
     a1ljqrt_lower_query_count := 4;
     a1ljqrt_upper_query_count := 4;
     a1ljqrt_floor_query_count := 4;
     a1ljqrt_ceil_query_count := 4;
     a1ljqrt_commit_count := 4;
     a1ljqrt_final_platform_ptr := 0;
     a1ljqrt_pre_input_bits := 32; (* INPUT_OFF_FLOOR only: 0x0020 *)
     a1ljqrt_pre_button_down_bits := 0;
     a1ljqrt_pre_button_pressed_bits := 0;
     a1ljqrt_a_pressed_poll_count := 0;
     a1ljqrt_a_down_poll_count := 0 |}.

Definition a1ljqrt_timer4_summary : A1LJQRunSummary :=
  {| a1ljqrt_pre_timer := 4;
     a1ljqrt_post_timer := 5;
     a1ljqrt_quicksand_depth_bits := 3229614080; (* 0xc0800000 *)
     a1ljqrt_lower_query_count := 4;
     a1ljqrt_upper_query_count := 4;
     a1ljqrt_floor_query_count := 4;
     a1ljqrt_ceil_query_count := 4;
     a1ljqrt_commit_count := 4;
     a1ljqrt_final_platform_ptr := 0;
     a1ljqrt_pre_input_bits := 32;
     a1ljqrt_pre_button_down_bits := 0;
     a1ljqrt_pre_button_pressed_bits := 0;
     a1ljqrt_a_pressed_poll_count := 0;
     a1ljqrt_a_down_poll_count := 0 |}.

Definition a1ljqrt_summary_well_formed (s : A1LJQRunSummary) : Prop :=
  a1ljqrt_lower_query_count s = 4 /\
  a1ljqrt_upper_query_count s = 4 /\
  a1ljqrt_floor_query_count s = 4 /\
  a1ljqrt_ceil_query_count s = 4 /\
  a1ljqrt_commit_count s = 4 /\
  a1ljqrt_final_platform_ptr s = 0 /\
  N.land (a1ljqrt_pre_input_bits s) 2 = 0 /\
  N.land (a1ljqrt_pre_button_down_bits s) 32768 = 0 /\
  N.land (a1ljqrt_pre_button_pressed_bits s) 32768 = 0 /\
  a1ljqrt_a_pressed_poll_count s = 0 /\
  a1ljqrt_a_down_poll_count s = 0.

Theorem a1ljqrt_both_timer_summaries_are_well_formed :
  a1ljqrt_summary_well_formed a1ljqrt_timer3_summary /\
  a1ljqrt_summary_well_formed a1ljqrt_timer4_summary.
Proof.
  unfold a1ljqrt_summary_well_formed, a1ljqrt_timer3_summary,
    a1ljqrt_timer4_summary.
  repeat split; reflexivity.
Qed.

Theorem a1ljqrt_timer_and_depth_summaries_are_exact :
  (a1ljqrt_pre_timer a1ljqrt_timer3_summary,
   a1ljqrt_post_timer a1ljqrt_timer3_summary,
   a1ljqrt_quicksand_depth_bits a1ljqrt_timer3_summary) =
    (3, 4, 3204448256) /\
  (a1ljqrt_pre_timer a1ljqrt_timer4_summary,
   a1ljqrt_post_timer a1ljqrt_timer4_summary,
   a1ljqrt_quicksand_depth_bits a1ljqrt_timer4_summary) =
    (4, 5, 3229614080).
Proof. split; reflexivity. Qed.

Record A1LJQRunReceipt : Type := {
  a1ljqrt_run_version : A1LJQRetailTraceVersion;
  a1ljqrt_run_summary : A1LJQRunSummary
}.

Definition a1ljqrt_four_run_receipts : list A1LJQRunReceipt :=
  [{| a1ljqrt_run_version := A1LJQTraceUS;
      a1ljqrt_run_summary := a1ljqrt_timer3_summary |};
   {| a1ljqrt_run_version := A1LJQTraceUS;
      a1ljqrt_run_summary := a1ljqrt_timer4_summary |};
   {| a1ljqrt_run_version := A1LJQTraceJP;
      a1ljqrt_run_summary := a1ljqrt_timer3_summary |};
   {| a1ljqrt_run_version := A1LJQTraceJP;
      a1ljqrt_run_summary := a1ljqrt_timer4_summary |}].

Theorem a1ljqrt_us_jp_timer3_timer4_run_matrix_is_exact :
  map
    (fun run =>
      (a1ljqrt_run_version run,
       a1ljqrt_pre_timer (a1ljqrt_run_summary run)))
    a1ljqrt_four_run_receipts =
  [(A1LJQTraceUS, 3); (A1LJQTraceUS, 4);
   (A1LJQTraceJP, 3); (A1LJQTraceJP, 4)] /\
  Forall
    (fun run => a1ljqrt_summary_well_formed (a1ljqrt_run_summary run))
    a1ljqrt_four_run_receipts.
Proof.
  split; [reflexivity |].
  unfold a1ljqrt_four_run_receipts, a1ljqrt_summary_well_formed,
    a1ljqrt_timer3_summary, a1ljqrt_timer4_summary.
  repeat constructor.
Qed.
