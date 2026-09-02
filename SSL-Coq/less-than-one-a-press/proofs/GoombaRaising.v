From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

(** * A bounded model of the Goomba-raising observation

    This file separates two claims which are easy to conflate.

    First, the regular-Goomba state machine has a conditional productive
    three-frame cycle.  In the selected branch without a fresh walk-action
    jump, a grounded priming sequence precedes the repeatable airborne jump
    action 2 state with vertical velocity [25.0f].  If Mario can alternate
    between collision range and a full
    three-dimensional distance greater than [4000.0f] at the required frame
    phases, then gravity leaves velocity [21.0f] and movement updates position
    with binary32 [Y + 21.0f].  The repeating action sequence is:

    - H (hit/depart): consume the cached interaction, apply gravity, update Y
      by binary32 addition of [25 + (-4) = 21], and finish far away;
    - F (far reset): execute the attacked action while movement is suppressed,
      thereby reset vertical velocity to [25], and remain far away;
    - R (near rearm): remain in jump action while movement is still
      suppressed, clear the far-away flag, and finish in position for the next
      frame's collision pass.

    Second, the source state machine does not provide the full-coordinate
    shuttle, Parallel-Universe transport, moving-collision capture, or route
    handoff needed to realize those premises in retail SSL.  The final section
    gives concrete obligation schemas for those missing execution witnesses.
    No theorem in the proved arithmetic boundary consumes an inhabitant of
    any of those schemas.

    The constants mirrored here come from:

    - [src/game/behaviors/goomba.inc.c] (regular scale [1.5f], jump
      [50/3 * scale], gravity [-8/3 * scale], action updates, hitbox);
    - [src/game/object_helpers.c] ([dist_between_objects] and suppression in
      [cur_obj_move_standard]);
    - [src/engine/behavior_script.c] (the drawing-distance far-away flag);
    - [src/game/object_collision.c] (strict horizontal and inclusive vertical
      hitbox tests);
    - [data/behavior_data.c] (Mario radius [37], normal height [160]).

    The transition functions below are deliberately conditional mirrors, not
    hand-written replacements for those C functions.  Their retail premises
    must eventually be discharged by linked Clight executions. *)

(** ** Exact constants *)

Definition goomba_jump_velocity_z : Z := 25.
Definition goomba_gravity_z : Z := -4.
Definition goomba_productive_rise_z : Z := 21.
Definition goomba_ground_bounce_velocity_z : Z := 2.

Definition regular_goomba_radius_z : Z := 108.
Definition regular_goomba_height_z : Z := 75.
Definition normal_mario_radius_z : Z := 37.
Definition normal_mario_height_z : Z := 160.
Definition regular_goomba_mario_radius_sum_z : Z := 145.

Definition goomba_far_distance_z : Z := 4000.
Definition moving_collision_load_distance_z : Z := 1000.
Definition parallel_universe_period_z : Z := 65536.

Definition goomba_f32_2 : float32 :=
  Float32.of_bits (Int.repr 1073741824).
Definition goomba_f32_21 : float32 :=
  Float32.of_bits (Int.repr 1101529088).
Definition goomba_f32_25 : float32 :=
  Float32.of_bits (Int.repr 1103626240).
Definition goomba_f32_neg4 : float32 :=
  Float32.of_bits (Int.repr 3229614080).
Definition goomba_f32_1000 : float32 :=
  Float32.of_bits (Int.repr 1148846080).
Definition goomba_f32_4000 : float32 :=
  Float32.of_bits (Int.repr 1165623296).
Definition goomba_f32_65536 : float32 :=
  Float32.of_bits (Int.repr 1199570944).
Definition goomba_f32_2p29 : float32 :=
  Float32.of_bits (Int.repr 1308622848).

Theorem regular_goomba_scaled_hitbox_checked :
  regular_goomba_radius_z = 72 * 3 / 2 /\
  regular_goomba_height_z = 50 * 3 / 2 /\
  regular_goomba_mario_radius_sum_z =
    regular_goomba_radius_z + normal_mario_radius_z.
Proof.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** This is an executable CompCert binary32 velocity-update fact, not a
    real-number substitution or a general theorem about adding [21.0f] to an
    arbitrary stored Y coordinate. *)
Theorem goomba_velocity_after_gravity_binary32_checked :
  Float32.to_bits
    (Float32.add goomba_f32_25 goomba_f32_neg4) =
      Int.repr 1101529088.
Proof.
  vm_compute.
  reflexivity.
Qed.

(** Consequently, literal unbounded raising is false.  At [2^29], the
    binary32 unit in the last place is [64], so adding [21.0f] rounds back to
    the same value.  This does not obstruct any SSL-relevant height. *)
Theorem goomba_binary32_raising_stagnates_at_2p29 :
  Float32.to_bits
    (Float32.add goomba_f32_2p29 goomba_f32_21) =
      Int.repr 1308622848.
Proof.
  vm_compute.
  reflexivity.
Qed.

Definition goomba_f32_nonintegral_y_witness : float32 :=
  Float32.of_bits (Int.repr 1157455875).

(** A concrete in-band counterexample to the stronger claim that every
    position update changes the stored Y by exactly [21.0f]. *)
Definition goomba_position_rounding_counterexample_claim : Prop :=
  Float32.to_bits
    (Float32.add goomba_f32_nonintegral_y_witness goomba_f32_21) =
      Int.repr 1157627906 /\
  Float32.to_bits
    (Float32.sub
      (Float32.add goomba_f32_nonintegral_y_witness goomba_f32_21)
      goomba_f32_nonintegral_y_witness) =
      Int.repr 1101529152 /\
  Int.repr 1101529152 <> Float32.to_bits goomba_f32_21.

Theorem goomba_position_delta_need_not_be_exact_21 :
  goomba_position_rounding_counterexample_claim.
Proof.
  unfold goomba_position_rounding_counterexample_claim.
  vm_compute.
  repeat split; congruence.
Qed.

Fixpoint iterate_goomba_float32_rises
    (cycles : nat) (y : float32) : float32 :=
  match cycles with
  | O => y
  | S remaining =>
      Float32.add
        (iterate_goomba_float32_rises remaining y)
        goomba_f32_21
  end.

(** The low, integer-aligned Area-1 values used by the finite top-window
    arithmetic do happen to remain exact.  These concrete computations avoid
    generalizing that fact to arbitrary binary32 Y values. *)
Theorem pyramid_top_y51_after_31_float32_rises_checked :
  Float32.to_bits
    (iterate_goomba_float32_rises 31
      (Float32.of_int (Int.repr 51))) =
  Float32.to_bits (Float32.of_int (Int.repr 702)).
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem pyramid_top_y51_after_83_float32_rises_checked :
  Float32.to_bits
    (iterate_goomba_float32_rises 83
      (Float32.of_int (Int.repr 51))) =
  Float32.to_bits (Float32.of_int (Int.repr 1794)).
