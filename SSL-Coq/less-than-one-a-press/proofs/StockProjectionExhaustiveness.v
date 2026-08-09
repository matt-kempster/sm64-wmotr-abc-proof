(** A non-circular decomposition of the remaining Area-1 stock-projection
    obligation.

    [StockArea1PreapplyPlatform] is strong enough to rule out a non-null
    platform at the fixed upper-warp sample, but it associates the current
    collision position with the platform value.  A real [gMarioPlatform]
    pointer was written at an earlier floor-query sample.  If queries are
    skipped, or State/Object/Graphics samples separate, those two positions
    need not be equal.  Proving the old projection sound without first
    proving this equality would therefore assume away the central Ink case.

    This file makes two abstract escape routes explicit:

    - a modeled stock write candidate and the current collision use distinct
      samples; or
    - a caller-classified owner observation is outside the canonical
      fifteen-kind identity/candidate model (outside the modeled envelope,
      a different-slot identity, a same-slot different ghost epoch, or an
      unclassified owner).

    The classifications below are exhaustive only over the supplied abstract
    records.  They do not claim that linked retail memory supplies the
    observations, that an object was actually selected from a live surface
    list, that a canonical map is unique or sound, that an object pointer has
    a particular ghost epoch, or that all dynamic-surface list nodes have been
    classified.  Those are the remaining Clight-memory and lifecycle bridges,
    rather than hidden assumptions of this module. *)

From Coq Require Import Classical_Prop Lia List ZArith.
From compcert Require Import Clight.
From LessThanOneAPress.Proofs Require Import
  Area1PlatformExhaustiveness GameTypes PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

(** * Finite owner identity and geometry cases *)

Definition object_ref_dec :
  forall left right : ObjectRef, {left = right} + {left <> right}.
Proof. decide equality; apply Nat.eq_dec. Defined.

Record Area1DynamicOwnerObservation : Type := {
  observed_owner_ref : ObjectRef;
  (** [None] means that the linked-memory classifier could not map the
      behavior/collision pair to one of the fifteen stock instances.  It does
      not mean that the raw C owner pointer was null. *)
  observed_owner_kind : option Area1SurfaceOwnerKind;
  observed_owner_query_position : PositionZ;
  observed_owner_floor_y : Z
}.

Definition CanonicalModeledCandidateObservation
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (observation : Area1DynamicOwnerObservation) : Prop :=
  exists kind,
    observed_owner_kind observation = Some kind /\
    observed_owner_ref observation = canonical_ref kind /\
    stock_area1_dynamic_floor_candidate kind
      (observed_owner_query_position observation)
      (observed_owner_floor_y observation).

Definition CanonicalOwnerOutsideModeledCandidate
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (observation : Area1DynamicOwnerObservation) : Prop :=
  exists kind,
    observed_owner_kind observation = Some kind /\
    observed_owner_ref observation = canonical_ref kind /\
    ~ stock_area1_dynamic_floor_candidate kind
        (observed_owner_query_position observation)
        (observed_owner_floor_y observation).

Definition KnownOwnerWithNoncanonicalIdentity
    (canonical_ref : Area1SurfaceOwnerKind -> ObjectRef)
    (observation : Area1DynamicOwnerObservation) : Prop :=
  exists kind,
    observed_owner_kind observation = Some kind /\
    observed_owner_ref observation <> canonical_ref kind.

Definition UnclassifiedDynamicOwner
    (observation : Area1DynamicOwnerObservation) : Prop :=
  observed_owner_kind observation = None.

Theorem area1_dynamic_owner_projection_cases_exhaustive :
  forall canonical_ref observation,
    CanonicalModeledCandidateObservation canonical_ref observation \/
    CanonicalOwnerOutsideModeledCandidate canonical_ref observation \/
    KnownOwnerWithNoncanonicalIdentity canonical_ref observation \/
    UnclassifiedDynamicOwner observation.
