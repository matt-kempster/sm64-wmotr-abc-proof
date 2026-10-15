From Coq Require Import Bool List String ZArith.
From compcert Require Import AST Clight Clightdefs Ctypes Events Floats
 Globalenvs Integers Maps Memory Memdata Values Errors.
From Demo.Generated Require Import us_game_init us_memory.
From Demo.Proofs Require Import DemoExecutionHistory.
Import ListNotations.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.
Module EG := us_game_init.
Module EM := us_memory.

(** SPECIFICATION ONLY. No SDK, native machine, ROM authentication, scheduler,
    or coverage refinement is asserted here. The underlying external call and
    Clight step are never replaced. Unknown game externals have no constructor.

    This is a proposed caller-visible SDK abstraction: SDK private state is
    carried by the phase rather than silently added to the game memory. Its
    relation to native SDK private memory is an outstanding refinement. *)

Inductive demo_external_api :=
| DemoCreateQueue | DemoReceive | DemoControllerInit | DemoControllerStart
| DemoControllerRead | DemoCacheWriteback | DemoVideoSwap | DemoEepromProbe
| DemoCacheInvalidateData | DemoCacheInvalidateInstruction | DemoPiRead | DemoSqrt.

Definition demo_external_api_name api : string :=
 match api with
 | DemoCreateQueue => "osCreateMesgQueue" | DemoReceive => "osRecvMesg"
 | DemoControllerInit => "osContInit" | DemoControllerStart => "osContStartReadData"
 | DemoControllerRead => "osContGetReadData" | DemoCacheWriteback => "osWritebackDCacheAll"
 | DemoVideoSwap => "osViSwapBuffer" | DemoEepromProbe => "osEepromProbe"
 | DemoCacheInvalidateData => "osInvalDCache"
 | DemoCacheInvalidateInstruction => "osInvalICache"
 | DemoPiRead => "osPiStartDma" | DemoSqrt => "sqrtf"
 end.

Definition demo_external_api_signature api : signature :=
 match api with
 | DemoCreateQueue => mksignature [Xptr;Xptr;Xint] Xvoid cc_default
 | DemoReceive => mksignature [Xptr;Xptr;Xint] Xint cc_default
 | DemoControllerInit => mksignature [Xptr;Xptr;Xptr] Xint cc_default
 | DemoControllerStart | DemoEepromProbe => mksignature [Xptr] Xint cc_default
 | DemoControllerRead | DemoVideoSwap => mksignature [Xptr] Xvoid cc_default
 | DemoCacheWriteback => mksignature [] Xvoid cc_default
 | DemoCacheInvalidateData | DemoCacheInvalidateInstruction =>
     mksignature [Xptr;Xint] Xvoid cc_default
 | DemoPiRead => mksignature [Xptr;Xint;Xint;Xint;Xptr;Xint;Xptr] Xint cc_default
 | DemoSqrt => mksignature [Xsingle] Xsingle cc_default
 end.

Definition demo_external_api_function api : external_function :=
 EF_external (demo_external_api_name api) (demo_external_api_signature api).

Record demo_external_region := DemoExternalRegion {
 demo_region_block : block; demo_region_first : Z; demo_region_past : Z
}.
Definition demo_external_in_regions regions b ofs : Prop :=
 exists region, In region regions /\ b = demo_region_block region /\
   demo_region_first region <= ofs < demo_region_past region.
Definition demo_external_memory_frame regions before after : Prop :=
 Mem.unchanged_on (fun b ofs => ~demo_external_in_regions regions b ofs) before after.
Definition demo_external_pointer_region pointer size : list demo_external_region :=
 match pointer with
 | Vptr b ofs => [DemoExternalRegion b (Ptrofs.unsigned ofs) (Ptrofs.unsigned ofs+size)]
 | _ => []
 end.

Record demo_external_store := DemoExternalStore {
 demo_store_chunk : memory_chunk; demo_store_block : block;
 demo_store_offset : Z; demo_store_value : val
}.
Fixpoint demo_external_apply_stores writes before : option mem :=
 match writes with
 | [] => Some before
 | write :: rest =>
   match Mem.store (demo_store_chunk write) before (demo_store_block write)
     (demo_store_offset write) (demo_store_value write) with
   | None => None | Some middle => demo_external_apply_stores rest middle
   end
 end.

