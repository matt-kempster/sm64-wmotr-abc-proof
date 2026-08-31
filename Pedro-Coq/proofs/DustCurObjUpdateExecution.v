From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Linking Maps Memory Values.
From Pedro.Generated Require Import us_behavior_script jp_behavior_script.
From Pedro.Proofs Require Import
  DustClightLink DustLinkedExecution DustWhitePuffExecution
  DustBehaviorCommandExecution.

Import ListNotations.

Module CUUS := us_behavior_script.
Module CUJP := jp_behavior_script.

(** The interpreter table entry used by CALL_NATIVE is taken directly from
    each generated translation unit.  Opcode [0x0c] indexes entry 12. *)
Lemma us_behavior_command_table_call_native_entry_exact :
  nth_error (gvar_init CUUS.v_BehaviorCmdTable) 12 =
    Some (Init_addrof CUUS._bhv_cmd_call_native Ptrofs.zero).
Proof. vm_compute. reflexivity. Qed.

Lemma jp_behavior_command_table_call_native_entry_exact :
  nth_error (gvar_init CUJP.v_BehaviorCmdTable) 12 =
    Some (Init_addrof CUJP._bhv_cmd_call_native Ptrofs.zero).
Proof. vm_compute. reflexivity. Qed.

Definition call_native_opcode_word : int := Int.repr 201326592.
Definition call_native_table_byte_offset : Z := 48.

Definition behavior_command_procedure_type : type :=
  tptr (Tfunction nil tint cc_default).

