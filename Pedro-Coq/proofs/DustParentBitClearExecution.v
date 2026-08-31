From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Errors Events Globalenvs Integers Maps Memory Values.
From Pedro.Generated Require Import
  us_behavior_data us_behavior_script
  jp_behavior_data jp_behavior_script.
Import ListNotations.

Module PBCUS := us_behavior_script.
Module PBCUSBD := us_behavior_data.
Module PBCJP := jp_behavior_script.
Module PBCJPBD := jp_behavior_data.

(** This file executes only the generated [PARENT_BIT_CLEAR] handler.  It
    deliberately takes an arbitrary Clight global environment and states the
    exact global-symbol, composite-layout, load, and store facts that the
    handler needs.  It does not claim that a retail TTC snapshot has already
    been refined into a CompCert memory. *)

Definition parent_object_byte_offset : Z := 104.
Definition raw_data_byte_offset : Z := 136.
Definition active_particle_word_byte_offset : Z := 224.

Definition mist_parent_clear_command_offset : ptrofs := Ptrofs.repr 4.
Definition mist_parent_clear_value_offset : Z := 8.
Definition mist_parent_clear_next_offset : ptrofs := Ptrofs.repr 12.

Definition parent_bit_clear_command_word : int := Int.repr 857079808.
Definition dust_active_bit : int := Int.one.
Definition dust_clear_mask : int :=
  Int.xor dust_active_bit (Int.repr (-1)).
Definition clear_dust_active_bit (flags : int) : int :=
  Int.and flags dust_clear_mask.

Definition dust_active_bit_is_set (flags : int) : Prop :=
  Int.and flags dust_active_bit = dust_active_bit.

Definition dust_active_bit_is_clear (flags : int) : Prop :=
  Int.and flags dust_active_bit = Int.zero.

Lemma dust_clear_mask_is_not_one :
  dust_clear_mask = Int.not dust_active_bit.
Proof. reflexivity. Qed.

Lemma clear_dust_active_bit_is_clear :
  forall flags, dust_active_bit_is_clear (clear_dust_active_bit flags).
Proof.
  intro flags.
  unfold dust_active_bit_is_clear, clear_dust_active_bit.
  rewrite dust_clear_mask_is_not_one.
  rewrite Int.and_assoc.
  rewrite (Int.and_commut (Int.not dust_active_bit) dust_active_bit).
  rewrite Int.and_not_self.
  apply Int.and_zero.
Qed.

Lemma us_mist_parent_bit_clear_initializer_exact :
  nth_error (gvar_init PBCUSBD.v_bhvMistParticleSpawner) 1 =
    Some (Init_int32 parent_bit_clear_command_word) /\
  nth_error (gvar_init PBCUSBD.v_bhvMistParticleSpawner) 2 =
    Some (Init_int32 dust_active_bit).
Proof. vm_compute. split; reflexivity. Qed.

Lemma jp_mist_parent_bit_clear_initializer_exact :
  nth_error (gvar_init PBCJPBD.v_bhvMistParticleSpawner) 1 =
    Some (Init_int32 parent_bit_clear_command_word) /\
  nth_error (gvar_init PBCJPBD.v_bhvMistParticleSpawner) 2 =
    Some (Init_int32 dust_active_bit).
Proof. vm_compute. split; reflexivity. Qed.

Lemma parent_bit_clear_command_field_exact :
  Int.and (Int.shru parent_bit_clear_command_word (Int.repr 16))
    (Int.repr 255) = Int.repr 22.
Proof. vm_compute. reflexivity. Qed.

Lemma generated_parent_bit_clear_mask_exact :
  Int.xor dust_active_bit (Int.repr (-1)) = dust_clear_mask.
Proof. reflexivity. Qed.

Lemma generated_parent_bit_clear_mask_unsigned :
  Int.unsigned dust_clear_mask = 4294967294%Z.
Proof. vm_compute. reflexivity. Qed.