(** Full representational ranges, not the header's unproved physical [-80,80]
    stick comment. The SDK extracts the two error bits to 0/4/8/12. *)
Record demo_external_pad := DemoExternalPad {
 demo_pad_buttons : Z; demo_pad_x : Z; demo_pad_y : Z; demo_pad_error : Z
}.
Definition demo_external_pad_valid pad : Prop :=
 0 <= demo_pad_buttons pad < 65536 /\ -128 <= demo_pad_x pad < 128 /\
 -128 <= demo_pad_y pad < 128 /\
 In (demo_pad_error pad) [0;4;8;12].
Definition demo_external_pad_frame_valid pads : Prop :=
 List.length pads = 4%nat /\ Forall demo_external_pad_valid pads.

(** osContGetReadData, lib/src/osContStartReadData.c44: errnum is always
    written; failed ports retain the previous button and stick fields.
    The sixth byte of each six-byte OSContPad remains untouched. *)
Definition demo_external_pad_writes b base pad : list demo_external_store :=
 DemoExternalStore Mint8unsigned b (base+4) (Vint (Int.repr (demo_pad_error pad))) ::
 if Z.eqb (demo_pad_error pad) 0 then
 [DemoExternalStore Mint16unsigned b base (Vint (Int.repr (demo_pad_buttons pad)));
  DemoExternalStore Mint8signed b (base+2) (Vint (Int.repr (demo_pad_x pad)));
  DemoExternalStore Mint8signed b (base+3) (Vint (Int.repr (demo_pad_y pad)))]
 else [].
Fixpoint demo_external_all_pad_writes b base pads : list demo_external_store :=
 match pads with
 | [] => []
 | pad::rest => demo_external_pad_writes b base pad ++
                demo_external_all_pad_writes b (base+6) rest
 end.

Record demo_external_status := DemoExternalStatus {
 demo_status_type : Z; demo_status_flags : Z; demo_status_error : Z
}.
Definition demo_external_status_valid status : Prop :=
 0 <= demo_status_type status < 65536 /\ 0 <= demo_status_flags status < 256 /\
 In (demo_status_error status) [0;4;8;12].
Definition demo_external_status_writes b base status : list demo_external_store :=
 DemoExternalStore Mint8unsigned b (base+3) (Vint (Int.repr (demo_status_error status))) ::
 if Z.eqb (demo_status_error status) 0 then
 [DemoExternalStore Mint16unsigned b base (Vint (Int.repr (demo_status_type status)));
  DemoExternalStore Mint8unsigned b (base+2) (Vint (Int.repr (demo_status_flags status)))]
 else [].
Fixpoint demo_external_all_status_writes b base statuses : list demo_external_store :=
 match statuses with
 | [] => []
 | status::rest => demo_external_status_writes b base status ++
                  demo_external_all_status_writes b (base+4) rest
 end.
Fixpoint demo_external_status_mask statuses : Z :=
 match statuses with
 | [] => 0
 | status::rest => (if Z.eqb (demo_status_error status) 0 then 1 else 0) +
                  2 * demo_external_status_mask rest
 end.

Inductive demo_external_queue_role :=
| DemoQueueSI | DemoQueueDMA | DemoQueueGameVblank | DemoQueueGfxVblank.
Definition demo_external_vblank_message role : val :=
 match role with
 | DemoQueueGameVblank => Vone
 | DemoQueueGfxVblank => Vint (Int.repr 2)
 | _ => Vundef
 end.
Record demo_external_queue := DemoExternalQueue {
 demo_queue_pointer : val; demo_queue_buffer : val; demo_queue_capacity : Z
}.
Definition demo_external_queue_regions queue : list demo_external_region :=
 demo_external_pointer_region (demo_queue_pointer queue) 24 ++
 demo_external_pointer_region (demo_queue_buffer queue) (4*demo_queue_capacity queue).

Record demo_external_dma := DemoExternalDMA {
 demo_dma_descriptor : val; demo_dma_device_address : Z;
 demo_dma_destination_block : block; demo_dma_destination_offset : ptrofs;
 demo_dma_size : Z
}.

(** The resource is a byte image, not a digest standing in for bytes. No image
    is instantiated here. ROM authentication, exact retail placement, SDK state
    projection, and source-layout receipts are explicit later obligations. *)
