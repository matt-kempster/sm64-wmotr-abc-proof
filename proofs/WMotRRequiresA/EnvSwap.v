(* ====================================================================== *)
(* spine (via ObjUpdate): a Clight statement that never names a local x   *)
(* runs the same in any two environments that agree off x.  Used for      *)
(* cur_obj_update, whose only local (filler[4]) the body never names: its *)
(* dispatch segment then runs as in the empty environment, where          *)
(* BhvStep's lemmas live.  Generic Clight; no SM64 fact.                  *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clight ClightBigstep.
Import ListNotations.

Section NOFV.
  Variable x : ident.

  Fixpoint e_nofv (a : expr) : bool :=
    match a with
    | Evar y _ => negb (Pos.eqb y x)
    | Ederef a1 _ | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ | Efield a1 _ _ => e_nofv a1
    | Ebinop _ a1 a2 _ => e_nofv a1 && e_nofv a2
    | _ => true
    end.

  Fixpoint el_nofv (l : list expr) : bool :=
    match l with [] => true | a :: l' => e_nofv a && el_nofv l' end.

  Fixpoint s_nofv (s : statement) : bool :=
    match s with
    | Sskip | Sbreak | Scontinue | Sgoto _ => true
    | Sassign a1 a2 => e_nofv a1 && e_nofv a2
    | Sset _ a => e_nofv a
    | Scall _ a al => e_nofv a && el_nofv al
    | Sbuiltin _ _ _ al => el_nofv al
    | Ssequence s1 s2 | Sloop s1 s2 => s_nofv s1 && s_nofv s2
    | Sifthenelse a s1 s2 => e_nofv a && s_nofv s1 && s_nofv s2
    | Sswitch _ _ => false
    | Sreturn None => true
    | Sreturn (Some a) => e_nofv a
    | Slabel _ s1 => s_nofv s1
    end.

  Variable ge : genv.
  Variable e2 : env.

  Section EV.
    Variable e1 : env.
    Hypothesis Hag : forall y, y <> x -> e1 ! y = e2 ! y.

    Lemma ev_swap_both : forall le m,
      (forall a v, eval_expr ge e1 le m a v -> e_nofv a = true -> eval_expr ge e2 le m a v)
      /\ (forall a b o bf, eval_lvalue ge e1 le m a b o bf -> e_nofv a = true -> eval_lvalue ge e2 le m a b o bf).
    Proof.
      intros le m.
      apply (eval_expr_lvalue_ind ge e1 le m
               (fun a v => e_nofv a = true -> eval_expr ge e2 le m a v)
               (fun a b o bf => e_nofv a = true -> eval_lvalue ge e2 le m a b o bf));
        intros; cbn [e_nofv] in *;
        repeat match goal with H : _ && _ = true |- _ => apply andb_prop in H; destruct H end;
        try (econstructor; eauto; fail).
      all: match goal with
           | Hl : e1 ! ?id = Some _, Hx : negb (Pos.eqb ?id x) = true |- _ =>
               apply negb_true_iff, Pos.eqb_neq in Hx;
               apply eval_Evar_local; rewrite <- (Hag id Hx); exact Hl
           | Hl : e1 ! ?id = None, Hx : negb (Pos.eqb ?id x) = true |- _ =>
               apply negb_true_iff, Pos.eqb_neq in Hx;
               apply eval_Evar_global; [ rewrite <- (Hag id Hx); exact Hl | assumption ]
           end.
    Qed.
  End EV.

  Lemma ev_swap : forall e1, (forall y, y <> x -> e1 ! y = e2 ! y) ->
    forall le m a v, eval_expr ge e1 le m a v -> e_nofv a = true -> eval_expr ge e2 le m a v.
  Proof. intros e1 Hag le m. exact (proj1 (ev_swap_both e1 Hag le m)). Qed.

  Lemma lv_swap : forall e1, (forall y, y <> x -> e1 ! y = e2 ! y) ->
    forall le m a b o bf, eval_lvalue ge e1 le m a b o bf -> e_nofv a = true ->
    eval_lvalue ge e2 le m a b o bf.
  Proof. intros e1 Hag le m. exact (proj2 (ev_swap_both e1 Hag le m)). Qed.

  Lemma evl_swap : forall e1, (forall y, y <> x -> e1 ! y = e2 ! y) ->
    forall le m al tys vs, eval_exprlist ge e1 le m al tys vs -> el_nofv al = true ->
    eval_exprlist ge e2 le m al tys vs.
  Proof.
    intros e1 Hag le m al tys vs H. induction H; intros Hn; cbn [el_nofv] in Hn; [ constructor | ].
    apply andb_prop in Hn as [Hna Hnb].
    econstructor; [ exact (ev_swap e1 Hag _ _ _ _ H Hna) | eassumption | exact (IHeval_exprlist Hnb) ].
  Qed.

  Theorem exec_swap : forall e1 le m s t le' m' out,
    exec_stmt function_entry2 ge e1 le m s t le' m' out ->
    (forall y, y <> x -> e1 ! y = e2 ! y) -> s_nofv s = true ->
    exec_stmt function_entry2 ge e2 le m s t le' m' out.
  Proof.
    intros e1 le m s t le' m' out H. induction H; intros Hag Hn; cbn [s_nofv] in Hn;
      repeat match goal with H : _ && _ = true |- _ => apply andb_prop in H; destruct H end.
    - apply exec_Sskip.
    - eapply exec_Sassign; eauto using lv_swap, ev_swap.
    - apply exec_Sset. eauto using ev_swap.
    - eapply exec_Scall; eauto using ev_swap, evl_swap.
    - eapply exec_Sbuiltin; eauto using evl_swap.
    - eapply exec_Sseq_1; eauto.
    - eapply exec_Sseq_2; eauto.
    - eapply exec_Sifthenelse; [ eauto using ev_swap | eassumption | destruct b; eauto ].
    - apply exec_Sreturn_none.
    - apply exec_Sreturn_some. eauto using ev_swap.
    - apply exec_Sbreak.
    - apply exec_Scontinue.
    - eapply exec_Sloop_stop1; eauto.
    - eapply exec_Sloop_stop2; eauto.
    - eapply exec_Sloop_loop; eauto.
      apply IHexec_stmt3; [ exact Hag | cbn [s_nofv]; apply andb_true_intro; split; assumption ].
    - discriminate Hn.
  Qed.
End NOFV.
