(* ====================================================================== *)
(* RE-ROOTING THE FRAME OVER THE LINKED PROGRAM (work in progress).        *)
(*                                                                        *)
(* RealFrameValue.v threads `mario_ge = globalenv mario.prog` through the  *)
(* whole frame: over that single-TU genv the action dispatchers            *)
(* (mario_execute_*_action) are underspecified Externals, which is why the *)
(* capstone must assume the FALSE reach_ext_action_cell. The fix is to      *)
(* re-root the frame over `globalenv lp` for a LINKED program lp (lp kept   *)
(* ABSTRACT -- a linkorder hypothesis, never vm_compute'd, so no OOM).      *)
(* Over globalenv lp those dispatcher Scalls resolve to real Internal       *)
(* bodies (SymbolicLinking.linkorder_resolves_funct) and the engine         *)
(* TRAVERSES them instead of bouncing off the external bucket.             *)
(*                                                                        *)
(* This file is the staging area for that re-derivation. It re-states the   *)
(* frame's genv-facing predicates over an abstract `lp_ge := globalenv lp`  *)
(* and re-proves the eval bricks, consuming the three-part genv interface   *)
(* proved in SymbolicLinking.v (funcall resolution / field-offset agreement *)
(* / symbol preservation). It lives under Unwired/ until the full wrapper   *)
(* is re-rooted and can replace RealFrameValue's mario_ge wrapper on the    *)
(* spine. NOTHING here is consumed by the capstone yet.                     *)
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
      Mem.valid_block m bm /\ action_sat nonflying m bm /\
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
  End ProvEngineLp.

End ReRoot.
