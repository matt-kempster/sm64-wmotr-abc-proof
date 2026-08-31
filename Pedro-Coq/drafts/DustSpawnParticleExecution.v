(** UNVERIFIED DRAFT. This file is preserved for review and is not part of _CoqProject. *)
From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import
  us_behavior_data us_object_helpers us_object_list_processor
  jp_behavior_data jp_object_helpers jp_object_list_processor.
From Pedro.Proofs Require Import
  DustLinkedExecution DustLinkedExecutionJP DustParentBitClearExecution.

Import ListNotations.

Module SPUS := us_object_list_processor.
Module SPUSOH := us_object_helpers.
Module SPUSBD := us_behavior_data.
Module SPJP := jp_object_list_processor.
Module SPJPOH := jp_object_helpers.
Module SPJPBD := jp_behavior_data.

(** This proof executes the exact generated [spawn_particle] caller on its
    accepted dust branch.  The two generated callees remain explicit
    [eval_funcall] premises.  In particular, this theorem does not postulate
    an execution of [spawn_object_at_origin]'s first call to
    [segmented_to_virtual], whose N64 flat-address arithmetic is outside
    CompCert's symbolic-block Clight semantics. *)

Definition dust_spawn_flag : int := Int.one.
Definition dust_spawn_model : int := Int.repr 142.
Definition dust_spawn_word_index : Z := 22.

Definition set_dust_spawn_flag (flags : int) : int :=
  Int.or flags dust_spawn_flag.

Definition dust_spawn_flag_is_clear (flags : int) : Prop :=
  Int.and flags dust_spawn_flag = Int.zero.

Definition dust_spawn_flag_is_set (flags : int) : Prop :=
  Int.and flags dust_spawn_flag = dust_spawn_flag.

Lemma set_dust_spawn_flag_is_set :
  forall flags, dust_spawn_flag_is_set (set_dust_spawn_flag flags).
Proof.
  intro flags.
  unfold dust_spawn_flag_is_set, set_dust_spawn_flag, dust_spawn_flag.
  rewrite Int.and_comm, Int.and_or_distrib.
  vm_compute.
  rewrite Int.or_comm, Int.or_zero.
  reflexivity.
Qed.

Lemma us_dust_particle_descriptor_exact :
  firstn 5 (gvar_init SPUS.v_sParticleTypes) =
    [Init_int32 dust_spawn_flag;
     Init_int32 dust_spawn_flag;
     Init_int8 dust_spawn_model;
     Init_space 3;
     Init_addrof SPUS._bhvMistParticleSpawner Ptrofs.zero].
Proof. vm_compute. reflexivity. Qed.

Lemma jp_dust_particle_descriptor_exact :
  firstn 5 (gvar_init SPJP.v_sParticleTypes) =
    [Init_int32 dust_spawn_flag;
     Init_int32 dust_spawn_flag;
     Init_int8 dust_spawn_model;
     Init_space 3;
     Init_addrof SPJP._bhvMistParticleSpawner Ptrofs.zero].
Proof. vm_compute. reflexivity. Qed.

Definition us_spawn_raw_u32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct SPUS._Object noattr)))
        (Tstruct SPUS._Object noattr))
      SPUS._rawData (Tunion SPUS.__764 noattr))
    SPUS._asU32 (tarray tuint 80).

Definition jp_spawn_raw_u32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct SPJP._Object noattr)))
        (Tstruct SPJP._Object noattr))
      SPJP._rawData (Tunion SPJP.__727 noattr))
    SPJP._asU32 (tarray tuint 80).

Definition us_spawn_active_word_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (us_spawn_raw_u32_array_expr object_temp)
      (Econst_int (Int.repr 22) tint) (tptr tuint))
    tuint.

Definition jp_spawn_active_word_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (jp_spawn_raw_u32_array_expr object_temp)
      (Econst_int (Int.repr 22) tint) (tptr tuint))
    tuint.

