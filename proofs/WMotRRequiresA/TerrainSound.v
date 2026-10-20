(* ====================================================================== *)
(* TerrainSound (unwired, GOAL 2): the value contract of the real          *)
(* mario_get_terrain_sound_addend, for the GOAL-2 executor                 *)
(* (SymExec2.xc_fresh: memory unchanged, some old result).                 *)
(*                                                                          *)
(* Its body has no locals, no stores and no calls (only temps, loads, ifs  *)
(* and a switch), so a call leaves memory IDENTICAL.  It returns a u32, so *)
(* the result is a Vint (an old value).  Nothing is assumed about the      *)
(* genv.                                                                   *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Memory Ctypes Cop Clight
  ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import WMotRRequiresA.FloorList.
Import ListNotations.

(* statements that cannot change memory: no stores, no calls, no builtins *)
Fixpoint nc_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue | Sreturn _ | Sset _ _ => true
  | Ssequence s1 s2 => nc_chk s1 && nc_chk s2
  | Sifthenelse _ s1 s2 => nc_chk s1 && nc_chk s2
  | Sloop s1 s2 => nc_chk s1 && nc_chk s2
  | Sswitch _ sl => nc_ls sl
  | _ => false
  end
with nc_ls (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => nc_chk s && nc_ls sl'
  end.

Lemma nc_seq : forall sl, nc_ls sl = true -> nc_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| c s sl IH]; intros H; [reflexivity |].
  cbn in H |- *. apply andb_prop in H as [H1 H2]. rewrite H1, (IH H2). reflexivity.
Qed.

Lemma nc_select : forall n sl, nc_ls sl = true -> nc_ls (select_switch n sl) = true.
Proof.
  intros n sl H. unfold select_switch.
  assert (D : forall sl, nc_ls sl = true -> nc_ls (select_switch_default sl) = true).
  { induction sl0 as [| [c|] s sl0 IH]; intros H0; cbn in *; auto.
    apply andb_prop in H0 as [_ H2]. exact (IH H2). }
  assert (C : forall sl sl', nc_ls sl = true -> select_switch_case n sl = Some sl' ->
                nc_ls sl' = true).
  { induction sl0 as [| [c|] s sl0 IH]; intros sl' H0 Hs; cbn in Hs; [discriminate | |].
    - destruct (zeq c n); [injection Hs as <-; exact H0 |].
      cbn in H0. apply andb_prop in H0 as [_ H2]. exact (IH sl' H2 Hs).
    - cbn in H0. apply andb_prop in H0 as [_ H2]. exact (IH sl' H2 Hs). }
  destruct (select_switch_case n sl) eqn:E; [exact (C sl l H E) | exact (D sl H)].
Qed.

Lemma nc_walk : forall (ge : genv) e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> nc_chk s = true -> m' = m.
Proof.
  intros ge e le m s t le' m' out Hexec.
  induction Hexec; intros Hchk; pose proof Hchk as Hc0; cbn [nc_chk] in Hchk;
    try reflexivity; try discriminate Hchk;
    repeat match goal with H : _ && _ = true |- _ => apply andb_prop in H as [? ?] end;
    try match goal with IH : nc_chk (if ?b then _ else _) = true -> _ |- _ => destruct b end;
    try match goal with IH : nc_chk (seq_of_labeled_statement (select_switch ?n ?sl)) = true -> _ |- _ =>
          specialize (IH (nc_seq _ (nc_select n sl Hchk))) end;
    repeat match goal with IH : nc_chk ?s = true -> _, H : nc_chk ?s = true |- _ =>
             specialize (IH H) end;
    subst; reflexivity.
Qed.

(* ---- the result is an int: every write of ret is an int shift ---- *)

Definition is_ity (t : type) : bool := match t with Tint _ _ _ => true | _ => false end.

Definition is_ishl (a : expr) : bool :=
  match a with Ebinop Oshl a1 a2 _ => is_ity (typeof a1) && is_ity (typeof a2) | _ => false end.

Fixpoint rt_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sset x a => if Pos.eqb x mario._ret then is_ishl a else true
  | Sreturn (Some (Etempvar x ty)) => Pos.eqb x mario._ret && (if type_eq ty (Tint I32 Signed noattr) then true else false)
  | Ssequence s1 s2 => rt_chk s1 && rt_chk s2
  | Sifthenelse _ s1 s2 => rt_chk s1 && rt_chk s2
  | Sloop s1 s2 => rt_chk s1 && rt_chk s2
  | Sswitch _ sl => rt_ls sl
  | _ => false
  end
with rt_ls (sl : labeled_statements) : bool :=
  match sl with
  | LSnil => true
  | LScons _ s sl' => rt_chk s && rt_ls sl'
  end.

Lemma rt_seq : forall sl, rt_ls sl = true -> rt_chk (seq_of_labeled_statement sl) = true.
Proof.
  induction sl as [| c s sl IH]; intros H; [reflexivity |].
  cbn in H |- *. apply andb_prop in H as [H1 H2]. rewrite H1, (IH H2). reflexivity.
Qed.

Lemma rt_select : forall n sl, rt_ls sl = true -> rt_ls (select_switch n sl) = true.
Proof.
  intros n sl H. unfold select_switch.
  assert (D : forall sl, rt_ls sl = true -> rt_ls (select_switch_default sl) = true).
  { induction sl0 as [| [c|] s sl0 IH]; intros H0; cbn in *; auto.
    apply andb_prop in H0 as [_ H2]. exact (IH H2). }
  assert (C : forall sl sl', rt_ls sl = true -> select_switch_case n sl = Some sl' ->
                rt_ls sl' = true).
  { induction sl0 as [| [c|] s sl0 IH]; intros sl' H0 Hs; cbn in Hs; [discriminate | |].
    - destruct (zeq c n); [injection Hs as <-; exact H0 |].
      cbn in H0. apply andb_prop in H0 as [_ H2]. exact (IH sl' H2 Hs).
    - cbn in H0. apply andb_prop in H0 as [_ H2]. exact (IH sl' H2 Hs). }
  destruct (select_switch_case n sl) eqn:E; [exact (C sl l H E) | exact (D sl H)].
Qed.

Lemma ishl_int : forall (ge : genv) e le m a v, is_ishl a = true ->
  eval_expr ge e le m a v -> exists i, v = Vint i.
Proof.
  intros ge e le m a v Ha Hev. destruct a; try discriminate Ha. destruct b; try discriminate Ha.
  cbn in Ha. apply andb_prop in Ha as [H1 H2].
  inv Hev; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
  match goal with Hs : sem_binary_operation _ _ _ _ _ _ _ = Some _ |- _ => rename Hs into Hsem end.
  destruct (typeof a1) as [| i1 s1 a1' | | | | | | |]; try discriminate H1.
  destruct (typeof a2) as [| i2 s2 a2' | | | | | | |]; try discriminate H2.
  cbn [sem_binary_operation] in Hsem. unfold sem_shl, sem_shift in Hsem.
  destruct (classify_shift (Tint i1 s1 a1') (Tint i2 s2 a2')) eqn:Ecl.
  - destruct v1, v2; try discriminate Hsem.
    destruct (Int.ltu _ _); inv Hsem; eauto.
  - destruct i1, s1, i2, s2; discriminate Ecl.
  - destruct i1, s1, i2, s2; discriminate Ecl.
  - destruct i1, s1, i2, s2; discriminate Ecl.
  - destruct i1, s1, i2, s2; discriminate Ecl.
Qed.

(* ret holds Vundef (before its first write) or an int *)
Definition uint (v : val) : Prop := v = Vundef \/ exists i, v = Vint i.
Definition Pret (le : temp_env) : Prop := exists v, le ! mario._ret = Some v /\ uint v.
Definition Qret (out : outcome) : Prop :=
  forall v ty, out = Out_return (Some (v, ty)) -> ty = Tint I32 Signed noattr /\ uint v.

Lemma rt_walk : forall (ge : genv) e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> rt_chk s = true -> Pret le ->
  Pret le' /\ Qret out.
Proof.
  intros ge e le m s t le' m' out Hexec.
  induction Hexec; intros Hchk HP; pose proof Hchk as Hc0; cbn [rt_chk] in Hchk;
    try discriminate Hchk;
    try (split; [exact HP | intros v0 ty0 Hq; discriminate Hq]).
  - (* Sset *)
    split; [| intros v0 ty0 Hq; discriminate Hq].
    destruct (Pos.eqb id mario._ret) eqn:Eid.
    + apply Pos.eqb_eq in Eid. subst id. destruct (ishl_int _ _ _ _ _ _ Hchk H) as (i & ->).
      exists (Vint i). split; [apply PTree.gss | right; eauto].
    + apply Pos.eqb_neq in Eid. destruct HP as (w & Hw & Uw). exists w. rewrite PTree.gso; auto.
  - (* Sseq, s1 normal *)
    apply andb_prop in Hchk as [H1 H2].
    destruct (IHHexec1 H1 HP) as (HP1 & _). exact (IHHexec2 H2 HP1).
  - (* Sseq, s1 abrupt *)
    apply andb_prop in Hchk as [H1 H2]. exact (IHHexec H1 HP).
  - (* Sifthenelse *)
    apply andb_prop in Hchk as [H1 H2]. apply IHHexec; [destruct b; assumption | exact HP].
  - (* Sreturn Some *)
    split; [exact HP |]. intros v0 ty0 Hq. injection Hq as <- <-.
    destruct a as [| | | | | i ty0 | | | | | | | |]; try discriminate Hchk. apply andb_prop in Hchk as [Hx Ht].
    apply Pos.eqb_eq in Hx. subst i. destruct (type_eq ty0 (Tint I32 Signed noattr)) as [-> |]; [| discriminate Ht].
    inv H; [| match goal with Hl : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv Hl end].
    destruct HP as (w & Hw & Uw). split; [reflexivity |].
    match goal with Ht : le ! mario._ret = Some _ |- _ => rewrite Hw in Ht; injection Ht as <- end. exact Uw.
  - (* Sloop stop1 *)
    apply andb_prop in Hchk as [H1 H2]. destruct (IHHexec H1 HP) as (HP1 & Q1).
    split; [exact HP1 |]. intros v0 ty0 Hq. subst out.
    inv H; try discriminate; exact (Q1 v0 ty0 eq_refl).
  - (* Sloop stop2 *)
    apply andb_prop in Hchk as [H1 H2]. destruct (IHHexec1 H1 HP) as (HP1 & _).
    destruct (IHHexec2 H2 HP1) as (HP2 & Q2).
    split; [exact HP2 |]. intros v0 ty0 Hq. subst out.
    inv H0; try discriminate; exact (Q2 v0 ty0 eq_refl).
  - (* Sloop loop *)
    apply andb_prop in Hchk as [H1 H2]. destruct (IHHexec1 H1 HP) as (HP1 & _).
    destruct (IHHexec2 H2 HP1) as (HP2 & _). exact (IHHexec3 Hc0 HP2).
  - (* Sswitch *)
    destruct (IHHexec (rt_seq _ (rt_select _ _ Hchk)) HP) as (HP1 & Q1).
    split; [exact HP1 |]. intros v0 ty0 Hq.
    destruct out; cbn in Hq; try discriminate Hq. exact (Q1 v0 ty0 Hq).
Qed.

Lemma terrain_sound_rt : rt_chk (fn_body mario.f_mario_get_terrain_sound_addend) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma terrain_sound_nc : nc_chk (fn_body mario.f_mario_get_terrain_sound_addend) = true.
Proof. vm_compute. reflexivity. Qed.

(* THE VALUE CONTRACT of mario_get_terrain_sound_addend (SymExec2.xc_fresh):
   memory unchanged, an int result.  Any genv. *)
Theorem terrain_sound_value_contract : forall (ge : genv) m vargs t m' vres,
    eval_funcall function_entry2 ge m
      (Internal mario.f_mario_get_terrain_sound_addend) vargs t m' vres ->
    m' = m /\ exists i, vres = Vint i.
Proof.
  intros ge m vargs t m' vres Hevf. inv Hevf.
  match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ => inv He end.
  match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
    cbn [mario.f_mario_get_terrain_sound_addend fn_vars] in Ha; inv Ha end.
  match goal with Hb : bind_parameter_temps _ _ _ = Some ?L |- _ =>
    assert (HP0 : Pret L) by
      (cbn [bind_parameter_temps create_undef_temps mario.f_mario_get_terrain_sound_addend
            fn_params fn_temps] in Hb;
       destruct vargs as [| v0 [|]]; try discriminate Hb; injection Hb as <-;
       exists Vundef; split; [ptg; reflexivity | left; reflexivity]) end.
  match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
    destruct (rt_walk _ _ _ _ _ _ _ _ _ Hx terrain_sound_rt HP0) as (_ & Q);
    pose proof (nc_walk _ _ _ _ _ _ _ _ _ Hx terrain_sound_nc) as -> end.
  match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
    rewrite (eq_refl : blocks_of_env ge empty_env = nil) in Hf;
    cbn [Mem.free_list] in Hf; injection Hf as <- end.
  split; [reflexivity |].
  match goal with Ho : outcome_result_value _ _ _ _ |- _ =>
    cbn [fn_return mario.f_mario_get_terrain_sound_addend] in Ho; rename Ho into Hout end.
  destruct out as [ | | | [[v' t']|]]; cbn in Hout; try contradiction.
  destruct (Q v' t' eq_refl) as (-> & [-> | (i & ->)]); destruct Hout as (_ & Hc);
    unfold sem_cast, classify_cast, Ctypesdefs.tuint in Hc; cbv [Archi.ptr64] in Hc; cbn in Hc;
    [discriminate Hc | injection Hc as <-; eauto].
Qed.
