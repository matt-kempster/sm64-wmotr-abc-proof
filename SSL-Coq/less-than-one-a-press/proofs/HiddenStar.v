From Coq Require Import Bool List ZArith.
From LessThanOneAPress.Proofs Require Import
  GameTypes CleanEntry CollisionRegions AreaTransitions StarCollection.

Import ListNotations.

Definition trigger_consumption_event
    (trigger : HiddenTrigger) (events : list FrameEvent) : Prop :=
  exists trigger_object phase,
    In (EventConsumeTrigger trigger trigger_object phase) events /\
    overlaps_object phase trigger_object.

Definition all_five_trigger_consumption_events
    (events : list FrameEvent) : Prop :=
  trigger_consumption_event TriggerLowerWest events /\
  trigger_consumption_event TriggerLowerEast events /\
  trigger_consumption_event TriggerMiddleWest events /\
  trigger_consumption_event TriggerMiddleNorth events /\
  trigger_consumption_event TriggerUpper events.

Lemma hidden_trigger_eq_dec :
  forall left right : HiddenTrigger, {left = right} + {left <> right}.
Proof. decide equality. Qed.

Lemma step_spawn6_or_history_preserved :
  forall before event after,
    CertifiedStep before event after ->
    (exists star,
      event = EventSpawnAct6 star /\
      active_star_or_key act6_index star /\
      object_origin star = PyramidHiddenStarController /\
      all_five_consumed (state_triggers before) /\
      state_puzzle_star_spawned after = true /\
      state_triggers after TriggerUpper = true) \/
    state_puzzle_star_spawned after = state_puzzle_star_spawned before.
Proof.
  intros before event after Hstep. inversion Hstep; subst.
  - right. unfold puzzle_history_preserved in H1. tauto.
  - right. unfold puzzle_history_preserved in H4. tauto.
  - left. exists star. split; [reflexivity|].
    refine (conj H (conj H0 (conj H2 (conj H4 _)))).
    rewrite (H5 TriggerUpper). apply H2. unfold all_hidden_triggers. simpl. tauto.
  - right. exact H9.
  - right. unfold puzzle_history_preserved in H6. tauto.
  - right. unfold puzzle_history_preserved in H6. tauto.
Qed.

Lemma step_upper_consumption_or_preserved :
  forall before event after,
    CertifiedStep before event after ->
    (exists trigger_object phase,
      event = EventConsumeTrigger TriggerUpper trigger_object phase /\
      upper_hidden_trigger_overlap phase trigger_object /\
      state_triggers after TriggerUpper = true) \/
    state_triggers after TriggerUpper = state_triggers before TriggerUpper.
Proof.
  intros before event after Hstep. inversion Hstep; subst.
  - right. destruct H1 as [_ Htriggers]. apply Htriggers.
  - right. destruct H4 as [_ Htriggers]. apply Htriggers.
  - right. apply H5.
  - destruct trigger.
    + right. apply H8. discriminate.
    + right. apply H8. discriminate.
    + right. apply H8. discriminate.
    + right. apply H8. discriminate.
    + left. exists trigger_object, phase. split; [reflexivity|]. split.
      * apply H5. reflexivity.
      * exact H7.
  - right. destruct H6 as [_ Htriggers]. apply Htriggers.
  - right. destruct H6 as [_ Htriggers]. apply Htriggers.
Qed.

Lemma step_trigger_consumption_or_preserved :
  forall watched before event after,
    CertifiedStep before event after ->
    (exists trigger_object phase,
      event = EventConsumeTrigger watched trigger_object phase /\
      overlaps_object phase trigger_object /\
      state_triggers after watched = true) \/
    state_triggers after watched = state_triggers before watched.
Proof.
  intros watched before event after Hstep.
  destruct Hstep as
    [ before after event Hnon_target Hbits Hpuzzle Hwf
    | before after star Hactive Horigin Hstatic Hin Hbits Hpuzzle Hwf
    | before after star Hactive Horigin Hin Hall Hnot_spawned Hspawned
        Htriggers Hbits Hwf
    | before after trigger trigger_object phase Hin_trigger Hin_object
        Hactive Hbehavior Horigin Hoverlap Hupper Hnot_consumed Hconsumed
        Hother Hspawned Hbits Hwf
    | before after star phase Hin Hactive Horigin Hstatic Hoverlap Hset
        Hother_bit Hpuzzle Hwf
    | before after star phase Hin Hactive Horigin Hoverlap Hspawned Hset
        Hother_bit Hpuzzle Hwf ].
  - right. apply (proj2 Hpuzzle watched).
  - right. apply (proj2 Hpuzzle watched).
  - right. apply Htriggers.
  - destruct (hidden_trigger_eq_dec watched trigger) as [->|Hdifferent].
    + left. exists trigger_object, phase. split; [reflexivity|].
      split; [exact Hoverlap|exact Hconsumed].
    + right. apply Hother. exact Hdifferent.
  - right. apply (proj2 Hpuzzle watched).
  - right. apply (proj2 Hpuzzle watched).
