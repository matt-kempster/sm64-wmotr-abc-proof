(** Generated-AST and abstract semantic closure for the SSL Area-1 prefix
    which runs before object-collision sampling.

    The scheduler order is [clear_dynamic_surfaces],
    [update_terrain_objects], [apply_mario_platform_displacement], then
    [detect_object_collisions].  Mario's action/physics behavior and
    [copy_mario_state_to_object] run later, in [update_non_terrain_objects].

    This module will classify what can create a local-Object/nonlocal-State
    split in that prefix.  Generated syntax alone cannot prove that the
    behavior-script interpreter's current object is a non-Mario stock Area-1
    spawner/surface object, or that arbitrary pointer writes do not alias
    Mario's cells.  Those linked-memory premises remain explicit. *)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_obj_behaviors
  us_object_collision us_object_list_processor us_platform_displacement
  us_surface_load
  jp_behavior_actions jp_obj_behaviors
  jp_object_collision jp_object_list_processor jp_platform_displacement
  jp_surface_load.
From LessThanOneAPress.Proofs Require Import ASTFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module PCUOC := us_object_collision.
Module PCUOL := us_object_list_processor.
Module PCUPD := us_platform_displacement.
Module PCUSL := us_surface_load.
Module PCUBA := us_behavior_actions.
Module PCUOB := us_obj_behaviors.
Module PCJOC := jp_object_collision.
Module PCJOL := jp_object_list_processor.
Module PCJPD := jp_platform_displacement.
Module PCJSL := jp_surface_load.
Module PCJBA := jp_behavior_actions.
Module PCJOB := jp_obj_behaviors.

Definition us_area1_stock_surface_native_bodies : list Clight.function :=
  [PCUOB.f_bhv_pyramid_top_init;
   PCUOB.f_bhv_pyramid_top_spinning;
   PCUOB.f_bhv_pyramid_top_explode;
   PCUOB.f_bhv_pyramid_top_loop;
   PCUBA.f_tox_box_shake_screen;
   PCUBA.f_tox_box_move;
   PCUBA.f_tox_box_act_roll_forward;
   PCUBA.f_tox_box_act_roll_backward;
   PCUBA.f_tox_box_act_roll_right;
   PCUBA.f_tox_box_act_roll_left;
   PCUBA.f_tox_box_act_roll_land;
   PCUBA.f_tox_box_act_idle;
   PCUBA.f_tox_box_act_unused_idle;
   PCUBA.f_tox_box_act_init;
   PCUBA.f_bhv_tox_box_loop;
   PCUBA.f_breakable_box_init;
   PCUBA.f_bhv_breakable_box_loop;
   PCUBA.f_bhv_rotating_exclamation_box_loop;
   PCUBA.f_exclamation_box_act_0;
   PCUBA.f_exclamation_box_act_1;
   PCUBA.f_exclamation_box_act_2;
   PCUBA.f_exclamation_box_act_3;
   PCUBA.f_exclamation_box_spawn_contents;
   PCUBA.f_exclamation_box_act_4;
   PCUBA.f_exclamation_box_act_5;
   PCUBA.f_bhv_exclamation_box_loop;
   PCUOB.f_bhv_cannon_closed_init;
   PCUOB.f_cannon_door_act_opening;
   PCUOB.f_bhv_cannon_closed_loop].

Definition jp_area1_stock_surface_native_bodies : list Clight.function :=
  [PCJOB.f_bhv_pyramid_top_init;
   PCJOB.f_bhv_pyramid_top_spinning;
   PCJOB.f_bhv_pyramid_top_explode;
   PCJOB.f_bhv_pyramid_top_loop;
   PCJBA.f_tox_box_shake_screen;
   PCJBA.f_tox_box_move;
   PCJBA.f_tox_box_act_roll_forward;
   PCJBA.f_tox_box_act_roll_backward;
   PCJBA.f_tox_box_act_roll_right;
   PCJBA.f_tox_box_act_roll_left;
   PCJBA.f_tox_box_act_roll_land;
   PCJBA.f_tox_box_act_idle;
   PCJBA.f_tox_box_act_unused_idle;
   PCJBA.f_tox_box_act_init;
   PCJBA.f_bhv_tox_box_loop;
   PCJBA.f_breakable_box_init;
   PCJBA.f_bhv_breakable_box_loop;
   PCJBA.f_bhv_rotating_exclamation_box_loop;
   PCJBA.f_exclamation_box_act_0;
   PCJBA.f_exclamation_box_act_1;
   PCJBA.f_exclamation_box_act_2;
   PCJBA.f_exclamation_box_act_3;
   PCJBA.f_exclamation_box_spawn_contents;
   PCJBA.f_exclamation_box_act_4;
   PCJBA.f_exclamation_box_act_5;
   PCJBA.f_bhv_exclamation_box_loop;
   PCJOB.f_bhv_cannon_closed_init;
   PCJOB.f_cannon_door_act_opening;
   PCJOB.f_bhv_cannon_closed_loop].

Definition body_assigns_named_pos_xyz (position_field : ident)
    (body : Clight.function) : bool :=
  existsb
    (fun component =>
       assigns_array_slot_s position_field component
         (Clight.fn_body body)) [0; 1; 2].

Definition body_calls_ident (callee : ident) (body : Clight.function) : bool :=
  calls_ident_s callee (Clight.fn_body body).

(** The generated [oPosX/Y/Z] macros are
    [receiver.rawData.asF32[6/7/8]].  This recognizer is receiver-neutral: a
    positive result does not by itself distinguish [o], a fresh child, or an
    aliased Mario object. *)
Definition expression_is_raw_xyz_slot
    (raw_data as_f32 : ident) (component : Z) (e : expr) : bool :=
  match e with
  | Ederef
      (Ebinop Oadd
        (Efield (Efield _ found_raw_data _) found_as_f32 _)
        offset _) _ =>
      Pos.eqb found_raw_data raw_data &&
      Pos.eqb found_as_f32 as_f32 &&
      match expression_const_int_z offset with
      | Some found_component => Z.eqb found_component component
      | None => false
      end
  | _ => false
  end.

Fixpoint assigns_raw_xyz_slot_s
    (raw_data as_f32 : ident) (component : Z) (s : statement) : bool :=
  match s with
  | Sassign lhs _ =>
      expression_is_raw_xyz_slot raw_data as_f32 component lhs
  | Ssequence lhs rhs | Sloop lhs rhs =>
      assigns_raw_xyz_slot_s raw_data as_f32 component lhs ||
      assigns_raw_xyz_slot_s raw_data as_f32 component rhs
  | Sifthenelse _ yes_branch no_branch =>
      assigns_raw_xyz_slot_s raw_data as_f32 component yes_branch ||
      assigns_raw_xyz_slot_s raw_data as_f32 component no_branch
  | Sswitch _ cases =>
      assigns_raw_xyz_slot_ls raw_data as_f32 component cases
  | Slabel _ body =>
      assigns_raw_xyz_slot_s raw_data as_f32 component body
  | _ => false
  end
with assigns_raw_xyz_slot_ls
    (raw_data as_f32 : ident) (component : Z)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_raw_xyz_slot_s raw_data as_f32 component body ||
      assigns_raw_xyz_slot_ls raw_data as_f32 component rest
  end.

Definition body_assigns_raw_xyz
    (raw_data as_f32 : ident) (body : Clight.function) : bool :=
  existsb
    (fun component =>
       assigns_raw_xyz_slot_s raw_data as_f32 component
         (Clight.fn_body body)) [6; 7; 8].

(** * Exact stock native-entry census

    The list contains the native entry/action bodies for all fifteen stock
    dynamic-surface owner instances already enumerated by
    [Area1PlatformExhaustiveness]: pyramid top, Tox Boxes, large breakables,
    exclamation boxes, cannon lid, and message panels.  Message panels have
    no native action body; their loop consists of behavior-script field
    commands and [load_object_collision_model].

    The first theorem is deliberately about direct generated lvalues and
    direct calls.  It does not close calls through helpers, action-function
    tables, the behavior-script interpreter, or pointer aliases. *)
Definition stock_surface_direct_raw_xyz_mask : list bool :=
  [false; true;  false; false; (* top: init, spinning, explode, loop *)
   false; true;  false; false; false; false; true; false; false; false; false;
     (* Tox: shake, move, four wrappers, land, two idles, init, loop *)
   false; false;               (* breakable init and loop *)
   false; false; false; true; false; false; false; false; false;
     (* rotating mark, exclamation actions 0..5, spawn, and loop *)
   true; true; false].          (* cannon init, opening, and loop *)

Definition stock_surface_native_direct_writer_claim : Prop :=
  length us_area1_stock_surface_native_bodies = 29%nat /\
  length jp_area1_stock_surface_native_bodies = 29%nat /\
  map (body_assigns_named_pos_xyz PCUBA._pos)
      us_area1_stock_surface_native_bodies = repeat false 29 /\
  map (body_assigns_named_pos_xyz PCJBA._pos)
      jp_area1_stock_surface_native_bodies = repeat false 29 /\
  map (body_calls_ident PCUBA._set_mario_pos)
      us_area1_stock_surface_native_bodies = repeat false 29 /\
  map (body_calls_ident PCJBA._set_mario_pos)
      jp_area1_stock_surface_native_bodies = repeat false 29 /\
  map (body_assigns_raw_xyz PCUBA._rawData PCUBA._asF32)
      us_area1_stock_surface_native_bodies =
        stock_surface_direct_raw_xyz_mask /\
  map (body_assigns_raw_xyz PCJBA._rawData PCJBA._asF32)
      jp_area1_stock_surface_native_bodies =
        stock_surface_direct_raw_xyz_mask.

Theorem stock_surface_native_direct_writer_census_checked :
  stock_surface_native_direct_writer_claim.
Proof.
  unfold stock_surface_native_direct_writer_claim,
    us_area1_stock_surface_native_bodies,
    jp_area1_stock_surface_native_bodies,
    body_assigns_named_pos_xyz, body_calls_ident,
    body_assigns_raw_xyz, stock_surface_direct_raw_xyz_mask.
  vm_compute. repeat split.
Qed.

(** * Scheduler and fixed-body receipts *)

Definition us_precollision_fixed_bodies : list Clight.function :=
  [PCUSL.f_clear_dynamic_surfaces;
   PCUOL.f_update_objects;
   PCUOL.f_update_terrain_objects;
   PCUOL.f_update_objects_in_list;
   PCUOL.f_update_objects_starting_at;
   PCUOL.f_update_objects_during_time_stop;
   PCUPD.f_apply_mario_platform_displacement;
   PCUOC.f_detect_object_hitbox_overlap;
   PCUOC.f_detect_object_hurtbox_overlap;
   PCUOC.f_clear_object_collision;
   PCUOC.f_check_collision_in_list;
   PCUOC.f_check_player_object_collision;
   PCUOC.f_check_destructive_object_collision;
   PCUOC.f_check_pushable_object_collision;
   PCUOC.f_detect_object_collisions].

Definition jp_precollision_fixed_bodies : list Clight.function :=
  [PCJSL.f_clear_dynamic_surfaces;
   PCJOL.f_update_objects;
   PCJOL.f_update_terrain_objects;
   PCJOL.f_update_objects_in_list;
   PCJOL.f_update_objects_starting_at;
   PCJOL.f_update_objects_during_time_stop;
   PCJPD.f_apply_mario_platform_displacement;
   PCJOC.f_detect_object_hitbox_overlap;
   PCJOC.f_detect_object_hurtbox_overlap;
   PCJOC.f_clear_object_collision;
   PCJOC.f_check_collision_in_list;
   PCJOC.f_check_player_object_collision;
   PCJOC.f_check_destructive_object_collision;
   PCJOC.f_check_pushable_object_collision;
   PCJOC.f_detect_object_collisions].

Definition body_has_direct_named_or_raw_xyz
    (position_field raw_data as_f32 : ident)
    (body : Clight.function) : bool :=
  body_assigns_named_pos_xyz position_field body ||
  body_assigns_raw_xyz raw_data as_f32 body.

Definition precollision_scheduler_source_shape_claim : Prop :=
  ident_subsequenceb
    [PCUOL._clear_dynamic_surfaces;
     PCUOL._update_terrain_objects;
     PCUOL._apply_mario_platform_displacement;
     PCUOL._detect_object_collisions;
     PCUOL._update_non_terrain_objects]
    (direct_callees_s (Clight.fn_body PCUOL.f_update_objects)) = true /\
  ident_subsequenceb
    [PCJOL._clear_dynamic_surfaces;
     PCJOL._update_terrain_objects;
     PCJOL._apply_mario_platform_displacement;
     PCJOL._detect_object_collisions;
     PCJOL._update_non_terrain_objects]
    (direct_callees_s (Clight.fn_body PCJOL.f_update_objects)) = true /\
  direct_callees_s (Clight.fn_body PCUOL.f_update_terrain_objects) =
    [PCUOL._update_objects_in_list; PCUOL._update_objects_in_list] /\
  direct_callees_s (Clight.fn_body PCJOL.f_update_terrain_objects) =
    [PCJOL._update_objects_in_list; PCJOL._update_objects_in_list] /\
  direct_callees_s (Clight.fn_body PCUOL.f_update_objects_in_list) =
    [PCUOL._update_objects_starting_at;
     PCUOL._update_objects_during_time_stop] /\
  direct_callees_s (Clight.fn_body PCJOL.f_update_objects_in_list) =
    [PCJOL._update_objects_starting_at;
     PCJOL._update_objects_during_time_stop] /\
  direct_callees_s (Clight.fn_body PCUOL.f_update_objects_starting_at) =
    [PCUOL._cur_obj_update] /\
  direct_callees_s (Clight.fn_body PCJOL.f_update_objects_starting_at) =
    [PCJOL._cur_obj_update] /\
  direct_callees_s
      (Clight.fn_body PCUOL.f_update_objects_during_time_stop) =
    [PCUOL._cur_obj_update] /\
  direct_callees_s
      (Clight.fn_body PCJOL.f_update_objects_during_time_stop) =
    [PCJOL._cur_obj_update].

Theorem precollision_scheduler_source_shape_checked :
  precollision_scheduler_source_shape_claim.
Proof.
  unfold precollision_scheduler_source_shape_claim.
  vm_compute. repeat split.
Qed.

(** Every fixed scheduler/collision body above is free of a direct generated
    [pos[0..2]] or [rawData.asF32[6..8]] assignment.  The list intentionally
    stops at [cur_obj_update], whose behavior-script dispatch is the remaining
    transitive frame-condition boundary. *)
Definition fixed_precollision_direct_writer_claim : Prop :=
  map
    (body_has_direct_named_or_raw_xyz
      PCUOL._pos PCUOL._rawData PCUOL._asF32)
    us_precollision_fixed_bodies = repeat false 15 /\
  map
    (body_has_direct_named_or_raw_xyz
      PCJOL._pos PCJOL._rawData PCJOL._asF32)
    jp_precollision_fixed_bodies = repeat false 15.

Theorem fixed_precollision_direct_writer_census_checked :
  fixed_precollision_direct_writer_claim.
Proof.
  unfold fixed_precollision_direct_writer_claim,
    us_precollision_fixed_bodies, jp_precollision_fixed_bodies,
    body_has_direct_named_or_raw_xyz,
    body_assigns_named_pos_xyz, body_assigns_raw_xyz.
  vm_compute. split; reflexivity.
Qed.

(** Match a call whose first argument is a selected integer literal. *)
Definition is_call_with_first_int_literal
    (callee : ident) (first : Z) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _) (Econst_int found_first _ :: _) =>
      Pos.eqb found_callee callee &&
      Int.eq found_first (Int.repr first)
  | _ => false
  end.

