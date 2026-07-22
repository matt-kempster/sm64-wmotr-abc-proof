From Coq Require Import List ZArith Lia.
From compcert Require Import Clight.
From SSLSpawning.Proofs Require Import
  ASTFacts Spec JPSpawn FreeListReuse PyramidTopSlotPersistence
  GeneratedClightFacts SourcePlatformOverlap PyramidTopWarp
  StaticPyramidTopWarp
  DesyncMechanismSearch.

Import ListNotations.
Local Open Scope Z_scope.

Record engine_position : Type := {
  engine_x : Z;
  engine_y : Z;
  engine_z : Z
}.

Definition stock_node1e_position : engine_position := {|
  engine_x := -2048;
  engine_y := 768;
  engine_z := -1024
|}.

Definition stock_node1e_static_floor_min_x : Z := -2149.
Definition stock_node1e_static_floor_max_x : Z := -1945.
Definition stock_node1e_static_floor_min_z : Z := -1125.
Definition stock_node1e_static_floor_max_z : Z := -921.

Definition point_on_stock_node1e_static_floor
    (position : engine_position) : Prop :=
  stock_node1e_static_floor_min_x <= engine_x position <=
    stock_node1e_static_floor_max_x /\
  engine_y position = 768 /\
  stock_node1e_static_floor_min_z <= engine_z position <=
    stock_node1e_static_floor_max_z.

Theorem stock_node1e_is_centered_on_static_terrain_floor :
  point_on_stock_node1e_static_floor stock_node1e_position.
Proof.
  unfold point_on_stock_node1e_static_floor,
    stock_node1e_static_floor_min_x, stock_node1e_static_floor_max_x,
    stock_node1e_static_floor_min_z, stock_node1e_static_floor_max_z,
    stock_node1e_position.
  cbn.
  repeat split; lia.
Qed.

Record stock_node1e_alias_desync_source_certificate : Prop := {
  bypass_cert_update_phase_order :
    ident_subsequenceb
      [O._apply_mario_platform_displacement;
       O._detect_object_collisions;
       O._update_non_terrain_objects;
       O._unload_deactivated_objects;
       O._update_mario_platform]
      (direct_callees_s (fn_body O.f_update_objects)) = true;
  bypass_cert_displacement_uses_state_setter :
    calls_ident_s P._set_mario_pos
      (fn_body P.f_apply_platform_displacement) = true;
  bypass_cert_state_setter_does_not_write_mario_object :
    assigns_array_slot_s P._pos 0 (fn_body P.f_set_mario_pos) = true /\
    assigns_array_slot_s P._pos 1 (fn_body P.f_set_mario_pos) = true /\
    assigns_array_slot_s P._pos 2 (fn_body P.f_set_mario_pos) = true /\
    statement_mentions_ident_s P._gMarioObject
      (fn_body P.f_set_mario_pos) = false;
  bypass_cert_collision_reads_object_position :
    statement_mentions_array_slot_s OC._asF32 6
      (fn_body OC.f_detect_object_hitbox_overlap) = true /\
    statement_mentions_array_slot_s OC._asF32 7
      (fn_body OC.f_detect_object_hitbox_overlap) = true /\
    statement_mentions_array_slot_s OC._asF32 8
      (fn_body OC.f_detect_object_hitbox_overlap) = true;
  bypass_cert_action_then_state_to_object_copy :
    ident_subsequenceb
      [O._execute_mario_action; O._copy_mario_state_to_object]
      (direct_callees_s (fn_body O.f_bhv_mario_update)) = true /\
    assigns_array_slot_s O._asF32 6
      (fn_body O.f_copy_mario_state_to_object) = true /\
    assigns_array_slot_s O._asF32 7
      (fn_body O.f_copy_mario_state_to_object) = true /\
    assigns_array_slot_s O._asF32 8
      (fn_body O.f_copy_mario_state_to_object) = true;
  bypass_cert_platform_query_reads_object_position :
    statement_mentions_array_slot_s P._asF32 6
      (fn_body P.f_update_mario_platform) = true /\
    statement_mentions_array_slot_s P._asF32 7
      (fn_body P.f_update_mario_platform) = true /\
    statement_mentions_array_slot_s P._asF32 8
      (fn_body P.f_update_mario_platform) = true;
  bypass_cert_warp_preempts_action_movement :
    assigns_field_named_s MAC._action
      (fn_body MAC.f_act_disappeared) = false /\
    calls_ident_s MAC._perform_ground_step
      (fn_body MAC.f_act_disappeared) = false /\
    calls_ident_s MAC._perform_air_step
      (fn_body MAC.f_act_disappeared) = false;
  bypass_cert_no_audited_persistent_post_copy_writer :
    forall candidate,
      ~ audited_post_copy_oPos_candidate_can_seed_overlap candidate;
  bypass_cert_stock_sources_do_not_overlap_warp :
    ~ original_area1_source_platform_overlap
}.

