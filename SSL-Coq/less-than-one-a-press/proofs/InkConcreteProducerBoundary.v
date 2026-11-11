(** Four source-linked producer cuts. These claims intentionally retain
    their different scopes. They neither construct a useful Ink pose nor
    assert that every gameplay history belongs to one of the cuts. *)
From LessThanOneAPress.Proofs Require Import InkFloorProducerEffect
  InkPlatformProducerHeight InkBounceProducerEffect InkQuicksandProducerSize
  InkStoppedFloorQuery InkGroundReturnFrame InkStoppedCrawlAlignment
  InkFloorAlignmentTailFrame InkAirReturnFrame InkBounceApproachGap
  InkBounceClearAscent InkMarioRawCopyCall InkMarioZeroParticleTail InkFlyGuySizeBoundary
  InkBounceLiveReadBoundary InkStockBounceHeight InkFlyGuyCycleHeight InkPokeyLiveScale
  InkObjectPushHandoff InkNearbyFloorGeometry InkTimer130Geometry
  InkCrawlQuarterHandoff InkCrawlQuarterPrefix InkItemDropPlacement.

(** Actor placement is not bounded by the old low-spawn example.  A matched
    fresh guard bounds the newly created rise; the completed actual air call
    separately erases the display/movement split.  Finite flight arithmetic
    does not assert that every quarter accepts those coordinates. *)
Definition InkBounceAirProducerCheckedBoundary : Prop :=
  InkBouncePlacementIndependentGapCheckpoint /\ InkBounceFreshDisplayGapCheckpoint /\
  InkBounceFreshSynchronizedGapCheckpoint /\ InkAirRefreshBoundary /\ InkBounceClearAscentBoundary /\
  InkMarioCallbackRawCopyCut /\ InkMarioZeroParticleBoundary /\ InkFlyGuySizeStoreBoundary /\
  InkBounceLiveReadBoundary /\ InkPokeyLiveScaleArgumentBoundary.

Theorem icpb_bounce_air_producer_checked : InkBounceAirProducerCheckedBoundary.
Proof.
  split; [exact ibag_completed_fresh_guard_bounce_has_bounded_rise|].
  split; [exact ibag_completed_bounce_creates_at_most_251_display_gap|].
  split; [exact ibag_completed_bounce_creates_at_most_251_synchronized_gap|].
  split; [exact iar_air_refresh_boundary_checked|].
  split; [exact ibca_clear_ascent_boundary_checked|].
  split; [exact imrc_completed_callback_reaches_matching_raw_copy|].
  split; [exact imzp_zero_particle_boundary_checked|].
  split; [exact ifgs_size_store_boundary_checked|].
  split; [exact iblr_real_classifier_through_bounce_has_at_most_251_new_rise|].
  exact ipls_reached_growth_constructs_bounded_scale_argument.
Qed.

(** These are adjacent actual cuts, not an asserted producer classification.
    In particular the matrix helper and the origin of the cached floor are
    still exposed, rather than hidden inside a coverage premise. *)
Definition InkStoppedFloorProducerCheckedBoundary : Prop :=
  InkStoppedFloorQueryBoundary /\ InkGroundReturnedPositionFrame /\
  InkStoppedCrawlReturnedGap /\ InkStoppedCrawlGroundReturnConnection /\
  InkStoppedCrawlActualResultAlignment /\ InkAlignmentTailFrameBoundary /\
  InkObjectPushHandoffBoundary /\ InkNearbyFloorGeometryBoundary /\
  InkTimer130GeometryBoundary /\ InkCrawlQuarterHandoffBoundary /\
  InkCrawlQuarterPrefixBoundary /\ InkItemDropPlacementBoundary.

Theorem icpb_stopped_floor_producer_checked : InkStoppedFloorProducerCheckedBoundary.
Proof.
  split; [exact isfq_stopped_floor_query_checked|].
  split; [exact igr_ground_return_position_checked|].
  split; [exact isca_stopped_crawl_returned_gap_checked|].
  split; [exact isca_actual_ground_call_connects_return_to_switch|].
  split; [exact isca_real_ground_result_two_reaches_alignment|].
  split; [exact ifat_alignment_tail_frame_boundary_checked|].
  split; [exact iph_object_push_handoff_checked|].
  split; [exact infg_nearby_floor_geometry_checked|].
  split; [exact i130_geometry_checked|].
  split; [exact icqh_crawl_quarter_handoff_checked|].
  split; [exact icqp_crawl_quarter_prefix_checked|].
  exact ink_item_drop_placement_checked.
Qed.

Definition InkConcreteProducerCheckedBoundary : Prop :=
  InkFloorProducerCheckedBoundary /\ InkPlatformNonrotationHeightBoundary /\
  InkBounceHeightCheckpoint /\ InkBounceBoundedProducerCheckpoint /\
  InkBounceFreshContactNoDownwardCheckpoint /\
  InkQuicksandProducerSizeBoundary /\ InkStoppedFloorProducerCheckedBoundary /\
  InkBounceAirProducerCheckedBoundary.

Theorem icpb_concrete_producer_boundary_checked : InkConcreteProducerCheckedBoundary.
Proof.
  split; [exact ifp_floor_producer_boundary_checked|].
  split; [exact iph_platform_nonrotation_height_checked|].
  split; [exact ibp_completed_bounce_reaches_height_checkpoint|].
  split; [exact ibp_completed_bounded_bounce_is_insufficient_at_snap|].
  split; [exact ibp_fresh_contact_bounce_cannot_snap_below_collision|].
  split; [exact iqps_quicksand_producer_size_checked|].
  split; [exact icpb_stopped_floor_producer_checked|].
  exact icpb_bounce_air_producer_checked.
Qed.
