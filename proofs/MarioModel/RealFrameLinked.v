(* ====================================================================== *)
(* THE FRAME RE-ROOTED OVER THE LINKED PROGRAM (SPINE).                    *)
(*                                                                        *)
(* RealFrameValue.v threads `mario_ge = globalenv mario.prog` through the  *)
(* whole frame: over that single-TU genv the action dispatchers            *)
(* (mario_execute_*_action) are underspecified Externals, which is why the *)
(* old capstone had to assume the FALSE reach_ext_action_cell. This file    *)
(* re-roots the frame over `globalenv lp` for a LINKED program lp (lp kept  *)
(* ABSTRACT -- a linkorder hypothesis, never vm_compute'd, so no OOM).      *)
(* Over globalenv lp those dispatcher Scalls resolve to real Internal       *)
(* bodies (SymbolicLinking.linkorder_resolves_funct) and the engine         *)
(* TRAVERSES them instead of bouncing off the external bucket.             *)
(*                                                                        *)
(* It re-states the frame's genv-facing predicates over an abstract         *)
(* `lp_ge := globalenv lp`, re-proves the eval bricks (consuming the        *)
(* three-part genv interface of SymbolicLinking.v: funcall resolution /     *)
(* field-offset agreement / symbol preservation), and exports the           *)
(* capstone-facing wrapper execute_mario_action_preserves_real_reached_lp,  *)
(* generic over the carried action-value predicate Qv. CONSUMED BY the      *)
(* live GOAL-1 capstone NoAImpliesNoFly/NoAImpliesNoFlyLinked.v at          *)
(* Qv := Taint.not_tainted.                                                 *)
(* ====================================================================== *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require mario.
From SM64.Proofs Require Import SymbolicLinking.
(* RealFrameValue is on the spine (non-Unwired); importing it here is firewall-OK
   (Unwired may consume non-Unwired). We reuse ONLY its genv-PARAMETRIC eval
   inversion helpers (eval_expr_Efield_load, eval_lvalue_Efield_inv,
   eval_expr_Ederef_load, eval_lvalue_Ederef_base, eval_expr_Etempvar_val,
   deref_loc_aggregate_eq) -- each is stated `forall ge`, so it threads at lp_ge
   verbatim. The mario_ge-specific wrappers there are NOT used. *)
From SM64.Proofs Require Import Flying ActionValue FieldNonInterference
  ActionValueFrame RealFrameValue.

Section ReRoot.
  (* The linked program -- ABSTRACT. The only thing we know is that mario.prog
     links into it (linkorder mario.prog lp). Every cross-TU fact comes from
     this via the SymbolicLinking interface; lp's defmap/cenv are never forced. *)
  Variable lp : Clight.program.
  Hypothesis LO_mario : linkorder mario.prog lp.

  (* The carried action-value predicate (the Q of action_sat). The whole frame
     engine is value-generic -- nothing below unfolds it -- so the wrapper
     exports generalize over Qv. The capstone instantiates
     Qv := Taint.not_tainted: the inductive invariant must exclude the whole
     no-A taint set T (not just the flying set F), because act_shot_from_cannon
     writes ACT_FLYING on a later, A-free frame -- carrying merely "not flying"
     makes the per-funcall residual unsatisfiable at the cannon. See Taint.v. *)
  Variable Qv : int -> Prop.

  Definition lp_ge : genv := globalenv lp.

  (* ---- genv-facing frame predicates, re-rooted at lp_ge. These are the
     RealFrameValue predicates with mario_ge replaced by lp_ge. The carried
     memory facts (the pointer chase) are identical; only the genv used to
     resolve gMarioState's symbol changes. ---- *)

  Definition gMarioState_wf_lp (m : mem) (bm : block) : Prop :=
    exists gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb /\
               Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr bm Ptrofs.zero).

  (* The re-rooted gMarioState invariant is SATISFIABLE over lp_ge: the symbol
     resolves there (it is a defined gvar in mario.prog, preserved by linking).
     So re-rooting does not vacuously strand this predicate. *)
  Lemma gMarioState_symbol_resolves_lp :
    exists gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb.
  Proof. unfold lp_ge. apply linking_resolves_gMarioState; exact LO_mario. Qed.

  (* THE FIRST RE-ROOTED EVAL BRICK: `gMarioState` (a pointer-typed global read)
     evaluates to Vptr bm 0 over lp_ge, given the re-rooted wf and that the symbol
     is not shadowed by a local. Identical script to RealFrameValue's
     eval_Evar_gMarioState_bm, but over lp_ge -- the proof is genv-parametric;
     all it needs from the genv is find_symbol, supplied by gMarioState_wf_lp. *)
  Lemma eval_Evar_gMarioState_bm_lp :
    forall e le m bm,
      e ! mario._gMarioState = None ->
      gMarioState_wf_lp m bm ->
      eval_expr lp_ge e le m
        (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))
        (Vptr bm Ptrofs.zero).
  Proof.
    intros e le m bm He (gb & Hsym & Hload).
    eapply eval_Elvalue.
    - eapply eval_Evar_global; eauto.
    - eapply deref_loc_value with (chunk := Mptr); [ reflexivity | ].
      unfold Mem.loadv. exact Hload.
  Qed.

  (* The marioObj pointer-chase invariant, re-rooted at lp_ge: the off-bm guard
     (no aliasing with gMarioState's block) is restated over lp_ge's symbol. The
     field offset is computed in mario.prog's OWN cenv (a concrete lookup); linking
     preserves it (action_offset_lp / linkorder_field_offset_agree). *)
  Definition marioObj_wf_lp (m : mem) (bm : block) : Prop :=
    exists off bobj ofs,
      field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
        = Errors.OK (off, Full) /\
      Mem.loadv Mptr m (Vptr bm (Ptrofs.repr off)) = Some (Vptr bobj ofs) /\
      bobj <> bm /\
      (forall gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb -> bobj <> gb).

  (* the offset of marioObj in MarioState, COMPUTED once (tiny readback --
     field_offset returns a small pair, not the composite). *)
  Lemma marioObj_offset_mario :
    field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
      = Errors.OK (136, Full).
  Proof. vm_compute. reflexivity. Qed.

  (* ---- the CONDITIONAL wf forms (2026-06-10): IF the watched cell holds
     a pointer, it is the right one. The positive load-success forms above
     made the per-funcall rest row (reach_rest_marg_lp, now DELETED)
     undischargeable: preserving "the load SUCCEEDS" across a callee needs
     cell-unchanged facts no body walk provides, whereas these conditional
     rows are projections of the carried MWF (MWF_real R5/R6 + the SafeB
     distinctness facts). The engines only ever USE the rows on loads the
     exec derivation itself performed -- so conditionality costs nothing. *)
  Definition gms_cond_lp (m : mem) (bm : block) : Prop :=
    forall gb b o,
      Genv.find_symbol lp_ge mario._gMarioState = Some gb ->
      Mem.loadv Mptr m (Vptr gb Ptrofs.zero) = Some (Vptr b o) ->
      b = bm /\ o = Ptrofs.zero.

  Definition mobj_cond_lp (m : mem) (bm : block) : Prop :=
    forall b o,
      Mem.loadv Mptr m (Vptr bm (Ptrofs.repr 136)) = Some (Vptr b o) ->
      b <> bm /\
      (forall gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb -> b <> gb).

  (* mario.prog defines the MarioState composite. NB: we must NOT `vm_compute` the
     lookup itself -- it reduces to Some <the full MarioState composite record,
     members + consistency proofs>, whose readback OOMs. Instead compute only a
     BOOLEAN (readback stays `true`, the composite is discarded on the VM stack),
     then case-split the lookup as an OPAQUE term. *)
  Lemma mario_MarioState_isSome :
    match (prog_comp_env mario.prog) ! mario._MarioState with
    | Some _ => true | None => false end = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma mario_defines_MarioState :
    exists co, (prog_comp_env mario.prog) ! mario._MarioState = Some co.
  Proof.
    pose proof mario_MarioState_isSome as H.
    destruct ((prog_comp_env mario.prog) ! mario._MarioState) as [co|].
    - exists co; reflexivity.
    - cbn in H; discriminate H.
  Qed.

  (* THE SECOND RE-ROOTED EVAL BRICK (the LOAD-EXPORTING form): a marioObj
     field read RETURNS the chase-root load the evaluation performed, at
     the COMPUTED offset 136. Identical inversion to RealFrameValue's
     eval_marioObj_off_bm except the two `rewrite cenv_eq` steps
     (false at lp_ge, where genv_cenv = the MERGED env) are replaced by:
       - linkorder_comp_env_extends : pin co to mario's MarioState composite, and
       - linkorder_field_offset_agree : move the offset onto mario.prog's cenv.
     The exported load feeds the CONDITIONAL rows (mobj_cond_lp, the MWF
     chase-root row) -- no positive wf premise needed: the derivation
     itself performed the load. *)
  Lemma eval_marioObj_load_lp :
    forall stid e le m bm bobj o,
      (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
      eval_expr lp_ge e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr))
                mario._marioObj (tptr (Tstruct mario._Object noattr)))
        (Vptr bobj o) ->
      Mem.loadv Mptr m (Vptr bm (Ptrofs.repr 136)) = Some (Vptr bobj o).
  Proof.
    intros stid e le m bm bobj o Ht48 Hev.
    pose proof marioObj_offset_mario as Hfo.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb. destruct (Ht48 _ _ Hlvb) as [Hl Ho]. subst.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate Hty ].
    cbn in Hty; inv Hty.
    change (genv_cenv lp_ge) with (prog_comp_env lp) in Hco, Hfo2.
    destruct mario_defines_MarioState as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState co0 LO_mario Hmar)
      as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    rewrite (linkorder_field_offset_agree lp mario.prog mario._marioObj (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    rewrite Hmm in Hfo. rewrite Hfo in Hfo2. inv Hfo2.
    rewrite Ptrofs.add_zero_l in Hderef.
    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate Hac end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate Hac end);
      try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk,
        Hlv3 : Mem.loadv ?chunk _ (Vptr _ (Ptrofs.repr ?d)) = Some (Vptr bobj o) |- _ =>
          cbn in Hac; inv Hac; exact Hlv3
      end.
  Qed.

  (* a store through assign_loc into block loc leaves loads at any OTHER
     block literally unchanged -- the EQUALITY form (no validity side
     conditions), which is what lets the conditional rows transport
     BACKWARD: a pointer-valued load observed in m' was already there
     in m, so the m-row applies. *)
  Lemma assign_loc_load_other_eq :
    forall ce ty m loc ofs bf v m' bp chunk (d : Z),
      assign_loc ce ty m loc ofs bf v m' ->
      bp <> loc ->
      Mem.load chunk m' bp d = Mem.load chunk m bp d.
  Proof.
    intros ce ty m loc ofs bf v m' bp chunk d Has Hne.
    inv Has.
    - match goal with H : Mem.storev _ _ _ _ = Some _ |- _ => cbn in H end.
      eapply Mem.load_store_other; [ eassumption | left; exact Hne ].
    - eapply Mem.load_storebytes_other; [ eassumption | left; exact Hne ].
    - match goal with H : store_bitfield _ _ _ _ _ _ _ _ _ _ |- _ => inv H end.
      match goal with H : Mem.storev _ _ _ _ = Some _ |- _ => cbn in H end.
      eapply Mem.load_store_other; [ eassumption | left; exact Hne ].
  Qed.

  (* Offset faithfulness, packaged for this section: over lp_ge the action cell
     is still byte 12 of MarioState (linking does not move it). This is what lets
     the re-rooted engine keep RealFrameValue's concrete action@12 reasoning. *)
  Lemma action_offset_lp :
    field_offset (prog_comp_env lp) mario._action mario_state_members
      = Errors.OK (12, Full).
  Proof. apply linking_preserves_action_offset; exact LO_mario. Qed.

  (* ---- THE BODY-CENSUS CORE, re-rooted: the Sassign case. ---- *)
  (* The body of f_execute_mario_action writes memory only through Object-pointer
     temps (off bm,gb). RealFrameValue.store_preserves_meminv proves each such
     store preserves the memory invariant; its only mario_ge dependencies are the
     statement's genv and the wf predicates -- the assign_loc machinery it calls
     (assign_loc_action_sat_avoid / assign_loc_off_loadv / assign_loc_valid_block)
     is genv-FREE. So it threads at lp_ge with meminv_lp. The temp-provenance
     predicates toff/tat are ge-free -- we reuse RealFrameValue's verbatim. *)
  Section ProvEngineLp.
    Variable bm gb : block.
    Hypothesis Hgb_lp : Genv.find_symbol lp_ge mario._gMarioState = Some gb.

    (* the carried memory invariant, re-rooted at lp_ge -- the pointer-chase
       rows are the CONDITIONAL forms (see gms_cond_lp/mobj_cond_lp above). *)
    Definition meminv_lp (m : mem) : Prop :=
      Mem.valid_block m bm /\ action_sat Qv m bm /\
      mobj_cond_lp m bm /\ gms_cond_lp m bm.

    (* THE Sassign CASE over lp_ge: a body store (base temp off {bm,gb}) preserves
       meminv_lp. Same proof as RealFrameValue.store_preserves_meminv, threaded. *)
    Lemma store_preserves_meminv_lp :
      forall a1 a2 (tid : ident)
        (Hgeom : forall e le m loc ofs bf,
           eval_lvalue lp_ge e le m a1 loc ofs bf -> exists d, le ! tid = Some (Vptr loc d)),
      forall e le m t le' m' out,
        meminv_lp m -> RealFrameValue.toff bm gb le tid ->
        exec_stmt function_entry2 lp_ge e le m (Sassign a1 a2) t le' m' out ->
        meminv_lp m'.
    Proof.
      intros a1 a2 tid Hgeom e le m t le' m' out (Hv & Hsat & Hmo & Hgm) Hoff Hexec. inv Hexec.
      match goal with H : eval_lvalue _ _ _ _ a1 _ _ _ |- _ => rename H into Hlv end.
      match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => rename H into Has end.
      apply Hgeom in Hlv as (d & Htmp). destruct (Hoff _ _ Htmp) as [Hnbm Hngb].
      split; [ eapply assign_loc_valid_block; [ exact Has | exact Hv ] | ].
      split; [ eapply assign_loc_action_sat_avoid;
                 [ exact Has | exact Hv | intros i _ [Hb _]; congruence | exact Hsat ] | ].
      split.
      - intros b o Hld. apply (Hmo b o). cbn in Hld |- *.
        rewrite <- (assign_loc_load_other_eq _ _ _ _ _ _ _ _ _ _ _ Has (not_eq_sym Hnbm)).
        exact Hld.
      - intros gb0 b o Hsym Hld.
        assert (gb0 = gb) by congruence. subst gb0.
        apply (Hgm gb b o Hsym). cbn in Hld |- *.
        rewrite <- (assign_loc_load_other_eq _ _ _ _ _ _ _ _ _ _ _ Has (not_eq_sym Hngb)).
        exact Hld.
    Qed.

    (* ---- THE Sset CASE, re-rooted. ---- *)

    (* `t = gMarioState` makes t hold Vptr bm 0, over lp_ge. Mirrors sset_gms_bm;
       the eval helpers (eval_expr_Evar_load / eval_lvalue_Evar_global_loc) are
       genv-parametric, so only the genv + wf predicate change. *)
    Lemma sset_gms_bm_lp :
      forall tid e le m t le' m' out,
        e ! mario._gMarioState = None ->
        gms_cond_lp m bm ->
        exec_stmt function_entry2 lp_ge e le m
          (Sset tid (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) t le' m' out ->
        forall b o, le' ! tid = Some (Vptr b o) -> b = bm /\ o = Ptrofs.zero.
    Proof.
      intros tid e le m t le' m' out He Hcond H b o Hle'. inv H.
      rewrite PTree.gss in Hle'. inv Hle'.
      match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd) end.
      apply eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs]; [ | exact He ]. subst.
      inv Hd;
        try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
        try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
        try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hl : Mem.loadv ?chunk _ _ = _ |- _ =>
          cbn in Hac; inv Hac
      end.
      eapply (Hcond _ _ _); [ exact Hfs | eassumption ].
    Qed.

    (* `t = stid->marioObj` makes t hold an off-{bm,gb} pointer, over lp_ge.
       Consumes eval_marioObj_off_bm_lp and the section's Hgb_lp. *)
    Lemma sset_marioObj_offbm_lp :
      forall tid stid e le m t le' m' out,
        (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
        mobj_cond_lp m bm ->
        exec_stmt function_entry2 lp_ge e le m
          (Sset tid (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._marioObj (tptr (Tstruct mario._Object noattr)))) t le' m' out ->
        forall b o, le' ! tid = Some (Vptr b o) -> b <> bm /\ b <> gb.
    Proof.
      intros tid stid e le m t le' m' out Hstid Hcond H b o Hle'. inv H.
      rewrite PTree.gss in Hle'. inv Hle'.
      match goal with Hev : eval_expr _ _ _ _ _ (Vptr b o) |- _ =>
        pose proof (eval_marioObj_load_lp _ _ _ _ _ _ _ Hstid Hev) as Hld end.
      destruct (Hcond _ _ Hld) as [Hbm Hgbfn].
      split; [ exact Hbm | exact (Hgbfn gb Hgb_lp) ].
    Qed.

    (* THE Sset CASE over lp_ge: memory untouched (meminv_lp trivially survives);
       the provenance invariant re-established by the sset_*_lp lemmas for a tracked
       temp, or preserved by gso for an untracked one. The provenance predicates
       (tprov/tat/toff, prov_sset_ok, gms_expr, marioObj_expr) are genv-FREE, reused
       from RealFrameValue. *)
    Lemma sset_case_preserves_lp :
      forall e le m id a t le' m' out,
        e ! mario._gMarioState = None ->
        meminv_lp m -> RealFrameValue.tprov bm gb le -> RealFrameValue.prov_sset_ok id a ->
        exec_stmt function_entry2 lp_ge e le m (Sset id a) t le' m' out ->
        meminv_lp m' /\ RealFrameValue.tprov bm gb le'.
    Proof.
      intros e le m id a t le' m' out He Hmem Htp Hck Hexec.
      inversion Hexec; subst.
      split; [ exact Hmem | ].
      destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
      destruct Htp as (T48 & T12 & T49 & T13).
      destruct Hck as (C48 & C12 & C49 & C13).
      unfold RealFrameValue.tprov; split; [ | split; [ | split ] ].
      - unfold RealFrameValue.tat. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'48) as [E|N].
        + subst id. rewrite (C48 eq_refl) in Hexec.
          exact (sset_gms_bm_lp _ _ _ _ _ _ _ _ He Hgwf Hexec _ _ Hs).
        + rewrite PTree.gso in Hs by congruence. exact (T48 _ _ Hs).
      - unfold RealFrameValue.tat. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'12) as [E|N].
        + subst id. rewrite (C12 eq_refl) in Hexec.
          exact (sset_gms_bm_lp _ _ _ _ _ _ _ _ He Hgwf Hexec _ _ Hs).
        + rewrite PTree.gso in Hs by congruence. exact (T12 _ _ Hs).
      - unfold RealFrameValue.toff. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'49) as [E|N].
        + subst id. rewrite (C49 eq_refl) in Hexec.
          eapply sset_marioObj_offbm_lp; [ exact T48 | exact Hmwf | exact Hexec | exact Hs ].
        + rewrite PTree.gso in Hs by congruence. exact (T49 _ _ Hs).
      - unfold RealFrameValue.toff. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'13) as [E|N].
        + subst id. rewrite (C13 eq_refl) in Hexec.
          eapply sset_marioObj_offbm_lp; [ exact T12 | exact Hmwf | exact Hexec | exact Hs ].
        + rewrite PTree.gso in Hs by congruence. exact (T13 _ _ Hs).
    Qed.

    (* ---- store geometry, threaded: the two body stores go through the
       Object-pointer temps _t'49 / _t'13. Proofs are all genv-PARAMETRIC peel
       helpers (eval_lvalue_Efield_base, eval_expr_Efield_peel, ...), so they
       thread at lp_ge verbatim. These are the Hgeom inputs to store_preserves. *)
    Lemma store1_loc_is_t49_lp :
      forall e le m loc ofs bf,
        eval_lvalue lp_ge e le m store1_lval loc ofs bf ->
        exists d, le ! mario._t'49 = Some (Vptr loc d).
    Proof.
      unfold store1_lval. intros e le m loc ofs bf H.
      apply eval_lvalue_Efield_base in H as (?&H).
      apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
      apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
      apply eval_expr_Efield_peel in H as (?&H); [ | cbn; auto ].
      apply eval_expr_Ederef_peel in H as (?&H); [ | cbn; auto ].
      apply eval_expr_Etempvar_val in H. eauto.
    Qed.

    Lemma store2_loc_is_t13_lp :
      forall e le m loc ofs bf,
        eval_lvalue lp_ge e le m store2_lval loc ofs bf ->
        exists d, le ! mario._t'13 = Some (Vptr loc d).
    Proof.
      unfold store2_lval. intros e le m loc ofs bf H.
      apply eval_lvalue_Ederef_base in H.
      apply eval_expr_Ebinop_inv in H as (v1 & v2 & Hb & Hidx & Hsem).
      apply eval_expr_Econst_int_val in Hidx; subst v2.
      apply sem_add_array_int_block in Hsem as (?&?); subst v1.
      apply eval_expr_Efield_peel in Hb as (?&Hb); [ | cbn; auto ].
      apply eval_expr_Efield_peel in Hb as (?&Hb); [ | cbn; auto ].
      apply eval_expr_Ederef_peel in Hb as (?&Hb); [ | cbn; auto ].
      apply eval_expr_Etempvar_val in Hb. eauto.
    Qed.

  End ProvEngineLp.

  (* ================================================================== *)
  (* THE RE-ROOTED FRAME WRAPPER -- the capstone-facing piece.            *)
  (*                                                                    *)
  (* execute_mario_action_step_lp is one real per-frame Mario update over *)
  (* the LINKED genv: a big-step eval_funcall of f_execute_mario_action at *)
  (* globalenv lp. Because the genv is lp, every dispatcher Scall inside    *)
  (* the body (and its callees) resolves to a REAL Internal body and is     *)
  (* traversed by the engine's funcall-IH -- the flying logic is now IN     *)
  (* SCOPE, not hidden behind an underspecified external. The wrapper       *)
  (* reduces a frame's NoA + memory-invariant preservation to the no-A      *)
  (* reach/ext/store residuals OVER lp (the analog of                       *)
  (* execute_mario_action_preserves_real, threaded). This is what the       *)
  (* capstone will consume in place of the mario_ge frame, retiring the     *)
  (* FALSE reach_ext_action_cell.                                           *)
  (* ================================================================== *)
  Definition execute_mario_action_step_lp (m m' : mem) : Prop :=
    exists (b_o : block) (t : trace) (res : val),
      eval_funcall function_entry2 lp_ge m
        (Internal mario.f_execute_mario_action)
        (Vptr b_o Ptrofs.zero :: nil) t m' res.

  (* ================================================================== *)
  (* TOWARD THE _REACHED VARIANT (the one the capstone consumes).         *)
  (*                                                                    *)
  (* The capstone uses the marg/MWF/reached-gated wrapper                 *)
  (* execute_mario_action_preserves_real_reached_lp below. The basic       *)
  (* (non-marg, forall-fd) v1 wrapper chain was DELETED 2026-06-10: its    *)
  (* reach_rest_noA_lp residual was FALSE for the real lp (EF_memcpy),     *)
  (* exactly the class the restatement arc killed -- keeping the template  *)
  (* invited re-introducing vacuity. These two bricks are the only         *)
  (* remaining genv-dependent pieces                                       *)
  (* of the marg/Pgms layer; everything else (Pgms, gms_arg_temps, marg_ok,  *)
  (* call_arg0_marg, reach_chk, pgms_chk, the switch helpers) is genv-free   *)
  (* and reused from RealFrameValue. *)
  (* ================================================================== *)

  (* the call-arg census is SOUND over lp: if Pgms holds and arg0 passes the
     per-call census, the first vararg satisfies marg_ok. Statement over lp_ge;
     proof is generic inversion (reused sem_cast_ptr_result_inv / sem_or_never_ptr),
     so it threads verbatim. *)
  Lemma call_arg0_marg_sound_lp :
    forall bm e le m al tyargs vargs,
      Pgms bm le -> call_arg0_marg al ->
      eval_exprlist lp_ge e le m al tyargs vargs ->
      marg_ok bm vargs.
  Proof.
    intros bm e le m al tyargs vargs HP Hc Hel.
    destruct al as [| a0 rest]; [ inv Hel; exact I | ].
    inv Hel.
    match goal with H : eval_expr _ _ _ _ a0 ?v |- _ => rename H into Hev; rename v into v0 end.
    match goal with H : sem_cast _ _ _ _ = Some ?v |- _ => rename H into Hcast; rename v into v0' end.
    unfold marg_ok. destruct v0' as [| | | | | b o]; auto.
    pose proof (sem_cast_ptr_result_inv _ _ _ _ _ _ Hcast) as Hsrc. subst v0.
    destruct a0 as [ ci cty | cf cfty | csg csgty | clg clgty | vx vxty | et ety
                   | dr drty | ad adty | uo ua uty | bop b1 b2 bty | cst cstty
                   | ef efld efty | sz1 sz2 | ag1 ag2 ];
      cbn in Hc; try contradiction.
    - inv Hev; match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end.
    - destruct ety; try contradiction.
      assert (Hget : le ! et = Some (Vptr b o))
        by (inv Hev; [ assumption
                     | match goal with H : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ => inv H end ]).
      exact (HP et Hc b o Hget).
    - destruct bop; try contradiction.
      inv Hev; [ exfalso; eapply sem_or_never_ptr; eauto
               | match goal with H : eval_lvalue _ _ _ _ _ _ _ _ |- _ => inv H end ].
  Qed.

  (* a tracked call-arg temp Sset preserves Pgms, over lp_ge. Consumes
     sset_gms_bm_lp; the rest (Pgms, gms_arg_temps, gms_expr) is genv-free. *)
  Lemma pgms_sset_preserves_lp :
    forall bm e le m id a t le' m' out,
      e ! mario._gMarioState = None ->
      gms_cond_lp m bm ->
      Pgms bm le -> (In id gms_arg_temps -> a = gms_expr) ->
      exec_stmt function_entry2 lp_ge e le m (Sset id a) t le' m' out ->
      Pgms bm le'.
  Proof.
    intros bm e le m id a t le' m' out He Hgwf HP Hck Hexec.
    assert (Hle' : exists v, le' = PTree.set id v le)
      by (inversion Hexec; subst; eauto).
    destruct Hle' as (v & ->).
    unfold Pgms. intros tt Hin b o Hs.
    destruct (Pos.eq_dec tt id) as [E|N].
    - subst tt. specialize (Hck Hin). subst a. unfold gms_expr in Hexec.
      exact (sset_gms_bm_lp bm id e le m t (PTree.set id v le) m' out He Hgwf Hexec b o Hs).
    - rewrite PTree.gso in Hs by congruence. exact (HP tt Hin b o Hs).
  Qed.

  (* the entry fact for the tsafe invariant: the Object-pointer temps
     _t'49/_t'13 start Vundef (they are temps, not params), so any SafeB
     obligation on them is vacuous at entry. Mirrors tprov_entry. *)
  Lemma tsafe_entry_lp :
    forall (S : block -> Prop) vargs le,
      bind_parameter_temps (fn_params mario.f_execute_mario_action) vargs
         (create_undef_temps (fn_temps mario.f_execute_mario_action)) = Some le ->
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> S b) /\
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> S b).
  Proof.
    intros S vargs le Hbind.
    assert (Hother : forall id, ~ In id (var_names (fn_params mario.f_execute_mario_action)) ->
              le ! id = (create_undef_temps (fn_temps mario.f_execute_mario_action)) ! id)
      by (intros id Hnin; eapply bind_parameter_temps_other; [ exact Hbind | exact Hnin ]).
    split; intros b o Hlk;
      rewrite Hother in Hlk by (vm_compute; intuition discriminate);
      vm_compute in Hlk; discriminate Hlk.
  Qed.

  (* ---- THE MARG/MWF/REACHED BODY ENGINE over lp_ge. ---- *)
  Section ReachedLp.
    Variable bm gb : block.
    Hypothesis Hgb_lp : Genv.find_symbol lp_ge mario._gMarioState = Some gb.
    Variable NoA MWF : mem -> Prop.
    Variable SafeB : block -> Prop.
    Variable Reached_id : ident -> Prop.
    Variable Reached_fd : Clight.fundef -> Prop.

    (* the chase-root row of the carried MWF: the marioObj cell's value, if
       a pointer, lands in the safe object region. At the grounded capstone
       this is exactly MWFReal.mwf_real_chase_root at fld := _marioObj. *)
    Hypothesis chase_root_safe_lp : forall delta m b' o',
        field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
          = Errors.OK (delta, Full) ->
        MWF m ->
        Mem.loadv Mptr m (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
        SafeB b'.

    (* THE RESTATED STORE ROW (execution-relative). The two body stores go
       through _t'49/_t'13, and the walk hands this row their SafeB
       provenance (chased from the marioObj cell under MWF, threaded by the
       tsafe invariant below). The previous forall-le rows were FALSE for
       the real lp: an adversarial le binding _t'49 := Vptr bc d lets
       store1 (a halfword store) overwrite the controller A-cell,
       breaking ctl_a_clear (= the grounded NoA) and the carried MWF. *)
    Hypothesis store_pres_safe_lp :
      forall e le m a1 a2 t le' m' out,
        NoA m -> MWF m -> prov_ok (Sassign a1 a2) ->
        (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
        (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
        exec_stmt function_entry2 lp_ge e le m (Sassign a1 a2) t le' m' out ->
        NoA m' /\ MWF m'.
    (* NO external/builtin hypothesis -- see the note in ProvEngineLp: the
       census forbids Sbuiltin, the engine refutes the case. *)
    Hypothesis reach_meminv_reached_lp :
      forall m fd vargs t m' vres,
        Reached_fd fd -> NoA m -> meminv_lp bm m -> MWF m -> marg_ok bm vargs ->
        sargs_ok fd vargs ->
        eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
        NoA m' /\ meminv_lp bm m' /\ MWF m'.
    (* the call-resolution hypothesis is stated at the EMPTY env -- the only
       env the root-body walk ever runs in (fn_vars = nil). Quantifying an
       arbitrary e here would be a forall-e phantom: an adversarial local
       binding could alias a censused callee ident to ANY function pointer,
       making the hypothesis unsatisfiable for a CONCRETE Reached_fd. *)
    Hypothesis body_call_reached_lp :
      forall oid a al le mm vf fd,
        reach_chk Reached_id (Scall oid a al) ->
        eval_expr lp_ge empty_env le mm a vf ->
        Genv.find_funct lp_ge vf = Some fd -> Reached_fd fd.

    (* the SafeB temp invariant carried by the walk: the two Object-pointer
       temps, IF they hold pointers, point into the safe region. *)
    Definition tsafe (le : temp_env) : Prop :=
      (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) /\
      (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b).

    (* `t = stid->marioObj` makes t SafeB, via the exported chase-root load
       + the carried MWF's chase-root row. *)
    Lemma sset_marioObj_safeb_lp :
      forall tid stid e le m t le' m' out,
        (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
        MWF m ->
        exec_stmt function_entry2 lp_ge e le m
          (Sset tid (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._marioObj (tptr (Tstruct mario._Object noattr)))) t le' m' out ->
        forall b o, le' ! tid = Some (Vptr b o) -> SafeB b.
    Proof.
      intros tid stid e le m t le' m' out Hstid HM H b o Hle'. inv H.
      rewrite PTree.gss in Hle'. inv Hle'.
      match goal with Hev : eval_expr _ _ _ _ _ (Vptr b o) |- _ =>
        pose proof (eval_marioObj_load_lp _ _ _ _ _ _ _ Hstid Hev) as Hld end.
      eapply chase_root_safe_lp; [ exact marioObj_offset_mario | exact HM | exact Hld ].
    Qed.

    (* tsafe across an Sset: re-established by the chase-root row for a
       tracked temp (the census pins its RHS), gso for the rest. *)
    Lemma tsafe_sset_preserves :
      forall e le m id a t le' m' out,
        meminv_lp bm m -> MWF m ->
        tprov bm gb le -> tsafe le -> prov_sset_ok id a ->
        exec_stmt function_entry2 lp_ge e le m (Sset id a) t le' m' out ->
        tsafe le'.
    Proof.
      intros e le m id a t le' m' out Hmem HM Htp Hts Hck Hexec.
      inversion Hexec; subst.
      destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
      destruct Htp as (T48 & T12 & _ & _).
      destruct Hts as (S49 & S13).
      destruct Hck as (C48 & C12 & C49 & C13).
      split.
      - intros bb oo Hs. destruct (Pos.eq_dec id mario._t'49) as [E|N].
        + subst id. rewrite (C49 eq_refl) in Hexec.
          eapply sset_marioObj_safeb_lp; [ exact T48 | exact HM | exact Hexec | exact Hs ].
        + rewrite PTree.gso in Hs by congruence. exact (S49 _ _ Hs).
      - intros bb oo Hs. destruct (Pos.eq_dec id mario._t'13) as [E|N].
        + subst id. rewrite (C13 eq_refl) in Hexec.
          eapply sset_marioObj_safeb_lp; [ exact T12 | exact HM | exact Hexec | exact Hs ].
        + rewrite PTree.gso in Hs by congruence. exact (S13 _ _ Hs).
    Qed.

    (* an untracked call-result temp leaves tsafe intact. *)
    Lemma tsafe_set_opttemp :
      forall oid v le, optid_untracked oid -> tsafe le -> tsafe (set_opttemp oid v le).
    Proof.
      intros oid v le Hut (S49 & S13). destruct oid as [id|]; [ | exact (conj S49 S13) ].
      destruct (Hut id eq_refl) as (_ & _ & N49 & N13).
      split; intros bb oo Hs; cbn [set_opttemp] in Hs;
        rewrite PTree.gso in Hs by congruence;
        [ exact (S49 _ _ Hs) | exact (S13 _ _ Hs) ].
    Qed.

    Theorem exec_body_prov_reached_lp :
      forall le m s t le' m' out,
        exec_stmt function_entry2 lp_ge empty_env le m s t le' m' out ->
        NoA m -> meminv_lp bm m -> tprov bm gb le -> Pgms bm le -> MWF m ->
        tsafe le ->
        prov_ok s -> pgms_chk s -> reach_chk Reached_id s ->
        NoA m' /\ meminv_lp bm m' /\ tprov bm gb le' /\ Pgms bm le' /\ MWF m' /\ tsafe le'.
    Proof.
      intros le m s t le' m' out H Hno Hmem Htp Hpg Hmwf Hts Hck Hpck Hrck.
      assert (He : empty_env ! mario._gMarioState = None) by apply PTree.gempty.
      apply (body_check_generic lp_ge empty_env
               (fun mm ll => NoA mm /\ meminv_lp bm mm /\ tprov bm gb ll /\ Pgms bm ll /\ MWF mm /\ tsafe ll)
               (fun ss => prov_ok ss /\ pgms_chk ss /\ reach_chk Reached_id ss))
        with (le := le) (m := m) (s := s) (t := t) (le' := le') (m' := m') (out := out);
        try exact H;
        try (split; [ exact Hno | split; [ exact Hmem | split; [ exact Htp
              | split; [ exact Hpg | split; [ exact Hmwf | exact Hts ] ] ] ] ]);
        try (split; [ exact Hck | split; [ exact Hpck | exact Hrck ] ]).
      - (* Sassign leaf: the restated store row consumes the tsafe facts *)
        intros le0 m0 a1 a2 t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0 & Hts0) (Hck0 & _ & _) Hexec.
        assert (Hle : le0' = le0) by (inversion Hexec; reflexivity). subst le0'.
        destruct (store_pres_safe_lp _ _ _ _ _ _ _ _ _ Hno0 Hmwf0 Hck0
                    (proj1 Hts0) (proj2 Hts0) Hexec) as (Hno0' & Hmwf0').
        split; [ exact Hno0' | ].
        split; [ | split; [ exact Htp0 | split; [ exact Hpg0 | split; [ exact Hmwf0' | exact Hts0 ] ] ] ].
        cbn [prov_ok] in Hck0.
        destruct Htp0 as (T48 & T12 & T49 & T13).
        destruct Hck0 as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst.
        + eapply (store_preserves_meminv_lp bm gb Hgb_lp store1_lval store1_rval mario._t'49 store1_loc_is_t49_lp);
            [ exact Hmem0 | exact T49 | exact Hexec ].
        + eapply (store_preserves_meminv_lp bm gb Hgb_lp store2_lval store2_rval mario._t'13 store2_loc_is_t13_lp);
            [ exact Hmem0 | exact T13 | exact Hexec ].
      - (* Sset leaf *)
        intros le0 m0 id a t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0 & Hts0) (Hck0 & Hpck0 & _) Hexec.
        cbn [prov_ok] in Hck0. cbn [pgms_chk] in Hpck0.
        assert (Hm : m0' = m0) by (inversion Hexec; reflexivity).
        pose proof Hmem0 as Hmemcopy. destruct Hmemcopy as (_ & _ & _ & Hgwf0).
        destruct (sset_case_preserves_lp bm gb Hgb_lp empty_env le0 m0 id a t0 le0' m0' out0 He Hmem0 Htp0 Hck0 Hexec)
          as (Hmem0' & Htp0').
        split; [ rewrite Hm; exact Hno0 | ].
        split; [ exact Hmem0' | split; [ exact Htp0' | split; [ | split ] ] ].
        + eapply pgms_sset_preserves_lp; [ exact He | exact Hgwf0 | exact Hpg0 | exact Hpck0 | exact Hexec ].
        + rewrite Hm; exact Hmwf0.
        + eapply tsafe_sset_preserves;
            [ exact Hmem0 | exact Hmwf0 | exact Htp0 | exact Hts0 | exact Hck0 | exact Hexec ].
      - (* Scall leaf *)
        intros le0 m0 oid a al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0 & Hts0) (Hck0 & Hpck0 & Hrck0) Hexec.
        cbn [prov_ok] in Hck0. cbn [pgms_chk] in Hpck0.
        destruct Hpck0 as (Hres & Hargs).
        inversion Hexec; subst.
        match goal with He0 : eval_expr _ _ _ _ a ?vf |- _ =>
          match goal with Hff : Genv.find_funct _ vf = Some ?fd |- _ =>
            assert (Hrf : Reached_fd fd)
              by (eapply body_call_reached_lp; [ exact Hrck0 | exact He0 | exact Hff ]) end end.
        match goal with Hel : eval_exprlist _ _ _ _ al _ ?vargs |- _ =>
          assert (Hmarg : marg_ok bm vargs)
            by (eapply call_arg0_marg_sound_lp; [ exact Hpg0 | exact Hargs | exact Hel ]) end.
        (* the sargs gate: exec_Scall's type_of_fundef pin makes the call-site
           tyargs the callee's true signature, so the gate holds GENERICALLY. *)
        match goal with
          Hel : eval_exprlist _ _ _ _ al _ ?vargs,
          Htof : type_of_fundef ?fd = Tfunction _ _ _ |- _ =>
            assert (Hsargs : sargs_ok fd vargs)
              by (intro Hs; unfold sig_sub32 in Hs; rewrite Htof in Hs; cbn in Hs;
                  apply Forall_forall; intros v0 Hin0;
                  exact (eval_exprlist_sub32i_vint _ _ _ _ _ _ _ Hel Hs v0 Hin0)) end.
        match goal with Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
          destruct (reach_meminv_reached_lp _ _ _ _ _ _ Hrf Hno0 Hmem0 Hmwf0 Hmarg Hsargs Hf)
            as (Hno0' & Hmem0' & Hmwf0') end.
        split; [ exact Hno0' | split; [ exact Hmem0' | split; [ | split; [ | split ] ] ] ].
        + apply tprov_set_opttemp; [ exact Hck0 | exact Htp0 ].
        + apply pgms_set_opttemp; [ exact Hres | exact Hpg0 ].
        + exact Hmwf0'.
        + apply tsafe_set_opttemp; [ exact Hck0 | exact Hts0 ].
      - (* Sbuiltin leaf: REFUTED by the census (the body has no builtins) *)
        intros le0 m0 oid ef tyl al t0 le0' m0' out0 _ (Hck0 & _) _.
        cbn [prov_ok] in Hck0. destruct Hck0.
      - (* Hseq *) intros s1 s2 Hd; destruct Hd as (Hp & Hg & Hr);
          cbn [prov_ok pgms_chk reach_chk] in Hp, Hg, Hr; tauto.
      - (* Hif *) intros a s1 s2 Hd; destruct Hd as (Hp & Hg & Hr);
          cbn [prov_ok pgms_chk reach_chk] in Hp, Hg, Hr; tauto.
      - (* Hloop *) intros s1 s2 Hd; destruct Hd as (Hp & Hg & Hr);
          cbn [prov_ok pgms_chk reach_chk] in Hp, Hg, Hr; tauto.
      - (* Hlabel *) intros l s0 Hd; destruct Hd as (Hp & Hg & Hr);
          cbn [prov_ok pgms_chk reach_chk] in Hp, Hg, Hr; tauto.
      - (* Hsw *) intros a ls n Hd; destruct Hd as (Hp & Hg & Hr);
          cbn [prov_ok pgms_chk reach_chk] in Hp, Hg, Hr.
        split; [ apply seq_of_prov_ok; apply select_switch_prov_ok; exact Hp
               | split; [ apply pgms_seq_of; apply pgms_select_switch; exact Hg
                        | apply reach_seq_of; apply reach_select_switch; exact Hr ] ].
    Qed.
  End ReachedLp.

  (* ---- the meminv build over lp_ge: NO funcall-level rest residual. ----
     The old reach_rest_marg_lp row (preserve NoA + the POSITIVE wf pair
     across every reached funcall) is GONE (2026-06-10): with the wf pair
     CONDITIONAL, everything the wrapper needs after a funcall is a
     projection of the MWF the value engine already returns --
       NoA       (at the grounding: ctl_a_clear = MWF_real's R2+R3),
       mobj_cond (R6 + the SafeB distinctness facts),
       gms_cond  (R5 verbatim).
     The three projection rows below are PROVED at the MWF_real grounding. *)
  Lemma reach_meminv_reached_build_lp :
    forall bm NoA MWF (Reached_fd : Clight.fundef -> Prop),
      reach_value_preserves_reached Qv bm lp_ge NoA MWF Reached_fd ->
      (forall m, MWF m -> NoA m) ->
      (forall m, MWF m -> mobj_cond_lp m bm) ->
      (forall m, MWF m -> gms_cond_lp m bm) ->
      forall m fd vargs t m' vres,
        Reached_fd fd ->
        NoA m -> meminv_lp bm m -> MWF m -> marg_ok bm vargs ->
        sargs_ok fd vargs ->
        eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
        NoA m' /\ meminv_lp bm m' /\ MWF m'.
  Proof.
    intros bm NoA MWF Reached_fd Hval Hnoa_mwf Hmo_mwf Hgm_mwf
           m fd vargs t m' vres Hrf Hno Hmem HMWF Hmarg Hsargs Hev.
    destruct Hmem as (Hv & Hsat & _ & _).
    destruct (Hval m fd vargs t m' vres Hrf Hno HMWF (fun _ => Hmarg) Hsargs Hev Hv Hsat) as (Hv' & Hsat' & HMWF').
    split; [ exact (Hnoa_mwf m' HMWF') | ].
    split; [ | exact HMWF' ].
    exact (conj Hv' (conj Hsat' (conj (Hmo_mwf m' HMWF') (Hgm_mwf m' HMWF')))).
  Qed.

  (* ================================================================== *)
  (* THE CAPSTONE-FACING RE-ROOTED WRAPPER (the _reached variant).        *)
  (* This is the exact analog of                                          *)
  (* RealFrameValue.execute_mario_action_preserves_real_reached -- the     *)
  (* theorem the capstone consumes -- now over globalenv lp. Its reach      *)
  (* residuals (reach_value_preserves_reached, reach_rest_marg_lp, the      *)
  (* ext/store/body_call residuals) all range over the LINKED genv, so the  *)
  (* dispatcher Scalls resolve to real Internal bodies and the residuals    *)
  (* are SATISFIABLE -- no false reach_ext_action_cell anywhere. This is    *)
  (* what NoAImpliesNoFly will consume in place of the mario_ge wrapper.    *)
  (* ================================================================== *)
  Theorem execute_mario_action_preserves_real_reached_lp :
    forall (bm : block) (NoA MWF : mem -> Prop) (SafeB : block -> Prop)
           (Reached_id : ident -> Prop) (Reached_fd : Clight.fundef -> Prop) m m',
      reach_value_preserves_reached Qv bm lp_ge NoA MWF Reached_fd ->
      (forall mm, MWF mm -> NoA mm) ->
      (forall mm, MWF mm -> mobj_cond_lp mm bm) ->
      (forall mm, MWF mm -> gms_cond_lp mm bm) ->
      (forall delta mm b' o',
          field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members
            = Errors.OK (delta, Full) ->
          MWF mm ->
          Mem.loadv Mptr mm (Vptr bm (Ptrofs.repr delta)) = Some (Vptr b' o') ->
          SafeB b') ->
      (forall e le mm a1 a2 tt le' mm' out,
          NoA mm -> MWF mm -> prov_ok (Sassign a1 a2) ->
          (forall b o, le ! mario._t'49 = Some (Vptr b o) -> SafeB b) ->
          (forall b o, le ! mario._t'13 = Some (Vptr b o) -> SafeB b) ->
          exec_stmt function_entry2 lp_ge e le mm (Sassign a1 a2) tt le' mm' out ->
          NoA mm' /\ MWF mm') ->
      (forall oid a al le mm vf fd,
          reach_chk Reached_id (Scall oid a al) ->
          eval_expr lp_ge empty_env le mm a vf ->
          Genv.find_funct lp_ge vf = Some fd -> Reached_fd fd) ->
      reach_chk Reached_id (fn_body mario.f_execute_mario_action) ->
      NoA m -> MWF m ->
      Mem.valid_block m bm -> action_sat Qv m bm ->
      execute_mario_action_step_lp m m' ->
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\ MWF m'.
  Proof.
    intros bm NoA MWF SafeB Reached_id Reached_fd m m' Hval Hnoa_mwf Hmo_mwf Hgm_mwf
           Hchase Hstore Hbcr Hbodyrck
           HnoA HMWF Hv Hsat (b_o & t & res & Hfun).
    destruct gMarioState_symbol_resolves_lp as (gb & Hgb).
    pose proof (reach_meminv_reached_build_lp bm NoA MWF Reached_fd Hval
                  Hnoa_mwf Hmo_mwf Hgm_mwf) as Hreachmem.
    assert (HPm' :
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\ MWF m').
    { eapply (funcall_from_body_preserves_entry
                (fun mm => NoA mm /\ Mem.valid_block mm bm /\ action_sat Qv mm bm /\ MWF mm)
                lp_ge mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil)
                m m' t res eq_refl);
        [ | exact (conj HnoA (conj Hv (conj Hsat HMWF))) | exact Hfun ].
      intros le mm tt le' mm' out Hbind (Hn & Hvv & Hss & Hmf) Hexec.
      edestruct (exec_body_prov_reached_lp bm gb Hgb NoA MWF SafeB Reached_id Reached_fd
                   Hchase Hstore Hreachmem Hbcr
                   le mm (fn_body mario.f_execute_mario_action) tt le' mm' out)
        as (Hn' & Hmem' & _ & _ & Hmf' & _);
        [ exact Hexec
        | exact Hn
        | exact (conj Hvv (conj Hss (conj (Hmo_mwf mm Hmf) (Hgm_mwf mm Hmf))))
        | eapply tprov_entry; exact Hbind
        | eapply pgms_entry; exact Hbind
        | exact Hmf
        | eapply (tsafe_entry_lp SafeB); exact Hbind
        | exact execute_mario_action_body_prov_ok
        | exact execute_mario_action_body_pgms_ok
        | exact Hbodyrck
        | ].
      destruct Hmem' as (Hvv' & Hss' & _ & _).
      exact (conj Hn' (conj Hvv' (conj Hss' Hmf'))). }
    exact HPm'.
  Qed.

End ReRoot.
