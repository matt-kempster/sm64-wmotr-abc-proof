From Coq Require Import List.
From compcert Require Import AST Clight Events Linking Smallstep.
From LessThanOneAPress.Generated Require Import
  us_game_init us_mario us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene
  us_mario_actions_moving us_mario_actions_object us_mario_actions_stationary
  us_mario_actions_submerged us_mario_step us_interaction us_save_file us_object_collision
  us_object_list_processor us_behavior_script us_level_script us_graph_node
  us_spawn_object us_object_helpers us_debug us_memory us_mario_misc
  us_obj_behaviors
  us_obj_behaviors_2 us_behavior_actions us_behavior_data us_area
  us_level_update us_platform_displacement us_math_util us_surface_collision
  us_surface_load
  us_macro_special_objects us_ssl_script
  us_ssl_area1_macro us_ssl_area2_macro us_ssl_collision
  jp_game_init jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene
  jp_mario_actions_moving jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction jp_save_file jp_object_collision
  jp_object_list_processor jp_behavior_script jp_level_script jp_graph_node
  jp_spawn_object jp_object_helpers jp_debug jp_memory jp_mario_misc
  jp_obj_behaviors
  jp_obj_behaviors_2 jp_behavior_actions jp_behavior_data jp_area
  jp_level_update jp_platform_displacement jp_math_util jp_surface_collision
  jp_surface_load
  jp_macro_special_objects jp_ssl_script
  jp_ssl_area1_macro jp_ssl_area2_macro jp_ssl_collision.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry AreaTransitions.

Import ListNotations.

(* A finite Clight step fragment.  A future concrete target theorem must also
   connect its endpoints to Clight initial_state/final_state; this record alone
   does not do so. *)
Record ImportedClightRun := {
  run_program : Clight.program;
  run_start : Clight.state;
  run_trace : Events.trace;
  run_final : Clight.state;
  run_steps :
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv run_program)
      run_start run_trace run_final
}.

Definition us_translation_units : list Clight.program :=
  [ us_game_init.prog; us_mario.prog; us_mario_actions_airborne.prog;
    us_mario_actions_automatic.prog; us_mario_actions_cutscene.prog;
    us_mario_actions_moving.prog;
    us_mario_actions_object.prog; us_mario_actions_stationary.prog;
    us_mario_actions_submerged.prog;
    us_mario_step.prog; us_interaction.prog; us_save_file.prog;
    us_object_collision.prog; us_object_list_processor.prog;
    us_behavior_script.prog; us_level_script.prog; us_graph_node.prog;
    us_spawn_object.prog; us_object_helpers.prog; us_debug.prog;
    us_memory.prog; us_mario_misc.prog; us_obj_behaviors.prog;
    us_obj_behaviors_2.prog; us_behavior_actions.prog;
    us_behavior_data.prog; us_area.prog; us_level_update.prog;
    us_platform_displacement.prog; us_math_util.prog;
    us_surface_collision.prog; us_surface_load.prog;
    us_macro_special_objects.prog; us_ssl_script.prog;
    us_ssl_area1_macro.prog; us_ssl_area2_macro.prog;
    us_ssl_collision.prog ].

Definition jp_translation_units : list Clight.program :=
  [ jp_game_init.prog; jp_mario.prog; jp_mario_actions_airborne.prog;
    jp_mario_actions_automatic.prog; jp_mario_actions_cutscene.prog;
    jp_mario_actions_moving.prog;
    jp_mario_actions_object.prog; jp_mario_actions_stationary.prog;
    jp_mario_actions_submerged.prog;
    jp_mario_step.prog; jp_interaction.prog; jp_save_file.prog;
    jp_object_collision.prog; jp_object_list_processor.prog;
    jp_behavior_script.prog; jp_level_script.prog; jp_graph_node.prog;
    jp_spawn_object.prog; jp_object_helpers.prog; jp_debug.prog;
    jp_memory.prog; jp_mario_misc.prog; jp_obj_behaviors.prog;
    jp_obj_behaviors_2.prog; jp_behavior_actions.prog;
    jp_behavior_data.prog; jp_area.prog; jp_level_update.prog;
    jp_platform_displacement.prog; jp_math_util.prog;
    jp_surface_collision.prog; jp_surface_load.prog;
    jp_macro_special_objects.prog; jp_ssl_script.prog;
    jp_ssl_area1_macro.prog; jp_ssl_area2_macro.prog;
    jp_ssl_collision.prog ].

Theorem us_translation_unit_count :
  length us_translation_units = 37%nat.