Record demo_external_configuration := DemoExternalConfiguration {
 demo_external_rom : list Integers.Byte.int;
 demo_external_queue_binding : demo_external_queue_role -> option demo_external_queue;
 demo_external_thread_tail : val
}.
Definition demo_external_rom_slice configuration address size :=
 firstn (Z.to_nat size) (skipn (Z.to_nat address) (demo_external_rom configuration)).
Definition demo_external_rom_range configuration address size : Prop :=
 0 <= address /\ 0 <= size /\
 address + size <= Z.of_nat (List.length (demo_external_rom configuration)).

Inductive demo_controller_io_phase :=
| DemoControllerIdle
| DemoControllerPending (sample : list demo_external_pad)
| DemoControllerCompleted (sample : list demo_external_pad).
Record demo_external_phase := DemoExternalPhase {
 demo_external_controller_initialized : bool;
 demo_external_controller_phase : demo_controller_io_phase;
 demo_external_pending_dma : option demo_external_dma
}.
Definition demo_external_set_controller phase initialized controller :=
 DemoExternalPhase initialized controller (demo_external_pending_dma phase).
Definition demo_external_set_dma phase dma :=
 DemoExternalPhase (demo_external_controller_initialized phase)
   (demo_external_controller_phase phase) dma.

(** Queue internals are deliberately a bounded footprint contract, not a proof
    of FIFO order, blocking progress or thread wakeup. These exact API effects
    must be justified against SDK code/scheduler, not assumed of game callees. *)
Definition demo_external_queue_effect queue reply before after : Prop :=
 0 < demo_queue_capacity queue /\
 demo_external_memory_frame
   (demo_external_queue_regions queue ++ demo_external_pointer_region reply 4) before after.
Definition demo_external_reply reply message before after : Prop :=
 match reply with
 | Vptr b ofs => Mem.store Mptr before b (Ptrofs.unsigned ofs) message = Some after
 | Vint zero => Int.eq zero Int.zero = true /\ after = before
 | _ => False
 end.
Definition demo_external_dma_copy configuration request before after : Prop :=
 demo_external_rom_range configuration (demo_dma_device_address request) (demo_dma_size request) /\
 Mem.storebytes before (demo_dma_destination_block request)
   (Ptrofs.unsigned (demo_dma_destination_offset request))
   (map Memdata.Byte (demo_external_rom_slice configuration
     (demo_dma_device_address request) (demo_dma_size request))) = Some after.

Definition demo_external_dma_descriptor_writes descriptor device destination size queue :=
 match descriptor with
 | Vptr b ofs =>
   let base := Ptrofs.unsigned ofs in
   [DemoExternalStore Mint16unsigned b base (Vint (Int.repr 11));
    DemoExternalStore Mint8unsigned b (base+2) Vzero;
    DemoExternalStore Mptr b (base+4) queue;
    DemoExternalStore Mptr b (base+8) destination;
    DemoExternalStore Mint32 b (base+12) (Vint device);
    DemoExternalStore Mint32 b (base+16) (Vint size)]
 | _ => []
 end.

(** Event names are checked when an external emits a syscall. EF_external
    does not itself emit a syscall. E0 remains possible, and the actual
    external_call conjunct below retains CompCert's determinism constraints.
    This does NOT claim every hardware sample has a matching external call. *)
Definition demo_external_trace_shape api trace : Prop :=
 trace = E0 \/ exists arguments result,
   trace = [Event_syscall (demo_external_api_name api) arguments result].

Inductive demo_external_api_effect (configuration : demo_external_configuration) :
 demo_external_phase -> demo_external_api -> list val -> mem -> val -> mem ->
 demo_external_phase -> Prop :=
| demo_external_read_pads : forall phase sample b ofs before after,
 demo_external_controller_phase phase = DemoControllerCompleted sample ->
 demo_external_pad_frame_valid sample ->
 demo_external_apply_stores (demo_external_all_pad_writes b (Ptrofs.unsigned ofs) sample)
   before = Some after ->
 demo_external_api_effect configuration phase DemoControllerRead [Vptr b ofs]
   before Vundef after (demo_external_set_controller phase true DemoControllerIdle)
