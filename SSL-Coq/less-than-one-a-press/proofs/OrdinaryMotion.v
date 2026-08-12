From Coq Require Import Lia List ZArith.
From compcert Require Import Clight Events Floats Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts GameTypes InputSemantics CleanEntry AreaTransitions ClightFacts
  CollisionMeshFacts ClightRefinement FirstTargetRefinement
  FirstCrossingWriterCoverage RouteEvidence.

Import ListNotations.
Local Open Scope Z_scope.

(** * Ordinary-motion proof boundary

    This module does not claim that retail ordinary Mario motion is unable to
    reach either target.  It separates three facts which must not be conflated:

    - consequences already supplied by a [ClightFrameEvidence] record;
    - a generic finite-cell safe-envelope preservation argument; and
    - closed integer arithmetic for two candidate ascent chains.

    Instantiating the envelope with the US/JP Area-2 collision mesh, and linking
    the ascent arithmetic to the generated Clight execution and collision
    queries, remain the narrow obligations named below. *)

(** ** Structural consequences of existing frame evidence *)

Lemma clight_physics_frame_endpoints_align :
  forall projection run initial certificate index from to before after
      (evidence :
        ClightFrameEvidence projection run initial certificate index
          (EventMarioMotion MotionPhysicsFrame from to) before after),
    state_mario_kinematics before = from /\
    state_mario_kinematics after = to /\
    state_area after = state_area before.
Proof.
  intros projection run initial certificate index from to before after
    evidence.
  pose proof
    (certified_step_at_is_step
      _ _ _ _ _ _ _
      (frame_certified_occurrence
        _ _ _ _ _ _ _ _ evidence)) as Hstep.
  pose proof
    (certified_non_target_spatial_effect
      before (EventMarioMotion MotionPhysicsFrame from to) after
      Hstep (NonTargetMarioMotion MotionPhysicsFrame from to)) as Hspatial.
  cbn in Hspatial.
  tauto.
Qed.

Lemma clight_frame_has_projected_no_a_sample :
  forall projection run initial certificate index event before after
      (evidence :
        ClightFrameEvidence projection run initial certificate index
          event before after),
    fewer_than_one_a_press (project_inputs projection run) ->
    exists input,
      nth_error (project_inputs projection run) (S index) = Some input /\
      frame_has_no_a_press input.
Proof.
  intros projection run initial certificate index event before after
    evidence Hno_a.
  pose proof
    (frame_projected_event _ _ _ _ _ _ _ _ evidence) as Hevent.
  assert (Hindex_events :
    (index < length (project_events projection run))%nat).
  {
    apply nth_error_Some.
    rewrite Hevent.
    discriminate.
  }
  assert (Hindex_inputs :
    (S index < length (project_inputs projection run))%nat).
  {
    rewrite (refined_input_count projection run initial certificate).
    lia.
  }
  apply nth_error_Some in Hindex_inputs.
  destruct (nth_error (project_inputs projection run) (S index))
    as [input |] eqn:Hinput.
  - exists input. split; [reflexivity |].
    unfold fewer_than_one_a_press in Hno_a.
    rewrite Forall_forall in Hno_a.
    apply Hno_a.
    exact
      (nth_error_In (project_inputs projection run) (S index) Hinput).
  - exfalso. apply Hindex_inputs. reflexivity.
Qed.

Lemma ordinary_writer_event_inversion :
  forall event,
    EventHasPositionWriter event FirstWriterOrdinaryPhysics ->
    exists from to,
      event = EventMarioMotion MotionPhysicsFrame from to.
Proof.
  intros event Hwriter.
  inversion Hwriter; subst.
  exists before, after.
  reflexivity.
Qed.

(** [clight_frame_has_projected_no_a_sample] is deliberately only a list-level
    fact.  The current projection does not yet prove that this sample is the
    controller memory read by the named Clight segment. *)

(** ** A generic, finite-cell safe envelope

    The envelope is not the opaque predicate "the target is unreachable".
    Membership requires an exhibited member of a finite list and a concrete
    state-to-cell relation.  A retail instantiation must define that relation
    from parsed collision surfaces, action state, and finite-width kinematic
    bounds. *)

