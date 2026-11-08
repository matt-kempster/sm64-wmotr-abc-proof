(* ======================================================================= *)
(* ObjExit.v -- the objects step's EXIT: the ghost's Pc carries to the     *)
(* real memory at cur_obj_update's return (GOAL 2 objects, W2, 2026-11-07).*)
(*                                                                         *)
(* At the exit of BhvStep.cou_real, ObjInv.INVk gives a ghost g (the       *)
(* invariant ClearKeep.Pc, slot k0 at the update's start VM state st0)     *)
(* and the real memory m' with                                             *)
(*   - Mem.unchanged_on Pfr g m': every block of g reads the same, except  *)
(*     the VM cursor gCurBhvCommand and slot k0's VM cells [460, 502);     *)
(*   - nvB scr_b g m': a changed byte holds no pointer but into a script;  *)
(*   - slot k0 at a reachable state st' of st0's family (ObjFamily.Qfam).  *)
(* exit_pc: Pc m'.  Two steps through cut (nextblock g) m' -- m' with the  *)
(* blocks born after g dropped (a memory of g's nextblock):                *)
(*   1. g -> cut: a change of the cursor and slot k0's VM cells only.      *)
(*      mem_ok by MWF_real_transfer (R7 by BhvStep.closed_nvB: g's R7 and  *)
(*      script-only new pointers); PhiW by RenderKeep.k_all_wc (Xs =       *)
(*      [gCurBhvCommand]; the cells are off owinc; g's closing injection   *)
(*      closes the cut, nvB_closed); obj_w by ObjVmSwap.obj_w_vm_swap; the *)
(*      A gate and plat_still read other cells.                            *)
(*   2. cut -> m': only blocks born after g differ: NewKeep.new_pc.        *)
(* PHANTOM CHECK: every premise is a fact INV_k carries at the exit or the *)
(* step's reached VM state; HSafeB_scr (the scripts are SafeB) is the      *)
(* labeled premise discharged at the capstone (StartSat's SB1, symbols).   *)
(* STAGED in Unwired/ with ObjInv until the objects step row uses it.      *)
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
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ClearKeep BhvStep ObjFamily.
From SM64.Proofs.WMotRRequiresA.Unwired Require ObjVmSwap NewKeep ObjInv.
From SM64.Proofs.WMotRRequiresA Require HeightFrame.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module PK := PollKeep.

(* ---------------------------------------------------------------------- *)
(* 1. cut nb m: m without the blocks from nb on (no permission there).     *)
(* ---------------------------------------------------------------------- *)
Fixpoint below (n : nat) : list positive :=
  match n with O => [] | S n' => Pos.of_nat (S n') :: below n' end.

Lemma in_below : forall n b, In b (below n) <-> (Pos.to_nat b <= n)%nat.
Proof.
  induction n as [| n IH]; intros b; cbn [below In].
  - split; [ intros [] | intros H; pose proof (Pos2Nat.is_pos b); lia ].
  - rewrite IH. split.
    + intros [<- | H]; [ rewrite Nat2Pos.id by discriminate; lia | lia ].
    + intros H. destruct (Nat.eq_dec (Pos.to_nat b) (S n)) as [E | E]; [ left | right; lia ].
      rewrite <- E. apply Pos2Nat.id.
Qed.

Definition nonef : Z -> perm_kind -> option permission := fun _ _ => None.

Lemma fold_get : forall (f : positive -> (Z -> perm_kind -> option permission)) L b,
  PMap.get b (fold_right (fun x a => PMap.set x (f x) a) (PMap.init nonef) L)
  = if in_dec peq b L then f b else nonef.
Proof.
  intros f L b. induction L as [| x L IH]; cbn [fold_right].
  - rewrite PMap.gi. reflexivity.
  - rewrite PMap.gsspec. destruct (peq b x) as [-> | Ne].
    + destruct (in_dec peq x (x :: L)) as [_ | N]; [ reflexivity | exfalso; apply N; left; reflexivity ].
    + rewrite IH. destruct (in_dec peq b L) as [H | H]; destruct (in_dec peq b (x :: L)) as [H' | H'];
        try reflexivity.
      * exfalso. apply H'. right. exact H.
      * exfalso. destruct H' as [E | H']; [ exact (Ne (eq_sym E)) | exact (H H') ].
Qed.

Definition acc_cut (nb : block) (m : mem) : PMap.t (Z -> perm_kind -> option permission) :=
  fold_right (fun x a => PMap.set x ((Mem.mem_access m) !! x) a) (PMap.init nonef) (below (Pos.to_nat nb - 1)).

Lemma acc_cut_get : forall nb m b, (acc_cut nb m) !! b = if plt b nb then (Mem.mem_access m) !! b else nonef.
Proof.
  intros nb m b. unfold acc_cut. rewrite (fold_get (fun x => (Mem.mem_access m) !! x)).
  destruct (in_dec peq b (below (Pos.to_nat nb - 1))) as [H | H]; destruct (plt b nb) as [P | P]; try reflexivity.
  - exfalso. apply in_below in H. apply P. unfold Plt. apply Pos2Nat.inj_lt. pose proof (Pos2Nat.is_pos nb). lia.
  - exfalso. apply H. apply in_below. unfold Plt in P. apply Pos2Nat.inj_lt in P. lia.
Qed.

Definition cut (nb : block) (m : mem) : mem.
Proof.
  refine (Mem.mkmem (Mem.mem_contents m) (acc_cut nb m) nb _ _ _).
  - intros b ofs. rewrite acc_cut_get. destruct (plt b nb); [ apply Mem.access_max | exact I ].
  - intros b ofs k H. rewrite acc_cut_get. destruct (plt b nb) as [P | _]; [ contradiction | reflexivity ].
  - intros b. apply Mem.contents_default.
Defined.

Lemma cut_nb : forall nb m, Mem.nextblock (cut nb m) = nb.
Proof. reflexivity. Qed.

Lemma cut_perm : forall nb m b o k p, Mem.perm (cut nb m) b o k p <-> Plt b nb /\ Mem.perm m b o k p.
Proof.
  intros nb m b o k p. unfold Mem.perm, cut. cbn [Mem.mem_access]. rewrite acc_cut_get.
  destruct (plt b nb) as [P | P]; [ tauto | ]. unfold nonef. cbn. tauto.
Qed.

Lemma cut_load_new : forall nb m ch b z, ~ Plt b nb -> Mem.load ch (cut nb m) b z = None.
Proof.
  intros nb m ch b z N. destruct (Mem.load ch (cut nb m) b z) eqn:L; [ exfalso | reflexivity ].
  pose proof (Mem.load_valid_access _ _ _ _ _ L) as (R & _).
  assert (Hp := R z ltac:(pose proof (size_chunk_pos ch); lia)).
  apply cut_perm in Hp. exact (N (proj1 Hp)).
Qed.

Lemma cut_unch : forall nb m, Ple nb (Mem.nextblock m) -> Mem.unchanged_on (fun _ _ => True) (cut nb m) m.
Proof.
  intros nb m Hle. constructor.
  - exact Hle.
  - intros b ofs k p _ Hv. unfold Mem.valid_block in Hv. rewrite cut_nb in Hv. rewrite cut_perm. tauto.
  - intros b ofs _ _. reflexivity.
Qed.

Lemma cut_load_old : forall nb m ch b z, Ple nb (Mem.nextblock m) -> Plt b nb ->
  Mem.load ch (cut nb m) b z = Mem.load ch m b z.
Proof.
  intros nb m ch b z Hle Hb. symmetry.
  eapply Mem.load_unchanged_on_1; [ exact (cut_unch nb m Hle) | exact Hb | intros; exact I ].
Qed.

Lemma load_invalid : forall ch m b z, ~ Mem.valid_block m b -> Mem.load ch m b z = None.
Proof.
  intros ch m b z N. destruct (Mem.load ch m b z) eqn:L; [ exfalso | reflexivity ].
  apply N. apply (Mem.valid_access_valid_block m ch b z).
  apply (Mem.valid_access_implies _ _ _ _ Readable); [ exact (Mem.load_valid_access _ _ _ _ _ L) | constructor ].
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. A closing injection of g closes a memory of g's nextblock whose      *)
(*    changed bytes name only blocks it maps (BhvStep.nvB).               *)
(* ---------------------------------------------------------------------- *)
Lemma nvB_closed : forall (P : block -> Prop) gp g m, closed_by gp g -> BhvStep.nvB P g m ->
  Mem.nextblock m = Mem.nextblock g -> (forall b, P b -> gp b <> None) -> closed_by gp m.
Proof.
  intros P gp g m Hc (PB & NC) En HP. pose proof Hc as (Hflat & Hi).
  assert (Vm : forall x x' d, gp x = Some (x', d) -> Mem.valid_block g x)
    by (intros x x' d E; exact (closed_valid_mapped _ _ _ _ _ Hc E)).
  assert (Vgm : forall x, Mem.valid_block g x <-> Mem.valid_block m x)
    by (intros x; unfold Mem.valid_block; rewrite En; tauto).
  split; [ exact Hflat | ].
  constructor.
  - constructor.
    + intros b1 b2 d ofs k p E Hp. destruct (Hflat _ _ _ E) as (-> & ->). rewrite Z.add_0_r. exact Hp.
    + intros b1 b2 d ch ofs p E _. destruct (Hflat _ _ _ E) as (_ & ->). apply Z.divide_0_r.
    + intros b1 ofs b2 d E Hp. destruct (Hflat _ _ _ E) as (-> & ->). rewrite Z.add_0_r.
      assert (Vb : Plt b1 (Mem.nextblock g)) by exact (Vm _ _ _ E).
      destruct (BhvStep.memval_eq_dec (ZMap.get ofs ((Mem.mem_contents m) !! b1))
                                      (ZMap.get ofs ((Mem.mem_contents g) !! b1))) as [Eq | Ne].
      * rewrite Eq. assert (Hp0 : Mem.perm g b1 ofs Cur Readable) by exact (proj1 (PB b1 ofs Cur Readable Vb) Hp).
        pose proof (Mem.mi_memval _ _ _ (Mem.mi_inj _ _ _ Hi) b1 ofs b1 0 E Hp0) as Mv.
        rewrite Z.add_0_r in Mv. exact Mv.
      * pose proof (NC b1 ofs Vb Hp Ne) as Ok.
        destruct (ZMap.get ofs ((Mem.mem_contents m) !! b1)) as [ | bt | v q n ]; [ constructor | constructor | ].
        constructor. destruct v as [ | | | | | b i ]; try constructor.
        cbn [BhvStep.pmvok] in Ok. pose proof (HP _ Ok) as Mb.
        destruct (gp b) as [[b' d'] |] eqn:Eb; [ | congruence ].
        destruct (Hflat _ _ _ Eb) as (-> & ->). econstructor; [ exact Eb | symmetry; exact (Ptrofs.add_zero i) ].
  - intros x Hnv. apply (Mem.mi_freeblocks _ _ _ Hi). intros Hv. exact (Hnv (proj1 (Vgm x) Hv)).
  - intros x x' d E. apply (proj1 (Vgm x')). exact (Mem.mi_mappedblocks _ _ _ Hi x x' d E).
  - intros b1 b1' d1 b2 b2' d2 o1 o2 Hne E1 E2 _ _. left.
    destruct (Hflat _ _ _ E1) as (-> & _). destruct (Hflat _ _ _ E2) as (-> & _). exact Hne.
  - intros x x' d ofs E _. destruct (Hflat _ _ _ E) as (_ & ->). pose proof (Ptrofs.unsigned_range_2 ofs). lia.
  - intros b1 ofs b2 d k p E Hp. left. destruct (Hflat _ _ _ E) as (-> & ->). rewrite Z.add_0_r in Hp. exact Hp.
Qed.

(* the script symbols are neither the VM cursor nor the object pool *)
Lemma scr_ids_ne : forall s, In s (map v_s vm_tab) ->
  s <> BhvStep.BS._gCurBhvCommand /\ s <> OLP._gObjectPool.
Proof.
  intros s Hin.
  assert (A1 : existsb (Pos.eqb BhvStep.BS._gCurBhvCommand) (map v_s vm_tab) = false) by (vm_compute; reflexivity).
  assert (A2 : existsb (Pos.eqb OLP._gObjectPool) (map v_s vm_tab) = false) by (vm_compute; reflexivity).
  split; intros E; subst s.
  - assert (B : existsb (Pos.eqb BhvStep.BS._gCurBhvCommand) (map v_s vm_tab) = true)
      by (apply existsb_exists; exists BhvStep.BS._gCurBhvCommand; split; [ exact Hin | apply Pos.eqb_refl ]).
    rewrite B in A1. discriminate A1.
  - assert (B : existsb (Pos.eqb OLP._gObjectPool) (map v_s vm_tab) = true)
      by (apply existsb_exists; exists OLP._gObjectPool; split; [ exact Hin | apply Pos.eqb_refl ]).
    rewrite B in A2. discriminate A2.
Qed.

(* ---------------------------------------------------------------------- *)
(* 3. The exit.                                                            *)
(* ---------------------------------------------------------------------- *)
Section EX.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation u := Ptrofs.unsigned.
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  (* the running slot k0 of the pool, the VM cursor *)
  Variables (pool bcc : block) (k0 : Z).
  Hypothesis Hpool : Genv.find_symbol G OLP._gObjectPool = Some pool.
  Hypothesis Hbcc : Genv.find_symbol G BhvStep.BS._gCurBhvCommand = Some bcc.
  Notation Pfr := (BhvStep.Pfr pool (k0 * OW.OSZ) bcc).
  Notation scr := (BhvStep.scr_b lp).
  (* LABELED: the scripts are SafeB (StartSat's SB1 holds every symbol
     outside non_safeb_syms; discharged at the linked capstone) *)
  Hypothesis HSafeB_scr : forall b, scr b -> SafeB b.

  Lemma SNE : forall id1 id2 b1 b2, Genv.find_symbol G id1 = Some b1 -> Genv.find_symbol G id2 = Some b2 ->
    id1 <> id2 -> b1 <> b2.
  Proof. intros id1 id2 b1 b2 H1 H2 Ne ->. apply Ne. eapply Genv.genv_vars_inj; eassumption. Qed.

  Lemma Npb : pool <> bcc.
  Proof. apply (SNE _ _ _ _ Hpool Hbcc). vm_compute. discriminate. Qed.

  (* the ghost, the real memory, the VM states *)
  Variables (g m' : mem).
  Hypothesis Hg : Pc g.
  Hypothesis U : Mem.unchanged_on Pfr g m'.
  Hypothesis NV : BhvStep.nvB scr g m'.

  Notation m2 := (cut (Mem.nextblock g) m').

  Lemma Hle : Ple (Mem.nextblock g) (Mem.nextblock m').
  Proof. exact (Mem.unchanged_on_nextblock _ _ _ U). Qed.

  Lemma Gnext : Ple (Genv.genv_next G) (Mem.nextblock g).
  Proof. destruct Hg as (_ & (_ & _ & _ & _ & (Hgn & _) & _) & _). exact Hgn. Qed.

  Lemma sym_lt : forall id b, Genv.find_symbol G id = Some b -> Plt b (Mem.nextblock g).
  Proof. intros id b Hs. exact (Plt_Ple_trans _ _ _ (Genv.genv_symb_range _ _ Hs) Gnext). Qed.

  (* ---- the loads of the cut ---- *)
  Lemma LO : forall ch b z, b <> bcc -> b <> pool -> Mem.load ch m2 b z = Mem.load ch g b z.
  Proof.
    intros ch b z N1 N2. destruct (plt b (Mem.nextblock g)) as [P | P].
    - rewrite (cut_load_old _ _ _ _ _ Hle P). eapply Mem.load_unchanged_on_1; [ exact U | exact P | ].
      intros i _. split; [ exact N1 | intros (E & _); exact (N2 E) ].
    - rewrite (cut_load_new _ _ _ _ _ P). symmetry. apply load_invalid. exact P.
  Qed.

  Lemma LOs : forall id b ch z, Genv.find_symbol G id = Some b ->
    id <> BhvStep.BS._gCurBhvCommand -> id <> OLP._gObjectPool -> Mem.load ch m2 b z = Mem.load ch g b z.
  Proof.
    intros id b ch z Hs N1 N2. apply LO; [ exact (SNE _ _ _ _ Hs Hbcc N1) | exact (SNE _ _ _ _ Hs Hpool N2) ].
  Qed.

  Lemma LM' : forall ch z, Mem.load ch m2 pool z = Mem.load ch m' pool z.
  Proof. intros ch z. exact (cut_load_old _ _ _ _ _ Hle (sym_lt _ _ Hpool)). Qed.

  Lemma LP : forall ch z, z + size_chunk ch <= k0 * OW.OSZ + OW.O_CMD \/ k0 * OW.OSZ + OW.O_STK + 34 <= z ->
    Mem.load ch m2 pool z = Mem.load ch g pool z.
  Proof.
    intros ch z H. pose proof (sym_lt _ _ Hpool) as P.
    rewrite (cut_load_old _ _ _ _ _ Hle P). eapply Mem.load_unchanged_on_1; [ exact U | exact P | ].
    intros i Hi. split; [ exact Npb | intros (_ & Hr); lia ].
  Qed.

  (* a cell of slot j: off slot k0's VM cells *)
  Lemma LPw : forall ch z j, j * OW.OSZ <= z -> z + size_chunk ch <= j * OW.OSZ + OW.OSZ ->
    (j <> k0 \/ z + size_chunk ch <= j * OW.OSZ + 460 \/ j * OW.OSZ + 502 <= z) ->
    Mem.load ch m2 pool z = Mem.load ch g pool z.
  Proof.
    intros ch z j A B C. apply LP. unfold OW.O_CMD, OW.O_STK, OW.OSZ in *. pose proof (size_chunk_pos ch).
    destruct (Z.lt_trichotomy j k0) as [L | [<- | L]]; [ left; nia | lia | right; nia ].
  Qed.

  Lemma LPs : forall ch k off, 0 <= off -> off + size_chunk ch <= OW.OSZ ->
    (k <> k0 \/ off + size_chunk ch <= 460 \/ 502 <= off) ->
    Mem.load ch m2 pool (k * OW.OSZ + off) = Mem.load ch g pool (k * OW.OSZ + off).
  Proof. intros ch k off A B C. apply (LPw ch _ k); lia. Qed.

  (* ---- the cut against the ghost: values, permissions, closedness ---- *)
  Lemma NV2 : BhvStep.nvB scr g m2.
  Proof.
    destruct NV as (PB & NC). split.
    - intros b ofs k p Hb. rewrite cut_perm. split; [ intros (_ & Hp) | intros Hp; split; [ exact Hb | ] ];
        [ exact (proj1 (PB b ofs k p Hb) Hp) | exact (proj2 (PB b ofs k p Hb) Hp) ].
    - intros b ofs Hb Hr Hne. exact (NC b ofs Hb (proj2 (proj1 (cut_perm _ _ _ _ _ _) Hr)) Hne).
  Qed.

  Lemma CLm : forall gp, closed_by gp g -> (forall id b, Genv.find_symbol G id = Some b -> gp b <> None) ->
    closed_by gp m2.
  Proof.
    intros gp Hc HS. apply (nvB_closed scr gp g m2 Hc NV2 (cut_nb _ _)).
    intros b (s & _ & Hs). exact (HS _ _ Hs).
  Qed.

  Lemma vm_at_cut : forall st, OW.vm_at G pool m' k0 st -> OW.vm_at G pool m2 k0 st.
  Proof.
    intros st ((b & Hs & Lc) & Ls & Lk). split; [ exists b; rewrite LM'; exact (conj Hs Lc) | ].
    split; [ rewrite LM'; exact Ls | intros n f Hn; rewrite LM'; exact (Lk n f Hn) ].
  Qed.

  (* ---- 3a. GOAL 1's mem_ok ---- *)
  Lemma Hbc_bm : bc <> bm.
  Proof. apply (SNE _ _ _ _ Hbc_sym Hbm_sym). vm_compute. discriminate. Qed.

  Lemma LObm : forall ch z, Mem.load ch m2 bm z = Mem.load ch g bm z.
  Proof. intros ch z. apply (LOs _ _ ch z Hbm_sym); vm_compute; discriminate. Qed.

  Lemma ok2 : mem_ok_lp bm MWF m2.
  Proof.
    destruct Hg as ((Hv & Hnt & M) & _).
    split; [ exact Hv | split ].
    - intros v L. rewrite LObm in L. exact (Hnt v L).
    - apply (MWF_real_transfer lp bm bc oc0 SafeB Hbc_bm g m2 (fun b H => H)); [ | | | exact M ].
      + intros v L. rewrite LObm in L. exact (mwf_real_inp lp bm bc oc0 SafeB g M v L).
      + intros ch x ofs v Hx L.
        destruct Hx as [ (-> & _) | [ -> | [ H | [ H | [ H | [ (gid & Hk & H) | H ] ] ] ] ] ].
        * rewrite LObm in L. exact L.
        * rewrite (LOs _ _ _ _ Hbc_sym) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
        * assert (A1 : gid <> BhvStep.BS._gCurBhvCommand) by (intros ->; vm_compute in Hk; discriminate Hk).
          assert (A2 : gid <> OLP._gObjectPool) by (intros ->; vm_compute in Hk; discriminate Hk).
          rewrite (LOs _ _ _ _ H A1 A2) in L. exact L.
        * rewrite (LOs _ _ _ _ H) in L by (vm_compute; discriminate). exact L.
      + apply (BhvStep.closed_nvB SafeB scr g m2 NV2 HSafeB_scr).
        * intros b Hb. exact (mwf_real_safe_valid lp bm bc oc0 SafeB g M b Hb).
        * intros b ofs b' o' Hb L. exact (mwf_real_chase_step lp bm bc oc0 SafeB g b ofs b' o' M Hb L).
  Qed.

  (* ---- 3b. the A gate ---- *)
  Lemma ad2 : a_down_real bm m2 = false.
  Proof.
    destruct Hg as (Ok & _ & HD & _). pose proof Ok as (_ & _ & HM). pose proof HM as (_ & _ & R2 & _).
    rewrite <- HD. unfold a_down_real. rewrite (LObm Mptr 156).
    destruct (Mem.load Mptr g bm 156) as [v0 |] eqn:E; [ | reflexivity ].
    destruct v0; try reflexivity.
    destruct (R2 _ _ eq_refl) as (-> & _).
    rewrite (LOs _ _ _ _ Hbc_sym); [ reflexivity | vm_compute; discriminate | vm_compute; discriminate ].
  Qed.

  (* ---- 3c. plat_still: the platform symbol, an object's angular velocity ---- *)
  Lemma ps2 : PlatformKeep.plat_still lp m2.
  Proof.
    destruct Hg as (_ & _ & _ & Hst & _).
    intros bp v0 Hbp Hl0.
    rewrite LO in Hl0 by first [ exact (SNE _ _ _ _ Hbp Hbcc ltac:(vm_compute; discriminate))
                               | exact (SNE _ _ _ _ Hbp Hpool ltac:(vm_compute; discriminate)) ].
    destruct (Hst bp v0 Hbp Hl0) as [Hz | (pb & po & -> & Hpb0 & Hk0 & Hal)]; [ left; exact Hz | right ].
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
    rewrite LPs; [ exact Hk0 | lia | unfold OW.OSZ; cbn [size_chunk]; lia | right; left; cbn [size_chunk]; lia ].
  Qed.

  (* ---- 3d. PhiW: RenderKeep.k_all_wc, the cursor the one written global ---- *)
  Lemma phi2 : phiw lp bm m2.
  Proof.
    destruct Hg as (Ok & Hphi & _ & _ & How).
    pose proof Hphi as (_ & _ & _ & _ & Hf & _).
    pose proof Hf as (Hgn & (d & FWF) & FD).
    pose proof How as (pool' & la & fl & gol & gmo' & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (km & Hkm & Lg & Lb & KO).
    assert (Hpl : pool <> la) by (apply (SNE _ _ _ _ Hpool S2); vm_compute; discriminate).
    assert (Rkm : 0 <= km < OW.NSLOT).
    { pose proof (proj1 (ObjRing.rings_iff pool g la rs Hpl) (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) as (_ & Henc).
      destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc0 & _).
      exact (ObjRing.chain_range pool g _ _ _ Hc0 km Hkm). }
    assert (Uj : forall j, 0 <= j < OW.NSLOT -> u (Ptrofs.repr (j * OW.OSZ)) = j * OW.OSZ)
      by (intros j Hj; apply Ptrofs.unsigned_repr; unfold OW.OSZ, OW.NSLOT in *;
          change Ptrofs.max_unsigned with 4294967295; lia).
    assert (Ukm : u (Ptrofs.repr (km * OW.OSZ)) = km * OW.OSZ) by exact (Uj km Rkm).
    assert (Bpl : bm <> pool) by (apply (SNE _ _ _ _ Hbm_sym Hpool); vm_compute; discriminate).
    set (Q := fun co : ptrofs => exists j, 0 <= j < OW.NSLOT /\ u co = j * OW.OSZ).
    assert (SQ : forall v0 co, OW.slot_ptr pool v0 -> v0 = Vptr pool co -> Q co).
    { intros v0 co [-> | (j & Hj & ->)] E; [ discriminate E | ].
      unfold OW.slot_v in E. injection E as <-. exists j. split; [ exact Hj | exact (Uj j Hj) ]. }
    assert (QC : forall i0 co, 0 <= i0 < 4 ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i0) = Some (Vptr pool co) -> Q co).
    { intros i0 co Hi0 Lc. rewrite Ukm in Lc.
      destruct (OW.ow_mcoll _ _ _ _ _ _ _ _ _ _ _ _ C km Rkm Lg i0 Hi0) as (v0 & Lv & Sv).
      unfold OW.O_COLLS, COLL_OFF in *. rewrite Lc in Lv. injection Lv as <-. exact (SQ _ co Sv eq_refl). }
    assert (QU : forall uo, Mem.load Mint32 g bm USED_OFF = Some (Vptr pool uo) -> Q uo).
    { intros uo Lu. destruct (OW.ow_stale _ _ _ _ _ _ _ _ _ _ _ _ C 128 ltac:(cbn; auto)) as (v0 & Lv & Sv).
      unfold USED_OFF in Lu. rewrite Lu in Lv. injection Lv as <-. exact (SQ _ uo Sv eq_refl). }
    set (Xs := [BhvStep.BS._gCurBhvCommand]).
    assert (HXs : forall id, In id Xs -> existsb (Pos.eqb id) core_ids = false)
      by (intros id [<- | []]; vm_compute; reflexivity).
    assert (HXl : forall id, In id Xs -> existsb (Pos.eqb id) lvl_rd_ids = false)
      by (intros id [<- | []]; vm_compute; reflexivity).
    assert (Nbm : ~ rgb lp Xs bm) by exact (rgb_not lp Xs HXs _ bm Hbm_sym ltac:(vm_compute; reflexivity)).
    assert (RGa : forall b, rgb lp Xs b -> b <> pool /\ AnimWorld.tab_apart G g b).
    { intros b (id & [<- | []] & Hs). rewrite Hbcc in Hs. injection Hs as <-.
      split; [ exact (not_eq_sym Npb) | ].
      exact (tab_apart_global G g _ _ _ bcc (Genv.genv_symb_range _ _ Hbcc) (ff_W _ _ _ _ FWF)). }
    assert (NB : Ple (Mem.nextblock g) (Mem.nextblock m2)) by (rewrite cut_nb; apply Ple_refl).
    assert (PM : forall b o k p, Plt b (Mem.nextblock g) -> Mem.perm g b o k p -> Mem.perm m2 b o k p).
    { intros b o k p Hb Hp. destruct NV2 as (PB & _). exact (proj2 (PB b o k p Hb) Hp). }
    assert (LD : forall ch' b z', ~ rgb lp Xs b -> b <> bm ->
              (b <> pool \/ owinc Q (Ptrofs.repr (km * OW.OSZ)) ch' z') -> Mem.load ch' m2 b z' = Mem.load ch' g b z').
    { intros ch' b z' Nr _ Hw.
      assert (Nc : b <> bcc) by (intros ->; apply Nr; exists BhvStep.BS._gCurBhvCommand; split; [ left; reflexivity | exact Hbcc ]).
      destruct (eq_block b pool) as [-> | Np]; [ | exact (LO _ _ _ Nc Np) ].
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
              exists gp', (forall b, gp b <> None -> gp' b <> None) /\ closed_by gp' m2).
    { intros gp HC _ HS. exists gp. split; [ intros b H; exact H | exact (CLm gp HC HS) ]. }
    assert (FR : forall bt0 ot0 kk, In kk hs_ids ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + 60) = Some (Vptr bt0 ot0) ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + 72) = Some (Vint Int.zero) ->
              (exists f, -1 <= f <= hs_le kk
                 /\ Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))) ->
              buf_ok g bt0 ot0 kk -> u ot0 + BUFSZ < Ptrofs.modulus ->
              exists f, -1 <= f <= hs_le kk
                /\ Mem.load Mint16signed m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + 64) = Some (Vint (Int.repr f))).
    { intros bt0 ot0 kk _ _ _ (f & Rf & L64) _ _. exists f. split; [ exact Rf | ]. rewrite Ukm in *.
      rewrite LPs; [ exact L64 | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ]. }
    assert (CKo : forall i cb co, 0 <= i < 4 ->
              Mem.load Mint32 m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co) ->
              Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some (Vptr cb co)
              \/ (cb = pool /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros i cb co Hi Hl. left. rewrite Ukm in *. unfold COLL_OFF in *. rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPs in Hl; [ exact Hl | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ]. }
    assert (CKn : forall n, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n) ->
              exists n', Mem.load Mint16signed m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n')
              /\ (n' = n \/ 0 <= Int.signed n' <= 4)
              /\ forall i v0, 0 <= i < Int.signed n' -> i < 4 ->
                   Mem.load Mint32 m2 pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0 ->
                   (exists n0, Mem.load Mint16signed g pool (u (Ptrofs.repr (km * OW.OSZ)) + NUMCOLL_OFF) = Some (Vint n0)
                      /\ i < Int.signed n0
                      /\ Mem.load Mint32 g pool (u (Ptrofs.repr (km * OW.OSZ)) + COLL_OFF + 4 * i) = Some v0)
                   \/ (exists co, v0 = Vptr pool co /\ coll_new bm g pool (Ptrofs.repr (km * OW.OSZ)) Q co)).
    { intros n Ln. rewrite Ukm in *. unfold NUMCOLL_OFF, COLL_OFF in *. exists n.
      split; [ rewrite LPs; [ exact Ln | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ] | ].
      split; [ left; reflexivity | ].
      intros i v0 Hi Hi4 Hl. left. exists n. split; [ exact Ln | split; [ lia | ] ].
      rewrite <- Z.add_assoc in Hl |- *.
      rewrite LPs in Hl; [ exact Hl | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ]. }
    eapply k_all_wc with (lp := lp) (bm := bm) (Xs := Xs) (Qt := fun _ : ptrofs => False);
      first [ exact HXs | exact HXl | exact Lb | exact NB | exact PM | exact LD
            | exact (fun ch' z' (_ : bmk ch' z') => LObm ch' z') | exact Hbm_sym
            | exact Nbm | exact Bpl | exact RGa | exact CL | exact FR
            | exact (fun i0 co Hi0 Lc => or_introl (QC i0 co Hi0 Lc))
            | exact (fun a uo (_ : Mem.load Mint32 g bm 12 = Some (Vint a)) (_ : In (Int.unsigned a) used_acts) Lu => QU uo Lu)
            | solve [ intros ? [] ] | solve [ intros ? ? [] ]
            | exact CKo | exact CKn | exact Hphi | exact (phiw_surf_apart lp bm _ g Hphi) ].
  Qed.

  (* ---- 3e. obj_w: ObjVmSwap's keeper ---- *)
  Lemma ow2 : forall st0 st', In st0 vm_tab -> In st' vm_tab ->
    OW.vm_at G pool g k0 st0 -> OW.vm_at G pool m' k0 st' -> ObjFamily.Qfam (v_s st0) st' ->
    OW.obj_w G bm m2.
  Proof.
    intros st0 st' H0 H1 V0 V1 HQ.
    destruct Hg as (_ & _ & _ & _ & How).
    assert (Kv : forall ch k off, (96 <= off \/ (4 <= off /\ off + size_chunk ch <= 16)) ->
              off + size_chunk ch <= OW.OSZ -> (off + size_chunk ch <= 532 \/ 536 <= off) ->
              OW.ccl off (off + size_chunk ch) -> (k <> k0 \/ ObjVmSwap.vmc off (off + size_chunk ch)) ->
              Mem.load ch m2 pool (k * OW.OSZ + off) = Mem.load ch g pool (k * OW.OSZ + off)).
    { intros ch k off A B _ _ D. pose proof (size_chunk_pos ch). apply LPs; [ lia | exact B | ].
      unfold ObjVmSwap.vmc, OW.O_CMD, OW.O_STK in D. lia. }
    assert (K : forall id b, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false -> Genv.find_symbol G id = Some b ->
              forall ch z, Mem.load ch m2 b z = Mem.load ch g b z).
    { intros id b Hin Hn Hs ch z. apply (LOs id b ch z Hs).
      - intros ->. exact (PK.not_in_of_existsb BhvStep.BS._gCurBhvCommand PK.ow_ids ltac:(vm_compute; reflexivity) Hin).
      - intros ->. vm_compute in Hn. discriminate Hn. }
    assert (KG' : forall id b, In id OW.surf_gids -> Genv.find_symbol G id = Some b ->
              forall ch z, Mem.load ch m2 b z = Mem.load ch g b z).
    { intros id b Hin Hs ch z. apply (LOs id b ch z Hs);
        unfold OW.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin;
        destruct Hin as [<- | [<- | [<- | [<- | []]]]]; vm_compute; discriminate. }
    assert (KP : forall P, Ple (Genv.genv_next G) P -> forall ch z, Mem.load ch m2 P z = Mem.load ch g P z).
    { intros P HP ch z. apply LO.
      - intros ->. pose proof (Genv.genv_symb_range _ _ Hbcc). unfold Plt, Ple in *. lia.
      - intros ->. pose proof (Genv.genv_symb_range _ _ Hpool). unfold Plt, Ple in *. lia. }
    assert (KS : PK.surf_keep g m2 G).
    { intros pool' Sp. rewrite Hpool in Sp. injection Sp as <-. split.
      - intros Cso. apply (OW.surf_obj_ok_ext G pool g m2); [ exact KG' | | | exact Cso ].
        + intros P HP _ _ ch z _. exact (KP P HP ch z).
        + intros k j _ Hj. rewrite <- Z.add_assoc. apply LPs;
            unfold RAW_OFF, OW.OSZ; unfold OW.ANGV in Hj; cbn [In] in Hj; cbn [size_chunk];
            destruct Hj as [<- | [<- | [<- | []]]]; lia.
      - intros mv. apply (OW.cls_surf_ext G pool g m2 mv KG'). intros P HP _ _ ch z _. exact (KP P HP ch z). }
    assert (KC : OW.ctr_s_ok G g -> OW.ctr_s_ok G m2).
    { intros (a & Hgc & Ha). exists a. split; [ | exact Ha ].
      apply (PK.gcell_K g m2); [ | exact Hgc ].
      intros b Hs ch z. apply (LOs _ b ch z Hs); vm_compute; discriminate. }
    assert (Kbm : forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104; 12] ->
              Mem.load Mint32 m2 bm z = Mem.load Mint32 g bm z) by (intros z _; apply LObm).
    assert (KSc : forall s b, In s (map v_s vm_tab) -> Genv.find_symbol G s = Some b ->
              forall ch z, Mem.load ch m2 b z = Mem.load ch g b z).
    { intros s b Hin Hs ch z. destruct (scr_ids_ne s Hin) as (N1 & N2). exact (LOs s b ch z Hs N1 N2). }
    assert (KNC : forall rs, OW.ncoll_ok pool g rs -> OW.ncoll_ok pool m2 rs).
    { intros rs Cn k Hk. destruct (Cn k Hk) as (n & Ln & Rn). exists n. split; [ | exact Rn ].
      unfold OW.O_NCOLL in *. rewrite LPs; [ exact Ln | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ]. }
    assert (KMC : forall gmo, Genv.find_symbol G OLP._gMarioObject = Some gmo ->
              OW.mcoll_ok pool gmo g -> OW.mcoll_ok pool gmo m2).
    { intros gmo Hgm Cm k Hk Lg i Hi.
      rewrite (LOs _ _ _ _ Hgm) in Lg by (vm_compute; discriminate).
      destruct (Cm k Hk Lg i Hi) as (v & Lv & Sv). exists v. split; [ | exact Sv ].
      unfold OW.O_COLLS in *. rewrite <- Z.add_assoc in Lv |- *.
      rewrite LPs; [ exact Lv | lia | cbn [size_chunk]; unfold OW.OSZ; lia | right; left; cbn [size_chunk]; lia ]. }
    exact (ObjVmSwap.obj_w_vm_swap g m2 G pool k0 Kv st0 st' H1 V0 (vm_at_cut st' V1) HQ Hpool
             bm K KS KC Kbm KSc KNC KMC How).
  Qed.

  (* ---- THE EXIT ---- *)
  (* slot k0: the update's start state st0 in the ghost, a reached state
     st' of st0's family in the real memory *)
  Theorem exit_cut : forall st0 st', In st0 vm_tab -> In st' vm_tab ->
    OW.vm_at G pool g k0 st0 -> OW.vm_at G pool m' k0 st' -> ObjFamily.Qfam (v_s st0) st' ->
    Pc m2.
  Proof.
    intros st0 st' H0 H1 V0 V1 HQ.
    exact (conj ok2 (conj phi2 (conj ad2 (conj ps2 (ow2 st0 st' H0 H1 V0 V1 HQ))))).
  Qed.

  Theorem exit_pc : forall st0 st', In st0 vm_tab -> In st' vm_tab ->
    OW.vm_at G pool g k0 st0 -> OW.vm_at G pool m' k0 st' -> ObjFamily.Qfam (v_s st0) st' ->
    Pc m'.
  Proof.
    intros st0 st' H0 H1 V0 V1 HQ.
    destruct Hg as (_ & Hphi & _).
    pose proof Hphi as (_ & _ & _ & _ & Hf & _).
    pose proof Hf as (_ & (d & FWF) & _).
    exact (NewKeep.new_pc lp bm Hbm_sym bc oc0 SafeB Hbc_sym (FfWorld.fw_gp d) m2 m'
             (CLm _ (ff_HC _ _ _ _ FWF) (ff_HS _ _ _ _ FWF)) (ff_HS _ _ _ _ FWF)
             (cut_unch _ _ Hle) (exit_cut st0 st' H0 H1 V0 V1 HQ)).
  Qed.
End EX.

(* ---------------------------------------------------------------------- *)
(* 4. INV_k's exit: the loop invariant at cur_obj_update's return, with   *)
(*    the slot at the reached state cou_real names, is Pobjl again.        *)
(* ---------------------------------------------------------------------- *)
Lemma Vo_vm_at : forall lp pool k m st, BhvStep.Vo lp pool (k * OW.OSZ) m st -> OW.vm_at (lp_ge lp) pool m k st.
Proof.
  intros lp pool k m st (Hc & Hsi & Hk). split; [ exact Hc | split; [ exact Hsi | unfold OW.stk_cell; exact Hk ] ].
Qed.

Theorem inv_exit : forall lp bm bc oc0 SafeB go pool bcc k0 st0 nb0 X m' st',
  Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm ->
  Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc ->
  Genv.find_symbol (lp_ge lp) OLP._gObjectPool = Some pool ->
  Genv.find_symbol (lp_ge lp) BhvStep.BS._gCurBhvCommand = Some bcc ->
  (forall b, BhvStep.scr_b lp b -> SafeB b) ->
  In st0 vm_tab -> In st' vm_tab -> ObjFamily.Qfam (v_s st0) st' ->
  ObjInv.INVk lp bm bc oc0 SafeB go pool (k0 * OW.OSZ) bcc st0 nb0 X m' ->
  BhvStep.Vo lp pool (k0 * OW.OSZ) m' st' ->
  HeightFrame.Pobj lp bm (MWF_real lp bm bc oc0 SafeB) (HeightFrame.PhiW lp bm) (OW.obj_w (lp_ge lp) bm) m'.
Proof.
  intros lp bm bc oc0 SafeB go pool bcc k0 st0 nb0 X m' st' Sbm Sbc Sp Sbcc HSc H0 H1 HQ
    (_ & _ & g & (Ok & Phi & HD & Hst & _ & How) & HV & _ & U & NV & _) HV'.
  destruct (exit_pc lp bm Sbm bc oc0 SafeB Sbc pool bcc k0 Sp Sbcc HSc g m'
              (conj Ok (conj Phi (conj HD (conj Hst How)))) U NV st0 st' H0 H1
              (Vo_vm_at _ _ _ _ _ HV) (Vo_vm_at _ _ _ _ _ HV') HQ) as (Ok' & Phi' & HD' & Hst' & How').
  exact (conj Ok' (conj Phi' (conj HD' (conj Hst' (conj (phiw_surf_apart lp bm _ m' Phi') How'))))).
Qed.
