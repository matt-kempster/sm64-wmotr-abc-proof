From Coq Require Import Bool Lia List PeanoNat PArith.BinPos ZArith.
From compcert Require Import AST Clight Cop Ctypes Integers.
From Pedro.Generated Require Import
  us_object_list_processor us_spawn_object us_behavior_data us_behavior_script
  jp_object_list_processor jp_spawn_object jp_behavior_data jp_behavior_script.
From Pedro.Proofs Require Import ASTFacts GameTypes.

Import ListNotations.

Module UOL := us_object_list_processor.
Module USO := us_spawn_object.
Module UBD := us_behavior_data.
Module UBS := us_behavior_script.

Module JOL := jp_object_list_processor.
Module JSO := jp_spawn_object.
Module JBD := jp_behavior_data.
Module JBS := jp_behavior_script.

(** These small recognizers deliberately retain the identifiers which relate
    the normalized Clight assignments.  They are stronger receipts than mere
    name occurrence checks, while remaining independent of temporary types. *)

Definition is_set_temp_from_field_of_temp
    (destination base field : ident) (s : statement) : bool :=
  match s with
  | Sset found_destination
      (Efield (Ederef (Etempvar found_base _) _) found_field _) =>
      Pos.eqb found_destination destination &&
      Pos.eqb found_base base && Pos.eqb found_field field
  | _ => false
  end.

Fixpoint sets_temp_from_field_of_temp_s
    (destination base field : ident) (s : statement) : bool :=
  is_set_temp_from_field_of_temp destination base field s ||
  match s with
  | Ssequence a b | Sloop a b =>
      sets_temp_from_field_of_temp_s destination base field a ||
      sets_temp_from_field_of_temp_s destination base field b
  | Sifthenelse _ a b =>
      sets_temp_from_field_of_temp_s destination base field a ||
      sets_temp_from_field_of_temp_s destination base field b
  | Slabel _ body => sets_temp_from_field_of_temp_s destination base field body
  | _ => false
  end.

Definition is_assign_field_of_temp_from_temp
    (base field source : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Efield (Ederef (Etempvar found_base _) _) found_field _)
      (Etempvar found_source _) =>
      Pos.eqb found_base base && Pos.eqb found_field field &&
      Pos.eqb found_source source
  | _ => false
  end.

Fixpoint assigns_field_of_temp_from_temp_s
    (base field source : ident) (s : statement) : bool :=
  is_assign_field_of_temp_from_temp base field source s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_field_of_temp_from_temp_s base field source a ||
      assigns_field_of_temp_from_temp_s base field source b
  | Sifthenelse _ a b =>
      assigns_field_of_temp_from_temp_s base field source a ||
      assigns_field_of_temp_from_temp_s base field source b
  | Slabel _ body => assigns_field_of_temp_from_temp_s base field source body
  | _ => false
  end.

Fixpoint statement_has_loop_s (s : statement) : bool :=
  match s with
  | Sloop _ _ => true
  | Ssequence a b | Sifthenelse _ a b =>
      statement_has_loop_s a || statement_has_loop_s b
  | Slabel _ body => statement_has_loop_s body
  | _ => false
  end.

Fixpoint statement_has_busy_loop_s (s : statement) : bool :=
  match s with
  | Sloop Sskip Sskip => true
  | Ssequence a b | Sloop a b | Sifthenelse _ a b =>
      statement_has_busy_loop_s a || statement_has_busy_loop_s b
  | Slabel _ body => statement_has_busy_loop_s body
  | _ => false
  end.

Definition is_set_temp_const
    (destination : ident) (value : Z) (s : statement) : bool :=
  match s with
  | Sset found_destination (Econst_int found_value _) =>
      Pos.eqb found_destination destination &&
      Int.eq found_value (Int.repr value)
  | _ => false
  end.

Fixpoint sets_temp_const_s
    (destination : ident) (value : Z) (s : statement) : bool :=
  is_set_temp_const destination value s ||
  match s with
  | Ssequence a b | Sloop a b =>
      sets_temp_const_s destination value a ||
      sets_temp_const_s destination value b
  | Sifthenelse _ a b =>
      sets_temp_const_s destination value a ||
      sets_temp_const_s destination value b
  | Slabel _ body => sets_temp_const_s destination value body
  | _ => false
  end.

