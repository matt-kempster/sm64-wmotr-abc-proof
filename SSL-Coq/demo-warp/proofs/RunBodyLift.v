From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep.
From DemoWarp.Generated Require Import game_init.
From DemoWarp.Proofs Require Import PointerProvenanceKernel AuthorizedWriterExec
  OperationalCallgraph TargetInvariant.

Module G := game_init.

Definition run_outer_prefix : statement :=
  match fn_body G.f_run_demo_inputs with
  | Ssequence prefix _ => prefix
  | _ => Sskip
  end.

Definition run_outer_guard_load : statement :=
  match fn_body G.f_run_demo_inputs with
  | Ssequence _ (Ssequence load _) => load
  | _ => Sskip
  end.

Definition run_outer_guard : expr :=
  match fn_body G.f_run_demo_inputs with
  | Ssequence _ (Ssequence _ (Sifthenelse condition _ _)) => condition
  | _ => Econst_int Int.zero (Tint I32 Signed noattr)
  end.

Definition run_outer_active_branch : statement :=
  match fn_body G.f_run_demo_inputs with
  | Ssequence _ (Ssequence _ (Sifthenelse _ active _)) => active
  | _ => Sskip
  end.

Theorem generated_run_outer_decomposition :
  fn_body G.f_run_demo_inputs =
    Ssequence run_outer_prefix
      (Ssequence run_outer_guard_load
        (Sifthenelse run_outer_guard run_outer_active_branch Sskip)).
Proof. reflexivity. Qed.

Theorem generated_run_outer_guard_load_is_concrete :
  run_outer_guard_load =
    Sset G._t'2
      (Evar G._gCurrDemoInput
        (Tpointer (Tstruct G._DemoInput noattr) noattr)).
Proof. reflexivity. Qed.

Theorem generated_run_outer_guard_is_nonnull_test :
  run_outer_guard =
    Ebinop One
      (Etempvar G._t'2
        (Tpointer (Tstruct G._DemoInput noattr) noattr))
      (Ecast (Econst_int Int.zero (Tint I32 Signed noattr))
        (Tpointer Tvoid noattr))
      (Tint I32 Signed noattr).
Proof. reflexivity. Qed.

Lemma exec_run_outer_guard_load_sets_safe_temp :
  forall (ge : genv) (e : env) (le : temp_env) (m : mem)
      trace le' m' out demo_block cell_block loaded,
    e ! G._gCurrDemoInput = None ->
    Genv.find_symbol ge G._gCurrDemoInput = Some cell_block ->
    Mem.load Mptr m cell_block 0 = Some loaded ->
    safe_demo_pointer_value demo_block loaded ->
    exec_stmt function_entry2 ge e le m run_outer_guard_load
      trace le' m' out ->
    m' = m /\ le' ! G._t'2 = Some loaded /\
    safe_demo_pointer_value demo_block loaded.
