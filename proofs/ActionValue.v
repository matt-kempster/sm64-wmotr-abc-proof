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

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory Globalenvs Ctypes Cop Clight ClightBigstep Clightdefs.
Import Clightdefs.ClightNotations.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying.
From SM64.Proofs Require Import ActionFrame.

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

(* ------------------------------------------------------------------ *)
(* Function-pointer evaluation bricks (reused inside each switch case). *)
(* ------------------------------------------------------------------ *)

(* find_funct on a zero-offset pointer is just find_funct_ptr. *)
Lemma find_funct_zero :
  forall (ge : genv) b f,
    Genv.find_funct_ptr ge b = Some f ->
    Genv.find_funct ge (Vptr b Ptrofs.zero) = Some f.
Proof.
  intros ge b f H. unfold Genv.find_funct.
  destruct (Ptrofs.eq_dec Ptrofs.zero Ptrofs.zero); congruence.
Qed.

(* Evaluating a GLOBAL function symbol `Evar id (Tfunction ..)` yields exactly
   its address Vptr b 0 (function type => By_reference deref). Inversion form:
   from any eval_expr of it we recover the address from find_symbol. *)
Lemma eval_Evar_funptr_inv :
  forall (ge : genv) (e : env) (le : temp_env) (m : mem) id tyargs tyres cc vf b,
    e ! id = None ->
    Genv.find_symbol ge id = Some b ->
    eval_expr ge e le m (Evar id (Tfunction tyargs tyres cc)) vf ->
    vf = Vptr b Ptrofs.zero.
Proof.
  intros ge e le m id tyargs tyres cc vf b He Hsym Hev.
  inv Hev.
  match goal with Hlv : eval_lvalue _ _ _ _ _ _ _ _ |- _ =>
    inv Hlv;
    [ match goal with Hloc : e ! id = Some _ |- _ => rewrite He in Hloc; discriminate end
    | match goal with Hfs : Genv.find_symbol _ id = Some ?l |- _ =>
        assert (l = b) by congruence; subst l end ]
  end;
  match goal with Hd : deref_loc _ _ _ _ _ _ |- _ =>
    inv Hd; simpl in *; try discriminate; reflexivity end.
Qed.

(* Evaluating the fixed argument list (m, action, actionArg) of every group
   call yields exactly [Vptr bm 0; Vint a; Vint arg] from the three temps. *)
Lemma eval_three_args :
  forall (ge : genv) (e : env) (le : temp_env) (m : mem) bm a arg vargs,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    le ! mario._action = Some (Vint a) ->
    le ! mario._actionArg = Some (Vint arg) ->
    eval_exprlist ge e le m
      ((Etempvar mario._m (tptr (Tstruct mario._MarioState noattr))) ::
       (Etempvar mario._action tuint) :: (Etempvar mario._actionArg tuint) :: nil)
      ((tptr (Tstruct mario._MarioState noattr)) :: tuint :: tuint :: nil)
      vargs ->
    vargs = (Vptr bm Ptrofs.zero :: Vint a :: Vint arg :: nil).
Proof.
  intros ge e le m bm a arg vargs Hm Ha Harg H.
  repeat (match goal with
          | He : eval_exprlist _ _ _ _ _ _ _ |- _ => inv He
          | He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
              inv He;
              try (match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
                     solve [ inv Hlv ] end)
          end).
  match goal with Ht : le ! mario._m = Some ?v1, Hc : sem_cast ?v1 _ _ _ = Some _ |- _ =>
    assert (v1 = Vptr bm Ptrofs.zero) by congruence; subst v1 end.
  match goal with Ht : le ! mario._action = Some ?v2, Hc : sem_cast ?v2 _ _ _ = Some _ |- _ =>
    assert (v2 = Vint a) by congruence; subst v2 end.
  match goal with Ht : le ! mario._actionArg = Some ?v3, Hc : sem_cast ?v3 _ _ _ = Some _ |- _ =>
    assert (v3 = Vint arg) by congruence; subst v3 end.
  repeat (match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ => vm_compute in Hc; inv Hc end).
  reflexivity.
