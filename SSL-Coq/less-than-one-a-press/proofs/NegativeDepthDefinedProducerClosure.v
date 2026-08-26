(** Defined-producer close-out for negative quicksand depth.

    This file combines three previously separate facts at one audit boundary:

    - every direct [quicksandDepth] store in the 38 selected US/JP units has
      one of the exact generated shapes recorded below;
    - the source contains no untyped/interior/retained MarioState or landing-
      descriptor pointer producer, while the initialized interaction action
      tables remain private throughout every successful selected Clight run;
    - a finite trace made only of the checked binary32 writer outcomes cannot
      turn the clean +0.0f entry value negative.

    CompCert deliberately leaves [EF_external] effects abstract.  The exact
    reachable frame needed for those calls is therefore stated over the
    action/input/timer/depth bytes, the live MarioState pointer cell, and all
    landing-descriptor blocks.  It is not inferred from a C prototype.  This
    keeps an unspecified outside effect from being mistaken for either a
    proved gameplay seed or a proved impossibility result. *)

From Coq Require Import Classical_Prop Lia List ZArith.
From compcert Require Import
  AST Builtins Clight Cop Ctypes Events Floats Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_mario us_mario_actions_airborne us_mario_actions_automatic
  us_mario_actions_cutscene us_mario_actions_moving
  us_mario_actions_submerged us_mario_step
  jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene jp_mario_actions_moving
  jp_mario_actions_submerged jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ActionDepthAliasCensus ClightLinkExecution CompCertRouteScope EntryMemory
  JPBinary32DepthWrites JPQuicksandDepth LongJumpProvenanceBoundary
  NegativeDepthInteractionClosure RetailExternalFrameReachability
  RetailExternalFrames WritableActionTableReachedExecution
  ZeroAQuicksandEntryBoundary.

Import ListNotations.
Local Open Scope Z_scope.

Module NDDP_USMario := us_mario.
Module NDDP_USAir := us_mario_actions_airborne.
Module NDDP_USAuto := us_mario_actions_automatic.
Module NDDP_USCut := us_mario_actions_cutscene.
Module NDDP_USMove := us_mario_actions_moving.
Module NDDP_USSubmerged := us_mario_actions_submerged.
Module NDDP_USStep := us_mario_step.
Module NDDP_JPMario := jp_mario.
Module NDDP_JPAir := jp_mario_actions_airborne.
Module NDDP_JPAuto := jp_mario_actions_automatic.
Module NDDP_JPCut := jp_mario_actions_cutscene.
Module NDDP_JPMove := jp_mario_actions_moving.
Module NDDP_JPSubmerged := jp_mario_actions_submerged.
Module NDDP_JPStep := jp_mario_step.

(** * Exact direct-store shapes *)

Inductive NegativeDepthStoreShape : Type :=
| NDStoreZero
| NDStoreOnePointOne
| NDStoreTen
| NDStoreTwentyFive
| NDStoreSixty
| NDStoreTemporary
| NDStoreCommonLandingDelta
| NDStoreQuicksandJumpDelta
| NDStoreOther.

Definition nddp_int_literal_is (value : Z) (expression : expr) : bool :=
  match expression with
  | Econst_int found _ => Int.eq found (Int.repr value)
  | _ => false
  end.

Definition nddp_single_literal_is (bits : Z) (expression : expr) : bool :=
  match expression with
  | Econst_single found _ => Int.eq (Float32.to_bits found) (Int.repr bits)
  | _ => false
  end.

Definition nddp_is_common_landing_delta (expression : expr) : bool :=
  match expression with
  | Ebinop Oadd (Etempvar _ _)
      (Ebinop Osub
        (Ebinop Omul
          (Ebinop Osub four (Etempvar _ _) _)
          three_point_five _)
        one_half _) _ =>
      nddp_int_literal_is 4 four &&
      nddp_single_literal_is 1080033280 three_point_five &&
      nddp_single_literal_is 1056964608 one_half
  | _ => false
  end.

