(** Source and memory boundary for post-copy Object-receiver aliases.

    This module deliberately distinguishes three facts which are easy to
    overstate:

    - exactly nine generated internal functions store raw Object XYZ through
      a declared Object-pointer formal;
    - eight use argument zero as that receiver, while
      [obj_update_pos_from_parent_transformation] uses argument one; and
    - a store through a valid, distinct object-pool slot cannot change a raw
      coordinate in Mario's slot.

    The nine functions are direct-store sites, not a transitive API closure.
    In particular [obj_copy_pos_and_angle] forwards its first argument to
    [obj_copy_pos].  The concrete intra-Mario post-copy particle and debug
    spawn chains are audited below because [gCurrentObject] still denotes
    Mario during that tail.  Both chains pass the allocation result, not the
    parent/current pointer, as the destination of the copy wrapper.  Turning
    that source shape into preservation still requires allocator freshness
    and slot-lifetime premises.

    Only after the PLAYER traversal advances may a linked execution use the
    later-current-node premise.  For those callbacks this file retains, rather
    than assumes, the obligation that every explicit receiver (current node,
    child, prevObj, or another pointer) denotes a valid slot distinct from
    Mario.  Indirect calls, external effects, receiver forwarding outside the
    two audited spawn chains, pointer fabrication, list corruption, slot
    reuse, and abnormal scheduler control remain named residuals. *)

From Coq Require Import Bool Lia List ZArith.
From compcert Require Import AST Clight Ctypes Integers Memory Values.
From LessThanOneAPress.Generated Require Import
  us_debug us_mario us_obj_behaviors us_object_helpers
  us_object_list_processor us_spawn_object
  jp_debug jp_mario jp_obj_behaviors jp_object_helpers
  jp_object_list_processor jp_spawn_object.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1PostCopyObjectWriterClosure Area1PostPlayerTailSource
  Area1PrecollisionWriterClosure ClightRefinement EntryMemory
  OrdinaryArea1EntryMemory.

Import ListNotations.
Local Open Scope Z_scope.

Module A1PCAC_USDebug := us_debug.
Module A1PCAC_USMario := us_mario.
Module A1PCAC_USBehaviors := us_obj_behaviors.
Module A1PCAC_USHelpers := us_object_helpers.
Module A1PCAC_USObjects := us_object_list_processor.
Module A1PCAC_USSpawn := us_spawn_object.
Module A1PCAC_JPDebug := jp_debug.
Module A1PCAC_JPMario := jp_mario.
Module A1PCAC_JPBehaviors := jp_obj_behaviors.
Module A1PCAC_JPHelpers := jp_object_helpers.
Module A1PCAC_JPObjects := jp_object_list_processor.
Module A1PCAC_JPSpawn := jp_spawn_object.

(** * Exact direct-store formal-receiver census *)

Definition function_has_formal_raw_xyz_receiver
    (object_tag raw_data as_f32 : ident)
    (function_value : Clight.function) : bool :=
  existsb
    (fun receiver =>
      existsb (fun formal => Pos.eqb receiver (fst formal))
        (fn_params function_value))
    (raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32
      (fn_body function_value)).

Definition formal_raw_xyz_writer_sites
    (object_tag raw_data as_f32 : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function_value) =>
            function_has_formal_raw_xyz_receiver
              object_tag raw_data as_f32 function_value
        | _ => false
        end)
      definitions).

Definition formal_raw_xyz_writer_sites_in_program
    (object_tag raw_data as_f32 : ident)
    (program : Clight.program) : list ident :=
  formal_raw_xyz_writer_sites object_tag raw_data as_f32 (prog_defs program).

Definition us_formal_raw_xyz_writer_partition : list (list ident) :=
  map
    (formal_raw_xyz_writer_sites_in_program
      A1PCAC_USObjects._Object A1PCAC_USObjects._rawData
      A1PCAC_USObjects._asF32)
    us_translation_units.

Definition jp_formal_raw_xyz_writer_partition : list (list ident) :=
  map
    (formal_raw_xyz_writer_sites_in_program
      A1PCAC_JPObjects._Object A1PCAC_JPObjects._rawData
      A1PCAC_JPObjects._asF32)
    jp_translation_units.

Definition us_expected_formal_raw_xyz_writer_partition : list (list ident) :=
  [[]; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; [];
   [A1PCAC_USSpawn._snap_object_to_floor];
   [A1PCAC_USHelpers._obj_update_pos_from_parent_transformation;
    A1PCAC_USHelpers._obj_set_pos;
    A1PCAC_USHelpers._obj_copy_pos;
    A1PCAC_USHelpers._obj_set_pos_relative;
    A1PCAC_USHelpers._obj_build_transform_relative_to_parent;
    A1PCAC_USHelpers._obj_translate_xyz_random;
    A1PCAC_USHelpers._obj_translate_xz_random];
   []; []; [];
   [A1PCAC_USBehaviors._obj_move_xyz_using_fvel_and_yaw];
   []; []; []; []; []; []; []; []; []; []; []; []; []; []].

