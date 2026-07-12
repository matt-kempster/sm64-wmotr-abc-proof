From Coq Require Import ZArith.
From SSLPoleBypass.Proofs Require Import GeneratedFacts PoleArithmetic PoleRoute Spec.

Local Open Scope Z_scope.

Theorem pole_route_minimum_a_certificate :
  generated_pole_model_shape /\ generated_pole_source_shape /\
  (forall frames, 0 <= frames -> ~ soft_clearable frames) /\
  (forall trace, executes NormalizedPole trace SixthFloor ->
      (1 <= a_count trace)%nat) /\
  exists trace, executes NormalizedPole trace SixthFloor /\ a_count trace = 1%nat.
Proof.
  refine (conj generated_pole_model_shape_holds _).
  refine (conj generated_pole_source_shape_holds _).
  refine (conj soft_bonk_never_clearable _).
  exact closed_world_pole_route_minimum_a_is_one.
Qed.

(* Deliberately not proved here: every authentic zero-A trace from the
   Pyramid bottom is simulated by [executes]. That is the global bypass-
   completeness obligation recorded in docs/claim.md. *)
