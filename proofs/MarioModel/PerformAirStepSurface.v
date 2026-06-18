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

(* ====================================================================== *)
(* apply_vertical_wind: a perform_air_step callee, but a CLEAN window-     *)
(* writer (NO calls, NO fn_vars; the only chase is a READ of m->floor->    *)
(* type -- reads never write memory).  All its stores are m->vel[1]        *)
(* indexed-window stores.  So it is discharged ZERO-RESIDUAL via the bare  *)
(* wwalk engine (the air analogue of mario_set_forward_vel's msfv_row).    *)
(* The pin/vars/params/walk facts are pure vm_compute checks; the capstone *)
(* (Lemma Hcp_avw) feeds them to call_pres_of_wwalk with the MWF_real kit, *)
(* ELIMINATING the Hcp_avw_real residual the pas walk left.                *)
(* ====================================================================== *)
Lemma avw_pin :
  (prog_defmap mario_step.prog) ! mario_step._apply_vertical_wind
  = Some (Gfun (Internal mario_step.f_apply_vertical_wind)).
Proof. vm_compute. reflexivity. Qed.

Lemma avw_vars : fn_vars mario_step.f_apply_vertical_wind = nil.
Proof. reflexivity. Qed.

Lemma avw_params :
  match fn_params mario_step.f_apply_vertical_wind with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.

Lemma avw_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_apply_vertical_wind) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* apply_gravity + its two callees -- ALL clean wwalk discharges.          *)
(*   - apply_twirl_gravity (atg): NO calls, NO fn_vars; writes m->angleVel *)
(*     [i] indexed-window.  Zero-residual via the bare engine (cact=nil).  *)
(*   - should_strengthen_gravity_for_jump_ascent (ssg): NO calls, NO       *)
(*     fn_vars; a pure reader.  Zero-residual via the bare engine.         *)
(*   - apply_gravity (ag): ids=[atg; ssg] + ONE marioBodyState chase store *)
(*     (_t'17->wingFlutter = 1, a const int) -> cact=[_t'17].              *)
(* The capstone feeds these to call_pres_of_wwalk (atg/ssg) and            *)
(* call_pres_of_wwalk_cact (ag, consuming Hcp_atg/Hcp_ssg) -> ELIMINATES   *)
(* the Hcp_ag_real residual the pas walk left, zero net new residuals.     *)
(* ====================================================================== *)
Lemma atg_pin :
  (prog_defmap mario_step.prog) ! mario_step._apply_twirl_gravity
  = Some (Gfun (Internal mario_step.f_apply_twirl_gravity)).
Proof. vm_compute. reflexivity. Qed.
Lemma atg_vars : fn_vars mario_step.f_apply_twirl_gravity = nil.
Proof. reflexivity. Qed.
Lemma atg_params :
  match fn_params mario_step.f_apply_twirl_gravity with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma atg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_apply_twirl_gravity) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ssg_pin :
  (prog_defmap mario_step.prog) ! mario_step._should_strengthen_gravity_for_jump_ascent
  = Some (Gfun (Internal mario_step.f_should_strengthen_gravity_for_jump_ascent)).
Proof. vm_compute. reflexivity. Qed.
Lemma ssg_vars :
  fn_vars mario_step.f_should_strengthen_gravity_for_jump_ascent = nil.
Proof. reflexivity. Qed.
Lemma ssg_params :
  match fn_params mario_step.f_should_strengthen_gravity_for_jump_ascent with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ssg_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario_step.f_should_strengthen_gravity_for_jump_ascent) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ag_pin :
  (prog_defmap mario_step.prog) ! mario_step._apply_gravity
  = Some (Gfun (Internal mario_step.f_apply_gravity)).
Proof. vm_compute. reflexivity. Qed.
Lemma ag_vars : fn_vars mario_step.f_apply_gravity = nil.
Proof. reflexivity. Qed.
Lemma ag_params :
  match fn_params mario_step.f_apply_gravity with
  | (i, ty) :: ps =>
      Pos.eqb i mario_actions_airborne._m
      && proj_sumbool (type_eq ty tyMSp)
      && negb (mem_id mario_actions_airborne._m (map fst ps))
  | nil => false
  end = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ag_cact_nonparam :
  forallb (fun t' => negb (mem_id t' (map fst (fn_params mario_step.f_apply_gravity))))
    (mario_step._t'17 :: nil) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma ag_walk :
  wwalk_chk false nil
    (mario_step._apply_twirl_gravity
       :: mario_step._should_strengthen_gravity_for_jump_ascent :: nil)
    nil (mario_step._t'17 :: nil) nil nil nil
    (fn_body mario_step.f_apply_gravity) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* ===================  perform_air_quarter_step (paqs)  ================ *)
(* The 363-line air quarter-step worker -- the AIR twin of                 *)
(* perform_ground_quarter_step.  Same callee set (resolve / find_floor /   *)
(* vec3f_find_ceil / find_water_level / vec3f_copy / atan2s) + the         *)
(* gWaterSurfacePseudoFloor special site + ONE extra internal callee       *)
(* (check_ledge_grab).  The KEY structural difference from pgqs: its       *)
(* out-param `_nextPos` is the function's OWN fn_var STACK ARRAY (Evar     *)
(* tarray tfloat 3), allocated at entry -- NOT a caller-supplied pointer    *)
(* param.  So the out-param locality comes from alloc_variables (Hlocal)   *)
(* not from a mo/last_arg gate; the bricks (ol/oc/w1) are gate-agnostic    *)
(* and reused verbatim, with the gates constructed from the Evar-array     *)
(* decay (oc2_extract pattern).  Gate at the call site: arg0 marg AND      *)
(* arg1 (intendedPos) local -- the paqs_gate already built in PasSurface,  *)
(* consumed by the entry vec3f_copy(nextPos, intendedPos).                 *)
(* ====================================================================== *)

Definition tSurfp : type := tptr (Tstruct mario_step._Surface noattr).

(* Val.load_result is the identity on pointers at Mptr (ptr32). *)
Lemma paqs_load_result_mptr_ptr :
  forall b o, Val.load_result Mptr (Vptr b o) = Vptr b o.
Proof.
  intros b o.
  assert (Hp64 : Archi.ptr64 = false) by (vm_compute; reflexivity).
  unfold Mptr. rewrite Hp64. cbn [Val.load_result]. rewrite Hp64. reflexivity.
Qed.

(* ---- recognizers (validated in the probe stage) ---- *)
Definition paqs_gwspf_site_chk (s : statement) : bool :=
  match s with
  | Ssequence
      (Sassign (Evar fl1 tps1)
         (Eaddrof (Evar gw (Tstruct sid sa)) tps2))
      (Ssequence
         (Sset t39a (Evar fl2 tps3))
         (Sassign
            (Efield (Ederef (Etempvar t39b tps4) (Tstruct sid2 sa2))
               oo tfo)
            (Etempvar fh tfh))) =>
      Pos.eqb fl1 mario_step._floor
      && Pos.eqb fl2 mario_step._floor
      && Pos.eqb gw mario_step._gWaterSurfacePseudoFloor
      && Pos.eqb t39a mario_step._t'39
      && Pos.eqb t39b mario_step._t'39
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

Definition paqs_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (Pos.eqb fid mario_step._resolve_and_return_wall_collisions
   && proj_sumbool
        (type_eq fty
           (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default))
   && match al with
      | Evar q (Tarray ety sz attr) :: Econst_single _ _ :: Econst_single _ _
        :: nil =>
          Pos.eqb q mario_step._nextPos
          && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
      | _ => false
      end)
  || oc_call_chk (mario_step._floor :: mario_step._ceil :: nil)
       (mario_step._find_floor :: mario_step._vec3f_find_ceil :: nil) fid fty al
  || (Pos.eqb fid mario_step._find_water_level
      && proj_sumbool
           (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tfloat cc_default)))
  || (Pos.eqb fid mario_step._vec3f_copy
      && proj_sumbool
           (type_eq fty
              (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                 cc_default))
      && match al with
         | Evar q (Tarray ety sz attr) :: Etempvar ip tip :: nil =>
             Pos.eqb q mario_step._nextPos
             && Pos.eqb ip mario_step._intendedPos
             && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
             && proj_sumbool (type_eq tip (tptr tfloat))
         | _ => false
         end)
  || (Pos.eqb fid mario_step._vec3f_copy
      && proj_sumbool
           (type_eq fty
              (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                 cc_default))
      && match al with
         | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa
           :: Evar q (Tarray ety sz attr) :: nil =>
             Pos.eqb mp mario_step._m
             && Pos.eqb fld mario_step._pos
             && Pos.eqb q mario_step._nextPos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq tsm (Tstruct mario_step._MarioState noattr))
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
             && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
         | _ => false
         end)
  || (Pos.eqb fid mario_step._check_ledge_grab
      && proj_sumbool
           (type_eq fty
              (Tfunction (tyMSstp :: tSurfp :: tptr tfloat :: tptr tfloat :: nil)
                 tuint cc_default))
      && match al with
         | Etempvar mp tmp :: Etempvar lw tlw :: Etempvar ip tip
           :: Evar q (Tarray ety sz attr) :: nil =>
             Pos.eqb mp mario_step._m
             && Pos.eqb q mario_step._nextPos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
         | _ => false
         end)
  || (Pos.eqb fid mario_step._atan2s
      && proj_sumbool
           (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))).

