(* ===================================================================== *)
(* PlatformKeep (GOAL 2): the platform step of HeightFrame, on the link   *)
(* (2026-10-23).                                                          *)
(*                                                                       *)
(* seg_platform is ONE real eval_funcall of platform_displacement.c's    *)
(* apply_mario_platform_displacement over the link (plat_call).  Its     *)
(* walked effect (PlatformWalk.ampd_eff -> PlatformEff.plat_eff) is:      *)
(* D_8032FEC0 gets an integer, Mario's pos[0] / pos[2] get new floats,   *)
(* pos[1] gets back the value it had, the locals are allocated and       *)
(* freed.  From that alone this file PROVES the step carries             *)
(*   - GOAL 1's mem_ok (MWF_real, the action cell, bm's validity),       *)
(*   - the A-held bit a_down_real (unchanged), and                       *)
(*   - HeightFrame's PhiW (RenderKeep.k_all with the written globals     *)
(*     [D_8032FEC0]).                                                    *)
(* What the step still STATES, besides the call (labeled trust,          *)
(* docs/TRUST.md 0.5):                                                   *)
(*   plat_still  gMarioPlatform is NULL or an object whose angle         *)
(*               velocity (oAngleVelPitch / Yaw / Roll, rawData.asS32    *)
(*               [35..37]) is zero.  With a nonzero one the real body     *)
(*               rotates Mario about the platform and changes his y; the  *)
(*               WMotR objects Mario can stand on are not proved still    *)
(*               here.                                                    *)
(*   surf_apart  Mario's wall / ceiling / floor surfaces are not in       *)
(*               D_8032FEC0's block (as RenderKeep.render_surf_apart).    *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require platform_displacement mario level_update interaction.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 MWFReal SpawnInit
  LinkedTwelve ActionValueFrame Taint NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve.
From SM64.Proofs Require Import HeightInvariant WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld PlatformEff PlatformWalk RenderKeep.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

Local Open Scope Z_scope.


(* the step: the real apply_mario_platform_displacement *)
Definition plat_call (lp : Clight.program) (m m' : mem) : Prop :=
  exists t vres, eval_funcall function_entry2 (lp_ge lp) m
    (Internal PD.f_apply_mario_platform_displacement) [] t m' vres.

(* its premise: the platform Mario rides is NULL or does not rotate *)
Definition plat_still (lp : Clight.program) (m : mem) : Prop :=
  forall bp v, Genv.find_symbol (lp_ge lp) PD._gMarioPlatform = Some bp ->
    Mem.load Mint32 m bp 0 = Some v ->
    v = Vint Int.zero
    \/ exists pb po, v = Vptr pb po /\ forall k, In k [35; 36; 37] ->
         Mem.loadv Mint32 m (Vptr pb (Ptrofs.add po (Ptrofs.repr (136 + 4 * k)))) = Some (Vint Int.zero).

(* the global the step writes *)
Definition plat_gvars : list ident := [PD._D_8032FEC0].

Section Link.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  Lemma plat_cenv : forall id co, (prog_comp_env PD.prog) ! id = Some co ->
    (genv_cenv G) ! id = Some co.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp PD.prog id co (linked12_LO_platform_displacement lp H12) Hco).
  Qed.

  Lemma pd_dm_gmp : (prog_defmap PD.prog) ! PD._get_mario_pos = Some (Gfun (Internal PD.f_get_mario_pos)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma pd_dm_smp : (prog_defmap PD.prog) ! PD._set_mario_pos = Some (Gfun (Internal PD.f_set_mario_pos)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma pd_dm_apd : (prog_defmap PD.prog) ! PD._apply_platform_displacement
    = Some (Gfun (Internal PD.f_apply_platform_displacement)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma pd_dm_D : (prog_defmap PD.prog) ! PD._D_8032FEC0 = Some (Gvar PD.v_D_8032FEC0).
  Proof. vm_compute. reflexivity. Qed.
  Lemma pd_dm_plat : (prog_defmap PD.prog) ! PD._gMarioPlatform = Some (Gvar PD.v_gMarioPlatform).
  Proof. vm_compute. reflexivity. Qed.

  Lemma plat_fun : forall id f, (prog_defmap PD.prog) ! id = Some (Gfun (Internal f)) ->
    forall b, Genv.find_symbol G id = Some b -> Genv.find_funct_ptr G b = Some (Internal f).
  Proof.
    intros id f Hdm b Hb.
    destruct (linkorder_resolves_internal lp PD.prog _ _ (linked12_LO_platform_displacement lp H12) Hdm)
      as (b' & Hs & Hf).
    unfold lp_ge in Hb. rewrite Hb in Hs. injection Hs as <-. exact Hf.
  Qed.

  Lemma plat_D_sym : exists bD, Genv.find_symbol G PD._D_8032FEC0 = Some bD.
  Proof. exact (linkorder_resolves_symbol lp PD.prog _ _ (linked12_LO_platform_displacement lp H12) pd_dm_D). Qed.
  Lemma plat_p_sym : exists bp, Genv.find_symbol G PD._gMarioPlatform = Some bp.
  Proof. exact (linkorder_resolves_symbol lp PD.prog _ _ (linked12_LO_platform_displacement lp H12) pd_dm_plat). Qed.

  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.

  Lemma bm_bD : forall bD, Genv.find_symbol G PD._D_8032FEC0 = Some bD -> bm <> bD.
  Proof.
    intros bD HbD E. subst bD.
    refine (Genv.global_addresses_distinct G _ Hbm_sym HbD eq_refl). vm_compute. discriminate.
  Qed.

  (* the step's effect, on the link *)
  Theorem plat_step_eff : forall bD m m',
    Genv.find_symbol G PD._D_8032FEC0 = Some bD ->
    Ple (Genv.genv_next G) (Mem.nextblock m) ->
    plat_call lp m m' -> plat_still lp m -> plat_eff bm bD m m'.
  Proof.
    intros bD m m' HbD Hgn (t & vres & Hev) Hst.
    destruct plat_p_sym as (bp & Hbp).
    assert (Hbm' : Genv.find_symbol G PD._gMarioStates = Some bm) by exact Hbm_sym.
    apply (ampd_eff G plat_cenv bm bD bp Hbm' HbD (plat_fun _ _ pd_dm_gmp) (plat_fun _ _ pd_dm_smp)
             (plat_fun _ _ pd_dm_apd) Hbp m t m' vres).
    - exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hbm_sym) Hgn).
    - exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ HbD) Hgn).
    - exact (bm_bD bD HbD).
    - intros v Hl. exact (Hst bp v Hbp Hl).
    - exact Hev.
  Qed.

  (* ===================================================================== *)
  (* 1. GOAL 1's mem_ok and the A-held bit.                                *)
  (* ===================================================================== *)
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  Lemma sym_apart : forall bD id gb, Genv.find_symbol G PD._D_8032FEC0 = Some bD ->
    Genv.find_symbol G id = Some gb ->
    id <> level_update._gMarioStates -> id <> PD._D_8032FEC0 -> gb <> bD /\ gb <> bm.
  Proof.
    intros bD id gb HbD Hs N1 N2. split.
    - intros ->. exact (Genv.global_addresses_distinct G N2 Hs HbD eq_refl).
    - intros ->. exact (Genv.global_addresses_distinct G N1 Hs Hbm_sym eq_refl).
  Qed.

  Lemma kt_ne : forall gid, mem_id gid knockback_table_ids = true ->
    gid <> level_update._gMarioStates /\ gid <> PD._D_8032FEC0.
  Proof. intros gid Hk. split; intros ->; vm_compute in Hk; discriminate Hk. Qed.

  Theorem plat_mem_ok : forall m m',
    mem_ok_lp bm MWF m -> plat_call lp m m' -> plat_still lp m -> mem_ok_lp bm MWF m'.
  Proof.
    intros m m' (Hv & Hs & HM) Hc Hst.
    destruct (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as (init & Hspawn).
    pose proof (spawn_Hbc_bm lp init bm bc oc0 Hspawn) as Hbc_bm.
    destruct plat_D_sym as (bD & HbD).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & R1 & _).
    destruct (plat_step_eff bD m m' HbD Hgn Hc Hst) as (NB & _ & _ & LD & LM & PD6).
    assert (Hval : forall b, Mem.valid_block m b -> Mem.valid_block m' b)
      by (intros b Hb; unfold Mem.valid_block in *; exact (Plt_Ple_trans _ _ _ Hb NB)).
    split; [ exact (Hval _ Hv) | split ].
    - intros v Hl. apply Hs. rewrite <- Hl. symmetry. apply LM. left. cbn. lia.
    - apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm m m'); [ exact Hval | | | | exact HM ].
      + intros v Hl. apply R1. rewrite <- Hl. symmetry. apply LM. left. cbn. lia.
      + intros ch b ofs v Hrow Hl. rewrite <- Hl. symmetry.
        destruct Hrow as [ (-> & Hc') | Hrow ].
        * apply LM. unfold bmw. unfold bm_row_cell in Hc'.
          destruct Hc' as [(_ & Hc') | [(Hc' & _) | (Hc' & _)]]; [ left; lia | right; left; lia | right; left; lia ].
        * assert (N : b <> bD /\ b <> bm).
          { destruct Hrow as [ -> | [ Hs' | [ Hs' | [ Hs' | [ (gid & Hk & Hs') | Hs' ] ] ] ] ].
            - split; [ exact (proj1 (sym_apart bD _ _ HbD Hbc_sym ltac:(vm_compute; discriminate)
                                            ltac:(vm_compute; discriminate))) | exact Hbc_bm ].
            - exact (sym_apart bD _ _ HbD Hs' ltac:(vm_compute; discriminate) ltac:(vm_compute; discriminate)).
            - exact (sym_apart bD _ _ HbD Hs' ltac:(vm_compute; discriminate) ltac:(vm_compute; discriminate)).
            - exact (sym_apart bD _ _ HbD Hs' ltac:(vm_compute; discriminate) ltac:(vm_compute; discriminate)).
            - exact (sym_apart bD _ _ HbD Hs' (proj1 (kt_ne gid Hk)) (proj2 (kt_ne gid Hk))).
            - exact (sym_apart bD _ _ HbD Hs' ltac:(vm_compute; discriminate) ltac:(vm_compute; discriminate)). }
          exact (LD ch b ofs (proj1 N) (proj2 N)).
      + intros b ofs b' o' Sb Hl.
        apply (mwf_real_chase_step lp bm bc oc0 SafeB m b ofs b' o' HM Sb).
        cbn [Mem.loadv] in Hl |- *.
        destruct (eq_block b bD) as [-> | NbD].
        * exact (PD6 _ _ _ _ Hl).
        * rewrite (LD _ _ _ NbD (safeb_not_bm lp init bm bc oc0 SafeB Hspawn HSafeB_syms b Sb)) in Hl.
          exact Hl.
  Qed.

  Theorem plat_a_down : forall m m',
    mem_ok_lp bm MWF m -> plat_call lp m m' -> plat_still lp m -> a_down_real bm m' = a_down_real bm m.
  Proof.
    intros m m' (_ & _ & HM) Hc Hst.
    destruct (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as (init & Hspawn).
    pose proof (spawn_Hbc_bm lp init bm bc oc0 Hspawn) as Hbc_bm.
    destruct plat_D_sym as (bD & HbD).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & _ & R2 & _).
    destruct (plat_step_eff bD m m' HbD Hgn Hc Hst) as (_ & _ & _ & LD & LM & _).
    unfold a_down_real.
    rewrite (LM Mptr 156) by (right; left; lia).
    destruct (Mem.load Mptr m bm 156) as [v |] eqn:E; [| reflexivity ].
    destruct v; try reflexivity.
    destruct (R2 _ _ eq_refl) as (-> & _).
    rewrite (LD _ bc _ (proj1 (sym_apart bD _ _ HbD Hbc_sym ltac:(vm_compute; discriminate)
                                  ltac:(vm_compute; discriminate))) Hbc_bm).
    reflexivity.
  Qed.
End Link.

(* ===================================================================== *)
(* 2. PhiW: RenderKeep's frame keep, with the written globals            *)
(*    [D_8032FEC0].                                                      *)
(* ===================================================================== *)
Section Phi.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Notation G := (lp_ge lp).

  Lemma plat_gvars_flank : incl plat_gvars flank_gvars.
  Proof.
    intros id [<- | []]. unfold flank_gvars. apply in_or_app. right. left. reflexivity.
  Qed.

  Theorem plat_keeps_phiw : forall m m',
    phiw lp bm m -> plat_call lp m m' -> plat_still lp m -> surf_apart lp bm plat_gvars m ->
    phiw lp bm m'.
  Proof.
    intros m m' Hphi Hc Hst RSA.
    pose proof Hphi as (_ & _ & _ & _ & Hf & _ & Haw & _).
    pose proof Haw as (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & _).
    pose proof B as (_ & _ & _ & _ & _ & Lmo & _ & _ & _ & _ & _ & (_ & RG) & _).
    pose proof Hf as (Hgn & EX & _).
    destruct EX as (dw & FWF).
    pose proof (ff_HC _ _ _ _ FWF) as HC. pose proof (ff_HS _ _ _ _ FWF) as HS. pose proof (ff_HM _ _ _ _ FWF) as HM.
    pose proof (ff_Lo _ _ _ _ FWF) as Lo. pose proof (ff_D1 _ _ _ _ FWF) as D1.
    set (gp := fw_gp dw) in *.
    change FFW_OBJ with 136 in Lo. rewrite Lmo in Lo.
    assert (Eb : mb = fw_bo dw) by congruence. rewrite <- Eb in D1. clear Lo Eb.
    assert (Bmb : bm <> mb) by (intros E; exact (D1 (eq_sym E))).
    destruct (plat_D_sym lp H12) as (bD & HbD).
    destruct (plat_step_eff lp H12 bm Hbm_sym bD m m' HbD Hgn Hc Hst) as (NB & PM & _ & LD0 & LM & _).
    assert (HinD : In PD._D_8032FEC0 flank_gvars) by exact (plat_gvars_flank _ (or_introl eq_refl)).
    assert (Rg : forall b, rgb lp plat_gvars b -> b = bD).
    { intros b (id & [<- | []] & Hs). congruence. }
    assert (RGa : forall b, rgb lp plat_gvars b -> b <> mb /\ AnimWorld.tab_apart G m b).
    { intros b Hb. pose proof (Rg b Hb) as ->. exact (RG _ bD HinD HbD). }
    assert (Nbm : ~ rgb lp plat_gvars bm)
      by (intros Hb; exact (bm_bD lp bm Hbm_sym bD HbD (Rg bm Hb))).
    assert (LD : forall ch b z, ~ rgb lp plat_gvars b -> b <> bm ->
              (b <> mb \/ z + size_chunk ch <= Ptrofs.unsigned mo + 64 \/ Ptrofs.unsigned mo + 72 <= z) ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Nr Nb _. apply LD0; [| exact Nb ].
      intros ->. apply Nr. exists PD._D_8032FEC0. split; [ left; reflexivity | exact HbD ]. }
    assert (Nmb : mb <> bD) by (intros E; subst mb; exact (proj1 (RG _ bD HinD HbD) eq_refl)).
    assert (CL : forall gp0, closed_by gp0 m -> gp0 mb <> None ->
              (forall id b, Genv.find_symbol G id = Some b -> gp0 b <> None) ->
              exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m').
    { intros gp0 HC0 _ HS0. destruct Hc as (t & vres & EV).
      destruct (funcall_closed G m _ _ t m' vres gp0 EV HC0 HS0 (Forall_nil _)) as (gp' & I & HC' & _ & _).
      exists gp'. split; [| exact HC' ].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence ].
      rewrite (I _ _ _ E0). discriminate. }
    assert (FR : forall bt0 ot0 k, In k hs_ids ->
              Mem.load Mint32 m mb (Ptrofs.unsigned mo + 60) = Some (Vptr bt0 ot0) ->
              Mem.load Mint32 m mb (Ptrofs.unsigned mo + 72) = Some (Vint Int.zero) ->
              (exists f, -1 <= f <= hs_le k
                 /\ Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 64) = Some (Vint (Int.repr f))) ->
              buf_ok m bt0 ot0 k -> Ptrofs.unsigned ot0 + BUFSZ < Ptrofs.modulus ->
              exists f, -1 <= f <= hs_le k
                /\ Mem.load Mint16signed m' mb (Ptrofs.unsigned mo + 64) = Some (Vint (Int.repr f))).
    { intros bt0 ot0 k _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf |].
      rewrite (LD0 _ _ _ Nmb (not_eq_sym Bmb)). exact L64. }
    exact (k_all lp bm plat_gvars plat_gvars_flank m m' mb mo Lmo NB PM LD LM Hbm_sym Nbm Bmb RGa CL FR
             Hphi RSA).
  Qed.
End Phi.
