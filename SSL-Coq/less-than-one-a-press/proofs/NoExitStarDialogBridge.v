(** The stock no-exit-star/dialog bridge, at a deliberately narrow boundary.

    A candidate negative-quicksand installer needs an already-tangible
    no-exit star on the collision pass after the landing writer.  Source
    review found the stock 100-coin star as the only ordinary SSL Area-1
    candidate; that whole-program source census is not a theorem in this
    module.  Its freshly spawned instance is not immediately tangible:

    - object collisions run before non-terrain object updates;
    - the player list runs before the level list containing the spawned star;
    - action 2 clears the star-spawn time stop and advances the action, but the
      hitbox helper is reached only by a later action-3 update; and
    - consequently one unstopped Mario update lies between the clear and the
      first collision pass that can observe the installed hitbox.

    The generated-AST receipts below pin the relevant US/JP data and call
    footprints.  They are not a linked small-step proof of the branch history.
    The finite lifecycle model encodes one unstopped Mario update before the
    first hitbox-eligible collision and proves consequences of that encoded
    chronology.  Importantly, that update does
    not eliminate every late-landing payload: a post-timer-4, -0.5f state is
    first clamped/incremented to 1.35f and then reaches the timer-5 landing
    write, ending at -2.65f.  A post-timer-5, -4.0f state instead exits at
    timer 6; the action loop then runs the stationary updater and ends at
    positive 1.85f.  Thus timing alone does not rule out
    a freshly spawned star; its vertical placement remains a separate gap.

    The file also proves that the finite prepared vertical orbit settles five
    units below the +250 home Y, checks the corresponding binary32 home and
    first-hitbox words for the measured F endpoint, and derives the modeled
    160/50-hitbox interval.  It proves the one-star milestone condition and
    the large XZ separation from the fixed upper warp.  It does not refine the
    full orbit through linked memory, execute the live hitbox-overlap routine,
    prove clean zero-A reachability of the landing writer, exclude older stock
    stars, or close every raw-coordinate writer. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Floats Integers.
From LessThanOneAPress.Proofs Require Import ASTFacts ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

(** * Bilateral generated receipts *)

Fixpoint nesdb_init_int8_values (values : list init_data) : list Z :=
  match values with
  | [] => []
  | Init_int8 value :: rest =>
      Int.signed value :: nesdb_init_int8_values rest
  | _ :: rest => nesdb_init_int8_values rest
  end.

Theorem no_exit_star_hitbox_initializer_exact_us_jp :
  gvar_init UBA.v_sSparkleSpawnStarHitbox =
    [Init_int32 (Int.repr 4096);
     Init_int8 (Int.repr 0); Init_int8 (Int.repr 0);
     Init_int8 (Int.repr 0); Init_int8 (Int.repr 0);
     Init_int16 (Int.repr 80); Init_int16 (Int.repr 50);
     Init_int16 (Int.repr 0); Init_int16 (Int.repr 0)] /\
  gvar_init JBA.v_sSparkleSpawnStarHitbox =
    [Init_int32 (Int.repr 4096);
     Init_int8 (Int.repr 0); Init_int8 (Int.repr 0);
     Init_int8 (Int.repr 0); Init_int8 (Int.repr 0);
     Init_int16 (Int.repr 80); Init_int16 (Int.repr 50);
     Init_int16 (Int.repr 0); Init_int16 (Int.repr 0)].
Proof. vm_compute. split; reflexivity. Qed.

Theorem no_exit_star_behavior_initializer_exact_us_jp :
  gvar_init UBD.v_bhvSpawnedStarNoLevelExit =
    [Init_int32 (Int.repr 393216);
     Init_int32 (Int.repr 285278209);
     Init_int32 (Int.repr 754974720);
     Init_int32 (Int.repr 201326592);
     Init_addrof UBD._bhv_spawned_star_init (Ptrofs.repr 0);
     Init_int32 (Int.repr 134217728);
     Init_int32 (Int.repr 201326592);
     Init_addrof UBD._bhv_spawned_star_loop (Ptrofs.repr 0);
     Init_int32 (Int.repr 150994944)] /\
  gvar_init JBD.v_bhvSpawnedStarNoLevelExit =
    [Init_int32 (Int.repr 393216);
     Init_int32 (Int.repr 285278209);
     Init_int32 (Int.repr 754974720);
     Init_int32 (Int.repr 201326592);
     Init_addrof JBD._bhv_spawned_star_init (Ptrofs.repr 0);
     Init_int32 (Int.repr 134217728);
     Init_int32 (Int.repr 201326592);
     Init_addrof JBD._bhv_spawned_star_loop (Ptrofs.repr 0);
     Init_int32 (Int.repr 150994944)].
Proof. vm_compute. split; reflexivity. Qed.

(** Numeric object-list order: player [0] precedes level [6]. *)
Theorem object_list_update_order_exact_us_jp :
  nesdb_init_int8_values (gvar_init UOL.v_sObjectListUpdateOrder) =
    [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
  nesdb_init_int8_values (gvar_init JOL.v_sObjectListUpdateOrder) =
    [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1].
Proof. vm_compute. split; reflexivity. Qed.

Theorem star_dialog_milestones_exact_us_jp :
  nesdb_init_int8_values
    (gvar_init UCutscene.v_sStarsNeededForDialog) =
      [1; 3; 8; 30; 50; 70] /\
  nesdb_init_int8_values
    (gvar_init JCutscene.v_sStarsNeededForDialog) =
      [1; 3; 8; 30; 50; 70].
Proof. vm_compute. split; reflexivity. Qed.

(** These call footprints pin the source chronology components, but a
    subsequence/call-presence result is not branch execution. *)
Definition no_exit_star_bridge_source_shape_claim : Prop :=
  ident_subsequenceb
    [UOL._detect_object_collisions; UOL._update_non_terrain_objects]
    (direct_callees_s (fn_body UOL.f_update_objects)) = true /\
  ident_subsequenceb
    [JOL._detect_object_collisions; JOL._update_non_terrain_objects]
    (direct_callees_s (fn_body JOL.f_update_objects)) = true /\
  calls_ident_s UBA._set_home_to_mario
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s UBA._clear_time_stop_flags
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s UBA._set_sparkle_spawn_star_hitbox
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s UBA._cur_obj_move_using_fvel_and_gravity
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1082130432
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1101004800
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1065353216
    (fn_body UBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1132068864
    (fn_body UBA.f_set_home_to_mario) = true /\
  calls_ident_s JBA._set_home_to_mario
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s JBA._clear_time_stop_flags
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s JBA._set_sparkle_spawn_star_hitbox
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  calls_ident_s JBA._cur_obj_move_using_fvel_and_gravity
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1112014848
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1082130432
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1101004800
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1065353216
    (fn_body JBA.f_bhv_spawned_star_loop) = true /\
  statement_mentions_float32_bits_s 1132068864
    (fn_body JBA.f_set_home_to_mario) = true /\
  ident_subsequenceb
    [UCutscene._general_star_dance_handler;
     UCutscene._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body UCutscene.f_act_star_dance)) = true /\
  ident_subsequenceb
    [JCutscene._general_star_dance_handler;
     JCutscene._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body JCutscene.f_act_star_dance)) = true /\
  calls_ident_s UCutscene._create_dialog_box_with_response
    (fn_body UCutscene.f_general_star_dance_handler) = true /\
  calls_ident_s UCutscene._get_star_collection_dialog
    (fn_body UCutscene.f_general_star_dance_handler) = true /\
  calls_ident_s UCutscene._act_reading_automatic_dialog
    (fn_body UCutscene.f_mario_execute_cutscene_action) = true /\
  calls_ident_s JCutscene._create_dialog_box_with_response
    (fn_body JCutscene.f_general_star_dance_handler) = true /\
  calls_ident_s JCutscene._get_star_collection_dialog
    (fn_body JCutscene.f_general_star_dance_handler) = true /\
  calls_ident_s JCutscene._act_reading_automatic_dialog
    (fn_body JCutscene.f_mario_execute_cutscene_action) = true.

Theorem no_exit_star_bridge_source_shape_checked :
  no_exit_star_bridge_source_shape_claim.
Proof.
  unfold no_exit_star_bridge_source_shape_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Fresh-star lifecycle consequence *)

