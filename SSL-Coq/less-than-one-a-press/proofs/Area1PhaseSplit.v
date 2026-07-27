(** A bounded SSL Area-1 audit of the transient MarioState/MarioObject split.

    This file proves two results that must not be conflated:

    - a generated-source-backed break-box fragment payload has a concrete
      binary32 execution that changes X, Y, and Z and raises MarioState by
      more than the 385-unit lower bound from [PyramidTopPU]; but
    - a platform pointer captured from the stock pyramid top at the preceding
      final platform query cannot bootstrap node-0x1E collision on the next
      frame, because collision still samples the same full-coordinate
      MarioObject that had to be at top height.

    The first result is a payload capability counterexample, not a reachable
    object-pool trace.  The second is a phase-boundary theorem whose
    object-sample preservation premise is checked syntactically in generated
    Clight by [mario_state_object_phase_split_source_shape_us/jp], but a linked
    Clight small-step refinement must still derive that premise for a retail
    execution.  No theorem here claims the ultimate no-A result. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions jp_behavior_actions
  us_math_util jp_math_util
  us_object_helpers jp_object_helpers
  us_spawn_object jp_spawn_object
  us_ssl_area1_macro jp_ssl_area1_macro.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts JPSlotLifetime PyramidTopPU PyramidTopSurface.

Import ListNotations.
Local Open Scope Z_scope.

Module UArea1Actions := us_behavior_actions.
Module JArea1Actions := jp_behavior_actions.
Module UArea1Math := us_math_util.
Module JArea1Math := jp_math_util.
Module UArea1Helpers := us_object_helpers.
Module JArea1Helpers := jp_object_helpers.
Module UArea1Spawn := us_spawn_object.
Module JArea1Spawn := jp_spawn_object.
Module UArea1Macro := us_ssl_area1_macro.
Module JArea1Macro := jp_ssl_area1_macro.

(** The two fragment-producing source paths are visible in generated Clight.
    An attacked breakable box requests mist before dirt fragments.  The mist
    helper contains the stock
    [gPrevFrameObjectCount > (240 - 30)] suppression threshold, so a
    suppressed mist loop can leave a fragment as the first allocation.  An
    exclamation box requests contents, mist, then cartoon-star fragments.
    Which allocation reuses a watched slot remains a free-list execution
    obligation.

    The fragment initializer writes nonzero pitch in both branches, and
    nonzero yaw in the dirt branch.  Fresh allocation zeros all 80 raw-data
    words.  Tox Box motion changes face angles but does not write the three
    angular-velocity slots read by platform displacement.  These checks are
    path-insensitive AST facts, not reachability or memory-dataflow proofs. *)
Definition area1_fragment_writer_source_claim : Prop :=
  ident_subsequenceb
    [UArea1Helpers._spawn_mist_particles_variable;
     UArea1Helpers._spawn_triangle_break_particles]
    (direct_callees_s
      (fn_body UArea1Helpers.f_obj_explode_and_spawn_coins)) = true /\
  ident_subsequenceb
    [JArea1Helpers._spawn_mist_particles_variable;
     JArea1Helpers._spawn_triangle_break_particles]
    (direct_callees_s
      (fn_body JArea1Helpers.f_obj_explode_and_spawn_coins)) = true /\
  statement_mentions_ident_s UArea1Helpers._gPrevFrameObjectCount
    (fn_body UArea1Helpers.f_cur_obj_spawn_particles) = true /\
  statement_mentions_int_s 240
    (fn_body UArea1Helpers.f_cur_obj_spawn_particles) = true /\
  statement_mentions_int_s 30
    (fn_body UArea1Helpers.f_cur_obj_spawn_particles) = true /\
  statement_mentions_ident_s JArea1Helpers._gPrevFrameObjectCount
    (fn_body JArea1Helpers.f_cur_obj_spawn_particles) = true /\
  statement_mentions_int_s 240
    (fn_body JArea1Helpers.f_cur_obj_spawn_particles) = true /\
  statement_mentions_int_s 30
    (fn_body JArea1Helpers.f_cur_obj_spawn_particles) = true /\
  ident_subsequenceb
    [UArea1Actions._exclamation_box_spawn_contents;
     UArea1Actions._spawn_mist_particles_variable;
     UArea1Actions._spawn_triangle_break_particles]
    (direct_callees_s
      (fn_body UArea1Actions.f_exclamation_box_act_4)) = true /\
  ident_subsequenceb
    [JArea1Actions._exclamation_box_spawn_contents;
     JArea1Actions._spawn_mist_particles_variable;
     JArea1Actions._spawn_triangle_break_particles]
    (direct_callees_s
      (fn_body JArea1Actions.f_exclamation_box_act_4)) = true /\
  assigns_array_slot_s UArea1Actions._asS32 35
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  assigns_array_slot_s UArea1Actions._asS32 36
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  assigns_array_slot_s JArea1Actions._asS32 35
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  assigns_array_slot_s JArea1Actions._asS32 36
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 3840
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 1280
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 128
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body UArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 3840
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 1280
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_int_s 128
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body JArea1Actions.f_spawn_triangle_break_particles) = true /\
  count_occ Pos.eq_dec
    (direct_callees_s
      (fn_body UArea1Actions.f_spawn_triangle_break_particles))
    UArea1Actions._random_u16 = 2%nat /\
  count_occ Pos.eq_dec
    (direct_callees_s
      (fn_body JArea1Actions.f_spawn_triangle_break_particles))
    JArea1Actions._random_u16 = 2%nat /\
  assigns_dynamic_raw_s32_zero_s
    UArea1Spawn._rawData UArea1Spawn._asS32 UArea1Spawn._i
    (fn_body UArea1Spawn.f_allocate_object) = true /\
  assigns_dynamic_raw_s32_zero_s
    JArea1Spawn._rawData JArea1Spawn._asS32 JArea1Spawn._i
    (fn_body JArea1Spawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body UArea1Spawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body JArea1Spawn.f_allocate_object) = true /\
  assigns_array_slot_s UArea1Actions._asS32 35
    (fn_body UArea1Actions.f_tox_box_move) = false /\
  assigns_array_slot_s UArea1Actions._asS32 36
    (fn_body UArea1Actions.f_tox_box_move) = false /\
  assigns_array_slot_s UArea1Actions._asS32 37
    (fn_body UArea1Actions.f_tox_box_move) = false /\
  assigns_array_slot_s JArea1Actions._asS32 35
    (fn_body JArea1Actions.f_tox_box_move) = false /\
  assigns_array_slot_s JArea1Actions._asS32 36
    (fn_body JArea1Actions.f_tox_box_move) = false /\
  assigns_array_slot_s JArea1Actions._asS32 37
    (fn_body JArea1Actions.f_tox_box_move) = false.