Definition us_parent_object_expr (object_temp : ident) : expr :=
  Efield
    (Ederef
      (Etempvar object_temp (tptr (Tstruct PBCUS._Object noattr)))
      (Tstruct PBCUS._Object noattr))
    PBCUS._parentObj (tptr (Tstruct PBCUS._Object noattr)).

Definition jp_parent_object_expr (object_temp : ident) : expr :=
  Efield
    (Ederef
      (Etempvar object_temp (tptr (Tstruct PBCJP._Object noattr)))
      (Tstruct PBCJP._Object noattr))
    PBCJP._parentObj (tptr (Tstruct PBCJP._Object noattr)).

Definition us_object_raw_s32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct PBCUS._Object noattr)))
        (Tstruct PBCUS._Object noattr))
      PBCUS._rawData (Tunion PBCUS.__764 noattr))
    PBCUS._asS32 (tarray tint 80).

Definition jp_object_raw_s32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct PBCJP._Object noattr)))
        (Tstruct PBCJP._Object noattr))
      PBCJP._rawData (Tunion PBCJP.__727 noattr))
    PBCJP._asS32 (tarray tint 80).

Definition us_active_particle_word_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (us_object_raw_s32_array_expr object_temp)
      (Etempvar PBCUS._field tuchar) (tptr tint))
    tint.

Definition jp_active_particle_word_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (jp_object_raw_s32_array_expr object_temp)
      (Etempvar PBCJP._field tuchar) (tptr tint))
    tint.

Lemma eval_us_global_cursor :
  forall (ge : Clight.genv) environment locals memory
      cursor_block script_block,
    environment ! PBCUS._gCurBhvCommand = None ->
    Genv.find_symbol ge PBCUS._gCurBhvCommand = Some cursor_block ->
    Mem.load Mptr memory cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_command_offset) ->
    eval_expr ge environment locals memory
      (Evar PBCUS._gCurBhvCommand (tptr tuint))
      (Vptr script_block mist_parent_clear_command_offset).
Proof.
  intros ge environment locals memory cursor_block script_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_jp_global_cursor :
  forall (ge : Clight.genv) environment locals memory
      cursor_block script_block,
    environment ! PBCJP._gCurBhvCommand = None ->
    Genv.find_symbol ge PBCJP._gCurBhvCommand = Some cursor_block ->
    Mem.load Mptr memory cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_command_offset) ->
    eval_expr ge environment locals memory
      (Evar PBCJP._gCurBhvCommand (tptr tuint))
      (Vptr script_block mist_parent_clear_command_offset).
Proof.
  intros ge environment locals memory cursor_block script_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_us_current_object :
  forall (ge : Clight.genv) environment locals memory
      current_block spawner_block,
    environment ! PBCUS._gCurrentObject = None ->
    Genv.find_symbol ge PBCUS._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr spawner_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (Evar PBCUS._gCurrentObject
        (tptr (Tstruct PBCUS._Object noattr)))
      (Vptr spawner_block Ptrofs.zero).
Proof.
  intros ge environment locals memory current_block spawner_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_jp_current_object :
  forall (ge : Clight.genv) environment locals memory
      current_block spawner_block,
    environment ! PBCJP._gCurrentObject = None ->
    Genv.find_symbol ge PBCJP._gCurrentObject = Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr spawner_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (Evar PBCJP._gCurrentObject
        (tptr (Tstruct PBCJP._Object noattr)))
      (Vptr spawner_block Ptrofs.zero).
Proof.
  intros ge environment locals memory current_block spawner_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal | exact Hsymbol].
  - eapply deref_loc_value; [reflexivity | cbn; exact Hload].
Qed.

