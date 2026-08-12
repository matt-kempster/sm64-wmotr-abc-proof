(** Data-bearing Clight chronologies for the observation projection.

    [ImportedClightRun] deliberately retains only a [Smallstep.star] proof.
    That is enough to certify reachability, but the proof lives in [Prop] and
    therefore cannot be eliminated to compute the [list FrameInput],
    [list FrameEvent], or collision-observation streams required by
    [ClightFrameRefinementCertificate].  In particular, a local Clight-step
    simulation cannot by itself synthesize those three lists from an
    [ImportedClightRun].

    This file supplies the missing compositional interface without changing
    the existing run type.  A chronology is an ordinary data-bearing list of
    frame chunks.  A projection-specific observation interface relates each
    concrete pair of Clight endpoints and trace to exactly one input/event/
    collision payload.  Its soundness fields require a real nonempty finite
    [Clight.step2] execution and a [CertifiedStep] between the projected
    endpoints; the relation may remain uninhabited until the concrete memory
    observer is constructed.  Every chunk carries evidence that its payload
    is accepted by that interface.  Connectivity then proves that the chunks
    form one run and that controller predecessor state is threaded between
    frames.

    The composition theorems below are admission-free.  They do not claim
    that the selected repaired US or cleaned JP program supplies such a
    chronology; the final obligations state exactly that construction. *)

From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes Events Globalenvs Integers Memory
  Smallstep Values.
From LessThanOneAPress.Proofs Require Import
  AreaTransitions CleanEntry EntryMemory GameTypes InputSemantics ClightRefinement
  JPZeroAReachability SelectedClightTarget.
From LessThanOneAPress.Generated Require Import
  us_game_init jp_game_init us_level_update jp_level_update us_mario jp_mario.

Import ListNotations.
Local Open Scope Z_scope.

(** Concrete controller cells used to authenticate each reported input.  A
    selected-program proof must resolve the controller symbol/pointer to this
    block and base; the observer cannot hard-code an all-zero input stream. *)
Record ClightFrameControllerBinding
    (projection : ClightObservationProjection) : Type := {
  frame_controller_block : block;
  frame_controller_base : Z;
  frame_controller_identifier : ident;
  frame_player1_pointer_cell_block : block;
  frame_player1_pointer_identifier : ident;
  frame_mario_state_block : block;
  frame_mario_state_base : Z;
  frame_mario_state_identifier : ident;
  frame_controller_poll_function_block : block;
  frame_mario_input_function_block : block;
  frame_controller_symbol_resolved :
    Genv.find_symbol (Clight.globalenv (projection_program projection))
      frame_controller_identifier = Some frame_controller_block;
  frame_player1_pointer_symbol_resolved :
    Genv.find_symbol (Clight.globalenv (projection_program projection))
      frame_player1_pointer_identifier =
      Some frame_player1_pointer_cell_block;
  frame_mario_state_symbol_resolved :
    Genv.find_symbol (Clight.globalenv (projection_program projection))
      frame_mario_state_identifier = Some frame_mario_state_block;
  frame_controller_poll_function_resolved :
    match projection_version projection with
    | VersionUS =>
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          us_game_init._read_controller_inputs =
          Some frame_controller_poll_function_block /\
        Genv.find_funct_ptr
          (Clight.globalenv (projection_program projection))
          frame_controller_poll_function_block =
          Some (Ctypes.Internal us_game_init.f_read_controller_inputs)
    | VersionJP =>
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          jp_game_init._read_controller_inputs =
          Some frame_controller_poll_function_block /\
        Genv.find_funct_ptr
          (Clight.globalenv (projection_program projection))
          frame_controller_poll_function_block =
          Some (Ctypes.Internal jp_game_init.f_read_controller_inputs)
    end;
  frame_mario_input_function_resolved :
    match projection_version projection with
    | VersionUS =>
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          us_mario._update_mario_button_inputs =
          Some frame_mario_input_function_block /\
        Genv.find_funct_ptr
          (Clight.globalenv (projection_program projection))
          frame_mario_input_function_block =
          Some (Ctypes.Internal us_mario.f_update_mario_button_inputs)
    | VersionJP =>
        Genv.find_symbol (Clight.globalenv (projection_program projection))
          jp_mario._update_mario_button_inputs =
          Some frame_mario_input_function_block /\
        Genv.find_funct_ptr
          (Clight.globalenv (projection_program projection))
          frame_mario_input_function_block =
          Some (Ctypes.Internal jp_mario.f_update_mario_button_inputs)
    end
}.

(** The values exported as a [FrameInput] are sampled at the completed return
    of [read_controller_inputs], not merely at arbitrary frame endpoints.
    Repeating the two controller loads and the two pointer loads at
    [clight_after] is an explicit preservation/tether obligation for any
    silent suffix between the poll return and the reported endpoint.  The
    MarioState.controller loads authenticate that the state consumed by the
    game points at gControllers[0], rather than merely observing an unrelated
    controller-shaped block. *)
Definition ClightFrameInputSound
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (poll_entry poll_return mario_input_call clight_after : Clight.state)
    (input : FrameInput) : Prop :=
  load_at Mint16unsigned (clight_state_memory poll_entry)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_previous_down input)) /\
  load_at Mint16unsigned (clight_state_memory poll_return)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_current_down input)) /\
  load_at Mint16unsigned (clight_state_memory poll_return)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed
      (frame_current_down input) (frame_previous_down input))) /\
  load_at Mint16unsigned (clight_state_memory mario_input_call)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_current_down input)) /\
  load_at Mint16unsigned (clight_state_memory mario_input_call)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed
      (frame_current_down input) (frame_previous_down input))) /\
  load_at Mint16unsigned (clight_state_memory clight_after)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_current_down input)) /\
  load_at Mint16unsigned (clight_state_memory clight_after)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed
      (frame_current_down input) (frame_previous_down input))) /\
  Mem.load Mptr (clight_state_memory poll_entry)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  Mem.load Mptr (clight_state_memory poll_return)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  Mem.load Mptr (clight_state_memory mario_input_call)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  Mem.load Mptr (clight_state_memory clight_after)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  load_at Mptr (clight_state_memory poll_return)
      (frame_mario_state_block _ binding) (frame_mario_state_base _ binding)
      mario_state_controller_pointer_offset =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  load_at Mptr (clight_state_memory mario_input_call)
      (frame_mario_state_block _ binding) (frame_mario_state_base _ binding)
      mario_state_controller_pointer_offset =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  load_at Mptr (clight_state_memory clight_after)
      (frame_mario_state_block _ binding) (frame_mario_state_base _ binding)
      mario_state_controller_pointer_offset =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero).

