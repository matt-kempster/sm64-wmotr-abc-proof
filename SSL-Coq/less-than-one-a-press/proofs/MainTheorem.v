From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry ObjectProvenance StarCollection
  CollisionRegions AreaTransitions HiddenStar LowerEntrance UpperEntrance
  ClightFacts ClightRefinement SelectedClightTarget ClightProjectionChronology
  ArchivedProofIntegration RouteEvidence
  TranscriptRouteModel
  FirstTargetRefinement JPSlotLifetime JPFirstApply FirstCrossingWriterCoverage
  OrdinaryMotion GoombaRaising PyramidTopPU InkFallback RetailFatalLatch
  InkPayloadInstaller InkTimer131CorruptionClosure InkTimer131ClightTraceBridge
  InkTimer131EntryExecutionClosure Area1PlayerListTailClosure
  Area1Rank1ResidualClosure Area1SurfaceWriteClosure
  Area1Rank1SixResidualAudit
  InkTimer131RetailMipsFrames Area1SurfacePoolRangeSeparation
  Area1Rank1LiveBoundaryReceipt Area1Rank1UpperWarpTraceReceipt
  Area1Rank4WarpTopTraceReceipt Area1Rank5StateSplitTraceReceipt
  InkTimer131RealEntryPrefix InkTimer131PostEntryMachineTrace TurningAnimation
  NegativeDepthInteractionClosure NegativeDepthDefinedProducerClosure
  WritableActionTableClosure
  Area2LowerTargetCut Area2HypotheticalPoleLongJump
  Area2NegativeQuicksandStarHypothesis
  WritableActionTableAliasExternalClosure
  WritableActionTableWholeGameAliases
  WritableActionTablePrivateInitialization
  WritableActionTablePrivateLive
  WritableActionTableReachedExecution
  PlatformIntegerAliasClosure Area1Rank3PayloadWriterClosure
  EyerokRank15ControllerRide EyerokRank15VSC EyerokRank29Preload
  EyerokRank29CycleClosure Area2Rank12ObjectImpulse
  CompCertRouteScope.

Import ListNotations.
Local Open Scope Z_scope.

(** This capstone is intentionally local to Marbler's proposed mechanism.  It
    combines the fully checked US/JP source/arithmetic boundary with the
    metadata-model theorem.  The DMA/memory and linked-transition refinement
    obligations in [TurningAnimation.v] remain open, so this is not a global
    animation or route-exhaustiveness theorem. *)
Theorem turning_part2_animation_metadata_boundary_excludes_ink_split :
  turning_animation_source_kernel /\
  forall before after,
    TurningPart2MetadataStep before after ->
    three_views_synchronized before ->
    three_views_synchronized after.
Proof.
  split.
  - exact turning_animation_source_kernel_checked.
  - exact turning_part2_metadata_cannot_create_ink_split.
Qed.

(** The project's route claims are interpreted through this boundary.  It
    rules invalid memory accesses and unregistered call targets out of a
    successful Clight run, while deliberately making no retail-machine claim
    about execution after source undefined behavior. *)
Theorem current_project_compcert_execution_scope_boundary :
  compcert_execution_scope_boundary_holds.
Proof. exact compcert_execution_scope_boundary_checked. Qed.

(** Rank 1's two immediate post-copy child families cannot append a PLAYER
    node behind Mario: Mario is the sole generated list-0 behavior, while all
    particle/debug children select later non-PLAYER lists.  A pre-existing
    node or another callback, pointer-forwarding step, alias/outside effect,
    or list/slot lifecycle event remains a linked-execution residual. *)
Theorem current_rank1_player_list_tail_boundary :
  Area1PlayerListTailCheckedBoundary /\
  (ink_zero_list_behavior_owner_ids (prog_defs IT131E_USData.prog) =
      [IT131E_USData._bhvMario] /\
   ink_zero_list_behavior_owner_ids (prog_defs IT131E_JPData.prog) =
      [IT131E_JPData._bhvMario]).
Proof.
  split; [exact area1_player_list_tail_checked_boundary_holds |].
  exact ink_bhv_mario_is_the_only_generated_list_zero_behavior.
Qed.

(** The stronger Rank-1 source boundary also closes the ordinary named-source
    ingress for a duplicate PLAYER object and audits the live floor-query data
    structure.  Every non-plain [Surface *] derivation is one of four
    pointer-preserving identity casts or the defined pool index; the node
    lineage has only its allocator, clear, and insertion writers.  The result
    intentionally leaves live [gCurrentObject] identity, already escaped or
    type-punned aliases, exact outside effects, and object/surface epochs for
    the continuous-execution proof. *)
Theorem current_rank1_player_and_floor_owner_source_boundary :
  Area1Rank1ResidualCheckedBoundary.
Proof. exact area1_rank1_residual_checked_boundary_holds. Qed.

(** The whole selected US/JP source now has an exhaustive destination-root
    census for [struct Surface].  Every rooted assignment is in the surface
    loader except three [originOffset] stores, and generated Clight shows that
    each of those first binds the separate water pseudo-floor, copies that
    binding to an unchanged temporary, and stores through the temporary.  The
    queried static/dynamic floor is therefore not a hidden post-load writer. *)
