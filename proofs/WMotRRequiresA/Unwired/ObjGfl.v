(* ======================================================================= *)
(* ObjGfl.v -- an int store into an object's graph-node head (the type /   *)
(* flags words, slot offsets [0, 4)) keeps the objects phase's invariant   *)
(* ClearKeep.Pc (GOAL 2 objects, 2026-11-07).                              *)
(*                                                                         *)
(* The objects loop's own stores (ObjLoop.loop_pre: gCurrentObject->       *)
(* header.gfx.node.flags |= GRAPH_RENDER_HAS_ANIMATION, and in the time-   *)
(* stop loop &= ~GRAPH_RENDER_HAS_ANIMATION) write slot k's flags word at  *)
(* k * OSZ + 2.  No Pc clause reads [0, 4) of a slot:                      *)
(*   - MWF_real: an int store into the (SafeB) pool forges no pointer,     *)
(*     reads of bm / bc / the tables are other blocks (MWF_real_transfer); *)
(*   - PhiW: RenderKeep.owinc reads Mario's object from 16 and far objects *)
(*     from 136 (k_all_wc with no written global);                         *)
(*   - obj_w: PollKeep.SKp reads a slot's [4, 16) and from 96              *)
(*     (obj_w_slots_g);                                                    *)
(*   - the A gate reads bm and bc; plat_still reads rawData from 136.     *)
(* gfl_pc: PROVED.  Also: the store keeps the rings (ring links at 96 /   *)
(* 100) and every slot's VM cells (from 460).                             *)
(* ======================================================================= *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area platform_displacement behavior_script interaction.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ClearKeep BhvStep.
From SM64.Proofs.WMotRRequiresA.Unwired Require ObjExit.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module PK := PollKeep.

Section GF.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation u := Ptrofs.unsigned.
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  Variables (pool : block) (k0 : Z).
  Hypothesis Hpool : Genv.find_symbol G OLP._gObjectPool = Some pool.

  Variables (g m1 : mem) (ch : memory_chunk) (z0 : Z) (i0 : int).
  Hypothesis Hg : Pc g.
  Hypothesis Hz : k0 * OW.OSZ <= z0 /\ z0 + size_chunk ch <= k0 * OW.OSZ + 4.
  Hypothesis S : Mem.store ch g pool z0 (Vint i0) = Some m1.

  Lemma LO : forall ch' b z, b <> pool -> Mem.load ch' m1 b z = Mem.load ch' g b z.
  Proof. intros ch' b z N. exact (Mem.load_store_other _ _ _ _ _ _ S _ _ _ (or_introl N)). Qed.

  Lemma LOs : forall id b ch' z, Genv.find_symbol G id = Some b -> id <> OLP._gObjectPool ->
    Mem.load ch' m1 b z = Mem.load ch' g b z.
  Proof. intros id b ch' z Hs N. apply LO. exact (ObjExit.SNE lp _ _ _ _ Hs Hpool N). Qed.

  (* a cell of slot j: off slot k0's head [0, 4) *)
  Lemma LPw : forall ch' z j, j * OW.OSZ <= z -> z + size_chunk ch' <= j * OW.OSZ + OW.OSZ ->
    (j <> k0 \/ k0 * OW.OSZ + 4 <= z) -> Mem.load ch' m1 pool z = Mem.load ch' g pool z.
  Proof.
    intros ch' z j A B C. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
    pose proof (size_chunk_pos ch'). pose proof (size_chunk_pos ch). unfold OW.OSZ in *.
    destruct (Z.lt_trichotomy j k0) as [L | [<- | L]]; [ left; nia | right; lia | right; nia ].
  Qed.

  Lemma LPs : forall ch' k off, 0 <= off -> off + size_chunk ch' <= OW.OSZ -> (k <> k0 \/ 4 <= off) ->
    Mem.load ch' m1 pool (k * OW.OSZ + off) = Mem.load ch' g pool (k * OW.OSZ + off).
  Proof.
    intros ch' k off A B C. apply (LPw ch' _ k); [ lia | lia | ].
    destruct (Z.eq_dec k k0) as [-> | Nk]; [ right; destruct C as [C | C]; [ exfalso; exact (C eq_refl) | lia ] | left; exact Nk ].
  Qed.

  Lemma NV : BhvStep.nvB (fun _ => False) g m1.
  Proof. apply (BhvStep.nvB_store_c _ _ _ _ _ _ _ S). destruct ch; exact I. Qed.

  Lemma NB : Mem.nextblock m1 = Mem.nextblock g.
  Proof. exact (Mem.nextblock_store _ _ _ _ _ _ S). Qed.

  Lemma Hbc_bm : bc <> bm.
  Proof. apply (ObjExit.SNE lp _ _ _ _ Hbc_sym Hbm_sym). vm_compute. discriminate. Qed.

  Lemma LObm : forall ch' z, Mem.load ch' m1 bm z = Mem.load ch' g bm z.
  Proof. intros ch' z. apply (LOs _ _ ch' z Hbm_sym). vm_compute. discriminate. Qed.

  Lemma ok1 : mem_ok_lp bm MWF m1.
  Proof.
    destruct Hg as ((Hv & Hnt & M) & _).
    split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ S _ Hv) | split ].
    - intros v L. rewrite LObm in L. exact (Hnt v L).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm g m1 (fun b H => Mem.store_valid_block_1 _ _ _ _ _ _ S b H));
        [ | | | exact M ].
      + intros v L. rewrite LObm in L. exact (mwf_real_inp lp bm bc oc0 SafeB g M v L).
      + intros ch1 x ofs v Hx L.
        destruct Hx as [ (-> & _) | [ -> | [ H | [ H | [ H | [ (gid & Hk & H) | H ] ] ] ] ] ].
        * rewrite LObm in L. exact L.
        * rewrite (LOs _ _ _ _ Hbc_sym) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * assert (A2 : gid <> OLP._gObjectPool) by (intros ->; vm_compute in Hk; discriminate Hk).
          rewrite (LOs _ _ _ _ H A2) in L. exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
      + apply (BhvStep.closed_nvB SafeB (fun _ => False) g m1 NV (fun b F => False_ind _ F)).
        * intros b Hb. exact (mwf_real_safe_valid lp bm bc oc0 SafeB g M b Hb).
        * intros b ofs b' o' Hb L. exact (mwf_real_chase_step lp bm bc oc0 SafeB g b ofs b' o' M Hb L).
  Qed.

  Lemma ad1 : a_down_real bm m1 = false.
  Proof.
    destruct Hg as (Ok & _ & HD & _). pose proof Ok as (_ & _ & HM). pose proof HM as (_ & _ & R2 & _).
    rewrite <- HD. unfold a_down_real. rewrite (LObm Mptr 156).
    destruct (Mem.load Mptr g bm 156) as [v0 |] eqn:E; [ | reflexivity ].
    destruct v0; try reflexivity.
    destruct (R2 _ _ eq_refl) as (-> & _).
    rewrite (LOs _ _ _ _ Hbc_sym); [ reflexivity | vm_compute; discriminate ].
  Qed.

  Lemma ps1 : PlatformKeep.plat_still lp m1.
  Proof.
    destruct Hg as (_ & _ & _ & Hst & _).
    intros bp v0 Hbp Hl0.
    rewrite LO in Hl0 by exact (ObjExit.SNE lp _ _ _ _ Hbp Hpool ltac:(vm_compute; discriminate)).
    destruct (Hst bp v0 Hbp Hl0) as [Hzz | (pb & po & -> & Hpb0 & Hk0 & Hal)]; [ left; exact Hzz | right ].
    rewrite Hpool in Hpb0. injection Hpb0 as <-.
    exists pool, po. split; [ reflexivity | split; [ exact Hpool | split; [ | exact Hal ] ] ].
    intros kk Hkk. destruct Hal as (j & Hj & Ej).
    assert (Hkr : 35 <= kk <= 37) by (cbn in Hkk; lia).
    specialize (Hk0 kk Hkk). cbn [Mem.loadv] in Hk0 |- *.
    assert (Eu : u (Ptrofs.add po (Ptrofs.repr (136 + 4 * kk))) = j * OW.OSZ + (136 + 4 * kk)).
    { rewrite Ptrofs.add_unsigned, Ej, (Ptrofs.unsigned_repr (136 + 4 * kk))
        by (change Ptrofs.max_unsigned with 4294967295; lia).
      unfold OW.OSZ. apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; unfold OW.NSLOT in Hj; lia. }
    rewrite Eu in Hk0 |- *.
    rewrite LPs; [ exact Hk0 | lia | unfold OW.OSZ; cbn [size_chunk]; lia | right; lia ].
  Qed.

  Lemma CLm : forall gp, closed_by gp g -> closed_by gp m1.
  Proof. intros gp Hc. exact (ObjExit.nvB_closed _ gp g m1 Hc NV NB (fun b F => False_ind _ F)). Qed.

  Lemma phi1 : phiw lp bm m1.
  Proof.
    destruct Hg as (Ok & Hphi & _ & _ & How).
    pose proof How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (km & Hkm & Lg & Lb & KO).
    assert (Hpl : pool <> la) by (apply (ObjExit.SNE lp _ _ _ _ Hpool S2); vm_compute; discriminate).
    assert (Rkm : 0 <= km < OW.NSLOT).
    { pose proof (proj1 (ObjRing.rings_iff pool g la rs Hpl) (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as (_ & Henc).
      destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc0 & _).
      exact (ObjRing.chain_range pool g _ _ _ Hc0 km Hkm). }
    assert (Uj : forall j, 0 <= j < OW.NSLOT -> u (Ptrofs.repr (j * OW.OSZ)) = j * OW.OSZ)
      by (intros j Hj; apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *;
          change Ptrofs.max_unsigned with 4294967295; lia).
    assert (Ukm : u (Ptrofs.repr (km * OW.OSZ)) = km * OW.OSZ) by exact (Uj km Rkm).
    assert (Bpl : bm <> pool) by (apply (ObjExit.SNE lp _ _ _ _ Hbm_sym Hpool); vm_compute; discriminate).
    set (Q := fun co : ptrofs => exists j, 0 <= j < OW.NSLOT /\ u co = j * OW.OSZ).
    assert (SQ : forall v0 co, OW.slot_ptr pool v0 -> v0 = Vptr pool co -> Q co).
    { intros v0 co [-> | (j & Hj & ->)] E; [ discriminate E | ].
      unfold OW.slot_v in E. injection E as <-. exists j. split; [ exact Hj | exact (Uj j Hj) ]. }
    assert (QC : forall i1 co, 0 <= i1 < 4 ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i1) = Some (Vptr pool co) -> Q co).
    { intros i1 co Hi1 Lc. rewrite Ukm in Lc.
      destruct (OW.ow_mcoll _ _ _ _ _ _ _ _ _ _ _ _ C km Rkm Lg i1 Hi1) as (v0 & Lv & Sv).
      unfold OW.O_COLLS, COLL_OFF in *. rewrite Lc in Lv. injection Lv as <-. exact (SQ _ co Sv eq_refl). }
    assert (QU : forall uo, Mem.load Mint32 g bm USED_OFF = Some (Vptr pool uo) -> Q uo).
    { intros uo Lu. destruct (OW.ow_stale _ _ _ _ _ _ _ _ _ _ _ _ C 128 ltac:(cbn; auto)) as (v0 & Lv & Sv).
      unfold USED_OFF in Lu. rewrite Lu in Lv. injection Lv as <-. exact (SQ _ uo Sv eq_refl). }
    assert (HXs : forall id, In id (@nil ident) -> existsb (Pos.eqb id) core_ids = false) by (intros id []).
    assert (HXl : forall id, In id (@nil ident) -> existsb (Pos.eqb id) lvl_rd_ids = false) by (intros id []).
    assert (Nbm : ~ rgb lp (@nil ident) bm) by (intros (id & [] & _)).
    assert (RGa : forall b, rgb lp (@nil ident) b -> b <> pool /\ AnimWorld.tab_apart G g b) by (intros b (id & [] & _)).
    assert (NB' : Ple (Mem.nextblock g) (Mem.nextblock m1)) by (rewrite NB; apply Ple_refl).
    assert (PM : forall b o k p, Plt b (Mem.nextblock g) -> Mem.perm g b o k p -> Mem.perm m1 b o k p).
    { intros b o k p _ Hp. exact (Mem.perm_store_1 _ _ _ _ _ _ S _ _ _ _ Hp). }
    assert (LD : forall ch' b z', ~ rgb lp (@nil ident) b -> b <> bm ->
              (b <> pool \/ owinc Q (Ptrofs.repr (km * OW.OSZ)) ch' z') -> Mem.load ch' m1 b z' = Mem.load ch' g b z').
    { intros ch' b z' _ _ Hw.
      destruct (eq_block b pool) as [-> | Np]; [ | exact (LO _ _ _ Np) ].
      destruct Hw as [Nb | Hw]; [ congruence | ].
      unfold owinc, ccl_at in Hw. rewrite Ukm in Hw. pose proof (size_chunk_pos ch').
      destruct Hw as [Hw | [Hw | [Hw | [Hw | (co & (j & Hj & Ec) & _ & Hw)]]]].
      - apply (LPw ch' z' km); unfold OW.OSZ in *; lia.
      - apply (LPw ch' z' km); unfold OW.OSZ in *; lia.
      - apply (LPw ch' z' km); unfold OW.OSZ in *; lia.
      - apply (LPw ch' z' km); unfold OW.OSZ in *; lia.
      - rewrite Ec in Hw. apply (LPw ch' z' j); unfold OW.OSZ in *; lia. }
    assert (CL : forall gp, closed_by gp g -> gp pool <> None ->
              (forall id b, Genv.find_symbol G id = Some b -> gp b <> None) ->
              exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m1).
    { intros gp HC _ _. exists gp. split; [ intros b H; exact H | exact (CLm gp HC) ]. }
    assert (FR : forall bt0 ot0 kk, In kk hs_ids ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + 60) = Some (Vptr bt0 ot0) ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + 72) = Some (Vint Int.zero) ->
              (exists f, -1 <= f <= hs_le kk
                 /\ Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))) ->
              buf_ok g bt0 ot0 kk -> u ot0 + BUFSZ < Ptrofs.modulus ->
              exists f, -1 <= f <= hs_le kk
                /\ Mem.load Mint16signed m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))).
    { intros bt0 ot0 kk _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ]. rewrite Ukm in *.
      rewrite LPs; [ exact L64 | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; lia ]. }
    assert (CKo : forall i cb co, 0 <= i < 4 ->
              Mem.load Mint32 m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co)
              \/ (cb = pool /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros i cb co Hi Hl. left. rewrite Ukm in *. unfold COLL_OFF in *. rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPs in Hl; [ exact Hl | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; lia ]. }
    assert (CKn : forall n, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n) ->
              exists n', Mem.load Mint16signed m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n')
              /\ (n' = n \/ 0 <= Int.signed n' <= 4)
              /\ forall i v0, 0 <= i < Int.signed n' -> i < 4 ->
                   Mem.load Mint32 m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0 ->
                   (exists n0, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n0)
                      /\ i < Int.signed n0
                      /\ Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0)
                   \/ (exists co, v0 = Vptr pool co /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros n Ln. rewrite Ukm in *. unfold NUMCOLL_OFF, COLL_OFF in *. exists n.
      split; [ rewrite LPs; [ exact Ln | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; lia ] | ].
      split; [ left; reflexivity | ].
      intros i v0 Hi Hi4 Hl. left. exists n. split; [ exact Ln | split; [ lia | ] ].
      rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPs in Hl; [ exact Hl | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; lia ]. }
    eapply k_all_wc with (lp := lp) (bm := bm) (Xs := @nil ident) (Qt := fun _ : ptrofs => False);
      first [ exact HXs | exact HXl | exact Lb | exact NB' | exact PM | exact LD
            | exact (fun ch' z' (_ : bmk ch' z') => LObm ch' z') | exact Hbm_sym
            | exact Nbm | exact Bpl | exact RGa | exact CL | exact FR
            | exact (fun i1 co Hi1 Lc => or_introl (QC i1 co Hi1 Lc))
            | exact (fun a uo (_ : Mem.load Mint32 g bm 12 = Some (Vint a)) (_ : In (Int.unsigned a) used_acts) Lu => QU uo Lu)
            | solve [ intros ? [] ] | solve [ intros ? ? [] ]
            | exact CKo | exact CKn | exact Hphi | exact (phiw_surf_apart lp bm _ g Hphi) ].
  Qed.

  Lemma ow1 : OW.obj_w G bm m1.
  Proof.
    destruct Hg as (_ & _ & _ & _ & How).
    assert (KP : forall pool', Genv.find_symbol G OLP._gObjectPool = Some pool' -> PK.SKp g m1 pool').
    { intros pool' Sp. rewrite Hpool in Sp. injection Sp as <-.
      intros ch' k off A B _. pose proof (size_chunk_pos ch'). apply LPs; [ lia | exact B | right; lia ]. }
    assert (K : forall id b, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false -> Genv.find_symbol G id = Some b ->
              forall ch' z, Mem.load ch' m1 b z = Mem.load ch' g b z).
    { intros id b Hin Hn Hs ch' z. apply (LOs id b ch' z Hs).
      intros ->. vm_compute in Hn. discriminate Hn. }
    assert (KG' : forall id b, In id OW.surf_gids -> Genv.find_symbol G id = Some b ->
              forall ch' z, Mem.load ch' m1 b z = Mem.load ch' g b z).
    { intros id b Hin Hs ch' z. apply (LOs id b ch' z Hs);
        unfold OW.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin;
        destruct Hin as [<- | [<- | [<- | [<- | []]]]]; vm_compute; discriminate. }
    assert (KPn : forall P, Ple (Genv.genv_next G) P -> forall ch' z, Mem.load ch' m1 P z = Mem.load ch' g P z).
    { intros P HP ch' z. apply LO.
      intros ->. pose proof (Genv.genv_symb_range _ _ Hpool). unfold Plt, Ple in *. lia. }
    assert (KS : PK.surf_keep g m1 G).
    { intros pool' Sp. rewrite Hpool in Sp. injection Sp as <-. split.
      - intros Cso. apply (OW.surf_obj_ok_ext G pool g m1); [ exact KG' | | | exact Cso ].
        + intros P HP _ _ ch' z _. exact (KPn P HP ch' z).
        + intros k j _ Hj. rewrite <- Z.add_assoc. apply LPs;
            unfold RAW_OFF, OW.OSZ; unfold OW.ANGV in Hj; cbn [In] in Hj; cbn [size_chunk];
            destruct Hj as [<- | [<- | [<- | []]]]; lia.
      - intros mv. apply (OW.cls_surf_ext G pool g m1 mv KG'). intros P HP _ _ ch' z _. exact (KPn P HP ch' z). }
    assert (KC : OW.ctr_s_ok G g -> OW.ctr_s_ok G m1).
    { intros (a & Hgc & Ha). exists a. split; [ | exact Ha ].
      apply (PK.gcell_K g m1); [ | exact Hgc ].
      intros b Hs ch' z. apply (LOs _ b ch' z Hs); vm_compute; discriminate. }
    assert (Kbm : forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104; 12] ->
              Mem.load Mint32 m1 bm z = Mem.load Mint32 g bm z) by (intros z _; apply LObm).
    assert (KSc : forall s b, In s (map v_s vm_tab) -> Genv.find_symbol G s = Some b ->
              forall ch' z, Mem.load ch' m1 b z = Mem.load ch' g b z).
    { intros s b Hin Hs ch' z. destruct (ObjExit.scr_ids_ne s Hin) as (_ & N2). exact (LOs s b ch' z Hs N2). }
    exact (PK.obj_w_slots_g g m1 G bm K KP KS KC Kbm KSc How).
  Qed.

  Theorem gfl_pc : Pc m1.
  Proof. exact (conj ok1 (conj phi1 (conj ad1 (conj ps1 ow1)))). Qed.

  (* the ring links (96 / 100) and the list heads stay *)
  Lemma gfl_rings : forall la, la <> pool -> OW.rings m1 pool la = OW.rings g pool la.
  Proof.
    intros la Nl. apply (PK.rings_eq g m1).
    - intros ch' k off A B _ _. pose proof (size_chunk_pos ch'). apply LPs; [ lia | exact B | right; lia ].
    - intros z. apply PK.ld32_eq. intros ch' z'. exact (LO ch' la z' Nl).
  Qed.

  (* every slot's VM cells stay *)
  Lemma gfl_vm : forall ch' k off, 460 <= off -> off + size_chunk ch' <= OW.OSZ ->
    Mem.load ch' m1 pool (k * OW.OSZ + off) = Mem.load ch' g pool (k * OW.OSZ + off).
  Proof. intros ch' k off A B. apply LPs; [ lia | exact B | right; lia ]. Qed.
End GF.