| demo_external_start_pads : forall phase queue sample before after,
 demo_external_queue_binding configuration DemoQueueSI = Some queue ->
 demo_external_controller_initialized phase = true ->
 demo_external_controller_phase phase = DemoControllerIdle ->
 demo_external_pad_frame_valid sample ->
 demo_external_queue_effect queue Vzero before after ->
 demo_external_api_effect configuration phase DemoControllerStart [demo_queue_pointer queue]
   before Vzero after (demo_external_set_controller phase true (DemoControllerPending sample))
| demo_external_receive_pads : forall phase queue sample reply before middle after,
 demo_external_queue_binding configuration DemoQueueSI = Some queue ->
 demo_external_controller_phase phase = DemoControllerPending sample ->
 demo_external_queue_effect queue Vzero before middle ->
 demo_external_reply reply Vzero middle after ->
 demo_external_api_effect configuration phase DemoReceive
   [demo_queue_pointer queue;reply;Vone] before Vzero after
   (demo_external_set_controller phase true (DemoControllerCompleted sample))
| demo_external_initialize_pads : forall phase queue statuses bits b ofs before middle after,
 demo_external_queue_binding configuration DemoQueueSI = Some queue ->
 demo_external_controller_initialized phase = false ->
 List.length statuses = 4%nat -> Forall demo_external_status_valid statuses ->
 demo_external_queue_effect queue Vzero before middle ->
 demo_external_apply_stores
   (demo_external_all_status_writes b (Ptrofs.unsigned ofs) statuses ++
    match bits with Vptr bitblock bitofs =>
      [DemoExternalStore Mint8unsigned bitblock (Ptrofs.unsigned bitofs)
        (Vint (Int.repr (demo_external_status_mask statuses)))] | _ => [] end)
   middle = Some after ->
 (exists bitblock bitofs, bits = Vptr bitblock bitofs) ->
 demo_external_api_effect configuration phase DemoControllerInit
   [demo_queue_pointer queue;bits;Vptr b ofs] before Vzero after
   (demo_external_set_controller phase true DemoControllerIdle)
| demo_external_initialize_again : forall phase queue bits statuses before,
 demo_external_queue_binding configuration DemoQueueSI = Some queue ->
 demo_external_controller_initialized phase = true ->
 demo_external_api_effect configuration phase DemoControllerInit
   [demo_queue_pointer queue;bits;statuses] before Vzero before phase
| demo_external_start_dma : forall phase queue descriptor device destination size
    b ofs before after,
 demo_external_queue_binding configuration DemoQueueDMA = Some queue ->
 demo_external_pending_dma phase = None ->
 descriptor <> Vundef -> destination = Vptr b ofs ->
 0 < Int.unsigned size <= 4096 -> Z.modulo (Int.unsigned size) 16 = 0 ->
 demo_external_rom_range configuration (Int.unsigned device) (Int.unsigned size) ->
 demo_external_apply_stores
   (demo_external_dma_descriptor_writes descriptor device destination size
      (demo_queue_pointer queue)) before = Some after ->
 (exists block offset, descriptor = Vptr block offset) ->
 demo_external_api_effect configuration phase DemoPiRead
   [descriptor;Vzero;Vzero;Vint device;destination;Vint size;demo_queue_pointer queue]
   before Vzero after
   (demo_external_set_dma phase (Some
     (DemoExternalDMA descriptor (Int.unsigned device) b ofs (Int.unsigned size))))
| demo_external_receive_dma : forall phase queue request reply before queued copied after,
 demo_external_queue_binding configuration DemoQueueDMA = Some queue ->
 demo_external_pending_dma phase = Some request ->
 demo_external_queue_effect queue Vzero before queued ->
 demo_external_dma_copy configuration request queued copied ->
 demo_external_reply reply (demo_dma_descriptor request) copied after ->
 demo_external_api_effect configuration phase DemoReceive
   [demo_queue_pointer queue;reply;Vone] before Vzero after
   (demo_external_set_dma phase None)
| demo_external_receive_vblank : forall phase role queue reply before middle after,
 (role = DemoQueueGameVblank \/ role = DemoQueueGfxVblank) ->
 demo_external_queue_binding configuration role = Some queue ->
 demo_external_queue_effect queue Vzero before middle ->
 demo_external_reply reply (demo_external_vblank_message role) middle after ->
 demo_external_api_effect configuration phase DemoReceive
   [demo_queue_pointer queue;reply;Vone] before Vzero after phase
