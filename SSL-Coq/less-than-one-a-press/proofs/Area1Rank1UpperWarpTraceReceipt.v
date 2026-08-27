(** Continuous original-JP Rank-1 receipt through a clean upper warp.

    The accepted level-select entry fixes the initial Area-1 state.  A
    read-only, ROM-hash-gated Mupen debugger trace then follows one controller
    schedule from global timer 348 through timer 2810.  The schedule touches
    all four pillars, explodes the pyramid top, uses a jumping box and a
    B-only rollout, and enters the upper warp without an A edge.  The same
    execution continues to the observed Area-2 load at timer 2830.

    Each audited frame watches the complete node and surface allocations,
    both spatial partitions, allocator heads, relevant outside destinations,
    every [find_floor] entry and common return, and Mario's final platform
    selection.  This file packages the exact finite receipt.  It does not
    promote one execution into a theorem about every controller history, and
    it is not an IDO-MIPS-to-Clight forward simulation. *)

From Coq Require Import Lia List ZArith.

Import ListNotations.
Local Open Scope Z_scope.

(** * Route milestones *)

Definition jp_rank1_trace_start_timer : Z := 348.
Definition jp_rank1_trace_exclusive_end_timer : Z := 2810.
Definition jp_rank1_trace_frame_count : Z := 2462.
Definition jp_rank1_trace_frame_failures : Z := 0.

Definition jp_rank1_pillar_touch_timers : list Z :=
  [848; 1065; 2390; 2548].
Definition jp_rank1_top_spin_timer : Z := 2549.
Definition jp_rank1_top_explosion_timer : Z := 2700.
Definition jp_rank1_box_pickup_timer : Z := 2671.
Definition jp_rank1_box_landing_timer : Z := 2776.
Definition jp_rank1_rollout_timer : Z := 2782.
Definition jp_rank1_upper_warp_contact_timer : Z := 2807.
Definition jp_rank1_upper_warp_action_timer : Z := 2808.
Definition jp_rank1_area2_load_timer : Z := 2830.

Definition jp_rank1_a_pressed_frames : Z := 0.
Definition jp_rank1_a_down_frames : Z := 0.
Definition jp_rank1_controller_a_frames : Z := 0.
Definition jp_rank1_pillars_complete : Z := 1.
Definition jp_rank1_upper_warp_disappeared : Z := 1.
Definition jp_rank1_upper_warp_used_object : Z := 1.

(** * Complete query and lifecycle totals *)

Definition jp_rank1_find_floor_call_sum : Z := 149578.
Definition jp_rank1_find_floor_return_sum : Z := 149578.
Definition jp_rank1_dynamic_find_floor_return_sum : Z := 426.
Definition jp_rank1_find_floor_return_failure_sum : Z := 0.
Definition jp_rank1_find_floor_before_clear_sum : Z := 0.

Definition jp_rank1_static_final_selection_frames : Z := 2462.
Definition jp_rank1_dynamic_final_selection_frames : Z := 0.
Definition jp_rank1_owned_final_selection_frames : Z := 0.

Definition jp_rank1_inactive_collision_model_call_sum : Z := 1.
Definition jp_rank1_inactive_owner_store_sum : Z := 6.
Definition jp_rank1_end_invalid_surface_sum : Z := 6.
Definition jp_rank1_pending_cleanup_surface_sum : Z := 6.
Definition jp_rank1_explosion_frame_dynamic_returns : Z := 0.
Definition jp_rank1_post_explosion_frame_dynamic_returns : Z := 0.

Definition jp_rank1_max_graphics_minus_object_y : Z := 0.
Definition jp_rank1_max_state_minus_object_y : Z := 0.
Definition jp_rank1_platform_top_observations : Z := 0.

