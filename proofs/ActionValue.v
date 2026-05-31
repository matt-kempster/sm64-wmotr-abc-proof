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
 * ALL FOUR group setters are now specified: submerged/cutscene "pass-through"
 * (return the arg unchanged); moving/airborne NON-FABRICATING (non-flying arg =>
 * non-flying result -- they remap the action but only to non-flying CONSTANTS),
 * proved via the flows_into dataflow engine + exec_trailing_return (reach the
 * final-value return through deep nesting). Next: the full set_mario_action spec
 * (it routes action := <group-setter call result>, consuming these four), then
 * P4's "Piece A" value-set frame induction.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory Globalenvs Ctypes Cop Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying.

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

(* ------------------------------------------------------------------ *)
(* NON-FABRICATION ENGINE: value-membership dataflow over a SET of      *)
(* temps (g : ident -> bool).  flows_into P g s = true means every Sset *)
(* to a g-temp assigns either a literal Econst satisfying P or ANOTHER  *)
(* g-temp, and no call/builtin targets a g-temp.  Then the invariant    *)
(* "every g-temp holding a Vint holds a P-value" survives execution.    *)
(* With g = {the action temp and the ternary feeder temps} and P =      *)
(* is-non-flying, a setter that never assigns a flying CONSTANT keeps    *)
(* the action non-flying -- even through clightgen's `t = c?x:y; act=t`. *)
(* ------------------------------------------------------------------ *)
Fixpoint flows_into (P : int -> bool) (g : ident -> bool) (s : statement) : bool :=
  match s with
  | Sset id e =>
      if g id then match e with
                   | Econst_int n _ => P n
                   | Etempvar j _   => g j
                   | _              => false
                   end
      else true
  | Scall optid _ _      => match optid with Some j => negb (g j) | None => true end
  | Sbuiltin optid _ _ _ => match optid with Some j => negb (g j) | None => true end
  | Ssequence s1 s2 | Sifthenelse _ s1 s2 | Sloop s1 s2
                         => flows_into P g s1 && flows_into P g s2
  | Slabel _ s1          => flows_into P g s1
  | Sswitch _ ls         => flows_into_ls P g ls
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sassign _ _ | Sgoto _ => true
  end
with flows_into_ls (P : int -> bool) (g : ident -> bool) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil           => true
  | LScons _ s rest => flows_into P g s && flows_into_ls P g rest
  end.

Lemma flows_into_ssd :
  forall P g sl, flows_into_ls P g sl = true -> flows_into_ls P g (select_switch_default sl) = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros H; auto.
  destruct o as [c|]; auto. apply andb_true_iff in H; destruct H; auto.
Qed.

Lemma flows_into_ssc :
  forall P g n sl res,
    flows_into_ls P g sl = true -> select_switch_case n sl = Some res -> flows_into_ls P g res = true.
Proof.
  induction sl as [| o s rest IH]; simpl; intros res H Hsel; try discriminate.
  apply andb_true_iff in H; destruct H as [Hs Hrest].
  destruct o as [c|].
  - destruct (zeq c n).
    + inv Hsel. simpl. rewrite Hs, Hrest; auto.
    + eapply IH; eauto.
  - eapply IH; eauto.
Qed.

Lemma flows_into_select_switch :
  forall P g n sl, flows_into_ls P g sl = true -> flows_into_ls P g (select_switch n sl) = true.
Proof.
  intros P g n sl H. unfold select_switch.
  destruct (select_switch_case n sl) eqn:E.
  - eapply flows_into_ssc; eauto.
  - apply flows_into_ssd; auto.
Qed.

Lemma flows_into_seq_of_ls :
  forall P g ls, flows_into_ls P g ls = true -> flows_into P g (seq_of_labeled_statement ls) = true.
Proof.
  induction ls as [| o s rest IH]; simpl; intros H; auto.
  apply andb_true_iff in H; destruct H. rewrite H; simpl; auto.
Qed.

Lemma exec_flows_into :
  forall (P : int -> bool) (g : ident -> bool) fe ge e le m s t le' m' out,
    exec_stmt fe ge e le m s t le' m' out ->
    flows_into P g s = true ->
    (forall j v, g j = true -> le  ! j = Some (Vint v) -> P v = true) ->
    (forall j v, g j = true -> le' ! j = Some (Vint v) -> P v = true).
Proof.
  intros P g fe ge e le m s t le' m' out H.
  induction H; intros Hfi Hinv; simpl in Hfi; try exact Hinv; try discriminate.
  - (* Sset id a v *)
    intros j v0 Hgj Hjv. destruct (peq j id).
    + (* j = id: the assigned value is (Vint v0) *)
      subst j. rewrite PTree.gss in Hjv. inv Hjv.
      rewrite Hgj in Hfi. destruct a; try discriminate Hfi.
      * (* Econst_int n: eval is (Vint n) = (Vint v0); P n = Hfi *)
        match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ => inv He end;
          try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [ inv Hlv ] end).
        exact Hfi.
      * (* Etempvar k: eval gives le!k = Some (Vint v0), a g-temp, P by invariant *)
        match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv He end;
          try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [ inv Hlv ] end).
        match goal with Hk : _ ! _ = Some (Vint v0) |- _ => eapply Hinv; [ exact Hfi | exact Hk ] end.
    + (* j <> id: untouched *)
      rewrite PTree.gso in Hjv by auto. eapply Hinv; eauto.
  - (* Scall *)
    intros j v0 Hgj Hjv. destruct optid as [k|]; simpl in Hjv.
    + destruct (peq j k).
      * subst k. apply negb_true_iff in Hfi. rewrite Hgj in Hfi; discriminate.
      * rewrite PTree.gso in Hjv by auto. eapply Hinv; eauto.
    + eapply Hinv; eauto.
  - (* Sbuiltin *)
    intros j v0 Hgj Hjv. destruct optid as [k|]; simpl in Hjv.
    + destruct (peq j k).
      * subst k. apply negb_true_iff in Hfi. rewrite Hgj in Hfi; discriminate.
      * rewrite PTree.gso in Hjv by auto. eapply Hinv; eauto.
    + eapply Hinv; eauto.
  - (* Sseq_1 *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 Hf2].
    apply (IHexec_stmt2 Hf2). apply (IHexec_stmt1 Hf1). exact Hinv.
  - (* Sseq_2 *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 _]. apply (IHexec_stmt Hf1). exact Hinv.
  - (* Sifthenelse *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 Hf2].
    apply IHexec_stmt; [ destruct b; assumption | exact Hinv ].
  - (* Sloop_stop1 *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 _]. apply (IHexec_stmt Hf1). exact Hinv.
  - (* Sloop_stop2 *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 Hf2].
    apply (IHexec_stmt2 Hf2). apply (IHexec_stmt1 Hf1). exact Hinv.
  - (* Sloop_loop *)
    apply andb_true_iff in Hfi; destruct Hfi as [Hf1 Hf2].
    apply (IHexec_stmt3 ltac:(simpl; rewrite Hf1, Hf2; reflexivity)).
    apply (IHexec_stmt2 Hf2). apply (IHexec_stmt1 Hf1). exact Hinv.
  - (* Sswitch *)
    apply IHexec_stmt; [ | exact Hinv ].
    apply flows_into_seq_of_ls. apply flows_into_select_switch. exact Hfi.
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