Definition is_global_field_from_temp_assignment
    (global field source : ident) (s : statement) : bool :=
  match s with
  | Sassign (Efield (Evar found_global _) found_field _)
      (Ecast (Etempvar found_source _) _) =>
      Pos.eqb found_global global && Pos.eqb found_field field &&
      Pos.eqb found_source source
  | _ => false
  end.

Fixpoint assigns_global_field_from_temp_s
    (global field source : ident) (s : statement) : bool :=
  is_global_field_from_temp_assignment global field source s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_global_field_from_temp_s global field source a ||
      assigns_global_field_from_temp_s global field source b
  | Sifthenelse _ a b =>
      assigns_global_field_from_temp_s global field source a ||
      assigns_global_field_from_temp_s global field source b
  | Slabel _ body => assigns_global_field_from_temp_s global field source body
  | _ => false
  end.

Definition is_pool_successor_link
    (object header next : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Efield
        (Efield (Ederef (Etempvar found_object _) _) found_header _) found_next _)
      (Eaddrof
        (Efield
          (Ederef
            (Ebinop Oadd (Etempvar found_successor_object _)
              (Econst_int one _) _) _) found_successor_header _) _) =>
      Pos.eqb found_object object && Pos.eqb found_header header &&
      Pos.eqb found_next next &&
      Pos.eqb found_successor_object object &&
      Pos.eqb found_successor_header header && Int.eq one Int.one
  | _ => false
  end.

Fixpoint contains_pool_successor_link_s
    (object header next : ident) (s : statement) : bool :=
  is_pool_successor_link object header next s ||
  match s with
  | Ssequence a b | Sloop a b =>
      contains_pool_successor_link_s object header next a ||
      contains_pool_successor_link_s object header next b
  | Sifthenelse _ a b =>
      contains_pool_successor_link_s object header next a ||
      contains_pool_successor_link_s object header next b
  | Slabel _ body => contains_pool_successor_link_s object header next body
  | _ => false
  end.

Definition is_pool_terminal_null
    (object header next : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Efield
        (Efield (Ederef (Etempvar found_object _) _) found_header _) found_next _)
      (Ecast (Econst_int zero _) _) =>
      Pos.eqb found_object object && Pos.eqb found_header header &&
      Pos.eqb found_next next && Int.eq zero Int.zero
  | _ => false
  end.

Fixpoint contains_pool_terminal_null_s
    (object header next : ident) (s : statement) : bool :=
  is_pool_terminal_null object header next s ||
  match s with
  | Ssequence a b | Sloop a b =>
      contains_pool_terminal_null_s object header next a ||
      contains_pool_terminal_null_s object header next b
  | Sifthenelse _ a b =>
      contains_pool_terminal_null_s object header next a ||
      contains_pool_terminal_null_s object header next b
  | Slabel _ body => contains_pool_terminal_null_s object header next body
  | _ => false
  end.

Definition is_dynamic_array_zero_assignment
    (array index : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Ederef
        (Ebinop Oadd (Efield _ found_array _) (Etempvar found_index _) _) _)
      (Econst_int zero _) =>
      Pos.eqb found_array array && Pos.eqb found_index index &&
      Int.eq zero Int.zero
  | _ => false
  end.

Fixpoint assigns_dynamic_array_zero_s
    (array index : ident) (s : statement) : bool :=
  is_dynamic_array_zero_assignment array index s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_dynamic_array_zero_s array index a ||
      assigns_dynamic_array_zero_s array index b
  | Sifthenelse _ a b =>
      assigns_dynamic_array_zero_s array index a ||
      assigns_dynamic_array_zero_s array index b
  | Slabel _ body => assigns_dynamic_array_zero_s array index body
  | _ => false
  end.

Definition is_list_index_extract
    (index : ident) (s : statement) : bool :=
  match s with
  | Sset found_index
      (Ebinop Oand
        (Ebinop Oshr _ (Econst_int shift _) _)
        (Econst_int mask _) _) =>
      Pos.eqb found_index index && Int.eq shift (Int.repr 16) &&
      Int.eq mask (Int.repr 65535)
  | _ => false
  end.

Fixpoint sets_list_index_extract_s (index : ident) (s : statement) : bool :=
  is_list_index_extract index s ||
  match s with
  | Ssequence a b | Sloop a b =>
      sets_list_index_extract_s index a || sets_list_index_extract_s index b
  | Sifthenelse _ a b =>
      sets_list_index_extract_s index a || sets_list_index_extract_s index b
  | Slabel _ body => sets_list_index_extract_s index body
  | _ => false
  end.