(** Paused, transition, and other administrative frames still complete the
    controller poll, but may skip Mario's button-consumer routine.  Their
    input is authenticated at the completed poll and preserved to the frame
    endpoint; no fictitious Mario consumption is asserted. *)
Definition ClightAdministrativeFrameInputSound
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (poll_entry poll_return clight_after : Clight.state)
    (input : FrameInput) : Prop :=
  load_at Mint16unsigned (clight_state_memory poll_entry)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_previous_down input)) /\
  load_at Mint16unsigned (clight_state_memory poll_return)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_current_down input)) /\
  load_at Mint16unsigned (clight_state_memory poll_return)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed
      (frame_current_down input) (frame_previous_down input))) /\
  load_at Mint16unsigned (clight_state_memory clight_after)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (frame_current_down input)) /\
  load_at Mint16unsigned (clight_state_memory clight_after)
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed
      (frame_current_down input) (frame_previous_down input))) /\
  Mem.load Mptr (clight_state_memory poll_entry)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  Mem.load Mptr (clight_state_memory poll_return)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  Mem.load Mptr (clight_state_memory clight_after)
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero).

Definition selected_controller_array_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_game_init._gControllers
  | VersionJP => jp_game_init._gControllers
  end.

Definition selected_player1_controller_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_game_init._gPlayer1Controller
  | VersionJP => jp_game_init._gPlayer1Controller
  end.

Definition selected_mario_states_ident (version : GameVersion) : ident :=
  match version with
  | VersionUS => us_level_update._gMarioStates
  | VersionJP => jp_level_update._gMarioStates
  end.

Definition SelectedControllerPollCall
    (version : GameVersion) (arguments : list val)
    (continuation : Clight.cont) (memory : Mem.mem)
    (state : Clight.state) : Prop :=
  match version with
  | VersionUS =>
      arguments = [] /\
      state = Callstate (Ctypes.Internal us_game_init.f_read_controller_inputs)
        [] continuation memory
  | VersionJP =>
      arguments = [] /\
      state = Callstate (Ctypes.Internal jp_game_init.f_read_controller_inputs)
        [] continuation memory
  end.

Definition SelectedControllerPollEntry
    (version : GameVersion) (state : Clight.state) : Prop :=
  SelectedFrameBoundaryState version state.

Definition SelectedMarioInputConsumptionCallExact
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (continuation : Clight.cont) (memory : Mem.mem)
    (state : Clight.state) : Prop :=
  match projection_version projection with
  | VersionUS =>
      state = Callstate (Ctypes.Internal us_mario.f_update_mario_button_inputs)
        [Vptr (frame_mario_state_block _ binding)
          (Ptrofs.repr (frame_mario_state_base _ binding))]
        continuation memory
  | VersionJP =>
      state = Callstate (Ctypes.Internal jp_mario.f_update_mario_button_inputs)
        [Vptr (frame_mario_state_block _ binding)
          (Ptrofs.repr (frame_mario_state_base _ binding))]
        continuation memory
  end.

Definition SelectedMarioInputConsumptionCall
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (state : Clight.state) : Prop :=
  exists continuation memory,
    SelectedMarioInputConsumptionCallExact projection binding
      continuation memory state.

Record ConcreteClightStep (program : Clight.program) : Type := {
  concrete_step_before : Clight.state;
  concrete_step_trace : Events.trace;
  concrete_step_after : Clight.state;
  concrete_step_executes :
    Clight.step2 (Clight.globalenv program)
      concrete_step_before concrete_step_trace concrete_step_after
}.

Arguments concrete_step_before {program} _.
Arguments concrete_step_trace {program} _.
Arguments concrete_step_after {program} _.

Inductive ConcreteClightStepsConnected (program : Clight.program) :
    list (ConcreteClightStep program) -> Clight.state -> Clight.state -> Prop :=
| concrete_steps_connected_nil :
    forall state, ConcreteClightStepsConnected program [] state state
| concrete_steps_connected_cons :
    forall step rest final,
      ConcreteClightStepsConnected program rest
        (concrete_step_after step) final ->
      ConcreteClightStepsConnected program (step :: rest)
        (concrete_step_before step) final.

Definition concrete_clight_steps_trace {program}
    (steps : list (ConcreteClightStep program)) : Events.trace :=
  concat (map concrete_step_trace steps).

Lemma concrete_clight_steps_connected_star :
  forall program steps before after,
    ConcreteClightStepsConnected program steps before after ->
    @Smallstep.star _ _ Clight.step2 (Clight.globalenv program)
      before (concrete_clight_steps_trace steps) after.
Proof.
  intros program steps before after Hconnected.
  induction Hconnected; cbn.
  - constructor.
  - eapply Smallstep.star_step.
    + exact (concrete_step_executes _ step).
    + exact IHHconnected.
    + reflexivity.
Qed.

(** This is the exact frame segmentation boundary still required from the
    live scheduler.  The distinguished call is followed all the way to the
    matching [Returnstate] with the same continuation.  Thus the memory named
    [poll_return] really is the completed poll memory; merely finding the
    first step out of a [Callstate] is no longer enough.  It then reaches the
    exact [update_mario_button_inputs] call on the bound MarioState, follows
    that call to its matching return, and thereby covers the internal loads
    that consume the input.  The surrounding lists contain neither a second
    poll nor a second input-consumption call. *)
