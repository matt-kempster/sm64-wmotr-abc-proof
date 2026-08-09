From Coq Require Import List ZArith.
From compcert Require Import AST Clight Ctypes.
From LessThanOneAPress.Generated Require Import
  us_behavior_data us_obj_behaviors us_spawn_object us_object_helpers
  us_obj_behaviors_2 us_behavior_actions
  us_behavior_script us_surface_load us_ssl_script us_area
  jp_behavior_data jp_obj_behaviors jp_spawn_object jp_object_helpers
  jp_obj_behaviors_2 jp_behavior_actions
  jp_behavior_script jp_surface_load jp_ssl_script jp_area.
From LessThanOneAPress.Proofs Require Import
  ASTFacts LinkedClightPrograms NormalizedClightPrograms.

Import ListNotations.

Module CUBD := us_behavior_data.
Module CUOB := us_obj_behaviors.
Module CUOB2 := us_obj_behaviors_2.
Module CUBA := us_behavior_actions.
Module CUSO := us_spawn_object.
Module CUOH := us_object_helpers.
Module CUBS := us_behavior_script.
Module CUSL := us_surface_load.
Module CUSS := us_ssl_script.
Module CUA := us_area.

Module CJBD := jp_behavior_data.
Module CJOB := jp_obj_behaviors.
Module CJOB2 := jp_obj_behaviors_2.
Module CJBA := jp_behavior_actions.
Module CJSO := jp_spawn_object.
Module CJOH := jp_object_helpers.
Module CJBS := jp_behavior_script.
Module CJSL := jp_surface_load.
Module CJSS := jp_ssl_script.
Module CJA := jp_area.

Definition internal_body_mentions_ident
    (needle : ident) (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gfun (Internal function) =>
      statement_mentions_ident_s needle (fn_body function)
  | _ => false
  end.

Definition internal_body_mentioning_ids
    (needle : ident) (definitions : list (ident * globdef Clight.fundef type))
    : list ident :=
  map fst (filter (internal_body_mentions_ident needle) definitions).

Definition global_initializer_mentions_addrof
    (needle : ident) (entry : ident * globdef Clight.fundef type) : bool :=
  match snd entry with
  | Gvar variable =>
      initializer_list_mentions_addrof needle (gvar_init variable)
  | _ => false
  end.

Definition initializer_addrof_owner_ids
    (needle : ident) (definitions : list (ident * globdef Clight.fundef type))
    : list ident :=
  map fst (filter (global_initializer_mentions_addrof needle) definitions).

Definition us_source_definitions := unit_global_definitions us_units.
Definition jp_source_definitions := unit_global_definitions jp_units.

Definition lhs_object_field_is
    (object_tag field : ident) (lhs : expr) : bool :=
  match lhs with
  | Efield (Ederef _ (Tstruct found_object _)) found_field _ =>
      Pos.eqb found_object object_tag && Pos.eqb found_field field
  | _ => false
  end.

Fixpoint assigns_object_field_s
    (object_tag field : ident) (statement : statement) : bool :=
  match statement with
  | Sassign lhs _ => lhs_object_field_is object_tag field lhs
  | Ssequence first second | Sloop first second =>
      assigns_object_field_s object_tag field first ||
      assigns_object_field_s object_tag field second
  | Sifthenelse _ yes_branch no_branch =>
      assigns_object_field_s object_tag field yes_branch ||
      assigns_object_field_s object_tag field no_branch
  | Sswitch _ cases => assigns_object_field_ls object_tag field cases
  | Slabel _ body => assigns_object_field_s object_tag field body
  | _ => false
  end
with assigns_object_field_ls
    (object_tag field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_object_field_s object_tag field body ||
      assigns_object_field_ls object_tag field rest
  end.

Definition internal_object_field_assignment_sites
    (object_tag field : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function) =>
            assigns_object_field_s object_tag field (fn_body function)
        | _ => false
        end)
      definitions).

(** This file deliberately proves a generated-source census, not a
    whole-program reachability theorem.  The lists below are computed from all
    translation units in [us_units] and [jp_units], including declarations
    which are later normalized by [NormalizedClightPrograms]. *)