Lemma eval_us_parent_object :
  forall (ge : Clight.genv) environment locals memory object_temp
      spawner_block mario_block object_composite,
    locals ! object_temp = Some (Vptr spawner_block Ptrofs.zero) ->
    (genv_cenv ge) ! PBCUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCUS._parentObj
      (co_members object_composite) =
      OK (parent_object_byte_offset, Full) ->
    Mem.load Mptr memory spawner_block parent_object_byte_offset =
      Some (Vptr mario_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (us_parent_object_expr object_temp)
      (Vptr mario_block Ptrofs.zero).
Proof.
  intros ge environment locals memory object_temp spawner_block mario_block
    object_composite Htemp Hobject Hoffset Hload.
  eapply eval_Elvalue.
  - unfold us_parent_object_expr.
    replace (Ptrofs.repr parent_object_byte_offset) with
      (Ptrofs.add Ptrofs.zero (Ptrofs.repr parent_object_byte_offset))
      by (vm_compute; reflexivity).
    eapply eval_Efield_struct with
      (id := PBCUS._Object) (co := object_composite) (att := noattr)
      (delta := parent_object_byte_offset) (bf := Full).
    + eapply eval_Elvalue.
      * eapply eval_Ederef. eapply eval_Etempvar. exact Htemp.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hobject.
    + exact Hoffset.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, parent_object_byte_offset.
      change (Mem.load Mptr memory spawner_block 104 =
        Some (Vptr mario_block Ptrofs.zero)).
      exact Hload.
Qed.

Lemma eval_jp_parent_object :
  forall (ge : Clight.genv) environment locals memory object_temp
      spawner_block mario_block object_composite,
    locals ! object_temp = Some (Vptr spawner_block Ptrofs.zero) ->
    (genv_cenv ge) ! PBCJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCJP._parentObj
      (co_members object_composite) =
      OK (parent_object_byte_offset, Full) ->
    Mem.load Mptr memory spawner_block parent_object_byte_offset =
      Some (Vptr mario_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (jp_parent_object_expr object_temp)
      (Vptr mario_block Ptrofs.zero).
Proof.
  intros ge environment locals memory object_temp spawner_block mario_block
    object_composite Htemp Hobject Hoffset Hload.
  eapply eval_Elvalue.
  - unfold jp_parent_object_expr.
    replace (Ptrofs.repr parent_object_byte_offset) with
      (Ptrofs.add Ptrofs.zero (Ptrofs.repr parent_object_byte_offset))
      by (vm_compute; reflexivity).
    eapply eval_Efield_struct with
      (id := PBCJP._Object) (co := object_composite) (att := noattr)
      (delta := parent_object_byte_offset) (bf := Full).
    + eapply eval_Elvalue.
      * eapply eval_Ederef. eapply eval_Etempvar. exact Htemp.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + exact Hobject.
    + exact Hoffset.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, parent_object_byte_offset.
      change (Mem.load Mptr memory spawner_block 104 =
        Some (Vptr mario_block Ptrofs.zero)).
      exact Hload.
Qed.

Lemma eval_us_object_raw_s32_array_pointer :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! PBCUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCUS._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCUS._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    eval_expr ge environment locals memory
      (us_object_raw_s32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr raw_data_byte_offset)).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold us_object_raw_s32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr raw_data_byte_offset) with
      (Ptrofs.add (Ptrofs.repr raw_data_byte_offset) Ptrofs.zero)
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := PBCUS.__764) (co := raw_composite) (att := noattr)
      (delta := 0%Z) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr raw_data_byte_offset) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr raw_data_byte_offset))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := PBCUS._Object) (co := object_composite) (att := noattr)
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

Lemma eval_jp_object_raw_s32_array_pointer :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    (genv_cenv ge) ! PBCJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCJP._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCJP._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    eval_expr ge environment locals memory
      (jp_object_raw_s32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr raw_data_byte_offset)).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hobject Hraw_offset Hraw
    Harray_offset.
  unfold jp_object_raw_s32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr raw_data_byte_offset) with
      (Ptrofs.add (Ptrofs.repr raw_data_byte_offset) Ptrofs.zero)
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := PBCJP.__727) (co := raw_composite) (att := noattr)
      (delta := 0%Z) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr raw_data_byte_offset) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr raw_data_byte_offset))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := PBCJP._Object) (co := object_composite) (att := noattr)
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

