From Coq Require Import Lia List.
From SSLPoleBypass.Proofs Require Import PoleRoute.

Section AuthenticBoundary.

  Variable authentic_run : Type.
  Variable starts_at_pyramid_bottom : authentic_run -> Prop.
  Variable reaches_sixth_floor : authentic_run -> Prop.
  Variable physical_a_count : authentic_run -> nat.

  Definition bypass_model_complete : Prop :=
    forall run,
      starts_at_pyramid_bottom run ->
      reaches_sixth_floor run ->
      exists model_trace,
        executes NormalizedPole model_trace SixthFloor /\
        (a_count model_trace <= physical_a_count run)%nat.

  Definition authentic_one_a_witness : Prop :=
    exists run,
      starts_at_pyramid_bottom run /\
      reaches_sixth_floor run /\
      physical_a_count run = 1%nat.

  Theorem global_lower_bound_from_bypass_model_complete :
    bypass_model_complete ->
    forall run,
      starts_at_pyramid_bottom run ->
      reaches_sixth_floor run ->
      (1 <= physical_a_count run)%nat.
  Proof.
    intros Hcomplete run Hstart Hreaches.
    destruct (Hcomplete run Hstart Hreaches)
      as (model_trace & Hexec & Hcount).
    pose proof (every_pole_route_uses_a model_trace Hexec).
    lia.
  Qed.

  Theorem global_minimum_one_from_explicit_boundary :
    bypass_model_complete ->
    authentic_one_a_witness ->
    (forall run,
        starts_at_pyramid_bottom run ->
        reaches_sixth_floor run ->
        (1 <= physical_a_count run)%nat) /\
    exists run,
      starts_at_pyramid_bottom run /\
      reaches_sixth_floor run /\
      physical_a_count run = 1%nat.
  Proof.
    intros Hcomplete Hwitness.
    split.
    - exact (global_lower_bound_from_bypass_model_complete Hcomplete).
    - exact Hwitness.
  Qed.

End AuthenticBoundary.