Definition expected_us_collision_data_writers : list ident :=
  [ CUBS._bhv_cmd_load_collision_data;
    CUSO._allocate_object;
    CUOH._obj_set_collision_data;
    CUOB2._bhv_platform_on_track_init;
    CUOB2._bhv_seesaw_platform_init;
    CUOB2._bhv_ferris_wheel_axle_init;
    CUOB2._bhv_ttc_rotating_solid_init;
    CUOB2._bhv_ttc_treadmill_init;
    CUOB2._bhv_ttc_cog_init;
    CUOB2._bhv_ttc_pit_block_init;
    CUOB2._bhv_sliding_plat_2_init;
    CUOB2._bhv_rotating_octagonal_plat_init;
    CUOB2._bhv_animates_on_floor_switch_press_loop;
    CUOB2._bhv_activated_back_and_forth_platform_init;
    CUOB2._dorrie_act_move;
    CUOB2._dorrie_act_raise_head;
    CUOB2._eyerok_hand_act_sleep;
    CUOB2._eyerok_hand_act_open;
    CUOB2._eyerok_hand_act_close;
    CUOB2._eyerok_hand_act_attacked;
    CUBA._bhv_ddd_warp_loop ].

Definition expected_jp_collision_data_writers : list ident :=
  [ CJBS._bhv_cmd_load_collision_data;
    CJSO._allocate_object;
    CJOH._obj_set_collision_data;
    CJOB2._bhv_platform_on_track_init;
    CJOB2._bhv_seesaw_platform_init;
    CJOB2._bhv_ferris_wheel_axle_init;
    CJOB2._bhv_ttc_rotating_solid_init;
    CJOB2._bhv_ttc_treadmill_init;
    CJOB2._bhv_ttc_cog_init;
    CJOB2._bhv_ttc_pit_block_init;
    CJOB2._bhv_sliding_plat_2_init;
    CJOB2._bhv_rotating_octagonal_plat_init;
    CJOB2._bhv_animates_on_floor_switch_press_loop;
    CJOB2._bhv_activated_back_and_forth_platform_init;
    CJOB2._dorrie_act_move;
    CJOB2._dorrie_act_raise_head;
    CJOB2._eyerok_hand_act_sleep;
    CJOB2._eyerok_hand_act_open;
    CJOB2._eyerok_hand_act_close;
    CJOB2._eyerok_hand_act_attacked;
    CJBA._bhv_ddd_warp_loop ].

(** The collision mesh address occurs in exactly one global initializer: the
    stock top behavior.  No internal function embeds that address.  Likewise,
    the only static [bhvPyramidTop] pointer is the SSL Area-1 LevelScript
    object record.  Thus no behavior command or native C callback contains a
    statically encoded request to clone the top behavior. *)
Theorem us_top_static_reference_census :
  internal_body_mentioning_ids CUBD._ssl_seg7_collision_pyramid_top
    us_source_definitions = [] /\
  initializer_addrof_owner_ids CUBD._ssl_seg7_collision_pyramid_top
    us_source_definitions = [CUBD._bhvPyramidTop] /\
  internal_body_mentioning_ids CUBD._bhvPyramidTop
    us_source_definitions = [] /\
  initializer_addrof_owner_ids CUBD._bhvPyramidTop
    us_source_definitions = [CUSS._script_func_local_1].
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_top_static_reference_census :
  internal_body_mentioning_ids CJBD._ssl_seg7_collision_pyramid_top
    jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._ssl_seg7_collision_pyramid_top
    jp_source_definitions = [CJBD._bhvPyramidTop] /\
  internal_body_mentioning_ids CJBD._bhvPyramidTop
    jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._bhvPyramidTop
    jp_source_definitions = [CJSS._script_func_local_1].
Proof. vm_compute. repeat split; reflexivity. Qed.

(** [bhvWarp] has two static owners.  The area table classifies warp behavior
    identity, while the SSL LevelScript contains the actual source objects.
    There is no direct C-body occurrence which could be a special-case warp
    relocation or replacement.  This does not exclude generic position
    writers acting through an object pointer. *)
Theorem us_warp_static_reference_census :
  internal_body_mentioning_ids CUBD._bhvWarp us_source_definitions = [] /\
  initializer_addrof_owner_ids CUBD._bhvWarp us_source_definitions =
    [CUA._sWarpBhvSpawnTable; CUSS._level_ssl_entry].
