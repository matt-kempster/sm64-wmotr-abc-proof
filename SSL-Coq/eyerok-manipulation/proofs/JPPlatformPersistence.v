From Coq Require Import Bool List ZArith.

From SSLEyerok.Proofs Require Import RouteModel EyerokParticleDisplacement.

Import ListNotations.
Local Open Scope Z_scope.

(** This file isolates the platform-pointer difference between the pinned US
    build and the original Japanese build.  A saved platform pointer is
    represented only by its object-slot address.  The live payload currently
    occupying that address is represented separately.  That distinction is
    essential for spawning/particle platform displacement: slot reuse changes
    the payload without changing the stale raw address. *)

Definition object_slot_address : Type := nat.

Inductive object_slot_kind : Type :=
| FreedResidualKind
| RotatingArea2Kind
| OtherArea2ObjectKind.

(** A nonnull raw pointer is dereferenced without checking the slot's active
    flag, behavior, or area.  The payload therefore always carries the
    effective transform read from that address.  [FreedResidualKind] is not an
    empty/zeroed slot: deallocation leaves the old object fields in memory. *)
Record object_slot_payload : Type := {
  payload_kind : object_slot_kind;
  payload_dx : Z;
  payload_dy : Z;
  payload_dz : Z;
  payload_dyaw : Z
}.

Definition freed_residual_payload (dx dy dz dyaw : Z) : object_slot_payload :=
  {| payload_kind := FreedResidualKind;
     payload_dx := dx; payload_dy := dy; payload_dz := dz;
     payload_dyaw := dyaw |}.

Definition rotating_area2_payload (dx dy dz dyaw : Z) : object_slot_payload :=
  {| payload_kind := RotatingArea2Kind;
     payload_dx := dx; payload_dy := dy; payload_dz := dz;
     payload_dyaw := dyaw |}.

Definition other_area2_payload (dx dy dz dyaw : Z) : object_slot_payload :=
  {| payload_kind := OtherArea2ObjectKind;
     payload_dx := dx; payload_dy := dy; payload_dz := dz;
     payload_dyaw := dyaw |}.

Definition object_slot_heap : Type :=
  object_slot_address -> object_slot_payload.

Inductive regional_build : Type :=
| PinnedUS
| OriginalJP.

Record saved_platform_state : Type := {
  saved_area : RouteModel.ssl_area;
  saved_slot_address : option object_slot_address;
  saved_mario : EyerokParticleDisplacement.mario_kinematics
}.

Definition mk_saved_platform_state
    (area : RouteModel.ssl_area)
    (address : option object_slot_address)
    (mario : EyerokParticleDisplacement.mario_kinematics)
    : saved_platform_state :=
  {| saved_area := area;
     saved_slot_address := address;
     saved_mario := mario |}.

