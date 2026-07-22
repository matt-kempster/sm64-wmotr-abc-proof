From Coq Require Import Bool Lia List ZArith.
From compcert Require Import Floats Integers.

Import ListNotations.
Local Open Scope Z_scope.

Inductive GameVersion := VersionUS | VersionJP.
Inductive PyramidEntrance := LowerEntrance | UpperEntrance.

Definition ssl_level_id : Int.int := Int.repr 8.
Definition ssl_course_id : Int.int := Int.repr 8.
Definition pyramid_area_id : Int.int := Int.repr 2.

(* The C behavior parameter is zero based: Act 3 is 2 and Act 6 is 5. *)
Definition act3_index : Z := 2.
Definition act6_index : Z := 5.
Definition hundred_coin_index : Z := 6.

Definition star_bit (flags : Int.int) (index : Z) : bool :=
  Int.testbit flags index.

Definition newly_collected
    (initial_flags final_flags : Int.int) (index : Z) : Prop :=
  star_bit initial_flags index = false /\
  star_bit final_flags index = true.

Record Vec3f := {
  vec_x : float32;
  vec_y : float32;
  vec_z : float32
}.

Record Hitbox := {
  hitbox_radius : float32;
  hitbox_height : float32;
  hitbox_down_offset : float32
}.

Record ObjectRef := {
  object_slot : nat;
  object_epoch : nat
}.

(* Intended abstraction of gMarioPlatform, which source inspection identifies
   as a raw pointer into the object pool rather than an allocation identity.
   The captured epoch is ghost provenance used to distinguish a live
   same-allocation pointer from an inactive or reused slot.  A concrete Clight
   memory projection and capture-history theorem remain pending. *)
Record RawPlatformPointer := {
  platform_slot : nat;
  platform_captured_epoch : nat
}.

Inductive BehaviorTag :=
| BehaviorStarOrKey
| BehaviorHiddenStarController
| BehaviorHiddenStarTrigger
| BehaviorOther.

Inductive ObjectOrigin :=
| StaticAct3PyramidStar
| PyramidHiddenStarController
| PyramidMacroTrigger
| RuntimeOtherOrigin.

Record ObjectState := {
  object_ref : ObjectRef;
  object_active : bool;
  object_area : Int.int;
  object_behavior : BehaviorTag;
  object_star_index : option Z;
  object_origin : ObjectOrigin;
  object_position : Vec3f;
  object_hitbox : Hitbox;
  object_macro_respawn_consumed : bool
}.

Inductive HiddenTrigger :=
| TriggerLowerWest
| TriggerLowerEast
| TriggerMiddleWest
| TriggerMiddleNorth
| TriggerUpper.

Definition all_hidden_triggers : list HiddenTrigger :=
  [ TriggerLowerWest; TriggerLowerEast; TriggerMiddleWest;
    TriggerMiddleNorth; TriggerUpper ].

Definition trigger_eqb (a b : HiddenTrigger) : bool :=
  match a, b with
  | TriggerLowerWest, TriggerLowerWest
  | TriggerLowerEast, TriggerLowerEast
  | TriggerMiddleWest, TriggerMiddleWest
  | TriggerMiddleNorth, TriggerMiddleNorth
  | TriggerUpper, TriggerUpper => true
  | _, _ => false
  end.

Definition TriggerState := HiddenTrigger -> bool.

Definition no_trigger_consumed (ts : TriggerState) : Prop :=
  forall trigger, ts trigger = false.

Definition all_five_consumed (ts : TriggerState) : Prop :=
  forall trigger, In trigger all_hidden_triggers -> ts trigger = true.

Record CollisionPhase := {
  collision_player_ref : ObjectRef;
  collision_mario_ref : ObjectRef;
  collision_target_ref : ObjectRef;
  collision_mario_position : Vec3f;
  collision_target_position : Vec3f;
  collision_mario_hitbox : Hitbox;
  collision_target_hitbox : Hitbox;
  collision_mario_count_before : Int.int;
  collision_target_count_before : Int.int;
  collision_pair_registered : bool;
  collision_after_platform_displacement : bool;
  collision_before_behavior_update : bool;
  collision_area : Int.int;
  collision_instant_warp_pending : bool
}.

(* A concrete Clight projection must emit these observations for the relevant
   Mario/object collision phases.  Keeping the object together with the phase
   lets Layer B state non-overlap independently of collection event labels. *)
Record CollisionObservation := {
  observed_object : ObjectState;
  observed_phase : CollisionPhase
}.