Proof. vm_compute. split; reflexivity. Qed.

Theorem jp_warp_static_reference_census :
  internal_body_mentioning_ids CJBD._bhvWarp jp_source_definitions = [] /\
  initializer_addrof_owner_ids CJBD._bhvWarp jp_source_definitions =
    [CJA._sWarpBhvSpawnTable; CJSS._level_ssl_entry].
Proof. vm_compute. split; reflexivity. Qed.

(** Complete direct writer census for the [collisionData] field of the
    generated [struct Object].  This intentionally includes functions from
    other levels: a later clean-SSL reachability proof must eliminate those
    callbacks by behavior provenance rather than pretending they do not
    exist. *)
Theorem us_object_collision_data_writer_census :
  internal_object_field_assignment_sites
    CUSO._Object CUSO._collisionData us_source_definitions =
  expected_us_collision_data_writers.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_object_collision_data_writer_census :
  internal_object_field_assignment_sites
    CJSO._Object CJSO._collisionData jp_source_definitions =
  expected_jp_collision_data_writers.
Proof. vm_compute. reflexivity. Qed.

(** * Stock top spawn identity *)

(** The initializer and explicit action routines containing the observed stock
    top spawn sites request pillar detectors and fragments, never a second
    [bhvPyramidTop].  The earlier whole-source reference census separately
    excludes another direct static [bhvPyramidTop] request. *)