Fixpoint contains_list_decode_s (index : ident) (s : statement) : bool :=
  match s with
  | Sifthenelse
      (Ebinop Oeq
        (Ebinop Oshr _ (Econst_int shift _) _)
        (Econst_int zero _) _)
      explicit_branch
      (Sset found_index (Econst_int default_list _)) =>
      (Int.eq shift (Int.repr 24) && Int.eq zero Int.zero &&
       Pos.eqb found_index index && Int.eq default_list (Int.repr 8) &&
       sets_list_index_extract_s index explicit_branch) ||
      contains_list_decode_s index explicit_branch
  | Ssequence a b | Sloop a b =>
      contains_list_decode_s index a || contains_list_decode_s index b
  | Sifthenelse _ a b =>
      contains_list_decode_s index a || contains_list_decode_s index b
  | Slabel _ body => contains_list_decode_s index body
  | _ => false
  end.

Fixpoint contains_global_list_address_s
    (global index list : ident) (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded (Evar found_global _))
      (Sset found_list
        (Ebinop Oadd (Etempvar used_loaded _) (Etempvar found_index _) _)) =>
      Pos.eqb found_global global && Pos.eqb loaded used_loaded &&
      Pos.eqb found_index index && Pos.eqb found_list list
  | Ssequence a b | Sloop a b =>
      contains_global_list_address_s global index list a ||
      contains_global_list_address_s global index list b
  | Sifthenelse _ a b =>
      contains_global_list_address_s global index list a ||
      contains_global_list_address_s global index list b
  | Slabel _ body => contains_global_list_address_s global index list body
  | _ => false
  end.

Fixpoint contains_unimportant_mark_s
    (index active_flags : ident) (s : statement) : bool :=
  match s with
  | Sifthenelse
      (Ebinop Oeq (Etempvar found_index _) (Econst_int list_number _) _)
      yes_branch no_branch =>
      (Pos.eqb found_index index && Int.eq list_number (Int.repr 12) &&
       assigns_field_or_shift_bit_s active_flags 4 yes_branch) ||
      contains_unimportant_mark_s index active_flags yes_branch ||
      contains_unimportant_mark_s index active_flags no_branch
  | Ssequence a b | Sloop a b =>
      contains_unimportant_mark_s index active_flags a ||
      contains_unimportant_mark_s index active_flags b
  | Slabel _ body => contains_unimportant_mark_s index active_flags body
  | _ => false
  end.

Definition is_raw_or_parameter_assignment
    (array : ident) (index : Z) (parameter : ident)
    (s : statement) : bool :=
  match s with
  | Sassign lhs (Ebinop Oor _ (Etempvar found_parameter _) _) =>
      array_lhs_field_index_is array index lhs &&
      Pos.eqb found_parameter parameter
  | _ => false
  end.

Definition array_rvalue_field_index_is
    (array : ident) (index : Z) (value : expr) : bool :=
  match value with
  | Ederef
      (Ebinop Oadd (Efield _ found_array _) (Econst_int found_index _) _) _ =>
      Pos.eqb found_array array && Int.eq found_index (Int.repr index)
  | _ => false
  end.

Fixpoint assigns_raw_or_parameter_s
    (array : ident) (index : Z) (parameter : ident)
    (s : statement) : bool :=
  is_raw_or_parameter_assignment array index parameter s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_raw_or_parameter_s array index parameter a ||
      assigns_raw_or_parameter_s array index parameter b
  | Sifthenelse _ a b =>
      assigns_raw_or_parameter_s array index parameter a ||
      assigns_raw_or_parameter_s array index parameter b
  | Slabel _ body => assigns_raw_or_parameter_s array index parameter body
  | _ => false
  end.

Fixpoint contains_particle_guard_set_s
    (array parameter : ident) (index : Z) (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset loaded loaded_value)
      (Sifthenelse
      (Eunop Onotbool
        (Ebinop Oand (Etempvar tested _) (Etempvar found_parameter _) _) _)
      yes_branch no_branch) =>
      (Pos.eqb loaded tested && Pos.eqb found_parameter parameter &&
       array_rvalue_field_index_is array index loaded_value &&
       assigns_raw_or_parameter_s array index parameter yes_branch) ||
      contains_particle_guard_set_s array parameter index yes_branch ||
      contains_particle_guard_set_s array parameter index no_branch
  | Ssequence a b | Sloop a b =>
      contains_particle_guard_set_s array parameter index a ||
      contains_particle_guard_set_s array parameter index b
  | Slabel _ body => contains_particle_guard_set_s array parameter index body
  | _ => false
  end.

