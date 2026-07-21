From Coq Require Import FunctionalExtensionality List ZArith Lia.
From SSLSpawning.Proofs Require Import
  Spec PlatformDisplacement FreeListReuse GeneratedClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

(* The numbers below are observations from the supplied runtime snapshots.
   Object-list membership comes from the generated JP behavior scripts; pool
   slot numbers are allocation-history facts, not properties of a behavior. *)
Definition observed_klepto_slot : slot := 55.
Definition observed_pyramid_top_slot : slot := 60.
Definition observed_top_entry_warp_slot : slot := 63.

Definition obj_list_genactor : Z := 4.
Definition obj_list_level : Z := 6.
Definition obj_list_surface : Z := 9.

Theorem observed_slots_are_distinct_valid_pool_slots :
  1 <= observed_klepto_slot <= 240 /\
  1 <= observed_pyramid_top_slot <= 240 /\
  1 <= observed_top_entry_warp_slot <= 240 /\
  observed_klepto_slot <> observed_pyramid_top_slot /\
  observed_klepto_slot <> observed_top_entry_warp_slot /\
  observed_pyramid_top_slot <> observed_top_entry_warp_slot.
Proof.
  repeat split; discriminate || lia.
Qed.

Definition area_unload_by_groups
    (genactors level_objects default_objects surfaces
       polelike spawners unimportant : list slot) : list slot :=
  genactors ++ level_objects ++ default_objects ++ surfaces ++
  polelike ++ spawners ++ unimportant.

Theorem push_front_reverses_area_unload_groups :
  forall initial genactors level_objects default_objects surfaces
         polelike spawners unimportant,
    free_list_after_unloads initial
      (area_unload_by_groups genactors level_objects default_objects
        surfaces polelike spawners unimportant) =
    rev unimportant ++ rev spawners ++ rev polelike ++ rev surfaces ++
    rev default_objects ++ rev level_objects ++ rev genactors ++ initial.
Proof.
  intros.
  unfold free_list_after_unloads, area_unload_by_groups.
  repeat rewrite rev_app_distr.
  repeat rewrite <- app_assoc.
  reflexivity.
Qed.

Definition bulk_surface_reuse_index (surface_suffix : list slot) : nat :=
  S (length surface_suffix).

Definition bulk_level_reuse_index
    (surfaces level_suffix : list slot) : nat :=
  S (length surfaces + length level_suffix).

Theorem bulk_unloaded_surface_would_precede_level_warp :
  forall surface_prefix surface_suffix level_suffix,
    (bulk_surface_reuse_index surface_suffix <
    bulk_level_reuse_index
      (surface_prefix ++ observed_pyramid_top_slot :: surface_suffix)
      level_suffix)%nat.
Proof.
  intros.
  unfold bulk_surface_reuse_index, bulk_level_reuse_index.
  rewrite app_length.
  simpl.
  lia.
Qed.

(* The observed ordering is explained by a different sequence.  Slot 60 is
   freed before the bulk area unload.  During the bulk pass, Klepto (list 4)
   is encountered before node 1E (list 6).  Every push goes to the front. *)
Definition observed_bulk_unload_order
    (before_klepto between_klepto_and_warp after_warp : list slot)
    : list slot :=
  before_klepto ++ [observed_klepto_slot] ++
  between_klepto_and_warp ++ [observed_top_entry_warp_slot] ++ after_warp.

Definition observed_free_list_after_transition_unload
    (initial before_klepto between_klepto_and_warp after_warp : list slot)
    : list slot :=
  free_list_after_unloads initial
    (observed_pyramid_top_slot ::
      observed_bulk_unload_order
        before_klepto between_klepto_and_warp after_warp).

Definition observed_warp_reuse_index (after_warp : list slot) : nat :=
  S (length after_warp).

Definition observed_klepto_reuse_index
    (between_klepto_and_warp after_warp : list slot) : nat :=
  S (length after_warp + 1 + length between_klepto_and_warp).

Definition observed_pyramid_top_reuse_index
    (before_klepto between_klepto_and_warp after_warp : list slot) : nat :=
  S (length
    (observed_bulk_unload_order
      before_klepto between_klepto_and_warp after_warp)).

Theorem observed_transition_free_list_layout :
  forall initial before_klepto between_klepto_and_warp after_warp,
    observed_free_list_after_transition_unload
      initial before_klepto between_klepto_and_warp after_warp =
    rev after_warp ++ [observed_top_entry_warp_slot] ++
    rev between_klepto_and_warp ++ [observed_klepto_slot] ++
    rev before_klepto ++ [observed_pyramid_top_slot] ++ initial.
