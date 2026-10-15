From Coq Require Import List ZArith.
From compcert Require Import AST Clight Clightdefs ClightBigstep Ctypes Events Floats
  Globalenvs Integers Maps Memory Values.
From Demo.Generated Require Import us_title_screen jp_title_screen us_memory.
From Demo.Proofs Require Import DemoStartExecution DemoTitleStartExecution
  DemoLoaderExecution.
Import ListNotations.
Local Open Scope Z_scope.
Module LT := us_title_screen.

(** Compose the actual first-miss loader with the whole title body. The named
    DMA call is still a premise. In particular, authentic bytes and the five
    metadata reads after DMA are not silently replaced by a whole-frame axiom. *)
Definition demo_dma_to_first_title_claim (body : statement) : Prop :=
  forall ge (title_layout : demo_title_layout ge)
      (loader_layout : demo_loader_layout ge) le before cleared counted dmaed
      current countdown index player controller handler table buffer save act
      loader_code dma_code source count offset size header,
    le ! LT._level = Some (Vint Int.zero) ->
    Genv.find_symbol ge LT._gCurrDemoInput = Some current ->
    Genv.find_symbol ge LT._sDemoCountdown = Some countdown ->
    Genv.find_symbol ge LT._gDemoInputListID = Some index ->
    Genv.find_symbol ge LT._gPlayer1Controller = Some player ->
    Genv.find_symbol ge LT._gDemoInputsBuf = Some handler ->
    Genv.find_symbol ge LT._gCurrSaveFileNum = Some save ->
    Genv.find_symbol ge LT._gCurrActNum = Some act ->
    Genv.find_symbol ge LT._load_patchable_table = Some loader_code ->
    Genv.find_funct_ptr ge loader_code = Some (Internal us_memory.f_load_patchable_table) ->
    Genv.find_symbol ge us_memory._dma_read = Some dma_code ->
    Genv.find_funct_ptr ge dma_code = Some (Internal us_memory.f_dma_read) ->
    current <> player -> current <> controller -> current <> countdown -> current <> index ->
    countdown <> index ->
    index <> handler -> index <> table -> index <> buffer -> index <> current ->
    handler <> current -> buffer <> current ->
    current <> save -> current <> act -> save <> act ->
    handler <> table -> handler <> buffer ->
    Mem.store Mptr before current 0 (Vint Int.zero) = Some cleared ->
    Mem.load Mptr cleared player 0 = Some (Vptr controller Ptrofs.zero) ->
    Mem.load Mint16unsigned cleared controller 16 = Some (Vint Int.zero) ->
    Mem.load Mfloat32 cleared controller 12 = Some (Vsingle Float32.zero) ->
    Mem.load Mint16unsigned cleared countdown 0 = Some (Vint (Int.repr 799)) ->
    Mem.load Mint16unsigned counted index 0 = Some (Vint Int.zero) ->
    Mem.store Mint16unsigned cleared countdown 0 (Vint (Int.repr 800)) = Some counted ->
    Mem.load Mptr counted handler 0 = Some (Vptr table Ptrofs.zero) ->
    Mem.load Mint32 counted table 0 = Some (Vint count) ->
    Int.ltu Int.zero count = true -> Int.eq Int.one count = false ->
    Mem.load Mptr counted table 4 = Some (Vptr source Ptrofs.zero) ->
    Mem.load Mint32 counted table 8 = Some (Vint offset) ->
    Mem.load Mint32 counted table 12 = Some (Vint size) ->
    Mem.load Mptr counted handler 4 = Some (Vint Int.zero) ->
    Mem.load Mptr counted handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.valid_pointer counted source
      (Ptrofs.unsigned (demo_loader_source_offset offset)) = true ->
    eval_funcall function_entry2 ge counted (Internal us_memory.f_dma_read)
      [Vptr buffer Ptrofs.zero;
       Vptr source (demo_loader_source_offset offset);
       Vptr source (demo_loader_source_end offset size)] E0 dmaed Vundef ->
    Mem.load Mptr dmaed handler 0 = Some (Vptr table Ptrofs.zero) ->
    Mem.load Mptr dmaed handler 8 = Some (Vptr buffer Ptrofs.zero) ->
    Mem.load Mint32 dmaed table 0 = Some (Vint count) ->
    Mem.load Mint8unsigned dmaed buffer 0 = Some (Vint header) ->
    Mem.load Mint16unsigned dmaed index 0 = Some (Vint Int.zero) ->
    Mem.valid_access dmaed Mptr handler 4 Writable ->
    Mem.valid_access dmaed Mint16unsigned index 0 Writable ->
    Mem.valid_access dmaed Mptr current 0 Writable ->
    Mem.valid_access dmaed Mint16signed save 0 Writable ->
    Mem.valid_access dmaed Mint16signed act 0 Writable ->
    exists after le',
      exec_stmt function_entry2 ge (PTree.empty _) le before body E0 le' after
        (Out_return (Some (Vint (Int.sign_ext 8 header), tint))) /\
      Mem.load Mptr after current 0 = Some (Vptr buffer (Ptrofs.repr 4)).

