(* spine (2026-11-02): the camera statement's footprint on PhiW states, from
   CamFootInst.update_camera_foot; HeightFrame derives the object-world
   globals' half of its camera row from it. *)
(* ====================================================================== *)
(* CamRows.v -- THE CAMERA STATEMENT'S FOOTPRINT.                         *)
(*                                                                        *)
(* THEOREM (cam_foot_step): the level's camera statement                   *)
(*   if (gCurrentArea != NULL) update_camera(gCurrentArea->camera);       *)
(* (LevelFlank.cam_step), run from a memory where FfWorld.cam_w holds      *)
(* (the Camera, its pins, R3), AudioInv holds (lvl_w's aud_w), every      *)
(* global is allocated, and gMarioState points into an FP global, either  *)
(* changes nothing, or keeps every permission and changes memory only in  *)
(* the blocks of CamFootTable's cf_FP / cf_XP globals, the Camera's 108   *)
(* bytes (a block past every global) and the camera pins' cells -- and    *)
(* AudioInv holds after.  The real update_camera is run through           *)
(* update_camera_foot (every state, no pruning).                          *)
(*                                                                        *)
(* COROLLARY (cam_ow_globals): the object world's globals (PollKeep.      *)
(* ow_ids) are none of those, so their blocks are unchanged.              *)
(*                                                                        *)
(* COROLLARY (cam_surf_keep): the surface clause of obj_w (ObjWorld.      *)
(* surf_obj_ok) is kept -- it reads its globals, the two surface pools'   *)
(* ranges and the listed slots' angle velocities, and R3 (cam_w) keeps    *)
(* the Camera's bytes off both pools.                                     *)
(* ====================================================================== *)

From Coq Require Import String ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Values AST Ctypes Clight ClightBigstep
  Memory Maps Globalenvs Linking Events Errors Clightdefs.
From SM64.Generated Require mario level_update camera.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor
  MathGeomGated Generic.PermWalk.
From SM64.Proofs.WMotRRequiresA Require Import CamFootKit CamFootSound CamFootTable CamFootInst
  RenderAnim.
From SM64.Proofs.WMotRRequiresA Require FfWorld AudioInv LevelFlank PollKeep FpuFloor ObjWorld FloorList BhvVM.
From SM64.Generated Require surface_load object_list_processor.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module LU := level_update.

(* the pins, by name *)
Lemma pin_cases : forall x c, pin_of x cf_pins = Some c ->
    (x = camera._gCamera /\ c = fC cf_SZ)
    \/ ((x = camera._sMarioCamState \/ x = camera._sLuigiCamState) /\ c = fF)
    \/ (x = camera._gSecondCameraFocus /\ c = fN)
    \/ (x = mario._gMarioState /\ c = fF).
Proof.
  intros x c H. unfold cf_pins in H. cbn [pin_of] in H.
  destruct (Pos.eqb $"gCamera" x) eqn:E1.
  { apply Pos.eqb_eq in E1. subst x. injection H as <-. left. split; reflexivity. }
  destruct (Pos.eqb $"sMarioCamState" x) eqn:E2.
  { apply Pos.eqb_eq in E2. subst x. injection H as <-. right; left. split; [ left | ]; reflexivity. }
  destruct (Pos.eqb $"sLuigiCamState" x) eqn:E3.
  { apply Pos.eqb_eq in E3. subst x. injection H as <-. right; left. split; [ right | ]; reflexivity. }
  destruct (Pos.eqb $"gSecondCameraFocus" x) eqn:E4.
  { apply Pos.eqb_eq in E4. subst x. injection H as <-. right; right; left. split; reflexivity. }
  destruct (Pos.eqb $"gMarioState" x) eqn:E5.
  { apply Pos.eqb_eq in E5. subst x. injection H as <-. right; right; right. split; reflexivity. }
  discriminate H.
Qed.

Lemma pcs_fp : mem_idf camera._gPlayerCameraState cf_FP = true.
Proof. vm_compute. reflexivity. Qed.

(* no object-world global is a footprint global or a pin *)
Lemma ow_not_fp : forallb (fun g => negb (mem_idf g cf_FP) && negb (mem_idf g cf_XP)
                                    && negb (mem_idf g (map fst cf_pins))) PollKeep.ow_ids = true.
Proof. vm_compute. reflexivity. Qed.

(* no script block (ObjWorld.scr_ok, ow_scr) is a footprint global or a pin *)
Lemma scr_not_fp : forallb (fun g => negb (mem_idf g cf_FP) && negb (mem_idf g cf_XP)
                                    && negb (mem_idf g (map fst cf_pins))) (map BhvVM.v_s BhvVM.vm_tab) = true.
Proof. vm_compute. reflexivity. Qed.

Section CR.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).

  (* the floors and the scoped audio contract update_camera_foot rests on *)
  Hypothesis Hsq : FpuFloor.sqrtf_spec.
  Hypothesis Hlsai : AudioInv.ls_frame_ai lp.
  Hypothesis Hfloor : os_dma_floor.

  Definition cam_fp (m m' : mem) : Prop :=
    m' = m
    \/ exists cb co, Ple (Genv.genv_next G) cb /\ PK m m'
       /\ Mem.unchanged_on (fun b z => ~ (FB0 G cf_FP b \/ FB0 G cf_XP b
                                         \/ (b = cb /\ co <= z < co + cf_SZ) \/ PCell G cf_pins b z)) m m'
       /\ AudioInv.AudioInv G m'
       (* R3 at the Camera the footprint names *)
       /\ (forall id n bs bp op, In (id, n) FfWorld.cam_pools -> Genv.find_symbol G id = Some bs ->
             Mem.load Mint32 m bs 0 = Some (Vptr bp op) ->
             bp <> cb \/ Ptrofs.unsigned op + n <= co \/ co + cf_SZ <= Ptrofs.unsigned op).

  Lemma fo_area_camera : forall co, (genv_cenv G) ! LU._Area = Some co ->
    field_offset G LU._camera (co_members co) = OK (36, Full).
  Proof.
    apply (fo_ok_lift (prog_comp_env LU.prog)); [ vm_compute; reflexivity | ].
    intros id c Hc. exact (linkorder_comp_env_extends lp LU.prog id c (linked12_LO_lvl lp H12) Hc).
  Qed.

  Theorem cam_foot_step : forall m m',
      LevelFlank.cam_step lp m m' ->
      FfWorld.cam_w G m -> AudioInv.AudioInv G m ->
      Ple (Genv.genv_next G) (Mem.nextblock m) ->
      (forall gb b o, Genv.find_symbol G mario._gMarioState = Some gb ->
         Mem.load Mint32 m gb 0 = Some (Vptr b o) -> FB0 G cf_FP b) ->
      cam_fp m m'.
  Proof.
    intros m m' (le & t & le' & out & Hx) CW AI Hgn Hgms.
    rewrite LevelFlank.lv_cam_eq in Hx.
    apply seq_inv in Hx as [(t1 & le1 & m1 & t2 & Hs & Hx) | (Hs & Hout)].
    2: { apply set_inv in Hs as (_ & _ & _ & _ & Ho). congruence. }
    apply set_inv in Hs as (v10 & _ & -> & -> & _).
    apply if_inv in Hx as (vc & bb & _ & _ & Hx).
    destruct bb.
    2: { apply skip_inv in Hx as (-> & _). left. reflexivity. }
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
    (* the argument: gCurrentArea->camera *)
    pose proof (fun Ham => ev_fld G empty_env m _ _ LU._Area LU._camera _ v12 Mint32 36 fo_area_camera Ham Hv12) as Hfl.
    specialize (Hfl eq_refl).
    destruct Hfl as (a & o & Hl & Hld).
    rewrite PTree.gss in Hl. injection Hl as Ea.
    eapply ev_gvar with (ch := Mptr) in Hv11; [ | apply PTree.gempty | reflexivity ].
    destruct Hv11 as (ga & Hga & Hga_ld).
    cbn [Mem.loadv] in Hga_ld. change Mptr with Mint32 in Hga_ld. rewrite Ptrofs.unsigned_zero in Hga_ld.
    subst v11.
    destruct CW as (_ & CA & (Pcam & Pcs & Psf)).
    destruct (CA ga a o Hga Hga_ld) as (cb & co & Lc & Hcbg & _ & (n & Lcut & _) & Hco & R3).
    cbn [Mem.loadv] in Hld.
    rewrite Lc in Hld. injection Hld as <-.
    (* the cast keeps the pointer *)
    apply cast_ptr_id in Hcast. subst.
    (* the footprint theorem's premises *)
    assert (HSZ : 0 <= Ptrofs.unsigned co /\ Ptrofs.unsigned co + cf_SZ <= Ptrofs.max_unsigned).
    { pose proof (Ptrofs.unsigned_range co). unfold FfWorld.CAM_SZ in Hco. unfold cf_SZ. lia. }
    assert (Hsym : forall g b, Genv.find_symbol G g = Some b -> Plt b (Genv.genv_next G)).
    { intros g b Hs. exact (Genv.genv_symb_range _ _ Hs). }
    assert (Hgcb : forall g b, Genv.find_symbol G g = Some b -> b <> cb).
    { intros g b Hs E. subst b. exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Hsym _ _ Hs) Hcbg)). }
    assert (Hcb : Plt cb (Mem.nextblock m)).
    { apply Mem.load_valid_access in Lcut. apply (Mem.valid_access_valid_block _ _ _ _ (Mem.valid_access_implies _ _ _ _ _ _ Lcut (perm_any_N _))). }
    assert (HG : forall g bg, Genv.find_symbol G g = Some bg -> Plt bg (Mem.nextblock m)).
    { intros g bg Hs. exact (Plt_Ple_trans _ _ _ (Hsym _ _ Hs) Hgn). }
    assert (Hpins : Pins G cf_FP cf_pins cb (Ptrofs.unsigned co) cf_SZ (Mem.nextblock m) (AudioInv.AudioInv G) m).
    { split; [ | exact AI ].
      intros x c b Hp Hs v Hl bb oo Ev. subst v.
      destruct (pin_cases x c Hp) as [(-> & ->) | [(Hx & ->) | [(-> & ->) | (-> & ->)]]].
      - destruct (Pcam b Hs bb oo Hl) as (ga' & bad' & o' & Hga' & Hl1 & Hl2).
        rewrite Hga in Hga'. injection Hga' as <-. rewrite Hga_ld in Hl1. injection Hl1 as <- <-.
        rewrite Lc in Hl2. injection Hl2 as <- <-.
        cbn [fpc]. split; [ reflexivity | lia ].
      - pose proof (Pcs x b ltac:(destruct Hx as [-> | ->]; cbn; auto) Hs bb oo Hl) as Hpc.
        cbn [fpc]. left. exists camera._gPlayerCameraState. split; [ exact pcs_fp | exact Hpc ].
      - exact (Psf b Hs bb oo Hl).
      - cbn [fpc]. left. exact (Hgms b bb oo Hs Hl). }
    destruct (update_camera_foot lp H12 Hsq Hlsai cb (Ptrofs.unsigned co) HSZ Hgcb Hfloor
                lf fd m (Vptr cb co) t6 m' vres Hsy Hff Hfc
                ltac:(intros bb oo E; injection E as <- <-; split; reflexivity)
                Hcb HG Hpins) as (PKm & U & (_ & AI')).
    right. exists cb, (Ptrofs.unsigned co).
    exact (conj Hcbg (conj PKm (conj U (conj AI' R3)))).
  Qed.

  (* a list of globals none of which is a footprint global or a pin: their
     blocks are unchanged *)
  Lemma cam_globals_of : forall L,
      forallb (fun g => negb (mem_idf g cf_FP) && negb (mem_idf g cf_XP)
                        && negb (mem_idf g (map fst cf_pins))) L = true ->
      forall m m', cam_fp m m' ->
      Ple (Genv.genv_next G) (Mem.nextblock m) ->
      forall id b, In id L -> Genv.find_symbol G id = Some b ->
      forall ch z, Mem.load ch m' b z = Mem.load ch m b z.
  Proof.
    intros L HL m m' [-> | (cb & co & Hcbg & _ & U & _ & _)] Hgn id b Hin Hs ch z; [ reflexivity | ].
    pose proof (proj1 (forallb_forall _ _) HL id Hin) as E. cbv beta in E.
    apply andb_prop in E as [E E3]. apply andb_prop in E as [E1 E2].
    apply negb_true_iff in E1, E2, E3.
    assert (Hlt : Plt b (Genv.genv_next G)) by exact (Genv.genv_symb_range _ _ Hs).
    apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U).
    - unfold Mem.valid_block. exact (Plt_Ple_trans _ _ _ Hlt Hgn).
    - intros i _ [(g & Hg & Hsg) | [(g & Hg & Hsg) | [(Eb & _) | (x & c & Hp & Hsx & _)]]].
      + assert (g = id) by (eapply Genv.genv_vars_inj; eassumption). subst g. congruence.
      + assert (g = id) by (eapply Genv.genv_vars_inj; eassumption). subst g. congruence.
      + subst b. exact (Plt_strict _ (Plt_Ple_trans _ _ _ Hlt Hcbg)).
      + assert (x = id) by (eapply Genv.genv_vars_inj; eassumption). subst x.
        rewrite (In_mem_idf _ _ (pin_of_in _ _ _ Hp)) in E3. discriminate E3.
  Qed.

  (* THE OBJECT WORLD'S GLOBALS: their blocks are none of the footprint's *)
  Theorem cam_ow_globals : forall m m', cam_fp m m' ->
      Ple (Genv.genv_next G) (Mem.nextblock m) ->
      forall id b, In id PollKeep.ow_ids -> Genv.find_symbol G id = Some b ->
      forall ch z, Mem.load ch m' b z = Mem.load ch m b z.
  Proof. exact (cam_globals_of PollKeep.ow_ids ow_not_fp). Qed.

  (* THE SCRIPTS (ow_scr, 2026-11-03): no script block is written *)
  Theorem cam_scr_globals : forall m m', cam_fp m m' ->
      Ple (Genv.genv_next G) (Mem.nextblock m) ->
      forall id b, In id (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol G id = Some b ->
      forall ch z, Mem.load ch m' b z = Mem.load ch m b z.
  Proof. exact (cam_globals_of (map BhvVM.v_s BhvVM.vm_tab) scr_not_fp). Qed.

  (* a load off the changed cells is unchanged (an invalid block stays
     without permissions, PK) *)
  Lemma ld_keep : forall (Q : block -> Z -> Prop) m m' b ch z, PK m m' -> Mem.unchanged_on Q m m' ->
    (forall i, z <= i < z + size_chunk ch -> Q b i) -> Mem.load ch m' b z = Mem.load ch m b z.
  Proof.
    intros Q m m' b ch z (_ & _ & Pinv) U HQ.
    destruct (plt b (Mem.nextblock m)) as [V | NV].
    - exact (Mem.load_unchanged_on_1 _ _ _ _ _ _ U V HQ).
    - assert (Lm : Mem.load ch m b z = None).
      { destruct (Mem.load ch m b z) eqn:L; [ | reflexivity ]. exfalso. apply NV.
        apply Mem.load_valid_access in L.
        exact (Mem.valid_access_valid_block _ _ _ _ (Mem.valid_access_implies _ _ _ _ _ _ L (perm_any_N _))). }
      rewrite Lm. destruct (Mem.load ch m' b z) eqn:L; [ | reflexivity ]. exfalso.
      apply Mem.load_valid_access in L. destruct L as (Hr & _).
      apply (Pinv b z Cur Readable NV). apply Hr. pose proof (size_chunk_pos ch). lia.
  Qed.

  (* THE SURFACE CLAUSE: kept by the camera statement (with R3) *)
  Theorem cam_surf_keep : forall m m', cam_fp m m' ->
      Ple (Genv.genv_next G) (Mem.nextblock m) -> PollKeep.surf_keep m m' G.
  Proof.
    intros m m' Hc Hgn. pose proof (cam_ow_globals m m' Hc Hgn) as KG.
    destruct Hc as [-> | (cb & co & Hcbg & PKm & U & _ & R3)].
    { intros pool _ C. exact C. }
    intros pool Hpool Cso.
    apply (ObjWorld.surf_obj_ok_ext G pool m m'); [ | | | exact Cso ].
    - intros id b Hin Hs ch z. apply (KG id b); [ | exact Hs ].
      unfold ObjWorld.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin.
      unfold PollKeep.ow_ids.
      destruct Hin as [<- | [<- | [<- | [<- | []]]]]; cbn [In]; repeat (first [ left; reflexivity | right ]).
    - intros P HP (bs1 & Hs1 & L1) (bs2 & Hs2 & L2) ch z Hz.
      pose proof (R3 surface_load._sSurfacePool 110400 bs1 P (Ptrofs.repr ObjWorld.SP_OFF)
                    (or_introl eq_refl) Hs1 L1) as R1.
      pose proof (R3 surface_load._sSurfaceNodePool 56000 bs2 P (Ptrofs.repr ObjWorld.NP_OFF)
                    (or_intror (or_introl eq_refl)) Hs2 L2) as R2.
      assert (U1 : Ptrofs.unsigned (Ptrofs.repr ObjWorld.SP_OFF) = ObjWorld.SP_OFF) by reflexivity.
      assert (U2 : Ptrofs.unsigned (Ptrofs.repr ObjWorld.NP_OFF) = ObjWorld.NP_OFF) by reflexivity.
      rewrite U1 in R1. rewrite U2 in R2.
      apply (ld_keep _ m m' P ch z PKm U). intros i Hi.
      intros [(g & _ & Hg) | [(g & _ & Hg) | [(Eb & Hr) | (x & c & _ & Hg & _)]]].
      + exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hg) HP)).
      + exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hg) HP)).
      + subst P.
        destruct R1 as [R1 | R1]; [ exact (R1 eq_refl) | ].
        destruct R2 as [R2 | R2]; [ exact (R2 eq_refl) | ].
        unfold ObjWorld.NP_END, ObjWorld.SP_END, ObjWorld.NP_OFF, ObjWorld.SP_OFF, ObjWorld.NP_CAP,
          ObjWorld.SP_CAP, ObjWorld.SNODE_SZ, ObjWorld.SURF_SZ, cf_SZ in *.
        lia.
      + exact (Plt_strict _ (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hg) HP)).
    - intros k j _ _. apply (KG object_list_processor._gObjectPool pool); [ | exact Hpool ].
      unfold PollKeep.ow_ids. cbn [In]. left. reflexivity.
  Qed.
End CR.