Theorem area1_fragment_writer_source_checked :
  area1_fragment_writer_source_claim.
Proof.
  unfold area1_fragment_writer_source_claim.
  vm_compute.
  repeat split.
Qed.

(** Packed macro records are [preset + 31; x; y; z; behavior parameter] for
    zero-yaw entries.  Tag 91 is [macro_box_wing_cap], and tag 100 is
    [macro_breakable_box_no_coins].  The middle wing-cap box supplies the
    concrete fragment parent used below. *)
Definition expected_area1_wing_cap_boxes : list (list Z) :=
  [ [91; 6900; 350; -5400; 0];
    [91; -3000; 500; 800; 0];
    [91; 5860; 940; 4180; 0] ].

Definition expected_area1_breakable_boxes : list (list Z) :=
  [ [100; 5900; 51; 4400; 0];
    [100; 5900; 51; 2311; 0] ].

Definition area1_fragment_parent_source_claim : Prop :=
  records_with_tag 91
    (gvar_init UArea1Macro.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_wing_cap_boxes /\
  records_with_tag 91
    (gvar_init JArea1Macro.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_wing_cap_boxes /\
  records_with_tag 100
    (gvar_init UArea1Macro.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_breakable_boxes /\
  records_with_tag 100
    (gvar_init JArea1Macro.v_ssl_seg7_area_1_macro_objs) =
      expected_area1_breakable_boxes.

Theorem area1_fragment_parent_source_checked :
  area1_fragment_parent_source_claim.
Proof.
  unfold area1_fragment_parent_source_claim,
    expected_area1_wing_cap_boxes, expected_area1_breakable_boxes.
  vm_compute.
  repeat split.
Qed.

(** The attack path writes vertical velocity 30 and gravity -8.  Action 3
    calls the stock vertical-motion helper, then clamps both fields after the
    velocity becomes negative.  The recognizers below establish only that
    source shape; the four-step recurrence is the corresponding finite-width
    value model, and linking it to a Clight memory execution remains an
    explicit refinement obligation. *)
Definition area1_box_rebound_source_claim : Prop :=
  assigns_array_slot_s UArea1Actions._asF32 10
    (fn_body UArea1Actions.f_exclamation_box_act_2) = true /\
  assigns_array_slot_s UArea1Actions._asF32 23
    (fn_body UArea1Actions.f_exclamation_box_act_2) = true /\
  statement_mentions_float32_bits_s 1106247680
    (fn_body UArea1Actions.f_exclamation_box_act_2) = true /\
  statement_mentions_float32_bits_s 1090519040
    (fn_body UArea1Actions.f_exclamation_box_act_2) = true /\
  calls_ident_s UArea1Actions._cur_obj_move_using_fvel_and_gravity
    (fn_body UArea1Actions.f_exclamation_box_act_3) = true /\
  assigns_array_slot_s UArea1Actions._asF32 10
    (fn_body UArea1Actions.f_exclamation_box_act_3) = true /\
  assigns_array_slot_s UArea1Actions._asF32 23
    (fn_body UArea1Actions.f_exclamation_box_act_3) = true /\
  assigns_array_slot_s JArea1Actions._asF32 10
    (fn_body JArea1Actions.f_exclamation_box_act_2) = true /\
  assigns_array_slot_s JArea1Actions._asF32 23
    (fn_body JArea1Actions.f_exclamation_box_act_2) = true /\
  statement_mentions_float32_bits_s 1106247680
    (fn_body JArea1Actions.f_exclamation_box_act_2) = true /\
  statement_mentions_float32_bits_s 1090519040
    (fn_body JArea1Actions.f_exclamation_box_act_2) = true /\
  calls_ident_s JArea1Actions._cur_obj_move_using_fvel_and_gravity
    (fn_body JArea1Actions.f_exclamation_box_act_3) = true /\
  assigns_array_slot_s JArea1Actions._asF32 10
    (fn_body JArea1Actions.f_exclamation_box_act_3) = true /\
  assigns_array_slot_s JArea1Actions._asF32 23
    (fn_body JArea1Actions.f_exclamation_box_act_3) = true.

Theorem area1_box_rebound_source_checked :
  area1_box_rebound_source_claim.
Proof.
  unfold area1_box_rebound_source_claim.
  vm_compute.
  repeat split.
Qed.

Definition area1_box_rebound_vertical_steps : list Z := [22; 14; 6; -2].

Definition area1_box_action4_y : Z :=
  fold_left Z.add area1_box_rebound_vertical_steps 500.

Theorem area1_box_action4_and_fragment_pivot_y_checked :
  area1_box_action4_y = 540 /\
  area1_box_action4_y + 100 = 640.
Proof. vm_compute. split; reflexivity. Qed.

(** The stock 16-bit PRNG, mirrored with explicit unsigned-16 truncation.
    Starting immediately before the two calls made by the first triangle,
    seed 0 yields yaw 57460 and then pitch 55882.  This proves the payload is
    compatible with the PRNG recurrence.  It does not prove that a reachable
    Area-1 run has seed 0 at the relevant allocation. *)
Definition u16z (value : Z) : Z := Z.land value 65535.

Definition random_u16_step_z (seed : Z) : Z :=
  let seed0 := if Z.eqb seed 22026 then 0 else u16z seed in
  let temp1 :=
    u16z
      (Z.lxor
        (Z.shiftl (Z.land seed0 255) 8)
        seed0) in
  let seed1 :=
    u16z
      (Z.shiftl (Z.land temp1 255) 8 +
       Z.shiftr (Z.land temp1 65280) 8) in
  let temp1' :=
    u16z
      (Z.lxor
        (Z.shiftl (Z.land temp1 255) 1)
        seed1) in
  let temp2 :=
    u16z (Z.lxor (Z.shiftr temp1' 1) 65408) in
  if Z.even temp1'
  then
    if Z.eqb temp2 43605
    then 0
    else u16z (Z.lxor temp2 8180)
  else u16z (Z.lxor temp2 33152).

Definition area1_fragment_rng_claim : Prop :=
  random_u16_step_z 0 = 57460 /\
  random_u16_step_z 57460 = 55882.

Theorem area1_fragment_rng_checked :
  area1_fragment_rng_claim.
Proof. vm_compute. split; reflexivity. Qed.

(** Selected table entries used by the previous and current fragment
    transforms.  Indices are [(u16 angle) >> 4], with cosine at index +1024.
    These exact binary32 words are checked against both generated tables. *)
Definition area1_fragment_sine_table_claim : Prop :=
  nth_error (gvar_init UArea1Math.v_gSineTable) 3092 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3212828969))) /\
  nth_error (gvar_init UArea1Math.v_gSineTable) 4116 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1023101370))) /\
  nth_error (gvar_init UArea1Math.v_gSineTable) 3492 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3209473657))) /\
  nth_error (gvar_init UArea1Math.v_gSineTable) 4516 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1058652672))) /\
  nth_error (gvar_init UArea1Math.v_gSineTable) 3591 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207794863))) /\
  nth_error (gvar_init UArea1Math.v_gSineTable) 4615 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060565983))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 3092 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3212828969))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 4116 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1023101370))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 3492 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3209473657))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 4516 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1058652672))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 3591 =
    Some (Init_float32 (Float32.of_bits (Int.repr 3207794863))) /\
  nth_error (gvar_init JArea1Math.v_gSineTable) 4615 =
    Some (Init_float32 (Float32.of_bits (Int.repr 1060565983))).