Theorem us_stock_top_callbacks_do_not_clone_top :
  calls_ident_s CUOB._spawn_object_abs_with_rot
    (fn_body CUOB.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s CUOB._bhvPyramidPillarTouchDetector
    (fn_body CUOB.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s CUBD._bhvPyramidTop
    (fn_body CUOB.f_bhv_pyramid_top_init) = false /\
  calls_ident_s CUOB._spawn_object
    (fn_body CUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_ident_s CUOB._bhvPyramidTopFragment
    (fn_body CUOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_ident_s CUBD._bhvPyramidTop
    (fn_body CUOB.f_bhv_pyramid_top_spinning) = false /\
  calls_ident_s CUOB._spawn_object
    (fn_body CUOB.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_ident_s CUOB._bhvPyramidTopFragment
    (fn_body CUOB.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_ident_s CUBD._bhvPyramidTop
    (fn_body CUOB.f_bhv_pyramid_top_explode) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_stock_top_callbacks_do_not_clone_top :
  calls_ident_s CJOB._spawn_object_abs_with_rot
    (fn_body CJOB.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s CJOB._bhvPyramidPillarTouchDetector
    (fn_body CJOB.f_bhv_pyramid_top_init) = true /\
  statement_mentions_ident_s CJBD._bhvPyramidTop
    (fn_body CJOB.f_bhv_pyramid_top_init) = false /\
  calls_ident_s CJOB._spawn_object
    (fn_body CJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_ident_s CJOB._bhvPyramidTopFragment
    (fn_body CJOB.f_bhv_pyramid_top_spinning) = true /\
  statement_mentions_ident_s CJBD._bhvPyramidTop
    (fn_body CJOB.f_bhv_pyramid_top_spinning) = false /\
  calls_ident_s CJOB._spawn_object
    (fn_body CJOB.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_ident_s CJOB._bhvPyramidTopFragment
    (fn_body CJOB.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_ident_s CJBD._bhvPyramidTop
    (fn_body CJOB.f_bhv_pyramid_top_explode) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Neither kind of top-created child carries the top mesh or invokes the
    collision-model loader from its behavior script. *)
Theorem us_top_children_have_no_top_collision_initializer :
  initializer_list_mentions_addrof CUBD._ssl_seg7_collision_pyramid_top
    (gvar_init CUBD.v_bhvPyramidTopFragment) = false /\
  initializer_list_mentions_addrof CUBD._load_object_collision_model
    (gvar_init CUBD.v_bhvPyramidTopFragment) = false /\
  initializer_list_mentions_addrof CUBD._ssl_seg7_collision_pyramid_top
    (gvar_init CUBD.v_bhvPyramidPillarTouchDetector) = false /\
  initializer_list_mentions_addrof CUBD._load_object_collision_model
    (gvar_init CUBD.v_bhvPyramidPillarTouchDetector) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

Theorem jp_top_children_have_no_top_collision_initializer :
  initializer_list_mentions_addrof CJBD._ssl_seg7_collision_pyramid_top
    (gvar_init CJBD.v_bhvPyramidTopFragment) = false /\
  initializer_list_mentions_addrof CJBD._load_object_collision_model
    (gvar_init CJBD.v_bhvPyramidTopFragment) = false /\
  initializer_list_mentions_addrof CJBD._ssl_seg7_collision_pyramid_top
    (gvar_init CJBD.v_bhvPyramidPillarTouchDetector) = false /\
  initializer_list_mentions_addrof CJBD._load_object_collision_model
    (gvar_init CJBD.v_bhvPyramidPillarTouchDetector) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** * Allocation and ordinary spawn/copy source shape *)

Fixpoint all_object_field_assignments_are_null_s
    (object_tag field : ident) (statement : statement) : bool :=
  match statement with
  | Sassign lhs rhs =>
      if lhs_object_field_is object_tag field lhs
      then rhs_is_null_pointer rhs
      else true
  | Ssequence first second | Sloop first second =>
      all_object_field_assignments_are_null_s object_tag field first &&
      all_object_field_assignments_are_null_s object_tag field second
  | Sifthenelse _ yes_branch no_branch =>
      all_object_field_assignments_are_null_s object_tag field yes_branch &&
      all_object_field_assignments_are_null_s object_tag field no_branch
  | Sswitch _ cases =>
      all_object_field_assignments_are_null_ls object_tag field cases
  | Slabel _ body =>
      all_object_field_assignments_are_null_s object_tag field body
  | _ => true
  end
with all_object_field_assignments_are_null_ls
    (object_tag field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => true
  | LScons _ body rest =>
      all_object_field_assignments_are_null_s object_tag field body &&
      all_object_field_assignments_are_null_ls object_tag field rest
  end.

(** On each generated source path, [allocate_object] has a direct Object
    [collisionData] assignment and every such assignment is null.  This is a
    stronger syntactic fact than mere occurrence, but still needs Clight
    control-flow execution to establish that a successful return passed it. *)
Theorem allocate_object_collision_reset_source_shape :
  assigns_object_field_s CUSO._Object CUSO._collisionData
    (fn_body CUSO.f_allocate_object) = true /\
  all_object_field_assignments_are_null_s CUSO._Object CUSO._collisionData
    (fn_body CUSO.f_allocate_object) = true /\
  assigns_object_field_s CJSO._Object CJSO._collisionData
    (fn_body CJSO.f_allocate_object) = true /\
  all_object_field_assignments_are_null_s CJSO._Object CJSO._collisionData
    (fn_body CJSO.f_allocate_object) = true.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The generated normal-construction body contains an allocation call and
    direct requested-behavior assignments, with no direct collision-data
    assignment.  This syntax receipt does not prove executed ordering,
    successful-return control flow, or alias freedom. *)
Theorem create_object_identity_source_shape :
  calls_ident_s CUSO._allocate_object (fn_body CUSO.f_create_object) = true /\
  assigns_object_field_s CUSO._Object CUSO._curBhvCommand
    (fn_body CUSO.f_create_object) = true /\
  assigns_object_field_s CUSO._Object CUSO._behavior
    (fn_body CUSO.f_create_object) = true /\
  assigns_object_field_s CUSO._Object CUSO._collisionData
    (fn_body CUSO.f_create_object) = false /\
  calls_ident_s CJSO._allocate_object (fn_body CJSO.f_create_object) = true /\
  assigns_object_field_s CJSO._Object CJSO._curBhvCommand
    (fn_body CJSO.f_create_object) = true /\
  assigns_object_field_s CJSO._Object CJSO._behavior
    (fn_body CJSO.f_create_object) = true /\
  assigns_object_field_s CJSO._Object CJSO._collisionData
    (fn_body CJSO.f_create_object) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The helper named [obj_copy_pos_and_angle] delegates only to the position
    and angle copies; none of the three bodies writes behavior identity or
    collision data.  Therefore this ordinary spawn helper is not itself a
    collision-preserving clone primitive. *)
Theorem ordinary_object_copy_does_not_copy_identity_or_collision :
  direct_callees_s (fn_body CUOH.f_obj_copy_pos_and_angle) =
    [CUOH._obj_copy_pos; CUOH._obj_copy_angle] /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_obj_copy_pos_and_angle) = false /\
  assigns_object_field_s CUOH._Object CUOH._behavior
    (fn_body CUOH.f_obj_copy_pos_and_angle) = false /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_obj_copy_pos) = false /\
  assigns_object_field_s CUOH._Object CUOH._behavior
    (fn_body CUOH.f_obj_copy_pos) = false /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_obj_copy_angle) = false /\
  assigns_object_field_s CUOH._Object CUOH._behavior
    (fn_body CUOH.f_obj_copy_angle) = false /\
  direct_callees_s (fn_body CJOH.f_obj_copy_pos_and_angle) =
    [CJOH._obj_copy_pos; CJOH._obj_copy_angle] /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_obj_copy_pos_and_angle) = false /\
  assigns_object_field_s CJOH._Object CJOH._behavior
    (fn_body CJOH.f_obj_copy_pos_and_angle) = false /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_obj_copy_pos) = false /\
  assigns_object_field_s CJOH._Object CJOH._behavior
    (fn_body CJOH.f_obj_copy_pos) = false /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_obj_copy_angle) = false /\
  assigns_object_field_s CJOH._Object CJOH._behavior
    (fn_body CJOH.f_obj_copy_angle) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The three ordinary helper bodies used by the top callbacks contain the
    expected calls to [spawn_object_at_origin], [create_object], or pose-copy
    helpers, and none directly writes [collisionData].  Call occurrence is not
    an executed ordering or freshness theorem. *)