Lemma us_spawn_raw_u32_offset_stable :
  forall target_env,
    (forall id composite,
      us_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env SPUS._asU32
      us_parent_raw_data_members = OK (0, Full).
Proof.
  intros target_env Hextends.
  assert (Hexact :
      union_field_offset us_dust_comp_env SPUS._asU32
        us_parent_raw_data_members = OK (0, Full))
    by (vm_compute; reflexivity).
  rewrite <- Hexact.
  exact (union_field_offset_stable us_dust_comp_env target_env Hextends
    SPUS._asU32 us_parent_raw_data_members
    us_parent_raw_data_members_complete).
Qed.

Lemma jp_spawn_raw_u32_offset_stable :
  forall target_env,
    (forall id composite,
      jp_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env SPJP._asU32
      jp_parent_raw_data_members = OK (0, Full).
Proof.
  intros target_env Hextends.
  assert (Hexact :
      union_field_offset jp_dust_comp_env SPJP._asU32
        jp_parent_raw_data_members = OK (0, Full))
    by (vm_compute; reflexivity).
  rewrite <- Hexact.
  exact (union_field_offset_stable jp_dust_comp_env target_env Hextends
    SPJP._asU32 jp_parent_raw_data_members
    jp_parent_raw_data_members_complete).
Qed.

Lemma eval_us_spawn_current_object :
  forall (ge : Clight.genv) environment locals memory
      current_block mario_block,
    environment ! SPUS._gCurrentObject = None ->
    Genv.find_symbol ge SPUS._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr mario_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (Evar SPUS._gCurrentObject
        (tptr (Tstruct SPUS._Object noattr)))
      (Vptr mario_block Ptrofs.zero).
Proof.
  intros ge environment locals memory current_block mario_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_jp_spawn_current_object :
  forall (ge : Clight.genv) environment locals memory
      current_block mario_block,
    environment ! SPJP._gCurrentObject = None ->
    Genv.find_symbol ge SPJP._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr mario_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (Evar SPJP._gCurrentObject
        (tptr (Tstruct SPJP._Object noattr)))
      (Vptr mario_block Ptrofs.zero).
Proof.
  intros ge environment locals memory current_block mario_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_us_spawn_raw_u32_array_pointer :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPUS._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPUS._asU32
      (co_members raw_composite) = OK (0, Full) ->
    eval_expr ge environment locals memory
      (us_spawn_raw_u32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr raw_data_byte_offset)).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold us_spawn_raw_u32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr raw_data_byte_offset) with
      (Ptrofs.add (Ptrofs.repr raw_data_byte_offset) Ptrofs.zero)
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := SPUS.__764) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr raw_data_byte_offset) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr raw_data_byte_offset))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := SPUS._Object) (co := object_composite) (att := noattr)
          (delta := raw_data_byte_offset) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef. eapply eval_Etempvar. exact Htemp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- exact Hobject.
        -- exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hraw.
    + exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_jp_spawn_raw_u32_array_pointer :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPJP._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPJP._asU32
      (co_members raw_composite) = OK (0, Full) ->
    eval_expr ge environment locals memory
      (jp_spawn_raw_u32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr raw_data_byte_offset)).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold jp_spawn_raw_u32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr raw_data_byte_offset) with
      (Ptrofs.add (Ptrofs.repr raw_data_byte_offset) Ptrofs.zero)
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := SPJP.__727) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr raw_data_byte_offset) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr raw_data_byte_offset))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := SPJP._Object) (co := object_composite) (att := noattr)
          (delta := raw_data_byte_offset) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef. eapply eval_Etempvar. exact Htemp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- exact Hobject.
        -- exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hraw.
    + exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_us_spawn_active_word_lvalue :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPUS._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPUS._asU32
      (co_members raw_composite) = OK (0, Full) ->
    eval_lvalue ge environment locals memory
      (us_spawn_active_word_lvalue object_temp)
      object_block (Ptrofs.repr active_particle_word_byte_offset) Full.
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold us_spawn_active_word_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - eapply eval_us_spawn_raw_u32_array_pointer; eassumption.
  - constructor.
  - unfold raw_data_byte_offset, active_particle_word_byte_offset.
    cbn. reflexivity.
