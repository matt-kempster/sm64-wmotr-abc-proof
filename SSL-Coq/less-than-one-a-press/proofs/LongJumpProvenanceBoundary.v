(** Long-jump provenance boundary for VERSION_US and VERSION_JP.

    This file proves two deliberately separate things.

    First, it computes source-shape receipts over the generated Clight for the
    ordinary long-jump cycle.  In both selected versions:

    - the crouch-slide constructor of [ACT_LONG_JUMP] is beneath the
      edge-triggered input bit;
    - the airborne dispatcher maps [ACT_LONG_JUMP] to [act_long_jump];
    - [act_long_jump] is the only function in its translation unit which
      passes [ACT_LONG_JUMP_LAND] to [common_air_action_step];
    - the moving dispatcher maps [ACT_LONG_JUMP_LAND] to
      [act_long_jump_land]; and
    - the landing wrapper supplies the writable long-jump descriptor, whose
      A-pressed field initially contains [ACT_LONG_JUMP], to a callback that
      is invoked beneath the same edge-triggered input bit.

    Second, it proves a first-occurrence theorem for the transition kernel
    exposed by those receipts.  Starting from a non-target action, a trace
    with neither an A edge nor a forged transition cannot acquire either
    long-jump action.

    This is not yet a linked-retail reachability theorem.  The generated-AST
    results are syntactic.  The definitions at the end name the remaining
    semantic interfaces: whole-program transition classification, live entry
    memory, interaction-table closure, descriptor preservation, pointer/OOB
    exclusion, and external-call frames.  None is assumed by a theorem in
    this file. *)

From Coq Require Import Bool List Lia ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_mario_actions_airborne us_mario_actions_moving
  jp_mario_actions_airborne jp_mario_actions_moving.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module LJ_USAir := us_mario_actions_airborne.
Module LJ_USMove := us_mario_actions_moving.
Module LJ_JPAir := jp_mario_actions_airborne.
Module LJ_JPMove := jp_mario_actions_moving.

Definition act_long_jump : Z := 50333832.
Definition act_long_jump_land : Z := 1145.
Definition act_spawn_spin_airborne : Z := 6436.
Definition act_spawn_no_spin_airborne : Z := 6450.

Definition long_jump_target (action : Z) : Prop :=
  action = act_long_jump \/ action = act_long_jump_land.

Definition non_long_jump_target (action : Z) : Prop :=
  ~ long_jump_target action.

Lemma spin_airborne_is_not_long_jump_target :
  non_long_jump_target act_spawn_spin_airborne.
Proof.
  unfold non_long_jump_target, long_jump_target,
    act_spawn_spin_airborne, act_long_jump, act_long_jump_land.
  lia.
Qed.

Lemma no_spin_airborne_is_not_long_jump_target :
  non_long_jump_target act_spawn_no_spin_airborne.
Proof.
  unfold non_long_jump_target, long_jump_target,
    act_spawn_no_spin_airborne, act_long_jump, act_long_jump_land.
  lia.
Qed.

(** Match [common_air_action_step(m, landing, animation, 1)].  The animation
    expression is deliberately unrestricted; the receipt couples the
    function, landing action, and final argument at one call site. *)
Definition is_air_landing_call_s
    (callee : ident) (landing_action : Z) (statement : statement) : bool :=
  match statement with
  | Scall _ (Evar found_callee _)
      [Etempvar _ _; Econst_int found_landing _; _;
       Econst_int found_final _] =>
      Pos.eqb found_callee callee &&
      Int.eq found_landing (Int.repr landing_action) &&
      Int.eq found_final (Int.repr 1)
  | _ => false
  end.

Fixpoint contains_air_landing_call_s
    (callee : ident) (landing_action : Z) (statement : statement) : bool :=
  is_air_landing_call_s callee landing_action statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      contains_air_landing_call_s callee landing_action first ||
      contains_air_landing_call_s callee landing_action second
  | Sifthenelse _ yes_branch no_branch =>
      contains_air_landing_call_s callee landing_action yes_branch ||
      contains_air_landing_call_s callee landing_action no_branch
  | Sswitch _ cases =>
      contains_air_landing_call_ls callee landing_action cases
  | Slabel _ body =>
      contains_air_landing_call_s callee landing_action body
  | _ => false
  end
