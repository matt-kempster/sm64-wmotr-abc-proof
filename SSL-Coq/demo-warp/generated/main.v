(* GENERATED FILE -- DO NOT EDIT.
   Source: ../../../reference-sm64-decomp/src/game/main.c
   clightgen: The CompCert CompCert AST generator, version 3.15
   Flags: -normalize -nostdinc -fstruct-passing -I../../../reference-sm64-decomp/include -I../../../reference-sm64-decomp/build/us -I../../../reference-sm64-decomp/build/us/include -I../../../reference-sm64-decomp/src -I../../../reference-sm64-decomp/src/game -I../../../reference-sm64-decomp -I../../../reference-sm64-decomp/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 *)
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
  Definition source_file := "../../../reference-sm64-decomp/src/game/main.c".
  Definition normalized := true.
End Info.

Definition _Controller : ident := $"Controller".
Definition _D_8032C650 : ident := $"D_8032C650".
Definition _D_80339210 : ident := $"D_80339210".
Definition _MemoryPool : ident := $"MemoryPool".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
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
Definition __390 : ident := $"_390".
Definition __392 : ident := $"_392".
Definition __394 : ident := $"_394".
Definition __421 : ident := $"_421".
Definition __423 : ident := $"_423".
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
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _alloc_pool : ident := $"alloc_pool".
Definition _arg : ident := $"arg".
Definition _at : ident := $"at".
Definition _b : ident := $"b".
Definition _badvaddr : ident := $"badvaddr".
Definition _burst : ident := $"burst".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _cause : ident := $"cause".
Definition _comRegs : ident := $"comRegs".
Definition _context : ident := $"context".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_thread : ident := $"create_thread".
Definition _ctrl : ident := $"ctrl".
Definition _curSPTask : ident := $"curSPTask".
Definition _data_ptr : ident := $"data_ptr".
Definition _data_size : ident := $"data_size".
Definition _devAddr : ident := $"devAddr".
Definition _dispatch_audio_sptask : ident := $"dispatch_audio_sptask".
Definition _dramAddr : ident := $"dramAddr".
Definition _dram_stack : ident := $"dram_stack".
Definition _dram_stack_size : ident := $"dram_stack_size".
Definition _end : ident := $"end".
Definition _entry : ident := $"entry".
Definition _errnum : ident := $"errnum".
Definition _exec_display_list : ident := $"exec_display_list".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _fadeout_music : ident := $"fadeout_music".
Definition _filler : ident := $"filler".
Definition _first : ident := $"first".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _fldRegs : ident := $"fldRegs".
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
Definition _gActiveSPTask : ident := $"gActiveSPTask".
Definition _gDebugLevelSelect : ident := $"gDebugLevelSelect".
Definition _gDmaIoMesg : ident := $"gDmaIoMesg".
Definition _gDmaMesgBuf : ident := $"gDmaMesgBuf".
Definition _gDmaMesgQueue : ident := $"gDmaMesgQueue".
Definition _gEffectsMemoryPool : ident := $"gEffectsMemoryPool".
Definition _gGameLoopThread : ident := $"gGameLoopThread".
Definition _gIdleThread : ident := $"gIdleThread".
Definition _gIdleThreadStack : ident := $"gIdleThreadStack".
Definition _gIntrMesgBuf : ident := $"gIntrMesgBuf".
Definition _gIntrMesgQueue : ident := $"gIntrMesgQueue".
Definition _gMainReceivedMesg : ident := $"gMainReceivedMesg".
Definition _gMainThread : ident := $"gMainThread".
Definition _gNmiResetBarsTimer : ident := $"gNmiResetBarsTimer".
Definition _gNumVblanks : ident := $"gNumVblanks".
Definition _gPIMesgBuf : ident := $"gPIMesgBuf".
Definition _gPIMesgQueue : ident := $"gPIMesgQueue".
Definition _gPlayer3Controller : ident := $"gPlayer3Controller".
Definition _gResetTimer : ident := $"gResetTimer".
Definition _gSIEventMesgBuf : ident := $"gSIEventMesgBuf".
Definition _gSIEventMesgQueue : ident := $"gSIEventMesgQueue".
Definition _gSPTaskMesgQueue : ident := $"gSPTaskMesgQueue".
Definition _gShowDebugText : ident := $"gShowDebugText".
Definition _gShowProfiler : ident := $"gShowProfiler".
Definition _gSoundThread : ident := $"gSoundThread".
Definition _gThread3Stack : ident := $"gThread3Stack".
Definition _gThread4Stack : ident := $"gThread4Stack".
Definition _gThread5Stack : ident := $"gThread5Stack".
Definition _gUnknownMesgBuf : ident := $"gUnknownMesgBuf".
Definition _gVblankHandler1 : ident := $"gVblankHandler1".
Definition _gVblankHandler2 : ident := $"gVblankHandler2".
Definition _gp : ident := $"gp".
Definition _hStart : ident := $"hStart".
Definition _hSync : ident := $"hSync".
Definition _handle_debug_key_sequences : ident := $"handle_debug_key_sequences".
Definition _handle_dp_complete : ident := $"handle_dp_complete".
Definition _handle_nmi_request : ident := $"handle_nmi_request".
Definition _handle_sp_complete : ident := $"handle_sp_complete".
Definition _handle_vblank : ident := $"handle_vblank".
Definition _handler : ident := $"handler".
Definition _hdr : ident := $"hdr".
Definition _hi : ident := $"hi".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _interrupt_gfx_sptask : ident := $"interrupt_gfx_sptask".
Definition _leap : ident := $"leap".
Definition _lo : ident := $"lo".
Definition _load_engine_code_segment : ident := $"load_engine_code_segment".
Definition _main : ident := $"main".
Definition _main_func : ident := $"main_func".
Definition _main_pool_init : ident := $"main_pool_init".
Definition _mem_pool_init : ident := $"mem_pool_init".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _msgqueue : ident := $"msgqueue".
Definition _mtqueue : ident := $"mtqueue".
Definition _next : ident := $"next".
Definition _origin : ident := $"origin".
Definition _osCreateMesgQueue : ident := $"osCreateMesgQueue".
Definition _osCreatePiManager : ident := $"osCreatePiManager".
Definition _osCreateThread : ident := $"osCreateThread".
Definition _osCreateViManager : ident := $"osCreateViManager".
Definition _osInitialize : ident := $"osInitialize".
Definition _osMapTLB : ident := $"osMapTLB".
Definition _osRecvMesg : ident := $"osRecvMesg".
Definition _osSendMesg : ident := $"osSendMesg".
Definition _osSetEventMesg : ident := $"osSetEventMesg".
Definition _osSetThreadPri : ident := $"osSetThreadPri".
Definition _osSetTime : ident := $"osSetTime".
Definition _osSpTaskLoad : ident := $"osSpTaskLoad".
Definition _osSpTaskStartGo : ident := $"osSpTaskStartGo".
Definition _osSpTaskYield : ident := $"osSpTaskYield".
Definition _osSpTaskYielded : ident := $"osSpTaskYielded".
Definition _osStartThread : ident := $"osStartThread".
Definition _osTvType : ident := $"osTvType".
Definition _osUnmapTLBAll : ident := $"osUnmapTLBAll".
Definition _osViBlack : ident := $"osViBlack".
Definition _osViModeTable : ident := $"osViModeTable".
Definition _osViSetEvent : ident := $"osViSetEvent".
Definition _osViSetMode : ident := $"osViSetMode".
Definition _osViSetSpecialFeatures : ident := $"osViSetSpecialFeatures".
Definition _osWritebackDCacheAll : ident := $"osWritebackDCacheAll".
Definition _output_buff : ident := $"output_buff".
Definition _output_buff_size : ident := $"output_buff_size".
Definition _pc : ident := $"pc".
Definition _pretend_audio_sptask_done : ident := $"pretend_audio_sptask_done".
Definition _pri : ident := $"pri".
Definition _priority : ident := $"priority".
Definition _profiler_log_gfx_time : ident := $"profiler_log_gfx_time".
Definition _profiler_log_vblank_time : ident := $"profiler_log_vblank_time".
Definition _queue : ident := $"queue".
Definition _ra : ident := $"ra".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _receive_new_tasks : ident := $"receive_new_tasks".
Definition _retQueue : ident := $"retQueue".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sAudioEnabled : ident := $"sAudioEnabled".
Definition _sCurrentAudioSPTask : ident := $"sCurrentAudioSPTask".
Definition _sCurrentDisplaySPTask : ident := $"sCurrentDisplaySPTask".
Definition _sDebugTextKey : ident := $"sDebugTextKey".
Definition _sDebugTextKeySequence : ident := $"sDebugTextKeySequence".
Definition _sNextAudioSPTask : ident := $"sNextAudioSPTask".
Definition _sNextDisplaySPTask : ident := $"sNextDisplaySPTask".
Definition _sProfilerKey : ident := $"sProfilerKey".
Definition _sProfilerKeySequence : ident := $"sProfilerKeySequence".
Definition _send_sp_task_message : ident := $"send_sp_task_message".
Definition _set_vblank_handler : ident := $"set_vblank_handler".
Definition _setup_mesg_queues : ident := $"setup_mesg_queues".
Definition _size : ident := $"size".
Definition _sound_banks_disable : ident := $"sound_banks_disable".
Definition _sp : ident := $"sp".
Definition _sp24 : ident := $"sp24".
Definition _spTask : ident := $"spTask".
Definition _sprintf : ident := $"sprintf".
Definition _sr : ident := $"sr".
Definition _start : ident := $"start".
Definition _start_gfx_sptask : ident := $"start_gfx_sptask".
Definition _start_sptask : ident := $"start_sptask".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_sounds_in_continuous_banks : ident := $"stop_sounds_in_continuous_banks".
Definition _stub_main_1 : ident := $"stub_main_1".
Definition _stub_main_2 : ident := $"stub_main_2".
Definition _stub_main_3 : ident := $"stub_main_3".
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
Definition _taskType : ident := $"taskType".
Definition _thprof : ident := $"thprof".
Definition _thread : ident := $"thread".
Definition _thread1_idle : ident := $"thread1_idle".
Definition _thread3_main : ident := $"thread3_main".
Definition _thread4_sound : ident := $"thread4_sound".
Definition _thread5_game_loop : ident := $"thread5_game_loop".
Definition _time : ident := $"time".
Definition _tlnext : ident := $"tlnext".
Definition _turn_off_audio : ident := $"turn_off_audio".
Definition _turn_on_audio : ident := $"turn_on_audio".
Definition _type : ident := $"type".
Definition _ucode : ident := $"ucode".
Definition _ucode_boot : ident := $"ucode_boot".
Definition _ucode_boot_size : ident := $"ucode_boot_size".
Definition _ucode_data : ident := $"ucode_data".
Definition _ucode_data_size : ident := $"ucode_data_size".
Definition _ucode_size : ident := $"ucode_size".
Definition _unknown_main_func : ident := $"unknown_main_func".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _vBurst : ident := $"vBurst".
Definition _vCurrent : ident := $"vCurrent".
Definition _vIntr : ident := $"vIntr".
Definition _vStart : ident := $"vStart".
Definition _vSync : ident := $"vSync".
Definition _validCount : ident := $"validCount".
Definition _width : ident := $"width".
Definition _xScale : ident := $"xScale".
Definition _yScale : ident := $"yScale".
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
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_osViModeTable := {|
  gvar_info := (tarray (Tstruct __394 noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_osTvType := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gEffectsMemoryPool := {|
  gvar_info := (tptr (Tstruct _MemoryPool noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayer3Controller := {|
  gvar_info := (tptr (Tstruct _Controller noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gIdleThreadStack := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gThread3Stack := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gThread4Stack := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gThread5Stack := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80339210 := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gIdleThread := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMainThread := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGameLoopThread := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSoundThread := {|
  gvar_info := (Tstruct _OSThread_s noattr);
  gvar_init := (Init_space 432 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDmaIoMesg := {|
  gvar_info := (Tstruct __423 noattr);
  gvar_init := (Init_space 20 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMainReceivedMesg := {|
  gvar_info := (tptr tvoid);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDmaMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSIEventMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPIMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gIntrMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSPTaskMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDmaMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 1);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPIMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 32);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSIEventMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 1);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gIntrMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 16);
  gvar_init := (Init_space 64 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnknownMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 16);
  gvar_init := (Init_space 64 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVblankHandler1 := {|
  gvar_info := (tptr (Tstruct _VblankHandler noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVblankHandler2 := {|
  gvar_info := (tptr (Tstruct _VblankHandler noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gActiveSPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentAudioSPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentDisplaySPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNextAudioSPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNextDisplaySPTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sAudioEnabled := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNumVblanks := {|
  gvar_info := tuint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gResetTimer := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNmiResetBarsTimer := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugLevelSelect := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032C650 := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShowProfiler := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gShowDebugText := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sProfilerKeySequence := {|
  gvar_info := (tarray tushort 8);
  gvar_init := (Init_int16 (Int.repr 2048) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 1024) :: Init_int16 (Int.repr 1024) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 256) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugTextKeySequence := {|
  gvar_info := (tarray tushort 8);
  gvar_init := (Init_int16 (Int.repr 1024) :: Init_int16 (Int.repr 1024) ::
                Init_int16 (Int.repr 2048) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 256) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sProfilerKey := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDebugTextKey := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_handle_debug_key_sequences := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tshort) :: (_t'1, tshort) :: (_t'14, tschar) ::
               (_t'13, tshort) :: (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _Controller noattr))) ::
               (_t'10, tushort) :: (_t'9, tschar) :: (_t'8, tshort) ::
               (_t'7, tushort) ::
               (_t'6, (tptr (Tstruct _Controller noattr))) ::
               (_t'5, tushort) :: (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'3 (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _t'3 (tptr (Tstruct _Controller noattr)))
          (Tstruct _Controller noattr)) _buttonPressed tushort))
    (Sifthenelse (Ebinop One (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'1 (Evar _sProfilerKey tshort))
            (Sassign (Evar _sProfilerKey tshort)
              (Ebinop Oadd (Etempvar _t'1 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ebinop Oadd (Evar _sProfilerKeySequence (tarray tushort 8))
                  (Etempvar _t'1 tshort) (tptr tushort)) tushort))
            (Ssequence
              (Sset _t'11
                (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef
                      (Etempvar _t'11 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                               (Etempvar _t'12 tushort) tint)
                  (Ssequence
                    (Sset _t'13 (Evar _sProfilerKey tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tshort)
                                   (Ecast
                                     (Ebinop Odiv
                                       (Esizeof (tarray tushort 8) tuint)
                                       (Esizeof tushort tuint) tuint) tint)
                                   tint)
                      (Ssequence
                        (Sassign (Evar _sProfilerKey tshort)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sset _t'14 (Evar _gShowProfiler tschar))
                          (Sassign (Evar _gShowProfiler tschar)
                            (Ebinop Oxor (Etempvar _t'14 tschar)
                              (Econst_int (Int.repr 1) tint) tint))))
                      Sskip))
                  (Sassign (Evar _sProfilerKey tshort)
                    (Econst_int (Int.repr 0) tint)))))))
        (Ssequence
          (Ssequence
            (Sset _t'2 (Evar _sDebugTextKey tshort))
            (Sassign (Evar _sDebugTextKey tshort)
              (Ebinop Oadd (Etempvar _t'2 tshort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd (Evar _sDebugTextKeySequence (tarray tushort 8))
                  (Etempvar _t'2 tshort) (tptr tushort)) tushort))
            (Ssequence
              (Sset _t'6
                (Evar _gPlayer3Controller (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef
                      (Etempvar _t'6 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                               (Etempvar _t'7 tushort) tint)
                  (Ssequence
                    (Sset _t'8 (Evar _sDebugTextKey tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tshort)
                                   (Ecast
                                     (Ebinop Odiv
                                       (Esizeof (tarray tushort 8) tuint)
                                       (Esizeof tushort tuint) tuint) tint)
                                   tint)
                      (Ssequence
                        (Sassign (Evar _sDebugTextKey tshort)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sset _t'9 (Evar _gShowDebugText tschar))
                          (Sassign (Evar _gShowDebugText tschar)
                            (Ebinop Oxor (Etempvar _t'9 tschar)
                              (Econst_int (Int.repr 1) tint) tint))))
                      Sskip))
                  (Sassign (Evar _sDebugTextKey tshort)
                    (Econst_int (Int.repr 0) tint))))))))
      Sskip)))
|}.

Definition f_unknown_main_func := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_time, tulong) :: (_b, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _time (Ecast (Econst_int (Int.repr 0) tint) tulong))
  (Ssequence
    (Sset _b (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Scall None
        (Evar _osSetTime (Tfunction (tulong :: nil) tvoid cc_default))
        ((Etempvar _time tulong) :: nil))
      (Ssequence
        (Scall None
          (Evar _osMapTLB (Tfunction
                            (tint :: tuint :: (tptr tvoid) :: tuint ::
                             tuint :: tint :: nil) tvoid cc_default))
          ((Econst_int (Int.repr 0) tint) :: (Etempvar _b tuint) ::
           (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Ssequence
          (Scall None (Evar _osUnmapTLBAll (Tfunction nil tvoid cc_default))
            nil)
          (Scall None
            (Evar _sprintf (Tfunction ((tptr tuchar) :: (tptr tuchar) :: nil)
                             tint
                             {|cc_vararg:=(Some 2); cc_unproto:=false; cc_structret:=false|}))
            ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
             (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil)))))))
|}.

Definition f_stub_main_1 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_main_2 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_stub_main_3 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_setup_mesg_queues := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _osCreateMesgQueue (Tfunction
                               ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                (tptr (tptr tvoid)) :: tint :: nil) tvoid
                               cc_default))
    ((Eaddrof (Evar _gDmaMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Evar _gDmaMesgBuf (tarray (tptr tvoid) 1)) ::
     (Ecast
       (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 1) tuint)
         (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _osCreateMesgQueue (Tfunction
                                 ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                  (tptr (tptr tvoid)) :: tint :: nil) tvoid
                                 cc_default))
      ((Eaddrof (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
         (tptr (Tstruct _OSMesgQueue_s noattr))) ::
       (Evar _gSIEventMesgBuf (tarray (tptr tvoid) 1)) ::
       (Ecast
         (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 1) tuint)
           (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _osSetEventMesg (Tfunction
                                (tuint ::
                                 (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                 (tptr tvoid) :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 5) tint) ::
         (Eaddrof (Evar _gSIEventMesgQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil))
      (Ssequence
        (Scall None
          (Evar _osCreateMesgQueue (Tfunction
                                     ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                      (tptr (tptr tvoid)) :: tint :: nil)
                                     tvoid cc_default))
          ((Eaddrof (Evar _gSPTaskMesgQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Evar _gUnknownMesgBuf (tarray (tptr tvoid) 16)) ::
           (Ecast
             (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 16) tuint)
               (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _osCreateMesgQueue (Tfunction
                                       ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                        (tptr (tptr tvoid)) :: tint :: nil)
                                       tvoid cc_default))
            ((Eaddrof (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
               (tptr (Tstruct _OSMesgQueue_s noattr))) ::
             (Evar _gIntrMesgBuf (tarray (tptr tvoid) 16)) ::
             (Ecast
               (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 16) tuint)
                 (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _osViSetEvent (Tfunction
                                    ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                     (tptr tvoid) :: tuint :: nil) tvoid
                                    cc_default))
              ((Eaddrof
                 (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (Ecast (Econst_int (Int.repr 102) tint) (tptr tvoid)) ::
               (Econst_int (Int.repr 1) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _osSetEventMesg (Tfunction
                                        (tuint ::
                                         (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                         (tptr tvoid) :: nil) tvoid
                                        cc_default))
                ((Econst_int (Int.repr 4) tint) ::
                 (Eaddrof
                   (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                   (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                 (Ecast (Econst_int (Int.repr 100) tint) (tptr tvoid)) ::
                 nil))
              (Ssequence
                (Scall None
                  (Evar _osSetEventMesg (Tfunction
                                          (tuint ::
                                           (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                           (tptr tvoid) :: nil) tvoid
                                          cc_default))
                  ((Econst_int (Int.repr 9) tint) ::
                   (Eaddrof
                     (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                   (Ecast (Econst_int (Int.repr 101) tint) (tptr tvoid)) ::
                   nil))
                (Scall None
                  (Evar _osSetEventMesg (Tfunction
                                          (tuint ::
                                           (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                           (tptr tvoid) :: nil) tvoid
                                          cc_default))
                  ((Econst_int (Int.repr 14) tint) ::
                   (Eaddrof
                     (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                   (Ecast (Econst_int (Int.repr 104) tint) (tptr tvoid)) ::
                   nil))))))))))
|}.

Definition f_alloc_pool := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_start, (tptr tvoid)) :: (_end, (tptr tvoid)) ::
               (_t'1, (tptr (Tstruct _MemoryPool noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _start
    (Ecast (Econst_int (Int.repr (-2147106816)) tuint) (tptr tvoid)))
  (Ssequence
    (Sset _end
      (Ecast
        (Ebinop Oadd (Econst_int (Int.repr (-2147106816)) tuint)
          (Econst_int (Int.repr 1462272) tint) tuint) (tptr tvoid)))
    (Ssequence
      (Scall None
        (Evar _main_pool_init (Tfunction
                                ((tptr tvoid) :: (tptr tvoid) :: nil) tvoid
                                cc_default))
        ((Etempvar _start (tptr tvoid)) :: (Etempvar _end (tptr tvoid)) ::
         nil))
      (Ssequence
        (Scall (Some _t'1)
          (Evar _mem_pool_init (Tfunction (tuint :: tuint :: nil)
                                 (tptr (Tstruct _MemoryPool noattr))
                                 cc_default))
          ((Econst_int (Int.repr 16384) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sassign
          (Evar _gEffectsMemoryPool (tptr (Tstruct _MemoryPool noattr)))
          (Etempvar _t'1 (tptr (Tstruct _MemoryPool noattr))))))))
|}.

Definition f_create_thread := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_thread, (tptr (Tstruct _OSThread_s noattr))) ::
                (_id, tint) ::
                (_entry,
                 (tptr (Tfunction ((tptr tvoid) :: nil) tvoid cc_default))) ::
                (_arg, (tptr tvoid)) :: (_sp, (tptr tvoid)) ::
                (_pri, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _thread (tptr (Tstruct _OSThread_s noattr)))
        (Tstruct _OSThread_s noattr)) _next
      (tptr (Tstruct _OSThread_s noattr)))
    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _thread (tptr (Tstruct _OSThread_s noattr)))
          (Tstruct _OSThread_s noattr)) _queue
        (tptr (tptr (Tstruct _OSThread_s noattr))))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Scall None
      (Evar _osCreateThread (Tfunction
                              ((tptr (Tstruct _OSThread_s noattr)) :: tint ::
                               (tptr (Tfunction ((tptr tvoid) :: nil) tvoid
                                       cc_default)) :: (tptr tvoid) ::
                               (tptr tvoid) :: tint :: nil) tvoid cc_default))
      ((Etempvar _thread (tptr (Tstruct _OSThread_s noattr))) ::
       (Etempvar _id tint) ::
       (Etempvar _entry (tptr (Tfunction ((tptr tvoid) :: nil) tvoid
                                cc_default))) ::
       (Etempvar _arg (tptr tvoid)) :: (Etempvar _sp (tptr tvoid)) ::
       (Etempvar _pri tint) :: nil))))
|}.

Definition f_handle_nmi_request := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _gResetTimer tschar) (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Sassign (Evar _gNmiResetBarsTimer tschar)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Scall None
        (Evar _stop_sounds_in_continuous_banks (Tfunction nil tvoid
                                                 cc_default)) nil)
      (Ssequence
        (Scall None
          (Evar _sound_banks_disable (Tfunction (tuchar :: tushort :: nil)
                                       tvoid cc_default))
          ((Econst_int (Int.repr 2) tint) ::
           (Ebinop Oand
             (Ebinop Osub
               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                 (Econst_int (Int.repr 10) tint) tint)
               (Econst_int (Int.repr 1) tint) tint)
             (Eunop Onotint
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 0) tint) tint)
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 2) tint) tint) tint)
                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                   (Econst_int (Int.repr 7) tint) tint) tint) tint) tint) ::
           nil))
        (Scall None
          (Evar _fadeout_music (Tfunction (tshort :: nil) tvoid cc_default))
          ((Econst_int (Int.repr 90) tint) :: nil))))))
|}.

Definition f_receive_new_tasks := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_spTask, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'14, (tptr (Tstruct _SPTask noattr))) ::
               (_t'13, (tptr (Tstruct _SPTask noattr))) ::
               (_t'12, (tptr (Tstruct _SPTask noattr))) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _SPTask noattr))) ::
               (_t'9, (tptr (Tstruct _SPTask noattr))) ::
               (_t'8, (tptr (Tstruct _SPTask noattr))) ::
               (_t'7, (tptr (Tstruct _SPTask noattr))) ::
               (_t'6, (tptr (Tstruct _SPTask noattr))) ::
               (_t'5, (tptr (Tstruct _SPTask noattr))) ::
               (_t'4, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sloop
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _osRecvMesg (Tfunction
                              ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                               (tptr (tptr tvoid)) :: tint :: nil) tint
                              cc_default))
          ((Eaddrof (Evar _gSPTaskMesgQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Ecast
             (Eaddrof (Evar _spTask (tptr (Tstruct _SPTask noattr)))
               (tptr (tptr (Tstruct _SPTask noattr)))) (tptr (tptr tvoid))) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                       (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
          Sskip
          Sbreak))
      (Ssequence
        (Ssequence
          (Sset _t'14 (Evar _spTask (tptr (Tstruct _SPTask noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'14 (tptr (Tstruct _SPTask noattr)))
                (Tstruct _SPTask noattr)) _state tint)
            (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Sset _t'10 (Evar _spTask (tptr (Tstruct _SPTask noattr))))
          (Ssequence
            (Sset _t'11
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'10 (tptr (Tstruct _SPTask noattr)))
                      (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
                  _t (Tstruct __356 noattr)) _type tuint))
            (Sswitch (Etempvar _t'11 tuint)
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Evar _spTask (tptr (Tstruct _SPTask noattr))))
                    (Sassign
                      (Evar _sNextAudioSPTask (tptr (Tstruct _SPTask noattr)))
                      (Etempvar _t'13 (tptr (Tstruct _SPTask noattr)))))
                  Sbreak)
                (LScons (Some 1)
                  (Ssequence
                    (Ssequence
                      (Sset _t'12
                        (Evar _spTask (tptr (Tstruct _SPTask noattr))))
                      (Sassign
                        (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr)))
                        (Etempvar _t'12 (tptr (Tstruct _SPTask noattr)))))
                    Sbreak)
                  LSnil)))))))
    Sskip)
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'8 (tptr (Tstruct _SPTask noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'9
              (Evar _sNextAudioSPTask (tptr (Tstruct _SPTask noattr))))
            (Sset _t'2
              (Ecast
                (Ebinop One (Etempvar _t'9 (tptr (Tstruct _SPTask noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Evar _sNextAudioSPTask (tptr (Tstruct _SPTask noattr))))
            (Sassign
              (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr)))
              (Etempvar _t'7 (tptr (Tstruct _SPTask noattr)))))
          (Sassign (Evar _sNextAudioSPTask (tptr (Tstruct _SPTask noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'5 (tptr (Tstruct _SPTask noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'6
              (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr))))
            (Sset _t'3
              (Ecast
                (Ebinop One (Etempvar _t'6 (tptr (Tstruct _SPTask noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr))))
            (Sassign
              (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr)))
              (Etempvar _t'4 (tptr (Tstruct _SPTask noattr)))))
          (Sassign (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        Sskip))))
|}.

Definition f_start_sptask := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_taskType, tint) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'5, (tptr (Tstruct _SPTask noattr))) ::
               (_t'4, (tptr (Tstruct _SPTask noattr))) ::
               (_t'3, (tptr (Tstruct _SPTask noattr))) ::
               (_t'2, (tptr (Tstruct _SPTask noattr))) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _taskType tint)
                 (Econst_int (Int.repr 2) tint) tint)
    (Ssequence
      (Sset _t'5 (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr))))
      (Sassign (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr)))
        (Etempvar _t'5 (tptr (Tstruct _SPTask noattr)))))
    (Ssequence
      (Sset _t'4
        (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
      (Sassign (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr)))
        (Etempvar _t'4 (tptr (Tstruct _SPTask noattr))))))
  (Ssequence
    (Ssequence
      (Sset _t'3 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
      (Scall None
        (Evar _osSpTaskLoad (Tfunction ((tptr (Tunion __358 noattr)) :: nil)
                              tvoid cc_default))
        ((Eaddrof
           (Efield
             (Ederef (Etempvar _t'3 (tptr (Tstruct _SPTask noattr)))
               (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
           (tptr (Tunion __358 noattr))) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
        (Scall None
          (Evar _osSpTaskStartGo (Tfunction
                                   ((tptr (Tunion __358 noattr)) :: nil)
                                   tvoid cc_default))
          ((Eaddrof
             (Efield
               (Ederef (Etempvar _t'2 (tptr (Tstruct _SPTask noattr)))
                 (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
             (tptr (Tunion __358 noattr))) :: nil)))
      (Ssequence
        (Sset _t'1 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
              (Tstruct _SPTask noattr)) _state tint)
          (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_interrupt_gfx_sptask := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _SPTask noattr))) :: (_t'2, tuint) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
  (Ssequence
    (Sset _t'2
      (Efield
        (Efield
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
              (Tstruct _SPTask noattr)) _task (Tunion __358 noattr)) _t
          (Tstruct __356 noattr)) _type tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _SPTask noattr)))
                (Tstruct _SPTask noattr)) _state tint)
            (Econst_int (Int.repr 2) tint)))
        (Scall None (Evar _osSpTaskYield (Tfunction nil tvoid cc_default))
          nil))
      Sskip)))
|}.

Definition f_start_gfx_sptask := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) ::
               (_t'6, (tptr (Tstruct _SPTask noattr))) ::
               (_t'5, (tptr (Tstruct _SPTask noattr))) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
      (Sifthenelse (Ebinop Oeq
                     (Etempvar _t'5 (tptr (Tstruct _SPTask noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'6
            (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
          (Sset _t'1
            (Ecast
              (Ebinop One (Etempvar _t'6 (tptr (Tstruct _SPTask noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
              tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'3
          (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _SPTask noattr)))
                (Tstruct _SPTask noattr)) _state tint))
          (Sset _t'2
            (Ecast
              (Ebinop Oeq (Etempvar _t'4 tint) (Econst_int (Int.repr 0) tint)
                tint) tbool))))
      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Scall None
        (Evar _profiler_log_gfx_time (Tfunction (tint :: nil) tvoid
                                       cc_default))
        ((Econst_int (Int.repr 0) tint) :: nil))
      (Scall None
        (Evar _start_sptask (Tfunction (tint :: nil) tvoid cc_default))
        ((Econst_int (Int.repr 1) tint) :: nil)))
    Sskip))
|}.

Definition f_pretend_audio_sptask_done := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, (tptr (Tstruct _SPTask noattr))) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr))))
    (Sassign (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr)))
      (Etempvar _t'2 (tptr (Tstruct _SPTask noattr)))))
  (Ssequence
    (Ssequence
      (Sset _t'1 (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
            (Tstruct _SPTask noattr)) _state tint)
        (Econst_int (Int.repr 1) tint)))
    (Scall None
      (Evar _osSendMesg (Tfunction
                          ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                           (tptr tvoid) :: tint :: nil) tint cc_default))
      ((Eaddrof (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
         (tptr (Tstruct _OSMesgQueue_s noattr))) ::
       (Ecast (Econst_int (Int.repr 100) tint) (tptr tvoid)) ::
       (Econst_int (Int.repr 0) tint) :: nil))))
|}.

Definition f_handle_vblank := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'22, tuint) ::
               (_t'21, tschar) :: (_t'20, tschar) :: (_t'19, tschar) ::
               (_t'18, (tptr (Tstruct _SPTask noattr))) ::
               (_t'17, (tptr (Tstruct _SPTask noattr))) ::
               (_t'16, (tptr (Tstruct _SPTask noattr))) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _SPTask noattr))) ::
               (_t'13, (tptr (Tstruct _SPTask noattr))) ::
               (_t'12, (tptr tvoid)) ::
               (_t'11, (tptr (Tstruct _VblankHandler noattr))) ::
               (_t'10, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'9, (tptr (Tstruct _VblankHandler noattr))) ::
               (_t'8, (tptr (Tstruct _VblankHandler noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _VblankHandler noattr))) ::
               (_t'5, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'4, (tptr (Tstruct _VblankHandler noattr))) ::
               (_t'3, (tptr (Tstruct _VblankHandler noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _stub_main_3 (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Ssequence
      (Sset _t'22 (Evar _gNumVblanks tuint))
      (Sassign (Evar _gNumVblanks tuint)
        (Ebinop Oadd (Etempvar _t'22 tuint) (Econst_int (Int.repr 1) tint)
          tuint)))
    (Ssequence
      (Ssequence
        (Sset _t'20 (Evar _gResetTimer tschar))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'20 tschar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'21 (Evar _gResetTimer tschar))
            (Sassign (Evar _gResetTimer tschar)
              (Ebinop Oadd (Etempvar _t'21 tschar)
                (Econst_int (Int.repr 1) tint) tint)))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _receive_new_tasks (Tfunction nil tvoid cc_default)) nil)
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'13 (tptr (Tstruct _SPTask noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _t'18
                  (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'18 (tptr (Tstruct _SPTask noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Scall None
                    (Evar _interrupt_gfx_sptask (Tfunction nil tvoid
                                                  cc_default)) nil)
                  (Ssequence
                    (Scall None
                      (Evar _profiler_log_vblank_time (Tfunction nil tvoid
                                                        cc_default)) nil)
                    (Ssequence
                      (Sset _t'19 (Evar _sAudioEnabled tschar))
                      (Sifthenelse (Etempvar _t'19 tschar)
                        (Scall None
                          (Evar _start_sptask (Tfunction (tint :: nil) tvoid
                                                cc_default))
                          ((Econst_int (Int.repr 2) tint) :: nil))
                        (Scall None
                          (Evar _pretend_audio_sptask_done (Tfunction nil
                                                             tvoid
                                                             cc_default))
                          nil))))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
                    (Sifthenelse (Ebinop Oeq
                                   (Etempvar _t'16 (tptr (Tstruct _SPTask noattr)))
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     (tptr tvoid)) tint)
                      (Ssequence
                        (Sset _t'17
                          (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
                        (Sset _t'1
                          (Ecast
                            (Ebinop One
                              (Etempvar _t'17 (tptr (Tstruct _SPTask noattr)))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid)) tint) tbool)))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Ssequence
                      (Sset _t'14
                        (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _t'14 (tptr (Tstruct _SPTask noattr)))
                              (Tstruct _SPTask noattr)) _state tint))
                        (Sset _t'2
                          (Ecast
                            (Ebinop One (Etempvar _t'15 tint)
                              (Econst_int (Int.repr 3) tint) tint) tbool))))
                    (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Ssequence
                    (Scall None
                      (Evar _profiler_log_gfx_time (Tfunction (tint :: nil)
                                                     tvoid cc_default))
                      ((Econst_int (Int.repr 0) tint) :: nil))
                    (Scall None
                      (Evar _start_sptask (Tfunction (tint :: nil) tvoid
                                            cc_default))
                      ((Econst_int (Int.repr 1) tint) :: nil)))
                  Sskip))))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Evar _gVblankHandler1 (tptr (Tstruct _VblankHandler noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'8 (tptr (Tstruct _VblankHandler noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'9
                    (Evar _gVblankHandler1 (tptr (Tstruct _VblankHandler noattr))))
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _VblankHandler noattr)))
                          (Tstruct _VblankHandler noattr)) _queue
                        (tptr (Tstruct _OSMesgQueue_s noattr))))
                    (Ssequence
                      (Sset _t'11
                        (Evar _gVblankHandler1 (tptr (Tstruct _VblankHandler noattr))))
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _t'11 (tptr (Tstruct _VblankHandler noattr)))
                              (Tstruct _VblankHandler noattr)) _msg
                            (tptr tvoid)))
                        (Scall None
                          (Evar _osSendMesg (Tfunction
                                              ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                               (tptr tvoid) :: tint :: nil)
                                              tint cc_default))
                          ((Etempvar _t'10 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                           (Etempvar _t'12 (tptr tvoid)) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))))
                Sskip))
            (Ssequence
              (Sset _t'3
                (Evar _gVblankHandler2 (tptr (Tstruct _VblankHandler noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'3 (tptr (Tstruct _VblankHandler noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'4
                    (Evar _gVblankHandler2 (tptr (Tstruct _VblankHandler noattr))))
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _VblankHandler noattr)))
                          (Tstruct _VblankHandler noattr)) _queue
                        (tptr (Tstruct _OSMesgQueue_s noattr))))
                    (Ssequence
                      (Sset _t'6
                        (Evar _gVblankHandler2 (tptr (Tstruct _VblankHandler noattr))))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _VblankHandler noattr)))
                              (Tstruct _VblankHandler noattr)) _msg
                            (tptr tvoid)))
                        (Scall None
                          (Evar _osSendMesg (Tfunction
                                              ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                               (tptr tvoid) :: tint :: nil)
                                              tint cc_default))
                          ((Etempvar _t'5 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                           (Etempvar _t'7 (tptr tvoid)) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))))
                Sskip))))))))
|}.

Definition f_handle_sp_complete := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_curSPTask, (tptr (Tstruct _SPTask noattr))) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'13, tschar) ::
               (_t'12, tint) :: (_t'11, (tptr (Tstruct _SPTask noattr))) ::
               (_t'10, (tptr (Tstruct _SPTask noattr))) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _SPTask noattr))) ::
               (_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'5, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'4, tuint) :: (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _curSPTask (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr))))
  (Ssequence
    (Sassign (Evar _gActiveSPTask (tptr (Tstruct _SPTask noattr)))
      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
            (Tstruct _SPTask noattr)) _state tint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _osSpTaskYielded (Tfunction
                                       ((tptr (Tunion __358 noattr)) :: nil)
                                       tuint cc_default))
              ((Eaddrof
                 (Efield
                   (Ederef
                     (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                     (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
                 (tptr (Tunion __358 noattr))) :: nil))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                      (Tstruct _SPTask noattr)) _state tint)
                  (Econst_int (Int.repr 3) tint))
                (Scall None
                  (Evar _profiler_log_gfx_time (Tfunction (tint :: nil) tvoid
                                                 cc_default))
                  ((Econst_int (Int.repr 1) tint) :: nil)))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _profiler_log_vblank_time (Tfunction nil tvoid
                                                cc_default)) nil)
            (Ssequence
              (Sset _t'13 (Evar _sAudioEnabled tschar))
              (Sifthenelse (Etempvar _t'13 tschar)
                (Scall None
                  (Evar _start_sptask (Tfunction (tint :: nil) tvoid
                                        cc_default))
                  ((Econst_int (Int.repr 2) tint) :: nil))
                (Scall None
                  (Evar _pretend_audio_sptask_done (Tfunction nil tvoid
                                                     cc_default)) nil)))))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                (Tstruct _SPTask noattr)) _state tint)
            (Econst_int (Int.repr 3) tint))
          (Ssequence
            (Sset _t'4
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                      (Tstruct _SPTask noattr)) _task (Tunion __358 noattr))
                  _t (Tstruct __356 noattr)) _type tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _profiler_log_vblank_time (Tfunction nil tvoid
                                                    cc_default)) nil)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
                      (Sifthenelse (Ebinop One
                                     (Etempvar _t'10 (tptr (Tstruct _SPTask noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Sset _t'11
                            (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _t'11 (tptr (Tstruct _SPTask noattr)))
                                  (Tstruct _SPTask noattr)) _state tint))
                            (Sset _t'2
                              (Ecast
                                (Ebinop One (Etempvar _t'12 tint)
                                  (Econst_int (Int.repr 3) tint) tint) tbool))))
                        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'2 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'8
                            (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
                          (Ssequence
                            (Sset _t'9
                              (Efield
                                (Ederef
                                  (Etempvar _t'8 (tptr (Tstruct _SPTask noattr)))
                                  (Tstruct _SPTask noattr)) _state tint))
                            (Sifthenelse (Ebinop One (Etempvar _t'9 tint)
                                           (Econst_int (Int.repr 2) tint)
                                           tint)
                              (Scall None
                                (Evar _profiler_log_gfx_time (Tfunction
                                                               (tint :: nil)
                                                               tvoid
                                                               cc_default))
                                ((Econst_int (Int.repr 0) tint) :: nil))
                              Sskip)))
                        (Scall None
                          (Evar _start_sptask (Tfunction (tint :: nil) tvoid
                                                cc_default))
                          ((Econst_int (Int.repr 1) tint) :: nil)))
                      Sskip))
                  (Ssequence
                    (Sassign
                      (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr)))
                      (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                            (Tstruct _SPTask noattr)) _msgqueue
                          (tptr (Tstruct _OSMesgQueue_s noattr))))
                      (Sifthenelse (Ebinop One
                                     (Etempvar _t'5 (tptr (Tstruct _OSMesgQueue_s noattr)))
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       (tptr tvoid)) tint)
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                                (Tstruct _SPTask noattr)) _msgqueue
                              (tptr (Tstruct _OSMesgQueue_s noattr))))
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Etempvar _curSPTask (tptr (Tstruct _SPTask noattr)))
                                  (Tstruct _SPTask noattr)) _msg
                                (tptr tvoid)))
                            (Scall None
                              (Evar _osSendMesg (Tfunction
                                                  ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                                   (tptr tvoid) :: tint ::
                                                   nil) tint cc_default))
                              ((Etempvar _t'6 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                               (Etempvar _t'7 (tptr tvoid)) ::
                               (Econst_int (Int.repr 0) tint) :: nil))))
                        Sskip)))))
              (Scall None
                (Evar _profiler_log_gfx_time (Tfunction (tint :: nil) tvoid
                                               cc_default))
                ((Econst_int (Int.repr 1) tint) :: nil)))))))))
