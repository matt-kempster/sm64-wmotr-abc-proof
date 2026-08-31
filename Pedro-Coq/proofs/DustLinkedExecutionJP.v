From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes Events
  Floats Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import
  jp_behavior_actions jp_behavior_script jp_object_helpers.
From Pedro.Proofs Require Import
  DustClightLink DustClightExec DustLinkedExecution.

Import ListNotations.

Module JPBA := jp_behavior_actions.
Module JPBS := jp_behavior_script.
Module JPOH := jp_object_helpers.

(** JP has the same concrete Object offsets as US, but clightgen assigned the
    raw-data union a different composite tag ([__727] rather than [__764]).
    Consequently this file proves the JP layout and body independently. *)
Definition jp_object_members : members :=
  match jp_dust_comp_env ! JPOH._Object with
  | Some composite => co_members composite
  | None => nil
  end.

Definition jp_object_raw_data_members : members :=
  match jp_dust_comp_env ! JPOH.__727 with
  | Some composite => co_members composite
  | None => nil
  end.

Lemma jp_object_composite_exists :
  exists composite,
    jp_dust_comp_env ! JPOH._Object = Some composite.
Proof.
  assert (Hsome :
    match jp_dust_comp_env ! JPOH._Object with
    | Some _ => true | None => false
    end = true) by (vm_compute; reflexivity).
  destruct (jp_dust_comp_env ! JPOH._Object) as [composite|] eqn:Hlookup.
  - exists composite. reflexivity.
  - discriminate Hsome.
Qed.

Lemma jp_object_raw_data_composite_exists :
  exists composite,
    jp_dust_comp_env ! JPOH.__727 = Some composite.
Proof.
  assert (Hsome :
    match jp_dust_comp_env ! JPOH.__727 with
    | Some _ => true | None => false
    end = true) by (vm_compute; reflexivity).
  destruct (jp_dust_comp_env ! JPOH.__727) as [composite|] eqn:Hlookup.
  - exists composite. reflexivity.
  - discriminate Hsome.
Qed.

Lemma jp_object_members_complete :
  complete_members jp_dust_comp_env jp_object_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma jp_object_raw_data_members_complete :
  complete_members jp_dust_comp_env jp_object_raw_data_members = true.
Proof. vm_compute. reflexivity. Qed.

Lemma jp_object_raw_data_offset :
  field_offset jp_dust_comp_env JPOH._rawData jp_object_members =
    Errors.OK (136, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma jp_object_raw_f32_union_offset :
  union_field_offset jp_dust_comp_env JPOH._asF32
    jp_object_raw_data_members = Errors.OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma jp_object_raw_data_offset_stable :
  forall target_env,
    (forall id composite,
      jp_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    field_offset target_env JPOH._rawData jp_object_members =
      Errors.OK (136, Full).
Proof.
  intros target_env Hextends.
  rewrite <- jp_object_raw_data_offset.
  exact (field_offset_stable jp_dust_comp_env target_env Hextends
    JPOH._rawData jp_object_members jp_object_members_complete).
Qed.

Lemma jp_object_raw_f32_union_offset_stable :
  forall target_env,
    (forall id composite,
      jp_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env JPOH._asF32
      jp_object_raw_data_members = Errors.OK (0, Full).
Proof.
  intros target_env Hextends.
  rewrite <- jp_object_raw_f32_union_offset.
  exact (union_field_offset_stable jp_dust_comp_env target_env Hextends
    JPOH._asF32 jp_object_raw_data_members
    jp_object_raw_data_members_complete).
Qed.

Definition jp_object_raw_f32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct JPOH._Object noattr)))
        (Tstruct JPOH._Object noattr))
      JPOH._rawData (Tunion JPOH.__727 noattr))
    JPOH._asF32 (tarray tfloat 80).

Definition jp_object_x_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (jp_object_raw_f32_array_expr object_temp)
      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
    tfloat.