Lemma eval_us_active_particle_word_lvalue :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    locals ! PBCUS._field = Some (Vint (Int.repr 22)) ->
    (genv_cenv ge) ! PBCUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCUS._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCUS._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    eval_lvalue ge environment locals memory
      (us_active_particle_word_lvalue object_temp)
      object_block (Ptrofs.repr active_particle_word_byte_offset) Full.
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hfield Hobject Hraw_offset Hraw
    Harray_offset.
  unfold us_active_particle_word_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - eapply eval_us_object_raw_s32_array_pointer; eauto.
  - eapply eval_Etempvar. exact Hfield.
  - unfold raw_data_byte_offset, active_particle_word_byte_offset.
    cbn. reflexivity.
Qed.

Lemma eval_jp_active_particle_word_lvalue :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    locals ! PBCJP._field = Some (Vint (Int.repr 22)) ->
    (genv_cenv ge) ! PBCJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCJP._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCJP._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    eval_lvalue ge environment locals memory
      (jp_active_particle_word_lvalue object_temp)
      object_block (Ptrofs.repr active_particle_word_byte_offset) Full.
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite Htemp Hfield Hobject Hraw_offset Hraw
    Harray_offset.
  unfold jp_active_particle_word_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - eapply eval_jp_object_raw_s32_array_pointer; eauto.
  - eapply eval_Etempvar. exact Hfield.
  - unfold raw_data_byte_offset, active_particle_word_byte_offset.
    cbn. reflexivity.
Qed.

Lemma eval_us_active_particle_word_value :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite flags,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    locals ! PBCUS._field = Some (Vint (Int.repr 22)) ->
    (genv_cenv ge) ! PBCUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCUS._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCUS._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    Mem.load Mint32 memory object_block active_particle_word_byte_offset =
      Some (Vint flags) ->
    eval_expr ge environment locals memory
      (us_active_particle_word_lvalue object_temp) (Vint flags).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite flags Htemp Hfield Hobject Hraw_offset
    Hraw Harray_offset Hload.
  eapply eval_Elvalue.
  - eapply eval_us_active_particle_word_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, active_particle_word_byte_offset.
      change (Mem.load Mint32 memory object_block 224 = Some (Vint flags)).
      exact Hload.
Qed.

Lemma eval_jp_active_particle_word_value :
  forall (ge : Clight.genv) environment locals memory object_temp
      object_block object_composite raw_composite flags,
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    locals ! PBCJP._field = Some (Vint (Int.repr 22)) ->
    (genv_cenv ge) ! PBCJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCJP._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCJP._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    Mem.load Mint32 memory object_block active_particle_word_byte_offset =
      Some (Vint flags) ->
    eval_expr ge environment locals memory
      (jp_active_particle_word_lvalue object_temp) (Vint flags).
Proof.
  intros ge environment locals memory object_temp object_block
    object_composite raw_composite flags Htemp Hfield Hobject Hraw_offset
    Hraw Harray_offset Hload.
  eapply eval_Elvalue.
  - eapply eval_jp_active_particle_word_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, active_particle_word_byte_offset.
      change (Mem.load Mint32 memory object_block 224 = Some (Vint flags)).
      exact Hload.
Qed.

Lemma assign_active_particle_word :
  forall cenv memory_before memory_after object_block flags,
    Mem.store Mint32 memory_before object_block
      active_particle_word_byte_offset (Vint (clear_dust_active_bit flags)) =
      Some memory_after ->
    assign_loc cenv tint memory_before object_block
      (Ptrofs.repr active_particle_word_byte_offset) Full
      (Vint (clear_dust_active_bit flags)) memory_after.
Proof.
  intros cenv memory_before memory_after object_block flags Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev, active_particle_word_byte_offset.
    change (Mem.store Mint32 memory_before object_block 224
      (Vint (clear_dust_active_bit flags)) = Some memory_after).
    exact Hstore.
Qed.

