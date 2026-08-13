(** Source-backed scheduling closure for the Area-1 upper-warp frame.

    This module narrows two installer branches that were previously left as
    generic possibilities:

    - movement after the object-warp interaction but before the final platform
      query; and
    - a non-null platform pointer carried across frames that skip the final
      query.

    The generated Clight receipts establish the relevant US/JP call and
    assignment shapes.  A small finite schedule then records the relevant
    stock branches: a full update with Mario running, a full update in which
    Mario is frozen, a null-[gMarioObject] early return, or a frame with no
    object update.  It also separates an upper-warp frame whose graphical
    floor retry stays null from one that dispatches [ACT_DISAPPEARED].  The
    resulting theorems prove that either interaction/action-selection branch has a later
    final query in the finite model, while that model skips an effective query
    only at the checked null early return or by skipping the object update.
    The floor-null branch
    is not a successful Area-2 warp: geometry input requested death before the
    cached interaction, and the separate fatal-latch proof shows why merely
    selecting [ACT_DISAPPEARED] does not replace that request.  The two
    NULL-callback change-area frames preserve only the result of the last
    completed query in the finite schedule model.

    The positional decomposition is deliberately conditional on a faithful
    projection of a live execution.  It shows that a final-query sample away
    from the collision sample must come from one of four places: the
    pre-interaction State sample, the graphical fallback sample, the cached
    floor-height snap, or an unclassified discrepancy after State-to-Object
    copying.  The last alternative is not silently called a writer here:
    whole-program execution, alias, and external-frame results are still
    needed to identify its cause or eliminate it. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_interaction us_level_update us_mario us_mario_actions_cutscene
  us_mario_step us_object_list_processor us_platform_displacement
  jp_interaction jp_level_update jp_mario jp_mario_actions_cutscene
  jp_mario_step jp_object_list_processor jp_platform_displacement.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module A1QUSInteraction := us_interaction.
Module A1QUSLevel := us_level_update.
Module A1QUSMario := us_mario.
Module A1QUSCutscene := us_mario_actions_cutscene.
Module A1QUSStep := us_mario_step.
Module A1QUSObjects := us_object_list_processor.
Module A1QUSPlatform := us_platform_displacement.

Module A1QJPInteraction := jp_interaction.
Module A1QJPLevel := jp_level_update.
Module A1QJPMario := jp_mario.
Module A1QJPCutscene := jp_mario_actions_cutscene.
Module A1QJPStep := jp_mario_step.
Module A1QJPObjects := jp_object_list_processor.
Module A1QJPPlatform := jp_platform_displacement.

Record SchedulePosition : Type := {
  schedule_x : Z;
  schedule_y : Z;
  schedule_z : Z
}.

Definition schedule_horizontal_distance_squared
    (left right : SchedulePosition) : Z :=
  let dx := schedule_x left - schedule_x right in
  let dz := schedule_z left - schedule_z right in
  dx * dx + dz * dz.

Definition schedule_upper_warp_center : SchedulePosition :=
  {| schedule_x := -2048; schedule_y := 768; schedule_z := -1024 |}.

(** The same integer hitbox test used by [PyramidTopPU.upper_warp_contact],
    repeated locally so this scheduling certificate need not load the much
    larger geometry dependency cone. *)
Definition schedule_upper_warp_contact (mario : SchedulePosition) : Prop :=
  schedule_horizontal_distance_squared mario schedule_upper_warp_center <
    (150 + 37) * (150 + 37) /\
  schedule_y mario <= 768 + 50 /\
  768 <= schedule_y mario + 160.

(** Count direct calls to one identifier.  The result remains a syntax fact;
    it does not assert that a call under a branch executes. *)
Definition direct_call_count (callee : ident) (body : statement) : nat :=
  count_occ Pos.eq_dec (direct_callees_s body) callee.

Fixpoint global_assignment_count_s
    (target : ident) (body : statement) : nat :=
  match body with
  | Sassign (Evar found _) _ =>
      if Pos.eqb found target then 1%nat else 0%nat
  | Ssequence first second
  | Sloop first second =>
      (global_assignment_count_s target first +
       global_assignment_count_s target second)%nat
  | Sifthenelse _ yes no =>
      (global_assignment_count_s target yes +
       global_assignment_count_s target no)%nat
  | Sswitch _ cases => global_assignment_count_ls target cases
  | Slabel _ nested => global_assignment_count_s target nested
  | _ => 0%nat
  end
with global_assignment_count_ls
    (target : ident) (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (global_assignment_count_s target body +
       global_assignment_count_ls target rest)%nat
  end.

(** Match the exact normal-warp action constructor

      set_mario_action(m, ACT_DISAPPEARED,
                       (WARP_OP_WARP_OBJECT << 16) + 2).

    In the pinned translations the relevant literals are 4864, 4, 16, and 2.
    Keeping them in one expression prevents unrelated constants elsewhere in
    [interact_warp] from satisfying the receipt. *)
Definition is_object_warp_disappeared_call_s
    (callee : ident) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found _)
      [Etempvar _ _;
       Econst_int action _;
       Ebinop Oadd
         (Ebinop Oshl (Econst_int operation _) (Econst_int shift _) _)
         (Econst_int delay _) _] =>
      Pos.eqb found callee &&
      Int.eq action (Int.repr 4864) &&
      Int.eq operation (Int.repr 4) &&
      Int.eq shift (Int.repr 16) &&
      Int.eq delay (Int.repr 2)
  | _ => false
  end.

Fixpoint contains_object_warp_disappeared_call_s
    (callee : ident) (body : statement) : bool :=
  is_object_warp_disappeared_call_s callee body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_object_warp_disappeared_call_s callee first ||
      contains_object_warp_disappeared_call_s callee second
  | Sifthenelse _ yes no =>
      contains_object_warp_disappeared_call_s callee yes ||
      contains_object_warp_disappeared_call_s callee no
  | Sswitch _ cases =>
      contains_object_warp_disappeared_call_ls callee cases
  | Slabel _ nested =>
      contains_object_warp_disappeared_call_s callee nested
  | _ => false
  end
with contains_object_warp_disappeared_call_ls
    (callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_object_warp_disappeared_call_s callee body ||
      contains_object_warp_disappeared_call_ls callee rest
  end.

(** Match [level_set_transition(2, NULL)] at the delayed object-warp site. *)
Definition is_two_frame_null_transition_call_s
    (callee : ident) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found _)
      [Econst_int timer _; Ecast (Econst_int null_value _) _] =>
      Pos.eqb found callee &&
      Int.eq timer (Int.repr 2) &&
      Int.eq null_value Int.zero
  | _ => false
  end.

Fixpoint contains_two_frame_null_transition_call_s
    (callee : ident) (body : statement) : bool :=
  is_two_frame_null_transition_call_s callee body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_two_frame_null_transition_call_s callee first ||
      contains_two_frame_null_transition_call_s callee second
  | Sifthenelse _ yes no =>
      contains_two_frame_null_transition_call_s callee yes ||
      contains_two_frame_null_transition_call_s callee no
  | Sswitch _ cases =>
      contains_two_frame_null_transition_call_ls callee cases
  | Slabel _ nested =>
      contains_two_frame_null_transition_call_s callee nested
  | _ => false
  end
with contains_two_frame_null_transition_call_ls
    (callee : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_two_frame_null_transition_call_s callee body ||
      contains_two_frame_null_transition_call_ls callee rest
  end.

Fixpoint assigns_global_from_temp_s
    (target source : ident) (body : statement) : bool :=
  match body with
  | Sassign (Evar found_target _) (Etempvar found_source _) =>
      Pos.eqb found_target target && Pos.eqb found_source source
  | Ssequence first second | Sloop first second =>
      assigns_global_from_temp_s target source first ||
      assigns_global_from_temp_s target source second
  | Sifthenelse _ yes no =>
      assigns_global_from_temp_s target source yes ||
      assigns_global_from_temp_s target source no
  | Sswitch _ cases => assigns_global_from_temp_ls target source cases
  | Slabel _ nested => assigns_global_from_temp_s target source nested
  | _ => false
  end
with assigns_global_from_temp_ls
    (target source : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_global_from_temp_s target source body ||
      assigns_global_from_temp_ls target source rest
  end.

(** Match the two early-return guards that matter to this schedule:

    - [execute_mario_action] loads [gMarioState->floor] and returns zero when
      it is null, after interactions but before action dispatch; and
    - [update_mario_platform] returns immediately when [gMarioObject] is
      null, before its floor query or any [gMarioPlatform] assignment.

    These recognizers are intentionally local source receipts.  Their
    concrete branch execution and the values of the loaded globals remain
    memory-refinement obligations. *)
Definition is_floor_null_return_zero_s
    (mario_state_global floor_field : ident) (body : statement) : bool :=
  match body with
  | Ssequence
      (Sset state_temp (Evar found_mario_state_global _))
      (Ssequence
        (Sset floor_temp
          (Efield (Ederef (Etempvar loaded_state_temp _) _)
            found_floor_field _))
        (Sifthenelse condition
          (Sreturn (Some (Econst_int result _))) Sskip)) =>
      Pos.eqb found_mario_state_global mario_state_global &&
      Pos.eqb loaded_state_temp state_temp &&
      Pos.eqb found_floor_field floor_field &&
      is_null_test_of_temp floor_temp condition &&
      Int.eq result Int.zero
  | _ => false
  end.

Fixpoint contains_floor_null_return_zero_s
    (mario_state_global floor_field : ident) (body : statement) : bool :=
  is_floor_null_return_zero_s mario_state_global floor_field body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_floor_null_return_zero_s mario_state_global floor_field first ||
      contains_floor_null_return_zero_s mario_state_global floor_field second
  | Sifthenelse _ yes no =>
      contains_floor_null_return_zero_s mario_state_global floor_field yes ||
      contains_floor_null_return_zero_s mario_state_global floor_field no
  | Sswitch _ cases =>
      contains_floor_null_return_zero_ls mario_state_global floor_field cases
  | Slabel _ nested =>
      contains_floor_null_return_zero_s mario_state_global floor_field nested
  | _ => false
  end
with contains_floor_null_return_zero_ls
    (mario_state_global floor_field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_floor_null_return_zero_s
        mario_state_global floor_field body ||
      contains_floor_null_return_zero_ls
        mario_state_global floor_field rest
  end.

Definition is_global_null_return_void_s
    (global : ident) (body : statement) : bool :=
  match body with
  | Ssequence
      (Sset loaded_temp (Evar found_global _))
      (Sifthenelse condition (Sreturn None) Sskip) =>
      Pos.eqb found_global global &&
      is_null_test_of_temp loaded_temp condition
  | _ => false
  end.

Fixpoint contains_global_null_return_void_s
    (global : ident) (body : statement) : bool :=
  is_global_null_return_void_s global body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_global_null_return_void_s global first ||
      contains_global_null_return_void_s global second
  | Sifthenelse _ yes no =>
      contains_global_null_return_void_s global yes ||
      contains_global_null_return_void_s global no
  | Sswitch _ cases => contains_global_null_return_void_ls global cases
  | Slabel _ nested => contains_global_null_return_void_s global nested
  | _ => false
  end
with contains_global_null_return_void_ls
    (global : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_global_null_return_void_s global body ||
      contains_global_null_return_void_ls global rest
  end.

(** Base-sensitive receipt for the [vec3f_copy] inside
    [stop_and_set_height_to_floor]: destination is Object.header.gfx.pos and
    source is MarioState.pos. *)
Definition is_state_to_graphics_position_copy_s
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (body : statement) : bool :=
  match body with
  | Scall None (Evar found_callee _)
      [Efield
        (Efield
          (Efield
            (Ederef _ (Tstruct found_object_tag _)) found_header_field _)
          found_graphics_field _)
        found_destination_position _;
       Efield
         (Ederef _ (Tstruct found_mario_state_tag _))
         found_source_position _] =>
      Pos.eqb found_callee copy_callee &&
      Pos.eqb found_object_tag object_tag &&
      Pos.eqb found_mario_state_tag mario_state_tag &&
      Pos.eqb found_header_field header_field &&
      Pos.eqb found_graphics_field graphics_field &&
      Pos.eqb found_destination_position position_field &&
      Pos.eqb found_source_position position_field
  | _ => false
  end.

Fixpoint contains_state_to_graphics_position_copy_s
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (body : statement) : bool :=
  is_state_to_graphics_position_copy_s
    copy_callee object_tag mario_state_tag header_field graphics_field
    position_field body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field first ||
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field second
  | Sifthenelse _ yes no =>
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field yes ||
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field no
  | Sswitch _ cases =>
      contains_state_to_graphics_position_copy_ls
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field cases
  | Slabel _ nested =>
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field nested
  | _ => false
  end
with contains_state_to_graphics_position_copy_ls
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_state_to_graphics_position_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field body ||
      contains_state_to_graphics_position_copy_ls
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field rest
  end.

(** The handler-table entry couples [INTERACT_WARP] (8192) to
    [interact_warp]. *)
Definition area1_warp_handler_table_source_claim : Prop :=
  firstn 2
    (skipn 8 (gvar_init A1QUSInteraction.v_sInteractionHandlers)) =
      [Init_int32 (Int.repr 8192);
       Init_addrof A1QUSInteraction._interact_warp Ptrofs.zero] /\
  firstn 2
    (skipn 8 (gvar_init A1QJPInteraction.v_sInteractionHandlers)) =
      [Init_int32 (Int.repr 8192);
       Init_addrof A1QJPInteraction._interact_warp Ptrofs.zero].

Theorem area1_warp_handler_table_source_checked :
  area1_warp_handler_table_source_claim.
Proof.
  unfold area1_warp_handler_table_source_claim.
  vm_compute.
  split; reflexivity.
Qed.

(** Generated-Clight intraprocedural call-order receipts.  The exact
    direct-callee lists for [act_disappeared] and
    [stop_and_set_height_to_floor] are especially useful: after the warp
    handler selects [ACT_DISAPPEARED], the stock action has no ordinary motion
    step.  It performs the cached-floor Y snap and copies State to Graphics;
    [bhv_mario_update] later copies State to the raw collision object. *)
Definition area1_active_warp_schedule_source_claim : Prop :=
  ident_subsequenceb
    [A1QUSObjects._clear_dynamic_surfaces;
     A1QUSObjects._update_terrain_objects;
     A1QUSObjects._apply_mario_platform_displacement;
     A1QUSObjects._detect_object_collisions;
     A1QUSObjects._update_non_terrain_objects;
     A1QUSObjects._unload_deactivated_objects;
     A1QUSObjects._update_mario_platform]
    (direct_callees_s (fn_body A1QUSObjects.f_update_objects)) = true /\
  ident_subsequenceb
    [A1QJPObjects._clear_dynamic_surfaces;
     A1QJPObjects._update_terrain_objects;
     A1QJPObjects._apply_mario_platform_displacement;
     A1QJPObjects._detect_object_collisions;
     A1QJPObjects._update_non_terrain_objects;
     A1QJPObjects._unload_deactivated_objects;
     A1QJPObjects._update_mario_platform]
    (direct_callees_s (fn_body A1QJPObjects.f_update_objects)) = true /\
  direct_call_count A1QUSObjects._apply_mario_platform_displacement
    (fn_body A1QUSObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QUSObjects._detect_object_collisions
    (fn_body A1QUSObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QUSObjects._update_non_terrain_objects
    (fn_body A1QUSObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QUSObjects._unload_deactivated_objects
    (fn_body A1QUSObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QUSObjects._update_mario_platform
    (fn_body A1QUSObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QJPObjects._apply_mario_platform_displacement
    (fn_body A1QJPObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QJPObjects._detect_object_collisions
    (fn_body A1QJPObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QJPObjects._update_non_terrain_objects
    (fn_body A1QJPObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QJPObjects._unload_deactivated_objects
    (fn_body A1QJPObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QJPObjects._update_mario_platform
    (fn_body A1QJPObjects.f_update_objects) = 1%nat /\
  direct_call_count A1QUSObjects._execute_mario_action
    (fn_body A1QUSObjects.f_bhv_mario_update) = 1%nat /\
  direct_call_count A1QUSObjects._copy_mario_state_to_object
    (fn_body A1QUSObjects.f_bhv_mario_update) = 1%nat /\
  direct_call_count A1QJPObjects._execute_mario_action
    (fn_body A1QJPObjects.f_bhv_mario_update) = 1%nat /\
  direct_call_count A1QJPObjects._copy_mario_state_to_object
    (fn_body A1QJPObjects.f_bhv_mario_update) = 1%nat /\
  firstn 2 (direct_callees_s (fn_body A1QUSObjects.f_bhv_mario_update)) =
    [A1QUSObjects._execute_mario_action;
     A1QUSObjects._copy_mario_state_to_object] /\
  firstn 2 (direct_callees_s (fn_body A1QJPObjects.f_bhv_mario_update)) =
    [A1QJPObjects._execute_mario_action;
     A1QJPObjects._copy_mario_state_to_object] /\
  ident_subsequenceb
    [A1QUSMario._update_mario_inputs;
     A1QUSMario._mario_process_interactions;
     A1QUSMario._mario_execute_cutscene_action]
    (direct_callees_s (fn_body A1QUSMario.f_execute_mario_action)) = true /\
  ident_subsequenceb
    [A1QJPMario._update_mario_inputs;
     A1QJPMario._mario_process_interactions;
     A1QJPMario._mario_execute_cutscene_action]
    (direct_callees_s (fn_body A1QJPMario.f_execute_mario_action)) = true /\
  contains_guarded_graphics_floor_retry_s
    A1QUSMario._floor A1QUSMario._marioObj A1QUSMario._header
    A1QUSMario._vec3f_copy A1QUSMario._find_floor A1QUSMario._gfx
    A1QUSMario._pos A1QUSMario._floorHeight
    (fn_body A1QUSMario.f_update_mario_geometry_inputs) = true /\
  contains_guarded_graphics_floor_retry_s
    A1QJPMario._floor A1QJPMario._marioObj A1QJPMario._header
    A1QJPMario._vec3f_copy A1QJPMario._find_floor A1QJPMario._gfx
    A1QJPMario._pos A1QJPMario._floorHeight
    (fn_body A1QJPMario.f_update_mario_geometry_inputs) = true /\
  contains_guarded_floor_null_else_call_s
    A1QUSMario._m A1QUSMario._floor A1QUSMario._level_trigger_warp 18
    (fn_body A1QUSMario.f_update_mario_geometry_inputs) = true /\
  contains_guarded_floor_null_else_call_s
    A1QJPMario._m A1QJPMario._floor A1QJPMario._level_trigger_warp 18
    (fn_body A1QJPMario.f_update_mario_geometry_inputs) = true /\
  contains_floor_null_return_zero_s
    A1QUSMario._gMarioState A1QUSMario._floor
    (fn_body A1QUSMario.f_execute_mario_action) = true /\
  contains_floor_null_return_zero_s
    A1QJPMario._gMarioState A1QJPMario._floor
    (fn_body A1QJPMario.f_execute_mario_action) = true /\
  contains_object_warp_disappeared_call_s
    A1QUSInteraction._set_mario_action
    (fn_body A1QUSInteraction.f_interact_warp) = true /\
  contains_object_warp_disappeared_call_s
    A1QJPInteraction._set_mario_action
    (fn_body A1QJPInteraction.f_interact_warp) = true /\
  direct_callees_s (fn_body A1QUSCutscene.f_act_disappeared) =
    [A1QUSCutscene._set_mario_animation;
     A1QUSCutscene._stop_and_set_height_to_floor;
     A1QUSCutscene._level_trigger_warp] /\
  direct_callees_s (fn_body A1QJPCutscene.f_act_disappeared) =
    [A1QJPCutscene._set_mario_animation;
     A1QJPCutscene._stop_and_set_height_to_floor;
     A1QJPCutscene._level_trigger_warp] /\
  direct_callees_s
    (fn_body A1QUSStep.f_stop_and_set_height_to_floor) =
    [A1QUSStep._mario_set_forward_vel;
     A1QUSStep._vec3f_copy;
     A1QUSStep._vec3s_set] /\
  direct_callees_s
    (fn_body A1QJPStep.f_stop_and_set_height_to_floor) =
    [A1QJPStep._mario_set_forward_vel;
     A1QJPStep._vec3f_copy;
     A1QJPStep._vec3s_set] /\
  assigns_array_slot_s A1QUSStep._pos 0
    (fn_body A1QUSStep.f_stop_and_set_height_to_floor) = false /\
  assigns_array_slot_s A1QUSStep._pos 1
    (fn_body A1QUSStep.f_stop_and_set_height_to_floor) = true /\
  assigns_array_slot_s A1QUSStep._pos 2
    (fn_body A1QUSStep.f_stop_and_set_height_to_floor) = false /\
  assigns_array_slot_s A1QJPStep._pos 0
    (fn_body A1QJPStep.f_stop_and_set_height_to_floor) = false /\
  assigns_array_slot_s A1QJPStep._pos 1
    (fn_body A1QJPStep.f_stop_and_set_height_to_floor) = true /\
  assigns_array_slot_s A1QJPStep._pos 2
    (fn_body A1QJPStep.f_stop_and_set_height_to_floor) = false /\
  contains_state_to_graphics_position_copy_s
    A1QUSStep._vec3f_copy A1QUSStep._Object A1QUSStep._MarioState
    A1QUSStep._header A1QUSStep._gfx A1QUSStep._pos
    (fn_body A1QUSStep.f_stop_and_set_height_to_floor) = true /\
  contains_state_to_graphics_position_copy_s
    A1QJPStep._vec3f_copy A1QJPStep._Object A1QJPStep._MarioState
    A1QJPStep._header A1QJPStep._gfx A1QJPStep._pos
    (fn_body A1QJPStep.f_stop_and_set_height_to_floor) = true.

Theorem area1_active_warp_schedule_source_checked :
  area1_active_warp_schedule_source_claim.
Proof.
  unfold area1_active_warp_schedule_source_claim, direct_call_count.
  repeat split;
    vm_compute;
    reflexivity.
Qed.

(** Direct-lvalue census for the code executed after [interact_warp] starts
    unwinding.  The handler, its riding-state helper, and the interaction-tail
    kick/punch helper contain no direct assignment to any component of
    [MarioState.pos].  The only direct State-position assignment in the
    disappeared helper is the cached-floor Y write already recorded above.

    This does not prove a frame condition for calls or pointer aliases.  In
    particular, [resolve_and_return_wall_collisions], [set_mario_action], and
    external helpers still require the linked-memory effect proof listed at
    the end of this file. *)
Definition area1_post_selection_direct_writer_source_claim : Prop :=
  assigns_array_slot_s A1QUSInteraction._pos 0
    (fn_body A1QUSInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 1
    (fn_body A1QUSInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 2
    (fn_body A1QUSInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 0
    (fn_body A1QJPInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 1
    (fn_body A1QJPInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 2
    (fn_body A1QJPInteraction.f_interact_warp) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 0
    (fn_body A1QUSInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 1
    (fn_body A1QUSInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 2
    (fn_body A1QUSInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 0
    (fn_body A1QJPInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 1
    (fn_body A1QJPInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 2
    (fn_body A1QJPInteraction.f_mario_stop_riding_object) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 0
    (fn_body A1QUSInteraction.f_check_kick_or_punch_wall) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 1
    (fn_body A1QUSInteraction.f_check_kick_or_punch_wall) = false /\
  assigns_array_slot_s A1QUSInteraction._pos 2
    (fn_body A1QUSInteraction.f_check_kick_or_punch_wall) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 0
    (fn_body A1QJPInteraction.f_check_kick_or_punch_wall) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 1
    (fn_body A1QJPInteraction.f_check_kick_or_punch_wall) = false /\
  assigns_array_slot_s A1QJPInteraction._pos 2
    (fn_body A1QJPInteraction.f_check_kick_or_punch_wall) = false.

Theorem area1_post_selection_direct_writer_source_checked :
  area1_post_selection_direct_writer_source_claim.
Proof.
  unfold area1_post_selection_direct_writer_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Match one of the three straight-line loads used to build the final
    platform query:

      object_temp := gMarioObject;
      coordinate_temp := object_temp->rawData.asF32[raw_index].

    Unlike a field-name occurrence check, this couples the global pointer,
    receiver temporary, raw-data selector, array slot, and destination
    temporary in one generated fragment. *)
Definition is_global_raw_object_coordinate_load_s
    (mario_object_global raw_data as_f32 coordinate_temp : ident)
    (raw_index : Z) (body : statement) : bool :=
  match body with
  | Ssequence
      (Sset object_temp (Evar found_global _))
      (Sset found_coordinate_temp
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar source_object_temp _) _)
                found_raw_data _)
              found_as_f32 _)
            offset _) _)) =>
      Pos.eqb found_global mario_object_global &&
      Pos.eqb source_object_temp object_temp &&
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_as_f32 as_f32 &&
      Pos.eqb found_coordinate_temp coordinate_temp &&
      match expression_const_int_z offset with
      | Some found_index => Z.eqb found_index raw_index
      | None => false
      end
  | _ => false
  end.

Definition is_find_floor_from_coordinate_temps_s
    (find_floor x_temp y_temp z_temp : ident) (body : statement) : bool :=
  match body with
  | Scall _ (Evar found_find_floor _)
      [Etempvar found_x_temp _;
       Etempvar found_y_temp _;
       Etempvar found_z_temp _;
       _] =>
      Pos.eqb found_find_floor find_floor &&
      Pos.eqb found_x_temp x_temp &&
      Pos.eqb found_y_temp y_temp &&
      Pos.eqb found_z_temp z_temp
  | _ => false
  end.

(** Match the exact straight-line query prefix emitted by [clightgen].  The
    three coordinate loads are contiguous and the very next effectful
    statement is [find_floor(marioX, marioY, marioZ, ...)].  This establishes
    query-time source dataflow only; it does not frame the raw Object cells to
    the following frame's collision sample. *)
Definition is_final_query_from_raw_mario_object_prefix_s
    (mario_object_global raw_data as_f32 find_floor
      x_temp y_temp z_temp : ident) (body : statement) : bool :=
  match body with
  | Ssequence x_load
      (Ssequence y_load
        (Ssequence z_load
          (Ssequence
            (Ssequence query _)
            _))) =>
      is_global_raw_object_coordinate_load_s
        mario_object_global raw_data as_f32 x_temp 6 x_load &&
      is_global_raw_object_coordinate_load_s
        mario_object_global raw_data as_f32 y_temp 7 y_load &&
      is_global_raw_object_coordinate_load_s
        mario_object_global raw_data as_f32 z_temp 8 z_load &&
      is_find_floor_from_coordinate_temps_s
        find_floor x_temp y_temp z_temp query
  | _ => false
  end.

Fixpoint contains_final_query_from_raw_mario_object_prefix_s
    (mario_object_global raw_data as_f32 find_floor
      x_temp y_temp z_temp : ident) (body : statement) : bool :=
  is_final_query_from_raw_mario_object_prefix_s
    mario_object_global raw_data as_f32 find_floor
    x_temp y_temp z_temp body ||
  match body with
  | Ssequence first second | Sloop first second =>
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp first ||
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp second
  | Sifthenelse _ yes no =>
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp yes ||
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp no
  | Sswitch _ cases =>
      contains_final_query_from_raw_mario_object_prefix_ls
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp cases
  | Slabel _ nested =>
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp nested
  | _ => false
  end
with contains_final_query_from_raw_mario_object_prefix_ls
    (mario_object_global raw_data as_f32 find_floor
      x_temp y_temp z_temp : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_final_query_from_raw_mario_object_prefix_s
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp body ||
      contains_final_query_from_raw_mario_object_prefix_ls
        mario_object_global raw_data as_f32 find_floor
        x_temp y_temp z_temp rest
  end.

(** [update_mario_platform] has one early return, guarded by a null Mario
    object.  Past that guard it calls [find_floor] once and contains exactly
    three assignments to [gMarioPlatform]: the away-from-floor case, the
    object-owned-floor case, and its null alternative.  The final two
    conjuncts additionally pin the query arguments to the immediately loaded
    raw Mario Object coordinates.  Lifting these source receipts to live
    execution and preserving that Object sample to the next collision still
    require the Clight control-flow, non-alias, and memory-frame proof named at
    the end. *)
Definition area1_final_query_overwrite_source_claim : Prop :=
  direct_callees_s
    (fn_body A1QUSPlatform.f_update_mario_platform) =
      [A1QUSPlatform._find_floor; A1QUSPlatform._absf] /\
  direct_callees_s
    (fn_body A1QJPPlatform.f_update_mario_platform) =
      [A1QJPPlatform._find_floor; A1QJPPlatform._absf] /\
  global_assignment_count_s A1QUSPlatform._gMarioPlatform
    (fn_body A1QUSPlatform.f_update_mario_platform) = 3%nat /\
  global_assignment_count_s A1QJPPlatform._gMarioPlatform
    (fn_body A1QJPPlatform.f_update_mario_platform) = 3%nat /\
  calls_ident_s A1QUSPlatform._find_floor
    (fn_body A1QUSPlatform.f_update_mario_platform) = true /\
  calls_ident_s A1QJPPlatform._find_floor
    (fn_body A1QJPPlatform.f_update_mario_platform) = true /\
  contains_global_null_return_void_s A1QUSPlatform._gMarioObject
    (fn_body A1QUSPlatform.f_update_mario_platform) = true /\
  contains_global_null_return_void_s A1QJPPlatform._gMarioObject
    (fn_body A1QJPPlatform.f_update_mario_platform) = true /\
  statement_mentions_ident_s A1QUSPlatform._object
    (fn_body A1QUSPlatform.f_update_mario_platform) = true /\
  statement_mentions_ident_s A1QJPPlatform._object
    (fn_body A1QJPPlatform.f_update_mario_platform) = true /\
  contains_final_query_from_raw_mario_object_prefix_s
    A1QUSPlatform._gMarioObject A1QUSPlatform._rawData
    A1QUSPlatform._asF32 A1QUSPlatform._find_floor
    A1QUSPlatform._marioX A1QUSPlatform._marioY A1QUSPlatform._marioZ
    (fn_body A1QUSPlatform.f_update_mario_platform) = true /\
  contains_final_query_from_raw_mario_object_prefix_s
    A1QJPPlatform._gMarioObject A1QJPPlatform._rawData
    A1QJPPlatform._asF32 A1QJPPlatform._find_floor
    A1QJPPlatform._marioX A1QJPPlatform._marioY A1QJPPlatform._marioZ
    (fn_body A1QJPPlatform.f_update_mario_platform) = true.

Theorem area1_final_query_overwrite_source_checked :
  area1_final_query_overwrite_source_claim.
Proof.
  unfold area1_final_query_overwrite_source_claim.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Scheduler receipts.  Full normal play and [basic_update] call the object
    updater.  Pause, NULL-callback change-area, and change-level bodies do not.
    Frame advance delegates to normal play only on its active branch.  The
    object-warp transition is installed with timer 2 and a NULL update
    callback. *)
Definition area1_scheduler_source_claim : Prop :=
  direct_call_count A1QUSLevel._area_update_objects
    (fn_body A1QUSLevel.f_play_mode_normal) = 1%nat /\
  direct_call_count A1QJPLevel._area_update_objects
    (fn_body A1QJPLevel.f_play_mode_normal) = 1%nat /\
  direct_call_count A1QUSLevel._area_update_objects
    (fn_body A1QUSLevel.f_basic_update) = 1%nat /\
  direct_call_count A1QJPLevel._area_update_objects
    (fn_body A1QJPLevel.f_basic_update) = 1%nat /\
  direct_call_count A1QUSLevel._area_update_objects
    (fn_body A1QUSLevel.f_play_mode_paused) = 0%nat /\
  direct_call_count A1QJPLevel._area_update_objects
    (fn_body A1QJPLevel.f_play_mode_paused) = 0%nat /\
  direct_call_count A1QUSLevel._play_mode_normal
    (fn_body A1QUSLevel.f_play_mode_frame_advance) = 1%nat /\
  direct_call_count A1QJPLevel._play_mode_normal
    (fn_body A1QJPLevel.f_play_mode_frame_advance) = 1%nat /\
  direct_call_count A1QUSLevel._area_update_objects
    (fn_body A1QUSLevel.f_play_mode_change_area) = 0%nat /\
  direct_call_count A1QJPLevel._area_update_objects
    (fn_body A1QJPLevel.f_play_mode_change_area) = 0%nat /\
  direct_call_count A1QUSLevel._area_update_objects
    (fn_body A1QUSLevel.f_play_mode_change_level) = 0%nat /\
  direct_call_count A1QJPLevel._area_update_objects
    (fn_body A1QJPLevel.f_play_mode_change_level) = 0%nat /\
  contains_two_frame_null_transition_call_s
    A1QUSLevel._level_set_transition
    (fn_body A1QUSLevel.f_initiate_delayed_warp) = true /\
  contains_two_frame_null_transition_call_s
    A1QJPLevel._level_set_transition
    (fn_body A1QJPLevel.f_initiate_delayed_warp) = true /\
  assigns_global_from_temp_s
    A1QUSLevel._sTransitionTimer A1QUSLevel._length
    (fn_body A1QUSLevel.f_level_set_transition) = true /\
  assigns_global_from_temp_s
    A1QJPLevel._sTransitionTimer A1QJPLevel._length
    (fn_body A1QJPLevel.f_level_set_transition) = true /\
  assigns_global_from_temp_s
    A1QUSLevel._sTransitionUpdate A1QUSLevel._updateFunction
    (fn_body A1QUSLevel.f_level_set_transition) = true /\
  assigns_global_from_temp_s
    A1QJPLevel._sTransitionUpdate A1QJPLevel._updateFunction
    (fn_body A1QJPLevel.f_level_set_transition) = true /\
  statement_mentions_ident_s A1QUSPlatform._gMarioPlatform
    (fn_body A1QUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1QJPPlatform._gMarioPlatform
    (fn_body A1QJPLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1QUSLevel._gMarioStates
    (fn_body A1QUSLevel.f_play_mode_change_area) = false /\
  statement_mentions_ident_s A1QJPLevel._gMarioStates
    (fn_body A1QJPLevel.f_play_mode_change_area) = false /\
  ident_subsequenceb
    [A1QUSLevel._warp_area; A1QUSLevel._area_update_objects]
    (direct_callees_s (fn_body A1QUSLevel.f_play_mode_normal)) = true /\
  ident_subsequenceb
    [A1QJPLevel._warp_area; A1QJPLevel._area_update_objects]
    (direct_callees_s (fn_body A1QJPLevel.f_play_mode_normal)) = true.

Theorem area1_scheduler_source_checked :
  area1_scheduler_source_claim.
Proof.
  unfold area1_scheduler_source_claim, direct_call_count.
  vm_compute.
  repeat split; reflexivity.
Qed.

(** Abstract call events.  [ApplyCachedPlatform] names the call, not a proof
    that its time-stop/platform guards take the displacement branch. *)
Inductive Area1ScheduleEvent : Type :=
| ScheduleClearDynamicSurfaces
| ScheduleUpdateTerrain
| ScheduleApplyCachedPlatform
| ScheduleDetectObjectCollisions
| ScheduleUpdateGeometryInputs
| ScheduleProcessInteractions
| ScheduleSelectUpperWarpDisappeared
| ScheduleDispatchDisappeared
| ScheduleReturnBeforeActionDispatch
| ScheduleCopyStateToObject
| ScheduleUnloadDeactivatedObjects
| ScheduleFinalPlatformQuery
| ScheduleFinalPlatformEarlyReturn.

Definition area1_active_no_mario_events : list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformQuery].

Definition area1_active_mario_no_warp_events : list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUpdateGeometryInputs;
   ScheduleProcessInteractions;
   ScheduleCopyStateToObject;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformQuery].

(** A later frame of the delayed object-warp continuation.  The object has
    already been marked interacted, so this frame can dispatch
    [ACT_DISAPPEARED] without calling [interact_warp] again. *)
Definition area1_active_disappeared_continuation_events :
    list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUpdateGeometryInputs;
   ScheduleProcessInteractions;
   ScheduleDispatchDisappeared;
   ScheduleCopyStateToObject;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformQuery].

Definition area1_active_upper_warp_events : list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUpdateGeometryInputs;
   ScheduleProcessInteractions;
   ScheduleSelectUpperWarpDisappeared;
   ScheduleDispatchDisappeared;
   ScheduleCopyStateToObject;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformQuery].

(** If the second graphical floor lookup is still null, the death request is
    made during geometry input.  Interaction processing can nevertheless set
    [ACT_DISAPPEARED], after which [execute_mario_action] returns before action
    dispatch.  [bhv_mario_update] still performs the raw Object copy and the
    outer object update still reaches its final platform call.  This is an
    action selection only: the earlier fatal request makes it unusable as a
    successful Area-2 warp under [RetailFatalLatch]'s separately checked event
    boundary. *)
Definition area1_active_upper_warp_floor_null_events :
    list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUpdateGeometryInputs;
   ScheduleProcessInteractions;
   ScheduleSelectUpperWarpDisappeared;
   ScheduleReturnBeforeActionDispatch;
   ScheduleCopyStateToObject;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformQuery].

(** In the finite model the checked null-[gMarioObject] early return skips the
    effective final query.  The function is called, but neither [find_floor]
    nor a [gMarioPlatform] assignment executes.  Exhaustiveness for linked
    retail branches remains an explicit refinement obligation. *)
Definition area1_active_null_mario_object_events :
    list Area1ScheduleEvent :=
  [ScheduleClearDynamicSurfaces;
   ScheduleUpdateTerrain;
   ScheduleApplyCachedPlatform;
   ScheduleDetectObjectCollisions;
   ScheduleUnloadDeactivatedObjects;
   ScheduleFinalPlatformEarlyReturn].

Inductive ModeledArea1FrameSchedule : Type :=
| FullUpdateMarioFrozen
| FullUpdateMarioNoWarp
| FullUpdateDisappearedContinuation
| FullUpdateUpperWarpSelection
| FullUpdateUpperWarpSelectionFloorNull
| FullUpdateNullMarioObject
| PausedNoUpdate
| FrameAdvanceNoUpdate
| NullCallbackAreaTransition
| NullCallbackLevelTransition.

Definition stock_area1_schedule_events
    (shape : ModeledArea1FrameSchedule) : list Area1ScheduleEvent :=
  match shape with
  | FullUpdateMarioFrozen => area1_active_no_mario_events
  | FullUpdateMarioNoWarp => area1_active_mario_no_warp_events
  | FullUpdateDisappearedContinuation =>
      area1_active_disappeared_continuation_events
  | FullUpdateUpperWarpSelection => area1_active_upper_warp_events
  | FullUpdateUpperWarpSelectionFloorNull =>
      area1_active_upper_warp_floor_null_events
  | FullUpdateNullMarioObject => area1_active_null_mario_object_events
  | PausedNoUpdate
  | FrameAdvanceNoUpdate
  | NullCallbackAreaTransition
  | NullCallbackLevelTransition => []
  end.

Definition schedule_contains
    (event : Area1ScheduleEvent) (events : list Area1ScheduleEvent) : Prop :=
  In event events.

Theorem modeled_schedule_queries_returns_early_or_skips_update :
  forall shape,
    schedule_contains ScheduleFinalPlatformQuery
      (stock_area1_schedule_events shape) \/
    schedule_contains ScheduleFinalPlatformEarlyReturn
      (stock_area1_schedule_events shape) \/
    stock_area1_schedule_events shape = [].
Proof.
  intros shape.
  destruct shape; cbn; intuition.
Qed.

Theorem a_schedule_that_selects_upper_warp_action_has_final_query :
  forall shape,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    schedule_contains ScheduleFinalPlatformQuery
      (stock_area1_schedule_events shape).
Proof.
  intros shape Hselection.
  destruct shape; unfold schedule_contains in *; cbn in *;
    intuition discriminate.
Qed.

Theorem query_free_schedule_cannot_select_upper_warp_action :
  forall shape,
    ~ schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) ->
    ~ schedule_contains ScheduleSelectUpperWarpDisappeared
        (stock_area1_schedule_events shape).
Proof.
  intros shape Hno_query Hselection.
  apply Hno_query.
  eapply a_schedule_that_selects_upper_warp_action_has_final_query.
  exact Hselection.
Qed.

Theorem modeled_effective_query_is_skipped_only_by_null_return_or_no_update :
  forall shape,
    ~ schedule_contains ScheduleFinalPlatformQuery
        (stock_area1_schedule_events shape) ->
    schedule_contains ScheduleFinalPlatformEarlyReturn
      (stock_area1_schedule_events shape) \/
    stock_area1_schedule_events shape = [].
Proof.
  intros shape Hno_query.
  destruct shape; cbn in *; intuition.
Qed.

Definition area1_schedule_event_eq_dec :
  forall left right : Area1ScheduleEvent,
    {left = right} + {left <> right}.
Proof. decide equality. Defined.

Fixpoint schedule_event_subsequenceb
    (wanted found : list Area1ScheduleEvent) : bool :=
  match wanted, found with
  | [], _ => true
  | _, [] => false
  | wanted_head :: wanted_tail, found_head :: found_tail =>
      if area1_schedule_event_eq_dec wanted_head found_head
      then schedule_event_subsequenceb wanted_tail found_tail
      else schedule_event_subsequenceb wanted found_tail
  end.

Theorem upper_warp_schedule_has_apply_collision_copy_query_order :
  schedule_event_subsequenceb
    [ScheduleApplyCachedPlatform;
     ScheduleDetectObjectCollisions;
     ScheduleSelectUpperWarpDisappeared;
     ScheduleCopyStateToObject;
     ScheduleFinalPlatformQuery]
    area1_active_upper_warp_events = true.
Proof. reflexivity. Qed.

Theorem floor_null_upper_warp_schedule_has_apply_collision_copy_query_order :
  schedule_event_subsequenceb
    [ScheduleApplyCachedPlatform;
     ScheduleDetectObjectCollisions;
     ScheduleSelectUpperWarpDisappeared;
     ScheduleReturnBeforeActionDispatch;
     ScheduleCopyStateToObject;
     ScheduleFinalPlatformQuery]
    area1_active_upper_warp_floor_null_events = true.
Proof. reflexivity. Qed.

(** The stock NULL-callback change-area transition stores no events from the
    object pipeline.  This functional mirror changes only the countdown and
    mode; its pointer and three Mario views are carried verbatim. *)
Inductive AbstractPlayMode : Type :=
| AbstractChangeArea
| AbstractNormal.

Record NullCallbackTransitionState (pointer : Type) : Type := {
  null_transition_mode : AbstractPlayMode;
  null_transition_timer : nat;
  null_transition_platform : option pointer;
  null_transition_state_position : SchedulePosition;
  null_transition_object_position : SchedulePosition;
  null_transition_graphics_position : SchedulePosition
}.

Arguments null_transition_mode {pointer} _.
Arguments null_transition_timer {pointer} _.
Arguments null_transition_platform {pointer} _.
Arguments null_transition_state_position {pointer} _.
Arguments null_transition_object_position {pointer} _.
Arguments null_transition_graphics_position {pointer} _.

Definition null_callback_change_area_step {pointer}
    (state : NullCallbackTransitionState pointer) :
    NullCallbackTransitionState pointer :=
  match null_transition_timer state with
  | O => state
  | S remaining =>
      {| null_transition_mode :=
           match remaining with
           | O => AbstractNormal
           | S _ => AbstractChangeArea
           end;
         null_transition_timer := remaining;
         null_transition_platform := null_transition_platform state;
         null_transition_state_position :=
           null_transition_state_position state;
         null_transition_object_position :=
           null_transition_object_position state;
         null_transition_graphics_position :=
           null_transition_graphics_position state |}
  end.

Definition begin_two_frame_null_transition {pointer}
    (platform : option pointer)
    (state_position object_position graphics_position : SchedulePosition) :
    NullCallbackTransitionState pointer :=
  {| null_transition_mode := AbstractChangeArea;
     null_transition_timer := 2%nat;
     null_transition_platform := platform;
     null_transition_state_position := state_position;
     null_transition_object_position := object_position;
     null_transition_graphics_position := graphics_position |}.

(** Functional mirror of the early return in [update_mario_platform].  It can
    preserve a pointer installed by an earlier effective query, but it cannot
    manufacture a pointer from [None]. *)
Definition null_mario_final_platform_return {pointer}
    (state : NullCallbackTransitionState pointer) :
    NullCallbackTransitionState pointer := state.

Theorem null_mario_early_return_preserves_only_the_prior_pointer :
  forall pointer (state : NullCallbackTransitionState pointer),
    null_transition_platform (null_mario_final_platform_return state) =
      null_transition_platform state.
Proof. reflexivity. Qed.

Theorem null_mario_early_return_cannot_install_from_none :
  forall pointer (state : NullCallbackTransitionState pointer),
    null_transition_platform state = None ->
    null_transition_platform (null_mario_final_platform_return state) = None.
Proof. intros; assumption. Qed.

Theorem two_null_callback_frames_preserve_query_result_and_views :
  forall pointer (platform : option pointer)
      state_position object_position graphics_position,
    let initial := begin_two_frame_null_transition
      platform state_position object_position graphics_position in
    let after_one := null_callback_change_area_step initial in
    let after_two := null_callback_change_area_step after_one in
    null_transition_timer after_one = 1%nat /\
    null_transition_mode after_one = AbstractChangeArea /\
    null_transition_timer after_two = 0%nat /\
    null_transition_mode after_two = AbstractNormal /\
    null_transition_platform after_two = platform /\
    null_transition_state_position after_two = state_position /\
    null_transition_object_position after_two = object_position /\
    null_transition_graphics_position after_two = graphics_position.
Proof.
  intros.
  cbn.
  repeat split; reflexivity.
Qed.

Theorem two_null_callback_frames_have_no_installer_events :
  stock_area1_schedule_events NullCallbackAreaTransition ++
  stock_area1_schedule_events NullCallbackAreaTransition = [].
Proof. reflexivity. Qed.

(** Position provenance around interaction/action selection. *)
Inductive GeometrySampleChoice
    (state_before graphics_before state_at_selection : SchedulePosition) : Prop :=
| GeometryKeptState :
    state_at_selection = state_before ->
    GeometrySampleChoice state_before graphics_before state_at_selection
| GeometryUsedGraphicsRetry :
    state_at_selection = graphics_before ->
    GeometrySampleChoice state_before graphics_before state_at_selection.

Inductive DisappearedContinuation
    (state_at_selection state_after : SchedulePosition) : Prop :=
| DisappearedActionNotRunForNullFloor :
    state_after = state_at_selection ->
    DisappearedContinuation state_at_selection state_after
| DisappearedSnappedToCachedFloor :
    forall cached_floor_y,
      schedule_x state_after = schedule_x state_at_selection ->
      schedule_y state_after = cached_floor_y ->
      schedule_z state_after = schedule_z state_at_selection ->
      DisappearedContinuation state_at_selection state_after.

Inductive FinalQuerySampleDisposition
    (copied_object final_query : SchedulePosition) : Prop :=
| FinalQueryReadsCopiedObject :
    final_query = copied_object ->
    FinalQuerySampleDisposition copied_object final_query
| FinalQueryHasPostCopyDiscrepancy :
    final_query <> copied_object ->
    FinalQuerySampleDisposition copied_object final_query.

Record UpperWarpSelectionPositionSchedule : Type := {
  schedule_collision_object : SchedulePosition;
  schedule_state_before_geometry : SchedulePosition;
  schedule_graphics_before_geometry : SchedulePosition;
  schedule_state_at_selection : SchedulePosition;
  schedule_state_after_disappeared : SchedulePosition;
  schedule_object_after_copy : SchedulePosition;
  schedule_final_query : SchedulePosition;
  schedule_geometry_choice :
    GeometrySampleChoice
      schedule_state_before_geometry
      schedule_graphics_before_geometry
      schedule_state_at_selection;
  schedule_disappeared_continuation :
    DisappearedContinuation
      schedule_state_at_selection schedule_state_after_disappeared;
  schedule_copy_synchronizes_object :
    schedule_object_after_copy = schedule_state_after_disappeared;
  schedule_final_query_disposition :
    FinalQuerySampleDisposition
      schedule_object_after_copy schedule_final_query
}.

Definition position_differs (left right : SchedulePosition) : Prop :=
  schedule_x left <> schedule_x right \/
  schedule_y left <> schedule_y right \/
  schedule_z left <> schedule_z right.

Definition post_copy_sample_discrepancy
    (schedule : UpperWarpSelectionPositionSchedule) : Prop :=
  schedule_final_query schedule <>
    schedule_object_after_copy schedule.

Definition cached_floor_snap_differs_from_collision
    (schedule : UpperWarpSelectionPositionSchedule) : Prop :=
  schedule_y (schedule_state_after_disappeared schedule) <>
    schedule_y (schedule_state_at_selection schedule) /\
  schedule_y (schedule_state_after_disappeared schedule) <>
    schedule_y (schedule_collision_object schedule).

Definition position_z_eq_dec :
  forall left right : SchedulePosition, {left = right} + {left <> right}.
Proof.
  decide equality; apply Z.eq_dec.
Defined.

Theorem final_query_disposition_is_exhaustive :
  forall copied_object final_query,
    FinalQuerySampleDisposition copied_object final_query.
Proof.
  intros copied_object final_query.
  destruct (position_z_eq_dec final_query copied_object) as
    [Hequal | Hdifferent].
  - apply FinalQueryReadsCopiedObject. exact Hequal.
  - apply FinalQueryHasPostCopyDiscrepancy. exact Hdifferent.
Qed.

(** Exhaustive only for [UpperWarpSelectionPositionSchedule], whose constructors
    assume the State-or-Graphics choice and unchanged-or-cached-Y continuation.
    Here [schedule_state_before_geometry] means the State sample *after* the two
    wall-collision calls and immediately before the floor queries.  In the
    absence of a post-copy discrepancy, a final-query/collision difference was
    already present in that State sample or the Graphics sample, except for the
    cached-floor Y snap performed by [ACT_DISAPPEARED]. *)
Theorem final_query_gap_fits_four_abstract_cases :
  forall schedule,
    position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule) ->
    position_differs
      (schedule_state_before_geometry schedule)
      (schedule_collision_object schedule) \/
    position_differs
      (schedule_graphics_before_geometry schedule)
      (schedule_collision_object schedule) \/
    cached_floor_snap_differs_from_collision schedule \/
    post_copy_sample_discrepancy schedule.
Proof.
  intros schedule Hgap.
  destruct (schedule_final_query_disposition schedule) as
    [Hquery | Hpostcopy].
  - rewrite Hquery, schedule_copy_synchronizes_object in Hgap.
    destruct (schedule_geometry_choice schedule) as
      [Hstate | Hgraphics].
    + destruct (schedule_disappeared_continuation schedule) as
        [Hunchanged | cached_floor_y Hx Hy Hz].
      * left.
        rewrite Hunchanged, Hstate in Hgap.
        exact Hgap.
      * unfold position_differs in Hgap.
        destruct Hgap as [Hdx | [Hdy | Hdz]].
        -- left. left. intro Hequal.
           apply Hdx. rewrite Hx, Hstate. exact Hequal.
        -- destruct (Z.eq_dec
             (schedule_y (schedule_state_after_disappeared schedule))
             (schedule_y (schedule_state_at_selection schedule))) as
             [Hsame_y | Hchanged_y].
           ++ left. right. left. intro Hequal.
              apply Hdy. rewrite Hsame_y, Hstate. exact Hequal.
           ++ right. right. left.
              split; [exact Hchanged_y | exact Hdy].
        -- left. right. right. intro Hequal.
           apply Hdz. rewrite Hz, Hstate. exact Hequal.
    + destruct (schedule_disappeared_continuation schedule) as
        [Hunchanged | cached_floor_y Hx Hy Hz].
      * right. left.
        rewrite Hunchanged, Hgraphics in Hgap.
        exact Hgap.
      * unfold position_differs in Hgap.
        destruct Hgap as [Hdx | [Hdy | Hdz]].
        -- right. left. left. intro Hequal.
           apply Hdx. rewrite Hx, Hgraphics. exact Hequal.
        -- destruct (Z.eq_dec
             (schedule_y (schedule_state_after_disappeared schedule))
             (schedule_y (schedule_state_at_selection schedule))) as
             [Hsame_y | Hchanged_y].
           ++ right. left. right. left. intro Hequal.
              apply Hdy. rewrite Hsame_y, Hgraphics. exact Hequal.
           ++ right. right. left.
              split; [exact Hchanged_y | exact Hdy].
        -- right. left. right. right. intro Hequal.
           apply Hdz. rewrite Hz, Hgraphics. exact Hequal.
  - right. right. right.
    exact Hpostcopy.
Qed.

(** A stronger horizontal corollary: [stop_and_set_height_to_floor] cannot
    create X/Z separation.  Without a post-copy sample discrepancy, any
    horizontal offset at the final query was already present in State or
    Graphics before interaction/action selection. *)
Definition horizontal_position_differs
    (left right : SchedulePosition) : Prop :=
  schedule_x left <> schedule_x right \/
  schedule_z left <> schedule_z right.

Theorem final_query_horizontal_gap_is_preselection_or_postcopy_discrepancy :
  forall schedule,
    horizontal_position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule) ->
    horizontal_position_differs
      (schedule_state_before_geometry schedule)
      (schedule_collision_object schedule) \/
    horizontal_position_differs
      (schedule_graphics_before_geometry schedule)
      (schedule_collision_object schedule) \/
    post_copy_sample_discrepancy schedule.
Proof.
  intros schedule Hgap.
  destruct (schedule_final_query_disposition schedule) as
    [Hquery | Hpostcopy].
  - destruct (schedule_geometry_choice schedule) as
      [Hstate | Hgraphics].
    + left.
      unfold horizontal_position_differs in *.
      destruct (schedule_disappeared_continuation schedule) as
        [Hunchanged | cached_floor_y Hx Hy Hz].
      * rewrite Hquery, schedule_copy_synchronizes_object,
          Hunchanged, Hstate in Hgap.
        exact Hgap.
      * destruct Hgap as [Hdx | Hdz].
        -- left. intro Hequal. apply Hdx. rewrite Hquery,
             schedule_copy_synchronizes_object, Hx, Hstate. exact Hequal.
        -- right. intro Hequal. apply Hdz. rewrite Hquery,
             schedule_copy_synchronizes_object, Hz, Hstate. exact Hequal.
    + right. left.
      unfold horizontal_position_differs in *.
      destruct (schedule_disappeared_continuation schedule) as
        [Hunchanged | cached_floor_y Hx Hy Hz].
      * rewrite Hquery, schedule_copy_synchronizes_object,
          Hunchanged, Hgraphics in Hgap.
        exact Hgap.
      * destruct Hgap as [Hdx | Hdz].
        -- left. intro Hequal. apply Hdx. rewrite Hquery,
             schedule_copy_synchronizes_object, Hx, Hgraphics. exact Hequal.
        -- right. intro Hequal. apply Hdz. rewrite Hquery,
             schedule_copy_synchronizes_object, Hz, Hgraphics. exact Hequal.
  - right. right. exact Hpostcopy.
Qed.

(** A deliberately non-retail countermodel showing why the post-copy
    discrepancy branch cannot be deleted on call ordering alone.  All three pre-geometry
    views start at the upper-warp sample and the disappeared continuation is
    position preserving, but an unconstrained post-copy sample differs at the
    final query.  A whole-program execution/non-alias/frame proof must identify
    or rule out the cause; this is not a gameplay witness or a writer proof. *)
Definition schedule_warp_sample : SchedulePosition :=
  {| schedule_x := -2048; schedule_y := 768; schedule_z := -1024 |}.

Definition schedule_arbitrary_post_copy_sample : SchedulePosition :=
  {| schedule_x := -1641; schedule_y := 1456; schedule_z := -783 |}.

Definition arbitrary_post_copy_discrepancy_countermodel :
    UpperWarpSelectionPositionSchedule.
Proof.
  refine
    {| schedule_collision_object := schedule_warp_sample;
       schedule_state_before_geometry := schedule_warp_sample;
       schedule_graphics_before_geometry := schedule_warp_sample;
       schedule_state_at_selection := schedule_warp_sample;
       schedule_state_after_disappeared := schedule_warp_sample;
       schedule_object_after_copy := schedule_warp_sample;
       schedule_final_query := schedule_arbitrary_post_copy_sample |}.
  - apply GeometryKeptState. reflexivity.
  - apply DisappearedActionNotRunForNullFloor. reflexivity.
  - reflexivity.
  - apply FinalQueryHasPostCopyDiscrepancy.
    discriminate.
Defined.

Theorem arbitrary_post_copy_discrepancy_countermodel_is_the_open_branch :
  schedule_upper_warp_contact
    (schedule_collision_object arbitrary_post_copy_discrepancy_countermodel) /\
  horizontal_position_differs
    (schedule_final_query arbitrary_post_copy_discrepancy_countermodel)
    (schedule_collision_object arbitrary_post_copy_discrepancy_countermodel) /\
  post_copy_sample_discrepancy arbitrary_post_copy_discrepancy_countermodel.
Proof.
  split.
  - unfold schedule_upper_warp_contact,
      schedule_horizontal_distance_squared, schedule_upper_warp_center,
      arbitrary_post_copy_discrepancy_countermodel, schedule_warp_sample.
    cbn.
    repeat split; lia.
  - split.
    + unfold horizontal_position_differs,
        arbitrary_post_copy_discrepancy_countermodel,
        schedule_warp_sample, schedule_arbitrary_post_copy_sample.
      cbn.
      left; lia.
    + unfold post_copy_sample_discrepancy,
        arbitrary_post_copy_discrepancy_countermodel,
        schedule_warp_sample, schedule_arbitrary_post_copy_sample.
      cbn.
      intro Hequal.
      inversion Hequal.
Qed.

(** The exact live-execution bridge still required is intentionally stated in
    prose instead of being hidden behind an unconstrained Gallina predicate.
    A future theorem must quantify over clean reachable states of the linked
    US/JP Clight programs and prove all of the following from their memories
    and small steps:

    1. the selected play-mode and [gMarioObject] branch project to
       [ModeledArea1FrameSchedule];
    2. a warp interaction projects to [UpperWarpSelectionPositionSchedule],
       including any earlier interaction handlers on that callback, and its
       [schedule_state_before_geometry] field is the live State sample after
       both wall-collision calls and immediately before floor lookup;
    3. the player-list callback really executes [bhv_mario_update] and then
       either the floor-null early return or the [ACT_DISAPPEARED] branch
       before the raw Object copy and final platform call;
    4. non-null [gMarioObject] makes [update_mario_platform] reach exactly one
       of its three global assignments, while a null value takes the checked
       early return without an alias write; and
    5. the post-handler interaction tail, action helpers, remaining object
       callbacks, particle spawns, unload code, and external calls cannot
       alias-write Mario's State/Object/Graphics coordinates or
       [gMarioPlatform]; and
    6. the two NULL-callback change-area steps occur only after an accepted
       nonfatal object-warp request, preserve the relevant memory in the full
       scheduler, and are followed by [warp_area] before the destination
       [area_update_objects].

    Until that theorem exists, the finite schedule is a checked source model,
    not a proof that every retail execution refines it. *)

Definition Area1QueryScheduleCheckedBoundary : Prop :=
  area1_warp_handler_table_source_claim /\
  area1_active_warp_schedule_source_claim /\
  area1_post_selection_direct_writer_source_claim /\
  area1_final_query_overwrite_source_claim /\
  area1_scheduler_source_claim /\
  (forall shape,
    schedule_contains ScheduleSelectUpperWarpDisappeared
      (stock_area1_schedule_events shape) ->
    schedule_contains ScheduleFinalPlatformQuery
      (stock_area1_schedule_events shape)) /\
  (forall schedule,
    horizontal_position_differs
      (schedule_final_query schedule)
      (schedule_collision_object schedule) ->
    horizontal_position_differs
      (schedule_state_before_geometry schedule)
      (schedule_collision_object schedule) \/
    horizontal_position_differs
      (schedule_graphics_before_geometry schedule)
      (schedule_collision_object schedule) \/
    post_copy_sample_discrepancy schedule).

Theorem area1_query_schedule_checked_boundary_holds :
  Area1QueryScheduleCheckedBoundary.
Proof.
  unfold Area1QueryScheduleCheckedBoundary.
  split; [exact area1_warp_handler_table_source_checked |].
  split; [exact area1_active_warp_schedule_source_checked |].
  split; [exact area1_post_selection_direct_writer_source_checked |].
  split; [exact area1_final_query_overwrite_source_checked |].
  split; [exact area1_scheduler_source_checked |].
  split; [exact a_schedule_that_selects_upper_warp_action_has_final_query |].
  exact final_query_horizontal_gap_is_preselection_or_postcopy_discrepancy.
Qed.
