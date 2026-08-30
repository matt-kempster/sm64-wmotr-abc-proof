(** Rank 29: close the reset-evading stock episode-cycle residual.

    [EyerokRank29Preload] proves that one ordinary settled airborne episode
    cannot accumulate the speed required by the sleeping-hand Pedro landing.
    Its remaining ordinary-game possibility was a repeatable moving-floor,
    landing, or [INPUT_OFF_FLOOR] transition that joined otherwise bounded
    episodes without replacing or damping [forwardVel].

    This file checks the relevant US/JP generated syntax and isolates the two
    apparently preserving cases.  A correctly owned platform is carried by
    platform displacement and that routine does not touch [forwardVel].  Even
    granting one missed carry, every stock Area-2 platform changes Y by at
    most 78 units in a frame, below the strict 100-unit [OFF_FLOOR] gap.  The
    other real case is the first flat landing in butt-slide-air: it preserves
    horizontal speed and changes [actionState] from 0 to 1, so the very next
    landing cannot repeat it.  Re-arming the air action goes through ground
    butt-slide, whose update contains the checked speed-100 normalization.

    The final theorem is deliberately scoped to the stock-owner model.  A
    stale or wrongly identified floor owner, missing collision reload, forged
    action/state, modified roster, or execution after undefined behavior is
    a failed premise and remains a concrete model-boundary counterexample,
    not an ordinary reset-evading cycle. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Integers Floats.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts CollisionMeshFacts EyerokRank29Preload.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated source receipts *)

Definition rank29_float32_four_bits : Z := 1082130432.
Definition rank29_float32_five_bits : Z := 1084227584.
Definition rank29_float32_sixteen_bits : Z := 1098907648.
Definition rank29_float32_seventy_bits : Z := 1116471296.
Definition rank29_float32_seventy_eight_bits : Z := 1117519872.
Definition rank29_float64_twenty_three_bits : Z := 4627167142146473984.
Definition rank29_act_freefall : Z := 16779404.
Definition rank29_act_hold_freefall : Z := 16779425.

Fixpoint rank29_expression_mentions_float64_bits
    (bits : Z) (e : expr) : bool :=
  match e with
  | Econst_float value _ =>
      Int64.eq (Float.to_bits value) (Int64.repr bits)
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _ =>
      rank29_expression_mentions_float64_bits bits inner
  | Ebinop _ lhs rhs _ =>
      rank29_expression_mentions_float64_bits bits lhs ||
      rank29_expression_mentions_float64_bits bits rhs
  | Efield inner _ _ => rank29_expression_mentions_float64_bits bits inner
  | _ => false
  end.

Fixpoint rank29_expressions_mention_float64_bits
    (bits : Z) (args : list expr) : bool :=
  match args with
  | [] => false
  | arg :: rest =>
      rank29_expression_mentions_float64_bits bits arg ||
      rank29_expressions_mention_float64_bits bits rest
  end.

