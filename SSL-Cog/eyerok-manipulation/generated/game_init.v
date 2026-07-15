(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: build/source/game_init.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -I../../../reference-sm64-decomp/include -I../../../reference-sm64-decomp/build/us -I../../../reference-sm64-decomp/build/us/include -I../../../reference-sm64-decomp/src -I../../../reference-sm64-decomp/src/engine -I../../../reference-sm64-decomp/src/game -I../../../reference-sm64-decomp -I../../../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition source_file := "build/source/game_init.c".
  Definition normalized := true.
End Info.

Definition _Controller : ident := $"Controller".
Definition _DemoInput : ident := $"DemoInput".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _GfxPool : ident := $"GfxPool".
Definition _LevelCommand : ident := $"LevelCommand".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _SPTask : ident := $"SPTask".
Definition _VblankHandler : ident := $"VblankHandler".
Definition __248 : ident := $"_248".
Definition __249 : ident := $"_249".
Definition __251 : ident := $"_251".
Definition __253 : ident := $"_253".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
Definition __356 : ident := $"_356".
Definition __358 : ident := $"_358".
Definition __469 : ident := $"_469".
Definition __474 : ident := $"_474".
Definition __476 : ident := $"_476".
Definition __510 : ident := $"_510".
Definition __512 : ident := $"_512".
Definition __514 : ident := $"_514".
Definition __516 : ident := $"_516".
Definition __518 : ident := $"_518".
Definition __520 : ident := $"_520".
Definition __522 : ident := $"_522".
Definition __524 : ident := $"_524".
Definition __526 : ident := $"_526".
Definition __528 : ident := $"_528".
Definition __530 : ident := $"_530".
Definition __532 : ident := $"_532".
Definition __534 : ident := $"_534".
Definition __536 : ident := $"_536".
Definition __538 : ident := $"_538".
Definition __547 : ident := $"_547".
Definition __549 : ident := $"_549".
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
Definition ___stringlit_1 : ident := $"__stringlit_1".
Definition __entrySegmentRomEnd : ident := $"_entrySegmentRomEnd".
Definition __entrySegmentRomStart : ident := $"_entrySegmentRomStart".
Definition __g : ident := $"_g".
Definition __g__1 : ident := $"_g__1".
Definition __g__10 : ident := $"_g__10".
Definition __g__11 : ident := $"_g__11".
Definition __g__12 : ident := $"_g__12".
Definition __g__13 : ident := $"_g__13".
Definition __g__14 : ident := $"_g__14".
Definition __g__15 : ident := $"_g__15".
Definition __g__2 : ident := $"_g__2".
Definition __g__3 : ident := $"_g__3".
Definition __g__4 : ident := $"_g__4".
Definition __g__5 : ident := $"_g__5".
Definition __g__6 : ident := $"_g__6".
Definition __g__7 : ident := $"_g__7".
Definition __g__8 : ident := $"_g__8".
Definition __g__9 : ident := $"_g__9".
Definition __segment2_mio0SegmentRomEnd : ident := $"_segment2_mio0SegmentRomEnd".
Definition __segment2_mio0SegmentRomStart : ident := $"_segment2_mio0SegmentRomStart".
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _addr : ident := $"addr".
Definition _adjust_analog_stick : ident := $"adjust_analog_stick".
Definition _anim : ident := $"anim".
Definition _arg : ident := $"arg".
Definition _at : ident := $"at".
Definition _audio_game_loop_tick : ident := $"audio_game_loop_tick".
Definition _badvaddr : ident := $"badvaddr".
Definition _base : ident := $"base".
Definition _bufTarget : ident := $"bufTarget".
Definition _buffer : ident := $"buffer".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonMask : ident := $"buttonMask".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cause : ident := $"cause".
Definition _clear_framebuffer : ident := $"clear_framebuffer".
Definition _clear_viewport : ident := $"clear_viewport".
Definition _cmd : ident := $"cmd".
Definition _color : ident := $"color".
Definition _cont : ident := $"cont".
Definition _context : ident := $"context".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_gfx_task_structure : ident := $"create_gfx_task_structure".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _currentAddr : ident := $"currentAddr".
Definition _data : ident := $"data".
Definition _data_ptr : ident := $"data_ptr".
Definition _data_size : ident := $"data_size".
Definition _display_and_vsync : ident := $"display_and_vsync".
Definition _dma : ident := $"dma".
Definition _dmaTable : ident := $"dmaTable".
Definition _dram : ident := $"dram".
Definition _dram_stack : ident := $"dram_stack".
Definition _dram_stack_size : ident := $"dram_stack_size".
Definition _draw_profiler : ident := $"draw_profiler".
Definition _draw_reset_bars : ident := $"draw_reset_bars".
Definition _draw_screen_borders : ident := $"draw_screen_borders".
Definition _end_master_display_list : ident := $"end_master_display_list".
Definition _entries : ident := $"entries".
Definition _errnum : ident := $"errnum".
Definition _exec_display_list : ident := $"exec_display_list".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _fbNum : ident := $"fbNum".
Definition _fbPtr : ident := $"fbPtr".
Definition _filler : ident := $"filler".
Definition _fillrect : ident := $"fillrect".
Definition _first : ident := $"first".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fmt : ident := $"fmt".
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
Definition _fullqueue : ident := $"fullqueue".
Definition _gControllerBits : ident := $"gControllerBits".
Definition _gControllerPads : ident := $"gControllerPads".
Definition _gControllerStatuses : ident := $"gControllerStatuses".
Definition _gControllers : ident := $"gControllers".
Definition _gCurrDemoInput : ident := $"gCurrDemoInput".
Definition _gDemoInputListID : ident := $"gDemoInputListID".
Definition _gDemoInputs : ident := $"gDemoInputs".
Definition _gDemoInputsBuf : ident := $"gDemoInputsBuf".
Definition _gDemoInputsMemAlloc : ident := $"gDemoInputsMemAlloc".
Definition _gDisplayListHead : ident := $"gDisplayListHead".
Definition _gEepromProbe : ident := $"gEepromProbe".
Definition _gFramebuffers : ident := $"gFramebuffers".
Definition _gGameMesgBuf : ident := $"gGameMesgBuf".
Definition _gGameVblankHandler : ident := $"gGameVblankHandler".
Definition _gGameVblankQueue : ident := $"gGameVblankQueue".
Definition _gGfxMesgBuf : ident := $"gGfxMesgBuf".
Definition _gGfxPool : ident := $"gGfxPool".
Definition _gGfxPoolEnd : ident := $"gGfxPoolEnd".
Definition _gGfxPools : ident := $"gGfxPools".
Definition _gGfxSPTask : ident := $"gGfxSPTask".
Definition _gGfxSPTaskOutputBuffer : ident := $"gGfxSPTaskOutputBuffer".
Definition _gGfxSPTaskStack : ident := $"gGfxSPTaskStack".
Definition _gGfxSPTaskYieldBuffer : ident := $"gGfxSPTaskYieldBuffer".
Definition _gGfxVblankQueue : ident := $"gGfxVblankQueue".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gGoddardVblankCallback : ident := $"gGoddardVblankCallback".
Definition _gMainReceivedMesg : ident := $"gMainReceivedMesg".
Definition _gMarioAnims : ident := $"gMarioAnims".
Definition _gMarioAnimsBuf : ident := $"gMarioAnimsBuf".
Definition _gMarioAnimsMemAlloc : ident := $"gMarioAnimsMemAlloc".
Definition _gNmiResetBarsTimer : ident := $"gNmiResetBarsTimer".
Definition _gPhysicalFramebuffers : ident := $"gPhysicalFramebuffers".
Definition _gPhysicalZBuffer : ident := $"gPhysicalZBuffer".
Definition _gPlayer1Controller : ident := $"gPlayer1Controller".
Definition _gPlayer2Controller : ident := $"gPlayer2Controller".
Definition _gPlayer3Controller : ident := $"gPlayer3Controller".
Definition _gRecordedDemoInput : ident := $"gRecordedDemoInput".
Definition _gResetTimer : ident := $"gResetTimer".
Definition _gSIEventMesgQueue : ident := $"gSIEventMesgQueue".
Definition _gShowDebugText : ident := $"gShowDebugText".
Definition _gShowProfiler : ident := $"gShowProfiler".
Definition _gZBuffer : ident := $"gZBuffer".
Definition _gp : ident := $"gp".
Definition _height : ident := $"height".
Definition _hi : ident := $"hi".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _init_controllers : ident := $"init_controllers".
Definition _init_rcp : ident := $"init_rcp".
Definition _init_rdp : ident := $"init_rdp".
Definition _init_rsp : ident := $"init_rsp".
Definition _init_z_buffer : ident := $"init_z_buffer".
Definition _len : ident := $"len".
Definition _level_script_entry : ident := $"level_script_entry".
Definition _level_script_execute : ident := $"level_script_execute".
Definition _line : ident := $"line".
Definition _lo : ident := $"lo".
Definition _load_segment : ident := $"load_segment".
Definition _load_segment_decompress : ident := $"load_segment_decompress".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _main : ident := $"main".
Definition _main_pool_alloc : ident := $"main_pool_alloc".
Definition _make_viewport_clip_rect : ident := $"make_viewport_clip_rect".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _move_segment_table_to_dmem : ident := $"move_segment_table_to_dmem".
Definition _ms : ident := $"ms".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _msgqueue : ident := $"msgqueue".
Definition _mt : ident := $"mt".
Definition _mtqueue : ident := $"mtqueue".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _number : ident := $"number".
Definition _offset : ident := $"offset".
Definition _on : ident := $"on".
Definition _osContGetReadData : ident := $"osContGetReadData".
Definition _osContInit : ident := $"osContInit".
Definition _osContStartReadData : ident := $"osContStartReadData".
Definition _osCreateMesgQueue : ident := $"osCreateMesgQueue".
Definition _osEepromProbe : ident := $"osEepromProbe".
Definition _osRecvMesg : ident := $"osRecvMesg".
Definition _osViSwapBuffer : ident := $"osViSwapBuffer".
Definition _osWritebackDCacheAll : ident := $"osWritebackDCacheAll".
Definition _output_buff : ident := $"output_buff".
Definition _output_buff_size : ident := $"output_buff_size".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _pc : ident := $"pc".
Definition _perspnorm : ident := $"perspnorm".
Definition _play_music : ident := $"play_music".
Definition _popmtx : ident := $"popmtx".
Definition _port : ident := $"port".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _priority : ident := $"priority".
Definition _profiler_log_thread5_time : ident := $"profiler_log_thread5_time".
Definition _queue : ident := $"queue".
Definition _ra : ident := $"ra".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _read_controller_inputs : ident := $"read_controller_inputs".
Definition _render_init : ident := $"render_init".
Definition _rspF3DBootEnd : ident := $"rspF3DBootEnd".
Definition _rspF3DBootStart : ident := $"rspF3DBootStart".
Definition _rspF3DDataStart : ident := $"rspF3DDataStart".
Definition _rspF3DStart : ident := $"rspF3DStart".
Definition _run_demo_inputs : ident := $"run_demo_inputs".
Definition _s : ident := $"s".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sRenderedFramebuffer : ident := $"sRenderedFramebuffer".
Definition _sRenderingFramebuffer : ident := $"sRenderingFramebuffer".
Definition _save_file_get_sound_mode : ident := $"save_file_get_sound_mode".
Definition _save_file_load_all : ident := $"save_file_load_all".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _select_framebuffer : ident := $"select_framebuffer".
Definition _select_gfx_pool : ident := $"select_gfx_pool".
Definition _set_segment_base_addr : ident := $"set_segment_base_addr".
Definition _set_sound_mode : ident := $"set_sound_mode".
Definition _set_vblank_handler : ident := $"set_vblank_handler".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _setup_dma_table_list : ident := $"setup_dma_table_list".
Definition _setup_game_memory : ident := $"setup_game_memory".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _siz : ident := $"siz".
Definition _size : ident := $"size".
Definition _sl : ident := $"sl".
Definition _sp : ident := $"sp".
Definition _spTask : ident := $"spTask".
Definition _sqrtf : ident := $"sqrtf".
Definition _sr : ident := $"sr".
Definition _srcAddr : ident := $"srcAddr".
Definition _startPushed : ident := $"startPushed".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _t : ident := $"t".
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
Definition _task : ident := $"task".
Definition _texture : ident := $"texture".
Definition _th : ident := $"th".
Definition _thprof : ident := $"thprof".
Definition _thread5_game_loop : ident := $"thread5_game_loop".
Definition _tile : ident := $"tile".
Definition _time : ident := $"time".
Definition _timer : ident := $"timer".
Definition _tl : ident := $"tl".
Definition _tlnext : ident := $"tlnext".
Definition _tmem : ident := $"tmem".
Definition _tri : ident := $"tri".
Definition _type : ident := $"type".
Definition _ucode : ident := $"ucode".
Definition _ucode_boot : ident := $"ucode_boot".
Definition _ucode_boot_size : ident := $"ucode_boot_size".
Definition _ucode_data : ident := $"ucode_data".
Definition _ucode_data_size : ident := $"ucode_data_size".
Definition _ucode_size : ident := $"ucode_size".
Definition _v : ident := $"v".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _viewport : ident := $"viewport".
Definition _vp : ident := $"vp".
Definition _vpLrx : ident := $"vpLrx".
Definition _vpLry : ident := $"vpLry".
Definition _vpPly : ident := $"vpPly".
Definition _vpUlx : ident := $"vpUlx".
Definition _vpUly : ident := $"vpUly".
Definition _vscale : ident := $"vscale".
Definition _vtrans : ident := $"vtrans".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wd : ident := $"wd".
Definition _width : ident := $"width".
Definition _words : ident := $"words".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
Definition _yield_data_ptr : ident := $"yield_data_ptr".
Definition _yield_data_size : ident := $"yield_data_size".
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
Definition _t'25 : ident := 152%positive.
Definition _t'26 : ident := 153%positive.
Definition _t'27 : ident := 154%positive.
Definition _t'28 : ident := 155%positive.
Definition _t'29 : ident := 156%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'30 : ident := 157%positive.
Definition _t'31 : ident := 158%positive.
Definition _t'32 : ident := 159%positive.
Definition _t'33 : ident := 160%positive.
Definition _t'34 : ident := 161%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tuchar 7);
  gvar_init := (Init_int8 (Int.repr 66) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_rspF3DBootStart := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rspF3DBootEnd := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rspF3DStart := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rspF3DDataStart := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioAnims := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputs := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxSPTaskYieldBuffer := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxSPTaskStack := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxPools := {|
  gvar_info := (tarray (Tstruct _GfxPool noattr) 2);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxSPTaskOutputBuffer := {|
  gvar_info := (tarray tulong 15872);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gFramebuffers := {|
  gvar_info := (tarray (tarray tushort 76800) 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gZBuffer := {|
  gvar_info := (tarray tushort 76800);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_level_script_entry := {|
  gvar_info := (tarray tuchar 0);
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

Definition v_gSIEventMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gResetTimer := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNmiResetBarsTimer := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShowProfiler := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShowDebugText := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__entrySegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__entrySegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__segment2_mio0SegmentRomStart := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v__segment2_mio0SegmentRomEnd := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gControllers := {|
  gvar_info := (tarray (Tstruct _Controller noattr) 3);
  gvar_init := (Init_space 84 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxSPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDisplayListHead := {|
  gvar_info := (tptr (Tunion __549 noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxPoolEnd := {|
  gvar_info := (tptr tuchar);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxPool := {|
  gvar_info := (tptr (Tstruct _GfxPool noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gControllerStatuses := {|
  gvar_info := (tarray (Tstruct __317 noattr) 4);
  gvar_init := (Init_space 16 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gControllerPads := {|
  gvar_info := (tarray (Tstruct __319 noattr) 4);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gControllerBits := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEepromProbe := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGameVblankQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxVblankQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGameMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 1);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGfxMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 1);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGameVblankHandler := {|
  gvar_info := (Tstruct _VblankHandler noattr);
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPhysicalFramebuffers := {|
  gvar_info := (tarray tuint 3);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPhysicalZBuffer := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioAnimsMemAlloc := {|
  gvar_info := (tptr tvoid);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputsMemAlloc := {|
  gvar_info := (tptr tvoid);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioAnimsBuf := {|
  gvar_info := (Tstruct _DmaHandlerList noattr);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputsBuf := {|
  gvar_info := (Tstruct _DmaHandlerList noattr);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGlobalTimer := {|
  gvar_info := tuint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRenderedFramebuffer := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sRenderingFramebuffer := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGoddardVblankCallback := {|
  gvar_info := (tptr (Tfunction nil tvoid cc_default));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer1Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := (Init_addrof _gControllers (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer2Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := (Init_addrof _gControllers (Ptrofs.repr 28) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer3Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := (Init_addrof _gControllers (Ptrofs.repr 56) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrDemoInput := {|
  gvar_info := (tptr (Tstruct _DemoInput noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDemoInputListID := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRecordedDemoInput := {|
  gvar_info := (Tstruct _DemoInput noattr);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_init_rdp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (__g__7, (tptr (Tunion __549 noattr))) ::
               (__g__8, (tptr (Tunion __549 noattr))) ::
               (__g__9, (tptr (Tunion __549 noattr))) ::
               (__g__10, (tptr (Tunion __549 noattr))) ::
               (__g__11, (tptr (Tunion __549 noattr))) ::
               (__g__12, (tptr (Tunion __549 noattr))) ::
               (__g__13, (tptr (Tunion __549 noattr))) ::
               (__g__14, (tptr (Tunion __549 noattr))) ::
               (__g__15, (tptr (Tunion __549 noattr))) ::
               (_t'16, (tptr (Tunion __549 noattr))) ::
               (_t'15, (tptr (Tunion __549 noattr))) ::
               (_t'14, (tptr (Tunion __549 noattr))) ::
               (_t'13, (tptr (Tunion __549 noattr))) ::
               (_t'12, (tptr (Tunion __549 noattr))) ::
               (_t'11, (tptr (Tunion __549 noattr))) ::
               (_t'10, (tptr (Tunion __549 noattr))) ::
               (_t'9, (tptr (Tunion __549 noattr))) ::
               (_t'8, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 227) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub
                        (Ebinop Osub (Econst_int (Int.repr 32) tint)
                          (Econst_int (Int.repr 23) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ebinop Osub (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 23) tint) tint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 237) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Econst_int (Int.repr 0) tint) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast (Econst_int (Int.repr 0) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Econst_int (Int.repr 320) tint) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast (Econst_int (Int.repr 240) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 252) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 31) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 4) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 20) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 31) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 5) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 15) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 7) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 3) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 12) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 7) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 9) tint)
                                tuint) tuint) tuint)
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 31) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 5) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 31) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 5) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint) tuint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 24) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ecast
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 31) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 28) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 4) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 15) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 7) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 12) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 4) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 9) tint) tuint) tuint) tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 31) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 7) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 3) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 21) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 7) tint) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 3) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 18) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 4) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 6) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 7) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 3) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 4) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint)
                  tuint) tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 227) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub
                              (Ebinop Osub (Econst_int (Int.repr 32) tint)
                                (Econst_int (Int.repr 16) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Osub (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                    (Econst_int (Int.repr 16) tint) tint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 227) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 32) tint)
                                  (Econst_int (Int.repr 14) tint) tint)
                                (Econst_int (Int.repr 2) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                      (Econst_int (Int.repr 14) tint) tint) tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__6
                    (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 227) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Osub
                                  (Ebinop Osub
                                    (Econst_int (Int.repr 32) tint)
                                    (Econst_int (Int.repr 17) tint) tint)
                                  (Econst_int (Int.repr 2) tint) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 8) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                        (Econst_int (Int.repr 17) tint) tint) tuint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__7
                      (Ecast (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 227) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Osub
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 32) tint)
                                      (Econst_int (Int.repr 19) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 8) tint) tuint) tuint)
                          tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Osub (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 0) tint) tuint) tuint)
                        tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w1 tuint)
                      (Ecast
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 19) tint) tint) tuint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'9
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __549 noattr)))))
                      (Sset __g__8
                        (Ecast (Etempvar _t'9 (tptr (Tunion __549 noattr)))
                          (tptr (Tunion __549 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w0 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 227) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Osub
                                      (Ebinop Osub
                                        (Econst_int (Int.repr 32) tint)
                                        (Econst_int (Int.repr 12) tint) tint)
                                      (Econst_int (Int.repr 2) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 8) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast
                                  (Ebinop Osub (Econst_int (Int.repr 2) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 0) tint) tuint) tuint)
                          tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__8 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ecast
                          (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                            (Econst_int (Int.repr 12) tint) tint) tuint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                          (Sassign
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'10 (tptr (Tunion __549 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __549 noattr)))))
                        (Sset __g__9
                          (Ecast
                            (Etempvar _t'10 (tptr (Tunion __549 noattr)))
                            (tptr (Tunion __549 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__9 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 227) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Osub
                                        (Ebinop Osub
                                          (Econst_int (Int.repr 32) tint)
                                          (Econst_int (Int.repr 9) tint)
                                          tint)
                                        (Econst_int (Int.repr 3) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 8) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 3) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__9 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w1 tuint)
                          (Ecast
                            (Ebinop Oshl (Econst_int (Int.repr 6) tint)
                              (Econst_int (Int.repr 9) tint) tint) tuint))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'11
                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                            (Sassign
                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                              (Ebinop Oadd
                                (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                                (Econst_int (Int.repr 1) tint)
                                (tptr (Tunion __549 noattr)))))
                          (Sset __g__10
                            (Ecast
                              (Etempvar _t'11 (tptr (Tunion __549 noattr)))
                              (tptr (Tunion __549 noattr)))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__10 (tptr (Tunion __549 noattr)))
                                  (Tunion __549 noattr)) _words
                                (Tstruct __547 noattr)) _w0 tuint)
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast (Econst_int (Int.repr 227) tint)
                                        tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 24) tint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Osub
                                          (Ebinop Osub
                                            (Econst_int (Int.repr 32) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 8) tint)
                                    tuint) tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Osub
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 0) tint)
                                  tuint) tuint) tuint))
                          (Sassign
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar __g__10 (tptr (Tunion __549 noattr)))
                                  (Tunion __549 noattr)) _words
                                (Tstruct __547 noattr)) _w1 tuint)
                            (Ecast
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 8) tint) tint) tuint))))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'12
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                              (Sassign
                                (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tunion __549 noattr)))))
                            (Sset __g__11
                              (Ecast
                                (Etempvar _t'12 (tptr (Tunion __549 noattr)))
                                (tptr (Tunion __549 noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__11 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w0 tuint)
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Econst_int (Int.repr 226) tint)
                                          tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 24) tint) tuint)
                                    tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ebinop Osub
                                            (Ebinop Osub
                                              (Econst_int (Int.repr 32) tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint)
                                            (Econst_int (Int.repr 2) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 8) tint) tuint)
                                    tuint) tuint)
                                (Ecast
                                  (Ebinop Oshl
                                    (Ebinop Oand
                                      (Ecast
                                        (Ebinop Osub
                                          (Econst_int (Int.repr 2) tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Ebinop Osub
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 1) tint)
                                          (Econst_int (Int.repr 8) tint)
                                          tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuint) (Econst_int (Int.repr 0) tint)
                                    tuint) tuint) tuint))
                            (Sassign
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar __g__11 (tptr (Tunion __549 noattr)))
                                    (Tunion __549 noattr)) _words
                                  (Tstruct __547 noattr)) _w1 tuint)
                              (Ecast
                                (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                  (Econst_int (Int.repr 0) tint) tint) tuint))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'13
                                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                (Sassign
                                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                  (Ebinop Oadd
                                    (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tunion __549 noattr)))))
                              (Sset __g__12
                                (Ecast
                                  (Etempvar _t'13 (tptr (Tunion __549 noattr)))
                                  (tptr (Tunion __549 noattr)))))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__12 (tptr (Tunion __549 noattr)))
                                      (Tunion __549 noattr)) _words
                                    (Tstruct __547 noattr)) _w0 tuint)
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 226) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 24) tint)
                                        tuint) tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Ebinop Osub
                                              (Ebinop Osub
                                                (Econst_int (Int.repr 32) tint)
                                                (Econst_int (Int.repr 3) tint)
                                                tint)
                                              (Econst_int (Int.repr 29) tint)
                                              tint) tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 8) tint) tuint)
                                      tuint) tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Ebinop Oand
                                        (Ecast
                                          (Ebinop Osub
                                            (Econst_int (Int.repr 29) tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Ebinop Osub
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 1) tint)
                                            (Econst_int (Int.repr 8) tint)
                                            tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 0) tint) tuint)
                                    tuint) tuint))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar __g__12 (tptr (Tunion __549 noattr)))
                                      (Tunion __549 noattr)) _words
                                    (Tstruct __547 noattr)) _w1 tuint)
                                (Ecast
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ebinop Oor
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Econst_int (Int.repr 0) tint)
                                                (Econst_int (Int.repr 16384) tint)
                                                tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint)
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 0) tint)
                                              (Econst_int (Int.repr 30) tint)
                                              tint) tint)
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 3) tint)
                                            (Econst_int (Int.repr 26) tint)
                                            tint) tint)
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 0) tint)
                                          (Econst_int (Int.repr 22) tint)
                                          tint) tint)
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 2) tint)
                                        (Econst_int (Int.repr 18) tint) tint)
                                      tint)
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ebinop Oor
                                          (Ebinop Oor
                                            (Ebinop Oor
                                              (Ebinop Oor
                                                (Econst_int (Int.repr 0) tint)
                                                (Econst_int (Int.repr 16384) tint)
                                                tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint)
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 0) tint)
                                              (Econst_int (Int.repr 28) tint)
                                              tint) tint)
                                          (Ebinop Oshl
                                            (Econst_int (Int.repr 3) tint)
                                            (Econst_int (Int.repr 24) tint)
                                            tint) tint)
                                        (Ebinop Oshl
                                          (Econst_int (Int.repr 0) tint)
                                          (Econst_int (Int.repr 20) tint)
                                          tint) tint)
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 2) tint)
                                        (Econst_int (Int.repr 16) tint) tint)
                                      tint) tint) tuint))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'14
                                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                  (Sassign
                                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                    (Ebinop Oadd
                                      (Etempvar _t'14 (tptr (Tunion __549 noattr)))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr (Tunion __549 noattr)))))
                                (Sset __g__13
                                  (Ecast
                                    (Etempvar _t'14 (tptr (Tunion __549 noattr)))
                                    (tptr (Tunion __549 noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__13 (tptr (Tunion __549 noattr)))
                                        (Tunion __549 noattr)) _words
                                      (Tstruct __547 noattr)) _w0 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Econst_int (Int.repr 227) tint)
                                              tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 24) tint)
                                          tuint) tuint)
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Ebinop Osub
                                                (Ebinop Osub
                                                  (Econst_int (Int.repr 32) tint)
                                                  (Econst_int (Int.repr 6) tint)
                                                  tint)
                                                (Econst_int (Int.repr 2) tint)
                                                tint) tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 8) tint)
                                          tuint) tuint) tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Ebinop Osub
                                              (Econst_int (Int.repr 2) tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 0) tint) tuint)
                                      tuint) tuint))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar __g__13 (tptr (Tunion __549 noattr)))
                                        (Tunion __549 noattr)) _words
                                      (Tstruct __547 noattr)) _w1 tuint)
                                  (Ecast
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 0) tint)
                                      (Econst_int (Int.repr 6) tint) tint)
                                    tuint))))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                    (Sassign
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                      (Ebinop Oadd
                                        (Etempvar _t'15 (tptr (Tunion __549 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __549 noattr)))))
                                  (Sset __g__14
                                    (Ecast
                                      (Etempvar _t'15 (tptr (Tunion __549 noattr)))
                                      (tptr (Tunion __549 noattr)))))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__14 (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w0 tuint)
                                    (Ebinop Oor
                                      (Ebinop Oor
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Econst_int (Int.repr 227) tint)
                                                tuint)
                                              (Ebinop Osub
                                                (Ebinop Oshl
                                                  (Econst_int (Int.repr 1) tint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Econst_int (Int.repr 24) tint)
                                            tuint) tuint)
                                        (Ecast
                                          (Ebinop Oshl
                                            (Ebinop Oand
                                              (Ecast
                                                (Ebinop Osub
                                                  (Ebinop Osub
                                                    (Econst_int (Int.repr 32) tint)
                                                    (Econst_int (Int.repr 20) tint)
                                                    tint)
                                                  (Econst_int (Int.repr 2) tint)
                                                  tint) tuint)
                                              (Ebinop Osub
                                                (Ebinop Oshl
                                                  (Econst_int (Int.repr 1) tint)
                                                  (Econst_int (Int.repr 8) tint)
                                                  tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Econst_int (Int.repr 8) tint)
                                            tuint) tuint) tuint)
                                      (Ecast
                                        (Ebinop Oshl
                                          (Ebinop Oand
                                            (Ecast
                                              (Ebinop Osub
                                                (Econst_int (Int.repr 2) tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)
                                            (Ebinop Osub
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 8) tint)
                                                tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)
                                          (Econst_int (Int.repr 0) tint)
                                          tuint) tuint) tuint))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__14 (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w1 tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 3) tint)
                                        (Econst_int (Int.repr 20) tint) tint)
                                      tuint))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'16
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                    (Sassign
                                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                                      (Ebinop Oadd
                                        (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr (Tunion __549 noattr)))))
                                  (Sset __g__15
                                    (Ecast
                                      (Etempvar _t'16 (tptr (Tunion __549 noattr)))
                                      (tptr (Tunion __549 noattr)))))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__15 (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w0 tuint)
                                    (Ecast
                                      (Ebinop Oshl
                                        (Ebinop Oand
                                          (Ecast
                                            (Econst_int (Int.repr 231) tint)
                                            tuint)
                                          (Ebinop Osub
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 8) tint)
                                              tint)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuint)
                                        (Econst_int (Int.repr 24) tint)
                                        tuint) tuint))
                                  (Sassign
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar __g__15 (tptr (Tunion __549 noattr)))
                                          (Tunion __549 noattr)) _words
                                        (Tstruct __547 noattr)) _w1 tuint)
                                    (Econst_int (Int.repr 0) tint)))))))))))))))))))
