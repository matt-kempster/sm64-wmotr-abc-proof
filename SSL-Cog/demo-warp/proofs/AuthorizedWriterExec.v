From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clight ClightBigstep.
From DemoWarp.Generated Require Import game_init title_screen.
From DemoWarp.Proofs Require Import PointerProvenanceKernel.

Module G := game_init.
Module T := title_screen.

Definition run_increment_rhs : expr :=
  Ebinop Oadd
    (Etempvar G._t'5 (Tpointer (Tstruct G._DemoInput noattr) noattr))
    (Econst_int Int.one (Tint I32 Signed noattr))
    (Tpointer (Tstruct G._DemoInput noattr) noattr).

Definition run_increment_statement : statement :=
  Sassign (Evar G._gCurrDemoInput (Tpointer (Tstruct G._DemoInput noattr) noattr))
    run_increment_rhs.

Definition title_install_rhs : expr :=
  Ebinop Oadd
    (Ecast (Etempvar T._t'6 (Tpointer Tvoid noattr))
      (Tpointer (Tstruct T._DemoInput noattr) noattr))
    (Econst_int Int.one (Tint I32 Signed noattr))
    (Tpointer (Tstruct T._DemoInput noattr) noattr).

Definition title_install_statement : statement :=
  Sassign (Evar T._gCurrDemoInput (Tpointer (Tstruct T._DemoInput noattr) noattr))
    title_install_rhs.

Lemma eval_tempvar_binding :
  forall ge e le m id ty value,
    eval_expr ge e le m (Etempvar id ty) value -> le ! id = Some value.
Proof.
  intros. inv H; auto.
  match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hlv end.
Qed.

Lemma eval_const_int_value :
  forall ge e le m n ty value,
    eval_expr ge e le m (Econst_int n ty) value -> value = Vint n.
Proof.
  intros. inv H; auto.
  match goal with Hlv : eval_lvalue _ _ _ _ (Econst_int _ _) _ _ _ |- _ => inv Hlv end.
Qed.

Lemma eval_run_increment_rhs_preserves_block :
  forall ge e le m demo_block ofs value,
    le ! G._t'5 = Some (Vptr demo_block ofs) ->
    eval_expr ge e le m run_increment_rhs value ->
    exists next, value = Vptr demo_block next.
Proof.
  intros ge e le m demo_block ofs value Htemp Heval.
  unfold run_increment_rhs in Heval.
  inv Heval.
  all: try match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    pose proof (eval_tempvar_binding _ _ _ _ _ _ _ H) as Hget;
    rewrite Htemp in Hget; inv Hget
  end.
  match goal with H : eval_expr _ _ _ _ (Econst_int _ _) ?v |- _ =>
    pose proof (eval_const_int_value _ _ _ _ _ _ _ H); subst v
  end.
  match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn in H; inv H
  end.
  all: eexists; reflexivity.
Qed.

Lemma eval_title_install_rhs_preserves_block :
  forall ge e le m demo_block ofs value,
    le ! T._t'6 = Some (Vptr demo_block ofs) ->
    eval_expr ge e le m title_install_rhs value ->
    exists next, value = Vptr demo_block next.
Proof.
  intros ge e le m demo_block ofs value Htemp Heval.
  unfold title_install_rhs in Heval.
  inv Heval.
  all: try match goal with H : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv H end.
  match goal with H : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inv H end.
  all: try match goal with H : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv H end.
  match goal with H : eval_expr _ _ _ _ (Etempvar _ _) ?v |- _ =>
    pose proof (eval_tempvar_binding _ _ _ _ _ _ _ H) as Hget;
    rewrite Htemp in Hget; inv Hget
  end.
  match goal with H : sem_cast _ _ _ _ = Some _ |- _ => cbn in H; inv H end.
  match goal with H : eval_expr _ _ _ _ (Econst_int _ _) ?v |- _ =>
    pose proof (eval_const_int_value _ _ _ _ _ _ _ H); subst v
  end.
  match goal with H : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn in H; inv H
  end.
  all: eexists; reflexivity.
Qed.

Theorem generated_writer_rhs_execution_preserves_demo_block :
  (forall ge e le m demo_block ofs value,
    le ! G._t'5 = Some (Vptr demo_block ofs) ->
    eval_expr ge e le m run_increment_rhs value ->
    safe_demo_pointer_value demo_block value) /\
  (forall ge e le m demo_block ofs value,
    le ! T._t'6 = Some (Vptr demo_block ofs) ->
    eval_expr ge e le m title_install_rhs value ->
    safe_demo_pointer_value demo_block value).
Proof.
  split.
  - intros. destruct (eval_run_increment_rhs_preserves_block _ _ _ _ _ _ _ H H0)
      as [next Hnext].
    right. exists next. exact Hnext.
  - intros. destruct (eval_title_install_rhs_preserves_block _ _ _ _ _ _ _ H H0)
      as [next Hnext].
    right. exists next. exact Hnext.
Qed.
