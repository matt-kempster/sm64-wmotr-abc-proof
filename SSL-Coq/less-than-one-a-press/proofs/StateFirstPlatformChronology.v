(** A factored chronology for the platform-pointer part of a State-first
    installer.

    [apply_mario_platform_displacement] runs before object collision.  Thus a
    State-first upper-warp attempt needs the platform global loaded by that
    apply to be non-null already.  The generated-source census leaves three
    ordinary ways for that value to have reached the apply:

      - the US area-spawn clear wrote null;
      - a completed final platform query wrote its selected surface owner; or
      - JP retained an inbound value while one or more later queries were
        skipped.

    This file gives those events executable chronology semantics.  It proves
    that a skipped query cannot manufacture a pointer and that every non-null
    upper-warp apply is classified as one of the remaining installer escapes:

      - a recognized stock final-query owner was selected at a position
        different from the current collision sample;
      - the owner/geometry projection is outside the canonical stock model;
        or
      - an inbound JP pointer survived to a different position.

    The theorem is deliberately conditional on a concrete event projection.
    Deriving that projection from linked Clight small steps still requires the
    platform-global non-alias/external-frame theorem, live surface-owner and
    slot/epoch classification, and proof that the value read by the true
    pre-collision apply is the value produced by this chronology.  None of
    those missing facts is postulated here. *)

From Coq Require Import Lia List.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness GameTypes PyramidTopPU
  StockProjectionExhaustiveness.

Import ListNotations.

(** Only JP may start this Area-1 interval with the cross-area retained
    pointer represented below.  US starts after its source-checked spawn clear
    and therefore ignores the JP seed argument. *)
Inductive PlatformRetailVersion : Type :=
| PlatformUS
| PlatformJP.

(** The last effective non-null source is retained explicitly.  The natural
    records how many subsequent final queries were skipped. *)
Inductive PlatformPointerLineage : Type :=
| PlatformLineageNull
| PlatformLineageFinalQuery
    (query_position : PositionZ)
    (owner : Area1DynamicOwnerObservation)
    (skipped_queries : nat)
| PlatformLineageJPInbound
    (node : Area1InboundNode)
    (owner : Area1DynamicOwnerObservation)
    (skipped_queries : nat).

Definition platform_lineage_owner
    (lineage : PlatformPointerLineage) :
    option Area1DynamicOwnerObservation :=
  match lineage with
  | PlatformLineageNull => None
  | PlatformLineageFinalQuery _ owner _ => Some owner
  | PlatformLineageJPInbound _ owner _ => Some owner
  end.

Definition skip_final_platform_query
    (lineage : PlatformPointerLineage) : PlatformPointerLineage :=
  match lineage with
  | PlatformLineageNull => PlatformLineageNull
  | PlatformLineageFinalQuery position owner skipped =>
      PlatformLineageFinalQuery position owner (S skipped)
  | PlatformLineageJPInbound node owner skipped =>
      PlatformLineageJPInbound node owner (S skipped)
  end.

Definition initial_platform_lineage
    (version : PlatformRetailVersion)
    (jp_inbound : option (Area1InboundNode * Area1DynamicOwnerObservation)) :
    PlatformPointerLineage :=
  match version, jp_inbound with
  | PlatformUS, _ => PlatformLineageNull
  | PlatformJP, None => PlatformLineageNull
  | PlatformJP, Some (node, owner) =>
      PlatformLineageJPInbound node owner 0
  end.

Inductive PlatformChronologyEvent : Type :=
| ChronologyCompletedFinalQuery
    (query_position : PositionZ)
    (owner : option Area1DynamicOwnerObservation)
| ChronologyUSSpawnClear
| ChronologySkippedFinalQuery.

(** A non-null query observation must carry the position actually supplied to
    that query.  The version clause prevents the US-only clear from being used
    as a fictitious JP event. *)
Definition platform_chronology_event_well_formed
    (version : PlatformRetailVersion)
    (event : PlatformChronologyEvent) : Prop :=
  match event with
  | ChronologyCompletedFinalQuery position (Some owner) =>
      observed_owner_query_position owner = position
  | ChronologyCompletedFinalQuery _ None => True
  | ChronologyUSSpawnClear => version = PlatformUS
  | ChronologySkippedFinalQuery => True
  end.

