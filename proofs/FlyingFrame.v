(* FlyingFrame.v -- wiring rung (c) into the flying invariant's step obligation.
 *
 * Plan-B deliverable: connect ActionFrame's interprocedural frame theorem
 * (exec_funcall_reach_unchanged_on, rung c) to FlyingStatement's grounded
 * `flying_mem`, and thereby PIN DOWN exactly what is left of R3 (the
 * Phi_preserved_noA obligation).
 *
 * The bridge, in one breath:
 *   - Instantiate rung (c)'s watched byte-set P at the TWO cells that decide
 *     `flying_mem`: the gMarioState pointer cell (chunk Mptr @ bg:0) and the
 *     action field (Mint32 @ bm:12).
 *   - rung (c) then gives `Mem.unchanged_on P m m'` across a whole frame PROVIDED
 *     no reached function writes those cells (its reach_body_avoids /
 *     reach_ext_preserves hypotheses).
 *   - `unchanged_on P` over those two cells preserves the pointer load and the
 *     action load, hence preserves `flying_mem` exactly (proved here, no admit).
 *
 * So `Phi_preserved_noA` for Phi := (~ flying_mem) REDUCES, via this file, to:
 *     reach_body_avoids (fly_watched bg bm) gw   (no reached fn writes the
 *                                                 pointer cell or action field)
 *   + reach_ext_preserves (fly_watched bg bm) gw
 *   + Mario-state well-formedness (bg/bm valid, the pointer points to bm).
 *
 * THE RESIDUAL, named honestly: `reach_body_avoids (fly_watched bg bm) gw` is
 * FALSE as literally stated, because set_mario_action's body DOES `Sassign` the
 * action field. That is exactly the carve-out the closed-world argument must make:
 * the ONLY reached writer of the action field is set_mario_action (the
 * ActionWriters/Flying corpus: no raw writers, all 6 Mario TUs
 * mario_action_writers = []), and under a no-A frame the value it is called with
 * is non-flying (R1/R2). Everything OTHER than that one call site is discharged by
 * the bridge below. This is the precise remaining gap.
 *
 * No Admitted here: the bridge lemmas are proved; the residual is surfaced as the
 * explicit reach_* hypotheses of frame_preserves_nonflying, not hidden.
 *)

From compcert Require Import Coqlib Maps AST Integers Values Events Memory Globalenvs Ctypes Clight ClightBigstep.
From SM64.Generated Require mario.
From SM64.Proofs Require Import Flying ActionFrame FlyingStatement.

Section FlyingFrame.

Variable prog : program.
Local Notation gw := (globalenv prog).

