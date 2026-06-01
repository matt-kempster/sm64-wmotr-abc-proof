(* ResetBodystate.v -- the FIRST real action-body preservation proof.
 *
 * GOAL (leaving abstract-land, per the user's push). Prove that executing a REAL
 * function's REAL body preserves "Mario's action field is non-flying" -- the
 * per-frame obligation the value-frame engine (ActionValueFrame) abstracts as a
 * hypothesis. This is the first time that hypothesis is discharged against actual
 * clightgen'd code, exercising the genuine aliasing question on real stores.
 *
 * WHY mario_reset_bodystate IS THE RIGHT FIRST TARGET (not act_panting):
 *   - it lives in mario.v -- the SAME TU as the globals gMarioState/gBodyStates,
 *     so no cross-TU linking is needed (act_panting is in a different TU);
 *   - it is CALL-FREE -- so no reach/callee specs are dragged in;
 *   - its body exercises BOTH real aliasing regimes in one function:
 *       * 5 POINTER-CHASE stores through bodyState (= m->marioBodyState):
 *         capState/eyeState/handState/modelState/wingFlutter -- these land in the
 *         gBodyStates block, DISTINCT from Mario's block (the MarioMemWF brick);
 *       * 1 DIRECT store m->flags = ... -- same block as the action cell, disjoint
 *         OFFSET (ActionFrame's field-offset disjointness).
 *   So one function is the clean unit test for the temp-provenance + block-
 *   separation mechanism, with nothing else entangled.
 *
 * THE MECHANISM. clightgen emits `bodyState = m->marioBodyState;` once, then every
 * body-field store goes THROUGH the temp bodyState. So the proof must thread the
 * temp's provenance: after the initial Sset, le!_bodyState = Vptr bbs _, and
 * mario_mem_wf says bbs <> bm. Each pointer-chase store's lvalue then evaluates to
 * block bbs, which avoids the action cell (bm,12) purely by bbs <> bm. The flags
 * store evaluates to block bm, avoided by offset disjointness.
 *
 * RESULT: mario_reset_bodystate preserves action_sat (non-flying), GIVEN
 * mario_mem_wf on the entry memory. No Admitted.
 *)

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep Events.
From Coq Require Import Lia.
Import Clightdefs.ClightNotations.
Local Open Scope clight_scope.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame ActionValueFrame MarioMemWF.

(* The non-flying predicate, as a Q for action_sat. *)
Definition nonflying (v : int) : Prop := is_flying_int v = false.

(* ------------------------------------------------------------------ *)
(* Per-store leaf: a store whose lvalue evaluates to block bbs, with    *)
(* bbs <> bm, avoids the action cell (bm,12) and so preserves action_sat.*)
(* This packages assign_loc_action_sat_avoid for the "different block"   *)
(* (pointer-chase) case -- the avoidance side condition is immediate     *)
(* because action_cell bm requires the block to BE bm.                   *)
(* ------------------------------------------------------------------ *)
Lemma store_offblock_preserves_action_sat :
  forall (Q : int -> Prop) ce ty m bm bbs ofs bf v m',
    assign_loc ce ty m bbs ofs bf v m' ->
    Mem.valid_block m bm ->
    bbs <> bm ->
    action_sat Q m bm ->
    action_sat Q m' bm.
Proof.
  intros Q ce ty m bm bbs ofs bf v m' Hassign Hvalid Hne Hsat.
  eapply assign_loc_action_sat_avoid; [ exact Hassign | exact Hvalid | | exact Hsat ].
  intros i _ [Hb _]. apply Hne. exact Hb.
Qed.

(* ------------------------------------------------------------------ *)
(* Generalized field-store-through-a-tempvar inverter: a store          *)
(*   p->fid = rhs        (p a tempvar holding Vptr blk off)             *)
(* lands its assign_loc in BLOCK blk. We keep ONLY the block (the       *)
(* offset/field identity are irrelevant for the block-distinctness      *)
(* avoidance argument). Mirrors ActionValue.exec_mario_field_store's    *)
(* inversion sequence, generalized over the base tempvar p, the struct  *)
(* ident sid, and the genv ge. *)
(* ------------------------------------------------------------------ *)
Lemma exec_field_store_block :
  forall ge (e : env) le m p sid sattr fid fty rhs t le' m' out blk off,
    le ! p = Some (Vptr blk off) ->
    exec_stmt function_entry2 ge e le m
      (Sassign (Efield (Ederef (Etempvar p (tptr (Tstruct sid sattr)))
                  (Tstruct sid sattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    exists ofs bf v, assign_loc (genv_cenv ge) fty m blk ofs bf v m'.
Proof.
  intros ge e le m p sid sattr fid fty rhs t le' m' out blk off Hp Hexec.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar p _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  (* pin the inner pointer to (blk, off) from le!p *)
  match goal with
  | Hlk : ?T ! p = Some (Vptr ?l ?o) |- _ =>
      assert (l = blk) by congruence; assert (o = off) by congruence; subst l o
  end.
  (* the struct base is read By_copy; reduce typeof in the deref_loc hyp first *)
  match goal with Hdl : deref_loc _ _ _ _ _ _ |- _ => cbn [typeof] in Hdl; inv Hdl end;
    try (match goal with Hac : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate end);
    try (match goal with Hac : access_mode (Tstruct _ _) = By_reference |- _ => discriminate end).
  split; [ reflexivity | split; [ reflexivity | ] ].
  (* whatever offset/bf/value the store used, the BLOCK is blk *)
  match goal with Hass : assign_loc _ _ _ _ ?ofs ?bf ?v _ |- _ =>
    exists ofs, bf, v; exact Hass end.
Qed.

(* ------------------------------------------------------------------ *)
(* genv_cenv of mario.prog's genv = its composite env (MarioMemWF's     *)
(* mario_ce). Plain reflexivity loops on Genv.globalenv; scope cbn to   *)
(* the projection (pipeline gotcha).                                    *)
(* ------------------------------------------------------------------ *)
Lemma genv_cenv_mario : genv_cenv mario_ge = mario_ce.
Proof. unfold mario_ge, mario_ce. cbn [genv_cenv globalenv]. reflexivity. Qed.

(* ------------------------------------------------------------------ *)
(* THE LOAD INVERTER (the blocker, done). The first statement of        *)
(* mario_reset_bodystate is  bodyState = m->marioBodyState  -- an Sset   *)
(* whose rhs is a By_value pointer-field load. Given that m->marioBody-  *)
(* State loads Vptr bbs ofs (the mario_mem_wf load fact), this Sset      *)
(* leaves memory unchanged and binds _bodyState to Vptr bbs ofs.         *)
(* Mirrors exec_field_store_block's lvalue-inversion sequence; the new   *)
(* part is the field's By_value deref_loc extraction (vs the store's     *)
(* By_copy), pinned to the wf load via the field offset.                 *)
(* ------------------------------------------------------------------ *)
Lemma exec_bodystate_load :
  forall e le m t le' m' out bm bbs off_bs ofs,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    field_offset mario_ce mario._marioBodyState mario_members = OK (off_bs, Full) ->
    Mem.load Mptr m bm off_bs = Some (Vptr bbs ofs) ->
    exec_stmt function_entry2 mario_ge e le m
      (Sset mario._bodyState
        (Efield
          (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
            (Tstruct mario._MarioState noattr)) mario._marioBodyState
          (tptr (Tstruct mario._MarioBodyState noattr)))) t le' m' out ->
    le' = PTree.set mario._bodyState (Vptr bbs ofs) le /\ m' = m /\ out = Out_normal.
Proof.
  intros e le m t le' m' out bm bbs off_bs ofs Hm Hfo Hld Hexec.
  (* pin off_bs to its literal value so all offset arithmetic is concrete *)
  assert (Hoff : off_bs = 200) by (vm_compute in Hfo; congruence).
  inv Hexec.
  (* Sset: goal is about PTree.set _bodyState v le; H : eval_expr .. (Efield..) v *)
  match goal with Hev : eval_expr _ _ _ _ (Efield _ _ _) ?v |- _ =>
    rename Hev into Heval; rename v into vfield end.
  (* the Efield rvalue: eval_Elvalue -> eval_lvalue (Efield) + deref_loc (field) *)
  inv Heval.
  (* eval_lvalue of Efield -> eval_Efield_struct (discharge the union case) *)
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  (* the struct base (Ederef ..) is read By_copy: eval_Elvalue again *)
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  (* pin the inner pointer to (bm, zero) from le!_m *)
  match goal with
  | Hlk : ?T ! mario._m = Some (Vptr ?l ?o) |- _ =>
      assert (l = bm) by congruence; assert (o = Ptrofs.zero) by congruence; subst l o
  end.
  (* reduce typeof in BOTH deref_loc hyps (struct base + field) so we can target
     each by its reduced type *)
  repeat match goal with
  | Hdl : deref_loc ?ty _ _ _ _ _ |- _ => progress cbn [typeof] in Hdl
  end.
  (* discharge the struct-base By_copy deref_loc *)
  match goal with Hdl : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ =>
    inv Hdl end;
    try (match goal with Hac : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate end);
    try (match goal with Hac : access_mode (Tstruct _ _) = By_reference |- _ => discriminate end).
  (* pin the eval's composite + field offset by computation: delta = 200, bf = Full.
     Both come from the concrete genv_cenv mario_ge, so vm_compute resolves them. The
     field_offset hyp from eval carries `co_members _`, distinguishing it from Hfo. *)
  (* the eval_Efield_struct hyps keep the struct ident `id` abstract behind an
     unreduced `typeof (Ederef ..) = Tstruct id att`; reduce it to pin id = _MarioState *)
  match goal with Ht : typeof (Ederef _ _) = Tstruct _ _ |- _ =>
    cbn [typeof] in Ht; inv Ht end.
  (* Convert the genv composite-env to the light mario_ce, then pin delta = off_bs,
     bf = Full by field_offset DETERMINISM against the wf field_offset Hfo. We never
     vm_compute the genv (OOM) NOR the composite (huge term) -- just congruence on two
     field_offset facts with the same arguments (mario_members = co_members co). *)
  rewrite genv_cenv_mario in *.
  (* use PTree.get explicitly: the `!` notation is shadowed by ClightNotations here,
     so a `_ ! _` match pattern parses to the wrong head and never matches. *)
  match goal with
  | Hco : PTree.get mario._MarioState mario_ce = Some ?co,
    Hfo2 : field_offset mario_ce mario._marioBodyState (co_members ?co) = OK (?delta, ?bf) |- _ =>
      assert (Hmm : mario_members = co_members co)
        by (unfold mario_members; rewrite Hco; reflexivity);
      rewrite <- Hmm in Hfo2;
      (* off_bs was already substituted to its literal 200 by inv Hexec's `subst`
         (it cleared the off_bs = 200 equation), so pin delta against 200 directly. *)
      assert (Hd1 : delta = 200) by congruence;
      assert (Hd2 : bf = Full) by congruence;
      subst delta bf
  end.
  (* the field By_value deref_loc: extract the loadv and match the wf load *)
  match goal with Hdl : deref_loc (tptr _) _ _ _ _ _ |- _ =>
    inv Hdl end;
    try (match goal with Hac : access_mode (tptr _) = By_reference |- _ => discriminate end);
    try (match goal with Hac : access_mode (tptr _) = By_copy |- _ => discriminate end).
  (* deref_loc_value: Mem.loadv Mptr m (Vptr bm (add zero (repr 200))) = Some vfield *)
  match goal with
  | Hac : access_mode (tptr _) = By_value ?chunk,
    Hlv : Mem.loadv ?chunk _ (Vptr _ _) = Some ?v |- _ =>
      simpl in Hac; inversion Hac; subst chunk;
      unfold Mem.loadv in Hlv;
      rewrite Ptrofs.add_zero_l in Hlv;
      rewrite Ptrofs.unsigned_repr in Hlv
        by (split; vm_compute; intro Hx; discriminate Hx);
      rewrite Hld in Hlv; inv Hlv
  end.
  split; [ reflexivity | split; reflexivity ].
Qed.

(* ------------------------------------------------------------------ *)
(* THE DIRECT-STORE inverter (third reusable brick). A store            *)
(*   m->fid = rhs      (fid a scalar field of MarioState, base = param) *)
(* lands its assign_loc in BLOCK bm at the field's OFFSET off (pinned    *)
(* via field_offset determinism). Companion to exec_field_store_block    *)
(* (which keeps only the block, for off-block pointer-chase stores):     *)
(* here the base IS Mario's block, so we need the OFFSET to argue        *)
(* disjointness from the action cell. Mirrors exec_bodystate_load's      *)
(* lvalue inversion; no field deref_loc (the field is the store target,  *)
(* an lvalue, not a read).                                               *)
(* ------------------------------------------------------------------ *)
Lemma exec_marioState_field_store :
  forall e le m fid fty rhs t le' m' out bm off,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    field_offset mario_ce fid mario_members = OK (off, Full) ->
    exec_stmt function_entry2 mario_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) fid fty) rhs) t le' m' out ->
    le' = le /\ out = Out_normal /\
    exists v, assign_loc mario_ce fty m bm (Ptrofs.repr off) Full v m'.
Proof.
  intros e le m fid fty rhs t le' m' out bm off Hm Hfo Hexec.
  inv Hexec.
  match goal with Hlv : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hlv end;
    [ | match goal with Hut : typeof _ = Tunion _ _ |- _ => inv Hut end ].
  match goal with Hee : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv Hee end.
  match goal with Hlv2 : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hlv2 end.
  match goal with He : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ =>
    inv He;
    try (match goal with Hl2 : eval_lvalue _ _ _ _ (Etempvar _ _) _ _ _ |- _ =>
           solve [ inv Hl2 ] end) end.
  match goal with Hlk : ?T ! mario._m = Some (Vptr ?l ?o) |- _ =>
    assert (l = bm) by congruence; assert (o = Ptrofs.zero) by congruence; subst l o end.
  repeat match goal with Hdl : deref_loc ?ty _ _ _ _ _ |- _ => progress cbn [typeof] in Hdl end.
  match goal with Hdl : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hdl end;
    try (match goal with Hac : access_mode (Tstruct _ _) = By_value _ |- _ => discriminate end);
    try (match goal with Hac : access_mode (Tstruct _ _) = By_reference |- _ => discriminate end).
  match goal with Ht : typeof (Ederef _ _) = Tstruct _ _ |- _ =>
    cbn [typeof] in Ht; inv Ht end.
  rewrite genv_cenv_mario in *.
  match goal with
  | Hco : PTree.get mario._MarioState mario_ce = Some ?co,
    Hfo2 : field_offset mario_ce fid (co_members ?co) = OK (?delta, ?bf) |- _ =>
      assert (Hmm : mario_members = co_members co)
        by (unfold mario_members; rewrite Hco; reflexivity);
      rewrite <- Hmm in Hfo2;
      assert (Hd1 : delta = off) by congruence;
      assert (Hd2 : bf = Full) by congruence;
      subst delta bf
  end.
  split; [ reflexivity | split; [ reflexivity | ] ].
  match goal with Hass : assign_loc _ _ _ _ ?o ?bff ?vv _ |- _ =>
    rewrite Ptrofs.add_zero_l in Hass; exists vv; exact Hass end.
Qed.

(* ================================================================== *)
(* FORWARD HELPERS for the assembly: one per statement-kind, packaging  *)
(* {inverter + preservation} so the body proof is a clean SEQUENCE of    *)
(* applications -- no in-place hyp threading (which ambiguates on stale   *)
(* action_sat/valid_block).                                              *)
(* ================================================================== *)

(* one pointer-chase store (through bodyState, an off-bm block) preserves *)
(* action_sat + valid_block and leaves le unchanged. *)
Lemma chase_store_preserves :
  forall e le m fid fty rhs t le2 m2 out2 bm bbs o,
    le ! mario._bodyState = Some (Vptr bbs o) ->
    bbs <> bm ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._bodyState (tptr (Tstruct mario._MarioBodyState noattr)))
                  (Tstruct mario._MarioBodyState noattr)) fid fty) rhs) t le2 m2 out2 ->
    le2 = le /\ out2 = Out_normal /\ Mem.valid_block m2 bm /\ action_sat nonflying m2 bm.
Proof.
  intros e le m fid fty rhs t le2 m2 out2 bm bbs o Hbl Hbbs Hv Hs Hexec.
  destruct (exec_field_store_block _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ Hbl Hexec)
    as (Hle & Hout & (ofs & bf & v & Hass)).
  split; [ exact Hle | split; [ exact Hout | split ] ].
  - eapply assign_loc_valid_block; [ exact Hass | exact Hv ].
  - eapply store_offblock_preserves_action_sat; [ exact Hass | exact Hv | exact Hbbs | exact Hs ].
Qed.

(* the direct m->flags store (offset 4) preserves action_sat (action@12). *)
Lemma flags_store_preserves :
  forall e le m rhs t le2 m2 out2 bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) mario._flags tuint) rhs) t le2 m2 out2 ->
    action_sat nonflying m2 bm.
