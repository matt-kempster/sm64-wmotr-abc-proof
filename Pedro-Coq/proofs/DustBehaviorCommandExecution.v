From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Floats Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import
  us_behavior_actions us_behavior_data us_behavior_script us_object_helpers
  jp_behavior_actions jp_behavior_data jp_behavior_script jp_object_helpers.
From Pedro.Proofs Require Import
  DustClightLink DustLinkedExecution DustLinkedExecutionJP
  DustWhitePuffExecution.

Import ListNotations.

Module BCUS := us_behavior_script.
Module BCUSBA := us_behavior_actions.
Module BCUSBD := us_behavior_data.
Module BCUSOH := us_object_helpers.
Module BCJP := jp_behavior_script.
Module BCJPBA := jp_behavior_actions.
Module BCJPBD := jp_behavior_data.
Module BCJPOH := jp_object_helpers.

(** In [bhvWhitePuff2], word 5 (byte 20) is CALL_NATIVE, word 6
    (byte 24) is the native pointer, and the next command is word 7
    (byte 28).  These are exact initializer facts, not a reconstructed script. *)
Lemma us_white_puff_2_call_native_initializer_exact :
  nth_error (gvar_init BCUSBD.v_bhvWhitePuff2) 5 =
    Some (Init_int32 (Int.repr 201326592)) /\
  nth_error (gvar_init BCUSBD.v_bhvWhitePuff2) 6 =
    Some (Init_addrof BCUSBA._bhv_white_puff_2_loop Ptrofs.zero).
Proof. vm_compute. split; reflexivity. Qed.

Lemma jp_white_puff_2_call_native_initializer_exact :
  nth_error (gvar_init BCJPBD.v_bhvWhitePuff2) 5 =
    Some (Init_int32 (Int.repr 201326592)) /\
  nth_error (gvar_init BCJPBD.v_bhvWhitePuff2) 6 =
    Some (Init_addrof BCJPBA._bhv_white_puff_2_loop Ptrofs.zero).
Proof. vm_compute. split; reflexivity. Qed.

Definition call_native_command_offset : ptrofs := Ptrofs.repr 20.
Definition call_native_function_offset : Z := 24.
Definition call_native_next_offset : ptrofs := Ptrofs.repr 28.