Inductive FreshStarPhase : Type :=
| FreshStarActionTwoTimeStopped
| FreshStarClearedNoHitbox
| FreshStarHitboxInstalled.

Definition fresh_star_collision_eligible (phase : FreshStarPhase) : bool :=
  match phase with
  | FreshStarHitboxInstalled => true
  | _ => false
  end.

(** An exact finite abstraction of the two decisive object-lifecycle frames.
    The action-2 update clears time stop but does not execute the action-3
    hitbox arm.  On the next frame collision still sees no hitbox; Mario
    updates, and the later level-list update installs it.  Depth is kept out
    of this phase model because the intervening moving-action update has two
    materially different late-landing outcomes, proved below. *)
Definition fresh_star_phase_frame (phase : FreshStarPhase) : FreshStarPhase :=
  match phase with
  | FreshStarActionTwoTimeStopped =>
      FreshStarClearedNoHitbox
  | FreshStarClearedNoHitbox =>
      FreshStarHitboxInstalled
  | FreshStarHitboxInstalled =>
      FreshStarHitboxInstalled
  end.

Theorem freshly_spawned_star_has_a_noncollidable_clear_frame :
  fresh_star_collision_eligible
    (fresh_star_phase_frame FreshStarActionTwoTimeStopped) = false.
Proof. reflexivity. Qed.