Theorem current_rank1_surface_write_source_boundary :
  Area1SurfaceWriteClosureBoundary.
Proof. exact area1_surface_write_closure_boundary_holds. Qed.

(** The six named Rank-1 survivors are now separated by outcome.  Ordinary
    direct and stock indirect callbacks cannot change [gCurrentObject]; the
    ordinary behavior/list constructor chain cannot append another PLAYER
    node; and the projected stock upper-warp query has no alternate floor.
    A stale cached object is genuinely possible.  Public surface-pool pointers
    into the shared main pool, the remaining outside effects, and the live
    allocator/query projection stay explicit rather than being framed away. *)
Theorem current_rank1_six_residual_audit_boundary :
  Area1Rank1SixResidualAuditBoundary.
Proof. exact area1_rank1_six_residual_audit_boundary_holds. Qed.

(** Rank 1's shared-main-pool residual is now a byte-range question rather
    than a free-form type-punning possibility.  The accepted JP receipt fixes
    both payload ranges and the live allocator heads; the inductive epoch
    relation preserves them through successful left/right allocations and
    safe state restoration.  The complete generated-source census fixes every
    main-pool allocator and epoch-mutator caller, while the machine receipt
    fixes the direct store/call projection of the five remaining JP roots.
    Any failed CompCert frame must be a same-block store whose byte interval
    actually overlaps a protected payload.  The live-list theorem projects a
    selected node to the finite stock-floor model once real insertion/clear
    execution and transitive descriptor validity inhabit its trace. *)
Theorem current_rank1_surface_pool_range_and_floor_projection_boundary :
  Area1SurfacePoolRangeSeparationBoundary.
Proof. exact area1_surface_pool_range_separation_boundary_holds. Qed.

(** The first continuous retail-JP frame receipt now instantiates the abstract
    range/list boundary.  A real graphics allocation starts exactly at the
    surface payload's exclusive end and is freed back to that boundary; all
    238 reached pool writes are classified; six owner stores pair with six
    insertions and survive the complete list scan; and the final query returns
    the exact stock static floor at the spawn position.  This rules out the
    six named escapes in that frame, while deliberately leaving universal
    extension to a target upper-warp frame as the remaining proof step. *)
Theorem current_rank1_live_boundary_receipt :
  Area1Rank1LiveBoundaryCheckedBoundary.
Proof. exact area1_rank1_live_boundary_checked_boundary_holds. Qed.

(** The continuous receipt now extends that first-frame boundary through one
    real zero-A four-pillar route and the upper-warp action.  All 2,462 frame
    checks pass; every [find_floor] entry has a checked return; every dynamic
    return observes its installed live owner; and Mario's final platform
    selection is ownerless and static in every audited frame.  The pyramid
    top's explosion creates six inactive-owner triangles for one frame, but
    none is returned after invalidation and the next clear precedes every
    query.  This closes the named escapes for this execution, not for every
    possible controller history or execution outside the selected model. *)
Theorem current_rank1_upper_warp_trace_receipt :
  Area1Rank1UpperWarpTraceCheckedBoundary.
Proof. exact area1_rank1_upper_warp_trace_checked_boundary_holds. Qed.

(** Rank 4 now has a route-matched machine receipt in addition to its
    generated-source census.  Across the same 2,462-frame zero-A upper-warp
    execution there is one canonical top and one node-1E warp, all 2,353
    top-mesh loads retain the canonical owner and bounded pose, and the warp
    receives no position, collision, or identity store.  The retired top slot
    is reused three times, but each reuse clears collision before installing a
    different behavior and never reloads the top mesh.  This closes relocation
    and collision-preserving cloning on this trace, not universally. *)
Theorem current_rank4_warp_top_trace_receipt :
  Area1Rank4WarpTopTraceCheckedBoundary.
Proof. exact area1_rank4_warp_top_trace_checked_boundary_holds. Qed.

(** Ranks 5 and 5A now share a route-matched intra-frame receipt.  Across
    the same 2,462-frame zero-A execution, every Mario copy is faithful, no
    coordinate or identity store occurs in the post-copy/next-preapply
    window, every cached-platform selection writes null through a checked
    retail store, and every apply/collision boundary remains synchronized.
    The three upper-warp applies at timers 2807--2809 likewise load null with
    inactive time stop.  This closes both mechanisms on this clean execution,
    not across every controller history or behavior outside defined retail
    execution. *)
Theorem current_rank5_state_split_trace_receipt :
  Area1Rank5StateSplitTraceCheckedBoundary.
Proof. exact area1_rank5_state_split_trace_checked_boundary_holds. Qed.

(** Rank 15 no longer needs an injected punching or jump-kick action at its
    accepted local hand-contact boundary.  With A already held, one real B
    edge makes the US retail loop execute idle -> punching -> jump-kick with
    no Mario-state write at release, then Mario catches and rides all six
    positive double-pound steps to Y=-943.  The generated US/JP ASTs retain
    same action chain.  The boss/contact prefix remains staged, so this is a
    stronger primitive rather than a complete no-A route. *)