Proof.
  intros ge e le m trace le' m' out demo_block cell_block loaded
    Hnotlocal Hsymbol Hload Hsafe Hexec.
  rewrite generated_run_outer_guard_load_is_concrete in Hexec.
  inv Hexec.
  match goal with Heval : eval_expr _ _ _ _ (Evar G._gCurrDemoInput _) _ |- _ =>
    inv Heval
  end.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Evar G._gCurrDemoInput _) _ _ _ |- _ => inv Hlv
  end.
  - match goal with Hlocal : e ! G._gCurrDemoInput = Some _ |- _ =>
      rewrite Hnotlocal in Hlocal; discriminate
    end.
  - match goal with Hfound : Genv.find_symbol _ G._gCurrDemoInput = Some _ |- _ =>
      rewrite Hsymbol in Hfound; inv Hfound
    end.
    match goal with Hderef : deref_loc _ _ _ Ptrofs.zero Full _ |- _ => inv Hderef end.
    + match goal with Hmode : access_mode _ = By_value _ |- _ => cbn in Hmode; inv Hmode end.
      unfold Mem.loadv in H1; cbn in H1.
      change (Mem.load Mptr m' loc 0 = Some v) in H1.
      rewrite Hload in H1; inv H1.
      split; [reflexivity |]. split; [apply PTree.gss | exact Hsafe].
    + match goal with Hmode : access_mode _ = By_reference |- _ => cbn in Hmode; discriminate end.
    + match goal with Hmode : access_mode _ = By_copy |- _ => cbn in Hmode; discriminate end.
Qed.

Lemma true_run_outer_guard_refines_to_demo_pointer :
  forall ge e le m demo_block loaded condition_value,
    le ! G._t'2 = Some loaded ->
    safe_demo_pointer_value demo_block loaded ->
    eval_expr ge e le m run_outer_guard condition_value ->
    bool_val condition_value (typeof run_outer_guard) m = Some true ->
    exists ofs, loaded = Vptr demo_block ofs.
Proof.
  intros ge e le m demo_block loaded condition_value Htemp Hsafe Heval Htrue.
  destruct Hsafe as [Hzero | [ofs Hptr]]; [| exists ofs; exact Hptr].
  subst loaded.
  rewrite generated_run_outer_guard_is_nonnull_test in Heval, Htrue.
  cbn in Htrue.
  inv Heval.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with Hleft : eval_expr _ _ _ _ (Etempvar G._t'2 _) ?v |- _ =>
    pose proof (eval_tempvar_binding _ _ _ _ _ _ _ Hleft) as Hget;
    rewrite Htemp in Hget; inv Hget
  end.
  match goal with Hcast_eval : eval_expr _ _ _ _ (Ecast _ _) _ |- _ => inv Hcast_eval end.
  all: try match goal with
    Hlv : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hlv
  end.
  match goal with Hzero_eval : eval_expr _ _ _ _ (Econst_int _ _) ?v |- _ =>
    pose proof (eval_const_int_value _ _ _ _ _ _ _ Hzero_eval); subst v
  end.
  match goal with Hcast : sem_cast _ _ _ _ = Some _ |- _ => cbn in Hcast; inv Hcast end.
  match goal with Hcmp : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ =>
    cbn in Hcmp; inv Hcmp
  end.
  discriminate Htrue.
Qed.

Definition active_branch_preserves_target
    (ge : genv) (e : env) (demo_block curr_cell handler_block : block) : Prop :=
  forall le before trace le' after out current_ofs,
    target_pointer_invariant demo_block curr_cell handler_block before ->
    Mem.load Mptr before curr_cell 0 = Some (Vptr demo_block current_ofs) ->
    exec_stmt function_entry2 ge e le before run_outer_active_branch
      trace le' after out ->
    target_pointer_invariant demo_block curr_cell handler_block after.

Theorem generated_run_demo_inputs_body_path_lift :
  forall (ge : genv) (e : env) (le : temp_env) before trace le' after out
      demo_block curr_cell handler_block,
    e ! G._gCurrDemoInput = None ->
    Genv.find_symbol ge G._gCurrDemoInput = Some curr_cell ->
    statement_preserves
      (target_pointer_invariant demo_block curr_cell handler_block)
      ge e run_outer_prefix ->
    active_branch_preserves_target ge e demo_block curr_cell handler_block ->
    target_pointer_invariant demo_block curr_cell handler_block before ->
    exec_stmt function_entry2 ge e le before (fn_body G.f_run_demo_inputs)
      trace le' after out ->
    target_pointer_invariant demo_block curr_cell handler_block after.
Proof.
  intros ge e le before trace le' after out demo_block curr_cell handler_block
    Hnotlocal Hsymbol Hprefix Hactive Hinvariant Hexec.
  rewrite generated_run_outer_decomposition in Hexec.
  inv Hexec.
  - match goal with Hfirst : exec_stmt _ _ _ _ _ run_outer_prefix _ _ _ _ |- _ =>
      assert (Hmiddle : target_pointer_invariant demo_block curr_cell handler_block m1)
        by (eapply Hprefix; eauto)
    end.
    match goal with Hrest : exec_stmt _ _ _ _ _ (Ssequence run_outer_guard_load _) _ _ _ _ |- _ =>
      inv Hrest
    end.
    + destruct Hmiddle as [Hdemo [Hcurr [Hhandler
        [[loaded [Hload Hsafe]] Hhandler_value]]]].
      assert (Hmiddle' : target_pointer_invariant demo_block curr_cell handler_block m1).
      { exact (conj Hdemo (conj Hcurr (conj Hhandler
          (conj (ex_intro _ loaded (conj Hload Hsafe)) Hhandler_value)))). }
      match goal with Hload_exec : exec_stmt _ _ _ _ _ run_outer_guard_load _ _ _ _ |- _ =>
        pose proof (exec_run_outer_guard_load_sets_safe_temp ge e le1 m1 _ _ _ _
          demo_block curr_cell loaded Hnotlocal Hsymbol Hload Hsafe Hload_exec)
          as Hloaded
      end.
      destruct Hloaded as [Hmem [Htemp Hsafe_temp]]. subst.
      match goal with Hif : exec_stmt _ _ _ _ _ (Sifthenelse run_outer_guard _ _) _ _ _ _ |- _ =>
        inv Hif
      end.
      destruct b.
      * assert (Hptr : exists ofs, loaded = Vptr demo_block ofs).
        { eapply true_run_outer_guard_refines_to_demo_pointer; eauto. }
        destruct Hptr as [current_ofs Hptr]. subst loaded.
        eapply Hactive; eauto.
      * match goal with Hskip : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv Hskip end.
        exact Hmiddle'.
    + match goal with Hload_exec : exec_stmt _ _ _ _ _ run_outer_guard_load _ _ _ _ |- _ =>
        inv Hload_exec
      end.
      match goal with Hnotnormal : Out_normal <> Out_normal |- _ => contradiction end.
  - match goal with Hfirst : exec_stmt _ _ _ _ _ run_outer_prefix _ _ _ _ |- _ =>
      eapply Hprefix; eauto
    end.
Qed.
