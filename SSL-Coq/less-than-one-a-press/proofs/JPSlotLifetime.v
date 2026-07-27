From Coq Require Import Bool Lia List ZArith.
From compcert Require Import
  AST Clight Ctypes Events Globalenvs Integers Memory Smallstep Values.
From LessThanOneAPress.Generated Require Import
  jp_area jp_level_update jp_object_helpers jp_object_list_processor
  jp_obj_behaviors jp_platform_displacement jp_spawn_object
  jp_macro_special_objects jp_ssl_area2_macro jp_surface_load
  us_ssl_area2_macro us_surface_load.
From LessThanOneAPress.Proofs Require Import
  ASTFacts ClightFacts GameTypes ObjectProvenance CleanEntry AreaTransitions
  ClightRefinement UpperEntrance FirstTargetRefinement.

Import ListNotations.
Local Open Scope Z_scope.

Module JPSLArea := jp_area.
Module JPSLLevel := jp_level_update.
Module JPSLHelpers := jp_object_helpers.
Module JPSLObjects := jp_object_list_processor.
Module JPSLBehaviors := jp_obj_behaviors.
Module JPSLPlatform := jp_platform_displacement.
Module JPSLSpawn := jp_spawn_object.
Module JPSLMacro := jp_macro_special_objects.
Module JPSLArea2Macro := jp_ssl_area2_macro.
Module JPSLSurfaceLoad := jp_surface_load.
Module UPSLArea2Macro := us_ssl_area2_macro.
Module UPSLSurfaceLoad := us_surface_load.

(** This file closes syntax and finite-list parts of the JP delayed-warp
    slot-lifetime investigation.  It does not assert that the stale/reused
    pyramid-top construction is reachable. *)

Definition has_internal_definition
    (needle : ident)
    (definitions : list (ident * globdef Clight.fundef type)) : bool :=
  existsb
    (fun definition =>
      Pos.eqb needle (fst definition) &&
      match snd definition with
      | Gfun (Internal _) => true
      | _ => false
      end)
    definitions.

Definition lhs_is_dynamic_raw_s32_slot
    (raw_data as_s32 index : ident) (lhs : expr) : bool :=
  match lhs with
  | Ederef
      (Ebinop Oadd
        (Efield (Efield _ found_raw _) found_as_s32 _)
        (Etempvar found_index _) _) _ =>
      Pos.eqb found_raw raw_data &&
      Pos.eqb found_as_s32 as_s32 &&
      Pos.eqb found_index index
  | _ => false
  end.

Definition rhs_is_int_zero (rhs : expr) : bool :=
  match rhs with
  | Econst_int value _ => Int.eq value Int.zero
  | _ => false
  end.

Fixpoint assigns_dynamic_raw_s32_zero_s
    (raw_data as_s32 index : ident) (statement : statement) : bool :=
  match statement with
  | Sassign lhs rhs =>
      lhs_is_dynamic_raw_s32_slot raw_data as_s32 index lhs &&
      rhs_is_int_zero rhs
  | Ssequence first second
  | Sloop first second =>
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index first ||
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index second
  | Sifthenelse _ if_true if_false =>
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index if_true ||
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index if_false
  | Sswitch _ cases =>
      assigns_dynamic_raw_s32_zero_ls raw_data as_s32 index cases
  | Slabel _ body =>
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index body
  | _ => false
  end
