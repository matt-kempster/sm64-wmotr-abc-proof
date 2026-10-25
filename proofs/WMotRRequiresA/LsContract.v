(* spine (via ObjFrame): the load_sequence contract (TRUST 4.1, the labeled
   audio premise), moved here from Unwired/CapAudio so the spine can name it. *)
(* ====================================================================== *)
(* LsContract.v -- load_sequence's contract: GOAL 1's row plus its        *)
(* footprint.                                                              *)
(*                                                                        *)
(* load_sequence (audio/load.c) is not linked.  Its contract is GOAL 1's  *)
(* row (call_pres_ext: the carried facts) plus its footprint (ls_frame):  *)
(* a call changes only the blocks of ls_ids, the load.c / buffers.c       *)
(* globals that have a block in the model.  Memory may grow (its frames:  *)
(* load_sequence_internal's defaultBank, bank_load_immediate's buf); the  *)
(* new blocks are freed (Q2).  Read off the real US code (load.c, heap.c, *)
(* seqplayer.c, playback.c, synthesis.c; checked 2026-10-24): every store *)
(* goes to                                                                *)
(*   gAudioLoadLock, gSequencePlayers, gSeqLoadedPool, gBankLoadedPool,   *)
(*   gAudioHeap (buffers.c: the pools, the notes, the loaded banks and    *)
(*     sequences, all soundAlloc'd from it),                               *)
(* or to load.c globals no linked TU declares, so no block in this model: *)
(*   gSequenceChannels, gSequenceLayers, gSeqLoadStatus, gBankLoadStatus, *)
(*   gCtlEntries, gNoteFreeLists, gLayerFreeList, gAudioDmaMesgQueue,     *)
(*   gAudioDmaIoMesg.                                                     *)
(* Pointer stores (note lists, layer and bank-patch pointers) stay inside *)
(* those, given the audio driver's own invariants.  The DMA / message     *)
(* calls are libultra (TRUST 3.5; gAudioDmaMesgQueue is not one of        *)
(* os_dma_floor's queues).  Discharge path: link load.c / heap.c /        *)
(* seqplayer.c / playback.c and walk them (then the unlinked globals join *)
(* ls_ids).                                                               *)
(* ====================================================================== *)

From Coq Require Import ZArith List Bool.
From compcert Require Import Coqlib Maps AST Integers Values Events Memory
  Globalenvs Ctypes Cop Clightdefs Clight ClightBigstep Linking.
From SM64.Generated Require audio_external buffers.
From SM64.Proofs Require Import SymbolicLinking RealFrameLinked CensusV2 FloorsSurface.
From SM64.Proofs Require EngineV2Consumer ObjExtBodies.
From SM64.Proofs.WMotRRequiresA Require Import BodyFrame.

Import ListNotations.

Module AX := audio_external.

(* the blocks of a list of globals *)
Definition gblk (G : genv) (ids : list ident) (b : block) : Prop :=
  exists g, In g ids /\ Genv.find_symbol G g = Some b.

(* load_sequence's written globals with a block in the model (see above) *)
Definition ls_ids : list ident :=
  [AX._gAudioLoadLock; AX._gSequencePlayers; AX._gSeqLoadedPool; AX._gBankLoadedPool;
   buffers._gAudioHeap].

Definition ls_frame (lp : Clight.program) : Prop :=
  forall fd m vargs t m' vres,
    eval_funcall function_entry2 (lp_ge lp) m fd vargs t m' vres ->
    EngineV2Consumer.resolves_lp lp AX._load_sequence fd ->
    Q2 (fun b _ => ~ gblk (lp_ge lp) ls_ids b) m m'.

(* THE LABELED AUDIO PREMISE (TRUST 4.1): GOAL 1's row and the footprint
   (HeightFrame takes NoA := NoA_real bm) *)
Definition ls_contract (lp : Clight.program) (bm : block) (NoA MWF : mem -> Prop) : Prop :=
  call_pres_ext lp bm NoA MWF AX._load_sequence /\ ls_frame lp.

(* none of ls_ids is a global MWF reads *)
Lemma ls_ids_not_mwf : forallb (fun g => negb (mem_id g ObjExtBodies.mwf_syms)) ls_ids = true.
Proof. vm_compute. reflexivity. Qed.

Lemma ls_ids_nm : forall g, In g ls_ids -> mem_id g ObjExtBodies.mwf_syms = false.
Proof.
  intros g Hg. pose proof (proj1 (forallb_forall _ _) ls_ids_not_mwf g Hg) as H.
  apply negb_true_iff in H. exact H.
Qed.
