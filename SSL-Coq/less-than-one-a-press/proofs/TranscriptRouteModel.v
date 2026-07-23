(* Logical route-gate model extracted from the supplied Pyramid A Presses
   transcript.  This file deliberately does not claim that the transcript's
   route decomposition has been refined from Clight.  [TranscriptRouteGateModel]
   and the two downstream-completeness definitions are named obligations that
   must be justified before these lemmas can say anything about a ROM run. *)

From Coq Require Import Lia List.
From LessThanOneAPress.Proofs Require Import
  GameTypes InputSemantics CleanEntry AreaTransitions.

Import ListNotations.

(* These are reachability nodes, not collection events.  The first is the
   interaction region for the static Act 3 star.  The second is the upper
   hidden-star trigger whose consumption is necessary for the Act 6 star. *)
Inductive TargetRouteRegion :=
| Act3InteractionRegionNode
| UpperHiddenStarTriggerNode.

Inductive TranscriptRouteGate :=
| ElevatorJumpOutGate
| SecondPoleJumpOffGate.

Inductive ElevatorEscapeMechanism :=
| SpawningDisplacementEscape
| OtherElevatorEscape.

(* [ObservedGateAPress gate] is gate-labelled evidence.  [RouteFrame] below
   pairs it with the input for that same modeled frame.  The label still needs
   a Clight control-flow refinement to show that the press performs the stated
   jump. *)
Inductive RouteObservation :=
| ObservedGateAPress : TranscriptRouteGate -> RouteObservation
| ObservedElevatorEscape : ElevatorEscapeMechanism -> RouteObservation
| ObservedAboveSecondPole : RouteObservation
| ObservedTargetRegion : TargetRouteRegion -> RouteObservation.

Record RouteFrame := {
  route_frame_input : FrameInput;
  (* Oldest observation in the frame first. *)
  route_frame_observations : list RouteObservation
}.

Record RouteTrace := {
  (* Oldest modeled frame first. *)
  route_frames : list RouteFrame
}.

Definition route_inputs (trace : RouteTrace) : list FrameInput :=
  map route_frame_input (route_frames trace).

Definition route_observations (trace : RouteTrace) : list RouteObservation :=
  concat (map route_frame_observations (route_frames trace)).

Lemma route_frame_observation_is_observed :
  forall trace frame observation,
    In frame (route_frames trace) ->
    In observation (route_frame_observations frame) ->
    In observation (route_observations trace).
Proof.
  intros trace frame observation Hframe Hobservation.
  unfold route_observations.
  apply in_concat.
  exists (route_frame_observations frame). split.
  - apply in_map. exact Hframe.
  - exact Hobservation.
Qed.

Definition observation_precedes_in_frame
    (frame : RouteFrame) (earlier later : RouteObservation) : Prop :=
  exists prefix middle suffix,
    route_frame_observations frame =
      prefix ++ (earlier :: (middle ++ (later :: suffix))).

Definition target_region_observed_at
    (trace : RouteTrace) (target_index : nat) (target_frame : RouteFrame)
    (region : TargetRouteRegion) : Prop :=
  nth_error (route_frames trace) target_index = Some target_frame /\
  In (ObservedTargetRegion region) (route_frame_observations target_frame).

(* The earlier occurrence is tied to a concrete frame/index.  If both
   observations are in one frame, their order is checked inside that frame. *)
Definition observation_occurrence_precedes_target
    (trace : RouteTrace)
    (earlier_index : nat) (earlier_frame : RouteFrame)
    (target_index : nat) (target_frame : RouteFrame)
    (earlier : RouteObservation) (region : TargetRouteRegion) : Prop :=
  nth_error (route_frames trace) earlier_index = Some earlier_frame /\
  target_region_observed_at trace target_index target_frame region /\
  In earlier (route_frame_observations earlier_frame) /\
  ((earlier_index < target_index)%nat \/
   (earlier_index = target_index /\
    earlier_frame = target_frame /\
    observation_precedes_in_frame earlier_frame earlier
      (ObservedTargetRegion region))).