Qed.

Lemma execution_preserves_consumed_trigger :
  forall trigger initial events final,
    CertifiedExecution initial events final ->
    state_triggers initial trigger = true ->
    state_triggers final trigger = true.
Proof.
  intros trigger initial events final Hexec Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - exact Htrue.
  - apply IH.
    destruct (step_trigger_consumption_or_preserved
      trigger before event middle Hstep)
      as [(trigger_object & phase & Hevent & Hoverlap & Hbecame) | Hpreserved].
    + exact Hbecame.
    + rewrite Hpreserved. exact Htrue.
Qed.

Theorem trigger_change_requires_consumption_event :
  forall trigger initial events final,
    CertifiedExecution initial events final ->
    state_triggers initial trigger = false ->
    state_triggers final trigger = true ->
    trigger_consumption_event trigger events.
Proof.
  intros trigger initial events final Hexec Hfalse Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - rewrite Hfalse in Htrue. discriminate.
  - destruct (step_trigger_consumption_or_preserved
      trigger before event middle Hstep)
      as [(trigger_object & phase & -> & Hoverlap & Hbecame) | Hpreserved].
    + unfold trigger_consumption_event. exists trigger_object, phase.
      split; [simpl; auto|exact Hoverlap].
    + destruct (IH (eq_trans Hpreserved Hfalse) Htrue)
        as (found & found_phase & Hin & Hfound_overlap).
      unfold trigger_consumption_event. exists found, found_phase.
      split; [simpl; auto|exact Hfound_overlap].
Qed.

Lemma execution_preserves_consumed_upper :
  forall initial events final,
    CertifiedExecution initial events final ->
    state_triggers initial TriggerUpper = true ->
    state_triggers final TriggerUpper = true.
Proof.
  intros initial events final Hexec Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - exact Htrue.
  - apply IH.
    destruct (step_upper_consumption_or_preserved before event middle Hstep)
      as [(trigger_object & phase & Hevent & Hoverlap & Hbecame) | Hpreserved].
    + exact Hbecame.
    + rewrite Hpreserved. exact Htrue.
Qed.

Lemma execution_preserves_spawned_puzzle_star :
  forall initial events final,
    CertifiedExecution initial events final ->
    state_puzzle_star_spawned initial = true ->
    state_puzzle_star_spawned final = true.
Proof.
  intros initial events final Hexec Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - exact Htrue.
  - apply IH.
    destruct (step_spawn6_or_history_preserved before event middle Hstep)
      as [(star & Hevent & Hactive & Horigin & Hall & Hbecame & Hupper) | Hpreserved].
    + exact Hbecame.
    + rewrite Hpreserved. exact Htrue.
Qed.

Theorem puzzle_spawn_change_requires_spawn_event :
  forall initial events final,
    CertifiedExecution initial events final ->
    state_puzzle_star_spawned initial = false ->
    state_puzzle_star_spawned final = true ->
    (exists star,
      In (EventSpawnAct6 star) events /\
      active_star_or_key act6_index star /\
      object_origin star = PyramidHiddenStarController) /\
    state_triggers final TriggerUpper = true.
Proof.
  intros initial events final Hexec Hfalse Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - rewrite Hfalse in Htrue. discriminate.
  - destruct (step_spawn6_or_history_preserved before event middle Hstep)
      as [(star & -> & Hactive & Horigin & Hall & Hbecame & Hupper) | Hpreserved].
    + split.
      * exists star. split; [simpl; auto|]. exact (conj Hactive Horigin).
      * apply execution_preserves_consumed_upper with (initial := middle) (events := events).
        -- exact Htail.
        -- exact Hupper.
    + destruct (IH (eq_trans Hpreserved Hfalse) Htrue)
        as ((found & Hin & Hfound_active & Hfound_origin) & Hupper_final).
      split.
      * exists found. split; [simpl; auto|].
        exact (conj Hfound_active Hfound_origin).
      * exact Hupper_final.
Qed.

Theorem puzzle_spawn_change_requires_all_five_consumed :
  forall initial events final,
    CertifiedExecution initial events final ->
    state_puzzle_star_spawned initial = false ->
    state_puzzle_star_spawned final = true ->
    (exists star,
      In (EventSpawnAct6 star) events /\
      active_star_or_key act6_index star /\
      object_origin star = PyramidHiddenStarController) /\
    all_five_consumed (state_triggers final).
