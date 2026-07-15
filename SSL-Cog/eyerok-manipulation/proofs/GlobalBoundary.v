From Coq Require Import Lia ZArith.
From SSLEyerok.Proofs Require Import Spec StateMachine VerticalBound.

Local Open Scope Z_scope.

Section AuthenticBoundary.

  Variable authentic_run : Type.
  Variable authentic_valid : authentic_run -> Prop.
  Variable authentic_height : authentic_run -> nat -> Z.
  Variable authentic_rank : authentic_run -> hand_rank.

  Definition authentic_refines_vertical_model : Prop :=
    forall run frame,
      authentic_valid run ->
      exists model_state,
        vertically_reachable (authentic_rank run) model_state /\
        authentic_height run frame = state_y model_state.

  Definition authentic_rises_unboundedly (run : authentic_run) : Prop :=
    forall bound, exists frame, bound < authentic_height run frame.

  Theorem authentic_height_bounded_from_refinement :
    authentic_refines_vertical_model ->
    forall run frame,
      authentic_valid run ->
      authentic_height run frame <= global_height_ceiling.
  Proof.
    intros Hrefines run frame Hvalid.
    destruct (Hrefines run frame Hvalid) as (state & Hreach & Hheight).
    rewrite Hheight.
    exact (every_reachable_hand_below_global_ceiling
      (authentic_rank run) state Hreach).
  Qed.

  Theorem authentic_no_unbounded_rise_from_refinement :
    authentic_refines_vertical_model ->
    forall run, authentic_valid run -> ~ authentic_rises_unboundedly run.
  Proof.
    intros Hrefines run Hvalid Hunbounded.
    destruct (Hunbounded global_height_ceiling) as (frame & Hhigher).
    pose proof (authentic_height_bounded_from_refinement
      Hrefines run frame Hvalid) as Hbounded.
    lia.
  Qed.

End AuthenticBoundary.
