(**
  The Ink graphics-gap proposal and the JP stale-platform proposal solve two
  different parts of one possible counterexample:

  - an Area-1 installer must make the final platform owner be a useful dynamic
    surface owner; and
  - the first relevant Area-2 application must still have a useful pointer and
    payload, and must actually move MarioState.

  This file records that composition boundary.  It deliberately does not claim
  that any constructor below is reachable in an unmodified US or JP execution.
  The source/Clight refinements at the end are named proof obligations.
*)

From Coq Require Import List Lia.
From compcert Require Import Integers.

Import ListNotations.
Local Open Scope nat_scope.

(** Concrete, finite data carried by installer and first-apply observations. *)

(** Each component is the exact 32-bit word of a binary32 game coordinate. *)
Record Vec3Bits : Type := {
  vec_x_bits : Int.int;
  vec_y_bits : Int.int;
  vec_z_bits : Int.int
}.

Record OwnerToken : Type := {
  owner_slot : nat;
  owner_epoch : nat
}.

Record SurfaceToken : Type := {
  surface_serial : nat;
  surface_owner : OwnerToken
}.

Record InstallerObservation : Type := {
  installer_frame : nat;
  installer_state_position : Vec3Bits;
  installer_object_position : Vec3Bits;
  installer_graphics_position : Vec3Bits;
  installer_selected_surface : SurfaceToken
}.

(** The physical-co-location branch is itself finite. *)
Inductive PhysicalCoLocationKind : Type :=
| CoLocateWarpToTop
| CoLocateTopToWarp
| CoLocateCollisionPreservingClone.

(**
  Exhaustive *candidate-mechanism* taxonomy for installing the final Area-1
  platform owner.  Constructor arguments retain the distinguishing samples;
  these are not merely names for cases.
*)
Inductive FinalArea1PlatformOwnerInstaller : Type :=
| InstallByInkGraphicalRetry
    (observation : InstallerObservation)
    (failed_state_query_sample : Vec3Bits)
    (successful_graphics_retry_sample : Vec3Bits)
| InstallByStateFirstFloor
    (observation : InstallerObservation)
    (state_floor_sample : Vec3Bits)
| InstallByPhysicalCoLocation
    (kind : PhysicalCoLocationKind)
    (observation : InstallerObservation)
    (warp_sample : Vec3Bits)
    (dynamic_surface_sample : Vec3Bits)
| InstallByPostCommitTransport
    (observation : InstallerObservation)
    (commit_frame transport_frame : nat)
    (committed_position transported_position : Vec3Bits)
| InstallByOtherDynamicOwner
    (observation : InstallerObservation)
    (owner_behavior_key : Int.int)
| InstallByFrozenCarry
    (observation : InstallerObservation)
    (retained_for_frames : nat)
    (action_key : Int.int).

Definition installer_observation
    (installer : FinalArea1PlatformOwnerInstaller) : InstallerObservation :=
  match installer with
  | InstallByInkGraphicalRetry observation _ _ => observation
  | InstallByStateFirstFloor observation _ => observation
  | InstallByPhysicalCoLocation _ observation _ _ => observation
  | InstallByPostCommitTransport observation _ _ _ _ => observation
  | InstallByOtherDynamicOwner observation _ => observation
  | InstallByFrozenCarry observation _ _ => observation
  end.

Definition installer_owner
    (installer : FinalArea1PlatformOwnerInstaller) : OwnerToken :=
  surface_owner
    (installer_selected_surface (installer_observation installer)).

Definition no_a_edges (pressed_trace : list bool) : Prop :=
  Forall (fun pressed => pressed = false) pressed_trace.

(**
  This is an abstract installer witness, not yet a retail-reachability witness.
  The nonempty input trace prevents the no-edge component from being discharged
  solely by choosing an empty execution.
*)
Record Area1InstallerWitness : Type := {
  witnessed_installer : FinalArea1PlatformOwnerInstaller;
  installer_a_pressed_trace : list bool;
  installer_trace_nonempty : installer_a_pressed_trace <> [];
  installer_trace_has_no_a_edges : no_a_edges installer_a_pressed_trace
}.

(** Data needed by the retained platform transform at the first Area-2 apply. *)
Record PlatformPayload : Type := {
  payload_previous_pivot : Vec3Bits;
  payload_current_pivot : Vec3Bits;
  payload_face_yaw : Int.int;
  payload_transform_words : list Int.int
}.

Record FirstArea2ApplySample : Type := {
  first_apply_frame : nat;
  first_apply_state_position : Vec3Bits;
  first_apply_object_position : Vec3Bits
}.

(**
  Pointer fate at the first Area-2 application.  The reused case carries both
  epochs; the pointer identifies [replacement_owner], not [freed_owner].
*)
Inductive FirstArea2PointerFate : Type :=
| FirstArea2Null
    (sample : FirstArea2ApplySample)
    (previous_owner : option OwnerToken)