Fixpoint calls_with_first_int_literal_s
    (callee : ident) (first : Z) (s : statement) : bool :=
  is_call_with_first_int_literal callee first s ||
  match s with
  | Ssequence lhs rhs | Sloop lhs rhs =>
      calls_with_first_int_literal_s callee first lhs ||
      calls_with_first_int_literal_s callee first rhs
  | Sifthenelse _ yes_branch no_branch =>
      calls_with_first_int_literal_s callee first yes_branch ||
      calls_with_first_int_literal_s callee first no_branch
  | Sswitch _ cases =>
      calls_with_first_int_literal_ls callee first cases
  | Slabel _ body => calls_with_first_int_literal_s callee first body
  | _ => false
  end
with calls_with_first_int_literal_ls
    (callee : ident) (first : Z) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      calls_with_first_int_literal_s callee first body ||
      calls_with_first_int_literal_ls callee first rest
  end.

(** The scheduler body contains a displacement-helper call whose first
    argument is the literal [1].  The helper contains a [set_mario_pos] call
    and receiver-neutral raw-object XYZ stores, while [set_mario_pos] contains
    the three named State-position component lvalue shapes.  These occurrence
    receipts do not prove call uniqueness, branch ownership, joint execution,
    expression evaluation, or pointer identity; all of those remain part of
    the linked Clight refinement below. *)