Proof.
  intros.
  unfold observed_free_list_after_transition_unload,
    observed_bulk_unload_order, free_list_after_unloads.
  simpl.
  rewrite rev_app_distr.
  simpl.
  rewrite rev_app_distr.
  simpl.
  repeat rewrite <- app_assoc.
  reflexivity.
Qed.

Theorem observed_slot_exact_reuse_indices :
  forall initial before_klepto between_klepto_and_warp after_warp,
    let free_list :=
      observed_free_list_after_transition_unload
        initial before_klepto between_klepto_and_warp after_warp in
    nth_allocation_reuses_slot free_list
      (observed_warp_reuse_index after_warp)
      observed_top_entry_warp_slot /\
    nth_allocation_reuses_slot free_list
      (observed_klepto_reuse_index between_klepto_and_warp after_warp)
      observed_klepto_slot /\
    nth_allocation_reuses_slot free_list
      (observed_pyramid_top_reuse_index
        before_klepto between_klepto_and_warp after_warp)
      observed_pyramid_top_slot.
Proof.
  intros initial before_klepto between_klepto_and_warp after_warp.
  rewrite observed_transition_free_list_layout.
  repeat split.
  - unfold observed_warp_reuse_index.
    rewrite <- rev_length.
    apply nth_allocation_exact_from_newer_slots.
  - unfold observed_klepto_reuse_index.
    replace
      (S (length after_warp + 1 + length between_klepto_and_warp))
      with
      (S (length
        (rev after_warp ++
          [observed_top_entry_warp_slot] ++
          rev between_klepto_and_warp))) by
        (repeat rewrite app_length; simpl; repeat rewrite rev_length; lia).
    assert (Hlayout :
      rev after_warp ++ [observed_top_entry_warp_slot] ++
      rev between_klepto_and_warp ++ [observed_klepto_slot] ++
      rev before_klepto ++ [observed_pyramid_top_slot] ++ initial =
      (rev after_warp ++ [observed_top_entry_warp_slot] ++
       rev between_klepto_and_warp) ++
      observed_klepto_slot ::
        (rev before_klepto ++ [observed_pyramid_top_slot] ++ initial)).
    {
      repeat rewrite <- app_assoc.
      reflexivity.
    }
    rewrite Hlayout.
    apply nth_allocation_exact_from_newer_slots.
  - unfold observed_pyramid_top_reuse_index,
      observed_bulk_unload_order.
    replace
      (S
        (length
          (before_klepto ++ [observed_klepto_slot] ++
           between_klepto_and_warp ++
           [observed_top_entry_warp_slot] ++ after_warp)))
      with
      (S (length
        (rev after_warp ++ [observed_top_entry_warp_slot] ++
         rev between_klepto_and_warp ++ [observed_klepto_slot] ++
         rev before_klepto))) by
        (repeat rewrite app_length; simpl; repeat rewrite rev_length; lia).
    assert (Hlayout :
      rev after_warp ++ [observed_top_entry_warp_slot] ++
      rev between_klepto_and_warp ++ [observed_klepto_slot] ++
      rev before_klepto ++ [observed_pyramid_top_slot] ++ initial =
      (rev after_warp ++ [observed_top_entry_warp_slot] ++
       rev between_klepto_and_warp ++ [observed_klepto_slot] ++
       rev before_klepto) ++ observed_pyramid_top_slot :: initial).
    {
      repeat rewrite <- app_assoc.
      reflexivity.
    }
    rewrite Hlayout.
    apply nth_allocation_exact_from_newer_slots.
Qed.

Theorem observed_reuse_order_is_warp_then_klepto_then_pyramid_top :
  forall before_klepto between_klepto_and_warp after_warp,
    (observed_warp_reuse_index after_warp <
      observed_klepto_reuse_index between_klepto_and_warp after_warp /\
    observed_klepto_reuse_index between_klepto_and_warp after_warp <
      observed_pyramid_top_reuse_index
        before_klepto between_klepto_and_warp after_warp)%nat.
Proof.
  intros.
  unfold observed_warp_reuse_index, observed_klepto_reuse_index,
    observed_pyramid_top_reuse_index, observed_bulk_unload_order.
  repeat rewrite app_length.
  simpl.
  lia.
Qed.

