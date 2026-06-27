(* Finite audit of non-Mario object-reference roots that could otherwise look
   like stale-pointer / cloning escape hatches.

   The earlier stale-pointer model focuses on MarioState object references.
   This file boxes in the other generated-Clight reference classes that show
   up around object unloading and held-object rendering:

   - object-owned Object* fields, namely Object.parentObj/Object.prevObj,
     Object.platform, Object.collidedObjs, and rawData.asObject behavior slots;
   - ObjectNode list links embedded in Object.header;
   - graph tree/list links and GraphNodeObject.sharedChild; and
   - GraphNodeHeldObject.objNode, including the render-side refresh path.

   These facts are syntactic/generated-code certificates.  They do not yet say
   that every writer is unreachable during a Pyramid warp; they give the later
   semantic proof a finite, checked list of roots and writer bodies to compose.
 *)

From Coq Require Import List PArith.BinPos.
Import ListNotations.
From compcert Require Import AST Ctypes Clight.
From SSLPyramid.Generated Require Import
  area audio_external behavior_actions graph_node interaction level_script
  level_update macro_special_objects mario mario_misc obj_behaviors
  object_helpers object_list_processor spawn_object ssl_area1_macro ssl_script.
From SSLPyramid.Proofs Require Import ASTFacts.

Module A := area.
Module AU := audio_external.
Module B := behavior_actions.
Module G := graph_node.
Module I := interaction.
Module LS := level_script.
Module L := level_update.
Module P := macro_special_objects.
Module M := mario.
Module MM := mario_misc.
Module OB := obj_behaviors.
Module H := object_helpers.
Module O := object_list_processor.
Module S := spawn_object.
Module SM := ssl_area1_macro.
Module SSL := ssl_script.

Fixpoint pointer_members_to_struct_in_members
    (target_struct : ident) (members : members) : list ident :=
  match members with
  | [] => []
  | Member_plain member_name
      (Tpointer (Tstruct found_struct _) _) :: rest =>
      if Pos.eqb found_struct target_struct then
        member_name :: pointer_members_to_struct_in_members target_struct rest
      else
        pointer_members_to_struct_in_members target_struct rest
  | _ :: rest =>
      pointer_members_to_struct_in_members target_struct rest
  end.

Fixpoint pointer_array_members_to_struct_in_members
    (target_struct : ident) (members : members) : list ident :=
  match members with
  | [] => []
  | Member_plain member_name
      (Tarray (Tpointer (Tstruct found_struct _) _) _ _) :: rest =>
      if Pos.eqb found_struct target_struct then
        member_name :: pointer_array_members_to_struct_in_members
          target_struct rest
      else
        pointer_array_members_to_struct_in_members target_struct rest
  | _ :: rest =>
      pointer_array_members_to_struct_in_members target_struct rest
  end.

Fixpoint composite_members
    (composite_id : ident) (defs : list composite_definition) : members :=
  match defs with
  | [] => []
  | Composite found_id _ members _ :: rest =>
      if Pos.eqb found_id composite_id then
        members
      else
        composite_members composite_id rest
  end.

Definition pointer_members_to_struct
    (defs : list composite_definition)
    (composite_id target_struct : ident) : list ident :=
  pointer_members_to_struct_in_members target_struct
    (composite_members composite_id defs).

Definition pointer_array_members_to_struct
    (defs : list composite_definition)
    (composite_id target_struct : ident) : list ident :=
  pointer_array_members_to_struct_in_members target_struct
    (composite_members composite_id defs).

Fixpoint expression_mentions_field (field : ident) (e : expr) : bool :=
  match e with
  | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _
  | Ecast inner _ =>
      expression_mentions_field field inner
  | Ebinop _ lhs rhs _ =>
      expression_mentions_field field lhs ||
      expression_mentions_field field rhs
  | Efield inner found _ =>
      Pos.eqb found field || expression_mentions_field field inner
  | _ => false
  end.

Fixpoint assigns_mentioned_field_s
    (field : ident) (s : statement) : bool :=
  match s with
  | Sassign lhs _ => expression_mentions_field field lhs
  | Ssequence s1 s2 =>
      assigns_mentioned_field_s field s1 ||
      assigns_mentioned_field_s field s2
  | Sifthenelse _ s1 s2 =>
      assigns_mentioned_field_s field s1 ||
      assigns_mentioned_field_s field s2
  | Sloop s1 s2 =>
      assigns_mentioned_field_s field s1 ||
      assigns_mentioned_field_s field s2
  | Slabel _ body => assigns_mentioned_field_s field body
  | Sswitch _ cases => assigns_mentioned_field_ls field cases
  | _ => false
  end
