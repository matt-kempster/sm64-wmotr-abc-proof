(* ===================================================================== *)
(* MplatKeep (GOAL 2): the object phase's update_mario_platform call,     *)
(* PROVED from the real code (2026-11-03).                                *)
(*                                                                       *)
(* platform_displacement.c:31-56 (MplatRun.mplat_run inverts the          *)
(* generated body): two locals; when gMarioObject is NULL nothing is      *)
(* stored; otherwise find_floor(x, y, z, &floor) runs and ONE value X is  *)
(* stored into gMarioPlatform and into gMarioObject->platform (offset     *)
(* 532): NULL, or floor->object.                                          *)
(*                                                                       *)
(* What the proof reads off that trace:                                   *)
(*   - find_floor's own effect: FloorList.ff_value_contract (the floor it *)
(*     reports is NULL or a surface on a partition list; it writes only   *)
(*     *pfloor and its three static cells, no permission changes) and     *)
(*     UcKit's class walk (GOAL 1's mem_ok, find_floor tabled as in the  *)
(*     camera walk);                                                      *)
(*   - floor->object: ObjWorld.ow_surf_obj (every surface on a partition  *)
(*     list is a sSurfacePool slot whose object is NULL or a gObjectPool  *)
(*     slot with zero angle velocity): so X is NULL or such an object,    *)
(*     and gMarioPlatform's fact (PlatformKeep.plat_still) is re-made;    *)
(*   - gMarioObject->platform: obj_w's ow_mario (gMarioObject is Mario's  *)
(*     pool slot), so the second store lands in Mario's slot's field      *)
(*     [532, 536), which no obj_w clause (PollKeep.SKp) and no PhiW      *)
(*     clause (RenderKeep.owin) reads.                                    *)
(* No premise beyond the object phase's invariant Pobjl.                  *)
(* PHANTOM CHECK: the theorem is over every memory the object phase can  *)
(* hold (Pobjl: mem_ok, PhiW, a_down, plat_still, obj_w); nothing is     *)
(* quantified that the game does not produce: the floor, its object and  *)
(* gMarioObject are all read off the real memory.                         *)
(* ===================================================================== *)
From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require platform_displacement surface_collision object_helpers
  object_list_processor level_update mario.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates UcKit.
From SM64.Proofs Require NoAImpliesNoFlyTwelve ObjExtBodies SpawnBodies.
From SM64.Proofs Require Import Generic.PermWalk Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Import HeightInvariant WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep FloorList MplatRun.
From SM64.Proofs.WMotRRequiresA Require ObjWorld PollKeep PlatformKeep ObjPhase BhvVM ObjLoop.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.
Module OLP := object_list_processor.

(* ---------------------------------------------------------------------- *)
(* 0. Generic pieces.                                                      *)
(* ---------------------------------------------------------------------- *)

(* a partition list the surface clause walks is a well-formed list *)
Lemma swalk_wf : forall P m (A : block -> Prop), Mem.valid_block m P -> ~ A P ->
  forall f hd l, OW.swalk P m f hd = Some l -> wf_list m A hd.
Proof.
  intros P m A Hv Ha. induction f as [| f IH]; intros hd l Hw; [ discriminate Hw | ].
  cbn [OW.swalk] in Hw. destruct hd; try discriminate Hw.
  - destruct (Int.eq i Int.zero) eqn:E; [ | discriminate Hw ].
    apply Int.same_if_eq in E. subst i. constructor.
  - destruct (Pos.eqb b P && OW.in_np (Ptrofs.unsigned i)) eqn:E; [ | discriminate Hw ].
    apply andb_prop in E as [E _]. apply Pos.eqb_eq in E. subst b.
    rewrite !OW.CM.load_eq in Hw.
    destruct (Mem.load Mint32 m P (Ptrofs.unsigned (Ptrofs.add i (Ptrofs.repr SN_SURF)))); [ | discriminate Hw ].
    destruct (Mem.load Mint32 m P (Ptrofs.unsigned (Ptrofs.add i (Ptrofs.repr SN_NEXT)))) as [nx |] eqn:Ln;
      [ | discriminate Hw ].
    destruct (OW.swalk P m f nx) as [l' |] eqn:Hw'; [ | discriminate Hw ].
    eapply wf_cons; [ exact Hv | exact Ha | cbn [Mem.loadv]; exact Ln | exact (IH _ _ Hw') ].
Qed.

(* a free_list leaves every other block's loads *)
Lemma fl_load_other : forall l m m' ch b z, Mem.free_list m l = Some m' ->
  (forall lo hi, ~ In (b, lo, hi) l) -> Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  induction l as [ | [[b0 lo0] hi0] l IH ]; intros m m' ch b z Hf Hn; cbn in Hf.
  - injection Hf as <-. reflexivity.
  - destruct (Mem.free m b0 lo0 hi0) as [m1|] eqn:E; [ | discriminate Hf ].
    rewrite (IH m1 m' ch b z Hf (fun lo hi Hin => Hn lo hi (or_intror Hin))).
    eapply Mem.load_free; [ exact E | ]. left. intros ->. exact (Hn lo0 hi0 (or_introl eq_refl)).
Qed.

(* the call's permissions: two fresh locals around a permission-keeping
   middle, both freed *)
Lemma call2_pk : forall m mA bF m1 bX m3 m',
  Mem.alloc m 0 4 = (mA, bF) -> Mem.alloc mA 0 4 = (m1, bX) -> PK m1 m3 ->
  Mem.free_list m3 [(bX, 0, 4); (bF, 0, 4)] = Some m' -> PK m m'.
Proof.
  intros m mA bF m1 bX m3 m' A1 A2 (N3 & P3 & F3) Hf.
  pose proof (Mem.fresh_block_alloc _ _ _ _ _ A1) as Fb.
  assert (Fx : ~ Mem.valid_block m bX)
    by (intro V; exact (Mem.fresh_block_alloc _ _ _ _ _ A2 (Mem.valid_block_alloc _ _ _ _ _ A1 _ V))).
  assert (VA : forall b, Mem.valid_block m b -> Mem.valid_block m1 b)
    by (intros b V; exact (Mem.valid_block_alloc _ _ _ _ _ A2 _ (Mem.valid_block_alloc _ _ _ _ _ A1 _ V))).
  split; [ | split ].
  - rewrite (fl_next _ _ _ Hf). eapply Ple_trans; [ | exact N3 ].
    rewrite (Mem.nextblock_alloc _ _ _ _ _ A2), (Mem.nextblock_alloc _ _ _ _ _ A1).
    eapply Ple_trans; [ apply Ple_succ | apply Ple_succ ].
  - intros b o k p Hv.
    assert (NF : b <> bF) by (intros ->; exact (Fb Hv)).
    assert (NX : b <> bX) by (intros ->; exact (Fx Hv)).
    split; intros Hp.
    + apply (fl_keep _ _ _ _ _ _ _ Hf).
      { intros lo hi [E | [E | []]]; injection E as -> _ _; [ exact (NX eq_refl) | exact (NF eq_refl) ]. }
      apply (P3 b o k p (VA b Hv)).
      exact (Mem.perm_alloc_1 _ _ _ _ _ A2 _ _ _ _ (Mem.perm_alloc_1 _ _ _ _ _ A1 _ _ _ _ Hp)).
    + pose proof (fl_back _ _ _ _ _ _ _ Hf Hp) as Hp3.
      apply (P3 b o k p (VA b Hv)) in Hp3.
      exact (Mem.perm_alloc_4 _ _ _ _ _ A1 _ _ _ _ (Mem.perm_alloc_4 _ _ _ _ _ A2 _ _ _ _ Hp3 NX) NF).
  - intros b o k p Hv Hp.
    pose proof (fl_back _ _ _ _ _ _ _ Hf Hp) as Hp3.
    destruct (plt b (Mem.nextblock m1)) as [V1 | V1]; [ | exact (F3 b o k p V1 Hp3) ].
    apply (P3 b o k p V1) in Hp3.
    destruct (peq b bX) as [-> | NX].
    + pose proof (Mem.perm_alloc_3 _ _ _ _ _ A2 _ _ _ Hp3) as R.
      exact (fl_kill _ _ _ _ _ _ _ _ _ Hf (or_introl eq_refl) R Hp).
    + pose proof (Mem.perm_alloc_4 _ _ _ _ _ A2 _ _ _ _ Hp3 NX) as HpA.
      destruct (peq b bF) as [-> | NF].
      * pose proof (Mem.perm_alloc_3 _ _ _ _ _ A1 _ _ _ HpA) as R.
        exact (fl_kill _ _ _ _ _ _ _ _ _ Hf (or_intror (or_introl eq_refl)) R Hp).
      * exact (Hv (Mem.perm_valid_block _ _ _ _ _ (Mem.perm_alloc_4 _ _ _ _ _ A1 _ _ _ _ HpA NF))).
Qed.

(* a fresh block has no loads past a PK step *)
Lemma pk_load_fresh : forall m m' ch b z, PK m m' -> ~ Mem.valid_block m b ->
  Mem.load ch m' b z = Mem.load ch m b z.
Proof.
  intros m m' ch b z (_ & _ & F) Hv.
  destruct (Mem.load ch m b z) eqn:E.
  - exfalso. apply Hv. apply Mem.load_valid_access in E.
    eapply Mem.valid_access_valid_block. eapply Mem.valid_access_implies; [ exact E | constructor ].
  - destruct (Mem.load ch m' b z) eqn:E'; [ | reflexivity ].
    exfalso. apply Mem.load_valid_access in E' as (Hr & _).
    apply (F b z Cur Readable Hv). apply Hr. pose proof (size_chunk_pos ch). lia.
Qed.

Lemma uadd : forall z d, 0 <= z -> 0 <= d -> z + d <= Ptrofs.max_unsigned ->
  Ptrofs.unsigned (Ptrofs.add (Ptrofs.repr z) (Ptrofs.repr d)) = z + d.
Proof.
  intros z d H0 H1 H2. unfold Ptrofs.add.
  rewrite (Ptrofs.unsigned_repr z) by lia. rewrite (Ptrofs.unsigned_repr d) by lia.
  apply Ptrofs.unsigned_repr. lia.
Qed.

Lemma dm_umop : (prog_defmap PD.prog) ! OLP._update_mario_platform
  = Some (Gfun (Internal PD.f_update_mario_platform)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ff : (prog_defmap SC.prog) ! PD._find_floor = Some (Gfun (Internal SC.f_find_floor)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_ffl : (prog_defmap SC.prog) ! SC._find_floor_from_list
  = Some (Gfun (Internal SC.f_find_floor_from_list)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_absf : (prog_defmap OH.prog) ! PD._absf = Some (Gfun (Internal OH.f_absf)).
Proof. vm_compute. reflexivity. Qed.
Lemma dm_gmo : (prog_defmap PD.prog) ! PD._gMarioObject = Some (Gvar PD.v_gMarioObject).
Proof. vm_compute. reflexivity. Qed.

(* the written globals: find_floor's three statics and gMarioPlatform *)
Definition mp_gvars : list ident := ff_statics ++ [PD._gMarioPlatform].

(* find_floor in UcKit's class table (as in the camera walk) *)
Definition ff_ut : utab :=
  [(SC._find_floor, ([kN; kN; kN; kT], kN, false));
   (SC._find_floor_from_list, ([kS; kN; kN; kN; kL], kS, false))].
Lemma uc_ff : uchk camera_safe_syms ff_ut [] ([kN; kN; kN; kT], kN, false) SC.f_find_floor = true.
Proof. vm_compute. reflexivity. Qed.
Lemma uc_ffl : uchk camera_safe_syms ff_ut [] ([kS; kN; kN; kN; kL], kS, false) SC.f_find_floor_from_list = true.
Proof. vm_compute. reflexivity. Qed.

Lemma swalk_wf2 : forall P m (A : block -> Prop), (Mem.valid_block m P -> ~ A P) ->
  forall f hd l, OW.swalk P m f hd = Some l -> wf_list m A hd.
Proof.
  intros P m A Ha. induction f as [| f IH]; intros hd l Hw; [ discriminate Hw | ].
  cbn [OW.swalk] in Hw. destruct hd; try discriminate Hw.
  - destruct (Int.eq i Int.zero) eqn:E; [ | discriminate Hw ].
    apply Int.same_if_eq in E. subst i. constructor.
  - destruct (Pos.eqb b P && OW.in_np (Ptrofs.unsigned i)) eqn:E; [ | discriminate Hw ].
    apply andb_prop in E as [E _]. apply Pos.eqb_eq in E. subst b.
    rewrite !OW.CM.load_eq in Hw.
    destruct (Mem.load Mint32 m P (Ptrofs.unsigned (Ptrofs.add i (Ptrofs.repr SN_SURF)))); [ | discriminate Hw ].
    destruct (Mem.load Mint32 m P (Ptrofs.unsigned (Ptrofs.add i (Ptrofs.repr SN_NEXT)))) as [nx |] eqn:Ln;
      [ | discriminate Hw ].
    destruct (OW.swalk P m f nx) as [l' |] eqn:Hw'; [ | discriminate Hw ].
    assert (Hv : Mem.valid_block m P).
    { apply Mem.load_valid_access in Ln. eapply Mem.valid_access_valid_block.
      eapply Mem.valid_access_implies; [ exact Ln | constructor ]. }
    eapply wf_cons; [ exact Hv | exact (Ha Hv) | cbn [Mem.loadv]; exact Ln | exact (IH _ _ Hw') ].
Qed.

(* a well-formed list survives a step that keeps its old blocks *)
Lemma wf_list_move : forall m m1 (A A1 : block -> Prop) hd, wf_list m A hd ->
  (forall b, Mem.valid_block m b -> Mem.valid_block m1 b) ->
  (forall ch b z, Mem.valid_block m b -> Mem.load ch m1 b z = Mem.load ch m b z) ->
  (forall b, Mem.valid_block m b -> ~ A b -> ~ A1 b) -> wf_list m1 A1 hd.
Proof.
  intros m m1 A A1 hd W HV HL HA. induction W as [| bn on nx Hv Hav Hld W IH]; [ constructor | ].
  eapply wf_cons; [ exact (HV _ Hv) | exact (HA _ Hv Hav) | | exact IH ].
  cbn [Mem.loadv] in *. rewrite (HL _ _ _ Hv). exact Hld.
Qed.

Section MK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation u := Ptrofs.unsigned.

  Lemma Hsp : exists init, spawn_ok lp init bm bc oc0.
  Proof. exact (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0). Qed.
  Lemma Hbc_bm : bc <> bm.
  Proof. destruct Hsp as (init & Hs). exact (spawn_Hbc_bm lp init bm bc oc0 Hs). Qed.

  (* ---- the link ---- *)
  Lemma ffr : forall b fd, Genv.find_symbol G PD._find_floor = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SC.f_find_floor.
  Proof. exact (ObjPhase.fun_of lp SC.prog _ _ (linked12_LO_surf lp H12) dm_ff). Qed.
  Lemma abr : forall b fd, Genv.find_symbol G PD._absf = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal OH.f_absf.
  Proof. exact (ObjPhase.fun_of lp OH.prog _ _ (linked12_LO_object_helpers lp H12) dm_absf). Qed.
  Lemma fflr : forall b fd, Genv.find_symbol G SC._find_floor_from_list = Some b ->
    Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> fd = Internal SC.f_find_floor_from_list.
  Proof. exact (ObjPhase.fun_of lp SC.prog _ _ (linked12_LO_surf lp H12) dm_ffl). Qed.

  Lemma ffl_pin : ffl_pinned G.
  Proof.
    intros bf f Hs Hf. apply (fflr bf f Hs). rewrite Genv.find_funct_find_funct_ptr. exact Hf.
  Qed.

  Lemma cenv_G : cenv_has G.
  Proof.
    intros id co Hco. unfold lp_ge, globalenv. cbn [genv_cenv].
    exact (linkorder_comp_env_extends lp SC.prog id co (linked12_LO_surf lp H12) Hco).
  Qed.

  Lemma gmo_sym : exists b, Genv.find_symbol G PD._gMarioObject = Some b.
  Proof. exact (linkorder_resolves_symbol lp PD.prog _ _ (linked12_LO_platform_displacement lp H12) dm_gmo). Qed.

  (* the camera's SafeB pointer globals *)
  Lemma cam_gs : forall x b, mem_id x camera_safe_syms = true -> Genv.find_symbol G x = Some b -> SafeB b.
  Proof.
    intros x b H Hs. destruct HSafeB_syms as (_ & _ & Hc). apply (Hc x b); [ | exact Hs ].
    unfold camera_safe_syms in H. cbn [mem_id existsb] in H.
    repeat (apply orb_true_iff in H as [E | H];
            [ apply Pos.eqb_eq in E; subst x; vm_compute; reflexivity | ]).
    discriminate H.
  Qed.

  Lemma ff_tab : TabGood lp camera_safe_syms ff_ut [] (fun _ _ => False).
  Proof.
    intros fid s Hf b fd Hs Hff. left.
    unfold ff_ut, ut_find in Hf. cbn [find fst] in Hf.
    repeat match type of Hf with
    | context [Pos.eqb ?g fid] =>
        let E := fresh "E" in
        destruct (Pos.eqb g fid) eqn:E; cbv beta iota in Hf;
        [ apply Pos.eqb_eq in E; subst fid; injection Hf as <- | ]
    end; [ | | discriminate Hf ].
    - exists SC.f_find_floor. split; [ exact (ffr b fd Hs Hff) | exact uc_ff ].
    - exists SC.f_find_floor_from_list. split; [ exact (fflr b fd Hs Hff) | exact uc_ffl ].
  Qed.

  Lemma ff_it : ItGood lp camera_safe_syms ff_ut [] (fun _ _ => False).
  Proof. intros ty s Hf. discriminate Hf. Qed.

  (* ---- GOAL 1's facts across the pieces ---- *)
  Lemma of_alloc : forall m lo hi m' b, Mem.alloc m lo hi = (m', b) ->
    mem_ok_lp bm MWF m -> mem_ok_lp bm MWF m'.
  Proof.
    intros m lo hi m' b Ha (Hv & Hs & HM).
    split; [ exact (Mem.valid_block_alloc _ _ _ _ _ Ha _ Hv) | split ].
    - intros v Hl. apply Hs. rewrite <- Hl. symmetry. exact (Mem.load_alloc_unchanged _ _ _ _ _ Ha _ _ _ Hv).
    - exact (mwf_real_alloc lp bm bc oc0 SafeB Hbc_bm m lo hi m' b Ha HM).
  Qed.

  Lemma of_free : forall m l m', Mem.free_list m l = Some m' ->
    mem_ok_lp bm MWF m -> mem_ok_lp bm MWF m'.
  Proof.
    intros m l m' Hf (Hv & Hs & HM).
    split; [ eapply free_list_valid_1; eassumption | split ].
    - intros v Hl. apply Hs. eapply free_list_load_2; eassumption.
    - exact (mwf_real_free lp bm bc oc0 SafeB Hbc_bm m m' l Hf HM).
  Qed.

  Lemma mo_off : field_offset (prog_comp_env mario.prog) mario._marioObj mario_state_members = OK (136, Full).
  Proof. vm_compute. reflexivity. Qed.
  Lemma mo_root : mem_id mario._marioObj chase_root_fields = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma part_static : forall id, In id part_ids -> In id ff_statics -> False.
  Proof.
    intros id H1 H2. unfold part_ids in H1. cbn [In] in H1.
    destruct H1 as [<- | [<- | []]]; vm_compute in H2; intuition discriminate.
  Qed.

  Lemma static_ids : forall b id, is_static G b -> Genv.find_symbol G id = Some b -> In id ff_statics.
  Proof.
    intros b id (id' & Hin & Hs') Hs.
    assert (E : id = id') by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hs' ]). subst id'. exact Hin.
  Qed.

  (* not a static: decided on the identifier *)
  Lemma not_static : forall id b, Genv.find_symbol G id = Some b ->
    existsb (Pos.eqb id) ff_statics = false -> ~ is_static G b.
  Proof.
    intros id b Hs Hn Hst. pose proof (static_ids b id Hst Hs) as Hin.
    assert (E : existsb (Pos.eqb id) ff_statics = true)
      by (apply existsb_exists; exists id; split; [ exact Hin | apply Pos.eqb_refl ]).
    congruence.
  Qed.

  Lemma sym_ne : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    Pos.eqb id1 id2 = false -> b1 <> b2.
  Proof.
    intros id1 id2 b1 b2 H1 H2 Hn E. subst b2.
    assert (E : id1 = id2) by (eapply Genv.genv_vars_inj; [ exact H1 | exact H2 ]).
    subst id2. rewrite Pos.eqb_refl in Hn. discriminate Hn.
  Qed.

  Lemma lr32 : forall v, (v = Vint Int.zero \/ exists b o, v = Vptr b o) -> Val.load_result Mint32 v = v.
  Proof. intros v [-> | (b & o & ->)]; reflexivity. Qed.

  (* ---- THE EFFECT ---- *)
  Theorem mplat_eff : forall m t m' vr,
    eval_funcall function_entry2 G m (Internal PD.f_update_mario_platform) [] t m' vr ->
    mem_ok_lp bm MWF m -> OW.obj_w G bm m ->
    mem_ok_lp bm MWF m' /\ PK m m'
    /\ exists pool k, Genv.find_symbol G OLP._gObjectPool = Some pool /\ 0 <= k < OW.NSLOT
      /\ Mem.load Mint32 m bm MARIOOBJ_OFF = Some (OW.slot_v pool k)
      /\ forall bgp, Genv.find_symbol G PD._gMarioPlatform = Some bgp ->
           (forall ch b z, ~ is_static G b -> b <> bgp ->
              (b <> pool \/ z + size_chunk ch <= k * OW.OSZ + 532 \/ k * OW.OSZ + 536 <= z) ->
              Mem.load ch m' b z = Mem.load ch m b z)
           /\ ((forall ch b z, Mem.load ch m' b z = Mem.load ch m b z)
               \/ forall v, Mem.load Mint32 m' bgp 0 = Some v ->
                    v = Vint Int.zero
                    \/ exists k', 0 <= k' < OW.NSLOT /\ v = OW.slot_v pool k'
                         /\ forall j, In j OW.ANGV ->
                              Mem.load Mint32 m pool (k' * OW.OSZ + RAW_OFF + 4 * j) = Some (Vint Int.zero)).
  Proof.
    intros m t m' vr Hev Hok How.
    destruct (PlatformKeep.plat_p_sym lp H12) as (bgp & Hgp).
    destruct gmo_sym as (bgmo & Hgmo).
    pose proof How as (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    assert (Egmo : gmo = bgmo) by (change OLP._gMarioObject with PD._gMarioObject in S5; congruence).
    subst gmo.
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (k & Hk & Lg & Lb & _).
    pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) as Cr.
    assert (H0 : (0 < OW.NLIST)%nat) by (unfold OW.NLIST; lia).
    destruct (ObjLoop.ring_i_spec _ _ _ _ _ (ObjLoop.rings_nth _ _ _ _ Cr 0 H0)) as (_ & Hall).
    destruct (Hall k Hk) as (Rk & _).
    pose proof (OW.ow_surf_obj _ _ _ _ _ _ _ _ _ _ _ _ C) as (P & HP & _ & _ & SW).
    pose proof Hok as (Hvb & _ & HM).
    pose proof (mwf_real_nextbound lp bm bc oc0 SafeB m HM) as Hgn.
    assert (Gv : forall id b, Genv.find_symbol G id = Some b -> Mem.valid_block m b)
      by exact (glob_valid_of_nextbound lp m Hgn).
    assert (Uk : u (Ptrofs.repr (k * OW.OSZ)) = k * OW.OSZ)
      by (apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
    assert (SBp : SafeB pool).
    { refine (mwf_real_chase_root lp bm bc oc0 SafeB _ 136 m pool (Ptrofs.repr (k * OW.OSZ)) mo_root mo_off HM _).
      cbn [Mem.loadv]. rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr by (change Ptrofs.max_unsigned with 4294967295; lia). exact Lb. }
    destruct (mplat_run G (PlatformKeep.plat_cenv lp H12) bgp bgmo Hgp Hgmo ffr abr m t m' vr Hev)
      as (bF & bX & mA & m1 & m3 & A1 & A2 & FLs & Tr).
    pose proof (Mem.fresh_block_alloc _ _ _ _ _ A1) as FbF.
    assert (FbX : ~ Mem.valid_block m bX)
      by (intro V; exact (Mem.fresh_block_alloc _ _ _ _ _ A2 (Mem.valid_block_alloc _ _ _ _ _ A1 _ V))).
    assert (V1 : forall b, Mem.valid_block m b -> Mem.valid_block m1 b)
      by (intros b V; exact (Mem.valid_block_alloc _ _ _ _ _ A2 _ (Mem.valid_block_alloc _ _ _ _ _ A1 _ V))).
    assert (L1 : forall ch b z, Mem.valid_block m b -> Mem.load ch m1 b z = Mem.load ch m b z).
    { intros ch b z Hv.
      rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ (Mem.valid_block_alloc _ _ _ _ _ A1 _ Hv)).
      exact (Mem.load_alloc_unchanged _ _ _ _ _ A1 _ _ _ Hv). }
    assert (L5 : forall ch b z, b <> bF -> b <> bX -> Mem.load ch m' b z = Mem.load ch m3 b z).
    { intros ch b z N1 N2. apply (fl_load_other _ _ _ _ _ _ FLs).
      intros lo hi [E | [E | []]]; injection E as E _ _; [ exact (N2 (eq_sym E)) | exact (N1 (eq_sym E)) ]. }
    assert (Ok1 : mem_ok_lp bm MWF m1) by exact (of_alloc _ _ _ _ _ A2 (of_alloc _ _ _ _ _ A1 Hok)).
    destruct Tr as [E3 | (fx & fy & fz & t1 & m2 & vff & X1 & m2a & pb2 & po2 & X2 & EVf & St1 & Lg2 & St2 & XX)].
    { (* gMarioObject NULL: nothing stored *)
      subst m3.
      assert (PKm : PK m m') by exact (call2_pk _ _ _ _ _ _ _ A1 A2 (PK_refl m1) FLs).
      assert (Lall : forall ch b z, Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z. destruct (plt b (Mem.nextblock m)) as [Hv | Hv]; [ | exact (pk_load_fresh _ _ _ _ _ PKm Hv) ].
        rewrite L5 by (intros ->; contradiction). exact (L1 _ _ _ Hv). }
      split; [ exact (of_free _ _ _ FLs Ok1) | split; [ exact PKm | ] ].
      exists pool, k. split; [ exact S1 | split; [ exact Rk | split; [ exact Lb | ] ] ].
      intros bgp' Hgp'. rewrite Hgp in Hgp'. injection Hgp' as <-.
      split; [ intros ch b z _ _ _; apply Lall | left; exact Lall ]. }
    (* ---- the store case ---- *)
    (* permissions *)
    assert (PSffl : PS G (Internal SC.f_find_floor_from_list))
      by (apply (pk_body G [] (PollKeep.psym_nil lp)); vm_compute; reflexivity).
    assert (psffl : PollKeep.ps_id lp SC._find_floor_from_list)
      by exact (PollKeep.ps_int lp SC.prog SC._find_floor_from_list SC.f_find_floor_from_list
                  (linked12_LO_surf lp H12) dm_ffl PSffl).
    assert (PSff : PS G (Internal SC.f_find_floor))
      by (apply (pk_body G [SC._find_floor_from_list] (PollKeep.psym_cons lp _ _ psffl (PollKeep.psym_nil lp)));
          vm_compute; reflexivity).
    assert (PK13 : PK m1 m3)
      by exact (PK_trans _ _ _ (PSff _ _ _ _ _ EVf)
                  (PK_trans _ _ _ (PK_store _ _ _ _ _ _ St1) (PK_store _ _ _ _ _ _ St2))).
    assert (PKm : PK m m') by exact (call2_pk _ _ _ _ _ _ _ A1 A2 PK13 FLs).
    (* find_floor's contract *)
    set (avoid := fun b => is_static G b \/ b = bF).
    assert (Vsym : forall b, is_static G b -> Mem.valid_block m b)
      by (intros b (id & _ & Hs); exact (Gv _ _ Hs)).
    assert (SnF : forall b, is_static G b -> b <> bF) by (intros b Hs ->; exact (FbF (Vsym _ Hs))).
    assert (VbF1 : Mem.valid_block m1 bF)
      by exact (Mem.valid_block_alloc _ _ _ _ _ A2 _ (Mem.valid_new_block _ _ _ _ _ A1)).
    assert (PHm : forall hd, part_head G m1 hd ->
              exists l, OW.swalk P m OW.SFUEL hd = Some l /\ Forall (OW.surf_obj_at P pool m) l).
    { intros hd (id & bp & o & Hin & Hs & Ld). cbn [Mem.loadv] in Ld.
      rewrite (L1 _ _ _ (Gv _ _ Hs)) in Ld. exact (SW id bp _ hd Hin Hs Ld). }
    assert (NsP : ~ is_static G P)
      by (intros (id & _ & Hs); pose proof (Genv.genv_symb_range _ _ Hs); unfold Plt, Ple in *; lia).
    assert (PnS : Mem.valid_block m P -> ~ avoid P)
      by (intros Hv [Hs | E]; [ exact (NsP Hs) | rewrite E in Hv; exact (FbF Hv) ]).
    assert (Hwf : forall hd, part_head G m1 hd -> wf_list m1 avoid hd).
    { intros hd PH. destruct (PHm hd PH) as (l & Hw & _).
      apply (wf_list_move m m1 avoid avoid hd (swalk_wf2 P m avoid PnS _ _ _ Hw) V1 L1).
      intros b _ H. exact H. }
    assert (Hpart : forall id bp, In id part_ids -> Genv.find_symbol G id = Some bp ->
              Mem.valid_block m1 bp /\ ~ avoid bp).
    { intros id bp Hin Hs. split; [ exact (V1 _ (Gv _ _ Hs)) | ].
      intros [Hst | E].
      - exact (part_static id Hin (static_ids bp id Hst Hs)).
      - subst bp. exact (FbF (Gv _ _ Hs)). }
    destruct (ff_value_contract G avoid cenv_G ffl_pin m1 _ _ _ bF Ptrofs.zero t1 m2 vff
                (or_intror eq_refl) VbF1 (fun b Hs => conj (or_introl Hs) (SnF b Hs)) Hpart Hwf EVf)
      as (flr & Hfl & Hld2 & (U & _) & _ & _).
    assert (L2 : forall ch b z, Mem.valid_block m b -> ~ is_static G b -> b <> bF ->
              Mem.load ch m2 b z = Mem.load ch m1 b z).
    { intros ch b z Hv Hs Hf. eapply Mem.load_unchanged_on_1; [ exact U | exact (V1 _ Hv) | ].
      intros i _. split; [ exact (V1 _ Hv) | ].
      intros [(E & _) | (id & sz & Hin & Hs' & _)]; [ exact (Hf E) | ].
      apply Hs. exists id. split; [ | exact Hs' ].
      unfold ff_cells in Hin. cbn [In] in Hin. unfold ff_statics. cbn [In].
      destruct Hin as [E | [E | [E | []]]]; injection E as <- _; auto. }
    (* the blocks the stores hit *)
    assert (Ngp : forall b, Mem.valid_block m b -> b <> bF) by (intros b Hv ->; exact (FbF Hv)).
    assert (BgF : bgp <> bF) by exact (Ngp _ (Gv _ _ Hgp)).
    assert (NgpS : ~ is_static G bgp) by exact (not_static _ _ Hgp ltac:(vm_compute; reflexivity)).
    assert (NgoS : ~ is_static G bgmo) by exact (not_static _ _ Hgmo ltac:(vm_compute; reflexivity)).
    assert (Ngo : bgmo <> bgp) by exact (sym_ne _ _ _ _ Hgmo Hgp ltac:(vm_compute; reflexivity)).
    assert (Npl : pool <> bgp) by exact (sym_ne _ _ _ _ S1 Hgp ltac:(vm_compute; reflexivity)).
    (* gMarioObject is Mario's slot *)
    rewrite (Mem.load_store_other _ _ _ _ _ _ St1) in Lg2 by (left; exact Ngo).
    rewrite (L2 _ _ _ (Gv _ _ Hgmo) NgoS (Ngp _ (Gv _ _ Hgmo))), (L1 _ _ _ (Gv _ _ Hgmo)), Lg in Lg2.
    unfold OW.slot_v in Lg2. injection Lg2 as <- <-.
    assert (Ua : u (Ptrofs.add (Ptrofs.repr (k * OW.OSZ)) (Ptrofs.repr 532)) = k * OW.OSZ + 532)
      by (apply uadd; unfold OW.OSZ, OW.NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
    rewrite Ua in St2.
    (* the stored value: NULL or an object of the pool, still *)
    assert (PV : X2 = X1 /\ (X1 = Vint Int.zero \/ exists k', 0 <= k' < OW.NSLOT /\ X1 = OW.slot_v pool k'
                   /\ forall j, In j OW.ANGV ->
                        Mem.load Mint32 m pool (k' * OW.OSZ + RAW_OFF + 4 * j) = Some (Vint Int.zero))).
    { destruct XX as [(-> & ->) | (sb & so & sb2 & so2 & Lf & Lx1 & Lf2 & Lx2)];
        [ split; [ reflexivity | left; reflexivity ] | ].
      pose proof Lf as Lf'. cbn [Mem.loadv] in Hld2. rewrite Ptrofs.unsigned_zero in Hld2. rewrite Hld2 in Lf'. injection Lf' as Lf'.
      assert (Efl : flr = Vptr sb so) by (destruct flr; cbv [Val.load_result Archi.ptr64] in Lf'; congruence). subst flr.
      destruct Hfl as [Ez | (hd & PH & OL)]; [ discriminate Ez | ].
      destruct (PHm hd PH) as (l & Hw & Fa).
      assert (Wm : wf_list m avoid hd) by exact (swalk_wf2 P m avoid PnS _ _ _ Hw).
      assert (UA : Mem.unchanged_on (keep m avoid) m m1)
        by exact (Mem.unchanged_on_trans _ _ _ _ (Mem.alloc_unchanged_on _ _ _ _ _ _ A1)
                    (Mem.alloc_unchanged_on _ _ _ _ _ _ A2)).
      pose proof (on_list_back m avoid hd Wm m1 _ UA OL) as OLm.
      pose proof (OW.swalk_on_list P m hd _ OLm _ _ Hw) as Hin.
      rewrite Forall_forall in Fa. destruct (Fa _ Hin) as (o & Eo & Hsp & Hobj).
      injection Eo as <- <-.
      destruct (OW.in_sp_spec _ Hsp) as (Sp1 & Sp2). pose proof OW.sp_end_small as Sm.
      assert (Uo : u (Ptrofs.add so (Ptrofs.repr 44)) = u so + 44).
      { unfold Ptrofs.add. rewrite (Ptrofs.unsigned_repr 44) by (change Ptrofs.max_unsigned with 4294967295; lia).
        apply Ptrofs.unsigned_repr. pose proof (Ptrofs.unsigned_range so).
        unfold OW.SURF_SZ in *. lia. }
      assert (VP : Mem.valid_block m sb).
      { destruct Hobj as [Hl | (k' & _ & Hl & _)];
          apply Mem.load_valid_access in Hl; eapply Mem.valid_access_valid_block;
          (eapply Mem.valid_access_implies; [ exact Hl | constructor ]). }
      assert (NgP : sb <> bgp) by (intros ->; pose proof (Genv.genv_symb_range _ _ Hgp); unfold Plt, Ple in *; lia).
      rewrite Uo, (L2 _ _ _ VP NsP (Ngp _ VP)), (L1 _ _ _ VP) in Lx1.
      rewrite (Mem.load_store_other _ _ _ _ _ _ St1) in Lf2 by (left; exact (not_eq_sym BgF)).
      rewrite Lf in Lf2. injection Lf2 as <- <-.
      rewrite (Mem.load_store_other _ _ _ _ _ _ St1) in Lx2 by (left; exact NgP).
      rewrite Uo, (L2 _ _ _ VP NsP (Ngp _ VP)), (L1 _ _ _ VP), Lx1 in Lx2. injection Lx2 as ->.
      split; [ reflexivity | ].
      change OW.S_OBJ with 44 in Hobj.
      destruct Hobj as [Hl | (k' & Hk' & Hl & Ha)]; rewrite Lx1 in Hl; injection Hl as ->;
        [ left; reflexivity | right; exists k'; split; [ exact Hk' | split; [ reflexivity | exact Ha ] ] ]. }
    destruct PV as (-> & PV).
    (* GOAL 1's facts *)
    assert (Ok2 : mem_ok_lp bm MWF m2).
    { set (nl := Mem.nextblock m).
      assert (HNL : HnB lp bm SafeB nl).
      { split; [ exact Hvb | split ].
        - intros b Hs. exact (mwf_real_safe_valid lp bm bc oc0 SafeB m HM b Hs).
        - exact Gv. }
      pose proof (good_spec lp bm bc oc0 SafeB HSafeB_syms Hsp nl HNL camera_safe_syms cam_gs ff_ut []
                    (fun _ _ => False) (fun _ _ (H : False) => match H with end) ff_tab ff_it
                    (Internal SC.f_find_floor) ([kN; kN; kN; kT], kN, false)
                    (or_introl (ex_intro _ SC.f_find_floor (conj eq_refl uc_ff)))) as Hs'.
      assert (Hi : UInv lp bm bc oc0 SafeB nl false nl m1).
      { split; [ exact Ok1 | split ].
        - unfold nl. rewrite (Mem.nextblock_alloc _ _ _ _ _ A2), (Mem.nextblock_alloc _ _ _ _ _ A1).
          apply (Ple_trans _ (Pos.succ (Mem.nextblock m))); apply Ple_succ.
        - intros _ b ofs b' o' Hb Hl. exfalso.
          assert (VL : forall mm ch bb z vv, Mem.load ch mm bb z = Some vv -> Mem.valid_block mm bb).
          { intros mm ch bb z vv Hx. apply Mem.load_valid_access in Hx.
            eapply Mem.valid_access_valid_block; eapply Mem.valid_access_implies; [ exact Hx | constructor ]. }
          destruct (Mem.valid_block_alloc_inv _ _ _ _ _ A2 b (VL _ _ _ _ _ Hl)) as [-> | VA].
          + pose proof (Mem.load_alloc_same _ _ _ _ _ A2 _ _ _ Hl) as E. discriminate E.
          + rewrite (Mem.load_alloc_unchanged _ _ _ _ _ A2 _ _ _ VA) in Hl.
            destruct (Mem.valid_block_alloc_inv _ _ _ _ _ A1 b VA) as [-> | Vm].
            * pose proof (Mem.load_alloc_same _ _ _ _ _ A1 _ _ _ Hl) as E. discriminate E.
            * unfold nl, Mem.valid_block, Plt, Ple in *. lia. }
      assert (Hva : Forall2 (uvok lp SafeB nl nl) [kN; kN; kN; kT]
                      [Vsingle fx; Vsingle fy; Vsingle fz; Vptr bF Ptrofs.zero]).
      { refine (Forall2_cons _ _ _ (Forall2_cons _ _ _ (Forall2_cons _ _ _ (Forall2_cons _ _ _ (Forall2_nil _)))));
          intros bb oo E; try discriminate E.
        injection E as <- _. hnf. right. left.
        unfold nl. rewrite (Mem.alloc_result _ _ _ _ _ A1). apply Ple_refl. }
      destruct (Hs' nl (Ple_refl _) m1 _ t1 m2 vff EVf Hva Hi) as ((Hof & _) & _). exact Hof. }
    assert (SV1 : forall bb oo, X1 = Vptr bb oo -> SafeB bb).
    { intros bb oo E. destruct PV as [Ez | (k' & _ & Ek & _)]; rewrite E in *; [ discriminate Ez | ].
      unfold OW.slot_v in Ek. injection Ek as -> _. exact SBp. }
    assert (Ok2a : mem_ok_lp bm MWF m2a)
      by exact (ObjExtBodies.safe_store_pres lp bm bc oc0 SafeB Hsp PD._gMarioPlatform bgp Mint32 0 X1 m2 m2a
                  ltac:(vm_compute; reflexivity) Hgp SV1 St1 Ok2).
    assert (Ok3 : mem_ok_lp bm MWF m3)
      by exact (SpawnBodies.sb_safe_store lp bm bc oc0 SafeB HSafeB_syms Hsp pool Mint32 _ X1 m2a m3 SBp SV1 St2 Ok2a).
    split; [ exact (of_free _ _ _ FLs Ok3) | split; [ exact PKm | ] ].
    exists pool, k. split; [ exact S1 | split; [ exact Rk | split; [ exact Lb | ] ] ].
    intros bgp' Hgp'. rewrite Hgp in Hgp'. injection Hgp' as <-.
    split.
    - intros ch b z Ns Ng Hh.
      destruct (plt b (Mem.nextblock m)) as [Hv | Hv]; [ | exact (pk_load_fresh _ _ _ _ _ PKm Hv) ].
      assert (NF : b <> bF) by (intros ->; exact (FbF Hv)).
      assert (NX : b <> bX) by (intros ->; exact (FbX Hv)).
      rewrite (L5 _ _ _ NF NX).
      rewrite (Mem.load_store_other _ _ _ _ _ _ St2)
        by (destruct Hh as [Hh | Hh]; [ left; exact Hh | right; cbn [size_chunk]; lia ]).
      rewrite (Mem.load_store_other _ _ _ _ _ _ St1) by (left; exact Ng).
      rewrite (L2 _ _ _ Hv Ns NF). exact (L1 _ _ _ Hv).
    - right. intros v Hl.
      assert (Vg : Mem.valid_block m bgp) by exact (Gv _ _ Hgp).
      rewrite (L5 _ _ _ BgF (fun E => FbX (eq_ind _ _ Vg _ E))) in Hl.
      rewrite (Mem.load_store_other _ _ _ _ _ _ St2) in Hl by (left; exact (not_eq_sym Npl)).
      rewrite (Mem.load_store_same _ _ _ _ _ _ St1) in Hl. injection Hl as Hl.
      assert (Ev : v = X1)
        by (destruct PV as [-> | (k' & _ & -> & _)]; cbv [Val.load_result Archi.ptr64 OW.slot_v] in Hl |- *;
            congruence).
      rewrite Ev. exact PV.
  Qed.

  (* ---- THE KEEP: the object phase's invariant, across the real call ---- *)
  Theorem mplat_keeps : forall m t m' vr,
    eval_funcall function_entry2 G m (Internal PD.f_update_mario_platform) [] t m' vr ->
    mem_ok_lp bm MWF m -> phiw lp bm m -> a_down_real bm m = false ->
    PlatformKeep.plat_still lp m -> OW.obj_w G bm m ->
    mem_ok_lp bm MWF m' /\ phiw lp bm m' /\ a_down_real bm m' = false
    /\ PlatformKeep.plat_still lp m' /\ OW.obj_w G bm m'.
  Proof.
    intros m t m' vr Hev Hok Hphi HD Hst How.
    destruct (mplat_eff m t m' vr Hev Hok How) as (Ok' & PKm & pool & k & S1 & Rk & Lb & EF).
    destruct (PlatformKeep.plat_p_sym lp H12) as (bgp & Hgp).
    destruct (EF bgp Hgp) as (E4 & E5).
    pose proof Hok as (_ & _ & HM).
    assert (Npl : pool <> bgp) by exact (sym_ne _ _ _ _ S1 Hgp ltac:(vm_compute; reflexivity)).
    (* a global off the written list and not the pool keeps every load *)
    assert (ES : forall id b, Genv.find_symbol G id = Some b -> existsb (Pos.eqb id) mp_gvars = false ->
              b <> pool -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros id b Hs Hn Hp ch z. apply E4; [ | | left; exact Hp ].
      - apply (not_static id b Hs). unfold mp_gvars in Hn. rewrite existsb_app in Hn.
        apply orb_false_iff in Hn. exact (proj1 Hn).
      - intros ->. assert (E : id = PD._gMarioPlatform) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hgp ]).
        subst id. vm_compute in Hn. discriminate Hn. }
    assert (Bpl : bm <> pool) by exact (sym_ne _ _ _ _ Hbm_sym S1 ltac:(vm_compute; reflexivity)).
    assert (LBM : forall ch z, Mem.load ch m' bm z = Mem.load ch m bm z)
      by exact (ES _ _ Hbm_sym ltac:(vm_compute; reflexivity) Bpl).
    assert (Uk : u (Ptrofs.repr (k * OW.OSZ)) = k * OW.OSZ)
      by (apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
    assert (NpS : ~ is_static G pool) by exact (not_static _ _ S1 ltac:(vm_compute; reflexivity)).
    split; [ exact Ok' | ].
    split.
    { (* PhiW: RenderKeep.k_all_w with the written list mp_gvars *)
      pose proof Hphi as (_ & _ & _ & _ & Hf & _ & Haw & _).
      pose proof Haw as (ab & bga & bauc & btab & otab & bt & ot & mb & mo & B & _).
      pose proof B as (_ & _ & _ & _ & _ & Lmo & _).
      pose proof Hf as (Hgn & (dw & FWF) & _).
      pose proof (ff_W _ _ _ _ FWF) as W.
      assert (Emb : Vptr mb mo = OW.slot_v pool k) by (change 136 with MARIOOBJ_OFF in Lmo; congruence).
      unfold OW.slot_v in Emb. injection Emb as -> ->.
      assert (HXs : forall id, In id mp_gvars -> existsb (Pos.eqb id) core_ids = false)
        by exact (avoid_of mp_gvars core_ids ltac:(vm_compute; reflexivity)).
      assert (HXl : forall id, In id mp_gvars -> existsb (Pos.eqb id) lvl_rd_ids = false)
        by exact (avoid_of mp_gvars lvl_rd_ids ltac:(vm_compute; reflexivity)).
      pose proof PKm as (NB & PP & _).
      assert (PM : forall b o k0 p, Plt b (Mem.nextblock m) -> Mem.perm m b o k0 p -> Mem.perm m' b o k0 p)
        by (intros b o k0 p Hb Hp; exact (proj1 (PP b o k0 p Hb) Hp)).
      assert (LD : forall ch b z, ~ rgb lp mp_gvars b -> b <> bm -> (b <> pool \/ owin (Ptrofs.repr (k * OW.OSZ)) ch z) ->
                Mem.load ch m' b z = Mem.load ch m b z).
      { intros ch b z Nr _ H. apply E4.
        - intros (id & Hin & Hs). apply Nr. exists id. split; [ apply in_or_app; left; exact Hin | exact Hs ].
        - intros ->. apply Nr. exists PD._gMarioPlatform. split; [ apply in_or_app; right; left; reflexivity | exact Hgp ].
        - destruct H as [H | H]; [ left; exact H | right ]. apply owin_sub in H. unfold owin0 in H. rewrite Uk in H. lia. }
      assert (Nbm : ~ rgb lp mp_gvars bm) by exact (rgb_not lp mp_gvars HXs _ bm Hbm_sym ltac:(vm_compute; reflexivity)).
      assert (RGa : forall b, rgb lp mp_gvars b -> b <> pool /\ AnimWorld.tab_apart G m b).
      { intros b (id & Hin & Hs). split.
        - intros ->.
          assert (Ei : id = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; [ exact Hs | exact S1 ]).
          subst id. unfold mp_gvars, ff_statics in Hin. cbn [app In] in Hin.
          repeat (destruct Hin as [E | Hin]; [ vm_compute in E; discriminate E | ]). destruct Hin.
        - exact (AnimWorld.tab_apart_global G m _ _ _ b (Genv.genv_symb_range _ _ Hs) W). }
      assert (CL : forall gp0, closed_by gp0 m -> gp0 pool <> None ->
                (forall id b, Genv.find_symbol G id = Some b -> gp0 b <> None) ->
                exists gp', (forall b, gp0 b <> None -> gp' b <> None) /\ closed_by gp' m').
      { intros gp0 HC0 _ HS0.
        destruct (funcall_closed G m _ _ t m' vr gp0 Hev HC0 HS0 (Forall_nil _)) as (gp' & I & HC' & _ & _).
        exists gp'. split; [| exact HC' ].
        intros b Hb'. destruct (gp0 b) as [[b1 d]|] eqn:E0; [| congruence ].
        rewrite (I _ _ _ E0). discriminate. }
      assert (FR : forall bt0 ot0 k0, In k0 hs_ids ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (k * OW.OSZ)) + 60) = Some (Vptr bt0 ot0) ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (k * OW.OSZ)) + 72) = Some (Vint Int.zero) ->
                (exists f, -1 <= f <= hs_le k0
                   /\ Mem.load Mint16signed m pool (u (Ptrofs.repr (k * OW.OSZ)) + 64) = Some (Vint (Int.repr f))) ->
                buf_ok m bt0 ot0 k0 -> u ot0 + BUFSZ < Ptrofs.modulus ->
                exists f, -1 <= f <= hs_le k0
                  /\ Mem.load Mint16signed m' pool (u (Ptrofs.repr (k * OW.OSZ)) + 64) = Some (Vint (Int.repr f))).
      { intros bt0 ot0 k0 _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ].
        rewrite E4; [ exact L64 | exact NpS | exact Npl | right; left; rewrite Uk; cbn [size_chunk]; lia ]. }
      exact (k_all_w lp bm mp_gvars HXs HXl m m' pool (Ptrofs.repr (k * OW.OSZ)) Lmo NB PM LD
               (fun ch z _ => LBM ch z) Hbm_sym Nbm Bpl RGa CL FR Hphi (phiw_surf_apart lp bm _ m Hphi)). }
    split.
    { (* the A-held bit: gMarioStates and the controllers are untouched *)
      pose proof HM as (_ & _ & R2 & _).
      assert (Bcp : bc <> pool) by exact (sym_ne _ _ _ _ Hbc_sym S1 ltac:(vm_compute; reflexivity)).
      rewrite <- HD. unfold a_down_real. rewrite (LBM Mptr 156).
      destruct (Mem.load Mptr m bm 156) as [v |] eqn:E; [| reflexivity ].
      destruct v; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (ES _ _ Hbc_sym ltac:(vm_compute; reflexivity) Bcp). reflexivity. }
    split.
    { (* gMarioPlatform: still NULL / the old still object, or the new floor object *)
      intros bp v Hbp Hl. rewrite Hgp in Hbp. injection Hbp as <-.
      destruct E5 as [Lall | PV].
      - rewrite Lall in Hl.
        destruct (Hst bgp v Hgp Hl) as [Hz | (pb & po & -> & Hpb & Hk)]; [ left; exact Hz | right ].
        exists pb, po. split; [ reflexivity | split; [ exact Hpb | ] ].
        intros k0 Hk0. cbn [Mem.loadv] in *. rewrite Lall. exact (Hk k0 Hk0).
      - destruct (PV v Hl) as [Hz | (k' & Hk' & -> & ANG)]; [ left; exact Hz | right ].
        exists pool, (Ptrofs.repr (k' * OW.OSZ)). split; [ reflexivity | split; [ exact S1 | ] ].
        intros j Hj. cbn [Mem.loadv].
        assert (Hj' : 35 <= j <= 37) by (cbn in Hj; lia).
        rewrite uadd by (unfold OW.OSZ, OW.NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
        rewrite E4; [ | exact NpS | exact Npl | ].
        + replace (k' * OW.OSZ + (136 + 4 * j)) with (k' * OW.OSZ + RAW_OFF + 4 * j) by (unfold RAW_OFF; lia).
          exact (ANG j Hj).
        + right. cbn [size_chunk]. unfold OW.OSZ in *.
          destruct (Z.lt_trichotomy k' k) as [Hlt | [-> | Hgt]]; [ left; nia | left; lia | right; nia ]. }
    (* obj_w: PollKeep.obj_w_slots, the pool's hole at [532, 536) *)
    apply (PollKeep.obj_w_slots m m' G bm); [ | | | | | exact How ].
    - intros id b Hin Hne Hs ch z. apply (ES id b Hs).
      + exact (avoid_of PollKeep.ow_ids mp_gvars ltac:(vm_compute; reflexivity) id Hin).
      + intros ->. apply Hne. eapply Genv.genv_vars_inj; [ exact Hs | exact S1 ].
    - intros pool' Hs'. rewrite S1 in Hs'. injection Hs' as <-.
      intros ch k' off H1 H2 Hh. apply E4; [ exact NpS | exact Npl | right ].
      unfold OW.OSZ in *.
      destruct (Z.lt_trichotomy k' k) as [Hlt | [-> | Hgt]]; [ left; nia | lia | right; nia ].
    - intros b Hb ch z. apply E4.
      + intros (id & _ & Hs). pose proof (Genv.genv_symb_range _ _ Hs). unfold Plt, Ple in *. lia.
      + intros ->. pose proof (Genv.genv_symb_range _ _ Hgp). unfold Plt, Ple in *. lia.
      + left. intros ->. pose proof (Genv.genv_symb_range _ _ S1). unfold Plt, Ple in *. lia.
    - intros z _. apply LBM.
    - intros s b Hin Hs ch z. apply (ES s b Hs).
      + exact (avoid_of (map BhvVM.v_s BhvVM.vm_tab) mp_gvars ltac:(vm_compute; reflexivity) s Hin).
      + intros ->.
        assert (Es : s = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; [ exact Hs | exact S1 ]).
        subst s. refine (PollKeep.not_in_of_existsb _ _ _ Hin); vm_compute; reflexivity.
  Qed.
End MK.