Section ConcreteSafeEnvelope.

  Context {Cell : Type}.

  Record OrdinarySafeEnvelope := {
    ordinary_safe_cells : list Cell;
    ordinary_state_in_cell : Cell -> GameState -> Prop
  }.

  Definition state_in_ordinary_envelope
      (envelope : OrdinarySafeEnvelope) (state : GameState) : Prop :=
    exists cell,
      In cell (ordinary_safe_cells envelope) /\
      ordinary_state_in_cell envelope cell state.

  Variable ordinary_step : FrameInput -> GameState -> GameState -> Prop.
  Variable target_state : GameState -> Prop.

  Definition OrdinaryEnvelopePreservationObligation
      (envelope : OrdinarySafeEnvelope) : Prop :=
    forall input before after,
      frame_has_no_a_press input ->
      state_in_ordinary_envelope envelope before ->
      ordinary_step input before after ->
      state_in_ordinary_envelope envelope after.

  Definition OrdinaryEnvelopeTargetExclusionObligation
      (envelope : OrdinarySafeEnvelope) : Prop :=
    forall state,
      state_in_ordinary_envelope envelope state ->
      target_state state ->
      False.

  Inductive OrdinaryMotionExecution :
      GameState -> list FrameInput -> GameState -> Prop :=
  | OrdinaryMotionExecutionNil :
      forall state,
        OrdinaryMotionExecution state [] state
  | OrdinaryMotionExecutionCons :
      forall before middle after input inputs,
        ordinary_step input before middle ->
        OrdinaryMotionExecution middle inputs after ->
        OrdinaryMotionExecution before (input :: inputs) after.

  Theorem ordinary_safe_envelope_step_excludes_target :
    forall envelope input before after,
      OrdinaryEnvelopePreservationObligation envelope ->
      OrdinaryEnvelopeTargetExclusionObligation envelope ->
      frame_has_no_a_press input ->
      state_in_ordinary_envelope envelope before ->
      ordinary_step input before after ->
      target_state after ->
      False.
  Proof.
    intros envelope input before after Hpreserves Hexcludes
      Hno_a Hbefore Hstep Htarget.
    eapply Hexcludes.
    - eapply Hpreserves; eauto.
    - exact Htarget.
  Qed.

  Theorem ordinary_safe_envelope_execution_preserved :
    forall envelope before inputs after,
      OrdinaryEnvelopePreservationObligation envelope ->
      fewer_than_one_a_press inputs ->
      state_in_ordinary_envelope envelope before ->
      OrdinaryMotionExecution before inputs after ->
      state_in_ordinary_envelope envelope after.
  Proof.
    intros envelope before inputs after Hpreserves Hno_a Hsafe Hexecution.
    induction Hexecution.
    - exact Hsafe.
    - inversion Hno_a as [| input' inputs' Hhead Htail]; subst.
      apply IHHexecution.
      + exact Htail.
      + eapply Hpreserves; eauto.
  Qed.

  Theorem ordinary_safe_envelope_execution_excludes_target :
    forall envelope before inputs after,
      OrdinaryEnvelopePreservationObligation envelope ->
      OrdinaryEnvelopeTargetExclusionObligation envelope ->
      fewer_than_one_a_press inputs ->
      state_in_ordinary_envelope envelope before ->
      OrdinaryMotionExecution before inputs after ->
      target_state after ->
      False.
  Proof.
    intros envelope before inputs after Hpreserves Hexcludes
      Hno_a Hsafe Hexecution Htarget.
    eapply Hexcludes.
    - eapply ordinary_safe_envelope_execution_preserved; eauto.
    - exact Htarget.
  Qed.

End ConcreteSafeEnvelope.

(** ** Narrow linkage obligations

    These interfaces contain no target region and no reachability conclusion.
    They name the two missing refinements required before the generic envelope
    theorem can say anything about retail execution.  A concrete instance must
    be proved from the generated US/JP Clight and parsed collision arrays. *)