Lemma assign_parent_clear_next_cursor :
  forall cenv memory_before memory_after cursor_block script_block,
    Mem.store Mptr memory_before cursor_block 0
      (Vptr script_block mist_parent_clear_next_offset) =
      Some memory_after ->
    assign_loc cenv (tptr tuint) memory_before cursor_block Ptrofs.zero Full
      (Vptr script_block mist_parent_clear_next_offset) memory_after.
Proof.
  intros cenv memory_before memory_after cursor_block script_block Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mptr memory_before cursor_block 0
      (Vptr script_block mist_parent_clear_next_offset) =
      Some memory_after).
    exact Hstore.
Qed.

(** Exact US generated-handler execution.  The two store premises name the
    actual memories produced by clearing Mario's raw-data word and advancing
    the global command cursor. *)
Theorem us_generated_parent_bit_clear_executes_in_any_genv :
  forall (ge : Clight.genv)
      (memory_before memory_cleared memory_after : mem)
      (cursor_block script_block current_block spawner_block mario_block : block)
      (object_composite raw_composite : composite) flags,
    Genv.find_symbol ge PBCUS._gCurBhvCommand = Some cursor_block ->
    Genv.find_symbol ge PBCUS._gCurrentObject = Some current_block ->
    (genv_cenv ge) ! PBCUS._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCUS._parentObj
      (co_members object_composite) =
      OK (parent_object_byte_offset, Full) ->
    field_offset (genv_cenv ge) PBCUS._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCUS.__764 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCUS._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_command_offset) ->
    Mem.load Mint32 memory_before script_block 4 =
      Some (Vint parent_bit_clear_command_word) ->
    Mem.load Mint32 memory_before script_block
      mist_parent_clear_value_offset = Some (Vint dust_active_bit) ->
    Mem.load Mptr memory_before current_block 0 =
      Some (Vptr spawner_block Ptrofs.zero) ->
    Mem.load Mptr memory_before spawner_block parent_object_byte_offset =
      Some (Vptr mario_block Ptrofs.zero) ->
    Mem.load Mint32 memory_before mario_block
      active_particle_word_byte_offset = Some (Vint flags) ->
    dust_active_bit_is_set flags ->
    cursor_block <> mario_block ->
    Mem.store Mint32 memory_before mario_block
      active_particle_word_byte_offset
      (Vint (clear_dust_active_bit flags)) = Some memory_cleared ->
    Mem.store Mptr memory_cleared cursor_block 0
      (Vptr script_block mist_parent_clear_next_offset) = Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal PBCUS.f_bhv_cmd_parent_bit_clear) [] E0 memory_after
      (Vint Int.zero) /\
    Mem.load Mint32 memory_after mario_block
      active_particle_word_byte_offset =
      Some (Vint (clear_dust_active_bit flags)) /\
    Mem.load Mptr memory_after cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_next_offset).