Definition ClightControllerPollBoundary
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (before : Clight.state) (frame_trace : Events.trace)
    (after poll_entry poll_return mario_input_call mario_input_return :
      Clight.state) : Prop :=
  exists (steps_before : list (ConcreteClightStep
      (projection_program projection))) poll_step steps_in_poll
      steps_to_consumer consumer_step steps_in_consumer steps_after
      arguments continuation memory_before return_value memory_after
      consumer_continuation consumer_memory_before consumer_return_value
      consumer_memory_after,
    ConcreteClightStepsConnected (projection_program projection)
      steps_before before poll_entry /\
    concrete_step_before poll_step = poll_entry /\
    SelectedControllerPollCall (projection_version projection)
      arguments continuation memory_before poll_entry /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_in_poll (concrete_step_after poll_step) poll_return /\
    poll_return = Returnstate return_value continuation memory_after /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_to_consumer poll_return mario_input_call /\
    SelectedMarioInputConsumptionCallExact projection binding
      consumer_continuation consumer_memory_before mario_input_call /\
    concrete_step_before consumer_step = mario_input_call /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_in_consumer (concrete_step_after consumer_step) mario_input_return /\
    mario_input_return = Returnstate consumer_return_value
      consumer_continuation consumer_memory_after /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_after mario_input_return after /\
    concrete_clight_steps_trace
      (steps_before ++ [poll_step] ++ steps_in_poll ++ steps_to_consumer ++
        [consumer_step] ++ steps_in_consumer ++ steps_after) =
        frame_trace /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_before /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_in_poll /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_to_consumer /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_in_consumer /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_after /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_before /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_in_poll /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_to_consumer /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_in_consumer /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_after /\
    ~ SelectedControllerPollEntry (projection_version projection) poll_return /\
    ~ SelectedMarioInputConsumptionCall projection binding poll_entry /\
    ~ SelectedMarioInputConsumptionCall projection binding poll_return /\
    ~ SelectedMarioInputConsumptionCall projection binding mario_input_return /\
    ~ SelectedMarioInputConsumptionCall projection binding after.

(** Exact one-poll frame boundary for administrative frames which skip
    [update_mario_button_inputs].  The completed poll is still followed to its
    matching return, while the entire chunk is certified to contain no Mario
    button-consumer call. *)
Definition ClightAdministrativePollBoundary
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (before : Clight.state) (frame_trace : Events.trace)
    (after poll_entry poll_return : Clight.state) : Prop :=
  exists (steps_before : list (ConcreteClightStep
      (projection_program projection))) poll_step steps_in_poll steps_after
      arguments continuation memory_before return_value memory_after,
    ConcreteClightStepsConnected (projection_program projection)
      steps_before before poll_entry /\
    concrete_step_before poll_step = poll_entry /\
    SelectedControllerPollCall (projection_version projection)
      arguments continuation memory_before poll_entry /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_in_poll (concrete_step_after poll_step) poll_return /\
    poll_return = Returnstate return_value continuation memory_after /\
    ConcreteClightStepsConnected (projection_program projection)
      steps_after poll_return after /\
    concrete_clight_steps_trace
      (steps_before ++ [poll_step] ++ steps_in_poll ++ steps_after) =
        frame_trace /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_before /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_in_poll /\
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) steps_after /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_before /\
    ~ SelectedMarioInputConsumptionCall projection binding poll_entry /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_in_poll /\
    ~ SelectedMarioInputConsumptionCall projection binding poll_return /\
    Forall (fun step =>
      ~ SelectedMarioInputConsumptionCall projection binding
          (concrete_step_before step)) steps_after /\
    ~ SelectedMarioInputConsumptionCall projection binding after /\
    ~ SelectedControllerPollEntry (projection_version projection) poll_return.

Inductive ClightAuthenticatedFrameInput
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection) :
    Clight.state -> Events.trace -> Clight.state ->
    FrameInput -> FrameEvent -> Prop :=
| authenticated_gameplay_frame :
    forall before frame_trace after input event
      poll_entry poll_return mario_input_call mario_input_return,
      ClightControllerPollBoundary projection binding before frame_trace after
        poll_entry poll_return mario_input_call mario_input_return ->
      ClightFrameInputSound projection binding poll_entry poll_return
        mario_input_call after input ->
      ClightAuthenticatedFrameInput projection binding
        before frame_trace after input event
| authenticated_administrative_frame :
    forall before frame_trace after input event poll_entry poll_return,
      ClightAdministrativePollBoundary projection binding
        before frame_trace after poll_entry poll_return ->
      ClightAdministrativeFrameInputSound projection binding
        poll_entry poll_return after input ->
      ClightAuthenticatedFrameInput projection binding
        before frame_trace after input event.

Definition FrameInputMatchesAbstractEndpoints
    (abstract_before abstract_after : GameState) (input : FrameInput) : Prop :=
  state_entry_button_down abstract_before = frame_previous_down input /\
  state_entry_button_down abstract_after = frame_current_down input /\
  state_entry_button_pressed abstract_after =
    edge_pressed (frame_current_down input) (frame_previous_down input).

(** Merely storing an arbitrary [FrameInput], [FrameEvent], and collision
    list beside a Clight step does not show that those labels came from the
    concrete execution.  This interface is the deliberately open semantic
    boundary for a projection-specific frame observer.  The relation is
    functional for fixed concrete endpoints and trace, admits only nonempty
    real executions, and must refine the projected endpoints to the reported
    event.  Requiring [Smallstep.plus] rules out zero-step phantom frames.
    Its collision-completeness clauses are likewise properties of the
    concrete observation relation, not free fields of a chronology.

    No relation is constructed in this file.  In particular, the empty
    relation satisfies the interface but cannot supply a nonempty chronology;
    a selected-program proof must define the actual memory/trace observer and
    prove these fields. *)