Definition nddp_is_quicksand_jump_delta (expression : expr) : bool :=
  match expression with
  | Ebinop Osub (Etempvar _ _)
      (Ebinop Omul
        (Ebinop Osub seven (Etempvar _ _) _)
        eight_tenths _) _ =>
      nddp_int_literal_is 7 seven &&
      nddp_single_literal_is 1061997773 eight_tenths
  | _ => false
  end.

Definition classify_negative_depth_store_rhs
    (expression : expr) : NegativeDepthStoreShape :=
  if nddp_is_common_landing_delta expression then NDStoreCommonLandingDelta
  else if nddp_is_quicksand_jump_delta expression
       then NDStoreQuicksandJumpDelta
  else
    match expression with
    | Econst_single value _ =>
        let bits := Float32.to_bits value in
        if Int.eq bits (Int.repr 0) then NDStoreZero
        else if Int.eq bits (Int.repr 1066192077) then NDStoreOnePointOne
        else if Int.eq bits (Int.repr 1092616192) then NDStoreTen
        else if Int.eq bits (Int.repr 1103626240) then NDStoreTwentyFive
        else if Int.eq bits (Int.repr 1114636288) then NDStoreSixty
        else NDStoreOther
    | Etempvar _ _ => NDStoreTemporary
    | _ => NDStoreOther
    end.

Fixpoint negative_depth_store_shapes_s
    (field : ident) (statement : statement) : list NegativeDepthStoreShape :=
  match statement with
  | Sassign left_expression right_expression =>
      if lhs_field_is field left_expression
      then [classify_negative_depth_store_rhs right_expression]
      else []
  | Ssequence first second | Sloop first second =>
      negative_depth_store_shapes_s field first ++
      negative_depth_store_shapes_s field second
  | Sifthenelse _ yes_branch no_branch =>
      negative_depth_store_shapes_s field yes_branch ++
      negative_depth_store_shapes_s field no_branch
  | Sswitch _ cases => negative_depth_store_shapes_ls field cases
  | Slabel _ body => negative_depth_store_shapes_s field body
  | _ => []
  end
with negative_depth_store_shapes_ls
    (field : ident) (cases : labeled_statements) :
    list NegativeDepthStoreShape :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      negative_depth_store_shapes_s field body ++
      negative_depth_store_shapes_ls field rest
  end.

(** [clightgen] lowers death and ordinary quicksand increments through two
    temporaries.  This recognizer couples the field load, floating addition,
    and final store so the five [NDStoreTemporary] entries are not opaque. *)
Definition nddp_is_depth_add_then_store
    (field : ident) (addend_is_expected : expr -> bool)
    (statement : statement) : bool :=
  match statement with
  | Ssequence
      (Ssequence
        (Sset loaded
          (Efield _ found_field _))
        (Sset result
          (Ecast
            (Ebinop Oadd (Etempvar used_loaded _) addend _) _)))
      (Sassign left_expression (Etempvar used_result _)) =>
      Pos.eqb found_field field &&
      Pos.eqb loaded used_loaded &&
      Pos.eqb result used_result &&
      lhs_field_is field left_expression &&
      addend_is_expected addend
  | _ => false
  end.

Fixpoint nddp_depth_add_then_store_count_s
    (field : ident) (addend_is_expected : expr -> bool)
    (statement : statement) : nat :=
  (if nddp_is_depth_add_then_store field addend_is_expected statement
   then 1%nat else 0%nat) +
  match statement with
  | Ssequence first second | Sloop first second =>
      nddp_depth_add_then_store_count_s field addend_is_expected first +
      nddp_depth_add_then_store_count_s field addend_is_expected second
  | Sifthenelse _ yes_branch no_branch =>
      nddp_depth_add_then_store_count_s field addend_is_expected yes_branch +
      nddp_depth_add_then_store_count_s field addend_is_expected no_branch
  | Sswitch _ cases =>
      nddp_depth_add_then_store_count_ls field addend_is_expected cases
  | Slabel _ body =>
      nddp_depth_add_then_store_count_s field addend_is_expected body
  | _ => 0%nat
  end