|}.

Definition f_handle_dp_complete := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'7, (tptr tvoid)) ::
               (_t'6, (tptr (Tstruct _SPTask noattr))) ::
               (_t'5, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'4, (tptr (Tstruct _SPTask noattr))) ::
               (_t'3, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
               (_t'2, (tptr (Tstruct _SPTask noattr))) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _t'2 (tptr (Tstruct _SPTask noattr)))
            (Tstruct _SPTask noattr)) _msgqueue
          (tptr (Tstruct _OSMesgQueue_s noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'3 (tptr (Tstruct _OSMesgQueue_s noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'4
            (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _t'4 (tptr (Tstruct _SPTask noattr)))
                  (Tstruct _SPTask noattr)) _msgqueue
                (tptr (Tstruct _OSMesgQueue_s noattr))))
            (Ssequence
              (Sset _t'6
                (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _t'6 (tptr (Tstruct _SPTask noattr)))
                      (Tstruct _SPTask noattr)) _msg (tptr tvoid)))
                (Scall None
                  (Evar _osSendMesg (Tfunction
                                      ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                       (tptr tvoid) :: tint :: nil) tint
                                      cc_default))
                  ((Etempvar _t'5 (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                   (Etempvar _t'7 (tptr tvoid)) ::
                   (Econst_int (Int.repr 0) tint) :: nil))))))
        Sskip)))
  (Ssequence
    (Scall None
      (Evar _profiler_log_gfx_time (Tfunction (tint :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 2) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'1
          (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
              (Tstruct _SPTask noattr)) _state tint)
          (Econst_int (Int.repr 4) tint)))
      (Sassign (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))))