(** These are the two exact statements supplied as the body and increment
    components of [cur_obj_update]'s generated [Sloop]. *)
Definition cur_obj_update_dispatch_body : statement :=
  Ssequence
    (Ssequence
      (Sset CUUS._t'50 (Evar CUUS._gCurBhvCommand (tptr tuint)))
      (Ssequence
        (Sset CUUS._t'51
          (Ederef (Etempvar CUUS._t'50 (tptr tuint)) tuint))
        (Sset CUUS._bhvCmdProc
          (Ederef
            (Ebinop Oadd
              (Evar CUUS._BehaviorCmdTable
                (tarray behavior_command_procedure_type 56))
              (Ebinop Oshr (Etempvar CUUS._t'51 tuint)
                (Econst_int (Int.repr 24) tint) tuint)
              (tptr behavior_command_procedure_type))
            behavior_command_procedure_type))))
    (Ssequence
      (Scall (Some CUUS._t'3)
        (Etempvar CUUS._bhvCmdProc behavior_command_procedure_type) nil)
      (Sset CUUS._bhvProcResult (Etempvar CUUS._t'3 tint))).

Definition cur_obj_update_dispatch_continue_test : statement :=
  Sifthenelse
    (Ebinop Oeq (Etempvar CUUS._bhvProcResult tint)
      (Econst_int Int.zero tint) tint)
    Sskip Sbreak.

Definition cur_obj_update_call_native_loop_cycle : statement :=
  Ssequence cur_obj_update_dispatch_body
    cur_obj_update_dispatch_continue_test.

(** Locate the first generated loop without rewriting the very large function
    body.  No earlier branch of [cur_obj_update] contains a loop. *)
Fixpoint first_loop_parts (statement_to_search : statement)
    : option (statement * statement) :=
  match statement_to_search with
  | Ssequence first_statement second_statement =>
      match first_loop_parts first_statement with
      | Some parts => Some parts
      | None => first_loop_parts second_statement
      end
  | Sifthenelse _ if_true if_false =>
      match first_loop_parts if_true with
      | Some parts => Some parts
      | None => first_loop_parts if_false
      end
  | Sloop body increment => Some (body, increment)
  | _ => None
  end.

Lemma us_cur_obj_update_dispatch_loop_exact :
  first_loop_parts (fn_body CUUS.f_cur_obj_update) =
    Some (cur_obj_update_dispatch_body,
          cur_obj_update_dispatch_continue_test).
Proof. vm_compute. reflexivity. Qed.

Lemma jp_cur_obj_update_dispatch_loop_exact :
  first_loop_parts (fn_body CUJP.f_cur_obj_update) =
    Some (cur_obj_update_dispatch_body,
          cur_obj_update_dispatch_continue_test).
Proof. vm_compute. reflexivity. Qed.

Lemma eval_call_native_opcode_word :
  forall (ge : Clight.genv) environment locals memory script_block,
    locals ! CUUS._t'50 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.load Mint32 memory script_block 20 =
      Some (Vint call_native_opcode_word) ->
    eval_expr ge environment locals memory
      (Ederef (Etempvar CUUS._t'50 (tptr tuint)) tuint)
      (Vint call_native_opcode_word).
Proof.
  intros ge environment locals memory script_block Hcursor Hopcode.
  eapply eval_Elvalue.
  - eapply eval_Ederef.
    eapply eval_Etempvar. exact Hcursor.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, call_native_command_offset.
      change (Mem.load Mint32 memory script_block 20 =
        Some (Vint call_native_opcode_word)).
      exact Hopcode.
Qed.

Lemma eval_call_native_table_entry :
  forall (ge : Clight.genv) environment locals memory
      table_block handler_block,
    environment ! CUUS._BehaviorCmdTable = None ->
    Genv.find_symbol ge CUUS._BehaviorCmdTable = Some table_block ->
    locals ! CUUS._t'51 = Some (Vint call_native_opcode_word) ->
    Mem.load Mptr memory table_block call_native_table_byte_offset =
      Some (Vptr handler_block Ptrofs.zero) ->
    eval_expr ge environment locals memory
      (Ederef
        (Ebinop Oadd
          (Evar CUUS._BehaviorCmdTable
            (tarray behavior_command_procedure_type 56))
          (Ebinop Oshr (Etempvar CUUS._t'51 tuint)
            (Econst_int (Int.repr 24) tint) tuint)
          (tptr behavior_command_procedure_type))
        behavior_command_procedure_type)
      (Vptr handler_block Ptrofs.zero).
Proof.
  intros ge environment locals memory table_block handler_block
    Hlocal Hsymbol Hopcode Htable.
  eapply eval_Elvalue.
  - eapply eval_Ederef.
    eapply eval_Ebinop.
    + eapply eval_Elvalue.
      * eapply eval_Evar_global; [exact Hlocal|exact Hsymbol].
      * eapply deref_loc_reference. reflexivity.
    + eapply eval_Ebinop.
      * eapply eval_Etempvar. exact Hopcode.
      * constructor.
      * cbn. reflexivity.
    + cbn. reflexivity.
  - eapply deref_loc_value.
    + reflexivity.
    + unfold Mem.loadv, call_native_table_byte_offset.
      change (Mem.load Mptr memory table_block 48 =
        Some (Vptr handler_block Ptrofs.zero)).
      exact Htable.
Qed.

(** One exact interpreter cycle: fetch opcode 0x0c from the current behavior
    cursor, load [BehaviorCmdTable[12]], indirectly execute the generated
    CALL_NATIVE handler, record its zero/CONTINUE result, and take the
    continue branch of the loop test.  The theorem intentionally does not
    claim an execution of the enclosing [Sloop]: a zero result requires the
    next iteration, which for [bhvWhitePuff2] is ADD_INT and then END_REPEAT. *)
Theorem generated_cur_obj_update_call_native_loop_cycle_executes_in_any_genv :
  forall (ge : Clight.genv) environment locals_before
      memory_before memory_after cursor_block script_block table_block
      handler_block,
    environment ! CUUS._gCurBhvCommand = None ->
    environment ! CUUS._BehaviorCmdTable = None ->
    Genv.find_symbol ge CUUS._gCurBhvCommand = Some cursor_block ->
    Genv.find_symbol ge CUUS._BehaviorCmdTable = Some table_block ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.load Mint32 memory_before script_block 20 =
      Some (Vint call_native_opcode_word) ->
    Mem.load Mptr memory_before table_block call_native_table_byte_offset =
      Some (Vptr handler_block Ptrofs.zero) ->
    Genv.find_funct_ptr ge handler_block =
      Some (Internal CUUS.f_bhv_cmd_call_native) ->
    eval_funcall function_entry2 ge memory_before
      (Internal CUUS.f_bhv_cmd_call_native) []
      E0 memory_after (Vint Int.zero) ->
    exists locals_after,
      exec_stmt function_entry2 ge environment locals_before memory_before
        cur_obj_update_call_native_loop_cycle
        E0 locals_after memory_after Out_normal /\
      locals_after ! CUUS._bhvProcResult = Some (Vint Int.zero).
Proof.
  intros ge environment locals_before memory_before memory_after cursor_block
    script_block table_block handler_block Hcursor_local Htable_local
    Hcursor_symbol Htable_symbol Hcursor Hopcode Htable Hhandler_function
    Hhandler.
  unfold cur_obj_update_call_native_loop_cycle,
    cur_obj_update_dispatch_body, cur_obj_update_dispatch_continue_test.
  eexists.
  split.
  - eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
    + eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Sset.
           eapply eval_behavior_command_cursor.
           ++ exact Hcursor_local.
           ++ exact Hcursor_symbol.
           ++ exact Hcursor.
        -- eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
           ++ eapply exec_Sset.
              eapply eval_call_native_opcode_word.
              ** apply PTree.gss.
              ** exact Hopcode.
           ++ eapply exec_Sset.
              eapply eval_call_native_table_entry.
              ** exact Htable_local.
              ** exact Htable_symbol.
              ** apply PTree.gss.
              ** exact Htable.
      * eapply exec_Sseq_1 with (t1 := E0) (t2 := E0).
        -- eapply exec_Scall.
           ++ cbn. reflexivity.
           ++ eapply eval_Etempvar. apply PTree.gss.
           ++ constructor.
           ++ eapply find_funct_at_zero_offset. exact Hhandler_function.
           ++ reflexivity.
           ++ exact Hhandler.
        -- eapply exec_Sset.
           eapply eval_Etempvar. apply PTree.gss.
    + eapply exec_Sifthenelse with (b := true).
      * eapply eval_Ebinop.
        -- eapply eval_Etempvar. apply PTree.gss.
        -- constructor.
        -- cbn. reflexivity.
      * cbn. reflexivity.
      * constructor.
  - apply PTree.gss.
Qed.

(** The relevant dispatcher statements and handler are syntactically the same
    in VERSION_US and VERSION_JP; only unrelated anonymous composite tags in
    other parts of [cur_obj_update] differ. *)
Lemma bhv_cmd_call_native_us_jp_function_exact :
  CUUS.f_bhv_cmd_call_native = CUJP.f_bhv_cmd_call_native.
Proof. reflexivity. Qed.

Corollary generated_cur_obj_update_call_native_loop_cycle_executes_in_jp_genv :
  forall (ge : Clight.genv) environment locals_before
      memory_before memory_after cursor_block script_block table_block
      handler_block,
    environment ! CUJP._gCurBhvCommand = None ->
    environment ! CUJP._BehaviorCmdTable = None ->
    Genv.find_symbol ge CUJP._gCurBhvCommand = Some cursor_block ->
    Genv.find_symbol ge CUJP._BehaviorCmdTable = Some table_block ->
    Mem.load Mptr memory_before cursor_block 0 =
      Some (Vptr script_block call_native_command_offset) ->
    Mem.load Mint32 memory_before script_block 20 =
      Some (Vint call_native_opcode_word) ->
    Mem.load Mptr memory_before table_block call_native_table_byte_offset =
      Some (Vptr handler_block Ptrofs.zero) ->
    Genv.find_funct_ptr ge handler_block =
      Some (Internal CUJP.f_bhv_cmd_call_native) ->
    eval_funcall function_entry2 ge memory_before
      (Internal CUJP.f_bhv_cmd_call_native) []
      E0 memory_after (Vint Int.zero) ->
    exists locals_after,
      exec_stmt function_entry2 ge environment locals_before memory_before
        cur_obj_update_call_native_loop_cycle
        E0 locals_after memory_after Out_normal /\
      locals_after ! CUJP._bhvProcResult = Some (Vint Int.zero).
Proof.
  intros ge environment locals_before memory_before memory_after cursor_block
    script_block table_block handler_block Hcursor_local Htable_local
    Hcursor_symbol Htable_symbol Hcursor Hopcode Htable Hhandler_function
    Hhandler.
  rewrite <- bhv_cmd_call_native_us_jp_function_exact in Hhandler_function.
  rewrite <- bhv_cmd_call_native_us_jp_function_exact in Hhandler.
  eapply generated_cur_obj_update_call_native_loop_cycle_executes_in_any_genv;
    eauto.
Qed.

(** Closed link-resolution and execution capstones.  Their only dynamic
    hypotheses are the concrete memory cells and permissions needed for the
    already-proved white-puff-2 CALL_NATIVE episode and this dispatcher cycle. *)
Definition us_linked_cur_obj_update_call_native_dispatch_cycle_claim : Prop :=
  exists linked seed_block current_block cursor_block table_block
      handler_block puff_block translate_block random_float_block
      random_u16_block,
    link us_dust_typed_core us_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._gCurBhvCommand =
      Some cursor_block /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._BehaviorCmdTable =
      Some table_block /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._bhv_cmd_call_native =
      Some handler_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) handler_block =
      Some (Internal CUUS.f_bhv_cmd_call_native) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCUSBA._bhv_white_puff_2_loop = Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCUSBA.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCUSOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCUSOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal CUUS.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) CUUS._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal CUUS.f_random_u16) /\
    forall environment locals_before memory_before script_block object_block
        x_before z_before,
      environment ! CUUS._gCurBhvCommand = None ->
      environment ! CUUS._BehaviorCmdTable = None ->
      cursor_block <> seed_block ->
      cursor_block <> object_block ->
      Mem.load Mptr memory_before cursor_block 0 =
        Some (Vptr script_block call_native_command_offset) ->
      Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
      Mem.load Mint32 memory_before script_block 20 =
        Some (Vint call_native_opcode_word) ->
      Mem.load Mptr memory_before table_block call_native_table_byte_offset =
        Some (Vptr handler_block Ptrofs.zero) ->
      Mem.load Mint32 memory_before script_block call_native_function_offset =
        Some (Vptr puff_block Ptrofs.zero) ->
      us_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after locals_after random_x random_z,
        exec_stmt function_entry2 (Clight.globalenv linked)
          environment locals_before memory_before
          cur_obj_update_call_native_loop_cycle
          E0 locals_after memory_after Out_normal /\
        locals_after ! CUUS._bhvProcResult = Some (Vint Int.zero) /\
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

Theorem checked_us_linked_cur_obj_update_call_native_dispatch_cycle :
  us_linked_cur_obj_update_call_native_dispatch_cycle_claim.
Proof.
  destruct checked_us_linked_call_native_white_puff_2_execution as
    (linked & seed_block & current_block & cursor_block & puff_block &
     translate_block & random_float_block & random_u16_block & Hlink &
     Hseed & Hcurrent & Hcursor_symbol & Hpuff_symbol & Hpuff_function &
     Htranslate_symbol & Htranslate_function & Hfloat_symbol &
     Hfloat_function & Hu16_symbol & Hu16_function & Hhandler_execution).
  destruct (linked_right_resolves_symbol us_dust_typed_core
    us_dust_leaf_program linked CUUS._BehaviorCmdTable
    (Gvar CUUS.v_BehaviorCmdTable) Hlink) as [table_block Htable_symbol].
  - vm_compute. reflexivity.
  - destruct (linked_right_resolves_internal us_dust_typed_core
      us_dust_leaf_program linked CUUS._bhv_cmd_call_native
      CUUS.f_bhv_cmd_call_native Hlink)
      as [handler_block [Hhandler_symbol Hhandler_function]].
    + vm_compute. reflexivity.
    + exists linked, seed_block, current_block, cursor_block, table_block,
        handler_block, puff_block, translate_block, random_float_block,
        random_u16_block.
      refine (conj Hlink _).
      refine (conj Hseed _).
      refine (conj Hcurrent _).
      refine (conj Hcursor_symbol _).
      refine (conj Htable_symbol _).
      refine (conj Hhandler_symbol _).
      refine (conj Hhandler_function _).
      refine (conj Hpuff_symbol _).
      refine (conj Hpuff_function _).
      refine (conj Htranslate_symbol _).
      refine (conj Htranslate_function _).
      refine (conj Hfloat_symbol _).
      refine (conj Hfloat_function _).
      refine (conj Hu16_symbol _).
      refine (conj Hu16_function _).
      intros environment locals_before memory_before script_block object_block
        x_before z_before Hcursor_local Htable_local Hcursor_seed
        Hcursor_object Hcursor Hcursor_write Hopcode Htable Hnative_word
        Hmemory.
      destruct (Hhandler_execution memory_before script_block object_block
        x_before z_before Hcursor_seed Hcursor_object Hcursor Hcursor_write
        Hnative_word Hmemory)
        as (memory_after & random_x & random_z & Hhandler & Hcursor_after &
            Hseed_after & Hx_after & Hz_after).
      destruct
        (generated_cur_obj_update_call_native_loop_cycle_executes_in_any_genv
          (Clight.globalenv linked) environment locals_before memory_before
          memory_after cursor_block script_block table_block handler_block
          Hcursor_local Htable_local Hcursor_symbol Htable_symbol Hcursor
          Hopcode Htable Hhandler_function Hhandler)
        as [locals_after [Hcycle Hresult]].
      exists memory_after, locals_after, random_x, random_z.
      repeat split; assumption.
Qed.

Definition jp_linked_cur_obj_update_call_native_dispatch_cycle_claim : Prop :=
  exists linked seed_block current_block cursor_block table_block
      handler_block puff_block translate_block random_float_block
      random_u16_block,
    link jp_dust_typed_core jp_dust_leaf_program = Some linked /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._gRandomSeed16 =
      Some seed_block /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._gCurrentObject =
      Some current_block /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._gCurBhvCommand =
      Some cursor_block /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._BehaviorCmdTable =
      Some table_block /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._bhv_cmd_call_native =
      Some handler_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) handler_block =
      Some (Internal CUJP.f_bhv_cmd_call_native) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCJPBA._bhv_white_puff_2_loop = Some puff_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) puff_block =
      Some (Internal BCJPBA.f_bhv_white_puff_2_loop) /\
    Genv.find_symbol (Clight.globalenv linked)
      BCJPOH._obj_translate_xz_random = Some translate_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) translate_block =
      Some (Internal BCJPOH.f_obj_translate_xz_random) /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._random_float =
      Some random_float_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_float_block =
      Some (Internal CUJP.f_random_float) /\
    Genv.find_symbol (Clight.globalenv linked) CUJP._random_u16 =
      Some random_u16_block /\
    Genv.find_funct_ptr (Clight.globalenv linked) random_u16_block =
      Some (Internal CUJP.f_random_u16) /\
    forall environment locals_before memory_before script_block object_block
        x_before z_before,
      environment ! CUJP._gCurBhvCommand = None ->
      environment ! CUJP._BehaviorCmdTable = None ->
      cursor_block <> seed_block ->
      cursor_block <> object_block ->
      Mem.load Mptr memory_before cursor_block 0 =
        Some (Vptr script_block call_native_command_offset) ->
      Mem.valid_access memory_before Mptr cursor_block 0 Writable ->
      Mem.load Mint32 memory_before script_block 20 =
        Some (Vint call_native_opcode_word) ->
      Mem.load Mptr memory_before table_block call_native_table_byte_offset =
        Some (Vptr handler_block Ptrofs.zero) ->
      Mem.load Mint32 memory_before script_block call_native_function_offset =
        Some (Vptr puff_block Ptrofs.zero) ->
      jp_white_puff_2_memory_image memory_before seed_block current_block
        object_block x_before z_before ->
      exists memory_after locals_after random_x random_z,
        exec_stmt function_entry2 (Clight.globalenv linked)
          environment locals_before memory_before
          cur_obj_update_call_native_loop_cycle
          E0 locals_after memory_after Out_normal /\
        locals_after ! CUJP._bhvProcResult = Some (Vint Int.zero) /\
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

Theorem checked_jp_linked_cur_obj_update_call_native_dispatch_cycle :
  jp_linked_cur_obj_update_call_native_dispatch_cycle_claim.
Proof.
  destruct checked_jp_linked_call_native_white_puff_2_execution as
    (linked & seed_block & current_block & cursor_block & puff_block &
     translate_block & random_float_block & random_u16_block & Hlink &
     Hseed & Hcurrent & Hcursor_symbol & Hpuff_symbol & Hpuff_function &
     Htranslate_symbol & Htranslate_function & Hfloat_symbol &
     Hfloat_function & Hu16_symbol & Hu16_function & Hhandler_execution).
  destruct (linked_right_resolves_symbol jp_dust_typed_core
    jp_dust_leaf_program linked CUJP._BehaviorCmdTable
    (Gvar CUJP.v_BehaviorCmdTable) Hlink) as [table_block Htable_symbol].
  - vm_compute. reflexivity.
  - destruct (linked_right_resolves_internal jp_dust_typed_core
      jp_dust_leaf_program linked CUJP._bhv_cmd_call_native
      CUJP.f_bhv_cmd_call_native Hlink)
      as [handler_block [Hhandler_symbol Hhandler_function]].
    + vm_compute. reflexivity.
    + exists linked, seed_block, current_block, cursor_block, table_block,
        handler_block, puff_block, translate_block, random_float_block,
        random_u16_block.
      refine (conj Hlink _).
      refine (conj Hseed _).
      refine (conj Hcurrent _).
      refine (conj Hcursor_symbol _).
      refine (conj Htable_symbol _).
      refine (conj Hhandler_symbol _).
      refine (conj Hhandler_function _).
      refine (conj Hpuff_symbol _).
      refine (conj Hpuff_function _).
      refine (conj Htranslate_symbol _).
      refine (conj Htranslate_function _).
      refine (conj Hfloat_symbol _).
      refine (conj Hfloat_function _).
      refine (conj Hu16_symbol _).
      refine (conj Hu16_function _).
      intros environment locals_before memory_before script_block object_block
        x_before z_before Hcursor_local Htable_local Hcursor_seed
        Hcursor_object Hcursor Hcursor_write Hopcode Htable Hnative_word
        Hmemory.
      destruct (Hhandler_execution memory_before script_block object_block
        x_before z_before Hcursor_seed Hcursor_object Hcursor Hcursor_write
        Hnative_word Hmemory)
        as (memory_after & random_x & random_z & Hhandler & Hcursor_after &
            Hseed_after & Hx_after & Hz_after).
      destruct
        (generated_cur_obj_update_call_native_loop_cycle_executes_in_jp_genv
          (Clight.globalenv linked) environment locals_before memory_before
          memory_after cursor_block script_block table_block handler_block
          Hcursor_local Htable_local Hcursor_symbol Htable_symbol Hcursor
          Hopcode Htable Hhandler_function Hhandler)
        as [locals_after [Hcycle Hresult]].
      exists memory_after, locals_after, random_x, random_z.
      repeat split; assumption.
Qed.

Definition linked_cur_obj_update_call_native_dispatch_cycle_us_jp_claim : Prop :=
  us_linked_cur_obj_update_call_native_dispatch_cycle_claim /\
  jp_linked_cur_obj_update_call_native_dispatch_cycle_claim.

Theorem checked_linked_cur_obj_update_call_native_dispatch_cycle_us_jp :
  linked_cur_obj_update_call_native_dispatch_cycle_us_jp_claim.
Proof.
  split.
  - exact checked_us_linked_cur_obj_update_call_native_dispatch_cycle.
  - exact checked_jp_linked_cur_obj_update_call_native_dispatch_cycle.
Qed.

(** Residual boundary, stated next to the executable theorem: after this
    cycle [bhv_cmd_call_native] has advanced the behavior cursor to byte 28.
    Finishing the surrounding generated loop must dispatch ADD_INT at byte 28,
    END_REPEAT at byte 32, execute the behavior-stack pop/push operations, and
    then execute [cur_obj_update]'s timer, movement, graphics, and visibility
    tail.  The object-list scheduler lies above that still-open full-function
    boundary. *)