Definition jp_object_z_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (jp_object_raw_f32_array_expr object_temp)
      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
        (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
    tfloat.

Definition jp_translated_coordinate_expr
    (initial_temp random_temp range_temp : ident) : expr :=
  Ebinop Oadd (Etempvar initial_temp tfloat)
    (Ebinop Osub
      (Ebinop Omul (Etempvar random_temp tfloat)
        (Etempvar range_temp tfloat) tfloat)
      (Ebinop Omul (Etempvar range_temp tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
        tfloat) tfloat) tfloat.

Definition jp_obj_translate_xz_random_body : statement :=
  Ssequence
    (Ssequence
      (Scall (Some JPOH._t'1)
        (Evar JPOH._random_float (Tfunction nil tfloat cc_default)) nil)
      (Ssequence
        (Sset JPOH._t'4 (jp_object_x_lvalue JPOH._obj))
        (Sassign (jp_object_x_lvalue JPOH._obj)
          (jp_translated_coordinate_expr JPOH._t'4 JPOH._t'1
            JPOH._rangeLength))))
    (Ssequence
      (Scall (Some JPOH._t'2)
        (Evar JPOH._random_float (Tfunction nil tfloat cc_default)) nil)
      (Ssequence
        (Sset JPOH._t'3 (jp_object_z_lvalue JPOH._obj))
        (Sassign (jp_object_z_lvalue JPOH._obj)
          (jp_translated_coordinate_expr JPOH._t'3 JPOH._t'2
            JPOH._rangeLength)))).

Lemma jp_obj_translate_xz_random_body_exact :
  fn_body JPOH.f_obj_translate_xz_random =
    jp_obj_translate_xz_random_body.
Proof. reflexivity. Qed.

Lemma eval_jp_object_raw_f32_array_pointer :
  forall linked environment locals memory object_temp object_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (jp_object_raw_f32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr 136)).
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  destruct (link_linkorder _ _ _ Hlink) as [Hleft _].
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Hleft.
  destruct Hleft as [_ Hextends].
  unfold jp_dust_typed_core, typed_component in Hextends.
  destruct jp_object_composite_exists as [object_composite Hobject].
  destruct jp_object_raw_data_composite_exists as
    [raw_composite Hraw_composite].
  assert (Hlinked_object :
      (prog_comp_env linked) ! JPOH._Object = Some object_composite).
  { apply Hextends. exact Hobject. }
  assert (Hlinked_raw :
      (prog_comp_env linked) ! JPOH.__727 = Some raw_composite).
  { apply Hextends. exact Hraw_composite. }
  assert (Hobject_members :
      jp_object_members = co_members object_composite).
  { unfold jp_object_members. rewrite Hobject. reflexivity. }
  assert (Hraw_members :
      jp_object_raw_data_members = co_members raw_composite).
  { unfold jp_object_raw_data_members. rewrite Hraw_composite. reflexivity. }
  assert (Hraw_offset :
      field_offset (prog_comp_env linked) JPOH._rawData jp_object_members =
        Errors.OK (136, Full)).
  { apply jp_object_raw_data_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  assert (Harray_offset :
      union_field_offset (prog_comp_env linked) JPOH._asF32
        jp_object_raw_data_members = Errors.OK (0, Full)).
  { apply jp_object_raw_f32_union_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  unfold jp_object_raw_f32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr 136) with
      (Ptrofs.add (Ptrofs.repr 136) (Ptrofs.repr 0))
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := JPOH.__727) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr 136) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := JPOH._Object) (co := object_composite) (att := noattr)
          (delta := 136) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef.
              eapply eval_Etempvar. exact Hobject_temp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- change ((prog_comp_env linked) ! JPOH._Object =
             Some object_composite).
           exact Hlinked_object.
        -- rewrite <- Hobject_members. exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + change ((prog_comp_env linked) ! JPOH.__727 = Some raw_composite).
      exact Hlinked_raw.
    + rewrite <- Hraw_members. exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_jp_object_x_lvalue :
  forall linked environment locals memory object_temp object_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_lvalue (Clight.globalenv linked) environment locals memory
      (jp_object_x_lvalue object_temp) object_block (Ptrofs.repr 160) Full.
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  unfold jp_object_x_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - exact (eval_jp_object_raw_f32_array_pointer linked environment locals
      memory object_temp object_block Hlink Hobject_temp).
  - eapply eval_Ebinop; [constructor | constructor | cbn; reflexivity].
  - cbn. reflexivity.
Qed.

Lemma eval_jp_object_z_lvalue :
  forall linked environment locals memory object_temp object_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_lvalue (Clight.globalenv linked) environment locals memory
      (jp_object_z_lvalue object_temp) object_block (Ptrofs.repr 168) Full.
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  unfold jp_object_z_lvalue.
  eapply eval_Ederef.
  eapply eval_Ebinop.
  - exact (eval_jp_object_raw_f32_array_pointer linked environment locals
      memory object_temp object_block Hlink Hobject_temp).
  - eapply eval_Ebinop; [constructor | constructor | cbn; reflexivity].
  - cbn. reflexivity.
Qed.

Lemma eval_jp_object_x_value :
  forall linked environment locals memory object_temp object_block value,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mfloat32 memory object_block 160 = Some (Vsingle value) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (jp_object_x_lvalue object_temp) (Vsingle value).
Proof.
  intros linked environment locals memory object_temp object_block value
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - eapply eval_jp_object_x_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mfloat32 memory object_block 160 =
        Some (Vsingle value)).
      exact Hload.
Qed.

Lemma eval_jp_object_z_value :
  forall linked environment locals memory object_temp object_block value,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mfloat32 memory object_block 168 = Some (Vsingle value) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (jp_object_z_lvalue object_temp) (Vsingle value).
Proof.
  intros linked environment locals memory object_temp object_block value
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - eapply eval_jp_object_z_lvalue; eauto.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mfloat32 memory object_block 168 =
        Some (Vsingle value)).
      exact Hload.
Qed.

Lemma assign_jp_object_x_value :
  forall linked memory_before memory_after object_block value,
    Mem.store Mfloat32 memory_before object_block 160 (Vsingle value) =
      Some memory_after ->
    assign_loc (genv_cenv (Clight.globalenv linked)) tfloat memory_before
      object_block (Ptrofs.repr 160) Full (Vsingle value) memory_after.
Proof.
  intros linked memory_before memory_after object_block value Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mfloat32 memory_before object_block 160
      (Vsingle value) = Some memory_after).
    exact Hstore.