Theorem freshly_spawned_star_first_eligible_after_gap_frame :
  fresh_star_collision_eligible
    (fresh_star_phase_frame
      (fresh_star_phase_frame FreshStarActionTwoTimeStopped)) = true.
Proof. reflexivity. Qed.

(** Exact binary32 replay of the intervening moving-action update.  The
    quicksand updater clamps a negative value to 1.1f and adds 0.25f.  When
    the previous writer ended at post timer 4, [common_landing_cancels]
    advances 4 to 5 and the landing body adds -4.0f in the same frame.  When
    the previous writer ended at post timer 5, advancing to 6 exits before
    the landing body, installs the landing-stop action, and the same
    [execute_mario_action] loop reaches the stationary +0.5f updater.  These
    are arithmetic mirrors; linked branch execution and memory refinement
    remain in the obligation below. *)
Definition nesdb_b32_zero : float32 :=
  Float32.of_bits (Int.repr 0).
Definition nesdb_b32_one_point_one : float32 :=
  Float32.of_bits (Int.repr 1066192077).
Definition nesdb_b32_quarter : float32 :=
  Float32.of_bits (Int.repr 1048576000).
Definition nesdb_b32_half : float32 :=
  Float32.of_bits (Int.repr 1056964608).
Definition nesdb_b32_four : float32 :=
  Float32.of_bits (Int.repr 1082130432).
Definition nesdb_b32_negative_half : float32 :=
  Float32.of_bits (Int.repr 3204448256).
Definition nesdb_b32_negative_four : float32 :=
  Float32.of_bits (Int.repr 3229614080).

Definition fresh_star_intervening_moving_quicksand_update
    (before : float32) : float32 :=
  Float32.add
    (if Float32.cmp Clt before nesdb_b32_one_point_one
     then nesdb_b32_one_point_one
     else before)
    nesdb_b32_quarter.

Definition fresh_star_post_timer_four_followup_depth : float32 :=
  Float32.sub
    (fresh_star_intervening_moving_quicksand_update
      nesdb_b32_negative_half)
    nesdb_b32_four.

