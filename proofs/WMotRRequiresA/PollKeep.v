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
From SM64.Generated Require save_file mario level_update platform_displacement surface_load area.
From SM64.Generated Require wmotr_level_data behavior_data.
From SM64.Proofs Require Import ActionValueFrame MWFReal SpawnInit MathBodies AGates.
From SM64.Proofs Require NoAImpliesNoFlyTwelve.
From SM64.Proofs.WMotRRequiresA Require Import FpuFloor WMotRWorld FfWorld RenderKeep LevelWalk.
From SM64.Proofs.WMotRRequiresA Require PollFlank ObjWorld FootWalk LevelKeep PlatformKeep BhvVM.
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
   object_list_processor._sObjectListUpdateOrder; behavior_script._BehaviorCmdTable;
   (* 3b, 2026-11-02: the surface pins and the partitions *)
   surface_load._sSurfacePool; surface_load._sSurfaceNodePool; surface_load._sSurfacePoolSize;
   surface_load._gNumStaticSurfaces; surface_load._gNumStaticSurfaceNodes;
   surface_load._gStaticSurfacePartition; surface_load._gDynamicSurfacePartition;
   (* 3c, 2026-11-02: the surface counter and the two collision meshes *)
   surface_load._gSurfacesAllocated; OW.BOXM; OW.LIDM;
   (* 3e, 2026-11-03: the object graph nodes' parent (ow_gfx) *)
   area._gObjParentGraphNode;
   (* 3h, 2026-11-03: the animation tables and structs (ow_anim, OW.anim_ids) *)
   wmotr_level_data._bobomb_seg8_anims_0802396C; wmotr_level_data._bowser_key_seg3_anims_list;
   wmotr_level_data._toad_seg6_anims_0600FB58; wmotr_level_data._peach_seg5_anims_0501C41C;
   wmotr_level_data._bobomb_seg8_anim_080237FC; wmotr_level_data._bobomb_seg8_anim_08023954;
   wmotr_level_data._bowser_key_seg3_anim_unlock_door; wmotr_level_data._bowser_key_seg3_anim_course_exit;
   wmotr_level_data._toad_seg6_anim_0600B66C; wmotr_level_data._toad_seg6_anim_0600CE78;
   wmotr_level_data._toad_seg6_anim_0600E414; wmotr_level_data._toad_seg6_anim_0600FB40;
   wmotr_level_data._toad_seg6_anim_060099F0; wmotr_level_data._toad_seg6_anim_0600A0D0;
   wmotr_level_data._toad_seg6_anim_06008F7C; wmotr_level_data._toad_seg6_anim_06009310;
   wmotr_level_data._peach_seg5_anim_0500C638; wmotr_level_data._peach_seg5_anim_0500E6B4;
   wmotr_level_data._peach_seg5_anim_0500ED94; wmotr_level_data._peach_seg5_anim_0500F474;
   wmotr_level_data._peach_seg5_anim_0500FE84; wmotr_level_data._peach_seg5_anim_05011050;
   wmotr_level_data._peach_seg5_anim_05012F40; wmotr_level_data._peach_seg5_anim_05015468;
   wmotr_level_data._peach_seg5_anim_05016798; wmotr_level_data._peach_seg5_anim_05018664;
   wmotr_level_data._peach_seg5_anim_0501B328; wmotr_level_data._peach_seg5_anim_0501C404;
   (* 3i, 2026-11-03: the droplet parameter structs (ow_dp, OW.dparams) *)
   behavior_data._gShallowWaterSplashDropletParams; behavior_data._gShallowWaterWaveDropletParams].

(* the globals a writer of obj_w's surface cells changes (2026-11-03,
   ClearKeep: the clear writes the counter and the dynamic partition) *)
Definition ow_xc : list ident :=
  [object_list_processor._gObjectPool; surface_load._gSurfacesAllocated;
   surface_load._gDynamicSurfacePartition].

(* the anim ids (ow_anim) are listed in ow_ids, and none is excluded *)
Lemma anim_in_ow : forall t, In t OW.anim_ids -> In t ow_ids /\ existsb (Pos.eqb t) ow_xc = false.
Proof.
  intros t Ht.
  assert (A : forallb (fun t => existsb (Pos.eqb t) ow_ids && negb (existsb (Pos.eqb t) ow_xc)) OW.anim_ids = true)
    by (vm_compute; reflexivity).
  pose proof (proj1 (forallb_forall _ _) A t Ht) as E. apply andb_prop in E as [E1 E2].
  apply existsb_exists in E1 as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x.
  split; [ exact Hx | apply negb_true_iff; exact E2 ].
Qed.

(* the scripts (ow_scr, 2026-11-03): membership decided; gMarioStates is
   no script *)
Lemma not_in_of_existsb : forall x l, existsb (Pos.eqb x) l = false -> ~ In x l.
Proof.
  intros x l H Hin.
  assert (E : existsb (Pos.eqb x) l = true)
    by (apply existsb_exists; exists x; split; [ exact Hin | apply Pos.eqb_refl ]).
  congruence.
Qed.
Lemma scr_not_ms : existsb (Pos.eqb level_update._gMarioStates) (map BhvVM.v_s BhvVM.vm_tab) = false.
Proof. vm_compute. reflexivity. Qed.

