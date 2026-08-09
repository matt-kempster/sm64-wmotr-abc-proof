(** The missing bridge from negative quicksand depth to Ink's timer-131
    platform sample.

    [Area1LongJumpQuicksandCrossing] identifies a static boundary candidate at
    raw X/Z = (5760, 4900).  [AutomaticDialogReanchoring] shows, at generated
    syntax and finite-model levels, how a surviving negative depth can raise
    Graphics Y during a stalled milestone dialog.  Neither fact moves the raw
    Mario object to the fixed upper pyramid warp at (-2048, -1024).

    This file proves that separation explicitly.  In the finite dialog model,
    any number of untransported stalls preserves State/Object X/Z at the
    ideal quicksand sample, whose exact horizontal squared distance from the
    upper warp is 96058640 (the overlap threshold is only 34969).  The later
    authenticated retail trace corrects the exact Z endpoint from 4900 to
    about 4899.19287; the stronger theorem below uses X=5760 alone, so that
    correction cannot change the separation.  Thus vertical amplification
    alone cannot start the timer-131 collision trace.

    It also checks the source shape of the first ordinary idle/walking paths:
    the stationary dispatcher reaches [mario_update_quicksand] before action
    dispatch, while idle and walking contain the usual Graphics reanchor
    helpers.  An exact binary32 mirror shows that either split-depth witness
    (-0.5f or -4.0f) is clamped and incremented to 1.6f on a shallow-moving-
    quicksand stationary update.  These are syntax and arithmetic facts, not
    a linked small-step proof that those branches execute.

    The surviving bridge therefore has to be made explicit: a raw-Object/XZ
    transport before the relevant collision, relocation/substitution of the
    warp, a collision-refinement failure, or a path that bypasses the ordinary
    reset/reanchor.  The final Definitions name the linked-memory obligations;
    no theorem here claims that the clean retail route is reachable or that
    the ultimate star theorem is complete. *)

From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Generated Require Import
  us_mario_actions_stationary us_mario_actions_moving
  jp_mario_actions_stationary jp_mario_actions_moving.
From LessThanOneAPress.Proofs Require Import
  ASTFacts PyramidTopPU Area1PlatformExhaustiveness
  Area1LongJumpQuicksandCrossing
  AutomaticDialogReanchoring JPLongJumpLandingDepth.

Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Float32.add Float32.cmp Float32.compare.

Module NDTB_USStationary := us_mario_actions_stationary.
Module NDTB_USMoving := us_mario_actions_moving.
Module NDTB_JPStationary := jp_mario_actions_stationary.
Module NDTB_JPMoving := jp_mario_actions_moving.

(** * The quicksand candidate and fixed upper warp are horizontally disjoint *)

Definition negative_depth_boundary_position (y : Z) : PositionZ :=
  {| position_x := 5760; position_y := y; position_z := 4900 |}.

Theorem negative_depth_boundary_exact_horizontal_distance :
  forall y,
    horizontal_distance_squared
      (negative_depth_boundary_position y) upper_warp_center = 96058640.
Proof.
  intros y.
  reflexivity.
Qed.

Theorem negative_depth_boundary_is_outside_fixed_upper_warp :
  forall y,
    ~ upper_warp_contact (negative_depth_boundary_position y).
Proof.
  intros y Hcontact.
  pose proof
    (upper_warp_contact_horizontal_bounds
      (negative_depth_boundary_position y) Hcontact) as Hbounds.
  cbn in Hbounds.
  lia.
Qed.

Theorem fixed_upper_warp_contact_requires_boundary_x_transport :
  forall position,
    upper_warp_contact position ->
    position_x position <> 5760.
Proof.
  intros position Hcontact Hequal.
  pose proof
    (upper_warp_contact_horizontal_bounds position Hcontact) as Hbounds.
  rewrite Hequal in Hbounds.
  lia.
Qed.

Theorem fixed_upper_warp_contact_requires_boundary_xz_transport :
  forall position,
    upper_warp_contact position ->
    position_x position <> 5760 \/ position_z position <> 4900.
Proof.
  intros position Hcontact.
  destruct (Z.eq_dec (position_x position) 5760) as [Hx | Hx];
    [| now left].
  destruct (Z.eq_dec (position_z position) 4900) as [Hz | Hz];
    [| now right].
  exfalso.
  pose proof
    (upper_warp_contact_horizontal_bounds position Hcontact) as Hbounds.
  rewrite Hx, Hz in Hbounds.
  lia.
Qed.

(** * A finite horizontal companion to the existing vertical dialog model *)

Record DialogHorizontalViews : Type := {
  dialog_state_x : Z;
  dialog_state_z : Z;
  dialog_object_x : Z;
  dialog_object_z : Z;
  dialog_graphics_x : Z;
  dialog_graphics_z : Z
}.