with contains_air_landing_call_ls
    (callee : ident) (landing_action : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_air_landing_call_s callee landing_action body ||
      contains_air_landing_call_ls callee landing_action rest
  end.

Fixpoint internal_air_landing_call_sites
    (callee : ident) (landing_action : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if contains_air_landing_call_s
           callee landing_action (fn_body body)
      then id :: internal_air_landing_call_sites callee landing_action rest
      else internal_air_landing_call_sites callee landing_action rest
  | _ :: rest =>
      internal_air_landing_call_sites callee landing_action rest
  end.

Fixpoint internal_two_literal_call_sites
    (callee : ident) (second third : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_ident_with_two_int_literals_s
           callee second third (fn_body body)
      then id :: internal_two_literal_call_sites callee second third rest
      else internal_two_literal_call_sites callee second third rest
  | _ :: rest =>
      internal_two_literal_call_sites callee second third rest
  end.

(** Couple the load of [m->input], bit test, and exact constructor call. *)
Definition is_field_mask_guarded_two_literal_call_s
    (field : ident) (mask : Z)
    (callee : ident) (second third : Z)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset loaded
        (Efield (Ederef (Etempvar _ _) _) found_field _))
      (Sifthenelse
        (Ebinop Oand (Etempvar tested _) (Econst_int found_mask _) _)
        yes_branch _) =>
      Pos.eqb found_field field &&
      Pos.eqb loaded tested &&
      Int.eq found_mask (Int.repr mask) &&
      calls_ident_with_two_int_literals_s
        callee second third yes_branch
  | _ => false
  end.

Fixpoint contains_field_mask_guarded_two_literal_call_s
    (field : ident) (mask : Z)
    (callee : ident) (second third : Z)
    (statement : statement) : bool :=
  is_field_mask_guarded_two_literal_call_s
    field mask callee second third statement ||
  match statement with
  | Ssequence first next | Sloop first next =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third first ||
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third next
  | Sifthenelse _ yes_branch no_branch =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third yes_branch ||
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third no_branch
  | Sswitch _ cases =>
      contains_field_mask_guarded_two_literal_call_ls
        field mask callee second third cases
  | Slabel _ body =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third body
  | _ => false
  end
with contains_field_mask_guarded_two_literal_call_ls
    (field : ident) (mask : Z)
    (callee : ident) (second third : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee second third body ||
      contains_field_mask_guarded_two_literal_call_ls
        field mask callee second third rest
  end.

(** Match the landing wrapper's exact descriptor and callback arguments. *)
Definition is_landing_wrapper_call_s
    (callee descriptor callback : ident) (statement : statement) : bool :=
  match statement with
  | Scall _ (Evar found_callee _)
      [Etempvar _ _;
       Eaddrof (Evar found_descriptor _) _;
       Evar found_callback _] =>
      Pos.eqb found_callee callee &&
      Pos.eqb found_descriptor descriptor &&
      Pos.eqb found_callback callback
  | _ => false
  end.

Fixpoint contains_landing_wrapper_call_s
    (callee descriptor callback : ident)
    (statement : statement) : bool :=
  is_landing_wrapper_call_s callee descriptor callback statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      contains_landing_wrapper_call_s callee descriptor callback first ||
      contains_landing_wrapper_call_s callee descriptor callback second
  | Sifthenelse _ yes_branch no_branch =>
      contains_landing_wrapper_call_s
        callee descriptor callback yes_branch ||
      contains_landing_wrapper_call_s
        callee descriptor callback no_branch
  | Sswitch _ cases =>
      contains_landing_wrapper_call_ls callee descriptor callback cases
  | Slabel _ body =>
      contains_landing_wrapper_call_s callee descriptor callback body
  | _ => false
  end
with contains_landing_wrapper_call_ls
    (callee descriptor callback : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_landing_wrapper_call_s callee descriptor callback body ||
      contains_landing_wrapper_call_ls callee descriptor callback rest
  end.

(** Couple [landingAction->aPressedAction] to the second argument of the
    indirect callback. *)
Definition is_descriptor_field_indirect_call_s
    (field : ident) (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset loaded
        (Efield (Ederef (Etempvar _ _) _) found_field _))
      (Scall _ (Etempvar _ _)
        [Etempvar _ _; Etempvar argument _;
         Econst_int found_zero _]) =>
      Pos.eqb found_field field &&
      Pos.eqb loaded argument &&
      Int.eq found_zero (Int.repr 0)
  | _ => false
  end.

Fixpoint contains_descriptor_field_indirect_call_s
    (field : ident) (statement : statement) : bool :=
  is_descriptor_field_indirect_call_s field statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      contains_descriptor_field_indirect_call_s field first ||
      contains_descriptor_field_indirect_call_s field second
  | Sifthenelse _ yes_branch no_branch =>
      contains_descriptor_field_indirect_call_s field yes_branch ||
      contains_descriptor_field_indirect_call_s field no_branch
  | Sswitch _ cases =>
      contains_descriptor_field_indirect_call_ls field cases
  | Slabel _ body =>
      contains_descriptor_field_indirect_call_s field body
  | _ => false
  end
with contains_descriptor_field_indirect_call_ls
    (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_descriptor_field_indirect_call_s field body ||
      contains_descriptor_field_indirect_call_ls field rest
  end.

Definition is_input_guarded_descriptor_indirect_call_s
    (input_field descriptor_field : ident) (mask : Z)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Sset loaded
        (Efield (Ederef (Etempvar _ _) _) found_input _))
      (Sifthenelse
        (Ebinop Oand (Etempvar tested _) (Econst_int found_mask _) _)
        yes_branch _) =>
      Pos.eqb found_input input_field &&
      Pos.eqb loaded tested &&
      Int.eq found_mask (Int.repr mask) &&
      contains_descriptor_field_indirect_call_s
        descriptor_field yes_branch
  | _ => false
  end.

Fixpoint contains_input_guarded_descriptor_indirect_call_s
    (input_field descriptor_field : ident) (mask : Z)
    (statement : statement) : bool :=
  is_input_guarded_descriptor_indirect_call_s
    input_field descriptor_field mask statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask first ||
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask second
  | Sifthenelse _ yes_branch no_branch =>
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask yes_branch ||
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask no_branch
  | Sswitch _ cases =>
      contains_input_guarded_descriptor_indirect_call_ls
        input_field descriptor_field mask cases
  | Slabel _ body =>
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask body
  | _ => false
  end
with contains_input_guarded_descriptor_indirect_call_ls
    (input_field descriptor_field : ident) (mask : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_input_guarded_descriptor_indirect_call_s
        input_field descriptor_field mask body ||
      contains_input_guarded_descriptor_indirect_call_ls
        input_field descriptor_field mask rest
  end.

Record landing_descriptor_projection := {
  descriptor_num_frames : Z;
  descriptor_aux_frames : Z;
  descriptor_steep_action : Z;
  descriptor_end_action : Z;
  descriptor_a_pressed_action : Z;
  descriptor_off_floor_action : Z;
  descriptor_slide_action : Z
}.

Definition project_landing_descriptor
    (variable : globvar type) : option landing_descriptor_projection :=
  match gvar_init variable with
  | [Init_int16 frames; Init_int16 aux;
     Init_int32 steep; Init_int32 ending; Init_int32 a_pressed;
     Init_int32 off_floor; Init_int32 slide] =>
      Some {| descriptor_num_frames := Int.signed frames;
              descriptor_aux_frames := Int.signed aux;
              descriptor_steep_action := Int.unsigned steep;
              descriptor_end_action := Int.unsigned ending;
              descriptor_a_pressed_action := Int.unsigned a_pressed;
              descriptor_off_floor_action := Int.unsigned off_floor;
              descriptor_slide_action := Int.unsigned slide |}
  | _ => None
  end.

Definition descriptor_frame_count
    (variable : globvar type) : option Z :=
  match project_landing_descriptor variable with
  | Some descriptor => Some (descriptor_num_frames descriptor)
  | None => None
  end.

Definition us_landing_descriptors : list (globvar type) :=
  [LJ_USMove.v_sJumpLandAction;
   LJ_USMove.v_sFreefallLandAction;
   LJ_USMove.v_sSideFlipLandAction;
   LJ_USMove.v_sHoldJumpLandAction;
   LJ_USMove.v_sHoldFreefallLandAction;
   LJ_USMove.v_sLongJumpLandAction;
   LJ_USMove.v_sDoubleJumpLandAction;
   LJ_USMove.v_sTripleJumpLandAction;
   LJ_USMove.v_sBackflipLandAction].

Definition jp_landing_descriptors : list (globvar type) :=
  [LJ_JPMove.v_sJumpLandAction;
   LJ_JPMove.v_sFreefallLandAction;
   LJ_JPMove.v_sSideFlipLandAction;
   LJ_JPMove.v_sHoldJumpLandAction;
   LJ_JPMove.v_sHoldFreefallLandAction;
   LJ_JPMove.v_sLongJumpLandAction;
   LJ_JPMove.v_sDoubleJumpLandAction;
   LJ_JPMove.v_sTripleJumpLandAction;
   LJ_JPMove.v_sBackflipLandAction].

Definition expected_landing_frame_counts : list (option Z) :=
  [Some 4; Some 4; Some 4; Some 4; Some 4;
   Some 6; Some 4; Some 4; Some 4].

Definition expected_long_jump_descriptor : landing_descriptor_projection :=
  {| descriptor_num_frames := 6;
     descriptor_aux_frames := 5;
     descriptor_steep_action := 16779404;
     descriptor_end_action := 134218299;
     descriptor_a_pressed_action := act_long_jump;
     descriptor_off_floor_action := 16779404;
     descriptor_slide_action := 80 |}.

Theorem us_jp_landing_descriptor_frames_source_receipt :
  map descriptor_frame_count us_landing_descriptors =
    expected_landing_frame_counts /\
  map descriptor_frame_count jp_landing_descriptors =
    expected_landing_frame_counts.
Proof. vm_compute; split; reflexivity. Qed.

Theorem us_jp_long_jump_descriptor_payload_source_receipt :
  project_landing_descriptor LJ_USMove.v_sLongJumpLandAction =
    Some expected_long_jump_descriptor /\
  project_landing_descriptor LJ_JPMove.v_sLongJumpLandAction =
    Some expected_long_jump_descriptor /\
  gvar_readonly LJ_USMove.v_sLongJumpLandAction = false /\
  gvar_readonly LJ_JPMove.v_sLongJumpLandAction = false.
Proof. vm_compute; repeat split; reflexivity. Qed.

Definition bilateral_long_jump_source_chain_claim : Prop :=
  (** The only exact constructor call in each moving unit. *)
  internal_two_literal_call_sites
    LJ_USMove._set_jumping_action act_long_jump 0
    (prog_defs LJ_USMove.prog) = [LJ_USMove._act_crouch_slide] /\
  internal_two_literal_call_sites
    LJ_JPMove._set_jumping_action act_long_jump 0
    (prog_defs LJ_JPMove.prog) = [LJ_JPMove._act_crouch_slide] /\
  (** That constructor is lexically beneath [INPUT_A_PRESSED = 2]. *)
  contains_field_mask_guarded_two_literal_call_s
    LJ_USMove._input 2 LJ_USMove._set_jumping_action act_long_jump 0
    (fn_body LJ_USMove.f_act_crouch_slide) = true /\
  contains_field_mask_guarded_two_literal_call_s
    LJ_JPMove._input 2 LJ_JPMove._set_jumping_action act_long_jump 0
    (fn_body LJ_JPMove.f_act_crouch_slide) = true /\
  (** Dispatch of the two target actions. *)
  switch_case_calls_ident_s act_long_jump LJ_USAir._act_long_jump
    (fn_body LJ_USAir.f_mario_execute_airborne_action) = true /\
  switch_case_calls_ident_s act_long_jump LJ_JPAir._act_long_jump
    (fn_body LJ_JPAir.f_mario_execute_airborne_action) = true /\
  switch_case_calls_ident_s act_long_jump_land LJ_USMove._act_long_jump_land
    (fn_body LJ_USMove.f_mario_execute_moving_action) = true /\
  switch_case_calls_ident_s act_long_jump_land LJ_JPMove._act_long_jump_land
    (fn_body LJ_JPMove.f_mario_execute_moving_action) = true /\
  (** Only [act_long_jump] passes 1145 to the airborne helper in-unit. *)
  internal_air_landing_call_sites
    LJ_USAir._common_air_action_step act_long_jump_land
    (prog_defs LJ_USAir.prog) = [LJ_USAir._act_long_jump] /\
  internal_air_landing_call_sites
    LJ_JPAir._common_air_action_step act_long_jump_land
    (prog_defs LJ_JPAir.prog) = [LJ_JPAir._act_long_jump] /\
  (** The landing wrapper supplies the target descriptor and callback. *)
  contains_landing_wrapper_call_s
    LJ_USMove._common_landing_cancels
    LJ_USMove._sLongJumpLandAction LJ_USMove._set_jumping_action
    (fn_body LJ_USMove.f_act_long_jump_land) = true /\
  contains_landing_wrapper_call_s
    LJ_JPMove._common_landing_cancels
    LJ_JPMove._sLongJumpLandAction LJ_JPMove._set_jumping_action
    (fn_body LJ_JPMove.f_act_long_jump_land) = true /\
  (** Its indirect A callback reads the descriptor field under input bit 2. *)
  contains_input_guarded_descriptor_indirect_call_s
    LJ_USMove._input LJ_USMove._aPressedAction 2
    (fn_body LJ_USMove.f_common_landing_cancels) = true /\
  contains_input_guarded_descriptor_indirect_call_s
    LJ_JPMove._input LJ_JPMove._aPressedAction 2
    (fn_body LJ_JPMove.f_common_landing_cancels) = true.

Theorem bilateral_long_jump_source_chain_checked :
  bilateral_long_jump_source_chain_claim.
Proof.
  unfold bilateral_long_jump_source_chain_claim.
  vm_compute; repeat split.
Qed.

(** A small transition kernel for the first-occurrence argument.  [Forge]
    is not a game transition: it records exactly the semantic escape classes
    that the linked proof still has to eliminate. *)
Inductive retail_version := VersionUS | VersionJP.

Inductive clean_entry_kind :=
| Area1LevelEntry
| PyramidLowerEntry
| PyramidUpperEntry.

Definition expected_clean_entry_action (entry : clean_entry_kind) : Z :=
  match entry with
  | Area1LevelEntry => act_spawn_spin_airborne
  | PyramidLowerEntry | PyramidUpperEntry => act_spawn_no_spin_airborne
  end.

Lemma expected_clean_entry_action_is_safe :
  forall entry,
    non_long_jump_target (expected_clean_entry_action entry).
Proof.
  destruct entry; simpl;
    [exact spin_airborne_is_not_long_jump_target |
     exact no_spin_airborne_is_not_long_jump_target |
     exact no_spin_airborne_is_not_long_jump_target].
Qed.

Inductive forged_action_cause :=
| ForgeLandingDescriptorPayload
| ForgeInteractionDispatchTarget
| ForgeIndirectCallbackTarget
| ForgeMarioStatePointerAlias
| ForgeOutOfBoundsStore
| ForgeExternalCallMemory
| ForgeUnclassifiedInternalWriter.

Definition all_forged_action_causes : list forged_action_cause :=
  [ForgeLandingDescriptorPayload;
   ForgeInteractionDispatchTarget;
   ForgeIndirectCallbackTarget;
   ForgeMarioStatePointerAlias;
   ForgeOutOfBoundsStore;
   ForgeExternalCallMemory;
   ForgeUnclassifiedInternalWriter].

Lemma all_forged_action_causes_complete :
  forall cause, In cause all_forged_action_causes.
Proof.
  destruct cause; unfold all_forged_action_causes; cbn; tauto.
Qed.

Inductive action_event :=
| OrdinaryActionPreservation
| InstantWarpActionPreservation
| CleanEntryReset (entry : clean_entry_kind)
| PyramidObjectWarpReset
| DirectNonTargetInstall (action : Z)
| CrouchSlideLongJumpConstructor
| LongJumpAirLanding
| LongJumpLandingAPressedCallback
| ForgedActionInstall
    (cause : forged_action_cause) (a_edge : bool) (action : Z).

Definition event_has_a_edge (event : action_event) : bool :=
  match event with
  | CrouchSlideLongJumpConstructor
  | LongJumpLandingAPressedCallback => true
  | ForgedActionInstall _ edge _ => edge
  | _ => false
  end.

Definition event_is_forged (event : action_event) : bool :=
  match event with
  | ForgedActionInstall _ _ _ => true
  | _ => false
  end.

Inductive source_action_step : action_event -> Z -> Z -> Prop :=
| StepOrdinaryPreserve :
    forall action,
      source_action_step OrdinaryActionPreservation action action
| StepInstantWarpPreserve :
    forall action,
      source_action_step InstantWarpActionPreservation action action
| StepCleanEntryReset :
    forall before entry,
      source_action_step (CleanEntryReset entry) before
        (expected_clean_entry_action entry)
| StepPyramidObjectWarpReset :
    forall before,
      source_action_step PyramidObjectWarpReset before
        act_spawn_no_spin_airborne
| StepDirectNonTargetInstall :
    forall before after,
      non_long_jump_target after ->
      source_action_step (DirectNonTargetInstall after) before after
| StepCrouchSlideLongJumpConstructor :
    forall before,
      source_action_step CrouchSlideLongJumpConstructor before act_long_jump
| StepLongJumpAirLanding :
    source_action_step LongJumpAirLanding
      act_long_jump act_long_jump_land
| StepLongJumpLandingAPressedCallback :
    source_action_step LongJumpLandingAPressedCallback
      act_long_jump_land act_long_jump
| StepForgedActionInstall :
    forall cause edge before after,
      source_action_step (ForgedActionInstall cause edge after) before after.

Lemma clean_source_action_step_preserves_exclusion :
  forall event before after,
    source_action_step event before after ->
    event_has_a_edge event = false ->
    event_is_forged event = false ->
    non_long_jump_target before ->
    non_long_jump_target after.
Proof.
  intros event before after Hstep Hedge Hforge Hbefore.
  inversion Hstep; subst; simpl in Hedge, Hforge |- *; try discriminate.
  - exact Hbefore.
  - exact Hbefore.
  - apply expected_clean_entry_action_is_safe.
  - apply no_spin_airborne_is_not_long_jump_target.
  - assumption.
  - exfalso. apply Hbefore. left. reflexivity.
Qed.

Inductive source_action_trace : Z -> list action_event -> Z -> Prop :=
| SourceActionTraceNil :
    forall action, source_action_trace action [] action
| SourceActionTraceCons :
    forall before middle after event events,
      source_action_step event before middle ->
      source_action_trace middle events after ->
      source_action_trace before (event :: events) after.

Definition no_a_edges (events : list action_event) : Prop :=
  Forall (fun event => event_has_a_edge event = false) events.

Definition no_forged_action_installs (events : list action_event) : Prop :=
  Forall (fun event => event_is_forged event = false) events.

Theorem clean_no_edge_trace_preserves_long_jump_exclusion :
  forall before events after,
    source_action_trace before events after ->
    no_a_edges events ->
    no_forged_action_installs events ->
    non_long_jump_target before ->
    non_long_jump_target after.
Proof.
  intros before events after Htrace.
  induction Htrace as
      [action | before middle after event events Hstep Htrace IH];
    intros Hedges Hforges Hbefore.
  - exact Hbefore.
  - inversion Hedges as [| ? ? Hedge Hedges']; subst.
    inversion Hforges as [| ? ? Hforge Hforges']; subst.
    apply IH; try assumption.
    eapply clean_source_action_step_preserves_exclusion; eauto.
Qed.

Theorem first_target_occurrence_requires_edge_or_forgery :
  forall before events after,
    source_action_trace before events after ->
    non_long_jump_target before ->
    long_jump_target after ->
    Exists
      (fun event =>
         event_has_a_edge event = true \/
         event_is_forged event = true)
      events.
Proof.
  intros before events after Htrace.
  induction Htrace as
      [action | before middle after event events Hstep Htrace IH];
    intros Hbefore Hafter.
  - exfalso. apply Hbefore. exact Hafter.
  - destruct (event_has_a_edge event) eqn:Hedge.
    + apply Exists_cons_hd. left. exact Hedge.
    + destruct (event_is_forged event) eqn:Hforge.
      * apply Exists_cons_hd. right. exact Hforge.
      * apply Exists_cons_tl. apply IH; try assumption.
        eapply clean_source_action_step_preserves_exclusion; eauto.
Qed.

Corollary clean_us_jp_entry_trace_cannot_reach_long_jump_cycle :
  forall (version : retail_version) entry events after,
    source_action_trace (expected_clean_entry_action entry) events after ->
    no_a_edges events ->
    no_forged_action_installs events ->
    non_long_jump_target after.
Proof.
  intros version entry events after Htrace Hedges Hforges.
  eapply clean_no_edge_trace_preserves_long_jump_exclusion; eauto.
  apply expected_clean_entry_action_is_safe.
Qed.

(** Semantic obligations.  These are parameterized propositions, not axioms,
    and no theorem above depends on them. *)

Definition LinkedRetailStepClassificationObligation
    (RetailStep : Type)
    (step_before_action step_after_action : RetailStep -> Z)
    (classify : RetailStep -> action_event) : Prop :=
  forall step,
    source_action_step (classify step)
      (step_before_action step) (step_after_action step).

Definition CleanReachableNoEdgeRefinementObligation
    (RetailStep : Type)
    (clean_zero_edge_reachable : RetailStep -> Prop)
    (classify : RetailStep -> action_event) : Prop :=
  forall step,
    clean_zero_edge_reachable step ->
    event_has_a_edge (classify step) = false.

Definition CleanReachableForgeExclusionObligation
    (RetailStep : Type)
    (clean_zero_edge_reachable : RetailStep -> Prop)
    (classify : RetailStep -> action_event) : Prop :=
  forall step,
    clean_zero_edge_reachable step ->
    event_is_forged (classify step) = false.

Definition CleanEntryActionMemoryObligation
    (read_live_action : retail_version -> clean_entry_kind -> Z) : Prop :=
  forall version entry,
    read_live_action version entry = expected_clean_entry_action entry.

Definition PyramidObjectWarpReinitializationObligation
    (object_warp_action : retail_version -> Z -> Z -> Prop) : Prop :=
  forall version before after,
    object_warp_action version before after ->
    after = act_spawn_no_spin_airborne.

Definition InstantWarpActionPreservationObligation
    (instant_warp_action : retail_version -> Z -> Z -> Prop) : Prop :=
  forall version before after,
    instant_warp_action version before after -> before = after.

Definition InteractionActionClosureObligation
    (interaction_installs : retail_version -> Z -> Prop) : Prop :=
  forall version installed,
    interaction_installs version installed ->
    non_long_jump_target installed.

Definition LongJumpDescriptorPreservationObligation
    (descriptor_payload_at_step :
       retail_version -> nat -> landing_descriptor_projection) : Prop :=
  forall version step,
    descriptor_payload_at_step version step = expected_long_jump_descriptor.

Definition ForgedActionCauseExclusionObligation
    (cause_reachable : retail_version -> forged_action_cause -> Prop) : Prop :=
  forall version cause, ~ cause_reachable version cause.

Definition LongJumpLinkedBoundaryObligation
    (RetailStep : Type)
    (step_before_action step_after_action : RetailStep -> Z)
    (classify : RetailStep -> action_event)
    (clean_zero_edge_reachable : RetailStep -> Prop) : Prop :=
  LinkedRetailStepClassificationObligation
    RetailStep step_before_action step_after_action classify /\
  CleanReachableNoEdgeRefinementObligation
    RetailStep clean_zero_edge_reachable classify /\
  CleanReachableForgeExclusionObligation
    RetailStep clean_zero_edge_reachable classify.

(** The source receipts do not inhabit [LongJumpLinkedBoundaryObligation].
    In particular, still needed are:

    - live US/JP entry execution and history through every action-preserving
      instant warp;
    - whole-program caller/handler closure for setters and interaction-table
      callbacks;
    - preservation of the writable [sLongJumpLandAction] block;
    - valid, non-aliased MarioState pointers and exclusion/modeling of OOB
      stores; and
    - writable-memory frames for unresolved external calls.

    Thus [clean_us_jp_entry_trace_cannot_reach_long_jump_cycle] is the exact
    source-kernel reduction, not a proof about all clean retail executions. *)
