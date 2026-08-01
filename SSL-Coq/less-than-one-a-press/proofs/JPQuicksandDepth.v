(** JP quicksand-depth sign closure and the automatic-dialog amplifier.

    The timer-131 conditional fixture needs Graphics substantially above the
    collision Object.  [sink_mario_in_quicksand] subtracts [quicksandDepth]
    from Graphics Y, so it raises Graphics only when that depth is negative.

    This file records three deliberately separate results:

    - generated-Clight syntax receipts for every direct source writer found in
      the Mario/action translation units and the interaction unit;
    - a sign-preservation theorem for a source-shaped, hundredths projection
      with the late long-jump landing writer excluded; and
    - an exact zero-base binary32 endpoint showing that an already-negative
      depth is dangerous in a non-reanchoring automatic-dialog loop.

    It does *not* claim linked-Clight clean-retail closure.  The final
    definitions name the missing memory, control-flow, action-provenance, and
    Graphics-reanchoring refinements.  They are definitions of propositions,
    not assumptions used by any theorem below. *)

From Coq Require Import List Lia ZArith.
From compcert Require Import AST Clight Ctypes Floats Integers.
From LessThanOneAPress.Generated Require Import
  jp_mario jp_mario_actions_airborne jp_mario_actions_automatic
  jp_mario_actions_cutscene jp_mario_actions_moving
  jp_mario_actions_object jp_mario_actions_stationary
  jp_mario_actions_submerged jp_mario_step jp_interaction.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module JQD_Mario := jp_mario.
Module JQD_Air := jp_mario_actions_airborne.
Module JQD_Auto := jp_mario_actions_automatic.
Module JQD_Cut := jp_mario_actions_cutscene.
Module JQD_Move := jp_mario_actions_moving.
Module JQD_Obj := jp_mario_actions_object.
Module JQD_Stationary := jp_mario_actions_stationary.
Module JQD_Submerged := jp_mario_actions_submerged.
Module JQD_Step := jp_mario_step.
Module JQD_Interaction := jp_interaction.

(** Enumerate every internal function in one generated translation unit whose
    body directly assigns a field with the selected name.  This is a syntactic
    inventory.  It does not see stores through an aliased pointer whose source
    type is unrelated, linker aliases, or memory corruption. *)
Fixpoint internal_field_assignment_sites
    (field : ident)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if assigns_field_named_s field (fn_body body)
      then id :: internal_field_assignment_sites field rest
      else internal_field_assignment_sites field rest
  | _ :: rest => internal_field_assignment_sites field rest
  end.

(** These equalities are computed over [prog_defs], not a hand-selected list
    of functions.  Together they match the direct C-field census:

    - [init_mario] initializes depth to zero;
    - airborne, automatic, and submerged dispatchers reset it to zero;
    - [mario_update_quicksand] clamps, increments, caps, or resets it;
    - [common_landing_action] applies the landing adjustment;
    - [quicksand_jump_land_action] subtracts and then clamps;
    - [act_quicksand_death] adds five.

    Stationary, object-action, and interaction files contain callers/readers
    but no direct writer.  This computed scope is intentionally not described
    as the full linked program: generated behavior, object-behavior, engine,
    and level units remain covered by the explicit linked-writer obligation at
    the end of this file. *)