Qed.

Lemma assign_jp_object_z_value :
  forall linked memory_before memory_after object_block value,
    Mem.store Mfloat32 memory_before object_block 168 (Vsingle value) =
      Some memory_after ->
    assign_loc (genv_cenv (Clight.globalenv linked)) tfloat memory_before
      object_block (Ptrofs.repr 168) Full (Vsingle value) memory_after.
Proof.
  intros linked memory_before memory_after object_block value Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mfloat32 memory_before object_block 168
      (Vsingle value) = Some memory_after).
    exact Hstore.
Qed.

(** Independent JP execution of the exact [__727]-typed generated body.  As in
    the US theorem, the memory image is explicit and the two generated
    [random_float -> random_u16] calls are interleaved with the X and Z stores. *)
Theorem generated_obj_translate_xz_random_executes_in_jp_typed_link :
  forall linked memory_before seed_block random_float_block random_u16_block
      object_block x_before z_before range,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) JPBS._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) JPBS._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal JPBS.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) JPBS._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal JPBS.f_random_u16) ->
    object_block <> seed_block ->
    Mem.load Mint16unsigned memory_before seed_block 0 =
      Some (Vint Int.zero) ->
    Mem.valid_access memory_before Mint16unsigned seed_block 0 Writable ->
    Mem.load Mfloat32 memory_before object_block 160 =
      Some (Vsingle x_before) ->
    Mem.valid_access memory_before Mfloat32 object_block 160 Writable ->
    Mem.load Mfloat32 memory_before object_block 168 =
      Some (Vsingle z_before) ->
    Mem.valid_access memory_before Mfloat32 object_block 168 Writable ->
    exists memory_after random_x random_z,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal JPOH.f_obj_translate_xz_random)
        [Vptr object_block Ptrofs.zero; Vsingle range]
        E0 memory_after Vundef /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z range)) /\
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block /\
      preserves_all_valid_accesses memory_before memory_after.
