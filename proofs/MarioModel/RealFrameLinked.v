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

  (* THE SECOND RE-ROOTED EVAL BRICK: the marioObj field load evaluates off bm
     over lp_ge -- the brick that CONSUMES the offset interface. Identical to
     RealFrameValue.eval_marioObj_off_bm except the two `rewrite cenv_eq` steps
     (false at lp_ge, where genv_cenv = the MERGED env) are replaced by:
       - linkorder_comp_env_extends : pin co to mario's MarioState composite, and
       - linkorder_field_offset_agree : move the offset onto mario.prog's cenv.
     Everything else threads via the genv-parametric inversion helpers. *)
  Lemma eval_marioObj_off_bm_lp :
    forall stid e le m bm bobj o,
      (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
      marioObj_wf_lp m bm ->
      eval_expr lp_ge e le m
        (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                        (Tstruct mario._MarioState noattr))
                mario._marioObj (tptr (Tstruct mario._Object noattr)))
        (Vptr bobj o) ->
      bobj <> bm /\ (forall gb, Genv.find_symbol lp_ge mario._gMarioState = Some gb -> bobj <> gb).
  Proof.
    intros stid e le m bm bobj o Ht48 (off & bobj0 & ofs0w & Hfo & Hload & Hne & Hng) Hev.
    apply eval_expr_Efield_load in Hev as (loc & ofs & bf & Hlv & Hderef).
    apply eval_lvalue_Efield_inv in Hlv as (o0 & id & att & co & delta & Hbase & Hco & Hofs & Hcase).
    apply eval_expr_Ederef_load in Hbase as (lb & ob & bfb & Hlvb & Hderefb).
    apply deref_loc_aggregate_eq in Hderefb as [? ?]; [ | right; reflexivity ]. subst lb ob.
    apply eval_lvalue_Ederef_base in Hlvb.
    apply eval_expr_Etempvar_val in Hlvb. destruct (Ht48 _ _ Hlvb) as [Hl Ho]. subst.
    destruct Hcase as [ (Hty & Hfo2) | (Hty & Hfo2) ]; [ | cbn in Hty; discriminate ].
    cbn in Hty; inv Hty.
    (* Hco : (genv_cenv lp_ge) ! _MarioState = Some co (genv_cenv lp_ge convertibly
       = prog_comp_env lp). Pin co to mario's composite via composite preservation. *)
    change (genv_cenv lp_ge) with (prog_comp_env lp) in Hco, Hfo2.
    destruct mario_defines_MarioState as (co0 & Hmar).
    pose proof (linkorder_comp_env_extends lp mario.prog mario._MarioState co0 LO_mario Hmar)
      as Hext_lp.
    assert (co = co0) by congruence. subst co0.
    (* now Hmar : (prog_comp_env mario.prog) ! _MarioState = Some co. *)
    assert (Hmm : mario_state_members = co_members co)
      by (unfold mario_state_members; rewrite Hmar; reflexivity).
    (* Move Hfo2's offset off the merged env onto mario.prog's cenv. *)
    rewrite (linkorder_field_offset_agree lp mario.prog mario._marioObj (co_members co)
               LO_mario) in Hfo2;
      [ | rewrite <- Hmm; exact mario_state_members_complete ].
    (* now Hfo2 : field_offset (prog_comp_env mario.prog) _marioObj (co_members co) = OK(delta,bf) *)
    rewrite Hmm in Hfo. rewrite Hfo in Hfo2. inv Hfo2.
    rewrite Ptrofs.add_zero_l in Hderef.
    inv Hderef;
      try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
      try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
      try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end);
      match goal with
      | Hac : access_mode _ = By_value ?chunk,
        Hlv3 : Mem.loadv ?chunk _ _ = Some (Vptr bobj o) |- _ =>
          cbn in Hac; inv Hac; rewrite Hlv3 in Hload; inv Hload; split; [ exact Hne | exact Hng ]
      end.
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

    (* the carried memory invariant, re-rooted at lp_ge (uses the _lp wf preds). *)
    Definition meminv_lp (m : mem) : Prop :=
      Mem.valid_block m bm /\ action_sat Qv m bm /\
      marioObj_wf_lp m bm /\ gMarioState_wf_lp m bm.

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
      intros a1 a2 tid Hgeom e le m t le' m' out (Hv & Hsat & Hmwf & Hgwf) Hoff Hexec. inv Hexec.
      match goal with H : eval_lvalue _ _ _ _ a1 _ _ _ |- _ => rename H into Hlv end.
      match goal with H : assign_loc _ _ _ _ _ _ _ _ |- _ => rename H into Has end.
      apply Hgeom in Hlv as (d & Htmp). destruct (Hoff _ _ Htmp) as [Hnbm Hngb].
      split; [ eapply assign_loc_valid_block; [ exact Has | exact Hv ] | ].
      split; [ eapply assign_loc_action_sat_avoid;
                 [ exact Has | exact Hv | intros i _ [Hb _]; congruence | exact Hsat ] | ].
      split.
      - destruct Hmwf as (off & bobj & ofs0 & Hfo & Hldv & Hbobj & Hng).
        exists off, bobj, ofs0. split; [ exact Hfo | ].
        split; [ | split; [ exact Hbobj | exact Hng ] ].
        eapply assign_loc_off_loadv; [ exact Has | exact (not_eq_sym Hnbm) | exact Hv | exact Hldv ].
      - destruct Hgwf as (gb' & Hsym & Hldv). assert (gb' = gb) by congruence. subst gb'.
        exists gb. split; [ exact Hsym | ].
        eapply assign_loc_off_loadv;
          [ exact Has | exact (not_eq_sym Hngb) | eapply loadv_valid_block; exact Hldv | exact Hldv ].
    Qed.

    (* ---- THE Sset CASE, re-rooted. ---- *)

    (* `t = gMarioState` makes t hold Vptr bm 0, over lp_ge. Mirrors sset_gms_bm;
       the eval helpers (eval_expr_Evar_load / eval_lvalue_Evar_global_loc) are
       genv-parametric, so only the genv + wf predicate change. *)
    Lemma sset_gms_bm_lp :
      forall tid e le m t le' m' out,
        e ! mario._gMarioState = None ->
        gMarioState_wf_lp m bm ->
        exec_stmt function_entry2 lp_ge e le m
          (Sset tid (Evar mario._gMarioState (tptr (Tstruct mario._MarioState noattr)))) t le' m' out ->
        le' ! tid = Some (Vptr bm Ptrofs.zero).
    Proof.
      intros tid e le m t le' m' out He (gb0 & Hsym & Hload) H. inv H.
      match goal with Hev : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
        apply eval_expr_Evar_load in Hev as (loc & ofs & bf & Hlv & Hd) end.
      apply eval_lvalue_Evar_global_loc in Hlv as [Hfs Hofs]; [ | exact He ].
      assert (loc = gb0) by congruence. subst.
      inv Hd;
        try (match goal with Hac : access_mode _ = By_reference |- _ => cbn in Hac; discriminate end);
        try (match goal with Hac : access_mode _ = By_copy |- _ => cbn in Hac; discriminate end);
        try (match goal with Hlb : load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hlb end).
      match goal with
      | Hac : access_mode _ = By_value ?chunk, Hl : Mem.loadv ?chunk _ _ = _ |- _ =>
          cbn in Hac; inv Hac; rewrite Hl in Hload; inv Hload
      end.
      rewrite PTree.gss; reflexivity.
    Qed.

    (* `t = stid->marioObj` makes t hold an off-{bm,gb} pointer, over lp_ge.
       Consumes eval_marioObj_off_bm_lp and the section's Hgb_lp. *)
    Lemma sset_marioObj_offbm_lp :
      forall tid stid e le m t le' m' out,
        (forall b o', le ! stid = Some (Vptr b o') -> b = bm /\ o' = Ptrofs.zero) ->
        marioObj_wf_lp m bm ->
        exec_stmt function_entry2 lp_ge e le m
          (Sset tid (Efield (Ederef (Etempvar stid (tptr (Tstruct mario._MarioState noattr)))
                                    (Tstruct mario._MarioState noattr))
                            mario._marioObj (tptr (Tstruct mario._Object noattr)))) t le' m' out ->
        forall b o, le' ! tid = Some (Vptr b o) -> b <> bm /\ b <> gb.
    Proof.
      intros tid stid e le m t le' m' out Hstid Hwf H b o Hle'. inv H.
      rewrite PTree.gss in Hle'. inv Hle'.
      match goal with Hev : eval_expr _ _ _ _ _ (Vptr b o) |- _ =>
        pose proof (eval_marioObj_off_bm_lp _ _ _ _ _ _ _ Hstid Hwf Hev) as [Hbm Hgbfn] end.
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
          rewrite (sset_gms_bm_lp _ _ _ _ _ _ _ _ He Hgwf Hexec) in Hs. inv Hs; auto.
        + rewrite PTree.gso in Hs by congruence. exact (T48 _ _ Hs).
      - unfold RealFrameValue.tat. intros bb oo Hs. destruct (Pos.eq_dec id mario._t'12) as [E|N].
        + subst id. rewrite (C12 eq_refl) in Hexec.
          rewrite (sset_gms_bm_lp _ _ _ _ _ _ _ _ He Hgwf Hexec) in Hs. inv Hs; auto.
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

    (* ---- THE NO-A-THREADED REACH RESIDUALS, re-rooted at lp_ge. These are the
       analog of RealFrameValue's reach_meminv_noA / ext_meminv_noA / noA_store_pres,
       now over globalenv lp. KEY POINT OF THE WHOLE RE-ROOTING: in
       reach_meminv_noA_lp the eval_funcall ranges over the LINKED genv, so a
       dispatcher Scall (mario_execute_*_action) resolves to its REAL Internal body
       and is traversed -- it is NO LONGER an underspecified external bouncing off
       the false reach_ext_action_cell. The residual is now SATISFIABLE for the
       real linked program (to be discharged in Phase B by the A-gating closure). *)
    Variable NoA : mem -> Prop.
    Hypothesis reach_meminv_noA_lp :
      forall m fd vargs t m' vres,
        NoA m -> meminv_lp m ->
        eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
        NoA m' /\ meminv_lp m'.
    Hypothesis ext_meminv_noA_lp :
      forall ef vargs m t vres m',
        NoA m -> meminv_lp m ->
        external_call ef lp_ge vargs m t vres m' ->
        NoA m' /\ meminv_lp m'.
    Hypothesis noA_store_pres_lp :
      forall e le m a1 a2 t le' m' out,
        NoA m -> prov_ok (Sassign a1 a2) ->
        exec_stmt function_entry2 lp_ge e le m (Sassign a1 a2) t le' m' out ->
        NoA m'.

    (* THE RE-ROOTED BODY CENSUS: the body of f_execute_mario_action preserves
       NoA /\ meminv_lp /\ tprov over lp_ge. Same body_prov_generic assembly as
       RealFrameValue.exec_body_prov_noA, now at lp_ge with the _lp leaves. The
       generic engine is forall-ge, so it applies directly. *)
    Theorem exec_body_prov_noA_lp :
      forall e le m s t le' m' out,
        e ! mario._gMarioState = None ->
        exec_stmt function_entry2 lp_ge e le m s t le' m' out ->
        NoA m -> meminv_lp m -> tprov bm gb le -> prov_ok s ->
        NoA m' /\ meminv_lp m' /\ tprov bm gb le'.
    Proof.
      intros e le m s t le' m' out He H Hno Hmem Htp Hck.
      apply (body_prov_generic lp_ge e
               (fun mm ll => NoA mm /\ meminv_lp mm /\ tprov bm gb ll))
        with (le := le) (m := m) (s := s) (t := t) (le' := le') (m' := m') (out := out);
        try assumption; try (split; [ exact Hno | split; assumption ]).
      - (* Sassign leaf *)
        intros le0 m0 a1 a2 t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
        assert (Hle : le0' = le0) by (inversion Hexec; reflexivity). subst le0'.
        split; [ eapply noA_store_pres_lp; [ exact Hno0 | exact Hck' | exact Hexec ] | ].
        split; [ | exact Htp0 ].
        cbn [prov_ok] in Hck'.
        destruct Htp0 as (T48 & T12 & T49 & T13).
        destruct Hck' as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst.
        + eapply (store_preserves_meminv_lp store1_lval store1_rval mario._t'49 store1_loc_is_t49_lp);
            [ exact Hmem0 | exact T49 | exact Hexec ].
        + eapply (store_preserves_meminv_lp store2_lval store2_rval mario._t'13 store2_loc_is_t13_lp);
            [ exact Hmem0 | exact T13 | exact Hexec ].
      - (* Sset leaf *)
        intros le0 m0 id a t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
        cbn [prov_ok] in Hck'.
        assert (Hm : m0' = m0) by (inversion Hexec; reflexivity).
        split; [ rewrite Hm; exact Hno0 | ].
        eapply sset_case_preserves_lp; [ exact He | exact Hmem0 | exact Htp0 | exact Hck' | exact Hexec ].
      - (* Scall leaf *)
        intros le0 m0 oid a al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
        cbn [prov_ok] in Hck'.
        inversion Hexec; subst.
        match goal with Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
          destruct (reach_meminv_noA_lp _ _ _ _ _ _ Hno0 Hmem0 Hf) as (Hno0' & Hmem0') end.
        split; [ exact Hno0' | split; [ exact Hmem0' | apply tprov_set_opttemp; assumption ] ].
      - (* Sbuiltin leaf *)
        intros le0 m0 oid ef tyl al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0) Hck' Hexec.
        cbn [prov_ok] in Hck'.
        inversion Hexec; subst.
        match goal with Hec : external_call _ _ _ _ _ _ _ |- _ =>
          destruct (ext_meminv_noA_lp _ _ _ _ _ _ Hno0 Hmem0 Hec) as (Hno0' & Hmem0') end.
        split; [ exact Hno0' | split; [ exact Hmem0' | apply tprov_set_opttemp; assumption ] ].
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

  (* the "rest" reach residual over lp_ge: every reached funcall preserves NoA
     and the two Mario-pointer invariants. (The value half -- valid + action_sat
     -- is the separate reach_value_preserves_noA at lp_ge.) *)
  Definition reach_rest_noA_lp (bm : block) (NoA : mem -> Prop) : Prop :=
    forall m fd vargs t m' vres,
      NoA m ->
      eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
      marioObj_wf_lp m bm -> gMarioState_wf_lp m bm ->
      NoA m' /\ marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm.

  Lemma reach_meminv_noA_build_lp :
    forall bm NoA,
      reach_value_preserves_noA Qv bm lp_ge NoA ->
      reach_rest_noA_lp bm NoA ->
      forall m fd vargs t m' vres,
        NoA m -> meminv_lp bm m ->
        eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
        NoA m' /\ meminv_lp bm m'.
  Proof.
    intros bm NoA Hval Hrest m fd vargs t m' vres Hno Hmem Hev.
    unfold meminv_lp in Hmem. destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
    destruct (Hval m fd vargs t m' vres Hno Hev Hv Hsat) as (Hv' & Hsat').
    destruct (Hrest m fd vargs t m' vres Hno Hev Hmwf Hgwf) as (Hno' & Hmwf' & Hgwf').
    split; [ exact Hno' | unfold meminv_lp; repeat split; assumption ].
  Qed.

  (* THE REDUCTION (re-rooted): a real frame over lp preserves NoA and the full
     memory invariant, reduced to the no-A reach/ext/store residuals over lp. The
     body is discharged by exec_body_prov_noA_lp; the entry facts (e = empty_env,
     tprov vacuous via the reused ge-free tprov_entry, body census via the ge-free
     execute_mario_action_body_prov_ok) and the gb from gMarioState_wf_lp are
     supplied here. funcall_from_body_preserves_entry is genv-parametric. *)
  Theorem execute_mario_action_preserves_real_lp :
    forall (bm : block) (NoA : mem -> Prop) m m',
      reach_value_preserves_noA Qv bm lp_ge NoA ->
      reach_rest_noA_lp bm NoA ->
      (forall ef vargs mm tt vres mm',
          NoA mm -> meminv_lp bm mm ->
          external_call ef lp_ge vargs mm tt vres mm' -> NoA mm' /\ meminv_lp bm mm') ->
      (forall e le mm a1 a2 tt le' mm' out,
          NoA mm -> prov_ok (Sassign a1 a2) ->
          exec_stmt function_entry2 lp_ge e le mm (Sassign a1 a2) tt le' mm' out -> NoA mm') ->
      NoA m ->
      Mem.valid_block m bm -> action_sat Qv m bm ->
      marioObj_wf_lp m bm -> gMarioState_wf_lp m bm ->
      execute_mario_action_step_lp m m' ->
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\
      marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm.
  Proof.
    intros bm NoA m m' Hval Hrest Hext Hstore HnoA Hv Hsat Hmwf Hgwf
           (b_o & t & res & Hfun).
    pose proof Hgwf as Hgwf2. destruct Hgwf2 as (gb & Hgb & Hload).
    pose proof (reach_meminv_noA_build_lp bm NoA Hval Hrest) as Hreachmem.
    assert (HPm' :
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\
      marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm).
    { eapply (funcall_from_body_preserves_entry
                (fun mm => NoA mm /\ Mem.valid_block mm bm /\ action_sat Qv mm bm /\
                           marioObj_wf_lp mm bm /\ gMarioState_wf_lp mm bm)
                lp_ge mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil)
                m m' t res eq_refl);
        [ | exact (conj HnoA (conj Hv (conj Hsat (conj Hmwf Hgwf)))) | exact Hfun ].
      intros le mm tt le' mm' out Hbind (Hn & Hvv & Hss & Hmw & Hgw) Hexec.
      edestruct (exec_body_prov_noA_lp bm gb Hgb NoA Hreachmem Hext Hstore
                   empty_env le mm (fn_body mario.f_execute_mario_action) tt le' mm' out)
        as (Hn' & Hmem' & _);
        [ apply PTree.gempty
        | exact Hexec
        | exact Hn
        | exact (conj Hvv (conj Hss (conj Hmw Hgw)))
        | eapply tprov_entry; exact Hbind
        | exact execute_mario_action_body_prov_ok
        | ].
      unfold meminv_lp in Hmem'. destruct Hmem' as (Hvv' & Hss' & Hmw' & Hgw').
      exact (conj Hn' (conj Hvv' (conj Hss' (conj Hmw' Hgw')))). }
    exact HPm'.
  Qed.

  (* ================================================================== *)
  (* TOWARD THE _REACHED VARIANT (the one the capstone consumes).         *)
  (*                                                                    *)
  (* The capstone uses the marg/MWF/reached-gated wrapper                 *)
  (* execute_mario_action_preserves_real_reached, not the basic one above. *)
  (* The marg-gating is ESSENTIAL and orthogonal to the genv: the          *)
  (* forall-vargs reach is FALSE for a misaligned Mario arg, so the basic   *)
  (* _lp wrapper, while a complete template, would re-introduce vacuity if   *)
  (* consumed. These two bricks are the only remaining genv-dependent pieces *)
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
      gMarioState_wf_lp m bm ->
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
      pose proof (sset_gms_bm_lp bm id e le m t (PTree.set id v le) m' out He Hgwf Hexec) as Hbm0.
      rewrite Hbm0 in Hs. inv Hs. split; reflexivity.
    - rewrite PTree.gso in Hs by congruence. exact (HP tt Hin b o Hs).
  Qed.

  (* ---- THE MARG/MWF/REACHED BODY ENGINE over lp_ge. ---- *)
  Section ReachedLp.
    Variable bm gb : block.
    Hypothesis Hgb_lp : Genv.find_symbol lp_ge mario._gMarioState = Some gb.
    Variable NoA MWF : mem -> Prop.
    Variable Reached_id : ident -> Prop.
    Variable Reached_fd : Clight.fundef -> Prop.

    Hypothesis noA_store_pres_lp :
      forall e le m a1 a2 t le' m' out,
        NoA m -> prov_ok (Sassign a1 a2) ->
        exec_stmt function_entry2 lp_ge e le m (Sassign a1 a2) t le' m' out -> NoA m'.
    Hypothesis store_mwf_lp :
      forall e le m a1 a2 t le' m' out,
        NoA m -> prov_ok (Sassign a1 a2) -> MWF m ->
        exec_stmt function_entry2 lp_ge e le m (Sassign a1 a2) t le' m' out -> MWF m'.
    Hypothesis ext_mwf_lp :
      forall ef vargs m t vres m',
        NoA m -> meminv_lp bm m -> MWF m ->
        external_call ef lp_ge vargs m t vres m' ->
        NoA m' /\ meminv_lp bm m' /\ MWF m'.
    Hypothesis reach_meminv_reached_lp :
      forall m fd vargs t m' vres,
        Reached_fd fd -> NoA m -> meminv_lp bm m -> MWF m -> marg_ok bm vargs ->
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

    Theorem exec_body_prov_reached_lp :
      forall le m s t le' m' out,
        exec_stmt function_entry2 lp_ge empty_env le m s t le' m' out ->
        NoA m -> meminv_lp bm m -> tprov bm gb le -> Pgms bm le -> MWF m ->
        prov_ok s -> pgms_chk s -> reach_chk Reached_id s ->
        NoA m' /\ meminv_lp bm m' /\ tprov bm gb le' /\ Pgms bm le' /\ MWF m'.
    Proof.
      intros le m s t le' m' out H Hno Hmem Htp Hpg Hmwf Hck Hpck Hrck.
      assert (He : empty_env ! mario._gMarioState = None) by apply PTree.gempty.
      apply (body_check_generic lp_ge empty_env
               (fun mm ll => NoA mm /\ meminv_lp bm mm /\ tprov bm gb ll /\ Pgms bm ll /\ MWF mm)
               (fun ss => prov_ok ss /\ pgms_chk ss /\ reach_chk Reached_id ss))
        with (le := le) (m := m) (s := s) (t := t) (le' := le') (m' := m') (out := out);
        try exact H;
        try (split; [ exact Hno | split; [ exact Hmem | split; [ exact Htp
              | split; [ exact Hpg | exact Hmwf ] ] ] ]);
        try (split; [ exact Hck | split; [ exact Hpck | exact Hrck ] ]).
      - (* Sassign leaf *)
        intros le0 m0 a1 a2 t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0) (Hck0 & _ & _) Hexec.
        assert (Hle : le0' = le0) by (inversion Hexec; reflexivity). subst le0'.
        assert (Hno0' : NoA m0') by (eapply noA_store_pres_lp; [ exact Hno0 | exact Hck0 | exact Hexec ]).
        assert (Hmwf0' : MWF m0') by (eapply store_mwf_lp; [ exact Hno0 | exact Hck0 | exact Hmwf0 | exact Hexec ]).
        split; [ exact Hno0' | ].
        split; [ | split; [ exact Htp0 | split; [ exact Hpg0 | exact Hmwf0' ] ] ].
        cbn [prov_ok] in Hck0.
        destruct Htp0 as (T48 & T12 & T49 & T13).
        destruct Hck0 as [ [Ha1 Ha2] | [Ha1 Ha2] ]; subst.
        + eapply (store_preserves_meminv_lp bm gb Hgb_lp store1_lval store1_rval mario._t'49 store1_loc_is_t49_lp);
            [ exact Hmem0 | exact T49 | exact Hexec ].
        + eapply (store_preserves_meminv_lp bm gb Hgb_lp store2_lval store2_rval mario._t'13 store2_loc_is_t13_lp);
            [ exact Hmem0 | exact T13 | exact Hexec ].
      - (* Sset leaf *)
        intros le0 m0 id a t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0) (Hck0 & Hpck0 & _) Hexec.
        cbn [prov_ok] in Hck0. cbn [pgms_chk] in Hpck0.
        assert (Hm : m0' = m0) by (inversion Hexec; reflexivity).
        pose proof Hmem0 as Hmemcopy. destruct Hmemcopy as (_ & _ & _ & Hgwf0).
        destruct (sset_case_preserves_lp bm gb Hgb_lp empty_env le0 m0 id a t0 le0' m0' out0 He Hmem0 Htp0 Hck0 Hexec)
          as (Hmem0' & Htp0').
        split; [ rewrite Hm; exact Hno0 | ].
        split; [ exact Hmem0' | split; [ exact Htp0' | split ] ].
        + eapply pgms_sset_preserves_lp; [ exact He | exact Hgwf0 | exact Hpg0 | exact Hpck0 | exact Hexec ].
        + rewrite Hm; exact Hmwf0.
      - (* Scall leaf *)
        intros le0 m0 oid a al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0) (Hck0 & Hpck0 & Hrck0) Hexec.
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
        match goal with Hf : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
          destruct (reach_meminv_reached_lp _ _ _ _ _ _ Hrf Hno0 Hmem0 Hmwf0 Hmarg Hf)
            as (Hno0' & Hmem0' & Hmwf0') end.
        split; [ exact Hno0' | split; [ exact Hmem0' | split; [ | split ] ] ].
        + apply tprov_set_opttemp; [ exact Hck0 | exact Htp0 ].
        + apply pgms_set_opttemp; [ exact Hres | exact Hpg0 ].
        + exact Hmwf0'.
      - (* Sbuiltin leaf *)
        intros le0 m0 oid ef tyl al t0 le0' m0' out0 (Hno0 & Hmem0 & Htp0 & Hpg0 & Hmwf0) (Hck0 & Hpck0 & _) Hexec.
        cbn [prov_ok] in Hck0. cbn [pgms_chk] in Hpck0.
        inversion Hexec; subst.
        match goal with Hec : external_call _ _ _ _ _ _ _ |- _ =>
          destruct (ext_mwf_lp _ _ _ _ _ _ Hno0 Hmem0 Hmwf0 Hec) as (Hno0' & Hmem0' & Hmwf0') end.
        split; [ exact Hno0' | split; [ exact Hmem0' | split; [ | split ] ] ].
        + apply tprov_set_opttemp; [ exact Hck0 | exact Htp0 ].
        + apply pgms_set_opttemp; [ exact Hpck0 | exact Hpg0 ].
        + exact Hmwf0'.
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

  (* ---- the marg-gated "rest" residual + meminv build over lp_ge. ---- *)
  Definition reach_rest_marg_lp (bm : block) (NoA : mem -> Prop) : Prop :=
    forall m fd vargs t m' vres,
      NoA m -> marg_ok bm vargs ->
      eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
      marioObj_wf_lp m bm -> gMarioState_wf_lp m bm ->
      NoA m' /\ marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm.

  Lemma reach_meminv_reached_build_lp :
    forall bm NoA MWF (Reached_fd : Clight.fundef -> Prop),
      reach_value_preserves_reached Qv bm lp_ge NoA MWF Reached_fd ->
      reach_rest_marg_lp bm NoA ->
      forall m fd vargs t m' vres,
        Reached_fd fd ->
        NoA m -> meminv_lp bm m -> MWF m -> marg_ok bm vargs ->
        eval_funcall function_entry2 lp_ge m fd vargs t m' vres ->
        NoA m' /\ meminv_lp bm m' /\ MWF m'.
  Proof.
    intros bm NoA MWF Reached_fd Hval Hrest m fd vargs t m' vres Hrf Hno Hmem HMWF Hmarg Hev.
    unfold meminv_lp in Hmem. destruct Hmem as (Hv & Hsat & Hmwf & Hgwf).
    destruct (Hval m fd vargs t m' vres Hrf Hno HMWF (fun _ => Hmarg) Hev Hv Hsat) as (Hv' & Hsat' & HMWF').
    destruct (Hrest m fd vargs t m' vres Hno Hmarg Hev Hmwf Hgwf) as (Hno' & Hmwf' & Hgwf').
    split; [ exact Hno' | split; [ unfold meminv_lp; repeat split; assumption | exact HMWF' ] ].
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
    forall (bm : block) (NoA MWF : mem -> Prop)
           (Reached_id : ident -> Prop) (Reached_fd : Clight.fundef -> Prop) m m',
      reach_value_preserves_reached Qv bm lp_ge NoA MWF Reached_fd ->
      reach_rest_marg_lp bm NoA ->
      (forall ef vargs mm tt vres mm',
          NoA mm -> meminv_lp bm mm -> MWF mm ->
          external_call ef lp_ge vargs mm tt vres mm' ->
          NoA mm' /\ meminv_lp bm mm' /\ MWF mm') ->
      (forall e le mm a1 a2 tt le' mm' out,
          NoA mm -> prov_ok (Sassign a1 a2) ->
          exec_stmt function_entry2 lp_ge e le mm (Sassign a1 a2) tt le' mm' out -> NoA mm') ->
      (forall e le mm a1 a2 tt le' mm' out,
          NoA mm -> prov_ok (Sassign a1 a2) -> MWF mm ->
          exec_stmt function_entry2 lp_ge e le mm (Sassign a1 a2) tt le' mm' out -> MWF mm') ->
      (forall oid a al le mm vf fd,
          reach_chk Reached_id (Scall oid a al) ->
          eval_expr lp_ge empty_env le mm a vf ->
          Genv.find_funct lp_ge vf = Some fd -> Reached_fd fd) ->
      reach_chk Reached_id (fn_body mario.f_execute_mario_action) ->
      NoA m -> MWF m ->
      Mem.valid_block m bm -> action_sat Qv m bm ->
      marioObj_wf_lp m bm -> gMarioState_wf_lp m bm ->
      execute_mario_action_step_lp m m' ->
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\
      marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm /\ MWF m'.
  Proof.
    intros bm NoA MWF Reached_id Reached_fd m m' Hval Hrest Hext Hstore Hstoremwf Hbcr Hbodyrck
           HnoA HMWF Hv Hsat Hmwf Hgwf (b_o & t & res & Hfun).
    pose proof Hgwf as Hgwf2. destruct Hgwf2 as (gb & Hgb & Hload).
    pose proof (reach_meminv_reached_build_lp bm NoA MWF Reached_fd Hval Hrest) as Hreachmem.
    assert (HPm' :
      NoA m' /\ Mem.valid_block m' bm /\ action_sat Qv m' bm /\
      marioObj_wf_lp m' bm /\ gMarioState_wf_lp m' bm /\ MWF m').
    { eapply (funcall_from_body_preserves_entry
                (fun mm => NoA mm /\ Mem.valid_block mm bm /\ action_sat Qv mm bm /\
                           marioObj_wf_lp mm bm /\ gMarioState_wf_lp mm bm /\ MWF mm)
                lp_ge mario.f_execute_mario_action (Vptr b_o Ptrofs.zero :: nil)
                m m' t res eq_refl);
        [ | exact (conj HnoA (conj Hv (conj Hsat (conj Hmwf (conj Hgwf HMWF))))) | exact Hfun ].
      intros le mm tt le' mm' out Hbind (Hn & Hvv & Hss & Hmw & Hgw & Hmf) Hexec.
      edestruct (exec_body_prov_reached_lp bm gb Hgb NoA MWF Reached_id Reached_fd
                   Hstore Hstoremwf Hext Hreachmem Hbcr
                   le mm (fn_body mario.f_execute_mario_action) tt le' mm' out)
        as (Hn' & Hmem' & _ & _ & Hmf');
        [ exact Hexec
        | exact Hn
        | exact (conj Hvv (conj Hss (conj Hmw Hgw)))
        | eapply tprov_entry; exact Hbind
        | eapply pgms_entry; exact Hbind
        | exact Hmf
        | exact execute_mario_action_body_prov_ok
        | exact execute_mario_action_body_pgms_ok
        | exact Hbodyrck
        | ].
      unfold meminv_lp in Hmem'. destruct Hmem' as (Hvv' & Hss' & Hmw' & Hgw').
      exact (conj Hn' (conj Hvv' (conj Hss' (conj Hmw' (conj Hgw' Hmf'))))). }
    exact HPm'.
  Qed.

End ReRoot.
