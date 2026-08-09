(** Source-bounded records for six proposed Area-1 payload-installer shapes.

    This file deliberately separates exclusions proved in the finite stock
    owner/provenance model from the cases that still require linked Clight
    reachability.  In particular, it does not turn the stock projection into
    an assumption and it does not claim that Ink's injected timer-131 boundary
    is reachable from a clean entry. *)

From Coq Require Import ZArith.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness InkPayloadInstaller StateFirstInstaller
  PyramidTopPU Timer131Surface.

Local Open Scope Z_scope.

(** The stock State-first constructor is already contradictory before any
    matrix arithmetic: a non-null pre-apply pointer at the fixed upper-warp
    collision sample cannot have the modeled stock provenance. *)
Theorem installer_coverage_excludes_stock_state_first :
  StockStateFirstInstallerAttempt -> False.
Proof.
  exact no_source_bounded_stock_state_first_installer.
Qed.

(** Fixed-placement physical co-location with the one stock pyramid top.  A
    relocation or collision-preserving clone does not satisfy this record and
    therefore is intentionally not excluded by the theorem. *)
Record FixedStockTopCoLocationAttempt : Type := {
  fixed_top_contact_position : PositionZ;
  fixed_top_floor_y : Z;
  fixed_top_hits_stock_upper_warp :
    upper_warp_contact fixed_top_contact_position;
  fixed_top_is_stock_floor_candidate :
    stock_area1_dynamic_floor_candidate
      A1PyramidTop fixed_top_contact_position fixed_top_floor_y
}.

Theorem installer_coverage_excludes_fixed_stock_top_colocation :
  FixedStockTopCoLocationAttempt -> False.
Proof.
  intros attempt.
  eapply (upper_warp_has_no_stock_dynamic_floor_candidate
    A1PyramidTop
    (fixed_top_contact_position attempt)
    (fixed_top_floor_y attempt)).
  - exact (fixed_top_hits_stock_upper_warp attempt).
  - exact (fixed_top_is_stock_floor_candidate attempt).
Qed.

(** Every non-top owner in the fifteen-owner Area-1 inventory is horizontally
    disjoint from the fixed upper-warp interaction sample.  This excludes the
    stock "another owner" branch without pretending to cover a relocated,
    cloned, or otherwise non-stock owner. *)
Record OtherStockOwnerInstallerAttempt : Type := {
  other_stock_owner : Area1SurfaceOwnerKind;
  other_stock_owner_is_not_top : other_stock_owner <> A1PyramidTop;
  other_stock_contact_position : PositionZ;
  other_stock_hits_upper_warp :
    upper_warp_contact other_stock_contact_position;
  other_stock_contains_contact_position :
    inside_horizontal_envelope
      (area1_owner_envelope other_stock_owner)
      other_stock_contact_position
}.

Theorem installer_coverage_excludes_every_non_top_stock_owner :
  OtherStockOwnerInstallerAttempt -> False.
Proof.
  intros attempt.
  eapply non_top_owner_envelope_disjoint_from_upper_warp.
  - exact (other_stock_owner_is_not_top attempt).
  - exact (other_stock_hits_upper_warp attempt).
  - exact (other_stock_contains_contact_position attempt).
Qed.

(** A post-commit transport which leaves the final platform-query sample in
    the fixed warp region cannot install a stock dynamic owner.  The genuinely
    different case--transporting the final query away from the cached warp
    sample and onto a dynamic surface--remains open. *)
Record PositionPreservingPostCommitAttempt : Type := {
  post_commit_query_position : PositionZ;
  post_commit_query_owner : option Area1SurfaceOwnerKind;
  post_commit_hits_upper_warp :
    upper_warp_contact post_commit_query_position;
  post_commit_is_stock_final_query :
    stock_area1_final_platform_query
      post_commit_query_position post_commit_query_owner;
  post_commit_installs_nonnull_owner :
    post_commit_query_owner <> None
}.

Theorem installer_coverage_excludes_position_preserving_post_commit :
  PositionPreservingPostCommitAttempt -> False.
Proof.
  intros attempt.
  apply (post_commit_installs_nonnull_owner attempt).
  eapply stock_upper_warp_final_query_clears_platform.
  - exact (post_commit_hits_upper_warp attempt).
  - exact (post_commit_is_stock_final_query attempt).