Proof.
  vm_compute.
  reflexivity.
Qed.

(** ** Explicit H/F/R state machine *)

Inductive GoombaRaisePhase : Type :=
| GoombaRaiseFirstReadyWalk
| GoombaRaiseCycleReadyJump
| GoombaRaiseAttackedFar
| GoombaRaiseJumpFar.

Record GoombaRaiseState : Type := {
  goomba_raise_phase : GoombaRaisePhase;
  goomba_raise_y : Z;
  goomba_raise_vel_y : Z;
  goomba_raise_far_away : bool;
  goomba_raise_on_ground : bool
}.

Definition goomba_ready_at (y : Z) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseCycleReadyJump;
  goomba_raise_y := y;
  goomba_raise_vel_y := goomba_jump_velocity_z;
  goomba_raise_far_away := false;
  goomba_raise_on_ground := false
|}.

Definition goomba_first_ready_walk_at (y : Z) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseFirstReadyWalk;
  goomba_raise_y := y;
  goomba_raise_vel_y := goomba_jump_velocity_z;
  goomba_raise_far_away := false;
  goomba_raise_on_ground := true
|}.

Definition goomba_unprimed_grounded_at (y : Z) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseFirstReadyWalk;
  goomba_raise_y := y;
  goomba_raise_vel_y := 0;
  goomba_raise_far_away := false;
  goomba_raise_on_ground := true
|}.

(** H: this function represents only the productive, already-armed case. *)
Definition goomba_hit_depart
    (state : GoombaRaiseState) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseAttackedFar;
  goomba_raise_y :=
    goomba_raise_y state + goomba_productive_rise_z;
  goomba_raise_vel_y := goomba_productive_rise_z;
  goomba_raise_far_away := true;
  goomba_raise_on_ground := false
|}.

(** F: [goomba_begin_jump] writes [25.0f], but the old far-away flag
    suppresses [cur_obj_move_standard]. *)
Definition goomba_far_reset
    (state : GoombaRaiseState) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseJumpFar;
  goomba_raise_y := goomba_raise_y state;
  goomba_raise_vel_y := goomba_jump_velocity_z;
  goomba_raise_far_away := true;
  goomba_raise_on_ground := goomba_raise_on_ground state
|}.

(** Repeating R: after a productive H, the retained movement flags are
    airborne.  Jump action therefore remains action 2 while movement is
    suppressed, and the end-of-update distance test clears the far-away flag.
    Collision detection can cache the next H on the following frame. *)
Definition goomba_near_rearm
    (state : GoombaRaiseState) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseCycleReadyJump;
  goomba_raise_y := goomba_raise_y state;
  goomba_raise_vel_y := goomba_raise_vel_y state;
  goomba_raise_far_away := false;
  goomba_raise_on_ground := goomba_raise_on_ground state
|}.

Definition goomba_productive_cycle
    (state : GoombaRaiseState) : GoombaRaiseState :=
  goomba_near_rearm
    (goomba_far_reset
      (goomba_hit_depart state)).

Theorem goomba_hfr_productive_cycle :
  forall y,
    goomba_productive_cycle (goomba_ready_at y) =
      goomba_ready_at (y + goomba_productive_rise_z).
Proof.
  intros y.
  reflexivity.
Qed.

(** This selected grounded branch assumes walk action did not first choose a
    notice/random jump.  Starting with velocity zero, gravity takes velocity to
    [-4], floor collision preserves the floor height, and regular bounciness
    [-0.5] leaves velocity [2].  The following F/R pair arms the first
    productive H.  Other walk-action branches may already write velocity 25
    before attack handling and are not represented by this definition. *)
Definition goomba_priming_hit_depart
    (state : GoombaRaiseState) : GoombaRaiseState := {|
  goomba_raise_phase := GoombaRaiseAttackedFar;
  goomba_raise_y := goomba_raise_y state;
  goomba_raise_vel_y := goomba_ground_bounce_velocity_z;
  goomba_raise_far_away := true;
  goomba_raise_on_ground := true
|}.

Definition goomba_prime_and_rearm
    (state : GoombaRaiseState) : GoombaRaiseState :=
  let reset := goomba_far_reset (goomba_priming_hit_depart state) in
  {| goomba_raise_phase := GoombaRaiseFirstReadyWalk;
     goomba_raise_y := goomba_raise_y reset;
     goomba_raise_vel_y := goomba_raise_vel_y reset;
     goomba_raise_far_away := false;
     goomba_raise_on_ground := true |}.

Theorem selected_grounded_hit_branch_primes_without_raising :
  forall y,
    goomba_priming_hit_depart (goomba_unprimed_grounded_at y) = {|
      goomba_raise_phase := GoombaRaiseAttackedFar;
      goomba_raise_y := y;
      goomba_raise_vel_y := goomba_ground_bounce_velocity_z;
      goomba_raise_far_away := true;
      goomba_raise_on_ground := true
    |}.
Proof.
  intros y.
  reflexivity.
Qed.

Theorem selected_priming_far_reset_and_rearm_produce_ready_state :
  forall y,
    goomba_prime_and_rearm (goomba_unprimed_grounded_at y) =
      goomba_first_ready_walk_at y.
Proof.
  intros y.
  reflexivity.
Qed.

(** The first productive H may start from the primed walk action, conditional
    on that action not selecting a fresh random/notice jump before attacks are
    handled.  Its R endpoint is already the repeating airborne action-2
    state. *)
Theorem first_productive_cycle_enters_repeating_ready_state :
  forall y,
    goomba_productive_cycle (goomba_first_ready_walk_at y) =
      goomba_ready_at (y + goomba_productive_rise_z).
Proof.
  intros y.
  reflexivity.
Qed.

Fixpoint iterate_goomba_productive_cycles
    (cycles : nat) (state : GoombaRaiseState) : GoombaRaiseState :=
  match cycles with
  | O => state
  | S remaining =>
      goomba_productive_cycle
        (iterate_goomba_productive_cycles remaining state)
  end.

Theorem finite_goomba_productive_cycles :
  forall cycles y,
    iterate_goomba_productive_cycles cycles (goomba_ready_at y) =
      goomba_ready_at
        (y + goomba_productive_rise_z * Z.of_nat cycles).
Proof.
  induction cycles as [| cycles IH]; intros y.
  - change (goomba_ready_at y = goomba_ready_at (y + 21 * 0)).
    replace (y + 21 * 0) with y by lia.
    reflexivity.
  - simpl.
    rewrite IH.
    rewrite goomba_hfr_productive_cycle.
    apply f_equal.
    unfold goomba_productive_rise_z.
    lia.
Qed.