Record ClightFrameObservationInterface
    (projection : ClightObservationProjection) : Type := {
  clight_frame_controller_binding :
    ClightFrameControllerBinding projection;
  clight_frame_controller_identifier_exact :
    frame_controller_identifier _ clight_frame_controller_binding =
      selected_controller_array_ident (projection_version projection);
  clight_frame_controller_base_exact :
    frame_controller_base _ clight_frame_controller_binding = 0;
  clight_frame_player1_pointer_identifier_exact :
    frame_player1_pointer_identifier _ clight_frame_controller_binding =
      selected_player1_controller_ident (projection_version projection);
  clight_frame_mario_state_identifier_exact :
    frame_mario_state_identifier _ clight_frame_controller_binding =
      selected_mario_states_ident (projection_version projection);
  clight_frame_mario_state_base_exact :
    frame_mario_state_base _ clight_frame_controller_binding = 0;
  clight_frame_observes :
    Clight.state -> Events.trace -> Clight.state ->
    FrameInput -> FrameEvent -> list CollisionObservation -> Prop;
  clight_frame_observation_functional :
    forall clight_before clight_trace clight_after
      input1 event1 collisions1 input2 event2 collisions2,
      clight_frame_observes clight_before clight_trace clight_after
        input1 event1 collisions1 ->
      clight_frame_observes clight_before clight_trace clight_after
        input2 event2 collisions2 ->
      input1 = input2 /\ event1 = event2 /\ collisions1 = collisions2;
  clight_frame_observation_poll_input_sound :
    forall clight_before clight_trace clight_after input event collisions,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      ClightAuthenticatedFrameInput projection
        clight_frame_controller_binding clight_before clight_trace
        clight_after input event;
  clight_frame_observation_executes :
    forall clight_before clight_trace clight_after input event collisions,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      @Smallstep.plus _ _ Clight.step2
        (Clight.globalenv (projection_program projection))
        clight_before clight_trace clight_after;
  clight_frame_observation_refines :
    forall clight_before clight_trace clight_after input event collisions
      abstract_before abstract_after,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      project_state projection clight_before = Some abstract_before ->
      project_state projection clight_after = Some abstract_after ->
      CertifiedStep abstract_before event abstract_after;
  clight_frame_observation_endpoint_input_sound :
    forall clight_before clight_trace clight_after input event collisions
      abstract_before abstract_after,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      project_state projection clight_before = Some abstract_before ->
      project_state projection clight_after = Some abstract_after ->
      FrameInputMatchesAbstractEndpoints abstract_before abstract_after input;
  clight_frame_observation_act3_complete :
    forall clight_before clight_trace clight_after input event collisions
      star phase,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      event = EventCollectAct3 star phase ->
      In {| observed_object := star; observed_phase := phase |} collisions;
  clight_frame_observation_trigger_complete :
    forall clight_before clight_trace clight_after input event collisions
      trigger trigger_object phase,
      clight_frame_observes clight_before clight_trace clight_after
        input event collisions ->
      event = EventConsumeTrigger trigger trigger_object phase ->
      In {| observed_object := trigger_object; observed_phase := phase |}
        collisions
}.

Arguments clight_frame_observes {projection} _ _ _ _ _ _ _.
Arguments clight_frame_observation_functional
  {projection} _ _ _ _ _ _ _ _ _ _.
Arguments clight_frame_observation_executes
  {projection} _ _ _ _ _ _ _.
Arguments clight_frame_observation_refines
  {projection} _ _ _ _ _ _ _ _ _.
Arguments clight_frame_observation_act3_complete
  {projection} _ _ _ _ _ _ _ _ _.
Arguments clight_frame_observation_trigger_complete
  {projection} _ _ _ _ _ _ _ _ _ _.

Definition RunStartBoundaryInputSound
    (projection : ClightObservationProjection)
    (binding : ClightFrameControllerBinding projection)
    (run : ImportedClightRun) (initial : GameState) : Prop :=
  load_at Mint16unsigned (clight_state_memory (run_start run))
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_down_offset =
    Some (Vint (state_entry_button_down initial)) /\
  load_at Mint16unsigned (clight_state_memory (run_start run))
      (frame_controller_block _ binding) (frame_controller_base _ binding)
      controller_button_pressed_offset =
    Some (Vint (edge_pressed (state_entry_button_down initial)
      (state_first_frame_previous_down_seed initial))) /\
  state_entry_button_pressed initial =
    edge_pressed (state_entry_button_down initial)
      (state_first_frame_previous_down_seed initial) /\
  Mem.load Mptr (clight_state_memory (run_start run))
      (frame_player1_pointer_cell_block _ binding) 0 =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero) /\
  load_at Mptr (clight_state_memory (run_start run))
      (frame_mario_state_block _ binding) (frame_mario_state_base _ binding)
      mario_state_controller_pointer_offset =
    Some (Vptr (frame_controller_block _ binding) Ptrofs.zero).

(** The boundary sample is not accepted merely because its endpoint bytes
    have the expected shape.  It must be the output of a completed, matching
    [read_controller_inputs] call reached from the selected runtime task.
    [ClightAuthenticatedFrameInput] admits either the gameplay route through
    the exact Mario button consumer or the explicitly poll-only administrative
    route; both forbid a second executed poll and preserve the sampled values
    to [run_start]. *)
Definition RunStartBoundaryPollAuthenticated
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection)
    (run : ImportedClightRun) (initial : GameState) : Prop :=
  exists task_start task_prefix_trace poll_entry poll_to_start_trace
      boundary_event,
    SelectedRuntimeTaskStart
      (projection_version projection) (projection_program projection)
      task_start /\
    @Smallstep.plus _ _ Clight.step2
      (Clight.globalenv (projection_program projection))
      task_start task_prefix_trace poll_entry /\
    ClightAuthenticatedFrameInput projection
      (clight_frame_controller_binding projection observer)
      poll_entry poll_to_start_trace (run_start run)
      (run_start_boundary_input initial) boundary_event.

(** One projected game frame may contain many Clight small steps.  Keeping
    the concrete trace and endpoints as data avoids attempting an illegal
    elimination of [Smallstep.star : Prop] into an observation list. *)
Record RefinedClightFrame
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) : Type := {
  refined_frame_clight_before : Clight.state;
  refined_frame_clight_after : Clight.state;
  refined_frame_clight_trace : Events.trace;

  refined_frame_abstract_before : GameState;
  refined_frame_abstract_after : GameState;
  refined_frame_before_matches :
    project_state projection refined_frame_clight_before =
      Some refined_frame_abstract_before;
  refined_frame_after_matches :
    project_state projection refined_frame_clight_after =
      Some refined_frame_abstract_after;

  refined_frame_input : FrameInput;
  refined_frame_event : FrameEvent;
  refined_frame_collision_observations : list CollisionObservation;
  refined_frame_observation_sound :
    clight_frame_observes observer
      refined_frame_clight_before refined_frame_clight_trace
      refined_frame_clight_after refined_frame_input refined_frame_event
      refined_frame_collision_observations
}.

