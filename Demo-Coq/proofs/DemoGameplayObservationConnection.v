From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Globalenvs Integers Maps Memory Memdata Values.
From Demo.Proofs Require Import DemoExecutionHistory
  DemoInputOriginObservation DemoGameplayConsumptionObservation
  DemoControllerInputExecution DemoPlaybackAdvanceExecution.
Local Open Scope Z_scope.

(** This connects the two independently defined boundaries at a real generated
    camera read. It does not classify every gameplay read, authenticate a ROM,
    identify a loaded scene, or assert a permitted boot history. In particular,
    neither a title-fade label nor equality of level globals is a premise. *)
Definition demo_camera_pressed_site {prog} (history : demo_execution_history prog)
    us emission observation : Prop :=
  exists k e le,
    history_state history observation =
      State (demo_camera_update us) demo_camera_pressed_read k e le
        (origin_history_memory history observation) /\
    demo_gameplay_dynamic_context us k /\
    le ! C._t'65 = Some (Vptr (emission_controllers emission) Ptrofs.zero).

Lemma demo_origin_camera_read_connection :
  forall us prog (history : demo_execution_history prog) emission observation,
  (observation < history_length history)%nat ->
  genv_cenv (Clight.globalenv prog) = prog_comp_env (demo_camera_program us) ->
  demo_camera_pressed_site history us emission observation ->
  Mem.load Mint16unsigned (origin_history_memory history observation)
    (emission_controllers emission) 18 =
      Some (origin_field_value emission OriginButtonPressed) ->
  demo_gameplay_consumption_observation us prog history observation
    (emission_controllers emission) Ptrofs.zero C._buttonPressed
      (origin_field_value emission OriginButtonPressed).
Proof.
  intros us prog history emission observation Hbound Henv
    (k & e & le & Hstate & Hcontext & Hpointer) Hload.
  apply demo_history_read_is_consumption; [exact Hbound |].
  destruct (generated_camera_pressed_read_executes us (Clight.globalenv prog)
    k e le (origin_history_memory history observation)
    (emission_controllers emission)
    (controller_pressed_value
      (playback_next_buttons (emission_timer emission)
        (emission_physical_buttons emission) (emission_mask emission))
      (emission_previous_buttons emission))) as [after [Hread Hstep]].
  - exact Henv.
  - exact Hpointer.
  - exact Hload.
  - exact Hcontext.
  - rewrite Hstate. exact Hread.
Qed.

Theorem demo_positive_origin_reaches_actual_camera_read :
  forall us prog (history : demo_execution_history prog)
    selection backing emission observation,
  (observation < history_length history)%nat ->
  genv_cenv (Clight.globalenv prog) = prog_comp_env (demo_camera_program us) ->
  demo_camera_pressed_site history us emission observation ->
  demo_input_origin_at history us selection backing emission observation
    OriginButtonPressed ->
  demo_gameplay_consumption_observation us prog history observation
    (emission_controllers emission) Ptrofs.zero C._buttonPressed
      (origin_field_value emission OriginButtonPressed).
Proof.
  intros us prog history selection backing emission observation
    Hbound Henv Hsite Horigin.
  eapply demo_origin_camera_read_connection; try eassumption.
  exact (demo_input_origin_at_supplies_typed_gameplay_load
    prog history us selection backing emission observation OriginButtonPressed Horigin).
Qed.

Theorem demo_eof_origin_reaches_actual_camera_read :
  forall us prog (history : demo_execution_history prog)
    selection backing emission observation,
  (observation < history_length history)%nat ->
  genv_cenv (Clight.globalenv prog) = prog_comp_env (demo_camera_program us) ->
  demo_camera_pressed_site history us emission observation ->
  demo_eof_origin_at history us selection backing emission observation
    OriginButtonPressed ->
  demo_gameplay_consumption_observation us prog history observation
    (emission_controllers emission) Ptrofs.zero C._buttonPressed
      (origin_field_value emission OriginButtonPressed).
Proof.
  intros us prog history selection backing emission observation
    Hbound Henv Hsite Horigin.
  eapply demo_origin_camera_read_connection; try eassumption.
  exact (demo_eof_origin_at_supplies_typed_terminal_load
    prog history us selection backing emission observation OriginButtonPressed Horigin).
Qed.

Definition demo_origin_camera_connection_claim : Prop :=
  forall us prog (history : demo_execution_history prog)
    selection backing emission observation,
  (observation < history_length history)%nat ->
  genv_cenv (Clight.globalenv prog) = prog_comp_env (demo_camera_program us) ->
  demo_camera_pressed_site history us emission observation ->
  (demo_input_origin_at history us selection backing emission observation
      OriginButtonPressed \/
   demo_eof_origin_at history us selection backing emission observation
      OriginButtonPressed) ->
  demo_gameplay_consumption_observation us prog history observation
    (emission_controllers emission) Ptrofs.zero C._buttonPressed
      (origin_field_value emission OriginButtonPressed).

Theorem checked_origin_camera_connection_us_jp : demo_origin_camera_connection_claim.
Proof.
  intros us prog history selection backing emission observation
    Hbound Henv Hsite [Hpositive | Heof].
  - eapply demo_positive_origin_reaches_actual_camera_read; eassumption.
  - eapply demo_eof_origin_reaches_actual_camera_read; eassumption.
Qed.
