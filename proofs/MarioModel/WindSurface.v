(* ====================================================================== *)
(* THE WIND SURFACE: Hpres_wind DISCHARGED (SPINE: consumed by the        *)
(* MWF-grounded capstone).                                                *)
(*                                                                        *)
(* f_spawn_wind_particles = a 3-iteration loop, each iteration:           *)
(*   _t'2 = gCurrentObject; _t'1 = spawn_object(_t'2, 142, bhvWind);      *)
(*   _wind = _t'1; wind->rawData.asS32[16] = yaw;                         *)
(*   wind->rawData.asS32[15] = pitch.                                     *)
(*                                                                        *)
(* THE FIRST LOOP-TOLERANT WALK: the exec-derivation induction handles    *)
(* Sloop for free (the three Sloop cases each apply the IH; the threaded  *)
(* facts are loop-invariant by construction) -- earlier walkers only      *)
(* discriminated Sloop because their recognizers rejected it.             *)
(*                                                                        *)
(* The two ingredients that make the walk honest:                        *)
(* - the sargs gate (body_pres_s): wind's (tshort, tshort) signature pins *)
(*   yaw/pitch to Vint at entry -- without it the rawData stores would    *)
(*   accept an adversarial Vptr (ptr32 cast_case_pointer passes pointers  *)
(*   THROUGH the inline s32 store cast) and break MWF_real's chase        *)
(*   closure, making plain body_pres FALSE.                               *)
(* - the spawn_object row (call_pres_ext_sr): spawn_object has NO         *)
(*   internal body anywhere in generated/ (EF_external in every TU), so   *)
(*   it is an honest terminal external-call-model boundary; its return    *)
(*   pointer is a slot of the SafeB object pool (which is exactly what    *)
(*   MWF_real's chase closure forces anyway, since the spawned object is  *)
(*   chase-reachable from the object lists).                              *)
(* ====================================================================== *)

From Coq Require Import ZArith List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require behavior_actions.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  LocalVarsSurface.

Import ListNotations.

(* ====================================================================== *)
(* The carried-preserving + SafeB-return external row (per-symbol).       *)
(* Like call_pres_ext, plus: the return value, IF a pointer, is a SafeB   *)
(* block.  spawn_object hands out a slot of the static object pool.       *)
(* ====================================================================== *)
Definition call_pres_ext_sr (lp : Clight.program) (bm : block)
    (NoA MWF : mem -> Prop) (SafeB : block -> Prop) (fid : ident) : Prop :=
  forall fd m0 vargs0 t0 m1 vres0,
    eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
    (exists b, Genv.find_symbol (lp_ge lp) fid = Some b /\
               Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd) ->
    NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
    action_sat not_tainted m0 bm ->
    Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\ MWF m1 /\
    (forall b o, vres0 = Vptr b o -> SafeB b).

(* ====================================================================== *)
(* The recognizer (top-level: no lp).  Accepts Sloop -- the walker's      *)
(* exec-derivation induction handles the three loop cases by IH.          *)
(* ====================================================================== *)

(* The recognizers are built from chained SINGLE-COLUMN helper booleans:
   a deep multi-column pattern (sibling sub-patterns on the same match)
   compiles in an order the proof's destruct cascade cannot rely on --
   non-matching branches stay STUCK instead of reducing to false, so the
   `try discriminate` cascade leaks wrong-shape goals.  One constructor
   level per match keeps every intermediate reduction definitional. *)

Definition is_i_temp (a : expr) : bool :=
  match a with
  | Etempvar i' _ => Pos.eqb i' behavior_actions._i
  | _ => false
  end.

Definition is_const_int (a : expr) : bool :=
  match a with Econst_int _ _ => true | _ => false end.

(* Ssets: the loop counter _i (const init + increment), the global load
   into _t'2, and the pinned _t'1 -> _wind TRANSFER. *)
Definition wnd_set_chk (id : ident) (a : expr) : bool :=
  match a with
  | Econst_int _ _ => Pos.eqb id behavior_actions._i
  | Ebinop Oadd b1 b2 _ =>
      Pos.eqb id behavior_actions._i && is_i_temp b1 && is_const_int b2
  | Evar _ _ => Pos.eqb id behavior_actions._t'2
  | Etempvar s _ =>
      Pos.eqb id behavior_actions._wind && Pos.eqb s behavior_actions._t'1
  | _ => false
  end.

Definition is_wind_temp (a : expr) : bool :=
  match a with
  | Etempvar w _ => Pos.eqb w behavior_actions._wind
  | _ => false
  end.

Definition is_struct_ty (t : type) : bool :=
  match t with Tstruct _ _ => true | _ => false end.

Definition is_wind_base (a : expr) : bool :=
  match a with
  | Ederef b t => is_wind_temp b && is_struct_ty t
  | _ => false
  end.

Definition is_union_field (a : expr) : bool :=
  match a with
  | Efield b _ (Tunion _ _) => is_wind_base b
  | _ => false
  end.

Definition is_arr_field (a : expr) : bool :=
  match a with
  | Efield b _ (Tarray _ _ _) => is_union_field b
  | _ => false
  end.

Definition is_store_addr (a : expr) : bool :=
  match a with
  | Ebinop Oadd b _ _ => is_arr_field b
  | _ => false
  end.

Definition is_s32 (t : type) : bool :=
  match t with Tint I32 Signed _ => true | _ => false end.

Definition is_src_temp (a : expr) : bool :=
  match a with
  | Etempvar s _ =>
      Pos.eqb s behavior_actions._yaw || Pos.eqb s behavior_actions._pitch
  | _ => false
  end.

(* the two rawData stores: wind->rawData.asS32[15+k] = yaw/pitch.  The
   lvalue is an indexed By_value-tint cell of an array field of a union
   field of *(_wind); the rvalue is the Vint-pinned scalar param. *)
Definition wnd_assign_chk (a1 a2 : expr) : bool :=
  match a1 with
  | Ederef aP ty1 => is_store_addr aP && is_s32 ty1 && is_src_temp a2
  | _ => false
  end.

Definition is_spawn_fn (a : expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      Pos.eqb fid behavior_actions._spawn_object
  | _ => false
  end.

(* the one call: _t'1 = spawn_object(...).  Arguments unconstrained (the
   row has no argument premise). *)
Definition wnd_call_chk (optid : option ident) (a : expr) : bool :=
  match optid with
  | Some t => Pos.eqb t behavior_actions._t'1 && is_spawn_fn a
  | None => false
  end.

Fixpoint wnd_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak => true
  | Sset id a => wnd_set_chk id a
  | Sassign a1 a2 => wnd_assign_chk a1 a2
  | Scall optid a _ => wnd_call_chk optid a
  | Ssequence s1 s2 => wnd_chk s1 && wnd_chk s2
  | Sloop s1 s2 => wnd_chk s1 && wnd_chk s2
  | Sifthenelse _ s1 s2 => wnd_chk s1 && wnd_chk s2
  | _ => false
  end.

(* non-vacuity: the real generated body passes the census. *)
Lemma wnd_chk_body :
  wnd_chk (fn_body behavior_actions.f_spawn_wind_particles) = true.
Proof. vm_compute. reflexivity. Qed.

Section WindSurface.
  Variable lp : Clight.program.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  (* the value-aware chase row (MWFReal.mwf_real_chase at the capstone):
     a NON-POINTER store into a SafeB block at ANY offset preserves MWF. *)
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  (* THE residual this walk emits: the spawn_object model-boundary row. *)
  Hypothesis Hcp_spawn : call_pres_ext_sr lp bm NoA MWF SafeB
      behavior_actions._spawn_object.

  (* the threaded temp facts: yaw/pitch stay the entry Vints (no Sset in
     the body writes them); _t'1/_wind hold SafeB pointers IF pointers at
     all (Vundef at entry; re-established at the Scall return and carried
     across the pinned transfer). *)
  Definition wle (le : temp_env) : Prop :=
    (exists n, le ! behavior_actions._yaw = Some (Vint n)) /\
    (exists n, le ! behavior_actions._pitch = Some (Vint n)) /\
    (forall b o, le ! behavior_actions._t'1 = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! behavior_actions._wind = Some (Vptr b o) -> SafeB b).

  Lemma wle_set_other :
    forall le id v,
      Pos.eqb id behavior_actions._yaw = false ->
      Pos.eqb id behavior_actions._pitch = false ->
      Pos.eqb id behavior_actions._t'1 = false ->
      Pos.eqb id behavior_actions._wind = false ->
      wle le -> wle (PTree.set id v le).
  Proof.
    intros le id v Hy Hp H1 Hw (Wy & Wp & W1 & Ww).
    refine (conj _ (conj _ (conj _ _))).
    - destruct Wy as (n & Hn). exists n.
      rewrite PTree.gso; [ exact Hn | ].
      intro E. subst id. rewrite Pos.eqb_refl in Hy. discriminate Hy.
    - destruct Wp as (n & Hn). exists n.
      rewrite PTree.gso; [ exact Hn | ].
      intro E. subst id. rewrite Pos.eqb_refl in Hp. discriminate Hp.
    - intros b o Hg.
      rewrite PTree.gso in Hg;
        [ exact (W1 b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in H1; discriminate H1 ].
    - intros b o Hg.
      rewrite PTree.gso in Hg;
        [ exact (Ww b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Hw; discriminate Hw ].
  Qed.

  (* ================================================================== *)
  (* THE WALK: exec-derivation induction; Sloop by IH.                   *)
  (* ================================================================== *)
  Lemma wnd_walk_pres :
    forall e le m0 s tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      wnd_chk s = true ->
      e = empty_env ->
      wle le ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ wle le'.
  Proof.
    intros e le m0 s tr le' m' out Hexec.
    induction Hexec; intros Hchk Hee Hwle Hc.
    - (* Sskip *) exact (conj Hc Hwle).
    - (* Sassign: the two rawData stores *)
      cbn [wnd_chk] in Hchk. unfold wnd_assign_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct a1 as [ | | | | | | aP ty1 | | | | | | | ]; try discriminate Hchk.
      apply andb_true_iff in Hchk. destruct Hchk as [Hchk Hsrc].
      apply andb_true_iff in Hchk. destruct Hchk as [Haddr Hty1].
      (* decode the address chain (one constructor level per step) *)
      unfold is_store_addr in Haddr.
      destruct aP as [ | | | | | | | | | op aF aI tyB | | | | ]; try discriminate Haddr.
      destruct op; try discriminate Haddr.
      unfold is_arr_field in Haddr.
      destruct aF as [ | | | | | | | | | | | aF1 fld2 tyA | | ]; try discriminate Haddr.
      destruct tyA as [ | | | | | tA zA aA | | | ]; try discriminate Haddr.
      unfold is_union_field in Haddr.
      destruct aF1 as [ | | | | | | | | | | | aF2 fld1 tyU | | ]; try discriminate Haddr.
      destruct tyU as [ | | | | | | | | uU aU ]; try discriminate Haddr.
      unfold is_wind_base in Haddr.
      destruct aF2 as [ | | | | | | aW tyS | | | | | | | ]; try discriminate Haddr.
      apply andb_true_iff in Haddr. destruct Haddr as [Hwt Hsty].
      unfold is_wind_temp in Hwt.
      destruct aW as [ | | | | | w tyW | | | | | | | | ]; try discriminate Hwt.
      apply Pos.eqb_eq in Hwt. subst w.
      unfold is_struct_ty in Hsty.
      destruct tyS as [ | | | | | | | sS aS | ]; try discriminate Hsty.
      (* decode the store type *)
      unfold is_s32 in Hty1.
      destruct ty1 as [ | sz1 sg1 at1 | | | | | | | ]; try discriminate Hty1.
      destruct sz1; try discriminate Hty1.
      destruct sg1; try discriminate Hty1.
      (* decode the rvalue *)
      unfold is_src_temp in Hsrc.
      destruct a2 as [ | | | | | src tys2 | | | | | | | | ]; try discriminate Hsrc.
      (* the lvalue chain pins the store block to le!_wind's *)
      match goal with
      | Hlv : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv
      end.
      match goal with
      | Hb : eval_expr _ _ _ _ (Ebinop _ _ _ _) (Vptr _ _) |- _ => inv Hb
      end.
      2:{ match goal with
          | HlvX : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ => inv HlvX
          end. }
      match goal with
      | Hsem : sem_binary_operation _ Oadd _ _ _ _ _ = Some (Vptr _ _) |- _ =>
          cbn [typeof] in Hsem;
          destruct (sem_add_ptrish_block _ _ (Tarray tA zA aA) _ _ _ _ _
                      eq_refl Hsem) as (oA & ->)
      end.
      match goal with
      | Hv1 : eval_expr _ _ _ _ (Efield _ _ (Tarray _ _ _)) (Vptr _ _) |- _ =>
          apply eval_expr_Efield_load in Hv1;
          destruct Hv1 as (lA & ofA & bfA & HlvA & HdA)
      end.
      destruct (deref_loc_aggregate_eq (Tarray tA zA aA) _ _ _ _ _ _
                  (or_introl eq_refl) HdA) as [E1 E2]; subst.
      match goal with
      | HlvA' : eval_lvalue _ _ _ _ (Efield _ _ (Tarray _ _ _)) _ _ _ |- _ =>
          apply eval_lvalue_Efield_base in HlvA';
          destruct HlvA' as (oU & HevU)
      end.
      apply eval_expr_Efield_load in HevU.
      destruct HevU as (lU & ofU & bfU & HlvU & HdU).
      destruct (deref_loc_aggregate_eq (Tunion uU aU) _ _ _ _ _ _
                  (or_intror eq_refl) HdU) as [E3 E4]; subst.
      apply eval_lvalue_Efield_base in HlvU.
      destruct HlvU as (oS & HevS).
      apply eval_expr_Ederef_load in HevS.
      destruct HevS as (lS & ofS & bfS & HlvS & HdS).
      destruct (deref_loc_aggregate_eq (Tstruct sS aS) _ _ _ _ _ _
                  (or_intror eq_refl) HdS) as [E5 E6]; subst.
      apply eval_lvalue_Ederef_base in HlvS.
      apply eval_expr_Etempvar_val in HlvS.
      pose proof Hwle as (Wy & Wp & W1 & Ww).
      pose proof (Ww _ _ HlvS) as Hsafe.
      (* the rvalue: the Vint-pinned scalar param; its cast stays non-ptr *)
      assert (Hsrcv : exists n, le ! src = Some (Vint n)).
      { apply orb_true_iff in Hsrc.
        destruct Hsrc as [Hs | Hs]; apply Pos.eqb_eq in Hs; subst src;
          assumption. }
      destruct Hsrcv as (nsv & Hnsv).
      match goal with
      | Hev2 : eval_expr _ _ _ _ (Etempvar src _) _ |- _ =>
          apply eval_expr_Etempvar_val in Hev2;
          rewrite Hnsv in Hev2; injection Hev2 as <-
      end.
      match goal with
      | Hcast : sem_cast (Vint _) _ _ _ = Some _ |- _ =>
          pose proof (sem_cast_vint_nonptr _ _ _ _ _ Hcast) as Hnoptr
      end.
      (* the assign_loc: a By_value Mint32 store into the SafeB block *)
      match goal with
      | Has : assign_loc _ _ _ _ _ _ _ _ |- _ =>
          cbn [typeof] in Has; inv Has;
          try (match goal with
               | Hacc2 : access_mode _ = _ |- _ =>
                   cbn in Hacc2; discriminate Hacc2
               end)
      end.
      match goal with
      | Hacc2 : access_mode _ = By_value _ |- _ =>
          cbn in Hacc2; injection Hacc2 as <-
      end.
      match goal with
      | Hstv : Mem.storev _ _ _ _ = Some _ |- _ =>
          unfold Mem.storev in Hstv; rename Hstv into Hst
      end.
      split; [ | exact Hwle ].
      refine (conj _ (conj _ (conj _ _))).
      + eapply Mem.store_valid_block_1; eauto.
      + intros av Hload.
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
          [ exact (HS av Hload)
          | left; exact (not_eq_sym (HSafeNotBm _ Hsafe)) ].
      + exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst).
      + exact (HNoA_of_MWF _ (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst)).
    - (* Sset: counter/global-load (gso) or the pinned transfer *)
      cbn [wnd_chk] in Hchk. unfold wnd_set_chk in Hchk.
      split; [ exact Hc | ].
      destruct a as [ ci cty | | | | g gty | s0 sty | | | |
                      bop b1 b2 bty | | | | ];
        try discriminate Hchk.
      + (* _i = const *)
        apply Pos.eqb_eq in Hchk. subst id.
        apply wle_set_other;
          [ reflexivity | reflexivity | reflexivity | reflexivity | exact Hwle ].
      + (* _t'2 = gCurrentObject *)
        apply Pos.eqb_eq in Hchk. subst id.
        apply wle_set_other;
          [ reflexivity | reflexivity | reflexivity | reflexivity | exact Hwle ].
      + (* the TRANSFER: _wind = _t'1 *)
        apply andb_true_iff in Hchk. destruct Hchk as [Hid Hs0].
        apply Pos.eqb_eq in Hid. apply Pos.eqb_eq in Hs0. subst id s0.
        match goal with
        | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev
        end.
        destruct Hwle as (Wy & Wp & W1 & Ww).
        refine (conj _ (conj _ (conj _ _))).
        * destruct Wy as (n & Hn). exists n.
          rewrite PTree.gso; [ exact Hn | discriminate ].
        * destruct Wp as (n & Hn). exists n.
          rewrite PTree.gso; [ exact Hn | discriminate ].
        * intros b o Hg.
          rewrite PTree.gso in Hg; [ exact (W1 b o Hg) | discriminate ].
        * intros b o Hg.
          rewrite PTree.gss in Hg. injection Hg as ->.
          match goal with
          | Hev : le ! behavior_actions._t'1 = Some (Vptr _ _) |- _ =>
              exact (W1 _ _ Hev)
          end.
      + (* _i = _i + 1 *)
        destruct bop; try discriminate Hchk.
        apply andb_true_iff in Hchk. destruct Hchk as [Hchk _].
        apply andb_true_iff in Hchk. destruct Hchk as [Hid _].
        apply Pos.eqb_eq in Hid. subst id.
        apply wle_set_other;
          [ reflexivity | reflexivity | reflexivity | reflexivity | exact Hwle ].
    - (* Scall: spawn_object through the carried+SafeB-return row *)
      cbn [wnd_chk] in Hchk. unfold wnd_call_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct optid as [ t0id | ]; [ | discriminate Hchk ].
      apply andb_true_iff in Hchk. destruct Hchk as [Ht1 Hfid].
      apply Pos.eqb_eq in Ht1. subst t0id.
      unfold is_spawn_fn in Hfid.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hfid.
      destruct fty as [ | | | | | | tyl rty cc1 | | ]; try discriminate Hfid.
      apply Pos.eqb_eq in Hfid. subst fid.
      subst e.
      match goal with
      | Hvf : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
          apply (eval_Evar_funct_empty lp) in Hvf;
          destruct Hvf as (bf0 & Hsym & ->)
      end.
      match goal with
      | Hff : Genv.find_funct _ (Vptr bf0 Ptrofs.zero) = Some _,
        Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
          destruct (Hcp_spawn _ _ _ _ _ _ Hevf
                      (ex_intro _ bf0 (conj Hsym Hff))
                      HN HM HV HS) as (HV' & HS' & HM' & Hret)
      end.
      split.
      { exact (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))). }
      destruct Hwle as (Wy & Wp & W1 & Ww).
      cbn [set_opttemp].
      refine (conj _ (conj _ (conj _ _))).
      + destruct Wy as (n & Hn). exists n.
        rewrite PTree.gso; [ exact Hn | discriminate ].
      + destruct Wp as (n & Hn). exists n.
        rewrite PTree.gso; [ exact Hn | discriminate ].
      + intros b o Hg.
        rewrite PTree.gss in Hg. injection Hg as Hg.
        exact (Hret _ _ Hg).
      + intros b o Hg.
        rewrite PTree.gso in Hg; [ exact (Ww b o Hg) | discriminate ].
    - (* Sbuiltin: rejected *)
      cbn [wnd_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [wnd_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hee Hwle Hc) as (Hc1 & Hwle1).
      exact (IHHexec2 H2 Hee Hwle1 Hc1).
    - (* Sseq_2 *)
      cbn [wnd_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 _].
      exact (IHHexec H1 Hee Hwle Hc).
    - (* Sifthenelse *)
      cbn [wnd_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None: rejected *)
      cbn [wnd_chk] in Hchk. discriminate Hchk.
    - (* Sreturn Some: rejected *)
      cbn [wnd_chk] in Hchk. discriminate Hchk.
    - (* Sbreak *) exact (conj Hc Hwle).
    - (* Scontinue: rejected *)
      cbn [wnd_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop1: the first body run ends the loop *)
      cbn [wnd_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 _].
      exact (IHHexec H1 Hee Hwle Hc).
    - (* Sloop stop2: body Out_normal/Continue, then s2 stops *)
      cbn [wnd_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hee Hwle Hc) as (Hc1 & Hwle1).
      exact (IHHexec2 H2 Hee Hwle1 Hc1).
    - (* Sloop loop: body, s2, then the loop again -- all by IH *)
      pose proof Hchk as Hchk2.
      cbn [wnd_chk] in Hchk2. apply andb_true_iff in Hchk2.
      destruct Hchk2 as [H1 H2].
      destruct (IHHexec1 H1 Hee Hwle Hc) as (Hc1 & Hwle1).
      destruct (IHHexec2 H2 Hee Hwle1 Hc1) as (Hc2 & Hwle2).
      exact (IHHexec3 Hchk Hee Hwle2 Hc2).
    - (* Sswitch: rejected *)
      cbn [wnd_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: the sargs-gated wind residual, PROVED.                  *)
  (* ================================================================== *)
  Theorem wind_pres :
    body_pres_s lp NoA MWF bm behavior_actions.f_spawn_wind_particles.
  Proof.
    intros m vargs t m' vres Hmargp Hsargs Hevf HN HM HV HS.
    (* the sargs gate fires: the signature is all-sub-32-int *)
    assert (Hvint : Forall (fun v => exists n, v = Vint n) vargs).
    { apply Hsargs. vm_compute. reflexivity. }
    inv Hevf.
    match goal with
    | He : function_entry2 _ _ _ _ _ _ _ |- _ => rename He into Hentry
    end.
    match goal with
    | Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ => rename Hx into Hbody
    end.
    match goal with
    | Hf : Mem.free_list _ _ = Some _ |- _ => rename Hf into Hfree
    end.
    inv Hentry.
    match goal with
    | Ha : alloc_variables _ _ _ _ _ _ |- _ =>
        change (fn_vars behavior_actions.f_spawn_wind_particles)
          with (@nil (ident * type)) in Ha;
        inv Ha
    end.
    match goal with
    | Hb : bind_parameter_temps _ _ _ = Some _ |- _ => rename Hb into Hbind
    end.
    change (fn_params behavior_actions.f_spawn_wind_particles)
      with ((behavior_actions._pitch, tshort)
              :: (behavior_actions._yaw, tshort) :: nil) in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [ | v1 vr1 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr1 as [ | v2 vr2 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr2 as [ | v3 vr3 ]; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* the gate pins both params to Vint *)
    inversion Hvint as [ | x1 l1 Hv1 Hvr ]; subst.
    inversion Hvr as [ | x2 l2 Hv2 _ ]; subst.
    destruct Hv1 as (n1 & ->). destruct Hv2 as (n2 & ->).
    (* the entry temp facts *)
    assert (Hwle : wle (PTree.set behavior_actions._yaw (Vint n2)
                          (PTree.set behavior_actions._pitch (Vint n1)
                             (create_undef_temps
                                (fn_temps behavior_actions.f_spawn_wind_particles))))).
    { refine (conj _ (conj _ (conj _ _))).
      - exists n2. apply PTree.gss.
      - exists n1.
        rewrite PTree.gso; [ apply PTree.gss | discriminate ].
      - intros b o Hg.
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg.
      - intros b o Hg.
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg. }
    (* the walk *)
    destruct (wnd_walk_pres _ _ _ _ _ _ _ _ Hbody wnd_chk_body eq_refl Hwle
                (conj HV (conj HS (conj HM HN)))) as ((HV' & HS' & HM' & _) & _).
    (* exit: fn_vars = nil, nothing to free *)
    change (blocks_of_env (lp_ge lp) empty_env)
      with (@nil (block * Z * Z)) in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' HM')).
  Qed.

End WindSurface.
