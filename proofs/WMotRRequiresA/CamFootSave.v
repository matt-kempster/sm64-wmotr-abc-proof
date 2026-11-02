(* spine (via CamFootInst): the save leaf of the camera footprint, proved
   from the real bodies of save_file_do_save's whole call tree. *)
(* ====================================================================== *)
(* CamFootSave.v -- save_file_do_save's FOOTPRINT, for ANY argument.      *)
(*                                                                        *)
(* The camera reaches save_file_do_save from a cutscene (CamFootInst).    *)
(* GOAL 1 proved the call keeps its carried facts (SaveDoSaveBody); the   *)
(* camera's footprint needs where it writes.  This file walks the same    *)
(* call tree with FootWalk (SaveDoSaveBody's recognizers over a LISTED    *)
(* footprint):                                                            *)
(*   save_file.c : save_file_do_save -> add_save_block_signature          *)
(*                 (-> calc_checksum), bcopy, write_eeprom_data,          *)
(*                 save_main_menu_data;                                   *)
(*                 write_eeprom_data -> osEepromLongWrite;                *)
(*   libultra    : osEepromLongWrite -> osEepromWrite, osSetTimer,        *)
(*                 osRecvMesg; osEepromWrite -> __osSiGetAccess,          *)
(*                 __osEepStatus, __osPackEepWriteData, __osSiRawStartDma,*)
(*                 osRecvMesg, __osSiRelAccess; __osSiGetAccess ->        *)
(*                 __osSiCreateAccessQueue (-> osCreateMesgQueue,         *)
(*                 osSendMesg), osRecvMesg; __osSiRelAccess -> osSendMesg.*)
(* THEOREM (sds_foot): the call changes memory only in the blocks of      *)
(* sds_gvars (the save buffer and its two dirty flags, the EEPROM PIF     *)
(* image and last-command byte,                                          *)
(* image, the SI access queue and its buffer, the SI event queue, the     *)
(* EEPROM timer, its queue and message), keeps every old permission and  *)
(* leaves every new block permissionless (PermWalk).  The floor calls are *)
(* OsDmaFloor's (TRUST 3.5): osRecvMesg / osSendMesg on a listed queue,   *)
(* __osSiRawStartDma into the PIF image, osSetTimer on __osEepromTimer,   *)
(* bcopy into the save buffer.  NO new premise.                           *)
(* ====================================================================== *)

From Coq Require Import ZArith List Lia Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clight ClightBigstep Linking.
From SM64.Generated Require memory save_file libultra_osEepromWrite libultra_osEepromLongWrite
  libultra_osSiCreateAccessQueue libultra_osCreateMesgQueue libultra_osContInit.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked LinkedTwelve OsDmaFloor
  CensusV2 Generic.PermWalk.
From SM64.Proofs Require MtxfBody MathGeomBodies SaveDoSaveBody.
From SM64.Proofs.WMotRRequiresA Require FootWalk PollKeep.
Import ListNotations.
Local Open Scope Z_scope.

Module SDB := SaveDoSaveBody.
Module SF := save_file.
Module EW := libultra_osEepromWrite.
Module ELW := libultra_osEepromLongWrite.
Module SQ := libultra_osSiCreateAccessQueue.
Module MQ := libultra_osCreateMesgQueue.

(* the globals the tree writes *)
Definition sds_gvars : list ident :=
  [SF._gSaveBuffer; SF._gSaveFileModified; SF._gMainMenuDataModified; EW.___osEepPifRam;
   EW.___osContLastCmd;
   SQ._gOsSiAccessQueueCreated; SQ._gOsSiMessageQueue; SQ._osSiMesgBuff;
   SF._gSIEventMesgQueue; ELW.___osEepromTimerQ; ELW.___osEepromTimerMsg; ELW.___osEepromTimer].

(* ---------------------------------------------------------------------- *)
(* 1. The footprint walk, bottom up.                                       *)
(* ---------------------------------------------------------------------- *)
Section SDF.
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

  Notation fpF := (FootWalk.fpF lp sds_gvars m0).
  Notation body := (FootWalk.body_fpF lp H12 Hfloor sds_gvars m0).

  Lemma ct_nil : FootWalk.ctab_ok lp sds_gvars m0 [].
  Proof. intros ? ? ? ? H. discriminate H. Qed.

  Lemma sw_cmq : fpF MQ.f_osCreateMesgQueue [] [].
  Proof. apply (body _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma sw_csq : fpF SQ.f___osSiCreateAccessQueue [] [].
  Proof.
    apply (body _ _ _ SDB.ct_csq); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_csq. split; [ res MQ.prog linked12_LO_ultra_cmq | exact sw_cmq ].
  Qed.

  Lemma sw_ga : fpF SQ.f___osSiGetAccess [SQ._t'1] [].
  Proof.
    apply (body _ _ _ SDB.ct_ga); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_ga. split; [ res SQ.prog linked12_LO_ultra_si | exact sw_csq ].
  Qed.

  Lemma sw_ra : fpF SQ.f___osSiRelAccess [] [].
  Proof. apply (body _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma sw_pack : fpF EW.f___osPackEepWriteData [] [].
  Proof. apply (body _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma sw_st : fpF EW.f___osEepStatus SDB.fl_st SDB.qa_mq.
  Proof. apply (body _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma sw_ew : fpF EW.f_osEepromWrite SDB.fl_ew SDB.qa_mq.
  Proof.
    apply (body _ _ _ SDB.ct_ew); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_ew.
    - split; [ res SQ.prog linked12_LO_ultra_si | exact sw_ga ].
    - split; [ res EW.prog linked12_LO_ultra_ew | exact sw_st ].
    - split; [ res EW.prog linked12_LO_ultra_ew | exact sw_pack ].
    - split; [ res SQ.prog linked12_LO_ultra_si | exact sw_ra ].
  Qed.

  Lemma sw_elw : fpF ELW.f_osEepromLongWrite SDB.fl_elw SDB.qa_elw.
  Proof.
    apply (body _ _ _ SDB.ct_elw); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_elw. split; [ res EW.prog linked12_LO_ultra_ew | exact sw_ew ].
  Qed.

  Lemma sw_cs : fpF SF.f_calc_checksum [] [].
  Proof. apply (body _ _ _ []); [ vm_compute; reflexivity | exact ct_nil ]. Qed.

  Lemma sw_asig : fpF SF.f_add_save_block_signature [SF._t'1] [].
  Proof.
    apply (body _ _ _ SDB.ct_asig); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_asig. split; [ res SF.prog linked12_LO_save | exact sw_cs ].
  Qed.

  Lemma sw_wed : fpF SF.f_write_eeprom_data SDB.fl_wed [].
  Proof.
    apply (body _ _ _ SDB.ct_wed); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_wed. split; [ res ELW.prog linked12_LO_ultra_elw | exact sw_elw ].
  Qed.

  Lemma sw_mmd : fpF SF.f_save_main_menu_data [] [].
  Proof.
    apply (body _ _ _ SDB.ct_mmd); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_mmd.
    - split; [ res SF.prog linked12_LO_save | exact sw_asig ].
    - split; [ res SF.prog linked12_LO_save | exact sw_wed ].
  Qed.

  Lemma sw_sds : fpF SF.f_save_file_do_save SDB.fl_sds [].
  Proof.
    apply (body _ _ _ SDB.ct_sds); [ vm_compute; reflexivity | ].
    ct_ok SDB.ct_sds.
    - split; [ res SF.prog linked12_LO_save | exact sw_mmd ].
    - split; [ res SF.prog linked12_LO_save | exact sw_asig ].
    - split; [ res SF.prog linked12_LO_save | exact sw_wed ].
  Qed.
End SDF.

(* ---------------------------------------------------------------------- *)
(* 2. Permissions (PermWalk), bottom up.                                   *)
(* ---------------------------------------------------------------------- *)
Section SDP.
  Variable lp : Clight.program.
  Hypothesis H12 : linked12 lp.
  Hypothesis Hfloor : os_dma_floor.
  Notation G := (lp_ge lp).

  Notation ps_id := (PollKeep.ps_id lp).
  Notation pcons := (PollKeep.psym_cons lp).

  Lemma ps_timer : ps_id ELW._osSetTimer.
  Proof.
    apply (PollKeep.ps_ext lp H12 ELW.prog ELW._osSetTimer "osSetTimer" (linked12_LO_ultra_elw lp H12) eq_refl
             ltac:(vm_compute; reflexivity)).
    intros sg vargs m t vres m' Hx. destruct Hfloor as (_ & _ & _ & _ & Hst & _).
    destruct (Hst _ _ _ _ _ _ _ Hx) as (bt & ot & rest & _ & SP & _). exact SP.
  Qed.

  Lemma ps_bcopy : ps_id SF._bcopy.
  Proof.
    apply (PollKeep.ps_ext lp H12 SF.prog SF._bcopy "bcopy" (linked12_LO_save lp H12) eq_refl
             ltac:(vm_compute; reflexivity)).
    intros sg vargs m t vres m' Hx. destruct Hfloor as (_ & _ & _ & _ & _ & _ & Hbc).
    destruct (Hbc _ _ _ _ _ _ _ Hx) as (bs & os & bd & od & n & _ & _ & SP & _). exact SP.
  Qed.

  Notation recv := (PollKeep.ps_recv lp H12 Hfloor).
  Notation rawdma := (PollKeep.ps_rawdma lp H12 Hfloor).
  Notation ga := (PollKeep.ps_ga lp H12 Hfloor).
  Notation ra := (PollKeep.ps_ra lp H12 Hfloor).
  Notation nil0 := (PollKeep.psym_nil lp).

  Lemma ps_pack : ps_id EW.___osPackEepWriteData.
  Proof.
    apply (PollKeep.ps_int lp EW.prog _ EW.f___osPackEepWriteData (linked12_LO_ultra_ew lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] nil0). vm_compute. reflexivity.
  Qed.

  Lemma ps_st : ps_id EW.___osEepStatus.
  Proof.
    apply (PollKeep.ps_int lp EW.prog _ EW.f___osEepStatus (linked12_LO_ultra_ew lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [EW.___osSiRawStartDma; memory._osRecvMesg] (pcons _ _ rawdma (pcons _ _ recv nil0))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_ew : ps_id ELW._osEepromWrite.
  Proof.
    apply (PollKeep.ps_int lp EW.prog _ EW.f_osEepromWrite (linked12_LO_ultra_ew lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [EW.___osSiGetAccess; EW.___osEepStatus; EW.___osPackEepWriteData;
                      EW.___osSiRawStartDma; memory._osRecvMesg; EW.___osSiRelAccess]
             (pcons _ _ ga (pcons _ _ ps_st (pcons _ _ ps_pack (pcons _ _ rawdma
               (pcons _ _ recv (pcons _ _ ra nil0))))))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_elw : ps_id SF._osEepromLongWrite.
  Proof.
    apply (PollKeep.ps_int lp ELW.prog _ ELW.f_osEepromLongWrite (linked12_LO_ultra_elw lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [ELW._osEepromWrite; ELW._osSetTimer; memory._osRecvMesg]
             (pcons _ _ ps_ew (pcons _ _ ps_timer (pcons _ _ recv nil0)))).
    vm_compute. reflexivity.
  Qed.

  Lemma ps_cs : ps_id SF._calc_checksum.
  Proof.
    apply (PollKeep.ps_int lp SF.prog _ SF.f_calc_checksum (linked12_LO_save lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [] nil0). vm_compute. reflexivity.
  Qed.

  Lemma ps_asig : ps_id SF._add_save_block_signature.
  Proof.
    apply (PollKeep.ps_int lp SF.prog _ SF.f_add_save_block_signature (linked12_LO_save lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [SF._calc_checksum] (pcons _ _ ps_cs nil0)). vm_compute. reflexivity.
  Qed.

  Lemma ps_wed : ps_id SF._write_eeprom_data.
  Proof.
    apply (PollKeep.ps_int lp SF.prog _ SF.f_write_eeprom_data (linked12_LO_save lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [SF._osEepromLongWrite] (pcons _ _ ps_elw nil0)). vm_compute. reflexivity.
  Qed.

  Lemma ps_mmd : ps_id SF._save_main_menu_data.
  Proof.
    apply (PollKeep.ps_int lp SF.prog _ SF.f_save_main_menu_data (linked12_LO_save lp H12));
      [ vm_compute; reflexivity | ].
    apply (pk_body G [SF._add_save_block_signature; SF._write_eeprom_data; SF._bcopy]
             (pcons _ _ ps_asig (pcons _ _ ps_wed (pcons _ _ ps_bcopy nil0)))).
    vm_compute. reflexivity.
  Qed.

  Theorem PS_sds : PS G (Internal SF.f_save_file_do_save).
  Proof.
    apply (pk_body G [SF._save_main_menu_data; SF._add_save_block_signature; SF._write_eeprom_data; SF._bcopy]
             (pcons _ _ ps_mmd (pcons _ _ ps_asig (pcons _ _ ps_wed (pcons _ _ ps_bcopy nil0))))).
    vm_compute. reflexivity.
  Qed.

  (* ==================================================================== *)
  (* 3. THE RESULT: save_file_do_save(any) writes only sds_gvars' blocks.  *)
  (* ==================================================================== *)
  Theorem sds_foot : forall b fd m vargs t m' vres,
      Genv.find_symbol G SF._save_file_do_save = Some b ->
      Genv.find_funct G (Vptr b Ptrofs.zero) = Some fd ->
      eval_funcall function_entry2 G m fd vargs t m' vres ->
      PK m m' /\ Mem.unchanged_on (fun b _ => ~ FootWalk.Fb lp sds_gvars b) m m'.
  Proof.
    intros b fd m vargs t m' vres Hs Hf Hev.
    destruct (linkorder_resolves_funct lp SF.prog SF._save_file_do_save SF.f_save_file_do_save
                (linked12_LO_save lp H12) ltac:(vm_compute; reflexivity)) as (b' & Hs' & Hf').
    unfold lp_ge in Hs, Hf. rewrite Hs in Hs'. injection Hs' as <-. rewrite Hf in Hf'. injection Hf' as ->.
    split; [ exact (PS_sds _ _ _ _ _ Hev) | ].
    assert (U : Mem.unchanged_on (FootWalk.Q lp sds_gvars m) m m').
    { apply (sw_sds lp H12 Hfloor m m vargs t m' vres Hev); [ | apply Ple_refl ].
      intros le Hb t0 v Hg.
      split; [ | intros H; discriminate H ].
      intros Hn.
      rewrite (MathGeomBodies.bind_parameter_temps_gso _ _ _ _ t0 Hb) in Hg.
      - apply MtxfBody.create_undef_temps_get in Hg. subst v. intros bb o E. discriminate E.
      - cbn [var_names map fst fn_params SF.f_save_file_do_save].
        intros [E | []]. subst t0. vm_compute in Hn. discriminate Hn. }
    eapply Mem.unchanged_on_implies; [ exact U | ].
    intros b0 z N V. exact (conj N V).
  Qed.
End SDP.