(* General version: a body that is a (possibly deeply right-nested) sequence of
   exit_free statements ending in `return (Etempvar id)` returns the FINAL value
   of id (le' ! id), at whatever type the Etempvar carries. Handles the setters
   whose action temp is REASSIGNED (so we want the final value, not the entry
   value) and whose return is nested under many statements. *)
Fixpoint trailing_return_id (id : ident) (s : statement) : option type :=
  match s with
  | Sreturn (Some (Etempvar j t)) => if Pos.eqb j id then Some t else None
  | Ssequence s1 s2               => if exit_free s1 then trailing_return_id id s2 else None
  | _                             => None
  end.

Lemma exec_trailing_return :
  forall id s fe ge e le m t le' m' out ty,
    trailing_return_id id s = Some ty ->
    exec_stmt fe ge e le m s t le' m' out ->
    exists w, out = Out_return (Some (w, ty)) /\ le' ! id = Some w.
Proof.
  intros id s. induction s; intros fe ge env le m tr le' m' out ty Htr Hexec;
    simpl in Htr; try discriminate.
  - (* Ssequence s1 s2: s1 exit_free, return is in s2 *)
    destruct (exit_free s1) eqn:Hef; try discriminate.
    inv Hexec.
    + (* Sseq_1: s1 normal, then s2 *)
      eapply IHs2; [ exact Htr | eassumption ].
    + (* Sseq_2: s1 abnormal -- contradicts exit_free s1 *)
      match goal with HA : exec_stmt _ _ _ _ _ s1 _ _ _ ?o1, Hne : ?o1 <> Out_normal |- _ =>
        apply (exec_exit_free_normal _ _ _ _ _ _ _ _ _ _ HA) in Hef; congruence end.
  - (* Sreturn (Some (Etempvar id ty)) *)
    destruct o as [a|]; try discriminate. destruct a; try discriminate.
    destruct (Pos.eqb i id) eqn:Hid; try discriminate.
    apply Pos.eqb_eq in Hid; subst i. inv Htr.
    inv Hexec.
    match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => inv He end;
      try (match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ => solve [ inv Hlv ] end).
    eexists; split; [ reflexivity | eassumption ].
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

(* ================================================================== *)
(* NON-FABRICATION for a REMAPPING setter: set_mario_action_moving may  *)
(* reassign the action (to ACT_BEGIN_SLIDING etc.) but ONLY to non-     *)
(* flying CONSTANTS, so given a non-flying argument it returns a non-    *)
(* flying value.  Proved via the flows_into engine (action stays non-   *)
(* flying) + exec_trailing_return (the return reads the final action).  *)
(* ================================================================== *)
Lemma set_mario_action_moving_result :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_moving)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    is_flying_int a = false ->
    exists w, res = Vint w /\ is_flying_int w = false.