with assigns_dynamic_raw_s32_zero_ls
    (raw_data as_s32 index : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_dynamic_raw_s32_zero_s raw_data as_s32 index body ||
      assigns_dynamic_raw_s32_zero_ls raw_data as_s32 index rest
  end.

Definition expression_is_field_of_temp
    (owner field : ident) (expression : expr) : bool :=
  match expression with
  | Efield (Ederef (Etempvar found_owner _) _) found_field _ =>
      Pos.eqb found_owner owner && Pos.eqb found_field field
  | _ => false
  end.

Definition lhs_is_field_of_temp
    (owner field : ident) (lhs : expr) : bool :=
  expression_is_field_of_temp owner field lhs.

Definition expression_is_temp
    (expected : ident) (expression : expr) : bool :=
  match expression with
  | Etempvar found _ => Pos.eqb found expected
  | _ => false
  end.

Fixpoint sets_temp_from_field_of_temp_s
    (destination owner field : ident) (statement : statement) : bool :=
  match statement with
  | Sset found rhs =>
      Pos.eqb found destination &&
      expression_is_field_of_temp owner field rhs
  | Ssequence first second
  | Sloop first second =>
      sets_temp_from_field_of_temp_s destination owner field first ||
      sets_temp_from_field_of_temp_s destination owner field second
  | Sifthenelse _ if_true if_false =>
      sets_temp_from_field_of_temp_s destination owner field if_true ||
      sets_temp_from_field_of_temp_s destination owner field if_false
  | Sswitch _ cases =>
      sets_temp_from_field_of_temp_ls destination owner field cases
  | Slabel _ body =>
      sets_temp_from_field_of_temp_s destination owner field body
  | _ => false
  end
with sets_temp_from_field_of_temp_ls
    (destination owner field : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      sets_temp_from_field_of_temp_s destination owner field body ||
      sets_temp_from_field_of_temp_ls destination owner field rest
  end.

Fixpoint assigns_field_of_temp_from_temp_s
    (owner field source : ident) (statement : statement) : bool :=
  match statement with
  | Sassign lhs rhs =>
      lhs_is_field_of_temp owner field lhs &&
      expression_is_temp source rhs
  | Ssequence first second
  | Sloop first second =>
      assigns_field_of_temp_from_temp_s owner field source first ||
      assigns_field_of_temp_from_temp_s owner field source second
  | Sifthenelse _ if_true if_false =>
      assigns_field_of_temp_from_temp_s owner field source if_true ||
      assigns_field_of_temp_from_temp_s owner field source if_false
  | Sswitch _ cases =>
      assigns_field_of_temp_from_temp_ls owner field source cases
  | Slabel _ body =>
      assigns_field_of_temp_from_temp_s owner field source body
  | _ => false
  end
with assigns_field_of_temp_from_temp_ls
    (owner field source : ident)
    (cases : labeled_statements) : bool :=
  match cases with
  | LSnil => false
  | LScons _ body rest =>
      assigns_field_of_temp_from_temp_s owner field source body ||
      assigns_field_of_temp_from_temp_ls owner field source rest
  end.

(** [surface_load.c] was previously outside the generated program set.  These
    checks establish that both versions now contain an internal
    [load_area_terrain], rather than an unconstrained external declaration. *)
Definition surface_load_translation_coverage_claim : Prop :=
  has_internal_definition JPSLSurfaceLoad._load_area_terrain
    JPSLSurfaceLoad.global_definitions = true /\
  has_internal_definition UPSLSurfaceLoad._load_area_terrain
    UPSLSurfaceLoad.global_definitions = true /\
  calls_ident_s JPSLSurfaceLoad._spawn_special_objects
    (fn_body JPSLSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s JPSLSurfaceLoad._spawn_macro_objects_hardcoded
    (fn_body JPSLSurfaceLoad.f_load_area_terrain) = true /\
  calls_ident_s JPSLSurfaceLoad._spawn_macro_objects
    (fn_body JPSLSurfaceLoad.f_load_area_terrain) = true.

Theorem surface_load_translation_coverage_checked :
  surface_load_translation_coverage_claim.
Proof. vm_compute. repeat split. Qed.

(** Direct-call and mutation anchors for the actual JP allocation path.
    The theorem is syntactic.  Turning it into a memory trace is isolated
    below as [JPCleanUpperPlatformApplyMemoryRefinementObligation]. *)
Definition jp_delayed_warp_slot_source_claim : Prop :=
  ident_subsequenceb
    [JPSLArea._load_area_terrain; JPSLArea._spawn_objects_from_info]
    (direct_callees_s (fn_body JPSLArea.f_load_area)) = true /\
  calls_ident_s JPSLObjects._create_object
    (fn_body JPSLObjects.f_spawn_objects_from_info) = true /\
  calls_ident_s JPSLMacro._spawn_object_abs_with_rot
    (fn_body JPSLMacro.f_spawn_macro_objects) = true /\
  calls_ident_s JPSLHelpers._spawn_object_at_origin
    (fn_body JPSLHelpers.f_spawn_object_abs_with_rot) = true /\
  calls_ident_s JPSLHelpers._create_object
    (fn_body JPSLHelpers.f_spawn_object_at_origin) = true /\
  calls_ident_s JPSLSpawn._allocate_object
    (fn_body JPSLSpawn.f_create_object) = true /\
  calls_ident_s JPSLSpawn._try_allocate_object
    (fn_body JPSLSpawn.f_allocate_object) = true /\
  calls_ident_s JPSLSpawn._deallocate_object
    (fn_body JPSLSpawn.f_unload_object) = true /\
  statement_mentions_ident_s JPSLSpawn._rawData
    (fn_body JPSLSpawn.f_unload_object) = false /\
  statement_mentions_ident_s JPSLSpawn._rawData
    (fn_body JPSLSpawn.f_deallocate_object) = false /\
  sets_temp_from_field_of_temp_s
    JPSLSpawn._t'1 JPSLSpawn._freeList JPSLSpawn._next
    (fn_body JPSLSpawn.f_deallocate_object) = true /\
  assigns_field_of_temp_from_temp_s
    JPSLSpawn._obj JPSLSpawn._next JPSLSpawn._t'1
    (fn_body JPSLSpawn.f_deallocate_object) = true /\
  assigns_field_of_temp_from_temp_s
    JPSLSpawn._freeList JPSLSpawn._next JPSLSpawn._obj
    (fn_body JPSLSpawn.f_deallocate_object) = true /\
  sets_temp_from_field_of_temp_s
    JPSLSpawn._t'5 JPSLSpawn._freeList JPSLSpawn._next
    (fn_body JPSLSpawn.f_try_allocate_object) = true /\
  sets_temp_from_field_of_temp_s
    JPSLSpawn._t'4 JPSLSpawn._nextObj JPSLSpawn._next
    (fn_body JPSLSpawn.f_try_allocate_object) = true /\
  assigns_field_of_temp_from_temp_s
    JPSLSpawn._freeList JPSLSpawn._next JPSLSpawn._t'4
    (fn_body JPSLSpawn.f_try_allocate_object) = true /\
  assigns_dynamic_raw_s32_zero_s
    JPSLSpawn._rawData JPSLSpawn._asS32 JPSLSpawn._i
    (fn_body JPSLSpawn.f_allocate_object) = true /\
  statement_mentions_int_s 80
    (fn_body JPSLSpawn.f_allocate_object) = true /\
  statement_contains_loop_s
    (fn_body JPSLSpawn.f_allocate_object) = true /\
  ident_subsequenceb
    [JPSLLevel._warp_area; JPSLLevel._area_update_objects]
    (direct_callees_s (fn_body JPSLLevel.f_play_mode_normal)) = true /\
  ident_subsequenceb
    [JPSLObjects._apply_mario_platform_displacement;
     JPSLObjects._update_mario_platform]
    (direct_callees_s (fn_body JPSLObjects.f_update_objects)) = true /\
  calls_ident_s UOL._clear_mario_platform
    (fn_body JPSLObjects.f_spawn_objects_from_info) = false /\
  calls_ident_s JPSLObjects._update_mario_platform
    (fn_body JPSLArea.f_load_area) = false /\
  calls_ident_s JPSLObjects._update_mario_platform
    (fn_body JPSLSurfaceLoad.f_load_area_terrain) = false /\
  statement_mentions_ident_s JPSLPlatform._gMarioPlatform
    (fn_body JPSLPlatform.f_apply_mario_platform_displacement) = true /\
  statement_mentions_ident_s JPSLPlatform._activeFlags
    (fn_body JPSLPlatform.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s JPSLPlatform._behavior
    (fn_body JPSLPlatform.f_apply_mario_platform_displacement) = false /\
  statement_mentions_ident_s JPSLPlatform._collisionData
    (fn_body JPSLPlatform.f_apply_mario_platform_displacement) = false /\
  calls_ident_s JPSLBehaviors._spawn_object
    (fn_body JPSLBehaviors.f_bhv_pyramid_top_explode) = true /\
  statement_mentions_int_s 30
    (fn_body JPSLBehaviors.f_bhv_pyramid_top_explode) = true /\
  assigns_field_named_s JPSLBehaviors._activeFlags
    (fn_body JPSLBehaviors.f_bhv_pyramid_top_explode) = true.

Theorem jp_delayed_warp_slot_source_checked :
  jp_delayed_warp_slot_source_claim.
Proof. vm_compute. repeat split. Qed.

(** Concrete layout anchor for the generated JP allocation unit.  The
    first-apply evidence separately requires the same size in the eventual
    linked [projection_program]; link-order alone is not silently used as that
    composite-layout refinement. *)
Definition jp_spawn_object_size_claim : Prop :=
  Ctypes.sizeof
    (prog_comp_env JPSLSpawn.prog)
    (Tstruct JPSLSpawn._Object noattr) = 608.

Theorem jp_spawn_object_size_checked :
  jp_spawn_object_size_claim.
Proof. vm_compute. reflexivity. Qed.

(** The packed Area-2 macro list contains fifty complete five-word records.
    The trailing end marker is deliberately excluded by [chunks5].  This is
    an input bound, not an allocation count: respawn filtering, special
    objects, SpawnInfo objects, and first terrain-object updates still have
    to be represented by the execution refinement. *)
Definition area2_macro_record_count_claim : Prop :=
  length
    (chunks5
      (init_int16_values
        (gvar_init JPSLArea2Macro.v_ssl_seg7_area_2_macro_objs))) = 50%nat /\
  length
    (chunks5
      (init_int16_values
        (gvar_init UPSLArea2Macro.v_ssl_seg7_area_2_macro_objs))) = 50%nat /\
  init_int16_values
    (gvar_init JPSLArea2Macro.v_ssl_seg7_area_2_macro_objs) =
  init_int16_values
    (gvar_init UPSLArea2Macro.v_ssl_seg7_area_2_macro_objs).

Theorem area2_macro_record_count_checked :
  area2_macro_record_count_claim.
Proof. vm_compute. repeat split. Qed.

(** The generated bodies contain the assignment shapes expected for a
    free-list head push and pop.  Pending their memory/execution refinement,
    the corresponding finite-list recurrence below proves that if [watched]
    is freed first and [bulk] is then freed in list order, all bulk slots
    precede [watched]. *)
Definition free_list_after_early_release
    {Slot : Type} (initial bulk : list Slot) (watched : Slot) : list Slot :=
  rev bulk ++ watched :: initial.

Theorem early_released_slot_has_exact_lifo_depth :
  forall (Slot : Type) (initial bulk : list Slot) (watched : Slot),
    nth_error (free_list_after_early_release initial bulk watched)
      (length bulk) = Some watched.
Proof.
  intros Slot initial bulk watched.
  unfold free_list_after_early_release.
  rewrite nth_error_app2.
  - rewrite rev_length, Nat.sub_diag. reflexivity.
  - rewrite rev_length. lia.
Qed.

Theorem allocations_before_watched_slot_are_exactly_bulk :
  forall (Slot : Type) (initial bulk : list Slot) (watched : Slot),
    firstn (length bulk)
      (free_list_after_early_release initial bulk watched) = rev bulk.
Proof.
  intros Slot initial bulk watched.
  unfold free_list_after_early_release.
  rewrite firstn_app.
  rewrite firstn_all2 by (rewrite rev_length; lia).
  rewrite rev_length, Nat.sub_diag.
  now rewrite app_nil_r.
Qed.

Theorem watched_slot_is_next_after_bulk_allocations :
  forall (Slot : Type) (initial bulk : list Slot) (watched : Slot),
    skipn (length bulk)
      (free_list_after_early_release initial bulk watched) =
    watched :: initial.
Proof.
  intros Slot initial bulk watched.
  unfold free_list_after_early_release.
  rewrite skipn_app.
  rewrite skipn_all2 by (rewrite rev_length; lia).
  now rewrite rev_length, Nat.sub_diag.
Qed.

(** There is no fourth abstract pointer state.  For a clean JP upper entry,
    a retained non-null pointer identifies one current in-bounds slot, and
    that slot is live in the captured epoch, inactive in the captured epoch,
    or has a different (reused) epoch. *)
Theorem clean_jp_upper_retained_slot_exact_classification :
  forall state platform,
    CleanPyramidEntry state ->
    state_entrance state = UpperEntrance ->
    state_version state = VersionJP ->
    state_mario_platform state = Some platform ->
    exists current,
      nth_error (state_object_pool state) (platform_slot platform) =
        Some current /\
      object_slot (object_ref current) = platform_slot platform /\
      ((object_active current = true /\
        object_epoch (object_ref current) =
          platform_captured_epoch platform) \/
       (object_active current = false /\
        object_epoch (object_ref current) =
          platform_captured_epoch platform) \/
       object_epoch (object_ref current) <>
          platform_captured_epoch platform).
Proof.
  intros state platform Hclean Hentrance Hversion Hplatform.
  pose proof
    (clean_jp_upper_platform_cases_are_exhaustive
      state Hclean Hentrance Hversion) as Hcases.
  rewrite Hplatform in Hcases.
  destruct Hcases as [Hnone | (found & Hfound & Hcase)].
  - discriminate.
  - inversion Hfound; subst found.
    destruct Hcase as
      [current Hlookup Hslot Hactive Hepoch
      |current Hlookup Hslot Hactive Hepoch
      |current Hlookup Hslot Hepoch].
    + exists current. repeat split; auto.
    + exists current. repeat split; auto.
    + exists current. repeat split; auto.
Qed.

(** Nonzero signed-16 pitch or roll angular velocity is one sufficient family
    of non-yaw-only rotation deltas.  It is not necessary for every
    Y-changing transform: a fixed nonzero face pitch/roll combined with a yaw
    delta can also change Y.  The stock pyramid-top source path has neither
    such face tilt nor a pitch/roll delta; connecting those source facts to a
    concrete payload remains part of the memory refinement below. *)
Definition payload_has_pitch_or_roll_delta
    (payload : PlatformDisplacementRawPayload) : Prop :=
  platform_payload_rotation_pitch_s16 payload <> Int.zero \/
  platform_payload_rotation_roll_s16 payload <> Int.zero.

Theorem zero_pitch_and_roll_delta_excludes_that_writer_family :
  forall payload,
    platform_payload_rotation_pitch_s16 payload = Int.zero ->
    platform_payload_rotation_roll_s16 payload = Int.zero ->
    ~ payload_has_pitch_or_roll_delta payload.
Proof.
  intros payload Hpitch Hroll [Hpitch' | Hroll'].
  - exact (Hpitch' Hpitch).
  - exact (Hroll' Hroll).
Qed.

Definition clight_state_executes_function
    (function : Clight.function) (state : Clight.state) : Prop :=
  match state with
  | Clight.State current _ _ _ _ _ => current = function
  | _ => False
  end.

(** Function entry is narrower than merely being somewhere in a function
    body.  The first-Area-2 control-point evidence below selects this state
    and separately excludes an earlier entry on the same concrete run. *)
Definition clight_state_enters_function
    (function : Clight.function) (state : Clight.state) : Prop :=
  match state with
  | Clight.State current body _ _ _ _ =>
      current = function /\ body = fn_body function
  | _ => False
  end.

Definition clight_run_plus
    (run : ImportedClightRun)
    (before : Clight.state) (trace : Events.trace)
    (after : Clight.state) : Prop :=
  @Smallstep.plus _ _ Clight.step2
    (Clight.globalenv (run_program run)) before trace after.

(** A concrete first-entry witness.  The frame evidence aligns the selected
    Clight state with one indexed projected event.  The [plus] premise in
    [jp_first_apply_no_earlier_entry] rules out selecting an arbitrary later
    invocation of the function.  Constructing this record is pending. *)
Record JPFirstArea2PlatformApplyControlPointEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (apply_state : Clight.state) : Type := {
  jp_first_apply_frame_index : nat;
  jp_first_apply_frame_event : FrameEvent;
  jp_first_apply_before : GameState;
  jp_first_apply_after : GameState;
  jp_first_apply_frame_evidence :
    ClightFrameEvidence projection run initial certificate
      jp_first_apply_frame_index jp_first_apply_frame_event
      jp_first_apply_before jp_first_apply_after;
  jp_first_apply_frame_prefix : Events.trace;
  jp_first_apply_frame_suffix : Events.trace;
  jp_first_apply_frame_trace_split :
    frame_segment_trace
      projection run initial certificate
      jp_first_apply_frame_index jp_first_apply_frame_event
      jp_first_apply_before jp_first_apply_after
      jp_first_apply_frame_evidence =
    jp_first_apply_frame_prefix ++ jp_first_apply_frame_suffix;
  jp_first_apply_steps_from_frame_before :
    clight_run_star run
      (frame_before_clight
        projection run initial certificate
        jp_first_apply_frame_index jp_first_apply_frame_event
        jp_first_apply_before jp_first_apply_after
        jp_first_apply_frame_evidence)
      jp_first_apply_frame_prefix apply_state;
  jp_first_apply_steps_to_frame_after :
    clight_run_star run apply_state jp_first_apply_frame_suffix
      (frame_after_clight
        projection run initial certificate
        jp_first_apply_frame_index jp_first_apply_frame_event
        jp_first_apply_before jp_first_apply_after
        jp_first_apply_frame_evidence);
  jp_first_apply_prefix : Events.trace;
  jp_first_apply_suffix : Events.trace;
  jp_first_apply_prefix_alignment :
    jp_first_apply_prefix =
      frame_prefix_trace
        projection run initial certificate
        jp_first_apply_frame_index jp_first_apply_frame_event
        jp_first_apply_before jp_first_apply_after
        jp_first_apply_frame_evidence ++
      jp_first_apply_frame_prefix;
  jp_first_apply_suffix_alignment :
    jp_first_apply_suffix =
      jp_first_apply_frame_suffix ++
      frame_suffix_trace
        projection run initial certificate
        jp_first_apply_frame_index jp_first_apply_frame_event
        jp_first_apply_before jp_first_apply_after
        jp_first_apply_frame_evidence;
  jp_first_apply_trace_split :
    run_trace run = jp_first_apply_prefix ++ jp_first_apply_suffix;
  jp_first_apply_reachable :
    clight_run_star run (run_start run)
      jp_first_apply_prefix apply_state;
  jp_first_apply_reaches_final :
    clight_run_star run apply_state
      jp_first_apply_suffix (run_final run);
  jp_first_apply_is_function_entry :
    clight_state_enters_function
      JPSLPlatform.f_apply_mario_platform_displacement apply_state;
  jp_first_apply_no_earlier_entry :
    forall earlier prefix_to_earlier trace_to_apply,
      clight_run_star run (run_start run) prefix_to_earlier earlier ->
      clight_run_plus run earlier trace_to_apply apply_state ->
      ~ clight_state_enters_function
          JPSLPlatform.f_apply_mario_platform_displacement earlier
}.

(** The concrete pointer-to-slot refinement that the former evidence record
    omitted.  It ties the object pointer loaded from [gMarioPlatform] to the
    linked [gObjectPool] block, the generated [struct Object] size, the
    abstract slot number, and the exact current abstract pool element.

    This is a pending evidence type, not a theorem that the projection already
    has these properties. *)
Record JPConcretePlatformSlotProjectionEvidence
    (projection : ClightObservationProjection)
    (abstract_state : GameState)
    (platform : RawPlatformPointer)
    (current : ObjectState)
    (object_block : Values.block)
    (object_offset : Ptrofs.int) : Type := {
  jp_slot_current_lookup :
    nth_error (state_object_pool abstract_state)
      (platform_slot platform) = Some current;
  jp_slot_current_number :
    object_slot (object_ref current) = platform_slot platform;
  jp_slot_pool_global_block : Values.block;
  jp_slot_pool_global_symbol :
    Genv.find_symbol (Clight.globalenv (projection_program projection))
      JPSLSpawn._gObjectPool = Some jp_slot_pool_global_block;
  jp_slot_object_block_is_pool_block :
    object_block = jp_slot_pool_global_block;
  jp_slot_linked_object_size :
    Ctypes.sizeof
      (prog_comp_env (projection_program projection))
      (Tstruct JPSLSpawn._Object noattr) = 608;
  jp_slot_object_offset_is_array_index :
    Ptrofs.unsigned object_offset =
      Z.of_nat (platform_slot platform) *
      Ctypes.sizeof
        (prog_comp_env (projection_program projection))
        (Tstruct JPSLSpawn._Object noattr)
}.

Definition event_reuses_platform_slot
    (platform : RawPlatformPointer) (event : FrameEvent) : Prop :=
  exists old_object new_object,
    event = EventReuseSlot old_object new_object /\
    object_slot (object_ref old_object) = platform_slot platform /\
    object_slot (object_ref new_object) = platform_slot platform.

(** Ghost epochs do not occur in C memory.  Their remaining refinement is
    therefore stated explicitly against the projected reuse-event prefix,
    rather than being silently inferred from the concrete pointer load. *)
Inductive JPProjectedPlatformEpochLineage
    (platform : RawPlatformPointer)
    (current : ObjectState)
    (events : list FrameEvent)
    (through_index : nat) : Prop :=
| JPProjectedEpochRetained :
    object_epoch (object_ref current) =
      platform_captured_epoch platform ->
    (forall index event,
      (index < through_index)%nat ->
      nth_error events index = Some event ->
      ~ event_reuses_platform_slot platform event) ->
    JPProjectedPlatformEpochLineage
      platform current events through_index
| JPProjectedEpochReused : forall index old_object,
    (index < through_index)%nat ->
    nth_error events index =
      Some (EventReuseSlot old_object current) ->
    object_epoch (object_ref old_object) =
      platform_captured_epoch platform ->
    fresh_slot_reuse old_object current ->
    JPProjectedPlatformEpochLineage
      platform current events through_index.

(** Remaining first-apply pointer/payload evidence.  It lives in [Type]
    because the exact CompCert load witness carries blocks and offsets, rather
    than erasing those data into an existential proposition.  Its fields keep
    four formerly conflated tasks separate:

    - select the first destination-area function entry;
    - project the exact abstract state at that entry;
    - relate the concrete pool pointer to the abstract slot/current object;
    - justify the ghost epoch by the projected reuse history.

    No constructor is supplied here. *)
Record JPCleanUpperPlatformApplyMemoryEvidence
    (projection : ClightObservationProjection)
    (run : ImportedClightRun)
    (initial : GameState)
    (certificate : ClightFrameRefinementCertificate projection run initial)
    (platform : RawPlatformPointer)
    (apply_state : Clight.state) : Type := {
  jp_apply_first_control_point :
    JPFirstArea2PlatformApplyControlPointEvidence
      projection run initial certificate apply_state;
  jp_apply_abstract_state : GameState;
  jp_apply_payload : PlatformDisplacementRawPayload;
  jp_apply_current_object : ObjectState;
  jp_apply_projected_state :
    project_state projection apply_state = Some jp_apply_abstract_state;
  jp_apply_projected_platform :
    state_mario_platform jp_apply_abstract_state = Some platform;
  jp_apply_projected_area :
    state_area jp_apply_abstract_state = pyramid_area_id;
  jp_apply_payload_memory :
    PlatformDisplacementPayloadMemoryWitness
      (projection_program projection) apply_state jp_apply_payload;
  jp_apply_pointer_slot_projection :
    JPConcretePlatformSlotProjectionEvidence
      projection jp_apply_abstract_state platform jp_apply_current_object
      (platform_payload_object_block
        (projection_program projection) apply_state jp_apply_payload
        jp_apply_payload_memory)
      (platform_payload_object_offset
        (projection_program projection) apply_state jp_apply_payload
        jp_apply_payload_memory);
  jp_apply_current_position_matches_payload :
    object_position jp_apply_current_object =
      platform_payload_position jp_apply_payload;
  jp_apply_current_epoch_case :
    (object_active jp_apply_current_object = true /\
     object_epoch (object_ref jp_apply_current_object) =
       platform_captured_epoch platform) \/
    (object_active jp_apply_current_object = false /\
     object_epoch (object_ref jp_apply_current_object) =
       platform_captured_epoch platform) \/
    object_epoch (object_ref jp_apply_current_object) <>
      platform_captured_epoch platform;
  jp_apply_epoch_lineage :
    JPProjectedPlatformEpochLineage
      platform jp_apply_current_object (project_events projection run)
      (S
        (jp_first_apply_frame_index
          projection run initial certificate apply_state
          jp_apply_first_control_point))
}.

(** Remaining linked-memory theorem.  The explicit control-point premise
    requires the selected finite run horizon to contain its proved-first
    Area-2 entry into [apply_mario_platform_displacement]; a truncated run is
    therefore outside this obligation.  Given that entry, the obligation
    extracts the concrete pointer, payload, slot, and epoch-lineage evidence.
    It does not demand that the initial retained pointer survive every later
    invocation after [update_mario_platform] has run. *)
Definition JPFirstArea2PlatformApplyMemoryRefinementObligation
    (projection : ClightObservationProjection) : Type :=
  forall run initial
      (certificate : ClightFrameRefinementCertificate projection run initial)
      platform apply_state,
    CleanPyramidEntry initial ->
    state_version initial = VersionJP ->
    state_entrance initial = UpperEntrance ->
    state_mario_platform initial = Some platform ->
    RunUsesProjection projection run ->
    JPFirstArea2PlatformApplyControlPointEvidence
      projection run initial certificate apply_state ->
    JPCleanUpperPlatformApplyMemoryEvidence
      projection run initial certificate platform apply_state.

(** Compatibility name used by the surrounding documentation.  Its
    definition is now the narrowed first-Area-2-apply memory obligation
    above. *)
Definition JPCleanUpperPlatformApplyMemoryRefinementObligation :=
  JPFirstArea2PlatformApplyMemoryRefinementObligation.

(** Exact count trichotomy for the pending execution extraction.  [Before]
    leaves later bulk slots ahead of the watched slot, [WatchedIsNext] means
    the watched slot is the free-list head but has not yet been popped, and
    [AlreadyAllocated] means it was selected earlier.  The remaining Clight
    task is to extract the concrete [bulk] and [preapply_allocations] and
    thereby determine which constructor applies. *)
Inductive JPPreapplyAllocationCountCase
    (bulk_count preapply_allocations : nat) : Prop :=
| JPAllocationsBeforeWatchedHead :
    (preapply_allocations < bulk_count)%nat ->
    JPPreapplyAllocationCountCase bulk_count preapply_allocations
| JPWatchedIsNextAllocation :
    preapply_allocations = bulk_count ->
    JPPreapplyAllocationCountCase bulk_count preapply_allocations
| JPWatchedAlreadyAllocated :
    (bulk_count < preapply_allocations)%nat ->
    JPPreapplyAllocationCountCase bulk_count preapply_allocations.

Theorem jp_preapply_allocation_count_cases_are_exhaustive :
  forall bulk_count preapply_allocations,
    JPPreapplyAllocationCountCase bulk_count preapply_allocations.
Proof.
  intros bulk_count preapply_allocations.
  destruct (Nat.lt_trichotomy preapply_allocations bulk_count)
    as [Hbefore | [Hat | Hafter]].
  - now constructor 1.
  - now constructor 2.
  - now constructor 3.
Qed.

(** The useful "earlier allocations cannot be [watched]" consequence also
    needs the object pool's no-duplicate free-list invariant.  We prove that
    exact conditional finite-list form here. *)
Theorem jp_preapply_allocations_do_not_reuse_watched_under_nodup :
  forall (Slot : Type) (initial bulk : list Slot) (watched : Slot)
      (preapply_allocations : nat),
    NoDup (free_list_after_early_release initial bulk watched) ->
    (preapply_allocations < length bulk)%nat ->
    nth_error
      (free_list_after_early_release initial bulk watched)
      preapply_allocations <> Some watched.
Proof.
  intros Slot initial bulk watched preapply_allocations Hnodup Hlt.
  intro Hequal.
  pose proof
    (early_released_slot_has_exact_lifo_depth
      Slot initial bulk watched) as Hdepth.
  pose proof
    (proj1
      (NoDup_nth_error
        (free_list_after_early_release initial bulk watched))
      Hnodup preapply_allocations (length bulk)) as Hunique.
  assert
    (Hpreapply_in_bounds :
      (preapply_allocations <
        length (free_list_after_early_release initial bulk watched))%nat).
  {
    unfold free_list_after_early_release.
    rewrite app_length, rev_length. simpl. lia.
  }
  specialize (Hunique Hpreapply_in_bounds).
  assert
    (Hsame_lookup :
      nth_error
        (free_list_after_early_release initial bulk watched)
        preapply_allocations =
      nth_error
        (free_list_after_early_release initial bulk watched)
        (length bulk)).
  {
    rewrite Hequal, Hdepth. reflexivity.
  }
  specialize (Hunique Hsame_lookup).
  lia.
Qed.

(** Checked staging boundary for this file.  [MainTheorem] now exposes it only
    as a separate conjunct on the verification spine, not as a delayed-warp
    retention theorem or a semantic bridge to collection.  Source coverage,
    the exact packed-data count, the finite LIFO recurrence, and clean-entry
    abstract case exhaustiveness are discharged.  The definitions above name
    the concrete first-apply pointer/payload and allocation work that remains.
*)
Definition JPDelayedWarpSlotBoundaryClaim : Prop :=
  surface_load_translation_coverage_claim /\
  jp_delayed_warp_slot_source_claim /\
  jp_spawn_object_size_claim /\
  area2_macro_record_count_claim /\
  (forall (Slot : Type) (initial bulk : list Slot) (watched : Slot),
    nth_error (free_list_after_early_release initial bulk watched)
      (length bulk) = Some watched) /\
  (forall state platform,
    CleanPyramidEntry state ->
    state_entrance state = UpperEntrance ->
    state_version state = VersionJP ->
    state_mario_platform state = Some platform ->
    RawPlatformSlotCase (state_object_pool state) platform).

Theorem jp_delayed_warp_slot_boundary_checked :
  JPDelayedWarpSlotBoundaryClaim.
Proof.
  unfold JPDelayedWarpSlotBoundaryClaim.
  split; [exact surface_load_translation_coverage_checked |].
  split; [exact jp_delayed_warp_slot_source_checked |].
  split; [exact jp_spawn_object_size_checked |].
  split; [exact area2_macro_record_count_checked |].
  split; [exact early_released_slot_has_exact_lifo_depth |].
  intros state platform Hclean Hentrance Hversion Hplatform.
  pose proof
    (clean_jp_upper_platform_cases_are_exhaustive
      state Hclean Hentrance Hversion) as Hcases.
  rewrite Hplatform in Hcases.
  destruct Hcases as [Hnone | (found & Hfound & Hcase)].
  - discriminate.
  - inversion Hfound. exact Hcase.
Qed.