Proof.
  intros linked memory_before seed_block random_float_block random_u16_block
    object_block x_before z_before range Hlink Hseed Hfloat_symbol
    Hfloat_function Hu16_symbol Hu16_function Hobject_seed Hload_seed0
    Hwrite_seed0 Hload_x0 Hwrite_x0 Hload_z0 Hwrite_z0.
  pose proof Hfloat_function as Hfloat_function_us.
  rewrite <- random_float_body_us_jp_identical in Hfloat_function_us.
  pose proof Hu16_function as Hu16_function_us.
  rewrite <- random_u16_body_us_jp_identical in Hu16_function_us.

  destruct (Mem.valid_access_store memory_before Mint16unsigned seed_block 0
    (Vint Int.zero) Hwrite_seed0) as [memory_swap1 Hstore_swap1].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mint16unsigned seed_block 0 Writable Hwrite_seed0) as Hwrite_seed_swap1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mfloat32 object_block 160 Writable Hwrite_x0) as Hwrite_x_swap1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
    Mfloat32 object_block 168 Writable Hwrite_z0) as Hwrite_z_swap1.
  destruct (Mem.valid_access_store memory_swap1 Mint16unsigned seed_block 0
    (Vint (Int.repr 57460)) Hwrite_seed_swap1)
    as [memory_random1 Hstore_random1].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mint16unsigned seed_block 0 Writable Hwrite_seed_swap1)
    as Hwrite_seed_random1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mfloat32 object_block 160 Writable Hwrite_x_swap1) as Hwrite_x_random1.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
    Mfloat32 object_block 168 Writable Hwrite_z_swap1) as Hwrite_z_random1.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_random1)
    as Hload_seed_random1.
  cbn in Hload_seed_random1.
  assert (Hload_x_random1 :
      Mem.load Mfloat32 memory_random1 object_block 160 =
        Some (Vsingle x_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
      + exact Hload_x0.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  assert (Hload_z_random1 :
      Mem.load Mfloat32 memory_random1 object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
      + exact Hload_z0.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  pose proof (generated_random_u16_zero_with_given_stores
    (Clight.globalenv linked) memory_before memory_swap1 memory_random1
    seed_block Hseed Hload_seed0 Hstore_swap1 Hstore_random1) as Hu16_first.
  destruct (generated_random_float_executes_linked_random_u16
    (Clight.globalenv linked) memory_before memory_random1 random_u16_block
    (Int.repr 57460) Hu16_symbol Hu16_function_us Hu16_first)
    as [random_x Hfloat_first].
  rewrite random_float_body_us_jp_identical in Hfloat_first.

  destruct (Mem.valid_access_store memory_random1 Mfloat32 object_block 160
    (Vsingle (translated_coordinate x_before random_x range))
    Hwrite_x_random1) as [memory_x Hstore_x].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
    Mint16unsigned seed_block 0 Writable Hwrite_seed_random1)
    as Hwrite_seed_x.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
    Mfloat32 object_block 168 Writable Hwrite_z_random1) as Hwrite_z_x.
  assert (Hload_seed_x :
      Mem.load Mint16unsigned memory_x seed_block 0 =
        Some (Vint (Int.repr 57460))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
    - exact Hload_seed_random1.
    - left. exact (not_eq_sym Hobject_seed). }
  assert (Hload_z_x :
      Mem.load Mfloat32 memory_x object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
    - exact Hload_z_random1.
    - right. right.
      change (164 <= 168)%Z. lia. }

  destruct (Mem.valid_access_store memory_x Mint16unsigned seed_block 0
    (Vint (Int.repr 29844)) Hwrite_seed_x)
    as [memory_swap2 Hstore_swap2].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
    Mint16unsigned seed_block 0 Writable Hwrite_seed_x) as Hwrite_seed_swap2.
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
    Mfloat32 object_block 168 Writable Hwrite_z_x) as Hwrite_z_swap2.
  destruct (Mem.valid_access_store memory_swap2 Mint16unsigned seed_block 0
    (Vint (Int.repr 55882)) Hwrite_seed_swap2)
    as [memory_random2 Hstore_random2].
  pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random2
    Mfloat32 object_block 168 Writable Hwrite_z_swap2) as Hwrite_z_random2.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_random2)
    as Hload_seed_random2.
  cbn in Hload_seed_random2.
  assert (Hload_z_random2 :
      Mem.load Mfloat32 memory_random2 object_block 168 =
        Some (Vsingle z_before)).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
      + exact Hload_z_x.
      + left. exact Hobject_seed.
    - left. exact Hobject_seed. }
  pose proof (generated_random_u16_57460_with_given_stores
    (Clight.globalenv linked) memory_x memory_swap2 memory_random2 seed_block
    Hseed Hload_seed_x Hstore_swap2 Hstore_random2) as Hu16_second.
  destruct (generated_random_float_executes_linked_random_u16
    (Clight.globalenv linked) memory_x memory_random2 random_u16_block
    (Int.repr 55882) Hu16_symbol Hu16_function_us Hu16_second)
    as [random_z Hfloat_second].
  rewrite random_float_body_us_jp_identical in Hfloat_second.

  destruct (Mem.valid_access_store memory_random2 Mfloat32 object_block 168
    (Vsingle (translated_coordinate z_before random_z range))
    Hwrite_z_random2) as [memory_after Hstore_z].
  assert (Hload_seed_after :
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - exact Hload_seed_random2.
    - left. exact (not_eq_sym Hobject_seed). }
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_z) as Hload_z_after.
  cbn in Hload_z_after.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_x) as Hload_x_store.
  cbn in Hload_x_store.
  assert (Hload_x_after :
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
        -- exact Hload_x_store.
        -- left. exact Hobject_seed.
      + left. exact Hobject_seed.
    - right. left.
      change (164 <= 168)%Z. lia. }

  assert (Hframe :
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block).
  { unfold preserves_loads_outside_two_blocks.
    intros chunk frame_block frame_offset value Hframe_seed Hframe_object
      Hload_frame.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_z).
    - rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random2).
      + rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap2).
        * rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_x).
          -- rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_random1).
             ++ rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_swap1).
                ** exact Hload_frame.
                ** left. exact Hframe_seed.
             ++ left. exact Hframe_seed.
          -- left. exact Hframe_object.
        * left. exact Hframe_seed.
      + left. exact Hframe_seed.
    - left. exact Hframe_object. }
  assert (Hvalid :
      preserves_all_valid_accesses memory_before memory_after).
  { unfold preserves_all_valid_accesses.
    intros chunk frame_block frame_offset permission Haccess0.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap1
      chunk frame_block frame_offset permission Haccess0) as Haccess1.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random1
      chunk frame_block frame_offset permission Haccess1) as Haccess2.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_x
      chunk frame_block frame_offset permission Haccess2) as Haccess3.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_swap2
      chunk frame_block frame_offset permission Haccess3) as Haccess4.
    pose proof (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_random2
      chunk frame_block frame_offset permission Haccess4) as Haccess5.
    exact (Mem.store_valid_access_1 _ _ _ _ _ _ Hstore_z
      chunk frame_block frame_offset permission Haccess5). }

  assert (Hexec :
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal JPOH.f_obj_translate_xz_random)
        [Vptr object_block Ptrofs.zero; Vsingle range]
        E0 memory_after Vundef).
  { eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + cbn.
      apply Coqlib.list_norepet_cons.
      * cbn. intros [Hequal | Hfalse].
        -- vm_compute in Hequal. discriminate.
        -- contradiction.
      * apply Coqlib.list_norepet_cons.
        -- cbn. tauto.
        -- apply Coqlib.list_norepet_nil.
    + red.
      intros parameter temporary Hparameter Htemporary Hequal.
      subst temporary.
      cbn in Hparameter, Htemporary.
      destruct Hparameter as [Hparameter | [Hparameter | Hnone]];
        try contradiction;
      destruct Htemporary as
        [Htemporary | [Htemporary | [Htemporary | [Htemporary | Hnone]]]];
        try contradiction;
      subst parameter;
      vm_compute in Htemporary;
      discriminate.
    + constructor.
    + cbn. reflexivity.
  - rewrite jp_obj_translate_xz_random_body_exact.
    unfold jp_obj_translate_xz_random_body.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_linked_function_symbol.
           ++ reflexivity.
           ++ exact Hfloat_symbol.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hfloat_function.
        -- cbn. reflexivity.
        -- exact Hfloat_first.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_jp_object_x_value; [exact Hlink | cbn; reflexivity |
             exact Hload_x_random1].
        -- eapply exec_Sassign.
           ++ eapply eval_jp_object_x_lvalue;
                [exact Hlink | cbn; reflexivity].
           ++ unfold jp_translated_coordinate_expr, translated_coordinate.
              linked_eval_closed_expr.
           ++ cbn. reflexivity.
           ++ eapply assign_jp_object_x_value. exact Hstore_x.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_linked_function_symbol.
           ++ reflexivity.
           ++ exact Hfloat_symbol.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hfloat_function.
        -- cbn. reflexivity.
        -- exact Hfloat_second.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_jp_object_z_value; [exact Hlink | cbn; reflexivity |
             exact Hload_z_random2].
        -- eapply exec_Sassign.
           ++ eapply eval_jp_object_z_lvalue;
                [exact Hlink | cbn; reflexivity].
           ++ unfold jp_translated_coordinate_expr, translated_coordinate.
              linked_eval_closed_expr.
           ++ cbn. reflexivity.
           ++ eapply assign_jp_object_z_value. exact Hstore_z.
  - cbn. reflexivity.
  - cbn. reflexivity. }
  exists memory_after, random_x, random_z.
  split; [exact Hexec|].
  split; [exact Hload_seed_after|].
  split; [exact Hload_x_after|].
  split; [exact Hload_z_after|].
  split; [exact Hframe|exact Hvalid].