(** ** Collision-height bounds for the proposed Spindel handoff *)

Definition regular_goomba_vertical_overlap
    (mario_y goomba_y : Z) : Prop :=
  mario_y - regular_goomba_height_z <= goomba_y /\
  goomba_y <= mario_y + normal_mario_height_z.

Definition spindel_capture_mario_y_min : Z := 2036.
Definition spindel_capture_mario_y_max : Z := 2336.
Definition spindel_capture_goomba_y_min : Z := 1961.
Definition spindel_capture_goomba_y_max : Z := 2496.
Definition spindel_post_hit_goomba_y_max : Z := 2517.

Theorem spindel_capture_imposes_goomba_collision_band :
  forall mario_y goomba_y,
    spindel_capture_mario_y_min <= mario_y <=
      spindel_capture_mario_y_max ->
    regular_goomba_vertical_overlap mario_y goomba_y ->
    spindel_capture_goomba_y_min <= goomba_y <=
      spindel_capture_goomba_y_max.
Proof.
  intros mario_y goomba_y Hmario Hoverlap.
  unfold spindel_capture_mario_y_min,
    spindel_capture_mario_y_max,
    spindel_capture_goomba_y_min,
    spindel_capture_goomba_y_max,
    regular_goomba_vertical_overlap,
    regular_goomba_height_z,
    normal_mario_height_z in *.
  lia.
Qed.

Theorem final_productive_hit_stays_below_2518 :
  forall goomba_y,
    goomba_y <= spindel_capture_goomba_y_max ->
    goomba_y + goomba_productive_rise_z <=
      spindel_post_hit_goomba_y_max.
Proof.
  intros goomba_y Hbound.
  unfold spindel_capture_goomba_y_max,
    goomba_productive_rise_z,
    spindel_post_hit_goomba_y_max in *.
  lia.
Qed.

Theorem goomba_y_778_cannot_overlap_spindel_capture_mario :
  forall mario_y,
    spindel_capture_mario_y_min <= mario_y <=
      spindel_capture_mario_y_max ->
    ~ regular_goomba_vertical_overlap mario_y 778.
Proof.
  intros mario_y Hmario Hoverlap.
  unfold spindel_capture_mario_y_min,
    spindel_capture_mario_y_max,
    regular_goomba_vertical_overlap,
    regular_goomba_height_z,
    normal_mario_height_z in *.
  lia.
Qed.

(** ** The pyramid-top timer window for the post-collision H/F/R schedule *)

Definition pyramid_top_productive_window_frames : Z := 91.
Definition goomba_hfr_cycle_frames : Z := 3.
Definition pyramid_top_productive_hit_capacity : Z := 31.

(** The first H may occur on the first useful top frame.  Each later H needs
    one F and one R, so [n > 0] hits occupy at least
    [1 + 3 * (n - 1)] frames. *)
Definition post_collision_hfr_hits_fit_window (hits : Z) : Prop :=
  hits = 0 \/
  (1 <= hits /\
   1 + goomba_hfr_cycle_frames * (hits - 1) <=
     pyramid_top_productive_window_frames).

Theorem pyramid_top_hfr_window_allows_at_most_31_productive_hits :
  forall hits,
    post_collision_hfr_hits_fit_window hits ->
    hits <= pyramid_top_productive_hit_capacity.
Proof.
  intros hits Hfits.
  unfold post_collision_hfr_hits_fit_window,
    goomba_hfr_cycle_frames,
    pyramid_top_productive_window_frames,
    pyramid_top_productive_hit_capacity in *.
  destruct Hfits as [-> | Hfits]; lia.
Qed.

Theorem thirty_one_hfr_hits_fit_idealized_window :
  post_collision_hfr_hits_fit_window pyramid_top_productive_hit_capacity.
Proof.
  unfold post_collision_hfr_hits_fit_window,
    pyramid_top_productive_hit_capacity,
    goomba_hfr_cycle_frames,
    pyramid_top_productive_window_frames.
  right.
  lia.
Qed.

Theorem pyramid_top_hfr_window_cannot_raise_y51_to_y1791 :
  51 + goomba_productive_rise_z *
    pyramid_top_productive_hit_capacity < 1791.
Proof.
  unfold goomba_productive_rise_z,
    pyramid_top_productive_hit_capacity.
  lia.
Qed.

Theorem eighty_three_productive_hits_are_the_first_arithmetic_crossing :
  51 + goomba_productive_rise_z * 82 < 1791 /\
  1791 <= 51 + goomba_productive_rise_z * 83.
Proof.
  unfold goomba_productive_rise_z.
  lia.
Qed.

(** ** The revised pre-collision timing class

    The raw-Object proposal below changes which frame establishes overlap,
    but it does not remove the Goomba state machine's reset frame.  A
    return/reset frame consumes the cached hit while FAR suppresses movement;
    the following departure frame begins the jump and performs the productive
    rise.  [goomba_revised_precollision_tail] is the exact alternating
    quotient of those two phases.

    The phase-shifted schedule deliberately grants the proposal its strongest
    possible start: the first useful top frame is already a productive
    departure.  The concrete obligation below instead begins FAR and therefore
    uses [goomba_return_first_precollision_schedule].  Thus the 46-hit bound is
    conservative even if a future linked execution supplies both raw-Object
    writers for free. *)
Inductive GoombaPrecollisionTimingPhase : Type :=
| GoombaPrecollisionReturnReset
| GoombaPrecollisionDepartureRise.

Fixpoint goomba_revised_precollision_tail
    (additional_hits : nat) : list GoombaPrecollisionTimingPhase :=
  match additional_hits with
  | O => []
  | S remaining =>
      GoombaPrecollisionReturnReset ::
      GoombaPrecollisionDepartureRise ::
      goomba_revised_precollision_tail remaining
  end.

Definition goomba_phase_shifted_precollision_schedule
    (hits : nat) : list GoombaPrecollisionTimingPhase :=
  match hits with
  | O => []
  | S remaining =>
      GoombaPrecollisionDepartureRise ::
      goomba_revised_precollision_tail remaining
  end.

Definition goomba_return_first_precollision_schedule
    (hits : nat) : list GoombaPrecollisionTimingPhase :=
  goomba_revised_precollision_tail hits.

Fixpoint goomba_precollision_productive_hits
    (schedule : list GoombaPrecollisionTimingPhase) : nat :=
  match schedule with
  | [] => O
  | GoombaPrecollisionReturnReset :: remaining =>
      goomba_precollision_productive_hits remaining
  | GoombaPrecollisionDepartureRise :: remaining =>
      S (goomba_precollision_productive_hits remaining)
  end.