Proof.
  intros ge m bm a arg t m' res H Hnf. inv H.
  match goal with H' : function_entry2 _ _ _ _ _ _ _ |- _ => rename H' into Hentry end.
  match goal with H' : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename H' into Hexec end.
  match goal with H' : outcome_result_value _ _ _ _ |- _ => rename H' into Hout end.
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
    assert (Hla1 : le1 ! mario._action = Some (Vint a)) by
      (vm_compute in Hb; injection Hb as Hb; rewrite <- Hb; vm_compute; reflexivity) end.
  unfold mario.f_set_mario_action_moving in Hexec; cbn [fn_body] in Hexec.
  set (g := fun j => Pos.eqb j mario._action).
  set (P := fun n => negb (is_flying_int n)).
  (* entry invariant: the only g-temp is _action, holding the non-flying arg *)
  assert (Hinv : forall j v, g j = true -> le1 ! j = Some (Vint v) -> P v = true).
  { intros j v Hgj Hjv. unfold g in Hgj. apply Pos.eqb_eq in Hgj. subst j.
    rewrite Hla1 in Hjv. inv Hjv. unfold P. rewrite Hnf. reflexivity. }
  pose proof (exec_flows_into P g _ _ _ _ _ _ _ _ _ _ Hexec
                ltac:(vm_compute; reflexivity) Hinv) as Hfinal.
  (* the return reads the final action value *)
  eapply (exec_trailing_return mario._action) in Hexec; [ | vm_compute; reflexivity ].
  destruct Hexec as [rv [Houteq Hrvlk]].
  rewrite Houteq in Hout. cbn in Hout. destruct Hout as [_ Hcast].
  destruct rv as [ | n | | | | ]; vm_compute in Hcast; try discriminate.
  (* rv = Vint n; Hcast : Some (Vint n) = Some res *)
  specialize (Hfinal mario._action n ltac:(unfold g; apply Pos.eqb_refl) Hrvlk).
  unfold P in Hfinal. apply negb_true_iff in Hfinal.
  exists n. split; [ congruence | exact Hfinal ].
Qed.

(* Same non-fabrication for the airborne setter: its 600+-line body reassigns the
   action exactly once (the squish remap to ACT_JUMP, a non-flying constant) and
   otherwise only sets velocities in its switch, then returns the action. *)
Lemma set_mario_action_airborne_result :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_airborne)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    is_flying_int a = false ->
    exists w, res = Vint w /\ is_flying_int w = false.
