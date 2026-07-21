From Coq Require Import List ZArith Lia.
From SSLSpawning.Proofs Require Import Spec JPSpawn PlatformDisplacement
  FreeListReuse SSLFacts PyramidTopWarp ClonedPlatformWarp.

Import ListNotations.
Local Open Scope Z_scope.

Definition ssl_start_mario : mario_state := {|
  mario_pos_x := 653;
  mario_pos_y := 38;
  mario_pos_z := 6566;
  mario_face_yaw := 88
|}.

Definition ssl_area1_box_wing_cap_east : ssl_object := {|
  ssl_object_kind := KindExclamationBox;
  ssl_object_x := 6900;
  ssl_object_y := 350;
  ssl_object_z := -5400
|}.

Definition ssl_area1_box_wing_cap_west : ssl_object := {|
  ssl_object_kind := KindExclamationBox;
  ssl_object_x := -3000;
  ssl_object_y := 500;
  ssl_object_z := 800
|}.

Definition ssl_area1_box_koopa_shell : ssl_object := {|
  ssl_object_kind := KindExclamationBox;
  ssl_object_x := 5840;
  ssl_object_y := 940;
  ssl_object_z := 2500
|}.

Definition ssl_area1_box_wing_cap_pillar : ssl_object := {|
  ssl_object_kind := KindExclamationBox;
  ssl_object_x := 5860;
  ssl_object_y := 940;
  ssl_object_z := 4180
|}.

Definition ssl_area1_box_1up_running_away : ssl_object := {|
  ssl_object_kind := KindExclamationBox;
  ssl_object_x := -1200;
  ssl_object_y := 500;
  ssl_object_z := 800
|}.

Definition ssl_area1_exclamation_box_sources : list ssl_object := [
  ssl_area1_box_wing_cap_east;
  ssl_area1_box_wing_cap_west;
  ssl_area1_box_koopa_shell;
  ssl_area1_box_wing_cap_pillar;
  ssl_area1_box_1up_running_away
].

Definition object_at_top_entry_warp_seed_position (obj : ssl_object) : Prop :=
  ssl_object_x obj = cloned_exclamation_box_x /\
  ssl_object_y obj = cloned_exclamation_box_y /\
  ssl_object_z obj = cloned_exclamation_box_z.

Theorem ssl_start_position_is_ssl_script_start :
  mario_pos_x ssl_start_mario = 653 /\
  mario_pos_y ssl_start_mario = 38 /\
  mario_pos_z ssl_start_mario = 6566 /\
  mario_face_yaw ssl_start_mario = 88.
Proof.
  repeat split.
Qed.

Theorem ssl_area1_exclamation_box_source_count_is_5 :
  length ssl_area1_exclamation_box_sources = 5%nat.
Proof.
  reflexivity.
Qed.

Theorem ssl_area1_exclamation_box_sources_are_boxes :
  Forall
    (fun obj => ssl_object_kind obj = KindExclamationBox)
    ssl_area1_exclamation_box_sources.
Proof.
  repeat constructor.
Qed.

Theorem ssl_area1_has_west_exclamation_box_source :
  In ssl_area1_box_wing_cap_west ssl_area1_exclamation_box_sources /\
  ssl_object_x ssl_area1_box_wing_cap_west = -3000 /\
  ssl_object_y ssl_area1_box_wing_cap_west = 500 /\
  ssl_object_z ssl_area1_box_wing_cap_west = 800.
Proof.
  split.
  - simpl. right. left. reflexivity.
  - repeat split; reflexivity.
Qed.

Theorem ssl_area1_has_running_1up_exclamation_box_source :
  In ssl_area1_box_1up_running_away ssl_area1_exclamation_box_sources /\
  ssl_object_x ssl_area1_box_1up_running_away = -1200 /\
  ssl_object_y ssl_area1_box_1up_running_away = 500 /\
  ssl_object_z ssl_area1_box_1up_running_away = 800.
Proof.
  split.
  - simpl. right. right. right. right. left. reflexivity.
  - repeat split; reflexivity.
Qed.

Theorem no_ssl_area1_exclamation_box_spawns_at_top_entry_seed_position :
  Forall
    (fun obj => ~ object_at_top_entry_warp_seed_position obj)
    ssl_area1_exclamation_box_sources.
