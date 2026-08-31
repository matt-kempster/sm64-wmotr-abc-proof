From Coq Require Import Lia List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes Events
  Floats Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import
  us_behavior_actions us_behavior_script
  us_object_helpers
  jp_behavior_actions jp_behavior_script
  jp_object_helpers.
From Pedro.Proofs Require Import
  DustClightLink DustClightExec DustLinkedExecution DustLinkedExecutionJP.

Import ListNotations.

Module WPUS := us_behavior_actions.
Module WPUSBS := us_behavior_script.
Module WPUSOH := us_object_helpers.
Module WPJP := jp_behavior_actions.
Module WPJPBS := jp_behavior_script.
Module WPJPOH := jp_object_helpers.

Definition white_puff_random_range : float32 :=
  Float32.of_bits (Int.repr 1109393408).

(** The timer read in both white-puff loops is rawData.asS32[51], i.e. byte
    offset 136 + 51*4 = 340 in the exact generated Object layout. *)
Lemma us_object_raw_s32_union_offset :
  union_field_offset us_dust_comp_env WPUS._asS32
    us_object_raw_data_members = Errors.OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma jp_object_raw_s32_union_offset :
  union_field_offset jp_dust_comp_env WPJP._asS32
    jp_object_raw_data_members = Errors.OK (0, Full).
Proof. vm_compute. reflexivity. Qed.

Lemma us_object_raw_s32_union_offset_stable :
  forall target_env,
    (forall id composite,
      us_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env WPUS._asS32
      us_object_raw_data_members = Errors.OK (0, Full).
Proof.
  intros target_env Hextends.
  rewrite <- us_object_raw_s32_union_offset.
  exact (union_field_offset_stable us_dust_comp_env target_env Hextends
    WPUS._asS32 us_object_raw_data_members
    us_object_raw_data_members_complete).
Qed.

Lemma jp_object_raw_s32_union_offset_stable :
  forall target_env,
    (forall id composite,
      jp_dust_comp_env ! id = Some composite ->
      target_env ! id = Some composite) ->
    union_field_offset target_env WPJP._asS32
      jp_object_raw_data_members = Errors.OK (0, Full).
Proof.
  intros target_env Hextends.
  rewrite <- jp_object_raw_s32_union_offset.
  exact (union_field_offset_stable jp_dust_comp_env target_env Hextends
    WPJP._asS32 jp_object_raw_data_members
    jp_object_raw_data_members_complete).
Qed.

Definition us_object_raw_s32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct WPUS._Object noattr)))
        (Tstruct WPUS._Object noattr))
      WPUS._rawData (Tunion WPUS.__764 noattr))
    WPUS._asS32 (tarray tint 80).

Definition jp_object_raw_s32_array_expr (object_temp : ident) : expr :=
  Efield
    (Efield
      (Ederef
        (Etempvar object_temp (tptr (Tstruct WPJP._Object noattr)))
        (Tstruct WPJP._Object noattr))
      WPJP._rawData (Tunion WPJP.__727 noattr))
    WPJP._asS32 (tarray tint 80).

Definition us_object_timer_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (us_object_raw_s32_array_expr object_temp)
      (Econst_int (Int.repr 51) tint) (tptr tint))
    tint.

Definition jp_object_timer_lvalue (object_temp : ident) : expr :=
  Ederef
    (Ebinop Oadd (jp_object_raw_s32_array_expr object_temp)
      (Econst_int (Int.repr 51) tint) (tptr tint))
    tint.

Definition us_white_puff_2_body : statement :=
  Ssequence
    (Sset WPUS._t'1
      (Evar WPUS._gCurrentObject (tptr (Tstruct WPUS._Object noattr))))
    (Ssequence
      (Sset WPUS._t'2 (us_object_timer_lvalue WPUS._t'1))
      (Sifthenelse
        (Ebinop Oeq (Etempvar WPUS._t'2 tint)
          (Econst_int Int.zero tint) tint)
        (Ssequence
          (Sset WPUS._t'3
            (Evar WPUS._gCurrentObject
              (tptr (Tstruct WPUS._Object noattr))))
          (Scall None
            (Evar WPUS._obj_translate_xz_random
              (Tfunction
                ((tptr (Tstruct WPUS._Object noattr)) :: tfloat :: nil)
                tvoid cc_default))
            [Etempvar WPUS._t'3 (tptr (Tstruct WPUS._Object noattr));
             Econst_single white_puff_random_range tfloat]))
        Sskip)).

