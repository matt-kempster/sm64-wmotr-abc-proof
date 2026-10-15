From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_script jp_level_script us_memory jp_memory.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution
  DemoConditionalDispatchExecution DemoNumericAddressExecution.
Import ListNotations.
Open Scope Z_scope.
Module D := us_level_script.

(** Complete taken JUMP_IF caller with the actual equality and address helper
    callees. The explicit numeric target-cell premise describes the numeric
    image lane; generated symbolic initial memory has not been refined to it. *)
Definition demo_numeric_equality_jump_taken_claim (body : statement) : Prop :=
  forall (ge : Clight.genv) le before command_global command base register operator_code
      segment_code segment_table register_value argument target segment_base,
    Genv.find_symbol ge D._sCurrentCmd = Some command_global ->
    Genv.find_symbol ge D._sRegister = Some register ->
    Genv.find_symbol ge D._eval_script_op = Some operator_code ->
    Genv.find_funct_ptr ge operator_code = Some (Internal D.f_eval_script_op) ->
    Genv.find_symbol ge D._segmented_to_virtual = Some segment_code ->
    Genv.find_funct_ptr ge segment_code =
      Some (Internal us_memory.f_segmented_to_virtual) ->
    Genv.find_symbol ge us_memory._sSegmentTable = Some segment_table ->
    Mem.load Mptr before command_global 0 = Some (Vptr command base) ->
    Mem.load Mint8unsigned before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 2))) =
      Some (Vint (Int.repr 2)) ->
    Mem.load Mint32 before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 4))) = Some (Vint argument) ->
    Mem.load Mptr before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 8))) = Some (Vint target) ->
    Mem.load Mint32 before register 0 = Some (Vint register_value) ->
    Int.eq register_value argument = true ->
    Mem.load Mint32 before segment_table (demo_n64_table_offset target) =
      Some (Vint segment_base) ->
    Mem.valid_access before Mptr command_global 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le' after Out_normal /\
      Mem.store Mptr before command_global 0
        (Vint (demo_n64_virtual_address segment_base target)) = Some after /\
      Mem.load Mptr after command_global 0 =
        Some (Vint (demo_n64_virtual_address segment_base target)) /\
      (forall block chunk offset, block <> command_global ->
        Mem.load chunk after block offset = Mem.load chunk before block offset).

Theorem generated_demo_numeric_equality_jump_taken_executes :
  demo_numeric_equality_jump_taken_claim (fn_body D.f_level_cmd_jump_if).
Proof.
  intros ge le before command_global command base register operator_code
    segment_code segment_table register_value argument target segment_base
    Hcurrent Hregister Hop_code Hop_function Hsegment_code Hsegment_function
    Htable Hpointer Hop Hargument Htarget Hread Hequal Htable_read Hwrite.
  pose proof (generated_demo_equality_operator_executes ge before register
    register_value argument Hregister Hread) as Hoperator.
  rewrite Hequal in Hoperator.
  pose proof (generated_demo_numeric_segment_executes ge before segment_table
    target segment_base Htable Htable_read) as Hsegment.
  destruct (Mem.valid_access_store before Mptr command_global 0
    (Vint (demo_n64_virtual_address segment_base target)) Hwrite) as (after & Hstore).
  exists after. eexists. split.
  - cbn [D.f_level_cmd_jump_if fn_body]. dispatch_stmt.
  - split; [exact Hstore |]. split; [dls_load |].
    intros block chunk offset Hdifferent.
    apply Mem.load_store_other with (chunk := Mptr)
      (v := Vint (demo_n64_virtual_address segment_base target))
      (m1 := before) (b := command_global) (ofs := 0); [exact Hstore |].
    left. congruence.
Qed.

Definition demo_numeric_equality_jump_taken_claim_us_jp : Prop :=
  fn_body D.f_level_cmd_jump_if = fn_body jp_level_script.f_level_cmd_jump_if /\
  demo_numeric_equality_jump_taken_claim (fn_body D.f_level_cmd_jump_if) /\
  demo_numeric_equality_jump_taken_claim (fn_body jp_level_script.f_level_cmd_jump_if).

Theorem generated_demo_numeric_equality_jump_taken_us_jp :
  demo_numeric_equality_jump_taken_claim_us_jp.
Proof.
  split; [reflexivity |]. split; exact generated_demo_numeric_equality_jump_taken_executes.
Qed.

Lemma generated_demo_numeric_dispatch_function_entry : forall ge before f,
  (f = D.f_level_cmd_jump_if \/ f = jp_level_script.f_level_cmd_jump_if) ->
  function_entry2 ge f [] before (PTree.empty _)
    (create_undef_temps (fn_temps f)) before.
Proof.
  intros ge before f [-> | ->];
    (apply function_entry2_intro;
      [apply Coqlib.list_norepet_nil
      |apply Coqlib.list_norepet_nil
      |vm_compute; intuition
      |apply alloc_variables_nil
      |reflexivity]).