Theorem generated_stock_node1e_alias_desync_source_certificate :
  stock_node1e_alias_desync_source_certificate.
Proof.
  constructor.
  - apply generated_update_objects_call_order.
  - apply generated_apply_platform_displacement_updates_mario_position.
  - apply generated_set_mario_pos_writes_state_and_not_mario_object.
  - apply generated_collision_reads_mario_object_position_slots.
  - split.
    + apply generated_bhv_mario_update_executes_action_before_copy.
    + destruct
        generated_copy_mario_state_to_object_writes_object_position_slots
        as [_ [Hx [Hy Hz]]].
      repeat split; assumption.
  - apply generated_platform_query_reads_mario_object_position_slots.
  - destruct generated_disappeared_action_keeps_action_and_skips_movement_steps
      as [Haction [_ [Hground [Hair _]]]].
    repeat split; assumption.
  - apply no_audited_post_copy_oPos_write_candidate_seeds_overlap.
  - apply original_area1_source_platform_overlap_is_impossible.
Qed.

Definition allocate_front_as
    (before : game_state) (fields : object_fields) : game_state :=
  match state_free_list before with
  | [] => before
  | allocated :: remaining => {|
      state_mario := state_mario before;
      state_gMarioPlatform := state_gMarioPlatform before;
      state_has_mario_object := state_has_mario_object before;
      state_time_stop_active := state_time_stop_active before;
      state_object_memory :=
        write_slot (state_object_memory before) allocated fields;
      state_free_list := remaining
    |}
  end.

Record valid_stale_slot_alias_transition
    (before after : game_state) (watched : slot)
    (target_kind : object_kind) : Prop := {
  stale_alias_pointer_before :
    state_gMarioPlatform before = Some watched;
  stale_alias_pointer_after :
    state_gMarioPlatform after = Some watched;
  stale_alias_slot_was_inactive :
    field_active (state_object_memory before watched) = false;
  stale_alias_slot_is_reallocated :
    field_active (state_object_memory after watched) = true;
  stale_alias_slot_has_target_kind :
    field_kind (state_object_memory after watched) = target_kind
}.

Theorem jp_area1_load_can_conditionally_form_a_valid_stale_slot_alias :
  forall before watched remaining fields,
    state_free_list before = watched :: remaining ->
    state_gMarioPlatform before = Some watched ->
    field_active (state_object_memory before watched) = false ->
    field_active fields = true ->
    let after :=
      allocate_front_as (spawn_objects_from_info_jp_model before) fields in
    valid_stale_slot_alias_transition
      before after watched (field_kind fields).
Proof.
  intros before watched remaining fields Hfree Hplatform Hinactive Hactive.
  change
    (valid_stale_slot_alias_transition before
      (allocate_front_as before fields) watched (field_kind fields)).
  unfold allocate_front_as.
  rewrite Hfree.
  constructor.
  - exact Hplatform.
  - exact Hplatform.
  - exact Hinactive.
  - change
      (field_active
        (write_slot (state_object_memory before) watched fields watched) =
       true).
    unfold write_slot.
    rewrite Z.eqb_refl.
    exact Hactive.
  - change
      (field_kind
        (write_slot (state_object_memory before) watched fields watched) =
       field_kind fields).
    unfold write_slot.
    rewrite Z.eqb_refl.
    reflexivity.
Qed.

Theorem front_unload_then_area1_allocation_reuses_the_aliased_slot :
  forall before after_unload after_allocate watched allocated,
    unload_object_pushes before watched after_unload ->
    allocate_object_pops after_unload allocated after_allocate ->
    allocated = watched.
Proof.
  apply unload_then_allocate_reuses_same_slot.
Qed.

Theorem allocation_cannot_create_a_platform_pointer_from_null :
  forall before fields,
    state_gMarioPlatform before = None ->
    state_gMarioPlatform (allocate_front_as before fields) = None.