Definition jp_white_puff_2_body : statement :=
  Ssequence
    (Sset WPJP._t'1
      (Evar WPJP._gCurrentObject (tptr (Tstruct WPJP._Object noattr))))
    (Ssequence
      (Sset WPJP._t'2 (jp_object_timer_lvalue WPJP._t'1))
      (Sifthenelse
        (Ebinop Oeq (Etempvar WPJP._t'2 tint)
          (Econst_int Int.zero tint) tint)
        (Ssequence
          (Sset WPJP._t'3
            (Evar WPJP._gCurrentObject
              (tptr (Tstruct WPJP._Object noattr))))
          (Scall None
            (Evar WPJP._obj_translate_xz_random
              (Tfunction
                ((tptr (Tstruct WPJP._Object noattr)) :: tfloat :: nil)
                tvoid cc_default))
            [Etempvar WPJP._t'3 (tptr (Tstruct WPJP._Object noattr));
             Econst_single white_puff_random_range tfloat]))
        Sskip)).

Lemma us_white_puff_2_body_exact :
  fn_body WPUS.f_bhv_white_puff_2_loop = us_white_puff_2_body.
Proof. reflexivity. Qed.

Lemma jp_white_puff_2_body_exact :
  fn_body WPJP.f_bhv_white_puff_2_loop = jp_white_puff_2_body.
Proof. reflexivity. Qed.

Lemma eval_us_object_raw_s32_array_pointer :
  forall linked environment locals memory object_temp object_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (us_object_raw_s32_array_expr object_temp)
      (Vptr object_block (Ptrofs.repr 136)).