Fixpoint rank29_statement_mentions_float64_bits_s
    (bits : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      rank29_expression_mentions_float64_bits bits lhs ||
      rank29_expression_mentions_float64_bits bits rhs
  | Sset _ rhs => rank29_expression_mentions_float64_bits bits rhs
  | Scall _ fn args =>
      rank29_expression_mentions_float64_bits bits fn ||
      rank29_expressions_mention_float64_bits bits args
  | Ssequence first second | Sloop first second =>
      rank29_statement_mentions_float64_bits_s bits first ||
      rank29_statement_mentions_float64_bits_s bits second
  | Sifthenelse condition yes_branch no_branch =>
      rank29_expression_mentions_float64_bits bits condition ||
      rank29_statement_mentions_float64_bits_s bits yes_branch ||
      rank29_statement_mentions_float64_bits_s bits no_branch
  | Sreturn (Some value) =>
      rank29_expression_mentions_float64_bits bits value
  | Sswitch value cases =>
      rank29_expression_mentions_float64_bits bits value ||
      rank29_statements_mention_float64_bits bits cases
  | Slabel _ body => rank29_statement_mentions_float64_bits_s bits body
  | _ => false
  end
with rank29_statements_mention_float64_bits
    (bits : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      rank29_statement_mentions_float64_bits_s bits body ||
      rank29_statements_mention_float64_bits bits rest
  end.

Definition Rank29EpisodeBoundarySourceShape : Prop :=
  (** The geometry input uses the strict 100-unit off-floor threshold. *)
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 4
    (fn_body UMI.f_update_mario_geometry_inputs) = true /\
  statement_mentions_int_s 4
    (fn_body JMI.f_update_mario_geometry_inputs) = true /\
  (** Platform carry does not read or write Mario's forward speed. *)
  statement_mentions_ident_s UPD._forwardVel
    (fn_body UPD.f_apply_platform_displacement) = false /\
  statement_mentions_ident_s JPD._forwardVel
    (fn_body JPD.f_apply_platform_displacement) = false /\
  (** A normal landing applies acceleration/deceleration before ground step. *)
  ident_subsequenceb
    [UMove._apply_landing_accel; UMove._perform_ground_step]
    (direct_callees_s (fn_body UMove.f_common_landing_action)) = true /\
  ident_subsequenceb
    [UMove._apply_slope_decel; UMove._perform_ground_step]
    (direct_callees_s (fn_body UMove.f_common_landing_action)) = true /\
  ident_subsequenceb
    [JMove._apply_landing_accel; JMove._perform_ground_step]
    (direct_callees_s (fn_body JMove.f_common_landing_action)) = true /\
  ident_subsequenceb
    [JMove._apply_slope_decel; JMove._perform_ground_step]
    (direct_callees_s (fn_body JMove.f_common_landing_action)) = true /\
  (** Landing cancellation has the descriptor off-floor action and the steep
      branch; the latter replaces forward speed with magnitude 16. *)
  statement_mentions_ident_s UMove._offFloorAction
    (fn_body UMove.f_common_landing_cancels) = true /\
  statement_mentions_ident_s JMove._offFloorAction
    (fn_body JMove.f_common_landing_cancels) = true /\
  calls_ident_s UMove._mario_push_off_steep_floor
    (fn_body UMove.f_common_landing_cancels) = true /\
  calls_ident_s JMove._mario_push_off_steep_floor
    (fn_body JMove.f_common_landing_cancels) = true /\
  statement_mentions_float32_bits_s rank29_float32_sixteen_bits
    (fn_body UStep.f_mario_push_off_steep_floor) = true /\
  statement_mentions_float32_bits_s rank29_float32_sixteen_bits
    (fn_body JStep.f_mario_push_off_steep_floor) = true /\
  (** The two freefall actions are default cases of airborne setup: neither
      appears among the actions that replace forward speed. *)
  statement_mentions_int_s rank29_act_freefall
    (fn_body UMI.f_set_mario_action_airborne) = false /\
  statement_mentions_int_s rank29_act_hold_freefall
    (fn_body UMI.f_set_mario_action_airborne) = false /\
  statement_mentions_int_s rank29_act_freefall
    (fn_body JMI.f_set_mario_action_airborne) = false /\
  statement_mentions_int_s rank29_act_hold_freefall
    (fn_body JMI.f_set_mario_action_airborne) = false /\
  (** Butt-slide-air's flat first bounce consumes state zero. *)
  assigns_field_int_constant_s UAir._actionState 1
    (fn_body UAir.f_act_butt_slide_air) = true /\
  assigns_field_int_constant_s UAir._actionState 1
    (fn_body UAir.f_act_hold_butt_slide_air) = true /\
  assigns_field_int_constant_s JAir._actionState 1
    (fn_body JAir.f_act_butt_slide_air) = true /\
  assigns_field_int_constant_s JAir._actionState 1
    (fn_body JAir.f_act_hold_butt_slide_air) = true /\
  statement_mentions_float32_bits_s float32_two_bits
    (fn_body UAir.f_act_butt_slide_air) = true /\
  statement_mentions_float32_bits_s float32_two_bits
    (fn_body JAir.f_act_butt_slide_air) = true /\
  (** Re-entry from ground slide first performs the checked slide update;
      the called angle update contains the speed-100 normalization. *)
  ident_subsequenceb
    [UMove._update_sliding; UMove._common_slide_action]
    (direct_callees_s (fn_body UMove.f_common_slide_action_with_jump)) = true /\
  ident_subsequenceb
    [JMove._update_sliding; JMove._common_slide_action]
    (direct_callees_s (fn_body JMove.f_common_slide_action_with_jump)) = true /\
  calls_ident_s UMove._update_sliding_angle
    (fn_body UMove.f_update_sliding) = true /\
  calls_ident_s JMove._update_sliding_angle
    (fn_body JMove.f_update_sliding) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body UMove.f_update_sliding_angle) = true /\
  statement_mentions_float32_bits_s float32_one_hundred_bits
    (fn_body JMove.f_update_sliding_angle) = true.

Theorem rank29_episode_boundary_source_shape_checked :
  Rank29EpisodeBoundarySourceShape.
Proof.
  unfold Rank29EpisodeBoundarySourceShape,
    rank29_float32_sixteen_bits, rank29_act_freefall,
    rank29_act_hold_freefall.
  vm_compute. repeat split; reflexivity.
Qed.

(** The five collision-owning behaviors reload their mesh after their native
    update.  These are exact initializer-subsequence receipts, bilaterally. *)
Definition Rank29PlatformReloadSourceShape : Prop :=
  initializer_addrof_subsequenceb
    [UBD._bhv_grindel_thwomp_loop; UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvGrindel) = true /\
  initializer_addrof_subsequenceb
    [UBD._bhv_horizontal_grindel_update; UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvHorizontalGrindel) = true /\
  initializer_addrof_subsequenceb
    [UBD._bhv_spindel_loop; UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvSpindel) = true /\
  initializer_addrof_subsequenceb
    [UBD._bhv_ssl_moving_pyramid_wall_loop;
     UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvSSLMovingPyramidWall) = true /\
  initializer_addrof_subsequenceb
    [UBD._bhv_pyramid_elevator_loop; UBD._load_object_collision_model]
    (gvar_init UBD.v_bhvPyramidElevator) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_grindel_thwomp_loop; JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvGrindel) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_horizontal_grindel_update; JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvHorizontalGrindel) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_spindel_loop; JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvSpindel) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_ssl_moving_pyramid_wall_loop;
     JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvSSLMovingPyramidWall) = true /\
  initializer_addrof_subsequenceb
    [JBD._bhv_pyramid_elevator_loop; JBD._load_object_collision_model]
    (gvar_init JBD.v_bhvPyramidElevator) = true.

