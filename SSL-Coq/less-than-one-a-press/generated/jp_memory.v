(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/game/memory.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   ====================================================================== *)
From Coq Require Import String List ZArith.
From compcert Require Import Coqlib Integers Floats AST Ctypes Cop Clight Clightdefs.
Import Clightdefs.ClightNotations.
Local Open Scope Z_scope.
Local Open Scope string_scope.
Local Open Scope clight_scope.

Module Info.
  Definition version := "3.15".
  Definition build_number := "".
  Definition build_tag := "".
  Definition build_branch := "".
  Definition arch := "powerpc".
  Definition model := "ppc32".
  Definition abi := "eabi".
  Definition bitsize := 32.
  Definition big_endian := true.
  Definition source_file := "build/pinned-sm64/src/game/memory.c".
  Definition normalized := true.
End Info.

Definition _AllocOnlyPool : ident := $"AllocOnlyPool".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _MainPoolBlock : ident := $"MainPoolBlock".
Definition _MainPoolState : ident := $"MainPoolState".
Definition _MemoryBlock : ident := $"MemoryBlock".
Definition _MemoryPool : ident := $"MemoryPool".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition __248 : ident := $"_248".
Definition __249 : ident := $"_249".
Definition __251 : ident := $"_251".
Definition __253 : ident := $"_253".
Definition __421 : ident := $"_421".
Definition __423 : ident := $"_423".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition ___builtin_ais_annot : ident := $"__builtin_ais_annot".
Definition ___builtin_annot : ident := $"__builtin_annot".
Definition ___builtin_annot_intval : ident := $"__builtin_annot_intval".
Definition ___builtin_atomic_compare_exchange : ident := $"__builtin_atomic_compare_exchange".
Definition ___builtin_atomic_exchange : ident := $"__builtin_atomic_exchange".
Definition ___builtin_atomic_load : ident := $"__builtin_atomic_load".
Definition ___builtin_bsel : ident := $"__builtin_bsel".
Definition ___builtin_bswap : ident := $"__builtin_bswap".
Definition ___builtin_bswap16 : ident := $"__builtin_bswap16".
Definition ___builtin_bswap32 : ident := $"__builtin_bswap32".
Definition ___builtin_bswap64 : ident := $"__builtin_bswap64".
Definition ___builtin_call_frame : ident := $"__builtin_call_frame".
Definition ___builtin_clz : ident := $"__builtin_clz".
Definition ___builtin_clzl : ident := $"__builtin_clzl".
Definition ___builtin_clzll : ident := $"__builtin_clzll".
Definition ___builtin_cmpb : ident := $"__builtin_cmpb".
Definition ___builtin_ctz : ident := $"__builtin_ctz".
Definition ___builtin_ctzl : ident := $"__builtin_ctzl".
Definition ___builtin_ctzll : ident := $"__builtin_ctzll".
Definition ___builtin_dcbf : ident := $"__builtin_dcbf".
Definition ___builtin_dcbi : ident := $"__builtin_dcbi".
Definition ___builtin_dcbtls : ident := $"__builtin_dcbtls".
Definition ___builtin_dcbz : ident := $"__builtin_dcbz".
Definition ___builtin_debug : ident := $"__builtin_debug".
Definition ___builtin_eieio : ident := $"__builtin_eieio".
Definition ___builtin_expect : ident := $"__builtin_expect".
Definition ___builtin_fabs : ident := $"__builtin_fabs".
Definition ___builtin_fabsf : ident := $"__builtin_fabsf".
Definition ___builtin_fcti : ident := $"__builtin_fcti".
Definition ___builtin_fmadd : ident := $"__builtin_fmadd".
Definition ___builtin_fmsub : ident := $"__builtin_fmsub".
Definition ___builtin_fnmadd : ident := $"__builtin_fnmadd".
Definition ___builtin_fnmsub : ident := $"__builtin_fnmsub".
Definition ___builtin_fres : ident := $"__builtin_fres".
Definition ___builtin_frsqrte : ident := $"__builtin_frsqrte".
Definition ___builtin_fsel : ident := $"__builtin_fsel".
Definition ___builtin_fsqrt : ident := $"__builtin_fsqrt".
Definition ___builtin_get_spr : ident := $"__builtin_get_spr".
Definition ___builtin_get_spr64 : ident := $"__builtin_get_spr64".
Definition ___builtin_icbi : ident := $"__builtin_icbi".
Definition ___builtin_icbtls : ident := $"__builtin_icbtls".
Definition ___builtin_isel : ident := $"__builtin_isel".
Definition ___builtin_isel64 : ident := $"__builtin_isel64".
Definition ___builtin_isync : ident := $"__builtin_isync".
Definition ___builtin_lwsync : ident := $"__builtin_lwsync".
Definition ___builtin_mbar : ident := $"__builtin_mbar".
Definition ___builtin_membar : ident := $"__builtin_membar".
Definition ___builtin_memcpy_aligned : ident := $"__builtin_memcpy_aligned".
Definition ___builtin_mr : ident := $"__builtin_mr".
Definition ___builtin_mulhd : ident := $"__builtin_mulhd".
Definition ___builtin_mulhdu : ident := $"__builtin_mulhdu".
Definition ___builtin_mulhw : ident := $"__builtin_mulhw".
Definition ___builtin_mulhwu : ident := $"__builtin_mulhwu".
Definition ___builtin_nop : ident := $"__builtin_nop".
Definition ___builtin_prefetch : ident := $"__builtin_prefetch".
Definition ___builtin_read16_reversed : ident := $"__builtin_read16_reversed".
Definition ___builtin_read32_reversed : ident := $"__builtin_read32_reversed".
Definition ___builtin_read64_reversed : ident := $"__builtin_read64_reversed".
Definition ___builtin_return_address : ident := $"__builtin_return_address".
Definition ___builtin_sel : ident := $"__builtin_sel".
Definition ___builtin_set_spr : ident := $"__builtin_set_spr".
Definition ___builtin_set_spr64 : ident := $"__builtin_set_spr64".
Definition ___builtin_sqrt : ident := $"__builtin_sqrt".
Definition ___builtin_sync : ident := $"__builtin_sync".
Definition ___builtin_sync_fetch_and_add : ident := $"__builtin_sync_fetch_and_add".
Definition ___builtin_trap : ident := $"__builtin_trap".
Definition ___builtin_uisel : ident := $"__builtin_uisel".
Definition ___builtin_uisel64 : ident := $"__builtin_uisel64".
Definition ___builtin_unreachable : ident := $"__builtin_unreachable".
Definition ___builtin_va_arg : ident := $"__builtin_va_arg".
Definition ___builtin_va_copy : ident := $"__builtin_va_copy".
Definition ___builtin_va_end : ident := $"__builtin_va_end".
Definition ___builtin_va_start : ident := $"__builtin_va_start".
Definition ___builtin_write16_reversed : ident := $"__builtin_write16_reversed".
Definition ___builtin_write32_reversed : ident := $"__builtin_write32_reversed".
Definition ___builtin_write64_reversed : ident := $"__builtin_write64_reversed".
Definition ___compcert_i64_dtos : ident := $"__compcert_i64_dtos".
Definition ___compcert_i64_dtou : ident := $"__compcert_i64_dtou".
Definition ___compcert_i64_sar : ident := $"__compcert_i64_sar".
Definition ___compcert_i64_sdiv : ident := $"__compcert_i64_sdiv".
Definition ___compcert_i64_shl : ident := $"__compcert_i64_shl".
Definition ___compcert_i64_shr : ident := $"__compcert_i64_shr".
Definition ___compcert_i64_smod : ident := $"__compcert_i64_smod".
Definition ___compcert_i64_smulh : ident := $"__compcert_i64_smulh".
Definition ___compcert_i64_stod : ident := $"__compcert_i64_stod".
Definition ___compcert_i64_stof : ident := $"__compcert_i64_stof".
Definition ___compcert_i64_udiv : ident := $"__compcert_i64_udiv".
Definition ___compcert_i64_umod : ident := $"__compcert_i64_umod".
Definition ___compcert_i64_umulh : ident := $"__compcert_i64_umulh".
Definition ___compcert_i64_utod : ident := $"__compcert_i64_utod".
Definition ___compcert_i64_utof : ident := $"__compcert_i64_utof".
Definition ___compcert_va_composite : ident := $"__compcert_va_composite".
Definition ___compcert_va_float64 : ident := $"__compcert_va_float64".
Definition ___compcert_va_int32 : ident := $"__compcert_va_int32".
Definition ___compcert_va_int64 : ident := $"__compcert_va_int64".
Definition __engineSegmentRomEnd : ident := $"_engineSegmentRomEnd".
Definition __engineSegmentRomStart : ident := $"_engineSegmentRomStart".
Definition __g : ident := $"_g".
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _addr : ident := $"addr".
Definition _alignedSize : ident := $"alignedSize".
Definition _alloc_display_list : ident := $"alloc_display_list".
Definition _alloc_only_pool_alloc : ident := $"alloc_only_pool_alloc".
Definition _alloc_only_pool_init : ident := $"alloc_only_pool_init".
Definition _alloc_only_pool_resize : ident := $"alloc_only_pool_resize".
Definition _anim : ident := $"anim".
Definition _at : ident := $"at".
Definition _badvaddr : ident := $"badvaddr".
Definition _block : ident := $"block".
Definition _bufTarget : ident := $"bufTarget".
Definition _buffer : ident := $"buffer".
Definition _bzero : ident := $"bzero".
Definition _cause : ident := $"cause".
Definition _compSize : ident := $"compSize".
Definition _compressed : ident := $"compressed".
Definition _context : ident := $"context".
Definition _copySize : ident := $"copySize".
Definition _count : ident := $"count".
Definition _currentAddr : ident := $"currentAddr".
Definition _decompress : ident := $"decompress".
Definition _dest : ident := $"dest".
Definition _destAddr : ident := $"destAddr".
Definition _destSize : ident := $"destSize".
Definition _devAddr : ident := $"devAddr".
Definition _dmaTable : ident := $"dmaTable".
Definition _dma_read : ident := $"dma_read".
Definition _dramAddr : ident := $"dramAddr".
Definition _dynamic_dma_read : ident := $"dynamic_dma_read".
Definition _end : ident := $"end".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _first : ident := $"first".
Definition _firstBlock : ident := $"firstBlock".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _fp : ident := $"fp".
Definition _fp0 : ident := $"fp0".
Definition _fp10 : ident := $"fp10".
Definition _fp12 : ident := $"fp12".
Definition _fp14 : ident := $"fp14".
Definition _fp16 : ident := $"fp16".
Definition _fp18 : ident := $"fp18".
Definition _fp2 : ident := $"fp2".
Definition _fp20 : ident := $"fp20".
Definition _fp22 : ident := $"fp22".
Definition _fp24 : ident := $"fp24".
Definition _fp26 : ident := $"fp26".
Definition _fp28 : ident := $"fp28".
Definition _fp30 : ident := $"fp30".
Definition _fp4 : ident := $"fp4".
Definition _fp6 : ident := $"fp6".
Definition _fp8 : ident := $"fp8".
Definition _fpcsr : ident := $"fpcsr".
Definition _freeBlock : ident := $"freeBlock".
Definition _freeList : ident := $"freeList".
Definition _freePtr : ident := $"freePtr".
Definition _freeSpace : ident := $"freeSpace".
Definition _fullqueue : ident := $"fullqueue".
Definition _gDecompressionHeap : ident := $"gDecompressionHeap".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gDmaIoMesg : ident := $"gDmaIoMesg".
Definition _gDmaMesgQueue : ident := $"gDmaMesgQueue".
Definition _gEffectsMemoryPool : ident := $"gEffectsMemoryPool".
Definition _gGfxPoolEnd : ident := $"gGfxPoolEnd".
Definition _gMainPoolState : ident := $"gMainPoolState".
Definition _gMainReceivedMesg : ident := $"gMainReceivedMesg".
Definition _get_segment_base_addr : ident := $"get_segment_base_addr".
Definition _gp : ident := $"gp".
Definition _hdr : ident := $"hdr".
Definition _hi : ident := $"hi".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _lhead : ident := $"lhead".
Definition _list : ident := $"list".
Definition _listHeadL : ident := $"listHeadL".
Definition _listHeadR : ident := $"listHeadR".
Definition _lo : ident := $"lo".
Definition _load_dma_table_address : ident := $"load_dma_table_address".
Definition _load_engine_code_segment : ident := $"load_engine_code_segment".
Definition _load_patchable_table : ident := $"load_patchable_table".
Definition _load_segment : ident := $"load_segment".
Definition _load_segment_decompress : ident := $"load_segment_decompress".
Definition _load_segment_decompress_heap : ident := $"load_segment_decompress_heap".
Definition _load_to_fixed_pool_addr : ident := $"load_to_fixed_pool_addr".
Definition _main : ident := $"main".
Definition _main_pool_alloc : ident := $"main_pool_alloc".
Definition _main_pool_available : ident := $"main_pool_available".
Definition _main_pool_free : ident := $"main_pool_free".
Definition _main_pool_init : ident := $"main_pool_init".
Definition _main_pool_pop_state : ident := $"main_pool_pop_state".
Definition _main_pool_push_state : ident := $"main_pool_push_state".
Definition _main_pool_realloc : ident := $"main_pool_realloc".
Definition _mem_pool_alloc : ident := $"mem_pool_alloc".
Definition _mem_pool_free : ident := $"mem_pool_free".
Definition _mem_pool_init : ident := $"mem_pool_init".
Definition _move_segment_table_to_dmem : ident := $"move_segment_table_to_dmem".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _mtqueue : ident := $"mtqueue".
Definition _newAddr : ident := $"newAddr".
Definition _newBlock : ident := $"newBlock".
Definition _newListHead : ident := $"newListHead".
Definition _newPool : ident := $"newPool".
Definition _next : ident := $"next".
Definition _offset : ident := $"offset".
Definition _oldListHead : ident := $"oldListHead".
Definition _osInvalDCache : ident := $"osInvalDCache".
Definition _osInvalICache : ident := $"osInvalICache".
Definition _osPiStartDma : ident := $"osPiStartDma".
Definition _osRecvMesg : ident := $"osRecvMesg".
Definition _osWritebackDCacheAll : ident := $"osWritebackDCacheAll".
Definition _pUncSize : ident := $"pUncSize".
Definition _pc : ident := $"pc".
Definition _pool : ident := $"pool".
Definition _prev : ident := $"prev".
Definition _prevState : ident := $"prevState".
Definition _pri : ident := $"pri".
Definition _priority : ident := $"priority".
Definition _ptr : ident := $"ptr".
Definition _queue : ident := $"queue".
Definition _ra : ident := $"ra".
Definition _rcp : ident := $"rcp".
Definition _ret : ident := $"ret".
Definition _retQueue : ident := $"retQueue".
Definition _rhead : ident := $"rhead".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sPoolEnd : ident := $"sPoolEnd".
Definition _sPoolFreeSpace : ident := $"sPoolFreeSpace".
Definition _sPoolListHeadL : ident := $"sPoolListHeadL".
Definition _sPoolListHeadR : ident := $"sPoolListHeadR".
Definition _sPoolStart : ident := $"sPoolStart".
Definition _sSegmentTable : ident := $"sSegmentTable".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_segment_base_addr : ident := $"set_segment_base_addr".
Definition _setup_dma_table_list : ident := $"setup_dma_table_list".
Definition _side : ident := $"side".
Definition _size : ident := $"size".
Definition _sp : ident := $"sp".
Definition _sr : ident := $"sr".
Definition _srcAddr : ident := $"srcAddr".
Definition _srcEnd : ident := $"srcEnd".
Definition _srcSize : ident := $"srcSize".
Definition _srcStart : ident := $"srcStart".
Definition _start : ident := $"start".
Definition _startAddr : ident := $"startAddr".
Definition _startPtr : ident := $"startPtr".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _subPool : ident := $"subPool".
Definition _t0 : ident := $"t0".
Definition _t1 : ident := $"t1".
Definition _t2 : ident := $"t2".
Definition _t3 : ident := $"t3".
Definition _t4 : ident := $"t4".
Definition _t5 : ident := $"t5".
Definition _t6 : ident := $"t6".
Definition _t7 : ident := $"t7".
Definition _t8 : ident := $"t8".
Definition _t9 : ident := $"t9".
Definition _table : ident := $"table".
Definition _thprof : ident := $"thprof".
Definition _time : ident := $"time".
Definition _tlnext : ident := $"tlnext".
Definition _totalSize : ident := $"totalSize".
Definition _totalSpace : ident := $"totalSpace".
Definition _type : ident := $"type".
Definition _usedSpace : ident := $"usedSpace".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _virtual_to_segmented : ident := $"virtual_to_segmented".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _words : ident := $"words".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'12 : ident := 139%positive.
Definition _t'13 : ident := 140%positive.
Definition _t'14 : ident := 141%positive.
Definition _t'15 : ident := 142%positive.
Definition _t'16 : ident := 143%positive.
Definition _t'17 : ident := 144%positive.
Definition _t'18 : ident := 145%positive.
Definition _t'19 : ident := 146%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'20 : ident := 147%positive.
Definition _t'21 : ident := 148%positive.
Definition _t'22 : ident := 149%positive.
Definition _t'23 : ident := 150%positive.
Definition _t'24 : ident := 151%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __512 noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxPoolEnd := {|
  gvar_info := (tptr tuchar);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDecompressionHeap := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDmaIoMesg := {|
  gvar_info := (Tstruct __423 noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMainReceivedMesg := {|
  gvar_info := (tptr tvoid);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDmaMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__engineSegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__engineSegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEffectsMemoryPool := {|
  gvar_info := (tptr (Tstruct _MemoryPool noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSegmentTable := {|
  gvar_info := (tarray tuint 32);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPoolFreeSpace := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPoolStart := {|
  gvar_info := (tptr tuchar);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPoolEnd := {|
  gvar_info := (tptr tuchar);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPoolListHeadL := {|
  gvar_info := (tptr (Tstruct _MainPoolBlock noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPoolListHeadR := {|
  gvar_info := (tptr (Tstruct _MainPoolBlock noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMainPoolState := {|
  gvar_info := (tptr (Tstruct _MainPoolState noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_set_segment_base_addr := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_segment, tint) :: (_addr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
        (Etempvar _segment tint) (tptr tuint)) tuint)
    (Ebinop Oand (Ecast (Etempvar _addr (tptr tvoid)) tuint)
      (Econst_int (Int.repr 536870911) tint) tuint))
  (Ssequence
    (Sset _t'1
      (Ederef
        (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
          (Etempvar _segment tint) (tptr tuint)) tuint))
    (Sreturn (Some (Etempvar _t'1 tuint)))))
|}.

Definition f_get_segment_base_addr := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_segment, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Ederef
      (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
        (Etempvar _segment tint) (tptr tuint)) tuint))
  (Sreturn (Some (Ecast
                   (Ebinop Oor (Etempvar _t'1 tuint)
                     (Econst_int (Int.repr (-2147483648)) tuint) tuint)
                   (tptr tvoid)))))
|}.

Definition f_segmented_to_virtual := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_addr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_segment, tuint) :: (_offset, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _segment
    (Ebinop Oshr (Ecast (Etempvar _addr (tptr tvoid)) tuint)
      (Econst_int (Int.repr 24) tint) tuint))
  (Ssequence
    (Sset _offset
      (Ebinop Oand (Ecast (Etempvar _addr (tptr tvoid)) tuint)
        (Econst_int (Int.repr 16777215) tint) tuint))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
            (Etempvar _segment tuint) (tptr tuint)) tuint))
      (Sreturn (Some (Ecast
                       (Ebinop Oor
                         (Ebinop Oadd (Etempvar _t'1 tuint)
                           (Etempvar _offset tuint) tuint)
                         (Econst_int (Int.repr (-2147483648)) tuint) tuint)
                       (tptr tvoid)))))))
|}.

Definition f_virtual_to_segmented := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_segment, tuint) :: (_addr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_offset, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Ederef
        (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
          (Etempvar _segment tuint) (tptr tuint)) tuint))
    (Sset _offset
      (Ebinop Osub
        (Ebinop Oand (Ecast (Etempvar _addr (tptr tvoid)) tuint)
          (Econst_int (Int.repr 536870911) tint) tuint) (Etempvar _t'1 tuint)
        tuint)))
  (Sreturn (Some (Ecast
                   (Ebinop Oadd
                     (Ebinop Oshl (Etempvar _segment tuint)
                       (Econst_int (Int.repr 24) tint) tuint)
                     (Etempvar _offset tuint) tuint) (tptr tvoid)))))
|}.

Definition f_move_segment_table_to_dmem := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (__g, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr (Tunion __512 noattr))) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Econst_int (Int.repr 0) tint))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                     (Econst_int (Int.repr 16) tint) tint)
        Sskip
        Sbreak)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __512 noattr)))
              (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __512 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __512 noattr)))))
          (Sset __g
            (Ecast (Etempvar _t'1 (tptr (Tunion __512 noattr)))
              (tptr (Tunion __512 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                  (Tunion __512 noattr)) _words (Tstruct __510 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Osub
                          (Eunop Oneg (Econst_int (Int.repr 65) tint) tint)
                          (Econst_int (Int.repr 3) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Omul (Etempvar _i tint)
                          (Econst_int (Int.repr 4) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 6) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd (Evar _sSegmentTable (tarray tuint 32))
                  (Etempvar _i tint) (tptr tuint)) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __512 noattr)))
                    (Tunion __512 noattr)) _words (Tstruct __510 noattr)) _w1
                tuint) (Ecast (Etempvar _t'2 tuint) tuint))))))
    (Sset _i
      (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_main_pool_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_start, (tptr tvoid)) :: (_end, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, (tptr tuchar)) :: (_t'7, (tptr tuchar)) ::
               (_t'6, (tptr tuchar)) :: (_t'5, (tptr tuchar)) ::
               (_t'4, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'3, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'2, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'1, (tptr (Tstruct _MainPoolBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sPoolStart (tptr tuchar))
    (Ebinop Oadd
      (Ecast
        (Ebinop Oand
          (Ebinop Oadd (Ecast (Etempvar _start (tptr tvoid)) tuint)
            (Econst_int (Int.repr 15) tint) tuint)
          (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tuint)
        (tptr tuchar)) (Econst_int (Int.repr 16) tint) (tptr tuchar)))
  (Ssequence
    (Sassign (Evar _sPoolEnd (tptr tuchar))
      (Ebinop Osub
        (Ecast
          (Ebinop Oand
            (Ebinop Oadd
              (Ebinop Osub (Ecast (Etempvar _end (tptr tvoid)) tuint)
                (Econst_int (Int.repr 15) tint) tuint)
              (Econst_int (Int.repr 15) tint) tuint)
            (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tuint)
          (tptr tuchar)) (Econst_int (Int.repr 16) tint) (tptr tuchar)))
    (Ssequence
      (Ssequence
        (Sset _t'7 (Evar _sPoolEnd (tptr tuchar)))
        (Ssequence
          (Sset _t'8 (Evar _sPoolStart (tptr tuchar)))
          (Sassign (Evar _sPoolFreeSpace tuint)
            (Ebinop Osub (Etempvar _t'7 (tptr tuchar))
              (Etempvar _t'8 (tptr tuchar)) tint))))
      (Ssequence
        (Ssequence
          (Sset _t'6 (Evar _sPoolStart (tptr tuchar)))
          (Sassign
            (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr)))
            (Ecast
              (Ebinop Osub (Etempvar _t'6 (tptr tuchar))
                (Econst_int (Int.repr 16) tint) (tptr tuchar))
              (tptr (Tstruct _MainPoolBlock noattr)))))
        (Ssequence
          (Ssequence
            (Sset _t'5 (Evar _sPoolEnd (tptr tuchar)))
            (Sassign
              (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr)))
              (Ecast (Etempvar _t'5 (tptr tuchar))
                (tptr (Tstruct _MainPoolBlock noattr)))))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _MainPoolBlock noattr)))
                    (Tstruct _MainPoolBlock noattr)) _prev
                  (tptr (Tstruct _MainPoolBlock noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'3 (tptr (Tstruct _MainPoolBlock noattr)))
                      (Tstruct _MainPoolBlock noattr)) _next
                    (tptr (Tstruct _MainPoolBlock noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'2 (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _prev
                      (tptr (Tstruct _MainPoolBlock noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
                (Ssequence
                  (Sset _t'1
                    (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'1 (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _next
                      (tptr (Tstruct _MainPoolBlock noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))))))))
|}.

Definition f_main_pool_alloc := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_size, tuint) :: (_side, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_newListHead, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_addr, (tptr tvoid)) :: (_t'1, tint) :: (_t'11, tuint) ::
               (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'8, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'7, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'6, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'5, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'4, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'3, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'2, (tptr (Tstruct _MainPoolBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _addr (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _size
      (Ebinop Oadd
        (Ebinop Oand
          (Ebinop Oadd (Etempvar _size tuint) (Econst_int (Int.repr 15) tint)
            tuint) (Eunop Onotint (Econst_int (Int.repr 15) tint) tint)
          tuint) (Econst_int (Int.repr 16) tint) tuint))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _size tuint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'11 (Evar _sPoolFreeSpace tuint))
            (Sset _t'1
              (Ecast
                (Ebinop Oge (Etempvar _t'11 tuint) (Etempvar _size tuint)
                  tint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Ssequence
              (Sset _t'10 (Evar _sPoolFreeSpace tuint))
              (Sassign (Evar _sPoolFreeSpace tuint)
                (Ebinop Osub (Etempvar _t'10 tuint) (Etempvar _size tuint)
                  tuint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _side tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sset _newListHead
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _t'9 (tptr (Tstruct _MainPoolBlock noattr)))
                          (tptr tuchar)) (Etempvar _size tuint)
                        (tptr tuchar))
                      (tptr (Tstruct _MainPoolBlock noattr)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'8 (tptr (Tstruct _MainPoolBlock noattr)))
                          (Tstruct _MainPoolBlock noattr)) _next
                        (tptr (Tstruct _MainPoolBlock noattr)))
                      (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            (Tstruct _MainPoolBlock noattr)) _prev
                          (tptr (Tstruct _MainPoolBlock noattr)))
                        (Etempvar _t'7 (tptr (Tstruct _MainPoolBlock noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            (Tstruct _MainPoolBlock noattr)) _next
                          (tptr (Tstruct _MainPoolBlock noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                          (Sset _addr
                            (Ebinop Oadd
                              (Ecast
                                (Etempvar _t'6 (tptr (Tstruct _MainPoolBlock noattr)))
                                (tptr tuchar))
                              (Econst_int (Int.repr 16) tint) (tptr tuchar))))
                        (Sassign
                          (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr)))
                          (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))))))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sset _newListHead
                    (Ecast
                      (Ebinop Osub
                        (Ecast
                          (Etempvar _t'5 (tptr (Tstruct _MainPoolBlock noattr)))
                          (tptr tuchar)) (Etempvar _size tuint)
                        (tptr tuchar))
                      (tptr (Tstruct _MainPoolBlock noattr)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _MainPoolBlock noattr)))
                          (Tstruct _MainPoolBlock noattr)) _prev
                        (tptr (Tstruct _MainPoolBlock noattr)))
                      (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            (Tstruct _MainPoolBlock noattr)) _next
                          (tptr (Tstruct _MainPoolBlock noattr)))
                        (Etempvar _t'3 (tptr (Tstruct _MainPoolBlock noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            (Tstruct _MainPoolBlock noattr)) _prev
                          (tptr (Tstruct _MainPoolBlock noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Ssequence
                        (Sassign
                          (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr)))
                          (Etempvar _newListHead (tptr (Tstruct _MainPoolBlock noattr))))
                        (Ssequence
                          (Sset _t'2
                            (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                          (Sset _addr
                            (Ebinop Oadd
                              (Ecast
                                (Etempvar _t'2 (tptr (Tstruct _MainPoolBlock noattr)))
                                (tptr tuchar))
                              (Econst_int (Int.repr 16) tint) (tptr tuchar)))))))))))
          Sskip))
      (Sreturn (Some (Etempvar _addr (tptr tvoid)))))))
|}.

Definition f_main_pool_free := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_addr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_block, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_oldListHead, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'11, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'10, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'9, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'8, tuint) ::
               (_t'7, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'6, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'5, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'4, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'3, tuint) ::
               (_t'2, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _block
    (Ecast
      (Ebinop Osub (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
        (Econst_int (Int.repr 16) tint) (tptr tuchar))
      (tptr (Tstruct _MainPoolBlock noattr))))
  (Ssequence
    (Sset _oldListHead
      (Ecast
        (Ebinop Osub (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
          (Econst_int (Int.repr 16) tint) (tptr tuchar))
        (tptr (Tstruct _MainPoolBlock noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
        (Sifthenelse (Ebinop Olt
                       (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                       (Etempvar _t'2 (tptr (Tstruct _MainPoolBlock noattr)))
                       tint)
          (Ssequence
            (Sloop
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _next
                      (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'11 (tptr (Tstruct _MainPoolBlock noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    Sskip
                    Sbreak))
                (Sset _oldListHead
                  (Efield
                    (Ederef
                      (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                      (Tstruct _MainPoolBlock noattr)) _next
                    (tptr (Tstruct _MainPoolBlock noattr)))))
              Sskip)
            (Ssequence
              (Sassign
                (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr)))
                (Etempvar _block (tptr (Tstruct _MainPoolBlock noattr))))
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _next
                      (tptr (Tstruct _MainPoolBlock noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
                (Ssequence
                  (Sset _t'8 (Evar _sPoolFreeSpace tuint))
                  (Ssequence
                    (Sset _t'9
                      (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
                    (Sassign (Evar _sPoolFreeSpace tuint)
                      (Ebinop Oadd (Etempvar _t'8 tuint)
                        (Ebinop Osub
                          (Ecast
                            (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            tuint)
                          (Ecast
                            (Etempvar _t'9 (tptr (Tstruct _MainPoolBlock noattr)))
                            tuint) tuint) tuint)))))))
          (Ssequence
            (Sloop
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _prev
                      (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sifthenelse (Ebinop One
                                 (Etempvar _t'7 (tptr (Tstruct _MainPoolBlock noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    Sskip
                    Sbreak))
                (Sset _oldListHead
                  (Efield
                    (Ederef
                      (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                      (Tstruct _MainPoolBlock noattr)) _prev
                    (tptr (Tstruct _MainPoolBlock noattr)))))
              Sskip)
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef
                      (Etempvar _block (tptr (Tstruct _MainPoolBlock noattr)))
                      (Tstruct _MainPoolBlock noattr)) _next
                    (tptr (Tstruct _MainPoolBlock noattr))))
                (Sassign
                  (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr)))
                  (Etempvar _t'6 (tptr (Tstruct _MainPoolBlock noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'5 (tptr (Tstruct _MainPoolBlock noattr)))
                        (Tstruct _MainPoolBlock noattr)) _prev
                      (tptr (Tstruct _MainPoolBlock noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
                (Ssequence
                  (Sset _t'3 (Evar _sPoolFreeSpace tuint))
                  (Ssequence
                    (Sset _t'4
                      (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
                    (Sassign (Evar _sPoolFreeSpace tuint)
                      (Ebinop Oadd (Etempvar _t'3 tuint)
                        (Ebinop Osub
                          (Ecast
                            (Etempvar _t'4 (tptr (Tstruct _MainPoolBlock noattr)))
                            tuint)
                          (Ecast
                            (Etempvar _oldListHead (tptr (Tstruct _MainPoolBlock noattr)))
                            tuint) tuint) tuint)))))))))
      (Ssequence
        (Sset _t'1 (Evar _sPoolFreeSpace tuint))
        (Sreturn (Some (Etempvar _t'1 tuint)))))))
|}.

Definition f_main_pool_realloc := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_addr, (tptr tvoid)) :: (_size, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_newAddr, (tptr tvoid)) ::
               (_block, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'3, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'2, (tptr (Tstruct _MainPoolBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _newAddr (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _block
      (Ecast
        (Ebinop Osub (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
          (Econst_int (Int.repr 16) tint) (tptr tuchar))
        (tptr (Tstruct _MainPoolBlock noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _block (tptr (Tstruct _MainPoolBlock noattr)))
              (Tstruct _MainPoolBlock noattr)) _next
            (tptr (Tstruct _MainPoolBlock noattr))))
        (Ssequence
          (Sset _t'3
            (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'2 (tptr (Tstruct _MainPoolBlock noattr)))
                         (Etempvar _t'3 (tptr (Tstruct _MainPoolBlock noattr)))
                         tint)
            (Ssequence
              (Scall None
                (Evar _main_pool_free (Tfunction ((tptr tvoid) :: nil) tuint
                                        cc_default))
                ((Etempvar _addr (tptr tvoid)) :: nil))
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                           (tptr tvoid) cc_default))
                  ((Etempvar _size tuint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sset _newAddr (Etempvar _t'1 (tptr tvoid)))))
            Sskip)))
      (Sreturn (Some (Etempvar _newAddr (tptr tvoid)))))))
|}.

Definition f_main_pool_available := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sPoolFreeSpace tuint))
  (Sreturn (Some (Ebinop Osub (Etempvar _t'1 tuint)
                   (Econst_int (Int.repr 16) tint) tuint))))
|}.

Definition f_main_pool_push_state := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_prevState, (tptr (Tstruct _MainPoolState noattr))) ::
               (_freeSpace, tuint) ::
               (_lhead, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_rhead, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'1, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'5, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'4, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'3, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _prevState
    (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
  (Ssequence
    (Sset _freeSpace (Evar _sPoolFreeSpace tuint))
    (Ssequence
      (Sset _lhead
        (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr))))
      (Ssequence
        (Sset _rhead
          (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                       (tptr tvoid) cc_default))
              ((Esizeof (Tstruct _MainPoolState noattr) tuint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sassign
              (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr)))
              (Etempvar _t'1 (tptr tvoid))))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'6 (tptr (Tstruct _MainPoolState noattr)))
                    (Tstruct _MainPoolState noattr)) _freeSpace tuint)
                (Etempvar _freeSpace tuint)))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'5 (tptr (Tstruct _MainPoolState noattr)))
                      (Tstruct _MainPoolState noattr)) _listHeadL
                    (tptr (Tstruct _MainPoolBlock noattr)))
                  (Etempvar _lhead (tptr (Tstruct _MainPoolBlock noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'4 (tptr (Tstruct _MainPoolState noattr)))
                        (Tstruct _MainPoolState noattr)) _listHeadR
                      (tptr (Tstruct _MainPoolBlock noattr)))
                    (Etempvar _rhead (tptr (Tstruct _MainPoolBlock noattr)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _MainPoolState noattr)))
                          (Tstruct _MainPoolState noattr)) _prev
                        (tptr (Tstruct _MainPoolState noattr)))
                      (Etempvar _prevState (tptr (Tstruct _MainPoolState noattr)))))
                  (Ssequence
                    (Sset _t'2 (Evar _sPoolFreeSpace tuint))
                    (Sreturn (Some (Etempvar _t'2 tuint)))))))))))))
|}.

Definition f_main_pool_pop_state := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'7, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'6, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'5, (tptr (Tstruct _MainPoolBlock noattr))) ::
               (_t'4, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'3, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'2, (tptr (Tstruct _MainPoolState noattr))) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8 (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _t'8 (tptr (Tstruct _MainPoolState noattr)))
            (Tstruct _MainPoolState noattr)) _freeSpace tuint))
      (Sassign (Evar _sPoolFreeSpace tuint) (Etempvar _t'9 tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _t'6 (tptr (Tstruct _MainPoolState noattr)))
              (Tstruct _MainPoolState noattr)) _listHeadL
            (tptr (Tstruct _MainPoolBlock noattr))))
        (Sassign
          (Evar _sPoolListHeadL (tptr (Tstruct _MainPoolBlock noattr)))
          (Etempvar _t'7 (tptr (Tstruct _MainPoolBlock noattr))))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _MainPoolState noattr)))
                (Tstruct _MainPoolState noattr)) _listHeadR
              (tptr (Tstruct _MainPoolBlock noattr))))
          (Sassign
            (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr)))
            (Etempvar _t'5 (tptr (Tstruct _MainPoolBlock noattr))))))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef
                  (Etempvar _t'2 (tptr (Tstruct _MainPoolState noattr)))
                  (Tstruct _MainPoolState noattr)) _prev
                (tptr (Tstruct _MainPoolState noattr))))
            (Sassign
              (Evar _gMainPoolState (tptr (Tstruct _MainPoolState noattr)))
              (Etempvar _t'3 (tptr (Tstruct _MainPoolState noattr))))))
        (Ssequence
          (Sset _t'1 (Evar _sPoolFreeSpace tuint))
          (Sreturn (Some (Etempvar _t'1 tuint))))))))
|}.

Definition f_dma_read := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_dest, (tptr tuchar)) :: (_srcStart, (tptr tuchar)) ::
                (_srcEnd, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_size, tuint) :: (_copySize, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _size
    (Ebinop Oand
      (Ebinop Oadd
        (Ebinop Osub (Etempvar _srcEnd (tptr tuchar))
          (Etempvar _srcStart (tptr tuchar)) tint)
        (Econst_int (Int.repr 15) tint) tint)
      (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
  (Ssequence
    (Scall None
      (Evar _osInvalDCache (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                             cc_default))
      ((Etempvar _dest (tptr tuchar)) :: (Etempvar _size tuint) :: nil))
    (Swhile
      (Ebinop One (Etempvar _size tuint) (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oge (Etempvar _size tuint)
                         (Econst_int (Int.repr 4096) tint) tint)
            (Sset _t'1 (Ecast (Econst_int (Int.repr 4096) tint) tuint))
            (Sset _t'1 (Ecast (Etempvar _size tuint) tuint)))
          (Sset _copySize (Etempvar _t'1 tuint)))
        (Ssequence
          (Scall None
            (Evar _osPiStartDma (Tfunction
                                  ((tptr (Tstruct __423 noattr)) :: tint ::
                                   tint :: tuint :: (tptr tvoid) :: tuint ::
                                   (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                   nil) tint cc_default))
            ((Eaddrof (Evar _gDmaIoMesg (Tstruct __423 noattr))
               (tptr (Tstruct __423 noattr))) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) ::
             (Ecast (Etempvar _srcStart (tptr tuchar)) tuint) ::
             (Etempvar _dest (tptr tuchar)) :: (Etempvar _copySize tuint) ::
             (Eaddrof (Evar _gDmaMesgQueue (Tstruct _OSMesgQueue_s noattr))
               (tptr (Tstruct _OSMesgQueue_s noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _osRecvMesg (Tfunction
                                  ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                   (tptr (tptr tvoid)) :: tint :: nil) tint
                                  cc_default))
              ((Eaddrof (Evar _gDmaMesgQueue (Tstruct _OSMesgQueue_s noattr))
                 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid))
                 (tptr (tptr tvoid))) :: (Econst_int (Int.repr 1) tint) ::
               nil))
            (Ssequence
              (Sset _dest
                (Ebinop Oadd (Etempvar _dest (tptr tuchar))
                  (Etempvar _copySize tuint) (tptr tuchar)))
              (Ssequence
                (Sset _srcStart
                  (Ebinop Oadd (Etempvar _srcStart (tptr tuchar))
                    (Etempvar _copySize tuint) (tptr tuchar)))
                (Sset _size
                  (Ebinop Osub (Etempvar _size tuint)
                    (Etempvar _copySize tuint) tuint))))))))))
|}.

Definition f_dynamic_dma_read := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_srcStart, (tptr tuchar)) :: (_srcEnd, (tptr tuchar)) ::
                (_side, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_dest, (tptr tvoid)) :: (_size, tuint) ::
               (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sset _size
    (Ebinop Oand
      (Ebinop Oadd
        (Ebinop Osub (Etempvar _srcEnd (tptr tuchar))
          (Etempvar _srcStart (tptr tuchar)) tint)
        (Econst_int (Int.repr 15) tint) tint)
      (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                 (tptr tvoid) cc_default))
        ((Etempvar _size tuint) :: (Etempvar _side tuint) :: nil))
      (Sset _dest (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Sifthenelse (Ebinop One (Etempvar _dest (tptr tvoid))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Scall None
          (Evar _dma_read (Tfunction
                            ((tptr tuchar) :: (tptr tuchar) ::
                             (tptr tuchar) :: nil) tvoid cc_default))
          ((Etempvar _dest (tptr tvoid)) ::
           (Etempvar _srcStart (tptr tuchar)) ::
           (Etempvar _srcEnd (tptr tuchar)) :: nil))
        Sskip)
      (Sreturn (Some (Etempvar _dest (tptr tvoid)))))))
|}.

Definition f_load_segment := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_segment, tint) :: (_srcStart, (tptr tuchar)) ::
                (_srcEnd, (tptr tuchar)) :: (_side, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_addr, (tptr tvoid)) :: (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _dynamic_dma_read (Tfunction
                                ((tptr tuchar) :: (tptr tuchar) :: tuint ::
                                 nil) (tptr tvoid) cc_default))
      ((Etempvar _srcStart (tptr tuchar)) ::
       (Etempvar _srcEnd (tptr tuchar)) :: (Etempvar _side tuint) :: nil))
    (Sset _addr (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Sifthenelse (Ebinop One (Etempvar _addr (tptr tvoid))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Scall None
        (Evar _set_segment_base_addr (Tfunction (tint :: (tptr tvoid) :: nil)
                                       tuint cc_default))
        ((Etempvar _segment tint) :: (Etempvar _addr (tptr tvoid)) :: nil))
      Sskip)
    (Sreturn (Some (Etempvar _addr (tptr tvoid))))))
|}.

Definition f_load_to_fixed_pool_addr := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_destAddr, (tptr tuchar)) :: (_srcStart, (tptr tuchar)) ::
                (_srcEnd, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_dest, (tptr tvoid)) :: (_srcSize, tuint) ::
               (_destSize, tuint) :: (_t'1, (tptr tvoid)) ::
               (_t'2, (tptr (Tstruct _MainPoolBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _dest (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _srcSize
      (Ebinop Oand
        (Ebinop Oadd
          (Ebinop Osub (Etempvar _srcEnd (tptr tuchar))
            (Etempvar _srcStart (tptr tuchar)) tint)
          (Econst_int (Int.repr 15) tint) tint)
        (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Evar _sPoolListHeadR (tptr (Tstruct _MainPoolBlock noattr))))
        (Sset _destSize
          (Ebinop Oand
            (Ebinop Oadd
              (Ebinop Osub
                (Ecast (Etempvar _t'2 (tptr (Tstruct _MainPoolBlock noattr)))
                  (tptr tuchar)) (Etempvar _destAddr (tptr tuchar)) tint)
              (Econst_int (Int.repr 15) tint) tint)
            (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint)))
      (Ssequence
        (Sifthenelse (Ebinop Ole (Etempvar _srcSize tuint)
                       (Etempvar _destSize tuint) tint)
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                         (tptr tvoid) cc_default))
                ((Etempvar _destSize tuint) ::
                 (Econst_int (Int.repr 1) tint) :: nil))
              (Sset _dest (Etempvar _t'1 (tptr tvoid))))
            (Sifthenelse (Ebinop One (Etempvar _dest (tptr tvoid))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Scall None
                  (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil)
                                 tvoid cc_default))
                  ((Etempvar _dest (tptr tvoid)) ::
                   (Etempvar _destSize tuint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _osWritebackDCacheAll (Tfunction nil tvoid
                                                  cc_default)) nil)
                  (Ssequence
                    (Scall None
                      (Evar _dma_read (Tfunction
                                        ((tptr tuchar) :: (tptr tuchar) ::
                                         (tptr tuchar) :: nil) tvoid
                                        cc_default))
                      ((Etempvar _dest (tptr tvoid)) ::
                       (Etempvar _srcStart (tptr tuchar)) ::
                       (Etempvar _srcEnd (tptr tuchar)) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _osInvalICache (Tfunction
                                               ((tptr tvoid) :: tuint :: nil)
                                               tvoid cc_default))
                        ((Etempvar _dest (tptr tvoid)) ::
                         (Etempvar _destSize tuint) :: nil))
                      (Scall None
                        (Evar _osInvalDCache (Tfunction
                                               ((tptr tvoid) :: tuint :: nil)
                                               tvoid cc_default))
                        ((Etempvar _dest (tptr tvoid)) ::
                         (Etempvar _destSize tuint) :: nil))))))
              Sskip))
          Sskip)
        (Sreturn (Some (Etempvar _dest (tptr tvoid))))))))
|}.