Arguments refined_frame_clight_before {projection observer} _.
Arguments refined_frame_clight_after {projection observer} _.
Arguments refined_frame_clight_trace {projection observer} _.
Arguments refined_frame_abstract_before {projection observer} _.
Arguments refined_frame_abstract_after {projection observer} _.
Arguments refined_frame_before_matches {projection observer} _.
Arguments refined_frame_after_matches {projection observer} _.
Arguments refined_frame_input {projection observer} _.
Arguments refined_frame_event {projection observer} _.
Arguments refined_frame_collision_observations {projection observer} _.
Arguments refined_frame_observation_sound {projection observer} _.

Lemma refined_frame_clight_steps :
  forall projection observer
    (frame : RefinedClightFrame projection observer),
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (projection_program projection))
      (refined_frame_clight_before frame)
      (refined_frame_clight_trace frame)
      (refined_frame_clight_after frame).
Proof.
  intros projection observer frame.
  apply Smallstep.plus_star.
  eapply clight_frame_observation_executes.
  exact (refined_frame_observation_sound frame).
Qed.

Lemma refined_frame_step :
  forall projection observer
    (frame : RefinedClightFrame projection observer),
    CertifiedStep (refined_frame_abstract_before frame)
      (refined_frame_event frame) (refined_frame_abstract_after frame).
Proof.
  intros projection observer frame.
  eapply clight_frame_observation_refines.
  - exact (refined_frame_observation_sound frame).
  - exact (refined_frame_before_matches frame).
  - exact (refined_frame_after_matches frame).
Qed.

Lemma refined_frame_act3_observed :
  forall projection observer
    (frame : RefinedClightFrame projection observer) star phase,
    refined_frame_event frame = EventCollectAct3 star phase ->
    In {| observed_object := star; observed_phase := phase |}
      (refined_frame_collision_observations frame).
Proof.
  intros projection observer frame star phase Hevent.
  eapply clight_frame_observation_act3_complete.
  - exact (refined_frame_observation_sound frame).
  - exact Hevent.
Qed.

Lemma refined_frame_trigger_observed :
  forall projection observer
    (frame : RefinedClightFrame projection observer)
    trigger trigger_object phase,
    refined_frame_event frame =
      EventConsumeTrigger trigger trigger_object phase ->
    In {| observed_object := trigger_object; observed_phase := phase |}
      (refined_frame_collision_observations frame).
Proof.
  intros projection observer frame trigger trigger_object phase Hevent.
  eapply clight_frame_observation_trigger_complete.
  - exact (refined_frame_observation_sound frame).
  - exact Hevent.
Qed.

Arguments refined_frame_clight_steps {projection observer} _.
Arguments refined_frame_step {projection observer} _.
Arguments refined_frame_act3_observed
  {projection observer} _ _ _ _.
Arguments refined_frame_trigger_observed
  {projection observer} _ _ _ _ _.

(** A finite Clight run need not begin or end exactly on a controller poll,
    and a nonempty prefix/suffix can contain no poll at all.  Such execution
    is represented as data, but emits no [FrameInput], [FrameEvent], or
    collision observation.  Requiring both endpoint projections to be the
    same abstract state is the stuttering condition needed for sound
    event-free composition. *)
Record SilentClightChunk
    (projection : ClightObservationProjection) : Type := {
  silent_chunk_clight_before : Clight.state;
  silent_chunk_clight_after : Clight.state;
  silent_chunk_clight_trace : Events.trace;
  silent_chunk_steps : list (ConcreteClightStep
    (projection_program projection));
  silent_chunk_abstract_state : GameState;
  silent_chunk_steps_connected :
    ConcreteClightStepsConnected (projection_program projection)
      silent_chunk_steps silent_chunk_clight_before silent_chunk_clight_after;
  silent_chunk_trace_exact :
    concrete_clight_steps_trace silent_chunk_steps = silent_chunk_clight_trace;
  silent_chunk_has_no_poll_entry :
    Forall (fun step =>
      ~ SelectedControllerPollEntry (projection_version projection)
          (concrete_step_before step)) silent_chunk_steps;
  silent_chunk_before_matches :
    project_state projection silent_chunk_clight_before =
      Some silent_chunk_abstract_state;
  silent_chunk_after_matches :
    project_state projection silent_chunk_clight_after =
      Some silent_chunk_abstract_state
}.

Arguments silent_chunk_clight_before {projection} _.
Arguments silent_chunk_clight_after {projection} _.
Arguments silent_chunk_clight_trace {projection} _.
Arguments silent_chunk_steps {projection} _.
Arguments silent_chunk_abstract_state {projection} _.
Arguments silent_chunk_before_matches {projection} _.
Arguments silent_chunk_after_matches {projection} _.

Lemma silent_chunk_clight_steps :
  forall projection (silent : SilentClightChunk projection),
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (projection_program projection))
      (silent_chunk_clight_before silent)
      (silent_chunk_clight_trace silent)
      (silent_chunk_clight_after silent).
Proof.
  intros projection silent.
  pose proof (concrete_clight_steps_connected_star
    (projection_program projection) (silent_chunk_steps silent)
    (silent_chunk_clight_before silent) (silent_chunk_clight_after silent)
    (silent_chunk_steps_connected projection silent)) as Hsteps.
  now rewrite (silent_chunk_trace_exact projection silent) in Hsteps.
Qed.

Inductive RefinedClightChronologyChunk
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) : Type :=
| chronology_observed_frame :
    RefinedClightFrame projection observer ->
    RefinedClightChronologyChunk projection observer
| chronology_silent_chunk :
    SilentClightChunk projection ->
    RefinedClightChronologyChunk projection observer.

Arguments chronology_observed_frame {projection observer} _.
Arguments chronology_silent_chunk {projection observer} _.

Definition RefinedClightFrameChronology
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) : Type :=
  list (RefinedClightChronologyChunk projection observer).