Definition call_native_function_word_expr : expr :=
  Ederef
    (Ebinop Oadd
      (Etempvar BCUS._t'2 (tptr tuint))
      (Econst_int (Int.repr 1) tint) (tptr tuint))
    tuint.

Definition bhv_cmd_call_native_body : statement :=
  Ssequence
    (Ssequence
      (Sset BCUS._t'2 (Evar BCUS._gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset BCUS._t'3 call_native_function_word_expr)
        (Sset BCUS._behaviorFunc
          (Ecast (Etempvar BCUS._t'3 tuint) (tptr tvoid)))))
    (Ssequence
      (Scall None
        (Etempvar BCUS._behaviorFunc
          (tptr (Tfunction nil tvoid cc_default))) nil)
      (Ssequence
        (Ssequence
          (Sset BCUS._t'1 (Evar BCUS._gCurBhvCommand (tptr tuint)))
          (Sassign
            (Evar BCUS._gCurBhvCommand (tptr tuint))
            (Ebinop Oadd
              (Etempvar BCUS._t'1 (tptr tuint))
              (Econst_int (Int.repr 2) tint) (tptr tuint))))
        (Sreturn (Some (Econst_int Int.zero tint))))).

Lemma us_bhv_cmd_call_native_body_exact :
  fn_body BCUS.f_bhv_cmd_call_native = bhv_cmd_call_native_body.
Proof. reflexivity. Qed.

Lemma bhv_cmd_call_native_us_jp_identical :
  BCUS.f_bhv_cmd_call_native = BCJP.f_bhv_cmd_call_native.
Proof. reflexivity. Qed.

Lemma eval_behavior_command_cursor :
  forall (ge : Clight.genv) (environment : env) (locals : temp_env)
      (memory : mem) (cursor_block script_block : block),
    environment ! BCUS._gCurBhvCommand = None ->
    Genv.find_symbol ge BCUS._gCurBhvCommand = Some cursor_block ->
    Mem.load Mptr memory cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    eval_expr ge environment locals memory
      (Evar BCUS._gCurBhvCommand (tptr tuint))
      (Vptr script_block call_native_command_offset).
Proof.
  intros ge environment locals memory cursor_block script_block
    Hlocal Hsymbol Hload.
  eapply eval_Elvalue.
  - eapply eval_Evar_global; [exact Hlocal|exact Hsymbol].
  - eapply deref_loc_value.
    + reflexivity.
    + cbn. exact Hload.
Qed.

Lemma eval_call_native_function_word :
  forall (ge : Clight.genv) (environment : env) (locals : temp_env)
      (memory : mem) (script_block native_block : block),
    locals ! BCUS._t'2 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.load Mint32 memory script_block call_native_function_offset =
      Some (Vptr native_block Ptrofs.zero) ->
    eval_expr ge environment locals memory call_native_function_word_expr
      (Vptr native_block Ptrofs.zero).
Proof.
  intros ge environment locals memory script_block native_block Htemp Hload.
  eapply eval_Elvalue.
  - unfold call_native_function_word_expr.
    eapply eval_Ederef.
    eapply eval_Ebinop.
    + eapply eval_Etempvar. exact Htemp.
    + constructor.
    + unfold call_native_command_offset.
      cbn. reflexivity.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, call_native_function_offset.
      change (Mem.load Mint32 memory script_block 24 =
        Some (Vptr native_block Ptrofs.zero)).
      exact Hload.
Qed.

Lemma assign_behavior_command_cursor :
  forall (cenv : composite_env) (memory_before memory_after : mem)
      (cursor_block script_block : block),
    Mem.store Mptr memory_before cursor_block 0
      (Vptr script_block call_native_next_offset) = Some memory_after ->
    assign_loc cenv (tptr tuint) memory_before cursor_block Ptrofs.zero Full
      (Vptr script_block call_native_next_offset) memory_after.
Proof.
  intros cenv memory_before memory_after cursor_block script_block Hstore.
  eapply assign_loc_value.
  - reflexivity.
  - unfold Mem.storev.
    change (Mem.store Mptr memory_before cursor_block 0
      (Vptr script_block call_native_next_offset) = Some memory_after).
    exact Hstore.
Qed.

(** Exact execution of the generated CALL_NATIVE handler around an actual
    callee big-step.  The native is abstract only as a generated Clight
    function argument; no external or hand-written transition is introduced. *)
Theorem generated_bhv_cmd_call_native_executes_in_any_genv :
  forall (ge : Clight.genv) (native : function)
      (memory_before memory_native memory_after : mem)
      (cursor_block script_block native_block : block),
    Genv.find_symbol ge BCUS._gCurBhvCommand = Some cursor_block ->
    Genv.find_funct_ptr ge native_block = Some (Internal native) ->
    type_of_function native = Tfunction nil tvoid cc_default ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.load Mint32 memory_before script_block call_native_function_offset =
      Some (Vptr native_block Ptrofs.zero) ->
    eval_funcall function_entry2 ge memory_before (Internal native) []
      E0 memory_native Vundef ->
    Mem.load Mptr memory_native cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.store Mptr memory_native cursor_block 0
      (Vptr script_block call_native_next_offset) = Some memory_after ->
    eval_funcall function_entry2 ge memory_before
      (Internal BCUS.f_bhv_cmd_call_native) []
      E0 memory_after (Vint Int.zero).
Proof.
  intros ge native memory_before memory_native memory_after cursor_block
    script_block native_block Hcursor_symbol Hnative_function Hnative_type
    Hcursor_before Hnative_word Hnative Hcursor_native Hstore_cursor.
  eapply eval_funcall_internal.
  - eapply function_entry2_intro.
    + constructor.
    + constructor.
    + intros x y Hnone. inversion Hnone.
    + constructor.
    + reflexivity.
  - rewrite us_bhv_cmd_call_native_body_exact.
    unfold bhv_cmd_call_native_body.
    eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sset.
        eapply eval_behavior_command_cursor.
        -- cbn. reflexivity.
        -- exact Hcursor_symbol.
        -- exact Hcursor_before.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_call_native_function_word.
           ++ apply PTree.gss.
           ++ exact Hnative_word.
        -- eapply exec_Sset.
           eapply eval_Ecast.
           ++ eapply eval_Etempvar. apply PTree.gss.
           ++ cbn. reflexivity.
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Scall.
        -- cbn. reflexivity.
        -- eapply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- eapply find_funct_at_zero_offset. exact Hnative_function.
        -- exact Hnative_type.
        -- exact Hnative.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_behavior_command_cursor.
              ** cbn. reflexivity.
              ** exact Hcursor_symbol.
              ** exact Hcursor_native.
           ++ eapply exec_Sassign.
              ** eapply eval_Evar_global.
                 --- cbn. reflexivity.
                 --- exact Hcursor_symbol.
              ** eapply eval_Ebinop.
                 --- eapply eval_Etempvar. apply PTree.gss.
                 --- constructor.
                 --- unfold call_native_command_offset,
                      call_native_next_offset.
                     cbn. reflexivity.
              ** cbn. reflexivity.
              ** eapply assign_behavior_command_cursor. exact Hstore_cursor.
        -- eapply exec_Sreturn_some. constructor.
  - cbn. split; [ discriminate | cbn; reflexivity ].
  - cbn. reflexivity.
Qed.

(** US composition with the closed white-puff-2 execution.  The exposed
    frame theorem supplies the post-native cursor load and writability needed
    by the generated handler's reload and store. *)
Theorem generated_call_native_white_puff_2_executes_in_us_typed_link :
  forall linked memory_before seed_block current_block cursor_block
      script_block puff_block translate_block random_float_block
      random_u16_block object_block x_before z_before,
    link us_dust_typed_core us_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) BCUS._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) BCUSBA._gCurrentObject =
      Some current_block ->
    Genv.find_symbol (Clight.globalenv linked) BCUS._gCurBhvCommand =
      Some cursor_block ->
    Genv.find_symbol (Clight.globalenv linked)
      BCUSBA._bhv_white_puff_2_loop = Some puff_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCUSBA.f_bhv_white_puff_2_loop) ->
    Genv.find_symbol (Clight.globalenv linked)
      BCUSOH._obj_translate_xz_random = Some translate_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCUSOH.f_obj_translate_xz_random) ->
    Genv.find_symbol (Clight.globalenv linked) BCUS._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal BCUS.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) BCUS._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal BCUS.f_random_u16) ->
    cursor_block <> seed_block ->
    cursor_block <> object_block ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
    Mem.load Mint32 memory_before script_block call_native_function_offset =
      Some (Vptr puff_block Ptrofs.zero) ->
    us_white_puff_2_memory_image memory_before seed_block current_block
      object_block x_before z_before ->
    exists memory_after random_x random_z,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal BCUS.f_bhv_cmd_call_native) []
        E0 memory_after (Vint Int.zero) /\
      Mem.load Mptr memory_after cursor_block 0 =
        Some (Vptr script_block call_native_next_offset) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range)).
