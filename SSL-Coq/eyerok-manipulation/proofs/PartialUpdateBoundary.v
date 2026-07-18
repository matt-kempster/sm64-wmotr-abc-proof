From Coq Require Import Bool ZArith.

Local Open Scope Z_scope.

(** Source-shaped boundary model for the object lifecycle facts that prevent
    an Eyerok hand from receiving a movement-only partial update.

    This file is deliberately not a CompCert/Clight refinement theorem.  Its
    transition function records facts checked against the pinned SM64 source:

    - spawning initializes collision data to NULL, room to [-1], and both
      partial-update active flags to clear;
    - the first native sleep handler installs non-NULL hand collision data;
    - the native handler runs before the behavior interpreter's visibility
      evaluation;
    - every later hand collision-data write is non-NULL, and the hand behavior
      never writes its room;
    - visibility may newly set FAR_AWAY only while collision data is NULL, and
      may update IN_DIFFERENT_ROOM only when the room is not [-1]; and
    - when time stop freezes the hand, the entire object update is skipped.

    [lifecycle_reachable] is therefore explicitly the no-external-writer
    closure of these source-shaped frames.  A refinement from the generated C
    to this model remains a separate obligation. *)

Inductive hand_lifecycle_phase : Type :=
| AwaitingFirstSleepUpdate
| LiveHand.

Inductive collision_pointer_state : Type :=
| CollisionNull
| CollisionNonnull.

Record hand_lifecycle_state : Type := {
  lifecycle_phase : hand_lifecycle_phase;
  collision_pointer : collision_pointer_state;
  object_room : Z;
  active_far_away : bool;
  active_in_different_room : bool
}.

Definition spawned_hand : hand_lifecycle_state :=
  {| lifecycle_phase := AwaitingFirstSleepUpdate;
     collision_pointer := CollisionNull;
     object_room := -1;
     active_far_away := false;
     active_in_different_room := false |}.

Lemma spawned_hand_source_shape :
  collision_pointer spawned_hand = CollisionNull /\
  object_room spawned_hand = -1 /\
  active_far_away spawned_hand = false /\
  active_in_different_room spawned_hand = false.
Proof. repeat split; reflexivity. Qed.

(** This is the native portion of an unfrozen Eyerok-hand update.  In the
    first sleep update it installs collision data.  Once live, the audited
    native behavior can replace that pointer only with another non-NULL hand
    collision mesh.  It never writes [object_room]. *)
Definition eyerok_native_body
    (before : hand_lifecycle_state) : hand_lifecycle_state :=
  {| lifecycle_phase := LiveHand;
     collision_pointer := CollisionNonnull;
     object_room := object_room before;
     active_far_away := active_far_away before;
     active_in_different_room := active_in_different_room before |}.

Lemma first_sleep_body_loads_collision_before_visibility :
  lifecycle_phase (eyerok_native_body spawned_hand) = LiveHand /\
  collision_pointer (eyerok_native_body spawned_hand) = CollisionNonnull /\
  object_room (eyerok_native_body spawned_hand) = -1.
Proof. repeat split; reflexivity. Qed.

Lemma native_body_collision_is_nonnull : forall before,
  collision_pointer (eyerok_native_body before) = CollisionNonnull.
Proof. intros before. reflexivity. Qed.

Lemma native_body_preserves_room : forall before,
  object_room (eyerok_native_body before) = object_room before.
Proof. intros before. reflexivity. Qed.

(** [far_decision] and [room_decision] adversarially over-approximate all
    distance, held-state, and Mario-room outcomes inside visibility handling.
    The branch guards retain the exact source ordering: a non-default room is
    handled first; otherwise FAR_AWAY can be changed only for NULL collision
    data. *)
Definition visibility_evaluation
    (far_decision room_decision : bool)
    (before : hand_lifecycle_state) : hand_lifecycle_state :=
  if Z.eqb (object_room before) (-1) then
    match collision_pointer before with
    | CollisionNull =>
        {| lifecycle_phase := lifecycle_phase before;
           collision_pointer := CollisionNull;
           object_room := object_room before;
           active_far_away := far_decision;
           active_in_different_room := active_in_different_room before |}
    | CollisionNonnull => before
    end
  else
    {| lifecycle_phase := lifecycle_phase before;
       collision_pointer := collision_pointer before;
       object_room := object_room before;
       active_far_away := active_far_away before;
       active_in_different_room := room_decision |}.

Lemma visibility_new_far_away_requires_null_collision :
  forall before far_decision room_decision,
    active_far_away before = false ->
    active_far_away
      (visibility_evaluation far_decision room_decision before) = true ->
    collision_pointer before = CollisionNull.
Proof.
  intros [phase pointer room far different] far_decision room_decision
    Hclear Hset.
  cbn in Hclear |- *.
  unfold visibility_evaluation in Hset.
  cbn in Hset.
  destruct (Z.eqb room (-1)) eqn:Hroom.
  - destruct pointer; cbn in Hset.
    + reflexivity.
    + congruence.
  - cbn in Hset. congruence.
Qed.

Lemma default_room_visibility_preserves_clear_different_room :
  forall before far_decision room_decision,
    object_room before = -1 ->
    active_in_different_room before = false ->
    active_in_different_room
      (visibility_evaluation far_decision room_decision before) = false.
