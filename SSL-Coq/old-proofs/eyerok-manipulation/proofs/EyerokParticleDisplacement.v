From Coq Require Import Lia List ZArith.

Import ListNotations.
Local Open Scope Z_scope.

(** [obj_explode_and_spawn_coins] allocates mist and rotating triangles,
    marks the hand for deletion, and then allocates coins.  Marking only clears
    [activeFlags]; [unload_deactivated_objects] does not return the slot to the
    free list until the end-of-frame unload pass. *)
Inductive explosion_event : Type :=
| SpawnMist
| SpawnTriangle
| MarkHandForDeletion
| SpawnCoins
| UnloadHand.

Definition explosion_rank (event : explosion_event) : nat :=
  match event with
  | SpawnMist => 0
  | SpawnTriangle => 1
  | MarkHandForDeletion => 2
  | SpawnCoins => 3
  | UnloadHand => 4
  end.

Definition hand_slot_free_at (event : explosion_event) : Prop :=
  (explosion_rank UnloadHand <= explosion_rank event)%nat.

Lemma deletion_mark_does_not_free_hand_slot :
  ~ hand_slot_free_at MarkHandForDeletion.
Proof. unfold hand_slot_free_at, explosion_rank; lia. Qed.

Lemma own_triangles_spawn_before_hand_slot_is_free :
  ~ hand_slot_free_at SpawnTriangle.
Proof. unfold hand_slot_free_at, explosion_rank; lia. Qed.

Lemma coins_spawn_before_hand_slot_is_free :
  ~ hand_slot_free_at SpawnCoins.
Proof. unfold hand_slot_free_at, explosion_rank; lia. Qed.

(** The following finite event system models only the two Eyerok hands and the
    platform-pointer reuse interval.  It deliberately starts with the first
    hand already in its lethal animation; it is not a controller-reachability
    model.  The constructors encode the audited source facts needed by PPD:

    - while the first hand is dying, it owns the eye lock and the sibling is
      idle;
    - the first explosion clears the lock but merely marks the first hand;
    - depending on surface-list order, the sibling may be selected to OPEN
      before the end-of-frame unload, but its OPEN handler has not yet run;
    - OPEN requires 30 handler updates and DIE requires 40 handler updates;
    - a lethal hit is accepted only after SHOW_EYE is reached; and
    - the sibling fragment is allocated by the final DIE update.

    A transition whose source has [FirstHandUnloaded] represents one later
    surface-object update opportunity.  Thus a one-step run is exactly the
    dangerous next-frame interval before platform displacement consumes the
    stale pointer. *)
Inductive exposure_lock : Type :=
| NoEyeLock
| FirstHandEyeLock
| SiblingEyeLock.

Inductive first_hand_lifecycle : Type :=
| FirstHandDying (remaining : nat)
| FirstHandMarked
| FirstHandUnloaded.

Inductive sibling_lifecycle : Type :=
| SiblingIdle
| SiblingOpenSelected
| SiblingOpening (remaining : nat)
| SiblingEyeVisible
| SiblingDying (remaining : nat)
| SiblingFragmentSpawned.

Record ppd_state : Type := {
  ppd_first_hand : first_hand_lifecycle;
  ppd_eye_lock : exposure_lock;
  ppd_sibling : sibling_lifecycle
}.

Definition mk_ppd_state
    (first : first_hand_lifecycle)
    (lock : exposure_lock)
    (sibling : sibling_lifecycle) : ppd_state :=
  {| ppd_first_hand := first;
     ppd_eye_lock := lock;
     ppd_sibling := sibling |}.

Definition sibling_open_frames : nat := 30.
Definition sibling_die_frames : nat := 40.
Definition audited_sibling_animation_delay : nat :=
  sibling_open_frames + sibling_die_frames.
Definition stale_platform_window : nat := 1.