(* a slot offset is a slot index times the object size *)
Lemma slot_of_eq : forall o k, OW.slot_of o = Some k -> o = k * OW.OSZ /\ 0 <= k < OW.NSLOT.
Proof.
  intros o k H. unfold OW.slot_of in H.
  destruct ((0 <=? o) && (o <? OW.NSLOT * OW.OSZ) && (o mod OW.OSZ =? 0)) eqn:E; [ | discriminate H ].
  injection H as <-. apply andb_prop in E as [E E3]. apply andb_prop in E as [E1 E2].
  apply Z.eqb_eq in E3. apply Z.leb_le in E1. apply Z.ltb_lt in E2.
  pose proof (Z.div_mod o OW.OSZ ltac:(unfold OW.OSZ; lia)) as D. rewrite E3 in D.
  unfold OW.OSZ, OW.NSLOT in *. split; [ lia | ].
  split; [ apply Z.div_pos; lia | apply Z.div_lt_upper_bound; lia ].
Qed.

(* the stack depth of every reachable VM state is at most 8 *)
Lemma vm_tab_depth : forallb (fun st => (List.length (BhvVM.v_k st) <=? 8)%nat) BhvVM.vm_tab = true.
Proof. vm_compute. reflexivity. Qed.

Lemma vm_depth : forall st, In st BhvVM.vm_tab -> (List.length (BhvVM.v_k st) <= 8)%nat.
Proof.
  intros st Hin. pose proof (proj1 (forallb_forall _ _) vm_tab_depth st Hin) as H.
  apply Nat.leb_le in H. exact H.
Qed.

