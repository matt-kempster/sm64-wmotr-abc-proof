From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry ObjectProvenance StarCollection
  CollisionRegions AreaTransitions HiddenStar LowerEntrance UpperEntrance
  ClightRefinement ArchivedProofIntegration.

Import ListNotations.

Definition CollectionProvenanceReductionClaim : Prop :=
  forall initial events final,
    CleanPyramidEntry initial ->
    CertifiedExecution initial events final ->
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act3_index ->
      exists star phase,
        In (EventCollectAct3 star phase) events /\
        active_star_or_key act3_index star /\
        object_origin star = StaticAct3PyramidStar /\
        act3_star_interaction_region phase star) /\
    (newly_collected
       (state_save_flags initial) (state_save_flags final) act6_index ->
      (exists star phase,
        In (EventCollectAct6 star phase) events /\
        active_star_or_key act6_index star /\
        object_origin star = PyramidHiddenStarController /\
        overlaps_object phase star) /\
      (exists spawned_star,
        In (EventSpawnAct6 spawned_star) events) /\
      (exists trigger_object phase,
        In (EventConsumeTrigger TriggerUpper trigger_object phase) events /\
        upper_hidden_trigger_overlap phase trigger_object)).

Theorem collection_provenance_reduction :
  CollectionProvenanceReductionClaim.
Proof.
  unfold CollectionProvenanceReductionClaim.
  intros initial events final Hclean Hexec. split.
  - apply newly_collected_act3_requires_collection_event. exact Hexec.
  - intro Hnew. split.
    + apply newly_collected_act6_requires_collection_event with
        (initial := initial) (final := final).
      * exact Hexec.
      * exact Hnew.
    + apply spawning_act6_requires_all_five_and_upper_overlap with
        (initial := initial) (final := final).
      * exact Hclean.
      * exact Hexec.
      * exact Hnew.
Qed.

(* This packages the current checked archive kernels with the certified-event
   reduction so the integration is on the project verification spine.  The
   conjunction is intentionally not described as a semantic bridge between
   them, and is not the ultimate gameplay theorem. *)
Theorem current_verified_evidence_and_collection_reduction :
  ArchivedProofIntegrationKernel /\ CollectionProvenanceReductionClaim.
Proof.
  split.
  - exact archived_proof_integration_kernel_holds.
  - exact collection_provenance_reduction.
Qed.

Theorem conditional_less_than_one_a_press_impossibility :
  forall projection,
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial),
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
           (refined_final_state projection run initial certificate)) act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
           (refined_final_state projection run initial certificate)) act6_index.
Proof.
  intros projection Hlower [Hupper_us Hupper_jp]
    run initial certificate Hclean Hnoa.
  assert (Hregions :
    NoAct3InteractionOverlap
      (project_collision_observations projection run) /\
    NoUpperTriggerOverlap
      (project_collision_observations projection run)).
  {
    destruct (clean_selected_entrance initial Hclean) as [Hentry | Hentry].
    - eapply Hlower; eauto.
    - destruct (state_version initial) eqn:Hversion.
      + eapply Hupper_us; eauto.
      + eapply Hupper_jp; eauto.
  }
  destruct Hregions as [Hnoact3 Hnoupper]. split.
  - intro Hnew.
    destruct (newly_collected_act3_requires_collection_event
      initial (project_events projection run)
      (refined_final_state projection run initial certificate)
      (refined_execution projection run initial certificate) Hnew)
      as (star & phase & Hin & Hactive & Horigin & Hoverlap).
    pose proof
      (refined_act3_collections_observed projection run initial certificate
        star phase Hin) as Hobserved.
    exact (Hnoact3 star phase Hobserved Hoverlap).
  - intro Hnew.
    destruct (spawning_act6_requires_all_five_and_upper_overlap
      initial (project_events projection run)
      (refined_final_state projection run initial certificate) Hclean
      (refined_execution projection run initial certificate) Hnew)
      as (_ & trigger_object & phase & Hin & Hoverlap).
    pose proof
      (refined_trigger_consumptions_observed projection run initial certificate
        TriggerUpper trigger_object phase Hin) as Hobserved.
    exact (Hnoupper trigger_object phase Hobserved Hoverlap).
Qed.

Theorem conditional_target_clight_run_impossibility :
  forall projection,
  TargetClightRefinementObligation projection ->
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial,
    RunUsesProjection projection run ->
    project_state projection (run_start run) = Some initial ->
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    exists final,
      project_state projection (run_final run) = Some final /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act3_index /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act6_index.
Proof.
  intros projection [Hrefine _] Hlower Hupper run initial
    Huses Hstart Hclean Hnoa.
  destruct (Hrefine run initial Huses Hstart) as [certificate _].
  exists (refined_final_state projection run initial certificate).
  split.
  - exact (refined_final_matches projection run initial certificate).
  - eapply conditional_less_than_one_a_press_impossibility; eauto.
Qed.