Proof.
  intros ge memory_before memory_cleared memory_after cursor_block
    script_block current_block spawner_block mario_block object_composite
    raw_composite flags Hcursor_symbol Hcurrent_symbol Hobject Hparent_offset
    Hraw_offset Hraw Harray_offset Hcursor_before Hcommand Hvalue
    Hcurrent Hparent Hflags _ Hblocks Hstore_flags Hstore_cursor.
  assert (Hcursor_cleared :
      Mem.load Mptr memory_cleared cursor_block 0 =
        Some (Vptr script_block mist_parent_clear_command_offset)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_flags).
    - exact Hcursor_before.
    - left. exact Hblocks. }
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + cbn [PBCUS.f_bhv_cmd_parent_bit_clear].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_us_global_cursor.
           ++ cbn. reflexivity.
           ++ exact Hcursor_symbol.
           ++ exact Hcursor_before.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_Elvalue.
              ** eapply eval_Ederef.
                 eapply eval_Ebinop.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- constructor.
                 --- cbn. reflexivity.
              ** eapply deref_loc_value.
                 --- reflexivity.
                 --- cbn [Mem.loadv mist_parent_clear_command_offset].
                     exact Hcommand.
           ++ eapply exec_Sset.
              eapply eval_Ecast.
              ** eapply eval_Ecast.
                 --- eapply eval_Ebinop.
                     +++ eapply eval_Ebinop.
                         *** eapply eval_Etempvar. apply PTree.gss.
                         *** constructor.
                         *** cbn. reflexivity.
                     +++ constructor.
                     +++ cbn. vm_compute. reflexivity.
                 --- cbn. reflexivity.
              ** cbn. reflexivity.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_us_global_cursor.
              ** cbn. reflexivity.
              ** exact Hcursor_symbol.
              ** exact Hcursor_before.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sset.
                 eapply eval_Elvalue.
                 --- eapply eval_Ederef.
                     eapply eval_Ebinop.
                     +++ eapply eval_Etempvar. apply PTree.gss.
                     +++ constructor.
                     +++ cbn. reflexivity.
                 --- eapply deref_loc_value.
                     +++ reflexivity.
                     +++ cbn [Mem.loadv
                           mist_parent_clear_command_offset].
                         exact Hvalue.
              ** eapply exec_Sset.
                 eapply eval_Ecast.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- cbn. reflexivity.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_Ebinop.
              ** eapply eval_Etempvar. apply PTree.gss.
              ** constructor.
              ** cbn. vm_compute. reflexivity.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sset.
                     eapply eval_us_current_object.
                     +++ cbn. reflexivity.
                     +++ exact Hcurrent_symbol.
                     +++ exact Hcurrent.
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_us_parent_object.
                         all: first [eassumption | (cbn; reflexivity)].
                     +++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                         *** eapply exec_Sset.
                             eapply eval_us_current_object.
                             ---- cbn. reflexivity.
                             ---- exact Hcurrent_symbol.
                             ---- exact Hcurrent.
                         *** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                             ---- eapply exec_Sset.
                                  eapply eval_us_parent_object.
                                  all: first [eassumption | (cbn; reflexivity)].
                             ---- eapply exec_Sseq_1 with
                                    (t1 := E0) (t2 := E0).
                                  ----- eapply exec_Sset.
                                      eapply eval_us_active_particle_word_value.
                                      all: try eassumption.
                                      all: cbn; reflexivity.
                                  ----- eapply exec_Sassign.
                                      ++++ eapply eval_us_active_particle_word_lvalue.
                                          all: try eassumption.
                                          all: cbn; reflexivity.
                                      ++++ eapply eval_Ebinop.
                                          ***** eapply eval_Etempvar.
                                               cbn. reflexivity.
                                          ***** eapply eval_Ecast.
                                               ------ eapply eval_Etempvar.
                                                    cbn. reflexivity.
                                               ------ cbn. reflexivity.
                                          ***** cbn. reflexivity.
                                      ++++ cbn. reflexivity.
                                      ++++ eapply assign_active_particle_word.
                                          exact Hstore_flags.
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_us_global_cursor.
                         *** cbn. reflexivity.
                         *** exact Hcursor_symbol.
                         *** exact Hcursor_cleared.
                     +++ eapply exec_Sassign.
                         *** eapply eval_Evar_global.
                             ---- cbn. reflexivity.
                             ---- exact Hcursor_symbol.
                         *** eapply eval_Ebinop.
                             ---- eapply eval_Etempvar. apply PTree.gss.
                             ---- constructor.
                             ---- unfold mist_parent_clear_command_offset,
                                  mist_parent_clear_next_offset.
                                  cbn. reflexivity.
                         *** cbn. reflexivity.
                         *** eapply assign_parent_clear_next_cursor.
                             exact Hstore_cursor.
                 --- eapply exec_Sreturn_some. constructor.
    + cbn. split; [discriminate | cbn; reflexivity].
    + cbn. reflexivity.
  - split.
    + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
      * exact (Mem.load_store_same _ _ _ _ _ _ Hstore_flags).
      * left. congruence.
    + exact (Mem.load_store_same _ _ _ _ _ _ Hstore_cursor).
