From Demo.Proofs Require Import SourceFacts DemoDispatchFacts DemoStartExecution
  DemoTitleStartExecution DemoLevelSelectionExecution DemoGameplayBoundary
  DemoPauseExclusion DemoScriptDispatchFacts DemoStartWarpExecution DemoLoaderExecution
  DemoLoadedTitleExecution DemoConditionalDispatchExecution DemoStartSchedulingExecution
  DemoPlaybackExecution.

(** This capstone composes actual source/semantic components on the route to
    the gameplay invariant. It is not yet a theorem of no desync from boot. *)
Definition demo_checked_boundary_claim : Prop :=
  demo_source_boundary_claim /\ demo_dispatch_boundary_claim /\
  demo_installation_execution_claim_us_jp /\
  demo_first_title_start_claim_us_jp /\
  demo_complete_interpreter_level_selection_claim_us_jp /\
  demo_gameplay_boundary_claim /\ demo_complete_pause_exclusion_claim /\
  demo_script_dispatch_routes_claim_us_jp /\ demo_start_warp_execution_claim /\
  demo_loader_execution_boundary_claim_us_jp /\ demo_dma_to_first_title_claim_us_jp /\
  demo_conditional_dispatch_execution_boundary_claim_us_jp /\
  demo_start_scheduling_execution_claim /\ demo_playback_execution_claim_us_jp.

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
                (conj generated_demo_start_warp_execution_us_jp
                  (conj generated_demo_loader_execution_boundary_us_jp
                    (conj generated_dma_to_first_title_us_jp
                      (conj generated_demo_conditional_dispatch_execution_boundary_us_jp
                        (conj generated_demo_next_is_really_scheduled_us_jp
                          generated_demo_playback_execution_us_jp))))))))))))).
Qed.