Definition paqs_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id mario_step._m)
               && negb (Pos.eqb id mario_step._intendedPos)
  | None => true
  end.

Fixpoint paqs_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 =>
      paqs_gwspf_site_chk (Ssequence s1 s2) || (paqs_chk s1 && paqs_chk s2)
  | Sifthenelse _ s1 s2 => paqs_chk s1 && paqs_chk s2
  | Sset id _ => paqs_optid_ok (Some id)
  | Sassign a1 _ =>
      safe_mfield_store mario_step._m a1 || idx_mfield_store mario_step._m a1
  | Scall optid (Evar fid fty) al =>
      paqs_optid_ok optid && paqs_call_chk fid fty al
  | _ => false
  end.

Lemma paqs_pin :
  (prog_defmap mario_step.prog) ! mario_step._perform_air_quarter_step
  = Some (Gfun (Internal mario_step.f_perform_air_quarter_step)).
Proof. vm_compute. reflexivity. Qed.

Lemma paqs_chk_body :
  paqs_chk (fn_body mario_step.f_perform_air_quarter_step) = true.
Proof. vm_compute. reflexivity. Qed.

(* ====================================================================== *)
(* the rows                                                               *)
(* ====================================================================== *)
Section PaqsSurface.
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
  (* the gWaterSurfacePseudoFloor store row (mwf_real_glob's conclusion at
     this single gid; discharged at the capstone via the stored_globals
     census which already carries the symbol from the pgqs walk). *)
  Hypothesis Hglob_gwspf :
    forall bg,
      Genv.find_symbol (lp_ge lp) mario_step._gWaterSurfacePseudoFloor
        = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').

  (* the callee rows -- the SAME gated externals the pgqs walk consumes
     (resolve / find_floor / vec3f_find_ceil / find_water_level / vec3f_copy
     window-writer / atan2s), PLUS the entry vec3f_copy under the ol gate
     (dst+src both local) and check_ledge_grab (internal marg helper). *)
  Hypothesis Hocp_resolve :
    call_pres_ext_ol lp bm NoA MWF SafeB
      mario_step._resolve_and_return_wall_collisions.
  Hypothesis Hocp_ff :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_step._find_floor.
  Hypothesis Hocp_vfc :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_step._vec3f_find_ceil.
  Hypothesis Hxcp_fwl :
    call_pres_ext lp bm NoA MWF mario_step._find_water_level.
  Hypothesis Holcp_v3f :
    call_pres_ext_ol lp bm NoA MWF SafeB mario_step._vec3f_copy.
  Hypothesis Hw1cp_v3f :
    call_pres_ext_w1 lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF mario_step._atan2s.
  Hypothesis Hcp_clg :
    call_pres lp bm NoA MWF mario_step._check_ledge_grab.

  (* ---- the Evar-array decay: a bare local array Evar evaluates to the
     base address (Vptr lblk 0) of its env block (By_reference access). ---- *)
  Lemma eval_Evar_arr_val :
    forall e le m lid b tyenv v,
      e ! lid = Some (b, tyenv) ->
      eval_expr (lp_ge lp) e le m (Evar lid (tarray tfloat 3)) v ->
      v = Vptr b Ptrofs.zero.
  Proof.
    intros e le m lid b tyenv v He Hev.
    inv Hev.
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar _ _) _ _ _ |- _ => inv Hlv
    end.
    2:{ match goal with
        | Hn : e ! lid = None |- _ => rewrite He in Hn; discriminate Hn
        end. }
    match goal with
    | Hb : e ! lid = Some _ |- _ => rewrite He in Hb; injection Hb as <- _
    end.
    match goal with
    | Hd : deref_loc (typeof _) _ _ _ _ _ |- _ =>
        cbn [typeof] in Hd; unfold tarray in Hd
    end.
    match goal with
    | Hd : deref_loc (Tarray _ _ _) _ _ _ _ _ |- _ => inv Hd
    end;
      try (match goal with
           | Hac : access_mode (Tarray _ _ _) = _ |- _ =>
               cbn in Hac; discriminate Hac
           end).
    reflexivity.
  Qed.

  (* ---- decoders ---- *)
  Lemma paqs_gwspf_site_decode :
    forall s, paqs_gwspf_site_chk s = true ->
      s = Ssequence
            (Sassign (Evar mario_step._floor tSurfp)
               (Eaddrof
                  (Evar mario_step._gWaterSurfacePseudoFloor
                     (Tstruct mario_step._Surface noattr)) tSurfp))
            (Ssequence
               (Sset mario_step._t'39 (Evar mario_step._floor tSurfp))
               (Sassign
                  (Efield
                     (Ederef (Etempvar mario_step._t'39 tSurfp)
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
    destruct s2a as [ | | t39a ae | | | | | | | | | | | ]; try discriminate H.
    destruct ae as [ | | | | fl2 tps3 | | | | | | | | | ]; try discriminate H.
    destruct s2b as [ | b1 b2 | | | | | | | | | | | | ]; try discriminate H.
    destruct b1 as [ | | | | | | | | | | | ef1 oo tfo | | ]; try discriminate H.
    destruct ef1 as [ | | | | | | edb edt | | | | | | | ]; try discriminate H.
    destruct edb as [ | | | | | t39b tps4 | | | | | | | | ]; try discriminate H.
    destruct edt as [ | | | | | | | sid2 sa2 | ]; try discriminate H.
    destruct b2 as [ | | | | | fh tfh | | | | | | | | ]; try discriminate H.
    cbn [paqs_gwspf_site_chk] in H.
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
    apply andb_true_iff in H as [H Ht39b].
    apply andb_true_iff in H as [H Ht39a].
    apply andb_true_iff in H as [H Hgw].
    apply andb_true_iff in H as [Hfl1 Hfl2].
    apply Pos.eqb_eq in Hfl1; subst fl1.
    apply Pos.eqb_eq in Hfl2; subst fl2.
    apply Pos.eqb_eq in Hgw; subst gw.
    apply Pos.eqb_eq in Ht39a; subst t39a.
    apply Pos.eqb_eq in Ht39b; subst t39b.
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

  Lemma paqs_call_decode :
    forall fid fty al, paqs_call_chk fid fty al = true ->
      (fid = mario_step._resolve_and_return_wall_collisions /\
       fty = Tfunction (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default /\
       exists c1 t1 c2 t2,
         al = Evar mario_step._nextPos (tarray tfloat 3)
              :: Econst_single c1 t1 :: Econst_single c2 t2 :: nil)
      \/ oc_call_chk (mario_step._floor :: mario_step._ceil :: nil)
           (mario_step._find_floor :: mario_step._vec3f_find_ceil :: nil)
           fid fty al = true
      \/ (fid = mario_step._find_water_level /\
          fty = Tfunction (tfloat :: tfloat :: nil) tfloat cc_default)
      \/ (fid = mario_step._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default /\
          al = Evar mario_step._nextPos (tarray tfloat 3)
               :: Etempvar mario_step._intendedPos (tptr tfloat) :: nil)
      \/ (fid = mario_step._vec3f_copy /\
          fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                  cc_default /\
          exists tail,
            al = Efield
                   (Ederef (Etempvar mario_step._m tyMSstp)
                      (Tstruct mario_step._MarioState noattr))
                   mario_step._pos (tarray tfloat 3) :: tail)
      \/ (fid = mario_step._check_ledge_grab /\
          fty = Tfunction (tyMSstp :: tSurfp :: tptr tfloat :: tptr tfloat :: nil)
                  tuint cc_default /\
          exists tail, al = Etempvar mario_step._m tyMSstp :: tail)
      \/ (fid = mario_step._atan2s /\
          fty = Tfunction (tfloat :: tfloat :: nil) tshort cc_default).
  Proof.
    intros fid fty al H. unfold paqs_call_chk in H.
    apply orb_true_iff in H as [H | Hat].
    apply orb_true_iff in H as [H | Hclg].
    apply orb_true_iff in H as [H | Hwin].
    apply orb_true_iff in H as [H | Hent].
    apply orb_true_iff in H as [H | Hfwl].
    apply orb_true_iff in H as [Hres | Hoc].
    - (* resolve *)
      left.
      apply andb_true_iff in Hres as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct tq as [ | | | | | ety sz attr | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | c1 t1 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | c2 t2 | | | | | | | | | | | ]; try discriminate Hal.
      destruct al2; try discriminate Hal.
      apply andb_true_iff in Hal as [Hq Harr].
      apply Pos.eqb_eq in Hq; subst q.
      destruct (type_eq (Tarray ety sz attr) (tarray tfloat 3)) as [Ea | ];
        [ | discriminate Harr ]. rewrite Ea.
      exists c1, t1, c2, t2. reflexivity.
    - right; left. exact Hoc.
    - (* find_water_level *)
      do 2 right; left.
      apply andb_true_iff in Hfwl as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tfloat
                               cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      exact (conj Hfid Efty).
    - (* vec3f_copy ENTRY *)
      do 3 right; left.
      apply andb_true_iff in Hent as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 al0 ]; try discriminate Hal.
      destruct a0 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct tq as [ | | | | | ety sz attr | | | ]; try discriminate Hal.
      destruct al0 as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | | ip tip | | | | | | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Htip].
      apply andb_true_iff in Hal as [Hal Harr].
      apply andb_true_iff in Hal as [Hq Hip].
      apply Pos.eqb_eq in Hq; subst q.
      apply Pos.eqb_eq in Hip; subst ip.
      destruct (type_eq (Tarray ety sz attr) (tarray tfloat 3)) as [Ea | ];
        [ | discriminate Harr ]. rewrite Ea.
      destruct (type_eq tip (tptr tfloat)) as [-> | ]; [ | discriminate Htip ].
      reflexivity.
    - (* vec3f_copy WINDOW *)
      do 4 right; left.
      apply andb_true_iff in Hwin as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                     cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 tail ]; try discriminate Hal.
      destruct a0 as [ | | | | | | | | | | | ef fld tfa | | ];
        try discriminate Hal.
      destruct ef as [ | | | | | | edb edt | | | | | | | ];
        try discriminate Hal.
      destruct edb as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct tail as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct tq as [ | | | | | ety sz attr | | | ]; try discriminate Hal.
      destruct al1; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Hatq].
      apply andb_true_iff in Hal as [Hal Htfa].
      apply andb_true_iff in Hal as [Hal Htsm].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hal Hq].
      apply andb_true_iff in Hal as [Hmp Hfld].
      apply Pos.eqb_eq in Hmp; subst mp.
      apply Pos.eqb_eq in Hfld; subst fld.
      destruct (type_eq tmp tyMSstp) as [-> | ]; [ | discriminate Htmp ].
      destruct (type_eq edt (Tstruct mario_step._MarioState noattr)) as [-> | ];
        [ | discriminate Htsm ].
      destruct (type_eq tfa (tarray tfloat 3)) as [-> | ]; [ | discriminate Htfa ].
      eexists; reflexivity.
    - (* check_ledge_grab *)
      do 5 right; left.
      apply andb_true_iff in Hclg as [H12 Hal].
      apply andb_true_iff in H12 as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty
                  (Tfunction
                     (tyMSstp :: tSurfp :: tptr tfloat :: tptr tfloat :: nil)
                     tuint cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      split; [ exact Hfid | ]. split; [ exact Efty | ].
      destruct al as [ | a0 tail ]; try discriminate Hal.
      destruct a0 as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
      destruct tail as [ | a1 al1 ]; try discriminate Hal.
      destruct a1 as [ | | | | | lw tlw | | | | | | | | ]; try discriminate Hal.
      destruct al1 as [ | a2 al2 ]; try discriminate Hal.
      destruct a2 as [ | | | | | ip tip | | | | | | | | ]; try discriminate Hal.
      destruct al2 as [ | a3 al3 ]; try discriminate Hal.
      destruct a3 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
      destruct tq as [ | | | | | ety sz attr | | | ]; try discriminate Hal.
      destruct al3; try discriminate Hal.
      apply andb_true_iff in Hal as [Hal Harr].
      apply andb_true_iff in Hal as [Hal Htmp].
      apply andb_true_iff in Hal as [Hmp Hq].
      apply Pos.eqb_eq in Hmp; subst mp.
      destruct (type_eq tmp tyMSstp) as [-> | ]; [ | discriminate Htmp ].
      eexists; reflexivity.
    - (* atan2s *)
      do 6 right.
      apply andb_true_iff in Hat as [Hfid Hfty].
      apply Pos.eqb_eq in Hfid.
      destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort
                               cc_default)) as [Efty | ]; [ | discriminate Hfty ].
      exact (conj Hfid Efty).
  Qed.

  (* ---- the gWaterSurfacePseudoFloor special site (paqs spelling, _t'39) -- *)
  Lemma paqs_gwspf_site_pres :
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
              (Sset mario_step._t'39 (Evar mario_step._floor tSurfp))
              (Sassign
                 (Efield
                    (Ederef (Etempvar mario_step._t'39 tSurfp)
                       (Tstruct mario_step._Surface noattr))
                    mario_step._originOffset tfloat)
                 (Etempvar mario_step._floorHeight tfloat))))
        tr le' m' out ->
      carried bm NoA MWF m0 ->
      carried bm NoA MWF m' /\ out = Out_normal /\
      exists vt, le' = PTree.set mario_step._t'39 vt le.
  Proof.
    intros e le m0 tr le' m' out flb flty Hfl Hflloc Hgw Hexec Hc.
    inv Hexec.
    2:{ match goal with
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
    match goal with
    | Hlv : eval_lvalue _ _ _ _ (Evar mario_step._floor _) _ _ _ |- _ => inv Hlv
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
    match goal with
    | Hca : sem_cast _ _ _ _ = Some _ |- _ =>
        apply sem_cast_ptr_ptr_id in Hca; subst
    end.
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
    rewrite paqs_load_result_mptr_ptr in Hload1.
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
    (* statement 2: _t'39 := _floor (reload of the just-stored address) *)
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
    (* statement 3: the store through _t'39 into the GLOBAL block *)
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
  (* THE WALKER: exec-derivation induction over paqs_chk-accepted          *)
  (* statements.  _nextPos is the function's OWN fn_var stack array (FIXED  *)
  (* in the env e via He_np); _m and _intendedPos are threaded le facts     *)
  (* (the marg conditional + the arg1-local pin).  Out-param calls write    *)
  (* the local stack blocks (nextPos/floor/ceil), the m-window stores hit   *)
  (* bm safely, and the gwspf site writes the static global.                *)
  (* ==================================================================== *)
  Lemma paqs_walk_pres :
    forall e npb tynp ipb ipo,
      e ! mario_step._nextPos = Some (npb, tynp) ->
      local_blk lp bm SafeB npb ->
      local_blk lp bm SafeB ipb ->
      (forall l, mem_id l (mario_step._floor :: mario_step._ceil :: nil) = true ->
         exists lblk tyenv, e ! l = Some (lblk, tyenv) /\ local_blk lp bm SafeB lblk) ->
      e ! mario_step._resolve_and_return_wall_collisions = None ->
      e ! mario_step._find_floor = None ->
      e ! mario_step._vec3f_find_ceil = None ->
      e ! mario_step._find_water_level = None ->
      e ! mario_step._vec3f_copy = None ->
      e ! mario_step._check_ledge_grab = None ->
      e ! mario_step._atan2s = None ->
      e ! mario_step._gWaterSurfacePseudoFloor = None ->
      forall s le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        paqs_chk s = true ->
        (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        le ! mario_step._intendedPos = Some (Vptr ipb ipo) ->
        carried bm NoA MWF m0 ->
        carried bm NoA MWF m' /\
        (forall b o, le' ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) /\
        le' ! mario_step._intendedPos = Some (Vptr ipb ipo).
  Proof.
    intros e npb tynp ipb ipo He_np Hnploc Hiploc Hlids
           Hrn Hff Hvfc Hfwl Hvc Hclg Hat Hgw.
    intros s le m0 tr le' m' out Hexec.
    induction Hexec;
      intros Hchk Hm Hip Hc.
    - (* Sskip *) exact (conj Hc (conj Hm Hip)).
    - (* Sassign a1 a2 *)
      cbn [paqs_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      destruct Hc as (HV & HS & HM & HN).
      apply orb_true_iff in Hchk as [Hsf | Hidx].
      + destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm Hip)).
      + destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hidx Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM'))))
                 (conj Hm Hip)).
    - (* Sset id a: id <> _m, _intendedPos (paqs_optid_ok) *)
      cbn [paqs_chk paqs_optid_ok] in Hchk.
      apply andb_true_iff in Hchk as [Hnm Hnip].
      apply negb_true_iff in Hnm; apply negb_true_iff in Hnip.
      refine (conj Hc (conj _ _)).
      + intros b o Hg.
        rewrite PTree.gso in Hg by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnm; discriminate Hnm).
        exact (Hm b o Hg).
      + rewrite PTree.gso by (intro EE; subst id;
          rewrite Pos.eqb_refl in Hnip; discriminate Hnip).
        exact Hip.
    - (* Scall optid a al *)
      cbn [paqs_chk] in Hchk.
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
                    (set_opttemp optid vres le) ! mario_step._intendedPos
                    = Some (Vptr ipb ipo)).
      { cbn [paqs_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply andb_true_iff in Hopt as [Hom Hoip].
          apply negb_true_iff in Hom; apply negb_true_iff in Hoip.
          split.
          + intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hom; discriminate Hom). exact (Hm b o Hg).
          + rewrite PTree.gso by (intro EE; subst oid;
              rewrite Pos.eqb_refl in Hoip; discriminate Hoip). exact Hip.
        - split; [ exact Hm | exact Hip ]. }
      destruct (paqs_call_decode _ _ _ Hcc)
        as [ (Hfeq & Hftyeq & (c1 & t1c & c2 & t2c & Haleq))
           | [ Hoc
             | [ (Hfeq & Hftyeq)
               | [ (Hfeq & Hftyeq & Haleq)
                 | [ (Hfeq & Hftyeq & (tail & Haleq))
                   | [ (Hfeq & Hftyeq & (tail & Haleq))
                     | (Hfeq & Hftyeq) ] ] ] ] ] ].
      + (* resolve(nextPos, c1, c2): ol gate, nextPos local *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Evar mario_step._nextPos (tarray tfloat 3)
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
          pose proof (eval_Evar_arr_val _ _ _ _ _ _ _ He_np Hev_a) as ->.
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
                    (tptr tfloat :: tfloat :: tfloat :: nil) tSurfp cc_default
                    (Evar mario_step._nextPos (tarray tfloat 3)
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
      + (* vec3f_copy(nextPos, intendedPos) ENTRY: ol gate, both local *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Evar mario_step._nextPos (tarray tfloat 3)
               :: Etempvar mario_step._intendedPos (tptr tfloat) :: nil)
              (tptr tfloat :: tptr tfloat :: nil) vargs ->
            args_all_local lp bm SafeB vargs).
        { intros vargs0 Hvl.
          inversion Hvl as [ | a1 bl1 ty1 tyl1 v1a v2a vl1 Hev_a Hsc_a Htl1 ];
            subst; clear Hvl.
          inversion Htl1 as [ | a2 bl2 ty2 tyl2 v1b v2b vl2 Hev_b Hsc_b Htl2 ];
            subst; clear Htl1.
          inversion Htl2; subst; clear Htl2.
          pose proof (eval_Evar_arr_val _ _ _ _ _ _ _ He_np Hev_a) as ->.
          apply RealFrameValue.eval_expr_Etempvar_val in Hev_b;
            rewrite Hip in Hev_b; injection Hev_b as <-.
          intros bb oo Hin; cbn in Hin.
          destruct Hin as [E | [E | []]]; subst;
          [ apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_a;
            injection Hsc_a as <- <-; exact Hnploc
          | apply RealFrameValue.sem_cast_ptr_result_inv in Hsc_b;
            injection Hsc_b as <- <-; exact Hiploc ]. }
        destruct (ol_scall_pres lp bm NoA MWF SafeB optid
                    mario_step._vec3f_copy
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Evar mario_step._nextPos (tarray tfloat 3)
                     :: Etempvar mario_step._intendedPos (tptr tfloat) :: nil)
                    e le m _ _ m' _ Hvc Holcp_v3f Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* vec3f_copy(m->pos, nextPos) WINDOW: w1 gate, dst = m->pos window *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield
                 (Ederef (Etempvar mario_step._m tyMSstp)
                    (Tstruct mario_step._MarioState noattr))
                 mario_step._pos (tarray tfloat 3) :: tail)
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
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Efield
                       (Ederef (Etempvar mario_step._m tyMSstp)
                          (Tstruct mario_step._MarioState noattr))
                       mario_step._pos (tarray tfloat 3) :: tail)
                    e le m _ _ m' _ Hvc Hw1cp_v3f Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' (conj (proj1 HmL) (proj2 HmL))).
      + (* check_ledge_grab(m, ..): internal marg helper *)
        subst fid fty al.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scalln_pres lp bm NoA MWF optid
                    mario_step._check_ledge_grab
                    (tSurfp :: tptr tfloat :: tptr tfloat :: nil) tuint cc_default
                    tail e le m _ _ m' _ Hclg Hex Hcp_clg Hm HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN')))
                 (conj (proj1 HmL) (proj2 HmL))).
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
      cbn [paqs_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [paqs_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hsite | Hchk].
      + (* the gwspf special site *)
        apply paqs_gwspf_site_decode in Hsite.
        injection Hsite as Es1 Es2; subst s1 s2.
        destruct (Hlids mario_step._floor eq_refl)
          as (flb & flty & Hfl & Hflloc).
        match goal with
        | H1 : exec_stmt _ _ _ _ _ _ _ ?le1 ?m1 Out_normal,
          H2 : exec_stmt _ _ _ ?le1 ?m1 _ _ _ _ _ |- _ =>
            pose proof (exec_Sseq_1 function_entry2 (lp_ge lp)
                          _ _ _ _ _ _ _ _ _ _ _ _ H1 H2) as Hexs
        end.
        destruct (paqs_gwspf_site_pres _ _ _ _ _ _ _ _ _
                    Hfl Hflloc Hgw Hexs Hc)
          as (Hc' & _ & (vt & Hle')).
        rewrite Hle'.
        refine (conj Hc' (conj _ _)).
        * intros b o Hg.
          rewrite PTree.gso in Hg by (vm_compute; discriminate).
          exact (Hm b o Hg).
        * rewrite PTree.gso by (vm_compute; discriminate). exact Hip.
      + apply andb_true_iff in Hchk as [H1 H2].
        destruct (IHHexec1 He_np Hlids Hrn Hff Hvfc Hfwl Hvc
                    Hclg Hat Hgw H1 Hm Hip Hc) as (Hc1 & Hm1 & Hip1).
        exact (IHHexec2 He_np Hlids Hrn Hff Hvfc Hfwl Hvc
                 Hclg Hat Hgw H2 Hm1 Hip1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [paqs_chk] in Hchk.
      apply orb_true_iff in Hchk as [Hsite | Hchk].
      + (* site's s1 is an Sassign: it cannot abort *)
        apply paqs_gwspf_site_decode in Hsite.
        injection Hsite as Es1 Es2; subst s1 s2.
        match goal with
        | H1 : exec_stmt _ _ _ _ _ (Sassign _ _) _ _ _ ?o,
          Hne : ?o <> Out_normal |- _ =>
            inv H1; exact (False_ind _ (Hne eq_refl))
        end.
      + apply andb_true_iff in Hchk as [H1 _].
        exact (IHHexec He_np Hlids Hrn Hff Hvfc Hfwl Hvc
                 Hclg Hat Hgw H1 Hm Hip Hc).
    - (* Sifthenelse *)
      cbn [paqs_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc (conj Hm Hip)).
    - (* Sreturn (Some _) *) exact (conj Hc (conj Hm Hip)).
    - (* Sbreak *) exact (conj Hc (conj Hm Hip)).
    - (* Scontinue *) exact (conj Hc (conj Hm Hip)).
    - (* Sloop stop1: rejected *)
      cbn [paqs_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [paqs_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [paqs_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [paqs_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE DISCHARGE: the whole body preserves carried under the paqs gate.   *)
  (* function_entry2 allocs _nextPos/_ceil/_floor and binds                 *)
  (* _m/_intendedPos/_stepArg; arg0_marg_p gives the _m conditional,        *)
  (* arg1_local the _intendedPos pin; alloc_variables_hlocal the local      *)
  (* out-param blocks.  paqs_walk_pres walks; free at exit.                 *)
  (* ==================================================================== *)
  Lemma paqs_cp :
    call_pres_paqs lp bm NoA MWF SafeB mario_step._perform_air_quarter_step.
  Proof.
    unfold call_pres_paqs.
    intros fd m0 vargs0 t0 m1 vres0 Hevf Hres Hgate HN HM HV HS.
    pose proof (OutParamSurface.resolve_pin_fd lp mario_step.prog _
                  mario_step.f_perform_air_quarter_step fd LO_stp paqs_pin Hres)
      as ->.
    destruct Hgate as (Hcond & Hlocal).
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
    unfold mario_step.f_perform_air_quarter_step in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried bm NoA MWF m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _nextPos fn_var: a watched-disjoint stack array block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._nextPos :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hnp_all.
    destruct (Hnp_all mario_step._nextPos eq_refl)
      as (npb & tynp & He_np & Hnploc).
    (* the _floor/_ceil fn_vars: watched-disjoint stack blocks *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._floor :: mario_step._ceil :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hmem];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_cons; apply in_eq
                        | apply Bool.orb_true_iff in Hmem;
                          destruct Hmem as [He | Hf];
                          [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                            apply in_cons; apply in_eq
                          | discriminate Hf ] ]))
      as Hlids.
    (* bind the 3 params _m, _intendedPos, _stepArg *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_ip vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2 as [| v_sa vr3];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr3; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_step._m = Some v_m)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate);
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    assert (Hipeq : le1 ! mario_step._intendedPos = Some v_ip)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    (* _m conditional from arg0_marg_p *)
    cbn [arg0_marg_p] in Hcond.
    assert (Hmcond : forall b o,
               le1 ! mario_step._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero)
      by (intros b o Hg; rewrite Hmeq in Hg; injection Hg as Hg;
          apply (Hcond b o Hg)).
    (* _intendedPos local from arg1_local *)
    cbn [arg1_local arg1_val] in Hlocal.
    destruct Hlocal as (ipb & ipo & Hvip & Hiploc).
    injection Hvip as Hvip; subst v_ip.
    (* the 7 callees + the gwspf global are unbound in the entry env *)
    assert (Hrn : eloc !
              mario_step._resolve_and_return_wall_collisions = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._resolve_and_return_wall_collisions)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hff : eloc ! mario_step._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._find_floor)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvfc : eloc ! mario_step._vec3f_find_ceil = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_find_ceil)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hfwl : eloc ! mario_step._find_water_level = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._find_water_level)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvc : eloc ! mario_step._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_copy)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hclg : eloc ! mario_step._check_ledge_grab = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._check_ledge_grab)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hat : eloc ! mario_step._atan2s = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._atan2s)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hgwn : eloc ! mario_step._gWaterSurfacePseudoFloor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._gWaterSurfacePseudoFloor)
        by (cbn; intros [HH | [HH | [HH | []]]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried bm NoA MWF me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (paqs_walk_pres eloc npb tynp ipb ipo He_np Hnploc Hiploc Hlids
                Hrn Hff Hvfc Hfwl Hvc Hclg Hat Hgwn _ _ _ _ _ _ _
                Hbody paqs_chk_body Hmcond Hipeq Hcar)
      as (Hcarr & _ & _).
    (* ---- exit: free the 3 fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ _ Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf (conj HMf HNf))).
  Qed.

End PaqsSurface.

(* ====================================================================== *)
(* ======================= check_ledge_grab (clg) ====================== *)
(* paqs's one deeper INTERNAL callee (mario_step.v:2493, Internal in       *)
(* mario_step.prog).  A bool-returning ledge-grab predicate with its OWN   *)
(* fn_vars (_ledgeFloor : Surface*, _ledgePos : f32[3] stack array).  4     *)
(* params (m, wall, intendedPos, nextPos): only _m is gated (marg) -- the   *)
(* others are READ-ONLY pointer params (loads off them are memory-blind).  *)
(* The body, on the full-success path, writes m->pos (vec3f_copy WINDOW,    *)
(* w1) / m->floor (pointer field, safe window) / m->floorHeight /           *)
(* m->floorAngle (safe fields) / m->faceAngle[i] (short idx, idx16) plus    *)
(* its OWN _ledgePos[i] stack stores (local idx); its sole gated calls are  *)
(* find_floor(...,&_ledgeFloor) (oc, out-param into local), the WINDOW      *)
(* vec3f_copy(&m->pos,_ledgePos) (w1), and atan2s (ungated math ext).  The  *)
(* gate is just marg (call_pres already carries marg_ok) -- no arg1_local   *)
(* like paqs, since the w1 vec3f_copy uses m->pos (window) not a param.     *)
(* ====================================================================== *)

Lemma clg_pin :
  (prog_defmap mario_step.prog) ! mario_step._check_ledge_grab
  = Some (Gfun (Internal mario_step.f_check_ledge_grab)).
Proof. vm_compute. reflexivity. Qed.

Definition clg_call_chk (fid : ident) (fty : type) (al : list expr) : bool :=
  (* find_floor(x, y, z, &_ledgeFloor) -- oc out-param into local _ledgeFloor *)
  oc_call_chk (mario_step._ledgeFloor :: nil)
    (mario_step._find_floor :: nil) fid fty al
  || (* vec3f_copy(&m->pos, _ledgePos) -- w1 window dst, local src *)
     (Pos.eqb fid mario_step._vec3f_copy
      && proj_sumbool
           (type_eq fty
              (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                 cc_default))
      && match al with
         | Efield (Ederef (Etempvar mp tmp) tsm) fld tfa
           :: Evar q (Tarray ety sz attr) :: nil =>
             Pos.eqb mp mario_step._m
             && Pos.eqb fld mario_step._pos
             && Pos.eqb q mario_step._ledgePos
             && proj_sumbool (type_eq tmp tyMSstp)
             && proj_sumbool (type_eq tsm (Tstruct mario_step._MarioState noattr))
             && proj_sumbool (type_eq tfa (tarray tfloat 3))
             && proj_sumbool (type_eq (Tarray ety sz attr) (tarray tfloat 3))
         | _ => false
         end)
  || (* atan2s: ungated pure-math external *)
     (Pos.eqb fid mario_step._atan2s
      && proj_sumbool
           (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))).

