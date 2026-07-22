From Coq Require Import List ZArith.
From LessThanOneAPress.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

Definition valid_target_origin (s : GameState) (o : ObjectState) : Prop :=
  (active_star_or_key act3_index o ->
     object_origin o = StaticAct3PyramidStar /\
     object_ref_equal (object_ref o) (state_static_act3_ref s)) /\
  (active_star_or_key act6_index o ->
     object_origin o = PyramidHiddenStarController).

Definition target_provenance (s : GameState) : Prop :=
  forall o, In o (state_object_pool s) -> valid_target_origin s o.

Definition no_preexisting_act6_star (s : GameState) : Prop :=
  forall o, In o (state_object_pool s) -> ~ active_star_or_key act6_index o.

Definition same_pool_slot (old_object new_object : ObjectState) : Prop :=
  object_slot (object_ref old_object) = object_slot (object_ref new_object).

Definition fresh_slot_reuse (old_object new_object : ObjectState) : Prop :=
  same_pool_slot old_object new_object /\
  (object_epoch (object_ref old_object) <
   object_epoch (object_ref new_object))%nat.

Theorem fresh_slot_reuse_is_not_object_identity :
  forall old_object new_object,
    fresh_slot_reuse old_object new_object ->
    ~ object_ref_equal (object_ref old_object) (object_ref new_object).
Proof.
  intros old_object new_object [_ Hepoch] [_ Hsame_epoch].
  rewrite Hsame_epoch in Hepoch.
  apply (Nat.lt_irrefl _ Hepoch).
Qed.

Definition act3_static_object_present (s : GameState) : Prop :=
  exists o,
    In o (state_object_pool s) /\
    active_star_or_key act3_index o /\
    object_origin o = StaticAct3PyramidStar /\
    object_ref_equal (object_ref o) (state_static_act3_ref s).

Definition no_preexisting_act3_substitute (s : GameState) : Prop :=
  forall o,
    In o (state_object_pool s) ->
    active_star_or_key act3_index o ->
    object_ref_equal (object_ref o) (state_static_act3_ref s).

Definition hidden_controller_present (s : GameState) : Prop :=
  exists o,
    In o (state_object_pool s) /\
    active_object o /\
    object_behavior o = BehaviorHiddenStarController /\
    object_star_index o = Some act6_index /\
    object_origin o = PyramidHiddenStarController.

Theorem target_object_has_required_origin :
  forall s o index,
    target_provenance s ->
    In o (state_object_pool s) ->
    active_star_or_key index o ->
    index = act3_index \/ index = act6_index ->
    (index = act3_index /\ object_origin o = StaticAct3PyramidStar) \/
    (index = act6_index /\ object_origin o = PyramidHiddenStarController).
Proof.
  intros s o index Hprov Hin Hactive [-> | ->].
  - left. split; [reflexivity|].
    exact (proj1 (proj1 (Hprov o Hin) Hactive)).
  - right. split; [reflexivity|].
    apply (proj2 (Hprov o Hin)); exact Hactive.
Qed.