Qed.

Definition jp_obj_translate_memory_image
    (memory : mem) (seed_block object_block : block)
    (x_value z_value : float32) : Prop :=
  object_block <> seed_block /\
  Mem.load Mint16unsigned memory seed_block 0 = Some (Vint Int.zero) /\
  Mem.valid_access memory Mint16unsigned seed_block 0 Writable /\
  Mem.load Mfloat32 memory object_block 160 = Some (Vsingle x_value) /\
  Mem.valid_access memory Mfloat32 object_block 160 Writable /\
  Mem.load Mfloat32 memory object_block 168 = Some (Vsingle z_value) /\
  Mem.valid_access memory Mfloat32 object_block 168 Writable.

Definition jp_linked_obj_translate_execution_claim : Prop :=
  exists linked seed_block translate_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) JPBS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked)
      JPOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal JPOH.f_obj_translate_xz_random) /\
    forall memory_before object_block x_before z_before range,
      jp_obj_translate_memory_image memory_before seed_block object_block
        x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal JPOH.f_obj_translate_xz_random)
          [Vptr object_block Ptrofs.zero; Vsingle range]
          E0 memory_after Vundef /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z range)).

Theorem checked_jp_linked_obj_translate_execution :
  jp_linked_obj_translate_execution_claim.
