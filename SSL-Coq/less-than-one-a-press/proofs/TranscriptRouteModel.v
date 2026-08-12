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

(* Despite the historical [Witness] names, these values are payload-free class
   tags, not evidence of a concrete bypass.  They make the intended case
   vocabulary reviewable.  A future Clight/collision-mesh projection must give
   each tag state/event semantics and prove that every non-gate first crossing
   produces one.  The two entrance-specific types are separate because the
   elevator and pole cuts have different obligations. *)
Inductive UpperBypassWitness :=
| UpperPlatformDisplacementBypass
| UpperObjectPushOrMovingGeometryBypass
| UpperWarpOrArea3Bypass
| UpperCollisionClipOrTunnelBypass
| UpperParallelUniverseOrOutOfBoundsBypass
| UpperTargetRelocationOrSubstitutionBypass
| UpperMacroOrLifecycleAnomalyBypass
| UpperSaveReloadOrCorruptionBypass
| UpperMemoryOrUndefinedBehaviorBypass.

Inductive LowerBypassWitness :=
| LowerPlatformDisplacementBypass
| LowerObjectPushOrMovingGeometryBypass
| LowerWarpOrArea3Bypass
| LowerCollisionClipOrTunnelBypass
| LowerParallelUniverseOrOutOfBoundsBypass
| LowerTargetRelocationOrSubstitutionBypass
| LowerMacroOrLifecycleAnomalyBypass
| LowerSaveReloadOrCorruptionBypass
| LowerMemoryOrUndefinedBehaviorBypass.

(* [ObservedGateAPress gate] is gate-labelled evidence.  [RouteFrame] below
   pairs it with the input for that same modeled frame.  The label still needs
   a Clight control-flow refinement to show that the press performs the stated
   jump. *)
Inductive RouteObservation :=
| ObservedGateAPress : TranscriptRouteGate -> RouteObservation
| ObservedElevatorEscape : ElevatorEscapeMechanism -> RouteObservation
| ObservedAboveSecondPole : RouteObservation
| ObservedUpperBypass : UpperBypassWitness -> RouteObservation
| ObservedLowerBypass : LowerBypassWitness -> RouteObservation
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

(* A position identifies one exact observation occurrence, including its
   within-frame position.  This is stronger than [In]: duplicate labels in a
   frame cannot be substituted for the selected first target occurrence. *)
Definition observation_at
    (trace : RouteTrace) (frame_index observation_index : nat)
    (observation : RouteObservation) : Prop :=
  exists frame,
    nth_error (route_frames trace) frame_index = Some frame /\
    nth_error (route_frame_observations frame) observation_index =
      Some observation.

Definition target_observation_at
    (trace : RouteTrace) (frame_index observation_index : nat)
    (region : TargetRouteRegion) : Prop :=
  observation_at trace frame_index observation_index
    (ObservedTargetRegion region).

Definition route_position_precedes
    (earlier_frame earlier_observation later_frame later_observation : nat)
    : Prop :=
  (earlier_frame < later_frame)%nat \/
  (earlier_frame = later_frame /\
   (earlier_observation < later_observation)%nat).

Definition exact_observation_precedes_target
    (trace : RouteTrace)
    (earlier_frame earlier_observation target_frame target_observation : nat)
    (earlier : RouteObservation) (region : TargetRouteRegion) : Prop :=
  observation_at trace earlier_frame earlier_observation earlier /\
  target_observation_at trace target_frame target_observation region /\
  route_position_precedes
    earlier_frame earlier_observation target_frame target_observation.

