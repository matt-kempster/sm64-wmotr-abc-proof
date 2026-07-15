From Coq Require Import ZArith.
From SSLEyerok.Proofs Require Import AuthenticReachability Binary32Boundary
  FirstHandBarrier GeneratedFacts SchedulerInvariant Spec StateMachine
  VerticalBound.

Local Open Scope Z_scope.

Theorem eyerok_no_unbounded_rise_certificate :
  generated_model_shape /\
  generated_critical_source_shape /\
  first_hand_barrier_certificate /\
  (forall scheduler,
      scheduler_reachable scheduler -> ~ runaway_seed scheduler) /\
  (forall rank state,
      vertically_reachable rank state -> state_y state <= global_height_ceiling) /\
  (forall rank run,
      vertical_run rank run -> ~ rises_unboundedly run) /\
  audited_coupled_reachability_certificate /\
  binary32_boundary_certificate /\
  (forall initial_y bound,
      exists frames, bound < runaway_height_after frames initial_y).
Proof.
  refine (conj generated_model_shape_holds _).
  refine (conj generated_critical_source_shape_holds _).
  refine (conj first_hand_barrier_certificate_holds _).
  refine (conj reachable_scheduler_excludes_runaway_seed _).
  refine (conj every_reachable_hand_below_global_ceiling _).
  refine (conj no_safe_vertical_run_rises_unboundedly _).
  refine (conj audited_coupled_reachability_certificate_holds _).
  refine (conj binary32_boundary_certificate_holds _).
  exact runaway_lasso_is_unbounded.
Qed.