Definition reaches_target_region
    (trace : RouteTrace) (region : TargetRouteRegion) : Prop :=
  In (ObservedTargetRegion region) (route_observations trace).

Definition reaches_any_target_region (trace : RouteTrace) : Prop :=
  exists region, reaches_target_region trace region.

Lemma reaches_target_region_has_occurrence :
  forall trace region,
    reaches_target_region trace region ->
    exists target_index target_frame,
      target_region_observed_at trace target_index target_frame region.
Proof.
  intros [frames] region Hreach.
  unfold reaches_target_region, route_observations in Hreach. simpl in Hreach.
  induction frames as [|frame rest IH].
  - simpl in Hreach. contradiction.
  - simpl in Hreach. apply in_app_iff in Hreach.
    destruct Hreach as [Hhere | Hrest].
    + exists 0%nat, frame. split; [reflexivity | exact Hhere].
    + specialize (IH Hrest) as [index [target_frame [Hnth Hin]]].
      exists (S index), target_frame. split; [simpl; exact Hnth | exact Hin].
Qed.

Definition elevator_escape_observed (trace : RouteTrace) : Prop :=
  exists mechanism,
    In (ObservedElevatorEscape mechanism) (route_observations trace).

Definition spawning_displacement_escape_observed (trace : RouteTrace) : Prop :=
  In (ObservedElevatorEscape SpawningDisplacementEscape)
    (route_observations trace).

Definition above_second_pole_observed (trace : RouteTrace) : Prop :=
  In ObservedAboveSecondPole (route_observations trace).

Definition gate_a_press_observed
    (trace : RouteTrace) (gate : TranscriptRouteGate) : Prop :=
  exists frame,
    In frame (route_frames trace) /\
    In (ObservedGateAPress gate) (route_frame_observations frame) /\
    a_button_pressed
      (frame_current_down (route_frame_input frame))
      (frame_previous_down (route_frame_input frame)) = true.

Definition gate_a_press_precedes_target
    (trace : RouteTrace) (gate : TranscriptRouteGate)
    (region : TargetRouteRegion)
    (target_index : nat) (target_frame : RouteFrame) : Prop :=
  exists gate_index gate_frame,
    a_button_pressed
      (frame_current_down (route_frame_input gate_frame))
      (frame_previous_down (route_frame_input gate_frame)) = true /\
    observation_occurrence_precedes_target trace
      gate_index gate_frame target_index target_frame
      (ObservedGateAPress gate) region.

Definition elevator_escape_precedes_target
    (trace : RouteTrace) (region : TargetRouteRegion)
    (target_index : nat) (target_frame : RouteFrame) : Prop :=
  exists mechanism escape_index escape_frame,
    observation_occurrence_precedes_target trace
      escape_index escape_frame target_index target_frame
      (ObservedElevatorEscape mechanism) region.

Definition above_second_pole_precedes_target
    (trace : RouteTrace) (region : TargetRouteRegion)
    (target_index : nat) (target_frame : RouteFrame) : Prop :=
  exists pole_index pole_frame,
    observation_occurrence_precedes_target trace
      pole_index pole_frame target_index target_frame
      ObservedAboveSecondPole region.

Definition trace_contains_a_press (trace : RouteTrace) : Prop :=
  exists frame,
    In frame (route_frames trace) /\
    a_button_pressed
      (frame_current_down (route_frame_input frame))
      (frame_previous_down (route_frame_input frame)) = true.

Lemma no_a_trace_has_no_gate_a_press :
  forall trace gate,
    fewer_than_one_a_press (route_inputs trace) ->
    ~ gate_a_press_observed trace gate.