| demo_external_create_queue : forall phase role queue b ofs before after,
 demo_external_queue_binding configuration role = Some queue ->
 demo_queue_pointer queue = Vptr b ofs -> 0 < demo_queue_capacity queue <= Int.max_signed ->
 demo_external_apply_stores
   [DemoExternalStore Mptr b (Ptrofs.unsigned ofs) (demo_external_thread_tail configuration);
    DemoExternalStore Mptr b (Ptrofs.unsigned ofs+4) (demo_external_thread_tail configuration);
    DemoExternalStore Mint32 b (Ptrofs.unsigned ofs+8) Vzero;
    DemoExternalStore Mint32 b (Ptrofs.unsigned ofs+12) Vzero;
    DemoExternalStore Mint32 b (Ptrofs.unsigned ofs+16)
      (Vint (Int.repr (demo_queue_capacity queue)));
    DemoExternalStore Mptr b (Ptrofs.unsigned ofs+20) (demo_queue_buffer queue)]
   before = Some after ->
 demo_external_api_effect configuration phase DemoCreateQueue
   [Vptr b ofs;demo_queue_buffer queue;Vint (Int.repr (demo_queue_capacity queue))]
   before Vundef after phase
| demo_external_probe_eeprom : forall phase queue before after (present : bool),
 demo_external_queue_binding configuration DemoQueueSI = Some queue ->
 demo_external_queue_effect queue Vzero before after ->
 demo_external_api_effect configuration phase DemoEepromProbe [demo_queue_pointer queue]
   before (if present then Vone else Vzero) after phase
| demo_external_cache_writeback : forall phase before,
 demo_external_api_effect configuration phase DemoCacheWriteback [] before Vundef before phase
| demo_external_cache_invalidate : forall phase api pointer size before,
 (api = DemoCacheInvalidateData \/ api = DemoCacheInvalidateInstruction) ->
 demo_external_api_effect configuration phase api [pointer;Vint size] before Vundef before phase
| demo_external_video_swap : forall phase framebuffer before,
 demo_external_api_effect configuration phase DemoVideoSwap [framebuffer] before Vundef before phase
| demo_external_square_root : forall phase input before,
 demo_external_api_effect configuration phase DemoSqrt [Vsingle input]
   before (Vsingle (Float32.sqrt input)) before phase.

Definition demo_external_queue_symbol role : ident :=
 match role with
 | DemoQueueSI => EG._gSIEventMesgQueue | DemoQueueDMA => EM._gDmaMesgQueue
 | DemoQueueGameVblank => EG._gGameVblankQueue | DemoQueueGfxVblank => EG._gGfxVblankQueue
 end.
Definition demo_external_queue_buffer_symbol role : ident :=
 match role with
 | DemoQueueSI => $"gSIEventMesgBuf" | DemoQueueDMA => $"gDmaMesgBuf"
 | DemoQueueGameVblank => EG._gGameMesgBuf | DemoQueueGfxVblank => EG._gGfxMesgBuf
 end.

(** SI/DMA buffer names are from pinned src/game/main.c, which is NOT currently
    translated. This is a resource requirement, not a declaration of a global
    or a claim that the selected source environment already provides it. *)
Definition demo_external_configuration_resources (ge : Clight.genv) configuration : Prop :=
 forall role queue,
 demo_external_queue_binding configuration role = Some queue ->
 exists queueblock bufferblock,
 Genv.find_symbol ge (demo_external_queue_symbol role) = Some queueblock /\
 Genv.find_symbol ge (demo_external_queue_buffer_symbol role) = Some bufferblock /\
 demo_queue_pointer queue = Vptr queueblock Ptrofs.zero /\
 demo_queue_buffer queue = Vptr bufferblock Ptrofs.zero /\
 demo_queue_capacity queue = 1.

Definition demo_external_struct_layout ge tag size fields : Prop :=
 exists co, (genv_cenv ge) ! tag = Some co /\ co_sizeof co = size /\
 Forall (fun entry => let '(field,offset) := entry in
   field_offset (genv_cenv ge) field (co_members co) = OK (offset,Full)) fields.