Proof.
  intros linked environment locals memory object_temp object_block
    Hlink Hobject_temp.
  destruct (link_linkorder _ _ _ Hlink) as [Hleft _].
  Local Transparent Linker_program.
  unfold linkorder, Linker_program, linkorder_program in Hleft.
  destruct Hleft as [_ Hextends].
  unfold us_dust_typed_core, typed_component in Hextends.
  destruct us_object_composite_exists as [object_composite Hobject].
  destruct us_object_raw_data_composite_exists as
    [raw_composite Hraw_composite].
  assert (Hlinked_object :
      (prog_comp_env linked) ! WPUS._Object = Some object_composite).
  { apply Hextends. exact Hobject. }
  assert (Hlinked_raw :
      (prog_comp_env linked) ! WPUS.__764 = Some raw_composite).
  { apply Hextends. exact Hraw_composite. }
  assert (Hobject_members :
      us_object_members = co_members object_composite).
  { unfold us_object_members. rewrite Hobject. reflexivity. }
  assert (Hraw_members :
      us_object_raw_data_members = co_members raw_composite).
  { unfold us_object_raw_data_members. rewrite Hraw_composite. reflexivity. }
  assert (Hraw_offset :
      field_offset (prog_comp_env linked) WPUS._rawData us_object_members =
        Errors.OK (136, Full)).
  { apply us_object_raw_data_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  assert (Harray_offset :
      union_field_offset (prog_comp_env linked) WPUS._asS32
        us_object_raw_data_members = Errors.OK (0, Full)).
  { apply us_object_raw_s32_union_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  unfold us_object_raw_s32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr 136) with
      (Ptrofs.add (Ptrofs.repr 136) (Ptrofs.repr 0))
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := WPUS.__764) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr 136) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := WPUS._Object) (co := object_composite) (att := noattr)
          (delta := 136) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef.
              eapply eval_Etempvar. exact Hobject_temp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- change ((prog_comp_env linked) ! WPUS._Object =
             Some object_composite).
           exact Hlinked_object.
        -- rewrite <- Hobject_members. exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + change ((prog_comp_env linked) ! WPUS.__764 = Some raw_composite).
      exact Hlinked_raw.
    + rewrite <- Hraw_members. exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_jp_object_raw_s32_array_pointer :
  forall linked environment locals memory object_temp object_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (jp_object_raw_s32_array_expr object_temp)
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
      (prog_comp_env linked) ! WPJP._Object = Some object_composite).
  { apply Hextends. exact Hobject. }
  assert (Hlinked_raw :
      (prog_comp_env linked) ! WPJP.__727 = Some raw_composite).
  { apply Hextends. exact Hraw_composite. }
  assert (Hobject_members :
      jp_object_members = co_members object_composite).
  { unfold jp_object_members. rewrite Hobject. reflexivity. }
  assert (Hraw_members :
      jp_object_raw_data_members = co_members raw_composite).
  { unfold jp_object_raw_data_members. rewrite Hraw_composite. reflexivity. }
  assert (Hraw_offset :
      field_offset (prog_comp_env linked) WPJP._rawData jp_object_members =
        Errors.OK (136, Full)).
  { apply jp_object_raw_data_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  assert (Harray_offset :
      union_field_offset (prog_comp_env linked) WPJP._asS32
        jp_object_raw_data_members = Errors.OK (0, Full)).
  { apply jp_object_raw_s32_union_offset_stable.
    intros id composite Hlookup.
    apply Hextends. exact Hlookup. }
  unfold jp_object_raw_s32_array_expr.
  eapply eval_Elvalue.
  - replace (Ptrofs.repr 136) with
      (Ptrofs.add (Ptrofs.repr 136) (Ptrofs.repr 0))
      by (vm_compute; reflexivity).
    eapply eval_Efield_union with
      (id := WPJP.__727) (co := raw_composite) (att := noattr)
      (delta := 0) (bf := Full).
    + eapply eval_Elvalue.
      * replace (Ptrofs.repr 136) with
          (Ptrofs.add Ptrofs.zero (Ptrofs.repr 136))
          by (vm_compute; reflexivity).
        eapply eval_Efield_struct with
          (id := WPJP._Object) (co := object_composite) (att := noattr)
          (delta := 136) (bf := Full).
        -- eapply eval_Elvalue.
           ++ eapply eval_Ederef.
              eapply eval_Etempvar. exact Hobject_temp.
           ++ eapply deref_loc_copy. reflexivity.
        -- reflexivity.
        -- change ((prog_comp_env linked) ! WPJP._Object =
             Some object_composite).
           exact Hlinked_object.
        -- rewrite <- Hobject_members. exact Hraw_offset.
      * eapply deref_loc_copy. reflexivity.
    + reflexivity.
    + change ((prog_comp_env linked) ! WPJP.__727 = Some raw_composite).
      exact Hlinked_raw.
    + rewrite <- Hraw_members. exact Harray_offset.
  - eapply deref_loc_reference. reflexivity.
Qed.

Lemma eval_us_object_timer_value :
  forall linked environment locals memory object_temp object_block timer,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mint32 memory object_block 340 = Some (Vint timer) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (us_object_timer_lvalue object_temp) (Vint timer).
Proof.
  intros linked environment locals memory object_temp object_block timer
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - unfold us_object_timer_lvalue.
    eapply eval_Ederef.
    eapply eval_Ebinop.
    + exact (eval_us_object_raw_s32_array_pointer linked environment locals
        memory object_temp object_block Hlink Htemp).
    + constructor.
    + cbn. reflexivity.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mint32 memory object_block 340 = Some (Vint timer)).
      exact Hload.
Qed.

Lemma eval_jp_object_timer_value :
  forall linked environment locals memory object_temp object_block timer,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    locals ! object_temp = Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mint32 memory object_block 340 = Some (Vint timer) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (jp_object_timer_lvalue object_temp) (Vint timer).
Proof.
  intros linked environment locals memory object_temp object_block timer
    Hlink Htemp Hload.
  eapply eval_Elvalue.
  - unfold jp_object_timer_lvalue.
    eapply eval_Ederef.
    eapply eval_Ebinop.
    + exact (eval_jp_object_raw_s32_array_pointer linked environment locals
        memory object_temp object_block Hlink Htemp).
    + constructor.
    + cbn. reflexivity.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv.
      change (Mem.load Mint32 memory object_block 340 = Some (Vint timer)).
      exact Hload.