Record GameState := {
  state_version : GameVersion;
  state_entrance : PyramidEntrance;
  state_level : Int.int;
  state_course : Int.int;
  state_act : Int.int;
  state_area : Int.int;
  state_save_flags : Int.int;
  state_object_pool : list ObjectState;
  state_static_act3_ref : ObjectRef;
  state_triggers : TriggerState;
  state_puzzle_star_spawned : bool;
  state_macro_spawn_valid : bool;
  state_pool_well_formed : bool;
  state_lists_well_formed : bool;
  state_pending_star_interaction : bool;
  state_delayed_star_exit : bool;
  state_previous_buttons : Int.int;
  state_current_buttons : Int.int;
  state_mario_platform : option RawPlatformPointer
}.

Definition active_object (o : ObjectState) : Prop := object_active o = true.

Definition object_has_index (index : Z) (o : ObjectState) : Prop :=
  object_star_index o = Some index.

Definition active_star_or_key (index : Z) (o : ObjectState) : Prop :=
  active_object o /\
  object_behavior o = BehaviorStarOrKey /\
  object_has_index index o.

Definition object_ref_equal (a b : ObjectRef) : Prop :=
  object_slot a = object_slot b /\ object_epoch a = object_epoch b.

Definition captured_platform_ref (platform : RawPlatformPointer) : ObjectRef :=
  {| object_slot := platform_slot platform;
     object_epoch := platform_captured_epoch platform |}.

Definition raw_platform_slot_in_bounds
    (pool : list ObjectState) (platform : RawPlatformPointer) : Prop :=
  (platform_slot platform < length pool)%nat.

Definition raw_platform_slot_well_formed
    (pool : list ObjectState) (platform : RawPlatformPointer) : Prop :=
  exists current,
    nth_error pool (platform_slot platform) = Some current /\
    object_slot (object_ref current) = platform_slot platform.

Inductive RawPlatformSlotCase
    (pool : list ObjectState) (platform : RawPlatformPointer) : Prop :=
| PlatformSlotLiveSameEpoch : forall current,
    nth_error pool (platform_slot platform) = Some current ->
    object_slot (object_ref current) = platform_slot platform ->
    object_active current = true ->
    object_epoch (object_ref current) = platform_captured_epoch platform ->
    RawPlatformSlotCase pool platform
| PlatformSlotInactiveSameEpoch : forall current,
    nth_error pool (platform_slot platform) = Some current ->
    object_slot (object_ref current) = platform_slot platform ->
    object_active current = false ->
    object_epoch (object_ref current) = platform_captured_epoch platform ->
    RawPlatformSlotCase pool platform
| PlatformSlotReused : forall current,
    nth_error pool (platform_slot platform) = Some current ->
    object_slot (object_ref current) = platform_slot platform ->
    object_epoch (object_ref current) <> platform_captured_epoch platform ->
    RawPlatformSlotCase pool platform.

Theorem raw_platform_slot_case_exhaustive :
  forall pool platform,
    raw_platform_slot_well_formed pool platform ->
    RawPlatformSlotCase pool platform.
Proof.
  intros pool platform (current & Hslot & Hobject_slot).
  destruct (Nat.eq_dec
    (object_epoch (object_ref current))
    (platform_captured_epoch platform)) as [Hepoch | Hepoch].
  - destruct (object_active current) eqn:Hactive.
    + econstructor 1; eauto.
    + econstructor 2; eauto.
  - econstructor 3; eauto.
Qed.

Theorem raw_platform_slot_well_formed_is_in_bounds :
  forall pool platform,
    raw_platform_slot_well_formed pool platform ->
    raw_platform_slot_in_bounds pool platform.
Proof.
  intros pool platform (current & Hslot & _).
  unfold raw_platform_slot_in_bounds.
  apply nth_error_Some.
  rewrite Hslot.
  discriminate.
Qed.

Theorem reused_raw_platform_slot_is_not_captured_object :
  forall pool platform current,
    nth_error pool (platform_slot platform) = Some current ->
    object_epoch (object_ref current) <> platform_captured_epoch platform ->
    ~ object_ref_equal (object_ref current) (captured_platform_ref platform).
Proof.
  intros pool platform current _ Hepoch [_ Hsame_epoch].
  apply Hepoch.
  exact Hsame_epoch.
Qed.

Definition valid_platform_state (s : GameState) : Prop :=
  match state_version s, state_entrance s, state_mario_platform s with
  | VersionUS, _, None => True
  | VersionUS, _, Some _ => False
  | VersionJP, LowerEntrance, None => True
  | VersionJP, LowerEntrance, Some platform =>
      raw_platform_slot_well_formed (state_object_pool s) platform
  | VersionJP, UpperEntrance, None => True
  | VersionJP, UpperEntrance, Some platform =>
      raw_platform_slot_well_formed (state_object_pool s) platform
  end.