Definition clg_optid_ok (optid : option ident) : bool :=
  match optid with
  | Some id => negb (Pos.eqb id mario_step._m)
  | None => true
  end.

Fixpoint clg_chk (s : statement) : bool :=
  match s with
  | Sskip | Sbreak | Scontinue => true
  | Sreturn _ => true
  | Ssequence s1 s2 => clg_chk s1 && clg_chk s2
  | Sifthenelse _ s1 s2 => clg_chk s1 && clg_chk s2
  | Sset id _ => clg_optid_ok (Some id)
  | Sassign a1 _ =>
      safe_mfield_store mario_step._m a1
      || idx_mfield_store mario_step._m a1
      || idx16_mfield_store mario_step._m a1
      || local_idx_store_chk (mario_step._ledgePos :: nil) a1
  | Scall optid (Evar fid fty) al =>
      clg_optid_ok optid && clg_call_chk fid fty al
  | _ => false
  end.

Lemma clg_chk_body : clg_chk (fn_body mario_step.f_check_ledge_grab) = true.
Proof. vm_compute. reflexivity. Qed.

Lemma clg_call_decode :
  forall fid fty al, clg_call_chk fid fty al = true ->
    oc_call_chk (mario_step._ledgeFloor :: nil)
      (mario_step._find_floor :: nil) fid fty al = true
    \/ (fid = mario_step._vec3f_copy /\
        fty = Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                cc_default /\
        exists tail,
          al = Efield
                 (Ederef (Etempvar mario_step._m tyMSstp)
                    (Tstruct mario_step._MarioState noattr))
                 mario_step._pos (tarray tfloat 3) :: tail)
    \/ (fid = mario_step._atan2s /\
        fty = Tfunction (tfloat :: tfloat :: nil) tshort cc_default).