Inductive ppd_event_step : ppd_state -> ppd_state -> Prop :=
| StepFirstDeath : forall remaining,
    ppd_event_step
      (mk_ppd_state (FirstHandDying (S remaining))
        FirstHandEyeLock SiblingIdle)
      (mk_ppd_state (FirstHandDying remaining)
        FirstHandEyeLock SiblingIdle)
| StepFirstExplosion :
    ppd_event_step
      (mk_ppd_state (FirstHandDying 0) FirstHandEyeLock SiblingIdle)
      (mk_ppd_state FirstHandMarked NoEyeLock SiblingIdle)
| StepSelectSiblingBeforeUnload :
    ppd_event_step
      (mk_ppd_state FirstHandMarked NoEyeLock SiblingIdle)
      (mk_ppd_state FirstHandMarked NoEyeLock SiblingOpenSelected)
| StepUnloadWithIdleSibling :
    ppd_event_step
      (mk_ppd_state FirstHandMarked NoEyeLock SiblingIdle)
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingIdle)
| StepUnloadWithSelectedSibling :
    ppd_event_step
      (mk_ppd_state FirstHandMarked NoEyeLock SiblingOpenSelected)
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingOpenSelected)
| StepSelectSiblingAfterUnload :
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingIdle)
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingOpenSelected)
| StepStartSiblingOpen :
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingOpenSelected)
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingOpening (Nat.pred sibling_open_frames)))
| StepSiblingOpen : forall remaining,
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingOpening (S (S remaining))))
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingOpening (S remaining)))
| StepSiblingEyeVisible :
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock (SiblingOpening 1))
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock SiblingEyeVisible)
| StepAcceptSiblingLethalHit :
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock SiblingEyeVisible)
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingDying sibling_die_frames))
| StepSiblingDeath : forall remaining,
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingDying (S (S remaining))))
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock
        (SiblingDying (S remaining)))
| StepSiblingExplosion :
    ppd_event_step
      (mk_ppd_state FirstHandUnloaded SiblingEyeLock (SiblingDying 1))
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingFragmentSpawned).

Inductive ppd_steps : nat -> ppd_state -> ppd_state -> Prop :=
| PpdStepsZero : forall state, ppd_steps 0 state state
| PpdStepsSucc : forall count before middle after,
    ppd_event_step before middle ->
    ppd_steps count middle after ->
    ppd_steps (S count) before after.

Lemma first_dying_successor_keeps_sibling_blocked :
  forall remaining after,
    ppd_event_step
      (mk_ppd_state (FirstHandDying remaining)
        FirstHandEyeLock SiblingIdle) after ->
    ppd_sibling after = SiblingIdle.
Proof.
  intros remaining after Hstep.
  inversion Hstep; reflexivity.
Qed.

Lemma first_dying_successor_retains_lock_until_explosion :
  forall remaining after,
    ppd_event_step
      (mk_ppd_state (FirstHandDying remaining)
        FirstHandEyeLock SiblingIdle) after ->
    (exists next,
        remaining = S next /\
        after = mk_ppd_state (FirstHandDying next)
          FirstHandEyeLock SiblingIdle) \/
    (remaining = 0%nat /\
      after = mk_ppd_state FirstHandMarked NoEyeLock SiblingIdle).
Proof.
  intros remaining after Hstep.
  inversion Hstep; subst; eauto.
Qed.

Lemma first_dying_successor_cannot_start_sibling_open :
  forall remaining after,
    ppd_event_step
      (mk_ppd_state (FirstHandDying remaining)
        FirstHandEyeLock SiblingIdle) after ->
    ppd_sibling after <> SiblingOpenSelected.
Proof.
  intros remaining after Hstep.
  rewrite (first_dying_successor_keeps_sibling_blocked remaining after Hstep).
  discriminate.
Qed.

(** These are the only two post-unload states admitted by the audited
    same-frame hand order: the sibling either has not yet been selected, or its
    action is OPEN but its OPEN handler has not yet claimed the lock. *)