Theorem current_rank15_controller_ride_boundary :
  EyerokRank15ControllerRideBoundary.
Proof. exact eyerok_rank15_controller_ride_boundary_holds. Qed.

(** Vertical-speed conservation does not turn the checked local hand ride into
    a tunnel entry with any stock seed considered here.  This source/data
    boundary couples jump-kick to its direct 20-unit velocity replacement,
    checks the 30-unit bounce and 160+78 lookup constants in both generated
    versions, and audits all 176 Area-3 static triangles.  Even granting ideal
    conservation and the full ledge-floor lookup allowance, every integral
    seed through 31 misses the Y=-562 tunnel floor; 32 is merely the first
    purely vertical arithmetic threshold.  The theorem does not prove a live
    wall/XZ trajectory, the staged boss/contact prefix, or the absence of a
    dynamic second support. *)
Theorem current_rank15_vsc_vertical_boundary :
  EyerokRank15VSCBoundary.
Proof. exact eyerok_rank15_vsc_boundary_holds. Qed.

(** Rank 29 no longer has an unidentified direct stock speed source.  The
    selected US/JP initializers authenticate the complete Area-2/Area-3
    roster, and the sleeping-hand branch loads collision while skipping its
    unique attack check.  Starting from the deliberately generous stock cap
    of 110, ordinary air control would require 1,934 uninterrupted updates to
    cross speed 400; the conservative vertical-envelope receipt excludes even
    400 such updates and bounds one settled episode at speed 170.  A complete
    route must therefore expose a repeatable landing/off-floor or moving-floor
    boundary which preserves speed between episodes, or fail one of the
    checked roster/action/alias/outside-call classifications. *)
Theorem current_rank29_stock_preload_boundary :
  EyerokRank29PreloadBoundary.
Proof. exact eyerok_rank29_preload_boundary_holds. Qed.

(** Rank 29's last ordinary stock residual is also closed in the finite
    source-shaped owner model.  All five collision-owning Area-2 platforms
    reload their mesh, platform carry does not touch Mario's forward speed,
    and even a deliberately uncarried stock floor can move at most 78 units
    in one frame, below the strict 100-unit [OFF_FLOOR] test.  The one real
    speed-preserving flat butt-slide-air landing consumes action state zero;
    a second landing cannot repeat it, and re-arming through ground slide
    executes the checked speed-100 normalization.  Area 2 contains no burning
    collision surface for a lava-bounce replacement.  A counterexample must
    now break owner/collision/action/source validity or leave defined stock
    execution rather than merely repeat a normal episode boundary. *)
Theorem current_rank29_stock_cycle_closure :
  EyerokRank29CycleClosure.
Proof. exact eyerok_rank29_cycle_closure_holds. Qed.

(** Rank 12's strongest named Area-2 impulse actor is now reduced to a
    collision/support residual.  The selected roster has exactly two homing
    Amps and one circling Amp, but none of the cannon, shell, Tweester,
    Heave-Ho, Chuckya, Fly Guy, or jumping-box preset families.  Even granting
    that the nearest homing Amp is perfectly lured to the second-pole top, its
    shock handler contains no push and the shocked action zeroes horizontal
    velocity before the air step; the stock pole grab had already erased
    inherited speed.  Consequently Amp shock supplies no direct horizontal
    dismount.  A useful composite must now name a wall response, support
    change, platform carry, pre-existing crossing, or a failed source/model
    premise. *)
Theorem current_rank12_object_impulse_boundary :
  Area2Rank12ObjectImpulseBoundary.
Proof. exact area2_rank12_object_impulse_boundary_holds. Qed.

(** Rank 3 can no longer use an ordinary integer-to-pointer cast as a clean
    platform-cell producer: integer constructors never become CompCert block
    pointers, and [Mem.storev] accepts only a block pointer.  The bilateral
    owner-call certificate separately closes the complete syntactically direct
    call graph of all canonical Area-1 surface owners against every named
    pitch-word writer.  Indirect/forged dispatch, lifecycle substitution,
    pre-existing/external aliases, and the six exact unresolved declarations
    remain explicit rather than being claimed impossible here. *)
Theorem current_rank3_integer_alias_defined_boundary :
  PlatformIntegerAliasDefinedClosure.
Proof. exact platform_integer_alias_defined_closure_holds. Qed.

Theorem current_rank3_payload_writer_boundary :
  Area1Rank3PayloadWriterCheckedBoundary.
Proof. exact area1_rank3_payload_writer_checked_boundary_holds. Qed.

(** The initialized interaction handler and knockback tables cannot install
    either long-jump action.  This is the source boundary needed by the
    negative-depth reduction; linked preservation of those writable tables,
    pointers, and outside-call frames remains explicit. *)
Theorem current_negative_depth_initialized_interaction_boundary :
  NegativeDepthInitializedInteractionSourceBoundary.
Proof.
  exact negative_depth_initialized_interaction_source_boundary_holds.