Theorem area1_fragment_sine_table_checked :
  area1_fragment_sine_table_claim.
Proof.
  unfold area1_fragment_sine_table_claim.
  vm_compute.
  repeat split.
Qed.

Record F32Vec3 : Type := {
  f32_x : float32;
  f32_y : float32;
  f32_z : float32
}.

Record F32LinearMatrix : Type := {
  f32_matrix_column_x : F32Vec3;
  f32_matrix_column_y : F32Vec3;
  f32_matrix_column_z : F32Vec3
}.

Definition f32_add3 (a b c : float32) : float32 :=
  Float32.add (Float32.add a b) c.

Definition f32_dot (a b : F32Vec3) : float32 :=
  f32_add3
    (Float32.mul (f32_x a) (f32_x b))
    (Float32.mul (f32_y a) (f32_y b))
    (Float32.mul (f32_z a) (f32_z b)).

Definition f32_vec_sub (a b : F32Vec3) : F32Vec3 := {|
  f32_x := Float32.sub (f32_x a) (f32_x b);
  f32_y := Float32.sub (f32_y a) (f32_y b);
  f32_z := Float32.sub (f32_z a) (f32_z b)
|}.

Definition f32_vec_add (a b : F32Vec3) : F32Vec3 := {|
  f32_x := Float32.add (f32_x a) (f32_x b);
  f32_y := Float32.add (f32_y a) (f32_y b);
  f32_z := Float32.add (f32_z a) (f32_z b)
|}.

