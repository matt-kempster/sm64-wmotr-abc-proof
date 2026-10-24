(* ====================================================================== *)
(* UnusedParam: a parameter the body never reads cannot change the call.   *)
(*                                                                          *)
(* THEOREM (funcall_unused_param): under function_entry2 (parameters are    *)
(* temporaries), if f has the single parameter x and no expression of its  *)
(* body reads the temp x (s_reads x body = false, a syntactic check), then  *)
(* a big-step call of f with argument v1 has, for every v2, a call with     *)
(* argument v2 with the same trace, final memory and result.               *)
(*                                                                          *)
(* Used for SM64's execute_mario_action(UNUSED struct Object *o)            *)
(* (mario.c:1699): the frame relation pins the argument to Vptr b 0, the    *)
(* real caller (bhv_mario_update) passes &gObjectPool[k] (RealFrameLinked). *)
(* Nothing about any particular program is assumed.                         *)
(* ====================================================================== *)

From Coq Require Import List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events
  Globalenvs Ctypes Cop Clight ClightBigstep.
Import ListNotations.

Section Reads.
Variable x : ident.

Fixpoint e_reads (a : expr) : bool :=
  match a with
  | Etempvar id _ => Pos.eqb id x
  | Eaddrof b _ | Ederef b _ | Eunop _ b _ | Ecast b _ | Efield b _ _ => e_reads b
  | Ebinop _ b c _ => e_reads b || e_reads c
  | _ => false
  end.

Fixpoint s_reads (s : statement) : bool :=
  match s with
  | Sassign a b => e_reads a || e_reads b
  | Sset _ a => e_reads a
  | Scall _ f al => e_reads f || existsb e_reads al
  | Sbuiltin _ _ _ al => existsb e_reads al
  | Ssequence a b | Sloop a b => s_reads a || s_reads b
  | Sifthenelse c a b => e_reads c || s_reads a || s_reads b
  | Sreturn (Some a) => e_reads a
  | Sswitch a ls => e_reads a || ls_reads ls
  | Slabel _ a => s_reads a
  | _ => false
  end
with ls_reads (ls : labeled_statements) : bool :=
  match ls with LSnil => false | LScons _ a r => s_reads a || ls_reads r end.

(* two temp envs that agree everywhere except at x *)
Definition agree (le1 le2 : temp_env) : Prop :=
  forall id, id <> x -> le1 ! id = le2 ! id.

Lemma agree_set : forall le1 le2 id v,
  agree le1 le2 -> agree (PTree.set id v le1) (PTree.set id v le2).
Proof.
  intros le1 le2 id v H i Hi. rewrite !PTree.gsspec.
  destruct (peq i id); [reflexivity | exact (H i Hi)].
Qed.

Lemma agree_setopt : forall le1 le2 o v,
  agree le1 le2 -> agree (set_opttemp o v le1) (set_opttemp o v le2).
Proof. intros le1 le2 [id|] v H; cbn; [exact (agree_set _ _ _ _ H) | exact H]. Qed.

Section Expr.
Variables (ge : genv) (e : env) (le1 le2 : temp_env) (m : mem).
Hypothesis Hag : agree le1 le2.

Lemma eval_agree_both :
  (forall a v, eval_expr ge e le1 m a v -> e_reads a = false -> eval_expr ge e le2 m a v) /\
  (forall a b o bf, eval_lvalue ge e le1 m a b o bf -> e_reads a = false ->
                    eval_lvalue ge e le2 m a b o bf).
Proof.
  apply eval_expr_lvalue_ind; intros; cbn in *;
    repeat match goal with H : (_ || _) = false |- _ => apply orb_false_iff in H as [? ?] end.
  - constructor.
  - constructor.
  - constructor.
  - constructor.
  - constructor. rewrite <- Hag; [assumption |].
    apply Pos.eqb_neq; assumption.
  - constructor; auto.
  - econstructor; eauto.
  - econstructor; eauto.
  - econstructor; eauto.
  - constructor.
  - constructor.
  - econstructor; eauto.
  - eapply eval_Evar_local; eauto.
  - eapply eval_Evar_global; eauto.
  - constructor; auto.
  - eapply eval_Efield_struct; eauto.
  - eapply eval_Efield_union; eauto.
Qed.

Lemma eval_expr_agree : forall a v,
  eval_expr ge e le1 m a v -> e_reads a = false -> eval_expr ge e le2 m a v.
Proof. exact (proj1 eval_agree_both). Qed.

Lemma eval_lvalue_agree : forall a b o bf,
  eval_lvalue ge e le1 m a b o bf -> e_reads a = false -> eval_lvalue ge e le2 m a b o bf.
Proof. exact (proj2 eval_agree_both). Qed.

Lemma eval_exprlist_agree : forall al tys vs,
  eval_exprlist ge e le1 m al tys vs -> existsb e_reads al = false ->
  eval_exprlist ge e le2 m al tys vs.
Proof.
  induction 1; intros Hr; cbn in Hr; [constructor |].
  apply orb_false_iff in Hr as [Hr1 Hr2].
  econstructor; eauto using eval_expr_agree.
Qed.
End Expr.

Lemma select_switch_case_reads : forall n ls ls',
  ls_reads ls = false -> select_switch_case n ls = Some ls' -> ls_reads ls' = false.
Proof.
  induction ls as [| c s r IH]; intros ls' Hr Hs; cbn in *; [discriminate |].
  destruct c as [c|].
  - destruct (zeq c n); [injection Hs as <-; exact Hr |].
    apply orb_false_iff in Hr as [_ Hr]. exact (IH _ Hr Hs).
  - apply orb_false_iff in Hr as [_ Hr]. exact (IH _ Hr Hs).
Qed.

Lemma select_switch_default_reads : forall ls,
  ls_reads ls = false -> ls_reads (select_switch_default ls) = false.
Proof.
  induction ls as [| c s r IH]; intros Hr; cbn in *; [reflexivity |].
  destruct c as [c|]; [| exact Hr].
  apply orb_false_iff in Hr as [_ Hr]. exact (IH Hr).
Qed.

Lemma seq_of_ls_reads : forall ls,
  ls_reads ls = false -> s_reads (seq_of_labeled_statement ls) = false.
Proof.
  induction ls as [| c s r IH]; intros Hr; cbn in *; [reflexivity |].
  apply orb_false_iff in Hr as [Hr1 Hr2]. rewrite Hr1, (IH Hr2). reflexivity.
Qed.

Lemma select_switch_reads : forall n ls,
  ls_reads ls = false -> s_reads (seq_of_labeled_statement (select_switch n ls)) = false.
Proof.
  intros n ls Hr. apply seq_of_ls_reads. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - exact (select_switch_case_reads _ _ _ Hr E).
  - exact (select_switch_default_reads _ Hr).
Qed.

Section Stmt.
Variable ge : genv.

Theorem exec_agree :
  forall e le1 m s t le1' m' out,
    exec_stmt function_entry2 ge e le1 m s t le1' m' out ->
    s_reads s = false ->
    forall le2, agree le1 le2 ->
    exists le2', agree le1' le2' /\
      exec_stmt function_entry2 ge e le2 m s t le2' m' out.
Proof.
  induction 1; intros Hr le2' Hag; cbn in Hr;
    repeat match goal with H : (_ || _) = false |- _ => apply orb_false_iff in H as [? ?] end.
  - exists le2'. split; [exact Hag | constructor].
  - exists le2'. split; [exact Hag |].
    econstructor; eauto using eval_expr_agree, eval_lvalue_agree.
  - exists (PTree.set id v le2'). split; [exact (agree_set _ _ _ _ Hag) |].
    constructor. eauto using eval_expr_agree.
  - exists (set_opttemp optid vres le2'). split; [exact (agree_setopt _ _ _ _ Hag) |].
    econstructor; eauto using eval_expr_agree, eval_exprlist_agree.
  - exists (set_opttemp optid vres le2'). split; [exact (agree_setopt _ _ _ _ Hag) |].
    econstructor; eauto using eval_exprlist_agree.
  - destruct (IHexec_stmt1 ltac:(assumption) _ Hag) as (l1 & A1 & E1).
    destruct (IHexec_stmt2 ltac:(assumption) _ A1) as (l2 & A2 & E2).
    exists l2. split; [exact A2 | eapply exec_Sseq_1; eauto].
  - destruct (IHexec_stmt ltac:(assumption) _ Hag) as (l1 & A1 & E1).
    exists l1. split; [exact A1 | eapply exec_Sseq_2; eauto].
  - assert (Hb : s_reads (if b then s1 else s2) = false) by (destruct b; assumption).
    destruct (IHexec_stmt Hb _ Hag) as (l1 & A1 & E1).
    exists l1. split; [exact A1 | eapply exec_Sifthenelse; eauto using eval_expr_agree].
  - exists le2'. split; [exact Hag | constructor].
  - exists le2'. split; [exact Hag | constructor; eauto using eval_expr_agree].
  - exists le2'. split; [exact Hag | constructor].
  - exists le2'. split; [exact Hag | constructor].
  - destruct (IHexec_stmt ltac:(assumption) _ Hag) as (l1 & A1 & E1).
    exists l1. split; [exact A1 | eapply exec_Sloop_stop1; eauto].
  - destruct (IHexec_stmt1 ltac:(assumption) _ Hag) as (l1 & A1 & E1).
    destruct (IHexec_stmt2 ltac:(assumption) _ A1) as (l2 & A2 & E2).
    exists l2. split; [exact A2 | eapply exec_Sloop_stop2; eauto].
  - destruct (IHexec_stmt1 ltac:(assumption) _ Hag) as (l1 & A1 & E1).
    destruct (IHexec_stmt2 ltac:(assumption) _ A1) as (l2 & A2 & E2).
    assert (Hr3 : s_reads (Sloop s1 s2) = false)
      by (cbn; apply orb_false_iff; split; assumption).
    destruct (IHexec_stmt3 Hr3 _ A2) as (l3 & A3 & E3).
    exists l3. split; [exact A3 | eapply exec_Sloop_loop; eauto].
  - assert (Hs : s_reads (seq_of_labeled_statement (select_switch n sl)) = false)
      by (apply select_switch_reads; assumption).
    destruct (IHexec_stmt Hs _ Hag) as (l1 & A1 & E1).
    exists l1. split; [exact A1 | eapply exec_Sswitch; eauto using eval_expr_agree].
Qed.

(* THE THEOREM *)
Theorem funcall_unused_param :
  forall m f ty v1 v2 t m' res,
    fn_params f = [(x, ty)] ->
    s_reads (fn_body f) = false ->
    eval_funcall function_entry2 ge m (Internal f) [v1] t m' res ->
    eval_funcall function_entry2 ge m (Internal f) [v2] t m' res.
Proof.
  intros m f ty v1 v2 t m' res Hp Hr H.
  assert (Ha : agree (PTree.set x v1 (create_undef_temps (fn_temps f)))
                     (PTree.set x v2 (create_undef_temps (fn_temps f)))).
  { intros i Hi. rewrite !PTree.gso by exact Hi. reflexivity. }
  inversion H; subst.
  match goal with Hent : function_entry2 _ _ _ _ _ _ _ |- _ => inversion Hent; subst end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
    rewrite Hp in Hb; cbn in Hb; injection Hb as Hb; subst end.
  match goal with Hex : exec_stmt _ _ _ _ _ (fn_body f) _ _ _ _ |- _ =>
    destruct (exec_agree _ _ _ _ _ _ _ _ Hex Hr _ Ha) as (l2' & _ & E2) end.
  eapply eval_funcall_internal; [| exact E2 | eassumption | eassumption].
  constructor; try assumption. rewrite Hp. reflexivity.
Qed.
End Stmt.
End Reads.
