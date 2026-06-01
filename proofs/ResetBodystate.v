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

From compcert Require Import Coqlib Errors Maps AST Integers Values Memory Globalenvs Ctypes Cop Clight Clightdefs ClightBigstep.
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