with nddp_depth_add_then_store_count_ls
    (field : ident) (addend_is_expected : expr -> bool)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      nddp_depth_add_then_store_count_s field addend_is_expected body +
      nddp_depth_add_then_store_count_ls field addend_is_expected rest
  end.

Definition nddp_addend_is_five (expression : expr) : bool :=
  nddp_single_literal_is 1084227584 expression.

Definition nddp_addend_is_temp (expected : ident) (expression : expr) : bool :=
  match expression with
  | Etempvar found _ => Pos.eqb found expected
  | _ => false
  end.

Definition NegativeDepthDirectStoreShapeReceipt : Prop :=
  map
    (fun body =>
       negative_depth_store_shapes_s NDDP_USMario._quicksandDepth
         (fn_body body))
    [NDDP_USMario.f_init_mario;
     NDDP_USAir.f_check_common_airborne_cancels;
     NDDP_USAuto.f_mario_execute_automatic_action;
     NDDP_USCut.f_act_quicksand_death;
     NDDP_USMove.f_common_landing_action;
     NDDP_USMove.f_quicksand_jump_land_action;
     NDDP_USSubmerged.f_mario_execute_submerged_action;
     NDDP_USStep.f_mario_update_quicksand] =
    [[NDStoreZero]; [NDStoreZero]; [NDStoreZero]; [NDStoreTemporary];
     [NDStoreCommonLandingDelta];
     [NDStoreQuicksandJumpDelta; NDStoreOnePointOne];
     [NDStoreZero];
     [NDStoreZero; NDStoreOnePointOne; NDStoreTemporary; NDStoreTen;
      NDStoreTemporary; NDStoreTwentyFive; NDStoreTemporary; NDStoreSixty;
      NDStoreTemporary; NDStoreZero]] /\
  map
    (fun body =>
       negative_depth_store_shapes_s NDDP_JPMario._quicksandDepth
         (fn_body body))
    [NDDP_JPMario.f_init_mario;
     NDDP_JPAir.f_check_common_airborne_cancels;
     NDDP_JPAuto.f_mario_execute_automatic_action;
     NDDP_JPCut.f_act_quicksand_death;
     NDDP_JPMove.f_common_landing_action;
     NDDP_JPMove.f_quicksand_jump_land_action;
     NDDP_JPSubmerged.f_mario_execute_submerged_action;
     NDDP_JPStep.f_mario_update_quicksand] =
    [[NDStoreZero]; [NDStoreZero]; [NDStoreZero]; [NDStoreTemporary];
     [NDStoreCommonLandingDelta];
     [NDStoreQuicksandJumpDelta; NDStoreOnePointOne];
     [NDStoreZero];
     [NDStoreZero; NDStoreOnePointOne; NDStoreTemporary; NDStoreTen;
      NDStoreTemporary; NDStoreTwentyFive; NDStoreTemporary; NDStoreSixty;
      NDStoreTemporary; NDStoreZero]] /\
  nddp_depth_add_then_store_count_s
      NDDP_USCut._quicksandDepth nddp_addend_is_five
      (fn_body NDDP_USCut.f_act_quicksand_death) = 1%nat /\
  nddp_depth_add_then_store_count_s
      NDDP_JPCut._quicksandDepth nddp_addend_is_five
      (fn_body NDDP_JPCut.f_act_quicksand_death) = 1%nat /\
  nddp_depth_add_then_store_count_s
      NDDP_USStep._quicksandDepth
      (nddp_addend_is_temp NDDP_USStep._sinkingSpeed)
      (fn_body NDDP_USStep.f_mario_update_quicksand) = 4%nat /\
  nddp_depth_add_then_store_count_s
      NDDP_JPStep._quicksandDepth
      (nddp_addend_is_temp NDDP_JPStep._sinkingSpeed)
      (fn_body NDDP_JPStep.f_mario_update_quicksand) = 4%nat.

Theorem negative_depth_direct_store_shape_receipt_holds :
  NegativeDepthDirectStoreShapeReceipt.
Proof.
  unfold NegativeDepthDirectStoreShapeReceipt.
  vm_compute. repeat split; reflexivity.
Qed.