Proof.
  intros linked memory_before seed_block current_block cursor_block
    script_block puff_block translate_block random_float_block
    random_u16_block object_block x_before z_before Hlink Hseed
    Hcurrent_symbol Hcursor_symbol Hpuff_symbol Hpuff_function
    Htranslate_symbol Htranslate_function Hfloat_symbol Hfloat_function
    Hu16_symbol Hu16_function Hcursor_seed Hcursor_object Hcursor_load
    Hcursor_write Hnative_word Hmemory.
  destruct Hmemory as
    (Hcurrent_load & Htimer_zero & Hobject_seed & Hload_seed & Hwrite_seed &
     Hload_x & Hwrite_x & Hload_z & Hwrite_z).
  destruct (generated_white_puff_2_timer_zero_executes_in_us_typed_link
    linked memory_before seed_block current_block translate_block
    random_float_block random_u16_block object_block x_before z_before
    Hlink Hseed Hcurrent_symbol Htranslate_symbol Htranslate_function
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hcurrent_load
    Htimer_zero Hobject_seed Hload_seed Hwrite_seed Hload_x Hwrite_x
    Hload_z Hwrite_z)
    as (memory_native & random_x & random_z & Hnative & Hseed_native &
        Hx_native & Hz_native & Hframe & Hvalid).
  pose proof (Hframe Mptr cursor_block 0
    (Vptr script_block call_native_command_offset) Hcursor_seed
    Hcursor_object Hcursor_load) as Hcursor_native.
  pose proof (Hvalid Mptr cursor_block 0 Writable Hcursor_write)
    as Hcursor_native_write.
  destruct (Mem.valid_access_store memory_native Mptr cursor_block 0
    (Vptr script_block call_native_next_offset) Hcursor_native_write)
    as [memory_after Hstore_cursor].
  pose proof (generated_bhv_cmd_call_native_executes_in_any_genv
    (Clight.globalenv linked) BCUSBA.f_bhv_white_puff_2_loop memory_before
    memory_native memory_after cursor_block script_block puff_block
    Hcursor_symbol Hpuff_function (eq_refl _)
    Hcursor_load Hnative_word Hnative
    Hcursor_native Hstore_cursor) as Hcommand.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_cursor)
    as Hcursor_after.
  cbn in Hcursor_after.
  assert (Hseed_after :
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hseed_native.
    - left. exact (not_eq_sym Hcursor_seed). }
  assert (Hx_after :
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hx_native.
    - left. exact (not_eq_sym Hcursor_object). }
  assert (Hz_after :
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hz_native.
    - left. exact (not_eq_sym Hcursor_object). }
  exists memory_after, random_x, random_z.
  split; [exact Hcommand|].
  split; [exact Hcursor_after|].
  split; [exact Hseed_after|].
  split; [exact Hx_after|exact Hz_after].