Proof. reflexivity. Qed.

Theorem jp_translation_unit_count :
  length jp_translation_units = 37%nat.
Proof. reflexivity. Qed.

Definition target_translation_units (version : GameVersion) : list Clight.program :=
  match version with
  | VersionUS => us_translation_units
  | VersionJP => jp_translation_units
  end.

Definition target_main_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_game_init._main
  | VersionJP => jp_game_init._main
  end.

(* Interface certificate only: no iterated link construction is supplied in
   this project. *)
Record TargetLinkedProgram
    (version : GameVersion) (linked : Clight.program) : Prop := {
  target_links_every_translation_unit :
    Forall (fun unit => linkorder unit linked)
      (target_translation_units version);
  target_linked_main :
    Ctypes.prog_main linked = target_main_ident version
}.

(* These functions remain abstract until a concrete memory/trace projection
   and the obligations below are proved. *)
Record ClightObservationProjection := {
  projection_version : GameVersion;
  projection_program : Clight.program;
  projection_links_current_units :
    TargetLinkedProgram projection_version projection_program;
  project_state : Clight.state -> option GameState;
  project_inputs : ImportedClightRun -> list FrameInput;
  project_events : ImportedClightRun -> list FrameEvent;
  project_collision_observations :
    ImportedClightRun -> list CollisionObservation
}.

Definition RunUsesProjection
    (projection : ClightObservationProjection)
    (run : ImportedClightRun) : Prop :=
  run_program run = projection_program projection.

Record ClightFrameRefinementCertificate
    (projection : ClightObservationProjection)
    (run : ImportedClightRun) (initial : GameState) := {
  refined_final_state : GameState;
  refined_run_uses_projection : RunUsesProjection projection run;
  refined_start_matches :
    project_state projection (run_start run) = Some initial;
  refined_initial_version :
    state_version initial = projection_version projection;
  refined_final_matches :
    project_state projection (run_final run) = Some refined_final_state;
  refined_input_count :
    length (project_inputs projection run) =
    length (project_events projection run);
  refined_input_history :
    coherent_input_history (state_first_frame_previous_down_seed initial)
      (project_inputs projection run);
  refined_act3_collections_observed :
    forall star phase,
      In (EventCollectAct3 star phase) (project_events projection run) ->
      In {| observed_object := star; observed_phase := phase |}
        (project_collision_observations projection run);
  refined_trigger_consumptions_observed :
    forall trigger trigger_object phase,
      In (EventConsumeTrigger trigger trigger_object phase)
        (project_events projection run) ->
      In {| observed_object := trigger_object; observed_phase := phase |}
        (project_collision_observations projection run);
  refined_execution :
    CertifiedExecution initial (project_events projection run)
      refined_final_state
}.

Definition WholeProgramClightRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  forall run initial,
    RunUsesProjection projection run ->
    project_state projection (run_start run) = Some initial ->
    exists certificate :
      ClightFrameRefinementCertificate projection run initial, True.

(* The earlier project version required a run for every inhabitant of the
   handwritten [CleanPyramidEntry] record.  That was false in principle:
   ghost object epochs and, in particular, arbitrary JP raw-platform slots
   describe more abstract states than the pinned program can reach.  Keep the
   old surjectivity statement available as an audit target, but do not use it
   in the advertised Clight obligation. *)
Definition AbstractCleanEntrySurjectivityObligation
    (projection : ClightObservationProjection) : Prop :=
  forall initial,
    CleanPyramidEntry initial ->
    state_version initial = projection_version projection ->
    exists run,
      RunUsesProjection projection run /\
      project_state projection (run_start run) = Some initial.

(* Non-vacuity now asks only for one actual projected run at each selected
   entrance.  It does not claim that a fabricated abstract raw-pointer seed is
   source-reachable.  Proving source-backed JP platform capture for a specific
   run remains part of the first-target platform-displacement obligation. *)
Definition CleanEntryProjectionNonvacuityObligation
    (projection : ClightObservationProjection) : Prop :=
  forall entrance,
    exists run initial,
      RunUsesProjection projection run /\
      project_state projection (run_start run) = Some initial /\
      CleanPyramidEntry initial /\
      state_version initial = projection_version projection /\
      state_entrance initial = entrance.

Definition TargetClightRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  WholeProgramClightRefinementObligation projection /\
  CleanEntryProjectionNonvacuityObligation projection.

(* No linked program, memory projection, or certificate is supplied.  The
   generated-AST source-shape facts do not establish these obligations. *)
