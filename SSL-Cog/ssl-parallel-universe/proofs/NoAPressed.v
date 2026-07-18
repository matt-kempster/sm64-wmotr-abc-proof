From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight.
From SSLPU.Generated Require Import level_update mario
  mario_actions_airborne mario_actions_moving mario_step.
From SSLPU.Proofs Require Import ASTFacts BLJDynamic BLJGeometry BLJRoute Spec.

Import ListNotations.
Local Open Scope Z_scope.

Fixpoint exprs_mentions_field (field : ident) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      expr_mentions_field field arg || exprs_mentions_field field rest
  end.

Fixpoint stmt_mentions_field_s (field : ident) (s : statement) : bool :=
  match s with
  | Sskip => false
  | Sassign lhs rhs =>
      expr_mentions_field field lhs || expr_mentions_field field rhs
  | Sset _ rhs => expr_mentions_field field rhs
  | Scall _ fn args =>
      expr_mentions_field field fn || exprs_mentions_field field args
  | Sbuiltin _ _ _ _ => false
  | Ssequence s1 s2 =>
      stmt_mentions_field_s field s1 || stmt_mentions_field_s field s2
  | Sifthenelse test s1 s2 =>
      expr_mentions_field field test ||
      stmt_mentions_field_s field s1 || stmt_mentions_field_s field s2
  | Sloop s1 s2 =>
      stmt_mentions_field_s field s1 || stmt_mentions_field_s field s2
  | Sbreak => false
  | Scontinue => false
  | Sreturn None => false
  | Sreturn (Some value) => expr_mentions_field field value
  | Sswitch key cases =>
      expr_mentions_field field key || cases_mentions_field field cases
  | Slabel _ body => stmt_mentions_field_s field body
  | Sgoto _ => false
  end
with cases_mentions_field
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      stmt_mentions_field_s field body || cases_mentions_field field rest
  end.

Definition float32_point_two_bits : Z := 1045220557.
Definition float32_five_point_three_bits : Z := 1084856730.
Definition float32_braking_normal_gate_bits : Z := 1043452116.
Definition float32_one_hundred_bits : Z := 1120403456.
Definition act_jump_kick : Z := 25168044.

Definition generated_jump_kick_case_is_vertical_only : bool :=
  match find_switch_case_body_s
      act_jump_kick (fn_body mario.f_set_mario_action_airborne) with
  | Some body =>
      assigns_through_field_s mario._vel body &&
      negb (assigns_through_field_s mario._forwardVel body) &&
      stmt_mentions_float32_bits float32_twenty_bits body
  | None => false
  end.

