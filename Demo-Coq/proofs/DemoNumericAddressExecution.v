From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Cop Ctypes
  Events Globalenvs Integers Maps Memdata Memory Values.
From Demo.Generated Require Import us_memory jp_memory.
Import ListNotations.
Open Scope Z_scope.
Module N := us_memory.

(** These are the arithmetic operations of the original generated helper.
    The theorem below executes its complete body on numeric Vint arguments;
    it does not change ordinary Clight dereference or function-call rules. *)
Definition demo_n64_segment_index address := Int.shru address (Int.repr 24).
Definition demo_n64_segment_offset address := Int.and address (Int.repr 16777215).
Definition demo_n64_virtual_address base address :=
  Int.or (Int.add base (demo_n64_segment_offset address)) (Int.repr (-2147483648)).
Definition demo_n64_table_offset address :=
  Ptrofs.unsigned (Ptrofs.mul (Ptrofs.repr 4)
    (Ptrofs.of_intu (demo_n64_segment_index address))).

Definition demo_numeric_segment_initial_temps address : temp_env :=
  PTree.set N._addr (Vint address)
    (create_undef_temps (fn_temps N.f_segmented_to_virtual)).

Lemma generated_demo_numeric_segment_entry : forall ge memory address,
  function_entry2 ge N.f_segmented_to_virtual [Vint address] memory
    (PTree.empty _) (demo_numeric_segment_initial_temps address) memory.
Proof.
  intros ge memory address. apply function_entry2_intro.
  - apply Coqlib.list_norepet_nil.
  - apply Coqlib.list_norepet_cons;
      [vm_compute; intuition | apply Coqlib.list_norepet_nil].
  - vm_compute. intuition congruence.
  - apply alloc_variables_nil.
  - reflexivity.
Qed.

Ltac numeric_segment_temp :=
  cbn [demo_numeric_segment_initial_temps];
  repeat first [rewrite PTree.gss | rewrite PTree.gso by discriminate]; reflexivity.
Ltac numeric_segment_expr :=
  lazymatch goal with
  | |- eval_expr _ _ _ _ (Econst_int _ _) _ => constructor
  | |- eval_expr _ _ _ _ (Etempvar _ _) _ =>
      eapply eval_Etempvar; numeric_segment_temp
  | |- eval_expr _ _ _ _ (Ebinop _ _ _ _) _ =>
      eapply eval_Ebinop; [numeric_segment_expr | numeric_segment_expr | reflexivity]
  | |- eval_expr _ _ _ _ (Ecast _ _) _ =>
      eapply eval_Ecast; [numeric_segment_expr | reflexivity]
  | |- eval_expr _ _ _ _ _ _ =>
      eapply eval_Elvalue; [numeric_segment_lvalue |
        first [eapply deref_loc_reference; reflexivity |
          eapply deref_loc_value; [reflexivity |
            cbn -[Int.shru Int.and Int.or Int.add Ptrofs.mul Ptrofs.of_intu];
            first [eassumption | rewrite Ptrofs.add_zero_l; eassumption]]]]
  end
with numeric_segment_lvalue :=
  lazymatch goal with
  | |- eval_lvalue _ _ _ _ (Evar _ _) _ _ _ =>
      eapply eval_Evar_global; [reflexivity | eassumption]
  | |- eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ =>
      eapply eval_Ederef; numeric_segment_expr
  end.
Ltac numeric_segment_stmt :=
  lazymatch goal with
  | |- exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ =>
      eapply exec_Sseq_1 with (t1 := E0) (t2 := E0);
        [numeric_segment_stmt | numeric_segment_stmt]
  | |- exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ =>
      eapply exec_Sset; numeric_segment_expr
  | |- exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ =>
      eapply exec_Sreturn_some; numeric_segment_expr
  end.

Definition demo_numeric_segment_execution_claim (f : function) : Prop :=
  forall (ge : Clight.genv) memory table address base,
    Genv.find_symbol ge N._sSegmentTable = Some table ->
    Mem.load Mint32 memory table (demo_n64_table_offset address) = Some (Vint base) ->
    eval_funcall function_entry2 ge memory (Internal f) [Vint address] E0 memory
      (Vint (demo_n64_virtual_address base address)).

Theorem generated_demo_numeric_segment_executes :
  demo_numeric_segment_execution_claim N.f_segmented_to_virtual.
Proof.
  intros ge memory table address base Htable Hload.
  unfold demo_n64_table_offset, demo_n64_segment_index in Hload.
  unfold demo_n64_virtual_address, demo_n64_segment_offset.
  eapply eval_funcall_internal.
  - exact (generated_demo_numeric_segment_entry ge memory address).
  - cbn [N.f_segmented_to_virtual fn_body]. numeric_segment_stmt.
  - split; [discriminate | reflexivity].
  - reflexivity.
Qed.