Qed.

Lemma eval_us_current_object :
  forall linked environment locals memory current_block object_block,
    environment ! WPUS._gCurrentObject = None ->
    Genv.find_symbol (Clight.globalenv linked) WPUS._gCurrentObject =
      Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (Evar WPUS._gCurrentObject (tptr (Tstruct WPUS._Object noattr)))
      (Vptr object_block Ptrofs.zero).
Proof.
  intros linked environment locals memory current_block object_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal|exact Hsymbol].
  - eapply deref_loc_value.
    + reflexivity.
    + cbn. exact Hload.
Qed.

Lemma eval_jp_current_object :
  forall linked environment locals memory current_block object_block,
    environment ! WPJP._gCurrentObject = None ->
    Genv.find_symbol (Clight.globalenv linked) WPJP._gCurrentObject =
      Some current_block ->
    Mem.load Mptr memory current_block 0 =
      Some (Vptr object_block Ptrofs.zero) ->
    eval_expr (Clight.globalenv linked) environment locals memory
      (Evar WPJP._gCurrentObject (tptr (Tstruct WPJP._Object noattr)))
      (Vptr object_block Ptrofs.zero).
Proof.
  intros linked environment locals memory current_block object_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal|exact Hsymbol].
  - eapply deref_loc_value.
    + reflexivity.
    + cbn. exact Hload.
Qed.

(** Exact first-frame branch of the generated US white-puff-2 native.  The
    timer-zero read selects its [obj_translate_xz_random] call; the nested
    function then executes both generated RNG calls and both Object stores. *)
Theorem generated_white_puff_2_timer_zero_executes_in_us_typed_link :
  forall linked memory_before seed_block current_block translate_block
      random_float_block random_u16_block object_block x_before z_before,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) WPUS._gCurrentObject =
      Some current_block ->
    Genv.find_symbol (Clight.globalenv linked)
      WPUS._obj_translate_xz_random = Some translate_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal WPUSOH.f_obj_translate_xz_random) ->
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal WPUSBS.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal WPUSBS.f_random_u16) ->
    Mem.load Mptr memory_before current_block 0 =
      Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mint32 memory_before object_block 340 = Some (Vint Int.zero) ->
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
        (Internal WPUS.f_bhv_white_puff_2_loop) []
        E0 memory_after Vundef /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range)) /\
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block /\
      preserves_all_valid_accesses memory_before memory_after.
Proof.
  intros linked memory_before seed_block current_block translate_block
    random_float_block random_u16_block object_block x_before z_before
    Hlink Hseed Hcurrent_symbol Htranslate_symbol Htranslate_function
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hcurrent_load
    Htimer_zero Hobject_seed Hload_seed Hwrite_seed Hload_x Hwrite_x
    Hload_z Hwrite_z.
  destruct (generated_obj_translate_xz_random_executes_in_us_typed_link
    linked memory_before seed_block random_float_block random_u16_block
    object_block x_before z_before white_puff_random_range Hlink Hseed
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hobject_seed
    Hload_seed Hwrite_seed Hload_x Hwrite_x Hload_z Hwrite_z)
    as (memory_after & random_x & random_z & Htranslate & Hseed_after &
        Hx_after & Hz_after & Hframe & Hvalid).
  exists memory_after, random_x, random_z.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + rewrite us_white_puff_2_body_exact.
      unfold us_white_puff_2_body.
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset.
        eapply eval_us_current_object.
        -- cbn. reflexivity.
        -- exact Hcurrent_symbol.
        -- exact Hcurrent_load.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_us_object_timer_value.
           ++ exact Hlink.
           ++ apply PTree.gss.
           ++ exact Htimer_zero.
        -- eapply exec_Sifthenelse with (b := true).
           ++ eapply eval_Ebinop.
              ** eapply eval_Etempvar. apply PTree.gss.
              ** constructor.
              ** cbn. reflexivity.
           ++ cbn. reflexivity.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sset.
                 eapply eval_us_current_object.
                 --- cbn. reflexivity.
                 --- exact Hcurrent_symbol.
                 --- exact Hcurrent_load.
              ** eapply exec_Scall.
                 --- cbn. reflexivity.
                 --- eapply eval_linked_function_symbol.
                     +++ reflexivity.
                     +++ exact Htranslate_symbol.
                 --- eapply eval_Econs.
                     +++ eapply eval_Etempvar. apply PTree.gss.
                     +++ cbn. reflexivity.
                     +++ eapply eval_Econs.
                         *** constructor.
                         *** cbn. reflexivity.
                         *** constructor.
                 --- eapply find_funct_at_zero_offset.
                     exact Htranslate_function.
                 --- cbn. reflexivity.
                 --- exact Htranslate.
    + cbn. reflexivity.
    + cbn. reflexivity.
  - split; [exact Hseed_after|].
    split; [exact Hx_after|].
    split; [exact Hz_after|].
    split; [exact Hframe|exact Hvalid].
