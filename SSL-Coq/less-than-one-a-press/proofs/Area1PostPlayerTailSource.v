(**
  Generated-source receipts for the stock object-list suffix after the
  PLAYER list in SSL Area 1, plus the still-open intra-PLAYER tail after
  Mario's State-to-Object copy.

  The retail list order is

    [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1].

  Thus lists [5;4;2;6;8;12] are the post-PLAYER suffix.  This suffix is not
  the whole post-copy tail: [bhv_mario_update] has a particle-spawn loop after
  the copy, [bhvMario] next names the debug-object-spawn callback, and the
  PLAYER list may contain later nodes.  The fixed scheduler,
  unload, and final-platform-query bodies below contain no direct generated
  [MarioState.pos[0..2]] or receiver-neutral [rawData.asF32[6..8]] store.
  This narrows a surviving post-copy split to behavior callbacks or to an
  execution escape (alias/external write, lifecycle/reuse, abnormal return,
  or scheduler mismatch); it is not a transitive callback proof.

  A concrete reason the transitive boundary matters is also recorded.  An
  Area-1 breakable-box root can call [obj_explode_and_spawn_coins], which calls
  [spawn_triangle_break_particles] and requests [bhvBreakBoxTriangle], a
  list-12 behavior.  The object traversal
  advances through [firstObj->next] after [cur_obj_update], and ordinary
  allocation mutates the destination list's tail links.  These are syntax
  receipts, not a theorem that allocation succeeds, that the new node is
  observed in the same traversal, or that the callback returns normally.
*)

From Coq Require Import Bool List ZArith.
From compcert Require Import AST Clight Ctypes Integers.
From LessThanOneAPress.Generated Require Import
  us_behavior_actions us_behavior_data us_object_helpers
  us_object_list_processor us_platform_displacement us_spawn_object us_debug
  jp_behavior_actions jp_behavior_data jp_object_helpers
  jp_object_list_processor jp_platform_displacement jp_spawn_object jp_debug.
From LessThanOneAPress.Proofs Require Import
  ASTFacts Area1EntryDepthClosure Area1PolePushSchedule
  Area1PrecollisionWriterClosure ClightFacts.

Import ListNotations.
Local Open Scope Z_scope.

Module A1PTS_USBA := us_behavior_actions.
Module A1PTS_USBD := us_behavior_data.
Module A1PTS_USOH := us_object_helpers.
Module A1PTS_USOL := us_object_list_processor.
Module A1PTS_USPD := us_platform_displacement.
Module A1PTS_USSO := us_spawn_object.
Module A1PTS_USDebug := us_debug.
Module A1PTS_JPBA := jp_behavior_actions.
Module A1PTS_JPBD := jp_behavior_data.
Module A1PTS_JPOH := jp_object_helpers.
Module A1PTS_JPOL := jp_object_list_processor.
Module A1PTS_JPPD := jp_platform_displacement.
Module A1PTS_JPSO := jp_spawn_object.
Module A1PTS_JPDebug := jp_debug.

(** The array receipt, its exact suffix, and the player callback's action-copy
    order are kept together.  [update_non_terrain_objects] starts at array
    index 2 in the pinned C source; connecting that loop counter to every
    selected list remains a Clight execution refinement. *)
Definition area1_post_player_list_suffix_source_claim : Prop :=
  a1pps_init_int8_values
    (gvar_init A1PTS_USOL.v_sObjectListUpdateOrder) =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
  a1pps_init_int8_values
    (gvar_init A1PTS_JPOL.v_sObjectListUpdateOrder) =
      [11; 9; 10; 0; 5; 4; 2; 6; 8; 12; -1] /\
  skipn 4
    (a1pps_init_int8_values
      (gvar_init A1PTS_USOL.v_sObjectListUpdateOrder)) =
      [5; 4; 2; 6; 8; 12; -1] /\
  skipn 4
    (a1pps_init_int8_values
      (gvar_init A1PTS_JPOL.v_sObjectListUpdateOrder)) =
      [5; 4; 2; 6; 8; 12; -1] /\
  ident_subsequenceb
    [A1PTS_USOL._execute_mario_action;
     A1PTS_USOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body A1PTS_USOL.f_bhv_mario_update)) = true /\
  ident_subsequenceb
    [A1PTS_JPOL._execute_mario_action;
     A1PTS_JPOL._copy_mario_state_to_object]
    (direct_callees_s (fn_body A1PTS_JPOL.f_bhv_mario_update)) = true /\
  ident_subsequenceb
    [A1PTS_USOL._update_non_terrain_objects;
     A1PTS_USOL._unload_deactivated_objects;
     A1PTS_USOL._update_mario_platform]
    (straightline_callees_s (fn_body A1PTS_USOL.f_update_objects)) = true /\
  ident_subsequenceb
    [A1PTS_JPOL._update_non_terrain_objects;
     A1PTS_JPOL._unload_deactivated_objects;
     A1PTS_JPOL._update_mario_platform]
    (straightline_callees_s (fn_body A1PTS_JPOL.f_update_objects)) = true.

