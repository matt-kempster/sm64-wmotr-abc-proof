From Coq Require Import Bool List ZArith.
From LessThanOneAPress.Proofs Require Import
  GameTypes ObjectProvenance CollisionRegions.

Import ListNotations.
Local Open Scope Z_scope.

Inductive MarioMotionKind :=
| MotionPhysicsFrame
| MotionPlatformDisplacement
| MotionObjectPush
| MotionCollisionClip.

Inductive FrameEvent :=
| EventOrdinary
| EventMarioMotion
    (kind : MarioMotionKind)
    (before_kinematics after_kinematics : MarioKinematics)
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
| EventSaveFileReload
| EventInstantWarp2To3
| EventInstantWarp3To2
| EventCollisionRefresh.

Inductive non_target_event : FrameEvent -> Prop :=
| NonTargetOrdinary : non_target_event EventOrdinary
| NonTargetMarioMotion : forall kind before_kinematics after_kinematics,
    non_target_event
      (EventMarioMotion kind before_kinematics after_kinematics)
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
| NonTargetSaveFileReload : non_target_event EventSaveFileReload
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

(* This immutable source context must not be replaced by an unrelated entry,
   object allocation, or macro-object table during a non-target step. *)
Definition route_context_preserved (before after : GameState) : Prop :=
  state_version after = state_version before /\
  state_entrance after = state_entrance before /\
  state_level after = state_level before /\
  state_course after = state_course before /\
  state_act after = state_act before /\
  state_entry_snapshot after = state_entry_snapshot before.

(* Reloading or macro respawning creates new allocations and therefore may
   advance the ghost epochs.  Other non-target steps cannot silently swap the
   designated Act 3 or trigger allocations. *)
Definition non_target_allocation_effect
    (event : FrameEvent) (before after : GameState) : Prop :=
  match event with
  | EventAreaReload => True
  | EventMacroRespawn =>
      object_ref_equal
        (state_static_act3_ref after) (state_static_act3_ref before) /\
      object_ref_equal
        (state_hidden_controller_ref after)
        (state_hidden_controller_ref before)
  | _ =>
      object_ref_equal
        (state_static_act3_ref after) (state_static_act3_ref before) /\
      object_ref_equal
        (state_hidden_controller_ref after)
        (state_hidden_controller_ref before) /\
      state_hidden_trigger_refs after = state_hidden_trigger_refs before
  end.

Definition kinematic_core_equal
    (after before : MarioKinematics) : Prop :=
  mario_position after = mario_position before /\
  mario_velocity after = mario_velocity before /\
  mario_forward_velocity after = mario_forward_velocity before /\
  mario_action after = mario_action before /\
  mario_room after = mario_room before.

(* Ordinary/admin events cannot silently teleport Mario.  A genuine gameplay
   movement is exposed as EventMarioMotion with both endpoint snapshots.  The
   zero-displacement area-2/area-3 instant warp preserves position, velocity,
   action, and room while permitting the floor reference to be refreshed. *)
Definition non_target_spatial_effect
    (event : FrameEvent) (before after : GameState) : Prop :=
  match event with
  | EventMarioMotion _ from_kinematics to_kinematics =>
      state_mario_kinematics before = from_kinematics /\
      state_mario_kinematics after = to_kinematics /\
      state_area after = state_area before
  | EventInstantWarp2To3 =>
      state_area before = pyramid_area_id /\
      state_area after = pyramid_boss_area_id /\
      kinematic_core_equal
        (state_mario_kinematics after) (state_mario_kinematics before)
  | EventInstantWarp3To2 =>
      state_area before = pyramid_boss_area_id /\
      state_area after = pyramid_area_id /\
      kinematic_core_equal
        (state_mario_kinematics after) (state_mario_kinematics before)
  | EventAreaReload =>
      (state_area after = state_area before /\
       state_mario_kinematics after = state_mario_kinematics before) \/
      (state_area after = pyramid_area_id /\
       state_mario_kinematics after =
         entry_kinematics (state_entry_snapshot after))
  | _ =>
      state_area after = state_area before /\
      state_mario_kinematics after = state_mario_kinematics before
  end.