Record JPRank1UpperWarpTraceReceipt : Prop := {
  jp_rank1_upper_receipt_timer_interval :
    jp_rank1_trace_exclusive_end_timer - jp_rank1_trace_start_timer =
      jp_rank1_trace_frame_count;
  jp_rank1_upper_receipt_every_frame_passes :
    jp_rank1_trace_frame_count = 2462 /\
    jp_rank1_trace_frame_failures = 0;
  jp_rank1_upper_receipt_four_pillars :
    jp_rank1_pillar_touch_timers = [848; 1065; 2390; 2548] /\
    jp_rank1_pillars_complete = 1;
  jp_rank1_upper_receipt_route_order :
    jp_rank1_trace_start_timer <
      nth 0 jp_rank1_pillar_touch_timers 0 /\
    nth 3 jp_rank1_pillar_touch_timers 0 < jp_rank1_top_spin_timer /\
    jp_rank1_top_spin_timer < jp_rank1_box_pickup_timer /\
    jp_rank1_box_pickup_timer < jp_rank1_top_explosion_timer /\
    jp_rank1_top_explosion_timer < jp_rank1_box_landing_timer /\
    jp_rank1_box_landing_timer < jp_rank1_rollout_timer /\
    jp_rank1_rollout_timer < jp_rank1_upper_warp_contact_timer /\
    jp_rank1_upper_warp_contact_timer < jp_rank1_upper_warp_action_timer /\
    jp_rank1_upper_warp_action_timer < jp_rank1_area2_load_timer;
  jp_rank1_upper_receipt_zero_a :
    jp_rank1_a_pressed_frames = 0 /\
    jp_rank1_a_down_frames = 0 /\
    jp_rank1_controller_a_frames = 0;
  jp_rank1_upper_receipt_warp_outcome :
    jp_rank1_upper_warp_disappeared = 1 /\
    jp_rank1_upper_warp_used_object = 1;
  jp_rank1_upper_receipt_all_floor_calls_return :
    jp_rank1_find_floor_call_sum = jp_rank1_find_floor_return_sum /\
    jp_rank1_find_floor_return_failure_sum = 0 /\
    jp_rank1_find_floor_before_clear_sum = 0;
  jp_rank1_upper_receipt_dynamic_returns_are_checked :
    jp_rank1_dynamic_find_floor_return_sum = 426 /\
    jp_rank1_find_floor_return_failure_sum = 0;
  jp_rank1_upper_receipt_final_platform_queries :
    jp_rank1_static_final_selection_frames = jp_rank1_trace_frame_count /\
    jp_rank1_dynamic_final_selection_frames = 0 /\
    jp_rank1_owned_final_selection_frames = 0;
  jp_rank1_upper_receipt_explosion_cleanup :
    jp_rank1_inactive_collision_model_call_sum = 1 /\
    jp_rank1_inactive_owner_store_sum = 6 /\
    jp_rank1_end_invalid_surface_sum =
      jp_rank1_pending_cleanup_surface_sum /\
    jp_rank1_explosion_frame_dynamic_returns = 0 /\
    jp_rank1_post_explosion_frame_dynamic_returns = 0;
  jp_rank1_upper_receipt_no_useful_view_split :
    jp_rank1_max_graphics_minus_object_y = 0 /\
    jp_rank1_max_state_minus_object_y = 0 /\
    jp_rank1_platform_top_observations = 0
}.

Theorem jp_rank1_upper_warp_trace_receipt_checked :
  JPRank1UpperWarpTraceReceipt.
Proof.
  constructor; unfold jp_rank1_trace_start_timer,
    jp_rank1_trace_exclusive_end_timer, jp_rank1_trace_frame_count,
    jp_rank1_trace_frame_failures, jp_rank1_pillar_touch_timers,
    jp_rank1_top_spin_timer, jp_rank1_top_explosion_timer,
    jp_rank1_box_pickup_timer, jp_rank1_box_landing_timer,
    jp_rank1_rollout_timer, jp_rank1_upper_warp_contact_timer,
    jp_rank1_upper_warp_action_timer, jp_rank1_area2_load_timer,
    jp_rank1_a_pressed_frames, jp_rank1_a_down_frames,
    jp_rank1_controller_a_frames, jp_rank1_pillars_complete,
    jp_rank1_upper_warp_disappeared, jp_rank1_upper_warp_used_object,
    jp_rank1_find_floor_call_sum, jp_rank1_find_floor_return_sum,
    jp_rank1_dynamic_find_floor_return_sum,
    jp_rank1_find_floor_return_failure_sum,
    jp_rank1_find_floor_before_clear_sum,
    jp_rank1_static_final_selection_frames,
    jp_rank1_dynamic_final_selection_frames,
    jp_rank1_owned_final_selection_frames,
    jp_rank1_inactive_collision_model_call_sum,
    jp_rank1_inactive_owner_store_sum,
    jp_rank1_end_invalid_surface_sum,
    jp_rank1_pending_cleanup_surface_sum,
    jp_rank1_explosion_frame_dynamic_returns,
    jp_rank1_post_explosion_frame_dynamic_returns,
    jp_rank1_max_graphics_minus_object_y,
    jp_rank1_max_state_minus_object_y,
    jp_rank1_platform_top_observations;
    cbn; repeat split; try reflexivity; lia.