Proof.
  intros e le m rhs t le2 m2 out2 bm Hm Hv Hs Hexec.
  assert (Hfo4 : field_offset mario_ce mario._flags mario_members = OK (4, Full))
    by (vm_compute; reflexivity).
  destruct (exec_marioState_field_store _ _ _ _ _ _ _ _ _ _ _ _ Hm Hfo4 Hexec)
    as (_ & _ & (v & Hass)).
  eapply assign_loc_action_sat_avoid; [ exact Hass | exact Hv | | exact Hs ].
  intros i Hi Hcell. unfold action_cell in Hcell. destruct Hcell as [_ Hc].
  cbn [size_chunk] in Hc.
  assert (Hsz : sizeof mario_ce tuint = 4) by reflexivity. rewrite Hsz in Hi.
  rewrite !Ptrofs.unsigned_repr in Hi by (split; vm_compute; intro Hx; discriminate Hx).
  lia.
Qed.

(* ================================================================== *)
(* THE WORKED EXAMPLE: the FULL real body of mario_reset_bodystate     *)
(* preserves action_sat nonflying, GIVEN mario_mem_wf. Assembled as a   *)
(* clean sequence of the forward helpers. This is the Option A prototype *)
(* the generic temp-provenance capstone will generalize -- the manual   *)
(* threading here (le!_bodyState off-bm + valid_block + sat, carried     *)
(* across stores) is exactly the invariant the capstone must thread.    *)
(* ================================================================== *)

