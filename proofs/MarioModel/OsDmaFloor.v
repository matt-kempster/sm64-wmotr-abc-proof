(* ====================================================================== *)
(* OsDmaFloor.v -- the hardware/OS floor under the linked libultra C      *)
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
(*                                                                        *)
(* WIDENED 2026-10-21 (save_file_do_save; the libultra EEPROM C is now    *)
(* linked: osEepromLongWrite / osEepromWrite / __osEepStatus /            *)
(* __osPackEepWriteData / the SI access queue / osCreateMesgQueue).  The  *)
(* floor is where that C stops:                                           *)
(*   - bcopy (lib/asm/bcopy.s): stores the n bytes it read at src to dst, *)
(*     and nothing else (an overlapping copy behaves as memmove);         *)
(*   - __osSiRawStartDma: its body is SI register IO_WRITEs (stores to    *)
(*     integer addresses: no CompCert execution) and the cache ops; the   *)
(*     SI DMA moves the 64-byte PIF RAM image at addr, so only those 64   *)
(*     bytes change, to data bytes or not at all (the read transfer is    *)
(*     attributed to the call, as osPiStartDma's is above);               *)
(*   - osRecvMesg / osSendMesg: their C reads and writes the thread       *)
(*     queues (__osThreadTail_fix / __osRunningThread, defined in asm)    *)
(*     and yields (__osEnqueueAndYield, asm), so they stay below the      *)
(*     floor.  osRecvMesg's message-cell argument may be NULL (the        *)
(*     EEPROM calls pass NULL; the old spec gave such calls no            *)
(*     execution).  What a wait / send changes is stated per queue, for   *)
(*     the queues the walked code uses (q_side): the queue, the cell,     *)
(*     and the queue's own message buffer when that buffer is linked      *)
(*     memory; for __osEepromTimerQ also the EEPROM timer, which the      *)
(*     timer interrupt unlinks while the game thread waits on it.  Calls  *)
(*     on any other queue are not constrained.  FOUND 2026-10-21: the old *)
(*     universal form was false for game_init.c's gGameVblankQueue,       *)
(*     whose buffer gGameMesgBuf is linked memory that the VI handler     *)
(*     writes during the wait;                                            *)
(*   - osSetTimer: its callee __osInsertTimer walks and rewrites the OS   *)
(*     timer list through the pointers libultra keeps in it (osTimer.c,   *)
(*     not linked; the timer interrupt, asm, drives it), which no         *)
(*     invariant here describes.  A COARSER floor than the C allows:      *)
(*     setting the EEPROM timer changes only its 32 bytes in the linked   *)
(*     memory (its list neighbour is __osBaseTimer, in osTimer.c).        *)
(* Every clause is about modeled memory only; writes by other threads are *)
(* TRUST 3.3.                                                             *)
(* ====================================================================== *)

From Coq Require Import ZArith List String.
From compcert Require Import Coqlib Maps AST Integers Values Memory Events Globalenvs.
From SM64.Generated Require memory save_file game_init libultra_osSiCreateAccessQueue
  libultra_osContInit.
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

(* osPiStartDma's CONTENT clause, for Mario's animation data only (TRUST
   0.8(f), user-approved 2026-10-22): the PI DMA copies the ROM bytes
   verbatim, and the ROM's gMarioAnims is the clightgen'd initializer's
   layout.  So a transfer whose device address is inside gMarioAnims (the
   only source load_patchable_table passes for Mario's list, memory.c:567)
   leaves in the n destination bytes the bytes gMarioAnims holds there.
   Stated only for the bytes of gMarioAnims that are readable (its linked
   storage); no other source is constrained.  The device address is the
   C's (u32) srcStart, which in CompCert's 32-bit model is the pointer
   itself. *)
Definition pi_dma_anim_spec : Prop :=
  forall sg ge vargs m t vres m' bga,
    external_functions_sem "osPiStartDma" sg ge vargs m t vres m' ->
    Senv.find_symbol ge game_init._gMarioAnims = Some bga ->
    forall mb pri dir os bd od n q,
      vargs = [mb; pri; dir; Vptr bga os; Vptr bd od; Vint n; q] ->
      forall i, 0 <= i < Int.unsigned n ->
        Mem.perm m bga (Ptrofs.unsigned os + i) Cur Readable ->
        ZMap.get (Ptrofs.unsigned od + i) (Mem.mem_contents m') !! bd
        = ZMap.get (Ptrofs.unsigned os + i) (Mem.mem_contents m) !! bga.

(* ---- the message queues the walked code waits on / sends to, and what
   else a wait or a send on each one changes in the linked memory: the
   queue's message buffer when it is linked (the array the program creates
   the queue with), and for the EEPROM timer queue the timer the interrupt
   fires.  gDmaMesgQueue / gSIEventMesgQueue: main.c's gDmaMesgBuf /
   gSIEventMesgBuf, not linked.  gOsSiMessageQueue: osSiMesgBuff
   (__osSiCreateAccessQueue.c).  __osEepromTimerQ: __osEepromTimerMsg
   (osContInit.c creates the queue on it) and __osEepromTimer. ---- *)
Definition q_side (q : ident) : option (list ident) :=
  if Pos.eqb q memory._gDmaMesgQueue then Some []
  else if Pos.eqb q save_file._gSIEventMesgQueue then Some []
  else if Pos.eqb q libultra_osSiCreateAccessQueue._gOsSiMessageQueue
  then Some [libultra_osSiCreateAccessQueue._osSiMesgBuff]
  else if Pos.eqb q libultra_osContInit.___osEepromTimerQ
  then Some [libultra_osContInit.___osEepromTimerMsg; libultra_osContInit.___osEepromTimer]
  else None.

(* b is none of the listed symbols' blocks *)
Definition not_side (ge : Senv.t) (l : list ident) (b : block) : Prop :=
  forall s, In s l -> Senv.find_symbol ge s <> Some b.

(* outside the 4-byte message cell, when there is one *)
Definition cell_out (cell : val) (b : block) (z : Z) : Prop :=
  match cell with
  | Vptr bc oc => outside bc oc 4 b z
  | _ => True
  end.

(* osRecvMesg(OSMesgQueue *mq, OSMesg *msg, s32 flags) *)
Definition recv_mesg_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osRecvMesg" sg ge vargs m t vres m' ->
    exists bq oq cell fl,
      vargs = [Vptr bq oq; cell; Vint fl]
      /\ (cell = Vint Int.zero \/ exists bc oc, cell = Vptr bc oc)
      /\ same_perms m m'
      /\ (forall q side, q_side q = Some side -> Senv.find_symbol ge q = Some bq ->
            Mem.unchanged_on (fun b z => outside bq oq SZ_MESGQ b z
                                         /\ cell_out cell b z
                                         /\ not_side ge side b) m m').

(* osSendMesg(OSMesgQueue *mq, OSMesg msg, s32 flags) *)
Definition send_mesg_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osSendMesg" sg ge vargs m t vres m' ->
    exists bq oq msg fl,
      vargs = [Vptr bq oq; msg; Vint fl]
      /\ same_perms m m'
      /\ (forall q side, q_side q = Some side -> Senv.find_symbol ge q = Some bq ->
            Mem.unchanged_on (fun b z => outside bq oq SZ_MESGQ b z
                                         /\ not_side ge side b) m m').

(* osSetTimer(OSTimer *t, OSTime countdown, OSTime interval, OSMesgQueue *mq,
              OSMesg msg); sizeof(OSTimer) = 32 (pinned: SaveDoSaveBody) *)
Definition SZ_OSTIMER : Z := 32.
Definition set_timer_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "osSetTimer" sg ge vargs m t vres m' ->
    exists bt ot rest,
      vargs = Vptr bt ot :: rest
      /\ same_perms m m'
      /\ (Senv.find_symbol ge libultra_osContInit.___osEepromTimer = Some bt ->
            Mem.unchanged_on (outside bt ot SZ_OSTIMER) m m').

(* __osSiRawStartDma(s32 dir, void *addr): the 64-byte PIF RAM image *)
Definition SZ_PIFRAM : Z := 64.
Definition si_raw_dma_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "__osSiRawStartDma" sg ge vargs m t vres m' ->
    exists dir bp op,
      vargs = [Vint dir; Vptr bp op]
      /\ Mem.unchanged_on (outside bp op SZ_PIFRAM) m m'
      /\ same_perms m m'
      /\ (forall z, Ptrofs.unsigned op <= z < Ptrofs.unsigned op + SZ_PIFRAM ->
            ZMap.get z (Mem.mem_contents m') !! bp = ZMap.get z (Mem.mem_contents m) !! bp
            \/ is_data (ZMap.get z (Mem.mem_contents m') !! bp)).

(* bcopy(const void *src, void *dst, size_t n) *)
Definition bcopy_spec : Prop :=
  forall sg ge vargs m t vres m',
    external_functions_sem "bcopy" sg ge vargs m t vres m' ->
    exists bs os bd od n,
      vargs = [Vptr bs os; Vptr bd od; Vint n]
      /\ Mem.unchanged_on (outside bd od (Int.unsigned n)) m m'
      /\ same_perms m m'
      /\ Mem.loadbytes m' bd (Ptrofs.unsigned od) (Int.unsigned n)
         = Mem.loadbytes m bs (Ptrofs.unsigned os) (Int.unsigned n).

(* the libultra OS / hardware floor (TRUST 3.5) *)
Definition os_dma_floor : Prop :=
  inval_dcache_spec /\ pi_start_dma_spec /\ recv_mesg_spec
  /\ send_mesg_spec /\ set_timer_spec /\ si_raw_dma_spec /\ bcopy_spec.
