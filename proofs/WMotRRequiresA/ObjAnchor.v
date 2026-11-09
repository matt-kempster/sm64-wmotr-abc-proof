(* ======================================================================= *)
(* ObjAnchor.v -- the RE-ANCHOR of INV_k's ghost at bhvCannon's word 6    *)
(* (GOAL 2 objects, 2026-11-09).                                           *)
(*                                                                         *)
(* INV_k's ghost g is a Pobjl memory with slot k at the update's start     *)
(* state st0.  Inside the cannon's prologue (ObjInv.inP: words 0..6, the   *)
(* update started in it) obj_w's cannon pin D holds slot k at its lid's y. *)
(* Word 6, ADD_FLOAT(oPosY, -340), drops it to lid - 340, and the ghost    *)
(* follows by RE-ANCHORING (anchor = ObjRows.anc_keep, PROVED here):       *)
(*   1. gL: g with slot k's command cell at bhvCannon + 28 (ObjInv.sL;      *)
(*      the stack is empty there and at st0): a Pobjl memory by            *)
(*      ObjExit.exit_pc (the exit's own keeper; the cell is a Pfr-excluded  *)
(*      VM cell), the ghost fact by xf_cou's shape (HXa);                  *)
(*   2. the store of lid - 340 into gL's oPosY: Pobjl by                    *)
(*      CannonKeep.can_drop_pc, the ghost fact by xf_st's shape (HXs);     *)
(*   3. GR: the real memory differs from gL off Pfr only (the store is the *)
(*      same store; the command cell is a VM cell, its old bytes a          *)
(*      script pointer's).                                                 *)
(* No premise: the ghost fact's transfer lemmas are ObjStep's (xf_cou /     *)
(* xf_st / xf_ring, PROVED for the objects step's XR / XT).                *)
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
From SM64.Proofs.WMotRRequiresA Require ObjExit ObjInv ObjRows CannonKeep.
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
  (* the ghost fact's transfers (ObjStep: xf_cou, xf_st, xf_ring) *)
  Hypothesis HXa : ObjFamily.Qfam (v_s st0) ObjInv.sL -> forall g m', Pobjl g -> Vo g st0 -> Mem.unchanged_on Pfr g m' -> Pobjl m' -> Vo m' ObjInv.sL ->
    X g -> X m'.
  Hypothesis HXs : forall m m1, Pobjl m -> Pobjl m1 ->
    (forall la, Genv.find_symbol G OLP._gObjectListArray = Some la -> OW.rings m1 pool la = OW.rings m pool la) ->
    (forall j, OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 m pool (j * OW.OSZ + OW.O_CMD)) ->
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

  (* ---- 1. the poke: slot k's command cell set to bhvCannon + 28 ---- *)
  Section PK.
    Variable g : mem.
    Variable bC : block.
    Local Transparent Mem.load.

    Definition pk_c : PMap.t (ZMap.t memval) :=
      PMap.set pool (Mem.setN (encode_val Mint32 (Vptr bC (Ptrofs.repr 28))) (oc + OW.O_CMD)
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
      exists q n, ZMap.get o ((Mem.mem_contents pk) !! pool) = Fragment (Vptr bC (Ptrofs.repr 28)) q n.
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
      Mem.load Mint32 pk pool (oc + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr 28)).
    Proof.
      intros Vg. unfold Mem.load.
      destruct (Mem.valid_access_dec pk Mint32 pool (oc + OW.O_CMD) Readable) as [A | A];
        [ | exfalso; exact (A Vg) ].
      apply (f_equal Some). cbn [Mem.mem_contents pk]. unfold pk_c. rewrite PMap.gss.
      rewrite <- (dec_enc bC (Ptrofs.repr 28)) at 2. apply (f_equal (decode_val Mint32)).
      change (size_chunk_nat Mint32) with (List.length (encode_val Mint32 (Vptr bC (Ptrofs.repr 28)))).
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
    (* slot k is in a ring; obj_w's cannon pin D: at index <= 6 it sits at a lid's y *)
    pose proof HP as (_ & _ & _ & _ & _ & How).
    destruct How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    pose proof (HXr g HX la rs S2 (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as Hkr.
    destruct (OW.ow_pin _ _ _ _ _ _ _ _ _ _ _ _ C k Hkr) as (_ & _ & D).
    assert (Lc' : OW.ld32 g pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr bC (Ptrofs.repr (4 * Z.of_nat (v_i st0)))))
      by (unfold OW.ld32; rewrite CM.load_eq; exact Lc).
    destruct (D bC _ HbC Lc') as [(_ & lid & Hlid & Ly) | Hge].
    2: { exfalso. assert (A : 0 <= 4 * Z.of_nat (v_i st0) <= Ptrofs.max_unsigned)
           by (change Ptrofs.max_unsigned with 4294967295; lia).
         rewrite (Ptrofs.unsigned_repr _ A) in Hge. lia. }
    (* the ADD_FLOAT's value: lid - 340 *)
    replace (k * OW.OSZ + 136 + 4 * 7) with (k * OW.OSZ + O_POSY) in L, S by (unfold O_POSY, RAW_OFF; lia).
    rewrite Ly in L. injection L as Eold. subst old.
    rewrite (CannonKeep.addf_lid lid w Hlid Hw) in S.
    (* 1. the poke: slot k at sL *)
    assert (VA : Mem.valid_access g Mint32 pool (k * OW.OSZ + OW.O_CMD) Readable)
      by exact (Mem.load_valid_access _ _ _ _ _ Lc).
    pose proof (pk_load_cmd g bC VA) as LcL.
    assert (VoL : Vo (pk g bC) ObjInv.sL).
    { split; [ exists bC; split; [ exact HbC | exact LcL ] | split ].
      - rewrite pk_load by (right; right; unfold OW.O_SIDX, OW.O_CMD; lia). rewrite Ek in Hsi. exact Hsi.
      - intros n f Hn. destruct n; discriminate Hn. }
    pose proof (pk_unch g bC) as UgL.
    pose proof (pk_nv g bC ScrC) as NVgL.
    assert (HQL : ObjFamily.Qfam (v_s st0) ObjInv.sL).
    { rewrite Ec. apply (ObjFamily.Qfam_start OW.CANS ObjInv.sL eq_refl).
      apply (proj1 (ObjFamily.memi_in _ _)). vm_compute. reflexivity. }
    pose proof (ObjExit.exit_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool bcc k Hpool Hbcc HSafeB_scr g (pk g bC)
                  (pc_of_P g HP) UgL NVgL st0 ObjInv.sL H0 ObjInv.sL_tab
                  (ObjExit.Vo_vm_at _ _ _ _ _ HV0) (ObjExit.Vo_vm_at _ _ _ _ _ VoL) HQL
                  ltac:(intros _; cbn; lia)) as PL.
    pose proof (P_of_pc _ PL) as PgL.
    pose proof (HXa HQL g (pk g bC) HP HV0 UgL PgL VoL HX) as XL.
    (* 2. the store on the poke *)
    pose proof (pkm_unch g bC m U) as UL.
    pose proof (pkm_nv g bC m NV bC _ ScrC Lc) as NVL.
    assert (VL : Mem.valid_block (pk g bC) pool).
    { unfold Mem.valid_block. rewrite pk_nb. exact (ObjInv.sym_valid lp bm bc oc0 SafeB g _ _ HP Hpool). }
    destruct (ObjRows.gr_store _ _ (pk g bC) m Mfloat32 pool _ _ m1 UL NVL VL S) as (g1 & Sg & U1 & NV1).
    assert (LyL : Mem.load Mfloat32 (pk g bC) pool (k * OW.OSZ + O_POSY) = Some (f32z lid)).
    { rewrite pk_load by (right; left; unfold O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia). exact Ly. }
    assert (EsL : v_s ObjInv.sL = OW.CANS) by reflexivity.
    assert (HviL : (7 <= v_i ObjInv.sL < 1000)%nat).
    { change (v_i ObjInv.sL) with 7%nat. split; [ apply le_n | ].
      assert (A : (7 < 1000)%nat) by lia. exact A. }
    pose proof (ObjExit.Vo_vm_at _ _ _ _ _ VoL) as VmL.
    assert (HrL : forall la2 rs2, Genv.find_symbol G OLP._gObjectListArray = Some la2 ->
              OW.rings (pk g bC) pool la2 = Some rs2 -> In k (concat rs2)).
    { intros la2 rs2 Sl2 Hr2. exact (HXr _ XL la2 rs2 Sl2 Hr2). }
    pose proof (CannonKeep.can_drop_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym pool k Hpool Hk
                  ObjInv.sL lid (pk g bC) g1 ObjInv.sL_tab VmL EsL HviL Hlid LyL PL HrL Sg) as Pc1.
    pose proof (P_of_pc _ Pc1) as Pg1.
    assert (Vo1 : Vo g1 ObjInv.sL).
    { destruct VoL as ((b1 & Hb1 & L1) & L2 & _). split; [ exists b1; split; [ exact Hb1 | ] | split ].
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Sg); [ exact L1 | right; right ].
        unfold O_POSY, RAW_OFF, OW.O_CMD; cbn [size_chunk]; lia.
      - rewrite (Mem.load_store_other _ _ _ _ _ _ Sg); [ exact L2 | right; right ].
        unfold O_POSY, RAW_OFF, OW.O_SIDX; cbn [size_chunk]; lia.
      - intros n f Hn. destruct n; discriminate Hn. }
    assert (X1 : X g1).
    { apply (HXs (pk g bC) g1 PgL Pg1); [ | | | exact XL ].
      - intros la2 Sl2.
        exact (CannonKeep.can_rings lp pool k Hk ObjInv.sL lid (pk g bC) g1 VmL EsL HviL LyL HrL Sg la2
                 (SNE _ _ _ _ Sl2 Hpool ltac:(vm_compute; discriminate))).
      - intros j. exact (CannonKeep.can_cmd lp pool k Hk ObjInv.sL lid (pk g bC) g1 VmL EsL HviL LyL HrL Sg j).
      - unfold OW.tsa. destruct (Genv.find_symbol G surface_load._gTimeStopState) as [bt |] eqn:Et; [ | reflexivity ].
        rewrite (Mem.load_store_other _ _ _ _ _ _ Sg); [ reflexivity | left ].
        exact (SNE _ _ _ _ Et Hpool ltac:(vm_compute; discriminate)). }
    exists g1. split; [ exact (conj Pg1 (conj Vo1 X1)) | ].
    split; [ | exact (conj U1 NV1) ].
    rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg), pk_nb. exact Hgn.
  Qed.
End AN.
