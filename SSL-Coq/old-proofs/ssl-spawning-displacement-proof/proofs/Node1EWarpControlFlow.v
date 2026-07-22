From Coq Require Import Bool List ZArith Lia.
From SSLSpawning.Proofs Require Import GeneratedClightFacts SSLStartCloneRoute.

Import ListNotations.

Inductive node1e_object_ref : Type :=
| RefNone
| RefNode1E
| RefOrdinaryGrabbable
| RefOtherObject.

Inductive node1e_action : Type :=
| NodeActionPickingUp
| NodeActionPickingUpBowser
| NodeActionDisappeared
| NodeActionUninitialized
| NodeActionOther.

Inductive node1e_permanent_behavior : Type :=
| PermanentWarpBehavior
| PermanentOtherBehavior.

Inductive node1e_current_command : Type :=
| WarpLoopCommand
| CarrySomething3Command
| OtherCommand.

Record node1e_control_state : Type := {
  node1e_held : node1e_object_ref;
  node1e_used : node1e_object_ref;
  node1e_interact : node1e_object_ref;
  node1e_ridden : node1e_object_ref;
  node1e_action_state : node1e_action;
  node1e_behavior : node1e_permanent_behavior;
  node1e_command : node1e_current_command;
  node1e_mario_loaded : bool;
  node1e_action_dispatch_enabled : bool
}.

Definition stock_node1e_initial_state : node1e_control_state := {|
  node1e_held := RefNone;
  node1e_used := RefNone;
  node1e_interact := RefNone;
  node1e_ridden := RefNone;
  node1e_action_state := NodeActionOther;
  node1e_behavior := PermanentWarpBehavior;
  node1e_command := WarpLoopCommand;
  node1e_mario_loaded := true;
  node1e_action_dispatch_enabled := true
|}.

Definition node1e_warp_interaction
    (state : node1e_control_state) : node1e_control_state := {|
  node1e_held := node1e_held state;
  node1e_used := RefNode1E;
  node1e_interact := RefNode1E;
  node1e_ridden := RefNone;
  node1e_action_state := NodeActionDisappeared;
  node1e_behavior := node1e_behavior state;
  node1e_command := node1e_command state;
  node1e_mario_loaded := node1e_mario_loaded state;
  node1e_action_dispatch_enabled := node1e_action_dispatch_enabled state
|}.

Definition grab_used_object_model
    (state : node1e_control_state) : node1e_control_state :=
  match node1e_held state with
  | RefNone => {|
      node1e_held := node1e_used state;
      node1e_used := node1e_used state;
      node1e_interact := node1e_interact state;
      node1e_ridden := node1e_ridden state;
      node1e_action_state := node1e_action_state state;
      node1e_behavior := node1e_behavior state;
      node1e_command :=
        match node1e_used state with
        | RefNode1E => CarrySomething3Command
        | _ => node1e_command state
        end;
      node1e_mario_loaded := node1e_mario_loaded state;
      node1e_action_dispatch_enabled :=
        node1e_action_dispatch_enabled state
    |}
  | _ => state
  end.

Definition dispatch_current_action
    (state : node1e_control_state) : node1e_control_state :=
  if node1e_mario_loaded state && node1e_action_dispatch_enabled state
  then
    match node1e_action_state state with
    | NodeActionPickingUp => grab_used_object_model state
    | NodeActionPickingUpBowser => grab_used_object_model state
    | _ => state
    end
  else state.

Definition node1e_warp_frame
    (state : node1e_control_state) : node1e_control_state :=
  dispatch_current_action (node1e_warp_interaction state).

Definition act_flag_intangible : Z := 4096.
Definition act_disappeared_value : Z := 4864.

Theorem act_disappeared_has_intangible_flag :
  Z.land act_disappeared_value act_flag_intangible = act_flag_intangible.
Proof.
  vm_compute.
  reflexivity.
Qed.