(** Actual generated member identifiers constrain every numerical patch above.
    The corresponding linked cenv/layout receipt remains an obligation. *)
Definition demo_external_source_layouts ge : Prop :=
 demo_external_struct_layout ge EG.__319 6
   [(EG._button,0);(EG._stick_x,2);(EG._stick_y,3);(EG._errnum,4)] /\
 demo_external_struct_layout ge EG.__317 4
   [(EG._type,0);(EG._status,2);(EG._errnum,3)] /\
 demo_external_struct_layout ge EG._OSMesgQueue_s 24
   [(EG._mtqueue,0);(EG._fullqueue,4);(EG._validCount,8);(EG._first,12);
    (EG._msgCount,16);(EG._msg,20)] /\
 demo_external_struct_layout ge EM.__423 20
   [(EM._hdr,0);(EM._dramAddr,8);(EM._devAddr,12);(EM._size,16)] /\
 demo_external_struct_layout ge EM.__421 8
   [(EM._type,0);(EM._pri,2);(EM._status,3);(EM._retQueue,4)].

Definition demo_external_global_pointer (ge : Clight.genv) id value : Prop :=
 exists b, Genv.find_symbol ge id = Some b /\ value = Vptr b Ptrofs.zero.
Definition demo_external_source_arguments ge api arguments : Prop :=
 match api, arguments with
 | DemoControllerRead, [pads] => demo_external_global_pointer ge EG._gControllerPads pads
 | DemoControllerInit, [_;bits;statuses] =>
   demo_external_global_pointer ge EG._gControllerBits bits /\
   demo_external_global_pointer ge EG._gControllerStatuses statuses
 | DemoPiRead, [descriptor;_;_;_;_;_;_] =>
   demo_external_global_pointer ge EM._gDmaIoMesg descriptor
 | DemoReceive, [_;reply;_] => demo_external_global_pointer ge EG._gMainReceivedMesg reply
 | _, _ => True
 end.

Definition demo_permitted_external_transition (ge : Clight.genv) configuration phase ef arguments
    before trace result after phase' : Prop :=
 external_call ef ge arguments before trace result after /\
 demo_external_configuration_resources ge configuration /\
 demo_external_source_layouts ge /\
 exists api,
   ef = demo_external_api_function api /\ demo_external_trace_shape api trace /\
   demo_external_source_arguments ge api arguments /\
   demo_external_api_effect configuration phase api arguments before result after phase'.

(** This projection loses sequencing; the history policy must use the phase-
    carrying relation above and retain one phase across consecutive calls. *)
Definition demo_permitted_external_call ge configuration ef arguments before trace result after : Prop :=
 exists phase phase', demo_permitted_external_transition ge configuration phase ef
   arguments before trace result after phase'.

(** Carry one SDK phase through the original execution. Sbuiltin is rejected
    explicitly: its external_call must never bypass the policy by being treated
    as an ordinary internal statement. No start predicate is supplied here. *)
Definition demo_external_state_invokes_external state : Prop :=
 match state with
 | Callstate (External _ _ _ _) _ _ _ => True
 | State _ (Sbuiltin _ _ _ _) _ _ _ _ => True
 | _ => False
 end.

Definition demo_external_step_policy ge configuration phase state trace next phase' : Prop :=
 match state with
 | Callstate (External ef _ _ _) arguments continuation before =>
   exists result after,
   next = Returnstate result continuation after /\
   demo_permitted_external_transition ge configuration phase ef arguments
     before trace result after phase'
 | State _ (Sbuiltin _ _ _ _) _ _ _ _ => False
 | _ => phase' = phase
 end.

Definition demo_history_external_policy {prog} configuration
    (history : demo_execution_history prog) (phases : nat -> demo_external_phase) : Prop :=
 forall index, (index < history_length history)%nat ->
 demo_external_step_policy (Clight.globalenv prog) configuration (phases index)
   (history_state history index) (history_trace history index)
   (history_state history (S index)) (phases (S index)).

Definition demo_permitted_external_history {prog} configuration
    (history : demo_execution_history prog) : Prop :=
 exists phases, demo_history_external_policy configuration history phases.