(* save_file_reload copies the backup slot.  All other non-target events
   preserve the two target bits in the backup. *)
Definition non_target_save_effect
    (event : FrameEvent) (before after : GameState) : Prop :=
  match event with
  | EventSaveFileReload =>
      state_save_flags after = state_backup_save_flags before /\
      state_backup_save_flags after = state_backup_save_flags before /\
      target_save_coherent before
  | _ =>
      star_bit (state_backup_save_flags after) act3_index =
        star_bit (state_backup_save_flags before) act3_index /\
      star_bit (state_backup_save_flags after) act6_index =
        star_bit (state_backup_save_flags before) act6_index
  end.

Definition frame_well_formed (s : GameState) : Prop :=
  state_pool_well_formed s = true /\
  state_lists_well_formed s = true /\
  target_provenance s /\
  hidden_trigger_provenance s /\
  hidden_trigger_refs_distinct s /\
  macro_spawn_state_valid s /\
  valid_platform_state s /\
  entry_snapshot_for (state_entrance s) (state_entry_snapshot s).

Inductive CertifiedStep : GameState -> FrameEvent -> GameState -> Prop :=
| StepNonTarget : forall before after event,
    non_target_event event ->
    target_bits_preserved before after ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    route_context_preserved before after ->
    non_target_allocation_effect event before after ->
    non_target_spatial_effect event before after ->
    non_target_save_effect event before after ->
    CertifiedStep before event after
| StepSpawnAct3 : forall before after star,
    active_star_or_key act3_index star ->
    object_origin star = StaticAct3PyramidStar ->
    object_ref_equal (object_ref star) (state_static_act3_ref after) ->
    In star (state_object_pool after) ->
    target_bits_preserved before after ->
    puzzle_history_preserved before after ->
    frame_well_formed after ->
    object_position star = act3_static_position ->
    object_area star = pyramid_area_id ->
    object_hitbox star = collect_star_hitbox ->
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
    hidden_controller_present before ->
    state_hidden_controller_ref after = state_hidden_controller_ref before ->
    object_parent_ref star = Some (state_hidden_controller_ref before) ->
    object_area star = pyramid_area_id ->
    object_position star = hidden_controller_position ->
    object_home_position star = hidden_controller_position ->
    object_hitbox star = collect_star_hitbox ->
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
    valid_hidden_trigger_object before trigger trigger_object ->
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

Theorem save_file_reload_effect_preserves_target_bits :
  forall before after,
    non_target_save_effect EventSaveFileReload before after ->
    target_bits_preserved before after.
Proof.
  intros before after (Hactive & _ & Hcoherent).
  unfold target_bits_preserved, target_save_coherent in *.
  rewrite Hactive.
  split; symmetry.
  - exact (proj1 Hcoherent).
  - exact (proj2 Hcoherent).
Qed.

Theorem certified_save_file_reload_cannot_introduce_target_bit :
  forall before after,
    CertifiedStep before EventSaveFileReload after ->
    target_bits_preserved before after.
Proof.
  intros before after Hstep.
  inversion Hstep; subst.
  match goal with
  | H : target_bits_preserved _ _ |- _ => exact H
  end.
Qed.

Theorem upper_consumption_uses_designated_static_trigger :
  forall before after trigger_object phase,
    CertifiedStep before
      (EventConsumeTrigger TriggerUpper trigger_object phase) after ->
    object_trigger_kind trigger_object = Some TriggerUpper /\
    object_ref_equal
      (object_ref trigger_object)
      (state_hidden_trigger_refs before TriggerUpper) /\
    object_position trigger_object =
      hidden_trigger_position TriggerUpper.
Proof.
  intros before after trigger_object phase Hstep.
  inversion Hstep; subst.
  - inversion H.
  - eapply valid_upper_trigger_has_static_identity; eassumption.
Qed.

Theorem instant_warp_has_zero_displacement_core :
  forall before after event,
    (event = EventInstantWarp2To3 \/ event = EventInstantWarp3To2) ->
    CertifiedStep before event after ->
    kinematic_core_equal
      (state_mario_kinematics after) (state_mario_kinematics before).