Inductive post_unload_seed : ppd_state -> Prop :=
| PostUnloadIdle :
    post_unload_seed
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingIdle)
| PostUnloadOpenSelected :
    post_unload_seed
      (mk_ppd_state FirstHandUnloaded NoEyeLock SiblingOpenSelected).

Lemma unload_transition_produces_post_unload_seed :
  forall before after,
    ppd_event_step before after ->
    ppd_first_hand before = FirstHandMarked ->
    ppd_first_hand after = FirstHandUnloaded ->
    post_unload_seed after.
Proof.
  intros before after Hstep Hbefore Hafter.
  inversion Hstep; subst; simpl in Hbefore, Hafter;
    try discriminate; constructor.
Qed.

(** Exact number of later surface-update opportunities needed by the abstract
    sibling control state.  The extra one between OPEN and DIE is the
    SHOW_EYE update that accepts the lethal hit. *)
Definition sibling_updates_remaining (phase : sibling_lifecycle) : nat :=
  match phase with
  | SiblingIdle => S (sibling_open_frames + 1 + sibling_die_frames)
  | SiblingOpenSelected => sibling_open_frames + 1 + sibling_die_frames
  | SiblingOpening remaining => remaining + 1 + sibling_die_frames
  | SiblingEyeVisible => S sibling_die_frames
  | SiblingDying remaining => remaining
  | SiblingFragmentSpawned => 0
  end.

Definition ppd_updates_remaining (state : ppd_state) : nat :=
  sibling_updates_remaining (ppd_sibling state).

Lemma post_unload_step_decreases_remaining :
  forall before after,
    ppd_event_step before after ->
    ppd_first_hand before = FirstHandUnloaded ->
    ppd_first_hand after = FirstHandUnloaded /\
    ppd_updates_remaining before = S (ppd_updates_remaining after).
Proof.
  intros before after Hstep Hunloaded.
  inversion Hstep; subst; simpl in Hunloaded; try discriminate.
  all: split.
  all: try reflexivity.
  all: unfold ppd_updates_remaining, sibling_updates_remaining,
    sibling_open_frames, sibling_die_frames; simpl; lia.
Qed.

Lemma post_unload_steps_account_for_remaining :
  forall count before after,
    ppd_steps count before after ->
    ppd_first_hand before = FirstHandUnloaded ->
    ppd_first_hand after = FirstHandUnloaded /\
    ppd_updates_remaining before =
      (count + ppd_updates_remaining after)%nat.
Proof.
  intros count before after Hsteps.
  induction Hsteps as
      [state | count before middle after Hstep Hsteps IH].
  - intros Hunloaded. split; [exact Hunloaded | reflexivity].
  - intros Hunloaded.
    destruct (post_unload_step_decreases_remaining
      before middle Hstep Hunloaded) as [Hmiddle Hdecrease].
    destruct (IH Hmiddle) as [Hafter Hremaining].
    split; [exact Hafter | lia].
Qed.

Lemma post_unload_seed_has_full_delay :
  forall state,
    post_unload_seed state ->
    (audited_sibling_animation_delay <= ppd_updates_remaining state)%nat.
Proof.
  intros state Hseed.
  inversion Hseed; subst;
    unfold audited_sibling_animation_delay, ppd_updates_remaining,
      sibling_updates_remaining, sibling_open_frames, sibling_die_frames;
    simpl; lia.
Qed.

Theorem sibling_fragment_requires_full_animation_delay :
  forall seed count after,
    post_unload_seed seed ->
    ppd_steps count seed after ->
    ppd_sibling after = SiblingFragmentSpawned ->
    (audited_sibling_animation_delay <= count)%nat.
