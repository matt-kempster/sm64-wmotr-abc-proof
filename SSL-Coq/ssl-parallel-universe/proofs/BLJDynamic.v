From Coq Require Import Bool Lia List PArith.BinPos QArith ZArith.
From compcert Require Import AST Clight Floats Integers.
From SSLPU.Generated Require Import grindel_behavior mario
  mario_actions_airborne mario_step object_list_processor
  platform_displacement.
From SSLPU.Proofs Require Import ASTFacts BLJGeometry BLJRoute Spec.

Import ListNotations.

Fixpoint ident_appears_before
    (first second : ident) (ids : list ident) : bool :=
  match ids with
  | [] => false
  | id :: rest =>
      if Pos.eqb first id
      then ident_mem second rest
      else ident_appears_before first second rest
  end.

Fixpoint stmt_returns_int_bits (bits : Z) (s : statement) : bool :=
  match s with
  | Ssequence s1 s2 =>
      stmt_returns_int_bits bits s1 || stmt_returns_int_bits bits s2
  | Sifthenelse _ s1 s2 =>
      stmt_returns_int_bits bits s1 || stmt_returns_int_bits bits s2
  | Sloop s1 s2 =>
      stmt_returns_int_bits bits s1 || stmt_returns_int_bits bits s2
  | Sreturn (Some (Econst_int value _)) => Int.eq value (Int.repr bits)
  | Sswitch _ cases => cases_return_int_bits bits cases
  | Slabel _ body => stmt_returns_int_bits bits body
  | _ => false
  end
with cases_return_int_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_returns_int_bits bits body || cases_return_int_bits bits rest
  end.

Definition float32_point_three_five_bits : Z := 1051931443.
Definition float32_five_bits : Z := 1084227584.
Definition float32_four_bits : Z := 1082130432.
Definition float32_ten_bits : Z := 1092616192.
Definition float32_sixteen_bits : Z := 1098907648.
Definition float32_twenty_bits : Z := 1101004800.
Definition float32_thirty_bits : Z := 1106247680.
Definition float32_two_bits : Z := 1073741824.

Fixpoint stmt_contains_loop (s : statement) : bool :=
  match s with
  | Ssequence s1 s2 => stmt_contains_loop s1 || stmt_contains_loop s2
  | Sifthenelse _ s1 s2 => stmt_contains_loop s1 || stmt_contains_loop s2
  | Sloop _ _ => true
  | Sswitch _ cases => cases_contain_loop cases
  | Slabel _ body => stmt_contains_loop body
  | _ => false
  end