Definition fresh_star_post_timer_five_followup_depth : float32 :=
  Float32.add
    (fresh_star_intervening_moving_quicksand_update
      nesdb_b32_negative_four)
    nesdb_b32_half.

Theorem fresh_star_late_landing_followup_binary32_split_checked :
  Float32.to_bits
    (fresh_star_intervening_moving_quicksand_update
      nesdb_b32_negative_half) = Int.repr 1068289229 /\
  Float32.to_bits
    (fresh_star_intervening_moving_quicksand_update
      nesdb_b32_negative_four) = Int.repr 1068289229 /\
  Float32.to_bits fresh_star_post_timer_four_followup_depth =
    Int.repr 3223951770 /\
  Float32.cmp Clt fresh_star_post_timer_four_followup_depth
    nesdb_b32_zero = true /\
  Float32.to_bits fresh_star_post_timer_five_followup_depth =
    Int.repr 1072483533 /\
  Float32.cmp Clt fresh_star_post_timer_five_followup_depth
    nesdb_b32_zero = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Retail use of the phase and arithmetic results requires this refinement,
    rather than assuming that either finite mirror is the generated program. *)
Definition FreshStarGapFrameClightRefinementObligation
    {State : Type}
    (action_two_clear : State -> State -> Prop)
    (first_unstopped_mario_and_level_update : State -> State -> Prop)
    (first_star_eligible_collision : State -> Prop)
    (post_timer_four_negative : State -> Prop)
    (post_timer_five_nonnegative : State -> Prop) : Prop :=
  forall before after_clear after_update,
    action_two_clear before after_clear ->
    first_unstopped_mario_and_level_update after_clear after_update ->
    first_star_eligible_collision after_update /\
    (post_timer_four_negative after_update \/
     post_timer_five_nonnegative after_update).

(** * Fresh-star vertical orbit and first-hitbox interval *)

Inductive FreshStarVerticalPhase : Type :=
| FreshStarRise
| FreshStarBounce
| FreshStarWaitForCamera
| FreshStarTangible.

Record FreshStarVerticalState : Type := {
  fresh_star_vertical_phase : FreshStarVerticalPhase;
  fresh_star_relative_y : Z;
  fresh_star_velocity_y : Z;
  fresh_star_gravity_y : Z
}.

Definition fresh_star_vertical_initial : FreshStarVerticalState :=
  {| fresh_star_vertical_phase := FreshStarRise;
     fresh_star_relative_y := 0;
     fresh_star_velocity_y := 50;
     fresh_star_gravity_y := -4 |}.

(** The source loop tests the action branch first, then its common tail does
    [velY += gravity; posY += velY].  This integer mirror is exact for the
    prepared relative orbit; the binary32/12k/live-memory connection remains
    an explicit obligation below. *)
Definition fresh_star_vertical_move_tail
    (phase : FreshStarVerticalPhase)
    (position velocity gravity : Z) : FreshStarVerticalState :=
  let velocity' := velocity + gravity in
  {| fresh_star_vertical_phase := phase;
     fresh_star_relative_y := position + velocity';
     fresh_star_velocity_y := velocity';
     fresh_star_gravity_y := gravity |}.

Definition fresh_star_vertical_tick
    (state : FreshStarVerticalState) : FreshStarVerticalState :=
  match fresh_star_vertical_phase state with
  | FreshStarRise =>
      if (fresh_star_velocity_y state <? 0) &&
         (fresh_star_relative_y state <? 0)
      then fresh_star_vertical_move_tail FreshStarBounce
             (fresh_star_relative_y state) 20 (-1)
      else fresh_star_vertical_move_tail FreshStarRise
             (fresh_star_relative_y state)
             (fresh_star_velocity_y state)
             (fresh_star_gravity_y state)
  | FreshStarBounce =>
      let capped_velocity :=
        if fresh_star_velocity_y state <? -4
        then -4 else fresh_star_velocity_y state in
      if (capped_velocity <? 0) && (fresh_star_relative_y state <? 0)
      then fresh_star_vertical_move_tail FreshStarWaitForCamera
             (fresh_star_relative_y state) 0 0
      else fresh_star_vertical_move_tail FreshStarBounce
             (fresh_star_relative_y state) capped_velocity
             (fresh_star_gravity_y state)
  | FreshStarWaitForCamera => state
  | FreshStarTangible => state
  end.