Proof.
  intros [phase pointer room far different] far_decision room_decision
    Hroom Hclear.
  cbn in *. subst room.
  destruct pointer; cbn; exact Hclear.
Qed.

(** The definition order is intentional: the native body produces the state
    consumed by visibility. *)
Definition running_hand_update
    (far_decision room_decision : bool)
    (before : hand_lifecycle_state) : hand_lifecycle_state :=
  visibility_evaluation far_decision room_decision
    (eyerok_native_body before).

Lemma first_running_update_observes_loaded_collision :
  forall far_decision room_decision,
    running_hand_update far_decision room_decision spawned_hand =
      {| lifecycle_phase := LiveHand;
         collision_pointer := CollisionNonnull;
         object_room := -1;
         active_far_away := false;
         active_in_different_room := false |}.
Proof. intros far_decision room_decision. reflexivity. Qed.

(** A true [time_stopped] argument means the object-list scheduler classified
    this hand as frozen.  The whole update stutters, rather than running the
    native action while skipping only [cur_obj_move_standard]. *)
Definition hand_update_frame
    (time_stopped far_decision room_decision : bool)
    (before : hand_lifecycle_state) : hand_lifecycle_state :=
  if time_stopped then before
  else running_hand_update far_decision room_decision before.

Lemma time_stop_freezes_whole_hand_update :
  forall before far_decision room_decision,
    hand_update_frame true far_decision room_decision before = before.
Proof. reflexivity. Qed.

Definition lifecycle_invariant (state : hand_lifecycle_state) : Prop :=
  object_room state = -1 /\
  active_far_away state = false /\
  active_in_different_room state = false /\
  (lifecycle_phase state = LiveHand ->
   collision_pointer state = CollisionNonnull).

Lemma spawned_hand_invariant : lifecycle_invariant spawned_hand.
Proof.
  repeat split; try reflexivity.
  discriminate.
Qed.

Theorem hand_update_frame_preserves_invariant :
  forall before time_stopped far_decision room_decision,
    lifecycle_invariant before ->
    lifecycle_invariant
      (hand_update_frame time_stopped far_decision room_decision before).
Proof.
  intros [phase pointer room far different]
    time_stopped far_decision room_decision Hsafe.
  destruct Hsafe as (Hroom & Hfar & Hdifferent & Hloaded).
  cbn in *. subst room. subst far. subst different.
  destruct time_stopped; cbn.
  - repeat split; try reflexivity.
    exact Hloaded.
  - destruct phase; cbn.
    + repeat split; intros; reflexivity.
    + specialize (Hloaded eq_refl). subst pointer.
      repeat split; intros; reflexivity.
Qed.

(** The only constructors below are complete frozen frames and complete
    running frames.  In particular there is no constructor for an external
    collision-pointer, room, or active-flag writer. *)
Inductive lifecycle_reachable : nat -> hand_lifecycle_state -> Prop :=
| lifecycle_reachable_spawn : lifecycle_reachable O spawned_hand
| lifecycle_reachable_frame : forall frame before
    time_stopped far_decision room_decision,
    lifecycle_reachable frame before ->
    lifecycle_reachable (S frame)
      (hand_update_frame time_stopped far_decision room_decision before).

Theorem every_lifecycle_reachable_state_satisfies_invariant :
  forall frame state,
    lifecycle_reachable frame state ->
    lifecycle_invariant state.
Proof.
  intros frame state Hreach. induction Hreach.
  - exact spawned_hand_invariant.
  - apply hand_update_frame_preserves_invariant.
    exact IHHreach.
Qed.

Definition live_hand (state : hand_lifecycle_state) : Prop :=
  lifecycle_phase state = LiveHand.

Definition movement_only_partial_update_guard
    (state : hand_lifecycle_state) : Prop :=
  active_far_away state = true \/
  active_in_different_room state = true.

Theorem live_eyerok_hand_cannot_enter_movement_only_partial_guard :
  forall frame state,
    lifecycle_reachable frame state ->
    live_hand state ->
    ~ movement_only_partial_update_guard state.
Proof.
  intros frame state Hreach _ Hpartial.
  destruct (every_lifecycle_reachable_state_satisfies_invariant
    frame state Hreach) as (_ & Hfar & Hdifferent & _).
  destruct Hpartial as [Hpartial | Hpartial]; congruence.
Qed.

Definition partial_update_boundary_certificate : Prop :=
  collision_pointer spawned_hand = CollisionNull /\
  object_room spawned_hand = -1 /\
  active_far_away spawned_hand = false /\
  active_in_different_room spawned_hand = false /\
  collision_pointer (eyerok_native_body spawned_hand) = CollisionNonnull /\
  (forall before far_decision room_decision,
      hand_update_frame true far_decision room_decision before = before) /\
  (forall frame state,
      lifecycle_reachable frame state ->
      live_hand state ->
      ~ movement_only_partial_update_guard state).

Theorem partial_update_boundary_certificate_holds :
  partial_update_boundary_certificate.
Proof.
  repeat split; try reflexivity.
  exact live_eyerok_hand_cannot_enter_movement_only_partial_guard.
Qed.