Qed.

Theorem generated_call_native_white_puff_2_executes_in_jp_typed_link :
  forall linked memory_before seed_block current_block cursor_block
      script_block puff_block translate_block random_float_block
      random_u16_block object_block x_before z_before,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked ->
    Genv.find_symbol (Clight.globalenv linked) BCJP._gRandomSeed16 =
      Some seed_block ->
    Genv.find_symbol (Clight.globalenv linked) BCJPBA._gCurrentObject =
      Some current_block ->
    Genv.find_symbol (Clight.globalenv linked) BCJP._gCurBhvCommand =
      Some cursor_block ->
    Genv.find_symbol (Clight.globalenv linked)
      BCJPBA._bhv_white_puff_2_loop = Some puff_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCJPBA.f_bhv_white_puff_2_loop) ->
    Genv.find_symbol (Clight.globalenv linked)
      BCJPOH._obj_translate_xz_random = Some translate_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCJPOH.f_obj_translate_xz_random) ->
    Genv.find_symbol (Clight.globalenv linked) BCJP._random_float =
      Some random_float_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal BCJP.f_random_float) ->
    Genv.find_symbol (Clight.globalenv linked) BCJP._random_u16 =
      Some random_u16_block ->
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal BCJP.f_random_u16) ->
    cursor_block <> seed_block ->
    cursor_block <> object_block ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
    Mem.load Mint32 memory_before script_block call_native_function_offset =
      Some (Vptr puff_block Ptrofs.zero) ->
    jp_white_puff_2_memory_image memory_before seed_block current_block
      object_block x_before z_before ->
    exists memory_after random_x random_z,
      eval_funcall function_entry2 (Clight.globalenv linked) memory_before
        (Internal BCJP.f_bhv_cmd_call_native) []
        E0 memory_after (Vint Int.zero) /\
      Mem.load Mptr memory_after cursor_block 0 =
        Some (Vptr script_block call_native_next_offset) /\
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882)) /\
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range)) /\
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range)).
Proof.
  intros linked memory_before seed_block current_block cursor_block
    script_block puff_block translate_block random_float_block
    random_u16_block object_block x_before z_before Hlink Hseed
    Hcurrent_symbol Hcursor_symbol Hpuff_symbol Hpuff_function
    Htranslate_symbol Htranslate_function Hfloat_symbol Hfloat_function
    Hu16_symbol Hu16_function Hcursor_seed Hcursor_object Hcursor_load
    Hcursor_write Hnative_word Hmemory.
  destruct Hmemory as
    (Hcurrent_load & Htimer_zero & Hobject_seed & Hload_seed & Hwrite_seed &
     Hload_x & Hwrite_x & Hload_z & Hwrite_z).
  destruct (generated_white_puff_2_timer_zero_executes_in_jp_typed_link
    linked memory_before seed_block current_block translate_block
    random_float_block random_u16_block object_block x_before z_before
    Hlink Hseed Hcurrent_symbol Htranslate_symbol Htranslate_function
    Hfloat_symbol Hfloat_function Hu16_symbol Hu16_function Hcurrent_load
    Htimer_zero Hobject_seed Hload_seed Hwrite_seed Hload_x Hwrite_x
    Hload_z Hwrite_z)
    as (memory_native & random_x & random_z & Hnative & Hseed_native &
        Hx_native & Hz_native & Hframe & Hvalid).
  pose proof (Hframe Mptr cursor_block 0
    (Vptr script_block call_native_command_offset) Hcursor_seed
    Hcursor_object Hcursor_load) as Hcursor_native.
  pose proof (Hvalid Mptr cursor_block 0 Writable Hcursor_write)
    as Hcursor_native_write.
  destruct (Mem.valid_access_store memory_native Mptr cursor_block 0
    (Vptr script_block call_native_next_offset) Hcursor_native_write)
    as [memory_after Hstore_cursor].
  pose proof (generated_bhv_cmd_call_native_executes_in_any_genv
    (Clight.globalenv linked) BCJPBA.f_bhv_white_puff_2_loop memory_before
    memory_native memory_after cursor_block script_block puff_block
    Hcursor_symbol Hpuff_function (eq_refl _)
    Hcursor_load Hnative_word Hnative
    Hcursor_native Hstore_cursor) as Hcommand_us.
  rewrite bhv_cmd_call_native_us_jp_identical in Hcommand_us.
  pose proof (Mem.load_store_same _ _ _ _ _ _ Hstore_cursor)
    as Hcursor_after.
  cbn in Hcursor_after.
  assert (Hseed_after :
      Mem.load Mint16unsigned memory_after seed_block 0 =
        Some (Vint (Int.repr 55882))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hseed_native.
    - left. exact (not_eq_sym Hcursor_seed). }
  assert (Hx_after :
      Mem.load Mfloat32 memory_after object_block 160 =
        Some (Vsingle (translated_coordinate x_before random_x
          white_puff_random_range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hx_native.
    - left. exact (not_eq_sym Hcursor_object). }
  assert (Hz_after :
      Mem.load Mfloat32 memory_after object_block 168 =
        Some (Vsingle (translated_coordinate z_before random_z
          white_puff_random_range))).
  { rewrite (Mem.load_store_other _ _ _ _ _ _ Hstore_cursor).
    - exact Hz_native.
    - left. exact (not_eq_sym Hcursor_object). }
  exists memory_after, random_x, random_z.
  split; [exact Hcommand_us|].
  split; [exact Hcursor_after|].
  split; [exact Hseed_after|].
  split; [exact Hx_after|exact Hz_after].
Qed.

(** This closes the generated CALL_NATIVE command itself.  The remaining
    upward boundary is [cur_obj_update]'s command-table fetch/loop and the
    object-list scheduler that invokes it; allocation/spawn remains a separate
    downward boundary. *)

(** Closed, linked US/JP capstones for the command-execution frontier.  As in
    the white-puff capstones, the memory image is a premise: the theorem proves
    execution of the exact generated functions once the linked globals and
    concrete command/object cells contain the stated values. *)
Definition us_linked_call_native_white_puff_2_execution_claim : Prop :=
  exists linked seed_block current_block cursor_block puff_block
      translate_block random_float_block random_u16_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) BCUS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) BCUSBA._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) BCUS._gCurBhvCommand =
      Some cursor_block /\
    Genv.find_symbol (Clight.globalenv linked)
      BCUSBA._bhv_white_puff_2_loop = Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCUSBA.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCUSOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCUSOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) BCUS._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal BCUS.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) BCUS._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal BCUS.f_random_u16) /\
    forall memory_before script_block object_block x_before z_before,
      cursor_block <> seed_block ->
      cursor_block <> object_block ->
      Mem.load Mptr memory_before cursor_block 0 =
        Some (Vptr script_block call_native_command_offset) ->
      Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
      Mem.load Mint32 memory_before script_block call_native_function_offset =
        Some (Vptr puff_block Ptrofs.zero) ->
      us_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal BCUS.f_bhv_cmd_call_native) []
          E0 memory_after (Vint Int.zero) /\
        Mem.load Mptr memory_after cursor_block 0 =
          Some (Vptr script_block call_native_next_offset) /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x
            white_puff_random_range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z
            white_puff_random_range)).