(* the Ssequence-second (abnormal first statement) case is impossible:   *)
(* our first statements are Sset/Sassign, which yield Out_normal.        *)
Local Ltac seq2_absurd :=
  exfalso;
  match goal with
  | Hs1 : exec_stmt _ _ _ _ _ _ _ _ _ ?o, Hne2 : ?o <> Out_normal |- _ =>
      inv Hs1; congruence
  end.

(* process one pointer-chase store: peel its Ssequence, apply the helper, *)
(* thread valid_block/action_sat forward, collapse the unchanged le.      *)
Local Ltac chase_one bm Hbbs :=
  match goal with
  | H : exec_stmt _ _ _ _ _
          (Ssequence (Sassign (Efield (Ederef (Etempvar mario._bodyState _) _) _ _) _) _) _ _ _ _ |- _ =>
      inv H; [ | seq2_absurd ]
  end;
  match goal with
  | HS : exec_stmt _ _ _ ?lc ?mc
           (Sassign (Efield (Ederef (Etempvar mario._bodyState _) _) _ _) _) _ ?lc2 _ _,
    Hbl : ?lc ! mario._bodyState = Some _,
    Hv : Mem.valid_block ?mc bm,
    Hs : action_sat nonflying ?mc bm |- _ =>
      let Hleq := fresh in let Hout := fresh in
      let Hv2 := fresh "Hv" in let Hs2 := fresh "Hs" in
      edestruct chase_store_preserves as (Hleq & Hout & Hv2 & Hs2);
        [ exact Hbl | exact Hbbs | exact Hv | exact Hs | exact HS
        | subst lc2; clear HS Hv Hs Hout ]
  end.

