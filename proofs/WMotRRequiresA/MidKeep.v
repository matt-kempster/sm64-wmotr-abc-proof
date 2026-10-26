(* ====================================================================== *)
(* MidKeep (GOAL 2): what the game runs BETWEEN the controller poll's two *)
(* calls, PROVED from the real code (2026-10-26).                         *)
(*                                                                        *)
(* thread5_game_loop (game_init.c:686-691):                               *)
(*     if (gControllerBits) osContStartReadData(&gSIEventMesgQueue);      *)
(*     audio_game_loop_tick();                                            *)
(*     select_gfx_pool();                                                 *)
(*     read_controller_inputs();                                          *)
(* Both middle calls are linked code (sound_init.c / audio/external.c /   *)
(* game_init.c / memory.c):                                               *)
(*   audio_game_loop_tick -> audio_signal_game_loop_tick (US):            *)
(*       sGameLoopTicked = 1; noop_8031EEC8();                            *)
(*   select_gfx_pool:                                                     *)
(*       gGfxPool = &gGfxPools[gGlobalTimer % 2];                         *)
(*       set_segment_base_addr(1, gGfxPool->buffer);  (sSegmentTable[1])  *)
(*       gGfxSPTask = ...; gDisplayListHead = ...; gGfxPoolEnd = ...;     *)
(* For each, FootWalk walks the generated body: memory changes only in    *)
(* the blocks of its listed globals; PermWalk: every permission kept.     *)
(* GOAL 1's facts by UcKit's class walker (pool pointers into the SafeB  *)
(* pool-pointer globals, CensusV2.gfx_safe_syms; integers elsewhere), PhiW *)
(* (LevelKeep.lvl_keeps_core; lvl_w untouched), the platform fact and the *)
(* object world from the footprint.  No premise.                          *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require memory game_init sound_init audio_external level_update mario.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor CensusV2.
From SM64.Proofs Require MtxfBody SaveDoSaveBody.
From SM64.Proofs Require Import Generic.PermWalk.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Import ActionValueFrame MWFReal SpawnInit MathBodies AGates UcKit.
From SM64.Proofs Require NoAImpliesNoFlyTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor WMotRWorld FfWorld RenderKeep LevelWalk.
From SM64.Proofs.WMotRRequiresA Require PollFlank ObjWorld FootWalk LevelKeep PlatformKeep PollKeep.
Import ListNotations.
Local Open Scope Z_scope.

Module SDB := SaveDoSaveBody.
Module GI := game_init.
Module SI := sound_init.
Module AX := audio_external.
Module OW := ObjWorld.

(* the two calls, as the generated bodies run them *)
Definition agt_call (lp : Clight.program) (m m' : mem) : Prop :=
  exists t vres, eval_funcall function_entry2 (lp_ge lp) m (Internal SI.f_audio_game_loop_tick) [] t m' vres.
Definition sgp_call (lp : Clight.program) (m m' : mem) : Prop :=
  exists t vres, eval_funcall function_entry2 (lp_ge lp) m (Internal GI.f_select_gfx_pool) [] t m' vres.
(* the stretch between osContStartReadData and read_controller_inputs *)
Definition mid_call (lp : Clight.program) (m i : mem) : Prop :=
  exists i1, agt_call lp m i1 /\ sgp_call lp i1 i.

(* their written globals *)
Definition agt_gvars : list ident := [AX._sGameLoopTicked].
Definition sgp_gvars : list ident :=
  [GI._gGfxPool; GI._gGfxSPTask; GI._gDisplayListHead; GI._gGfxPoolEnd; memory._sSegmentTable].

(* ---------------------------------------------------------------------- *)
(* 0. GOAL 1's facts: UcKit's class walk (dirty mode).                    *)
(* ---------------------------------------------------------------------- *)
Definition mk_sig : usig := ([], kN, true).
Definition mk_ut : utab :=
  [(SI._audio_game_loop_tick, mk_sig); (AX._audio_signal_game_loop_tick, mk_sig);
   (AX._noop_8031EEC8, mk_sig); (GI._select_gfx_pool, mk_sig);
   (memory._set_segment_base_addr, ([kN; kA], kA, true))].

Lemma uc_agt : uchk gfx_safe_syms mk_ut [] mk_sig SI.f_audio_game_loop_tick = true.
Proof. vm_compute. reflexivity. Qed.
Lemma uc_asg : uchk gfx_safe_syms mk_ut [] mk_sig AX.f_audio_signal_game_loop_tick = true.
Proof. vm_compute. reflexivity. Qed.
Lemma uc_noop : uchk gfx_safe_syms mk_ut [] mk_sig AX.f_noop_8031EEC8 = true.
Proof. vm_compute. reflexivity. Qed.
Lemma uc_sgp : uchk gfx_safe_syms mk_ut [] mk_sig GI.f_select_gfx_pool = true.
Proof. vm_compute. reflexivity. Qed.
Lemma uc_ssb : uchk gfx_safe_syms mk_ut [] ([kN; kA], kA, true) memory.f_set_segment_base_addr = true.
Proof. vm_compute. reflexivity. Qed.

Section UCW.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* the pool pointers are SafeB symbols (CensusV2.gfx_safe_syms) *)
  Lemma mk_gs : forall x b, mem_id x gfx_safe_syms = true -> Genv.find_symbol G x = Some b -> SafeB b.
  Proof.
    intros x b H Hs. destruct HSafeB_syms as (_ & _ & Hc). apply (Hc x b); [ | exact Hs ].
    unfold gfx_safe_syms in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [E | H];
            [ apply Pos.eqb_eq in E; subst x; vm_compute; reflexivity | ]).
    discriminate H.
  Qed.

  Lemma res_int : forall q fid f b fd, linkorder q lp ->
    (prog_defmap q) ! fid = Some (Gfun (Internal f)) ->
    Genv.find_symbol G fid = Some b -> Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
    fd = Internal f.
  Proof.
    intros q fid f b fd LO Hd Hs Hf.
    destruct (linkorder_resolves_funct lp q fid f LO Hd) as (b' & Hs' & Hf').
    unfold lp_ge in *. rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'. injection Hf' as ->. reflexivity.
  Qed.

  Lemma mk_tab : TabGood lp gfx_safe_syms mk_ut [] (fun _ _ => False).
  Proof.
    intros fid s Hf b fd Hs Hff. left.
    unfold mk_ut, ut_find in Hf. cbn [find fst] in Hf.
    repeat match type of Hf with
    | context [Pos.eqb ?g fid] =>
        let E := fresh "E" in
        destruct (Pos.eqb g fid) eqn:E; cbv beta iota in Hf;
        [ apply Pos.eqb_eq in E; subst fid; injection Hf as <- | ]
    end; [ | | | | | discriminate Hf ].
    - exists SI.f_audio_game_loop_tick. split; [ | exact uc_agt ].
      apply (res_int sound_init.prog SI._audio_game_loop_tick SI.f_audio_game_loop_tick b fd (linked12_LO_sound_init lp H12)); [ vm_compute; reflexivity | exact Hs | exact Hff ].
    - exists AX.f_audio_signal_game_loop_tick. split; [ | exact uc_asg ].
      apply (res_int AX.prog AX._audio_signal_game_loop_tick AX.f_audio_signal_game_loop_tick b fd (linked12_LO_audio_external lp H12)); [ vm_compute; reflexivity | exact Hs | exact Hff ].
    - exists AX.f_noop_8031EEC8. split; [ | exact uc_noop ].
      apply (res_int AX.prog AX._noop_8031EEC8 AX.f_noop_8031EEC8 b fd (linked12_LO_audio_external lp H12)); [ vm_compute; reflexivity | exact Hs | exact Hff ].
    - exists GI.f_select_gfx_pool. split; [ | exact uc_sgp ].
      apply (res_int GI.prog GI._select_gfx_pool GI.f_select_gfx_pool b fd (PollFlank.LO_gi lp H12)); [ vm_compute; reflexivity | exact Hs | exact Hff ].
    - exists memory.f_set_segment_base_addr. split; [ | exact uc_ssb ].
      apply (res_int memory.prog memory._set_segment_base_addr memory.f_set_segment_base_addr b fd (linked12_LO_memory lp H12)); [ vm_compute; reflexivity | exact Hs | exact Hff ].
  Qed.

  Lemma mk_it : ItGood lp gfx_safe_syms mk_ut [] (fun _ _ => False).
  Proof. intros ty s Hf. discriminate Hf. Qed.

  (* a walked no-argument body keeps GOAL 1's facts *)
  Lemma of_uc : forall f m t m' vres,
    uchk gfx_safe_syms mk_ut [] mk_sig f = true ->
    eval_funcall function_entry2 G m (Internal f) [] t m' vres ->
    ow_facts bm MWF m -> ow_facts bm MWF m'.
  Proof.
    intros f m t m' vres Hc Hev Hof.
    pose proof (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as Hsp.
    set (nl := Mem.nextblock m).
    assert (HNL : HnB lp bm SafeB nl).
    { destruct Hof as (Hv & _ & HM). split; [ exact Hv | split ].
      - intros b Hs. exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs).
      - intros gid bg Hg.
        exact (glob_valid_of_nextbound lp m (mwf_real_nextbound lp bm bc oc0 SafeB m HM) gid bg Hg). }
    pose proof (good_spec lp bm bc oc0 SafeB HSafeB_syms Hsp nl HNL gfx_safe_syms mk_gs mk_ut [] (fun _ _ => False)
                  (fun _ _ (H : False) => match H with end) mk_tab mk_it (Internal f) mk_sig (or_introl (ex_intro _ f (conj eq_refl Hc)))) as Hsp'.
    assert (Hi : UInv lp bm bc oc0 SafeB nl true nl m).
    { split; [ exact Hof | split; [ apply Ple_refl | intros E; discriminate E ] ]. }
    destruct (Hsp' nl (Ple_refl _) m [] t m' vres Hev (Forall2_nil _) Hi) as ((Hof' & _) & _).
    exact Hof'.
  Qed.
End UCW.

(* ---------------------------------------------------------------------- *)
(* 1. Permissions.                                                         *)
(* ---------------------------------------------------------------------- *)
Section PERM.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  Lemma PS_noop : PS G (Internal AX.f_noop_8031EEC8).
  Proof. apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity. Qed.

  Lemma ps_noop : PollKeep.ps_id lp AX._noop_8031EEC8.
  Proof.
    apply (PollKeep.ps_int lp AX.prog AX._noop_8031EEC8 AX.f_noop_8031EEC8 (linked12_LO_audio_external lp H12));
      [ vm_compute; reflexivity | exact PS_noop ].
  Qed.

  Lemma PS_asg : PS G (Internal AX.f_audio_signal_game_loop_tick).
  Proof.
    apply (pk_body G [AX._noop_8031EEC8] (PollKeep.psym_cons lp _ _ ps_noop (PollKeep.psym_nil lp))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_asg : PollKeep.ps_id lp AX._audio_signal_game_loop_tick.
  Proof.
    apply (PollKeep.ps_int lp AX.prog AX._audio_signal_game_loop_tick AX.f_audio_signal_game_loop_tick
             (linked12_LO_audio_external lp H12)); [ vm_compute; reflexivity | exact PS_asg ].
  Qed.

  Theorem PS_agt : PS G (Internal SI.f_audio_game_loop_tick).
  Proof.
    apply (pk_body G [AX._audio_signal_game_loop_tick] (PollKeep.psym_cons lp _ _ ps_asg (PollKeep.psym_nil lp))).
    vm_compute. reflexivity.
  Qed.

  Lemma PS_ssb : PS G (Internal memory.f_set_segment_base_addr).
  Proof. apply (pk_body G [] (PollKeep.psym_nil lp)). vm_compute. reflexivity. Qed.

  Lemma ps_ssb : PollKeep.ps_id lp memory._set_segment_base_addr.
  Proof.
    apply (PollKeep.ps_int lp memory.prog memory._set_segment_base_addr memory.f_set_segment_base_addr
             (linked12_LO_memory lp H12)); [ vm_compute; reflexivity | exact PS_ssb ].
  Qed.

  Theorem PS_sgp : PS G (Internal GI.f_select_gfx_pool).
  Proof.
    apply (pk_body G [memory._set_segment_base_addr] (PollKeep.psym_cons lp _ _ ps_ssb (PollKeep.psym_nil lp))).
    vm_compute. reflexivity.
  Qed.
End PERM.

(* ---------------------------------------------------------------------- *)
(* 2. Footprints (FootWalk).                                               *)
(* ---------------------------------------------------------------------- *)
Section FOOT.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Variable m0 : mem.

  Ltac ct_ok c :=
    let fid := fresh "fid" in let f := fresh "f" in
    let fl' := fresh "fl'" in let qa' := fresh "qa'" in let H := fresh "H" in
    intros fid f fl' qa' H; unfold c in H; cbn [SDB.find_ct] in H;
    repeat match type of H with
    | (if Pos.eqb fid ?g then Some _ else _) = _ =>
        let E := fresh "E" in
        destruct (Pos.eqb fid g) eqn:E; cbv beta iota in H;
        [ apply Pos.eqb_eq in E; subst fid; injection H as <- <- <- | ]
    end;
    [ .. | discriminate H ].

  Ltac res q LO :=
    apply (linkorder_resolves_funct lp q _ _ (LO lp H12)); vm_compute; reflexivity.

  Lemma ct_nil_a : FootWalk.ctab_ok lp agt_gvars m0 [].
  Proof. intros ? ? ? ? H. discriminate H. Qed.
  Lemma ct_nil_s : FootWalk.ctab_ok lp sgp_gvars m0 [].
  Proof. intros ? ? ? ? H. discriminate H. Qed.

  Lemma fw_noop : FootWalk.fpF lp agt_gvars m0 AX.f_noop_8031EEC8 [] [].
  Proof. apply (FootWalk.body_fpF lp H12 Hfloor agt_gvars m0 _ _ _ []); [ vm_compute; reflexivity | exact ct_nil_a ]. Qed.

  Definition ct_asg : SDB.ctab := [(AX._noop_8031EEC8, (AX.f_noop_8031EEC8, ([], [])))].
  Lemma fw_asg : FootWalk.fpF lp agt_gvars m0 AX.f_audio_signal_game_loop_tick [] [].
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor agt_gvars m0 _ _ _ ct_asg); [ vm_compute; reflexivity | ].
    ct_ok ct_asg. split; [ res AX.prog linked12_LO_audio_external | exact fw_noop ].
  Qed.

  Definition ct_agt : SDB.ctab :=
    [(AX._audio_signal_game_loop_tick, (AX.f_audio_signal_game_loop_tick, ([], [])))].
  Lemma fw_agt : FootWalk.fpF lp agt_gvars m0 SI.f_audio_game_loop_tick [] [].
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor agt_gvars m0 _ _ _ ct_agt); [ vm_compute; reflexivity | ].
    ct_ok ct_agt. split; [ res AX.prog linked12_LO_audio_external | exact fw_asg ].
  Qed.

  Definition fl_ssb : list ident := [memory._addr; memory._t'1].
  Lemma fw_ssb : FootWalk.fpF lp sgp_gvars m0 memory.f_set_segment_base_addr fl_ssb [].
  Proof. apply (FootWalk.body_fpF lp H12 Hfloor sgp_gvars m0 _ _ _ []); [ vm_compute; reflexivity | exact ct_nil_s ]. Qed.

  Definition fl_sgp : list ident := [GI._t'1; GI._t'2; GI._t'3; GI._t'4; GI._t'5].
  Definition ct_sgp : SDB.ctab :=
    [(memory._set_segment_base_addr, (memory.f_set_segment_base_addr, (fl_ssb, [])))].
  Lemma fw_sgp : FootWalk.fpF lp sgp_gvars m0 GI.f_select_gfx_pool fl_sgp [].
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor sgp_gvars m0 _ _ _ ct_sgp); [ vm_compute; reflexivity | ].
    ct_ok ct_sgp. split; [ res memory.prog linked12_LO_memory | exact fw_ssb ].
  Qed.
End FOOT.

(* temps all undefined: every Pt holds when qa is empty *)
Lemma pt_undef : forall lp FP m0 fl temps,
  FootWalk.Pt lp FP m0 fl [] (create_undef_temps temps).
Proof.
  intros lp FP m0 fl temps t v Hg. split.
  - intros _ b o ->. exfalso.
    induction temps as [ | (x, ty) temps IH ]; cbn [create_undef_temps] in Hg;
      [ rewrite PTree.gempty in Hg; discriminate Hg | ].
    rewrite PTree.gsspec in Hg. destruct (peq t x); [ discriminate Hg | exact (IH Hg) ].
  - intros Hm. discriminate Hm.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The carries.                                                         *)
(* ---------------------------------------------------------------------- *)
Section LINK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Ltac vmr := vm_compute; reflexivity.

  (* a no-argument call confined to FP's blocks, keeping permissions *)
  Lemma call_fx : forall FP f fl m m' t vres,
    FootWalk.fpF lp FP m f fl [] -> PS G (Internal f) ->
    eval_funcall function_entry2 G m (Internal f) [] t m' vres ->
    fn_params f = [] ->
    Mem.unchanged_on (FootWalk.Q lp FP m) m m' /\ fx lp bm FP m m'.
  Proof.
    intros FP f fl m m' t vres Hfw Hps Hev Hp.
    pose proof (Hps _ _ _ _ _ Hev) as (_ & P & F).
    assert (U : Mem.unchanged_on (FootWalk.Q lp FP m) m m').
    { apply (Hfw m _ t m' vres Hev); [ | apply Ple_refl ].
      intros le Hb. rewrite Hp in Hb. cbn [bind_parameter_temps] in Hb. injection Hb as <-.
      apply pt_undef. }
    split; [ exact U | split; [ | exact (conj P F) ] ].
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b z Nw V. split; [ | exact V ].
    intros Hb. apply Nw. left. exact Hb.
  Qed.

  Ltac keep FP Hc Hfx Hof' Hphi :=
    let Hcl := fresh "Hcl" in
    assert (Hcl : cl_rel G _ _)
      by (destruct Hc as (t & vres & Hev); apply (PollKeep.call_cl lp _ _ _ t _ vres Hev); intros v []);
    pose proof Hphi as (_ & _ & _ & _ & _ & _ & _ & Hl);
    split; [ exact Hof' | split; [ | split ] ];
    [ apply (LevelKeep.lvl_keeps_core lp bm Hbm_sym FP
               (avoid_of FP core_ids ltac:(vmr)) ltac:(vmr) _ _ Hphi Hfx Hcl
               (phiw_surf_apart lp bm FP _ Hphi));
      exact (PollKeep.lvl_w_fx0 lp bm Hbm_sym FP _ _ (avoid_of FP lvl_ids ltac:(vmr)) Hfx Hl)
    | exact (LevelKeep.fx_plat_still lp bm Hbm_sym FP _ _ ltac:(vmr) ltac:(vmr) Hfx)
    | exact (PollKeep.fx_obj_w lp bm Hbm_sym FP _ _ (avoid_of PollKeep.ow_ids FP ltac:(vmr)) ltac:(vmr) Hfx) ].

  Theorem agt_keeps : forall m i, agt_call lp m i ->
    ow_facts bm MWF m -> phiw lp bm m ->
    ow_facts bm MWF i /\ phiw lp bm i
    /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp i)
    /\ (OW.obj_w G bm m -> OW.obj_w G bm i).
  Proof.
    intros m i Hc.
    pose proof Hc as (t0 & v0 & Hev0).
    destruct (call_fx agt_gvars _ [] m i t0 v0 (fw_agt lp H12 Hfloor m) (PS_agt lp H12) Hev0 eq_refl) as (_ & Hfx).
    intros Hof Hphi.
    pose proof (of_uc lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0 _ m t0 i v0 uc_agt Hev0 Hof) as Hof'.
    keep agt_gvars Hc Hfx Hof' Hphi.
  Qed.

  Theorem sgp_keeps : forall m i, sgp_call lp m i ->
    ow_facts bm MWF m -> phiw lp bm m ->
    ow_facts bm MWF i /\ phiw lp bm i
    /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp i)
    /\ (OW.obj_w G bm m -> OW.obj_w G bm i).
  Proof.
    intros m i Hc.
    pose proof Hc as (t0 & v0 & Hev0).
    destruct (call_fx sgp_gvars _ fl_sgp m i t0 v0 (fw_sgp lp H12 Hfloor m) (PS_sgp lp H12) Hev0 eq_refl) as (_ & Hfx).
    intros Hof Hphi.
    pose proof (of_uc lp H12 bm bc oc0 SafeB HSafeB_syms Hbm_sym Hbc_sym Hoc0 _ m t0 i v0 uc_sgp Hev0 Hof) as Hof'.
    keep sgp_gvars Hc Hfx Hof' Hphi.
  Qed.

  (* THE ROW: the stretch between the poll's two calls keeps everything *)
  Theorem mid_keeps : forall m i, mid_call lp m i ->
    ow_facts bm MWF m -> phiw lp bm m ->
    (ow_facts bm MWF i /\ phiw lp bm i)
    /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp i)
    /\ (OW.obj_w G bm m -> OW.obj_w G bm i).
  Proof.
    intros m i (i1 & Ha & Hs) Hof Hphi.
    destruct (agt_keeps m i1 Ha Hof Hphi) as (Hof1 & Hphi1 & P1 & O1).
    destruct (sgp_keeps i1 i Hs Hof1 Hphi1) as (Hof2 & Hphi2 & P2 & O2).
    split; [ exact (conj Hof2 Hphi2) | split; intro H; [ exact (P2 (P1 H)) | exact (O2 (O1 H)) ] ].
  Qed.
End LINK.