Theorem node1e_warp_interaction_sets_used_and_interact :
  forall state,
    node1e_used (node1e_warp_interaction state) = RefNode1E /\
    node1e_interact (node1e_warp_interaction state) = RefNode1E /\
    node1e_action_state (node1e_warp_interaction state) =
      NodeActionDisappeared.
Proof.
  intros state.
  repeat split; reflexivity.
Qed.

Theorem node1e_warp_frame_preserves_held_and_command :
  forall state,
    node1e_held (node1e_warp_frame state) = node1e_held state /\
    node1e_command (node1e_warp_frame state) = node1e_command state.
Proof.
  intros
    [held used interact ridden action behavior command loaded dispatch].
  unfold node1e_warp_frame, dispatch_current_action,
    node1e_warp_interaction.
  cbn.
  destruct loaded, dispatch; split; reflexivity.
Qed.

Theorem warp_touch_used_pointer_is_a_pickup_dead_end :
  forall state,
    node1e_held state <> RefNode1E ->
    node1e_command state = WarpLoopCommand ->
    node1e_used (node1e_warp_frame state) = RefNode1E /\
    node1e_interact (node1e_warp_frame state) = RefNode1E /\
    node1e_held (node1e_warp_frame state) <> RefNode1E /\
    node1e_command (node1e_warp_frame state) = WarpLoopCommand.
Proof.
  intros state Hheld Hcommand.
  destruct (node1e_warp_frame_preserves_held_and_command state)
    as [Hheld_preserved Hcommand_preserved].
  repeat split.
  - destruct state as
      [held used interact ridden action behavior command loaded dispatch].
    unfold node1e_warp_frame, dispatch_current_action,
      node1e_warp_interaction.
    cbn.
    destruct loaded, dispatch; reflexivity.
  - destruct state as
      [held used interact ridden action behavior command loaded dispatch].
    unfold node1e_warp_frame, dispatch_current_action,
      node1e_warp_interaction.
    cbn.
    destruct loaded, dispatch; reflexivity.
  - rewrite Hheld_preserved.
    exact Hheld.
  - rewrite Hcommand_preserved.
    exact Hcommand.
Qed.

Definition ordinary_grabbable_interaction
    (state : node1e_control_state) : node1e_control_state := {|
  node1e_held := node1e_held state;
  node1e_used := RefOrdinaryGrabbable;
  node1e_interact := RefOrdinaryGrabbable;
  node1e_ridden := node1e_ridden state;
  node1e_action_state := NodeActionPickingUp;
  node1e_behavior := node1e_behavior state;
  node1e_command := node1e_command state;
  node1e_mario_loaded := node1e_mario_loaded state;
  node1e_action_dispatch_enabled := node1e_action_dispatch_enabled state
|}.

(* The generated table puts warp at index 4 and grabbable at index 29; the
   successful warp handler breaks the loop, so the grabbable handler is not
   applied to the same collision set. *)
Definition simultaneous_warp_and_grabbable_interactions
    (state : node1e_control_state) : node1e_control_state :=
  node1e_warp_interaction state.

Theorem simultaneous_grabbable_does_not_overwrite_node1e_warp_result :
  forall state,
    node1e_used (simultaneous_warp_and_grabbable_interactions state) =
      RefNode1E /\
    node1e_action_state
      (simultaneous_warp_and_grabbable_interactions state) =
      NodeActionDisappeared.
Proof.
  intros state.
  split; reflexivity.
Qed.

Definition water_grab_model
    (state : node1e_control_state) : node1e_control_state :=
  grab_used_object_model (ordinary_grabbable_interaction state).

Theorem water_grab_cannot_select_warp_only_node1e :
  forall state,
    node1e_held state <> RefNode1E ->
    node1e_held (water_grab_model state) <> RefNode1E.
Proof.
  intros
    [held used interact ridden action behavior command loaded dispatch] Hheld.
  unfold water_grab_model, ordinary_grabbable_interaction,
    grab_used_object_model.
  cbn in *.
  destruct held; cbn in *; congruence.
Qed.