Proof.
  intros before fields Hplatform.
  unfold allocate_front_as.
  destruct (state_free_list before); cbn; exact Hplatform.
Qed.

Definition stock_node1e_floor_observation : platform_floor_observation :=
  PlatformUpdateUnownedFloor.

Definition stock_node1e_platform_requery
    (before : option slot) : option slot :=
  update_gMarioPlatform_pointer_model
    before stock_node1e_floor_observation.

Theorem stock_node1e_requery_clears_every_stale_slot_alias :
  forall watched,
    stock_node1e_platform_requery (Some watched) = None.
Proof.
  reflexivity.
Qed.

Theorem stock_node1e_requery_is_null_for_every_prior_pointer :
  forall before,
    stock_node1e_platform_requery before = None.
Proof.
  intros [watched |]; reflexivity.
Qed.

Record mario_coordinate_pair : Type := {
  pair_state_position : engine_position;
  pair_object_position : engine_position
}.

Definition synchronized_coordinate_pair
    (position : engine_position) : mario_coordinate_pair := {|
  pair_state_position := position;
  pair_object_position := position
|}.

Definition apply_state_only_displacement
    (platform : option slot) (displaced_state : engine_position)
    (coordinates : mario_coordinate_pair) : mario_coordinate_pair :=
  match platform with
  | None => coordinates
  | Some _ => {|
      pair_state_position := displaced_state;
      pair_object_position := pair_object_position coordinates
    |}
  end.

Definition replace_position_y
    (position : engine_position) (floor_y : Z) : engine_position := {|
  engine_x := engine_x position;
  engine_y := floor_y;
  engine_z := engine_z position
|}.

Definition disappeared_floor_snap
    (floor_y : Z) (coordinates : mario_coordinate_pair)
    : mario_coordinate_pair := {|
  pair_state_position :=
    replace_position_y (pair_state_position coordinates) floor_y;
  pair_object_position := pair_object_position coordinates
|}.

Definition copy_state_position_to_mario_object
    (coordinates : mario_coordinate_pair) : mario_coordinate_pair := {|
  pair_state_position := pair_state_position coordinates;
  pair_object_position := pair_state_position coordinates
|}.

Definition warp_collision_position
    (coordinates : mario_coordinate_pair) : engine_position :=
  pair_object_position coordinates.

Definition platform_selection_position
    (coordinates : mario_coordinate_pair) : engine_position :=
  pair_object_position coordinates.

Theorem state_only_platform_displacement_creates_a_transient_desync :
  forall watched before_position displaced_position,
    before_position <> displaced_position ->
    let after :=
      apply_state_only_displacement (Some watched) displaced_position
        (synchronized_coordinate_pair before_position) in
    pair_state_position after = displaced_position /\
    pair_object_position after = before_position /\
    pair_state_position after <> pair_object_position after.
Proof.
  intros watched before_position displaced_position Hdistinct.
  cbn.
  split; [reflexivity |].
  split; [reflexivity |].
  intro Hequal.
  apply Hdistinct.
  symmetry.
  exact Hequal.
Qed.

Theorem platform_desync_is_conditionally_the_right_shape_for_stock_node1e :
  forall watched top_position,
    let after_displacement :=
      apply_state_only_displacement (Some watched) top_position
        (synchronized_coordinate_pair stock_node1e_position) in
    let after_disappeared :=
      disappeared_floor_snap (engine_y top_position) after_displacement in
    let after_copy :=
      copy_state_position_to_mario_object after_disappeared in
    warp_collision_position after_displacement = stock_node1e_position /\
    platform_selection_position after_copy = top_position.
Proof.
  intros watched top_position.
  destruct top_position.
  split; reflexivity.
Qed.

Definition top_floor_position_at_node_xz (floor_y : Z)
    : engine_position := {|
  engine_x := engine_x stock_node1e_position;
  engine_y := floor_y;
  engine_z := engine_z stock_node1e_position
|}.

Theorem a_spinning_top_floor_position_is_not_stock_node1e :
  forall object_y floor_y,
    spinning_top_owned_floor_height object_y floor_y ->
    top_floor_position_at_node_xz floor_y <> stock_node1e_position.
Proof.
  intros object_y floor_y [Hspinning [Hminimum _]] Hequal.
  unfold top_floor_position_at_node_xz, stock_node1e_position in Hequal.
  inversion Hequal.
  unfold pyramid_top_spinning_or_rising_y in Hspinning.
  unfold pyramid_top_collision_min_world_y,
    pyramid_top_collision_min_relative_y in Hminimum.
  cbn in Hspinning.
  lia.