|}.

Definition f_thread3_main := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, (tptr tvoid)) :: nil);
  fn_vars := ((_msg, (tptr tvoid)) :: nil);
  fn_temps := ((_t'1, (tptr tvoid)) :: nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _setup_mesg_queues (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None (Evar _alloc_pool (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None
        (Evar _load_engine_code_segment (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Scall None
          (Evar _create_thread (Tfunction
                                 ((tptr (Tstruct _OSThread_s noattr)) ::
                                  tint ::
                                  (tptr (Tfunction ((tptr tvoid) :: nil)
                                          tvoid cc_default)) ::
                                  (tptr tvoid) :: (tptr tvoid) :: tint ::
                                  nil) tvoid cc_default))
          ((Eaddrof (Evar _gSoundThread (Tstruct _OSThread_s noattr))
             (tptr (Tstruct _OSThread_s noattr))) ::
           (Econst_int (Int.repr 4) tint) ::
           (Evar _thread4_sound (Tfunction ((tptr tvoid) :: nil) tvoid
                                  cc_default)) ::
           (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
           (Ebinop Oadd (Evar _gThread4Stack (tarray tuchar 0))
             (Econst_int (Int.repr 8192) tint) (tptr tuchar)) ::
           (Econst_int (Int.repr 20) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _osStartThread (Tfunction
                                   ((tptr (Tstruct _OSThread_s noattr)) ::
                                    nil) tvoid cc_default))
            ((Eaddrof (Evar _gSoundThread (Tstruct _OSThread_s noattr))
               (tptr (Tstruct _OSThread_s noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _create_thread (Tfunction
                                     ((tptr (Tstruct _OSThread_s noattr)) ::
                                      tint ::
                                      (tptr (Tfunction ((tptr tvoid) :: nil)
                                              tvoid cc_default)) ::
                                      (tptr tvoid) :: (tptr tvoid) :: tint ::
                                      nil) tvoid cc_default))
              ((Eaddrof (Evar _gGameLoopThread (Tstruct _OSThread_s noattr))
                 (tptr (Tstruct _OSThread_s noattr))) ::
               (Econst_int (Int.repr 5) tint) ::
               (Evar _thread5_game_loop (Tfunction ((tptr tvoid) :: nil)
                                          tvoid cc_default)) ::
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
               (Ebinop Oadd (Evar _gThread5Stack (tarray tuchar 0))
                 (Econst_int (Int.repr 8192) tint) (tptr tuchar)) ::
               (Econst_int (Int.repr 10) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _osStartThread (Tfunction
                                       ((tptr (Tstruct _OSThread_s noattr)) ::
                                        nil) tvoid cc_default))
                ((Eaddrof
                   (Evar _gGameLoopThread (Tstruct _OSThread_s noattr))
                   (tptr (Tstruct _OSThread_s noattr))) :: nil))
              (Sloop
                (Ssequence
                  Sskip
                  (Ssequence
                    (Scall None
                      (Evar _osRecvMesg (Tfunction
                                          ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                           (tptr (tptr tvoid)) :: tint ::
                                           nil) tint cc_default))
                      ((Eaddrof
                         (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                         (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                       (Eaddrof (Evar _msg (tptr tvoid)) (tptr (tptr tvoid))) ::
                       (Econst_int (Int.repr 1) tint) :: nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'1 (Evar _msg (tptr tvoid)))
                        (Sswitch (Ecast (Etempvar _t'1 (tptr tvoid)) tuint)
                          (LScons (Some 102)
                            (Ssequence
                              (Scall None
                                (Evar _handle_vblank (Tfunction nil tvoid
                                                       cc_default)) nil)
                              Sbreak)
                            (LScons (Some 100)
                              (Ssequence
                                (Scall None
                                  (Evar _handle_sp_complete (Tfunction nil
                                                              tvoid
                                                              cc_default))
                                  nil)
                                Sbreak)
                              (LScons (Some 101)
                                (Ssequence
                                  (Scall None
                                    (Evar _handle_dp_complete (Tfunction nil
                                                                tvoid
                                                                cc_default))
                                    nil)
                                  Sbreak)
                                (LScons (Some 103)
                                  (Ssequence
                                    (Scall None
                                      (Evar _start_gfx_sptask (Tfunction nil
                                                                tvoid
                                                                cc_default))
                                      nil)
                                    Sbreak)
                                  (LScons (Some 104)
                                    (Ssequence
                                      (Scall None
                                        (Evar _handle_nmi_request (Tfunction
                                                                    nil tvoid
                                                                    cc_default))
                                        nil)
                                      Sbreak)
                                    LSnil)))))))
                      (Scall None
                        (Evar _stub_main_2 (Tfunction nil tvoid cc_default))
                        nil))))
                Sskip))))))))
|}.

Definition f_set_vblank_handler := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_index, tint) ::
                (_handler, (tptr (Tstruct _VblankHandler noattr))) ::
                (_queue, (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                (_msg, (tptr (tptr tvoid))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _handler (tptr (Tstruct _VblankHandler noattr)))
        (Tstruct _VblankHandler noattr)) _queue
      (tptr (Tstruct _OSMesgQueue_s noattr)))
    (Etempvar _queue (tptr (Tstruct _OSMesgQueue_s noattr))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _handler (tptr (Tstruct _VblankHandler noattr)))
          (Tstruct _VblankHandler noattr)) _msg (tptr tvoid))
      (Etempvar _msg (tptr (tptr tvoid))))
    (Sswitch (Etempvar _index tint)
      (LScons (Some 1)
        (Ssequence
          (Sassign
            (Evar _gVblankHandler1 (tptr (Tstruct _VblankHandler noattr)))
            (Etempvar _handler (tptr (Tstruct _VblankHandler noattr))))
          Sbreak)
        (LScons (Some 2)
          (Ssequence
            (Sassign
              (Evar _gVblankHandler2 (tptr (Tstruct _VblankHandler noattr)))
              (Etempvar _handler (tptr (Tstruct _VblankHandler noattr))))
            Sbreak)
          LSnil)))))
