(* ======================================================================= *)
(* ObjVmSwap.v -- obj_w survives a change of ONE slot's behavior-VM cells *)
(* to a state of the same script family (GOAL 2 objects, W2, 2026-11-07). *)
(*                                                                         *)
(* The objects step (BhvStep.cou_real) moves the running slot k0's VM     *)
(* cells [460, 502) (curBhvCommand, bhvStackIndex, bhvStack[8],           *)
(* bhvDelayTimer): they are outside its frame Pfr.  At the step's exit    *)
(* the ghost memory g of ObjInv.INVk holds obj_w with k0 at its start     *)
(* state st0, and the real memory m' agrees with g off those cells, with  *)
(* k0 at a reachable state st' of st0's family (ObjFamily.Qfam).          *)
(*                                                                         *)
(* THE KEEPER (obj_w_vm_swap), PollKeep.obj_w_slots_c's hypotheses with   *)
(* the pool premise relaxed at k0's VM cells:                             *)
(*   - every clause reading no VM cell: the loads are equal;              *)
(*   - every clause reading slot k <> k0's VM cells: the loads are equal; *)
(*   - slot k0: the clause is re-made from st' and the class st' shares   *)
(*     with st0 -- live (ow_script), list 12 (ow_dry12), special (ow_cls, *)
(*     ow_tie), PARENT_BIT_CLEAR (ow_par), box / lid / coin formation     *)
(*     (ow_ter's runs), bhvMario (ow_mvm, ow_mact: ObjFamily.mario_frames)*)
(*     -- and vm_ok from st' itself.                                       *)
(* No premise beyond the frame; nothing quantified that the game does not *)
(* produce: st' is the slot's reached VM state, read off the real memory. *)
(* STAGED in Unwired/ with ObjInv until the objects step row uses it.    *)
(* ======================================================================= *)
From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require object_list_processor debug behavior_script.
From SM64.Proofs Require Interp.CMem.
From SM64.Generated Require mario level_update surface_load area wmotr_level_data behavior_data.
From SM64.Proofs Require Import ActionValueFrame MWFReal SpawnInit.
From SM64.Proofs.WMotRRequiresA Require Import WMotRWorld FfWorld RenderKeep BhvVM.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjFamily PollKeep.
Import ListNotations.
Local Open Scope Z_scope.

Module OW := ObjWorld.
Module PK := PollKeep.
Module CM := SM64.Proofs.Interp.CMem.
Module OF := ObjFamily.

(* the bytes [off, e) miss the VM cells [460, 502), and (2026-11-09, for
   CannonKeep: a cannon base's ADD_FLOAT(oPosY, -340)) oPosY [164, 168) *)
Definition vmc (off e : Z) : Prop :=
  (e <= OW.O_CMD \/ OW.O_STK + 34 <= off) /\ (e <= O_POSY \/ O_POSY + 4 <= off).

(* a VM state's script is the symbol whose block the command pointer is in *)
Lemma vm_at_cmd : forall (ge : genv) pool m k st b o id,
  OW.vm_at ge pool m k st -> Mem.load Mint32 m pool (k * OW.OSZ + OW.O_CMD) = Some (Vptr b o) ->
  Genv.find_symbol ge id = Some b -> id = v_s st.
Proof.
  intros ge pool m k st b o id ((b1 & Hs1 & L1) & _) L Hs. rewrite L1 in L. injection L as <- _.
  eapply Genv.genv_vars_inj; [ exact Hs | exact Hs1 ].
Qed.

Lemma vm_at_same : forall (ge : genv) pool m k st1 st2,
  OW.vm_at ge pool m k st1 -> OW.vm_at ge pool m k st2 -> v_s st1 = v_s st2.
Proof.
  intros ge pool m k st1 st2 V1 V2. pose proof V1 as ((b1 & Hs1 & L1) & _).
  exact (vm_at_cmd ge pool m k st2 _ _ _ V2 L1 Hs1).
Qed.

Lemma runs_vm_at : forall (ge : genv) pool m k st id,
  OW.vm_at ge pool m k st -> OW.runs ge pool m k id = Pos.eqb id (v_s st).
Proof.
  intros ge pool m k st id V. pose proof V as ((b1 & Hs1 & L1) & _).
  unfold OW.runs, OW.ld32. rewrite CM.load_eq, L1. unfold OW.sym_is.
  destruct (Pos.eqb_spec id (v_s st)) as [-> | Ne].
  - rewrite Hs1. apply Pos.eqb_refl.
  - destruct (Genv.find_symbol ge id) as [b' |] eqn:Hs; [ | reflexivity ].
    apply Pos.eqb_neq. intros <-. apply Ne. eapply Genv.genv_vars_inj; [ exact Hs | exact Hs1 ].
Qed.

(* membership in PollKeep's list, decided (auto over the unfolded list hung) *)
Lemma in_ow : forall id, existsb (Pos.eqb id) PK.ow_ids = true -> In id PK.ow_ids.
Proof.
  intros id A. apply existsb_exists in A as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x. exact Hx.
Qed.
Ltac iow := apply in_ow; vm_compute; reflexivity.

(* Mario's cells (outside the section: its Qfam hypothesis made tauto
   unfold the computed class lists) *)
Lemma in4_in8 : forall z : Z, In z [120; 124; 128; 132] -> In z [120; 124; 128; 132; 96; 100; 104; 12].
Proof. intros z H. cbn [In] in H |- *. tauto. Qed.

Lemma msurf_in8 : forall z : Z, In z OW.MSURF -> In z [120; 124; 128; 132; 96; 100; 104; 12].
Proof. intros z H. unfold OW.MSURF, WALL_OFF, CEIL_OFF, FLOOR_OFF in H. cbn [In] in H |- *. tauto. Qed.

(* the walk half of the class tie, its VM side moved *)
Lemma cls_surf_mv : forall (ge : genv) pool mw mv mv',
  (forall k, OW.sp_vm ge pool mv k -> OW.sp_vm ge pool mv' k) ->
  OW.cls_surf_at ge pool mw mv -> OW.cls_surf_at ge pool mw mv'.
Proof.
  intros ge pool mw mv mv' K C P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo.
  exact (K k (C P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo)).
Qed.

Section VS.
  Variables (m m' : mem) (ge : genv) (pool : block) (k0 : Z).

  (* the pool unchanged where PollKeep.SKc says, except at slot k0's VM
     cells *)
  Hypothesis Kv : forall ch k off, (96 <= off \/ (4 <= off /\ off + size_chunk ch <= 16)) ->
    off + size_chunk ch <= OW.OSZ -> (off + size_chunk ch <= 532 \/ 536 <= off) ->
    OW.ccl off (off + size_chunk ch) -> (k <> k0 \/ vmc off (off + size_chunk ch)) ->
    Mem.load ch m' pool (k * OW.OSZ + off) = Mem.load ch m pool (k * OW.OSZ + off).

  (* slot k0's VM: st0 before, st' after, one family *)
  Variables (st0 st' : vst).
  Hypothesis H0 : In st0 vm_tab.
  Hypothesis H1 : In st' vm_tab.
  Hypothesis V0 : OW.vm_at ge pool m k0 st0.
  Hypothesis V1 : OW.vm_at ge pool m' k0 st'.
  Hypothesis HQ : OF.Qfam (v_s st0) st'.

  (* slot k0's oPosY: kept (the exit), or (CannonKeep) moved with k0's
     kind re-made: not a pole, not a box, its cannon pins at m' *)
  Hypothesis Hy0 : (forall ch, Mem.load ch m' pool (k0 * OW.OSZ + O_POSY) = Mem.load ch m pool (k0 * OW.OSZ + O_POSY))
    \/ (OW.kind_ok pool m' k0 /\ OW.runs ge pool m k0 OW.POLES = false
        /\ OW.is_bhv_b ge pool m macro_special_objects._bhvExclamationBox k0 = false
        /\ (forall t, Mem.load Mint32 m pool (k0 * OW.OSZ + O_INTERACT_TYPE) = Some (Vint t) ->
              OW.runs ge pool m k0 OW.CANS = true -> Int.unsigned t <> INTERACT_CANNON_BASE ->
              cannon_xz_ok m' pool (k0 * OW.OSZ))).

  Ltac sv := unfold vmc, OW.O_BHV, OW.O_CMD, OW.O_SIDX, OW.O_STK, OW.O_ACTION, OW.O_HSCOUNT,
    OW.O_FLAGS, OW.O_NEXT, OW.O_PREV, OW.OSZ, O_INTERACT_TYPE, O_POSX, O_POSY, O_POSZ, HITBOX_DOWN_OFF,
    HITBOX_H_OFF, RAW_OFF, OW.O_RTYPE, OW.O_RINFO, OW.G_PREV, OW.G_NEXT, OW.G_PAR, OW.O_PARENT,
    OW.O_COLL, OW.ccl, FieldWin.ucl in *; cbn [size_chunk];
    first [ lia | right; lia | left; assumption ].

  Lemma ld32_v : forall k off, 96 <= off -> off + 4 <= OW.OSZ -> (off + 4 <= 532 \/ 536 <= off) ->
    OW.ccl off (off + 4) -> (k <> k0 \/ vmc off (off + 4)) ->
    OW.ld32 m' pool (k * OW.OSZ + off) = OW.ld32 m pool (k * OW.OSZ + off).
  Proof.
    intros k off A B C D E. unfold OW.ld32. rewrite !CM.load_eq.
    apply Kv; [ left; exact A | exact B | exact C | exact D | exact E ].
  Qed.

  (* ---- the list walks (header links 96, 100) ---- *)
  Lemma ring_from_v : forall hb, (forall z, OW.ld32 m' hb z = OW.ld32 m hb z) ->
    forall n ho prev cur, OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
  Proof.
    intros hb Kh n. induction n as [| n IH]; intros ho prev cur; cbn [OW.ring_from]; [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned i) ho); [ rewrite Kh; reflexivity | ].
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
    destruct (PK.slot_of_eq _ _ E) as (Eo & _). rewrite Eo.
    rewrite !ld32_v by sv.
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_PREV)); [ | reflexivity ].
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
    destruct (OW.veqb v prev); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Lemma rings_v : forall la, (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
    OW.rings m' pool la = OW.rings m pool la.
  Proof.
    intros la Kl. unfold OW.rings.
    assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
    { apply map_ext. intros i. unfold OW.ring_i. rewrite Kl.
      destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
      apply ring_from_v; assumption. }
    rewrite E. reflexivity.
  Qed.

  Lemma free_from_v : forall n cur, OW.free_from m' pool cur n = OW.free_from m pool cur n.
  Proof.
    intros n. induction n as [| n IH]; intros cur; cbn [OW.free_from]; [ reflexivity | ].
    destruct (OW.veqb cur Vnullptr); [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
    destruct (PK.slot_of_eq _ _ E) as (Eo & _). rewrite Eo.
    rewrite ld32_v by sv.
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  (* ---- the clauses that read no VM cell ---- *)
  Lemma is_bhv_v : forall k id, OW.is_bhv ge pool m k id -> OW.is_bhv ge pool m' k id.
  Proof. intros k id (b & Hs & L). exists b. rewrite Kv by sv. exact (conj Hs L). Qed.

  Lemma is_bhv_v' : forall k id, OW.is_bhv ge pool m' k id -> OW.is_bhv ge pool m k id.
  Proof. intros k id (b & Hs & L). exists b. rewrite Kv in L by sv. exact (conj Hs L). Qed.

  Lemma is_bhv_b_v : forall id k, OW.is_bhv_b ge pool m' id k = OW.is_bhv_b ge pool m id k.
  Proof. intros id k. unfold OW.is_bhv_b. rewrite ld32_v by sv. reflexivity. Qed.

  Lemma act_v : forall k, OW.act_ok ge pool m k -> OW.act_ok ge pool m' k.
  Proof.
    intros k H bh t Hin Hb. destruct (H bh t Hin (is_bhv_v' k bh Hb)) as (a & La & R).
    exists a. rewrite Kv by sv. exact (conj La R).
  Qed.

  Lemma red_v : forall k, OW.red_ok ge pool m k -> OW.red_ok ge pool m' k.
  Proof.
    intros k (N & R). split.
    - intros Hb. exact (N (is_bhv_v' k _ Hb)).
    - intros Hb. destruct (R (is_bhv_v' k _ Hb)) as (c & Lc & Rc). exists c. rewrite Kv by sv. exact (conj Lc Rc).
  Qed.

  Lemma kind_k0 : OW.kind_ok pool m k0 -> OW.kind_ok pool m' k0.
  Proof.
    intros Kk. destruct Hy0 as [E | (K & _)]; [ | exact K ].
    destruct Kk as (t & Lt & Hin & Hp & Hc & Hpx & Hcx).
    exists t.
    split; [ rewrite Kv by sv; exact Lt | split; [ exact Hin | split; [ | split; [ | split ] ] ] ].
    - intros Et. destruct (Hp Et) as (base & top & Hb & L1 & L2 & L3).
      exists base, top. rewrite (E Mfloat32). rewrite !Kv by sv. exact (conj Hb (conj L1 (conj L2 L3))).
    - intros Et. destruct (Hc Et) as (y & Hy & L). exists y. rewrite (E Mfloat32). exact (conj Hy L).
    - intros Et. destruct (Hpx Et) as (x & z & base & top & Hb & L1 & L2 & L3).
      exists x, z, base, top. rewrite (E Mfloat32). rewrite !Kv by sv. exact (conj Hb (conj L1 (conj L2 L3))).
    - intros Et. destruct (Hcx Et) as (x & z & y & Hy & L1 & L2 & L3).
      exists x, z, y. rewrite (E Mfloat32). rewrite !Kv by sv. exact (conj Hy (conj L1 (conj L2 L3))).
  Qed.

  Lemma kind_v : forall k, OW.kind_ok pool m k -> OW.kind_ok pool m' k.
  Proof.
    intros k Kk. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact (kind_k0 Kk) | ].
    destruct Kk as (t & Lt & Hin & Hp & Hc & Hpx & Hcx).
    exists t.
    split; [ rewrite Kv by sv; exact Lt | split; [ exact Hin | split; [ | split; [ | split ] ] ] ].
    - intros E. destruct (Hp E) as (base & top & Hb & L1 & L2 & L3).
      exists base, top. rewrite !Kv by sv. exact (conj Hb (conj L1 (conj L2 L3))).
    - intros E. destruct (Hc E) as (y & Hy & L). exists y. rewrite Kv by sv. exact (conj Hy L).
    - intros E. destruct (Hpx E) as (x & z & base & top & Hb & L1 & L2 & L3).
      exists x, z, base, top. rewrite !Kv by sv. exact (conj Hb (conj L1 (conj L2 L3))).
    - intros E. destruct (Hcx E) as (x & z & y & Hy & L1 & L2 & L3).
      exists x, z, y. rewrite !Kv by sv. exact (conj Hy (conj L1 (conj L2 L3))).
  Qed.

  (* ---- the VM clauses at a slot other than k0 ---- *)
  Section NE.
    Variable k : Z.
    Hypothesis Hne : k <> k0.

    Lemma vm_at_ne : forall st, In st vm_tab -> OW.vm_at ge pool m k st -> OW.vm_at ge pool m' k st.
    Proof.
      intros st Hin ((b & Hs & L1) & L2 & F).
      pose proof (PK.vm_depth st Hin) as Dp.
      split; [ exists b; rewrite Kv by sv; exact (conj Hs L1) | split ].
      - rewrite Kv by sv. exact L2.
      - intros n f Hn. pose proof (F n f Hn) as Fn.
        assert (Hlt : (n < List.length (v_k st))%nat) by (apply nth_error_Some; rewrite Hn; discriminate).
        unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
        rewrite Kv by sv. exact Fn.
    Qed.

    Lemma script_ne : OW.script_ok ge pool m k -> OW.script_ok ge pool m' k.
    Proof.
      intros (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kv by sv. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma script12_ne : OW.script12_ok ge pool m k -> OW.script12_ok ge pool m' k.
    Proof.
      intros (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kv by sv. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma runs_ne : forall id, OW.runs ge pool m' k id = OW.runs ge pool m k id.
    Proof. intros id. unfold OW.runs. rewrite ld32_v by sv. reflexivity. Qed.
  End NE.

  (* ---- slot k0: re-made from st' and its class ---- *)
  Lemma cmd_k0 : forall b o id, Mem.load Mint32 m pool (k0 * OW.OSZ + OW.O_CMD) = Some (Vptr b o) ->
    Genv.find_symbol ge id = Some b -> id = v_s st0.
  Proof. intros b o id L Hs. exact (vm_at_cmd ge pool m k0 st0 b o id V0 L Hs). Qed.

  Lemma runs_k0 : forall id, In id [OW.BOXS; OW.LIDS; OW.COINF] ->
    OW.runs ge pool m' k0 id = OW.runs ge pool m k0 id.
  Proof.
    intros id Hid. rewrite (runs_vm_at ge pool m' k0 st' id V1), (runs_vm_at ge pool m k0 st0 id V0).
    pose proof (OF.Qfam_id (v_s st0) st' id Hid HQ) as E.
    destruct (Pos.eqb_spec id (v_s st')) as [E1 | N1]; destruct (Pos.eqb_spec id (v_s st0)) as [E2 | N2];
      try reflexivity.
    - exfalso. apply N2. symmetry. apply E. symmetry. exact E1.
    - exfalso. apply N1. symmetry. apply E. symmetry. exact E2.
  Qed.

  (* 2026-11-09: the pole / cannon-base identity is a class bit too *)
  Lemma runs_k0' : forall id, In id [OW.POLES; OW.CANS] ->
    OW.runs ge pool m' k0 id = OW.runs ge pool m k0 id.
  Proof.
    intros id Hid. rewrite (runs_vm_at ge pool m' k0 st' id V1), (runs_vm_at ge pool m k0 st0 id V0).
    pose proof (OF.Qfam_id2 (v_s st0) st' id Hid HQ) as E.
    destruct (Pos.eqb_spec id (v_s st')) as [E1 | N1]; destruct (Pos.eqb_spec id (v_s st0)) as [E2 | N2];
      try reflexivity.
    - exfalso. apply N2. symmetry. apply E. symmetry. exact E1.
    - exfalso. apply N1. symmetry. apply E. symmetry. exact E2.
  Qed.

  (* 2026-11-09: the cannon pin D at k0 -- a cannon that is reached past
     its home-to-lid prologue (index >= 7) is pinned by its offset *)
  Lemma can_k0 : (v_s st' = OW.CANS -> (7 <= v_i st' /\ v_i st' < 1000)%nat) ->
    OW.can_pin ge pool m' k0.
  Proof.
    intros HC b o Hb L. unfold OW.ld32 in L. rewrite CM.load_eq in L.
    pose proof (vm_at_cmd ge pool m' k0 st' b o OW.CANS V1 L Hb) as E.
    destruct (HC (eq_sym E)) as (Lo & Hi). right.
    pose proof V1 as ((b1 & _ & L1) & _). rewrite L1 in L. injection L as _ <-.
    rewrite Ptrofs.unsigned_repr; [ assert (A28 : 28 <= 4 * Z.of_nat (v_i st')) by lia; exact A28 | change Ptrofs.max_unsigned with 4294967295;
      assert (A32 : 0 <= 4 * Z.of_nat (v_i st') <= 4294967295) by lia; exact A32 ].
  Qed.

  Lemma sp_k0 : OW.sp_vm ge pool m k0 -> OW.sp_vm ge pool m' k0.
  Proof.
    intros (st & Hin & Hsp & V). exists st'. split; [ exact H1 | split; [ | exact V1 ] ].
    rewrite (vm_at_same ge pool m k0 st st0 V V0) in Hsp.
    exact (proj2 (OF.Qfam_sp (v_s st0) st' HQ) Hsp).
  Qed.

  Lemma script_k0 : OW.script_ok ge pool m' k0.
  Proof.
    pose proof V1 as ((b & Hs & L) & _).
    exists (v_s st'), b, (Ptrofs.repr (4 * Z.of_nat (v_i st'))).
    exact (conj (OF.Qfam_live _ _ HQ) (conj Hs L)).
  Qed.

  Lemma script12_k0 : OW.script12_ok ge pool m k0 -> OW.script12_ok ge pool m' k0.
  Proof.
    intros (id & b & o & Hin & Hs & L). rewrite (cmd_k0 b o id L Hs) in Hin.
    pose proof V1 as ((b' & Hs' & L') & _).
    exists (v_s st'), b', (Ptrofs.repr (4 * Z.of_nat (v_i st'))).
    exact (conj (proj2 (OF.Qfam_live12 (v_s st0) st' HQ) Hin) (conj Hs' L')).
  Qed.

  Lemma vm_k0 : OW.vm_ok ge pool m' k0.
  Proof. apply (proj2 (OW.vm_ok_at ge pool m' k0)). exists st'. exact (conj H1 V1). Qed.

  (* Mario's slot: st' runs bhvMario, its frames are counts or bhvMario
     addresses *)
  Lemma mario_k0 : forall b, v_s st0 = OF.MARIO -> Genv.find_symbol ge behavior_data._bhvMario = Some b ->
    (exists o, Mem.load Mint32 m' pool (k0 * OW.OSZ + OW.O_CMD) = Some (Vptr b o))
    /\ (forall d n, Mem.load Mint32 m' pool (k0 * OW.OSZ + OW.O_SIDX) = Some (Vint d) ->
          0 <= n < Z.min (Int.unsigned d) 8 ->
          (exists o, Mem.load Mint32 m' pool (k0 * OW.OSZ + OW.O_STK + 4 * n) = Some (Vptr b o))
          \/ (exists c, Mem.load Mint32 m' pool (k0 * OW.OSZ + OW.O_STK + 4 * n) = Some (Vint c))).
  Proof.
    intros b E0 Sb. pose proof (OF.Qfam_mario _ _ HQ E0) as E1.
    pose proof V1 as ((b1 & Hs1 & L1) & L2 & F).
    rewrite E1 in Hs1. unfold OF.MARIO in Hs1. rewrite Sb in Hs1. injection Hs1 as <-.
    split; [ eexists; exact L1 | ].
    intros d n Ld Hn. rewrite L2 in Ld. injection Ld as <-.
    pose proof (PK.vm_depth st' H1) as Dp.
    set (len := List.length (v_k st')) in *.
    rewrite Int.unsigned_repr in Hn by (unfold Int.max_unsigned; cbn; lia).
    set (n' := Z.to_nat (Z.of_nat len - 1 - n)).
    assert (Hlt : (n' < len)%nat) by (unfold n'; lia).
    destruct (nth_error (v_k st') n') as [f |] eqn:Hf;
      [ | apply nth_error_None in Hf; unfold len in Hlt; lia ].
    pose proof (F n' f Hf) as Fn. unfold OW.stk_cell in Fn. fold len in Fn.
    replace (k0 * OW.OSZ + OW.O_STK + 4 * (Z.of_nat len - 1 - Z.of_nat n'))
      with (k0 * OW.OSZ + OW.O_STK + 4 * n) in Fn by (unfold n'; lia).
    destruct (OF.mario_frames st' f H1 E1 (nth_error_In _ _ Hf)) as [-> | (i & ->)].
    - right. exact Fn.
    - left. destruct Fn as (b2 & Hs2 & L). unfold OF.MARIO in Hs2. rewrite Sb in Hs2. injection Hs2 as <-.
      eexists. exact L.
  Qed.

  (* ---- the combined slot facts, every slot ---- *)
  Lemma sp_all : forall k, OW.sp_vm ge pool m k -> OW.sp_vm ge pool m' k.
  Proof.
    intros k Hs. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact (sp_k0 Hs) | ].
    destruct Hs as (st & Hin & Hsp & V). exists st. exact (conj Hin (conj Hsp (vm_at_ne k Ne st Hin V))).
  Qed.

  Lemma runs_all : forall k id, In id [OW.BOXS; OW.LIDS; OW.COINF] ->
    OW.runs ge pool m' k id = OW.runs ge pool m k id.
  Proof.
    intros k id Hid. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact (runs_k0 id Hid) | exact (runs_ne k Ne id) ].
  Qed.

  Lemma runs_b : forall k, OW.runs ge pool m' k OW.BOXS = OW.runs ge pool m k OW.BOXS.
  Proof. intros k. exact (runs_all k OW.BOXS (or_introl eq_refl)). Qed.
  Lemma runs_l : forall k, OW.runs ge pool m' k OW.LIDS = OW.runs ge pool m k OW.LIDS.
  Proof. intros k. exact (runs_all k OW.LIDS (or_intror (or_introl eq_refl))). Qed.
  Lemma runs_c : forall k, OW.runs ge pool m' k OW.COINF = OW.runs ge pool m k OW.COINF.
  Proof. intros k. exact (runs_all k OW.COINF (or_intror (or_intror (or_introl eq_refl)))). Qed.

  Lemma sdyn_all : forall k, OW.sdyn ge pool m' k = OW.sdyn ge pool m k.
  Proof.
    intros k. unfold OW.sdyn. rewrite runs_b, runs_l. reflexivity.
  Qed.

  Lemma coll_pin_all : forall k, OW.coll_pin ge pool m k -> OW.coll_pin ge pool m' k.
  Proof.
    intros k (C1 & C2). unfold OW.coll_pin. rewrite runs_b, runs_l.
    rewrite (Kv Mint32 k OW.O_COLL) by sv. exact (conj C1 C2).
  Qed.

  Lemma script_all : forall k, OW.script_ok ge pool m k -> OW.script_ok ge pool m' k.
  Proof.
    intros k Hs. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact script_k0 | exact (script_ne k Ne Hs) ].
  Qed.

  Lemma script12_all : forall k, OW.script12_ok ge pool m k -> OW.script12_ok ge pool m' k.
  Proof.
    intros k Hs. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact (script12_k0 Hs) | exact (script12_ne k Ne Hs) ].
  Qed.

  Lemma vm_all : forall k, OW.vm_ok ge pool m k -> OW.vm_ok ge pool m' k.
  Proof.
    intros k Hv. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact vm_k0 | ].
    destruct (proj1 (OW.vm_ok_at ge pool m k) Hv) as (st & Hin & V).
    apply (proj2 (OW.vm_ok_at ge pool m' k)). exists st. exact (conj Hin (vm_at_ne k Ne st Hin V)).
  Qed.

  (* ---- THE KEEPER ---- *)
  Hypothesis Hpool : Genv.find_symbol ge object_list_processor._gObjectPool = Some pool.

  Theorem obj_w_vm_swap : forall bm,
    (v_s st' = OW.CANS -> (7 <= v_i st' /\ v_i st' < 1000)%nat) ->
    (forall id b, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    PK.surf_keep m m' ge ->
    (OW.ctr_s_ok ge m -> OW.ctr_s_ok ge m') ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104; 12] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (forall s b, In s (map v_s vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall rs, OW.ncoll_ok pool m rs -> OW.ncoll_ok pool m' rs) ->
    (forall gmo, Genv.find_symbol ge object_list_processor._gMarioObject = Some gmo ->
       OW.mcoll_ok pool gmo m -> OW.mcoll_ok pool gmo m') ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros bm HCn K KS KC Kbm KSc KNC KMC
      (pool' & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    rewrite Hpool in S1. injection S1 as <-.
    assert (Kl := K object_list_processor._gObjectListArray la ltac:(iow) ltac:(vm_compute; reflexivity) S2).
    assert (Kf := K object_list_processor._gFreeObjectList fl ltac:(iow) ltac:(vm_compute; reflexivity) S3).
    assert (Kg := K object_list_processor._gObjectLists gol ltac:(iow) ltac:(vm_compute; reflexivity) S4).
    assert (Km := K object_list_processor._gMarioObject gmo ltac:(iow) ltac:(vm_compute; reflexivity) S5).
    assert (Ks := K debug._sDebugPage sdp ltac:(iow) ltac:(vm_compute; reflexivity) S6).
    assert (Kd := K debug._gDebugInfo gdi ltac:(iow) ltac:(vm_compute; reflexivity) S7).
    exists pool, la, fl, gol, gmo, sdp, gdi, rs, fs.
    refine (conj Hpool (conj S2 (conj S3 (conj S4 (conj S5 (conj S6 (conj S7 _))))))).
    destruct C as [Cg Cr Cf Cp Cfo Cm Cs Ca Crd Cdb Cst Co Cd12 Cct Cvm Csp Cso Cco Cctr Cter Cscr Cmact Cresp Cgfx Cmsurf Cpar
                   Cmvm Canim Ccls Cdp Cnco Cmco Ctie Cpin].
    assert (KG : forall id, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false ->
               forall b, Genv.find_symbol ge id = Some b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z)
      by (intros id Hin Hn b Hs; exact (K id b Hin Hn Hs)).
    constructor.
    - rewrite Kg. exact Cg.
    - rewrite (rings_v la (PK.ld32_eq m m' la Kl)). exact Cr.
    - unfold OW.free_list in *. rewrite (PK.ld32_eq m m' fl Kf).
      destruct (OW.ld32 m fl OW.O_NEXT); [ | discriminate Cf ].
      rewrite free_from_v. exact Cf.
    - exact Cp.
    - intros k Hk. rewrite Kv by sv. exact (Cfo k Hk).
    - destruct Cm as (k & Hk & Lg & Lb & Kd').
      exists k. split; [ exact Hk | split; [ rewrite Km; exact Lg | split ] ].
      + rewrite (Kbm _ (or_introl eq_refl)). exact Lb.
      + intros j Hj Ne. exact (kind_v j (Kd' j Hj Ne)).
    - intros k Hk. exact (script_all k (Cs k Hk)).
    - intros k Hk. exact (act_v k (Ca k Hk)).
    - intros k Hk. exact (red_v k (Crd k Hk)).
    - destruct Cdb as (Cd1 & Cd2). split; [ rewrite Ks; exact Cd1 | ].
      apply (OW.dflags_ok_ext ge m m'); [ | exact Cd2 ]. intros b Sb.
      exact (K debug._gDebugInfoFlags b PK.dflags_in_ow ltac:(vm_compute; reflexivity) Sb _ _).
    - intros z Hz. assert (Hz' := in4_in8 z Hz).
      rewrite (Kbm z (or_intror Hz')). exact (Cst z Hz).
    - destruct Co as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j Hj. rewrite (K object_list_processor._sObjectListUpdateOrder b ltac:(iow) ltac:(vm_compute; reflexivity) Sb). exact (L j Hj).
    - intros k Hk. exact (script12_all k (Cd12 k Hk)).
    - destruct Cct as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j id Hj. rewrite (K behavior_script._BehaviorCmdTable b ltac:(iow) ltac:(vm_compute; reflexivity) Sb). exact (L j id Hj).
    - intros k Hk. exact (vm_all k (Cvm k Hk)).
    - destruct Csp as (P & HP & G1 & G2 & G3 & G4 & G5). exists P. split; [ exact HP | ].
      assert (Kc : forall id, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false ->
                 forall ch v, OW.gcell ge id ch v m -> OW.gcell ge id ch v m')
        by (intros id Hin Hn ch v; apply (PK.gcell_K m m'); exact (KG id Hin Hn)).
      split; [ | split; [ | split; [ | split ] ] ];
        (apply Kc; [ iow | vm_compute; reflexivity | assumption ]).
    - exact (proj1 (KS pool Hpool) Cso).
    - destruct Cco as (C1 & C2 & C3).
      assert (Ef : forall id, filter (OW.is_bhv_b ge pool m' id) (concat rs) = filter (OW.is_bhv_b ge pool m id) (concat rs))
        by (intros id; apply filter_ext; intros k; exact (is_bhv_b_v id k)).
      split; [ rewrite Ef; exact C1 | split; [ rewrite Ef; exact C2 | ] ].
      intros k Hk Hb. rewrite (is_bhv_b_v _ k) in Hb.
      destruct (C3 k Hk Hb) as (x & y & z & Hin & L1 & L2 & L3).
      unfold OW.box_pos_ok. exists x, y, z.
      destruct (Z.eq_dec k k0) as [-> | Ne].
      + destruct Hy0 as [E | (_ & _ & Nb & _)]; [ | rewrite Nb in Hb; discriminate Hb ].
        rewrite (E Mfloat32). rewrite !Kv by sv. exact (conj Hin (conj L1 (conj L2 L3))).
      + rewrite !Kv by sv. exact (conj Hin (conj L1 (conj L2 L3))).
    - exact (KC Cctr).
    - destruct Cter as (T1 & T2 & T3 & T4 & T5 & T6).
      assert (Kme : forall id l, In id PK.ow_ids -> existsb (Pos.eqb id) PK.ow_xc = false ->
                 OW.mesh_ok ge id l m -> OW.mesh_ok ge id l m').
      { intros id l Hin Hn (b & Hs & L). exists b. split; [ exact Hs | ].
        intros j x Hj. rewrite (KG id Hin Hn b Hs). exact (L j x Hj). }
      split; [ | split; [ | split; [ | split; [ | split ] ] ] ].
      + intros i k Hk. rewrite sdyn_all. exact (T1 i k Hk).
      + intros i k Hi Hk.
        rewrite runs_b, runs_l, runs_c.
        exact (T2 i k Hi Hk).
      + rewrite (map_ext _ _ sdyn_all). exact T3.
      + intros k Hk. exact (coll_pin_all k (T4 k Hk)).
      + apply Kme; [ iow | vm_compute; reflexivity | exact T5 ].
      + apply Kme; [ iow | vm_compute; reflexivity | exact T6 ].
    - exact (OW.scr_ok_ext ge m m' KSc Cscr).
    - (* Mario's flags, command and stack *)
      intros k Hk Lg. rewrite Km in Lg.
      destruct (Cmact k Hk Lg) as ((f & Lf & Ef) & (b & Sb & (o & Lc) & Lst)).
      split; [ exists f; rewrite Kv by sv; exact (conj Lf Ef) | exists b; split; [ exact Sb | ] ].
      destruct (Z.eq_dec k k0) as [-> | Ne].
      + exact (mario_k0 b (eq_sym (cmd_k0 b o _ Lc Sb)) Sb).
      + split; [ exists o; rewrite Kv by sv; exact Lc | ].
        intros d n Ld Hn. rewrite Kv in Ld by sv.
        pose proof (Lst d n Ld Hn) as Hs. rewrite <- !Z.add_assoc in Hs |- *.
        rewrite !Kv by sv. exact Hs.
    - (* respawn targets *)
      intros j Hj. destruct (Cresp j Hj) as (t & Lt & R1 & R2). exists t.
      split; [ rewrite Kv by sv; exact Lt | split ].
      + intros Et. destruct (R1 Et) as (b & o & Lr & Hor). exists b, o.
        split; [ rewrite Kv by sv; exact Lr | ].
        destruct Hor as [Hor | (Hg & Hin)]; [ left; exact Hor | right; split; [ | exact Hin ] ].
        apply (PK.gcell_K m m'); [ | exact Hg ].
        apply (KG surface_load._sSurfacePool); [ iow | vm_compute; reflexivity ].
      + intros Et. destruct (R2 Et) as (b & o & Lr & Hor). exists b, o.
        rewrite Kv by sv. exact (conj Lr Hor).
    - (* the graph links *)
      intros bpg Hbpg. destruct (Cgfx bpg Hbpg) as (G1 & G2).
      assert (Kb := KG area._gObjParentGraphNode ltac:(iow) ltac:(vm_compute; reflexivity) bpg Hbpg).
      split.
      + intros k Hk. destruct (G1 k Hk) as (P1 & P2 & P3).
        unfold OW.G_PAR, OW.G_PREV, OW.G_NEXT in *. rewrite !Kv by sv. exact (conj P1 (conj P2 P3)).
      + rewrite !Kb. exact G2.
    - (* Mario's three surface cells *)
      intros z v Hz L. assert (Hz' : In z [120; 124; 128; 132; 96; 100; 104; 12])
        by exact (msurf_in8 z Hz).
      rewrite (Kbm z (or_intror Hz')) in L.
      destruct (Cmsurf z v Hz L) as [E | (b & o & E & Hs)]; [ left; exact E | right ].
      exists b, o. split; [ exact E | ]. intros P (s & Ss & Ls). apply Hs. exists s. split; [ exact Ss | ].
      rewrite <- Ls. symmetry.
      apply (KG surface_load._sSurfacePool); [ iow | vm_compute; reflexivity | exact Ss ].
    - (* the parents: slot word 104; a PARENT_BIT_CLEAR slot at k0 by its class *)
      destruct Cpar as (P1 & P2). split.
      + intros k Hk. rewrite Kv by sv. exact (P1 k Hk).
      + intros k id Hk Hid Hr. rewrite Kv by sv.
        destruct (Z.eq_dec k k0) as [-> | Ne].
        * rewrite (runs_vm_at ge pool m' k0 st' id V1) in Hr. apply Pos.eqb_eq in Hr. subst id.
          apply (P2 k0 (v_s st0) Hk (proj1 (OF.Qfam_pbc (v_s st0) st' HQ) Hid)).
          rewrite (runs_vm_at ge pool m k0 st0 _ V0). apply Pos.eqb_refl.
        * rewrite (runs_ne k Ne id) in Hr. exact (P2 k id Hk Hid Hr).
    - (* Mario's VM *)
      intros k Hk Lg. rewrite Km in Lg. destruct (Cmvm k Hk Lg) as (st & Hin & Hs & V).
      destruct (Z.eq_dec k k0) as [-> | Ne].
      + exists st'. split; [ exact H1 | split; [ | exact V1 ] ].
        apply (OF.Qfam_mario (v_s st0) st' HQ).
        rewrite <- (vm_at_same ge pool m k0 st st0 V V0). exact Hs.
      + exists st. exact (conj Hin (conj Hs (vm_at_ne k Ne st Hin V))).
    - apply (OW.anim_ok_ext ge m m'); [ | exact Canim ].
      intros t b Ht Hs. destruct (PK.anim_in_ow t Ht) as (A1 & A2). exact (KG t A1 A2 b Hs).
    - (* the class tie *)
      destruct Ccls as (T1 & T2). split.
      + intros k t Hk L Ht. rewrite Kv in L by sv. exact (sp_all k (T1 k t Hk L Ht)).
      + apply (cls_surf_mv ge pool m' m m' sp_all). exact (proj2 (KS pool Hpool) m T2).
    - apply (OW.dp_ok_ext ge m m'); [ | exact Cdp ].
      intros p b Hp Hs.
      assert (A : forallb (fun t => existsb (Pos.eqb t) PK.ow_ids && negb (existsb (Pos.eqb t) PK.ow_xc)) OW.dparams = true)
        by (vm_compute; reflexivity).
      pose proof (proj1 (forallb_forall _ _) A p Hp) as E. apply andb_prop in E as [E1 E2].
      apply existsb_exists in E1 as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x.
      exact (KG p Hx (proj1 (negb_true_iff _) E2) b Hs).
    - exact (KNC rs Cnco).
    - exact (KMC gmo S5 Cmco).
    - (* TIE *)
      destruct Ctie as (T1 & T3). split.
      + intros k bh Hk Hb Hi. exact (sp_all k (T1 k bh Hk Hb (is_bhv_v' k bh Hi))).
      + intros a La Ha. rewrite (Kbm 12 ltac:(right; cbn [In]; repeat (first [ left; reflexivity | right ]))) in La.
        destruct (T3 a La Ha) as (k & Rk & Lu & Sk). exists k. split; [ exact Rk | split ].
        * erewrite Kbm; [ exact Lu | right; cbn [In]; repeat (first [ left; reflexivity | right ]) ].
        * exact (sp_all k Sk).
    - (* PINS (2026-11-09): slot fields off the VM cells; the pole /
         cannon-base identity of k0 by its class *)
      intros k Hk.
      assert (R : forall id, In id [OW.POLES; OW.CANS] -> OW.runs ge pool m' k id = OW.runs ge pool m k id).
      { intros id Hid. destruct (Z.eq_dec k k0) as [-> | Ne]; [ exact (runs_k0' id Hid) | exact (runs_ne k Ne id) ]. }
      destruct (Z.eq_dec k k0) as [-> | Ne].
      + (* k0 *)
        destruct Hy0 as [E | (_ & Np & _ & Hx)].
        * apply (OW.pin_at_eq ge pool m m' k0 R); [ | | exact (Cpin k0 Hk) ].
          -- intros ch off Hoff Hch.
             assert (Hs : size_chunk ch = 4) by (destruct Hch as [-> | ->]; reflexivity).
             unfold OW.pin_offs, OW.O_BPARAMS in Hoff. cbn [In] in Hoff.
             destruct Hoff as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]];
               [ apply Kv; rewrite Hs; sv | apply Kv; rewrite Hs; sv | | apply Kv; rewrite Hs; sv
               | apply Kv; rewrite Hs; sv | apply Kv; rewrite Hs; sv ].
             exact (E ch).
          -- intros _. exact (can_k0 HCn).
        * destruct (Cpin k0 Hk) as (T0 & _ & _).
          split; [ | split; [ | exact (can_k0 HCn) ] ].
          -- intros t Lt. rewrite Kv in Lt by sv. destruct (T0 t Lt) as (T1 & T2 & _).
             rewrite (R OW.POLES ltac:(left; reflexivity)), (R OW.CANS ltac:(right; left; reflexivity)). split; [ exact T1 | split; [ exact T2 | ] ].
             intros Hc Ht. exact (Hx t Lt Hc Ht).
          -- rewrite (R OW.POLES ltac:(left; reflexivity)), Np. intros F; discriminate F.
      + apply (OW.pin_at_eq ge pool m m' k R); [ | | exact (Cpin k Hk) ].
        * intros ch off Hoff Hch.
          assert (Hs : size_chunk ch = 4) by (destruct Hch as [-> | ->]; reflexivity).
          unfold OW.pin_offs, OW.O_BPARAMS in Hoff. cbn [In] in Hoff.
          apply Kv; rewrite Hs; destruct Hoff as [<- | [<- | [<- | [<- | [<- | [<- | []]]]]]]; sv.
        * apply OW.can_pin_eq; [ | apply Kv; sv ].
          unfold OW.ld32. rewrite !CM.load_eq. apply Kv; sv.
  Qed.
End VS.
