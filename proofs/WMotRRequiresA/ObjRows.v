(* ======================================================================= *)
(* ObjRows.v -- the dispatch loop's row keeps for INV_k, by the ghost      *)
(* (GOAL 2 objects, W2, 2026-11-07).                                       *)
(*                                                                         *)
(* ObjInv.INVk m holds a ghost g: a Pobjl memory whose slot k holds the    *)
(* update's start state st0 (GP g := Pobjl g /\ Vo g st0), equal to m off  *)
(* the VM cursor and slot k's VM cells (GR g m: unchanged_on Pfr g m, and  *)
(* nvB scr_b g m).  A row's change of m is FOLLOWED on the ghost:          *)
(*   - a store into m: the same store into g (gr_store: both memories take *)
(*     the same bytes, so GR is kept);                                     *)
(*   - a footprint-only change m -> m1 (the RNG call's Psd, SFR'): the     *)
(*     ghost fol g m1 -- m1 with g's bytes at the cursor and slot k's VM   *)
(*     cells, g's nextblock (fol_gr).                                      *)
(* So each row keep at INV := INV_k follows from the SAME keep at the      *)
(* ghost, INV := GP (t_set ... t_sir): a premise about Pobjl memories      *)
(* (the frame-start memory, VM cells at st0), no longer about the loop's   *)
(* intermediate memories.  The loads a keep reads are the ghost's loads    *)
(* (off the VM cells: fld_chk, vm-checked over the reachable words).       *)
(*                                                                         *)
(* STAGED in Unwired/ with ObjInv / ObjExit until the objects step row     *)
(* uses them.                                                              *)
(* ======================================================================= *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Memory Globalenvs Ctypes Clight.
From SM64.Proofs Require Import RealFrameLinked LinkedTwelve MWFReal.
From SM64.Proofs.WMotRRequiresA Require Import BhvVM.
From SM64.Generated Require behavior_script behavior_data.
From SM64.Proofs.WMotRRequiresA Require WMotRLevel WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require BhvStep ClearKeep ObjWorld ObjFamily ObjSelf ObjFrame.
From SM64.Proofs.WMotRRequiresA Require ObjInv ObjExit.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

(* ---------------------------------------------------------------------- *)
(* 1. A store taken by both memories keeps unchanged_on P and nvB Q.      *)
(* ---------------------------------------------------------------------- *)
Lemma setN_agree : forall bl p (c1 c2 : ZMap.t memval) q,
  ZMap.get q c1 = ZMap.get q c2 \/ p <= q < p + Z.of_nat (length bl) ->
  ZMap.get q (Mem.setN bl p c1) = ZMap.get q (Mem.setN bl p c2).
Proof.
  induction bl as [| a bl IH]; intros p c1 c2 q H; cbn [Mem.setN].
  - destruct H as [H | H]; [ exact H | cbn [length] in H; lia ].
  - apply IH. destruct (Z.eq_dec q p) as [-> | Ne].
    + left. rewrite !ZMap.gss. reflexivity.
    + destruct H as [H | H]; [ left; rewrite !ZMap.gso by exact Ne; exact H | right; cbn [length] in H; lia ].
Qed.

Lemma gr_store : forall (P : block -> Z -> Prop) (Q : block -> Prop) g m ch b z v m1,
  Mem.unchanged_on P g m -> BhvStep.nvB Q g m -> Mem.valid_block g b ->
  Mem.store ch m b z v = Some m1 ->
  exists g1, Mem.store ch g b z v = Some g1 /\ Mem.unchanged_on P g1 m1 /\ BhvStep.nvB Q g1 m1.
Proof.
  intros P Q g m ch b z v m1 U (PB & NC) Hv S.
  assert (Vg : Mem.valid_access g ch b z Writable).
  { destruct (Mem.store_valid_access_3 _ _ _ _ _ _ S) as (Hr & Al). split; [ | exact Al ].
    intros o Ho. exact (proj1 (PB b o Cur Writable Hv) (Hr o Ho)). }
  destruct (Mem.valid_access_store g ch b z v Vg) as (g1 & Sg).
  exists g1. split; [ exact Sg | split ].
  - constructor.
    + rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg), (Mem.nextblock_store _ _ _ _ _ _ S).
      exact (Mem.unchanged_on_nextblock _ _ _ U).
    + intros b' o k p HP Hv'. unfold Mem.valid_block in Hv'. rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg) in Hv'.
      split; intros Hp.
      * apply (Mem.perm_store_1 _ _ _ _ _ _ S).
        apply (proj1 (Mem.unchanged_on_perm _ _ _ U b' o k p HP Hv')).
        exact (Mem.perm_store_2 _ _ _ _ _ _ Sg _ _ _ _ Hp).
      * apply (Mem.perm_store_1 _ _ _ _ _ _ Sg).
        apply (proj2 (Mem.unchanged_on_perm _ _ _ U b' o k p HP Hv')).
        exact (Mem.perm_store_2 _ _ _ _ _ _ S _ _ _ _ Hp).
    + intros b' o HP Hr.
      pose proof (Mem.perm_store_2 _ _ _ _ _ _ Sg _ _ _ _ Hr) as Hr0.
      rewrite (Mem.store_mem_contents _ _ _ _ _ _ S), (Mem.store_mem_contents _ _ _ _ _ _ Sg).
      destruct (peq b' b) as [-> | Ne]; [ rewrite !PMap.gss | rewrite !PMap.gso by exact Ne ].
      * apply setN_agree. left. exact (Mem.unchanged_on_contents _ _ _ U _ _ HP Hr0).
      * exact (Mem.unchanged_on_contents _ _ _ U _ _ HP Hr0).
  - split.
    + intros b' o k p Hb. rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg) in Hb. split; intros Hp.
      * apply (Mem.perm_store_1 _ _ _ _ _ _ Sg). apply (proj1 (PB b' o k p Hb)).
        exact (Mem.perm_store_2 _ _ _ _ _ _ S _ _ _ _ Hp).
      * apply (Mem.perm_store_1 _ _ _ _ _ _ S). apply (proj2 (PB b' o k p Hb)).
        exact (Mem.perm_store_2 _ _ _ _ _ _ Sg _ _ _ _ Hp).
    + intros b' o Hb Hr Hne. rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg) in Hb.
      pose proof (Mem.perm_store_2 _ _ _ _ _ _ S _ _ _ _ Hr) as Hr0.
      rewrite (Mem.store_mem_contents _ _ _ _ _ _ S), (Mem.store_mem_contents _ _ _ _ _ _ Sg) in Hne.
      rewrite (Mem.store_mem_contents _ _ _ _ _ _ S).
      destruct (peq b' b) as [-> | Ne]; [ rewrite !PMap.gss in Hne; rewrite !PMap.gss | rewrite !PMap.gso in Hne by exact Ne; rewrite !PMap.gso by exact Ne ].
      * destruct (zle z o) as [L1 | L1];
          [ destruct (zlt o (z + Z.of_nat (length (encode_val ch v)))) as [L2 | L2] | ].
        -- exfalso. apply Hne. apply setN_agree. right. lia.
        -- rewrite Mem.setN_outside in Hne by lia; rewrite Mem.setN_outside in Hne by lia; rewrite Mem.setN_outside by lia. exact (NC b o Hb Hr0 Hne).
        -- rewrite Mem.setN_outside in Hne by lia; rewrite Mem.setN_outside in Hne by lia; rewrite Mem.setN_outside by lia. exact (NC b o Hb Hr0 Hne).
      * exact (NC b' o Hb Hr0 Hne).
Qed.

(* ---------------------------------------------------------------------- *)
(* 2. fol g m1: m1 with g's bytes at block bc and at pool [lo, lo + n),    *)
(*    g's nextblock (m1's permissions below it).                           *)
(* ---------------------------------------------------------------------- *)
Lemma setN_getN_in : forall n lo (cg c1 : ZMap.t memval) o, lo <= o < lo + Z.of_nat n ->
  ZMap.get o (Mem.setN (Mem.getN n lo cg) lo c1) = ZMap.get o cg.
Proof.
  induction n as [| n IH]; intros lo cg c1 o H; [ lia | ].
  cbn [Mem.getN Mem.setN]. destruct (Z.eq_dec o lo) as [-> | Ne].
  - rewrite Mem.setN_outside by lia. apply ZMap.gss.
  - apply IH. lia.
Qed.

Section Fol.
  Variables (g m1 : mem) (pool bc : block) (lo : Z) (n : nat).

  Definition fol_c : PMap.t (ZMap.t memval) :=
    PMap.set pool (Mem.setN (Mem.getN n lo ((Mem.mem_contents g) !! pool)) lo ((Mem.mem_contents m1) !! pool))
      (PMap.set bc ((Mem.mem_contents g) !! bc) (Mem.mem_contents m1)).

  Definition fol : mem.
  Proof.
    refine (Mem.mkmem fol_c (ObjExit.acc_cut (Mem.nextblock g) m1) (Mem.nextblock g) _ _ _).
    - intros b ofs. rewrite ObjExit.acc_cut_get. destruct (plt b (Mem.nextblock g)); [ apply Mem.access_max | exact I ].
    - intros b ofs k H. rewrite ObjExit.acc_cut_get. destruct (plt b (Mem.nextblock g)) as [P | _]; [ contradiction | reflexivity ].
    - intros b. unfold fol_c. rewrite !PMap.gsspec.
      destruct (peq b pool); [ rewrite Mem.setN_default; apply Mem.contents_default | ].
      destruct (peq b bc); apply Mem.contents_default.
  Defined.

  Lemma fol_nb : Mem.nextblock fol = Mem.nextblock g.
  Proof. reflexivity. Qed.

  Lemma fol_perm : forall b o k p, Mem.perm fol b o k p <-> Plt b (Mem.nextblock g) /\ Mem.perm m1 b o k p.
  Proof.
    intros b o k p. unfold Mem.perm, fol. cbn [Mem.mem_access]. rewrite ObjExit.acc_cut_get.
    destruct (plt b (Mem.nextblock g)) as [P | P]; [ tauto | ]. unfold ObjExit.nonef. cbn. tauto.
  Qed.


  Lemma fol_pool_in : forall o, lo <= o < lo + Z.of_nat n ->
    ZMap.get o ((Mem.mem_contents fol) !! pool) = ZMap.get o ((Mem.mem_contents g) !! pool).
  Proof. intros o Ho. unfold fol, fol_c. cbn [Mem.mem_contents]. rewrite PMap.gss. apply setN_getN_in. exact Ho. Qed.

  Lemma fol_pool_out : forall o, ~ (lo <= o < lo + Z.of_nat n) ->
    ZMap.get o ((Mem.mem_contents fol) !! pool) = ZMap.get o ((Mem.mem_contents m1) !! pool).
  Proof.
    intros o Ho. unfold fol, fol_c. cbn [Mem.mem_contents]. rewrite PMap.gss.
    rewrite Mem.setN_outside; [ reflexivity | rewrite Mem.getN_length; lia ].
  Qed.

  Lemma fol_bc : forall (Hpb : pool <> bc) o, ZMap.get o ((Mem.mem_contents fol) !! bc) = ZMap.get o ((Mem.mem_contents g) !! bc).
  Proof.
    intros Hpb o. unfold fol, fol_c. cbn [Mem.mem_contents].
    rewrite PMap.gso by (intro E; exact (Hpb (eq_sym E))). rewrite PMap.gss. reflexivity.
  Qed.

  Lemma fol_other : forall b o, b <> pool -> b <> bc ->
    ZMap.get o ((Mem.mem_contents fol) !! b) = ZMap.get o ((Mem.mem_contents m1) !! b).
  Proof.
    intros b o H1 H2. unfold fol, fol_c. cbn [Mem.mem_contents].
    rewrite PMap.gso by exact H1. rewrite PMap.gso by exact H2. reflexivity.
  Qed.
End Fol.

(* ---------------------------------------------------------------------- *)
(* 3. The field cells the keeps read are off the VM cells (vm-checked over *)
(*    the reachable words).                                               *)
(* ---------------------------------------------------------------------- *)
Definition fsafe (f : Z) : bool := (f <=? 80) || (92 <=? f).

(* PERF TRAP: stated inline (see BhvStep.chk42_ok) *)
Lemma fld_chk :
  forallb (fun st =>
    (negb (existsb (Z.eqb (opc st)) [15; 17; 13; 52]) || fsafe (byte2 (w0 st)))
    && (negb (opc st =? 51) || (byte2 (w0 st) <=? 80))
    && (negb (opc st =? 31) || (fsafe (byte3 (w0 st)) && fsafe (byte4 (w0 st))))) vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma fld_of : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  (negb (existsb (Z.eqb (Z.shiftr w 24)) [15; 17; 13; 52]) || fsafe (byte2 w))
  && (negb (Z.shiftr w 24 =? 51) || (byte2 w <=? 80))
  && (negb (Z.shiftr w 24 =? 31) || (fsafe (byte3 w) && fsafe (byte4 w))) = true.
Proof.
  intros st w Hst Hw. pose proof fld_chk as A. rewrite forallb_forall in A. specialize (A st Hst).
  unfold opc, w0 in A. rewrite Hw in A. exact A.
Qed.

Lemma byte_nn : forall w k, 0 <= Z.land (Z.shiftr w k) 255.
Proof. intros w k. apply Z.land_nonneg. right. lia. Qed.

Lemma fsafe_rng : forall f, fsafe f = true -> 0 <= f -> forall oc (ch : memory_chunk), size_chunk ch <= 4 ->
  oc + 136 + 4 * f + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_STK + 34 <= oc + 136 + 4 * f.
Proof.
  intros f Hf H0 oc ch Hc. unfold fsafe, OW.O_CMD, OW.O_STK in *.
  apply orb_true_iff in Hf as [Hf | Hf]; apply Z.leb_le in Hf; [ left | right ]; lia.
Qed.

Lemma fld2 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w ->
  existsb (Z.eqb (Z.shiftr w 24)) [15; 17; 13; 52] = true ->
  forall oc (ch : memory_chunk), size_chunk ch <= 4 ->
  oc + 136 + 4 * byte2 w + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_STK + 34 <= oc + 136 + 4 * byte2 w.
Proof.
  intros st w Hst Hw Ho. pose proof (fld_of st w Hst Hw) as A. rewrite Ho in A. cbn [negb orb] in A.
  apply andb_prop in A as [A _]. apply andb_prop in A as [A _].
  apply fsafe_rng; [ exact A | apply byte_nn ].
Qed.

Lemma fld51 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 51 ->
  byte2 w <= 80.
Proof.
  intros st w Hst Hw Ho. pose proof (fld_of st w Hst Hw) as A. rewrite Ho in A.
  change (existsb (Z.eqb 51) [15; 17; 13; 52]) with false in A. change (51 =? 51) with true in A.
  change (51 =? 31) with false in A. cbn [negb orb andb] in A.
  apply andb_prop in A as [A _]. apply Z.leb_le. exact A.
Qed.

Lemma fld31 : forall st w, In st vm_tab -> word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 31 ->
  forall oc (ch : memory_chunk), size_chunk ch <= 4 ->
  (oc + 136 + 4 * byte3 w + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_STK + 34 <= oc + 136 + 4 * byte3 w)
  /\ (oc + 136 + 4 * byte4 w + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_STK + 34 <= oc + 136 + 4 * byte4 w).
Proof.
  intros st w Hst Hw Ho oc ch Hc. pose proof (fld_of st w Hst Hw) as A. rewrite Ho in A.
  change (existsb (Z.eqb 31) [15; 17; 13; 52]) with false in A. change (31 =? 51) with false in A.
  change (31 =? 31) with true in A. cbn [negb orb andb] in A. apply andb_prop in A as [A3 A4].
  split; (apply fsafe_rng; [ assumption | unfold byte3, byte4; apply Z.land_nonneg; right; lia | exact Hc ]).
Qed.

(* ---------------------------------------------------------------------- *)
(* 4. The keeps for INV_k from the keeps for the ghost.                    *)
(* ---------------------------------------------------------------------- *)
Section Rows.
  Variable lp : Clight.program.
  Notation G := (lp_ge lp).
  Variables (bm bc0 : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Notation MWF := (MWF_real lp bm bc0 oc0 SafeB).
  Notation Pobjl := (ClearKeep.Pobjc lp bm bc0 oc0 SafeB).

  Variables (go pool : block) (oc : Z) (bcc sb : block).
  Hypothesis Hgo : Genv.find_symbol G BhvStep.BS._gCurrentObject = Some go.
  Hypothesis Hbcc : Genv.find_symbol G BhvStep.BS._gCurBhvCommand = Some bcc.
  Hypothesis Hpool : Genv.find_symbol G ObjSelf.POOL = Some pool.
  Hypothesis Hsb : Genv.find_symbol G BhvStep.BS._gRandomSeed16 = Some sb.
  Hypothesis Hpg : pool <> go.
  Hypothesis Hbp : bcc <> pool.

  Notation Pfr := (BhvStep.Pfr pool oc bcc).
  Notation scr := (BhvStep.scr_b lp).
  Notation cur := (BhvStep.cur go pool oc).
  Notation Vo := (BhvStep.Vo lp pool oc).
  Notation Psd := (BhvStep.Psd sb).

  Variables (st0 : vst) (nb0 : block) (X : mem -> Prop).
  Notation INV := (ObjInv.INVk lp bm bc0 oc0 SafeB go pool oc bcc st0 nb0 X).
  Notation Qk := (ObjFamily.Qfam (v_s st0)).

  (* the ghost: Pobjl with slot k at st0, and the step's own fact X *)
  Definition GP (g : mem) : Prop := Pobjl g /\ Vo g st0 /\ X g.
  (* the ghost keeps, state-indexed: at every state (GPi), or outside the
     pole window (GPn: SET_INT and SET_HITBOX, whose window case is PROVED
     here, t_set / t_hb) *)
  Notation GPi := (fun _ : vst => GP).
  Definition GPn (s : vst) (g : mem) : Prop := ~ ObjInv.Wp s /\ GP g.
  Notation GPs := (ObjInv.GPs lp bm bc0 oc0 SafeB pool oc st0 X).
  (* ghost and real memory: equal off the cursor and slot k's VM cells *)
  Definition GR (g m : mem) : Prop :=
    Ple (Mem.nextblock g) nb0 /\ Mem.unchanged_on Pfr g m /\ BhvStep.nvB scr g m.

  Lemma inv_fin_s : forall s m m1 g1, Ple nb0 (Mem.nextblock m) -> Ple (Mem.nextblock m) (Mem.nextblock m1) ->
    cur m1 -> GPs s g1 -> GR g1 m1 -> INV s m1.
  Proof.
    intros s m m1 g1 Hn L Hc HG (Hgn & U & NV).
    split; [ exact (Ple_trans _ _ _ Hn L) | split; [ exact Hc | ] ].
    exists g1. exact (conj HG (conj Hgn (conj U NV))).
  Qed.

  Lemma inv_fin : forall s m m1 g1, Ple nb0 (Mem.nextblock m) -> Ple (Mem.nextblock m) (Mem.nextblock m1) ->
    cur m1 -> GP g1 -> GR g1 m1 -> INV s m1.
  Proof. intros s m m1 g1 Hn L Hc HG. exact (inv_fin_s s m m1 g1 Hn L Hc (or_introl HG)). Qed.

  (* a symbol's block is valid in the ghost (MWF's nextblock bound; as ObjInv.sym_valid) *)
  Lemma sym_v : forall g id b, GP g -> Genv.find_symbol G id = Some b -> Mem.valid_block g b.
  Proof.
    intros g id b ((Hok & _) & _) Hs. pose proof Hok as (_ & _ & HM).
    pose proof HM as ((_ & _ & _ & _ & _ & _ & _ & Hgn) & _).
    pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Mem.valid_block, Plt, Ple in *. lia.
  Qed.

  Lemma gr_st : forall g m ch z v m1, GR g m -> Mem.valid_block g pool ->
    Mem.store ch m pool z v = Some m1 ->
    exists g1, Mem.store ch g pool z v = Some g1 /\ GR g1 m1 /\ Mem.valid_block g1 pool.
  Proof.
    intros g m ch z v m1 (Hn & U & NV) Hv S.
    destruct (gr_store _ _ g m ch pool z v m1 U NV Hv S) as (g1 & Sg & U1 & NV1).
    exists g1. split; [ exact Sg | split; [ | exact (Mem.store_valid_block_1 _ _ _ _ _ _ Sg _ Hv) ] ].
    split; [ rewrite (Mem.nextblock_store _ _ _ _ _ _ Sg); exact Hn | exact (conj U1 NV1) ].
  Qed.

  Lemma cur_st : forall m ch z v m1, cur m -> Mem.store ch m pool z v = Some m1 -> cur m1.
  Proof.
    unfold BhvStep.cur. intros m ch z v m1 Hc S.
    rewrite (Mem.load_store_other _ _ _ _ _ _ S); [ exact Hc | left; exact (fun E => Hpg (eq_sym E)) ].
  Qed.

  Lemma nb_st : forall m ch z v m1, Mem.store ch m pool z v = Some m1 -> Ple (Mem.nextblock m) (Mem.nextblock m1).
  Proof. intros m ch z v m1 S. rewrite (Mem.nextblock_store _ _ _ _ _ _ S). apply Ple_refl. Qed.

  (* a load off the VM cells reads the ghost's value *)
  Lemma ld_gr : forall g m ch z, GR g m -> Mem.valid_block g pool ->
    (z + size_chunk ch <= oc + OW.O_CMD \/ oc + OW.O_STK + 34 <= z) ->
    Mem.load ch m pool z = Mem.load ch g pool z.
  Proof.
    intros g m ch z (_ & U & _) Hv Hz. apply (Mem.load_unchanged_on_1 _ _ _ _ _ _ U Hv).
    intros i Hi. unfold BhvStep.Pfr. split; [ exact (fun E => Hbp (eq_sym E)) | intros (_ & Hi'); lia ].
  Qed.

  Ltac ginv H m := destruct H as (Hn & Hc & g & HGs & Hgn & U & NV);
    assert (Hgr : GR g m) by exact (conj Hgn (conj U NV)); clear Hgn U NV.
  (* a command other than SET_INT / SET_HITBOX / CALL_NATIVE is never run in
     the pole window (ObjInv.W_not): there the ghost is GP *)
  Ltac gout_ HGs g st w Hst Hw Ho := destruct HGs as [HG | (Hwp & _)];
    [ assert (Hv : Mem.valid_block g pool) by exact (sym_v g _ _ HG Hpool)
    | exfalso; exact (ObjInv.W_not st w _ Hst Hwp Hw Ho ltac:(lia) ltac:(lia) ltac:(lia)) ].

  (* ---- the one-store keeps ---- *)
  (* SET_INT: in the pole window it is SET_INT(oInteractType, INTERACT_POLE)
     (ObjInv.W_ops), a store into the relaxed cells (PROVED: win_keep) *)
  Lemma t_set : BhvStep.set_keep pool oc GPn Qk -> BhvStep.set_keep pool oc INV Qk.
  Proof.
    intros K m st w m1 HI Hst HQ Hw Ho S. ginv HI m.
    assert (Hv : Mem.valid_block g pool) by exact (ObjInv.gps_valid lp bm bc0 oc0 SafeB pool oc st0 X st g _ _ HGs Hpool).
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    destruct (ObjInv.Wp_dec st) as [Hwp | Hnw].
    - destruct (ObjInv.W_ops st w Hst Hwp Hw) as [(_ & E2 & E3) | [E | E]];
        [ | rewrite Ho in E; discriminate E .. ].
      rewrite E2, E3 in Sg.
      destruct (ObjInv.rc_store pool oc g Mint32 _ _ g1 Sg ltac:(left; cbn [size_chunk]; lia)) as (U1 & N1).
      refine (inv_fin_s st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (or_intror (conj Hwp _)) Hgr1).
      refine (ObjInv.win_keep lp bm bc0 oc0 SafeB pool oc st0 X st g g1 Hwp HGs U1 N1 _).
      right. replace (oc + 304) with (oc + 136 + 4 * 42) by lia.
      rewrite (Mem.load_store_same _ _ _ _ _ _ Sg). reflexivity.
    - destruct HGs as [HG | (Hwp & _)]; [ | contradiction ].
      destruct (K g st w g1 (conj Hnw HG) Hst HQ Hw Ho Sg) as (_ & HG1).
      exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) HG1 Hgr1).
  Qed.

  Lemma t_setf : BhvStep.setf_keep pool oc GPi Qk -> BhvStep.setf_keep pool oc INV Qk.
  Proof.
    intros K m st w m1 HI Hst HQ Hw Ho S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w g1 HG Hst HQ Hw Ho Sg) Hgr1).
  Qed.

  Lemma t_addi : BhvStep.addi_keep pool oc GPi Qk -> BhvStep.addi_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m _ _ Hgr Hv (fld2 st w Hst Hw ltac:(rewrite Ho; reflexivity) oc Mint32 ltac:(cbn; lia))) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_ori : BhvStep.ori_keep pool oc GPi Qk -> BhvStep.ori_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m _ _ Hgr Hv (fld2 st w Hst Hw ltac:(rewrite Ho; reflexivity) oc Mint32 ltac:(cbn; lia))) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_addf : BhvStep.addf_keep pool oc GPi Qk -> BhvStep.addf_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m _ _ Hgr Hv (fld2 st w Hst Hw ltac:(rewrite Ho; reflexivity) oc Mfloat32 ltac:(cbn; lia))) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_sumf : BhvStep.sumf_keep pool oc GPi Qk -> BhvStep.sumf_keep pool oc INV Qk.
  Proof.
    intros K m st w a1 a2 m1 HI Hst HQ Hw Ho L1 L2 S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (fld31 st w Hst Hw Ho oc Mfloat32 ltac:(cbn; lia)) as (R3 & R4).
    rewrite (ld_gr g m _ _ Hgr Hv R3) in L1. rewrite (ld_gr g m _ _ Hgr Hv R4) in L2.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w a1 a2 g1 HG Hst HQ Hw Ho L1 L2 Sg) Hgr1).
  Qed.

  Lemma t_deact : BhvStep.deact_keep pool oc GPi Qk -> BhvStep.deact_keep pool oc INV Qk.
  Proof.
    intros K m st w m1 HI Hst HQ Hw Ho S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w g1 HG Hst HQ Hw Ho Sg) Hgr1).
  Qed.

  Lemma t_sit : BhvStep.sit_keep pool oc GPi Qk -> BhvStep.sit_keep pool oc INV Qk.
  Proof.
    intros K m st w a m1 HI Hst HQ Hw Ho Ha S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w a g1 HG Hst HQ Hw Ho Ha Sg) Hgr1).
  Qed.

  Lemma t_atex : BhvStep.atex_keep pool oc GPi Qk -> BhvStep.atex_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m _ _ Hgr Hv (fld2 st w Hst Hw ltac:(rewrite Ho; reflexivity) oc Mint32 ltac:(cbn; lia))) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_bb : BhvStep.bb_keep pool oc GPi Qk -> BhvStep.bb_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m Mint16signed (oc + 2) Hgr Hv ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_dr : BhvStep.dr_keep pool oc GPi Qk -> BhvStep.dr_keep pool oc INV Qk.
  Proof.
    intros K m st w old m1 HI Hst HQ Hw Ho L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m Mint16signed (oc + 2) Hgr Hv ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w old g1 HG Hst HQ Hw Ho L Sg) Hgr1).
  Qed.

  Lemma t_la : BhvStep.la_keep lp pool oc GPi Qk -> BhvStep.la_keep lp pool oc INV Qk.
  Proof.
    intros K m st w ta oa bt m1 HI Hst HQ Hw Ho Hn1 Ht S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w ta oa bt g1 HG Hst HQ Hw Ho Hn1 Ht Sg) Hgr1).
  Qed.

  Lemma t_lcd : BhvStep.lcd_keep lp pool oc GPi Qk -> BhvStep.lcd_keep lp pool oc INV Qk.
  Proof.
    intros K m st w ta oa bt m1 HI Hst HQ Hw Ho Hn1 Ht S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w ta oa bt g1 HG Hst HQ Hw Ho Hn1 Ht Sg) Hgr1).
  Qed.

  (* ---- the multi-store keeps ---- *)
  (* SET_HITBOX: in the pole window its two stores are the relaxed hitbox
     cells (PROVED: win_keep) *)
  Lemma t_hb : BhvStep.hb_keep pool oc GPn Qk -> BhvStep.hb_keep pool oc INV Qk.
  Proof.
    intros K m st w z m1 m2 HI Hst HQ Hw Ho Hz S1 S2. ginv HI m.
    assert (Hv : Mem.valid_block g pool) by exact (ObjInv.gps_valid lp bm bc0 oc0 SafeB pool oc st0 X st g _ _ HGs Hpool).
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S1) as (g1 & Sg1 & Hgr1 & Hv1).
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S2) as (g2 & Sg2 & Hgr2 & _).
    assert (Nb : Ple (Mem.nextblock m) (Mem.nextblock m2))
      by exact (Ple_trans _ _ _ (nb_st _ _ _ _ _ S1) (nb_st _ _ _ _ _ S2)).
    assert (Cu : cur m2) by exact (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ Hc S1) S2).
    destruct (ObjInv.Wp_dec st) as [Hwp | Hnw].
    - destruct (ObjInv.rc_store pool oc g Mfloat32 _ _ g1 Sg1 ltac:(right; cbn [size_chunk]; lia)) as (U1 & N1).
      destruct (ObjInv.rc_store pool oc g1 Mfloat32 _ _ g2 Sg2 ltac:(right; cbn [size_chunk]; lia)) as (U2 & N2).
      refine (inv_fin_s st m m2 g2 Hn Nb Cu (or_intror (conj Hwp _)) Hgr2).
      refine (ObjInv.win_keep lp bm bc0 oc0 SafeB pool oc st0 X st g g2 Hwp HGs
                (Mem.unchanged_on_trans _ _ _ _ U1 U2) (eq_trans N2 N1) _).
      left. rewrite (Mem.load_store_other _ _ _ _ _ _ Sg2) by (right; left; cbn [size_chunk]; lia).
      rewrite (Mem.load_store_other _ _ _ _ _ _ Sg1) by (right; left; cbn [size_chunk]; lia). reflexivity.
    - destruct HGs as [HG | (Hwp & _)]; [ | contradiction ].
      destruct (K g st w z g1 g2 (conj Hnw HG) Hst HQ Hw Ho Hz Sg1 Sg2) as (_ & HG2).
      exact (inv_fin st m m2 g2 Hn Nb Cu HG2 Hgr2).
  Qed.

  Lemma t_hbo : BhvStep.hbo_keep pool oc GPi Qk -> BhvStep.hbo_keep pool oc INV Qk.
  Proof.
    intros K m st w z z2 m1 m2 m3 HI Hst HQ Hw Ho Hz Hz2 S1 S2 S3. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S1) as (g1 & Sg1 & Hgr1 & Hv1).
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S2) as (g2 & Sg2 & Hgr2 & Hv2).
    destruct (gr_st _ _ _ _ _ _ Hgr2 Hv2 S3) as (g3 & Sg3 & Hgr3 & _).
    exact (inv_fin st m m3 g3 Hn (Ple_trans _ _ _ (Ple_trans _ _ _ (nb_st _ _ _ _ _ S1) (nb_st _ _ _ _ _ S2)) (nb_st _ _ _ _ _ S3))
             (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ Hc S1) S2) S3)
             (K g st w z z2 g1 g2 g3 HG Hst HQ Hw Ho Hz Hz2 Sg1 Sg2 Sg3) Hgr3).
  Qed.

  Lemma t_home : BhvStep.home_keep pool oc GPi Qk -> BhvStep.home_keep pool oc INV Qk.
  Proof.
    intros K m st w f1 f2 f3 m1 m2 m3 HI Hst HQ Hw Ho L1 S1 L2 S2 L3 S3. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    rewrite (ld_gr g m Mfloat32 (oc + 136 + 4 * 6) Hgr Hv ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in L1.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S1) as (g1 & Sg1 & Hgr1 & Hv1).
    rewrite (ld_gr g1 m1 Mfloat32 (oc + 136 + 4 * 7) Hgr1 Hv1 ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in L2.
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S2) as (g2 & Sg2 & Hgr2 & Hv2).
    rewrite (ld_gr g2 m2 Mfloat32 (oc + 136 + 4 * 8) Hgr2 Hv2 ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in L3.
    destruct (gr_st _ _ _ _ _ _ Hgr2 Hv2 S3) as (g3 & Sg3 & Hgr3 & _).
    exact (inv_fin st m m3 g3 Hn (Ple_trans _ _ _ (Ple_trans _ _ _ (nb_st _ _ _ _ _ S1) (nb_st _ _ _ _ _ S2)) (nb_st _ _ _ _ _ S3))
             (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ Hc S1) S2) S3)
             (K g st w f1 f2 f3 g1 g2 g3 HG Hst HQ Hw Ho L1 Sg1 L2 Sg2 L3 Sg3) Hgr3).
  Qed.

  Lemma t_phys : BhvStep.phys_keep pool oc GPi Qk -> BhvStep.phys_keep pool oc INV Qk.
  Proof.
    intros K m st w z1 z2 z3 m1 m2 m3 m4 m5 m6 HI Hst HQ Hw Ho Hz1 Hz2 Hz3 S1 S2 S3 S4 S5 S6. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S1) as (g1 & Sg1 & Hgr1 & Hv1).
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S2) as (g2 & Sg2 & Hgr2 & Hv2).
    destruct (gr_st _ _ _ _ _ _ Hgr2 Hv2 S3) as (g3 & Sg3 & Hgr3 & Hv3).
    destruct (gr_st _ _ _ _ _ _ Hgr3 Hv3 S4) as (g4 & Sg4 & Hgr4 & Hv4).
    destruct (gr_st _ _ _ _ _ _ Hgr4 Hv4 S5) as (g5 & Sg5 & Hgr5 & Hv5).
    destruct (gr_st _ _ _ _ _ _ Hgr5 Hv5 S6) as (g6 & Sg6 & Hgr6 & _).
    refine (inv_fin st m m6 g6 Hn _ _ (K g st w z1 z2 z3 g1 g2 g3 g4 g5 g6 HG Hst HQ Hw Ho Hz1 Hz2 Hz3 Sg1 Sg2 Sg3 Sg4 Sg5 Sg6) Hgr6).
    - rewrite (Mem.nextblock_store _ _ _ _ _ _ S6), (Mem.nextblock_store _ _ _ _ _ _ S5), (Mem.nextblock_store _ _ _ _ _ _ S4),
        (Mem.nextblock_store _ _ _ _ _ _ S3), (Mem.nextblock_store _ _ _ _ _ _ S2), (Mem.nextblock_store _ _ _ _ _ _ S1).
      apply Ple_refl.
    - exact (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _
               (cur_st _ _ _ _ _ Hc S1) S2) S3) S4) S5) S6).
  Qed.

  Lemma t_scale : BhvStep.scale_keep pool oc GPi Qk -> BhvStep.scale_keep pool oc INV Qk.
  Proof.
    intros K m st w m1 m2 m3 HI Hst HQ Hw Ho S1 S2 S3. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S1) as (g1 & Sg1 & Hgr1 & Hv1).
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S2) as (g2 & Sg2 & Hgr2 & Hv2).
    destruct (gr_st _ _ _ _ _ _ Hgr2 Hv2 S3) as (g3 & Sg3 & Hgr3 & _).
    exact (inv_fin st m m3 g3 Hn (Ple_trans _ _ _ (Ple_trans _ _ _ (nb_st _ _ _ _ _ S1) (nb_st _ _ _ _ _ S2)) (nb_st _ _ _ _ _ S3))
             (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ (cur_st _ _ _ _ _ Hc S1) S2) S3)
             (K g st w g1 g2 g3 HG Hst HQ Hw Ho Sg1 Sg2 Sg3) Hgr3).
  Qed.

  (* ---- PARENT_BIT_CLEAR: the parent slot's cell, off slot k's VM cells
     (the parent is slot k itself or a disjoint slot; field <= 80) ---- *)
  Lemma t_par51 : BhvStep.par51_ok pool oc GPi Qk -> BhvStep.par51_ok pool oc INV Qk.
  Proof.
    intros K m st w HI Hst HQ Hw Ho. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (K g st w HG Hst HQ Hw Ho) as (po & L & R).
    exists po. split; [ | exact R ].
    rewrite (ld_gr g m Mint32 (oc + 104) Hgr Hv ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)). exact L.
  Qed.

  Lemma t_pbc : BhvStep.pbc_keep pool oc GPi Qk -> BhvStep.pbc_keep pool oc INV Qk.
  Proof.
    intros K m st w po a old m1 HI Hst HQ Hw Ho Lp Rp Dp Ha L S. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    pose proof (fld51 st w Hst Hw Ho) as Hb. pose proof (byte_nn w 16) as Hb0. unfold byte2 in Hb.
    rewrite (ld_gr g m Mint32 (oc + 104) Hgr Hv ltac:(left; unfold OW.O_CMD; cbn [size_chunk]; lia)) in Lp.
    assert (R : po + 136 + 4 * byte2 w + size_chunk Mint32 <= oc + OW.O_CMD
                \/ oc + OW.O_STK + 34 <= po + 136 + 4 * byte2 w).
    { unfold OW.O_CMD, OW.O_STK, byte2. cbn [size_chunk].
      destruct Dp as [-> | [Dp | Dp]]; [ left | left | right ]; lia. }
    rewrite (ld_gr g m _ _ Hgr Hv R) in L.
    destruct (gr_st _ _ _ _ _ _ Hgr Hv S) as (g1 & Sg & Hgr1 & _).
    exact (inv_fin st m m1 g1 Hn (nb_st _ _ _ _ _ S) (cur_st _ _ _ _ _ Hc S) (K g st w po a old g1 HG Hst HQ Hw Ho Lp Rp Dp Ha L Sg) Hgr1).
  Qed.

  (* ---- BEGIN: the slot's behavior pointer and three symbols are valid ---- *)
  Lemma vp_gr : forall g m b o, GR g m -> Mem.valid_pointer g b o = true -> Mem.valid_pointer m b o = true.
  Proof.
    intros g m b o (_ & _ & PB & _) H. apply Mem.valid_pointer_nonempty_perm in H.
    apply Mem.valid_pointer_nonempty_perm.
    exact (proj2 (PB b o Cur Nonempty (Mem.perm_valid_block _ _ _ _ _ H)) H).
  Qed.

  Lemma t_begin : BhvStep.begin_ok lp pool oc GPi Qk -> BhvStep.begin_ok lp pool oc INV Qk.
  Proof.
    intros K m st w HI Hst HQ Hw Ho. ginv HI m. gout_ HGs g st w Hst Hw Ho.
    destruct (K g st w HG Hst HQ Hw Ho) as (bb & ob & L & Vb & Hs).
    exists bb, ob. split; [ | split ].
    - rewrite (ld_gr g m Mint32 (oc + 524) Hgr Hv ltac:(right; unfold OW.O_STK; cbn [size_chunk]; lia)). exact L.
    - exact (vp_gr g m _ _ Hgr Vb).
    - intros id Hid. destruct (Hs id Hid) as (bs & Hbs & Ne & Vs).
      exists bs. split; [ exact Hbs | split; [ exact Ne | exact (vp_gr g m _ _ Hgr Vs) ] ].
  Qed.

  (* ---- the RNG keeps: the call changes only gRandomSeed16 (Psd); the
     ghost follows by fol (g's cursor and VM cells, m1's rest) ---- *)
  Hypothesis Hsp : sb <> pool.
  Hypothesis Hsc : sb <> bcc.
  Hypothesis Hsg : sb <> go.

  Notation folk g m1 := (fol g m1 pool bcc (oc + OW.O_CMD) 42).

  Lemma fol_gr_n : forall n g m m1, Z.of_nat n <= 42 -> GR g m -> Ple (Mem.nextblock m) (Mem.nextblock m1) ->
    (forall b o, b = bcc \/ (b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + Z.of_nat n) ->
       Mem.perm m1 b o Cur Readable ->
       Mem.perm m b o Cur Readable /\ ZMap.get o ((Mem.mem_contents m1) !! b) = ZMap.get o ((Mem.mem_contents m) !! b)) ->
    GR (fol g m1 pool bcc (oc + OW.O_CMD) n) m1.
  Proof.
    intros n g m m1 Hn42 (Hgn & U & PB & NC) L HH. pose proof (Mem.unchanged_on_nextblock _ _ _ U) as Lg.
    assert (Hpb : pool <> bcc) by exact (fun E => Hbp (eq_sym E)).
    split; [ rewrite fol_nb; exact Hgn | split ].
    - constructor.
      + rewrite fol_nb. exact (Ple_trans _ _ _ Lg L).
      + intros b o k p _ Hv'. unfold Mem.valid_block in Hv'. rewrite fol_nb in Hv'. rewrite fol_perm. tauto.
      + intros b o (Hb & Hnp) _. destruct (peq b pool) as [-> | Hne].
        * rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) n); [ reflexivity | ].
          intros Ho. apply Hnp. split; [ reflexivity | ]. unfold OW.O_CMD, OW.O_STK in *. lia.
        * rewrite (fol_other g m1 pool bcc (oc + OW.O_CMD) n b o Hne Hb). reflexivity.
    - split.
      + intros b o k p Hb. rewrite fol_nb in Hb. rewrite fol_perm. tauto.
      + intros b o Hb Hr Hne. rewrite fol_nb in Hb.
        destruct (peq b bcc) as [-> | Hnb].
        * destruct (HH bcc o (or_introl eq_refl) Hr) as (Hr0 & E). rewrite E in Hne |- *.
          rewrite (fol_bc g m1 pool bcc (oc + OW.O_CMD) n Hpb) in Hne. exact (NC bcc o Hb Hr0 Hne).
        * destruct (peq b pool) as [-> | Hnp].
          -- destruct (zle (oc + OW.O_CMD) o) as [L1 | L1];
               [ destruct (zlt o (oc + OW.O_CMD + Z.of_nat n)) as [L2 | L2] | ].
             ++ destruct (HH pool o (or_intror (conj eq_refl (conj L1 L2))) Hr) as (Hr0 & E).
                rewrite E in Hne |- *. rewrite (fol_pool_in g m1 pool bcc (oc + OW.O_CMD) n o ltac:(lia)) in Hne.
                exact (NC pool o Hb Hr0 Hne).
             ++ exfalso. apply Hne. rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) n); [ reflexivity | lia ].
             ++ exfalso. apply Hne. rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) n); [ reflexivity | lia ].
          -- exfalso. apply Hne. rewrite (fol_other g m1 pool bcc (oc + OW.O_CMD) n b o Hnp Hnb). reflexivity.
  Qed.

  Lemma psd_hh : forall g m m1, GR g m -> Mem.valid_block g pool -> Mem.valid_block g bcc ->
    Mem.unchanged_on Psd m m1 ->
    forall b o, b = bcc \/ (b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + Z.of_nat 42) ->
      Mem.perm m1 b o Cur Readable ->
      Mem.perm m b o Cur Readable /\ ZMap.get o ((Mem.mem_contents m1) !! b) = ZMap.get o ((Mem.mem_contents m) !! b).
  Proof.
    intros g m m1 (_ & U & _) Hv Hvc P b o Hb Hr.
    assert (Hs : Psd b o) by (unfold BhvStep.Psd; destruct Hb as [-> | (-> & _)]; [ exact (fun E => Hsc (eq_sym E)) | exact (fun E => Hsp (eq_sym E)) ]).
    assert (Vm : Mem.valid_block m b).
    { destruct Hb as [-> | (-> & _)]; eapply Mem.valid_block_unchanged_on; eassumption. }
    pose proof (proj2 (Mem.unchanged_on_perm _ _ _ P b o Cur Readable Hs Vm) Hr) as Hr0.
    exact (conj Hr0 (Mem.unchanged_on_contents _ _ _ P b o Hs Hr0)).
  Qed.

  Lemma psd_fol : forall g m m1, GR g m -> Mem.unchanged_on Psd m m1 -> Mem.unchanged_on Psd g (folk g m1).
  Proof.
    intros g m m1 (_ & U & PB & _) P.
    assert (Hpb : pool <> bcc) by exact (fun E => Hbp (eq_sym E)).
    constructor.
    - rewrite fol_nb. apply Ple_refl.
    - intros b o k p Hs Hv'. rewrite fol_perm. unfold Mem.valid_block in Hv'.
      assert (Vm : Mem.valid_block m b) by (eapply Mem.valid_block_unchanged_on; eassumption).
      rewrite <- (Mem.unchanged_on_perm _ _ _ P b o k p Hs Vm). rewrite (PB b o k p Hv'). tauto.
    - intros b o Hs Hr. pose proof (Mem.perm_valid_block _ _ _ _ _ Hr) as Vg.
      assert (Vm : Mem.valid_block m b) by (eapply Mem.valid_block_unchanged_on; eassumption).
      destruct (peq b bcc) as [-> | Hnb]; [ exact (fol_bc g m1 pool bcc (oc + OW.O_CMD) 42 Hpb o) | ].
      assert (Hr' : Mem.perm m b o Cur Readable) by exact (proj2 (PB b o Cur Readable Vg) Hr).
      destruct (peq b pool) as [-> | Hnp].
      + destruct (zle (oc + OW.O_CMD) o) as [L1 | L1];
          [ destruct (zlt o (oc + OW.O_CMD + 42)) as [L2 | L2] | ].
        * exact (fol_pool_in g m1 pool bcc (oc + OW.O_CMD) 42 o ltac:(cbn; lia)).
        * rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 42) by (cbn; lia).
          rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hs Hr').
          apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
          unfold BhvStep.Pfr. split; [ exact Hpb | intros (_ & Ho); unfold OW.O_CMD, OW.O_STK in *; lia ].
        * rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 42) by (cbn; lia).
          rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hs Hr').
          apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
          unfold BhvStep.Pfr. split; [ exact Hpb | intros (_ & Ho); unfold OW.O_CMD, OW.O_STK in *; lia ].
      + rewrite (fol_other g m1 pool bcc (oc + OW.O_CMD) 42 b o Hnp Hnb).
        rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hs Hr').
        apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
        unfold BhvStep.Pfr. split; [ exact Hnb | intros (E & _); exact (Hnp E) ].
  Qed.

  Lemma cur_psd : forall m m1, cur m -> Mem.unchanged_on Psd m m1 -> cur m1.
  Proof.
    unfold BhvStep.cur. intros m m1 Hc P. eapply Mem.load_unchanged_on; [ exact P | | exact Hc ].
    intros i _. unfold BhvStep.Psd. exact (fun E => Hsg (eq_sym E)).
  Qed.

  Ltac gpsd P m1 g HG Hgr Hv :=
    pose proof (sym_v g _ _ HG Hbcc) as Hvc;
    pose proof (psd_fol g _ _ Hgr P) as Pg;
    pose proof (fol_gr_n 42 g _ _ ltac:(cbn; lia) Hgr (Mem.unchanged_on_nextblock _ _ _ P) (psd_hh g _ _ Hgr Hv Hvc P)) as Hgr1;
    assert (Hv1 : Mem.valid_block (folk g m1) pool) by (unfold Mem.valid_block; rewrite fol_nb; exact Hv).

  Lemma t_srf : BhvStep.srf_keep pool oc sb GPi Qk -> BhvStep.srf_keep pool oc sb INV Qk.
  Proof.
    intros K m st w z u m1 m2 HI Hst HQ Hw Ho Hz Hu P S. ginv HI m. gout_ HGs g st w Hst Hw Ho. gpsd P m1 g HG Hgr Hv.
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S) as (g2 & Sg & Hgr2 & _).
    exact (inv_fin st m m2 g2 Hn (Ple_trans _ _ _ (Mem.unchanged_on_nextblock _ _ _ P) (nb_st _ _ _ _ _ S))
             (cur_st _ _ _ _ _ (cur_psd _ _ Hc P) S) (K g st w z u _ g2 HG Hst HQ Hw Ho Hz Hu Pg Sg) Hgr2).
  Qed.

  Lemma t_sri : BhvStep.sri_keep pool oc sb GPi Qk -> BhvStep.sri_keep pool oc sb INV Qk.
  Proof.
    intros K m st w z u ri m1 m2 HI Hst HQ Hw Ho Hz Hu Hri P S. ginv HI m. gout_ HGs g st w Hst Hw Ho. gpsd P m1 g HG Hgr Hv.
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S) as (g2 & Sg & Hgr2 & _).
    exact (inv_fin st m m2 g2 Hn (Ple_trans _ _ _ (Mem.unchanged_on_nextblock _ _ _ P) (nb_st _ _ _ _ _ S))
             (cur_st _ _ _ _ _ (cur_psd _ _ Hc P) S) (K g st w z u ri _ g2 HG Hst HQ Hw Ho Hz Hu Hri Pg Sg) Hgr2).
  Qed.

  Lemma t_sir : BhvStep.sir_keep pool oc sb GPi Qk -> BhvStep.sir_keep pool oc sb INV Qk.
  Proof.
    intros K m st w z u ri m1 m2 HI Hst HQ Hw Ho Hz Hu Hri P S. ginv HI m. gout_ HGs g st w Hst Hw Ho. gpsd P m1 g HG Hgr Hv.
    destruct (gr_st _ _ _ _ _ _ Hgr1 Hv1 S) as (g2 & Sg & Hgr2 & _).
    exact (inv_fin st m m2 g2 Hn (Ple_trans _ _ _ (Mem.unchanged_on_nextblock _ _ _ P) (nb_st _ _ _ _ _ S))
             (cur_st _ _ _ _ _ (cur_psd _ _ Hc P) S) (K g st w z u ri _ g2 HG Hst HQ Hw Ho Hz Hu Hri Pg Sg) Hgr2).
  Qed.
  (* ---- SFR' (sfr_keep): a bulk native at a generic state.  The ghost
     follows by fol with g's bytes at the cursor and slot k's Vo cells
     [460, 500) only: SFR' lets a native write the slot's non-XBn bytes,
     the delay timer [500, 502) among them.  The ghost keep (gsfr_keep)
     is sfr_keep's own shape on the ghost: g -> g1 changes only what SFR'
     allows at g, every changed readable byte holds no pointer but into a
     script or a SafeB block (the natives' values, PV := SafeB, and the
     VM's own pushes), g's nextblock ---- *)
  Hypothesis Hoc : 0 <= oc <= 145312.
  Hypothesis Hk0 : (List.length (v_k st0) <= 8)%nat.
  Notation SFPn := (BhvStep.SFPn lp go pool oc).
  Notation folv g m1 := (fol g m1 pool bcc (oc + OW.O_CMD) 40).

  Definition gsfr_keep : Prop := forall g g1 st, GP g -> In st vm_tab -> Qk st ->
    existsb (Pos.eqb (v_s st)) BhvStep.sp_scripts = false ->
    Mem.unchanged_on (SFPn g) g g1 -> BhvStep.nvB (fun b => scr b \/ SafeB b) g g1 ->
    Mem.nextblock g1 = Mem.nextblock g -> Pobjl g1 /\ X g1.

  Lemma uoc : Ptrofs.unsigned (Ptrofs.repr oc) = oc.
  Proof. apply Ptrofs.unsigned_repr. rewrite BhvStep.maxu. lia. Qed.

  Lemma sfp_vm : forall m o, oc + OW.O_CMD <= o < oc + OW.O_CMD + Z.of_nat 40 -> SFPn m pool o.
  Proof.
    intros m o Ho. unfold BhvStep.SFPn, ObjSelf.SFP. left. split; [ reflexivity | right ].
    exists (460, 500). split; [ unfold ObjFrame.XBn; cbn [In]; do 3 right; left; reflexivity | ].
    cbn [fst snd]. rewrite uoc. unfold OW.O_CMD in Ho. cbn in Ho. lia.
  Qed.

  Lemma sfp_bc : forall m, Mem.valid_block m bcc -> forall o, SFPn m bcc o.
  Proof.
    intros m Hv o. unfold BhvStep.SFPn, ObjSelf.SFP, ObjSelf.PB. right. right.
    split; [ exact Hbp | split; [ exact Hv | ] ].
    intros (x & Hx & Hs).
    assert (Ex : x = BhvStep.BS._gCurBhvCommand) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbcc ]).
    subst x. pose proof BhvStep.bc_not_allow as Hn.
    assert (Ht : existsb (Pos.eqb BhvStep.BS._gCurBhvCommand) ObjFrame.allow_n = true)
      by (apply existsb_exists; exists BhvStep.BS._gCurBhvCommand; split; [ exact Hx | apply Pos.eqb_refl ]).
    rewrite Ht in Hn. discriminate Hn.
  Qed.

  Lemma sfp_mono : forall g m b o, Ple (Mem.nextblock g) (Mem.nextblock m) -> SFPn g b o -> SFPn m b o.
  Proof.
    intros g m b o L H. unfold BhvStep.SFPn, ObjSelf.SFP, ObjSelf.PB in *.
    destruct H as [H | [H | (H1 & H2 & H3)]]; [ left; exact H | right; left; exact H | right; right ].
    exact (conj H1 (conj (Plt_Ple_trans _ _ _ H2 L) H3)).
  Qed.

  (* an SFR' cell off the ghost's fol cells is a frame cell *)
  Lemma sfp_pfr : forall g b o, SFPn g b o -> b <> bcc ->
    ~ (b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + Z.of_nat 40) -> Pfr b o.
  Proof.
    intros g b o H Hb Hn. unfold BhvStep.Pfr. split; [ exact Hb | ]. intros (-> & Ho).
    apply Hn. split; [ reflexivity | ]. cbn. unfold BhvStep.SFPn, ObjSelf.SFP, ObjSelf.PB in H.
    destruct H as [(_ & [Nown | (r & Hr & Hro)]) | [E | (E & _)]].
    - exfalso. apply Nown. unfold ObjSelf.own. rewrite uoc. unfold ObjFrame.OSZ, OW.O_CMD, OW.O_STK in *. lia.
    - unfold ObjFrame.XBn in Hr. rewrite uoc in Hro. unfold OW.O_CMD, OW.O_STK in *.
      cbn [In] in Hr. repeat (destruct Hr as [<- | Hr]; [ cbn [fst snd] in Hro; lia | ]). destruct Hr.
    - exfalso. exact (Hpg E).
    - exfalso. exact (E eq_refl).
  Qed.

  Lemma pmvok_mono : forall (P Q : block -> Prop) mv, (forall b, P b -> Q b) -> BhvStep.pmvok P mv -> BhvStep.pmvok Q mv.
  Proof.
    intros P Q mv H. destruct mv as [ | | v q n ]; cbn; auto. destruct v; auto.
  Qed.

  Lemma sfr_hh : forall g m m1, GR g m -> Mem.valid_block g pool -> Mem.valid_block g bcc ->
    Mem.unchanged_on (SFPn m) m m1 ->
    forall b o, b = bcc \/ (b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + Z.of_nat 40) ->
      Mem.perm m1 b o Cur Readable ->
      Mem.perm m b o Cur Readable /\ ZMap.get o ((Mem.mem_contents m1) !! b) = ZMap.get o ((Mem.mem_contents m) !! b).
  Proof.
    intros g m m1 (_ & U & _) Hv Hvc P b o Hb Hr.
    assert (Vm : Mem.valid_block m b)
      by (destruct Hb as [-> | (-> & _)]; eapply Mem.valid_block_unchanged_on; eassumption).
    assert (Hs : SFPn m b o)
      by (destruct Hb as [-> | (-> & Ho)]; [ exact (sfp_bc m Vm o) | exact (sfp_vm m o Ho) ]).
    pose proof (proj2 (Mem.unchanged_on_perm _ _ _ P b o Cur Readable Hs Vm) Hr) as Hr0.
    exact (conj Hr0 (Mem.unchanged_on_contents _ _ _ P b o Hs Hr0)).
  Qed.

  Lemma sfr_fol : forall g m m1, GR g m -> Mem.unchanged_on (SFPn m) m m1 -> BhvStep.pback m m1 ->
    Mem.unchanged_on (SFPn g) g (folv g m1).
  Proof.
    intros g m m1 (_ & U & PB & _) P PB1. pose proof (Mem.unchanged_on_nextblock _ _ _ U) as Lg.
    assert (Hpb : pool <> bcc) by exact (fun E => Hbp (eq_sym E)).
    constructor.
    - rewrite fol_nb. apply Ple_refl.
    - intros b o k p Hs Hv'. rewrite fol_perm. unfold Mem.valid_block in Hv'.
      rewrite (PB1 b o k p (Plt_Ple_trans _ _ _ Hv' Lg)), (PB b o k p Hv'). tauto.
    - intros b o Hs Hr. pose proof (Mem.perm_valid_block _ _ _ _ _ Hr) as Vg.
      destruct (peq b bcc) as [-> | Hnb]; [ exact (fol_bc g m1 pool bcc (oc + OW.O_CMD) 40 Hpb o) | ].
      assert (Hr' : Mem.perm m b o Cur Readable) by exact (proj2 (PB b o Cur Readable Vg) Hr).
      assert (Hsm : SFPn m b o) by exact (sfp_mono g m b o Lg Hs).
      destruct (peq b pool) as [-> | Hnp].
      + destruct (zle (oc + OW.O_CMD) o) as [L1 | L1];
          [ destruct (zlt o (oc + OW.O_CMD + 40)) as [L2 | L2] | ].
        * exact (fol_pool_in g m1 pool bcc (oc + OW.O_CMD) 40 o ltac:(cbn; lia)).
        * rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 40) by (cbn; lia).
          rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hsm Hr').
          apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
          apply (sfp_pfr g pool o Hs Hpb). cbn. lia.
        * rewrite (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 40) by (cbn; lia).
          rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hsm Hr').
          apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
          apply (sfp_pfr g pool o Hs Hpb). cbn. lia.
      + rewrite (fol_other g m1 pool bcc (oc + OW.O_CMD) 40 b o Hnp Hnb).
        rewrite (Mem.unchanged_on_contents _ _ _ P _ _ Hsm Hr').
        apply (Mem.unchanged_on_contents _ _ _ U); [ | exact Hr ].
        apply (sfp_pfr g b o Hs Hnb). intros (E & _). exact (Hnp E).
  Qed.

  Lemma sfr_nv : forall g m m1, GR g m -> BhvStep.nvB SafeB m m1 ->
    BhvStep.nvB (fun b => scr b \/ SafeB b) g (folv g m1).
  Proof.
    intros g m m1 (_ & U & PB & NC) (PB1 & NC1). pose proof (Mem.unchanged_on_nextblock _ _ _ U) as Lg.
    assert (Hpb : pool <> bcc) by exact (fun E => Hbp (eq_sym E)).
    split.
    - intros b o k p Hb. rewrite fol_perm. rewrite (PB1 b o k p (Plt_Ple_trans _ _ _ Hb Lg)), (PB b o k p Hb). tauto.
    - intros b o Hb Hr Hne. apply fol_perm in Hr as (_ & Hr1).
      assert (Hr0 : Mem.perm m b o Cur Readable) by exact (proj1 (PB1 b o Cur Readable (Plt_Ple_trans _ _ _ Hb Lg)) Hr1).
      assert (Fo : ZMap.get o ((Mem.mem_contents (folv g m1)) !! b) = ZMap.get o ((Mem.mem_contents m1) !! b)
                   \/ ZMap.get o ((Mem.mem_contents (folv g m1)) !! b) = ZMap.get o ((Mem.mem_contents g) !! b)).
      { destruct (peq b bcc) as [-> | Hnb]; [ right; exact (fol_bc g m1 pool bcc (oc + OW.O_CMD) 40 Hpb o) | ].
        destruct (peq b pool) as [-> | Hnp].
        - destruct (zle (oc + OW.O_CMD) o) as [L1 | L1];
            [ destruct (zlt o (oc + OW.O_CMD + 40)) as [L2 | L2] | ].
          + right. exact (fol_pool_in g m1 pool bcc (oc + OW.O_CMD) 40 o ltac:(cbn; lia)).
          + left. apply (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 40). cbn. lia.
          + left. apply (fol_pool_out g m1 pool bcc (oc + OW.O_CMD) 40). cbn. lia.
        - left. exact (fol_other g m1 pool bcc (oc + OW.O_CMD) 40 b o Hnp Hnb). }
      destruct Fo as [Fo | Fo]; [ | exfalso; exact (Hne Fo) ].
      rewrite Fo in Hne |- *.
      destruct (BhvStep.memval_eq_dec (ZMap.get o ((Mem.mem_contents m1) !! b))
                                      (ZMap.get o ((Mem.mem_contents m) !! b))) as [E | E].
      + rewrite E in Hne |- *. apply (pmvok_mono scr); [ intros x Hx; left; exact Hx | exact (NC b o Hb Hr0 Hne) ].
      + apply (pmvok_mono SafeB); [ intros x Hx; right; exact Hx | ].
        exact (NC1 b o (Plt_Ple_trans _ _ _ Hb Lg) Hr1 E).
  Qed.

  (* slot k's Vo cells are g's in fol *)
  Lemma vo_fol : forall g m m1, Vo g st0 -> GR g m -> BhvStep.pback m m1 -> Mem.valid_block g pool ->
    Vo (folv g m1) st0.
  Proof.
    intros g m m1 HV (_ & U & PB & _) PB1 Hv. pose proof (Mem.unchanged_on_nextblock _ _ _ U) as Lg.
    assert (U' : Mem.unchanged_on (fun b o => b = pool /\ oc + OW.O_CMD <= o < oc + OW.O_CMD + 40) g (folv g m1)).
    { constructor.
      - rewrite fol_nb. apply Ple_refl.
      - intros b o k p (-> & _) Hvb. rewrite fol_perm. unfold Mem.valid_block in Hvb.
        rewrite (PB1 pool o k p (Plt_Ple_trans _ _ _ Hvb Lg)), (PB pool o k p Hvb). tauto.
      - intros b o (-> & Ho) _. exact (fol_pool_in g m1 pool bcc (oc + OW.O_CMD) 40 o ltac:(cbn; lia)). }
    destruct HV as ((b & Hb & Hl) & Hsi & Hk).
    split; [ exists b; split; [ exact Hb | ] | split ].
    - refine (Mem.load_unchanged_on _ _ _ _ _ _ _ U' _ Hl).
      intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. lia.
    - refine (Mem.load_unchanged_on _ _ _ _ _ _ _ U' _ Hsi).
      intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. unfold OW.O_SIDX, OW.O_CMD in *. lia.
    - intros j f Hj. pose proof (Hk j f Hj) as Hf.
      assert (Hlt : (j < List.length (v_k st0))%nat) by (apply nth_error_Some; rewrite Hj; discriminate).
      assert (R : forall i, oc + OW.O_STK + 4 * (Z.of_nat (List.length (v_k st0)) - 1 - Z.of_nat j) <= i
                  < oc + OW.O_STK + 4 * (Z.of_nat (List.length (v_k st0)) - 1 - Z.of_nat j) + size_chunk Mint32 ->
                  pool = pool /\ oc + OW.O_CMD <= i < oc + OW.O_CMD + 40).
      { intros i Hi. split; [ reflexivity | ]. cbn [size_chunk] in Hi. unfold OW.O_STK, OW.O_CMD in *. lia. }
      destruct f as [s0 i0 |];
        [ destruct Hf as (b0 & Hb0 & Hl0); exists b0; split; [ exact Hb0 | ] | destruct Hf as (c & Hl0); exists c ];
        exact (Mem.load_unchanged_on _ _ _ _ _ _ _ U' R Hl0).
  Qed.

  Lemma cur_sfr : forall m m1, cur m -> Mem.unchanged_on (SFPn m) m m1 -> cur m1.
  Proof.
    unfold BhvStep.cur. intros m m1 Hc P. eapply Mem.load_unchanged_on; [ exact P | | exact Hc ].
    intros i _. unfold BhvStep.SFPn, ObjSelf.SFP, ObjSelf.PB. right. left. reflexivity.
  Qed.

  Lemma t_sfr : gsfr_keep -> BhvStep.sfr_keep lp go pool oc bcc INV Qk (fun _ => SafeB).
  Proof.
    intros K m m1 st HI _ Hst HQ Hgen U1 NV1. ginv HI m. destruct HGs as [HG | (Hwp & _)]; [ | rewrite (ObjInv.W_sp st Hwp) in Hgen; discriminate Hgen ]. assert (Hv : Mem.valid_block g pool) by exact (sym_v g _ _ HG Hpool).
    pose proof (sym_v g _ _ HG Hbcc) as Hvc.
    destruct (K g (folv g m1) st HG Hst HQ Hgen (sfr_fol g m m1 Hgr U1 (proj1 NV1)) (sfr_nv g m m1 Hgr NV1)
                (fol_nb _ _ _ _ _ _)) as (Kp & Kx).
    exact (inv_fin st m m1 (folv g m1) Hn (Mem.unchanged_on_nextblock _ _ _ U1) (cur_sfr m m1 Hc U1)
             (conj Kp (conj (vo_fol g m m1 (proj1 (proj2 HG)) Hgr (proj1 NV1) Hv) Kx))
             (fol_gr_n 40 g m m1 ltac:(cbn; lia) Hgr (Mem.unchanged_on_nextblock _ _ _ U1) (sfr_hh g m m1 Hgr Hv Hvc U1))).
  Qed.
  (* ---- the bundle: BhvStep.row_keeps at INV := INV_k, PV := SafeB, from
     the ghost keeps (premises about Pobjl memories) and the keeps not yet
     moved to the ghost (the natives' value side and residual, the spawns,
     ANIMATE, DROP_TO_FLOOR: they read cells or run code the ghost does not
     follow by one store / one footprint) ---- *)
  Definition ghost_keeps : Prop :=
    BhvStep.set_keep pool oc GPn Qk /\ BhvStep.setf_keep pool oc GPi Qk /\ BhvStep.addi_keep pool oc GPi Qk
    /\ BhvStep.ori_keep pool oc GPi Qk /\ BhvStep.addf_keep pool oc GPi Qk /\ BhvStep.sumf_keep pool oc GPi Qk
    /\ BhvStep.deact_keep pool oc GPi Qk /\ BhvStep.sit_keep pool oc GPi Qk /\ BhvStep.srf_keep pool oc sb GPi Qk
    /\ BhvStep.sri_keep pool oc sb GPi Qk /\ BhvStep.sir_keep pool oc sb GPi Qk /\ BhvStep.par51_ok pool oc GPi Qk
    /\ BhvStep.pbc_keep pool oc GPi Qk /\ BhvStep.atex_keep pool oc GPi Qk /\ BhvStep.bb_keep pool oc GPi Qk
    /\ BhvStep.dr_keep pool oc GPi Qk /\ BhvStep.hb_keep pool oc GPn Qk /\ BhvStep.hbo_keep pool oc GPi Qk
    /\ BhvStep.home_keep pool oc GPi Qk /\ BhvStep.phys_keep pool oc GPi Qk /\ BhvStep.la_keep lp pool oc GPi Qk
    /\ BhvStep.lcd_keep lp pool oc GPi Qk /\ BhvStep.scale_keep pool oc GPi Qk /\ BhvStep.begin_ok lp pool oc GPi Qk
    /\ gsfr_keep.

  Definition rest_keeps : Prop :=
    BhvStep.native_vals lp pool oc bcc INV Qk (fun _ => SafeB) /\ BhvStep.native_res lp pool oc bcc INV Qk
    /\ BhvStep.sc_pre lp pool oc INV Qk /\ BhvStep.sc_free lp pool INV Qk
    /\ BhvStep.sc_keep lp pool oc bcc INV Qk /\ BhvStep.wd_pre lp pool oc INV Qk
    /\ BhvStep.wd_free lp pool INV Qk /\ BhvStep.wd_dp lp INV
    /\ BhvStep.wd_keep lp pool oc bcc sb INV Qk /\ BhvStep.an_keep pool oc INV Qk
    /\ BhvStep.dtf_ff lp INV /\ BhvStep.dtf_keep lp pool oc INV Qk.

  (* the residual ghost keeps (2026-11-08): BILLBOARD's and
     DISABLE_RENDERING's (the s16 store into the slot's graph-node flags,
     @2) are PROVED for the objects step's ghost facts (ObjStep.bb_g /
     dr_g, from ObjGfl); the window fields and SCALE too (ObjStep) *)
  (* SET_INT's keep at its one read field, 42 (oInteractType: the pole /
     cannon pins, BhvStep.set42); its other fields are windows (ObjStep.set_g) *)
  Definition set42_keep : Prop := forall m st w m1, ~ ObjInv.Wp st -> GP m -> In st vm_tab -> Qk st ->
    word_at (v_s st) (v_i st) = Some w -> Z.shiftr w 24 = 16 -> byte2 w = 42 ->
    Mem.store Mint32 m pool (oc + 136 + 4 * 42) (Vint (BhvStep.s16_of w)) = Some m1 -> GP m1.

  (* FOUND/REPAIRED 2026-11-09 (the earlier set42_keep was FALSE in the real game, so were the
     capstones' Hobj_cou_nt / Hobj_cou_t, which ask it for every slot and
     start state): bhvPoleGrabbing's word 2 is SET_INT(oInteractType,
     INTERACT_POLE = 64), word 3-4 SET_HITBOX(80, 1500), word 5 the
     CALL_NATIVE of bhv_pole_init (which sets hitboxHeight from the
     params).  On a pole's first update hitboxHeight is allocate_object's
     100.0f, then 1500; no WMotR pole is 100 or 1500 tall.  So right after
     word 2, obj_w's kind_ok (POLE: hitboxHeight = top - base) fails at the
     updated slot, and INV_k's ghost (Pobjl after every command) was not an
     invariant of the real dispatch loop.  Checked here from the generated
     script and level data.
     REPAIRED: INV_k is state-indexed and relaxes slot k's interact type and
     hitbox cells in the pole window (ObjInv.Wp: words 2, 3, 5); set42_keep
     and SET_HITBOX's keep are asked outside it only (GPn), their window
     case is PROVED (t_set, t_hb); the native at word 5 re-establishes the
     full ghost (native_res; obj_w's pole pins P give its height).
     STILL OPEN (FOUND 2026-11-09): bhvCannon's word 6, ADD_FLOAT(oPosY,
     -340), asked at every ghost by addf_keep, is false at a phantom ghost
     (slot k already CANNON_BASE at the lid's y - 340, VM back at word 0 --
     a legal Pobjl memory): re-running word 6 leaves cannon_obj_ok.  Not
     repaired here (needs a cannon window to the exit, or a new premise). *)
  Lemma set42_pole_found :
    map (fun i => option_map (fun w => (Z.shiftr w 24, byte2 w, Z.land w 65535))
                    (word_at behavior_data._bhvPoleGrabbing i)) [2; 3; 4; 5]%nat
      = [Some (16, 42, WMotRWorld.INTERACT_POLE); Some (35, 0, 0); Some (0, 80, 1500); Some (12, 0, 0)]
    /\ forallb (fun bt => negb ((snd bt - fst bt =? 100) || (snd bt - fst bt =? 1500))) WMotRLevel.wmotr_pole_list = true.
  Proof. split; vm_compute; reflexivity. Qed.

  Definition ghost_keeps_r : Prop :=
    set42_keep /\ BhvStep.addf_keep pool oc GPi Qk /\ BhvStep.sumf_keep pool oc GPi Qk
    /\ BhvStep.deact_keep pool oc GPi Qk /\ BhvStep.sit_keep pool oc GPi Qk /\ BhvStep.srf_keep pool oc sb GPi Qk
    /\ BhvStep.sri_keep pool oc sb GPi Qk /\ BhvStep.sir_keep pool oc sb GPi Qk /\ BhvStep.par51_ok pool oc GPi Qk
    /\ BhvStep.hb_keep pool oc GPn Qk /\ BhvStep.hbo_keep pool oc GPi Qk
    /\ BhvStep.la_keep lp pool oc GPi Qk
    /\ BhvStep.lcd_keep lp pool oc GPi Qk /\ BhvStep.begin_ok lp pool oc GPi Qk
    /\ gsfr_keep.

  (* the keeps PROVED in ObjStep (bb / dr: ObjGfl; setf / addi / ori /
     atex / home / phys: ObjFld + FieldWinCensus; scale: ObjFldLo, the
     slot is not Mario's) are this lemma's
     arguments; ghost_keeps_r is what is still asked *)
  Lemma ghost_keeps_of : BhvStep.set_keep pool oc GPn Qk ->
    BhvStep.bb_keep pool oc GPi Qk -> BhvStep.dr_keep pool oc GPi Qk ->
    BhvStep.setf_keep pool oc GPi Qk -> BhvStep.addi_keep pool oc GPi Qk -> BhvStep.ori_keep pool oc GPi Qk ->
    BhvStep.atex_keep pool oc GPi Qk -> BhvStep.pbc_keep pool oc GPi Qk -> BhvStep.home_keep pool oc GPi Qk -> BhvStep.phys_keep pool oc GPi Qk ->
    BhvStep.scale_keep pool oc GPi Qk ->
    ghost_keeps_r -> ghost_keeps.
  Proof.
    intros K16 K33 K53 K14 K15 K17 K52 K51 K45 K48 K50
      (_ & K13 & K31 & K29 & K47 & K20 & K21 & K19 & K51p & K35 & K43 & K39 & K42 & K0 & Ksfr).
    repeat (apply conj; [ eassumption | ]). exact Ksfr.
  Qed.

  Theorem rows_k : ghost_keeps -> rest_keeps -> BhvStep.row_keeps lp go pool oc bcc sb INV Qk (fun _ => SafeB).
  Proof.
    intros (K16 & K14 & K15 & K17 & K13 & K31 & K29 & K47 & K20 & K21 & K19 & K51p & K51 & K52 & K33 & K53
            & K35 & K43 & K45 & K48 & K39 & K42 & K50 & K0 & Ksfr)
           (Kv & Kr & Kc1 & Kc2 & Kc3 & Kw1 & Kw2 & Kw3 & Kw4 & Kan & Kd1 & Kd2).
    unfold BhvStep.row_keeps.
    refine (conj (t_set K16) _).
    refine (conj (t_setf K14) _).
    refine (conj (t_addi K15) _).
    refine (conj (t_ori K17) _).
    refine (conj (t_addf K13) _).
    refine (conj (t_sumf K31) _).
    refine (conj (t_deact K29) _).
    refine (conj (t_sit K47) _).
    refine (conj (t_srf K20) _).
    refine (conj (t_sri K21) _).
    refine (conj (t_sir K19) _).
    refine (conj (t_par51 K51p) _).
    refine (conj (t_pbc K51) _).
    refine (conj (t_atex K52) _).
    refine (conj (t_bb K33) _).
    refine (conj (t_dr K53) _).
    refine (conj (t_hb K35) _).
    refine (conj (t_hbo K43) _).
    refine (conj (t_home K45) _).
    refine (conj (t_phys K48) _).
    refine (conj (t_la K39) _).
    refine (conj (t_lcd K42) _).
    refine (conj (t_scale K50) _).
    refine (conj (t_begin K0) _).
    refine (conj (t_sfr Ksfr) _).
    refine (conj (Kv) _).
    refine (conj (Kr) _).
    refine (conj (Kc1) _).
    refine (conj (Kc2) _).
    refine (conj (Kc3) _).
    refine (conj (Kw1) _).
    refine (conj (Kw2) _).
    refine (conj (Kw3) _).
    refine (conj (Kw4) _).
    refine (conj (Kan) _).
    refine (conj (Kd1) _).
    exact Kd2.
  Qed.
End Rows.