(** This is intentionally an *untransported* frame.  The handler and common
    sink do not move State X/Z; the final Mario-object copy synchronizes only
    the raw Object view to State.  Platform displacement, aliased writes, and
    other pre-handler transport are not built into this model. *)
Definition untransported_dialog_horizontal_frame
    (views : DialogHorizontalViews) : DialogHorizontalViews :=
  {| dialog_state_x := dialog_state_x views;
     dialog_state_z := dialog_state_z views;
     dialog_object_x := dialog_state_x views;
     dialog_object_z := dialog_state_z views;
     dialog_graphics_x := dialog_graphics_x views;
     dialog_graphics_z := dialog_graphics_z views |}.

Fixpoint repeat_untransported_dialog_horizontal
    (frames : nat) (views : DialogHorizontalViews) : DialogHorizontalViews :=
  match frames with
  | O => views
  | S rest =>
      repeat_untransported_dialog_horizontal rest
        (untransported_dialog_horizontal_frame views)
  end.

Definition boundary_dialog_horizontal_views : DialogHorizontalViews :=
  {| dialog_state_x := 5760;
     dialog_state_z := 4900;
     dialog_object_x := 5760;
     dialog_object_z := 4900;
     dialog_graphics_x := 5760;
     dialog_graphics_z := 4900 |}.

Theorem untransported_dialog_preserves_boundary_state_and_object_xz :
  forall frames,
    let final :=
      repeat_untransported_dialog_horizontal
        frames boundary_dialog_horizontal_views in
    dialog_state_x final = 5760 /\
    dialog_state_z final = 4900 /\
    dialog_object_x final = 5760 /\
    dialog_object_z final = 4900.
Proof.
  induction frames as [| frames IH].
  - cbn. repeat split; reflexivity.
  - cbn [repeat_untransported_dialog_horizontal].
    exact IH.
Qed.

Definition dialog_raw_object_position
    (y : Z) (views : DialogHorizontalViews) : PositionZ :=
  {| position_x := dialog_object_x views;
     position_y := y;
     position_z := dialog_object_z views |}.

Theorem vertical_dialog_amplification_does_not_supply_warp_xz :
  forall frames depth vertical_views raw_y,
    dialog_object_y vertical_views = dialog_state_y vertical_views ->
    dialog_gap (repeat_stalled_dialog frames depth vertical_views) =
      dialog_gap vertical_views - Z.of_nat frames * depth /\
    ~ upper_warp_contact
        (dialog_raw_object_position raw_y
          (repeat_untransported_dialog_horizontal
            frames boundary_dialog_horizontal_views)).
Proof.
  intros frames depth vertical_views raw_y Hsynchronized.
  split.
  - now apply repeat_stalled_dialog_exact_gap.
  - pose proof
      (untransported_dialog_preserves_boundary_state_and_object_xz frames)
      as (_ & _ & Hobject_x & Hobject_z).
    intro Hcontact.
    pose proof
      (fixed_upper_warp_contact_requires_boundary_x_transport
        (dialog_raw_object_position raw_y
          (repeat_untransported_dialog_horizontal
            frames boundary_dialog_horizontal_views)) Hcontact) as Htransport.
    change
      (dialog_object_x
         (repeat_untransported_dialog_horizontal
           frames boundary_dialog_horizontal_views) <> 5760) in Htransport.
    contradiction.
Qed.

(** * First ordinary stationary update: exact arithmetic and source shape *)

Definition ndtb_b32_one_point_one : float32 :=
  Float32.of_bits (Int.repr 1066192077).
Definition ndtb_b32_half : float32 :=
  Float32.of_bits (Int.repr 1056964608).
Definition ndtb_b32_twenty_five : float32 :=
  Float32.of_bits (Int.repr 1103626240).
Definition ndtb_b32_zero : float32 :=
  Float32.of_bits (Int.repr 0).

Definition ndtb_shallow_moving_stationary_update
    (before : float32) : float32 :=
  let clamped :=
    if Float32.cmp Clt before ndtb_b32_one_point_one
    then ndtb_b32_one_point_one
    else before in
  let increased := Float32.add clamped ndtb_b32_half in
  if Float32.cmp Clt increased ndtb_b32_twenty_five
  then increased
  else ndtb_b32_twenty_five.