Theorem jp_quicksand_direct_writer_inventory_mario :
  internal_field_assignment_sites
    JQD_Mario._quicksandDepth (prog_defs JQD_Mario.prog) =
  [JQD_Mario._init_mario].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_airborne :
  internal_field_assignment_sites
    JQD_Air._quicksandDepth (prog_defs JQD_Air.prog) =
  [JQD_Air._check_common_airborne_cancels].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_automatic :
  internal_field_assignment_sites
    JQD_Auto._quicksandDepth (prog_defs JQD_Auto.prog) =
  [JQD_Auto._mario_execute_automatic_action].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_cutscene :
  internal_field_assignment_sites
    JQD_Cut._quicksandDepth (prog_defs JQD_Cut.prog) =
  [JQD_Cut._act_quicksand_death].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_moving :
  internal_field_assignment_sites
    JQD_Move._quicksandDepth (prog_defs JQD_Move.prog) =
  [JQD_Move._common_landing_action;
   JQD_Move._quicksand_jump_land_action].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_object :
  internal_field_assignment_sites
    JQD_Obj._quicksandDepth (prog_defs JQD_Obj.prog) = [].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_stationary :
  internal_field_assignment_sites
    JQD_Stationary._quicksandDepth
    (prog_defs JQD_Stationary.prog) = [].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_submerged :
  internal_field_assignment_sites
    JQD_Submerged._quicksandDepth
    (prog_defs JQD_Submerged.prog) =
  [JQD_Submerged._mario_execute_submerged_action].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_step :
  internal_field_assignment_sites
    JQD_Step._quicksandDepth (prog_defs JQD_Step.prog) =
  [JQD_Step._mario_update_quicksand].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_quicksand_direct_writer_inventory_interaction :
  internal_field_assignment_sites
    JQD_Interaction._quicksandDepth
    (prog_defs JQD_Interaction.prog) = [].
Proof. vm_compute. reflexivity. Qed.

(** More precise receipts for the potentially dangerous control shape.
    [act_reading_automatic_dialog] has no direct depth writer.  The outer
    executor contains cutscene dispatch before the final sink call.  This is
    lexical AST evidence only; it is not a proof that a live path reaches both
    calls or that no callee reanchors Graphics. *)
Definition jp_dialog_depth_and_sink_source_shape_claim : Prop :=
  assigns_field_named_s JQD_Cut._quicksandDepth
    (fn_body JQD_Cut.f_act_reading_automatic_dialog) = false /\
  assigns_array_slot_s JQD_Cut._pos 1
    (fn_body JQD_Cut.f_act_reading_automatic_dialog) = false /\
  calls_ident_s JQD_Cut._set_mario_animation
    (fn_body JQD_Cut.f_act_reading_automatic_dialog) = true /\
  assigns_array_slot_s JQD_Mario._pos 1
    (fn_body JQD_Mario.f_set_mario_animation) = false /\
  ident_subsequenceb
    [JQD_Mario._mario_execute_cutscene_action;
     JQD_Mario._sink_mario_in_quicksand]
    (direct_callees_s (fn_body JQD_Mario.f_execute_mario_action)) = true.

Theorem jp_dialog_depth_and_sink_source_shape :
  jp_dialog_depth_and_sink_source_shape_claim.
Proof.
  unfold jp_dialog_depth_and_sink_source_shape_claim.
  vm_compute. repeat split.
Qed.

(** Couple the state pointer used for [m->input], the temporary tested against
    one mask bit, and the first argument of an exact two-literal call.  This
    avoids the weaker (and unsound for control-flow purposes) observation that
    a function merely mentions both the mask and the call somewhere. *)
Definition is_base_two_literal_call_s
    (base callee : ident) (first second : Z)
    (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _)
      [Etempvar found_base _;
       Econst_int found_first _;
       Econst_int found_second _] =>
      Pos.eqb found_base base &&
      Pos.eqb found_callee callee &&
      Int.eq found_first (Int.repr first) &&
      Int.eq found_second (Int.repr second)
  | _ => false
  end.

Fixpoint calls_base_two_literals_s
    (base callee : ident) (first second : Z)
    (s : statement) : bool :=
  is_base_two_literal_call_s base callee first second s ||
  match s with
  | Ssequence lhs rhs | Sloop lhs rhs =>
      calls_base_two_literals_s base callee first second lhs ||
      calls_base_two_literals_s base callee first second rhs
  | Sifthenelse _ yes_branch no_branch =>
      calls_base_two_literals_s base callee first second yes_branch ||
      calls_base_two_literals_s base callee first second no_branch
  | Sswitch _ cases =>
      calls_base_two_literals_ls base callee first second cases
  | Slabel _ body =>
      calls_base_two_literals_s base callee first second body
  | _ => false
  end