Definition platform_state_only_source_shape_claim : Prop :=
  calls_with_first_int_literal_s PCUPD._apply_platform_displacement 1
    (Clight.fn_body PCUPD.f_apply_mario_platform_displacement) = true /\
  calls_with_first_int_literal_s PCJPD._apply_platform_displacement 1
    (Clight.fn_body PCJPD.f_apply_mario_platform_displacement) = true /\
  calls_ident_s PCUPD._set_mario_pos
    (Clight.fn_body PCUPD.f_apply_platform_displacement) = true /\
  calls_ident_s PCJPD._set_mario_pos
    (Clight.fn_body PCJPD.f_apply_platform_displacement) = true /\
  map (fun component =>
    assigns_array_slot_s PCUPD._pos component
      (Clight.fn_body PCUPD.f_set_mario_pos)) [0; 1; 2] =
    [true; true; true] /\
  map (fun component =>
    assigns_array_slot_s PCJPD._pos component
      (Clight.fn_body PCJPD.f_set_mario_pos)) [0; 1; 2] =
    [true; true; true] /\
  body_assigns_named_pos_xyz PCUPD._pos
    PCUPD.f_apply_platform_displacement = false /\
  body_assigns_named_pos_xyz PCJPD._pos
    PCJPD.f_apply_platform_displacement = false /\
  map (fun component =>
    assigns_raw_xyz_slot_s PCUPD._rawData PCUPD._asF32 component
      (Clight.fn_body PCUPD.f_apply_platform_displacement)) [6; 7; 8] =
    [true; true; true] /\
  map (fun component =>
    assigns_raw_xyz_slot_s PCJPD._rawData PCJPD._asF32 component
      (Clight.fn_body PCJPD.f_apply_platform_displacement)) [6; 7; 8] =
    [true; true; true].