(** * Consequence of the checked arithmetic/source traces *)

Theorem negative_binary32_seed_requires_an_unclassified_depth_step :
  forall final_depth,
    Float32.cmp Clt final_depth jp_b32_zero = true ->
    ~ JPBinary32SafeDepthWriterTrace jp_b32_zero final_depth.
Proof.
  intros final_depth Hnegative Htrace.
  pose proof
    (jp_binary32_safe_writer_trace_from_clean_zero_is_not_clight_negative
      final_depth Htrace) as Hnonnegative.
  rewrite Hnegative in Hnonnegative. discriminate.
Qed.

Theorem negative_source_seed_requires_a_forgery_or_unclassified_writer :
  forall entry action_events final_action final_depth,
    source_action_trace
      (expected_clean_entry_action entry) action_events final_action ->
    final_depth < 0 ->
    ~ no_a_edges action_events \/
    ~ no_forged_action_installs action_events \/
    ~ JPSourceShapedSafeDepthTrace 0 final_depth.
Proof.
  intros entry action_events final_action final_depth Hactions Hnegative.
  destruct (classic (no_a_edges action_events)) as [Hedges | Hedges].
  2: now left.
  destruct (classic (no_forged_action_installs action_events))
    as [Hforges | Hforges].
  2: now right; left.
  right. right. intro Hdepth.
  pose proof
    (zero_a_ordinary_source_kernels_exclude_prepared_negative_state
      entry action_events final_action final_depth
      Hactions Hedges Hforges Hdepth) as [_ Hnonnegative].
  lia.
Qed.

(** * Exact unresolved-external frame *)

Record NegativeDepthProtectedAddresses : Type := {
  nddp_state_block : block;
  nddp_state_base : Z;
  nddp_state_pointer_block : block;
  nddp_state_pointer_offset : Z;
  nddp_landing_descriptor_blocks : list block
}.

Definition nddp_byte_in_range (offset low size : Z) : Prop :=
  low <= offset < low + size.

(** Bytes 0..3 include Mario's flags/input pair.  The remaining intervals are
    the action word, state/timer/argument controls, and quicksand depth. *)
Definition negative_depth_protected_byte
    (addresses : NegativeDepthProtectedAddresses)
    (candidate_block : block) (offset : Z) : Prop :=
  (candidate_block = nddp_state_block addresses /\
   (nddp_byte_in_range offset (nddp_state_base addresses) 4 \/
    nddp_byte_in_range offset
      (nddp_state_base addresses + mario_state_action_offset) 4 \/
    nddp_byte_in_range offset
      (nddp_state_base addresses + mario_state_action_state_offset) 2 \/
    nddp_byte_in_range offset
      (nddp_state_base addresses + mario_state_action_timer_offset) 2 \/
    nddp_byte_in_range offset
      (nddp_state_base addresses + mario_state_action_arg_offset) 4 \/
    nddp_byte_in_range offset
      (nddp_state_base addresses + mario_state_quicksand_depth_offset) 4)) \/
  (candidate_block = nddp_state_pointer_block addresses /\
   nddp_byte_in_range offset
     (nddp_state_pointer_offset addresses) 4) \/
  (In candidate_block (nddp_landing_descriptor_blocks addresses) /\
   nddp_byte_in_range offset 0 28).

Definition NegativeDepthReachableExternalFrames
    (program : Clight.program) (origin : ClightExecutionOrigin)
    (addresses : NegativeDepthProtectedAddresses) : Prop :=
  forall name signature,
    ReachableExternalCallFrame program origin
      (constant_external_protected_cells
        (negative_depth_protected_byte addresses))
      (EF_external name signature).

(** Recognized CompCert builtins and runtime helpers already satisfy this
    complete byte frame because their concrete semantics leaves all memory
    unchanged.  Only genuine [EF_external] declarations need the policy
    above or an implementation refinement. *)
Theorem recognized_builtin_preserves_negative_depth_protected_bytes :
  forall addresses name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame (negative_depth_protected_byte addresses)
      (EF_builtin name signature).
Proof.
  intros. eapply recognized_builtin_has_every_writable_frame; eauto.
