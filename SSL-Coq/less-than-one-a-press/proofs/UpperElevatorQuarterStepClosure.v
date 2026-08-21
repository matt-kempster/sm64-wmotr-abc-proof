(** Exact Float32 quarter-step closure for the upper elevator candidates.

    The earlier [OrdinaryMotion] bounds added Mario's per-frame rise to the
    elevator's ten-unit descent.  That is enough for rendered endpoints, but
    collision is queried four times inside each frame, after the elevator has
    moved and before Mario completes the frame.  This file executes that
    Float32 schedule exactly.

    The result strengthens the ordinary (non-Wing) cases: held-A jump-kick
    queries at relative Y at most 134 and B rollout at most 224.5, both below
    the strict 231-unit height at which the lower wall query can miss the
    elevator's padded inner wall.  It also corrects a false comfort in the old
    Wing endpoint bound: a retained Wing Cap has a transient query at 234 even
    though its frame endpoints peak at 228.  Thus the Wing case is not closed
    by endpoint arithmetic; a linked proof must establish the real cap reset.

    Generated-source receipts below also enumerate every literal result of
    [perform_air_quarter_step] and the four-quarter-step/gravity order.  They
    make the action/collision split finite, but do not claim a live wall or
    floor is selected.  The remaining retail obligation is now explicitly the
    initial descent/elevator landing plus live surface and cap-state projection. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  jp_mario jp_mario_step us_mario us_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1InteractionShortCircuitClosure Area2ElevatorCut ClightFacts
  OrdinaryMotion.

Import ListNotations.
Local Open Scope Z_scope.

Module UEQ_UStep := us_mario_step.
Module UEQ_JStep := jp_mario_step.
Module UEQ_UMario := us_mario.
Module UEQ_JMario := jp_mario.

Definition ueq_f32 (value : Z) : float32 :=
  Float32.of_int (Int.repr value).

Definition ueq_f32_four := ueq_f32 4.
Definition ueq_f32_ten := ueq_f32 10.
Definition ueq_f32_cutoff := ueq_f32 pyramid_elevator_cage_clearance.

Definition ueq_quarter_delta (velocity : float32) : float32 :=
  Float32.div velocity ueq_f32_four.

Fixpoint ueq_quarter_positions
    (quarters : nat) (relative_y velocity : float32) : list float32 :=
  match quarters with
  | O => []
  | S earlier =>
      let next := Float32.add relative_y (ueq_quarter_delta velocity) in
      next :: ueq_quarter_positions earlier next velocity
  end.

Fixpoint ueq_advance_quarters
    (quarters : nat) (relative_y velocity : float32) : float32 :=
  match quarters with
  | O => relative_y
  | S earlier =>
      ueq_advance_quarters earlier
        (Float32.add relative_y (ueq_quarter_delta velocity)) velocity
  end.

Fixpoint ueq_nonwing_frames
    (frames : nat) (relative_y velocity : float32) : list float32 :=
  match frames with
  | O => []
  | S earlier =>
      let after_elevator := Float32.add relative_y ueq_f32_ten in
      ueq_quarter_positions 4 after_elevator velocity ++
      ueq_nonwing_frames earlier
        (ueq_advance_quarters 4 after_elevator velocity)
        (Float32.sub velocity (ueq_f32 normal_gravity_per_frame))
  end.

Fixpoint ueq_velocity_frames
    (relative_y : float32) (velocities : list Z) : list float32 :=
  match velocities with
  | [] => []
  | velocity :: rest =>
      let velocity_f32 := ueq_f32 velocity in
      let after_elevator := Float32.add relative_y ueq_f32_ten in
      ueq_quarter_positions 4 after_elevator velocity_f32 ++
      ueq_velocity_frames
        (ueq_advance_quarters 4 after_elevator velocity_f32) rest
  end.

(** All candidate velocities are even integers.  Measuring relative height in
    half-unit ticks makes every [/4] qstep integral while retaining exact
    binary32 representability.  The checker below separately validates each
    generated Float32 addition against this recurrence, avoiding exponential
    normalization of a deeply nested float expression. *)
Definition ueq_half_f32 (half_units : Z) : float32 :=
  Float32.div (ueq_f32 half_units) (ueq_f32 2).

Fixpoint ueq_scaled_quarter_positions
    (quarters : nat) (relative_half velocity : Z) : list Z :=
  match quarters with
  | O => []
  | S earlier =>
      let next := relative_half + velocity / 2 in
      next :: ueq_scaled_quarter_positions earlier next velocity
  end.

Fixpoint ueq_scaled_advance_quarters
    (quarters : nat) (relative_half velocity : Z) : Z :=
  match quarters with
  | O => relative_half
  | S earlier =>
      ueq_scaled_advance_quarters earlier
        (relative_half + velocity / 2) velocity
  end.

Fixpoint ueq_scaled_nonwing_frames
    (frames : nat) (relative_half velocity : Z) : list Z :=
  match frames with
  | O => []
  | S earlier =>
      let after_elevator := relative_half + 20 in
      ueq_scaled_quarter_positions 4 after_elevator velocity ++
      ueq_scaled_nonwing_frames earlier
        (ueq_scaled_advance_quarters 4 after_elevator velocity)
        (velocity - normal_gravity_per_frame)
  end.

Fixpoint ueq_scaled_velocity_frames
    (relative_half : Z) (velocities : list Z) : list Z :=
  match velocities with
  | [] => []
  | velocity :: rest =>
      let after_elevator := relative_half + 20 in
      ueq_scaled_quarter_positions 4 after_elevator velocity ++
      ueq_scaled_velocity_frames
        (ueq_scaled_advance_quarters 4 after_elevator velocity) rest
  end.

Fixpoint ueq_scaled_quarter_transitions
    (quarters : nat) (relative_half velocity : Z) : list (Z * Z) :=
  match quarters with
  | O => []
  | S earlier =>
      (relative_half, velocity) ::
      ueq_scaled_quarter_transitions earlier
        (relative_half + velocity / 2) velocity
  end.

Fixpoint ueq_scaled_nonwing_transitions
    (frames : nat) (relative_half velocity : Z) : list (Z * Z) :=
  match frames with
  | O => []
  | S earlier =>
      let after_elevator := relative_half + 20 in
      ueq_scaled_quarter_transitions 4 after_elevator velocity ++
      ueq_scaled_nonwing_transitions earlier
        (ueq_scaled_advance_quarters 4 after_elevator velocity)
        (velocity - normal_gravity_per_frame)
  end.

Fixpoint ueq_scaled_velocity_transitions
    (relative_half : Z) (velocities : list Z) : list (Z * Z) :=
  match velocities with
  | [] => []
  | velocity :: rest =>
      let after_elevator := relative_half + 20 in
      ueq_scaled_quarter_transitions 4 after_elevator velocity ++
      ueq_scaled_velocity_transitions
        (ueq_scaled_advance_quarters 4 after_elevator velocity) rest
  end.

Definition ueq_float32_transition_exact (transition : Z * Z) : bool :=
  let '(relative_half, velocity) := transition in
  Int.eq
    (Float32.to_bits
      (Float32.add (ueq_half_f32 relative_half)
        (Float32.div (ueq_f32 velocity) ueq_f32_four)))
    (Float32.to_bits (ueq_half_f32 (relative_half + velocity / 2))).

Definition held_a_jump_kick_scaled_qsteps : list Z :=
  ueq_scaled_nonwing_frames 8 0 held_a_jump_kick_initial_vy.

Definition b_rollout_scaled_qsteps : list Z :=
  ueq_scaled_nonwing_frames 10 0 rollout_initial_vy.

Definition wing_rollout_scaled_qsteps : list Z :=
  ueq_scaled_velocity_frames 0 wing_cap_rollout_velocity_trace.

Definition held_a_jump_kick_qsteps : list float32 :=
  map ueq_half_f32 held_a_jump_kick_scaled_qsteps.

Definition b_rollout_qsteps : list float32 :=
  map ueq_half_f32 b_rollout_scaled_qsteps.

Definition wing_rollout_qsteps : list float32 :=
  map ueq_half_f32 wing_rollout_scaled_qsteps.

Fixpoint ueq_scaled_list_max (current : Z) (values : list Z) : Z :=
  match values with
  | [] => current
  | value :: rest => ueq_scaled_list_max (Z.max current value) rest
  end.

Definition ueq_all_at_or_below_cutoff (values : list float32) : bool :=
  forallb (fun value => Float32.cmp Cle value ueq_f32_cutoff) values.

Lemma ueq_scaled_quarter_positions_length :
  forall quarters relative_y velocity,
    length (ueq_scaled_quarter_positions quarters relative_y velocity) =
      quarters.
Proof.
  induction quarters as [|quarters IH]; intros relative_y velocity.
  - reflexivity.
  - cbn [ueq_scaled_quarter_positions length].
    rewrite IH. reflexivity.
Qed.

Lemma ueq_scaled_nonwing_frames_length :
  forall frames relative_y velocity,
    length (ueq_scaled_nonwing_frames frames relative_y velocity) =
      (4 * frames)%nat.
Proof.
  induction frames; intros; cbn [ueq_scaled_nonwing_frames].
  - reflexivity.
  - rewrite app_length, ueq_scaled_quarter_positions_length, IHframes. lia.
Qed.

Theorem held_a_jump_kick_executes_exactly_32_qsteps :
  length held_a_jump_kick_qsteps = 32%nat.
Proof.
  unfold held_a_jump_kick_qsteps, held_a_jump_kick_scaled_qsteps.
  rewrite map_length, ueq_scaled_nonwing_frames_length. reflexivity.
Qed.

Theorem b_rollout_executes_exactly_40_qsteps :
  length b_rollout_qsteps = 40%nat.
Proof.
  unfold b_rollout_qsteps, b_rollout_scaled_qsteps.
  rewrite map_length, ueq_scaled_nonwing_frames_length. reflexivity.
Qed.

Theorem held_a_jump_kick_qstep_max_is_134 :
  ueq_scaled_list_max 0 held_a_jump_kick_scaled_qsteps = 268 /\
  Float32.to_bits (ueq_half_f32 268) = Float32.to_bits (ueq_f32 134).
Proof. vm_compute. split; reflexivity. Qed.

Theorem b_rollout_qstep_max_is_224_point_5 :
  ueq_scaled_list_max 0 b_rollout_scaled_qsteps = 449 /\
  Float32.to_bits (ueq_half_f32 449) =
    Float32.to_bits (Float32.div (ueq_f32 449) (ueq_f32 2)).
Proof. vm_compute. split; reflexivity. Qed.

Theorem nonwing_candidate_qsteps_remain_below_wall_cutoff :
  ueq_all_at_or_below_cutoff held_a_jump_kick_qsteps = true /\
  ueq_all_at_or_below_cutoff b_rollout_qsteps = true.
Proof. vm_compute. split; reflexivity. Qed.

Inductive UpperElevatorNonwingCandidate : Type :=
| UEHeldAJumpKick
| UEBRollout.

Definition ueq_nonwing_candidate_qsteps
    (candidate : UpperElevatorNonwingCandidate) : list float32 :=
  match candidate with
  | UEHeldAJumpKick => held_a_jump_kick_qsteps
  | UEBRollout => b_rollout_qsteps
  end.

(** This is the pointwise form of the finite computation above: it applies to
    every one of the 72 modeled collision queries, rather than merely to each
    trajectory's maximum. *)
Theorem every_nonwing_candidate_qstep_is_at_or_below_wall_cutoff :
  forall candidate query,
    In query (ueq_nonwing_candidate_qsteps candidate) ->
    Float32.cmp Cle query ueq_f32_cutoff = true.
Proof.
  intros candidate query Hquery.
  destruct nonwing_candidate_qsteps_remain_below_wall_cutoff as
    [Hheld Hroll].
  unfold ueq_all_at_or_below_cutoff in Hheld, Hroll.
  rewrite forallb_forall in Hheld, Hroll.
  destruct candidate; cbn [ueq_nonwing_candidate_qsteps] in Hquery.
  - exact (Hheld query Hquery).
  - exact (Hroll query Hquery).
Qed.

Theorem every_candidate_scaled_transition_matches_float32 :
  forallb ueq_float32_transition_exact
    (ueq_scaled_nonwing_transitions
      8 0 held_a_jump_kick_initial_vy) = true /\
  forallb ueq_float32_transition_exact
    (ueq_scaled_nonwing_transitions 10 0 rollout_initial_vy) = true /\
  forallb ueq_float32_transition_exact
    (ueq_scaled_velocity_transitions
      0 wing_cap_rollout_velocity_trace) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The 45th zero-based sample is the first quarter-step of the final Wing
    frame.  The elevator has already descended ten units, so this query sees
    234 even though the frame returns to the 228 endpoint. *)
Lemma retained_wing_cap_scaled_query_is_468_half_units :
  nth_error wing_rollout_scaled_qsteps 44 = Some 468.
Proof. vm_compute. reflexivity. Qed.

Theorem retained_wing_cap_has_a_234_unit_transient_query :
  exists query,
    nth_error wing_rollout_qsteps 44 = Some query /\
    Float32.to_bits query = Float32.to_bits (ueq_f32 234) /\
    Float32.cmp Clt ueq_f32_cutoff query = true.
Proof.
  exists (ueq_half_f32 468).
  split.
  - unfold wing_rollout_qsteps.
    rewrite nth_error_map, retained_wing_cap_scaled_query_is_468_half_units.
    reflexivity.
  - split; vm_compute; reflexivity.
Qed.

Theorem wing_endpoint_228_does_not_bound_every_qstep :
  wing_cap_rollout_relative_rise = 228 /\
  exists query,
    In query wing_rollout_qsteps /\
    Float32.cmp Clt ueq_f32_cutoff query = true.
Proof.
  split; [exact wing_cap_rollout_relative_rise_is_228 |].
  destruct retained_wing_cap_has_a_234_unit_transient_query as
    [query [Hquery [_ Hcutoff]]].
  exists query. split.
  - apply nth_error_In with (n := 44%nat). exact Hquery.
  - exact Hcutoff.
Qed.

(** * Finite generated collision-result split *)

Definition ueq_known_air_result (result : option Z) : bool :=
  match result with
  | None => true
  | Some value => existsb (Z.eqb value) [0; 1; 2; 3; 4; 6]
  end.

Definition ueq_air_quarter_result_literals_checked : Prop :=
  forallb ueq_known_air_result
    (returned_int_literals_s (fn_body UEQ_UStep.f_perform_air_quarter_step)) =
      true /\
  forallb ueq_known_air_result
    (returned_int_literals_s (fn_body UEQ_JStep.f_perform_air_quarter_step)) =
      true.

Theorem ueq_air_quarter_result_literals_are_exhaustive :
  ueq_air_quarter_result_literals_checked.
Proof.
  unfold ueq_air_quarter_result_literals_checked, ueq_known_air_result.
  vm_compute. split; reflexivity.
Qed.

Inductive UpperElevatorAirResult : Z -> Prop :=
| UEAirNone : UpperElevatorAirResult 0
| UEAirLanded : UpperElevatorAirResult 1
| UEAirHitWall : UpperElevatorAirResult 2
| UEAirGrabbedLedge : UpperElevatorAirResult 3
| UEAirGrabbedCeiling : UpperElevatorAirResult 4
| UEAirHitLavaWall : UpperElevatorAirResult 6.

Lemma known_air_result_has_one_of_six_outcomes :
  forall result,
    In result [0; 1; 2; 3; 4; 6] ->
    UpperElevatorAirResult result.
Proof.
  intros result Hresult.
  repeat (destruct Hresult as [Hresult | Hresult];
    [subst; constructor |]); contradiction.
Qed.

Definition ueq_air_step_source_claim : Prop :=
  calls_ident_s UEQ_UStep._perform_air_quarter_step
    (fn_body UEQ_UStep.f_perform_air_step) = true /\
  calls_ident_s UEQ_JStep._perform_air_quarter_step
    (fn_body UEQ_JStep.f_perform_air_step) = true /\
  statement_mentions_int_s 4 (fn_body UEQ_UStep.f_perform_air_step) = true /\
  statement_mentions_int_s 4 (fn_body UEQ_JStep.f_perform_air_step) = true /\
  ident_subsequenceb
    [UEQ_UStep._perform_air_quarter_step; UEQ_UStep._apply_gravity;
     UEQ_UStep._apply_vertical_wind]
    (direct_callees_s (fn_body UEQ_UStep.f_perform_air_step)) = true /\
  ident_subsequenceb
    [UEQ_JStep._perform_air_quarter_step; UEQ_JStep._apply_gravity;
     UEQ_JStep._apply_vertical_wind]
    (direct_callees_s (fn_body UEQ_JStep.f_perform_air_step)) = true.

Theorem ueq_air_step_source_checked : ueq_air_step_source_claim.
Proof.
  unfold ueq_air_step_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** Both possible clean [init_mario] cap-flag assignments are non-Wing, and
    the timer assignment is exactly zero.  The generated program spells the
    second flag value as [1 | 16], rather than as a folded literal [17].  The
    universal check below classifies every direct assignment to each field,
    while the separate occurrence check prevents vacuous success.  This is
    still a source receipt: a live Area-2 entry trace must show that these
    values persist. *)
