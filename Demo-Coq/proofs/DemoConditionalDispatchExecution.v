From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_level_script jp_level_script us_memory jp_memory.
From Demo.Proofs Require Import DemoStartExecution DemoLevelSelectionExecution.
Import ListNotations.
Open Scope Z_scope.
Module J := us_level_script.

Ltac dispatch_normalize :=
  first [match goal with
    | H : Int.eq ?x ?y = ?b |- _ = ?out =>
        change (Some (Val.of_bool (Int.eq x y)) = out);
        rewrite H; reflexivity
    end | demo_reduce; first [reflexivity | eassumption]].

Ltac dispatch_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; cbn [set_opttemp]; repeat rewrite PTree.gsspec;
      cbn; first [eassumption | reflexivity]
  | |- eval_expr _ _ _ _ (Esizeof _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [dispatch_expr | dispatch_expr | dispatch_normalize]
  | |- eval_expr _ _ _ _ (Eunop _ _ _) _ =>
      eapply eval_Eunop; [dispatch_expr | dispatch_normalize]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [dispatch_expr | dispatch_normalize]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [dispatch_lvalue |
        first [eapply deref_loc_value; [reflexivity | cbn; dls_load]
              |eapply deref_loc_reference; reflexivity
              |eapply deref_loc_copy; reflexivity]]
  end
with dispatch_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; dispatch_expr
  | |- eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ =>
      eapply eval_Efield_struct;
      [dispatch_expr | reflexivity | eassumption | eassumption]
  end.

Ltac dispatch_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ Sskip _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ Sbreak _ _ _ _ => constructor
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [dispatch_stmt | dispatch_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; dispatch_expr
  | |- exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ =>
      eapply exec_Sassign;
      [dispatch_lvalue | dispatch_expr | dispatch_normalize |
       eapply assign_loc_value; [reflexivity | cbn; eassumption]]
  | |- exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ =>
      eapply exec_Scall;
      [reflexivity | dispatch_expr | dispatch_arguments |
       cbn; eassumption | reflexivity | eassumption]
  | |- exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ =>
      eapply exec_Sifthenelse; [dispatch_expr | reflexivity |
       lazymatch goal with
       | |- exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ =>
           let value := eval vm_compute in b in change b with value
       end; cbn; dispatch_stmt]
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; dispatch_expr
  end
with dispatch_arguments :=
  first [apply eval_Enil |
    eapply eval_Econs; [dispatch_expr | dispatch_normalize | dispatch_arguments]].

Definition demo_equality_operator_initial_temps (argument : int) : temp_env :=
  PTree.set J._arg (Vint argument)
    (PTree.set J._op (Vint (Int.repr 2))
      (create_undef_temps (fn_temps J.f_eval_script_op))).

Lemma generated_demo_equality_operator_entry : forall ge before argument,
  function_entry2 ge J.f_eval_script_op [Vint (Int.repr 2); Vint argument]
    before (PTree.empty _) (demo_equality_operator_initial_temps argument) before.
Proof.
  intros ge before argument. apply function_entry2_intro.
  - apply Coqlib.list_norepet_nil.
  - apply Coqlib.list_norepet_cons; [vm_compute; intuition congruence |].
    apply Coqlib.list_norepet_cons;
      [vm_compute; intuition congruence | apply Coqlib.list_norepet_nil].
  - vm_compute. intuition congruence.
  - apply alloc_variables_nil.
  - reflexivity.
Qed.

Definition demo_equality_operator_execution_claim (f : function) : Prop :=
  forall (ge : Clight.genv) before register register_value argument,
    Genv.find_symbol ge J._sRegister = Some register ->
    Mem.load Mint32 before register 0 = Some (Vint register_value) ->
    eval_funcall function_entry2 ge before (Internal f)
      [Vint (Int.repr 2); Vint argument] E0 before
      (Val.of_bool (Int.eq register_value argument)).

Theorem generated_demo_equality_operator_executes :
  demo_equality_operator_execution_claim J.f_eval_script_op.
Proof.
  intros ge before register register_value argument Hregister Hread.
  destruct (Int.eq register_value argument) eqn:Hequal;
    (eapply eval_funcall_internal;
     [exact (generated_demo_equality_operator_entry ge before argument)
     |cbn [J.f_eval_script_op fn_body];
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0); [dispatch_stmt |];
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [eapply exec_Sswitch with (out := Out_break);
          [unfold demo_equality_operator_initial_temps; dispatch_expr
          |reflexivity
          |lazymatch goal with
           | |- exec_stmt ?entry ?ge ?e ?le ?m ?s ?trace ?le' ?m' ?out =>
               let selected := eval vm_compute in s in
               change (exec_stmt entry ge e le m selected trace le' m' out)
           end;
           eapply exec_Sseq_2; [dispatch_stmt | discriminate]]
        |dispatch_stmt]
     |split; [discriminate | reflexivity]
     |reflexivity]).
Qed.

Definition demo_equality_operator_execution_claim_us_jp : Prop :=
  J.f_eval_script_op = jp_level_script.f_eval_script_op /\
  demo_equality_operator_execution_claim J.f_eval_script_op /\
  demo_equality_operator_execution_claim jp_level_script.f_eval_script_op.

Theorem generated_demo_equality_operator_execution_us_jp :
  demo_equality_operator_execution_claim_us_jp.
Proof.
  split; [reflexivity |]. split; exact generated_demo_equality_operator_executes.
Qed.

Definition demo_dispatch_next_command (base : ptrofs) : ptrofs :=
  Ptrofs.add base (Ptrofs.repr 12).

(** A nonmatching equality arm executes the complete real JUMP_IF command,
    including its actual eval_script_op call, and advances exactly 12 bytes.
    Arbitrary command offsets are supported so consecutive arms can compose. *)
Definition demo_equality_jump_not_taken_claim (body : statement) : Prop :=
  forall ge (layout : demo_command_layout ge) le before
      command_global command base register code register_value argument,
    Genv.find_symbol ge J._sCurrentCmd = Some command_global ->
    Genv.find_symbol ge J._sRegister = Some register ->
    Genv.find_symbol ge J._eval_script_op = Some code ->
    Genv.find_funct_ptr ge code = Some (Internal J.f_eval_script_op) ->
    command_global <> command -> command_global <> register ->
    Mem.load Mptr before command_global 0 = Some (Vptr command base) ->
    Mem.load Mint8unsigned before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 1))) =
      Some (Vint (Int.repr 12)) ->
    Mem.load Mint8unsigned before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 2))) =
      Some (Vint (Int.repr 2)) ->
    Mem.load Mint32 before command
      (Ptrofs.unsigned (Ptrofs.add base (Ptrofs.repr 4))) = Some (Vint argument) ->
    Mem.load Mint32 before register 0 = Some (Vint register_value) ->
    Int.eq register_value argument = false ->
    Mem.valid_access before Mptr command_global 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le' after
        Out_normal /\
      Mem.store Mptr before command_global 0
        (Vptr command (demo_dispatch_next_command base)) = Some after /\
      Mem.load Mptr after command_global 0 =
        Some (Vptr command (demo_dispatch_next_command base)) /\
      Mem.load Mint32 after register 0 = Some (Vint register_value) /\
      (forall chunk offset, Mem.load chunk after command offset =
        Mem.load chunk before command offset).