|}.

Definition f_send_sp_task_message := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_msg, (tptr (tptr tvoid))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default))
    nil)
  (Scall None
    (Evar _osSendMesg (Tfunction
                        ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                         (tptr tvoid) :: tint :: nil) tint cc_default))
    ((Eaddrof (Evar _gSPTaskMesgQueue (Tstruct _OSMesgQueue_s noattr))
       (tptr (Tstruct _OSMesgQueue_s noattr))) ::
     (Etempvar _msg (tptr (tptr tvoid))) :: (Econst_int (Int.repr 0) tint) ::
     nil)))
|}.

Definition f_dispatch_audio_sptask := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_spTask, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sAudioEnabled tschar))
    (Sifthenelse (Etempvar _t'2 tschar)
      (Sset _t'1
        (Ecast
          (Ebinop One (Etempvar _spTask (tptr (Tstruct _SPTask noattr)))
            (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint) tbool))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Scall None
        (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default)) nil)
      (Scall None
        (Evar _osSendMesg (Tfunction
                            ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                             (tptr tvoid) :: tint :: nil) tint cc_default))
        ((Eaddrof (Evar _gSPTaskMesgQueue (Tstruct _OSMesgQueue_s noattr))
           (tptr (Tstruct _OSMesgQueue_s noattr))) ::
         (Etempvar _spTask (tptr (Tstruct _SPTask noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil)))
    Sskip))
