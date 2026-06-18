(* ====================================================================== *)
(* THE PERFORM_AIR_STEP SURFACE (SPINE: pas_cp DISCHARGES the capstone's   *)
(* Hcp_pas_real -- the perform_air_step opaque-internal blocker behind the *)
(* airborne family's act_lava_boost / act_getting_blown leaves).           *)
(*                                                                         *)
(* f_perform_air_step (mario_step.v:4475, fn_vars = [_intendedPos]) is the *)
(* air-movement worker, the exact structural twin of perform_ground_step:  *)
(* a 4-iteration Sloop of pure m->... loads, window-checked m-field stores, *)
(* indexed stores into its OWN stack array _intendedPos, and 6 calls:      *)
(*   - perform_air_quarter_step(m, intendedPos, stepArg): the 363-line     *)
(*     quarter-step worker.  intendedPos is pas's stack local, but it is   *)
(*     the MIDDLE arg (stepArg:tuint is last), so the mo class             *)
(*     (last_arg_local) does NOT fit.  The honest gate is the NEW paqs     *)
(*     class: arg0 marg AND arg1 local.  A plain marg call_pres would be   *)
(*     PHANTOM-FALSE (an unconstrained intendedPos could alias bm's action *)
(*     cell).  Deeper row, walkable later.                                 *)
(*   - mario_get_terrain_sound_addend(m) / apply_gravity(m) /              *)
(*     apply_vertical_wind(m): plain marg internals (Internal in           *)
(*     mario_step.prog).  Deeper rows.                                     *)
(*   - vec3f_copy / vec3s_set: the ungated obj_ext externals already       *)
(*     carried by the capstone.                                            *)
(* The walk: a loop-tolerant exec-derivation induction (the pgs shape)     *)
(* threading carried + the conditional _m marg fact; the fn_var arc        *)
(* (LocalVarsSurface) supplies entry alloc / local-store / exit free.      *)
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
Definition pas_assign_chk (a1 : expr) : bool :=
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

Definition pas_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid mario_step._perform_air_quarter_step
   && proj_sumbool
        (type_eq fty
           (Tfunction (tyMSstp :: tptr tfloat :: tuint :: nil) tint cc_default))
   && match al with
      | Etempvar mp tmp :: Evar q tq :: Etempvar sp tsp :: nil =>
          Pos.eqb mp mario_step._m
          && Pos.eqb q mario_step._intendedPos
          && Pos.eqb sp mario_step._stepArg
          && proj_sumbool (type_eq tmp tyMSstp)
          && proj_sumbool (type_eq tq (tarray tfloat 3))
          && proj_sumbool (type_eq tsp tuint)
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
  || (Pos.eqb fid mario_step._apply_gravity
      && proj_sumbool (type_eq fty (Tfunction (tyMSstp :: nil) tvoid cc_default))
      && match al with
         | Etempvar mp tmp :: nil =>
             Pos.eqb mp mario_step._m && proj_sumbool (type_eq tmp tyMSstp)
         | _ => false
         end)
  || (Pos.eqb fid mario_step._apply_vertical_wind
      && proj_sumbool (type_eq fty (Tfunction (tyMSstp :: nil) tvoid cc_default))
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

Definition pas_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id mario_step._m)
  | None => true
  end.

Fixpoint pas_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => pas_chk s1 && pas_chk s2
  | Sifthenelse _ s1 s2 => pas_chk s1 && pas_chk s2
  | Sloop s1 s2 => pas_chk s1 && pas_chk s2
  | Sset id _ => pas_optid_ok (Some id)
  | Sassign a1 _ => pas_assign_chk a1
  | Scall optid (Evar fid fty) al => pas_optid_ok optid && pas_call_chk fid fty al
  | _ => false
  end.

Lemma pas_pin :
  (prog_defmap mario_step.prog) ! mario_step._perform_air_step
  = Some (Gfun (Internal mario_step.f_perform_air_step)).
Proof. vm_compute. reflexivity. Qed.

(* NON-VACUITY: the recognizer accepts the REAL generated body. *)
Lemma pas_chk_body :
  pas_chk (fn_body mario_step.f_perform_air_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* the rows                                                               *)
(* ====================================================================== *)
Section PasSurface.
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

  (* ==================================================================== *)
  (* THE paqs GATE: arg0 marg AND arg1 (NOT last) local.  perform_air_     *)
  (* quarter_step(m, intendedPos, stepArg) -- the local out-param is the   *)
  (* MIDDLE arg, so mo/last_arg_local does not fit.                        *)
  (* ==================================================================== *)
  Definition arg0_marg_p (vargs : list val) : Prop :=
    match vargs with
    | v0 :: _ => forall b o, v0 = Vptr b o -> b = bm /\ o = Ptrofs.zero
    | nil => True
    end.

  Definition arg1_val (vs : list val) : option val :=
    match vs with _ :: v1 :: _ => Some v1 | _ => None end.

  Definition arg1_local (vargs : list val) : Prop :=
    exists b ofs, arg1_val vargs = Some (Vptr b ofs) /\ local_blk lp bm SafeB b.

  Definition paqs_gate (vargs : list val) : Prop :=
    arg0_marg_p vargs /\ arg1_local vargs.

  (* the ARG-AWARE residual for the marg-AND-middle-local-out-param helper *)
  Definition call_pres_paqs (fid : ident) : Prop :=
    forall fd m0 vargs0 t0 m1 vres0,
      eval_funcall function_entry2 (lp_ge lp) m0 fd vargs0 t0 m1 vres0 ->
      resolves_lp lp fid fd ->
      paqs_gate vargs0 ->
      NoA m0 -> MWF m0 -> Mem.valid_block m0 bm ->
      action_sat not_tainted m0 bm ->
      Mem.valid_block m1 bm /\ action_sat not_tainted m1 bm /\
      MWF m1 /\ NoA m1.

  (* the callee rows *)
  Hypothesis Hcp_paqs :
    call_pres_paqs mario_step._perform_air_quarter_step.
  Hypothesis Hcp_mgtsa :
    call_pres lp bm NoA MWF mario_step._mario_get_terrain_sound_addend.
  Hypothesis Hcp_ag :
    call_pres lp bm NoA MWF mario_step._apply_gravity.
  Hypothesis Hcp_avw :
    call_pres lp bm NoA MWF mario_step._apply_vertical_wind.
  Hypothesis Hcpx_v3f :
    call_pres_ext lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_v3s :
    call_pres_ext lp bm NoA MWF mario_step._vec3s_set.

  (* ---- decoders ---- *)
  Lemma pas_assign_decode :
    forall a1, pas_assign_chk a1 = true ->
      safe_mfield_store mario_step._m a1 = true
      \/ exists idxN,
          a1 = Ederef (Ebinop Oadd
                         (Evar mario_step._intendedPos (tarray tfloat 3))
                         (Econst_int idxN tint) (tptr tfloat)) tfloat.
  Proof.
    intros a1 H. unfold pas_assign_chk in H.
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

  Lemma pas_call_decode :
    forall fid fty al, pas_call_chk fid fty al = true ->
      (fid = mario_step._perform_air_quarter_step /\
       fty = Tfunction (tyMSstp :: tptr tfloat :: tuint :: nil) tint cc_default /\
       al = Etempvar mario_step._m tyMSstp
            :: Evar mario_step._intendedPos (tarray tfloat 3)
            :: Etempvar mario_step._stepArg tuint :: nil)
      \/ (fid = mario_step._mario_get_terrain_sound_addend /\
          fty = Tfunction (tyMSstp :: nil) tuint cc_default /\
          al = Etempvar mario_step._m tyMSstp :: nil)
      \/ (fid = mario_step._apply_gravity /\
          fty = Tfunction (tyMSstp :: nil) tvoid cc_default /\
          al = Etempvar mario_step._m tyMSstp :: nil)
      \/ (fid = mario_step._apply_vertical_wind /\
          fty = Tfunction (tyMSstp :: nil) tvoid cc_default /\
          al = Etempvar mario_step._m tyMSstp :: nil)
      \/ (fid = mario_step._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default)
      \/ (fid = mario_step._vec3s_set /\
          fty = Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                  (tptr tvoid) cc_default).
  Proof.
    intros fid fty al H. unfold pas_call_chk in H.
    apply orb_true_iff in H as [H | Hv3s].
    apply orb_true_iff in H as [H | Hv3f].
    apply orb_true_iff in H as [H | Havw].
    apply orb_true_iff in H as [H | Hag].
    apply orb_true_iff in H as [Hpaqs | Hmgtsa].
    - left.
      apply andb_true_iff in Hpaqs as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tyMSstp :: tptr tfloat :: tuint :: nil) tint
                     cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | | | | sp tsp | | | | | | | | ]; try discriminate Hal.
      destruct al2; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htsp].
      apply andb_true_iff in Hal as [Hal Htq].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hal Hsp].
      apply andb_true_iff in Hal as [Hmp Hq].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hq; subst q.
      apply Pos.eqb_eq in Hsp; subst sp.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      destruct (type_eq tq (tarray tfloat 3)) as [E2 | ];
        [ subst tq | discriminate Htq ].
      destruct (type_eq tsp tuint) as [E3 | ]; [ subst tsp | discriminate Htsp ].
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
      apply andb_true_iff in Hag as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tyMSstp :: nil) tvoid cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0; try discriminate Hal.
      apply andb_true_iff in Hal as [Hmp Htmp].
      apply Pos.eqb_eq in Hmp; subst mp.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      reflexivity.
    - do 3 right; left.
      apply andb_true_iff in Havw as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tyMSstp :: nil) tvoid cc_default))
        as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct al0; try discriminate Hal.
      apply andb_true_iff in Hal as [Hmp Htmp].
      apply Pos.eqb_eq in Hmp; subst mp.
      destruct (type_eq tmp tyMSstp) as [E1 | ]; [ subst tmp | discriminate Htmp ].
      reflexivity.
    - do 4 right; left.
      apply andb_true_iff in Hv3f as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      exact (conj Hfid Efty).
    - do 5 right.
      apply andb_true_iff in Hv3s as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tshort :: tshort :: tshort :: tshort :: nil)
                     (tptr tvoid) cc_default)) as [Efty | ];
        [ | discriminate Hfty ].
      exact (conj Hfid Efty).
  Qed.

  (* ---- the paqs gate at the call site: arg0 = Etempvar _m under the
     conditional marg, arg1 = Evar _intendedPos (the fn_var stack array,
     By_reference decay to its local_blk base), arg2 = Etempvar _stepArg
     (irrelevant non-pointer) ---- *)
  Lemma pas_paqs_gate :
    forall e le m ipb ipty vargs,
      (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                   b = bm /\ o = Ptrofs.zero) ->
      e ! mario_step._intendedPos = Some (ipb, ipty) ->
      local_blk lp bm SafeB ipb ->
      eval_exprlist (lp_ge lp) e le m
        (Etempvar mario_step._m tyMSstp
           :: Evar mario_step._intendedPos (tarray tfloat 3)
           :: Etempvar mario_step._stepArg tuint :: nil)
        (tyMSstp :: tptr tfloat :: tuint :: nil) vargs ->
      paqs_gate vargs.
  Proof.
    intros e le m ipb ipty vargs Hmarg Heip Hiploc Hvl.
    inv Hvl.
    match goal with H : eval_exprlist _ _ _ _ (Evar _ _ :: _) _ _ |- _ => inv H end.
    match goal with H : eval_exprlist _ _ _ _ (Etempvar _ _ :: nil) _ _ |- _ =>
      inv H end.
    match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
    (* arg0: the marg conditional *)
    match goal with
    | He : eval_expr _ _ _ _ (Etempvar mario_step._m _) ?v0 |- _ =>
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
    (* arg1: the Evar _intendedPos local *)
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
    - cbn [arg0_marg_p]. exact Hv0.
    - red. cbn [arg1_val]. exists ipb, Ptrofs.zero.
      split; [ reflexivity | exact Hiploc ].
  Qed.

  (* THE CALL-SITE BRICK: a Scall to the paqs helper preserves carried.
     Verbatim mirror of mo_scall_pres, paqs_gate in place of mo_gate. *)
  Lemma paqs_scall_pres :
    forall optid fid tyl rty cc args e le0 m0 tr le1 m1 out0,
      e ! fid = None ->
      call_pres_paqs fid ->
      (forall vargs, eval_exprlist (lp_ge lp) e le0 m0 args tyl vargs ->
                     paqs_gate vargs) ->
      exec_stmt function_entry2 (lp_ge lp) e le0 m0
        (Scall optid (Evar fid (Tfunction tyl rty cc)) args)
        tr le1 m1 out0 ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m1 /\ out0 = Out_normal.
  Proof.
    intros optid fid tyl rty cc args e le0 m0 tr le1 m1 out0
           He Hpaqs Hgate Hexec Hc.
    inv Hexec.
    match goal with
    | Hcf : classify_fun _ = fun_case_f _ _ _ |- _ =>
        cbn in Hcf; injection Hcf as E1 E2 E3; subst
    end.
    match goal with
    | Hv : eval_expr _ _ _ _ (Evar _ _) ?vf |- _ =>
        destruct (eval_Evar_funct lp _ _ _ _ _ _ _ _ He Hv) as (bf & Hsym & ->)
    end.
    match goal with
    | Hff : Genv.find_funct _ (Vptr bf Ptrofs.zero) = Some ?fd |- _ =>
        assert (Hres : resolves_lp lp fid fd) by (exists bf; split; assumption)
    end.
    match goal with
    | Hvl : eval_exprlist _ _ _ _ _ _ ?vargs |- _ =>
        pose proof (Hgate vargs Hvl) as Hga
    end.
    destruct Hc as (HV & HS & HM & HN).
    match goal with
    | Hevf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
        destruct (Hpaqs _ _ _ _ _ _ Hevf Hres Hga HN HM HV HS)
          as (HV' & HS' & HM' & HN')
    end.
    split; [ | reflexivity ].
    split; [ exact HV' | split; [ exact HS' | split; [ exact HM' | exact HN' ] ] ].
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
  (* THE WALKER (the pgs shape, 6 callees).                               *)
  (* ==================================================================== *)
  Lemma pas_walk_pres :
    forall ipb ipty,
      local_blk lp bm SafeB ipb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        pas_chk s = true ->
        e ! mario_step._perform_air_quarter_step = None ->
        e ! mario_step._mario_get_terrain_sound_addend = None ->
        e ! mario_step._apply_gravity = None ->
        e ! mario_step._apply_vertical_wind = None ->
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
    induction Hexec; intros Hchk Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign a1 a2 *)
      cbn [pas_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct (pas_assign_decode _ Hchk) as [Hsf | (idxN & ->)].
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
    - (* Sset id a: id <> _m (pas_optid_ok) *)
      cbn [pas_chk pas_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id; rewrite Pos.eqb_refl in Hchk;
                                  discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall optid a al *)
      cbn [pas_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t (set_opttemp optid vres le)
                      m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! mario_step._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [pas_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt). exact (Hm b o Hg).
        - exact Hm. }
      destruct (pas_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & Haleq)
           | [ (Hfeq & Hftyeq & Haleq)
             | [ (Hfeq & Hftyeq & Haleq)
               | [ (Hfeq & Hftyeq & Haleq)
                 | [ (Hfeq & Hftyeq) | (Hfeq & Hftyeq) ] ] ] ] ];
        subst fid fty.
      + (* perform_air_quarter_step(m, intendedPos, stepArg): the paqs helper *)
        subst al.
        destruct (paqs_scall_pres optid
                    mario_step._perform_air_quarter_step
                    (tyMSstp :: tptr tfloat :: tuint :: nil) tint cc_default
                    (Etempvar mario_step._m tyMSstp
                       :: Evar mario_step._intendedPos (tarray tfloat 3)
                       :: Etempvar mario_step._stepArg tuint :: nil)
                    e le m _ _ m' _ Hpaqs Hcp_paqs
                    ltac:(intros vargs1 Hvl;
                          exact (pas_paqs_gate _ _ _ _ _ _ Hm Hip Hiploc Hvl))
                    Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* mario_get_terrain_sound_addend(m): marg internal *)
        subst al.
        destruct (cp_scall_pres optid mario_step._mario_get_terrain_sound_addend
                    tuint cc_default e le m _ _ m' _
                    Hmgtsa Hex Hcp_mgtsa Hm Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* apply_gravity(m): marg internal *)
        subst al.
        destruct (cp_scall_pres optid mario_step._apply_gravity
                    tvoid cc_default e le m _ _ m' _
                    Hag Hex Hcp_ag Hm Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* apply_vertical_wind(m): marg internal *)
        subst al.
        destruct (cp_scall_pres optid mario_step._apply_vertical_wind
                    tvoid cc_default e le m _ _ m' _
                    Havw Hex Hcp_avw Hm Hc) as (Hc' & _).
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
      cbn [pas_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [pas_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc)
        as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [pas_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc).
    - (* Sifthenelse *)
      cbn [pas_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1 *)
      cbn [pas_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc).
    - (* Sloop stop2 *)
      cbn [pas_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc)
        as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm1 Hc1).
    - (* Sloop loop *)
      cbn [pas_chk] in Hchk.
      pose proof Hchk as Hchk0.
      apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm Hc)
        as (Hc1 & Hm1).
      destruct (IHHexec2 H2 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm1 Hc1)
        as (Hc2 & Hm2).
      exact (IHHexec3 Hchk0 Hpaqs Hmgtsa Hag Havw Hv3f Hv3s Hip Hm2 Hc2).
    - (* Sswitch: rejected *)
      cbn [pas_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE ENTRY LEMMA: pas's whole body preserves the carried facts.       *)
  (* ==================================================================== *)
  Lemma pas_body_pres :
    body_pres lp NoA MWF bm mario_step.f_perform_air_step.
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
    unfold mario_step.f_perform_air_step in Hbind, Halloc.
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
    (* bind the 2 params _m, _stepArg *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_sa vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2; [ | cbn [bind_parameter_temps] in Hbind; discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_step._m = Some v_m).
    { rewrite <- Hle_init. rewrite PTree.gso by (vm_compute; discriminate).
      apply PTree.gss. }
    (* _m conditional from marg_ok *)
    assert (Hmcond : forall b o,
               le1 ! mario_step._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 6 callees are unbound globals in the entry env *)
    assert (Hpaqs_none :
              eloc ! mario_step._perform_air_quarter_step = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._perform_air_quarter_step)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hmgtsa_none :
              eloc ! mario_step._mario_get_terrain_sound_addend = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._mario_get_terrain_sound_addend)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hag_none : eloc ! mario_step._apply_gravity = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._apply_gravity)
        by (cbn; intros [HH | []]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Havw_none : eloc ! mario_step._apply_vertical_wind = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._apply_vertical_wind)
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
    destruct (pas_walk_pres ipb ipty Hiploc _ _ _ _ _ _ _ _
                Hbody pas_chk_body Hpaqs_none Hmgtsa_none Hag_none Havw_none
                Hv3f_none Hv3s_none Hip Hmcond Hcar)
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
  Lemma pas_cp :
    call_pres lp bm NoA MWF mario_step._perform_air_step.
  Proof.
    exact (call_pres_of_body lp bm NoA MWF HNoA_of_MWF mario_step.prog
             mario_step._perform_air_step mario_step.f_perform_air_step
             LO_stp pas_pin pas_body_pres).
  Qed.

End PasSurface.
