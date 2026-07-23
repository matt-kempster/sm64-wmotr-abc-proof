(* Executable audit of two deliberately open abstraction boundaries.

   These theorems are negative results about the current handwritten
   [CertifiedStep] relation.  They are not counterexamples to either retail
   ROM.  In particular they explain why a Clight-to-event refinement must
   connect every motion endpoint and every collision phase to the same
   concrete frame state before the route theorem can use [CertifiedExecution].
*)

From Coq Require Import Lia List ZArith.
From compcert Require Import Integers.
From LessThanOneAPress.Proofs Require Import
  GameTypes ObjectProvenance CollisionRegions CleanEntry AreaTransitions.

Import ListNotations.
Local Open Scope Z_scope.

Definition with_mario_kinematics
    (state : GameState) (kinematics : MarioKinematics) : GameState :=
  {| state_version := state_version state;
     state_entrance := state_entrance state;
     state_level := state_level state;
     state_course := state_course state;
     state_act := state_act state;
     state_area := state_area state;
     state_save_flags := state_save_flags state;
     state_backup_save_flags := state_backup_save_flags state;
     state_object_pool := state_object_pool state;
     state_static_act3_ref := state_static_act3_ref state;
     state_hidden_controller_ref := state_hidden_controller_ref state;
     state_hidden_trigger_refs := state_hidden_trigger_refs state;
     state_triggers := state_triggers state;
     state_puzzle_star_spawned := state_puzzle_star_spawned state;
     state_macro_respawn_state := state_macro_respawn_state state;
     state_pool_well_formed := state_pool_well_formed state;
     state_lists_well_formed := state_lists_well_formed state;
     state_pending_star_interaction :=
       state_pending_star_interaction state;
     state_delayed_star_exit := state_delayed_star_exit state;
     state_entry_button_down := state_entry_button_down state;
     state_first_frame_previous_down_seed :=
       state_first_frame_previous_down_seed state;
     state_mario_platform := state_mario_platform state;
     state_entry_snapshot := state_entry_snapshot state;
     state_mario_kinematics := kinematics |}.

Definition with_save_flags
    (state : GameState) (flags : Int.int) : GameState :=
  {| state_version := state_version state;
     state_entrance := state_entrance state;
     state_level := state_level state;
     state_course := state_course state;
     state_act := state_act state;
     state_area := state_area state;
     state_save_flags := flags;
     state_backup_save_flags := state_backup_save_flags state;
     state_object_pool := state_object_pool state;
     state_static_act3_ref := state_static_act3_ref state;
     state_hidden_controller_ref := state_hidden_controller_ref state;
     state_hidden_trigger_refs := state_hidden_trigger_refs state;
     state_triggers := state_triggers state;
     state_puzzle_star_spawned := state_puzzle_star_spawned state;
     state_macro_respawn_state := state_macro_respawn_state state;
     state_pool_well_formed := state_pool_well_formed state;
     state_lists_well_formed := state_lists_well_formed state;
     state_pending_star_interaction :=
       state_pending_star_interaction state;
     state_delayed_star_exit := state_delayed_star_exit state;
     state_entry_button_down := state_entry_button_down state;
     state_first_frame_previous_down_seed :=
       state_first_frame_previous_down_seed state;
     state_mario_platform := state_mario_platform state;
     state_entry_snapshot := state_entry_snapshot state;
     state_mario_kinematics := state_mario_kinematics state |}.

Lemma clean_entry_is_frame_well_formed :
  forall state,
    CleanPyramidEntry state ->
    frame_well_formed state.
Proof.
  intros state Hclean.
  unfold frame_well_formed.
  exact
    (conj (clean_pool state Hclean)
      (conj (clean_lists state Hclean)
        (conj (clean_target_provenance state Hclean)
          (conj (clean_hidden_trigger_provenance state Hclean)
            (conj (clean_hidden_trigger_refs_distinct state Hclean)
              (conj (clean_macro_spawn state Hclean)
                (conj (clean_platform state Hclean)
                  (clean_entry_snapshot state Hclean)))))))).
Qed.

Lemma frame_well_formed_with_mario_kinematics :
  forall state kinematics,
    frame_well_formed state ->
    frame_well_formed (with_mario_kinematics state kinematics).
Proof.
  intros state kinematics Hframe.
  exact Hframe.
Qed.

Lemma frame_well_formed_with_save_flags :
  forall state flags,
    frame_well_formed state ->
    frame_well_formed (with_save_flags state flags).
Proof.
  intros state flags Hframe.
  exact Hframe.
Qed.

(* The current abstract relation accepts every endpoint for a physics event.
   No gravity, action, surface, Float32, or Clight premise constrains
   [arbitrary_endpoint]. *)
