(* ====================================================================== *)
(* LandingBricks.v  --  UNWIRED scaffolding for the LANDING KEYSTONE.       *)
(*                                                                        *)
(* The 9 moving `act_*_land` leaves (jump/freefall/side_flip/hold_jump/    *)
(* hold_freefall/long_jump/double_jump/triple_jump/backflip) all call      *)
(*   common_landing_cancels(m, &sXLandAction, set_jumping_action)          *)
(* followed by common_landing_action(m, anim, UNTAINTED_const).            *)
(*                                                                        *)
(* common_landing_cancels (mario_actions_moving.v:11078) LOADS its action  *)
(* values out of the `landingAction` POINTER PARAM struct                  *)
(*   (landingAction->{verySteepAction,slideAction,endAction,offFloorAction})*)
(* and set_mario_action's them, so it is NOT a generic call_pres (false    *)
(* for a tainted-field landingAction).  It is a PER-LEAF, PER-GLOBAL fact: *)
(* each leaf passes a SPECIFIC landing global (sJumpLandAction, ...), whose *)
(* int32 action fields are UNTAINTED -- pinned by MWFReal R10              *)
(* (knockback_table_ids was enlarged with the 9 LandingAction globals in   *)
(* commit 9289c03; mwf_real_ktab is the offset-free projection).           *)
(*                                                                        *)
(* This file holds the TWO reusable bricks proven for that walk:           *)
(*   landing_field_load_untainted -- a u32 landingAction->fld load yields  *)
(*       an untainted scalar (handles the abstract-lp struct field load    *)
(*       incl. the bitfield deref_loc case WITHOUT pinning the LandingAction*)
(*       composite, which OOMs);                                           *)
(*   setter_block_pres -- the guarded global-load setter block             *)
(*       `if (cond) return SETTER(m, landingAction->fld, 0); [else]`       *)
(*       (SETTER = set_mario_action / mario_push_off_steep_floor) preserves.*)
(* Plus the local clean exec_stmt inversion helpers they rest on.          *)
(*                                                                        *)
(* STATUS: scaffolding.  NOTHING on the capstone consumes these yet.       *)
(* The remaining wiring is a genuine multi-step arc:                       *)
(*   (a) a non-indexed window-store brick (m->doubleJumpTimer/actionTimer);*)
(*   (b) assemble clc_body_pres over the full ~190-line body (2 window     *)
(*       stores + chase load + should_begin_sliding call + 5 setter blocks *)
(*       + the input&2 indirect-call kill via AGates.clc_indirect_call_dead*)
(*       _lp + return);                                                    *)
(*   (c) a bespoke 3-param funcall lift (fn_vars=nil => env=empty_env)      *)
(*       SPECIALIZED to landingAction = &(ktab global);                    *)
(*   (d) common_landing_action act3 row;                                   *)
(*   (e) 2 thin leaf rows (act_jump_land, act_freefall_land -- the clean    *)
(*       pair) wired into MovingLeafSurface's mov_rest dispatch.           *)
(* When landed, this file is promoted out of Unwired/ (git mv up).         *)
(* The section's abstract kit mirrors ActWriterSurface.Section             *)
(* ActWriterWalk + the HMWF_ktab row (discharged at the capstone via       *)
(* MWFReal.mwf_real_ktab -- NO new trust).                                 *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking Errors.
From SM64.Proofs Require Import SymbolicLinking Flying Taint CensusV2
  RealFrameLinked RealFrameValue ActionValueFrame AirborneSurface
  ActWriterSurface MWFReal AGates.
From SM64.Generated Require mario mario_step mario_actions_moving interaction.
Import ListNotations.
Local Open Scope Z_scope.
Module M := mario_actions_moving.

(* ---- helper-body walks the landing keystone bottoms out in ---- *)
Example mfd_walk :
  wwalk_chk false nil nil nil nil nil nil nil
    (fn_body mario.f_mario_facing_downhill) = true.
Proof. vm_compute. reflexivity. Qed.

Example sbs_walk :
  wwalk_chk false nil (M._mario_facing_downhill :: nil) nil nil nil nil nil
    (fn_body M.f_should_begin_sliding) = true.
Proof. vm_compute. reflexivity. Qed.

Example push_walk :
  wwalk_chk true (mario_step._action :: mario_step._t'2 :: nil)
    nil (mario_step._set_mario_action :: nil) nil nil nil nil
    (fn_body mario_step.f_mario_push_off_steep_floor) = true.
Proof. vm_compute. reflexivity. Qed.

Section LandingWalk.
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.
  Hypothesis LO_mario_step : linkorder mario_step.prog lp.
  Hypothesis LO_mov : linkorder mario_actions_moving.prog lp.

  Variable bm : block.
  Variable NoA MWF : mem -> Prop.

  Hypothesis HNoA_of_MWF : forall m, MWF m -> NoA m.
  Hypothesis HMWF_window : forall mm mm' ch (delta : Z) vv,
      MWF mm -> store_window_ok delta (size_chunk ch) = true ->
      Mem.store ch mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_glob : forall gid,
      mem_id gid stored_globals = true ->
      forall bg, Genv.find_symbol (lp_ge lp) gid = Some bg ->
      bg <> bm /\
      (forall mm mm' ch0 (d : Z) vv,
          MWF mm -> Mem.store ch0 mm bg d vv = Some mm' -> MWF mm').
  Hypothesis HMWF_act : forall mm mm' vv,
      MWF mm ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store Mint32 mm bm 12 vv = Some mm' -> MWF mm'.
  Variable SafeB : block -> Prop.
  Hypothesis HSafeNotBm : forall b, SafeB b -> b <> bm.
  Hypothesis HchaseRoot : forall fld delta m b' o',
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      MWF m ->
      Mem.loadv Mptr m
        (Vptr bm (Ptrofs.add Ptrofs.zero (Ptrofs.repr delta)))
        = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv <> Vptr bb oo) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_root : forall mm mm' fld (delta : Z) vv,
      mem_id fld chase_root_fields = true ->
      field_offset (prog_comp_env mario.prog) fld mario_state_members
        = OK (delta, Full) ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      MWF mm ->
      Mem.store Mptr mm bm delta vv = Some mm' -> MWF mm'.
  Hypothesis HMWF_sglob : forall m gb v,
      MWF m ->
      Genv.find_symbol (lp_ge lp) interaction._gGlobalTimer = Some gb ->
      Mem.load Mint32 m gb 0 = Some v ->
      forall bb oo, v <> Vptr bb oo.
  Hypothesis HchaseStep : forall m b ofs b' o',
      MWF m -> SafeB b ->
      Mem.loadv Mptr m (Vptr b ofs) = Some (Vptr b' o') ->
      SafeB b'.
  Hypothesis HMWF_chase_safe : forall mm ch bsafe (d : Z) vv mm',
      MWF mm -> SafeB bsafe ->
      (forall bb oo, vv = Vptr bb oo -> SafeB bb) ->
      Mem.store ch mm bsafe d vv = Some mm' -> MWF mm'.

  (* the NEW kit row: an Mint32 load from a knockback_table_ids block is an
     UNTAINTED scalar.  Discharged at the capstone via MWFReal.mwf_real_ktab
     (the LandingAction globals were folded into knockback_table_ids in
     commit 9289c03) -- NO new trust. *)
  Hypothesis HMWF_ktab : forall m gid kb (ofs : Z) v,
      MWF m -> mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some kb ->
      Mem.load Mint32 m kb ofs = Some v ->
      v = Vundef \/ exists vi, v = Vint vi /\ not_tainted vi.

  Let Hsmact : call_pres_act lp bm NoA MWF mario._set_mario_action :=
    smact_pres lp LO_mario LO_mario_step bm NoA MWF HNoA_of_MWF
      HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
      HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe.

  Notation tyMSp := (tptr (Tstruct mario._MarioState noattr)).

  (* ---- local clean exec_stmt inversion helpers (lp-specialized) ---- *)
  Lemma exec_seq_cases :
    forall e le m s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Ssequence s1 s2) tr le' m' out ->
      (exists tr1 le1 m1 tr2,
          exec_stmt function_entry2 (lp_ge lp) e le m s1 tr1 le1 m1 Out_normal /\
          exec_stmt function_entry2 (lp_ge lp) e le1 m1 s2 tr2 le' m' out)
      \/ (exec_stmt function_entry2 (lp_ge lp) e le m s1 tr le' m' out /\
          out <> Out_normal).
  Proof.
    intros e le m s1 s2 tr le' m' out H; inv H.
    - left; do 4 eexists; split; eassumption.
    - right; split; assumption.
  Qed.

  Lemma exec_set_inv :
    forall e le m t a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sset t a) tr le' m' out ->
      exists v, eval_expr (lp_ge lp) e le m a v /\
                le' = PTree.set t v le /\ m' = m /\ out = Out_normal.
  Proof. intros e le m t a tr le' m' out H; inv H. eexists; repeat split; eauto. Qed.

  Lemma exec_if_inv :
    forall e le m c s1 s2 tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sifthenelse c s1 s2) tr le' m' out ->
      exists b,
        exec_stmt function_entry2 (lp_ge lp) e le m (if b : bool then s1 else s2)
          tr le' m' out.
  Proof. intros e le m c s1 s2 tr le' m' out H; inv H; eexists; eassumption. Qed.

  Lemma exec_skip_inv :
    forall e le m tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m Sskip tr le' m' out ->
      le' = le /\ m' = m /\ out = Out_normal.
  Proof. intros e le m tr le' m' out H; inv H; auto. Qed.

  Lemma exec_call_normal :
    forall e le m optid a al tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Scall optid a al) tr le' m' out ->
      out = Out_normal.
  Proof. intros e le m optid a al tr le' m' out H; inv H; reflexivity. Qed.

  Lemma exec_return_inv :
    forall e le m a tr le' m' out,
      exec_stmt function_entry2 (lp_ge lp) e le m (Sreturn a) tr le' m' out ->
      le' = le /\ m' = m /\ out <> Out_normal.
  Proof.
    intros e le m a tr le' m' out H; inv H;
      (split; [ reflexivity | split; [ reflexivity | discriminate ] ]).
  Qed.

  (* a u32 LandingAction-field load out of the landing global lb is an
     untainted scalar (its block lb's Mint32 contents are untainted by R10
     / HMWF_ktab; the field offset is irrelevant -- R10 is offset-free). *)
  Lemma landing_field_load_untainted :
    forall gid lb fld e le m v,
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some lb ->
      le ! M._landingAction = Some (Vptr lb Ptrofs.zero) ->
      MWF m ->
      eval_expr (lp_ge lp) e le m
        (Efield
           (Ederef
              (Etempvar M._landingAction (tptr (Tstruct M._LandingAction noattr)))
              (Tstruct M._LandingAction noattr)) fld tuint) v ->
      untainted_scalar v.
  Proof.
    intros gid lb fld e le m v Hgid Hsym Hla HM Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv
      as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb0 & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ].
    subst lb0 ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb.
    rewrite Hla in Hlvb. inv Hlvb.
    (* the field load is a Mint32 loadv from the landing block lb. *)
    inv Hderef.
    - (* deref_loc_value *)
      match goal with
      | Hac : access_mode _ = By_value ?chunk,
        Hld : Mem.loadv ?chunk m (Vptr ?b ?ofs) = Some v |- _ =>
          cbn in Hac; inv Hac;
          change (Mem.loadv Mint32 m (Vptr b ofs))
            with (Mem.load Mint32 m b (Ptrofs.unsigned ofs)) in Hld;
          destruct (HMWF_ktab m gid b (Ptrofs.unsigned ofs) v HM Hgid Hsym Hld)
            as [-> | (vi & -> & Hnt)];
          [ left; reflexivity
          | right; exists vi; split; [ reflexivity | exact Hnt ] ]
      end.
    - (* deref_loc_reference *)
      match goal with Hac : access_mode _ = By_reference |- _ =>
        cbn in Hac; discriminate end.
    - (* deref_loc_copy *)
      match goal with Hac : access_mode _ = By_copy |- _ =>
        cbn in Hac; discriminate end.
    - (* deref_loc_bitfield: tuint is regular, so width=32/pos=0 and the
         extract is the identity on the (untainted) loaded carrier. *)
      match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end.
      cbn [bitsize_intsize bitsize_carrier chunk_for_carrier] in *.
      match goal with
      | Hsg : Unsigned = (if zlt ?w 32 then Signed else _) |- _ =>
          destruct (zlt w 32) as [Hlt | Hge]; [ discriminate Hsg | ]
      end.
      match goal with
      | Hw : 0 < ?w <= 32, Hpw : ?p + ?w <= 32, Hp : 0 <= ?p,
        Hsg : Unsigned = ?s |- _ =>
          assert (w = 32) by lia; assert (p = 0) by lia; subst w p s
      end.
      replace (bitfield_extract I32 Unsigned 0 32 c) with c.
      2:{ unfold bitfield_extract, Int.unsigned_bitfield_extract.
          cbn [intsize_eq signedness_eq].
          replace (first_bit I32 0 32) with 0
            by (unfold first_bit; destruct Archi.big_endian; reflexivity).
          change (Int.repr 0) with Int.zero. rewrite Int.shru_zero.
          rewrite Int.zero_ext_above
            by (change Int.zwordsize with 32; lia). reflexivity. }
      match goal with
      | Hld : Mem.loadv Mint32 m (Vptr ?b ?ofs) = Some (Vint c) |- _ =>
          change (Mem.loadv Mint32 m (Vptr b ofs))
            with (Mem.load Mint32 m b (Ptrofs.unsigned ofs)) in Hld;
          destruct (HMWF_ktab m gid b (Ptrofs.unsigned ofs) (Vint c)
                      HM Hgid Hsym Hld) as [E | (vi & E & Hnt)];
          [ discriminate E | injection E as <- ]
      end.
      right; exists c; split; [ reflexivity | exact Hnt ].
  Qed.

  (* The reusable guarded global-load setter block:
        if (cond) return SETTER(m, landingAction->fld, 0);   [else fall through]
     SETTER = fid (set_mario_action or mario_push_off_steep_floor), a
     call_pres_act.  The action arg is a u32 LandingAction field loaded out of
     the landing global lb; it is untainted by landing_field_load_untainted, so
     kit_scallw_pres discharges the call.  Either the guard is taken (the setter
     fires and returns -- Out_return, preserving) or it falls through (Sskip --
     le and m unchanged). *)
  Lemma setter_block_pres :
    forall (fid : ident),
      call_pres_act lp bm NoA MWF fid ->
      forall (gid : ident) (lb : block) (fld q t : ident) (cond : expr)
             e le m tr le' m' out,
        mem_id gid knockback_table_ids = true ->
        Genv.find_symbol (lp_ge lp) gid = Some lb ->
        q <> M._m ->
        le ! M._m = Some (Vptr bm Ptrofs.zero) ->
        le ! M._landingAction = Some (Vptr lb Ptrofs.zero) ->
        e ! fid = None ->
        exec_stmt function_entry2 (lp_ge lp) e le m
          (Sifthenelse cond
             (Ssequence
                (Ssequence
                   (Sset q
                      (Efield
                         (Ederef
                            (Etempvar M._landingAction
                               (tptr (Tstruct M._LandingAction noattr)))
                            (Tstruct M._LandingAction noattr)) fld tuint))
                   (Scall (Some t)
                      (Evar fid
                         (Tfunction (tyMSp :: tuint :: tuint :: nil) tuint
                            cc_default))
                      (Etempvar M._m tyMSp :: Etempvar q tuint
                         :: Econst_int (Int.repr 0) tint :: nil)))
                (Sreturn (Some (Etempvar t tuint))))
             Sskip)
          tr le' m' out ->
        NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
        Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\
        MWF m' /\ NoA m' /\ (out = Out_normal -> le' = le /\ m' = m).
  Proof.
    intros fid Hcpa gid lb fld q t cond e le m tr le' m' out
           Hgid Hsym Hqm Hm Hla He_fid Hexec HN HM HV HS.
    apply exec_if_inv in Hexec as [b Hbr]. destruct b.
    - (* THEN: Ssequence (Ssequence (Sset q load) (Scall ...)) (Sreturn ...) *)
      apply exec_seq_cases in Hbr as [ (tr1 & le1 & m1 & tr2 & HA & HRet) | (HA & Hne) ].
      2:{ (* the inner (set;call) always ends Out_normal -> contradiction *)
          exfalso. apply exec_seq_cases in HA
            as [ (? & ? & ? & ? & Hset & Hcall) | (Hset & Hne2) ].
          - apply exec_call_normal in Hcall. congruence.
          - apply exec_set_inv in Hset as (? & _ & _ & _ & Hout). congruence. }
      (* HA : (Sset q load; Scall ...) -> Out_normal at (le1,m1); HRet : Sreturn *)
      apply exec_seq_cases in HA as [ (tr3 & le3 & m3 & tr4 & Hset & Hcall) | (Hset & Hne2) ].
      2:{ exfalso. apply exec_set_inv in Hset as (? & _ & _ & _ & Hout). congruence. }
      apply exec_set_inv in Hset as (v0 & Heval & Hle3 & Hm3 & _). subst le3 m3.
      assert (Hu : untainted_scalar v0)
        by (eapply landing_field_load_untainted; eauto).
      assert (Hm' : le ! mario_actions_airborne._m = Some (Vptr bm Ptrofs.zero))
        by exact Hm.
      assert (Hmptr : forall b o,
                 (PTree.set q v0 le) ! mario_actions_airborne._m = Some (Vptr b o) ->
                 b = bm /\ o = Ptrofs.zero).
      { intros b o Hb. rewrite PTree.gso in Hb by (apply not_eq_sym; exact Hqm).
        rewrite Hm' in Hb. injection Hb as <- <-. split; reflexivity. }
      assert (Hqunt : forall x, (PTree.set q v0 le) ! q = Some x -> untainted_scalar x).
      { intros x Hx. rewrite PTree.gss in Hx. injection Hx as <-. exact Hu. }
      destruct (kit_scallw_pres lp bm NoA MWF
                  t fid tuint (tuint :: nil) tuint cc_default q tuint
                  (Econst_int (Int.repr 0) tint :: nil)
                  e (PTree.set q v0 le) m tr4 le1 m1 Out_normal
                  He_fid Hcall Hcpa eq_refl eq_refl Hmptr Hqunt HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & _ & _ & _).
      (* HRet : Sreturn (Some (Etempvar t)) over (le1,m1) -> Out_return *)
      apply exec_return_inv in HRet as (_ & Hmr & Hne).
      subst m'.
      split; [ exact HV1 | ]. split; [ exact HS1 | ].
      split; [ exact HM1 | ]. split; [ exact HN1 | ].
      intro Hc; exfalso; exact (Hne Hc).
    - (* ELSE: Sskip -> le'=le, m'=m, Out_normal *)
      apply exec_skip_inv in Hbr as (Hle' & Hm' & _). subst le' m'.
      split; [ exact HV | ]. split; [ exact HS | ].
      split; [ exact HM | ]. split; [ exact HN | ].
      intro; split; reflexivity.
  Qed.

End LandingWalk.