Definition jp_expected_formal_raw_xyz_writer_partition : list (list ident) :=
  [[]; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; []; [];
   [A1PCAC_JPSpawn._snap_object_to_floor];
   [A1PCAC_JPHelpers._obj_update_pos_from_parent_transformation;
    A1PCAC_JPHelpers._obj_set_pos;
    A1PCAC_JPHelpers._obj_copy_pos;
    A1PCAC_JPHelpers._obj_set_pos_relative;
    A1PCAC_JPHelpers._obj_build_transform_relative_to_parent;
    A1PCAC_JPHelpers._obj_translate_xyz_random;
    A1PCAC_JPHelpers._obj_translate_xz_random];
   []; []; [];
   [A1PCAC_JPBehaviors._obj_move_xyz_using_fvel_and_yaw];
   []; []; []; []; []; []; []; []; []; []; []; []; []; []].

Ltac solve_formal_writer_partition :=
  unfold us_formal_raw_xyz_writer_partition,
    jp_formal_raw_xyz_writer_partition,
    us_expected_formal_raw_xyz_writer_partition,
    jp_expected_formal_raw_xyz_writer_partition,
    us_translation_units, jp_translation_units;
  cbn [map];
  repeat match goal with
  | |- @eq (list _) (_ :: _) (_ :: _) =>
      apply f_equal2; [vm_compute; reflexivity |]
  end;
  reflexivity.

Theorem us_formal_raw_xyz_writer_partition_checked :
  us_formal_raw_xyz_writer_partition =
    us_expected_formal_raw_xyz_writer_partition.
Proof. solve_formal_writer_partition. Qed.

Theorem jp_formal_raw_xyz_writer_partition_checked :
  jp_formal_raw_xyz_writer_partition =
    jp_expected_formal_raw_xyz_writer_partition.
Proof. solve_formal_writer_partition. Qed.

Definition us_formal_raw_xyz_direct_store_writers : list ident :=
  concat us_formal_raw_xyz_writer_partition.

Definition jp_formal_raw_xyz_direct_store_writers : list ident :=
  concat jp_formal_raw_xyz_writer_partition.

Definition us_expected_formal_raw_xyz_direct_store_writers : list ident :=
  [A1PCAC_USSpawn._snap_object_to_floor;
   A1PCAC_USHelpers._obj_update_pos_from_parent_transformation;
   A1PCAC_USHelpers._obj_set_pos;
   A1PCAC_USHelpers._obj_copy_pos;
   A1PCAC_USHelpers._obj_set_pos_relative;
   A1PCAC_USHelpers._obj_build_transform_relative_to_parent;
   A1PCAC_USHelpers._obj_translate_xyz_random;
   A1PCAC_USHelpers._obj_translate_xz_random;
   A1PCAC_USBehaviors._obj_move_xyz_using_fvel_and_yaw].

Definition jp_expected_formal_raw_xyz_direct_store_writers : list ident :=
  [A1PCAC_JPSpawn._snap_object_to_floor;
   A1PCAC_JPHelpers._obj_update_pos_from_parent_transformation;
   A1PCAC_JPHelpers._obj_set_pos;
   A1PCAC_JPHelpers._obj_copy_pos;
   A1PCAC_JPHelpers._obj_set_pos_relative;
   A1PCAC_JPHelpers._obj_build_transform_relative_to_parent;
   A1PCAC_JPHelpers._obj_translate_xyz_random;
   A1PCAC_JPHelpers._obj_translate_xz_random;
   A1PCAC_JPBehaviors._obj_move_xyz_using_fvel_and_yaw].

Theorem bilateral_formal_raw_xyz_direct_store_writer_census_checked :
  us_formal_raw_xyz_direct_store_writers =
    us_expected_formal_raw_xyz_direct_store_writers /\
  jp_formal_raw_xyz_direct_store_writers =
    jp_expected_formal_raw_xyz_direct_store_writers.
Proof.
  unfold us_formal_raw_xyz_direct_store_writers,
    jp_formal_raw_xyz_direct_store_writers.
  rewrite us_formal_raw_xyz_writer_partition_checked,
    jp_formal_raw_xyz_writer_partition_checked.
  split; reflexivity.
Qed.

(** A direct-store ABI is [(function, receiver argument index)].  All but
    [obj_update_pos_from_parent_transformation] use the first argument. *)
Definition us_formal_raw_xyz_direct_store_abis : list (ident * nat) :=
  [(A1PCAC_USSpawn._snap_object_to_floor, 0%nat);
   (A1PCAC_USHelpers._obj_update_pos_from_parent_transformation, 1%nat);
   (A1PCAC_USHelpers._obj_set_pos, 0%nat);
   (A1PCAC_USHelpers._obj_copy_pos, 0%nat);
   (A1PCAC_USHelpers._obj_set_pos_relative, 0%nat);
   (A1PCAC_USHelpers._obj_build_transform_relative_to_parent, 0%nat);
   (A1PCAC_USHelpers._obj_translate_xyz_random, 0%nat);
   (A1PCAC_USHelpers._obj_translate_xz_random, 0%nat);
   (A1PCAC_USBehaviors._obj_move_xyz_using_fvel_and_yaw, 0%nat)].