Definition f_load_segment_decompress := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_segment, tint) :: (_srcStart, (tptr tuchar)) ::
                (_srcEnd, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_dest, (tptr tvoid)) :: (_compSize, tuint) ::
               (_compressed, (tptr tuchar)) :: (_size, (tptr tuint)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _dest (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _compSize
      (Ebinop Oand
        (Ebinop Oadd
          (Ebinop Osub (Etempvar _srcEnd (tptr tuchar))
            (Etempvar _srcStart (tptr tuchar)) tint)
          (Econst_int (Int.repr 15) tint) tint)
        (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                   (tptr tvoid) cc_default))
          ((Etempvar _compSize tuint) :: (Econst_int (Int.repr 1) tint) ::
           nil))
        (Sset _compressed (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Sset _size
          (Ecast
            (Ebinop Oadd (Etempvar _compressed (tptr tuchar))
              (Econst_int (Int.repr 4) tint) (tptr tuchar)) (tptr tuint)))
        (Ssequence
          (Sifthenelse (Ebinop One (Etempvar _compressed (tptr tuchar))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Scall None
                (Evar _dma_read (Tfunction
                                  ((tptr tuchar) :: (tptr tuchar) ::
                                   (tptr tuchar) :: nil) tvoid cc_default))
                ((Etempvar _compressed (tptr tuchar)) ::
                 (Etempvar _srcStart (tptr tuchar)) ::
                 (Etempvar _srcEnd (tptr tuchar)) :: nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'3 (Ederef (Etempvar _size (tptr tuint)) tuint))
                    (Scall (Some _t'2)
                      (Evar _main_pool_alloc (Tfunction
                                               (tuint :: tuint :: nil)
                                               (tptr tvoid) cc_default))
                      ((Etempvar _t'3 tuint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Sset _dest (Etempvar _t'2 (tptr tvoid))))
                (Sifthenelse (Ebinop One (Etempvar _dest (tptr tvoid))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Scall None
                      (Evar _decompress (Tfunction
                                          ((tptr tvoid) :: (tptr tvoid) ::
                                           nil) tvoid cc_default))
                      ((Etempvar _compressed (tptr tuchar)) ::
                       (Etempvar _dest (tptr tvoid)) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _set_segment_base_addr (Tfunction
                                                       (tint ::
                                                        (tptr tvoid) :: nil)
                                                       tuint cc_default))
                        ((Etempvar _segment tint) ::
                         (Etempvar _dest (tptr tvoid)) :: nil))
                      (Scall None
                        (Evar _main_pool_free (Tfunction
                                                ((tptr tvoid) :: nil) tuint
                                                cc_default))
                        ((Etempvar _compressed (tptr tuchar)) :: nil))))
                  Sskip)))
            Sskip)
          (Sreturn (Some (Etempvar _dest (tptr tvoid)))))))))