with cases_contain_loop (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_contains_loop body || cases_contain_loop rest
  end.

Definition generated_long_jump_case_mentions_thirty : bool :=
  match find_switch_case_body_s
      act_long_jump (fn_body mario.f_set_mario_action_airborne) with
  | Some body => stmt_mentions_float32_bits float32_thirty_bits body
  | None => false
  end.

Record generated_dynamic_blj_source_shape : Prop := {
  shape_grindel_bottom_idle_contains_ten_unit_random_span :
    stmt_mentions_float32_bits float32_ten_bits
      (fn_body grindel_behavior.f_grindel_thwomp_act_idle_at_bottom) = true;
  shape_grindel_bottom_idle_contains_twenty_unit_minimum :
    stmt_mentions_float32_bits float32_twenty_bits
      (fn_body grindel_behavior.f_grindel_thwomp_act_idle_at_bottom) = true;
  shape_grindel_raise_checks_parameter_plus_forty :
    stmt_mentions_int_bits 40
      (fn_body grindel_behavior.f_grindel_thwomp_act_raise) = true;
  shape_grindel_raise_contains_ten_unit_step :
    stmt_mentions_float32_bits float32_ten_bits
      (fn_body grindel_behavior.f_grindel_thwomp_act_raise) = true;
  shape_grindel_raise_contains_final_five_unit_step :
    stmt_mentions_float32_bits float32_five_bits
      (fn_body grindel_behavior.f_grindel_thwomp_act_raise) = true;
  shape_grindel_raise_writes_object_raw_data :
    assigns_through_field_s grindel_behavior._rawData
      (fn_body grindel_behavior.f_grindel_thwomp_act_raise) = true;
  shape_terrain_objects_update_before_platform_displacement :
    ident_appears_before object_list_processor._update_terrain_objects
      object_list_processor._apply_mario_platform_displacement
      (direct_callees_s
        (fn_body object_list_processor.f_update_objects)) = true;
  shape_platform_displacement_precedes_mario_action_objects :
    ident_appears_before
      object_list_processor._apply_mario_platform_displacement
      object_list_processor._update_non_terrain_objects
      (direct_callees_s
        (fn_body object_list_processor.f_update_objects)) = true;
  shape_platform_displacement_reads_x_velocity_slot_nine :
    stmt_mentions_int_bits 9
      (fn_body platform_displacement.f_apply_platform_displacement) = true;
  shape_platform_displacement_omits_y_velocity_slot_ten :
    stmt_mentions_int_bits 10
      (fn_body platform_displacement.f_apply_platform_displacement) = false;
  shape_platform_displacement_reads_z_velocity_slot_eleven :
    stmt_mentions_int_bits 11
      (fn_body platform_displacement.f_apply_platform_displacement) = true;
  shape_action_executor_has_subframe_transition_loop :
    stmt_contains_loop (fn_body mario.f_execute_mario_action) = true;
  shape_action_executor_calls_moving_actions :
    ident_mem mario._mario_execute_moving_action
      (direct_callees_s (fn_body mario.f_execute_mario_action)) = true;
  shape_action_executor_calls_airborne_actions :
    ident_mem mario._mario_execute_airborne_action
      (direct_callees_s (fn_body mario.f_execute_mario_action)) = true;
  shape_long_jump_sets_thirty_vertical_velocity :
    generated_long_jump_case_mentions_thirty = true;
  shape_air_update_calls_approach_f32 :
    ident_mem mario_actions_airborne._approach_f32
      (direct_callees_s
        (fn_body mario_actions_airborne.f_update_air_without_turn)) = true;
  shape_air_update_contains_point_three_five_drag :
    stmt_mentions_float32_bits float32_point_three_five_bits
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_air_update_uses_generated_trig_table :
    stmt_mentions_var mario_actions_airborne._gSineTable
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_air_update_contains_full_back_acceleration :
    stmt_mentions_float32_bits float32_one_point_five_bits
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_air_update_contains_negative_soft_cap :
    stmt_mentions_float32_bits float32_sixteen_bits
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_air_update_contains_two_unit_soft_cap_correction :
    stmt_mentions_float32_bits float32_two_bits
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_air_update_assigns_forward_velocity :
    assigns_through_field_s mario_actions_airborne._forwardVel
      (fn_body mario_actions_airborne.f_update_air_without_turn) = true;
  shape_common_air_action_updates_speed_before_step :
    ident_appears_before mario_actions_airborne._update_air_without_turn
      mario_actions_airborne._perform_air_step
      (direct_callees_s
        (fn_body mario_actions_airborne.f_common_air_action_step)) = true;
  shape_air_quarter_step_calls_find_floor :
    ident_mem mario_step._find_floor
      (direct_callees_s
        (fn_body mario_step.f_perform_air_quarter_step)) = true;
  shape_air_quarter_step_has_landed_return :
    stmt_returns_int_bits 1
      (fn_body mario_step.f_perform_air_quarter_step) = true;
  shape_air_quarter_step_writes_position :
    assigns_through_field_s mario_step._pos
      (fn_body mario_step.f_perform_air_quarter_step) = true;
  shape_air_quarter_step_updates_floor_height :
    assigns_through_field_s mario_step._floorHeight
      (fn_body mario_step.f_perform_air_quarter_step) = true;
  shape_air_step_calls_gravity_after_quarter_steps :
    ident_appears_before mario_step._perform_air_quarter_step
      mario_step._apply_gravity
      (direct_callees_s (fn_body mario_step.f_perform_air_step)) = true;
  shape_gravity_contains_four_unit_update :
    stmt_mentions_float32_bits float32_four_bits
      (fn_body mario_step.f_apply_gravity) = true
}.

Theorem generated_dynamic_blj_source_shape_holds :
  generated_dynamic_blj_source_shape.
Proof.
  constructor; vm_compute; reflexivity.
Qed.

Definition grindel_center_x : Z := 3297.
Definition grindel_center_z : Z := 95.
Definition grindel_top_half_extent : Z := 224.
Definition grindel_top_local_y : Z := 450.
Definition grindel_behavior_parameter : Z := 28.
Definition grindel_rise_per_frame : Z := 10.
Definition grindel_full_rise_frames : nat := 69%nat.
Definition grindel_bottom_idle_min_frames : nat := 20%nat.
Definition static_mesh_min_x : Z := -3993.
Definition static_mesh_max_x : Z := 3994.

Definition grindel_top_min_x : Z :=
  grindel_center_x - grindel_top_half_extent.
Definition grindel_top_max_x : Z :=
  grindel_center_x + grindel_top_half_extent.
Definition grindel_top_min_z : Z :=
  grindel_center_z - grindel_top_half_extent.
Definition grindel_top_max_z : Z :=
  grindel_center_z + grindel_top_half_extent.

Definition grindel_setup_state : pu_state := {|
  state_area := ssl_area2;
  state_x := grindel_center_x;
  state_z := grindel_center_z
|}.

Theorem grindel_setup_state_in_area2_bounds :
  state_in_area2_bounds grindel_setup_state.
Proof.
  unfold state_in_area2_bounds, coord_in_area2_bounds,
    grindel_setup_state, grindel_center_x, grindel_center_z,
    ssl_area2_min, ssl_area2_max.
  simpl.
  lia.
Qed.

Theorem grindel_top_footprint_in_area2_bounds :
  coord_in_area2_bounds grindel_top_min_x /\
  coord_in_area2_bounds grindel_top_max_x /\
  coord_in_area2_bounds grindel_top_min_z /\
  coord_in_area2_bounds grindel_top_max_z.
Proof.
  unfold coord_in_area2_bounds, grindel_top_min_x, grindel_top_max_x,
    grindel_top_min_z, grindel_top_max_z, grindel_center_x,
    grindel_center_z, grindel_top_half_extent, ssl_area2_min,
    ssl_area2_max.
  lia.
Qed.

Definition full_back_air_update20 (speed20 : Z) : Z :=
  let approached :=
    if (7 <? speed20)%Z then speed20 - 7
    else if (speed20 <? -7)%Z then speed20 + 7
    else 0 in
  let accelerated := approached - 30 in
  if (accelerated <? -320)%Z then accelerated + 40
  else accelerated.

Fixpoint full_back_speed20_after (frames : nat) (speed20 : Z) : Z :=
  match frames with
  | O => speed20
  | S rest =>
      full_back_air_update20
        (full_back_speed20_after rest speed20)
  end.

Fixpoint full_back_speed20_sum (frames : nat) (speed20 : Z) : Z :=
  match frames with
  | O => 0
  | S rest =>
      let next := full_back_air_update20 speed20 in
      next + full_back_speed20_sum rest next
  end.

Definition bootstrap_pre_long_jump_speed20 : Z := 220.
Definition bootstrap_takeoff_speed20 : Z := 330.
Definition bootstrap_catch_frame : nat := 16%nat.
Definition bootstrap_full_frames_before_catch : nat := 15%nat.
Definition bootstrap_catch_qsteps : Z := 3.

Definition bootstrap_catch_displacement80 : Z :=
  4 * full_back_speed20_sum
        bootstrap_full_frames_before_catch bootstrap_takeoff_speed20 +
  bootstrap_catch_qsteps *
    full_back_speed20_after bootstrap_catch_frame bootstrap_takeoff_speed20.

Definition bootstrap_initial_x80 : Z := 80 * grindel_center_x.

Fixpoint bootstrap_full_qstep_trace80
    (frames : nat) (speed20 x80 : Z) : list Z :=
  match frames with
  | O => []
  | S rest =>
      let next_speed := full_back_air_update20 speed20 in
      let x1 := x80 - next_speed in
      let x2 := x1 - next_speed in
      let x3 := x2 - next_speed in
      let x4 := x3 - next_speed in
      [x1; x2; x3; x4] ++
      bootstrap_full_qstep_trace80 rest next_speed x4
  end.

Definition bootstrap_frame16_start_x80 : Z :=
  bootstrap_initial_x80 -
  4 * full_back_speed20_sum
        bootstrap_full_frames_before_catch bootstrap_takeoff_speed20.

Definition bootstrap_frame16_speed20 : Z :=
  full_back_speed20_after bootstrap_catch_frame bootstrap_takeoff_speed20.

Definition bootstrap_qstep_trace80 : list Z :=
  bootstrap_full_qstep_trace80 bootstrap_full_frames_before_catch
    bootstrap_takeoff_speed20 bootstrap_initial_x80 ++
  [ bootstrap_frame16_start_x80 - bootstrap_frame16_speed20;
    bootstrap_frame16_start_x80 - 2 * bootstrap_frame16_speed20;
    bootstrap_frame16_start_x80 - 3 * bootstrap_frame16_speed20 ].

Definition bootstrap_catch_x80 : Z :=
  bootstrap_initial_x80 - bootstrap_catch_displacement80.

Definition x80_in_grindel_footprint (x80 : Z) : bool :=
  (80 * grindel_top_min_x <=? x80)%Z &&
  (x80 <=? 80 * grindel_top_max_x)%Z.

Theorem bootstrap_source_gate_and_long_jump_multiplier :
  200 < bootstrap_pre_long_jump_speed20 /\
  2 * bootstrap_takeoff_speed20 =
    3 * bootstrap_pre_long_jump_speed20.
Proof.
  unfold bootstrap_pre_long_jump_speed20, bootstrap_takeoff_speed20.
  lia.
Qed.

Theorem bootstrap_reaches_negative_eight_point_four :
  full_back_speed20_after bootstrap_catch_frame
    bootstrap_takeoff_speed20 = -168.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem bootstrap_catch_displacement_is_thirty_two_point_seven :
  bootstrap_catch_displacement80 = 2616.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem bootstrap_every_qstep_stays_on_grindel_top :
  forallb x80_in_grindel_footprint bootstrap_qstep_trace80 = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Definition long_jump_vertical_velocity (frame_index : nat) : Z :=
  30 - 4 * Z.of_nat frame_index.

Fixpoint long_jump_vertical_displacement4 (frames : nat) : Z :=
  match frames with
  | O => 0
  | S rest =>
      long_jump_vertical_displacement4 rest +
      4 * long_jump_vertical_velocity rest
  end.

Definition bootstrap_y4_before_catch_frame : Z :=
  4 * grindel_top_local_y +
  long_jump_vertical_displacement4 bootstrap_full_frames_before_catch.

Definition bootstrap_catch_qstep_y4 (qstep : nat) : Z :=
  bootstrap_y4_before_catch_frame +
  Z.of_nat qstep *
    long_jump_vertical_velocity bootstrap_full_frames_before_catch.

Definition grindel_first_rise_floor_y4 : Z :=
  4 * (grindel_top_local_y + grindel_rise_per_frame).

Theorem bottom_idle_has_room_for_bootstrap_timing :
  (bootstrap_full_frames_before_catch <= grindel_bottom_idle_min_frames)%nat.
Proof.
  unfold bootstrap_full_frames_before_catch,
    grindel_bottom_idle_min_frames.
  lia.
Qed.

Theorem first_grindel_rise_catches_bootstrap_qstep_three :
  grindel_first_rise_floor_y4 < bootstrap_catch_qstep_y4 2 /\
  bootstrap_catch_qstep_y4 3 <= grindel_first_rise_floor_y4.
Proof.
  vm_compute.
  split; [reflexivity | discriminate].
Qed.

Definition q_of_scaled (value scale : Z) : Q :=
  inject_Z value / inject_Z scale.

Local Open Scope Q_scope.

Definition positive_q_trunc (value : Q) : Z :=
  (Qnum value / Z.pos (Qden value))%Z.

Definition full_back_drag : Q := (17 # 20).
Definition full_back_soft_cap_acceleration : Q := (23 # 20).
Definition bootstrap_catch_magnitude : Q := (42 # 5).

Definition interrupted_blj_magnitude (magnitude : Q) : Q :=
  let provisional :=
    (3 # 2) * magnitude + full_back_soft_cap_acceleration in
  if Qle_bool provisional 16 then provisional else provisional - 2.

Fixpoint interrupted_blj_magnitude_after
    (cycles : nat) (magnitude : Q) : Q :=
  match cycles with
  | O => magnitude
  | S rest =>
      interrupted_blj_magnitude
        (interrupted_blj_magnitude_after rest magnitude)
  end.

Fixpoint interrupted_qstep_sum
    (cycles : nat) (magnitude : Q) : Q :=
  match cycles with
  | O => 0
  | S rest =>
      interrupted_qstep_sum rest magnitude +
      interrupted_blj_magnitude_after (S rest) magnitude / 4
  end.

Definition grindel_fast_recycles : nat := 9%nat.
Definition bootstrap_catch_x : Q := q_of_scaled bootstrap_catch_x80 80.

Definition grindel_recycle_x (cycles : nat) : Q :=
  bootstrap_catch_x +
  interrupted_qstep_sum cycles bootstrap_catch_magnitude.

Definition q_in_grindel_footprint (x : Q) : bool :=
  Qle_bool (inject_Z grindel_top_min_x) x &&
  Qle_bool x (inject_Z grindel_top_max_x).

Definition grindel_recycle_positions : list Q :=
  map grindel_recycle_x (seq 1 grindel_fast_recycles).

Definition grindel_release_x : Q :=
  grindel_recycle_x grindel_fast_recycles.

Definition release_first_air_magnitude : Q :=
  interrupted_blj_magnitude_after (S grindel_fast_recycles)
    bootstrap_catch_magnitude.

Definition release_first_qstep_x : Q :=
  grindel_release_x + release_first_air_magnitude / 4.

Theorem nine_grindel_recycles_stay_on_the_top :
  forallb q_in_grindel_footprint grindel_recycle_positions = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem tenth_long_jump_releases_over_the_top_edge :
  positive_q_trunc grindel_release_x = 3493%Z /\
  (grindel_release_x < inject_Z grindel_top_max_x)%Q /\
  (inject_Z grindel_top_max_x < release_first_qstep_x)%Q.
Proof.
  split.
  - vm_compute; reflexivity.
  - split.
    + vm_compute. reflexivity.
    + vm_compute. reflexivity.
Qed.

Definition release_qstep_x (qstep : nat) : Q :=
  grindel_release_x +
  inject_Z (Z.of_nat qstep) * release_first_air_magnitude / 4.

Definition release_static_qstep_xs : list Z :=
  map (fun qstep => positive_q_trunc (release_qstep_x qstep)) (seq 1 4).

Definition outer_floor_anchor_x : Q := release_qstep_x 4.

Definition first_floor_null_target_x : Q :=
  outer_floor_anchor_x +
  (release_first_air_magnitude - full_back_drag) / 4.

Theorem release_static_qstep_coordinates :
  release_static_qstep_xs = [3609%Z; 3726%Z; 3842%Z; 3958%Z].
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem release_reaches_outer_floor_then_floor_null :
  positive_q_trunc outer_floor_anchor_x = 3958%Z /\
  (outer_floor_anchor_x < inject_Z static_mesh_max_x)%Q /\
  (inject_Z static_mesh_max_x < first_floor_null_target_x)%Q /\
  positive_q_trunc first_floor_null_target_x = 4074%Z.
Proof.
  split.
  - vm_compute; reflexivity.
  - split.
    + vm_compute; reflexivity.
    + split.
      * vm_compute; reflexivity.
      * vm_compute; reflexivity.
Qed.

Definition grindel_release_start_y : Z :=
  grindel_top_local_y +
  (1 + Z.of_nat grindel_fast_recycles) * grindel_rise_per_frame.

Definition release_full_frames_before_landing : nat := 26%nat.

Definition release_y4_before_landing_frame : Z :=
  4 * grindel_release_start_y +
  long_jump_vertical_displacement4 release_full_frames_before_landing.

Definition release_landing_qstep_y4 (qstep : nat) : Z :=
  release_y4_before_landing_frame +
  Z.of_nat qstep *
    long_jump_vertical_velocity release_full_frames_before_landing.

Theorem release_lands_on_frame_27_qstep_two :
  release_y4_before_landing_frame = 120%Z /\
  (0 < release_landing_qstep_y4 1)%Z /\
  (release_landing_qstep_y4 2 <= 0)%Z.
Proof.
  vm_compute.
  repeat split; discriminate.
Qed.

Definition release_landing_magnitude : Q :=
  release_first_air_magnitude -
  inject_Z (Z.of_nat release_full_frames_before_landing) * full_back_drag.

Theorem release_lands_with_growth_seed :
  (400 < release_landing_magnitude)%Q.
Proof.
  vm_compute.
  reflexivity.
Qed.

Definition oob_air_frames : Z := 16.
Definition oob_cycle_drag : Q :=
  inject_Z oob_air_frames * full_back_drag.

Definition oob_landing_step (magnitude : Q) : Q :=
  (3 # 2) * magnitude - oob_cycle_drag.

Fixpoint oob_landing_magnitude_after (cycles : nat) : Q :=
  match cycles with
  | O => release_landing_magnitude
  | S rest => oob_landing_step (oob_landing_magnitude_after rest)
  end.

Definition oob_target_for_cycle (cycle : nat) : Q :=
  outer_floor_anchor_x +
  ((3 # 2) * oob_landing_magnitude_after cycle - full_back_drag) / 4.

Definition signed16_wrap (value : Z) : Z :=
  let residue := value mod 65536 in
  if (residue <? 32768)%Z then residue else residue - 65536.

Definition oob_target_alias_x (cycle : nat) : Z :=
  signed16_wrap (positive_q_trunc (oob_target_for_cycle cycle)).

Definition misses_static_mesh_x (x : Z) : bool :=
  (x <? static_mesh_min_x)%Z || (static_mesh_max_x <? x)%Z.

Definition pu_entry_cycle_index : nat := 20%nat.
Definition pu_entry_cycle_count : nat := 21%nat.

Definition prior_oob_aliases_miss_static_mesh : bool :=
  forallb misses_static_mesh_x
    (map oob_target_alias_x (seq 0 pu_entry_cycle_index)).

Theorem first_20_oob_targets_miss_the_static_mesh :
  prior_oob_aliases_miss_static_mesh = true.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem oob_cycle_21_reaches_pu_alias :
  positive_q_trunc (oob_target_for_cycle pu_entry_cycle_index) = 522262%Z /\
  oob_target_alias_x pu_entry_cycle_index = (-2026)%Z /\
  (inject_Z first_parallel_universe <=
    oob_target_for_cycle pu_entry_cycle_index)%Q.
Proof.
  split.
  - vm_compute; reflexivity.
  - split.
    + vm_compute; reflexivity.
    + vm_compute; discriminate.
Qed.

Local Close Scope Q_scope.

Record horizontal_floor_triangle := {
  triangle_x1 : Z; triangle_z1 : Z;
  triangle_x2 : Z; triangle_z2 : Z;
  triangle_x3 : Z; triangle_z3 : Z
}.

Definition floor_edge_value
    (x z x1 z1 x2 z2 : Z) : Z :=
  (z1 - z) * (x2 - x1) - (x1 - x) * (z2 - z1).

Definition point_in_floor_triangle
    (x z : Z) (triangle : horizontal_floor_triangle) : Prop :=
  0 <= floor_edge_value x z
    (triangle_x1 triangle) (triangle_z1 triangle)
    (triangle_x2 triangle) (triangle_z2 triangle) /\
  0 <= floor_edge_value x z
    (triangle_x2 triangle) (triangle_z2 triangle)
    (triangle_x3 triangle) (triangle_z3 triangle) /\
  0 <= floor_edge_value x z
    (triangle_x3 triangle) (triangle_z3 triangle)
    (triangle_x1 triangle) (triangle_z1 triangle).

Definition outer_edge_floor_triangle : horizontal_floor_triangle := {|
  triangle_x1 := 3072; triangle_z1 := -283;
  triangle_x2 := 3994; triangle_z2 := 4096;
  triangle_x3 := 3994; triangle_z3 := -283
|}.

Definition pu_alias_floor_triangle : horizontal_floor_triangle := {|
  triangle_x1 := -2546; triangle_z1 := -25;
  triangle_x2 := -1522; triangle_z2 := 230;
  triangle_x3 := -1522; triangle_z3 := -25
|}.

Theorem release_static_qsteps_have_floor :
  point_in_floor_triangle 3609 grindel_center_z outer_edge_floor_triangle /\
  point_in_floor_triangle 3726 grindel_center_z outer_edge_floor_triangle /\
  point_in_floor_triangle 3842 grindel_center_z outer_edge_floor_triangle /\
  point_in_floor_triangle 3958 grindel_center_z outer_edge_floor_triangle.
Proof.
  vm_compute.
  repeat split.
  all: discriminate.
Qed.

Theorem final_alias_has_static_floor :
  point_in_floor_triangle (-2026) grindel_center_z
    pu_alias_floor_triangle.
Proof.
  vm_compute.
  repeat split.
  all: discriminate.
Qed.

Definition grindel_dynamic_counterexample_state : pu_state := {|
  state_area := ssl_area2;
  state_x := positive_q_trunc (oob_target_for_cycle pu_entry_cycle_index);
  state_z := grindel_center_z
|}.

Theorem grindel_dynamic_counterexample_state_is_in_pu :
  state_in_parallel_universe grindel_dynamic_counterexample_state.
Proof.
  left.
  unfold grindel_dynamic_counterexample_state, parallel_universe_coord,
    first_parallel_universe.
  vm_compute.
  discriminate.
Qed.

Theorem grindel_rise_has_enough_frames_for_bootstrap_and_release :
  (1 + grindel_fast_recycles + 1 <= grindel_full_rise_frames)%nat.
Proof.
  unfold grindel_fast_recycles, grindel_full_rise_frames.
  lia.
Qed.

Theorem ssl_area2_grindel_dynamic_counterexample_certificate :
  generated_dynamic_blj_source_shape /\
  input_allows_long_jump_land_recycle a_z_recycle_input /\
  state_in_area2_bounds grindel_setup_state /\
  (200 < bootstrap_pre_long_jump_speed20 /\
   2 * bootstrap_takeoff_speed20 =
     3 * bootstrap_pre_long_jump_speed20) /\
  (bootstrap_full_frames_before_catch <= grindel_bottom_idle_min_frames)%nat /\
  forallb x80_in_grindel_footprint bootstrap_qstep_trace80 = true /\
  (grindel_first_rise_floor_y4 < bootstrap_catch_qstep_y4 2 /\
   bootstrap_catch_qstep_y4 3 <= grindel_first_rise_floor_y4) /\
  forallb q_in_grindel_footprint grindel_recycle_positions = true /\
  (1 + grindel_fast_recycles + 1 <= grindel_full_rise_frames)%nat /\
  release_static_qstep_xs = [3609%Z; 3726%Z; 3842%Z; 3958%Z] /\
  (point_in_floor_triangle 3609 grindel_center_z outer_edge_floor_triangle /\
   point_in_floor_triangle 3726 grindel_center_z outer_edge_floor_triangle /\
   point_in_floor_triangle 3842 grindel_center_z outer_edge_floor_triangle /\
   point_in_floor_triangle 3958 grindel_center_z outer_edge_floor_triangle) /\
  (inject_Z static_mesh_max_x < first_floor_null_target_x)%Q /\
  (release_y4_before_landing_frame = 120%Z /\
   (0 < release_landing_qstep_y4 1)%Z /\
   (release_landing_qstep_y4 2 <= 0)%Z) /\
  (400 < release_landing_magnitude)%Q /\
  prior_oob_aliases_miss_static_mesh = true /\
  positive_q_trunc (oob_target_for_cycle pu_entry_cycle_index) = 522262%Z /\
  oob_target_alias_x pu_entry_cycle_index = (-2026)%Z /\
  point_in_floor_triangle (-2026) grindel_center_z
    pu_alias_floor_triangle /\
  state_in_parallel_universe grindel_dynamic_counterexample_state.
Proof.
  refine (conj generated_dynamic_blj_source_shape_holds _).
  refine (conj a_z_recycle_input_allows_long_jump_land_recycle _).
  refine (conj grindel_setup_state_in_area2_bounds _).
  refine (conj bootstrap_source_gate_and_long_jump_multiplier _).
  refine (conj bottom_idle_has_room_for_bootstrap_timing _).
  refine (conj bootstrap_every_qstep_stays_on_grindel_top _).
  refine (conj first_grindel_rise_catches_bootstrap_qstep_three _).
  refine (conj nine_grindel_recycles_stay_on_the_top _).
  refine (conj grindel_rise_has_enough_frames_for_bootstrap_and_release _).
  refine (conj release_static_qstep_coordinates _).
  refine (conj release_static_qsteps_have_floor _).
  refine (conj
    (proj1 (proj2 (proj2 release_reaches_outer_floor_then_floor_null))) _).
  refine (conj release_lands_on_frame_27_qstep_two _).
  refine (conj release_lands_with_growth_seed _).
  refine (conj first_20_oob_targets_miss_the_static_mesh _).
  refine (conj (proj1 oob_cycle_21_reaches_pu_alias) _).
  refine (conj (proj1 (proj2 oob_cycle_21_reaches_pu_alias)) _).
  refine (conj final_alias_has_static_floor _).
  exact grindel_dynamic_counterexample_state_is_in_pu.
Qed.