Definition platform_chronology_step
    (lineage : PlatformPointerLineage)
    (event : PlatformChronologyEvent) : PlatformPointerLineage :=
  match event with
  | ChronologyCompletedFinalQuery position (Some owner) =>
      PlatformLineageFinalQuery position owner 0
  | ChronologyCompletedFinalQuery _ None => PlatformLineageNull
  | ChronologyUSSpawnClear => PlatformLineageNull
  | ChronologySkippedFinalQuery => skip_final_platform_query lineage
  end.

Fixpoint run_platform_chronology
    (lineage : PlatformPointerLineage)
    (events : list PlatformChronologyEvent) : PlatformPointerLineage :=
  match events with
  | [] => lineage
  | event :: rest =>
      run_platform_chronology
        (platform_chronology_step lineage event) rest
  end.

Definition platform_lineage_well_formed
    (lineage : PlatformPointerLineage) : Prop :=
  match lineage with
  | PlatformLineageFinalQuery position owner _ =>
      observed_owner_query_position owner = position
  | _ => True
  end.

Lemma initial_platform_lineage_well_formed :
  forall version jp_inbound,
    platform_lineage_well_formed
      (initial_platform_lineage version jp_inbound).
Proof.
  intros version jp_inbound.
  destruct version, jp_inbound as [[node owner] |]; reflexivity.
Qed.

Lemma platform_chronology_step_preserves_well_formed :
  forall version lineage event,
    platform_lineage_well_formed lineage ->
    platform_chronology_event_well_formed version event ->
    platform_lineage_well_formed
      (platform_chronology_step lineage event).
Proof.
  intros version lineage event Hlineage Hevent.
  destruct event as [position [owner |] | |]; cbn in *.
  - exact Hevent.
  - exact I.
  - exact I.
  - destruct lineage; cbn in *; exact Hlineage.
Qed.

Lemma run_platform_chronology_preserves_well_formed :
  forall version events lineage,
    platform_lineage_well_formed lineage ->
    Forall (platform_chronology_event_well_formed version) events ->
    platform_lineage_well_formed
      (run_platform_chronology lineage events).
Proof.
  intros version events.
  induction events as [| event rest IH]; intros lineage Hlineage Hevents.
  - exact Hlineage.
  - inversion Hevents as [| event' rest' Hevent Hrest].
    cbn.
    apply IH.
    + eapply platform_chronology_step_preserves_well_formed; eauto.
    + exact Hrest.
Qed.

Lemma skipped_queries_preserve_platform_owner :
  forall count lineage,
    platform_lineage_owner
      (run_platform_chronology lineage
        (repeat ChronologySkippedFinalQuery count)) =
    platform_lineage_owner lineage.
Proof.
  intros count.
  induction count as [| count IH]; intros lineage; cbn.
  - reflexivity.
  - rewrite IH.
    destruct lineage; reflexivity.
Qed.

Theorem us_spawn_clear_followed_by_skips_cannot_install_platform :
  forall count lineage,
    platform_lineage_owner
      (run_platform_chronology lineage
        (ChronologyUSSpawnClear ::
          repeat ChronologySkippedFinalQuery count)) = None.
Proof.
  intros count lineage.
  cbn.
  rewrite skipped_queries_preserve_platform_owner.
  reflexivity.
Qed.

Lemma retained_jp_lineage_survives_exact_skipped_count :
  forall count skipped node owner,
    run_platform_chronology
      (PlatformLineageJPInbound node owner skipped)
      (repeat ChronologySkippedFinalQuery count) =
    PlatformLineageJPInbound node owner (skipped + count)%nat.
Proof.
  intros count.
  induction count as [| count IH]; intros skipped node owner; cbn.
  - f_equal. lia.
  - rewrite IH.
    f_equal.
    lia.
Qed.

Theorem jp_inbound_pointer_followed_by_skips_is_retention_not_installation :
  forall count node owner,
    run_platform_chronology
      (initial_platform_lineage PlatformJP (Some (node, owner)))
      (repeat ChronologySkippedFinalQuery count) =
      PlatformLineageJPInbound node owner count /\
    platform_lineage_owner
      (run_platform_chronology
        (initial_platform_lineage PlatformJP (Some (node, owner)))
        (repeat ChronologySkippedFinalQuery count)) = Some owner.
Proof.
  intros count node owner.
  split.
  - cbn.
    rewrite retained_jp_lineage_survives_exact_skipped_count.
    reflexivity.
  - rewrite skipped_queries_preserve_platform_owner.
    reflexivity.