|}.

Definition f_init_rsp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (__g__7, (tptr (Tunion __549 noattr))) ::
               (_t'8, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ebinop Oor
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand (Ecast (Econst_int (Int.repr 217) tint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 24) tint) tuint) tuint)
          (Ecast
            (Ebinop Oshl
              (Ebinop Oand
                (Ecast
                  (Eunop Onotint
                    (Ecast
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ebinop Oor (Econst_int (Int.repr 4) tint)
                                    (Econst_int (Int.repr 2097152) tint)
                                    tint) (Econst_int (Int.repr 1536) tint)
                                  tint) (Econst_int (Int.repr 65536) tint)
                                tint) (Econst_int (Int.repr 131072) tint)
                              tint) (Econst_int (Int.repr 262144) tint) tint)
                          (Econst_int (Int.repr 524288) tint) tint)
                        (Econst_int (Int.repr 1048576) tint) tint) tuint)
                    tuint) tuint)
                (Ebinop Osub
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 24) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tuint)
              (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Ecast (Econst_int (Int.repr 0) tint) tuint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 217) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 24) tint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Eunop Onotint
                      (Ecast (Econst_int (Int.repr 0) tint) tuint) tuint)
                    tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 24) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor (Econst_int (Int.repr 4) tint)
                  (Econst_int (Int.repr 2097152) tint) tint)
                (Econst_int (Int.repr 1024) tint) tint)
              (Econst_int (Int.repr 131072) tint) tint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 219) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 16) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Ebinop Omul (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 24) tint) tint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 215) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 0) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 11) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 7) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 1) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 16) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 219) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 4) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 4) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint) (Ecast (Econst_int (Int.repr 1) tint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 219) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 4) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 12) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 16) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint) (Ecast (Econst_int (Int.repr 1) tint) tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__6
                    (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 219) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 4) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 20) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 16) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast (Econst_int (Int.repr 65535) tint) tuint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__7
                    (Ecast (Etempvar _t'8 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 219) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 4) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 28) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 16) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__7 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast (Econst_int (Int.repr 65535) tint) tuint)))))))))))
|}.

Definition f_init_z_buffer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'8, tuint) ::
               (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 226) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub
                        (Ebinop Osub (Econst_int (Int.repr 32) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ebinop Osub (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast
            (Ebinop Oshl (Econst_int (Int.repr 0) tint)
              (Econst_int (Int.repr 2) tint) tint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 254) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sset _t'8 (Evar _gPhysicalZBuffer tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Ecast (Etempvar _t'8 tuint) tuint)))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 255) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 2) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Osub (Econst_int (Int.repr 320) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Ssequence
              (Sset _t'7 (Evar _gPhysicalZBuffer tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint) (Ecast (Etempvar _t'7 tuint) tuint)))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 247) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Ebinop Oor
                    (Ebinop Oshl
                      (Ebinop Oor
                        (Ebinop Oshl (Econst_int (Int.repr 16383) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 0) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint)
                    (Ebinop Oor
                      (Ebinop Oshl (Econst_int (Int.repr 16383) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 0) tint) tint) tint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__5
                (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 246) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 320) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 14) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Osub
                            (Ebinop Osub (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 1) tint) tint)
                            (Econst_int (Int.repr 8) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 14) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 8) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 2) tint) tuint) tuint) tuint)))))))))
|}.

Definition f_select_framebuffer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'6, tuint) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 227) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub
                        (Ebinop Osub (Econst_int (Int.repr 32) tint)
                          (Econst_int (Int.repr 20) tint) tint)
                        (Econst_int (Int.repr 2) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ebinop Osub (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast
            (Ebinop Oshl (Econst_int (Int.repr 0) tint)
              (Econst_int (Int.repr 20) tint) tint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 255) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 21) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 2) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 19) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 320) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Ssequence
            (Sset _t'5 (Evar _sRenderingFramebuffer tushort))
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd (Evar _gPhysicalFramebuffers (tarray tuint 3))
                    (Etempvar _t'5 tushort) (tptr tuint)) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint) (Ecast (Etempvar _t'6 tuint) tuint))))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__3
            (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 237) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Econst_int (Int.repr 0) tint) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast (Econst_int (Int.repr 8) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 2) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Econst_int (Int.repr 320) tint) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 8) tint) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint)))))))