Definition ueq_rhs_is_safe_entry_flags (rhs : expr) : bool :=
  match rhs with
  | Econst_int found _ => Int.eq found (Int.repr 0)
  | Ebinop Oor (Econst_int left_value _) (Econst_int right_value _) _ =>
      Int.eq left_value (Int.repr 1) &&
      Int.eq right_value (Int.repr 16)
  | _ => false
  end.

Definition ueq_rhs_is_zero (rhs : expr) : bool :=
  match rhs with
  | Econst_int found _ => Int.eq found (Int.repr 0)
  | _ => false
  end.

Fixpoint ueq_field_assignments_satisfy_s
    (field : ident) (rhs_ok : expr -> bool) (s : statement) : bool :=
  match s with
  | Sassign lhs rhs =>
      if lhs_field_is field lhs then rhs_ok rhs else true
  | Ssequence first second | Sloop first second =>
      ueq_field_assignments_satisfy_s field rhs_ok first &&
      ueq_field_assignments_satisfy_s field rhs_ok second
  | Sifthenelse _ yes no =>
      ueq_field_assignments_satisfy_s field rhs_ok yes &&
      ueq_field_assignments_satisfy_s field rhs_ok no
  | Sswitch _ cases =>
      ueq_field_assignments_satisfy_ls field rhs_ok cases
  | Slabel _ body => ueq_field_assignments_satisfy_s field rhs_ok body
  | _ => true
  end