Fixpoint goomba_precollision_total_rise_z
    (schedule : list GoombaPrecollisionTimingPhase) : Z :=
  match schedule with
  | [] => 0
  | GoombaPrecollisionReturnReset :: remaining =>
      goomba_precollision_total_rise_z remaining
  | GoombaPrecollisionDepartureRise :: remaining =>
      goomba_productive_rise_z +
      goomba_precollision_total_rise_z remaining
  end.

Lemma goomba_revised_precollision_tail_length :
  forall additional_hits,
    length (goomba_revised_precollision_tail additional_hits) =
      (2 * additional_hits)%nat.
Proof.
  induction additional_hits as [| additional_hits IH]; simpl; lia.
Qed.

Lemma goomba_revised_precollision_tail_hit_count :
  forall additional_hits,
    goomba_precollision_productive_hits
      (goomba_revised_precollision_tail additional_hits) = additional_hits.
Proof.
  induction additional_hits as [| additional_hits IH]; simpl; lia.
Qed.

Lemma goomba_revised_precollision_tail_total_rise :
  forall additional_hits,
    goomba_precollision_total_rise_z
      (goomba_revised_precollision_tail additional_hits) =
      goomba_productive_rise_z * Z.of_nat additional_hits.
Proof.
  induction additional_hits as [| additional_hits IH].
  - reflexivity.
  - change (goomba_productive_rise_z +
      goomba_precollision_total_rise_z
        (goomba_revised_precollision_tail additional_hits) =
      goomba_productive_rise_z * Z.of_nat (S additional_hits)).
    rewrite IH, Nat2Z.inj_succ. lia.
Qed.

Theorem goomba_return_first_precollision_schedule_exact :
  forall hits,
    length (goomba_return_first_precollision_schedule hits) =
      (2 * hits)%nat /\
    goomba_precollision_productive_hits
      (goomba_return_first_precollision_schedule hits) = hits /\
    goomba_precollision_total_rise_z
      (goomba_return_first_precollision_schedule hits) =
      goomba_productive_rise_z * Z.of_nat hits.
Proof.
  intros hits.
  unfold goomba_return_first_precollision_schedule.
  repeat split.
  - exact (goomba_revised_precollision_tail_length hits).
  - exact (goomba_revised_precollision_tail_hit_count hits).
  - exact (goomba_revised_precollision_tail_total_rise hits).
Qed.

Theorem goomba_phase_shifted_precollision_schedule_exact :
  forall hits,
    goomba_precollision_productive_hits
      (goomba_phase_shifted_precollision_schedule hits) = hits /\
    goomba_precollision_total_rise_z
      (goomba_phase_shifted_precollision_schedule hits) =
      goomba_productive_rise_z * Z.of_nat hits /\
    match hits with
    | O =>
        length (goomba_phase_shifted_precollision_schedule hits) = O
    | S remaining =>
        length (goomba_phase_shifted_precollision_schedule hits) =
          S (2 * remaining)%nat
    end.
Proof.
  intros [| remaining].
  - repeat split; reflexivity.
  - change
      (S (goomba_precollision_productive_hits
         (goomba_revised_precollision_tail remaining)) = S remaining /\
       goomba_productive_rise_z + goomba_precollision_total_rise_z
         (goomba_revised_precollision_tail remaining) =
         goomba_productive_rise_z * Z.of_nat (S remaining) /\
       S (length (goomba_revised_precollision_tail remaining)) =
         S (2 * remaining)%nat).
    rewrite goomba_revised_precollision_tail_hit_count,
      goomba_revised_precollision_tail_total_rise,
      goomba_revised_precollision_tail_length,
      Nat2Z.inj_succ.
    repeat split; lia.
Qed.

Theorem return_first_precollision_window_allows_at_most_45_productive_hits :
  forall hits,
    Z.of_nat
      (length (goomba_return_first_precollision_schedule hits)) <=
      pyramid_top_productive_window_frames ->
    Z.of_nat hits <= 45.
Proof.
  intros hits Hwindow.
  pose proof (goomba_return_first_precollision_schedule_exact hits)
    as (Hlength & _).
  rewrite Hlength, Nat2Z.inj_mul in Hwindow.
  change (2 * Z.of_nat hits <= 91) in Hwindow.
  lia.
Qed.

Theorem phase_shifted_precollision_window_allows_at_most_46_productive_hits :
  forall hits,
    Z.of_nat
      (length (goomba_phase_shifted_precollision_schedule hits)) <=
      pyramid_top_productive_window_frames ->
    Z.of_nat hits <= 46.
Proof.
  intros [| remaining] Hwindow; [simpl; lia |].
  pose proof
    (goomba_phase_shifted_precollision_schedule_exact (S remaining))
    as (_ & _ & Hlength).
  change (length (goomba_phase_shifted_precollision_schedule (S remaining)) =
    S (2 * remaining)%nat) in Hlength.
  rewrite Hlength, Nat2Z.inj_succ, Nat2Z.inj_mul in Hwindow.
  change (Z.succ (2 * Z.of_nat remaining) <= 91) in Hwindow.
  rewrite Nat2Z.inj_succ.
  lia.
Qed.

Theorem forty_five_return_first_hits_fit_idealized_window :
  Z.of_nat
    (length (goomba_return_first_precollision_schedule 45)) <=
    pyramid_top_productive_window_frames.
Proof. vm_compute. discriminate. Qed.

Theorem forty_six_phase_shifted_hits_fill_idealized_window :
  Z.of_nat
    (length (goomba_phase_shifted_precollision_schedule 46)) =
    pyramid_top_productive_window_frames.
Proof. vm_compute. reflexivity. Qed.

Theorem revised_precollision_window_cannot_raise_y51_to_y1791 :
  forall hits,
    Z.of_nat
      (length (goomba_phase_shifted_precollision_schedule hits)) <=
      pyramid_top_productive_window_frames ->
    51 + goomba_productive_rise_z * Z.of_nat hits <= 1017 /\
    51 + goomba_productive_rise_z * Z.of_nat hits < 1791.
Proof.
  intros hits Hwindow.
  pose proof
    (phase_shifted_precollision_window_allows_at_most_46_productive_hits
      hits Hwindow) as Hhits.
  unfold goomba_productive_rise_z.
  lia.
Qed.

Theorem pyramid_top_y51_after_46_float32_rises_checked :
  Float32.to_bits
    (iterate_goomba_float32_rises 46
      (Float32.of_int (Int.repr 51))) =
  Float32.to_bits (Float32.of_int (Int.repr 1017)).
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem revised_precollision_best_case_misses_top_by_774 :
  51 + goomba_productive_rise_z * 46 = 1017 /\
  1791 - 1017 = 774.
Proof.
  unfold goomba_productive_rise_z.
  lia.
Qed.

