(** Generated-source boundary for the physical warp/top-relocation branch.

    The stock Area-1 upper warp is created by a fixed LevelScript object
    record.  Its behavior script initializes flags and interaction fields and
    repeatedly calls [bhv_warp_loop].  The generated native body writes the
    hitbox and interaction-status fields, but contains no direct read or write
    of raw position slots 6, 7, or 8.  This is a direct-writer source-shape
    receipt, not yet a small-step position-preservation theorem.

    The pyramid top is different.  Its spinning native body writes X and Y,
    never Z.  The generated syntax exposes the source formula constants:
    X is home X plus a sine-table sample times 40; before timer 60 Y is home Y
    plus an absolute sine sample times 10; afterwards the vertical velocity
    is eventually clamped to 5 while yaw acceleration is capped at 0x1800.
    The finite binary32 mirror below checks all modeled spinning timer indices
    0 through 150: X stays in [-2087,-2007], Y stays between home Y and its
    timer-150 value, and Z remains -1023.  Timer 131 agrees with the separate
    surface fixture.

    These are direct generated-AST receipts and a finite value certificate.
    They do not prove that arbitrary callers cannot alias the warp object,
    that a clone cannot be created at another position, or that every live
    Clight execution refines the value mirror.  Those connections remain
    explicit at the end of the file. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions jp_behavior_actions
  us_behavior_data jp_behavior_data
  us_obj_behaviors jp_obj_behaviors
  us_math_util jp_math_util.
From LessThanOneAPress.Proofs Require Import ASTFacts ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module SWTUBA := us_behavior_actions.
Module SWTJBA := jp_behavior_actions.
Module SWTUBD := us_behavior_data.
Module SWTJBD := jp_behavior_data.
Module SWTUOB := us_obj_behaviors.
Module SWTJOB := jp_obj_behaviors.
Module SWTUMath := us_math_util.
Module SWTJMath := jp_math_util.

(** * Stock upper-warp direct-writer source shape *)

Definition expected_stock_warp_script_us : list init_data :=
  [ Init_int32 (Int.repr 393216);
    Init_int32 (Int.repr 285278217);
    Init_int32 (Int.repr 271196160);
    Init_int32 (Int.repr 268763136);
    Init_int32 (Int.repr 134217728);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTUBD._bhv_warp_loop (Ptrofs.repr 0);
    Init_int32 (Int.repr 150994944) ].

Definition expected_stock_warp_script_jp : list init_data :=
  [ Init_int32 (Int.repr 393216);
    Init_int32 (Int.repr 285278217);
    Init_int32 (Int.repr 271196160);
    Init_int32 (Int.repr 268763136);
    Init_int32 (Int.repr 134217728);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTJBD._bhv_warp_loop (Ptrofs.repr 0);
    Init_int32 (Int.repr 150994944) ].

Definition stock_warp_script_source_claim : Prop :=
  gvar_init SWTUBD.v_bhvWarp = expected_stock_warp_script_us /\
  gvar_init SWTJBD.v_bhvWarp = expected_stock_warp_script_jp.

Theorem stock_warp_script_source_checked :
  stock_warp_script_source_claim.
Proof.
  unfold stock_warp_script_source_claim,
    expected_stock_warp_script_us, expected_stock_warp_script_jp.
  vm_compute.
  split; reflexivity.
Qed.

Definition stock_warp_native_direct_position_write_us : bool :=
  assigns_array_slot_s SWTUBA._asF32 6
    (fn_body SWTUBA.f_bhv_warp_loop) ||
  assigns_array_slot_s SWTUBA._asF32 7
    (fn_body SWTUBA.f_bhv_warp_loop) ||
  assigns_array_slot_s SWTUBA._asF32 8
    (fn_body SWTUBA.f_bhv_warp_loop).

Definition stock_warp_native_direct_position_write_jp : bool :=
  assigns_array_slot_s SWTJBA._asF32 6
    (fn_body SWTJBA.f_bhv_warp_loop) ||
  assigns_array_slot_s SWTJBA._asF32 7
    (fn_body SWTJBA.f_bhv_warp_loop) ||
  assigns_array_slot_s SWTJBA._asF32 8
    (fn_body SWTJBA.f_bhv_warp_loop).

(** This theorem is deliberately about the imported native body.  It is
    stronger than merely failing to find an assignment: the body does not
    even mention any of the three position slots and has no direct callees. *)
Definition stock_warp_native_position_source_claim : Prop :=
  stock_warp_native_direct_position_write_us = false /\
  stock_warp_native_direct_position_write_jp = false /\
  statement_mentions_array_slot_s SWTUBA._asF32 6
    (fn_body SWTUBA.f_bhv_warp_loop) = false /\
  statement_mentions_array_slot_s SWTUBA._asF32 7
    (fn_body SWTUBA.f_bhv_warp_loop) = false /\
  statement_mentions_array_slot_s SWTUBA._asF32 8
    (fn_body SWTUBA.f_bhv_warp_loop) = false /\
  direct_callees_s (fn_body SWTUBA.f_bhv_warp_loop) = [] /\
  statement_mentions_array_slot_s SWTJBA._asF32 6
    (fn_body SWTJBA.f_bhv_warp_loop) = false /\
  statement_mentions_array_slot_s SWTJBA._asF32 7
    (fn_body SWTJBA.f_bhv_warp_loop) = false /\
  statement_mentions_array_slot_s SWTJBA._asF32 8
    (fn_body SWTJBA.f_bhv_warp_loop) = false /\
  direct_callees_s (fn_body SWTJBA.f_bhv_warp_loop) = [] /\
  assigns_field_named_s SWTUBA._hitboxRadius
    (fn_body SWTUBA.f_bhv_warp_loop) = true /\
  assigns_field_named_s SWTUBA._hitboxHeight
    (fn_body SWTUBA.f_bhv_warp_loop) = true /\
  assigns_array_slot_int_constant_s SWTUBA._asS32 43 0
    (fn_body SWTUBA.f_bhv_warp_loop) = true /\
  assigns_field_named_s SWTJBA._hitboxRadius
    (fn_body SWTJBA.f_bhv_warp_loop) = true /\
  assigns_field_named_s SWTJBA._hitboxHeight
    (fn_body SWTJBA.f_bhv_warp_loop) = true /\
  assigns_array_slot_int_constant_s SWTJBA._asS32 43 0
    (fn_body SWTJBA.f_bhv_warp_loop) = true.

Theorem stock_warp_native_position_source_checked :
  stock_warp_native_position_source_claim.
Proof.
  unfold stock_warp_native_position_source_claim,
    stock_warp_native_direct_position_write_us,
    stock_warp_native_direct_position_write_jp.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The exact LevelScript records checked in [ClightFacts] locate the upper
    warp at (-2048,768,-1024) with behavior [bhvWarp].  Packaging that receipt
    with the script and native-body source facts does not replace an execution
    or memory-frame refinement. *)