Theorem checked_us_linked_call_native_white_puff_2_execution :
  us_linked_call_native_white_puff_2_execution_claim.
Proof.
  destruct checked_us_linked_white_puff_2_execution as
    (linked & seed_block & current_block & puff_block & translate_block &
     random_float_block & random_u16_block & Hlink & Hseed & Hcurrent &
     Hpuff_symbol & Hpuff_function & Htranslate_symbol &
     Htranslate_function & Hfloat_symbol & Hfloat_function & Hu16_symbol &
     Hu16_function & Hwhite_puff).
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked BCUS._gCurBhvCommand
    (Gvar BCUS.v_gCurBhvCommand) Hlink) as [cursor_block Hcursor_symbol].
  - vm_compute. reflexivity.
  - exists linked, seed_block, current_block, cursor_block, puff_block,
      translate_block, random_float_block, random_u16_block.
    refine (conj Hlink _).
    refine (conj Hseed _).
    refine (conj Hcurrent _).
    refine (conj Hcursor_symbol _).
    refine (conj Hpuff_symbol _).
    refine (conj Hpuff_function _).
    refine (conj Htranslate_symbol _).
    refine (conj Htranslate_function _).
    refine (conj Hfloat_symbol _).
    refine (conj Hfloat_function _).
    refine (conj Hu16_symbol _).
    refine (conj Hu16_function _).
    intros memory_before script_block object_block x_before z_before
      Hcursor_seed Hcursor_object Hcursor_load Hcursor_write Hnative_word
      Hmemory.
    eapply generated_call_native_white_puff_2_executes_in_us_typed_link;
      eauto.
