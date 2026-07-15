From Coq Require Import Bool Lia ZArith.

Local Open Scope Z_scope.

(** A schedule records the A bit immediately before the measured interval as
    well as the bit on each frame.  This distinguishes continuously held A
    from a fresh A press on frame zero. *)
Record a_schedule : Type := {
  a_before_start : bool;
  a_down_at : nat -> bool
}.

Definition a_press_edge (schedule : a_schedule) (frame : nat) : Prop :=
  a_down_at schedule frame = true /\
  match frame with
  | O => a_before_start schedule = false
  | S previous => a_down_at schedule previous = false
  end.

Definition unrestricted_a (_ : a_schedule) : Prop := True.

Definition always_released_a (schedule : a_schedule) : Prop :=
  a_before_start schedule = false /\
  forall frame, a_down_at schedule frame = false.

Definition continuously_held_a (schedule : a_schedule) : Prop :=
  a_before_start schedule = true /\
  forall frame, a_down_at schedule frame = true.

Lemma always_released_has_no_press_edge : forall schedule frame,
  always_released_a schedule -> ~ a_press_edge schedule frame.
Proof.
  intros schedule frame (_ & Hreleased) (Hdown & _).
  rewrite Hreleased in Hdown. discriminate.
Qed.

Lemma continuously_held_has_no_press_edge : forall schedule frame,
  continuously_held_a schedule -> ~ a_press_edge schedule frame.
Proof.
  intros schedule [| previous] (Hbefore & Hheld) (Hdown & Hprevious).
  - congruence.
  - rewrite Hheld in Hprevious. discriminate.
Qed.

Inductive observed_area : Type := ObservedArea2 | ObservedArea3.

Inductive observed_mario_floor : Type :=
| ObservedFirstHandFloor
| ObservedSecondHandFloor
| ObservedArea3WarpFloor
| ObservedOtherFloor
| ObservedNoFloor.

(** These fields intentionally keep hand origins, transformed hand surfaces,
    and Mario Y separate.  The four legacy numbers denote different kinds of
    observation and must never be substituted for one another. *)
Record height_observation : Type := {
  observed_area_of : observed_area;
  observed_first_hand_origin_y : Z;
  observed_first_hand_surface_y : option Z;
  observed_second_hand_origin_y : Z;
  observed_second_hand_surface_y : option Z;
  observed_mario_y : Z;
  observed_mario_floor_of : observed_mario_floor
}.

Definition optional_height_at_least (threshold : Z) (height : option Z) : Prop :=
  exists value, height = Some value /\ threshold <= value.

Definition reaches_first_surface_1179 (observation : height_observation) : Prop :=
  optional_height_at_least 1179 (observed_first_hand_surface_y observation).

Definition reaches_second_origin_1467 (observation : height_observation) : Prop :=
  1467 <= observed_second_hand_origin_y observation.

Definition reaches_second_surface_1974 (observation : height_observation) : Prop :=
  optional_height_at_least 1974 (observed_second_hand_surface_y observation).

Definition reaches_mario_y_2604 (observation : height_observation) : Prop :=
  2604 <= observed_mario_y observation.

Definition area3_warp_ready_at_mario_y
    (threshold : Z) (observation : height_observation) : Prop :=
  observed_area_of observation = ObservedArea3 /\
  observed_mario_floor_of observation = ObservedArea3WarpFloor /\
  threshold <= observed_mario_y observation.

Definition area2_preserves_mario_y
    (before after : height_observation) : Prop :=
  observed_area_of before = ObservedArea3 /\
  observed_area_of after = ObservedArea2 /\
  observed_mario_y after = observed_mario_y before.

Lemma milestone_thresholds_strictly_increase :
  1179 < 1467 /\ 1467 < 1974 /\ 1974 < 2604.
Proof. lia. Qed.
