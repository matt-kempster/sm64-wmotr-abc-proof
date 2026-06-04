(* ====================================================================== *)
(* CensusV2 -- the PER-BODY census + temp-table for the engine-v2 lp       *)
(* discharge (ActionValueFrame.exec_funcall_reach_value_v2).               *)
(*                                                                         *)
(* The engine's TI and C are indexed by an opaque per-body census index:   *)
(* here the index is `body_census`, a record naming the body's Mario       *)
(* param and ITS OWN gate/dispatch temps. clightgen reuses temp idents      *)
(* (_t'N is the same positive in every body), so the tables MUST be        *)
(* per-body -- a global table would collide.                               *)
(*                                                                         *)
(* TI_of: the temp-table invariant. Three families of facts:               *)
(*  - the Mario param holds EXACTLY (bm,0) (established at entry from the   *)
(*    exact marg_ok; preserved because the census forbids Sset to it);      *)
(*  - an input-A-gate temp's Vint value has bit 1 clear (established at     *)
(*    its defining Sset from input_a_clear; the census forces every Sset    *)
(*    to a tabled gate temp to be the canonical m->input load);             *)
(*  - a dispatch temp's Vint value satisfies Q (= not_tainted at the        *)
(*    consumer; established from action_sat at the m->action load).         *)
(*                                                                         *)
(* chk: the boolean per-statement census (reflexivity-checkable per body).  *)
(*  - the if rule EXEMPTS the THEN branch of a censused input A-gate        *)
(*    (engine HCif + the gate temp's TI fact kill it semantically);          *)
(*  - the switch rule on a censused dispatch temp only requires the         *)
(*    NON-T-labeled suffixes (engine HCsw + action_sat kill the T arms);     *)
(*    ordinary switches require EVERY suffix (chk_all_ls);                   *)
(*  - the Ssequence rule is break-aware: the tail census may be waived      *)
(*    when the head provably never completes normally (dispatch arms end    *)
(*    in break; the textually-following dead arms never run);               *)
(*  - Sassign / Scall / Sbuiltin are STRICT placeholders (false) in this    *)
(*    first cut: only store-free, call-free fragments pass. Widening these   *)
(*    rules (store classes + call classes) is the next brick; keeping them   *)
(*    false is sound -- bodies simply do not pass census yet.               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.

Import ListNotations.
Local Open Scope Z_scope.

(* ====================================================================== *)
(* The per-body census record.                                             *)
(* ====================================================================== *)

Record body_census : Type := {
  bc_mptr  : ident;        (* the body's MarioState* parameter *)
  bc_gates : list ident;   (* THIS body's input-A-gate temps *)
  bc_disp  : list ident    (* THIS body's action-dispatch temps *)
}.

Definition mem_id (t : ident) (l : list ident) : bool :=
  existsb (Pos.eqb t) l.

(* ====================================================================== *)
(* The temp-table invariant.                                               *)
(* ====================================================================== *)

Definition TI_of (Q : int -> Prop) (bm : block) (bc : body_census)
    (le : temp_env) : Prop :=
  (forall v, le ! (bc_mptr bc) = Some v -> v = Vptr bm Ptrofs.zero) /\
  (forall t, mem_id t (bc_gates bc) = true ->
     forall vi, le ! t = Some (Vint vi) ->
       Int.and vi (Int.repr 2) = Int.zero) /\
  (forall t, mem_id t (bc_disp bc) = true ->
     forall vi, le ! t = Some (Vint vi) -> Q vi).

(* ====================================================================== *)
(* Shape detectors -- EXACT (type_eq-pinned) so the AGates eval bricks      *)
(* apply syntactically. The canonical clightgen shapes:                     *)
(*   input load:  (Efield (Ederef (Etempvar m (tptr MarioState)) MarioState) *)
(*                 _input tushort)                                           *)
(*   action load: ... _action tuint                                          *)
(*   gate guard:  (Ebinop Oand (Etempvar t tushort) (Econst_int 2 tint) tint)*)
(* ====================================================================== *)

Definition tyMS : type := Tstruct mario._MarioState noattr.

Definition is_input_load_x (mptr : ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mptr && Pos.eqb fld mario._input
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq fty tushort)
  | _ => false
  end.

Definition is_action_load_x (mptr : ident) (a : expr) : bool :=
  match a with
  | Efield (Ederef (Etempvar p pty) sty) fld fty =>
      Pos.eqb p mptr && Pos.eqb fld mario._action
      && proj_sumbool (type_eq pty (tptr tyMS))
      && proj_sumbool (type_eq sty tyMS)
      && proj_sumbool (type_eq fty tuint)
  | _ => false
  end.

Lemma is_input_load_x_shape :
  forall mptr a, is_input_load_x mptr a = true ->
    a = Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) mario._input tushort.
Proof.
  intros mptr a H. destruct a; try discriminate H.
  destruct a; try discriminate H.
  destruct a; try discriminate H.
  unfold is_input_load_x in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. reflexivity.
Qed.

Lemma is_action_load_x_shape :
  forall mptr a, is_action_load_x mptr a = true ->
    a = Efield (Ederef (Etempvar mptr (tptr tyMS)) tyMS) mario._action tuint.
Proof.
  intros mptr a H. destruct a; try discriminate H.
  destruct a; try discriminate H.
  destruct a; try discriminate H.
  unfold is_action_load_x in H.
  repeat (apply andb_true_iff in H; destruct H as [H ?]).
  repeat match goal with
         | Hp : Pos.eqb _ _ = true |- _ => apply Pos.eqb_eq in Hp
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  subst. reflexivity.
Qed.

(* the input-A-gate guard, returning the gate temp on an exact match. *)
Definition input_guard_temp (a : expr) : option ident :=
  match a with
  | Ebinop Oand (Etempvar t ty1) (Econst_int c ty2) ty3 =>
      if Int.eq c (Int.repr 2)
         && proj_sumbool (type_eq ty1 tushort)
         && proj_sumbool (type_eq ty2 tint)
         && proj_sumbool (type_eq ty3 tint)
      then Some t else None
  | _ => None
  end.

Lemma input_guard_temp_shape :
  forall a t, input_guard_temp a = Some t ->
    a = Ebinop Oand (Etempvar t tushort)
          (Econst_int (Int.repr 2) tint) tint.
Proof.
  intros a t H. destruct a; try discriminate H.
  destruct b; try discriminate H.
  destruct a1; try discriminate H.
  destruct a2; try discriminate H.
  unfold input_guard_temp in H.
  match type of H with (if ?cond then _ else _) = _ =>
    destruct cond eqn:Hc; [ | discriminate H ] end.
  inv H.
  repeat (apply andb_true_iff in Hc; destruct Hc as [Hc ?]).
  repeat match goal with
         | Hp : proj_sumbool _ = true |- _ => apply proj_sumbool_true in Hp
         end.
  apply Int.same_if_eq in Hc. subst. reflexivity.
Qed.

(* the dispatch scrutinee, returning the dispatch temp on an exact match. *)
Definition disp_scrut_temp (a : expr) : option ident :=
  match a with
  | Etempvar t ty =>
      if proj_sumbool (type_eq ty tuint) then Some t else None
  | _ => None
  end.

Lemma disp_scrut_temp_shape :
  forall a t, disp_scrut_temp a = Some t -> a = Etempvar t tuint.
Proof.
  intros a t H. destruct a; try discriminate H. unfold disp_scrut_temp in H.
  match type of H with (if ?cond then _ else _) = _ =>
    destruct cond eqn:Hc; [ | discriminate H ] end.
  inv H.
  apply proj_sumbool_true in Hc. subst. reflexivity.
Qed.

Definition gate_if (bc : body_census) (g : expr) : bool :=
  match input_guard_temp g with
  | Some t => mem_id t (bc_gates bc)
  | None => false
  end.

Definition disp_switch (bc : body_census) (a : expr) : bool :=
  match disp_scrut_temp a with
  | Some t => mem_id t (bc_disp bc)
  | None => false
  end.

(* ====================================================================== *)
(* The census.                                                             *)
(*                                                                         *)
(* chk_ls    : the SELECTED-SUFFIX check -- mirrors chk over the            *)
(*             seq_of_labeled_statement concatenation (break-aware).        *)
(* chk_all_ls: the ordinary-switch census -- EVERY suffix is selectable,    *)
(*             so every suffix must pass chk_ls's head conjunct.            *)
(* chk_disp_ls: the dispatch census -- T-labeled suffixes are exempt        *)
(*             (action_sat not_tainted makes them unselectable).            *)
(* ====================================================================== *)

Fixpoint chk (bc : body_census) (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn None => true
  | Sreturn (Some _) => true
  | Sset id a =>
      negb (Pos.eqb id (bc_mptr bc))
      && (negb (mem_id id (bc_gates bc)) || is_input_load_x (bc_mptr bc) a)
      && (negb (mem_id id (bc_disp bc)) || is_action_load_x (bc_mptr bc) a)
  | Ssequence s1 s2 =>
      chk bc s1 && (chk bc s2 || ends_in_break s1)
  | Sifthenelse g s1 s2 =>
      if gate_if bc g then chk bc s2 else chk bc s1 && chk bc s2
  | Sloop s1 s2 => chk bc s1 && chk bc s2
  | Slabel _ s1 => chk bc s1
  | Sswitch a ls =>
      if disp_switch bc a then chk_disp_ls bc ls else chk_all_ls bc ls
  | Sassign _ _ => false       (* first cut: store classes are the next brick *)
  | Scall _ _ _ => false       (* first cut: call classes are the next brick *)
  | Sbuiltin _ _ _ _ => false
  | Sgoto _ => false
  end
with chk_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest => chk bc s && (chk_ls bc rest || ends_in_break s)
  end
with chk_all_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons _ s rest =>
      (chk bc s && (chk_ls bc rest || ends_in_break s))
      && chk_all_ls bc rest
  end
with chk_disp_ls (bc : body_census) (ls : labeled_statements) : bool :=
  match ls with
  | LSnil => true
  | LScons o s rest =>
      (match o with
       | Some c => if is_T_label c then true
                   else chk bc s && (chk_ls bc rest || ends_in_break s)
       | None => chk bc s && (chk_ls bc rest || ends_in_break s)
       end)
      && chk_disp_ls bc rest
  end.

(* chk over the seq_of concatenation IS chk_ls (definitional mirror). *)
Lemma chk_seq_of :
  forall bc ls, chk_ls bc ls = true ->
    chk bc (seq_of_labeled_statement ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros H.
  - reflexivity.
  - apply andb_true_iff in H as [Hs Hrest].
    apply andb_true_iff; split; [ exact Hs | ].
    apply orb_true_iff in Hrest as [Hr | Hb].
    + apply orb_true_iff; left. exact (IH Hr).
    + apply orb_true_iff; right. exact Hb.
Qed.

(* ---- ordinary switches: any selection is censused. ---- *)
Lemma chk_all_select_case :
  forall bc n ls res,
    chk_all_ls bc ls = true ->
    select_switch_case n ls = Some res ->
    chk_ls bc res = true.
Proof.
  intros bc n ls; induction ls as [| o s rest IH]; cbn; intros res Hd Hsel.
  - discriminate Hsel.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + destruct (zeq c n) as [E|NE].
      * inv Hsel. cbn. exact Hhead.
      * exact (IH res Hrest Hsel).
    + exact (IH res Hrest Hsel).
Qed.

Lemma chk_all_select_default :
  forall bc ls,
    chk_all_ls bc ls = true ->
    chk_ls bc (select_switch_default ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros Hd.
  - reflexivity.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + exact (IH Hrest).
    + cbn. exact Hhead.
Qed.

Lemma chk_all_select :
  forall bc n ls,
    chk_all_ls bc ls = true ->
    chk_ls bc (select_switch n ls) = true.
Proof.
  intros bc n ls Hd. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - exact (chk_all_select_case bc n ls l Hd E).
  - exact (chk_all_select_default bc ls Hd).
Qed.

(* ---- the dispatch: a non-T selection is censused. ---- *)
Lemma chk_disp_select_case :
  forall bc n ls res,
    chk_disp_ls bc ls = true ->
    is_T_label n = false ->
    select_switch_case n ls = Some res ->
    chk_ls bc res = true.
Proof.
  intros bc n ls; induction ls as [| o s rest IH]; cbn; intros res Hd Hn Hsel.
  - discriminate Hsel.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + destruct (zeq c n) as [E|NE].
      * inv Hsel. rewrite Hn in Hhead. cbn. exact Hhead.
      * exact (IH res Hrest Hn Hsel).
    + exact (IH res Hrest Hn Hsel).
Qed.

Lemma chk_disp_select_default :
  forall bc ls,
    chk_disp_ls bc ls = true ->
    chk_ls bc (select_switch_default ls) = true.
Proof.
  intros bc ls; induction ls as [| o s rest IH]; cbn; intros Hd.
  - reflexivity.
  - apply andb_true_iff in Hd as [Hhead Hrest].
    destruct o as [c|].
    + exact (IH Hrest).
    + cbn. exact Hhead.
Qed.

Lemma chk_disp_select :
  forall bc n ls,
    chk_disp_ls bc ls = true ->
    is_T_label n = false ->
    chk_ls bc (select_switch n ls) = true.
Proof.
  intros bc n ls Hd Hn. unfold select_switch.
  destruct (select_switch_case n ls) eqn:E.
  - exact (chk_disp_select_case bc n ls l Hd Hn E).
  - exact (chk_disp_select_default bc ls Hd).
Qed.

(* ====================================================================== *)
(* The engine-leaf discharges, over the abstract linked program.           *)
(* ====================================================================== *)

(* ---- HCseq1 / HCloop: pure projections. ---- *)
Lemma chk_seq1 :
  forall bc s1 s2, chk bc (Ssequence s1 s2) = true -> chk bc s1 = true.
Proof.
  intros bc s1 s2 H. cbn in H.
  apply andb_true_iff in H as [H1 _]. exact H1.
Qed.

Lemma chk_loop :
  forall bc s1 s2, chk bc (Sloop s1 s2) = true ->
    chk bc s1 = true /\ chk bc s2 = true.
Proof.
  intros bc s1 s2 H. cbn in H. apply andb_true_iff in H. exact H.
Qed.

Section CensusLeavesLp.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* ---- HCseq2: the tail census, given the head actually completed
     Out_normal -- a break-ended head refutes the premise. ---- *)
  Lemma chk_seq2 :
    forall bc e le m s1 s2 t1 le1 m1,
      chk bc (Ssequence s1 s2) = true ->
      exec_stmt function_entry2 (lp_ge lp) e le m s1 t1 le1 m1 Out_normal ->
      chk bc s2 = true.
  Proof.
    intros bc e le m s1 s2 t1 le1 m1 H Hexec. cbn in H.
    apply andb_true_iff in H as [_ H2].
    apply orb_true_iff in H2 as [H2 | Hb]; [ exact H2 | ].
    exfalso.
    exact (ends_in_break_not_normal lp _ _ _ _ _ _ _ _ Hb Hexec eq_refl).
  Qed.

  (* ---- HCif: the gate kill. At a censused input A-gate the guard
     provably evaluates to false (the gate temp's TI fact + the bit
     arithmetic), so only the ELSE census -- which is what chk carries --
     is ever demanded. Non-gate ifs carry both branches. ---- *)
  Lemma chk_if :
    forall Q bm bc e le m a s1 s2 v1 b,
      chk bc (Sifthenelse a s1 s2) = true ->
      TI_of Q bm bc le ->
      eval_expr (lp_ge lp) e le m a v1 ->
      bool_val v1 (typeof a) m = Some b ->
      chk bc (if b then s1 else s2) = true.
  Proof.
    intros Q bm bc e le m a s1 s2 v1 b HC HTI Hev Hbv.
    change ((if gate_if bc a then chk bc s2 else chk bc s1 && chk bc s2)
            = true) in HC.
    (* destruct abstracts + reduces the occurrence in HC too *)
    destruct (gate_if bc a) eqn:Hg.
    - (* censused gate: THEN is dead.  HC : chk bc s2 = true *)
      unfold gate_if in Hg.
      destruct (input_guard_temp a) as [t|] eqn:Hgt; [ | discriminate Hg ].
      pose proof (input_guard_temp_shape _ _ Hgt) as Hshape. subst a.
      destruct (guard_temp_vint lp _ _ _ _ _ _ Hev) as (vi & Hlet & Hv1).
      destruct HTI as (_ & Hgate & _).
      pose proof (Hgate t Hg vi Hlet) as Hclear.
      subst v1. cbn [typeof] in Hbv.
      pose proof (bool_val_and_zero _ _ _ _ Hclear Hbv) as Hb. subst b.
      exact HC.
    - (* ordinary if: both branches censused *)
      apply andb_true_iff in HC as [H1 H2]. destruct b; assumption.
  Qed.

  (* ---- HCsw: the dispatch kill. On a censused dispatch switch the
     scrutinee temp's TI fact (Q = not_tainted) means the selector never
     matches a T label, and the selected suffix is chk_disp_ls censused.
     Ordinary switches carry every suffix (chk_all_ls). ---- *)
  Lemma chk_sw :
    forall bm bc e le m a ls v n,
      chk bc (Sswitch a ls) = true ->
      TI_of not_tainted bm bc le ->
      eval_expr (lp_ge lp) e le m a v ->
      sem_switch_arg v (typeof a) = Some n ->
      chk bc (seq_of_labeled_statement (select_switch n ls)) = true.
  Proof.
    intros bm bc e le m a ls v n HC HTI Hev Hsa.
    change ((if disp_switch bc a then chk_disp_ls bc ls else chk_all_ls bc ls)
            = true) in HC.
    (* destruct abstracts + reduces the occurrence in HC too *)
    destruct (disp_switch bc a) eqn:Hd.
    - (* censused dispatch.  HC : chk_disp_ls bc ls = true *)
      unfold disp_switch in Hd.
      destruct (disp_scrut_temp a) as [t|] eqn:Hdt; [ | discriminate Hd ].
      pose proof (disp_scrut_temp_shape _ _ Hdt) as Hshape. subst a.
      apply eval_expr_Etempvar_val in Hev.
      cbn [typeof] in Hsa.
      unfold sem_switch_arg in Hsa; cbn [classify_switch] in Hsa.
      destruct v; try discriminate Hsa. inv Hsa.
      destruct HTI as (_ & _ & Hdisp).
      pose proof (Hdisp t Hd i Hev) as Hnt.
      apply chk_seq_of, (chk_disp_select bc _ _ HC).
      exact (not_tainted_not_T_label _ Hnt).
    - (* ordinary switch: every suffix censused *)
      apply chk_seq_of, (chk_all_select bc _ _ HC).
  Qed.

  (* ---- HTI_set: the table maintenance. The census forbids Sset to the
     Mario param; an Sset to a tabled gate temp is the canonical input
     load, whose value is bit-1-clear under input_a_clear; an Sset to a
     tabled dispatch temp is the canonical action load, whose value
     satisfies Q under action_sat. Everything else is gso. ---- *)
  Lemma chk_ti_set :
    forall Q bm bc e le m id a v,
      input_a_clear m bm ->
      action_sat Q m bm ->
      eval_expr (lp_ge lp) e le m a v ->
      TI_of Q bm bc le ->
      chk bc (Sset id a) = true ->
      TI_of Q bm bc (PTree.set id v le).
  Proof.
    intros Q bm bc e le m id a v Hinp Hsat Hev HTI HC.
    change ((negb (Pos.eqb id (bc_mptr bc))
             && (negb (mem_id id (bc_gates bc))
                 || is_input_load_x (bc_mptr bc) a)
             && (negb (mem_id id (bc_disp bc))
                 || is_action_load_x (bc_mptr bc) a)) = true) in HC.
    apply andb_true_iff in HC as [HC Hdisp_rule].
    apply andb_true_iff in HC as [Hnm Hgate_rule].
    destruct HTI as (Hm & Hgate & Hdisp).
    split; [ | split ].
    - (* the Mario param: never assigned (census) *)
      intros vv Hlk.
      rewrite PTree.gso in Hlk
        by (intro E; subst id; rewrite Pos.eqb_refl in Hnm; discriminate Hnm).
      exact (Hm vv Hlk).
    - (* gate temps *)
      intros t Hmem vi Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hgate_rule. cbn [negb orb] in Hgate_rule.
        pose proof (is_input_load_x_shape _ _ Hgate_rule) as Hshape. subst a.
        destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev) as (pb & po & Hpm).
        pose proof (Hm _ Hpm) as Hbm. inv Hbm.
        pose proof (eval_input_load_bm_lp lp LO_mario _ _ _ _ _ _ Hpm Hev)
          as Hload.
        exact (Hinp vi Hload).
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hgate t Hmem vi Hlk).
    - (* dispatch temps *)
      intros t Hmem vi Hlk.
      destruct (Pos.eq_dec t id) as [E|NE].
      + subst t. rewrite PTree.gss in Hlk. inv Hlk.
        rewrite Hmem in Hdisp_rule. cbn [negb orb] in Hdisp_rule.
        pose proof (is_action_load_x_shape _ _ Hdisp_rule) as Hshape. subst a.
        destruct (efield_base_vptr lp _ _ _ _ _ _ _ _ Hev) as (pb & po & Hpm).
        pose proof (Hm _ Hpm) as Hbm. inv Hbm.
        pose proof (eval_action_load_bm_lp lp LO_mario _ _ _ _ _ _ Hpm Hev)
          as Hload.
        exact (Hsat vi Hload).
      + rewrite PTree.gso in Hlk by exact NE.
        exact (Hdisp t Hmem vi Hlk).
  Qed.

End CensusLeavesLp.
