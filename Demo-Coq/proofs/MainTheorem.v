From Demo.Proofs Require Import SourceFacts DemoDispatchFacts DemoStartExecution
  DemoTitleStartExecution DemoLevelSelectionExecution DemoGameplayBoundary
  DemoPauseExclusion DemoScriptDispatchFacts DemoStartWarpExecution DemoLoaderExecution
  DemoLoadedTitleExecution DemoConditionalDispatchExecution DemoStartSchedulingExecution
  DemoPlaybackExecution DemoPlaybackAdvanceExecution DemoNumericAddressExecution DemoNormalStartExecution
  DemoScriptNumericImage DemoInstantWarpExecution DemoNormalTimerExecution
  DemoControllerInputExecution DemoNormalPreObjectsExecution DemoNumericDispatchExecution
  DemoPrivateGlobalLinkReceipt DemoConsumedInputExecution DemoCurrentLevelGetExecution
  DemoAreaInitialization DemoAreaInitialMemory DemoAnalogInputExecution
  DemoControllerCopyExecution DemoNormalPostCameraExecution DemoExternArrayCompletion
  DemoDelayedWarpTerminalExecution DemoControllerReadExecution
  DemoNormalDelayedExecution DemoSelectedLinkTypeBoundary.

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
  demo_start_scheduling_execution_claim /\ demo_complete_playback_consumer_claim_us_jp /\
  demo_numeric_address_execution_boundary_claim_us_jp /\ demo_normal_start_execution_claim /\
  demo_script_numeric_image_boundary_claim_us_jp /\ demo_instant_warp_execution_claim /\
  demo_normal_timer_boundary_claim /\ demo_controller_input_execution_claim_us_jp /\
  demo_normal_preobjects_execution_claim /\ demo_numeric_dispatch_execution_boundary_claim_us_jp /\
  demo_private_global_link_boundary_claim_us_jp /\ demo_consumed_record_start_boundary_claim_us_jp /\
  demo_current_level_get_claim_us_jp /\ demo_area_initialization_claim_us_jp /\
  demo_area_initial_memory_execution_claim /\ demo_arbitrary_analog_call_claim_us_jp /\
  demo_controller_copy_execution_claim /\ demo_normal_postcamera_execution_claim /\
  demo_extern_array_completion_boundary_claim_us_jp /\ demo_delayed_warp_execution_claim /\
  demo_controller_post_polling_claim_us_jp /\ demo_normal_delayed_execution_claim /\
  demo_selected_link_type_boundary_claim_us_jp.

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
                          (conj generated_complete_playback_consumer_us_jp
                            (conj generated_demo_numeric_address_execution_boundary_us_jp
                              (conj generated_normal_demo_start_prefix_executes
                                (conj generated_demo_script_numeric_image_boundary_us_jp
                                  (conj generated_demo_instant_warp_execution_us_jp
                                    (conj generated_normal_timer_boundary_us_jp
                                      (conj generated_demo_controller_input_execution_us_jp
                                        (conj generated_normal_preobjects_interval_executes
                                          (conj generated_demo_numeric_dispatch_execution_boundary_us_jp
                                            (conj generated_demo_private_global_link_boundary_us_jp
                                              (conj generated_demo_consumed_record_start_boundary_us_jp
                                                (conj generated_current_level_get_us_jp
                                                  (conj generated_demo_area_initialization_us_jp
                                                    (conj generated_area_initial_memory_executes_clear_areas_us_jp
                                                      (conj generated_demo_arbitrary_analog_call_us_jp
                                                        (conj generated_controller_copy_execution_us_jp
                                                          (conj generated_normal_postcamera_interval_executes_us_jp
                                                            (conj generated_demo_extern_array_completion_boundary_us_jp
                                                              (conj generated_demo_delayed_warp_execution_us_jp
                                                                (conj generated_controller_post_polling_us_jp
                                                                  (conj generated_normal_delayed_execution_us_jp
                                                                    generated_demo_selected_link_type_boundary_us_jp)))))))))))))))))))))))))))))))))).
Qed.