|}.

Definition f_clear_framebuffer := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_color, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 226) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub
                        (Ebinop Osub (Econst_int (Int.repr 32) tint)
                          (Econst_int (Int.repr 3) tint) tint)
                        (Econst_int (Int.repr 29) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ebinop Osub (Econst_int (Int.repr 29) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 16384) tint) tint)
                        (Econst_int (Int.repr 0) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                        (Econst_int (Int.repr 30) tint) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                      (Econst_int (Int.repr 26) tint) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                    (Econst_int (Int.repr 22) tint) tint) tint)
                (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 18) tint) tint) tint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 16384) tint) tint)
                        (Econst_int (Int.repr 0) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                        (Econst_int (Int.repr 28) tint) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                      (Econst_int (Int.repr 24) tint) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                    (Econst_int (Int.repr 20) tint) tint) tint)
                (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 16) tint) tint) tint) tint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 227) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Osub
                          (Ebinop Osub (Econst_int (Int.repr 32) tint)
                            (Econst_int (Int.repr 20) tint) tint)
                          (Econst_int (Int.repr 2) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 2) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                (Econst_int (Int.repr 20) tint) tint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 247) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Ecast (Etempvar _color tint) tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 246) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 24) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub
                              (Ebinop Osub (Econst_int (Int.repr 320) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 14) tint) tuint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Osub
                            (Ebinop Osub (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 14) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 8) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 10) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 231) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint) (Econst_int (Int.repr 0) tint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__6
                  (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 227) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 32) tint)
                                  (Econst_int (Int.repr 20) tint) tint)
                                (Econst_int (Int.repr 2) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 2) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                      (Econst_int (Int.repr 20) tint) tint) tuint))))))))))
|}.

Definition f_clear_viewport := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_viewport, (tptr (Tunion __476 noattr))) ::
                (_color, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_vpUlx, tshort) :: (_vpUly, tshort) :: (_vpLrx, tshort) ::
               (_vpLry, tshort) :: (__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vtrans
            (tarray tshort 4)) (Econst_int (Int.repr 0) tint) (tptr tshort))
        tshort))
    (Ssequence
      (Sset _t'15
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                  (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vscale
              (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
            (tptr tshort)) tshort))
      (Sset _vpUlx
        (Ecast
          (Ebinop Oadd
            (Ebinop Odiv
              (Ebinop Osub (Etempvar _t'14 tshort) (Etempvar _t'15 tshort)
                tint) (Econst_int (Int.repr 4) tint) tint)
            (Econst_int (Int.repr 1) tint) tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                  (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vtrans
              (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
            (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'13
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                    (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                _vscale (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
              (tptr tshort)) tshort))
        (Sset _vpUly
          (Ecast
            (Ebinop Oadd
              (Ebinop Odiv
                (Ebinop Osub (Etempvar _t'12 tshort) (Etempvar _t'13 tshort)
                  tint) (Econst_int (Int.repr 4) tint) tint)
              (Econst_int (Int.repr 1) tint) tint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                    (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                _vtrans (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
              (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                      (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                  _vscale (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Sset _vpLrx
            (Ecast
              (Ebinop Osub
                (Ebinop Odiv
                  (Ebinop Oadd (Etempvar _t'10 tshort)
                    (Etempvar _t'11 tshort) tint)
                  (Econst_int (Int.repr 4) tint) tint)
                (Econst_int (Int.repr 2) tint) tint) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                      (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                  _vtrans (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _viewport (tptr (Tunion __476 noattr)))
                        (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                    _vscale (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _vpLry
              (Ecast
                (Ebinop Osub
                  (Ebinop Odiv
                    (Ebinop Oadd (Etempvar _t'8 tshort)
                      (Etempvar _t'9 tshort) tint)
                    (Econst_int (Int.repr 4) tint) tint)
                  (Econst_int (Int.repr 2) tint) tint) tshort))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'1
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g
                (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 231) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint) (Econst_int (Int.repr 0) tint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__1
                  (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 226) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 32) tint)
                                  (Econst_int (Int.repr 3) tint) tint)
                                (Econst_int (Int.repr 29) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 29) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ecast
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ebinop Oor (Econst_int (Int.repr 0) tint)
                                  (Econst_int (Int.repr 16384) tint) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 30) tint) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 26) tint) tint) tint)
                          (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 22) tint) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 18) tint) tint) tint)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ebinop Oor (Econst_int (Int.repr 0) tint)
                                  (Econst_int (Int.repr 16384) tint) tint)
                                (Econst_int (Int.repr 0) tint) tint)
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 28) tint) tint) tint)
                            (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                              (Econst_int (Int.repr 24) tint) tint) tint)
                          (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 20) tint) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 16) tint) tint) tint) tint)
                    tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                    (Sassign
                      (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                      (Ebinop Oadd
                        (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tunion __549 noattr)))))
                  (Sset __g__2
                    (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                      (tptr (Tunion __549 noattr)))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w0 tuint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast (Econst_int (Int.repr 227) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 24) tint) tuint) tuint)
                        (Ecast
                          (Ebinop Oshl
                            (Ebinop Oand
                              (Ecast
                                (Ebinop Osub
                                  (Ebinop Osub
                                    (Econst_int (Int.repr 32) tint)
                                    (Econst_int (Int.repr 20) tint) tint)
                                  (Econst_int (Int.repr 2) tint) tint) tuint)
                              (Ebinop Osub
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 8) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Econst_int (Int.repr 8) tint) tuint) tuint)
                        tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
                  (Sassign
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                          (Tunion __549 noattr)) _words
                        (Tstruct __547 noattr)) _w1 tuint)
                    (Ecast
                      (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                        (Econst_int (Int.repr 20) tint) tint) tuint))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                      (Sassign
                        (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                        (Ebinop Oadd
                          (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tunion __549 noattr)))))
                    (Sset __g__3
                      (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                        (tptr (Tunion __549 noattr)))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w0 tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 247) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint))
                    (Sassign
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                            (Tunion __549 noattr)) _words
                          (Tstruct __547 noattr)) _w1 tuint)
                      (Ecast (Etempvar _color tint) tuint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'5
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                        (Sassign
                          (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                          (Ebinop Oadd
                            (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                            (Econst_int (Int.repr 1) tint)
                            (tptr (Tunion __549 noattr)))))
                      (Sset __g__4
                        (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                          (tptr (Tunion __549 noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w0 tuint)
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Econst_int (Int.repr 246) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 24) tint)
                                tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast (Etempvar _vpLrx tshort) tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 10) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 14) tint)
                                tuint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Etempvar _vpLry tshort) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 10) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 2) tint) tuint) tuint)
                          tuint))
                      (Sassign
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                              (Tunion __549 noattr)) _words
                            (Tstruct __547 noattr)) _w1 tuint)
                        (Ebinop Oor
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Etempvar _vpUlx tshort) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 10) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 14) tint) tuint) tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Etempvar _vpUly tshort) tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 10) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 2) tint) tuint) tuint)
                          tuint))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                          (Sassign
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __549 noattr)))))
                        (Sset __g__5
                          (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                            (tptr (Tunion __549 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w0 tuint)
                          (Ecast
                            (Ebinop Oshl
                              (Ebinop Oand
                                (Ecast (Econst_int (Int.repr 231) tint)
                                  tuint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 8) tint) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)
                              (Econst_int (Int.repr 24) tint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w1 tuint)
                          (Econst_int (Int.repr 0) tint))))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                          (Sassign
                            (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                            (Ebinop Oadd
                              (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                              (Econst_int (Int.repr 1) tint)
                              (tptr (Tunion __549 noattr)))))
                        (Sset __g__6
                          (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                            (tptr (Tunion __549 noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w0 tuint)
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast (Econst_int (Int.repr 227) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 24) tint)
                                  tuint) tuint)
                              (Ecast
                                (Ebinop Oshl
                                  (Ebinop Oand
                                    (Ecast
                                      (Ebinop Osub
                                        (Ebinop Osub
                                          (Econst_int (Int.repr 32) tint)
                                          (Econst_int (Int.repr 20) tint)
                                          tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      tuint)
                                    (Ebinop Osub
                                      (Ebinop Oshl
                                        (Econst_int (Int.repr 1) tint)
                                        (Econst_int (Int.repr 8) tint) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint) (Econst_int (Int.repr 8) tint)
                                  tuint) tuint) tuint)
                            (Ecast
                              (Ebinop Oshl
                                (Ebinop Oand
                                  (Ecast
                                    (Ebinop Osub
                                      (Econst_int (Int.repr 2) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuint)
                                  (Ebinop Osub
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 8) tint) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint) (Econst_int (Int.repr 0) tint)
                                tuint) tuint) tuint))
                        (Sassign
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                                (Tunion __549 noattr)) _words
                              (Tstruct __547 noattr)) _w1 tuint)
                          (Ecast
                            (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 20) tint) tint) tuint))))))))))))))
|}.

Definition f_draw_screen_borders := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (__g__2, (tptr (Tunion __549 noattr))) ::
               (__g__3, (tptr (Tunion __549 noattr))) ::
               (__g__4, (tptr (Tunion __549 noattr))) ::
               (__g__5, (tptr (Tunion __549 noattr))) ::
               (__g__6, (tptr (Tunion __549 noattr))) ::
               (_t'7, (tptr (Tunion __549 noattr))) ::
               (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr (Tunion __549 noattr))) ::
               (_t'4, (tptr (Tunion __549 noattr))) ::
               (_t'3, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
        (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
          (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
            (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
      (Sset __g
        (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
          (tptr (Tunion __549 noattr)))))
    (Ssequence
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
          tuint)
        (Ecast
          (Ebinop Oshl
            (Ebinop Oand (Ecast (Econst_int (Int.repr 231) tint) tuint)
              (Ebinop Osub
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 8) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tuint)
            (Econst_int (Int.repr 24) tint) tuint) tuint))
      (Sassign
        (Efield
          (Efield
            (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
              (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
          tuint) (Econst_int (Int.repr 0) tint))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
              (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
        (Sset __g__1
          (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
            (tptr (Tunion __549 noattr)))))
      (Ssequence
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 237) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast (Econst_int (Int.repr 0) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ecast
                      (Ebinop Omul
                        (Ecast (Econst_int (Int.repr 0) tint) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 12) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
        (Sassign
          (Efield
            (Efield
              (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
            tuint)
          (Ebinop Oor
            (Ebinop Oor
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ecast (Econst_int (Int.repr 320) tint) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand
                  (Ecast
                    (Ecast
                      (Ebinop Omul
                        (Ecast (Econst_int (Int.repr 240) tint) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 12) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'3 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g__2
            (Ecast (Etempvar _t'3 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ebinop Oor
              (Ebinop Oor
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 226) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Osub
                          (Ebinop Osub (Econst_int (Int.repr 32) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Econst_int (Int.repr 29) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 29) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g__2 (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint)
            (Ecast
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 16384) tint) tint)
                          (Econst_int (Int.repr 0) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 30) tint) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                        (Econst_int (Int.repr 26) tint) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                      (Econst_int (Int.repr 22) tint) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 18) tint) tint) tint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 16384) tint) tint)
                          (Econst_int (Int.repr 0) tint) tint)
                        (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 28) tint) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                        (Econst_int (Int.repr 24) tint) tint) tint)
                    (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                      (Econst_int (Int.repr 20) tint) tint) tint)
                  (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 16) tint) tint) tint) tint) tuint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__3
              (Ecast (Etempvar _t'4 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 227) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ebinop Osub
                            (Ebinop Osub (Econst_int (Int.repr 32) tint)
                              (Econst_int (Int.repr 20) tint) tint)
                            (Econst_int (Int.repr 2) tint) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ebinop Osub (Econst_int (Int.repr 2) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__3 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ecast
                (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                  (Econst_int (Int.repr 20) tint) tint) tuint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                (Sassign
                  (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                  (Ebinop Oadd (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                    (Econst_int (Int.repr 1) tint)
                    (tptr (Tunion __549 noattr)))))
              (Sset __g__4
                (Ecast (Etempvar _t'5 (tptr (Tunion __549 noattr)))
                  (tptr (Tunion __549 noattr)))))
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w0 tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast (Econst_int (Int.repr 247) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 8) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 24) tint) tuint) tuint))
              (Sassign
                (Efield
                  (Efield
                    (Ederef (Etempvar __g__4 (tptr (Tunion __549 noattr)))
                      (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                  _w1 tuint)
                (Ecast
                  (Ebinop Oor
                    (Ebinop Oshl
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oand
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 63488) tint) tint)
                            (Ebinop Oand
                              (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                                (Econst_int (Int.repr 3) tint) tint)
                              (Econst_int (Int.repr 1984) tint) tint) tint)
                          (Ebinop Oand
                            (Ebinop Oshr (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 2) tint) tint)
                            (Econst_int (Int.repr 62) tint) tint) tint)
                        (Ebinop Oand (Econst_int (Int.repr 0) tint)
                          (Econst_int (Int.repr 1) tint) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint)
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oand
                            (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 8) tint) tint)
                            (Econst_int (Int.repr 63488) tint) tint)
                          (Ebinop Oand
                            (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                              (Econst_int (Int.repr 3) tint) tint)
                            (Econst_int (Int.repr 1984) tint) tint) tint)
                        (Ebinop Oand
                          (Ebinop Oshr (Econst_int (Int.repr 0) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 62) tint) tint) tint)
                      (Ebinop Oand (Econst_int (Int.repr 0) tint)
                        (Econst_int (Int.repr 1) tint) tint) tint) tint)
                  tuint))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__5
                  (Ecast (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 246) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 320) tint)
                                  (Econst_int (Int.repr 0) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 10) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 14) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 8) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__5 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 14) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                  (Sassign
                    (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                    (Ebinop Oadd (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (Tunion __549 noattr)))))
                (Sset __g__6
                  (Ecast (Etempvar _t'7 (tptr (Tunion __549 noattr)))
                    (tptr (Tunion __549 noattr)))))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w0 tuint)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast (Econst_int (Int.repr 246) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 24) tint) tuint) tuint)
                      (Ecast
                        (Ebinop Oshl
                          (Ebinop Oand
                            (Ecast
                              (Ebinop Osub
                                (Ebinop Osub (Econst_int (Int.repr 320) tint)
                                  (Econst_int (Int.repr 0) tint) tint)
                                (Econst_int (Int.repr 1) tint) tint) tuint)
                            (Ebinop Osub
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 10) tint) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Econst_int (Int.repr 14) tint) tuint) tuint)
                      tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))
                (Sassign
                  (Efield
                    (Efield
                      (Ederef (Etempvar __g__6 (tptr (Tunion __549 noattr)))
                        (Tunion __549 noattr)) _words (Tstruct __547 noattr))
                    _w1 tuint)
                  (Ebinop Oor
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 14) tint) tuint) tuint)
                    (Ecast
                      (Ebinop Oshl
                        (Ebinop Oand
                          (Ecast
                            (Ebinop Osub (Econst_int (Int.repr 240) tint)
                              (Econst_int (Int.repr 8) tint) tint) tuint)
                          (Ebinop Osub
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 10) tint) tint)
                            (Econst_int (Int.repr 1) tint) tint) tuint)
                        (Econst_int (Int.repr 2) tint) tuint) tuint) tuint))))))))))
|}.