Qed.

Theorem recognized_runtime_preserves_negative_depth_protected_bytes :
  forall addresses name signature builtin,
    lookup_builtin_function name signature = Some builtin ->
    ExternalCallFrame (negative_depth_protected_byte addresses)
      (EF_runtime name signature).
Proof.
  intros. eapply recognized_runtime_has_every_writable_frame; eauto.
Qed.

Inductive NegativeDepthDefinedEscape : Type :=
| NDEscapeLateLandingWithoutCleanProvenance
| NDEscapeLandingDescriptorChanged
| NDEscapeActionOrTimerChanged
| NDEscapeIndirectCallbackRetargeted
| NDEscapeMarioStateIdentityChanged
| NDEscapeUnclassifiedTypedInternalWrite
| NDEscapeUnframedExternalEffect.

Definition all_negative_depth_defined_escapes :
    list NegativeDepthDefinedEscape :=
  [NDEscapeLateLandingWithoutCleanProvenance;
   NDEscapeLandingDescriptorChanged;
   NDEscapeActionOrTimerChanged;
   NDEscapeIndirectCallbackRetargeted;
   NDEscapeMarioStateIdentityChanged;
   NDEscapeUnclassifiedTypedInternalWrite;
   NDEscapeUnframedExternalEffect].

Lemma all_negative_depth_defined_escapes_complete :
  forall escape, In escape all_negative_depth_defined_escapes.
Proof.
  destruct escape; unfold all_negative_depth_defined_escapes; cbn; tauto.
Qed.

(** Premise-free capstone for everything actually discharged in this tranche.
    The live Clight projection and [NegativeDepthReachableExternalFrames] are
    intentionally not smuggled into this record: they are the two remaining
    semantic inputs needed for a universal execution theorem. *)
Definition NegativeDepthDefinedProducerCheckedBoundary : Prop :=
  ActionDepthAliasSyntaxBoundary /\
  ActionDepthDefinedAliasSourceClosure /\
  NegativeDepthDirectStoreShapeReceipt /\
  ZeroAOrdinaryLongJumpSourceBoundary /\
  NegativeDepthInitializedInteractionSourceBoundary /\
  WritableActionTableReachedExecutionClosure /\
  compcert_execution_scope_boundary_holds /\
  (forall final_depth,
    Float32.cmp Clt final_depth jp_b32_zero = true ->
    ~ JPBinary32SafeDepthWriterTrace jp_b32_zero final_depth) /\
  (forall entry action_events final_action final_depth,
    source_action_trace
      (expected_clean_entry_action entry) action_events final_action ->
    final_depth < 0 ->
    ~ no_a_edges action_events \/
    ~ no_forged_action_installs action_events \/
    ~ JPSourceShapedSafeDepthTrace 0 final_depth).

Theorem negative_depth_defined_producer_checked_boundary_holds :
  NegativeDepthDefinedProducerCheckedBoundary.
Proof.
  unfold NegativeDepthDefinedProducerCheckedBoundary.
  split; [exact action_depth_alias_syntax_boundary_holds |].
  split; [exact action_depth_defined_alias_source_closure_holds |].
  split; [exact negative_depth_direct_store_shape_receipt_holds |].
  split; [exact zero_a_ordinary_long_jump_source_boundary_checked |].
  split; [exact negative_depth_initialized_interaction_source_boundary_holds |].
  split; [exact writable_action_table_reached_execution_closure_holds |].
  split; [exact compcert_execution_scope_boundary_checked |].
  split.
  - exact negative_binary32_seed_requires_an_unclassified_depth_step.
  - exact negative_source_seed_requires_a_forgery_or_unclassified_writer.
Qed.

Print Assumptions action_depth_defined_alias_source_closure_holds.
Print Assumptions negative_depth_direct_store_shape_receipt_holds.
Print Assumptions negative_binary32_seed_requires_an_unclassified_depth_step.
Print Assumptions negative_source_seed_requires_a_forgery_or_unclassified_writer.
Print Assumptions negative_depth_defined_producer_checked_boundary_holds.
