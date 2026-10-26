(* ====================================================================== *)
(* PollKeep (GOAL 2): the controller poll's carries of the frame world,   *)
(* PROVED from the real code (2026-10-26).                                *)
(*                                                                        *)
(* The poll (PollFlank) is two real calls: osContStartReadData(&gSI...)   *)
(* (srd) and read_controller_inputs() (rci).  For each this file proves   *)
(* the footprint relation LevelWalk.fx over a LISTED set of globals:      *)
(*   - unchanged outside those globals' blocks (srd: FootWalk, the        *)
(*     footprint twin of SaveDoSaveBody's SI walker; rci: PollFlank's     *)
(*     own walk, poll_core's Uc);                                         *)
(*   - every old permission kept, new blocks without any (Generic         *)
(*     PermWalk over the two call trees, whose leaves are the OS floor    *)
(*     calls, OsDmaFloor's same_perms, and sqrtf, FpuFloor);              *)
(* and then the frame-boundary facts through it:                          *)
(*   PhiW      RenderKeep.k_all_lvl via LevelKeep.lvl_keeps_core (lvl_w   *)
(*             at the end: unchanged for srd; for rci the controller      *)
(*             clause ctl_w is what PollFlank.poll_ok re-establishes);    *)
(*   plat_still  LevelKeep.fx_plat_still (no gMarioPlatform, no pool);   *)
(*   OW        ObjWorld.obj_w_unch (no object-world block).               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require memory game_init libultra_osEepromWrite libultra_osSiCreateAccessQueue
  libultra_osCreateMesgQueue libultra_osContStartReadData math_util object_list_processor debug
  behavior_script.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor CensusV2.
From SM64.Proofs Require MtxfBody SaveDoSaveBody.
From SM64.Proofs Require Import Generic.PermWalk.
From SM64.Proofs Require Interp.CMem.
From SM64.Proofs Require Import Generic.ClosedMem Generic.ClightClosed.
From SM64.Generated Require save_file mario level_update platform_displacement.
From SM64.Proofs Require Import ActionValueFrame MWFReal SpawnInit MathBodies AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor WMotRWorld FfWorld RenderKeep LevelWalk.
From SM64.Proofs.WMotRRequiresA Require PollFlank ObjWorld FootWalk LevelKeep PlatformKeep.
Import ListNotations.
Local Open Scope Z_scope.

Module SDB := SaveDoSaveBody.
Module GI := game_init.
Module CR := libultra_osContStartReadData.
Module SQ := libultra_osSiCreateAccessQueue.
Module MQ := libultra_osCreateMesgQueue.
Module EW := libultra_osEepromWrite.

(* ---------------------------------------------------------------------- *)
(* 1. Permissions: both call trees keep every old permission.              *)
(* ---------------------------------------------------------------------- *)
Section PERM.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Hypothesis Hsq : sqrtf_spec.
  Notation G := (lp_ge lp).

  Definition ps_id (id : ident) : Prop :=
    forall b fd, Genv.find_symbol G id = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd -> PS G fd.

  Lemma psym_nil : psym G [].
  Proof. intros id b fd H. discriminate H. Qed.

  Lemma psym_cons : forall id ids, ps_id id -> psym G ids -> psym G (id :: ids).
  Proof.
    intros id ids P Ps x b fd Hin Hs Hf. cbn [inl_id existsb] in Hin.
    apply orb_true_iff in Hin as [E | Hin].
    - apply Pos.eqb_eq in E. subst x. exact (P b fd Hs Hf).
    - exact (Ps x b fd Hin Hs Hf).
  Qed.

  Lemma ps_int : forall q id f, linkorder q lp ->
    (prog_defmap q) ! id = Some (Gfun (Internal f)) -> PS G (Internal f) -> ps_id id.
  Proof.
    intros q id f LO Hd P b fd Hs Hf.
    destruct (linkorder_resolves_funct lp q id f LO Hd) as (b' & Hs' & Hf').
    unfold lp_ge in *. rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'. injection Hf' as ->. exact P.
  Qed.

  Lemma floor_ids3 : MtxfBody.no_internal_all12 SDB.floor_ids = true.
  Proof. vm_compute. reflexivity. Qed.

  Lemma ps_ext : forall q fid n, linkorder q lp -> mem_id fid SDB.floor_ids = true ->
    MtxfBody.xnamed ((prog_defmap q) ! fid) n = true ->
    (forall sg vargs m t vres m', external_functions_sem n sg (Genv.to_senv G) vargs m t vres m' ->
       same_perms m m') -> ps_id fid.
  Proof.
    intros q fid n LO Hid Hn Hsp b fd Hs Hf.
    destruct (MtxfBody.xresolve lp q fid SDB.floor_ids n b fd H12 LO Hid floor_ids3 Hn Hs Hf)
      as (sg & targs & tres & cc & ->).
    apply PS_external. intros vargs m t vres m' Hx. exact (Hsp sg _ _ _ _ _ Hx).
  Qed.

  Lemma ps_recv : ps_id memory._osRecvMesg.
  Proof.
    apply (ps_ext memory.prog memory._osRecvMesg "osRecvMesg" (linked12_LO_memory lp H12) eq_refl
             ltac:(vm_compute; reflexivity)).
    intros sg vargs m t vres m' Hx. destruct Hfloor as (_ & _ & Hrv & _).
    destruct (Hrv _ _ _ _ _ _ _ Hx) as (bq & oq & cell & f0 & _ & _ & SP & _). exact SP.
  Qed.

  Lemma ps_send : ps_id SQ._osSendMesg.
  Proof.
    apply (ps_ext SQ.prog SQ._osSendMesg "osSendMesg" (linked12_LO_ultra_si lp H12) eq_refl
             ltac:(vm_compute; reflexivity)).
    intros sg vargs m t vres m' Hx. destruct Hfloor as (_ & _ & _ & Hsd & _).
    destruct (Hsd _ _ _ _ _ _ _ Hx) as (bq & oq & msg & f0 & _ & SP & _). exact SP.
  Qed.

  Lemma ps_rawdma : ps_id EW.___osSiRawStartDma.
  Proof.
    apply (ps_ext EW.prog EW.___osSiRawStartDma "__osSiRawStartDma" (linked12_LO_ultra_ew lp H12) eq_refl
             ltac:(vm_compute; reflexivity)).
    intros sg vargs m t vres m' Hx. destruct Hfloor as (_ & _ & _ & _ & _ & Hsi & _).
    destruct (Hsi _ _ _ _ _ _ _ Hx) as (dir & bp & op & _ & _ & SP & _). exact SP.
  Qed.

  Lemma ps_sqrtf : ps_id math_util._sqrtf.
  Proof.
    intros b fd Hs Hf m vargs t m' vres Hev.
    rewrite (MtxfBody.sqrtf_memid lp H12 Hsq b fd m vargs t m' vres Hs Hf Hev). apply PK_refl.
  Qed.

  (* the internal functions, bottom-up *)
  Lemma PS_cmq : PS G (Internal MQ.f_osCreateMesgQueue).
  Proof. apply (pk_body G [] psym_nil). vm_compute. reflexivity. Qed.

  Lemma ps_cmq : ps_id MQ._osCreateMesgQueue.
  Proof.
    apply (ps_int MQ.prog MQ._osCreateMesgQueue MQ.f_osCreateMesgQueue (linked12_LO_ultra_cmq lp H12)); [ vm_compute; reflexivity | exact PS_cmq ].
  Qed.

  Lemma PS_caq : PS G (Internal SQ.f___osSiCreateAccessQueue).
  Proof.
    apply (pk_body G [MQ._osCreateMesgQueue; SQ._osSendMesg]
             (psym_cons _ _ ps_cmq (psym_cons _ _ ps_send psym_nil))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_caq : ps_id SQ.___osSiCreateAccessQueue.
  Proof.
    apply (ps_int SQ.prog SQ.___osSiCreateAccessQueue SQ.f___osSiCreateAccessQueue (linked12_LO_ultra_si lp H12)); [ vm_compute; reflexivity | exact PS_caq ].
  Qed.

  Lemma PS_ga : PS G (Internal SQ.f___osSiGetAccess).
  Proof.
    apply (pk_body G [SQ.___osSiCreateAccessQueue; memory._osRecvMesg]
             (psym_cons _ _ ps_caq (psym_cons _ _ ps_recv psym_nil))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_ga : ps_id SQ.___osSiGetAccess.
  Proof.
    apply (ps_int SQ.prog SQ.___osSiGetAccess SQ.f___osSiGetAccess (linked12_LO_ultra_si lp H12)); [ vm_compute; reflexivity | exact PS_ga ].
  Qed.

  Lemma PS_ra : PS G (Internal SQ.f___osSiRelAccess).
  Proof.
    apply (pk_body G [SQ._osSendMesg] (psym_cons _ _ ps_send psym_nil)). vm_compute. reflexivity.
  Qed.

  Lemma ps_ra : ps_id SQ.___osSiRelAccess.
  Proof.
    apply (ps_int SQ.prog SQ.___osSiRelAccess SQ.f___osSiRelAccess (linked12_LO_ultra_si lp H12)); [ vm_compute; reflexivity | exact PS_ra ].
  Qed.

  Lemma PS_prd : PS G (Internal CR.f___osPackReadData).
  Proof. apply (pk_body G [] psym_nil). vm_compute. reflexivity. Qed.

  Lemma ps_prd : ps_id CR.___osPackReadData.
  Proof.
    apply (ps_int CR.prog CR.___osPackReadData CR.f___osPackReadData (linked12_LO_libultra_osContStartReadData lp H12));
      [ vm_compute; reflexivity | exact PS_prd ].
  Qed.

  (* osContStartReadData keeps every permission *)
  Theorem PS_srd : PS G (Internal CR.f_osContStartReadData).
  Proof.
    apply (pk_body G [CR.___osPackReadData; SQ.___osSiGetAccess; EW.___osSiRawStartDma;
                      SQ.___osSiRelAccess; memory._osRecvMesg]
             (psym_cons _ _ ps_prd (psym_cons _ _ ps_ga (psym_cons _ _ ps_rawdma
               (psym_cons _ _ ps_ra (psym_cons _ _ ps_recv psym_nil)))))).
    vm_compute. reflexivity.
  Qed.

  Lemma PS_grd : PS G (Internal CR.f_osContGetReadData).
  Proof. apply (pk_body G [] psym_nil). vm_compute. reflexivity. Qed.

  Lemma ps_grd : ps_id CR._osContGetReadData.
  Proof.
    apply (ps_int CR.prog CR._osContGetReadData CR.f_osContGetReadData (linked12_LO_libultra_osContStartReadData lp H12));
      [ vm_compute; reflexivity | exact PS_grd ].
  Qed.

  Lemma PS_rd : PS G (Internal GI.f_run_demo_inputs).
  Proof. apply (pk_body G [] psym_nil). vm_compute. reflexivity. Qed.

  Lemma ps_rd : ps_id GI._run_demo_inputs.
  Proof.
    apply (ps_int GI.prog GI._run_demo_inputs GI.f_run_demo_inputs (PollFlank.LO_gi lp H12)); [ vm_compute; reflexivity | exact PS_rd ].
  Qed.

  Lemma PS_adj : PS G (Internal GI.f_adjust_analog_stick).
  Proof.
    apply (pk_body G [math_util._sqrtf] (psym_cons _ _ ps_sqrtf psym_nil)). vm_compute. reflexivity.
  Qed.

  Lemma ps_adj : ps_id GI._adjust_analog_stick.
  Proof.
    apply (ps_int GI.prog GI._adjust_analog_stick GI.f_adjust_analog_stick (PollFlank.LO_gi lp H12)); [ vm_compute; reflexivity | exact PS_adj ].
  Qed.

  (* read_controller_inputs keeps every permission *)
  Theorem PS_rci : PS G (Internal GI.f_read_controller_inputs).
  Proof.
    apply (pk_body G [GI._adjust_analog_stick; CR._osContGetReadData; memory._osRecvMesg; GI._run_demo_inputs]
             (psym_cons _ _ ps_adj (psym_cons _ _ ps_grd (psym_cons _ _ ps_recv
               (psym_cons _ _ ps_rd psym_nil))))).
    vm_compute. reflexivity.
  Qed.
End PERM.

(* ---------------------------------------------------------------------- *)
(* 2. The object world reads only its own globals' blocks and Mario's     *)
(*    marioObj / interactObj .. riddenObj cells.                           *)
(* ---------------------------------------------------------------------- *)
Module OW := ObjWorld.
Module CM := SM64.Proofs.Interp.CMem.

(* the globals obj_w reads *)
Definition ow_ids : list ident :=
  [object_list_processor._gObjectPool; object_list_processor._gObjectListArray;
   object_list_processor._gFreeObjectList; object_list_processor._gObjectLists;
   object_list_processor._gMarioObject; debug._sDebugPage; debug._gDebugInfo;
   object_list_processor._sObjectListUpdateOrder; behavior_script._BehaviorCmdTable].

Section OWK.
  Variables (m m' : mem).

  Lemma ld32_eq : forall b, (forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    forall z, OW.ld32 m' b z = OW.ld32 m b z.
  Proof. intros b K z. unfold OW.ld32. rewrite !CM.load_eq. apply K. Qed.

  Lemma ring_from_eq : forall pool hb,
    (forall z, OW.ld32 m' pool z = OW.ld32 m pool z) -> (forall z, OW.ld32 m' hb z = OW.ld32 m hb z) ->
    forall n ho prev cur, OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
  Proof.
    intros pool hb Kp Kh n. induction n as [| n IH]; intros ho prev cur; cbn [OW.ring_from]; [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned i) ho); [ rewrite Kh; reflexivity | ].
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)); [ | reflexivity ].
    rewrite !Kp.
    destruct (OW.ld32 m pool (Ptrofs.unsigned i + OW.O_PREV)); [ | reflexivity ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned i + OW.O_NEXT)); [ | reflexivity ].
    destruct (OW.veqb v prev); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Lemma rings_eq : forall pool la,
    (forall z, OW.ld32 m' pool z = OW.ld32 m pool z) -> (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
    OW.rings m' pool la = OW.rings m pool la.
  Proof.
    intros pool la Kp Kl. unfold OW.rings.
    assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
    { apply map_ext. intros i. unfold OW.ring_i. rewrite Kl.
      destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
      apply ring_from_eq; assumption. }
    rewrite E. reflexivity.
  Qed.

  Lemma free_from_eq : forall pool, (forall z, OW.ld32 m' pool z = OW.ld32 m pool z) ->
    forall n cur, OW.free_from m' pool cur n = OW.free_from m pool cur n.
  Proof.
    intros pool Kp n. induction n as [| n IH]; intros cur; cbn [OW.free_from]; [ reflexivity | ].
    destruct (OW.veqb cur Vnullptr); [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b pool); [ | reflexivity ].
    rewrite Kp. destruct (OW.slot_of (Ptrofs.unsigned i)); [ | reflexivity ].
    destruct (OW.ld32 m pool (Ptrofs.unsigned i + OW.O_NEXT)); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Section POOL.
    Variables (ge : genv) (pool : block).
    Hypothesis Kp : forall ch z, Mem.load ch m' pool z = Mem.load ch m pool z.

    Lemma is_bhv_eq : forall k id, OW.is_bhv ge pool m k id -> OW.is_bhv ge pool m' k id.
    Proof. intros k id (b & Hs & L). exists b. rewrite Kp. exact (conj Hs L). Qed.

    Lemma is_bhv_eq' : forall k id, OW.is_bhv ge pool m' k id -> OW.is_bhv ge pool m k id.
    Proof. intros k id (b & Hs & L). exists b. rewrite Kp in L. exact (conj Hs L). Qed.

    Lemma script_eq : forall k, OW.script_ok ge pool m k -> OW.script_ok ge pool m' k.
    Proof.
      intros k (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kp. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma script12_eq : forall k, OW.script12_ok ge pool m k -> OW.script12_ok ge pool m' k.
    Proof.
      intros k (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kp. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma vm_eq : forall k, OW.vm_ok ge pool m k -> OW.vm_ok ge pool m' k.
    Proof.
      intros k (st & Hin & (b & Hs & L1) & L2 & F). exists st.
      split; [ exact Hin | split; [ exists b; rewrite Kp; exact (conj Hs L1) | split ] ].
      - rewrite Kp. exact L2.
      - intros n f Hn. rewrite Kp. exact (F n f Hn).
    Qed.

    Lemma act_eq : forall k, OW.act_ok ge pool m k -> OW.act_ok ge pool m' k.
    Proof.
      intros k H bh t Hin Hb. destruct (H bh t Hin (is_bhv_eq' k bh Hb)) as (a & La & R).
      exists a. rewrite Kp. exact (conj La R).
    Qed.

    Lemma kind_eq : forall k, OW.kind_ok pool m k -> OW.kind_ok pool m' k.
    Proof.
      intros k (t & Lt & Hin & Hp & Hc). exists t.
      split; [ rewrite Kp; exact Lt | split; [ exact Hin | split ] ].
      - intros E. destruct (Hp E) as (base & top & Hb & L1 & L2 & L3).
        exists base, top. rewrite !Kp. exact (conj Hb (conj L1 (conj L2 L3))).
      - intros E. destruct (Hc E) as (y & Hy & L). exists y. rewrite Kp. exact (conj Hy L).
    Qed.

    Lemma red_eq : forall k, OW.red_ok ge pool m k -> OW.red_ok ge pool m' k.
    Proof.
      intros k (N & R). split.
      - intros Hb. exact (N (is_bhv_eq' k _ Hb)).
      - intros Hb. destruct (R (is_bhv_eq' k _ Hb)) as (c & Lc & Rc). exists c. rewrite Kp. exact (conj Lc Rc).
    Qed.
  End POOL.

  (* THE LEMMA: obj_w survives any change off its globals' blocks and off
     Mario's five object-pointer cells *)
  Theorem obj_w_unch : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K Kbm (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    assert (Kp := K object_list_processor._gObjectPool pool ltac:(unfold ow_ids; cbn [In]; auto 10) S1).
    assert (Kl := K object_list_processor._gObjectListArray la ltac:(unfold ow_ids; cbn [In]; auto 10) S2).
    assert (Kf := K object_list_processor._gFreeObjectList fl ltac:(unfold ow_ids; cbn [In]; auto 10) S3).
    assert (Kg := K object_list_processor._gObjectLists gol ltac:(unfold ow_ids; cbn [In]; auto 10) S4).
    assert (Km := K object_list_processor._gMarioObject gmo ltac:(unfold ow_ids; cbn [In]; auto 10) S5).
    assert (Ks := K debug._sDebugPage sdp ltac:(unfold ow_ids; cbn [In]; auto 10) S6).
    assert (Kd := K debug._gDebugInfo gdi ltac:(unfold ow_ids; cbn [In]; auto 10) S7).
    exists pool, la, fl, gol, gmo, sdp, gdi, rs, fs.
    refine (conj S1 (conj S2 (conj S3 (conj S4 (conj S5 (conj S6 (conj S7 _))))))).
    destruct C as [Cg Cr Cf Cp Cfo Cm Cs Ca Crd Cdb Cst Co Cd12 Cct Cvm].
    constructor.
    - rewrite Kg. exact Cg.
    - rewrite (rings_eq pool la (ld32_eq pool Kp) (ld32_eq la Kl)). exact Cr.
    - unfold OW.free_list in *. rewrite (ld32_eq fl Kf).
      destruct (OW.ld32 m fl OW.O_NEXT); [ | discriminate Cf ].
      rewrite (free_from_eq pool (ld32_eq pool Kp)). exact Cf.
    - exact Cp.
    - intros k Hk. rewrite Kp. exact (Cfo k Hk).
    - destruct Cm as (k & Hk & Lg & Lb & Kd').
      exists k. split; [ exact Hk | split; [ rewrite Km; exact Lg | split ] ].
      + rewrite (Kbm _ (or_introl eq_refl)). exact Lb.
      + intros j Hj Ne. exact (kind_eq pool Kp j (Kd' j Hj Ne)).
    - intros k Hk. exact (script_eq ge pool Kp k (Cs k Hk)).
    - intros k Hk. exact (act_eq ge pool Kp k (Ca k Hk)).
    - intros k Hk. exact (red_eq ge pool Kp k (Crd k Hk)).
    - rewrite Ks, Kd. exact Cdb.
    - intros z Hz. rewrite (Kbm z (or_intror Hz)). exact (Cst z Hz).
    - destruct Co as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j Hj. rewrite (K object_list_processor._sObjectListUpdateOrder b ltac:(unfold ow_ids; cbn [In]; auto 10) Sb). exact (L j Hj).
    - intros k Hk. exact (script12_eq ge pool Kp k (Cd12 k Hk)).
    - destruct Cct as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j id Hj. rewrite (K behavior_script._BehaviorCmdTable b ltac:(unfold ow_ids; cbn [In]; auto 10) Sb). exact (L j id Hj).
    - intros k Hk. exact (vm_eq ge pool Kp k (Cvm k Hk)).
  Qed.
End OWK.

(* ---------------------------------------------------------------------- *)
(* 3. osContStartReadData's footprint: FootWalk over its call tree.        *)
(* ---------------------------------------------------------------------- *)
(* the globals the SI request writes: the event queue (its DMA-done
   message), the SI access queue and its buffer, the PIF image and the
   last-command byte *)
Definition srd_gvars : list ident :=
  [save_file._gSIEventMesgQueue; SQ._gOsSiAccessQueueCreated; SQ._gOsSiMessageQueue;
   SQ._osSiMesgBuff; CR.___osContPifRam; CR.___osContLastCmd].

Section SRDF.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Variable m0 : mem.

  Ltac ct_ok c :=
    let fid := fresh "fid" in let f := fresh "f" in
    let fl' := fresh "fl'" in let qa' := fresh "qa'" in let H := fresh "H" in
    intros fid f fl' qa' H; unfold c in H; cbn [SDB.find_ct] in H;
    repeat match type of H with
    | (if Pos.eqb fid ?g then Some _ else _) = _ =>
        let E := fresh "E" in
        destruct (Pos.eqb fid g) eqn:E; cbv beta iota in H;
        [ apply Pos.eqb_eq in E; subst fid; injection H as <- <- <- | ]
    end;
    [ .. | discriminate H ].

  Ltac res q LO :=
    apply (linkorder_resolves_funct lp q _ _ (LO lp H12)); vm_compute; reflexivity.

  Lemma ct_nil : FootWalk.ctab_ok lp srd_gvars m0 [].
  Proof. intros ? ? ? ? H. discriminate H. Qed.

  Lemma fw_cmq : FootWalk.fpF lp srd_gvars m0 MQ.f_osCreateMesgQueue [] [].
  Proof. apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Definition ct_csq : SDB.ctab := [(SQ._osCreateMesgQueue, (MQ.f_osCreateMesgQueue, ([], [])))].
  Lemma fw_csq : FootWalk.fpF lp srd_gvars m0 SQ.f___osSiCreateAccessQueue [] [].
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ ct_csq); [ vm_compute; reflexivity | ].
    ct_ok ct_csq. split; [ res MQ.prog linked12_LO_ultra_cmq | exact fw_cmq ].
  Qed.

  Definition ct_ga : SDB.ctab := [(SQ.___osSiCreateAccessQueue, (SQ.f___osSiCreateAccessQueue, ([], [])))].
  Lemma fw_ga : FootWalk.fpF lp srd_gvars m0 SQ.f___osSiGetAccess [SQ._t'1] [].
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ ct_ga); [ vm_compute; reflexivity | ].
    ct_ok ct_ga. split; [ res SQ.prog linked12_LO_ultra_si | exact fw_csq ].
  Qed.

  Lemma fw_ra : FootWalk.fpF lp srd_gvars m0 SQ.f___osSiRelAccess [] [].
  Proof. apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma fw_prd : FootWalk.fpF lp srd_gvars m0 CR.f___osPackReadData [] [].
  Proof. apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma fw_srd : FootWalk.fpF lp srd_gvars m0 CR.f_osContStartReadData PollFlank.fl_srd PollFlank.qa_srd.
  Proof.
    apply (FootWalk.body_fpF lp H12 Hfloor srd_gvars m0 _ _ _ PollFlank.ct_srd); [ vm_compute; reflexivity | ].
    ct_ok PollFlank.ct_srd.
    - split; [ res SQ.prog linked12_LO_ultra_si | exact fw_ga ].
    - split; [ res CR.prog linked12_LO_libultra_osContStartReadData | exact fw_prd ].
    - split; [ res SQ.prog linked12_LO_ultra_si | exact fw_ra ].
  Qed.
End SRDF.

(* ---------------------------------------------------------------------- *)
(* 4. The two calls as footprint relations, and the carries.               *)
(* ---------------------------------------------------------------------- *)
Section LINK.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Hypothesis Hsq : sqrtf_spec.
  Variables (bm bc : block) (oc0 : ptrofs) (SafeB : block -> Prop).
  Hypothesis HSafeB_syms : SafeB_syms_ok lp SafeB.
  Hypothesis Hbm_sym : Genv.find_symbol (lp_ge lp) level_update._gMarioStates = Some bm.
  Hypothesis Hbc_sym : Genv.find_symbol (lp_ge lp) mario._gControllers = Some bc.
  Hypothesis Hoc0 : oc0 = Ptrofs.zero.
  Notation G := (lp_ge lp).
  Notation MWF := (MWF_real lp bm bc oc0 SafeB).

  (* the request: memory changes only in srd_gvars' blocks, every old
     permission kept *)
  Theorem srd_fx : forall m i, PollFlank.srd_call lp m i -> fx lp bm srd_gvars m i.
  Proof.
    intros m i (bq & t & vres & Hq & Hev).
    pose proof (PS_srd lp H12 Hfloor _ _ _ _ _ Hev) as (_ & P & F).
    split; [ | exact (conj P F) ].
    assert (U : Mem.unchanged_on (FootWalk.Q lp srd_gvars m) m i).
    { apply (fw_srd lp H12 Hfloor m m _ t i vres Hev); [ | apply Ple_refl ].
      intros le Hb t0 v Hg.
      cbn [CR.f_osContStartReadData fn_params fn_temps bind_parameter_temps] in Hb.
      injection Hb as <-.
      destruct (Pos.eq_dec t0 CR._mesg) as [-> | Ne].
      - rewrite PTree.gss in Hg. injection Hg as <-.
        split.
        + intros _ b o E. injection E as <- _. left.
          exists save_file._gSIEventMesgQueue. split; [ left; reflexivity | exact Hq ].
        + intros _ b o E. injection E as <- _.
          exists save_file._gSIEventMesgQueue, []. split; [ vm_compute; reflexivity | ].
          split; [ vm_compute; reflexivity | split; [ intros s0 [] | exact Hq ] ].
      - rewrite PTree.gso in Hg by exact Ne.
        assert (Ev : v = Vundef).
        { revert Hg.
          repeat (rewrite PTree.gsspec; destruct (peq _ _); [ intro E; injection E as <-; reflexivity | ]).
          rewrite PTree.gempty. intro E; discriminate E. }
        subst v.
        split; [ intros _ b o E; discriminate E | ].
        intros Hm. exfalso. apply Ne. unfold PollFlank.qa_srd, mem_id in Hm. cbn [existsb] in Hm.
        rewrite orb_false_r in Hm. apply Pos.eqb_eq in Hm. exact Hm. }
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b z Nw V. split; [ | exact V ].
    intros Hb. apply Nw. left. exact Hb.
  Qed.

  (* the poll: memory changes only in PollFlank.rci_gvars' blocks *)
  Lemma rci_perm : forall i m0, PollFlank.rci_call lp i m0 -> PK i m0.
  Proof. intros i m0 (t & vres & Hev). exact (PS_rci lp H12 Hfloor Hsq _ _ _ _ _ Hev). Qed.

  Lemma rci_fx : forall i m0, PollFlank.rci_call lp i m0 ->
    Mem.unchanged_on (fun b _ => ~ PollFlank.rci_blk lp b) i m0 -> fx lp bm PollFlank.rci_gvars i m0.
  Proof.
    intros i m0 Hc U. pose proof (rci_perm i m0 Hc) as (_ & P & F).
    split; [ | exact (conj P F) ].
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b z Nw _ Hb. apply Nw. left. exact Hb.
  Qed.

  (* closedness, for a call with global-pointer (or no) arguments *)
  Lemma call_cl : forall m fd vargs t m' vres,
    eval_funcall function_entry2 G m fd vargs t m' vres ->
    (forall v, In v vargs -> exists id b, Genv.find_symbol G id = Some b /\ v = Vptr b Ptrofs.zero) ->
    cl_rel G m m'.
  Proof.
    intros m fd vargs t m' vres Hev Ha g Hc Hs.
    assert (Hv : Forall (vok g) vargs).
    { apply Forall_forall. intros v Hin. destruct (Ha v Hin) as (id & b & Hb & ->).
      apply vok_mk_ptr. exact (closed_mapped_flat g m b Hc (Hs id b Hb)). }
    destruct (funcall_closed G m fd vargs t m' vres g Hev Hc Hs Hv) as (g' & I & Hc' & Hs' & _).
    exists g'. auto.
  Qed.

  (* ---- the generic carries through a footprint ---- *)
  Lemma lvl_w_fx0 : forall Xs m m',
    (forall id, In id Xs -> existsb (Pos.eqb id) lvl_ids = false) ->
    fx lp bm Xs m m' -> lvl_w G m -> lvl_w G m'.
  Proof.
    intros Xs m m' HX Hfx. apply lvl_w_unch.
    intros b ch z (id & Hin & Hs). apply (fx_load lp bm Xs m m' ch b z Hfx).
    intros i _ [(id' & Hin' & Hs') | (-> & _)].
    - assert (E : id' = id) by (eapply Genv.genv_vars_inj; [ exact Hs' | exact Hs ]). subst id'.
      pose proof (HX id Hin') as N.
      assert (Y : existsb (Pos.eqb id) lvl_ids = true)
        by (apply existsb_exists; exists id; split; [ exact Hin | apply Pos.eqb_refl ]).
      congruence.
    - assert (E : id = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbm_sym ]).
      subst id.
      assert (Y : existsb (Pos.eqb level_update._gMarioStates) lvl_ids = true)
        by (apply existsb_exists; exists level_update._gMarioStates; split; [ exact Hin | apply Pos.eqb_refl ]).
      vm_compute in Y. discriminate Y.
  Qed.

  Lemma fx_obj_w : forall Xs m m',
    (forall id, In id ow_ids -> existsb (Pos.eqb id) Xs = false) ->
    existsb (Pos.eqb level_update._gMarioStates) Xs = false ->
    fx lp bm Xs m m' -> OW.obj_w G bm m -> OW.obj_w G bm m'.
  Proof.
    intros Xs m m' HX Hn Hfx. apply obj_w_unch.
    - intros id b Hin Hs ch z. apply (fx_load lp bm Xs m m' ch b z Hfx).
      intros i _ [Hb | (-> & _)].
      + exact (LevelKeep.not_lvl lp Xs id b Hs (HX id Hin) Hb).
      + assert (E : id = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbm_sym ]).
        subst id. unfold ow_ids in Hin. cbn [In] in Hin.
        repeat (destruct Hin as [E | Hin]; [ vm_compute in E; discriminate E | ]). exact Hin.
    - intros z Hz. apply (fx_load lp bm Xs m m' Mint32 bm z Hfx).
      intros i Hi [Hb | (_ & Hc)].
      + exact (LevelKeep.not_lvl lp Xs _ bm Hbm_sym Hn Hb).
      + cbn [size_chunk] in Hi. unfold MARIOOBJ_OFF in Hz. cbn [In] in Hz. lia.
  Qed.
  (* ---- THE ROWS ---- *)
  Ltac vmr := vm_compute; reflexivity.

  (* osContStartReadData keeps PhiW, the platform fact and the object world *)
  Theorem srd_keeps : forall m i, PollFlank.srd_call lp m i -> phiw lp bm m ->
    phiw lp bm i /\ (PlatformKeep.plat_still lp m -> PlatformKeep.plat_still lp i)
    /\ (OW.obj_w G bm m -> OW.obj_w G bm i).
  Proof.
    intros m i Hc Hphi.
    pose proof (srd_fx m i Hc) as Hfx.
    pose proof Hc as (bq & t & vres & Hq & Hev).
    assert (Hcl : cl_rel G m i).
    { apply (call_cl m _ _ t i vres Hev). intros v [<- | []].
      exists save_file._gSIEventMesgQueue, bq. split; [ exact Hq | reflexivity ]. }
    pose proof Hphi as (_ & _ & _ & _ & _ & _ & _ & Hl).
    split; [ | split ].
    - apply (LevelKeep.lvl_keeps_core lp bm Hbm_sym srd_gvars
               (avoid_of srd_gvars core_ids ltac:(vmr)) ltac:(vmr) m i Hphi Hfx Hcl
               (phiw_surf_apart lp bm srd_gvars m Hphi)).
      exact (lvl_w_fx0 srd_gvars m i (avoid_of srd_gvars lvl_ids ltac:(vmr)) Hfx Hl).
    - exact (LevelKeep.fx_plat_still lp bm Hbm_sym srd_gvars m i ltac:(vmr) ltac:(vmr) Hfx).
    - exact (fx_obj_w srd_gvars m i (avoid_of ow_ids srd_gvars ltac:(vmr)) ltac:(vmr) Hfx).
  Qed.

  (* read_controller_inputs: GOAL 1's facts and A-freedom (PollFlank), and
     PhiW (its controller clause re-established), the platform fact and the
     object world *)
  Theorem rci_keeps : forall i m0,
    ow_facts bm MWF i -> phiw lp bm i -> PollFlank.pif_a_real G i = false -> PollFlank.rci_call lp i m0 ->
    (ow_facts bm MWF m0 /\ a_used_real bm m0 = false /\ phiw lp bm m0)
    /\ (PlatformKeep.plat_still lp i -> PlatformKeep.plat_still lp m0)
    /\ (OW.obj_w G bm i -> OW.obj_w G bm m0).
  Proof.
    intros i m0 Hof Hphi HP Hr.
    pose proof (NoAImpliesNoFlyTwelve.Hspawn lp H12 bm bc oc0 Hbm_sym Hbc_sym Hoc0) as Hsp.
    pose proof Hphi as (_ & _ & _ & _ & Hf & _ & _ & Hl).
    pose proof Hl as (_ & _ & _ & Hcw & _).
    destruct (PollFlank.poll_ok_foot lp H12 Hfloor Hsq bm bc oc0 SafeB HSafeB_syms Hsp i m0 Hof Hf Hcw HP Hr)
      as ((Hof' & HU & Hcw') & U).
    pose proof (rci_fx i m0 Hr U) as Hfx.
    pose proof Hr as (t & vres & Hev).
    assert (Hcl : cl_rel G i m0) by (apply (call_cl i _ _ t m0 vres Hev); intros v []).
    assert (HX : forall id, In id lvl_ids -> existsb (Pos.eqb id) PollFlank.rci_gvars = true ->
                   id = mario._gControllers \/ id = game_init._gControllerPads).
    { intros id Hin E. unfold lvl_ids in Hin. cbn [In] in Hin.
      repeat (destruct Hin as [<- | Hin];
              [ first [ vm_compute in E; discriminate E | left; reflexivity | right; reflexivity ] | ]).
      destruct Hin. }
    split; [ split; [ exact Hof' | split; [ exact HU | ] ] | split ].
    - apply (LevelKeep.lvl_keeps_core lp bm Hbm_sym PollFlank.rci_gvars
               (avoid_of PollFlank.rci_gvars core_ids ltac:(vmr)) ltac:(vmr) i m0 Hphi Hfx Hcl
               (phiw_surf_apart lp bm PollFlank.rci_gvars i Hphi)).
      exact (LevelKeep.lvl_w_ctl lp bm Hbm_sym PollFlank.rci_gvars i m0 HX Hl Hfx Hcw').
    - exact (LevelKeep.fx_plat_still lp bm Hbm_sym PollFlank.rci_gvars i m0 ltac:(vmr) ltac:(vmr) Hfx).
    - exact (fx_obj_w PollFlank.rci_gvars i m0 (avoid_of ow_ids PollFlank.rci_gvars ltac:(vmr)) ltac:(vmr) Hfx).
  Qed.
End LINK.