Proof.
  unfold ssl_area1_exclamation_box_sources.
  apply Forall_cons.
  - unfold object_at_top_entry_warp_seed_position.
    intros [_ [Hy _]].
    unfold cloned_exclamation_box_y in Hy.
    unfold ssl_top_entry_warp_y, exclamation_box_scaled_top_relative_y,
      exclamation_box_outline_top_relative_y,
      exclamation_box_runtime_scale in Hy.
    cbn in Hy.
    lia.
  - apply Forall_cons.
    + unfold object_at_top_entry_warp_seed_position.
      intros [_ [Hy _]].
      unfold cloned_exclamation_box_y in Hy.
      unfold ssl_top_entry_warp_y, exclamation_box_scaled_top_relative_y,
        exclamation_box_outline_top_relative_y,
        exclamation_box_runtime_scale in Hy.
      cbn in Hy.
      lia.
    + apply Forall_cons.
      * unfold object_at_top_entry_warp_seed_position.
        intros [_ [Hy _]].
        unfold cloned_exclamation_box_y in Hy.
        unfold ssl_top_entry_warp_y, exclamation_box_scaled_top_relative_y,
          exclamation_box_outline_top_relative_y,
          exclamation_box_runtime_scale in Hy.
        cbn in Hy.
        lia.
      * apply Forall_cons.
        -- unfold object_at_top_entry_warp_seed_position.
           intros [_ [Hy _]].
           unfold cloned_exclamation_box_y in Hy.
           unfold ssl_top_entry_warp_y, exclamation_box_scaled_top_relative_y,
             exclamation_box_outline_top_relative_y,
             exclamation_box_runtime_scale in Hy.
           cbn in Hy.
           lia.
        -- apply Forall_cons.
           ++ unfold object_at_top_entry_warp_seed_position.
              intros [_ [Hy _]].
              unfold cloned_exclamation_box_y in Hy.
              unfold ssl_top_entry_warp_y, exclamation_box_scaled_top_relative_y,
                exclamation_box_outline_top_relative_y,
                exclamation_box_runtime_scale in Hy.
              cbn in Hy.
              lia.
           ++ apply Forall_nil.
Qed.

Inductive executed_behavior : Type :=
| RunsExclamationBox
| RunsCarrySomething3
| RunsCarrySomething4
| RunsOtherBehavior.

Definition executed_behavior_loads_owned_surface_collision
    (behavior : executed_behavior) : bool :=
  match behavior with
  | RunsExclamationBox => true
  | RunsCarrySomething3 => false
  | RunsCarrySomething4 => false
  | RunsOtherBehavior => false
  end.

Definition source_exclamation_box_has_holdable_flag : bool := false.

Definition obj_set_held_state_effect_on_executed_behavior
    (has_holdable_flag : bool)
    (current_behavior held_behavior : executed_behavior)
    : executed_behavior :=
  if has_holdable_flag then current_behavior else held_behavior.

Definition fake_object_grabbed_exclamation_box_behavior : executed_behavior :=
  obj_set_held_state_effect_on_executed_behavior
    source_exclamation_box_has_holdable_flag
    RunsExclamationBox
    RunsCarrySomething3.

Definition fake_object_dropped_exclamation_box_behavior : executed_behavior :=
  obj_set_held_state_effect_on_executed_behavior
    source_exclamation_box_has_holdable_flag
    fake_object_grabbed_exclamation_box_behavior
    RunsCarrySomething4.

Definition fake_object_grab_drop_produces_standable_exclamation_box : Prop :=
  executed_behavior_loads_owned_surface_collision
    fake_object_dropped_exclamation_box_behavior = true.

Theorem exclamation_box_is_non_holdable_for_obj_set_held_state :
  source_exclamation_box_has_holdable_flag = false.
Proof.
  reflexivity.
Qed.

Theorem fake_object_grab_replaces_non_holdable_exclamation_loop :
  fake_object_grabbed_exclamation_box_behavior = RunsCarrySomething3.
Proof.
  reflexivity.
Qed.

Theorem fake_object_drop_replaces_non_holdable_exclamation_loop :
  fake_object_dropped_exclamation_box_behavior = RunsCarrySomething4.
Proof.
  reflexivity.
Qed.

Theorem carry_something_behaviors_do_not_load_surface_collision :
  executed_behavior_loads_owned_surface_collision RunsCarrySomething3 = false /\
  executed_behavior_loads_owned_surface_collision RunsCarrySomething4 = false.
Proof.
  split; reflexivity.
Qed.

Theorem fake_object_grab_drop_exclamation_box_loses_collision_loader :
  executed_behavior_loads_owned_surface_collision
    fake_object_dropped_exclamation_box_behavior = false.
Proof.
  reflexivity.
Qed.

Theorem fake_object_grab_drop_exclamation_box_cannot_seed_platform :
  ~ fake_object_grab_drop_produces_standable_exclamation_box.
Proof.
  unfold fake_object_grab_drop_produces_standable_exclamation_box.
  rewrite fake_object_grab_drop_exclamation_box_loses_collision_loader.
  discriminate.
Qed.

Definition standable_clone_at_top_entry_warp_obligation : Prop :=
  exists state watched,
    cloned_exclamation_box_seed_route state watched.

