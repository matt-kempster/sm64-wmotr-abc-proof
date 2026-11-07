(* ====================================================================== *)
(* CollKeep (GOAL 2): one store of detect_object_collisions keeps the     *)
(* object phase's invariant (ClearKeep.Pc), 2026-11-06.                   *)
(*                                                                        *)
(* object_collision.c writes, of a gObjectPool slot k, only its           *)
(* collision cells (coll_cell): collidedObjInteractTypes (112),           *)
(* numCollidedObjs (118, s16), collidedObjs[0..3] (120..136), and         *)
(* rawData words 5 (oIntangibleTimer, 156) and 66 (400).  coll_store_pc:  *)
(* such a store keeps Pc when the value is what the code stores           *)
(* (coll_val):                                                            *)
(*   - collidedObjs[i] := another slot (detect_object_hitbox_overlap      *)
(*     stores b into a and a into b, two objects of walked lists), and    *)
(*     when k is Mario's slot, a slot that is not his and whose kind      *)
(*     obj_w pins (ow_mario's kind_ok: every listed object but Mario);    *)
(*   - numCollidedObjs := a value in [0, 4] (the code tests >= 4 first),  *)
(*     and for Mario's slot each entry below it old or such a slot;       *)
(*   - the other three cells: any int.                                    *)
(* Readers: PhiW (RenderKeep.k_all_wc: owinc misses the cells; Mario's    *)
(* entries after are old or new far objects, CKo / CKn), obj_w            *)
(* (PollKeep.obj_w_slots_c: SKc misses them; ow_ncoll / ow_mcoll          *)
(* re-made), plat_still (angular velocity cells 276..288), mem_ok         *)
(* (ClearKeep.safe_store_g: an int or a pool pointer into the pool).      *)
(* PHANTOM CHECK: nothing is quantified beyond Pc and the stored value;   *)
(* the value facts are what the walk of the real code supplies.           *)
(* Used by CollWalk (the walk of the real detect_object_collisions).      *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area platform_displacement.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.ClosedMem.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ClearKeep UnloadRows BhvVM.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.

(* ---------------------------------------------------------------------- *)
(* 1. The cells and their arithmetic.                                      *)
(* ---------------------------------------------------------------------- *)
Definition coll_cell (off : Z) (ch : memory_chunk) : Prop :=
  (off = 112 /\ ch = Mint32) \/ (off = 118 /\ ch = Mint16signed)
  \/ (exists i, 0 <= i < 4 /\ off = 120 + 4 * i /\ ch = Mint32)
  \/ (off = 156 /\ ch = Mint32) \/ (off = 400 /\ ch = Mint32).

Lemma cc_range : forall off ch, coll_cell off ch -> 112 <= off /\ off + size_chunk ch <= 404.
Proof.
  intros off ch [(-> & ->) | [(-> & ->) | [(i & Hi & -> & ->) | [(-> & ->) | (-> & ->)]]]]; cbn [size_chunk]; lia.
Qed.

(* a slot field off the collision cells (or of another slot) misses them *)
Lemma dj_ccl : forall off ch k k' off' sz, coll_cell off ch -> 0 <= off' -> off' + sz <= 608 -> 0 <= sz ->
  (k' <> k \/ OW.ccl off' (off' + sz)) ->
  k' * 608 + off' + sz <= k * 608 + off \/ k * 608 + off + size_chunk ch <= k' * 608 + off'.
Proof.
  intros off ch k k' off' sz Hc H1 H2 H3 H4. pose proof (cc_range off ch Hc) as (R1 & R2).
  destruct (Z.lt_trichotomy k' k) as [Hlt | [-> | Hgt]]; [ left; nia | | right; nia ].
  destruct H4 as [N | C]; [ congruence | ]. unfold OW.ccl in C.
  destruct Hc as [(-> & ->) | [(-> & ->) | [(i & Hi & -> & ->) | [(-> & ->) | (-> & ->)]]]]; cbn [size_chunk]; lia.
Qed.

(* two collision cells: the same, or apart *)
Lemma cc_same : forall off ch off' ch' k k', coll_cell off ch -> coll_cell off' ch' ->
  (k' = k /\ off' = off /\ ch' = ch)
  \/ k' * 608 + off' + size_chunk ch' <= k * 608 + off \/ k * 608 + off + size_chunk ch <= k' * 608 + off'.
Proof.
  intros off ch off' ch' k k' Hc Hc'. pose proof (cc_range off ch Hc) as (R1 & R2).
  pose proof (cc_range off' ch' Hc') as (R1' & R2').
  destruct (Z.lt_trichotomy k' k) as [Hlt | [-> | Hgt]]; [ right; left; nia | | right; right; nia ].
  destruct Hc as [(-> & ->) | [(-> & ->) | [(i & Hi & -> & ->) | [(-> & ->) | (-> & ->)]]]];
  destruct Hc' as [(-> & ->) | [(-> & ->) | [(i' & Hi' & -> & ->) | [(-> & ->) | (-> & ->)]]]];
    cbn [size_chunk];
    first [ solve [ left; auto ]
          | right; lia
          | destruct (Z.eq_dec i i') as [<- | Ne]; [ left; auto | right; lia ] ].
Qed.

(* a WMotR object kind of a slot is a collided object's fact *)
Lemma kind_coll : forall pool m j, 0 <= j < OW.NSLOT -> OW.kind_ok pool m j -> coll_obj_ok m (OW.slot_v pool j).
Proof.
  intros pool m j Hj (t & Lt & Hin & Hp & Hc & _ & _).
  assert (U : Ptrofs.unsigned (Ptrofs.repr (j * OW.OSZ)) = j * OW.OSZ)
    by (apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *; change Ptrofs.max_unsigned with 4294967295; lia).
  exists pool, (Ptrofs.repr (j * OW.OSZ)), t. rewrite U. split; [ reflexivity | exact (conj Lt (conj Hin (conj Hp Hc))) ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The store keep.                                                      *)
(* ---------------------------------------------------------------------- *)
Section CS.
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
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  Lemma SNE : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. Qed.

  (* slot k is Mario's (gMarioObject) *)
  Definition mario_at (pool gmo : block) (m : mem) (k : Z) : Prop :=
    Mem.load Mint32 m gmo 0 = Some (OW.slot_v pool k).

  (* what the code stores into slot k's collision cell at off *)
  Definition coll_val (pool gmo : block) (m : mem) (k off : Z) (v : val) : Prop :=
    (off = 118 -> exists x, v = Vint x /\ Int.sign_ext 16 x = x /\ 0 <= Int.signed x <= 4
       /\ (mario_at pool gmo m k -> forall i, 0 <= i < Int.signed x ->
             (exists n, Mem.load Mint16signed m pool (k * OW.OSZ + 118) = Some (Vint n) /\ i < Int.signed n)
             \/ (exists j, 0 <= j < OW.NSLOT /\ j <> k /\ OW.kind_ok pool m j
                  /\ Mem.load Mint32 m pool (k * OW.OSZ + 120 + 4 * i) = Some (OW.slot_v pool j))))
    /\ (120 <= off < 136 -> exists j, v = OW.slot_v pool j /\ 0 <= j < OW.NSLOT
          /\ (mario_at pool gmo m k -> j <> k /\ OW.kind_ok pool m j))
    /\ (off = 112 \/ off = 156 \/ off = 400 -> exists x, v = Vint x).

  Theorem coll_store_pc : forall m m2 pool gmo k off ch v,
    Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gMarioObject = Some gmo ->
    0 <= k < OW.NSLOT -> coll_cell off ch -> coll_val pool gmo m k off v ->
    Mem.store ch m pool (k * OW.OSZ + off) v = Some m2 ->
    Pc m -> Pc m2.
  Proof.
    intros m m2 pool gmo k off ch v Sp Sg Hk Hc Hv St (Ok & Hphi & HD & Hst & How).
    pose proof (cc_range off ch Hc) as Rc.
    (* the value: an int, or a pool pointer *)
    assert (VP : forall bb oo, v = Vptr bb oo -> bb = pool).
    { intros bb oo Ev. destruct Hv as (V1 & V2 & V3).
      destruct Hc as [(-> & ->) | [(-> & ->) | [(i & Hi & -> & ->) | [(-> & ->) | (-> & ->)]]]].
      - destruct (V3 ltac:(auto)) as (x & Ex). congruence.
      - destruct (V1 eq_refl) as (x & Ex & _). congruence.
      - destruct (V2 ltac:(lia)) as (j & Ej & _). rewrite Ev in Ej. unfold OW.slot_v in Ej. congruence.
      - destruct (V3 ltac:(auto)) as (x & Ex). congruence.
      - destruct (V3 ltac:(auto)) as (x & Ex). congruence. }
    (* loads off the pool *)
    assert (LO : forall ch' b z', b <> pool -> Mem.load ch' m2 b z' = Mem.load ch' m b z').
    { intros ch' b z' Nb. eapply Mem.load_store_other; [ exact St | left; exact Nb ]. }
    assert (LPd : forall ch' z', z' + size_chunk ch' <= k * OW.OSZ + off \/ k * OW.OSZ + off + size_chunk ch <= z' ->
              Mem.load ch' m2 pool z' = Mem.load ch' m pool z').
    { intros ch' z' H. eapply Mem.load_store_other; [ exact St | right; exact H ]. }
    (* a slot field off the collision cells, or of another slot *)
    assert (LPs : forall ch' k' off', 0 <= off' -> off' + size_chunk ch' <= 608 ->
              (k' <> k \/ OW.ccl off' (off' + size_chunk ch')) ->
              Mem.load ch' m2 pool (k' * OW.OSZ + off') = Mem.load ch' m pool (k' * OW.OSZ + off')).
    { intros ch' k' off' H1 H2 H3. apply LPd. pose proof (size_chunk_pos ch').
      destruct (dj_ccl off ch k k' off' (size_chunk ch') Hc H1 H2 ltac:(lia) H3); unfold OW.OSZ; [ left | right ]; lia. }
    (* a collision cell: the written one, or kept *)
    assert (LPc : forall k' off' ch', coll_cell off' ch' ->
              (k' = k /\ off' = off /\ ch' = ch
               /\ Mem.load ch' m2 pool (k' * OW.OSZ + off') = Some (Val.load_result ch v))
              \/ Mem.load ch' m2 pool (k' * OW.OSZ + off') = Mem.load ch' m pool (k' * OW.OSZ + off')).
    { intros k' off' ch' Hc'. destruct (cc_same off ch off' ch' k k' Hc Hc') as [(-> & -> & ->) | D].
      - left. split; [ reflexivity | split; [ reflexivity | split; [ reflexivity | ] ] ].
        exact (Mem.load_store_same _ _ _ _ _ _ St).
      - right. apply LPd. unfold OW.OSZ. exact D. }
    (* obj_w's pieces *)
    pose proof How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Sp in S1. injection S1 as <-. rewrite Sg in S5. injection S5 as <-.
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (km & Hkm & Lg & Lb & KO).
    assert (Hpl : pool <> la) by (apply (SNE _ _ _ _ Sp S2); vm_compute; discriminate).
    assert (Rkm : 0 <= km < OW.NSLOT).
    { pose proof (proj1 (ObjRing.rings_iff pool m la rs Hpl) (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as (_ & Henc).
      destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc0 & _).
      exact (ObjRing.chain_range pool m _ _ _ Hc0 km Hkm). }
    assert (Hkc : In km (concat rs))
      by (destruct rs as [| l rs']; [ destruct Hkm | cbn [concat nth] in Hkm |- *; apply in_or_app; left; exact Hkm ]).
    assert (Uj : forall j, 0 <= j < OW.NSLOT -> u (Ptrofs.repr (j * OW.OSZ)) = j * OW.OSZ)
      by (intros j Hj; apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *;
          change Ptrofs.max_unsigned with 4294967295; lia).
    assert (Ukm : u (Ptrofs.repr (km * OW.OSZ)) = km * OW.OSZ) by exact (Uj km Rkm).
    assert (Bpl : bm <> pool) by (apply (SNE _ _ _ _ Hbm_sym Sp); vm_compute; discriminate).
    assert (Gpl : gmo <> pool) by (apply (SNE _ _ _ _ Sg Sp); vm_compute; discriminate).
    assert (LBM : forall ch' z', Mem.load ch' m2 bm z' = Mem.load ch' m bm z') by (intros; apply LO; exact Bpl).
    set (Q := fun co : ptrofs => exists j, 0 <= j < OW.NSLOT /\ u co = j * OW.OSZ).
    (* Mario's collided objects and usedObj are slots *)
    assert (SQ : forall v0 co, OW.slot_ptr pool v0 -> v0 = Vptr pool co -> Q co).
    { intros v0 co [-> | (j & Hj & ->)] E; [ discriminate E | ].
      unfold OW.slot_v in E. injection E as <-. exists j. split; [ exact Hj | exact (Uj j Hj) ]. }
    assert (QC : forall i0 co, 0 <= i0 < 4 ->
              Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i0) = Some (Vptr pool co) -> Q co).
    { intros i0 co Hi0 Lc. rewrite Ukm in Lc.
      destruct (OW.ow_mcoll _ _ _ _ _ _ _ _ _ _ _ _ C km Rkm Lg i0 Hi0) as (v0 & Lv & Sv).
      unfold OW.O_COLLS, COLL_OFF in *. rewrite Lc in Lv. injection Lv as <-. exact (SQ _ co Sv eq_refl). }
    assert (QU : forall uo, Mem.load Mint32 m bm USED_OFF = Some (Vptr pool uo) -> Q uo).
    { intros uo Lu. destruct (OW.ow_stale _ _ _ _ _ _ _ _ _ _ _ _ C 128 ltac:(cbn; auto)) as (v0 & Lv & Sv).
      unfold USED_OFF in Lu. rewrite Lu in Lv. injection Lv as <-. exact (SQ _ uo Sv eq_refl). }
    (* a new collided object of Mario's *)
    assert (NEW : forall j, 0 <= j < OW.NSLOT -> j <> km -> OW.kind_ok pool m j ->
              coll_new bm m pool (Ptrofs.repr (km * OW.OSZ)) Q (Ptrofs.repr (j * OW.OSZ))).
    { intros j Hj Nj Kj. unfold coll_new. rewrite Ukm, (Uj j Hj).
      split; [ exists j; split; [ exact Hj | exact (Uj j Hj) ] | ].
      split; [ unfold OW.OSZ; destruct (Z.lt_trichotomy j km) as [H | [H | H]];
               [ left; nia | contradiction | right; nia ] | ].
      split; [ | exact (kind_coll pool m j Hj Kj) ].
      intros uo Lu. destruct (QU uo Lu) as (j' & Hj' & Eu). rewrite Eu.
      destruct (Z.lt_trichotomy j j') as [H | [<- | H]];
        [ right; left; unfold OW.OSZ; nia | left | right; right; unfold OW.OSZ; nia ].
      rewrite <- (Ptrofs.repr_unsigned uo), Eu. reflexivity. }
    (* Mario's collided-object cells after: old, or a new such object *)
    assert (CE : forall i v0, 0 <= i < 4 -> Mem.load Mint32 m2 pool (km * OW.OSZ + 120 + 4 * i) = Some v0 ->
              Mem.load Mint32 m pool (km * OW.OSZ + 120 + 4 * i) = Some v0
              \/ exists j, v0 = OW.slot_v pool j /\ 0 <= j < OW.NSLOT /\ j <> km /\ OW.kind_ok pool m j).
    { intros i v0 Hi Hl. rewrite <- Z.add_assoc in Hl |- *.
      destruct (LPc km (120 + 4 * i) Mint32 ltac:(right; right; left; exists i; split; [ exact Hi | split; reflexivity ]))
        as [(Ek & Eo & Ech & L2) | L2].
      - right. subst k off ch. destruct Hv as (_ & V2 & _). destruct (V2 ltac:(lia)) as (j & Ej & Hj & Mj).
        destruct (Mj Lg) as (Nj & Kj). subst v. rewrite L2 in Hl. unfold OW.slot_v in Hl |- *. cbn [Val.load_result Archi.ptr64] in Hl.
        injection Hl as <-. exists j. split; [ reflexivity | auto ].
      - left. rewrite <- L2. exact Hl. }
    (* ---- mem_ok ---- *)
    assert (SBp : SafeB pool) by exact (UnloadRows.pool_safe lp bm bc oc0 SafeB m pool Ok How Sp).
    assert (Ok' : mem_ok_lp bm MWF m2).
    { eapply ClearKeep.safe_store_g with (g := OLP._gObjectPool); try eassumption; try (vm_compute; reflexivity).
      intros _ bb oo Ev. rewrite (VP bb oo Ev). exact SBp. }
    (* ---- PhiW ---- *)
    assert (Phi' : phiw lp bm m2).
    { assert (Lmo : Mem.load Mint32 m bm 136 = Some (Vptr pool (Ptrofs.repr (km * OW.OSZ)))) by exact Lb.
      assert (NB : Ple (Mem.nextblock m) (Mem.nextblock m2))
        by (rewrite (Mem.nextblock_store _ _ _ _ _ _ St); apply Ple_refl).
      assert (PM : forall b o k0 p, Plt b (Mem.nextblock m) -> Mem.perm m b o k0 p -> Mem.perm m2 b o k0 p)
        by (intros b o k0 p _ Hp; exact (Mem.perm_store_1 _ _ _ _ _ _ St _ _ _ _ Hp)).
      assert (HXs : forall id, In id ([] : list ident) -> existsb (Pos.eqb id) core_ids = false)
        by (intros id []).
      assert (HXl : forall id, In id ([] : list ident) -> existsb (Pos.eqb id) lvl_rd_ids = false)
        by (intros id []).
      assert (Nbm : ~ rgb lp [] bm) by (intros (id & [] & _)).
      assert (RGa : forall b, rgb lp [] b -> b <> pool /\ AnimWorld.tab_apart G m b)
        by (intros b (id & [] & _)).
      assert (LD : forall ch' b z', ~ rgb lp [] b -> b <> bm ->
                (b <> pool \/ owinc Q (Ptrofs.repr (km * OW.OSZ)) ch' z') -> Mem.load ch' m2 b z' = Mem.load ch' m b z').
      { assert (LPw : forall ch' z' j, j * 608 <= z' -> z' + size_chunk ch' <= j * 608 + 608 ->
                  (j <> k \/ OW.ccl (z' - j * 608) (z' - j * 608 + size_chunk ch')) ->
                  Mem.load ch' m2 pool z' = Mem.load ch' m pool z').
        { intros ch' z' j H1 H2 H3.
          replace z' with (j * OW.OSZ + (z' - j * OW.OSZ)) by (unfold OW.OSZ; lia).
          apply LPs; unfold OW.OSZ; [ lia | lia | exact H3 ]. }
        intros ch' b z' _ _ [Nb | Hw]; [ exact (LO _ _ _ Nb) | ].
        destruct (eq_block b pool) as [-> | Nb]; [ | exact (LO _ _ _ Nb) ].
        unfold owinc, ccl_at in Hw. rewrite Ukm in Hw. unfold OW.OSZ in Hw. pose proof (size_chunk_pos ch').
        destruct Hw as [Hw | [Hw | [Hw | [Hw | (co & (j & Hj & Ec) & _ & Hw)]]]].
        - apply (LPw ch' z' km); [ lia | lia | ].
          destruct (Z.eq_dec km k) as [E | Ne]; [ right; unfold OW.ccl; lia | left; exact Ne ].
        - apply (LPw ch' z' km); [ lia | lia | ].
          destruct (Z.eq_dec km k) as [E | Ne]; [ right; unfold OW.ccl; lia | left; exact Ne ].
        - apply (LPw ch' z' km); [ lia | lia | ].
          destruct (Z.eq_dec km k) as [E | Ne]; [ right; unfold OW.ccl; lia | left; exact Ne ].
        - apply (LPw ch' z' km); [ lia | lia | ].
          destruct (Z.eq_dec km k) as [E | Ne]; [ right; unfold OW.ccl; lia | left; exact Ne ].
        - rewrite Ec in Hw. unfold OW.OSZ in Hw. apply (LPw ch' z' j); [ lia | lia | ].
          destruct (Z.eq_dec j k) as [E | Ne]; [ right; unfold OW.ccl; lia | left; exact Ne ]. }
      assert (CL : forall gp, closed_by gp m -> gp pool <> None ->
                (forall id b, Genv.find_symbol G id = Some b -> gp b <> None) ->
                exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m2).
      { intros gp HC Gp _. exists gp. split; [ intros b H; exact H | ].
        apply (store_mapped_closed gp m ch pool (k * OW.OSZ + off) v m2 HC); [ exact (ClearKeep.flat_bg gp m pool HC Gp) | | exact St ].
        apply (ClearKeep.inj_symv gp m v HC). intros b o Ev. rewrite (VP b o Ev). exact Gp. }
      assert (FR : forall bt0 ot0 k0, In k0 hs_ids ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + 60) = Some (Vptr bt0 ot0) ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + 72) = Some (Vint Int.zero) ->
                (exists f, -1 <= f <= hs_le k0
                   /\ Mem.load Mint16signed m pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))) ->
                buf_ok m bt0 ot0 k0 -> u ot0 + BUFSZ < Ptrofs.modulus ->
                exists f, -1 <= f <= hs_le k0
                  /\ Mem.load Mint16signed m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))).
      { intros bt0 ot0 k0 _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ]. rewrite Ukm in *.
        rewrite LPs; [ exact L64 | lia | cbn [size_chunk]; lia | right; unfold OW.ccl; cbn [size_chunk]; lia ]. }
      assert (CKo : forall i cb co, 0 <= i < 4 ->
                Mem.load Mint32 m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
                Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co)
                \/ (cb = pool /\ coll_new bm m pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
      { intros i cb co Hi Hl. rewrite Ukm in *. unfold COLL_OFF in *.
        destruct (CE i _ Hi Hl) as [L | (j & Ej & Hj & Nj & Kj)]; [ left; exact L | right ].
        unfold OW.slot_v in Ej. injection Ej as -> ->. split; [ reflexivity | exact (NEW j Hj Nj Kj) ]. }
      assert (CKn : forall n, Mem.load Mint16signed m pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n) ->
                exists n', Mem.load Mint16signed m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n')
                /\ (n' = n \/ 0 <= Int.signed n' <= 4)
                /\ forall i v0, 0 <= i < Int.signed n' -> i < 4 ->
                     Mem.load Mint32 m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0 ->
                     (exists n0, Mem.load Mint16signed m pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n0)
                        /\ i < Int.signed n0
                        /\ Mem.load Mint32 m pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0)
                     \/ (exists co, v0 = Vptr pool co /\ coll_new bm m pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
      { intros n Ln. rewrite Ukm in *. unfold NUMCOLL_OFF, COLL_OFF in *.
        destruct (OW.ow_ncoll _ _ _ _ _ _ _ _ _ _ _ _ C km Hkc) as (n1 & Ln1 & Rn1).
        unfold OW.O_NCOLL in Ln1. rewrite Ln in Ln1. injection Ln1 as <-.
        destruct (LPc km 118 Mint16signed ltac:(right; left; split; reflexivity)) as [(Ek & Eo & Ech & L2) | L2].
        - subst k off ch. destruct Hv as (V1 & _ & _). destruct (V1 eq_refl) as (x & -> & Sx & Rx & Mx).
          exists x. split; [ rewrite L2; cbn [Val.load_result]; rewrite Sx; reflexivity | split; [ right; exact Rx | ] ].
          intros i v0 Hi Hi4 Hl.
          rewrite LPd in Hl by (unfold OW.OSZ; cbn [size_chunk]; lia).
          destruct (Mx Lg i Hi) as [(n0 & Ln0 & Hn0) | (j & Hj & Nj & Kj & Lj)].
          + left. exists n0. exact (conj Ln0 (conj Hn0 Hl)).
          + right. rewrite Lj in Hl. injection Hl as <-. exists (Ptrofs.repr (j * OW.OSZ)).
            split; [ reflexivity | exact (NEW j Hj Nj Kj) ].
        - exists n. split; [ rewrite L2; exact Ln | split; [ left; reflexivity | ] ].
          intros i v0 Hi Hi4 Hl.
          destruct (CE i v0 ltac:(lia) Hl) as [Lv | (j & -> & Hj & Nj & Kj)].
          + left. exists n. exact (conj Ln (conj (proj2 Hi) Lv)).
          + right. exists (Ptrofs.repr (j * OW.OSZ)). split; [ reflexivity | exact (NEW j Hj Nj Kj) ]. }
      eapply k_all_wc with (lp := lp) (bm := bm) (Xs := []) (Qt := fun _ : ptrofs => False);
        first [ exact HXs | exact HXl | exact Lmo | exact NB | exact PM | exact LD
              | exact (fun ch' z' (_ : bmk ch' z') => LBM ch' z') | exact Hbm_sym
              | exact Nbm | exact Bpl | exact RGa | exact CL | exact FR
              | exact (fun i0 co Hi0 Lc => or_introl (QC i0 co Hi0 Lc))
              | exact (fun a uo (_ : Mem.load Mint32 m bm 12 = Some (Vint a)) (_ : In (Int.unsigned a) used_acts) Lu => QU uo Lu)
              | solve [ intros ? [] ] | solve [ intros ? ? [] ]
              | exact CKo | exact CKn | exact Hphi | exact (phiw_surf_apart lp bm _ m Hphi) ]. }
    (* ---- the A-held bit ---- *)
    assert (HD' : a_down_real bm m2 = false).
    { pose proof Ok as (_ & _ & HM). pose proof HM as (_ & _ & R2 & _).
      assert (Bcp : bc <> pool) by (apply (SNE _ _ _ _ Hbc_sym Sp); vm_compute; discriminate).
      rewrite <- HD. unfold a_down_real. rewrite (LBM Mptr 156).
      destruct (Mem.load Mptr m bm 156) as [v0 |] eqn:E; [ | reflexivity ].
      destruct v0; try reflexivity.
      destruct (R2 _ _ eq_refl) as (-> & _).
      rewrite (LO _ _ _ Bcp). reflexivity. }
    (* ---- plat_still: an object's angular velocity (276..288) ---- *)
    assert (Hst' : PlatformKeep.plat_still lp m2).
    { intros bp v0 Hbp Hl0.
      assert (Npp : bp <> pool) by (apply (SNE _ _ _ _ Hbp Sp); vm_compute; discriminate).
      rewrite LO in Hl0 by exact Npp.
      destruct (Hst bp v0 Hbp Hl0) as [Hz | (pb & po & -> & Hpb0 & Hk0 & Hal)]; [ left; exact Hz | right ].
      rewrite Sp in Hpb0. injection Hpb0 as <-.
      exists pool, po. split; [ reflexivity | split; [ exact Sp | split; [ | exact Hal ] ] ].
      intros k0 Hk0'. destruct Hal as (j & Hj & Ej).
      assert (Hk0r : 35 <= k0 <= 37) by (cbn in Hk0'; lia).
      specialize (Hk0 k0 Hk0'). cbn [Mem.loadv] in Hk0 |- *.
      assert (Eu : u (Ptrofs.add po (Ptrofs.repr (136 + 4 * k0))) = j * OW.OSZ + (136 + 4 * k0)).
      { rewrite Ptrofs.add_unsigned, Ej, (Ptrofs.unsigned_repr (136 + 4 * k0))
          by (change Ptrofs.max_unsigned with 4294967295; lia).
        unfold OW.OSZ. apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; lia. }
      rewrite Eu in Hk0 |- *.
      rewrite LPs; [ exact Hk0 | lia | cbn [size_chunk]; lia | right; unfold OW.ccl; cbn [size_chunk]; lia ]. }
    (* ---- obj_w: PollKeep.obj_w_slots_c, the pool's collision cells ---- *)
    assert (SKc : forall pool', Genv.find_symbol G OLP._gObjectPool = Some pool' -> PollKeep.SKc m m2 pool').
    { intros pool' Hs'. rewrite Sp in Hs'. injection Hs' as <-. intros ch' k' off' H1 H2 H3 H4.
      apply LPs; [ lia | unfold OW.OSZ in H2; exact H2 | right; exact H4 ]. }
    assert (How' : OW.obj_w G bm m2).
    { apply (PollKeep.obj_w_slots_c m m2 G bm); [ | exact SKc | | | | | | | exact How ].
      - intros id b Hin Hn Hs ch' z'. apply LO. intros ->.
        assert (E : id = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; eassumption). subst id.
        vm_compute in Hn. discriminate Hn.
      - apply (PollKeep.surf_keep_of_KN m m2 G); [ | exact SKc | ].
        + intros id b Hin Hne Hs ch' z'. apply LO. intros ->. apply Hne. eapply Genv.genv_vars_inj; eassumption.
        + intros b Hb ch' z'. apply LO. intros ->. pose proof (Genv.genv_symb_range _ _ Sp). unfold Plt, Ple in *. lia.
      - intros (a & Hg & Hb). exists a. split; [ | exact Hb ]. apply (PollKeep.gcell_K m m2); [ | exact Hg ].
        intros b Hs ch' z'. apply LO. apply (SNE _ _ _ _ Hs Sp). vm_compute. discriminate.
      - intros z _. apply LBM.
      - intros s b Hin Hs ch' z'. apply LO. intros ->.
        assert (Es : s = OLP._gObjectPool) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Sp ]).
        subst s. refine (PollKeep.not_in_of_existsb _ _ _ Hin); vm_compute; reflexivity.
      - intros pool' rs' Hs' Cn k' Hk'. rewrite Sp in Hs'. injection Hs' as <-.
        destruct (Cn k' Hk') as (n & Ln & Rn). unfold OW.O_NCOLL in *.
        destruct (LPc k' 118 Mint16signed ltac:(right; left; split; reflexivity)) as [(Ek & Eo & Ech & L2) | L2].
        + subst k' off ch. destruct Hv as (V1 & _ & _). destruct (V1 eq_refl) as (x & -> & Sx & Rx & _).
          exists x. rewrite L2. cbn [Val.load_result]. rewrite Sx. split; [ reflexivity | exact Rx ].
        + exists n. rewrite L2. exact (conj Ln Rn).
      - intros pool' gmo' Hs' Hg' Cm k' Hk' Lg' i Hi. rewrite Sp in Hs'. injection Hs' as <-.
        rewrite Sg in Hg'. injection Hg' as <-.
        rewrite LO in Lg' by exact Gpl.
        destruct (Cm k' Hk' Lg' i Hi) as (v0 & Lv & Sv). unfold OW.O_COLLS in *.
        rewrite <- Z.add_assoc in Lv |- *.
        destruct (LPc k' (120 + 4 * i) Mint32 ltac:(right; right; left; exists i; split; [ exact Hi | split; reflexivity ]))
          as [(Ek & Eo & Ech & L2) | L2].
        + subst k' off ch. destruct Hv as (_ & V2 & _). destruct (V2 ltac:(lia)) as (j & -> & Hj & _).
          exists (OW.slot_v pool j). rewrite L2. unfold OW.slot_v. cbn [Val.load_result Archi.ptr64].
          split; [ reflexivity | right; exists j; split; [ exact Hj | reflexivity ] ].
        + exists v0. rewrite L2. exact (conj Lv Sv). }
    exact (conj Ok' (conj Phi' (conj HD' (conj Hst' How')))).
  Qed.
End CS.