Qed.

Lemma eval_jp_spawn_active_word_lvalue :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPJP._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPJP._asU32
      (co_members raw_composite) = OK (0, Full) ->
    eval_lvalue ge environment locals memory
      (jp_spawn_active_word_lvalue object_temp)
      object_block (Ptrofs.repr active_particle_word_byte_offset) Full.
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold jp_spawn_active_word_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - eapply eval_jp_spawn_raw_u32_array_pointer; eassumption.
  - constructor.
  - unfold raw_data_byte_offset, active_particle_word_byte_offset.
    cbn. reflexivity.
Qed.

Lemma eval_us_spawn_active_word_value :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite flags,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPUS._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPUS._asU32
      (co_members raw_composite) = OK (0, Full) ->
    Mem.load Mint32 memory object_block active_particle_word_byte_offset =
      Some (Vint flags) ->
    eval_expr ge environment locals memory
      (us_spawn_active_word_lvalue object_temp) (Vint flags).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite flags Htemp Hobject Hraw_offset Hraw
    Harray_offset Hload.
  eapply eval_Elvalue.
  - eapply eval_us_spawn_active_word_lvalue; eassumption.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, active_particle_word_byte_offset.
      exact Hload.
Qed.

Lemma eval_jp_spawn_active_word_value :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite flags,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! SPJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPJP._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPJP._asU32
      (co_members raw_composite) = OK (0, Full) ->
    Mem.load Mint32 memory object_block active_particle_word_byte_offset =
      Some (Vint flags) ->
    eval_expr ge environment locals memory
      (jp_spawn_active_word_lvalue object_temp) (Vint flags).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite flags Htemp Hobject Hraw_offset Hraw
    Harray_offset Hload.
  eapply eval_Elvalue.
  - eapply eval_jp_spawn_active_word_lvalue; eassumption.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, active_particle_word_byte_offset.
      exact Hload.
Qed.

Lemma assign_spawn_active_word :
  forall cenv memory_before memory_after object_block flags,
    Mem.store Mint32 memory_before object_block active_particle_word_byte_offset
      (Vint (set_dust_spawn_flag flags)) = Some memory_after ->
    assign_loc cenv tuint memory_before object_block
      (Ptrofs.repr active_particle_word_byte_offset) Full
      (Vint (set_dust_spawn_flag flags)) memory_after.
Proof.
  intros cenv memory_before memory_after object_block flags Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev, active_particle_word_byte_offset.
    exact Hstore.
Qed.

Definition preserves_spawn_active_word
    (before after : mem) (object_block : block) (flags : int) : Prop :=
  Mem.load Mint32 before object_block active_particle_word_byte_offset =
    Some (Vint flags) ->
  Mem.load Mint32 after object_block active_particle_word_byte_offset =
    Some (Vint flags).


(** Exact US caller execution.  [Hspawn_call] and [Hcopy_call] are executions
    of the generated callees with the exact arguments emitted by
    [f_spawn_particle].  They make the segmented-address boundary explicit
    instead of replacing either callee with a hand-written transition. *)