Proof.
  intros trace gate Hnoa
    [frame [Hframe [_ Hpressed]]].
  unfold fewer_than_one_a_press in Hnoa.
  rewrite Forall_forall in Hnoa.
  specialize (Hnoa (route_frame_input frame)).
  assert (Hinput : In (route_frame_input frame) (route_inputs trace)).
  { unfold route_inputs. apply in_map. exact Hframe. }
  specialize (Hnoa Hinput).
  unfold frame_has_no_a_press in Hnoa.
  rewrite Hnoa in Hpressed.
  discriminate.
Qed.

Lemma gate_a_press_precedes_target_is_observed :
  forall trace gate region target_index target_frame,
    gate_a_press_precedes_target
      trace gate region target_index target_frame ->
    gate_a_press_observed trace gate.
Proof.
  intros trace gate region target_index target_frame
    [gate_index [gate_frame [Hpressed Hprecedes]]].
  destruct Hprecedes as [Hgate_nth [_ [Hgate _]]].
  exists gate_frame. split.
  - eapply nth_error_In. exact Hgate_nth.
  - auto.
Qed.

Lemma elevator_escape_precedes_target_is_observed :
  forall trace region target_index target_frame,
    elevator_escape_precedes_target
      trace region target_index target_frame ->
    elevator_escape_observed trace.
Proof.
  intros trace region target_index target_frame
    [mechanism [escape_index [escape_frame Hprecedes]]].
  destruct Hprecedes as [Hescape_nth [_ [Hescape _]]].
  exists mechanism.
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hescape_nth.
  - exact Hescape.
Qed.

Lemma above_second_pole_precedes_target_is_observed :
  forall trace region target_index target_frame,
    above_second_pole_precedes_target
      trace region target_index target_frame ->
    above_second_pole_observed trace.
Proof.
  intros trace region target_index target_frame
    [pole_index [pole_frame Hprecedes]].
  destruct Hprecedes as [Hpole_nth [_ [Hpole _]]].
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hpole_nth.
  - exact Hpole.
Qed.

(* Regression property for the ordering bug this indexed representation
   avoids: the selected A-edge frame can never be after the target frame. *)
Lemma gate_a_press_precedes_target_uses_nonlater_frame :
  forall trace gate region target_index target_frame,
    gate_a_press_precedes_target
      trace gate region target_index target_frame ->
    exists gate_index gate_frame,
      nth_error (route_frames trace) gate_index = Some gate_frame /\
      a_button_pressed
        (frame_current_down (route_frame_input gate_frame))
        (frame_previous_down (route_frame_input gate_frame)) = true /\
      (gate_index <= target_index)%nat.
Proof.
  intros trace gate region target_index target_frame
    [gate_index [gate_frame [Hpressed Hprecedes]]].
  destruct Hprecedes as [Hgate_nth [_ [_ Horder]]].
  exists gate_index, gate_frame. split; [exact Hgate_nth |].
  split; [exact Hpressed |].
  destruct Horder as [Hbefore | [Hequal _]].
  - lia.
  - lia.
Qed.

Lemma gate_a_press_is_a_trace_press :
  forall trace gate,
    gate_a_press_observed trace gate ->
    trace_contains_a_press trace.
Proof.
  intros trace gate [frame [Hframe [_ Hpressed]]].
  exists frame. auto.
Qed.

(* This certificate prevents route observations from being free-standing
   labels.  Each route frame has one event slot in a [CertifiedExecution], and
   each target-region observation is backed by the corresponding collection
   or trigger-consumption event at the same list index.  It is still an
   abstract-event certificate, not yet a Clight execution/refinement proof. *)