Definition StockUpperWarpDirectWriterSourceBoundary : Prop :=
  firstn 6 (skipn 62 (gvar_init USS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_us /\
  firstn 6 (skipn 62 (gvar_init JSS.v_level_ssl_entry)) =
    ssl_area1_upper_warp_object_jp /\
  stock_warp_script_source_claim /\
  stock_warp_native_position_source_claim.

Theorem stock_upper_warp_direct_writer_source_boundary_checked :
  StockUpperWarpDirectWriterSourceBoundary.
Proof.
  unfold StockUpperWarpDirectWriterSourceBoundary.
  split; [exact ssl_area1_upper_warp_object_exact_us |].
  split; [exact ssl_area1_upper_warp_object_exact_jp |].
  split; [exact stock_warp_script_source_checked |].
  exact stock_warp_native_position_source_checked.
Qed.

(** * Stock pyramid-top movement source classification *)

Definition expected_stock_top_script_us : list init_data :=
  [ Init_int32 (Int.repr 589824);
    Init_int32 (Int.repr 285278209);
    Init_int32 (Int.repr 704643072);
    Init_addrof SWTUBD._ssl_seg7_collision_pyramid_top (Ptrofs.repr 0);
    Init_int32 (Int.repr 754974720);
    Init_int32 (Int.repr 239291936);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTUBD._bhv_pyramid_top_init (Ptrofs.repr 0);
    Init_int32 (Int.repr 134217728);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTUBD._bhv_pyramid_top_loop (Ptrofs.repr 0);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTUBD._load_object_collision_model (Ptrofs.repr 0);
    Init_int32 (Int.repr 150994944) ].

Definition expected_stock_top_script_jp : list init_data :=
  [ Init_int32 (Int.repr 589824);
    Init_int32 (Int.repr 285278209);
    Init_int32 (Int.repr 704643072);
    Init_addrof SWTJBD._ssl_seg7_collision_pyramid_top (Ptrofs.repr 0);
    Init_int32 (Int.repr 754974720);
    Init_int32 (Int.repr 239291936);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTJBD._bhv_pyramid_top_init (Ptrofs.repr 0);
    Init_int32 (Int.repr 134217728);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTJBD._bhv_pyramid_top_loop (Ptrofs.repr 0);
    Init_int32 (Int.repr 201326592);
    Init_addrof SWTJBD._load_object_collision_model (Ptrofs.repr 0);
    Init_int32 (Int.repr 150994944) ].

Definition stock_top_script_source_claim : Prop :=
  gvar_init SWTUBD.v_bhvPyramidTop = expected_stock_top_script_us /\
  gvar_init SWTJBD.v_bhvPyramidTop = expected_stock_top_script_jp.

Theorem stock_top_script_source_checked :
  stock_top_script_source_claim.
Proof.
  unfold stock_top_script_source_claim,
    expected_stock_top_script_us, expected_stock_top_script_jp.
  vm_compute.
  split; reflexivity.
Qed.

Definition stock_top_direct_motion_source_claim : Prop :=
  assigns_array_slot_s SWTUOB._asF32 6
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s SWTUOB._asF32 7
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s SWTUOB._asF32 8
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = false /\
  statement_mentions_array_slot_s SWTUOB._asF32 55
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_array_slot_s SWTUOB._asF32 56
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_array_slot_s SWTUOB._asS32 51
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 16384
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 8192
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1109393408
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1092616192
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1084227584
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 60
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 150
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 256
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 6144
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  calls_ident_s SWTUOB._absf_2
    (fn_body SWTUOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s SWTJOB._asF32 6
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s SWTJOB._asF32 7
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  assigns_array_slot_s SWTJOB._asF32 8
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = false /\
  statement_mentions_array_slot_s SWTJOB._asF32 55
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_array_slot_s SWTJOB._asF32 56
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_array_slot_s SWTJOB._asS32 51
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 16384
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 8192
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1109393408
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1092616192
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_float32_bits_s 1084227584
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 60
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 150
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 256
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_int_s 6144
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true /\
  calls_ident_s SWTJOB._absf_2
    (fn_body SWTJOB.f_bhv_pyramid_top_spinning) = true.

Theorem stock_top_direct_motion_source_checked :
  stock_top_direct_motion_source_claim.
Proof.
  unfold stock_top_direct_motion_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** The initializer, dispatcher, and explosion bodies contain no direct
    assignment to the top's raw position slots.  Calls that allocate children
    are intentionally not treated as memory-frame theorems. *)
Definition stock_top_nonspinning_direct_position_source_claim : Prop :=
  assigns_array_slot_s SWTUOB._asF32 6
    (fn_body SWTUOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTUOB._asF32 7
    (fn_body SWTUOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTUOB._asF32 8
    (fn_body SWTUOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTUOB._asF32 6
    (fn_body SWTUOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTUOB._asF32 7
    (fn_body SWTUOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTUOB._asF32 8
    (fn_body SWTUOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTUOB._asF32 6
    (fn_body SWTUOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s SWTUOB._asF32 7
    (fn_body SWTUOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s SWTUOB._asF32 8
    (fn_body SWTUOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s SWTJOB._asF32 6
    (fn_body SWTJOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTJOB._asF32 7
    (fn_body SWTJOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTJOB._asF32 8
    (fn_body SWTJOB.f_bhv_pyramid_top_init) = false /\
  assigns_array_slot_s SWTJOB._asF32 6
    (fn_body SWTJOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTJOB._asF32 7
    (fn_body SWTJOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTJOB._asF32 8
    (fn_body SWTJOB.f_bhv_pyramid_top_loop) = false /\
  assigns_array_slot_s SWTJOB._asF32 6
    (fn_body SWTJOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s SWTJOB._asF32 7
    (fn_body SWTJOB.f_bhv_pyramid_top_explode) = false /\
  assigns_array_slot_s SWTJOB._asF32 8
    (fn_body SWTJOB.f_bhv_pyramid_top_explode) = false.

Theorem stock_top_nonspinning_direct_position_source_checked :
  stock_top_nonspinning_direct_position_source_claim.
Proof.
  unfold stock_top_nonspinning_direct_position_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** * Generated sine-table receipt and finite binary32 pose model *)

Definition stock_top_sine_eighths : list float32 :=
  [ Float32.of_bits (Int.repr 0);
    Float32.of_bits (Int.repr 1060439283);
    Float32.of_bits (Int.repr 1065353216);
    Float32.of_bits (Int.repr 1060439283);
    Float32.of_bits (Int.repr 0);
    Float32.of_bits (Int.repr 3207922931);
    Float32.of_bits (Int.repr 3212836864);
    Float32.of_bits (Int.repr 3207922931) ].

Definition stock_top_sine_table_source_claim : Prop :=
  nth_error (gvar_init SWTUMath.v_gSineTable) 0 =
    Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 512 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060439283))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 1024 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1065353216))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 1536 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060439283))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 2048 =
    Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 2560 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207922931))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 3072 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3212836864))) /\
  nth_error (gvar_init SWTUMath.v_gSineTable) 3584 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207922931))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 0 =
    Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 512 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060439283))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 1024 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1065353216))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 1536 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060439283))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 2048 =
    Some (Init_float32 (Float32.of_bits (Int.repr 0))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 2560 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207922931))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 3072 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3212836864))) /\
  nth_error (gvar_init SWTJMath.v_gSineTable) 3584 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207922931))).