Theorem current_certified_motion_accepts_arbitrary_endpoint :
  forall state arbitrary_endpoint,
    CleanPyramidEntry state ->
    CertifiedStep state
      (EventMarioMotion MotionPhysicsFrame
        (state_mario_kinematics state) arbitrary_endpoint)
      (with_mario_kinematics state arbitrary_endpoint).
Proof.
  intros state arbitrary_endpoint Hclean.
  eapply StepNonTarget.
  - constructor.
  - unfold target_bits_preserved. cbn. tauto.
  - unfold puzzle_history_preserved. cbn. tauto.
  - apply frame_well_formed_with_mario_kinematics.
    exact (clean_entry_is_frame_well_formed state Hclean).
  - unfold route_context_preserved. cbn. tauto.
  - unfold non_target_allocation_effect. cbn.
    unfold object_ref_equal. repeat split.
  - unfold non_target_spatial_effect. cbn. tauto.
  - unfold non_target_save_effect. cbn. tauto.
Qed.

Definition synthetic_act3_collision_phase
    (star : ObjectState) : CollisionPhase :=
  {| collision_player_ref := object_ref star;
     collision_mario_ref := object_ref star;
     collision_target_ref := object_ref star;
     collision_mario_position := act3_static_position;
     collision_target_position := act3_static_position;
     collision_mario_hitbox := collect_star_hitbox;
     collision_target_hitbox := collect_star_hitbox;
     collision_mario_count_before := Int.zero;
     collision_target_count_before := Int.zero;
     collision_pair_registered := true;
     collision_after_platform_displacement := true;
     collision_before_behavior_update := true;
     collision_area := pyramid_area_id;
     collision_instant_warp_pending := false |}.

Lemma synthetic_act3_phase_overlaps_static_star :
  forall star,
    object_position star = act3_static_position ->
    object_hitbox star = collect_star_hitbox ->
    overlaps_object (synthetic_act3_collision_phase star) star.
Proof.
  intros star Hposition Hhitbox.
  unfold overlaps_object, collision_phase_overlap,
    synthetic_act3_collision_phase, object_ref_equal.
  cbn.
  rewrite Hposition, Hhitbox.
  repeat split; try reflexivity.
Qed.

(* This one-step witness changes only [state_save_flags].  The abstract
   collision phase is not required to agree with [state_mario_kinematics], so
   a clean entry can be labelled as an immediate Act 3 collision even though
   its entry snapshot is at a different position. *)
Theorem current_certified_model_admits_spurious_act3_collection :
  forall initial,
    CleanPyramidEntry initial ->
    exists star phase final,
      CertifiedExecution initial [EventCollectAct3 star phase] final /\
      newly_collected
        (state_save_flags initial) (state_save_flags final) act3_index /\
      state_mario_kinematics final = state_mario_kinematics initial.
Proof.
  intros initial Hclean.
  destruct (clean_act3_static initial Hclean) as
    [star [Hin [Hactive [Horigin [Href [Harea [Hposition Hhitbox]]]]]]].
  exists star, (synthetic_act3_collision_phase star),
    (with_save_flags initial (Int.repr 4)).
  split.
  - eapply ExecutionCons with
      (middle := with_save_flags initial (Int.repr 4)).
    + eapply StepCollectAct3.
      * exact Hin.
      * exact Hactive.
      * exact Horigin.
      * exact Href.
      * split; [exact Hactive |].
        apply synthetic_act3_phase_overlaps_static_star; assumption.
      * vm_compute. reflexivity.
      * change
          (star_bit (Int.repr 4) act6_index =
           star_bit (state_save_flags initial) act6_index).
        rewrite (clean_act6_bit initial Hclean).
        vm_compute. reflexivity.
      * unfold puzzle_history_preserved. cbn. tauto.
      * apply frame_well_formed_with_save_flags.
        exact (clean_entry_is_frame_well_formed initial Hclean).
    + constructor.
  - split.
    + split.
      * exact (clean_act3_bit initial Hclean).
      * vm_compute. reflexivity.
    + reflexivity.
Qed.

(* A small, fully concrete clean-entry fixture makes the audit above
   non-vacuous.  It is a logical state of the handwritten model, not a RAM
   dump or an assertion that these ghost slot numbers are the retail pool
   allocation order. *)

Definition audit_act3_ref : ObjectRef :=
  {| object_slot := 0; object_epoch := 0 |}.

Definition audit_controller_ref : ObjectRef :=
  {| object_slot := 1; object_epoch := 0 |}.

Definition audit_trigger_ref (trigger : HiddenTrigger) : ObjectRef :=
  {| object_slot :=
       match trigger with
       | TriggerLowerWest => 2
       | TriggerLowerEast => 3
       | TriggerMiddleWest => 4
       | TriggerMiddleNorth => 5
       | TriggerUpper => 6
       end;
     object_epoch := 0 |}.

