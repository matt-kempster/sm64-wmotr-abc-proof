(* ActionValue.v -- P4 kickoff: value-level reasoning about the action field.
 *
 * The FlyingFrame bridge stopped at "no reached function writes the action field"
 * -- false, because set_mario_action does. P4 replaces that with value tracking:
 * the action field's NEW value, not merely whether it changed. This file is the
 * de-risking experiment for P4 (see docs/p4-exploration.md):
 *
 *   (1) the reusable KERNEL -- writing Vint v into the action field makes the
 *       action load read back Vint v (the write side of the value frame);
 *   (2) REAL function value-specs -- set_mario_action_submerged and
 *       set_mario_action_cutscene return their input action UNCHANGED (validates
 *       big-step funcall inversion + return-value tracking on actual SM64 code).
 *       The `_returns_arg` pattern reuses exec_prefix_return_tempvar, which now
 *       accepts a `switch` prefix (escape_free: cases that only break/fall-through
 *       finish Out_normal, since outcome_switch absorbs Out_break).
 *
 * These are the "pass-through" group setters. moving/airborne additionally remap
 * some actions (always to NON-flying values) -- their non-fabrication spec is the
 * next leaf. Then P4's "Piece A" value-set frame induction.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.

(* ------------------------------------------------------------------ *)
(* KERNEL: a By_value store of (Vint v) into a scalar field reads back  *)
(* exactly (Vint v). For the action field (tuint, By_value Mint32) the  *)
(* load_result is the identity on Vint, so the load returns Some(Vint v).*)
(* ------------------------------------------------------------------ *)
Lemma assign_loc_scalar_load_same :
  forall ce m b ofs v m',
    assign_loc ce (Tint I32 Unsigned noattr) m b ofs Full (Vint v) m' ->
    Mem.load Mint32 m' b (Ptrofs.unsigned ofs) = Some (Vint v).
Proof.
  intros ce m b ofs v m' H. inv H.
  - (* By_value: access_mode tuint = By_value Mint32, storev Mint32 *)
    match goal with
    | Ham : access_mode _ = By_value ?chk, Hs : Mem.storev ?chk _ _ _ = Some _ |- _ =>
        simpl in Ham; inversion Ham; subst;
        unfold Mem.storev in Hs;
        erewrite Mem.load_store_same by exact Hs; reflexivity
    end.
Qed.

(* ------------------------------------------------------------------ *)
(* REUSABLE: a temp the statement never assigns is preserved across     *)
(* execution. set_free i s = true means i is not the target of any Sset *)
(* /Scall/Sbuiltin in s (the only temp-binding statements). Used to     *)
(* track that a function's action ARGUMENT temp survives to the return. *)
(* ------------------------------------------------------------------ *)
Definition opt_set_free (i : ident) (optid : option ident) : bool :=
  match optid with Some id => negb (Pos.eqb id i) | None => true end.

Fixpoint set_free (i : ident) (s : statement) : bool :=
  match s with
  | Sset id _                           => negb (Pos.eqb id i)
  | Scall optid _ _                     => opt_set_free i optid
  | Sbuiltin optid _ _ _                => opt_set_free i optid
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2
                                        => set_free i s1 && set_free i s2
  | Slabel _ s1                         => set_free i s1
  | Sswitch _ ls                        => set_free_ls i ls
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sassign _ _ | Sgoto _ => true
  end
with set_free_ls (i : ident) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => true
  | LScons _ s rest => set_free i s && set_free_ls i rest
  end.

(* select_switch / seq_of_labeled_statement preserve set_free (switch case). *)
Lemma set_free_ssd :
  forall i sl, set_free_ls i sl = true -> set_free_ls i (select_switch_default sl) = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; auto. apply andb_true_iff in H; destruct H; auto.
Qed.

Lemma set_free_ssc :
  forall i n sl res,
    set_free_ls i sl = true -> select_switch_case n sl = Some res -> set_free_ls i res = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res H Hsel; try discriminate.
  apply andb_true_iff in H; destruct H as [Hs Hrest].
  destruct o as [c|].
  - destruct (zeq c n).
    + inv Hsel. simpl. rewrite Hs, Hrest; auto.
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma set_free_select_switch :
  forall i n sl, set_free_ls i sl = true -> set_free_ls i (select_switch n sl) = true.
Proof.
  intros i n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply set_free_ssc; eauto.
  - apply set_free_ssd; auto.
Qed.

Lemma set_free_seq_of_ls :
  forall i ls, set_free_ls i ls = true -> set_free i (seq_of_labeled_statement ls) = true.
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H; destruct H. rewrite H; simpl; auto.
Qed.

Lemma exec_stmt_preserves_temp :
  forall i fe ge e le m s t le' m' out,
    exec_stmt fe ge e le m s t le' m' out ->
    set_free i s = true ->
    le' ! i = le ! i.
Proof.
  intros i fe ge e le m s t le' m' out H.
  induction H; intros Hsf; simpl in Hsf; auto; try discriminate.
  - (* Sset id a v: id <> i *)
    apply negb_true_iff in Hsf; apply Pos.eqb_neq in Hsf. rewrite PTree.gso by auto. reflexivity.
  - (* Scall *)
    unfold opt_set_free in Hsf. destruct optid as [id|]; simpl.
    + apply negb_true_iff in Hsf; apply Pos.eqb_neq in Hsf. rewrite PTree.gso by auto. reflexivity.
    + reflexivity.
  - (* Sbuiltin *)
    unfold opt_set_free in Hsf. destruct optid as [id|]; simpl.
    + apply negb_true_iff in Hsf; apply Pos.eqb_neq in Hsf. rewrite PTree.gso by auto. reflexivity.
    + reflexivity.
  - (* Sseq_1 *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 Hs2].
    rewrite IHexec_stmt2 by exact Hs2. apply IHexec_stmt1; exact Hs1.
  - (* Sseq_2 *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 _]. apply IHexec_stmt; exact Hs1.
  - (* Sifthenelse *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 Hs2].
    apply IHexec_stmt; destruct b; assumption.
  - (* Sloop_stop1 *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 _]. apply IHexec_stmt; exact Hs1.
  - (* Sloop_stop2 *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 Hs2].
    rewrite IHexec_stmt2 by exact Hs2. apply IHexec_stmt1; exact Hs1.
  - (* Sloop_loop *)
    apply andb_true_iff in Hsf; destruct Hsf as [Hs1 Hs2].
    rewrite IHexec_stmt3 by (simpl; rewrite Hs1, Hs2; reflexivity).
    rewrite IHexec_stmt2 by exact Hs2. apply IHexec_stmt1; exact Hs1.
  - (* Sswitch *)
    apply IHexec_stmt.
    apply set_free_seq_of_ls. apply set_free_select_switch. exact Hsf.
Qed.

(* escape_free: no return/continue/goto/loop; Sbreak IS allowed (it is absorbed
   by an enclosing switch). Such a statement executes to Out_normal or Out_break.
   This is what lets a `switch` whose cases only break/fall-through count as
   straight-line for the purpose of reaching a trailing Sreturn. *)
Fixpoint escape_free (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ | Sbreak => true
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 => escape_free s1 && escape_free s2
  | Sswitch _ ls => escape_free_ls ls
  | _ => false
  end
with escape_free_ls (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => true
  | LScons _ s rest => escape_free s && escape_free_ls rest
  end.

Lemma escape_free_ssd :
  forall sl, escape_free_ls sl = true -> escape_free_ls (select_switch_default sl) = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; auto. apply andb_true_iff in H; destruct H; auto.
Qed.

Lemma escape_free_ssc :
  forall n sl res,
    escape_free_ls sl = true -> select_switch_case n sl = Some res -> escape_free_ls res = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res H Hsel; try discriminate.
  apply andb_true_iff in H; destruct H as [Hs Hrest].
  destruct o as [c|].
  - destruct (zeq c n).
    + inv Hsel. simpl. rewrite Hs, Hrest; auto.
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma escape_free_select_switch :
  forall n sl, escape_free_ls sl = true -> escape_free_ls (select_switch n sl) = true.
Proof.
  intros n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply escape_free_ssc; eauto.
  - apply escape_free_ssd; auto.
Qed.

Lemma escape_free_seq_of_ls :
  forall ls, escape_free_ls ls = true -> escape_free (seq_of_labeled_statement ls) = true.
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H; destruct H. rewrite H; simpl; auto.
Qed.

Lemma exec_escape_free :
  forall fe ge e le m s t le' m' out,
    exec_stmt fe ge e le m s t le' m' out ->
    escape_free s = true ->
    out = Out_normal \/ out = Out_break.
Proof.
  intros fe ge e le m s t le' m' out H.
  induction H; intros Hef; simpl in Hef; try discriminate; try (left; reflexivity).
  - (* Sseq_1: out = out2 *)
    apply andb_true_iff in Hef; destruct Hef as [_ He2]. exact (IHexec_stmt2 He2).
  - (* Sseq_2: out = out1, out1 <> Out_normal *)
    apply andb_true_iff in Hef; destruct Hef as [He1 _].
    destruct (IHexec_stmt He1) as [Hn | Hb]; [ congruence | right; exact Hb ].
  - (* Sifthenelse *)
    apply andb_true_iff in Hef; destruct Hef as [He1 He2].
    apply IHexec_stmt; destruct b; assumption.
  - (* Sbreak *) right; reflexivity.
  - (* Sswitch: outcome_switch of an inner Normal/Break is Normal *)
    assert (Hin : out = Out_normal \/ out = Out_break) by
      (apply IHexec_stmt; apply escape_free_seq_of_ls; apply escape_free_select_switch; exact Hef).
    left. destruct Hin as [Ho | Ho]; rewrite Ho; reflexivity.
Qed.

(* A straight-line statement always finishes Out_normal -- used to reach a
   trailing Sreturn through a function's prefix. A `switch` counts as long as its
   cases are escape_free (break/fall-through, no return/continue/goto). *)
Fixpoint exit_free (s : statement) : bool :=
  match s with
  | Sskip | Sset _ _ | Sassign _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 => exit_free s1 && exit_free s2
  | Sswitch _ ls => escape_free_ls ls
  | _ => false
  end.

Lemma exec_exit_free_normal :
  forall fe ge e le m s t le' m' out,
    exec_stmt fe ge e le m s t le' m' out ->
    exit_free s = true -> out = Out_normal.
Proof.
  intros fe ge e le m s t le' m' out H.
  induction H; intros Hef; simpl in Hef; try discriminate; auto.
  - (* Sseq_1 *) apply andb_true_iff in Hef; destruct Hef as [_ He2]; auto.
  - (* Sseq_2: s1 abnormal -- but exit_free s1 forces normal, contradiction *)
    apply andb_true_iff in Hef; destruct Hef as [He1 _].
    specialize (IHexec_stmt He1). congruence.
  - (* Sifthenelse *)
    apply andb_true_iff in Hef; destruct Hef as [He1 He2].
    apply IHexec_stmt; destruct b; assumption.
  - (* Sswitch: inner is escape_free, so its outcome is Normal/Break -> switch Normal *)
    assert (Hin : out = Out_normal \/ out = Out_break) by
      (eapply exec_escape_free;
        [ eassumption | apply escape_free_seq_of_ls; apply escape_free_select_switch; exact Hef ]).
    destruct Hin as [Ho | Ho]; rewrite Ho; reflexivity.
Qed.

(* A function whose body is `PREFIX; return (Etempvar id)`, where PREFIX is
   straight-line and never assigns id, returns exactly le_entry!id.  Reusable
   for every set_mario_action_<group> (each ends `return action`). *)
Lemma exec_prefix_return_tempvar :
  forall fe ge e le m pre id ty t le' m' out v,
    exec_stmt fe ge e le m (Ssequence pre (Sreturn (Some (Etempvar id ty)))) t le' m' out ->
    exit_free pre = true ->
    set_free id pre = true ->
    le ! id = Some v ->
    out = Out_return (Some (v, ty)).
Proof.
  intros fe ge e le m pre id ty t le' m' out v Hexec Hef Hsf Hv.
  inv Hexec.
  - (* Sseq_1: prefix normal, then the return *)
    match goal with Hpre : exec_stmt _ _ _ _ _ pre _ ?leA _ _ |- _ =>
      assert (Hp : leA ! id = Some v) by
        (rewrite (exec_stmt_preserves_temp id _ _ _ _ _ _ _ _ _ _ Hpre Hsf); exact Hv) end.
    match goal with HR : exec_stmt _ _ _ _ _ (Sreturn (Some _)) _ _ _ _ |- _ => inv HR end.
    match goal with Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv Hev end;
      try (match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv Hlv end).
    match goal with |- Out_return (Some (?x, _)) = _ =>
      assert (Hxv : x = v) by congruence; rewrite Hxv end.
    reflexivity.
  - (* Sseq_2: prefix abnormal -- impossible (exit_free) *)
    match goal with Hpre : exec_stmt _ _ _ _ _ pre _ _ _ ?o1, Hne : ?o1 <> Out_normal |- _ =>
      assert (o1 = Out_normal) by
        (apply (exec_exit_free_normal _ _ _ _ _ _ _ _ _ _ Hpre); exact Hef);
      congruence end.
Qed.

(* ================================================================== *)
(* FIRST REAL FUNCTION VALUE-SPEC: set_mario_action_submerged returns  *)
(* its input action UNCHANGED (the C body only touches m->vel[1] and    *)
(* `return action;`).  Now linear via exec_prefix_return_tempvar.       *)
(* Validates value-level big-step funcall reasoning on real SM64 code.  *)
(* ================================================================== *)
Lemma set_mario_action_submerged_returns_arg :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_submerged)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    res = Vint a.
Proof.
  intros ge m bm a arg t m' res H. inv H.
  match goal with H' : function_entry2 _ _ _ _ _ _ _ |- _ => rename H' into Hentry end.
  match goal with H' : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename H' into Hexec end.
  match goal with H' : outcome_result_value _ _ _ _ |- _ => rename H' into Hout end.
  (* entry env: the action argument temp holds (Vint a). *)
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
    assert (Hla1 : le1 ! mario._action = Some (Vint a)) by
      (vm_compute in Hb; injection Hb as Hb; rewrite <- Hb; vm_compute; reflexivity) end.
  (* body = PREFIX; return action.  helper: outcome returns the arg. *)
  unfold mario.f_set_mario_action_submerged in Hexec; cbn [fn_body] in Hexec.
  pose proof (exec_prefix_return_tempvar _ _ _ _ _ _ _ _ _ _ _ _ _ Hexec
                ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) Hla1) as Hoeq.
  (* outcome_result_value: res = sem_cast (Vint a) tuint tuint = Vint a. *)
  rewrite Hoeq in Hout. cbn in Hout. destruct Hout as [_ Hcast].
  vm_compute in Hcast. congruence.
Qed.

(* Same shape for the cutscene setter (its prefix is a `switch` whose cases only
   set velocity / call void helpers and break -- handled by the switch-aware
   exit_free).  Returns the input action unchanged. *)
Lemma set_mario_action_cutscene_returns_arg :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_cutscene)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    res = Vint a.
Proof.
  intros ge m bm a arg t m' res H. inv H.
  match goal with H' : function_entry2 _ _ _ _ _ _ _ |- _ => rename H' into Hentry end.
  match goal with H' : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename H' into Hexec end.
  match goal with H' : outcome_result_value _ _ _ _ |- _ => rename H' into Hout end.
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
    assert (Hla1 : le1 ! mario._action = Some (Vint a)) by
      (vm_compute in Hb; injection Hb as Hb; rewrite <- Hb; vm_compute; reflexivity) end.
  unfold mario.f_set_mario_action_cutscene in Hexec; cbn [fn_body] in Hexec.
  pose proof (exec_prefix_return_tempvar _ _ _ _ _ _ _ _ _ _ _ _ _ Hexec
                ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) Hla1) as Hoeq.
  rewrite Hoeq in Hout. cbn in Hout. destruct Hout as [_ Hcast].
  vm_compute in Hcast. congruence.
Qed.