Proof.
  intros ge m bm a arg t m' res H Hnf. inv H.
  match goal with H' : function_entry2 _ _ _ _ _ _ _ |- _ => rename H' into Hentry end.
  match goal with H' : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename H' into Hexec end.
  match goal with H' : outcome_result_value _ _ _ _ |- _ => rename H' into Hout end.
  inv Hentry.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?le1 |- _ =>
    assert (Hla1 : le1 ! mario._action = Some (Vint a)) by
      (vm_compute in Hb; injection Hb as Hb; rewrite <- Hb; vm_compute; reflexivity) end.
  unfold mario.f_set_mario_action_airborne in Hexec; cbn [fn_body] in Hexec.
  set (g := fun j => Pos.eqb j mario._action).
  set (P := fun n => negb (is_flying_int n)).
  assert (Hinv : forall j v, g j = true -> le1 ! j = Some (Vint v) -> P v = true).
  { intros j v Hgj Hjv. unfold g in Hgj. apply Pos.eqb_eq in Hgj. subst j.
    rewrite Hla1 in Hjv. inv Hjv. unfold P. rewrite Hnf. reflexivity. }
  pose proof (exec_flows_into P g _ _ _ _ _ _ _ _ _ _ Hexec
                ltac:(vm_compute; reflexivity) Hinv) as Hfinal.
  eapply (exec_trailing_return mario._action) in Hexec; [ | vm_compute; reflexivity ].
  destruct Hexec as [rv [Houteq Hrvlk]].
  rewrite Houteq in Hout. cbn in Hout. destruct Hout as [_ Hcast].
  destruct rv as [ | n | | | | ]; vm_compute in Hcast; try discriminate.
  specialize (Hfinal mario._action n ltac:(unfold g; apply Pos.eqb_refl) Hrvlk).
  unfold P in Hfinal. apply negb_true_iff in Hfinal.
  exists n. split; [ congruence | exact Hfinal ].
Qed.

(* Pass-through setters (submerged/cutscene return the arg) cast to the same
   uniform `_result` shape, so the switch lemma can treat all four uniformly. *)
Lemma set_mario_action_submerged_result :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_submerged)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    is_flying_int a = false ->
    exists w, res = Vint w /\ is_flying_int w = false.
Proof.
  intros ge m bm a arg t m' res H Hnf.
  exists a. split;
    [ exact (set_mario_action_submerged_returns_arg _ _ _ _ _ _ _ _ H) | exact Hnf ].
Qed.

Lemma set_mario_action_cutscene_result :
  forall ge m bm a arg t m' res,
    eval_funcall function_entry2 ge m
      (Internal mario.f_set_mario_action_cutscene)
      (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil) t m' res ->
    is_flying_int a = false ->
    exists w, res = Vint w /\ is_flying_int w = false.
Proof.
  intros ge m bm a arg t m' res H Hnf.
  exists a. split;
    [ exact (set_mario_action_cutscene_returns_arg _ _ _ _ _ _ _ _ H) | exact Hnf ].
Qed.

(* ================================================================== *)
(* INTERPROCEDURAL set_mario_action: it routes action through a switch  *)
(* to set_mario_action_<group>(m, action, arg), then writes m->action.  *)
(* First brick -- resolve each group-setter call target in the real     *)
(* program genv (vm_compute over globalenv mario.prog). *)
(* ================================================================== *)
Definition sma_ge : genv := globalenv mario.prog.

Lemma find_funct_set_mario_action_moving :
  exists b, Genv.find_symbol sma_ge mario._set_mario_action_moving = Some b /\
            Genv.find_funct_ptr sma_ge b = Some (Internal mario.f_set_mario_action_moving).
Proof. eexists; split; vm_compute; reflexivity. Qed.

Lemma find_funct_set_mario_action_airborne :
  exists b, Genv.find_symbol sma_ge mario._set_mario_action_airborne = Some b /\
            Genv.find_funct_ptr sma_ge b = Some (Internal mario.f_set_mario_action_airborne).
Proof. eexists; split; vm_compute; reflexivity. Qed.

Lemma find_funct_set_mario_action_submerged :
  exists b, Genv.find_symbol sma_ge mario._set_mario_action_submerged = Some b /\
            Genv.find_funct_ptr sma_ge b = Some (Internal mario.f_set_mario_action_submerged).
Proof. eexists; split; vm_compute; reflexivity. Qed.

Lemma find_funct_set_mario_action_cutscene :
  exists b, Genv.find_symbol sma_ge mario._set_mario_action_cutscene = Some b /\
            Genv.find_funct_ptr sma_ge b = Some (Internal mario.f_set_mario_action_cutscene).
Proof. eexists; split; vm_compute; reflexivity. Qed.