Definition allocation_count_leaves_watched_slot
    (free_list : free_list_slots) (watched : slot)
    (allocation_count : nat) : Prop :=
  exists newer older,
    free_list = newer ++ watched :: older /\
    (allocation_count <= length newer)%nat.

Lemma nth_allocation_within_count_is_reached :
  forall free_list watched allocation_index allocation_count,
    nth_allocation_reuses_slot free_list allocation_index watched ->
    (0 < allocation_index <= allocation_count)%nat ->
    allocation_count_reaches_watched_slot
      free_list watched allocation_count.
Proof.
  intros free_list watched allocation_index allocation_count Hnth Hbounds.
  unfold nth_allocation_reuses_slot in Hnth.
  apply nth_error_split in Hnth.
  destruct Hnth as (newer & older & Hfree & Hlength).
  exists newer, older.
  split; [exact Hfree |].
  rewrite Hlength.
  lia.
Qed.

Lemma nth_allocation_after_count_is_left :
  forall free_list watched allocation_index allocation_count,
    nth_allocation_reuses_slot free_list allocation_index watched ->
    (allocation_count < allocation_index)%nat ->
    allocation_count_leaves_watched_slot
      free_list watched allocation_count.
Proof.
  intros free_list watched allocation_index allocation_count Hnth Hafter.
  unfold nth_allocation_reuses_slot in Hnth.
  apply nth_error_split in Hnth.
  destruct Hnth as (newer & older & Hfree & Hlength).
  exists newer, older.
  split; [exact Hfree |].
  rewrite Hlength.
  lia.
Qed.

Theorem warp_slot_can_be_reused_while_klepto_and_top_slots_remain_free :
  forall initial before_klepto between_klepto_and_warp after_warp
         allocation_count,
    let free_list :=
      observed_free_list_after_transition_unload
        initial before_klepto between_klepto_and_warp after_warp in
    (observed_warp_reuse_index after_warp <= allocation_count)%nat ->
    (allocation_count <
      observed_klepto_reuse_index
        between_klepto_and_warp after_warp)%nat ->
    allocation_count_reaches_watched_slot free_list
      observed_top_entry_warp_slot allocation_count /\
    allocation_count_leaves_watched_slot free_list
      observed_klepto_slot allocation_count /\
    allocation_count_leaves_watched_slot free_list
      observed_pyramid_top_slot allocation_count.
Proof.
  intros initial before_klepto between_klepto_and_warp after_warp
    allocation_count.
  cbn.
  intros Hwarp Hklepto.
  pose proof
    (observed_slot_exact_reuse_indices initial before_klepto
      between_klepto_and_warp after_warp) as Hexact.
  destruct Hexact as [HexactWarp [HexactKlepto HexactTop]].
  pose proof
    (observed_reuse_order_is_warp_then_klepto_then_pyramid_top
      before_klepto between_klepto_and_warp after_warp)
    as [HorderWarp HorderTop].
  repeat split.
  - eapply nth_allocation_within_count_is_reached; eauto.
    split.
    + unfold observed_warp_reuse_index.
      apply Nat.lt_0_succ.
    + exact Hwarp.
  - eapply nth_allocation_after_count_is_left; eauto.
  - eapply nth_allocation_after_count_is_left; eauto.
    lia.
Qed.

Definition inactive_version (fields : object_fields) : object_fields := {|
  field_kind := field_kind fields;
  field_active := false;
  field_oVelX := field_oVelX fields;
  field_oVelY := field_oVelY fields;
  field_oVelZ := field_oVelZ fields;
  field_oAngleVelPitch := field_oAngleVelPitch fields;
  field_oAngleVelYaw := field_oAngleVelYaw fields;
  field_oAngleVelRoll := field_oAngleVelRoll fields;
  field_oFaceAnglePitch := field_oFaceAnglePitch fields;
  field_oFaceAngleYaw := field_oFaceAngleYaw fields;
  field_oFaceAngleRoll := field_oFaceAngleRoll fields
|}.

Record synchronized_top_frame_state : Type := {
  synchronized_top_active : bool;
  synchronized_top_collision_loaded : bool;
  synchronized_top_slot_is_free : bool;
  synchronized_platform_pointer : option slot;
  synchronized_top_fields : object_fields;
  synchronized_free_list : list slot
}.