Qed.

(** The three writable interaction/action tables have no ordinary named
    controller producer.  The older whole-corpus Ink receipt supplies the
    exact handler-table mention/address census; the new boundary adds exact
    storage size, bounded consumers, one-word arbitrary-action capacity, and
    compatible coin/pole handler payloads.  The occurrence-sensitive alias and
    abstract-external closure is packaged separately below. *)
Theorem current_writable_action_table_mutation_boundary :
  WritableActionTableCheckedBoundary /\
  ink_dispatch_table_named_source_claim.
Proof.
  split.
  - exact writable_action_table_checked_boundary_holds.
  - exact ink_dispatch_tables_have_only_stock_named_source_uses.
Qed.

(** A future machine-level mutation has a now-checked conditional payoff at
    the lower Area-2 pole.  The exact two-word US/JP payload can redirect the
    pole row through the compatible Snufit/knockback path and select
    [ACT_LONG_JUMP].  The no-analog binary32 clear-quarter kernel then reaches
    the authenticated target-air cell in five zero-A frames from the pole
    top.  Conversely, granting the same fully initialized action at the
    normalized base contact peaks at only 3440 and misses the target during
    the complete 31-frame flight; a 3702 contact is the modeled threshold.
    This theorem does not inhabit the ACE/write/timing/live-collision bridge. *)
Theorem current_hypothetical_pole_long_jump_boundary :
  HypotheticalPoleLongJumpTablePayload /\
  HypotheticalEarlyGroundPoleLongJumpTablePayload /\
  HypotheticalPreinstalledKnockbackOnlySourceShape /\
  TopOfPoleKnownTableIndependenceSourceShape /\
  (forall handlers,
    ~ StaticPoleHandlerPreservesGrabAndRedirectsUS handlers) /\
  (forall handlers,
    ~ StaticPoleHandlerPreservesGrabAndRedirectsJP handlers) /\
  HypotheticalPoleLongJumpStockSourceShape /\
  position_in_lower_ring_target_air
    (hplj_position hplj_after_five_clear_frames) = true /\
  forallb
    (fun state =>
      negb
        (position_in_lower_ring_target_air (hplj_position state)))
    hplj_base_contact_first_31_states = true /\
  position_in_lower_ring_target_air
    (hplj_position
      (hplj_iterate_clear_south 15 hplj_threshold_contact_state)) = true /\
  fewer_than_one_a_press hplj_five_frame_inputs.
Proof.
  split; [exact hypothetical_pole_long_jump_table_payload_is_exact |].
  split; [exact hypothetical_early_ground_pole_long_jump_payload_is_exact |].
  split; [exact hypothetical_preinstalled_knockback_only_source_shape_holds |].
  split; [exact top_of_pole_does_not_read_the_known_writable_tables |].
  split; [exact (proj1 no_single_static_pole_handler_word_preserves_grab_and_redirects) |].
  split; [exact (proj2 no_single_static_pole_handler_word_preserves_grab_and_redirects) |].
  split; [exact hypothetical_pole_long_jump_stock_source_shape_holds |].
  split; [exact hypothetical_pole_long_jump_enters_lower_target_air_on_frame_five |].
  split; [exact hypothetical_base_contact_single_long_jump_misses_target_air |].
  split; [exact (proj2 (proj2 (proj2 hypothetical_3702_contact_enters_target_air_at_the_apex))) |].
  exact (proj2 hypothetical_pole_long_jump_five_frames_use_zero_a_presses).
Qed.

(** Area 2 has an exact moving-quicksand support under the Act-6 star, but
    negative depth alone changes only Graphics and therefore cannot change
    either raw standing collision.  The same checked kernel records the
    conditional payoff after a forced Graphics retry and raw copy: five
    retained sinks suffice for Act 6 and 29 for Act 3.  This theorem packages
    that arithmetic/source boundary and does not inhabit the post-entry seed,
    floor-query miss, retry, or live collection obligation. *)
Theorem current_area2_negative_quicksand_hypothetical_boundary :
  Area2NegativeQuicksandHypotheticalBoundary.
Proof.
  exact area2_negative_quicksand_hypothetical_boundary_checked.
Qed.

(** The former free-form alias/outside-call residual is reduced to one exact
    live invariant.  Every table occurrence per version is a terminal read,
    and an omitted valid private block is neither a self-injected store target
    nor writable/returnable by a CompCert abstract external call.  The
    construction and finite-execution carrier are packaged below; this theorem
    does not claim an OOB or post-undefined-behavior result. *)
Theorem current_writable_action_table_alias_external_boundary :
  WritableActionTableDefinedProducerClosure.
Proof. exact writable_action_table_defined_producer_closure_holds. Qed.

(** The whole-game stored-alias census closes the part that the accepted SSL
    boundary cannot state by itself: across every modeled US/JP translation
    unit, no initializer or export retains a pointer to any of the three
    tables, all body occurrences are terminal reads, and ordinary area/level
    transitions do not name them.  The semantic frame exposes the first step
    that would violate the private-table relation; retail OOB/DMA/ACE behavior
    remains outside this CompCert boundary. *)