Definition audit_act3_object : ObjectState :=
  {| object_ref := audit_act3_ref;
     object_active := true;
     object_area := pyramid_area_id;
     object_behavior := BehaviorStarOrKey;
     object_star_index := Some act3_index;
     object_origin := StaticAct3PyramidStar;
     object_parent_ref := None;
     object_trigger_kind := None;
     object_position := act3_static_position;
     object_home_position := act3_static_position;
     object_hitbox := collect_star_hitbox;
     object_macro_respawn_consumed := false |}.

Definition audit_controller_object : ObjectState :=
  {| object_ref := audit_controller_ref;
     object_active := true;
     object_area := pyramid_area_id;
     object_behavior := BehaviorHiddenStarController;
     object_star_index := Some act6_index;
     object_origin := PyramidHiddenStarController;
     object_parent_ref := None;
     object_trigger_kind := None;
     object_position := hidden_controller_position;
     object_home_position := hidden_controller_position;
     object_hitbox := collect_star_hitbox;
     object_macro_respawn_consumed := false |}.

Definition audit_trigger_object (trigger : HiddenTrigger) : ObjectState :=
  {| object_ref := audit_trigger_ref trigger;
     object_active := true;
     object_area := pyramid_area_id;
     object_behavior := BehaviorHiddenStarTrigger;
     object_star_index := None;
     object_origin := PyramidMacroTrigger;
     object_parent_ref := None;
     object_trigger_kind := Some trigger;
     object_position := hidden_trigger_position trigger;
     object_home_position := hidden_trigger_position trigger;
     object_hitbox := hidden_trigger_hitbox;
     object_macro_respawn_consumed := false |}.

Definition audit_object_pool : list ObjectState :=
  [ audit_act3_object;
    audit_controller_object;
    audit_trigger_object TriggerLowerWest;
    audit_trigger_object TriggerLowerEast;
    audit_trigger_object TriggerMiddleWest;
    audit_trigger_object TriggerMiddleNorth;
    audit_trigger_object TriggerUpper ].

Definition audit_trigger_state (_ : HiddenTrigger) : bool := false.

Definition audit_entry_kinematics
    (entrance : PyramidEntrance) : MarioKinematics :=
  {| mario_position :=
       match entrance with
       | LowerEntrance => lower_entry_position
       | UpperEntrance => upper_entry_position
       end;
     mario_velocity := vec3f_zero;
     mario_forward_velocity := f32_zero;
     mario_action := airborne_warp_action;
     mario_floor :=
       {| surface_area := pyramid_area_id; surface_index := 0 |};
     mario_floor_height := f32_zero;
     mario_room := Int.zero |}.

Definition audit_entry_snapshot
    (entrance : PyramidEntrance) : EntrySnapshot :=
  {| entry_warp_node :=
       match entrance with
       | LowerEntrance => lower_entry_warp_node
       | UpperEntrance => upper_entry_warp_node
       end;
     entry_facing_yaw := airborne_entry_facing_yaw;
     entry_kinematics := audit_entry_kinematics entrance |}.

Definition audit_clean_entry
    (version : GameVersion) (entrance : PyramidEntrance) : GameState :=
  {| state_version := version;
     state_entrance := entrance;
     state_level := ssl_level_id;
     state_course := ssl_course_id;
     state_act := Int.one;
     state_area := pyramid_area_id;
     state_save_flags := Int.zero;
     state_backup_save_flags := Int.zero;
     state_object_pool := audit_object_pool;
     state_static_act3_ref := audit_act3_ref;
     state_hidden_controller_ref := audit_controller_ref;
     state_hidden_trigger_refs := audit_trigger_ref;
     state_triggers := audit_trigger_state;
     state_puzzle_star_spawned := false;
     state_macro_respawn_state := audit_trigger_state;
     state_pool_well_formed := true;
     state_lists_well_formed := true;
     state_pending_star_interaction := false;
     state_delayed_star_exit := false;
     state_entry_button_down := Int.zero;
     state_first_frame_previous_down_seed := Int.zero;
     state_mario_platform := None;
     state_entry_snapshot := audit_entry_snapshot entrance;
     state_mario_kinematics := audit_entry_kinematics entrance |}.

Lemma audit_trigger_object_is_valid :
  forall version entrance trigger,
    valid_hidden_trigger_object
      (audit_clean_entry version entrance) trigger
      (audit_trigger_object trigger).
Proof.
  intros version entrance trigger.
  destruct trigger; cbn; repeat split; auto;
    unfold all_hidden_triggers, audit_clean_entry, audit_object_pool;
    cbn; firstorder.
