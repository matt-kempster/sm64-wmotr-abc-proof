(* ====================================================================== *)
(* THE MARIO_STEP SURFACE (SPINE: pgs_cp DISCHARGES the capstone's        *)
(* Hcp_pgs -- the perform_ground_step opaque-internal blocker).           *)
(*                                                                        *)
(* f_perform_ground_step (mario_step.v:2274, fn_vars = [_intendedPos])    *)
(* is the shared ground-movement worker consumed by the B3 sgs_row and    *)
(* act_punching.  Its body is a 4-iteration Sloop of pure m->... loads,   *)
(* window-checked m-field stores, indexed stores into its OWN stack array *)
(* _intendedPos, and 4 calls:                                             *)
(*   - perform_ground_quarter_step(m, intendedPos): the 363-line quarter- *)
(*     step worker.  intendedPos is pgs's stack local, so the HONEST gate *)
(*     is the marg-AND-local mo class (call_pres_mo) -- a plain marg      *)
(*     call_pres would be PHANTOM-FALSE (an unconstrained intendedPos     *)
(*     could alias bm's action cell).  Deeper row, walkable later.        *)
(*   - mario_get_terrain_sound_addend(m): plain marg internal (Internal   *)
(*     in mario.prog; EF_external in mario_step.prog).  Deeper row.       *)
(*   - vec3f_copy / vec3s_set: the ungated obj_ext_ids externals already  *)
(*     carried by the capstone (Hpres_obj_ext).                           *)
(* The walk: a loop-tolerant exec-derivation induction (the wind shape)   *)
(* threading carried + the conditional _m marg fact; the fn_var arc       *)
(* (LocalVarsSurface) supplies entry alloc / local-store / exit free.     *)
(* NEW reusable brick: cp_scall_pres, the GENERAL-ENV marg internal-call  *)
(* arm (kit_scall_pres is empty-env-only).                                *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Generated Require mario mario_step mario_actions_airborne
  mario_actions_automatic.
From SM64.Proofs Require Import SymbolicLinking Flying Taint
  ActionValueFrame RealFrameValue RealFrameLinked AGates.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface
  AirborneSurface DispatchKit FloorsSurface AutomaticSurface.
From SM64.Proofs Require Import ActWriterSurface ObjectLeafSurface
  AutomaticLeafSurface.
From SM64.Proofs Require Import LocalVarsSurface OutParamSurface.

Import ListNotations.

(* ---- the Mario-pointer type as mario_step spells it ---- *)
Definition tyMSstp : type := tptr (Tstruct mario_step._MarioState noattr).

(* ====================================================================== *)
(* recognizers                                                            *)
(* ====================================================================== *)
Definition pgs_assign_chk (a1 : expr) : bool :=
  safe_mfield_store mario_step._m a1
  || match a1 with
     | Ederef (Ebinop Oadd (Evar lid (Tarray ety sz attr))
                 (Econst_int _ tci) itya) ety2 =>
         Pos.eqb lid mario_step._intendedPos
         && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
         && proj_sumbool (type_eq tci tint)
         && proj_sumbool (type_eq itya (tptr tfloat))
         && proj_sumbool (type_eq ety2 tfloat)
     | _ => false
     end.

Definition pgs_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid mario_step._perform_ground_quarter_step
   && proj_sumbool
        (type_eq fty
           (Tfunction (tyMSstp :: tptr tfloat :: nil) tint cc_default))
   && match al with
      | Etempvar mp tmp :: Evar q tq :: nil =>
          Pos.eqb mp mario_step._m
          && Pos.eqb q mario_step._intendedPos
          && proj_sumbool (type_eq tmp tyMSstp)
          && proj_sumbool (type_eq tq (tarray tfloat 3))
      | _ => false
      end)
  || (Pos.eqb fid mario_step._mario_get_terrain_sound_addend
      && proj_sumbool
           (type_eq fty (Tfunction (tyMSstp :: nil) tuint cc_default))
      && match al with
         | Etempvar mp tmp :: nil =>
             Pos.eqb mp mario_step._m && proj_sumbool (type_eq tmp tyMSstp)
         | _ => false
         end)
  || (Pos.eqb fid mario_step._vec3f_copy
      && proj_sumbool
           (type_eq fty
              (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                 cc_default)))
  || (Pos.eqb fid mario_step._vec3s_set
      && proj_sumbool
           (type_eq fty
              (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                 (tptr tvoid) cc_default))).

Definition pgs_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id mario_step._m)
  | None => true
  end.

Fixpoint pgs_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => pgs_chk s1 && pgs_chk s2
  | Sifthenelse _ s1 s2 => pgs_chk s1 && pgs_chk s2
  | Sloop s1 s2 => pgs_chk s1 && pgs_chk s2
  | Sset id _ => pgs_optid_ok (Some id)
  | Sassign a1 _ => pgs_assign_chk a1
  | Scall optid (Evar fid fty) al => pgs_optid_ok optid && pgs_call_chk fid fty al
  | _ => false
  end.

Lemma pgs_pin :
  (prog_defmap mario_step.prog) ! mario_step._perform_ground_step
  = Some (Gfun (Internal mario_step.f_perform_ground_step)).
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: the recognizer accepts the REAL generated body. *)
Lemma pgs_chk_body :
  pgs_chk (fn_body mario_step.f_perform_ground_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* the rows                                                               *)
(* ====================================================================== *)
Section PgsSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.
  Hypothesis HSafeValid :
    forall m, MWF m -> forall b, SafeB b -> Mem.valid_block m b.
  Hypothesis HGlobValid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  Hypothesis Hls_real :
    forall m ch b (d : Z) v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.

  (* the callee rows *)
  Hypothesis Hcp_pgqs :
    call_pres_mo lp bm NoA MWF SafeB mario_step._perform_ground_quarter_step.
  Hypothesis Hcp_mgtsa :
    call_pres lp bm NoA MWF mario_step._mario_get_terrain_sound_addend.
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario_step._vec3s_set.

  (* ---- decoders ---- *)
  Lemma pgs_assign_decode :
    forall a1, pgs_assign_chk a1 = true ->
      safe_mfield_store mario_step._m a1 = true
      \/ exists idxN,
          a1 = Ederef (Ebinop Oadd
                         (Evar mario_step._intendedPos (tarray tfloat 3))
                         (Econst_int idxN tint) (tptr tfloat)) tfloat.
  Proof.
    intros a1 H. unfold pgs_assign_chk in H.
    apply orb_true_iff in H as [Hsf | Hidx]; [ left; exact Hsf | right ].
    destruct a1 as [ | | | | | | ein eity | | | | | | | ]; try discriminate Hidx.
    destruct ein as [ | | | | | | | | | bop e1 e2 bty | | | | ];
      try discriminate Hidx.
    destruct bop; try discriminate Hidx.
    destruct e1 as [ | | | | vid vty | | | | | | | | | ]; try discriminate Hidx.
    destruct vty as [ | | | | | aty asz aattr | | | ]; try discriminate Hidx.
    destruct e2 as [ ic ict | | | | | | | | | | | | | ]; try discriminate Hidx.
    apply andb_true_iff in Hidx as [Hidx He2y].
    apply andb_true_iff in Hidx as [Hidx Hity].
    apply andb_true_iff in Hidx as [Hidx Hict].
    apply andb_true_iff in Hidx as [Hlid Harr].
    apply Pos.eqb_eq in Hlid; subst vid.
    destruct (type_eq (Tarray aty asz aattr) (tarray tfloat 3))
      as [Ea | ]; [ | discriminate Harr ].
    destruct (type_eq ict tint) as [Ei | ]; [ subst ict | discriminate Hict ].
    destruct (type_eq bty (tptr tfloat)) as [Eb | ]; [ subst bty | discriminate Hity ].
    destruct (type_eq eity tfloat) as [Ee | ]; [ subst eity | discriminate He2y ].
    rewrite Ea. exists ic. reflexivity.
  Qed.

  Lemma pgs_call_decode :
    forall fid fty al, pgs_call_chk fid fty al = true ->
      (fid = mario_step._perform_ground_quarter_step /\
       fty = Tfunction (tyMSstp :: tptr tfloat :: nil) tint cc_default /\
       al = Etempvar mario_step._m tyMSstp
            :: Evar mario_step._intendedPos (tarray tfloat 3) :: nil)
      \/ (fid = mario_step._mario_get_terrain_sound_addend /\
          fty = Tfunction (tyMSstp :: nil) tuint cc_default /\
          al = Etempvar mario_step._m tyMSstp :: nil)
      \/ (fid = mario_step._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default)
      \/ (fid = mario_step._vec3s_set /\
          fty = Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                  (tptr tvoid) cc_default).
  Proof.
    intros fid fty al H. unfold pgs_call_chk in H.
    apply orb_true_iff in H as [H | Hv3s].
    apply orb_true_iff in H as [H | Hv3f].
    apply orb_true_iff in H as [Hpgqs | Hmgtsa].
    - left.
      apply andb_true_iff in Hpgqs as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tyMSstp :: tptr tfloat :: nil) tint cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htq].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hmp Hq].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      destruct (type_eq tq (tarray tfloat 3)) as [E2 | ];
        [ subst tq | discriminate Htq ].
      reflexivity.
    - right; left.
      apply andb_true_iff in Hmgtsa as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tyMSstp :: nil) tuint cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0; try discriminate Hal.
      apply andb_true_iff in Hal as [Hmp Htmp].
      apply Pos.eqb_eq in Hmp; subst mp.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      reflexivity.
    - do 2 right; left.
      apply andb_true_iff in Hv3f as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      exact (conj Hfid Efty).
    - do 3 right.
      apply andb_true_iff in Hv3s as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                     (tptr tvoid) cc_default)) as [Efty | ];
        [ | discriminate Hfty ].
      exact (conj Hfid Efty).
  Qed.

  (* ---- the pgqs gate: arg0 = Etempvar _m under the conditional marg,
     arg1 = Evar _intendedPos (the fn_var stack array, By_reference decay
     to its local_blk base) ---- *)
  Lemma pgs_mo_gate :
    forall e le m ipb ipty vargs,
      (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      e ! mario_step._intendedPos = Some (ipb, ipty) ->
      local_blk lp bm SafeB ipb ->
      eval_exprlist (lp_ge lp) e le m
        (Etempvar mario_step._m tyMSstp
           :: Evar mario_step._intendedPos (tarray tfloat 3) :: nil)
        (tyMSstp :: tptr tfloat :: nil) vargs ->
      mo_gate lp bm SafeB vargs.
  Proof.
    intros e le m ipb ipty vargs Hmarg Heip Hiploc Hvl.
    inv Hvl.
    match goal with H : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv H end.
    match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar _ _) ?v0 |- _ =>
        apply RealFrameValue.eval_expr_Etempvar_val in He
    end.
    match goal with
    | He : le ! mario_step._m = Some ?v0,
      Hc : sem_cast ?v0 _ _ _ = Some ?vc |- _ =>
        assert (Hv0 : forall b o, vc = Vptr b o -> b = bm /\ o = Ptrofs.zero)
          by (intros b o Heqvc; rewrite Heqvc in Hc; cbn in Hc;
              destruct v0 as [| ? | ? | ? | ? | b1 o1 ]; cbn in Hc;
              try discriminate Hc;
              injection Hc as Hb Ho; subst b1 o1; exact (Hmarg b o He))
    end.
    match goal with
    | He : eval_expr _ _ _ _ (Evar _ _) ?v1 |- _ => inv He
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end;
    [ | match goal with
        | Hn : e ! mario_step._intendedPos = None |- _ =>
            rewrite Heip in Hn; discriminate Hn
        end ].
    match goal with
    | He : e ! mario_step._intendedPos = Some (?loc, _) |- _ =>
        assert (loc = ipb) by congruence; subst loc
    end.
    match goal with
    | Hd : deref_loc _ _ ipb _ _ _ |- _ =>
        cbn [typeof] in Hd; inv Hd;
        try (match goal with
             | Hac : access_mode _ = By_value _ |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hac : access_mode _ = By_copy |- _ =>
                 cbn in Hac; discriminate Hac
             end);
        try (match goal with
             | Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb
             end)
    end.
    match goal with
    | Hc : sem_cast (Vptr ipb _) _ _ _ = Some _ |- _ =>
        cbn in Hc; injection Hc as <-
    end.
    split.
    - cbn [arg0_marg]. exact Hv0.
    - red. cbn [last_val]. exists ipb, Ptrofs.zero.
      split; [ reflexivity | exact Hiploc ].
  Qed.

  (* ---- the general-env marg internal-call brick: `optid := f(m)` at an
     env e with fid unbound (kit_scall_pres is empty-env-only). ---- *)
  Lemma cp_scall_pres :
    forall optid fid rty cc e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction (tyMSstp :: nil) rty cc))
           (Etempvar mario_step._m tyMSstp :: nil))
        tr le1 m1 out0 ->
      call_pres lp bm NoA MWF fid ->
      (forall b o, le0 ! mario_step._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid rty cc e le0 m0 tr le1 m1 out0 He Hexec Hcp Htat Hc.
    destruct Hc as (HV & HS & HM & HN).
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv)
          as (bf & Hsym & ->)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ => inv Hvl
    end.
    match goal with
    | Hl : eval_exprlist _ _ _ _ nil _ _ |- _ => inv Hl
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
        apply RealFrameValue.eval_expr_Etempvar_val in Hv; rename Hv into Hv1
    end.
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    match goal with
    | Hv1' : le0 ! _ = Some ?vv |- _ =>
        assert (Hmarg : marg_ok bm (vv :: nil))
          by (destruct vv; cbn; try exact I; exact (Htat _ _ Hv1'))
    end.
    match goal with
    | Hevf : eval_funcall _ _ _ _ (_ :: nil) _ _ _,
      Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some _ |- _ =>
        destruct (Hcp _ _ _ _ _ _ Hevf
                    ltac:(red; exists bf; split; assumption)
                    Hmarg HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
  Qed.

  (* ==================================================================== *)
  (* THE WALKER: any pgs_chk-passing statement, executed at an env where  *)
  (* _intendedPos is the fn_var stack array (local_blk) and the 4 callees *)
  (* are unbound, preserves carried under the conditional _m marg fact -- *)
  (* WHATEVER its outcome.  Sloop by IH (loop-tolerant, the wind shape).  *)
  (* ==================================================================== *)
  Lemma pgs_walk_pres :
    forall ipb ipty,
      local_blk lp bm SafeB ipb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        pgs_chk s = true ->
        e ! mario_step._perform_ground_quarter_step = None ->
        e ! mario_step._mario_get_terrain_sound_addend = None ->
        e ! mario_step._vec3f_copy = None ->
        e ! mario_step._vec3s_set = None ->
        e ! mario_step._intendedPos = Some (ipb, ipty) ->
        (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
  Proof.
    intros ipb ipty Hiploc s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign a1 a2 *)
      cbn [pgs_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (pgs_assign_decode _ Hchk) as [Hsf | (idxN & ->)].
      + (* marg Mario-field store: value-blind epi *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* intendedPos[i] indexed fn_var local store *)
        destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e mario_step._intendedPos tfloat 3%Z noattr
                    idxN (tptr tfloat) tfloat a2 le m E0 le m' Out_normal
                    ipb ipty Mfloat32 Hip Hiploc eq_refl Hex Hc)
          as (Hc' & _ & _).
        exact (conj Hc' Hm).
    - (* Sset id a: id <> _m (pgs_optid_ok) *)
      cbn [pgs_chk pgs_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id; rewrite Pos.eqb_refl in Hchk;
                                  discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall optid a al *)
      cbn [pgs_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t (set_opttemp optid vres le)
                      m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! mario_step._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [pgs_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt). exact (Hm b o Hg).
        - exact Hm. }
      destruct (pgs_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & Haleq)
           | [ (Hfeq & Hftyeq & Haleq)
             | [ (Hfeq & Hftyeq) | (Hfeq & Hftyeq) ] ] ];
        subst fid fty.
      + (* perform_ground_quarter_step(m, intendedPos): the mo helper *)
        subst al.
        destruct (mo_scall_pres lp bm NoA MWF SafeB optid
                    mario_step._perform_ground_quarter_step
                    (tyMSstp :: tptr tfloat :: nil) tint cc_default
                    (Etempvar mario_step._m tyMSstp
                       :: Evar mario_step._intendedPos (tarray tfloat 3) :: nil)
                    e le m _ _ m' _ Hpgqs Hcp_pgqs
                    ltac:(intros vargs1 Hvl;
                          exact (pgs_mo_gate _ _ _ _ _ _ Hm Hip Hiploc Hvl))
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* mario_get_terrain_sound_addend(m): the marg internal *)
        subst al.
        destruct (cp_scall_pres optid mario_step._mario_get_terrain_sound_addend
                    tuint cc_default e le m _ _ m' _
                    Hmgtsa Hex Hcp_mgtsa Hm Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* vec3f_copy: ungated obj_ext external *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid mario_step._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    al e le m _ _ m' _ Hv3f Hex Hcpx_v3f HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
      + (* vec3s_set: ungated obj_ext external *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid mario_step._vec3s_set
                    (tptr tshort :: tshort :: tshort :: tshort :: nil)
                    (tptr tvoid) cc_default
                    al e le m _ _ m' _ Hv3s Hex Hcpx_v3s HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin: rejected *)
      cbn [pgs_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pgs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [pgs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc).
    - (* Sifthenelse *)
      cbn [pgs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1 *)
      cbn [pgs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc).
    - (* Sloop stop2 *)
      cbn [pgs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm1 Hc1).
    - (* Sloop loop *)
      cbn [pgs_chk] in Hchk.
      pose proof Hchk as Hchk0.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm Hc) as (Hc1 & Hm1).
      destruct (IHHexec2 H2 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm1 Hc1) as (Hc2 & Hm2).
      exact (IHHexec3 Hchk0 Hpgqs Hmgtsa Hv3f Hv3s Hip Hm2 Hc2).
    - (* Sswitch: rejected *)
      cbn [pgs_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE ENTRY LEMMA: pgs's whole body preserves the carried facts under  *)
  (* the marg gate.  function_entry2 allocs _intendedPos and binds _m;    *)
  (* marg_ok gives the _m conditional; alloc_variables_hlocal gives the   *)
  (* _intendedPos locality; pgs_walk_pres walks; free at exit.            *)
  (* ==================================================================== *)
  Lemma pgs_body_pres :
    body_pres lp NoA MWF bm mario_step.f_perform_ground_step.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    assert (Hmarg : marg_ok bm vargs0)
      by (apply Hgate; vm_compute; reflexivity).
    (* ---- entry ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario_step.f_perform_ground_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _intendedPos fn_var is a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._intendedPos :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hlids.
    destruct (Hlids mario_step._intendedPos eq_refl)
      as (ipb & ipty & Hip & Hiploc).
    (* bind the 1 param _m *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_step._m = Some v_m)
      by (rewrite <- Hle_init; apply PTree.gss).
    (* _m conditional from marg_ok *)
    assert (Hmcond : forall b o,
               le1 ! mario_step._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 4 callees are unbound globals in the entry env *)
    assert (Hpgqs_none :
              eloc ! mario_step._perform_ground_quarter_step = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._perform_ground_quarter_step)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hmgtsa_none :
              eloc ! mario_step._mario_get_terrain_sound_addend = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._mario_get_terrain_sound_addend)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3f_none : eloc ! mario_step._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_copy)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hv3s_none : eloc ! mario_step._vec3s_set = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3s_set)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (pgs_walk_pres ipb ipty Hiploc _ _ _ _ _ _ _ _
                Hbody pgs_chk_body Hpgqs_none Hmgtsa_none Hv3f_none Hv3s_none
                Hip Hmcond Hcar)
      as (Hcarr & _).
    (* ---- exit: free the fn_var stack block ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE *)
  Lemma pgs_cp :
    call_pres lp bm NoA MWF mario_step._perform_ground_step.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario_step.prog
             mario_step._perform_ground_step mario_step.f_perform_ground_step
             LO_stp pgs_pin pgs_body_pres).
  Qed.

End PgsSurface.

(* ====================================================================== *)
(* ===================  perform_ground_quarter_step  ==================== *)
(* The mo-gated worker behind pgs (mario_step.v:1912, 363 lines):         *)
(* straight-line, 6 early returns, callees resolve_and_return_wall_       *)
(* collisions (ol) / find_floor + vec3f_find_ceil (oc, &fn_var locals) /  *)
(* find_water_level + atan2s (terminal externals) / vec3f_copy +          *)
(* vec3f_set (w1, dst = m->pos window).  Plus ONE special site the        *)
(* walker abstraction cannot see: the gWaterSurfacePseudoFloor patch      *)
(* (store the static Surface's ADDRESS into the local _floor, reload,     *)
(* store floorHeight through it into the GLOBAL's originOffset) --        *)
(* handled by an exact-shape recognizer + a bespoke load-after-store      *)
(* brick riding the stored_globals census row (gwspf_site_pres).          *)
(* ====================================================================== *)

Definition tSurfp : type := tptr (Tstruct mario_step._Surface noattr).

Lemma pgqs_pin :
  (prog_defmap mario_step.prog) ! mario_step._perform_ground_quarter_step
  = Some (Gfun (Internal mario_step.f_perform_ground_quarter_step)).
Proof. vm_compute. reflexivity. Qed.

(* Val.load_result is the identity on pointers at Mptr (ptr32). *)
Lemma load_result_mptr_ptr :
  forall b o, Val.load_result Mptr (Vptr b o) = Vptr b o.
Proof.
  intros b o.
  assert (Hp64 : Archi.ptr64 = false) by (vm_compute; reflexivity).
  unfold Mptr. rewrite Hp64. cbn [Val.load_result]. rewrite Hp64. reflexivity.
Qed.

(* ====================================================================== *)
(* recognizers (validated in probe stage 1)                               *)
(* ====================================================================== *)
Definition gwspf_site_chk (s : statement) : bool :=
  match s with
  | Ssequence
      (Sassign (Evar fl1 tps1)
         (Eaddrof (Evar gw (Tstruct sid sa)) tps2))
      (Ssequence
         (Sset t19a (Evar fl2 tps3))
         (Sassign
            (Efield (Ederef (Etempvar t19b tps4) (Tstruct sid2 sa2))
               oo tfo)
            (Etempvar fh tfh))) =>
      Pos.eqb fl1 mario_step._floor
      && Pos.eqb fl2 mario_step._floor
      && Pos.eqb gw mario_step._gWaterSurfacePseudoFloor
      && Pos.eqb t19a mario_step._t'19
      && Pos.eqb t19b mario_step._t'19
      && Pos.eqb oo mario_step._originOffset
      && Pos.eqb fh mario_step._floorHeight
      && proj_sumbool
           (type_eq (Tstruct sid sa) (Tstruct mario_step._Surface noattr))
      && proj_sumbool
           (type_eq (Tstruct sid2 sa2) (Tstruct mario_step._Surface noattr))
      && proj_sumbool (type_eq tps1 tSurfp)
      && proj_sumbool (type_eq tps2 tSurfp)
      && proj_sumbool (type_eq tps3 tSurfp)
      && proj_sumbool (type_eq tps4 tSurfp)
      && proj_sumbool (type_eq tfo tfloat)
      && proj_sumbool (type_eq tfh tfloat)
  | _ => false
  end.

Definition pgqs_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid mario_step._resolve_and_return_wall_collisions
   && proj_sumbool
        (type_eq fty
           (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
              tSurfp cc_default))
   && match al with
      | Etempvar q tq :: Econst_single _ _ :: Econst_single _ _ :: nil =>
          Pos.eqb q mario_step._nextPos
          && proj_sumbool (type_eq tq (tptr tfloat))
      | _ => false
      end)
  || oc_call_chk
       (mario_step._floor :: mario_step._ceil :: nil)
       (mario_step._find_floor :: mario_step._vec3f_find_ceil :: nil)
       fid fty al
  || (Pos.eqb fid mario_step._find_water_level
      && proj_sumbool
           (type_eq fty
              (Tfunction (tfloat :: tfloat :: nil) tfloat cc_default)))
  || ((Pos.eqb fid mario_step._vec3f_copy
       && proj_sumbool
            (type_eq fty
               (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default))
      || Pos.eqb fid mario_step._vec3f_set
         && proj_sumbool
              (type_eq fty
                 (Tfunction (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                    (tptr tvoid) cc_default)))
      && match al with
         | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa :: _ =>
             Pos.eqb mp mario_step._m
             && Pos.eqb fld mario_step._pos
             && proj_sumbool
                  (type_eq tmp (tptr (Tstruct mario_step._MarioState noattr)))
             && proj_sumbool
                  (type_eq tsm (Tstruct mario_step._MarioState noattr))
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
         | _ => false
         end)
  || (Pos.eqb fid mario_step._atan2s
      && proj_sumbool
           (type_eq fty
              (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))).

Definition pgqs_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id mario_step._m)
               && negb (Pos.eqb id mario_step._nextPos)
  | None => true
  end.

Fixpoint pgqs_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 =>
      gwspf_site_chk (Ssequence s1 s2) || (pgqs_chk s1 && pgqs_chk s2)
  | Sifthenelse _ s1 s2 => pgqs_chk s1 && pgqs_chk s2
  | Sset id _ => pgqs_optid_ok (Some id)
  | Sassign a1 _ => safe_mfield_store mario_step._m a1
  | Scall optid (Evar fid fty) al =>
      pgqs_optid_ok optid && pgqs_call_chk fid fty al
  | _ => false
  end.

Lemma pgqs_chk_body :
  pgqs_chk (fn_body mario_step.f_perform_ground_quarter_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* the rows                                                               *)
(* ====================================================================== *)
Section PgqsSurface.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_stp : linkorder mario_step.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.
  Variable SafeB : block -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_alloc : forall m lo hi m' b,
      Mem.alloc m lo hi = (m', b) -> MWF m -> MWF m'.
  Hypothesis HMWF_free : forall m l m',
      Mem.free_list m l = Some m' -> MWF m -> MWF m'.
  Hypothesis HSafeValid :
    forall m, MWF m -> forall b, SafeB b -> Mem.valid_block m b.
  Hypothesis HGlobValid :
    forall m, MWF m -> forall gid bg,
        Genv.find_symbol (lp_ge lp) gid = Some bg -> Mem.valid_block m bg.
  Hypothesis Hls_real :
    forall m ch b (d : Z) v m',
      local_blk lp bm SafeB b ->
      Mem.store ch m b d v = Some m' -> MWF m -> MWF m'.
  (* the gWaterSurfacePseudoFloor store row (mwf_real_glob's conclusion
     shape at this single gid; discharged at the capstone after the
     stored_globals census gains the symbol). *)
  Hypothesis Hglob_gwspf :
    forall bg,
      Genv.find_symbol (lp_ge lp) mario_step._gWaterSurfacePseudoFloor
        = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').

  (* the callee rows *)
  Hypothesis Hocp_resolve :
    call_pres_ext_ol lp bm NoA MWF SafeB
      mario_step._resolve_and_return_wall_collisions.
  Hypothesis Hocp_ff :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_step._find_floor.
  Hypothesis Hocp_vfc :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_step._vec3f_find_ceil.
  Hypothesis Hxcp_fwl :
    call_pres_ext lp bm NoA MWF mario_step._find_water_level.
  Hypothesis Hw1cp_v3f :
    call_pres_ext_w1 lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hw1cp_v3fset :
    call_pres_ext_w1 lp bm NoA MWF mario_step._vec3f_set.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF mario_step._atan2s.

  (* ---- decoders ---- *)
  Lemma gwspf_site_decode :
    forall s, gwspf_site_chk s = true ->
      s = Ssequence
            (Sassign (Evar mario_step._floor tSurfp)
               (Eaddrof
                  (Evar mario_step._gWaterSurfacePseudoFloor
                     (Tstruct mario_step._Surface noattr)) tSurfp))
            (Ssequence
               (Sset mario_step._t'19 (Evar mario_step._floor tSurfp))
               (Sassign
                  (Efield
                     (Ederef (Etempvar mario_step._t'19 tSurfp)
                        (Tstruct mario_step._Surface noattr))
                     mario_step._originOffset tfloat)
                  (Etempvar mario_step._floorHeight tfloat))).
  Proof.
    intros s H.
    destruct s as [ | | | | | s1 s2 | | | | | | | | ]; try discriminate H.
    destruct s1 as [ | a1 a2 | | | | | | | | | | | | ]; try discriminate H.
    destruct a1 as [ | | | | fl1 tps1 | | | | | | | | | ]; try discriminate H.
    destruct a2 as [ | | | | | | | inner tps2 | | | | | | ]; try discriminate H.
    destruct inner as [ | | | | gw gwt | | | | | | | | | ]; try discriminate H.
    destruct gwt as [ | | | | | | | sid sa | ]; try discriminate H.
    destruct s2 as [ | | | | | s2a s2b | | | | | | | | ]; try discriminate H.
    destruct s2a as [ | | t19a ae | | | | | | | | | | | ]; try discriminate H.
    destruct ae as [ | | | | fl2 tps3 | | | | | | | | | ]; try discriminate H.
    destruct s2b as [ | b1 b2 | | | | | | | | | | | | ]; try discriminate H.
    destruct b1 as [ | | | | | | | | | | | ef1 oo tfo | | ]; try discriminate H.
    destruct ef1 as [ | | | | | | edb edt | | | | | | | ]; try discriminate H.
    destruct edb as [ | | | | | t19b tps4 | | | | | | | | ]; try discriminate H.
    destruct edt as [ | | | | | | | sid2 sa2 | ]; try discriminate H.
    destruct b2 as [ | | | | | fh tfh | | | | | | | | ]; try discriminate H.
    cbn [gwspf_site_chk] in H.
    apply andb_true_iff in H as [H Htfh].
    apply andb_true_iff in H as [H Htfo].
    apply andb_true_iff in H as [H Htps4].
    apply andb_true_iff in H as [H Htps3].
    apply andb_true_iff in H as [H Htps2].
    apply andb_true_iff in H as [H Htps1].
    apply andb_true_iff in H as [H Hsid2].
    apply andb_true_iff in H as [H Hsid].
    apply andb_true_iff in H as [H Hfh].
    apply andb_true_iff in H as [H Hoo].
    apply andb_true_iff in H as [H Ht19b].
    apply andb_true_iff in H as [H Ht19a].
    apply andb_true_iff in H as [H Hgw].
    apply andb_true_iff in H as [Hfl1 Hfl2].
    apply Pos.eqb_eq in Hfl1; subst fl1.
    apply Pos.eqb_eq in Hfl2; subst fl2.
    apply Pos.eqb_eq in Hgw; subst gw.
    apply Pos.eqb_eq in Ht19a; subst t19a.
    apply Pos.eqb_eq in Ht19b; subst t19b.
    apply Pos.eqb_eq in Hoo; subst oo.
    apply Pos.eqb_eq in Hfh; subst fh.
    destruct (type_eq (Tstruct sid sa) (Tstruct mario_step._Surface noattr))
      as [Es | ]; [ injection Es as -> -> | discriminate Hsid ].
    destruct (type_eq (Tstruct sid2 sa2) (Tstruct mario_step._Surface noattr))
      as [Es2 | ]; [ injection Es2 as -> -> | discriminate Hsid2 ].
    destruct (type_eq tps1 tSurfp) as [-> | ]; [ | discriminate Htps1 ].
    destruct (type_eq tps2 tSurfp) as [-> | ]; [ | discriminate Htps2 ].
    destruct (type_eq tps3 tSurfp) as [-> | ]; [ | discriminate Htps3 ].
    destruct (type_eq tps4 tSurfp) as [-> | ]; [ | discriminate Htps4 ].
    destruct (type_eq tfo tfloat) as [-> | ]; [ | discriminate Htfo ].
    destruct (type_eq tfh tfloat) as [-> | ]; [ | discriminate Htfh ].
    reflexivity.
  Qed.

  Lemma pgqs_call_decode :
    forall fid fty al, pgqs_call_chk fid fty al = true ->
      (fid = mario_step._resolve_and_return_wall_collisions /\
       fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
               tSurfp cc_default /\
       exists c1 t1 c2 t2,
         al = Etempvar mario_step._nextPos (tptr tfloat)
              :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
      \/ oc_call_chk
           (mario_step._floor :: mario_step._ceil :: nil)
           (mario_step._find_floor :: mario_step._vec3f_find_ceil :: nil)
           fid fty al = true
      \/ (fid = mario_step._find_water_level /\
          fty = Tfunction (tfloat :: tfloat :: nil) tfloat cc_default)
      \/ (((fid = mario_step._vec3f_copy /\
            fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                    cc_default)
           \/ (fid = mario_step._vec3f_set /\
               fty = Tfunction
                       (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                       (tptr tvoid) cc_default)) /\
          exists rest,
            al = Efield
                   (Ederef (Etempvar mario_step._m
                              (tptr (Tstruct mario_step._MarioState noattr)))
                      (Tstruct mario_step._MarioState noattr))
                   mario_step._pos (tarray tfloat 3) :: rest)
      \/ (fid = mario_step._atan2s /\
          fty = Tfunction (tfloat :: tfloat :: nil) tshort cc_default).
  Proof.
    intros fid fty al H. unfold pgqs_call_chk in H.
    apply orb_true_iff in H as [H | Hat].
    apply orb_true_iff in H as [H | Hw1].
    apply orb_true_iff in H as [H | Hfwl].
    apply orb_true_iff in H as [Hres | Hoc].
    - left.
      apply andb_true_iff in Hres as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil)
                     tSurfp cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | q tq | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al2; try discriminate Hal.
      apply andb_true_iff in Hal as [Hq Htq].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq tq (tptr tfloat)) as [E | ];
        [ subst tq | discriminate Htq ].
      exists c1, t1, c2, t2. reflexivity.
    - right; left. exact Hoc.
    - do 2 right; left.
      apply andb_true_iff in Hfwl as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tfloat
                               cc_default)) as [Efty | ];
        [ | discriminate Hfty ].
      exact (conj Hfid Efty).
    - do 3 right; left.
      apply andb_true_iff in Hw1 as [Hfidty Hshape].
      split.
      + apply orb_true_iff in Hfidty as [Hcp | Hst].
        * left. apply andb_true_iff in Hcp as [Hfid Hfty].
          apply Pos.eqb_eq in Hfid.
          destruct (type_eq fty
                      (Tfunction (tptr tfloat :: tptr tfloat :: nil)
                         (tptr tvoid) cc_default)) as [Efty | ];
            [ | discriminate Hfty ].
          exact (conj Hfid Efty).
        * right. apply andb_true_iff in Hst as [Hfid Hfty].
          apply Pos.eqb_eq in Hfid.
          destruct (type_eq fty
                      (Tfunction (tptr tfloat :: tfloat :: tfloat :: tfloat
                                  :: nil) (tptr tvoid) cc_default))
            as [Efty | ]; [ | discriminate Hfty ].
          exact (conj Hfid Efty).
      + destruct al as [ | a0 rest ]; try discriminate Hshape.
        destruct a0 as [ | | | | | | | | | | | ef efd eft | | ];
          try discriminate Hshape.
        destruct ef as [ | | | | | | edb edt | | | | | | | ];
          try discriminate Hshape.
        destruct edb as [ | | | | | mp tmp | | | | | | | | ];
          try discriminate Hshape.
        apply andb_true_iff in Hshape as [Hshape Htfa].
        apply andb_true_iff in Hshape as [Hshape Htsm].
        apply andb_true_iff in Hshape as [Hshape Htmp].
        apply andb_true_iff in Hshape as [Hmp Hfld].
        apply Pos.eqb_eq in Hmp; subst mp.
        apply Pos.eqb_eq in Hfld; subst efd.
        destruct (type_eq tmp (tptr (Tstruct mario_step._MarioState noattr)))
          as [E1 | ]; [ subst tmp | discriminate Htmp ].
        destruct (type_eq edt (Tstruct mario_step._MarioState noattr))
          as [E2 | ]; [ subst edt | discriminate Htsm ].
        destruct (type_eq eft (tarray tfloat 3)) as [E3 | ];
          [ subst eft | discriminate Htfa ].
        exists rest. reflexivity.
    - do 4 right.
      apply andb_true_iff in Hat as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort
                               cc_default)) as [Efty | ];
        [ | discriminate Hfty ].
      exact (conj Hfid Efty).
  Qed.

  (* ==================================================================== *)
  (* THE SPECIAL-SITE BRICK: _floor := &gWaterSurfacePseudoFloor;          *)
  (* _t'19 := _floor; _t'19->originOffset := _floorHeight.                 *)
  (* The local store is frame-silent (local_blk); the reload pins _t'19    *)
  (* to the global's address (load-after-store); the final store lands in  *)
  (* the global block, covered by the gwspf store row.                     *)
  (* ==================================================================== *)
  Lemma gwspf_site_pres :
    forall e le m0 tr le' m' out flb flty,
      e ! mario_step._floor = Some (flb, flty) ->
      local_blk lp bm SafeB flb ->
      e ! mario_step._gWaterSurfacePseudoFloor = None ->
      exec_stmt function_entry2 (lp_ge lp) e le m0
        (Ssequence
           (Sassign (Evar mario_step._floor tSurfp)
              (Eaddrof
                 (Evar mario_step._gWaterSurfacePseudoFloor
                    (Tstruct mario_step._Surface noattr)) tSurfp))
           (Ssequence
              (Sset mario_step._t'19 (Evar mario_step._floor tSurfp))
              (Sassign
                 (Efield
                    (Ederef (Etempvar mario_step._t'19 tSurfp)
                       (Tstruct mario_step._Surface noattr))
                    mario_step._originOffset tfloat)
                 (Etempvar mario_step._floorHeight tfloat))))
        tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ out = Out_normal /\
      exists vt, le' = PTree.set mario_step._t'19 vt le.
  Proof.
    intros e le m0 tr le' m' out flb flty Hfl Hflloc Hgw Hexec Hc.
    inv Hexec.
    2:{ (* Sseq_2: the leading Sassign cannot abort *)
        match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Hs
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ =>
            contradiction Hne; reflexivity
        end. }
    (* ---- statement 1: the local ptr store ---- *)
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Hs
    end.
    (* lvalue (Evar _floor): the local case, block = flb *)
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar mario_step._floor _) _ _ _ |- _ =>
        inv Hlv
    end.
    2:{ match goal with
        | Hn : e ! mario_step._floor = None |- _ =>
            rewrite Hfl in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! mario_step._floor = Some _ |- _ =>
        rewrite Hfl in Hb; injection Hb as <- _
    end.
    (* rvalue (Eaddrof (Evar gwspf)): the global's address *)
    match goal with
    | Hev : eval_expr _ _ _ _ (Eaddrof _ _) _ |- _ => inv Hev
    end.
    2:{ match goal with
        | Hlv : eval_lvalue _ _ _ _ (Eaddrof _ _) _ _ _ |- _ => inv Hlv
        end. }
    match goal with
    | Hlv : eval_lvalue _ _ _ _
              (Evar mario_step._gWaterSurfacePseudoFloor _) _ _ _ |- _ =>
        inv Hlv
    end.
    { match goal with
      | Hb : e ! mario_step._gWaterSurfacePseudoFloor = Some _ |- _ =>
          rewrite Hgw in Hb; discriminate Hb
      end. }
    match goal with
    | Hsym0 : Genv.find_symbol _ mario_step._gWaterSurfacePseudoFloor
              = Some ?g |- _ => rename Hsym0 into Hsym; rename g into gb
    end.
    destruct (Hglob_gwspf gb Hsym) as (Hgb_bm & Hgb_store).
    (* the cast keeps the pointer *)
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
    (* the assign is a By_value Mptr store into the local block *)
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Has; inv Has
    end.
    2:{ match goal with
        | Hac : access_mode _ = By_copy |- _ =>
            cbn in Hac; discriminate Hac
        end. }
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ _ _ = Some _ |- _ =>
        unfold Mem.storev in Hsv;
        rewrite Ptrofs.unsigned_zero in Hsv;
        rename Hsv into Hst1
    end.
    assert (Hc1 : carried bm NoA MWF m1)
      by (eapply (localstore_carried lp bm NoA MWF SafeB Hls_real HNoA_of_MWF);
          [ exact Hflloc | exact Hst1 | exact Hc ]).
    pose proof (Mem.load_store_same _ _ _ _ _ _ Hst1) as Hload1.
    rewrite load_result_mptr_ptr in Hload1.
    (* ---- statements 2+3 ---- *)
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Ssequence _ _) _ _ _ _ |- _ => inv Hs
    end.
    2:{ match goal with
        | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
        end.
        match goal with
        | Hne : Out_normal <> Out_normal |- _ =>
            contradiction Hne; reflexivity
        end. }
    (* statement 2: _t'19 := _floor (reload of the just-stored address) *)
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Sset _ _) _ _ _ _ |- _ => inv Hs
    end.
    match goal with
    | Hev : eval_expr _ _ _ _ (Evar mario_step._floor _) _ |- _ => inv Hev
    end.
    match goal with
    | Hlv2 : eval_lvalue _ _ _ _ (Evar mario_step._floor _) _ _ _ |- _ =>
        inv Hlv2
    end.
    2:{ match goal with
        | Hn : e ! mario_step._floor = None |- _ =>
            rewrite Hfl in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! mario_step._floor = Some _ |- _ =>
        rewrite Hfl in Hb; injection Hb as <- _
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ => cbn [typeof] in Hd
    end.
    match goal with
    | Hd : deref_loc _ _ flb _ _ _ |- _ => inv Hd
    end.
    2:{ match goal with
        | Hac : access_mode _ = By_reference |- _ =>
            cbn in Hac; discriminate Hac
        end. }
    2:{ match goal with
        | Hac : access_mode _ = By_copy |- _ =>
            cbn in Hac; discriminate Hac
        end. }
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hldv : Mem.loadv _ _ _ = Some _ |- _ =>
        unfold Mem.loadv in Hldv;
        rewrite Ptrofs.unsigned_zero in Hldv;
        rewrite Hload1 in Hldv; injection Hldv as <-
    end.
    (* statement 3: the store through _t'19 into the GLOBAL block *)
    match goal with
    | Hs : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ _ |- _ => inv Hs
    end.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ =>
        pose proof Hlv as Hpin;
        apply RealFrameValue.eval_lvalue_Efield_base in Hpin;
        destruct Hpin as (o0 & Hbase)
    end.
    destruct (RealFrameValue.eval_expr_Ederef_load _ _ _ _ _ _ _ Hbase)
      as (lb & ob & bfb & Hlvb & Hderefb).
    pose proof (RealFrameValue.deref_loc_aggregate_block
                  (Tstruct mario_step._Surface noattr) _ _ _ _ _ _
                  (or_intror eq_refl) Hderefb) as Hblk.
    apply RealFrameValue.eval_lvalue_Ederef_base in Hlvb.
    apply RealFrameValue.eval_expr_Etempvar_val in Hlvb.
    rewrite PTree.gss in Hlvb. injection Hlvb as <- <-.
    match goal with
    | Has : assign_loc _ (typeof _) _ _ _ _ _ _ |- _ =>
        cbn [typeof] in Has; rewrite Hblk in Has; inv Has
    end.
    2:{ match goal with
        | Hac : access_mode _ = By_copy |- _ =>
            cbn in Hac; discriminate Hac
        end. }
    2:{ match goal with
        | Hsb : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv Hsb
        end. }
    match goal with
    | Hac : access_mode _ = By_value _ |- _ =>
        cbn in Hac; injection Hac as <-
    end.
    match goal with
    | Hsv : Mem.storev _ _ (Vptr gb _) _ = Some _ |- _ =>
        unfold Mem.storev in Hsv; rename Hsv into Hst3
    end.
    destruct Hc1 as (HV1 & HS1 & HM1 & HN1).
    assert (HM' : MWF m') by (eapply Hgb_store; [ exact HM1 | exact Hst3 ]).
    refine (conj _ (conj eq_refl _));
      [ split;
        [ eapply Mem.store_valid_block_1; eauto
        | split;
          [ eapply (LocalVarsSurface.store_action_sat bm);
            [ exact Hst3 | exact Hgb_bm | exact HS1 ]
          | split; [ exact HM' | exact (HNoA_of_MWF _ HM') ] ] ]
      | eexists; reflexivity ].
  Qed.


  (* ==================================================================== *)
  (* THE WALKER: exec-derivation induction over pgqs_chk-accepted         *)
  (* statements, carrying the conditional _m marg + the _nextPos local    *)
  (* out-param binding (php_walk_pres shape) + the gwspf special site.    *)
  (* ==================================================================== *)
  Lemma pgqs_walk_pres :
    forall npb npo,
      local_blk lp bm SafeB npb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        pgqs_chk s = true ->
        e ! mario_step._resolve_and_return_wall_collisions = None ->
        e ! mario_step._find_floor = None ->
        e ! mario_step._vec3f_find_ceil = None ->
        e ! mario_step._find_water_level = None ->
        e ! mario_step._vec3f_copy = None ->
        e ! mario_step._vec3f_set = None ->
        e ! mario_step._atan2s = None ->
        e ! mario_step._gWaterSurfacePseudoFloor = None ->
        (forall l, mem_id l (mario_step._floor :: mario_step._ceil :: nil)
                   = true ->
           exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                              local_blk lp bm SafeB lblk) ->
        (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        le ! mario_step._nextPos = Some (Vptr npb npo) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        le' ! mario_step._nextPos = Some (Vptr npb npo).
  Proof.
    intros npb npo Hnploc s e le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hchk Hrn Hff Hvfc Hfwl Hvc Hvs Hat Hgw Hlids Hm Hnp Hc.
    - (* Sskip *) exact (conj Hc (conj Hm Hnp)).
    - (* Sassign a1 a2: safe Mario-field store, value-blind epi *)
      cbn [pgqs_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct Hc as (HV & HS & HM & HN).
      destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                  a1 a2 _ _ _ _ _ _ _ Hchk Hm Hex HM HV HS)
        as (HV' & HS' & HM' & _ & _).
      exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
               (conj Hm Hnp)).
    - (* Sset id a: id <> _m, _nextPos (pgqs_optid_ok) *)
      cbn [pgqs_chk pgqs_optid_ok] in Hchk.
      apply andb_true_iff in Hchk as [Hnm Hnnp].
      apply negb_true_iff in Hnm; apply negb_true_iff in Hnnp.
      refine (conj Hc (conj _ _)).
      + intros b o Hg.
        rewrite PTree.gso in Hg by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnm; discriminate Hnm).
        exact (Hm b o Hg).
      + rewrite PTree.gso by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnnp; discriminate Hnnp).
        exact Hnp.
    - (* Scall optid a al *)
      cbn [pgqs_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ];
        try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t
                      (set_opttemp optid vres le) m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : (forall b o,
                       (set_opttemp optid vres le) ! mario_step._m
                       = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero) /\
                    (set_opttemp optid vres le) ! mario_step._nextPos
                    = Some (Vptr npb npo)).
      { cbn [pgqs_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [Hom Honp].
          apply negb_true_iff in Hom; apply negb_true_iff in Honp.
          split.
          + intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hom; discriminate Hom). exact (Hm b o Hg).
          + rewrite PTree.gso by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Honp; discriminate Honp). exact Hnp.
        - split; [ exact Hm | exact Hnp ]. }
      destruct (pgqs_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & (c1 & t1c & c2 & t2c & Haleq))
           | [ Hoc
             | [ (Hfeq & Hftyeq)
               | [ ([ (Hfeq & Hftyeq) | (Hfeq & Hftyeq) ] & (rest & Haleq))
                 | (Hfeq & Hftyeq) ] ] ] ].
      + (* ol: resolve_and_return_wall_collisions(nextPos, c1, c2) *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Etempvar mario_step._nextPos (tptr tfloat)
               :: Econst_single c1 t1c :: Econst_single c2 t2c :: nil)
              (tptr tfloat :: tfloat :: tfloat :: nil) vargs ->
            args_all_local lp bm SafeB vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2 as [ | a3 bl3 ty3 tyl3 v1c v2c vl3 Hev_c Hsc_c Htl3 ];
            subst; clear Htl2.
          inversion Htl3; subst; clear Htl3.
          apply RealFrameValue.eval_expr_Etempvar_val in Hev_a;
            rewrite Hnp in Hev_a; injection Hev_a as <-.
          apply eval_Econst_single_val in Hev_b; subst v1b.
          apply eval_Econst_single_val in Hev_c; subst v1c.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | [E | []]]]; subst;
          [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
            injection Hsc_a as <- <-; exact Hnploc
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
            discriminate Hsc_b
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_c;
            discriminate Hsc_c ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                    mario_step._resolve_and_return_wall_collisions
                    (tptr tfloat :: tfloat :: tfloat :: nil)
                    tSurfp cc_default
                    (Etempvar mario_step._nextPos (tptr tfloat)
                     :: Econst_single c1 t1c :: Econst_single c2 t2c :: nil)
                    e le m _ _ m' _ Hrn Hocp_resolve Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* oc: find_floor / vec3f_find_ceil (out-param = &local) *)
        assert (Hcp_oc : forall g,
                  mem_id g (mario_step._find_floor
                            :: mario_step._vec3f_find_ceil :: nil) = true ->
                  call_pres_ext_oc lp bm NoA MWF SafeB g).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_ff | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_vfc
            | discriminate F ]. }
        assert (Hnone : forall g,
                  mem_id g (mario_step._find_floor
                            :: mario_step._vec3f_find_ceil :: nil) = true ->
                  e ! g = None).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | Hg];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hff | ].
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hvfc | discriminate F ]. }
        destruct (oc_call_chk_pres lp bm NoA MWF SafeB
                    (mario_step._floor :: mario_step._ceil :: nil)
                    (mario_step._find_floor
                       :: mario_step._vec3f_find_ceil :: nil)
                    optid fid fty al e le m _ _ m' _
                    Hcp_oc Hnone Hlids Hoc Hex Hc) as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* find_water_level: ungated terminal external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid
                    mario_step._find_water_level
                    (tfloat :: tfloat :: nil) tfloat cc_default
                    al e le m _ _ m' _ Hfwl Hex Hxcp_fwl HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN')))
                 (conj (proj1 HmL) (proj2 HmL))).
      + (* w1: vec3f_copy(m->pos, nextPos), dst = m->pos window *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield
                 (Ederef (Etempvar mario_step._m
                            (tptr (Tstruct mario_step._MarioState noattr)))
                    (Tstruct mario_step._MarioState noattr))
                 mario_step._pos (tarray tfloat 3) :: rest)
              (tptr tfloat :: tptr tfloat :: nil) vargs ->
            arg0_window bm vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (pos_window_val lp LO_mario bm _ _ _ _ Hm Hev_a)
            as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (w1_scall_pres lp bm NoA MWF optid mario_step._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                    cc_default
                    (Efield
                       (Ederef (Etempvar mario_step._m
                                  (tptr (Tstruct mario_step._MarioState noattr)))
                          (Tstruct mario_step._MarioState noattr))
                       mario_step._pos (tarray tfloat 3) :: rest)
                    e le m _ _ m' _ Hvc Hw1cp_v3f Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* w1: vec3f_set(m->pos, x, y, z), dst = m->pos window *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield
                 (Ederef (Etempvar mario_step._m
                            (tptr (Tstruct mario_step._MarioState noattr)))
                    (Tstruct mario_step._MarioState noattr))
                 mario_step._pos (tarray tfloat 3) :: rest)
              (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil) vargs ->
            arg0_window bm vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          destruct (pos_window_val lp LO_mario bm _ _ _ _ Hm Hev_a)
            as (o0 & Ev0 & Hwin0).
          subst v1a. cbn in Hsc_a. injection Hsc_a as <-.
          red. exists o0, vl1. split; [ reflexivity | exact Hwin0 ]. }
        destruct (w1_scall_pres lp bm NoA MWF optid mario_step._vec3f_set
                    (tptr tfloat :: tfloat :: tfloat :: tfloat :: nil)
                    (tptr tvoid) cc_default
                    (Efield
                       (Ederef (Etempvar mario_step._m
                                  (tptr (Tstruct mario_step._MarioState noattr)))
                          (Tstruct mario_step._MarioState noattr))
                       mario_step._pos (tarray tfloat 3) :: rest)
                    e le m _ _ m' _ Hvs Hw1cp_v3fset Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* atan2s: ungated pure-math external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid mario_step._atan2s
                    (tfloat :: tfloat :: nil) tshort cc_default
                    al e le m _ _ m' _ Hat Hex Hcpx_atan2s HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN')))
                 (conj (proj1 HmL) (proj2 HmL))).
    - (* Sbuiltin: rejected *)
      cbn [pgqs_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pgqs_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hsite | Hchk].
      + (* the gwspf special site *)
        apply gwspf_site_decode in Hsite.
        injection Hsite as Es1 Es2; subst s1 s2.
        destruct (Hlids mario_step._floor eq_refl)
          as (flb & flty & Hfl & Hflloc).
        match goal with
        | H1 : exec_stmt _ _ _ _ _ _ _ ?le1 ?m1 Out_normal,
          H2 : exec_stmt _ _ _ ?le1 ?m1 _ _ _ _ _ |- _ =>
            pose proof (exec_Sseq_1 function_entry2 (lp_ge lp)
                          _ _ _ _ _ _ _ _ _ _ _ _ H1 H2) as Hexs
        end.
        destruct (gwspf_site_pres _ _ _ _ _ _ _ _ _
                    Hfl Hflloc Hgw Hexs Hc)
          as (Hc' & _ & (vt & Hle')).
        rewrite Hle'.
        refine (conj Hc' (conj _ _)).
        * intros b o Hg.
          rewrite PTree.gso in Hg by (vm_compute; discriminate).
          exact (Hm b o Hg).
        * rewrite PTree.gso by (vm_compute; discriminate). exact Hnp.
      + apply andb_true_iff in Hchk as [H1 H2].
        destruct (IHHexec1 H1 Hrn Hff Hvfc Hfwl Hvc Hvs Hat Hgw Hlids
                    Hm Hnp Hc) as (Hc1 & Hm1 & Hnp1).
        exact (IHHexec2 H2 Hrn Hff Hvfc Hfwl Hvc Hvs Hat Hgw Hlids
                 Hm1 Hnp1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [pgqs_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hsite | Hchk].
      + (* site's s1 is an Sassign: it cannot abort *)
        apply gwspf_site_decode in Hsite.
        injection Hsite as Es1 Es2; subst s1 s2.
        match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ ?o,
          Hne : ?o <> Out_normal |- _ =>
            inv H1; exact (False_ind _ (Hne eq_refl))
        end.
      + apply andb_true_iff in Hchk as [H1 _].
        exact (IHHexec H1 Hrn Hff Hvfc Hfwl Hvc Hvs Hat Hgw Hlids Hm Hnp Hc).
    - (* Sifthenelse *)
      cbn [pgqs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc (conj Hm Hnp)).
    - (* Sreturn (Some _) *) exact (conj Hc (conj Hm Hnp)).
    - (* Sbreak *) exact (conj Hc (conj Hm Hnp)).
    - (* Scontinue *) exact (conj Hc (conj Hm Hnp)).
    - (* Sloop stop1: rejected *)
      cbn [pgqs_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [pgqs_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [pgqs_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [pgqs_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE ENTRY LEMMA: pgqs's whole body preserves carried under the mo    *)
  (* gate.  function_entry2 allocs _ceil/_floor and binds _m/_nextPos;    *)
  (* arg0_marg gives the _m conditional, last_arg_local the _nextPos      *)
  (* local out-param; alloc_variables_hlocal gives the _floor/_ceil       *)
  (* locality; the 7 callees + gWaterSurfacePseudoFloor are unbound       *)
  (* globals.  pgqs_walk_pres walks; free at exit.                        *)
  (* ==================================================================== *)
  Lemma pgqs_body_pres_mo :
    body_pres_mo lp bm NoA MWF SafeB
      mario_step.f_perform_ground_quarter_step.
  Proof.
    intros m0 vargs0 t0 mF vres0 Hgate Hevf HN HM HV HS.
    destruct Hgate as (Hcond & Hlast).
    (* ---- entry ---- *)
    inv Hevf.
    match goal with He : function_entry2 _ _ _ _ _ _ _ |- _ =>
      rename He into Hentry end.
    match goal with Hx : exec_stmt _ _ _ _ _ _ _ _ _ _ |- _ =>
      rename Hx into Hbody end.
    match goal with Hf : Mem.free_list _ _ = Some _ |- _ =>
      rename Hf into Hfree end.
    inv Hentry.
    match goal with Ha : alloc_variables _ _ _ _ _ _ |- _ =>
      rename Ha into Halloc end.
    match goal with Hb : bind_parameter_temps _ _ _ = Some _ |- _ =>
      rename Hb into Hbind end.
    unfold mario_step.f_perform_ground_quarter_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _floor/_ceil fn_vars are watched-disjoint stack blocks *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._floor :: mario_step._ceil :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_eq
                        | apply Bool.orb_true_iff in Hmem;
                          destruct Hmem as [He | Hf];
                          [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                            apply in_eq
                          | discriminate Hf ] ]))
      as Hlids.
    (* bind the 2 params _m, _nextPos *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_np vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_step._m = Some v_m)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    assert (Hnpeq : le1 ! mario_step._nextPos = Some v_np)
      by (rewrite <- Hle_init; apply PTree.gss).
    (* _m conditional from arg0_marg *)
    cbn [arg0_marg] in Hcond.
    assert (Hmcond : forall b o,
               le1 ! mario_step._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hg;
          apply (Hcond b o Hg)).
    (* _nextPos local from last_arg_local *)
    cbn [last_val] in Hlast.
    destruct Hlast as (npb & npo & Hvnp & Hnploc).
    injection Hvnp as Hvnp; subst v_np.
    (* the 7 callees + the gwspf global are unbound in the entry env *)
    assert (Hrn : eloc !
              mario_step._resolve_and_return_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._resolve_and_return_wall_collisions)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hff : eloc ! mario_step._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._find_floor)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvfc : eloc ! mario_step._vec3f_find_ceil = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_find_ceil)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hfwl : eloc ! mario_step._find_water_level = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._find_water_level)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvc : eloc ! mario_step._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_copy)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvs : eloc ! mario_step._vec3f_set = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_set)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hat : eloc ! mario_step._atan2s = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._atan2s)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hgwn : eloc ! mario_step._gWaterSurfacePseudoFloor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._gWaterSurfacePseudoFloor)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (pgqs_walk_pres npb npo Hnploc _ _ _ _ _ _ _ _
                Hbody pgqs_chk_body Hrn Hff Hvfc Hfwl Hvc Hvs Hat Hgwn
                Hlids Hmcond Hnpeq Hcar)
      as (Hcarr & _ & _).
    (* ---- exit: free the 2 fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  (* THE DISCHARGE: lift the per-body walk to the mo residual via the
     producer + the prog_defmap pin. *)
  Lemma pgqs_cp :
    call_pres_mo lp bm NoA MWF SafeB
      mario_step._perform_ground_quarter_step.
  Proof.
    eapply call_pres_mo_of_body.
    - exact HNoA_of_MWF.
    - exact LO_stp.
    - exact pgqs_pin.
    - exact pgqs_body_pres_mo.
  Qed.

End PgqsSurface.
