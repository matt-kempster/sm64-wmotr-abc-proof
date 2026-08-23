(** Named-source corruption closure for the timer-131 Ink route.

    Earlier files reduce the surviving ordinary producer to corruption of a
    live object/list identity, behavior constructor, dispatch table, or an
    overlapping untyped store.  This file removes two more source-level
    ambiguities:

    - the generated command and interaction tables are mentioned only by
      their stock dispatchers and have no direct named assignment or explicit
      address-taking site anywhere in the 38-unit US/JP corpus; and
    - [spawn_objects_from_info] forwards one stable
      [segmented_to_virtual(behaviorScript)] result to both [create_object]
      and the new object's [behavior] field.  The constructor path therefore
      does not independently invent a Mario behavior pointer.

    It also packages the negative-quicksand result in route form.  A clean
    zero-A, no-forgery source trace cannot produce a negative seed, and even a
    granted negative seed plus arbitrarily many untransported dialog stalls
    cannot reach the fixed upper warp in X/Z.

    These are generated-source, arithmetic, and finite-model results.  An
    overlapping out-of-bounds store, integer/interior pointer fabrication,
    untyped external write, live-table mismatch, corrupt SpawnInfo, or broken
    object-list/slot epoch remains outside the theorem. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_script us_interaction us_object_list_processor
  jp_behavior_script jp_interaction jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1WarpTopCloneCensus AutomaticDialogReanchoring
  InkTimer131IndirectAliasClosure InkTimer131MarioTailClosure
  JPQuicksandDepth LongJumpProvenanceBoundary
  NegativeDepthInteractionClosure NegativeDepthTimer131Bridge PyramidTopPU
  ZeroAQuicksandEntryBoundary.

Import ListNotations.
Local Open Scope Z_scope.

Module ITCC_USBehavior := us_behavior_script.
Module ITCC_USInteraction := us_interaction.
Module ITCC_USObjects := us_object_list_processor.
Module ITCC_JPBehavior := jp_behavior_script.
Module ITCC_JPInteraction := jp_interaction.
Module ITCC_JPObjects := jp_object_list_processor.

(** Exact whole-corpus use sites.  Array decay is not represented as
    [Eaddrof], so the mention census is essential alongside the empty
    assignment/address censuses. *)
Definition ink_dispatch_table_named_source_claim : Prop :=
  internal_body_mentioning_ids ITCC_USBehavior._BehaviorCmdTable
      ink_us_definitions = [ITCC_USBehavior._cur_obj_update] /\
  internal_body_mentioning_ids ITCC_JPBehavior._BehaviorCmdTable
      ink_jp_definitions = [ITCC_JPBehavior._cur_obj_update] /\
  internal_function_assignment_sites ITCC_USBehavior._BehaviorCmdTable
      ink_us_definitions = [] /\
  internal_function_assignment_sites ITCC_JPBehavior._BehaviorCmdTable
      ink_jp_definitions = [] /\
  internal_function_address_sites ITCC_USBehavior._BehaviorCmdTable
      ink_us_definitions = [] /\
  internal_function_address_sites ITCC_JPBehavior._BehaviorCmdTable
      ink_jp_definitions = [] /\
  internal_body_mentioning_ids ITCC_USInteraction._sInteractionHandlers
      ink_us_definitions =
        [ITCC_USInteraction._mario_process_interactions] /\
  internal_body_mentioning_ids ITCC_JPInteraction._sInteractionHandlers
      ink_jp_definitions =
        [ITCC_JPInteraction._mario_process_interactions] /\
  internal_function_assignment_sites ITCC_USInteraction._sInteractionHandlers
      ink_us_definitions = [] /\
  internal_function_assignment_sites ITCC_JPInteraction._sInteractionHandlers
      ink_jp_definitions = [] /\
  internal_function_address_sites ITCC_USInteraction._sInteractionHandlers
      ink_us_definitions = [] /\
  internal_function_address_sites ITCC_JPInteraction._sInteractionHandlers
      ink_jp_definitions = [].

Theorem ink_dispatch_tables_have_only_stock_named_source_uses :
  ink_dispatch_table_named_source_claim.
Proof.
  unfold ink_dispatch_table_named_source_claim,
    ink_us_definitions, ink_jp_definitions,
    internal_body_mentioning_ids, internal_body_mentions_ident.
  vm_compute. repeat split; reflexivity.
Qed.

(** Match the normalized three-statement dataflow

      source = spawnInfo->behaviorScript;
      result = segmented_to_virtual(source);
      script = result.

    The exact source field is checked so another temporary cannot masquerade
    as the behavior-script value. *)
Definition ink_is_segmented_behavior_to_script_s
    (segmented spawn_info_tag behavior_script_field script_temp : ident)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Ssequence
        (Sset source_temp
          (Efield
            (Ederef _ (Tstruct found_spawn_info_tag _))
            found_behavior_script_field _))
        (Scall (Some result_temp) (Evar found_segmented _)
          [Etempvar used_source_temp _]))
      (Sset found_script_temp (Etempvar used_result_temp _)) =>
      Pos.eqb found_spawn_info_tag spawn_info_tag &&
      Pos.eqb found_behavior_script_field behavior_script_field &&
      Pos.eqb found_segmented segmented &&
      Pos.eqb source_temp used_source_temp &&
      Pos.eqb result_temp used_result_temp &&
      Pos.eqb found_script_temp script_temp
  | _ => false
  end.