Proof.
  intros seed count after Hseed Hsteps Hfragment.
  pose proof post_unload_seed_has_full_delay seed Hseed as Hdelay.
  pose proof post_unload_steps_account_for_remaining
    count seed after Hsteps as Haccount.
  assert (Hseed_unloaded : ppd_first_hand seed = FirstHandUnloaded).
  { inversion Hseed; reflexivity. }
  specialize (Haccount Hseed_unloaded).
  destruct Haccount as [_ Haccount].
  assert (Hafter_zero : ppd_updates_remaining after = 0%nat).
  { unfold ppd_updates_remaining. rewrite Hfragment. reflexivity. }
  rewrite Hafter_zero, Nat.add_0_r in Haccount.
  lia.
Qed.

Theorem sibling_fragment_misses_stale_platform_window :
  forall seed count after,
    post_unload_seed seed ->
    ppd_steps count seed after ->
    (count <= stale_platform_window)%nat ->
    ppd_sibling after <> SiblingFragmentSpawned.
Proof.
  intros seed count after Hseed Hsteps Hwindow Hfragment.
  pose proof sibling_fragment_requires_full_animation_delay
    seed count after Hseed Hsteps Hfragment.
  unfold audited_sibling_animation_delay, sibling_open_frames,
    sibling_die_frames, stale_platform_window in *.
  lia.
Qed.

Inductive eyerok_fragment_source : Type :=
| ExplodingHand
| SiblingHand.

Definition eyerok_slot_replacement_possible
    (source : eyerok_fragment_source) : Prop :=
  match source with
  | ExplodingHand => hand_slot_free_at SpawnTriangle
  | SiblingHand =>
      exists seed count after,
        post_unload_seed seed /\
        ppd_steps count seed after /\
        (count <= stale_platform_window)%nat /\
        ppd_sibling after = SiblingFragmentSpawned
  end.

Theorem no_eyerok_fragment_can_replace_stale_hand_slot :
  forall source, ~ eyerok_slot_replacement_possible source.
Proof.
  intros source; destruct source.
  - exact own_triangles_spawn_before_hand_slot_is_free.
  - unfold eyerok_slot_replacement_possible.
    intros [seed [count [after [Hseed [Hsteps [Hwindow Hfragment]]]]]].
    eapply (sibling_fragment_misses_stale_platform_window
      seed count after Hseed Hsteps Hwindow).
    exact Hfragment.
Qed.

(** On the pinned US build, [spawn_objects_from_info] executes
    [clear_mario_platform] when an area is loaded.  This separate transition
    model records the cross-area consequence: even a hypothetical stale hand
    pointer in Area 3 is not carried into Area 2.  The Japanese-version spawning
    displacement behavior is intentionally outside this US-only theorem. *)
Inductive ssl_area : Type :=
| PyramidArea2
| EyerokArea3.

Inductive saved_platform : Type :=
| NoSavedPlatform
| SavedEyerokHand
| SavedOtherPlatform.

Record area_platform_state : Type := {
  current_ssl_area : ssl_area;
  mario_saved_platform : saved_platform
}.

Definition us_load_area
    (destination : ssl_area) (_before : area_platform_state)
    : area_platform_state :=
  {| current_ssl_area := destination;
     mario_saved_platform := NoSavedPlatform |}.

Theorem us_area3_to_area2_clears_stale_eyerok_platform :
  forall before,
    current_ssl_area (us_load_area PyramidArea2 before) = PyramidArea2 /\
    mario_saved_platform (us_load_area PyramidArea2 before) = NoSavedPlatform.
Proof. intros; split; reflexivity. Qed.

(** The platform transform changes position and facing.  It preserves all
    stored speed components.  This is the semantic counterpart of the audit
    that the C helper writes position/yaw but neither [vel] nor [forwardVel]. *)
Record mario_kinematics : Type := {
  mario_x : Z;
  mario_y : Z;
  mario_z : Z;
  mario_face_yaw : Z;
  mario_vel_x : Z;
  mario_vel_y : Z;
  mario_vel_z : Z;
  mario_forward_vel : Z
}.