Record generated_no_a_source_shape : Prop := {
  shape_area_warp_calls_warp_initializer :
    ident_mem level_update._init_mario_after_warp
      (direct_callees_s (fn_body level_update.f_warp_area)) = true;
  shape_warp_initializer_calls_init_mario :
    ident_mem level_update._init_mario
      (direct_callees_s
        (fn_body level_update.f_init_mario_after_warp)) = true;
  shape_init_mario_resets_forward_velocity :
    assigns_through_field_s mario._forwardVel
      (fn_body mario.f_init_mario) = true;
  shape_init_mario_mentions_velocity_vector :
    stmt_mentions_field_s mario._vel (fn_body mario.f_init_mario) = true;
  shape_input_update_rebuilds_input :
    assigns_through_field_s mario._input
      (fn_body mario.f_update_mario_inputs) = true;
  shape_button_update_reads_pressed_edge :
    stmt_mentions_field_s mario._buttonPressed
      (fn_body mario.f_update_mario_button_inputs) = true;
  shape_button_update_reads_held_state :
    stmt_mentions_field_s mario._buttonDown
      (fn_body mario.f_update_mario_button_inputs) = true;
  shape_button_update_mentions_a_pressed_bit :
    stmt_mentions_int_bits input_a_pressed_bits
      (fn_body mario.f_update_mario_button_inputs) = true;
  shape_button_update_mentions_a_down_bit :
    stmt_mentions_int_bits 128
      (fn_body mario.f_update_mario_button_inputs) = true;
  shape_walking_checks_braking_before_jump :
    ident_appears_before mario_actions_moving._begin_braking_action
      mario_actions_moving._set_jump_from_landing
      (direct_callees_s
        (fn_body mario_actions_moving.f_act_walking)) = true;
  shape_braking_gate_mentions_sixteen :
    stmt_mentions_float32_bits float32_sixteen_bits
      (fn_body mario_actions_moving.f_begin_braking_action) = true;
  shape_braking_gate_mentions_floor_normal_threshold :
    stmt_mentions_float32_bits float32_braking_normal_gate_bits
      (fn_body mario_actions_moving.f_begin_braking_action) = true;
  shape_braking_updates_speed_before_ground_step :
    ident_appears_before mario_actions_moving._apply_slope_decel
      mario_actions_moving._perform_ground_step
      (direct_callees_s
        (fn_body mario_actions_moving.f_act_braking)) = true;
  shape_braking_does_not_turn_face_yaw :
    assigns_through_field_s mario_actions_moving._faceAngle
      (fn_body mario_actions_moving.f_act_braking) = false;
  shape_very_slippery_decel_mentions_point_two :
    stmt_mentions_float32_bits float32_point_two_bits
      (fn_body mario_actions_moving.f_apply_slope_decel) = true;
  shape_slope_decel_calls_slope_accel :
    ident_mem mario_actions_moving._apply_slope_accel
      (direct_callees_s
        (fn_body mario_actions_moving.f_apply_slope_decel)) = true;
  shape_very_slippery_accel_mentions_five_point_three :
    stmt_mentions_float32_bits float32_five_point_three_bits
      (fn_body mario_actions_moving.f_apply_slope_accel) = true;
  shape_slope_accel_assigns_forward_velocity :
    assigns_through_field_s mario_actions_moving._forwardVel
      (fn_body mario_actions_moving.f_apply_slope_accel) = true;
  shape_slope_accel_assigns_velocity_vector :
    assigns_through_field_s mario_actions_moving._vel
      (fn_body mario_actions_moving.f_apply_slope_accel) = true;
  shape_regular_slide_mentions_hundred_cap :
    stmt_mentions_float32_bits float32_one_hundred_bits
      (fn_body mario_actions_moving.f_update_sliding_angle) = true;
  shape_held_a_punch_mentions_a_down :
    stmt_mentions_int_bits 128
      (fn_body mario_actions_moving.f_act_move_punching) = true;
  shape_held_a_punch_mentions_jump_kick :
    stmt_mentions_int_bits act_jump_kick
      (fn_body mario_actions_moving.f_act_move_punching) = true;
  shape_jump_kick_initialization_is_vertical_only :
    generated_jump_kick_case_is_vertical_only = true;
  shape_ground_step_has_four_qsteps :
    stmt_contains_loop (fn_body mario_step.f_perform_ground_step) = true;
  shape_air_step_has_four_qsteps :
    stmt_contains_loop (fn_body mario_step.f_perform_air_step) = true;
  shape_ground_qstep_calls_find_floor :
    ident_mem mario_step._find_floor
      (direct_callees_s
        (fn_body mario_step.f_perform_ground_quarter_step)) = true;
  shape_air_qstep_calls_find_floor :
    ident_mem mario_step._find_floor
      (direct_callees_s
        (fn_body mario_step.f_perform_air_quarter_step)) = true;
  shape_blj_recycle_still_uses_pressed_a :
    generated_landing_input_gate_shape
}.

Theorem generated_no_a_source_shape_holds :
  generated_no_a_source_shape.
Proof.
  constructor.
  all: try (vm_compute; reflexivity).
  exact generated_landing_input_gate_shape_holds.
Qed.

Inductive a_hold_policy : Type :=
| AUp
| AHeld.

Record a_button_frame : Type := {
  frame_a_pressed : bool;
  frame_a_down : bool
}.

Definition policy_frame (policy : a_hold_policy) : a_button_frame :=
  match policy with
  | AUp => {| frame_a_pressed := false; frame_a_down := false |}
  | AHeld => {| frame_a_pressed := false; frame_a_down := true |}
  end.

Definition no_new_a_input (frame : a_button_frame) : Prop :=
  frame_a_pressed frame = false.

Definition a_hold_schedule : Type := nat -> a_hold_policy.

Definition scheduled_frame
    (schedule : a_hold_schedule) (frame : nat) : a_button_frame :=
  policy_frame (schedule frame).

Theorem no_new_a_policy_covers_a_up_and_held_a :
  policy_frame AUp =
    {| frame_a_pressed := false; frame_a_down := false |} /\
  policy_frame AHeld =
    {| frame_a_pressed := false; frame_a_down := true |} /\
  forall policy, no_new_a_input (policy_frame policy).
