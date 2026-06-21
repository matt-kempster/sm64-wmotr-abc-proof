(* ====================================================================== *)
(* THE spawn_obj_at_mario_rel_yaw SURFACE: spawn_obj_cp PROVED (a brick).   *)
(*                                                                        *)
(* f_spawn_obj_at_mario_rel_yaw (mario_actions_cutscene.prog), the helper  *)
(* the door cutscenes (act_unlocking_key_door / act_exit_land_save_dialog) *)
(* use to drop a key/star object:                                         *)
(*   o = spawn_object(m->marioObj, model, behavior);     <- SafeB pool slot *)
(*   o->rawData.asS32[19] = (short)m->faceAngle[1] + relYaw;  chase stores  *)
(*   o->rawData.asF32[6]  = m->pos[0];                     through the      *)
(*   o->rawData.asF32[7]  = m->pos[1];                     spawned object   *)
(*   o->rawData.asF32[8]  = m->pos[2];                     block (bm-disj). *)
(*   return o;                                                             *)
(*                                                                        *)
(* This is the SPAWN-then-store-through-spawned-obj arc (the air analogue  *)
(* is MboCSurface.mboc_cp).  EVERY store lands in a bm-disjoint SafeB block *)
(* (spawn_object's return, Hcp_spawn = call_pres_ext_sr); the body makes NO *)
(* store through Mario, so it is MARG-FREE (mle tracks only _t'1 / _o).    *)
(* The one callee, spawn_object, is EF_external in EVERY TU (Hcp_spawn_     *)
(* real at the capstone).  Differs from mboc only in the asS32 chase value: *)
(* a SHORT-BINOP `(short)+(short) : int` (not a cast-to-short), whose       *)
(* result is always a Vint (sem_add_short_short_vint).                     *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require Import mario_actions_cutscene.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  LocalVarsSurface DispatchKit MarioStepSurface FloorsSurface WindSurface MWFReal.

Import ListNotations.

Module C := mario_actions_cutscene.

(* ====================================================================== *)
(* The recognizer (top-level, no lp).  Single-column helper booleans.     *)
(* ====================================================================== *)

Definition is_o_temp (a : expr) : bool :=
  match a with Etempvar i _ => Pos.eqb i C._o | _ => false end.
Definition is_t1_temp (a : expr) : bool :=
  match a with Etempvar i _ => Pos.eqb i C._t'1 | _ => false end.

(* the o <- t'1 TRANSFER, or any OTHER temp (gso-safe, must not be t'1/o). *)
Definition sob_set_chk (id : ident) (a : expr) : bool :=
  if Pos.eqb id C._o then is_t1_temp a
  else negb (Pos.eqb id C._t'1) && negb (Pos.eqb id C._o).

(* ---- chase store: o->rawData.{asF32|asS32}[i] = <non-ptr> ---- *)
Definition is_struct_ty (t : type) : bool :=
  match t with Tstruct _ _ => true | _ => false end.
Definition is_o_base (a : expr) : bool :=
  match a with
  | Ederef b t => is_o_temp b && is_struct_ty t
  | _ => false
  end.
Definition is_rawdata_union (a : expr) : bool :=
  match a with
  | Efield b _ (Tunion _ _) => is_o_base b
  | _ => false
  end.
Definition is_chase_arr_field (a : expr) : bool :=
  match a with
  | Efield b _ (Tarray _ _ _) => is_rawdata_union b
  | _ => false
  end.
Definition is_chase_addr (a : expr) : bool :=
  match a with
  | Ebinop Oadd b _ _ => is_chase_arr_field b
  | _ => false
  end.

(* the asS32 value is a short+short binop (an int): always a Vint. *)
Definition is_short_ty (t : type) : bool :=
  match t with Tint I16 _ _ => true | _ => false end.
Definition is_short_binop (a : expr) : bool :=
  match a with
  | Ebinop Oadd a1 a2 _ => is_short_ty (typeof a1) && is_short_ty (typeof a2)
  | _ => false
  end.
(* tfloat dst => the store cast targets Tfloat F32 (always non-ptr); tint  *)
(* dst => the rvalue is a short-binop, so it evaluates to a Vint.           *)
Definition chase_src_ok (ty : type) (a2 : expr) : bool :=
  match ty with
  | Tfloat F32 _ => true
  | Tint I32 _ _ => is_short_binop a2
  | _ => false
  end.

Definition sob_assign_chk (a1 a2 : expr) : bool :=
  match a1 with
  | Ederef aP ty => is_chase_addr aP && chase_src_ok ty a2
  | _ => false
  end.

Definition sob_call_chk (optid : option ident) (a : expr) : bool :=
  match a with
  | Evar fid (Tfunction _ _ _) =>
      if Pos.eqb fid C._spawn_object
      then match optid with Some t => Pos.eqb t C._t'1 | None => false end
      else false
  | _ => false
  end.

Fixpoint sob_chk (s : statement) : bool :=
  match s with
  | Sskip => true
  | Sset id a => sob_set_chk id a
  | Sassign a1 a2 => sob_assign_chk a1 a2
  | Scall optid a _ => sob_call_chk optid a
  | Sreturn _ => true
  | Ssequence s1 s2 => sob_chk s1 && sob_chk s2
  | Sifthenelse _ s1 s2 => sob_chk s1 && sob_chk s2
  | _ => false
  end.

(* NON-VACUITY: the recognizer accepts the REAL generated body. *)
Lemma sob_chk_body :
  sob_chk (fn_body C.f_spawn_obj_at_mario_rel_yaw) = true.
Proof. vm_compute. reflexivity. Qed.

(* the defmap pin: f_spawn_obj_at_mario_rel_yaw is Internal in cutscene.prog. *)
Lemma sob_pin :
  (prog_defmap C.prog) ! C._spawn_obj_at_mario_rel_yaw
  = Some (Gfun (Internal C.f_spawn_obj_at_mario_rel_yaw)).
Proof. vm_compute. reflexivity. Qed.

(* a cast landing in tfloat (Tfloat F32) is never a pointer. *)
Lemma sem_cast_tfloat_nonptr : forall v0 t1 a m v,
    sem_cast v0 t1 (Tfloat F32 a) m = Some v -> forall bb oo, v <> Vptr bb oo.
Proof.
  intros v0 t1 a m v H bb oo Heq; subst v.
  unfold sem_cast in H.
  destruct t1 as [ | sz si att | si att | fsz att | t att
                 | t z att | tl tr cc | id att | id att ];
    cbn in H;
    try (destruct v0; cbn in H; discriminate H);
    try (destruct fsz; cbn in H; destruct v0; cbn in H; discriminate H).
Qed.

(* a short + short add (Tint I16 operands) always evaluates to a Vint:
   classify_add is add_default (neither operand is a pointer), so sem_add
   reduces to sem_binarith at bin_case_i, whose only Some-producing branch
   demands BOTH coerced operands be Vint and yields Vint. *)
Lemma sem_add_short_short_vint : forall cenv v1 s1 a1 v2 s2 a2 m v,
    sem_binary_operation cenv Oadd v1 (Tint I16 s1 a1) v2 (Tint I16 s2 a2) m
      = Some v ->
    exists vi, v = Vint vi.
Proof.
  intros cenv v1 s1 a1 v2 s2 a2 m v H.
  destruct v1; destruct v2; cbn in H; try discriminate H.
  inv H. eexists; reflexivity.
Qed.

Section SpawnObjSurface.
  Variable lp : Clight.program.
  Hypothesis LO_cut : linkorder C.prog lp.
  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  (* a NON-POINTER store into a SafeB block at ANY offset preserves MWF. *)
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  (* spawn_object: the SafeB-return external boundary (Hcp_spawn_real). *)
  Hypothesis Hcp_spawn : call_pres_ext_sr lp bm NoA MWF SafeB C._spawn_object.

  (* ================================================================== *)
  (* The le-invariant: _t'1 / _o hold SafeB pointers if they hold        *)
  (* pointers at all.  (No store goes through _m, so _m is untracked.)   *)
  (* ================================================================== *)
  Definition mle (le : temp_env) : Prop :=
    (forall b o, le ! C._t'1 = Some (Vptr b o) -> SafeB b) /\
    (forall b o, le ! C._o = Some (Vptr b o) -> SafeB b).

  Lemma mle_set_other :
    forall le id v,
      Pos.eqb id C._t'1 = false ->
      Pos.eqb id C._o = false ->
      mle le -> mle (PTree.set id v le).
  Proof.
    intros le id v Ht1 Ho (W1 & Wo).
    refine (conj _ _); intros b o Hg.
    - rewrite PTree.gso in Hg;
        [ exact (W1 b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Ht1; discriminate Ht1 ].
    - rewrite PTree.gso in Hg;
        [ exact (Wo b o Hg)
        | intro E; subst id; rewrite Pos.eqb_refl in Ho; discriminate Ho ].
  Qed.

  (* ================================================================== *)
  (* THE WALK: exec-derivation induction (no Sloop/Sswitch in the body). *)
  (* ================================================================== *)
  Lemma sob_walk_pres :
    forall e le m0 s tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
      sob_chk s = true ->
      e = empty_env ->
      mle le ->
      (Mem.valid_block m0 bm /\ action_sat not_tainted m0 bm /\
       MWF m0 /\ NoA m0) ->
      (Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
       MWF m' /\ NoA m') /\ mle le'.
  Proof.
    intros e le m0 s tr le' m' out Hexec.
    induction Hexec; intros Hchk Hee Hmle Hc.
    - (* Sskip *) exact (conj Hc Hmle).
    - (* Sassign: a chase store o->rawData.{asF32|asS32}[i] = .. *)
      cbn [sob_chk] in Hchk. unfold sob_assign_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct a1 as [ | | | | | | aBP aTY | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk. destruct Hchk as [Haddr Hsrc].
      destruct Hmle as (W1 & Wo).
      (* decode the address chain, pinning the block to le!_o *)
      unfold is_chase_addr in Haddr.
      destruct aBP as [ | | | | | | | | | op cF cI tyB | | | | ];
        try discriminate Haddr.
      destruct op; try discriminate Haddr.
      unfold is_chase_arr_field in Haddr.
      destruct cF as [ | | | | | | | | | | | cF1 fld2 tyA | | ];
        try discriminate Haddr.
      destruct tyA as [ | | | | | tA zA aA | | | ]; try discriminate Haddr.
      unfold is_rawdata_union in Haddr.
      destruct cF1 as [ | | | | | | | | | | | cF2 fld1 tyU | | ];
        try discriminate Haddr.
      destruct tyU as [ | | | | | | | | uU aU ]; try discriminate Haddr.
      unfold is_o_base in Haddr.
      destruct cF2 as [ | | | | | | cW tyS | | | | | | | ];
        try discriminate Haddr.
      apply andb_true_iff in Haddr. destruct Haddr as [Hct Hsty].
      unfold is_o_temp in Hct.
      destruct cW as [ | | | | | w tyW | | | | | | | | ];
        try discriminate Hct.
      apply Pos.eqb_eq in Hct. subst w.
      unfold is_struct_ty in Hsty.
      destruct tyS as [ | | | | | | | sS aS | ]; try discriminate Hsty.
      (* the lvalue chain pins the store block to le!_o's *)
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
      pose proof (Wo _ _ HlvS) as Hsafe.
      (* the stored value v is non-pointer (float dst => Vsingle; tint dst
         => the rvalue is a short-binop, hence a Vint) *)
      assert (Hnoptr : forall bb oo, v <> Vptr bb oo).
      { unfold chase_src_ok in Hsrc.
        destruct aTY as [ | szc sgc atc | sgl atl | szf atf
                        | tp ap | te ze ae | tlf trf ccf | idt ait | idu aiu ];
          try discriminate Hsrc.
        - (* tint dst: the rvalue is a short-binop -> Vint *)
          destruct szc; try discriminate Hsrc.
          unfold is_short_binop in Hsrc.
          destruct a2 as [ | | | | | | | | | bop bA bB bTY | | | | ];
            try discriminate Hsrc.
          destruct bop; try discriminate Hsrc.
          apply andb_true_iff in Hsrc. destruct Hsrc as [HtA HtB].
          unfold is_short_ty in HtA, HtB.
          destruct (typeof bA) as [ | iszA isgA iatA | | | | | | | ] eqn:EtA;
            try discriminate HtA.
          destruct iszA; try discriminate HtA.
          destruct (typeof bB) as [ | iszB isgB iatB | | | | | | | ] eqn:EtB;
            try discriminate HtB.
          destruct iszB; try discriminate HtB.
          (* invert the binop eval: its value v0 is a Vint *)
          match goal with
          | Hev2 : eval_expr _ _ _ _ (Ebinop _ _ _ _) _ |- _ =>
              inv Hev2;
              [ | match goal with
                  | Hx : eval_lvalue _ _ _ _ (Ebinop _ _ _ _) _ _ _ |- _ =>
                      inv Hx
                  end ]
          end.
          match goal with
          | Hsb : sem_binary_operation _ Oadd _ (typeof bA) _ (typeof bB) _
                    = Some ?v0 |- _ =>
              rewrite EtA, EtB in Hsb;
              destruct (sem_add_short_short_vint _ _ _ _ _ _ _ _ _ Hsb)
                as (vi & ->)
          end.
          match goal with
          | Hca : sem_cast (Vint _) _ _ _ = Some v |- _ =>
              exact (sem_cast_vint_not_vptr _ _ _ _ _ Hca)
          end.
        - (* tfloat dst: the STORE cast targets Tfloat F32, hence non-ptr *)
          destruct szf; try discriminate Hsrc.
          match goal with
          | Hca : sem_cast _ _ ?tylv _ = Some v |- _ =>
              change tylv with (Tfloat F32 atf) in Hca;
              exact (sem_cast_tfloat_nonptr _ _ _ _ _ Hca)
          end. }
      (* aTY (the Ederef type) is Tfloat F32 or Tint I32 -- both By_value. *)
      assert (Hacc : exists ch, access_mode aTY = By_value ch).
      { unfold chase_src_ok in Hsrc.
        destruct aTY as [ | isz sg aa | | szf aa | | | | | ];
          try discriminate Hsrc.
        - destruct isz; try discriminate Hsrc; eexists; reflexivity.
        - destruct szf; try discriminate Hsrc; eexists; reflexivity. }
      destruct Hacc as [chA HaccA].
      (* the assign_loc: a By_value store into the SafeB block *)
      match goal with
      | Has : assign_loc _ _ _ _ _ _ _ m' |- _ =>
          cbn [typeof] in Has; inv Has;
          try (match goal with
               | Hac : access_mode _ = _ |- _ =>
                   rewrite HaccA in Hac; discriminate Hac
               end)
      end.
      match goal with
      | Hsv : Mem.storev _ _ (Vptr _ _) _ = Some m' |- _ =>
          unfold Mem.storev in Hsv; rename Hsv into Hst
      end.
      split; [ | exact (conj W1 Wo) ].
      refine (conj _ (conj _ (conj _ _))).
      * eapply Mem.store_valid_block_1; eauto.
      * intros av Hload.
        rewrite (Mem.load_store_other _ _ _ _ _ _ Hst) in Hload;
          [ exact (HS av Hload)
          | left; exact (not_eq_sym (HSafeNotBm _ Hsafe)) ].
      * exact (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst).
      * exact (HNoA_of_MWF _ (HMWF_chase _ _ _ _ _ _ HM Hsafe Hnoptr Hst)).
    - (* Sset: the o <- t'1 transfer, or another temp (gso) *)
      cbn [sob_chk] in Hchk. unfold sob_set_chk in Hchk.
      split; [ exact Hc | ].
      destruct (Pos.eqb id C._o) eqn:Eo.
      + (* the TRANSFER: o = t'1 *)
        apply Pos.eqb_eq in Eo. subst id.
        unfold is_t1_temp in Hchk.
        destruct a as [ | | | | | s0 sty | | | | | | | | ];
          try discriminate Hchk.
        apply Pos.eqb_eq in Hchk. subst s0.
        match goal with
        | Hev : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
            apply eval_expr_Etempvar_val in Hev
        end.
        destruct Hmle as (W1 & Wo).
        refine (conj _ _); intros b o Hg.
        * rewrite PTree.gso in Hg; [ exact (W1 b o Hg) | discriminate ].
        * rewrite PTree.gss in Hg. injection Hg as ->.
          match goal with
          | Hev : le ! C._t'1 = Some (Vptr _ _) |- _ => exact (W1 _ _ Hev)
          end.
      + (* another temp: gso-safe on both clauses (Eo gives the _o clause) *)
        apply andb_true_iff in Hchk. destruct Hchk as [Hn1 _].
        apply negb_true_iff in Hn1.
        exact (mle_set_other le id v Hn1 Eo Hmle).
    - (* Scall: spawn_object (external + SafeB-return) *)
      cbn [sob_chk] in Hchk. unfold sob_call_chk in Hchk.
      destruct Hc as (HV & HS & HM & HN).
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      destruct fty as [ | | | | | | tyl rty cc1 | | ]; try discriminate Hchk.
      subst e.
      match goal with
      | Hvf : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
          apply (eval_Evar_funct_empty lp) in Hvf;
          destruct Hvf as (bf0 & Hsym & ->)
      end.
      match goal with
      | Hff : Genv.find_funct _ (Vptr bf0 Ptrofs.zero) = Some _ |- _ =>
          rename Hff into Hfind
      end.
      destruct (Pos.eqb fid C._spawn_object) eqn:Esp; [ | discriminate Hchk ].
      apply Pos.eqb_eq in Esp. subst fid.
      destruct optid as [ t1 | ]; [ | discriminate Hchk ].
      apply Pos.eqb_eq in Hchk. subst t1.
      destruct Hmle as (W1 & Wo).
      match goal with
      | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
          destruct (Hcp_spawn _ _ _ _ _ _ Hevf
                      (ex_intro _ bf0 (conj Hsym Hfind))
                      HN HM HV HS) as (HV' & HS' & HM' & Hret)
      end.
      split.
      { exact (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))). }
      cbn [set_opttemp].
      refine (conj _ _); intros b o Hg.
      -- rewrite PTree.gss in Hg. injection Hg as Hg.
         exact (Hret _ _ Hg).
      -- rewrite PTree.gso in Hg; [ exact (Wo b o Hg) | discriminate ].
    - (* Sbuiltin: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [sob_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hee Hmle Hc) as (Hc1 & Hmle1).
      exact (IHHexec2 H2 Hee Hmle1 Hc1).
    - (* Sseq_2 *)
      cbn [sob_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 _].
      exact (IHHexec H1 Hee Hmle Hc).
    - (* Sifthenelse *)
      cbn [sob_chk] in Hchk. apply andb_true_iff in Hchk.
      destruct Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None: memory unchanged *)
      exact (conj Hc Hmle).
    - (* Sreturn Some: evaluates the expr, memory unchanged *)
      exact (conj Hc Hmle).
    - (* Sbreak: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Scontinue: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop1: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [sob_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ================================================================== *)
  (* THE ENTRY: bind the four params, seed mle (both SafeB temps Vundef). *)
  (* ================================================================== *)
  Lemma sob_body_pres :
    body_pres lp NoA MWF bm C.f_spawn_obj_at_mario_rel_yaw.
  Proof.
    intros m vargs t mF vres Hgate Hevf HN HM HV HS.
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      change (fn_vars C.f_spawn_obj_at_mario_rel_yaw)
        with (@nil (ident * type)) in Ha;
      inv Ha end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    change (fn_params C.f_spawn_obj_at_mario_rel_yaw)
      with ((C._m, tptr (Tstruct C._MarioState noattr)) :: (C._model, tint)
              :: (C._behavior, tptr tuint) :: (C._relYaw, tshort) :: nil)
      in Hbind.
    cbn [bind_parameter_temps] in Hbind.
    destruct vargs as [ | v1 vr1 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr1 as [ | v2 vr2 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr2 as [ | v3 vr3 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr3 as [ | v4 vr4 ]; [ discriminate Hbind | ].
    cbn [bind_parameter_temps] in Hbind.
    destruct vr4 as [ | v5 vr5 ]; [ | discriminate Hbind ].
    injection Hbind as <-.
    (* the entry invariant: _t'1 / _o are Vundef in the undef-temps env. *)
    assert (Hmle : mle (PTree.set C._relYaw v4
                          (PTree.set C._behavior v3
                             (PTree.set C._model v2
                                (PTree.set C._m v1
                                   (create_undef_temps
                                      (fn_temps C.f_spawn_obj_at_mario_rel_yaw))))))).
    { refine (conj _ _); intros b o Hg.
      - rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg.
      - rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        rewrite PTree.gso in Hg; [ | discriminate ].
        vm_compute in Hg. discriminate Hg. }
    destruct (sob_walk_pres _ _ _ _ _ _ _ _ Hbody sob_chk_body eq_refl Hmle
                (conj HV (conj HS (conj HM HN)))) as ((HV' & HS' & HM' & _) & _).
    change (blocks_of_env (lp_ge lp) empty_env) with (@nil (block * Z * Z))
      in Hfree.
    cbn [Mem.free_list] in Hfree. injection Hfree as <-.
    exact (conj HV' (conj HS' HM')).
  Qed.

  (* ================================================================== *)
  (* THE PAYOFF: spawn_obj_cp, PROVED (the door-cutscene ids row).        *)
  (* ================================================================== *)
  Theorem spawn_obj_cp :
    call_pres lp bm NoA MWF C._spawn_obj_at_mario_rel_yaw.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF C.prog
             C._spawn_obj_at_mario_rel_yaw C.f_spawn_obj_at_mario_rel_yaw
             LO_cut sob_pin sob_body_pres).
  Qed.

End SpawnObjSurface.