(** * Concrete missing retail-execution schemas

    The following observation record names the memory values that a future
    Clight projection must read.  In particular, the distance is the actual
    [oDistanceToMario] binary32 field.  The long-named cached-collision field
    is the conjunction of the retail [INTERACTED] and [ATTACKED_MARIO] status
    bits consumed by the Goomba handler, not geometric overlap and not an
    arbitrary nonzero interaction status.  A linked projection must derive
    that conjunction from live memory.  Neither value is recomputed with
    mathematical reals here. *)

Record GoombaRetailObservation : Type := {
  raising_area : Int.int;
  raising_a_button_pressed : bool;
  raising_mario_state_position : Vec3f;
  raising_mario_object_position : Vec3f;
  raising_goomba_position : Vec3f;
  raising_goomba_distance_to_mario : float32;
  raising_goomba_action : Int.int;
  raising_goomba_vel_y : float32;
  raising_goomba_far_flag : bool;
  raising_goomba_on_ground : bool;
  raising_goomba_cached_interacted_and_attacked_mario : bool;
  raising_goomba_geometric_overlap : bool;
  raising_goomba_active : bool;
  raising_goomba_singleton : bool;
  raising_goomba_slot : nat;
  raising_goomba_epoch : nat;
  raising_spindel_distance_to_mario : float32;
  raising_spindel_collision_loaded : bool;
  raising_platform_is_spindel : bool
}.

Definition ssl_area1_id : Int.int := Int.repr 1.
Definition ssl_area2_id : Int.int := Int.repr 2.

Definition goomba_observation_no_a
    (observation : GoombaRetailObservation) : Prop :=
  raising_a_button_pressed observation = false.

Definition goomba_observation_distance_far
    (observation : GoombaRetailObservation) : Prop :=
  Float32.cmp Clt goomba_f32_4000
    (raising_goomba_distance_to_mario observation) = true.

(** This exactly mirrors the branch complement of
    [distanceFromMario > drawingDistance], including unordered binary32
    comparisons. *)
Definition goomba_observation_distance_not_far
    (observation : GoombaRetailObservation) : Prop :=
  Float32.cmp Clt goomba_f32_4000
    (raising_goomba_distance_to_mario observation) = false.

Definition same_goomba_allocation
    (first second : GoombaRetailObservation) : Prop :=
  raising_goomba_slot first = raising_goomba_slot second /\
  raising_goomba_epoch first = raising_goomba_epoch second.

Definition retail_trace_connects
    (before after : Clight.state)
    (trace : list Clight.state) : Prop :=
  exists middle, trace = before :: middle ++ [after].

Definition observation_projection_functional
    (version : GameVersion)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  forall concrete_state first second,
    projects_observation version concrete_state first ->
    projects_observation version concrete_state second ->
    first = second.

Definition retail_trace_projects_no_a
    (version : GameVersion)
    (trace : list Clight.state)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  forall concrete_state,
    In concrete_state trace ->
    (exists observation,
      projects_observation version concrete_state observation) /\
    forall observation,
      projects_observation version concrete_state observation ->
      goomba_observation_no_a observation.

Definition retail_trace_projects_no_a_live_allocation
    (version : GameVersion)
    (trace : list Clight.state)
    (anchor : GoombaRetailObservation)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  forall concrete_state,
    In concrete_state trace ->
    (exists observation,
      projects_observation version concrete_state observation) /\
    forall observation,
      projects_observation version concrete_state observation ->
      goomba_observation_no_a observation /\
      raising_goomba_active observation = true /\
      raising_goomba_singleton observation = true /\
      same_goomba_allocation anchor observation.

Definition retail_trace_projects_area2_no_a
    (version : GameVersion)
    (trace : list Clight.state)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  forall concrete_state,
    In concrete_state trace ->
    (exists observation,
      projects_observation version concrete_state observation) /\
    forall observation,
      projects_observation version concrete_state observation ->
      raising_area observation = ssl_area2_id /\
      goomba_observation_no_a observation.

Definition retail_trace_projects_area2_no_a_live_allocation
    (version : GameVersion)
    (trace : list Clight.state)
    (anchor : GoombaRetailObservation)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  forall concrete_state,
    In concrete_state trace ->
    (exists observation,
      projects_observation version concrete_state observation) /\
    forall observation,
      projects_observation version concrete_state observation ->
      raising_area observation = ssl_area2_id /\
      goomba_observation_no_a observation /\
      raising_goomba_active observation = true /\
      raising_goomba_singleton observation = true /\
      same_goomba_allocation anchor observation.

Definition observes_goomba_h_ready
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = false /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = true /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_goomba_after_h
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 1 /\
  raising_goomba_vel_y observation = goomba_f32_21 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_goomba_after_f
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_goomba_after_r
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = false /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = true /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

(** This is one exact post-collision-return shuttle witness at linked phase
    boundaries; it is not a proof that all possible raising schedules have
    this shape.
    [h_start] and [next_h_collision] are post-collision/pre-Goomba-update
    states.  The R endpoint is merely positioned for the next collision pass:
    it must not already carry [ATTACKED_MARIO], because the same-frame Goomba
    update would consume that status and leave action 1.  An instantiation
    must provide linked US/JP trace execution, a proof that the trace lists
    every modeled frame, and a functional memory projection.  The trace-wide
    predicate requires every projected observation to have no A edge and the
    same live singleton allocation; endpoint-only checks are insufficient.
    The finite arithmetic theorem alone supplies none of these movements. *)