Definition top_frame_before_explosion
    (initial_free_list : list slot) (fields : object_fields)
    : synchronized_top_frame_state := {|
  synchronized_top_active := true;
  synchronized_top_collision_loaded := false;
  synchronized_top_slot_is_free := false;
  synchronized_platform_pointer := None;
  synchronized_top_fields := fields;
  synchronized_free_list := initial_free_list
|}.

Definition top_explodes_and_loads_collision
    (state : synchronized_top_frame_state)
    : synchronized_top_frame_state := {|
  synchronized_top_active := false;
  synchronized_top_collision_loaded := true;
  synchronized_top_slot_is_free := synchronized_top_slot_is_free state;
  synchronized_platform_pointer := synchronized_platform_pointer state;
  synchronized_top_fields := inactive_version (synchronized_top_fields state);
  synchronized_free_list := synchronized_free_list state
|}.

Definition unload_deactivated_top
    (state : synchronized_top_frame_state)
    : synchronized_top_frame_state := {|
  synchronized_top_active := synchronized_top_active state;
  synchronized_top_collision_loaded :=
    synchronized_top_collision_loaded state;
  synchronized_top_slot_is_free := true;
  synchronized_platform_pointer := synchronized_platform_pointer state;
  synchronized_top_fields := synchronized_top_fields state;
  synchronized_free_list :=
    observed_pyramid_top_slot :: synchronized_free_list state
|}.

Definition select_loaded_top_floor
    (state : synchronized_top_frame_state)
    : synchronized_top_frame_state := {|
  synchronized_top_active := synchronized_top_active state;
  synchronized_top_collision_loaded :=
    synchronized_top_collision_loaded state;
  synchronized_top_slot_is_free := synchronized_top_slot_is_free state;
  synchronized_platform_pointer :=
    if synchronized_top_collision_loaded state
    then Some observed_pyramid_top_slot
    else None;
  synchronized_top_fields := synchronized_top_fields state;
  synchronized_free_list := synchronized_free_list state
|}.

Definition synchronized_last_normal_frame
    (initial_free_list : list slot) (fields : object_fields)
    : synchronized_top_frame_state :=
  select_loaded_top_floor
    (unload_deactivated_top
      (top_explodes_and_loads_collision
        (top_frame_before_explosion initial_free_list fields))).

Theorem final_normal_frame_can_reselect_already_freed_top_slot :
  forall initial_free_list fields,
    let after := synchronized_last_normal_frame initial_free_list fields in
    synchronized_top_active after = false /\
    synchronized_top_collision_loaded after = true /\
    synchronized_top_slot_is_free after = true /\
    synchronized_platform_pointer after = Some observed_pyramid_top_slot /\
    synchronized_top_fields after = inactive_version fields /\
    synchronized_free_list after =
      observed_pyramid_top_slot :: initial_free_list.
Proof.
  intros.
  repeat split.
Qed.

Definition bulk_unload_after_synchronized_frame
    (bulk_unload_order : list slot) (state : synchronized_top_frame_state)
    : synchronized_top_frame_state := {|
  synchronized_top_active := synchronized_top_active state;
  synchronized_top_collision_loaded :=
    synchronized_top_collision_loaded state;
  synchronized_top_slot_is_free := synchronized_top_slot_is_free state;
  synchronized_platform_pointer := synchronized_platform_pointer state;
  synchronized_top_fields := synchronized_top_fields state;
  synchronized_free_list :=
    free_list_after_unloads
      (synchronized_free_list state) bulk_unload_order
|}.

Theorem later_bulk_unload_buries_top_without_changing_the_pointer_or_fields :
  forall initial_free_list fields bulk_unload_order,
    let after_final_frame :=
      synchronized_last_normal_frame initial_free_list fields in
    let after_bulk :=
      bulk_unload_after_synchronized_frame
        bulk_unload_order after_final_frame in
    synchronized_platform_pointer after_bulk =
      Some observed_pyramid_top_slot /\
    synchronized_top_fields after_bulk = inactive_version fields /\
    synchronized_free_list after_bulk =
      rev bulk_unload_order ++ observed_pyramid_top_slot :: initial_free_list.
Proof.
  intros.
  repeat split.
Qed.

