From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry CollisionRegions AreaTransitions
  ClightRefinement LowerEntrance.

Definition UpperUSReachabilityObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    state_version initial = VersionUS ->
    fewer_than_one_a_press (project_inputs projection run) ->
    NoAct3InteractionOverlap
      (project_collision_observations projection run) /\
    NoUpperTriggerOverlap
      (project_collision_observations projection run).

(* JP does not execute clear_mario_platform during the relevant area object
   spawn.  state_mario_platform therefore retains a raw pool-slot pointer,
   with a ghost capture epoch used only for provenance.  This obligation must
   cover null, live same-epoch, inactive same-epoch, and reused-slot cases. *)
Definition UpperJPReachabilityObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    state_version initial = VersionJP ->
    fewer_than_one_a_press (project_inputs projection run) ->
    NoAct3InteractionOverlap
      (project_collision_observations projection run) /\
    NoUpperTriggerOverlap
      (project_collision_observations projection run).

Definition UpperEntranceReachabilityObligation
    (projection : ClightObservationProjection) : Prop :=
  UpperUSReachabilityObligation projection /\
  UpperJPReachabilityObligation projection.

Theorem upper_version_split_is_exhaustive :
  forall version, version = VersionUS \/ version = VersionJP.
Proof. intros []; auto. Qed.

Theorem clean_jp_upper_platform_cases_are_exhaustive :
  forall state,
    CleanPyramidEntry state ->
    state_entrance state = UpperEntrance ->
    state_version state = VersionJP ->
    state_mario_platform state = None \/
    exists platform,
      state_mario_platform state = Some platform /\
      RawPlatformSlotCase (state_object_pool state) platform.
Proof.
  intros state Hclean Hentrance Hversion.
  destruct (state_mario_platform state) as [platform|] eqn:Hplatform.
  - right. exists platform. split; [reflexivity |].
    apply raw_platform_slot_case_exhaustive.
    pose proof (clean_platform state Hclean) as Hvalid.
    unfold valid_platform_state in Hvalid.
    rewrite Hversion, Hentrance, Hplatform in Hvalid.
    exact Hvalid.
  - left. reflexivity.
Qed.