Fixpoint refined_chronology_inputs
    {projection observer}
    (chunks : RefinedClightFrameChronology projection observer) :
    list FrameInput :=
  match chunks with
  | [] => []
  | chronology_observed_frame frame :: rest =>
      refined_frame_input frame :: refined_chronology_inputs rest
  | chronology_silent_chunk _ :: rest => refined_chronology_inputs rest
  end.

Fixpoint refined_chronology_events
    {projection observer}
    (chunks : RefinedClightFrameChronology projection observer) :
    list FrameEvent :=
  match chunks with
  | [] => []
  | chronology_observed_frame frame :: rest =>
      refined_frame_event frame :: refined_chronology_events rest
  | chronology_silent_chunk _ :: rest => refined_chronology_events rest
  end.

Fixpoint refined_chronology_collision_observations
    {projection observer}
    (chunks : RefinedClightFrameChronology projection observer) :
    list CollisionObservation :=
  match chunks with
  | [] => []
  | chronology_observed_frame frame :: rest =>
      refined_frame_collision_observations frame ++
        refined_chronology_collision_observations rest
  | chronology_silent_chunk _ :: rest =>
      refined_chronology_collision_observations rest
  end.

Fixpoint refined_chronology_clight_trace
    {projection observer}
    (chunks : RefinedClightFrameChronology projection observer) :
    Events.trace :=
  match chunks with
  | [] => E0
  | chronology_observed_frame frame :: rest =>
      refined_frame_clight_trace frame ++
        refined_chronology_clight_trace rest
  | chronology_silent_chunk silent :: rest =>
      silent_chunk_clight_trace silent ++
        refined_chronology_clight_trace rest
  end.

(** Connectivity is separate from the data list so the observation streams
    remain computational.  Its indices enforce both concrete/abstract
    endpoint chaining and controller-history chaining. *)
Inductive RefinedFrameChronologyConnected
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) :
    RefinedClightFrameChronology projection observer ->
    Clight.state -> GameState -> Int.int ->
    Clight.state -> GameState -> Prop :=
| refined_chronology_connected_nil :
    forall state abstract_state expected_previous,
      RefinedFrameChronologyConnected projection observer []
        state abstract_state expected_previous state abstract_state
| refined_chronology_connected_cons :
    forall frame rest clight_start abstract_start expected_previous
      clight_final abstract_final,
      refined_frame_clight_before frame = clight_start ->
      refined_frame_abstract_before frame = abstract_start ->
      frame_previous_down (refined_frame_input frame) = expected_previous ->
      RefinedFrameChronologyConnected projection observer rest
        (refined_frame_clight_after frame)
        (refined_frame_abstract_after frame)
        (frame_current_down (refined_frame_input frame))
        clight_final abstract_final ->
      RefinedFrameChronologyConnected projection observer
        (chronology_observed_frame frame :: rest)
        clight_start abstract_start expected_previous
        clight_final abstract_final
| refined_chronology_connected_silent :
    forall silent rest expected_previous clight_final abstract_final,
      RefinedFrameChronologyConnected projection observer rest
        (silent_chunk_clight_after silent)
        (silent_chunk_abstract_state silent) expected_previous
        clight_final abstract_final ->
      RefinedFrameChronologyConnected projection observer
        (chronology_silent_chunk silent :: rest)
        (silent_chunk_clight_before silent)
        (silent_chunk_abstract_state silent) expected_previous
        clight_final abstract_final.

Lemma refined_chronology_input_event_count :
  forall projection observer
    (frames : RefinedClightFrameChronology projection observer),
    length (refined_chronology_inputs frames) =
    length (refined_chronology_events frames).
Proof.
  intros projection observer chunks.
  induction chunks as [| chunk rest IH]; cbn; [reflexivity |].
  destruct chunk; cbn; [now rewrite IH | exact IH].
Qed.

Lemma refined_chronology_has_coherent_inputs :
  forall projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final,
    RefinedFrameChronologyConnected projection observer frames
      clight_start abstract_start expected_previous
      clight_final abstract_final ->
    coherent_input_history expected_previous
      (refined_chronology_inputs frames).
Proof.
  intros projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final Hconnected.
  induction Hconnected; cbn.
  - exact I.
  - split; assumption.
  - exact IHHconnected.
Qed.

Lemma refined_chronology_is_clight_star :
  forall projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final,
    RefinedFrameChronologyConnected projection observer frames
      clight_start abstract_start expected_previous
      clight_final abstract_final ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (projection_program projection))
      clight_start (refined_chronology_clight_trace frames) clight_final.
Proof.
  intros projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final Hconnected.
  induction Hconnected; cbn.
  - constructor.
  - subst clight_start abstract_start.
    eapply Smallstep.star_trans.
    + exact (refined_frame_clight_steps frame).
    + exact IHHconnected.
    + reflexivity.
  - eapply Smallstep.star_trans.
    + exact (silent_chunk_clight_steps projection silent).
    + exact IHHconnected.
    + reflexivity.
Qed.

Lemma refined_chronology_is_certified_execution :
  forall projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final,
    RefinedFrameChronologyConnected projection observer frames
      clight_start abstract_start expected_previous
      clight_final abstract_final ->
    CertifiedExecution abstract_start
      (refined_chronology_events frames) abstract_final.
Proof.
  intros projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final Hconnected.
  induction Hconnected; cbn.
  - constructor.
  - subst clight_start abstract_start.
    econstructor.
    + exact (refined_frame_step frame).
    + exact IHHconnected.
  - exact IHHconnected.
Qed.

Lemma refined_chronology_final_matches :
  forall projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final,
    RefinedFrameChronologyConnected projection observer frames
      clight_start abstract_start expected_previous
      clight_final abstract_final ->
    project_state projection clight_start = Some abstract_start ->
    project_state projection clight_final = Some abstract_final.
Proof.
  intros projection observer frames clight_start abstract_start
    expected_previous clight_final abstract_final Hconnected.
  induction Hconnected; intros Hstart.
  - exact Hstart.
  - eapply IHHconnected.
    exact (refined_frame_after_matches frame).
  - eapply IHHconnected.
    exact (silent_chunk_after_matches silent).
Qed.