Definition first_target_observation_at
    (trace : RouteTrace) (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop :=
  target_observation_at trace target_frame target_observation region /\
  forall earlier_region earlier_frame earlier_observation,
    target_observation_at trace earlier_frame earlier_observation
      earlier_region ->
    ~ route_position_precedes
        earlier_frame earlier_observation target_frame target_observation.

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

Definition route_observation_eq_dec :
  forall left right : RouteObservation, {left = right} + {left <> right}.
Proof. repeat decide equality. Defined.

Definition target_observation_in_list_dec
    (observations : list RouteObservation) :
    {exists region,
      In (ObservedTargetRegion region) observations} +
    {~ exists region,
      In (ObservedTargetRegion region) observations}.
Proof.
  destruct (in_dec route_observation_eq_dec
    (ObservedTargetRegion Act3InteractionRegionNode) observations)
    as [Hact3 | Hnot_act3].
  - left. exists Act3InteractionRegionNode. exact Hact3.
  - destruct (in_dec route_observation_eq_dec
      (ObservedTargetRegion UpperHiddenStarTriggerNode) observations)
      as [Hupper | Hnot_upper].
    + left. exists UpperHiddenStarTriggerNode. exact Hupper.
    + right. intros [region Htarget]. destruct region.
      * exact (Hnot_act3 Htarget).
      * exact (Hnot_upper Htarget).
Defined.

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

Lemma first_target_in_observation_list :
  forall observations,
    (exists region,
      In (ObservedTargetRegion region) observations) ->
    exists region observation_index,
      nth_error observations observation_index =
        Some (ObservedTargetRegion region) /\
      forall earlier_region earlier_index,
        (earlier_index < observation_index)%nat ->
        nth_error observations earlier_index <>
          Some (ObservedTargetRegion earlier_region).
Proof.
  induction observations as [|observation rest IH]; intros Htarget.
  - destruct Htarget as [region Htarget]. contradiction.
  - destruct observation as
      [gate | mechanism | | upper_witness | lower_witness | region].
    + assert (Hrest :
        exists region, In (ObservedTargetRegion region) rest).
      {
        destruct Htarget as [region [Hhead | Htail]].
        - discriminate.
        - exists region. exact Htail.
      }
      destruct (IH Hrest) as
        [target_region [observation_index [Hat Hfirst]]].
      exists target_region, (S observation_index). split.
      * simpl. exact Hat.
      * intros earlier_region earlier_index Hbefore.
        destruct earlier_index as [|earlier_index].
        -- discriminate.
        -- simpl. apply Hfirst. lia.
    + assert (Hrest :
        exists region, In (ObservedTargetRegion region) rest).
      {
        destruct Htarget as [region [Hhead | Htail]].
        - discriminate.
        - exists region. exact Htail.
      }
      destruct (IH Hrest) as
        [target_region [observation_index [Hat Hfirst]]].
      exists target_region, (S observation_index). split.
      * simpl. exact Hat.
      * intros earlier_region earlier_index Hbefore.
        destruct earlier_index as [|earlier_index].
        -- discriminate.
        -- simpl. apply Hfirst. lia.
    + assert (Hrest :
        exists region, In (ObservedTargetRegion region) rest).
      {
        destruct Htarget as [region [Hhead | Htail]].
        - discriminate.
        - exists region. exact Htail.
      }
      destruct (IH Hrest) as
        [target_region [observation_index [Hat Hfirst]]].
      exists target_region, (S observation_index). split.
      * simpl. exact Hat.
      * intros earlier_region earlier_index Hbefore.
        destruct earlier_index as [|earlier_index].
        -- discriminate.
        -- simpl. apply Hfirst. lia.
    + assert (Hrest :
        exists region, In (ObservedTargetRegion region) rest).
      {
        destruct Htarget as [region [Hhead | Htail]].
        - discriminate.
        - exists region. exact Htail.
      }
      destruct (IH Hrest) as
        [target_region [observation_index [Hat Hfirst]]].
      exists target_region, (S observation_index). split.
      * simpl. exact Hat.
      * intros earlier_region earlier_index Hbefore.
        destruct earlier_index as [|earlier_index].
        -- discriminate.
        -- simpl. apply Hfirst. lia.
    + assert (Hrest :
        exists region, In (ObservedTargetRegion region) rest).
      {
        destruct Htarget as [region [Hhead | Htail]].
        - discriminate.
        - exists region. exact Htail.
      }
      destruct (IH Hrest) as
        [target_region [observation_index [Hat Hfirst]]].
      exists target_region, (S observation_index). split.
      * simpl. exact Hat.
      * intros earlier_region earlier_index Hbefore.
        destruct earlier_index as [|earlier_index].
        -- discriminate.
        -- simpl. apply Hfirst. lia.
    + exists region, 0%nat. split; [reflexivity |].
      intros earlier_region earlier_index Hbefore. lia.
Qed.

Lemma first_target_in_frame_list :
  forall frames,
    (exists region,
      In (ObservedTargetRegion region)
        (concat (map route_frame_observations frames))) ->
    exists region frame_index observation_index,
      (exists frame,
        nth_error frames frame_index = Some frame /\
        nth_error (route_frame_observations frame) observation_index =
          Some (ObservedTargetRegion region)) /\
      forall earlier_region earlier_frame earlier_observation,
        (exists frame,
          nth_error frames earlier_frame = Some frame /\
          nth_error (route_frame_observations frame) earlier_observation =
            Some (ObservedTargetRegion earlier_region)) ->
        ~ route_position_precedes
            earlier_frame earlier_observation frame_index observation_index.
Proof.
  induction frames as [|frame rest IH]; intros Htarget.
  - destruct Htarget as [region Htarget]. contradiction.
  - destruct (target_observation_in_list_dec
      (route_frame_observations frame))
      as [Htarget_here | Hno_target_here].
    + destruct (first_target_in_observation_list
        (route_frame_observations frame) Htarget_here)
        as [region [observation_index [Hat Hfirst]]].
      exists region, 0%nat, observation_index. split.
      * exists frame. split; [reflexivity | exact Hat].
      * intros earlier_region earlier_frame earlier_observation
          [selected_frame [Hframe Hobservation]] Hprecedes.
        destruct Hprecedes as [Hframe_before |
          [Hsame_frame Hobservation_before]].
        -- lia.
        -- subst earlier_frame. simpl in Hframe.
           inversion Hframe; subst selected_frame.
           eapply (Hfirst earlier_region earlier_observation
             Hobservation_before).
           exact Hobservation.
    + assert (Htarget_rest :
        exists region,
          In (ObservedTargetRegion region)
            (concat (map route_frame_observations rest))).
      {
        destruct Htarget as [region Htarget].
        simpl in Htarget. apply in_app_iff in Htarget.
        destruct Htarget as [Hhere | Hrest].
        - exfalso. apply Hno_target_here.
          exists region. exact Hhere.
        - exists region. exact Hrest.
      }
      destruct (IH Htarget_rest) as
        [region [frame_index [observation_index [Hat Hfirst]]]].
      exists region, (S frame_index), observation_index. split.
      * destruct Hat as [selected_frame [Hframe Hobservation]].
        exists selected_frame. split; [simpl; exact Hframe |].
        exact Hobservation.
      * intros earlier_region earlier_frame earlier_observation
          [selected_frame [Hframe Hobservation]] Hprecedes.
        destruct earlier_frame as [|earlier_frame].
        -- simpl in Hframe. inversion Hframe; subst selected_frame.
           apply Hno_target_here. exists earlier_region.
           eapply nth_error_In. exact Hobservation.
        -- apply (Hfirst earlier_region earlier_frame earlier_observation).
           ++ exists selected_frame. split.
              ** simpl in Hframe. exact Hframe.
              ** exact Hobservation.
           ++ destruct Hprecedes as [Hframe_before |
                [Hsame_frame Hobservation_before]].
              ** left. lia.
              ** right. split; [lia | exact Hobservation_before].
Qed.

Theorem reaches_any_target_has_first_exact_occurrence :
  forall trace,
    reaches_any_target_region trace ->
    exists region frame_index observation_index,
      first_target_observation_at
        trace region frame_index observation_index.
Proof.
  intros [frames] [region Htarget].
  unfold reaches_target_region, route_observations in Htarget. simpl in Htarget.
  destruct (first_target_in_frame_list frames)
    as [first_region [frame_index [observation_index [Hat Hfirst]]]].
  - exists region. exact Htarget.
  - exists first_region, frame_index, observation_index.
    split; [exact Hat | exact Hfirst].
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

Inductive TargetEventForRegion :
    TargetRouteRegion -> FrameEvent -> Prop :=
| TargetEventForAct3 : forall star phase,
    TargetEventForRegion Act3InteractionRegionNode
      (EventCollectAct3 star phase)
| TargetEventForUpperTrigger : forall trigger_object phase,
    TargetEventForRegion UpperHiddenStarTriggerNode
      (EventConsumeTrigger TriggerUpper trigger_object phase).

(* The alignment is deliberately bidirectional at the exact frame index.
   Consequently neither a target observation nor a target event can be
   appended without its same-frame counterpart.  This is still an
   abstract-event certificate, not yet a Clight execution/refinement proof. *)
Record RouteTraceExecutionAlignment
    (initial : GameState) (trace : RouteTrace)
    (events : list FrameEvent) (final : GameState) : Prop := {
  aligned_certified_execution :
    CertifiedExecution initial events final;
  aligned_frame_event_lengths :
    length (route_frames trace) = length events;
  aligned_act3_observation_to_event :
    forall index frame,
      nth_error (route_frames trace) index = Some frame ->
      In (ObservedTargetRegion Act3InteractionRegionNode)
        (route_frame_observations frame) ->
      exists star phase,
        nth_error events index = Some (EventCollectAct3 star phase);
  aligned_upper_observation_to_event :
    forall index frame,
      nth_error (route_frames trace) index = Some frame ->
      In (ObservedTargetRegion UpperHiddenStarTriggerNode)
        (route_frame_observations frame) ->
      exists trigger_object phase,
        nth_error events index = Some (EventConsumeTrigger
          TriggerUpper trigger_object phase);
  aligned_act3_event_to_observation :
    forall index star phase,
      nth_error events index = Some (EventCollectAct3 star phase) ->
      exists frame,
        nth_error (route_frames trace) index = Some frame /\
        In (ObservedTargetRegion Act3InteractionRegionNode)
          (route_frame_observations frame);
  aligned_upper_event_to_observation :
    forall index trigger_object phase,
      nth_error events index = Some (EventConsumeTrigger
        TriggerUpper trigger_object phase) ->
      exists frame,
        nth_error (route_frames trace) index = Some frame /\
        In (ObservedTargetRegion UpperHiddenStarTriggerNode)
          (route_frame_observations frame)
}.

Definition RealizedRouteTrace
    (initial : GameState) (trace : RouteTrace) : Prop :=
  exists final events,
    RouteTraceExecutionAlignment initial trace events final.

Theorem aligned_target_event_iff_observation_at_same_frame :
  forall initial trace events final,
    RouteTraceExecutionAlignment initial trace events final ->
    forall index region,
      (exists event,
        nth_error events index = Some event /\
        TargetEventForRegion region event) <->
      (exists frame,
        nth_error (route_frames trace) index = Some frame /\
        In (ObservedTargetRegion region)
          (route_frame_observations frame)).
Proof.
  intros initial trace events final Haligned index region.
  split.
  - intros [event [Hevent Htarget_event]].
    inversion Htarget_event; subst.
    + eapply aligned_act3_event_to_observation; eauto.
    + eapply aligned_upper_event_to_observation; eauto.
  - intros [frame [Hframe Hobservation]].
    destruct region.
    + destruct (aligned_act3_observation_to_event
        initial trace events final Haligned index frame
        Hframe Hobservation) as [star [phase Hevent]].
      exists (EventCollectAct3 star phase). split; [exact Hevent |].
      constructor.
    + destruct (aligned_upper_observation_to_event
        initial trace events final Haligned index frame
        Hframe Hobservation) as [trigger_object [phase Hevent]].
      exists (EventConsumeTrigger TriggerUpper trigger_object phase).
      split; [exact Hevent |]. constructor.
Qed.

Definition truncate_route_frame_after
    (frame : RouteFrame) (observation_index : nat) : RouteFrame :=
  {| route_frame_input := route_frame_input frame;
     route_frame_observations :=
       firstn (S observation_index) (route_frame_observations frame) |}.

Definition route_prefix_through_observation
    (trace : RouteTrace) (frame_index observation_index : nat) : RouteTrace :=
  {| route_frames :=
      firstn frame_index (route_frames trace) ++
      match nth_error (route_frames trace) frame_index with
      | Some frame =>
          [truncate_route_frame_after frame observation_index]
      | None => []
      end |}.

Definition event_prefix_through_frame
    (events : list FrameEvent) (frame_index : nat) : list FrameEvent :=
  firstn (S frame_index) events.

(* A canonical paired prefix: the final route observation is the exact first
   target occurrence, and the final included event slot is its same-frame
   target event.  The equality fields make "prefix" computational rather than
   an unconstrained predicate. *)
Record FirstTargetObservationEventPrefix
    (trace prefix : RouteTrace)
    (events event_prefix : list FrameEvent)
    (region : TargetRouteRegion)
    (frame_index observation_index : nat) : Prop := {
  first_prefix_target :
    first_target_observation_at
      trace region frame_index observation_index;
  first_prefix_route_exact :
    prefix =
      route_prefix_through_observation trace frame_index observation_index;
  first_prefix_events_exact :
    event_prefix = event_prefix_through_frame events frame_index;
  first_prefix_target_event :
    exists event,
      nth_error events frame_index = Some event /\
      TargetEventForRegion region event
}.

Theorem aligned_first_target_has_exact_observation_event_prefix :
  forall initial trace events final region frame_index observation_index,
    RouteTraceExecutionAlignment initial trace events final ->
    first_target_observation_at
      trace region frame_index observation_index ->
    FirstTargetObservationEventPrefix
      trace
      (route_prefix_through_observation
        trace frame_index observation_index)
      events (event_prefix_through_frame events frame_index)
      region frame_index observation_index.
Proof.
  intros initial trace events final region frame_index observation_index
    Haligned Hfirst.
  constructor; [exact Hfirst | reflexivity | reflexivity |].
  apply (proj2 (aligned_target_event_iff_observation_at_same_frame
    initial trace events final Haligned frame_index region)).
  destruct Hfirst as
    [[frame [Hframe Hobservation]] Hno_earlier].
  exists frame. split; [exact Hframe |].
  eapply nth_error_In. exact Hobservation.
Qed.

Theorem realized_route_with_target_has_exact_first_prefix :
  forall initial trace,
    RealizedRouteTrace initial trace ->
    reaches_any_target_region trace ->
    exists final events region frame_index observation_index
        prefix event_prefix,
      RouteTraceExecutionAlignment initial trace events final /\
      FirstTargetObservationEventPrefix trace prefix events event_prefix
        region frame_index observation_index.
Proof.
  intros initial trace
    [final [events Haligned]] Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [frame_index [observation_index Hfirst]]].
  exists final, events, region, frame_index, observation_index,
    (route_prefix_through_observation trace frame_index observation_index),
    (event_prefix_through_frame events frame_index).
  split; [exact Haligned |].
  eapply aligned_first_target_has_exact_observation_event_prefix; eauto.