Theorem ordinary_spawn_pipeline_source_shape :
  calls_ident_s CUOH._create_object
    (fn_body CUOH.f_spawn_object_at_origin) = true /\
  calls_ident_s CUOH._spawn_object_at_origin
    (fn_body CUOH.f_spawn_object) = true /\
  calls_ident_s CUOH._obj_copy_pos_and_angle
    (fn_body CUOH.f_spawn_object) = true /\
  calls_ident_s CUOH._spawn_object_at_origin
    (fn_body CUOH.f_spawn_object_abs_with_rot) = true /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_spawn_object_at_origin) = false /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_spawn_object) = false /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_spawn_object_abs_with_rot) = false /\
  calls_ident_s CJOH._create_object
    (fn_body CJOH.f_spawn_object_at_origin) = true /\
  calls_ident_s CJOH._spawn_object_at_origin
    (fn_body CJOH.f_spawn_object) = true /\
  calls_ident_s CJOH._obj_copy_pos_and_angle
    (fn_body CJOH.f_spawn_object) = true /\
  calls_ident_s CJOH._spawn_object_at_origin
    (fn_body CJOH.f_spawn_object_abs_with_rot) = true /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_spawn_object_at_origin) = false /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_spawn_object) = false /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_spawn_object_abs_with_rot) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** Behavior-script spawn opcode bodies contain calls to the ordinary spawn and
    pose-copy helpers and no direct collision-data assignment.  Freshness,
    call ordering, successful execution, and runtime behavior-argument
    provenance remain open; the unique initializer census above only excludes
    another statically encoded top reference. *)