Theorem current_writable_action_table_whole_game_alias_boundary :
  WritableActionTableWholeGameAliasBoundary.
Proof. exact writable_action_table_whole_game_alias_boundary_holds. Qed.

(** The private injection is no longer merely an obligation.  It is
    constructed from the selected linked program's successful initial memory,
    omits exactly the three resolved table blocks, and is carried through
    certified stores, byte copies, allocation/free effects, abstract external
    calls, and finite actual [Clight.step2] executions.  The remaining
    selected-run input is the pointwise step-coverage proof; a failed point is
    returned as the exact unclassified effect. *)
Theorem current_writable_action_table_private_initialization_boundary :
  WritableActionTablePrivateInitializationClosure.
Proof.
  exact writable_action_table_private_initialization_closure_holds.
Qed.

Theorem current_writable_action_table_private_live_boundary :
  WritableActionTablePrivateLiveClosure /\
  WritableActionTableSelectedLiveBridgeClosure.
Proof.
  split.
  - exact writable_action_table_private_live_closure_holds.
  - exact writable_action_table_selected_live_bridge_closure_holds.
Qed.

(** The formerly open reached-step obligation is now closed.  Every actual
    constructor of a selected US/JP [Clight.step2] run is covered, including
    assignments, copies, internal and external calls, allocation/free,
    continuations, and the four legitimate terminal table reads.  Therefore
    all three action tables retain their initialized bytes throughout every
    successful finite in-bounds run from the accepted task start. *)
Theorem current_writable_action_table_reached_execution_boundary :
  WritableActionTableReachedExecutionClosure.
Proof.
  exact writable_action_table_reached_execution_closure_holds.
Qed.

Theorem current_negative_depth_route_checked_boundary :
  InkTimer131CorruptionCheckedBoundary.
Proof. exact ink_timer131_corruption_checked_boundary_holds. Qed.

(** The defined negative-depth producer search is now closed at the generated
    source boundary.  The only ordinary store shape capable of crossing below
    zero is the late landing subtraction, whose clean provenance requires an A
    edge.  The 38-unit bilateral audit finds no source-created interior or
    untyped pointer, whole-structure copy, retained or returned pointer,
    and the initialized interaction tables remain private in every successful
    selected Clight run.  A universal live-execution impossibility theorem
    still needs the explicit reached-step projection and exact frames for
    genuine [EF_external] calls; those two semantic inputs are deliberately
    not assumed here. *)
Theorem current_negative_depth_defined_producer_boundary :
  NegativeDepthDefinedProducerCheckedBoundary.
Proof. exact negative_depth_defined_producer_checked_boundary_holds. Qed.

(** The rank-2 live-memory reduction is part of the capstone interface: a
    selected execution satisfying the concrete entry and reachable-step
    predicates cannot install the dangerous Mario graphical-tail cells. *)
Theorem current_timer131_clight_trace_bridge_boundary :
  InkTimer131ClightTraceBridgeCheckedBoundary.
Proof. exact ink_timer131_clight_trace_bridge_checked_boundary_holds. Qed.

(** The official JP initializer and generated entry chain now discharge the
    finite source/initial-memory part of the live-entry obligation.  The
    actual allocator/spawn [star] and its reachable-step classifier remain
    explicit rather than being assumed by this checked boundary. *)
Theorem current_timer131_entry_execution_boundary :
  InkTimer131EntryExecutionCheckedBoundary.
Proof. exact ink_timer131_entry_execution_checked_boundary_holds. Qed.

(** At the user-selected level-select boundary, the authenticated 19-write JP
    machine receipt is the accepted entry theorem.  It supplies slot 67,
    Mario/list/behavior identity, and safe tail values without requiring an
    IDO-MIPS-to-Clight simulation.  The optional Clight-prefix certificate is
    retained separately; the route's required work now starts with post-entry
    preservation through timer 131. *)
Theorem current_timer131_accepted_machine_entry_boundary :
  JPInkTimer131AcceptedEntryTheorem.
Proof. exact jp_timer131_authenticated_receipt_is_accepted_entry. Qed.

(** The callsite-strengthened form additionally proves that the allocator's
    exhaustion edge, [unload_object], and its source-sound call do not execute
    in the accepted prefix.  The continuous-bank sound call does execute;
    [sqrtf] is not eliminated by this receipt. *)
Theorem current_timer131_accepted_machine_entry_callsite_boundary :
  JPInkTimer131AcceptedEntryWithCallsiteBoundary.
Proof. exact jp_timer131_authenticated_entry_and_callsite_boundary. Qed.

(** The formerly abstract pre-entry calls now have a separate retail-MIPS
    frame.  The authenticated live continuous-bank SP is exactly the SP used
    by that frame theorem; [sqrtf] is store-free, and the source-sound call is
    independently proved unreached (although its machine footprint is also
    covered).  This is a direct IDO-code result, not an IDO-to-Clight bridge. *)