Qed.

Definition gate_a_press_precedes_exact_target
    (trace : RouteTrace) (gate : TranscriptRouteGate)
    (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop :=
  exists gate_frame gate_observation frame,
    nth_error (route_frames trace) gate_frame = Some frame /\
    nth_error (route_frame_observations frame) gate_observation =
      Some (ObservedGateAPress gate) /\
    a_button_pressed
      (frame_current_down (route_frame_input frame))
      (frame_previous_down (route_frame_input frame)) = true /\
    target_observation_at
      trace target_frame target_observation region /\
    route_position_precedes
      gate_frame gate_observation target_frame target_observation.

Definition upper_bypass_precedes_exact_target
    (trace : RouteTrace) (witness : UpperBypassWitness)
    (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop :=
  exists bypass_frame bypass_observation,
    exact_observation_precedes_target trace
      bypass_frame bypass_observation target_frame target_observation
      (ObservedUpperBypass witness) region.

Definition lower_bypass_precedes_exact_target
    (trace : RouteTrace) (witness : LowerBypassWitness)
    (region : TargetRouteRegion)
    (target_frame target_observation : nat) : Prop :=
  exists bypass_frame bypass_observation,
    exact_observation_precedes_target trace
      bypass_frame bypass_observation target_frame target_observation
      (ObservedLowerBypass witness) region.

Definition explicit_upper_bypass_observed
    (trace : RouteTrace) (witness : UpperBypassWitness) : Prop :=
  In (ObservedUpperBypass witness) (route_observations trace).

Definition explicit_lower_bypass_observed
    (trace : RouteTrace) (witness : LowerBypassWitness) : Prop :=
  In (ObservedLowerBypass witness) (route_observations trace).

Definition ExcludesAllUpperBypassWitnesses (trace : RouteTrace) : Prop :=
  forall witness, ~ explicit_upper_bypass_observed trace witness.

Definition ExcludesAllLowerBypassWitnesses (trace : RouteTrace) : Prop :=
  forall witness, ~ explicit_lower_bypass_observed trace witness.

(* These predicates currently exclude observation tags only.  They are not
   geometric or Clight non-reachability results. *)

Lemma exact_gate_a_press_is_trace_press :
  forall trace gate region target_frame target_observation,
    gate_a_press_precedes_exact_target
      trace gate region target_frame target_observation ->
    trace_contains_a_press trace.
Proof.
  intros trace gate region target_frame target_observation
    [gate_frame [gate_observation [frame
      [Hframe [Hgate [Hpressed [Htarget Hprecedes]]]]]]].
  exists frame. split.
  - eapply nth_error_In. exact Hframe.
  - exact Hpressed.
Qed.

Lemma upper_bypass_before_target_is_observed :
  forall trace witness region target_frame target_observation,
    upper_bypass_precedes_exact_target
      trace witness region target_frame target_observation ->
    explicit_upper_bypass_observed trace witness.
Proof.
  intros trace witness region target_frame target_observation
    [bypass_frame [bypass_observation
      [[frame [Hframe Hobservation]] [Htarget Hprecedes]]]].
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hframe.
  - eapply nth_error_In. exact Hobservation.
Qed.

Lemma lower_bypass_before_target_is_observed :
  forall trace witness region target_frame target_observation,
    lower_bypass_precedes_exact_target
      trace witness region target_frame target_observation ->
    explicit_lower_bypass_observed trace witness.
Proof.
  intros trace witness region target_frame target_observation
    [bypass_frame [bypass_observation
      [[frame [Hframe Hobservation]] [Htarget Hprecedes]]]].
  eapply route_frame_observation_is_observed.
  - eapply nth_error_In. exact Hframe.
  - eapply nth_error_In. exact Hobservation.
Qed.

(* This is a broad coverage premise, not a proved or narrow Layer-B result.
   Its classification fields already assume the gate-or-tag split used by the
   theorem below.  It is intentionally named [Obligation]: no theorem here
   derives it from the transcript, the abstract event model, Clight, or the
   collision mesh.  The payload-free tags above still need evidence semantics. *)
Record FirstTargetCutClassificationObligation
    (initial : GameState) (trace : RouteTrace) : Prop := {
  first_target_cut_clean_entry : CleanPyramidEntry initial;
  first_target_cut_input_history :
    coherent_input_history (state_entry_button_down initial)
      (route_inputs trace);
  first_target_cut_realized : RealizedRouteTrace initial trace;
  classify_upper_first_target :
    forall region target_frame target_observation,
      state_entrance initial = UpperEntrance ->
      first_target_observation_at
        trace region target_frame target_observation ->
      gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
        region target_frame target_observation \/
      exists witness,
        upper_bypass_precedes_exact_target trace witness
          region target_frame target_observation;
  classify_lower_first_target :
    forall region target_frame target_observation,
      state_entrance initial = LowerEntrance ->
      first_target_observation_at
        trace region target_frame target_observation ->
      gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
        region target_frame target_observation \/
      exists witness,
        lower_bypass_precedes_exact_target trace witness
          region target_frame target_observation
}.

Theorem first_target_access_requires_gate_a_or_explicit_bypass :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        (gate_a_press_precedes_exact_target trace ElevatorJumpOutGate
           region target_frame target_observation \/
         exists witness,
           upper_bypass_precedes_exact_target trace witness
             region target_frame target_observation)) \/
       (state_entrance initial = LowerEntrance /\
        (gate_a_press_precedes_exact_target trace SecondPoleJumpOffGate
           region target_frame target_observation \/
         exists witness,
           lower_bypass_precedes_exact_target trace witness
             region target_frame target_observation))).