|}.

Definition f_load_segment_decompress_heap := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_segment, tuint) :: (_srcStart, (tptr tuchar)) ::
                (_srcEnd, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_dest, (tptr tvoid)) :: (_compSize, tuint) ::
               (_compressed, (tptr tuchar)) :: (_pUncSize, (tptr tuint)) ::
               (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sset _dest (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _compSize
      (Ebinop Oand
        (Ebinop Oadd
          (Ebinop Osub (Etempvar _srcEnd (tptr tuchar))
            (Etempvar _srcStart (tptr tuchar)) tint)
          (Econst_int (Int.repr 15) tint) tint)
        (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                   (tptr tvoid) cc_default))
          ((Etempvar _compSize tuint) :: (Econst_int (Int.repr 1) tint) ::
           nil))
        (Sset _compressed (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Sset _pUncSize
          (Ecast
            (Ebinop Oadd (Etempvar _compressed (tptr tuchar))
              (Econst_int (Int.repr 4) tint) (tptr tuchar)) (tptr tuint)))
        (Ssequence
          (Sifthenelse (Ebinop One (Etempvar _compressed (tptr tuchar))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Scall None
                (Evar _dma_read (Tfunction
                                  ((tptr tuchar) :: (tptr tuchar) ::
                                   (tptr tuchar) :: nil) tvoid cc_default))
                ((Etempvar _compressed (tptr tuchar)) ::
                 (Etempvar _srcStart (tptr tuchar)) ::
                 (Etempvar _srcEnd (tptr tuchar)) :: nil))
              (Ssequence
                (Scall None
                  (Evar _decompress (Tfunction
                                      ((tptr tvoid) :: (tptr tvoid) :: nil)
                                      tvoid cc_default))
                  ((Etempvar _compressed (tptr tuchar)) ::
                   (Evar _gDecompressionHeap (tarray tuchar 0)) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _set_segment_base_addr (Tfunction
                                                   (tint :: (tptr tvoid) ::
                                                    nil) tuint cc_default))
                    ((Etempvar _segment tuint) ::
                     (Evar _gDecompressionHeap (tarray tuchar 0)) :: nil))
                  (Scall None
                    (Evar _main_pool_free (Tfunction ((tptr tvoid) :: nil)
                                            tuint cc_default))
                    ((Etempvar _compressed (tptr tuchar)) :: nil)))))
            Sskip)
          (Sreturn (Some (Evar _gDecompressionHeap (tarray tuchar 0)))))))))