Theorem area1_post_player_list_suffix_source_checked :
  area1_post_player_list_suffix_source_claim.
Proof.
  unfold area1_post_player_list_suffix_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** Recognize the exact local traversal fragment

      callback();
      cursor = cursor->next;

    while retaining the callback, cursor, and field identifiers at the same
    syntax node. *)
Definition is_callback_then_cursor_field_advance_s
    (callback cursor field : ident) (s : statement) : bool :=
  match s with
  | Ssequence
      (Scall _ (Evar found_callback _) _)
      (Ssequence
        (Sset found_destination
          (Efield
            (Ederef (Etempvar found_source _) _) found_field _)) _) =>
      Pos.eqb found_callback callback &&
      Pos.eqb found_destination cursor &&
      Pos.eqb found_source cursor &&
      Pos.eqb found_field field
  | _ => false
  end.

Fixpoint contains_callback_then_cursor_field_advance_s
    (callback cursor field : ident) (s : statement) : bool :=
  is_callback_then_cursor_field_advance_s callback cursor field s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_callback_then_cursor_field_advance_s
        callback cursor field first ||
      contains_callback_then_cursor_field_advance_s
        callback cursor field second
  | Sifthenelse _ if_true if_false =>
      contains_callback_then_cursor_field_advance_s
        callback cursor field if_true ||
      contains_callback_then_cursor_field_advance_s
        callback cursor field if_false
  | Sswitch _ cases =>
      contains_callback_then_cursor_field_advance_ls
        callback cursor field cases
  | Slabel _ body =>
      contains_callback_then_cursor_field_advance_s
        callback cursor field body
  | _ => false
  end