Definition f_make_viewport_clip_rect := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_viewport, (tptr (Tunion __476 noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_vpUlx, tshort) :: (_vpPly, tshort) :: (_vpLrx, tshort) ::
               (_vpLry, tshort) :: (__g, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vtrans
            (tarray tshort 4)) (Econst_int (Int.repr 0) tint) (tptr tshort))
        tshort))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                  (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vscale
              (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
            (tptr tshort)) tshort))
      (Sset _vpUlx
        (Ecast
          (Ebinop Oadd
            (Ebinop Odiv
              (Ebinop Osub (Etempvar _t'8 tshort) (Etempvar _t'9 tshort)
                tint) (Econst_int (Int.repr 4) tint) tint)
            (Econst_int (Int.repr 1) tint) tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                  (Tunion __476 noattr)) _vp (Tstruct __474 noattr)) _vtrans
              (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
            (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                    (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                _vscale (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
              (tptr tshort)) tshort))
        (Sset _vpPly
          (Ecast
            (Ebinop Oadd
              (Ebinop Odiv
                (Ebinop Osub (Etempvar _t'6 tshort) (Etempvar _t'7 tshort)
                  tint) (Econst_int (Int.repr 4) tint) tint)
              (Econst_int (Int.repr 1) tint) tint) tshort))))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                    (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                _vtrans (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
              (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                      (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                  _vscale (tarray tshort 4)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Sset _vpLrx
            (Ecast
              (Ebinop Osub
                (Ebinop Odiv
                  (Ebinop Oadd (Etempvar _t'4 tshort) (Etempvar _t'5 tshort)
                    tint) (Econst_int (Int.repr 4) tint) tint)
                (Econst_int (Int.repr 1) tint) tint) tshort))))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _viewport (tptr (Tunion __476 noattr)))
                      (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                  _vtrans (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _viewport (tptr (Tunion __476 noattr)))
                        (Tunion __476 noattr)) _vp (Tstruct __474 noattr))
                    _vscale (tarray tshort 4)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _vpLry
              (Ecast
                (Ebinop Osub
                  (Ebinop Odiv
                    (Ebinop Oadd (Etempvar _t'2 tshort)
                      (Etempvar _t'3 tshort) tint)
                    (Econst_int (Int.repr 4) tint) tint)
                  (Econst_int (Int.repr 1) tint) tint) tshort))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'1
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g
              (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 237) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 8) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ecast
                            (Ebinop Omul
                              (Ecast (Etempvar _vpUlx tshort) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                              tfloat) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Etempvar _vpPly tshort) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast (Econst_int (Int.repr 0) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 24) tint) tuint) tuint)
                  (Ecast
                    (Ebinop Oshl
                      (Ebinop Oand
                        (Ecast
                          (Ecast
                            (Ebinop Omul
                              (Ecast (Etempvar _vpLrx tshort) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                              tfloat) tint) tuint)
                        (Ebinop Osub
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 12) tint) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)
                      (Econst_int (Int.repr 12) tint) tuint) tuint) tuint)
                (Ecast
                  (Ebinop Oshl
                    (Ebinop Oand
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ecast (Etempvar _vpLry tshort) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                            tfloat) tint) tuint)
                      (Ebinop Osub
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 12) tint) tint)
                        (Econst_int (Int.repr 1) tint) tint) tuint)
                    (Econst_int (Int.repr 0) tint) tuint) tuint) tuint))))))))
|}.

Definition f_create_gfx_task_structure := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_entries, tint) ::
               (_t'21, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'20, (tptr (Tunion __549 noattr))) ::
               (_t'19, (tptr (Tstruct _SPTask noattr))) ::
               (_t'18, (tptr (Tstruct _SPTask noattr))) ::
               (_t'17, (tptr (Tstruct _SPTask noattr))) ::
               (_t'16, (tptr (Tstruct _SPTask noattr))) ::
               (_t'15, (tptr (Tstruct _SPTask noattr))) ::
               (_t'14, (tptr (Tstruct _SPTask noattr))) ::
               (_t'13, (tptr (Tstruct _SPTask noattr))) ::
               (_t'12, (tptr (Tstruct _SPTask noattr))) ::
               (_t'11, (tptr (Tstruct _SPTask noattr))) ::
               (_t'10, (tptr (Tstruct _SPTask noattr))) ::
               (_t'9, (tptr (Tstruct _SPTask noattr))) ::
               (_t'8, (tptr (Tstruct _SPTask noattr))) ::
               (_t'7, (tptr (Tstruct _SPTask noattr))) ::
               (_t'6, (tptr (Tstruct _SPTask noattr))) ::
               (_t'5, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'4, (tptr (Tstruct _SPTask noattr))) ::
               (_t'3, (tptr (Tstruct _SPTask noattr))) ::
               (_t'2, (tptr (Tstruct _SPTask noattr))) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
    (Ssequence
      (Sset _t'21 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
      (Sset _entries
        (Ebinop Osub (Etempvar _t'20 (tptr (Tunion __549 noattr)))
          (Efield
            (Ederef (Etempvar _t'21 (tptr (Tstruct _GfxPool noattr)))
              (Tstruct _GfxPool noattr)) _buffer
            (tarray (Tunion __549 noattr) 6400)) tint))))
  (Ssequence
    (Ssequence
      (Sset _t'19 (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'19 (tptr (Tstruct _SPTask noattr)))
            (Tstruct _SPTask noattr)) _msgqueue
          (tptr (Tstruct _OSMesgQueue_s noattr)))
        (Eaddrof (Evar _gGfxVblankQueue (Tstruct _OSMesgQueue_s noattr))
          (tptr (Tstruct _OSMesgQueue_s noattr)))))
    (Ssequence
      (Ssequence
        (Sset _t'18 (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'18 (tptr (Tstruct _SPTask noattr)))
              (Tstruct _SPTask noattr)) _msg (tptr tvoid))
          (Ecast (Econst_int (Int.repr 2) tint) (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Sset _t'17 (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _t'17 (tptr (Tstruct _SPTask noattr)))
                    (Tstruct _SPTask noattr)) _task (Tunion __358 noattr)) _t
                (Tstruct __356 noattr)) _type tuint)
            (Econst_int (Int.repr 1) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'16 (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'16 (tptr (Tstruct _SPTask noattr)))
                      (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
                  _t (Tstruct __356 noattr)) _ucode_boot (tptr tulong))
              (Evar _rspF3DBootStart (tarray tulong 0))))
          (Ssequence
            (Ssequence
              (Sset _t'15 (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'15 (tptr (Tstruct _SPTask noattr)))
                        (Tstruct _SPTask noattr)) _task
                      (Tunion __358 noattr)) _t (Tstruct __356 noattr))
                  _ucode_boot_size tuint)
                (Ebinop Osub
                  (Ecast (Evar _rspF3DBootEnd (tarray tulong 0))
                    (tptr tuchar))
                  (Ecast (Evar _rspF3DBootStart (tarray tulong 0))
                    (tptr tuchar)) tint)))
            (Ssequence
              (Ssequence
                (Sset _t'14
                  (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                (Sassign
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'14 (tptr (Tstruct _SPTask noattr)))
                          (Tstruct _SPTask noattr)) _task
                        (Tunion __358 noattr)) _t (Tstruct __356 noattr))
                    _flags tuint) (Econst_int (Int.repr 0) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                  (Sassign
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'13 (tptr (Tstruct _SPTask noattr)))
                            (Tstruct _SPTask noattr)) _task
                          (Tunion __358 noattr)) _t (Tstruct __356 noattr))
                      _ucode (tptr tulong))
                    (Evar _rspF3DStart (tarray tulong 0))))
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                    (Sassign
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'12 (tptr (Tstruct _SPTask noattr)))
                              (Tstruct _SPTask noattr)) _task
                            (Tunion __358 noattr)) _t (Tstruct __356 noattr))
                        _ucode_data (tptr tulong))
                      (Evar _rspF3DDataStart (tarray tulong 0))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                      (Sassign
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'11 (tptr (Tstruct _SPTask noattr)))
                                (Tstruct _SPTask noattr)) _task
                              (Tunion __358 noattr)) _t
                            (Tstruct __356 noattr)) _ucode_size tuint)
                        (Econst_int (Int.repr 4096) tint)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                        (Sassign
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'10 (tptr (Tstruct _SPTask noattr)))
                                  (Tstruct _SPTask noattr)) _task
                                (Tunion __358 noattr)) _t
                              (Tstruct __356 noattr)) _ucode_data_size tuint)
                          (Econst_int (Int.repr 2048) tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
                            (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                          (Sassign
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'9 (tptr (Tstruct _SPTask noattr)))
                                    (Tstruct _SPTask noattr)) _task
                                  (Tunion __358 noattr)) _t
                                (Tstruct __356 noattr)) _dram_stack
                              (tptr tulong))
                            (Ecast (Evar _gGfxSPTaskStack (tarray tuchar 0))
                              (tptr tulong))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'8
                              (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                            (Sassign
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'8 (tptr (Tstruct _SPTask noattr)))
                                      (Tstruct _SPTask noattr)) _task
                                    (Tunion __358 noattr)) _t
                                  (Tstruct __356 noattr)) _dram_stack_size
                                tuint) (Econst_int (Int.repr 1024) tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
                                (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'7 (tptr (Tstruct _SPTask noattr)))
                                        (Tstruct _SPTask noattr)) _task
                                      (Tunion __358 noattr)) _t
                                    (Tstruct __356 noattr)) _output_buff
                                  (tptr tulong))
                                (Evar _gGfxSPTaskOutputBuffer (tarray tulong 15872))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'6
                                  (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                                (Sassign
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'6 (tptr (Tstruct _SPTask noattr)))
                                          (Tstruct _SPTask noattr)) _task
                                        (Tunion __358 noattr)) _t
                                      (Tstruct __356 noattr))
                                    _output_buff_size (tptr tulong))
                                  (Ecast
                                    (Ebinop Oadd
                                      (Ecast
                                        (Evar _gGfxSPTaskOutputBuffer (tarray tulong 15872))
                                        (tptr tuchar))
                                      (Esizeof (tarray tulong 15872) tuint)
                                      (tptr tuchar)) (tptr tulong))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'4
                                    (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                                  (Ssequence
                                    (Sset _t'5
                                      (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'4 (tptr (Tstruct _SPTask noattr)))
                                              (Tstruct _SPTask noattr)) _task
                                            (Tunion __358 noattr)) _t
                                          (Tstruct __356 noattr)) _data_ptr
                                        (tptr tulong))
                                      (Ecast
                                        (Eaddrof
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'5 (tptr (Tstruct _GfxPool noattr)))
                                              (Tstruct _GfxPool noattr))
                                            _buffer
                                            (tarray (Tunion __549 noattr) 6400))
                                          (tptr (tarray (Tunion __549 noattr) 6400)))
                                        (tptr tulong)))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'3
                                      (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                                    (Sassign
                                      (Efield
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'3 (tptr (Tstruct _SPTask noattr)))
                                              (Tstruct _SPTask noattr)) _task
                                            (Tunion __358 noattr)) _t
                                          (Tstruct __356 noattr)) _data_size
                                        tuint)
                                      (Ebinop Omul (Etempvar _entries tint)
                                        (Esizeof (Tunion __549 noattr) tuint)
                                        tuint)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'2
                                        (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'2 (tptr (Tstruct _SPTask noattr)))
                                                (Tstruct _SPTask noattr))
                                              _task (Tunion __358 noattr)) _t
                                            (Tstruct __356 noattr))
                                          _yield_data_ptr (tptr tulong))
                                        (Ecast
                                          (Evar _gGfxSPTaskYieldBuffer (tarray tuchar 0))
                                          (tptr tulong))))
                                    (Ssequence
                                      (Sset _t'1
                                        (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr))))
                                      (Sassign
                                        (Efield
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
                                                (Tstruct _SPTask noattr))
                                              _task (Tunion __358 noattr)) _t
                                            (Tstruct __356 noattr))
                                          _yield_data_size tuint)
                                        (Econst_int (Int.repr 3072) tint)))))))))))))))))))))
|}.

Definition f_init_rcp := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _move_segment_table_to_dmem (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None (Evar _init_rdp (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None (Evar _init_rsp (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Scall None (Evar _init_z_buffer (Tfunction nil tvoid cc_default))
          nil)
        (Scall None
          (Evar _select_framebuffer (Tfunction nil tvoid cc_default)) nil)))))
|}.

Definition f_end_master_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((__g, (tptr (Tunion __549 noattr))) ::
               (__g__1, (tptr (Tunion __549 noattr))) ::
               (_t'2, (tptr (Tunion __549 noattr))) ::
               (_t'1, (tptr (Tunion __549 noattr))) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _draw_screen_borders (Tfunction nil tvoid cc_default))
    nil)
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gShowProfiler tschar))
      (Sifthenelse (Etempvar _t'3 tschar)
        (Scall None (Evar _draw_profiler (Tfunction nil tvoid cc_default))
          nil)
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
            (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
              (Ebinop Oadd (Etempvar _t'1 (tptr (Tunion __549 noattr)))
                (Econst_int (Int.repr 1) tint) (tptr (Tunion __549 noattr)))))
          (Sset __g
            (Ecast (Etempvar _t'1 (tptr (Tunion __549 noattr)))
              (tptr (Tunion __549 noattr)))))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
              tuint)
            (Ecast
              (Ebinop Oshl
                (Ebinop Oand (Ecast (Econst_int (Int.repr 233) tint) tuint)
                  (Ebinop Osub
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 8) tint) tint)
                    (Econst_int (Int.repr 1) tint) tint) tuint)
                (Econst_int (Int.repr 24) tint) tuint) tuint))
          (Sassign
            (Efield
              (Efield
                (Ederef (Etempvar __g (tptr (Tunion __549 noattr)))
                  (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
              tuint) (Econst_int (Int.repr 0) tint))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
              (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
                (Ebinop Oadd (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tunion __549 noattr)))))
            (Sset __g__1
              (Ecast (Etempvar _t'2 (tptr (Tunion __549 noattr)))
                (tptr (Tunion __549 noattr)))))
          (Ssequence
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w0
                tuint)
              (Ecast
                (Ebinop Oshl
                  (Ebinop Oand (Ecast (Econst_int (Int.repr 223) tint) tuint)
                    (Ebinop Osub
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 8) tint) tint)
                      (Econst_int (Int.repr 1) tint) tint) tuint)
                  (Econst_int (Int.repr 24) tint) tuint) tuint))
            (Sassign
              (Efield
                (Efield
                  (Ederef (Etempvar __g__1 (tptr (Tunion __549 noattr)))
                    (Tunion __549 noattr)) _words (Tstruct __547 noattr)) _w1
                tuint) (Econst_int (Int.repr 0) tint))))
        (Scall None
          (Evar _create_gfx_task_structure (Tfunction nil tvoid cc_default))
          nil)))))
|}.