|}.

Definition f_load_engine_code_segment := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_startAddr, (tptr tvoid)) :: (_totalSize, tuint) ::
               (_alignedSize, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _startAddr
    (Ecast (Econst_int (Int.repr (-2143844352)) tuint) (tptr tvoid)))
  (Ssequence
    (Sset _totalSize
      (Ebinop Osub
        (Ebinop Osub (Econst_int (Int.repr (-2143289344)) tuint)
          (Ebinop Omul
            (Ebinop Omul
              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                (Econst_int (Int.repr 320) tint) tint)
              (Econst_int (Int.repr 240) tint) tint)
            (Econst_int (Int.repr 3) tint) tint) tuint)
        (Econst_int (Int.repr (-2143844352)) tuint) tuint))
    (Ssequence
      (Sset _alignedSize
        (Ebinop Oand
          (Ebinop Oadd
            (Ebinop Osub (Evar __engineSegmentRomEnd (tarray tuchar 0))
              (Evar __engineSegmentRomStart (tarray tuchar 0)) tint)
            (Econst_int (Int.repr 15) tint) tint)
          (Eunop Onotint (Econst_int (Int.repr 15) tint) tint) tint))
      (Ssequence
        (Scall None
          (Evar _bzero (Tfunction ((tptr tvoid) :: tuint :: nil) tvoid
                         cc_default))
          ((Etempvar _startAddr (tptr tvoid)) ::
           (Etempvar _totalSize tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default))
            nil)
          (Ssequence
            (Scall None
              (Evar _dma_read (Tfunction
                                ((tptr tuchar) :: (tptr tuchar) ::
                                 (tptr tuchar) :: nil) tvoid cc_default))
              ((Etempvar _startAddr (tptr tvoid)) ::
               (Evar __engineSegmentRomStart (tarray tuchar 0)) ::
               (Evar __engineSegmentRomEnd (tarray tuchar 0)) :: nil))
            (Ssequence
              (Scall None
                (Evar _osInvalICache (Tfunction
                                       ((tptr tvoid) :: tuint :: nil) tvoid
                                       cc_default))
                ((Etempvar _startAddr (tptr tvoid)) ::
                 (Etempvar _totalSize tuint) :: nil))
              (Scall None
                (Evar _osInvalDCache (Tfunction
                                       ((tptr tvoid) :: tuint :: nil) tvoid
                                       cc_default))
                ((Etempvar _startAddr (tptr tvoid)) ::
                 (Etempvar _totalSize tuint) :: nil)))))))))
|}.

Definition f_alloc_only_pool_init := {|
  fn_return := (tptr (Tstruct _AllocOnlyPool noattr));
  fn_callconv := cc_default;
  fn_params := ((_size, tuint) :: (_side, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_addr, (tptr tvoid)) ::
               (_subPool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sset _subPool (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _size
      (Ebinop Oand
        (Ebinop Oadd (Etempvar _size tuint) (Econst_int (Int.repr 3) tint)
          tuint) (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tuint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                   (tptr tvoid) cc_default))
          ((Ebinop Oadd (Etempvar _size tuint)
             (Esizeof (Tstruct _AllocOnlyPool noattr) tuint) tuint) ::
           (Etempvar _side tuint) :: nil))
        (Sset _addr (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _addr (tptr tvoid))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _subPool
              (Ecast (Etempvar _addr (tptr tvoid))
                (tptr (Tstruct _AllocOnlyPool noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _subPool (tptr (Tstruct _AllocOnlyPool noattr)))
                    (Tstruct _AllocOnlyPool noattr)) _totalSpace tint)
                (Etempvar _size tuint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _subPool (tptr (Tstruct _AllocOnlyPool noattr)))
                      (Tstruct _AllocOnlyPool noattr)) _usedSpace tint)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _subPool (tptr (Tstruct _AllocOnlyPool noattr)))
                        (Tstruct _AllocOnlyPool noattr)) _startPtr
                      (tptr tuchar))
                    (Ebinop Oadd
                      (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
                      (Esizeof (Tstruct _AllocOnlyPool noattr) tuint)
                      (tptr tuchar)))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _subPool (tptr (Tstruct _AllocOnlyPool noattr)))
                        (Tstruct _AllocOnlyPool noattr)) _freePtr
                      (tptr tuchar))
                    (Ebinop Oadd
                      (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
                      (Esizeof (Tstruct _AllocOnlyPool noattr) tuint)
                      (tptr tuchar)))))))
          Sskip)
        (Sreturn (Some (Etempvar _subPool (tptr (Tstruct _AllocOnlyPool noattr)))))))))
|}.

Definition f_alloc_only_pool_alloc := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_size, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_addr, (tptr tvoid)) :: (_t'1, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, (tptr tuchar)) :: (_t'2, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _addr (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _size
      (Ebinop Oand
        (Ebinop Oadd (Etempvar _size tint) (Econst_int (Int.repr 3) tint)
          tint) (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tint))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Ogt (Etempvar _size tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                  (Tstruct _AllocOnlyPool noattr)) _usedSpace tint))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                    (Tstruct _AllocOnlyPool noattr)) _totalSpace tint))
              (Sset _t'1
                (Ecast
                  (Ebinop Ole
                    (Ebinop Oadd (Etempvar _t'4 tint) (Etempvar _size tint)
                      tint) (Etempvar _t'5 tint) tint) tbool))))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Sset _addr
              (Efield
                (Ederef
                  (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                  (Tstruct _AllocOnlyPool noattr)) _freePtr (tptr tuchar)))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                      (Tstruct _AllocOnlyPool noattr)) _freePtr
                    (tptr tuchar)))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                      (Tstruct _AllocOnlyPool noattr)) _freePtr
                    (tptr tuchar))
                  (Ebinop Oadd (Etempvar _t'3 (tptr tuchar))
                    (Etempvar _size tint) (tptr tuchar))))
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                      (Tstruct _AllocOnlyPool noattr)) _usedSpace tint))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
                      (Tstruct _AllocOnlyPool noattr)) _usedSpace tint)
                  (Ebinop Oadd (Etempvar _t'2 tint) (Etempvar _size tint)
                    tint)))))
          Sskip))
      (Sreturn (Some (Etempvar _addr (tptr tvoid)))))))
|}.