with assigns_mentioned_field_ls
       (field : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_mentioned_field_s field body ||
      assigns_mentioned_field_ls field rest
  end.

Definition mentioned_field_writers
    (program : Clight.program) (field : ident) : list ident :=
  map fst
    (filter
      (fun named_function =>
         assigns_mentioned_field_s field (fn_body (snd named_function)))
      (internal_functions (prog_defs program))).

Theorem object_owned_scalar_object_reference_fields :
  pointer_members_to_struct S.composites S._Object S._Object =
  [S._parentObj; S._prevObj; S._platform].
Proof. vm_compute; reflexivity. Qed.

Theorem object_owned_array_object_reference_fields :
  pointer_array_members_to_struct S.composites S._Object S._Object =
  [S._collidedObjs].
Proof. vm_compute; reflexivity. Qed.

Theorem object_raw_data_object_reference_array_fields :
  pointer_array_members_to_struct S.composites S.__764 S._Object =
  [S._asObject].
Proof. vm_compute; reflexivity. Qed.

Theorem object_node_list_reference_fields :
  pointer_members_to_struct S.composites S._ObjectNode S._ObjectNode =
  [S._next; S._prev].
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_reference_fields :
  pointer_members_to_struct G.composites G._GraphNode G._GraphNode =
  [G._prev; G._next; G._parent; G._children].
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_object_shared_child_reference_fields :
  pointer_members_to_struct G.composites G._GraphNodeObject G._GraphNode =
  [G._sharedChild].
Proof. vm_compute; reflexivity. Qed.

Theorem graph_node_held_object_reference_fields :
  pointer_members_to_struct G.composites G._GraphNodeHeldObject G._Object =
  [G._objNode].
Proof. vm_compute; reflexivity. Qed.

Theorem spawn_object_owned_reference_writers :
  direct_field_writers S.prog S._parentObj =
    [S._allocate_object] /\
  direct_field_writers S.prog S._prevObj =
    [S._unload_object; S._allocate_object].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem spawn_object_node_link_writers :
  direct_field_writers S.prog S._prev =
    [S._unused_init_free_list; S._unused_try_allocate;
     S._try_allocate_object; S._unused_deallocate; S._deallocate_object;
     S._clear_object_lists] /\
  direct_field_writers S.prog S._next =
    [S._unused_init_free_list; S._unused_try_allocate;
     S._try_allocate_object; S._unused_deallocate; S._deallocate_object;
     S._init_free_object_list; S._clear_object_lists].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem object_helpers_owned_reference_writers :
  direct_field_writers H.prog H._parentObj =
    [H._obj_set_held_state; H._spawn_object_at_origin] /\
  direct_field_writers H.prog H._prevObj = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem object_list_processor_has_no_owned_reference_writers :
  direct_field_writers O.prog O._parentObj = [] /\
  direct_field_writers O.prog O._prevObj = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem obj_behaviors_owned_reference_writers :
  direct_field_writers OB.prog OB._parentObj =
    [OB._spawn_manta_ray_ring_manager; OB._bhv_snowmans_bottom_init;
     OB._bhv_red_coin_init; OB._bhv_manta_ray_init] /\
  direct_field_writers OB.prog OB._prevObj = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem behavior_actions_owned_reference_writers :
  direct_field_writers B.prog B._parentObj =
    [B._beta_boo_key_drop] /\
  direct_field_writers B.prog B._prevObj =
    [B._bhv_flame_mario_loop; B._tuxies_mother_act_2;
     B._tuxies_mother_act_0].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem object_owned_platform_writers :
  mentioned_field_writers A.prog A._platform = [] /\
  mentioned_field_writers AU.prog AU._platform = [] /\
  mentioned_field_writers B.prog B._platform =
    [B._bowser_free_update] /\
  mentioned_field_writers G.prog G._platform = [] /\
  mentioned_field_writers I.prog I._platform = [] /\
  mentioned_field_writers LS.prog LS._platform = [] /\
  mentioned_field_writers L.prog L._platform = [] /\
  mentioned_field_writers P.prog P._platform = [] /\
  mentioned_field_writers MM.prog MM._platform = [] /\
  mentioned_field_writers M.prog M._platform = [] /\
  mentioned_field_writers OB.prog OB._platform = [] /\
  mentioned_field_writers H.prog H._platform = [] /\
  mentioned_field_writers O.prog O._platform = [] /\
  mentioned_field_writers S.prog S._platform =
    [S._allocate_object].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem object_owned_collided_object_array_writers :
  mentioned_field_writers A.prog A._collidedObjs = [] /\
  mentioned_field_writers AU.prog AU._collidedObjs = [] /\
  mentioned_field_writers B.prog B._collidedObjs = [] /\
  mentioned_field_writers G.prog G._collidedObjs = [] /\
  mentioned_field_writers I.prog I._collidedObjs = [] /\
  mentioned_field_writers LS.prog LS._collidedObjs = [] /\
  mentioned_field_writers L.prog L._collidedObjs = [] /\
  mentioned_field_writers P.prog P._collidedObjs = [] /\
  mentioned_field_writers MM.prog MM._collidedObjs = [] /\
  mentioned_field_writers M.prog M._collidedObjs = [] /\
  mentioned_field_writers OB.prog OB._collidedObjs = [] /\
  mentioned_field_writers H.prog H._collidedObjs = [] /\
  mentioned_field_writers O.prog O._collidedObjs = [] /\
  mentioned_field_writers S.prog S._collidedObjs = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem object_owned_raw_behavior_object_slot_writers :
  mentioned_field_writers A.prog A._asObject = [] /\
  mentioned_field_writers AU.prog AU._asObject = [] /\
  mentioned_field_writers B.prog B._asObject =
    [B._breakable_box_init; B._hidden_breakable_box_actions;
     B._hidden_wdw_platform_actions; B._falling_bowser_plat_act_start;
     B._bhv_flame_bouncing_loop; B._bhv_jrb_sliding_box_loop;
     B._bhv_hidden_blue_coin_loop; B._bhv_openable_grill_loop;
     B._boo_act_0; B._big_boo_act_0; B._boo_with_cage_act_0;
     B._bhv_strong_wind_particle_loop] /\
  mentioned_field_writers G.prog G._asObject = [] /\
  mentioned_field_writers I.prog I._asObject = [] /\
  mentioned_field_writers LS.prog LS._asObject = [] /\
  mentioned_field_writers L.prog L._asObject = [] /\
  mentioned_field_writers P.prog P._asObject = [] /\
  mentioned_field_writers MM.prog MM._asObject = [] /\
  mentioned_field_writers M.prog M._asObject = [] /\
  mentioned_field_writers OB.prog OB._asObject = [] /\
  mentioned_field_writers H.prog H._asObject = [] /\
  mentioned_field_writers O.prog O._asObject = [] /\
  mentioned_field_writers S.prog S._asObject = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem transition_side_modules_have_no_owned_reference_writers :
  direct_field_writers A.prog A._parentObj = [] /\
  direct_field_writers A.prog A._prevObj = [] /\
  direct_field_writers L.prog L._parentObj = [] /\
  direct_field_writers L.prog L._prevObj = [] /\
  direct_field_writers M.prog M._parentObj = [] /\
  direct_field_writers M.prog M._prevObj = [] /\
  direct_field_writers I.prog I._parentObj = [] /\
  direct_field_writers I.prog I._prevObj = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem graph_node_tree_link_writers :
  direct_field_writers G.prog G._parent =
    [G._init_scene_graph_node_links; G._geo_add_child] /\
  direct_field_writers G.prog G._children =
    [G._init_scene_graph_node_links; G._geo_add_child] /\
  direct_field_writers G.prog G._prev =
    [G._init_scene_graph_node_links; G._geo_add_child;
     G._geo_remove_child; G._geo_make_first_child] /\
  direct_field_writers G.prog G._next =
    [G._init_scene_graph_node_links; G._geo_add_child;
     G._geo_remove_child; G._geo_make_first_child].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem graph_node_shared_child_writers :
  direct_field_writers G.prog G._sharedChild =
    [G._init_graph_node_object; G._init_graph_node_object_parent;
     G._geo_obj_init; G._geo_obj_init_spawninfo] /\
  direct_field_writers H.prog H._sharedChild =
    [H._cur_obj_set_model] /\
  direct_field_writers S.prog S._sharedChild = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem graph_node_held_object_objnode_writers :
  direct_field_writers G.prog G._objNode =
    [G._init_graph_node_held_object] /\
  direct_field_writers MM.prog MM._objNode =
    [MM._geo_switch_mario_hand_grab_pos] /\
  direct_field_writers H.prog H._objNode = [] /\
  direct_field_writers B.prog B._objNode = [] /\
  direct_field_writers OB.prog OB._objNode = [].
Proof. repeat split; vm_compute; reflexivity. Qed.

Theorem init_graph_node_held_object_stores_objnode_parameter :
  event_subsequenceb
    [Event_assign_field_from_temp G._objNode G._objNode]
    (statement_events_s
      (fn_body G.f_init_graph_node_held_object)) = true.
Proof. vm_compute; reflexivity. Qed.

Theorem mario_misc_render_held_object_refreshes_from_mario_heldObj :
  event_subsequenceb
    [Event_assign_field_null MM._objNode;
     Event_set_temp_from_field MM._t'4 MM._marioState MM._heldObj;
     Event_set_temp_from_field MM._t'8 MM._marioState MM._heldObj;
     Event_assign_field_from_temp MM._objNode MM._t'8]
    (statement_events_s
      (fn_body MM.f_geo_switch_mario_hand_grab_pos)) = true.
Proof. vm_compute; reflexivity. Qed.