Theorem current_timer131_retail_mips_external_frame_boundary :
  InkTimer131RetailMipsExternalFrameCheckedBoundary /\
  jp_machine_stop_sounds_continuous_entry_sp
    jp_timer131_machine_call_reachability =
      jp_timer131_continuous_entry_sp.
Proof.
  split.
  - exact ink_timer131_retail_mips_external_frame_checked_boundary_holds.
  - reflexivity.
Qed.

(** From the user-accepted safe machine endpoint, the authenticated ordinary
    Area-1 execution performs 131 complete updates without changing Mario's
    slot, list identity, behavior, or either protected tail value.  Every
    watched write is the checked collision-reset halfword immediately after
    [activeFlags].  This theorem deliberately records one concrete action-0
    timeline; the spinning-action/all-controller-history extension remains
    explicit in [JPInkTimer131PostEntryUniversalizationResidual]. *)
Theorem current_timer131_accepted_post_entry_machine_boundary :
  JPInkTimer131AcceptedPostEntryBoundary.
Proof. exact jp_timer131_accepted_post_entry_boundary_holds. Qed.

(** A route-specific strengthening reaches the pyramid top's real spinning
    action timer 131 after one separately checked, disjoint fixture write to
    the top's pillar counter.  It closes the selected machine timeline, not
    clean four-pillar reachability or universal controller histories. *)
Theorem current_timer131_accepted_spinning_post_entry_machine_boundary :
  JPInkTimer131AcceptedSpinningPostEntryBoundary.
Proof. exact jp_timer131_accepted_spinning_post_entry_boundary_holds. Qed.

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

(* This packages the current checked archive kernels and the JP slot-lifetime
   staging boundary with the certified-event reduction so they are on the
   project verification spine.  The conjunction is intentionally not
   described as a semantic bridge between them, and is not the ultimate
   gameplay theorem. *)
Theorem current_verified_evidence_and_collection_reduction :
  ArchivedProofIntegrationKernel /\
  JPDelayedWarpSlotBoundaryClaim /\
  CollectionProvenanceReductionClaim.
Proof.
  split.
  - exact archived_proof_integration_kernel_holds.
  - split.
    + exact jp_delayed_warp_slot_boundary_checked.
    + exact collection_provenance_reduction.
Qed.

(** This capstone exposes only the corrected finite JP boundary.  The `84/85`
    totals and free-list windows are conditional arithmetic; the concrete
    destination-scoped Clight census is still
    [JPFirstApplySourceProjectionObligation].  In particular, this theorem
    does not claim that an early-freed top has any selected depth. *)
Theorem current_jp_first_apply_finite_boundary :
  jp_loader_fresh_allocations = 74%nat /\
  jp_pre_true_first_apply_fresh_allocations false = 84%nat /\
  jp_pre_true_first_apply_fresh_allocations true = 85%nat /\
  jp_spindel_conditional_free_list_depth_zero_based = 63%nat /\
  (forall depth,
    jp_free_list_depth_is_popped false depth <-> (depth <= 83)%nat) /\
  (forall depth,
    jp_free_list_depth_survives true depth <-> (85 <= depth)%nat).
Proof.
  split; [exact jp_loader_allocation_decomposition_is_74 |].
  split; [exact jp_pre_true_first_apply_count_without_saved_cap |].
  split; [exact jp_pre_true_first_apply_count_with_saved_cap |].
  split; [exact jp_spindel_conditional_free_list_depth_is_63 |].
  split.
  - exact jp_no_cap_popped_depths_are_exactly_0_through_83.
  - exact jp_saved_cap_surviving_depths_begin_at_85.
Qed.

(** Ink's graphics split is one possible Layer-1 installer; the JP pointer
    fate is Layer 2.  This capstone exposes only the exact conditional timer
    arithmetic used by that composition.  It does not inhabit any of the
    Clight installer or first-apply refinement obligations. *)
Theorem current_ink_payload_installer_timer_boundary :
  timer_schedule_is_consistent exact_installer_timer_schedule /\
  (forall f0_timer,
    unit_timer_increments 19%nat f0_timer = 150%nat ->
    f0_timer = 131%nat).
Proof.
  split.
  - exact exact_installer_timer_schedule_is_consistent.
  - exact f0_top_timer_is_forced_to_131.
Qed.

(* The ordinary-motion tranche intentionally exposes both sides of the
   current upper arithmetic boundary: the non-Wing source/mesh/arithmetic
   kernel stays below the integer-translation vertical rejection threshold,
   while the retained-Wing-Cap arithmetic countermodel exceeds the non-Wing
   rollout bound without a new A edge but still stays below that threshold.
   The changed gravity is why cap initialization is an explicit refinement
   obligation.  Neither conjunction is a retail collision-containment or
   route theorem. *)
Theorem current_ordinary_motion_evidence_boundary :
  UpperOrdinaryAscentKernel /\
  follows_vertical_step
      wing_cap_held_gravity_step wing_cap_rollout_velocity_trace = true /\
  wing_cap_rollout_relative_rise = 228 /\
  220 < wing_cap_rollout_relative_rise /\
  wing_cap_rollout_relative_rise < pyramid_elevator_cage_clearance /\
  fewer_than_one_a_press
    (repeat held_a_frame (length wing_cap_rollout_velocity_trace)).