Qed.

(** The corresponding JP proof executes the independently generated
    [__727]-typed caller and the independently checked JP translation body. *)
Theorem generated_white_puff_2_timer_zero_executes_in_jp_typed_link :
  forall linked memory_before seed_block current_block translate_block
      random_float_block random_u16_block object_block x_before z_before,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) WPJP._gCurrentObject =
      Some current_block ->
    Genv.find_symbol (Clight.globalenv linked)
      WPJP._obj_translate_xz_random = Some translate_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal WPJPOH.f_obj_translate_xz_random) ->
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal WPJPBS.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal WPJPBS.f_random_u16) ->
    Mem.load Mptr memory_before current_block 0 =
      Some (Vptr object_block Ptrofs.zero) ->
    Mem.load Mint32 memory_before object_block 340 = Some (Vint Int.zero) ->
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
        (Internal WPJP.f_bhv_white_puff_2_loop) []
        E0 memory_after Vundef /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range)) /\
      preserves_loads_outside_two_blocks memory_before memory_after
        seed_block object_block /\
      preserves_all_valid_accesses memory_before memory_after.
Proof.
  intros linked memory_before seed_block current_block translate_block
    random_float_block random_u16_block object_block x_before z_before
    Hlink Hseed Hcurrent_symbol Htranslate_symbol Htranslate_function
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hcurrent_load
    Htimer_zero Hobject_seed Hload_seed Hwrite_seed Hload_x Hwrite_x
    Hload_z Hwrite_z.
  destruct (generated_obj_translate_xz_random_executes_in_jp_typed_link
    linked memory_before seed_block random_float_block random_u16_block
    object_block x_before z_before white_puff_random_range Hlink Hseed
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hobject_seed
    Hload_seed Hwrite_seed Hload_x Hwrite_x Hload_z Hwrite_z)
    as (memory_after & random_x & random_z & Htranslate & Hseed_after &
        Hx_after & Hz_after & Hframe & Hvalid).
  exists memory_after, random_x, random_z.
  split.
  - eapply eval_funcall_internal.
    + eapply function_entry2_intro.
      * constructor.
      * constructor.
      * intros x y Hnone. inversion Hnone.
      * constructor.
      * reflexivity.
    + rewrite jp_white_puff_2_body_exact.
      unfold jp_white_puff_2_body.
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset.
        eapply eval_jp_current_object.
        -- cbn. reflexivity.
        -- exact Hcurrent_symbol.
        -- exact Hcurrent_load.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_jp_object_timer_value.
           ++ exact Hlink.
           ++ apply PTree.gss.
           ++ exact Htimer_zero.
        -- eapply exec_Sifthenelse with (b := true).
           ++ eapply eval_Ebinop.
              ** eapply eval_Etempvar. apply PTree.gss.
              ** constructor.
              ** cbn. reflexivity.
           ++ cbn. reflexivity.
           ++ eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
              ** eapply exec_Sset.
                 eapply eval_jp_current_object.
                 --- cbn. reflexivity.
                 --- exact Hcurrent_symbol.
                 --- exact Hcurrent_load.
              ** eapply exec_Scall.
                 --- cbn. reflexivity.
                 --- eapply eval_linked_function_symbol.
                     +++ reflexivity.
                     +++ exact Htranslate_symbol.
                 --- eapply eval_Econs.
                     +++ eapply eval_Etempvar. apply PTree.gss.
                     +++ cbn. reflexivity.
                     +++ eapply eval_Econs.
                         *** constructor.
                         *** cbn. reflexivity.
                         *** constructor.
                 --- eapply find_funct_at_zero_offset.
                     exact Htranslate_function.
                 --- cbn. reflexivity.
                 --- exact Htranslate.
    + cbn. reflexivity.
    + cbn. reflexivity.
  - split; [exact Hseed_after|].
    split; [exact Hx_after|].
    split; [exact Hz_after|].
    split; [exact Hframe|exact Hvalid].