Qed.

(* ------------------------------------------------------------------ *)
(* ONE SWITCH CASE of set_mario_action: call the group setter, store    *)
(* its result into the action temp, break. Given a non-flying action     *)
(* argument and the genv-resolved non-fabricating group setter, the      *)
(* case leaves _action holding a non-flying Vint and _m unchanged.       *)
(* ------------------------------------------------------------------ *)
Definition group_case_body (gsym tk : ident) : statement :=
  Ssequence
    (Ssequence
      (Scall (Some tk)
        (Evar gsym (Tfunction
           ((tptr (Tstruct mario._MarioState noattr)) :: tuint :: tuint :: nil)
           tuint cc_default))
        ((Etempvar mario._m (tptr (Tstruct mario._MarioState noattr))) ::
         (Etempvar mario._action tuint) :: (Etempvar mario._actionArg tuint) :: nil))
      (Sset mario._action (Etempvar tk tuint)))
    Sbreak.

Lemma exec_group_case :
  forall (ge : genv) (e : env) (le : temp_env) (m : mem)
         b gsym gf tk bm a arg t le' m' out,
    e ! gsym = None ->
    le ! mario._m         = Some (Vptr bm Ptrofs.zero) ->
    le ! mario._action    = Some (Vint a) ->
    le ! mario._actionArg = Some (Vint arg) ->
    tk <> mario._m ->
    Genv.find_symbol ge gsym = Some b ->
    Genv.find_funct_ptr ge b = Some (Internal gf) ->
    (forall mm bmm aa aarg tt mm' res,
        eval_funcall function_entry2 ge mm (Internal gf)
          (Vptr bmm Ptrofs.zero :: Vint aa :: Vint aarg :: nil) tt mm' res ->
        is_flying_int aa = false ->
        exists w, res = Vint w /\ is_flying_int w = false) ->
    is_flying_int a = false ->
    exec_stmt function_entry2 ge e le m (group_case_body gsym tk) t le' m' out ->
    out = Out_break /\
    le' ! mario._m = Some (Vptr bm Ptrofs.zero) /\
    (exists w, le' ! mario._action = Some (Vint w) /\ is_flying_int w = false).