Lemma refined_chronology_act3_observations_complete :
  forall projection observer
    (frames : RefinedClightFrameChronology projection observer) star phase,
    In (EventCollectAct3 star phase) (refined_chronology_events frames) ->
    In {| observed_object := star; observed_phase := phase |}
      (refined_chronology_collision_observations frames).
Proof.
  intros projection observer chunks.
  induction chunks as [| chunk rest IH]; intros star phase Hin; cbn in *.
  - contradiction.
  - destruct chunk as [frame | silent]; cbn in *.
    + destruct Hin as [Hevent | Hin].
      * apply in_or_app. left.
        eapply refined_frame_act3_observed. exact Hevent.
      * apply in_or_app. right.
        now apply (IH star phase).
    + now apply (IH star phase).
Qed.

Lemma refined_chronology_trigger_observations_complete :
  forall projection observer
    (frames : RefinedClightFrameChronology projection observer)
    trigger trigger_object phase,
    In (EventConsumeTrigger trigger trigger_object phase)
      (refined_chronology_events frames) ->
    In {| observed_object := trigger_object; observed_phase := phase |}
      (refined_chronology_collision_observations frames).
Proof.
  intros projection observer chunks.
  induction chunks as [| chunk rest IH];
    intros trigger trigger_object phase Hin; cbn in *.
  - contradiction.
  - destruct chunk as [frame | silent]; cbn in *.
    + destruct Hin as [Hevent | Hin].
      * apply in_or_app. left.
        eapply refined_frame_trigger_observed. exact Hevent.
      * apply in_or_app. right.
        now apply (IH trigger trigger_object phase).
    + now apply (IH trigger trigger_object phase).
Qed.

(** This record ties a data chronology to one existing
    [ImportedClightRun].  The exact list equalities are deliberately visible:
    they prevent a proof about one chronology from certifying unrelated
    projection functions. *)
Record ChronologizedRunRefinement
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection)
    (run : ImportedClightRun)
    (initial : GameState) : Type := {
  chronologized_final_state : GameState;
  chronologized_frames :
    RefinedClightFrameChronology projection observer;
  chronologized_run_uses_projection : RunUsesProjection projection run;
  chronologized_start_matches :
    project_state projection (run_start run) = Some initial;
  chronologized_initial_version :
    state_version initial = projection_version projection;
  chronologized_boundary_input_sound :
    RunStartBoundaryInputSound projection
      (clight_frame_controller_binding projection observer) run initial;
  chronologized_boundary_poll_authenticated :
    RunStartBoundaryPollAuthenticated projection observer run initial;
  chronologized_connected :
    RefinedFrameChronologyConnected projection observer
      chronologized_frames (run_start run) initial
      (state_entry_button_down initial)
      (run_final run) chronologized_final_state;
  chronologized_trace_exact :
    refined_chronology_clight_trace chronologized_frames = run_trace run;
  chronologized_inputs_exact :
    project_inputs projection run =
      run_start_boundary_input initial ::
        refined_chronology_inputs chronologized_frames;
  chronologized_events_exact :
    project_events projection run =
      refined_chronology_events chronologized_frames;
  chronologized_collisions_exact :
    project_collision_observations projection run =
      refined_chronology_collision_observations chronologized_frames
}.

Theorem chronologized_run_reconstructs_exact_clight_trace :
  forall projection observer run initial,
    ChronologizedRunRefinement projection observer run initial ->
    @Smallstep.star _ _ Clight.step2
      (Clight.globalenv (run_program run))
      (run_start run) (run_trace run) (run_final run).
Proof.
  intros projection observer run initial chronology.
  destruct chronology as
    [final frames Huses Hstart Hversion Hboundary Hboundary_poll
      Hconnected Htrace
      Hinputs Hevents Hcollisions].
  unfold RunUsesProjection in Huses.
  rewrite Huses, <- Htrace.
  eapply refined_chronology_is_clight_star; eauto.
Qed.

Theorem chronologized_run_supplies_frame_refinement_certificate :
  forall projection observer run initial,
    ChronologizedRunRefinement projection observer run initial ->
    exists certificate :
      ClightFrameRefinementCertificate projection run initial, True.
Proof.
  intros projection observer run initial chronology.
  destruct chronology as
    [final frames Huses Hstart Hversion Hboundary Hboundary_poll
      Hconnected Htrace
      Hinputs Hevents Hcollisions].
  assert (Hfinal :
      project_state projection (run_final run) = Some final).
  {
    eapply refined_chronology_final_matches; eauto.
  }
  assert (Hhistory :
      coherent_input_history
        (state_first_frame_previous_down_seed initial)
        (project_inputs projection run)).
  {
    rewrite Hinputs.
    cbn. split; [reflexivity |].
    eapply refined_chronology_has_coherent_inputs; eauto.
  }
  assert (Hcount :
      length (project_inputs projection run) =
      S (length (project_events projection run))).
  {
    rewrite Hinputs, Hevents.
    cbn. now rewrite refined_chronology_input_event_count.
  }
  assert (Hboundary_exact :
      hd_error (project_inputs projection run) =
        Some (run_start_boundary_input initial)).
  {
    rewrite Hinputs. reflexivity.
  }
  assert (Hexecution :
      CertifiedExecution initial (project_events projection run) final).
  {
    rewrite Hevents.
    eapply refined_chronology_is_certified_execution; eauto.
  }
  assert (Hact3 :
      forall star phase,
        In (EventCollectAct3 star phase) (project_events projection run) ->
        In {| observed_object := star; observed_phase := phase |}
          (project_collision_observations projection run)).
  {
    intros star phase Hin.
    rewrite Hcollisions, Hevents in *.
    now eapply refined_chronology_act3_observations_complete.
  }
  assert (Htriggers :
      forall trigger trigger_object phase,
        In (EventConsumeTrigger trigger trigger_object phase)
          (project_events projection run) ->
        In {| observed_object := trigger_object; observed_phase := phase |}
          (project_collision_observations projection run)).
  {
    intros trigger trigger_object phase Hin.
    rewrite Hcollisions, Hevents in *.
    now eapply (refined_chronology_trigger_observations_complete
      projection observer frames trigger trigger_object phase).
  }
  exists
    {| refined_final_state := final;
       refined_run_uses_projection := Huses;
       refined_start_matches := Hstart;
       refined_initial_version := Hversion;
       refined_final_matches := Hfinal;
       refined_input_count := Hcount;
       refined_boundary_input_exact := Hboundary_exact;
       refined_input_history := Hhistory;
       refined_act3_collections_observed := Hact3;
       refined_trigger_consumptions_observed := Htriggers;
       refined_execution := Hexecution |}.
  exact I.
