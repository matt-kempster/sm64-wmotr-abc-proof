From Coq Require Import Bool ZArith Lia.
From SSLSpawning.Proofs Require Import GeneratedClightFacts Spec.

Local Open Scope Z_scope.

Record warp_point : Type := {
  warp_point_x : Z;
  warp_point_y : Z;
  warp_point_z : Z
}.

Definition ssl_node1e_original_position : warp_point := {|
  warp_point_x := -2048;
  warp_point_y := 768;
  warp_point_z := -1024
|}.

Definition ssl_area2_node14_position : warp_point := {|
  warp_point_x := 0;
  warp_point_y := 5500;
  warp_point_z := 256
|}.

Definition ssl_node1e_id : Z := 30.
Definition ssl_node14_id : Z := 20.
Definition ssl_area2_id : Z := 2.

Record live_warp_object : Type := {
  live_warp_position : warp_point;
  live_warp_node_parameter : Z;
  live_warp_permanent_behavior : bool;
  live_warp_interact_type : bool;
  live_warp_hitbox_radius : Z;
  live_warp_hitbox_height : Z;
  live_warp_status_clear : bool;
  live_warp_normal_loop_active : bool
}.

Definition ssl_node1e_object : live_warp_object := {|
  live_warp_position := ssl_node1e_original_position;
  live_warp_node_parameter := ssl_node1e_id;
  live_warp_permanent_behavior := true;
  live_warp_interact_type := true;
  live_warp_hitbox_radius := 150;
  live_warp_hitbox_height := 50;
  live_warp_status_clear := true;
  live_warp_normal_loop_active := true
|}.