Definition allocation_cleared_fields : object_fields := {|
  field_kind := KindOther;
  field_active := true;
  field_oVelX := 0;
  field_oVelY := 0;
  field_oVelZ := 0;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition write_slot
    (memory : slot -> object_fields) (written : slot)
    (value : object_fields) : slot -> object_fields :=
  fun queried => if Z.eqb queried written then value else memory queried.

Fixpoint allocate_n_reset
    (allocation_count : nat) (free_list : list slot)
    (memory : slot -> object_fields)
    : list slot * (slot -> object_fields) :=
  match allocation_count, free_list with
  | O, _ => (free_list, memory)
  | S _, [] => ([], memory)
  | S remaining, allocated :: rest =>
      allocate_n_reset remaining rest
        (write_slot memory allocated allocation_cleared_fields)
  end.

Theorem unload_preserves_all_platform_displacement_fields :
  forall fields,
    field_active (inactive_version fields) = false /\
    field_oVelX (inactive_version fields) = field_oVelX fields /\
    field_oVelZ (inactive_version fields) = field_oVelZ fields /\
    field_oAngleVelPitch (inactive_version fields) =
      field_oAngleVelPitch fields /\
    field_oAngleVelYaw (inactive_version fields) =
      field_oAngleVelYaw fields /\
    field_oAngleVelRoll (inactive_version fields) =
      field_oAngleVelRoll fields.
Proof.
  intros.
  repeat split.
Qed.

Lemma writing_distinct_slot_preserves_watched :
  forall memory written watched value,
    written <> watched ->
    write_slot memory written value watched = memory watched.
Proof.
  intros memory written watched value Hdistinct.
  unfold write_slot.
  apply Z.eqb_neq in Hdistinct.
  rewrite Z.eqb_sym, Hdistinct.
  reflexivity.
Qed.

Theorem allocations_before_watched_preserve_its_fields :
  forall newer watched older allocation_count memory,
    NoDup (newer ++ watched :: older) ->
    (allocation_count <= length newer)%nat ->
    snd
      (allocate_n_reset allocation_count
        (newer ++ watched :: older) memory) watched = memory watched.
Proof.
  intros newer watched older allocation_count.
  revert newer watched older.
  induction allocation_count as [| allocation_count IH];
    intros newer watched older memory Hnodup Hcount.
  - reflexivity.
  - destruct newer as [| newest newer].
    + simpl in Hcount.
      lia.
    + simpl in Hcount.
      cbn [allocate_n_reset].
      change (NoDup (newest :: (newer ++ watched :: older))) in Hnodup.
      apply NoDup_cons_iff in Hnodup.
      destruct Hnodup as [Hnotin Htail].
      transitivity
        ((write_slot memory newest allocation_cleared_fields) watched).
      * apply IH; try assumption.
        lia.
      * apply writing_distinct_slot_preserves_watched.
        intro Hequal.
        apply Hnotin.
        subst newest.
        apply in_or_app.
        right.
        simpl.
        auto.
Qed.

Theorem unreached_watched_slot_keeps_stale_fields :
  forall free_list watched allocation_count memory,
    NoDup free_list ->
    allocation_count_leaves_watched_slot
      free_list watched allocation_count ->
    snd (allocate_n_reset allocation_count free_list memory) watched =
      memory watched.
Proof.
  intros free_list watched allocation_count memory Hnodup Hleft.
  destruct Hleft as (newer & older & Hfree & Hcount).
  subst free_list.
  eapply allocations_before_watched_preserve_its_fields; eauto.
Qed.

Definition stale_exploded_pyramid_top_fields : object_fields := {|
  field_kind := KindPyramidTop;
  field_active := false;
  field_oVelX := 0;
  field_oVelY := 5;
  field_oVelZ := 0;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 6144;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition default_inactive_fields : object_fields := {|
  field_kind := KindOther;
  field_active := false;
  field_oVelX := 0;
  field_oVelY := 0;
  field_oVelZ := 0;
  field_oAngleVelPitch := 0;
  field_oAngleVelYaw := 0;
  field_oAngleVelRoll := 0;
  field_oFaceAnglePitch := 0;
  field_oFaceAngleYaw := 0;
  field_oFaceAngleRoll := 0
|}.

Definition memory_with_stale_pyramid_top : slot -> object_fields :=
  write_slot (fun _ => default_inactive_fields)
    observed_pyramid_top_slot stale_exploded_pyramid_top_fields.

Definition destination_state_after_allocations
    (allocation_count : nat) (free_list : list slot) : game_state :=
  let result :=
    allocate_n_reset allocation_count free_list
      memory_with_stale_pyramid_top in
  {|
    state_mario := {|
      mario_pos_x := 0;
      mario_pos_y := 5500;
      mario_pos_z := 256;
      mario_face_yaw := 0
    |};
    state_gMarioPlatform := Some observed_pyramid_top_slot;
    state_has_mario_object := true;
    state_time_stop_active := false;
    state_object_memory := snd result;
    state_free_list := fst result
  |}.

Theorem stale_pyramid_top_fields_have_capped_yaw :
  field_active stale_exploded_pyramid_top_fields = false /\
  field_oVelX stale_exploded_pyramid_top_fields = 0 /\
  field_oVelZ stale_exploded_pyramid_top_fields = 0 /\
  field_oAngleVelPitch stale_exploded_pyramid_top_fields = 0 /\
  field_oAngleVelYaw stale_exploded_pyramid_top_fields = 6144 /\
  field_oAngleVelRoll stale_exploded_pyramid_top_fields = 0.
Proof.
  repeat split.
Qed.

Theorem unreused_pyramid_top_slot_drives_first_area2_displacement :
  forall free_list allocation_count,
    NoDup free_list ->
    allocation_count_leaves_watched_slot free_list
      observed_pyramid_top_slot allocation_count ->
    exists observation,
      apply_mario_platform_displacement_model
        (destination_state_after_allocations allocation_count free_list) =
        Some observation /\
      observation_slot observation = observed_pyramid_top_slot /\
      observation_oVelX observation = 0 /\
      observation_oVelZ observation = 0 /\
      observation_oAngleVelPitch observation = 0 /\
      observation_oAngleVelYaw observation = 6144 /\
      observation_oAngleVelRoll observation = 0 /\
      observation_checked_active_flags observation = false.
Proof.
  intros free_list allocation_count Hnodup Hleft.
  pose proof
    (unreached_watched_slot_keeps_stale_fields
      free_list observed_pyramid_top_slot allocation_count
      memory_with_stale_pyramid_top Hnodup Hleft) as Hmemory.
  assert (Hinitial :
    memory_with_stale_pyramid_top observed_pyramid_top_slot =
      stale_exploded_pyramid_top_fields).
  {
    unfold memory_with_stale_pyramid_top, write_slot.
    rewrite Z.eqb_refl.
    reflexivity.
  }
  unfold destination_state_after_allocations,
    apply_mario_platform_displacement_model.
  simpl.
  eexists.
  split; [reflexivity |].
  rewrite Hmemory, Hinitial.
  repeat split.
Qed.

Theorem generated_jp_clight_observed_pyramid_top_slot_capstone :
  jp_pyramid_top_slot_source_certificate /\
  (forall initial before_klepto between_klepto_and_warp after_warp
          allocation_count,
    let free_list :=
      observed_free_list_after_transition_unload
        initial before_klepto between_klepto_and_warp after_warp in
    NoDup free_list ->
    (observed_warp_reuse_index after_warp <= allocation_count)%nat ->
    (allocation_count <
      observed_klepto_reuse_index
        between_klepto_and_warp after_warp)%nat ->
    allocation_count_reaches_watched_slot free_list
      observed_top_entry_warp_slot allocation_count /\
    allocation_count_leaves_watched_slot free_list
      observed_klepto_slot allocation_count /\
    allocation_count_leaves_watched_slot free_list
      observed_pyramid_top_slot allocation_count /\
    exists observation,
      apply_mario_platform_displacement_model
        (destination_state_after_allocations allocation_count free_list) =
        Some observation /\
      observation_slot observation = observed_pyramid_top_slot /\
      observation_oAngleVelYaw observation = 6144 /\
      observation_checked_active_flags observation = false).
Proof.
  split.
  - apply generated_jp_pyramid_top_slot_source_certificate.
  - intros initial before_klepto between_klepto_and_warp after_warp
      allocation_count.
    cbn.
    intros Hnodup Hwarp Hklepto.
    pose proof
      (warp_slot_can_be_reused_while_klepto_and_top_slots_remain_free
        initial before_klepto between_klepto_and_warp after_warp
        allocation_count Hwarp Hklepto) as Hslots.
    destruct Hslots as [HwarpReached [HkleptoLeft HtopLeft]].
    repeat split; try assumption.
    destruct
      (unreused_pyramid_top_slot_drives_first_area2_displacement
        (observed_free_list_after_transition_unload
          initial before_klepto between_klepto_and_warp after_warp)
        allocation_count Hnodup HtopLeft)
      as (observation & Happly & Hslot & _ & _ & _ & Hyaw & _ & Hactive).
    exists observation.
    repeat split; assumption.
Qed.
