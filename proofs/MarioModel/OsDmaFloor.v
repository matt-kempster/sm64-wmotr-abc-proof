(* ====================================================================== *)
(* OsDmaFloor.v -- the hardware/OS floor under load_patchable_table      *)
(*                                                                        *)
(* memory.c's dma_read is the game's only path to ROM data, and it ends   *)
(* in three libultra calls: osInvalDCache, osPiStartDma, osRecvMesg.      *)
(* Below them there is no more C to link: osRecvMesg yields the thread    *)
(* (__osEnqueueAndYield, asm), the PI manager thread starts the transfer  *)
(* by writing PI registers, and the bytes arrive by hardware DMA.  So     *)
(* this is where proving stops and a spec of the hardware/OS starts       *)
(* (TRUST 3.5).                                                           *)
(*                                                                        *)
(* Each spec bounds every execution of the call (CompCert's               *)
(* external_functions_sem has no content of its own):                     *)
(*   - the arguments have the shape every real call has (pointers where   *)
(*     the C passes addresses).  A call with other arguments has no       *)
(*     execution, like UB (TRUST 3.2);                                    *)
(*   - nothing changes outside the argument ranges: the destination       *)
(*     range, the OSIoMesg (20 bytes, __423), the OSMesgQueue (24 bytes), *)
(*     the received-message cell (4 bytes);                               *)
(*   - no block is allocated or freed, and no permission changes;         *)
(*   - the destination range lies inside the address space: it does not *)
(*     wrap past 2^32 (on the N64 every buffer is in RDRAM, far below);   *)
(*   - the DMA'd destination bytes are data (Byte memvals): a ROM copy    *)
(*     never produces a CompCert pointer.  osInvalDCache leaves each      *)
(*     byte of its range either as it was or as data (a discarded dirty   *)
(*     line exposes older RAM).                                           *)
(* The whole DMA is attributed to osPiStartDma.  Between it and the       *)
(* blocking osRecvMesg the game thread only returns and makes the call,   *)
(* reading nothing, so that order describes every interleaving the game  *)
(* thread can observe.  Other threads' writes are TRUST 3.3.              *)
(* ====================================================================== *)

From Coq Require Import ZArith List String.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events.
Import ListNotations.
Local Open Scope Z_scope.

(* (b', z) lies outside the [n] bytes at (b, o) *)
Definition outside (b : block) (o : ptrofs) (n : Z) (b' : block) (z : Z) : Prop :=
  b' <> b \/ z < Ptrofs.unsigned o \/ Ptrofs.unsigned o + n <= z.

Definition same_perms (m m' : mem) : Prop :=
  Mem.nextblock m' = Mem.nextblock m
  /\ (forall b z k p, Mem.perm m' b z k p <-> Mem.perm m b z k p).

Definition is_data (mv : memval) : Prop := exists byte, mv = Byte byte.

Definition SZ_IOMESG : Z := 20.
Definition SZ_MESGQ : Z := 24.

(* osInvalDCache(void *p, u32 n) *)
Definition inval_dcache_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osInvalDCache" sg ge vargs m t vres m' ->
    exists bp op n,
      vargs = [Vptr bp op; Vint n]
      /\ Mem.unchanged_on (outside bp op (Int.unsigned n)) m m'
      /\ same_perms m m'
      /\ (forall z, Ptrofs.unsigned op <= z < Ptrofs.unsigned op + Int.unsigned n ->
            ZMap.get z (Mem.mem_contents m') !! bp = ZMap.get z (Mem.mem_contents m) !! bp
            \/ is_data (ZMap.get z (Mem.mem_contents m') !! bp))
      /\ Ptrofs.unsigned op + Int.unsigned n <= Ptrofs.modulus.

(* osPiStartDma(OSIoMesg *mb, s32 pri, s32 dir, u32 devAddr, void *dest,
                u32 size, OSMesgQueue *mq) *)
Definition pi_start_dma_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osPiStartDma" sg ge vargs m t vres m' ->
    exists bmb omb pri dir dev bd od n bq oq,
      vargs = [Vptr bmb omb; Vint pri; Vint dir; dev; Vptr bd od; Vint n; Vptr bq oq]
      /\ Mem.unchanged_on (fun b z => outside bd od (Int.unsigned n) b z
                                      /\ outside bmb omb SZ_IOMESG b z
                                      /\ outside bq oq SZ_MESGQ b z) m m'
      /\ same_perms m m'
      /\ (forall z, Ptrofs.unsigned od <= z < Ptrofs.unsigned od + Int.unsigned n ->
            is_data (ZMap.get z (Mem.mem_contents m') !! bd))
      /\ Ptrofs.unsigned od + Int.unsigned n <= Ptrofs.modulus.

(* osRecvMesg(OSMesgQueue *mq, OSMesg *msg, s32 flags) *)
Definition recv_mesg_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osRecvMesg" sg ge vargs m t vres m' ->
    exists bq oq bmsg omsg fl,
      vargs = [Vptr bq oq; Vptr bmsg omsg; Vint fl]
      /\ Mem.unchanged_on (fun b z => outside bq oq SZ_MESGQ b z
                                      /\ outside bmsg omsg 4 b z) m m'
      /\ same_perms m m'.

Definition os_dma_floor : Prop :=
  inval_dcache_spec /\ pi_start_dma_spec /\ recv_mesg_spec.