Proof.
  intros canonical_ref observation.
  destruct (observed_owner_kind observation) as [kind |] eqn:Hkind.
  - destruct (object_ref_dec
      (observed_owner_ref observation) (canonical_ref kind))
      as [Href | Href].
    + destruct (classic
        (stock_area1_dynamic_floor_candidate kind
          (observed_owner_query_position observation)
          (observed_owner_floor_y observation)))
        as [Hcandidate | Hcandidate].
      * left. exists kind. split; [exact Hkind |].
        split; [exact Href | exact Hcandidate].
      * right. left. exists kind. split; [exact Hkind |].
        split; [exact Href | exact Hcandidate].
    + right. right. left. exists kind.
      split; [exact Hkind | exact Href].
  - right. right. right. exact Hkind.
Qed.

(** Every recognized kind has an index in the checked fifteen-element list.
    Thus the noncanonical case above does not silently enlarge the kind
    universe; it changes only the concrete object identity. *)
Theorem recognized_area1_owner_has_finite_inventory_index :
  forall observation kind,
    observed_owner_kind observation = Some kind ->
    exists index,
      (index < 15)%nat /\
      nth_error all_area1_surface_owners index = Some kind.
Proof.
  intros observation kind _.
  pose proof area1_surface_owner_finite_inventory as
    (Hlength & _ & Hall).
  specialize (Hall kind).
  apply In_nth_error in Hall.
  destruct Hall as (index & Hindex).
  exists index. split.
  - rewrite <- Hlength.
    apply (proj1 (nth_error_Some all_area1_surface_owners index)).
    rewrite Hindex. discriminate.
  - exact Hindex.
Qed.

(** A noncanonical [ObjectRef] has the identity distinction needed by a future
    retail proof: either it is a different pool slot (a substitute and only a
    candidate clone after behavior/mesh provenance), or it is the same raw slot
    with a different ghost epoch.  Reuse and temporal ordering still have to be
    reconstructed from the concrete free-list history. *)
Theorem noncanonical_owner_identity_is_different_slot_or_ghost_epoch :
  forall observed canonical,
    observed <> canonical ->
    object_slot observed <> object_slot canonical \/
    (object_slot observed = object_slot canonical /\
     object_epoch observed <> object_epoch canonical).
Proof.
  intros [observed_slot observed_epoch]
    [canonical_slot canonical_epoch] Hdifferent.
  cbn in *.
  destruct (Nat.eq_dec observed_slot canonical_slot)
    as [Hslot | Hslot].
  - right. split; [exact Hslot |].
    intro Hepoch.
    apply Hdifferent.
    subst. reflexivity.
  - left. exact Hslot.
Qed.

Theorem upper_warp_dynamic_owner_requires_projection_escape :
  forall canonical_ref observation,
    upper_warp_contact (observed_owner_query_position observation) ->
    CanonicalOwnerOutsideModeledCandidate canonical_ref observation \/
    KnownOwnerWithNoncanonicalIdentity canonical_ref observation \/
    UnclassifiedDynamicOwner observation.
Proof.
  intros canonical_ref observation Hwarp.
  destruct (area1_dynamic_owner_projection_cases_exhaustive
    canonical_ref observation) as
    [Hstock | [Hgeometry | [Hidentity | Hunclassified]]].
  - destruct Hstock as (kind & _ & _ & Hcandidate).
    exfalso.
    eapply upper_warp_has_no_stock_dynamic_floor_candidate; eauto.
  - left. exact Hgeometry.
  - right. left. exact Hidentity.
  - right. right. exact Hunclassified.
Qed.

Theorem upper_warp_noncanonical_owner_has_different_slot_or_ghost_epoch :
  forall canonical_ref observation,
    upper_warp_contact (observed_owner_query_position observation) ->
    KnownOwnerWithNoncanonicalIdentity canonical_ref observation ->
    exists kind,
      observed_owner_kind observation = Some kind /\
      (object_slot (observed_owner_ref observation) <>
         object_slot (canonical_ref kind) \/
       (object_slot (observed_owner_ref observation) =
          object_slot (canonical_ref kind) /\
        object_epoch (observed_owner_ref observation) <>
          object_epoch (canonical_ref kind))).