Definition f_alloc_only_pool_resize := {|
  fn_return := (tptr (Tstruct _AllocOnlyPool noattr));
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
                (_size, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_newPool, (tptr (Tstruct _AllocOnlyPool noattr))) ::
               (_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Sset _size
    (Ebinop Oand
      (Ebinop Oadd (Etempvar _size tuint) (Econst_int (Int.repr 3) tint)
        tuint) (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tuint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _main_pool_realloc (Tfunction ((tptr tvoid) :: tuint :: nil)
                                   (tptr tvoid) cc_default))
        ((Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr))) ::
         (Ebinop Oadd (Etempvar _size tuint)
           (Esizeof (Tstruct _AllocOnlyPool noattr) tuint) tuint) :: nil))
      (Sset _newPool (Etempvar _t'1 (tptr tvoid))))
    (Ssequence
      (Sifthenelse (Ebinop One
                     (Etempvar _newPool (tptr (Tstruct _AllocOnlyPool noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Sassign
          (Efield
            (Ederef (Etempvar _pool (tptr (Tstruct _AllocOnlyPool noattr)))
              (Tstruct _AllocOnlyPool noattr)) _totalSpace tint)
          (Etempvar _size tuint))
        Sskip)
      (Sreturn (Some (Etempvar _newPool (tptr (Tstruct _AllocOnlyPool noattr))))))))
|}.

Definition f_mem_pool_init := {|
  fn_return := (tptr (Tstruct _MemoryPool noattr));
  fn_callconv := cc_default;
  fn_params := ((_size, tuint) :: (_side, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_addr, (tptr tvoid)) ::
               (_block, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_pool, (tptr (Tstruct _MemoryPool noattr))) ::
               (_t'1, (tptr tvoid)) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _pool (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _size
      (Ebinop Oand
        (Ebinop Oadd (Etempvar _size tuint) (Econst_int (Int.repr 3) tint)
          tuint) (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tuint))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                   (tptr tvoid) cc_default))
          ((Ebinop Oadd (Etempvar _size tuint)
             (Esizeof (Tstruct _MemoryPool noattr) tuint) tuint) ::
           (Etempvar _side tuint) :: nil))
        (Sset _addr (Etempvar _t'1 (tptr tvoid))))
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _addr (tptr tvoid))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _pool
              (Ecast (Etempvar _addr (tptr tvoid))
                (tptr (Tstruct _MemoryPool noattr))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                    (Tstruct _MemoryPool noattr)) _totalSpace tuint)
                (Etempvar _size tuint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                      (Tstruct _MemoryPool noattr)) _firstBlock
                    (tptr (Tstruct _MemoryBlock noattr)))
                  (Ecast
                    (Ebinop Oadd
                      (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
                      (Esizeof (Tstruct _MemoryPool noattr) tuint)
                      (tptr tuchar)) (tptr (Tstruct _MemoryBlock noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                          (Tstruct _MemoryPool noattr)) _freeList
                        (Tstruct _MemoryBlock noattr)) _next
                      (tptr (Tstruct _MemoryBlock noattr)))
                    (Ecast
                      (Ebinop Oadd
                        (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
                        (Esizeof (Tstruct _MemoryPool noattr) tuint)
                        (tptr tuchar)) (tptr (Tstruct _MemoryBlock noattr))))
                  (Ssequence
                    (Sset _block
                      (Efield
                        (Ederef
                          (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                          (Tstruct _MemoryPool noattr)) _firstBlock
                        (tptr (Tstruct _MemoryBlock noattr))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                            (Tstruct _MemoryBlock noattr)) _next
                          (tptr (Tstruct _MemoryBlock noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                      (Ssequence
                        (Sset _t'2
                          (Efield
                            (Ederef
                              (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                              (Tstruct _MemoryPool noattr)) _totalSpace
                            tuint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _size tuint)
                          (Etempvar _t'2 tuint)))))))))
          Sskip)
        (Sreturn (Some (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))))))))
|}.

Definition f_mem_pool_alloc := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _MemoryPool noattr))) ::
                (_size, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_freeBlock, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_addr, (tptr tvoid)) ::
               (_newBlock, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'14, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'13, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'12, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'11, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'10, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'7, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'6, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'5, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'4, tuint) ::
               (_t'3, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _MemoryBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _freeBlock
    (Eaddrof
      (Efield
        (Ederef (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
          (Tstruct _MemoryPool noattr)) _freeList
        (Tstruct _MemoryBlock noattr)) (tptr (Tstruct _MemoryBlock noattr))))
  (Ssequence
    (Sset _addr (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Sset _size
        (Ebinop Oadd
          (Ebinop Oand
            (Ebinop Oadd (Etempvar _size tuint)
              (Econst_int (Int.repr 3) tint) tuint)
            (Eunop Onotint (Econst_int (Int.repr 3) tint) tint) tuint)
          (Esizeof (Tstruct _MemoryBlock noattr) tuint) tuint))
      (Ssequence
        (Sloop
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef
                    (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                    (Tstruct _MemoryBlock noattr)) _next
                  (tptr (Tstruct _MemoryBlock noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'14 (tptr (Tstruct _MemoryBlock noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                Sskip
                Sbreak))
            (Ssequence
              (Ssequence
                (Sset _t'1
                  (Efield
                    (Ederef
                      (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                      (Tstruct _MemoryBlock noattr)) _next
                    (tptr (Tstruct _MemoryBlock noattr))))
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _t'1 (tptr (Tstruct _MemoryBlock noattr)))
                        (Tstruct _MemoryBlock noattr)) _size tuint))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'2 tuint)
                                 (Etempvar _size tuint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr))))
                        (Sset _addr
                          (Ebinop Oadd
                            (Ecast
                              (Etempvar _t'13 (tptr (Tstruct _MemoryBlock noattr)))
                              (tptr tuchar))
                            (Esizeof (Tstruct _MemoryBlock noattr) tuint)
                            (tptr tuchar))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Efield
                              (Ederef
                                (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _next
                              (tptr (Tstruct _MemoryBlock noattr))))
                          (Ssequence
                            (Sset _t'4
                              (Efield
                                (Ederef
                                  (Etempvar _t'3 (tptr (Tstruct _MemoryBlock noattr)))
                                  (Tstruct _MemoryBlock noattr)) _size tuint))
                            (Sifthenelse (Ebinop Ole
                                           (Ebinop Osub (Etempvar _t'4 tuint)
                                             (Etempvar _size tuint) tuint)
                                           (Esizeof (Tstruct _MemoryBlock noattr) tuint)
                                           tint)
                              (Ssequence
                                (Sset _t'11
                                  (Efield
                                    (Ederef
                                      (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                      (Tstruct _MemoryBlock noattr)) _next
                                    (tptr (Tstruct _MemoryBlock noattr))))
                                (Ssequence
                                  (Sset _t'12
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'11 (tptr (Tstruct _MemoryBlock noattr)))
                                        (Tstruct _MemoryBlock noattr)) _next
                                      (tptr (Tstruct _MemoryBlock noattr))))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                        (Tstruct _MemoryBlock noattr)) _next
                                      (tptr (Tstruct _MemoryBlock noattr)))
                                    (Etempvar _t'12 (tptr (Tstruct _MemoryBlock noattr))))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'10
                                    (Efield
                                      (Ederef
                                        (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                        (Tstruct _MemoryBlock noattr)) _next
                                      (tptr (Tstruct _MemoryBlock noattr))))
                                  (Sset _newBlock
                                    (Ecast
                                      (Ebinop Oadd
                                        (Ecast
                                          (Etempvar _t'10 (tptr (Tstruct _MemoryBlock noattr)))
                                          (tptr tuchar))
                                        (Etempvar _size tuint) (tptr tuchar))
                                      (tptr (Tstruct _MemoryBlock noattr)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'8
                                      (Efield
                                        (Ederef
                                          (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                          (Tstruct _MemoryBlock noattr))
                                        _next
                                        (tptr (Tstruct _MemoryBlock noattr))))
                                    (Ssequence
                                      (Sset _t'9
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'8 (tptr (Tstruct _MemoryBlock noattr)))
                                            (Tstruct _MemoryBlock noattr))
                                          _size tuint))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _newBlock (tptr (Tstruct _MemoryBlock noattr)))
                                            (Tstruct _MemoryBlock noattr))
                                          _size tuint)
                                        (Ebinop Osub (Etempvar _t'9 tuint)
                                          (Etempvar _size tuint) tuint))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'6
                                        (Efield
                                          (Ederef
                                            (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                            (Tstruct _MemoryBlock noattr))
                                          _next
                                          (tptr (Tstruct _MemoryBlock noattr))))
                                      (Ssequence
                                        (Sset _t'7
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'6 (tptr (Tstruct _MemoryBlock noattr)))
                                              (Tstruct _MemoryBlock noattr))
                                            _next
                                            (tptr (Tstruct _MemoryBlock noattr))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _newBlock (tptr (Tstruct _MemoryBlock noattr)))
                                              (Tstruct _MemoryBlock noattr))
                                            _next
                                            (tptr (Tstruct _MemoryBlock noattr)))
                                          (Etempvar _t'7 (tptr (Tstruct _MemoryBlock noattr))))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'5
                                          (Efield
                                            (Ederef
                                              (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                              (Tstruct _MemoryBlock noattr))
                                            _next
                                            (tptr (Tstruct _MemoryBlock noattr))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'5 (tptr (Tstruct _MemoryBlock noattr)))
                                              (Tstruct _MemoryBlock noattr))
                                            _size tuint)
                                          (Etempvar _size tuint)))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                                            (Tstruct _MemoryBlock noattr))
                                          _next
                                          (tptr (Tstruct _MemoryBlock noattr)))
                                        (Etempvar _newBlock (tptr (Tstruct _MemoryBlock noattr)))))))))))
                        Sbreak))
                    Sskip)))
              (Sset _freeBlock
                (Efield
                  (Ederef
                    (Etempvar _freeBlock (tptr (Tstruct _MemoryBlock noattr)))
                    (Tstruct _MemoryBlock noattr)) _next
                  (tptr (Tstruct _MemoryBlock noattr))))))
          Sskip)
        (Sreturn (Some (Etempvar _addr (tptr tvoid))))))))
|}.

