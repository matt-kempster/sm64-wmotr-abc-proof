(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/audio/data.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -include pipeline/proof_n64.h (+ __stringlit_ -> __stringlit_audio_data_)
   Regenerate:  make regen   (output must be byte-identical)
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
  Definition source_file := "vendor/sm64/src/audio/data.c".
  Definition normalized := true.
End Info.

Definition _AdsrEnvelope : ident := $"AdsrEnvelope".
Definition _AudioSessionSettings : ident := $"AudioSessionSettings".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _SPTask : ident := $"SPTask".
Definition __248 : ident := $"_anon_07a69785bc06".
Definition __249 : ident := $"_anon_a9a983b34860".
Definition __251 : ident := $"_anon_4f5eb5534ceb".
Definition __253 : ident := $"_anon_f4fa7cbf403d".
Definition __356 : ident := $"_anon_eb33296dc4e6".
Definition __358 : ident := $"_anon_e6e5dd5b5d1f".
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
Definition _arg : ident := $"arg".
Definition _at : ident := $"at".
Definition _badvaddr : ident := $"badvaddr".
Definition _cause : ident := $"cause".
Definition _context : ident := $"context".
Definition _count : ident := $"count".
Definition _data_ptr : ident := $"data_ptr".
Definition _data_size : ident := $"data_size".
Definition _delay : ident := $"delay".
Definition _dram_stack : ident := $"dram_stack".
Definition _dram_stack_size : ident := $"dram_stack_size".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _first : ident := $"first".
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
Definition _frequency : ident := $"frequency".
Definition _fullqueue : ident := $"fullqueue".
Definition _gAiBufferLengths : ident := $"gAiBufferLengths".
Definition _gAiBuffers : ident := $"gAiBuffers".
Definition _gAudioCmd : ident := $"gAudioCmd".
Definition _gAudioCmdBuffers : ident := $"gAudioCmdBuffers".
Definition _gAudioCosineTable : ident := $"gAudioCosineTable".
Definition _gAudioFrameCount : ident := $"gAudioFrameCount".
Definition _gAudioGlobalsEndMarker : ident := $"gAudioGlobalsEndMarker".
Definition _gAudioHeapSize : ident := $"gAudioHeapSize".
Definition _gAudioInitPoolSize : ident := $"gAudioInitPoolSize".
Definition _gAudioLoadLock : ident := $"gAudioLoadLock".
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gAudioSessionPresets : ident := $"gAudioSessionPresets".
Definition _gAudioTask : ident := $"gAudioTask".
Definition _gAudioTaskIndex : ident := $"gAudioTaskIndex".
Definition _gAudioTasks : ident := $"gAudioTasks".
Definition _gCurrAiBufferIndex : ident := $"gCurrAiBufferIndex".
Definition _gCurrAudioFrameDmaCount : ident := $"gCurrAudioFrameDmaCount".
Definition _gDefaultEnvelope : ident := $"gDefaultEnvelope".
Definition _gDefaultPanVolume : ident := $"gDefaultPanVolume".
Definition _gDefaultShortNoteDurationTable : ident := $"gDefaultShortNoteDurationTable".
Definition _gDefaultShortNoteVelocityTable : ident := $"gDefaultShortNoteVelocityTable".
Definition _gHeadsetPanQuantization : ident := $"gHeadsetPanQuantization".
Definition _gHeadsetPanVolume : ident := $"gHeadsetPanVolume".
Definition _gNoteFrequencies : ident := $"gNoteFrequencies".
Definition _gPitchBendFrequencyScale : ident := $"gPitchBendFrequencyScale".
Definition _gStereoPanVolume : ident := $"gStereoPanVolume".
Definition _gTatumsPerBeat : ident := $"gTatumsPerBeat".
Definition _gUnused80226E58 : ident := $"gUnused80226E58".
Definition _gUnused80226E98 : ident := $"gUnused80226E98".
Definition _gUnusedCount80333EE8 : ident := $"gUnusedCount80333EE8".
Definition _gVibratoCurve : ident := $"gVibratoCurve".
Definition _gVolRampingLhs128 : ident := $"gVolRampingLhs128".
Definition _gVolRampingLhs136 : ident := $"gVolRampingLhs136".
Definition _gVolRampingLhs144 : ident := $"gVolRampingLhs144".
Definition _gVolRampingRhs128 : ident := $"gVolRampingRhs128".
Definition _gVolRampingRhs136 : ident := $"gVolRampingRhs136".
Definition _gVolRampingRhs144 : ident := $"gVolRampingRhs144".
Definition _gWaveSamples : ident := $"gWaveSamples".
Definition _gp : ident := $"gp".
Definition _hi : ident := $"hi".
Definition _id : ident := $"id".
Definition _lo : ident := $"lo".
Definition _main : ident := $"main".
Definition _maxSimultaneousNotes : ident := $"maxSimultaneousNotes".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _msgqueue : ident := $"msgqueue".
Definition _mtqueue : ident := $"mtqueue".
Definition _next : ident := $"next".
Definition _output_buff : ident := $"output_buff".
Definition _output_buff_size : ident := $"output_buff_size".
Definition _pc : ident := $"pc".
Definition _persistentBankMem : ident := $"persistentBankMem".
Definition _persistentSeqMem : ident := $"persistentSeqMem".
Definition _priority : ident := $"priority".
Definition _queue : ident := $"queue".
Definition _ra : ident := $"ra".
Definition _rcp : ident := $"rcp".
Definition _reverbDownsampleRate : ident := $"reverbDownsampleRate".
Definition _reverbGain : ident := $"reverbGain".
Definition _reverbWindowSize : ident := $"reverbWindowSize".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sSawtoothWave : ident := $"sSawtoothWave".
Definition _sSineWave : ident := $"sSineWave".
Definition _sSquareWave : ident := $"sSquareWave".
Definition _sTriangleWave : ident := $"sTriangleWave".
Definition _sUnused8033EF8 : ident := $"sUnused8033EF8".
Definition _sp : ident := $"sp".
Definition _sr : ident := $"sr".
Definition _state : ident := $"state".
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
Definition _temporaryBankMem : ident := $"temporaryBankMem".
Definition _temporarySeqMem : ident := $"temporarySeqMem".
Definition _thprof : ident := $"thprof".
Definition _time : ident := $"time".
Definition _tlnext : ident := $"tlnext".
Definition _type : ident := $"type".
Definition _ucode : ident := $"ucode".
Definition _ucode_boot : ident := $"ucode_boot".
Definition _ucode_boot_size : ident := $"ucode_boot_size".
Definition _ucode_data : ident := $"ucode_data".
Definition _ucode_data_size : ident := $"ucode_data_size".
Definition _ucode_size : ident := $"ucode_size".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _volume : ident := $"volume".
Definition _yield_data_ptr : ident := $"yield_data_ptr".
Definition _yield_data_size : ident := $"yield_data_size".

Definition v_gAudioSessionPresets := {|
  gvar_info := (tarray (Tstruct _AudioSessionSettings noattr) 18);
  gvar_init := (Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 3072) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 14848) :: Init_int32 (Int.repr 27904) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2560) ::
                Init_int16 (Int.repr 18431) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 14848) :: Init_int32 (Int.repr 27904) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 4096) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 14848) :: Init_int32 (Int.repr 27904) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 3584) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 14848) :: Init_int32 (Int.repr 27904) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 3072) ::
                Init_int16 (Int.repr 20479) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 14848) :: Init_int32 (Int.repr 27904) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 3072) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 16384) :: Init_int32 (Int.repr 28160) ::
                Init_int32 (Int.repr 16128) :: Init_int32 (Int.repr 10752) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2560) ::
                Init_int16 (Int.repr 18431) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 16640) :: Init_int32 (Int.repr 28160) ::
                Init_int32 (Int.repr 17408) :: Init_int32 (Int.repr 10880) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 20) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 14335) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 13504) :: Init_int32 (Int.repr 25216) ::
                Init_int32 (Int.repr 16384) :: Init_int32 (Int.repr 6912) ::
                Init_int32 (Int.repr 27000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 27000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 27000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 4096) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 27000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 4096) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 27000) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 3072) ::
                Init_int16 (Int.repr 20479) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 14) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 12) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 10) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 32000) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 1) :: Init_int16 (Int.repr 2048) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 32767) ::
                Init_int32 (Int.repr 9472) :: Init_int32 (Int.repr 21760) ::
                Init_int32 (Int.repr 29696) :: Init_int32 (Int.repr 9216) ::
                Init_int32 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioCosineTable := {|
  gvar_info := (tarray tushort 128);
  gvar_init := (Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32764) ::
                Init_int16 (Int.repr 32757) :: Init_int16 (Int.repr 32744) ::
                Init_int16 (Int.repr 32727) :: Init_int16 (Int.repr 32704) ::
                Init_int16 (Int.repr 32677) :: Init_int16 (Int.repr 32644) ::
                Init_int16 (Int.repr 32607) :: Init_int16 (Int.repr 32564) ::
                Init_int16 (Int.repr 32517) :: Init_int16 (Int.repr 32464) ::
                Init_int16 (Int.repr 32407) :: Init_int16 (Int.repr 32344) ::
                Init_int16 (Int.repr 32277) :: Init_int16 (Int.repr 32205) ::
                Init_int16 (Int.repr 32127) :: Init_int16 (Int.repr 32045) ::
                Init_int16 (Int.repr 31958) :: Init_int16 (Int.repr 31866) ::
                Init_int16 (Int.repr 31770) :: Init_int16 (Int.repr 31668) ::
                Init_int16 (Int.repr 31561) :: Init_int16 (Int.repr 31450) ::
                Init_int16 (Int.repr 31334) :: Init_int16 (Int.repr 31213) ::
                Init_int16 (Int.repr 31087) :: Init_int16 (Int.repr 30957) ::
                Init_int16 (Int.repr 30822) :: Init_int16 (Int.repr 30682) ::
                Init_int16 (Int.repr 30537) :: Init_int16 (Int.repr 30388) ::
                Init_int16 (Int.repr 30234) :: Init_int16 (Int.repr 30075) ::
                Init_int16 (Int.repr 29912) :: Init_int16 (Int.repr 29744) ::
                Init_int16 (Int.repr 29572) :: Init_int16 (Int.repr 29395) ::
                Init_int16 (Int.repr 29214) :: Init_int16 (Int.repr 29028) ::
                Init_int16 (Int.repr 28838) :: Init_int16 (Int.repr 28643) ::
                Init_int16 (Int.repr 28444) :: Init_int16 (Int.repr 28241) ::
                Init_int16 (Int.repr 28033) :: Init_int16 (Int.repr 27821) ::
                Init_int16 (Int.repr 27605) :: Init_int16 (Int.repr 27385) ::
                Init_int16 (Int.repr 27160) :: Init_int16 (Int.repr 26931) ::
                Init_int16 (Int.repr 26698) :: Init_int16 (Int.repr 26461) ::
                Init_int16 (Int.repr 26220) :: Init_int16 (Int.repr 25975) ::
                Init_int16 (Int.repr 25726) :: Init_int16 (Int.repr 25473) ::
                Init_int16 (Int.repr 25216) :: Init_int16 (Int.repr 24956) ::
                Init_int16 (Int.repr 24691) :: Init_int16 (Int.repr 24423) ::
                Init_int16 (Int.repr 24151) :: Init_int16 (Int.repr 23875) ::
                Init_int16 (Int.repr 23596) :: Init_int16 (Int.repr 23313) ::
                Init_int16 (Int.repr 23026) :: Init_int16 (Int.repr 22736) ::
                Init_int16 (Int.repr 22442) :: Init_int16 (Int.repr 22145) ::
                Init_int16 (Int.repr 21845) :: Init_int16 (Int.repr 21541) ::
                Init_int16 (Int.repr 21234) :: Init_int16 (Int.repr 20924) ::
                Init_int16 (Int.repr 20610) :: Init_int16 (Int.repr 20294) ::
                Init_int16 (Int.repr 19974) :: Init_int16 (Int.repr 19651) ::
                Init_int16 (Int.repr 19325) :: Init_int16 (Int.repr 18997) ::
                Init_int16 (Int.repr 18665) :: Init_int16 (Int.repr 18331) ::
                Init_int16 (Int.repr 17993) :: Init_int16 (Int.repr 17653) ::
                Init_int16 (Int.repr 17310) :: Init_int16 (Int.repr 16965) ::
                Init_int16 (Int.repr 16617) :: Init_int16 (Int.repr 16266) ::
                Init_int16 (Int.repr 15913) :: Init_int16 (Int.repr 15558) ::
                Init_int16 (Int.repr 15200) :: Init_int16 (Int.repr 14840) ::
                Init_int16 (Int.repr 14477) :: Init_int16 (Int.repr 14113) ::
                Init_int16 (Int.repr 13746) :: Init_int16 (Int.repr 13377) ::
                Init_int16 (Int.repr 13006) :: Init_int16 (Int.repr 12633) ::
                Init_int16 (Int.repr 12258) :: Init_int16 (Int.repr 11881) ::
                Init_int16 (Int.repr 11503) :: Init_int16 (Int.repr 11122) ::
                Init_int16 (Int.repr 10740) :: Init_int16 (Int.repr 10357) ::
                Init_int16 (Int.repr 9971) :: Init_int16 (Int.repr 9584) ::
                Init_int16 (Int.repr 9196) :: Init_int16 (Int.repr 8806) ::
                Init_int16 (Int.repr 8415) :: Init_int16 (Int.repr 8023) ::
                Init_int16 (Int.repr 7630) :: Init_int16 (Int.repr 7235) ::
                Init_int16 (Int.repr 6839) :: Init_int16 (Int.repr 6442) ::
                Init_int16 (Int.repr 6044) :: Init_int16 (Int.repr 5646) ::
                Init_int16 (Int.repr 5246) :: Init_int16 (Int.repr 4845) ::
                Init_int16 (Int.repr 4444) :: Init_int16 (Int.repr 4042) ::
                Init_int16 (Int.repr 3640) :: Init_int16 (Int.repr 3237) ::
                Init_int16 (Int.repr 2833) :: Init_int16 (Int.repr 2429) ::
                Init_int16 (Int.repr 2025) :: Init_int16 (Int.repr 1620) ::
                Init_int16 (Int.repr 1216) :: Init_int16 (Int.repr 810) ::
                Init_int16 (Int.repr 405) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPitchBendFrequencyScale := {|
  gvar_info := (tarray tfloat 255);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1056964608)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057010510)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057056681)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057103087)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057149761)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057196687)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057243865)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057291294)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057338992)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057386958)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057435175)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057483662)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057532399)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057581422)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057630697)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057680257)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057730085)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057780182)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057830547)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057881198)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057932133)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057983337)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058034810)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058086584)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058138627)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058190972)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058243586)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058296501)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058349701)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058403187)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058456958)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058511048)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058565406)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058620083)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058675045)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058730326)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058785892)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058841777)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058897947)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058954436)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059011244)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059068353)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059125765)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059183512)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059241561)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059299929)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059358616)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059417638)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059476963)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059536622)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059596618)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059656932)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059717565)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059778550)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059839854)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059901493)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059963485)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060025796)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060088459)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060151474)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060214808)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060278511)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060342549)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060406957)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060471700)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060536796)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060602261)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060668078)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060734264)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060800802)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060867693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060934970)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061002615)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061070614)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061138997)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061207750)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061276873)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061346397)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061416274)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061486554)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061557203)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061628255)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061699675)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061771498)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061843724)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061916336)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061989334)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062062751)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062136554)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062210776)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062285401)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062360429)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062435859)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062511709)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062587978)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062664667)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062741775)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062819286)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062897250)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062975616)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063054435)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063133657)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063213332)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063293444)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063373991)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063454975)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063536395)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063618284)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063700593)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063783372)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063866604)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063950288)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064034426)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064119017)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064204094)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064289608)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064375608)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064462077)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064549017)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064636443)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064724339)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064812704)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064901573)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064990912)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065080754)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065171083)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065261898)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065399127)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065445281)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065491695)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065538361)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065585287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065632464)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065679902)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065727600)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065775557)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065823775)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065872261)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065921016)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065970030)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066019313)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066068865)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066118693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066168790)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066219164)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066269814)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066320733)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066371937)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066423426)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066475192)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066527244)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066579572)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066632194)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066685100)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066738301)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066791787)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066845575)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066899647)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066954022)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067008691)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067063662)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067118926)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067174500)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067230377)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067286564)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067343053)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067399852)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067456961)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067514381)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067572120)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067630169)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067688537)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067747232)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067806238)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067865579)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067925230)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067985217)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068045531)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068106173)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068167149)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068228462)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068290101)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068352085)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068414404)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068477067)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068540073)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068603424)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068667119)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068731166)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068795565)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068860308)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068925412)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068990869)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069056686)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069122863)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069189402)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069256309)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069323578)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069391215)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069459222)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069527605)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069596358)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069665489)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069734997)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069804891)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069875162)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069945819)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070016863)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070088292)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070160115)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070232332)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070304944)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070377950)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070451359)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070525170)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070599384)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070674001)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070749029)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070824467)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070900317)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070976586)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071053275)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071130375)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071207902)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071285849)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071364232)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071443035)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071522274)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071601940)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071682052)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071762599)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071843583)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071925011)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072006884)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072089210)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072171980)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072255212)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072338888)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072423034)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072507633)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072592694)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072678224)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072764224)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072850685)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072937625)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073025043)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073112938)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073201321)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073290173)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073379520)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073469362)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073559682)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073650506)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073741824)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNoteFrequencies := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1037518070)) ::
                Init_float32 (Float32.of_bits (Int.repr 1038356931)) ::
                Init_float32 (Float32.of_bits (Int.repr 1039245720)) ::
                Init_float32 (Float32.of_bits (Int.repr 1040187392)) ::
                Init_float32 (Float32.of_bits (Int.repr 1040686212)) ::
                Init_float32 (Float32.of_bits (Int.repr 1041214694)) ::
                Init_float32 (Float32.of_bits (Int.repr 1041774584)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042367759)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042996234)) ::
                Init_float32 (Float32.of_bits (Int.repr 1043662088)) ::
                Init_float32 (Float32.of_bits (Int.repr 1044367469)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045114860)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045906678)) ::
                Init_float32 (Float32.of_bits (Int.repr 1046745606)) ::
                Init_float32 (Float32.of_bits (Int.repr 1047634396)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048576000)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049074820)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049603302)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050163192)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050756367)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051384842)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052050662)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052756110)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053503468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1054295286)) ::
                Init_float32 (Float32.of_bits (Int.repr 1055134180)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056022970)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056964608)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057463428)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057991894)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058551800)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059144992)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059773450)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060439287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061144718)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061892093)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062683911)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063522805)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064411595)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065852028)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066380502)) ::
                Init_float32 (Float32.of_bits (Int.repr 1066940399)) ::
                Init_float32 (Float32.of_bits (Int.repr 1067533591)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068162058)) ::
                Init_float32 (Float32.of_bits (Int.repr 1068827895)) ::
                Init_float32 (Float32.of_bits (Int.repr 1069533318)) ::
                Init_float32 (Float32.of_bits (Int.repr 1070280693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071072510)) ::
                Init_float32 (Float32.of_bits (Int.repr 1071911413)) ::
                Init_float32 (Float32.of_bits (Int.repr 1072800194)) ::
                Init_float32 (Float32.of_bits (Int.repr 1073741824)) ::
                Init_float32 (Float32.of_bits (Int.repr 1074240636)) ::
                Init_float32 (Float32.of_bits (Int.repr 1074769110)) ::
                Init_float32 (Float32.of_bits (Int.repr 1075329007)) ::
                Init_float32 (Float32.of_bits (Int.repr 1075922199)) ::
                Init_float32 (Float32.of_bits (Int.repr 1076550666)) ::
                Init_float32 (Float32.of_bits (Int.repr 1077216503)) ::
                Init_float32 (Float32.of_bits (Int.repr 1077921930)) ::
                Init_float32 (Float32.of_bits (Int.repr 1078669305)) ::
                Init_float32 (Float32.of_bits (Int.repr 1079461118)) ::
                Init_float32 (Float32.of_bits (Int.repr 1080300021)) ::
                Init_float32 (Float32.of_bits (Int.repr 1081188802)) ::
                Init_float32 (Float32.of_bits (Int.repr 1082130432)) ::
                Init_float32 (Float32.of_bits (Int.repr 1082629246)) ::
                Init_float32 (Float32.of_bits (Int.repr 1083157720)) ::
                Init_float32 (Float32.of_bits (Int.repr 1083717617)) ::
                Init_float32 (Float32.of_bits (Int.repr 1084310809)) ::
                Init_float32 (Float32.of_bits (Int.repr 1084939274)) ::
                Init_float32 (Float32.of_bits (Int.repr 1085605109)) ::
                Init_float32 (Float32.of_bits (Int.repr 1086310536)) ::
                Init_float32 (Float32.of_bits (Int.repr 1087057913)) ::
                Init_float32 (Float32.of_bits (Int.repr 1087849728)) ::
                Init_float32 (Float32.of_bits (Int.repr 1088688629)) ::
                Init_float32 (Float32.of_bits (Int.repr 1089577410)) ::
                Init_float32 (Float32.of_bits (Int.repr 1090519040)) ::
                Init_float32 (Float32.of_bits (Int.repr 1091017853)) ::
                Init_float32 (Float32.of_bits (Int.repr 1091546327)) ::
                Init_float32 (Float32.of_bits (Int.repr 1092106225)) ::
                Init_float32 (Float32.of_bits (Int.repr 1092699417)) ::
                Init_float32 (Float32.of_bits (Int.repr 1093327882)) ::
                Init_float32 (Float32.of_bits (Int.repr 1093993717)) ::
                Init_float32 (Float32.of_bits (Int.repr 1094699145)) ::
                Init_float32 (Float32.of_bits (Int.repr 1095446520)) ::
                Init_float32 (Float32.of_bits (Int.repr 1096238336)) ::
                Init_float32 (Float32.of_bits (Int.repr 1097077236)) ::
                Init_float32 (Float32.of_bits (Int.repr 1097966019)) ::
                Init_float32 (Float32.of_bits (Int.repr 1098907648)) ::
                Init_float32 (Float32.of_bits (Int.repr 1099406461)) ::
                Init_float32 (Float32.of_bits (Int.repr 1099934935)) ::
                Init_float32 (Float32.of_bits (Int.repr 1100494833)) ::
                Init_float32 (Float32.of_bits (Int.repr 1101088025)) ::
                Init_float32 (Float32.of_bits (Int.repr 1101716490)) ::
                Init_float32 (Float32.of_bits (Int.repr 1102382325)) ::
                Init_float32 (Float32.of_bits (Int.repr 1103087753)) ::
                Init_float32 (Float32.of_bits (Int.repr 1103835128)) ::
                Init_float32 (Float32.of_bits (Int.repr 1104626944)) ::
                Init_float32 (Float32.of_bits (Int.repr 1105465844)) ::
                Init_float32 (Float32.of_bits (Int.repr 1106354627)) ::
                Init_float32 (Float32.of_bits (Int.repr 1107296256)) ::
                Init_float32 (Float32.of_bits (Int.repr 1107795069)) ::
                Init_float32 (Float32.of_bits (Int.repr 1108323543)) ::
                Init_float32 (Float32.of_bits (Int.repr 1108883441)) ::
                Init_float32 (Float32.of_bits (Int.repr 1109476633)) ::
                Init_float32 (Float32.of_bits (Int.repr 1110105098)) ::
                Init_float32 (Float32.of_bits (Int.repr 1110770933)) ::
                Init_float32 (Float32.of_bits (Int.repr 1111476361)) ::
                Init_float32 (Float32.of_bits (Int.repr 1112223736)) ::
                Init_float32 (Float32.of_bits (Int.repr 1113015552)) ::
                Init_float32 (Float32.of_bits (Int.repr 1113854452)) ::
                Init_float32 (Float32.of_bits (Int.repr 1114743235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1115684864)) ::
                Init_float32 (Float32.of_bits (Int.repr 1116183677)) ::
                Init_float32 (Float32.of_bits (Int.repr 1116712151)) ::
                Init_float32 (Float32.of_bits (Int.repr 1117272049)) ::
                Init_float32 (Float32.of_bits (Int.repr 1117865241)) ::
                Init_float32 (Float32.of_bits (Int.repr 1118493706)) ::
                Init_float32 (Float32.of_bits (Int.repr 1110770933)) ::
                Init_float32 (Float32.of_bits (Int.repr 1111476361)) ::
                Init_float32 (Float32.of_bits (Int.repr 1112223736)) ::
                Init_float32 (Float32.of_bits (Int.repr 1113015552)) ::
                Init_float32 (Float32.of_bits (Int.repr 1113854452)) ::
                Init_float32 (Float32.of_bits (Int.repr 1114743235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1115684864)) ::
                Init_float32 (Float32.of_bits (Int.repr 1116183677)) ::
                Init_float32 (Float32.of_bits (Int.repr 1116712151)) ::
                Init_float32 (Float32.of_bits (Int.repr 1117272049)) ::
                Init_float32 (Float32.of_bits (Int.repr 1117865241)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDefaultShortNoteVelocityTable := {|
  gvar_info := (tarray tuchar 16);
  gvar_init := (Init_int8 (Int.repr 12) :: Init_int8 (Int.repr 25) ::
                Init_int8 (Int.repr 38) :: Init_int8 (Int.repr 51) ::
                Init_int8 (Int.repr 57) :: Init_int8 (Int.repr 64) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 76) ::
                Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 89) ::
                Init_int8 (Int.repr 96) :: Init_int8 (Int.repr 102) ::
                Init_int8 (Int.repr 109) :: Init_int8 (Int.repr 115) ::
                Init_int8 (Int.repr 121) :: Init_int8 (Int.repr 127) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDefaultShortNoteDurationTable := {|
  gvar_info := (tarray tuchar 16);
  gvar_init := (Init_int8 (Int.repr 229) :: Init_int8 (Int.repr 203) ::
                Init_int8 (Int.repr 177) :: Init_int8 (Int.repr 151) ::
                Init_int8 (Int.repr 139) :: Init_int8 (Int.repr 126) ::
                Init_int8 (Int.repr 113) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 87) :: Init_int8 (Int.repr 74) ::
                Init_int8 (Int.repr 61) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 36) :: Init_int8 (Int.repr 23) ::
                Init_int8 (Int.repr 10) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVibratoCurve := {|
  gvar_info := (tarray tschar 16);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 48) :: Init_int8 (Int.repr 56) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 72) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 88) ::
                Init_int8 (Int.repr 96) :: Init_int8 (Int.repr 104) ::
                Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 120) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDefaultEnvelope := {|
  gvar_info := (tarray (Tstruct _AdsrEnvelope noattr) 3);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 32000) ::
                Init_int16 (Int.repr 1000) :: Init_int16 (Int.repr 32000) ::
                Init_int16 (Int.repr (-1)) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSineWave := {|
  gvar_info := (tarray tshort 64);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 3211) ::
                Init_int16 (Int.repr 6392) :: Init_int16 (Int.repr 9511) ::
                Init_int16 (Int.repr 12539) :: Init_int16 (Int.repr 15446) ::
                Init_int16 (Int.repr 18204) :: Init_int16 (Int.repr 20787) ::
                Init_int16 (Int.repr 23169) :: Init_int16 (Int.repr 25329) ::
                Init_int16 (Int.repr 27244) :: Init_int16 (Int.repr 28897) ::
                Init_int16 (Int.repr 30272) :: Init_int16 (Int.repr 31356) ::
                Init_int16 (Int.repr 32137) :: Init_int16 (Int.repr 32609) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32609) ::
                Init_int16 (Int.repr 32137) :: Init_int16 (Int.repr 31356) ::
                Init_int16 (Int.repr 30272) :: Init_int16 (Int.repr 28897) ::
                Init_int16 (Int.repr 27244) :: Init_int16 (Int.repr 25329) ::
                Init_int16 (Int.repr 23169) :: Init_int16 (Int.repr 20787) ::
                Init_int16 (Int.repr 18204) :: Init_int16 (Int.repr 15446) ::
                Init_int16 (Int.repr 12539) :: Init_int16 (Int.repr 9511) ::
                Init_int16 (Int.repr 6392) :: Init_int16 (Int.repr 3211) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-3211)) ::
                Init_int16 (Int.repr (-6392)) ::
                Init_int16 (Int.repr (-9511)) ::
                Init_int16 (Int.repr (-12539)) ::
                Init_int16 (Int.repr (-15446)) ::
                Init_int16 (Int.repr (-18204)) ::
                Init_int16 (Int.repr (-20787)) ::
                Init_int16 (Int.repr (-23169)) ::
                Init_int16 (Int.repr (-25329)) ::
                Init_int16 (Int.repr (-27244)) ::
                Init_int16 (Int.repr (-28897)) ::
                Init_int16 (Int.repr (-30272)) ::
                Init_int16 (Int.repr (-31356)) ::
                Init_int16 (Int.repr (-32137)) ::
                Init_int16 (Int.repr (-32609)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32609)) ::
                Init_int16 (Int.repr (-32137)) ::
                Init_int16 (Int.repr (-31356)) ::
                Init_int16 (Int.repr (-30272)) ::
                Init_int16 (Int.repr (-28897)) ::
                Init_int16 (Int.repr (-27244)) ::
                Init_int16 (Int.repr (-25329)) ::
                Init_int16 (Int.repr (-23169)) ::
                Init_int16 (Int.repr (-20787)) ::
                Init_int16 (Int.repr (-18204)) ::
                Init_int16 (Int.repr (-15446)) ::
                Init_int16 (Int.repr (-12539)) ::
                Init_int16 (Int.repr (-9511)) ::
                Init_int16 (Int.repr (-6392)) ::
                Init_int16 (Int.repr (-3211)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSquareWave := {|
  gvar_info := (tarray tshort 64);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 32767) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-32767)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTriangleWave := {|
  gvar_info := (tarray tshort 64);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 2047) ::
                Init_int16 (Int.repr 4095) :: Init_int16 (Int.repr 6143) ::
                Init_int16 (Int.repr 8191) :: Init_int16 (Int.repr 10239) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 14335) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 18431) ::
                Init_int16 (Int.repr 20479) :: Init_int16 (Int.repr 22527) ::
                Init_int16 (Int.repr 24575) :: Init_int16 (Int.repr 26623) ::
                Init_int16 (Int.repr 28671) :: Init_int16 (Int.repr 30719) ::
                Init_int16 (Int.repr 32767) :: Init_int16 (Int.repr 30719) ::
                Init_int16 (Int.repr 28671) :: Init_int16 (Int.repr 26623) ::
                Init_int16 (Int.repr 24575) :: Init_int16 (Int.repr 22527) ::
                Init_int16 (Int.repr 20479) :: Init_int16 (Int.repr 18431) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 14335) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 10239) ::
                Init_int16 (Int.repr 8191) :: Init_int16 (Int.repr 6143) ::
                Init_int16 (Int.repr 4095) :: Init_int16 (Int.repr 2047) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-2047)) ::
                Init_int16 (Int.repr (-4095)) ::
                Init_int16 (Int.repr (-6143)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-10239)) ::
                Init_int16 (Int.repr (-12287)) ::
                Init_int16 (Int.repr (-14335)) ::
                Init_int16 (Int.repr (-16383)) ::
                Init_int16 (Int.repr (-18431)) ::
                Init_int16 (Int.repr (-20479)) ::
                Init_int16 (Int.repr (-22527)) ::
                Init_int16 (Int.repr (-24575)) ::
                Init_int16 (Int.repr (-26623)) ::
                Init_int16 (Int.repr (-28671)) ::
                Init_int16 (Int.repr (-30719)) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-30719)) ::
                Init_int16 (Int.repr (-28671)) ::
                Init_int16 (Int.repr (-26623)) ::
                Init_int16 (Int.repr (-24575)) ::
                Init_int16 (Int.repr (-22527)) ::
                Init_int16 (Int.repr (-20479)) ::
                Init_int16 (Int.repr (-18431)) ::
                Init_int16 (Int.repr (-16383)) ::
                Init_int16 (Int.repr (-14335)) ::
                Init_int16 (Int.repr (-12287)) ::
                Init_int16 (Int.repr (-10239)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-6143)) ::
                Init_int16 (Int.repr (-4095)) ::
                Init_int16 (Int.repr (-2047)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSawtoothWave := {|
  gvar_info := (tarray tshort 64);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 1023) ::
                Init_int16 (Int.repr 2047) :: Init_int16 (Int.repr 3071) ::
                Init_int16 (Int.repr 4095) :: Init_int16 (Int.repr 5119) ::
                Init_int16 (Int.repr 6143) :: Init_int16 (Int.repr 7167) ::
                Init_int16 (Int.repr 8191) :: Init_int16 (Int.repr 9215) ::
                Init_int16 (Int.repr 10239) :: Init_int16 (Int.repr 11263) ::
                Init_int16 (Int.repr 12287) :: Init_int16 (Int.repr 13311) ::
                Init_int16 (Int.repr 14335) :: Init_int16 (Int.repr 15359) ::
                Init_int16 (Int.repr 16383) :: Init_int16 (Int.repr 17407) ::
                Init_int16 (Int.repr 18431) :: Init_int16 (Int.repr 19455) ::
                Init_int16 (Int.repr 20479) :: Init_int16 (Int.repr 21503) ::
                Init_int16 (Int.repr 22527) :: Init_int16 (Int.repr 23551) ::
                Init_int16 (Int.repr 24575) :: Init_int16 (Int.repr 25599) ::
                Init_int16 (Int.repr 26623) :: Init_int16 (Int.repr 27647) ::
                Init_int16 (Int.repr 28671) :: Init_int16 (Int.repr 29695) ::
                Init_int16 (Int.repr 30719) :: Init_int16 (Int.repr 31743) ::
                Init_int16 (Int.repr (-32767)) ::
                Init_int16 (Int.repr (-31743)) ::
                Init_int16 (Int.repr (-30719)) ::
                Init_int16 (Int.repr (-29695)) ::
                Init_int16 (Int.repr (-28671)) ::
                Init_int16 (Int.repr (-27647)) ::
                Init_int16 (Int.repr (-26623)) ::
                Init_int16 (Int.repr (-25599)) ::
                Init_int16 (Int.repr (-24575)) ::
                Init_int16 (Int.repr (-23551)) ::
                Init_int16 (Int.repr (-22527)) ::
                Init_int16 (Int.repr (-21503)) ::
                Init_int16 (Int.repr (-20479)) ::
                Init_int16 (Int.repr (-19455)) ::
                Init_int16 (Int.repr (-18431)) ::
                Init_int16 (Int.repr (-17407)) ::
                Init_int16 (Int.repr (-16383)) ::
                Init_int16 (Int.repr (-15359)) ::
                Init_int16 (Int.repr (-14335)) ::
                Init_int16 (Int.repr (-13311)) ::
                Init_int16 (Int.repr (-12287)) ::
                Init_int16 (Int.repr (-11263)) ::
                Init_int16 (Int.repr (-10239)) ::
                Init_int16 (Int.repr (-9215)) ::
                Init_int16 (Int.repr (-8191)) ::
                Init_int16 (Int.repr (-7167)) ::
                Init_int16 (Int.repr (-6143)) ::
                Init_int16 (Int.repr (-5119)) ::
                Init_int16 (Int.repr (-4095)) ::
                Init_int16 (Int.repr (-3071)) ::
                Init_int16 (Int.repr (-2047)) ::
                Init_int16 (Int.repr (-1023)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gWaveSamples := {|
  gvar_info := (tarray (tptr tshort) 4);
  gvar_init := (Init_addrof _sSawtoothWave (Ptrofs.repr 0) ::
                Init_addrof _sTriangleWave (Ptrofs.repr 0) ::
                Init_addrof _sSineWave (Ptrofs.repr 0) ::
                Init_addrof _sSquareWave (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gHeadsetPanQuantization := {|
  gvar_info := (tarray tushort 10);
  gvar_init := (Init_int16 (Int.repr 64) :: Init_int16 (Int.repr 48) ::
                Init_int16 (Int.repr 32) :: Init_int16 (Int.repr 16) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gHeadsetPanVolume := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065275806)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065198396)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065120969)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065043559)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064966149)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064888739)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064811329)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064733919)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064656492)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064579082)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064501672)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064424262)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064346851)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064269441)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064192015)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064114604)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064037194)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063959784)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063882374)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063804964)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063727537)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063650127)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063572717)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063495307)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063417897)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063340470)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063263060)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063185650)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063108240)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063030830)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062953420)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062875993)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062798583)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062721173)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062643763)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062566353)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062488943)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062411516)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062334106)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062256696)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062179285)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062101875)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062024465)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061947038)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061869628)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061792218)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061714808)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061637398)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061559988)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061482561)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061405151)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061327741)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061250331)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061172921)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061095494)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061018084)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060940674)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060863264)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060785854)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060708444)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060631017)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060553607)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060476197)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060410145)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060355451)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060300757)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060246080)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060191387)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060136693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060081999)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060027306)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059972612)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059917918)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059863241)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059808547)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059753854)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059699160)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059644466)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059589773)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059535096)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059480402)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059425708)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059371014)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059316321)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059261627)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059206950)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059152256)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059097563)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059042869)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058988175)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058933481)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058878788)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058824111)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058769417)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058714723)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058660030)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058605336)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058550642)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058495965)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058441271)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058386578)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058331884)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058277190)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058222497)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058167820)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058113126)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058058432)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058003738)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057949045)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057894351)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057839657)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057784980)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057730287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057675593)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057620899)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057566205)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057511512)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057456835)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057402141)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057347447)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057292754)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057238060)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057183366)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057128689)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057073995)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057019302)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056964608)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gStereoPanVolume := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1060437492)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060592312)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060747149)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060901969)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061056789)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061211626)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061366446)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061521266)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061676103)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061830923)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061985744)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062140580)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062295401)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062450221)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062605058)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062759878)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062914715)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063069535)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063224355)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063379192)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063534012)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063688832)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063843669)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063998489)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064153310)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064308146)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064462967)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064617787)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064772624)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064927444)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065082264)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065237101)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065314511)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065159691)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065004854)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064850034)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064695197)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064540377)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064385557)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064230736)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064075899)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063921079)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063766242)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063611422)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063456602)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063301765)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063146945)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062992125)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062837288)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062682468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062527648)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062372811)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062217991)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062063170)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061908333)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061753513)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061598693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061443856)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061289036)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061134216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060979379)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060824559)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060669739)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060514902)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060250694)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059877099)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059503521)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059129926)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058756331)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058382753)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058009157)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057635562)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057261967)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056812170)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056064980)) ::
                Init_float32 (Float32.of_bits (Int.repr 1055317790)) ::
                Init_float32 (Float32.of_bits (Int.repr 1054570633)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053823443)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053076253)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052329063)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051581907)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050834717)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050087526)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049340370)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048593180)) ::
                Init_float32 (Float32.of_bits (Int.repr 1047115980)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045621599)) ::
                Init_float32 (Float32.of_bits (Int.repr 1044127286)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042632906)) ::
                Init_float32 (Float32.of_bits (Int.repr 1041138526)) ::
                Init_float32 (Float32.of_bits (Int.repr 1039100899)) ::
                Init_float32 (Float32.of_bits (Int.repr 1036112273)) ::
                Init_float32 (Float32.of_bits (Int.repr 1033123513)) ::
                Init_float32 (Float32.of_bits (Int.repr 1028470721)) ::
                Init_float32 (Float32.of_bits (Int.repr 1021576762)) ::
                Init_float32 (Float32.of_bits (Int.repr 1001810785)) ::
                Init_float32 (Float32.of_bits (Int.repr 1007210096)) ::
                Init_float32 (Float32.of_bits (Int.repr 1017093353)) ::
                Init_float32 (Float32.of_bits (Int.repr 1023070874)) ::
                Init_float32 (Float32.of_bits (Int.repr 1026229285)) ::
                Init_float32 (Float32.of_bits (Int.repr 1029218046)) ::
                Init_float32 (Float32.of_bits (Int.repr 1032002795)) ::
                Init_float32 (Float32.of_bits (Int.repr 1033497175)) ::
                Init_float32 (Float32.of_bits (Int.repr 1034991421)) ::
                Init_float32 (Float32.of_bits (Int.repr 1036485801)) ::
                Init_float32 (Float32.of_bits (Int.repr 1037980181)) ::
                Init_float32 (Float32.of_bits (Int.repr 1039474562)) ::
                Init_float32 (Float32.of_bits (Int.repr 1040578167)) ::
                Init_float32 (Float32.of_bits (Int.repr 1041325357)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042072547)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042819670)) ::
                Init_float32 (Float32.of_bits (Int.repr 1043566860)) ::
                Init_float32 (Float32.of_bits (Int.repr 1044314050)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045061240)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045808430)) ::
                Init_float32 (Float32.of_bits (Int.repr 1046555621)) ::
                Init_float32 (Float32.of_bits (Int.repr 1047302811)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048049934)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048686562)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049060157)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049433752)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049807347)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050180942)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050554537)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050928099)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051301694)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051675289)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052048884)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDefaultPanVolume := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065351941)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065348082)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065341673)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065332681)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065321138)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065307045)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065290369)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065271159)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065249382)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065225055)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065198178)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065168767)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065136807)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065102313)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065065302)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065025758)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064983715)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064939154)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064892077)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064842518)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064790458)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064735932)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064678923)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064619464)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064557540)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064493166)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064426359)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064357136)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064285497)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064211459)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064135022)) ::
                Init_float32 (Float32.of_bits (Int.repr 1064056203)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063975018)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063891468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063805585)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063717387)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063626857)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063534012)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063438902)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063341510)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063241854)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063139949)) ::
                Init_float32 (Float32.of_bits (Int.repr 1063035829)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062929495)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062820964)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062710251)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062597374)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062482366)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062365211)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062245958)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062124625)) ::
                Init_float32 (Float32.of_bits (Int.repr 1062001195)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061875719)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061748212)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061618692)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061487175)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061353695)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061218236)) ::
                Init_float32 (Float32.of_bits (Int.repr 1061080864)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060941563)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060800383)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060657324)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060512419)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060365685)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060217157)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060066849)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059914764)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059760967)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059605442)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059448240)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059289376)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059128869)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058966751)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058803039)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058637766)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058470950)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058302625)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058132806)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057961527)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057788806)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057614692)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057439185)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057262320)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057084129)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056844651)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056483135)) ::
                Init_float32 (Float32.of_bits (Int.repr 1056119103)) ::
                Init_float32 (Float32.of_bits (Int.repr 1055752622)) ::
                Init_float32 (Float32.of_bits (Int.repr 1055383792)) ::
                Init_float32 (Float32.of_bits (Int.repr 1055012612)) ::
                Init_float32 (Float32.of_bits (Int.repr 1054639185)) ::
                Init_float32 (Float32.of_bits (Int.repr 1054263543)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053885754)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053505851)) ::
                Init_float32 (Float32.of_bits (Int.repr 1053123901)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052740004)) ::
                Init_float32 (Float32.of_bits (Int.repr 1052354162)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051966474)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051576974)) ::
                Init_float32 (Float32.of_bits (Int.repr 1051185730)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050792807)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050398274)) ::
                Init_float32 (Float32.of_bits (Int.repr 1050002164)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049604544)) ::
                Init_float32 (Float32.of_bits (Int.repr 1049205515)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048805076)) ::
                Init_float32 (Float32.of_bits (Int.repr 1048230658)) ::
                Init_float32 (Float32.of_bits (Int.repr 1047424680)) ::
                Init_float32 (Float32.of_bits (Int.repr 1046616287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1045805612)) ::
                Init_float32 (Float32.of_bits (Int.repr 1044992789)) ::
                Init_float32 (Float32.of_bits (Int.repr 1044178021)) ::
                Init_float32 (Float32.of_bits (Int.repr 1043361306)) ::
                Init_float32 (Float32.of_bits (Int.repr 1042542779)) ::
                Init_float32 (Float32.of_bits (Int.repr 1041722641)) ::
                Init_float32 (Float32.of_bits (Int.repr 1040901028)) ::
                Init_float32 (Float32.of_bits (Int.repr 1039968617)) ::
                Init_float32 (Float32.of_bits (Int.repr 1038320021)) ::
                Init_float32 (Float32.of_bits (Int.repr 1036669008)) ::
                Init_float32 (Float32.of_bits (Int.repr 1035016117)) ::
                Init_float32 (Float32.of_bits (Int.repr 1033361481)) ::
                Init_float32 (Float32.of_bits (Int.repr 1031611684)) ::
                Init_float32 (Float32.of_bits (Int.repr 1028296775)) ::
                Init_float32 (Float32.of_bits (Int.repr 1024979718)) ::
                Init_float32 (Float32.of_bits (Int.repr 1019911925)) ::
                Init_float32 (Float32.of_bits (Int.repr 1011524391)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingLhs136 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1199570944)) ::
                Init_float32 (Float32.of_bits (Int.repr 1202806215)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203289954)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203582203)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203793825)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203960456)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204098236)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204215886)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204318665)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204409995)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204492230)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204567061)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204635744)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204699238)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204758290)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204813499)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204865347)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204914229)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204960477)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205004367)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205046135)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205085981)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205124080)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205160583)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205195622)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205229312)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205261757)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205293048)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205323267)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205352487)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205380774)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205408186)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205434779)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205460601)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205485696)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205510106)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205533869)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205557018)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205579585)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205601601)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205623091)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205644081)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205664596)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205684655)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205704280)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205723490)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205742302)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205760733)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205778799)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205796513)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205813891)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205830945)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205847687)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205864128)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205880280)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205896153)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205911757)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205927100)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205942192)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205957042)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205971656)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205986043)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206000209)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206014162)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206027909)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206041454)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206054805)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206067967)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206080945)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206093745)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206106371)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206118828)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206131122)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206143256)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206155235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206167062)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206178741)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206190277)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206201673)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206212932)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206224058)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206235053)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206245922)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206256666)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206267289)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206277794)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206288184)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206298460)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206308626)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206318683)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206328635)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206338483)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206348230)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206357877)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206367428)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206376883)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206386245)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206395516)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206404697)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206413791)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206422798)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206431721)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206440561)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206449320)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206458000)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206466601)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206475126)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206483575)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206491950)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206500252)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206508483)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206516644)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206524736)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206532761)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206540718)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206548611)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206556439)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206564204)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206571906)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206579547)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206587129)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206594650)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206602114)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206609520)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206616870)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206624164)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206631404)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206638590)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingRhs136 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060683613)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060199876)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059925921)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059735466)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059589940)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059472449)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059374085)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059289611)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059215641)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059149907)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059090785)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059037097)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058987957)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058942675)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058900682)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058861557)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058824950)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058790556)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058758109)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058727440)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058698349)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058670683)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058644326)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058619143)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058595068)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058571966)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058549803)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058528496)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058507961)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058488181)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058469088)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058450616)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058432765)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058415468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058398708)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058382451)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058366646)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058351312)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058336380)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058321851)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058307708)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058293917)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058280479)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058267359)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058254558)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058242059)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058229845)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058217883)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058206206)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058194764)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058183573)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058172601)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058161847)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058151311)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058140993)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058130859)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058120911)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058111146)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058101566)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058092154)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058082910)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058073817)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058064891)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058056100)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058047460)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058038954)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058030582)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058022344)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058014241)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058006255)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057998386)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057990635)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057983002)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057975486)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057968070)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057960755)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057953541)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057946427)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057939398)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057932469)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057925640)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057918896)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057912235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057905659)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057899166)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057892757)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057886415)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057880157)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057873983)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057867877)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057861837)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057855864)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057849975)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057844137)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057838365)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057832661)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057827024)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057821437)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057815917)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057810465)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057805063)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057799711)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057794426)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057789175)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057783990)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057778873)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057773790)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057768757)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057763774)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057758841)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057753942)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057749111)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057744312)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057739564)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057734850)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057730186)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057725572)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057720992)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057716445)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057711949)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057707503)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057703074)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057698695)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057694350)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057690038)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057685777)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057681532)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingLhs144 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1199570944)) ::
                Init_float32 (Float32.of_bits (Int.repr 1202597470)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203045619)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203315882)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203511363)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203665155)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203792236)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203900690)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203995391)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204079508)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204155221)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204224095)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204287291)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204345696)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204400002)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204450762)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204498421)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204543346)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204585841)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204626162)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204664526)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204701120)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204736104)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204769617)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204801781)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204832703)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204862479)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204891192)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204918918)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204945724)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204971670)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204996813)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205021200)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205044879)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205067889)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205090268)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205112052)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205133271)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205153956)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205174133)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205193827)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205213061)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205231857)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205250235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205268214)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205285812)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205303043)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205319924)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205336470)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205352693)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205368606)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205384222)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205399551)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205414604)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205429391)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205443922)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205458205)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205472250)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205486064)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205499654)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205513029)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205526195)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205539158)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205551926)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205564503)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205576897)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205589111)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205601152)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205613025)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205624733)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205636283)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205647678)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205658922)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205670019)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205680974)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205691790)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205702471)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205713020)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205723440)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205733735)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205743907)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205753960)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205763896)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205773719)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205783431)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205793034)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205802530)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205811923)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205821215)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205830408)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205839503)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205848504)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205857411)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205866228)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205874955)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205883595)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205892150)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205900621)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205909010)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205917319)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205925548)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205933701)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205941777)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205949779)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205957708)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205965565)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205973352)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205981070)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205988720)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205996303)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206003821)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206011274)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206018665)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206025993)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206033261)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206040468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206047617)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206054707)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206061741)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206068719)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206075641)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206082509)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206089324)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206096086)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206102796)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206109456)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206116065)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206122625)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingRhs144 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060905022)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060439287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060175046)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059991134)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059850490)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059736875)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059641698)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059559909)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059488270)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059424584)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059367290)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059315264)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059267600)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059223677)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059182942)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059144992)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059109441)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059076054)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059044563)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059014767)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058986514)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058959637)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058934035)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058909574)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058886153)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058863722)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058842180)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058821460)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058801495)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058782252)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058763679)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058745728)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058728363)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058711536)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058695228)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058679407)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058664039)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058649091)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058634579)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058620435)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058606661)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058593239)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058580153)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058567386)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058554920)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058542740)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058530845)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058519202)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058507827)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058496687)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058485781)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058475094)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058464625)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058454358)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058444291)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058434426)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058424729)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058415216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058405872)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058396711)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058387685)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058378827)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058370119)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058361563)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058353124)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058344836)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058336682)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058328646)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058320744)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058312959)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058305292)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058297726)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058290293)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058282945)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058275714)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058268567)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058261537)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058254591)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058247746)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058240985)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058234324)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058227748)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058221255)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058214829)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058208504)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058202246)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058196056)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058189949)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058183926)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058177953)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058172064)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058166243)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058160488)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058154784)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058149163)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058143593)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058138090)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058132638)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058127252)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058121917)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058116649)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058111415)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058106247)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058101147)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058096080)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058091064)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058086098)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058081182)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058076317)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058071502)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058066737)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058062006)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058057325)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058052678)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058048081)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058043534)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058039021)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058034541)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058030112)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058025717)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058021355)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058017043)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058012765)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058008520)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058004309)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058000131)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057996004)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingLhs128 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1199570944)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203045619)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203570852)) ::
                Init_float32 (Float32.of_bits (Int.repr 1203888808)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204119338)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204301028)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204451371)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204579829)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204692108)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204791926)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204881842)) ::
                Init_float32 (Float32.of_bits (Int.repr 1204963692)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205038842)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205108335)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205172986)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205233445)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205290237)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205343794)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205394474)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205442581)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205488371)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205532062)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205573844)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205613883)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205652322)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205689287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205724892)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205759235)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205792405)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205824483)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205855541)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205885642)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205914847)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205943208)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205970775)) ::
                Init_float32 (Float32.of_bits (Int.repr 1205997592)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206023700)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206049136)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206073936)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206098132)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206121753)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206144827)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206167378)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206189433)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206211011)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206232134)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206252822)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206273093)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206292963)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206312448)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206331565)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206350326)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206368746)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206386836)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206404609)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206422076)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206439248)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206456135)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206472747)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206489092)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206505179)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206521017)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206536613)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206551976)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206567111)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206582026)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206596728)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206611222)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206625515)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206639612)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206653519)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206667241)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206680783)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206694150)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206707346)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206720376)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206733244)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206745954)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206758511)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206770917)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206783177)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206795295)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206807273)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206819114)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206830823)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206842402)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206853853)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206865181)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206876387)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206887475)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206898446)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206909303)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206920050)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206930687)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206941217)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206951644)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206961967)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206972191)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206982316)) ::
                Init_float32 (Float32.of_bits (Int.repr 1206992344)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207002278)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207012120)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207021870)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207031532)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207041105)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207050593)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207059997)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207069317)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207078557)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207087716)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207096797)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207105801)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207114730)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207123583)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207132364)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207141073)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207149711)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207158279)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207166780)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207175212)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207183579)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207191881)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207200118)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207208293)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207216405)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207224456)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207232448)) ::
                Init_float32 (Float32.of_bits (Int.repr 1207240380)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gVolRampingRhs128 := {|
  gvar_info := (tarray tfloat 128);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1060439287)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059936323)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059652050)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059454682)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059304006)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059182455)) ::
                Init_float32 (Float32.of_bits (Int.repr 1059080769)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058993460)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058917057)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058849176)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058788174)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058732776)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058682092)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058635401)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058592115)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058551800)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058514068)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058478634)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058445214)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058413639)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058383675)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058355204)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058328076)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058302172)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058277375)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058253635)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058230835)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058208907)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058187801)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058167467)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058147821)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058128846)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058110492)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058092725)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058075495)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058058784)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058042561)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058026790)) ::
                Init_float32 (Float32.of_bits (Int.repr 1058011473)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057996541)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057982012)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057967869)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057954061)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057940589)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057927452)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057914618)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057902068)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057889804)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057877809)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057866081)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057854589)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057843331)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057832309)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057821504)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057810901)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057800499)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057790315)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057780299)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057770468)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057760821)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057751325)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057742014)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057732853)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057723844)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057714986)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057706262)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057697688)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057689250)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057680928)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057672758)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057664688)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057656752)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057648917)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057641216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057633616)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057626117)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057618718)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057611437)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057604239)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057597143)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057590146)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057583234)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057576423)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057569678)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057563035)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057556458)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057549982)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057543573)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057537231)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057530990)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057524799)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057518692)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057512653)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057506680)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057500774)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057494936)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057489164)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057483443)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057477789)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057472203)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057466683)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057461197)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057455795)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057450426)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057445124)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057439873)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057434672)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057429521)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057424421)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057419371)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057414372)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057409422)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057404507)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057399658)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057394843)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057390061)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057385330)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057380649)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057376019)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057371405)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057366842)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057362329)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057357849)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057353403)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057348991)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057344629)) ::
                Init_float32 (Float32.of_bits (Int.repr 1057340300)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTatumsPerBeat := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 48) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnusedCount80333EE8 := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 16) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioHeapSize := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 201040) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioInitPoolSize := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 9472) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioLoadLock := {|
  gvar_info := (tvolatile tint);
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_sUnused8033EF8 := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 24) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioFrameCount := {|
  gvar_info := (tvolatile tint);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_gCurrAudioFrameDmaCount := {|
  gvar_info := (tvolatile tint);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_gAudioTaskIndex := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAiBufferIndex := {|
  gvar_info := tint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioCmdBuffers := {|
  gvar_info := (tarray (tptr tulong) 2);
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioCmd := {|
  gvar_info := (tptr tulong);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioTasks := {|
  gvar_info := (tarray (Tstruct _SPTask noattr) 2);
  gvar_init := (Init_space 160 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAiBuffers := {|
  gvar_info := (tarray (tptr tshort) 3);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAiBufferLengths := {|
  gvar_info := (tarray tshort 3);
  gvar_init := (Init_space 6 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnused80226E58 := {|
  gvar_info := (tarray tuint 16);
  gvar_init := (Init_space 64 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gUnused80226E98 := {|
  gvar_info := (tarray tushort 16);
  gvar_init := (Init_space 32 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioRandom := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioGlobalsEndMarker := {|
  gvar_info := tulong;
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
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
 Composite _SPTask Struct
   (Member_plain _task (Tunion __358 noattr) ::
    Member_plain _msgqueue (tptr (Tstruct _OSMesgQueue_s noattr)) ::
    Member_plain _msg (tptr tvoid) :: Member_plain _state tint :: nil)
   noattr ::
 Composite _AdsrEnvelope Struct
   (Member_plain _delay tshort :: Member_plain _arg tshort :: nil)
   noattr ::
 Composite _AudioSessionSettings Struct
   (Member_plain _frequency tuint ::
    Member_plain _maxSimultaneousNotes tuchar ::
    Member_plain _reverbDownsampleRate tuchar ::
    Member_plain _reverbWindowSize tushort ::
    Member_plain _reverbGain tushort :: Member_plain _volume tushort ::
    Member_plain _persistentSeqMem tuint ::
    Member_plain _persistentBankMem tuint ::
    Member_plain _temporarySeqMem tuint ::
    Member_plain _temporaryBankMem tuint :: nil)
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
 (_gAudioSessionPresets, Gvar v_gAudioSessionPresets) ::
 (_gAudioCosineTable, Gvar v_gAudioCosineTable) ::
 (_gPitchBendFrequencyScale, Gvar v_gPitchBendFrequencyScale) ::
 (_gNoteFrequencies, Gvar v_gNoteFrequencies) ::
 (_gDefaultShortNoteVelocityTable, Gvar v_gDefaultShortNoteVelocityTable) ::
 (_gDefaultShortNoteDurationTable, Gvar v_gDefaultShortNoteDurationTable) ::
 (_gVibratoCurve, Gvar v_gVibratoCurve) ::
 (_gDefaultEnvelope, Gvar v_gDefaultEnvelope) ::
 (_sSineWave, Gvar v_sSineWave) :: (_sSquareWave, Gvar v_sSquareWave) ::
 (_sTriangleWave, Gvar v_sTriangleWave) ::
 (_sSawtoothWave, Gvar v_sSawtoothWave) ::
 (_gWaveSamples, Gvar v_gWaveSamples) ::
 (_gHeadsetPanQuantization, Gvar v_gHeadsetPanQuantization) ::
 (_gHeadsetPanVolume, Gvar v_gHeadsetPanVolume) ::
 (_gStereoPanVolume, Gvar v_gStereoPanVolume) ::
 (_gDefaultPanVolume, Gvar v_gDefaultPanVolume) ::
 (_gVolRampingLhs136, Gvar v_gVolRampingLhs136) ::
 (_gVolRampingRhs136, Gvar v_gVolRampingRhs136) ::
 (_gVolRampingLhs144, Gvar v_gVolRampingLhs144) ::
 (_gVolRampingRhs144, Gvar v_gVolRampingRhs144) ::
 (_gVolRampingLhs128, Gvar v_gVolRampingLhs128) ::
 (_gVolRampingRhs128, Gvar v_gVolRampingRhs128) ::
 (_gTatumsPerBeat, Gvar v_gTatumsPerBeat) ::
 (_gUnusedCount80333EE8, Gvar v_gUnusedCount80333EE8) ::
 (_gAudioHeapSize, Gvar v_gAudioHeapSize) ::
 (_gAudioInitPoolSize, Gvar v_gAudioInitPoolSize) ::
 (_gAudioLoadLock, Gvar v_gAudioLoadLock) ::
 (_sUnused8033EF8, Gvar v_sUnused8033EF8) ::
 (_gAudioFrameCount, Gvar v_gAudioFrameCount) ::
 (_gCurrAudioFrameDmaCount, Gvar v_gCurrAudioFrameDmaCount) ::
 (_gAudioTaskIndex, Gvar v_gAudioTaskIndex) ::
 (_gCurrAiBufferIndex, Gvar v_gCurrAiBufferIndex) ::
 (_gAudioCmdBuffers, Gvar v_gAudioCmdBuffers) ::
 (_gAudioCmd, Gvar v_gAudioCmd) :: (_gAudioTask, Gvar v_gAudioTask) ::
 (_gAudioTasks, Gvar v_gAudioTasks) :: (_gAiBuffers, Gvar v_gAiBuffers) ::
 (_gAiBufferLengths, Gvar v_gAiBufferLengths) ::
 (_gUnused80226E58, Gvar v_gUnused80226E58) ::
 (_gUnused80226E98, Gvar v_gUnused80226E98) ::
 (_gAudioRandom, Gvar v_gAudioRandom) ::
 (_gAudioGlobalsEndMarker, Gvar v_gAudioGlobalsEndMarker) :: nil).

Definition public_idents : list ident :=
(_gAudioGlobalsEndMarker :: _gAudioRandom :: _gUnused80226E98 ::
 _gUnused80226E58 :: _gAiBufferLengths :: _gAiBuffers :: _gAudioTasks ::
 _gAudioTask :: _gAudioCmd :: _gAudioCmdBuffers :: _gCurrAiBufferIndex ::
 _gAudioTaskIndex :: _gCurrAudioFrameDmaCount :: _gAudioFrameCount ::
 _sUnused8033EF8 :: _gAudioLoadLock :: _gAudioInitPoolSize ::
 _gAudioHeapSize :: _gUnusedCount80333EE8 :: _gTatumsPerBeat ::
 _gVolRampingRhs128 :: _gVolRampingLhs128 :: _gVolRampingRhs144 ::
 _gVolRampingLhs144 :: _gVolRampingRhs136 :: _gVolRampingLhs136 ::
 _gDefaultPanVolume :: _gStereoPanVolume :: _gHeadsetPanVolume ::
 _gHeadsetPanQuantization :: _gWaveSamples :: _sSawtoothWave ::
 _sTriangleWave :: _sSquareWave :: _sSineWave :: _gDefaultEnvelope ::
 _gVibratoCurve :: _gDefaultShortNoteDurationTable ::
 _gDefaultShortNoteVelocityTable :: _gNoteFrequencies ::
 _gPitchBendFrequencyScale :: _gAudioCosineTable :: _gAudioSessionPresets ::
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