Qed.

Definition demo_numeric_dispatch_call_bridge_claim : Prop :=
  forall ge before after f,
    (f = D.f_level_cmd_jump_if \/ f = jp_level_script.f_level_cmd_jump_if) ->
    (exists le', exec_stmt function_entry2 ge (PTree.empty _)
      (create_undef_temps (fn_temps f)) before (fn_body f) E0 le' after Out_normal) ->
    eval_funcall function_entry2 ge before (Internal f) [] E0 after Vundef.

Theorem generated_demo_numeric_dispatch_body_to_funcall :
  demo_numeric_dispatch_call_bridge_claim.
Proof.
  intros ge before after f Hf (le' & Hbody).
  eapply eval_funcall_internal.
  - exact (generated_demo_numeric_dispatch_function_entry ge before f Hf).
  - exact Hbody.
  - destruct Hf as [-> | ->]; reflexivity.
  - reflexivity.
Qed.

(** Ordinary Clight still requires a Vptr for the following opcode load. This
    theorem records the exact boundary, rather than inventing a numeric-pointer
    dereference rule or treating the numeric caller result as an executable PC. *)
Lemma demo_numeric_command_pointer_cannot_dereference :
  forall ge environment locals memory id ty address result,
    locals ! id = Some (Vint address) ->
    ~ eval_expr ge environment locals memory
        (Ederef (Etempvar id (tptr ty)) ty) result.
Proof.
  intros ge environment locals memory id ty address result Hlocal Heval.
  inversion Heval; subst.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ =>
      inversion Hlv; subst
  end.
  match goal with
  | Hptr : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
      pose proof (demo_eval_temp_binding _ _ _ _ _ _ _ Hptr); congruence
  end.
Qed.

Definition demo_interpreter_next_opcode_expression body : option expr :=
  match body with
  | Ssequence _ (Ssequence _ (Ssequence
      (Sloop (Ssequence _ (Ssequence _ (Ssequence (Sset _ opcode) _))) _) _)) =>
      Some opcode
  | _ => None
  end.

Definition demo_expected_interpreter_opcode_expression : expr :=
  Efield
    (Ederef (Etempvar D._t'2 (tptr (Tstruct D._LevelCommand noattr)))
      (Tstruct D._LevelCommand noattr)) D._type tuchar.

Lemma generated_demo_interpreter_opcode_expression_us_jp :
  demo_interpreter_next_opcode_expression (fn_body D.f_level_script_execute) =
    Some demo_expected_interpreter_opcode_expression /\
  demo_interpreter_next_opcode_expression
    (fn_body jp_level_script.f_level_script_execute) =
    Some demo_expected_interpreter_opcode_expression.
Proof. split; reflexivity. Qed.

Lemma generated_demo_numeric_interpreter_opcode_cannot_evaluate :
  forall ge environment locals memory address result,
    locals ! D._t'2 = Some (Vint address) ->
    ~ eval_expr ge environment locals memory
        demo_expected_interpreter_opcode_expression result.
Proof.
  intros ge environment locals memory address result Hlocal Heval.
  unfold demo_expected_interpreter_opcode_expression in Heval.
  inversion Heval; subst.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
      inversion Hlv; subst
  end.
  all: eapply demo_numeric_command_pointer_cannot_dereference; eassumption.
Qed.

Definition demo_numeric_dispatch_execution_boundary_claim_us_jp : Prop :=
  demo_numeric_equality_jump_taken_claim_us_jp /\
  demo_numeric_dispatch_call_bridge_claim /\
  (demo_interpreter_next_opcode_expression (fn_body D.f_level_script_execute) =
    Some demo_expected_interpreter_opcode_expression /\
   demo_interpreter_next_opcode_expression
      (fn_body jp_level_script.f_level_script_execute) =
    Some demo_expected_interpreter_opcode_expression) /\
  (forall ge environment locals memory address result,
    locals ! D._t'2 = Some (Vint address) ->
    ~ eval_expr ge environment locals memory
        demo_expected_interpreter_opcode_expression result) /\
  (forall ge environment locals memory id ty address result,
    locals ! id = Some (Vint address) ->
    ~ eval_expr ge environment locals memory
        (Ederef (Etempvar id (tptr ty)) ty) result).

Theorem generated_demo_numeric_dispatch_execution_boundary_us_jp :
  demo_numeric_dispatch_execution_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_numeric_equality_jump_taken_us_jp
    (conj generated_demo_numeric_dispatch_body_to_funcall
      (conj generated_demo_interpreter_opcode_expression_us_jp
        (conj generated_demo_numeric_interpreter_opcode_cannot_evaluate
          demo_numeric_command_pointer_cannot_dereference)))).
Qed.
