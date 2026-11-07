(* ====================================================================== *)
(* UnloadOw (GOAL 2 objects, 2026-11-03): the object world across the     *)
(* real unload_object on an inactive slot k of ring i.                    *)
(*                                                                        *)
(* obj_w_unload: from ow_core at m with rings rs and free list fs, the     *)
(* memory after the call (UnloadSharp.unload_sharp_real: ring i loses k,  *)
(* the free list gains it, the graph shape and k's zero flags) satisfies  *)
(* ow_core with rings upd rs i (l1 ++ l2) and free list k :: fs, given    *)
(* the keep the sharp footprint yields: obj_w's other globals, the        *)
(* dynamic blocks, Mario's cells and the scripts unchanged, and every     *)
(* slot's fields from offset 104 unchanged except k's prevObj (108) and   *)
(* activeFlags (116).  Mario's slot is active (ow_mact), so it is not k.  *)
(* PollKeep's slot keeps assume no change from offset 96 on; here the     *)
(* list links (96..104) change, so the clause keeps are restated over      *)
(* that narrower keep (KPu).                                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool Permutation.
From compcert Require Import Coqlib Maps AST Integers Floats Values Memory Globalenvs Ctypes Clight ClightBigstep.
From SM64.Generated Require object_list_processor debug behavior_script surface_load area.
From SM64.Proofs.WMotRRequiresA Require Import WMotRWorld.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep UnloadLoop BhvVM.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.

(* ---------------------------------------------------------------------- *)
(* 1. Lists: ring i loses k, the free list gains it.                      *)
(* ---------------------------------------------------------------------- *)
Lemma upd_split : forall {A} (l : list A) i x, (i < List.length l)%nat ->
  ObjRing.upd l i x = firstn i l ++ x :: skipn (S i) l.
Proof.
  intros A l. induction l as [|a l IH]; intros i x H; [ cbn in H; lia | ].
  destruct i; cbn; [ reflexivity | ]. f_equal. apply IH. cbn in H. lia.
Qed.

Lemma nth_split : forall {A} (l : list A) i d, (i < List.length l)%nat ->
  l = firstn i l ++ nth i l d :: skipn (S i) l.
Proof.
  intros A l. induction l as [|a l IH]; intros i d H; [ cbn in H; lia | ].
  destruct i; cbn; [ reflexivity | ]. f_equal. apply IH. cbn in H. lia.
Qed.


Lemma perm_unl : forall (A B l1 l2 fs : list Z) k,
  Permutation (A ++ l1 ++ l2 ++ B ++ k :: fs) (A ++ l1 ++ (k :: l2) ++ B ++ fs).
Proof.
  intros A B l1 l2 fs k. apply Permutation_app_head, Permutation_app_head. cbn [app].
  rewrite (app_assoc l2 B (k :: fs)), (app_assoc l2 B fs). apply Permutation_sym, Permutation_middle.
Qed.

Section LISTS.
  Variables (rs : list (list Z)) (fs l1 l2 : list Z) (i : nat) (k : Z).
  Hypothesis Hlen : (i < List.length rs)%nat.
  Hypothesis El : nth i rs [] = l1 ++ k :: l2.
  Notation rs' := (ObjRing.upd rs i (l1 ++ l2)).

  Lemma concat_old : concat rs = concat (firstn i rs) ++ (l1 ++ k :: l2) ++ concat (skipn (S i) rs).
  Proof. rewrite (nth_split rs i [] Hlen) at 1. rewrite concat_app. cbn [concat]. rewrite El. reflexivity. Qed.
  Lemma concat_new : concat rs' = concat (firstn i rs) ++ (l1 ++ l2) ++ concat (skipn (S i) rs).
  Proof. rewrite (upd_split rs i _ Hlen). rewrite concat_app. reflexivity. Qed.

  Lemma perm_rs : Permutation (concat rs' ++ k :: fs) (concat rs ++ fs).
  Proof.
    rewrite concat_new, concat_old. rewrite <- !app_assoc. apply perm_unl.
  Qed.

  Lemma in_new : forall j, In j (concat rs') -> In j (concat rs).
  Proof.
    intros j H. rewrite concat_new in H. rewrite concat_old.
    apply in_app_or in H as [H | H]; apply in_or_app; [ left; exact H | right ].
    apply in_app_or in H as [H | H]; apply in_or_app; [ left | right; exact H ].
    apply in_app_or in H as [H | H]; apply in_or_app; [ left; exact H | right; right; exact H ].
  Qed.

  Lemma in_nth_new : forall i' j, In j (nth i' rs' []) -> In j (nth i' rs []).
  Proof.
    intros i' j H. destruct (Nat.eq_dec i' i) as [-> | Ne].
    - rewrite ObjRing.upd_nth_eq in H by exact Hlen. rewrite El.
      apply in_app_or in H as [H | H]; apply in_or_app; [ left; exact H | right; right; exact H ].
    - rewrite ObjRing.upd_nth_ne in H by exact Ne. exact H.
  Qed.

  Lemma new_ne : NoDup (concat rs ++ fs) -> forall j, In j (concat rs') -> j <> k.
  Proof.
    intros Hnd j Hj ->. pose proof (Permutation_NoDup (Permutation_sym perm_rs) Hnd) as N.
    apply NoDup_remove_2 in N. apply N. apply in_or_app. left. exact Hj.
  Qed.

  Lemma free_ne : NoDup (concat rs ++ fs) -> forall j, In j fs -> j <> k.
  Proof.
    intros Hnd j Hj ->. pose proof (Permutation_NoDup (Permutation_sym perm_rs) Hnd) as N.
    apply NoDup_remove_2 in N. apply N. apply in_or_app. right. exact Hj.
  Qed.
End LISTS.

(* ---------------------------------------------------------------------- *)
(* 2. The keep: every slot's fields from 104 on, except k's prevObj and   *)
(*    activeFlags.                                                         *)
(* ---------------------------------------------------------------------- *)
Definition KPu (pool : block) (k : Z) (m m' : mem) : Prop :=
  forall ch j off, 104 <= off -> off + size_chunk ch <= OW.OSZ ->
    (j <> k \/ off + size_chunk ch <= 108 \/ (112 <= off /\ off + size_chunk ch <= 116) \/ 118 <= off) ->
    Mem.load ch m' pool (j * OW.OSZ + off) = Mem.load ch m pool (j * OW.OSZ + off).

Ltac ks := unfold OW.O_BHV, OW.O_CMD, OW.O_SIDX, OW.O_STK, OW.O_ACTION, OW.O_HSCOUNT,
    OW.O_FLAGS, OW.OSZ, O_INTERACT_TYPE, O_POSX, O_POSY, O_POSZ, HITBOX_DOWN_OFF,
    HITBOX_H_OFF, RAW_OFF, OW.O_RTYPE, OW.O_RINFO, OW.O_PARENT, OW.O_COLL, OW.O_NCOLL, OW.O_COLLS in *;
    cbn [size_chunk] in *; lia.

Section KEEP.
  Variables (ge : genv) (pool : block) (k : Z) (m m' : mem).
  Hypothesis Ku : KPu pool k m m'.

  (* a slot other than k: every field from 104 on *)
  Lemma SK : forall j, j <> k -> forall ch off, 104 <= off -> off + size_chunk ch <= OW.OSZ ->
    Mem.load ch m' pool (j * OW.OSZ + off) = Mem.load ch m pool (j * OW.OSZ + off).
  Proof. intros j Hj ch off H1 H2. apply Ku; [ exact H1 | exact H2 | left; exact Hj ]. Qed.

  Lemma ld32_SK : forall j, j <> k -> forall off, 104 <= off -> off + 4 <= OW.OSZ ->
    OW.ld32 m' pool (j * OW.OSZ + off) = OW.ld32 m pool (j * OW.OSZ + off).
  Proof. intros j Hj off H1 H2. unfold OW.ld32. rewrite !OW.CM.load_eq. apply (SK j Hj); [ exact H1 | exact H2 ]. Qed.

  Section J.
    Variable j : Z.
    Hypothesis Hj : j <> k.

    Lemma is_bhv_u : forall id, OW.is_bhv ge pool m j id -> OW.is_bhv ge pool m' j id.
    Proof. intros id (b & Hs & L). exists b. rewrite (SK j Hj) by ks. exact (conj Hs L). Qed.
    Lemma is_bhv_u' : forall id, OW.is_bhv ge pool m' j id -> OW.is_bhv ge pool m j id.
    Proof. intros id (b & Hs & L). exists b. rewrite (SK j Hj) in L by ks. exact (conj Hs L). Qed.
    Lemma script_u : OW.script_ok ge pool m j -> OW.script_ok ge pool m' j.
    Proof. intros (id & b & o & Hin & Hs & L). exists id, b, o. rewrite (SK j Hj) by ks. exact (conj Hin (conj Hs L)). Qed.
    Lemma script12_u : OW.script12_ok ge pool m j -> OW.script12_ok ge pool m' j.
    Proof. intros (id & b & o & Hin & Hs & L). exists id, b, o. rewrite (SK j Hj) by ks. exact (conj Hin (conj Hs L)). Qed.

    Lemma vm_at_u : forall st, In st BhvVM.vm_tab -> OW.vm_at ge pool m j st -> OW.vm_at ge pool m' j st.
    Proof.
      intros st Hin ((b & Hs & L1) & L2 & F).
      pose proof (PollKeep.vm_depth st Hin) as Dp.
      split; [ exists b; rewrite (SK j Hj) by ks; exact (conj Hs L1) | split ].
      - rewrite (SK j Hj) by ks. exact L2.
      - intros n f Hn. pose proof (F n f Hn) as Fn.
        assert (Hlt : (n < List.length (BhvVM.v_k st))%nat) by (apply nth_error_Some; congruence).
        unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
        rewrite (SK j Hj) by ks. exact Fn.
    Qed.
    Lemma vm_u : OW.vm_ok ge pool m j -> OW.vm_ok ge pool m' j.
    Proof.
      intros H. apply OW.vm_ok_at in H as (st & Hin & V). apply OW.vm_ok_at.
      exists st. exact (conj Hin (vm_at_u st Hin V)).
    Qed.
    Lemma act_u : OW.act_ok ge pool m j -> OW.act_ok ge pool m' j.
    Proof.
      intros H bh t Hin Hb. destruct (H bh t Hin (is_bhv_u' bh Hb)) as (a & La & R).
      exists a. rewrite (SK j Hj) by ks. exact (conj La R).
    Qed.
    Lemma red_u : OW.red_ok ge pool m j -> OW.red_ok ge pool m' j.
    Proof.
      intros (N & R). split.
      - intros Hb. exact (N (is_bhv_u' _ Hb)).
      - intros Hb. destruct (R (is_bhv_u' _ Hb)) as (c & Lc & Rc). exists c. rewrite (SK j Hj) by ks. exact (conj Lc Rc).
    Qed.
    Lemma kind_u : OW.kind_ok pool m j -> OW.kind_ok pool m' j.
    Proof.
      intros (t & Lt & Hin & Hp & Hc & Hpx & Hcx).
      exists t.
      split; [ rewrite (SK j Hj) by ks; exact Lt | split; [ exact Hin | split; [ | split; [ | split ] ] ] ].
      - intros E. destruct (Hp E) as (base & top & Hb & L1 & L2 & L3).
        exists base, top. rewrite !(SK j Hj) by ks. exact (conj Hb (conj L1 (conj L2 L3))).
      - intros E. destruct (Hc E) as (y & Hy & L). exists y. rewrite (SK j Hj) by ks. exact (conj Hy L).
      - intros E. destruct (Hpx E) as (x & z & base & top & Hb & L1 & L2 & L3).
        exists x, z, base, top. rewrite !(SK j Hj) by ks. exact (conj Hb (conj L1 (conj L2 L3))).
      - intros E. destruct (Hcx E) as (x & z & y & Hy & L1 & L2 & L3).
        exists x, z, y. rewrite !(SK j Hj) by ks. exact (conj Hy (conj L1 (conj L2 L3))).
    Qed.
    Lemma runs_u : forall id, OW.runs ge pool m' j id = OW.runs ge pool m j id.
    Proof. intros id. unfold OW.runs. rewrite (ld32_SK j Hj) by ks. reflexivity. Qed.
    Lemma sdyn_u : OW.sdyn ge pool m' j = OW.sdyn ge pool m j.
    Proof. unfold OW.sdyn. rewrite !runs_u. reflexivity. Qed.
    Lemma coll_pin_u : OW.coll_pin ge pool m j -> OW.coll_pin ge pool m' j.
    Proof.
      intros (C1 & C2). unfold OW.coll_pin. rewrite !runs_u.
      rewrite (SK j Hj Mint32 OW.O_COLL) by ks. exact (conj C1 C2).
    Qed.
    Lemma is_bhv_b_u : forall id, OW.is_bhv_b ge pool m' id j = OW.is_bhv_b ge pool m id j.
    Proof. intros id. unfold OW.is_bhv_b. rewrite (ld32_SK j Hj) by ks. reflexivity. Qed.
  End J.

  (* any slot (k included): the VM cells, the angle velocity, the parent *)
  Lemma vm_at_all : forall j st, In st BhvVM.vm_tab -> OW.vm_at ge pool m j st -> OW.vm_at ge pool m' j st.
  Proof.
    intros j st Hin ((b & Hs & L1) & L2 & F).
    pose proof (PollKeep.vm_depth st Hin) as Dp.
    split; [ exists b; rewrite Ku by ks; exact (conj Hs L1) | split ].
    - rewrite Ku by ks. exact L2.
    - intros n f Hn. pose proof (F n f Hn) as Fn.
      assert (Hlt : (n < List.length (BhvVM.v_k st))%nat) by (apply nth_error_Some; congruence).
      unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
      rewrite Ku by ks. exact Fn.
  Qed.
  Lemma sp_vm_all : forall j, OW.sp_vm ge pool m j -> OW.sp_vm ge pool m' j.
  Proof.
    intros j (st & Hin & Hsp & V). exists st. exact (conj Hin (conj Hsp (vm_at_all j st Hin V))).
  Qed.
  Lemma angv_all : forall j a, 0 <= j < OW.NSLOT -> In a OW.ANGV ->
    Mem.load Mint32 m' pool (j * OW.OSZ + RAW_OFF + 4 * a) = Mem.load Mint32 m pool (j * OW.OSZ + RAW_OFF + 4 * a).
  Proof.
    intros j a _ Ha. rewrite <- Z.add_assoc.
    apply Ku; unfold OW.OSZ, RAW_OFF; cbn [size_chunk];
      unfold OW.ANGV in Ha; cbn [In] in Ha; destruct Ha as [<- | [<- | [<- | []]]]; lia.
  Qed.
End KEEP.

(* ---------------------------------------------------------------------- *)
(* 3. THE LEMMA                                                            *)
(* ---------------------------------------------------------------------- *)
Definition unl_gids : list ident :=
  [object_list_processor._gObjectPool; object_list_processor._gObjectListArray;
   object_list_processor._gFreeObjectList; area._gObjParentGraphNode].

Theorem obj_w_unload : forall (ge : genv) bm pool la fl gol gmo sdp gdi m m' rs fs i l1 k l2,
  Genv.find_symbol ge object_list_processor._gObjectPool = Some pool ->
  Genv.find_symbol ge object_list_processor._gObjectListArray = Some la ->
  Genv.find_symbol ge object_list_processor._gFreeObjectList = Some fl ->
  Genv.find_symbol ge object_list_processor._gObjectLists = Some gol ->
  Genv.find_symbol ge object_list_processor._gMarioObject = Some gmo ->
  Genv.find_symbol ge debug._sDebugPage = Some sdp ->
  Genv.find_symbol ge debug._gDebugInfo = Some gdi ->
  OW.ow_core ge pool la fl gol gmo sdp gdi bm m rs fs ->
  (i < OW.NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 -> UnloadLoop.inactive pool m k ->
  OW.rings m' pool la = Some (ObjRing.upd rs i (l1 ++ l2)) ->
  OW.free_list m' pool fl = Some (k :: fs) ->
  OW.gfx_ok ge pool m' ->
  Mem.load Mint16signed m' pool (k * OW.OSZ + OW.O_FLAGS) = Some (Vint Int.zero) ->
  (* obj_w's other globals *)
  (forall id b, In id PollKeep.ow_ids -> existsb (Pos.eqb id) unl_gids = false -> Genv.find_symbol ge id = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  (* the dynamic blocks *)
  (forall b, Ple (Genv.genv_next ge) b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  (* Mario's cells *)
  (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
     Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
  (* the scripts *)
  (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
     forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
  KPu pool k m m' ->
  OW.ow_core ge pool la fl gol gmo sdp gdi bm m' (ObjRing.upd rs i (l1 ++ l2)) (k :: fs).
Proof.
  intros ge bm pool la fl gol gmo sdp gdi m m' rs fs i l1 k l2 S1 S2 S3 S4 S5 S6 S7 C Hi El Ina R' F' G' A'
    K KN Kbm KSc Ku.
  destruct C as [Cg Cr Cf Cp Cfo Cm Cs Ca Crd Cdb Cst Co Cd12 Cct Cvm Csp Cso Cco Cctr Cter Cscr Cmact Cresp Cgfx Cmsurf Cpar
                 Cmvm Canim Ccls Cdp Cnco Cmco].
  assert (Hpl : pool <> la).
  { intros E. subst la. refine (Genv.global_addresses_distinct ge _ S1 S2 eq_refl). vm_compute. discriminate. }
  pose proof (proj1 (ObjRing.rings_iff pool m la rs Hpl) Cr) as (Hlen & Henc).
  assert (Hlen' : (i < List.length rs)%nat) by (rewrite Hlen; exact Hi).
  set (rs' := ObjRing.upd rs i (l1 ++ l2)) in *.
  destruct Cp as (Hnd & Hcard).
  pose proof (new_ne rs fs l1 l2 i k Hlen' El Hnd) as Nn.
  pose proof (free_ne rs fs l1 l2 i k Hlen' El Hnd) as Nf.
  pose proof (in_new rs l1 l2 i k Hlen' El) as Inw.
  pose proof (in_nth_new rs l1 l2 i k Hlen' El) as Inth.
  assert (KG : forall id, In id PollKeep.ow_ids -> existsb (Pos.eqb id) unl_gids = false ->
             forall b, Genv.find_symbol ge id = Some b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z)
    by (intros id Hin Hn b Hs; exact (K id b Hin Hn Hs)).
  assert (Kg := K object_list_processor._gObjectLists gol ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S4).
  assert (Km := K object_list_processor._gMarioObject gmo ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S5).
  assert (Ks := K debug._sDebugPage sdp ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S6).
  assert (Kd := K debug._gDebugInfo gdi ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S7).
  (* Mario is not k: his slot is active, k is not *)
  destruct Cm as (km & Hkm & Lg & Lb & Kd').
  assert (Rkm : 0 <= km < OW.NSLOT).
  { destruct (Henc 0%nat ltac:(unfold OW.NLIST; lia)) as (_ & Hc & _).
    exact (ObjRing.chain_range pool m _ _ _ Hc km Hkm). }
  assert (Nkm : km <> k).
  { intros ->. destruct (Cmact k Rkm Lg) as ((f & Lf & Ef) & _).
    destruct Ina as (a & La & Ea). rewrite Lf in La. injection La as <-. rewrite Ef in Ea.
    vm_compute in Ea. discriminate Ea. }
  constructor.
  - rewrite Kg. exact Cg.
  - exact R'.
  - exact F'.
  - split.
    + exact (Permutation_NoDup (Permutation_sym (perm_rs rs fs l1 l2 i k Hlen' El)) Hnd).
    + unfold rs'. rewrite (Permutation_length (perm_rs rs fs l1 l2 i k Hlen' El)). exact Hcard.
  - intros j [<- | Hj]; [ exact A' | ].
    rewrite (SK pool k m m' Ku j (Nf j Hj)) by ks. exact (Cfo j Hj).
  - exists km. split; [ | split; [ rewrite Km; exact Lg | split ] ].
    + destruct (Nat.eq_dec i 0) as [-> | Ne].
      * unfold rs'. rewrite ObjRing.upd_nth_eq by exact Hlen'. rewrite El in Hkm.
        apply in_app_or in Hkm as [H | [E | H]]; apply in_or_app; [ left; exact H | congruence | right; exact H ].
      * unfold rs'. rewrite ObjRing.upd_nth_ne by (intros E; apply Ne; symmetry; exact E). exact Hkm.
    + rewrite (Kbm _ (or_introl eq_refl)). exact Lb.
    + intros j Hj Ne. exact (kind_u pool k m m' Ku j (Nn j Hj) (Kd' j (Inw j Hj) Ne)).
  - intros j Hj. exact (script_u ge pool k m m' Ku j (Nn j Hj) (Cs j (Inw j Hj))).
  - intros j Hj. exact (act_u ge pool k m m' Ku j (Nn j Hj) (Ca j (Inw j Hj))).
  - intros j Hj. exact (red_u ge pool k m m' Ku j (Nn j Hj) (Crd j (Inw j Hj))).
  - rewrite Ks, Kd. exact Cdb.
  - intros z Hz. assert (Hz' : In z [120; 124; 128; 132; 96; 100; 104]) by (cbn [In] in Hz |- *; tauto).
    rewrite (Kbm z (or_intror Hz')). exact (Cst z Hz).
  - destruct Co as (b & Sb & L). exists b. split; [ exact Sb | ].
    intros j Hj. rewrite (K object_list_processor._sObjectListUpdateOrder b ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) Sb). exact (L j Hj).
  - intros j Hj. pose proof (Inth 12%nat j Hj) as Hj0.
    assert (Hjc : In j (concat rs')).
    { apply in_concat. exists (nth 12 rs' []). split; [ | exact Hj ].
      apply nth_In. unfold rs'. rewrite ObjRing.upd_length, Hlen. unfold OW.NLIST. lia. }
    exact (script12_u ge pool k m m' Ku j (Nn j Hjc) (Cd12 j Hj0)).
  - destruct Cct as (b & Sb & L). exists b. split; [ exact Sb | ].
    intros j id Hj. rewrite (K behavior_script._BehaviorCmdTable b ltac:(unfold PollKeep.ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) Sb). exact (L j id Hj).
  - intros j Hj. exact (vm_u ge pool k m m' Ku j (Nn j Hj) (Cvm j (Inw j Hj))).
  - destruct Csp as (P & HP & G1 & G2 & G3 & G4 & G5). exists P. split; [ exact HP | ].
    assert (Kc : forall id, In id PollKeep.ow_ids -> existsb (Pos.eqb id) unl_gids = false ->
               forall ch v, OW.gcell ge id ch v m -> OW.gcell ge id ch v m')
      by (intros id Hin Hn ch v; apply (PollKeep.gcell_K m m'); exact (KG id Hin Hn)).
    split; [ | split; [ | split; [ | split ] ] ];
      (apply Kc; [ unfold PollKeep.ow_ids; cbn [In]; auto 20 | vm_compute; reflexivity | assumption ]).
  - apply (OW.surf_obj_ok_ext ge pool m m'); [ | | exact (angv_all pool k m m' Ku) | exact Cso ].
    + intros id b Hin Hs. apply (KG id); [ | | exact Hs ];
        unfold OW.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin;
        destruct Hin as [<- | [<- | [<- | [<- | []]]]];
        first [ solve [ unfold PollKeep.ow_ids; cbn [In]; repeat (first [ left; reflexivity | right ]) ]
              | vm_compute; reflexivity ].
    + intros P HP _ _ ch z _. exact (KN P HP ch z).
  - destruct Cco as (C1 & C2 & C3).
    assert (Sub : forall id, (List.length (filter (OW.is_bhv_b ge pool m' id) (concat rs'))
                              <= List.length (filter (OW.is_bhv_b ge pool m id) (concat rs)))%nat).
    { intros id. unfold rs'. rewrite (concat_new rs l1 l2 i Hlen'), (concat_old rs l1 l2 i k Hlen' El).
      assert (Ef : forall l, (forall j, In j l -> j <> k) ->
                 filter (OW.is_bhv_b ge pool m' id) l = filter (OW.is_bhv_b ge pool m id) l).
      { induction l as [|a l IH]; intros Hl; [ reflexivity | cbn ].
        rewrite (is_bhv_b_u ge pool k m m' Ku a (Hl a (or_introl eq_refl))).
        rewrite IH by (intros x Hx; exact (Hl x (or_intror Hx))). reflexivity. }
      rewrite Ef.
      2: { intros j Hj. apply Nn. unfold rs'. rewrite (concat_new rs l1 l2 i Hlen'). exact Hj. }
      rewrite !filter_app, !app_length. cbn [filter].
      destruct (OW.is_bhv_b ge pool m id k); cbn [List.length]; lia. }
    split; [ pose proof (Sub macro_special_objects._bhvExclamationBox); lia | ].
    split; [ pose proof (Sub macro_special_objects._bhvCannonClosed); lia | ].
    intros j Hj Hb. rewrite (is_bhv_b_u ge pool k m m' Ku j (Nn j Hj)) in Hb.
    destruct (C3 j (Inw j Hj) Hb) as (x & y & z & Hin & L1 & L2 & L3).
    unfold OW.box_pos_ok. exists x, y, z. rewrite !(SK pool k m m' Ku j (Nn j Hj)) by ks.
    exact (conj Hin (conj L1 (conj L2 L3))).
  - destruct Cctr as (a & Ga & Ra). exists a. split; [ | exact Ra ].
    apply (PollKeep.gcell_K m m'); [ | exact Ga ].
    apply (KG surface_load._gSurfacesAllocated); [ unfold PollKeep.ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity ].
  - destruct Cter as (T1 & T2 & T3 & T4 & T5 & T6).
    assert (Kme : forall id l, In id PollKeep.ow_ids -> existsb (Pos.eqb id) unl_gids = false ->
               OW.mesh_ok ge id l m -> OW.mesh_ok ge id l m').
    { intros id l Hin Hn (b & Hs & L). exists b. split; [ exact Hs | ].
      intros j x Hj. rewrite (KG id Hin Hn b Hs). exact (L j x Hj). }
    assert (Hin_c : forall i' j, In j (nth i' rs' []) -> In j (concat rs')).
    { intros i' j Hj. apply in_concat. exists (nth i' rs' []). split; [ | exact Hj ].
      destruct (Nat.lt_ge_cases i' (List.length rs')) as [Hlt | Hge]; [ apply nth_In; exact Hlt | ].
      rewrite nth_overflow in Hj by exact Hge. destruct Hj. }
    split; [ | split; [ | split; [ | split; [ | split ] ] ] ].
    + intros i' j Hj. rewrite (sdyn_u ge pool k m m' Ku j (Nn j (Hin_c i' j Hj))). exact (T1 i' j (Inth i' j Hj)).
    + intros i' j Hi' Hj. rewrite !(runs_u ge pool k m m' Ku j (Nn j (Hin_c i' j Hj))). exact (T2 i' j Hi' (Inth i' j Hj)).
    + assert (Nn9 : forall j, In j (nth 9 rs' []) -> j <> k) by (intros j Hj; exact (Nn j (Hin_c 9%nat j Hj))).
      assert (Em : map (OW.sdyn ge pool m') (nth 9 rs' []) = map (OW.sdyn ge pool m) (nth 9 rs' [])).
      { apply map_ext_in. intros j Hj. exact (sdyn_u ge pool k m m' Ku j (Nn9 j Hj)). }
      rewrite Em.
      assert (Pos : forall j, 0 <= OW.sdyn ge pool m j)
        by (intros j; unfold OW.sdyn, OW.D_BOX, OW.D_LID;
            destruct (OW.runs ge pool m j OW.BOXS); [ lia | destruct (OW.runs ge pool m j OW.LIDS); lia ]).
      destruct (Nat.eq_dec i 9) as [-> | Ne].
      * unfold rs'. rewrite ObjRing.upd_nth_eq by exact Hlen'. rewrite El in T3.
        unfold OW.sumz in *. rewrite !map_app, !fold_right_app in *. cbn [map fold_right] in T3.
        assert (Fa : forall l a, 0 <= a -> a <= fold_right Z.add a (map (OW.sdyn ge pool m) l)).
        { induction l as [|x l IH]; intros a Ha; cbn [map fold_right]; [ lia | ].
          specialize (IH a Ha). pose proof (Pos x). lia. }
        assert (Mo : forall l a b, a <= b -> fold_right Z.add a (map (OW.sdyn ge pool m) l)
                                     <= fold_right Z.add b (map (OW.sdyn ge pool m) l)).
        { induction l as [|x l IH]; intros a b Hab; cbn [map fold_right]; [ lia | ].
          specialize (IH a b Hab). lia. }
        pose proof (Pos k) as Pk.
        assert (E2 : fold_right Z.add 0 (map (OW.sdyn ge pool m) l2)
                     <= OW.sdyn ge pool m k + fold_right Z.add 0 (map (OW.sdyn ge pool m) l2)) by lia.
        pose proof (Mo l1 _ _ E2). lia.
      * unfold rs'. rewrite ObjRing.upd_nth_ne by (intros E; apply Ne; symmetry; exact E). exact T3.
    + intros j Hj. exact (coll_pin_u ge pool k m m' Ku j (Nn j Hj) (T4 j (Inw j Hj))).
    + apply Kme; [ unfold PollKeep.ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact T5 ].
    + apply Kme; [ unfold PollKeep.ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact T6 ].
  - exact (OW.scr_ok_ext ge m m' KSc Cscr).
  - intros j Hj Lg'. rewrite Km in Lg'.
    destruct (Cmact j Hj Lg') as ((f & Lf & Ef) & (b & Sb & (o & Lc) & Lst)).
    assert (Ejk : j = km).
    { rewrite Lg in Lg'. assert (E : OW.slot_v pool km = OW.slot_v pool j) by congruence.
      exact (eq_sym (OW.slot_v_inj pool km j Rkm Hj E)). }
    subst j.
    split; [ exists f; rewrite (SK pool k m m' Ku km Nkm) by ks; exact (conj Lf Ef) | exists b; split; [ exact Sb | split ] ].
    + exists o. rewrite (SK pool k m m' Ku km Nkm) by ks. exact Lc.
    + intros d n Ld Hn. rewrite (SK pool k m m' Ku km Nkm) in Ld by ks.
      pose proof (Lst d n Ld Hn) as Hs. rewrite <- !Z.add_assoc in Hs |- *.
      rewrite !(SK pool k m m' Ku km Nkm) by ks. exact Hs.
  - intros j Hj. pose proof (Nn j Hj) as Nj. destruct (Cresp j (Inw j Hj)) as (t & Lt & R1 & R2). exists t.
    split; [ rewrite (SK pool k m m' Ku j Nj) by ks; exact Lt | split ].
    + intros Et. destruct (R1 Et) as (b & o & Lr & Hor). exists b, o.
      split; [ rewrite (SK pool k m m' Ku j Nj) by ks; exact Lr | ].
      destruct Hor as [Hor | (Hg & Hin)]; [ left; exact Hor | right; split; [ | exact Hin ] ].
      apply (PollKeep.gcell_K m m'); [ | exact Hg ].
      apply (KG surface_load._sSurfacePool); [ unfold PollKeep.ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity ].
    + intros Et. destruct (R2 Et) as (b & o & Lr & Hor). exists b, o.
      rewrite (SK pool k m m' Ku j Nj) by ks. exact (conj Lr Hor).
  - exact G'.
  - intros z v Hz L. assert (Hz' : In z [120; 124; 128; 132; 96; 100; 104])
      by (unfold OW.MSURF, WALL_OFF, CEIL_OFF, FLOOR_OFF in Hz; cbn [In] in Hz |- *; tauto).
    rewrite (Kbm z (or_intror Hz')) in L.
    destruct (Cmsurf z v Hz L) as [E | (b & o & E & Hs)]; [ left; exact E | right ].
    exists b, o. split; [ exact E | ]. intros P (s & Ss & Ls). apply Hs. exists s. split; [ exact Ss | ].
    rewrite <- Ls. symmetry.
    apply (KG surface_load._sSurfacePool); [ unfold PollKeep.ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact Ss ].
  - destruct Cpar as (P1 & P2). split.
    + intros j Hj. unfold OW.O_PARENT in *. rewrite Ku by ks. exact (P1 j Hj).
    + intros j id Hj Hid Hr. pose proof (Nn j Hj) as Nj.
      rewrite (runs_u ge pool k m m' Ku j Nj) in Hr. unfold OW.O_PARENT in *. rewrite Ku by ks.
      exact (P2 j id (Inw j Hj) Hid Hr).
  - intros j Hj Lg'. rewrite Km in Lg'.
    assert (Ejk : j = km).
    { rewrite Lg in Lg'. assert (E : OW.slot_v pool km = OW.slot_v pool j) by congruence.
      exact (eq_sym (OW.slot_v_inj pool km j Rkm Hj E)). }
    subst j. destruct (Cmvm km Hj Lg') as (st & Hin & Hs & V).
    exists st. exact (conj Hin (conj Hs (vm_at_u ge pool k m m' Ku km Nkm st Hin V))).
  - apply (OW.anim_ok_ext ge m m'); [ | exact Canim ].
    intros t b Ht Hs. destruct (PollKeep.anim_in_ow t Ht) as (H1 & _).
    apply (KG t H1); [ | exact Hs ].
    assert (A : forallb (fun t => negb (existsb (Pos.eqb t) unl_gids)) OW.anim_ids = true) by (vm_compute; reflexivity).
    exact (proj1 (negb_true_iff _) (proj1 (forallb_forall _ _) A t Ht)).
  - destruct Ccls as (T1 & T2). split.
    + intros j t Hj L Ht. pose proof (Nn j Hj) as Nj. rewrite (SK pool k m m' Ku j Nj) in L by ks.
      exact (sp_vm_all ge pool k m m' Ku j (T1 j t (Inw j Hj) L Ht)).
    + apply (OW.cls_surf_ext ge pool m m' m').
      * intros id b Hin Hs. apply (KG id); [ | | exact Hs ];
          unfold OW.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin;
          destruct Hin as [<- | [<- | [<- | [<- | []]]]];
          first [ solve [ unfold PollKeep.ow_ids; cbn [In]; repeat (first [ left; reflexivity | right ]) ]
                | vm_compute; reflexivity ].
      * intros P HP _ _ ch z _. exact (KN P HP ch z).
      * intros P id bp z hd l o j HP Gp Gn Hid Hs L Hw Ho N Hj Lo.
        exact (sp_vm_all ge pool k m m' Ku j (T2 P id bp z hd l o j HP Gp Gn Hid Hs L Hw Ho N Hj Lo)).
  - apply (OW.dp_ok_ext ge m m'); [ | exact Cdp ].
    intros p b Hp Hs.
    assert (A : forallb (fun t => existsb (Pos.eqb t) PollKeep.ow_ids && negb (existsb (Pos.eqb t) unl_gids)) OW.dparams = true)
      by (vm_compute; reflexivity).
    pose proof (proj1 (forallb_forall _ _) A p Hp) as E. apply andb_prop in E as [E1 E2].
    apply existsb_exists in E1 as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x.
    exact (KG p Hx (proj1 (negb_true_iff _) E2) b Hs).
  - intros j Hj. pose proof (Nn j Hj) as Nj. destruct (Cnco j (Inw j Hj)) as (n & Ln & Rn). exists n.
    rewrite (SK pool k m m' Ku j Nj) by ks. exact (conj Ln Rn).
  - intros j Hj Lg' a Ha. rewrite Km in Lg'.
    assert (Ejk : j = km).
    { rewrite Lg in Lg'. assert (E : OW.slot_v pool km = OW.slot_v pool j) by congruence.
      exact (eq_sym (OW.slot_v_inj pool km j Rkm Hj E)). }
    subst j. destruct (Cmco km Hj Lg' a Ha) as (v & Lv & Sv).
    exists v. unfold OW.O_COLLS in *. rewrite <- !Z.add_assoc in Lv |- *.
    rewrite (SK pool k m m' Ku km Nkm) by ks. exact (conj Lv Sv).
Qed.