Qed.

(** A canonical modeled owner selected by a completed query cannot have used
    the same sample that is currently touching the fixed upper warp. *)
Lemma canonical_stock_query_at_upper_warp_requires_different_sample :
  forall canonical_ref current source owner,
    upper_warp_contact current ->
    observed_owner_query_position owner = source ->
    CanonicalModeledCandidateObservation canonical_ref owner ->
    source <> current.
Proof.
  intros canonical_ref current source owner Hwarp Hsource
    (kind & _ & _ & Hcandidate) Hequal.
  rewrite Hsource, Hequal in Hcandidate.
  eapply upper_warp_has_no_stock_dynamic_floor_candidate; eauto.
Qed.

Definition CompletedQueryUpperWarpInstallerResidual
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (current : PositionZ)
    (lineage : PlatformPointerLineage) : Prop :=
  exists source owner skipped,
    lineage = PlatformLineageFinalQuery source owner skipped /\
    ((CanonicalModeledCandidateObservation canonical_ref owner /\
      source <> current) \/
     CanonicalOwnerOutsideModeledCandidate canonical_ref owner \/
     KnownOwnerWithNoncanonicalIdentity canonical_ref owner \/
     UnclassifiedDynamicOwner owner).

Definition JPRetainedUpperWarpInstallerResidual
    (current : PositionZ)
    (lineage : PlatformPointerLineage) : Prop :=
  exists node owner skipped,
    lineage = PlatformLineageJPInbound node owner skipped /\
    area1_inbound_position node <> current.

Definition UpperWarpPlatformInstallerResidual
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (current : PositionZ)
    (lineage : PlatformPointerLineage) : Prop :=
  CompletedQueryUpperWarpInstallerResidual canonical_ref current lineage \/
  JPRetainedUpperWarpInstallerResidual current lineage.

Theorem nonnull_upper_warp_lineage_requires_installer_residual :
  forall canonical_ref current lineage owner,
    upper_warp_contact current ->
    platform_lineage_well_formed lineage ->
    platform_lineage_owner lineage = Some owner ->
    UpperWarpPlatformInstallerResidual canonical_ref current lineage.
Proof.
  intros canonical_ref current lineage owner Hwarp Hwell Howner.
  destruct lineage as
    [| source found_owner skipped | node found_owner skipped];
    cbn in Howner.
  - discriminate.
  - inversion Howner; subst found_owner.
    left.
    exists source, owner, skipped.
    split; [reflexivity |].
    destruct (area1_dynamic_owner_projection_cases_exhaustive
      canonical_ref owner) as
      [Hmodeled | [Houtside | [Hidentity | Hunclassified]]].
    + left. split; [exact Hmodeled |].
      eapply canonical_stock_query_at_upper_warp_requires_different_sample;
        eauto.
    + right. left. exact Houtside.
    + right. right. left. exact Hidentity.
    + right. right. right. exact Hunclassified.
  - inversion Howner; subst found_owner.
    right.
    exists node, owner, skipped.
    split; [reflexivity |].
    intro Hequal.
    subst current.
    eapply no_stock_area1_inbound_node_overlaps_upper_warp; eauto.
Qed.

(** The data a linked small-step projection must establish at the true
    pre-collision apply.  All fields are concrete equalities or the explicit
    per-event well-formedness relation above; there is no reachability oracle
    or premise equivalent to the classification conclusion. *)
Record UpperWarpPrecollisionApplyProjection : Type := {
  projected_platform_version : PlatformRetailVersion;
  projected_jp_inbound_seed :
    option (Area1InboundNode * Area1DynamicOwnerObservation);
  projected_platform_events : list PlatformChronologyEvent;
  projected_collision_position : PositionZ;
  projected_loaded_platform_owner :
    option Area1DynamicOwnerObservation;
  projected_events_well_formed :
    Forall
      (platform_chronology_event_well_formed projected_platform_version)
      projected_platform_events;
  projected_loaded_owner_is_chronology_result :
    platform_lineage_owner
      (run_platform_chronology
        (initial_platform_lineage
          projected_platform_version projected_jp_inbound_seed)
        projected_platform_events) =
      projected_loaded_platform_owner;
  projected_collision_hits_upper_warp :
    upper_warp_contact projected_collision_position;
  projected_apply_body_runs : projected_loaded_platform_owner <> None
}.