Proof.
  split.
  - exact upper_ordinary_ascent_kernel_checked.
  - exact wing_cap_rollout_arithmetic_countermodel.
Qed.

(* The transcript's regular-Goomba observation is a real but bounded,
   conditional state-machine primitive.  The idealized Z-valued H/F/R model
   adds 21 per cycle; binary32 proves the 25 + (-4) velocity update and the
   concrete integer-aligned Y=51 computations at 31 and 83 rises, but not a
   universal exact-21 position recurrence.  This capstone also records the
   binary32 fixed-point witness at 2^29, the integer-abstraction Spindel
   height-band exclusion for the Area-2 Y=778 singleton, and the 31-hit bound
   for the specific post-collision H/F/R top-window schedule.  It does not
   provide linked binary32 hitbox bounds or inhabit the
   full-float shuttle, alternate pre-collision writer, PU capture/transport,
   or height-handoff obligations. *)
Theorem current_goomba_raising_bounded_boundary :
  goomba_raising_bounded_claim.
Proof.
  exact goomba_raising_bounded_kernel.
Qed.

(* This packages the bounded model beside the generated US/JP source receipts
   on the verification spine.  It is only a conjunction: no conjunct states
   that a linked Clight execution refines the H/F/R transition system. *)
Theorem current_goomba_raising_source_event_boundary :
  goomba_raising_bounded_claim /\
  goomba_state_machine_source_shape_us_claim /\
  goomba_state_machine_source_shape_jp_claim /\
  goomba_player_collision_source_shape_us_claim /\
  goomba_player_collision_source_shape_jp_claim /\
  spindel_pu_station_source_shape_us_claim /\
  spindel_pu_station_source_shape_jp_claim.
Proof.
  split; [exact goomba_raising_bounded_kernel |].
  split; [exact goomba_state_machine_source_shape_us |].
  split; [exact goomba_state_machine_source_shape_jp |].
  split; [exact goomba_player_collision_source_shape_us |].
  split; [exact goomba_player_collision_source_shape_jp |].
  split; [exact spindel_pu_station_source_shape_us |].
  exact spindel_pu_station_source_shape_jp.
Qed.

(* The graphical-fallback tranche shows that update order does not by itself
   refute the scheduling shape; it does not execute the branch in Clight or
   settle clean-entry reachability.  It provides local and PU conditional
   pipeline-coordinate witnesses, exact nearby static-mesh arithmetic, the
   fifteen-owner abstract dynamic-floor exclusion for the first query, and the
   invariant that State-only ordinary/PU writes preserve Object and Graphics.
   The linked branch/surface refinement and writer/action closure are explicit
   obligations in [InkFallback], so this is not the ultimate theorem. *)
Theorem current_ink_fallback_evidence_boundary :
  InkFallbackCheckedBoundary /\
  (forall owner floor_y,
    ~ stock_dynamic_geometry_floor_candidate
        owner ink_warp_floor_miss_position floor_y) /\
  (forall object_position graphics_position floor_y,
    upper_warp_contact object_position ->
    -32768 <= position_y graphics_position < 32768 ->
    position_y graphics_position - position_y object_position <= 45 ->
    pyramid_top_floor_min_y <= floor_y ->
    ~ floor_query_can_return graphics_position floor_y).
Proof.
  split; [exact ink_fallback_checked_boundary |].
  split.
  - exact ink_first_query_has_no_modeled_stock_dynamic_floor_candidate.
  - exact dry_graphics_offset_cannot_supply_top_retry.
Qed.

(* Within the finite event system, the retail fatal-latch tranche closes the
   scheduler-level loophole in the double-NULL graphical fallback.  Once
   death/game-over wins the empty first-writer latch, a later ACT_DISAPPEARED
   tick cannot replace it.  Every modeled clear event is an atomic barrier that
   destroys the old continuation.  The checked boundary includes the
   direct-writer and explicit address-taking censuses for the generated US/JP
   level-update units, but is not an iterated linked-Clight alias,
   memory-safety, clear-order, or destination-selection theorem. *)
Theorem current_retail_fatal_latch_boundary :
  RetailFatalLatchCheckedBoundary /\
  forall kind events,
    retail_fatal_or_old_continuation_destroyed
      (retail_latch_run events (retail_after_both_null_frame kind)) /\
    retail_upper_request_accepted
      (retail_latch_run events (retail_after_both_null_frame kind)) = false.
Proof.
  split.
  - exact retail_fatal_latch_checked_boundary.
  - exact retail_fatal_persists_or_reset_destroys_disappeared.
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

(* Corrected first-crossing coverage.  Unlike the older unused writer
   inventory, the premise names an entrance-contracted cut, endpoint-local
   side separation, an actual source-to-target Clight segment, and its
   minimality.  The conclusion is exhaustive for non-target projected events:
   either the position writer is ordinary physics, platform displacement,
   object impulse, collision clip, or area reload, or unchanged coordinates
   crossed the cut through a floor/platform support-selection change.
   Selecting and constructing the target-specific cut from a linked run
   remains open. *)