with calls_base_two_literals_ls
    (base callee : ident) (first second : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_base_two_literals_s base callee first second body ||
      calls_base_two_literals_ls base callee first second rest
  end.

Definition is_field_mask_guarded_two_literal_call_s
    (field : ident) (mask : Z)
    (callee : ident) (first second : Z)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset guard_temp
        (Efield
          (Ederef (Etempvar state_temp _) _) found_field _))
      (Sifthenelse
        (Ebinop Oand (Etempvar found_guard_temp _)
          (Econst_int found_mask _) _)
        yes_branch _) =>
      Pos.eqb found_field field &&
      Pos.eqb found_guard_temp guard_temp &&
      Int.eq found_mask (Int.repr mask) &&
      calls_base_two_literals_s
        state_temp callee first second yes_branch
  | _ => false
  end.

Fixpoint contains_field_mask_guarded_two_literal_call_s
    (field : ident) (mask : Z)
    (callee : ident) (first second : Z)
    (s : statement) : bool :=
  is_field_mask_guarded_two_literal_call_s
    field mask callee first second s ||
  match s with
  | Ssequence lhs rhs | Sloop lhs rhs =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second lhs ||
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second rhs
  | Sifthenelse _ yes_branch no_branch =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second yes_branch ||
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second no_branch
  | Sswitch _ cases =>
      contains_field_mask_guarded_two_literal_call_ls
        field mask callee first second cases
  | Slabel _ body =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second body
  | _ => false
  end