Definition is_dynamic_array_and_assignment
    (array field value : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Ederef
        (Ebinop Oadd (Efield _ found_array _) (Etempvar found_field _) _) _)
      (Ebinop Oand _ (Ecast (Etempvar found_value _) _) _) =>
      Pos.eqb found_array array && Pos.eqb found_field field &&
      Pos.eqb found_value value
  | _ => false
  end.

Fixpoint assigns_dynamic_array_and_s
    (array field value : ident) (s : statement) : bool :=
  is_dynamic_array_and_assignment array field value s ||
  match s with
  | Ssequence a b | Sloop a b =>
      assigns_dynamic_array_and_s array field value a ||
      assigns_dynamic_array_and_s array field value b
  | Sifthenelse _ a b =>
      assigns_dynamic_array_and_s array field value a ||
      assigns_dynamic_array_and_s array field value b
  | Slabel _ body => assigns_dynamic_array_and_s array field value body
  | _ => false
  end.

(** A generated-data/Clight receipt for each supported retail version.

    The receipt covers, in order:
    - the 240-object pool and its free-list initialization;
    - free-head removal and the four tail-append links;
    - unimportant-object fallback, non-returning exhaustion, and rawData zeroing;
    - behavior-header list decoding (default 8, explicit 12);
    - the D/D/U list classes of spawner, WhitePuff1, and WhitePuff2;
    - active-particle word 22's guard and OR-set;
    - the spawner's first PARENT_BIT_CLEAR command and its AND-clear handler;
    - PLAYER (0) preceding DEFAULT (8) and UNIMPORTANT (12) this frame.

    The relevant pinned C regions are object_list_processor.c:172-217,
    255-287, 573-581; spawn_object.c:79-99, 132-148, 208-253,
    313-352; behavior_data.c:2771-2801; and
    behavior_script.c:805-813.  This is a syntax/data theorem, not a
    whole-program Clight execution theorem. *)