Proof.
  intros canonical_ref observation _
    (kind & Hkind & Hnoncanonical).
  exists kind. split; [exact Hkind |].
  apply noncanonical_owner_identity_is_different_slot_or_ghost_epoch.
  exact Hnoncanonical.
Qed.

(** * Fixed-center, changed-center, noncanonical, and unclassified warp records *)

Record Area1UpperWarpObservation : Type := {
  observed_warp_ref : ObjectRef;
  observed_warp_has_stock_behavior : bool;
  observed_warp_center : PositionZ
}.

Definition FixedCanonicalUpperWarp
    (canonical_warp_ref : ObjectRef)
    (observation : Area1UpperWarpObservation) : Prop :=
  observed_warp_has_stock_behavior observation = true /\
  observed_warp_ref observation = canonical_warp_ref /\
  observed_warp_center observation = upper_warp_center.

Definition RelocatedCanonicalUpperWarp
    (canonical_warp_ref : ObjectRef)
    (observation : Area1UpperWarpObservation) : Prop :=
  observed_warp_has_stock_behavior observation = true /\
  observed_warp_ref observation = canonical_warp_ref /\
  observed_warp_center observation <> upper_warp_center.

Definition NoncanonicalStockBehaviorWarp
    (canonical_warp_ref : ObjectRef)
    (observation : Area1UpperWarpObservation) : Prop :=
  observed_warp_has_stock_behavior observation = true /\
  observed_warp_ref observation <> canonical_warp_ref.

Definition UnclassifiedWarpObject
    (observation : Area1UpperWarpObservation) : Prop :=
  observed_warp_has_stock_behavior observation = false.

Theorem area1_upper_warp_identity_and_position_cases_exhaustive :
  forall canonical_warp_ref observation,
    FixedCanonicalUpperWarp canonical_warp_ref observation \/
    RelocatedCanonicalUpperWarp canonical_warp_ref observation \/
    NoncanonicalStockBehaviorWarp canonical_warp_ref observation \/
    UnclassifiedWarpObject observation.
Proof.
  intros canonical_warp_ref observation.
  destruct (observed_warp_has_stock_behavior observation) eqn:Hbehavior.
  - destruct (object_ref_dec
      (observed_warp_ref observation) canonical_warp_ref)
      as [Href | Href].
    + destruct (classic
        (observed_warp_center observation = upper_warp_center))
        as [Hcenter | Hcenter].
      * left. repeat split; assumption.
      * right. left. repeat split; assumption.
    + right. right. left. split; assumption.
  - right. right. right. exact Hbehavior.
Qed.

Theorem noncanonical_stock_behavior_warp_is_different_slot_or_ghost_epoch :
  forall canonical_warp_ref observation,
    NoncanonicalStockBehaviorWarp canonical_warp_ref observation ->
    object_slot (observed_warp_ref observation) <>
      object_slot canonical_warp_ref \/
    (object_slot (observed_warp_ref observation) =
       object_slot canonical_warp_ref /\
     object_epoch (observed_warp_ref observation) <>
       object_epoch canonical_warp_ref).
Proof.
  intros canonical_warp_ref observation (_ & Hidentity).
  apply noncanonical_owner_identity_is_different_slot_or_ghost_epoch.
  exact Hidentity.
Qed.

(** * Last-write chronology with a distinct current collision sample *)

(** A non-null stock write *candidate*.  A completed-query constructor carries
    a query sample and finite-owner witness.  An inbound constructor carries an
    arbitrary non-null observation.  Neither constructor proves temporal
    ordering, absence of later stores, pointer retention, or linked execution;
    those are separate object-pool/lifecycle obligations.  US spawn-clear is
    absent because it writes null and cannot construct this relation. *)
Inductive StockNonNullPlatformWriteCandidate :
    PositionZ -> Area1DynamicOwnerObservation -> Prop :=
| NonNullWriteCompletedQueryCandidate :
    forall position observation kind,
      observed_owner_kind observation = Some kind ->
      observed_owner_query_position observation = position ->
      stock_area1_dynamic_floor_candidate kind position
        (observed_owner_floor_y observation) ->
      StockNonNullPlatformWriteCandidate position observation