Proof.
  intros fid fty al H. unfold clg_call_chk in H.
  apply orb_true_iff in H as [H | Hat].
  apply orb_true_iff in H as [Hoc | Hwin].
  - (* oc: find_floor *) left. exact Hoc.
  - (* vec3f_copy WINDOW *)
    right; left.
    apply andb_true_iff in Hwin as [H12 Hal].
    apply andb_true_iff in H12 as [Hfid Hfty].
    apply Pos.eqb_eq in Hfid.
    destruct (type_eq fty
                (Tfunction (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid)
                   cc_default)) as [Efty | ]; [ | discriminate Hfty ].
    split; [ exact Hfid | ]. split; [ exact Efty | ].
    destruct al as [ | a0 tail ]; try discriminate Hal.
    destruct a0 as [ | | | | | | | | | | | ef fld tfa | | ];
      try discriminate Hal.
    destruct ef as [ | | | | | | edb edt | | | | | | | ];
      try discriminate Hal.
    destruct edb as [ | | | | | mp tmp | | | | | | | | ]; try discriminate Hal.
    destruct tail as [ | a1 al1 ]; try discriminate Hal.
    destruct a1 as [ | | | | q tq | | | | | | | | | ]; try discriminate Hal.
    destruct tq as [ | | | | | ety sz attr | | | ]; try discriminate Hal.
    destruct al1; try discriminate Hal.
    apply andb_true_iff in Hal as [Hal Hatq].
    apply andb_true_iff in Hal as [Hal Htfa].
    apply andb_true_iff in Hal as [Hal Htsm].
    apply andb_true_iff in Hal as [Hal Htmp].
    apply andb_true_iff in Hal as [Hal Hq].
    apply andb_true_iff in Hal as [Hmp Hfld].
    apply Pos.eqb_eq in Hmp; subst mp.
    apply Pos.eqb_eq in Hfld; subst fld.
    destruct (type_eq tmp tyMSstp) as [-> | ]; [ | discriminate Htmp ].
    destruct (type_eq edt (Tstruct mario_step._MarioState noattr)) as [-> | ];
      [ | discriminate Htsm ].
    destruct (type_eq tfa (tarray tfloat 3)) as [-> | ]; [ | discriminate Htfa ].
    exists (Evar q (Tarray ety sz attr) :: nil). reflexivity.
  - (* atan2s *)
    right; right.
    apply andb_true_iff in Hat as [Hfid Hfty].
    apply Pos.eqb_eq in Hfid.
    destruct (type_eq fty (Tfunction (tfloat :: tfloat :: nil) tshort cc_default))
      as [Efty | ]; [ | discriminate Hfty ].
    exact (conj Hfid Efty).