Qed.

(** Exact JP generated-handler execution, with the JP raw-data union tag and
    otherwise the same target-ABI offsets and command words. *)
Theorem jp_generated_parent_bit_clear_executes_in_any_genv :
  forall (ge : Clight.genv)
      (memory_before memory_cleared memory_after : mem)
      (cursor_block script_block current_block spawner_block mario_block : block)
      (object_composite raw_composite : composite) flags,
    Genv.find_symbol ge PBCJP._gCurBhvCommand = Some cursor_block ->
    Genv.find_symbol ge PBCJP._gCurrentObject = Some current_block ->
    (genv_cenv ge) ! PBCJP._Object = Some object_composite ->
    field_offset (genv_cenv ge) PBCJP._parentObj
      (co_members object_composite) =
      OK (parent_object_byte_offset, Full) ->
    field_offset (genv_cenv ge) PBCJP._rawData
      (co_members object_composite) =
      OK (raw_data_byte_offset, Full) ->
    (genv_cenv ge) ! PBCJP.__727 = Some raw_composite ->
    union_field_offset (genv_cenv ge) PBCJP._asS32
      (co_members raw_composite) = OK (0%Z, Full) ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_command_offset) ->
    Mem.load Mint32 memory_before script_block 4 =
      Some (Vint parent_bit_clear_command_word) ->
    Mem.load Mint32 memory_before script_block
      mist_parent_clear_value_offset = Some (Vint dust_active_bit) ->
    Mem.load Mptr memory_before current_block 0 =
      Some (Vptr spawner_block Ptrofs.zero) ->
    Mem.load Mptr memory_before spawner_block parent_object_byte_offset =
      Some (Vptr mario_block Ptrofs.zero) ->
    Mem.load Mint32 memory_before mario_block
      active_particle_word_byte_offset = Some (Vint flags) ->
    dust_active_bit_is_set flags ->
    cursor_block <> mario_block ->
    Mem.store Mint32 memory_before mario_block
      active_particle_word_byte_offset
      (Vint (clear_dust_active_bit flags)) = Some memory_cleared ->
    Mem.store Mptr memory_cleared cursor_block 0
      (Vptr script_block mist_parent_clear_next_offset) = Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal PBCJP.f_bhv_cmd_parent_bit_clear) [] E0 memory_after
      (Vint Int.zero) /\
    Mem.load Mint32 memory_after mario_block
      active_particle_word_byte_offset =
      Some (Vint (clear_dust_active_bit flags)) /\
    Mem.load Mptr memory_after cursor_block 0 =
      Some (Vptr script_block mist_parent_clear_next_offset).