Theorem platform_state_only_source_shape_checked :
  platform_state_only_source_shape_claim.
Proof.
  unfold platform_state_only_source_shape_claim,
    body_assigns_named_pos_xyz.
  vm_compute. repeat split.
Qed.

(** * Abstract semantic classification

    [MarioXYZViews] contains only the three coordinate views relevant to the
    installer question.  [PlatformMarioPhase] is the intended abstract effect
    of the source's [isMario = 1] path: either the guard skips the helper or
    State changes while Object and Graphics remain untouched.  The occurrence
    receipts above do not establish this relation for linked execution. *)
Section PrecollisionSemantics.

Context {Coordinate : Type}.

Record MarioXYZViews : Type := {
  precollision_state_xyz : Coordinate;
  precollision_object_xyz : Coordinate;
  precollision_graphics_xyz : Coordinate
}.

Definition write_precollision_state_only
    (next_state : Coordinate) (before : MarioXYZViews) : MarioXYZViews := {|
  precollision_state_xyz := next_state;
  precollision_object_xyz := precollision_object_xyz before;
  precollision_graphics_xyz := precollision_graphics_xyz before
|}.

Inductive PlatformMarioPhase : MarioXYZViews -> MarioXYZViews -> Prop :=
| PlatformMarioSkipped :
    forall before, PlatformMarioPhase before before