Definition jp_formal_raw_xyz_direct_store_abis : list (ident * nat) :=
  [(A1PCAC_JPSpawn._snap_object_to_floor, 0%nat);
   (A1PCAC_JPHelpers._obj_update_pos_from_parent_transformation, 1%nat);
   (A1PCAC_JPHelpers._obj_set_pos, 0%nat);
   (A1PCAC_JPHelpers._obj_copy_pos, 0%nat);
   (A1PCAC_JPHelpers._obj_set_pos_relative, 0%nat);
   (A1PCAC_JPHelpers._obj_build_transform_relative_to_parent, 0%nat);
   (A1PCAC_JPHelpers._obj_translate_xyz_random, 0%nat);
   (A1PCAC_JPHelpers._obj_translate_xz_random, 0%nat);
   (A1PCAC_JPBehaviors._obj_move_xyz_using_fvel_and_yaw, 0%nat)].

Definition raw_xyz_receivers_are_parameter_at
    (object_tag raw_data as_f32 : ident) (index : nat)
    (function_value : Clight.function) : bool :=
  match nth_error (map fst (fn_params function_value)) index with
  | None => false
  | Some receiver =>
      match raw_xyz_receiver_temp_sites_s object_tag raw_data as_f32
              (fn_body function_value) with
      | [] => false
      | receivers => forallb (Pos.eqb receiver) receivers
      end
  end.

Definition formal_raw_xyz_direct_store_abi_shape_claim : Prop :=
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USSpawn._Object A1PCAC_USSpawn._rawData A1PCAC_USSpawn._asF32
    0 A1PCAC_USSpawn.f_snap_object_to_floor = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 1
    A1PCAC_USHelpers.f_obj_update_pos_from_parent_transformation = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0 A1PCAC_USHelpers.f_obj_set_pos = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0 A1PCAC_USHelpers.f_obj_copy_pos = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0 A1PCAC_USHelpers.f_obj_set_pos_relative = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0
    A1PCAC_USHelpers.f_obj_build_transform_relative_to_parent = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0
    A1PCAC_USHelpers.f_obj_translate_xyz_random = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USHelpers._Object A1PCAC_USHelpers._rawData
    A1PCAC_USHelpers._asF32 0
    A1PCAC_USHelpers.f_obj_translate_xz_random = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_USBehaviors._Object A1PCAC_USBehaviors._rawData
    A1PCAC_USBehaviors._asF32 0
    A1PCAC_USBehaviors.f_obj_move_xyz_using_fvel_and_yaw = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPSpawn._Object A1PCAC_JPSpawn._rawData A1PCAC_JPSpawn._asF32
    0 A1PCAC_JPSpawn.f_snap_object_to_floor = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 1
    A1PCAC_JPHelpers.f_obj_update_pos_from_parent_transformation = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0 A1PCAC_JPHelpers.f_obj_set_pos = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0 A1PCAC_JPHelpers.f_obj_copy_pos = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0 A1PCAC_JPHelpers.f_obj_set_pos_relative = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0
    A1PCAC_JPHelpers.f_obj_build_transform_relative_to_parent = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0
    A1PCAC_JPHelpers.f_obj_translate_xyz_random = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPHelpers._Object A1PCAC_JPHelpers._rawData
    A1PCAC_JPHelpers._asF32 0
    A1PCAC_JPHelpers.f_obj_translate_xz_random = true /\
  raw_xyz_receivers_are_parameter_at
    A1PCAC_JPBehaviors._Object A1PCAC_JPBehaviors._rawData
    A1PCAC_JPBehaviors._asF32 0
    A1PCAC_JPBehaviors.f_obj_move_xyz_using_fvel_and_yaw = true.

Theorem formal_raw_xyz_direct_store_abi_shape_checked :
  formal_raw_xyz_direct_store_abi_shape_claim.
Proof.
  unfold formal_raw_xyz_direct_store_abi_shape_claim,
    raw_xyz_receivers_are_parameter_at.
  vm_compute; tauto.
Qed.

(** * One-hop receiver-origin census for the nine direct-store ABIs *)

Fixpoint receiver_argument_index
    (callee : ident) (abis : list (ident * nat)) : option nat :=
  match abis with
  | [] => None
  | (candidate, index) :: rest =>
      if Pos.eqb callee candidate
      then Some index
      else receiver_argument_index callee rest
  end.