Lemma mario_reset_bodystate_preserves :
  forall e le m t le' m' out bm bbs,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    mario_mem_wf m bm bbs ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_mario_reset_bodystate) t le' m' out ->
    action_sat nonflying m' bm.
Proof.
  intros e le m t le' m' out bm bbs Hm Hvalid Hwf Hsat Hexec.
  destruct Hwf as [Hbne (off_bs & ofs0 & Hfo & Hwfld)].
  assert (Hbbs : bbs <> bm) by (intro HH; apply Hbne; symmetry; exact HH).
  unfold mario.f_mario_reset_bodystate in Hexec; cbn [fn_body] in Hexec.
  (* ---- LOAD: bodyState = m->marioBodyState ---- *)
  inv Hexec; [ | seq2_absurd ].
  match goal with HL : exec_stmt _ _ _ _ _ (Sset mario._bodyState _) _ _ _ _ |- _ =>
    destruct (exec_bodystate_load _ _ _ _ _ _ _ _ _ _ _ Hm Hfo Hwfld HL) as (Hl1 & Hm1 & _) end.
  subst m.   (* load leaves memory unchanged (m1 = m) *)
  match goal with HR : exec_stmt _ _ _ ?l1 _ _ _ _ _ _ |- _ =>
    assert (HbodyLe : l1 ! mario._bodyState = Some (Vptr bbs ofs0))
      by (rewrite Hl1; apply PTree.gss);
    assert (HmLe : l1 ! mario._m = Some (Vptr bm Ptrofs.zero))
      by (rewrite Hl1; rewrite PTree.gso by (vm_compute; discriminate); exact Hm);
    clear Hl1 end.
  (* ---- the 5 pointer-chase stores through bodyState ---- *)
  do 5 (chase_one bm Hbbs).
  (* ---- t'1 = m->flags  (Sset, memory unchanged) ---- *)
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset mario._t'1 _) _) _ _ _ _ |- _ =>
    inv H; [ | seq2_absurd ] end.
  match goal with HS : exec_stmt _ _ _ _ _ (Sset mario._t'1 _) _ _ _ _ |- _ => inv HS end.
  (* ---- m->flags = t'1 & ~64  (direct store, offset 4) ---- *)
  match goal with
  | HF : exec_stmt _ _ _ ?lf _
           (Sassign (Efield (Ederef (Etempvar mario._m _) _) mario._flags _) _) _ _ _ _,
    Hv : Mem.valid_block ?mf bm, Hs : action_sat nonflying ?mf bm |- _ =>
      assert (HmF : lf ! mario._m = Some (Vptr bm Ptrofs.zero))
        by (rewrite PTree.gso by (vm_compute; discriminate); exact HmLe);
      eapply flags_store_preserves; [ exact HmF | exact Hv | exact Hs | exact HF ]
  end.
Qed.

(* ================================================================== *)
(* SECOND function, the new capability: a body WITH A FUNCTION CALL.    *)
(* hurt_and_set_mario_action: m->hurtCounter = c; set_mario_action(...);  *)
(* return. A direct store + ONE call (to the choke-point set_mario_action)*)
(* + a return. The call is handled by reach_value_preserves -- the callee *)
(* preservation is an explicit hypothesis (discharged later, recursively),*)
(* NOT hidden. Closest-to-leaf real call-bearing function in mario.c.     *)
(* ================================================================== *)

(* generic direct (m->field) store preservation, given the field's byte   *)
(* range is disjoint from the action cell [12,16). Generalizes            *)
(* flags_store_preserves to any scalar field at any disjoint offset.      *)
Lemma direct_store_preserves :
  forall e le m fid fty rhs t le2 m2 out2 bm off,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    action_sat nonflying m bm ->
    field_offset mario_ce fid mario_members = OK (off, Full) ->
    (Ptrofs.unsigned (Ptrofs.repr off) + sizeof mario_ce fty <= 12
     \/ 16 <= Ptrofs.unsigned (Ptrofs.repr off)) ->
    exec_stmt function_entry2 mario_ge e le m
      (Sassign (Efield (Ederef (Etempvar mario._m (tptr (Tstruct mario._MarioState noattr)))
                  (Tstruct mario._MarioState noattr)) fid fty) rhs) t le2 m2 out2 ->
    le2 = le /\ out2 = Out_normal /\ Mem.valid_block m2 bm /\ action_sat nonflying m2 bm.
Proof.
  intros e le m fid fty rhs t le2 m2 out2 bm off Hm Hv Hs Hfo Hdisj Hexec.
  destruct (exec_marioState_field_store _ _ _ _ _ _ _ _ _ _ _ _ Hm Hfo Hexec)
    as (Hle & Hout & (v & Hass)).
  split; [ exact Hle | split; [ exact Hout | split ] ].
  - eapply assign_loc_valid_block; [ exact Hass | exact Hv ].
  - eapply assign_loc_action_sat_avoid; [ exact Hass | exact Hv | | exact Hs ].
    intros i Hi Hcell. unfold action_cell in Hcell. destruct Hcell as [_ Hc].
    cbn [size_chunk] in Hc. destruct Hdisj as [Hd|Hd]; lia.
Qed.

Lemma hurt_and_set_mario_action_preserves :
  forall e le m t le' m' out bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    reach_value_preserves nonflying bm mario_ge ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_hurt_and_set_mario_action) t le' m' out ->
    action_sat nonflying m' bm.
Proof.
  intros e le m t le' m' out bm Hm Hvalid Hreach Hsat Hexec.
  unfold mario.f_hurt_and_set_mario_action in Hexec; cbn [fn_body] in Hexec.
  (* ---- m->hurtCounter = hurtCounter  (direct store, offset 238) ---- *)
  inv Hexec; [ | seq2_absurd ].
  assert (Hfohc : field_offset mario_ce mario._hurtCounter mario_members = OK (238, Full))
    by (vm_compute; reflexivity).
  assert (Hdj : Ptrofs.unsigned (Ptrofs.repr 238) + sizeof mario_ce tuchar <= 12
                \/ 16 <= Ptrofs.unsigned (Ptrofs.repr 238))
    by (right; vm_compute; intro Hx; discriminate Hx).
  match goal with HS : exec_stmt _ _ _ _ _
      (Sassign (Efield (Ederef (Etempvar mario._m _) _) mario._hurtCounter _) _) _ _ _ _ |- _ =>
    destruct (direct_store_preserves _ _ _ _ _ _ _ _ _ _ _ _ Hm Hvalid Hsat Hfohc Hdj HS)
      as (_ & _ & Hv1 & Hs1) end.
  (* ---- t'1 = set_mario_action(m, action, actionArg)  (the CALL) ---- *)
  match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ =>
    inv H; [ | seq2_absurd ] end.
  match goal with HSc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv HSc end.
  match goal with HFun : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
    destruct (Hreach _ _ _ _ _ _ HFun Hv1 Hs1) as (Hv2 & Hs2) end.
  (* ---- return t'1  (memory unchanged) ---- *)
  match goal with HRet : exec_stmt _ _ _ _ _ (Sreturn _) _ _ _ _ |- _ => inv HRet end.
  exact Hs2.
Qed.

(* ================================================================== *)
(* THIRD function, the new capability: CONTROL FLOW (if/else).          *)
(* play_mario_action_sound:                                             *)
(*   t'1 = m->flags;                                                    *)
(*   if (!(t'1 & 0x10000))                                              *)
(*     { play_sound_and_spawn_particles(m,..); m->flags |= 0x10000 }    *)
(*   else { }                                                           *)
(* The if is handled by inverting Sifthenelse and case-splitting on the *)
(* branch taken; each branch preserves action_sat (THEN: a reach'd call *)
(* + a direct flags store; ELSE: Sskip, memory unchanged). Direct store *)
(* + call reuse the existing helpers; the branch split is the new part. *)
(* ================================================================== *)
Lemma play_mario_action_sound_preserves :
  forall e le m t le' m' out bm,
    le ! mario._m = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    reach_value_preserves nonflying bm mario_ge ->
    action_sat nonflying m bm ->
    exec_stmt function_entry2 mario_ge e le m
      (fn_body mario.f_play_mario_action_sound) t le' m' out ->
    action_sat nonflying m' bm.
Proof.
  intros e le m t le' m' out bm Hm Hvalid Hreach Hsat Hexec.
  unfold mario.f_play_mario_action_sound in Hexec; cbn [fn_body] in Hexec.
  (* t'1 = m->flags : memory unchanged *)
  inv Hexec; [ | seq2_absurd ].
  match goal with HS : exec_stmt _ _ _ _ _ (Sset mario._t'1 _) _ _ _ _ |- _ => inv HS end.
  (* the if: invert and case-split on the branch taken *)
  match goal with H : exec_stmt _ _ _ _ _ (Sifthenelse _ _ _) _ _ _ _ |- _ => inv H end.
  match goal with H : exec_stmt _ _ _ _ _ (if ?b then _ else _) _ _ _ _ |- _ => destruct b end.
  - (* THEN: play_sound_and_spawn_particles(...) ; t'2 = m->flags ; m->flags |= 0x10000 *)
    match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Scall _ _ _) _) _ _ _ _ |- _ =>
      inv H; [ | seq2_absurd ] end.
    match goal with HSc : exec_stmt _ _ _ _ _ (Scall _ _ _) _ _ _ _ |- _ => inv HSc end.
    match goal with HFun : eval_funcall _ _ _ _ _ _ _ _ |- _ =>
      destruct (Hreach _ _ _ _ _ _ HFun Hvalid Hsat) as (Hv2 & Hs2) end.
    match goal with H : exec_stmt _ _ _ _ _ (Ssequence (Sset mario._t'2 _) _) _ _ _ _ |- _ =>
      inv H; [ | seq2_absurd ] end.
    match goal with HS2 : exec_stmt _ _ _ _ _ (Sset mario._t'2 _) _ _ _ _ |- _ => inv HS2 end.
    match goal with HF : exec_stmt _ _ _ ?lf _
        (Sassign (Efield (Ederef (Etempvar mario._m _) _) mario._flags _) _) _ _ _ _ |- _ =>
      assert (HmF : lf ! mario._m = Some (Vptr bm Ptrofs.zero))
        by (cbn [set_opttemp];
            rewrite PTree.gso by (vm_compute; discriminate);
            rewrite PTree.gso by (vm_compute; discriminate); exact Hm);
      eapply flags_store_preserves; [ exact HmF | exact Hv2 | exact Hs2 | exact HF ] end.
  - (* ELSE: Sskip, memory unchanged *)
    match goal with H : exec_stmt _ _ _ _ _ Sskip _ _ _ _ |- _ => inv H end.
    exact Hsat.
Qed.