Proof.
  destruct jp_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked JPBS._gRandomSeed16
    (Gvar JPBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - destruct (jp_typed_link_resolves_obj_translate_xz_random linked Hlink)
      as [translate_block [Htranslate_symbol Htranslate_function]].
    pose proof
      (jp_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
      as [_ [_ [_ [[random_float_block
        [Hfloat_symbol Hfloat_function]]
        [random_u16_block [Hu16_symbol Hu16_function]]]]]].
    exists linked, seed_block, translate_block.
    repeat split; try assumption.
    intros memory_before object_block x_before z_before range Hmemory.
    destruct Hmemory as
      (Hobject_seed & Hload_seed & Hwrite_seed & Hload_x & Hwrite_x &
       Hload_z & Hwrite_z).
    destruct (generated_obj_translate_xz_random_executes_in_jp_typed_link
      linked memory_before seed_block random_float_block random_u16_block
      object_block x_before z_before range Hlink Hseed Hfloat_symbol
      Hfloat_function Hu16_symbol Hu16_function Hobject_seed Hload_seed
      Hwrite_seed Hload_x Hwrite_x Hload_z Hwrite_z)
      as (memory_after & random_x & random_z & Hexec & Hseed_after &
          Hx_after & Hz_after & _ & _).
    exists memory_after, random_x, random_z.
    split; [exact Hexec|].
    split; [exact Hseed_after|].
    split; [exact Hx_after|exact Hz_after].
Qed.