Proof.
  intros initial trace Hcoverage Htarget.
  destruct (reaches_any_target_has_first_exact_occurrence trace Htarget)
    as [region [target_frame [target_observation Hfirst]]].
  exists region, target_frame, target_observation. split; [exact Hfirst |].
  destruct (state_entrance initial) eqn:Hentrance.
  - right. split; [reflexivity |].
    exact (classify_lower_first_target initial trace Hcoverage
      region target_frame target_observation Hentrance Hfirst).
  - left. split; [reflexivity |].
    exact (classify_upper_first_target initial trace Hcoverage
      region target_frame target_observation Hentrance Hfirst).
Qed.

Theorem first_target_access_with_all_bypasses_excluded_requires_a_edge :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    reaches_any_target_region trace ->
    ExcludesAllUpperBypassWitnesses trace ->
    ExcludesAllLowerBypassWitnesses trace ->
    trace_contains_a_press trace.
Proof.
  intros initial trace Hcoverage Htarget Hexclude_upper Hexclude_lower.
  destruct (first_target_access_requires_gate_a_or_explicit_bypass
    initial trace Hcoverage Htarget)
    as [region [target_frame [target_observation
      [Hfirst Hclassification]]]].
  destruct Hclassification as
    [[Hupper Hupper_case] | [Hlower Hlower_case]].
  - destruct Hupper_case as [Hpress | [witness Hbypass]].
    + eapply exact_gate_a_press_is_trace_press. exact Hpress.
    + exfalso. eapply (Hexclude_upper witness).
      eapply upper_bypass_before_target_is_observed. exact Hbypass.
  - destruct Hlower_case as [Hpress | [witness Hbypass]].
    + eapply exact_gate_a_press_is_trace_press. exact Hpress.
    + exfalso. eapply (Hexclude_lower witness).
      eapply lower_bypass_before_target_is_observed. exact Hbypass.
