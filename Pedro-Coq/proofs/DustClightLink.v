From Coq Require Import List.
From compcert Require Import AST Clight Clightdefs Ctypes Linking.
From Pedro.Generated Require Import
  us_mario us_object_list_processor us_behavior_script us_spawn_object
  us_object_helpers us_behavior_actions us_behavior_data
  jp_mario jp_object_list_processor jp_behavior_script jp_spawn_object
  jp_object_helpers jp_behavior_actions jp_behavior_data.

Import ListNotations.

Module UM := us_mario.
Module UOL := us_object_list_processor.
Module UBS := us_behavior_script.
Module USO := us_spawn_object.
Module UOH := us_object_helpers.
Module UBA := us_behavior_actions.
Module UBD := us_behavior_data.

Module JM := jp_mario.
Module JOL := jp_object_list_processor.
Module JBS := jp_behavior_script.
Module JSO := jp_spawn_object.
Module JOH := jp_object_helpers.
Module JBA := jp_behavior_actions.
Module JBD := jp_behavior_data.

(** A deliberately small linkable slice containing the exact generated
    definitions used by the dust episode.  The original [clightgen] programs
    repeat tentative declarations and incompatible translation-unit-local
    composite tags, so linking the unfiltered units is not a valid shortcut.
    These two disjoint definition sets are linked with CompCert's real
    [Linking.link].  The slices intentionally use an empty composite header to
    audit symbols without pretending that translation-unit-local layouts have
    already been reconciled.  Calls outside the selected set also remain
    unresolved.  This construction proves that the selected definitions
    coexist in one structural [Clight.program]; it is not a well-typed
    executable slice, a separate-compilation refinement, or a big-step
    execution of a retail frame. *)

Definition us_dust_core_definitions :
    list (ident * globdef Clight.fundef type) :=
  [ (UM._execute_mario_action, Gfun (Internal UM.f_execute_mario_action));
    (UOL._sObjectListUpdateOrder, Gvar UOL.v_sObjectListUpdateOrder);
    (UOL._sParticleTypes, Gvar UOL.v_sParticleTypes);
    (UOL._spawn_particle, Gfun (Internal UOL.f_spawn_particle));
    (UOL._bhv_mario_update, Gfun (Internal UOL.f_bhv_mario_update));
    (UOL._update_objects_starting_at,
      Gfun (Internal UOL.f_update_objects_starting_at));
    (UOL._update_non_terrain_objects,
      Gfun (Internal UOL.f_update_non_terrain_objects));
    (USO._try_allocate_object, Gfun (Internal USO.f_try_allocate_object));
    (USO._allocate_object, Gfun (Internal USO.f_allocate_object));
    (USO._create_object, Gfun (Internal USO.f_create_object));
    (UBS._cur_obj_update, Gfun (Internal UBS.f_cur_obj_update)) ].

Definition us_dust_leaf_definitions :
    list (ident * globdef Clight.fundef type) :=
  [ (UBD._bhvMistParticleSpawner, Gvar UBD.v_bhvMistParticleSpawner);
    (UBD._bhvWhitePuff1, Gvar UBD.v_bhvWhitePuff1);
    (UBD._bhvWhitePuff2, Gvar UBD.v_bhvWhitePuff2);
    (UBA._gCurrentObject, Gvar UBA.v_gCurrentObject);
    (UBA._bhv_white_puff_1_loop,
      Gfun (Internal UBA.f_bhv_white_puff_1_loop));
    (UBA._bhv_white_puff_2_loop,
      Gfun (Internal UBA.f_bhv_white_puff_2_loop));
    (UOH._spawn_object_at_origin,
      Gfun (Internal UOH.f_spawn_object_at_origin));
    (UOH._obj_copy_pos_and_angle,
      Gfun (Internal UOH.f_obj_copy_pos_and_angle));
    (UOH._obj_translate_xz_random,
      Gfun (Internal UOH.f_obj_translate_xz_random));
    (UBS._BehaviorCmdTable, Gvar UBS.v_BehaviorCmdTable);
    (UBS._gCurBhvCommand, Gvar UBS.v_gCurBhvCommand);
    (UBS._bhv_cmd_call_native,
      Gfun (Internal UBS.f_bhv_cmd_call_native));
    (UBS._bhv_cmd_parent_bit_clear,
      Gfun (Internal UBS.f_bhv_cmd_parent_bit_clear));
    (UBS._gRandomSeed16, Gvar UBS.v_gRandomSeed16);
    (UBS._random_float, Gfun (Internal UBS.f_random_float));
    (UBS._random_u16, Gfun (Internal UBS.f_random_u16)) ].