Proof.
  intros ge memory_before memory_cleared memory_after cursor_block
    script_block current_block spawner_block mario_block object_composite
    raw_composite flags Hcursor_symbol Hcurrent_symbol Hobject Hparent_offset
    Hraw_offset Hraw Harray_offset Hcursor_before Hcommand Hvalue
    Hcurrent Hparent Hflags _ Hblocks Hstore_flags Hstore_cursor.
  assert (Hcursor_cleared :
      Mem.load Mptr memory_cleared cursor_block 0 =
        Some (Vptr script_block mist_parent_clear_command_offset)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_flags).
    - exact Hcursor_before.
    - left. exact Hblocks. }
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + cbn [PBCJP.f_bhv_cmd_parent_bit_clear].
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_jp_global_cursor.
           ++ cbn. reflexivity.
           ++ exact Hcursor_symbol.
           ++ exact Hcursor_before.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_Elvalue.
              ** eapply eval_Ederef.
                 eapply eval_Ebinop.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- constructor.
                 --- cbn. reflexivity.
              ** eapply deref_loc_value.
                 --- reflexivity.
                 --- cbn [Mem.loadv mist_parent_clear_command_offset].
                     exact Hcommand.
           ++ eapply exec_Sset.
              eapply eval_Ecast.
              ** eapply eval_Ecast.
                 --- eapply eval_Ebinop.
                     +++ eapply eval_Ebinop.
                         *** eapply eval_Etempvar. apply PTree.gss.
                         *** constructor.
                         *** cbn. reflexivity.
                     +++ constructor.
                     +++ cbn. vm_compute. reflexivity.
                 --- cbn. reflexivity.
              ** cbn. reflexivity.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_jp_global_cursor.
              ** cbn. reflexivity.
              ** exact Hcursor_symbol.
              ** exact Hcursor_before.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sset.
                 eapply eval_Elvalue.
                 --- eapply eval_Ederef.
                     eapply eval_Ebinop.
                     +++ eapply eval_Etempvar. apply PTree.gss.
                     +++ constructor.
                     +++ cbn. reflexivity.
                 --- eapply deref_loc_value.
                     +++ reflexivity.
                     +++ cbn [Mem.loadv
                           mist_parent_clear_command_offset].
                         exact Hvalue.
              ** eapply exec_Sset.
                 eapply eval_Ecast.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- cbn. reflexivity.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_Ebinop.
              ** eapply eval_Etempvar. apply PTree.gss.
              ** constructor.
              ** cbn. vm_compute. reflexivity.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sset.
                     eapply eval_jp_current_object.
                     +++ cbn. reflexivity.
                     +++ exact Hcurrent_symbol.
                     +++ exact Hcurrent.
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_jp_parent_object.
                         all: first [eassumption | (cbn; reflexivity)].
                     +++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                         *** eapply exec_Sset.
                             eapply eval_jp_current_object.
                             ---- cbn. reflexivity.
                             ---- exact Hcurrent_symbol.
                             ---- exact Hcurrent.
                         *** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                             ---- eapply exec_Sset.
                                  eapply eval_jp_parent_object.
                                  all: first [eassumption | (cbn; reflexivity)].
                             ---- eapply exec_Sseq_1 with
                                    (t1 := E0) (t2 := E0).
                                  ----- eapply exec_Sset.
                                      eapply eval_jp_active_particle_word_value.
                                      all: try eassumption.
                                      all: cbn; reflexivity.
                                  ----- eapply exec_Sassign.
                                      ++++ eapply eval_jp_active_particle_word_lvalue.
                                          all: try eassumption.
                                          all: cbn; reflexivity.
                                      ++++ eapply eval_Ebinop.
                                          ***** eapply eval_Etempvar.
                                               cbn. reflexivity.
                                          ***** eapply eval_Ecast.
                                               ------ eapply eval_Etempvar.
                                                    cbn. reflexivity.
                                               ------ cbn. reflexivity.
                                          ***** cbn. reflexivity.
                                      ++++ cbn. reflexivity.
                                      ++++ eapply assign_active_particle_word.
                                          exact Hstore_flags.
              ** eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                 --- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
                     +++ eapply exec_Sset.
                         eapply eval_jp_global_cursor.
                         *** cbn. reflexivity.
                         *** exact Hcursor_symbol.
                         *** exact Hcursor_cleared.
                     +++ eapply exec_Sassign.
                         *** eapply eval_Evar_global.
                             ---- cbn. reflexivity.
                             ---- exact Hcursor_symbol.
                         *** eapply eval_Ebinop.
                             ---- eapply eval_Etempvar. apply PTree.gss.
                             ---- constructor.
                             ---- unfold mist_parent_clear_command_offset,
                                  mist_parent_clear_next_offset.
                                  cbn. reflexivity.
                         *** cbn. reflexivity.
                         *** eapply assign_parent_clear_next_cursor.
                             exact Hstore_cursor.
                 --- eapply exec_Sreturn_some. constructor.
    + cbn. split; [discriminate | cbn; reflexivity].
    + cbn. reflexivity.
  - split.
    + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
      * exact (Mem.load_store_same _ _ _ _ _ _ Hstore_flags).
      * left. congruence.
    + exact (Mem.load_store_same _ _ _ _ _ _ Hstore_cursor).
Qed.