with contains_callback_then_cursor_field_advance_ls
    (callback cursor field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_callback_then_cursor_field_advance_s
        callback cursor field body ||
      contains_callback_then_cursor_field_advance_ls
        callback cursor field rest
  end.

(** Couple a particular temporary receiver, struct field, and temporary value
    at one assignment site.  This is stronger than finding an unrelated field
    write and an unrelated mention of the destination list. *)
Fixpoint assigns_temp_struct_field_from_temp_s
    (base field value : ident) (s : statement) : bool :=
  match s with
  | Sassign
      (Efield (Ederef (Etempvar found_base _) _) found_field _)
      (Etempvar found_value _) =>
      Pos.eqb found_base base &&
      Pos.eqb found_field field &&
      Pos.eqb found_value value
  | Ssequence first second | Sloop first second =>
      assigns_temp_struct_field_from_temp_s base field value first ||
      assigns_temp_struct_field_from_temp_s base field value second
  | Sifthenelse _ if_true if_false =>
      assigns_temp_struct_field_from_temp_s base field value if_true ||
      assigns_temp_struct_field_from_temp_s base field value if_false
  | Sswitch _ cases =>
      assigns_temp_struct_field_from_temp_ls base field value cases
  | Slabel _ body =>
      assigns_temp_struct_field_from_temp_s base field value body
  | _ => false
  end
with assigns_temp_struct_field_from_temp_ls
    (base field value : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_temp_struct_field_from_temp_s base field value body ||
      assigns_temp_struct_field_from_temp_ls base field value rest
  end.

(** The first two conjuncts couple the callback and subsequent list advance.
    The remaining receipts show that ordinary construction reaches the
    allocator and couple [nextObj.next := destList] with
    [destList.prev := nextObj].  They do not establish freshness, the complete
    four-store insertion order, or same-frame execution. *)
Definition post_player_traversal_and_tail_link_source_claim : Prop :=
  contains_callback_then_cursor_field_advance_s
    A1PTS_USOL._cur_obj_update A1PTS_USOL._firstObj A1PTS_USOL._next
    (fn_body A1PTS_USOL.f_update_objects_starting_at) = true /\
  contains_callback_then_cursor_field_advance_s
    A1PTS_JPOL._cur_obj_update A1PTS_JPOL._firstObj A1PTS_JPOL._next
    (fn_body A1PTS_JPOL.f_update_objects_starting_at) = true /\
  calls_ident_s A1PTS_USSO._allocate_object
    (fn_body A1PTS_USSO.f_create_object) = true /\
  calls_ident_s A1PTS_JPSO._allocate_object
    (fn_body A1PTS_JPSO.f_create_object) = true /\
  calls_ident_s A1PTS_USSO._try_allocate_object
    (fn_body A1PTS_USSO.f_allocate_object) = true /\
  calls_ident_s A1PTS_JPSO._try_allocate_object
    (fn_body A1PTS_JPSO.f_allocate_object) = true /\
  assigns_temp_struct_field_from_temp_s
    A1PTS_USSO._nextObj A1PTS_USSO._next A1PTS_USSO._destList
    (fn_body A1PTS_USSO.f_try_allocate_object) = true /\
  assigns_temp_struct_field_from_temp_s
    A1PTS_USSO._destList A1PTS_USSO._prev A1PTS_USSO._nextObj
    (fn_body A1PTS_USSO.f_try_allocate_object) = true /\
  assigns_temp_struct_field_from_temp_s
    A1PTS_JPSO._nextObj A1PTS_JPSO._next A1PTS_JPSO._destList
    (fn_body A1PTS_JPSO.f_try_allocate_object) = true /\
  assigns_temp_struct_field_from_temp_s
    A1PTS_JPSO._destList A1PTS_JPSO._prev A1PTS_JPSO._nextObj
    (fn_body A1PTS_JPSO.f_try_allocate_object) = true /\
  calls_ident_s A1PTS_USSO._unload_object
    (fn_body A1PTS_USSO.f_allocate_object) = true /\
  calls_ident_s A1PTS_JPSO._unload_object
    (fn_body A1PTS_JPSO.f_allocate_object) = true.

Theorem post_player_traversal_and_tail_link_source_checked :
  post_player_traversal_and_tail_link_source_claim.
Proof.
  unfold post_player_traversal_and_tail_link_source_claim.
  vm_compute. repeat split; reflexivity.
Qed.

(** The numerical post-PLAYER suffix begins only after the PLAYER traversal
    finishes.  These receipts expose the concrete work which remains after
    Mario's copy but before that suffix: Mario may spawn particles, the same
    behavior initializer next pairs a native-call command with the guarded
    debug-object spawner, and the
    list traversal advances to another PLAYER node after each callback.  This
    is evidence for an explicit residual, not proof that any guarded spawn is
    enabled, that the behavior interpreter executes either callback, or that
    another PLAYER node exists. *)
Definition bhv_mario_postcopy_native_callback_suffix
    (mario_update debug_spawn : ident) : list init_data :=
  [Init_int32 (Int.repr 201326592);
   Init_addrof mario_update (Ptrofs.repr 0);
   Init_int32 (Int.repr 201326592);
   Init_addrof debug_spawn (Ptrofs.repr 0);
   Init_int32 (Int.repr 150994944)].

Definition mario_post_copy_intra_player_residual_source_claim : Prop :=
  ident_subsequenceb
    [A1PTS_USOL._copy_mario_state_to_object; A1PTS_USOL._spawn_particle]
    (direct_callees_s (fn_body A1PTS_USOL.f_bhv_mario_update)) = true /\
  ident_subsequenceb
    [A1PTS_JPOL._copy_mario_state_to_object; A1PTS_JPOL._spawn_particle]
    (direct_callees_s (fn_body A1PTS_JPOL.f_bhv_mario_update)) = true /\
  skipn 9 (gvar_init A1PTS_USBD.v_bhvMario) =
    bhv_mario_postcopy_native_callback_suffix
      A1PTS_USBD._bhv_mario_update
      A1PTS_USBD._try_do_mario_debug_object_spawn /\
  skipn 9 (gvar_init A1PTS_JPBD.v_bhvMario) =
    bhv_mario_postcopy_native_callback_suffix
      A1PTS_JPBD._bhv_mario_update
      A1PTS_JPBD._try_do_mario_debug_object_spawn /\
  calls_ident_s A1PTS_USDebug._spawn_object_relative
    (fn_body A1PTS_USDebug.f_try_do_mario_debug_object_spawn) = true /\
  calls_ident_s A1PTS_JPDebug._spawn_object_relative
    (fn_body A1PTS_JPDebug.f_try_do_mario_debug_object_spawn) = true.

Theorem mario_post_copy_intra_player_residual_source_checked :
  mario_post_copy_intra_player_residual_source_claim.
Proof.
  unfold mario_post_copy_intra_player_residual_source_claim,
    bhv_mario_postcopy_native_callback_suffix.
  vm_compute. repeat split; reflexivity.
Qed.

(** Couple the table lookup

      behavior_temp = sParticleTypes[index_temp].behavior

    to the immediately following third argument of [spawn_particle].  This is
    deliberately a local syntax recognizer: it does not prove the loop guard,
    index range, or call execution. *)
Definition is_particle_behavior_load_then_spawn_s
    (table index_temp behavior_field behavior_temp callee : ident)
    (s : statement) : bool :=
  match s with
  | Ssequence
      (Sset found_behavior_temp
        (Efield
          (Ederef
            (Ebinop Oadd (Evar found_table _)
              (Etempvar found_index_temp _) _) _)
          found_behavior_field _))
      (Scall _ (Evar found_callee _)
        [_; _; Etempvar found_behavior_argument _]) =>
      Pos.eqb found_table table &&
      Pos.eqb found_index_temp index_temp &&
      Pos.eqb found_behavior_field behavior_field &&
      Pos.eqb found_behavior_temp behavior_temp &&
      Pos.eqb found_callee callee &&
      Pos.eqb found_behavior_argument behavior_temp
  | _ => false
  end.

Fixpoint contains_particle_behavior_load_then_spawn_s
    (table index_temp behavior_field behavior_temp callee : ident)
    (s : statement) : bool :=
  is_particle_behavior_load_then_spawn_s
    table index_temp behavior_field behavior_temp callee s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee first ||
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee second
  | Sifthenelse _ if_true if_false =>
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee if_true ||
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee if_false
  | Sswitch _ cases =>
      contains_particle_behavior_load_then_spawn_ls
        table index_temp behavior_field behavior_temp callee cases
  | Slabel _ body =>
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee body
  | _ => false
  end
with contains_particle_behavior_load_then_spawn_ls
    (table index_temp behavior_field behavior_temp callee : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_particle_behavior_load_then_spawn_s
        table index_temp behavior_field behavior_temp callee body ||
      contains_particle_behavior_load_then_spawn_ls
        table index_temp behavior_field behavior_temp callee rest
  end.

(** Match a four-argument call whose fourth argument is the selected formal.
    Formal-name receipts below keep the identifier tied to
    [spawn_particle]'s third formal parameter. *)
Definition is_call_forwarding_fourth_temp_s
    (callee forwarded : ident) (s : statement) : bool :=
  match s with
  | Scall _ (Evar found_callee _)
      [_; _; _; Etempvar found_forwarded _] =>
      Pos.eqb found_callee callee && Pos.eqb found_forwarded forwarded
  | _ => false
  end.

Fixpoint contains_call_forwarding_fourth_temp_s
    (callee forwarded : ident) (s : statement) : bool :=
  is_call_forwarding_fourth_temp_s callee forwarded s ||
  match s with
  | Ssequence first second | Sloop first second =>
      contains_call_forwarding_fourth_temp_s callee forwarded first ||
      contains_call_forwarding_fourth_temp_s callee forwarded second
  | Sifthenelse _ if_true if_false =>
      contains_call_forwarding_fourth_temp_s callee forwarded if_true ||
      contains_call_forwarding_fourth_temp_s callee forwarded if_false
  | Sswitch _ cases =>
      contains_call_forwarding_fourth_temp_ls callee forwarded cases
  | Slabel _ body =>
      contains_call_forwarding_fourth_temp_s callee forwarded body
  | _ => false
  end
with contains_call_forwarding_fourth_temp_ls
    (callee forwarded : ident) (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      contains_call_forwarding_fourth_temp_s callee forwarded body ||
      contains_call_forwarding_fourth_temp_ls callee forwarded rest
  end.

(** All 18 non-null behavior pointers in [sParticleTypes] select list 8.
    The dataflow receipts also tie the table's [behavior] field to the third
    [spawn_particle] argument, then tie that function's [behavior] parameter
    to the fourth [spawn_object_at_origin] argument.  Together with the
    copy-before-[spawn_particle] receipt above, this pins a concrete family of
    syntactically available post-copy descendants.  It still says neither that
    a particle flag is enabled nor that the calls, allocation, or traversal
    execute successfully. *)
Definition us_mario_particle_behavior_entries :
    list (ident * globvar type) :=
  [(A1PTS_USBD._bhvMistParticleSpawner,
      A1PTS_USBD.v_bhvMistParticleSpawner);
   (A1PTS_USBD._bhvVertStarParticleSpawner,
      A1PTS_USBD.v_bhvVertStarParticleSpawner);
   (A1PTS_USBD._bhvHorStarParticleSpawner,
      A1PTS_USBD.v_bhvHorStarParticleSpawner);
   (A1PTS_USBD._bhvSparkleParticleSpawner,
      A1PTS_USBD.v_bhvSparkleParticleSpawner);
   (A1PTS_USBD._bhvBubbleParticleSpawner,
      A1PTS_USBD.v_bhvBubbleParticleSpawner);
   (A1PTS_USBD._bhvWaterSplash, A1PTS_USBD.v_bhvWaterSplash);
   (A1PTS_USBD._bhvIdleWaterWave, A1PTS_USBD.v_bhvIdleWaterWave);
   (A1PTS_USBD._bhvPlungeBubble, A1PTS_USBD.v_bhvPlungeBubble);
   (A1PTS_USBD._bhvWaveTrail, A1PTS_USBD.v_bhvWaveTrail);
   (A1PTS_USBD._bhvFireParticleSpawner,
      A1PTS_USBD.v_bhvFireParticleSpawner);
   (A1PTS_USBD._bhvShallowWaterWave,
      A1PTS_USBD.v_bhvShallowWaterWave);
   (A1PTS_USBD._bhvShallowWaterSplash,
      A1PTS_USBD.v_bhvShallowWaterSplash);
   (A1PTS_USBD._bhvLeafParticleSpawner,
      A1PTS_USBD.v_bhvLeafParticleSpawner);
   (A1PTS_USBD._bhvSnowParticleSpawner,
      A1PTS_USBD.v_bhvSnowParticleSpawner);
   (A1PTS_USBD._bhvBreathParticleSpawner,
      A1PTS_USBD.v_bhvBreathParticleSpawner);
   (A1PTS_USBD._bhvDirtParticleSpawner,
      A1PTS_USBD.v_bhvDirtParticleSpawner);
   (A1PTS_USBD._bhvMistCircParticleSpawner,
      A1PTS_USBD.v_bhvMistCircParticleSpawner);
   (A1PTS_USBD._bhvTriangleParticleSpawner,
      A1PTS_USBD.v_bhvTriangleParticleSpawner)].

Definition jp_mario_particle_behavior_entries :
    list (ident * globvar type) :=
  [(A1PTS_JPBD._bhvMistParticleSpawner,
      A1PTS_JPBD.v_bhvMistParticleSpawner);
   (A1PTS_JPBD._bhvVertStarParticleSpawner,
      A1PTS_JPBD.v_bhvVertStarParticleSpawner);
   (A1PTS_JPBD._bhvHorStarParticleSpawner,
      A1PTS_JPBD.v_bhvHorStarParticleSpawner);
   (A1PTS_JPBD._bhvSparkleParticleSpawner,
      A1PTS_JPBD.v_bhvSparkleParticleSpawner);
   (A1PTS_JPBD._bhvBubbleParticleSpawner,
      A1PTS_JPBD.v_bhvBubbleParticleSpawner);
   (A1PTS_JPBD._bhvWaterSplash, A1PTS_JPBD.v_bhvWaterSplash);
   (A1PTS_JPBD._bhvIdleWaterWave, A1PTS_JPBD.v_bhvIdleWaterWave);
   (A1PTS_JPBD._bhvPlungeBubble, A1PTS_JPBD.v_bhvPlungeBubble);
   (A1PTS_JPBD._bhvWaveTrail, A1PTS_JPBD.v_bhvWaveTrail);
   (A1PTS_JPBD._bhvFireParticleSpawner,
      A1PTS_JPBD.v_bhvFireParticleSpawner);
   (A1PTS_JPBD._bhvShallowWaterWave,
      A1PTS_JPBD.v_bhvShallowWaterWave);
   (A1PTS_JPBD._bhvShallowWaterSplash,
      A1PTS_JPBD.v_bhvShallowWaterSplash);
   (A1PTS_JPBD._bhvLeafParticleSpawner,
      A1PTS_JPBD.v_bhvLeafParticleSpawner);
   (A1PTS_JPBD._bhvSnowParticleSpawner,
      A1PTS_JPBD.v_bhvSnowParticleSpawner);
   (A1PTS_JPBD._bhvBreathParticleSpawner,
      A1PTS_JPBD.v_bhvBreathParticleSpawner);
   (A1PTS_JPBD._bhvDirtParticleSpawner,
      A1PTS_JPBD.v_bhvDirtParticleSpawner);
   (A1PTS_JPBD._bhvMistCircParticleSpawner,
      A1PTS_JPBD.v_bhvMistCircParticleSpawner);
   (A1PTS_JPBD._bhvTriangleParticleSpawner,
      A1PTS_JPBD.v_bhvTriangleParticleSpawner)].

Definition mario_particle_behaviors_are_list8_source_claim : Prop :=
  initializer_addrof_idents (gvar_init A1PTS_USOL.v_sParticleTypes) =
    map fst us_mario_particle_behavior_entries /\
  initializer_addrof_idents (gvar_init A1PTS_JPOL.v_sParticleTypes) =
    map fst jp_mario_particle_behavior_entries /\
  map (fun entry => hd_error (gvar_init (snd entry)))
    us_mario_particle_behavior_entries =
      repeat (Some (Init_int32 (Int.repr 524288))) 18 /\
  map (fun entry => hd_error (gvar_init (snd entry)))
    jp_mario_particle_behavior_entries =
      repeat (Some (Init_int32 (Int.repr 524288))) 18 /\
  contains_particle_behavior_load_then_spawn_s
    A1PTS_USOL._sParticleTypes A1PTS_USOL._i A1PTS_USOL._behavior
    A1PTS_USOL._t'5 A1PTS_USOL._spawn_particle
    (fn_body A1PTS_USOL.f_bhv_mario_update) = true /\
  contains_particle_behavior_load_then_spawn_s
    A1PTS_JPOL._sParticleTypes A1PTS_JPOL._i A1PTS_JPOL._behavior
    A1PTS_JPOL._t'5 A1PTS_JPOL._spawn_particle
    (fn_body A1PTS_JPOL.f_bhv_mario_update) = true /\
  map fst (fn_params A1PTS_USOL.f_spawn_particle) =
    [A1PTS_USOL._activeParticleFlag; A1PTS_USOL._model;
     A1PTS_USOL._behavior] /\
  map fst (fn_params A1PTS_JPOL.f_spawn_particle) =
    [A1PTS_JPOL._activeParticleFlag; A1PTS_JPOL._model;
     A1PTS_JPOL._behavior] /\
  contains_call_forwarding_fourth_temp_s
    A1PTS_USOL._spawn_object_at_origin A1PTS_USOL._behavior
    (fn_body A1PTS_USOL.f_spawn_particle) = true /\
  contains_call_forwarding_fourth_temp_s
    A1PTS_JPOL._spawn_object_at_origin A1PTS_JPOL._behavior
    (fn_body A1PTS_JPOL.f_spawn_particle) = true.

Theorem mario_particle_behaviors_are_list8_source_checked :
  mario_particle_behaviors_are_list8_source_claim.
Proof.
  unfold mario_particle_behaviors_are_list8_source_claim,
    us_mario_particle_behavior_entries,
    jp_mario_particle_behavior_entries,
    contains_particle_behavior_load_then_spawn_s,
    is_particle_behavior_load_then_spawn_s,
    contains_call_forwarding_fourth_temp_s,
    is_call_forwarding_fourth_temp_s.
  vm_compute. repeat split; reflexivity.
Qed.

(** A direct stock Area-1 root reaches a request for a later-list behavior:
    [bhvBreakableBox] -> native loop -> explosion helper -> triangle helper ->
    [spawn_object]
    requesting [bhvBreakBoxTriangle].  Its leading behavior word is
    [12 << 16 = 786432].  The root decoder is total, but this path is only one
    spawn edge; exhaustiveness over all descendants is intentionally open. *)
Definition area1_breakable_triangle_spawn_path_source_claim : Prop :=
  us_area1_macro_mentions_behavior A1PTS_USBD._bhvBreakableBox = true /\
  jp_area1_macro_mentions_behavior A1PTS_JPBD._bhvBreakableBox = true /\
  initializer_list_mentions_addrof A1PTS_USBD._bhv_breakable_box_loop
    (gvar_init A1PTS_USBD.v_bhvBreakableBox) = true /\
  initializer_list_mentions_addrof A1PTS_JPBD._bhv_breakable_box_loop
    (gvar_init A1PTS_JPBD.v_bhvBreakableBox) = true /\
  calls_ident_s A1PTS_USBA._obj_explode_and_spawn_coins
    (fn_body A1PTS_USBA.f_bhv_breakable_box_loop) = true /\
  calls_ident_s A1PTS_JPBA._obj_explode_and_spawn_coins
    (fn_body A1PTS_JPBA.f_bhv_breakable_box_loop) = true /\
  calls_ident_s A1PTS_USOH._spawn_triangle_break_particles
    (fn_body A1PTS_USOH.f_obj_explode_and_spawn_coins) = true /\
  calls_ident_s A1PTS_JPOH._spawn_triangle_break_particles
    (fn_body A1PTS_JPOH.f_obj_explode_and_spawn_coins) = true /\
  calls_ident_with_argument_ident_s
    A1PTS_USBA._spawn_object A1PTS_USBA._bhvBreakBoxTriangle
    (fn_body A1PTS_USBA.f_spawn_triangle_break_particles) = true /\
  calls_ident_with_argument_ident_s
    A1PTS_JPBA._spawn_object A1PTS_JPBA._bhvBreakBoxTriangle
    (fn_body A1PTS_JPBA.f_spawn_triangle_break_particles) = true /\
  calls_ident_s A1PTS_USOH._spawn_object_at_origin
    (fn_body A1PTS_USOH.f_spawn_object) = true /\
  calls_ident_s A1PTS_JPOH._spawn_object_at_origin
    (fn_body A1PTS_JPOH.f_spawn_object) = true /\
  calls_ident_s A1PTS_USOH._create_object
    (fn_body A1PTS_USOH.f_spawn_object_at_origin) = true /\
  calls_ident_s A1PTS_JPOH._create_object
    (fn_body A1PTS_JPOH.f_spawn_object_at_origin) = true /\
  hd_error (gvar_init A1PTS_USBD.v_bhvBreakBoxTriangle) =
    Some (Init_int32 (Int.repr 786432)) /\
  hd_error (gvar_init A1PTS_JPBD.v_bhvBreakBoxTriangle) =
    Some (Init_int32 (Int.repr 786432)).

Theorem area1_breakable_triangle_spawn_path_source_checked :
  area1_breakable_triangle_spawn_path_source_claim.
Proof.
  unfold area1_breakable_triangle_spawn_path_source_claim,
    us_area1_macro_mentions_behavior, jp_area1_macro_mentions_behavior,
    macro_list_mentions_behavior.
  vm_compute. repeat split; reflexivity.
Qed.

Definition us_post_player_fixed_tail_bodies : list Clight.function :=
  [A1PTS_USOL.f_update_objects;
   A1PTS_USOL.f_update_non_terrain_objects;
   A1PTS_USOL.f_update_objects_in_list;
   A1PTS_USOL.f_update_objects_starting_at;
   A1PTS_USOL.f_update_objects_during_time_stop;
   A1PTS_USOL.f_unload_deactivated_objects;
   A1PTS_USOL.f_unload_deactivated_objects_in_list;
   A1PTS_USSO.f_unload_object;
   A1PTS_USPD.f_update_mario_platform].

Definition jp_post_player_fixed_tail_bodies : list Clight.function :=
  [A1PTS_JPOL.f_update_objects;
   A1PTS_JPOL.f_update_non_terrain_objects;
   A1PTS_JPOL.f_update_objects_in_list;
   A1PTS_JPOL.f_update_objects_starting_at;
   A1PTS_JPOL.f_update_objects_during_time_stop;
   A1PTS_JPOL.f_unload_deactivated_objects;
   A1PTS_JPOL.f_unload_deactivated_objects_in_list;
   A1PTS_JPSO.f_unload_object;
   A1PTS_JPPD.f_update_mario_platform].

(** This is a direct-lvalue census over fixed bodies only.  [cur_obj_update]
    deliberately remains outside the list because it dispatches behavior
    scripts and native callbacks.  Pointer aliasing and external calls are
    likewise outside this receiver-neutral generated syntax check. *)
Definition post_player_fixed_tail_direct_writer_claim : Prop :=
  map
    (body_has_direct_named_or_raw_xyz
      A1PTS_USOL._pos A1PTS_USOL._rawData A1PTS_USOL._asF32)
    us_post_player_fixed_tail_bodies = repeat false 9 /\
  map
    (body_has_direct_named_or_raw_xyz
      A1PTS_JPOL._pos A1PTS_JPOL._rawData A1PTS_JPOL._asF32)
    jp_post_player_fixed_tail_bodies = repeat false 9 /\
  ident_subsequenceb
    [A1PTS_USOL._update_mario_platform;
     A1PTS_USOL._try_print_debug_mario_object_info]
    (straightline_callees_s (fn_body A1PTS_USOL.f_update_objects)) = true /\
  ident_subsequenceb
    [A1PTS_JPOL._update_mario_platform;
     A1PTS_JPOL._try_print_debug_mario_object_info]
    (straightline_callees_s (fn_body A1PTS_JPOL.f_update_objects)) = true.

Theorem post_player_fixed_tail_direct_writer_census_checked :
  post_player_fixed_tail_direct_writer_claim.
Proof.
  unfold post_player_fixed_tail_direct_writer_claim,
    us_post_player_fixed_tail_bodies, jp_post_player_fixed_tail_bodies,
    body_has_direct_named_or_raw_xyz,
    body_assigns_named_pos_xyz, body_assigns_raw_xyz.
  vm_compute. repeat split; reflexivity.
Qed.

(** The exact remaining completeness premise.  Static root decoding and the
    one concrete edge above do not establish this relation.  A normal-proof
    closure must supply it (or classify a violating descendant) before it may
    lift the fixed-body census to every live post-player callback. *)
Definition us_post_player_transitive_spawn_residual
    (spawn_reachable : ident -> ident -> Prop)
    (live_behavior : ident -> Prop) : Prop :=
  StockArea1TransitiveBehaviorProvenance
    us_stock_area1_behavior_source spawn_reachable live_behavior.

Definition jp_post_player_transitive_spawn_residual
    (spawn_reachable : ident -> ident -> Prop)
    (live_behavior : ident -> Prop) : Prop :=
  StockArea1TransitiveBehaviorProvenance
    jp_stock_area1_behavior_source spawn_reachable live_behavior.

(** Audit boundary: all concrete source claims hold together.  This
    theorem intentionally does not discharge either transitive residual. *)
Theorem area1_post_player_tail_source_audit_boundary_holds :
  area1_post_player_list_suffix_source_claim /\
  post_player_traversal_and_tail_link_source_claim /\
  mario_post_copy_intra_player_residual_source_claim /\
  mario_particle_behaviors_are_list8_source_claim /\
  area1_breakable_triangle_spawn_path_source_claim /\
  post_player_fixed_tail_direct_writer_claim.
Proof.
  split; [exact area1_post_player_list_suffix_source_checked |].
  split; [exact post_player_traversal_and_tail_link_source_checked |].
  split; [exact mario_post_copy_intra_player_residual_source_checked |].
  split; [exact mario_particle_behaviors_are_list8_source_checked |].
  split; [exact area1_breakable_triangle_spawn_path_source_checked |].
  exact post_player_fixed_tail_direct_writer_census_checked.
Qed.