Definition direct_call_receiver_expression
    (abis : list (ident * nat)) (s : statement) : option expr :=
  match s with
  | Scall _ (Evar callee _) arguments =>
      match receiver_argument_index callee abis with
      | Some index => nth_error arguments index
      | None => None
      end
  | _ => None
  end.

Fixpoint direct_store_receiver_expressions_s
    (abis : list (ident * nat)) (s : statement) : list expr :=
  match direct_call_receiver_expression abis s with
  | Some receiver => [receiver]
  | None =>
      match s with
      | Ssequence first second | Sloop first second =>
          direct_store_receiver_expressions_s abis first ++
          direct_store_receiver_expressions_s abis second
      | Sifthenelse _ yes no =>
          direct_store_receiver_expressions_s abis yes ++
          direct_store_receiver_expressions_s abis no
      | Sswitch _ cases => direct_store_receiver_expressions_ls abis cases
      | Slabel _ body => direct_store_receiver_expressions_s abis body
      | _ => []
      end
  end
with direct_store_receiver_expressions_ls
    (abis : list (ident * nat))
    (cases : labeled_statements) : list expr :=
  match cases with
  | LSnil => []
  | LScons _ body rest =>
      direct_store_receiver_expressions_s abis body ++
      direct_store_receiver_expressions_ls abis rest
  end.

Definition receiver_temp_identifiers (receivers : list expr) : list ident :=
  fold_right
    (fun receiver collected =>
      match receiver with
      | Etempvar temporary _ => temporary :: collected
      | _ => collected
      end)
    [] receivers.

(** Conservative one-hop test inside one generated function.  A site is
    selected when its receiver expression itself has [origin], or when the
    same generated temporary is somewhere loaded from [origin] and passed in
    the ABI's receiver position.  Reuse of a temporary may add false
    positives.  Copies through another temporary, heap fields, indirect
    calls, and aliases already present in memory are not followed. *)
Definition function_has_one_hop_direct_store_receiver_origin
    (origin : expr -> bool) (abis : list (ident * nat))
    (function_value : Clight.function) : bool :=
  let receivers :=
    direct_store_receiver_expressions_s abis (fn_body function_value) in
  match receivers with
  | [] => false
  | _ =>
      existsb origin receivers ||
      ident_lists_intersectb
        (temp_rhs_match_sites_s origin (fn_body function_value))
        (receiver_temp_identifiers receivers)
  end.

Definition one_hop_direct_store_receiver_origin_sites
    (origin : expr -> bool) (abis : list (ident * nat))
    (definitions : list (ident * globdef Clight.fundef type)) : list ident :=
  map fst
    (filter
      (fun entry =>
        match snd entry with
        | Gfun (Internal function_value) =>
            function_has_one_hop_direct_store_receiver_origin
              origin abis function_value
        | _ => false
        end)
      definitions).

Definition one_hop_direct_store_receiver_origin_sites_in_program
    (origin : expr -> bool) (abis : list (ident * nat))
    (program : Clight.program) : list ident :=
  one_hop_direct_store_receiver_origin_sites origin abis (prog_defs program).

Definition expression_mentions_object_pointer_global
    (object_tag : ident) (expression : expr) : bool :=
  let fix visit (current : expr) : bool :=
    match current with
    | Evar _ (Tpointer (Tstruct found_object _) _) =>
        Pos.eqb found_object object_tag
    | Ederef inner _ | Eaddrof inner _ | Eunop _ inner _ | Ecast inner _
    | Efield inner _ _ => visit inner
    | Ebinop _ left_expression right_expression _ =>
        visit left_expression || visit right_expression
    | _ => false
    end
  in visit expression.

Definition expression_mentions_other_object_pointer_global
    (object_tag current_object mario_object : ident)
    (expression : expr) : bool :=
  expression_mentions_object_pointer_global object_tag expression &&
  negb (expression_mentions_ident current_object expression) &&
  negb (expression_mentions_ident mario_object expression).

Definition us_designated_mario_one_hop_receiver_partition : list (list ident) :=
  map
    (one_hop_direct_store_receiver_origin_sites_in_program
      (expression_mentions_designated_mario_object_origin
        A1PCAC_USMario._gMarioObject A1PCAC_USMario._marioObj)
      us_formal_raw_xyz_direct_store_abis)
    us_translation_units.

Definition jp_designated_mario_one_hop_receiver_partition : list (list ident) :=
  map
    (one_hop_direct_store_receiver_origin_sites_in_program
      (expression_mentions_designated_mario_object_origin
        A1PCAC_JPMario._gMarioObject A1PCAC_JPMario._marioObj)
      jp_formal_raw_xyz_direct_store_abis)
    jp_translation_units.

(** These two lists are intentionally exported as residual inventories.
    [gCurrentObject] is Mario during the intra-Mario tail, but a later list
    node after the traversal advance under the linked scheduler premise.
    Other Object-pointer globals include potential aliases such as platform or
    focus pointers; source syntax alone does not prove their runtime value. *)