|}.

Definition f_exec_display_list := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_spTask, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Sifthenelse (Ebinop One (Etempvar _spTask (tptr (Tstruct _SPTask noattr)))
               (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
  (Ssequence
    (Scall None (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _spTask (tptr (Tstruct _SPTask noattr)))
            (Tstruct _SPTask noattr)) _state tint)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sset _t'1
          (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sassign
              (Evar _sCurrentDisplaySPTask (tptr (Tstruct _SPTask noattr)))
              (Etempvar _spTask (tptr (Tstruct _SPTask noattr))))
            (Ssequence
              (Sassign
                (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Scall None
                (Evar _osSendMesg (Tfunction
                                    ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                     (tptr tvoid) :: tint :: nil) tint
                                    cc_default))
                ((Eaddrof
                   (Evar _gIntrMesgQueue (Tstruct _OSMesgQueue_s noattr))
                   (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                 (Ecast (Econst_int (Int.repr 103) tint) (tptr tvoid)) ::
                 (Econst_int (Int.repr 0) tint) :: nil))))
          (Sassign (Evar _sNextDisplaySPTask (tptr (Tstruct _SPTask noattr)))
            (Etempvar _spTask (tptr (Tstruct _SPTask noattr))))))))
  Sskip)
|}.

Definition f_turn_on_audio := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign (Evar _sAudioEnabled tschar) (Econst_int (Int.repr 1) tint))
|}.