Definition FullFloatHFRShuttleObligation
    (reachable_clean_no_a :
      GameVersion -> Clight.state -> Prop)
    (executes_retail_trace :
      GameVersion -> list Clight.state -> Prop)
    (trace_covers_every_modeled_frame :
      GameVersion -> list Clight.state -> Prop)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  exists version h_start h_end f_end r_end next_h_collision
         h_trace f_trace r_trace collision_trace
         h_start_observation h_end_observation
         f_end_observation r_end_observation next_h_observation,
    reachable_clean_no_a version h_start /\
    observation_projection_functional version projects_observation /\
    executes_retail_trace version h_trace /\
    executes_retail_trace version f_trace /\
    executes_retail_trace version r_trace /\
    executes_retail_trace version collision_trace /\
    trace_covers_every_modeled_frame version h_trace /\
    trace_covers_every_modeled_frame version f_trace /\
    trace_covers_every_modeled_frame version r_trace /\
    trace_covers_every_modeled_frame version collision_trace /\
    retail_trace_connects h_start h_end h_trace /\
    retail_trace_connects h_end f_end f_trace /\
    retail_trace_connects f_end r_end r_trace /\
    retail_trace_connects r_end next_h_collision collision_trace /\
    retail_trace_projects_no_a_live_allocation
      version h_trace h_start_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version f_trace h_start_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version r_trace h_start_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version collision_trace h_start_observation projects_observation /\
    projects_observation version h_start h_start_observation /\
    projects_observation version h_end h_end_observation /\
    projects_observation version f_end f_end_observation /\
    projects_observation version r_end r_end_observation /\
    projects_observation version next_h_collision next_h_observation /\
    same_goomba_allocation h_start_observation h_end_observation /\
    same_goomba_allocation h_end_observation f_end_observation /\
    same_goomba_allocation f_end_observation r_end_observation /\
    same_goomba_allocation r_end_observation next_h_observation /\
    observes_goomba_h_ready h_start_observation /\
    observes_goomba_after_h h_end_observation /\
    observes_goomba_after_f f_end_observation /\
    observes_goomba_after_r r_end_observation /\
    observes_goomba_h_ready next_h_observation /\
    goomba_observation_distance_not_far h_start_observation /\
    goomba_observation_distance_far h_end_observation /\
    goomba_observation_distance_far f_end_observation /\
    goomba_observation_distance_not_far r_end_observation /\
    goomba_observation_distance_not_far next_h_observation /\
    goomba_observation_no_a h_start_observation /\
    goomba_observation_no_a h_end_observation /\
    goomba_observation_no_a f_end_observation /\
    goomba_observation_no_a r_end_observation /\
    goomba_observation_no_a next_h_observation /\
    vec_y (raising_goomba_position h_end_observation) =
      Float32.add
        (vec_y (raising_goomba_position h_start_observation))
        goomba_f32_21 /\
    raising_goomba_position f_end_observation =
      raising_goomba_position h_end_observation /\
    raising_goomba_position r_end_observation =
      raising_goomba_position f_end_observation /\
    raising_goomba_position next_h_observation =
      raising_goomba_position r_end_observation.

(** A distinct writer schema can return Mario's raw Object before collision
    while the Goomba still begins the frame FAR.  That frame may cache both
    [INTERACTED] and [ATTACKED_MARIO], select action 1 with movement
    suppressed, consume the cache, and clear FAR.  A following departure frame
    can then execute action 1, reset velocity to 25, and move upward.

    The writer inventory is a classification interface only.  No constructor
    below is proved reachable, and a linked proof must show the classified
    relation covers the concrete raw-Object write.  Every represented
    intermediate state must preserve the same live singleton allocation.  The
    obligation remains useful for identifying a writer or a different route,
    but repeating this exact two-frame shape cannot meet the checked Rank-16
    91-frame height budget proved above. *)
Inductive GoombaRawObjectWriterClass : Type :=
| GoombaWriterMarioStateToObjectSync
| GoombaWriterPlatformOrPUStateCopy
| GoombaWriterObjectOrCollisionImpulse
| GoombaWriterLifecycleOrEntry.

Definition observes_far_jump_before_precollision_return
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = false /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_returned_object_before_collision
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = true /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_cached_return_hit_before_goomba_update
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = true /\
  raising_goomba_geometric_overlap observation = true /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_after_precollision_return
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 1 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = false /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = true /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_departure_before_collision
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 1 /\
  raising_goomba_vel_y observation = goomba_f32_25 /\
  raising_goomba_far_flag observation = false /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = false /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition observes_after_precollision_departure
    (observation : GoombaRetailObservation) : Prop :=
  raising_goomba_action observation = Int.repr 2 /\
  raising_goomba_vel_y observation = goomba_f32_21 /\
  raising_goomba_far_flag observation = true /\
  raising_goomba_on_ground observation = false /\
  raising_goomba_cached_interacted_and_attacked_mario observation = false /\
  raising_goomba_geometric_overlap observation = false /\
  raising_goomba_active observation = true /\
  raising_goomba_singleton observation = true.

Definition PreCollisionRawObjectReturnRaisingObligation
    (reachable_clean_no_a :
      GameVersion -> Clight.state -> Prop)
    (executes_retail_trace :
      GameVersion -> list Clight.state -> Prop)
    (trace_covers_every_modeled_frame :
      GameVersion -> list Clight.state -> Prop)
    (executes_classified_raw_object_writer :
      GameVersion -> GoombaRawObjectWriterClass ->
      list Clight.state -> Prop)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  exists version return_writer departure_writer
         far_start return_pre_collision return_collision_cached return_end
         departure_pre_collision departure_pre_update departure_end
         return_writer_trace return_collision_trace return_update_trace
         departure_writer_trace departure_collision_trace
         departure_update_trace
         far_observation return_pre_collision_observation
         return_collision_observation return_end_observation
         departure_pre_collision_observation
         departure_pre_update_observation departure_end_observation,
    reachable_clean_no_a version far_start /\
    observation_projection_functional version projects_observation /\
    executes_classified_raw_object_writer
      version return_writer return_writer_trace /\
    executes_classified_raw_object_writer
      version departure_writer departure_writer_trace /\
    executes_retail_trace version return_writer_trace /\
    executes_retail_trace version return_collision_trace /\
    executes_retail_trace version return_update_trace /\
    executes_retail_trace version departure_writer_trace /\
    executes_retail_trace version departure_collision_trace /\
    executes_retail_trace version departure_update_trace /\
    trace_covers_every_modeled_frame version return_writer_trace /\
    trace_covers_every_modeled_frame version return_collision_trace /\
    trace_covers_every_modeled_frame version return_update_trace /\
    trace_covers_every_modeled_frame version departure_writer_trace /\
    trace_covers_every_modeled_frame version departure_collision_trace /\
    trace_covers_every_modeled_frame version departure_update_trace /\
    retail_trace_connects
      far_start return_pre_collision return_writer_trace /\
    retail_trace_connects
      return_pre_collision return_collision_cached return_collision_trace /\
    retail_trace_connects
      return_collision_cached return_end return_update_trace /\
    retail_trace_connects
      return_end departure_pre_collision departure_writer_trace /\
    retail_trace_connects
      departure_pre_collision departure_pre_update departure_collision_trace /\
    retail_trace_connects
      departure_pre_update departure_end departure_update_trace /\
    retail_trace_projects_no_a_live_allocation
      version return_writer_trace far_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version return_collision_trace far_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version return_update_trace far_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version departure_writer_trace far_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version departure_collision_trace far_observation projects_observation /\
    retail_trace_projects_no_a_live_allocation
      version departure_update_trace far_observation projects_observation /\
    projects_observation version far_start far_observation /\
    projects_observation version return_pre_collision
      return_pre_collision_observation /\
    projects_observation version return_collision_cached
      return_collision_observation /\
    projects_observation version return_end return_end_observation /\
    projects_observation version departure_pre_collision
      departure_pre_collision_observation /\
    projects_observation version departure_pre_update
      departure_pre_update_observation /\
    projects_observation version departure_end departure_end_observation /\
    same_goomba_allocation
      far_observation return_pre_collision_observation /\
    same_goomba_allocation
      far_observation return_collision_observation /\
    same_goomba_allocation far_observation return_end_observation /\
    same_goomba_allocation
      far_observation departure_pre_collision_observation /\
    same_goomba_allocation
      far_observation departure_pre_update_observation /\
    same_goomba_allocation far_observation departure_end_observation /\
    observes_far_jump_before_precollision_return far_observation /\
    observes_returned_object_before_collision
      return_pre_collision_observation /\
    observes_cached_return_hit_before_goomba_update
      return_collision_observation /\
    observes_after_precollision_return return_end_observation /\
    observes_departure_before_collision
      departure_pre_collision_observation /\
    observes_departure_before_collision departure_pre_update_observation /\
    observes_after_precollision_departure departure_end_observation /\
    goomba_observation_distance_far far_observation /\
    goomba_observation_distance_not_far return_end_observation /\
    goomba_observation_distance_far departure_end_observation /\
    raising_mario_state_position return_pre_collision_observation =
      raising_mario_state_position far_observation /\
    raising_mario_object_position return_pre_collision_observation <>
      raising_mario_object_position far_observation /\
    raising_mario_state_position return_collision_observation =
      raising_mario_state_position return_pre_collision_observation /\
    raising_mario_object_position return_collision_observation =
      raising_mario_object_position return_pre_collision_observation /\
    raising_mario_state_position return_end_observation =
      raising_mario_state_position return_collision_observation /\
    raising_mario_object_position return_end_observation =
      raising_mario_object_position return_collision_observation /\
    raising_goomba_position return_pre_collision_observation =
      raising_goomba_position far_observation /\
    raising_goomba_position return_collision_observation =
      raising_goomba_position far_observation /\
    raising_goomba_position return_end_observation =
      raising_goomba_position far_observation /\
    raising_mario_state_position departure_pre_collision_observation =
      raising_mario_state_position return_end_observation /\
    raising_mario_object_position departure_pre_collision_observation <>
      raising_mario_object_position return_end_observation /\
    raising_mario_state_position departure_pre_update_observation =
      raising_mario_state_position departure_pre_collision_observation /\
    raising_mario_object_position departure_pre_update_observation =
      raising_mario_object_position departure_pre_collision_observation /\
    raising_goomba_position departure_pre_collision_observation =
      raising_goomba_position return_end_observation /\
    raising_goomba_position departure_pre_update_observation =
      raising_goomba_position departure_pre_collision_observation /\
    vec_x (raising_goomba_position departure_end_observation) =
      vec_x (raising_goomba_position return_end_observation) /\
    vec_y (raising_goomba_position departure_end_observation) =
      Float32.add
        (vec_y (raising_goomba_position return_end_observation))
        goomba_f32_21 /\
    vec_z (raising_goomba_position departure_end_observation) =
      vec_z (raising_goomba_position return_end_observation).