with ueq_field_assignments_satisfy_ls
    (field : ident) (rhs_ok : expr -> bool)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      ueq_field_assignments_satisfy_s field rhs_ok body &&
      ueq_field_assignments_satisfy_ls field rhs_ok rest
  end.

Definition ueq_entry_cap_reset_source_claim : Prop :=
  assigns_through_field_s UEQ_UMario._flags
    (fn_body UEQ_UMario.f_init_mario) = true /\
  ueq_field_assignments_satisfy_s UEQ_UMario._flags
    ueq_rhs_is_safe_entry_flags (fn_body UEQ_UMario.f_init_mario) = true /\
  assigns_through_field_s UEQ_UMario._capTimer
    (fn_body UEQ_UMario.f_init_mario) = true /\
  ueq_field_assignments_satisfy_s UEQ_UMario._capTimer
    ueq_rhs_is_zero (fn_body UEQ_UMario.f_init_mario) = true /\
  assigns_through_field_s UEQ_JMario._flags
    (fn_body UEQ_JMario.f_init_mario) = true /\
  ueq_field_assignments_satisfy_s UEQ_JMario._flags
    ueq_rhs_is_safe_entry_flags (fn_body UEQ_JMario.f_init_mario) = true /\
  assigns_through_field_s UEQ_JMario._capTimer
    (fn_body UEQ_JMario.f_init_mario) = true /\
  ueq_field_assignments_satisfy_s UEQ_JMario._capTimer
    ueq_rhs_is_zero (fn_body UEQ_JMario.f_init_mario) = true.