Definition RealizedRouteTrace
    (initial : GameState) (trace : RouteTrace) : Prop :=
  exists final events,
    CertifiedExecution initial events final /\
    length (route_frames trace) = length events /\
    (forall index frame,
      nth_error (route_frames trace) index = Some frame ->
      In (ObservedTargetRegion Act3InteractionRegionNode)
        (route_frame_observations frame) ->
      exists star phase,
        nth_error events index = Some (EventCollectAct3 star phase)) /\
    (forall index frame,
      nth_error (route_frames trace) index = Some frame ->
      In (ObservedTargetRegion UpperHiddenStarTriggerNode)
        (route_frame_observations frame) ->
      exists trigger_object phase,
        nth_error events index = Some (EventConsumeTrigger
          TriggerUpper trigger_object phase)).

(* This record is the transcript's two-gate reduction, stated as an explicit
   obligation rather than asserted as a theorem of the imported C program.
   It says that access to either relevant target region must cross the gate
   selected by the clean entry: the elevator for the upper entrance, or the
   second-pole boundary for the lower entrance. *)
Record TranscriptRouteGateModel
    (initial : GameState) (trace : RouteTrace) : Prop := {
  transcript_route_clean_entry : CleanPyramidEntry initial;
  transcript_route_input_history :
    coherent_input_history (state_previous_buttons initial)
      (route_inputs trace);
  transcript_route_realized : RealizedRouteTrace initial trace;
  upper_target_access_gate :
    forall region target_index target_frame,
    state_entrance initial = UpperEntrance ->
    target_region_observed_at trace target_index target_frame region ->
    gate_a_press_precedes_target
      trace ElevatorJumpOutGate region target_index target_frame \/
    elevator_escape_precedes_target
      trace region target_index target_frame;
  lower_target_access_gate :
    forall region target_index target_frame,
    state_entrance initial = LowerEntrance ->
    target_region_observed_at trace target_index target_frame region ->
    gate_a_press_precedes_target
      trace SecondPoleJumpOffGate region target_index target_frame \/
    above_second_pole_precedes_target
      trace region target_index target_frame
}.

Theorem no_a_target_access_requires_preceding_gate_bypass :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    exists region target_index target_frame,
      target_region_observed_at trace target_index target_frame region /\
      ((state_entrance initial = UpperEntrance /\
         elevator_escape_precedes_target
           trace region target_index target_frame) \/
       (state_entrance initial = LowerEntrance /\
         above_second_pole_precedes_target
           trace region target_index target_frame)).
Proof.
  intros initial trace Hmodel Hnoa Htarget.
  destruct Htarget as [region Htarget].
  destruct (reaches_target_region_has_occurrence trace region Htarget)
    as [target_index [target_frame Htarget_at]].
  exists region, target_index, target_frame.
  split; [exact Htarget_at |].
  destruct (clean_selected_entrance initial
    (transcript_route_clean_entry initial trace Hmodel))
    as [Hlower | Hupper].
  - right. split; [exact Hlower |].
    destruct (lower_target_access_gate initial trace Hmodel
      region target_index target_frame Hlower Htarget_at)
      as [Hpress | Habove].
    + exfalso.
      eapply (no_a_trace_has_no_gate_a_press
        trace SecondPoleJumpOffGate Hnoa).
      eapply gate_a_press_precedes_target_is_observed.
      exact Hpress.
    + exact Habove.
  - left. split; [exact Hupper |].
    destruct (upper_target_access_gate initial trace Hmodel
      region target_index target_frame Hupper Htarget_at)
      as [Hpress | Hescape].
    + exfalso.
      eapply (no_a_trace_has_no_gate_a_press
        trace ElevatorJumpOutGate Hnoa).
      eapply gate_a_press_precedes_target_is_observed.
      exact Hpress.
    + exact Hescape.
Qed.

Theorem no_a_target_access_requires_gate_bypass :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    (state_entrance initial = UpperEntrance /\
       elevator_escape_observed trace) \/
    (state_entrance initial = LowerEntrance /\
       above_second_pole_observed trace).