Definition dust_pool_source_receipt (version : GameVersion) : Prop :=
  match version with
  | VersionUS =>
      gvar_info UOL.v_gObjectPool =
        Tarray (Tstruct UOL._Object noattr) 240 noattr /\
      gvar_init UOL.v_gObjectPool = [Init_space 145920] /\
      sets_temp_const_s USO._poolLength 240
        (fn_body USO.f_init_free_object_list) = true /\
      statement_mentions_ident_s USO._gObjectPool
        (fn_body USO.f_init_free_object_list) = true /\
      assigns_global_field_from_temp_s
        USO._gFreeObjectList USO._next USO._obj
        (fn_body USO.f_init_free_object_list) = true /\
      contains_pool_successor_link_s USO._obj USO._header USO._next
        (fn_body USO.f_init_free_object_list) = true /\
      contains_pool_terminal_null_s USO._obj USO._header USO._next
        (fn_body USO.f_init_free_object_list) = true /\
      statement_has_loop_s (fn_body USO.f_init_free_object_list) = true /\
      sets_temp_from_field_of_temp_s USO._t'5 USO._freeList USO._next
        (fn_body USO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s USO._t'4 USO._nextObj USO._next
        (fn_body USO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s USO._freeList USO._next USO._t'4
        (fn_body USO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s USO._t'3 USO._destList USO._prev
        (fn_body USO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s USO._nextObj USO._prev USO._t'3
        (fn_body USO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s USO._nextObj USO._next USO._destList
        (fn_body USO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s USO._t'2 USO._destList USO._prev
        (fn_body USO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s USO._t'2 USO._next USO._nextObj
        (fn_body USO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s USO._destList USO._prev USO._nextObj
        (fn_body USO.f_try_allocate_object) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body USO.f_allocate_object))
        USO._try_allocate_object = 2%nat /\
      calls_ident_s USO._find_unimportant_object
        (fn_body USO.f_allocate_object) = true /\
      calls_ident_s USO._unload_object
        (fn_body USO.f_allocate_object) = true /\
      statement_has_busy_loop_s (fn_body USO.f_allocate_object) = true /\
      statement_mentions_int_s 80 (fn_body USO.f_allocate_object) = true /\
      assigns_dynamic_array_zero_s USO._asS32 USO._i
        (fn_body USO.f_allocate_object) = true /\
      contains_list_decode_s USO._objListIndex
        (fn_body USO.f_create_object) = true /\
      contains_global_list_address_s
        USO._gObjectLists USO._objListIndex USO._objList
        (fn_body USO.f_create_object) = true /\
      calls_ident_s USO._allocate_object (fn_body USO.f_create_object) = true /\
      contains_unimportant_mark_s USO._objListIndex USO._activeFlags
        (fn_body USO.f_create_object) = true /\
      firstn 3 (gvar_init UBD.v_bhvMistParticleSpawner) =
        [Init_int32 (Int.repr 524288);
         Init_int32 (Int.repr 857079808);
         Init_int32 (Int.repr 1)] /\
      nth_error (gvar_init UBD.v_bhvMistParticleSpawner) 6 =
        Some (Init_addrof UBD._bhvWhitePuff1 (Ptrofs.repr 0)) /\
      nth_error (gvar_init UBD.v_bhvMistParticleSpawner) 9 =
        Some (Init_addrof UBD._bhvWhitePuff2 (Ptrofs.repr 0)) /\
      hd_error (gvar_init UBD.v_bhvWhitePuff1) =
        Some (Init_int32 (Int.repr 524288)) /\
      hd_error (gvar_init UBD.v_bhvWhitePuff2) =
        Some (Init_int32 (Int.repr 786432)) /\
      contains_particle_guard_set_s UOL._asU32 UOL._activeParticleFlag 22
        (fn_body UOL.f_spawn_particle) = true /\
      calls_ident_s UOL._spawn_object_at_origin
        (fn_body UOL.f_spawn_particle) = true /\
      calls_ident_s UOL._obj_copy_pos_and_angle
        (fn_body UOL.f_spawn_particle) = true /\
      nth_error (gvar_init UBS.v_BehaviorCmdTable) 51 =
        Some (Init_addrof UBS._bhv_cmd_parent_bit_clear (Ptrofs.repr 0)) /\
      statement_mentions_ident_s UBS._parentObj
        (fn_body UBS.f_bhv_cmd_parent_bit_clear) = true /\
      statement_mentions_ident_s UBS._rawData
        (fn_body UBS.f_bhv_cmd_parent_bit_clear) = true /\
      statement_mentions_int_s (-1)
        (fn_body UBS.f_bhv_cmd_parent_bit_clear) = true /\
      assigns_dynamic_array_and_s UBS._asS32 UBS._field UBS._value
        (fn_body UBS.f_bhv_cmd_parent_bit_clear) = true /\
      gvar_init UOL.v_sObjectListUpdateOrder =
        [Init_int8 (Int.repr 11); Init_int8 (Int.repr 9);
         Init_int8 (Int.repr 10); Init_int8 (Int.repr 0);
         Init_int8 (Int.repr 5); Init_int8 (Int.repr 4);
         Init_int8 (Int.repr 2); Init_int8 (Int.repr 6);
         Init_int8 (Int.repr 8); Init_int8 (Int.repr 12);
         Init_int8 (Int.repr (-1))]
  | VersionJP =>
      gvar_info JOL.v_gObjectPool =
        Tarray (Tstruct JOL._Object noattr) 240 noattr /\
      gvar_init JOL.v_gObjectPool = [Init_space 145920] /\
      sets_temp_const_s JSO._poolLength 240
        (fn_body JSO.f_init_free_object_list) = true /\
      statement_mentions_ident_s JSO._gObjectPool
        (fn_body JSO.f_init_free_object_list) = true /\
      assigns_global_field_from_temp_s
        JSO._gFreeObjectList JSO._next JSO._obj
        (fn_body JSO.f_init_free_object_list) = true /\
      contains_pool_successor_link_s JSO._obj JSO._header JSO._next
        (fn_body JSO.f_init_free_object_list) = true /\
      contains_pool_terminal_null_s JSO._obj JSO._header JSO._next
        (fn_body JSO.f_init_free_object_list) = true /\
      statement_has_loop_s (fn_body JSO.f_init_free_object_list) = true /\
      sets_temp_from_field_of_temp_s JSO._t'5 JSO._freeList JSO._next
        (fn_body JSO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s JSO._t'4 JSO._nextObj JSO._next
        (fn_body JSO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s JSO._freeList JSO._next JSO._t'4
        (fn_body JSO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s JSO._t'3 JSO._destList JSO._prev
        (fn_body JSO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s JSO._nextObj JSO._prev JSO._t'3
        (fn_body JSO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s JSO._nextObj JSO._next JSO._destList
        (fn_body JSO.f_try_allocate_object) = true /\
      sets_temp_from_field_of_temp_s JSO._t'2 JSO._destList JSO._prev
        (fn_body JSO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s JSO._t'2 JSO._next JSO._nextObj
        (fn_body JSO.f_try_allocate_object) = true /\
      assigns_field_of_temp_from_temp_s JSO._destList JSO._prev JSO._nextObj
        (fn_body JSO.f_try_allocate_object) = true /\
      count_occ Pos.eq_dec
        (direct_callees_s (fn_body JSO.f_allocate_object))
        JSO._try_allocate_object = 2%nat /\
      calls_ident_s JSO._find_unimportant_object
        (fn_body JSO.f_allocate_object) = true /\
      calls_ident_s JSO._unload_object
        (fn_body JSO.f_allocate_object) = true /\
      statement_has_busy_loop_s (fn_body JSO.f_allocate_object) = true /\
      statement_mentions_int_s 80 (fn_body JSO.f_allocate_object) = true /\
      assigns_dynamic_array_zero_s JSO._asS32 JSO._i
        (fn_body JSO.f_allocate_object) = true /\
      contains_list_decode_s JSO._objListIndex
        (fn_body JSO.f_create_object) = true /\
      contains_global_list_address_s
        JSO._gObjectLists JSO._objListIndex JSO._objList
        (fn_body JSO.f_create_object) = true /\
      calls_ident_s JSO._allocate_object (fn_body JSO.f_create_object) = true /\
      contains_unimportant_mark_s JSO._objListIndex JSO._activeFlags
        (fn_body JSO.f_create_object) = true /\
      firstn 3 (gvar_init JBD.v_bhvMistParticleSpawner) =
        [Init_int32 (Int.repr 524288);
         Init_int32 (Int.repr 857079808);
         Init_int32 (Int.repr 1)] /\
      nth_error (gvar_init JBD.v_bhvMistParticleSpawner) 6 =
        Some (Init_addrof JBD._bhvWhitePuff1 (Ptrofs.repr 0)) /\
      nth_error (gvar_init JBD.v_bhvMistParticleSpawner) 9 =
        Some (Init_addrof JBD._bhvWhitePuff2 (Ptrofs.repr 0)) /\
      hd_error (gvar_init JBD.v_bhvWhitePuff1) =
        Some (Init_int32 (Int.repr 524288)) /\
      hd_error (gvar_init JBD.v_bhvWhitePuff2) =
        Some (Init_int32 (Int.repr 786432)) /\
      contains_particle_guard_set_s JOL._asU32 JOL._activeParticleFlag 22
        (fn_body JOL.f_spawn_particle) = true /\
      calls_ident_s JOL._spawn_object_at_origin
        (fn_body JOL.f_spawn_particle) = true /\
      calls_ident_s JOL._obj_copy_pos_and_angle
        (fn_body JOL.f_spawn_particle) = true /\
      nth_error (gvar_init JBS.v_BehaviorCmdTable) 51 =
        Some (Init_addrof JBS._bhv_cmd_parent_bit_clear (Ptrofs.repr 0)) /\
      statement_mentions_ident_s JBS._parentObj
        (fn_body JBS.f_bhv_cmd_parent_bit_clear) = true /\
      statement_mentions_ident_s JBS._rawData
        (fn_body JBS.f_bhv_cmd_parent_bit_clear) = true /\
      statement_mentions_int_s (-1)
        (fn_body JBS.f_bhv_cmd_parent_bit_clear) = true /\
      assigns_dynamic_array_and_s JBS._asS32 JBS._field JBS._value
        (fn_body JBS.f_bhv_cmd_parent_bit_clear) = true /\
      gvar_init JOL.v_sObjectListUpdateOrder =
        [Init_int8 (Int.repr 11); Init_int8 (Int.repr 9);
         Init_int8 (Int.repr 10); Init_int8 (Int.repr 0);
         Init_int8 (Int.repr 5); Init_int8 (Int.repr 4);
         Init_int8 (Int.repr 2); Init_int8 (Int.repr 6);
         Init_int8 (Int.repr 8); Init_int8 (Int.repr 12);
         Init_int8 (Int.repr (-1))]
  end.

Theorem dust_pool_source_receipt_us :
  dust_pool_source_receipt VersionUS.
Proof.
  unfold dust_pool_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem dust_pool_source_receipt_jp :
  dust_pool_source_receipt VersionJP.
Proof.
  unfold dust_pool_source_receipt.
  vm_compute.
  repeat split.
Qed.

Theorem dust_pool_source_receipt_supported :
  forall version, dust_pool_source_receipt version.
Proof.
  intros []; [exact dust_pool_source_receipt_us |
              exact dust_pool_source_receipt_jp].
Qed.

(** Exact reserve abstraction for the allocation behavior witnessed above.
    [free_objects + unimportant_objects] is precisely the stock allocator's
    immediately usable reserve.  An important-list allocation consumes one
    unit.  An unimportant-list allocation consumes a free unit but creates an
    evictable unit, or replaces an evicted unimportant object, so it preserves
    the total reserve. *)
Inductive AllocationList : Type :=
| ImportantList
| UnimportantList.

Record PoolReserve : Type := {
  free_objects : nat;
  unimportant_objects : nat
}.

Definition usable_reserve (pool : PoolReserve) : nat :=
  free_objects pool + unimportant_objects pool.

Definition allocate_from_reserve
    (list : AllocationList) (pool : PoolReserve) : option PoolReserve :=
  match free_objects pool with
  | S free_after =>
      match list with
      | ImportantList =>
          Some {| free_objects := free_after;
                  unimportant_objects := unimportant_objects pool |}
      | UnimportantList =>
          Some {| free_objects := free_after;
                  unimportant_objects := S (unimportant_objects pool) |}
      end
  | O =>
      match unimportant_objects pool with
      | S unimportant_after =>
          match list with
          | ImportantList =>
              Some {| free_objects := O;
                      unimportant_objects := unimportant_after |}
          | UnimportantList =>
              Some {| free_objects := O;
                      unimportant_objects := S unimportant_after |}
          end
      | O => None
      end
  end.

(** The behavior headers prove that this is the actual list-class trace:
    mist spawner DEFAULT, WhitePuff1 DEFAULT, WhitePuff2 UNIMPORTANT. *)
Definition dust_three_allocation_trace
    (pool : PoolReserve) : option PoolReserve :=
  match allocate_from_reserve ImportantList pool with
  | None => None
  | Some after_spawner =>
      match allocate_from_reserve ImportantList after_spawner with
      | None => None
      | Some after_white_puff_1 =>
          allocate_from_reserve UnimportantList after_white_puff_1
      end
  end.

Definition option_pool_is_some (result : option PoolReserve) : bool :=
  match result with
  | Some _ => true
  | None => false
  end.

Theorem dust_three_allocations_succeed_iff_reserve_at_least_three :
  forall pool,
    option_pool_is_some (dust_three_allocation_trace pool) = true <->
    3 <= usable_reserve pool.
Proof.
  intros [free unimportant].
  destruct free as [|free].
  - destruct unimportant as [|unimportant].
    + cbn. split; intro H; [discriminate H | lia].
    + destruct unimportant as [|unimportant].
      * cbn. split; intro H; [discriminate H | lia].
      * destruct unimportant as [|unimportant].
        -- cbn. split; intro H; [discriminate H | lia].
        -- cbn. split; intro H; [lia | reflexivity].
  - destruct free as [|free].
    + destruct unimportant as [|unimportant].
      * cbn. split; intro H; [discriminate H | lia].
      * destruct unimportant as [|unimportant].
        -- cbn. split; intro H; [discriminate H | lia].
        -- cbn. split; intro H; [lia | reflexivity].
    + destruct free as [|free].
      * destruct unimportant as [|unimportant].
        -- cbn. split; intro H; [discriminate H | lia].
        -- cbn. split; intro H; [lia | reflexivity].
      * cbn. split; intro H; [lia | reflexivity].
Qed.

Theorem dust_three_allocations_exist_iff_reserve_at_least_three :
  forall pool,
    (exists pool_after, dust_three_allocation_trace pool = Some pool_after) <->
    3 <= usable_reserve pool.
Proof.
  intro pool.
  rewrite <- dust_three_allocations_succeed_iff_reserve_at_least_three.
  destruct (dust_three_allocation_trace pool) as [pool_after|] eqn:Htrace.
  - split; intro.
    + reflexivity.
    + exists pool_after; reflexivity.
  - split; intro H.
    + destruct H as [pool_after H]. discriminate.
    + discriminate.
Qed.

Theorem dust_three_allocations_leave_exactly_two_fewer_reserve_units :
  forall pool pool_after,
    dust_three_allocation_trace pool = Some pool_after ->
    usable_reserve pool_after = usable_reserve pool - 2.
Proof.
  intros [free unimportant] pool_after Htrace.
  destruct free as [|free].
  - destruct unimportant as [|unimportant].
    + discriminate.
    + destruct unimportant as [|unimportant].
      * discriminate.
      * destruct unimportant as [|unimportant].
        -- discriminate.
        -- simpl in Htrace. inversion Htrace; subst; reflexivity.
  - destruct free as [|free].
    + destruct unimportant as [|unimportant].
      * discriminate.
      * destruct unimportant as [|unimportant].
        -- discriminate.
        -- simpl in Htrace. inversion Htrace; subst; reflexivity.
    + destruct free as [|free].
      * destruct unimportant as [|unimportant].
        -- discriminate.
        -- simpl in Htrace. inversion Htrace; subst; reflexivity.
      * simpl in Htrace. inversion Htrace; subst.
        unfold usable_reserve; simpl; lia.
Qed.

(** Projection of rawData.asU32[22]'s dust bit through the guarded source
    operations.  A clear bit accepts this spawn request, OR with 1 sets it,
    and that newly allocated spawner later clears it.  If the bit was already
    set, this call allocates no spawner, so this episode cannot claim a
    same-frame parent clear. *)
Definition dust_spawn_accepted (before : bool) : bool := negb before.

Definition dust_active_bit_after_spawn (_before : bool) : bool := true.

Definition dust_active_bit_after_default_phase (before : bool) : bool :=
  if dust_spawn_accepted before then false else true.

Record DustBitSameFrame : Type := {
  bit_before_player_update : bool;
  dust_request_accepted : bool;
  bit_after_spawn_particle : bool;
  bit_after_default_spawner : bool
}.

Definition run_dust_bit_same_frame (initial : bool) : DustBitSameFrame :=
  {| bit_before_player_update := initial;
     dust_request_accepted := dust_spawn_accepted initial;
     bit_after_spawn_particle := dust_active_bit_after_spawn initial;
     bit_after_default_spawner := dust_active_bit_after_default_phase initial |}.

Theorem clear_active_dust_bit_accepts_then_clears_in_same_frame_model :
  forall initial,
    initial = false ->
    dust_request_accepted (run_dust_bit_same_frame initial) = true /\
    bit_after_spawn_particle (run_dust_bit_same_frame initial) = true /\
    bit_after_default_spawner (run_dust_bit_same_frame initial) = false.
Proof.
  intros [] Hclear; [discriminate Hclear | repeat split; reflexivity].
Qed.

Theorem set_active_dust_bit_rejects_new_spawner_in_same_frame_model :
  forall initial,
    initial = true ->
    dust_request_accepted (run_dust_bit_same_frame initial) = false /\
    bit_after_spawn_particle (run_dust_bit_same_frame initial) = true /\
    bit_after_default_spawner (run_dust_bit_same_frame initial) = true.
Proof.
  intros [] Hset; [repeat split; reflexivity | discriminate Hset].
Qed.

(** This is deliberately conditional on a reachable retail tap and on the
    reserve bound at that tap.  This file does not construct [reachable_tap];
    consequently the theorem must not be cited as a stock TTC reachability
    result. *)
Theorem pool_and_active_flag_result_given_unproved_reachable_tap :
  forall (reachable_tap : Prop) (pool : PoolReserve) (initial_bit : bool),
    reachable_tap ->
    3 <= usable_reserve pool ->
    initial_bit = false ->
    reachable_tap /\
    (exists pool_after,
       dust_three_allocation_trace pool = Some pool_after) /\
    dust_request_accepted (run_dust_bit_same_frame initial_bit) = true /\
    bit_after_spawn_particle (run_dust_bit_same_frame initial_bit) = true /\
    bit_after_default_spawner (run_dust_bit_same_frame initial_bit) = false.
Proof.
  intros reachable_tap pool initial_bit Hreachable Hreserve Hclear.
  split; [exact Hreachable|].
  split.
  - apply (proj2
      (dust_three_allocations_exist_iff_reserve_at_least_three pool)).
    exact Hreserve.
  - apply clear_active_dust_bit_accepts_then_clears_in_same_frame_model.
    exact Hclear.
Qed.
