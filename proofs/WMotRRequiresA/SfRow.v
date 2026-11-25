(* ======================================================================= *)
(* SfRow (GOAL 2, 2026-11-15): mario_handle_special_floors, walked.        *)
(*                                                                         *)
(* The real body (generated/interaction.v, interaction.c:1836) returns in  *)
(* the cutscene group, skips a NULL floor, and otherwise switches on       *)
(* m->floor->type:                                                         *)
(*   SURFACE_DEATH_PLANE (10) / VERTICAL_WIND (56): check_death_barrier,   *)
(*   SURFACE_WARP (50): level_trigger_warp(m, WARP_OP_WARP_FLOOR),         *)
(*   SURFACE_TIMER_START / _END (51 / 52): the PSS slide timer,            *)
(* then, off the riding / invulnerable actions, SURFACE_BURNING (1):       *)
(* check_lava_boost.  WMotR's floors have the types 5, 10, 21, 55, 0       *)
(* (WMotRWorld.wmotr_surface_types, the frame world's floor clause), so    *)
(* the one call the body makes is check_death_barrier on the death plane   *)
(* (sf_shape).  check_death_barrier (cdb_keep) calls                       *)
(* level_trigger_warp(m, WARP_OP_WARP_FLOOR) under its height test and     *)
(* may play Mario's falling scream: LtwFrame's footprint (the delayed-warp *)
(* statics, the transition and sound queues, m->invincTimer), AudioInv     *)
(* kept (LtwAudio), warp_w kept (LtwFrame.ltw_warp_w).                     *)
(* Consumer: NaSplit.sf_row.                                               *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Relations.
From compcert Require Import Coqlib Maps AST Integers Floats Values Events Memory
  Globalenvs Ctypes Ctypesdefs Cop Clight ClightBigstep Linking.
From SM64.Generated Require mario interaction level_update audio_external.
From SM64.Proofs Require Import Flying Taint ActionValue ActionValueFrame
  RealFrameValue RealFrameLinked AGates SymbolicLinking.
From SM64.Proofs Require Import CensusV2 EngineV2Consumer RestSurface AirborneSurface.
From SM64.Proofs Require Import NoAImpliesNoFlyLinked.
From SM64.Proofs Require Import HeightInvariant HeightMoveCatalog WMotRLevel WMotRWorld
  NoAActions FrameCalls FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AirSplit AutoSplit ProRows BodyFrame.
From SM64.Proofs.WMotRRequiresA Require LsContract CapAudio AudioInv LtwFrame LtwAudio.
From SM64.Proofs Require Import MarioModel.AudioBodies MarioModel.LinkedTwelve.
Import ListNotations.

Module INT := interaction.

Lemma dm_sf : (prog_defmap INT.prog) ! INT._mario_handle_special_floors
  = Some (Gfun (Internal INT.f_mario_handle_special_floors)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_cdb : (prog_defmap INT.prog) ! INT._check_death_barrier
  = Some (Gfun (Internal INT.f_check_death_barrier)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ltw : (prog_defmap level_update.prog) ! level_update._level_trigger_warp
  = Some (Gfun (Internal level_update.f_level_trigger_warp)).
Proof. vm_compute. reflexivity. Qed.

(* ---------------------------------------------------------------------- *)
(* 1. The body's pieces, read off the generated AST.                      *)
(* ---------------------------------------------------------------------- *)

(* the floor-type switch *)
Definition sf_ls1 : labeled_statements :=
  match fn_body INT.f_mario_handle_special_floors with
  | Ssequence _ (Ssequence _ (Sifthenelse _ (Ssequence _ (Ssequence (Sswitch _ ls) _)) _)) => ls
  | _ => LSnil
  end.

(* what follows it: the lava test *)
Definition sf_part2 : statement :=
  match fn_body INT.f_mario_handle_special_floors with
  | Ssequence _ (Ssequence _ (Sifthenelse _ (Ssequence _ (Ssequence _ p)) _)) => p
  | _ => Sskip
  end.

(* the lava switch *)
Definition sf_ls2 : labeled_statements :=
  match sf_part2 with
  | Ssequence _ (Sifthenelse _ (Sswitch _ ls) _) => ls
  | _ => LSnil
  end.

Lemma sel1_skip : forall t, In (Int.signed t) [5; 21; 55; 0] ->
  seq_of_labeled_statement (select_switch (Int.unsigned t) sf_ls1) = Sskip.
Proof.
  intros t H. rewrite <- (Int.repr_signed t).
  destruct H as [H | [H | [H | [H | []]]]]; rewrite <- H; vm_compute; reflexivity.
Qed.

Lemma sel1_10 : exists rest,
  seq_of_labeled_statement (select_switch (Int.unsigned (Int.repr 10)) sf_ls1)
  = Ssequence Sskip
      (Ssequence
        (Ssequence
          (Scall None (Evar INT._check_death_barrier (Tfunction (tyMSp :: nil) tvoid cc_default))
             (Etempvar INT._m tyMSp :: nil))
          Sbreak)
        rest).
Proof. eexists. reflexivity. Qed.

Lemma sel2_skip : forall t, In (Int.signed t) [5; 10; 21; 55; 0] ->
  seq_of_labeled_statement (select_switch (Int.unsigned t) sf_ls2) = Sskip.
Proof.
  intros t H. rewrite <- (Int.repr_signed t).
  destruct H as [H | [H | [H | [H | [H | []]]]]]; rewrite <- H; vm_compute; reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. Inversions.                                                         *)
(* ---------------------------------------------------------------------- *)

Section Inv.
  Variable ge : genv.
  Notation xs := (exec_stmt function_entry2 ge empty_env).

  Lemma x_switch : forall le m a sl t le' m' out,
    xs le m (Sswitch a sl) t le' m' out ->
    exists v n out0, eval_expr ge empty_env le m a v /\ sem_switch_arg v (typeof a) = Some n
      /\ xs le m (seq_of_labeled_statement (select_switch n sl)) t le' m' out0.
  Proof. intros. inv H. eauto 10. Qed.

  Lemma call_inv : forall le m optid f tyl rty cc al t le' m' out,
    xs le m (Scall optid (Evar f (Tfunction tyl rty cc)) al) t le' m' out ->
    exists b fd vargs vres, Genv.find_symbol ge f = Some b
      /\ Genv.find_funct ge (Vptr b Ptrofs.zero) = Some fd
      /\ eval_exprlist ge empty_env le m al tyl vargs
      /\ eval_funcall function_entry2 ge m fd vargs t m' vres
      /\ le' = set_opttemp optid vres le /\ out = Out_normal.
  Proof.
    intros le m optid f tyl rty cc al t le' m' out H. inv H.
    match goal with Hc : classify_fun _ = fun_case_f _ _ _ |- _ =>
      cbn in Hc; injection Hc as <- <- <- end.
    match goal with He : eval_expr _ _ _ _ (Evar _ _) _ |- _ =>
      destruct (ev_fun _ _ _ _ _ _ _ _ He) as (b & Hsy & ->) end.
    exists b. do 3 eexists. repeat split; eassumption.
  Qed.

  Lemma el1_inv : forall le m a1 t1 vs,
    eval_exprlist ge empty_env le m [a1] [t1] vs ->
    exists v1 v1', eval_expr ge empty_env le m a1 v1 /\ sem_cast v1 (typeof a1) t1 m = Some v1'
      /\ vs = [v1'].
  Proof.
    intros le m a1 t1 vs H. inv H.
    match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end. eauto.
  Qed.

  Lemma el2_inv : forall le m a1 a2 t1 t2 vs,
    eval_exprlist ge empty_env le m [a1; a2] [t1; t2] vs ->
    exists v1 v1' v2 v2', eval_expr ge empty_env le m a1 v1 /\ sem_cast v1 (typeof a1) t1 m = Some v1'
      /\ eval_expr ge empty_env le m a2 v2 /\ sem_cast v2 (typeof a2) t2 m = Some v2'
      /\ vs = [v1'; v2'].
  Proof.
    intros le m a1 a2 t1 t2 vs H. inv H.
    match goal with H : eval_exprlist _ _ _ _ (_ :: nil) _ _ |- _ =>
      apply el1_inv in H as (w2 & w2' & E2 & C2 & ->) end.
    eauto 10.
  Qed.

  (* a switch case `f(...); break;` after an empty case *)
  Lemma call_break_inv : forall le m o a al rest t le' m' out,
    xs le m (Ssequence Sskip (Ssequence (Ssequence (Scall o a al) Sbreak) rest)) t le' m' out ->
    exists t1, xs le m (Scall o a al) t1 le' m' Out_normal.
  Proof.
    intros le m o a al rest t le' m' out H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & Hn)];
      [| apply x_skip in H1 as (_ & _ & E); contradiction (Hn E)].
    apply x_skip in H1 as (-> & -> & _).
    apply seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (t3 & H3 & Hn)].
    - exfalso.
      apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & Hc & Hb) | (t5 & Hc & Hn)];
        [inv Hb | inv Hc; congruence].
    - apply seq_inv in H3 as [(t5 & le5 & m5 & t6 & Hc & Hb) | (t5 & Hc & Hn')];
        [inv Hb; eauto | inv Hc; congruence].
  Qed.
End Inv.

(* ---------------------------------------------------------------------- *)
(* 3. warp_w reads six cells.                                             *)
(* ---------------------------------------------------------------------- *)

Definition wr_ids : list ident :=
  [level_update._sCurrPlayMode; level_update._sWarpDest; level_update._gCurrDemoInput;
   level_update._gCurrCreditsEntry; level_update._sDelayedWarpOp; level_update._sSourceWarpNodeId].

Lemma warp_w_keep : forall (G : genv) m m',
  (forall id b ch, In id wr_ids -> Genv.find_symbol G id = Some b ->
     Mem.load ch m' b 0 = Mem.load ch m b 0) ->
  warp_w G m -> warp_w G m'.
Proof.
  intros G m m' K0 (W1 & W2 & W3 & W4 & W5).
  assert (K : forall id b ch, Genv.find_symbol G id = Some b -> In id wr_ids ->
            Mem.load ch m' b 0 = Mem.load ch m b 0) by (intros; eauto).
  split; [| split; [| split; [| split]]].
  - intros bp bw Hp Hw.
    rewrite (K _ _ _ Hp), (K _ _ _ Hw) by (unfold wr_ids; cbn [In]; auto 10).
    exact (W1 bp bw Hp Hw).
  - intros b Hs. rewrite (K _ _ _ Hs) by (unfold wr_ids; cbn [In]; auto 10). exact (W2 b Hs).
  - intros b Hs. rewrite (K _ _ _ Hs) by (unfold wr_ids; cbn [In]; auto 10). exact (W3 b Hs).
  - intros bo bs Ho Hs.
    rewrite (K _ _ _ Ho), (K _ _ _ Hs) by (unfold wr_ids; cbn [In]; auto 10).
    exact (W4 bo bs Ho Hs).
  - intros bo Ho. rewrite (K _ _ _ Ho) by (unfold wr_ids; cbn [In]; auto 10). exact (W5 bo Ho).
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. check_death_barrier and the body.                                   *)
(* ---------------------------------------------------------------------- *)

Section SF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Notation ge := (lp_ge lp).
  Notation xs := (exec_stmt function_entry2 ge empty_env).
  Hypothesis Hbm : Genv.find_symbol ge level_update._gMarioStates = Some bm.

  (* what a death-barrier call leaves *)
  Definition sf_post (m m' : mem) : Prop :=
    Q2 (LtwFrame.aki lp LtwFrame.ltw_ws bm) m m' /\ AudioInv.AudioInv ge m' /\ warp_w ge m'.

  Lemma sf_post_trans : forall m0 m1 m2, sf_post m0 m1 -> sf_post m1 m2 -> sf_post m0 m2.
  Proof.
    intros m0 m1 m2 (Q & _ & _) (Q' & A & W).
    exact (conj (Q2_trans _ _ _ _ Q Q') (conj A W)).
  Qed.

  Lemma NLm : ~ LsContract.gblk ge LsContract.ls_ids bm.
  Proof.
    intros (g & Hin & Hg).
    assert (g = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [exact Hg | exact Hbm]).
    subst g.
    assert (T : existsb (Pos.eqb level_update._gMarioStates) LsContract.ls_ids = true)
      by (apply existsb_exists; eexists; split; [exact Hin | apply Pos.eqb_refl]).
    vm_compute in T. discriminate T.
  Qed.

  Lemma lu_sym : forall id, (prog_defmap level_update.prog) ! id <> None ->
    exists b, Genv.find_symbol ge id = Some b.
  Proof.
    intros id H. destruct ((prog_defmap level_update.prog) ! id) as [gd |] eqn:E; [| congruence].
    exact (linkorder_resolves_symbol lp level_update.prog id gd (linked12_LO_lvl lp H12) E).
  Qed.

  (* level_trigger_warp(m, WARP_OP_WARP_FLOOR) *)
  Lemma ltw_step : forall le m optid tyl rty cc t le' m' out,
    le ! INT._m = Some (Vptr bm Ptrofs.zero) ->
    xs le m (Scall optid (Evar INT._level_trigger_warp (Tfunction (tyMSp :: tint :: nil) rty cc))
               (Etempvar INT._m tyMSp :: Econst_int (Int.repr 19) tint :: tyl)) t le' m' out ->
    tyl = nil ->
    AudioInv.AudioInv ge m -> warp_w ge m -> sf_post m m'.
  Proof.
    intros le m optid tyl rty cc t le' m' out Hle Hx -> AI WW.
    apply call_inv in Hx as (b & fd & vargs & vres & Hsy & Hff & Hargs & Hcall & _ & _).
    apply el2_inv in Hargs as (v1 & v1' & v2 & v2' & E1 & C1 & E2 & C2 & ->).
    apply eval_expr_Etempvar_val in E1. rewrite Hle in E1. injection E1 as <-.
    cbn [typeof] in C1. apply cast_pp in C1. subst v1'.
    apply eval_expr_Econst_int_val in E2. subst v2.
    cbn in C2. injection C2 as <-.
    pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_lvl lp H12) dm_ltw
                  (ex_intro _ b (conj Hsy Hff))) as Efd.
    rewrite Efd in Hcall.
    destruct (lu_sym level_update._sDelayedWarpOp ltac:(intros E; vm_compute in E; discriminate E))
      as (bo & Hbo).
    destruct (lu_sym level_update._sSourceWarpNodeId ltac:(intros E; vm_compute in E; discriminate E))
      as (bs & Hbs).
    split; [| split].
    - exact (LtwFrame.ltw_frame lp H12 bm m _ t m' vres Hcall).
    - exact (LtwAudio.ltw_ai lp H12 bm NLm m _ t m' vres Hcall AI).
    - exact (LtwFrame.ltw_warp_w lp H12 bm bo bs Hbm Hbo Hbs m (Int.repr 19) t m' vres
               (or_intror eq_refl) Hcall WW).
  Qed.

  (* play_sound *)
  Lemma ps_step : forall le m optid tyl rty cc al t le' m' out,
    xs le m (Scall optid (Evar audio_external._play_sound (Tfunction tyl rty cc)) al) t le' m' out ->
    AudioInv.AudioInv ge m -> warp_w ge m -> sf_post m m'.
  Proof.
    intros le m optid tyl rty cc al t le' m' out Hx AI WW.
    apply call_inv in Hx as (b & fd & vargs & vres & Hsy & Hff & _ & Hcall & _ & _).
    rewrite Genv.find_funct_find_funct_ptr in Hff.
    split; [| split].
    - refine (Q2_mono _ _ m m' (LtwFrame.aki_ak lp LtwFrame.ltw_ws bm) _).
      exact (LtwFrame.callees_af lp H12 LtwFrame.ltw_ws (LtwFrame.cids_ws) audio_external._play_sound
               ltac:(vm_compute; reflexivity) b fd Hsy Hff m vargs t m' vres Hcall).
    - exact (proj2 (LtwAudio.ps_ai lp H12 b fd m vargs t m' vres Hsy Hff Hcall AI)).
    - pose proof (LtwFrame.lf_ps lp H12 b fd Hsy Hff m vargs t m' vres Hcall) as HQ.
      refine (warp_w_keep ge m m' _ WW).
      intros id b0 ch Hin Hs. apply (Q2_load _ _ _ HQ). intros i _ (g & Ig & Hg).
      assert (g = id) by (eapply Genv.genv_vars_inj; [exact Hg | exact Hs]). subst g.
      assert (T : existsb (Pos.eqb id) LtwFrame.ltw_cids = true)
        by (apply existsb_exists; eexists; split; [exact Ig | apply Pos.eqb_refl]).
      unfold wr_ids in Hin. cbn [In] in Hin.
      decompose [or] Hin; try contradiction; subst id; vm_compute in T; discriminate T.
  Qed.

  Lemma cdb_keep : forall m t m' vr,
    eval_funcall function_entry2 ge m (Internal INT.f_check_death_barrier)
      [Vptr bm Ptrofs.zero] t m' vr ->
    AudioInv.AudioInv ge m -> warp_w ge m -> sf_post m m'.
  Proof.
    intros m t m' vr Hev AI WW.
    assert (R0 : sf_post m m) by exact (conj (Q2_refl _ m) (conj AI WW)).
    destruct (fc_entry ge m INT.f_check_death_barrier _ t m' vr eq_refl Hev)
      as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! INT._m = Some (Vptr bm Ptrofs.zero)).
    { change (fn_params INT.f_check_death_barrier) with [(INT._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    unfold INT.f_check_death_barrier in H. cbn [fn_body] in H.
    apply (seq_set_inv lp) in H as (v3 & _ & H).
    apply (seq_set_inv lp) in H as (v4 & _ & H).
    apply x_if in H as (vc & bc & _ & _ & H).
    destruct bc; [| apply x_skip in H as (_ & -> & _); exact R0].
    assert (Hle1 : (PTree.set INT._t'4 v4 (PTree.set INT._t'3 v3 le0)) ! INT._m
                   = Some (Vptr bm Ptrofs.zero)) by (le_simp; exact Hle).
    apply seq_inv in H as [(t1 & le2 & m1 & t2 & H1 & H2) | (t1 & H1 & _)].
    - apply seq_inv in H1 as [(t3 & le3 & m3 & t4 & Hc & Hi) | (t3 & Hc & _)].
      + pose proof (pure_mem _ _ _ _ _ _ _ _ _ Hi eq_refl) as E. subst m1.
        pose proof (ltw_step _ _ _ _ _ _ _ _ _ _ Hle1 Hc eq_refl AI WW) as P.
        apply x_if in H2 as (v2 & b2 & _ & _ & H2).
        destruct b2; [| apply x_skip in H2 as (_ & -> & _); exact P].
        apply (seq_set_inv lp) in H2 as (v5 & _ & H2).
        destruct P as (Q & A & W).
        exact (sf_post_trans m m3 m' (conj Q (conj A W)) (ps_step _ _ _ _ _ _ _ _ _ _ _ H2 A W)).
      + pose proof (ltw_step _ _ _ _ _ _ _ _ _ _ Hle1 Hc eq_refl AI WW) as P.
        apply x_if in H2 as (v2 & b2 & _ & _ & H2).
        destruct b2; [| apply x_skip in H2 as (_ & -> & _); exact P].
        apply (seq_set_inv lp) in H2 as (v5 & _ & H2).
        destruct P as (Q & A & W).
        exact (sf_post_trans m m1 m' (conj Q (conj A W)) (ps_step _ _ _ _ _ _ _ _ _ _ _ H2 A W)).
    - apply seq_inv in H1 as [(t3 & le3 & m3 & t4 & Hc & Hi) | (t3 & Hc & _)].
      + pose proof (pure_mem _ _ _ _ _ _ _ _ _ Hi eq_refl) as E. subst m'.
        exact (ltw_step _ _ _ _ _ _ _ _ _ _ Hle1 Hc eq_refl AI WW).
      + exact (ltw_step _ _ _ _ _ _ _ _ _ _ Hle1 Hc eq_refl AI WW).
  Qed.

  (* the floor-type switch: a WMotR floor calls check_death_barrier or
     nothing *)
  Lemma sw1 : forall le m ty t le' m' out,
    le ! INT._m = Some (Vptr bm Ptrofs.zero) ->
    le ! INT._floorType = Some (Vint ty) ->
    In (Int.signed ty) wmotr_surface_types ->
    xs le m (Sswitch (Etempvar INT._floorType tint) sf_ls1) t le' m' out ->
    (m' = m \/ exists t1 vr1,
       eval_funcall function_entry2 ge m (Internal INT.f_check_death_barrier)
         [Vptr bm Ptrofs.zero] t1 m' vr1)
    /\ le' = le.
  Proof.
    intros le m ty t le' m' out Hm Hft Hin H.
    apply x_switch in H as (vs & n & out0 & Es & Sn & H).
    apply eval_expr_Etempvar_val in Es. rewrite Hft in Es. injection Es as <-.
    cbn in Sn. injection Sn as <-.
    rewrite wmotr_surface_types_value in Hin.
    destruct (Int.eq_dec ty (Int.repr 10)) as [-> | Hne].
    - destruct sel1_10 as (rest & E). rewrite E in H.
      apply call_break_inv in H as (t1 & Hc).
      apply call_inv in Hc as (b & fd & vargs & vres & Hsy & Hff & Hargs & Hcall & -> & _).
      apply el1_inv in Hargs as (v1 & v1' & E1 & C1 & ->).
      apply eval_expr_Etempvar_val in E1. rewrite Hm in E1. injection E1 as <-.
      cbn [typeof] in C1. apply cast_pp in C1. subst v1'.
      pose proof (resolve_pin_fd lp _ _ _ _ (linked12_LO_int lp H12) dm_cdb
                    (ex_intro _ b (conj Hsy Hff))) as Efd.
      rewrite Efd in Hcall.
      split; [right; eauto | reflexivity].
    - rewrite sel1_skip in H.
      + apply x_skip in H as (-> & -> & _). split; [left; reflexivity | reflexivity].
      + destruct Hin as [E | [E | Hin]]; [left; exact E | | right; exact Hin].
        exfalso. apply Hne. rewrite <- (Int.repr_signed ty), <- E. reflexivity.
  Qed.

  (* the lava test: no WMotR floor burns *)
  Lemma part2_mem : forall le m ty t le' m' out,
    le ! INT._floorType = Some (Vint ty) ->
    In (Int.signed ty) wmotr_surface_types ->
    xs le m sf_part2 t le' m' out -> m' = m.
  Proof.
    intros le m ty t le' m' out Hft Hin H.
    cbv [sf_part2 INT.f_mario_handle_special_floors fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & _)];
      [| exact (pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl)].
    pose proof (pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl) as E. subst m1.
    assert (Hft1 : le1 ! INT._floorType = Some (Vint ty)).
    { apply (seq_set_inv lp) in H1 as (v3 & _ & H1).
      apply x_if in H1 as (vc & b & _ & _ & H1). destruct b.
      - apply (seq_set_inv lp) in H1 as (v4 & _ & H1).
        apply x_set in H1 as (v1 & _ & -> & _ & _). le_simp. exact Hft.
      - apply x_set in H1 as (v1 & _ & -> & _ & _). le_simp. exact Hft. }
    apply x_if in H2 as (vc & b & _ & _ & H2).
    destruct b; [| apply x_skip in H2 as (_ & -> & _); reflexivity].
    apply x_switch in H2 as (vs & n & out0 & Es & Sn & H2).
    apply eval_expr_Etempvar_val in Es. rewrite Hft1 in Es. injection Es as <-.
    cbn in Sn. injection Sn as <-.
    match type of H2 with
    | exec_stmt _ _ _ _ _ (seq_of_labeled_statement (select_switch _ ?l)) _ _ _ _ =>
        change l with sf_ls2 in H2
    end.
    rewrite wmotr_surface_types_value in Hin.
    rewrite (sel2_skip ty Hin) in H2.
    apply x_skip in H2 as (_ & -> & _). reflexivity.
  Qed.

  (* THE SHAPE: on a WMotR floor the body leaves the memory alone or runs
     one check_death_barrier(m) *)
  Theorem sf_shape : forall v m t m' vr, marg_ok bm [v] -> wmotr_world bm m ->
    eval_funcall function_entry2 ge m (Internal INT.f_mario_handle_special_floors) [v] t m' vr ->
    m' = m \/ exists t1 vr1,
      eval_funcall function_entry2 ge m (Internal INT.f_check_death_barrier)
        [Vptr bm Ptrofs.zero] t1 m' vr1.
  Proof.
    intros v m t m' vr Hmarg HW Hev.
    destruct (fc_entry ge m INT.f_mario_handle_special_floors [v] t m' vr eq_refl Hev)
      as (le0 & le' & t' & out & Hbind & H).
    assert (Hle : le0 ! INT._m = Some v).
    { change (fn_params INT.f_mario_handle_special_floors) with [(INT._m, tyMSp)] in Hbind.
      cbn [bind_parameter_temps] in Hbind. injection Hbind as <-. apply PTree.gss. }
    unfold INT.f_mario_handle_special_floors in H. cbn [fn_body] in H.
    apply seq_inv in H as [(t1 & le1 & m1 & t2 & H1 & H2) | (t1 & H1 & _)];
      [| left; exact (pure_mem _ _ _ _ _ _ _ _ _ H1 eq_refl)].
    (* the cutscene-group test fell through *)
    apply (seq_set_inv lp) in H1 as (va & Ea & H1).
    destruct (ev_fld lp H12 bm INT._m le0 m v INT._action tuint Mint32 12 va Hle Hmarg
                action_fo ltac:(lia) eq_refl Ea) as (-> & _).
    apply x_if in H1 as (vc & bc & _ & _ & H1).
    destruct bc; [inv H1 |].
    apply x_skip in H1 as (-> & -> & _).
    assert (Hle1 : (PTree.set INT._t'6 va le0) ! INT._m = Some (Vptr bm Ptrofs.zero))
      by (le_simp; exact Hle).
    (* m->floor: a WMotR surface *)
    apply (seq_set_inv lp) in H2 as (vf & Ef & H2).
    destruct (ev_fld lp H12 bm INT._m _ m _ INT._floor (tptr (Tstruct INT._Surface noattr)) Mint32 104 vf
                Hle1 Hmarg fo_floor ltac:(lia) eq_refl Ef) as (_ & Lf).
    destruct HW as (_ & _ & HF & _).
    apply x_if in H2 as (vc2 & bc2 & Ec2 & Bc2 & H2).
    destruct (HF vf Lf) as [Hnul | (sb & so & ty & -> & Lt & Hin)].
    { (* a NULL floor (update_mario_inputs' double miss): the real test
         `m->floor != NULL` is false and the body does nothing *)
      assert (VN : Vnullptr = Vint Int.zero) by (unfold Vnullptr; cbv [Archi.ptr64]; reflexivity).
      rewrite VN in Hnul. subst vf.
      apply eval_expr_Ebinop_inv in Ec2 as (xa & xb & QEa & QEb & QSb).
      apply eval_expr_Etempvar_val in QEa. rewrite PTree.gss in QEa. injection QEa as <-.
      inv QEb; [| match goal with Hl : eval_lvalue _ _ _ _ (Ecast _ _) _ _ _ |- _ => inv Hl end].
      match goal with He : eval_expr _ _ _ _ (Econst_int _ _) _ |- _ =>
        apply eval_expr_Econst_int_val in He; subst end.
      match goal with Hc : sem_cast _ _ _ _ = Some _ |- _ =>
        cbv [sem_cast classify_cast Archi.ptr64] in Hc; cbn in Hc; injection Hc as <- end.
      cbn [typeof] in QSb, Bc2.
      cbv [sem_binary_operation sem_cmp classify_cmp cmp_ptr Archi.ptr64] in QSb. cbn in QSb.
      injection QSb as <-. cbn in Bc2. injection Bc2 as <-.
      apply x_skip in H2 as (_ & -> & _). left; reflexivity. }
    destruct bc2; [| apply x_skip in H2 as (_ & -> & _); left; reflexivity].
    apply seq_inv in H2 as [(t3 & le3 & m3 & t4 & H3 & H4) | (t3 & H3 & Hn)].
    2: { apply (seq_set_inv lp) in H3 as (v5 & _ & H3).
         apply x_set in H3 as (vt & _ & _ & _ & Eo). contradiction (Hn Eo). }
    apply (seq_set_inv lp) in H3 as (v5 & E5 & H3).
    apply x_set in H3 as (vt & Et & -> & -> & _).
    assert (Hle2 : (PTree.set INT._t'2 (Vptr sb so) (PTree.set INT._t'6 va le0)) ! INT._m
                   = Some (Vptr bm Ptrofs.zero)) by (le_simp; exact Hle).
    destruct (ev_fld lp H12 bm INT._m _ m _ INT._floor (tptr (Tstruct INT._Surface noattr)) Mint32 104 v5
                Hle2 Hmarg fo_floor ltac:(lia) eq_refl E5) as (_ & L5).
    assert (v5 = Vptr sb so) by congruence. subst v5.
    pose proof (ev_stype lp H12 INT._t'5 _ m sb so vt (PTree.gss _ _ _) Et) as Lt'.
    assert (vt = Vint ty) by congruence. subst vt.
    match type of H4 with exec_stmt _ _ _ ?lef _ _ _ _ _ _ =>
      assert (Hm : lef ! INT._m = Some (Vptr bm Ptrofs.zero)) by (le_simp; exact Hle);
      assert (Hft : lef ! INT._floorType = Some (Vint ty)) by apply PTree.gss
    end.
    apply seq_inv in H4 as [(t5 & le5 & m5 & t6 & H5 & H6) | (t5 & H5 & _)].
    - destruct (sw1 _ _ ty _ _ _ _ Hm Hft Hin H5) as (Hres & ->).
      rewrite (part2_mem _ _ ty _ _ _ _ Hft Hin H6). exact Hres.
    - exact (proj1 (sw1 _ _ ty _ _ _ _ Hm Hft Hin H5)).
  Qed.
End SF.