Definition jp_dust_core_definitions :
    list (ident * globdef Clight.fundef type) :=
  [ (JM._execute_mario_action, Gfun (Internal JM.f_execute_mario_action));
    (JOL._sObjectListUpdateOrder, Gvar JOL.v_sObjectListUpdateOrder);
    (JOL._sParticleTypes, Gvar JOL.v_sParticleTypes);
    (JOL._spawn_particle, Gfun (Internal JOL.f_spawn_particle));
    (JOL._bhv_mario_update, Gfun (Internal JOL.f_bhv_mario_update));
    (JOL._update_objects_starting_at,
      Gfun (Internal JOL.f_update_objects_starting_at));
    (JOL._update_non_terrain_objects,
      Gfun (Internal JOL.f_update_non_terrain_objects));
    (JSO._try_allocate_object, Gfun (Internal JSO.f_try_allocate_object));
    (JSO._allocate_object, Gfun (Internal JSO.f_allocate_object));
    (JSO._create_object, Gfun (Internal JSO.f_create_object));
    (JBS._cur_obj_update, Gfun (Internal JBS.f_cur_obj_update)) ].

Definition jp_dust_leaf_definitions :
    list (ident * globdef Clight.fundef type) :=
  [ (JBD._bhvMistParticleSpawner, Gvar JBD.v_bhvMistParticleSpawner);
    (JBD._bhvWhitePuff1, Gvar JBD.v_bhvWhitePuff1);
    (JBD._bhvWhitePuff2, Gvar JBD.v_bhvWhitePuff2);
    (JBA._gCurrentObject, Gvar JBA.v_gCurrentObject);
    (JBA._bhv_white_puff_1_loop,
      Gfun (Internal JBA.f_bhv_white_puff_1_loop));
    (JBA._bhv_white_puff_2_loop,
      Gfun (Internal JBA.f_bhv_white_puff_2_loop));
    (JOH._spawn_object_at_origin,
      Gfun (Internal JOH.f_spawn_object_at_origin));
    (JOH._obj_copy_pos_and_angle,
      Gfun (Internal JOH.f_obj_copy_pos_and_angle));
    (JOH._obj_translate_xz_random,
      Gfun (Internal JOH.f_obj_translate_xz_random));
    (JBS._BehaviorCmdTable, Gvar JBS.v_BehaviorCmdTable);
    (JBS._gCurBhvCommand, Gvar JBS.v_gCurBhvCommand);
    (JBS._bhv_cmd_call_native,
      Gfun (Internal JBS.f_bhv_cmd_call_native));
    (JBS._bhv_cmd_parent_bit_clear,
      Gfun (Internal JBS.f_bhv_cmd_parent_bit_clear));
    (JBS._gRandomSeed16, Gvar JBS.v_gRandomSeed16);
    (JBS._random_float, Gfun (Internal JBS.f_random_float));
    (JBS._random_u16, Gfun (Internal JBS.f_random_u16)) ].

Definition make_structural_slice
    (definitions : list (ident * globdef Clight.fundef type))
    (main : ident) : Clight.program :=
  Clightdefs.mkprogram [] definitions (map fst definitions) main Logic.I.

Definition us_dust_core_program :=
  make_structural_slice us_dust_core_definitions UOL._main.
Definition us_dust_leaf_program :=
  make_structural_slice us_dust_leaf_definitions UOL._main.
Definition jp_dust_core_program :=
  make_structural_slice jp_dust_core_definitions JOL._main.
Definition jp_dust_leaf_program :=
  make_structural_slice jp_dust_leaf_definitions JOL._main.

Definition option_successb {A : Type} (result : option A) : bool :=
  match result with
  | Some _ => true
  | None => false
  end.

Definition program_components
    (program : Clight.program) : AST.program Clight.fundef type :=
  Ctypes.program_of_program program.

Definition composite_components
    (program : Clight.program) : list composite_definition :=
  Ctypes.prog_types program.

Definition us_dust_ast_link_check : bool :=
  option_successb
    (link (program_components us_dust_core_program)
          (program_components us_dust_leaf_program)).