Theorem behavior_spawn_commands_do_not_copy_collision_data :
  calls_ident_s CUBS._spawn_object_at_origin
    (fn_body CUBS.f_bhv_cmd_spawn_child) = true /\
  calls_ident_s CUBS._obj_copy_pos_and_angle
    (fn_body CUBS.f_bhv_cmd_spawn_child) = true /\
  assigns_object_field_s CUBS._Object CUBS._collisionData
    (fn_body CUBS.f_bhv_cmd_spawn_child) = false /\
  calls_ident_s CUBS._spawn_object_at_origin
    (fn_body CUBS.f_bhv_cmd_spawn_obj) = true /\
  calls_ident_s CUBS._obj_copy_pos_and_angle
    (fn_body CUBS.f_bhv_cmd_spawn_obj) = true /\
  assigns_object_field_s CUBS._Object CUBS._collisionData
    (fn_body CUBS.f_bhv_cmd_spawn_obj) = false /\
  calls_ident_s CUBS._spawn_object_at_origin
    (fn_body CUBS.f_bhv_cmd_spawn_child_with_param) = true /\
  calls_ident_s CUBS._obj_copy_pos_and_angle
    (fn_body CUBS.f_bhv_cmd_spawn_child_with_param) = true /\
  assigns_object_field_s CUBS._Object CUBS._collisionData
    (fn_body CUBS.f_bhv_cmd_spawn_child_with_param) = false /\
  calls_ident_s CJBS._spawn_object_at_origin
    (fn_body CJBS.f_bhv_cmd_spawn_child) = true /\
  calls_ident_s CJBS._obj_copy_pos_and_angle
    (fn_body CJBS.f_bhv_cmd_spawn_child) = true /\
  assigns_object_field_s CJBS._Object CJBS._collisionData
    (fn_body CJBS.f_bhv_cmd_spawn_child) = false /\
  calls_ident_s CJBS._spawn_object_at_origin
    (fn_body CJBS.f_bhv_cmd_spawn_obj) = true /\
  calls_ident_s CJBS._obj_copy_pos_and_angle
    (fn_body CJBS.f_bhv_cmd_spawn_obj) = true /\
  assigns_object_field_s CJBS._Object CJBS._collisionData
    (fn_body CJBS.f_bhv_cmd_spawn_obj) = false /\
  calls_ident_s CJBS._spawn_object_at_origin
    (fn_body CJBS.f_bhv_cmd_spawn_child_with_param) = true /\
  calls_ident_s CJBS._obj_copy_pos_and_angle
    (fn_body CJBS.f_bhv_cmd_spawn_child_with_param) = true /\
  assigns_object_field_s CJBS._Object CJBS._collisionData
    (fn_body CJBS.f_bhv_cmd_spawn_child_with_param) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** The generic behavior opcode and generic helper are genuine indirect
    writers, so they are retained in the census rather than declared
    impossible.  Each obtains its value through [segmented_to_virtual]; neither
    body embeds the pyramid-top collision symbol. *)
Theorem generic_collision_installers_are_indirect_source_shape :
  calls_ident_s CUBS._segmented_to_virtual
    (fn_body CUBS.f_bhv_cmd_load_collision_data) = true /\
  assigns_object_field_s CUBS._Object CUBS._collisionData
    (fn_body CUBS.f_bhv_cmd_load_collision_data) = true /\
  statement_mentions_ident_s CUBD._ssl_seg7_collision_pyramid_top
    (fn_body CUBS.f_bhv_cmd_load_collision_data) = false /\
  calls_ident_s CUOH._segmented_to_virtual
    (fn_body CUOH.f_obj_set_collision_data) = true /\
  assigns_object_field_s CUOH._Object CUOH._collisionData
    (fn_body CUOH.f_obj_set_collision_data) = true /\
  statement_mentions_ident_s CUBD._ssl_seg7_collision_pyramid_top
    (fn_body CUOH.f_obj_set_collision_data) = false /\
  calls_ident_s CJBS._segmented_to_virtual
    (fn_body CJBS.f_bhv_cmd_load_collision_data) = true /\
  assigns_object_field_s CJBS._Object CJBS._collisionData
    (fn_body CJBS.f_bhv_cmd_load_collision_data) = true /\
  statement_mentions_ident_s CJBD._ssl_seg7_collision_pyramid_top
    (fn_body CJBS.f_bhv_cmd_load_collision_data) = false /\
  calls_ident_s CJOH._segmented_to_virtual
    (fn_body CJOH.f_obj_set_collision_data) = true /\
  assigns_object_field_s CJOH._Object CJOH._collisionData
    (fn_body CJOH.f_obj_set_collision_data) = true /\
  statement_mentions_ident_s CJBD._ssl_seg7_collision_pyramid_top
    (fn_body CJOH.f_obj_set_collision_data) = false.
Proof. vm_compute. repeat split; reflexivity. Qed.

(** These receipts rule out only direct, stock-source relocation and ordinary
    collision-preserving cloning.  To lift them to clean retail reachability,
    one must still execute the linked spawn/interpreter paths, prove that
    current script pointers originate in the censused initializers, eliminate
    the non-SSL writer callbacks in the 21-entry list by behavior provenance,
    and establish memory-safety/external-call frames against forged aliases. *)