| NonNullWriteInboundCandidate :
    forall node observation,
      StockNonNullPlatformWriteCandidate
        (area1_inbound_position node) observation.

Record StockNonNullTwoSampleCandidate : Type := {
  candidate_query_position : PositionZ;
  candidate_current_collision_position : PositionZ;
  candidate_owner_observation : Area1DynamicOwnerObservation;
  candidate_write_evidence :
    StockNonNullPlatformWriteCandidate
      candidate_query_position candidate_owner_observation
}.

(** This theorem is purely two-sample: a modeled stock query/inbound candidate
    and an upper-warp collision cannot use the same position.  Calling the
    first sample an actual last write, proving retention, and deriving physical
    movement require the linked chronology that this record deliberately does
    not encode. *)
Theorem stock_nonnull_upper_warp_candidate_requires_distinct_samples :
  forall carry,
    upper_warp_contact (candidate_current_collision_position carry) ->
    candidate_query_position carry <>
      candidate_current_collision_position carry.
Proof.
  intros carry Hwarp Hequal.
  destruct (candidate_write_evidence carry) as
    [position observation kind Hkind Hquery Hcandidate
    |node observation].
  - cbn in Hequal. subst position.
    eapply upper_warp_has_no_stock_dynamic_floor_candidate; eauto.
  - cbn in Hequal.
    apply (no_stock_area1_inbound_node_overlaps_upper_warp node).
    rewrite <- Hequal in Hwarp.
    exact Hwarp.
Qed.

(** When the candidate query/current samples are equal and the owner is
    recognized, the two-sample relation projects into the old relation.  A
    linked proof must additionally establish that the candidate was the last
    effective writer and was retained to the current state. *)
Theorem stable_recognized_write_candidate_projects_to_stock_preapply :
  forall source current observation kind,
    StockNonNullPlatformWriteCandidate source observation ->
    observed_owner_kind observation = Some kind ->
    source = current ->
    StockArea1PreapplyPlatform current (Some kind).
Proof.
  intros source current observation kind Hlast Hkind Hstable.
  subst current.
  destruct Hlast as
    [position observation last_kind Hlast_kind Hquery Hcandidate
    |node observation].
  - rewrite Hkind in Hlast_kind.
    inversion Hlast_kind. subst last_kind.
    apply PreapplyFromCompletedFinalQuery.
    cbn. exists (observed_owner_floor_y observation).
    exact Hcandidate.
  - apply PreapplyFromRetainedInboundPointer.
Qed.

(** A sufficient, deliberately factored logical bridge for the existing
    Clight-state projection.  Its premise still has to be derived from linked
    execution, including last-writer and retention evidence not represented by
    [StockNonNullPlatformWriteCandidate].  The separation witness below shows
    why sample equality cannot be silently dropped. *)
Definition StableRecognizedStockWriteCandidateBridge
    (project :
      Clight.state ->
        option (PositionZ * option Area1SurfaceOwnerKind)) : Prop :=
  forall state current kind,
    project state = Some (current, Some kind) ->
    exists source observation,
      StockNonNullPlatformWriteCandidate source observation /\
      observed_owner_kind observation = Some kind /\
      source = current.

Theorem stable_recognized_write_candidate_bridge_is_sufficient :
  forall project,
    StableRecognizedStockWriteCandidateBridge project ->
    Area1StockPreapplyProjectionSound project.
Proof.
  intros project Hbridge state position platform Hproject.
  destruct platform as [kind |].
  - destruct (Hbridge state position kind Hproject) as
      (source & observation & Hlast & Hkind & Hstable).
    eapply stable_recognized_write_candidate_projects_to_stock_preapply; eauto.
  - apply PreapplyFromUSSpawnClear.
Qed.

