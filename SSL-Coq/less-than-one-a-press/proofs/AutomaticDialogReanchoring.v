(** Automatic-dialog and cutscene reanchoring, for US and JP.

    Ink's proposed installer needs Graphics Y to get far above both
    MarioState Y and the raw Mario-object Y.  A negative quicksand depth is
    dangerous because the common end-of-action sink subtracts that depth from
    Graphics.  Whether the subtraction can accumulate depends on whether the
    selected action first copies MarioState position back to Graphics.

    This file keeps three levels deliberately separate:

    - computed facts about the generated Clight syntax for VERSION_US and
      VERSION_JP;
    - a complete census, within the translated cutscene and interaction
      units, of direct constructors of ACT_READING_AUTOMATIC_DIALOG; and
    - a small integer scheduling model explaining the consequence of a
      reanchor versus a non-reanchoring stalled dialog.

    The computed facts are not a linked small-step execution.  In particular,
    this file does not prove clean Area-1 reachability, rule out a door object,
    establish pointer non-aliasing, give external helper frame conditions, or
    derive a negative binary32 quicksand depth. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_mario us_mario_actions_automatic us_mario_actions_cutscene
  us_mario_actions_submerged us_mario_step us_interaction
  us_object_list_processor
  jp_mario jp_mario_actions_automatic jp_mario_actions_cutscene
  jp_mario_actions_submerged jp_mario_step jp_interaction
  jp_object_list_processor.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module ADR_USMario := us_mario.
Module ADR_USAutomatic := us_mario_actions_automatic.
Module ADR_USCutscene := us_mario_actions_cutscene.
Module ADR_USSubmerged := us_mario_actions_submerged.
Module ADR_USStep := us_mario_step.
Module ADR_USInteraction := us_interaction.
Module ADR_USObjects := us_object_list_processor.

Module ADR_JPMario := jp_mario.
Module ADR_JPAutomatic := jp_mario_actions_automatic.
Module ADR_JPCutscene := jp_mario_actions_cutscene.
Module ADR_JPSubmerged := jp_mario_actions_submerged.
Module ADR_JPStep := jp_mario_step.
Module ADR_JPInteraction := jp_interaction.
Module ADR_JPObjects := jp_object_list_processor.

(** Field-chain/type-sensitive recognition of the direct source operation

      vec3f_copy(m->marioObj->header.gfx.pos, m->pos).

    The expression bases may pass through generated temporaries, but their
    struct types and the destination/source field chain must be exact.  This
    intentionally does not prove that both expressions arise from one live
    [m] pointer; that is part of the memory refinement obligation below. *)
Definition adr_is_state_to_graphics_copy
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (s : statement) : bool :=
  match s with
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

Fixpoint adr_contains_state_to_graphics_copy_s
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (s : statement) : bool :=
  adr_is_state_to_graphics_copy
    copy_callee object_tag mario_state_tag header_field graphics_field
    position_field s ||
  match s with
  | Ssequence first second | Sloop first second =>
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field first ||
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field second
  | Sifthenelse _ yes no =>
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field yes ||
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field no
  | Sswitch _ cases =>
      adr_contains_state_to_graphics_copy_ls
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field cases
  | Slabel _ body =>
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field body
  | _ => false
  end
with adr_contains_state_to_graphics_copy_ls
    (copy_callee object_tag mario_state_tag header_field graphics_field
      position_field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      adr_contains_state_to_graphics_copy_s
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field body ||
      adr_contains_state_to_graphics_copy_ls
        copy_callee object_tag mario_state_tag header_field graphics_field
        position_field rest
  end.

(** Check both that at least one value-return exists and that every explicit
    value-return in the body is the integer literal zero. *)
Fixpoint adr_has_value_return_s (s : statement) : bool :=
  match s with
  | Sreturn (Some _) => true
  | Ssequence first second | Sloop first second =>
      adr_has_value_return_s first || adr_has_value_return_s second
  | Sifthenelse _ yes no =>
      adr_has_value_return_s yes || adr_has_value_return_s no
  | Sswitch _ cases => adr_has_value_return_ls cases
  | Slabel _ body => adr_has_value_return_s body
  | _ => false
  end
with adr_has_value_return_ls (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      adr_has_value_return_s body || adr_has_value_return_ls rest
  end.

Fixpoint adr_all_value_returns_zero_s (s : statement) : bool :=
  match s with
  | Sreturn (Some (Econst_int value _)) => Int.eq value Int.zero
  | Sreturn (Some _) => false
  | Ssequence first second | Sloop first second =>
      adr_all_value_returns_zero_s first &&
      adr_all_value_returns_zero_s second
  | Sifthenelse _ yes no =>
      adr_all_value_returns_zero_s yes && adr_all_value_returns_zero_s no
  | Sswitch _ cases => adr_all_value_returns_zero_ls cases
  | Slabel _ body => adr_all_value_returns_zero_s body
  | _ => true
  end
with adr_all_value_returns_zero_ls (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      adr_all_value_returns_zero_s body &&
      adr_all_value_returns_zero_ls rest
  end.

(** The generated automatic-dialog handler has no direct State-position or
    depth write, no direct State-to-Graphics copy, and no call to the usual
    floor-snap helper.  Its only value return is [0], so the source handler
    itself requests no further same-frame action-loop iteration.  The same
    checked footprint holds for both target versions. *)
Definition us_automatic_dialog_direct_footprint_claim : Prop :=
  assigns_array_slot_s ADR_USCutscene._pos 0
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_array_slot_s ADR_USCutscene._pos 1
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_array_slot_s ADR_USCutscene._pos 2
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s ADR_USCutscene._quicksandDepth
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  adr_contains_state_to_graphics_copy_s
    ADR_USCutscene._vec3f_copy ADR_USCutscene._Object
    ADR_USCutscene._MarioState ADR_USCutscene._header
    ADR_USCutscene._gfx ADR_USCutscene._pos
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  calls_ident_s ADR_USCutscene._stop_and_set_height_to_floor
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s ADR_USCutscene._actionState
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true /\
  statement_mentions_int_s 9
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true /\
  statement_mentions_int_s 10
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true /\
  calls_ident_s ADR_USCutscene._get_dialog_id
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true /\
  adr_has_value_return_s
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true /\
  adr_all_value_returns_zero_s
    (fn_body ADR_USCutscene.f_act_reading_automatic_dialog) = true.

Theorem us_automatic_dialog_no_recognized_direct_reanchor_checked :
  us_automatic_dialog_direct_footprint_claim.
Proof. unfold us_automatic_dialog_direct_footprint_claim; vm_compute; repeat split. Qed.

Definition jp_automatic_dialog_direct_footprint_claim : Prop :=
  assigns_array_slot_s ADR_JPCutscene._pos 0
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_array_slot_s ADR_JPCutscene._pos 1
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_array_slot_s ADR_JPCutscene._pos 2
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s ADR_JPCutscene._quicksandDepth
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPCutscene._vec3f_copy ADR_JPCutscene._Object
    ADR_JPCutscene._MarioState ADR_JPCutscene._header
    ADR_JPCutscene._gfx ADR_JPCutscene._pos
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  calls_ident_s ADR_JPCutscene._stop_and_set_height_to_floor
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = false /\
  assigns_field_named_s ADR_JPCutscene._actionState
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true /\
  statement_mentions_int_s 9
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true /\
  statement_mentions_int_s 10
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true /\
  calls_ident_s ADR_JPCutscene._get_dialog_id
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true /\
  adr_has_value_return_s
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true /\
  adr_all_value_returns_zero_s
    (fn_body ADR_JPCutscene.f_act_reading_automatic_dialog) = true.

Theorem jp_automatic_dialog_no_recognized_direct_reanchor_checked :
  jp_automatic_dialog_direct_footprint_claim.
Proof. unfold jp_automatic_dialog_direct_footprint_claim; vm_compute; repeat split. Qed.

(** Despite its English name, [ACT_READING_AUTOMATIC_DIALOG] belongs to the
    cutscene action group, not [mario_execute_automatic_action].  The generated
    cutscene dispatcher contains its handler and has no direct depth write;
    the automatic dispatcher contains no call to that handler.  Therefore the
    automatic group's zero reset cannot be attributed to a dialog frame. *)
Definition automatic_dialog_is_cutscene_group_claim : Prop :=
  calls_ident_s ADR_USCutscene._act_reading_automatic_dialog
    (fn_body ADR_USCutscene.f_mario_execute_cutscene_action) = true /\
  assigns_field_named_s ADR_USCutscene._quicksandDepth
    (fn_body ADR_USCutscene.f_mario_execute_cutscene_action) = false /\
  calls_ident_s ADR_USCutscene._act_reading_automatic_dialog
    (fn_body ADR_USAutomatic.f_mario_execute_automatic_action) = false /\
  calls_ident_s ADR_JPCutscene._act_reading_automatic_dialog
    (fn_body ADR_JPCutscene.f_mario_execute_cutscene_action) = true /\
  assigns_field_named_s ADR_JPCutscene._quicksandDepth
    (fn_body ADR_JPCutscene.f_mario_execute_cutscene_action) = false /\
  calls_ident_s ADR_JPCutscene._act_reading_automatic_dialog
    (fn_body ADR_JPAutomatic.f_mario_execute_automatic_action) = false.

Theorem automatic_dialog_is_cutscene_group_checked :
  automatic_dialog_is_cutscene_group_claim.
Proof. unfold automatic_dialog_is_cutscene_group_claim; vm_compute; repeat split. Qed.

(** [set_mario_animation] changes animation metadata, including
    [animYTrans], but does not itself write MarioState position or perform a
    State-to-Graphics position copy.  This closes the direct helper called on
    the early automatic-dialog states; effects of [load_patchable_table] and
    arbitrary aliasing remain outside this syntax fact. *)
Definition animation_helper_position_footprint_claim : Prop :=
  assigns_array_slot_s ADR_USMario._pos 0
    (fn_body ADR_USMario.f_set_mario_animation) = false /\
  assigns_array_slot_s ADR_USMario._pos 1
    (fn_body ADR_USMario.f_set_mario_animation) = false /\
  assigns_array_slot_s ADR_USMario._pos 2
    (fn_body ADR_USMario.f_set_mario_animation) = false /\
  calls_ident_s ADR_USMario._vec3f_copy
    (fn_body ADR_USMario.f_set_mario_animation) = false /\
  assigns_array_slot_s ADR_JPMario._pos 0
    (fn_body ADR_JPMario.f_set_mario_animation) = false /\
  assigns_array_slot_s ADR_JPMario._pos 1
    (fn_body ADR_JPMario.f_set_mario_animation) = false /\
  assigns_array_slot_s ADR_JPMario._pos 2
    (fn_body ADR_JPMario.f_set_mario_animation) = false /\
  calls_ident_s ADR_JPMario._vec3f_copy
    (fn_body ADR_JPMario.f_set_mario_animation) = false.

Theorem animation_helper_position_footprint_checked :
  animation_helper_position_footprint_claim.
Proof. unfold animation_helper_position_footprint_claim; vm_compute; repeat split. Qed.

(** Three dialog-like handlers directly reanchor Graphics from State on every
    path that reaches their common tail.  [ACT_DISAPPEARED] instead calls the
    helper that snaps State to cached floor height and copies State to
    Graphics.  These are body-shape facts; reaching the common tail and the
    external/helper effects still need Clight execution proofs. *)
Definition us_dialog_reanchor_handler_claim : Prop :=
  adr_contains_state_to_graphics_copy_s
    ADR_USCutscene._vec3f_copy ADR_USCutscene._Object
    ADR_USCutscene._MarioState ADR_USCutscene._header
    ADR_USCutscene._gfx ADR_USCutscene._pos
    (fn_body ADR_USCutscene.f_act_reading_npc_dialog) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_USCutscene._vec3f_copy ADR_USCutscene._Object
    ADR_USCutscene._MarioState ADR_USCutscene._header
    ADR_USCutscene._gfx ADR_USCutscene._pos
    (fn_body ADR_USCutscene.f_act_waiting_for_dialog) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_USCutscene._vec3f_copy ADR_USCutscene._Object
    ADR_USCutscene._MarioState ADR_USCutscene._header
    ADR_USCutscene._gfx ADR_USCutscene._pos
    (fn_body ADR_USCutscene.f_act_reading_sign) = true /\
  calls_ident_s ADR_USCutscene._stop_and_set_height_to_floor
    (fn_body ADR_USCutscene.f_act_disappeared) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_USStep._vec3f_copy ADR_USStep._Object ADR_USStep._MarioState
    ADR_USStep._header ADR_USStep._gfx ADR_USStep._pos
    (fn_body ADR_USStep.f_stop_and_set_height_to_floor) = true /\
  calls_ident_s ADR_USStep._perform_ground_step
    (fn_body ADR_USStep.f_stationary_ground_step) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_USStep._vec3f_copy ADR_USStep._Object ADR_USStep._MarioState
    ADR_USStep._header ADR_USStep._gfx ADR_USStep._pos
    (fn_body ADR_USStep.f_stationary_ground_step) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_USStep._vec3f_copy ADR_USStep._Object ADR_USStep._MarioState
    ADR_USStep._header ADR_USStep._gfx ADR_USStep._pos
    (fn_body ADR_USStep.f_perform_ground_step) = true.

Theorem us_dialog_reanchor_handlers_checked :
  us_dialog_reanchor_handler_claim.
Proof. unfold us_dialog_reanchor_handler_claim; vm_compute; repeat split. Qed.

Definition jp_dialog_reanchor_handler_claim : Prop :=
  adr_contains_state_to_graphics_copy_s
    ADR_JPCutscene._vec3f_copy ADR_JPCutscene._Object
    ADR_JPCutscene._MarioState ADR_JPCutscene._header
    ADR_JPCutscene._gfx ADR_JPCutscene._pos
    (fn_body ADR_JPCutscene.f_act_reading_npc_dialog) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPCutscene._vec3f_copy ADR_JPCutscene._Object
    ADR_JPCutscene._MarioState ADR_JPCutscene._header
    ADR_JPCutscene._gfx ADR_JPCutscene._pos
    (fn_body ADR_JPCutscene.f_act_waiting_for_dialog) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPCutscene._vec3f_copy ADR_JPCutscene._Object
    ADR_JPCutscene._MarioState ADR_JPCutscene._header
    ADR_JPCutscene._gfx ADR_JPCutscene._pos
    (fn_body ADR_JPCutscene.f_act_reading_sign) = true /\
  calls_ident_s ADR_JPCutscene._stop_and_set_height_to_floor
    (fn_body ADR_JPCutscene.f_act_disappeared) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPStep._vec3f_copy ADR_JPStep._Object ADR_JPStep._MarioState
    ADR_JPStep._header ADR_JPStep._gfx ADR_JPStep._pos
    (fn_body ADR_JPStep.f_stop_and_set_height_to_floor) = true /\
  calls_ident_s ADR_JPStep._perform_ground_step
    (fn_body ADR_JPStep.f_stationary_ground_step) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPStep._vec3f_copy ADR_JPStep._Object ADR_JPStep._MarioState
    ADR_JPStep._header ADR_JPStep._gfx ADR_JPStep._pos
    (fn_body ADR_JPStep.f_stationary_ground_step) = true /\
  adr_contains_state_to_graphics_copy_s
    ADR_JPStep._vec3f_copy ADR_JPStep._Object ADR_JPStep._MarioState
    ADR_JPStep._header ADR_JPStep._gfx ADR_JPStep._pos
    (fn_body ADR_JPStep.f_perform_ground_step) = true.

Theorem jp_dialog_reanchor_handlers_checked :
  jp_dialog_reanchor_handler_claim.
Proof. unfold jp_dialog_reanchor_handler_claim; vm_compute; repeat split. Qed.

(** Locate calls of [set_mario_action(m, ACT, ...)] while coupling the action
    constant to the call's second argument. *)
Definition adr_is_second_literal_call
    (callee : ident) (second : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _)
      [Etempvar _ _; Econst_int found_second _; _] =>
      Pos.eqb found_callee callee &&
      Int.eq found_second (Int.repr second)
  | _ => false
  end.

Fixpoint adr_calls_second_literal_s
    (callee : ident) (second : Z) (s : statement) : bool :=
  match s with
  | Scall _ _ _ => adr_is_second_literal_call callee second s
  | Ssequence first second_body | Sloop first second_body =>
      adr_calls_second_literal_s callee second first ||
      adr_calls_second_literal_s callee second second_body
  | Sifthenelse _ yes no =>
      adr_calls_second_literal_s callee second yes ||
      adr_calls_second_literal_s callee second no
  | Sswitch _ cases => adr_calls_second_literal_ls callee second cases
  | Slabel _ body => adr_calls_second_literal_s callee second body
  | _ => false
  end
with adr_calls_second_literal_ls
    (callee : ident) (second : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      adr_calls_second_literal_s callee second body ||
      adr_calls_second_literal_ls callee second rest
  end.

Fixpoint adr_internal_second_literal_sites
    (callee : ident) (second : Z)
    (definitions : list (ident * globdef (fundef function) type)) :
    list ident :=
  match definitions with
  | [] => []
  | (id, Gfun (Internal body)) :: rest =>
      if adr_calls_second_literal_s callee second (fn_body body)
      then id :: adr_internal_second_literal_sites callee second rest
      else adr_internal_second_literal_sites callee second rest
  | _ :: rest => adr_internal_second_literal_sites callee second rest
  end.

Definition us_dialog_constructor_scope :=
  prog_defs ADR_USCutscene.prog ++ prog_defs ADR_USInteraction.prog.

Definition jp_dialog_constructor_scope :=
  prog_defs ADR_JPCutscene.prog ++ prog_defs ADR_JPInteraction.prog.

(** The exact direct-constructor census in the two source units that define
    cutscene and object-interaction action changes.  Four sites are cutscene
    paths; two are live-door interaction paths. *)
Theorem us_automatic_dialog_constructor_census :
  adr_internal_second_literal_sites ADR_USMario._set_mario_action 536875781
    us_dialog_constructor_scope =
  [ADR_USCutscene._handle_save_menu;
   ADR_USCutscene._general_star_dance_handler;
   ADR_USCutscene._act_unlocking_star_door;
   ADR_USCutscene._act_warp_door_spawn;
   ADR_USInteraction._interact_warp_door;
   ADR_USInteraction._interact_door].
Proof. vm_compute. reflexivity. Qed.

Theorem jp_automatic_dialog_constructor_census :
  adr_internal_second_literal_sites ADR_JPMario._set_mario_action 536875781
    jp_dialog_constructor_scope =
  [ADR_JPCutscene._handle_save_menu;
   ADR_JPCutscene._general_star_dance_handler;
   ADR_JPCutscene._act_unlocking_star_door;
   ADR_JPCutscene._act_warp_door_spawn;
   ADR_JPInteraction._interact_warp_door;
   ADR_JPInteraction._interact_door].
Proof. vm_compute. reflexivity. Qed.

(** Each of the four cutscene-origin families has a same-enclosing-handler
    reanchor call before or after its constructor helper in the generated
    body.  The two interaction-origin sites do not themselves write State
    position or call either reanchor helper.  Subsequence checks are lexical,
    not proofs that both calls execute along one live path. *)
Definition us_constructor_reanchor_shape_claim : Prop :=
  ident_subsequenceb
    [ADR_USCutscene._stationary_ground_step;
     ADR_USCutscene._handle_save_menu]
    (direct_callees_s
      (fn_body ADR_USCutscene.f_act_exit_land_save_dialog)) = true /\
  ident_subsequenceb
    [ADR_USCutscene._general_star_dance_handler;
     ADR_USCutscene._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body ADR_USCutscene.f_act_star_dance)) = true /\
  ident_subsequenceb
    [ADR_USCutscene._vec3f_copy;
     ADR_USCutscene._general_star_dance_handler]
    (direct_callees_s
      (fn_body ADR_USCutscene.f_act_star_dance_water)) = true /\
  ident_subsequenceb
    [ADR_USCutscene._set_mario_action;
     ADR_USCutscene._update_mario_pos_for_anim;
     ADR_USCutscene._stop_and_set_height_to_floor]
    (direct_callees_s
      (fn_body ADR_USCutscene.f_act_unlocking_star_door)) = true /\
  ident_subsequenceb
    [ADR_USCutscene._set_mario_action;
     ADR_USCutscene._stop_and_set_height_to_floor]
    (direct_callees_s
      (fn_body ADR_USCutscene.f_act_warp_door_spawn)) = true /\
  assigns_array_slot_s ADR_USInteraction._pos 0
    (fn_body ADR_USInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_USInteraction._pos 1
    (fn_body ADR_USInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_USInteraction._pos 2
    (fn_body ADR_USInteraction.f_interact_warp_door) = false /\
  calls_ident_s ADR_USCutscene._vec3f_copy
    (fn_body ADR_USInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_USInteraction._pos 0
    (fn_body ADR_USInteraction.f_interact_door) = false /\
  assigns_array_slot_s ADR_USInteraction._pos 1
    (fn_body ADR_USInteraction.f_interact_door) = false /\
  assigns_array_slot_s ADR_USInteraction._pos 2
    (fn_body ADR_USInteraction.f_interact_door) = false /\
  calls_ident_s ADR_USCutscene._vec3f_copy
    (fn_body ADR_USInteraction.f_interact_door) = false.

Theorem us_constructor_reanchor_shape_checked :
  us_constructor_reanchor_shape_claim.
Proof. unfold us_constructor_reanchor_shape_claim; vm_compute; repeat split. Qed.

Definition jp_constructor_reanchor_shape_claim : Prop :=
  ident_subsequenceb
    [ADR_JPCutscene._stationary_ground_step;
     ADR_JPCutscene._handle_save_menu]
    (direct_callees_s
      (fn_body ADR_JPCutscene.f_act_exit_land_save_dialog)) = true /\
  ident_subsequenceb
    [ADR_JPCutscene._general_star_dance_handler;
     ADR_JPCutscene._stop_and_set_height_to_floor]
    (direct_callees_s (fn_body ADR_JPCutscene.f_act_star_dance)) = true /\
  ident_subsequenceb
    [ADR_JPCutscene._vec3f_copy;
     ADR_JPCutscene._general_star_dance_handler]
    (direct_callees_s
      (fn_body ADR_JPCutscene.f_act_star_dance_water)) = true /\
  ident_subsequenceb
    [ADR_JPCutscene._set_mario_action;
     ADR_JPCutscene._update_mario_pos_for_anim;
     ADR_JPCutscene._stop_and_set_height_to_floor]
    (direct_callees_s
      (fn_body ADR_JPCutscene.f_act_unlocking_star_door)) = true /\
  ident_subsequenceb
    [ADR_JPCutscene._set_mario_action;
     ADR_JPCutscene._stop_and_set_height_to_floor]
    (direct_callees_s
      (fn_body ADR_JPCutscene.f_act_warp_door_spawn)) = true /\
  assigns_array_slot_s ADR_JPInteraction._pos 0
    (fn_body ADR_JPInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_JPInteraction._pos 1
    (fn_body ADR_JPInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_JPInteraction._pos 2
    (fn_body ADR_JPInteraction.f_interact_warp_door) = false /\
  calls_ident_s ADR_JPCutscene._vec3f_copy
    (fn_body ADR_JPInteraction.f_interact_warp_door) = false /\
  assigns_array_slot_s ADR_JPInteraction._pos 0
    (fn_body ADR_JPInteraction.f_interact_door) = false /\
  assigns_array_slot_s ADR_JPInteraction._pos 1
    (fn_body ADR_JPInteraction.f_interact_door) = false /\
  assigns_array_slot_s ADR_JPInteraction._pos 2
    (fn_body ADR_JPInteraction.f_interact_door) = false /\
  calls_ident_s ADR_JPCutscene._vec3f_copy
    (fn_body ADR_JPInteraction.f_interact_door) = false.

Theorem jp_constructor_reanchor_shape_checked :
  jp_constructor_reanchor_shape_claim.
Proof. unfold jp_constructor_reanchor_shape_claim; vm_compute; repeat split. Qed.

(** All seventeen switch arms of the automatic action group occur after the
    dispatcher's direct binary32-zero write to [quicksandDepth].  The common
    cancel is the only pre-reset return; its only direct action helper is
    [set_water_plunge_action], and the submerged dispatcher also contains the
    zero reset.  This is the complete generated handler list for US and JP,
    but ordering/path execution still needs semantic refinement. *)
Definition us_automatic_handler_calls : list ident :=
  [ADR_USAutomatic._check_common_automatic_cancels;
   ADR_USAutomatic._act_holding_pole;
   ADR_USAutomatic._act_grab_pole_slow;
   ADR_USAutomatic._act_grab_pole_fast;
   ADR_USAutomatic._act_climbing_pole;
   ADR_USAutomatic._act_top_of_pole_transition;
   ADR_USAutomatic._act_top_of_pole;
   ADR_USAutomatic._act_start_hanging;
   ADR_USAutomatic._act_hanging;
   ADR_USAutomatic._act_hang_moving;
   ADR_USAutomatic._act_ledge_grab;
   ADR_USAutomatic._act_ledge_climb_slow;
   ADR_USAutomatic._act_ledge_climb_slow;
   ADR_USAutomatic._act_ledge_climb_down;
   ADR_USAutomatic._act_ledge_climb_fast;
   ADR_USAutomatic._act_grabbed;
   ADR_USAutomatic._act_in_cannon;
   ADR_USAutomatic._act_tornado_twirling].

Definition jp_automatic_handler_calls : list ident :=
  [ADR_JPAutomatic._check_common_automatic_cancels;
   ADR_JPAutomatic._act_holding_pole;
   ADR_JPAutomatic._act_grab_pole_slow;
   ADR_JPAutomatic._act_grab_pole_fast;
   ADR_JPAutomatic._act_climbing_pole;
   ADR_JPAutomatic._act_top_of_pole_transition;
   ADR_JPAutomatic._act_top_of_pole;
   ADR_JPAutomatic._act_start_hanging;
   ADR_JPAutomatic._act_hanging;
   ADR_JPAutomatic._act_hang_moving;
   ADR_JPAutomatic._act_ledge_grab;
   ADR_JPAutomatic._act_ledge_climb_slow;
   ADR_JPAutomatic._act_ledge_climb_slow;
   ADR_JPAutomatic._act_ledge_climb_down;
   ADR_JPAutomatic._act_ledge_climb_fast;
   ADR_JPAutomatic._act_grabbed;
   ADR_JPAutomatic._act_in_cannon;
   ADR_JPAutomatic._act_tornado_twirling].

(** Match the top-level generated sequence rather than finding the reset and
    handlers independently.  The pre-reset prefix contains only the common
    cancel call.  The immediate next statement writes binary32 zero, and the
    remaining suffix contains exactly the switch-handler calls. *)
Definition adr_automatic_dispatch_sequence_shape
    (depth_field common_cancel : ident) (handler_calls : list ident)
    (body : statement) : Prop :=
  match body with
  | Ssequence cancel_prefix (Ssequence depth_write dispatch_suffix) =>
      direct_callees_s cancel_prefix = [common_cancel] /\
      assigns_field_float32_constant_s depth_field 0 depth_write = true /\
      direct_callees_s dispatch_suffix = handler_calls
  | _ => False
  end.

Definition us_automatic_switch_handler_calls : list ident :=
  tl us_automatic_handler_calls.

Definition jp_automatic_switch_handler_calls : list ident :=
  tl jp_automatic_handler_calls.

Theorem automatic_dispatch_sequence_shape_checked :
  adr_automatic_dispatch_sequence_shape
    ADR_USAutomatic._quicksandDepth
    ADR_USAutomatic._check_common_automatic_cancels
    us_automatic_switch_handler_calls
    (fn_body ADR_USAutomatic.f_mario_execute_automatic_action) /\
  adr_automatic_dispatch_sequence_shape
    ADR_JPAutomatic._quicksandDepth
    ADR_JPAutomatic._check_common_automatic_cancels
    jp_automatic_switch_handler_calls
    (fn_body ADR_JPAutomatic.f_mario_execute_automatic_action).
Proof.
  unfold adr_automatic_dispatch_sequence_shape,
    us_automatic_switch_handler_calls, jp_automatic_switch_handler_calls,
    us_automatic_handler_calls, jp_automatic_handler_calls.
  vm_compute. split; repeat split; reflexivity.
Qed.

Definition automatic_dispatch_depth_reset_claim : Prop :=
  direct_callees_s
    (fn_body ADR_USAutomatic.f_mario_execute_automatic_action) =
      us_automatic_handler_calls /\
  assigns_field_float32_constant_s ADR_USAutomatic._quicksandDepth 0
    (fn_body ADR_USAutomatic.f_mario_execute_automatic_action) = true /\
  direct_callees_s
    (fn_body ADR_USAutomatic.f_check_common_automatic_cancels) =
      [ADR_USAutomatic._set_water_plunge_action] /\
  assigns_field_float32_constant_s ADR_USSubmerged._quicksandDepth 0
    (fn_body ADR_USSubmerged.f_mario_execute_submerged_action) = true /\
  direct_callees_s
    (fn_body ADR_JPAutomatic.f_mario_execute_automatic_action) =
      jp_automatic_handler_calls /\
  assigns_field_float32_constant_s ADR_JPAutomatic._quicksandDepth 0
    (fn_body ADR_JPAutomatic.f_mario_execute_automatic_action) = true /\
  direct_callees_s
    (fn_body ADR_JPAutomatic.f_check_common_automatic_cancels) =
      [ADR_JPAutomatic._set_water_plunge_action] /\
  assigns_field_float32_constant_s ADR_JPSubmerged._quicksandDepth 0
    (fn_body ADR_JPSubmerged.f_mario_execute_submerged_action) = true.

Theorem automatic_dispatch_depth_reset_checked :
  automatic_dispatch_depth_reset_claim.
Proof. unfold automatic_dispatch_depth_reset_claim; vm_compute; repeat split. Qed.

(** The outer ordering that makes a stalled dialog relevant: cutscene action
    dispatch precedes the common sink; Mario's object behavior then copies
    State to the raw Object coordinates.  That raw copy writes slots 6/7/8
    and contains no direct [vec3f_copy], so it does not undo the Graphics-only
    sink in its own generated body. *)
Definition dialog_sink_and_raw_copy_order_claim : Prop :=
  ident_subsequenceb
    [ADR_USMario._mario_execute_cutscene_action;
     ADR_USMario._sink_mario_in_quicksand]
    (direct_callees_s (fn_body ADR_USMario.f_execute_mario_action)) = true /\
  ident_subsequenceb
    [ADR_USObjects._execute_mario_action;
     ADR_USObjects._copy_mario_state_to_object]
    (direct_callees_s (fn_body ADR_USObjects.f_bhv_mario_update)) = true /\
  assigns_array_slot_s ADR_USObjects._asF32 6
    (fn_body ADR_USObjects.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s ADR_USObjects._asF32 7
    (fn_body ADR_USObjects.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s ADR_USObjects._asF32 8
    (fn_body ADR_USObjects.f_copy_mario_state_to_object) = true /\
  calls_ident_s ADR_USMario._vec3f_copy
    (fn_body ADR_USObjects.f_copy_mario_state_to_object) = false /\
  ident_subsequenceb
    [ADR_JPMario._mario_execute_cutscene_action;
     ADR_JPMario._sink_mario_in_quicksand]
    (direct_callees_s (fn_body ADR_JPMario.f_execute_mario_action)) = true /\
  ident_subsequenceb
    [ADR_JPObjects._execute_mario_action;
     ADR_JPObjects._copy_mario_state_to_object]
    (direct_callees_s (fn_body ADR_JPObjects.f_bhv_mario_update)) = true /\
  assigns_array_slot_s ADR_JPObjects._asF32 6
    (fn_body ADR_JPObjects.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s ADR_JPObjects._asF32 7
    (fn_body ADR_JPObjects.f_copy_mario_state_to_object) = true /\
  assigns_array_slot_s ADR_JPObjects._asF32 8
    (fn_body ADR_JPObjects.f_copy_mario_state_to_object) = true /\
  calls_ident_s ADR_JPMario._vec3f_copy
    (fn_body ADR_JPObjects.f_copy_mario_state_to_object) = false.

Theorem dialog_sink_and_raw_copy_order_checked :
  dialog_sink_and_raw_copy_order_claim.
Proof. unfold dialog_sink_and_raw_copy_order_claim; vm_compute; repeat split. Qed.

(** * Exact finite scheduling consequence *)

Record DialogVerticalViews : Type := {
  dialog_state_y : Z;
  dialog_object_y : Z;
  dialog_graphics_y : Z
}.

Definition dialog_gap (views : DialogVerticalViews) : Z :=
  dialog_graphics_y views - dialog_object_y views.

Definition dialog_reanchor (views : DialogVerticalViews) :
    DialogVerticalViews :=
  {| dialog_state_y := dialog_state_y views;
     dialog_object_y := dialog_object_y views;
     dialog_graphics_y := dialog_state_y views |}.

Definition dialog_sink (depth : Z) (views : DialogVerticalViews) :
    DialogVerticalViews :=
  {| dialog_state_y := dialog_state_y views;
     dialog_object_y := dialog_object_y views;
     dialog_graphics_y := dialog_graphics_y views - depth |}.

Definition dialog_copy_state_to_object (views : DialogVerticalViews) :
    DialogVerticalViews :=
  {| dialog_state_y := dialog_state_y views;
     dialog_object_y := dialog_state_y views;
     dialog_graphics_y := dialog_graphics_y views |}.

Definition reanchored_cutscene_frame
    (depth : Z) (views : DialogVerticalViews) : DialogVerticalViews :=
  dialog_copy_state_to_object (dialog_sink depth (dialog_reanchor views)).

Definition stalled_automatic_dialog_frame
    (depth : Z) (views : DialogVerticalViews) : DialogVerticalViews :=
  dialog_copy_state_to_object (dialog_sink depth views).

Theorem reanchored_frame_forgets_the_incoming_graphics_gap :
  forall depth views,
    dialog_gap (reanchored_cutscene_frame depth views) = - depth.
Proof. intros; unfold dialog_gap, reanchored_cutscene_frame; simpl; lia. Qed.

(** Reanchoring forgets the incoming gap, but it does not reset the depth
    argument.  If the same negative value survives into the first stalled
    dialog frame, the constructor-frame gap [-depth] becomes [-2*depth]. *)
Theorem modeled_reanchor_then_stall_with_same_depth_has_double_gap :
  forall depth views,
    dialog_gap
      (stalled_automatic_dialog_frame depth
        (reanchored_cutscene_frame depth views)) = -2 * depth.
Proof.
  intros depth [state_y object_y graphics_y].
  change ((state_y - depth - depth) - state_y = -2 * depth).
  lia.
Qed.

Theorem stalled_dialog_frame_adds_negative_depth_to_the_gap :
  forall depth views,
    dialog_object_y views = dialog_state_y views ->
    dialog_gap (stalled_automatic_dialog_frame depth views) =
      dialog_gap views - depth.
Proof.
  intros depth views Hobject.
  unfold dialog_gap, stalled_automatic_dialog_frame; simpl.
  rewrite Hobject. lia.
Qed.

Fixpoint repeat_stalled_dialog
    (frames : nat) (depth : Z) (views : DialogVerticalViews) :
    DialogVerticalViews :=
  match frames with
  | O => views
  | S rest =>
      repeat_stalled_dialog rest depth
        (stalled_automatic_dialog_frame depth views)
  end.

Theorem repeat_stalled_dialog_exact_gap :
  forall frames depth views,
    dialog_object_y views = dialog_state_y views ->
    dialog_gap (repeat_stalled_dialog frames depth views) =
      dialog_gap views - Z.of_nat frames * depth.
Proof.
  induction frames as [| frames IH]; intros depth views Hobject.
  - simpl. lia.
  - change
      (dialog_gap
        (repeat_stalled_dialog frames depth
          (stalled_automatic_dialog_frame depth views)) =
       dialog_gap views - Z.of_nat (S frames) * depth).
    rewrite IH.
    + rewrite stalled_dialog_frame_adds_negative_depth_to_the_gap by exact Hobject.
      rewrite Nat2Z.inj_succ. ring.
    + reflexivity.
Qed.

Theorem negative_depth_strictly_raises_the_stalled_dialog_gap :
  forall depth views,
    depth < 0 ->
    dialog_object_y views = dialog_state_y views ->
    dialog_gap views <
      dialog_gap (stalled_automatic_dialog_frame depth views).
Proof.
  intros depth views Hnegative Hobject.
  rewrite stalled_dialog_frame_adds_negative_depth_to_the_gap by exact Hobject.
  lia.
Qed.

(** The source increments [actionState] before testing it.  When the stored
    state is 9, the call observes state 10; an open dialog causes the handler
    to decrement it back to 9.  Consequently the stored state is 9 between
    every stalled frame, rather than 10. *)
Definition automatic_dialog_next_stored_state
    (dialog_open : bool) (stored_state : Z) : Z :=
  let incremented := (stored_state + 1) mod 65536 in
  if Z.eqb incremented 10
  then if dialog_open then (incremented - 1) mod 65536 else incremented
  else incremented.

Theorem open_automatic_dialog_stalls_at_stored_state_nine :
  automatic_dialog_next_stored_state true 9 = 9.
Proof. reflexivity. Qed.

Theorem open_automatic_dialog_can_stall_for_any_finite_frame_count :
  forall frames,
    Nat.iter frames (automatic_dialog_next_stored_state true) 9 = 9.
Proof.
  induction frames; simpl; auto.
  rewrite IHframes. reflexivity.
Qed.

(** The remaining retail bridge is stated narrowly rather than hidden in the
    model.  It must (1) establish a valid non-null floor, since
    [execute_mario_action] returns before action dispatch and the sink when
    [m->floor == NULL], (2) exclude the two door constructors or model their
    live effects, (3) refine the four cutscene reanchors to one Mario pointer
    in memory, (4) show all helper/external calls preserve the watched cells,
    (5) connect the generated dispatch/sink/raw-copy sequence to each clean
    frame, and (6) prove the binary32 sign/reachability property of depth. *)
Definition AutomaticDialogRetailClosureObligation
    {State : Type}
    (clean_zero_edge_area1 : State -> Prop)
    (valid_nonnull_floor_for_dispatch_and_sink : State -> Prop)
    (live_door_dialog_constructor : State -> Prop)
    (cutscene_reanchor_failed : State -> Prop)
    (external_or_alias_writer : State -> Prop)
    (negative_depth_at_unreanchored_sink : State -> Prop) : Prop :=
  forall state,
    clean_zero_edge_area1 state ->
    valid_nonnull_floor_for_dispatch_and_sink state /\
    ~ live_door_dialog_constructor state /\
    ~ cutscene_reanchor_failed state /\
    ~ external_or_alias_writer state /\
    ~ negative_depth_at_unreanchored_sink state.
