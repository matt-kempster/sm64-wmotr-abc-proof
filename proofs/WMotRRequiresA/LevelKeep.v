(* ====================================================================== *)
(* LevelKeep (GOAL 2): the level phase of a WMotR frame carries GOAL 1's  *)
(* mem_ok, the A-held bit and HeightFrame's PhiW, from the real code      *)
(* (2026-10-24).                                                          *)
(*                                                                        *)
(* The two level steps are statement slices of the real play_mode_normal  *)
(* (LevelFlank.level_pre_call / level_post_call).                         *)
(*   PRE  (before area_update_objects): under warp_w (in PhiW) the demo   *)
(*        guard, warp_area and check_instant_warp do nothing (walked,     *)
(*        LevelFlank); the timer statement is walked (LevelWalk).         *)
(*   POST (after it): update_hud_values, initiate_painting_warp (only its *)
(*        local: no painting floor), initiate_delayed_warp and the mode   *)
(*        switch are walked (LevelWalk); update_camera(gCurrentArea->     *)
(*        camera) is walked to the call and keeps mem_ok by the real      *)
(*        camera.c (UpdateCameraBody.update_camera_pres, passed in as     *)
(*        uc_keeps); its PhiW carry is the ONE labeled row (cam_phi_row). *)
(* Each walked piece changes memory only in LevelWalk.lvW (written       *)
(* globals' blocks and gMarioStates' numCoins / numLives), keeps ow_facts *)
(* and closedness.  RenderKeep.k_all_lvl then carries PhiW: the PRE and  *)
(* update_hud_values write no lvl_w cell (footprint lvl_safe_gvars), the *)
(* tail writes the warp cells sWarpDest / sCurrPlayMode /                *)
(* gCurrCreditsEntry, and FfWorld.warp_w at its end is PROVED from the   *)
(* real tail (LevelWarp.tail_warp_w, 2026-10-26).                        *)
(*                                                                        *)
(* What the steps still STATE (labeled trust, docs/TRUST.md 0.5 / 0.7):   *)
(*   surf_apart  Mario's wall / ceiling / floor surfaces are not in a     *)
(*               level global's block (as for the render / platform       *)
(*               steps);                                                  *)
(*   cam_phi_row update_camera's statement, from a mem_ok state to a      *)
(*               mem_ok state, keeps PhiW and Mario's three surface       *)
(*               cells.  A clobber-form contract (camera-private writes   *)
(*               only) does not give it: the main-pool Camera struct      *)
(*               shares its block with the surface pool, and k_all keeps  *)
(*               whole blocks.  The out-of-class writes it must cover are *)
(*               UpdateCameraBody.uc_census's (vm-pinned): gTimeStopState, *)
(*               sCutsceneVars, gCameraMovementFlags, gSecondCameraFocus's *)
(*               object, Mario's action (set_mario_npc_dialog), the audio *)
(*               / dialog / hud sCameraHUDStatus globals, gRandomSeed16   *)
(*               and the find_floor counters.                              *)
(* ====================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors.
From SM64.Generated Require mario level_update platform_displacement object_list_processor area.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 MWFReal SpawnInit
  LinkedTwelve ActionValueFrame Taint NoAImpliesNoFlyLinked AGates MathBodies MathGeomGated
  OsDmaFloor.
From SM64.Proofs Require NoAImpliesNoFlyTwelve SaveDoSaveBody.
From SM64.Proofs.WMotRRequiresA Require PlatformKeep.
From SM64.Proofs Require Import HeightInvariant WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderAnim RenderKeep
  LevelGvars LevelFlank LevelWalk.
From SM64.Proofs.WMotRRequiresA Require LevelWarp.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
Import ListNotations.

Local Open Scope Z_scope.

(* a statement made of assignments, calls and ifs ends normally *)
Fixpoint plain (s : statement) : bool :=
  match s with
  | Sskip | Sassign _ _ | Sset _ _ | Scall _ _ _ | Sbuiltin _ _ _ _ => true
  | Ssequence a b | Sifthenelse _ a b => plain a && plain b
  | _ => false
  end.

Lemma plain_normal : forall ge e le m s t le' m' out,
  exec_stmt function_entry2 ge e le m s t le' m' out -> plain s = true -> out = Out_normal.
Proof.
  intros ge e le m s t le' m' out H. induction H; intros Hp; cbn [plain] in Hp;
    try discriminate Hp; try reflexivity.
  - apply andb_prop in Hp as [_ A2]. exact (IHexec_stmt2 A2).
  - apply andb_prop in Hp as [A1 _]. exfalso. exact (H0 (IHexec_stmt A1)).
  - apply andb_prop in Hp as [A1 A2]. apply IHexec_stmt. destruct b; assumption.
Qed.

Lemma lv_plain : plain lv_hud && plain lv_cam && plain lv_paint && plain lv_demo = true.
Proof. vm_compute. reflexivity. Qed.

(* the real update_camera keeps mem_ok from any mem_ok state, its argument
   SafeB-if-pointer (UpdateCameraBody.update_camera_pres, as
   HeightFrame.update_camera_ok_linked12 states it on the link) *)
Definition uc_keeps (lp : Clight.program) (bm : block) (MWF : mem -> Prop) (SafeB : block -> Prop) : Prop :=
  forall b fd m c t m' vres,
    Genv.find_symbol (lp_ge lp) LU._update_camera = Some b ->
    Genv.find_funct (lp_ge lp) (Vptr b Ptrofs.zero) = Some fd ->
    eval_funcall function_entry2 (lp_ge lp) m fd [c] t m' vres ->
    (forall bb oo, c = Vptr bb oo -> SafeB bb) ->
    mem_ok_lp bm MWF m -> mem_ok_lp bm MWF m'.

(* gCurrentArea points into a SafeB block *)
Definition cam_area_safe (lp : Clight.program) (SafeB : block -> Prop) (m : mem) : Prop :=
  forall ga a o, Genv.find_symbol (lp_ge lp) LU._gCurrentArea = Some ga ->
    Mem.load Mint32 m ga 0 = Some (Vptr a o) -> SafeB a.

(* the camera step of the POST slice (LevelFlank.cam_step), between mem_ok
   states, keeps PhiW and Mario's wall / ceiling / floor cells *)
Definition cam_phi_row (lp : Clight.program) (bm : block) (MWF : mem -> Prop) : Prop :=
  forall m m', cam_step lp m m' -> mem_ok_lp bm MWF m -> phiw lp bm m -> mem_ok_lp bm MWF m' ->
    phiw lp bm m'
    /\ (forall off, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
          Mem.load Mint32 m' bm off = Mem.load Mint32 m bm off).

(* p->f, any offset *)
Lemma ev_fld_any : forall ge e le m x S f t v ch, access_mode (Tpointer t noattr) = By_value ch ->
  eval_expr ge e le m (Efield (Ederef (Etempvar x (Tpointer (Tstruct S noattr) noattr)) (Tstruct S noattr)) f
                         (Tpointer t noattr)) v ->
  exists b o ofs, le ! x = Some (Vptr b o) /\ Mem.loadv ch m (Vptr b ofs) = Some v.
Proof.
  intros ge e le m x S f t v ch Ham H. cbn [access_mode] in Ham. injection Ham as <-.
  inv H. match goal with Hl : eval_lvalue _ _ _ _ (Efield _ _ _) _ _ _ |- _ => inv Hl end.
  all: try (match goal with Ht : typeof _ = Tunion _ _ |- _ => cbn in Ht; discriminate Ht end).
  all: match goal with He : eval_expr _ _ _ _ (Ederef _ _) _ |- _ => inv He end.
  all: match goal with Hl : eval_lvalue _ _ _ _ (Ederef _ _) _ _ _ |- _ => inv Hl end.
  all: cbn [typeof] in *.
  all: match goal with Hd : deref_loc (Tstruct _ _) _ _ _ _ _ |- _ => inv Hd end; cbn in *; try discriminate.
  all: match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) _ |- _ => apply ev_temp in Ht end.
  all: do 3 eexists; split; [ eassumption |].
  all: match goal with Hd : deref_loc _ _ _ _ _ _ |- _ => inv Hd end; cbn [access_mode] in *; try discriminate.
  all: try (match goal with Hb : Cop.load_bitfield _ _ _ _ _ _ _ _ |- _ => inv Hb end).
  all: repeat match goal with H1 : By_value _ = By_value _ |- _ => injection H1 as H1; subst end.
  all: cbn [Mem.loadv] in *; eassumption.
Qed.

Lemma level_gvars_flank : incl level_gvars flank_gvars.
Proof.
  intros id Hin. unfold flank_gvars. apply in_or_app. right. apply in_or_app. right. exact Hin.
Qed.


Section Link.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Hypothesis Hfloor : os_dma_floor.

  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation OF := (ow_facts bm MWF).

  Let Hspawn := NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0.

  Lemma not_lvl : forall Xs id b, Genv.find_symbol G id = Some b ->
    existsb (Pos.eqb id) Xs = false -> ~ lvl_blk lp Xs b.
  Proof.
    intros Xs id b Hs Hn (id' & Hin & Hs').
    destruct (peq id id') as [<- | Ne].
    - assert (E : existsb (Pos.eqb id) Xs = true)
        by (apply existsb_exists; exists id; split; [ exact Hin | apply Pos.eqb_refl ]).
      congruence.
    - exact (Genv.global_addresses_distinct G Ne Hs Hs' eq_refl).
  Qed.

  Lemma bm_not_lvl : forall Xs, existsb (Pos.eqb level_update._gMarioStates) Xs = false ->
    ~ lvl_blk lp Xs bm.
  Proof. intros Xs H. exact (not_lvl Xs _ _ Hbm_sym H). Qed.
  Lemma bc_not_lvl : forall Xs, existsb (Pos.eqb mario._gControllers) Xs = false ->
    ~ lvl_blk lp Xs bc.
  Proof. intros Xs H. exact (not_lvl Xs _ _ Hbc_sym H). Qed.

  Ltac nb := vm_compute; reflexivity.

  Lemma lu_sym : forall id, (prog_defmap LU.prog) ! id <> None -> exists b, Genv.find_symbol G id = Some b.
  Proof.
    intros id H. destruct ((prog_defmap LU.prog) ! id) as [gd|] eqn:E; [ | congruence ].
    exact (linkorder_resolves_symbol lp LU.prog id gd (linked12_LO_lvl lp H12) E).
  Qed.

  (* `f();` of a level_update function *)
  Lemma lu_call0 : forall id f le m t le' m' out,
    (prog_defmap LU.prog) ! id = Some (Gfun (Internal f)) ->
    exec_stmt function_entry2 G empty_env le m (Scall None (Evar id fn0) nil) t le' m' out ->
    exists t' vres, eval_funcall function_entry2 G m (Internal f) nil t' m' vres.
  Proof.
    intros id f le m t le' m' out Hdm Hx.
    apply call_inv in Hx.
    destruct Hx as (tyargs & tyres & cc & vf & vargs & fd & vres & _ & Hev & Hel & Hff & _ & Hfc & _ & _).
    unfold fn0 in Hev.
    destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev (PTree.gempty _ _)) as (lf & Hsy & ->).
    destruct (linkorder_resolves_internal lp LU.prog id f (linked12_LO_lvl lp H12) Hdm) as (b' & Hs' & Hf').
    unfold lp_ge in Hsy. rewrite Hsy in Hs'. injection Hs' as <-.
    rewrite Genv.find_funct_find_funct_ptr in Hff. unfold lp_ge in Hff. rewrite Hf' in Hff.
    injection Hff as <-.
    inv Hel. eauto.
  Qed.

  Lemma dm_wa : (prog_defmap LU.prog) ! LU._warp_area = Some (Gfun (Internal LU.f_warp_area)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_ciw : (prog_defmap LU.prog) ! LU._check_instant_warp
    = Some (Gfun (Internal LU.f_check_instant_warp)).
  Proof. vm_compute. reflexivity. Qed.
  Lemma dm_paint : (prog_defmap LU.prog) ! LU._initiate_painting_warp
    = Some (Gfun (Internal LU.f_initiate_painting_warp)).
  Proof. vm_compute. reflexivity. Qed.

  Lemma chk_timer : lv_stmt_chk lvl_safe_gvars nil lv_timer = true /\ cl_chk lv_timer = true.
  Proof. split; vm_compute; reflexivity. Qed.
  Lemma chk_hud : lv_stmt_chk lvl_safe_gvars hud_ids lv_hud = true /\ cl_chk lv_hud = true.
  Proof. split; vm_compute; reflexivity. Qed.
  Lemma chk_tail : lv_stmt_chk level_gvars lvl_calls lv_tail = true /\ cl_chk lv_tail = true.
  Proof. split; vm_compute; reflexivity. Qed.
  Lemma chk_paint : cl_chk lv_paint = true.
  Proof. vm_compute. reflexivity. Qed.

  (* the instant / painting warp guards' premise, from GOAL 1's facts and
     the frame world *)
  Lemma fsafe : forall m, OF m -> phiw lp bm m -> floor_safe G bm m.
  Proof.
    intros m (Hv & _ & HM) (_ & (_ & _ & Hfl & _) & _).
    destruct (lu_sym LU._gMarioState ltac:(vm_compute; discriminate)) as (bs & Hbs).
    exists bs. split; [ exact Hbs | split; [ | split; [ | exact Hv ] ] ].
    - intros b o Hl. exact (mwf_real_pgms lp bm bc oc0 SafeB m bs b o HM Hbs Hl).
    - intros v Hl. destruct (Hfl v Hl) as (fb & fo & t & -> & Ht & Hin).
      rewrite wmotr_surface_types_value in Hin.
      exists fb, fo, t. split; [ reflexivity | split; [ exact Ht | exact Hin ] ].
  Qed.

  Lemma Hgp : forall b fd, Genv.find_symbol G LU._get_painting_warp_node = Some b ->
    Genv.find_funct_ptr G b = Some fd -> fd = Internal LU.f_get_painting_warp_node.
  Proof.
    intros b fd Hs Hf.
    destruct (linkorder_resolves_internal lp LU.prog LU._get_painting_warp_node LU.f_get_painting_warp_node
                (linked12_LO_lvl lp H12) ltac:(vm_compute; reflexivity)) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hf. rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'.
    injection Hf' as ->. reflexivity.
  Qed.

  (* ===================================================================== *)
  (* 1. The PRE slice's effect: footprint lvl_safe_gvars (the timer).      *)
  (* ===================================================================== *)
  Theorem pre_eff : forall m m',
    level_pre_call lp m m' -> phiw lp bm m -> OF m ->
    OF m' /\ fx lp bm lvl_safe_gvars m m' /\ cl_rel G m m'.
  Proof.
    intros m m' (Hmode & t & le' & out & Hx) Hphi Hf.
    pose proof Hphi as (_ & _ & _ & _ & _ & _ & _ & Hlvl).
    pose proof Hlvl as (L1 & _ & (Pw & Pd & _ & _) & _).
    pose proof lv_plain as Hpl. repeat (apply andb_prop in Hpl as [Hpl ?]).
    destruct (lu_sym LU._gCurrDemoInput ltac:(vm_compute; discriminate)) as (bd & Hbd).
    unfold lv_pre in Hx.
    apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & Hd & Hx) | (Hd & Hout)];
      destruct (demo_noop G _ _ _ _ _ _ bd Hbd (Pd bd Hbd) Hd) as (-> & Ho);
      [ | congruence ].
    (* warp_area *)
    destruct (lu_sym LU._sCurrPlayMode ltac:(vm_compute; discriminate)) as (bp & Hbp).
    destruct (lu_sym LU._sWarpDest ltac:(vm_compute; discriminate)) as (bw & Hbw).
    apply seq_inv in Hx as [(t3 & le2 & m2 & t4 & Hw & Hx) | (Hw & Hout)];
      rewrite lv_wa_eq in Hw;
      [ | exfalso; apply Hout; exact (plain_normal _ _ _ _ _ _ _ _ _ Hw eq_refl) ].
    destruct (lu_call0 _ _ _ _ _ _ _ _ dm_wa Hw) as (tw & vw & Hfw).
    pose proof (wa_noop G (lu_cenv lp H12) _ _ _ _ bw Hbw
                  (Pw bp bw Hbp Hbw (Hmode bp Hbp)) Hfw) as ->.
    (* check_instant_warp *)
    destruct (lu_sym LU._gCurrLevelNum ltac:(vm_compute; discriminate)) as (bl & Hbl).
    apply seq_inv in Hx as [(t5 & le3 & m3 & t6 & Hc & Hx) | (Hc & Hout)];
      rewrite lv_ciw_eq in Hc;
      [ | exfalso; apply Hout; exact (plain_normal _ _ _ _ _ _ _ _ _ Hc eq_refl) ].
    destruct (lu_call0 _ _ _ _ _ _ _ _ dm_ciw Hc) as (tc & vc & Hfc).
    pose proof (ciw_noop G (lu_cenv lp H12) bm _ _ _ _ bl Hbl (L1 bl Hbl) (fsafe m Hf Hphi) Hfc) as ->.
    (* the timer *)
    destruct chk_timer as (C1 & C2).
    destruct (lv_stmt lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor lvl_safe_gvars sb_safe nil lv_timer C1
                (fun g Hg => ltac:(discriminate Hg)) _ _ _ _ _ _ Hx Hf) as (Hf' & Hfx).
    exact (conj Hf' (conj Hfx (cl_stmt G lv_timer C2 _ _ _ _ _ _ Hx))).
  Qed.

  Theorem fx_a_down : forall Xs m m',
    existsb (Pos.eqb level_update._gMarioStates) Xs = false ->
    existsb (Pos.eqb mario._gControllers) Xs = false ->
    OF m -> fx lp bm Xs m m' -> a_down_real bm m' = a_down_real bm m.
  Proof.
    intros Xs m m' Nm Nc (_ & _ & HM) Hfx.
    pose proof HM as (_ & _ & R2 & _).
    pose proof (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as (init & Hsp).
    pose proof (spawn_Hbc_bm lp init bm bc oc0 Hsp) as Hbc_bm.
    unfold a_down_real.
    rewrite (fx_load lp bm Xs m m' Mptr bm 156 Hfx)
      by (intros i Hi [Hb | (_ & Hc)]; [ exact (bm_not_lvl Xs Nm Hb) | change (size_chunk Mptr) with 4 in Hi; lia ]).
    destruct (Mem.load Mptr m bm 156) as [v|] eqn:E; [ | reflexivity ].
    destruct v; try reflexivity.
    destruct (R2 _ _ eq_refl) as (-> & _).
    rewrite (fx_load lp bm Xs m m' Mint16unsigned bc _ Hfx)
      by (intros j _ [Hb | (Hb & _)]; [ exact (bc_not_lvl Xs Nc Hb) | exact (Hbc_bm Hb) ]).
    reflexivity.
  Qed.

  (* ===================================================================== *)
  (* 2. PhiW through a walked piece: RenderKeep.k_all_lvl, given lvl_w at  *)
  (*    the end.                                                           *)
  (* ===================================================================== *)
  Theorem lvl_keeps_gen : forall Xs, incl Xs flank_gvars ->
    existsb (Pos.eqb level_update._gMarioStates) Xs = false -> forall m m',
    phiw lp bm m -> fx lp bm Xs m m' -> cl_rel G m m' -> surf_apart lp bm Xs m ->
    lvl_w G m' -> phiw lp bm m'.
  Proof.
    intros Xs HXs HNm m m' Hphi Hfx Hcl RSA Hlw.
    pose proof Hphi as (_ & _ & _ & _ & Hf & _ & Haw & _).
    pose proof Haw as (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & _).
    pose proof B as (_ & _ & _ & _ & _ & Lmo & _ & _ & _ & _ & _ & (_ & RG) & _).
    pose proof Hf as (Hgn & EX & _).
    ffw_unpack EX.
    change FFW_OBJ with 136 in Lo. rewrite Lmo in Lo. injection Lo as <- <-.
    assert (Bmb : bm <> mb) by (intros E; exact (D1 (eq_sym E))).
    assert (RGa : forall b, rgb lp Xs b -> b <> mb /\ AnimWorld.tab_apart G m b).
    { intros b (id & Hin & Hs). exact (RG _ b (HXs _ Hin) Hs). }
    assert (Nbm : ~ rgb lp Xs bm) by exact (bm_not_lvl Xs HNm).
    pose proof Hfx as (U & P & F).
    assert (NB : Ple (Mem.nextblock m) (Mem.nextblock m')) by exact (Mem.unchanged_on_nextblock _ _ _ U).
    assert (PM : forall b o k p, Plt b (Mem.nextblock m) -> Mem.perm m b o k p -> Mem.perm m' b o k p)
      by (intros b o k p Hv Hp; exact (proj1 (P b o k p Hv) Hp)).
    assert (LD : forall ch b z, ~ rgb lp Xs b -> b <> bm ->
              (b <> mb \/ z + size_chunk ch <= Ptrofs.unsigned mo + 64 \/ Ptrofs.unsigned mo + 72 <= z) ->
              Mem.load ch m' b z = Mem.load ch m b z).
    { intros ch b z Nr Nb _. apply (fx_load lp bm Xs m m' ch b z Hfx).
      intros i _ [Hb | (Hb & _)]; [ exact (Nr Hb) | exact (Nb Hb) ]. }
    assert (LM : forall ch z, bmk ch z -> Mem.load ch m' bm z = Mem.load ch m bm z).
    { intros ch z Hk. apply (fx_load lp bm Xs m m' ch bm z Hfx).
      intros i Hi [Hb | (_ & Hc)]; [ exact (Nbm Hb) | ].
      destruct Hk as (_ & K1 & K2). lia. }
    assert (CL : forall gp0, closed_by gp0 m -> gp0 mb <> None ->
              (forall id b, Genv.find_symbol G id = Some b -> gp0 b <> None) ->
              exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m').
    { intros gp0 HC0 _ HS0.
      destruct (Hcl gp0 HC0 HS0) as (gp' & I & HC' & _).
      exists gp'. split; [ | exact HC' ].
      intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence ].
      rewrite (I _ _ _ E0). discriminate. }
    assert (Nmbl : ~ rgb lp Xs mb) by (intros Hb; exact (proj1 (RGa mb Hb) eq_refl)).
    assert (FR : forall bt0 ot0 k, In k hs_ids ->
              Mem.load Mint32 m mb (Ptrofs.unsigned mo + 60) = Some (Vptr bt0 ot0) ->
              Mem.load Mint32 m mb (Ptrofs.unsigned mo + 72) = Some (Vint Int.zero) ->
              (exists f, -1 <= f <= hs_le k
                 /\ Mem.load Mint16signed m mb (Ptrofs.unsigned mo + 64) = Some (Vint (Int.repr f))) ->
              buf_ok m bt0 ot0 k -> Ptrofs.unsigned ot0 + BUFSZ < Ptrofs.modulus ->
              exists f, -1 <= f <= hs_le k
                /\ Mem.load Mint16signed m' mb (Ptrofs.unsigned mo + 64) = Some (Vint (Int.repr f))).
    { intros btx otx k _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf |].
      rewrite (fx_load lp bm Xs m m' Mint16signed mb _ Hfx). exact L64.
      intros i _ [Hb | (Hb & _)]; [ exact (Nmbl Hb) | exact (Bmb (eq_sym Hb)) ]. }
    exact (k_all_lvl lp bm Xs HXs m m' mb mo Lmo NB PM LD LM Hbm_sym Nbm Bmb RGa CL FR Hphi RSA Hlw).
  Qed.

  Ltac ne := let E := fresh in intro E; vm_compute in E; discriminate E.

  (* a footprint without the lvl_ids globals keeps lvl_w *)
  Lemma lvl_w_safe : forall m m', lvl_w G m -> fx lp bm lvl_safe_gvars m m' -> lvl_w G m'.
  Proof.
    intros m m' Hl Hfx. apply (lvl_w_unch G m m'); [ | exact Hl ].
    intros b ch z Hs. apply (fx_load lp bm lvl_safe_gvars m m' ch b z Hfx).
    intros i _ Hw.
    lvl_cases Hs; (destruct Hw as [Hb | (-> & _)];
      [ exact (not_lvl lvl_safe_gvars _ _ Hs ltac:(nb) Hb)
      | refine (Genv.global_addresses_distinct G _ Hs Hbm_sym eq_refl); ne ]).
  Qed.

  (* the POST tail writes three warp cells; with warp_w at its end
     (LevelWarp.tail_warp_w), lvl_w holds there (the other lvl_ids globals
     are not written) *)
  Lemma lvl_w_tail : forall m m', lvl_w G m -> fx lp bm level_gvars m m' -> warp_w G m' -> lvl_w G m'.
  Proof.
    intros m m' (L1 & L2 & _ & CW & AW) Hfx Hw.
    assert (U' : forall id b, Genv.find_symbol G id = Some b ->
               existsb (Pos.eqb id) level_gvars = false -> id <> level_update._gMarioStates ->
               forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros id b Hs Hn Hne ch z. apply (fx_load lp bm level_gvars m m' ch b z Hfx).
      intros i _ [Hb | (-> & _)];
        [ exact (not_lvl level_gvars _ _ Hs Hn Hb) | exact (Genv.global_addresses_distinct G Hne Hs Hbm_sym eq_refl) ]. }
    split; [| split; [| split; [ exact Hw | split ]]].
    - intros b Hs. rewrite (U' _ b Hs ltac:(nb) ltac:(ne)). exact (L1 b Hs).
    - intros b Hs. rewrite (U' _ b Hs ltac:(nb) ltac:(ne)). exact (L2 b Hs).
    - intros bc' bp Sc Sp.
      destruct (CW bc' bp Sc Sp) as (L24 & B16 & PA & P1 & P3 & DM & MX).
      pose proof (U' _ bc' Sc ltac:(nb) ltac:(ne)) as Kc.
      pose proof (U' _ bp Sp ltac:(nb) ltac:(ne)) as Kp.
      split; [intros j Hj; rewrite !Kc; exact (L24 j Hj) |].
      split; [intros z Hz; rewrite Kc; exact (B16 z Hz) |].
      split; [intros k' n Hk' Hl; rewrite Kp in Hl; exact (PA k' n Hk' Hl) |].
      split; [intros b1 S1; rewrite (U' _ b1 S1 ltac:(nb) ltac:(ne)); exact (P1 b1 S1) |].
      split; [intros b3 S3; rewrite (U' _ b3 S3 ltac:(nb) ltac:(ne)); exact (P3 b3 S3) |].
      split; [intros bd Sd; rewrite (U' _ bd Sd ltac:(nb) ltac:(ne)); exact (DM bd Sd) |].
      intros bx Sx; rewrite (U' _ bx Sx ltac:(nb) ltac:(ne)); exact (MX bx Sx).
    - split; [ | split ].
      + intros ga Sa. rewrite (U' _ ga Sa ltac:(nb) ltac:(ne)). exact (proj1 AW ga Sa).
      + intros be Se. rewrite (U' _ be Se ltac:(nb) ltac:(ne)). exact (proj1 (proj2 AW) be Se).
      + intros be Se. rewrite (U' _ be Se ltac:(nb) ltac:(ne)). exact (proj2 (proj2 AW) be Se).
  Qed.

  Lemma safe_flank : incl lvl_safe_gvars flank_gvars.
  Proof.
    intros id Hin. unfold flank_gvars. apply in_or_app. right. apply in_or_app. right.
    unfold level_gvars. apply in_or_app. left. exact Hin.
  Qed.

  Theorem safe_keeps_phiw : forall m m',
    phiw lp bm m -> fx lp bm lvl_safe_gvars m m' -> cl_rel G m m' ->
    surf_apart lp bm lvl_safe_gvars m -> phiw lp bm m'.
  Proof.
    intros m m' Hphi Hfx Hcl RSA.
    apply (lvl_keeps_gen lvl_safe_gvars safe_flank ltac:(nb) m m' Hphi Hfx Hcl RSA).
    exact (lvl_w_safe m m' (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 Hphi))))))) Hfx).
  Qed.

  (* surf_apart: smaller lists, and along unchanged surface cells *)
  Lemma surf_apart_incl : forall Xs Ys m, incl Ys Xs ->
    surf_apart lp bm Xs m -> surf_apart lp bm Ys m.
  Proof. intros Xs Ys m I RSA id b off sb so Hin. exact (RSA id b off sb so (I _ Hin)). Qed.

  Lemma safe_incl : incl lvl_safe_gvars level_gvars.
  Proof. intros id Hin. unfold level_gvars. apply in_or_app. left. exact Hin. Qed.

  Lemma surf_apart_move : forall Xs m m',
    (forall off, off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
       Mem.load Mint32 m' bm off = Mem.load Mint32 m bm off) ->
    surf_apart lp bm Xs m -> surf_apart lp bm Xs m'.
  Proof.
    intros Xs m m' E RSA id b off sb so Hin Hs Hoff Hl.
    rewrite (E off Hoff) in Hl. exact (RSA id b off sb so Hin Hs Hoff Hl).
  Qed.

  Lemma fx_surf : forall Xs m m' off, existsb (Pos.eqb level_update._gMarioStates) Xs = false ->
    fx lp bm Xs m m' ->
    off = WALL_OFF \/ off = CEIL_OFF \/ off = FLOOR_OFF ->
    Mem.load Mint32 m' bm off = Mem.load Mint32 m bm off.
  Proof.
    intros Xs m m' off Nm Hfx Hoff. apply (fx_load lp bm Xs m m' Mint32 bm off Hfx).
    intros i Hi [Hb | (_ & Hc)]; [ exact (bm_not_lvl Xs Nm Hb) | ].
    unfold WALL_OFF, CEIL_OFF, FLOOR_OFF in Hoff. cbn in Hi. lia.
  Qed.

  (* the platform fact through a footprint that misses gMarioPlatform and
     gObjectPool (the platform object's block, PlatformKeep.plat_still) *)
  Lemma fx_plat_still : forall Xs m m',
    existsb (Pos.eqb platform_displacement._gMarioPlatform) Xs = false ->
    existsb (Pos.eqb object_list_processor._gObjectPool) Xs = false ->
    fx lp bm Xs m m' ->
    PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp m'.
  Proof.
    intros Xs m m' Hn Hnp Hfx Hst bp v Hbp Hl.
    assert (Nbp : bp <> bm)
      by (refine (Genv.global_addresses_distinct G _ Hbp Hbm_sym); ne).
    rewrite (fx_load lp bm Xs m m' Mint32 bp 0 Hfx) in Hl
      by (intros i _ [Hb | (Hb & _)]; [ exact (not_lvl Xs _ _ Hbp Hn Hb) | exact (Nbp Hb) ]).
    destruct (Hst bp v Hbp Hl) as [Hz | (pb & po & -> & Hpool & Hk)]; [ left; exact Hz | right ].
    assert (Np : ~ lvl_blk lp Xs pb) by exact (not_lvl Xs _ _ Hpool Hnp).
    assert (Npm : pb <> bm)
      by (refine (Genv.global_addresses_distinct G _ Hpool Hbm_sym); ne).
    exists pb, po. split; [ reflexivity | split; [ exact Hpool | ] ].
    intros k Hk'. specialize (Hk k Hk'). cbn [Mem.loadv] in *.
    rewrite (fx_load lp bm Xs m m' Mint32 pb _ Hfx)
      by (intros i _ [Hb | (Hb & _)]; [ exact (Np Hb) | exact (Npm Hb) ]).
    exact Hk.
  Qed.

  (* ===================================================================== *)
  (* 3. The two steps' carries.                                            *)
  (* ===================================================================== *)
  Theorem pre_keeps : forall m m',
    level_pre_call lp m m' -> surf_apart lp bm level_gvars m ->
    mem_ok_lp bm MWF m -> phiw lp bm m ->
    mem_ok_lp bm MWF m' /\ phiw lp bm m' /\ a_down_real bm m' = a_down_real bm m
    /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp m').
  Proof.
    intros m m' Hc RSA Hok Hphi.
    destruct (pre_eff m m' Hc Hphi Hok) as (Hok' & Hfx & Hcl).
    split; [ exact Hok' | split; [ | split ] ].
    - exact (safe_keeps_phiw m m' Hphi Hfx Hcl (surf_apart_incl _ _ m safe_incl RSA)).
    - exact (fx_a_down lvl_safe_gvars m m' ltac:(nb) ltac:(nb) Hok Hfx).
    - exact (fx_plat_still lvl_safe_gvars m m' ltac:(nb) ltac:(nb) Hfx).
  Qed.

  (* gCurrentArea points into gAreaData (the carried FfWorld.area_w), a
     SafeB symbol (CensusV2.camera_safe_syms) *)
  Lemma area_safe_of_w : forall m, area_w G m -> cam_area_safe lp SafeB m.
  Proof.
    intros m AW ga a o Hga Hl.
    destruct (AW ga Hga) as (bad & o' & Hgad & Hl').
    rewrite Hl in Hl'. injection Hl' as <- _.
    exact (proj2 (proj2 HSafeB_syms) area._gAreaData a ltac:(vm_compute; reflexivity) Hgad).
  Qed.

  (* the camera statement keeps mem_ok: walked to the call, the real
     update_camera (uc_keeps) on gCurrentArea->camera, SafeB by MWF's chase
     step from gCurrentArea's SafeB pointee *)
  Lemma cam_mem_ok : uc_keeps lp bm MWF SafeB -> forall m m',
    cam_step lp m m' -> mem_ok_lp bm MWF m -> cam_area_safe lp SafeB m -> mem_ok_lp bm MWF m'.
  Proof.
    intros UC m m' (le & t & le' & out & Hx) Hok Hsa.
    rewrite lv_cam_eq in Hx.
    apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & Hs & Hx) | (Hs & Hout)].
    2: { apply set_inv in Hs as (_ & _ & _ & _ & Ho). congruence. }
    apply set_inv in Hs as (v10 & _ & -> & -> & _).
    apply if_inv in Hx as (vc & bb & _ & _ & Hx).
    destruct bb.
    2: { apply skip_inv in Hx as (-> & _). exact Hok. }
    apply seq_inv in Hx as [(t3 & le2 & m2 & t4 & Hs & Hx) | (Hs & Hout)].
    2: { apply set_inv in Hs as (_ & _ & _ & _ & Ho). congruence. }
    apply set_inv in Hs as (v11 & Hv11 & -> & -> & _).
    apply seq_inv in Hx as [(t5 & le3 & m3 & t6 & Hs & Hx) | (Hs & Hout)].
    2: { apply set_inv in Hs as (_ & _ & _ & _ & Ho). congruence. }
    apply set_inv in Hs as (v12 & Hv12 & -> & -> & _).
    apply call_inv in Hx as (tyargs & tyres & cc & vf & vargs & fd & vres & Hcl & Hev & Hel & Hff & _ & Hfc & _ & _).
    cbn in Hcl. injection Hcl as <- <- <-.
    destruct (evar_fun_val _ _ _ _ _ _ _ _ _ Hev (PTree.gempty _ _)) as (lf & Hsy & ->).
    inv Hel. match goal with H : eval_exprlist _ _ _ _ nil _ _ |- _ => inv H end.
    match goal with Ht : eval_expr _ _ _ _ (Etempvar _ _) ?v1, Hc : Cop.sem_cast ?v1 _ _ _ = Some ?v2 |- _ =>
      apply ev_temp in Ht; rewrite PTree.gss in Ht; injection Ht as <-; rename Hc into Hcast end.
    apply (UC lf fd m _ _ m' vres Hsy Hff Hfc); [ | exact Hok ].
    intros bp op Ep.
    apply (ev_fld_any _ _ _ _ _ _ _ _ _ Mptr eq_refl) in Hv12 as (a & o & ofs & Hl & Hld).
    rewrite PTree.gss in Hl. injection Hl as ->.
    eapply ev_gvar with (ch := Mptr) in Hv11; [ | apply PTree.gempty | reflexivity ].
    destruct Hv11 as (ga & Hga & Hga_ld).
    cbn [Mem.loadv] in Hga_ld. change Mptr with Mint32 in Hga_ld. rewrite Ptrofs.unsigned_zero in Hga_ld.
    pose proof (Hsa ga a o Hga Hga_ld) as Sa.
    pose proof Hok as (_ & _ & HM).
    destruct v12; cbn in Hcast; try discriminate Hcast; injection Hcast as <-; try discriminate Ep.
    injection Ep as <- <-.
    exact (mwf_real_chase_step lp bm bc _ SafeB m a ofs _ _ HM Sa Hld).
  Qed.

  Theorem post_keeps : forall m m',
    uc_keeps lp bm MWF SafeB -> cam_phi_row lp bm MWF ->
    level_post_call lp m m' -> surf_apart lp bm level_gvars m ->
    mem_ok_lp bm MWF m -> phiw lp bm m ->
    mem_ok_lp bm MWF m' /\ phiw lp bm m'.
  Proof.
    intros m m' UC Hcam (le & t & le' & out & Hx) RSA Hok Hphi.
    pose proof (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 Hphi))))))) as LW0.
    pose proof (area_safe_of_w m (proj1 (proj2 (proj2 (proj2 (proj2 LW0)))))) as Hca.
    pose proof lv_plain as Hpl. repeat (apply andb_prop in Hpl as [Hpl ?]).
    rewrite post_eq in Hx.
    (* update_hud_values *)
    apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & Hh & Hx) | (Hh & Hout)];
      [ | exfalso; apply Hout; exact (plain_normal _ _ _ _ _ _ _ _ _ Hh ltac:(assumption)) ].
    destruct chk_hud as (Ch1 & Ch2).
    destruct (lv_stmt lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor lvl_safe_gvars sb_safe hud_ids lv_hud Ch1
                (hud_ids_lfun lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor)
                _ _ _ _ _ _ Hh Hok) as (Hok1 & Hfx1).
    pose proof (safe_keeps_phiw m m1 Hphi Hfx1 (cl_stmt G lv_hud Ch2 _ _ _ _ _ _ Hh)
                  (surf_apart_incl _ _ m safe_incl RSA)) as Hphi1.
    (* the camera: the labeled row *)
    apply seq_inv in Hx as [(t3 & le2 & m2 & t4 & Hc & Hx) | (Hc & Hout)];
      [ | exfalso; apply Hout; exact (plain_normal _ _ _ _ _ _ _ _ _ Hc ltac:(assumption)) ].
    assert (Hcs : cam_step lp m1 m2)
      by exact (ex_intro _ le1 (ex_intro _ t3 (ex_intro _ le2 (ex_intro _ Out_normal Hc)))).
    assert (Hca1 : cam_area_safe lp SafeB m1).
    { intros ga a o Hga Hl. apply (Hca ga a o Hga).
      rewrite <- Hl. symmetry. apply (fx_load lp bm lvl_safe_gvars m m1 Mint32 ga 0 Hfx1).
      intros i _ [Hb | (Hb & _)]; [ exact (not_lvl lvl_safe_gvars _ _ Hga ltac:(nb) Hb) | ].
      subst ga. refine (Genv.global_addresses_distinct G _ Hga Hbm_sym eq_refl); ne. }
    pose proof (cam_mem_ok UC m1 m2 Hcs Hok1 Hca1) as Hok2.
    destruct (Hcam m1 m2 Hcs Hok1 Hphi1 Hok2) as (Hphi2 & Hcells).
    assert (RSA2 : surf_apart lp bm level_gvars m2).
    { apply (surf_apart_move level_gvars m m2); [ | exact RSA ].
      intros off Hoff. rewrite (Hcells off Hoff). exact (fx_surf lvl_safe_gvars m m1 off ltac:(nb) Hfx1 Hoff). }
    (* initiate_painting_warp: its local only (Mario's floor is no painting) *)
    apply seq_inv in Hx as [(t5 & le3 & m3 & t6 & Hp & Hx) | (Hp & Hout)];
      [ | exfalso; apply Hout; exact (plain_normal _ _ _ _ _ _ _ _ _ Hp ltac:(assumption)) ].
    pose proof Hp as Hp0. rewrite lv_paint_eq in Hp0.
    destruct (lu_call0 _ _ _ _ _ _ _ _ dm_paint Hp0) as (tp & vp & Hfp).
    destruct (paint_noop G (lu_cenv lp H12) bm Hgp _ _ _ _ (fsafe m2 Hok2 Hphi2) Hfp) as (ma & bl & sz & Hal & Hfr).
    assert (Hfx3 : fx lp bm level_gvars m2 m3) by exact (fx_alloc_free lp bm level_gvars _ _ _ _ _ _ Hal Hfr).
    assert (Hok3 : OF m3).
    { apply (SaveDoSaveBody.harm_change lp bm bc oc0 SafeB Hspawn m2 m3 Hok2).
      pose proof (Mem.fresh_block_alloc _ _ _ _ _ Hal) as Hfr0.
      assert (U : Mem.unchanged_on (fun b' _ => Mem.valid_block m2 b') m2 m3).
      { eapply Mem.unchanged_on_trans.
        - eapply Mem.alloc_unchanged_on; exact Hal.
        - eapply Mem.free_unchanged_on; [ exact Hfr | ]. intros i _ Hv. exact (Hfr0 Hv). }
      eapply Mem.unchanged_on_implies; [ exact U | ]. intros b' z _ Hv. exact Hv. }
    pose proof (cl_stmt G lv_paint chk_paint _ _ _ _ _ _ Hp) as Hcl3.
    (* initiate_delayed_warp and the play-mode switch *)
    destruct chk_tail as (T1 & T2).
    destruct (lv_stmt lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor level_gvars sb_all lvl_calls lv_tail T1
                (lvl_calls_lfun lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor)
                _ _ _ _ _ _ Hx Hok3) as (Hok' & Hfx').
    pose proof (cl_stmt G lv_tail T2 _ _ _ _ _ _ Hx) as Hcl'.
    pose proof (fx_trans lp bm level_gvars _ _ _ Hfx3 Hfx') as Hfx4.
    (* warp_w at the tail's start (the painting call only allocates and
       frees its local), and at its end from the walked tail *)
    pose proof (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 (proj2 Hphi2))))))) as LW2.
    pose proof (proj1 (proj2 (proj2 (lvl_w_safe m2 m3 LW2
                  (fx_alloc_free lp bm lvl_safe_gvars _ _ _ _ _ _ Hal Hfr))))) as Hw3.
    destruct (lu_sym LU._sCurrPlayMode ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bp & Hbp).
    destruct (lu_sym LU._sWarpDest ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bw & Hbw).
    destruct (lu_sym LU._sTransitionTimer ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bt & Hbt).
    destruct (lu_sym LU._gCurrCreditsEntry ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bcr & Hbcr).
    destruct (lu_sym LU._gCurrDemoInput ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bd & Hbd).
    destruct (lu_sym LU._sDelayedWarpOp ltac:(let E := fresh in intro E; vm_compute in E; discriminate E)) as (bo & Hbo).
    pose proof (LevelWarp.tail_warp_w lp H12 bm bc oc0 SafeB HSafeB_syms Hspawn Hfloor Hbm_sym
                  bp bw bt bcr bd bo Hbp Hbw Hbt Hbcr Hbd Hbo _ _ _ _ _ _ Hx Hok3 Hw3 Hfx') as Hwend.
    split; [ exact Hok' | ].
    refine (lvl_keeps_gen level_gvars level_gvars_flank ltac:(nb) m2 m' Hphi2 Hfx4
              (cl_trans G _ _ _ Hcl3 Hcl') RSA2 _).
    exact (lvl_w_tail m2 m' LW2 Hfx4 Hwend).
  Qed.
End Link.