Definition OrdinaryMotionSourceExecutionLinkageObligation
    (projection : ClightObservationProjection)
    (source_ordinary_segment : Clight.state -> Clight.state -> Prop)
    (resolved_ordinary_step :
      FrameInput -> GameState -> GameState -> Prop) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial)
      index from to before after
      (evidence :
        ClightFrameEvidence projection run initial certificate index
          (EventMarioMotion MotionPhysicsFrame from to) before after),
    source_ordinary_segment
      (frame_before_clight _ _ _ _ _ _ _ _ evidence)
      (frame_after_clight _ _ _ _ _ _ _ _ evidence) ->
    exists input,
      nth_error (project_inputs projection run) (S index) = Some input /\
      resolved_ordinary_step input before after.

Definition OrdinaryMotionCollisionLinkageObligation
    (projection : ClightObservationProjection)
    (observation_belongs_to_frame :
      nat -> CollisionObservation -> Prop) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial)
      index from to before after
      (evidence :
        ClightFrameEvidence projection run initial certificate index
          (EventMarioMotion MotionPhysicsFrame from to) before after)
      observation,
    observation_belongs_to_frame index observation ->
    In observation (project_collision_observations projection run) /\
    collision_mario_position (observed_phase observation) =
      mario_position (state_mario_kinematics after) /\
    collision_area (observed_phase observation) = state_area after.

(** A retail instantiation additionally needs every intermediate ground/air
    quarter-step floor, wall, and ceiling query.  Endpoint locality alone does
    not discharge that requirement. *)
Definition OrdinaryMotionIntermediateQueryLinkageObligation
    (projection : ClightObservationProjection)
    (query_is_local :
      Clight.state -> Clight.state -> Prop) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial)
      index from to before after
      (evidence :
        ClightFrameEvidence projection run initial certificate index
          (EventMarioMotion MotionPhysicsFrame from to) before after),
    CoordinatesInLocalCastDomain from ->
    CoordinatesInLocalCastDomain to ->
    query_is_local
      (frame_before_clight _ _ _ _ _ _ _ _ evidence)
      (frame_after_clight _ _ _ _ _ _ _ _ evidence).

(** [GameState] does not currently project [MarioState.flags] or [capTimer].
    A retained Wing Cap changes airborne physics and therefore invalidates a
    generic ascent bound.  Retail initialization clears the special-cap timer,
    but that source fact still needs this concrete entry-memory projection. *)
Record OrdinaryMotionCapState := {
  ordinary_cap_flags : Int.int;
  ordinary_cap_timer : Int.int
}.

Definition mario_wing_cap_mask : Int.int := Int.repr 8.

Definition ordinary_wing_cap_inactive
    (cap : OrdinaryMotionCapState) : Prop :=
  Int.and (ordinary_cap_flags cap) mario_wing_cap_mask = Int.zero /\
  ordinary_cap_timer cap = Int.zero.

