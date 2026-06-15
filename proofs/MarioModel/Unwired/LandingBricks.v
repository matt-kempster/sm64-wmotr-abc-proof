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
  ActWriterSurface MWFReal AGates DispatchKit.
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

  (* the carried MWF pins Mario's input halfword A-clear -- the mid-frame fact
     the input&2 indirect-call kill consumes.  Discharged at the capstone via
     MWFReal.mwf_real_inp (NO new trust). *)
  Hypothesis HMWF_inp : forall m, MWF m -> input_a_clear m bm.

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

  (* ================================================================== *)
  (* The block_pres combinator toolkit.  common_landing_cancels' body is  *)
  (* a right-nested Ssequence of "blocks"; each block either falls        *)
  (* through (Out_normal, re-establishing the two param facts for the     *)
  (* next block) or returns (Out_return, done).  Every block maps to ONE  *)
  (* brick: scalar/chase loads -> set_block_pres; window stores ->         *)
  (* window_block_pres (epi_assign_pres); the should_begin_sliding call -> *)
  (* call1_block_pres (kit_scall_pres); the 5 guarded setters ->           *)
  (* setter_blk (setter_block_pres); the input&2 indirect call ->          *)
  (* dead_gate_block_pres (AGates.clc_indirect_call_dead_lp + HMWF_inp);   *)
  (* the final `return 0` -> return_block_pres.  block_pres_seq folds them.*)
  (* The whole body runs at env = empty_env (fn_vars = nil).               *)
  (* ================================================================== *)
  Definition block_pres (s : statement) (lb : block) : Prop :=
    forall le m tr le' m' out,
      le ! M._m = Some (Vptr bm Ptrofs.zero) ->
      le ! M._landingAction = Some (Vptr lb Ptrofs.zero) ->
      exec_stmt function_entry2 (lp_ge lp) empty_env le m s tr le' m' out ->
      NoA m -> MWF m -> Mem.valid_block m bm -> action_sat not_tainted m bm ->
      Mem.valid_block m' bm /\ action_sat not_tainted m' bm /\ MWF m' /\ NoA m' /\
      (out = Out_normal ->
         le' ! M._m = Some (Vptr bm Ptrofs.zero) /\
         le' ! M._landingAction = Some (Vptr lb Ptrofs.zero)).

  Lemma block_pres_seq : forall s1 s2 lb,
      block_pres s1 lb -> block_pres s2 lb -> block_pres (Ssequence s1 s2) lb.
  Proof.
    intros s1 s2 lb H1 H2 le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    apply exec_seq_cases in Hexec
      as [ (tr1 & le1 & m1 & tr2 & HA & HB) | (HA & Hne) ].
    - destruct (H1 le m tr1 le1 m1 Out_normal Hm Hla HA HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & Hc1).
      destruct (Hc1 eq_refl) as (Hm1 & Hla1).
      destruct (H2 le1 m1 tr2 le' m' out Hm1 Hla1 HB HN1 HM1 HV1 HS1)
        as (HV2 & HS2 & HM2 & HN2 & Hc2).
      split; [ exact HV2 | ]. split; [ exact HS2 | ].
      split; [ exact HM2 | ]. split; [ exact HN2 | ]. exact Hc2.
    - destruct (H1 le m tr le' m' out Hm Hla HA HN HM HV HS)
        as (HV1 & HS1 & HM1 & HN1 & _).
      split; [ exact HV1 | ]. split; [ exact HS1 | ].
      split; [ exact HM1 | ]. split; [ exact HN1 | ].
      intro Hc; exfalso; exact (Hne Hc).
  Qed.

  (* a scalar/chase load into a temp distinct from the two params *)
  Lemma set_block_pres : forall q a lb,
      q <> M._m -> q <> M._landingAction -> block_pres (Sset q a) lb.
  Proof.
    intros q a lb Hqm Hql le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    apply exec_set_inv in Hexec as (v & _ & -> & -> & _).
    split; [ exact HV | ]. split; [ exact HS | ].
    split; [ exact HM | ]. split; [ exact HN | ].
    intro. split.
    - rewrite PTree.gso by (apply not_eq_sym; exact Hqm). exact Hm.
    - rewrite PTree.gso by (apply not_eq_sym; exact Hql). exact Hla.
  Qed.

  (* a window-checked m->field store (RHS unconstrained; HMWF_window covers
     it; the safe window excludes the action cell so action_sat carries) *)
  Lemma window_block_pres : forall a1 a2 lb,
      safe_mfield_store mario_actions_airborne._m a1 = true ->
      block_pres (Sassign a1 a2) lb.
  Proof.
    intros a1 a2 lb Hsf le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    assert (Htat : forall b o,
               le ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hb. assert (Hb' : le ! M._m = Some (Vptr b o)) by exact Hb.
      rewrite Hm in Hb'. injection Hb' as <- <-. split; reflexivity. }
    destruct (epi_assign_pres lp LO_mario bm MWF HMWF_window a1 a2 empty_env le m
                tr le' m' out Hsf Htat Hexec HM HV HS)
      as (HV1 & HS1 & HM1 & Hle' & _).
    subst le'.
    split; [ exact HV1 | ]. split; [ exact HS1 | ].
    split; [ exact HM1 | ]. split; [ exact (HNoA_of_MWF _ HM1) | ].
    intro. split; [ exact Hm | exact Hla ].
  Qed.

  (* a 1-arg `t := f(m)` call to a call_pres callee (should_begin_sliding) *)
  Lemma call1_block_pres : forall (fid t : ident) (rty : type)
                                  (cc : calling_convention) lb,
      t <> M._m -> t <> M._landingAction ->
      call_pres lp bm NoA MWF fid ->
      block_pres (Scall (Some t) (Evar fid (Tfunction (tyMSp :: nil) rty cc))
                    (Etempvar mario_actions_airborne._m tyMSp :: nil)) lb.
  Proof.
    intros fid t rty cc lb Htm Htl Hcp le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    assert (Htat : forall b o,
               le ! mario_actions_airborne._m = Some (Vptr b o) ->
               b = bm /\ o = Ptrofs.zero).
    { intros b o Hb. assert (Hb' : le ! M._m = Some (Vptr b o)) by exact Hb.
      rewrite Hm in Hb'. injection Hb' as <- <-. split; reflexivity. }
    destruct (kit_scall_pres lp bm NoA MWF (Some t) fid rty cc le m tr le' m' out
                Hexec Hcp Htat HN HM HV HS)
      as (HV1 & HS1 & HM1 & HN1 & _ & vr & Hle1).
    split; [ exact HV1 | ]. split; [ exact HS1 | ].
    split; [ exact HM1 | ]. split; [ exact HN1 | ].
    intro. subst le'. cbn [set_opttemp]. split.
    - rewrite PTree.gso by (apply not_eq_sym; exact Htm). exact Hm.
    - rewrite PTree.gso by (apply not_eq_sym; exact Htl). exact Hla.
  Qed.

  (* one of the 5 guarded landingAction-field setter blocks *)
  Lemma setter_blk : forall (fid : ident),
      call_pres_act lp bm NoA MWF fid ->
      forall (gid : ident) (lb : block) (fld q t : ident) (cond : expr),
        mem_id gid knockback_table_ids = true ->
        Genv.find_symbol (lp_ge lp) gid = Some lb ->
        q <> M._m ->
        block_pres
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
             Sskip) lb.
  Proof.
    intros fid Hcpa gid lb fld q t cond Hgid Hsym Hqm
           le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    destruct (setter_block_pres fid Hcpa gid lb fld q t cond empty_env le m
                tr le' m' out Hgid Hsym Hqm Hm Hla (PTree.gempty _ fid)
                Hexec HN HM HV HS)
      as (HV1 & HS1 & HM1 & HN1 & Hcont).
    split; [ exact HV1 | ]. split; [ exact HS1 | ].
    split; [ exact HM1 | ]. split; [ exact HN1 | ].
    intro Hc. destruct (Hcont Hc) as (-> & _). split; [ exact Hm | exact Hla ].
  Qed.

  (* the input&2 indirect setAPressAction call: DEAD under the carried
     input_a_clear (the gate takes its Sskip else) *)
  Lemma dead_gate_block_pres : forall lb, block_pres clc_gate lb.
  Proof.
    intros lb le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    pose proof (HMWF_inp m HM) as Hclear.
    assert (Hm2 : le ! mario_actions_moving._m = Some (Vptr bm Ptrofs.zero))
      by exact Hm.
    destruct (clc_indirect_call_dead_lp lp LO_mario empty_env le m bm tr le' m' out
                Hm2 Hclear Hexec) as (vi & _ & _ & _ & Helse).
    assert (Hgelse : gate_else clc_gate = Sskip) by (vm_compute; reflexivity).
    rewrite Hgelse in Helse.
    apply exec_skip_inv in Helse as (-> & -> & _).
    split; [ exact HV | ]. split; [ exact HS | ].
    split; [ exact HM | ]. split; [ exact HN | ].
    intro. split.
    - rewrite PTree.gso by (vm_compute; congruence). exact Hm.
    - rewrite PTree.gso by (vm_compute; congruence). exact Hla.
  Qed.

  (* the terminal `return 0` *)
  Lemma return_block_pres : forall a lb, block_pres (Sreturn a) lb.
  Proof.
    intros a lb le m tr le' m' out Hm Hla Hexec HN HM HV HS.
    apply exec_return_inv in Hexec as (-> & -> & Hne).
    split; [ exact HV | ]. split; [ exact HS | ].
    split; [ exact HM | ]. split; [ exact HN | ].
    intro Hc; exfalso; exact (Hne Hc).
  Qed.

  (* ================================================================== *)
  (* The producer rows the body calls bottom out in.                     *)
  (* ================================================================== *)

  (* mario_push_off_steep_floor: call_pres_act (writer_params, threads
     _action to set_mario_action; wact = [_action; _t'2], sids = [sma]). *)
  Definition pushoff_wact : list ident :=
    mario_step._action :: mario_step._t'2 :: nil.
  Definition sids_sma : list ident := mario._set_mario_action :: nil.

  Lemma sids_sma_rows : forall fid, mem_id fid sids_sma = true ->
      call_pres_act lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sids_sma in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hsmact | discriminate H ].
  Qed.

  Lemma Hpush : call_pres_act lp bm NoA MWF mario_step._mario_push_off_steep_floor.
  Proof.
    apply (call_pres_act_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_step.prog mario_step._mario_push_off_steep_floor
             mario_step.f_mario_push_off_steep_floor
             pushoff_wact nil sids_sma nil nil sids_sma
             LO_mario_step
             ltac:(vm_compute; reflexivity) ltac:(reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity)
             eq_refl eq_refl eq_refl eq_refl eq_refl eq_refl).
    - intros fid' H; discriminate H.
    - exact sids_sma_rows.
    - intros fid' H; discriminate H.
    - exact sids_sma_rows.
    - vm_compute; reflexivity.
  Qed.

  (* mario_facing_downhill: call_pres (read-only, in mario.prog). *)
  Lemma Hmfd : call_pres lp bm NoA MWF mario._mario_facing_downhill.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario.prog mario._mario_facing_downhill
             mario.f_mario_facing_downhill nil nil nil nil
             LO_mario ltac:(vm_compute; reflexivity) ltac:(reflexivity)
             ltac:(vm_compute; reflexivity)).
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - vm_compute; reflexivity.
  Qed.

  (* should_begin_sliding: call_pres (in mario_actions_moving.prog; calls
     mario_facing_downhill). *)
  Definition sbs_ids : list ident := mario._mario_facing_downhill :: nil.

  Lemma sbs_ids_rows : forall fid, mem_id fid sbs_ids = true ->
      call_pres lp bm NoA MWF fid.
  Proof.
    intros fid H. unfold sbs_ids in H. cbn [mem_id existsb] in H.
    apply orb_true_iff in H as [Hm | H];
      [ apply Pos.eqb_eq in Hm; subst fid; exact Hmfd | discriminate H ].
  Qed.

  Lemma Hsbs : call_pres lp bm NoA MWF M._should_begin_sliding.
  Proof.
    apply (call_pres_of_wwalk lp LO_mario bm NoA MWF HNoA_of_MWF
             HMWF_window HMWF_glob HMWF_act SafeB HSafeNotBm HchaseRoot
             HMWF_chase HMWF_root HMWF_sglob HchaseStep HMWF_chase_safe
             mario_actions_moving.prog M._should_begin_sliding
             M.f_should_begin_sliding sbs_ids nil nil nil
             LO_mov ltac:(vm_compute; reflexivity) ltac:(reflexivity)
             ltac:(vm_compute; reflexivity)).
    - exact sbs_ids_rows.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - intros fid' H; discriminate H.
    - vm_compute; reflexivity.
  Qed.

  (* ================================================================== *)
  (* THE BODY WALK: common_landing_cancels preserves, GIVEN landingAction *)
  (* points at a ktab landing global lb.  Peels the right-nested body     *)
  (* (block_pres_seq) and discharges each of the 8 blocks with the bricks *)
  (* above -- P1 chase+steep, P2 doubleJumpTimer window, P3 should_begin_ *)
  (* sliding+slide, P4 input&16+end, P5 actionTimer window+end, P6 the    *)
  (* DEAD input&2 indirect call, P7 input&4+offFloor, P8 return 0.        *)
  (* ================================================================== *)
  Lemma clc_body_pres : forall (gid : ident) (lb : block),
      mem_id gid knockback_table_ids = true ->
      Genv.find_symbol (lp_ge lp) gid = Some lb ->
      block_pres (fn_body M.f_common_landing_cancels) lb.
  Proof.
    intros gid lb Hgid Hsym.
    unfold M.f_common_landing_cancels; cbn [fn_body].
    (* P1: chase load; (chasestep load; STEEP push_off setter) *)
    apply block_pres_seq.
    { apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply (setter_blk mario_step._mario_push_off_steep_floor Hpush gid lb);
        [ exact Hgid | exact Hsym | vm_compute; congruence ]. }
    (* P2: (t'19 load); window store doubleJumpTimer *)
    apply block_pres_seq.
    { apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply window_block_pres; vm_compute; reflexivity. }
    (* P3: sbs call; slide setter *)
    apply block_pres_seq.
    { apply block_pres_seq;
        [ apply call1_block_pres;
          [ vm_compute; congruence | vm_compute; congruence | exact Hsbs ] | ].
      apply (setter_blk mario._set_mario_action Hsmact gid lb);
        [ exact Hgid | exact Hsym | vm_compute; congruence ]. }
    (* P4: input load; end-input16 setter *)
    apply block_pres_seq.
    { apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply (setter_blk mario._set_mario_action Hsmact gid lb);
        [ exact Hgid | exact Hsym | vm_compute; congruence ]. }
    (* P5: ((actionTimer load; cast set); window store actionTimer);
           (numFrames load; end-numFrames setter) *)
    apply block_pres_seq.
    { apply block_pres_seq.
      { apply block_pres_seq.
        { apply block_pres_seq;
            [ apply set_block_pres; vm_compute; congruence
            | apply set_block_pres; vm_compute; congruence ]. }
        apply window_block_pres; vm_compute; reflexivity. }
      apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply (setter_blk mario._set_mario_action Hsmact gid lb);
        [ exact Hgid | exact Hsym | vm_compute; congruence ]. }
    (* P6: input&2 indirect setAPressAction call -- DEAD *)
    apply block_pres_seq.
    { exact (dead_gate_block_pres lb). }
    (* P7: input load; offFloor-input4 setter *)
    apply block_pres_seq.
    { apply block_pres_seq; [ apply set_block_pres; vm_compute; congruence | ].
      apply (setter_blk mario._set_mario_action Hsmact gid lb);
        [ exact Hgid | exact Hsym | vm_compute; congruence ]. }
    (* P8: return 0 *)
    apply return_block_pres.
  Qed.

End LandingWalk.
