(* ======================================================================= *)
(* CannonKeep.v -- bhvCannon's ADD_FLOAT(oPosY, -340) keeps the objects   *)
(* phase's invariant ClearKeep.Pc (GOAL 2 objects, 2026-11-09).            *)
(*                                                                         *)
(* bhvCannon's first update runs word 5 SET_INT(oInteractType,            *)
(* INTERACT_CANNON_BASE) and word 6 ADD_FLOAT(oPosY, -340): the base,      *)
(* spawned at its closed lid's y, drops to its home (the level data's      *)
(* cannon y - 350 = lid - 340; vm-checked here from the generated macro    *)
(* and script words).  can_drop_pc: in a Pc memory whose slot k0 runs      *)
(* bhvCannon past that prologue (VM index >= 7, so obj_w's cannon pin D    *)
(* reads the offset, not the height) and sits at a lid's y, the store of   *)
(* lid - 340 into its oPosY keeps Pc.  PROVED:                            *)
(*   - MWF_real: a float store into the pool forges no pointer;           *)
(*   - PhiW: RenderKeep.k_all_wc with the slot RE-PINNED (Qy): as a        *)
(*     collided object or usedObj it is a cannon base at a listed height   *)
(*     again (coll_obj_ok / cannon_obj_ok), never a pole (no lid is a     *)
(*     pole base); every other slot (Q) and Mario's own object are kept;  *)
(*   - obj_w: ObjVmSwap.obj_w_vm_swap with the VM kept and k0's oPosY      *)
(*     moved (Hy0): its kind is re-made (cannon_obj_ok / cannon_xz_ok at   *)
(*     the same x / z: the level data lists both heights), it is no pole   *)
(*     and no box (no lid is a box's y);                                   *)
(*   - the A gate reads bm and bc; plat_still reads ANGV (276..288).      *)
(* PHANTOM CHECK: the hypotheses are what the dispatch loop's real state   *)
(* has at word 6 (ObjRows.t_addf): the slot's start state is CANS@0 with  *)
(* its lid's y (pin D), re-anchored to CANS@7 (ObjAnchor).                 *)
(* ======================================================================= *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  area platform_displacement behavior_script interaction behavior_data macro_special_objects.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld AnimData AnimWorld RenderKeep BhvVM WMotRLevel.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ClearKeep BhvStep ObjFamily.
From SM64.Proofs.WMotRRequiresA Require ObjExit ObjVmSwap FieldWin.
From SM64.Proofs Require Interp.CMem.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module PK := PollKeep.
Module CM := SM64.Proofs.Interp.CMem.

(* ---------------------------------------------------------------------- *)
(* 1. The level data, vm-checked: a lid's y is no pole base and no box's   *)
(*    y; lid - 340 is a listed cannon height (lid + 10 - CANNON_SEAT);      *)
(*    a cannon entry at the lid's height has its x / z listed at lid - 340.*)
(* ---------------------------------------------------------------------- *)
Definition veqb (a b : val) : bool := if Val.eq a b then true else false.

Lemma veqb_true : forall a b, veqb a b = true -> a = b.
Proof. intros a b H. unfold veqb in H. destruct (Val.eq a b); [ exact e | discriminate H ]. Qed.

Lemma veqb_refl : forall a, veqb a a = true.
Proof. intros a. unfold veqb. destruct (Val.eq a a); [ reflexivity | contradiction ]. Qed.

Definition lid_chk : bool :=
  forallb (fun lid =>
     existsb (Z.eqb (lid + 10)) wmotr_cannon_list
     && forallb (fun bt => negb (veqb (f32z lid) (f32z (fst bt)))) wmotr_pole_list
     && forallb (fun xyz => negb (veqb (f32z lid) (f32z (snd (fst xyz))))) OW.box_xyz
     && forallb (fun xzy => negb (veqb (f32z (snd xzy - CANNON_SEAT)) (f32z lid))
                            || (existsb (fun xzy' => (fst (fst xzy) =? fst (fst xzy'))
                                                     && (snd (fst xzy) =? snd (fst xzy'))
                                                     && (snd xzy' =? snd xzy - 340)) wmotr_cannon_xzy
                                && veqb (f32z (snd xzy - 340 - CANNON_SEAT)) (f32z (lid - 340))))
          wmotr_cannon_xzy)
    OW.cannon_lids.

Lemma lid_chk_ok : lid_chk = true.
Proof. vm_compute. reflexivity. Qed.

Section LID.
  Variable lid : Z.
  Hypothesis Hlid : In lid OW.cannon_lids.

  Lemma lid_parts :
    existsb (Z.eqb (lid + 10)) wmotr_cannon_list = true
    /\ forallb (fun bt => negb (veqb (f32z lid) (f32z (fst bt)))) wmotr_pole_list = true
    /\ forallb (fun xyz => negb (veqb (f32z lid) (f32z (snd (fst xyz))))) OW.box_xyz = true
    /\ forallb (fun xzy => negb (veqb (f32z (snd xzy - CANNON_SEAT)) (f32z lid))
                            || (existsb (fun xzy' => (fst (fst xzy) =? fst (fst xzy'))
                                                     && (snd (fst xzy) =? snd (fst xzy'))
                                                     && (snd xzy' =? snd xzy - 340)) wmotr_cannon_xzy
                                && veqb (f32z (snd xzy - 340 - CANNON_SEAT)) (f32z (lid - 340))))
          wmotr_cannon_xzy = true.
  Proof.
    pose proof (proj1 (forallb_forall _ _) lid_chk_ok lid Hlid) as H. cbv beta in H.
    apply andb_prop in H as [H H4]. apply andb_prop in H as [H H3]. apply andb_prop in H as [H1 H2].
    exact (conj H1 (conj H2 (conj H3 H4))).
  Qed.

  Lemma lid_home : In (lid + 10) wmotr_cannon_list.
  Proof.
    destruct lid_parts as (H & _). apply existsb_exists in H as (y & Hy & E). apply Z.eqb_eq in E. subst y. exact Hy.
  Qed.

  Lemma lid_not_pole : forall base top, In (base, top) wmotr_pole_list -> f32z lid <> f32z base.
  Proof.
    intros base top Hin E. destruct lid_parts as (_ & H & _).
    pose proof (proj1 (forallb_forall _ _) H _ Hin) as A. cbn [fst] in A.
    rewrite E, veqb_refl in A. discriminate A.
  Qed.

  Lemma lid_not_box : forall x y z, In (x, y, z) OW.box_xyz -> f32z lid <> f32z y.
  Proof.
    intros x y z Hin E. destruct lid_parts as (_ & _ & H & _).
    pose proof (proj1 (forallb_forall _ _) H _ Hin) as A. cbn [fst snd] in A.
    rewrite E, veqb_refl in A. discriminate A.
  Qed.

  Lemma lid_xz : forall x z y, In (x, z, y) wmotr_cannon_xzy -> f32z (y - CANNON_SEAT) = f32z lid ->
    In (x, z, y - 340) wmotr_cannon_xzy /\ f32z (y - 340 - CANNON_SEAT) = f32z (lid - 340).
  Proof.
    intros x z y Hin E. destruct lid_parts as (_ & _ & _ & H).
    pose proof (proj1 (forallb_forall _ _) H _ Hin) as A. cbn [fst snd] in A.
    rewrite E, veqb_refl in A. cbn [negb orb] in A. apply andb_prop in A as [A1 A2].
    split; [ | exact (veqb_true _ _ A2) ].
    apply existsb_exists in A1 as (((x', z'), y') & Hin' & Eq). cbn [fst snd] in Eq.
    apply andb_prop in Eq as [Eq E3]. apply andb_prop in Eq as [E1 E2].
    apply Z.eqb_eq in E1. apply Z.eqb_eq in E2. apply Z.eqb_eq in E3. subst. exact Hin'.
  Qed.
End LID.

(* the ADD_FLOAT's value at a lid's y: lid - 340, exactly (vm-checked) *)
Definition addf_chk : bool :=
  forallb (fun lid => match word_at OW.CANS 6 with
                      | Some w => veqb (Vsingle (Float32.add (Float32.of_int (Int.repr lid)) (BhvStep.f32_of w)))
                                       (f32z (lid - 340))
                      | None => false end) OW.cannon_lids.

Lemma addf_chk_ok : addf_chk = true.
Proof. vm_compute. reflexivity. Qed.

Lemma addf_lid : forall lid w, In lid OW.cannon_lids -> word_at OW.CANS 6 = Some w ->
  Vsingle (Float32.add (Float32.of_int (Int.repr lid)) (BhvStep.f32_of w)) = f32z (lid - 340).
Proof.
  intros lid w Hin Hw. pose proof (proj1 (forallb_forall _ _) addf_chk_ok lid Hin) as A. cbv beta in A.
  rewrite Hw in A. exact (veqb_true _ _ A).
Qed.

(* the rings read the slots' list links only *)
Lemma ring_from_eq' : forall m m' pool hb,
  (forall z off, off = OW.O_PREV \/ off = OW.O_NEXT -> OW.ld32 m' pool (z * OW.OSZ + off) = OW.ld32 m pool (z * OW.OSZ + off)) ->
  (forall z, OW.ld32 m' hb z = OW.ld32 m hb z) ->
  forall n ho prev cur, OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
Proof.
  intros m m' pool hb Kp Kh n. induction n as [| n IH]; intros ho prev cur; cbn [OW.ring_from]; [ reflexivity | ].
  destruct cur; try reflexivity.
  destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned i) ho); [ rewrite Kh; reflexivity | ].
  destruct (eq_block b pool); [ | reflexivity ].
  destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
  destruct (PK.slot_of_eq _ _ E) as (Eo & _). rewrite Eo.
  rewrite (Kp z OW.O_PREV (or_introl eq_refl)), (Kp z OW.O_NEXT (or_intror eq_refl)).
  destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_PREV)); [ | reflexivity ].
  destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
  destruct (OW.veqb v prev); [ | reflexivity ].
  rewrite IH. reflexivity.
Qed.

Lemma rings_eq' : forall m m' pool la,
  (forall z off, off = OW.O_PREV \/ off = OW.O_NEXT -> OW.ld32 m' pool (z * OW.OSZ + off) = OW.ld32 m pool (z * OW.OSZ + off)) ->
  (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
  OW.rings m' pool la = OW.rings m pool la.
Proof.
  intros m m' pool la Kp Kl. unfold OW.rings.
  assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
  { apply map_ext. intros i. unfold OW.ring_i. rewrite Kl.
    destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
    apply ring_from_eq'; assumption. }
  rewrite E. reflexivity.
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. The store keep.                                                      *)
(* ---------------------------------------------------------------------- *)
Section CK.
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
  Hypothesis Hk0 : 0 <= k0 < OW.NSLOT.

  (* slot k0 runs bhvCannon past its prologue, at a lid's y, in a ring *)
  Variables (st : vst) (lid : Z) (g m1 : mem).
  Hypothesis Hst : In st vm_tab.
  Hypothesis V0 : OW.vm_at G pool g k0 st.
  Hypothesis Ecs : v_s st = OW.CANS.
  Hypothesis Hvi : (7 <= v_i st /\ v_i st < 1000)%nat.
  Hypothesis Hlid : In lid OW.cannon_lids.
  Hypothesis Ly : Mem.load Mfloat32 g pool (k0 * OW.OSZ + O_POSY) = Some (f32z lid).
  Hypothesis Hg : Pc g.
  Hypothesis Hring : forall la rs, Genv.find_symbol G OLP._gObjectListArray = Some la ->
    OW.rings g pool la = Some rs -> In k0 (concat rs).
  Hypothesis S : Mem.store Mfloat32 g pool (k0 * OW.OSZ + O_POSY) (f32z (lid - 340)) = Some m1.

  Lemma LO : forall ch' b z, b <> pool -> Mem.load ch' m1 b z = Mem.load ch' g b z.
  Proof. intros ch' b z N. exact (Mem.load_store_other _ _ _ _ _ _ S _ _ _ (or_introl N)). Qed.

  Lemma LOs : forall id b ch' z, Genv.find_symbol G id = Some b -> id <> OLP._gObjectPool ->
    Mem.load ch' m1 b z = Mem.load ch' g b z.
  Proof. intros id b ch' z Hs N. apply LO. exact (ObjExit.SNE lp _ _ _ _ Hs Hpool N). Qed.

  (* a cell of slot j: off slot k0's oPosY [164, 168) *)
  Lemma LPw : forall ch' z j, j * OW.OSZ <= z -> z + size_chunk ch' <= j * OW.OSZ + OW.OSZ ->
    (j <> k0 \/ z + size_chunk ch' <= k0 * OW.OSZ + 164 \/ k0 * OW.OSZ + 168 <= z) ->
    Mem.load ch' m1 pool z = Mem.load ch' g pool z.
  Proof.
    intros ch' z j A B C. apply (Mem.load_store_other _ _ _ _ _ _ S). right.
    pose proof (size_chunk_pos ch'). cbn [size_chunk]. unfold O_POSY, RAW_OFF, OW.OSZ in *.
    destruct (Z.lt_trichotomy j k0) as [L | [<- | L]]; [ left; nia | | right; nia ].
    destruct C as [C | [C | C]]; [ exfalso; exact (C eq_refl) | left; lia | right; lia ].
  Qed.

  Lemma LPs : forall ch' k off, 0 <= off -> off + size_chunk ch' <= OW.OSZ ->
    (k <> k0 \/ off + size_chunk ch' <= 164 \/ 168 <= off) ->
    Mem.load ch' m1 pool (k * OW.OSZ + off) = Mem.load ch' g pool (k * OW.OSZ + off).
  Proof.
    intros ch' k off A B C. apply (LPw ch' _ k); [ lia | lia | ].
    destruct (Z.eq_dec k k0) as [-> | Nk]; [ right | left; exact Nk ].
    destruct C as [C | C]; [ exfalso; exact (C eq_refl) | lia ].
  Qed.

  Lemma LPlo : forall ch' k off, 0 <= off -> off + size_chunk ch' <= 136 ->
    Mem.load ch' m1 pool (k * OW.OSZ + off) = Mem.load ch' g pool (k * OW.OSZ + off).
  Proof. intros ch' k off A B. apply LPs; [ lia | unfold OW.OSZ; lia | right; left; lia ]. Qed.

  Lemma Ly1 : Mem.load Mfloat32 m1 pool (k0 * OW.OSZ + O_POSY) = Some (f32z (lid - 340)).
  Proof. rewrite (Mem.load_store_same _ _ _ _ _ _ S). reflexivity. Qed.

  Lemma NV : BhvStep.nvB (fun _ => False) g m1.
  Proof. exact (BhvStep.nvB_store_c _ _ _ _ _ _ _ S I). Qed.

  Lemma NB : Mem.nextblock m1 = Mem.nextblock g.
  Proof. exact (Mem.nextblock_store _ _ _ _ _ _ S). Qed.

  Lemma Hbc_bm : bc <> bm.
  Proof. apply (ObjExit.SNE lp _ _ _ _ Hbc_sym Hbm_sym). vm_compute. discriminate. Qed.

  Lemma LObm : forall ch' z, Mem.load ch' m1 bm z = Mem.load ch' g bm z.
  Proof. intros ch' z. apply (LOs _ _ ch' z Hbm_sym). vm_compute. discriminate. Qed.

  Lemma ok1 : mem_ok_lp bm MWF m1.
  Proof.
    destruct Hg as ((Hv0 & Hnt & M) & _).
    split; [ exact (Mem.store_valid_block_1 _ _ _ _ _ _ S _ Hv0) | split ].
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
    destruct (Mem.load Mptr g bm 156) as [v1 |] eqn:E; [ | reflexivity ].
    destruct v1; try reflexivity.
    destruct (R2 _ _ eq_refl) as (-> & _).
    rewrite (LOs _ _ _ _ Hbc_sym); [ reflexivity | vm_compute; discriminate ].
  Qed.

  Lemma ps1 : PlatformKeep.plat_still lp m1.
  Proof.
    destruct Hg as (_ & _ & _ & Hst' & _).
    intros bp v1 Hbp Hl0.
    rewrite LO in Hl0 by exact (ObjExit.SNE lp _ _ _ _ Hbp Hpool ltac:(vm_compute; discriminate)).
    destruct (Hst' bp v1 Hbp Hl0) as [Hzz | (pb & po & -> & Hpb0 & Hkk & Hal)]; [ left; exact Hzz | right ].
    rewrite Hpool in Hpb0. injection Hpb0 as <-.
    exists pool, po. split; [ reflexivity | split; [ exact Hpool | split; [ | exact Hal ] ] ].
    intros kk Hkk'. destruct Hal as (j & Hj & Ej).
    assert (Hkr : 35 <= kk <= 37) by (cbn in Hkk'; lia).
    specialize (Hkk kk Hkk'). cbn [Mem.loadv] in Hkk |- *.
    assert (Eu : u (Ptrofs.add po (Ptrofs.repr (136 + 4 * kk))) = j * OW.OSZ + (136 + 4 * kk)).
    { rewrite Ptrofs.add_unsigned, Ej, (Ptrofs.unsigned_repr (136 + 4 * kk))
        by (change Ptrofs.max_unsigned with 4294967295; lia).
      unfold OW.OSZ. apply Ptrofs.unsigned_repr. change Ptrofs.max_unsigned with 4294967295; unfold OW.NSLOT in Hj; lia. }
    rewrite Eu in Hkk |- *.
    rewrite LPs; [ exact Hkk | lia | unfold OW.OSZ; cbn [size_chunk]; lia | right; right; lia ].
  Qed.

  Lemma CLm : forall gp, closed_by gp g -> closed_by gp m1.
  Proof. intros gp Hc. exact (ObjExit.nvB_closed _ gp g m1 Hc NV NB (fun b F => False_ind _ F)). Qed.

  (* ---- the slot's own facts ---- *)
  Lemma Uj : forall j, 0 <= j < OW.NSLOT -> u (Ptrofs.repr (j * OW.OSZ)) = j * OW.OSZ.
  Proof.
    intros j Hj. apply Ptrofs.unsigned_repr. unfold OW.OSZ, OW.NSLOT in *.
    change Ptrofs.max_unsigned with 4294967295; lia.
  Qed.

  (* k0 is not Mario's slot (Mario runs bhvMario) *)
  Lemma not_mario : forall gmo km, Genv.find_symbol G OLP._gMarioObject = Some gmo ->
    OW.mvm_ok G pool gmo g -> Mem.load Mint32 g gmo 0 = Some (OW.slot_v pool km) -> 0 <= km < OW.NSLOT -> km <> k0.
  Proof.
    intros gmo km Hgmo Cm Lg Hkm ->.
    destruct (Cm k0 Hkm Lg) as (stM & _ & EM & (b & Hb & Lb) & _).
    pose proof V0 as ((b0 & Hb0 & L0) & _). rewrite Lb in L0. injection L0 as <- _.
    assert (E : v_s st = v_s stM) by (eapply Genv.genv_vars_inj; [ exact Hb0 | exact Hb ]).
    rewrite Ecs, EM in E. vm_compute in E. discriminate E.
  Qed.

  (* the type cell is kept *)
  Lemma Lt1 : Mem.load Mint32 m1 pool (k0 * OW.OSZ + O_INTERACT_TYPE) = Mem.load Mint32 g pool (k0 * OW.OSZ + O_INTERACT_TYPE).
  Proof. apply LPs; unfold O_INTERACT_TYPE, RAW_OFF, OW.OSZ; cbn [size_chunk]; lia. Qed.

  Lemma no_pole : forall o, o = k0 * OW.OSZ -> ~ pole_obj_ok g pool o.
  Proof.
    intros o -> (base & top & Hin & L & _). rewrite Ly in L. injection L as E.
    exact (lid_not_pole lid Hlid base top Hin (f_equal Vsingle E)).
  Qed.

  Lemma no_low_pole : forall o, o = k0 * OW.OSZ -> ~ low_pole_obj g pool o.
  Proof.
    intros o -> (base & top & Hin & _ & L & _). rewrite Ly in L. injection L as E.
    exact (lid_not_pole lid Hlid base top Hin (f_equal Vsingle E)).
  Qed.

  Lemma can1 : cannon_obj_ok m1 pool (k0 * OW.OSZ).
  Proof.
    exists (lid + 10). split; [ exact (lid_home lid Hlid) | ].
    rewrite Ly1. replace (lid + 10 - CANNON_SEAT) with (lid - 340) by (unfold CANNON_SEAT; lia). reflexivity.
  Qed.

  Lemma xz1 : cannon_xz_ok g pool (k0 * OW.OSZ) -> cannon_xz_ok m1 pool (k0 * OW.OSZ).
  Proof.
    intros (x & z & y & Hin & Lx & Lyy & Lz). rewrite Ly in Lyy. injection Lyy as E.
    destruct (lid_xz lid Hlid x z y Hin (eq_sym (f_equal Vsingle E))) as (Hin' & E').
    exists x, z, (y - 340). split; [ exact Hin' | ].
    rewrite Ly1, <- E'.
    rewrite !LPs; [ exact (conj Lx (conj eq_refl Lz)) | .. ];
      unfold O_POSX, O_POSZ, RAW_OFF, OW.OSZ; cbn [size_chunk]; lia.
  Qed.

  (* the slot's kind, re-made *)
  Lemma kind1 : OW.kind_ok pool g k0 -> OW.kind_ok pool m1 k0.
  Proof.
    intros (t & Lt & Hin & Hp & Hc & Hpx & Hcx). exists t.
    split; [ rewrite Lt1; exact Lt | split; [ exact Hin | ] ].
    split; [ intros Et; exfalso; exact (no_pole _ eq_refl (Hp Et)) | ].
    split; [ intros _; exact can1 | ].
    split; [ intros Et; exfalso | intros Et; exact (xz1 (Hcx Et)) ].
    destruct (Hp Et) as (base & top & Hb & L & _). rewrite Ly in L. injection L as E.
    exact (lid_not_pole lid Hlid base top Hb (f_equal Vsingle E)).
  Qed.

  (* ---- PhiW ---- *)
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
    assert (Nk : km <> k0) by exact (not_mario gmo' km S5 (OW.ow_mvm _ _ _ _ _ _ _ _ _ _ _ _ C) Lg Rkm).
    assert (Ukm : u (Ptrofs.repr (km * OW.OSZ)) = km * OW.OSZ) by exact (Uj km Rkm).
    assert (Bpl : bm <> pool) by (apply (ObjExit.SNE lp _ _ _ _ Hbm_sym Hpool); vm_compute; discriminate).
    set (Q := fun co : ptrofs => exists j, 0 <= j < OW.NSLOT /\ j <> k0 /\ u co = j * OW.OSZ).
    set (Qy := fun co : ptrofs => u co = k0 * OW.OSZ).
    assert (SQ : forall v1 co, OW.slot_ptr pool v1 -> v1 = Vptr pool co -> Q co \/ Qy co).
    { intros v1 co [-> | (j & Hj & ->)] E; [ discriminate E | ].
      unfold OW.slot_v in E. injection E as <-.
      destruct (Z.eq_dec j k0) as [-> | Nj]; [ right; exact (Uj k0 Hk0) | left ].
      exists j. exact (conj Hj (conj Nj (Uj j Hj))). }
    assert (QC : forall i1 co, 0 <= i1 < 4 ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i1) = Some (Vptr pool co) ->
              Q co \/ (fun _ : ptrofs => False) co \/ Qy co).
    { intros i1 co Hi1 Lc. rewrite Ukm in Lc.
      destruct (OW.ow_mcoll _ _ _ _ _ _ _ _ _ _ _ _ C km Rkm Lg i1 Hi1) as (v1 & Lv & Sv).
      unfold OW.O_COLLS, COLL_OFF in *. rewrite Lc in Lv. injection Lv as <-.
      destruct (SQ _ co Sv eq_refl) as [H | H]; [ left; exact H | right; right; exact H ]. }
    assert (QU : forall a uo, Mem.load Mint32 g bm 12 = Some (Vint a) -> In (Int.unsigned a) used_acts ->
              Mem.load Mint32 g bm USED_OFF = Some (Vptr pool uo) -> Q uo \/ Qy uo).
    { intros a uo _ _ Lu. destruct (OW.ow_stale _ _ _ _ _ _ _ _ _ _ _ _ C 128 ltac:(right; right; left; reflexivity)) as (v1 & Lv & Sv).
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
      unfold owinc in Hw. rewrite Ukm in Hw. pose proof (size_chunk_pos ch').
      destruct Hw as [Hw | [Hw | [Hw | [Hw | (co & (j & Hj & Nj & Ec) & _ & Hw)]]]].
      - apply (LPw ch' z' km); unfold OW.OSZ in *; [ lia | lia | left; exact Nk ].
      - apply (LPw ch' z' km); unfold OW.OSZ in *; [ lia | lia | left; exact Nk ].
      - apply (LPw ch' z' km); unfold OW.OSZ in *; [ lia | lia | left; exact Nk ].
      - destruct Hw as (Hw1 & Hw2 & _).
        apply (LPw ch' z' km); unfold OW.OSZ in *; [ lia | lia | left; exact Nk ].
      - rewrite Ec in Hw. destruct Hw as (Hw1 & Hw2 & _).
        apply (LPw ch' z' j); unfold OW.OSZ in *; [ lia | lia | left; exact Nj ]. }
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
      rewrite LPlo; [ exact L64 | lia | cbn [size_chunk]; lia ]. }
    assert (CKo : forall i cb co, 0 <= i < 4 ->
              Mem.load Mint32 m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co)
              \/ (cb = pool /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros i cb co Hi Hl. left. rewrite Ukm in *. unfold COLL_OFF in *. rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPlo in Hl; [ exact Hl | lia | cbn [size_chunk]; lia ]. }
    assert (CKn : forall n0, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n0) ->
              exists n', Mem.load Mint16signed m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n')
              /\ (n' = n0 \/ 0 <= Int.signed n' <= 4)
              /\ forall i v1, 0 <= i < Int.signed n' -> i < 4 ->
                   Mem.load Mint32 m1 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v1 ->
                   (exists n1, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n1)
                      /\ i < Int.signed n1
                      /\ Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v1)
                   \/ (exists co, v1 = Vptr pool co /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros n0 Ln. rewrite Ukm in *. unfold NUMCOLL_OFF, COLL_OFF in *. exists n0.
      split; [ rewrite LPlo; [ exact Ln | lia | cbn [size_chunk]; lia ] | ].
      split; [ left; reflexivity | ].
      intros i v1 Hi Hi4 Hl. left. exists n0. split; [ exact Ln | split; [ lia | ] ].
      rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPlo in Hl; [ exact Hl | lia | cbn [size_chunk]; lia ]. }
    (* the re-pinned slot *)
    assert (QyK : forall co, Qy co ->
              (pool <> pool \/ co = Ptrofs.repr (km * OW.OSZ) \/ u co + OBJ_SIZE <= u (Ptrofs.repr (km * OW.OSZ))
               \/ u (Ptrofs.repr (km * OW.OSZ)) + OBJ_SIZE <= u co) ->
              coll_obj_ok g (Vptr pool co) -> coll_obj_ok m1 (Vptr pool co)).
    { intros co Eq _ (b & o & t & E & Lt & Hin & Hp & Hc). injection E as <- <-.
      unfold Qy in Eq. rewrite Eq in *.
      exists pool, co, t. split; [ reflexivity | ]. rewrite Eq.
      split; [ rewrite Lt1; exact Lt | split; [ exact Hin | split ] ].
      - intros Et. exfalso. exact (no_pole _ eq_refl (Hp Et)).
      - intros _. exact can1. }
    assert (QyP : forall co, Qy co -> (u co + 608 <= u (Ptrofs.repr (km * OW.OSZ)) \/ u (Ptrofs.repr (km * OW.OSZ)) + 608 <= u co) ->
              low_pole_obj g pool (u co) -> low_pole_obj m1 pool (u co)).
    { intros co Eq _ Hl. unfold Qy in Eq. rewrite Eq in *. exfalso. exact (no_low_pole _ eq_refl Hl). }
    assert (QyN : forall co, Qy co -> (u co + 608 <= u (Ptrofs.repr (km * OW.OSZ)) \/ u (Ptrofs.repr (km * OW.OSZ)) + 608 <= u co) ->
              cannon_obj_ok g pool (u co) -> cannon_obj_ok m1 pool (u co)).
    { intros co Eq _ _. unfold Qy in Eq. rewrite Eq. exact can1. }
    eapply k_all_wc with (lp := lp) (bm := bm) (Xs := @nil ident) (Qt := fun _ : ptrofs => False) (Qy := Qy);
      first [ exact HXs | exact HXl | exact Lb | exact NB' | exact PM | exact LD
            | exact (fun ch' z' (_ : bmk ch' z') => LObm ch' z') | exact Hbm_sym
            | exact Nbm | exact Bpl | exact RGa | exact CL | exact FR
            | exact QC | exact QU | exact QyK | exact QyP | exact QyN
            | solve [ intros ? [] ] | solve [ intros ? ? [] ]
            | exact CKo | exact CKn | exact Hphi | exact (phiw_surf_apart lp bm _ g Hphi) ].
  Qed.

  (* ---- obj_w: ObjVmSwap's keeper, the VM kept and k0's oPosY moved ---- *)
  Lemma V1 : OW.vm_at G pool m1 k0 st.
  Proof.
    destruct V0 as ((b & Hs & L1) & L2 & F).
    pose proof (PK.vm_depth st Hst) as Dp.
    split; [ exists b; rewrite LPs by (unfold OW.O_CMD, OW.OSZ; cbn [size_chunk]; lia); exact (conj Hs L1) | split ].
    - rewrite LPs by (unfold OW.O_SIDX, OW.OSZ; cbn [size_chunk]; lia). exact L2.
    - intros n f Hn. pose proof (F n f Hn) as Fn.
      assert (Hlt : (n < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn; discriminate).
      unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
      rewrite LPs by (unfold OW.O_STK, OW.OSZ; cbn [size_chunk]; lia). exact Fn.
  Qed.

  Lemma ow1 : OW.obj_w G bm m1.
  Proof.
    destruct Hg as (_ & _ & _ & _ & How).
    pose proof How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    assert (Hkr : In k0 (concat rs)) by exact (Hring la rs S2 (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)).
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (km & Hkm & Lg & Lb & KO).
    assert (Hpl : pool <> la) by (apply (ObjExit.SNE lp _ _ _ _ Hpool S2); vm_compute; discriminate).
    assert (Rkm : 0 <= km < OW.NSLOT).
    { pose proof (proj1 (ObjRing.rings_iff pool g la rs Hpl) (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as (_ & Henc).
      destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc0 & _).
      exact (ObjRing.chain_range pool g _ _ _ Hc0 km Hkm). }
    assert (Nk : km <> k0) by exact (not_mario gmo' km S5 (OW.ow_mvm _ _ _ _ _ _ _ _ _ _ _ _ C) Lg Rkm).
    pose proof (KO k0 Hkr (fun E => Nk (eq_sym E))) as Kk.
    destruct (OW.ow_pin _ _ _ _ _ _ _ _ _ _ _ _ C k0 Hkr) as (T0 & _ & _).
    (* the VM's script: CANS, not POLES *)
    assert (RP : OW.runs G pool g k0 OW.POLES = false).
    { rewrite (ObjVmSwap.runs_vm_at G pool g k0 st OW.POLES V0), Ecs. vm_compute. reflexivity. }
    (* no box: a box sits at a box's y, a lid's y is none *)
    assert (NBx : OW.is_bhv_b G pool g macro_special_objects._bhvExclamationBox k0 = false).
    { destruct (OW.is_bhv_b G pool g macro_special_objects._bhvExclamationBox k0) eqn:Eb; [ exfalso | reflexivity ].
      destruct (OW.ow_coll _ _ _ _ _ _ _ _ _ _ _ _ C) as (_ & _ & C3).
      destruct (C3 k0 Hkr Eb) as (x & y & z & Hin & _ & L & _). rewrite Ly in L. injection L as E.
      exact (lid_not_box lid Hlid x y z Hin (f_equal Vsingle E)). }
    assert (Hy0 : (forall ch, Mem.load ch m1 pool (k0 * OW.OSZ + O_POSY) = Mem.load ch g pool (k0 * OW.OSZ + O_POSY))
      \/ (OW.kind_ok pool m1 k0 /\ OW.runs G pool g k0 OW.POLES = false
          /\ OW.is_bhv_b G pool g macro_special_objects._bhvExclamationBox k0 = false
          /\ (forall t, Mem.load Mint32 g pool (k0 * OW.OSZ + O_INTERACT_TYPE) = Some (Vint t) ->
                OW.runs G pool g k0 OW.CANS = true -> Int.unsigned t <> INTERACT_CANNON_BASE ->
                cannon_xz_ok m1 pool (k0 * OW.OSZ)))).
    { right. split; [ exact (kind1 Kk) | split; [ exact RP | split; [ exact NBx | ] ] ].
      intros t Lt Hc Ht. destruct (T0 t Lt) as (_ & _ & T3). exact (xz1 (T3 Hc Ht)). }
    assert (Kv : forall ch k off, (96 <= off \/ (4 <= off /\ off + size_chunk ch <= 16)) ->
              off + size_chunk ch <= OW.OSZ -> (off + size_chunk ch <= 532 \/ 536 <= off) ->
              OW.ccl off (off + size_chunk ch) -> (k <> k0 \/ ObjVmSwap.vmc off (off + size_chunk ch)) ->
              Mem.load ch m1 pool (k * OW.OSZ + off) = Mem.load ch g pool (k * OW.OSZ + off)).
    { intros ch k off A B _ _ D. pose proof (size_chunk_pos ch). apply LPs; [ lia | exact B | ].
      unfold ObjVmSwap.vmc, O_POSY, RAW_OFF in D. lia. }
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
    { intros pool2 Sp. rewrite Hpool in Sp. injection Sp as <-. split.
      - intros Cso. apply (OW.surf_obj_ok_ext G pool g m1); [ exact KG' | | | exact Cso ].
        + intros P HP _ _ ch' z _. exact (KPn P HP ch' z).
        + intros k j _ Hj.
          assert (Hj' : 35 <= j <= 37)
            by (unfold OW.ANGV in Hj; cbn [In] in Hj; destruct Hj as [<- | [<- | [<- | []]]]; lia).
          rewrite <- Z.add_assoc. apply LPs;
            unfold RAW_OFF, OW.OSZ in *; cbn [size_chunk]; lia.
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
    assert (KNC : forall rs', OW.ncoll_ok pool g rs' -> OW.ncoll_ok pool m1 rs').
    { intros rs' Cn k Hk. destruct (Cn k Hk) as (n0 & Ln & Rn). exists n0.
      unfold OW.O_NCOLL in *. rewrite LPlo by (cbn [size_chunk]; lia). exact (conj Ln Rn). }
    assert (KMC : forall gmo, Genv.find_symbol G OLP._gMarioObject = Some gmo ->
              OW.mcoll_ok pool gmo g -> OW.mcoll_ok pool gmo m1).
    { intros gmo S5' Cmco.
      assert (Km : forall ch' z, Mem.load ch' m1 gmo z = Mem.load ch' g gmo z)
        by (intros ch' z; apply (LOs _ _ ch' z S5'); vm_compute; discriminate).
      intros k Hk Lg' i Hi. rewrite Km in Lg'. destruct (Cmco k Hk Lg' i Hi) as (v1 & Lv & Sv).
      exists v1. unfold OW.O_COLLS in *. rewrite <- !Z.add_assoc in Lv |- *.
      rewrite LPlo by (cbn [size_chunk]; lia). exact (conj Lv Sv). }
    assert (HQ : ObjFamily.Qfam (v_s st) st).
    { apply (ObjFamily.Qfam_start (v_s st) st eq_refl). rewrite Ecs. apply (proj1 (ObjFamily.memi_in _ _)). vm_compute. reflexivity. }
    assert (HCn : v_s st = OW.CANS -> (7 <= v_i st /\ v_i st < 1000)%nat) by (intros _; exact Hvi).
    exact (ObjVmSwap.obj_w_vm_swap g m1 G pool k0 Kv st st Hst V0 V1 HQ Hy0 Hpool
             bm HCn K KS KC Kbm KSc KNC KMC How).
  Qed.

  Theorem can_drop_pc : Pc m1.
  Proof. exact (conj ok1 (conj phi1 (conj ad1 (conj ps1 ow1)))). Qed.

  (* the rings, every slot's command cell, every other block stay *)
  Lemma can_rings : forall la, la <> pool -> OW.rings m1 pool la = OW.rings g pool la.
  Proof.
    intros la Nl. apply (rings_eq' g m1).
    - intros z off [-> | ->]; unfold OW.ld32; rewrite !CM.load_eq; apply LPs;
        unfold OW.O_PREV, OW.O_NEXT, OW.OSZ; cbn [size_chunk]; lia.
    - intros z. unfold OW.ld32. rewrite !CM.load_eq. exact (LO Mint32 la z Nl).
  Qed.

  Lemma can_cmd : forall j, OW.ld32 m1 pool (j * OW.OSZ + OW.O_CMD) = OW.ld32 g pool (j * OW.OSZ + OW.O_CMD).
  Proof. intros j. unfold OW.ld32. rewrite !CM.load_eq. apply LPs; unfold OW.O_CMD, OW.OSZ; cbn [size_chunk]; lia. Qed.
End CK.