Definition OrdinaryMotionCapFlagsEntryProjectionObligation
    (projection : ClightObservationProjection)
    (project_cap_state :
      Clight.state -> option OrdinaryMotionCapState) : Prop :=
  forall run initial
      (certificate :
        ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    exists cap,
      project_cap_state (run_start run) = Some cap /\
      ordinary_wing_cap_inactive cap.

(** ** Checked upper source-shape bundle

    These propositions package generated-AST receipts only.  They do not
    execute the entry fall, select a live wall/floor, establish cap state at a
    projected clean entry, or prove any candidate action reachable. *)

Definition UpperEntryDescentSourceShapeKernel : Prop :=
  (calls_ident_s ULU._set_mario_action
      (fn_body ULU.f_set_mario_initial_action) = true /\
   statement_mentions_int_s act_spawn_no_spin_airborne_bits
      (fn_body ULU.f_set_mario_initial_action) = true) /\
  (calls_ident_s JLU._set_mario_action
      (fn_body JLU.f_set_mario_initial_action) = true /\
   statement_mentions_int_s act_spawn_no_spin_airborne_bits
      (fn_body JLU.f_set_mario_initial_action) = true) /\
  (calls_ident_with_float32_arg_s
      UCutscene._launch_mario_until_land 0
      (fn_body UCutscene.f_act_spawn_no_spin_airborne) = true /\
   calls_ident_s UCutscene._mario_set_forward_vel
      (fn_body UCutscene.f_launch_mario_until_land) = true /\
   calls_ident_s UCutscene._perform_air_step
      (fn_body UCutscene.f_launch_mario_until_land) = true) /\
  (calls_ident_with_float32_arg_s
      JCutscene._launch_mario_until_land 0
      (fn_body JCutscene.f_act_spawn_no_spin_airborne) = true /\
   calls_ident_s JCutscene._mario_set_forward_vel
      (fn_body JCutscene.f_launch_mario_until_land) = true /\
   calls_ident_s JCutscene._perform_air_step
      (fn_body JCutscene.f_launch_mario_until_land) = true).

Theorem upper_entry_descent_source_shape_kernel_checked :
  UpperEntryDescentSourceShapeKernel.
Proof.
  unfold UpperEntryDescentSourceShapeKernel.
  split; [exact airborne_entry_action_source_shape_us |].
  split; [exact airborne_entry_action_source_shape_jp |].
  split; [exact no_spin_airborne_entry_update_source_shape_us |].
  exact no_spin_airborne_entry_update_source_shape_jp.
Qed.

Definition UpperCandidateActionSourceShapeKernel : Prop :=
  held_a_jump_kick_source_shape_us_claim /\
  held_a_jump_kick_source_shape_jp_claim /\
  b_rollout_chain_source_shape_us_claim /\
  b_rollout_chain_source_shape_jp_claim.

Theorem upper_candidate_action_source_shape_kernel_checked :
  UpperCandidateActionSourceShapeKernel.
Proof.
  unfold UpperCandidateActionSourceShapeKernel.
  split; [exact held_a_jump_kick_source_shape_us |].
  split; [exact held_a_jump_kick_source_shape_jp |].
  split; [exact b_rollout_chain_source_shape_us |].
  exact b_rollout_chain_source_shape_jp.
Qed.

Definition UpperWallAndCapSourceShapeKernel : Prop :=
  retail_entry_cap_reset_source_shape_us_claim /\
  retail_entry_cap_reset_source_shape_jp_claim /\
  pyramid_elevator_motion_source_shape_us_claim /\
  pyramid_elevator_motion_source_shape_jp_claim /\
  calls_ident_with_float32_arg_s
    UStep._resolve_and_return_wall_collisions float32_thirty_bits
    (fn_body UStep.f_perform_air_quarter_step) = true /\
  calls_ident_with_float32_arg_s
    JStep._resolve_and_return_wall_collisions float32_thirty_bits
    (fn_body JStep.f_perform_air_quarter_step) = true /\
  assigns_field_from_temp_plus_int_s
    USurfaceLoad._upperY USurfaceLoad._maxY 5
    (fn_body USurfaceLoad.f_read_surface_data) = true /\
  assigns_field_from_temp_plus_int_s
    JSurfaceLoad._upperY JSurfaceLoad._maxY 5
    (fn_body JSurfaceLoad.f_read_surface_data) = true /\
  contains_strict_temp_gt_loaded_field_s USurface._y USurface._upperY
    (fn_body USurface.f_find_wall_collisions_from_list) = true /\
  contains_strict_temp_gt_loaded_field_s JSurface._y JSurface._upperY
    (fn_body JSurface.f_find_wall_collisions_from_list) = true.

Theorem upper_wall_and_cap_source_shape_kernel_checked :
  UpperWallAndCapSourceShapeKernel.
Proof.
  unfold UpperWallAndCapSourceShapeKernel.
  split; [exact retail_entry_cap_reset_source_shape_us |].
  split; [exact retail_entry_cap_reset_source_shape_jp |].
  split; [exact pyramid_elevator_motion_source_shape_us |].
  split; [exact pyramid_elevator_motion_source_shape_jp |].
  split; [exact air_quarter_lower_wall_query_source_shape_us |].
  split; [exact air_quarter_lower_wall_query_source_shape_jp |].
  split; [exact surface_upper_y_padding_source_shape_us |].
  split; [exact surface_upper_y_padding_source_shape_jp |].
  split; [exact wall_upper_y_strict_rejection_source_shape_us |].
  exact wall_upper_y_strict_rejection_source_shape_jp.
Qed.

Definition UpperOrdinarySourceShapeKernel : Prop :=
  UpperEntryDescentSourceShapeKernel /\
  UpperCandidateActionSourceShapeKernel /\
  UpperWallAndCapSourceShapeKernel.

Theorem upper_ordinary_source_shape_kernel_checked :
  UpperOrdinarySourceShapeKernel.
Proof.
  split; [exact upper_entry_descent_source_shape_kernel_checked |].
  split; [exact upper_candidate_action_source_shape_kernel_checked |].
  exact upper_wall_and_cap_source_shape_kernel_checked.
Qed.

(** ** Closed ascent arithmetic

    [accumulated_positive_ascent initial gravity frames] sums the positive
    vertical increments [initial - gravity * frame] for the requested number
    of frames.  The model uses mathematical integers only after fixing the
    exact integral values observed in the candidate action chain.  The
    source-to-Float32 execution refinement is not asserted here. *)

Definition normal_gravity_per_frame : Z := 4.
Definition elevator_descent_per_frame : Z := 10.
Definition lower_wall_query_offset : Z := 30.
Definition dynamic_surface_upper_y_pad : Z := 5.
(** Integer-translation vertical rejection threshold.  The linked Float32 to
    signed-short transformed-vertex execution for nonintegral elevator
    positions remains part of the intermediate-query obligation. *)
Definition pyramid_elevator_cage_clearance : Z :=
  256 + dynamic_surface_upper_y_pad - lower_wall_query_offset.

Definition vertical_increment
    (initial_velocity gravity : Z) (frame : nat) : Z :=
  initial_velocity - gravity * Z.of_nat frame.

Fixpoint accumulated_positive_ascent
    (initial_velocity gravity : Z) (frames : nat) : Z :=
  match frames with
  | O => 0
  | S earlier =>
      accumulated_positive_ascent initial_velocity gravity earlier +
      Z.max 0 (vertical_increment initial_velocity gravity earlier)
  end.

Lemma accumulated_positive_ascent_one_step_monotone :
  forall initial_velocity gravity frames,
    accumulated_positive_ascent initial_velocity gravity frames <=
    accumulated_positive_ascent initial_velocity gravity (S frames).
Proof.
  intros initial_velocity gravity frames.
  cbn [accumulated_positive_ascent].
  pose proof
    (Z.le_max_l 0
      (vertical_increment initial_velocity gravity frames)).
  lia.
Qed.

Lemma accumulated_positive_ascent_monotone :
  forall initial_velocity gravity earlier later,
    (earlier <= later)%nat ->
    accumulated_positive_ascent initial_velocity gravity earlier <=
    accumulated_positive_ascent initial_velocity gravity later.
Proof.
  intros initial_velocity gravity earlier later Hle.
  induction Hle.
  - apply Z.le_refl.
  - eapply Z.le_trans.
    + exact IHHle.
    + apply accumulated_positive_ascent_one_step_monotone.
Qed.

Definition held_a_jump_kick_initial_vy : Z := 20.
Definition rollout_initial_vy : Z := 30.

Definition held_a_jump_kick_absolute_ascent (frames : nat) : Z :=
  accumulated_positive_ascent
    held_a_jump_kick_initial_vy normal_gravity_per_frame frames.

(** Elevator-relative increments receive a conservative [+10] on the first
    frame as well as subsequent descending-elevator frames. *)
Definition held_a_jump_kick_elevator_relative_ascent
    (frames : nat) : Z :=
  accumulated_positive_ascent
    (held_a_jump_kick_initial_vy + elevator_descent_per_frame)
    normal_gravity_per_frame frames.

Definition rollout_elevator_relative_ascent (frames : nat) : Z :=
  accumulated_positive_ascent
    (rollout_initial_vy + elevator_descent_per_frame)
    normal_gravity_per_frame frames.

Lemma held_a_jump_kick_absolute_ascent_saturates :
  forall extra_frames,
    held_a_jump_kick_absolute_ascent (5 + extra_frames)%nat = 60.
Proof.
  unfold held_a_jump_kick_absolute_ascent.
  induction extra_frames as [|extra_frames IH].
  - vm_compute. reflexivity.
  - replace (5 + S extra_frames)%nat with
      (S (5 + extra_frames))%nat by lia.
    cbn [accumulated_positive_ascent].
    rewrite IH.
    assert (Hvelocity :
      vertical_increment held_a_jump_kick_initial_vy
        normal_gravity_per_frame (5 + extra_frames)%nat <= 0).
    {
      unfold vertical_increment, held_a_jump_kick_initial_vy,
        normal_gravity_per_frame.
      rewrite Nat2Z.inj_add.
      pose proof (Nat2Z.is_nonneg extra_frames).
      lia.
    }
    rewrite Z.max_l by exact Hvelocity.
    lia.
Qed.

Theorem held_a_jump_kick_normal_absolute_ascent_bound :
  forall frames,
    held_a_jump_kick_absolute_ascent frames <= 60.
Proof.
  intros frames.
  destruct (le_dec frames 5) as [Hsmall | Hlarge].
  - eapply Z.le_trans.
    + apply accumulated_positive_ascent_monotone.
      exact Hsmall.
    + vm_compute. discriminate.
  - replace frames with (5 + (frames - 5))%nat by lia.
    rewrite held_a_jump_kick_absolute_ascent_saturates.
    lia.
Qed.

Lemma held_a_jump_kick_relative_ascent_saturates :
  forall extra_frames,
    held_a_jump_kick_elevator_relative_ascent
      (8 + extra_frames)%nat = 128.
Proof.
  unfold held_a_jump_kick_elevator_relative_ascent.
  induction extra_frames as [|extra_frames IH].
  - vm_compute. reflexivity.
  - replace (8 + S extra_frames)%nat with
      (S (8 + extra_frames))%nat by lia.
    cbn [accumulated_positive_ascent].
    rewrite IH.
    assert (Hvelocity :
      vertical_increment
        (held_a_jump_kick_initial_vy + elevator_descent_per_frame)
        normal_gravity_per_frame (8 + extra_frames)%nat <= 0).
    {
      unfold vertical_increment, held_a_jump_kick_initial_vy,
        elevator_descent_per_frame, normal_gravity_per_frame.
      rewrite Nat2Z.inj_add.
      pose proof (Nat2Z.is_nonneg extra_frames).
      lia.
    }
    rewrite Z.max_l by exact Hvelocity.
    lia.
Qed.

Theorem held_a_jump_kick_elevator_relative_ascent_bound :
  forall frames,
    held_a_jump_kick_elevator_relative_ascent frames <= 128.
Proof.
  intros frames.
  destruct (le_dec frames 8) as [Hsmall | Hlarge].
  - eapply Z.le_trans.
    + apply accumulated_positive_ascent_monotone.
      exact Hsmall.
    + vm_compute. discriminate.
  - replace frames with (8 + (frames - 8))%nat by lia.
    rewrite held_a_jump_kick_relative_ascent_saturates.
    lia.
Qed.

Theorem held_a_jump_kick_relative_ascent_below_cage_clearance :
  128 < pyramid_elevator_cage_clearance.
Proof.
  unfold pyramid_elevator_cage_clearance, dynamic_surface_upper_y_pad,
    lower_wall_query_offset.
  lia.
Qed.

Lemma rollout_relative_ascent_saturates :
  forall extra_frames,
    rollout_elevator_relative_ascent (10 + extra_frames)%nat = 220.
Proof.
  unfold rollout_elevator_relative_ascent.
  induction extra_frames as [|extra_frames IH].
  - vm_compute. reflexivity.
  - replace (10 + S extra_frames)%nat with
      (S (10 + extra_frames))%nat by lia.
    cbn [accumulated_positive_ascent].
    rewrite IH.
    assert (Hvelocity :
      vertical_increment
        (rollout_initial_vy + elevator_descent_per_frame)
        normal_gravity_per_frame (10 + extra_frames)%nat <= 0).
    {
      unfold vertical_increment, rollout_initial_vy,
        elevator_descent_per_frame, normal_gravity_per_frame.
      rewrite Nat2Z.inj_add.
      pose proof (Nat2Z.is_nonneg extra_frames).
      lia.
    }
    rewrite Z.max_l by exact Hvelocity.
    lia.
Qed.

Theorem rollout_elevator_relative_ascent_bound :
  forall frames,
    rollout_elevator_relative_ascent frames <= 220.
Proof.
  intros frames.
  destruct (le_dec frames 10) as [Hsmall | Hlarge].
  - eapply Z.le_trans.
    + apply accumulated_positive_ascent_monotone.
      exact Hsmall.
    + vm_compute. discriminate.
  - replace frames with (10 + (frames - 10))%nat by lia.
    rewrite rollout_relative_ascent_saturates.
    lia.
Qed.

Theorem rollout_relative_ascent_below_cage_clearance :
  220 < pyramid_elevator_cage_clearance.
Proof.
  unfold pyramid_elevator_cage_clearance, dynamic_surface_upper_y_pad,
    lower_wall_query_offset.
  lia.
Qed.

(** The arithmetic is compatible with continuously held A having no new edge,
    but it does not prove that the retail action dispatcher selects either
    chain or that the collision queries retain the modeled clearance. *)
Theorem held_a_ascent_schedule_has_no_new_a_edges :
  forall frames,
    fewer_than_one_a_press (repeat held_a_frame frames).
Proof.
  exact continuously_held_a_has_no_press_edges.
Qed.

(** ** Arithmetic cap-state countermodel

    This is a countermodel to applying the non-Wing 4-unit-gravity bound
    without first projecting Mario's flags and cap timer.  It is not a
    reachable retail execution or a target-region witness.

    The rollout begins at vertical velocity 30.  While velocity is
    nonnegative, the closed model subtracts the non-Wing gravity value 4.
    Once negative, continuously held A with a retained Wing Cap uses the
    candidate decrement 2.  Adding the elevator's 10-unit descent produces
    total relative rise 228.  This refutes reuse of the non-Wing 220 bound,
    but remains below the integer-translation wall rejection threshold 231.
    It is therefore not a vertical-clearance counterexample. *)
Definition wing_cap_held_gravity_step (vertical_velocity : Z) : Z :=
  if Z.geb vertical_velocity 0
  then vertical_velocity - normal_gravity_per_frame
  else vertical_velocity - 2.

Definition wing_cap_rollout_velocity_trace : list Z :=
  [30; 26; 22; 18; 14; 10; 6; 2; -2; -4; -6; -8].

Fixpoint follows_vertical_step
    (step : Z -> Z) (samples : list Z) : bool :=
  match samples with
  | before :: (after :: _ as rest) =>
      Z.eqb after (step before) && follows_vertical_step step rest
  | _ => true
  end.

Definition wing_cap_rollout_relative_rise : Z :=
  fold_right Z.add 0
    (map
      (fun velocity => velocity + elevator_descent_per_frame)
      wing_cap_rollout_velocity_trace).

Theorem wing_cap_rollout_trace_follows_piecewise_gravity :
  follows_vertical_step
    wing_cap_held_gravity_step wing_cap_rollout_velocity_trace = true.
Proof. vm_compute. reflexivity. Qed.

Theorem wing_cap_rollout_relative_rise_is_228 :
  wing_cap_rollout_relative_rise = 228.
Proof. vm_compute. reflexivity. Qed.

Theorem wing_cap_rollout_arithmetic_exceeds_non_wing_rollout_bound :
  220 < wing_cap_rollout_relative_rise.
Proof.
  rewrite wing_cap_rollout_relative_rise_is_228.
  lia.
Qed.

Theorem wing_cap_rollout_arithmetic_below_integer_wall_clearance :
  wing_cap_rollout_relative_rise < pyramid_elevator_cage_clearance.
Proof.
  rewrite wing_cap_rollout_relative_rise_is_228.
  unfold pyramid_elevator_cage_clearance, dynamic_surface_upper_y_pad,
    lower_wall_query_offset.
  lia.
Qed.

Theorem wing_cap_rollout_arithmetic_countermodel :
  follows_vertical_step
      wing_cap_held_gravity_step wing_cap_rollout_velocity_trace = true /\
  wing_cap_rollout_relative_rise = 228 /\
  220 < wing_cap_rollout_relative_rise /\
  wing_cap_rollout_relative_rise < pyramid_elevator_cage_clearance /\
  fewer_than_one_a_press
    (repeat held_a_frame (length wing_cap_rollout_velocity_trace)).
Proof.
  split.
  - exact wing_cap_rollout_trace_follows_piecewise_gravity.
  - split.
    + exact wing_cap_rollout_relative_rise_is_228.
    + split.
      * exact wing_cap_rollout_arithmetic_exceeds_non_wing_rollout_bound.
      * split.
        -- exact wing_cap_rollout_arithmetic_below_integer_wall_clearance.
        -- apply held_a_ascent_schedule_has_no_new_a_edges.
Qed.

(** ** Closed upper-ascent kernel

    This conjunction packages four kinds of already checked evidence:

    - generated US/JP syntax receipts for the held-A jump-kick and B-rollout
      chains;
    - exact US/JP decoding of the raw elevator vertex prefix;
    - the base-floor, upper-rim, and whole-prefix integer mesh facts; and
    - the closed ascent arithmetic above.

    It is intentionally not a Clight execution theorem.  It proves neither
    branch reachability nor transformed live-surface ownership, collision-list
    selection, cap-state refinement, or containment of an actual Mario frame. *)
Definition UpperOrdinaryAscentKernel : Prop :=
  UpperOrdinarySourceShapeKernel /\
  pyramid_elevator_vertices_us = pyramid_elevator_vertices /\
  pyramid_elevator_vertices_jp = pyramid_elevator_vertices /\
  Forall
    (fun vertex => vertex_y vertex = 0)
    pyramid_elevator_base_floor_vertices /\
  Forall
    (fun vertex => vertex_y vertex = 256)
    pyramid_elevator_upper_rim_vertices /\
  collision_vertex_bounds pyramid_elevator_vertices =
    (Some (-511, 512), Some (-50, 256), Some (-511, 512)) /\
  (forall frames,
    held_a_jump_kick_absolute_ascent frames <= 60) /\
  (forall frames,
    held_a_jump_kick_elevator_relative_ascent frames <= 128) /\
  128 < pyramid_elevator_cage_clearance /\
  (forall frames,
    rollout_elevator_relative_ascent frames <= 220) /\
  220 < pyramid_elevator_cage_clearance.

Theorem upper_ordinary_ascent_kernel_checked :
  UpperOrdinaryAscentKernel.
Proof.
  unfold UpperOrdinaryAscentKernel.
  refine (conj upper_ordinary_source_shape_kernel_checked _).
  refine (conj pyramid_elevator_vertices_exact_us _).
  refine (conj pyramid_elevator_vertices_exact_jp _).
  refine (conj pyramid_elevator_base_floor_local_y_is_zero _).
  refine (conj pyramid_elevator_upper_rim_local_y_is_256 _).
  refine (conj pyramid_elevator_generated_vertex_bounds _).
  refine (conj held_a_jump_kick_normal_absolute_ascent_bound _).
  refine (conj held_a_jump_kick_elevator_relative_ascent_bound _).
  refine (conj
    held_a_jump_kick_relative_ascent_below_cage_clearance _).
  refine (conj rollout_elevator_relative_ascent_bound _).
  exact rollout_relative_ascent_below_cage_clearance.
Qed.