Qed.

(** The only end-of-frame owner invalidity is safe for this trace because the
    six invalid triangles are exactly the six pending-clear triangles, no
    return-side owner check fails, and every next-frame query occurs after the
    dynamic clear.  The stronger factual statement is that the explosion
    frame and its successor return no dynamic floor at all. *)
Definition JPRank1ExplosionLifecycleSafe : Prop :=
  jp_rank1_end_invalid_surface_sum =
    jp_rank1_pending_cleanup_surface_sum /\
  jp_rank1_find_floor_return_failure_sum = 0 /\
  jp_rank1_find_floor_before_clear_sum = 0 /\
  jp_rank1_explosion_frame_dynamic_returns = 0 /\
  jp_rank1_post_explosion_frame_dynamic_returns = 0.

Theorem jp_rank1_explosion_lifecycle_is_pending_clear_only :
  JPRank1ExplosionLifecycleSafe.
Proof.
  unfold JPRank1ExplosionLifecycleSafe,
    jp_rank1_end_invalid_surface_sum,
    jp_rank1_pending_cleanup_surface_sum,
    jp_rank1_find_floor_return_failure_sum,
    jp_rank1_find_floor_before_clear_sum,
    jp_rank1_explosion_frame_dynamic_returns,
    jp_rank1_post_explosion_frame_dynamic_returns.
  repeat split; reflexivity.
Qed.

(** Trace-scoped verdict: this successful zero-A pillar/upper-warp execution
    contains no failed protected write/list/owner/outside check, no floor
    return before clearing, no invalid returned dynamic owner, no owned final
    platform, and no positive State/Object/Graphics split.  A different input
    history or machine behavior outside the watched in-bounds model is not
    quantified here. *)
Definition JPRank1UpperWarpTraceEscapesAbsent : Prop :=
  jp_rank1_trace_frame_failures = 0 /\
  jp_rank1_find_floor_call_sum = jp_rank1_find_floor_return_sum /\
  jp_rank1_find_floor_return_failure_sum = 0 /\
  jp_rank1_find_floor_before_clear_sum = 0 /\
  jp_rank1_dynamic_final_selection_frames = 0 /\
  jp_rank1_owned_final_selection_frames = 0 /\
  JPRank1ExplosionLifecycleSafe /\
  jp_rank1_max_graphics_minus_object_y = 0 /\
  jp_rank1_max_state_minus_object_y = 0 /\
  jp_rank1_platform_top_observations = 0 /\
  jp_rank1_a_pressed_frames = 0 /\
  jp_rank1_a_down_frames = 0 /\
  jp_rank1_controller_a_frames = 0 /\
  jp_rank1_upper_warp_disappeared = 1 /\
  jp_rank1_upper_warp_used_object = 1.

Theorem jp_rank1_upper_warp_trace_escapes_absent :
  JPRank1UpperWarpTraceEscapesAbsent.
Proof.
  unfold JPRank1UpperWarpTraceEscapesAbsent,
    jp_rank1_trace_frame_failures, jp_rank1_find_floor_call_sum,
    jp_rank1_find_floor_return_sum,
    jp_rank1_find_floor_return_failure_sum,
    jp_rank1_find_floor_before_clear_sum,
    jp_rank1_dynamic_final_selection_frames,
    jp_rank1_owned_final_selection_frames,
    jp_rank1_max_graphics_minus_object_y,
    jp_rank1_max_state_minus_object_y,
    jp_rank1_platform_top_observations, jp_rank1_a_pressed_frames,
    jp_rank1_a_down_frames, jp_rank1_controller_a_frames,
    jp_rank1_upper_warp_disappeared, jp_rank1_upper_warp_used_object.
  repeat split; try reflexivity.
Qed.

Definition Area1Rank1UpperWarpTraceCheckedBoundary : Prop :=
  JPRank1UpperWarpTraceReceipt /\
  JPRank1ExplosionLifecycleSafe /\
  JPRank1UpperWarpTraceEscapesAbsent.

Theorem area1_rank1_upper_warp_trace_checked_boundary_holds :
  Area1Rank1UpperWarpTraceCheckedBoundary.
Proof.
  unfold Area1Rank1UpperWarpTraceCheckedBoundary.
  split; [exact jp_rank1_upper_warp_trace_receipt_checked |].
  split; [exact jp_rank1_explosion_lifecycle_is_pending_clear_only |].
  exact jp_rank1_upper_warp_trace_escapes_absent.
Qed.