Qed.

Definition jp_linked_call_native_white_puff_2_execution_claim : Prop :=
  exists linked seed_block current_block cursor_block puff_block
      translate_block random_float_block random_u16_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) BCJP._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) BCJPBA._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) BCJP._gCurBhvCommand =
      Some cursor_block /\
    Genv.find_symbol (Clight.globalenv linked)
      BCJPBA._bhv_white_puff_2_loop = Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCJPBA.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCJPOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCJPOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) BCJP._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal BCJP.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) BCJP._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal BCJP.f_random_u16) /\
    forall memory_before script_block object_block x_before z_before,
      cursor_block <> seed_block ->
      cursor_block <> object_block ->
      Mem.load Mptr memory_before cursor_block 0 =
        Some (Vptr script_block call_native_command_offset) ->
      Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
      Mem.load Mint32 memory_before script_block call_native_function_offset =
        Some (Vptr puff_block Ptrofs.zero) ->
      jp_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after random_x random_z,
        eval_funcall function_entry2 (Clight.globalenv linked) memory_before
          (Internal BCJP.f_bhv_cmd_call_native) []
          E0 memory_after (Vint Int.zero) /\
        Mem.load Mptr memory_after cursor_block 0 =
          Some (Vptr script_block call_native_next_offset) /\
        Mem.load Mint16unsigned memory_after seed_block 0 =
          Some (Vint (Int.repr 55882)) /\
        Mem.load Mfloat32 memory_after object_block 160 =
          Some (Vsingle (translated_coordinate x_before random_x
            white_puff_random_range)) /\
        Mem.load Mfloat32 memory_after object_block 168 =
          Some (Vsingle (translated_coordinate z_before random_z
            white_puff_random_range)).

Theorem checked_jp_linked_call_native_white_puff_2_execution :
  jp_linked_call_native_white_puff_2_execution_claim.
Proof.
  destruct checked_jp_linked_white_puff_2_execution as
    (linked & seed_block & current_block & puff_block & translate_block &
     random_float_block & random_u16_block & Hlink & Hseed & Hcurrent &
     Hpuff_symbol & Hpuff_function & Htranslate_symbol &
     Htranslate_function & Hfloat_symbol & Hfloat_function & Hu16_symbol &
     Hu16_function & Hwhite_puff).
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked BCJP._gCurBhvCommand
    (Gvar BCJP.v_gCurBhvCommand) Hlink) as [cursor_block Hcursor_symbol].
  - vm_compute. reflexivity.
  - exists linked, seed_block, current_block, cursor_block, puff_block,
      translate_block, random_float_block, random_u16_block.
    refine (conj Hlink _).
    refine (conj Hseed _).
    refine (conj Hcurrent _).
    refine (conj Hcursor_symbol _).
    refine (conj Hpuff_symbol _).
    refine (conj Hpuff_function _).
    refine (conj Htranslate_symbol _).
    refine (conj Htranslate_function _).
    refine (conj Hfloat_symbol _).
    refine (conj Hfloat_function _).
    refine (conj Hu16_symbol _).
    refine (conj Hu16_function _).
    intros memory_before script_block object_block x_before z_before
      Hcursor_seed Hcursor_object Hcursor_load Hcursor_write Hnative_word
      Hmemory.
    eapply generated_call_native_white_puff_2_executes_in_jp_typed_link;
      eauto.
Qed.

Definition linked_call_native_white_puff_2_execution_us_jp_claim : Prop :=
  us_linked_call_native_white_puff_2_execution_claim /\
  jp_linked_call_native_white_puff_2_execution_claim.

Theorem checked_linked_call_native_white_puff_2_execution_us_jp :
  linked_call_native_white_puff_2_execution_us_jp_claim.
Proof.
  split.
  - exact checked_us_linked_call_native_white_puff_2_execution.
  - exact checked_jp_linked_call_native_white_puff_2_execution.
Qed.