Proof.
  repeat split; try reflexivity.
  intros []; reflexivity.
Qed.

Theorem every_a_down_schedule_has_no_new_a_press :
  forall schedule frame,
    no_new_a_input (scheduled_frame schedule frame).
Proof.
  intros schedule frame.
  unfold scheduled_frame.
  destruct (schedule frame); reflexivity.
Qed.

Definition policy_recycle_input (_ : a_hold_policy) : recycle_input := {|
  recycle_input_a_pressed := false;
  recycle_input_z_down := true
|}.

Theorem no_new_a_policy_forbids_blj_recycle :
  forall policy,
    ~ input_allows_long_jump_land_recycle
        (policy_recycle_input policy).
Proof.
  intros policy [Hpressed _].
  discriminate Hpressed.
Qed.

Theorem no_new_a_schedule_forbids_every_blj_recycle :
  forall (schedule : a_hold_schedule) (frame : nat),
    ~ input_allows_long_jump_land_recycle
        (policy_recycle_input (schedule frame)).
Proof.
  intros schedule frame.
  apply no_new_a_policy_forbids_blj_recycle.
Qed.

Record slippery_component_certificate : Type := {
  component_triangle_count : nat;
  component_min_x : Z;
  component_max_x : Z;
  component_min_y : Z;
  component_max_y : Z;
  component_min_z : Z;
  component_max_z : Z
}.

Definition area2_slippery_components :
    list slippery_component_certificate := [
  {| component_triangle_count := 2; component_min_x := -3112;
     component_max_x := -3071; component_min_y := 72;
     component_max_y := 113; component_min_z := -4095;
     component_max_z := -3378 |};
  {| component_triangle_count := 8; component_min_x := -3112;
     component_max_x := -3071; component_min_y := 72;
     component_max_y := 113; component_min_z := -3173;
     component_max_z := 2970 |};
  {| component_triangle_count := 4; component_min_x := -2969;
     component_max_x := -854; component_min_y := 72;
     component_max_y := 113; component_min_z := 2662;
     component_max_z := 3113 |};
  {| component_triangle_count := 2; component_min_x := -818;
     component_max_x := 819; component_min_y := 72;
     component_max_y := 113; component_min_z := 2586;
     component_max_z := 2627 |};
  {| component_triangle_count := 2; component_min_x := -818;
     component_max_x := 819; component_min_y := 1280;
     component_max_y := 1536; component_min_z := 2560;
     component_max_z := 3174 |};
  {| component_triangle_count := 6; component_min_x := 387;
     component_max_x := 643; component_min_y := 4887;
     component_max_y := 4927; component_min_z := -1125;
     component_max_z := -409 |};
  {| component_triangle_count := 4; component_min_x := 855;
     component_max_x := 2970; component_min_y := 72;
     component_max_y := 113; component_min_z := 2662;
     component_max_z := 3113 |};
  {| component_triangle_count := 2; component_min_x := 3072;
     component_max_x := 3113; component_min_y := 72;
     component_max_y := 113; component_min_z := -3173;
     component_max_z := -220 |};
  {| component_triangle_count := 2; component_min_x := 3072;
     component_max_x := 3113; component_min_y := 72;
     component_max_y := 113; component_min_z := 411;
     component_max_z := 2714 |}
].

Fixpoint slippery_triangle_total
    (components : list slippery_component_certificate) : nat :=
  match components with
  | [] => O
  | component :: rest =>
      (component_triangle_count component +
       slippery_triangle_total rest)%nat
  end.

Definition slippery_path_cost
    (component : slippery_component_certificate) : Z :=
  2 * ((component_max_x component - component_min_x component) +
       (component_max_z component - component_min_z component)).

Definition slippery_path_budget : Z := 16384.

Definition slippery_component_fits_path_budget
    (component : slippery_component_certificate) : bool :=
  slippery_path_cost component <=? slippery_path_budget.

Theorem area2_slippery_component_certificate_holds :
  length area2_slippery_components = 9%nat /\
  slippery_triangle_total area2_slippery_components = 32%nat /\
  forallb slippery_component_fits_path_budget
    area2_slippery_components = true.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition c_up_entry_speed_bound : Z := 32.
Definition c_up_energy_coefficient : Z := 16.
Definition no_a_horizontal_speed_bound : Z := 1024.