Fixpoint ink_contains_segmented_behavior_to_script_s
    (segmented spawn_info_tag behavior_script_field script_temp : ident)
    (statement : statement) : bool :=
  ink_is_segmented_behavior_to_script_s segmented spawn_info_tag
      behavior_script_field script_temp statement ||
  match statement with
  | Ssequence first second | Sloop first second =>
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp first ||
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp second
  | Sifthenelse _ yes no =>
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp yes ||
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp no
  | Sswitch _ cases =>
      ink_contains_segmented_behavior_to_script_ls segmented spawn_info_tag
        behavior_script_field script_temp cases
  | Slabel _ nested =>
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp nested
  | _ => false
  end
with ink_contains_segmented_behavior_to_script_ls
    (segmented spawn_info_tag behavior_script_field script_temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_contains_segmented_behavior_to_script_s segmented spawn_info_tag
        behavior_script_field script_temp body ||
      ink_contains_segmented_behavior_to_script_ls segmented spawn_info_tag
        behavior_script_field script_temp rest
  end.

Fixpoint ink_contains_object_field_from_temp_s
    (object_tag field object_temp value_temp : ident)
    (statement : statement) : bool :=
  match statement with
  | Sassign
      (Efield
        (Ederef (Etempvar found_object_temp _) (Tstruct found_object_tag _))
        found_field _)
      (Etempvar found_value_temp _) =>
      Pos.eqb found_object_tag object_tag &&
      Pos.eqb found_field field &&
      Pos.eqb found_object_temp object_temp &&
      Pos.eqb found_value_temp value_temp
  | Ssequence first second | Sloop first second =>
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp first ||
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp second
  | Sifthenelse _ yes no =>
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp yes ||
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp no
  | Sswitch _ cases =>
      ink_contains_object_field_from_temp_ls object_tag field object_temp
        value_temp cases
  | Slabel _ nested =>
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp nested
  | _ => false
  end
with ink_contains_object_field_from_temp_ls
    (object_tag field object_temp value_temp : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      ink_contains_object_field_from_temp_s object_tag field object_temp
        value_temp body ||
      ink_contains_object_field_from_temp_ls object_tag field object_temp
        value_temp rest
  end.

Definition ink_mario_constructor_behavior_forwarding_claim : Prop :=
  ink_contains_segmented_behavior_to_script_s
      ITCC_USObjects._segmented_to_virtual ITCC_USObjects._SpawnInfo
      ITCC_USObjects._behaviorScript ITCC_USObjects._script
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = true /\
  contains_unary_temp_call_s
      ITCC_USObjects._create_object ITCC_USObjects._script
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = true /\
  ink_contains_object_field_from_temp_s
      ITCC_USObjects._Object ITCC_USObjects._behavior
      ITCC_USObjects._object ITCC_USObjects._script
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = true /\
  temp_set_count_s ITCC_USObjects._script
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = 1%nat /\
  ink_contains_call_result_to_global_s
      ITCC_USObjects._create_object ITCC_USObjects._object
      ITCC_USObjects._gMarioObject
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = true /\
  ink_count_temp_sets_s ITCC_USObjects._object
      (fn_body ITCC_USObjects.f_spawn_objects_from_info) = 1%nat /\
  ink_contains_segmented_behavior_to_script_s
      ITCC_JPObjects._segmented_to_virtual ITCC_JPObjects._SpawnInfo
      ITCC_JPObjects._behaviorScript ITCC_JPObjects._script
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = true /\
  contains_unary_temp_call_s
      ITCC_JPObjects._create_object ITCC_JPObjects._script
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = true /\
  ink_contains_object_field_from_temp_s
      ITCC_JPObjects._Object ITCC_JPObjects._behavior
      ITCC_JPObjects._object ITCC_JPObjects._script
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = true /\
  temp_set_count_s ITCC_JPObjects._script
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = 1%nat /\
  ink_contains_call_result_to_global_s
      ITCC_JPObjects._create_object ITCC_JPObjects._object
      ITCC_JPObjects._gMarioObject
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = true /\
  ink_count_temp_sets_s ITCC_JPObjects._object
      (fn_body ITCC_JPObjects.f_spawn_objects_from_info) = 1%nat.

Theorem ink_mario_constructor_forwards_one_stable_behavior_value :
  ink_mario_constructor_behavior_forwarding_claim.
Proof.
  unfold ink_mario_constructor_behavior_forwarding_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The clean source kernels already rule out the only ordinary negative
    seed.  This corollary states the route consequence directly. *)
Theorem clean_zero_a_no_forgery_trace_has_no_negative_dialog_seed :
  forall entry action_events final_action final_depth,
    source_action_trace
      (expected_clean_entry_action entry) action_events final_action ->
    no_a_edges action_events ->
    no_forged_action_installs action_events ->
    JPSourceShapedSafeDepthTrace 0 final_depth ->
    final_depth < 0 ->
    False.
Proof.
  intros entry action_events final_action final_depth
    Hactions Hedges Hforges Hdepth Hnegative.
  pose proof
    (zero_a_ordinary_source_kernels_exclude_prepared_negative_state
      entry action_events final_action final_depth
      Hactions Hedges Hforges Hdepth) as (_ & Hnonnegative).
  lia.
Qed.

(** Granting a negative depth does not repair the missing horizontal route:
    the stalled dialog model can amplify Y for any finite frame count while
    its raw Object remains outside the fixed warp. *)
Theorem granted_negative_untransported_dialog_never_reaches_timer131_warp :
  forall frames depth vertical_views raw_y,
    depth < 0 ->
    dialog_object_y vertical_views = dialog_state_y vertical_views ->
    ~ upper_warp_contact
        (dialog_raw_object_position raw_y
          (repeat_untransported_dialog_horizontal
            frames boundary_dialog_horizontal_views)).
Proof.
  intros frames depth vertical_views raw_y _ Hsync.
  exact (proj2
    (vertical_dialog_amplification_does_not_supply_warp_xz
      frames depth vertical_views raw_y Hsync)).
Qed.

Definition InkTimer131CorruptionCheckedBoundary : Prop :=
  ink_dispatch_table_named_source_claim /\
  ink_mario_constructor_behavior_forwarding_claim /\
  NegativeDepthInitializedInteractionSourceBoundary /\
  (forall entry action_events final_action final_depth,
    source_action_trace
      (expected_clean_entry_action entry) action_events final_action ->
    no_a_edges action_events ->
    no_forged_action_installs action_events ->
    JPSourceShapedSafeDepthTrace 0 final_depth ->
    ~ final_depth < 0) /\
  (forall frames depth vertical_views raw_y,
    depth < 0 ->
    dialog_object_y vertical_views = dialog_state_y vertical_views ->
    ~ upper_warp_contact
        (dialog_raw_object_position raw_y
          (repeat_untransported_dialog_horizontal
            frames boundary_dialog_horizontal_views))).

Theorem ink_timer131_corruption_checked_boundary_holds :
  InkTimer131CorruptionCheckedBoundary.
Proof.
  unfold InkTimer131CorruptionCheckedBoundary.
  split; [exact ink_dispatch_tables_have_only_stock_named_source_uses |].
  split; [exact ink_mario_constructor_forwards_one_stable_behavior_value |].
  split; [exact negative_depth_initialized_interaction_source_boundary_holds |].
  split.
  - intros. intro Hnegative.
    eapply clean_zero_a_no_forgery_trace_has_no_negative_dialog_seed; eauto.
  - exact granted_negative_untransported_dialog_never_reaches_timer131_warp.
Qed.