Definition f_mem_pool_free := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_pool, (tptr (Tstruct _MemoryPool noattr))) ::
                (_addr, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_block, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_freeList, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'24, tuint) ::
               (_t'23, tuint) ::
               (_t'22, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'21, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'20, tuint) ::
               (_t'19, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'18, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'17, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'16, tuint) :: (_t'15, tuint) ::
               (_t'14, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'13, tuint) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'10, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'5, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'4, (tptr (Tstruct _MemoryBlock noattr))) ::
               (_t'3, (tptr (Tstruct _MemoryBlock noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _block
    (Ecast
      (Ebinop Osub (Ecast (Etempvar _addr (tptr tvoid)) (tptr tuchar))
        (Esizeof (Tstruct _MemoryBlock noattr) tuint) (tptr tuchar))
      (tptr (Tstruct _MemoryBlock noattr))))
  (Ssequence
    (Sset _freeList
      (Efield
        (Efield
          (Ederef (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
            (Tstruct _MemoryPool noattr)) _freeList
          (Tstruct _MemoryBlock noattr)) _next
        (tptr (Tstruct _MemoryBlock noattr))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Efield
            (Ederef (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
              (Tstruct _MemoryPool noattr)) _freeList
            (Tstruct _MemoryBlock noattr)) _next
          (tptr (Tstruct _MemoryBlock noattr))))
      (Sifthenelse (Ebinop Oeq
                     (Etempvar _t'3 (tptr (Tstruct _MemoryBlock noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                  (Tstruct _MemoryPool noattr)) _freeList
                (Tstruct _MemoryBlock noattr)) _next
              (tptr (Tstruct _MemoryBlock noattr)))
            (Etempvar _block (tptr (Tstruct _MemoryBlock noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                (Tstruct _MemoryBlock noattr)) _next
              (tptr (Tstruct _MemoryBlock noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        (Ssequence
          (Sset _t'4
            (Efield
              (Efield
                (Ederef (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                  (Tstruct _MemoryPool noattr)) _freeList
                (Tstruct _MemoryBlock noattr)) _next
              (tptr (Tstruct _MemoryBlock noattr))))
          (Sifthenelse (Ebinop Olt
                         (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                         (Etempvar _t'4 (tptr (Tstruct _MemoryBlock noattr)))
                         tint)
            (Ssequence
              (Sset _t'19
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                      (Tstruct _MemoryPool noattr)) _freeList
                    (Tstruct _MemoryBlock noattr)) _next
                  (tptr (Tstruct _MemoryBlock noattr))))
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Ederef
                      (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                      (Tstruct _MemoryBlock noattr)) _size tuint))
                (Sifthenelse (Ebinop Oeq
                               (Ecast
                                 (Etempvar _t'19 (tptr (Tstruct _MemoryBlock noattr)))
                                 (tptr tuchar))
                               (Ebinop Oadd
                                 (Ecast
                                   (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                   (tptr tuchar)) (Etempvar _t'20 tuint)
                                 (tptr tuchar)) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'23
                        (Efield
                          (Ederef
                            (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                            (Tstruct _MemoryBlock noattr)) _size tuint))
                      (Ssequence
                        (Sset _t'24
                          (Efield
                            (Ederef
                              (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _size tuint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _size tuint)
                          (Ebinop Oadd (Etempvar _t'23 tuint)
                            (Etempvar _t'24 tuint) tuint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'22
                          (Efield
                            (Ederef
                              (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr)))
                          (Etempvar _t'22 (tptr (Tstruct _MemoryBlock noattr)))))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                              (Tstruct _MemoryPool noattr)) _freeList
                            (Tstruct _MemoryBlock noattr)) _next
                          (tptr (Tstruct _MemoryBlock noattr)))
                        (Etempvar _block (tptr (Tstruct _MemoryBlock noattr))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'21
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                              (Tstruct _MemoryPool noattr)) _freeList
                            (Tstruct _MemoryBlock noattr)) _next
                          (tptr (Tstruct _MemoryBlock noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                            (Tstruct _MemoryBlock noattr)) _next
                          (tptr (Tstruct _MemoryBlock noattr)))
                        (Etempvar _t'21 (tptr (Tstruct _MemoryBlock noattr)))))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _pool (tptr (Tstruct _MemoryPool noattr)))
                            (Tstruct _MemoryPool noattr)) _freeList
                          (Tstruct _MemoryBlock noattr)) _next
                        (tptr (Tstruct _MemoryBlock noattr)))
                      (Etempvar _block (tptr (Tstruct _MemoryBlock noattr))))))))
            (Ssequence
              (Sloop
                (Ssequence
                  (Ssequence
                    (Sset _t'18
                      (Efield
                        (Ederef
                          (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                          (Tstruct _MemoryBlock noattr)) _next
                        (tptr (Tstruct _MemoryBlock noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'18 (tptr (Tstruct _MemoryBlock noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      Sskip
                      Sbreak))
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Ebinop Olt
                                     (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                                     (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                     tint)
                        (Ssequence
                          (Sset _t'17
                            (Efield
                              (Ederef
                                (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _next
                              (tptr (Tstruct _MemoryBlock noattr))))
                          (Sset _t'1
                            (Ecast
                              (Ebinop Olt
                                (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                (Etempvar _t'17 (tptr (Tstruct _MemoryBlock noattr)))
                                tint) tbool)))
                        (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'1 tint) Sbreak Sskip))
                    (Sset _freeList
                      (Efield
                        (Ederef
                          (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                          (Tstruct _MemoryBlock noattr)) _next
                        (tptr (Tstruct _MemoryBlock noattr))))))
                Sskip)
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                        (Tstruct _MemoryBlock noattr)) _size tuint))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                 (Ecast
                                   (Ebinop Oadd
                                     (Ecast
                                       (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                                       (tptr tuchar)) (Etempvar _t'13 tuint)
                                     (tptr tuchar))
                                   (tptr (Tstruct _MemoryBlock noattr)))
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _size tuint))
                        (Ssequence
                          (Sset _t'16
                            (Efield
                              (Ederef
                                (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _size tuint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _size tuint)
                            (Ebinop Oadd (Etempvar _t'15 tuint)
                              (Etempvar _t'16 tuint) tuint))))
                      (Sset _block
                        (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr)))
                          (Etempvar _t'14 (tptr (Tstruct _MemoryBlock noattr)))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _freeList (tptr (Tstruct _MemoryBlock noattr)))
                            (Tstruct _MemoryBlock noattr)) _next
                          (tptr (Tstruct _MemoryBlock noattr)))
                        (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                          (Tstruct _MemoryBlock noattr)) _next
                        (tptr (Tstruct _MemoryBlock noattr))))
                    (Sifthenelse (Ebinop One
                                   (Etempvar _t'10 (tptr (Tstruct _MemoryBlock noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr))))
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Ederef
                                (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _size tuint))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Oeq
                                (Ecast
                                  (Etempvar _t'11 (tptr (Tstruct _MemoryBlock noattr)))
                                  (tptr tuchar))
                                (Ebinop Oadd
                                  (Ecast
                                    (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                    (tptr tuchar)) (Etempvar _t'12 tuint)
                                  (tptr tuchar)) tint) tbool))))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _size tuint))
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _next
                              (tptr (Tstruct _MemoryBlock noattr))))
                          (Ssequence
                            (Sset _t'9
                              (Efield
                                (Ederef
                                  (Etempvar _t'8 (tptr (Tstruct _MemoryBlock noattr)))
                                  (Tstruct _MemoryBlock noattr)) _size tuint))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                  (Tstruct _MemoryBlock noattr)) _size tuint)
                              (Ebinop Oadd (Etempvar _t'7 tuint)
                                (Etempvar _t'9 tuint) tuint)))))
                      (Ssequence
                        (Sset _t'5
                          (Efield
                            (Ederef
                              (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                              (Tstruct _MemoryBlock noattr)) _next
                            (tptr (Tstruct _MemoryBlock noattr))))
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _next
                              (tptr (Tstruct _MemoryBlock noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _block (tptr (Tstruct _MemoryBlock noattr)))
                                (Tstruct _MemoryBlock noattr)) _next
                              (tptr (Tstruct _MemoryBlock noattr)))
                            (Etempvar _t'6 (tptr (Tstruct _MemoryBlock noattr)))))))
                    Sskip))))))))))
|}.

Definition f_alloc_display_list := {|
  fn_return := (tptr tvoid);
  fn_callconv := cc_default;
  fn_params := ((_size, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_ptr, (tptr tvoid)) :: (_t'3, (tptr tuchar)) ::
               (_t'2, (tptr (Tunion __512 noattr))) ::
               (_t'1, (tptr tuchar)) :: nil);
  fn_body :=
(Ssequence
  (Sset _ptr (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sset _size
      (Ebinop Oand
        (Ebinop Oadd (Etempvar _size tuint) (Econst_int (Int.repr 7) tint)
          tuint) (Eunop Onotint (Econst_int (Int.repr 7) tint) tint) tuint))
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gGfxPoolEnd (tptr tuchar)))
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __512 noattr))))
          (Sifthenelse (Ebinop Oge
                         (Ebinop Osub (Etempvar _t'1 (tptr tuchar))
                           (Etempvar _size tuint) (tptr tuchar))
                         (Ecast (Etempvar _t'2 (tptr (Tunion __512 noattr)))
                           (tptr tuchar)) tint)
            (Ssequence
              (Ssequence
                (Sset _t'3 (Evar _gGfxPoolEnd (tptr tuchar)))
                (Sassign (Evar _gGfxPoolEnd (tptr tuchar))
                  (Ebinop Osub (Etempvar _t'3 (tptr tuchar))
                    (Etempvar _size tuint) (tptr tuchar))))
              (Sset _ptr (Evar _gGfxPoolEnd (tptr tuchar))))
            Sskip)))
      (Sreturn (Some (Etempvar _ptr (tptr tvoid)))))))
|}.

Definition f_load_dma_table_address := {|
  fn_return := (tptr (Tstruct _DmaTable noattr));
  fn_callconv := cc_default;
  fn_params := ((_srcAddr, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_table, (tptr (Tstruct _DmaTable noattr))) ::
               (_size, tuint) :: (_t'2, (tptr tvoid)) ::
               (_t'1, (tptr tvoid)) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _dynamic_dma_read (Tfunction
                                ((tptr tuchar) :: (tptr tuchar) :: tuint ::
                                 nil) (tptr tvoid) cc_default))
      ((Etempvar _srcAddr (tptr tuchar)) ::
       (Ebinop Oadd (Etempvar _srcAddr (tptr tuchar)) (Esizeof tuint tuint)
         (tptr tuchar)) :: (Econst_int (Int.repr 0) tint) :: nil))
    (Sset _table (Etempvar _t'1 (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
            (Tstruct _DmaTable noattr)) _count tuint))
      (Sset _size
        (Ebinop Osub
          (Ebinop Oadd
            (Ebinop Omul (Etempvar _t'3 tuint)
              (Esizeof (Tstruct _OffsetSizePair noattr) tuint) tuint)
            (Esizeof (Tstruct _DmaTable noattr) tuint) tuint)
          (Esizeof (Tstruct _OffsetSizePair noattr) tuint) tuint)))
    (Ssequence
      (Scall None
        (Evar _main_pool_free (Tfunction ((tptr tvoid) :: nil) tuint
                                cc_default))
        ((Etempvar _table (tptr (Tstruct _DmaTable noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _dynamic_dma_read (Tfunction
                                      ((tptr tuchar) :: (tptr tuchar) ::
                                       tuint :: nil) (tptr tvoid) cc_default))
            ((Etempvar _srcAddr (tptr tuchar)) ::
             (Ebinop Oadd (Etempvar _srcAddr (tptr tuchar))
               (Etempvar _size tuint) (tptr tuchar)) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sset _table (Etempvar _t'2 (tptr tvoid))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
                (Tstruct _DmaTable noattr)) _srcAddr (tptr tuchar))
            (Etempvar _srcAddr (tptr tuchar)))
          (Sreturn (Some (Etempvar _table (tptr (Tstruct _DmaTable noattr))))))))))
|}.

Definition f_setup_dma_table_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_list, (tptr (Tstruct _DmaHandlerList noattr))) ::
                (_srcAddr, (tptr tvoid)) :: (_buffer, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _DmaTable noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop One (Etempvar _srcAddr (tptr tvoid))
                 (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
    (Ssequence
      (Scall (Some _t'1)
        (Evar _load_dma_table_address (Tfunction ((tptr tuchar) :: nil)
                                        (tptr (Tstruct _DmaTable noattr))
                                        cc_default))
        ((Etempvar _srcAddr (tptr tvoid)) :: nil))
      (Sassign
        (Efield
          (Ederef (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
            (Tstruct _DmaHandlerList noattr)) _dmaTable
          (tptr (Tstruct _DmaTable noattr)))
        (Etempvar _t'1 (tptr (Tstruct _DmaTable noattr)))))
    Sskip)
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
          (Tstruct _DmaHandlerList noattr)) _currentAddr (tptr tvoid))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Sassign
      (Efield
        (Ederef (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
          (Tstruct _DmaHandlerList noattr)) _bufTarget (tptr tvoid))
      (Etempvar _buffer (tptr tvoid)))))
|}.

Definition f_load_patchable_table := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_list, (tptr (Tstruct _DmaHandlerList noattr))) ::
                (_index, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_ret, tint) :: (_table, (tptr (Tstruct _DmaTable noattr))) ::
               (_addr, (tptr tuchar)) :: (_size, tint) :: (_t'5, tuint) ::
               (_t'4, (tptr tuchar)) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _ret (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sset _table
      (Efield
        (Ederef (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
          (Tstruct _DmaHandlerList noattr)) _dmaTable
        (tptr (Tstruct _DmaTable noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
              (Tstruct _DmaTable noattr)) _count tuint))
        (Sifthenelse (Ebinop Olt (Ecast (Etempvar _index tint) tuint)
                       (Etempvar _t'1 tuint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
                    (Tstruct _DmaTable noattr)) _srcAddr (tptr tuchar)))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
                            (Tstruct _DmaTable noattr)) _anim
                          (tarray (Tstruct _OffsetSizePair noattr) 1))
                        (Etempvar _index tint)
                        (tptr (Tstruct _OffsetSizePair noattr)))
                      (Tstruct _OffsetSizePair noattr)) _offset tuint))
                (Sset _addr
                  (Ebinop Oadd (Etempvar _t'4 (tptr tuchar))
                    (Etempvar _t'5 tuint) (tptr tuchar)))))
            (Ssequence
              (Sset _size
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _table (tptr (Tstruct _DmaTable noattr)))
                          (Tstruct _DmaTable noattr)) _anim
                        (tarray (Tstruct _OffsetSizePair noattr) 1))
                      (Etempvar _index tint)
                      (tptr (Tstruct _OffsetSizePair noattr)))
                    (Tstruct _OffsetSizePair noattr)) _size tuint))
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef
                      (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
                      (Tstruct _DmaHandlerList noattr)) _currentAddr
                    (tptr tvoid)))
                (Sifthenelse (Ebinop One (Etempvar _addr (tptr tuchar))
                               (Etempvar _t'2 (tptr tvoid)) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
                            (Tstruct _DmaHandlerList noattr)) _bufTarget
                          (tptr tvoid)))
                      (Scall None
                        (Evar _dma_read (Tfunction
                                          ((tptr tuchar) :: (tptr tuchar) ::
                                           (tptr tuchar) :: nil) tvoid
                                          cc_default))
                        ((Etempvar _t'3 (tptr tvoid)) ::
                         (Etempvar _addr (tptr tuchar)) ::
                         (Ebinop Oadd (Etempvar _addr (tptr tuchar))
                           (Etempvar _size tint) (tptr tuchar)) :: nil)))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _list (tptr (Tstruct _DmaHandlerList noattr)))
                            (Tstruct _DmaHandlerList noattr)) _currentAddr
                          (tptr tvoid)) (Etempvar _addr (tptr tuchar)))
                      (Sset _ret (Econst_int (Int.repr 1) tint))))
                  Sskip))))
          Sskip))
      (Sreturn (Some (Etempvar _ret tint))))))
|}.