Definition f_draw_reset_bars := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_width, tint) :: (_height, tint) :: (_fbNum, tint) ::
               (_fbPtr, (tptr tulong)) :: (_t'3, tint) ::
               (_t'2, (tptr tulong)) :: (_t'1, tschar) :: (_t'8, tschar) ::
               (_t'7, tschar) :: (_t'6, tushort) :: (_t'5, tushort) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gResetTimer tschar))
      (Sifthenelse (Ebinop One (Etempvar _t'7 tschar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'8 (Evar _gNmiResetBarsTimer tschar))
          (Sset _t'3
            (Ecast
              (Ebinop Olt (Etempvar _t'8 tschar)
                (Econst_int (Int.repr 15) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _sRenderedFramebuffer tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _fbNum (Econst_int (Int.repr 2) tint))
            (Ssequence
              (Sset _t'6 (Evar _sRenderedFramebuffer tushort))
              (Sset _fbNum
                (Ebinop Osub (Etempvar _t'6 tushort)
                  (Econst_int (Int.repr 1) tint) tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd (Evar _gPhysicalFramebuffers (tarray tuint 3))
                  (Etempvar _fbNum tint) (tptr tuint)) tuint))
            (Sset _fbPtr
              (Ecast
                (Ebinop Oor (Ecast (Etempvar _t'4 tuint) tuint)
                  (Econst_int (Int.repr (-2147483648)) tuint) tuint)
                (tptr tulong))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'1 (Evar _gNmiResetBarsTimer tschar))
                (Sassign (Evar _gNmiResetBarsTimer tschar)
                  (Ebinop Oadd (Etempvar _t'1 tschar)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Sset _fbPtr
                (Ebinop Oadd (Etempvar _fbPtr (tptr tulong))
                  (Ebinop Omul (Etempvar _t'1 tschar)
                    (Ebinop Odiv (Econst_int (Int.repr 320) tint)
                      (Econst_int (Int.repr 4) tint) tint) tint)
                  (tptr tulong))))
            (Ssequence
              (Sset _width (Econst_int (Int.repr 0) tint))
              (Sloop
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _width tint)
                                 (Ebinop Oadd
                                   (Ebinop Odiv
                                     (Econst_int (Int.repr 240) tint)
                                     (Econst_int (Int.repr 16) tint) tint)
                                   (Econst_int (Int.repr 1) tint) tint) tint)
                    Sskip
                    Sbreak)
                  (Ssequence
                    (Ssequence
                      (Sset _height (Econst_int (Int.repr 0) tint))
                      (Sloop
                        (Ssequence
                          (Sifthenelse (Ebinop Olt (Etempvar _height tint)
                                         (Ebinop Odiv
                                           (Econst_int (Int.repr 320) tint)
                                           (Econst_int (Int.repr 4) tint)
                                           tint) tint)
                            Sskip
                            Sbreak)
                          (Ssequence
                            (Ssequence
                              (Sset _t'2 (Etempvar _fbPtr (tptr tulong)))
                              (Sset _fbPtr
                                (Ebinop Oadd (Etempvar _t'2 (tptr tulong))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tulong))))
                            (Sassign
                              (Ederef (Etempvar _t'2 (tptr tulong)) tulong)
                              (Econst_int (Int.repr 0) tint))))
                        (Sset _height
                          (Ebinop Oadd (Etempvar _height tint)
                            (Econst_int (Int.repr 1) tint) tint))))
                    (Sset _fbPtr
                      (Ebinop Oadd (Etempvar _fbPtr (tptr tulong))
                        (Ebinop Omul
                          (Ebinop Odiv (Econst_int (Int.repr 320) tint)
                            (Econst_int (Int.repr 4) tint) tint)
                          (Econst_int (Int.repr 14) tint) tint)
                        (tptr tulong)))))
                (Sset _width
                  (Ebinop Oadd (Etempvar _width tint)
                    (Econst_int (Int.repr 1) tint) tint)))))))
      Sskip))
  (Ssequence
    (Scall None (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Scall None
        (Evar _osRecvMesg (Tfunction
                            ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                             (tptr (tptr tvoid)) :: tint :: nil) tint
                            cc_default))
        ((Eaddrof (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid)) (tptr (tptr tvoid))) ::
         (Econst_int (Int.repr 1) tint) :: nil))
      (Scall None
        (Evar _osRecvMesg (Tfunction
                            ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                             (tptr (tptr tvoid)) :: tint :: nil) tint
                            cc_default))
        ((Eaddrof (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid)) (tptr (tptr tvoid))) ::
         (Econst_int (Int.repr 1) tint) :: nil)))))
|}.

Definition f_render_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'7, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'6, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'5, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'4, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'3, (tptr (Tstruct _GfxPool noattr))) :: (_t'2, tushort) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr)))
    (Ebinop Oadd (Evar _gGfxPools (tarray (Tstruct _GfxPool noattr) 2))
      (Econst_int (Int.repr 0) tint) (tptr (Tstruct _GfxPool noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
      (Scall None
        (Evar _set_segment_base_addr (Tfunction (tint :: (tptr tvoid) :: nil)
                                       tuint cc_default))
        ((Econst_int (Int.repr 1) tint) ::
         (Efield
           (Ederef (Etempvar _t'7 (tptr (Tstruct _GfxPool noattr)))
             (Tstruct _GfxPool noattr)) _buffer
           (tarray (Tunion __549 noattr) 6400)) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'6 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
        (Sassign (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr)))
          (Eaddrof
            (Efield
              (Ederef (Etempvar _t'6 (tptr (Tstruct _GfxPool noattr)))
                (Tstruct _GfxPool noattr)) _spTask (Tstruct _SPTask noattr))
            (tptr (Tstruct _SPTask noattr)))))
      (Ssequence
        (Ssequence
          (Sset _t'5 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _GfxPool noattr)))
                (Tstruct _GfxPool noattr)) _buffer
              (tarray (Tunion __549 noattr) 6400))))
        (Ssequence
          (Ssequence
            (Sset _t'4 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
            (Sassign (Evar _gGfxPoolEnd (tptr tuchar))
              (Ecast
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _t'4 (tptr (Tstruct _GfxPool noattr)))
                      (Tstruct _GfxPool noattr)) _buffer
                    (tarray (Tunion __549 noattr) 6400))
                  (Econst_int (Int.repr 6400) tint)
                  (tptr (Tunion __549 noattr))) (tptr tuchar))))
          (Ssequence
            (Scall None (Evar _init_rcp (Tfunction nil tvoid cc_default))
              nil)
            (Ssequence
              (Scall None
                (Evar _clear_framebuffer (Tfunction (tint :: nil) tvoid
                                           cc_default))
                ((Econst_int (Int.repr 0) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _end_master_display_list (Tfunction nil tvoid
                                                   cc_default)) nil)
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
                    (Scall None
                      (Evar _exec_display_list (Tfunction
                                                 ((tptr (Tstruct _SPTask noattr)) ::
                                                  nil) tvoid cc_default))
                      ((Eaddrof
                         (Efield
                           (Ederef
                             (Etempvar _t'3 (tptr (Tstruct _GfxPool noattr)))
                             (Tstruct _GfxPool noattr)) _spTask
                           (Tstruct _SPTask noattr))
                         (tptr (Tstruct _SPTask noattr))) :: nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'2 (Evar _sRenderingFramebuffer tushort))
                      (Sassign (Evar _sRenderingFramebuffer tushort)
                        (Ebinop Oadd (Etempvar _t'2 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Ssequence
                      (Sset _t'1 (Evar _gGlobalTimer tuint))
                      (Sassign (Evar _gGlobalTimer tuint)
                        (Ebinop Oadd (Etempvar _t'1 tuint)
                          (Econst_int (Int.repr 1) tint) tuint)))))))))))))
|}.

Definition f_select_gfx_pool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'5, tuint) :: (_t'4, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'3, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'2, (tptr (Tstruct _GfxPool noattr))) ::
               (_t'1, (tptr (Tstruct _GfxPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gGlobalTimer tuint))
    (Sassign (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr)))
      (Ebinop Oadd (Evar _gGfxPools (tarray (Tstruct _GfxPool noattr) 2))
        (Ebinop Omod (Etempvar _t'5 tuint)
          (Ecast
            (Ebinop Odiv (Esizeof (tarray (Tstruct _GfxPool noattr) 2) tuint)
              (Esizeof (Tstruct _GfxPool noattr) tuint) tuint) tint) tuint)
        (tptr (Tstruct _GfxPool noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'4 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
      (Scall None
        (Evar _set_segment_base_addr (Tfunction (tint :: (tptr tvoid) :: nil)
                                       tuint cc_default))
        ((Econst_int (Int.repr 1) tint) ::
         (Efield
           (Ederef (Etempvar _t'4 (tptr (Tstruct _GfxPool noattr)))
             (Tstruct _GfxPool noattr)) _buffer
           (tarray (Tunion __549 noattr) 6400)) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
        (Sassign (Evar _gGfxSPTask (tptr (Tstruct _SPTask noattr)))
          (Eaddrof
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _GfxPool noattr)))
                (Tstruct _GfxPool noattr)) _spTask (Tstruct _SPTask noattr))
            (tptr (Tstruct _SPTask noattr)))))
      (Ssequence
        (Ssequence
          (Sset _t'2 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
          (Sassign (Evar _gDisplayListHead (tptr (Tunion __549 noattr)))
            (Efield
              (Ederef (Etempvar _t'2 (tptr (Tstruct _GfxPool noattr)))
                (Tstruct _GfxPool noattr)) _buffer
              (tarray (Tunion __549 noattr) 6400))))
        (Ssequence
          (Sset _t'1 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
          (Sassign (Evar _gGfxPoolEnd (tptr tuchar))
            (Ecast
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _t'1 (tptr (Tstruct _GfxPool noattr)))
                    (Tstruct _GfxPool noattr)) _buffer
                  (tarray (Tunion __549 noattr) 6400))
                (Econst_int (Int.repr 6400) tint)
                (tptr (Tunion __549 noattr))) (tptr tuchar))))))))
|}.

Definition f_display_and_vsync := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tushort) ::
               (_t'10, (tptr (Tfunction nil tvoid cc_default))) ::
               (_t'9, (tptr (Tfunction nil tvoid cc_default))) ::
               (_t'8, (tptr (Tstruct _GfxPool noattr))) :: (_t'7, tuint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) ::
               (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _profiler_log_thread5_time (Tfunction (tint :: nil) tvoid
                                       cc_default))
    ((Econst_int (Int.repr 2) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _osRecvMesg (Tfunction
                          ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                           (tptr (tptr tvoid)) :: tint :: nil) tint
                          cc_default))
      ((Eaddrof (Evar _gGfxVblankQueue (Tstruct _OSMesgQueue_s noattr))
         (tptr (Tstruct _OSMesgQueue_s noattr))) ::
       (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid)) (tptr (tptr tvoid))) ::
       (Econst_int (Int.repr 1) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Evar _gGoddardVblankCallback (tptr (Tfunction nil tvoid
                                                cc_default))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'9 (tptr (Tfunction nil tvoid cc_default)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Evar _gGoddardVblankCallback (tptr (Tfunction nil tvoid
                                                      cc_default))))
              (Scall None
                (Etempvar _t'10 (tptr (Tfunction nil tvoid cc_default))) nil))
            (Sassign
              (Evar _gGoddardVblankCallback (tptr (Tfunction nil tvoid
                                                    cc_default)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8 (Evar _gGfxPool (tptr (Tstruct _GfxPool noattr))))
          (Scall None
            (Evar _exec_display_list (Tfunction
                                       ((tptr (Tstruct _SPTask noattr)) ::
                                        nil) tvoid cc_default))
            ((Eaddrof
               (Efield
                 (Ederef (Etempvar _t'8 (tptr (Tstruct _GfxPool noattr)))
                   (Tstruct _GfxPool noattr)) _spTask
                 (Tstruct _SPTask noattr)) (tptr (Tstruct _SPTask noattr))) ::
             nil)))
        (Ssequence
          (Scall None
            (Evar _profiler_log_thread5_time (Tfunction (tint :: nil) tvoid
                                               cc_default))
            ((Econst_int (Int.repr 3) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _osRecvMesg (Tfunction
                                  ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                   (tptr (tptr tvoid)) :: tint :: nil) tint
                                  cc_default))
              ((Eaddrof
                 (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
                 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid))
                 (tptr (tptr tvoid))) :: (Econst_int (Int.repr 1) tint) ::
               nil))
            (Ssequence
              (Ssequence
                (Sset _t'6 (Evar _sRenderedFramebuffer tushort))
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gPhysicalFramebuffers (tarray tuint 3))
                        (Etempvar _t'6 tushort) (tptr tuint)) tuint))
                  (Scall None
                    (Evar _osViSwapBuffer (Tfunction ((tptr tvoid) :: nil)
                                            tvoid cc_default))
                    ((Ecast
                       (Ebinop Oor (Ecast (Etempvar _t'7 tuint) tuint)
                         (Econst_int (Int.repr (-2147483648)) tuint) tuint)
                       (tptr tvoid)) :: nil))))
              (Ssequence
                (Scall None
                  (Evar _profiler_log_thread5_time (Tfunction (tint :: nil)
                                                     tvoid cc_default))
                  ((Econst_int (Int.repr 4) tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _osRecvMesg (Tfunction
                                        ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                         (tptr (tptr tvoid)) :: tint :: nil)
                                        tint cc_default))
                    ((Eaddrof
                       (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
                       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                     (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid))
                       (tptr (tptr tvoid))) ::
                     (Econst_int (Int.repr 1) tint) :: nil))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'5 (Evar _sRenderedFramebuffer tushort))
                          (Sset _t'1
                            (Ecast
                              (Ebinop Oadd (Etempvar _t'5 tushort)
                                (Econst_int (Int.repr 1) tint) tint) tushort)))
                        (Sassign (Evar _sRenderedFramebuffer tushort)
                          (Etempvar _t'1 tushort)))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                                     (Econst_int (Int.repr 3) tint) tint)
                        (Sassign (Evar _sRenderedFramebuffer tushort)
                          (Econst_int (Int.repr 0) tint))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'4 (Evar _sRenderingFramebuffer tushort))
                            (Sset _t'2
                              (Ecast
                                (Ebinop Oadd (Etempvar _t'4 tushort)
                                  (Econst_int (Int.repr 1) tint) tint)
                                tushort)))
                          (Sassign (Evar _sRenderingFramebuffer tushort)
                            (Etempvar _t'2 tushort)))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                                       (Econst_int (Int.repr 3) tint) tint)
                          (Sassign (Evar _sRenderingFramebuffer tushort)
                            (Econst_int (Int.repr 0) tint))
                          Sskip))
                      (Ssequence
                        (Sset _t'3 (Evar _gGlobalTimer tuint))
                        (Sassign (Evar _gGlobalTimer tuint)
                          (Ebinop Oadd (Etempvar _t'3 tuint)
                            (Econst_int (Int.repr 1) tint) tuint))))))))))))))
|}.

Definition f_adjust_analog_stick := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_controller, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 8)) :: nil);
  fn_temps := ((_t'1, tfloat) :: (_t'18, tshort) :: (_t'17, tshort) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _controller (tptr (Tstruct _Controller noattr)))
        (Tstruct _Controller noattr)) _stickX tfloat)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _controller (tptr (Tstruct _Controller noattr)))
          (Tstruct _Controller noattr)) _stickY tfloat)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Sset _t'17
          (Efield
            (Ederef
              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _rawStickX tshort))
        (Sifthenelse (Ebinop Ole (Etempvar _t'17 tshort)
                       (Eunop Oneg (Econst_int (Int.repr 8) tint) tint) tint)
          (Ssequence
            (Sset _t'18
              (Efield
                (Ederef
                  (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _rawStickX tshort))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _stickX tfloat)
              (Ebinop Oadd (Etempvar _t'18 tshort)
                (Econst_int (Int.repr 6) tint) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef
                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                (Tstruct _Controller noattr)) _rawStickX tshort))
          (Sifthenelse (Ebinop Oge (Etempvar _t'15 tshort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef
                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _rawStickX tshort))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _stickX tfloat)
                (Ebinop Osub (Etempvar _t'16 tshort)
                  (Econst_int (Int.repr 6) tint) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef
                  (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _rawStickY tshort))
            (Sifthenelse (Ebinop Ole (Etempvar _t'13 tshort)
                           (Eunop Oneg (Econst_int (Int.repr 8) tint) tint)
                           tint)
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _rawStickY tshort))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _stickY tfloat)
                  (Ebinop Oadd (Etempvar _t'14 tshort)
                    (Econst_int (Int.repr 6) tint) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _rawStickY tshort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'11 tshort)
                             (Econst_int (Int.repr 8) tint) tint)
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _rawStickY tshort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickY tfloat)
                    (Ebinop Osub (Etempvar _t'12 tshort)
                      (Econst_int (Int.repr 6) tint) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickX tfloat))
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _stickX tfloat))
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _stickY tfloat))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickY tfloat))
                        (Scall (Some _t'1)
                          (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                         cc_default))
                          ((Ebinop Oadd
                             (Ebinop Omul (Etempvar _t'7 tfloat)
                               (Etempvar _t'8 tfloat) tfloat)
                             (Ebinop Omul (Etempvar _t'9 tfloat)
                               (Etempvar _t'10 tfloat) tfloat) tfloat) ::
                           nil))))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _stickMag tfloat)
                  (Etempvar _t'1 tfloat)))
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _stickMag tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tfloat)
                               (Econst_int (Int.repr 64) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _stickX tfloat))
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickMag tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickX tfloat)
                          (Ebinop Omul (Etempvar _t'5 tfloat)
                            (Ebinop Odiv (Econst_int (Int.repr 64) tint)
                              (Etempvar _t'6 tfloat) tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'3
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickY tfloat))
                        (Ssequence
                          (Sset _t'4
                            (Efield
                              (Ederef
                                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _stickMag
                              tfloat))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _stickY tfloat)
                            (Ebinop Omul (Etempvar _t'3 tfloat)
                              (Ebinop Odiv (Econst_int (Int.repr 64) tint)
                                (Etempvar _t'4 tfloat) tfloat) tfloat))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _stickMag tfloat)
                        (Econst_int (Int.repr 64) tint))))
                  Sskip)))))))))
|}.