| PlatformMarioApplied :
    forall before next_state,
      PlatformMarioPhase before
        (write_precollision_state_only next_state before).

Definition MarioXYZFrame
    (before after : MarioXYZViews) : Prop := after = before.

(** This is the precise remaining semantic bridge for the terrain prefix.
    It requires [clear_dynamic_surfaces] plus both stock spawner/surface-list
    interpreter walks to frame Mario's three XYZ regions.  A linked proof must
    derive it from stock object-list membership, current-object/Mario
    non-aliasing, fresh-child allocation, helper closure, and external-call
    frames; the definition does not assume any target-region fact. *)
Definition Area1TerrainDispatchXYZFrameObligation
    (retail_terrain_prefix : MarioXYZViews -> MarioXYZViews -> Prop) : Prop :=
  forall before after,
    retail_terrain_prefix before after -> MarioXYZFrame before after.

(** The generated call/literal receipts above do not by themselves execute
    the true platform branch.  This separate refinement must show that every
    linked platform interval has one of the two effects represented by
    [PlatformMarioPhase]. *)
Definition Area1PlatformMarioPhaseClightRefinementObligation
    (retail_platform_phase : MarioXYZViews -> MarioXYZViews -> Prop) : Prop :=
  forall before after,
    retail_platform_phase before after -> PlatformMarioPhase before after.