(* The two byte-ranges that decide flying_mem: the gMarioState pointer cell at
   (bg, 0) and the action field at (bm, 12). Ranges written to match
   load_unchanged_on_1's `ofs <= i < ofs + size_chunk chunk` exactly. *)
Definition fly_watched (bg bm : block) : block -> Z -> Prop :=
  fun b o =>
    (b = bg /\ 0  <= o < 0  + size_chunk Mptr) \/
    (b = bm /\ 12 <= o < 12 + size_chunk Mint32).

(* ---- the heart: unchanged_on those two cells preserves flying_mem exactly. ---- *)
Lemma unchanged_on_preserves_flying :
  forall bg bm m m',
    Genv.find_symbol gw mario._gMarioState = Some bg ->
    Mem.valid_block m bg ->
    Mem.load Mptr m bg 0 = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    Mem.unchanged_on (fly_watched bg bm) m m' ->
    (flying_mem prog m' <-> flying_mem prog m).
Proof.
  intros bg bm m m' Hsym Hvbg Hptr Hvbm Hunch.
  (* the two loads are preserved across m -> m' *)
  assert (HP : Mem.load Mptr m' bg 0 = Mem.load Mptr m bg 0).
  { eapply Mem.load_unchanged_on_1;
      [ exact Hunch | exact Hvbg | intros i Hi; left; split; [ reflexivity | exact Hi ] ]. }
  assert (HA : Mem.load Mint32 m' bm 12 = Mem.load Mint32 m bm 12).
  { eapply Mem.load_unchanged_on_1;
      [ exact Hunch | exact Hvbm | intros i Hi; right; split; [ reflexivity | exact Hi ] ]. }
  assert (Hptr' : Mem.load Mptr m' bg 0 = Some (Vptr bm Ptrofs.zero)) by congruence.
  (* action_holds at m and at m' both collapse to the SAME canonical load at (bm,12),
     because find_symbol pins bg and the pointer load pins bm. *)
  assert (Hcanon : forall (mm : mem) v,
            Mem.load Mptr mm bg 0 = Some (Vptr bm Ptrofs.zero) ->
            (action_holds prog mm v <-> Mem.load Mint32 mm bm 12 = Some (Vint v))).
  { intros mm v Hpmm. unfold action_holds, mario_struct_block. split.
    - intros [bm0 [[bg0 [Hs0 Hp0]] Ha0]].
      assert (bg0 = bg) by congruence. subst bg0.
      rewrite Hpmm in Hp0. inversion Hp0. subst bm0. exact Ha0.
    - intros Ha. exists bm. split; [ exists bg; split; [ exact Hsym | exact Hpmm ] | exact Ha ]. }
  unfold flying_mem. split.
  - intros [v [Ha Hf]]. exists v. split; [ | exact Hf ].
    apply (Hcanon m v Hptr). rewrite <- HA. apply (Hcanon m' v Hptr'). exact Ha.
  - intros [v [Ha Hf]]. exists v. split; [ | exact Hf ].
    apply (Hcanon m' v Hptr'). rewrite HA. apply (Hcanon m v Hptr). exact Ha.
Qed.

(* ---- rung (c), instantiated: a Mario update that avoids the watched cells
       leaves them unchanged across the WHOLE frame. ---- *)
Lemma frame_unchanged_watched :
  forall bg bm i m m',
    reach_body_avoids   (fly_watched bg bm) gw ->
    reach_ext_preserves (fly_watched bg bm) gw ->
    Mem.valid_block m bg ->
    Mem.valid_block m bm ->
    mario_update prog i m m' ->
    Mem.unchanged_on (fly_watched bg bm) m m'.
Proof.
  intros bg bm i m m' Hbody Hext Hvbg Hvbm Hupd.
  destruct Hupd as [_ [b_o [t [res Hfun]]]].
  eapply (proj2 (exec_funcall_reach_unchanged_on (fly_watched bg bm) gw Hbody Hext));
    [ exact Hfun | ].
  intros b o HP. destruct HP as [[Hb _] | [Hb _]]; subst b; assumption.
Qed.

(* ---- bridge 1: such a frame preserves NON-flying (the Phi_preserved_noA core,
       for Phi := ~ flying_mem, given the reach_* + well-formedness hypotheses). ---- *)
Lemma frame_preserves_nonflying :
  forall bg bm i m m',
    (* rung (c) Phase-3 hypotheses, here instantiated at the action/pointer cells: *)
    reach_body_avoids   (fly_watched bg bm) gw ->
    reach_ext_preserves (fly_watched bg bm) gw ->
    (* Mario-state well-formedness (a fuller Phi carries these): *)
    Genv.find_symbol gw mario._gMarioState = Some bg ->
    Mem.valid_block m bg ->
    Mem.load Mptr m bg 0 = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    (* the frame: *)
    mario_update prog i m m' ->
    ~ flying_mem prog m ->
    ~ flying_mem prog m'.
Proof.
  intros bg bm i m m' Hbody Hext Hsym Hvbg Hptr Hvbm Hupd Hnf.
  assert (Hunch : Mem.unchanged_on (fly_watched bg bm) m m')
    by (eapply frame_unchanged_watched; eauto).
  rewrite (unchanged_on_preserves_flying bg bm m m' Hsym Hvbg Hptr Hvbm Hunch).
  exact Hnf.
Qed.

(* ---- bridge 2: the SAME frame preserves Mario-state well-formedness, so the
       (bg, bm, validity, pointer) facts are a genuine INVARIANT, not just a
       per-state assumption. The gMarioState pointer cell is itself in
       fly_watched, so rung (c) freezes it; validity is monotone under
       unchanged_on. Hence the well-formedness premises of bridge 1 reproduce at
       m' -- nothing about R3's residual lives here. ---- *)
Lemma frame_preserves_wf :
  forall bg bm i m m',
    reach_body_avoids   (fly_watched bg bm) gw ->
    reach_ext_preserves (fly_watched bg bm) gw ->
    Genv.find_symbol gw mario._gMarioState = Some bg ->
    Mem.valid_block m bg ->
    Mem.load Mptr m bg 0 = Some (Vptr bm Ptrofs.zero) ->
    Mem.valid_block m bm ->
    mario_update prog i m m' ->
    Genv.find_symbol gw mario._gMarioState = Some bg /\
    Mem.valid_block m' bg /\
    Mem.load Mptr m' bg 0 = Some (Vptr bm Ptrofs.zero) /\
    Mem.valid_block m' bm.
Proof.
  intros bg bm i m m' Hbody Hext Hsym Hvbg Hptr Hvbm Hupd.
  assert (Hunch : Mem.unchanged_on (fly_watched bg bm) m m')
    by (eapply frame_unchanged_watched; eauto).
  assert (HP : Mem.load Mptr m' bg 0 = Mem.load Mptr m bg 0).
  { eapply Mem.load_unchanged_on_1;
      [ exact Hunch | exact Hvbg | intros j Hj; left; split; [ reflexivity | exact Hj ] ]. }
  split; [ exact Hsym | ].
  split; [ eapply Mem.valid_block_unchanged_on; eauto | ].
  split; [ congruence | ].
  eapply Mem.valid_block_unchanged_on; eauto.
Qed.

End FlyingFrame.