Proof.
  intros initial events final Hexec Hfalse Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - rewrite Hfalse in Htrue. discriminate.
  - destruct (step_spawn6_or_history_preserved before event middle Hstep)
      as [(star & -> & Hactive & Horigin & Hall & Hbecame & Hupper) | Hpreserved].
    + split.
      * exists star. split; [simpl; auto|]. exact (conj Hactive Horigin).
      * intros trigger Hin_trigger.
        eapply execution_preserves_consumed_trigger.
        -- exact Htail.
        -- apply Hall. exact Hin_trigger.
    + destruct (IH (eq_trans Hpreserved Hfalse) Htrue)
        as ((found & Hin & Hfound_active & Hfound_origin) & Hall_final).
      split.
      * exists found. split; [simpl; auto|].
        exact (conj Hfound_active Hfound_origin).
      * exact Hall_final.
Qed.

Theorem upper_trigger_change_requires_collision_event :
  forall initial events final,
    CertifiedExecution initial events final ->
    state_triggers initial TriggerUpper = false ->
    state_triggers final TriggerUpper = true ->
    exists trigger_object phase,
      In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
      upper_hidden_trigger_overlap phase trigger_object.
Proof.
  intros initial events final Hexec Hfalse Htrue.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - rewrite Hfalse in Htrue. discriminate.
  - destruct (step_upper_consumption_or_preserved before event middle Hstep)
      as [(trigger_object & phase & -> & Hoverlap & Hbecame) | Hpreserved].
    + exists trigger_object, phase. split; [simpl; auto|exact Hoverlap].
    + destruct (IH (eq_trans Hpreserved Hfalse) Htrue)
        as (found & found_phase & Hin & Hfound_overlap).
      exists found, found_phase. split; [simpl; auto|exact Hfound_overlap].
Qed.

Lemma newly_collected_act6_implies_spawned_final :
  forall initial events final,
    CertifiedExecution initial events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act6_index ->
    state_puzzle_star_spawned final = true.
Proof.
  intros initial events final Hexec Hnew.
  induction Hexec as [state|before middle after event events Hstep Htail IH].
  - destruct Hnew as [Hclear Hset]. rewrite Hclear in Hset. discriminate.
  - destruct Hnew as [Hclear Hset].
    destruct (step_act6_collection_or_preserved before event middle Hstep)
      as [(star & phase & Hevent & Hactive & Horigin & Hoverlap & Hspawned_middle) | Hpreserved].
    + subst event.
      apply execution_preserves_spawned_puzzle_star with
        (initial := middle) (events := events).
      * exact Htail.
      * exact Hspawned_middle.
    + apply IH. split; [rewrite Hpreserved; exact Hclear|exact Hset].
Qed.

Theorem act6_spawn_from_clean_requires_all_five_trigger_consumptions :
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    state_puzzle_star_spawned final = true ->
    all_five_trigger_consumption_events events.
Proof.
  intros initial events final Hclean Hexec Hspawned.
  destruct (puzzle_spawn_change_requires_all_five_consumed
    initial events final Hexec
    (clean_puzzle_not_spawned initial Hclean) Hspawned)
    as (Hspawn_event & Hall_final).
  assert (Heach : forall trigger,
    In trigger all_hidden_triggers ->
    trigger_consumption_event trigger events).
  { intros trigger Hin_trigger.
    eapply trigger_change_requires_consumption_event; eauto.
    - apply clean_triggers. exact Hclean.
    - apply Hall_final. exact Hin_trigger. }
  unfold all_five_trigger_consumption_events.
  repeat split; apply Heach; simpl; auto.
Qed.

Theorem newly_collected_act6_from_clean_requires_all_five_trigger_consumptions :
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act6_index ->
    all_five_trigger_consumption_events events.
Proof.
  intros initial events final Hclean Hexec Hnew.
  eapply act6_spawn_from_clean_requires_all_five_trigger_consumptions; eauto.
  eapply newly_collected_act6_implies_spawned_final; eauto.
Qed.

Theorem spawning_act6_requires_all_five_and_upper_overlap :
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    newly_collected
      (state_save_flags initial) (state_save_flags final) act6_index ->
    (exists spawn_star,
      In (EventSpawnAct6 spawn_star) events) /\
    (exists trigger_object phase,
      In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
      upper_hidden_trigger_overlap phase trigger_object).
Proof.
  intros initial events final Hclean Hexec Hnew.
  assert (Hspawned : state_puzzle_star_spawned final = true).
  { eapply newly_collected_act6_implies_spawned_final; eauto. }
  destruct (puzzle_spawn_change_requires_spawn_event
    initial events final Hexec
    (clean_puzzle_not_spawned initial Hclean) Hspawned)
    as ((spawn_star & Hspawn & Hactive & Horigin) & Hupper).
  split.
  - exists spawn_star. exact Hspawn.
  - eapply upper_trigger_change_requires_collision_event; eauto.
    apply clean_triggers. exact Hclean.
Qed.
