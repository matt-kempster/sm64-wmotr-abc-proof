(** Bilateral source and conditional semantic closure for the successful
    nonfading upper-warp interaction.

    The generated source has a useful short circuit: the fifth interaction
    table entry is [INTERACT_WARP]/[interact_warp]; its accepted non-pipe
    branch returns the result of [set_mario_action(ACT_DISAPPEARED, ...)];
    [set_mario_action] returns one; and [mario_process_interactions] breaks
    when an indirect handler returns nonzero.  Consequently no handler later
    in the table can run on that faithful execution.

    The source receipts below pin that chain for both retail versions and
    extend the direct [MarioState.pos] census through the interaction tail and
    disappeared action.  They are deliberately not a linked-memory proof.
    The handler table is writable, indirect dispatch and return propagation
    need Clight execution refinement, and calls or aliases can write through
    receivers which a direct-lvalue census cannot see.

    The final record makes those live obligations concrete.  Given faithful
    table/dispatch/return/break projection, the selection-sample equality
    which a separate live-Mario-receiver proof must supply, an alias sample
    frame, and an external-call sample frame, the final query reads the copied
    Object and no later handler is selected.  The finite schedule then leaves
    only the cached-floor Y snap.  With an explicit cached Y of 768, the
    already checked stock-query theorem returns [None]. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_interaction us_mario us_mario_actions_cutscene us_mario_step
  jp_interaction jp_mario jp_mario_actions_cutscene jp_mario_step.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PlatformExhaustiveness Area1QueryScheduleClosure
  Area1PostCopyObjectWriterClosure PyramidTopPU.

Import ListNotations.
Local Open Scope Z_scope.

Module A1ISC_USInteraction := us_interaction.
Module A1ISC_USMario := us_mario.
Module A1ISC_USCutscene := us_mario_actions_cutscene.
Module A1ISC_USStep := us_mario_step.
Module A1ISC_JPInteraction := jp_interaction.
Module A1ISC_JPMario := jp_mario.
Module A1ISC_JPCutscene := jp_mario_actions_cutscene.
Module A1ISC_JPStep := jp_mario_step.

(** The exact prefix through the entry immediately after [interact_warp].
    Thus the warp pair is index four (zero based), after coin, water-ring,
    star/key, and BBH, and before every remaining table entry. *)
Definition us_interaction_handler_prefix_through_warp : list init_data :=
  [Init_int32 (Int.repr 16);
   Init_addrof A1ISC_USInteraction._interact_coin Ptrofs.zero;
   Init_int32 (Int.repr 65536);
   Init_addrof A1ISC_USInteraction._interact_water_ring Ptrofs.zero;
   Init_int32 (Int.repr 4096);
   Init_addrof A1ISC_USInteraction._interact_star_or_key Ptrofs.zero;
   Init_int32 (Int.repr 134217728);
   Init_addrof A1ISC_USInteraction._interact_bbh_entrance Ptrofs.zero;
   Init_int32 (Int.repr 8192);
   Init_addrof A1ISC_USInteraction._interact_warp Ptrofs.zero;
   Init_int32 (Int.repr 2048);
   Init_addrof A1ISC_USInteraction._interact_warp_door Ptrofs.zero].

Definition jp_interaction_handler_prefix_through_warp : list init_data :=
  [Init_int32 (Int.repr 16);
   Init_addrof A1ISC_JPInteraction._interact_coin Ptrofs.zero;
   Init_int32 (Int.repr 65536);
   Init_addrof A1ISC_JPInteraction._interact_water_ring Ptrofs.zero;
   Init_int32 (Int.repr 4096);
   Init_addrof A1ISC_JPInteraction._interact_star_or_key Ptrofs.zero;
   Init_int32 (Int.repr 134217728);
   Init_addrof A1ISC_JPInteraction._interact_bbh_entrance Ptrofs.zero;
   Init_int32 (Int.repr 8192);
   Init_addrof A1ISC_JPInteraction._interact_warp Ptrofs.zero;
   Init_int32 (Int.repr 2048);
   Init_addrof A1ISC_JPInteraction._interact_warp_door Ptrofs.zero].

Definition warp_handler_pair_and_order_source_claim : Prop :=
  firstn 12 (gvar_init A1ISC_USInteraction.v_sInteractionHandlers) =
    us_interaction_handler_prefix_through_warp /\
  firstn 12 (gvar_init A1ISC_JPInteraction.v_sInteractionHandlers) =
    jp_interaction_handler_prefix_through_warp /\
  length (gvar_init A1ISC_USInteraction.v_sInteractionHandlers) = 62%nat /\
  length (gvar_init A1ISC_JPInteraction.v_sInteractionHandlers) = 62%nat.

Theorem warp_handler_pair_and_order_source_checked :
  warp_handler_pair_and_order_source_claim.
Proof.
  unfold warp_handler_pair_and_order_source_claim,
    us_interaction_handler_prefix_through_warp,
    jp_interaction_handler_prefix_through_warp.
  vm_compute. repeat split; reflexivity.
Qed.

(** Match the exact action argument

      (WARP_OP_WARP_OBJECT << 16) + 2.
*)
Definition is_object_warp_delay_argument (value : expr) : bool :=
  match value with
  | Ebinop Oadd
      (Ebinop Oshl (Econst_int operation _) (Econst_int shift _) _)
      (Econst_int delay _) _ =>
      Int.eq operation (Int.repr 4) &&
      Int.eq shift (Int.repr 16) &&
      Int.eq delay (Int.repr 2)
  | _ => false
  end.

Definition is_nonpipe_action_guard (condition : expr) : bool :=
  match condition with
  | Ebinop Cop.One (Etempvar _ _) (Econst_int action _) _ =>
      Int.eq action (Int.repr 6435)
  | _ => false
  end.

(** The outer [interact_warp] split tests the object's fading-warp bit.  Its
    false branch is the nonfading branch. *)
Definition is_fading_warp_flag_guard (condition : expr) : bool :=
  match condition with
  | Ebinop Oand (Etempvar _ _) (Econst_int mask _) _ =>
      Int.eq mask (Int.repr 1)
  | _ => false
  end.

(** Match the successful tail as one data-flow unit: stop riding, call
    [set_mario_action] with ACT_DISAPPEARED (4864), and return that exact
    call-result temporary. *)
Definition is_stop_set_disappeared_return_tail_s
    (stop_riding set_action : ident) (body : statement) : bool :=
  match body with
  | Ssequence
      (Scall None (Evar found_stop _) [Etempvar mario _])
      (Ssequence
        (Scall (Some result) (Evar found_set _)
          [Etempvar action_mario _; Econst_int action _; action_arg])
        (Sreturn (Some (Etempvar returned_result _)))) =>
      Pos.eqb found_stop stop_riding &&
      Pos.eqb found_set set_action &&
      Pos.eqb mario action_mario &&
      Pos.eqb result returned_result &&
      Int.eq action (Int.repr 4864) &&
      is_object_warp_delay_argument action_arg
  | _ => false
  end.

Fixpoint contains_stop_set_disappeared_return_tail_s
    (stop_riding set_action : ident) (body : statement) : bool :=
  is_stop_set_disappeared_return_tail_s stop_riding set_action body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_stop_set_disappeared_return_tail_s
        stop_riding set_action first ||
      contains_stop_set_disappeared_return_tail_s
        stop_riding set_action second
  | Sifthenelse _ yes no =>
      contains_stop_set_disappeared_return_tail_s stop_riding set_action yes ||
      contains_stop_set_disappeared_return_tail_s stop_riding set_action no
  | Sswitch _ cases =>
      contains_stop_set_disappeared_return_tail_ls
        stop_riding set_action cases
  | Slabel _ nested =>
      contains_stop_set_disappeared_return_tail_s
        stop_riding set_action nested
  | _ => false
  end
with contains_stop_set_disappeared_return_tail_ls
    (stop_riding set_action : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_stop_set_disappeared_return_tail_s
        stop_riding set_action body ||
      contains_stop_set_disappeared_return_tail_ls
        stop_riding set_action rest
  end.

Fixpoint contains_nonpipe_disappeared_success_s
    (stop_riding set_action : ident) (body : statement) : bool :=
  match body with
  | Ssequence first second | Sloop first second =>
      contains_nonpipe_disappeared_success_s stop_riding set_action first ||
      contains_nonpipe_disappeared_success_s stop_riding set_action second
  | Sifthenelse condition yes no =>
      (is_nonpipe_action_guard condition &&
       contains_stop_set_disappeared_return_tail_s
         stop_riding set_action yes) ||
      contains_nonpipe_disappeared_success_s stop_riding set_action yes ||
      contains_nonpipe_disappeared_success_s stop_riding set_action no
  | Sswitch _ cases =>
      contains_nonpipe_disappeared_success_ls stop_riding set_action cases
  | Slabel _ nested =>
      contains_nonpipe_disappeared_success_s stop_riding set_action nested
  | _ => false
  end
with contains_nonpipe_disappeared_success_ls
    (stop_riding set_action : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_nonpipe_disappeared_success_s
        stop_riding set_action body ||
      contains_nonpipe_disappeared_success_ls stop_riding set_action rest
  end.

(** Couple that non-pipe action branch to the *false* side of the outer
    fading-bit test, rather than inferring "nonfading" merely from the unique
    action tail. *)
Fixpoint contains_nonfading_disappeared_success_s
    (stop_riding set_action : ident) (body : statement) : bool :=
  match body with
  | Ssequence first second | Sloop first second =>
      contains_nonfading_disappeared_success_s stop_riding set_action first ||
      contains_nonfading_disappeared_success_s stop_riding set_action second
  | Sifthenelse condition yes no =>
      (is_fading_warp_flag_guard condition &&
       contains_nonpipe_disappeared_success_s
         stop_riding set_action no) ||
      contains_nonfading_disappeared_success_s stop_riding set_action yes ||
      contains_nonfading_disappeared_success_s stop_riding set_action no
  | Sswitch _ cases =>
      contains_nonfading_disappeared_success_ls stop_riding set_action cases
  | Slabel _ nested =>
      contains_nonfading_disappeared_success_s stop_riding set_action nested
  | _ => false
  end
with contains_nonfading_disappeared_success_ls
    (stop_riding set_action : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_nonfading_disappeared_success_s
        stop_riding set_action body ||
      contains_nonfading_disappeared_success_ls stop_riding set_action rest
  end.

Definition nonfading_warp_return_source_claim : Prop :=
  contains_nonfading_disappeared_success_s
    A1ISC_USInteraction._mario_stop_riding_object
    A1ISC_USInteraction._set_mario_action
    (fn_body A1ISC_USInteraction.f_interact_warp) = true /\
  contains_nonfading_disappeared_success_s
    A1ISC_JPInteraction._mario_stop_riding_object
    A1ISC_JPInteraction._set_mario_action
    (fn_body A1ISC_JPInteraction.f_interact_warp) = true.

Theorem nonfading_warp_return_source_checked :
  nonfading_warp_return_source_claim.
Proof.
  unfold nonfading_warp_return_source_claim.
  vm_compute. split; reflexivity.
Qed.

(** Match the loop's exact handler data flow: load [table[i].handler], call
    that temporary, then break iff its returned temporary is nonzero. *)
Definition is_table_handler_call_then_break_s
    (table handler_field : ident) (body : statement) : bool :=
  match body with
  | Ssequence
      (Ssequence
        (Sset loaded_handler
          (Efield
            (Ederef
              (Ebinop Oadd (Evar found_table _) (Etempvar _ _) _) _)
            found_handler_field _))
        (Scall (Some result) (Etempvar called_handler _)
          [Etempvar _ _; Etempvar _ _; Etempvar _ _]))
      (Sifthenelse (Etempvar tested_result _) Sbreak Sskip) =>
      Pos.eqb found_table table &&
      Pos.eqb found_handler_field handler_field &&
      Pos.eqb loaded_handler called_handler &&
      Pos.eqb result tested_result
  | _ => false
  end.

Fixpoint contains_table_handler_call_then_break_s
    (table handler_field : ident) (body : statement) : bool :=
  is_table_handler_call_then_break_s table handler_field body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_table_handler_call_then_break_s table handler_field first ||
      contains_table_handler_call_then_break_s table handler_field second
  | Sifthenelse _ yes no =>
      contains_table_handler_call_then_break_s table handler_field yes ||
      contains_table_handler_call_then_break_s table handler_field no
  | Sswitch _ cases =>
      contains_table_handler_call_then_break_ls table handler_field cases
  | Slabel _ nested =>
      contains_table_handler_call_then_break_s table handler_field nested
  | _ => false
  end
with contains_table_handler_call_then_break_ls
    (table handler_field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_table_handler_call_then_break_s table handler_field body ||
      contains_table_handler_call_then_break_ls table handler_field rest
  end.

Definition interaction_nonzero_break_source_claim : Prop :=
  contains_table_handler_call_then_break_s
    A1ISC_USInteraction._sInteractionHandlers A1ISC_USInteraction._handler
    (fn_body A1ISC_USInteraction.f_mario_process_interactions) = true /\
  contains_table_handler_call_then_break_s
    A1ISC_JPInteraction._sInteractionHandlers A1ISC_JPInteraction._handler
    (fn_body A1ISC_JPInteraction.f_mario_process_interactions) = true.

Theorem interaction_nonzero_break_source_checked :
  interaction_nonzero_break_source_claim.
Proof.
  unfold interaction_nonzero_break_source_claim.
  vm_compute. split; reflexivity.
Qed.

(** Collect every explicit return expression, recording [None] for a
    non-literal return.  The dispatcher itself has exactly one return and it
    is the literal one, independently of the action value it stores. *)
Fixpoint returned_int_literals_s (body : statement) : list (option Z) :=
  match body with
  | Sreturn (Some (Econst_int value _)) => [Some (Int.unsigned value)]
  | Sreturn (Some _) => [None]
  | Ssequence first second | Sloop first second =>
      returned_int_literals_s first ++ returned_int_literals_s second
  | Sifthenelse _ yes no =>
      returned_int_literals_s yes ++ returned_int_literals_s no
  | Sswitch _ cases => returned_int_literals_ls cases
  | Slabel _ nested => returned_int_literals_s nested
  | _ => []
  end
with returned_int_literals_ls
    (cases : labeled_statements) : list (option Z) :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      returned_int_literals_s body ++ returned_int_literals_ls rest
  end.

Definition set_mario_action_return_source_claim : Prop :=
  returned_int_literals_s (fn_body A1ISC_USMario.f_set_mario_action) =
    [Some 1] /\
  returned_int_literals_s (fn_body A1ISC_JPMario.f_set_mario_action) =
    [Some 1].

Theorem set_mario_action_return_source_checked :
  set_mario_action_return_source_claim.
Proof.
  unfold set_mario_action_return_source_claim.
  vm_compute. split; reflexivity.
Qed.

(** Direct field-name census for the post-selection spine.  It intentionally
    says "direct": calls, forged aliases, and externals remain framed linked
    obligations.  Only [stop_and_set_height_to_floor] directly assigns a
    State-position component, and that component is Y. *)
Definition direct_state_xyz_write_vector
    (position_field : ident) (body : statement) : list bool :=
  [assigns_array_slot_s position_field 0 body;
   assigns_array_slot_s position_field 1 body;
   assigns_array_slot_s position_field 2 body].

Definition us_postselection_direct_state_xyz_census : list (list bool) :=
  [direct_state_xyz_write_vector A1ISC_USInteraction._pos
     (fn_body A1ISC_USInteraction.f_interact_warp);
   direct_state_xyz_write_vector A1ISC_USInteraction._pos
     (fn_body A1ISC_USInteraction.f_mario_stop_riding_object);
   direct_state_xyz_write_vector A1ISC_USInteraction._pos
     (fn_body A1ISC_USInteraction.f_mario_process_interactions);
   direct_state_xyz_write_vector A1ISC_USInteraction._pos
     (fn_body A1ISC_USInteraction.f_check_kick_or_punch_wall);
   direct_state_xyz_write_vector A1ISC_USMario._pos
     (fn_body A1ISC_USMario.f_set_mario_action);
   direct_state_xyz_write_vector A1ISC_USMario._pos
     (fn_body A1ISC_USMario.f_set_mario_action_cutscene);
   direct_state_xyz_write_vector A1ISC_USCutscene._pos
     (fn_body A1ISC_USCutscene.f_act_disappeared);
   direct_state_xyz_write_vector A1ISC_USStep._pos
     (fn_body A1ISC_USStep.f_stop_and_set_height_to_floor)].

Definition jp_postselection_direct_state_xyz_census : list (list bool) :=
  [direct_state_xyz_write_vector A1ISC_JPInteraction._pos
     (fn_body A1ISC_JPInteraction.f_interact_warp);
   direct_state_xyz_write_vector A1ISC_JPInteraction._pos
     (fn_body A1ISC_JPInteraction.f_mario_stop_riding_object);
   direct_state_xyz_write_vector A1ISC_JPInteraction._pos
     (fn_body A1ISC_JPInteraction.f_mario_process_interactions);
   direct_state_xyz_write_vector A1ISC_JPInteraction._pos
     (fn_body A1ISC_JPInteraction.f_check_kick_or_punch_wall);
   direct_state_xyz_write_vector A1ISC_JPMario._pos
     (fn_body A1ISC_JPMario.f_set_mario_action);
   direct_state_xyz_write_vector A1ISC_JPMario._pos
     (fn_body A1ISC_JPMario.f_set_mario_action_cutscene);
   direct_state_xyz_write_vector A1ISC_JPCutscene._pos
     (fn_body A1ISC_JPCutscene.f_act_disappeared);
   direct_state_xyz_write_vector A1ISC_JPStep._pos
     (fn_body A1ISC_JPStep.f_stop_and_set_height_to_floor)].

Definition expected_postselection_direct_state_xyz_census :
    list (list bool) :=
  [[false; false; false]; [false; false; false];
   [false; false; false]; [false; false; false];
   [false; false; false]; [false; false; false];
   [false; false; false]; [false; true; false]].

Definition postselection_direct_state_xyz_source_claim : Prop :=
  us_postselection_direct_state_xyz_census =
    expected_postselection_direct_state_xyz_census /\
  jp_postselection_direct_state_xyz_census =
    expected_postselection_direct_state_xyz_census.

Theorem postselection_direct_state_xyz_source_checked :
  postselection_direct_state_xyz_source_claim.
Proof.
  unfold postselection_direct_state_xyz_source_claim,
    us_postselection_direct_state_xyz_census,
    jp_postselection_direct_state_xyz_census,
    expected_postselection_direct_state_xyz_census,
    direct_state_xyz_write_vector.
  vm_compute. split; reflexivity.
Qed.

Definition Area1InteractionShortCircuitSourceBoundary : Prop :=
  warp_handler_pair_and_order_source_claim /\
  nonfading_warp_return_source_claim /\
  interaction_nonzero_break_source_claim /\
  set_mario_action_return_source_claim /\
  postselection_direct_state_xyz_source_claim.

Theorem area1_interaction_short_circuit_source_boundary_holds :
  Area1InteractionShortCircuitSourceBoundary.
Proof.
  unfold Area1InteractionShortCircuitSourceBoundary.
  split; [exact warp_handler_pair_and_order_source_checked |].
  split; [exact nonfading_warp_return_source_checked |].
  split; [exact interaction_nonzero_break_source_checked |].
  split; [exact set_mario_action_return_source_checked |].
  exact postselection_direct_state_xyz_source_checked.
Qed.

(** * Conditional linked projection *)

Definition interaction_loop_successor
    (handler_index : nat) (handler_result : Z) : option nat :=
  if Z.eqb handler_result 0 then Some (S handler_index) else None.

(** This record is the schedule-sample boundary not supplied by the syntax
    receipts.  [projected_selection_sample_matches_collision] is only a
    position equality; constructing it from linked execution still requires
    a genuine live-pointer/receiver-identity theorem.  The remaining samples
    separately expose post-copy alias preservation, external-call
    preservation, and the final Object load. *)
Record AcceptedNonfadingWarpRuntimeProjection
    (schedule : UpperWarpSelectionPositionSchedule) : Type := {
  projected_handler_index : nat;
  projected_handler_result : Z;
  projected_next_handler_index : option nat;
  projected_object_after_alias_frame : SchedulePosition;
  projected_object_after_external_frame : SchedulePosition;
  projected_preserved_table_and_faithful_dispatch :
    projected_handler_index = 4%nat;
  projected_faithful_set_mario_action_return :
    projected_handler_result = 1;
  projected_faithful_break_on_nonzero :
    projected_next_handler_index =
      interaction_loop_successor
        projected_handler_index projected_handler_result;
  projected_selection_sample_matches_collision :
    schedule_state_at_selection schedule =
      schedule_collision_object schedule;
  projected_alias_nonoverlap_frame :
    projected_object_after_alias_frame =
      schedule_object_after_copy schedule;
  projected_external_call_frame :
    projected_object_after_external_frame =
      projected_object_after_alias_frame;
  projected_final_query_reads_live_mario_object :
    schedule_final_query schedule =
      projected_object_after_external_frame
}.

Theorem accepted_nonfading_warp_stops_before_later_handlers :
  forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    projected_next_handler_index schedule projection = None.
Proof.
  intros schedule projection.
  rewrite (projected_faithful_break_on_nonzero schedule projection),
    (projected_preserved_table_and_faithful_dispatch schedule projection),
    (projected_faithful_set_mario_action_return schedule projection).
  reflexivity.
Qed.

Theorem accepted_nonfading_warp_final_query_reads_completed_copy :
  forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    schedule_final_query schedule = schedule_object_after_copy schedule.
Proof.
  intros schedule projection.
  rewrite
    (projected_final_query_reads_live_mario_object schedule projection),
    (projected_external_call_frame schedule projection),
    (projected_alias_nonoverlap_frame schedule projection).
  reflexivity.
Qed.

Theorem accepted_nonfading_warp_only_cached_floor_y_can_change_sample :
  forall schedule
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule) ->
    projected_next_handler_index schedule projection = None /\
    cached_floor_snap_differs_from_collision schedule.
Proof.
  intros schedule projection Hgap.
  split.
  - exact (accepted_nonfading_warp_stops_before_later_handlers
      schedule projection).
  - pose proof
      (accepted_nonfading_warp_final_query_reads_completed_copy
        schedule projection) as Hquery.
    rewrite Hquery, schedule_copy_synchronizes_object in Hgap.
    destruct (schedule_disappeared_continuation schedule) as
      [Hunchanged | cached_y Hx Hy Hz].
    + unfold position_differs in Hgap.
      destruct Hgap as [Hdx | [Hdy | Hdz]].
      * exfalso. apply Hdx.
        now rewrite Hunchanged,
          (projected_selection_sample_matches_collision schedule projection).
      * exfalso. apply Hdy.
        now rewrite Hunchanged,
          (projected_selection_sample_matches_collision schedule projection).
      * exfalso. apply Hdz.
        now rewrite Hunchanged,
          (projected_selection_sample_matches_collision schedule projection).
    + unfold position_differs in Hgap.
      destruct Hgap as [Hdx | [Hdy | Hdz]].
      * exfalso. apply Hdx.
        now rewrite Hx,
          (projected_selection_sample_matches_collision schedule projection).
      * unfold cached_floor_snap_differs_from_collision.
        split.
        -- now rewrite
             (projected_selection_sample_matches_collision schedule projection).
        -- exact Hdy.
      * exfalso. apply Hdz.
        now rewrite Hz,
          (projected_selection_sample_matches_collision schedule projection).
Qed.

(** The cached-floor value remains an explicit premise.  This theorem does
    not claim that every live X/Z in the upper-warp envelope selects 768. *)
Theorem accepted_nonfading_warp_cached_y_768_stock_query_is_null :
  forall schedule platform
      (projection : AcceptedNonfadingWarpRuntimeProjection schedule),
    upper_warp_contact
      (position_z_of_schedule (schedule_collision_object schedule)) ->
    schedule_y (schedule_state_after_disappeared schedule) = 768 ->
    stock_area1_final_platform_query
      (position_z_of_schedule (schedule_final_query schedule)) platform ->
    platform = None.
Proof.
  intros schedule platform projection Hcontact Hcached Hstock.
  eapply explicit_cached_y_768_only_stock_query_is_null.
  - exact Hcontact.
  - exact (projected_selection_sample_matches_collision schedule projection).
  - exact Hcached.
  - exact (accepted_nonfading_warp_final_query_reads_completed_copy
      schedule projection).
  - exact Hstock.
Qed.