(** Functional mirror of the generated [mtxf_rotate_zxy_and_translate]
    linear part, parameterized by the six already-selected sine-table words.
    It preserves the C expression association through explicit nested
    [Float32.add]/[Float32.mul]. *)
Definition f32_rotate_zxy_from_trig
    (sx cx sy cy sz cz : float32) : F32LinearMatrix := {|
  f32_matrix_column_x := {|
    f32_x :=
      Float32.add
        (Float32.mul cy cz)
        (Float32.mul (Float32.mul sx sy) sz);
    f32_y :=
      Float32.add
        (Float32.mul (Float32.neg cy) sz)
        (Float32.mul (Float32.mul sx sy) cz);
    f32_z := Float32.mul cx sy
  |};
  f32_matrix_column_y := {|
    f32_x := Float32.mul cx sz;
    f32_y := Float32.mul cx cz;
    f32_z := Float32.neg sx
  |};
  f32_matrix_column_z := {|
    f32_x :=
      Float32.add
        (Float32.mul (Float32.neg sy) cz)
        (Float32.mul (Float32.mul sx cy) sz);
    f32_y :=
      Float32.add
        (Float32.mul sy sz)
        (Float32.mul (Float32.mul sx cy) cz);
    f32_z := Float32.mul cx cy
  |}
|}.