Qed.

Theorem no_a_first_target_access_requires_explicit_bypass :
  forall initial trace,
    FirstTargetCutClassificationObligation initial trace ->
    fewer_than_one_a_press (route_inputs trace) ->
    reaches_any_target_region trace ->
    exists region target_frame target_observation,
      first_target_observation_at
        trace region target_frame target_observation /\
      ((state_entrance initial = UpperEntrance /\
        exists witness,
          upper_bypass_precedes_exact_target trace witness
            region target_frame target_observation) \/
       (state_entrance initial = LowerEntrance /\
        exists witness,
          lower_bypass_precedes_exact_target trace witness
            region target_frame target_observation)).
Proof.
  intros initial trace Hcoverage Hnoa Htarget.
  destruct (first_target_access_requires_gate_a_or_explicit_bypass
    initial trace Hcoverage Htarget)
    as [region [target_frame [target_observation
      [Hfirst Hclassification]]]].
  destruct Hclassification as
    [[Hupper Hupper_case] | [Hlower Hlower_case]].
  - destruct Hupper_case as [Hpress | Hbypass].
    + exfalso.
      apply (no_a_trace_has_no_gate_a_press
        trace ElevatorJumpOutGate Hnoa).
      destruct Hpress as
        [gate_frame [gate_observation [frame
          [Hframe [Hgate [Hpressed [Htarget_at Hprecedes]]]]]]].
      exists frame. split.
      * eapply nth_error_In. exact Hframe.
      * split.
        -- eapply nth_error_In. exact Hgate.
        -- exact Hpressed.
    + exists region, target_frame, target_observation.
      split; [exact Hfirst |]. left. auto.
  - destruct Hlower_case as [Hpress | Hbypass].
    + exfalso.
      apply (no_a_trace_has_no_gate_a_press
        trace SecondPoleJumpOffGate Hnoa).
      destruct Hpress as
        [gate_frame [gate_observation [frame
          [Hframe [Hgate [Hpressed [Htarget_at Hprecedes]]]]]]].
      exists frame. split.
      * eapply nth_error_In. exact Hframe.
      * split.
        -- eapply nth_error_In. exact Hgate.
        -- exact Hpressed.
    + exists region, target_frame, target_observation.
      split; [exact Hfirst |]. right. auto.
