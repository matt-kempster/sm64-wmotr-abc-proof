From Coq Require Import List ZArith.
From LessThanOneAPress.Proofs Require Import GameTypes.

Import ListNotations.
Local Open Scope Z_scope.

Definition valid_target_origin (s : GameState) (o : ObjectState) : Prop :=
  (active_star_or_key act3_index o ->
     object_origin o = StaticAct3PyramidStar /\
     object_ref_equal (object_ref o) (state_static_act3_ref s) /\
     object_area o = pyramid_area_id /\
     object_position o = act3_static_position /\
     object_hitbox o = collect_star_hitbox) /\
  (active_star_or_key act6_index o ->
     object_origin o = PyramidHiddenStarController /\
     object_parent_ref o = Some (state_hidden_controller_ref s) /\
     object_area o = pyramid_area_id /\
     object_home_position o = hidden_controller_position /\
     object_hitbox o = collect_star_hitbox).

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
    object_ref_equal (object_ref o) (state_static_act3_ref s) /\
    object_area o = pyramid_area_id /\
    object_position o = act3_static_position /\
    object_hitbox o = collect_star_hitbox.

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
    object_origin o = PyramidHiddenStarController /\
    object_ref_equal
      (object_ref o) (state_hidden_controller_ref s) /\
    object_area o = pyramid_area_id /\
    object_position o = hidden_controller_position.

Definition macro_spawn_state_valid (s : GameState) : Prop :=
  forall trigger,
    In trigger all_hidden_triggers ->
    state_macro_respawn_state s trigger = state_triggers s trigger.

Definition valid_hidden_trigger_object
    (s : GameState) (trigger : HiddenTrigger) (o : ObjectState) : Prop :=
  In trigger all_hidden_triggers /\
  In o (state_object_pool s) /\
  active_object o /\
  object_behavior o = BehaviorHiddenStarTrigger /\
  object_origin o = PyramidMacroTrigger /\
  object_trigger_kind o = Some trigger /\
  object_ref_equal (object_ref o) (state_hidden_trigger_refs s trigger) /\
  object_area o = pyramid_area_id /\
  object_position o = hidden_trigger_position trigger /\
  object_hitbox o = hidden_trigger_hitbox /\
  state_triggers s trigger = false /\
  state_macro_respawn_state s trigger = false /\
  object_macro_respawn_consumed o = false.

(* This projection invariant makes the macro preset identity explicit.  In
   particular an arbitrary trigger-shaped object cannot be relabeled as the
   upper trigger merely because Mario overlaps it. *)
Definition hidden_trigger_provenance (s : GameState) : Prop :=
  forall o,
    In o (state_object_pool s) ->
    active_object o ->
    object_behavior o = BehaviorHiddenStarTrigger ->
    exists trigger, valid_hidden_trigger_object s trigger o.

Definition all_hidden_trigger_objects_present (s : GameState) : Prop :=
  forall trigger,
    In trigger all_hidden_triggers ->
    exists o, valid_hidden_trigger_object s trigger o.

Definition hidden_trigger_refs_distinct (s : GameState) : Prop :=
  forall first second,
    In first all_hidden_triggers ->
    In second all_hidden_triggers ->
    first <> second ->
    ~ object_ref_equal
        (state_hidden_trigger_refs s first)
        (state_hidden_trigger_refs s second).

Definition no_active_hidden_trigger_kind
    (s : GameState) (trigger : HiddenTrigger) : Prop :=
  forall o,
    In o (state_object_pool s) ->
    active_object o ->
    object_behavior o = BehaviorHiddenStarTrigger ->
    object_trigger_kind o = Some trigger ->
    False.

Theorem valid_upper_trigger_has_static_identity :
  forall s o,
    valid_hidden_trigger_object s TriggerUpper o ->
    object_trigger_kind o = Some TriggerUpper /\
    object_ref_equal
      (object_ref o) (state_hidden_trigger_refs s TriggerUpper) /\
    object_position o = hidden_trigger_position TriggerUpper.
Proof.
  intros s o
    (_ & _ & _ & _ & _ & Hkind & Href & _ & Hposition & _).
  exact (conj Hkind (conj Href Hposition)).
Qed.

Theorem consumed_trigger_has_no_active_object :
  forall s trigger,
    hidden_trigger_provenance s ->
    state_triggers s trigger = true ->
    no_active_hidden_trigger_kind s trigger.
Proof.
  intros s trigger Hprovenance Hconsumed
    o Hin Hactive Hbehavior Hkind.
  destruct (Hprovenance o Hin Hactive Hbehavior)
    as (actual & _ & _ & _ & _ & _ & Hactual_kind & _ & _ &
        _ & _ & Hactual_clear & _).
  rewrite Hkind in Hactual_kind.
  inversion Hactual_kind; subst actual.
  rewrite Hconsumed in Hactual_clear.
  discriminate.
Qed.

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
    exact (proj1 (proj2 (Hprov o Hin) Hactive)).
Qed.