Theorem stock_top_sine_table_source_checked :
  stock_top_sine_table_source_claim.
Proof.
  unfold stock_top_sine_table_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition stock_f32_of_Z (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition stock_top_sine_eighth (timer : nat) : float32 :=
  nth (timer mod 8) stock_top_sine_eighths (stock_f32_of_Z 0).

Definition modeled_stock_top_center_x (timer : nat) : float32 :=
  Float32.add (stock_f32_of_Z (-2047))
    (Float32.mul (stock_top_sine_eighth (2 * timer))
      (stock_f32_of_Z 40)).

Definition modeled_stock_top_early_y (timer : nat) : float32 :=
  Float32.add (stock_f32_of_Z 1536)
    (Float32.abs
      (Float32.mul (stock_top_sine_eighth timer) (stock_f32_of_Z 10))).

Record StockTopSpinYState : Type := {
  stock_top_angle_velocity_yaw : Z;
  stock_top_velocity_y : float32;
  stock_top_center_y : float32
}.

Definition stock_top_spin_y_step
    (state : StockTopSpinYState) : StockTopSpinYState :=
  let proposed := stock_top_angle_velocity_yaw state + 256 in
  let exceeded := 6144 <? proposed in
  let next_angle_velocity := if exceeded then 6144 else proposed in
  let next_velocity_y :=
    if exceeded then stock_f32_of_Z 5 else stock_top_velocity_y state in
  {| stock_top_angle_velocity_yaw := next_angle_velocity;
     stock_top_velocity_y := next_velocity_y;
     stock_top_center_y :=
       Float32.add (stock_top_center_y state) next_velocity_y |}.

Fixpoint iterate_stock_top_spin_y
    (updates : nat) (state : StockTopSpinYState) : StockTopSpinYState :=
  match updates with
  | O => state
  | S remaining =>
      iterate_stock_top_spin_y remaining (stock_top_spin_y_step state)
  end.

Definition stock_top_before_timer60 : StockTopSpinYState :=
  {| stock_top_angle_velocity_yaw := 0;
     stock_top_velocity_y := stock_f32_of_Z 0;
     stock_top_center_y := modeled_stock_top_early_y 59 |}.

(** The subtraction counts both endpoints: timer 60 is one update after the
    saved timer-59 pose, while timer 150 is 91 updates after it. *)
Definition modeled_stock_top_center_y (timer : nat) : float32 :=
  if Nat.ltb timer 60
  then modeled_stock_top_early_y timer
  else stock_top_center_y
    (iterate_stock_top_spin_y (Nat.sub timer 59) stock_top_before_timer60).

Definition modeled_stock_top_center_z (_ : nat) : float32 :=
  stock_f32_of_Z (-1023).

Definition modeled_stock_top_pose_bounded_b (timer : nat) : bool :=
  Float32.cmp Cle (stock_f32_of_Z (-2087))
    (modeled_stock_top_center_x timer) &&
  Float32.cmp Cle (modeled_stock_top_center_x timer)
    (stock_f32_of_Z (-2007)) &&
  Float32.cmp Cle (stock_f32_of_Z 1536)
    (modeled_stock_top_center_y timer) &&
  Float32.cmp Cle (modeled_stock_top_center_y timer)
    (modeled_stock_top_center_y 150) &&
  Float32.cmp Ceq (modeled_stock_top_center_z timer)
    (stock_f32_of_Z (-1023)).

Theorem modeled_stock_top_x_four_frame_cycle_checked :
  map (fun timer => Float32.to_bits (modeled_stock_top_center_x timer))
    (seq 0 4) =
  [ Int.repr 3305103360;  (* -2047.0f *)
    Int.repr 3304775680;  (* -2007.0f *)
    Int.repr 3305103360;  (* -2047.0f *)
    Int.repr 3305271296   (* -2087.0f *)
  ].
Proof. vm_compute. reflexivity. Qed.

Theorem modeled_stock_top_timer131_agrees_with_surface_fixture :
  Float32.to_bits (modeled_stock_top_center_x 131) =
    Int.repr 3305271296 /\
  Float32.to_bits (modeled_stock_top_center_y 131) =
    Int.repr 1155457606 /\
  Float32.to_bits (modeled_stock_top_center_z 131) =
    Int.repr 3296706560.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem modeled_stock_top_timer150_rise_is_between_342_and_343 :
  Float32.cmp Clt (stock_f32_of_Z (1536 + 342))
    (modeled_stock_top_center_y 150) = true /\
  Float32.cmp Clt (modeled_stock_top_center_y 150)
    (stock_f32_of_Z (1536 + 343)) = true.
Proof. vm_compute. split; reflexivity. Qed.

(** This computation covers every timer for which the spinning body can run,
    including timer 150 before it changes the action to exploding. *)
Theorem modeled_stock_top_all_spinning_timers_bounded_checked :
  forallb modeled_stock_top_pose_bounded_b (seq 0 151) = true.
Proof. vm_compute. reflexivity. Qed.

Theorem modeled_stock_top_spinning_timer_bounded :
  forall timer,
    (timer < 151)%nat ->
    modeled_stock_top_pose_bounded_b timer = true.
Proof.
  intros timer Htimer.
  apply (proj1 (forallb_forall modeled_stock_top_pose_bounded_b (seq 0 151))).
  - exact modeled_stock_top_all_spinning_timers_bounded_checked.
  - apply in_seq. lia.
Qed.

Theorem modeled_stock_top_never_changes_z :
  forall timer,
    modeled_stock_top_center_z timer = stock_f32_of_Z (-1023).
Proof. reflexivity. Qed.

(** * Precisely retained residuals *)

(** A future linked proof must show that a live execution of the spinning
    body has the same timer, home coordinates, initialized velocity, sine
    lookup, binary32 operations, and object identity as the finite mirror. *)
Definition StockTopMotionClightRefinementObligation
    (live_pose : nat -> option (float32 * float32 * float32)) : Prop :=
  forall timer,
    (timer < 151)%nat ->
    live_pose timer =
      Some (modeled_stock_top_center_x timer,
            modeled_stock_top_center_y timer,
            modeled_stock_top_center_z timer).

(** This module closes neither writes through an aliased object pointer nor
    replacement/cloned behavior instances.  Those are separate from the
    stock upper warp's own script/native callback proved above. *)
Definition StockWarpExternalRelocationAndCloneObligation
    (all_live_warp_position_writes_classified : Prop)
    (upper_warp_identity_and_epoch_preserved : Prop) : Prop :=
  all_live_warp_position_writes_classified /\
  upper_warp_identity_and_epoch_preserved.