Definition jp_dust_ast_link_check : bool :=
  option_successb
    (link (program_components jp_dust_core_program)
          (program_components jp_dust_leaf_program)).

Theorem us_dust_ast_link_check_passes :
  us_dust_ast_link_check = true.
Proof. vm_compute. reflexivity. Qed.

Theorem jp_dust_ast_link_check_passes :
  jp_dust_ast_link_check = true.
Proof. vm_compute. reflexivity. Qed.

Lemma option_successb_has_witness :
  forall (A : Type) (result : option A),
    option_successb result = true ->
    exists value, result = Some value.
Proof.
  intros A [value |] Hsuccess; simpl in Hsuccess.
  - now exists value.
  - discriminate.
Qed.

(** Avoid reducing the proof-produced composite environment in
    [Ctypes.link_program].  The two executable component checks suffice to
    obtain a witness for CompCert's official Clight link. *)
Lemma ast_and_composite_links_lift_to_clight_pair :
  forall left right ast_linked composite_linked,
    link (program_components left) (program_components right) =
      Some ast_linked ->
    link (composite_components left) (composite_components right) =
      Some composite_linked ->
    exists linked, link left right = Some linked.
Proof.
  intros left right ast_linked composite_linked Hast Htypes.
  unfold program_components in Hast.
  unfold Clight.fundef in Hast.
  unfold composite_components in Htypes.
  Local Transparent Ctypes.Linker_program.
  change (exists linked, Ctypes.link_program left right = Some linked).
  unfold Ctypes.link_program.
  rewrite Hast.
  destruct (Ctypes.lift_option
    (link (Ctypes.prog_types left) (Ctypes.prog_types right)))
    as [[types Hlinked_types] | Hlinked_types].
  - destruct (Ctypes.link_build_composite_env
      (Ctypes.prog_types left) (Ctypes.prog_types right) types
      (Ctypes.prog_comp_env left) (Ctypes.prog_comp_env right)
      (Ctypes.prog_comp_env_eq left) (Ctypes.prog_comp_env_eq right)
      Hlinked_types) as (environment & Henvironment & Hextends).
    eexists. reflexivity.
  - rewrite Hlinked_types in Htypes. discriminate.
Qed.

Theorem us_dust_slice_link_succeeds :
  exists linked,
    link us_dust_core_program us_dust_leaf_program = Some linked.
Proof.
  destruct (option_successb_has_witness _ _
    us_dust_ast_link_check_passes) as [ast_linked Hast].
  eapply ast_and_composite_links_lift_to_clight_pair.
  - exact Hast.
  - vm_compute. reflexivity.
Qed.

Theorem jp_dust_slice_link_succeeds :
  exists linked,
    link jp_dust_core_program jp_dust_leaf_program = Some linked.
Proof.
  destruct (option_successb_has_witness _ _
    jp_dust_ast_link_check_passes) as [ast_linked Hast].
  eapply ast_and_composite_links_lift_to_clight_pair.
  - exact Hast.
  - vm_compute. reflexivity.
Qed.

(** The generated definitions were selected verbatim, rather than rewritten
    into a hand-authored function body. *)
Theorem selected_dust_definitions_are_verbatim :
  In (UOL._spawn_particle, Gfun (Internal UOL.f_spawn_particle))
      us_dust_core_definitions /\
  In (UBS._cur_obj_update, Gfun (Internal UBS.f_cur_obj_update))
      us_dust_core_definitions /\
  In (USO._allocate_object, Gfun (Internal USO.f_allocate_object))
      us_dust_core_definitions /\
  In (UBA._bhv_white_puff_1_loop,
      Gfun (Internal UBA.f_bhv_white_puff_1_loop))
      us_dust_leaf_definitions /\
  In (JOL._spawn_particle, Gfun (Internal JOL.f_spawn_particle))
      jp_dust_core_definitions /\
  In (JBS._cur_obj_update, Gfun (Internal JBS.f_cur_obj_update))
      jp_dust_core_definitions /\
  In (JSO._allocate_object, Gfun (Internal JSO.f_allocate_object))
      jp_dust_core_definitions /\
  In (JBA._bhv_white_puff_1_loop,
      Gfun (Internal JBA.f_bhv_white_puff_1_loop))
      jp_dust_leaf_definitions.
Proof. repeat split; simpl; tauto. Qed.