Theorem ueq_entry_cap_reset_source_checked :
  ueq_entry_cap_reset_source_claim.
Proof.
  unfold ueq_entry_cap_reset_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

Record UpperElevatorLiveCapState := {
  ueq_live_flags : Int.int;
  ueq_live_cap_timer : Int.int
}.

Definition ueq_wing_mask : Int.int := Int.repr 8.

Definition ueq_live_cap_is_nonwing
    (cap : UpperElevatorLiveCapState) : Prop :=
  Int.and (ueq_live_flags cap) ueq_wing_mask = Int.zero /\
  ueq_live_cap_timer cap = Int.zero.

Theorem clean_init_cap_values_are_nonwing :
  forall cap,
    (ueq_live_flags cap = Int.zero \/
     ueq_live_flags cap = Int.repr 17) ->
    ueq_live_cap_timer cap = Int.zero ->
    ueq_live_cap_is_nonwing cap.
Proof.
  intros cap Hflags Htimer.
  unfold ueq_live_cap_is_nonwing, ueq_wing_mask.
  split.
  - destruct Hflags as [Hflags | Hflags]; rewrite Hflags;
      vm_compute; reflexivity.
  - exact Htimer.
Qed.

(** A live execution certificate must supply these facts at the same descent,
    landing, and action run.  Unlike an opaque target-exclusion premise, each
    field names a concrete missing projection. *)