Definition fresh_star_install_hitbox
    (state : FreshStarVerticalState) : FreshStarVerticalState :=
  match fresh_star_vertical_phase state with
  | FreshStarWaitForCamera =>
      {| fresh_star_vertical_phase := FreshStarTangible;
         fresh_star_relative_y := fresh_star_relative_y state;
         fresh_star_velocity_y := fresh_star_velocity_y state;
         fresh_star_gravity_y := fresh_star_gravity_y state |}
  | _ => state
  end.

Theorem fresh_star_prepared_vertical_orbit_settles_five_below_home :
  Nat.iter 77 fresh_star_vertical_tick fresh_star_vertical_initial =
    {| fresh_star_vertical_phase := FreshStarWaitForCamera;
       fresh_star_relative_y := -5;
       fresh_star_velocity_y := 0;
       fresh_star_gravity_y := 0 |} /\
  fresh_star_install_hitbox
    (Nat.iter 77 fresh_star_vertical_tick fresh_star_vertical_initial) =
    {| fresh_star_vertical_phase := FreshStarTangible;
       fresh_star_relative_y := -5;
       fresh_star_velocity_y := 0;
       fresh_star_gravity_y := 0 |}.
Proof. vm_compute. split; reflexivity. Qed.

Definition nesdb_prepared_spawn_y : float32 :=
  Float32.of_bits (Int.repr 3237756945). (* F post-Y: 0xc0fc4011 *)
Definition nesdb_prepared_home_y : float32 :=
  Float32.add nesdb_prepared_spawn_y
    (Float32.of_bits (Int.repr 1132068864)). (* 250.0f *)
Definition nesdb_prepared_first_hitbox_y : float32 :=
  Float32.sub nesdb_prepared_home_y
    (Float32.of_bits (Int.repr 1084227584)). (* 5.0f *)

Theorem fresh_star_prepared_home_and_first_hitbox_y_binary32_checked :
  Float32.to_bits nesdb_prepared_home_y = Int.repr 1131552255 /\
  Float32.to_bits nesdb_prepared_first_hitbox_y = Int.repr 1131224575.
Proof. vm_compute. split; reflexivity. Qed.

(** With Mario height 160 and star height 50, a star at prepared
    [spawnY + 245] overlaps exactly this integer interval. *)
Definition prepared_settled_star_vertical_overlap_model
    (spawn_mario_y future_mario_y : Z) : Prop :=
  future_mario_y <= spawn_mario_y + 245 + 50 /\
  spawn_mario_y + 245 <= future_mario_y + 160.

Theorem prepared_settled_star_vertical_overlap_model_interval :
  forall spawn_mario_y future_mario_y,
    prepared_settled_star_vertical_overlap_model
      spawn_mario_y future_mario_y <->
    spawn_mario_y + 85 <= future_mario_y /\
    future_mario_y <= spawn_mario_y + 295.
Proof.
  intros. unfold prepared_settled_star_vertical_overlap_model. lia.
Qed.

Theorem prepared_settled_star_same_height_mario_does_not_overlap :
  forall mario_y,
    ~ prepared_settled_star_vertical_overlap_model mario_y mario_y.
Proof.
  intros mario_y H.
  unfold prepared_settled_star_vertical_overlap_model in H. lia.
Qed.