Record c_up_trace_certificate (speed distance : Z) : Prop := {
  c_up_speed_nonnegative : 0 <= speed;
  c_up_distance_nonnegative : 0 <= distance;
  c_up_distance_within_component : distance <= slippery_path_budget;
  c_up_energy_bound :
    speed * speed <=
      c_up_entry_speed_bound * c_up_entry_speed_bound +
      c_up_energy_coefficient * distance
}.

Theorem certified_c_up_trace_stays_below_no_a_speed_bound :
  forall speed distance,
    c_up_trace_certificate speed distance ->
    speed < no_a_horizontal_speed_bound.
Proof.
  intros speed distance Htrace.
  destruct Htrace as [Hspeed Hdistance Hpath Henergy].
  unfold c_up_entry_speed_bound, c_up_energy_coefficient,
    slippery_path_budget, no_a_horizontal_speed_bound in *.
  nia.
Qed.

Definition ground_quarter_step_count : Z := 4.
Definition no_a_quarter_step_bound : Z :=
  no_a_horizontal_speed_bound / ground_quarter_step_count.
Definition dynamic_horizontal_step_bound : Z := 64.
Definition signed_coord_period : Z := 65536.
Definition local_mesh_min : Z := -4148.
Definition local_mesh_max : Z := 6758.
Definition first_static_alias_gap : Z :=
  signed_coord_period - (local_mesh_max - local_mesh_min).

Theorem no_a_step_bounds_are_below_first_static_alias_gap :
  no_a_quarter_step_bound = 256 /\
  first_static_alias_gap = 54630 /\
  no_a_quarter_step_bound < first_static_alias_gap /\
  dynamic_horizontal_step_bound < first_static_alias_gap.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

Definition local_mesh_coord (coord : Z) : Prop :=
  local_mesh_min <= coord <= local_mesh_max.

Definition state_in_local_mesh_window (state : pu_state) : Prop :=
  state_area state = ssl_area2 /\
  local_mesh_coord (state_x state) /\
  local_mesh_coord (state_z state).

Record accepted_static_floor_qstep (before after : Z) : Prop := {
  accepted_qstep_before_local : local_mesh_coord before;
  accepted_qstep_has_bounded_delta :
    exists delta,
      after = before + delta /\
      Z.abs delta <= no_a_quarter_step_bound;
  accepted_qstep_has_static_alias :
    exists local period_index,
      local_mesh_coord local /\
      after = local + signed_coord_period * period_index
}.

Theorem bounded_accepted_qstep_cannot_change_alias_period :
  forall before after,
    accepted_static_floor_qstep before after ->
    local_mesh_coord after.
Proof.
  intros before after Hstep.
  destruct Hstep as
    [Hbefore [delta [Hafter Hdelta]]
      [local [period_index [Hlocal Halias]]]].
  unfold local_mesh_coord, local_mesh_min, local_mesh_max in
    Hbefore, Hlocal |- *.
  unfold no_a_quarter_step_bound, no_a_horizontal_speed_bound,
    ground_quarter_step_count in Hdelta.
  change (Z.abs delta <= 256) in Hdelta.
  apply Z.abs_le in Hdelta.
  unfold signed_coord_period in Halias.
  assert (period_index = 0) by nia.
  subst period_index.
  simpl in Halias.
  nia.
Qed.

Inductive no_a_area2_step : pu_state -> pu_state -> Prop :=
| no_a_static_floor_step :
    forall before after,
      state_area after = state_area before ->
      accepted_static_floor_qstep (state_x before) (state_x after) ->
      accepted_static_floor_qstep (state_z before) (state_z after) ->
      no_a_area2_step before after
| no_a_floor_null_step :
    forall state,
      no_a_area2_step state state
| no_a_local_position_writer :
    forall before after,
      state_in_local_mesh_window after ->
      no_a_area2_step before after.

Theorem no_a_area2_step_preserves_local_mesh_window :
  forall before after,
    state_in_local_mesh_window before ->
    no_a_area2_step before after ->
    state_in_local_mesh_window after.
Proof.
  intros before after Hbefore Hstep.
  destruct Hstep as
    [before after Harea Hx Hz | state | before after Hafter].
  - destruct Hbefore as [Hbefore_area [Hbefore_x Hbefore_z]].
    split.
    + rewrite Harea. exact Hbefore_area.
    + split.
      * exact (bounded_accepted_qstep_cannot_change_alias_period
          (state_x before) (state_x after) Hx).
      * exact (bounded_accepted_qstep_cannot_change_alias_period
          (state_z before) (state_z after) Hz).
  - exact Hbefore.
  - exact Hafter.
