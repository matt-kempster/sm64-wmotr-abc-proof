(* ======================================================================= *)
(* FrameCalls: a function body as a sequence of calls and store blocks.    *)
(*                                                                         *)
(* GOAL 2's frame rows are about what one real execute_mario_action does   *)
(* to Mario's cells.  The body itself does little: it calls 20 functions   *)
(* (the input update, the action dispatchers, the post-action helpers) and *)
(* makes two stores to Mario's object.  This file proves, once and for     *)
(* any memory predicate P, that a body run keeps P when every call and     *)
(* every store block in it keeps P.  The obligations are computed from the *)
(* statement by [cl]:                                                       *)
(*   OCall f   `t = gMarioState; f(t)`  (the argument is the loaded global) *)
(*   OAny f    any other call of f                                          *)
(*   OBlk s    a straight-line block s with a store and no call            *)
(* Control flow (if, loop, switch, break, return) needs no obligation.     *)
(* ======================================================================= *)

From Coq Require Import List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs
  Ctypes Cop Clight ClightBigstep.
Import ListNotations.

Inductive obl : Type :=
| OCall (f : ident)
| OAny (f : ident) (fty : type) (al : list expr)
| OBlk (s : statement).

Section FrameCalls.
  Variable ge : genv.
  Variable gid : ident.   (* the global whose loaded value is the argument *)
  Variable gty : type.    (* its (pointer) type *)

  Fixpoint straight (s : statement) : bool :=
    match s with
    | Sskip | Sset _ _ | Sassign _ _ => true
    | Ssequence a b => straight a && straight b
    | _ => false
    end.

  Fixpoint has_asg (s : statement) : bool :=
    match s with
    | Sassign _ _ => true
    | Ssequence a b => has_asg a || has_asg b
    | _ => false
    end.

  Definition is_fun_ty (t : type) : bool :=
    match t with Tfunction _ _ _ => true | _ => false end.

  (* `t = gid; f(t)` with gid, t and the parameter all of type gty *)
  Definition gms_call (s : statement) : option ident :=
    match s with
    | Ssequence (Sset t (Evar g ty0))
        (Scall _ (Evar f (Tfunction (pty :: nil) _ _)) (Etempvar t' ty1 :: nil)) =>
        if Pos.eqb g gid && Pos.eqb t t' && type_eq ty0 gty && type_eq ty1 gty
           && type_eq pty gty
        then Some f else None
    | _ => None
    end.

  Definition ocat (a b : option (list obl)) : option (list obl) :=
    match a, b with Some x, Some y => Some (x ++ y) | _, _ => None end.

  Fixpoint cl (s : statement) : option (list obl) :=
    match s with
    | Sskip | Sset _ _ | Sbreak | Scontinue | Sreturn _ => Some []
    | Sassign _ _ => Some [OBlk s]
    | Scall _ (Evar f fty) al => if is_fun_ty fty then Some [OAny f fty al] else None
    | Ssequence s1 s2 =>
        match gms_call s with
        | Some f => Some [OCall f]
        | None =>
            if straight s && has_asg s then Some [OBlk s]
            else ocat (cl s1) (cl s2)
        end
    | Sifthenelse _ s1 s2 => ocat (cl s1) (cl s2)
    | Sloop s1 s2 => ocat (cl s1) (cl s2)
    | Sswitch _ ls => cl_ls ls
    | Slabel _ s1 => cl s1
    | _ => None
    end
  with cl_ls (ls : labeled_statements) : option (list obl) :=
    match ls with
    | LSnil => Some []
    | LScons _ s ls' => ocat (cl s) (cl_ls ls')
    end.

  Variable P : mem -> Prop.

  Definition obl_ok (o : obl) : Prop :=
    match o with
    | OCall f =>
        forall le bf fd m v v' rt cc t m' vr,
          eval_expr ge empty_env le m (Evar gid gty) v ->
          sem_cast v gty gty m = Some v' ->
          Genv.find_symbol ge f = Some bf ->
          Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd ->
          type_of_fundef fd = Tfunction [gty] rt cc ->
          P m -> eval_funcall function_entry2 ge m fd [v'] t m' vr -> P m'
    | OAny f fty al =>
        forall le bf fd m tyargs tyres cc vargs t m' vr,
          classify_fun fty = fun_case_f tyargs tyres cc ->
          Genv.find_symbol ge f = Some bf ->
          Genv.find_funct ge (Vptr bf Ptrofs.zero) = Some fd ->
          type_of_fundef fd = Tfunction tyargs tyres cc ->
          eval_exprlist ge empty_env le m al tyargs vargs ->
          P m -> eval_funcall function_entry2 ge m fd vargs t m' vr -> P m'
    | OBlk s =>
        forall le m t le' m' out,
          P m -> exec_stmt function_entry2 ge empty_env le m s t le' m' out -> P m'
    end.

  Lemma ocat_some : forall a b l, ocat a b = Some l ->
    exists x y, a = Some x /\ b = Some y /\ l = x ++ y.
  Proof.
    intros [x|] [y|] l H; cbn in H; try discriminate H.
    injection H as <-. eauto.
  Qed.

  Lemma Forall_app_inv : forall (Q : obl -> Prop) x y,
    Forall Q (x ++ y) -> Forall Q x /\ Forall Q y.
  Proof. intros Q x y H. apply Forall_app in H. exact H. Qed.

  Lemma eval_Evar_fun : forall le m f tyl rty cc vf,
    eval_expr ge empty_env le m (Evar f (Tfunction tyl rty cc)) vf ->
    exists b, Genv.find_symbol ge f = Some b /\ vf = Vptr b Ptrofs.zero.
  Proof.
    intros le m f tyl rty cc vf H. inv H;
      match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end.
    - match goal with He : empty_env ! _ = Some _ |- _ =>
        rewrite PTree.gempty in He; discriminate He end.
    - match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end;
        match goal with Ha : access_mode _ = _ |- _ => cbn in Ha; try discriminate Ha end.
      eauto.
  Qed.

  Lemma eval_Evar_fun' : forall le m f fty vf,
    is_fun_ty fty = true ->
    eval_expr ge empty_env le m (Evar f fty) vf ->
    exists b, Genv.find_symbol ge f = Some b /\ vf = Vptr b Ptrofs.zero.
  Proof.
    intros le m f fty vf Ht H. destruct fty; try discriminate Ht.
    exact (eval_Evar_fun le m f _ _ _ vf H).
  Qed.

  (* ---- a statement keeps P ---- *)
  Definition safe (s : statement) : Prop :=
    forall le m t le' m' out,
      P m -> exec_stmt function_entry2 ge empty_env le m s t le' m' out -> P m'.

  Lemma safe_seq : forall s1 s2, safe s1 -> safe s2 -> safe (Ssequence s1 s2).
  Proof.
    intros s1 s2 H1 H2 le m t le' m' out HP H. inv H.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, E2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
        exact (H2 _ _ _ _ _ _ (H1 _ _ _ _ _ _ HP E1) E2) end.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _ |- _ => exact (H1 _ _ _ _ _ _ HP E1) end.
  Qed.

  Lemma safe_if : forall a s1 s2, safe s1 -> safe s2 -> safe (Sifthenelse a s1 s2).
  Proof.
    intros a s1 s2 H1 H2 le m t le' m' out HP H. inv H.
    match goal with E : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ =>
      destruct b; exact (ltac:(first [exact (H1 _ _ _ _ _ _ HP E) | exact (H2 _ _ _ _ _ _ HP E)])) end.
  Qed.

  Lemma safe_loop : forall s1 s2, safe s1 -> safe s2 -> safe (Sloop s1 s2).
  Proof.
    intros s1 s2 H1 H2 le m t le' m' out HP H.
    remember (Sloop s1 s2) as S eqn:ES.
    remember empty_env as e0 eqn:Ee.
    revert HP. induction H; intros HP; try discriminate ES; injection ES as -> ->; subst e.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _ |- _ => exact (H1 _ _ _ _ _ _ HP E1) end.
    - match goal with E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, E2 : exec_stmt _ _ _ _ _ s2 _ _ _ _ |- _ =>
        exact (H2 _ _ _ _ _ _ (H1 _ _ _ _ _ _ HP E1) E2) end.
    - match goal with
      | E1 : exec_stmt _ _ _ _ _ s1 _ _ _ _, E2 : exec_stmt _ _ _ _ _ s2 _ _ _ _,
        IH : Sloop s1 s2 = Sloop s1 s2 -> empty_env = empty_env -> P _ -> P _ |- _ =>
        exact (IH eq_refl eq_refl (H2 _ _ _ _ _ _ (H1 _ _ _ _ _ _ HP E1) E2)) end.
  Qed.

  Lemma safe_skip : safe Sskip.
  Proof. intros le m t le' m' out HP H. inv H. exact HP. Qed.
  Lemma safe_set : forall i a, safe (Sset i a).
  Proof. intros i a le m t le' m' out HP H. inv H. exact HP. Qed.
  Lemma safe_break : safe Sbreak.
  Proof. intros le m t le' m' out HP H. inv H. exact HP. Qed.
  Lemma safe_continue : safe Scontinue.
  Proof. intros le m t le' m' out HP H. inv H. exact HP. Qed.
  Lemma safe_return : forall a, safe (Sreturn a).
  Proof. intros a le m t le' m' out HP H. inv H; exact HP. Qed.
  Lemma safe_label : forall l s, safe s -> safe (Slabel l s).
  Proof.
    intros l s Hs le m t le' m' out HP H. inv H.
  Qed.

  Fixpoint all_safe (ls : labeled_statements) : Prop :=
    match ls with
    | LSnil => True
    | LScons _ s ls' => safe s /\ all_safe ls'
    end.

  Lemma seq_ls_safe : forall ls, all_safe ls -> safe (seq_of_labeled_statement ls).
  Proof.
    induction ls as [| c s ls IH]; intros H; cbn [seq_of_labeled_statement].
    - exact safe_skip.
    - destruct H as (Hs & Hl). exact (safe_seq _ _ Hs (IH Hl)).
  Qed.

  Lemma select_default_safe : forall ls, all_safe ls -> all_safe (select_switch_default ls).
  Proof.
    induction ls as [| c s ls IH]; intros H; cbn [select_switch_default]; [exact H |].
    destruct c; [exact (IH (proj2 H)) | exact H].
  Qed.

  Lemma select_case_safe : forall n ls l', all_safe ls ->
    select_switch_case n ls = Some l' -> all_safe l'.
  Proof.
    induction ls as [| c s ls IH]; intros l' H E; cbn [select_switch_case] in E;
      [discriminate E |].
    destruct c as [z|]; [| exact (IH _ (proj2 H) E)].
    destruct (zeq z n); [injection E as <-; exact H | exact (IH _ (proj2 H) E)].
  Qed.

  Lemma safe_switch : forall a ls, all_safe ls -> safe (Sswitch a ls).
  Proof.
    intros a ls Hl le m t le' m' out HP H. inv H.
    assert (Hsel : all_safe (select_switch n ls)).
    { unfold select_switch. destruct (select_switch_case n ls) eqn:E.
      - exact (select_case_safe _ _ _ Hl E).
      - exact (select_default_safe _ Hl). }
    match goal with E : exec_stmt _ _ _ _ _ (seq_of_labeled_statement _) _ _ _ _ |- _ =>
      exact (seq_ls_safe _ Hsel _ _ _ _ _ _ HP E) end.
  Qed.

  (* ---- the obligations make each piece safe ---- *)
  Lemma gms_call_spec : forall s f, gms_call s = Some f ->
    exists t o rt cc, s = Ssequence (Sset t (Evar gid gty))
                        (Scall o (Evar f (Tfunction [gty] rt cc)) [Etempvar t gty]).
  Proof.
    intros s f E. unfold gms_call in E.
    repeat match goal with
           | H : (if ?c then _ else _) = Some _ |- _ =>
               destruct c eqn:?; [| discriminate H]
           | H : match ?x with _ => _ end = Some _ |- _ => destruct x; try discriminate H
           end.
    injection E as <-.
    repeat match goal with
           | H : (_ && _) = true |- _ => apply andb_prop in H; destruct H
           | H : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in H; subst
           | H : proj_sumbool _ = true |- _ => apply proj_sumbool_true in H; subst
           end.
    eauto.
  Qed.

  Lemma safe_ocall : forall s f, gms_call s = Some f -> obl_ok (OCall f) -> safe s.
  Proof.
    intros s f E Ho le m t le' m' out HP H.
    destruct (gms_call_spec s f E) as (tv & o & rt & cc & ->).
    inv H; [| match goal with E2 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv E2 end;
              congruence].
    match goal with E1 : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv E1 end.
    match goal with E2 : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv E2 end.
    match goal with Hv : eval_expr _ _ _ _ (Evar f _) _ |- _ =>
      destruct (eval_Evar_fun _ _ _ _ _ _ _ Hv) as (bf & Hbf & ->) end.
    match goal with Hl : eval_exprlist _ _ _ _ (_ :: _) _ _ |- _ => inv Hl end.
    match goal with Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv Ht end.
    2: match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hl end.
    match goal with Hg : (PTree.set _ _ _) ! _ = Some _ |- _ =>
      rewrite PTree.gss in Hg; injection Hg as <- end.
    match goal with Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hc; injection Hc as <- <- <- end.
    match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => cbn [typeof] in Hc end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Evar gid gty) _, Hc : sem_cast _ _ _ _ = Some _,
      Hff : Genv.find_funct _ _ = Some _, Ht' : type_of_fundef _ = _,
      Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        exact (Ho _ _ _ _ _ _ _ _ _ _ _ Hev Hc Hbf Hff Ht' HP Hf)
    end.
  Qed.

  Lemma safe_oany : forall o al f fty, is_fun_ty fty = true ->
    obl_ok (OAny f fty al) -> safe (Scall o (Evar f fty) al).
  Proof.
    intros o al f fty Ht Ho le m t le' m' out HP H. inv H.
    match goal with Hv : eval_expr _ _ _ _ (Evar f _) _ |- _ =>
      destruct (eval_Evar_fun' _ _ _ _ _ Ht Hv) as (bf & Hbf & ->) end.
    match goal with
    | Hc : classify_fun _ = _, Hff : Genv.find_funct _ _ = Some _,
      Ht' : type_of_fundef _ = _, Hl : eval_exprlist _ _ _ _ _ _ _,
      Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        exact (Ho _ _ _ _ _ _ _ _ _ _ _ Hc Hbf Hff Ht' Hl HP Hf)
    end.
  Qed.

  Lemma safe_oblk : forall s, obl_ok (OBlk s) -> safe s.
  Proof. intros s Ho. exact Ho. Qed.

  (* ---- soundness of the checker ---- *)
  Fixpoint cl_sound (s : statement) :
    forall l, cl s = Some l -> Forall obl_ok l -> safe s
  with cl_ls_sound (ls : labeled_statements) :
    forall l, cl_ls ls = Some l -> Forall obl_ok l -> all_safe ls.
  Proof.
    - destruct s; intros ol E F; cbn [cl] in E.
      + exact safe_skip.
      + injection E as <-. inversion F; subst. exact (safe_oblk _ H1).
      + exact (safe_set _ _).
      + destruct e; try discriminate E.
        destruct (is_fun_ty t) eqn:Ht; [| discriminate E].
        injection E as <-. inversion F; subst. exact (safe_oany o l i t Ht H1).
      + discriminate E.
      + destruct (gms_call (Ssequence s1 s2)) eqn:Eg.
        * injection E as <-. inversion F; subst. exact (safe_ocall _ _ Eg H1).
        * destruct (straight (Ssequence s1 s2) && has_asg (Ssequence s1 s2)).
          -- injection E as <-. inversion F; subst. exact (safe_oblk _ H1).
          -- destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
             apply Forall_app in F. destruct F as (Fx & Fy).
             exact (safe_seq _ _ (cl_sound _ _ Hx Fx) (cl_sound _ _ Hy Fy)).
      + destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
        apply Forall_app in F. destruct F as (Fx & Fy).
        exact (safe_if _ _ _ (cl_sound _ _ Hx Fx) (cl_sound _ _ Hy Fy)).
      + destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
        apply Forall_app in F. destruct F as (Fx & Fy).
        exact (safe_loop _ _ (cl_sound _ _ Hx Fx) (cl_sound _ _ Hy Fy)).
      + exact safe_break.
      + exact safe_continue.
      + exact (safe_return _).
      + exact (safe_switch _ _ (cl_ls_sound _ _ E F)).
      + exact (safe_label _ _ (cl_sound _ _ E F)).
      + discriminate E.
    - destruct ls; intros ol E F; cbn [cl_ls all_safe] in *.
      + exact I.
      + destruct (ocat_some _ _ _ E) as (x & y & Hx & Hy & ->).
        apply Forall_app in F. destruct F as (Fx & Fy).
        exact (conj (cl_sound _ _ Hx Fx) (cl_ls_sound _ _ Hy Fy)).
  Qed.

  (* a function with no stack variables: its call keeps P *)
  Theorem funcall_safe : forall f l vargs m t m' vr,
    fn_vars f = nil -> cl (fn_body f) = Some l -> Forall obl_ok l ->
    P m -> eval_funcall function_entry2 ge m (Internal f) vargs t m' vr -> P m'.
  Proof.
    intros f l vargs m t m' vr Hv E F HP H. inv H.
    match goal with Hfe : function_entry2 _ _ _ _ _ _ _ |- _ => inv Hfe end.
    match goal with Hav : alloc_variables _ _ _ _ _ _ |- _ =>
      rewrite Hv in Hav; inv Hav end.
    match goal with Hfree : Mem.free_list _ _ = Some _ |- _ =>
      cbn in Hfree; injection Hfree as <- end.
    match goal with Hx : exec_stmt _ _ _ _ _ (fn_body f) _ _ _ _ |- _ =>
      exact (cl_sound _ _ E F _ _ _ _ _ _ HP Hx) end.
  Qed.

End FrameCalls.

(* ---- an expression reads only its own temps ---- *)
Fixpoint temps_of (a : expr) : list ident :=
  match a with
  | Etempvar i _ => [i]
  | Ederef a1 _ | Eaddrof a1 _ | Eunop _ a1 _ | Ecast a1 _ | Efield a1 _ _ => temps_of a1
  | Ebinop _ a1 a2 _ => temps_of a1 ++ temps_of a2
  | _ => []
  end.

Section Agree.
  Variables (ge : genv) (e : env) (le le0 : temp_env) (m : mem).

  Lemma eval_agree :
    (forall a v, eval_expr ge e le m a v ->
       (forall i, In i (temps_of a) -> le0 ! i = le ! i) -> eval_expr ge e le0 m a v)
    /\ (forall a b o bf, eval_lvalue ge e le m a b o bf ->
       (forall i, In i (temps_of a) -> le0 ! i = le ! i) -> eval_lvalue ge e le0 m a b o bf).
  Proof.
    apply eval_expr_lvalue_ind; intros; cbn [temps_of] in *;
      try (econstructor; eauto; fail).
    - match goal with HA : forall i, In i [id] -> _ |- _ =>
        constructor; rewrite (HA id (or_introl eq_refl)); assumption end.
    - match goal with
      | HA : forall i, In i (temps_of a1 ++ temps_of a2) -> _,
        I1 : (forall i, In i (temps_of a1) -> _) -> eval_expr _ _ _ _ a1 _,
        I2 : (forall i, In i (temps_of a2) -> _) -> eval_expr _ _ _ _ a2 _ |- _ =>
          econstructor;
            [ apply I1; intros i Hi; apply HA; apply in_or_app; left; exact Hi
            | apply I2; intros i Hi; apply HA; apply in_or_app; right; exact Hi
            | eassumption ]
      end.
  Qed.
End Agree.

Lemma exec_assign_agree : forall ge le le0 m a1 a2 t le' m' out,
  exec_stmt function_entry2 ge empty_env le m (Sassign a1 a2) t le' m' out ->
  (forall i, In i (temps_of a1 ++ temps_of a2) -> le0 ! i = le ! i) ->
  exec_stmt function_entry2 ge empty_env le0 m (Sassign a1 a2) t le0 m' out.
Proof.
  intros ge le le0 m a1 a2 t le' m' out H Ha. inv H.
  match goal with
  | L : eval_lvalue _ _ ?l _ a1 _ _ _, R : eval_expr _ _ ?l _ a2 _ |- _ =>
      econstructor;
        [ apply (proj2 (eval_agree ge empty_env l le0 m) _ _ _ _ L);
          intros i Hi; apply Ha; apply in_or_app; left; exact Hi
        | apply (proj1 (eval_agree ge empty_env l le0 m) _ _ R);
          intros i Hi; apply Ha; apply in_or_app; right; exact Hi
        | eassumption | eassumption ]
  end.
Qed.