(** Object collision is source-checked as a direct non-writer, but linked
    helper, alias, and external-call framing is still required. *)
Definition Area1CollisionXYZFrameObligation
    (retail_collision_phase : MarioXYZViews -> MarioXYZViews -> Prop) : Prop :=
  forall before after,
    retail_collision_phase before after -> MarioXYZFrame before after.

Lemma platform_mario_phase_preserves_object_and_graphics :
  forall before after,
    PlatformMarioPhase before after ->
    precollision_object_xyz after = precollision_object_xyz before /\
    precollision_graphics_xyz after = precollision_graphics_xyz before.
Proof.
  intros before after Hphase.
  inversion Hphase; subst; split; reflexivity.
Qed.

(** A State/Object split at collision sampling has only two abstract sources
    once the terrain and collision routines satisfy their XYZ frames: it was
    already present at the start of the prefix, or the Mario platform branch
    ran and changed State away from the retained Object sample. *)
Theorem platform_phase_state_object_split_source :
  forall before after,
    PlatformMarioPhase before after ->
    precollision_state_xyz after <> precollision_object_xyz after ->
    precollision_state_xyz before <> precollision_object_xyz before \/
    exists next_state,
      after = write_precollision_state_only next_state before /\
      next_state <> precollision_object_xyz before.
Proof.
  intros before after Hphase Hsplit.
  inversion Hphase; subst.
  - left. exact Hsplit.
  - right. exists next_state. split; [reflexivity |].
    exact Hsplit.
Qed.

Theorem synchronized_platform_split_requires_effective_apply :
  forall before after,
    precollision_state_xyz before = precollision_object_xyz before ->
    PlatformMarioPhase before after ->
    precollision_state_xyz after <> precollision_object_xyz after ->
    exists next_state,
      after = write_precollision_state_only next_state before /\
      next_state <> precollision_object_xyz before.
Proof.
  intros before after Hsync Hphase Hsplit.
  destruct (platform_phase_state_object_split_source
    before after Hphase Hsplit) as [Hprior | Happlied].
  - contradiction.
  - exact Happlied.
Qed.

(** Platform displacement cannot install Ink's Object/Graphics gap.  It can
    install the distinct State-first shape, but any collision-time
    Object/Graphics separation must have existed before the platform phase
    (or come from failure of the terrain frame premise). *)
Theorem platform_phase_object_graphics_split_iff_preexisting :
  forall before after,
    PlatformMarioPhase before after ->
    (precollision_object_xyz after <> precollision_graphics_xyz after <->
     precollision_object_xyz before <> precollision_graphics_xyz before).
