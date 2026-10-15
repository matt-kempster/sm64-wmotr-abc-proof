From Demo.Proofs Require Import SourceFacts DemoDispatchFacts DemoStartExecution
  DemoTitleStartExecution DemoLevelSelectionExecution DemoGameplayBoundary
  DemoPauseExclusion DemoScriptDispatchFacts DemoStartWarpExecution.

(** This capstone composes actual source/semantic components on the route to
    the gameplay invariant. It is not yet a theorem of no desync from boot. *)
Definition demo_checked_boundary_claim : Prop :=
  demo_source_boundary_claim /\ demo_dispatch_boundary_claim /\
  demo_installation_execution_claim_us_jp /\
  demo_first_title_start_claim_us_jp /\
  demo_complete_interpreter_level_selection_claim_us_jp /\
  demo_gameplay_boundary_claim /\ demo_complete_pause_exclusion_claim /\
  demo_script_dispatch_routes_claim_us_jp /\ demo_start_warp_execution_claim.

Theorem checked_demo_source_boundary_us_jp : demo_checked_boundary_claim.
Proof.
  exact (conj generated_demo_source_boundary_us_jp
    (conj generated_demo_dispatch_boundary_us_jp
      (conj generated_demo_installation_execution_us_jp
        (conj generated_first_title_start_us_jp
          (conj generated_demo_complete_interpreter_level_selection_us_jp
            (conj generated_demo_gameplay_boundary_us_jp
            (conj generated_demo_complete_pause_exclusion_us_jp
              (conj generated_demo_script_dispatch_routes_us_jp
                generated_demo_start_warp_execution_us_jp)))))))).
Qed.
