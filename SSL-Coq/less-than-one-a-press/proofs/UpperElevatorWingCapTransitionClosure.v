(** Stock SSL Area-1-to-Area-2 Wing-Cap transition closure.

    The upper pyramid entrance is the Area-1 node 0x1E route to Area 2,
    node 0x14.  Unlike an instant warp, this same-level area change unloads
    and reloads Mario's area, then calls [init_mario_after_warp].  That routine
    calls [init_mario] and [set_mario_initial_action]; the latter finishes by
    calling [set_mario_initial_cap_powerup].

    [init_mario] writes either 0 or 17 to Mario's flags and writes zero to the
    cap timer.  Both flag values exclude the Wing bit.  SSL is course 8, so
    its cap-course index is 8 - 20 = -12, whereas the only initial-cap switch
    labels are 0, 1, and 2.  Consequently the later helper cannot restore a
    Wing Cap on this transition.

    The generated-source receipts and value theorem below close preservation
    for a stock, defined execution once the live route, receiver, and ordinary
    call-return chain are linked to them.  They intentionally do not cover an
    out-of-model memory corruption, a forged course/warp destination, or an
    execution that fails that link.

    For diagnosis, the file also makes the hypothetical retained-Wing branch
    exact.  Only zero-based quarter-steps 44 and 45 exceed the 231-unit wall
    cutoff (at 234 and 232); the next two are 230 and 228.  The generated
    quarter-step query order and rollout call order are checked, so this is a
    two-query wall-selection opportunity, not proof of a crossing. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Generated Require Import
  us_level_update us_mario_actions_airborne us_mario_step us_save_file
  jp_level_update jp_mario_actions_airborne jp_mario_step jp_save_file.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PlatformExhaustiveness OrdinaryMotion
  UpperElevatorQuarterStepClosure.

Import ListNotations.
Local Open Scope Z_scope.

Module UEW_ULevel := us_level_update.
Module UEW_JLevel := jp_level_update.
Module UEW_UAir := us_mario_actions_airborne.
Module UEW_JAir := jp_mario_actions_airborne.
Module UEW_UStep := us_mario_step.
Module UEW_JStep := jp_mario_step.
Module UEW_USave := us_save_file.
Module UEW_JSave := jp_save_file.

(** The generated cap helper has no default body and exactly the Metal,
    Wing, and Vanish course labels 0, 1, and 2. *)
Fixpoint uew_switch_labels (cases : labeled_statements) : list (option Z) :=
  match cases with
  | LSnil => []
  | LScons label _ rest => label :: uew_switch_labels rest
  end.

Definition uew_outer_switch_labels (body : statement) : list (option Z) :=
  match body with
  | Ssequence _ (Sswitch _ cases) => uew_switch_labels cases
  | _ => []
  end.

Definition upper_entry_transition_source_claim : Prop :=
  area1_inbound_and_route_source_claim /\
  nth_error (gvar_init UEW_USave.v_gLevelToCourseNumTable) 7 =
    Some (Init_int8 (Int.repr 8)) /\
  nth_error (gvar_init UEW_JSave.v_gLevelToCourseNumTable) 7 =
    Some (Init_int8 (Int.repr 8)) /\
  ident_subsequenceb
    [UEW_ULevel._unload_mario_area; UEW_ULevel._load_area;
     UEW_ULevel._init_mario_after_warp]
    (direct_callees_s (fn_body UEW_ULevel.f_warp_area)) = true /\
  ident_subsequenceb
    [UEW_JLevel._unload_mario_area; UEW_JLevel._load_area;
     UEW_JLevel._init_mario_after_warp]
    (direct_callees_s (fn_body UEW_JLevel.f_warp_area)) = true /\
  ident_subsequenceb
    [UEW_ULevel._area_get_warp_node; UEW_ULevel._get_mario_spawn_type;
     UEW_ULevel._load_mario_area; UEW_ULevel._init_mario;
     UEW_ULevel._set_mario_initial_action]
    (direct_callees_s (fn_body UEW_ULevel.f_init_mario_after_warp)) = true /\
  ident_subsequenceb
    [UEW_JLevel._area_get_warp_node; UEW_JLevel._get_mario_spawn_type;
     UEW_JLevel._load_mario_area; UEW_JLevel._init_mario;
     UEW_JLevel._set_mario_initial_action]
    (direct_callees_s (fn_body UEW_JLevel.f_init_mario_after_warp)) = true /\
  calls_ident_s UEW_ULevel._set_mario_initial_cap_powerup
    (fn_body UEW_ULevel.f_set_mario_initial_action) = true /\
  calls_ident_s UEW_JLevel._set_mario_initial_cap_powerup
    (fn_body UEW_JLevel.f_set_mario_initial_action) = true /\
  assigns_field_int_constant_s UEW_ULevel._type 2
    (fn_body UEW_ULevel.f_initiate_warp) = true /\
  assigns_field_int_constant_s UEW_JLevel._type 2
    (fn_body UEW_JLevel.f_initiate_warp) = true /\
  uew_outer_switch_labels
    (fn_body UEW_ULevel.f_set_mario_initial_cap_powerup) =
      [Some 0; Some 1; Some 2] /\
  uew_outer_switch_labels
    (fn_body UEW_JLevel.f_set_mario_initial_cap_powerup) =
      [Some 0; Some 1; Some 2] /\
  statement_mentions_ident_s UEW_ULevel._gCurrCourseNum
    (fn_body UEW_ULevel.f_set_mario_initial_cap_powerup) = true /\
  statement_mentions_ident_s UEW_JLevel._gCurrCourseNum
    (fn_body UEW_JLevel.f_set_mario_initial_cap_powerup) = true /\
  statement_mentions_int_s 20
    (fn_body UEW_ULevel.f_set_mario_initial_cap_powerup) = true /\
  statement_mentions_int_s 20
    (fn_body UEW_JLevel.f_set_mario_initial_cap_powerup) = true /\
  ueq_entry_cap_reset_source_claim.

Theorem upper_entry_transition_source_checked :
  upper_entry_transition_source_claim.
Proof.
  unfold upper_entry_transition_source_claim.
  split; [exact area1_inbound_and_route_source_checked |].
  vm_compute. repeat split; reflexivity.
Qed.

Definition ssl_course_number : Z := 8.
Definition cap_courses_start : Z := 20.
Definition ssl_cap_course_index : Z :=
  ssl_course_number - cap_courses_start.

Theorem ssl_selects_no_initial_special_cap_case :
  ssl_cap_course_index = -12 /\
  ssl_cap_course_index <> 0 /\
  ssl_cap_course_index <> 1 /\
  ssl_cap_course_index <> 2.
Proof.
  unfold ssl_cap_course_index, ssl_course_number, cap_courses_start.
  lia.
Qed.

(** This is the value-level conclusion of the two generated assignments. *)
Theorem stock_upper_area_change_reset_cannot_preserve_wing :
  forall cap,
    (ueq_live_flags cap = Int.zero \/
     ueq_live_flags cap = Int.repr 17) ->
    ueq_live_cap_timer cap = Int.zero ->
    ueq_live_cap_is_nonwing cap.
Proof.
  exact clean_init_cap_values_are_nonwing.
Qed.

Definition uew_above_wall_cutoff (relative_half : Z) : bool :=
  Z.gtb relative_half (2 * pyramid_elevator_cage_clearance).

Theorem hypothetical_wing_above_cutoff_window_is_exact :
  filter uew_above_wall_cutoff wing_rollout_scaled_qsteps = [468; 464] /\
  nth_error wing_rollout_scaled_qsteps 44 = Some 468 /\
  nth_error wing_rollout_scaled_qsteps 45 = Some 464 /\
  nth_error wing_rollout_scaled_qsteps 46 = Some 460 /\
  nth_error wing_rollout_scaled_qsteps 47 = Some 456.
Proof.
  vm_compute. repeat split; reflexivity.
Qed.

Definition hypothetical_wing_query_and_action_source_claim : Prop :=
  ident_subsequenceb
    [UEW_UStep._resolve_and_return_wall_collisions;
     UEW_UStep._resolve_and_return_wall_collisions;
     UEW_UStep._find_floor; UEW_UStep._vec3f_find_ceil;
     UEW_UStep._find_water_level]
    (direct_callees_s (fn_body UEW_UStep.f_perform_air_quarter_step)) = true /\
  ident_subsequenceb
    [UEW_JStep._resolve_and_return_wall_collisions;
     UEW_JStep._resolve_and_return_wall_collisions;
     UEW_JStep._find_floor; UEW_JStep._vec3f_find_ceil;
     UEW_JStep._find_water_level]
    (direct_callees_s (fn_body UEW_JStep.f_perform_air_quarter_step)) = true /\
  ident_subsequenceb
    [UEW_UAir._update_air_without_turn; UEW_UAir._perform_air_step]
    (direct_callees_s (fn_body UEW_UAir.f_act_forward_rollout)) = true /\
  ident_subsequenceb
    [UEW_JAir._update_air_without_turn; UEW_JAir._perform_air_step]
    (direct_callees_s (fn_body UEW_JAir.f_act_forward_rollout)) = true /\
  ident_subsequenceb
    [UEW_UAir._update_air_without_turn; UEW_UAir._perform_air_step]
    (direct_callees_s (fn_body UEW_UAir.f_act_backward_rollout)) = true /\
  ident_subsequenceb
    [UEW_JAir._update_air_without_turn; UEW_JAir._perform_air_step]
    (direct_callees_s (fn_body UEW_JAir.f_act_backward_rollout)) = true /\
  calls_ident_with_int_literal_s UEW_UAir._perform_air_step 0
    (fn_body UEW_UAir.f_act_forward_rollout) = true /\
  calls_ident_with_int_literal_s UEW_JAir._perform_air_step 0
    (fn_body UEW_JAir.f_act_forward_rollout) = true /\
  calls_ident_with_int_literal_s UEW_UAir._perform_air_step 0
    (fn_body UEW_UAir.f_act_backward_rollout) = true /\
  calls_ident_with_int_literal_s UEW_JAir._perform_air_step 0
    (fn_body UEW_JAir.f_act_backward_rollout) = true /\
  switch_case_calls_ident_with_two_int_literals_s
    1 UEW_UAir._set_mario_action 201327154 0
    (fn_body UEW_UAir.f_act_forward_rollout) = true /\
  switch_case_calls_ident_with_two_int_literals_s
    1 UEW_JAir._set_mario_action 201327154 0
    (fn_body UEW_JAir.f_act_forward_rollout) = true /\
  switch_case_calls_ident_s 2 UEW_UAir._mario_set_forward_vel
    (fn_body UEW_UAir.f_act_forward_rollout) = true /\
  switch_case_calls_ident_s 2 UEW_JAir._mario_set_forward_vel
    (fn_body UEW_JAir.f_act_forward_rollout) = true /\
  switch_case_calls_ident_s 6 UEW_UAir._lava_boost_on_wall
    (fn_body UEW_UAir.f_act_forward_rollout) = true /\
  switch_case_calls_ident_s 6 UEW_JAir._lava_boost_on_wall
    (fn_body UEW_JAir.f_act_forward_rollout) = true /\
  calls_ident_s UEW_UStep._apply_gravity
    (fn_body UEW_UStep.f_perform_air_step) = true /\
  calls_ident_s UEW_JStep._apply_gravity
    (fn_body UEW_JStep.f_perform_air_step) = true /\
  statement_mentions_int_s 8 (fn_body UEW_UStep.f_apply_gravity) = true /\
  statement_mentions_int_s 8 (fn_body UEW_JStep.f_apply_gravity) = true /\
  statement_mentions_int_s 128 (fn_body UEW_UStep.f_apply_gravity) = true /\
  statement_mentions_int_s 128 (fn_body UEW_JStep.f_apply_gravity) = true.

Theorem hypothetical_wing_query_and_action_source_checked :
  hypothetical_wing_query_and_action_source_claim.
Proof.
  unfold hypothetical_wing_query_and_action_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Definition UpperElevatorWingCapTransitionCheckedBoundary : Prop :=
  upper_entry_transition_source_claim /\
  ssl_cap_course_index = -12 /\
  (forall cap,
    (ueq_live_flags cap = Int.zero \/
     ueq_live_flags cap = Int.repr 17) ->
    ueq_live_cap_timer cap = Int.zero ->
    ueq_live_cap_is_nonwing cap) /\
  filter uew_above_wall_cutoff wing_rollout_scaled_qsteps = [468; 464] /\
  hypothetical_wing_query_and_action_source_claim.

Theorem upper_elevator_wing_cap_transition_checked_boundary_holds :
  UpperElevatorWingCapTransitionCheckedBoundary.
Proof.
  unfold UpperElevatorWingCapTransitionCheckedBoundary.
  split; [exact upper_entry_transition_source_checked |].
  split; [exact (proj1 ssl_selects_no_initial_special_cap_case) |].
  split; [exact stock_upper_area_change_reset_cannot_preserve_wing |].
  split.
  - exact (proj1 hypothetical_wing_above_cutoff_window_is_exact).
  - exact hypothetical_wing_query_and_action_source_checked.
Qed.