Proof.
  intros before after Hphase.
  pose proof
    (platform_mario_phase_preserves_object_and_graphics
      before after Hphase) as (Hobject & Hgraphics).
  rewrite Hobject, Hgraphics. reflexivity.
Qed.

(** Composition of the exact frame boundaries.  [terrain_sample] is the
    state after clear/update-terrain, [platform_sample] after apply, and
    [collision_sample] the sample consumed by object collision. *)
Theorem framed_precollision_state_first_installer_classification :
  forall entry terrain_sample platform_sample collision_sample,
    MarioXYZFrame entry terrain_sample ->
    PlatformMarioPhase terrain_sample platform_sample ->
    MarioXYZFrame platform_sample collision_sample ->
    precollision_state_xyz entry = precollision_object_xyz entry ->
    precollision_state_xyz collision_sample <>
      precollision_object_xyz collision_sample ->
    exists next_state,
      collision_sample = write_precollision_state_only next_state entry /\
      next_state <> precollision_object_xyz entry.
Proof.
  intros entry terrain_sample platform_sample collision_sample
    Hterrain Hplatform Hcollision Hsync Hsplit.
  unfold MarioXYZFrame in Hterrain, Hcollision.
  subst terrain_sample collision_sample.
  now eapply synchronized_platform_split_requires_effective_apply.
Qed.

Theorem framed_precollision_preserves_object_graphics_sample :
  forall entry terrain_sample platform_sample collision_sample,
    MarioXYZFrame entry terrain_sample ->
    PlatformMarioPhase terrain_sample platform_sample ->
    MarioXYZFrame platform_sample collision_sample ->
    precollision_object_xyz collision_sample =
      precollision_object_xyz entry /\
    precollision_graphics_xyz collision_sample =
      precollision_graphics_xyz entry.
Proof.
  intros entry terrain_sample platform_sample collision_sample
    Hterrain Hplatform Hcollision.
  unfold MarioXYZFrame in Hterrain, Hcollision.
  subst terrain_sample collision_sample.
  now apply platform_mario_phase_preserves_object_and_graphics.
Qed.

Corollary framed_precollision_ink_gap_requires_preexisting_gap :
  forall entry terrain_sample platform_sample collision_sample,
    MarioXYZFrame entry terrain_sample ->
    PlatformMarioPhase terrain_sample platform_sample ->
    MarioXYZFrame platform_sample collision_sample ->
    precollision_object_xyz entry = precollision_graphics_xyz entry ->
    precollision_object_xyz collision_sample <>
      precollision_graphics_xyz collision_sample ->
    False.
Proof.
  intros entry terrain_sample platform_sample collision_sample
    Hterrain Hplatform Hcollision Hsync Hsplit.
  pose proof
    (framed_precollision_preserves_object_graphics_sample
      entry terrain_sample platform_sample collision_sample
      Hterrain Hplatform Hcollision) as (Hobject & Hgraphics).
  apply Hsplit. rewrite Hobject, Hgraphics. exact Hsync.
Qed.

End PrecollisionSemantics.

(** The capstone is intentionally a generated-syntax boundary.  It does not
    inhabit [Area1TerrainDispatchXYZFrameObligation],
    [Area1PlatformMarioPhaseClightRefinementObligation], or
    [Area1CollisionXYZFrameObligation] for linked retail execution and
    therefore does not claim that a clean installer is impossible. *)
Definition Area1PrecollisionWriterSourceBoundary : Prop :=
  stock_surface_native_direct_writer_claim /\
  precollision_scheduler_source_shape_claim /\
  fixed_precollision_direct_writer_claim /\
  platform_state_only_source_shape_claim.

Theorem area1_precollision_writer_source_boundary_checked :
  Area1PrecollisionWriterSourceBoundary.
Proof.
  unfold Area1PrecollisionWriterSourceBoundary.
  split; [exact stock_surface_native_direct_writer_census_checked |].
  split; [exact precollision_scheduler_source_shape_checked |].
  split; [exact fixed_precollision_direct_writer_census_checked |].
  exact platform_state_only_source_shape_checked.
Qed.