Proof.
  intros ge e le m b gsym gf tk bm a arg t le' m' out
         Henv Hm Ha Harg Htk Hsym Hfun Hspec Hnf Hexec.
  unfold group_case_body in Hexec.
  (* outer Ssequence: (call;set) then break *)
  inv Hexec;
    [ | exfalso;
        match goal with
        | Hne : ?o1 <> Out_normal, Hab : exec_stmt _ _ _ _ _ _ _ _ _ ?o1 |- _ =>
            apply Hne; eapply (exec_exit_free_normal _ _ _ _ _ _ _ _ _ _ Hab);
            vm_compute; reflexivity end ].
  (* break: out = Out_break, le' = le1, m' = m1 *)
  match goal with Hbr : exec_stmt _ _ _ _ _ Sbreak _ _ _ _ |- _ => inv Hbr end.
  (* inner Ssequence: call then set *)
  match goal with Hcs : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ =>
    inv Hcs;
    [ | exfalso;
        match goal with
        | Hne : ?o1 <> Out_normal, Hab : exec_stmt _ _ _ _ _ _ _ _ _ ?o1 |- _ =>
            apply Hne; eapply (exec_exit_free_normal _ _ _ _ _ _ _ _ _ _ Hab);
            vm_compute; reflexivity end ] end.
  (* Scall *)
  match goal with Hcall : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv Hcall end.
  (* resolve the callee to Internal gf via the genv bricks *)
  match goal with
  | Hvf : eval_expr _ _ _ _ (Evar gsym _) ?vf, Hff : Genv.find_funct _ ?vf = Some _ |- _ =>
      pose proof (eval_Evar_funptr_inv _ _ _ _ _ _ _ _ _ _ Henv Hsym Hvf) as Hvfeq;
      rewrite Hvfeq in Hff; rewrite (find_funct_zero _ _ _ Hfun) in Hff; inv Hff
  end.
  (* pin the callee's argument types (classify_fun of the concrete Tfunction) *)
  match goal with Hcl : classify_fun _ = fun_case_f _ _ _ |- _ => cbn in Hcl; inv Hcl end.
  (* pin the argument list, then apply the non-fabrication spec to the result *)
  lazymatch goal with Hargs : eval_exprlist _ _ _ _ _ _ _ |- _ =>
    pose proof (eval_three_args _ _ _ _ _ _ _ _ Hm Ha Harg Hargs) as Hve end.
  match goal with Hfc : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
    rewrite Hve in Hfc;
    destruct (Hspec _ _ _ _ _ _ _ Hfc Hnf) as [w [Hvres Hwnf]] end.
  (* Sset _action (Etempvar tk): le1 = set _action vres (= Vint w) *)
  match goal with Hset : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hset end.
  match goal with He : eval_expr _ _ _ _ (Etempvar tk _) ?v |- _ =>
    inv He;
    try (match goal with Hlv : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hlv ] end) end.
  cbn [set_opttemp] in *.
  (* finish: out = Out_break, _m preserved, _action = Vint w non-flying *)
  split; [ reflexivity | split ].
  - (* le'!_m : through set _action then set tk *)
    rewrite PTree.gso by (vm_compute; discriminate).
    rewrite PTree.gso by (intro Hc; apply Htk; symmetry; exact Hc).
    exact Hm.
  - (* le'!_action = Some vres, and vres = Vint w *)
    match goal with Htk' : (PTree.set tk ?vr _) ! tk = Some ?vv |- _ =>
      rewrite PTree.gss in Htk' end.
    exists w. rewrite PTree.gss. split; [ congruence | exact Hwnf ].
Qed.

(* ================================================================== *)
(* STAGE 3: the full set_mario_action SWITCH.                          *)
(* `Sswitch (action & ACT_GROUP_MASK) { 64->moving; 128->airborne;     *)
(*  192->submerged; 256->cutscene }`. Each case is a group_case_body.   *)
(* The default (action's group bits not one of the four) leaves the     *)
(* action temp untouched. Either way, a non-flying action argument      *)
(* leaves _action non-flying after the switch.                          *)
(* ================================================================== *)
Definition sma_switch_scrut : expr :=
  Ebinop Oand (Etempvar mario._action tuint) (Econst_int (Int.repr 448) tint) tuint.

Definition sma_switch_cases : labeled_statements :=
  LScons (Some 64)  (group_case_body mario._set_mario_action_moving    mario._t'1)
 (LScons (Some 128) (group_case_body mario._set_mario_action_airborne  mario._t'2)
 (LScons (Some 192) (group_case_body mario._set_mario_action_submerged mario._t'3)
 (LScons (Some 256) (group_case_body mario._set_mario_action_cutscene  mario._t'4)
  LSnil))).

(* seq_of (select_switch c cases) for each matched label c: peels to the
   matched group_case_body followed by the rest (group_case_body stays folded). *)
Lemma sma_seq_64 :
  seq_of_labeled_statement (select_switch 64 sma_switch_cases)
  = Ssequence (group_case_body mario._set_mario_action_moving mario._t'1)
      (seq_of_labeled_statement
        (LScons (Some 128) (group_case_body mario._set_mario_action_airborne mario._t'2)
        (LScons (Some 192) (group_case_body mario._set_mario_action_submerged mario._t'3)
        (LScons (Some 256) (group_case_body mario._set_mario_action_cutscene mario._t'4) LSnil)))).
Proof. reflexivity. Qed.

Lemma sma_seq_128 :
  seq_of_labeled_statement (select_switch 128 sma_switch_cases)
  = Ssequence (group_case_body mario._set_mario_action_airborne mario._t'2)
      (seq_of_labeled_statement
        (LScons (Some 192) (group_case_body mario._set_mario_action_submerged mario._t'3)
        (LScons (Some 256) (group_case_body mario._set_mario_action_cutscene mario._t'4) LSnil))).
Proof. reflexivity. Qed.

Lemma sma_seq_192 :
  seq_of_labeled_statement (select_switch 192 sma_switch_cases)
  = Ssequence (group_case_body mario._set_mario_action_submerged mario._t'3)
      (seq_of_labeled_statement
        (LScons (Some 256) (group_case_body mario._set_mario_action_cutscene mario._t'4) LSnil)).
Proof. reflexivity. Qed.

Lemma sma_seq_256 :
  seq_of_labeled_statement (select_switch 256 sma_switch_cases)
  = Ssequence (group_case_body mario._set_mario_action_cutscene mario._t'4)
      (seq_of_labeled_statement LSnil).
Proof. reflexivity. Qed.

(* No label matches => the default (empty) branch. *)
Lemma sma_select_switch_default :
  forall n, n <> 64 -> n <> 128 -> n <> 192 -> n <> 256 ->
    select_switch n sma_switch_cases = LSnil.
Proof.
  intros n H1 H2 H3 H4.
  assert (Hc : select_switch_case n sma_switch_cases = None).
  { unfold sma_switch_cases; cbn [select_switch_case].
    destruct (zeq 64 n);  [ congruence | ].
    destruct (zeq 128 n); [ congruence | ].
    destruct (zeq 192 n); [ congruence | ].
    destruct (zeq 256 n); [ congruence | reflexivity ]. }
  unfold select_switch. rewrite Hc. reflexivity.
Qed.

(* A selected sequence that STARTS with a group_case_body: the group body
   breaks, so the trailing cases are skipped, and the result is the group
   body's (non-flying action, preserved _m). *)
Lemma exec_selected_case :
  forall (e : env) (le : temp_env) m b gsym gf tk bm a arg rest t le' m' out,
    e ! gsym = None ->
    le ! mario._m         = Some (Vptr bm Ptrofs.zero) ->
    le ! mario._action    = Some (Vint a) ->
    le ! mario._actionArg = Some (Vint arg) ->
    tk <> mario._m ->
    Genv.find_symbol sma_ge gsym = Some b ->
    Genv.find_funct_ptr sma_ge b = Some (Internal gf) ->
    (forall mm bmm aa aarg tt mm' res,
        eval_funcall function_entry2 sma_ge mm (Internal gf)
          (Vptr bmm Ptrofs.zero :: Vint aa :: Vint aarg :: nil) tt mm' res ->
        is_flying_int aa = false ->
        exists w, res = Vint w /\ is_flying_int w = false) ->
    is_flying_int a = false ->
    exec_stmt function_entry2 sma_ge e le m
      (Ssequence (group_case_body gsym tk) rest) t le' m' out ->
    out = Out_break /\
    le' ! mario._m = Some (Vptr bm Ptrofs.zero) /\
    (exists w, le' ! mario._action = Some (Vint w) /\ is_flying_int w = false).
Proof.
  intros e le m b gsym gf tk bm a arg rest t le' m' out
         Henv Hm Ha Harg Htk Hsym Hfun Hspec Hnf Hexec.
  inv Hexec.
  - (* Sseq_1: group body Out_normal -- impossible, it breaks *)
    match goal with Hg : exec_stmt _ _ _ _ _ (group_case_body _ _) _ _ _ Out_normal |- _ =>
      pose proof (exec_group_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                    Henv Hm Ha Harg Htk Hsym Hfun Hspec Hnf Hg) as HG;
      destruct HG as [Hb _]; discriminate end.
  - (* Sseq_2: group body's outcome (Out_break) is the whole result *)
    match goal with Hg : exec_stmt _ _ _ _ _ (group_case_body _ _) _ _ _ _ |- _ =>
      pose proof (exec_group_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                    Henv Hm Ha Harg Htk Hsym Hfun Hspec Hnf Hg) as HG end.
  exact HG.
Qed.

Lemma exec_sma_switch :
  forall (e : env) (le : temp_env) m a arg bm t le' m' out,
    e ! mario._set_mario_action_moving    = None ->
    e ! mario._set_mario_action_airborne  = None ->
    e ! mario._set_mario_action_submerged = None ->
    e ! mario._set_mario_action_cutscene  = None ->
    le ! mario._m         = Some (Vptr bm Ptrofs.zero) ->
    le ! mario._action    = Some (Vint a) ->
    le ! mario._actionArg = Some (Vint arg) ->
    is_flying_int a = false ->
    exec_stmt function_entry2 sma_ge e le m (Sswitch sma_switch_scrut sma_switch_cases)
      t le' m' out ->
    out = Out_normal /\
    le' ! mario._m = Some (Vptr bm Ptrofs.zero) /\
    (exists w, le' ! mario._action = Some (Vint w) /\ is_flying_int w = false).
Proof.
  intros e le m a arg bm t le' m' out Hmv Hai Hsu Hcu Hm Ha Harg Hnf Hexec.
  inv Hexec.
  (* Hbody : exec of seq_of (select_switch n sma_switch_cases); goal out0 = outcome_switch _ *)
  match goal with Hbody : exec_stmt _ _ _ _ _
      (seq_of_labeled_statement (select_switch ?n sma_switch_cases)) _ _ _ _ |- _ =>
    rename Hbody into Hb; set (nn := n) in * end.
  destruct (zeq nn 64) as [E|N64];
  [ | destruct (zeq nn 128) as [E|N128];
  [ | destruct (zeq nn 192) as [E|N192];
  [ | destruct (zeq nn 256) as [E|N256] ]]].
  - (* moving *)
    rewrite E, sma_seq_64 in Hb.
    destruct find_funct_set_mario_action_moving as [bb [Hs Hf]].
    pose proof (exec_selected_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                  Hmv Hm Ha Harg (ltac:(vm_compute; discriminate) : mario._t'1 <> mario._m) Hs Hf
                  (set_mario_action_moving_result sma_ge) Hnf Hb) as HG.
    destruct HG as [Hout [Hmm Hact]]. rewrite Hout; cbn [outcome_switch].
    split; [ reflexivity | split; [ exact Hmm | exact Hact ] ].
  - (* airborne *)
    rewrite E, sma_seq_128 in Hb.
    destruct find_funct_set_mario_action_airborne as [bb [Hs Hf]].
    pose proof (exec_selected_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                  Hai Hm Ha Harg (ltac:(vm_compute; discriminate) : mario._t'2 <> mario._m) Hs Hf
                  (set_mario_action_airborne_result sma_ge) Hnf Hb) as HG.
    destruct HG as [Hout [Hmm Hact]]. rewrite Hout; cbn [outcome_switch].
    split; [ reflexivity | split; [ exact Hmm | exact Hact ] ].
  - (* submerged *)
    rewrite E, sma_seq_192 in Hb.
    destruct find_funct_set_mario_action_submerged as [bb [Hs Hf]].
    pose proof (exec_selected_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                  Hsu Hm Ha Harg (ltac:(vm_compute; discriminate) : mario._t'3 <> mario._m) Hs Hf
                  (set_mario_action_submerged_result sma_ge) Hnf Hb) as HG.
    destruct HG as [Hout [Hmm Hact]]. rewrite Hout; cbn [outcome_switch].
    split; [ reflexivity | split; [ exact Hmm | exact Hact ] ].
  - (* cutscene *)
    rewrite E, sma_seq_256 in Hb.
    destruct find_funct_set_mario_action_cutscene as [bb [Hs Hf]].
    pose proof (exec_selected_case _ _ _ _ _ _ _ _ _ _ _ _ _ _ _
                  Hcu Hm Ha Harg (ltac:(vm_compute; discriminate) : mario._t'4 <> mario._m) Hs Hf
                  (set_mario_action_cutscene_result sma_ge) Hnf Hb) as HG.
    destruct HG as [Hout [Hmm Hact]]. rewrite Hout; cbn [outcome_switch].
    split; [ reflexivity | split; [ exact Hmm | exact Hact ] ].
  - (* default: no case matched, action temp untouched *)
    rewrite (sma_select_switch_default nn N64 N128 N192 N256) in Hb.
    cbn [seq_of_labeled_statement] in Hb. inv Hb. cbn [outcome_switch].
    split; [ reflexivity | split; [ exact Hm | exists a; split; [ exact Ha | exact Hnf ] ] ].
Qed.

(* ================================================================== *)
(* STAGE 4: the REST of set_mario_action (everything after the switch). *)
(* It reads/writes several MarioState fields and ends in `return 1`.    *)
(* The ONE write to the action field (offset 12) is `m->action =        *)
(* _action`; all other field writes are at disjoint offsets. So after    *)
(* REST, m->action holds the (non-flying) value of the _action temp.     *)
(* ================================================================== *)

(* The Clight genv's composite env for mario.prog IS mario_ce (both are    *)
(* prog_comp_env mario.prog), by a lazy record projection -- cheap.         *)
Lemma genv_cenv_sma : genv_cenv sma_ge = mario_ce.
Proof. unfold sma_ge, mario_ce, globalenv. cbn [genv_cenv]. reflexivity. Qed.

(* Bridge: a Clight `Sassign` through the canonical `m->field` lvalue     *)
(* (Efield (Ederef (Etempvar _m) MarioState) f) reduces to a concrete     *)
(* assign_loc at byte (bm, delta) of the real MarioState composite,       *)
(* leaving the temps untouched. delta/bf come from the field table.       *)
Lemma exec_mario_field_store :
  forall (e : env) le m bm fid fty rhs t le' m' out,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    exec_stmt function_entry2 sma_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    exists delta bf v2 v,
      field_offset mario_ce fid mario_members = OK (delta, bf) /\
      eval_expr sma_ge e le m rhs v2 /\
      sem_cast v2 (typeof rhs) fty m = Some v /\
      assign_loc mario_ce fty m bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)) bf v m'.
Proof.
  intros e le m bm fid fty rhs t le' m' out Hm Hexec.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  (* struct field: the inner Ederef is read as an rvalue (By_copy) *)
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar mario._m _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  (* pin the inner _m pointer to (bm, 0): use the inversion hyp (its offset is
     a variable ofs), NOT the precondition Hm (offset literally Ptrofs.zero) *)
  match goal with
  | Hlk : ?T ! mario._m = Some (Vptr ?l ?o) |- _ =>
      first [ constr_eq o Ptrofs.zero; fail 1
            | first [ constr_eq l bm | assert (l = bm) by congruence; subst l ];
              assert (o = Ptrofs.zero) by congruence; subst o ]
  end.
  (* the struct base is read By_copy. Reduce typeof IN the deref_loc hyp first,
     so after inv the spurious By_value/By_reference branches carry an
     `access_mode (Tstruct _ _) = ...` hyp that discriminate can kill. *)
  match goal with Hdl : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hdl; inv Hdl end;
    try (match goal with Hac : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate end);
    try (match goal with Hac : access_mode (Tstruct _ _) = By_reference |- _ => discriminate end).
  (* reduce `typeof` ONLY in the hyps that mention it -- a blanket `cbn ... in *`
     HANGS here because the context holds genv terms (sma_ge = globalenv ...). *)
  repeat match goal with
  | H : context[typeof (Efield _ _ _)] |- _ => cbn [typeof] in H
  | H : context[typeof (Ederef _ _)]   |- _ => cbn [typeof] in H
  end.
  (* pin the composite name id := _MarioState from `typeof a = Tstruct id att` *)
  match goal with Hty : Tstruct _ _ = Tstruct _ _ |- _ => inv Hty end.
  rewrite genv_cenv_sma in *.
  split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with
  | Hco : mario_ce ! mario._MarioState = Some ?co,
    Hfo : field_offset mario_ce fid (co_members ?co) = OK (?delta, ?bf),
    Hev : eval_expr _ _ _ _ rhs ?v2,
    Hcast : sem_cast ?v2 _ _ _ = Some ?v,
    Hass : assign_loc mario_ce fty m _ _ _ ?v _ |- _ =>
      assert (Hmem : co_members co = mario_members) by
        (unfold mario_members; rewrite Hco; reflexivity);
      rewrite Hmem in Hfo;
      exists delta, bf, v2, v;
      split; [ exact Hfo | split; [ exact Hev | split; [ exact Hcast | exact Hass ] ] ]
  end.
Qed.

(* The action write `m->action = _action`: stores the (non-flying) temp value
   into the action field, so the field reads back exactly Vint w. *)
Lemma exec_action_field_write :
  forall (e : env) le m bm w t le' m' out,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    le ! mario._action = Some (Vint w) ->
    exec_stmt function_entry2 sma_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) mario._action tuint)
               (Etempvar mario._action tuint)) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.load Mint32 m' bm 12 = Some (Vint w).
Proof.
  intros e le m bm w t le' m' out Hm Hact Hexec.
  apply exec_mario_field_store in Hexec; [ | exact Hm ].
  destruct Hexec as [Hle [Hout [delta [bf [v2 [v [Hfo [Hev [Hcast Hass]]]]]]]]].
  vm_compute in Hfo; inv Hfo.            (* delta = 12, bf = Full *)
  inv Hev;
    try (match goal with Hl : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => solve [ inv Hl ] end).
  (* le!_action = Some v2 = Vint w *)
  match goal with Hk : _ ! mario._action = Some ?vv |- _ =>
    assert (vv = Vint w) by congruence; subst vv end.
  vm_compute in Hcast; inv Hcast.        (* v = Vint w *)
  split; [ exact Hle | split; [ exact Hout | ] ].
  erewrite assign_loc_scalar_load_same;
    [ | match goal with Ha : assign_loc _ _ _ _ _ _ _ _ |- _ => exact Ha end ].
  reflexivity.
Qed.

(* Any OTHER scalar field write `m->f = rhs` (f <> action) leaves the action
   field unchanged. Offsets/types/access discharged by vm_compute at call sites. *)
Lemma exec_other_field_write :
  forall (e : env) le m bm fid fty rhs t le' m' out delta chunk,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    fid <> mario._action ->
    field_offset mario_ce fid mario_members = OK (delta, Full) ->
    field_type fid mario_members = OK fty ->
    access_mode fty = By_value chunk ->
    Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)) = 0 + delta ->
    exec_stmt function_entry2 sma_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\ Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12.
Proof.
  intros e le m bm fid fty rhs t le' m' out delta chunk
         Hm Hne Hfo Hft Ham Hov Hexec.
  apply exec_mario_field_store in Hexec; [ | exact Hm ].
  destruct Hexec as [Hle [Hout [delta' [bf' [v2 [v [Hfo' [Hev [Hcast Hass]]]]]]]]].
  rewrite Hfo in Hfo'; inv Hfo'.         (* delta' = delta, bf' = Full *)
  split; [ exact Hle | split; [ exact Hout | ] ].
  pose proof (assign_loc_other_field_preserves_action_loadv
                m bm Ptrofs.zero fid delta fty chunk v m'
                Hfo Hft Ham Hne Hov ltac:(vm_compute; reflexivity) Hass) as Hpres.
  unfold Mem.loadv in Hpres.
  replace (Ptrofs.unsigned (Ptrofs.add Ptrofs.zero (Ptrofs.repr 12))) with 12 in Hpres
    by (vm_compute; reflexivity).
  exact Hpres.
Qed.