Definition projected_final_lineage
    (projection : UpperWarpPrecollisionApplyProjection) :
    PlatformPointerLineage :=
  run_platform_chronology
    (initial_platform_lineage
      (projected_platform_version projection)
      (projected_jp_inbound_seed projection))
    (projected_platform_events projection).

(** Main conditional classification.  To rule out the platform-based
    State-first installer, a linked proof now has to eliminate exactly the
    two residual families rather than an unconstrained non-null pointer. *)
Theorem projected_state_first_platform_installer_is_exhaustively_classified :
  forall canonical_ref projection,
    UpperWarpPlatformInstallerResidual
      canonical_ref
      (projected_collision_position projection)
      (projected_final_lineage projection).
Proof.
  intros canonical_ref projection.
  assert (Hlineage_well_formed :
    platform_lineage_well_formed (projected_final_lineage projection)).
  {
    unfold projected_final_lineage.
    eapply run_platform_chronology_preserves_well_formed.
    - apply initial_platform_lineage_well_formed.
    - exact (projected_events_well_formed projection).
  }
  destruct (projected_loaded_platform_owner projection)
    as [owner |] eqn:Hloaded.
  - eapply nonnull_upper_warp_lineage_requires_installer_residual.
    + exact (projected_collision_hits_upper_warp projection).
    + exact Hlineage_well_formed.
    + unfold projected_final_lineage.
      rewrite projected_loaded_owner_is_chronology_result.
      exact Hloaded.
  - exfalso.
    apply (projected_apply_body_runs projection).
    exact Hloaded.
Qed.

(** A compact exclusion corollary.  It records the exact facts still needed
    from linked retail semantics: every completed-query survivor is a
    canonical stock candidate at the unchanged current sample, and no JP
    inbound lineage survives to this apply.  Under those facts the apply body
    cannot run at the upper warp. *)
Theorem stock_closed_projection_rules_out_state_first_platform_apply :
  forall canonical_ref projection,
    (forall source owner skipped,
      projected_final_lineage projection =
        PlatformLineageFinalQuery source owner skipped ->
      source = projected_collision_position projection /\
      CanonicalModeledCandidateObservation canonical_ref owner) ->
    (forall node owner skipped,
      projected_final_lineage projection =
        PlatformLineageJPInbound node owner skipped ->
      False) ->
    False.
Proof.
  intros canonical_ref projection Hquery_closed Hinbound_closed.
  pose proof
    (projected_state_first_platform_installer_is_exhaustively_classified
      canonical_ref projection) as Hclassified.
  destruct Hclassified as [Hcompleted | Hinbound].
  - destruct Hcompleted as
      (source & owner & skipped & Hlineage & Hcases).
    destruct Hcases as [Hmodeled_case | Hother_cases].
    + destruct Hmodeled_case as (Hmodeled & Hdifferent).
      destruct (Hquery_closed source owner skipped Hlineage)
      as (Hequal & Hcanonical).
      exact (Hdifferent Hequal).
    + destruct Hother_cases as [Houtside | Hidentity_or_unclassified].
      * destruct (Hquery_closed source owner skipped Hlineage)
          as (_ & (kind & Hkind & Href & Hcandidate)).
        destruct Houtside as
          (outside_kind & Houtside_kind & Houtside_ref & Houtside_candidate).
        rewrite Hkind in Houtside_kind.
        inversion Houtside_kind; subst outside_kind.
        exact (Houtside_candidate Hcandidate).
      * destruct Hidentity_or_unclassified as [Hidentity | Hunclassified].
        -- destruct (Hquery_closed source owner skipped Hlineage)
             as (_ & (kind & Hkind & Href & Hcandidate)).
           destruct Hidentity as
             (identity_kind & Hidentity_kind & Hnoncanonical).
           rewrite Hkind in Hidentity_kind.
           inversion Hidentity_kind; subst identity_kind.
           exact (Hnoncanonical Href).
        -- destruct (Hquery_closed source owner skipped Hlineage)
             as (_ & (kind & Hkind & Href & Hcandidate)).
           unfold UnclassifiedDynamicOwner in Hunclassified.
           rewrite Hkind in Hunclassified.
           discriminate.
  - destruct Hinbound as (node & owner & skipped & Hlineage & _).
    exact (Hinbound_closed node owner skipped Hlineage).
Qed.
