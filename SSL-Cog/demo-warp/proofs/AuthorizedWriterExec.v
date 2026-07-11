From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs
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

Theorem exec_run_increment_stores_safe_pointer :
  forall (ge : genv) (e : env) (le : temp_env) (before : mem)
      (trace : Events.trace) (le' : temp_env) (after : mem) (out : outcome)
      demo_block ofs cell_block,
    e ! G._gCurrDemoInput = None ->
    Genv.find_symbol ge G._gCurrDemoInput = Some cell_block ->
    le ! G._t'5 = Some (Vptr demo_block ofs) ->
    exec_stmt function_entry2 ge e le before run_increment_statement
      trace le' after out ->
    exists loaded,
      Mem.load Mptr after cell_block 0 = Some loaded /\
      safe_demo_pointer_value demo_block loaded.
Proof.
  intros ge e le before trace le' after out demo_block ofs cell_block
    Hnotlocal Hsymbol Htemp Hexec.
  unfold run_increment_statement in Hexec.
  inv Hexec.
  match goal with Hrhs : eval_expr _ _ ?current_le _ _ ?value |- _ =>
    assert (Hrhs' : eval_expr ge e current_le before run_increment_rhs value) by exact Hrhs;
    destruct (eval_run_increment_rhs_preserves_block
      ge e current_le before demo_block ofs value Htemp Hrhs') as [next Hvalue];
    subst value
  end.
  match goal with Hcast : sem_cast (Vptr _ _) _ _ _ = Some ?stored |- _ =>
    cbn in Hcast; inv Hcast
  end.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar G._gCurrDemoInput _) _ _ _ |- _ =>
    inv Hlv
  end.
  - match goal with Hlocal : e ! G._gCurrDemoInput = Some _ |- _ =>
      rewrite Hnotlocal in Hlocal; discriminate
    end.
  - match goal with Hfound : Genv.find_symbol _ G._gCurrDemoInput = Some _ |- _ =>
      rewrite Hsymbol in Hfound; inv Hfound
    end.
    match goal with Hassign : assign_loc _ _ _ ?target_block _ _ _ after |- _ =>
      inv Hassign
    end.
    + match goal with Hmode : access_mode _ = By_value _ |- _ => cbn in Hmode; inv Hmode end.
      match goal with Hstore : Mem.storev Mptr before (Vptr ?target_block _) _ = Some after |- _ =>
        unfold Mem.storev in Hstore;
        eapply storing_safe_pointer_establishes_safe_pointer_cell;
        [ right; eexists; reflexivity | exact Hstore ]
      end.
    + match goal with Hmode : access_mode _ = By_copy |- _ => cbn in Hmode; discriminate end.
Qed.

Theorem exec_title_install_stores_safe_pointer :
  forall (ge : genv) (e : env) (le : temp_env) (before : mem)
      (trace : Events.trace) (le' : temp_env) (after : mem) (out : outcome)
      demo_block ofs cell_block,
    e ! T._gCurrDemoInput = None ->
    Genv.find_symbol ge T._gCurrDemoInput = Some cell_block ->
    le ! T._t'6 = Some (Vptr demo_block ofs) ->
    exec_stmt function_entry2 ge e le before title_install_statement
      trace le' after out ->
    exists loaded,
      Mem.load Mptr after cell_block 0 = Some loaded /\
      safe_demo_pointer_value demo_block loaded.
Proof.
  intros ge e le before trace le' after out demo_block ofs cell_block
    Hnotlocal Hsymbol Htemp Hexec.
  unfold title_install_statement in Hexec.
  inv Hexec.
  match goal with Hrhs : eval_expr _ _ ?current_le _ _ ?value |- _ =>
    assert (Hrhs' : eval_expr ge e current_le before title_install_rhs value) by exact Hrhs;
    destruct (eval_title_install_rhs_preserves_block
      ge e current_le before demo_block ofs value Htemp Hrhs') as [next Hvalue];
    subst value
  end.
  match goal with Hcast : sem_cast (Vptr _ _) _ _ _ = Some ?stored |- _ =>
    cbn in Hcast; inv Hcast
  end.
  match goal with Hlv : eval_lvalue _ _ _ _ (Evar T._gCurrDemoInput _) _ _ _ |- _ =>
    inv Hlv
  end.
  - match goal with Hlocal : e ! T._gCurrDemoInput = Some _ |- _ =>
      rewrite Hnotlocal in Hlocal; discriminate
    end.
  - match goal with Hfound : Genv.find_symbol _ T._gCurrDemoInput = Some _ |- _ =>
      rewrite Hsymbol in Hfound; inv Hfound
    end.
    match goal with Hassign : assign_loc _ _ _ ?target_block _ _ _ after |- _ =>
      inv Hassign
    end.
    + match goal with Hmode : access_mode _ = By_value _ |- _ => cbn in Hmode; inv Hmode end.
      match goal with Hstore : Mem.storev Mptr before (Vptr ?target_block _) _ = Some after |- _ =>
        unfold Mem.storev in Hstore;
        eapply storing_safe_pointer_establishes_safe_pointer_cell;
        [ right; eexists; reflexivity | exact Hstore ]
      end.
    + match goal with Hmode : access_mode _ = By_copy |- _ => cbn in Hmode; discriminate end.
Qed.

Theorem generated_writer_statement_execution_preserves_demo_block :
  (forall (ge : genv) (e : env) (le : temp_env) (before : mem)
      (trace : Events.trace) (le' : temp_env) (after : mem) (out : outcome)
      demo_block ofs cell_block,
    e ! G._gCurrDemoInput = None ->
    Genv.find_symbol ge G._gCurrDemoInput = Some cell_block ->
    le ! G._t'5 = Some (Vptr demo_block ofs) ->
    exec_stmt function_entry2 ge e le before run_increment_statement
      trace le' after out ->
    exists loaded,
      Mem.load Mptr after cell_block 0 = Some loaded /\
      safe_demo_pointer_value demo_block loaded) /\
  (forall (ge : genv) (e : env) (le : temp_env) (before : mem)
      (trace : Events.trace) (le' : temp_env) (after : mem) (out : outcome)
      demo_block ofs cell_block,
    e ! T._gCurrDemoInput = None ->
    Genv.find_symbol ge T._gCurrDemoInput = Some cell_block ->
    le ! T._t'6 = Some (Vptr demo_block ofs) ->
    exec_stmt function_entry2 ge e le before title_install_statement
      trace le' after out ->
    exists loaded,
      Mem.load Mptr after cell_block 0 = Some loaded /\
      safe_demo_pointer_value demo_block loaded).
Proof.
  split; [apply exec_run_increment_stores_safe_pointer |
          apply exec_title_install_stores_safe_pointer].
Qed.