Definition load_area_reusing_old_held_slot
    (state : node1e_control_state) : node1e_control_state := {|
  node1e_held := RefNode1E;
  node1e_used := node1e_used state;
  node1e_interact := node1e_interact state;
  node1e_ridden := node1e_ridden state;
  node1e_action_state := node1e_action_state state;
  node1e_behavior := PermanentWarpBehavior;
  node1e_command := WarpLoopCommand;
  node1e_mario_loaded := false;
  node1e_action_dispatch_enabled := false
|}.

Definition init_mario_after_area_change_model
    (state : node1e_control_state) : node1e_control_state := {|
  node1e_held := RefNone;
  node1e_used := RefNone;
  node1e_interact := RefOtherObject;
  node1e_ridden := RefNone;
  node1e_action_state := NodeActionOther;
  node1e_behavior := node1e_behavior state;
  node1e_command := node1e_command state;
  node1e_mario_loaded := true;
  node1e_action_dispatch_enabled := true
|}.

Definition normal_area_change_with_slot_reuse
    (state : node1e_control_state) : node1e_control_state :=
  init_mario_after_area_change_model
    (load_area_reusing_old_held_slot state).

Definition can_drop_node1e (state : node1e_control_state) : Prop :=
  node1e_held state = RefNode1E /\
  node1e_mario_loaded state = true /\
  node1e_action_dispatch_enabled state = true.

Theorem normal_area_change_clears_reused_held_alias_before_control :
  forall state,
    node1e_held (normal_area_change_with_slot_reuse state) = RefNone /\
    node1e_used (normal_area_change_with_slot_reuse state) = RefNone /\
    node1e_ridden (normal_area_change_with_slot_reuse state) = RefNone /\
    ~ can_drop_node1e (normal_area_change_with_slot_reuse state).
Proof.
  intros state.
  repeat split; try reflexivity.
  intros [Hheld _].
  discriminate Hheld.
Qed.

Definition action_zero_area_change_with_slot_reuse
    (state : node1e_control_state) : node1e_control_state :=
  let loaded := load_area_reusing_old_held_slot state in {|
    node1e_held := node1e_held loaded;
    node1e_used := node1e_used loaded;
    node1e_interact := node1e_interact loaded;
    node1e_ridden := node1e_ridden loaded;
    node1e_action_state := NodeActionUninitialized;
    node1e_behavior := node1e_behavior loaded;
    node1e_command := node1e_command loaded;
    node1e_mario_loaded := false;
    node1e_action_dispatch_enabled := false
  |}.

Theorem action_zero_can_preserve_alias_but_cannot_execute_drop :
  forall state,
    node1e_held (action_zero_area_change_with_slot_reuse state) = RefNode1E /\
    node1e_mario_loaded
      (action_zero_area_change_with_slot_reuse state) = false /\
    node1e_action_dispatch_enabled
      (action_zero_area_change_with_slot_reuse state) = false /\
    ~ can_drop_node1e (action_zero_area_change_with_slot_reuse state).
Proof.
  intros state.
  repeat split; try reflexivity.
  intros [_ [Hloaded _]].
  discriminate Hloaded.
Qed.

Definition set_node1e_current_command
    (state : node1e_control_state) (command : node1e_current_command)
    : node1e_control_state := {|
  node1e_held := node1e_held state;
  node1e_used := node1e_used state;
  node1e_interact := node1e_interact state;
  node1e_ridden := node1e_ridden state;
  node1e_action_state := node1e_action_state state;
  node1e_behavior := node1e_behavior state;
  node1e_command := command;
  node1e_mario_loaded := node1e_mario_loaded state;
  node1e_action_dispatch_enabled := node1e_action_dispatch_enabled state
|}.

Definition obj_set_held_state_on_mario_held_object
    (state : node1e_control_state) : node1e_control_state :=
  match node1e_held state with
  | RefNode1E =>
      set_node1e_current_command state CarrySomething3Command
  | _ => state
  end.