Definition f32_linear_mul
    (matrix : F32LinearMatrix) (vector : F32Vec3) : F32Vec3 := {|
  f32_x := f32_dot (f32_matrix_column_x matrix) vector;
  f32_y := f32_dot (f32_matrix_column_y matrix) vector;
  f32_z := f32_dot (f32_matrix_column_z matrix) vector
|}.

Definition f32_linear_transpose_mul
    (matrix : F32LinearMatrix) (vector : F32Vec3) : F32Vec3 := {|
  f32_x :=
    f32_add3
      (Float32.mul
        (f32_x (f32_matrix_column_x matrix)) (f32_x vector))
      (Float32.mul
        (f32_x (f32_matrix_column_y matrix)) (f32_y vector))
      (Float32.mul
        (f32_x (f32_matrix_column_z matrix)) (f32_z vector));
  f32_y :=
    f32_add3
      (Float32.mul
        (f32_y (f32_matrix_column_x matrix)) (f32_x vector))
      (Float32.mul
        (f32_y (f32_matrix_column_y matrix)) (f32_y vector))
      (Float32.mul
        (f32_y (f32_matrix_column_z matrix)) (f32_z vector));
  f32_z :=
    f32_add3
      (Float32.mul
        (f32_z (f32_matrix_column_x matrix)) (f32_x vector))
      (Float32.mul
        (f32_z (f32_matrix_column_y matrix)) (f32_y vector))
      (Float32.mul
        (f32_z (f32_matrix_column_z matrix)) (f32_z vector))
|}.

Definition fragment_previous_pitch_sine : float32 :=
  Float32.of_bits (Int.repr 3212828969).
Definition fragment_previous_pitch_cosine : float32 :=
  Float32.of_bits (Int.repr 1023101370).
Definition fragment_current_pitch_sine : float32 :=
  Float32.of_bits (Int.repr 3209473657).
Definition fragment_current_pitch_cosine : float32 :=
  Float32.of_bits (Int.repr 1058652672).
Definition fragment_yaw_sine : float32 :=
  Float32.of_bits (Int.repr 3207794863).
Definition fragment_yaw_cosine : float32 :=
  Float32.of_bits (Int.repr 1060565983).

Definition fragment_previous_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    fragment_previous_pitch_sine fragment_previous_pitch_cosine
    fragment_yaw_sine fragment_yaw_cosine
    (f32_of_Z 0) (f32_of_Z 1).

Definition fragment_current_matrix : F32LinearMatrix :=
  f32_rotate_zxy_from_trig
    fragment_current_pitch_sine fragment_current_pitch_cosine
    fragment_yaw_sine fragment_yaw_cosine
    (f32_of_Z 0) (f32_of_Z 1).

Definition area1_fragment_old_state : F32Vec3 := {|
  f32_x := f32_of_Z (-2048);
  f32_y := f32_of_Z 768;
  f32_z := f32_of_Z (-1024)
|}.

(** The wing-cap box starts at macro position [(-3000,500,800)].  Its attack
    and rebound actions leave it at Y=540 when action 4 runs; the fragment
    initializer then applies [oPosY += 100.0f]. *)
Definition area1_fragment_pivot : F32Vec3 := {|
  f32_x := f32_of_Z (-3000);
  f32_y := f32_of_Z 640;
  f32_z := f32_of_Z 800
|}.