Qed.

Definition stock_node1e_warp_frame_after_prior_requery
    (prior_pointer : option slot) (hypothetical_displaced_state : engine_position)
    : mario_coordinate_pair :=
  let reselected := stock_node1e_platform_requery prior_pointer in
  let after_displacement :=
    apply_state_only_displacement reselected hypothetical_displaced_state
      (synchronized_coordinate_pair stock_node1e_position) in
  let after_disappeared :=
    disappeared_floor_snap 768 after_displacement in
  copy_state_position_to_mario_object after_disappeared.

Theorem stock_node1e_prior_requery_prevents_the_coordinate_desync :
  forall prior_pointer hypothetical_displaced_state,
    stock_node1e_warp_frame_after_prior_requery
      prior_pointer hypothetical_displaced_state =
    synchronized_coordinate_pair stock_node1e_position.
Proof.
  intros [watched |] hypothetical_displaced_state;
    destruct hypothetical_displaced_state;
    reflexivity.
Qed.

Theorem stale_alias_cannot_enable_top_selection_at_stock_node1e :
  forall watched hypothetical_displaced_state object_y top_floor_y,
    spinning_top_owned_floor_height object_y top_floor_y ->
    let after :=
      stock_node1e_warp_frame_after_prior_requery
        (Some watched) hypothetical_displaced_state in
    warp_collision_position after = stock_node1e_position /\
    platform_selection_position after = stock_node1e_position /\
    platform_selection_position after <>
      top_floor_position_at_node_xz top_floor_y.
Proof.
  intros watched hypothetical_displaced_state object_y top_floor_y Htop.
  rewrite stock_node1e_prior_requery_prevents_the_coordinate_desync.
  cbn.
  repeat split; try reflexivity.
  intro Hequal.
  apply (a_spinning_top_floor_position_is_not_stock_node1e
    object_y top_floor_y Htop).
  symmetry.
  exact Hequal.
Qed.

Definition stale_slot_alias_solves_stock_node1e : Prop :=
  exists watched,
    stock_node1e_platform_requery (Some watched) = Some watched.

Theorem stale_slot_alias_does_not_solve_stock_node1e :
  ~ stale_slot_alias_solves_stock_node1e.
Proof.
  intros [watched Hsurvives].
  rewrite stock_node1e_requery_clears_every_stale_slot_alias in Hsurvives.
  discriminate.
Qed.

Definition coordinate_desync_solves_stock_node1e : Prop :=
  exists prior_pointer hypothetical_displaced_state object_y top_floor_y,
    spinning_top_owned_floor_height object_y top_floor_y /\
    platform_selection_position
      (stock_node1e_warp_frame_after_prior_requery
        prior_pointer hypothetical_displaced_state) =
      top_floor_position_at_node_xz top_floor_y.

Theorem coordinate_desync_does_not_solve_stock_node1e :
  ~ coordinate_desync_solves_stock_node1e.
Proof.
  intros
    (prior_pointer & hypothetical_displaced_state & object_y & top_floor_y &
     Htop & Hselection).
  rewrite stock_node1e_prior_requery_prevents_the_coordinate_desync in
    Hselection.
  cbn in Hselection.
  apply (a_spinning_top_floor_position_is_not_stock_node1e
    object_y top_floor_y Htop).
  symmetry.
  exact Hselection.
Qed.

Theorem stock_node1e_stale_alias_and_coordinate_desync_capstone :
  stock_node1e_alias_desync_source_certificate /\
  (forall watched,
    stock_node1e_platform_requery (Some watched) = None) /\
  (forall watched top_position,
    let after_displacement :=
      apply_state_only_displacement (Some watched) top_position
        (synchronized_coordinate_pair stock_node1e_position) in
    warp_collision_position after_displacement = stock_node1e_position) /\
  (forall prior_pointer hypothetical_displaced_state,
    stock_node1e_warp_frame_after_prior_requery
      prior_pointer hypothetical_displaced_state =
    synchronized_coordinate_pair stock_node1e_position).
Proof.
  split.
  - apply generated_stock_node1e_alias_desync_source_certificate.
  - split.
    + apply stock_node1e_requery_clears_every_stale_slot_alias.
    + split.
      * intros watched top_position.
        reflexivity.
      * apply stock_node1e_prior_requery_prevents_the_coordinate_desync.
Qed.