Theorem generated_dma_to_first_title_executes :
  demo_dma_to_first_title_claim (fn_body LT.f_run_level_id_or_demo).
Proof.
  unfold demo_dma_to_first_title_claim.
  intros ge title_layout loader_layout le before cleared counted dmaed
    current countdown index player controller handler table buffer save act
    loader_code dma_code source count offset size header
    Hlevel Hcurrent Hcountdown Hindex Hplayer Hhandler Hsave Hact Hloadercode Hloaderfd
    Hdmacode Hdmafd Hcp Hcc Hct Hci Hti Hih Hit Hib Hic Hhc Hbc Hcs Hca Hsa Hht Hhb
    Hclear Hplayerload Hbuttons Hmagnitude Htimer Hindexcounted Hcountstore
    Htable0 Hcount0 Hpositive Hnotwrap Hsource Hoffset Hsize Hempty Htarget0 Hvalid
    Hdma Htable1 Htarget1 Hcount1 Hheader Hindex1 Hwcache Hwindex Hwcurrent Hwsave Hwact.
  destruct (generated_first_demo_loader_cache_miss_executes ge loader_layout counted dmaed
    handler table source buffer dma_code count offset size Hdmacode Hdmafd Htable0
    Hcount0 Hpositive Hsource Hoffset Hsize Hempty Htarget0 Hvalid Hdma Hwcache)
    as (loaded & Hloader & Hcache & Hcacheload).
  destruct (generated_demo_loader_cache_store_preserves_title_reads dmaed loaded
    handler table buffer index source (demo_loader_source_offset offset) count header
    Int.zero Hcache Hht Hhb ltac:(congruence) Htable1 Htarget1 Hcount1 Hheader Hindex1)
    as (Htable & Htarget & Hcount & Hhead & Hindexloaded).
  destruct (Mem.valid_access_store loaded Mint16unsigned index 0 (Vint Int.one)
    ltac:(demo_access)) as (indexed & Hindexstore).
  pose proof generated_first_title_start_executes as Htitle.
  unfold demo_first_title_start_claim in Htitle.
  specialize (Htitle ge title_layout).
  eapply (Htitle le before cleared counted loaded indexed current countdown index
    player controller handler table buffer save act loader_code count header Int.one);
    first [eassumption | demo_access |
      match goal with |- ?g => idtac "LOADED TITLE REMAINING" g end; fail 1].
Qed.

Definition demo_dma_to_first_title_claim_us_jp : Prop :=
  demo_dma_to_first_title_claim (fn_body LT.f_run_level_id_or_demo) /\
  demo_dma_to_first_title_claim (fn_body jp_title_screen.f_run_level_id_or_demo).

Theorem generated_dma_to_first_title_us_jp : demo_dma_to_first_title_claim_us_jp.
Proof. split; exact generated_dma_to_first_title_executes. Qed.