| FirstArea2USClear
    (sample : FirstArea2ApplySample)
    (cleared_owner : OwnerToken)
| FirstArea2JPInactiveRetained
    (sample : FirstArea2ApplySample)
    (retained_owner : OwnerToken)
    (payload : PlatformPayload)
| FirstArea2JPReusedReplacement
    (sample : FirstArea2ApplySample)
    (freed_owner replacement_owner : OwnerToken)
    (payload : PlatformPayload)
| FirstArea2LiveSameEpoch
    (sample : FirstArea2ApplySample)
    (live_owner : OwnerToken)
    (payload : PlatformPayload).

(*
  [fate_origin_owner] is the owner captured in Area 1.  In the reuse case it is
  the freed epoch.  [fate_payload_owner] is the owner whose fields are read by
  the Area-2 application; in the reuse case it is the replacement epoch.
*)
Definition fate_origin_owner
    (fate : FirstArea2PointerFate) : option OwnerToken :=
  match fate with
  | FirstArea2Null _ previous => previous
  | FirstArea2USClear _ cleared => Some cleared
  | FirstArea2JPInactiveRetained _ owner _ => Some owner
  | FirstArea2JPReusedReplacement _ freed _ _ => Some freed
  | FirstArea2LiveSameEpoch _ owner _ => Some owner
  end.

Definition fate_payload_owner
    (fate : FirstArea2PointerFate) : option OwnerToken :=
  match fate with
  | FirstArea2Null _ _ => None
  | FirstArea2USClear _ _ => None
  | FirstArea2JPInactiveRetained _ owner _ => Some owner
  | FirstArea2JPReusedReplacement _ _ replacement _ => Some replacement
  | FirstArea2LiveSameEpoch _ owner _ => Some owner
  end.

Definition fate_payload (fate : FirstArea2PointerFate) : option PlatformPayload :=
  match fate with
  | FirstArea2Null _ _ => None
  | FirstArea2USClear _ _ => None
  | FirstArea2JPInactiveRetained _ _ payload => Some payload
  | FirstArea2JPReusedReplacement _ _ _ payload => Some payload
  | FirstArea2LiveSameEpoch _ _ payload => Some payload
  end.

(**
  A first-apply effect witness is stronger than a fate label: it identifies the
  selected payload and supplies a genuinely changed MarioState position.
*)
Record FirstArea2FateEffectWitness : Type := {
  witnessed_fate : FirstArea2PointerFate;
  witnessed_origin_owner : OwnerToken;
  witnessed_payload_owner : OwnerToken;
  witnessed_origin_owner_is_captured :
    fate_origin_owner witnessed_fate = Some witnessed_origin_owner;
  witnessed_payload_owner_is_current :
    fate_payload_owner witnessed_fate = Some witnessed_payload_owner;
  witnessed_owner_slot_is_preserved :
    owner_slot witnessed_origin_owner = owner_slot witnessed_payload_owner;
  witnessed_payload : PlatformPayload;
  witnessed_payload_is_selected :
    fate_payload witnessed_fate = Some witnessed_payload;
  effect_state_before : Vec3Bits;
  effect_state_after : Vec3Bits;
  effect_is_nontrivial : effect_state_before <> effect_state_after
}.

(**
  The composition is intentionally conditional on both halves.  In particular,
  an Ink graphics retry alone says nothing about Area 2, and a synthetic Area-2
  payload fixture alone says nothing about how the pointer was installed.
*)
Theorem area1_installer_and_first_area2_effect_compose :
  forall
    (installer : Area1InstallerWitness)
    (effect : FirstArea2FateEffectWitness),
    fate_origin_owner (witnessed_fate effect) =
      Some (installer_owner (witnessed_installer installer)) ->
    exists
      (origin_owner payload_owner : OwnerToken)
      (payload : PlatformPayload)
      (before after : Vec3Bits),
      origin_owner = installer_owner (witnessed_installer installer) /\
      payload_owner = witnessed_payload_owner effect /\
      payload = witnessed_payload effect /\
      fate_origin_owner (witnessed_fate effect) = Some origin_owner /\
      fate_payload_owner (witnessed_fate effect) = Some payload_owner /\
      owner_slot origin_owner = owner_slot payload_owner /\
      fate_payload (witnessed_fate effect) = Some payload /\
      before = effect_state_before effect /\
      after = effect_state_after effect /\
      before <> after.