Definition f_turn_off_audio := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sAudioEnabled tschar) (Econst_int (Int.repr 0) tint))
  (Sloop
    (Ssequence
      (Sset _t'1 (Evar _sCurrentAudioSPTask (tptr (Tstruct _SPTask noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        Sskip
        Sbreak))
    Sskip))
|}.

Definition f_thread1_idle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp24, tint) :: (_t'1, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _sp24 (Evar _osTvType tuint))
  (Ssequence
    (Scall None
      (Evar _osCreateViManager (Tfunction (tint :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 254) tint) :: nil))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _sp24 tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Scall None
          (Evar _osViSetMode (Tfunction
                               ((tptr (Tstruct __394 noattr)) :: nil) tvoid
                               cc_default))
          ((Ebinop Oadd
             (Evar _osViModeTable (tarray (Tstruct __394 noattr) 0))
             (Econst_int (Int.repr 2) tint) (tptr (Tstruct __394 noattr))) ::
           nil))
        (Scall None
          (Evar _osViSetMode (Tfunction
                               ((tptr (Tstruct __394 noattr)) :: nil) tvoid
                               cc_default))
          ((Ebinop Oadd
             (Evar _osViModeTable (tarray (Tstruct __394 noattr) 0))
             (Econst_int (Int.repr 16) tint) (tptr (Tstruct __394 noattr))) ::
           nil)))
      (Ssequence
        (Scall None
          (Evar _osViBlack (Tfunction (tuchar :: nil) tvoid cc_default))
          ((Econst_int (Int.repr 1) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _osViSetSpecialFeatures (Tfunction (tuint :: nil) tvoid
                                            cc_default))
            ((Econst_int (Int.repr 64) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _osViSetSpecialFeatures (Tfunction (tuint :: nil) tvoid
                                              cc_default))
              ((Econst_int (Int.repr 2) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _osCreatePiManager (Tfunction
                                           (tint ::
                                            (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                            (tptr (tptr tvoid)) :: tint ::
                                            nil) tvoid cc_default))
                ((Econst_int (Int.repr 150) tint) ::
                 (Eaddrof
                   (Evar _gPIMesgQueue (Tstruct _OSMesgQueue_s noattr))
                   (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                 (Evar _gPIMesgBuf (tarray (tptr tvoid) 32)) ::
                 (Ecast
                   (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 32) tuint)
                     (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _create_thread (Tfunction
                                         ((tptr (Tstruct _OSThread_s noattr)) ::
                                          tint ::
                                          (tptr (Tfunction
                                                  ((tptr tvoid) :: nil) tvoid
                                                  cc_default)) ::
                                          (tptr tvoid) :: (tptr tvoid) ::
                                          tint :: nil) tvoid cc_default))
                  ((Eaddrof (Evar _gMainThread (Tstruct _OSThread_s noattr))
                     (tptr (Tstruct _OSThread_s noattr))) ::
                   (Econst_int (Int.repr 3) tint) ::
                   (Evar _thread3_main (Tfunction ((tptr tvoid) :: nil) tvoid
                                         cc_default)) ::
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                   (Ebinop Oadd (Evar _gThread3Stack (tarray tuchar 0))
                     (Econst_int (Int.repr 8192) tint) (tptr tuchar)) ::
                   (Econst_int (Int.repr 100) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'1 (Evar _D_8032C650 tschar))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tschar)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Scall None
                        (Evar _osStartThread (Tfunction
                                               ((tptr (Tstruct _OSThread_s noattr)) ::
                                                nil) tvoid cc_default))
                        ((Eaddrof
                           (Evar _gMainThread (Tstruct _OSThread_s noattr))
                           (tptr (Tstruct _OSThread_s noattr))) :: nil))
                      Sskip))
                  (Ssequence
                    (Scall None
                      (Evar _osSetThreadPri (Tfunction
                                              ((tptr (Tstruct _OSThread_s noattr)) ::
                                               tint :: nil) tvoid cc_default))
                      ((Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sloop Sskip Sskip)))))))))))
|}.