Theorem redirecting_node1e_command_requires_held_node1e :
  forall state,
    node1e_command state = WarpLoopCommand ->
    node1e_command (obj_set_held_state_on_mario_held_object state) =
      CarrySomething3Command ->
    node1e_held state = RefNode1E.
Proof.
  intros
    [held used interact ridden action behavior command loaded dispatch]
    Hcommand Hredirect.
  unfold obj_set_held_state_on_mario_held_object,
    set_node1e_current_command in Hredirect.
  cbn in *.
  destruct held; cbn in *; congruence.
Qed.

Theorem hypothetical_held_node1e_redirect_preserves_permanent_behavior :
  forall state,
    node1e_held state = RefNode1E ->
    node1e_behavior state = PermanentWarpBehavior ->
    node1e_command (obj_set_held_state_on_mario_held_object state) =
      CarrySomething3Command /\
    node1e_behavior (obj_set_held_state_on_mario_held_object state) =
      PermanentWarpBehavior.
Proof.
  intros
    [held used interact ridden action behavior command loaded dispatch]
    Hheld Hbehavior.
  cbn in *.
  subst held behavior.
  split; reflexivity.
Qed.

Definition node1e_warp_loop_model
    (state : node1e_control_state) : node1e_control_state := state.

Theorem node1e_warp_loop_does_not_self_redirect :
  forall state,
    node1e_command (node1e_warp_loop_model state) = node1e_command state /\
    node1e_behavior (node1e_warp_loop_model state) = node1e_behavior state.
Proof.
  intros state.
  split; reflexivity.
Qed.

Inductive enumerated_node1e_relocation_route : Type :=
| RouteWarpUsedThenPickup
| RouteSimultaneousWarpAndGrab
| RouteNormalStaleHeldSlotReuse
| RouteActionZeroStaleHeldSlotReuse
| RouteIndependentHeldStateRedirect
| RouteWarpBehaviorSelfRedirect.

Definition enumerated_node1e_route_succeeds
    (route : enumerated_node1e_relocation_route) : Prop :=
  match route with
  | RouteWarpUsedThenPickup =>
      node1e_held (node1e_warp_frame stock_node1e_initial_state) = RefNode1E
  | RouteSimultaneousWarpAndGrab =>
      node1e_held
        (dispatch_current_action
          (simultaneous_warp_and_grabbable_interactions
            stock_node1e_initial_state)) = RefNode1E
  | RouteNormalStaleHeldSlotReuse =>
      can_drop_node1e
        (normal_area_change_with_slot_reuse stock_node1e_initial_state)
  | RouteActionZeroStaleHeldSlotReuse =>
      can_drop_node1e
        (action_zero_area_change_with_slot_reuse stock_node1e_initial_state)
  | RouteIndependentHeldStateRedirect =>
      node1e_command
        (obj_set_held_state_on_mario_held_object stock_node1e_initial_state) =
        CarrySomething3Command
  | RouteWarpBehaviorSelfRedirect =>
      node1e_command
        (node1e_warp_loop_model stock_node1e_initial_state) =
        CarrySomething3Command
  end.

Theorem no_enumerated_stock_route_holds_or_redirects_node1e :
  forall route, ~ enumerated_node1e_route_succeeds route.
Proof.
  intros route.
  destruct route; cbn.
  - discriminate.
  - discriminate.
  - intros [Hheld _].
    discriminate Hheld.
  - intros [_ [Hloaded _]].
    discriminate Hloaded.
  - discriminate.
  - discriminate.
Qed.

Theorem generated_jp_clight_node1e_control_flow_capstone :
  jp_node1e_control_flow_source_certificate /\
  (forall route, ~ enumerated_node1e_route_succeeds route).
Proof.
  split.
  - apply generated_jp_node1e_control_flow_source_certificate.
  - apply no_enumerated_stock_route_holds_or_redirects_node1e.
Qed.

(* This theorem does not exclude arbitrary writes, ACE, hardware faults, or
   stale gMarioPlatform slot aliasing. It closes only the constructors above,
   which correspond to the audited stock held-object/behavior-command routes. *)