Theorem us_generated_spawn_particle_accepts_clear_dust_in_any_genv :
  forall (ge : Clight.genv)
      (memory_before memory_flag_set memory_spawned memory_after : mem)
      (current_block mario_block behavior_block spawn_block copy_block
       particle_block : block)
      (object_composite raw_composite : composite) flags,
    Genv.find_symbol ge SPUS._gCurrentObject = Some current_block ->
    Genv.find_symbol ge SPUS._spawn_object_at_origin = Some spawn_block ->
    Genv.find_funct_ptr ge spawn_block =
      Some (Internal SPUSOH.f_spawn_object_at_origin) ->
    Genv.find_symbol ge SPUS._obj_copy_pos_and_angle = Some copy_block ->
    Genv.find_funct_ptr ge copy_block =
      Some (Internal SPUSOH.f_obj_copy_pos_and_angle) ->
    (genv_cenv ge) ! SPUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) SPUS._rawData
      (co_members object_composite) = OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! SPUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) SPUS._asU32
      (co_members raw_composite) = OK (0, Full) ->
    Mem.load Mptr memory_before current_block 0 =
      Some (Vptr mario_block Ptrofs.zero) ->
    Mem.load Mint32 memory_before mario_block
      active_particle_word_byte_offset = Some (Vint flags) ->
    dust_spawn_flag_is_clear flags ->
    current_block <> mario_block ->
    Mem.store Mint32 memory_before mario_block
      active_particle_word_byte_offset
      (Vint (set_dust_spawn_flag flags)) = Some memory_flag_set ->
    eval_funcall function_entry2 ge memory_flag_set
      (Internal SPUSOH.f_spawn_object_at_origin)
      [Vptr mario_block Ptrofs.zero; Vint Int.zero;
       Vint dust_spawn_model; Vptr behavior_block Ptrofs.zero]
      E0 memory_spawned (Vptr particle_block Ptrofs.zero) ->
    Mem.load Mptr memory_spawned current_block 0 =
      Some (Vptr mario_block Ptrofs.zero) ->
    preserves_spawn_active_word memory_flag_set memory_spawned mario_block
      (set_dust_spawn_flag flags) ->
    eval_funcall function_entry2 ge memory_spawned
      (Internal SPUSOH.f_obj_copy_pos_and_angle)
      [Vptr particle_block Ptrofs.zero; Vptr mario_block Ptrofs.zero]
      E0 memory_after Vundef ->
    preserves_spawn_active_word memory_spawned memory_after mario_block
      (set_dust_spawn_flag flags) ->
    eval_funcall function_entry2 ge memory_before
      (Internal SPUS.f_spawn_particle)
      [Vint dust_spawn_flag; Vint dust_spawn_model;
       Vptr behavior_block Ptrofs.zero]
      E0 memory_after Vundef /\
    Mem.load Mint32 memory_after mario_block
      active_particle_word_byte_offset =
      Some (Vint (set_dust_spawn_flag flags)) /\
    dust_spawn_flag_is_set (set_dust_spawn_flag flags).
