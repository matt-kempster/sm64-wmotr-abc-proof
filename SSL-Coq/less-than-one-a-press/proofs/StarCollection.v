From Coq Require Import Bool List ZArith.
From LessThanOneAPress.Proofs Require Import
  GameTypes ObjectProvenance CollisionRegions AreaTransitions.

Import ListNotations.
Local Open Scope Z_scope.

Lemma step_act3_collection_or_preserved :
  forall before event after,
    CertifiedStep before event after ->
    (exists star phase,
      event = EventCollectAct3 star phase /\
      active_star_or_key act3_index star /\
      object_origin star = StaticAct3PyramidStar /\
      act3_star_interaction_region phase star) \/
    star_bit (state_save_flags after) act3_index =
      star_bit (state_save_flags before) act3_index.
Proof.
  intros before event after Hstep.
  inversion Hstep; subst.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj1 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj1 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj1 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj1 H)
    end.
  - left. exists star, phase. split; [reflexivity |].
    exact (conj H0 (conj H1 H3)).
  - right. assumption.
Qed.

Lemma step_act6_collection_or_preserved :
  forall before event after,
    CertifiedStep before event after ->
    (exists star phase,
      event = EventCollectAct6 star phase /\
      active_star_or_key act6_index star /\
      object_origin star = PyramidHiddenStarController /\
      overlaps_object phase star /\
      state_puzzle_star_spawned after = true) \/
    star_bit (state_save_flags after) act6_index =
      star_bit (state_save_flags before) act6_index.
Proof.
  intros before event after Hstep.
  inversion Hstep; subst.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj2 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj2 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj2 H)
    end.
  - right. match goal with
      H : target_bits_preserved _ _ |- _ => exact (proj2 H)
    end.
  - right. assumption.
  - left. exists star, phase. split; [reflexivity|].
    refine (conj H0 (conj H1 (conj H2 _))).
    destruct H6 as [Hspawned _]. exact (eq_trans Hspawned H3).
Qed.

Theorem newly_collected_act3_requires_collection_event :
  forall initial events final,
    CertifiedExecution initial events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act3_index ->
    exists star phase,
      In (EventCollectAct3 star phase) events /\
      active_star_or_key act3_index star /\
      object_origin star = StaticAct3PyramidStar /\
      act3_star_interaction_region phase star.
Proof.
  intros initial events final Hexec Hnew.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - destruct Hnew as [Hclear Hset]. rewrite Hclear in Hset. discriminate.
  - destruct Hnew as [Hclear Hset].
    destruct (step_act3_collection_or_preserved before event middle Hstep)
      as [(star & phase & -> & Hactive & Horigin & Hoverlap) | Hpreserve].
    + exists star, phase. split; [simpl; auto|].
      exact (conj Hactive (conj Horigin Hoverlap)).
    + specialize (IH (conj (eq_trans Hpreserve Hclear) Hset)).
      destruct IH as (star & phase & Hin & Hactive & Horigin & Hoverlap).
      exists star, phase. split; [simpl; auto|].
      exact (conj Hactive (conj Horigin Hoverlap)).
Qed.

Theorem newly_collected_act6_requires_collection_event :
  forall initial events final,
    CertifiedExecution initial events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act6_index ->
    exists star phase,
      In (EventCollectAct6 star phase) events /\
      active_star_or_key act6_index star /\
      object_origin star = PyramidHiddenStarController /\
      overlaps_object phase star.
Proof.
  intros initial events final Hexec Hnew.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - destruct Hnew as [Hclear Hset]. rewrite Hclear in Hset. discriminate.
  - destruct Hnew as [Hclear Hset].
    destruct (step_act6_collection_or_preserved before event middle Hstep)
      as [(star & phase & -> & Hactive & Horigin & Hoverlap & Hspawned) | Hpreserve].
    + exists star, phase. split; [simpl; auto|].
      exact (conj Hactive (conj Horigin Hoverlap)).
    + specialize (IH (conj (eq_trans Hpreserve Hclear) Hset)).
      destruct IH as (star & phase & Hin & Hactive & Horigin & Hoverlap).
      exists star, phase. split; [simpl; auto|].
      exact (conj Hactive (conj Horigin Hoverlap)).
Qed.

Theorem hundred_coin_event_is_not_a_target_collection :
  hundred_coin_index <> act3_index /\ hundred_coin_index <> act6_index.
Proof. vm_compute. split; discriminate. Qed.