Theorem rank29_platform_reload_source_shape_checked :
  Rank29PlatformReloadSourceShape.
Proof.
  unfold Rank29PlatformReloadSourceShape.
  vm_compute. repeat split; reflexivity.
Qed.

Definition Rank29PlatformMotionSourceShape : Prop :=
  (** Vertical Grindel: -4 acceleration and 5/10 upward increments. *)
  statement_mentions_float32_bits_s rank29_float32_four_bits
    (fn_body UBA.f_grindel_thwomp_act_lower) = true /\
  statement_mentions_float32_bits_s rank29_float32_five_bits
    (fn_body UBA.f_grindel_thwomp_act_raise) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body UBA.f_grindel_thwomp_act_raise) = true /\
  statement_mentions_float32_bits_s rank29_float32_four_bits
    (fn_body JBA.f_grindel_thwomp_act_lower) = true /\
  statement_mentions_float32_bits_s rank29_float32_five_bits
    (fn_body JBA.f_grindel_thwomp_act_raise) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body JBA.f_grindel_thwomp_act_raise) = true /\
  (** Horizontal Grindel: 70 jump, -4/-16 gravity, terminal cap 78. *)
  statement_mentions_float32_bits_s rank29_float32_seventy_bits
    (fn_body UEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_four_bits
    (fn_body UEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_sixteen_bits
    (fn_body UEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_int_s 78
    (fn_body UEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_seventy_eight_bits
    (fn_body UOH.f_cur_obj_move_y_and_get_water_level) = true /\
  statement_mentions_float32_bits_s rank29_float32_seventy_bits
    (fn_body JEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_four_bits
    (fn_body JEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_sixteen_bits
    (fn_body JEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_int_s 78
    (fn_body JEye.f_bhv_horizontal_grindel_update) = true /\
  statement_mentions_float32_bits_s rank29_float32_seventy_eight_bits
    (fn_body JOH.f_cur_obj_move_y_and_get_water_level) = true /\
  (** Spindel has a 23-unit vertical amplitude. *)
  rank29_statement_mentions_float64_bits_s rank29_float64_twenty_three_bits
    (fn_body UOB.f_bhv_spindel_loop) = true /\
  rank29_statement_mentions_float64_bits_s rank29_float64_twenty_three_bits
    (fn_body JOB.f_bhv_spindel_loop) = true /\
  (** Moving wall and elevator constants. *)
  statement_mentions_float32_bits_s 1084479242
    (fn_body UOB.f_bhv_ssl_moving_pyramid_wall_loop) = true /\
  statement_mentions_float32_bits_s 1084479242
    (fn_body JOB.f_bhv_ssl_moving_pyramid_wall_loop) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body UOB.f_bhv_pyramid_elevator_loop) = true /\
  statement_mentions_float32_bits_s float32_ten_bits
    (fn_body JOB.f_bhv_pyramid_elevator_loop) = true.

Theorem rank29_platform_motion_source_shape_checked :
  Rank29PlatformMotionSourceShape.
Proof.
  unfold Rank29PlatformMotionSourceShape,
    rank29_float32_four_bits, rank29_float32_five_bits,
    rank29_float32_sixteen_bits, rank29_float32_seventy_bits,
    rank29_float32_seventy_eight_bits,
    rank29_float64_twenty_three_bits.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Area-2 collision surfaces exclude the repeatable lava bounce *)

Definition rank29_surface_has_force (surface_type : Z) : bool :=
  existsb (Z.eqb surface_type) [4; 14; 36; 37; 39; 44; 45].

Fixpoint rank29_collision_surface_types
    (fuel : nat) (words : list Z) : list Z :=
  match fuel with
  | O => []
  | S fuel' =>
      match words with
      | 65 :: _ | 66 :: _ => []
      | surface_type :: count :: rest =>
          surface_type ::
          rank29_collision_surface_types fuel'
            (skipn
              ((if rank29_surface_has_force surface_type then 4 else 3) *
               Z.to_nat count)%nat rest)
      | _ => []
      end
  end.

Definition rank29_collision_initializer_surface_types
    (initializers : list init_data) : list Z :=
  match init_int16_values initializers with
  | 64 :: vertex_count :: rest =>
      rank29_collision_surface_types 32
        (skipn (3 * Z.to_nat vertex_count)%nat rest)
  | _ => []
  end.

Definition rank29_area2_surface_types_us : list Z :=
  concat
    [rank29_collision_initializer_surface_types
       (gvar_init UCollision.v_ssl_seg7_area_2_collision);
     rank29_collision_initializer_surface_types
       (gvar_init UCollision.v_ssl_seg7_collision_grindel);
     rank29_collision_initializer_surface_types
       (gvar_init UCollision.v_ssl_seg7_collision_spindel);
     rank29_collision_initializer_surface_types
       (gvar_init UCollision.v_ssl_seg7_collision_0702808C);
     rank29_collision_initializer_surface_types
       (gvar_init UCollision.v_ssl_seg7_collision_pyramid_elevator)].

Definition rank29_area2_surface_types_jp : list Z :=
  concat
    [rank29_collision_initializer_surface_types
       (gvar_init JCollision.v_ssl_seg7_area_2_collision);
     rank29_collision_initializer_surface_types
       (gvar_init JCollision.v_ssl_seg7_collision_grindel);
     rank29_collision_initializer_surface_types
       (gvar_init JCollision.v_ssl_seg7_collision_spindel);
     rank29_collision_initializer_surface_types
       (gvar_init JCollision.v_ssl_seg7_collision_0702808C);
     rank29_collision_initializer_surface_types
       (gvar_init JCollision.v_ssl_seg7_collision_pyramid_elevator)].

Definition rank29_expected_area2_surface_types : list Z :=
  [0; 5; 11; 19; 21; 29; 30; 34; 36; 39; 45; 102; 118;
   0; 0; 0; 0; 11; 118].

Definition Rank29Area2NoBurningSurface : Prop :=
  rank29_area2_surface_types_us = rank29_expected_area2_surface_types /\
  rank29_area2_surface_types_jp = rank29_expected_area2_surface_types /\
  existsb (Z.eqb 1) rank29_area2_surface_types_us = false /\
  existsb (Z.eqb 1) rank29_area2_surface_types_jp = false.

Theorem rank29_area2_no_burning_surface_checked :
  Rank29Area2NoBurningSurface.
Proof.
  unfold Rank29Area2NoBurningSurface,
    rank29_area2_surface_types_us, rank29_area2_surface_types_jp,
    rank29_expected_area2_surface_types,
    rank29_collision_initializer_surface_types,
    rank29_surface_has_force.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Exact finite boundary model *)

Inductive Rank29StockPlatformKind : Type :=
| Rank29PyramidElevator
| Rank29MovingPyramidWall
| Rank29Spindel
| Rank29VerticalGrindel
| Rank29HorizontalGrindel.

(** Hundredths of one game unit.  The elevator cap is deliberately widened
    from its 10-unit sampled motion to 20, while the wall's 5.12 is rounded up
    to 6.  The Grindel caps retain their exact worst downward steps. *)
Definition rank29_platform_delta_cap
    (kind : Rank29StockPlatformKind) : Z :=
  match kind with
  | Rank29PyramidElevator => 2000
  | Rank29MovingPyramidWall => 600
  | Rank29Spindel => 2300
  | Rank29VerticalGrindel => 7200
  | Rank29HorizontalGrindel => 7800
  end.

Definition Rank29StockPlatformDelta
    (kind : Rank29StockPlatformKind) (delta_y : Z) : Prop :=
  - rank29_platform_delta_cap kind <= delta_y <=
    rank29_platform_delta_cap kind.

Theorem rank29_every_stock_platform_delta_is_below_off_floor_gap :
  forall kind delta_y,
    Rank29StockPlatformDelta kind delta_y ->
    -10000 < delta_y /\ delta_y < 10000.
Proof.
  intros kind delta_y Hdelta.
  destruct kind;
    unfold Rank29StockPlatformDelta, rank29_platform_delta_cap in Hdelta;
    cbn in Hdelta; lia.
Qed.

Definition rank29_off_floor_after_uncarried_shift (delta_y : Z) : bool :=
  10000 <? - delta_y.

Theorem rank29_owned_stock_platform_cannot_create_off_floor :
  forall kind delta_y,
    Rank29StockPlatformDelta kind delta_y ->
    rank29_off_floor_after_uncarried_shift delta_y = false.
Proof.
  intros kind delta_y Hdelta.
  unfold rank29_off_floor_after_uncarried_shift.
  apply Z.ltb_ge.
  pose proof
    (rank29_every_stock_platform_delta_is_below_off_floor_gap
      kind delta_y Hdelta) as [Hlower _].
  lia.
Qed.

(** The exact accelerating-lower recurrence for the vertical Grindel with
    behavior parameter 28.  The last unclamped step is n=18; its 72-unit drop
    is the largest, and the following step clamps to home. *)
Definition rank29_vertical_grindel_height (frame : Z) : Z :=
  Z.max 0 (69500 - 200 * frame * (frame + 1)).

Theorem rank29_vertical_grindel_parameter_28_drop_checked :
  rank29_vertical_grindel_height 17 = 8300 /\
  rank29_vertical_grindel_height 18 = 1100 /\
  rank29_vertical_grindel_height 19 = 0 /\
  rank29_vertical_grindel_height 17 -
    rank29_vertical_grindel_height 18 = 7200.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** On the first eligible flat landing, state 0 is consumed and horizontal
    speed is preserved.  Any subsequent landing in the same action is not a
    preserving bounce. *)
Definition rank29_butt_slide_landing
    (action_state : nat) : nat * bool :=
  match action_state with
  | O => (1%nat, true)
  | S _ => (action_state, false)
  end.

Theorem rank29_butt_slide_preserving_bounce_is_single_use :
  rank29_butt_slide_landing 0 = (1%nat, true) /\
  rank29_butt_slide_landing
    (fst (rank29_butt_slide_landing 0)) = (1%nat, false).
Proof. split; reflexivity. Qed.

Definition Rank29RepeatablePreservingBoundary : Prop :=
  (exists kind delta_y,
      Rank29StockPlatformDelta kind delta_y /\
      rank29_off_floor_after_uncarried_shift delta_y = true) \/
  (snd (rank29_butt_slide_landing 0) = true /\
   snd (rank29_butt_slide_landing
     (fst (rank29_butt_slide_landing 0))) = true).

Theorem rank29_no_repeatable_preserving_stock_boundary :
  ~ Rank29RepeatablePreservingBoundary.
Proof.
  intros [Hplatform | Hbounce].
  - destruct Hplatform as [kind [delta_y [Hdelta Hoff]]].
    rewrite (rank29_owned_stock_platform_cannot_create_off_floor
      kind delta_y Hdelta) in Hoff.
    discriminate.
  - destruct Hbounce as [_ Hsecond].
    vm_compute in Hsecond. discriminate.
Qed.

(** * Public Rank-29 closure *)

Record EyerokRank29CycleClosure : Prop := {
  rank29_cycle_preload_boundary : EyerokRank29PreloadBoundary;
  rank29_cycle_episode_source : Rank29EpisodeBoundarySourceShape;
  rank29_cycle_platform_reload_source : Rank29PlatformReloadSourceShape;
  rank29_cycle_platform_motion_source : Rank29PlatformMotionSourceShape;
  rank29_cycle_no_lava_source : Rank29Area2NoBurningSurface;
  rank29_cycle_platform_gap :
    forall kind delta_y,
      Rank29StockPlatformDelta kind delta_y ->
      rank29_off_floor_after_uncarried_shift delta_y = false;
  rank29_cycle_single_bounce :
    rank29_butt_slide_landing 0 = (1%nat, true) /\
    rank29_butt_slide_landing
      (fst (rank29_butt_slide_landing 0)) = (1%nat, false);
  rank29_cycle_no_repeatable_boundary :
    ~ Rank29RepeatablePreservingBoundary
}.

Theorem eyerok_rank29_cycle_closure_holds :
  EyerokRank29CycleClosure.
Proof.
  constructor.
  - exact eyerok_rank29_preload_boundary_holds.
  - exact rank29_episode_boundary_source_shape_checked.
  - exact rank29_platform_reload_source_shape_checked.
  - exact rank29_platform_motion_source_shape_checked.
  - exact rank29_area2_no_burning_surface_checked.
  - exact rank29_owned_stock_platform_cannot_create_off_floor.
  - exact rank29_butt_slide_preserving_bounce_is_single_use.
  - exact rank29_no_repeatable_preserving_stock_boundary.
Qed.