Qed.

(** Unlike the old opaque whole-run premise, this obligation demands a
    concrete list of chunks accepted by one fixed observation interface for
    every run in scope.  Observed gameplay/administrative chunks are nonempty;
    silent no-poll chunks may stutter and emit no input or event. *)
Definition WholeProgramChronologyRefinementObligation
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) : Prop :=
  forall run initial,
    RunUsesProjection projection run ->
    project_state projection (run_start run) = Some initial ->
    RunEndsAtSelectedFrameBoundary projection run ->
    exists chronology :
      ChronologizedRunRefinement projection observer run initial, True.

Definition SelectedObservedChronologyRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  exists observer : ClightFrameObservationInterface projection,
    WholeProgramChronologyRefinementObligation projection observer.

Theorem whole_program_chronology_refinement_supplies_clight_refinement :
  forall projection observer,
    WholeProgramChronologyRefinementObligation projection observer ->
    WholeProgramClightRefinementObligation projection.
Proof.
  intros projection observer Hchronology run initial Huses Hstart Hend.
  destruct (Hchronology run initial Huses Hstart Hend)
    as [chronology _].
  now apply (chronologized_run_supplies_frame_refinement_certificate
    projection observer run initial).
Qed.

(** * Non-vacuity from an actual program prefix *)

Definition reflexive_imported_clight_run
    (program : Clight.program) (state : Clight.state) : ImportedClightRun :=
  {| run_program := program;
     run_start := state;
     run_trace := E0;
     run_final := state;
     run_steps := @Smallstep.star_refl _ _ Clight.step2
       (Clight.globalenv program) state |}.

Definition ReachableProjectedCleanEntry
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection)
    (entrance : PyramidEntrance) : Prop :=
  exists entry_state abstract_state,
    project_state projection entry_state = Some abstract_state /\
    CleanPyramidEntry abstract_state /\
    state_version abstract_state = projection_version projection /\
    state_entrance abstract_state = entrance /\
    RunStartBoundaryPollAuthenticated projection observer
      (reflexive_imported_clight_run
        (projection_program projection) entry_state) abstract_state.

Definition ReachableProjectedCleanEntries
    (projection : ClightObservationProjection)
    (observer : ClightFrameObservationInterface projection) : Prop :=
  forall entrance, ReachableProjectedCleanEntry projection observer entrance.

Theorem reachable_projected_clean_entries_supply_nonvacuity :
  forall projection observer,
    ReachableProjectedCleanEntries projection observer ->
    CleanEntryProjectionNonvacuityObligation projection.
Proof.
  intros projection observer Hreachable entrance.
  destruct (Hreachable entrance) as
    (entry_state & abstract_state & Hprojection & Hclean & Hversion &
      Hentrance & Hboundary_poll).
  exists (reflexive_imported_clight_run
    (projection_program projection) entry_state), abstract_state.
  split.
  - unfold RunUsesProjection. reflexivity.
  - split; [exact Hprojection |].
    split; [exact Hclean |].
    split; assumption.
Qed.

Theorem chronology_and_reachable_entries_supply_target_refinement :
  forall projection observer,
    WholeProgramChronologyRefinementObligation projection observer ->
    ReachableProjectedCleanEntries projection observer ->
    TargetClightRefinementObligation projection.
Proof.
  intros projection observer Hchronology Hentries. split.
  - now apply (whole_program_chronology_refinement_supplies_clight_refinement
      projection observer).
  - now apply (reachable_projected_clean_entries_supply_nonvacuity
      projection observer).
Qed.

Theorem selected_chronology_and_reachable_entries_supply_target_refinement :
  forall projection observer,
    SelectedClightObservationProjection projection ->
    SelectedTargetSourceRefinementObligation projection ->
    SelectedTargetAuditTransportObligation projection ->
    WholeProgramChronologyRefinementObligation projection observer ->
    ReachableProjectedCleanEntries projection observer ->
    SelectedTargetClightRefinementObligation projection.
Proof.
  intros projection observer Hselected Hsource_refinement Haudit_transport
    Hchronology Hentries. split.
  - exact Hselected.
  - split.
    + exact Hsource_refinement.
    + split.
      * exact Haudit_transport.
      * now apply (chronology_and_reachable_entries_supply_target_refinement
          projection observer).
Qed.

(** Advertised capstone: unlike the generic selected-target obligation, this
    premise carries the concrete controller-authenticated observer and exact
    chronology existential needed to justify [project_inputs]. *)
Definition ObservedSelectedTargetClightRefinementObligation
    (projection : ClightObservationProjection) : Prop :=
  SelectedClightObservationProjection projection /\
  SelectedTargetSourceRefinementObligation projection /\
  SelectedTargetAuditTransportObligation projection /\
  exists observer : ClightFrameObservationInterface projection,
    WholeProgramChronologyRefinementObligation projection observer /\
    ReachableProjectedCleanEntries projection observer.

Theorem observed_selected_target_refinement_supplies_selected_refinement :
  forall projection,
    ObservedSelectedTargetClightRefinementObligation projection ->
    SelectedTargetClightRefinementObligation projection.
Proof.
  intros projection
    [Hselected [Hsource [Haudit
      [observer [Hchronology Hentries]]]]].
  eapply selected_chronology_and_reachable_entries_supply_target_refinement;
    eauto.
Qed.

(** The construction above exposes the exact remaining facts rather than
    hiding them in [WholeProgramClightRefinementObligation]: define the
    selected program's concrete frame observer and prove its interface, build
    the nonempty frame chronology from linked execution, and prove that the
    projection functions return precisely its data streams.  Separately,
    non-vacuity now reduces to a nonempty [thread5_game_loop] task-entry prefix
    reaching each concrete lower/upper entry. *)