Qed.

Section ClgSurface.
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

  (* the gated-external callee rows: find_floor (oc out-param), the WINDOW
     vec3f_copy (w1 dst), atan2s (ungated math ext) -- the SAME rows the
     pgqs walk consumes (shared at the capstone). *)
  Hypothesis Hocp_ff :
    call_pres_ext_oc lp bm NoA MWF SafeB mario_step._find_floor.
  Hypothesis Hw1cp_v3f :
    call_pres_ext_w1 lp bm NoA MWF mario_step._vec3f_copy.
  Hypothesis Hcpx_atan2s :
    call_pres_ext lp bm NoA MWF mario_step._atan2s.

  Notation carried := (carried bm NoA MWF).

  (* ==================================================================== *)
  (* THE WALKER (the pas shape: marg-only _m tracking + local stores).    *)
  (* ==================================================================== *)
  Lemma clg_walk_pres :
    forall lfb lfty lpb lpty,
      local_blk lp bm SafeB lfb ->
      local_blk lp bm SafeB lpb ->
      forall s e le m0 tr le' m' out,
        exec_stmt function_entry2 (lp_ge lp) e le m0 s tr le' m' out ->
        clg_chk s = true ->
        e ! mario_step._find_floor = None ->
        e ! mario_step._vec3f_copy = None ->
        e ! mario_step._atan2s = None ->
        e ! mario_step._ledgeFloor = Some (lfb, lfty) ->
        e ! mario_step._ledgePos = Some (lpb, lpty) ->
        (forall b o, le ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero) ->
        carried m0 ->
        carried m' /\
        (forall b o, le' ! mario_step._m = Some (Vptr b o) ->
                     b = bm /\ o = Ptrofs.zero).
  Proof.
    intros lfb lfty lpb lpty Hlfloc Hlploc s e le m0 tr le' m' out Hexec.
    induction Hexec; intros Hchk Hff Hvc Hat Hlf Hlp Hm Hc.
    - (* Sskip *) exact (conj Hc Hm).
    - (* Sassign a1 a2 *)
      cbn [clg_chk] in Hchk.
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Sassign a1 a2) E0 le m' Out_normal)
        by (econstructor; eauto).
      apply orb_true_iff in Hchk as [Hchk | Hloc].
      apply orb_true_iff in Hchk as [Hchk | Hi16].
      apply orb_true_iff in Hchk as [Hsf | Hidx].
      + (* safe Mario-field store: value-blind epi *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hsf Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* float indexed Mario-field store *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (idx_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hidx Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* short faceAngle[i] indexed Mario-field store *)
        destruct Hc as (HV & HS & HM & HN).
        destruct (idx16_assign_pres lp LO_mario bm MWF HMWF_window
                    a1 a2 _ _ _ _ _ _ _ Hi16 Hm Hex HM HV HS)
          as (HV' & HS' & HM' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' (HNoA_of_MWF _ HM')))) Hm).
      + (* local _ledgePos[i] indexed stack store *)
        destruct (local_idx_store_chk_shape _ _ Hloc)
          as (lid & ety & sz & attr & idxN & itya & ety2 & ch & Ha1 & Hlidmem
              & Hacc).
        cbn [mem_id existsb] in Hlidmem.
        apply orb_true_iff in Hlidmem as [Eg | F];
          [ apply Pos.eqb_eq in Eg; subst lid | discriminate F ].
        subst a1.
        destruct (local_idx_assign_pres' lp bm NoA MWF SafeB Hls_real
                    HNoA_of_MWF e mario_step._ledgePos ety sz attr idxN itya
                    ety2 a2 le m E0 le m' Out_normal lpb lpty ch
                    Hlp Hlploc Hacc Hex Hc) as (Hc' & _ & _).
        exact (conj Hc' Hm).
    - (* Sset id a: id <> _m (clg_optid_ok) *)
      cbn [clg_chk clg_optid_ok] in Hchk.
      apply negb_true_iff in Hchk.
      refine (conj Hc _).
      intros b o Hg.
      rewrite PTree.gso in Hg by (intro EE; subst id; rewrite Pos.eqb_refl in Hchk;
                                  discriminate Hchk).
      exact (Hm b o Hg).
    - (* Scall optid a al *)
      cbn [clg_chk] in Hchk.
      destruct a as [ | | | | fid fty | | | | | | | | | ]; try discriminate Hchk.
      apply andb_true_iff in Hchk as [Hopt Hcc].
      assert (Hex : exec_stmt function_entry2 (lp_ge lp) e le m
                      (Scall optid (Evar fid fty) al) t (set_opttemp optid vres le)
                      m' Out_normal)
        by (econstructor; eauto).
      assert (HmL : forall b o,
                 (set_opttemp optid vres le) ! mario_step._m
                 = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero).
      { cbn [clg_optid_ok] in Hopt.
        destruct optid as [oid | ]; cbn [set_opttemp].
        - apply negb_true_iff in Hopt.
          intros b o Hg. rewrite PTree.gso in Hg by (intro EE; subst oid;
            rewrite Pos.eqb_refl in Hopt; discriminate Hopt). exact (Hm b o Hg).
        - exact Hm. }
      destruct (clg_call_decode _ _ _ Hcc)
        as [ Hoc | [ (Hfeq & Hftyeq & (tail & Haleq)) | (Hfeq & Hftyeq) ] ].
      + (* oc: find_floor (out-param = &_ledgeFloor local) *)
        assert (Hcp_oc : forall g,
                  mem_id g (mario_step._find_floor :: nil) = true ->
                  call_pres_ext_oc lp bm NoA MWF SafeB g).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hocp_ff | discriminate F ]. }
        assert (Hnone : forall g,
                  mem_id g (mario_step._find_floor :: nil) = true ->
                  e ! g = None).
        { intros g Hg. cbn [mem_id existsb] in Hg.
          apply orb_true_iff in Hg as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst g; exact Hff | discriminate F ]. }
        assert (Hlocal : forall l,
                  mem_id l (mario_step._ledgeFloor :: nil) = true ->
                  exists lblk tyenv, e ! l = Some (lblk, tyenv) /\
                                     local_blk lp bm SafeB lblk).
        { intros l Hl. cbn [mem_id existsb] in Hl.
          apply orb_true_iff in Hl as [Eg | F];
            [ apply Pos.eqb_eq in Eg; subst l | discriminate F ].
          exists lfb, lfty. exact (conj Hlf Hlfloc). }
        destruct (oc_call_chk_pres lp bm NoA MWF SafeB
                    (mario_step._ledgeFloor :: nil)
                    (mario_step._find_floor :: nil)
                    optid fid fty al e le m _ _ m' _
                    Hcp_oc Hnone Hlocal Hoc Hex Hc) as (Hc' & _).
        exact (conj Hc' HmL).
      + (* vec3f_copy(m->pos, _ledgePos) WINDOW: w1 gate, dst = m->pos window *)
        subst fid fty al.
        assert (Hgate : forall vargs,
            eval_exprlist (lp_ge lp) e le m
              (Efield
                 (Ederef (Etempvar mario_step._m tyMSstp)
                    (Tstruct mario_step._MarioState noattr))
                 mario_step._pos (tarray tfloat 3) :: tail)
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
                    (tptr tfloat :: tptr tfloat :: nil) (tptr tvoid) cc_default
                    (Efield
                       (Ederef (Etempvar mario_step._m tyMSstp)
                          (Tstruct mario_step._MarioState noattr))
                       mario_step._pos (tarray tfloat 3) :: tail)
                    e le m _ _ m' _ Hvc Hw1cp_v3f Hgate Hex Hc)
          as (Hc' & _).
        exact (conj Hc' HmL).
      + (* atan2s: ungated pure-math external *)
        subst fid fty.
        destruct Hc as (HV & HS & HM & HN).
        destruct (kit_scallx_pres lp bm NoA MWF optid mario_step._atan2s
                    (tfloat :: tfloat :: nil) tshort cc_default
                    al e le m _ _ m' _ Hat Hex Hcpx_atan2s HN HM HV HS)
          as (HV' & HS' & HM' & HN' & _ & _).
        exact (conj (conj HV' (conj HS' (conj HM' HN'))) HmL).
    - (* Sbuiltin: rejected *)
      cbn [clg_chk] in Hchk. discriminate Hchk.
    - (* Sseq_1 *)
      cbn [clg_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      destruct (IHHexec1 H1 Hff Hvc Hat Hlf Hlp Hm Hc) as (Hc1 & Hm1).
      exact (IHHexec2 H2 Hff Hvc Hat Hlf Hlp Hm1 Hc1).
    - (* Sseq_2 (s1 aborts) *)
      cbn [clg_chk] in Hchk. apply andb_true_iff in Hchk as [H1 _].
      exact (IHHexec H1 Hff Hvc Hat Hlf Hlp Hm Hc).
    - (* Sifthenelse *)
      cbn [clg_chk] in Hchk. apply andb_true_iff in Hchk as [H1 H2].
      apply IHHexec; try assumption.
      destruct b; assumption.
    - (* Sreturn None *) exact (conj Hc Hm).
    - (* Sreturn (Some _) *) exact (conj Hc Hm).
    - (* Sbreak *) exact (conj Hc Hm).
    - (* Scontinue *) exact (conj Hc Hm).
    - (* Sloop stop1: rejected *)
      cbn [clg_chk] in Hchk. discriminate Hchk.
    - (* Sloop stop2: rejected *)
      cbn [clg_chk] in Hchk. discriminate Hchk.
    - (* Sloop loop: rejected *)
      cbn [clg_chk] in Hchk. discriminate Hchk.
    - (* Sswitch: rejected *)
      cbn [clg_chk] in Hchk. discriminate Hchk.
  Qed.

  (* ==================================================================== *)
  (* THE DISCHARGE: body_pres, then call_pres via call_pres_of_body.       *)
  (* function_entry2 allocs _ledgeFloor/_ledgePos and binds the 4 params;  *)
  (* marg_ok gives the _m conditional; alloc_variables_hlocal gives the    *)
  (* fn_var localities; clg_walk_pres walks; free at exit.                 *)
  (* ==================================================================== *)
  Lemma clg_body_pres :
    RestSurface.body_pres lp NoA MWF bm mario_step.f_check_ledge_grab.
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
    unfold mario_step.f_check_ledge_grab in Hbind, Halloc.
    cbn [fn_params fn_temps fn_vars] in Hbind, Halloc.
    match goal with H : alloc_variables _ _ _ _ ?E ?ME |- _ =>
      set (eloc := E) in *; set (me := ME) in * end.
    assert (Hc0 : carried m0)
      by (split; [ exact HV | split; [ exact HS
                 | split; [ exact HM | exact HN ] ] ]).
    pose proof (alloc_variables_carried bm NoA MWF HMWF_alloc HNoA_of_MWF
                  _ _ _ _ _ _ Halloc Hc0) as Hce.
    destruct Hce as (HVe & HSe & HMe & HNe).
    (* the _ledgeFloor fn_var: a watched-disjoint stack block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._ledgeFloor :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_eq
                        | discriminate Hf ]))
      as Hlf_all.
    destruct (Hlf_all mario_step._ledgeFloor eq_refl)
      as (lfb & lfty & Hlf & Hlfloc).
    (* the _ledgePos fn_var: a watched-disjoint stack array block *)
    pose proof (alloc_variables_hlocal lp bm SafeB m0 _ eloc _
                  (mario_step._ledgePos :: nil)
                  Halloc HV (HSafeValid m0 HM) (HGlobValid m0 HM)
                  ltac:(intros lid Hmem; unfold mem_id in Hmem;
                        cbn [existsb] in Hmem;
                        apply Bool.orb_true_iff in Hmem;
                        destruct Hmem as [He | Hf];
                        [ apply Pos.eqb_eq in He; subst lid; cbn [map fst];
                          apply in_cons; apply in_eq
                        | discriminate Hf ]))
      as Hlp_all.
    destruct (Hlp_all mario_step._ledgePos eq_refl)
      as (lpb & lpty & Hlp & Hlploc).
    (* bind the 4 params _m, _wall, _intendedPos, _nextPos *)
    destruct vargs0 as [| v_m vr1];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr1 as [| v_w vr2];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr2 as [| v_ip vr3];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr3 as [| v_np vr4];
      cbn [bind_parameter_temps] in Hbind; [ discriminate Hbind | ].
    destruct vr4; [ | cbn [bind_parameter_temps] in Hbind;
                      discriminate Hbind ].
    injection Hbind as Hle_init.
    assert (Hmeq : le1 ! mario_step._m = Some v_m)
      by (rewrite <- Hle_init;
          rewrite PTree.gso by (vm_compute; discriminate);
          rewrite PTree.gso by (vm_compute; discriminate);
          rewrite PTree.gso by (vm_compute; discriminate); apply PTree.gss).
    (* _m conditional from marg_ok *)
    assert (Hmcond : forall b o,
               le1 ! mario_step._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hg. rewrite Hmeq in Hg. injection Hg as Hg.
      subst v_m. exact Hmarg. }
    (* the 3 callees are unbound globals in the entry env *)
    assert (Hff : eloc ! mario_step._find_floor = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._find_floor)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hvc : eloc ! mario_step._vec3f_copy = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._vec3f_copy)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hat : eloc ! mario_step._atan2s = None).
    { rewrite (alloc_variables_unbound (lp_ge lp) m0 _ empty_env _ _ Halloc
                 mario_step._atan2s)
        by (cbn; intros [HH | [HH | []]]; vm_compute in HH; discriminate HH).
      apply PTree.gempty. }
    assert (Hcar : carried me)
      by (split; [ exact HVe | split; [ exact HSe
                 | split; [ exact HMe | exact HNe ] ] ]).
    (* ---- WALK the body ---- *)
    destruct (clg_walk_pres lfb lfty lpb lpty Hlfloc Hlploc _ _ _ _ _ _ _ _
                Hbody clg_chk_body Hff Hvc Hat Hlf Hlp Hmcond Hcar)
      as (Hcarr & _).
    (* ---- exit: free the 2 fn_var stack blocks ---- *)
    destruct Hcarr as (HVb & HSb & HMb & HNb).
    pose proof (blocks_of_env_bm lp bm m0 _ eloc _ Halloc HV) as Hforall.
    pose proof (free_list_carried_bm bm NoA MWF HMWF_free HNoA_of_MWF
                  (blocks_of_env (lp_ge lp) eloc) _ mF Hforall Hfree
                  (conj HVb (conj HSb (conj HMb HNb))))
      as (HVf & HSf & HMf & HNf).
    exact (conj HVf (conj HSf HMf)).
  Qed.

  Lemma clg_cp :
    DispatchKit.call_pres lp bm NoA MWF mario_step._check_ledge_grab.
  Proof.
    exact (DispatchKit.call_pres_of_body lp bm NoA MWF HNoA_of_MWF
             mario_step.prog mario_step._check_ledge_grab
             mario_step.f_check_ledge_grab LO_stp clg_pin clg_body_pres).
  Qed.

End ClgSurface.