Definition us_current_object_one_hop_receiver_sites : list ident :=
  concat
    (map
      (one_hop_direct_store_receiver_origin_sites_in_program
        (expression_mentions_ident A1PCAC_USObjects._gCurrentObject)
        us_formal_raw_xyz_direct_store_abis)
      us_translation_units).

Definition jp_current_object_one_hop_receiver_sites : list ident :=
  concat
    (map
      (one_hop_direct_store_receiver_origin_sites_in_program
        (expression_mentions_ident A1PCAC_JPObjects._gCurrentObject)
        jp_formal_raw_xyz_direct_store_abis)
      jp_translation_units).

Definition us_other_global_one_hop_receiver_sites : list ident :=
  concat
    (map
      (one_hop_direct_store_receiver_origin_sites_in_program
        (expression_mentions_other_object_pointer_global
          A1PCAC_USObjects._Object A1PCAC_USObjects._gCurrentObject
          A1PCAC_USMario._gMarioObject)
        us_formal_raw_xyz_direct_store_abis)
      us_translation_units).

Definition jp_other_global_one_hop_receiver_sites : list ident :=
  concat
    (map
      (one_hop_direct_store_receiver_origin_sites_in_program
        (expression_mentions_other_object_pointer_global
          A1PCAC_JPObjects._Object A1PCAC_JPObjects._gCurrentObject
          A1PCAC_JPMario._gMarioObject)
        jp_formal_raw_xyz_direct_store_abis)
      jp_translation_units).

Definition empty_formal_receiver_origin_partition : list (list ident) :=
  map (fun _ : Clight.program => []) us_translation_units.

Ltac solve_empty_designated_receiver_partition :=
  unfold us_designated_mario_one_hop_receiver_partition,
    jp_designated_mario_one_hop_receiver_partition,
    empty_formal_receiver_origin_partition,
    us_formal_raw_xyz_direct_store_abis,
    jp_formal_raw_xyz_direct_store_abis,
    us_translation_units, jp_translation_units;
  cbn [map];
  repeat match goal with
  | |- @eq (list _) (_ :: _) (_ :: _) =>
      apply f_equal2; [vm_compute; reflexivity |]
  end;
  reflexivity.

(** No generated direct call to one of the nine direct-store functions passes
    a one-hop [gMarioObject] or [MarioState.marioObj] receiver.  This theorem
    does not cover a wrapper such as [obj_copy_pos_and_angle], a second pointer
    copy, an indirect call, or an alias pre-existing in memory. *)
Theorem bilateral_no_designated_mario_one_hop_direct_store_receiver :
  us_designated_mario_one_hop_receiver_partition =
    empty_formal_receiver_origin_partition /\
  jp_designated_mario_one_hop_receiver_partition =
    empty_formal_receiver_origin_partition.
Proof.
  split; solve_empty_designated_receiver_partition.
Qed.

(** * Intra-Mario post-copy child destinations *)

(** Match the coupled fragment used by [spawn_particle]: obtain a child from
    [allocator], copy the result into a named child temporary, then pass that
    child as destination and [gCurrentObject] as source to [copier]. *)
Definition is_current_parent_spawn_then_child_copy_s
    (current allocator copier : ident) (s : statement) : bool :=
  match s with
  | Ssequence
      (Ssequence
        (Ssequence
          (Sset parent (Evar found_current _))
          (Scall (Some result) (Evar found_allocator _)
            (Etempvar found_parent _ :: _)))
        (Sset child (Etempvar found_result _)))
      (Ssequence
        (Sset source (Evar found_source_global _))
        (Scall _ (Evar found_copier _)
          [Etempvar found_child _; Etempvar found_source _])) =>
      Pos.eqb found_current current &&
      Pos.eqb found_source_global current &&
      Pos.eqb found_allocator allocator &&
      Pos.eqb found_copier copier &&
      Pos.eqb parent found_parent &&
      Pos.eqb result found_result &&
      Pos.eqb child found_child &&
      Pos.eqb source found_source
  | _ => false
  end.

Fixpoint contains_current_parent_spawn_then_child_copy_s
    (current allocator copier : ident) (s : statement) : bool :=
  is_current_parent_spawn_then_child_copy_s current allocator copier s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier first ||
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier second
  | Sifthenelse _ yes no =>
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier yes ||
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier no
  | Sswitch _ cases =>
      contains_current_parent_spawn_then_child_copy_ls
        current allocator copier cases
  | Slabel _ body =>
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier body
  | _ => false
  end