Proof.
  intros installer effect Howner.
  exists (installer_owner (witnessed_installer installer)).
  exists (witnessed_payload_owner effect).
  exists (witnessed_payload effect).
  exists (effect_state_before effect), (effect_state_after effect).
  repeat split; try reflexivity.
  - exact Howner.
  - exact (witnessed_payload_owner_is_current effect).
  - rewrite (witnessed_origin_owner_is_captured effect) in Howner.
    injection Howner as Horigin.
    rewrite <- Horigin.
    exact (witnessed_owner_slot_is_preserved effect).
  - exact (witnessed_payload_is_selected effect).
  - exact (effect_is_nontrivial effect).
Qed.

(** A reused pointer may change epoch while retaining the pool slot. *)
Theorem reused_replacement_carries_distinct_origin_and_payload_owners :
  forall sample freed replacement payload,
    owner_slot freed = owner_slot replacement ->
    fate_origin_owner
      (FirstArea2JPReusedReplacement sample freed replacement payload) =
        Some freed /\
    fate_payload_owner
      (FirstArea2JPReusedReplacement sample freed replacement payload) =
        Some replacement /\
    owner_slot freed = owner_slot replacement.
Proof.
  intros sample freed replacement payload Hslot.
  repeat split; try reflexivity; assumption.
Qed.

(** The null and US-clear cases cannot provide a platform payload. *)
Theorem null_fate_has_no_payload :
  forall sample previous_owner,
    fate_payload (FirstArea2Null sample previous_owner) = None.
Proof. reflexivity. Qed.

Theorem us_clear_fate_has_no_payload :
  forall sample cleared_owner,
    fate_payload (FirstArea2USClear sample cleared_owner) = None.
Proof. reflexivity. Qed.

Theorem effect_witness_excludes_null_and_us_clear :
  forall effect,
    (forall sample previous_owner,
      witnessed_fate effect <> FirstArea2Null sample previous_owner) /\
    (forall sample cleared_owner,
      witnessed_fate effect <> FirstArea2USClear sample cleared_owner).
Proof.
  intros effect; split; intros sample owner Heq;
    pose proof (witnessed_payload_is_selected effect) as Hpayload;
    rewrite Heq in Hpayload; discriminate.
Qed.

(** Exact delayed-warp / spinning-top timer arithmetic. *)

Inductive TopActionTimerSample : Type :=
| TopSpinning (action_timer : nat)
| TopExploding (action_timer : nat).

Definition disappeared_tick (count : nat) : nat := Nat.pred count.
Definition delayed_warp_install_value : nat := 20.
Definition delayed_warp_after_immediate_tick : nat :=
  Nat.pred delayed_warp_install_value.

Fixpoint unit_timer_increments (frames timer : nat) : nat :=
  match frames with
  | O => timer
  | S remaining => unit_timer_increments remaining (S timer)
  end.

Definition spinning_frame_transition
    (sample : TopActionTimerSample) : TopActionTimerSample :=
  match sample with
  | TopSpinning timer =>
      if Nat.eqb timer 150 then TopExploding 0 else TopSpinning (S timer)
  | TopExploding timer => TopExploding (S timer)
  end.

Record ExactInstallerTimerSchedule : Type := {
  schedule_f0_disappeared_before : nat;
  schedule_f0_disappeared_after : nat;
  schedule_f1_disappeared_before : nat;
  schedule_f1_disappeared_after : nat;
  schedule_f1_delayed_installed : nat;
  schedule_f1_delayed_after_tick : nat;
  schedule_f0_top_timer : nat;
  schedule_f19_top_sample : TopActionTimerSample;
  schedule_f20_top_sample : TopActionTimerSample
}.

Definition exact_installer_timer_schedule : ExactInstallerTimerSchedule :=
  {| schedule_f0_disappeared_before := 2;
     schedule_f0_disappeared_after := 1;
     schedule_f1_disappeared_before := 1;
     schedule_f1_disappeared_after := 0;
     schedule_f1_delayed_installed := 20;
     schedule_f1_delayed_after_tick := 19;
     schedule_f0_top_timer := 131;
     schedule_f19_top_sample := TopSpinning 150;
     schedule_f20_top_sample := TopExploding 0 |}.

Definition timer_schedule_is_consistent
    (schedule : ExactInstallerTimerSchedule) : Prop :=
  schedule_f0_disappeared_after schedule =
    disappeared_tick (schedule_f0_disappeared_before schedule) /\
  schedule_f1_disappeared_before schedule =
    schedule_f0_disappeared_after schedule /\
  schedule_f1_disappeared_after schedule =
    disappeared_tick (schedule_f1_disappeared_before schedule) /\
  schedule_f1_delayed_installed schedule = delayed_warp_install_value /\
  schedule_f1_delayed_after_tick schedule =
    Nat.pred (schedule_f1_delayed_installed schedule) /\
  unit_timer_increments 19 (schedule_f0_top_timer schedule) = 150 /\
  schedule_f19_top_sample schedule = TopSpinning 150 /\
  spinning_frame_transition (schedule_f19_top_sample schedule) =
    schedule_f20_top_sample schedule /\
  schedule_f20_top_sample schedule = TopExploding 0.