Qed.

Definition us_white_puff_2_memory_image
    (memory : mem) (seed_block current_block object_block : block)
    (x_value z_value : float32) : Prop :=
  Mem.load Mptr memory current_block 0 =
    Some (Vptr object_block Ptrofs.zero) /\
  Mem.load Mint32 memory object_block 340 = Some (Vint Int.zero) /\
  us_obj_translate_memory_image memory seed_block object_block
    x_value z_value.

Definition jp_white_puff_2_memory_image
    (memory : mem) (seed_block current_block object_block : block)
    (x_value z_value : float32) : Prop :=
  Mem.load Mptr memory current_block 0 =
    Some (Vptr object_block Ptrofs.zero) /\
  Mem.load Mint32 memory object_block 340 = Some (Vint Int.zero) /\
  jp_obj_translate_memory_image memory seed_block object_block
    x_value z_value.

(** A closed US link certificate for this execution frontier.  Unlike a mere
    resolution theorem, its final conjunct executes the generated white-puff
    caller, which in turn executes the generated translation and both nested
    PRNG calls. *)
Definition us_linked_white_puff_2_execution_claim : Prop :=
  exists linked seed_block current_block puff_block translate_block
      random_float_block random_u16_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) WPUS._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) WPUS._bhv_white_puff_2_loop =
      Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal WPUS.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      WPUSOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal WPUSOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal WPUSBS.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) WPUSBS._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal WPUSBS.f_random_u16) /\
    forall memory_before object_block x_before z_before,
      us_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal WPUS.f_bhv_white_puff_2_loop) []
          E0 memory_after Vundef /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x
            white_puff_random_range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z
            white_puff_random_range)) /\
        preserves_loads_outside_two_blocks memory_before memory_after
          seed_block object_block /\
        preserves_all_valid_accesses memory_before memory_after.

Theorem checked_us_linked_white_puff_2_execution :
  us_linked_white_puff_2_execution_claim.
