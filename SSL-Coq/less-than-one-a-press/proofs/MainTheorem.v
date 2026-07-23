From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry ObjectProvenance StarCollection
  CollisionRegions AreaTransitions HiddenStar LowerEntrance UpperEntrance
  ClightRefinement ArchivedProofIntegration TranscriptRouteModel.

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
      all_five_trigger_consumption_events events /\
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
    + destruct (spawning_act6_requires_all_five_and_upper_overlap
        initial events final Hclean Hexec Hnew) as [Hspawn Hupper].
      split.
      * exact Hspawn.
      * split.
        -- eapply newly_collected_act6_from_clean_requires_all_five_trigger_consumptions;
          eauto.
        -- exact Hupper.
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

(* Capstone exposure of the transcript-derived route-gate reduction.  The
   [TranscriptRouteGateModel] premise is an unproved abstract route-coverage
   certificate, not a consequence of the generated Clight modules.  Likewise,
   the separate downstream-completeness premises used by the sufficiency
   theorems remain open. *)
Theorem transcript_route_gate_reduction :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
Proof.
  exact no_a_target_access_requires_gate_bypass.
Qed.

(* This is the stronger first-crossing formulation.  Its coverage premise is
   deliberately named [FirstTargetCutClassificationObligation]: proving that
   premise from Clight plus the collision mesh is the still-open route
   exhaustiveness task.  The conclusion identifies the exact preceding gate A
   edge or a finite entrance-specific bypass class tag.  Those tags are
   payload-free bookkeeping, not evidence of the classified trajectory. *)
Theorem first_target_cut_coverage_reduction :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        (gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
           region target_frame target_observation \/
         exists witness,
           upper_bypass_precedes_exact_target trace witness
             region target_frame target_observation)) \/
       (state_entrance initial = LowerEntrance /\
        (gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
           region target_frame target_observation \/
         exists witness,
           lower_bypass_precedes_exact_target trace witness
             region target_frame target_observation))).
Proof.
  exact first_target_access_requires_gate_a_or_explicit_bypass.
Qed.

Theorem first_target_cut_with_all_bypasses_excluded_requires_a_edge :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    ExcludesAllUpperBypassWitnesses trace ->
    ExcludesAllLowerBypassWitnesses trace ->
    trace_contains_a_press trace.
Proof.
  exact first_target_access_with_all_bypasses_excluded_requires_a_edge.
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