Theorem exact_installer_timer_schedule_is_consistent :
  timer_schedule_is_consistent exact_installer_timer_schedule.
Proof. vm_compute; repeat split. Qed.

Theorem f0_top_timer_is_forced_to_131 :
  forall f0_timer,
    unit_timer_increments 19 f0_timer = 150 ->
    f0_timer = 131.
Proof.
  intros f0_timer Htimer.
  simpl in Htimer.
  lia.
Qed.

Theorem exact_timer_arithmetic :
  disappeared_tick 2 = 1 /\
  disappeared_tick 1 = 0 /\
  delayed_warp_after_immediate_tick = 19 /\
  unit_timer_increments 19 131 = 150 /\
  spinning_frame_transition (TopSpinning 150) = TopExploding 0.
Proof. vm_compute; repeat split. Qed.

(**
  Narrow refinement targets.  These definitions do not assert that their
  premises hold.  Later files must instantiate them with observations obtained
  from the generated Clight program (or prove an explicit source refinement).
*)

Record TimedInkGraphicalRetryCandidate : Type := {
  timed_ink_installer : Area1InstallerWitness;
  timed_ink_state_query_owner : option OwnerToken;
  timed_ink_graphics_query_owner : option OwnerToken;
  timed_ink_final_platform_owner : option OwnerToken;
  timed_ink_schedule : ExactInstallerTimerSchedule
}.

Definition TimedInkGraphicalRetryClightRefinementObligation
    (candidate : TimedInkGraphicalRetryCandidate) : Prop :=
  (exists observation state_sample graphics_sample,
      witnessed_installer (timed_ink_installer candidate) =
        InstallByInkGraphicalRetry
          observation state_sample graphics_sample) /\
  timed_ink_state_query_owner candidate = None /\
  timed_ink_graphics_query_owner candidate =
    Some (installer_owner
      (witnessed_installer (timed_ink_installer candidate))) /\
  timed_ink_final_platform_owner candidate =
    Some (installer_owner
      (witnessed_installer (timed_ink_installer candidate))) /\
  timer_schedule_is_consistent (timed_ink_schedule candidate).

Definition AlternativeInstallerClightRefinementObligation
    (installer : Area1InstallerWitness)
    (clight_final_owner : option OwnerToken) : Prop :=
  (exists observation,
      (exists state_sample,
        witnessed_installer installer =
          InstallByStateFirstFloor observation state_sample) \/
      (exists kind warp_sample dynamic_sample,
        witnessed_installer installer =
          InstallByPhysicalCoLocation
            kind observation warp_sample dynamic_sample) \/
      (exists commit_frame transport_frame committed transported,
        witnessed_installer installer =
          InstallByPostCommitTransport observation
            commit_frame transport_frame committed transported) \/
      (exists behavior_key,
        witnessed_installer installer =
          InstallByOtherDynamicOwner observation behavior_key) \/
      (exists retained_frames action_key,
        witnessed_installer installer =
          InstallByFrozenCarry observation retained_frames action_key)) /\
  clight_final_owner = Some (installer_owner (witnessed_installer installer)).

Record FirstArea2ClightObservation : Type := {
  observed_first_apply_fate : FirstArea2PointerFate;
  observed_origin_owner : option OwnerToken;
  observed_payload_owner : option OwnerToken;
  observed_first_apply_payload : option PlatformPayload;
  observed_state_before_apply : Vec3Bits;
  observed_state_after_apply : Vec3Bits
}.

Definition FirstArea2PointerFateClightRefinementObligation
    (observation : FirstArea2ClightObservation)
    (effect : FirstArea2FateEffectWitness) : Prop :=
  observed_first_apply_fate observation = witnessed_fate effect /\
  observed_origin_owner observation = Some (witnessed_origin_owner effect) /\
  observed_payload_owner observation = Some (witnessed_payload_owner effect) /\
  observed_first_apply_payload observation = Some (witnessed_payload effect) /\
  observed_state_before_apply observation = effect_state_before effect /\
  observed_state_after_apply observation = effect_state_after effect.

Definition InstallerToFirstApplyOwnerRefinementObligation
    (installer : Area1InstallerWitness)
    (effect : FirstArea2FateEffectWitness) : Prop :=
  fate_origin_owner (witnessed_fate effect) =
    Some (installer_owner (witnessed_installer installer)).

(**
  A retail counterexample still needs all three obligations: a reachable
  zero-edge installer trace, a source-faithful first-apply effect, and the
  slot/epoch link between them.  The composition theorem above only performs
  the sound reduction after those facts have been supplied.
*)
