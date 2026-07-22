From Coq Require Import Bool List ZArith.
From LessThanOneAPress.Proofs Require Import
  GameTypes ObjectProvenance CollisionRegions.

Import ListNotations.
Local Open Scope Z_scope.

Inductive FrameEvent :=
| EventOrdinary
| EventSpawnAct3 (star : ObjectState)
| EventSpawnAct6 (star : ObjectState)
| EventConsumeTrigger
    (trigger : HiddenTrigger) (trigger_object : ObjectState)
    (phase : CollisionPhase)
| EventCollectAct3 (star : ObjectState) (phase : CollisionPhase)
| EventCollectAct6 (star : ObjectState) (phase : CollisionPhase)
| EventCollectOther (index : Z)
| EventDeactivate (object : ObjectRef)
| EventReuseSlot (old_object new_object : ObjectState)
| EventMacroRespawn
| EventAreaUnload
| EventAreaReload
| EventInstantWarp2To3
| EventInstantWarp3To2
| EventCollisionRefresh.

Inductive non_target_event : FrameEvent -> Prop :=
| NonTargetOrdinary : non_target_event EventOrdinary
| NonTargetCollectOther : forall index,
    index <> act3_index -> index <> act6_index ->
    non_target_event (EventCollectOther index)
| NonTargetDeactivate : forall object,
    non_target_event (EventDeactivate object)
| NonTargetReuse : forall old_object new_object,
    fresh_slot_reuse old_object new_object ->
    non_target_event (EventReuseSlot old_object new_object)
| NonTargetMacroRespawn : non_target_event EventMacroRespawn
| NonTargetAreaUnload : non_target_event EventAreaUnload
| NonTargetAreaReload : non_target_event EventAreaReload
| NonTargetWarp23 : non_target_event EventInstantWarp2To3
| NonTargetWarp32 : non_target_event EventInstantWarp3To2
| NonTargetCollisionRefresh : non_target_event EventCollisionRefresh.

Definition target_bits_preserved (before after : GameState) : Prop :=
  star_bit (state_save_flags after) act3_index =
    star_bit (state_save_flags before) act3_index /\
  star_bit (state_save_flags after) act6_index =
    star_bit (state_save_flags before) act6_index.

Definition puzzle_history_preserved (before after : GameState) : Prop :=
  state_puzzle_star_spawned after = state_puzzle_star_spawned before /\
  forall trigger,
    state_triggers after trigger = state_triggers before trigger.

Definition frame_well_formed (s : GameState) : Prop :=
  state_pool_well_formed s = true /\
  state_lists_well_formed s = true /\
  target_provenance s /\
  valid_platform_state s.

Inductive CertifiedStep : GameState -> FrameEvent -> GameState -> Prop :=
| StepNonTarget : forall before after event,
    non_target_event event ->
    target_bits_preserved before after ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before event after
| StepSpawnAct3 : forall before after star,
    active_star_or_key act3_index star ->
    object_origin star = StaticAct3PyramidStar ->
    object_ref_equal (object_ref star) (state_static_act3_ref after) ->
    In star (state_object_pool after) ->
    target_bits_preserved before after ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before (EventSpawnAct3 star) after
| StepSpawnAct6 : forall before after star,
    active_star_or_key act6_index star ->
    object_origin star = PyramidHiddenStarController ->
    In star (state_object_pool after) ->
    all_five_consumed (state_triggers before) ->
    state_puzzle_star_spawned before = false ->
    state_puzzle_star_spawned after = true ->
    (forall trigger,
      state_triggers after trigger = state_triggers before trigger) ->
    target_bits_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before (EventSpawnAct6 star) after
| StepConsumeTrigger : forall before after trigger trigger_object phase,
    In trigger all_hidden_triggers ->
    In trigger_object (state_object_pool before) ->
    active_object trigger_object ->
    object_behavior trigger_object = BehaviorHiddenStarTrigger ->
    object_origin trigger_object = PyramidMacroTrigger ->
    overlaps_object phase trigger_object ->
    (trigger = TriggerUpper ->
      upper_hidden_trigger_overlap phase trigger_object) ->
    state_triggers before trigger = false ->
    state_triggers after trigger = true ->
    (forall other, other <> trigger ->
      state_triggers after other = state_triggers before other) ->
    state_puzzle_star_spawned after = state_puzzle_star_spawned before ->
    target_bits_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before
      (EventConsumeTrigger trigger trigger_object phase) after
| StepCollectAct3 : forall before after star phase,
    In star (state_object_pool before) ->
    active_star_or_key act3_index star ->
    object_origin star = StaticAct3PyramidStar ->
    object_ref_equal (object_ref star) (state_static_act3_ref before) ->
    act3_star_interaction_region phase star ->
    star_bit (state_save_flags after) act3_index = true ->
    star_bit (state_save_flags after) act6_index =
      star_bit (state_save_flags before) act6_index ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before (EventCollectAct3 star phase) after
| StepCollectAct6 : forall before after star phase,
    In star (state_object_pool before) ->
    active_star_or_key act6_index star ->
    object_origin star = PyramidHiddenStarController ->
    overlaps_object phase star ->
    state_puzzle_star_spawned before = true ->
    star_bit (state_save_flags after) act6_index = true ->
    star_bit (state_save_flags after) act3_index =
      star_bit (state_save_flags before) act3_index ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    CertifiedStep before (EventCollectAct6 star phase) after.

Inductive CertifiedExecution :
    GameState -> list FrameEvent -> GameState -> Prop :=
| ExecutionNil : forall state,
    CertifiedExecution state [] state
| ExecutionCons : forall before middle after event events,
    CertifiedStep before event middle ->
    CertifiedExecution middle events after ->
    CertifiedExecution before (event :: events) after.

Theorem instant_warp_preserves_target_provenance :
  forall before after event,
    (event = EventInstantWarp2To3 \/ event = EventInstantWarp3To2) ->
    CertifiedStep before event after ->
    target_provenance after.
Proof.
  intros before after event _ Hstep.
  inversion Hstep; subst; unfold frame_well_formed in *; intuition.
Qed.

Theorem area_reload_preserves_target_provenance :
  forall before after,
    CertifiedStep before EventAreaReload after ->
    target_provenance after.
Proof.
  intros before after Hstep.
  inversion Hstep; subst; unfold frame_well_formed in *; intuition.
Qed.

Theorem certified_step_has_valid_successor_platform_state :
  forall before event after,
    CertifiedStep before event after ->
    valid_platform_state after.
Proof.
  intros before event after Hstep.
  inversion Hstep; subst; unfold frame_well_formed in *; intuition.
Qed.