Proof.
  intros ge memory_before memory_flag_set memory_spawned memory_after
    current_block mario_block behavior_block spawn_block copy_block
    particle_block object_composite raw_composite flags Hcurrent_symbol
    Hspawn_symbol Hspawn_function Hcopy_symbol Hcopy_function Hobject
    Hraw_offset Hraw Harray_offset Hcurrent_before Hflags_before Hclear
    Hcurrent_mario Hstore_flag Hspawn_call Hcurrent_spawned
    Hspawn_preserves Hcopy_call Hcopy_preserves.
  assert (Hcurrent_flag_set :
      Mem.load Mptr memory_flag_set current_block 0 =
        Some (Vptr mario_block Ptrofs.zero)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_flag).
    - exact Hcurrent_before.
    - left. exact Hcurrent_mario. }
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_flag)
    as Hflag_set.
  cbn in Hflag_set.
  assert (Hflag_spawned :
      Mem.load Mint32 memory_spawned mario_block
        active_particle_word_byte_offset =
        Some (Vint (set_dust_spawn_flag flags))).
  { apply Hspawn_preserves. exact Hflag_set. }
  assert (Hflag_after :
      Mem.load Mint32 memory_after mario_block
        active_particle_word_byte_offset =
        Some (Vint (set_dust_spawn_flag flags))).
  { apply Hcopy_preserves. exact Hflag_spawned. }
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * cbn. repeat constructor; congruence.
      * red. intros parameter temporary Hparameter Htemporary Hequal.
        subst temporary.
        cbn in Hparameter, Htemporary.
        intuition congruence.
      * constructor.
      * cbn. reflexivity.
    + cbn [SPUS.f_spawn_particle].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset.
        eapply eval_us_spawn_current_object.
        -- cbn. reflexivity.
        -- exact Hcurrent_symbol.
        -- exact Hcurrent_before.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_us_spawn_active_word_value.
           ++ apply PTree.gss.
           ++ exact Hobject.
           ++ exact Hraw_offset.
           ++ exact Hraw.
           ++ exact Harray_offset.
           ++ exact Hflags_before.
        -- eapply exec_Sifthenelse with (b := true).
           ++ eapply eval_Eunop.
              ** eapply eval_Ebinop.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- eapply eval_Etempvar. cbn. reflexivity.
                 --- cbn. reflexivity.
              ** cbn. rewrite Hclear. reflexivity.
           ++ cbn. reflexivity.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sset.
                     eapply eval_us_spawn_current_object.
                     +++ cbn. reflexivity.
                     +++ exact Hcurrent_symbol.
                     +++ exact Hcurrent_before.
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_us_spawn_current_object.
                         *** cbn. reflexivity.
                         *** exact Hcurrent_symbol.
                         *** exact Hcurrent_before.
                     +++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                         *** eapply exec_Sset.
                             eapply eval_us_spawn_active_word_value.
                             ---- apply PTree.gss.
                             ---- exact Hobject.
                             ---- exact Hraw_offset.
                             ---- exact Hraw.
                             ---- exact Harray_offset.
                             ---- exact Hflags_before.
                         *** eapply exec_Sassign.
                             ---- eapply eval_us_spawn_active_word_lvalue.
                                  ++++ cbn. reflexivity.
                                  ++++ exact Hobject.
                                  ++++ exact Hraw_offset.
                                  ++++ exact Hraw.
                                  ++++ exact Harray_offset.
                             ---- eapply eval_Ebinop.
                                  ++++ eapply eval_Etempvar. apply PTree.gss.
                                  ++++ eapply eval_Etempvar. cbn. reflexivity.
                                  ++++ cbn. reflexivity.
                             ---- cbn. reflexivity.
                             ---- eapply assign_spawn_active_word.
                                  exact Hstore_flag.
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                         *** eapply exec_Sset.
                             eapply eval_us_spawn_current_object.
                             ---- cbn. reflexivity.
                             ---- exact Hcurrent_symbol.
                             ---- exact Hcurrent_flag_set.
                         *** eapply exec_Scall.
                             ---- cbn. reflexivity.
                             ---- eapply eval_linked_function_symbol.
                                  ++++ cbn. reflexivity.
                                  ++++ exact Hspawn_symbol.
                             ---- repeat (eapply eval_Econs).
                                  ++++ eapply eval_Etempvar. apply PTree.gss.
                                  ++++ cbn. reflexivity.
                                  ++++ constructor.
                                  ++++ cbn. reflexivity.
                                  ++++ eapply eval_Etempvar. cbn. reflexivity.
                                  ++++ cbn. reflexivity.
                                  ++++ eapply eval_Etempvar. cbn. reflexivity.
                                  ++++ cbn. reflexivity.
                                  ++++ constructor.
                             ---- eapply find_funct_at_zero_offset.
                                  exact Hspawn_function.
                             ---- cbn. reflexivity.
                             ---- exact Hspawn_call.
                     +++ eapply exec_Sset.
                         eapply eval_Etempvar. apply PTree.gss.
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_us_spawn_current_object.
                         *** cbn. reflexivity.
                         *** exact Hcurrent_symbol.
                         *** exact Hcurrent_spawned.
                     +++ eapply exec_Scall.
                         *** cbn. reflexivity.
                         *** eapply eval_linked_function_symbol.
                             ---- cbn. reflexivity.
                             ---- exact Hcopy_symbol.
                         *** eapply eval_Econs.
                             ---- eapply eval_Etempvar. cbn. reflexivity.
                             ---- cbn. reflexivity.
                             ---- eapply eval_Econs.
                                  ++++ eapply eval_Etempvar. apply PTree.gss.
                                  ++++ cbn. reflexivity.
                                  ++++ constructor.
                         *** eapply find_funct_at_zero_offset.
                             exact Hcopy_function.
                         *** cbn. reflexivity.
                         *** exact Hcopy_call.
    + cbn. reflexivity.
    + cbn. reflexivity.
  - split.
    + exact Hflag_after.
    + apply set_dust_spawn_flag_is_set.
Qed.