Record UpperElevatorLiveExecutionBoundary : Type := {
  ueq_live_initial_descent_and_floor_queries : Prop;
  ueq_live_elevator_selected_and_landed : Prop;
  ueq_live_each_qstep_uses_generated_float32_update : Prop;
  ueq_live_each_wall_floor_ceil_result_is_projected : Prop;
  ueq_live_each_action_transition_is_projected : Prop;
  ueq_live_cap_state : UpperElevatorLiveCapState;
  ueq_live_cap_state_is_nonwing : ueq_live_cap_is_nonwing ueq_live_cap_state
}.

Definition UpperElevatorQuarterStepCheckedBoundary : Prop :=
  length held_a_jump_kick_qsteps = 32%nat /\
  length b_rollout_qsteps = 40%nat /\
  ueq_all_at_or_below_cutoff held_a_jump_kick_qsteps = true /\
  ueq_all_at_or_below_cutoff b_rollout_qsteps = true /\
  (forall candidate query,
    In query (ueq_nonwing_candidate_qsteps candidate) ->
    Float32.cmp Cle query ueq_f32_cutoff = true) /\
  (forallb ueq_float32_transition_exact
      (ueq_scaled_nonwing_transitions
        8 0 held_a_jump_kick_initial_vy) = true /\
   forallb ueq_float32_transition_exact
      (ueq_scaled_nonwing_transitions 10 0 rollout_initial_vy) = true /\
   forallb ueq_float32_transition_exact
      (ueq_scaled_velocity_transitions
        0 wing_cap_rollout_velocity_trace) = true) /\
  (exists query,
    In query wing_rollout_qsteps /\
    Float32.cmp Clt ueq_f32_cutoff query = true) /\
  ueq_air_quarter_result_literals_checked /\
  ueq_air_step_source_claim /\
  ueq_entry_cap_reset_source_claim.

Theorem upper_elevator_quarter_step_checked_boundary_holds :
  UpperElevatorQuarterStepCheckedBoundary.
Proof.
  unfold UpperElevatorQuarterStepCheckedBoundary.
  split; [exact held_a_jump_kick_executes_exactly_32_qsteps |].
  split; [exact b_rollout_executes_exactly_40_qsteps |].
  destruct nonwing_candidate_qsteps_remain_below_wall_cutoff as [Hjump Hroll].
  split; [exact Hjump |]. split; [exact Hroll |].
  split; [exact every_nonwing_candidate_qstep_is_at_or_below_wall_cutoff |].
  split; [exact every_candidate_scaled_transition_matches_float32 |].
  split.
  - exact (proj2 wing_endpoint_228_does_not_bound_every_qstep).
  - split; [exact ueq_air_quarter_result_literals_are_exhaustive |].
    split; [exact ueq_air_step_source_checked |].
    exact ueq_entry_cap_reset_source_checked.
Qed.