Definition demo_numeric_segment_execution_claim_us_jp : Prop :=
  N.f_segmented_to_virtual = jp_memory.f_segmented_to_virtual /\
  demo_numeric_segment_execution_claim N.f_segmented_to_virtual /\
  demo_numeric_segment_execution_claim jp_memory.f_segmented_to_virtual.

Theorem generated_demo_numeric_segment_execution_us_jp :
  demo_numeric_segment_execution_claim_us_jp.
Proof.
  split; [reflexivity |]. split; exact generated_demo_numeric_segment_executes.
Qed.

Definition demo_symbolic_segment_index_expression addr : expr :=
  Ebinop Oshr (Ecast (Etempvar addr (tptr tvoid)) tuint)
    (Econst_int (Int.repr 24) tint) tuint.

Lemma demo_eval_temp_binding : forall ge environment locals memory id ty value,
  eval_expr ge environment locals memory (Etempvar id ty) value ->
  locals ! id = Some value.
Proof.
  intros. inversion H; auto.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inversion Hlv
  end.
Qed.

Lemma demo_eval_const_value : forall ge environment locals memory integer ty value,
  eval_expr ge environment locals memory (Econst_int integer ty) value ->
  value = Vint integer.
Proof.
  intros. inversion H; auto.
  match goal with
  | Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inversion Hlv
  end.
Qed.

Theorem demo_symbolic_segment_index_cannot_evaluate :
  forall ge environment locals memory addr block offset value,
    locals ! addr = Some (Vptr block offset) ->
    ~ eval_expr ge environment locals memory
      (demo_symbolic_segment_index_expression addr) value.
Proof.
  intros ge environment locals memory addr block offset value Haddr Heval.
  unfold demo_symbolic_segment_index_expression in Heval.
  inversion Heval; subst.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inversion Hlv
  end.
  match goal with
  | Hcast_eval : eval_expr _ _ _ _ (Ecast _ _) _ |- _ =>
      inversion Hcast_eval; subst
  end.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inversion Hlv
  end.
  match goal with
  | Htemp : eval_expr _ _ _ _ (Etempvar _ _) ?loaded |- _ =>
      pose proof (demo_eval_temp_binding _ _ _ _ _ _ _ Htemp) as Hget;
      assert (loaded = Vptr block offset) by congruence; subst loaded
  end.
  match goal with
  | Hcast : sem_cast (Vptr block offset) _ _ _ = Some ?casted |- _ =>
      change (Some (Vptr block offset) = Some casted) in Hcast;
      inversion Hcast; subst
  end.
  match goal with
  | Hconst : eval_expr _ _ _ _ (Econst_int _ _) ?count |- _ =>
      pose proof (demo_eval_const_value _ _ _ _ _ _ _ Hconst); subst count
  end.
  match goal with
  | Hshift : sem_binary_operation _ Oshr (Vptr block offset) _ _ _ _ = Some _ |- _ =>
      change (None = Some value) in Hshift; discriminate
  end.
Qed.

Definition demo_symbolic_segment_call_impossibility_claim (f : function) : Prop :=
  forall ge before after block offset trace result,
    ~ eval_funcall function_entry2 ge before (Internal f)
      [Vptr block offset] trace after result.

Theorem generated_demo_segmented_call_cannot_execute_symbolic_pointer :
  demo_symbolic_segment_call_impossibility_claim N.f_segmented_to_virtual.
Proof.
  intros ge before after block offset trace result Hcall.
  inversion Hcall; subst; clear Hcall.
  match goal with
  | Hentry : function_entry2 _ _ _ _ _ _ _ |- _ => inversion Hentry; subst
  end.
  match goal with
  | Hparams : bind_parameter_temps _ _ _ = Some _ |- _ =>
      cbn [fn_params fn_temps bind_parameter_temps create_undef_temps] in Hparams;
      inversion Hparams; subst; clear Hparams
  end.
  all: match goal with
  | Hbody : exec_stmt _ _ _ _ _ (fn_body _) _ _ _ _ |- _ =>
      cbn [fn_body] in Hbody; inversion Hbody; subst; clear Hbody
  end.
  all: match goal with
  | Hset : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ =>
      inversion Hset; subst; clear Hset
  end.
  all: eapply demo_symbolic_segment_index_cannot_evaluate; [| eassumption].
  all: cbn; reflexivity.
Qed.

Definition demo_numeric_address_execution_boundary_claim_us_jp : Prop :=
  demo_numeric_segment_execution_claim_us_jp /\
  demo_symbolic_segment_call_impossibility_claim N.f_segmented_to_virtual /\
  demo_symbolic_segment_call_impossibility_claim jp_memory.f_segmented_to_virtual.

Theorem generated_demo_numeric_address_execution_boundary_us_jp :
  demo_numeric_address_execution_boundary_claim_us_jp.
Proof.
  split; [exact generated_demo_numeric_segment_execution_us_jp |].
  split; exact generated_demo_segmented_call_cannot_execute_symbolic_pointer.
Qed.
