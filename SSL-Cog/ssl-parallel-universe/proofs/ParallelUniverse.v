From SSLPU.Proofs Require Import ASTFacts Spec.

Definition ssl_area2_no_parallel_universe_statement : Prop :=
  forall before after dx dz,
    ssl_area2_transition_certificate before after dx dz ->
    ~ state_in_parallel_universe after.

Theorem generated_pu_model_shape_checked :
  generated_pu_model_shape.
Proof.
  exact generated_pu_model_shape_holds.
Qed.

Theorem ssl_area2_no_parallel_universe :
  ssl_area2_no_parallel_universe_statement.
Proof.
  unfold ssl_area2_no_parallel_universe_statement.
  intros before after dx dz Hcertificate.
  exact (certified_transition_forbids_parallel_universe
    before after dx dz Hcertificate).
Qed.

Theorem generated_model_and_area2_bounds_forbid_parallel_universe :
  generated_pu_model_shape /\
  ssl_area2_no_parallel_universe_statement.
Proof.
  split.
  - exact generated_pu_model_shape_checked.
  - exact ssl_area2_no_parallel_universe.
Qed.