Definition float32_axis_gap_at_least_one_pu
    (first second : float32) : Prop :=
  Float32.cmp Cle goomba_f32_65536
    (Float32.sub first second) = true \/
  Float32.cmp Cle goomba_f32_65536
    (Float32.sub second first) = true.

Definition vec3f_has_pu_sized_xz_gap
    (first second : Vec3f) : Prop :=
  float32_axis_gap_at_least_one_pu
    (vec_x first) (vec_x second) \/
  float32_axis_gap_at_least_one_pu
    (vec_z first) (vec_z second).

Definition spindel_locally_loaded
    (observation : GoombaRetailObservation) : Prop :=
  raising_spindel_collision_loaded observation = true /\
  Float32.cmp Clt
    (raising_spindel_distance_to_mario observation)
    goomba_f32_1000 = true.

(** The proposed PU capture trace starts at a post-load boundary where the
    Spindel moving collision is already local and retained, then returns a
    Spindel-owned surface as Mario's platform after a PU-sized full-coordinate
    move.  Platform capture reads Mario Object, so the gap is imposed on Object
    coordinates and the capture endpoint additionally requires State/Object
    equality.  Every represented frame must have no A edge. *)
Definition SpindelSameSegmentPUCaptureObligation
    (reachable_clean_no_a :
      GameVersion -> Clight.state -> Prop)
    (executes_retail_trace :
      GameVersion -> list Clight.state -> Prop)
    (trace_covers_every_modeled_frame :
      GameVersion -> list Clight.state -> Prop)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  exists version before after trace before_observation after_observation,
    reachable_clean_no_a version before /\
    observation_projection_functional version projects_observation /\
    executes_retail_trace version trace /\
    trace_covers_every_modeled_frame version trace /\
    retail_trace_connects before after trace /\
    retail_trace_projects_area2_no_a
      version trace projects_observation /\
    projects_observation version before before_observation /\
    projects_observation version after after_observation /\
    raising_area before_observation = ssl_area2_id /\
    raising_area after_observation = ssl_area2_id /\
    goomba_observation_no_a before_observation /\
    goomba_observation_no_a after_observation /\
    spindel_locally_loaded before_observation /\
    raising_spindel_collision_loaded after_observation = true /\
    raising_platform_is_spindel after_observation = true /\
    raising_mario_state_position after_observation =
      raising_mario_object_position after_observation /\
    vec3f_has_pu_sized_xz_gap
      (raising_mario_object_position before_observation)
      (raising_mario_object_position after_observation).

(** Raising a singleton in one place does not transport it to the Spindel's
    useful PU.  This schema asks for that separate same-allocation transport
    trace while Area 2 remains loaded. *)
Definition GoombaParallelUniverseTransportObligation
    (reachable_clean_no_a :
      GameVersion -> Clight.state -> Prop)
    (executes_retail_trace :
      GameVersion -> list Clight.state -> Prop)
    (trace_covers_every_modeled_frame :
      GameVersion -> list Clight.state -> Prop)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  exists version before after trace before_observation after_observation,
    reachable_clean_no_a version before /\
    observation_projection_functional version projects_observation /\
    executes_retail_trace version trace /\
    trace_covers_every_modeled_frame version trace /\
    retail_trace_connects before after trace /\
    retail_trace_projects_area2_no_a_live_allocation
      version trace before_observation projects_observation /\
    projects_observation version before before_observation /\
    projects_observation version after after_observation /\
    raising_area before_observation = ssl_area2_id /\
    raising_area after_observation = ssl_area2_id /\
    goomba_observation_no_a before_observation /\
    goomba_observation_no_a after_observation /\
    raising_goomba_active before_observation = true /\
    raising_goomba_active after_observation = true /\
    raising_goomba_singleton before_observation = true /\
    raising_goomba_singleton after_observation = true /\
    same_goomba_allocation before_observation after_observation /\
    vec3f_has_pu_sized_xz_gap
      (raising_goomba_position before_observation)
      (raising_goomba_position after_observation).