Definition concrete_area1_fragment_displacement : F32Vec3 :=
  let offset :=
    f32_vec_sub area1_fragment_old_state area1_fragment_pivot in
  let relative :=
    f32_linear_transpose_mul fragment_previous_matrix offset in
  let new_offset :=
    f32_linear_mul fragment_current_matrix relative in
  f32_vec_add area1_fragment_pivot new_offset.

(** Exact CompCert binary32 evaluation:

      old Object/State = (-2048, 768, -1024)
      displaced State  = (-2350.8427734375, 1878.6683349609375,
                          -714.5823974609375)

    The Y rise is about 1110.67, exceeding the 385-unit necessary lower bound.
    All three coordinates change.  This refutes the claim that every
    source-shaped Area-1 reused payload is Y-neutral.  It does not establish a
    stale pointer, slot selection, object-count/RNG prehistory, or a live top
    surface at this control point. *)
Theorem concrete_area1_fragment_displacement_is_route_sized_3d :
  Float32.to_bits
    (f32_x concrete_area1_fragment_displacement) =
      Int.repr 3306351996 /\
  Float32.to_bits
    (f32_y concrete_area1_fragment_displacement) =
      Int.repr 1156240739 /\
  Float32.to_bits
    (f32_z concrete_area1_fragment_displacement) =
      Int.repr 3291653446 /\
  Float32.cmp Clt
    (f32_of_Z (768 + 384))
    (f32_y concrete_area1_fragment_displacement) = true /\
  Float32.cmp Ceq
    (f32_x area1_fragment_old_state)
    (f32_x concrete_area1_fragment_displacement) = false /\
  Float32.cmp Ceq
    (f32_y area1_fragment_old_state)
    (f32_y concrete_area1_fragment_displacement) = false /\
  Float32.cmp Ceq
    (f32_z area1_fragment_old_state)
    (f32_z concrete_area1_fragment_displacement) = false.
Proof.
  vm_compute.
  repeat split.
Qed.

(** The phase boundary needed for the Area-1 bootstrap question.  The prior
    final object is the sample used to capture the top-owned platform pointer.
    Platform displacement updates State only; [collision_object_position] is
    the old Object sample observed by the following collision pass. *)
Record Area1StateObjectPhaseBoundary : Type := {
  area1_prior_final_object_position : PositionZ;
  area1_prior_top_floor_y : Z;
  area1_collision_object_position : PositionZ;
  area1_displaced_state_position : PositionZ
}.

Definition captured_stock_top_epoch
    (boundary : Area1StateObjectPhaseBoundary) : Prop :=
  live_top_platform_capture
    (area1_prior_final_object_position boundary)
    (area1_prior_top_floor_y boundary).

Definition collision_preserves_prior_object_sample
    (boundary : Area1StateObjectPhaseBoundary) : Prop :=
  area1_collision_object_position boundary =
    area1_prior_final_object_position boundary.

Definition route_relevant_area1_phase_split
    (boundary : Area1StateObjectPhaseBoundary) : Prop :=
  upper_warp_contact (area1_collision_object_position boundary) /\
  384 <
    position_y (area1_displaced_state_position boundary) -
    position_y (area1_collision_object_position boundary).

(** The key Area-1 result is independent of the replacement payload.  If the
    pointer was captured from the stock top at the preceding final query and
    the collision pass still samples that copied Object, the Object cannot
    overlap the upper warp.  A fragment may move State in 3D, but collision
    remains at the top-height sample. *)
Theorem captured_top_epoch_cannot_bootstrap_upper_warp_collision :
  forall boundary,
    captured_stock_top_epoch boundary ->
    collision_preserves_prior_object_sample boundary ->
    ~ upper_warp_contact (area1_collision_object_position boundary).
Proof.
  intros boundary Hcapture Hpreserved Hwarp.
  unfold captured_stock_top_epoch in Hcapture.
  unfold collision_preserves_prior_object_sample in Hpreserved.
  rewrite Hpreserved in Hwarp.
  eapply one_coordinate_cannot_contact_warp_and_capture_live_top.
  - exact Hwarp.
  - exact Hcapture.