Definition TangibleStarVerticalPoseRefinementObligation
    {State : Type}
    (prepared_first_hitbox_state : State -> Prop)
    (binary32_orbit_and_12k_gate_refined : State -> Prop)
    (live_hitbox_fields_refined : State -> Prop)
    (detect_object_hitbox_overlap_execution_refined : State -> Prop)
    (no_alias_external_or_lifecycle_writer : State -> Prop) : Prop :=
  forall state,
    prepared_first_hitbox_state state ->
    binary32_orbit_and_12k_gate_refined state /\
    live_hitbox_fields_refined state /\
    detect_object_hitbox_overlap_execution_refined state /\
    no_alias_external_or_lifecycle_writer state.

(** * Milestone condition for exactly one newly collected star *)

Definition star_dialog_milestones : list Z := [1; 3; 8; 30; 50; 70].

Definition crosses_star_dialog_milestone (before after : Z) : Prop :=
  exists threshold,
    In threshold star_dialog_milestones /\
    before < threshold /\ threshold <= after.

Theorem one_new_star_crosses_exactly_the_next_milestone :
  forall before,
    crosses_star_dialog_milestone before (before + 1) <->
    In (before + 1) star_dialog_milestones.
Proof.
  intros before. split.
  - intros [threshold [Hin [Hlt Hle]]].
    assert (threshold = before + 1) by lia. subst. exact Hin.
  - intros Hin. exists (before + 1). repeat split; try assumption; lia.
Qed.

Corollary synchronized_one_star_dialog_precounts :
  forall before,
    crosses_star_dialog_milestone before (before + 1) ->
    before = 0 \/ before = 2 \/ before = 7 \/
    before = 29 \/ before = 49 \/ before = 69.
Proof.
  intros before H.
  apply one_new_star_crosses_exactly_the_next_milestone in H.
  unfold star_dialog_milestones in H.
  cbn in H. lia.
Qed.

(** * The audited floor boundary is not the upper warp *)

Definition audited_boundary_x : Z := 5760.
Definition audited_boundary_z : Z := 4900.
Definition upper_warp_x : Z := -2048.
Definition upper_warp_z : Z := -1024.

(** Mario's stock radius 37 plus the upper warp's radius 150 gives 187.
    Squared XZ distance avoids importing a real/square-root abstraction. *)
Theorem audited_boundary_is_outside_upper_warp_horizontal_hitbox :
  187 * 187 <
    (audited_boundary_x - upper_warp_x) *
      (audited_boundary_x - upper_warp_x) +
    (audited_boundary_z - upper_warp_z) *
      (audited_boundary_z - upper_warp_z).
Proof.
  unfold audited_boundary_x, audited_boundary_z, upper_warp_x, upper_warp_z.
  lia.
Qed.

Record RawXZ : Type := {
  raw_x : Z;
  raw_z : Z
}.

Definition dialog_preserves_raw_xz (position : RawXZ) : RawXZ := position.

Theorem any_finite_dialog_prefix_preserves_boundary_raw_xz :
  forall frames,
    Nat.iter frames dialog_preserves_raw_xz
      {| raw_x := audited_boundary_x; raw_z := audited_boundary_z |} =
    {| raw_x := audited_boundary_x; raw_z := audited_boundary_z |}.
Proof. induction frames; cbn; auto. Qed.

(** A linked retail proof must instantiate this with the generated
    star-dance/automatic-dialog execution, all helpers and external frames,
    and the first post-dialog collision-before-action order.  Without a
    separate raw-XZ transport or warp relocation, accumulating a Graphics-Y
    gap at the audited boundary cannot itself trigger the fixed upper warp. *)
Definition DialogToUpperWarpRawTransportObligation
    {State : Type}
    (dialog_bridge_state : State -> Prop)
    (raw_at_audited_boundary : State -> Prop)
    (first_post_dialog_upper_warp_collision : State -> Prop)
    (raw_transport_or_warp_relocation : State -> Prop) : Prop :=
  forall state,
    dialog_bridge_state state ->
    raw_at_audited_boundary state ->
    first_post_dialog_upper_warp_collision state ->
    raw_transport_or_warp_relocation state.
