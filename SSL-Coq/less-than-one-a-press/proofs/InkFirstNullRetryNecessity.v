(** A narrow capstone for Ink's first-NULL branch.

    [InkFallback] gives the source-ordered three-way floor outcome, while
    [RetailFatalLatch] proves that an accepted fatal request cannot later be
    replaced by the upper object-warp request in its audited scheduler model.
    This file joins those facts without claiming that a retail Clight trace
    has already been refined to either abstraction.

    The two projection premises below are intentionally explicit.  A linked
    counterexample must identify the abstract floor outcome and, if both
    queries were NULL, must project its later successful upper warp to the
    latch model.  Under precisely those premises, the only surviving
    first-NULL outcome is a non-NULL Graphics retry. *)

From Coq Require Import List.
From LessThanOneAPress.Proofs Require Import
  Area1FirstNull InkFallback RetailFatalLatch.

(** Re-export the finite US/JP static traversal receipt at the capstone.  This
    is evidence that the chosen first sample has no static result; it is not a
    claim about the live dynamic lists or reachability of that sample. *)
Definition ink_first_query_static_traversal_receipt :=
  area1_q_static_traversal_computed.

(** [outcome <> InkStateFloorFound] is the live first-query-NULL projection.
    The implication is the live route-success projection: the route requires
    an accepted upper object warp, so a both-NULL execution must expose that
    acceptance in the audited latch run. *)
Record InkFirstNullRouteProjection
    (outcome : InkFloorSamplingOutcome)
    (kind : RetailFatalKind)
    (events : list RetailLatchEvent) : Prop := {
  projected_first_query_is_null :
    outcome <> InkStateFloorFound;
  projected_both_null_route_needs_upper_acceptance :
    outcome = InkBothFloorQueriesNull ->
    retail_upper_request_accepted
      (retail_latch_run events (retail_after_both_null_frame kind)) = true
}.

(** Main reduction: a viable first-NULL Ink execution cannot take the
    retry-NULL branch.  It must return a floor on the Graphics retry. *)
Theorem linked_first_null_ink_route_requires_nonnull_graphics_retry :
  forall outcome kind events,
    InkFirstNullRouteProjection outcome kind events ->
    outcome = InkGraphicsRetryFound.
Proof.
  intros outcome kind events [Hfirst_null Hupper_if_both_null].
  destruct outcome.
  - exfalso.
    exact (Hfirst_null eq_refl).
  - reflexivity.
  - pose proof (Hupper_if_both_null eq_refl) as Haccepted.
    pose proof
      (retail_fatal_persists_or_reset_destroys_disappeared kind events)
      as [_ Hblocked].
    rewrite Hblocked in Haccepted.
    discriminate.
Qed.

(** The direct negative form is often easier for a future trace refinement:
    after two NULL results, every audited suffix rejects the upper request. *)
Theorem projected_double_null_ink_route_is_impossible :
  forall kind events,
    ~ InkFirstNullRouteProjection InkBothFloorQueriesNull kind events.
Proof.
  intros kind events Hprojection.
  pose proof
    (linked_first_null_ink_route_requires_nonnull_graphics_retry
      InkBothFloorQueriesNull kind events Hprojection) as Hcontra.
  discriminate.
Qed.

(** Source syntax plus the scheduler reduction are kept together as a checked
    boundary.  It still does not supply live list traversal, concrete Clight
    event projection, alias safety, or external-call frame conditions. *)
Definition InkFirstNullRetryNecessityCheckedBoundary : Prop :=
  RetailFatalLatchCheckedBoundary /\
  (forall outcome kind events,
    InkFirstNullRouteProjection outcome kind events ->
    outcome = InkGraphicsRetryFound).

Theorem ink_first_null_retry_necessity_checked_boundary :
  InkFirstNullRetryNecessityCheckedBoundary.
Proof.
  split.
  - exact retail_fatal_latch_checked_boundary.
  - exact linked_first_null_ink_route_requires_nonnull_graphics_retry.
Qed.