(** [spawn_objects_from_info] calls [clear_mario_platform] in the pinned US
    build.  That call is excluded by [#ifndef VERSION_JP] in the original JP
    build.  Object loading and slot reuse are deliberately outside this small
    pointer-policy function. *)
Definition load_area_pointer_policy
    (version : regional_build)
    (destination : RouteModel.ssl_area)
    (before : saved_platform_state) : saved_platform_state :=
  match version with
  | PinnedUS =>
      mk_saved_platform_state destination None (saved_mario before)
  | OriginalJP =>
      mk_saved_platform_state destination (saved_slot_address before)
        (saved_mario before)
  end.

Theorem us_area_load_clears_saved_slot_address :
  forall destination before,
    saved_slot_address
      (load_area_pointer_policy PinnedUS destination before) = None.
Proof. reflexivity. Qed.

Theorem jp_area_load_retains_saved_slot_address :
  forall destination before,
    saved_slot_address
      (load_area_pointer_policy OriginalJP destination before) =
    saved_slot_address before.
Proof. reflexivity. Qed.

(** These are the three guards in [apply_mario_platform_displacement]: time
    stop must be inactive, the Mario object must be present, and the saved raw
    platform pointer must be nonnull.  The third guard is represented by
    matching [saved_slot_address] below. *)
Record displacement_gates : Type := {
  time_stop_active : bool;
  mario_object_present : bool
}.

Definition displacement_gates_allow (gates : displacement_gates) : Prop :=
  time_stop_active gates = false /\
  mario_object_present gates = true.

Definition displacement_gates_allowb (gates : displacement_gates) : bool :=
  negb (time_stop_active gates) && mario_object_present gates.

Lemma displacement_gates_allow_reflects_boolean :
  forall gates,
    displacement_gates_allow gates ->
    displacement_gates_allowb gates = true.
Proof.
  intros gates [Htime Hmario].
  unfold displacement_gates_allowb.
  rewrite Htime, Hmario.
  reflexivity.
Qed.

Record platform_frame_result : Type := {
  frame_mario : EyerokParticleDisplacement.mario_kinematics;
  frame_displacement_applications : nat
}.

Definition no_platform_displacement
    (before : saved_platform_state) : platform_frame_result :=
  {| frame_mario := saved_mario before;
     frame_displacement_applications := 0 |}.

(** The four integer deltas summarize the effective transform read from the
    raw payload.  [apply_particle_platform_displacement] is reused from the
    Eyerok PPD model; in particular, it changes position/yaw and preserves
    speed. *)
Definition consume_saved_platform_for_one_frame
    (heap : object_slot_heap)
    (gates : displacement_gates)
    (before : saved_platform_state) : platform_frame_result :=
  match saved_slot_address before with
  | None => no_platform_displacement before
  | Some address =>
      let payload := heap address in
      if displacement_gates_allowb gates then
        {| frame_mario :=
             EyerokParticleDisplacement.apply_particle_platform_displacement
               (payload_dx payload) (payload_dy payload) (payload_dz payload)
               (payload_dyaw payload) (saved_mario before);
           frame_displacement_applications := 1 |}
      else no_platform_displacement before
  end.

(** Every nonnull retained address is consumed once when the three runtime
    gates pass, regardless of whether the slot is active or which behavior it
    currently contains.  This theorem is conditional on the supplied raw-slot
    payload; it does not establish an authentic stale-pointer prestate. *)
Theorem jp_saved_slot_payload_consumed_once :
  forall before heap gates address,
    saved_slot_address before = Some address ->
    displacement_gates_allow gates ->
    let loaded :=
      load_area_pointer_policy OriginalJP RouteModel.Area2 before in
    let payload := heap address in
    let result := consume_saved_platform_for_one_frame heap gates loaded in
    saved_area loaded = RouteModel.Area2 /\
    saved_slot_address loaded = Some address /\
    frame_displacement_applications result = 1%nat /\
    frame_mario result =
      EyerokParticleDisplacement.apply_particle_platform_displacement
        (payload_dx payload) (payload_dy payload) (payload_dz payload)
        (payload_dyaw payload) (saved_mario before).
Proof.
  intros before heap gates address Haddress Hgates.
  pose proof displacement_gates_allow_reflects_boolean gates Hgates as Hgateb.
  cbn [load_area_pointer_policy mk_saved_platform_state].
  rewrite Haddress.
  unfold consume_saved_platform_for_one_frame, mk_saved_platform_state.
  simpl.
  rewrite Hgateb.
  repeat split; reflexivity.
Qed.

(** This is a conditional semantic counterpoint to the US clearing theorem.
    If a nonnull JP-carried address is in fact reused by a rotating Area-2
    object and the runtime guards allow application, exactly one application
    occurs in this modeled object-update frame.  The theorem does not prove
    that an authentic Eyerok-to-Area-2 trace establishes those hypotheses. *)
Theorem jp_reused_rotating_area2_slot_consumes_one_displacement :
  forall before heap gates address dx dy dz dyaw,
    saved_slot_address before = Some address ->
    heap address = rotating_area2_payload dx dy dz dyaw ->
    displacement_gates_allow gates ->
    let loaded :=
      load_area_pointer_policy OriginalJP RouteModel.Area2 before in
    let result := consume_saved_platform_for_one_frame heap gates loaded in
    saved_area loaded = RouteModel.Area2 /\
    saved_slot_address loaded = Some address /\
    frame_displacement_applications result = 1%nat /\
    frame_mario result =
      EyerokParticleDisplacement.apply_particle_platform_displacement
        dx dy dz dyaw (saved_mario before).
Proof.
  intros before heap gates address dx dy dz dyaw Haddress Hpayload Hgates.
  pose proof displacement_gates_allow_reflects_boolean gates Hgates as Hgateb.
  cbn [load_area_pointer_policy mk_saved_platform_state].
  rewrite Haddress.
  unfold consume_saved_platform_for_one_frame, mk_saved_platform_state.
  simpl.
  rewrite Hpayload, Hgateb.
  repeat split; reflexivity.
Qed.

(** A freed slot is not cleared.  If the retained address is still free, its
    residual velocity/rotation fields are consumed by the same unchecked
    application. *)
Theorem jp_freed_residual_payload_consumes_one_displacement :
  forall before heap gates address dx dy dz dyaw,
    saved_slot_address before = Some address ->
    heap address = freed_residual_payload dx dy dz dyaw ->
    displacement_gates_allow gates ->
    let loaded :=
      load_area_pointer_policy OriginalJP RouteModel.Area2 before in
    let result := consume_saved_platform_for_one_frame heap gates loaded in
    frame_displacement_applications result = 1%nat /\
    frame_mario result =
      EyerokParticleDisplacement.apply_particle_platform_displacement
        dx dy dz dyaw (saved_mario before).
Proof.
  intros before heap gates address dx dy dz dyaw Haddress Hpayload Hgates.
  pose proof displacement_gates_allow_reflects_boolean gates Hgates as Hgateb.
  cbn [load_area_pointer_policy mk_saved_platform_state].
  rewrite Haddress.
  unfold consume_saved_platform_for_one_frame, mk_saved_platform_state.
  simpl.
  rewrite Hpayload, Hgateb.
  split; reflexivity.
Qed.

(** The concrete unpadded JP emulator fixture reused the hand address for a
    [bhvWaterDroplet] whose effective transform was zero.  The unchecked
    function was still invoked once; it simply left Mario unchanged. *)
Theorem jp_zero_motion_other_object_is_consumed_without_effect :
  forall before heap gates address,
    saved_slot_address before = Some address ->
    heap address = other_area2_payload 0 0 0 0 ->
    displacement_gates_allow gates ->
    let loaded :=
      load_area_pointer_policy OriginalJP RouteModel.Area2 before in
    let result := consume_saved_platform_for_one_frame heap gates loaded in
    frame_displacement_applications result = 1%nat /\
    frame_mario result = saved_mario before.
Proof.
  intros before heap gates address Haddress Hpayload Hgates.
  pose proof displacement_gates_allow_reflects_boolean gates Hgates as Hgateb.
  cbn [load_area_pointer_policy mk_saved_platform_state].
  rewrite Haddress.
  unfold consume_saved_platform_for_one_frame, no_platform_displacement,
    mk_saved_platform_state.
  simpl.
  rewrite Hpayload, Hgateb.
  split; [reflexivity |].
  change
    (EyerokParticleDisplacement.apply_particle_platform_displacement
       0 0 0 0 (saved_mario before) = saved_mario before).
  destruct (saved_mario before).
  unfold EyerokParticleDisplacement.apply_particle_platform_displacement.
  simpl.
  repeat rewrite Z.add_0_r.
  reflexivity.
Qed.

(** A floor chosen from static level collision has no owning object pointer.
    Coherence therefore requires [gMarioPlatform] to be NULL.  Conversely, an
    object-owned floor records the address of its owning object. *)
Inductive selected_floor_owner : Type :=
| StaticLevelFloor
| ObjectOwnedFloor (address : object_slot_address).

Definition saved_address_coherent_with_floor
    (owner : selected_floor_owner)
    (address : option object_slot_address) : Prop :=
  match owner with
  | StaticLevelFloor => address = None
  | ObjectOwnedFloor object_address => address = Some object_address
  end.

(** This predicate describes the ordinary, coherent Area-3 instant-warp
    prestate: Mario's selected floor is the static Area3Warp1D triangle, and
    the saved platform address agrees with that floor's lack of an object.
    It intentionally excludes stale-pointer and incoherent-floor glitches. *)
Definition ordinary_coherent_area3_instant_warp_prestate
    (route : RouteModel.mario_route_state)
    (platform : saved_platform_state) : Prop :=
  RouteModel.route_area route = RouteModel.Area3 /\
  RouteModel.route_floor_of route = RouteModel.Area3Warp1D /\
  saved_area platform = RouteModel.Area3 /\
  saved_address_coherent_with_floor StaticLevelFloor
    (saved_slot_address platform).

Theorem ordinary_coherent_area3_instant_warp_has_null_platform :
  forall route platform,
    ordinary_coherent_area3_instant_warp_prestate route platform ->
    saved_slot_address platform = None.
Proof.
  intros route platform [_ [_ [_ Hcoherent]]].
  exact Hcoherent.
Qed.

Theorem ordinary_coherent_jp_instant_warp_carries_null_platform :
  forall route platform,
    ordinary_coherent_area3_instant_warp_prestate route platform ->
    let loaded :=
      load_area_pointer_policy OriginalJP RouteModel.Area2 platform in
    saved_area loaded = RouteModel.Area2 /\
    saved_slot_address loaded = None.
Proof.
  intros route platform Hordinary.
  pose proof ordinary_coherent_area3_instant_warp_has_null_platform
    route platform Hordinary as Hnull.
  simpl.
  split; [reflexivity | exact Hnull].
Qed.

Theorem ordinary_coherent_route_can_take_instant_warp_step :
  forall route platform,
    ordinary_coherent_area3_instant_warp_prestate route platform ->
    RouteModel.instant_warp_step route (RouteModel.enter_area2 route).
Proof.
  intros route platform [Harea [Hfloor _]].
  constructor; assumption.
Qed.

Definition jp_platform_persistence_certificate : Prop :=
  (forall destination before,
      saved_slot_address
        (load_area_pointer_policy PinnedUS destination before) = None) /\
  (forall destination before,
      saved_slot_address
        (load_area_pointer_policy OriginalJP destination before) =
      saved_slot_address before) /\
  (forall before heap gates address,
      saved_slot_address before = Some address ->
      displacement_gates_allow gates ->
      let loaded :=
        load_area_pointer_policy OriginalJP RouteModel.Area2 before in
      let payload := heap address in
      let result := consume_saved_platform_for_one_frame heap gates loaded in
      saved_area loaded = RouteModel.Area2 /\
      saved_slot_address loaded = Some address /\
      frame_displacement_applications result = 1%nat /\
      frame_mario result =
        EyerokParticleDisplacement.apply_particle_platform_displacement
          (payload_dx payload) (payload_dy payload) (payload_dz payload)
          (payload_dyaw payload) (saved_mario before)) /\
  (forall before heap gates address,
      saved_slot_address before = Some address ->
      heap address = other_area2_payload 0 0 0 0 ->
      displacement_gates_allow gates ->
      let loaded :=
        load_area_pointer_policy OriginalJP RouteModel.Area2 before in
      let result := consume_saved_platform_for_one_frame heap gates loaded in
      frame_displacement_applications result = 1%nat /\
      frame_mario result = saved_mario before) /\
  (forall route platform,
      ordinary_coherent_area3_instant_warp_prestate route platform ->
      saved_slot_address platform = None) /\
  (forall route platform,
      ordinary_coherent_area3_instant_warp_prestate route platform ->
      let loaded :=
        load_area_pointer_policy OriginalJP RouteModel.Area2 platform in
      saved_area loaded = RouteModel.Area2 /\
      saved_slot_address loaded = None).

Theorem jp_platform_persistence_certificate_holds :
  jp_platform_persistence_certificate.
Proof.
  unfold jp_platform_persistence_certificate.
  refine (conj us_area_load_clears_saved_slot_address _).
  refine (conj jp_area_load_retains_saved_slot_address _).
  refine (conj jp_saved_slot_payload_consumed_once _).
  refine (conj jp_zero_motion_other_object_is_consumed_without_effect _).
  refine (conj ordinary_coherent_area3_instant_warp_has_null_platform _).
  exact ordinary_coherent_jp_instant_warp_carries_null_platform.
Qed.

Print Assumptions jp_reused_rotating_area2_slot_consumes_one_displacement.
Print Assumptions jp_freed_residual_payload_consumes_one_displacement.
Print Assumptions jp_zero_motion_other_object_is_consumed_without_effect.
Print Assumptions ordinary_coherent_jp_instant_warp_carries_null_platform.
Print Assumptions jp_platform_persistence_certificate_holds.