Theorem generated_demo_equality_jump_not_taken_executes :
  demo_equality_jump_not_taken_claim (fn_body J.f_level_cmd_jump_if).
Proof.
  intros ge layout le before command_global command base register code
    register_value argument Hcommand Hregister Hcode Hfd Hcc Hcr
    Hpointer Hsize Hop Hargument Hread Hequal Hwrite.
  destruct layout as [command_co Hcommand_co Hsize_offset].
  pose proof (generated_demo_equality_operator_executes ge before register
    register_value argument Hregister Hread) as Hoperator.
  rewrite Hequal in Hoperator.
  destruct (Mem.valid_access_store before Mptr command_global 0
    (Vptr command (demo_dispatch_next_command base)) Hwrite) as (after & Hstore).
  exists after. eexists. split.
  - cbn [J.f_level_cmd_jump_if fn_body]. dispatch_stmt.
  - split; [exact Hstore |]. split; [dls_load |]. split; [dls_load |].
    intros chunk offset. apply Mem.load_store_other with
      (chunk := Mptr) (v := Vptr command (demo_dispatch_next_command base))
      (m1 := before) (b := command_global) (ofs := 0); [exact Hstore |].
    left. congruence.
Qed.

Definition demo_equality_jump_not_taken_claim_us_jp : Prop :=
  fn_body J.f_level_cmd_jump_if = fn_body jp_level_script.f_level_cmd_jump_if /\
  demo_equality_jump_not_taken_claim (fn_body J.f_level_cmd_jump_if) /\
  demo_equality_jump_not_taken_claim (fn_body jp_level_script.f_level_cmd_jump_if).

Theorem generated_demo_equality_jump_not_taken_us_jp :
  demo_equality_jump_not_taken_claim_us_jp.
Proof.
  split; [reflexivity |]. split; exact generated_demo_equality_jump_not_taken_executes.
Qed.

(** This selector reads the real first expression of segmented_to_virtual.
    Its pointer-to-integer cast does not turn a symbolic CompCert relocation
    into a numerical retail address, and its immediate shift is undefined on
    that Vptr value.  This is an address-model obstruction, not a game desync. *)
Definition demo_segmented_address_first_expression (body : statement) : option expr :=
  match body with Ssequence (Sset _ expression) _ => Some expression | _ => None end.

Definition expected_demo_segmented_address_first_expression : expr :=
  Ebinop Oshr
    (Ecast (Etempvar us_memory._addr (tptr tvoid)) tuint)
    (Econst_int (Int.repr 24) tint) tuint.

Definition demo_symbolic_segmented_address_obstruction_claim_us_jp : Prop :=
  demo_segmented_address_first_expression
    (fn_body us_memory.f_segmented_to_virtual) =
    Some expected_demo_segmented_address_first_expression /\
  demo_segmented_address_first_expression
    (fn_body jp_memory.f_segmented_to_virtual) =
    Some expected_demo_segmented_address_first_expression /\
  (forall (ge : Clight.genv) memory block offset,
    sem_cast (Vptr block offset) (tptr tvoid) tuint memory =
      Some (Vptr block offset) /\
    sem_binary_operation ge Oshr (Vptr block offset) tuint
      (Vint (Int.repr 24)) tint memory = None).

Theorem generated_demo_symbolic_segmented_address_obstruction_us_jp :
  demo_symbolic_segmented_address_obstruction_claim_us_jp.
Proof.
  split; [reflexivity |]. split; [reflexivity |].
  intros ge memory block offset. split; reflexivity.
Qed.

Definition demo_conditional_dispatch_execution_boundary_claim_us_jp : Prop :=
  demo_equality_operator_execution_claim_us_jp /\
  demo_equality_jump_not_taken_claim_us_jp /\
  demo_symbolic_segmented_address_obstruction_claim_us_jp.

Theorem generated_demo_conditional_dispatch_execution_boundary_us_jp :
  demo_conditional_dispatch_execution_boundary_claim_us_jp.
Proof.
  exact (conj generated_demo_equality_operator_execution_us_jp
    (conj generated_demo_equality_jump_not_taken_us_jp
      generated_demo_symbolic_segmented_address_obstruction_us_jp)).
Qed.