Qed.

Theorem captured_top_epoch_cannot_realize_route_relevant_phase_split :
  forall boundary,
    captured_stock_top_epoch boundary ->
    collision_preserves_prior_object_sample boundary ->
    ~ route_relevant_area1_phase_split boundary.
Proof.
  intros boundary Hcapture Hpreserved (Hwarp & _).
  eapply captured_top_epoch_cannot_bootstrap_upper_warp_collision;
    eauto.
Qed.

(** Minimal arithmetic model of the object-update lifetime ordering checked by
    [update_objects_direct_callee_order_us/jp].  Deactivation during terrain
    update cannot free/reuse the same slot before the current apply, because
    unloading is later.  A next-frame reuse is after the next
    [clear_dynamic_surfaces], so it cannot simultaneously use the preceding
    frame's top surface without a separate surface-lifetime violation. *)
Record Area1TopSlotTiming : Type := {
  timing_current_terrain : nat;
  timing_current_apply : nat;
  timing_current_unload : nat;
  timing_next_clear_surfaces : nat;
  timing_next_terrain : nat;
  timing_next_apply : nat
}.

Definition stock_area1_top_slot_timing
    (timing : Area1TopSlotTiming) : Prop :=
  (timing_current_terrain timing < timing_current_apply timing)%nat /\
  (timing_current_apply timing < timing_current_unload timing)%nat /\
  (timing_current_unload timing <
    timing_next_clear_surfaces timing)%nat /\
  (timing_next_clear_surfaces timing <
    timing_next_terrain timing)%nat /\
  (timing_next_terrain timing < timing_next_apply timing)%nat.

Theorem top_slot_cannot_be_freed_and_reused_before_current_apply :
  forall timing (free_time reuse_time : nat),
    stock_area1_top_slot_timing timing ->
    (timing_current_unload timing <= free_time)%nat ->
    (free_time <= reuse_time)%nat ->
    ~ (reuse_time < timing_current_apply timing)%nat.
Proof.
  intros timing free_time reuse_time
    (_ & Happly_unload & _ & _ & _)
    Hfree Hreuse Hbefore.
  lia.
Qed.

Theorem next_apply_top_slot_reuse_is_after_surface_clear :
  forall timing (reuse_time : nat),
    stock_area1_top_slot_timing timing ->
    (timing_next_terrain timing <= reuse_time)%nat ->
    (reuse_time < timing_next_apply timing)%nat ->
    (timing_next_clear_surfaces timing < reuse_time)%nat.
Proof.
  intros timing reuse_time
    (_ & _ & _ & Hclear_terrain & _)
    Hterrain _.
  lia.
Qed.

Definition area1_phase_split_boundary_claim : Prop :=
  area1_fragment_writer_source_claim /\
  area1_fragment_parent_source_claim /\
  area1_box_rebound_source_claim /\
  (area1_box_action4_y = 540 /\ area1_box_action4_y + 100 = 640) /\
  area1_fragment_rng_claim /\
  area1_fragment_sine_table_claim /\
  (Float32.cmp Clt
    (f32_of_Z (768 + 384))
    (f32_y concrete_area1_fragment_displacement) = true) /\
  (forall boundary,
    captured_stock_top_epoch boundary ->
    collision_preserves_prior_object_sample boundary ->
    ~ route_relevant_area1_phase_split boundary).

Theorem area1_phase_split_boundary_checked :
  area1_phase_split_boundary_claim.
Proof.
  unfold area1_phase_split_boundary_claim.
  split; [exact area1_fragment_writer_source_checked |].
  split; [exact area1_fragment_parent_source_checked |].
  split; [exact area1_box_rebound_source_checked |].
  split; [exact area1_box_action4_and_fragment_pivot_y_checked |].
  split; [exact area1_fragment_rng_checked |].
  split; [exact area1_fragment_sine_table_checked |].
  split.
  - exact
      (proj1
        (proj2
          (proj2
            (proj2
              concrete_area1_fragment_displacement_is_route_sized_3d)))).
  - exact captured_top_epoch_cannot_realize_route_relevant_phase_split.
Qed.