Theorem demo_permitted_history_step_is_actual :
 forall prog configuration (history : demo_execution_history prog) phases index,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 Clight.step2 (Clight.globalenv prog) (history_state history index)
   (history_trace history index) (history_state history (S index)).
Proof. intros. apply history_step. assumption. Qed.

Theorem demo_permitted_history_internal_phase_continuous :
 forall prog configuration (history : demo_execution_history prog) phases index,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 ~demo_external_state_invokes_external (history_state history index) ->
 phases (S index) = phases index.
Proof.
 intros prog configuration history phases index Hpolicy Hbound Hinternal.
 specialize (Hpolicy index Hbound).
 unfold demo_external_step_policy in Hpolicy.
 unfold demo_external_state_invokes_external in Hinternal.
 destruct (history_state history index) as [f statement k e le m | fd args k m | result k m].
 - destruct statement; cbn in *; try exact Hpolicy; contradiction.
 - destruct fd; cbn in *; [exact Hpolicy | contradiction].
 - exact Hpolicy.
Qed.

Theorem demo_permitted_history_external_call_exact :
 forall prog configuration (history : demo_execution_history prog) phases index
     ef types returntype callconv arguments continuation before,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 history_state history index =
   Callstate (External ef types returntype callconv) arguments continuation before ->
 exists result after,
 history_state history (S index) = Returnstate result continuation after /\
 external_call ef (Clight.globalenv prog) arguments before
   (history_trace history index) result after /\
 demo_permitted_external_transition (Clight.globalenv prog) configuration
   (phases index) ef arguments before (history_trace history index)
   result after (phases (S index)).
Proof.
 intros prog configuration history phases index ef types returntype callconv
   arguments continuation before Hpolicy Hbound Hstate.
 specialize (Hpolicy index Hbound). unfold demo_external_step_policy in Hpolicy.
 rewrite Hstate in Hpolicy. destruct Hpolicy as (result & after & Hnext & Hcall).
 exists result, after. split; [exact Hnext |]. split; [exact (proj1 Hcall) | exact Hcall].
Qed.

Theorem demo_permitted_history_rejects_builtin :
 forall prog configuration (history : demo_execution_history prog) phases index
     f optid ef types arguments continuation locals temporaries before,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 history_state history index =
   State f (Sbuiltin optid ef types arguments) continuation locals temporaries before -> False.
Proof.
 intros prog configuration history phases index f optid ef types arguments
   continuation locals temporaries before Hpolicy Hbound Hstate.
 specialize (Hpolicy index Hbound). unfold demo_external_step_policy in Hpolicy.
 rewrite Hstate in Hpolicy. exact Hpolicy.
Qed.

(** These are structural facts about the candidate policy, not an adequacy
    statement for the SDK or the intended set of retail executions. *)
Definition demo_external_history_policy_claim : Prop :=
 (forall prog configuration (history : demo_execution_history prog) phases index,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 Clight.step2 (Clight.globalenv prog) (history_state history index)
   (history_trace history index) (history_state history (S index))) /\
 (forall prog configuration (history : demo_execution_history prog) phases index,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 ~demo_external_state_invokes_external (history_state history index) ->
 phases (S index) = phases index) /\
 (forall prog configuration (history : demo_execution_history prog) phases index
     ef types returntype callconv arguments continuation before,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 history_state history index =
   Callstate (External ef types returntype callconv) arguments continuation before ->
 exists result after,
 history_state history (S index) = Returnstate result continuation after /\
 external_call ef (Clight.globalenv prog) arguments before
   (history_trace history index) result after /\
 demo_permitted_external_transition (Clight.globalenv prog) configuration
   (phases index) ef arguments before (history_trace history index)
   result after (phases (S index))) /\
 (forall prog configuration (history : demo_execution_history prog) phases index
     f optid ef types arguments continuation locals temporaries before,
 demo_history_external_policy configuration history phases ->
 (index < history_length history)%nat ->
 history_state history index =
   State f (Sbuiltin optid ef types arguments) continuation locals temporaries before -> False).

Theorem checked_demo_external_history_policy : demo_external_history_policy_claim.
Proof.
 split; [exact demo_permitted_history_step_is_actual |].
 split; [exact demo_permitted_history_internal_phase_continuous |].
 split; [exact demo_permitted_history_external_call_exact |
         exact demo_permitted_history_rejects_builtin].
Qed.