(* For a non-holdable object, obj_set_held_state redirects only the current
   behavior command.  It does not write the object's live coordinates. *)
Definition grab_warp_portal_model
    (portal : live_warp_object) : live_warp_object := {|
  live_warp_position := live_warp_position portal;
  live_warp_node_parameter := live_warp_node_parameter portal;
  live_warp_permanent_behavior := live_warp_permanent_behavior portal;
  live_warp_interact_type := live_warp_interact_type portal;
  live_warp_hitbox_radius := live_warp_hitbox_radius portal;
  live_warp_hitbox_height := live_warp_hitbox_height portal;
  live_warp_status_clear := live_warp_status_clear portal;
  live_warp_normal_loop_active := false
|}.

Definition held_object_drop_position
    (held_object_last_position mario_position : warp_point) : warp_point := {|
  warp_point_x := warp_point_x held_object_last_position;
  warp_point_y := warp_point_y mario_position;
  warp_point_z := warp_point_z held_object_last_position
|}.

Definition drop_warp_portal_model
    (portal : live_warp_object)
    (held_object_last_position mario_position : warp_point)
    : live_warp_object := {|
  live_warp_position :=
    held_object_drop_position held_object_last_position mario_position;
  live_warp_node_parameter := live_warp_node_parameter portal;
  live_warp_permanent_behavior := live_warp_permanent_behavior portal;
  live_warp_interact_type := live_warp_interact_type portal;
  live_warp_hitbox_radius := live_warp_hitbox_radius portal;
  live_warp_hitbox_height := live_warp_hitbox_height portal;
  live_warp_status_clear := live_warp_status_clear portal;
  live_warp_normal_loop_active := false
|}.

Definition ready_for_first_warp_contact (portal : live_warp_object) : Prop :=
  live_warp_permanent_behavior portal = true /\
  live_warp_interact_type portal = true /\
  live_warp_status_clear portal = true /\
  0 < live_warp_hitbox_radius portal /\
  0 < live_warp_hitbox_height portal.

Theorem grabbing_node1e_alone_does_not_move_its_live_entrance :
  live_warp_position (grab_warp_portal_model ssl_node1e_object) =
    ssl_node1e_original_position.
Proof.
  reflexivity.
Qed.

Theorem dropping_hypothetically_held_node1e_relocates_its_live_entrance :
  forall held_object_last_position mario_position,
    live_warp_position
      (drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_position) =
      held_object_drop_position held_object_last_position mario_position.
Proof.
  reflexivity.
Qed.

Theorem dropping_node1e_preserves_first_contact_warp_fields :
  forall held_object_last_position mario_position,
    let moved :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_position in
    live_warp_node_parameter moved = ssl_node1e_id /\
    ready_for_first_warp_contact moved /\
    live_warp_normal_loop_active moved = false.
Proof.
  intros held_object_last_position mario_position.
  repeat split; reflexivity || lia.
Qed.

Inductive warp_mario_action : Type :=
| WarpMarioOther
| WarpMarioDisappeared.

Record warp_mario_control : Type := {
  warp_mario_position : warp_point;
  warp_mario_floor_y : Z;
  warp_mario_platform : option slot;
  warp_mario_used_node : option Z;
  warp_mario_interact_node : option Z;
  warp_mario_action_state : warp_mario_action
}.

Definition mario_at_live_warp
    (portal : live_warp_object) (floor_y : Z) (platform : option slot)
    : warp_mario_control := {|
  warp_mario_position := live_warp_position portal;
  warp_mario_floor_y := floor_y;
  warp_mario_platform := platform;
  warp_mario_used_node := None;
  warp_mario_interact_node := None;
  warp_mario_action_state := WarpMarioOther
|}.

Definition interact_with_live_warp_model
    (portal : live_warp_object) (mario : warp_mario_control)
    : warp_mario_control := {|
  warp_mario_position := warp_mario_position mario;
  warp_mario_floor_y := warp_mario_floor_y mario;
  warp_mario_platform := warp_mario_platform mario;
  warp_mario_used_node := Some (live_warp_node_parameter portal);
  warp_mario_interact_node := Some (live_warp_node_parameter portal);
  warp_mario_action_state := WarpMarioDisappeared
|}.

Definition act_disappeared_step_model
    (mario : warp_mario_control) : warp_mario_control := {|
  warp_mario_position := {|
    warp_point_x := warp_point_x (warp_mario_position mario);
    warp_point_y := warp_mario_floor_y mario;
    warp_point_z := warp_point_z (warp_mario_position mario)
  |};
  warp_mario_floor_y := warp_mario_floor_y mario;
  warp_mario_platform := warp_mario_platform mario;
  warp_mario_used_node := warp_mario_used_node mario;
  warp_mario_interact_node := warp_mario_interact_node mario;
  warp_mario_action_state := warp_mario_action_state mario
|}.

Definition warp_object_action_pipeline
    (portal : live_warp_object) (mario : warp_mario_control)
    : warp_mario_control :=
  act_disappeared_step_model (interact_with_live_warp_model portal mario).

Theorem warp_contact_uses_marios_current_location :
  forall portal floor_y platform,
    let after :=
      warp_object_action_pipeline portal
        (mario_at_live_warp portal floor_y platform) in
    warp_point_x (warp_mario_position after) =
      warp_point_x (live_warp_position portal) /\
    warp_point_y (warp_mario_position after) = floor_y /\
    warp_point_z (warp_mario_position after) =
      warp_point_z (live_warp_position portal).
Proof.
  intros portal floor_y platform.
  repeat split; reflexivity.
Qed.

Theorem warp_contact_sets_used_and_disappeared_but_not_platform :
  forall portal mario,
    let after := warp_object_action_pipeline portal mario in
    warp_mario_used_node after = Some (live_warp_node_parameter portal) /\
    warp_mario_interact_node after =
      Some (live_warp_node_parameter portal) /\
    warp_mario_action_state after = WarpMarioDisappeared /\
    warp_mario_platform after = warp_mario_platform mario.
Proof.
  intros portal mario.
  repeat split; reflexivity.
Qed.

Theorem warp_pipeline_does_not_seed_gMarioPlatform :
  forall portal mario,
    warp_mario_platform mario = None ->
    warp_mario_platform (warp_object_action_pipeline portal mario) = None.
Proof.
  intros portal mario Hplatform.
  cbn.
  exact Hplatform.
Qed.

Theorem warp_contact_while_on_platform_preserves_gMarioPlatform :
  forall portal mario platform_slot,
    warp_mario_platform mario = Some platform_slot ->
    warp_mario_platform (warp_object_action_pipeline portal mario) =
      Some platform_slot.
Proof.
  intros portal mario platform_slot Hplatform.
  cbn.
  exact Hplatform.
Qed.

Record warp_destination : Type := {
  warp_destination_area : Z;
  warp_destination_node : Z;
  warp_destination_position : warp_point
}.

Definition ssl_node1e_destination : warp_destination := {|
  warp_destination_area := ssl_area2_id;
  warp_destination_node := ssl_node14_id;
  warp_destination_position := ssl_area2_node14_position
|}.

Definition resolve_ssl_area1_warp_node
    (source_node : Z) : option warp_destination :=
  if Z.eqb source_node ssl_node1e_id
  then Some ssl_node1e_destination
  else None.

Definition route_from_used_warp
    (mario : warp_mario_control) : option warp_destination :=
  match warp_mario_used_node mario with
  | Some source_node => resolve_ssl_area1_warp_node source_node
  | None => None
  end.

Theorem moved_node1e_still_routes_to_area2_node14 :
  forall portal_position floor_y platform,
    let portal :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        portal_position portal_position in
    route_from_used_warp
      (warp_object_action_pipeline portal
        (mario_at_live_warp portal floor_y platform)) =
      Some ssl_node1e_destination.
Proof.
  intros portal_position floor_y platform.
  reflexivity.
Qed.

Definition init_mario_at_destination_model
    (destination : warp_destination) (mario : warp_mario_control)
    : warp_mario_control := {|
  warp_mario_position := warp_destination_position destination;
  warp_mario_floor_y := warp_mario_floor_y mario;
  warp_mario_platform := warp_mario_platform mario;
  warp_mario_used_node := Some (warp_destination_node destination);
  warp_mario_interact_node := Some (warp_destination_node destination);
  warp_mario_action_state := WarpMarioOther
|}.

Theorem moved_node1e_does_not_move_destination_spawn :
  forall portal_position floor_y platform,
    let portal :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        portal_position portal_position in
    let source_after :=
      warp_object_action_pipeline portal
        (mario_at_live_warp portal floor_y platform) in
    warp_mario_position
      (init_mario_at_destination_model ssl_node1e_destination source_after) =
      ssl_area2_node14_position.
Proof.
  reflexivity.
Qed.

Definition update_platform_from_owned_floor_model
    (owner : slot) (mario : warp_mario_control) : warp_mario_control := {|
  warp_mario_position := warp_mario_position mario;
  warp_mario_floor_y := warp_mario_floor_y mario;
  warp_mario_platform := Some owner;
  warp_mario_used_node := warp_mario_used_node mario;
  warp_mario_interact_node := warp_mario_interact_node mario;
  warp_mario_action_state := warp_mario_action_state mario
|}.

Theorem moved_warp_can_seed_platform_only_through_separate_floor_update :
  forall portal mario owner,
    warp_mario_platform (warp_object_action_pipeline portal mario) =
      warp_mario_platform mario /\
    warp_mario_platform
      (update_platform_from_owned_floor_model owner
        (warp_object_action_pipeline portal mario)) = Some owner.
Proof.
  intros portal mario owner.
  split; reflexivity.
Qed.

Definition first_warp_frame_on_owned_platform
    (portal : live_warp_object) (owner : slot) (mario : warp_mario_control)
    : warp_mario_control :=
  update_platform_from_owned_floor_model owner
    (warp_object_action_pipeline portal mario).

Definition later_disappeared_frame_on_owned_platform
    (owner : slot) (mario : warp_mario_control) : warp_mario_control :=
  update_platform_from_owned_floor_model owner
    (act_disappeared_step_model mario).

Fixpoint disappeared_frames_on_owned_platform
    (frames : nat) (owner : slot) (mario : warp_mario_control)
    : warp_mario_control :=
  match frames with
  | O => mario
  | S remaining =>
      disappeared_frames_on_owned_platform remaining owner
        (later_disappeared_frame_on_owned_platform owner mario)
  end.

Theorem moving_platform_floor_at_warp_contact_sets_gMarioPlatform :
  forall portal owner mario,
    warp_mario_platform
      (first_warp_frame_on_owned_platform portal owner mario) = Some owner.
Proof.
  reflexivity.
Qed.

Theorem moving_platform_seed_survives_disappeared_frames :
  forall frames owner mario,
    warp_mario_platform mario = Some owner ->
    warp_mario_platform
      (disappeared_frames_on_owned_platform frames owner mario) = Some owner.
Proof.
  induction frames as [| frames IH]; intros owner mario Hplatform.
  - exact Hplatform.
  - cbn.
    apply IH.
    reflexivity.
Qed.

Theorem hypothetical_moved_node1e_platform_seed_reaches_area2 :
  forall held_object_last_position mario_drop_position floor_y
         previous_platform seed_slot disappeared_frames,
    let moved :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_drop_position in
    let source_before :=
      mario_at_live_warp moved floor_y previous_platform in
    let seeded :=
      first_warp_frame_on_owned_platform moved seed_slot source_before in
    let faded :=
      disappeared_frames_on_owned_platform
        disappeared_frames seed_slot seeded in
    let arrived :=
      init_mario_at_destination_model ssl_node1e_destination faded in
    warp_mario_platform seeded = Some seed_slot /\
    warp_mario_platform faded = Some seed_slot /\
    warp_mario_position arrived = ssl_area2_node14_position /\
    warp_mario_platform arrived = Some seed_slot.
Proof.
  intros held_object_last_position mario_drop_position floor_y
    previous_platform seed_slot disappeared_frames.
  cbn -[disappeared_frames_on_owned_platform].
  assert (Hfaded :
    warp_mario_platform
      (disappeared_frames_on_owned_platform disappeared_frames seed_slot
        (first_warp_frame_on_owned_platform
          (drop_warp_portal_model
            (grab_warp_portal_model ssl_node1e_object)
            held_object_last_position mario_drop_position)
          seed_slot
          (mario_at_live_warp
            (drop_warp_portal_model
              (grab_warp_portal_model ssl_node1e_object)
              held_object_last_position mario_drop_position)
            floor_y previous_platform))) = Some seed_slot).
  {
    apply moving_platform_seed_survives_disappeared_frames.
    reflexivity.
  }
  repeat split; try reflexivity; exact Hfaded.
Qed.

Theorem hypothetical_held_node1e_moves_entrance_not_destination :
  forall held_object_last_position mario_drop_position floor_y
         previous_platform seed_slot,
    let moved :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_drop_position in
    let source_after :=
      warp_object_action_pipeline moved
        (mario_at_live_warp moved floor_y previous_platform) in
    let seeded :=
      update_platform_from_owned_floor_model seed_slot source_after in
    let arrived :=
      init_mario_at_destination_model ssl_node1e_destination seeded in
    live_warp_position moved =
      held_object_drop_position held_object_last_position mario_drop_position /\
    ready_for_first_warp_contact moved /\
    warp_mario_used_node source_after = Some ssl_node1e_id /\
    warp_mario_platform source_after = previous_platform /\
    warp_mario_platform seeded = Some seed_slot /\
    warp_mario_position arrived = ssl_area2_node14_position /\
    warp_mario_platform arrived = Some seed_slot.
Proof.
  intros held_object_last_position mario_drop_position floor_y
    previous_platform seed_slot.
  repeat split; reflexivity || lia.
Qed.

Theorem generated_jp_clight_moved_node1e_capstone :
  jp_moved_node1e_source_certificate /\
  (forall held_object_last_position mario_drop_position floor_y
          previous_platform seed_slot,
    let moved :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_drop_position in
    let source_after :=
      warp_object_action_pipeline moved
        (mario_at_live_warp moved floor_y previous_platform) in
    let seeded :=
      update_platform_from_owned_floor_model seed_slot source_after in
    let arrived :=
      init_mario_at_destination_model ssl_node1e_destination seeded in
    live_warp_position moved =
      held_object_drop_position held_object_last_position mario_drop_position /\
    ready_for_first_warp_contact moved /\
    warp_mario_used_node source_after = Some ssl_node1e_id /\
    warp_mario_platform source_after = previous_platform /\
    warp_mario_platform seeded = Some seed_slot /\
    warp_mario_position arrived = ssl_area2_node14_position /\
    warp_mario_platform arrived = Some seed_slot).
Proof.
  split.
  - apply generated_jp_moved_node1e_source_certificate.
  - apply hypothetical_held_node1e_moves_entrance_not_destination.
Qed.

Theorem generated_jp_clight_moved_node1e_platform_seed_capstone :
  jp_moved_node1e_source_certificate /\
  (forall held_object_last_position mario_drop_position floor_y
          previous_platform seed_slot disappeared_frames,
    let moved :=
      drop_warp_portal_model
        (grab_warp_portal_model ssl_node1e_object)
        held_object_last_position mario_drop_position in
    let source_before :=
      mario_at_live_warp moved floor_y previous_platform in
    let seeded :=
      first_warp_frame_on_owned_platform moved seed_slot source_before in
    let faded :=
      disappeared_frames_on_owned_platform
        disappeared_frames seed_slot seeded in
    let arrived :=
      init_mario_at_destination_model ssl_node1e_destination faded in
    warp_mario_platform seeded = Some seed_slot /\
    warp_mario_platform faded = Some seed_slot /\
    warp_mario_position arrived = ssl_area2_node14_position /\
    warp_mario_platform arrived = Some seed_slot).
Proof.
  split.
  - apply generated_jp_moved_node1e_source_certificate.
  - apply hypothetical_moved_node1e_platform_seed_reaches_area2.
Qed.

(* The positive half is conditional on the already-disproved stock premise
   that Mario can hold node 1E.  It proves the mechanics after that premise;
   it does not make the premise ordinarily reachable. *)