Proof.
  intros initial trace Hmodel Hnoa Htarget.
  destruct (no_a_target_access_requires_preceding_gate_bypass
    initial trace Hmodel Hnoa Htarget)
    as [region [target_index [target_frame
      [_ [[Hupper Hescape] | [Hlower Habove]]]]]].
  - left. split; [exact Hupper |].
    eapply elevator_escape_precedes_target_is_observed. exact Hescape.
  - right. split; [exact Hlower |].
    eapply above_second_pole_precedes_target_is_observed. exact Habove.
Qed.

(* When both bypass alternatives are excluded, the route-gate model entails
   at least one edge-triggered A press.  It does not establish either bypass
   exclusion; those are the substantive geometric/lifecycle obligations. *)
Theorem closed_route_model_requires_one_a :
  forall initial trace,
    TranscriptRouteGateModel initial trace ->
    reaches_any_target_region trace ->
    ~ elevator_escape_observed trace ->
    ~ above_second_pole_observed trace ->
    trace_contains_a_press trace.
Proof.
  intros initial trace Hmodel Htarget Hno_escape Hnot_above.
  destruct Htarget as [region Htarget].
  destruct (reaches_target_region_has_occurrence trace region Htarget)
    as [target_index [target_frame Htarget_at]].
  destruct (clean_selected_entrance initial
    (transcript_route_clean_entry initial trace Hmodel))
    as [Hlower | Hupper].
  - destruct (lower_target_access_gate initial trace Hmodel
      region target_index target_frame Hlower Htarget_at)
      as [Hpress | Habove].
    + eapply gate_a_press_is_a_trace_press.
      eapply gate_a_press_precedes_target_is_observed. exact Hpress.
    + exfalso. apply Hnot_above.
      eapply above_second_pole_precedes_target_is_observed. exact Habove.
  - destruct (upper_target_access_gate initial trace Hmodel
      region target_index target_frame Hupper Htarget_at)
      as [Hpress | Hescape].
    + eapply gate_a_press_is_a_trace_press.
      eapply gate_a_press_precedes_target_is_observed. exact Hpress.
    + exfalso. apply Hno_escape.
      eapply elevator_escape_precedes_target_is_observed. exact Hescape.
Qed.

(* A bypass witnessed in a no-A trace falsifies the corresponding closure
   premise.  Thus the gate argument alone cannot exclude target access after
   such a witness is found. *)
Definition UpperElevatorGateClosed (trace : RouteTrace) : Prop :=
  fewer_than_one_a_press (route_inputs trace) ->
  ~ elevator_escape_observed trace.

Definition LowerSecondPoleGateClosed (trace : RouteTrace) : Prop :=
  fewer_than_one_a_press (route_inputs trace) ->
  ~ above_second_pole_observed trace.

Theorem no_a_elevator_escape_refutes_upper_gate_closure :
  forall trace,
    fewer_than_one_a_press (route_inputs trace) ->
    elevator_escape_observed trace ->
    ~ UpperElevatorGateClosed trace.
Proof.
  intros trace Hnoa Hescape Hclosed.
  exact (Hclosed Hnoa Hescape).
Qed.

Theorem no_a_above_second_pole_refutes_lower_gate_closure :
  forall trace,
    fewer_than_one_a_press (route_inputs trace) ->
    above_second_pole_observed trace ->
    ~ LowerSecondPoleGateClosed trace.
Proof.
  intros trace Hnoa Habove Hclosed.
  exact (Hclosed Hnoa Habove).
Qed.

(* A complete route may extend a bypass prefix with more inputs and route
   observations.  The extension relation is structural only; it says nothing
   about executability, which belongs in the future Clight refinement. *)
Definition RouteTraceExtension (prefix complete : RouteTrace) : Prop :=
  exists frame_suffix,
    route_frames complete = route_frames prefix ++ frame_suffix.

(* The selected target observation lies strictly in the continuation, so a
   target visited before the bypass prefix cannot satisfy downstream access. *)