Definition apply_particle_platform_displacement
    (dx dy dz dyaw : Z) (mario : mario_kinematics) : mario_kinematics :=
  {| mario_x := mario_x mario + dx;
     mario_y := mario_y mario + dy;
     mario_z := mario_z mario + dz;
     mario_face_yaw := mario_face_yaw mario + dyaw;
     mario_vel_x := mario_vel_x mario;
     mario_vel_y := mario_vel_y mario;
     mario_vel_z := mario_vel_z mario;
     mario_forward_vel := mario_forward_vel mario |}.

Theorem particle_platform_displacement_preserves_speed :
  forall dx dy dz dyaw mario,
    let after := apply_particle_platform_displacement dx dy dz dyaw mario in
    mario_vel_x after = mario_vel_x mario /\
    mario_vel_y after = mario_vel_y mario /\
    mario_vel_z after = mario_vel_z mario /\
    mario_forward_vel after = mario_forward_vel mario.
Proof. intros; repeat split; reflexivity. Qed.

Definition eyerok_fragment_ppd_certificate : Prop :=
  ~ hand_slot_free_at SpawnTriangle /\
  ~ hand_slot_free_at MarkHandForDeletion /\
  (forall remaining after,
      ppd_event_step
        (mk_ppd_state (FirstHandDying remaining)
          FirstHandEyeLock SiblingIdle) after ->
      (exists next,
          remaining = S next /\
          after = mk_ppd_state (FirstHandDying next)
            FirstHandEyeLock SiblingIdle) \/
      (remaining = 0%nat /\
        after = mk_ppd_state FirstHandMarked NoEyeLock SiblingIdle)) /\
  (forall seed count after,
      post_unload_seed seed ->
      ppd_steps count seed after ->
      (count <= stale_platform_window)%nat ->
      ppd_sibling after <> SiblingFragmentSpawned) /\
  (forall source, ~ eyerok_slot_replacement_possible source) /\
  (forall dx dy dz dyaw mario,
      let after := apply_particle_platform_displacement dx dy dz dyaw mario in
      mario_vel_x after = mario_vel_x mario /\
      mario_vel_y after = mario_vel_y mario /\
      mario_vel_z after = mario_vel_z mario /\
      mario_forward_vel after = mario_forward_vel mario).

Theorem eyerok_fragment_ppd_certificate_holds :
  eyerok_fragment_ppd_certificate.
Proof.
  refine (conj own_triangles_spawn_before_hand_slot_is_free _).
  refine (conj deletion_mark_does_not_free_hand_slot _).
  refine (conj first_dying_successor_retains_lock_until_explosion _).
  refine (conj sibling_fragment_misses_stale_platform_window _).
  refine (conj no_eyerok_fragment_can_replace_stale_hand_slot _).
  exact particle_platform_displacement_preserves_speed.
Qed.

(** The same-area Eyerok-fragment result above is version-independent.  This
    additional certificate is specifically for the pinned US build, whose
    area loader clears [gMarioPlatform].  Original JP intentionally omits that
    call and is modeled separately in [JPPlatformPersistence]. *)
Definition us_eyerok_particle_displacement_certificate : Prop :=
  eyerok_fragment_ppd_certificate /\
  (forall before,
      current_ssl_area (us_load_area PyramidArea2 before) = PyramidArea2 /\
      mario_saved_platform (us_load_area PyramidArea2 before) =
        NoSavedPlatform).

Theorem us_eyerok_particle_displacement_certificate_holds :
  us_eyerok_particle_displacement_certificate.
Proof.
  split.
  - exact eyerok_fragment_ppd_certificate_holds.
  - exact us_area3_to_area2_clears_stale_eyerok_platform.
Qed.

(** Backward-compatible name retained for the original US-facing capstone. *)
Definition eyerok_particle_displacement_certificate : Prop :=
  us_eyerok_particle_displacement_certificate.

Theorem eyerok_particle_displacement_certificate_holds :
  eyerok_particle_displacement_certificate.
Proof. exact us_eyerok_particle_displacement_certificate_holds. Qed.