Definition f_run_demo_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_startPushed, tushort) :: (_t'1, tuchar) ::
               (_t'34, tushort) :: (_t'33, (tptr (Tstruct __319 noattr))) ::
               (_t'32, (tptr (Tstruct __319 noattr))) ::
               (_t'31, (tptr (Tstruct __319 noattr))) ::
               (_t'30, (tptr (Tstruct __319 noattr))) ::
               (_t'29, (tptr (Tstruct __319 noattr))) ::
               (_t'28, (tptr (Tstruct __319 noattr))) ::
               (_t'27, (tptr (Tstruct __319 noattr))) ::
               (_t'26, (tptr (Tstruct __319 noattr))) ::
               (_t'25, (tptr (Tstruct __319 noattr))) :: (_t'24, tushort) ::
               (_t'23, (tptr (Tstruct __319 noattr))) :: (_t'22, tschar) ::
               (_t'21, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'20, (tptr (Tstruct __319 noattr))) :: (_t'19, tschar) ::
               (_t'18, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'17, (tptr (Tstruct __319 noattr))) :: (_t'16, tuchar) ::
               (_t'15, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'12, (tptr (Tstruct __319 noattr))) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct __319 noattr))) ::
               (_t'9, (tptr (Tstruct __319 noattr))) :: (_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'6, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'5, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _DemoInput noattr))) ::
               (_t'2, (tptr (Tstruct _DemoInput noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'32
      (Efield
        (Ederef
          (Ebinop Oadd
            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
            (Econst_int (Int.repr 0) tint)
            (tptr (Tstruct _Controller noattr)))
          (Tstruct _Controller noattr)) _controllerData
        (tptr (Tstruct __319 noattr))))
    (Ssequence
      (Sset _t'33
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _controllerData
          (tptr (Tstruct __319 noattr))))
      (Ssequence
        (Sset _t'34
          (Efield
            (Ederef (Etempvar _t'33 (tptr (Tstruct __319 noattr)))
              (Tstruct __319 noattr)) _button tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'32 (tptr (Tstruct __319 noattr)))
              (Tstruct __319 noattr)) _button tushort)
          (Ebinop Oand (Etempvar _t'34 tushort)
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor
                            (Ebinop Oor
                              (Ebinop Oor
                                (Ebinop Oor
                                  (Ebinop Oor
                                    (Ebinop Oor
                                      (Econst_int (Int.repr 32768) tint)
                                      (Econst_int (Int.repr 16384) tint)
                                      tint) (Econst_int (Int.repr 8192) tint)
                                    tint) (Econst_int (Int.repr 4096) tint)
                                  tint) (Econst_int (Int.repr 2048) tint)
                                tint) (Econst_int (Int.repr 1024) tint) tint)
                            (Econst_int (Int.repr 512) tint) tint)
                          (Econst_int (Int.repr 256) tint) tint)
                        (Econst_int (Int.repr 32) tint) tint)
                      (Econst_int (Int.repr 16) tint) tint)
                    (Econst_int (Int.repr 8) tint) tint)
                  (Econst_int (Int.repr 4) tint) tint)
                (Econst_int (Int.repr 2) tint) tint)
              (Econst_int (Int.repr 1) tint) tint) tint)))))
  (Ssequence
    (Sset _t'2 (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'2 (tptr (Tstruct _DemoInput noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Ssequence
          (Sset _t'28
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                  (Econst_int (Int.repr 1) tint)
                  (tptr (Tstruct _Controller noattr)))
                (Tstruct _Controller noattr)) _controllerData
              (tptr (Tstruct __319 noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'28 (tptr (Tstruct __319 noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'31
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                        (Econst_int (Int.repr 1) tint)
                        (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _controllerData
                    (tptr (Tstruct __319 noattr))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _t'31 (tptr (Tstruct __319 noattr)))
                      (Tstruct __319 noattr)) _stick_x tschar)
                  (Econst_int (Int.repr 0) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'30
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _controllerData
                      (tptr (Tstruct __319 noattr))))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _t'30 (tptr (Tstruct __319 noattr)))
                        (Tstruct __319 noattr)) _stick_y tschar)
                    (Econst_int (Int.repr 0) tint)))
                (Ssequence
                  (Sset _t'29
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                          (Econst_int (Int.repr 1) tint)
                          (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _controllerData
                      (tptr (Tstruct __319 noattr))))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _t'29 (tptr (Tstruct __319 noattr)))
                        (Tstruct __319 noattr)) _button tushort)
                    (Econst_int (Int.repr 0) tint)))))
            Sskip))
        (Ssequence
          (Sset _t'3
            (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _DemoInput noattr)))
                  (Tstruct _DemoInput noattr)) _timer tuchar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuchar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'27
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _controllerData
                      (tptr (Tstruct __319 noattr))))
                  (Sassign
                    (Efield
                      (Ederef (Etempvar _t'27 (tptr (Tstruct __319 noattr)))
                        (Tstruct __319 noattr)) _stick_x tschar)
                    (Econst_int (Int.repr 0) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'26
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                            (Econst_int (Int.repr 0) tint)
                            (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _controllerData
                        (tptr (Tstruct __319 noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'26 (tptr (Tstruct __319 noattr)))
                          (Tstruct __319 noattr)) _stick_y tschar)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Sset _t'25
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                            (Econst_int (Int.repr 0) tint)
                            (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _controllerData
                        (tptr (Tstruct __319 noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'25 (tptr (Tstruct __319 noattr)))
                          (Tstruct __319 noattr)) _button tushort)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 7) tint) tint)))))
              (Ssequence
                (Ssequence
                  (Sset _t'23
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _controllerData
                      (tptr (Tstruct __319 noattr))))
                  (Ssequence
                    (Sset _t'24
                      (Efield
                        (Ederef
                          (Etempvar _t'23 (tptr (Tstruct __319 noattr)))
                          (Tstruct __319 noattr)) _button tushort))
                    (Sset _startPushed
                      (Ecast
                        (Ebinop Oand (Etempvar _t'24 tushort)
                          (Econst_int (Int.repr 4096) tint) tint) tushort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                            (Econst_int (Int.repr 0) tint)
                            (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _controllerData
                        (tptr (Tstruct __319 noattr))))
                    (Ssequence
                      (Sset _t'21
                        (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                      (Ssequence
                        (Sset _t'22
                          (Efield
                            (Ederef
                              (Etempvar _t'21 (tptr (Tstruct _DemoInput noattr)))
                              (Tstruct _DemoInput noattr)) _rawStickX tschar))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'20 (tptr (Tstruct __319 noattr)))
                              (Tstruct __319 noattr)) _stick_x tschar)
                          (Etempvar _t'22 tschar)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'17
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                              (Econst_int (Int.repr 0) tint)
                              (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _controllerData
                          (tptr (Tstruct __319 noattr))))
                      (Ssequence
                        (Sset _t'18
                          (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                        (Ssequence
                          (Sset _t'19
                            (Efield
                              (Ederef
                                (Etempvar _t'18 (tptr (Tstruct _DemoInput noattr)))
                                (Tstruct _DemoInput noattr)) _rawStickY
                              tschar))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'17 (tptr (Tstruct __319 noattr)))
                                (Tstruct __319 noattr)) _stick_y tschar)
                            (Etempvar _t'19 tschar)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                                (Econst_int (Int.repr 0) tint)
                                (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _controllerData
                            (tptr (Tstruct __319 noattr))))
                        (Ssequence
                          (Sset _t'13
                            (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                          (Ssequence
                            (Sset _t'14
                              (Efield
                                (Ederef
                                  (Etempvar _t'13 (tptr (Tstruct _DemoInput noattr)))
                                  (Tstruct _DemoInput noattr)) _buttonMask
                                tuchar))
                            (Ssequence
                              (Sset _t'15
                                (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                              (Ssequence
                                (Sset _t'16
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'15 (tptr (Tstruct _DemoInput noattr)))
                                      (Tstruct _DemoInput noattr))
                                    _buttonMask tuchar))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'12 (tptr (Tstruct __319 noattr)))
                                      (Tstruct __319 noattr)) _button
                                    tushort)
                                  (Ebinop Oadd
                                    (Ebinop Oshl
                                      (Ebinop Oand (Etempvar _t'14 tuchar)
                                        (Econst_int (Int.repr 240) tint)
                                        tint) (Econst_int (Int.repr 8) tint)
                                      tint)
                                    (Ebinop Oand (Etempvar _t'16 tuchar)
                                      (Econst_int (Int.repr 15) tint) tint)
                                    tint)))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _controllerData
                              (tptr (Tstruct __319 noattr))))
                          (Ssequence
                            (Sset _t'10
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr))
                                _controllerData
                                (tptr (Tstruct __319 noattr))))
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _t'10 (tptr (Tstruct __319 noattr)))
                                    (Tstruct __319 noattr)) _button tushort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _t'9 (tptr (Tstruct __319 noattr)))
                                    (Tstruct __319 noattr)) _button tushort)
                                (Ebinop Oor (Etempvar _t'11 tushort)
                                  (Etempvar _startPushed tushort) tint)))))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
                                (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                              (Ssequence
                                (Sset _t'8
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _DemoInput noattr)))
                                      (Tstruct _DemoInput noattr)) _timer
                                    tuchar))
                                (Sset _t'1
                                  (Ecast
                                    (Ebinop Osub (Etempvar _t'8 tuchar)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuchar))))
                            (Ssequence
                              (Sset _t'6
                                (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _t'6 (tptr (Tstruct _DemoInput noattr)))
                                    (Tstruct _DemoInput noattr)) _timer
                                  tuchar) (Etempvar _t'1 tuchar))))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuchar)
                                         (Econst_int (Int.repr 0) tint) tint)
                            (Ssequence
                              (Sset _t'5
                                (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr))))
                              (Sassign
                                (Evar _gCurrDemoInput (tptr (Tstruct _DemoInput noattr)))
                                (Ebinop Oadd
                                  (Etempvar _t'5 (tptr (Tstruct _DemoInput noattr)))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr (Tstruct _DemoInput noattr)))))
                            Sskip)))))))))))
      Sskip)))
|}.