Qed.

(* This record is the transcript's two-gate reduction, stated as an explicit
   obligation rather than asserted as a theorem of the imported C program.
   It says that access to either relevant target region must cross the gate
   selected by the clean entry: the elevator for the upper entrance, or the
   second-pole boundary for the lower entrance. *)
Record TranscriptRouteGateModel
    (initial : GameState) (trace : RouteTrace) : Prop := {
  transcript_route_clean_entry : CleanPyramidEntry initial;
  transcript_route_input_history :
    coherent_input_history (state_first_frame_previous_down_seed initial)
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
    coherent_input_history (state_first_frame_previous_down_seed initial)
      (route_inputs act3_complete)) /\
  (exists trigger_complete,
    RouteTraceExtensionToTarget
      prefix trigger_complete UpperHiddenStarTriggerNode /\
    RealizedRouteTrace initial trigger_complete /\
    fewer_than_one_a_press (route_inputs trigger_complete) /\
    coherent_input_history (state_first_frame_previous_down_seed initial)
      (route_inputs trigger_complete)).

(* These are precisely the transcript's "everything else is traversable"
   premises.  They are intentionally not proved here. *)
Definition UpperDownstreamCompleteness (initial : GameState) : Prop :=
  forall prefix,
    CleanPyramidEntry initial ->
    state_entrance initial = UpperEntrance ->
    coherent_input_history (state_first_frame_previous_down_seed initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    elevator_escape_observed prefix ->
    ZeroATargetRouteCapability initial prefix.

Definition LowerDownstreamCompleteness (initial : GameState) : Prop :=
  forall prefix,
    CleanPyramidEntry initial ->
    state_entrance initial = LowerEntrance ->
    coherent_input_history (state_first_frame_previous_down_seed initial)
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
    coherent_input_history (state_first_frame_previous_down_seed initial)
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
    coherent_input_history (state_first_frame_previous_down_seed initial)
      (route_inputs prefix) ->
    fewer_than_one_a_press (route_inputs prefix) ->
    above_second_pole_observed prefix ->
    ZeroATargetRouteCapability initial prefix.
Proof.
  intros initial prefix Hdownstream Hclean Hlower Hhistory Hnoa Habove.
  eapply Hdownstream; eauto.
Qed.