with contains_current_parent_spawn_then_child_copy_ls
    (current allocator copier : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_current_parent_spawn_then_child_copy_s
        current allocator copier body ||
      contains_current_parent_spawn_then_child_copy_ls
        current allocator copier rest
  end.

(** [spawn_object_relative] has a slightly simpler shape because the parent is
    already a formal.  Again the allocation result is the copy destination. *)
Definition is_parent_formal_spawn_then_child_copy_s
    (allocator copier : ident) (s : statement) : bool :=
  match s with
  | Ssequence
      (Ssequence
        (Scall (Some result) (Evar found_allocator _)
          (Etempvar parent _ :: _))
        (Sset child (Etempvar found_result _)))
      (Ssequence
        (Scall _ (Evar found_copier _)
          [Etempvar found_child _; Etempvar found_parent _]) _) =>
      Pos.eqb found_allocator allocator &&
      Pos.eqb found_copier copier &&
      Pos.eqb result found_result &&
      Pos.eqb child found_child &&
      Pos.eqb parent found_parent
  | _ => false
  end.

Fixpoint contains_parent_formal_spawn_then_child_copy_s
    (allocator copier : ident) (s : statement) : bool :=
  is_parent_formal_spawn_then_child_copy_s allocator copier s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_parent_formal_spawn_then_child_copy_s allocator copier first ||
      contains_parent_formal_spawn_then_child_copy_s allocator copier second
  | Sifthenelse _ yes no =>
      contains_parent_formal_spawn_then_child_copy_s allocator copier yes ||
      contains_parent_formal_spawn_then_child_copy_s allocator copier no
  | Sswitch _ cases =>
      contains_parent_formal_spawn_then_child_copy_ls allocator copier cases
  | Slabel _ body =>
      contains_parent_formal_spawn_then_child_copy_s allocator copier body
  | _ => false
  end
with contains_parent_formal_spawn_then_child_copy_ls
    (allocator copier : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_parent_formal_spawn_then_child_copy_s allocator copier body ||
      contains_parent_formal_spawn_then_child_copy_ls allocator copier rest
  end.

(** Exact wrapper forwarding: the selected body contains

      callee(first, second)

    with both expressions the named formal temporaries.  This couples the
    destination and source arguments at one call node. *)
Definition is_call_forwarding_two_temps_s
    (callee first second : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _)
      [Etempvar found_first _; Etempvar found_second _] =>
      Pos.eqb found_callee callee &&
      Pos.eqb found_first first &&
      Pos.eqb found_second second
  | _ => false
  end.

Fixpoint contains_call_forwarding_two_temps_s
    (callee first second : ident) (s : statement) : bool :=
  is_call_forwarding_two_temps_s callee first second s ||
  match s with
  | Ssequence first_statement second_statement
  | Sloop first_statement second_statement =>
      contains_call_forwarding_two_temps_s
        callee first second first_statement ||
      contains_call_forwarding_two_temps_s
        callee first second second_statement
  | Sifthenelse _ yes no =>
      contains_call_forwarding_two_temps_s callee first second yes ||
      contains_call_forwarding_two_temps_s callee first second no
  | Sswitch _ cases =>
      contains_call_forwarding_two_temps_ls callee first second cases
  | Slabel _ body =>
      contains_call_forwarding_two_temps_s callee first second body
  | _ => false
  end
with contains_call_forwarding_two_temps_ls
    (callee first second : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_call_forwarding_two_temps_s callee first second body ||
      contains_call_forwarding_two_temps_ls callee first second rest
  end.

(** Match a directly adjacent [temp := global; callee(..., temp, ...)] and
    retain the selected argument position. *)
Definition is_global_temp_then_call_argument_s
    (global callee : ident) (index : nat) (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset temp (Evar found_global _))
      (Scall _ (Evar found_callee _) arguments) =>
      Pos.eqb found_global global &&
      Pos.eqb found_callee callee &&
      match nth_error arguments index with
      | Some (Etempvar found_temp _) => Pos.eqb temp found_temp
      | _ => false
      end
  | _ => false
  end.

Fixpoint count_global_temp_then_call_argument_s
    (global callee : ident) (index : nat) (s : statement) : nat :=
  (if is_global_temp_then_call_argument_s global callee index s
   then 1 else 0)%nat +
  match s with
  | Ssequence first second | Sloop first second =>
      (count_global_temp_then_call_argument_s global callee index first +
       count_global_temp_then_call_argument_s global callee index second)%nat
  | Sifthenelse _ yes no =>
      (count_global_temp_then_call_argument_s global callee index yes +
       count_global_temp_then_call_argument_s global callee index no)%nat
  | Sswitch _ cases =>
      count_global_temp_then_call_argument_ls global callee index cases
  | Slabel _ body =>
      count_global_temp_then_call_argument_s global callee index body
  | _ => 0%nat
  end
with count_global_temp_then_call_argument_ls
    (global callee : ident) (index : nat)
    (cases : labeled_statements) : nat :=
  match cases with
  | LSnil => 0%nat
  | LScons _ body rest =>
      (count_global_temp_then_call_argument_s global callee index body +
       count_global_temp_then_call_argument_ls global callee index rest)%nat
  end.

Definition intra_mario_postcopy_child_destination_source_claim : Prop :=
  (* Mario's native update directly calls no member of the nine-site list. *)
  forallb
    (fun callee =>
      negb (calls_ident_s callee
        (fn_body A1PCAC_USObjects.f_bhv_mario_update)))
    us_expected_formal_raw_xyz_direct_store_writers = true /\
  forallb
    (fun callee =>
      negb (calls_ident_s callee
        (fn_body A1PCAC_JPObjects.f_bhv_mario_update)))
    jp_expected_formal_raw_xyz_direct_store_writers = true /\
  (* Its particle helper sends allocator result to copy destination and keeps
     current/Mario only in the parent/source positions. *)
  contains_current_parent_spawn_then_child_copy_s
    A1PCAC_USObjects._gCurrentObject
    A1PCAC_USObjects._spawn_object_at_origin
    A1PCAC_USObjects._obj_copy_pos_and_angle
    (fn_body A1PCAC_USObjects.f_spawn_particle) = true /\
  contains_current_parent_spawn_then_child_copy_s
    A1PCAC_JPObjects._gCurrentObject
    A1PCAC_JPObjects._spawn_object_at_origin
    A1PCAC_JPObjects._obj_copy_pos_and_angle
    (fn_body A1PCAC_JPObjects.f_spawn_particle) = true /\
  (* The copy wrapper's formals are [dst; src], and the one direct-store call
     forwards exactly [dst; src] in that order. *)
  map fst (fn_params A1PCAC_USHelpers.f_obj_copy_pos_and_angle) =
    [A1PCAC_USHelpers._dst; A1PCAC_USHelpers._src] /\
  contains_call_forwarding_two_temps_s
    A1PCAC_USHelpers._obj_copy_pos
    A1PCAC_USHelpers._dst A1PCAC_USHelpers._src
    (fn_body A1PCAC_USHelpers.f_obj_copy_pos_and_angle) = true /\
  map fst (fn_params A1PCAC_JPHelpers.f_obj_copy_pos_and_angle) =
    [A1PCAC_JPHelpers._dst; A1PCAC_JPHelpers._src] /\
  contains_call_forwarding_two_temps_s
    A1PCAC_JPHelpers._obj_copy_pos
    A1PCAC_JPHelpers._dst A1PCAC_JPHelpers._src
    (fn_body A1PCAC_JPHelpers.f_obj_copy_pos_and_angle) = true /\
  (* The debug callback's three spawn parents are current/Mario, but the spawn
     wrapper again copies into its allocation result. *)
  count_occ Pos.eq_dec
    (direct_callees_s (fn_body A1PCAC_USDebug.f_try_do_mario_debug_object_spawn))
    A1PCAC_USDebug._spawn_object_relative = 3%nat /\
  count_global_temp_then_call_argument_s
    A1PCAC_USDebug._gCurrentObject A1PCAC_USDebug._spawn_object_relative 4
    (fn_body A1PCAC_USDebug.f_try_do_mario_debug_object_spawn) = 3%nat /\
  contains_parent_formal_spawn_then_child_copy_s
    A1PCAC_USHelpers._spawn_object_at_origin
    A1PCAC_USHelpers._obj_copy_pos_and_angle
    (fn_body A1PCAC_USHelpers.f_spawn_object_relative) = true /\
  count_occ Pos.eq_dec
    (direct_callees_s (fn_body A1PCAC_JPDebug.f_try_do_mario_debug_object_spawn))
    A1PCAC_JPDebug._spawn_object_relative = 3%nat /\
  count_global_temp_then_call_argument_s
    A1PCAC_JPDebug._gCurrentObject A1PCAC_JPDebug._spawn_object_relative 4
    (fn_body A1PCAC_JPDebug.f_try_do_mario_debug_object_spawn) = 3%nat /\
  contains_parent_formal_spawn_then_child_copy_s
    A1PCAC_JPHelpers._spawn_object_at_origin
    A1PCAC_JPHelpers._obj_copy_pos_and_angle
    (fn_body A1PCAC_JPHelpers.f_spawn_object_relative) = true.

Theorem intra_mario_postcopy_child_destination_source_checked :
  intra_mario_postcopy_child_destination_source_claim.
Proof.
  unfold intra_mario_postcopy_child_destination_source_claim,
    us_expected_formal_raw_xyz_direct_store_writers,
    jp_expected_formal_raw_xyz_direct_store_writers.
  vm_compute; tauto.
Qed.

(** * Concrete distinct-slot memory frame *)

Definition object_raw_coordinate_offset (component : Z) : Z :=
  mario_object_raw_position_offset + 4 * component.

Lemma object_raw_coordinate_offset_in_bounds :
  forall component,
    0 <= component < 3 ->
    0 <= object_raw_coordinate_offset component /\
    object_raw_coordinate_offset component + 4 <= object_size.
Proof.
  intros component Hcomponent.
  unfold object_raw_coordinate_offset, mario_object_raw_position_offset,
    object_size.
  lia.
Qed.

(** A successful binary32 store to one valid Object slot preserves a raw XYZ
    load in a distinct valid Mario slot.  The validity hypotheses make this a
    defined in-pool statement; it says nothing about out-of-bounds pointer
    arithmetic or a slot that has been freed and reused as Mario's slot. *)
Theorem distinct_object_slot_raw_store_preserves_mario_raw_load :
  forall before after pool_block writer_slot mario_slot
      writer_component mario_component value,
    (writer_slot < object_pool_capacity)%nat ->
    (mario_slot < object_pool_capacity)%nat ->
    writer_slot <> mario_slot ->
    0 <= writer_component < 3 ->
    0 <= mario_component < 3 ->
    Mem.store Mfloat32 before pool_block
      (object_slot_offset writer_slot +
       object_raw_coordinate_offset writer_component) value = Some after ->
    Mem.load Mfloat32 after pool_block
      (object_slot_offset mario_slot +
       object_raw_coordinate_offset mario_component) =
    Mem.load Mfloat32 before pool_block
      (object_slot_offset mario_slot +
       object_raw_coordinate_offset mario_component).
Proof.
  intros before after pool_block writer_slot mario_slot
    writer_component mario_component value
    Hwriter_valid Hmario_valid Hdistinct Hwriter_component Hmario_component
    Hstore.
  pose proof
    (object_raw_coordinate_offset_in_bounds
      writer_component Hwriter_component) as Hwriter_bounds.
  pose proof
    (object_raw_coordinate_offset_in_bounds
      mario_component Hmario_component) as Hmario_bounds.
  pose proof
    (distinct_object_slot_intervals_are_disjoint
      writer_slot mario_slot Hdistinct) as Hintervals.
  eapply Mem.load_store_other; eauto.
  right.
  destruct Hintervals as [Hwriter_before | Hmario_before].
  - right. cbn [size_chunk]. lia.
  - left. cbn [size_chunk]. lia.
Qed.

Corollary valid_changed_mario_raw_load_requires_same_slot :
  forall before after pool_block writer_slot mario_slot
      writer_component mario_component value,
    (writer_slot < object_pool_capacity)%nat ->
    (mario_slot < object_pool_capacity)%nat ->
    0 <= writer_component < 3 ->
    0 <= mario_component < 3 ->
    Mem.store Mfloat32 before pool_block
      (object_slot_offset writer_slot +
       object_raw_coordinate_offset writer_component) value = Some after ->
    Mem.load Mfloat32 after pool_block
      (object_slot_offset mario_slot +
       object_raw_coordinate_offset mario_component) <>
    Mem.load Mfloat32 before pool_block
      (object_slot_offset mario_slot +
       object_raw_coordinate_offset mario_component) ->
    writer_slot = mario_slot.
Proof.
  intros before after pool_block writer_slot mario_slot
    writer_component mario_component value
    Hwriter_valid Hmario_valid Hwriter_component Hmario_component
    Hstore Hchanged.
  destruct (Nat.eq_dec writer_slot mario_slot) as [Hequal | Hdistinct];
    [exact Hequal |].
  exfalso. apply Hchanged.
  exact
    (distinct_object_slot_raw_store_preserves_mario_raw_load
      before after pool_block writer_slot mario_slot
      writer_component mario_component value
      Hwriter_valid Hmario_valid Hdistinct
      Hwriter_component Hmario_component Hstore).
Qed.

(** Audit boundary: exact direct-store names and ABIs plus the two concrete
    intra-Mario child-destination chains.  This conjunction is intentionally
    not a transitive callback-closure theorem. *)
Theorem area1_postcopy_alias_callback_source_boundary_holds :
  us_formal_raw_xyz_direct_store_writers =
    us_expected_formal_raw_xyz_direct_store_writers /\
  jp_formal_raw_xyz_direct_store_writers =
    jp_expected_formal_raw_xyz_direct_store_writers /\
  formal_raw_xyz_direct_store_abi_shape_claim /\
  us_designated_mario_one_hop_receiver_partition =
    empty_formal_receiver_origin_partition /\
  jp_designated_mario_one_hop_receiver_partition =
    empty_formal_receiver_origin_partition /\
  mario_post_copy_intra_player_residual_source_claim /\
  intra_mario_postcopy_child_destination_source_claim.
Proof.
  pose proof bilateral_formal_raw_xyz_direct_store_writer_census_checked
    as Hcensus.
  destruct Hcensus as [Hus Hjp].
  split; [exact Hus |].
  split; [exact Hjp |].
  split; [exact formal_raw_xyz_direct_store_abi_shape_checked |].
  split.
  - exact (proj1 bilateral_no_designated_mario_one_hop_direct_store_receiver).
  - split.
    + exact (proj2 bilateral_no_designated_mario_one_hop_direct_store_receiver).
    + split.
      * exact mario_post_copy_intra_player_residual_source_checked.
      * exact intra_mario_postcopy_child_destination_source_checked.
Qed.