Definition composites : list composite_definition :=
(Composite __249 Struct
   (Member_plain _f_odd tfloat :: Member_plain _f_even tfloat :: nil)
   noattr ::
 Composite __248 Union (Member_plain _f (Tstruct __249 noattr) :: nil) noattr ::
 Composite __251 Struct
   (Member_plain _at tulong :: Member_plain _v0 tulong ::
    Member_plain _v1 tulong :: Member_plain _a0 tulong ::
    Member_plain _a1 tulong :: Member_plain _a2 tulong ::
    Member_plain _a3 tulong :: Member_plain _t0 tulong ::
    Member_plain _t1 tulong :: Member_plain _t2 tulong ::
    Member_plain _t3 tulong :: Member_plain _t4 tulong ::
    Member_plain _t5 tulong :: Member_plain _t6 tulong ::
    Member_plain _t7 tulong :: Member_plain _s0 tulong ::
    Member_plain _s1 tulong :: Member_plain _s2 tulong ::
    Member_plain _s3 tulong :: Member_plain _s4 tulong ::
    Member_plain _s5 tulong :: Member_plain _s6 tulong ::
    Member_plain _s7 tulong :: Member_plain _t8 tulong ::
    Member_plain _t9 tulong :: Member_plain _gp tulong ::
    Member_plain _sp tulong :: Member_plain _s8 tulong ::
    Member_plain _ra tulong :: Member_plain _lo tulong ::
    Member_plain _hi tulong :: Member_plain _sr tuint ::
    Member_plain _pc tuint :: Member_plain _cause tuint ::
    Member_plain _badvaddr tuint :: Member_plain _rcp tuint ::
    Member_plain _fpcsr tuint :: Member_plain _fp0 (Tunion __248 noattr) ::
    Member_plain _fp2 (Tunion __248 noattr) ::
    Member_plain _fp4 (Tunion __248 noattr) ::
    Member_plain _fp6 (Tunion __248 noattr) ::
    Member_plain _fp8 (Tunion __248 noattr) ::
    Member_plain _fp10 (Tunion __248 noattr) ::
    Member_plain _fp12 (Tunion __248 noattr) ::
    Member_plain _fp14 (Tunion __248 noattr) ::
    Member_plain _fp16 (Tunion __248 noattr) ::
    Member_plain _fp18 (Tunion __248 noattr) ::
    Member_plain _fp20 (Tunion __248 noattr) ::
    Member_plain _fp22 (Tunion __248 noattr) ::
    Member_plain _fp24 (Tunion __248 noattr) ::
    Member_plain _fp26 (Tunion __248 noattr) ::
    Member_plain _fp28 (Tunion __248 noattr) ::
    Member_plain _fp30 (Tunion __248 noattr) :: nil)
   noattr ::
 Composite __253 Struct
   (Member_plain _flag tuint :: Member_plain _count tuint ::
    Member_plain _time tulong :: nil)
   noattr ::
 Composite _OSThread_s Struct
   (Member_plain _next (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _priority tint ::
    Member_plain _queue (tptr (tptr (Tstruct _OSThread_s noattr))) ::
    Member_plain _tlnext (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _state tushort :: Member_plain _flags tushort ::
    Member_plain _id tint :: Member_plain _fp tint ::
    Member_plain _thprof (tptr (Tstruct __253 noattr)) ::
    Member_plain _context (Tstruct __251 noattr) :: nil)
   noattr ::
 Composite _OSMesgQueue_s Struct
   (Member_plain _mtqueue (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _fullqueue (tptr (Tstruct _OSThread_s noattr)) ::
    Member_plain _validCount tint :: Member_plain _first tint ::
    Member_plain _msgCount tint :: Member_plain _msg (tptr (tptr tvoid)) ::
    nil)
   noattr ::
 Composite __421 Struct
   (Member_plain _type tushort :: Member_plain _pri tuchar ::
    Member_plain _status tuchar ::
    Member_plain _retQueue (tptr (Tstruct _OSMesgQueue_s noattr)) :: nil)
   noattr ::
 Composite __423 Struct
   (Member_plain _hdr (Tstruct __421 noattr) ::
    Member_plain _dramAddr (tptr tvoid) :: Member_plain _devAddr tuint ::
    Member_plain _size tuint :: nil)
   noattr ::
 Composite __510 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __512 Union
   (Member_plain _words (Tstruct __510 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _AllocOnlyPool Struct
   (Member_plain _totalSpace tint :: Member_plain _usedSpace tint ::
    Member_plain _startPtr (tptr tuchar) ::
    Member_plain _freePtr (tptr tuchar) :: nil)
   noattr ::
 Composite _OffsetSizePair Struct
   (Member_plain _offset tuint :: Member_plain _size tuint :: nil)
   noattr ::
 Composite _DmaTable Struct
   (Member_plain _count tuint :: Member_plain _srcAddr (tptr tuchar) ::
    Member_plain _anim (tarray (Tstruct _OffsetSizePair noattr) 1) :: nil)
   noattr ::
 Composite _DmaHandlerList Struct
   (Member_plain _dmaTable (tptr (Tstruct _DmaTable noattr)) ::
    Member_plain _currentAddr (tptr tvoid) ::
    Member_plain _bufTarget (tptr tvoid) :: nil)
   noattr ::
 Composite _MainPoolState Struct
   (Member_plain _freeSpace tuint ::
    Member_plain _listHeadL (tptr (Tstruct _MainPoolBlock noattr)) ::
    Member_plain _listHeadR (tptr (Tstruct _MainPoolBlock noattr)) ::
    Member_plain _prev (tptr (Tstruct _MainPoolState noattr)) :: nil)
   noattr ::
 Composite _MainPoolBlock Struct
   (Member_plain _prev (tptr (Tstruct _MainPoolBlock noattr)) ::
    Member_plain _next (tptr (Tstruct _MainPoolBlock noattr)) :: nil)
   noattr ::
 Composite _MemoryBlock Struct
   (Member_plain _next (tptr (Tstruct _MemoryBlock noattr)) ::
    Member_plain _size tuint :: nil)
   noattr ::
 Composite _MemoryPool Struct
   (Member_plain _totalSpace tuint ::
    Member_plain _firstBlock (tptr (Tstruct _MemoryBlock noattr)) ::
    Member_plain _freeList (Tstruct _MemoryBlock noattr) :: nil)
   noattr :: nil).

Definition global_definitions : list (ident * globdef fundef type) :=
((___compcert_va_int32,
   Gfun(External (EF_runtime "__compcert_va_int32"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tvoid) :: nil) tuint cc_default)) ::
 (___compcert_va_int64,
   Gfun(External (EF_runtime "__compcert_va_int64"
                   (mksignature (AST.Xptr :: nil) AST.Xlong cc_default))
     ((tptr tvoid) :: nil) tulong cc_default)) ::
 (___compcert_va_float64,
   Gfun(External (EF_runtime "__compcert_va_float64"
                   (mksignature (AST.Xptr :: nil) AST.Xfloat cc_default))
     ((tptr tvoid) :: nil) tdouble cc_default)) ::
 (___compcert_va_composite,
   Gfun(External (EF_runtime "__compcert_va_composite"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default)) ((tptr tvoid) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (___compcert_i64_dtos,
   Gfun(External (EF_runtime "__compcert_i64_dtos"
                   (mksignature (AST.Xfloat :: nil) AST.Xlong cc_default))
     (tdouble :: nil) tlong cc_default)) ::
 (___compcert_i64_dtou,
   Gfun(External (EF_runtime "__compcert_i64_dtou"
                   (mksignature (AST.Xfloat :: nil) AST.Xlong cc_default))
     (tdouble :: nil) tulong cc_default)) ::
 (___compcert_i64_stod,
   Gfun(External (EF_runtime "__compcert_i64_stod"
                   (mksignature (AST.Xlong :: nil) AST.Xfloat cc_default))
     (tlong :: nil) tdouble cc_default)) ::
 (___compcert_i64_utod,
   Gfun(External (EF_runtime "__compcert_i64_utod"
                   (mksignature (AST.Xlong :: nil) AST.Xfloat cc_default))
     (tulong :: nil) tdouble cc_default)) ::
 (___compcert_i64_stof,
   Gfun(External (EF_runtime "__compcert_i64_stof"
                   (mksignature (AST.Xlong :: nil) AST.Xsingle cc_default))
     (tlong :: nil) tfloat cc_default)) ::
 (___compcert_i64_utof,
   Gfun(External (EF_runtime "__compcert_i64_utof"
                   (mksignature (AST.Xlong :: nil) AST.Xsingle cc_default))
     (tulong :: nil) tfloat cc_default)) ::
 (___compcert_i64_sdiv,
   Gfun(External (EF_runtime "__compcert_i64_sdiv"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___compcert_i64_udiv,
   Gfun(External (EF_runtime "__compcert_i64_udiv"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tulong :: tulong :: nil) tulong
     cc_default)) ::
 (___compcert_i64_smod,
   Gfun(External (EF_runtime "__compcert_i64_smod"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___compcert_i64_umod,
   Gfun(External (EF_runtime "__compcert_i64_umod"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tulong :: tulong :: nil) tulong
     cc_default)) ::
 (___compcert_i64_shl,
   Gfun(External (EF_runtime "__compcert_i64_shl"
                   (mksignature (AST.Xlong :: AST.Xint :: nil) AST.Xlong
                     cc_default)) (tlong :: tint :: nil) tlong cc_default)) ::
 (___compcert_i64_shr,
   Gfun(External (EF_runtime "__compcert_i64_shr"
                   (mksignature (AST.Xlong :: AST.Xint :: nil) AST.Xlong
                     cc_default)) (tulong :: tint :: nil) tulong cc_default)) ::
 (___compcert_i64_sar,
   Gfun(External (EF_runtime "__compcert_i64_sar"
                   (mksignature (AST.Xlong :: AST.Xint :: nil) AST.Xlong
                     cc_default)) (tlong :: tint :: nil) tlong cc_default)) ::
 (___compcert_i64_smulh,
   Gfun(External (EF_runtime "__compcert_i64_smulh"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___compcert_i64_umulh,
   Gfun(External (EF_runtime "__compcert_i64_umulh"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tulong :: tulong :: nil) tulong
     cc_default)) ::
 (___builtin_ais_annot,
   Gfun(External (EF_builtin "__builtin_ais_annot"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     ((tptr tuchar) :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_bswap64,
   Gfun(External (EF_builtin "__builtin_bswap64"
                   (mksignature (AST.Xlong :: nil) AST.Xlong cc_default))
     (tulong :: nil) tulong cc_default)) ::
 (___builtin_bswap,
   Gfun(External (EF_builtin "__builtin_bswap"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tuint cc_default)) ::
 (___builtin_bswap32,
   Gfun(External (EF_builtin "__builtin_bswap32"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tuint cc_default)) ::
 (___builtin_bswap16,
   Gfun(External (EF_builtin "__builtin_bswap16"
                   (mksignature (AST.Xint16unsigned :: nil)
                     AST.Xint16unsigned cc_default)) (tushort :: nil) tushort
     cc_default)) ::
 (___builtin_clz,
   Gfun(External (EF_builtin "__builtin_clz"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
 (___builtin_clzl,
   Gfun(External (EF_builtin "__builtin_clzl"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
 (___builtin_clzll,
   Gfun(External (EF_builtin "__builtin_clzll"
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
 (___builtin_ctz,
   Gfun(External (EF_builtin "__builtin_ctz"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
 (___builtin_ctzl,
   Gfun(External (EF_builtin "__builtin_ctzl"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tuint :: nil) tint cc_default)) ::
 (___builtin_ctzll,
   Gfun(External (EF_builtin "__builtin_ctzll"
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
 (___builtin_fabs,
   Gfun(External (EF_builtin "__builtin_fabs"
                   (mksignature (AST.Xfloat :: nil) AST.Xfloat cc_default))
     (tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fabsf,
   Gfun(External (EF_builtin "__builtin_fabsf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (___builtin_fsqrt,
   Gfun(External (EF_builtin "__builtin_fsqrt"
                   (mksignature (AST.Xfloat :: nil) AST.Xfloat cc_default))
     (tdouble :: nil) tdouble cc_default)) ::
 (___builtin_sqrt,
   Gfun(External (EF_builtin "__builtin_sqrt"
                   (mksignature (AST.Xfloat :: nil) AST.Xfloat cc_default))
     (tdouble :: nil) tdouble cc_default)) ::
 (___builtin_memcpy_aligned,
   Gfun(External (EF_builtin "__builtin_memcpy_aligned"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: (tptr tvoid) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (___builtin_sel,
   Gfun(External (EF_builtin "__builtin_sel"
                   (mksignature (AST.Xbool :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (tbool :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot,
   Gfun(External (EF_builtin "__builtin_annot"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     ((tptr tuchar) :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tuchar) :: tint :: nil) tint
     cc_default)) ::
 (___builtin_membar,
   Gfun(External (EF_builtin "__builtin_membar"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_va_start,
   Gfun(External (EF_builtin "__builtin_va_start"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_va_arg,
   Gfun(External (EF_builtin "__builtin_va_arg"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) ::
 (___builtin_va_copy,
   Gfun(External (EF_builtin "__builtin_va_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: (tptr tvoid) :: nil) tvoid
     cc_default)) ::
 (___builtin_va_end,
   Gfun(External (EF_builtin "__builtin_va_end"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_unreachable,
   Gfun(External (EF_builtin "__builtin_unreachable"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_expect,
   Gfun(External (EF_builtin "__builtin_expect"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (___builtin_mulhw,
   Gfun(External (EF_builtin "__builtin_mulhw"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tint :: tint :: nil) tint cc_default)) ::
 (___builtin_mulhwu,
   Gfun(External (EF_builtin "__builtin_mulhwu"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tuint :: tuint :: nil) tuint cc_default)) ::
 (___builtin_cmpb,
   Gfun(External (EF_builtin "__builtin_cmpb"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xint
                     cc_default)) (tuint :: tuint :: nil) tuint cc_default)) ::
 (___builtin_mulhd,
   Gfun(External (EF_builtin "__builtin_mulhd"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___builtin_mulhdu,
   Gfun(External (EF_builtin "__builtin_mulhdu"
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tulong :: tulong :: nil) tulong
     cc_default)) ::
 (___builtin_fmadd,
   Gfun(External (EF_builtin "__builtin_fmadd"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fmsub,
   Gfun(External (EF_builtin "__builtin_fmsub"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fnmadd,
   Gfun(External (EF_builtin "__builtin_fnmadd"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fnmsub,
   Gfun(External (EF_builtin "__builtin_fnmsub"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_frsqrte,
   Gfun(External (EF_builtin "__builtin_frsqrte"
                   (mksignature (AST.Xfloat :: nil) AST.Xfloat cc_default))
     (tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fres,
   Gfun(External (EF_builtin "__builtin_fres"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (___builtin_fsel,
   Gfun(External (EF_builtin "__builtin_fsel"
                   (mksignature
                     (AST.Xfloat :: AST.Xfloat :: AST.Xfloat :: nil)
                     AST.Xfloat cc_default))
     (tdouble :: tdouble :: tdouble :: nil) tdouble cc_default)) ::
 (___builtin_fcti,
   Gfun(External (EF_builtin "__builtin_fcti"
                   (mksignature (AST.Xfloat :: nil) AST.Xint cc_default))
     (tdouble :: nil) tint cc_default)) ::
 (___builtin_read16_reversed,
   Gfun(External (EF_builtin "__builtin_read16_reversed"
                   (mksignature (AST.Xptr :: nil) AST.Xint16unsigned
                     cc_default)) ((tptr tushort) :: nil) tushort
     cc_default)) ::
 (___builtin_read32_reversed,
   Gfun(External (EF_builtin "__builtin_read32_reversed"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tuint) :: nil) tuint cc_default)) ::
 (___builtin_write16_reversed,
   Gfun(External (EF_builtin "__builtin_write16_reversed"
                   (mksignature (AST.Xptr :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default))
     ((tptr tushort) :: tushort :: nil) tvoid cc_default)) ::
 (___builtin_write32_reversed,
   Gfun(External (EF_builtin "__builtin_write32_reversed"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tuint) :: tuint :: nil) tvoid
     cc_default)) ::
 (___builtin_read64_reversed,
   Gfun(External (EF_builtin "__builtin_read64_reversed"
                   (mksignature (AST.Xptr :: nil) AST.Xlong cc_default))
     ((tptr tulong) :: nil) tulong cc_default)) ::
 (___builtin_write64_reversed,
   Gfun(External (EF_builtin "__builtin_write64_reversed"
                   (mksignature (AST.Xptr :: AST.Xlong :: nil) AST.Xvoid
                     cc_default)) ((tptr tulong) :: tulong :: nil) tvoid
     cc_default)) ::
 (___builtin_eieio,
   Gfun(External (EF_builtin "__builtin_eieio"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_sync,
   Gfun(External (EF_builtin "__builtin_sync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_isync,
   Gfun(External (EF_builtin "__builtin_isync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_lwsync,
   Gfun(External (EF_builtin "__builtin_lwsync"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_mbar,
   Gfun(External (EF_builtin "__builtin_mbar"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (___builtin_trap,
   Gfun(External (EF_builtin "__builtin_trap"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_dcbf,
   Gfun(External (EF_builtin "__builtin_dcbf"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_dcbi,
   Gfun(External (EF_builtin "__builtin_dcbi"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_icbi,
   Gfun(External (EF_builtin "__builtin_icbi"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_prefetch,
   Gfun(External (EF_builtin "__builtin_prefetch"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: tint :: tint :: nil) tvoid cc_default)) ::
 (___builtin_dcbtls,
   Gfun(External (EF_builtin "__builtin_dcbtls"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tint :: nil) tvoid
     cc_default)) ::
 (___builtin_icbtls,
   Gfun(External (EF_builtin "__builtin_icbtls"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tint :: nil) tvoid
     cc_default)) ::
 (___builtin_dcbz,
   Gfun(External (EF_builtin "__builtin_dcbz"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (___builtin_get_spr,
   Gfun(External (EF_builtin "__builtin_get_spr"
                   (mksignature (AST.Xint :: nil) AST.Xint cc_default))
     (tint :: nil) tuint cc_default)) ::
 (___builtin_set_spr,
   Gfun(External (EF_builtin "__builtin_set_spr"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tuint :: nil) tvoid cc_default)) ::
 (___builtin_get_spr64,
   Gfun(External (EF_builtin "__builtin_get_spr64"
                   (mksignature (AST.Xint :: nil) AST.Xlong cc_default))
     (tint :: nil) tulong cc_default)) ::
 (___builtin_set_spr64,
   Gfun(External (EF_builtin "__builtin_set_spr64"
                   (mksignature (AST.Xint :: AST.Xlong :: nil) AST.Xvoid
                     cc_default)) (tint :: tulong :: nil) tvoid cc_default)) ::
 (___builtin_mr,
   Gfun(External (EF_builtin "__builtin_mr"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) (tint :: tint :: nil) tvoid cc_default)) ::
 (___builtin_call_frame,
   Gfun(External (EF_builtin "__builtin_call_frame"
                   (mksignature nil AST.Xptr cc_default)) nil (tptr tvoid)
     cc_default)) ::
 (___builtin_return_address,
   Gfun(External (EF_builtin "__builtin_return_address"
                   (mksignature nil AST.Xptr cc_default)) nil (tptr tvoid)
     cc_default)) ::
 (___builtin_isel,
   Gfun(External (EF_builtin "__builtin_isel"
                   (mksignature (AST.Xbool :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tbool :: tint :: tint :: nil)
     tint cc_default)) ::
 (___builtin_uisel,
   Gfun(External (EF_builtin "__builtin_uisel"
                   (mksignature (AST.Xbool :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tbool :: tuint :: tuint :: nil)
     tuint cc_default)) ::
 (___builtin_isel64,
   Gfun(External (EF_builtin "__builtin_isel64"
                   (mksignature (AST.Xbool :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xlong cc_default)) (tbool :: tlong :: tlong :: nil)
     tlong cc_default)) ::
 (___builtin_uisel64,
   Gfun(External (EF_builtin "__builtin_uisel64"
                   (mksignature (AST.Xbool :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xlong cc_default))
     (tbool :: tulong :: tulong :: nil) tulong cc_default)) ::
 (___builtin_bsel,
   Gfun(External (EF_builtin "__builtin_bsel"
                   (mksignature (AST.Xbool :: AST.Xbool :: AST.Xbool :: nil)
                     AST.Xbool cc_default)) (tbool :: tbool :: tbool :: nil)
     tbool cc_default)) ::
 (___builtin_nop,
   Gfun(External (EF_builtin "__builtin_nop"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (___builtin_atomic_exchange,
   Gfun(External (EF_builtin "__builtin_atomic_exchange"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr tint) :: (tptr tint) :: (tptr tint) :: nil) tvoid cc_default)) ::
 (___builtin_atomic_load,
   Gfun(External (EF_builtin "__builtin_atomic_load"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) ((tptr tint) :: (tptr tint) :: nil) tvoid
     cc_default)) ::
 (___builtin_atomic_compare_exchange,
   Gfun(External (EF_builtin "__builtin_atomic_compare_exchange"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xbool cc_default))
     ((tptr tint) :: (tptr tint) :: (tptr tint) :: nil) tbool cc_default)) ::
 (___builtin_sync_fetch_and_add,
   Gfun(External (EF_builtin "__builtin_sync_fetch_and_add"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tint) :: tint :: nil) tint
     cc_default)) ::
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Xint :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (tint :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_osRecvMesg,
   Gfun(External (EF_external "osRecvMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tint cc_default)) ::
 (_osInvalDCache,
   Gfun(External (EF_external "osInvalDCache"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) ::
 (_osInvalICache,
   Gfun(External (EF_external "osInvalICache"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) ::
 (_osWritebackDCacheAll,
   Gfun(External (EF_external "osWritebackDCacheAll"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osPiStartDma,
   Gfun(External (EF_external "osPiStartDma"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xint :: AST.Xint ::
                      AST.Xptr :: AST.Xint :: AST.Xptr :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct __423 noattr)) :: tint :: tint :: tuint ::
      (tptr tvoid) :: tuint :: (tptr (Tstruct _OSMesgQueue_s noattr)) :: nil)
     tint cc_default)) ::
 (_bzero,
   Gfun(External (EF_external "bzero"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tvoid
     cc_default)) :: (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_gGfxPoolEnd, Gvar v_gGfxPoolEnd) ::
 (_gDecompressionHeap, Gvar v_gDecompressionHeap) ::
 (_decompress,
   Gfun(External (EF_external "decompress"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: (tptr tvoid) :: nil) tvoid
     cc_default)) :: (_gDmaIoMesg, Gvar v_gDmaIoMesg) ::
 (_gMainReceivedMesg, Gvar v_gMainReceivedMesg) ::
 (_gDmaMesgQueue, Gvar v_gDmaMesgQueue) ::
 (__engineSegmentRomStart, Gvar v__engineSegmentRomStart) ::
 (__engineSegmentRomEnd, Gvar v__engineSegmentRomEnd) ::
 (_gEffectsMemoryPool, Gvar v_gEffectsMemoryPool) ::
 (_sSegmentTable, Gvar v_sSegmentTable) ::
 (_sPoolFreeSpace, Gvar v_sPoolFreeSpace) ::
 (_sPoolStart, Gvar v_sPoolStart) :: (_sPoolEnd, Gvar v_sPoolEnd) ::
 (_sPoolListHeadL, Gvar v_sPoolListHeadL) ::
 (_sPoolListHeadR, Gvar v_sPoolListHeadR) ::
 (_gMainPoolState, Gvar v_gMainPoolState) ::
 (_set_segment_base_addr, Gfun(Internal f_set_segment_base_addr)) ::
 (_get_segment_base_addr, Gfun(Internal f_get_segment_base_addr)) ::
 (_segmented_to_virtual, Gfun(Internal f_segmented_to_virtual)) ::
 (_virtual_to_segmented, Gfun(Internal f_virtual_to_segmented)) ::
 (_move_segment_table_to_dmem, Gfun(Internal f_move_segment_table_to_dmem)) ::
 (_main_pool_init, Gfun(Internal f_main_pool_init)) ::
 (_main_pool_alloc, Gfun(Internal f_main_pool_alloc)) ::
 (_main_pool_free, Gfun(Internal f_main_pool_free)) ::
 (_main_pool_realloc, Gfun(Internal f_main_pool_realloc)) ::
 (_main_pool_available, Gfun(Internal f_main_pool_available)) ::
 (_main_pool_push_state, Gfun(Internal f_main_pool_push_state)) ::
 (_main_pool_pop_state, Gfun(Internal f_main_pool_pop_state)) ::
 (_dma_read, Gfun(Internal f_dma_read)) ::
 (_dynamic_dma_read, Gfun(Internal f_dynamic_dma_read)) ::
 (_load_segment, Gfun(Internal f_load_segment)) ::
 (_load_to_fixed_pool_addr, Gfun(Internal f_load_to_fixed_pool_addr)) ::
 (_load_segment_decompress, Gfun(Internal f_load_segment_decompress)) ::
 (_load_segment_decompress_heap, Gfun(Internal f_load_segment_decompress_heap)) ::
 (_load_engine_code_segment, Gfun(Internal f_load_engine_code_segment)) ::
 (_alloc_only_pool_init, Gfun(Internal f_alloc_only_pool_init)) ::
 (_alloc_only_pool_alloc, Gfun(Internal f_alloc_only_pool_alloc)) ::
 (_alloc_only_pool_resize, Gfun(Internal f_alloc_only_pool_resize)) ::
 (_mem_pool_init, Gfun(Internal f_mem_pool_init)) ::
 (_mem_pool_alloc, Gfun(Internal f_mem_pool_alloc)) ::
 (_mem_pool_free, Gfun(Internal f_mem_pool_free)) ::
 (_alloc_display_list, Gfun(Internal f_alloc_display_list)) ::
 (_load_dma_table_address, Gfun(Internal f_load_dma_table_address)) ::
 (_setup_dma_table_list, Gfun(Internal f_setup_dma_table_list)) ::
 (_load_patchable_table, Gfun(Internal f_load_patchable_table)) :: nil).

Definition public_idents : list ident :=
(_load_patchable_table :: _setup_dma_table_list :: _alloc_display_list ::
 _mem_pool_free :: _mem_pool_alloc :: _mem_pool_init ::
 _alloc_only_pool_resize :: _alloc_only_pool_alloc ::
 _alloc_only_pool_init :: _load_engine_code_segment ::
 _load_segment_decompress_heap :: _load_segment_decompress ::
 _load_to_fixed_pool_addr :: _load_segment :: _main_pool_pop_state ::
 _main_pool_push_state :: _main_pool_available :: _main_pool_realloc ::
 _main_pool_free :: _main_pool_alloc :: _main_pool_init ::
 _move_segment_table_to_dmem :: _virtual_to_segmented ::
 _segmented_to_virtual :: _get_segment_base_addr :: _set_segment_base_addr ::
 _sPoolListHeadR :: _sPoolListHeadL :: _sPoolEnd :: _sPoolStart ::
 _sPoolFreeSpace :: _sSegmentTable :: _gEffectsMemoryPool ::
 __engineSegmentRomEnd :: __engineSegmentRomStart :: _gDmaMesgQueue ::
 _gMainReceivedMesg :: _gDmaIoMesg :: _decompress :: _gDecompressionHeap ::
 _gGfxPoolEnd :: _gDisplayListHead :: _bzero :: _osPiStartDma ::
 _osWritebackDCacheAll :: _osInvalICache :: _osInvalDCache :: _osRecvMesg ::
 ___builtin_debug :: ___builtin_sync_fetch_and_add ::
 ___builtin_atomic_compare_exchange :: ___builtin_atomic_load ::
 ___builtin_atomic_exchange :: ___builtin_nop :: ___builtin_bsel ::
 ___builtin_uisel64 :: ___builtin_isel64 :: ___builtin_uisel ::
 ___builtin_isel :: ___builtin_return_address :: ___builtin_call_frame ::
 ___builtin_mr :: ___builtin_set_spr64 :: ___builtin_get_spr64 ::
 ___builtin_set_spr :: ___builtin_get_spr :: ___builtin_dcbz ::
 ___builtin_icbtls :: ___builtin_dcbtls :: ___builtin_prefetch ::
 ___builtin_icbi :: ___builtin_dcbi :: ___builtin_dcbf :: ___builtin_trap ::
 ___builtin_mbar :: ___builtin_lwsync :: ___builtin_isync ::
 ___builtin_sync :: ___builtin_eieio :: ___builtin_write64_reversed ::
 ___builtin_read64_reversed :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fcti :: ___builtin_fsel ::
 ___builtin_fres :: ___builtin_frsqrte :: ___builtin_fnmsub ::
 ___builtin_fnmadd :: ___builtin_fmsub :: ___builtin_fmadd ::
 ___builtin_mulhdu :: ___builtin_mulhd :: ___builtin_cmpb ::
 ___builtin_mulhwu :: ___builtin_mulhw :: ___builtin_expect ::
 ___builtin_unreachable :: ___builtin_va_end :: ___builtin_va_copy ::
 ___builtin_va_arg :: ___builtin_va_start :: ___builtin_membar ::
 ___builtin_annot_intval :: ___builtin_annot :: ___builtin_sel ::
 ___builtin_memcpy_aligned :: ___builtin_sqrt :: ___builtin_fsqrt ::
 ___builtin_fabsf :: ___builtin_fabs :: ___builtin_ctzll ::
 ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll :: ___builtin_clzl ::
 ___builtin_clz :: ___builtin_bswap16 :: ___builtin_bswap32 ::
 ___builtin_bswap :: ___builtin_bswap64 :: ___builtin_ais_annot ::
 ___compcert_i64_umulh :: ___compcert_i64_smulh :: ___compcert_i64_sar ::
 ___compcert_i64_shr :: ___compcert_i64_shl :: ___compcert_i64_umod ::
 ___compcert_i64_smod :: ___compcert_i64_udiv :: ___compcert_i64_sdiv ::
 ___compcert_i64_utof :: ___compcert_i64_stof :: ___compcert_i64_utod ::
 ___compcert_i64_stod :: ___compcert_i64_dtou :: ___compcert_i64_dtos ::
 ___compcert_va_composite :: ___compcert_va_float64 ::
 ___compcert_va_int64 :: ___compcert_va_int32 :: nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


