(** Rank 15: a controller-authentic local predecessor for riding an Eyerok
    hand's normal double-pound rise.

    The hash-gated US retail trace starts only after the probe has repeatedly
    placed Mario on a hand and the game itself reports that hand as both the
    selected floor owner and [gMarioPlatform].  At release the probe makes no
    Mario-state write: A has been held since Area 3 entry and the controller
    supplies one new B edge.  Retail code executes
    [ACT_IDLE -> ACT_PUNCHING -> ACT_JUMP_KICK] in one action-loop frame, then
    catches and rides all six positive hand steps.  This removes the injected
    action predecessor from the earlier local experiment.  It does not derive
    the staged boss/contact boundary from ordinary play, and the final hand
    height remains too low for the tunnel. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Clight Integers.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts InputSemantics.

Import ListNotations.
Local Open Scope Z_scope.

(** * Generated US/JP source receipt *)

Definition rank15_input_b_pressed_bits : Z := 8192.
Definition rank15_input_a_down_bits : Z := 128.
Definition rank15_act_idle_bits : Z := 205521409.
Definition rank15_act_punching_bits : Z := 8389504.

Definition EyerokRank15ControllerSourceShape : Prop :=
  statement_mentions_int_s rank15_input_b_pressed_bits
    (fn_body UStationary.f_check_common_idle_cancels) = true /\
  statement_mentions_int_s rank15_act_punching_bits
    (fn_body UStationary.f_check_common_idle_cancels) = true /\
  calls_ident_s UStationary._set_mario_action
    (fn_body UStationary.f_check_common_idle_cancels) = true /\
  statement_mentions_int_s rank15_input_a_down_bits
    (fn_body UObjectActions.f_act_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body UObjectActions.f_act_punching) = true /\
  calls_ident_s UObjectActions._set_mario_action
    (fn_body UObjectActions.f_act_punching) = true /\
  statement_contains_loop_s (fn_body UMI.f_execute_mario_action) = true /\
  calls_ident_s UMI._mario_execute_stationary_action
    (fn_body UMI.f_execute_mario_action) = true /\
  calls_ident_s UMI._mario_execute_object_action
    (fn_body UMI.f_execute_mario_action) = true /\
  statement_mentions_int_s rank15_input_b_pressed_bits
    (fn_body JStationary.f_check_common_idle_cancels) = true /\
  statement_mentions_int_s rank15_act_punching_bits
    (fn_body JStationary.f_check_common_idle_cancels) = true /\
  calls_ident_s JStationary._set_mario_action
    (fn_body JStationary.f_check_common_idle_cancels) = true /\
  statement_mentions_int_s rank15_input_a_down_bits
    (fn_body JObjectActions.f_act_punching) = true /\
  statement_mentions_int_s act_jump_kick_bits
    (fn_body JObjectActions.f_act_punching) = true /\
  calls_ident_s JObjectActions._set_mario_action
    (fn_body JObjectActions.f_act_punching) = true /\
  statement_contains_loop_s (fn_body JMI.f_execute_mario_action) = true /\
  calls_ident_s JMI._mario_execute_stationary_action
    (fn_body JMI.f_execute_mario_action) = true /\
  calls_ident_s JMI._mario_execute_object_action
    (fn_body JMI.f_execute_mario_action) = true.

Theorem eyerok_rank15_controller_source_shape_checked :
  EyerokRank15ControllerSourceShape.
Proof.
  unfold EyerokRank15ControllerSourceShape,
    rank15_input_b_pressed_bits, rank15_input_a_down_bits,
    rank15_act_punching_bits.
  vm_compute. repeat split.
Qed.

(** * Controller edge and local action chain *)

Definition rank15_controller_previous : Int.int := Int.repr 32768.
Definition rank15_controller_current : Int.int := Int.repr 49152.

Definition rank15_controller_frame : FrameInput :=
  {| frame_previous_down := rank15_controller_previous;
     frame_current_down := rank15_controller_current |}.

Definition b_button_pressed (current previous : Int.int) : bool :=
  Int.testbit (edge_pressed current previous) 14.

Theorem rank15_controller_frame_has_b_edge_but_no_a_edge :
  frame_has_no_a_press rank15_controller_frame /\
  a_button_down (frame_current_down rank15_controller_frame) = true /\
  b_button_pressed
    (frame_current_down rank15_controller_frame)
    (frame_previous_down rank15_controller_frame) = true.
Proof. vm_compute. repeat split. Qed.

Inductive rank15_local_action : Type :=
| Rank15Idle
| Rank15Punching
| Rank15JumpKick.

Record rank15_internal_input : Type := {
  rank15_a_pressed : bool;
  rank15_a_down : bool;
  rank15_b_pressed : bool
}.

Definition rank15_observed_release_input : rank15_internal_input :=
  {| rank15_a_pressed := false;
     rank15_a_down := true;
     rank15_b_pressed := true |}.

Definition rank15_idle_cancel (input : rank15_internal_input) :
    rank15_local_action :=
  if rank15_b_pressed input then Rank15Punching else Rank15Idle.

Definition rank15_punch_state_zero
    (input : rank15_internal_input) : rank15_local_action :=
  if rank15_a_down input then Rank15JumpKick else Rank15Punching.

(** This is the narrow source-shaped branch after all earlier idle/punch
    cancels have been checked false.  The generated-AST receipt above proves
    that both selected versions retain the constants, calls, and looping
    dispatch needed by this abstraction; it is not a Clight big-step proof. *)
Theorem rank15_observed_input_takes_same_frame_jump_kick_chain :
  rank15_a_pressed rank15_observed_release_input = false /\
  rank15_idle_cancel rank15_observed_release_input = Rank15Punching /\
  rank15_punch_state_zero rank15_observed_release_input = Rank15JumpKick.
Proof. repeat split; reflexivity. Qed.

(** * Hash-gated US retail trace receipt *)

Definition rank15_observed_internal_input_word : Z := 8352.
Definition rank15_observed_release_mario_writes : Z := 0.
Definition rank15_observed_hand_address : Z := 2150899848.
Definition rank15_observed_release_top_y : Z := -1228.
Definition rank15_observed_jump_kick_mario_y : Z := -1208.
Definition rank15_observed_jump_kick_velocity_y : Z := 16.
Definition rank15_observed_prelaunch_mario_y : Z := -1192.
Definition rank15_observed_prelaunch_velocity_y : Z := 12.
Definition rank15_observed_positive_hand_steps : list Z :=
  [85; 70; 55; 40; 25; 10].
Definition rank15_observed_highest_hand_top : Z := -943.
Definition rank15_tunnel_floor_query_min_y : Z := -640.
(** A historical counterfactual bookkeeping grant, not an executable stacking
    claim.  [EyerokRank15VSC] proves that jump-kick replaces stored vertical
    speed with 20 and therefore cannot add this 60-unit ascent to a conserved
    seed. *)
Definition rank15_granted_second_action_rise : Z := 60.

Record EyerokRank15USControllerTraceReceipt : Prop := {
  rank15_receipt_release_is_write_free_idle_contact :
    rank15_observed_release_mario_writes = 0 /\
    rank15_act_idle_bits = 205521409 /\
    rank15_observed_release_top_y = -1228 /\
    rank15_observed_hand_address = 2150899848;
  rank15_receipt_input_bits :
    Z.land rank15_observed_internal_input_word rank15_input_a_down_bits =
      rank15_input_a_down_bits /\
    Z.land rank15_observed_internal_input_word rank15_input_b_pressed_bits =
      rank15_input_b_pressed_bits /\
    Z.land rank15_observed_internal_input_word 2 = 0;
  rank15_receipt_retail_action_result :
    act_jump_kick_bits = 25168044 /\
    rank15_observed_jump_kick_mario_y = -1208 /\
    rank15_observed_jump_kick_velocity_y = 16 /\
    rank15_observed_prelaunch_mario_y = -1192 /\
    rank15_observed_prelaunch_velocity_y = 12;
  rank15_receipt_full_positive_ride :
    rank15_observed_positive_hand_steps = [85; 70; 55; 40; 25; 10] /\
    fold_right Z.add 0 rank15_observed_positive_hand_steps = 285 /\
    rank15_observed_release_top_y + 285 =
      rank15_observed_highest_hand_top;
  rank15_receipt_first_catch_gap :
    (rank15_observed_release_top_y + 85) -
      rank15_observed_prelaunch_mario_y = 49 /\
    49 <= 78;
  rank15_receipt_height_shortfalls :
    rank15_tunnel_floor_query_min_y - rank15_observed_highest_hand_top = 303 /\
    rank15_tunnel_floor_query_min_y -
      (rank15_observed_highest_hand_top + rank15_granted_second_action_rise) =
      243
}.

Theorem eyerok_rank15_us_controller_trace_receipt_checked :
  EyerokRank15USControllerTraceReceipt.
Proof.
  constructor.
  - repeat split; reflexivity.
  - vm_compute. repeat split.
  - repeat split; reflexivity.
  - repeat split; reflexivity.
  - repeat split; lia.
  - repeat split; lia.
Qed.

Definition EyerokRank15ControllerRideBoundary : Prop :=
  EyerokRank15ControllerSourceShape /\
  frame_has_no_a_press rank15_controller_frame /\
  b_button_pressed
    (frame_current_down rank15_controller_frame)
    (frame_previous_down rank15_controller_frame) = true /\
  rank15_idle_cancel rank15_observed_release_input = Rank15Punching /\
  rank15_punch_state_zero rank15_observed_release_input = Rank15JumpKick /\
  EyerokRank15USControllerTraceReceipt.

Theorem eyerok_rank15_controller_ride_boundary_holds :
  EyerokRank15ControllerRideBoundary.
Proof.
  unfold EyerokRank15ControllerRideBoundary.
  destruct rank15_controller_frame_has_b_edge_but_no_a_edge as
    [Hnoa [_ Hb]].
  destruct rank15_observed_input_takes_same_frame_jump_kick_chain as
    [_ [Hpunch Hkick]].
  refine (conj eyerok_rank15_controller_source_shape_checked _).
  refine (conj Hnoa _).
  refine (conj Hb _).
  refine (conj Hpunch _).
  refine (conj Hkick _).
  exact eyerok_rank15_us_controller_trace_receipt_checked.
Qed.
