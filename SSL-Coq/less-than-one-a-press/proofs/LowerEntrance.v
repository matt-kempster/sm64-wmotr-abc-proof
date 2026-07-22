From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry CollisionRegions AreaTransitions
  ClightRefinement.

Definition NoAct3InteractionOverlap
    (observations : list CollisionObservation) : Prop :=
  forall star phase,
    In {| observed_object := star; observed_phase := phase |} observations ->
    ~ act3_star_interaction_region phase star.

Definition NoUpperTriggerOverlap
    (observations : list CollisionObservation) : Prop :=
  forall trigger_object phase,
    In {| observed_object := trigger_object; observed_phase := phase |}
      observations ->
    ~ upper_hidden_trigger_overlap phase trigger_object.

(* Pending geometric theorem over a concrete run's projected collision
   observations.  Its predicates expose Float32 hitboxes and phase fields
   through CollisionRegions and do not mention an informal floor number.
   Defining and proving completeness of that projection is part of the open
   Clight refinement. *)
Definition LowerEntranceReachabilityObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    fewer_than_one_a_press (project_inputs projection run) ->
    NoAct3InteractionOverlap
      (project_collision_observations projection run) /\
    NoUpperTriggerOverlap
      (project_collision_observations projection run).

Theorem lower_obligation_is_collision_phase_specific :
  forall projection,
  LowerEntranceReachabilityObligation projection ->
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial)
      star phase,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    fewer_than_one_a_press (project_inputs projection run) ->
    In {| observed_object := star; observed_phase := phase |}
      (project_collision_observations projection run) ->
    act3_star_interaction_region phase star -> False.
Proof.
  intros projection Hobligation run initial certificate star phase
    Hclean Hentrance Hnoa Hin Hoverlap.
  pose proof (Hobligation run initial certificate Hclean Hentrance Hnoa)
    as [Hnoact3 _].
  exact (Hnoact3 star phase Hin Hoverlap).
Qed.