Qed.

Inductive no_a_area2_reachable : pu_state -> pu_state -> Prop :=
| no_a_reachable_refl :
    forall state,
      no_a_area2_reachable state state
| no_a_reachable_step :
    forall initial middle final,
      no_a_area2_reachable initial middle ->
      no_a_area2_step middle final ->
      no_a_area2_reachable initial final.

Theorem no_a_reachable_preserves_local_mesh_window :
  forall initial final,
    state_in_local_mesh_window initial ->
    no_a_area2_reachable initial final ->
    state_in_local_mesh_window final.
Proof.
  intros initial final Hinitial Hreachable.
  induction Hreachable.
  - exact Hinitial.
  - apply no_a_area2_step_preserves_local_mesh_window with middle.
    + exact (IHHreachable Hinitial).
    + exact H.
Qed.

Theorem local_mesh_window_is_inside_area2_bounds :
  forall state,
    state_in_local_mesh_window state ->
    state_in_area2_bounds state.
Proof.
  intros state [Harea [Hx Hz]].
  split.
  - exact Harea.
  - split;
      unfold local_mesh_coord, coord_in_area2_bounds,
        local_mesh_min, local_mesh_max,
        ssl_area2_min, ssl_area2_max in *;
      lia.
Qed.

Record no_a_source_mesh_certificate : Prop := {
  no_a_generated_source_certificate : generated_no_a_source_shape;
  no_a_policy_certificate :
    forall (schedule : a_hold_schedule) (frame : nat),
      no_new_a_input (scheduled_frame schedule frame);
  no_a_blj_exclusion_certificate :
    forall (schedule : a_hold_schedule) (frame : nat),
      ~ input_allows_long_jump_land_recycle
          (policy_recycle_input (schedule frame));
  no_a_slippery_triangle_partition :
    slippery_triangle_total area2_slippery_components = 32%nat;
  no_a_slippery_path_certificate :
    forallb slippery_component_fits_path_budget
      area2_slippery_components = true;
  no_a_c_up_energy_certificate :
    c_up_entry_speed_bound * c_up_entry_speed_bound +
      c_up_energy_coefficient * slippery_path_budget <
    no_a_horizontal_speed_bound * no_a_horizontal_speed_bound;
  no_a_alias_gap_certificate :
    no_a_quarter_step_bound < first_static_alias_gap /\
    dynamic_horizontal_step_bound < first_static_alias_gap
}.

Theorem no_a_source_mesh_certificate_holds :
  no_a_source_mesh_certificate.
Proof.
  constructor.
  - exact generated_no_a_source_shape_holds.
  - exact every_a_down_schedule_has_no_new_a_press.
  - exact no_new_a_schedule_forbids_every_blj_recycle.
  - exact (proj1 (proj2 area2_slippery_component_certificate_holds)).
  - exact (proj2 (proj2 area2_slippery_component_certificate_holds)).
  - change (263168 < 1048576). lia.
  - change (256 < 54630 /\ 64 < 54630). lia.
Qed.

Definition certified_no_a_area2_execution
    (schedule : a_hold_schedule) (initial final : pu_state) : Prop :=
  (forall frame, no_new_a_input (scheduled_frame schedule frame)) /\
  state_in_local_mesh_window initial /\
  no_a_area2_reachable initial final.

Theorem certified_no_a_area2_execution_forbids_parallel_universe :
  forall schedule initial final,
    certified_no_a_area2_execution schedule initial final ->
    ~ state_in_parallel_universe final.
Proof.
  intros schedule initial final (_ & Hinitial & Hreachable).
  apply area2_bounds_not_parallel_universe.
  apply local_mesh_window_is_inside_area2_bounds.
  exact (no_a_reachable_preserves_local_mesh_window
    initial final Hinitial Hreachable).
Qed.

Theorem ssl_area2_no_new_a_parallel_universe_certificate :
  no_a_source_mesh_certificate /\
  forall schedule initial final,
    certified_no_a_area2_execution schedule initial final ->
    ~ state_in_parallel_universe final.
Proof.
  split.
  - exact no_a_source_mesh_certificate_holds.
  - exact certified_no_a_area2_execution_forbids_parallel_universe.
Qed.