Definition f_read_controller_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tint) ::
               (_controller, (tptr (Tstruct _Controller noattr))) ::
               (_t'34, tuchar) :: (_t'33, tschar) ::
               (_t'32, (tptr (Tstruct __319 noattr))) :: (_t'31, tschar) ::
               (_t'30, (tptr (Tstruct __319 noattr))) :: (_t'29, tushort) ::
               (_t'28, tushort) :: (_t'27, (tptr (Tstruct __319 noattr))) ::
               (_t'26, tushort) :: (_t'25, (tptr (Tstruct __319 noattr))) ::
               (_t'24, tushort) :: (_t'23, (tptr (Tstruct __319 noattr))) ::
               (_t'22, (tptr (Tstruct __319 noattr))) :: (_t'21, tshort) ::
               (_t'20, (tptr (Tstruct _Controller noattr))) ::
               (_t'19, (tptr (Tstruct _Controller noattr))) ::
               (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Controller noattr))) ::
               (_t'16, (tptr (Tstruct _Controller noattr))) ::
               (_t'15, tfloat) ::
               (_t'14, (tptr (Tstruct _Controller noattr))) ::
               (_t'13, (tptr (Tstruct _Controller noattr))) ::
               (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Controller noattr))) ::
               (_t'10, (tptr (Tstruct _Controller noattr))) ::
               (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Controller noattr))) ::
               (_t'7, (tptr (Tstruct _Controller noattr))) ::
               (_t'6, tushort) ::
               (_t'5, (tptr (Tstruct _Controller noattr))) ::
               (_t'4, (tptr (Tstruct _Controller noattr))) ::
               (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Controller noattr))) ::
               (_t'1, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'34 (Evar _gControllerBits tuchar))
    (Sifthenelse (Etempvar _t'34 tuchar)
      (Ssequence
        (Scall None
          (Evar _osRecvMesg (Tfunction
                              ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                               (tptr (tptr tvoid)) :: tint :: nil) tint
                              cc_default))
          ((Eaddrof (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Eaddrof (Evar _gMainReceivedMesg (tptr tvoid))
             (tptr (tptr tvoid))) :: (Econst_int (Int.repr 1) tint) :: nil))
        (Scall None
          (Evar _osContGetReadData (Tfunction
                                     ((tptr (Tstruct __319 noattr)) :: nil)
                                     tvoid cc_default))
          ((Ebinop Oadd
             (Evar _gControllerPads (tarray (Tstruct __319 noattr) 4))
             (Econst_int (Int.repr 0) tint) (tptr (Tstruct __319 noattr))) ::
           nil)))
      Sskip))
  (Ssequence
    (Scall None (Evar _run_demo_inputs (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Ssequence
        (Sset _i (Econst_int (Int.repr 0) tint))
        (Sloop
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                           (Econst_int (Int.repr 2) tint) tint)
              Sskip
              Sbreak)
            (Ssequence
              (Sset _controller
                (Ebinop Oadd
                  (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                  (Etempvar _i tint) (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'22
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _controllerData
                    (tptr (Tstruct __319 noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'22 (tptr (Tstruct __319 noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'32
                        (Efield
                          (Ederef
                            (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _controllerData
                          (tptr (Tstruct __319 noattr))))
                      (Ssequence
                        (Sset _t'33
                          (Efield
                            (Ederef
                              (Etempvar _t'32 (tptr (Tstruct __319 noattr)))
                              (Tstruct __319 noattr)) _stick_x tschar))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _rawStickX
                            tshort) (Etempvar _t'33 tschar))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'30
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _controllerData
                            (tptr (Tstruct __319 noattr))))
                        (Ssequence
                          (Sset _t'31
                            (Efield
                              (Ederef
                                (Etempvar _t'30 (tptr (Tstruct __319 noattr)))
                                (Tstruct __319 noattr)) _stick_y tschar))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _rawStickY
                              tshort) (Etempvar _t'31 tschar))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'25
                            (Efield
                              (Ederef
                                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _controllerData
                              (tptr (Tstruct __319 noattr))))
                          (Ssequence
                            (Sset _t'26
                              (Efield
                                (Ederef
                                  (Etempvar _t'25 (tptr (Tstruct __319 noattr)))
                                  (Tstruct __319 noattr)) _button tushort))
                            (Ssequence
                              (Sset _t'27
                                (Efield
                                  (Ederef
                                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                    (Tstruct _Controller noattr))
                                  _controllerData
                                  (tptr (Tstruct __319 noattr))))
                              (Ssequence
                                (Sset _t'28
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'27 (tptr (Tstruct __319 noattr)))
                                      (Tstruct __319 noattr)) _button
                                    tushort))
                                (Ssequence
                                  (Sset _t'29
                                    (Efield
                                      (Ederef
                                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                        (Tstruct _Controller noattr))
                                      _buttonDown tushort))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                        (Tstruct _Controller noattr))
                                      _buttonPressed tushort)
                                    (Ebinop Oand (Etempvar _t'26 tushort)
                                      (Ebinop Oxor (Etempvar _t'28 tushort)
                                        (Etempvar _t'29 tushort) tint) tint)))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'23
                              (Efield
                                (Ederef
                                  (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr))
                                _controllerData
                                (tptr (Tstruct __319 noattr))))
                            (Ssequence
                              (Sset _t'24
                                (Efield
                                  (Ederef
                                    (Etempvar _t'23 (tptr (Tstruct __319 noattr)))
                                    (Tstruct __319 noattr)) _button tushort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                    (Tstruct _Controller noattr)) _buttonDown
                                  tushort) (Etempvar _t'24 tushort))))
                          (Scall None
                            (Evar _adjust_analog_stick (Tfunction
                                                         ((tptr (Tstruct _Controller noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                            ((Etempvar _controller (tptr (Tstruct _Controller noattr))) ::
                             nil))))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _rawStickX tshort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _rawStickY tshort)
                        (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonPressed
                            tushort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _buttonDown
                              tushort) (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr)) _stickX
                                tfloat) (Econst_int (Int.repr 0) tint))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                    (Tstruct _Controller noattr)) _stickY
                                  tfloat) (Econst_int (Int.repr 0) tint))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                                    (Tstruct _Controller noattr)) _stickMag
                                  tfloat) (Econst_int (Int.repr 0) tint))))))))))))
          (Sset _i
            (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
              tint))))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'20
              (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef
                    (Etempvar _t'20 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _rawStickX tshort))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'19 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _rawStickX tshort)
                (Etempvar _t'21 tshort)))))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'17
                (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef
                      (Etempvar _t'17 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _rawStickY tshort))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'16 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _rawStickY tshort)
                  (Etempvar _t'18 tshort)))))
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'14
                  (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _t'14 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickX tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'13 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickX tfloat)
                    (Etempvar _t'15 tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'11
                    (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Ederef
                          (Etempvar _t'11 (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _stickY tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'10 (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _stickY tfloat)
                      (Etempvar _t'12 tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
                  (Ssequence
                    (Sset _t'8
                      (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _t'8 (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _stickMag tfloat))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _stickMag tfloat)
                        (Etempvar _t'9 tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
                    (Ssequence
                      (Sset _t'5
                        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonPressed
                            tushort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'4 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonPressed
                            tushort) (Etempvar _t'6 tushort)))))
                  (Ssequence
                    (Sset _t'1
                      (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
                    (Ssequence
                      (Sset _t'2
                        (Evar _gPlayer1Controller (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'3
                          (Efield
                            (Ederef
                              (Etempvar _t'2 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonDown
                            tushort))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'1 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _buttonDown
                            tushort) (Etempvar _t'3 tushort))))))))))))))
|}.

Definition f_init_controllers := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_port, tshort) :: (_cont, tshort) :: (_t'3, tshort) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'4, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef
        (Ebinop Oadd
          (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
          (Econst_int (Int.repr 0) tint) (tptr (Tstruct _Controller noattr)))
        (Tstruct _Controller noattr)) _statusData
      (tptr (Tstruct __317 noattr)))
    (Ebinop Oadd
      (Evar _gControllerStatuses (tarray (Tstruct __317 noattr) 4))
      (Econst_int (Int.repr 0) tint) (tptr (Tstruct __317 noattr))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef
          (Ebinop Oadd
            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
            (Econst_int (Int.repr 0) tint)
            (tptr (Tstruct _Controller noattr)))
          (Tstruct _Controller noattr)) _controllerData
        (tptr (Tstruct __319 noattr)))
      (Ebinop Oadd (Evar _gControllerPads (tarray (Tstruct __319 noattr) 4))
        (Econst_int (Int.repr 0) tint) (tptr (Tstruct __319 noattr))))
    (Ssequence
      (Scall None
        (Evar _osContInit (Tfunction
                            ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                             (tptr tuchar) ::
                             (tptr (Tstruct __317 noattr)) :: nil) tint
                            cc_default))
        ((Eaddrof (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Eaddrof (Evar _gControllerBits tuchar) (tptr tuchar)) ::
         (Ebinop Oadd
           (Evar _gControllerStatuses (tarray (Tstruct __317 noattr) 4))
           (Econst_int (Int.repr 0) tint) (tptr (Tstruct __317 noattr))) ::
         nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _osEepromProbe (Tfunction
                                   ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                    nil) tint cc_default))
            ((Eaddrof
               (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
               (tptr (Tstruct _OSMesgQueue_s noattr))) :: nil))
          (Sassign (Evar _gEepromProbe tschar) (Etempvar _t'1 tint)))
        (Ssequence
          (Ssequence
            (Sset _cont (Ecast (Econst_int (Int.repr 0) tint) tshort))
            (Sset _port (Ecast (Econst_int (Int.repr 0) tint) tshort)))
          (Sloop
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _port tshort)
                               (Econst_int (Int.repr 4) tint) tint)
                  (Sset _t'2
                    (Ecast
                      (Ebinop Olt (Etempvar _cont tshort)
                        (Econst_int (Int.repr 2) tint) tint) tbool))
                  (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'2 tint) Sskip Sbreak))
              (Ssequence
                (Sset _t'4 (Evar _gControllerBits tuchar))
                (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuchar)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Etempvar _port tshort) tint) tint)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                            (Etempvar _cont tshort)
                            (tptr (Tstruct _Controller noattr)))
                          (Tstruct _Controller noattr)) _statusData
                        (tptr (Tstruct __317 noattr)))
                      (Ebinop Oadd
                        (Evar _gControllerStatuses (tarray (Tstruct __317 noattr) 4))
                        (Etempvar _port tshort)
                        (tptr (Tstruct __317 noattr))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'3 (Etempvar _cont tshort))
                        (Sset _cont
                          (Ecast
                            (Ebinop Oadd (Etempvar _t'3 tshort)
                              (Econst_int (Int.repr 1) tint) tint) tshort)))
                      (Sassign
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                              (Etempvar _t'3 tshort)
                              (tptr (Tstruct _Controller noattr)))
                            (Tstruct _Controller noattr)) _controllerData
                          (tptr (Tstruct __319 noattr)))
                        (Ebinop Oadd
                          (Evar _gControllerPads (tarray (Tstruct __319 noattr) 4))
                          (Etempvar _port tshort)
                          (tptr (Tstruct __319 noattr))))))
                  Sskip)))
            (Sset _port
              (Ecast
                (Ebinop Oadd (Etempvar _port tshort)
                  (Econst_int (Int.repr 1) tint) tint) tshort))))))))
|}.

Definition f_setup_game_memory := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 8)) :: nil);
  fn_temps := ((_t'2, (tptr tvoid)) :: (_t'1, (tptr tvoid)) ::
               (_t'6, (tptr tvoid)) :: (_t'5, (tptr tvoid)) ::
               (_t'4, (tptr tvoid)) :: (_t'3, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_segment_base_addr (Tfunction (tint :: (tptr tvoid) :: nil)
                                   tuint cc_default))
    ((Econst_int (Int.repr 0) tint) ::
     (Ecast (Econst_int (Int.repr (-2147483648)) tuint) (tptr tvoid)) :: nil))
  (Ssequence
    (Scall None
      (Evar _osCreateMesgQueue (Tfunction
                                 ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                  (tptr (tptr tvoid)) :: tint :: nil) tvoid
                                 cc_default))
      ((Eaddrof (Evar _gGfxVblankQueue (Tstruct _OSMesgQueue_s noattr))
         (tptr (Tstruct _OSMesgQueue_s noattr))) ::
       (Evar _gGfxMesgBuf (tarray (tptr tvoid) 1)) ::
       (Ecast
         (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 1) tuint)
           (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _osCreateMesgQueue (Tfunction
                                   ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                    (tptr (tptr tvoid)) :: tint :: nil) tvoid
                                   cc_default))
        ((Eaddrof (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Evar _gGameMesgBuf (tarray (tptr tvoid) 1)) ::
         (Ecast
           (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 1) tuint)
             (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
      (Ssequence
        (Sassign (Evar _gPhysicalZBuffer tuint)
          (Ebinop Oand (Ecast (Evar _gZBuffer (tarray tushort 76800)) tuint)
            (Econst_int (Int.repr 536870911) tint) tuint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _gPhysicalFramebuffers (tarray tuint 3))
                (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint)
            (Ebinop Oand
              (Ecast
                (Ederef
                  (Ebinop Oadd
                    (Evar _gFramebuffers (tarray (tarray tushort 76800) 3))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (tarray tushort 76800))) (tarray tushort 76800))
                tuint) (Econst_int (Int.repr 536870911) tint) tuint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _gPhysicalFramebuffers (tarray tuint 3))
                  (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint)
              (Ebinop Oand
                (Ecast
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gFramebuffers (tarray (tarray tushort 76800) 3))
                      (Econst_int (Int.repr 1) tint)
                      (tptr (tarray tushort 76800))) (tarray tushort 76800))
                  tuint) (Econst_int (Int.repr 536870911) tint) tuint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _gPhysicalFramebuffers (tarray tuint 3))
                    (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint)
                (Ebinop Oand
                  (Ecast
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gFramebuffers (tarray (tarray tushort 76800) 3))
                        (Econst_int (Int.repr 2) tint)
                        (tptr (tarray tushort 76800)))
                      (tarray tushort 76800)) tuint)
                  (Econst_int (Int.repr 536870911) tint) tuint))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _main_pool_alloc (Tfunction (tuint :: tuint :: nil)
                                             (tptr tvoid) cc_default))
                    ((Econst_int (Int.repr 16384) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sassign (Evar _gMarioAnimsMemAlloc (tptr tvoid))
                    (Etempvar _t'1 (tptr tvoid))))
                (Ssequence
                  (Ssequence
                    (Sset _t'6 (Evar _gMarioAnimsMemAlloc (tptr tvoid)))
                    (Scall None
                      (Evar _set_segment_base_addr (Tfunction
                                                     (tint :: (tptr tvoid) ::
                                                      nil) tuint cc_default))
                      ((Econst_int (Int.repr 17) tint) ::
                       (Ecast (Etempvar _t'6 (tptr tvoid)) (tptr tvoid)) ::
                       nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'5 (Evar _gMarioAnimsMemAlloc (tptr tvoid)))
                      (Scall None
                        (Evar _setup_dma_table_list (Tfunction
                                                      ((tptr (Tstruct _DmaHandlerList noattr)) ::
                                                       (tptr tvoid) ::
                                                       (tptr tvoid) :: nil)
                                                      tvoid cc_default))
                        ((Eaddrof
                           (Evar _gMarioAnimsBuf (Tstruct _DmaHandlerList noattr))
                           (tptr (Tstruct _DmaHandlerList noattr))) ::
                         (Evar _gMarioAnims (tarray tuchar 0)) ::
                         (Etempvar _t'5 (tptr tvoid)) :: nil)))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _main_pool_alloc (Tfunction
                                                   (tuint :: tuint :: nil)
                                                   (tptr tvoid) cc_default))
                          ((Econst_int (Int.repr 2048) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sassign (Evar _gDemoInputsMemAlloc (tptr tvoid))
                          (Etempvar _t'2 (tptr tvoid))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'4
                            (Evar _gDemoInputsMemAlloc (tptr tvoid)))
                          (Scall None
                            (Evar _set_segment_base_addr (Tfunction
                                                           (tint ::
                                                            (tptr tvoid) ::
                                                            nil) tuint
                                                           cc_default))
                            ((Econst_int (Int.repr 24) tint) ::
                             (Ecast (Etempvar _t'4 (tptr tvoid))
                               (tptr tvoid)) :: nil)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Evar _gDemoInputsMemAlloc (tptr tvoid)))
                            (Scall None
                              (Evar _setup_dma_table_list (Tfunction
                                                            ((tptr (Tstruct _DmaHandlerList noattr)) ::
                                                             (tptr tvoid) ::
                                                             (tptr tvoid) ::
                                                             nil) tvoid
                                                            cc_default))
                              ((Eaddrof
                                 (Evar _gDemoInputsBuf (Tstruct _DmaHandlerList noattr))
                                 (tptr (Tstruct _DmaHandlerList noattr))) ::
                               (Evar _gDemoInputs (tarray tuchar 0)) ::
                               (Etempvar _t'3 (tptr tvoid)) :: nil)))
                          (Ssequence
                            (Scall None
                              (Evar _load_segment (Tfunction
                                                    (tint :: (tptr tuchar) ::
                                                     (tptr tuchar) ::
                                                     tuint :: nil)
                                                    (tptr tvoid) cc_default))
                              ((Econst_int (Int.repr 16) tint) ::
                               (Evar __entrySegmentRomStart (tarray tuchar 0)) ::
                               (Evar __entrySegmentRomEnd (tarray tuchar 0)) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Scall None
                              (Evar _load_segment_decompress (Tfunction
                                                               (tint ::
                                                                (tptr tuchar) ::
                                                                (tptr tuchar) ::
                                                                nil)
                                                               (tptr tvoid)
                                                               cc_default))
                              ((Econst_int (Int.repr 2) tint) ::
                               (Evar __segment2_mio0SegmentRomStart (tarray tuchar 0)) ::
                               (Evar __segment2_mio0SegmentRomEnd (tarray tuchar 0)) ::
                               nil))))))))))))))))
|}.

Definition f_thread5_game_loop := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_addr, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'3, (tptr (Tstruct _LevelCommand noattr))) ::
               (_t'2, tushort) :: (_t'1, (tptr tvoid)) :: (_t'8, tschar) ::
               (_t'7, tuchar) :: (_t'6, (tptr (Tunion __549 noattr))) ::
               (_t'5, (tptr tuchar)) :: (_t'4, tschar) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _setup_game_memory (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None (Evar _init_controllers (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Scall None (Evar _save_file_load_all (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Scall None
          (Evar _set_vblank_handler (Tfunction
                                      (tint ::
                                       (tptr (Tstruct _VblankHandler noattr)) ::
                                       (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                       (tptr (tptr tvoid)) :: nil) tvoid
                                      cc_default))
          ((Econst_int (Int.repr 2) tint) ::
           (Eaddrof
             (Evar _gGameVblankHandler (Tstruct _VblankHandler noattr))
             (tptr (Tstruct _VblankHandler noattr))) ::
           (Eaddrof (Evar _gGameVblankQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Ecast (Econst_int (Int.repr 1) tint) (tptr tvoid)) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Evar _level_script_entry (tarray tuchar 0)) :: nil))
            (Sset _addr (Etempvar _t'1 (tptr tvoid))))
          (Ssequence
            (Scall None
              (Evar _play_music (Tfunction
                                  (tuchar :: tushort :: tushort :: nil) tvoid
                                  cc_default))
              ((Econst_int (Int.repr 2) tint) ::
               (Ebinop Oor
                 (Ebinop Oshl (Econst_int (Int.repr 0) tint)
                   (Econst_int (Int.repr 8) tint) tint)
                 (Econst_int (Int.repr 0) tint) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _save_file_get_sound_mode (Tfunction nil tushort
                                                    cc_default)) nil)
                (Scall None
                  (Evar _set_sound_mode (Tfunction (tushort :: nil) tvoid
                                          cc_default))
                  ((Etempvar _t'2 tushort) :: nil)))
              (Ssequence
                (Scall None
                  (Evar _render_init (Tfunction nil tvoid cc_default)) nil)
                (Sloop
                  (Ssequence
                    Sskip
                    (Ssequence
                      (Ssequence
                        (Sset _t'8 (Evar _gResetTimer tschar))
                        (Sifthenelse (Ebinop One (Etempvar _t'8 tschar)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Ssequence
                            (Scall None
                              (Evar _draw_reset_bars (Tfunction nil tvoid
                                                       cc_default)) nil)
                            Scontinue)
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _profiler_log_thread5_time (Tfunction
                                                             (tint :: nil)
                                                             tvoid
                                                             cc_default))
                          ((Econst_int (Int.repr 0) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'7 (Evar _gControllerBits tuchar))
                            (Sifthenelse (Etempvar _t'7 tuchar)
                              (Scall None
                                (Evar _osContStartReadData (Tfunction
                                                             ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                                              nil) tint
                                                             cc_default))
                                ((Eaddrof
                                   (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
                                   (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                                 nil))
                              Sskip))
                          (Ssequence
                            (Scall None
                              (Evar _audio_game_loop_tick (Tfunction nil
                                                            tvoid cc_default))
                              nil)
                            (Ssequence
                              (Scall None
                                (Evar _select_gfx_pool (Tfunction nil tvoid
                                                         cc_default)) nil)
                              (Ssequence
                                (Scall None
                                  (Evar _read_controller_inputs (Tfunction
                                                                  nil tvoid
                                                                  cc_default))
                                  nil)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'3)
                                      (Evar _level_script_execute (Tfunction
                                                                    ((tptr (Tstruct _LevelCommand noattr)) ::
                                                                    nil)
                                                                    (tptr (Tstruct _LevelCommand noattr))
                                                                    cc_default))
                                      ((Etempvar _addr (tptr (Tstruct _LevelCommand noattr))) ::
                                       nil))
                                    (Sset _addr
                                      (Etempvar _t'3 (tptr (Tstruct _LevelCommand noattr)))))
                                  (Ssequence
                                    (Scall None
                                      (Evar _display_and_vsync (Tfunction nil
                                                                 tvoid
                                                                 cc_default))
                                      nil)
                                    (Ssequence
                                      (Sset _t'4
                                        (Evar _gShowDebugText tschar))
                                      (Sifthenelse (Etempvar _t'4 tschar)
                                        (Ssequence
                                          (Sset _t'5
                                            (Evar _gGfxPoolEnd (tptr tuchar)))
                                          (Ssequence
                                            (Sset _t'6
                                              (Evar _gDisplayListHead (tptr (Tunion __549 noattr))))
                                            (Scall None
                                              (Evar _print_text_fmt_int
                                              (Tfunction
                                                (tint :: tint ::
                                                 (tptr tuchar) :: tint ::
                                                 nil) tvoid cc_default))
                                              ((Econst_int (Int.repr 180) tint) ::
                                               (Econst_int (Int.repr 20) tint) ::
                                               (Evar ___stringlit_1 (tarray tuchar 7)) ::
                                               (Ebinop Osub
                                                 (Etempvar _t'5 (tptr tuchar))
                                                 (Ecast
                                                   (Etempvar _t'6 (tptr (Tunion __549 noattr)))
                                                   (tptr tuchar)) tint) ::
                                               nil))))
                                        Sskip)))))))))))
                  Sskip)))))))))
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
 Composite __317 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __319 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __356 Struct
   (Member_plain _type tuint :: Member_plain _flags tuint ::
    Member_plain _ucode_boot (tptr tulong) ::
    Member_plain _ucode_boot_size tuint ::
    Member_plain _ucode (tptr tulong) :: Member_plain _ucode_size tuint ::
    Member_plain _ucode_data (tptr tulong) ::
    Member_plain _ucode_data_size tuint ::
    Member_plain _dram_stack (tptr tulong) ::
    Member_plain _dram_stack_size tuint ::
    Member_plain _output_buff (tptr tulong) ::
    Member_plain _output_buff_size (tptr tulong) ::
    Member_plain _data_ptr (tptr tulong) :: Member_plain _data_size tuint ::
    Member_plain _yield_data_ptr (tptr tulong) ::
    Member_plain _yield_data_size tuint :: nil)
   noattr ::
 Composite __358 Union
   (Member_plain _t (Tstruct __356 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __469 Struct
   (Member_plain _flag tuchar :: Member_plain _v (tarray tuchar 3) :: nil)
   noattr ::
 Composite __474 Struct
   (Member_plain _vscale (tarray tshort 4) ::
    Member_plain _vtrans (tarray tshort 4) :: nil)
   noattr ::
 Composite __476 Union
   (Member_plain _vp (Tstruct __474 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite __510 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _par I32 Unsigned noattr 8 false ::
    Member_bitfield _len I32 Unsigned noattr 16 false ::
    Member_plain _addr tuint :: nil)
   noattr ::
 Composite __512 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _tri (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __514 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_bitfield _pad2 I32 Signed noattr 24 false ::
    Member_bitfield _param I8 Unsigned noattr 8 false :: nil)
   noattr ::
 Composite __516 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _mw_index I32 Signed noattr 8 false ::
    Member_bitfield _number I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 8 false ::
    Member_bitfield _base I32 Signed noattr 24 false :: nil)
   noattr ::
 Composite __518 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __520 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad0 I32 Signed noattr 8 false ::
    Member_bitfield _sft I32 Signed noattr 8 false ::
    Member_bitfield _len I32 Signed noattr 8 false ::
    Member_bitfield _data I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __522 Struct
   (Member_plain _cmd tuchar :: Member_plain _lodscale tuchar ::
    Member_plain _tile tuchar :: Member_plain _on tuchar ::
    Member_plain _s tushort :: Member_plain _t tushort :: nil)
   noattr ::
 Composite __524 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad I32 Signed noattr 24 false ::
    Member_plain _line (Tstruct __469 noattr) :: nil)
   noattr ::
 Composite __526 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _pad1 I32 Signed noattr 24 false ::
    Member_plain _pad2 tshort :: Member_plain _scale tshort :: nil)
   noattr ::
 Composite __528 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 7 false ::
    Member_bitfield _wd I32 Unsigned noattr 12 false ::
    Member_plain _dram tuint :: nil)
   noattr ::
 Composite __530 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _muxs0 I32 Unsigned noattr 24 false ::
    Member_bitfield _muxs1 I32 Unsigned noattr 32 false :: nil)
   noattr ::
 Composite __532 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_plain _pad tuchar :: Member_plain _prim_min_level tuchar ::
    Member_plain _prim_level tuchar :: Member_plain _color tuint :: nil)
   noattr ::
 Composite __534 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _x0 I32 Signed noattr 10 false ::
    Member_bitfield _x0frac I32 Signed noattr 2 false ::
    Member_bitfield _y0 I32 Signed noattr 10 false ::
    Member_bitfield _y0frac I32 Signed noattr 2 false ::
    Member_bitfield _pad I32 Unsigned noattr 8 false ::
    Member_bitfield _x1 I32 Signed noattr 10 false ::
    Member_bitfield _x1frac I32 Signed noattr 2 false ::
    Member_bitfield _y1 I32 Signed noattr 10 false ::
    Member_bitfield _y1frac I32 Signed noattr 2 false :: nil)
   noattr ::
 Composite __536 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _fmt I32 Unsigned noattr 3 false ::
    Member_bitfield _siz I32 Unsigned noattr 2 false ::
    Member_bitfield _pad0 I32 Unsigned noattr 1 false ::
    Member_bitfield _line I32 Unsigned noattr 9 false ::
    Member_bitfield _tmem I32 Unsigned noattr 9 false ::
    Member_bitfield _pad1 I32 Unsigned noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _palette I32 Unsigned noattr 4 false ::
    Member_bitfield _ct I32 Unsigned noattr 1 false ::
    Member_bitfield _mt I32 Unsigned noattr 1 false ::
    Member_bitfield _maskt I32 Unsigned noattr 4 false ::
    Member_bitfield _shiftt I32 Unsigned noattr 4 false ::
    Member_bitfield _cs I32 Unsigned noattr 1 false ::
    Member_bitfield _ms I32 Unsigned noattr 1 false ::
    Member_bitfield _masks I32 Unsigned noattr 4 false ::
    Member_bitfield _shifts I32 Unsigned noattr 4 false :: nil)
   noattr ::
 Composite __538 Struct
   (Member_bitfield _cmd I32 Signed noattr 8 false ::
    Member_bitfield _sl I32 Unsigned noattr 12 false ::
    Member_bitfield _tl I32 Unsigned noattr 12 false ::
    Member_bitfield _pad I32 Signed noattr 5 false ::
    Member_bitfield _tile I32 Unsigned noattr 3 false ::
    Member_bitfield _sh I32 Unsigned noattr 12 false ::
    Member_bitfield _th I32 Unsigned noattr 12 false :: nil)
   noattr ::
 Composite __547 Struct
   (Member_plain _w0 tuint :: Member_plain _w1 tuint :: nil)
   noattr ::
 Composite __549 Union
   (Member_plain _words (Tstruct __547 noattr) ::
    Member_plain _dma (Tstruct __510 noattr) ::
    Member_plain _tri (Tstruct __512 noattr) ::
    Member_plain _line (Tstruct __524 noattr) ::
    Member_plain _popmtx (Tstruct __514 noattr) ::
    Member_plain _segment (Tstruct __516 noattr) ::
    Member_plain _setothermodeH (Tstruct __520 noattr) ::
    Member_plain _setothermodeL (Tstruct __518 noattr) ::
    Member_plain _texture (Tstruct __522 noattr) ::
    Member_plain _perspnorm (Tstruct __526 noattr) ::
    Member_plain _setimg (Tstruct __528 noattr) ::
    Member_plain _setcombine (Tstruct __530 noattr) ::
    Member_plain _setcolor (Tstruct __532 noattr) ::
    Member_plain _fillrect (Tstruct __534 noattr) ::
    Member_plain _settile (Tstruct __536 noattr) ::
    Member_plain _loadtile (Tstruct __538 noattr) ::
    Member_plain _settilesize (Tstruct __538 noattr) ::
    Member_plain _loadtlut (Tstruct __538 noattr) ::
    Member_plain _force_structure_alignment tlong :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __317 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __319 noattr)) :: nil)
   noattr ::
 Composite _SPTask Struct
   (Member_plain _task (Tunion __358 noattr) ::
    Member_plain _msgqueue (tptr (Tstruct _OSMesgQueue_s noattr)) ::
    Member_plain _msg (tptr tvoid) :: Member_plain _state tint :: nil)
   noattr ::
 Composite _VblankHandler Struct
   (Member_plain _queue (tptr (Tstruct _OSMesgQueue_s noattr)) ::
    Member_plain _msg (tptr tvoid) :: nil)
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
 Composite _GfxPool Struct
   (Member_plain _buffer (tarray (Tunion __549 noattr) 6400) ::
    Member_plain _spTask (Tstruct _SPTask noattr) :: nil)
   noattr ::
 Composite _DemoInput Struct
   (Member_plain _timer tuchar :: Member_plain _rawStickX tschar ::
    Member_plain _rawStickY tschar :: Member_plain _buttonMask tuchar :: nil)
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
     cc_default)) :: (___stringlit_1, Gvar v___stringlit_1) ::
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_osCreateMesgQueue,
   Gfun(External (EF_external "osCreateMesgQueue"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tvoid cc_default)) ::
 (_osRecvMesg,
   Gfun(External (EF_external "osRecvMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tint cc_default)) ::
 (_osContInit,
   Gfun(External (EF_external "osContInit"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr tuchar) ::
      (tptr (Tstruct __317 noattr)) :: nil) tint cc_default)) ::
 (_osContStartReadData,
   Gfun(External (EF_external "osContStartReadData"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: nil) tint cc_default)) ::
 (_osContGetReadData,
   Gfun(External (EF_external "osContGetReadData"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct __319 noattr)) :: nil) tvoid cc_default)) ::
 (_rspF3DBootStart, Gvar v_rspF3DBootStart) ::
 (_rspF3DBootEnd, Gvar v_rspF3DBootEnd) ::
 (_rspF3DStart, Gvar v_rspF3DStart) ::
 (_rspF3DDataStart, Gvar v_rspF3DDataStart) ::
 (_osWritebackDCacheAll,
   Gfun(External (EF_external "osWritebackDCacheAll"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osViSwapBuffer,
   Gfun(External (EF_external "osViSwapBuffer"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (_osEepromProbe,
   Gfun(External (EF_external "osEepromProbe"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: nil) tint cc_default)) ::
 (_play_music,
   Gfun(External (EF_external "play_music"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned ::
                      AST.Xint16unsigned :: nil) AST.Xvoid cc_default))
     (tuchar :: tushort :: tushort :: nil) tvoid cc_default)) ::
 (_set_segment_base_addr,
   Gfun(External (EF_external "set_segment_base_addr"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xint
                     cc_default)) (tint :: (tptr tvoid) :: nil) tuint
     cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_move_segment_table_to_dmem,
   Gfun(External (EF_external "move_segment_table_to_dmem"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_main_pool_alloc,
   Gfun(External (EF_external "main_pool_alloc"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_load_segment,
   Gfun(External (EF_external "load_segment"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tuchar) :: (tptr tuchar) :: tuint :: nil) (tptr tvoid)
     cc_default)) ::
 (_load_segment_decompress,
   Gfun(External (EF_external "load_segment_decompress"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     (tint :: (tptr tuchar) :: (tptr tuchar) :: nil) (tptr tvoid)
     cc_default)) ::
 (_setup_dma_table_list,
   Gfun(External (EF_external "setup_dma_table_list"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _DmaHandlerList noattr)) :: (tptr tvoid) ::
      (tptr tvoid) :: nil) tvoid cc_default)) ::
 (_save_file_load_all,
   Gfun(External (EF_external "save_file_load_all"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_save_file_get_sound_mode,
   Gfun(External (EF_external "save_file_get_sound_mode"
                   (mksignature nil AST.Xint16unsigned cc_default)) nil
     tushort cc_default)) :: (_gMarioAnims, Gvar v_gMarioAnims) ::
 (_gDemoInputs, Gvar v_gDemoInputs) ::
 (_gGfxSPTaskYieldBuffer, Gvar v_gGfxSPTaskYieldBuffer) ::
 (_gGfxSPTaskStack, Gvar v_gGfxSPTaskStack) ::
 (_gGfxPools, Gvar v_gGfxPools) ::
 (_gGfxSPTaskOutputBuffer, Gvar v_gGfxSPTaskOutputBuffer) ::
 (_gFramebuffers, Gvar v_gFramebuffers) :: (_gZBuffer, Gvar v_gZBuffer) ::
 (_level_script_entry, Gvar v_level_script_entry) ::
 (_level_script_execute,
   Gfun(External (EF_external "level_script_execute"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr (Tstruct _LevelCommand noattr)) :: nil)
     (tptr (Tstruct _LevelCommand noattr)) cc_default)) ::
 (_gMainReceivedMesg, Gvar v_gMainReceivedMesg) ::
 (_gSIEventMesgQueue, Gvar v_gSIEventMesgQueue) ::
 (_gResetTimer, Gvar v_gResetTimer) ::
 (_gNmiResetBarsTimer, Gvar v_gNmiResetBarsTimer) ::
 (_gShowProfiler, Gvar v_gShowProfiler) ::
 (_gShowDebugText, Gvar v_gShowDebugText) ::
 (_set_vblank_handler,
   Gfun(External (EF_external "set_vblank_handler"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: (tptr (Tstruct _VblankHandler noattr)) ::
      (tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) :: nil)
     tvoid cc_default)) ::
 (_exec_display_list,
   Gfun(External (EF_external "exec_display_list"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _SPTask noattr)) :: nil) tvoid cc_default)) ::
 (_profiler_log_thread5_time,
   Gfun(External (EF_external "profiler_log_thread5_time"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_draw_profiler,
   Gfun(External (EF_external "draw_profiler"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_set_sound_mode,
   Gfun(External (EF_external "set_sound_mode"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_audio_game_loop_tick,
   Gfun(External (EF_external "audio_game_loop_tick"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_print_text_fmt_int,
   Gfun(External (EF_external "print_text_fmt_int"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tuchar) :: tint :: nil) tvoid cc_default)) ::
 (__entrySegmentRomStart, Gvar v__entrySegmentRomStart) ::
 (__entrySegmentRomEnd, Gvar v__entrySegmentRomEnd) ::
 (__segment2_mio0SegmentRomStart, Gvar v__segment2_mio0SegmentRomStart) ::
 (__segment2_mio0SegmentRomEnd, Gvar v__segment2_mio0SegmentRomEnd) ::
 (_gControllers, Gvar v_gControllers) :: (_gGfxSPTask, Gvar v_gGfxSPTask) ::
 (_gDisplayListHead, Gvar v_gDisplayListHead) ::
 (_gGfxPoolEnd, Gvar v_gGfxPoolEnd) :: (_gGfxPool, Gvar v_gGfxPool) ::
 (_gControllerStatuses, Gvar v_gControllerStatuses) ::
 (_gControllerPads, Gvar v_gControllerPads) ::
 (_gControllerBits, Gvar v_gControllerBits) ::
 (_gEepromProbe, Gvar v_gEepromProbe) ::
 (_gGameVblankQueue, Gvar v_gGameVblankQueue) ::
 (_gGfxVblankQueue, Gvar v_gGfxVblankQueue) ::
 (_gGameMesgBuf, Gvar v_gGameMesgBuf) ::
 (_gGfxMesgBuf, Gvar v_gGfxMesgBuf) ::
 (_gGameVblankHandler, Gvar v_gGameVblankHandler) ::
 (_gPhysicalFramebuffers, Gvar v_gPhysicalFramebuffers) ::
 (_gPhysicalZBuffer, Gvar v_gPhysicalZBuffer) ::
 (_gMarioAnimsMemAlloc, Gvar v_gMarioAnimsMemAlloc) ::
 (_gDemoInputsMemAlloc, Gvar v_gDemoInputsMemAlloc) ::
 (_gMarioAnimsBuf, Gvar v_gMarioAnimsBuf) ::
 (_gDemoInputsBuf, Gvar v_gDemoInputsBuf) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_sRenderedFramebuffer, Gvar v_sRenderedFramebuffer) ::
 (_sRenderingFramebuffer, Gvar v_sRenderingFramebuffer) ::
 (_gGoddardVblankCallback, Gvar v_gGoddardVblankCallback) ::
 (_gPlayer1Controller, Gvar v_gPlayer1Controller) ::
 (_gPlayer2Controller, Gvar v_gPlayer2Controller) ::
 (_gPlayer3Controller, Gvar v_gPlayer3Controller) ::
 (_gCurrDemoInput, Gvar v_gCurrDemoInput) ::
 (_gDemoInputListID, Gvar v_gDemoInputListID) ::
 (_gRecordedDemoInput, Gvar v_gRecordedDemoInput) ::
 (_init_rdp, Gfun(Internal f_init_rdp)) ::
 (_init_rsp, Gfun(Internal f_init_rsp)) ::
 (_init_z_buffer, Gfun(Internal f_init_z_buffer)) ::
 (_select_framebuffer, Gfun(Internal f_select_framebuffer)) ::
 (_clear_framebuffer, Gfun(Internal f_clear_framebuffer)) ::
 (_clear_viewport, Gfun(Internal f_clear_viewport)) ::
 (_draw_screen_borders, Gfun(Internal f_draw_screen_borders)) ::
 (_make_viewport_clip_rect, Gfun(Internal f_make_viewport_clip_rect)) ::
 (_create_gfx_task_structure, Gfun(Internal f_create_gfx_task_structure)) ::
 (_init_rcp, Gfun(Internal f_init_rcp)) ::
 (_end_master_display_list, Gfun(Internal f_end_master_display_list)) ::
 (_draw_reset_bars, Gfun(Internal f_draw_reset_bars)) ::
 (_render_init, Gfun(Internal f_render_init)) ::
 (_select_gfx_pool, Gfun(Internal f_select_gfx_pool)) ::
 (_display_and_vsync, Gfun(Internal f_display_and_vsync)) ::
 (_adjust_analog_stick, Gfun(Internal f_adjust_analog_stick)) ::
 (_run_demo_inputs, Gfun(Internal f_run_demo_inputs)) ::
 (_read_controller_inputs, Gfun(Internal f_read_controller_inputs)) ::
 (_init_controllers, Gfun(Internal f_init_controllers)) ::
 (_setup_game_memory, Gfun(Internal f_setup_game_memory)) ::
 (_thread5_game_loop, Gfun(Internal f_thread5_game_loop)) :: nil).

Definition public_idents : list ident :=
(_thread5_game_loop :: _setup_game_memory :: _init_controllers ::
 _read_controller_inputs :: _run_demo_inputs :: _adjust_analog_stick ::
 _display_and_vsync :: _select_gfx_pool :: _render_init ::
 _draw_reset_bars :: _end_master_display_list :: _init_rcp ::
 _create_gfx_task_structure :: _make_viewport_clip_rect ::
 _draw_screen_borders :: _clear_viewport :: _clear_framebuffer ::
 _select_framebuffer :: _init_z_buffer :: _init_rsp :: _init_rdp ::
 _gRecordedDemoInput :: _gDemoInputListID :: _gCurrDemoInput ::
 _gPlayer3Controller :: _gPlayer2Controller :: _gPlayer1Controller ::
 _gGoddardVblankCallback :: _sRenderingFramebuffer ::
 _sRenderedFramebuffer :: _gGlobalTimer :: _gDemoInputsBuf ::
 _gMarioAnimsBuf :: _gDemoInputsMemAlloc :: _gMarioAnimsMemAlloc ::
 _gPhysicalZBuffer :: _gPhysicalFramebuffers :: _gGameVblankHandler ::
 _gGfxMesgBuf :: _gGameMesgBuf :: _gGfxVblankQueue :: _gGameVblankQueue ::
 _gEepromProbe :: _gControllerBits :: _gControllerPads ::
 _gControllerStatuses :: _gGfxPool :: _gGfxPoolEnd :: _gDisplayListHead ::
 _gGfxSPTask :: _gControllers :: __segment2_mio0SegmentRomEnd ::
 __segment2_mio0SegmentRomStart :: __entrySegmentRomEnd ::
 __entrySegmentRomStart :: _print_text_fmt_int :: _audio_game_loop_tick ::
 _set_sound_mode :: _draw_profiler :: _profiler_log_thread5_time ::
 _exec_display_list :: _set_vblank_handler :: _gShowDebugText ::
 _gShowProfiler :: _gNmiResetBarsTimer :: _gResetTimer ::
 _gSIEventMesgQueue :: _gMainReceivedMesg :: _level_script_execute ::
 _level_script_entry :: _gZBuffer :: _gFramebuffers ::
 _gGfxSPTaskOutputBuffer :: _gGfxPools :: _gGfxSPTaskStack ::
 _gGfxSPTaskYieldBuffer :: _gDemoInputs :: _gMarioAnims ::
 _save_file_get_sound_mode :: _save_file_load_all :: _setup_dma_table_list ::
 _load_segment_decompress :: _load_segment :: _main_pool_alloc ::
 _move_segment_table_to_dmem :: _segmented_to_virtual ::
 _set_segment_base_addr :: _play_music :: _osEepromProbe ::
 _osViSwapBuffer :: _osWritebackDCacheAll :: _rspF3DDataStart ::
 _rspF3DStart :: _rspF3DBootEnd :: _rspF3DBootStart :: _osContGetReadData ::
 _osContStartReadData :: _osContInit :: _osRecvMesg :: _osCreateMesgQueue ::
 _sqrtf :: ___builtin_debug :: ___builtin_sync_fetch_and_add ::
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