Section OWK.
  Variables (m m' : mem).

  Lemma ld32_eq : forall b, (forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    forall z, OW.ld32 m' b z = OW.ld32 m b z.
  Proof. intros b K z. unfold OW.ld32. rewrite !CM.load_eq. apply K. Qed.

  (* the pool unchanged at every slot's fields from offset 96 on (the list
     node, the flags, the script VM, rawData, the hitbox, the behavior),
     except the platform field (offset 532, 2026-11-03: written by
     update_mario_platform, read by no obj_w clause), and at the graph
     node's prev / next / parent words [4, 16) (ow_gfx, 2026-11-03): what
     every obj_w clause reads of it *)
  Definition SKp (pool : block) : Prop :=
    forall ch k off, (96 <= off \/ (4 <= off /\ off + size_chunk ch <= 16)) -> off + size_chunk ch <= OW.OSZ ->
      (off + size_chunk ch <= 532 \/ 536 <= off) ->
      Mem.load ch m' pool (k * OW.OSZ + off) = Mem.load ch m pool (k * OW.OSZ + off).

  Lemma SKp_full : forall pool, (forall ch z, Mem.load ch m' pool z = Mem.load ch m pool z) -> SKp pool.
  Proof. intros pool K ch k off _ _ _. apply K. Qed.

  Ltac sk_side := unfold OW.O_BHV, OW.O_CMD, OW.O_SIDX, OW.O_STK, OW.O_ACTION, OW.O_HSCOUNT,
    OW.O_FLAGS, OW.O_NEXT, OW.O_PREV, OW.OSZ, O_INTERACT_TYPE, O_POSX, O_POSY, O_POSZ, HITBOX_DOWN_OFF,
    HITBOX_H_OFF, RAW_OFF, OW.O_RTYPE, OW.O_RINFO, OW.G_PREV, OW.G_NEXT, OW.G_PAR in *; cbn [size_chunk]; lia.

  Lemma ld32_sk : forall pool, SKp pool -> forall k off, 96 <= off -> off + 4 <= OW.OSZ ->
    (off + 4 <= 532 \/ 536 <= off) ->
    OW.ld32 m' pool (k * OW.OSZ + off) = OW.ld32 m pool (k * OW.OSZ + off).
  Proof. intros pool SK k off H1 H2 H3. unfold OW.ld32. rewrite !CM.load_eq. apply SK; [ left; exact H1 | exact H2 | exact H3 ]. Qed.

  Lemma ring_from_eq : forall pool hb, SKp pool ->
    (forall z, OW.ld32 m' hb z = OW.ld32 m hb z) ->
    forall n ho prev cur, OW.ring_from m' pool hb ho prev cur n = OW.ring_from m pool hb ho prev cur n.
  Proof.
    intros pool hb SK Kh n. induction n as [| n IH]; intros ho prev cur; cbn [OW.ring_from]; [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b hb && Z.eqb (Ptrofs.unsigned i) ho); [ rewrite Kh; reflexivity | ].
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
    destruct (slot_of_eq _ _ E) as (Eo & _). rewrite Eo.
    rewrite !(ld32_sk pool SK) by sk_side.
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_PREV)); [ | reflexivity ].
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
    destruct (OW.veqb v prev); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Lemma rings_eq : forall pool la, SKp pool -> (forall z, OW.ld32 m' la z = OW.ld32 m la z) ->
    OW.rings m' pool la = OW.rings m pool la.
  Proof.
    intros pool la SK Kl. unfold OW.rings.
    assert (E : map (OW.ring_i m' pool la) (seq 0 OW.NLIST) = map (OW.ring_i m pool la) (seq 0 OW.NLIST)).
    { apply map_ext. intros i. unfold OW.ring_i. rewrite Kl.
      destruct (OW.ld32 m la (Z.of_nat i * OW.NODESZ + OW.O_NEXT)); [ | reflexivity ].
      apply ring_from_eq; assumption. }
    rewrite E. reflexivity.
  Qed.

  Lemma free_from_eq : forall pool, SKp pool ->
    forall n cur, OW.free_from m' pool cur n = OW.free_from m pool cur n.
  Proof.
    intros pool SK n. induction n as [| n IH]; intros cur; cbn [OW.free_from]; [ reflexivity | ].
    destruct (OW.veqb cur Vnullptr); [ reflexivity | ].
    destruct cur; try reflexivity.
    destruct (eq_block b pool); [ | reflexivity ].
    destruct (OW.slot_of (Ptrofs.unsigned i)) eqn:E; [ | reflexivity ].
    destruct (slot_of_eq _ _ E) as (Eo & _). rewrite Eo.
    rewrite (ld32_sk pool SK) by sk_side.
    destruct (OW.ld32 m pool (z * OW.OSZ + OW.O_NEXT)); [ | reflexivity ].
    rewrite IH. reflexivity.
  Qed.

  Section POOL.
    Variables (ge : genv) (pool : block).
    Hypothesis Kp : SKp pool.

    Lemma is_bhv_eq : forall k id, OW.is_bhv ge pool m k id -> OW.is_bhv ge pool m' k id.
    Proof. intros k id (b & Hs & L). exists b. rewrite Kp by sk_side. exact (conj Hs L). Qed.

    Lemma is_bhv_eq' : forall k id, OW.is_bhv ge pool m' k id -> OW.is_bhv ge pool m k id.
    Proof. intros k id (b & Hs & L). exists b. rewrite Kp in L by sk_side. exact (conj Hs L). Qed.

    Lemma script_eq : forall k, OW.script_ok ge pool m k -> OW.script_ok ge pool m' k.
    Proof.
      intros k (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kp by sk_side. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma script12_eq : forall k, OW.script12_ok ge pool m k -> OW.script12_ok ge pool m' k.
    Proof.
      intros k (id & b & o & Hin & Hs & L). exists id, b, o. rewrite Kp by sk_side. exact (conj Hin (conj Hs L)).
    Qed.

    Lemma vm_eq : forall k, OW.vm_ok ge pool m k -> OW.vm_ok ge pool m' k.
    Proof.
      intros k (st & Hin & (b & Hs & L1) & L2 & F). exists st.
      pose proof (vm_depth st Hin) as Dp.
      split; [ exact Hin | split; [ exists b; rewrite Kp by sk_side; exact (conj Hs L1) | split ] ].
      - rewrite Kp by sk_side. exact L2.
      - intros n f Hn. pose proof (F n f Hn) as Fn.
        assert (Hlt : (n < List.length (BhvVM.v_k st))%nat) by (apply nth_error_Some; congruence).
        unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
        rewrite Kp by sk_side. exact Fn.
    Qed.

    (* 3h: a named VM state at a slot (the cells 460..500) *)
    Lemma vm_at_eq : forall k st, In st BhvVM.vm_tab -> OW.vm_at ge pool m k st -> OW.vm_at ge pool m' k st.
    Proof.
      intros k st Hin ((b & Hs & L1) & L2 & F).
      pose proof (vm_depth st Hin) as Dp.
      split; [ exists b; rewrite Kp by sk_side; exact (conj Hs L1) | split ].
      - rewrite Kp by sk_side. exact L2.
      - intros n f Hn. pose proof (F n f Hn) as Fn.
        assert (Hlt : (n < List.length (BhvVM.v_k st))%nat) by (apply nth_error_Some; congruence).
        unfold OW.stk_cell in *. rewrite <- Z.add_assoc in *.
        rewrite Kp by sk_side. exact Fn.
    Qed.

    Lemma sp_vm_eq : forall k, OW.sp_vm ge pool m k -> OW.sp_vm ge pool m' k.
    Proof.
      intros k (st & Hin & Hsp & V). exists st. exact (conj Hin (conj Hsp (vm_at_eq k st Hin V))).
    Qed.

    Lemma act_eq : forall k, OW.act_ok ge pool m k -> OW.act_ok ge pool m' k.
    Proof.
      intros k H bh t Hin Hb. destruct (H bh t Hin (is_bhv_eq' k bh Hb)) as (a & La & R).
      exists a. rewrite Kp by sk_side. exact (conj La R).
    Qed.

    Lemma kind_eq : forall k, OW.kind_ok pool m k -> OW.kind_ok pool m' k.
    Proof. exact (OW.kind_ok_eq pool m m' (fun ch k off H1 => Kp ch k off (or_introl H1))). Qed.

    Lemma red_eq : forall k, OW.red_ok ge pool m k -> OW.red_ok ge pool m' k.
    Proof.
      intros k (N & R). split.
      - intros Hb. exact (N (is_bhv_eq' k _ Hb)).
      - intros Hb. destruct (R (is_bhv_eq' k _ Hb)) as (c & Lc & Rc). exists c. rewrite Kp by sk_side. exact (conj Lc Rc).
    Qed.

    (* the surface budget (ObjWorld 3c): the script a slot runs and its
       collisionData (offsets 460, 536) *)
    Lemma runs_eq : forall k id, OW.runs ge pool m' k id = OW.runs ge pool m k id.
    Proof. intros k id. unfold OW.runs. rewrite (ld32_sk pool Kp) by (unfold OW.O_CMD, OW.OSZ; lia). reflexivity. Qed.

    Lemma sdyn_eq : forall k, OW.sdyn ge pool m' k = OW.sdyn ge pool m k.
    Proof. intros k. unfold OW.sdyn. rewrite !runs_eq. reflexivity. Qed.

    Lemma coll_pin_eq : forall k, OW.coll_pin ge pool m k -> OW.coll_pin ge pool m' k.
    Proof.
      intros k (C1 & C2). unfold OW.coll_pin. rewrite !runs_eq.
      rewrite (Kp Mint32 k OW.O_COLL) by (unfold OW.O_COLL, OW.OSZ; cbn [size_chunk]; lia).
      exact (conj C1 C2).
    Qed.
  End POOL.

  (* the surface clauses (ObjWorld 3b): a global's cell, the list walks
     (dynamic blocks only), a surface's object (a dynamic block and the
     slot's angle velocity, offsets 276..287) *)
  Lemma gcell_K : forall (ge : genv) id ch v,
    (forall b, Genv.find_symbol ge id = Some b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.gcell ge id ch v m -> OW.gcell ge id ch v m'.
  Proof. intros ge id ch v K (b & Hs & L). exists b. rewrite (K b Hs). exact (conj Hs L). Qed.

  (* a listed slot's angle velocity (offsets 276..287) is a slot field
     past 96 *)
  Lemma angv_sk : forall pool, SKp pool -> forall k j, 0 <= k < OW.NSLOT -> In j OW.ANGV ->
    Mem.load Mint32 m' pool (k * OW.OSZ + RAW_OFF + 4 * j) = Mem.load Mint32 m pool (k * OW.OSZ + RAW_OFF + 4 * j).
  Proof.
    intros pool Kp k j _ Hj. rewrite <- Z.add_assoc.
    apply Kp; unfold OW.OSZ, RAW_OFF; cbn [size_chunk];
      unfold OW.ANGV in Hj; cbn [In] in Hj; destruct Hj as [<- | [<- | [<- | []]]]; lia.
  Qed.

  Lemma is_bhv_b_eq : forall ge pool id k, SKp pool ->
    OW.is_bhv_b ge pool m' id k = OW.is_bhv_b ge pool m id k.
  Proof.
    intros ge pool id k Kp. unfold OW.is_bhv_b. rewrite (ld32_sk pool Kp) by sk_side. reflexivity.
  Qed.

  (* THE LEMMA, slot-field form: obj_w survives any change off its globals'
     blocks (the pool: off every slot's fields from offset 96 on) and off
     Mario's five object-pointer cells *)
  (* the surface clause (ObjWorld.surf_obj_ok) is kept: from "no non-symbol
     block changes" (surf_keep_of_KN), or stated by a row *)
  (* 2026-11-03 (3h): with the walk half of the class tie (OW.cls_surf_at),
     which reads what surf_obj_ok reads (OW.cls_surf_ext: the same keep) *)
  Definition surf_keep (ge : genv) : Prop :=
    forall pool, Genv.find_symbol ge object_list_processor._gObjectPool = Some pool ->
      (OW.surf_obj_ok ge pool m -> OW.surf_obj_ok ge pool m')
      /\ (forall mv, OW.cls_surf_at ge pool m mv -> OW.cls_surf_at ge pool m' mv).

  Lemma surf_keep_of_KN : forall (ge : genv),
    (forall id b, In id ow_ids -> id <> object_list_processor._gObjectPool -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall pool, Genv.find_symbol ge object_list_processor._gObjectPool = Some pool -> SKp pool) ->
    (forall b, Ple (Genv.genv_next ge) b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    surf_keep ge.
  Proof.
    intros ge KG KP KN pool S1. assert (Kp := KP pool S1).
    assert (KG' : forall id b, In id OW.surf_gids -> Genv.find_symbol ge id = Some b ->
                    forall ch z, Mem.load ch m' b z = Mem.load ch m b z).
    { intros id b Hin Hs. apply (KG id b); [ | | exact Hs ];
        unfold OW.surf_gids, FloorList.part_ids in Hin; cbn [In] in Hin;
        destruct Hin as [<- | [<- | [<- | [<- | []]]]];
        first [ solve [ unfold ow_ids; cbn [In]; repeat (first [ left; reflexivity | right ]) ]
              | vm_compute; discriminate ]. }
    split.
    - intros Cso. apply (OW.surf_obj_ok_ext ge pool m m'); [ exact KG' | | exact (angv_sk pool Kp) | exact Cso ].
      intros P HP _ _ ch z _. exact (KN P HP ch z).
    - intros mv. apply (OW.cls_surf_ext ge pool m m' mv KG').
      intros P HP _ _ ch z _. exact (KN P HP ch z).
  Qed.

  Theorem obj_w_slots_g : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> existsb (Pos.eqb id) ow_xc = false -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall pool, Genv.find_symbol ge object_list_processor._gObjectPool = Some pool -> SKp pool) ->
    surf_keep ge ->
    (* the surface counter (ow_ctr): kept, or re-made by the writer *)
    (OW.ctr_s_ok ge m -> OW.ctr_s_ok ge m') ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (* no store into a script block (ow_scr, 2026-11-03) *)
    (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K KP KS KC Kbm KSc (pool & la & fl & gol & gmo & sdp & gdi & rs & fs & S1 & S2 & S3 & S4 & S5 & S6 & S7 & C).
    assert (Kp := KP pool S1).
    assert (Kl := K object_list_processor._gObjectListArray la ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S2).
    assert (Kf := K object_list_processor._gFreeObjectList fl ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S3).
    assert (Kg := K object_list_processor._gObjectLists gol ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S4).
    assert (Km := K object_list_processor._gMarioObject gmo ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S5).
    assert (Ks := K debug._sDebugPage sdp ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S6).
    assert (Kd := K debug._gDebugInfo gdi ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) S7).
    exists pool, la, fl, gol, gmo, sdp, gdi, rs, fs.
    refine (conj S1 (conj S2 (conj S3 (conj S4 (conj S5 (conj S6 (conj S7 _))))))).
    destruct C as [Cg Cr Cf Cp Cfo Cm Cs Ca Crd Cdb Cst Co Cd12 Cct Cvm Csp Cso Cco Cctr Cter Cscr Cmact Cresp Cgfx Cmsurf Cpar
                   Cmvm Canim Ccls Cdp Cnco Cmco].
    assert (KG : forall id, In id ow_ids -> existsb (Pos.eqb id) ow_xc = false ->
               forall b, Genv.find_symbol ge id = Some b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z)
      by (intros id Hin Hn b Hs; exact (K id b Hin Hn Hs)).
    constructor.
    - rewrite Kg. exact Cg.
    - rewrite (rings_eq pool la Kp (ld32_eq la Kl)). exact Cr.
    - unfold OW.free_list in *. rewrite (ld32_eq fl Kf).
      destruct (OW.ld32 m fl OW.O_NEXT); [ | discriminate Cf ].
      rewrite (free_from_eq pool Kp). exact Cf.
    - exact Cp.
    - intros k Hk. rewrite Kp by sk_side. exact (Cfo k Hk).
    - destruct Cm as (k & Hk & Lg & Lb & Kd').
      exists k. split; [ exact Hk | split; [ rewrite Km; exact Lg | split ] ].
      + rewrite (Kbm _ (or_introl eq_refl)). exact Lb.
      + intros j Hj Ne. exact (kind_eq pool Kp j (Kd' j Hj Ne)).
    - intros k Hk. exact (script_eq ge pool Kp k (Cs k Hk)).
    - intros k Hk. exact (act_eq ge pool Kp k (Ca k Hk)).
    - intros k Hk. exact (red_eq ge pool Kp k (Crd k Hk)).
    - rewrite Ks, Kd. exact Cdb.
    - intros z Hz. assert (Hz' : In z [120; 124; 128; 132; 96; 100; 104]) by (cbn [In] in Hz |- *; tauto).
      rewrite (Kbm z (or_intror Hz')). exact (Cst z Hz).
    - destruct Co as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j Hj. rewrite (K object_list_processor._sObjectListUpdateOrder b ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) Sb). exact (L j Hj).
    - intros k Hk. exact (script12_eq ge pool Kp k (Cd12 k Hk)).
    - destruct Cct as (b & Sb & L). exists b. split; [ exact Sb | ].
      intros j id Hj. rewrite (K behavior_script._BehaviorCmdTable b ltac:(unfold ow_ids; cbn [In]; auto 10) ltac:(vm_compute; reflexivity) Sb). exact (L j id Hj).
    - intros k Hk. exact (vm_eq ge pool Kp k (Cvm k Hk)).
    - destruct Csp as (P & HP & G1 & G2 & G3 & G4 & G5). exists P. split; [ exact HP | ].
      assert (Kc : forall id, In id ow_ids -> existsb (Pos.eqb id) ow_xc = false ->
                 forall ch v, OW.gcell ge id ch v m -> OW.gcell ge id ch v m')
        by (intros id Hin Hn ch v; apply gcell_K; exact (KG id Hin Hn)).
      split; [ | split; [ | split; [ | split ] ] ];
        (apply Kc; [ unfold ow_ids; cbn [In]; auto 20 | vm_compute; reflexivity | assumption ]).
    - exact (proj1 (KS pool S1) Cso).
    - destruct Cco as (C1 & C2 & C3).
      assert (Ef : forall id, filter (OW.is_bhv_b ge pool m' id) (concat rs) = filter (OW.is_bhv_b ge pool m id) (concat rs))
        by (intros id; apply filter_ext; intros k; exact (is_bhv_b_eq ge pool id k Kp)).
      split; [ rewrite Ef; exact C1 | split; [ rewrite Ef; exact C2 | ] ].
      intros k Hk Hb. rewrite (is_bhv_b_eq ge pool _ k Kp) in Hb.
      destruct (C3 k Hk Hb) as (x & y & z & Hin & L1 & L2 & L3).
      unfold OW.box_pos_ok. exists x, y, z. rewrite !Kp by sk_side. exact (conj Hin (conj L1 (conj L2 L3))).
    - exact (KC Cctr).
    - destruct Cter as (T1 & T2 & T3 & T4 & T5 & T6).
      assert (Kme : forall id l, In id ow_ids -> existsb (Pos.eqb id) ow_xc = false ->
                 OW.mesh_ok ge id l m -> OW.mesh_ok ge id l m').
      { intros id l Hin Hn (b & Hs & L). exists b. split; [ exact Hs | ].
        intros j x Hj. rewrite (KG id Hin Hn b Hs). exact (L j x Hj). }
      split; [ | split; [ | split; [ | split; [ | split ] ] ] ].
      + intros i k Hk. rewrite (sdyn_eq ge pool Kp). exact (T1 i k Hk).
      + intros i k Hi Hk. rewrite !(runs_eq ge pool Kp). exact (T2 i k Hi Hk).
      + rewrite (map_ext _ _ (sdyn_eq ge pool Kp)). exact T3.
      + intros k Hk. exact (coll_pin_eq ge pool Kp k (T4 k Hk)).
      + apply Kme; [ unfold ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact T5 ].
      + apply Kme; [ unfold ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact T6 ].
    - exact (OW.scr_ok_ext ge m m' KSc Cscr).
    - (* 3e: Mario's flags, command and stack: slot fields past 96 *)
      intros k Hk Lg. rewrite Km in Lg.
      destruct (Cmact k Hk Lg) as ((f & Lf & Ef) & (b & Sb & (o & Lc) & Lst)).
      split; [ exists f; rewrite Kp by sk_side; exact (conj Lf Ef) | exists b; split; [ exact Sb | split ] ].
      + exists o. rewrite Kp by sk_side. exact Lc.
      + intros d n Ld Hn. rewrite Kp in Ld by sk_side.
        pose proof (Lst d n Ld Hn) as Hs. rewrite <- !Z.add_assoc in Hs |- *.
        rewrite !Kp by sk_side. exact Hs.
    - (* 3e: respawn targets: slot fields past 96, the main-pool cell *)
      intros j Hj. destruct (Cresp j Hj) as (t & Lt & R1 & R2). exists t.
      split; [ rewrite Kp by sk_side; exact Lt | split ].
      + intros Et. destruct (R1 Et) as (b & o & Lr & Hor). exists b, o.
        split; [ rewrite Kp by sk_side; exact Lr | ].
        destruct Hor as [Hor | (Hg & Hin)]; [ left; exact Hor | right; split; [ | exact Hin ] ].
        apply gcell_K; [ | exact Hg ].
        apply (KG surface_load._sSurfacePool); [ unfold ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity ].
      + intros Et. destruct (R2 Et) as (b & o & Lr & Hor). exists b, o.
        rewrite Kp by sk_side. exact (conj Lr Hor).
    - (* 3e: the graph links: slot words [4, 16) and the parent's children *)
      intros bpg Hbpg. destruct (Cgfx bpg Hbpg) as (G1 & G2).
      assert (Kb := KG area._gObjParentGraphNode ltac:(unfold ow_ids; cbn [In]; auto 30) ltac:(vm_compute; reflexivity) bpg Hbpg).
      split.
      + intros k Hk. destruct (G1 k Hk) as (P1 & P2 & P3).
        unfold OW.G_PAR, OW.G_PREV, OW.G_NEXT in *. rewrite !Kp by sk_side. exact (conj P1 (conj P2 P3)).
      + rewrite !Kb. exact G2.
    - (* 3f: Mario's three surface cells and the pool pin *)
      intros z v Hz L. assert (Hz' : In z [120; 124; 128; 132; 96; 100; 104])
        by (unfold OW.MSURF, WALL_OFF, CEIL_OFF, FLOOR_OFF in Hz; cbn [In] in Hz |- *; tauto).
      rewrite (Kbm z (or_intror Hz')) in L.
      destruct (Cmsurf z v Hz L) as [E | (b & o & E & Hs)]; [ left; exact E | right ].
      exists b, o. split; [ exact E | ]. intros P (s & Ss & Ls). apply Hs. exists s. split; [ exact Ss | ].
      rewrite <- Ls. symmetry.
      apply (KG surface_load._sSurfacePool); [ unfold ow_ids; cbn [In]; auto 30 | vm_compute; reflexivity | exact Ss ].
    - (* 3g: the parents: slot word 104 *)
      destruct Cpar as (P1 & P2). split.
      + intros k Hk. unfold OW.O_PARENT in *. rewrite Kp by sk_side. exact (P1 k Hk).
      + intros k id Hk Hid Hr. rewrite (runs_eq ge pool Kp) in Hr. unfold OW.O_PARENT in *. rewrite Kp by sk_side.
        exact (P2 k id Hk Hid Hr).
    - (* 3h: Mario's VM cells, slot fields 460.. *)
      intros k Hk Lg. rewrite Km in Lg. destruct (Cmvm k Hk Lg) as (st & Hin & Hs & V).
      exists st. exact (conj Hin (conj Hs (vm_at_eq ge pool Kp k st Hin V))).
    - (* 3h: the animation blocks, listed in ow_ids *)
      apply (OW.anim_ok_ext ge m m'); [ | exact Canim ].
      intros t b Ht Hs. destruct (anim_in_ow t Ht) as (H1 & H2). exact (KG t H1 H2 b Hs).
    - (* 3h: the class tie: interactType and VM cells are slot fields; the
         walk half as the surface clause (KS) *)
      destruct Ccls as (T1 & T2). split.
      + intros k t Hk L Ht. rewrite Kp in L by sk_side. exact (sp_vm_eq ge pool Kp k (T1 k t Hk L Ht)).
      + intros P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo.
        apply (sp_vm_eq ge pool Kp k).
        exact (proj2 (KS pool S1) m T2 P id bp z hd l o k HP G1 G2 Hin Hs L Hw Ho N Hk Lo).
    - (* 3i: the droplet parameter structs, listed in ow_ids *)
      apply (OW.dp_ok_ext ge m m'); [ | exact Cdp ].
      intros p b Hp Hs.
      assert (A : forallb (fun t => existsb (Pos.eqb t) ow_ids && negb (existsb (Pos.eqb t) ow_xc)) OW.dparams = true)
        by (vm_compute; reflexivity).
      pose proof (proj1 (forallb_forall _ _) A p Hp) as E. apply andb_prop in E as [E1 E2].
      apply existsb_exists in E1 as (x & Hx & Ex). apply Pos.eqb_eq in Ex. subst x.
      exact (KG p Hx (proj1 (negb_true_iff _) E2) b Hs).
    - (* 3j: numCollidedObjs, a slot field past 96 *)
      intros k Hk. destruct (Cnco k Hk) as (n & Ln & Rn). exists n.
      unfold OW.O_NCOLL in *. rewrite Kp by sk_side. exact (conj Ln Rn).
    - (* 3j: Mario's collidedObjs, slot fields 120..136 *)
      intros k Hk Lg i Hi. rewrite Km in Lg. destruct (Cmco k Hk Lg i Hi) as (v & Lv & Sv).
      exists v. unfold OW.O_COLLS in *. rewrite <- !Z.add_assoc in Lv |- *.
      rewrite Kp by (cbn [size_chunk]; unfold OW.OSZ; lia). exact (conj Lv Sv).
  Qed.

  (* THE LEMMA, slot-field form: obj_w survives any change off its globals'
     blocks (the pool: off every slot's fields from offset 96 on) and off
     Mario's five object-pointer cells, with the surface clause's keep *)
  Theorem obj_w_slots_s : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> id <> object_list_processor._gObjectPool -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall pool, Genv.find_symbol ge object_list_processor._gObjectPool = Some pool -> SKp pool) ->
    surf_keep ge ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (* no store into a script block (ow_scr, 2026-11-03) *)
    (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K KP KS Kbm KSc. apply obj_w_slots_g; [ | exact KP | exact KS | | exact Kbm | exact KSc ].
    - intros id b Hin Hn Hs. apply (K id b Hin); [ | exact Hs ]. intros ->. vm_compute in Hn. discriminate Hn.
    - intros (a & Hg & Hb). exists a. split; [ | exact Hb ]. apply gcell_K; [ | exact Hg ].
      intros b Hs. apply (K surface_load._gSurfacesAllocated b); [ unfold ow_ids; cbn [In]; auto 30 | | exact Hs ].
      vm_compute. discriminate.
  Qed.

  (* THE LEMMA, slot-field form: obj_w survives any change off its globals'
     blocks (the pool: off every slot's fields from offset 96 on), off the
     non-symbol blocks, and off Mario's five object-pointer cells *)
  Theorem obj_w_slots : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> id <> object_list_processor._gObjectPool -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall pool, Genv.find_symbol ge object_list_processor._gObjectPool = Some pool -> SKp pool) ->
    (* no non-symbol block changes (the main pool: the surface pools) *)
    (forall b, Ple (Genv.genv_next ge) b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (* no store into a script block (ow_scr, 2026-11-03) *)
    (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K KP KN Kbm KSc. apply obj_w_slots_s; [ exact K | exact KP | | exact Kbm | exact KSc ].
    exact (surf_keep_of_KN ge K KP KN).
  Qed.

  (* the same with the surface clause's keep given (a row's footprint) *)
  Theorem obj_w_unch_s : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    surf_keep ge ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (* no store into a script block (ow_scr, 2026-11-03) *)
    (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K KS Kbm KSc. apply obj_w_slots_s; [ | | exact KS | exact Kbm | exact KSc ].
    - intros id b Hin _ Hs. exact (K id b Hin Hs).
    - intros pool Hs. apply SKp_full. apply (K object_list_processor._gObjectPool pool); [ unfold ow_ids; cbn [In]; auto 10 | exact Hs ].
  Qed.

  (* THE LEMMA: obj_w survives any change off its globals' blocks and off
     Mario's five object-pointer cells *)
  Theorem obj_w_unch : forall (ge : genv) bm,
    (forall id b, In id ow_ids -> Genv.find_symbol ge id = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall b, Ple (Genv.genv_next ge) b -> forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    (forall z, z = MARIOOBJ_OFF \/ In z [120; 124; 128; 132; 96; 100; 104] ->
       Mem.load Mint32 m' bm z = Mem.load Mint32 m bm z) ->
    (* no store into a script block (ow_scr, 2026-11-03) *)
    (forall s b, In s (map BhvVM.v_s BhvVM.vm_tab) -> Genv.find_symbol ge s = Some b ->
       forall ch z, Mem.load ch m' b z = Mem.load ch m b z) ->
    OW.obj_w ge bm m -> OW.obj_w ge bm m'.
  Proof.
    intros ge bm K KN Kbm KSc. apply obj_w_slots; [ | | exact KN | exact Kbm | exact KSc ].
    - intros id b Hin _ Hs. exact (K id b Hin Hs).
    - intros pool Hs. apply SKp_full. apply (K object_list_processor._gObjectPool pool); [ unfold ow_ids; cbn [In]; auto 10 | exact Hs ].
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
    (forall id, In id Xs -> existsb (Pos.eqb id) lvl_rd_ids = false) ->
    fx lp bm Xs m m' -> lvl_w G m -> lvl_w G m'.
  Proof. exact (LevelKeep.lvl_w_fx lp bm Hbm_sym). Qed.

  Lemma fx_obj_w : forall Xs m m',
    (forall id, In id ow_ids -> existsb (Pos.eqb id) Xs = false) ->
    existsb (Pos.eqb level_update._gMarioStates) Xs = false ->
    (* 2026-11-03: and no script block (ow_scr) *)
    (forall id, In id (map BhvVM.v_s BhvVM.vm_tab) -> existsb (Pos.eqb id) Xs = false) ->
    fx lp bm Xs m m' -> OW.obj_w G bm m -> OW.obj_w G bm m'.
  Proof.
    intros Xs m m' HX Hn HS Hfx. apply obj_w_unch.
    - intros id b Hin Hs ch z. apply (fx_load lp bm Xs m m' ch b z Hfx).
      intros i _ [Hb | (-> & _)].
      + exact (LevelKeep.not_lvl lp Xs id b Hs (HX id Hin) Hb).
      + assert (E : id = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbm_sym ]).
        subst id. unfold ow_ids in Hin. cbn [In] in Hin.
        repeat (destruct Hin as [E | Hin]; [ vm_compute in E; discriminate E | ]). exact Hin.
    - intros b Hb ch z. apply (fx_load lp bm Xs m m' ch b z Hfx).
      intros i _ [(id & _ & Hs) | (-> & _)].
      + pose proof (Genv.genv_symb_range _ _ Hs) as R. unfold Plt, Ple in *. lia.
      + pose proof (Genv.genv_symb_range _ _ Hbm_sym) as R. unfold Plt, Ple in *. lia.
    - intros z Hz. apply (fx_load lp bm Xs m m' Mint32 bm z Hfx).
      intros i Hi [Hb | (_ & Hc)].
      + exact (LevelKeep.not_lvl lp Xs _ bm Hbm_sym Hn Hb).
      + cbn [size_chunk] in Hi. unfold MARIOOBJ_OFF in Hz. cbn [In] in Hz. lia.
    - intros id b Hin Hs ch z. apply (fx_load lp bm Xs m m' ch b z Hfx).
      intros i _ [Hb | (-> & _)].
      + exact (LevelKeep.not_lvl lp Xs id b Hs (HS id Hin) Hb).
      + assert (E : id = level_update._gMarioStates) by (eapply Genv.genv_vars_inj; [ exact Hs | exact Hbm_sym ]).
        subst id. exact (not_in_of_existsb _ _ scr_not_ms Hin).
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
      exact (lvl_w_fx0 srd_gvars m i (avoid_of srd_gvars lvl_rd_ids ltac:(vmr)) Hfx Hl).
    - exact (LevelKeep.fx_plat_still lp bm Hbm_sym srd_gvars m i ltac:(vmr) ltac:(vmr) Hfx).
    - exact (fx_obj_w srd_gvars m i (avoid_of ow_ids srd_gvars ltac:(vmr)) ltac:(vmr)
               (avoid_of (map BhvVM.v_s BhvVM.vm_tab) srd_gvars ltac:(vmr)) Hfx).
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
      exact (LevelKeep.lvl_w_ctl lp bm Hbm_sym PollFlank.rci_gvars i m0 HX
        (avoid_of PollFlank.rci_gvars cam_rd_ids ltac:(vm_compute; reflexivity))
        (avoid_of PollFlank.rci_gvars aud_ls_ids ltac:(vm_compute; reflexivity)) Hl Hfx Hcw').
    - exact (LevelKeep.fx_plat_still lp bm Hbm_sym PollFlank.rci_gvars i m0 ltac:(vmr) ltac:(vmr) Hfx).
    - exact (fx_obj_w PollFlank.rci_gvars i m0 (avoid_of ow_ids PollFlank.rci_gvars ltac:(vmr)) ltac:(vmr)
               (avoid_of (map BhvVM.v_s BhvVM.vm_tab) PollFlank.rci_gvars ltac:(vmr)) Hfx).
  Qed.
End LINK.