Definition f_main_func := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_filler, (tarray tuchar 64)) :: nil);
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None (Evar _osInitialize (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None (Evar _stub_main_1 (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None
        (Evar _create_thread (Tfunction
                               ((tptr (Tstruct _OSThread_s noattr)) ::
                                tint ::
                                (tptr (Tfunction ((tptr tvoid) :: nil) tvoid
                                        cc_default)) :: (tptr tvoid) ::
                                (tptr tvoid) :: tint :: nil) tvoid
                               cc_default))
        ((Eaddrof (Evar _gIdleThread (Tstruct _OSThread_s noattr))
           (tptr (Tstruct _OSThread_s noattr))) ::
         (Econst_int (Int.repr 1) tint) ::
         (Evar _thread1_idle (Tfunction ((tptr tvoid) :: nil) tvoid
                               cc_default)) ::
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) ::
         (Ebinop Oadd (Evar _gIdleThreadStack (tarray tuchar 0))
           (Econst_int (Int.repr 2048) tint) (tptr tuchar)) ::
         (Econst_int (Int.repr 100) tint) :: nil))
      (Scall None
        (Evar _osStartThread (Tfunction
                               ((tptr (Tstruct _OSThread_s noattr)) :: nil)
                               tvoid cc_default))
        ((Eaddrof (Evar _gIdleThread (Tstruct _OSThread_s noattr))
           (tptr (Tstruct _OSThread_s noattr))) :: nil)))))
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
 Composite __390 Struct
   (Member_plain _ctrl tuint :: Member_plain _width tuint ::
    Member_plain _burst tuint :: Member_plain _vSync tuint ::
    Member_plain _hSync tuint :: Member_plain _leap tuint ::
    Member_plain _hStart tuint :: Member_plain _xScale tuint ::
    Member_plain _vCurrent tuint :: nil)
   noattr ::
 Composite __392 Struct
   (Member_plain _origin tuint :: Member_plain _yScale tuint ::
    Member_plain _vStart tuint :: Member_plain _vBurst tuint ::
    Member_plain _vIntr tuint :: nil)
   noattr ::
 Composite __394 Struct
   (Member_plain _type tuchar ::
    Member_plain _comRegs (Tstruct __390 noattr) ::
    Member_plain _fldRegs (tarray (Tstruct __392 noattr) 2) :: nil)
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
 (_osInitialize,
   Gfun(External (EF_external "osInitialize"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osCreateThread,
   Gfun(External (EF_external "osCreateThread"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xptr :: AST.Xptr ::
                      AST.Xptr :: AST.Xint :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _OSThread_s noattr)) :: tint ::
      (tptr (Tfunction ((tptr tvoid) :: nil) tvoid cc_default)) ::
      (tptr tvoid) :: (tptr tvoid) :: tint :: nil) tvoid cc_default)) ::
 (_osSetThreadPri,
   Gfun(External (EF_external "osSetThreadPri"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _OSThread_s noattr)) :: tint :: nil) tvoid cc_default)) ::
 (_osStartThread,
   Gfun(External (EF_external "osStartThread"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _OSThread_s noattr)) :: nil) tvoid cc_default)) ::
 (_osCreateMesgQueue,
   Gfun(External (EF_external "osCreateMesgQueue"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tvoid cc_default)) ::
 (_osSendMesg,
   Gfun(External (EF_external "osSendMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr tvoid) :: tint :: nil)
     tint cc_default)) ::
 (_osRecvMesg,
   Gfun(External (EF_external "osRecvMesg"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) ::
      tint :: nil) tint cc_default)) ::
 (_osSetEventMesg,
   Gfun(External (EF_external "osSetEventMesg"
                   (mksignature (AST.Xint :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tuint :: (tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr tvoid) :: nil)
     tvoid cc_default)) ::
 (_osSetTime,
   Gfun(External (EF_external "osSetTime"
                   (mksignature (AST.Xlong :: nil) AST.Xvoid cc_default))
     (tulong :: nil) tvoid cc_default)) ::
 (_osMapTLB,
   Gfun(External (EF_external "osMapTLB"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint ::
                      AST.Xint :: AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: tuint :: (tptr tvoid) :: tuint :: tuint :: tint :: nil) tvoid
     cc_default)) ::
 (_osUnmapTLBAll,
   Gfun(External (EF_external "osUnmapTLBAll"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osSpTaskLoad,
   Gfun(External (EF_external "osSpTaskLoad"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tunion __358 noattr)) :: nil) tvoid cc_default)) ::
 (_osSpTaskStartGo,
   Gfun(External (EF_external "osSpTaskStartGo"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tunion __358 noattr)) :: nil) tvoid cc_default)) ::
 (_osSpTaskYield,
   Gfun(External (EF_external "osSpTaskYield"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osSpTaskYielded,
   Gfun(External (EF_external "osSpTaskYielded"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tunion __358 noattr)) :: nil) tuint cc_default)) ::
 (_osWritebackDCacheAll,
   Gfun(External (EF_external "osWritebackDCacheAll"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osCreateViManager,
   Gfun(External (EF_external "osCreateViManager"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_osViSetMode,
   Gfun(External (EF_external "osViSetMode"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct __394 noattr)) :: nil) tvoid cc_default)) ::
 (_osViSetEvent,
   Gfun(External (EF_external "osViSetEvent"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr tvoid) :: tuint :: nil)
     tvoid cc_default)) ::
 (_osViBlack,
   Gfun(External (EF_external "osViBlack"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xvoid
                     cc_default)) (tuchar :: nil) tvoid cc_default)) ::
 (_osViSetSpecialFeatures,
   Gfun(External (EF_external "osViSetSpecialFeatures"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_osViModeTable, Gvar v_osViModeTable) ::
 (_osCreatePiManager,
   Gfun(External (EF_external "osCreatePiManager"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: (tptr (Tstruct _OSMesgQueue_s noattr)) ::
      (tptr (tptr tvoid)) :: tint :: nil) tvoid cc_default)) ::
 (_osTvType, Gvar v_osTvType) ::
 (_sprintf,
   Gfun(External (EF_external "sprintf"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xint
                     {|cc_vararg:=(Some 2); cc_unproto:=false; cc_structret:=false|}))
     ((tptr tuchar) :: (tptr tuchar) :: nil) tint
     {|cc_vararg:=(Some 2); cc_unproto:=false; cc_structret:=false|})) ::
 (_stop_sounds_in_continuous_banks,
   Gfun(External (EF_external "stop_sounds_in_continuous_banks"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_sound_banks_disable,
   Gfun(External (EF_external "sound_banks_disable"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) :: (_gEffectsMemoryPool, Gvar v_gEffectsMemoryPool) ::
 (_main_pool_init,
   Gfun(External (EF_external "main_pool_init"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) ((tptr tvoid) :: (tptr tvoid) :: nil) tvoid
     cc_default)) ::
 (_load_engine_code_segment,
   Gfun(External (EF_external "load_engine_code_segment"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_mem_pool_init,
   Gfun(External (EF_external "mem_pool_init"
                   (mksignature (AST.Xint :: AST.Xint :: nil) AST.Xptr
                     cc_default)) (tuint :: tuint :: nil)
     (tptr (Tstruct _MemoryPool noattr)) cc_default)) ::
 (_gPlayer3Controller, Gvar v_gPlayer3Controller) ::
 (_thread5_game_loop,
   Gfun(External (EF_external "thread5_game_loop"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (_fadeout_music,
   Gfun(External (EF_external "fadeout_music"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_thread4_sound,
   Gfun(External (EF_external "thread4_sound"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr tvoid) :: nil) tvoid cc_default)) ::
 (_profiler_log_gfx_time,
   Gfun(External (EF_external "profiler_log_gfx_time"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_profiler_log_vblank_time,
   Gfun(External (EF_external "profiler_log_vblank_time"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_gIdleThreadStack, Gvar v_gIdleThreadStack) ::
 (_gThread3Stack, Gvar v_gThread3Stack) ::
 (_gThread4Stack, Gvar v_gThread4Stack) ::
 (_gThread5Stack, Gvar v_gThread5Stack) ::
 (_D_80339210, Gvar v_D_80339210) :: (_gIdleThread, Gvar v_gIdleThread) ::
 (_gMainThread, Gvar v_gMainThread) ::
 (_gGameLoopThread, Gvar v_gGameLoopThread) ::
 (_gSoundThread, Gvar v_gSoundThread) :: (_gDmaIoMesg, Gvar v_gDmaIoMesg) ::
 (_gMainReceivedMesg, Gvar v_gMainReceivedMesg) ::
 (_gDmaMesgQueue, Gvar v_gDmaMesgQueue) ::
 (_gSIEventMesgQueue, Gvar v_gSIEventMesgQueue) ::
 (_gPIMesgQueue, Gvar v_gPIMesgQueue) ::
 (_gIntrMesgQueue, Gvar v_gIntrMesgQueue) ::
 (_gSPTaskMesgQueue, Gvar v_gSPTaskMesgQueue) ::
 (_gDmaMesgBuf, Gvar v_gDmaMesgBuf) :: (_gPIMesgBuf, Gvar v_gPIMesgBuf) ::
 (_gSIEventMesgBuf, Gvar v_gSIEventMesgBuf) ::
 (_gIntrMesgBuf, Gvar v_gIntrMesgBuf) ::
 (_gUnknownMesgBuf, Gvar v_gUnknownMesgBuf) ::
 (_gVblankHandler1, Gvar v_gVblankHandler1) ::
 (_gVblankHandler2, Gvar v_gVblankHandler2) ::
 (_gActiveSPTask, Gvar v_gActiveSPTask) ::
 (_sCurrentAudioSPTask, Gvar v_sCurrentAudioSPTask) ::
 (_sCurrentDisplaySPTask, Gvar v_sCurrentDisplaySPTask) ::
 (_sNextAudioSPTask, Gvar v_sNextAudioSPTask) ::
 (_sNextDisplaySPTask, Gvar v_sNextDisplaySPTask) ::
 (_sAudioEnabled, Gvar v_sAudioEnabled) ::
 (_gNumVblanks, Gvar v_gNumVblanks) :: (_gResetTimer, Gvar v_gResetTimer) ::
 (_gNmiResetBarsTimer, Gvar v_gNmiResetBarsTimer) ::
 (_gDebugLevelSelect, Gvar v_gDebugLevelSelect) ::
 (_D_8032C650, Gvar v_D_8032C650) ::
 (_gShowProfiler, Gvar v_gShowProfiler) ::
 (_gShowDebugText, Gvar v_gShowDebugText) ::
 (_sProfilerKeySequence, Gvar v_sProfilerKeySequence) ::
 (_sDebugTextKeySequence, Gvar v_sDebugTextKeySequence) ::
 (_sProfilerKey, Gvar v_sProfilerKey) ::
 (_sDebugTextKey, Gvar v_sDebugTextKey) ::
 (_handle_debug_key_sequences, Gfun(Internal f_handle_debug_key_sequences)) ::
 (_unknown_main_func, Gfun(Internal f_unknown_main_func)) ::
 (_stub_main_1, Gfun(Internal f_stub_main_1)) ::
 (_stub_main_2, Gfun(Internal f_stub_main_2)) ::
 (_stub_main_3, Gfun(Internal f_stub_main_3)) ::
 (_setup_mesg_queues, Gfun(Internal f_setup_mesg_queues)) ::
 (_alloc_pool, Gfun(Internal f_alloc_pool)) ::
 (_create_thread, Gfun(Internal f_create_thread)) ::
 (_handle_nmi_request, Gfun(Internal f_handle_nmi_request)) ::
 (_receive_new_tasks, Gfun(Internal f_receive_new_tasks)) ::
 (_start_sptask, Gfun(Internal f_start_sptask)) ::
 (_interrupt_gfx_sptask, Gfun(Internal f_interrupt_gfx_sptask)) ::
 (_start_gfx_sptask, Gfun(Internal f_start_gfx_sptask)) ::
 (_pretend_audio_sptask_done, Gfun(Internal f_pretend_audio_sptask_done)) ::
 (_handle_vblank, Gfun(Internal f_handle_vblank)) ::
 (_handle_sp_complete, Gfun(Internal f_handle_sp_complete)) ::
 (_handle_dp_complete, Gfun(Internal f_handle_dp_complete)) ::
 (_thread3_main, Gfun(Internal f_thread3_main)) ::
 (_set_vblank_handler, Gfun(Internal f_set_vblank_handler)) ::
 (_send_sp_task_message, Gfun(Internal f_send_sp_task_message)) ::
 (_dispatch_audio_sptask, Gfun(Internal f_dispatch_audio_sptask)) ::
 (_exec_display_list, Gfun(Internal f_exec_display_list)) ::
 (_turn_on_audio, Gfun(Internal f_turn_on_audio)) ::
 (_turn_off_audio, Gfun(Internal f_turn_off_audio)) ::
 (_thread1_idle, Gfun(Internal f_thread1_idle)) ::
 (_main_func, Gfun(Internal f_main_func)) :: nil).

Definition public_idents : list ident :=
(_main_func :: _thread1_idle :: _turn_off_audio :: _turn_on_audio ::
 _exec_display_list :: _dispatch_audio_sptask :: _send_sp_task_message ::
 _set_vblank_handler :: _thread3_main :: _handle_dp_complete ::
 _handle_sp_complete :: _handle_vblank :: _pretend_audio_sptask_done ::
 _start_gfx_sptask :: _interrupt_gfx_sptask :: _start_sptask ::
 _receive_new_tasks :: _handle_nmi_request :: _create_thread ::
 _alloc_pool :: _setup_mesg_queues :: _stub_main_3 :: _stub_main_2 ::
 _stub_main_1 :: _unknown_main_func :: _handle_debug_key_sequences ::
 _gShowDebugText :: _gShowProfiler :: _D_8032C650 :: _gDebugLevelSelect ::
 _gNmiResetBarsTimer :: _gResetTimer :: _gNumVblanks :: _sAudioEnabled ::
 _sNextDisplaySPTask :: _sNextAudioSPTask :: _sCurrentDisplaySPTask ::
 _sCurrentAudioSPTask :: _gActiveSPTask :: _gVblankHandler2 ::
 _gVblankHandler1 :: _gUnknownMesgBuf :: _gIntrMesgBuf :: _gSIEventMesgBuf ::
 _gPIMesgBuf :: _gDmaMesgBuf :: _gSPTaskMesgQueue :: _gIntrMesgQueue ::
 _gPIMesgQueue :: _gSIEventMesgQueue :: _gDmaMesgQueue ::
 _gMainReceivedMesg :: _gDmaIoMesg :: _gSoundThread :: _gGameLoopThread ::
 _gMainThread :: _gIdleThread :: _D_80339210 :: _gThread5Stack ::
 _gThread4Stack :: _gThread3Stack :: _gIdleThreadStack ::
 _profiler_log_vblank_time :: _profiler_log_gfx_time :: _thread4_sound ::
 _fadeout_music :: _thread5_game_loop :: _gPlayer3Controller ::
 _mem_pool_init :: _load_engine_code_segment :: _main_pool_init ::
 _gEffectsMemoryPool :: _sound_banks_disable ::
 _stop_sounds_in_continuous_banks :: _sprintf :: _osTvType ::
 _osCreatePiManager :: _osViModeTable :: _osViSetSpecialFeatures ::
 _osViBlack :: _osViSetEvent :: _osViSetMode :: _osCreateViManager ::
 _osWritebackDCacheAll :: _osSpTaskYielded :: _osSpTaskYield ::
 _osSpTaskStartGo :: _osSpTaskLoad :: _osUnmapTLBAll :: _osMapTLB ::
 _osSetTime :: _osSetEventMesg :: _osRecvMesg :: _osSendMesg ::
 _osCreateMesgQueue :: _osStartThread :: _osSetThreadPri ::
 _osCreateThread :: _osInitialize :: ___builtin_debug ::
 ___builtin_sync_fetch_and_add :: ___builtin_atomic_compare_exchange ::
 ___builtin_atomic_load :: ___builtin_atomic_exchange :: ___builtin_nop ::
 ___builtin_bsel :: ___builtin_uisel64 :: ___builtin_isel64 ::
 ___builtin_uisel :: ___builtin_isel :: ___builtin_return_address ::
 ___builtin_call_frame :: ___builtin_mr :: ___builtin_set_spr64 ::
 ___builtin_get_spr64 :: ___builtin_set_spr :: ___builtin_get_spr ::
 ___builtin_dcbz :: ___builtin_icbtls :: ___builtin_dcbtls ::
 ___builtin_prefetch :: ___builtin_icbi :: ___builtin_dcbi ::
 ___builtin_dcbf :: ___builtin_trap :: ___builtin_mbar ::
 ___builtin_lwsync :: ___builtin_isync :: ___builtin_sync ::
 ___builtin_eieio :: ___builtin_write64_reversed ::
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