Qed.

(** One or more skipped-query frames cannot rescue a non-null pointer when
    their provenance remains inside [StockArea1PreapplyPlatform].  The linked
    scheduling proof that every retail skip has this provenance remains a
    separate obligation. *)
Record StockFrozenCarryInstallerAttempt : Type := {
  frozen_carry_position : PositionZ;
  frozen_carry_owner : option Area1SurfaceOwnerKind;
  frozen_carry_prior_provenance :
    StockArea1PreapplyPlatform frozen_carry_position frozen_carry_owner;
  frozen_carry_hits_upper_warp :
    upper_warp_contact frozen_carry_position;
  frozen_carry_is_nonnull : frozen_carry_owner <> None
}.

Theorem installer_coverage_excludes_stock_provenanced_frozen_carry :
  StockFrozenCarryInstallerAttempt -> False.
Proof.
  intros attempt.
  apply (frozen_carry_is_nonnull attempt).
  eapply stock_area1_upper_warp_preapply_platform_null.
  - apply PreapplyAfterFrozenFrames.
    exact (frozen_carry_prior_provenance attempt).
  - exact (frozen_carry_hits_upper_warp attempt).
Qed.

(** Ink's non-null graphical retry has not been eliminated by the local
    arithmetic.  The exact timer-131 State sample is rejected, the mid-face
    Graphics sample is accepted, and the authenticated conditional fixture
    records the same top pointer through timers 493, 498, and 513 with no A
    input.  These are value/trace receipts, not a clean-entry or linked-Clight
    reachability theorem. *)
Definition Timer131InkConditionalTraceBoundary : Prop :=
  timer131_buffer_observation timer131_state_query timer131_state_face =
    Some (1156733869, 3297287085, true) /\
  timer131_buffer_observation
      timer131_midface_retry_query timer131_retry_face =
    Some (1155464726, 1116741280, false) /\
  midface_timer493_floor_owner timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer493_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer498_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer513_platform timer131_jp_midface_capture_observation =
    midface_top_pointer timer131_jp_midface_capture_observation /\
  midface_timer513_top_active timer131_jp_midface_capture_observation = 0 /\
  midface_timer513_free_depth timer131_jp_midface_capture_observation = 0 /\
  midface_first_area2_free_depth timer131_jp_midface_capture_observation = 47 /\
  midface_a_pressed_frames timer131_jp_midface_capture_observation = 0 /\
  midface_a_down_frames timer131_jp_midface_capture_observation = 0 /\
  midface_controller_a_frames timer131_jp_midface_capture_observation = 0.

Theorem installer_coverage_carries_ink_into_conditional_trace :
  Timer131InkConditionalTraceBoundary.
Proof.
  unfold Timer131InkConditionalTraceBoundary.
  repeat split.
Qed.

(** One checked boundary for the installer-coverage tranche.  Its negative
    conjuncts quantify only over the explicitly source-bounded records above;
    the final positive conjunct says that Ink remains a conditional candidate,
    not that retail can install its initial three-view gap. *)
Definition InstallerCoverageCheckedBoundary : Prop :=
  (StockStateFirstInstallerAttempt -> False) /\
  (FixedStockTopCoLocationAttempt -> False) /\
  (OtherStockOwnerInstallerAttempt -> False) /\
  (PositionPreservingPostCommitAttempt -> False) /\
  (StockFrozenCarryInstallerAttempt -> False) /\
  Timer131InkConditionalTraceBoundary.

Theorem installer_coverage_checked_boundary_holds :
  InstallerCoverageCheckedBoundary.
Proof.
  unfold InstallerCoverageCheckedBoundary.
  split; [exact installer_coverage_excludes_stock_state_first |].
  split; [exact installer_coverage_excludes_fixed_stock_top_colocation |].
  split; [exact installer_coverage_excludes_every_non_top_stock_owner |].
  split; [exact installer_coverage_excludes_position_preserving_post_commit |].
  split; [exact installer_coverage_excludes_stock_provenanced_frozen_carry |].
  exact installer_coverage_carries_ink_into_conditional_trace.
Qed.