Theorem split_negative_depths_become_positive_one_point_six :
  Float32.to_bits
    (ndtb_shallow_moving_stationary_update jp_timer_four_split_depth) =
      Int.repr 1070386381 /\
  Float32.to_bits
    (ndtb_shallow_moving_stationary_update jp_timer_five_split_depth) =
      Int.repr 1070386381 /\
  Float32.cmp Clt
    (ndtb_shallow_moving_stationary_update jp_timer_four_split_depth)
    ndtb_b32_zero = false /\
  Float32.cmp Clt
    (ndtb_shallow_moving_stationary_update jp_timer_five_split_depth)
    ndtb_b32_zero = false.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Generated-AST receipts for the ordinary post-dialog paths.  They are
    deliberately lexical: branch execution, one live Mario pointer, helper
    effects, and memory non-aliasing remain in the obligation below. *)
Definition post_dialog_idle_walk_source_shape_claim : Prop :=
  ident_subsequenceb
    [NDTB_USStationary._check_common_stationary_cancels;
     NDTB_USStationary._mario_update_quicksand]
    (direct_callees_s
      (fn_body NDTB_USStationary.f_mario_execute_stationary_action)) = true /\
  calls_ident_s NDTB_USStationary._stationary_ground_step
    (fn_body NDTB_USStationary.f_act_idle) = true /\
  calls_ident_s NDTB_USMoving._perform_ground_step
    (fn_body NDTB_USMoving.f_act_walking) = true /\
  ident_subsequenceb
    [NDTB_JPStationary._check_common_stationary_cancels;
     NDTB_JPStationary._mario_update_quicksand]
    (direct_callees_s
      (fn_body NDTB_JPStationary.f_mario_execute_stationary_action)) = true /\
  calls_ident_s NDTB_JPStationary._stationary_ground_step
    (fn_body NDTB_JPStationary.f_act_idle) = true /\
  calls_ident_s NDTB_JPMoving._perform_ground_step
    (fn_body NDTB_JPMoving.f_act_walking) = true.

Theorem post_dialog_idle_walk_source_shape_checked :
  post_dialog_idle_walk_source_shape_claim.
Proof.
  unfold post_dialog_idle_walk_source_shape_claim.
  vm_compute.
  repeat split.
Qed.

(** * Precisely scoped linked-retail obligations *)

(** Instantiate this with the linked US/JP small-step trace.  It must prove
    that a milestone-dialog completion at the boundary reaches the following
    collision pass with the same raw Object X/Z, before Mario's ordinary
    callback can run; or else identify the exact writer/transport that changes
    those coordinates. *)
Definition DialogCompletionCollisionOrderObligation
    {Frame : Type}
    (clean_zero_edge_dialog_completion : Frame -> Prop)
    (collision_uses_boundary_raw_object : Frame -> Prop)
    (precollision_raw_object_transport : Frame -> Prop) : Prop :=
  forall frame,
    clean_zero_edge_dialog_completion frame ->
    collision_uses_boundary_raw_object frame \/
    precollision_raw_object_transport frame.

(** Refine the arithmetic mirror and lexical call receipts above to one live
    MarioState cell.  The exceptional disjunct is intentional: water plunge,
    squish/death, an interaction-selected action, an alias/external write, or
    another same-frame control path must be classified rather than silently
    treated as ordinary idle/walking. *)
Definition PostDialogDepthResetAndReanchorObligation
    {Frame : Type}
    (clean_boundary_post_dialog_frame : Frame -> Prop)
    (ordinary_shallow_moving_reset_and_reanchor : Frame -> Prop)
    (classified_exceptional_action_or_writer : Frame -> Prop) : Prop :=
  forall frame,
    clean_boundary_post_dialog_frame frame ->
    ordinary_shallow_moving_reset_and_reanchor frame \/
    classified_exceptional_action_or_writer frame.

(** This is the exact remaining handoff into timer 131 after granting the
    quarter-step, action, star, and dialog premises.  For the fixed retail
    warp, [fixed_upper_warp_contact_requires_boundary_xz_transport] already
    proves that an unchanged boundary sample cannot suffice.  Linked retail
    execution must therefore produce and classify at least one escape. *)
Definition NegativeDepthDialogToTimer131TransportObligation
    {State : Type}
    (clean_zero_edge_negative_dialog_state : State -> Prop)
    (attempts_timer131_handoff : State -> Prop)
    (raw_object_xz_transport_before_warp_collision : State -> Prop)
    (upper_warp_relocated_or_substituted : State -> Prop)
    (object_collision_refinement_failed : State -> Prop)
    (ordinary_reset_or_reanchor_bypassed : State -> Prop) : Prop :=
  forall state,
    clean_zero_edge_negative_dialog_state state ->
    attempts_timer131_handoff state ->
    raw_object_xz_transport_before_warp_collision state \/
    upper_warp_relocated_or_substituted state \/
    object_collision_refinement_failed state \/
    ordinary_reset_or_reanchor_bypassed state.