Theorem validated_first_crossing_writer_reduction :
  forall projection run initial certificate region target_frame
      (crossing :
        FirstValidatedCutCrossingAt
          projection run initial certificate region target_frame),
    FirstCrossingWriterCause
      (first_crossing_event _ _ _ _ _ _ crossing)
      (first_crossing_before _ _ _ _ _ _ crossing)
      (first_crossing_after _ _ _ _ _ _ crossing).
Proof.
  exact validated_pre_target_first_crossing_writer_coverage.
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

(* This is the target-bit-facing route capstone.  In contrast with the older
   payload-free cut theorem above, every bypass alternative carries a concrete
   Clight frame segment and projected before/after states.  The remaining
   premises are explicit: constructing that evidence-bearing classification
   and proving the six open writer/geometry classes unreachable are the Layer-B
   residuals; constructing the frame certificate and route projection remains
   part of the whole-program refinement residual. *)
Theorem evidence_bearing_route_cut_blocks_new_target_bits :
  forall projection run initial certificate trace,
    CleanPyramidEntry initial ->
    ClightRouteTraceProjection projection run initial certificate trace ->
    EvidenceBearingFirstTargetCutClassification
      projection run initial certificate trace ->
    OpenRouteWriterClassesUnreachable
      projection run initial certificate trace ->
    fewer_than_one_a_press (project_inputs projection run) ->
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act3_index /\
    ~ newly_collected
        (state_save_flags initial)
        (state_save_flags
          (refined_final_state projection run initial certificate))
        act6_index.
Proof.
  exact evidence_classifier_with_open_writers_closed_blocks_new_target_bits.
Qed.

(* Whole-program exposure of the evidence-bearing route path.  This theorem
   deliberately keeps three independent residuals visible:

   - construct the ordinary Clight frame/event refinement certificate;
   - construct an evidence-bearing first-cut classification for its route;
   - exclude the six surviving writer/geometry classes under no A edge.

   The first residual includes Layer A.  The latter two are the current Layer B
   route-exhaustiveness boundary. *)
Theorem conditional_evidence_bearing_clight_run_impossibility :
  forall projection,
    WholeProgramClightRefinementObligation projection ->
    EvidenceBearingRouteClassificationRefinementObligation projection ->
    NoAOpenRouteWriterClassesUnreachableObligation projection ->
    forall run initial,
      RunUsesProjection projection run ->
      project_state projection (run_start run) = Some initial ->
      RunEndsAtSelectedFrameBoundary projection run ->
      CleanPyramidEntry initial ->
      fewer_than_one_a_press (project_inputs projection run) ->
      exists final,
        project_state projection (run_final run) = Some final /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act3_index /\
        ~ newly_collected
            (state_save_flags initial) (state_save_flags final) act6_index.
Proof.
  intros projection Hwhole Hclassify Hclose run initial
    Huses Hstart Hend Hclean Hnoa.
  destruct (Hwhole run initial Huses Hstart Hend) as [certificate _].
  destruct (Hclassify run initial certificate Hclean)
    as [trace [Hroute Hclassifier]].
  pose proof (Hclose run initial certificate trace
    Hclean Hroute Hclassifier Hnoa) as Hclosed.
  exists (refined_final_state projection run initial certificate).
  split.
  - exact (refined_final_matches projection run initial certificate).
  - eapply evidence_bearing_route_cut_blocks_new_target_bits; eauto.
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
  ObservedSelectedTargetClightRefinementObligation projection ->
  LowerEntranceReachabilityObligation projection ->
  UpperEntranceReachabilityObligation projection ->
  forall run initial,
    RunUsesProjection projection run ->
    project_state projection (run_start run) = Some initial ->
    RunEndsAtSelectedFrameBoundary projection run ->
    CleanPyramidEntry initial ->
    fewer_than_one_a_press (project_inputs projection run) ->
    exists final,
      project_state projection (run_final run) = Some final /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act3_index /\
      ~ newly_collected
          (state_save_flags initial) (state_save_flags final) act6_index.
Proof.
  intros projection Hobserved Hlower Hupper run initial
    Huses Hstart Hend Hclean Hnoa.
  destruct Hobserved as
    [Hselected_program [Hsource [Haudit
      [observer [Hobserved_chronology Hentries]]]]].
  pose proof
    (observed_selected_target_refinement_supplies_selected_refinement
      projection
      (conj Hselected_program
        (conj Hsource
            (conj Haudit
            (ex_intro _ observer
              (conj Hobserved_chronology Hentries)))))) as Hselected.
  destruct Hselected as [_ [_ [_ [Hrefine _]]]].
  destruct (Hrefine run initial Huses Hstart Hend) as [certificate _].
  exists (refined_final_state projection run initial certificate).
  split.
  - exact (refined_final_matches projection run initial certificate).
  - eapply conditional_less_than_one_a_press_impossibility; eauto.
Qed.