Proof.
  destruct us_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked WPUSBS._gRandomSeed16
    (Gvar WPUSBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - destruct (linked_right_resolves_symbol us_dust_typed_core
      us_dust_leaf_program linked WPUS._gCurrentObject
      (Gvar WPUS.v_gCurrentObject) Hlink) as [current_block Hcurrent].
    + vm_compute. reflexivity.
    + pose proof
        (us_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
        as [_ [_ [[puff_block [Hpuff_symbol Hpuff_function]]
          [[random_float_block [Hfloat_symbol Hfloat_function]]
           [random_u16_block [Hu16_symbol Hu16_function]]]]]].
      destruct (us_typed_link_resolves_obj_translate_xz_random linked Hlink)
        as [translate_block [Htranslate_symbol Htranslate_function]].
      exists linked, seed_block, current_block, puff_block, translate_block,
        random_float_block, random_u16_block.
      split; [exact Hlink|].
      split; [exact Hseed|].
      split; [exact Hcurrent|].
      split; [exact Hpuff_symbol|].
      split; [exact Hpuff_function|].
      split; [exact Htranslate_symbol|].
      split; [exact Htranslate_function|].
      split; [exact Hfloat_symbol|].
      split; [exact Hfloat_function|].
      split; [exact Hu16_symbol|].
      split; [exact Hu16_function|].
      intros memory_before object_block x_before z_before Hmemory.
      destruct Hmemory as
        (Hcurrent_load & Htimer_zero & Hobject_seed & Hload_seed &
         Hwrite_seed & Hload_x & Hwrite_x & Hload_z & Hwrite_z).
      eapply generated_white_puff_2_timer_zero_executes_in_us_typed_link;
        eauto.
Qed.

Definition jp_linked_white_puff_2_execution_claim : Prop :=
  exists linked seed_block current_block puff_block translate_block
      random_float_block random_u16_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) WPJP._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) WPJP._bhv_white_puff_2_loop =
      Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal WPJP.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      WPJPOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal WPJPOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal WPJPBS.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) WPJPBS._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal WPJPBS.f_random_u16) /\
    forall memory_before object_block x_before z_before,
      jp_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal WPJP.f_bhv_white_puff_2_loop) []
          E0 memory_after Vundef /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x
            white_puff_random_range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z
            white_puff_random_range)) /\
        preserves_loads_outside_two_blocks memory_before memory_after
          seed_block object_block /\
        preserves_all_valid_accesses memory_before memory_after.

Theorem checked_jp_linked_white_puff_2_execution :
  jp_linked_white_puff_2_execution_claim.
Proof.
  destruct jp_dust_typed_link_exists as [linked Hlink].
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked WPJPBS._gRandomSeed16
    (Gvar WPJPBS.v_gRandomSeed16) Hlink) as [seed_block Hseed].
  - vm_compute. reflexivity.
  - destruct (linked_right_resolves_symbol jp_dust_typed_core
      jp_dust_leaf_program linked WPJP._gCurrentObject
      (Gvar WPJP.v_gCurrentObject) Hlink) as [current_block Hcurrent].
    + vm_compute. reflexivity.
    + pose proof
        (jp_typed_link_resolves_selected_behavior_leaf_chain linked Hlink)
        as [_ [_ [[puff_block [Hpuff_symbol Hpuff_function]]
          [[random_float_block [Hfloat_symbol Hfloat_function]]
           [random_u16_block [Hu16_symbol Hu16_function]]]]]].
      destruct (jp_typed_link_resolves_obj_translate_xz_random linked Hlink)
        as [translate_block [Htranslate_symbol Htranslate_function]].
      exists linked, seed_block, current_block, puff_block, translate_block,
        random_float_block, random_u16_block.
      split; [exact Hlink|].
      split; [exact Hseed|].
      split; [exact Hcurrent|].
      split; [exact Hpuff_symbol|].
      split; [exact Hpuff_function|].
      split; [exact Htranslate_symbol|].
      split; [exact Htranslate_function|].
      split; [exact Hfloat_symbol|].
      split; [exact Hfloat_function|].
      split; [exact Hu16_symbol|].
      split; [exact Hu16_function|].
      intros memory_before object_block x_before z_before Hmemory.
      destruct Hmemory as
        (Hcurrent_load & Htimer_zero & Hobject_seed & Hload_seed &
         Hwrite_seed & Hload_x & Hwrite_x & Hload_z & Hwrite_z).
      eapply generated_white_puff_2_timer_zero_executes_in_jp_typed_link;
        eauto.
Qed.

Definition linked_white_puff_2_execution_us_jp_claim : Prop :=
  us_linked_white_puff_2_execution_claim /\
  jp_linked_white_puff_2_execution_claim.

Theorem checked_linked_white_puff_2_execution_us_jp :
  linked_white_puff_2_execution_us_jp_claim.
Proof.
  split.
  - exact checked_us_linked_white_puff_2_execution.
  - exact checked_jp_linked_white_puff_2_execution.
Qed.

(** The executable frontier above begins at the timer-zero invocation of the
    generated white-puff-2 native.  It does not yet execute the behavior-script
    interpreter that chooses this native, [spawn_object_at_origin], object-pool
    allocation, or the object-list scheduler; those remain distinct generated
    Clight big-step obligations with their own concrete memory images. *)