Definition f32_goomba_y_in_spindel_pre_hit_band
    (observation : GoombaRetailObservation) : Prop :=
  Float32.cmp Cle
    (Float32.of_int (Int.repr spindel_capture_goomba_y_min))
    (vec_y (raising_goomba_position observation)) = true /\
  Float32.cmp Cle
    (vec_y (raising_goomba_position observation))
    (Float32.of_int (Int.repr spindel_capture_goomba_y_max)) = true.

Definition f32_mario_y_in_spindel_capture_band
    (observation : GoombaRetailObservation) : Prop :=
  Float32.cmp Cle
    (Float32.of_int (Int.repr spindel_capture_mario_y_min))
    (vec_y (raising_mario_object_position observation)) = true /\
  Float32.cmp Cle
    (vec_y (raising_mario_object_position observation))
    (Float32.of_int (Int.repr spindel_capture_mario_y_max)) = true.

(** Even a raised and transported Goomba is not yet a route.  This final
    schema asks for a clean no-A trace from a real Goomba collision in the
    derived height band to an actual Spindel platform capture. *)
Definition RaisedGoombaToSpindelHandoffObligation
    (reachable_clean_no_a :
      GameVersion -> Clight.state -> Prop)
    (executes_retail_trace :
      GameVersion -> list Clight.state -> Prop)
    (trace_covers_every_modeled_frame :
      GameVersion -> list Clight.state -> Prop)
    (projects_observation :
      GameVersion -> Clight.state -> GoombaRetailObservation -> Prop) :
    Prop :=
  exists version contact capture trace
         contact_observation capture_observation,
    reachable_clean_no_a version contact /\
    observation_projection_functional version projects_observation /\
    executes_retail_trace version trace /\
    trace_covers_every_modeled_frame version trace /\
    retail_trace_connects contact capture trace /\
    retail_trace_projects_area2_no_a_live_allocation
      version trace contact_observation projects_observation /\
    projects_observation version contact contact_observation /\
    projects_observation version capture capture_observation /\
    raising_area contact_observation = ssl_area2_id /\
    raising_area capture_observation = ssl_area2_id /\
    goomba_observation_no_a contact_observation /\
    goomba_observation_no_a capture_observation /\
    raising_goomba_geometric_overlap contact_observation = true /\
    raising_goomba_active contact_observation = true /\
    raising_goomba_active capture_observation = true /\
    raising_goomba_singleton contact_observation = true /\
    raising_goomba_singleton capture_observation = true /\
    same_goomba_allocation contact_observation capture_observation /\
    f32_goomba_y_in_spindel_pre_hit_band contact_observation /\
    f32_goomba_y_in_spindel_pre_hit_band capture_observation /\
    raising_goomba_geometric_overlap capture_observation = true /\
    f32_mario_y_in_spindel_capture_band capture_observation /\
    raising_spindel_collision_loaded capture_observation = true /\
    raising_platform_is_spindel capture_observation = true.

(** The proved export deliberately contains only bounded, unconditional
    arithmetic facts. *)
Definition goomba_raising_bounded_claim : Prop :=
  (forall y,
      goomba_productive_cycle (goomba_ready_at y) =
        goomba_ready_at (y + 21)) /\
  (forall cycles y,
      iterate_goomba_productive_cycles cycles (goomba_ready_at y) =
        goomba_ready_at (y + 21 * Z.of_nat cycles)) /\
  Float32.to_bits
    (Float32.add goomba_f32_25 goomba_f32_neg4) =
      Int.repr 1101529088 /\
  goomba_position_rounding_counterexample_claim /\
  Float32.to_bits
    (Float32.add goomba_f32_2p29 goomba_f32_21) =
      Int.repr 1308622848 /\
  Float32.to_bits
    (iterate_goomba_float32_rises 31
      (Float32.of_int (Int.repr 51))) =
    Float32.to_bits (Float32.of_int (Int.repr 702)) /\
  Float32.to_bits
    (iterate_goomba_float32_rises 83
      (Float32.of_int (Int.repr 51))) =
    Float32.to_bits (Float32.of_int (Int.repr 1794)) /\
  (forall mario_y,
      2036 <= mario_y <= 2336 ->
      ~ regular_goomba_vertical_overlap mario_y 778) /\
  (forall hits,
      post_collision_hfr_hits_fit_window hits -> hits <= 31) /\
  51 + 21 * 31 < 1791 /\
  (forall hits,
      Z.of_nat
        (length (goomba_return_first_precollision_schedule hits)) <=
        pyramid_top_productive_window_frames ->
      Z.of_nat hits <= 45) /\
  (forall hits,
      Z.of_nat
        (length (goomba_phase_shifted_precollision_schedule hits)) <=
        pyramid_top_productive_window_frames ->
      Z.of_nat hits <= 46) /\
  (forall hits,
      Z.of_nat
        (length (goomba_phase_shifted_precollision_schedule hits)) <=
        pyramid_top_productive_window_frames ->
      51 + goomba_productive_rise_z * Z.of_nat hits < 1791) /\
  Float32.to_bits
    (iterate_goomba_float32_rises 46
      (Float32.of_int (Int.repr 51))) =
    Float32.to_bits (Float32.of_int (Int.repr 1017)).

Theorem goomba_raising_bounded_kernel :
  goomba_raising_bounded_claim.
Proof.
  unfold goomba_raising_bounded_claim.
  split.
  - exact goomba_hfr_productive_cycle.
  - split.
    + exact finite_goomba_productive_cycles.
    + split.
      * exact goomba_velocity_after_gravity_binary32_checked.
      * split.
        -- exact goomba_position_delta_need_not_be_exact_21.
        -- split.
           ++ exact goomba_binary32_raising_stagnates_at_2p29.
           ++ split.
              ** exact pyramid_top_y51_after_31_float32_rises_checked.
              ** split.
                 --- exact pyramid_top_y51_after_83_float32_rises_checked.
                 --- split.
                     +++ intros mario_y Hband.
                         apply goomba_y_778_cannot_overlap_spindel_capture_mario.
                         exact Hband.
                     +++ split.
                         *** intros hits Hfits.
                             apply
                               pyramid_top_hfr_window_allows_at_most_31_productive_hits.
                             exact Hfits.
                         *** split; [lia |].
                             split.
                             ---- exact
                               return_first_precollision_window_allows_at_most_45_productive_hits.
                             ---- split.
                                  ++++ exact
                                    phase_shifted_precollision_window_allows_at_most_46_productive_hits.
                                  ++++ split.
                                       **** intros hits Hwindow.
                                            exact (proj2
                                              (revised_precollision_window_cannot_raise_y51_to_y1791
                                                hits Hwindow)).
                                       **** exact
                                            pyramid_top_y51_after_46_float32_rises_checked.
Qed.
