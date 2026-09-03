(** Finite original-JP receipt for Rank 10's B-only elevator rollout.

    A ROM-hash-gated, read-only Mupen debugger probe replays the established
    zero-A four-pillar route, enters SSL Area 2 through the upper warp, and
    continues with controller input only.  One continuous execution observes
    the initial fall, the live elevator floor, a speed-kick dive, its landing,
    a B-triggered forward rollout, the selected wall and the final landing.

    This module packages the exact receipt and combines it with the separately
    checked Float32 vertical envelope.  It does not turn one input schedule
    into a universal controller-history theorem, and it does not claim that an
    end-of-frame MarioState snapshot exposes every intermediate query call. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import Floats Integers.
From LessThanOneAPress.Proofs Require Import
  UpperElevatorQuarterStepClosure.

Import ListNotations.
Local Open Scope Z_scope.

Definition jp_rank10_first_timer : Z := 2831.
Definition jp_rank10_last_timer : Z := 3501.
Definition jp_rank10_area2_frames : Z := 671.

Definition jp_rank10_mario_object : Z := 2150881496. (* 0x8033d8d8 *)
Definition jp_rank10_state_mario_object : Z := 2150881496.
Definition jp_rank10_mario_slot : Z := 10.
Definition jp_rank10_elevator_object : Z := 2150886360. (* 0x8033ebd8 *)
Definition jp_rank10_elevator_candidates : Z := 1.

Definition jp_rank10_descent_relative_y : list Z :=
  [534; 530; 522; 510; 494; 474; 450; 422; 390;
   354; 314; 270; 222; 170; 114; 54; 0].
Definition jp_rank10_descent_start_action : Z := 6450. (* 0x00001932 *)
Definition jp_rank10_landing_action : Z := 4915. (* 0x00001333 *)
Definition jp_rank10_landing_timer : Z := 2847.
Definition jp_rank10_descent_mismatch_frames : Z := 0.

Definition jp_rank10_stage_timers : list Z :=
  [2863; 3017; 3021; 3144; 3148; 3198; 3214; 3235].
Definition jp_rank10_stage_actions : list Z :=
  [205521409; 67109952; 205521409; 67109952;
   205521409; 67109952; 8914006; 201327154].
Definition jp_rank10_dive_timer : Z := 3198.
Definition jp_rank10_rollout_input_timer : Z := 3214.
Definition jp_rank10_finished_stage : Z := 8.

Definition jp_rank10_controller_a_frames : Z := 0.
Definition jp_rank10_controller_b_frames : Z := 2.
Definition jp_rank10_a_pressed_frames : Z := 0.
Definition jp_rank10_a_down_frames : Z := 0.
Definition jp_rank10_nonwing_frames : Z := 671.

Definition jp_rank10_identity_mismatch_frames : Z := 0.
Definition jp_rank10_elevator_identity_failure_frames : Z := 0.
Definition jp_rank10_floor_owner_mismatch_frames : Z := 0.
Definition jp_rank10_elevator_floor_frames : Z := 671.

Definition jp_rank10_rollout_frames : Z := 20.
Definition jp_rank10_rollout_relative_y : list Z :=
  [40; 76; 108; 136; 160; 180; 196; 208; 216; 220;
   220; 216; 208; 196; 180; 160; 136; 108; 76; 40].
Definition jp_rank10_rollout_wall_stop_frames : Z := 20.
Definition jp_rank10_rollout_wall_frames : Z := 20.
Definition jp_rank10_rollout_elevator_wall_frames : Z := 20.
Definition jp_rank10_rollout_floor_owner_frames : Z := 20.
Definition jp_rank10_rollout_outside_inner_center_frames : Z := 0.
Definition jp_rank10_rollout_max_relative_y : Z := 220.
Definition jp_rank10_rollout_max_x : Z := 411.

Definition jp_rank10_first_wall : Z := 2149198928. (* 0x801a2c50 *)
Definition jp_rank10_first_wall_owner : Z := 2150886360.
Definition jp_rank10_first_wall_type : Z := 118.
Definition jp_rank10_first_wall_lower_y : Z := 1381.
Definition jp_rank10_first_wall_upper_y : Z := 1647.
Definition jp_rank10_first_wall_x : Z := 461.
Definition jp_rank10_first_wall_z_min : Z := -204.
Definition jp_rank10_first_wall_z_max : Z := 717.
Definition jp_rank10_first_wall_normal_x : Z := -1.
Definition jp_rank10_first_wall_normal_y : Z := 0.
Definition jp_rank10_first_wall_normal_z : Z := 0.

Record JPRank10BOnlyLiveReceipt : Prop := {
  jp_rank10_receipt_interval_exact :
    jp_rank10_last_timer - jp_rank10_first_timer + 1 =
      jp_rank10_area2_frames;
  jp_rank10_receipt_one_mario_and_elevator :
    jp_rank10_mario_object = jp_rank10_state_mario_object /\
    jp_rank10_mario_slot = 10 /\
    jp_rank10_elevator_candidates = 1 /\
    jp_rank10_identity_mismatch_frames = 0 /\
    jp_rank10_elevator_identity_failure_frames = 0;
  jp_rank10_receipt_exact_descent_and_landing :
    length jp_rank10_descent_relative_y = 17%nat /\
    hd 0 jp_rank10_descent_relative_y = 534 /\
    last jp_rank10_descent_relative_y 534 = 0 /\
    jp_rank10_landing_timer = jp_rank10_first_timer + 16 /\
    jp_rank10_descent_start_action = 6450 /\
    jp_rank10_landing_action = 4915 /\
    jp_rank10_descent_mismatch_frames = 0;
  jp_rank10_receipt_floor_and_cap_frames :
    jp_rank10_elevator_floor_frames = jp_rank10_area2_frames /\
    jp_rank10_floor_owner_mismatch_frames = 0 /\
    jp_rank10_nonwing_frames = jp_rank10_area2_frames;
  jp_rank10_receipt_controller_edges :
    jp_rank10_controller_a_frames = 0 /\
    jp_rank10_a_pressed_frames = 0 /\
    jp_rank10_a_down_frames = 0 /\
    jp_rank10_controller_b_frames = 2;
  jp_rank10_receipt_action_order :
    jp_rank10_stage_timers =
      [2863; 3017; 3021; 3144; 3148; 3198; 3214; 3235] /\
    jp_rank10_stage_actions =
      [205521409; 67109952; 205521409; 67109952;
       205521409; 67109952; 8914006; 201327154] /\
    jp_rank10_dive_timer < jp_rank10_rollout_input_timer /\
    jp_rank10_finished_stage = 8;
  jp_rank10_receipt_rollout_stays_in_cell :
    length jp_rank10_rollout_relative_y = 20%nat /\
    Forall (fun relative_y => relative_y <= 220)
      jp_rank10_rollout_relative_y /\
    jp_rank10_rollout_frames = 20 /\
    jp_rank10_rollout_max_relative_y = 220 /\
    jp_rank10_rollout_max_x = 411 /\
    jp_rank10_rollout_outside_inner_center_frames = 0;
  jp_rank10_receipt_live_wall_and_floor :
    jp_rank10_rollout_wall_stop_frames = jp_rank10_rollout_frames /\
    jp_rank10_rollout_wall_frames = jp_rank10_rollout_frames /\
    jp_rank10_rollout_elevator_wall_frames = jp_rank10_rollout_frames /\
    jp_rank10_rollout_floor_owner_frames = jp_rank10_rollout_frames /\
    jp_rank10_first_wall_owner = jp_rank10_elevator_object /\
    jp_rank10_first_wall_type = 118 /\
    jp_rank10_first_wall_x = 461 /\
    jp_rank10_first_wall_z_min = -204 /\
    jp_rank10_first_wall_z_max = 717 /\
    jp_rank10_first_wall_normal_x = -1 /\
    jp_rank10_first_wall_normal_y = 0 /\
    jp_rank10_first_wall_normal_z = 0
}.

Theorem jp_rank10_b_only_live_receipt_checked :
  JPRank10BOnlyLiveReceipt.
Proof.
  constructor; unfold jp_rank10_first_timer, jp_rank10_last_timer,
    jp_rank10_area2_frames, jp_rank10_mario_object,
    jp_rank10_state_mario_object, jp_rank10_mario_slot,
    jp_rank10_elevator_object, jp_rank10_elevator_candidates,
    jp_rank10_descent_relative_y, jp_rank10_descent_start_action,
    jp_rank10_landing_action, jp_rank10_landing_timer,
    jp_rank10_descent_mismatch_frames, jp_rank10_stage_timers,
    jp_rank10_stage_actions, jp_rank10_dive_timer,
    jp_rank10_rollout_input_timer, jp_rank10_finished_stage,
    jp_rank10_controller_a_frames, jp_rank10_controller_b_frames,
    jp_rank10_a_pressed_frames, jp_rank10_a_down_frames,
    jp_rank10_nonwing_frames, jp_rank10_identity_mismatch_frames,
    jp_rank10_elevator_identity_failure_frames,
    jp_rank10_floor_owner_mismatch_frames,
    jp_rank10_elevator_floor_frames, jp_rank10_rollout_frames,
    jp_rank10_rollout_relative_y, jp_rank10_rollout_wall_stop_frames,
    jp_rank10_rollout_wall_frames, jp_rank10_rollout_elevator_wall_frames,
    jp_rank10_rollout_floor_owner_frames,
    jp_rank10_rollout_outside_inner_center_frames,
    jp_rank10_rollout_max_relative_y, jp_rank10_rollout_max_x,
    jp_rank10_first_wall, jp_rank10_first_wall_owner,
    jp_rank10_first_wall_type, jp_rank10_first_wall_lower_y,
    jp_rank10_first_wall_upper_y, jp_rank10_first_wall_x,
    jp_rank10_first_wall_z_min, jp_rank10_first_wall_z_max,
    jp_rank10_first_wall_normal_x, jp_rank10_first_wall_normal_y,
    jp_rank10_first_wall_normal_z;
    cbn; repeat split; try reflexivity; repeat constructor; lia.
Qed.

(** This combines two independently checked facts without pretending that the
    machine receipt is itself a CompCert execution: the observed B-only run
    has the exact live identities above, and every point in the conservative
    full-return Float32 rollout envelope is at or below the 231-unit wall
    cutoff. *)
Definition JPRank10BOnlyLiveAndVerticalBoundary : Prop :=
  JPRank10BOnlyLiveReceipt /\
  forall query,
    In query b_rollout_full_return_qsteps ->
    Float32.cmp Cle query ueq_f32_cutoff = true.

Theorem jp_rank10_b_only_live_and_vertical_boundary_checked :
  JPRank10BOnlyLiveAndVerticalBoundary.
Proof.
  split.
  - exact jp_rank10_b_only_live_receipt_checked.
  - intros query Hquery.
    exact (every_full_return_candidate_qstep_is_at_or_below_wall_cutoff
      UEBRollout query Hquery).
Qed.