Qed.

Lemma audit_target_provenance :
  forall version entrance,
    target_provenance (audit_clean_entry version entrance).
Proof.
  intros version entrance object Hin.
  unfold audit_clean_entry, audit_object_pool in Hin.
  cbn in Hin.
  destruct Hin as
    [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]];
    unfold valid_target_origin, active_star_or_key, active_object,
      object_has_index, object_ref_equal;
    cbn;
    intuition discriminate.
Qed.

Lemma audit_hidden_trigger_provenance :
  forall version entrance,
    hidden_trigger_provenance (audit_clean_entry version entrance).
Proof.
  intros version entrance object Hin Hactive Hbehavior.
  unfold audit_clean_entry, audit_object_pool in Hin.
  cbn in Hin.
  destruct Hin as
    [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]].
  - discriminate.
  - discriminate.
  - exists TriggerLowerWest. apply audit_trigger_object_is_valid.
  - exists TriggerLowerEast. apply audit_trigger_object_is_valid.
  - exists TriggerMiddleWest. apply audit_trigger_object_is_valid.
  - exists TriggerMiddleNorth. apply audit_trigger_object_is_valid.
  - exists TriggerUpper. apply audit_trigger_object_is_valid.
Qed.

Lemma audit_trigger_refs_distinct :
  forall version entrance,
    hidden_trigger_refs_distinct (audit_clean_entry version entrance).
Proof.
  intros version entrance first second _ _ Hdifferent.
  destruct first, second; try contradiction;
    unfold object_ref_equal, audit_clean_entry, audit_trigger_ref;
    cbn;
    intros [Hslot _];
    discriminate.
Qed.

Lemma audit_all_hidden_triggers_present :
  forall version entrance,
    all_hidden_trigger_objects_present
      (audit_clean_entry version entrance).
Proof.
  intros version entrance trigger _.
  exists (audit_trigger_object trigger).
  apply audit_trigger_object_is_valid.
Qed.

Theorem audit_clean_entry_is_clean :
  forall version entrance,
    CleanPyramidEntry (audit_clean_entry version entrance).
Proof.
  intros version entrance.
  constructor.
  - destruct version; auto.
  - reflexivity.
  - reflexivity.
  - unfold valid_act. change (1 <= 1 <= 6). lia.
  - reflexivity.
  - destruct entrance; auto.
  - vm_compute. reflexivity.
  - vm_compute. reflexivity.
  - unfold target_save_coherent. vm_compute. auto.
  - intros trigger. reflexivity.
  - reflexivity.
  - intros object Hin.
    unfold audit_clean_entry, audit_object_pool in Hin.
    cbn in Hin.
    destruct Hin as
      [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]];
      unfold active_star_or_key, active_object, object_has_index;
      cbn;
      intuition discriminate.
  - exists audit_act3_object.
    cbn. repeat split; try reflexivity; tauto.
  - intros object Hin Hactive.
    pose proof (audit_target_provenance version entrance object Hin)
      as [Hact3 _].
    exact (proj1 (proj2 (Hact3 Hactive))).
  - exists audit_controller_object.
    cbn. repeat split; try reflexivity; tauto.
  - apply audit_target_provenance.
  - apply audit_hidden_trigger_provenance.
  - apply audit_all_hidden_triggers_present.
  - apply audit_trigger_refs_distinct.
  - intros trigger _. reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - reflexivity.
  - unfold input_history_well_formed. reflexivity.
  - destruct version, entrance; cbn; auto.
  - destruct entrance; cbn.
    + unfold entry_floor_well_formed. vm_compute.
      repeat split; reflexivity.
    + unfold entry_floor_well_formed. vm_compute.
      repeat split; reflexivity.
  - reflexivity.
Qed.

Corollary current_abstract_counterexample_exists_for_every_target_entry :
  forall version entrance,
    exists initial star phase final,
      initial = audit_clean_entry version entrance /\
      CleanPyramidEntry initial /\
      CertifiedExecution initial [EventCollectAct3 star phase] final /\
      newly_collected
        (state_save_flags initial) (state_save_flags final) act3_index /\
      state_mario_kinematics final = state_mario_kinematics initial.
Proof.
  intros version entrance.
  pose proof (audit_clean_entry_is_clean version entrance) as Hclean.
  destruct
    (current_certified_model_admits_spurious_act3_collection
      (audit_clean_entry version entrance) Hclean)
    as [star [phase [final [Hexecution [Hnew Hstill]]]]].
  exists (audit_clean_entry version entrance), star, phase, final.
  split; [reflexivity |].
  split; [exact Hclean |].
  split; [exact Hexecution |].
  split; assumption.
Qed.