Proof.
  intros before after event [-> | ->] Hstep;
    inversion Hstep; subst;
    match goal with
    | H : non_target_spatial_effect _ _ _ |- _ =>
        unfold non_target_spatial_effect in H; tauto
    end.
Qed.

Theorem frame_has_valid_macro_respawn_state :
  forall s,
    frame_well_formed s ->
    macro_spawn_state_valid s.
Proof.
  intros s Hframe.
  unfold frame_well_formed in Hframe.
  tauto.
Qed.

Theorem frame_consumed_trigger_has_no_active_object :
  forall s trigger,
    frame_well_formed s ->
    state_triggers s trigger = true ->
    no_active_hidden_trigger_kind s trigger.
Proof.
  intros s trigger Hframe Hconsumed.
  eapply consumed_trigger_has_no_active_object.
  - unfold frame_well_formed in Hframe. tauto.
  - exact Hconsumed.
Qed.

Theorem consumed_trigger_successor_updates_macro_and_deactivates_kind :
  forall before after trigger trigger_object phase,
    CertifiedStep before
      (EventConsumeTrigger trigger trigger_object phase) after ->
    state_macro_respawn_state after trigger = true /\
    no_active_hidden_trigger_kind after trigger.
Proof.
  intros before after trigger trigger_object phase Hstep.
  inversion Hstep; subst.
  - inversion H.
  - split.
    + pose proof (frame_has_valid_macro_respawn_state after H16)
        as Hmacro.
      rewrite (Hmacro trigger H2).
      exact H10.
    + eapply frame_consumed_trigger_has_no_active_object.
      * exact H16.
      * exact H10.
Qed.

Theorem act6_spawn_uses_designated_controller_lineage :
  forall before after star,
    CertifiedStep before (EventSpawnAct6 star) after ->
    hidden_controller_present before /\
    state_hidden_controller_ref after = state_hidden_controller_ref before /\
    object_parent_ref star = Some (state_hidden_controller_ref before) /\
    object_area star = pyramid_area_id /\
    object_position star = hidden_controller_position /\
    object_home_position star = hidden_controller_position /\
    object_hitbox star = collect_star_hitbox.
Proof.
  intros before after star Hstep.
  inversion Hstep; subst.
  - inversion H.
  - repeat split; assumption.
Qed.

Theorem non_target_step_does_not_revive_consumed_trigger :
  forall before after event trigger,
    non_target_event event ->
    CertifiedStep before event after ->
    state_triggers before trigger = true ->
    state_macro_respawn_state after trigger = true /\
    no_active_hidden_trigger_kind after trigger.
Proof.
  intros before after event trigger Hnon_target Hstep Hconsumed.
  inversion Hstep; subst.
  - assert (Hafter : state_triggers after trigger = true).
    { match goal with
      | Hhistory : puzzle_history_preserved before after |- _ =>
          rewrite (proj2 Hhistory trigger); exact Hconsumed
      end. }
    split.
    + match goal with
      | Hframe : frame_well_formed after |- _ =>
          pose proof (frame_has_valid_macro_respawn_state after Hframe)
            as Hmacro;
          rewrite (Hmacro trigger);
          [exact Hafter |
           destruct trigger; unfold all_hidden_triggers; simpl; tauto]
      end.
    + match goal with
      | Hframe : frame_well_formed after |- _ =>
          exact (frame_consumed_trigger_has_no_active_object
            after trigger Hframe Hafter)
      end.
  - inversion Hnon_target.
  - inversion Hnon_target.
  - inversion Hnon_target.
  - inversion Hnon_target.
  - inversion Hnon_target.
Qed.

Theorem reload_and_macro_respawn_preserve_consumed_trigger_absence :
  forall before after event trigger,
    (event = EventAreaReload \/ event = EventMacroRespawn) ->
    CertifiedStep before event after ->
    state_triggers before trigger = true ->
    state_macro_respawn_state after trigger = true /\
    no_active_hidden_trigger_kind after trigger.
Proof.
  intros before after event trigger [-> | ->] Hstep Hconsumed;
    eapply non_target_step_does_not_revive_consumed_trigger; eauto;
    constructor.
Qed.
