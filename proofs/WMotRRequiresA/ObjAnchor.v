(* ======================================================================= *)
(* ObjAnchor.v -- the RE-ANCHOR of INV_k's ghost at bhvCannon's word 6    *)
(* (GOAL 2 objects, 2026-11-09).                                           *)
(*                                                                         *)
(* INV_k's ghost g is a Pobjl memory with slot k at the update's start     *)
(* state st0.  Inside the cannon's prologue (ObjInv.inP: words 0..6, the   *)
(* update started in it) obj_w's trajectory pin (can_traj) holds slot k    *)
(* at word 0 -- words 1..6 are no start state (clause class 3) -- at its   *)
(* lid's macro position, (oAction, oPrevAction, oTimer) = 0.  Word 6,      *)
(* ADD_FLOAT(oPosY, -340), drops it to lid - 340, and the ghost follows by *)
(* RE-ANCHORING in ONE step (anchor = ObjRows.anc_keep, PROVED here):      *)
(*   gp: g with slot k's command cell at bhvCannon + 28 (ObjInv.sL; the    *)
(*      stack is empty there and at st0) -- not itself a Pobjl memory;      *)
(*   g1: gp with lid - 340 stored into oPosY: Pobjl by                     *)
(*      CannonKeep.can_drop_pc (the poke and the drop together; obj_w's     *)
(*      word-7 pin, can7, at the dropped position), the ghost fact by      *)
(*      xf_mix's shape (HXm);                                              *)
(*   GR: the real memory differs from g1 off Pfr only (the store is the    *)
(*      same store; the command cell is a VM cell, its old bytes a          *)
(*      script pointer's).                                                 *)
(* No premise: the ghost fact's transfer lemmas are ObjStep's (xf_mix /     *)
(* xf_ring, PROVED for the objects step's XR / XT).                         *)
(* ======================================================================= *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Memdata Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area platform_displacement behavior_script interaction behavior_data macro_special_objects.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep BhvVM WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ClearKeep BhvStep ObjFamily.
From SM64.Proofs.WMotRRequiresA Require ObjExit ObjInv ObjRows CannonKeep ObjFld FieldWin.
From SM64.Proofs Require Interp.CMem.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module CM := SM64.Proofs.Interp.CMem.

(* a 32-bit pointer's bytes are its fragments *)
Lemma enc_frag : forall b o mv, In mv (encode_val Mint32 (Vptr b o)) -> exists q n, mv = Fragment (Vptr b o) q n.
Proof.
  intros b o mv H. cbn in H.
  destruct H as [<- | [<- | [<- | [<- | []]]]]; eexists; eexists; reflexivity.
Qed.

Lemma dec_enc : forall b o, decode_val Mint32 (encode_val Mint32 (Vptr b o)) = Vptr b o.
Proof.
  intros b o. pose proof (decode_encode_val_general (Vptr b o) Mint32 Mint32) as D. cbn in D. exact D.
Qed.

(* inside the prologue only word 0 is a clause class with a pin (words
   1..6 are class 3: no start state there) *)
Lemma can_cl_P : forall i m pool o, (i <= 6)%nat -> OW.can_cl (OW.ccls (4 * Z.of_nat i)) m pool o ->
  i = 0%nat /\ OW.can0 m pool o.
Proof.
  intros i m pool o Hi H. unfold OW.can_cl, OW.ccls in H.
  destruct (Z.eqb_spec (4 * Z.of_nat i) 0) as [E | N].
  - split; [ lia | exact H ].
  - destruct (Z.eqb_spec (4 * Z.of_nat i) 28); [ lia | ].
    destruct (Z.leb_spec 32 (4 * Z.of_nat i)); [ lia | ]. cbn in H. destruct H.
Qed.

Lemma lid_xyz_chk : forallb (fun '(x, y, z) => existsb (Z.eqb y) OW.cannon_lids) OW.cannon_lid_xyz = true.
Proof. vm_compute. reflexivity. Qed.

Lemma lid_xyz_lids : forall x y z, In (x, y, z) OW.cannon_lid_xyz -> In y OW.cannon_lids.
Proof.
  intros x y z H. pose proof (proj1 (forallb_forall _ _) lid_xyz_chk _ H) as A. cbv beta iota in A.
  apply existsb_exists in A as (y' & Hy & E). apply Z.eqb_eq in E. subst y'. exact Hy.
Qed.

Section AN.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Notation Pobjl := (ClearKeep.Pobjc lp bm bc oc0 SafeB).
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  Variables (pool bcc : block) (k : Z).
  Hypothesis Hpool : Genv.find_symbol G OLP._gObjectPool = Some pool.
  Hypothesis Hbcc : Genv.find_symbol G BhvStep.BS._gCurBhvCommand = Some bcc.
  Hypothesis HSafeB_scr : forall b, BhvStep.scr_b lp b -> SafeB b.
  Hypothesis Hk : 0 <= k < OW.NSLOT.
  Notation oc := (k * OW.OSZ).
  Notation Vo := (BhvStep.Vo lp pool (k * OW.OSZ)).
  Notation Pfr := (BhvStep.Pfr pool (k * OW.OSZ) bcc).
  Notation scr := (BhvStep.scr_b lp).

  Variables (st0 : vst) (nb0 : block) (X : mem -> Prop).
  Hypothesis H0 : In st0 vm_tab.
  (* the ghost fact's transfers (ObjStep: xf_mix, xf_ring) *)
  Hypothesis HXm : forall s0 s1 m m1, ObjFamily.Qfam (v_s s0) s1 -> Pobjl m -> Pobjl m1 -> Vo m s0 -> Vo m1 s1 ->
    (forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la) ->
    (forall j, j <> k -> OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD)) ->
    OW.tsa G m1 = OW.tsa G m -> X m -> X m1.
  Hypothesis HXr : forall g, X g -> forall la rs, Genv.find_symbol G OLP._gObjectListArray = Some la ->
    OW.rings g pool la = Some rs -> In k (concat rs).

  Lemma SNE : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. Qed.

  Lemma P_of_pc : forall m, Pc m -> Pobjl m.
  Proof.
    intros m (Hok & Hphi & HD & Hst & How).
    exact (conj Hok (conj Hphi (conj HD (conj Hst (conj (RenderKeep.phiw_surf_apart lp bm _ m Hphi) How))))).
  Qed.

  Lemma pc_of_P : forall m, Pobjl m -> Pc m.
  Proof. intros m (Hok & Hphi & HD & Hst & _ & How). exact (conj Hok (conj Hphi (conj HD (conj Hst How)))). Qed.

  Lemma Uoc : 0 <= oc /\ oc + OW.OSZ <= OW.NSLOT * OW.OSZ.
  Proof. unfold OW.OSZ, OW.NSLOT in *. lia. Qed.

  (* ---- 1. the poke: slot k's command cell set to bhvCannon + po ---- *)
  Section PK.
    Variable g : mem.
    Variable bC : block.
    Variable po : Z.
    Local Transparent Mem.load.

    Definition pk_c : PMap.t (ZMap.t memval) :=
      PMap.set pool (Mem.setN (encode_val Mint32 (Vptr bC (Ptrofs.repr po))) (oc + OW.O_CMD)
                       ((Mem.mem_contents g) !! pool)) (Mem.mem_contents g).

    Definition pk : mem.
    Proof.
      refine (Mem.mkmem pk_c (Mem.mem_access g) (Mem.nextblock g) (Mem.access_max g) (Mem.nextblock_noaccess g) _).
      intros b. unfold pk_c. rewrite PMap.gsspec.
      destruct (peq b pool); [ rewrite Mem.setN_default; apply Mem.contents_default | apply Mem.contents_default ].
    Defined.

    Lemma pk_nb : Mem.nextblock pk = Mem.nextblock g.
    Proof. reflexivity. Qed.

    Lemma pk_perm : forall b o kk p, Mem.perm pk b o kk p <-> Mem.perm g b o kk p.
    Proof. intros b o kk p. unfold Mem.perm. cbn. reflexivity. Qed.

    Definition cmdc (b : block) (o : Z) : Prop := b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + 4.

    Lemma cmdc_dec : forall b o, {cmdc b o} + {~ cmdc b o}.
    Proof.
      intros b o. unfold cmdc. destruct (peq b pool) as [E | N]; [ | right; intros (E & _); exact (N E) ].
      destruct (Z_lt_le_dec o (oc + OW.O_CMD)); [ right; intros (_ & H); lia | ].
      destruct (Z_lt_le_dec o (oc + OW.O_CMD + 4)); [ left; split; [ exact E | lia ] | right; intros (_ & H); lia ].
    Qed.

    Lemma pk_out : forall b o, ~ cmdc b o ->
      ZMap.get o ((Mem.mem_contents pk) !! b) = ZMap.get o ((Mem.mem_contents g) !! b).
    Proof.
      intros b o N. cbn [Mem.mem_contents pk]. unfold pk_c. rewrite PMap.gsspec.
      destruct (peq b pool) as [-> | Nb]; [ | reflexivity ].
      rewrite Mem.setN_outside; [ reflexivity | ].
      rewrite encode_val_length. cbn. destruct (Z_lt_le_dec o (oc + OW.O_CMD)); [ left; lia | right ].
      destruct (Z_lt_le_dec o (oc + OW.O_CMD + 4)); [ exfalso; apply N; split; [ reflexivity | lia ] | lia ].
    Qed.

    Lemma pk_in : forall o, oc + OW.O_CMD <= o < oc + OW.O_CMD + 4 ->
      exists q n, ZMap.get o ((Mem.mem_contents pk) !! pool) = Fragment (Vptr bC (Ptrofs.repr po)) q n.
    Proof.
      intros o Ho. cbn [Mem.mem_contents pk]. unfold pk_c. rewrite PMap.gss.
      apply enc_frag. apply Mem.setN_in. rewrite encode_val_length. cbn. lia.
    Qed.

    Lemma pk_load : forall ch b z, (b <> pool \/ z + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_CMD + 4 <= z) ->
      Mem.load ch pk b z = Mem.load ch g b z.
    Proof.
      intros ch b z H. unfold Mem.load.
      destruct (Mem.valid_access_dec pk ch b z Readable) as [A | A];
        destruct (Mem.valid_access_dec g ch b z Readable) as [B | B];
        [ | exfalso; exact (B A) | exfalso; exact (A B) | reflexivity ].
      apply (f_equal (fun l => Some (decode_val ch l))). apply Mem.getN_exten. intros i Hi. rewrite <- size_chunk_conv in Hi.
      apply pk_out. intros (Eb & Hi2). destruct H as [H | [H | H]]; [ exact (H Eb) | lia | lia ].
    Qed.

    Lemma pk_load_cmd : Mem.valid_access g Mint32 pool (oc + OW.O_CMD) Readable ->
      Mem.load Mint32 pk pool (oc + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr po)).
    Proof.
      intros Vg. unfold Mem.load.
      destruct (Mem.valid_access_dec pk Mint32 pool (oc + OW.O_CMD) Readable) as [A | A];
        [ | exfalso; exact (A Vg) ].
      apply (f_equal Some). cbn [Mem.mem_contents pk]. unfold pk_c. rewrite PMap.gss.
      rewrite <- (dec_enc bC (Ptrofs.repr po)) at 2. apply (f_equal (decode_val Mint32)).
      change (size_chunk_nat Mint32) with (List.length (encode_val Mint32 (Vptr bC (Ptrofs.repr po)))).
      apply Mem.getN_setN_same.
    Qed.

    (* the poke changes only a Pfr-excluded cell, to a script pointer *)
    Lemma pk_unch : Mem.unchanged_on Pfr g pk.
    Proof.
      constructor.
      - rewrite pk_nb. apply Ple_refl.
      - intros b o kk p _ _. rewrite pk_perm. reflexivity.
      - intros b o (_ & Hn) _. apply pk_out. intros (Eb & Ho). apply Hn. split; [ exact Eb | ].
        unfold OW.O_CMD, OW.O_STK in *. lia.
    Qed.

    Hypothesis HbC : scr bC.

    Lemma pk_nv : BhvStep.nvB scr g pk.
    Proof.
      split.
      - intros b o kk p _. rewrite pk_perm. reflexivity.
      - intros b o _ _ Ne. destruct (cmdc_dec b o) as [(-> & Ho) | N].
        + destruct (pk_in o Ho) as (q & n & E). rewrite E. exact HbC.
        + exfalso. exact (Ne (pk_out b o N)).
    Qed.

    (* GR moves from g to the poke: the real memory's command cell holds
       g's bytes or a changed byte nvB allowed *)
    Variable m : mem.
    Hypothesis U : Mem.unchanged_on Pfr g m.
    Hypothesis NV : BhvStep.nvB scr g m.
    Variables (b0 : block) (o0 : ptrofs).
    Hypothesis Hb0 : scr b0.
    Hypothesis L0 : Mem.load Mint32 g pool (oc + OW.O_CMD) = Some (Vptr b0 o0).

    Lemma pkm_unch : Mem.unchanged_on Pfr pk m.
    Proof.
      constructor.
      - rewrite pk_nb. exact (Mem.unchanged_on_nextblock _ _ _ U).
      - intros b o kk p HP Hv. rewrite pk_perm. unfold Mem.valid_block in Hv. rewrite pk_nb in Hv.
        exact (Mem.unchanged_on_perm _ _ _ U b o kk p HP Hv).
      - intros b o HP Hr. rewrite pk_perm in Hr.
        rewrite (Mem.unchanged_on_contents _ _ _ U b o HP Hr). symmetry. apply pk_out.
        intros (Eb & Ho). destruct HP as (_ & Hn). apply Hn. split; [ exact Eb | unfold OW.O_CMD, OW.O_STK in *; lia ].
    Qed.

    Lemma pkm_nv : BhvStep.nvB scr pk m.
    Proof.
      destruct NV as (PB & NC). split.
      - intros b o kk p Hb. rewrite pk_nb in Hb. rewrite (PB b o kk p Hb). rewrite pk_perm. reflexivity.
      - intros b o Hb Hr Ne. rewrite pk_nb in Hb.
        destruct (cmdc_dec b o) as [(-> & Ho) | N].
        + destruct (BhvStep.memval_eq_dec (ZMap.get o ((Mem.mem_contents m) !! pool)) (ZMap.get o ((Mem.mem_contents g) !! pool)))
            as [E | E]; [ | exact (NC pool o Hb Hr E) ].
          rewrite E.
          pose proof (Mem.load_result _ _ _ _ _ L0) as D.
          assert (Hin : In (ZMap.get o ((Mem.mem_contents g) !! pool))
                           (Mem.getN (size_chunk_nat Mint32) (oc + OW.O_CMD) ((Mem.mem_contents g) !! pool)))
            by (apply Mem.getN_in; cbn; lia).
          destruct (BhvStep.decode_ptr_frag Mint32 _ b0 o0 _ (eq_sym D) Hin) as (q & n & ->). exact Hb0.
        + rewrite (pk_out b o N) in Ne. exact (NC b o Hb Hr Ne).
    Qed.
  End PK.

  (* ---- 2. the anchor: ObjRows.anc_keep, PROVED ---- *)
  Theorem anchor : ObjRows.anc_keep lp bm bc oc0 SafeB pool (k * OW.OSZ) bcc st0 nb0 X.
  Proof.
    intros g m m1 w old (HP & HV0 & HX) Hp0 (Hgn & U & NV) Hw L S.
    pose proof Hp0 as (Ec & Hi).
    pose proof (ObjInv.P_stk st0 H0 Hp0) as Ek.
    pose proof HV0 as ((bC & HbC & Lc) & Hsi & _).
    rewrite Ec in HbC.
    assert (ScrC : scr bC).
    { exists OW.CANS. split; [ | exact HbC ]. rewrite <- Ec. exact (in_map v_s vm_tab st0 H0). }
    (* slot k is in a ring; obj_w's trajectory pin: at index <= 6 it is the
       spawned base, word 0, at its lid's position *)
    pose proof HP as (_ & _ & _ & _ & _ & How).
    destruct How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    pose proof (HXr g HX la rs S2 (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as Hkr.
    destruct (OW.ow_pin _ _ _ _ _ _ _ _ _ _ _ _ C k Hkr) as (_ & _ & _ & T).
    assert (Lc' : OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr (4 * Z.of_nat (v_i st0)))))
      by (unfold OW.ld32; rewrite CM.load_eq; exact Lc).
    pose proof (T bC _ HbC Lc') as T0.
    rewrite Ptrofs.unsigned_repr in T0 by (change Ptrofs.max_unsigned with 4294967295; lia).
    destruct (can_cl_P (v_i st0) g pool (k * OW.OSZ) Hi T0) as (_ & x & y & z & Hin & (Px & Py & Pz) & (Aa & Ap & At)).
    pose proof (lid_xyz_lids x y z Hin) as Hlid.
    (* the ADD_FLOAT's value: lid - 340 *)
    replace (k * OW.OSZ + 136 + 4 * 7) with (k * OW.OSZ + O_POSY) in L, S by (unfold O_POSY, RAW_OFF; lia).
    rewrite Py in L. injection L as Eold. subst old.
    rewrite (CannonKeep.addf_lid y w Hlid Hw) in S.
    (* the poke: slot k at sL *)
    assert (VA : Mem.valid_access g Mint32 pool (k * OW.OSZ + OW.O_CMD) Readable)
      by exact (Mem.load_valid_access _ _ _ _ _ Lc).
    pose proof (pk_load_cmd g bC 28 VA) as LcL.
    assert (VmL : OW.vm_at G pool (pk g bC 28) k ObjInv.sL).
    { split; [ exists bC; split; [ exact HbC | exact LcL ] | split ].
      - rewrite pk_load by (right; right; unfold OW.O_SIDX, OW.O_CMD; lia). rewrite Ek in Hsi. exact Hsi.
      - intros n f Hn. destruct n; discriminate Hn. }
    assert (HQL : ObjFamily.Qfam (v_s st0) ObjInv.sL).
    { rewrite Ec. apply (ObjFamily.Qfam_start OW.CANS ObjInv.sL eq_refl).
      apply (proj1 (ObjFamily.memi_in _ _)). vm_compute. reflexivity. }
    (* the drop, on the poke: the ghost g1 *)
    pose proof (pkm_unch g bC 28 m U) as UL.
    pose proof (pkm_nv g bC 28 m NV bC _ ScrC Lc) as NVL.
    assert (VL : Mem.valid_block (pk g bC 28) pool).
    { unfold Mem.valid_block. rewrite pk_nb. exact (ObjInv.sym_valid lp bm bc oc0 SafeB g _ _ HP Hpool). }
    destruct (ObjRows.gr_store _ _ (pk g bC 28) m Mfloat32 pool _ _ m1 UL NVL VL S) as (g1 & Sg & U1 & NV1).
    assert (Lo1 : forall ch z0, (z0 + size_chunk ch <= k * OW.OSZ + O_POSY \/ k * OW.OSZ + O_POSY + 4 <= z0) ->
              (z0 + size_chunk ch <= k * OW.OSZ + OW.O_CMD \/ k * OW.OSZ + OW.O_CMD + 4 <= z0) ->
              Mem.load ch g1 pool z0 = Mem.load ch g pool z0).
    { intros ch z0 A B. rewrite (Mem.load_store_other _ _ _ _ _ _ Sg) by (right; cbn [size_chunk]; exact A).
      apply pk_load. right. exact B. }
    (* g1's trajectory pin: word 7, dropped, (A, P, t) = 0 *)
    assert (HCt : OW.can_traj G pool g k -> OW.can_traj G pool g1 k).
    { intros _ b o' Hb L'.
      assert (Lc1 : OW.ld32 g1 pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr 28))).
      { unfold OW.ld32. rewrite CM.load_eq.
        rewrite (Mem.load_store_other _ _ _ _ _ _ Sg) by (right; right; unfold O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia).
        exact LcL. }
      rewrite Lc1 in L'. injection L' as <- <-.
      rewrite Ptrofs.unsigned_repr by (change Ptrofs.max_unsigned with 4294967295; lia).
      change (OW.can_cl (OW.ccls 28) g1 pool (k * OW.OSZ)) with (OW.can7 g1 pool (k * OW.OSZ)).
      exists x, y, z. split; [ exact Hin | split; [ split; [ | split ] | split; [ | split ] ] ].
      - rewrite Lo1 by (unfold O_POSX, O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Px.
      - rewrite (Mem.load_store_same _ _ _ _ _ _ Sg). reflexivity.
      - rewrite Lo1 by (unfold O_POSZ, O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Pz.
      - rewrite Lo1 by (unfold OW.O_ACTION, O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Aa.
      - rewrite Lo1 by (unfold OW.O_PREVACT, O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Ap.
      - rewrite Lo1 by (unfold OW.O_TIMER, O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact At. }
    assert (EsL : v_s ObjInv.sL = OW.CANS) by exact eq_refl.
    assert (HviL : (7 <= v_i ObjInv.sL < 1000)%nat).
    { change (v_i ObjInv.sL) with 7%nat. split; [ apply le_n | ].
      assert (A : (7 < 1000)%nat) by lia. exact A. }
    pose proof (ObjExit.Vo_vm_at _ _ _ _ _ HV0) as Vm0.
    assert (HrL : forall la2 rs2, Genv.find_symbol G OLP._gObjectListArray = Some la2 ->
              OW.rings g pool la2 = Some rs2 -> In k (concat rs2)).
    { intros la2 rs2 Sl2 Hr2. exact (HXr _ HX la2 rs2 Sl2 Hr2). }
    Timeout 60 pose proof (CannonKeep.can_drop_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool k Hpool Hk
                  st0 ObjInv.sL y g (pk g bC 28) g1 ObjInv.sL_tab Vm0 Ec VmL EsL HviL Hlid Py (pc_of_P g HP) HrL
                  (fun ch' b z0 H => pk_load g bC 28 ch' b z0 H) (pk_perm g bC 28) (pk_nb g bC 28) (pk_nv g bC 28 ScrC)
                  HSafeB_scr HCt Sg) as Pc1.
    pose proof (P_of_pc _ Pc1) as Pg1.
    assert (Vo1 : Vo g1 ObjInv.sL).
    { destruct VmL as ((b1 & Hb1 & L1) & L2 & _). split; [ exists b1; split; [ exact Hb1 | ] | split ].
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Sg); [ exact L1 | right; right ].
        unfold O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Sg); [ exact L2 | right; right ].
        unfold O_POSY, RAW_OFF, OW.O_SIDX; cbn [size_chunk]; lia.
      - intros n f Hn. destruct n; discriminate Hn. }
    assert (X1 : X g1).
    { apply (HXm st0 ObjInv.sL g g1 HQL HP Pg1 HV0 Vo1); [ | | | exact HX ].
      - intros la2 Sl2.
        exact (CannonKeep.can_rings pool k st0 ObjInv.sL y g (pk g bC 28) g1 Ec EsL HviL
                 (fun ch' b z0 H => pk_load g bC 28 ch' b z0 H) (pk_nb g bC 28) Sg la2
                 (SNE _ _ _ _ Sl2 Hpool ltac:(vm_compute; discriminate))).
      - intros j Nj. exact (CannonKeep.can_cmd pool k st0 ObjInv.sL y g (pk g bC 28) g1 Ec EsL HviL
                 (fun ch' b z0 H => pk_load g bC 28 ch' b z0 H) (pk_nb g bC 28) Sg j Nj).
      - exact (CannonKeep.can_tsa lp pool k Hpool y g (pk g bC 28) g1 (fun ch' b z0 H => pk_load g bC 28 ch' b z0 H) Sg). }
    exists g1. split; [ exact (conj Pg1 (conj Vo1 X1)) | ].
    split; [ | exact (conj U1 NV1) ].
    rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg), pk_nb. exact Hgn.
  Qed.
  (* ---- 3. SET_HOME at the re-anchored ghost: ObjRows.home8_keep, PROVED.
     The ghost (GPL: slot k at sL, dropped, (A, P, t) = 0 by obj_w's word-7
     pin can7) takes the same three home stores (oHome := oPos, a window
     store keeping Pc: ObjFld.fld_pc_t, the word-7 pin reads no home cell,
     kt_home), then its command cell moves to word 8 (ObjExit.exit_pc; the
     word-8 pin can8 holds at the trajectory's start: oHome = oPos = lid -
     (0, 340, 0), (A, P, t) = 0, traj_b 0 0 0 0 0) ---- *)
  Lemma kt_home : forall g ga ch z0 v, Mem.store ch g pool z0 v = Some ga ->
    k * OW.OSZ + 356 <= z0 -> z0 + size_chunk ch <= k * OW.OSZ + 368 ->
    (forall b o, Genv.find_symbol G OW.CANS = Some b -> OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr b o) ->
       Ptrofs.unsigned o = 28) ->
    forall k', OW.can_traj G pool g k' -> OW.can_traj G pool ga k'.
  Proof.
    intros g ga ch z0 v S A B H28 k' T. pose proof (size_chunk_pos ch).
    assert (Lo : forall ch' off, 0 <= off -> off + size_chunk ch' <= OW.OSZ ->
              (k' <> k \/ off + size_chunk ch' <= 356 \/ 368 <= off) ->
              Mem.load ch' ga pool (k' * OW.OSZ + off) = Mem.load ch' g pool (k' * OW.OSZ + off)).
    { intros ch' off C1 C2 C3. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
      pose proof (size_chunk_pos ch'). unfold OW.OSZ in *.
      destruct (Z.lt_trichotomy k' k) as [L | [-> | L]]; [ left; nia | | right; nia ].
      destruct C3 as [C3 | [C3 | C3]]; [ exfalso; exact (C3 eq_refl) | left; lia | right; lia ]. }
    assert (Lc : OW.ld32 ga pool (k' * OW.OSZ + OW.O_CMD) = OW.ld32 g pool (k' * OW.OSZ + OW.O_CMD)).
    { unfold OW.ld32. rewrite !CM.load_eq. apply Lo; unfold OW.O_CMD, OW.OSZ; cbn [size_chunk]; lia. }
    destruct (Z.eq_dec k' k) as [-> | Nk].
    - intros b o Hb L'. rewrite Lc in L'. pose proof (T b o Hb L') as Tc. rewrite (H28 b o Hb L') in Tc |- *.
      change (OW.can_cl (OW.ccls 28) g pool (k * OW.OSZ)) with (OW.can7 g pool (k * OW.OSZ)) in Tc.
      change (OW.can_cl (OW.ccls 28) ga pool (k * OW.OSZ)) with (OW.can7 ga pool (k * OW.OSZ)).
      destruct Tc as (x & y & z & Hin & (Px & Py & Pz) & (Aa & Ap & At)).
      exists x, y, z. split; [ exact Hin | split; [ split; [ | split ] | split; [ | split ] ] ];
        (rewrite Lo; [ assumption | .. ]);
        unfold O_POSX, O_POSY, O_POSZ, OW.O_ACTION, OW.O_PREVACT, OW.O_TIMER, RAW_OFF, OW.OSZ; cbn [size_chunk]; lia.
    - apply (OW.can_traj_eq G pool g ga k'); [ | exact Lc | exact T ].
      intros ch' off Hoff Hch. assert (Hs : size_chunk ch' = 4) by (destruct Hch as [-> | ->]; reflexivity).
      apply Lo; [ | | left; exact Nk ]; unfold OW.traj_offs in Hoff; cbn [In] in Hoff; rewrite Hs;
        destruct Hoff as [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]]]];
        unfold O_POSX, O_POSY, O_POSZ, OW.O_ACTION, OW.O_PREVACT, OW.O_TIMER, OW.O_HOMEX, OW.O_HOMEY, OW.O_HOMEZ,
          RAW_OFF, OW.OSZ; lia.
  Qed.

  (* a home store keeps Pc and the word-7 command *)
  Lemma home_st : forall g ga i v, Pc g -> 55 <= i <= 57 ->
    (forall b o, Genv.find_symbol G OW.CANS = Some b -> OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr b o) ->
       Ptrofs.unsigned o = 28) ->
    Mem.store Mfloat32 g pool (k * OW.OSZ + 136 + 4 * i) (Vsingle v) = Some ga ->
    Pc ga /\ (forall b o, Genv.find_symbol G OW.CANS = Some b -> OW.ld32 ga pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr b o) ->
       Ptrofs.unsigned o = 28).
  Proof.
    intros g ga i v Hg Hi H28 S. split.
    - refine (ObjFld.fld_pc_t lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool k Hpool 356 368 _ g ga Mfloat32 _ _ Hg _ I S
                (kt_home g ga Mfloat32 _ _ S ltac:(lia) ltac:(cbn [size_chunk]; lia) H28)).
      + split; [ lia | split; [ lia | ] ]. intros off e _ _ Hu. unfold FieldWin.ucl in Hu. lia.
      + cbn [size_chunk]. lia.
    - intros b o Hb L. apply (H28 b o Hb). rewrite <- L. unfold OW.ld32. rewrite !CM.load_eq.
      symmetry. apply (Mem.load_store_other _ _ _ _ _ _ S). right. right. unfold OW.O_CMD. cbn [size_chunk]. lia.
  Qed.

  Theorem home8 : ObjRows.home8_keep lp bm bc oc0 SafeB pool (k * OW.OSZ) bcc nb0 X.
  Proof.
    intros g m f1 f2 f3 m1 m2 m3 (HP & HV & HX) (Hgn & U & NV) L1 S1 L2 S2 L3 S3.
    pose proof HV as ((bC & HbC & Lc) & Hsi & _).
    assert (ScrC : scr bC) by (exists OW.CANS; split; [ exact (in_map v_s vm_tab _ ObjInv.sL_tab) | exact HbC ]).
    assert (Npb : pool <> bcc) by (apply (SNE _ _ _ _ Hpool Hbcc); vm_compute; discriminate).
    assert (ldg : forall g' m' ch z0, Mem.unchanged_on Pfr g' m' -> Mem.valid_block g' pool ->
              z0 + size_chunk ch <= k * OW.OSZ + OW.O_CMD -> Mem.load ch m' pool z0 = Mem.load ch g' pool z0).
    { intros g' m' ch z0 U' V' H. apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U' V').
      intros i Hi. split; [ exact Npb | intros (_ & Hi'); lia ]. }
    (* the word-7 pin: dropped, (A, P, t) = 0 *)
    pose proof HP as (_ & _ & _ & _ & _ & How).
    destruct How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & W1 & W2 & W3 & W4 & W5 & W6 & W7 & C).
    rewrite Hpool in W1. injection W1 as <-.
    pose proof (HXr g HX la rs W2 (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as Hkr.
    destruct (OW.ow_pin _ _ _ _ _ _ _ _ _ _ _ _ C k Hkr) as (_ & _ & _ & T).
    assert (Lc' : OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr 28)))
      by (unfold OW.ld32; rewrite CM.load_eq; exact Lc).
    assert (H28 : forall b o, Genv.find_symbol G OW.CANS = Some b ->
              OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr b o) -> Ptrofs.unsigned o = 28).
    { intros b o _ L. rewrite Lc' in L. injection L as _ <-.
      rewrite Ptrofs.unsigned_repr by (change Ptrofs.max_unsigned with 4294967295; lia). reflexivity. }
    pose proof (T bC _ HbC Lc') as T0.
    rewrite Ptrofs.unsigned_repr in T0 by (change Ptrofs.max_unsigned with 4294967295; lia).
    change (OW.can_cl (OW.ccls 28) g pool (k * OW.OSZ)) with (OW.can7 g pool (k * OW.OSZ)) in T0.
    destruct T0 as (x & y & z & Hin & (Px & Py & Pz) & (Aa & Ap & At)).
    pose proof (ObjInv.sym_valid lp bm bc oc0 SafeB g _ _ HP Hpool) as Vp.
    (* the three home stores, real and ghost *)
    rewrite (ldg g m Mfloat32 (k * OW.OSZ + 136 + 4 * 6) U Vp ltac:(unfold OW.O_CMD; cbn [size_chunk]; lia)) in L1.
    replace (k * OW.OSZ + 136 + 4 * 6) with (k * OW.OSZ + O_POSX) in L1 by (unfold O_POSX, RAW_OFF; lia).
    rewrite Px in L1. injection L1 as E1. subst f1.
    destruct (ObjRows.gr_store _ _ g m Mfloat32 pool _ _ m1 U NV Vp S1) as (ga & Sa & Ua & NVa).
    pose proof (Mem.store_valid_block_1 _ _ _ _ _ _ Sa _ Vp) as Va.
    rewrite (ldg ga m1 Mfloat32 (k * OW.OSZ + 136 + 4 * 7) Ua Va ltac:(unfold OW.O_CMD; cbn [size_chunk]; lia)) in L2.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Sa) in L2 by (right; cbn [size_chunk]; lia).
    replace (k * OW.OSZ + 136 + 4 * 7) with (k * OW.OSZ + O_POSY) in L2 by (unfold O_POSY, RAW_OFF; lia).
    rewrite Py in L2. injection L2 as E2. subst f2.
    destruct (ObjRows.gr_store _ _ ga m1 Mfloat32 pool _ _ m2 Ua NVa Va S2) as (gb & Sb & Ub & NVb).
    pose proof (Mem.store_valid_block_1 _ _ _ _ _ _ Sb _ Va) as Vb.
    rewrite (ldg gb m2 Mfloat32 (k * OW.OSZ + 136 + 4 * 8) Ub Vb ltac:(unfold OW.O_CMD; cbn [size_chunk]; lia)) in L3.
    rewrite (Mem.load_store_other _ _ _ _ _ _ Sb) in L3 by (right; cbn [size_chunk]; lia).
    rewrite (Mem.load_store_other _ _ _ _ _ _ Sa) in L3 by (right; cbn [size_chunk]; lia).
    replace (k * OW.OSZ + 136 + 4 * 8) with (k * OW.OSZ + O_POSZ) in L3 by (unfold O_POSZ, RAW_OFF; lia).
    rewrite Pz in L3. injection L3 as E3. subst f3.
    destruct (ObjRows.gr_store _ _ gb m2 Mfloat32 pool _ _ m3 Ub NVb Vb S3) as (gc & Sc & Uc & NVc).
    destruct (home_st g ga 55 _ (pc_of_P g HP) ltac:(lia) H28 Sa) as (Pa & Ha).
    destruct (home_st ga gb 56 _ Pa ltac:(lia) Ha Sb) as (Pb & Hb).
    destruct (home_st gb gc 57 _ Pb ltac:(lia) Hb Sc) as (Pcc & _).
    (* gc reads g's cells off the home cells *)
    assert (Lgc : forall ch z0, (z0 + size_chunk ch <= k * OW.OSZ + 356 \/ k * OW.OSZ + 368 <= z0) ->
              Mem.load ch gc pool z0 = Mem.load ch g pool z0).
    { intros ch z0 Hz.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sc) by (right; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sb) by (right; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sa) by (right; cbn [size_chunk]; lia). reflexivity. }
    assert (Lgco : forall ch b z0, b <> pool -> Mem.load ch gc b z0 = Mem.load ch g b z0).
    { intros ch b z0 N.
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sc) by (left; exact N).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sb) by (left; exact N).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sa) by (left; exact N). reflexivity. }
    assert (Lcc : Mem.load Mint32 gc pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr 28)))
      by (rewrite Lgc by (unfold OW.O_CMD; cbn [size_chunk]; lia); exact Lc).
    (* the poke: slot k at s8 *)
    set (g8 := pk gc bC 32).
    assert (VA : Mem.valid_access gc Mint32 pool (k * OW.OSZ + OW.O_CMD) Readable)
      by exact (Mem.load_valid_access _ _ _ _ _ Lcc).
    pose proof (pk_load_cmd gc bC 32 VA) as Lc8.
    assert (L8 : forall ch z0, (z0 + size_chunk ch <= k * OW.OSZ + 356 \/ k * OW.OSZ + 368 <= z0) ->
              (z0 + size_chunk ch <= k * OW.OSZ + OW.O_CMD \/ k * OW.OSZ + OW.O_CMD + 4 <= z0) ->
              Mem.load ch g8 pool z0 = Mem.load ch g pool z0).
    { intros ch z0 A B. unfold g8. rewrite pk_load by (right; exact B). exact (Lgc ch z0 A). }
    assert (L8o : forall ch b z0, b <> pool -> Mem.load ch g8 b z0 = Mem.load ch g b z0).
    { intros ch b z0 N. unfold g8. rewrite pk_load by (left; exact N). exact (Lgco ch b z0 N). }
    assert (Vgc : OW.vm_at G pool gc k ObjInv.sL).
    { split; [ exists bC; split; [ exact HbC | exact Lcc ] | split ].
      - rewrite Lgc by (unfold OW.O_SIDX; cbn [size_chunk]; lia). exact Hsi.
      - intros n f Hn. destruct n; discriminate Hn. }
    assert (V8 : OW.vm_at G pool g8 k ObjInv.s8).
    { split; [ exists bC; split; [ exact HbC | exact Lc8 ] | split ].
      - unfold g8. rewrite pk_load by (right; right; unfold OW.O_SIDX, OW.O_CMD; lia).
        rewrite Lgc by (unfold OW.O_SIDX; cbn [size_chunk]; lia). exact Hsi.
      - intros n f Hn. destruct n; discriminate Hn. }
    assert (HQ8 : ObjFamily.Qfam (v_s ObjInv.sL) ObjInv.s8).
    { apply (ObjFamily.Qfam_start OW.CANS ObjInv.s8 eq_refl).
      apply (proj1 (ObjFamily.memi_in _ _)). vm_compute. reflexivity. }
    (* the word-8 pin at the trajectory's start *)
    assert (HCt : OW.can_traj G pool gc k -> OW.can_traj G pool g8 k).
    { intros _ b o' Hb L'. unfold OW.ld32 in L'. rewrite CM.load_eq, Lc8 in L'. injection L' as <- <-.
      rewrite Ptrofs.unsigned_repr by (change Ptrofs.max_unsigned with 4294967295; lia).
      change (OW.can_cl (OW.ccls 32) g8 pool (k * OW.OSZ)) with (OW.can8 g8 pool (k * OW.OSZ)).
      exists x, y, z, 0, 0, Int.zero, Int.zero, Int.zero.
      rewrite Z.mul_0_r, !Z.add_0_r.
      split; [ exact Hin | split; [ split; [ | split ] | split; [ split; [ | split ] | split; [ split; [ | split ] | ] ] ] ].
      - unfold g8. rewrite pk_load by (right; left; unfold OW.O_HOMEX, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Sc) by (right; unfold OW.O_HOMEX, RAW_OFF; cbn [size_chunk]; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Sb) by (right; unfold OW.O_HOMEX, RAW_OFF; cbn [size_chunk]; lia).
        replace (k * OW.OSZ + OW.O_HOMEX) with (k * OW.OSZ + 136 + 4 * 55) by (unfold OW.O_HOMEX, RAW_OFF; lia).
        rewrite (Mem.load_store_same _ _ _ _ _ _ Sa). reflexivity.
      - unfold g8. rewrite pk_load by (right; left; unfold OW.O_HOMEY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia).
        rewrite (Mem.load_store_other _ _ _ _ _ _ Sc) by (right; unfold OW.O_HOMEY, RAW_OFF; cbn [size_chunk]; lia).
        replace (k * OW.OSZ + OW.O_HOMEY) with (k * OW.OSZ + 136 + 4 * 56) by (unfold OW.O_HOMEY, RAW_OFF; lia).
        rewrite (Mem.load_store_same _ _ _ _ _ _ Sb). reflexivity.
      - unfold g8. rewrite pk_load by (right; left; unfold OW.O_HOMEZ, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia).
        replace (k * OW.OSZ + OW.O_HOMEZ) with (k * OW.OSZ + 136 + 4 * 57) by (unfold OW.O_HOMEZ, RAW_OFF; lia).
        rewrite (Mem.load_store_same _ _ _ _ _ _ Sc). reflexivity.
      - rewrite L8 by (unfold O_POSX, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Px.
      - rewrite L8 by (unfold O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Py.
      - rewrite L8 by (unfold O_POSZ, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Pz.
      - rewrite L8 by (unfold OW.O_ACTION, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Aa.
      - rewrite L8 by (unfold OW.O_PREVACT, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Ap.
      - rewrite L8 by (unfold OW.O_TIMER, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact At.
      - vm_compute. reflexivity. }
    pose proof (ObjExit.exit_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool bcc k Hpool Hbcc HSafeB_scr gc g8
                  Pcc (pk_unch gc bC 32) (pk_nv gc bC 32 ScrC) ObjInv.sL ObjInv.s8 ObjInv.sL_tab ObjInv.s8_tab
                  Vgc V8 HQ8 ltac:(intros _; cbn; lia) HCt) as Pc8.
    pose proof (P_of_pc _ Pc8) as Pg8.
    assert (Vo8 : Vo g8 ObjInv.s8).
    { destruct V8 as (Hc8 & Hs8 & _). split; [ exact Hc8 | split; [ exact Hs8 | ] ].
      intros n f Hn. destruct n; discriminate Hn. }
    assert (X8 : X g8).
    { apply (HXm ObjInv.sL ObjInv.s8 g g8 HQ8 HP Pg8 HV Vo8); [ | | | exact HX ].
      - intros la2 Sl2. assert (Npl : la2 <> pool) by exact (SNE _ _ _ _ Sl2 Hpool ltac:(vm_compute; discriminate)).
        apply (CannonKeep.rings_eq' g g8 pool la2).
        + intros j off Hoff. unfold OW.ld32. rewrite !CM.load_eq.
          apply L8; destruct Hoff as [-> | ->]; unfold OW.O_PREV, OW.O_NEXT, OW.O_CMD, OW.OSZ; cbn [size_chunk];
            solve [ left; nia | right; nia ].
        + intros z0. unfold OW.ld32. rewrite !CM.load_eq. exact (L8o Mint32 la2 z0 Npl).
      - intros j Nj. unfold OW.ld32. rewrite !CM.load_eq. unfold OW.O_CMD, OW.OSZ.
        assert (Nj' : j < k \/ k < j) by lia.
        apply L8; cbn [size_chunk]; unfold OW.O_CMD; destruct Nj' as [Lj | Lj]; solve [ left; nia | right; nia ].
      - unfold OW.tsa. destruct (Genv.find_symbol G surface_load._gTimeStopState) as [bt |] eqn:Et; [ | reflexivity ].
        rewrite (L8o _ _ _ (SNE _ _ _ _ Et Hpool ltac:(vm_compute; discriminate))). reflexivity. }
    exists g8. split; [ exact (conj Pg8 (conj Vo8 X8)) | ].
    split; [ | split ].
    - unfold g8. rewrite pk_nb, (Mem.nextblock_store _ _ _ _ _ _ Sc), (Mem.nextblock_store _ _ _ _ _ _ Sb),
        (Mem.nextblock_store _ _ _ _ _ _ Sa). exact Hgn.
    - exact (pkm_unch gc bC 32 m3 Uc).
    - exact (pkm_nv gc bC 32 m3 NVc bC (Ptrofs.repr 28) ScrC Lcc).
  Qed.
End AN.