(** * A checked abstract witness to the current relation's missing case *)

Definition abstract_separation_query_position : PositionZ := {|
  position_x := 5900;
  position_y := 100;
  position_z := 4400
|}.

Definition abstract_separation_owner_ref : ObjectRef := {|
  object_slot := 0%nat;
  object_epoch := 0%nat
|}.

Definition abstract_separation_owner_observation : Area1DynamicOwnerObservation := {|
  observed_owner_ref := abstract_separation_owner_ref;
  observed_owner_kind := Some A1BreakableSouth;
  observed_owner_query_position := abstract_separation_query_position;
  observed_owner_floor_y := 100
|}.

Theorem abstract_separation_query_is_modeled_dynamic_candidate :
  stock_area1_dynamic_floor_candidate A1BreakableSouth
    abstract_separation_query_position 100.
Proof.
  unfold stock_area1_dynamic_floor_candidate,
    inside_horizontal_envelope, area1_owner_envelope,
    abstract_separation_query_position, platform_floor_tolerance.
  cbn. lia.
Qed.

(** This inhabits only the handwritten candidate relation; it does not show
    that retail [find_floor] selected the breakable, wrote a pointer, or
    retained it to another frame. *)
Theorem abstract_separation_write_candidate_is_modeled :
  StockNonNullPlatformWriteCandidate
    abstract_separation_query_position abstract_separation_owner_observation.
Proof.
  econstructor 1 with (kind := A1BreakableSouth).
  - reflexivity.
  - reflexivity.
  - exact abstract_separation_query_is_modeled_dynamic_candidate.
Qed.

Theorem upper_warp_center_has_integer_contact :
  upper_warp_contact upper_warp_center.
Proof.
  unfold upper_warp_contact, horizontal_distance_squared,
    upper_warp_center, upper_warp_radius, mario_hitbox_radius,
    upper_warp_y, upper_warp_height, mario_hitbox_height.
  cbn. lia.
Qed.

(** This is not a reachable gameplay counterexample or a modeled carry.  It is
    a separation witness: the candidate relation is inhabited at one sample,
    upper-warp contact holds at an independent sample, and the old
    same-position relation rejects the latter.  A retail proof must supply the
    temporal write/retention bridge before these samples may be related. *)
Theorem abstract_distinct_samples_are_not_same_position_stock_preapply :
  StockNonNullPlatformWriteCandidate
    abstract_separation_query_position abstract_separation_owner_observation /\
  upper_warp_contact upper_warp_center /\
  ~ StockArea1PreapplyPlatform upper_warp_center
      (Some A1BreakableSouth).
Proof.
  split; [exact abstract_separation_write_candidate_is_modeled |].
  split; [exact upper_warp_center_has_integer_contact |].
  intro Hpreapply.
  pose proof (stock_area1_upper_warp_preapply_platform_null
    upper_warp_center (Some A1BreakableSouth)
    Hpreapply upper_warp_center_has_integer_contact) as Hnull.
  discriminate.
Qed.

(** The strongest admission-free *abstract* boundary from this tranche.  It
    packages the supplied-record partition, the distinct-sample fact, and the
    separation witness.  It does not state that retail execution supplies any
    of those records or connect an Ink candidate to these alternatives. *)
Definition StockProjectionAbstractCheckedBoundary : Prop :=
  (forall canonical_ref observation,
    upper_warp_contact (observed_owner_query_position observation) ->
    CanonicalOwnerOutsideModeledCandidate canonical_ref observation \/
    KnownOwnerWithNoncanonicalIdentity canonical_ref observation \/
    UnclassifiedDynamicOwner observation) /\
  (forall carry,
    upper_warp_contact (candidate_current_collision_position carry) ->
    candidate_query_position carry <>
      candidate_current_collision_position carry) /\
  (StockNonNullPlatformWriteCandidate
      abstract_separation_query_position abstract_separation_owner_observation /\
   upper_warp_contact upper_warp_center /\
   ~ StockArea1PreapplyPlatform upper_warp_center
       (Some A1BreakableSouth)).

Theorem stock_projection_abstract_checked_boundary_holds :
  StockProjectionAbstractCheckedBoundary.
Proof.
  unfold StockProjectionAbstractCheckedBoundary.
  split; [exact upper_warp_dynamic_owner_requires_projection_escape |].
  split; [exact stock_nonnull_upper_warp_candidate_requires_distinct_samples |].
  exact abstract_distinct_samples_are_not_same_position_stock_preapply.
Qed.