Definition RouteTraceExtensionToTarget
    (prefix complete : RouteTrace) (region : TargetRouteRegion) : Prop :=
  exists frame_suffix target_frame,
    route_frames complete = route_frames prefix ++ frame_suffix /\
    In target_frame frame_suffix /\
    In (ObservedTargetRegion region)
      (route_frame_observations target_frame).

Lemma route_trace_extension_to_target_is_extension :
  forall prefix complete region,
    RouteTraceExtensionToTarget prefix complete region ->
    RouteTraceExtension prefix complete.
Proof.
  intros prefix complete region
    [frame_suffix [target_frame [Hframes [Htarget_frame Htarget]]]].
  exists frame_suffix. exact Hframes.
Qed.

Lemma route_trace_extension_to_target_reaches_region :
  forall prefix complete region,
    RouteTraceExtensionToTarget prefix complete region ->
    reaches_target_region complete region.
Proof.
  intros prefix complete region
    [frame_suffix [target_frame [Hframes [Htarget_frame Htarget]]]].
  unfold reaches_target_region.
  eapply route_frame_observation_is_observed.
  - rewrite Hframes. apply in_or_app. right. exact Htarget_frame.
  - exact Htarget.
Qed.

(* The two target nodes are reached in separate executions extending the same
   bypass prefix.  This is necessary because collecting a star normally exits
   the course.  Full input-history coherence on each extension also prevents
   a hidden A edge from being erased at the prefix/suffix boundary. *)
Definition ZeroATargetRouteCapability
    (initial : GameState) (prefix : RouteTrace) : Prop :=
  (exists act3_complete,
    RouteTraceExtensionToTarget
      prefix act3_complete Act3InteractionRegionNode /\
    RealizedRouteTrace initial act3_complete /\
    fewer_than_one_a_press (route_inputs act3_complete) /\
    coherent_input_history (state_previous_buttons initial)
      (route_inputs act3_complete)) /\
  (exists trigger_complete,
    RouteTraceExtensionToTarget
      prefix trigger_complete UpperHiddenStarTriggerNode /\
    RealizedRouteTrace initial trigger_complete /\
    fewer_than_one_a_press (route_inputs trigger_complete) /\
    coherent_input_history (state_previous_buttons initial)
      (route_inputs trigger_complete)).

(* These are precisely the transcript's "everything else is traversable"
   premises.  They are intentionally not proved here. *)
Definition UpperDownstreamCompleteness (initial : GameState) : Prop :=
  forall prefix,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    coherent_input_history (state_previous_buttons initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    elevator_escape_observed prefix ->
    ZeroATargetRouteCapability initial prefix.

Definition LowerDownstreamCompleteness (initial : GameState) : Prop :=
  forall prefix,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    coherent_input_history (state_previous_buttons initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    above_second_pole_observed prefix ->
    ZeroATargetRouteCapability initial prefix.

Theorem spawning_displacement_escape_opens_both_target_regions :
  forall initial prefix,
    UpperDownstreamCompleteness initial ->
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    state_version initial = VersionJP ->
    coherent_input_history (state_previous_buttons initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    spawning_displacement_escape_observed prefix ->
    ZeroATargetRouteCapability initial prefix.
Proof.
  intros initial prefix Hdownstream Hclean Hupper Hjp Hhistory Hnoa Hspawn.
  (* [Hjp] records the source-backed version scope of retained-platform
     spawning displacement; the abstract downstream implication itself does
     not inspect the version. *)
  clear Hjp.
  eapply Hdownstream; eauto.
  exists SpawningDisplacementEscape.
  exact Hspawn.
Qed.

Theorem above_second_pole_access_opens_both_target_regions :
  forall initial prefix,
    LowerDownstreamCompleteness initial ->
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    coherent_input_history (state_previous_buttons initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    above_second_pole_observed prefix ->
    ZeroATargetRouteCapability initial prefix.
Proof.
  intros initial prefix Hdownstream Hclean Hlower Hhistory Hnoa Habove.
  eapply Hdownstream; eauto.
Qed.