Theorem source_verified_standable_clone_obligation_is_engine_sufficient :
  standable_clone_at_top_entry_warp_obligation ->
  exists seed_state after_jp_spawn first_update_state observation,
    cloned_exclamation_box_seed_route
      seed_state cloned_platform_slot /\
    after_jp_spawn = spawn_objects_from_info_jp_model seed_state /\
    state_gMarioPlatform after_jp_spawn = Some cloned_platform_slot /\
    nth_allocation_reuses_slot
      (free_list_after_unloads [] cloned_route_unload_order)
      ssl_area2_spindel_allocation_index
      cloned_platform_slot /\
    apply_mario_platform_displacement_model first_update_state =
      Some observation /\
    observation_slot observation = cloned_platform_slot /\
    observation_oVelZ observation = 5 /\
    observation_oAngleVelPitch observation = 256.
Proof.
  intros _.
  apply cloned_platform_route_can_feed_spindel_displacement.
Qed.

Theorem current_source_facts_do_not_prove_fake_object_box_route :
  standable_clone_at_top_entry_warp_obligation /\
  fake_object_grab_drop_produces_standable_exclamation_box ->
  False.
Proof.
  intros [_ Hfake].
  exact (fake_object_grab_drop_exclamation_box_cannot_seed_platform Hfake).
Qed.

Inductive interaction_kind : Type :=
| InteractionWarp
| InteractionGrabbable
| InteractionOther.

Definition interaction_handler_index (kind : interaction_kind) : nat :=
  match kind with
  | InteractionWarp => 4%nat
  | InteractionGrabbable => 29%nat
  | InteractionOther => 99%nat
  end.

Theorem warp_interaction_is_processed_before_grabbable :
  (interaction_handler_index InteractionWarp <
   interaction_handler_index InteractionGrabbable)%nat.
Proof.
  cbn.
  lia.
Qed.

Inductive mario_action_model : Type :=
| ActionPickingUp
| ActionDisappeared
| ActionOther.

Inductive mario_action_group_model : Type :=
| ActionGroupObject
| ActionGroupCutscene
| ActionGroupOther.

Definition action_group_model (action : mario_action_model)
    : mario_action_group_model :=
  match action with
  | ActionPickingUp => ActionGroupObject
  | ActionDisappeared => ActionGroupCutscene
  | ActionOther => ActionGroupOther
  end.

Definition action_can_complete_fake_object_pickup
    (action : mario_action_model) : bool :=
  match action with
  | ActionPickingUp => true
  | ActionDisappeared => false
  | ActionOther => false
  end.

Definition non_fading_warp_interaction_action : mario_action_model :=
  ActionDisappeared.

Definition already_held_fake_exclamation_box_behavior : executed_behavior :=
  RunsCarrySomething3.

Definition grab_on_warp_frame_can_complete_pickup : Prop :=
  action_can_complete_fake_object_pickup
    non_fading_warp_interaction_action = true.

Definition already_held_box_can_load_collision_this_frame : Prop :=
  executed_behavior_loads_owned_surface_collision
    already_held_fake_exclamation_box_behavior = true.

Definition no_drop_fake_box_at_warp_proper_can_seed_platform : Prop :=
  already_held_box_can_load_collision_this_frame \/
  grab_on_warp_frame_can_complete_pickup.

Theorem non_fading_warp_sets_cutscene_action_not_pickup :
  action_group_model non_fading_warp_interaction_action =
  ActionGroupCutscene /\
  action_can_complete_fake_object_pickup
    non_fading_warp_interaction_action = false.
Proof.
  split; reflexivity.
Qed.

Theorem already_held_fake_box_does_not_load_collision_this_frame :
  executed_behavior_loads_owned_surface_collision
    already_held_fake_exclamation_box_behavior = false.
Proof.
  reflexivity.
Qed.

Theorem grab_on_warp_frame_cannot_complete_pickup :
  ~ grab_on_warp_frame_can_complete_pickup.
Proof.
  unfold grab_on_warp_frame_can_complete_pickup.
  destruct non_fading_warp_sets_cutscene_action_not_pickup as [_ Hpickup].
  rewrite Hpickup.
  discriminate.
Qed.

Theorem no_drop_fake_box_at_warp_proper_cannot_seed_platform :
  ~ no_drop_fake_box_at_warp_proper_can_seed_platform.
Proof.
  intros [Halready_held | Hgrab_on_warp].
  - unfold already_held_box_can_load_collision_this_frame in Halready_held.
    rewrite already_held_fake_box_does_not_load_collision_this_frame
      in Halready_held.
    discriminate.
  - exact (grab_on_warp_frame_cannot_complete_pickup Hgrab_on_warp).
Qed.
