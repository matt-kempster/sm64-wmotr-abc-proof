(* ====================================================================== *)
(* UnloadRows (GOAL 2 objects, 2026-11-03): unload_deactivated_objects    *)
(* over the object phase's invariant (ClearKeep.Pc), from the real loops   *)
(* (UnloadKeep.unload_outer, UnloadLoop.inlist_ok).                        *)
(*                                                                        *)
(* PROVED here: the outer loop's own store (gTimeStopState &= ~1, an int  *)
(* into a global no clause reads), the in-list loop's gCurrentObject = obj *)
(* (a slot pointer into a global no clause reads; the pool is SafeB), the  *)
(* respawn OR into gPlayerSpawnInfos+16 or a WMotR macro entry (int stores *)
(* into globals no clause reads), and that each per-slot call leaves the  *)
(* rings as the loop needs them (UnloadSharp.unload_sharp_real: slot k     *)
(* leaves ring i).                                                         *)
(* The two rows the loops rest on, stated here over Pc, are PROVED        *)
(* (2026-11-06; HeightFrame instantiates them):                            *)
(*   si_row   the respawn OR into a SpawnInfo behaviorArg cell of the main *)
(*            pool block P (ObjWorld.SI_OFFS) keeps Pc:                    *)
(*            UnloadSi.si_row_proved (P's other readers are the surface    *)
(*            and node pools from NP_OFF = 2672, Mario's surfaces, the     *)
(*            Camera, kept off the SI cells by FfWorld.cam_si).            *)
(*   unl_row  the real unload_object on an inactive slot of a walked ring  *)
(*            keeps Pc: UnloadPc.unl_row_proved (UnloadSharp's footprint;  *)
(*            Mario's slot is active, ow_mact, so it is never the one      *)
(*            freed).                                                      *)
(* ====================================================================== *)

From Coq Require Import ZArith Lia List Bool.
From compcert Require Import Coqlib Integers Floats Values AST Ctypes Cop Clight
  ClightBigstep Clightdefs Memory Maps Globalenvs Events Errors Linking.
From SM64.Generated Require surface_load surface_collision object_list_processor level_update mario
  platform_displacement area spawn_object wmotr_level_data.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve CensusV2 MWFReal
  SpawnInit ActionValueFrame NoAImpliesNoFlyLinked AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve ObjExtBodies.
From SM64.Proofs Require Import HeightInvariant WMotRWorld FrameSplit.
From SM64.Proofs.WMotRRequiresA Require Import FfWorld RenderKeep.
From SM64.Proofs.WMotRRequiresA Require ObjWorld ObjRing PollKeep PlatformKeep ObjPhase ObjLoop BhvVM
  ClearKeep MplatKeep UnloadObj UnloadLoop UnloadKeep UnloadSharp AudioInv ObjCreate.
Import ListNotations.
Local Open Scope Z_scope.
Local Transparent Archi.ptr64.

Module OW := ObjWorld.
Module OLP := object_list_processor.
Module SO := spawn_object.

Lemma dm_bpg : exists gd, (prog_defmap SO.prog) ! SO._gObjParentGraphNode = Some gd.
Proof.
  destruct ((prog_defmap SO.prog) ! SO._gObjParentGraphNode) as [gd|] eqn:E;
    [ exists gd; reflexivity | vm_compute in E; discriminate E ].
Qed.

Lemma in_nth_concat : forall (rs : list (list Z)) i k, (i < List.length rs)%nat -> In k (nth i rs []) -> In k (concat rs).
Proof.
  intros rs i k Hi Hk. apply in_concat. exists (nth i rs []). split; [ apply nth_In; exact Hi | exact Hk ].
Qed.

Section UR.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Notation G := (lp_ge lp).
  Variable bm : block.
  Hypothesis Hbm_sym : Genv.find_symbol G level_update._gMarioStates = Some bm.
  Variables (bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis Hbc_sym : Genv.find_symbol G mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).
  Notation Pc := (ClearKeep.Pc lp bm bc oc0 SafeB).

  (* the object pool is SafeB: gMarioStates->marioObj is a slot pointer *)
  Lemma pool_safe : forall m pool, mem_ok_lp bm MWF m -> OW.obj_w G bm m ->
    Genv.find_symbol G OLP._gObjectPool = Some pool -> SafeB pool.
  Proof.
    intros m pool (_ & _ & HM) How Hp.
    pose proof How as (pool' & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & _ & _ & _ & _ & _ & _ & C).
    rewrite Hp in S1. injection S1 as <-.
    destruct (OW.ow_mario _ _ _ _ _ _ _ _ _ _ _ _ C) as (k & _ & _ & Lb & _).
    refine (mwf_real_chase_root lp bm bc oc0 SafeB _ 136 m pool (Ptrofs.repr (k * OW.OSZ))
              MplatKeep.mo_root MplatKeep.mo_off HM _).
    cbn [Mem.loadv]. rewrite Ptrofs.add_zero_l, Ptrofs.unsigned_repr by (change Ptrofs.max_unsigned with 4294967295; lia).
    exact Lb.
  Qed.

  (* an int store into a global no clause reads *)
  Lemma int_gstore : forall id bg ch z i m m2,
    Genv.find_symbol G id = Some bg -> ClearKeep.gs_ok id = true ->
    existsb (Pos.eqb id) PollKeep.ow_ids = false ->
    existsb (Pos.eqb id) (map BhvVM.v_s BhvVM.vm_tab) = false ->
    Mem.store ch m bg z (Vint i) = Some m2 -> Pc m -> Pc m2.
  Proof. exact (ClearKeep.gstore_keep lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0). Qed.

  (* gCurrentObject = <a slot>: a pointer into the (SafeB) pool *)
  Lemma gco_keep : forall gco pool k m m2,
    Genv.find_symbol G OLP._gCurrentObject = Some gco ->
    Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Mem.store Mint32 m gco 0 (OW.slot_v pool k) = Some m2 -> Pc m -> Pc m2.
  Proof.
    intros gco pool k m m2 Hg Hp St (Ok & Hphi & HD & Hst & How).
    assert (SBp : SafeB pool) by exact (pool_safe m pool Ok How Hp).
    assert (Hv : forall b o, OW.slot_v pool k = Vptr b o ->
                   (exists idv, Genv.find_symbol G idv = Some b) /\ (SafeB gco -> SafeB b)).
    { intros b o E. unfold OW.slot_v in E. injection E as <- _.
      split; [ exists OLP._gObjectPool; exact Hp | intros _; exact SBp ]. }
    destruct (ClearKeep.gstore_core_p lp H12 bm Hbm_sym bc oc0 SafeB Hbc_sym Hoc0 OLP._gCurrentObject gco Mint32 0 _ m m2
                Hg ltac:(vm_compute; reflexivity) Hv St Ok Hphi HD Hst) as (Ok2 & Hphi2 & HD2 & Hst2 & LO).
    assert (NI : forall id' b, Genv.find_symbol G id' = Some b -> Pos.eqb id' OLP._gCurrentObject = false -> b <> gco)
      by (intros id' b Hs' Hn; exact (ClearKeep.symne_b G _ _ id' b Hg Hs' Hn)).
    refine (conj Ok2 (conj Hphi2 (conj HD2 (conj Hst2 _)))).
    apply (PollKeep.obj_w_unch m m2 G bm); [ | | | | exact How ].
    - intros id' b Hin Hs' ch' z'. apply LO. apply (NI id' b Hs').
      exact (ClearKeep.eqb_of_notin OLP._gCurrentObject PollKeep.ow_ids id' ltac:(vm_compute; reflexivity) Hin).
    - intros b Hb ch' z'. apply LO. exact (ClearKeep.glob_ne_dyn G _ _ b Hg Hb).
    - intros z' _. apply LO. apply (NI _ _ Hbm_sym). vm_compute. reflexivity.
    - intros s b Hin Hs' ch' z'. apply LO. apply (NI s b Hs').
      exact (ClearKeep.eqb_of_notin OLP._gCurrentObject (map BhvVM.v_s BhvVM.vm_tab) s ltac:(vm_compute; reflexivity) Hin).
  Qed.

  (* THE ROWS (OPEN) *)
  Definition si_row : Prop := forall m bP o i m2,
    Pc m -> OW.gcell G surface_load._sSurfacePool Mint32 (Vptr bP (Ptrofs.repr OW.SP_OFF)) m ->
    In (Ptrofs.unsigned o) OW.SI_OFFS ->
    Mem.store Mint32 m bP (Ptrofs.unsigned o) (Vint i) = Some m2 -> Pc m2.
  Definition unl_row : Prop := forall pool la m rs i l1 k l2 t m' vr,
    Genv.find_symbol G OLP._gObjectPool = Some pool ->
    Genv.find_symbol G OLP._gObjectListArray = Some la ->
    Pc m -> OW.rings m pool la = Some rs -> (i < OW.NLIST)%nat -> nth i rs [] = l1 ++ k :: l2 ->
    UnloadLoop.inactive pool m k ->
    eval_funcall function_entry2 G m (Internal SO.f_unload_object) [OW.slot_v pool k] t m' vr -> Pc m'.

  Hypothesis Hsi : si_row.
  Hypothesis Hunl : unl_row.

  (* the loop's world: Pc and the rings it walks *)
  Section LIST.
    Variables (pool la gco : block).
    Hypothesis Hp : Genv.find_symbol G OLP._gObjectPool = Some pool.
    Hypothesis Hl : Genv.find_symbol G OLP._gObjectListArray = Some la.
    Hypothesis Hg : Genv.find_symbol G OLP._gCurrentObject = Some gco.
    Variable i : nat.
    Hypothesis Hi : (i < OW.NLIST)%nat.

    Definition WU (m : mem) (rs : list (list Z)) : Prop := Pc m /\ OW.rings m pool la = Some rs.

    Lemma Hpl : pool <> la.
    Proof. exact (ClearKeep.symne_b G _ _ _ _ Hl Hp ltac:(vm_compute; reflexivity)). Qed.
    Lemma Hpg : pool <> gco.
    Proof. exact (ClearKeep.symne_b G _ _ _ _ Hg Hp ltac:(vm_compute; reflexivity)). Qed.
    Lemma Hlg : la <> gco.
    Proof. exact (ClearKeep.symne_b G _ _ _ _ Hg Hl ltac:(vm_compute; reflexivity)). Qed.

    (* a change off pool and la keeps the rings; off pool, the flags *)
    Lemma rings_off : forall m m2 bt, (forall ch b z, b <> bt -> Mem.load ch m2 b z = Mem.load ch m b z) ->
      bt <> pool -> bt <> la -> OW.rings m2 pool la = OW.rings m pool la.
    Proof.
      intros m m2 bt LO Np Nl. apply (PollKeep.rings_eq m m2 pool la).
      - apply PollKeep.SKp_c, PollKeep.SKp_full. intros ch z. apply LO. exact (not_eq_sym Np).
      - intros z. unfold OW.ld32. rewrite !OW.CM.load_eq. apply LO. exact (not_eq_sym Nl).
    Qed.
    Lemma inactive_off : forall m m2 bt k, (forall ch b z, b <> bt -> Mem.load ch m2 b z = Mem.load ch m b z) ->
      bt <> pool -> UnloadLoop.inactive pool m k -> UnloadLoop.inactive pool m2 k.
    Proof.
      intros m m2 bt k LO Np (a & La & Ea). exists a. rewrite LO by exact (not_eq_sym Np). exact (conj La Ea).
    Qed.

    Lemma Wr : forall m rs, WU m rs -> OW.rings m pool la = Some rs.
    Proof. intros m rs (_ & R). exact R. Qed.

    Lemma Wg : forall m rs k m', WU m rs -> In k (nth i rs []) ->
      Mem.store Mint32 m gco 0 (OW.slot_v pool k) = Some m' -> WU m' rs.
    Proof.
      intros m rs k m' (HP & R) _ St. split; [ exact (gco_keep gco pool k m m' Hg Hp St HP) | ].
      assert (LO : forall ch b z, b <> gco -> Mem.load ch m' b z = Mem.load ch m b z)
        by (intros ch b z N; apply (Mem.load_store_other _ _ _ _ _ _ St); left; exact N).
      rewrite (rings_off m m' gco LO (not_eq_sym Hpg) (not_eq_sym Hlg)). exact R.
    Qed.

    Lemma dm_resp : (prog_defmap OLP.prog) ! OLP._set_object_respawn_info_bits
      = Some (Gfun (Internal OLP.f_set_object_respawn_info_bits)).
    Proof. vm_compute. reflexivity. Qed.

    (* obj_w's parts at this pool, list array and rings *)
    Lemma ow_at : forall m rs, Pc m -> OW.rings m pool la = Some rs ->
      exists fl gol gmo sdp gdi fs, Genv.find_symbol G OLP._gFreeObjectList = Some fl
        /\ OW.ow_core G pool la fl gol gmo sdp gdi bm m rs fs.
    Proof.
      intros m rs (_ & _ & _ & _ & How) R.
      destruct How as (pool' & la' & fl & gol & gmo & sdp & gdi & rs' & fs & S1 & S2 & S3 & _ & _ & _ & _ & C).
      rewrite Hp in S1. injection S1 as <-. rewrite Hl in S2. injection S2 as <-.
      pose proof (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C) as R'. rewrite R in R'. injection R' as <-.
      exists fl, gol, gmo, sdp, gdi, fs. exact (conj S3 C).
    Qed.

    Lemma slot_in : forall m rs l1 k l2, OW.rings m pool la = Some rs -> nth i rs [] = l1 ++ k :: l2 ->
      0 <= k < OW.NSLOT /\ In k (concat rs).
    Proof.
      intros m rs l1 k l2 R El.
      pose proof (proj1 (ObjRing.rings_iff pool m la rs Hpl) R) as (Hlen & Henc).
      destruct (Henc i Hi) as (_ & Hc & _). rewrite El in Hc.
      destruct (UnloadLoop.chain_mid _ _ _ _ _ _ _ Hc) as (Hk & _).
      split; [ exact Hk | ].
      apply (in_nth_concat rs i k); [ rewrite Hlen; exact Hi | rewrite El; apply in_or_app; right; left; reflexivity ].
    Qed.

    Lemma Wresp : forall b fd, Genv.find_symbol G OLP._set_object_respawn_info_bits = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
      forall m rs l1 k l2 t m' vr, WU m rs -> nth i rs [] = l1 ++ k :: l2 -> UnloadLoop.inactive pool m k ->
        Mem.load Mint32 m gco 0 = Some (OW.slot_v pool k) ->
        eval_funcall function_entry2 G m fd [OW.slot_v pool k; Vint (Int.repr 255)] t m' vr ->
        WU m' rs /\ Mem.load Mint32 m' gco 0 = Some (OW.slot_v pool k) /\ UnloadLoop.inactive pool m' k.
    Proof.
      intros b fd Hs Hf m rs l1 k l2 t m' vr (HP & R) El Ina Lg H.
      rewrite (ObjLoop.fun_olp lp H12 _ _ dm_resp b fd Hs Hf) in H.
      destruct (slot_in m rs l1 k l2 R El) as (Hk & Hin).
      destruct (UnloadLoop.resp_walk G (ObjLoop.cenv_olp lp H12) pool m k _ t m' vr Hk H)
        as [-> | (tt & bt & o & ch & ii & Lt & Hch & Li & St)].
      { exact (conj (conj HP R) (conj Lg Ina)). }
      destruct (ow_at m rs HP R) as (fl & gol & gmo & sdp & gdi & fs & S3 & C).
      destruct (OW.ow_resp _ _ _ _ _ _ _ _ _ _ _ _ C k Hin) as (t0 & Lt0 & T1 & T2).
      rewrite Lt in Lt0. injection Lt0 as <-.
      assert (LO : forall ch' b' z, b' <> bt -> Mem.load ch' m' b' z = Mem.load ch' m b' z)
        by (intros ch' b' z N; apply (Mem.load_store_other _ _ _ _ _ _ St); left; exact N).
      (* the three targets: where the store lands, and that it keeps Pc *)
      assert (TG : Pc m' /\ bt <> pool /\ bt <> la /\ bt <> gco).
      { destruct Hch as [(E1 & ->) | (E2 & ->)].
        - destruct (T1 E1) as (b1 & o1 & Li1 & [(Sps & Eo) | (Gc & Ino)]);
            rewrite Li in Li1; injection Li1 as <- <-.
          + split; [ exact (int_gstore area._gPlayerSpawnInfos bt Mint32 _ ii m m' Sps
                              ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) St HP) | ].
            split; [ exact (ClearKeep.symne_b G _ _ _ _ Hp Sps ltac:(vm_compute; reflexivity)) | ].
            split; [ exact (ClearKeep.symne_b G _ _ _ _ Hl Sps ltac:(vm_compute; reflexivity)) | ].
            exact (ClearKeep.symne_b G _ _ _ _ Hg Sps ltac:(vm_compute; reflexivity)).
          + split; [ exact (Hsi m bt o ii m' HP Gc Ino St) | ].
            destruct (OW.ow_spool _ _ _ _ _ _ _ _ _ _ _ _ C) as (P & HPn & Gc' & _).
            assert (EP : bt = P).
            { destruct Gc as (bs & Hs1 & L1). destruct Gc' as (bs' & Hs2 & L2).
              rewrite Hs1 in Hs2. injection Hs2 as <-. rewrite L1 in L2. injection L2 as E. exact E. }
            subst P.
            split; [ exact (ClearKeep.glob_ne_dyn G _ _ bt Hp HPn) | ].
            split; [ exact (ClearKeep.glob_ne_dyn G _ _ bt Hl HPn) | ].
            exact (ClearKeep.glob_ne_dyn G _ _ bt Hg HPn).
        - destruct (T2 E2) as (b1 & o1 & Li1 & Smo & _).
          rewrite Li in Li1. injection Li1 as <- <-.
          split; [ exact (int_gstore wmotr_level_data._wmotr_seg7_macro_objs bt Mint16unsigned _ ii m m' Smo
                            ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) St HP) | ].
          split; [ exact (ClearKeep.symne_b G _ _ _ _ Hp Smo ltac:(vm_compute; reflexivity)) | ].
          split; [ exact (ClearKeep.symne_b G _ _ _ _ Hl Smo ltac:(vm_compute; reflexivity)) | ].
          exact (ClearKeep.symne_b G _ _ _ _ Hg Smo ltac:(vm_compute; reflexivity)). }
      destruct TG as (HP' & Np & Nl & Ng).
      split; [ split; [ exact HP' | rewrite (rings_off m m' bt LO Np Nl); exact R ] | ].
      split; [ rewrite (LO _ _ _ (not_eq_sym Ng)); exact Lg | exact (inactive_off m m' bt k LO Np Ina) ].
    Qed.

    Lemma Wunl : forall b fd, Genv.find_symbol G OLP._unload_object = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
      forall m rs l1 k l2 t m' vr, WU m rs -> nth i rs [] = l1 ++ k :: l2 -> UnloadLoop.inactive pool m k ->
        eval_funcall function_entry2 G m fd [OW.slot_v pool k] t m' vr -> WU m' (ObjRing.upd rs i (l1 ++ l2)).
    Proof.
      intros b fd Hs Hf m rs l1 k l2 t m' vr (HP & R) El Ina H.
      rewrite (ObjPhase.fun_of lp SO.prog _ _ (linked12_LO_spawn_object lp H12) UnloadObj.dm_uo b fd Hs Hf) in H.
      split; [ exact (Hunl pool la m rs i l1 k l2 t m' vr Hp Hl HP R Hi El Ina H) | ].
      destruct (ow_at m rs HP R) as (fl & gol & gmo & sdp & gdi & fs & S3 & C).
      destruct dm_bpg as (gd & Hdm).
      destruct (linkorder_resolves_symbol lp SO.prog _ gd (linked12_LO_spawn_object lp H12) Hdm) as (bpg & Hb).
      pose proof HP as ((_ & _ & HM) & Hphi & _).
      pose proof Hphi as (_ & _ & _ & _ & _ & _ & _ & Hlvl).
      pose proof (proj1 (AudioInv.aud_w_eq G m) (lvl_w_aud G m Hlvl)) as AI.
      destruct (UnloadSharp.unload_sharp_real lp H12 pool la fl bpg Hp Hl S3 Hb m rs fs i l1 k l2 t m' vr R
                  (OW.ow_free _ _ _ _ _ _ _ _ _ _ _ _ C) (proj1 (OW.ow_part _ _ _ _ _ _ _ _ _ _ _ _ C)) Hi El
                  (OW.ow_gfx _ _ _ _ _ _ _ _ _ _ _ _ C) AI (mwf_real_nextbound lp bm bc oc0 SafeB m HM) H)
        as (R' & _).
      exact R'.
    Qed.
  End LIST.

  Lemma dm_gco' : exists gd, (prog_defmap OLP.prog) ! OLP._gCurrentObject = Some gd.
  Proof.
    destruct ((prog_defmap OLP.prog) ! OLP._gCurrentObject) as [gd|] eqn:E;
      [ exists gd; reflexivity | vm_compute in E; discriminate E ].
  Qed.

  (* unload_deactivated_objects_in_list on a list head the order table
     names keeps Pc *)
  Theorem inlist_keeps : forall la idx m t m' vr, (idx < 13)%nat ->
    Genv.find_symbol G OLP._gObjectListArray = Some la -> Pc m ->
    eval_funcall function_entry2 G m (Internal OLP.f_unload_deactivated_objects_in_list)
      [ObjLoop.head_v la idx] t m' vr -> Pc m'.
  Proof.
    intros la idx m t m' vr Hidx Hl HP H.
    pose proof HP as (_ & _ & _ & _ & How).
    destruct How as (pool & la' & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & _ & _ & _ & _ & _ & C).
    rewrite Hl in S2. injection S2 as <-.
    destruct dm_gco' as (gd & Hdm).
    destruct (linkorder_resolves_symbol lp OLP.prog _ gd (ObjPhase.LO_olp lp H12) Hdm) as (gco & Hgco).
    assert (Hi : (idx < OW.NLIST)%nat) by (unfold OW.NLIST; exact Hidx).
    destruct (UnloadLoop.inlist_ok G (ObjLoop.cenv_olp lp H12) pool la gco (Hpl pool la S1 Hl) Hgco idx Hi
                (WU pool la) (Wr pool la) (Wg pool la gco S1 Hl Hgco idx)
                (Wresp pool la gco S1 Hl Hgco idx Hi) (Wunl pool la S1 Hl idx Hi)
                m rs t m' vr (conj HP (OW.ow_rings _ _ _ _ _ _ _ _ _ _ _ _ C)) H)
      as (rs' & HP' & _).
    exact HP'.
  Qed.

  (* the outer loop's own store: gTimeStopState &= ~1 *)
  Theorem ts_keeps : forall m b c m', Pc m -> Genv.find_symbol G OLP._gTimeStopState = Some b ->
    Mem.store Mint32 m b 0 (Vint c) = Some m' -> Pc m'.
  Proof.
    intros m b c m' HP Hs St.
    exact (int_gstore OLP._gTimeStopState b Mint32 0 c m m' Hs ltac:(vm_compute; reflexivity)
             ltac:(vm_compute; reflexivity) ltac:(vm_compute; reflexivity) St HP).
  Qed.
End UR.