with contains_field_mask_guarded_two_literal_call_ls
    (field : ident) (mask : Z)
    (callee : ident) (first second : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_field_mask_guarded_two_literal_call_s
        field mask callee first second body ||
      contains_field_mask_guarded_two_literal_call_ls
        field mask callee first second rest
  end.

Fixpoint internal_two_literal_call_sites
    (callee : ident) (first second : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if calls_ident_with_two_int_literals_s
           callee first second (fn_body body)
      then id :: internal_two_literal_call_sites
        callee first second rest
      else internal_two_literal_call_sites callee first second rest
  | _ :: rest =>
      internal_two_literal_call_sites callee first second rest
  end.

(** The sole ordinary source transition into [ACT_LONG_JUMP] is the crouch
    slide A-edge branch in [src/game/mario_actions_moving.c], function
    [act_crouch_slide]: it tests [m->input & INPUT_A_PRESSED] immediately
    before [set_jumping_action(m, ACT_LONG_JUMP, 0)].  The action literal is
    0x03000888 = 50333832.  The long-jump action supplies
    [ACT_LONG_JUMP_LAND] (0x479 = 1145) to [common_air_action_step].

    The equalities below prove those calls occur in the generated functions;
    proving that no pointer corruption or body outside generated coverage can
    install either action remains a linked-program obligation below. *)
Definition jp_long_jump_a_edge_source_shape_claim : Prop :=
  contains_field_mask_guarded_two_literal_call_s
    JQD_Move._input 2 JQD_Move._set_jumping_action 50333832 0
    (fn_body JQD_Move.f_act_crouch_slide) = true /\
  calls_ident_s JQD_Air._common_air_action_step
    (fn_body JQD_Air.f_act_long_jump) = true /\
  statement_mentions_int_s 1145
    (fn_body JQD_Air.f_act_long_jump) = true.

Theorem jp_long_jump_a_edge_source_shape :
  jp_long_jump_a_edge_source_shape_claim.
Proof.
  unfold jp_long_jump_a_edge_source_shape_claim.
  vm_compute. repeat split.
Qed.

(** Within the moving-action translation unit, the exact long-jump helper call
    has one site.  Neither the object-action dispatcher nor the interaction
    unit directly calls [set_jumping_action] or [set_mario_action] with the
    long-jump value.  The airborne landing transition is the separately
    recorded [common_air_action_step] call above. *)
Definition jp_long_jump_selected_unit_call_inventory_claim : Prop :=
  internal_two_literal_call_sites
    JQD_Move._set_jumping_action 50333832 0
    (prog_defs JQD_Move.prog) = [JQD_Move._act_crouch_slide] /\
  internal_two_literal_call_sites
    JQD_Move._set_jumping_action 50333832 0
    (prog_defs JQD_Obj.prog) = [] /\
  internal_two_literal_call_sites
    JQD_Move._set_mario_action 50333832 0
    (prog_defs JQD_Obj.prog) = [] /\
  internal_two_literal_call_sites
    JQD_Move._set_jumping_action 50333832 0
    (prog_defs JQD_Interaction.prog) = [] /\
  internal_two_literal_call_sites
    JQD_Move._set_mario_action 50333832 0
    (prog_defs JQD_Interaction.prog) = [].

Theorem jp_long_jump_selected_unit_call_inventory :
  jp_long_jump_selected_unit_call_inventory_claim.
Proof.
  unfold jp_long_jump_selected_unit_call_inventory_claim.
  vm_compute. repeat split.
Qed.

(** * Sign closure in the source-shaped decimal projection *)

(** Depths are measured in hundredths, so every decimal constant used by the
    relevant C writers is integral: 1.1 = 110, 0.25 = 25, 0.5 = 50,
    0.8 = 80, 3.5 = 350, and 5.0 = 500.  This is not silently substituted for
    binary32.  [JPQuicksandBinary32ProjectionRefinementObligation] below names
    the required live-Clight connection. *)
Definition JPDepthHundredths := Z.

(** The source-shaped writer relation used by the sign argument.  It excludes
    the late (six-frame) long-jump landing writer by construction.  The
    separate linked action-provenance obligation below must prove that a real
    no-A execution is contained in this relation. *)
Inductive JPSourceShapedSafeDepthWrite :
    JPDepthHundredths -> JPDepthHundredths -> Prop :=
| JPDepthReset :
    forall before,
      JPSourceShapedSafeDepthWrite before 0
| JPDepthClampedIncrement :
    forall before speed,
      0 <= speed ->
      JPSourceShapedSafeDepthWrite before (Z.max 110 before + speed)
| JPDepthPositiveCap :
    forall before cap,
      0 <= cap ->
      JPSourceShapedSafeDepthWrite before cap
| JPDepthShortLandingAdjustment :
    forall before timer,
      1 <= timer <= 3 ->
      JPSourceShapedSafeDepthWrite before
        (before + (4 - timer) * 350 - 50)
| JPDepthQuicksandJumpUnclamped :
    forall before timer,
      1 <= timer <= 6 ->
      100 <= before - (7 - timer) * 80 ->
      JPSourceShapedSafeDepthWrite before
        (before - (7 - timer) * 80)
| JPDepthQuicksandJumpClamped :
    forall before timer,
      1 <= timer <= 6 ->
      before - (7 - timer) * 80 < 100 ->
      JPSourceShapedSafeDepthWrite before 110
| JPDepthDeathIncrement :
    forall before,
      JPSourceShapedSafeDepthWrite before (before + 500)
| JPDepthPreserved :
    forall before,
      JPSourceShapedSafeDepthWrite before before.

Theorem jp_source_shaped_safe_depth_writer_preserves_nonnegative :
  forall before after,
    0 <= before ->
    JPSourceShapedSafeDepthWrite before after ->
    0 <= after.
Proof.
  intros before after Hbefore Hwrite.
  inversion Hwrite; subst; try lia.
Qed.

Inductive JPSourceShapedSafeDepthTrace :
    JPDepthHundredths -> JPDepthHundredths -> Prop :=
| JPDepthTraceRefl :
    forall depth,
      JPSourceShapedSafeDepthTrace depth depth
| JPDepthTraceStep :
    forall before middle after,
      JPSourceShapedSafeDepthWrite before middle ->
      JPSourceShapedSafeDepthTrace middle after ->
      JPSourceShapedSafeDepthTrace before after.

Theorem jp_source_shaped_safe_depth_trace_preserves_nonnegative :
  forall before after,
    0 <= before ->
    JPSourceShapedSafeDepthTrace before after ->
    0 <= after.
Proof.
  intros before after Hbefore Htrace.
  induction Htrace.
  - exact Hbefore.
  - apply IHHtrace.
    eapply jp_source_shaped_safe_depth_writer_preserves_nonnegative; eauto.
Qed.

Corollary jp_source_shaped_safe_depth_trace_from_zero_is_nonnegative :
  forall depth,
    JPSourceShapedSafeDepthTrace 0 depth ->
    0 <= depth.
Proof.
  intros depth Htrace.
  eapply jp_source_shaped_safe_depth_trace_preserves_nonnegative; eauto.
  lia.
Qed.

(** If the general landing formula creates a negative depth from a
    nonnegative input, its post-increment timer is at least four.  All ordinary
    landing descriptors other than long-jump have [numFrames = 4], so their
    common-cancel path exits before such a writer.  Connecting that descriptor
    and action-dispatch fact to live Clight is left explicit below. *)
Theorem jp_negative_common_landing_requires_late_timer :
  forall before timer after,
    0 <= before ->
    1 <= timer <= 5 ->
    after = before + (4 - timer) * 350 - 50 ->
    after < 0 ->
    4 <= timer.
Proof. intros; lia. Qed.

(** On a real moving-dispatch frame, the preceding 1.1 clamp plus 0.25
    increment gives at least 1.35 (135 hundredths).  Under that stronger
    premise, timer four cannot cross zero; the only negative iteration is the
    fifth and final body frame of the six-frame landing descriptor. *)
Theorem jp_negative_common_landing_after_dispatch_is_timer_five :
  forall before timer after,
    135 <= before ->
    1 <= timer <= 5 ->
    after = before + (4 - timer) * 350 - 50 ->
    after < 0 ->
    timer = 5.
Proof. intros; lia. Qed.

(** The fifth long-jump landing frame is a genuine source-level negative
    witness if it first encounters quicksand with the minimum clamped depth.
    In hundredths: 110 + 25 - 400 = -265. *)
Theorem jp_prepared_late_long_jump_landing_is_negative :
  110 + 25 + (4 - 5) * 350 - 50 = -265 /\
  -265 < 0.
Proof. lia. Qed.

(** Exact CompCert binary32 replay of the same writer. *)
Definition jp_prepared_depth_after_update : float32 :=
  Float32.add
    (Float32.of_bits (Int.repr 1066192077))  (* 1.1f *)
    (Float32.of_bits (Int.repr 1048576000)). (* 0.25f *)

Definition jp_prepared_negative_depth : float32 :=
  Float32.sub jp_prepared_depth_after_update
    (Float32.of_bits (Int.repr 1082130432)). (* 4.0f *)

Theorem jp_prepared_negative_depth_binary32_checked :
  Float32.to_bits jp_prepared_depth_after_update =
    Int.repr 1068289229 /\
  Float32.to_bits jp_prepared_negative_depth =
    Int.repr 3223951770.
Proof. vm_compute. split; reflexivity. Qed.

(** * Conditional automatic-dialog amplification *)

Fixpoint jp_repeat_binary32_sink
    (ticks : nat) (depth graphics_y : float32) : float32 :=
  match ticks with
  | O => graphics_y
  | S remaining =>
      Float32.sub
        (jp_repeat_binary32_sink remaining depth graphics_y)
        depth
  end.

(** If the prepared negative value could enter an unreanchored automatic
    dialog, 363 sink calls starting from a +0.0 Graphics base produce an
    endpoint at least 960.0.  Binary32 addition is not translation-invariant,
    so this does not prove a 960-unit delta from an arbitrary live base. *)
Theorem jp_negative_depth_dialog_zero_base_endpoint_binary32_checked :
  Float32.cmp Cle
    (Float32.of_bits (Int.repr 1148190720)) (* 960.0f *)
    (jp_repeat_binary32_sink 363 jp_prepared_negative_depth
      (Float32.of_bits (Int.repr 0))) = true.
Proof. vm_compute. reflexivity. Qed.

Fixpoint jp_repeat_projected_sink
    (ticks : nat) (depth gap : Z) : Z :=
  match ticks with
  | O => gap
  | S remaining => jp_repeat_projected_sink remaining depth gap - depth
  end.

Theorem jp_nonnegative_depth_dialog_cannot_increase_gap :
  forall ticks depth gap,
    0 <= depth ->
    jp_repeat_projected_sink ticks depth gap <= gap.
Proof.
  induction ticks as [| ticks IH]; intros depth gap Hdepth.
  - cbn. lia.
  - cbn [jp_repeat_projected_sink].
    specialize (IH depth gap Hdepth).
    lia.
Qed.

Theorem jp_prepared_negative_dialog_reaches_960_projected :
  jp_repeat_projected_sink 363 (-265) 0 = 96195 /\
  96000 <= 96195.
Proof.
  split.
  - vm_compute. reflexivity.
  - lia.
Qed.

(** * Precisely named remaining retail obligations *)

Definition jp_quicksand_direct_writer_ids : list ident :=
  [JQD_Mario._init_mario;
   JQD_Air._check_common_airborne_cancels;
   JQD_Auto._mario_execute_automatic_action;
   JQD_Cut._act_quicksand_death;
   JQD_Move._common_landing_action;
   JQD_Move._quicksand_jump_land_action;
   JQD_Submerged._mario_execute_submerged_action;
   JQD_Step._mario_update_quicksand].

(** Prove over the linked JP Clight program and live memory that every write
    to the selected MarioState cell during a clean Area-1 trace is represented
    by one of the inventoried functions above (including non-aliasing and
    absence of out-of-bounds/corrupting stores). *)
Definition JPQuicksandLinkedWriterCoverageObligation
    (is_clean_reachable_depth_writer : ident -> Prop) : Prop :=
  forall writer,
    is_clean_reachable_depth_writer writer ->
    In writer jp_quicksand_direct_writer_ids.

(** Prove that a clean JP Area-1 execution with [INPUT_A_PRESSED] false cannot
    reach [ACT_LONG_JUMP], [ACT_LONG_JUMP_LAND], or a forged equivalent
    action/timer combination.  The generated syntax receipt identifies the
    ordinary A-edge constructor but does not establish this whole-program
    provenance theorem. *)
Definition JPCleanNoEdgeLongJumpProvenanceObligation
    (is_clean_no_edge_action_timer : Z -> Z -> Prop) : Prop :=
  forall action timer,
    is_clean_no_edge_action_timer action timer ->
    action <> 50333832 /\ action <> 1145.

(** Refine the hundredths sign theorem to the exact binary32 loads/stores of
    the generated bodies, including finite-value, pointer-validity, and
    non-aliasing premises derived from clean live memory. *)
Definition JPQuicksandBinary32ProjectionRefinementObligation
    (is_clean_live_depth_write : float32 -> float32 -> Prop)
    (projects_to_hundredths : float32 -> Z -> Prop) : Prop :=
  forall before_float after_float,
    is_clean_live_depth_write before_float after_float ->
    exists before_depth after_depth,
      projects_to_hundredths before_float before_depth /\
      projects_to_hundredths after_float after_depth /\
      JPSourceShapedSafeDepthWrite before_depth after_depth.

(** Establish which clean SSL Area-1 paths can enter the automatic-dialog
    action, whether Graphics is reanchored by every intervening action/object
    tail, and whether a retained depth reaches the final sink on each loop.
    This is intentionally separate from sign closure: a negative value is
    harmless to the proposed installer if the relevant handler is unreachable
    or reanchors Graphics before collision can use the accumulated gap. *)
Definition JPArea1DialogAndGraphicsReachabilityObligation
    (is_clean_area1_dialog_sink_sample : float32 -> bool -> Prop) : Prop :=
  forall depth graphics_reanchored,
    is_clean_area1_dialog_sink_sample depth graphics_reanchored ->
    Float32.cmp Clt depth (Float32.of_bits (Int.repr 0)) <> true \/
    graphics_reanchored = true.

(** Logical packaging for the three named escapes.  No theorem here derives
    this disjunction from a clean negative-depth execution; that linked
    reduction remains part of the writer/action/refinement obligations above. *)
Definition JPCleanNegativeDepthEscape
    (uncovered_writer forged_long_jump binary32_refinement_failure : Prop) :
    Prop :=
  uncovered_writer \/ forged_long_jump \/ binary32_refinement_failure.

Theorem jp_named_negative_depth_escapes_absent_if_each_is_impossible :
  forall (uncovered_writer forged_long_jump
      binary32_refinement_failure : Prop),
    (uncovered_writer -> False) ->
    (forged_long_jump -> False) ->
    (binary32_refinement_failure -> False) ->
    ~ JPCleanNegativeDepthEscape
        uncovered_writer forged_long_jump binary32_refinement_failure.
Proof.
  intros uncovered forged refinement Huncovered Hforged Hrefinement
    [H | [H | H]]; auto.
Qed.
