(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_JP
   Source:          src/audio/external.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_JP=1 -DF3D_OLD=1
   Link hygiene:    private __stringlit_N atoms prefixed with jp_audio_external
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
  Definition source_file := "build/pinned-sm64/src/audio/external.c".
  Definition normalized := true.
End Info.

Definition _AdpcmBook : ident := $"AdpcmBook".
Definition _AdpcmLoop : ident := $"AdpcmLoop".
Definition _AdsrEnvelope : ident := $"AdsrEnvelope".
Definition _AdsrSettings : ident := $"AdsrSettings".
Definition _AdsrState : ident := $"AdsrState".
Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _AudioBank : ident := $"AudioBank".
Definition _AudioBankSample : ident := $"AudioBankSample".
Definition _AudioBankSound : ident := $"AudioBankSound".
Definition _AudioListItem : ident := $"AudioListItem".
Definition _AudioSessionSettings : ident := $"AudioSessionSettings".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _ChannelVolumeScaleFade : ident := $"ChannelVolumeScaleFade".
Definition _Controller : ident := $"Controller".
Definition _D_80332108 : ident := $"D_80332108".
Definition _D_80332120 : ident := $"D_80332120".
Definition _D_80332124 : ident := $"D_80332124".
Definition _D_80360928 : ident := $"D_80360928".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _Drum : ident := $"Drum".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _Instrument : ident := $"Instrument".
Definition _M64ScriptState : ident := $"M64ScriptState".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _MusicDynamic : ident := $"MusicDynamic".
Definition _Note : ident := $"Note".
Definition _NoteAttributes : ident := $"NoteAttributes".
Definition _NotePool : ident := $"NotePool".
Definition _NoteSynthesisBuffers : ident := $"NoteSynthesisBuffers".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _Portamento : ident := $"Portamento".
Definition _SPTask : ident := $"SPTask".
Definition _SequenceChannel : ident := $"SequenceChannel".
Definition _SequenceChannelLayer : ident := $"SequenceChannelLayer".
Definition _SequencePlayer : ident := $"SequencePlayer".
Definition _SequenceQueueItem : ident := $"SequenceQueueItem".
Definition _Sound : ident := $"Sound".
Definition _SoundCharacteristics : ident := $"SoundCharacteristics".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _VibratoState : ident := $"VibratoState".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __248 : ident := $"_248".
Definition __249 : ident := $"_249".
Definition __251 : ident := $"_251".
Definition __253 : ident := $"_253".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
Definition __356 : ident := $"_356".
Definition __358 : ident := $"_358".
Definition __421 : ident := $"_421".
Definition __423 : ident := $"_423".
Definition __727 : ident := $"_727".
Definition __732 : ident := $"_732".
Definition __977 : ident := $"_977".
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
Definition _absX : ident := $"absX".
Definition _absZ : ident := $"absZ".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _active : ident := $"active".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _adpcmdecState : ident := $"adpcmdecState".
Definition _adsr : ident := $"adsr".
Definition _adsrVolScale : ident := $"adsrVolScale".
Definition _amount : ident := $"amount".
Definition _angle : ident := $"angle".
Definition _angleVel : ident := $"angleVel".
Definition _anim : ident := $"anim".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animInfo : ident := $"animInfo".
Definition _animList : ident := $"animList".
Definition _animTimer : ident := $"animTimer".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _arg : ident := $"arg".
Definition _arg0 : ident := $"arg0".
Definition _arg1 : ident := $"arg1".
Definition _arg2 : ident := $"arg2".
Definition _arg3 : ident := $"arg3".
Definition _asAnims : ident := $"asAnims".
Definition _asChainSegment : ident := $"asChainSegment".
Definition _asConstVoidPtr : ident := $"asConstVoidPtr".
Definition _asF32 : ident := $"asF32".
Definition _asObject : ident := $"asObject".
Definition _asS16 : ident := $"asS16".
Definition _asS16P : ident := $"asS16P".
Definition _asS32 : ident := $"asS32".
Definition _asS32P : ident := $"asS32P".
Definition _asSurface : ident := $"asSurface".
Definition _asU32 : ident := $"asU32".
Definition _asVoidPtr : ident := $"asVoidPtr".
Definition _asWaypoint : ident := $"asWaypoint".
Definition _at : ident := $"at".
Definition _attributes : ident := $"attributes".
Definition _audio_reset_session : ident := $"audio_reset_session".
Definition _audio_set_sound_mode : ident := $"audio_set_sound_mode".
Definition _audio_signal_game_loop_tick : ident := $"audio_signal_game_loop_tick".
Definition _badvaddr : ident := $"badvaddr".
Definition _bank : ident := $"bank".
Definition _bankDmaCurrDevAddr : ident := $"bankDmaCurrDevAddr".
Definition _bankDmaCurrMemAddr : ident := $"bankDmaCurrMemAddr".
Definition _bankDmaInProgress : ident := $"bankDmaInProgress".
Definition _bankDmaIoMesg : ident := $"bankDmaIoMesg".
Definition _bankDmaMesg : ident := $"bankDmaMesg".
Definition _bankDmaMesgQueue : ident := $"bankDmaMesgQueue".
Definition _bankDmaRemaining : ident := $"bankDmaRemaining".
Definition _bankId : ident := $"bankId".
Definition _bankMask : ident := $"bankMask".
Definition _begin_background_music_fade : ident := $"begin_background_music_fade".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bgMusicVolume : ident := $"bgMusicVolume".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bit : ident := $"bit".
Definition _bits : ident := $"bits".
Definition _bits1 : ident := $"bits1".
Definition _bits2 : ident := $"bits2".
Definition _book : ident := $"book".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _cause : ident := $"cause".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _channelIndex : ident := $"channelIndex".
Definition _channels : ident := $"channels".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _condIndex : ident := $"condIndex".
Definition _conditionBits : ident := $"conditionBits".
Definition _conditionTypes : ident := $"conditionTypes".
Definition _conditionValues : ident := $"conditionValues".
Definition _context : ident := $"context".
Definition _continuousNotes : ident := $"continuousNotes".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _counter : ident := $"counter".
Definition _create_next_audio_frame_task : ident := $"create_next_audio_frame_task".
Definition _cur : ident := $"cur".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _curVolLeft : ident := $"curVolLeft".
Definition _curVolRight : ident := $"curVolRight".
Definition _current : ident := $"current".
Definition _currentAddr : ident := $"currentAddr".
Definition _currentHiRes : ident := $"currentHiRes".
Definition _curve : ident := $"curve".
Definition _cutscene : ident := $"cutscene".
Definition _data_ptr : ident := $"data_ptr".
Definition _data_size : ident := $"data_size".
Definition _decaying : ident := $"decaying".
Definition _decrease_sample_dma_ttls : ident := $"decrease_sample_dma_ttls".
Definition _defMode : ident := $"defMode".
Definition _defaultBank : ident := $"defaultBank".
Definition _delay : ident := $"delay".
Definition _delayUnused : ident := $"delayUnused".
Definition _delete_sound_from_bank : ident := $"delete_sound_from_bank".
Definition _depth : ident := $"depth".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _devAddr : ident := $"devAddr".
Definition _dialog : ident := $"dialog".
Definition _dialogID : ident := $"dialogID".
Definition _disable_all_sequence_players : ident := $"disable_all_sequence_players".
Definition _disabled : ident := $"disabled".
Definition _displacement : ident := $"displacement".
Definition _dist : ident := $"dist".
Definition _distance : ident := $"distance".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dramAddr : ident := $"dramAddr".
Definition _dram_stack : ident := $"dram_stack".
Definition _dram_stack_size : ident := $"dram_stack_size".
Definition _drop_queued_background_music : ident := $"drop_queued_background_music".
Definition _drums : ident := $"drums".
Definition _dummy : ident := $"dummy".
Definition _dummyResampleState : ident := $"dummyResampleState".
Definition _dur1 : ident := $"dur1".
Definition _dur2 : ident := $"dur2".
Definition _duration : ident := $"duration".
Definition _dynTable : ident := $"dynTable".
Definition _enabled : ident := $"enabled".
Definition _end : ident := $"end".
Definition _envIndex : ident := $"envIndex".
Definition _envMixerNeedsInit : ident := $"envMixerNeedsInit".
Definition _envelope : ident := $"envelope".
Definition _errnum : ident := $"errnum".
Definition _extent : ident := $"extent".
Definition _extentChangeTimer : ident := $"extentChangeTimer".
Definition _eyeState : ident := $"eyeState".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeDuration : ident := $"fadeDuration".
Definition _fadeInTime : ident := $"fadeInTime".
Definition _fadeOut : ident := $"fadeOut".
Definition _fadeOutVel : ident := $"fadeOutVel".
Definition _fadeRemainingFrames : ident := $"fadeRemainingFrames".
Definition _fadeTimer : ident := $"fadeTimer".
Definition _fadeVelocity : ident := $"fadeVelocity".
Definition _fadeVolume : ident := $"fadeVolume".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fade_channel_volume_scale : ident := $"fade_channel_volume_scale".
Definition _fade_volume_scale : ident := $"fade_volume_scale".
Definition _fadeout_background_music : ident := $"fadeout_background_music".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _finalResampleState : ident := $"finalResampleState".
Definition _finished : ident := $"finished".
Definition _first : ident := $"first".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _forwardVel : ident := $"forwardVel".
Definition _foundIndex : ident := $"foundIndex".
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
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _freqScale : ident := $"freqScale".
Definition _frequency : ident := $"frequency".
Definition _freshness : ident := $"freshness".
Definition _fullqueue : ident := $"fullqueue".
Definition _func_8031D690 : ident := $"func_8031D690".
Definition _func_8031F96C : ident := $"func_8031F96C".
Definition _func_80320ED8 : ident := $"func_80320ED8".
Definition _func_80321080 : ident := $"func_80321080".
Definition _func_803210D4 : ident := $"func_803210D4".
Definition _gAiBufferLengths : ident := $"gAiBufferLengths".
Definition _gAiBuffers : ident := $"gAiBuffers".
Definition _gAudioCmd : ident := $"gAudioCmd".
Definition _gAudioCmdBuffers : ident := $"gAudioCmdBuffers".
Definition _gAudioErrorFlags : ident := $"gAudioErrorFlags".
Definition _gAudioFrameCount : ident := $"gAudioFrameCount".
Definition _gAudioLoadLock : ident := $"gAudioLoadLock".
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gAudioSPTaskYieldBuffer : ident := $"gAudioSPTaskYieldBuffer".
Definition _gAudioSessionPresets : ident := $"gAudioSessionPresets".
Definition _gAudioTask : ident := $"gAudioTask".
Definition _gAudioTaskIndex : ident := $"gAudioTaskIndex".
Definition _gAudioTasks : ident := $"gAudioTasks".
Definition _gCurrAiBuffer : ident := $"gCurrAiBuffer".
Definition _gCurrAiBufferIndex : ident := $"gCurrAiBufferIndex".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrAudioFrameDmaCount : ident := $"gCurrAudioFrameDmaCount".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gMarioCurrentRoom : ident := $"gMarioCurrentRoom".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gMinAiBufferLength : ident := $"gMinAiBufferLength".
Definition _gSamplesPerFrameTarget : ident := $"gSamplesPerFrameTarget".
Definition _gSequenceChannelNone : ident := $"gSequenceChannelNone".
Definition _gSequencePlayers : ident := $"gSequencePlayers".
Definition _gSoundMode : ident := $"gSoundMode".
Definition _get_current_background_music : ident := $"get_current_background_music".
Definition _get_currently_playing_sound : ident := $"get_currently_playing_sound".
Definition _get_sound_freq_scale : ident := $"get_sound_freq_scale".
Definition _get_sound_pan : ident := $"get_sound_pan".
Definition _get_sound_reverb : ident := $"get_sound_reverb".
Definition _get_sound_volume : ident := $"get_sound_volume".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _gp : ident := $"gp".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _hasInstrument : ident := $"hasInstrument".
Definition _hdr : ident := $"hdr".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _headsetPanLeft : ident := $"headsetPanLeft".
Definition _headsetPanRight : ident := $"headsetPanRight".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hi : ident := $"hi".
Definition _highNotesSound : ident := $"highNotesSound".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _initial : ident := $"initial".
Definition _input : ident := $"input".
Definition _instOrWave : ident := $"instOrWave".
Definition _instantWarps : ident := $"instantWarps".
Definition _instrument : ident := $"instrument".
Definition _instruments : ident := $"instruments".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _intensity : ident := $"intensity".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isDiscreteAndStatus : ident := $"isDiscreteAndStatus".
Definition _item : ident := $"item".
Definition _j : ident := $"j".
Definition _largeNotes : ident := $"largeNotes".
Definition _latestSoundIndex : ident := $"latestSoundIndex".
Definition _layerUnused : ident := $"layerUnused".
Definition _layers : ident := $"layers".
Definition _length : ident := $"length".
Definition _level : ident := $"level".
Definition _listItem : ident := $"listItem".
Definition _liveSoundIndices : ident := $"liveSoundIndices".
Definition _liveSoundPriorities : ident := $"liveSoundPriorities".
Definition _liveSoundStatuses : ident := $"liveSoundStatuses".
Definition _lo : ident := $"lo".
Definition _load_sequence : ident := $"load_sequence".
Definition _loaded : ident := $"loaded".
Definition _loadingBank : ident := $"loadingBank".
Definition _loadingBankId : ident := $"loadingBankId".
Definition _loadingBankNumDrums : ident := $"loadingBankNumDrums".
Definition _loadingBankNumInstruments : ident := $"loadingBankNumInstruments".
Definition _loop : ident := $"loop".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowNotesSound : ident := $"lowNotesSound".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _maxSimultaneousNotes : ident := $"maxSimultaneousNotes".
Definition _maxSoundDistance : ident := $"maxSoundDistance".
Definition _maxTargetVolume : ident := $"maxTargetVolume".
Definition _mixEnvelopeState : ident := $"mixEnvelopeState".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _msgqueue : ident := $"msgqueue".
Definition _mtqueue : ident := $"mtqueue".
Definition _musicDynIndex : ident := $"musicDynIndex".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _muteBehavior : ident := $"muteBehavior".
Definition _muteVolumeScale : ident := $"muteVolumeScale".
Definition _muted : ident := $"muted".
Definition _needsInit : ident := $"needsInit".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _noop_8031EEC8 : ident := $"noop_8031EEC8".
Definition _normal : ident := $"normal".
Definition _normalNotesSound : ident := $"normalNotesSound".
Definition _normalRangeHi : ident := $"normalRangeHi".
Definition _normalRangeLo : ident := $"normalRangeLo".
Definition _note : ident := $"note".
Definition _noteAllocPolicy : ident := $"noteAllocPolicy".
Definition _noteDuration : ident := $"noteDuration".
Definition _noteFreqScale : ident := $"noteFreqScale".
Definition _notePan : ident := $"notePan".
Definition _notePool : ident := $"notePool".
Definition _notePriority : ident := $"notePriority".
Definition _noteUnused : ident := $"noteUnused".
Definition _noteVelocity : ident := $"noteVelocity".
Definition _npredictors : ident := $"npredictors".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numPlayingSounds : ident := $"numPlayingSounds".
Definition _numSoundsInBank : ident := $"numSoundsInBank".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _oldDmaCount : ident := $"oldDmaCount".
Definition _one : ident := $"one".
Definition _order : ident := $"order".
Definition _originOffset : ident := $"originOffset".
Definition _osAiGetLength : ident := $"osAiGetLength".
Definition _osAiSetNextBuffer : ident := $"osAiSetNextBuffer".
Definition _osWritebackDCacheAll : ident := $"osWritebackDCacheAll".
Definition _output_buff : ident := $"output_buff".
Definition _output_buff_size : ident := $"output_buff_size".
Definition _pad : ident := $"pad".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _pan : ident := $"pan".
Definition _panChannelWeight : ident := $"panChannelWeight".
Definition _panResampleState : ident := $"panResampleState".
Definition _panSamplesBuffer : ident := $"panSamplesBuffer".
Definition _parent : ident := $"parent".
Definition _parentLayer : ident := $"parentLayer".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _pc : ident := $"pc".
Definition _peakHeight : ident := $"peakHeight".
Definition _percentage : ident := $"percentage".
Definition _persistentBankMem : ident := $"persistentBankMem".
Definition _persistentSeqMem : ident := $"persistentSeqMem".
Definition _platform : ident := $"platform".
Definition _playPercentage : ident := $"playPercentage".
Definition _play_course_clear : ident := $"play_course_clear".
Definition _play_dialog_sound : ident := $"play_dialog_sound".
Definition _play_music : ident := $"play_music".
Definition _play_peachs_jingle : ident := $"play_peachs_jingle".
Definition _play_power_star_jingle : ident := $"play_power_star_jingle".
Definition _play_puzzle_jingle : ident := $"play_puzzle_jingle".
Definition _play_race_fanfare : ident := $"play_race_fanfare".
Definition _play_secondary_music : ident := $"play_secondary_music".
Definition _play_sound : ident := $"play_sound".
Definition _play_star_fanfare : ident := $"play_star_fanfare".
Definition _play_toads_jingle : ident := $"play_toads_jingle".
Definition _player : ident := $"player".
Definition _pool : ident := $"pool".
Definition _portamento : ident := $"portamento".
Definition _portamentoFreqScale : ident := $"portamentoFreqScale".
Definition _portamentoTargetNote : ident := $"portamentoTargetNote".
Definition _portamentoTime : ident := $"portamentoTime".
Definition _pos : ident := $"pos".
Definition _position : ident := $"position".
Definition _preload_sequence : ident := $"preload_sequence".
Definition _presetId : ident := $"presetId".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevHeadsetPanLeft : ident := $"prevHeadsetPanLeft".
Definition _prevHeadsetPanRight : ident := $"prevHeadsetPanRight".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _prevParentLayer : ident := $"prevParentLayer".
Definition _pri : ident := $"pri".
Definition _priority : ident := $"priority".
Definition _process_all_sound_requests : ident := $"process_all_sound_requests".
Definition _process_level_music_dynamics : ident := $"process_level_music_dynamics".
Definition _process_sound_request : ident := $"process_sound_request".
Definition _punchState : ident := $"punchState".
Definition _queue : ident := $"queue".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _ra : ident := $"ra".
Definition _rate : ident := $"rate".
Definition _rateChangeTimer : ident := $"rateChangeTimer".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _releaseRate : ident := $"releaseRate".
Definition _releasing : ident := $"releasing".
Definition _remLoopIters : ident := $"remLoopIters".
Definition _remainingFrames : ident := $"remainingFrames".
Definition _requestedPriority : ident := $"requestedPriority".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _restart : ident := $"restart".
Definition _ret : ident := $"ret".
Definition _retQueue : ident := $"retQueue".
Definition _reverb : ident := $"reverb".
Definition _reverbDownsampleRate : ident := $"reverbDownsampleRate".
Definition _reverbGain : ident := $"reverbGain".
Definition _reverbVol : ident := $"reverbVol".
Definition _reverbVolShifted : ident := $"reverbVolShifted".
Definition _reverbWindowSize : ident := $"reverbWindowSize".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _rspAspMainDataEnd : ident := $"rspAspMainDataEnd".
Definition _rspAspMainDataStart : ident := $"rspAspMainDataStart".
Definition _rspAspMainStart : ident := $"rspAspMainStart".
Definition _rspF3DBootEnd : ident := $"rspF3DBootEnd".
Definition _rspF3DBootStart : ident := $"rspF3DBootStart".
Definition _s0 : ident := $"s0".
Definition _s1 : ident := $"s1".
Definition _s2 : ident := $"s2".
Definition _s3 : ident := $"s3".
Definition _s4 : ident := $"s4".
Definition _s5 : ident := $"s5".
Definition _s6 : ident := $"s6".
Definition _s7 : ident := $"s7".
Definition _s8 : ident := $"s8".
Definition _sBackgroundMusicDefaultVolume : ident := $"sBackgroundMusicDefaultVolume".
Definition _sBackgroundMusicForDynamics : ident := $"sBackgroundMusicForDynamics".
Definition _sBackgroundMusicMaxTargetVolume : ident := $"sBackgroundMusicMaxTargetVolume".
Definition _sBackgroundMusicQueue : ident := $"sBackgroundMusicQueue".
Definition _sBackgroundMusicQueueSize : ident := $"sBackgroundMusicQueueSize".
Definition _sBackgroundMusicTargetVolume : ident := $"sBackgroundMusicTargetVolume".
Definition _sCurrentBackgroundMusicSeqId : ident := $"sCurrentBackgroundMusicSeqId".
Definition _sCurrentMusicDynamic : ident := $"sCurrentMusicDynamic".
Definition _sCurrentSound : ident := $"sCurrentSound".
Definition _sDialogSpeaker : ident := $"sDialogSpeaker".
Definition _sDialogSpeakerVoice : ident := $"sDialogSpeakerVoice".
Definition _sDynBBH : ident := $"sDynBBH".
Definition _sDynDDD : ident := $"sDynDDD".
Definition _sDynHMC : ident := $"sDynHMC".
Definition _sDynJRB : ident := $"sDynJRB".
Definition _sDynNone : ident := $"sDynNone".
Definition _sDynUnk38 : ident := $"sDynUnk38".
Definition _sDynWDW : ident := $"sDynWDW".
Definition _sGameLoopTicked : ident := $"sGameLoopTicked".
Definition _sHasStartedFadeOut : ident := $"sHasStartedFadeOut".
Definition _sLevelAcousticReaches : ident := $"sLevelAcousticReaches".
Definition _sLevelAreaReverbs : ident := $"sLevelAreaReverbs".
Definition _sLevelDynamics : ident := $"sLevelDynamics".
Definition _sLowerBackgroundMusicVolume : ident := $"sLowerBackgroundMusicVolume".
Definition _sMaxChannelsForSoundBank : ident := $"sMaxChannelsForSoundBank".
Definition _sMusicDynamicDelay : ident := $"sMusicDynamicDelay".
Definition _sMusicDynamics : ident := $"sMusicDynamics".
Definition _sNumProcessedSoundRequests : ident := $"sNumProcessedSoundRequests".
Definition _sNumSoundsInBank : ident := $"sNumSoundsInBank".
Definition _sNumSoundsPerBank : ident := $"sNumSoundsPerBank".
Definition _sSoundBankDisabled : ident := $"sSoundBankDisabled".
Definition _sSoundBankFreeListFront : ident := $"sSoundBankFreeListFront".
Definition _sSoundBankUsedListBack : ident := $"sSoundBankUsedListBack".
Definition _sSoundBanks : ident := $"sSoundBanks".
Definition _sSoundBanksThatLowerBackgroundMusic : ident := $"sSoundBanksThatLowerBackgroundMusic".
Definition _sSoundMovingSpeed : ident := $"sSoundMovingSpeed".
Definition _sSoundRequestCount : ident := $"sSoundRequestCount".
Definition _sSoundRequests : ident := $"sSoundRequests".
Definition _sUnused80332114 : ident := $"sUnused80332114".
Definition _sUnused80332118 : ident := $"sUnused80332118".
Definition _sUnusedSoundArgs : ident := $"sUnusedSoundArgs".
Definition _sUsedChannelsForSoundBank : ident := $"sUsedChannelsForSoundBank".
Definition _sample : ident := $"sample".
Definition _sampleAddr : ident := $"sampleAddr".
Definition _sampleCount : ident := $"sampleCount".
Definition _sampleDmaIndex : ident := $"sampleDmaIndex".
Definition _samplePosFrac : ident := $"samplePosFrac".
Definition _samplePosInt : ident := $"samplePosInt".
Definition _sampleSize : ident := $"sampleSize".
Definition _samples : ident := $"samples".
Definition _samplesRemainingInAI : ident := $"samplesRemainingInAI".
Definition _scale : ident := $"scale".
Definition _scriptState : ident := $"scriptState".
Definition _select_current_sounds : ident := $"select_current_sounds".
Definition _seqArgs : ident := $"seqArgs".
Definition _seqChannel : ident := $"seqChannel".
Definition _seqData : ident := $"seqData".
Definition _seqDmaInProgress : ident := $"seqDmaInProgress".
Definition _seqDmaIoMesg : ident := $"seqDmaIoMesg".
Definition _seqDmaMesg : ident := $"seqDmaMesg".
Definition _seqDmaMesgQueue : ident := $"seqDmaMesgQueue".
Definition _seqId : ident := $"seqId".
Definition _seqPlayer : ident := $"seqPlayer".
Definition _seqVariation : ident := $"seqVariation".
Definition _seq_player_fade_out : ident := $"seq_player_fade_out".
Definition _seq_player_fade_to_normal_volume : ident := $"seq_player_fade_to_normal_volume".
Definition _seq_player_fade_to_percentage_of_volume : ident := $"seq_player_fade_to_percentage_of_volume".
Definition _seq_player_fade_to_target_volume : ident := $"seq_player_fade_to_target_volume".
Definition _seq_player_fade_to_zero_volume : ident := $"seq_player_fade_to_zero_volume".
Definition _seq_player_lower_volume : ident := $"seq_player_lower_volume".
Definition _seq_player_play_sequence : ident := $"seq_player_play_sequence".
Definition _seq_player_unlower_volume : ident := $"seq_player_unlower_volume".
Definition _sequence_player_disable : ident := $"sequence_player_disable".
Definition _set_audio_muted : ident := $"set_audio_muted".
Definition _set_sound_moving_speed : ident := $"set_sound_moving_speed".
Definition _sharedChild : ident := $"sharedChild".
Definition _shortNoteDefaultPlayPercentage : ident := $"shortNoteDefaultPlayPercentage".
Definition _shortNoteDurationTable : ident := $"shortNoteDurationTable".
Definition _shortNoteVelocityTable : ident := $"shortNoteVelocityTable".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sound : ident := $"sound".
Definition _soundBits : ident := $"soundBits".
Definition _soundId : ident := $"soundId".
Definition _soundIndex : ident := $"soundIndex".
Definition _soundMode : ident := $"soundMode".
Definition _soundScriptIO : ident := $"soundScriptIO".
Definition _soundStatus : ident := $"soundStatus".
Definition _sound_banks_disable : ident := $"sound_banks_disable".
Definition _sound_banks_enable : ident := $"sound_banks_enable".
Definition _sound_init : ident := $"sound_init".
Definition _sound_reset : ident := $"sound_reset".
Definition _sp : ident := $"sp".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _speaker : ident := $"speaker".
Definition _speed : ident := $"speed".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _sr : ident := $"sr".
Definition _srcAddr : ident := $"srcAddr".
Definition _stack : ident := $"stack".
Definition _start : ident := $"start".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stereoHeadsetEffects : ident := $"stereoHeadsetEffects".
Definition _stereoStrongLeft : ident := $"stereoStrongLeft".
Definition _stereoStrongRight : ident := $"stereoStrongRight".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stopScript : ident := $"stopScript".
Definition _stopSomething : ident := $"stopSomething".
Definition _stopSomething2 : ident := $"stopSomething2".
Definition _stop_background_music : ident := $"stop_background_music".
Definition _stop_sound : ident := $"stop_sound".
Definition _stop_sounds_from_source : ident := $"stop_sounds_from_source".
Definition _stop_sounds_in_bank : ident := $"stop_sounds_in_bank".
Definition _stop_sounds_in_continuous_banks : ident := $"stop_sounds_in_continuous_banks".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _sustain : ident := $"sustain".
Definition _synthesisBuffers : ident := $"synthesisBuffers".
Definition _synthesis_execute : ident := $"synthesis_execute".
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
Definition _target : ident := $"target".
Definition _targetScale : ident := $"targetScale".
Definition _targetVolLeft : ident := $"targetVolLeft".
Definition _targetVolRight : ident := $"targetVolRight".
Definition _targetVolume : ident := $"targetVolume".
Definition _task : ident := $"task".
Definition _temp : ident := $"temp".
Definition _tempBits : ident := $"tempBits".
Definition _tempo : ident := $"tempo".
Definition _tempoAcc : ident := $"tempoAcc".
Definition _temporaryBankMem : ident := $"temporaryBankMem".
Definition _temporarySeqMem : ident := $"temporarySeqMem".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _thprof : ident := $"thprof".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _time : ident := $"time".
Definition _tlnext : ident := $"tlnext".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _transposition : ident := $"transposition".
Definition _tuning : ident := $"tuning".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _u : ident := $"u".
Definition _ucode : ident := $"ucode".
Definition _ucode_boot : ident := $"ucode_boot".
Definition _ucode_boot_size : ident := $"ucode_boot_size".
Definition _ucode_data : ident := $"ucode_data".
Definition _ucode_data_size : ident := $"ucode_data_size".
Definition _ucode_size : ident := $"ucode_size".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk15 : ident := $"unk15".
Definition _unk2 : ident := $"unk2".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _unused_8031FED0 : ident := $"unused_8031FED0".
Definition _unused_803209D8 : ident := $"unused_803209D8".
Definition _unused_80321460 : ident := $"unused_80321460".
Definition _unused_80321474 : ident := $"unused_80321474".
Definition _update_background_music_after_sound : ident := $"update_background_music_after_sound".
Definition _update_game_sound : ident := $"update_game_sound".
Definition _updatesPerFrameUnused : ident := $"updatesPerFrameUnused".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _usesHeadsetPanEffects : ident := $"usesHeadsetPanEffects".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _value : ident := $"value".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _velocity : ident := $"velocity".
Definition _velocitySquare : ident := $"velocitySquare".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _vibratoDelay : ident := $"vibratoDelay".
Definition _vibratoExtentChangeDelay : ident := $"vibratoExtentChangeDelay".
Definition _vibratoExtentStart : ident := $"vibratoExtentStart".
Definition _vibratoExtentTarget : ident := $"vibratoExtentTarget".
Definition _vibratoFreqScale : ident := $"vibratoFreqScale".
Definition _vibratoRateChangeDelay : ident := $"vibratoRateChangeDelay".
Definition _vibratoRateStart : ident := $"vibratoRateStart".
Definition _vibratoRateTarget : ident := $"vibratoRateTarget".
Definition _vibratoState : ident := $"vibratoState".
Definition _views : ident := $"views".
Definition _volOut : ident := $"volOut".
Definition _volScale1 : ident := $"volScale1".
Definition _volScale2 : ident := $"volScale2".
Definition _volume : ident := $"volume".
Definition _volumeRange : ident := $"volumeRange".
Definition _volumeScale : ident := $"volumeScale".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _wantedParentLayer : ident := $"wantedParentLayer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _writtenCmds : ident := $"writtenCmds".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _yield_data_ptr : ident := $"yield_data_ptr".
Definition _yield_data_size : ident := $"yield_data_size".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'100 : ident := 227%positive.
Definition _t'101 : ident := 228%positive.
Definition _t'102 : ident := 229%positive.
Definition _t'103 : ident := 230%positive.
Definition _t'104 : ident := 231%positive.
Definition _t'105 : ident := 232%positive.
Definition _t'106 : ident := 233%positive.
Definition _t'107 : ident := 234%positive.
Definition _t'108 : ident := 235%positive.
Definition _t'109 : ident := 236%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'110 : ident := 237%positive.
Definition _t'111 : ident := 238%positive.
Definition _t'112 : ident := 239%positive.
Definition _t'113 : ident := 240%positive.
Definition _t'114 : ident := 241%positive.
Definition _t'115 : ident := 242%positive.
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
Definition _t'35 : ident := 162%positive.
Definition _t'36 : ident := 163%positive.
Definition _t'37 : ident := 164%positive.
Definition _t'38 : ident := 165%positive.
Definition _t'39 : ident := 166%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'40 : ident := 167%positive.
Definition _t'41 : ident := 168%positive.
Definition _t'42 : ident := 169%positive.
Definition _t'43 : ident := 170%positive.
Definition _t'44 : ident := 171%positive.
Definition _t'45 : ident := 172%positive.
Definition _t'46 : ident := 173%positive.
Definition _t'47 : ident := 174%positive.
Definition _t'48 : ident := 175%positive.
Definition _t'49 : ident := 176%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'50 : ident := 177%positive.
Definition _t'51 : ident := 178%positive.
Definition _t'52 : ident := 179%positive.
Definition _t'53 : ident := 180%positive.
Definition _t'54 : ident := 181%positive.
Definition _t'55 : ident := 182%positive.
Definition _t'56 : ident := 183%positive.
Definition _t'57 : ident := 184%positive.
Definition _t'58 : ident := 185%positive.
Definition _t'59 : ident := 186%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'60 : ident := 187%positive.
Definition _t'61 : ident := 188%positive.
Definition _t'62 : ident := 189%positive.
Definition _t'63 : ident := 190%positive.
Definition _t'64 : ident := 191%positive.
Definition _t'65 : ident := 192%positive.
Definition _t'66 : ident := 193%positive.
Definition _t'67 : ident := 194%positive.
Definition _t'68 : ident := 195%positive.
Definition _t'69 : ident := 196%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'70 : ident := 197%positive.
Definition _t'71 : ident := 198%positive.
Definition _t'72 : ident := 199%positive.
Definition _t'73 : ident := 200%positive.
Definition _t'74 : ident := 201%positive.
Definition _t'75 : ident := 202%positive.
Definition _t'76 : ident := 203%positive.
Definition _t'77 : ident := 204%positive.
Definition _t'78 : ident := 205%positive.
Definition _t'79 : ident := 206%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'80 : ident := 207%positive.
Definition _t'81 : ident := 208%positive.
Definition _t'82 : ident := 209%positive.
Definition _t'83 : ident := 210%positive.
Definition _t'84 : ident := 211%positive.
Definition _t'85 : ident := 212%positive.
Definition _t'86 : ident := 213%positive.
Definition _t'87 : ident := 214%positive.
Definition _t'88 : ident := 215%positive.
Definition _t'89 : ident := 216%positive.
Definition _t'9 : ident := 136%positive.
Definition _t'90 : ident := 217%positive.
Definition _t'91 : ident := 218%positive.
Definition _t'92 : ident := 219%positive.
Definition _t'93 : ident := 220%positive.
Definition _t'94 : ident := 221%positive.
Definition _t'95 : ident := 222%positive.
Definition _t'96 : ident := 223%positive.
Definition _t'97 : ident := 224%positive.
Definition _t'98 : ident := 225%positive.
Definition _t'99 : ident := 226%positive.

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

Definition v_rspAspMainStart := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rspAspMainDataStart := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_rspAspMainDataEnd := {|
  gvar_info := (tarray tulong 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSequencePlayers := {|
  gvar_info := (tarray (Tstruct _SequencePlayer noattr) 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSequenceChannelNone := {|
  gvar_info := (Tstruct _SequenceChannel noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSamplesPerFrameTarget := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMinAiBufferLength := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSoundMode := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioSessionPresets := {|
  gvar_info := (tarray (Tstruct _AudioSessionSettings noattr) 18);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioLoadLock := {|
  gvar_info := (tvolatile tint);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_gAudioFrameCount := {|
  gvar_info := (tvolatile tint);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_gCurrAudioFrameDmaCount := {|
  gvar_info := (tvolatile tint);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := true
|}.

Definition v_gAudioTaskIndex := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAiBufferIndex := {|
  gvar_info := tint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioCmdBuffers := {|
  gvar_info := (tarray (tptr tulong) 2);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioCmd := {|
  gvar_info := (tptr tulong);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioTask := {|
  gvar_info := (tptr (Tstruct _SPTask noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioTasks := {|
  gvar_info := (tarray (Tstruct _SPTask noattr) 2);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAiBuffers := {|
  gvar_info := (tarray (tptr tshort) 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAiBufferLengths := {|
  gvar_info := (tarray tshort 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioRandom := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioSPTaskYieldBuffer := {|
  gvar_info := (tarray tuchar 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAreaIndex := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrLevelNum := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioCurrentRoom := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gAudioErrorFlags := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sGameLoopTicked := {|
  gvar_info := tint;
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDialogSpeaker := {|
  gvar_info := (tarray tuchar 170);
  gvar_init := (Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 2) :: Init_int8 (Int.repr 2) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 7) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 5) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 7) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 5) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 5) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 9) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 10) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 255) :: Init_int8 (Int.repr 255) ::
                Init_int8 (Int.repr 9) :: Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDialogSpeakerVoice := {|
  gvar_info := (tarray tint 15);
  gvar_init := (Init_int32 (Int.repr 1344340097) ::
                Init_int32 (Int.repr 1345126529) ::
                Init_int32 (Int.repr 1348436113) ::
                Init_int32 (Int.repr 1346216065) ::
                Init_int32 (Int.repr 1346437249) ::
                Init_int32 (Int.repr 1346896001) ::
                Init_int32 (Int.repr 1347960961) ::
                Init_int32 (Int.repr 1345880193) ::
                Init_int32 (Int.repr (-1872150399)) ::
                Init_int32 (Int.repr 1349451905) ::
                Init_int32 (Int.repr 812658817) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNumProcessedSoundRequests := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundRequestCount := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynBBH := {|
  gvar_info := (tarray tshort 6);
  gvar_init := (Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 13) :: Init_int16 (Int.repr 262) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 5) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynDDD := {|
  gvar_info := (tarray tshort 12);
  gvar_init := (Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 4608) ::
                Init_int16 (Int.repr (-800)) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 20992) ::
                Init_int16 (Int.repr (-2000)) :: Init_int16 (Int.repr 470) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 16898) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynJRB := {|
  gvar_info := (tarray tshort 13);
  gvar_init := (Init_int16 (Int.repr 5) :: Init_int16 (Int.repr 20480) ::
                Init_int16 (Int.repr 945) :: Init_int16 (Int.repr (-5260)) ::
                Init_int16 (Int.repr 512) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 16384) :: Init_int16 (Int.repr 1000) ::
                Init_int16 (Int.repr 17410) ::
                Init_int16 (Int.repr (-3100)) ::
                Init_int16 (Int.repr (-900)) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 5) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynWDW := {|
  gvar_info := (tarray tshort 7);
  gvar_init := (Init_int16 (Int.repr 12) :: Init_int16 (Int.repr 2564) ::
                Init_int16 (Int.repr (-670)) :: Init_int16 (Int.repr 1) ::
                Init_int16 (Int.repr 516) :: Init_int16 (Int.repr 2) ::
                Init_int16 (Int.repr 3) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynHMC := {|
  gvar_info := (tarray tshort 8);
  gvar_init := (Init_int16 (Int.repr 12) :: Init_int16 (Int.repr (-30716)) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr (-203)) ::
                Init_int16 (Int.repr 6148) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr (-2400)) :: Init_int16 (Int.repr 3) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynUnk38 := {|
  gvar_info := (tarray tshort 8);
  gvar_init := (Init_int16 (Int.repr 12) :: Init_int16 (Int.repr 515) ::
                Init_int16 (Int.repr 1) :: Init_int16 (Int.repr 516) ::
                Init_int16 (Int.repr 2) :: Init_int16 (Int.repr 519) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDynNone := {|
  gvar_info := (tarray tshort 2);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentMusicDynamic := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicForDynamics := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLevelDynamics := {|
  gvar_info := (tarray (tptr tshort) 39);
  gvar_init := (Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynBBH (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynHMC (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynWDW (Ptrofs.repr 0) ::
                Init_addrof _sDynJRB (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynDDD (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynNone (Ptrofs.repr 0) ::
                Init_addrof _sDynUnk38 (Ptrofs.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMusicDynamics := {|
  gvar_info := (tarray (Tstruct _MusicDynamic noattr) 8);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 3651) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 3) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 3648) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 3651) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 200) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 200) ::
                Init_int16 (Int.repr 767) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 256) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 1015) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 8) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 112) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 10) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 112) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 10) ::
                Init_int16 (Int.repr (-1)) :: Init_int16 (Int.repr 127) ::
                Init_int16 (Int.repr 100) :: Init_int16 (Int.repr 0) ::
                Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 100) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLevelAreaReverbs := {|
  gvar_info := (tarray (tarray tuchar 3) 39);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 56) :: Init_int8 (Int.repr 56) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 48) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 48) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 12) ::
                Init_int8 (Int.repr 12) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 24) ::
                Init_int8 (Int.repr 24) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 16) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 48) :: Init_int8 (Int.repr 16) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 64) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 40) ::
                Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 64) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 64) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 64) ::
                Init_int8 (Int.repr 64) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 8) ::
                Init_int8 (Int.repr 8) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLevelAcousticReaches := {|
  gvar_info := (tarray tushort 39);
  gvar_init := (Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 28000) :: Init_int16 (Int.repr 17000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 16000) ::
                Init_int16 (Int.repr 15000) :: Init_int16 (Int.repr 15000) ::
                Init_int16 (Int.repr 14000) :: Init_int16 (Int.repr 17000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 18000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 25000) :: Init_int16 (Int.repr 16000) ::
                Init_int16 (Int.repr 30000) :: Init_int16 (Int.repr 16000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 16000) ::
                Init_int16 (Int.repr 22000) :: Init_int16 (Int.repr 17000) ::
                Init_int16 (Int.repr 13000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 18000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 25000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 20000) :: Init_int16 (Int.repr 25000) ::
                Init_int16 (Int.repr 25000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 15000) :: Init_int16 (Int.repr 20000) ::
                Init_int16 (Int.repr 20000) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicDefaultVolume := {|
  gvar_info := (tarray tuchar 35);
  gvar_init := (Init_int8 (Int.repr 127) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 85) :: Init_int8 (Int.repr 75) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 85) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 70) ::
                Init_int8 (Int.repr 75) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 65) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentBackgroundMusicSeqId := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 255) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMusicDynamicDelay := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundBankUsedListBack := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundBankFreeListFront := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNumSoundsInBank := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMaxChannelsForSoundBank := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sNumSoundsPerBank := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_int8 (Int.repr 112) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 48) :: Init_int8 (Int.repr 128) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 128) ::
                Init_int8 (Int.repr 32) :: Init_int8 (Int.repr 48) ::
                Init_int8 (Int.repr 128) :: Init_int8 (Int.repr 128) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) ::
                Init_float32 (Float32.of_bits (Int.repr 0)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUnusedSoundArgs := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) ::
                Init_float32 (Float32.of_bits (Int.repr 1065353216)) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundBankDisabled := {|
  gvar_info := (tarray tuchar 16);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_space 15 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80332108 := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sHasStartedFadeOut := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundBanksThatLowerBackgroundMusic := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUnused80332114 := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUnused80332118 := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicMaxTargetVolume := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80332120 := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80332124 := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicQueueSize := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrAiBuffer := {|
  gvar_info := (tptr tshort);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundRequests := {|
  gvar_info := (tarray (Tstruct _Sound noattr) 256);
  gvar_init := (Init_space 2048 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_80360928 := {|
  gvar_info := (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3);
  gvar_init := (Init_space 768 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sUsedChannelsForSoundBank := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_space 10 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentSound := {|
  gvar_info := (tarray (tarray tuchar 1) 10);
  gvar_init := (Init_space 10 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundBanks := {|
  gvar_info := (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10);
  gvar_init := (Init_space 11200 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundMovingSpeed := {|
  gvar_info := (tarray tuchar 10);
  gvar_init := (Init_space 10 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicTargetVolume := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLowerBackgroundMusicVolume := {|
  gvar_info := tuchar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackgroundMusicQueue := {|
  gvar_info := (tarray (Tstruct _SequenceQueueItem noattr) 6);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_seq_player_fade_to_zero_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tint) :: (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqPlayer, (tptr (Tstruct _SequencePlayer noattr))) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqPlayer
    (Ebinop Oadd
      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
      (Etempvar _player tint) (tptr (Tstruct _SequencePlayer noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _fadeVelocity tfloat)
        (Eunop Oneg
          (Ebinop Odiv (Etempvar _t'1 tfloat)
            (Etempvar _fadeDuration tushort) tfloat) tfloat)))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar)
        (Econst_int (Int.repr 1) tint))
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames tushort)
        (Etempvar _fadeDuration tushort)))))
|}.

Definition f_func_8031D690 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tint) :: (_fadeInTime, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqPlayer, (tptr (Tstruct _SequencePlayer noattr))) ::
               (_t'1, tint) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqPlayer
    (Ebinop Oadd
      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
      (Etempvar _player tint) (tptr (Tstruct _SequencePlayer noattr))))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _fadeInTime tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _t'1 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _state tuchar))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'2 tuchar)
                (Econst_int (Int.repr 1) tint) tint) tbool))))
      (Sifthenelse (Etempvar _t'1 tint) (Sreturn None) Sskip))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar)
        (Econst_int (Int.repr 2) tint))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
              (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames tushort)
          (Etempvar _fadeInTime tushort))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat)
            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _fadeVelocity tfloat)
            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))))))
|}.

Definition f_seq_player_fade_to_percentage_of_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tint) :: (_fadeDuration, tushort) ::
                (_percentage, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqPlayer, (tptr (Tstruct _SequencePlayer noattr))) ::
               (_targetVolume, tfloat) :: (_t'4, tuchar) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqPlayer
    (Ebinop Oadd
      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
      (Etempvar _player tint) (tptr (Tstruct _SequencePlayer noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuchar)
                     (Econst_int (Int.repr 1) tint) tint)
        (Sreturn None)
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef
              (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
              (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
        (Sset _targetVolume
          (Ecast
            (Ebinop Omul
              (Ebinop Odiv (Ecast (Etempvar _percentage tuchar) tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4636737291354636288)) tdouble)
                tdouble) (Etempvar _t'3 tfloat) tdouble) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _volume tfloat)
            (Etempvar _t'2 tfloat)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames
              tushort) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _fadeDuration tushort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat)
                  (Etempvar _targetVolume tfloat))
                (Sreturn None))
              Sskip)
            (Ssequence
              (Ssequence
                (Sset _t'1
                  (Efield
                    (Ederef
                      (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _fadeVelocity tfloat)
                  (Ebinop Odiv
                    (Ebinop Osub (Etempvar _targetVolume tfloat)
                      (Etempvar _t'1 tfloat) tfloat)
                    (Etempvar _fadeDuration tushort) tfloat)))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _state tuchar)
                  (Econst_int (Int.repr 4) tint))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames
                    tushort) (Etempvar _fadeDuration tushort))))))))))
|}.

Definition f_seq_player_fade_to_normal_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tint) :: (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqPlayer, (tptr (Tstruct _SequencePlayer noattr))) ::
               (_t'4, tuchar) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqPlayer
    (Ebinop Oadd
      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
      (Etempvar _player tint) (tptr (Tstruct _SequencePlayer noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuchar)
                     (Econst_int (Int.repr 1) tint) tint)
        (Sreturn None)
        Sskip))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames tushort)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _fadeDuration tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef
                    (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _volume tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat)
                (Etempvar _t'3 tfloat)))
            (Sreturn None))
          Sskip)
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _volume tfloat))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef
                    (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _fadeVelocity tfloat)
                (Ebinop Odiv
                  (Ebinop Osub (Etempvar _t'1 tfloat) (Etempvar _t'2 tfloat)
                    tfloat) (Etempvar _fadeDuration tushort) tfloat))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _state tuchar)
              (Econst_int (Int.repr 2) tint))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames
                tushort) (Etempvar _fadeDuration tushort))))))))
|}.

Definition f_seq_player_fade_to_target_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tint) :: (_fadeDuration, tushort) ::
                (_targetVolume, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqPlayer, (tptr (Tstruct _SequencePlayer noattr))) ::
               (_t'2, tuchar) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqPlayer
    (Ebinop Oadd
      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
      (Etempvar _player tint) (tptr (Tstruct _SequencePlayer noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 1) tint) tint)
        (Sreturn None)
        Sskip))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames tushort)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _fadeDuration tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat)
              (Ebinop Odiv (Ecast (Etempvar _targetVolume tuchar) tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                tdouble))
            (Sreturn None))
          Sskip)
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeVelocity tfloat)
              (Ebinop Odiv
                (Ebinop Osub
                  (Ecast
                    (Ebinop Odiv
                      (Ecast (Etempvar _targetVolume tuchar) tfloat)
                      (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                      tdouble) tfloat) (Etempvar _t'1 tfloat) tfloat)
                (Ecast (Etempvar _fadeDuration tushort) tfloat) tfloat)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _state tuchar)
              (Econst_int (Int.repr 4) tint))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _seqPlayer (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeRemainingFrames
                tushort) (Etempvar _fadeDuration tushort))))))))
|}.

Definition f_create_next_audio_frame_task := {|
  fn_return := (tptr (Tstruct _SPTask noattr));
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_writtenCmds, tint) :: nil);
  fn_temps := ((_samplesRemainingInAI, tuint) :: (_index, tint) ::
               (_task, (tptr (Tstruct __356 noattr))) ::
               (_oldDmaCount, tint) :: (_flags, tint) ::
               (_t'7, (tvolatile tint)) :: (_t'6, (tvolatile tint)) ::
               (_t'5, (tptr tulong)) :: (_t'4, (tvolatile tint)) ::
               (_t'3, tuint) :: (_t'2, (tvolatile tint)) ::
               (_t'1, (tvolatile tint)) :: (_t'36, tint) :: (_t'35, tint) ::
               (_t'34, tint) :: (_t'33, tint) :: (_t'32, tshort) ::
               (_t'31, (tptr tshort)) :: (_t'30, tshort) :: (_t'29, tint) ::
               (_t'28, (tptr tulong)) :: (_t'27, tint) ::
               (_t'26, (tptr tshort)) :: (_t'25, tint) :: (_t'24, tint) ::
               (_t'23, tint) :: (_t'22, tshort) :: (_t'21, tint) ::
               (_t'20, tint) :: (_t'19, tshort) :: (_t'18, tint) ::
               (_t'17, tshort) :: (_t'16, (tptr tshort)) ::
               (_t'15, (tptr tulong)) :: (_t'14, tuint) ::
               (_t'13, (tptr (Tstruct _SPTask noattr))) ::
               (_t'12, (tptr (Tstruct _SPTask noattr))) ::
               (_t'11, (tptr (Tstruct _SPTask noattr))) ::
               (_t'10, (tptr tulong)) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _SPTask noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sbuiltin (Some _t'1) (EF_vload Mint32) ((tptr (tvolatile tint)) :: nil)
      ((Eaddrof (Evar _gAudioFrameCount (tvolatile tint))
         (tptr (tvolatile tint))) :: nil))
    (Sbuiltin None (EF_vstore Mint32)
      ((tptr (tvolatile tint)) :: (tvolatile tint) :: nil)
      ((Eaddrof (Evar _gAudioFrameCount (tvolatile tint))
         (tptr (tvolatile tint))) ::
       (Ebinop Oadd (Etempvar _t'1 (tvolatile tint))
         (Econst_int (Int.repr 1) tint) tint) :: nil)))
  (Ssequence
    (Ssequence
      (Sbuiltin (Some _t'2) (EF_vload Mint32)
        ((tptr (tvolatile tint)) :: nil)
        ((Eaddrof (Evar _gAudioLoadLock (tvolatile tint))
           (tptr (tvolatile tint))) :: nil))
      (Sifthenelse (Ebinop One (Etempvar _t'2 (tvolatile tint))
                     (Econst_int (Int.repr 1985311588) tint) tint)
        (Sreturn (Some (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'36 (Evar _gAudioTaskIndex tint))
        (Sassign (Evar _gAudioTaskIndex tint)
          (Ebinop Oxor (Etempvar _t'36 tint) (Econst_int (Int.repr 1) tint)
            tint)))
      (Ssequence
        (Ssequence
          (Sset _t'35 (Evar _gCurrAiBufferIndex tint))
          (Sassign (Evar _gCurrAiBufferIndex tint)
            (Ebinop Oadd (Etempvar _t'35 tint) (Econst_int (Int.repr 1) tint)
              tint)))
        (Ssequence
          (Ssequence
            (Sset _t'34 (Evar _gCurrAiBufferIndex tint))
            (Sassign (Evar _gCurrAiBufferIndex tint)
              (Ebinop Omod (Etempvar _t'34 tint)
                (Econst_int (Int.repr 3) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'33 (Evar _gCurrAiBufferIndex tint))
              (Sset _index
                (Ebinop Omod
                  (Ebinop Oadd
                    (Ebinop Osub (Etempvar _t'33 tint)
                      (Econst_int (Int.repr 2) tint) tint)
                    (Econst_int (Int.repr 3) tint) tint)
                  (Econst_int (Int.repr 3) tint) tint)))
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _osAiGetLength (Tfunction nil tuint cc_default)) nil)
                (Sset _samplesRemainingInAI
                  (Ebinop Odiv (Etempvar _t'3 tuint)
                    (Econst_int (Int.repr 4) tint) tuint)))
              (Ssequence
                (Ssequence
                  (Sset _t'30
                    (Ederef
                      (Ebinop Oadd (Evar _gAiBufferLengths (tarray tshort 3))
                        (Etempvar _index tint) (tptr tshort)) tshort))
                  (Sifthenelse (Ebinop One (Etempvar _t'30 tshort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'31
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gAiBuffers (tarray (tptr tshort) 3))
                            (Etempvar _index tint) (tptr (tptr tshort)))
                          (tptr tshort)))
                      (Ssequence
                        (Sset _t'32
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gAiBufferLengths (tarray tshort 3))
                              (Etempvar _index tint) (tptr tshort)) tshort))
                        (Scall None
                          (Evar _osAiSetNextBuffer (Tfunction
                                                     ((tptr tvoid) ::
                                                      tuint :: nil) tint
                                                     cc_default))
                          ((Etempvar _t'31 (tptr tshort)) ::
                           (Ebinop Omul (Etempvar _t'32 tshort)
                             (Econst_int (Int.repr 4) tint) tint) :: nil))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sbuiltin (Some _t'4) (EF_vload Mint32)
                      ((tptr (tvolatile tint)) :: nil)
                      ((Eaddrof
                         (Evar _gCurrAudioFrameDmaCount (tvolatile tint))
                         (tptr (tvolatile tint))) :: nil))
                    (Sset _oldDmaCount (Etempvar _t'4 (tvolatile tint))))
                  (Ssequence
                    Sskip
                    (Ssequence
                      (Sbuiltin None (EF_vstore Mint32)
                        ((tptr (tvolatile tint)) :: (tvolatile tint) :: nil)
                        ((Eaddrof
                           (Evar _gCurrAudioFrameDmaCount (tvolatile tint))
                           (tptr (tvolatile tint))) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'29 (Evar _gAudioTaskIndex tint))
                          (Sassign
                            (Evar _gAudioTask (tptr (Tstruct _SPTask noattr)))
                            (Ebinop Oadd
                              (Evar _gAudioTasks (tarray (Tstruct _SPTask noattr) 2))
                              (Etempvar _t'29 tint)
                              (tptr (Tstruct _SPTask noattr)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'27 (Evar _gAudioTaskIndex tint))
                            (Ssequence
                              (Sset _t'28
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gAudioCmdBuffers (tarray (tptr tulong) 2))
                                    (Etempvar _t'27 tint)
                                    (tptr (tptr tulong))) (tptr tulong)))
                              (Sassign (Evar _gAudioCmd (tptr tulong))
                                (Etempvar _t'28 (tptr tulong)))))
                          (Ssequence
                            (Sset _index (Evar _gCurrAiBufferIndex tint))
                            (Ssequence
                              (Ssequence
                                (Sset _t'26
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _gAiBuffers (tarray (tptr tshort) 3))
                                      (Etempvar _index tint)
                                      (tptr (tptr tshort))) (tptr tshort)))
                                (Sassign (Evar _gCurrAiBuffer (tptr tshort))
                                  (Etempvar _t'26 (tptr tshort))))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'25
                                    (Evar _gSamplesPerFrameTarget tint))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _gAiBufferLengths (tarray tshort 3))
                                        (Etempvar _index tint) (tptr tshort))
                                      tshort)
                                    (Ebinop Oadd
                                      (Ebinop Oand
                                        (Ebinop Oadd
                                          (Ebinop Osub (Etempvar _t'25 tint)
                                            (Etempvar _samplesRemainingInAI tuint)
                                            tuint)
                                          (Econst_int (Int.repr 64) tint)
                                          tuint)
                                        (Eunop Onotint
                                          (Econst_int (Int.repr 15) tint)
                                          tint) tuint)
                                      (Econst_int (Int.repr 16) tint) tuint)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'22
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _gAiBufferLengths (tarray tshort 3))
                                          (Etempvar _index tint)
                                          (tptr tshort)) tshort))
                                    (Ssequence
                                      (Sset _t'23
                                        (Evar _gMinAiBufferLength tint))
                                      (Sifthenelse (Ebinop Olt
                                                     (Etempvar _t'22 tshort)
                                                     (Etempvar _t'23 tint)
                                                     tint)
                                        (Ssequence
                                          (Sset _t'24
                                            (Evar _gMinAiBufferLength tint))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gAiBufferLengths (tarray tshort 3))
                                                (Etempvar _index tint)
                                                (tptr tshort)) tshort)
                                            (Etempvar _t'24 tint)))
                                        Sskip)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'19
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gAiBufferLengths (tarray tshort 3))
                                            (Etempvar _index tint)
                                            (tptr tshort)) tshort))
                                      (Ssequence
                                        (Sset _t'20
                                          (Evar _gSamplesPerFrameTarget tint))
                                        (Sifthenelse (Ebinop Ogt
                                                       (Etempvar _t'19 tshort)
                                                       (Ebinop Oadd
                                                         (Etempvar _t'20 tint)
                                                         (Econst_int (Int.repr 16) tint)
                                                         tint) tint)
                                          (Ssequence
                                            (Sset _t'21
                                              (Evar _gSamplesPerFrameTarget tint))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _gAiBufferLengths (tarray tshort 3))
                                                  (Etempvar _index tint)
                                                  (tptr tshort)) tshort)
                                              (Ebinop Oadd
                                                (Etempvar _t'21 tint)
                                                (Econst_int (Int.repr 16) tint)
                                                tint)))
                                          Sskip)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'18
                                          (Evar _sGameLoopTicked tint))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'18 tint)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Ssequence
                                            (Scall None
                                              (Evar _update_game_sound
                                              (Tfunction nil tvoid
                                                cc_default)) nil)
                                            (Sassign
                                              (Evar _sGameLoopTicked tint)
                                              (Econst_int (Int.repr 0) tint)))
                                          Sskip))
                                      (Ssequence
                                        (Sset _flags
                                          (Econst_int (Int.repr 0) tint))
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'15
                                                (Evar _gAudioCmd (tptr tulong)))
                                              (Ssequence
                                                (Sset _t'16
                                                  (Evar _gCurrAiBuffer (tptr tshort)))
                                                (Ssequence
                                                  (Sset _t'17
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _gAiBufferLengths (tarray tshort 3))
                                                        (Etempvar _index tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Scall (Some _t'5)
                                                    (Evar _synthesis_execute
                                                    (Tfunction
                                                      ((tptr tulong) ::
                                                       (tptr tint) ::
                                                       (tptr tshort) ::
                                                       tint :: nil)
                                                      (tptr tulong)
                                                      cc_default))
                                                    ((Etempvar _t'15 (tptr tulong)) ::
                                                     (Eaddrof
                                                       (Evar _writtenCmds tint)
                                                       (tptr tint)) ::
                                                     (Etempvar _t'16 (tptr tshort)) ::
                                                     (Etempvar _t'17 tshort) ::
                                                     nil)))))
                                            (Sassign
                                              (Evar _gAudioCmd (tptr tulong))
                                              (Etempvar _t'5 (tptr tulong))))
                                          (Ssequence
                                            (Ssequence
                                              (Ssequence
                                                (Sbuiltin (Some _t'6)
                                                  (EF_vload Mint32)
                                                  ((tptr (tvolatile tint)) ::
                                                   nil)
                                                  ((Eaddrof
                                                     (Evar _gAudioFrameCount (tvolatile tint))
                                                     (tptr (tvolatile tint))) ::
                                                   nil))
                                                (Sbuiltin (Some _t'7)
                                                  (EF_vload Mint32)
                                                  ((tptr (tvolatile tint)) ::
                                                   nil)
                                                  ((Eaddrof
                                                     (Evar _gAudioFrameCount (tvolatile tint))
                                                     (tptr (tvolatile tint))) ::
                                                   nil)))
                                              (Ssequence
                                                (Sset _t'14
                                                  (Evar _gAudioRandom tuint))
                                                (Sassign
                                                  (Evar _gAudioRandom tuint)
                                                  (Ebinop Omul
                                                    (Ebinop Oadd
                                                      (Etempvar _t'14 tuint)
                                                      (Etempvar _t'6 (tvolatile tint))
                                                      tuint)
                                                    (Etempvar _t'7 (tvolatile tint))
                                                    tuint))))
                                            (Ssequence
                                              (Sset _index
                                                (Evar _gAudioTaskIndex tint))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'13
                                                    (Evar _gAudioTask (tptr (Tstruct _SPTask noattr))))
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'13 (tptr (Tstruct _SPTask noattr)))
                                                        (Tstruct _SPTask noattr))
                                                      _msgqueue
                                                      (tptr (Tstruct _OSMesgQueue_s noattr)))
                                                    (Ecast
                                                      (Econst_int (Int.repr 0) tint)
                                                      (tptr tvoid))))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'12
                                                      (Evar _gAudioTask (tptr (Tstruct _SPTask noattr))))
                                                    (Sassign
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'12 (tptr (Tstruct _SPTask noattr)))
                                                          (Tstruct _SPTask noattr))
                                                        _msg (tptr tvoid))
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        (tptr tvoid))))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'11
                                                        (Evar _gAudioTask (tptr (Tstruct _SPTask noattr))))
                                                      (Sset _task
                                                        (Eaddrof
                                                          (Efield
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _t'11 (tptr (Tstruct _SPTask noattr)))
                                                                (Tstruct _SPTask noattr))
                                                              _task
                                                              (Tunion __358 noattr))
                                                            _t
                                                            (Tstruct __356 noattr))
                                                          (tptr (Tstruct __356 noattr)))))
                                                    (Ssequence
                                                      (Sassign
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                            (Tstruct __356 noattr))
                                                          _type tuint)
                                                        (Econst_int (Int.repr 2) tint))
                                                      (Ssequence
                                                        (Sassign
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                              (Tstruct __356 noattr))
                                                            _flags tuint)
                                                          (Etempvar _flags tint))
                                                        (Ssequence
                                                          (Sassign
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                (Tstruct __356 noattr))
                                                              _ucode_boot
                                                              (tptr tulong))
                                                            (Evar _rspF3DBootStart (tarray tulong 0)))
                                                          (Ssequence
                                                            (Sassign
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                  (Tstruct __356 noattr))
                                                                _ucode_boot_size
                                                                tuint)
                                                              (Ebinop Osub
                                                                (Ecast
                                                                  (Evar _rspF3DBootEnd (tarray tulong 0))
                                                                  (tptr tuchar))
                                                                (Ecast
                                                                  (Evar _rspF3DBootStart (tarray tulong 0))
                                                                  (tptr tuchar))
                                                                tint))
                                                            (Ssequence
                                                              (Sassign
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                  _ucode
                                                                  (tptr tulong))
                                                                (Evar _rspAspMainStart (tarray tulong 0)))
                                                              (Ssequence
                                                                (Sassign
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _ucode_size
                                                                    tuint)
                                                                  (Econst_int (Int.repr 2048) tint))
                                                                (Ssequence
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _ucode_data
                                                                    (tptr tulong))
                                                                    (Evar _rspAspMainDataStart (tarray tulong 0)))
                                                                  (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _ucode_data_size
                                                                    tuint)
                                                                    (Ebinop Omul
                                                                    (Ebinop Osub
                                                                    (Evar _rspAspMainDataEnd (tarray tulong 0))
                                                                    (Evar _rspAspMainDataStart (tarray tulong 0))
                                                                    tint)
                                                                    (Esizeof tulong tuint)
                                                                    tuint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _dram_stack
                                                                    (tptr tulong))
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tvoid)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _dram_stack_size
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _output_buff
                                                                    (tptr tulong))
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tvoid)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _output_buff_size
                                                                    (tptr tulong))
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tvoid)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'10
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gAudioCmdBuffers (tarray (tptr tulong) 2))
                                                                    (Etempvar _index tint)
                                                                    (tptr (tptr tulong)))
                                                                    (tptr tulong)))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _data_ptr
                                                                    (tptr tulong))
                                                                    (Etempvar _t'10 (tptr tulong))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'9
                                                                    (Evar _writtenCmds tint))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _data_size
                                                                    tuint)
                                                                    (Ebinop Omul
                                                                    (Etempvar _t'9 tint)
                                                                    (Esizeof tulong tuint)
                                                                    tuint)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _yield_data_ptr
                                                                    (tptr tulong))
                                                                    (Ecast
                                                                    (Evar _gAudioSPTaskYieldBuffer (tarray tuchar 0))
                                                                    (tptr tulong)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _task (tptr (Tstruct __356 noattr)))
                                                                    (Tstruct __356 noattr))
                                                                    _yield_data_size
                                                                    tuint)
                                                                    (Econst_int (Int.repr 1024) tint))
                                                                    (Ssequence
                                                                    (Scall None
                                                                    (Evar _decrease_sample_dma_ttls
                                                                    (Tfunction
                                                                    nil tvoid
                                                                    cc_default))
                                                                    nil)
                                                                    (Ssequence
                                                                    (Sset _t'8
                                                                    (Evar _gAudioTask (tptr (Tstruct _SPTask noattr))))
                                                                    (Sreturn (Some (Etempvar _t'8 (tptr (Tstruct _SPTask noattr)))))))))))))))))))))))))))))))))))))))))))))))))
|}.

Definition f_play_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundBits, tint) :: (_pos, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _sSoundRequestCount tuchar))
    (Sassign
      (Efield
        (Ederef
          (Ebinop Oadd
            (Evar _sSoundRequests (tarray (Tstruct _Sound noattr) 256))
            (Etempvar _t'3 tuchar) (tptr (Tstruct _Sound noattr)))
          (Tstruct _Sound noattr)) _soundBits tint)
      (Etempvar _soundBits tint)))
  (Ssequence
    (Ssequence
      (Sset _t'2 (Evar _sSoundRequestCount tuchar))
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _sSoundRequests (tarray (Tstruct _Sound noattr) 256))
              (Etempvar _t'2 tuchar) (tptr (Tstruct _Sound noattr)))
            (Tstruct _Sound noattr)) _position (tptr tfloat))
        (Etempvar _pos (tptr tfloat))))
    (Ssequence
      (Sset _t'1 (Evar _sSoundRequestCount tuchar))
      (Sassign (Evar _sSoundRequestCount tuchar)
        (Ebinop Oadd (Etempvar _t'1 tuchar) (Econst_int (Int.repr 1) tint)
          tint)))))
|}.

Definition f_process_sound_request := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bits, tuint) :: (_pos, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_bank, tuchar) :: (_soundIndex, tuchar) ::
               (_counter, tuchar) :: (_soundId, tuchar) :: (_dist, tfloat) ::
               (_one, tfloat) :: (_t'5, tint) :: (_t'4, tfloat) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'29, tuchar) :: (_t'28, tuchar) :: (_t'27, tuchar) ::
               (_t'26, tuint) :: (_t'25, tuint) :: (_t'24, tuint) ::
               (_t'23, tuchar) :: (_t'22, (tptr tfloat)) ::
               (_t'21, tuchar) :: (_t'20, tuchar) :: (_t'19, tuchar) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tuchar) :: (_t'11, tuchar) :: (_t'10, tuchar) ::
               (_t'9, tuchar) :: (_t'8, tuchar) :: (_t'7, tuchar) ::
               (_t'6, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _counter (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Sset _one
      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))
    (Ssequence
      (Sset _bank
        (Ecast
          (Ebinop Oshr
            (Ebinop Oand (Etempvar _bits tuint)
              (Econst_int (Int.repr (-268435456)) tuint) tuint)
            (Econst_int (Int.repr 28) tint) tuint) tuchar))
      (Ssequence
        (Sset _soundId
          (Ecast
            (Ebinop Oshr
              (Ebinop Oand (Etempvar _bits tuint)
                (Econst_int (Int.repr 16711680) tint) tuint)
              (Econst_int (Int.repr 16) tint) tuint) tuchar))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'28
                (Ederef
                  (Ebinop Oadd (Evar _sNumSoundsPerBank (tarray tuchar 10))
                    (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
              (Sifthenelse (Ebinop Oge (Etempvar _soundId tuchar)
                             (Etempvar _t'28 tuchar) tint)
                (Sset _t'1 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'29
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBankDisabled (tarray tuchar 16))
                        (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
                  (Sset _t'1 (Ecast (Etempvar _t'29 tuchar) tbool)))))
            (Sifthenelse (Etempvar _t'1 tint) (Sreturn None) Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'27
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _bank tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _next tuchar))
              (Sset _soundIndex (Ecast (Etempvar _t'27 tuchar) tuchar)))
            (Ssequence
              (Sloop
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop One (Etempvar _soundIndex tuchar)
                                   (Econst_int (Int.repr 255) tint) tint)
                      (Sset _t'2
                        (Ecast
                          (Ebinop One (Etempvar _soundIndex tuchar)
                            (Econst_int (Int.repr 0) tint) tint) tbool))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'2 tint) Sskip Sbreak))
                  (Ssequence
                    (Ssequence
                      (Sset _t'22
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                  (Etempvar _bank tuchar)
                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                              (Etempvar _soundIndex tuchar)
                              (tptr (Tstruct _SoundCharacteristics noattr)))
                            (Tstruct _SoundCharacteristics noattr)) _x
                          (tptr tfloat)))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'22 (tptr tfloat))
                                     (Etempvar _pos (tptr tfloat)) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'24
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                        (Etempvar _bank tuchar)
                                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                    (Etempvar _soundIndex tuchar)
                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                  (Tstruct _SoundCharacteristics noattr))
                                _soundBits tuint))
                            (Sifthenelse (Ebinop Ole
                                           (Ebinop Oand
                                             (Etempvar _t'24 tuint)
                                             (Econst_int (Int.repr 65280) tint)
                                             tuint)
                                           (Ebinop Oand
                                             (Etempvar _bits tuint)
                                             (Econst_int (Int.repr 65280) tint)
                                             tuint) tint)
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'25
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                (Etempvar _bank tuchar)
                                                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                              (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                            (Etempvar _soundIndex tuchar)
                                            (tptr (Tstruct _SoundCharacteristics noattr)))
                                          (Tstruct _SoundCharacteristics noattr))
                                        _soundBits tuint))
                                    (Sifthenelse (Ebinop One
                                                   (Ebinop Oand
                                                     (Etempvar _t'25 tuint)
                                                     (Econst_int (Int.repr 128) tint)
                                                     tuint)
                                                   (Econst_int (Int.repr 0) tint)
                                                   tint)
                                      (Sset _t'3
                                        (Econst_int (Int.repr 1) tint))
                                      (Ssequence
                                        (Sset _t'26
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                (Etempvar _soundIndex tuchar)
                                                (tptr (Tstruct _SoundCharacteristics noattr)))
                                              (Tstruct _SoundCharacteristics noattr))
                                            _soundBits tuint))
                                        (Sset _t'3
                                          (Ecast
                                            (Ebinop One
                                              (Ebinop Oand
                                                (Etempvar _bits tuint)
                                                (Econst_int (Int.repr 16711680) tint)
                                                tuint)
                                              (Ebinop Oand
                                                (Etempvar _t'26 tuint)
                                                (Econst_int (Int.repr 16711680) tint)
                                                tuint) tint) tbool)))))
                                  (Sifthenelse (Etempvar _t'3 tint)
                                    (Ssequence
                                      (Scall None
                                        (Evar _update_background_music_after_sound
                                        (Tfunction (tuchar :: tuchar :: nil)
                                          tvoid cc_default))
                                        ((Etempvar _bank tuchar) ::
                                         (Etempvar _soundIndex tuchar) ::
                                         nil))
                                      (Ssequence
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                (Etempvar _soundIndex tuchar)
                                                (tptr (Tstruct _SoundCharacteristics noattr)))
                                              (Tstruct _SoundCharacteristics noattr))
                                            _soundBits tuint)
                                          (Etempvar _bits tuint))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                (Etempvar _soundIndex tuchar)
                                                (tptr (Tstruct _SoundCharacteristics noattr)))
                                              (Tstruct _SoundCharacteristics noattr))
                                            _soundStatus tuchar)
                                          (Ebinop Oand (Etempvar _bits tuint)
                                            (Econst_int (Int.repr 15) tint)
                                            tuint))))
                                    Sskip))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                            (Etempvar _bank tuchar)
                                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                        (Etempvar _soundIndex tuchar)
                                        (tptr (Tstruct _SoundCharacteristics noattr)))
                                      (Tstruct _SoundCharacteristics noattr))
                                    _freshness tuchar)
                                  (Econst_int (Int.repr 10) tint)))
                              Sskip))
                          (Sset _soundIndex
                            (Ecast (Econst_int (Int.repr 0) tint) tuchar)))
                        (Ssequence
                          (Sset _t'23
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                      (Etempvar _bank tuchar)
                                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                  (Etempvar _soundIndex tuchar)
                                  (tptr (Tstruct _SoundCharacteristics noattr)))
                                (Tstruct _SoundCharacteristics noattr)) _next
                              tuchar))
                          (Sset _soundIndex
                            (Ecast (Etempvar _t'23 tuchar) tuchar)))))
                    (Sset _counter
                      (Ecast
                        (Ebinop Oadd (Etempvar _counter tuchar)
                          (Econst_int (Int.repr 1) tint) tint) tuchar))))
                Sskip)
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _counter tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundMovingSpeed (tarray tuchar 10))
                        (Etempvar _bank tuchar) (tptr tuchar)) tuchar)
                    (Econst_int (Int.repr 32) tint))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                          (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
                    (Ssequence
                      (Sset _t'21
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                  (Etempvar _bank tuchar)
                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                              (Etempvar _t'20 tuchar)
                              (tptr (Tstruct _SoundCharacteristics noattr)))
                            (Tstruct _SoundCharacteristics noattr)) _next
                          tuchar))
                      (Sifthenelse (Ebinop One (Etempvar _t'21 tuchar)
                                     (Econst_int (Int.repr 255) tint) tint)
                        (Sset _t'5
                          (Ecast
                            (Ebinop One (Etempvar _soundIndex tuchar)
                              (Econst_int (Int.repr 0) tint) tint) tbool))
                        (Sset _t'5 (Econst_int (Int.repr 0) tint)))))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'19
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                              (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
                        (Sset _soundIndex
                          (Ecast (Etempvar _t'19 tuchar) tuchar)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'13
                              (Ederef
                                (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _t'14
                                (Ederef
                                  (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'15
                                  (Ederef
                                    (Ebinop Oadd
                                      (Etempvar _pos (tptr tfloat))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'16
                                    (Ederef
                                      (Ebinop Oadd
                                        (Etempvar _pos (tptr tfloat))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'17
                                      (Ederef
                                        (Ebinop Oadd
                                          (Etempvar _pos (tptr tfloat))
                                          (Econst_int (Int.repr 2) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'18
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _pos (tptr tfloat))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tfloat)) tfloat))
                                      (Scall (Some _t'4)
                                        (Evar _sqrtf (Tfunction
                                                       (tfloat :: nil) tfloat
                                                       cc_default))
                                        ((Ebinop Oadd
                                           (Ebinop Oadd
                                             (Ebinop Omul
                                               (Etempvar _t'13 tfloat)
                                               (Etempvar _t'14 tfloat)
                                               tfloat)
                                             (Ebinop Omul
                                               (Etempvar _t'15 tfloat)
                                               (Etempvar _t'16 tfloat)
                                               tfloat) tfloat)
                                           (Ebinop Omul
                                             (Etempvar _t'17 tfloat)
                                             (Etempvar _t'18 tfloat) tfloat)
                                           tfloat) :: nil))))))))
                          (Sset _dist
                            (Ebinop Omul (Etempvar _t'4 tfloat)
                              (Etempvar _one tfloat) tfloat)))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                      (Etempvar _bank tuchar)
                                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                  (Etempvar _soundIndex tuchar)
                                  (tptr (Tstruct _SoundCharacteristics noattr)))
                                (Tstruct _SoundCharacteristics noattr)) _x
                              (tptr tfloat))
                            (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat)))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                        (Etempvar _bank tuchar)
                                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                    (Etempvar _soundIndex tuchar)
                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                  (Tstruct _SoundCharacteristics noattr)) _y
                                (tptr tfloat))
                              (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat)))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Ebinop Oadd
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                          (Etempvar _bank tuchar)
                                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                      (Etempvar _soundIndex tuchar)
                                      (tptr (Tstruct _SoundCharacteristics noattr)))
                                    (Tstruct _SoundCharacteristics noattr))
                                  _z (tptr tfloat))
                                (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                            (Etempvar _bank tuchar)
                                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                        (Etempvar _soundIndex tuchar)
                                        (tptr (Tstruct _SoundCharacteristics noattr)))
                                      (Tstruct _SoundCharacteristics noattr))
                                    _distance tfloat)
                                  (Etempvar _dist tfloat))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                              (Etempvar _bank tuchar)
                                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                          (Etempvar _soundIndex tuchar)
                                          (tptr (Tstruct _SoundCharacteristics noattr)))
                                        (Tstruct _SoundCharacteristics noattr))
                                      _soundBits tuint)
                                    (Etempvar _bits tuint))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                (Etempvar _bank tuchar)
                                                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                              (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                            (Etempvar _soundIndex tuchar)
                                            (tptr (Tstruct _SoundCharacteristics noattr)))
                                          (Tstruct _SoundCharacteristics noattr))
                                        _soundStatus tuchar)
                                      (Ebinop Oand (Etempvar _bits tuint)
                                        (Econst_int (Int.repr 15) tint)
                                        tuint))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                  (Etempvar _bank tuchar)
                                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                              (Etempvar _soundIndex tuchar)
                                              (tptr (Tstruct _SoundCharacteristics noattr)))
                                            (Tstruct _SoundCharacteristics noattr))
                                          _freshness tuchar)
                                        (Econst_int (Int.repr 10) tint))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'12
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sSoundBankUsedListBack (tarray tuchar 10))
                                                (Etempvar _bank tuchar)
                                                (tptr tuchar)) tuchar))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                      (Etempvar _bank tuchar)
                                                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                  (Etempvar _soundIndex tuchar)
                                                  (tptr (Tstruct _SoundCharacteristics noattr)))
                                                (Tstruct _SoundCharacteristics noattr))
                                              _prev tuchar)
                                            (Etempvar _t'12 tuchar)))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'10
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSoundBankUsedListBack (tarray tuchar 10))
                                                  (Etempvar _bank tuchar)
                                                  (tptr tuchar)) tuchar))
                                            (Ssequence
                                              (Sset _t'11
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr tuchar)) tuchar))
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                          (Etempvar _bank tuchar)
                                                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                      (Etempvar _t'10 tuchar)
                                                      (tptr (Tstruct _SoundCharacteristics noattr)))
                                                    (Tstruct _SoundCharacteristics noattr))
                                                  _next tuchar)
                                                (Etempvar _t'11 tuchar))))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'9
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr tuchar)) tuchar))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sSoundBankUsedListBack (tarray tuchar 10))
                                                    (Etempvar _bank tuchar)
                                                    (tptr tuchar)) tuchar)
                                                (Etempvar _t'9 tuchar)))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'7
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                                                      (Etempvar _bank tuchar)
                                                      (tptr tuchar)) tuchar))
                                                (Ssequence
                                                  (Sset _t'8
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                              (Etempvar _bank tuchar)
                                                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                          (Etempvar _t'7 tuchar)
                                                          (tptr (Tstruct _SoundCharacteristics noattr)))
                                                        (Tstruct _SoundCharacteristics noattr))
                                                      _next tuchar))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                                                        (Etempvar _bank tuchar)
                                                        (tptr tuchar))
                                                      tuchar)
                                                    (Etempvar _t'8 tuchar))))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'6
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                                                        (Etempvar _bank tuchar)
                                                        (tptr tuchar))
                                                      tuchar))
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                              (Etempvar _bank tuchar)
                                                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                          (Etempvar _t'6 tuchar)
                                                          (tptr (Tstruct _SoundCharacteristics noattr)))
                                                        (Tstruct _SoundCharacteristics noattr))
                                                      _prev tuchar)
                                                    (Econst_int (Int.repr 255) tint)))
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                            (Etempvar _bank tuchar)
                                                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                        (Etempvar _soundIndex tuchar)
                                                        (tptr (Tstruct _SoundCharacteristics noattr)))
                                                      (Tstruct _SoundCharacteristics noattr))
                                                    _next tuchar)
                                                  (Econst_int (Int.repr 255) tint))))))))))))))))
                    Sskip))))))))))
|}.

Definition f_process_all_sound_requests := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_sound, (tptr (Tstruct _Sound noattr))) :: (_t'6, tuchar) ::
               (_t'5, tuchar) :: (_t'4, tuchar) :: (_t'3, (tptr tfloat)) ::
               (_t'2, tint) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Sloop
  (Ssequence
    (Ssequence
      (Sset _t'5 (Evar _sSoundRequestCount tuchar))
      (Ssequence
        (Sset _t'6 (Evar _sNumProcessedSoundRequests tuchar))
        (Sifthenelse (Ebinop One (Etempvar _t'5 tuchar)
                       (Etempvar _t'6 tuchar) tint)
          Sskip
          Sbreak)))
    (Ssequence
      (Ssequence
        (Sset _t'4 (Evar _sNumProcessedSoundRequests tuchar))
        (Sset _sound
          (Ebinop Oadd
            (Evar _sSoundRequests (tarray (Tstruct _Sound noattr) 256))
            (Etempvar _t'4 tuchar) (tptr (Tstruct _Sound noattr)))))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _sound (tptr (Tstruct _Sound noattr)))
                (Tstruct _Sound noattr)) _soundBits tint))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _sound (tptr (Tstruct _Sound noattr)))
                  (Tstruct _Sound noattr)) _position (tptr tfloat)))
            (Scall None
              (Evar _process_sound_request (Tfunction
                                             (tuint :: (tptr tfloat) :: nil)
                                             tvoid cc_default))
              ((Etempvar _t'2 tint) :: (Etempvar _t'3 (tptr tfloat)) :: nil))))
        (Ssequence
          (Sset _t'1 (Evar _sNumProcessedSoundRequests tuchar))
          (Sassign (Evar _sNumProcessedSoundRequests tuchar)
            (Ebinop Oadd (Etempvar _t'1 tuchar)
              (Econst_int (Int.repr 1) tint) tint))))))
  Sskip)
|}.

Definition f_delete_sound_from_bank := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_soundIndex, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tuchar) :: (_t'7, tuchar) :: (_t'6, tuchar) ::
               (_t'5, tuchar) :: (_t'4, tuchar) :: (_t'3, tuchar) ::
               (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Ederef
        (Ebinop Oadd (Evar _sSoundBankUsedListBack (tarray tuchar 10))
          (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tuchar)
                   (Etempvar _soundIndex tuchar) tint)
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _prev tuchar))
        (Sassign
          (Ederef
            (Ebinop Oadd (Evar _sSoundBankUsedListBack (tarray tuchar 10))
              (Etempvar _bank tuchar) (tptr tuchar)) tuchar)
          (Etempvar _t'8 tuchar)))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _next tuchar))
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _soundIndex tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _prev tuchar))
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _t'6 tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _prev tuchar)
            (Etempvar _t'7 tuchar))))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                  (Etempvar _bank tuchar)
                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                (tarray (Tstruct _SoundCharacteristics noattr) 40))
              (Etempvar _soundIndex tuchar)
              (tptr (Tstruct _SoundCharacteristics noattr)))
            (Tstruct _SoundCharacteristics noattr)) _prev tuchar))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _next tuchar))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _t'3 tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _next tuchar)
          (Etempvar _t'4 tuchar))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd (Evar _sSoundBankFreeListFront (tarray tuchar 10))
              (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _next tuchar)
          (Etempvar _t'2 tuchar)))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _prev tuchar)
          (Econst_int (Int.repr 255) tint))
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Ederef
                (Ebinop Oadd
                  (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                  (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                        (Etempvar _bank tuchar)
                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                    (Etempvar _t'1 tuchar)
                    (tptr (Tstruct _SoundCharacteristics noattr)))
                  (Tstruct _SoundCharacteristics noattr)) _prev tuchar)
              (Etempvar _soundIndex tuchar)))
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                (Etempvar _bank tuchar) (tptr tuchar)) tuchar)
            (Etempvar _soundIndex tuchar)))))))
|}.

Definition f_update_background_music_after_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_soundIndex, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef
        (Ebinop Oadd
          (Ederef
            (Ebinop Oadd
              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
              (Etempvar _bank tuchar)
              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
            (tarray (Tstruct _SoundCharacteristics noattr) 40))
          (Etempvar _soundIndex tuchar)
          (tptr (Tstruct _SoundCharacteristics noattr)))
        (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
  (Sifthenelse (Ebinop Oand (Etempvar _t'1 tuint)
                 (Econst_int (Int.repr 16) tint) tuint)
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sSoundBanksThatLowerBackgroundMusic tushort))
        (Sassign (Evar _sSoundBanksThatLowerBackgroundMusic tushort)
          (Ebinop Oand (Etempvar _t'2 tushort)
            (Ebinop Oxor
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Etempvar _bank tuchar) tint)
              (Econst_int (Int.repr 65535) tint) tint) tint)))
      (Scall None
        (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                             cc_default))
        ((Econst_int (Int.repr 50) tint) :: nil)))
    Sskip))
|}.

Definition f_select_current_sounds := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: nil);
  fn_vars := ((_liveSoundPriorities, (tarray tuint 16)) ::
              (_liveSoundIndices, (tarray tuchar 16)) ::
              (_liveSoundStatuses, (tarray tuchar 16)) :: nil);
  fn_temps := ((_isDiscreteAndStatus, tuint) ::
               (_latestSoundIndex, tuchar) :: (_i, tuchar) :: (_j, tuchar) ::
               (_soundIndex, tuchar) :: (_numSoundsInBank, tuchar) ::
               (_requestedPriority, tuchar) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tfloat) :: (_t'3, tint) :: (_t'2, tuchar) ::
               (_t'1, tuchar) :: (_t'77, tuchar) :: (_t'76, tuint) ::
               (_t'75, tuint) :: (_t'74, tuchar) :: (_t'73, tuint) ::
               (_t'72, tuchar) :: (_t'71, tuchar) :: (_t'70, tfloat) ::
               (_t'69, (tptr tfloat)) :: (_t'68, tfloat) ::
               (_t'67, (tptr tfloat)) :: (_t'66, tfloat) ::
               (_t'65, (tptr tfloat)) :: (_t'64, tfloat) ::
               (_t'63, (tptr tfloat)) :: (_t'62, tfloat) ::
               (_t'61, (tptr tfloat)) :: (_t'60, tfloat) ::
               (_t'59, (tptr tfloat)) :: (_t'58, tuint) :: (_t'57, tfloat) ::
               (_t'56, (tptr tfloat)) :: (_t'55, tfloat) ::
               (_t'54, tfloat) :: (_t'53, tfloat) ::
               (_t'52, (tptr tfloat)) :: (_t'51, tuint) :: (_t'50, tuchar) ::
               (_t'49, tuchar) :: (_t'48, tuint) :: (_t'47, tuchar) ::
               (_t'46, tuchar) :: (_t'45, tuint) :: (_t'44, tuchar) ::
               (_t'43, tuchar) :: (_t'42, tuint) :: (_t'41, tuint) ::
               (_t'40, tuchar) :: (_t'39, tuchar) :: (_t'38, tuchar) ::
               (_t'37, tuchar) :: (_t'36, tuchar) :: (_t'35, tuchar) ::
               (_t'34, tuchar) :: (_t'33, tuchar) :: (_t'32, tuchar) ::
               (_t'31, tuchar) :: (_t'30, tuchar) :: (_t'29, tuint) ::
               (_t'28, tuchar) :: (_t'27, tuint) :: (_t'26, tuchar) ::
               (_t'25, tuchar) :: (_t'24, tuchar) :: (_t'23, tuchar) ::
               (_t'22, tuchar) :: (_t'21, tuchar) :: (_t'20, tuchar) ::
               (_t'19, tuchar) :: (_t'18, tuchar) :: (_t'17, tuchar) ::
               (_t'16, tuchar) :: (_t'15, tuchar) :: (_t'14, tuchar) ::
               (_t'13, tuint) :: (_t'12, tuchar) :: (_t'11, tuchar) ::
               (_t'10, tuchar) :: (_t'9, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
        (Econst_int (Int.repr 0) tint) (tptr tuint)) tuint)
    (Econst_int (Int.repr 268435456) tint))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
          (Econst_int (Int.repr 1) tint) (tptr tuint)) tuint)
      (Econst_int (Int.repr 268435456) tint))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
            (Econst_int (Int.repr 2) tint) (tptr tuint)) tuint)
        (Econst_int (Int.repr 268435456) tint))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
              (Econst_int (Int.repr 3) tint) (tptr tuint)) tuint)
          (Econst_int (Int.repr 268435456) tint))
        (Ssequence
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
                (Econst_int (Int.repr 4) tint) (tptr tuint)) tuint)
            (Econst_int (Int.repr 268435456) tint))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
                  (Econst_int (Int.repr 5) tint) (tptr tuint)) tuint)
              (Econst_int (Int.repr 268435456) tint))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _liveSoundPriorities (tarray tuint 16))
                    (Econst_int (Int.repr 6) tint) (tptr tuint)) tuint)
                (Econst_int (Int.repr 268435456) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Evar _liveSoundPriorities (tarray tuint 16))
                      (Econst_int (Int.repr 7) tint) (tptr tuint)) tuint)
                  (Econst_int (Int.repr 268435456) tint))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Evar _liveSoundPriorities (tarray tuint 16))
                        (Econst_int (Int.repr 8) tint) (tptr tuint)) tuint)
                    (Econst_int (Int.repr 268435456) tint))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Evar _liveSoundPriorities (tarray tuint 16))
                          (Econst_int (Int.repr 9) tint) (tptr tuint)) tuint)
                      (Econst_int (Int.repr 268435456) tint))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Evar _liveSoundPriorities (tarray tuint 16))
                            (Econst_int (Int.repr 10) tint) (tptr tuint))
                          tuint) (Econst_int (Int.repr 268435456) tint))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Evar _liveSoundPriorities (tarray tuint 16))
                              (Econst_int (Int.repr 11) tint) (tptr tuint))
                            tuint) (Econst_int (Int.repr 268435456) tint))
                        (Ssequence
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Evar _liveSoundPriorities (tarray tuint 16))
                                (Econst_int (Int.repr 12) tint) (tptr tuint))
                              tuint) (Econst_int (Int.repr 268435456) tint))
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _liveSoundPriorities (tarray tuint 16))
                                  (Econst_int (Int.repr 13) tint)
                                  (tptr tuint)) tuint)
                              (Econst_int (Int.repr 268435456) tint))
                            (Ssequence
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _liveSoundPriorities (tarray tuint 16))
                                    (Econst_int (Int.repr 14) tint)
                                    (tptr tuint)) tuint)
                                (Econst_int (Int.repr 268435456) tint))
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _liveSoundPriorities (tarray tuint 16))
                                      (Econst_int (Int.repr 15) tint)
                                      (tptr tuint)) tuint)
                                  (Econst_int (Int.repr 268435456) tint))
                                (Ssequence
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _liveSoundIndices (tarray tuchar 16))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr tuchar)) tuchar)
                                    (Econst_int (Int.repr 255) tint))
                                  (Ssequence
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _liveSoundIndices (tarray tuchar 16))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tuchar)) tuchar)
                                      (Econst_int (Int.repr 255) tint))
                                    (Ssequence
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _liveSoundIndices (tarray tuchar 16))
                                            (Econst_int (Int.repr 2) tint)
                                            (tptr tuchar)) tuchar)
                                        (Econst_int (Int.repr 255) tint))
                                      (Ssequence
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _liveSoundIndices (tarray tuchar 16))
                                              (Econst_int (Int.repr 3) tint)
                                              (tptr tuchar)) tuchar)
                                          (Econst_int (Int.repr 255) tint))
                                        (Ssequence
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _liveSoundIndices (tarray tuchar 16))
                                                (Econst_int (Int.repr 4) tint)
                                                (tptr tuchar)) tuchar)
                                            (Econst_int (Int.repr 255) tint))
                                          (Ssequence
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _liveSoundIndices (tarray tuchar 16))
                                                  (Econst_int (Int.repr 5) tint)
                                                  (tptr tuchar)) tuchar)
                                              (Econst_int (Int.repr 255) tint))
                                            (Ssequence
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                    (Econst_int (Int.repr 6) tint)
                                                    (tptr tuchar)) tuchar)
                                                (Econst_int (Int.repr 255) tint))
                                              (Ssequence
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _liveSoundIndices (tarray tuchar 16))
                                                      (Econst_int (Int.repr 7) tint)
                                                      (tptr tuchar)) tuchar)
                                                  (Econst_int (Int.repr 255) tint))
                                                (Ssequence
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _liveSoundIndices (tarray tuchar 16))
                                                        (Econst_int (Int.repr 8) tint)
                                                        (tptr tuchar))
                                                      tuchar)
                                                    (Econst_int (Int.repr 255) tint))
                                                  (Ssequence
                                                    (Sassign
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _liveSoundIndices (tarray tuchar 16))
                                                          (Econst_int (Int.repr 9) tint)
                                                          (tptr tuchar))
                                                        tuchar)
                                                      (Econst_int (Int.repr 255) tint))
                                                    (Ssequence
                                                      (Sassign
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _liveSoundIndices (tarray tuchar 16))
                                                            (Econst_int (Int.repr 10) tint)
                                                            (tptr tuchar))
                                                          tuchar)
                                                        (Econst_int (Int.repr 255) tint))
                                                      (Ssequence
                                                        (Sassign
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _liveSoundIndices (tarray tuchar 16))
                                                              (Econst_int (Int.repr 11) tint)
                                                              (tptr tuchar))
                                                            tuchar)
                                                          (Econst_int (Int.repr 255) tint))
                                                        (Ssequence
                                                          (Sassign
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Evar _liveSoundIndices (tarray tuchar 16))
                                                                (Econst_int (Int.repr 12) tint)
                                                                (tptr tuchar))
                                                              tuchar)
                                                            (Econst_int (Int.repr 255) tint))
                                                          (Ssequence
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _liveSoundIndices (tarray tuchar 16))
                                                                  (Econst_int (Int.repr 13) tint)
                                                                  (tptr tuchar))
                                                                tuchar)
                                                              (Econst_int (Int.repr 255) tint))
                                                            (Ssequence
                                                              (Sassign
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 14) tint)
                                                                    (tptr tuchar))
                                                                  tuchar)
                                                                (Econst_int (Int.repr 255) tint))
                                                              (Ssequence
                                                                (Sassign
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                  (Econst_int (Int.repr 255) tint))
                                                                (Ssequence
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                  (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 3) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 4) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 5) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 7) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 9) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 10) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 11) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 12) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 13) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 14) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Ssequence
                                                                    (Sset _numSoundsInBank
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'77
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _next
                                                                    tuchar))
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Etempvar _t'77 tuchar)
                                                                    tuchar)))
                                                                    (Ssequence
                                                                    (Swhile
                                                                    (Ebinop One
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _latestSoundIndex
                                                                    (Ecast
                                                                    (Etempvar _soundIndex tuchar)
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'75
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'75 tuint)
                                                                    (Ebinop Oor
                                                                    (Econst_int (Int.repr 128) tint)
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Ebinop Oor
                                                                    (Econst_int (Int.repr 128) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'1
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _freshness
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _freshness
                                                                    tuchar)
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'1 tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'1 tuchar)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint))
                                                                    Sskip))
                                                                    (Ssequence
                                                                    (Sset _t'76
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'76 tuint)
                                                                    (Econst_int (Int.repr 128) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'2
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _freshness
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _freshness
                                                                    tuchar)
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'2 tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'2 tuchar)
                                                                    (Ebinop Osub
                                                                    (Econst_int (Int.repr 10) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Scall None
                                                                    (Evar _update_background_music_after_sound
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    Sskip))
                                                                    Sskip))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'73
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'73 tuint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'74
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sset _t'3
                                                                    (Ecast
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'74 tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tbool)))
                                                                    (Sset _t'3
                                                                    (Econst_int (Int.repr 0) tint))))
                                                                    (Sifthenelse (Etempvar _t'3 tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'72
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _prev
                                                                    tuchar))
                                                                    (Sset _latestSoundIndex
                                                                    (Ecast
                                                                    (Etempvar _t'72 tuchar)
                                                                    tuchar)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 0) tint))
                                                                    (Scall None
                                                                    (Evar _delete_sound_from_bank
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))))
                                                                    Sskip))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'71
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop One
                                                                    (Etempvar _t'71 tuchar)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (Sset _t'5
                                                                    (Ecast
                                                                    (Ebinop Oeq
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Etempvar _latestSoundIndex tuchar)
                                                                    tint)
                                                                    tbool))
                                                                    (Sset _t'5
                                                                    (Econst_int (Int.repr 0) tint))))
                                                                    (Sifthenelse (Etempvar _t'5 tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'59
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'60
                                                                    (Ederef
                                                                    (Etempvar _t'59 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'61
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'62
                                                                    (Ederef
                                                                    (Etempvar _t'61 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'63
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _y
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'64
                                                                    (Ederef
                                                                    (Etempvar _t'63 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'65
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _y
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'66
                                                                    (Ederef
                                                                    (Etempvar _t'65 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'67
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'68
                                                                    (Ederef
                                                                    (Etempvar _t'67 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'69
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'70
                                                                    (Ederef
                                                                    (Etempvar _t'69 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'4)
                                                                    (Evar _sqrtf
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Ebinop Oadd
                                                                    (Ebinop Oadd
                                                                    (Ebinop Omul
                                                                    (Etempvar _t'60 tfloat)
                                                                    (Etempvar _t'62 tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Etempvar _t'64 tfloat)
                                                                    (Etempvar _t'66 tfloat)
                                                                    tfloat)
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Etempvar _t'68 tfloat)
                                                                    (Etempvar _t'70 tfloat)
                                                                    tfloat)
                                                                    tfloat) ::
                                                                    nil))))))))))))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _distance
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Etempvar _t'4 tfloat)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tfloat)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'58
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sset _requestedPriority
                                                                    (Ecast
                                                                    (Ebinop Oshr
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'58 tuint)
                                                                    (Econst_int (Int.repr 65280) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tuint)
                                                                    tuchar)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'51
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'51 tuint)
                                                                    (Econst_int (Int.repr 67108864) tint)
                                                                    tuint)
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _priority
                                                                    tuint)
                                                                    (Ebinop Omul
                                                                    (Econst_int (Int.repr 76) tint)
                                                                    (Ebinop Osub
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    (Etempvar _requestedPriority tuchar)
                                                                    tint)
                                                                    tint))
                                                                    (Ssequence
                                                                    (Sset _t'52
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'53
                                                                    (Ederef
                                                                    (Etempvar _t'52 (tptr tfloat))
                                                                    tfloat))
                                                                    (Sifthenelse
                                                                    (Ebinop Ogt
                                                                    (Etempvar _t'53 tfloat)
                                                                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'55
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _distance
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'56
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'57
                                                                    (Ederef
                                                                    (Etempvar _t'56 (tptr tfloat))
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _priority
                                                                    tuint)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Oadd
                                                                    (Ecast
                                                                    (Etempvar _t'55 tfloat)
                                                                    tuint)
                                                                    (Ecast
                                                                    (Ebinop Odiv
                                                                    (Etempvar _t'57 tfloat)
                                                                    (Econst_float (Float.of_bits (Int64.repr 4618441417868443648)) tdouble)
                                                                    tdouble)
                                                                    tuint)
                                                                    tuint)
                                                                    (Ebinop Omul
                                                                    (Econst_int (Int.repr 76) tint)
                                                                    (Ebinop Osub
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    (Etempvar _requestedPriority tuchar)
                                                                    tint)
                                                                    tint)
                                                                    tuint)))))
                                                                    (Ssequence
                                                                    (Sset _t'54
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _distance
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _priority
                                                                    tuint)
                                                                    (Ebinop Oadd
                                                                    (Ecast
                                                                    (Etempvar _t'54 tfloat)
                                                                    tuint)
                                                                    (Ebinop Omul
                                                                    (Econst_int (Int.repr 76) tint)
                                                                    (Ebinop Osub
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    (Etempvar _requestedPriority tuchar)
                                                                    tint)
                                                                    tint)
                                                                    tuint))))))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'50
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Olt
                                                                    (Etempvar _i tuchar)
                                                                    (Etempvar _t'50 tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                    (Ssequence
                                                                    (Sset _t'41
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundPriorities (tarray tuint 16))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuint))
                                                                    tuint))
                                                                    (Ssequence
                                                                    (Sset _t'42
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _priority
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oge
                                                                    (Etempvar _t'41 tuint)
                                                                    (Etempvar _t'42 tuint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'49
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sset _j
                                                                    (Ecast
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'49 tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar)))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Sifthenelse
                                                                    (Ebinop Ogt
                                                                    (Etempvar _j tuchar)
                                                                    (Etempvar _i tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'48
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundPriorities (tarray tuint 16))
                                                                    (Ebinop Osub
                                                                    (Etempvar _j tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tuint))
                                                                    tuint))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundPriorities (tarray tuint 16))
                                                                    (Etempvar _j tuchar)
                                                                    (tptr tuint))
                                                                    tuint)
                                                                    (Etempvar _t'48 tuint)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'47
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Ebinop Osub
                                                                    (Etempvar _j tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _j tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _t'47 tuchar)))
                                                                    (Ssequence
                                                                    (Sset _t'46
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Ebinop Osub
                                                                    (Etempvar _j tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Etempvar _j tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _t'46 tuchar))))))
                                                                    (Sset _j
                                                                    (Ecast
                                                                    (Ebinop Osub
                                                                    (Etempvar _j tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'45
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _priority
                                                                    tuint))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundPriorities (tarray tuint 16))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuint))
                                                                    tuint)
                                                                    (Etempvar _t'45 tuint)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _soundIndex tuchar))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'44
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundStatuses (tarray tuchar 16))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _t'44 tuchar)))
                                                                    (Ssequence
                                                                    (Sset _t'43
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Etempvar _t'43 tuchar)
                                                                    tuchar)))))))
                                                                    Sskip))))
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _i tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))
                                                                    (Sset _numSoundsInBank
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _numSoundsInBank tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))))
                                                                    Sskip))
                                                                    (Ssequence
                                                                    (Sset _t'40
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _latestSoundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _next
                                                                    tuchar))
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Etempvar _t'40 tuchar)
                                                                    tuchar))))))))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sNumSoundsInBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _numSoundsInBank tuchar))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'39
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _t'39 tuchar)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'38
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Olt
                                                                    (Etempvar _i tuchar)
                                                                    (Etempvar _t'38 tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'37
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Olt
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Etempvar _t'37 tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'34
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop One
                                                                    (Etempvar _t'34 tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'35
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'36
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sset _t'6
                                                                    (Ecast
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'35 tuchar)
                                                                    (Etempvar _t'36 tuchar)
                                                                    tint)
                                                                    tbool))))
                                                                    (Sset _t'6
                                                                    (Econst_int (Int.repr 0) tint))))
                                                                    (Sifthenelse (Etempvar _t'6 tint)
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 254) tint)
                                                                    tuchar)))
                                                                    Sskip)))
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))
                                                                    (Sifthenelse
                                                                    (Ebinop One
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'17
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop One
                                                                    (Etempvar _t'17 tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'28
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'29
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'28 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'29 tuint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'30
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'31
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'30 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'31 tuchar)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'33
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'33 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    (Ssequence
                                                                    (Sset _t'32
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Scall None
                                                                    (Evar _delete_sound_from_bank
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _t'32 tuchar) ::
                                                                    nil))))
                                                                    Sskip)))
                                                                    Sskip)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'26
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'27
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'26 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sset _isDiscreteAndStatus
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'27 tuint)
                                                                    (Ebinop Oor
                                                                    (Econst_int (Int.repr 128) tint)
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    tint)
                                                                    tuint))))
                                                                    (Ssequence
                                                                    (Sifthenelse
                                                                    (Ebinop Oge
                                                                    (Etempvar _isDiscreteAndStatus tuint)
                                                                    (Ebinop Oor
                                                                    (Econst_int (Int.repr 128) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'24
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'25
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'24 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sset _t'8
                                                                    (Ecast
                                                                    (Ebinop One
                                                                    (Etempvar _t'25 tuchar)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    tbool))))
                                                                    (Sset _t'8
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    (Sifthenelse (Etempvar _t'8 tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'23
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'23 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint)
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'22
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'22 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    (Ssequence
                                                                    (Sset _t'21
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Scall None
                                                                    (Evar _delete_sound_from_bank
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _t'21 tuchar) ::
                                                                    nil)))))
                                                                    (Ssequence
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _isDiscreteAndStatus tuint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _t'19
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'20
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'19 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar))
                                                                    (Sset _t'7
                                                                    (Ecast
                                                                    (Ebinop One
                                                                    (Etempvar _t'20 tuchar)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    tbool))))
                                                                    (Sset _t'7
                                                                    (Econst_int (Int.repr 0) tint)))
                                                                    (Sifthenelse (Etempvar _t'7 tint)
                                                                    (Ssequence
                                                                    (Sset _t'18
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'18 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundStatus
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 1) tint)))
                                                                    Sskip))))))
                                                                    Sskip))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint)))
                                                                    Sskip)))
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _i tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))
                                                                    (Ssequence
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'16
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Olt
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Etempvar _t'16 tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                    (Ssequence
                                                                    (Sset _t'9
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop One
                                                                    (Etempvar _t'9 tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuchar))
                                                                    (Sloop
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'15
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Olt
                                                                    (Etempvar _i tuchar)
                                                                    (Etempvar _t'15 tuchar)
                                                                    tint)
                                                                    Sskip
                                                                    Sbreak))
                                                                    (Ssequence
                                                                    (Sset _t'10
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Etempvar _t'10 tuchar)
                                                                    (Econst_int (Int.repr 255) tint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'14
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray tuchar 1)))
                                                                    (tarray tuchar 1))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Etempvar _t'14 tuchar)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'11
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'12
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Ssequence
                                                                    (Sset _t'13
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'12 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _t'11 tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'13 tuint)
                                                                    (Eunop Onotint
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tuint)))))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _liveSoundIndices (tarray tuchar 16))
                                                                    (Etempvar _i tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar)
                                                                    (Econst_int (Int.repr 255) tint))
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 254) tint)
                                                                    tuchar)))))
                                                                    Sskip)))
                                                                    (Sset _i
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _i tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))
                                                                    Sskip)))
                                                                    (Sset _soundIndex
                                                                    (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))))))))))))))))))))))))))))))))))))))))))))))))))))))))))
|}.

Definition f_get_sound_pan := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_x, tfloat) :: (_z, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_absX, tfloat) :: (_absZ, tfloat) :: (_pan, tfloat) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _x tfloat)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _t'1 (Ecast (Eunop Oneg (Etempvar _x tfloat) tfloat) tfloat))
      (Sset _t'1 (Ecast (Etempvar _x tfloat) tfloat)))
    (Sset _absX (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _absX tfloat)
                   (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                   tint)
      (Sset _absX
        (Ecast
          (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
          tfloat))
      Sskip)
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _z tfloat)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sset _t'2 (Ecast (Eunop Oneg (Etempvar _z tfloat) tfloat) tfloat))
          (Sset _t'2 (Ecast (Etempvar _z tfloat) tfloat)))
        (Sset _absZ (Etempvar _t'2 tfloat)))
      (Ssequence
        (Sifthenelse (Ebinop Ogt (Etempvar _absZ tfloat)
                       (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                       tint)
          (Sset _absZ
            (Ecast
              (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
              tfloat))
          Sskip)
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _x tfloat)
                           (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                           tint)
              (Sset _t'5
                (Ecast
                  (Ebinop Oeq (Etempvar _z tfloat)
                    (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                    tint) tbool))
              (Sset _t'5 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'5 tint)
              (Sset _pan
                (Ecast
                  (Econst_float (Float.of_bits (Int64.repr 4602678819172646912)) tdouble)
                  tfloat))
              (Ssequence
                (Sifthenelse (Ebinop Oge (Etempvar _x tfloat)
                               (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                               tint)
                  (Sset _t'4
                    (Ecast
                      (Ebinop Oge (Etempvar _absX tfloat)
                        (Etempvar _absZ tfloat) tint) tbool))
                  (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Sset _pan
                    (Ecast
                      (Ebinop Osub
                        (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                        (Ebinop Odiv
                          (Ebinop Osub
                            (Ebinop Omul (Econst_int (Int.repr 2) tint)
                              (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                              tdouble) (Etempvar _absX tfloat) tdouble)
                          (Ebinop Omul
                            (Econst_float (Float.of_bits (Int64.repr 4613937818241073152)) tdouble)
                            (Ebinop Osub
                              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                                tdouble) (Etempvar _absZ tfloat) tdouble)
                            tdouble) tdouble) tdouble) tfloat))
                  (Ssequence
                    (Sifthenelse (Ebinop Olt (Etempvar _x tfloat)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Sset _t'3
                        (Ecast
                          (Ebinop Ogt (Etempvar _absX tfloat)
                            (Etempvar _absZ tfloat) tint) tbool))
                      (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Sset _pan
                        (Ecast
                          (Ebinop Odiv
                            (Ebinop Osub
                              (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                                tdouble) (Etempvar _absX tfloat) tdouble)
                            (Ebinop Omul
                              (Econst_float (Float.of_bits (Int64.repr 4613937818241073152)) tdouble)
                              (Ebinop Osub
                                (Ebinop Omul (Econst_int (Int.repr 2) tint)
                                  (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                                  tdouble) (Etempvar _absZ tfloat) tdouble)
                              tdouble) tdouble) tfloat))
                      (Sset _pan
                        (Ecast
                          (Ebinop Oadd
                            (Econst_float (Float.of_bits (Int64.repr 4602678819172646912)) tdouble)
                            (Ebinop Odiv (Etempvar _x tfloat)
                              (Ebinop Omul
                                (Econst_float (Float.of_bits (Int64.repr 4618441417868443648)) tdouble)
                                (Etempvar _absZ tfloat) tdouble) tdouble)
                            tdouble) tfloat))))))))
          (Sreturn (Some (Etempvar _pan tfloat))))))))
|}.

Definition f_get_sound_volume := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_soundIndex, tuchar) ::
                (_volumeRange, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_maxSoundDistance, tfloat) :: (_intensity, tfloat) ::
               (_t'7, tushort) :: (_t'6, tshort) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef
          (Ebinop Oadd
            (Ederef
              (Ebinop Oadd
                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                (Etempvar _bank tuchar)
                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
              (tarray (Tstruct _SoundCharacteristics noattr) 40))
            (Etempvar _soundIndex tuchar)
            (tptr (Tstruct _SoundCharacteristics noattr)))
          (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'1 tuint)
                     (Econst_int (Int.repr 16777216) tint) tuint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6 (Evar _gCurrLevelNum tshort))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Evar _sLevelAcousticReaches (tarray tushort 39))
                  (Etempvar _t'6 tshort) (tptr tushort)) tushort))
            (Sset _maxSoundDistance (Ecast (Etempvar _t'7 tushort) tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                        (Etempvar _bank tuchar)
                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                    (Etempvar _soundIndex tuchar)
                    (tptr (Tstruct _SoundCharacteristics noattr)))
                  (Tstruct _SoundCharacteristics noattr)) _distance tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _maxSoundDistance tfloat)
                           (Etempvar _t'4 tfloat) tint)
              (Sset _intensity
                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                            (Etempvar _bank tuchar)
                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                        (Etempvar _soundIndex tuchar)
                        (tptr (Tstruct _SoundCharacteristics noattr)))
                      (Tstruct _SoundCharacteristics noattr)) _distance
                    tfloat))
                (Sset _intensity
                  (Ecast
                    (Ebinop Osub
                      (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                      (Ebinop Odiv (Etempvar _t'5 tfloat)
                        (Etempvar _maxSoundDistance tfloat) tfloat) tdouble)
                    tfloat)))))
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                        (Etempvar _bank tuchar)
                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                    (Etempvar _soundIndex tuchar)
                    (tptr (Tstruct _SoundCharacteristics noattr)))
                  (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
            (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                           (Econst_int (Int.repr 33554432) tint) tuint)
              (Sifthenelse (Ebinop One (Etempvar _intensity tfloat)
                             (Econst_float (Float.of_bits (Int64.repr 0)) tdouble)
                             tint)
                (Ssequence
                  (Sset _t'3 (Evar _gAudioRandom tuint))
                  (Sset _intensity
                    (Ecast
                      (Ebinop Osub (Etempvar _intensity tfloat)
                        (Ebinop Odiv
                          (Ecast
                            (Ebinop Oand (Etempvar _t'3 tuint)
                              (Econst_int (Int.repr 15) tint) tuint) tfloat)
                          (Econst_float (Float.of_bits (Int64.repr 4640959416005296128)) tdouble)
                          tdouble) tdouble) tfloat)))
                Sskip)
              Sskip))))
      (Sset _intensity
        (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat))))
  (Sreturn (Some (Ebinop Osub
                   (Ebinop Oadd
                     (Ebinop Omul
                       (Ebinop Omul (Etempvar _volumeRange tfloat)
                         (Etempvar _intensity tfloat) tfloat)
                       (Etempvar _intensity tfloat) tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                     tfloat) (Etempvar _volumeRange tfloat) tfloat))))
|}.

Definition f_get_sound_freq_scale := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_item, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_amount, tfloat) :: (_t'4, tfloat) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef
          (Ebinop Oadd
            (Ederef
              (Ebinop Oadd
                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                (Etempvar _bank tuchar)
                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
              (tarray (Tstruct _SoundCharacteristics noattr) 40))
            (Etempvar _item tuchar)
            (tptr (Tstruct _SoundCharacteristics noattr)))
          (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'1 tuint)
                     (Econst_int (Int.repr 134217728) tint) tuint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _item tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _distance tfloat))
          (Sset _amount
            (Ecast
              (Ebinop Odiv (Etempvar _t'4 tfloat)
                (Econst_float (Float.of_bits (Int64.repr 4671776527908601856)) tdouble)
                tdouble) tfloat)))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _item tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                         (Econst_int (Int.repr 33554432) tint) tuint)
            (Ssequence
              (Sset _t'3 (Evar _gAudioRandom tuint))
              (Sset _amount
                (Ecast
                  (Ebinop Oadd (Etempvar _amount tfloat)
                    (Ebinop Odiv
                      (Ecast
                        (Ebinop Oand (Etempvar _t'3 tuint)
                          (Econst_int (Int.repr 255) tint) tuint) tfloat)
                      (Econst_float (Float.of_bits (Int64.repr 4634204016564240384)) tdouble)
                      tdouble) tdouble) tfloat)))
            Sskip)))
      (Sset _amount (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))))
  (Sreturn (Some (Ebinop Oadd
                   (Ebinop Odiv (Etempvar _amount tfloat)
                     (Econst_float (Float.of_bits (Int64.repr 4624633867356078080)) tdouble)
                     tdouble)
                   (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                   tdouble))))
|}.

Definition f_get_sound_reverb := {|
  fn_return := tuchar;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_soundIndex, tuchar) ::
                (_channelIndex, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_area, tuchar) :: (_level, tuchar) :: (_reverb, tuchar) ::
               (_t'1, tint) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'4, tuchar) :: (_t'3, tschar) ::
               (_t'2, (tptr (Tstruct _SequenceChannel noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gCurrLevelNum tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tshort)
                     (Econst_int (Int.repr 38) tint) tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 38) tint) tint))
        (Ssequence
          (Sset _t'9 (Evar _gCurrLevelNum tshort))
          (Sset _t'1 (Ecast (Etempvar _t'9 tshort) tint)))))
    (Sset _level (Ecast (Etempvar _t'1 tint) tuchar)))
  (Ssequence
    (Ssequence
      (Sset _t'7 (Evar _gCurrAreaIndex tshort))
      (Sset _area
        (Ecast
          (Ebinop Osub (Etempvar _t'7 tshort) (Econst_int (Int.repr 1) tint)
            tint) tuchar)))
    (Ssequence
      (Sifthenelse (Ebinop Ogt (Etempvar _area tuchar)
                     (Econst_int (Int.repr 2) tint) tint)
        (Sset _area (Ecast (Econst_int (Int.repr 2) tint) tuchar))
        Sskip)
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                      (Econst_int (Int.repr 2) tint)
                      (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _channels
                  (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                (Etempvar _channelIndex tuchar)
                (tptr (tptr (Tstruct _SequenceChannel noattr))))
              (tptr (Tstruct _SequenceChannel noattr))))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _t'2 (tptr (Tstruct _SequenceChannel noattr)))
                      (Tstruct _SequenceChannel noattr)) _soundScriptIO
                    (tarray tschar 8)) (Econst_int (Int.repr 5) tint)
                  (tptr tschar)) tschar))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sLevelAreaReverbs (tarray (tarray tuchar 3) 39))
                        (Etempvar _level tuchar) (tptr (tarray tuchar 3)))
                      (tarray tuchar 3)) (Etempvar _area tuchar)
                    (tptr tuchar)) tuchar))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                            (Econst_int (Int.repr 2) tint)
                            (tptr (Tstruct _SequencePlayer noattr)))
                          (Tstruct _SequencePlayer noattr)) _channels
                        (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                      (Etempvar _channelIndex tuchar)
                      (tptr (tptr (Tstruct _SequenceChannel noattr))))
                    (tptr (Tstruct _SequenceChannel noattr))))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _t'5 (tptr (Tstruct _SequenceChannel noattr)))
                        (Tstruct _SequenceChannel noattr)) _volume tfloat))
                  (Sset _reverb
                    (Ecast
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Oadd (Ecast (Etempvar _t'3 tschar) tuchar)
                            (Etempvar _t'4 tuchar) tint)
                          (Ebinop Omul
                            (Ebinop Osub
                              (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                              (Etempvar _t'6 tfloat) tdouble)
                            (Econst_float (Float.of_bits (Int64.repr 4631952216750555136)) tdouble)
                            tdouble) tdouble) tuchar) tuchar)))))))
        (Ssequence
          (Sifthenelse (Ebinop Ogt (Etempvar _reverb tuchar)
                         (Econst_int (Int.repr 127) tint) tint)
            (Sset _reverb (Ecast (Econst_int (Int.repr 127) tint) tuchar))
            Sskip)
          (Sreturn (Some (Etempvar _reverb tuchar))))))))
|}.

Definition f_noop_8031EEC8 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_audio_signal_game_loop_tick := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign (Evar _sGameLoopTicked tint) (Econst_int (Int.repr 1) tint))
  (Scall None (Evar _noop_8031EEC8 (Tfunction nil tvoid cc_default)) nil))
|}.

Definition f_update_game_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_soundStatus, tuchar) :: (_i, tuchar) ::
               (_soundId, tuchar) :: (_bank, tuchar) ::
               (_channelIndex, tuchar) :: (_soundIndex, tuchar) ::
               (_value, tfloat) :: (_t'29, tint) :: (_t'28, tfloat) ::
               (_t'27, tfloat) :: (_t'26, tfloat) :: (_t'25, tuchar) ::
               (_t'24, tuchar) :: (_t'23, tfloat) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tuchar) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tuchar) :: (_t'10, tuchar) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tuchar) :: (_t'5, tfloat) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'115, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'114, tuchar) :: (_t'113, tuchar) :: (_t'112, tuint) ::
               (_t'111, tuint) :: (_t'110, tushort) :: (_t'109, tuint) ::
               (_t'108, tuint) ::
               (_t'107, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'106, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'105, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'104, tuchar) ::
               (_t'103, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'102, tuchar) :: (_t'101, tfloat) ::
               (_t'100, (tptr tfloat)) :: (_t'99, tfloat) ::
               (_t'98, (tptr tfloat)) ::
               (_t'97, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'96, tuchar) ::
               (_t'95, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'94, tuchar) ::
               (_t'93, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'92, tuint) ::
               (_t'91, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'90, tuint) ::
               (_t'89, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'88, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'87, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'86, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'85, tfloat) :: (_t'84, (tptr tfloat)) ::
               (_t'83, tfloat) :: (_t'82, (tptr tfloat)) ::
               (_t'81, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'80, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'79, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'78, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'77, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'76, tfloat) :: (_t'75, (tptr tfloat)) ::
               (_t'74, tfloat) :: (_t'73, (tptr tfloat)) ::
               (_t'72, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'71, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'70, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'69, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'68, tuchar) ::
               (_t'67, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'66, tuchar) :: (_t'65, tfloat) ::
               (_t'64, (tptr tfloat)) :: (_t'63, tfloat) ::
               (_t'62, (tptr tfloat)) ::
               (_t'61, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'60, tuchar) ::
               (_t'59, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'58, tuchar) ::
               (_t'57, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'56, tuint) ::
               (_t'55, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'54, tuint) ::
               (_t'53, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'52, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'51, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'50, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'49, tfloat) :: (_t'48, (tptr tfloat)) ::
               (_t'47, tfloat) :: (_t'46, (tptr tfloat)) ::
               (_t'45, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'44, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'43, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'42, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'41, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'40, tfloat) :: (_t'39, (tptr tfloat)) ::
               (_t'38, tfloat) :: (_t'37, (tptr tfloat)) ::
               (_t'36, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'35, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'34, tschar) ::
               (_t'33, (tptr (Tstruct _SequenceChannelLayer noattr))) ::
               (_t'32, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'31, tuchar) :: (_t'30, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _channelIndex (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Scall None
      (Evar _process_all_sound_requests (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Scall None
        (Evar _process_level_music_dynamics (Tfunction nil tvoid cc_default))
        nil)
      (Ssequence
        (Ssequence
          (Sset _t'115
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                      (Econst_int (Int.repr 2) tint)
                      (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _channels
                  (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                (Econst_int (Int.repr 0) tint)
                (tptr (tptr (Tstruct _SequenceChannel noattr))))
              (tptr (Tstruct _SequenceChannel noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'115 (tptr (Tstruct _SequenceChannel noattr)))
                         (Eaddrof
                           (Evar _gSequenceChannelNone (Tstruct _SequenceChannel noattr))
                           (tptr (Tstruct _SequenceChannel noattr))) tint)
            (Sreturn None)
            Sskip))
        (Ssequence
          (Sset _bank (Ecast (Econst_int (Int.repr 0) tint) tuchar))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _bank tuchar)
                             (Econst_int (Int.repr 10) tint) tint)
                Sskip
                Sbreak)
              (Ssequence
                (Scall None
                  (Evar _select_current_sounds (Tfunction (tuchar :: nil)
                                                 tvoid cc_default))
                  ((Etempvar _bank tuchar) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                                       (Econst_int (Int.repr 1) tint) tint)
                          Sskip
                          Sbreak)
                        (Ssequence
                          (Ssequence
                            (Sset _t'114
                              (Ederef
                                (Ebinop Oadd
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                                      (Etempvar _bank tuchar)
                                      (tptr (tarray tuchar 1)))
                                    (tarray tuchar 1)) (Etempvar _i tuchar)
                                  (tptr tuchar)) tuchar))
                            (Sset _soundIndex
                              (Ecast (Etempvar _t'114 tuchar) tuchar)))
                          (Ssequence
                            (Ssequence
                              (Sifthenelse (Ebinop Olt
                                             (Etempvar _soundIndex tuchar)
                                             (Econst_int (Int.repr 255) tint)
                                             tint)
                                (Ssequence
                                  (Sset _t'113
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                              (Etempvar _bank tuchar)
                                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                          (Etempvar _soundIndex tuchar)
                                          (tptr (Tstruct _SoundCharacteristics noattr)))
                                        (Tstruct _SoundCharacteristics noattr))
                                      _soundStatus tuchar))
                                  (Sset _t'29
                                    (Ecast
                                      (Ebinop One (Etempvar _t'113 tuchar)
                                        (Econst_int (Int.repr 0) tint) tint)
                                      tbool)))
                                (Sset _t'29 (Econst_int (Int.repr 0) tint)))
                              (Sifthenelse (Etempvar _t'29 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'112
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                (Etempvar _bank tuchar)
                                                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                              (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                            (Etempvar _soundIndex tuchar)
                                            (tptr (Tstruct _SoundCharacteristics noattr)))
                                          (Tstruct _SoundCharacteristics noattr))
                                        _soundBits tuint))
                                    (Sset _soundStatus
                                      (Ecast
                                        (Ebinop Oand (Etempvar _t'112 tuint)
                                          (Econst_int (Int.repr 15) tint)
                                          tuint) tuchar)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'111
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                  (Etempvar _bank tuchar)
                                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                              (Etempvar _soundIndex tuchar)
                                              (tptr (Tstruct _SoundCharacteristics noattr)))
                                            (Tstruct _SoundCharacteristics noattr))
                                          _soundBits tuint))
                                      (Sset _soundId
                                        (Ecast
                                          (Ebinop Oshr
                                            (Etempvar _t'111 tuint)
                                            (Econst_int (Int.repr 16) tint)
                                            tuint) tuchar)))
                                    (Ssequence
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Ebinop Oadd
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                  (Etempvar _bank tuchar)
                                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                              (Etempvar _soundIndex tuchar)
                                              (tptr (Tstruct _SoundCharacteristics noattr)))
                                            (Tstruct _SoundCharacteristics noattr))
                                          _soundStatus tuchar)
                                        (Etempvar _soundStatus tuchar))
                                      (Sifthenelse (Ebinop Oeq
                                                     (Etempvar _soundStatus tuchar)
                                                     (Econst_int (Int.repr 1) tint)
                                                     tint)
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'109
                                              (Efield
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                        (Etempvar _bank tuchar)
                                                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                    (Etempvar _soundIndex tuchar)
                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                  (Tstruct _SoundCharacteristics noattr))
                                                _soundBits tuint))
                                            (Sifthenelse (Ebinop Oand
                                                           (Etempvar _t'109 tuint)
                                                           (Econst_int (Int.repr 16) tint)
                                                           tuint)
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'110
                                                    (Evar _sSoundBanksThatLowerBackgroundMusic tushort))
                                                  (Sassign
                                                    (Evar _sSoundBanksThatLowerBackgroundMusic tushort)
                                                    (Ebinop Oor
                                                      (Etempvar _t'110 tushort)
                                                      (Ebinop Oshl
                                                        (Econst_int (Int.repr 1) tint)
                                                        (Etempvar _bank tuchar)
                                                        tint) tint)))
                                                (Scall None
                                                  (Evar _begin_background_music_fade
                                                  (Tfunction (tushort :: nil)
                                                    tuchar cc_default))
                                                  ((Econst_int (Int.repr 50) tint) ::
                                                   nil)))
                                              Sskip))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'108
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                          (Etempvar _bank tuchar)
                                                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                      (Etempvar _soundIndex tuchar)
                                                      (tptr (Tstruct _SoundCharacteristics noattr)))
                                                    (Tstruct _SoundCharacteristics noattr))
                                                  _soundBits tuint))
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                          (Etempvar _bank tuchar)
                                                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                      (Etempvar _soundIndex tuchar)
                                                      (tptr (Tstruct _SoundCharacteristics noattr)))
                                                    (Tstruct _SoundCharacteristics noattr))
                                                  _soundBits tuint)
                                                (Ebinop Oadd
                                                  (Etempvar _t'108 tuint)
                                                  (Econst_int (Int.repr 1) tint)
                                                  tuint)))
                                            (Ssequence
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                          (Etempvar _bank tuchar)
                                                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                      (Etempvar _soundIndex tuchar)
                                                      (tptr (Tstruct _SoundCharacteristics noattr)))
                                                    (Tstruct _SoundCharacteristics noattr))
                                                  _soundStatus tuchar)
                                                (Econst_int (Int.repr 2) tint))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'107
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                              (Econst_int (Int.repr 2) tint)
                                                              (tptr (Tstruct _SequencePlayer noattr)))
                                                            (Tstruct _SequencePlayer noattr))
                                                          _channels
                                                          (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                        (Etempvar _channelIndex tuchar)
                                                        (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                      (tptr (Tstruct _SequenceChannel noattr))))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'107 (tptr (Tstruct _SequenceChannel noattr)))
                                                            (Tstruct _SequenceChannel noattr))
                                                          _soundScriptIO
                                                          (tarray tschar 8))
                                                        (Econst_int (Int.repr 4) tint)
                                                        (tptr tschar))
                                                      tschar)
                                                    (Etempvar _soundId tuchar)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'106
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                (Econst_int (Int.repr 2) tint)
                                                                (tptr (Tstruct _SequencePlayer noattr)))
                                                              (Tstruct _SequencePlayer noattr))
                                                            _channels
                                                            (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                          (Etempvar _channelIndex tuchar)
                                                          (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                        (tptr (Tstruct _SequenceChannel noattr))))
                                                    (Sassign
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _t'106 (tptr (Tstruct _SequenceChannel noattr)))
                                                              (Tstruct _SequenceChannel noattr))
                                                            _soundScriptIO
                                                            (tarray tschar 8))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr tschar))
                                                        tschar)
                                                      (Econst_int (Int.repr 1) tint)))
                                                  (Sswitch (Etempvar _bank tuchar)
                                                    (LScons (Some 1)
                                                      (Ssequence
                                                        (Sset _t'90
                                                          (Efield
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                (Etempvar _soundIndex tuchar)
                                                                (tptr (Tstruct _SoundCharacteristics noattr)))
                                                              (Tstruct _SoundCharacteristics noattr))
                                                            _soundBits tuint))
                                                        (Sifthenelse
                                                          (Eunop Onotbool
                                                            (Ebinop Oand
                                                              (Etempvar _t'90 tuint)
                                                              (Econst_int (Int.repr 134217728) tint)
                                                              tuint) tint)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'102
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                  tuchar))
                                                              (Sifthenelse
                                                                (Ebinop Ogt
                                                                  (Etempvar _t'102 tuchar)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'1)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'1 tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'105
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'105 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _value tfloat))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'2)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'2 tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'103
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'104
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'103 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Odiv
                                                                    (Ebinop Oadd
                                                                    (Etempvar _t'104 tuchar)
                                                                    (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                                                    tfloat)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tfloat)
                                                                    (Etempvar _value tfloat)
                                                                    tfloat)))))))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'98
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'99
                                                                    (Ederef
                                                                    (Etempvar _t'98 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'100
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'101
                                                                    (Ederef
                                                                    (Etempvar _t'100 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'3)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'99 tfloat) ::
                                                                    (Etempvar _t'101 tfloat) ::
                                                                    nil))))))
                                                                (Ssequence
                                                                  (Sset _t'97
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'97 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'3 tfloat))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'92
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                  (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'92 tuint)
                                                                    (Econst_int (Int.repr 16711680) tint)
                                                                    tuint)
                                                                    (Ebinop Oand
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 28) tint)
                                                                    tuint)
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 23) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 67108864) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16711680) tint)
                                                                    tuint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'4)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'4 tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'95
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'96
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'95 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Odiv
                                                                    (Ecast
                                                                    (Etempvar _t'96 tuchar)
                                                                    tfloat)
                                                                    (Econst_float (Float.of_bits (Int64.repr 4635329916471083008)) tdouble)
                                                                    tdouble)
                                                                    (Etempvar _value tfloat)
                                                                    tdouble)))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'5)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'5 tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'93
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'94
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'93 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Odiv
                                                                    (Ecast
                                                                    (Etempvar _t'94 tuchar)
                                                                    tfloat)
                                                                    (Econst_float (Float.of_bits (Int64.repr 4645744490609377280)) tdouble)
                                                                    tdouble)
                                                                    (Etempvar _value tfloat)
                                                                    tdouble)))))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'6)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'91
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'91 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'6 tuchar))))
                                                                  Sbreak))))
                                                          Sskip))
                                                      (LScons (Some 7)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'89
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                  (Etempvar _channelIndex tuchar)
                                                                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                (tptr (Tstruct _SequenceChannel noattr))))
                                                            (Sassign
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _t'89 (tptr (Tstruct _SequenceChannel noattr)))
                                                                  (Tstruct _SequenceChannel noattr))
                                                                _volume
                                                                tfloat)
                                                              (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'88
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (tptr (Tstruct _SequenceChannel noattr))))
                                                              (Sassign
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _t'88 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                  _pan
                                                                  tfloat)
                                                                (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'87
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                (Sassign
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'87 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))
                                                              Sbreak)))
                                                        (LScons (Some 0)
                                                          Sskip
                                                          (LScons (Some 2)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'7)
                                                                  (Evar _get_sound_volume
                                                                  (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                  ((Etempvar _bank tuchar) ::
                                                                   (Etempvar _soundIndex tuchar) ::
                                                                   (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                   nil))
                                                                (Ssequence
                                                                  (Sset _t'86
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'86 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _t'7 tfloat))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Sset _t'82
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'83
                                                                    (Ederef
                                                                    (Etempvar _t'82 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'84
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'85
                                                                    (Ederef
                                                                    (Etempvar _t'84 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'8)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'83 tfloat) ::
                                                                    (Etempvar _t'85 tfloat) ::
                                                                    nil))))))
                                                                  (Ssequence
                                                                    (Sset _t'81
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'81 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'8 tfloat))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'9)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'80
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'80 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Etempvar _t'9 tfloat))))
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'10)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'79
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'79 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'10 tuchar))))
                                                                    Sbreak))))
                                                            (LScons (Some 3)
                                                              Sskip
                                                              (LScons (Some 4)
                                                                Sskip
                                                                (LScons (Some 5)
                                                                  Sskip
                                                                  (LScons (Some 6)
                                                                    Sskip
                                                                    (LScons (Some 8)
                                                                    Sskip
                                                                    (LScons (Some 9)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'11)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'78
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'78 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'11 tuchar))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'12)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'77
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'77 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _t'12 tfloat))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'73
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'74
                                                                    (Ederef
                                                                    (Etempvar _t'73 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'75
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'76
                                                                    (Ederef
                                                                    (Etempvar _t'75 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'13)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'74 tfloat) ::
                                                                    (Etempvar _t'76 tfloat) ::
                                                                    nil))))))
                                                                    (Ssequence
                                                                    (Sset _t'72
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'72 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'13 tfloat))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'14)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'71
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'71 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Etempvar _t'14 tfloat))))
                                                                    Sbreak))))
                                                                    LSnil))))))))))))))))
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _soundStatus tuchar)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Ssequence
                                            (Scall None
                                              (Evar _update_background_music_after_sound
                                              (Tfunction
                                                (tuchar :: tuchar :: nil)
                                                tvoid cc_default))
                                              ((Etempvar _bank tuchar) ::
                                               (Etempvar _soundIndex tuchar) ::
                                               nil))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'70
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                            (Econst_int (Int.repr 2) tint)
                                                            (tptr (Tstruct _SequencePlayer noattr)))
                                                          (Tstruct _SequencePlayer noattr))
                                                        _channels
                                                        (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                      (Etempvar _channelIndex tuchar)
                                                      (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'70 (tptr (Tstruct _SequenceChannel noattr)))
                                                          (Tstruct _SequenceChannel noattr))
                                                        _soundScriptIO
                                                        (tarray tschar 8))
                                                      (Econst_int (Int.repr 0) tint)
                                                      (tptr tschar)) tschar)
                                                  (Econst_int (Int.repr 0) tint)))
                                              (Scall None
                                                (Evar _delete_sound_from_bank
                                                (Tfunction
                                                  (tuchar :: tuchar :: nil)
                                                  tvoid cc_default))
                                                ((Etempvar _bank tuchar) ::
                                                 (Etempvar _soundIndex tuchar) ::
                                                 nil))))
                                          (Ssequence
                                            (Sset _t'32
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr (Tstruct _SequencePlayer noattr)))
                                                      (Tstruct _SequencePlayer noattr))
                                                    _channels
                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                  (Etempvar _channelIndex tuchar)
                                                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                (tptr (Tstruct _SequenceChannel noattr))))
                                            (Ssequence
                                              (Sset _t'33
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'32 (tptr (Tstruct _SequenceChannel noattr)))
                                                        (Tstruct _SequenceChannel noattr))
                                                      _layers
                                                      (tarray (tptr (Tstruct _SequenceChannelLayer noattr)) 4))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr (tptr (Tstruct _SequenceChannelLayer noattr))))
                                                  (tptr (Tstruct _SequenceChannelLayer noattr))))
                                              (Ssequence
                                                (Sset _t'34
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'33 (tptr (Tstruct _SequenceChannelLayer noattr)))
                                                      (Tstruct _SequenceChannelLayer noattr))
                                                    _enabled tschar))
                                                (Sifthenelse (Ebinop Oeq
                                                               (Etempvar _t'34 tschar)
                                                               (Econst_int (Int.repr 0) tint)
                                                               tint)
                                                  (Ssequence
                                                    (Scall None
                                                      (Evar _update_background_music_after_sound
                                                      (Tfunction
                                                        (tuchar :: tuchar ::
                                                         nil) tvoid
                                                        cc_default))
                                                      ((Etempvar _bank tuchar) ::
                                                       (Etempvar _soundIndex tuchar) ::
                                                       nil))
                                                    (Ssequence
                                                      (Sassign
                                                        (Efield
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                  (Etempvar _bank tuchar)
                                                                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                              (Etempvar _soundIndex tuchar)
                                                              (tptr (Tstruct _SoundCharacteristics noattr)))
                                                            (Tstruct _SoundCharacteristics noattr))
                                                          _soundStatus
                                                          tuchar)
                                                        (Econst_int (Int.repr 0) tint))
                                                      (Scall None
                                                        (Evar _delete_sound_from_bank
                                                        (Tfunction
                                                          (tuchar ::
                                                           tuchar :: nil)
                                                          tvoid cc_default))
                                                        ((Etempvar _bank tuchar) ::
                                                         (Etempvar _soundIndex tuchar) ::
                                                         nil))))
                                                  (Sswitch (Etempvar _bank tuchar)
                                                    (LScons (Some 1)
                                                      (Ssequence
                                                        (Sset _t'54
                                                          (Efield
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                (Etempvar _soundIndex tuchar)
                                                                (tptr (Tstruct _SoundCharacteristics noattr)))
                                                              (Tstruct _SoundCharacteristics noattr))
                                                            _soundBits tuint))
                                                        (Sifthenelse
                                                          (Eunop Onotbool
                                                            (Ebinop Oand
                                                              (Etempvar _t'54 tuint)
                                                              (Econst_int (Int.repr 134217728) tint)
                                                              tuint) tint)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'66
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                  tuchar))
                                                              (Sifthenelse
                                                                (Ebinop Ogt
                                                                  (Etempvar _t'66 tuchar)
                                                                  (Econst_int (Int.repr 8) tint)
                                                                  tint)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'15)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'15 tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'69
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'69 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _value tfloat))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'16)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'16 tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'67
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'68
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'67 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Ebinop Omul
                                                                    (Ebinop Odiv
                                                                    (Ebinop Oadd
                                                                    (Etempvar _t'68 tuchar)
                                                                    (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                                                    tfloat)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tfloat)
                                                                    (Etempvar _value tfloat)
                                                                    tfloat)))))))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'62
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                  (Ssequence
                                                                    (Sset _t'63
                                                                    (Ederef
                                                                    (Etempvar _t'62 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'64
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'65
                                                                    (Ederef
                                                                    (Etempvar _t'64 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'17)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'63 tfloat) ::
                                                                    (Etempvar _t'65 tfloat) ::
                                                                    nil))))))
                                                                (Ssequence
                                                                  (Sset _t'61
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'61 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'17 tfloat))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'56
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _soundBits
                                                                    tuint))
                                                                  (Sifthenelse
                                                                    (Ebinop Oeq
                                                                    (Ebinop Oand
                                                                    (Etempvar _t'56 tuint)
                                                                    (Econst_int (Int.repr 16711680) tint)
                                                                    tuint)
                                                                    (Ebinop Oand
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oor
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 28) tint)
                                                                    tuint)
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 23) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Ebinop Oshl
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 8) tint)
                                                                    tuint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 67108864) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tuint)
                                                                    (Econst_int (Int.repr 16711680) tint)
                                                                    tuint)
                                                                    tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'18)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'18 tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'59
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'60
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'59 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Odiv
                                                                    (Ecast
                                                                    (Etempvar _t'60 tuchar)
                                                                    tfloat)
                                                                    (Econst_float (Float.of_bits (Int64.repr 4635329916471083008)) tdouble)
                                                                    tdouble)
                                                                    (Etempvar _value tfloat)
                                                                    tdouble)))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'19)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Sset _value
                                                                    (Etempvar _t'19 tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'57
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'58
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundMovingSpeed (tarray tuchar 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr tuchar))
                                                                    tuchar))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'57 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Ebinop Oadd
                                                                    (Ebinop Odiv
                                                                    (Ecast
                                                                    (Etempvar _t'58 tuchar)
                                                                    tfloat)
                                                                    (Econst_float (Float.of_bits (Int64.repr 4645744490609377280)) tdouble)
                                                                    tdouble)
                                                                    (Etempvar _value tfloat)
                                                                    tdouble)))))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'20)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'55
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'55 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'20 tuchar))))
                                                                  Sbreak))))
                                                          Sskip))
                                                      (LScons (Some 7)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'53
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                  (Etempvar _channelIndex tuchar)
                                                                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                (tptr (Tstruct _SequenceChannel noattr))))
                                                            (Sassign
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _t'53 (tptr (Tstruct _SequenceChannel noattr)))
                                                                  (Tstruct _SequenceChannel noattr))
                                                                _volume
                                                                tfloat)
                                                              (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'52
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (tptr (Tstruct _SequenceChannel noattr))))
                                                              (Sassign
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _t'52 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                  _pan
                                                                  tfloat)
                                                                (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'51
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                (Sassign
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'51 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))
                                                              Sbreak)))
                                                        (LScons (Some 0)
                                                          Sskip
                                                          (LScons (Some 2)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'21)
                                                                  (Evar _get_sound_volume
                                                                  (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                  ((Etempvar _bank tuchar) ::
                                                                   (Etempvar _soundIndex tuchar) ::
                                                                   (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat) ::
                                                                   nil))
                                                                (Ssequence
                                                                  (Sset _t'50
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                  (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'50 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _t'21 tfloat))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Sset _t'46
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'47
                                                                    (Ederef
                                                                    (Etempvar _t'46 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'48
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'49
                                                                    (Ederef
                                                                    (Etempvar _t'48 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'22)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'47 tfloat) ::
                                                                    (Etempvar _t'49 tfloat) ::
                                                                    nil))))))
                                                                  (Ssequence
                                                                    (Sset _t'45
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'45 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'22 tfloat))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'23)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'44
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'44 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Etempvar _t'23 tfloat))))
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'24)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'43
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'43 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'24 tuchar))))
                                                                    Sbreak))))
                                                            (LScons (Some 3)
                                                              Sskip
                                                              (LScons (Some 4)
                                                                Sskip
                                                                (LScons (Some 5)
                                                                  Sskip
                                                                  (LScons (Some 6)
                                                                    Sskip
                                                                    (LScons (Some 8)
                                                                    Sskip
                                                                    (LScons (Some 9)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'25)
                                                                    (Evar _get_sound_reverb
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tuchar
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Etempvar _channelIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'42
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'42 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _reverbVol
                                                                    tuchar)
                                                                    (Etempvar _t'25 tuchar))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'26)
                                                                    (Evar _get_sound_volume
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'41
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'41 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _volume
                                                                    tfloat)
                                                                    (Etempvar _t'26 tfloat))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'37
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _x
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'38
                                                                    (Ederef
                                                                    (Etempvar _t'37 (tptr tfloat))
                                                                    tfloat))
                                                                    (Ssequence
                                                                    (Sset _t'39
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                                                    (Etempvar _bank tuchar)
                                                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                                                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                                                    (Etempvar _soundIndex tuchar)
                                                                    (tptr (Tstruct _SoundCharacteristics noattr)))
                                                                    (Tstruct _SoundCharacteristics noattr))
                                                                    _z
                                                                    (tptr tfloat)))
                                                                    (Ssequence
                                                                    (Sset _t'40
                                                                    (Ederef
                                                                    (Etempvar _t'39 (tptr tfloat))
                                                                    tfloat))
                                                                    (Scall (Some _t'27)
                                                                    (Evar _get_sound_pan
                                                                    (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _t'38 tfloat) ::
                                                                    (Etempvar _t'40 tfloat) ::
                                                                    nil))))))
                                                                    (Ssequence
                                                                    (Sset _t'36
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'36 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _pan
                                                                    tfloat)
                                                                    (Etempvar _t'27 tfloat))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'28)
                                                                    (Evar _get_sound_freq_scale
                                                                    (Tfunction
                                                                    (tuchar ::
                                                                    tuchar ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                    ((Etempvar _bank tuchar) ::
                                                                    (Etempvar _soundIndex tuchar) ::
                                                                    nil))
                                                                    (Ssequence
                                                                    (Sset _t'35
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr (Tstruct _SequencePlayer noattr)))
                                                                    (Tstruct _SequencePlayer noattr))
                                                                    _channels
                                                                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                                                                    (Etempvar _channelIndex tuchar)
                                                                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (tptr (Tstruct _SequenceChannel noattr))))
                                                                    (Sassign
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'35 (tptr (Tstruct _SequenceChannel noattr)))
                                                                    (Tstruct _SequenceChannel noattr))
                                                                    _freqScale
                                                                    tfloat)
                                                                    (Etempvar _t'28 tfloat))))
                                                                    Sbreak))))
                                                                    LSnil))))))))))))))))))))
                                Sskip))
                            (Sset _channelIndex
                              (Ecast
                                (Ebinop Oadd (Etempvar _channelIndex tuchar)
                                  (Econst_int (Int.repr 1) tint) tint)
                                tuchar)))))
                      (Sset _i
                        (Ecast
                          (Ebinop Oadd (Etempvar _i tuchar)
                            (Econst_int (Int.repr 1) tint) tint) tuchar))))
                  (Ssequence
                    (Sset _t'30
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                          (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
                    (Ssequence
                      (Sset _t'31
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sUsedChannelsForSoundBank (tarray tuchar 10))
                            (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
                      (Sset _channelIndex
                        (Ecast
                          (Ebinop Oadd (Etempvar _channelIndex tuchar)
                            (Ebinop Osub (Etempvar _t'30 tuchar)
                              (Etempvar _t'31 tuchar) tint) tint) tuchar)))))))
            (Sset _bank
              (Ecast
                (Ebinop Oadd (Etempvar _bank tuchar)
                  (Econst_int (Int.repr 1) tint) tint) tuchar))))))))
|}.

Definition f_seq_player_play_sequence := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_seqId, tuchar) :: (_arg2, tushort) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_targetVolume, tuchar) :: (_i, tuchar) :: (_t'1, tuchar) ::
               nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _player tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sassign (Evar _sCurrentBackgroundMusicSeqId tuchar)
        (Ebinop Oand (Etempvar _seqId tuchar)
          (Econst_int (Int.repr 127) tint) tint))
      (Ssequence
        (Sassign (Evar _sBackgroundMusicForDynamics tuchar)
          (Econst_int (Int.repr 255) tint))
        (Ssequence
          (Sassign (Evar _sCurrentMusicDynamic tuchar)
            (Econst_int (Int.repr 255) tint))
          (Sassign (Evar _sMusicDynamicDelay tuchar)
            (Econst_int (Int.repr 2) tint)))))
    Sskip)
  (Ssequence
    (Ssequence
      (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                         (Econst_int (Int.repr 16) tint) tint)
            Sskip
            Sbreak)
          (Sassign
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                      (Etempvar _player tuchar)
                      (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                    (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                  (Etempvar _i tuchar)
                  (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                (Tstruct _ChannelVolumeScaleFade noattr)) _remainingFrames
              tushort) (Econst_int (Int.repr 0) tint)))
        (Sset _i
          (Ecast
            (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
              tint) tuchar))))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Etempvar _player tuchar)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _seqVariation tschar)
        (Ebinop Oand (Etempvar _seqId tuchar)
          (Econst_int (Int.repr 128) tint) tint))
      (Ssequence
        (Scall None
          (Evar _load_sequence (Tfunction (tuint :: tuint :: tint :: nil)
                                 tvoid cc_default))
          ((Etempvar _player tuchar) ::
           (Ebinop Oand (Etempvar _seqId tuchar)
             (Econst_int (Int.repr 127) tint) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sifthenelse (Ebinop Oeq (Etempvar _player tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _begin_background_music_fade (Tfunction
                                                     (tushort :: nil) tuchar
                                                     cc_default))
                ((Econst_int (Int.repr 0) tint) :: nil))
              (Sset _targetVolume (Ecast (Etempvar _t'1 tuchar) tuchar)))
            (Sifthenelse (Ebinop One (Etempvar _targetVolume tuchar)
                           (Econst_int (Int.repr 255) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _state tuchar)
                  (Econst_int (Int.repr 4) tint))
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                        (Econst_int (Int.repr 0) tint)
                        (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat)
                  (Ebinop Odiv (Ecast (Etempvar _targetVolume tuchar) tfloat)
                    (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                    tdouble)))
              Sskip))
          (Scall None
            (Evar _func_8031D690 (Tfunction (tint :: tushort :: nil) tvoid
                                   cc_default))
            ((Etempvar _player tuchar) :: (Etempvar _arg2 tushort) :: nil)))))))
|}.

Definition f_seq_player_fade_out := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _player tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sassign (Evar _sCurrentBackgroundMusicSeqId tuchar)
      (Econst_int (Int.repr 255) tint))
    Sskip)
  (Scall None
    (Evar _seq_player_fade_to_zero_volume (Tfunction (tint :: tushort :: nil)
                                            tvoid cc_default))
    ((Etempvar _player tuchar) :: (Etempvar _fadeDuration tushort) :: nil)))
|}.

Definition f_fade_volume_scale := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_targetScale, tuchar) ::
                (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 16) tint) tint)
        Sskip
        Sbreak)
      (Scall None
        (Evar _fade_channel_volume_scale (Tfunction
                                           (tuchar :: tuchar :: tuchar ::
                                            tushort :: nil) tvoid cc_default))
        ((Etempvar _player tuchar) :: (Etempvar _i tuchar) ::
         (Etempvar _targetScale tuchar) ::
         (Etempvar _fadeDuration tushort) :: nil)))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_fade_channel_volume_scale := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_channelIndex, tuchar) ::
                (_targetScale, tuchar) :: (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_temp, (tptr (Tstruct _ChannelVolumeScaleFade noattr))) ::
               (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'3, tfloat) ::
               (_t'2, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'1, (tptr (Tstruct _SequenceChannel noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Ederef
      (Ebinop Oadd
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Etempvar _player tuchar)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _channels
          (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
        (Etempvar _channelIndex tuchar)
        (tptr (tptr (Tstruct _SequenceChannel noattr))))
      (tptr (Tstruct _SequenceChannel noattr))))
  (Sifthenelse (Ebinop One
                 (Etempvar _t'1 (tptr (Tstruct _SequenceChannel noattr)))
                 (Eaddrof
                   (Evar _gSequenceChannelNone (Tstruct _SequenceChannel noattr))
                   (tptr (Tstruct _SequenceChannel noattr))) tint)
    (Ssequence
      (Sset _temp
        (Ebinop Oadd
          (Ederef
            (Ebinop Oadd
              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
              (Etempvar _player tuchar)
              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
          (Etempvar _channelIndex tuchar)
          (tptr (Tstruct _ChannelVolumeScaleFade noattr))))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _temp (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
              (Tstruct _ChannelVolumeScaleFade noattr)) _remainingFrames
            tushort) (Etempvar _fadeDuration tushort))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                        (Etempvar _player tuchar)
                        (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _channels
                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                  (Etempvar _channelIndex tuchar)
                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                (tptr (Tstruct _SequenceChannel noattr))))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _SequenceChannel noattr)))
                    (Tstruct _SequenceChannel noattr)) _volumeScale tfloat))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _temp (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                    (Tstruct _ChannelVolumeScaleFade noattr)) _velocity
                  tfloat)
                (Ebinop Odiv
                  (Ebinop Osub
                    (Ecast
                      (Ebinop Odiv (Etempvar _targetScale tuchar)
                        (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                        tdouble) tfloat) (Etempvar _t'5 tfloat) tfloat)
                  (Etempvar _fadeDuration tushort) tfloat))))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _temp (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                  (Tstruct _ChannelVolumeScaleFade noattr)) _target tuchar)
              (Etempvar _targetScale tuchar))
            (Ssequence
              (Sset _t'2
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                          (Etempvar _player tuchar)
                          (tptr (Tstruct _SequencePlayer noattr)))
                        (Tstruct _SequencePlayer noattr)) _channels
                      (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                    (Etempvar _channelIndex tuchar)
                    (tptr (tptr (Tstruct _SequenceChannel noattr))))
                  (tptr (Tstruct _SequenceChannel noattr))))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Etempvar _t'2 (tptr (Tstruct _SequenceChannel noattr)))
                      (Tstruct _SequenceChannel noattr)) _volumeScale tfloat))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _temp (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                      (Tstruct _ChannelVolumeScaleFade noattr)) _current
                    tfloat) (Etempvar _t'3 tfloat))))))))
    Sskip))
|}.

Definition f_func_8031F96C := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: (_t'1, tint) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'5, tushort) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 16) tint) tint)
        Sskip
        Sbreak)
      (Ssequence
        (Ssequence
          (Sset _t'10
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                      (Etempvar _player tuchar)
                      (tptr (Tstruct _SequencePlayer noattr)))
                    (Tstruct _SequencePlayer noattr)) _channels
                  (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                (Etempvar _i tuchar)
                (tptr (tptr (Tstruct _SequenceChannel noattr))))
              (tptr (Tstruct _SequenceChannel noattr))))
          (Sifthenelse (Ebinop One
                         (Etempvar _t'10 (tptr (Tstruct _SequenceChannel noattr)))
                         (Eaddrof
                           (Evar _gSequenceChannelNone (Tstruct _SequenceChannel noattr))
                           (tptr (Tstruct _SequenceChannel noattr))) tint)
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                          (Etempvar _player tuchar)
                          (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                        (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                      (Etempvar _i tuchar)
                      (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                    (Tstruct _ChannelVolumeScaleFade noattr))
                  _remainingFrames tushort))
              (Sset _t'1
                (Ecast
                  (Ebinop One (Etempvar _t'11 tushort)
                    (Econst_int (Int.repr 0) tint) tint) tbool)))
            (Sset _t'1 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                          (Etempvar _player tuchar)
                          (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                        (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                      (Etempvar _i tuchar)
                      (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                    (Tstruct _ChannelVolumeScaleFade noattr)) _current
                  tfloat))
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                            (Etempvar _player tuchar)
                            (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                          (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                        (Etempvar _i tuchar)
                        (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                      (Tstruct _ChannelVolumeScaleFade noattr)) _velocity
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                            (Etempvar _player tuchar)
                            (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                          (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                        (Etempvar _i tuchar)
                        (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                      (Tstruct _ChannelVolumeScaleFade noattr)) _current
                    tfloat)
                  (Ebinop Oadd (Etempvar _t'8 tfloat) (Etempvar _t'9 tfloat)
                    tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                            (Etempvar _player tuchar)
                            (tptr (Tstruct _SequencePlayer noattr)))
                          (Tstruct _SequencePlayer noattr)) _channels
                        (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                      (Etempvar _i tuchar)
                      (tptr (tptr (Tstruct _SequenceChannel noattr))))
                    (tptr (Tstruct _SequenceChannel noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                              (Etempvar _player tuchar)
                              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                        (Tstruct _ChannelVolumeScaleFade noattr)) _current
                      tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'6 (tptr (Tstruct _SequenceChannel noattr)))
                        (Tstruct _SequenceChannel noattr)) _volumeScale
                      tfloat) (Etempvar _t'7 tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                              (Etempvar _player tuchar)
                              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                        (Tstruct _ChannelVolumeScaleFade noattr))
                      _remainingFrames tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                              (Etempvar _player tuchar)
                              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                        (Tstruct _ChannelVolumeScaleFade noattr))
                      _remainingFrames tushort)
                    (Ebinop Osub (Etempvar _t'5 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                              (Etempvar _player tuchar)
                              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                        (Tstruct _ChannelVolumeScaleFade noattr))
                      _remainingFrames tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'3
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                  (Etempvar _player tuchar)
                                  (tptr (Tstruct _SequencePlayer noattr)))
                                (Tstruct _SequencePlayer noattr)) _channels
                              (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                            (Etempvar _i tuchar)
                            (tptr (tptr (Tstruct _SequenceChannel noattr))))
                          (tptr (Tstruct _SequenceChannel noattr))))
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                                    (Etempvar _player tuchar)
                                    (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                                  (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                                (Etempvar _i tuchar)
                                (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                              (Tstruct _ChannelVolumeScaleFade noattr))
                            _target tuchar))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'3 (tptr (Tstruct _SequenceChannel noattr)))
                              (Tstruct _SequenceChannel noattr)) _volumeScale
                            tfloat)
                          (Ebinop Odiv (Etempvar _t'4 tuchar)
                            (Econst_single (Float32.of_bits (Int.repr 1123942400)) tfloat)
                            tfloat))))
                    Sskip)))))
          Sskip)))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_process_level_music_dynamics := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_conditionValues, (tarray tshort 8)) ::
              (_conditionTypes, (tarray tuchar 8)) :: nil);
  fn_temps := ((_conditionBits, tuint) :: (_tempBits, tushort) ::
               (_pad, tushort) :: (_musicDynIndex, tuchar) ::
               (_condIndex, tuchar) :: (_i, tuchar) :: (_j, tuchar) ::
               (_dur1, tshort) :: (_dur2, tshort) :: (_bit, tushort) ::
               (_t'1, tuchar) :: (_t'48, tuchar) :: (_t'47, tuchar) ::
               (_t'46, tuchar) :: (_t'45, tshort) ::
               (_t'44, (tptr tshort)) :: (_t'43, tshort) ::
               (_t'42, tuchar) :: (_t'41, tshort) ::
               (_t'40, (tptr tshort)) :: (_t'39, tshort) ::
               (_t'38, tshort) :: (_t'37, (tptr tshort)) ::
               (_t'36, tshort) :: (_t'35, tshort) ::
               (_t'34, (tptr tshort)) :: (_t'33, tshort) ::
               (_t'32, tshort) :: (_t'31, tfloat) :: (_t'30, tshort) ::
               (_t'29, tfloat) :: (_t'28, tshort) :: (_t'27, tfloat) ::
               (_t'26, tshort) :: (_t'25, tfloat) :: (_t'24, tshort) ::
               (_t'23, tfloat) :: (_t'22, tshort) :: (_t'21, tfloat) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) :: (_t'16, tuchar) :: (_t'15, tshort) ::
               (_t'14, (tptr tshort)) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, (tptr tshort)) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tuchar) :: (_t'6, tushort) :: (_t'5, tshort) ::
               (_t'4, tushort) :: (_t'3, tshort) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _func_8031F96C (Tfunction (tuchar :: nil) tvoid cc_default))
    ((Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _func_8031F96C (Tfunction (tuchar :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 2) tint) :: nil))
    (Ssequence
      (Scall None (Evar _func_80320ED8 (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Ssequence
          (Sset _t'46 (Evar _sMusicDynamicDelay tuchar))
          (Sifthenelse (Ebinop One (Etempvar _t'46 tuchar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'48 (Evar _sMusicDynamicDelay tuchar))
              (Sassign (Evar _sMusicDynamicDelay tuchar)
                (Ebinop Osub (Etempvar _t'48 tuchar)
                  (Econst_int (Int.repr 1) tint) tint)))
            (Ssequence
              (Sset _t'47 (Evar _sCurrentBackgroundMusicSeqId tuchar))
              (Sassign (Evar _sBackgroundMusicForDynamics tuchar)
                (Etempvar _t'47 tuchar)))))
        (Ssequence
          (Ssequence
            (Sset _t'42 (Evar _sBackgroundMusicForDynamics tuchar))
            (Ssequence
              (Sset _t'43 (Evar _gCurrLevelNum tshort))
              (Ssequence
                (Sset _t'44
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                      (Etempvar _t'43 tshort) (tptr (tptr tshort)))
                    (tptr tshort)))
                (Ssequence
                  (Sset _t'45
                    (Ederef
                      (Ebinop Oadd (Etempvar _t'44 (tptr tshort))
                        (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
                  (Sifthenelse (Ebinop One (Etempvar _t'42 tuchar)
                                 (Etempvar _t'45 tshort) tint)
                    (Sreturn None)
                    Sskip)))))
          (Ssequence
            (Ssequence
              (Sset _t'39 (Evar _gCurrLevelNum tshort))
              (Ssequence
                (Sset _t'40
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                      (Etempvar _t'39 tshort) (tptr (tptr tshort)))
                    (tptr tshort)))
                (Ssequence
                  (Sset _t'41
                    (Ederef
                      (Ebinop Oadd (Etempvar _t'40 (tptr tshort))
                        (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
                  (Sset _conditionBits
                    (Ebinop Oand (Etempvar _t'41 tshort)
                      (Econst_int (Int.repr 65280) tint) tint)))))
            (Ssequence
              (Ssequence
                (Sset _t'36 (Evar _gCurrLevelNum tshort))
                (Ssequence
                  (Sset _t'37
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                        (Etempvar _t'36 tshort) (tptr (tptr tshort)))
                      (tptr tshort)))
                  (Ssequence
                    (Sset _t'38
                      (Ederef
                        (Ebinop Oadd (Etempvar _t'37 (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))
                        tshort))
                    (Sset _musicDynIndex
                      (Ecast
                        (Ebinop Oand (Ecast (Etempvar _t'38 tshort) tuchar)
                          (Econst_int (Int.repr 255) tint) tint) tuchar)))))
              (Ssequence
                (Sset _i (Ecast (Econst_int (Int.repr 2) tint) tuchar))
                (Ssequence
                  (Swhile
                    (Ebinop Oand (Etempvar _conditionBits tuint)
                      (Econst_int (Int.repr 65280) tint) tuint)
                    (Ssequence
                      (Sset _j (Ecast (Econst_int (Int.repr 0) tint) tuchar))
                      (Ssequence
                        (Sset _condIndex
                          (Ecast (Econst_int (Int.repr 0) tint) tuchar))
                        (Ssequence
                          (Sset _bit
                            (Ecast (Econst_int (Int.repr 32768) tint)
                              tushort))
                          (Ssequence
                            (Swhile
                              (Ebinop Olt (Etempvar _j tuchar)
                                (Econst_int (Int.repr 8) tint) tint)
                              (Ssequence
                                (Sifthenelse (Ebinop Oand
                                               (Etempvar _conditionBits tuint)
                                               (Etempvar _bit tushort) tuint)
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'1 (Etempvar _i tuchar))
                                        (Sset _i
                                          (Ecast
                                            (Ebinop Oadd
                                              (Etempvar _t'1 tuchar)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuchar)))
                                      (Ssequence
                                        (Sset _t'33
                                          (Evar _gCurrLevelNum tshort))
                                        (Ssequence
                                          (Sset _t'34
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                                                (Etempvar _t'33 tshort)
                                                (tptr (tptr tshort)))
                                              (tptr tshort)))
                                          (Ssequence
                                            (Sset _t'35
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Etempvar _t'34 (tptr tshort))
                                                  (Etempvar _t'1 tuchar)
                                                  (tptr tshort)) tshort))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _conditionValues (tarray tshort 8))
                                                  (Etempvar _condIndex tuchar)
                                                  (tptr tshort)) tshort)
                                              (Etempvar _t'35 tshort))))))
                                    (Ssequence
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _conditionTypes (tarray tuchar 8))
                                            (Etempvar _condIndex tuchar)
                                            (tptr tuchar)) tuchar)
                                        (Etempvar _j tuchar))
                                      (Sset _condIndex
                                        (Ecast
                                          (Ebinop Oadd
                                            (Etempvar _condIndex tuchar)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuchar))))
                                  Sskip)
                                (Ssequence
                                  (Sset _j
                                    (Ecast
                                      (Ebinop Oadd (Etempvar _j tuchar)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuchar))
                                  (Sset _bit
                                    (Ecast
                                      (Ebinop Oshr (Etempvar _bit tushort)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tushort)))))
                            (Ssequence
                              (Ssequence
                                (Sset _j
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    tuchar))
                                (Sloop
                                  (Ssequence
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _j tuchar)
                                                   (Etempvar _condIndex tuchar)
                                                   tint)
                                      Sskip
                                      Sbreak)
                                    (Ssequence
                                      (Sset _t'16
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _conditionTypes (tarray tuchar 8))
                                            (Etempvar _j tuchar)
                                            (tptr tuchar)) tuchar))
                                      (Sswitch (Etempvar _t'16 tuchar)
                                        (LScons (Some 0)
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'31
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _pos (tarray tfloat 3))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Ssequence
                                                (Sset _t'32
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _conditionValues (tarray tshort 8))
                                                      (Etempvar _j tuchar)
                                                      (tptr tshort)) tshort))
                                                (Sifthenelse (Ebinop Olt
                                                               (Ecast
                                                                 (Etempvar _t'31 tfloat)
                                                                 tshort)
                                                               (Etempvar _t'32 tshort)
                                                               tint)
                                                  (Sset _j
                                                    (Ecast
                                                      (Ebinop Oadd
                                                        (Etempvar _condIndex tuchar)
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint) tuchar))
                                                  Sskip)))
                                            Sbreak)
                                          (LScons (Some 1)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'29
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                            (Econst_int (Int.repr 0) tint)
                                                            (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _pos
                                                        (tarray tfloat 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tfloat)) tfloat))
                                                (Ssequence
                                                  (Sset _t'30
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _conditionValues (tarray tshort 8))
                                                        (Etempvar _j tuchar)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Sifthenelse (Ebinop Olt
                                                                 (Ecast
                                                                   (Etempvar _t'29 tfloat)
                                                                   tshort)
                                                                 (Etempvar _t'30 tshort)
                                                                 tint)
                                                    (Sset _j
                                                      (Ecast
                                                        (Ebinop Oadd
                                                          (Etempvar _condIndex tuchar)
                                                          (Econst_int (Int.repr 1) tint)
                                                          tint) tuchar))
                                                    Sskip)))
                                              Sbreak)
                                            (LScons (Some 2)
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'27
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                              (Econst_int (Int.repr 0) tint)
                                                              (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _pos
                                                          (tarray tfloat 3))
                                                        (Econst_int (Int.repr 2) tint)
                                                        (tptr tfloat))
                                                      tfloat))
                                                  (Ssequence
                                                    (Sset _t'28
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _conditionValues (tarray tshort 8))
                                                          (Etempvar _j tuchar)
                                                          (tptr tshort))
                                                        tshort))
                                                    (Sifthenelse (Ebinop Olt
                                                                   (Ecast
                                                                    (Etempvar _t'27 tfloat)
                                                                    tshort)
                                                                   (Etempvar _t'28 tshort)
                                                                   tint)
                                                      (Sset _j
                                                        (Ecast
                                                          (Ebinop Oadd
                                                            (Etempvar _condIndex tuchar)
                                                            (Econst_int (Int.repr 1) tint)
                                                            tint) tuchar))
                                                      Sskip)))
                                                Sbreak)
                                              (LScons (Some 3)
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'25
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                                (Econst_int (Int.repr 0) tint)
                                                                (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _pos
                                                            (tarray tfloat 3))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr tfloat))
                                                        tfloat))
                                                    (Ssequence
                                                      (Sset _t'26
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _conditionValues (tarray tshort 8))
                                                            (Etempvar _j tuchar)
                                                            (tptr tshort))
                                                          tshort))
                                                      (Sifthenelse (Ebinop Oge
                                                                    (Ecast
                                                                    (Etempvar _t'25 tfloat)
                                                                    tshort)
                                                                    (Etempvar _t'26 tshort)
                                                                    tint)
                                                        (Sset _j
                                                          (Ecast
                                                            (Ebinop Oadd
                                                              (Etempvar _condIndex tuchar)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint) tuchar))
                                                        Sskip)))
                                                  Sbreak)
                                                (LScons (Some 4)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'23
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                                  (Econst_int (Int.repr 0) tint)
                                                                  (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _pos
                                                              (tarray tfloat 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tfloat))
                                                          tfloat))
                                                      (Ssequence
                                                        (Sset _t'24
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _conditionValues (tarray tshort 8))
                                                              (Etempvar _j tuchar)
                                                              (tptr tshort))
                                                            tshort))
                                                        (Sifthenelse
                                                          (Ebinop Oge
                                                            (Ecast
                                                              (Etempvar _t'23 tfloat)
                                                              tshort)
                                                            (Etempvar _t'24 tshort)
                                                            tint)
                                                          (Sset _j
                                                            (Ecast
                                                              (Ebinop Oadd
                                                                (Etempvar _condIndex tuchar)
                                                                (Econst_int (Int.repr 1) tint)
                                                                tint) tuchar))
                                                          Sskip)))
                                                    Sbreak)
                                                  (LScons (Some 5)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'21
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr (Tstruct _MarioState noattr)))
                                                                  (Tstruct _MarioState noattr))
                                                                _pos
                                                                (tarray tfloat 3))
                                                              (Econst_int (Int.repr 2) tint)
                                                              (tptr tfloat))
                                                            tfloat))
                                                        (Ssequence
                                                          (Sset _t'22
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Evar _conditionValues (tarray tshort 8))
                                                                (Etempvar _j tuchar)
                                                                (tptr tshort))
                                                              tshort))
                                                          (Sifthenelse
                                                            (Ebinop Oge
                                                              (Ecast
                                                                (Etempvar _t'21 tfloat)
                                                                tshort)
                                                              (Etempvar _t'22 tshort)
                                                              tint)
                                                            (Sset _j
                                                              (Ecast
                                                                (Ebinop Oadd
                                                                  (Etempvar _condIndex tuchar)
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  tint)
                                                                tuchar))
                                                            Sskip)))
                                                      Sbreak)
                                                    (LScons (Some 6)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'19
                                                            (Evar _gCurrAreaIndex tshort))
                                                          (Ssequence
                                                            (Sset _t'20
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Evar _conditionValues (tarray tshort 8))
                                                                  (Etempvar _j tuchar)
                                                                  (tptr tshort))
                                                                tshort))
                                                            (Sifthenelse
                                                              (Ebinop One
                                                                (Etempvar _t'19 tshort)
                                                                (Etempvar _t'20 tshort)
                                                                tint)
                                                              (Sset _j
                                                                (Ecast
                                                                  (Ebinop Oadd
                                                                    (Etempvar _condIndex tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                  tuchar))
                                                              Sskip)))
                                                        Sbreak)
                                                      (LScons (Some 7)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'17
                                                              (Evar _gMarioCurrentRoom tshort))
                                                            (Ssequence
                                                              (Sset _t'18
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _conditionValues (tarray tshort 8))
                                                                    (Etempvar _j tuchar)
                                                                    (tptr tshort))
                                                                  tshort))
                                                              (Sifthenelse
                                                                (Ebinop One
                                                                  (Etempvar _t'17 tshort)
                                                                  (Etempvar _t'18 tshort)
                                                                  tint)
                                                                (Sset _j
                                                                  (Ecast
                                                                    (Ebinop Oadd
                                                                    (Etempvar _condIndex tuchar)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    tuchar))
                                                                Sskip)))
                                                          Sbreak)
                                                        LSnil)))))))))))
                                  (Sset _j
                                    (Ecast
                                      (Ebinop Oadd (Etempvar _j tuchar)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      tuchar))))
                              (Ssequence
                                (Sifthenelse (Ebinop Oeq (Etempvar _j tuchar)
                                               (Etempvar _condIndex tuchar)
                                               tint)
                                  (Sset _tempBits
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      tushort))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'13
                                        (Evar _gCurrLevelNum tshort))
                                      (Ssequence
                                        (Sset _t'14
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                                              (Etempvar _t'13 tshort)
                                              (tptr (tptr tshort)))
                                            (tptr tshort)))
                                        (Ssequence
                                          (Sset _t'15
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _t'14 (tptr tshort))
                                                (Etempvar _i tuchar)
                                                (tptr tshort)) tshort))
                                          (Sset _tempBits
                                            (Ecast
                                              (Ebinop Oand
                                                (Etempvar _t'15 tshort)
                                                (Econst_int (Int.repr 65280) tint)
                                                tint) tushort)))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'10
                                          (Evar _gCurrLevelNum tshort))
                                        (Ssequence
                                          (Sset _t'11
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _sLevelDynamics (tarray (tptr tshort) 39))
                                                (Etempvar _t'10 tshort)
                                                (tptr (tptr tshort)))
                                              (tptr tshort)))
                                          (Ssequence
                                            (Sset _t'12
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Etempvar _t'11 (tptr tshort))
                                                  (Etempvar _i tuchar)
                                                  (tptr tshort)) tshort))
                                            (Sset _musicDynIndex
                                              (Ecast
                                                (Ebinop Oand
                                                  (Etempvar _t'12 tshort)
                                                  (Econst_int (Int.repr 255) tint)
                                                  tint) tuchar)))))
                                      (Sset _i
                                        (Ecast
                                          (Ebinop Oadd (Etempvar _i tuchar)
                                            (Econst_int (Int.repr 1) tint)
                                            tint) tuchar)))))
                                (Sset _conditionBits
                                  (Etempvar _tempBits tushort)))))))))
                  (Ssequence
                    (Sset _t'2 (Evar _sCurrentMusicDynamic tuchar))
                    (Sifthenelse (Ebinop One (Etempvar _t'2 tuchar)
                                   (Etempvar _musicDynIndex tuchar) tint)
                      (Ssequence
                        (Sset _tempBits
                          (Ecast (Econst_int (Int.repr 1) tint) tushort))
                        (Ssequence
                          (Ssequence
                            (Sset _t'7 (Evar _sCurrentMusicDynamic tuchar))
                            (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuchar)
                                           (Econst_int (Int.repr 255) tint)
                                           tint)
                              (Ssequence
                                (Sset _dur1
                                  (Ecast (Econst_int (Int.repr 1) tint)
                                    tshort))
                                (Sset _dur2
                                  (Ecast (Econst_int (Int.repr 1) tint)
                                    tshort)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'9
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                          (Etempvar _musicDynIndex tuchar)
                                          (tptr (Tstruct _MusicDynamic noattr)))
                                        (Tstruct _MusicDynamic noattr)) _dur1
                                      tshort))
                                  (Sset _dur1
                                    (Ecast (Etempvar _t'9 tshort) tshort)))
                                (Ssequence
                                  (Sset _t'8
                                    (Efield
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                          (Etempvar _musicDynIndex tuchar)
                                          (tptr (Tstruct _MusicDynamic noattr)))
                                        (Tstruct _MusicDynamic noattr)) _dur2
                                      tshort))
                                  (Sset _dur2
                                    (Ecast (Etempvar _t'8 tshort) tshort))))))
                          (Ssequence
                            (Ssequence
                              (Sset _i
                                (Ecast (Econst_int (Int.repr 0) tint) tuchar))
                              (Sloop
                                (Ssequence
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _i tuchar)
                                                 (Econst_int (Int.repr 16) tint)
                                                 tint)
                                    Sskip
                                    Sbreak)
                                  (Ssequence
                                    (Sset _conditionBits
                                      (Etempvar _tempBits tushort))
                                    (Ssequence
                                      (Sset _tempBits
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tushort))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'5
                                            (Efield
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                                  (Etempvar _musicDynIndex tuchar)
                                                  (tptr (Tstruct _MusicDynamic noattr)))
                                                (Tstruct _MusicDynamic noattr))
                                              _bits1 tshort))
                                          (Sifthenelse (Ebinop Oand
                                                         (Etempvar _t'5 tshort)
                                                         (Etempvar _conditionBits tuint)
                                                         tuint)
                                            (Ssequence
                                              (Sset _t'6
                                                (Efield
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                                      (Etempvar _musicDynIndex tuchar)
                                                      (tptr (Tstruct _MusicDynamic noattr)))
                                                    (Tstruct _MusicDynamic noattr))
                                                  _volScale1 tushort))
                                              (Scall None
                                                (Evar _fade_channel_volume_scale
                                                (Tfunction
                                                  (tuchar :: tuchar ::
                                                   tuchar :: tushort :: nil)
                                                  tvoid cc_default))
                                                ((Econst_int (Int.repr 0) tint) ::
                                                 (Etempvar _i tuchar) ::
                                                 (Etempvar _t'6 tushort) ::
                                                 (Etempvar _dur1 tshort) ::
                                                 nil)))
                                            Sskip))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'3
                                              (Efield
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                                    (Etempvar _musicDynIndex tuchar)
                                                    (tptr (Tstruct _MusicDynamic noattr)))
                                                  (Tstruct _MusicDynamic noattr))
                                                _bits2 tshort))
                                            (Sifthenelse (Ebinop Oand
                                                           (Etempvar _t'3 tshort)
                                                           (Etempvar _conditionBits tuint)
                                                           tuint)
                                              (Ssequence
                                                (Sset _t'4
                                                  (Efield
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _sMusicDynamics (tarray (Tstruct _MusicDynamic noattr) 8))
                                                        (Etempvar _musicDynIndex tuchar)
                                                        (tptr (Tstruct _MusicDynamic noattr)))
                                                      (Tstruct _MusicDynamic noattr))
                                                    _volScale2 tushort))
                                                (Scall None
                                                  (Evar _fade_channel_volume_scale
                                                  (Tfunction
                                                    (tuchar :: tuchar ::
                                                     tuchar :: tushort ::
                                                     nil) tvoid cc_default))
                                                  ((Econst_int (Int.repr 0) tint) ::
                                                   (Etempvar _i tuchar) ::
                                                   (Etempvar _t'4 tushort) ::
                                                   (Etempvar _dur2 tshort) ::
                                                   nil)))
                                              Sskip))
                                          (Sset _tempBits
                                            (Ecast
                                              (Ebinop Oshl
                                                (Etempvar _conditionBits tuint)
                                                (Econst_int (Int.repr 1) tint)
                                                tuint) tushort)))))))
                                (Sset _i
                                  (Ecast
                                    (Ebinop Oadd (Etempvar _i tuchar)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    tuchar))))
                            (Sassign (Evar _sCurrentMusicDynamic tuchar)
                              (Etempvar _musicDynIndex tuchar)))))
                      Sskip)))))))))))
|}.

Definition f_unused_8031FED0 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_bits, tuint) :: (_arg2, tschar) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) ::
               (_t'4, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'3, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'2, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'1, (tptr (Tstruct _SequenceChannel noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Olt (Etempvar _arg2 tschar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sset _arg2 (Ecast (Eunop Oneg (Etempvar _arg2 tschar) tint) tschar))
    Sskip)
  (Ssequence
    (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                       (Econst_int (Int.repr 16) tint) tint)
          Sskip
          Sbreak)
        (Ssequence
          (Ssequence
            (Sset _t'1
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                        (Etempvar _player tuchar)
                        (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _channels
                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                  (Etempvar _i tuchar)
                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                (tptr (Tstruct _SequenceChannel noattr))))
            (Sifthenelse (Ebinop One
                           (Etempvar _t'1 (tptr (Tstruct _SequenceChannel noattr)))
                           (Eaddrof
                             (Evar _gSequenceChannelNone (Tstruct _SequenceChannel noattr))
                             (tptr (Tstruct _SequenceChannel noattr))) tint)
              (Sifthenelse (Ebinop Oeq
                             (Ebinop Oand (Etempvar _bits tuint)
                               (Econst_int (Int.repr 3) tint) tuint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Sset _t'4
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                              (Etempvar _player tuchar)
                              (tptr (Tstruct _SequencePlayer noattr)))
                            (Tstruct _SequencePlayer noattr)) _channels
                          (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                        (Etempvar _i tuchar)
                        (tptr (tptr (Tstruct _SequenceChannel noattr))))
                      (tptr (Tstruct _SequenceChannel noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'4 (tptr (Tstruct _SequenceChannel noattr)))
                        (Tstruct _SequenceChannel noattr)) _volumeScale
                      tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)))
                (Sifthenelse (Ebinop One
                               (Ebinop Oand (Etempvar _bits tuint)
                                 (Econst_int (Int.repr 1) tint) tuint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'3
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                (Etempvar _player tuchar)
                                (tptr (Tstruct _SequencePlayer noattr)))
                              (Tstruct _SequencePlayer noattr)) _channels
                            (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                          (Etempvar _i tuchar)
                          (tptr (tptr (Tstruct _SequenceChannel noattr))))
                        (tptr (Tstruct _SequenceChannel noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _SequenceChannel noattr)))
                          (Tstruct _SequenceChannel noattr)) _volumeScale
                        tfloat)
                      (Ebinop Odiv (Ecast (Etempvar _arg2 tschar) tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                        tdouble)))
                  (Ssequence
                    (Sset _t'2
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                (Etempvar _player tuchar)
                                (tptr (Tstruct _SequencePlayer noattr)))
                              (Tstruct _SequencePlayer noattr)) _channels
                            (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                          (Etempvar _i tuchar)
                          (tptr (tptr (Tstruct _SequenceChannel noattr))))
                        (tptr (Tstruct _SequenceChannel noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'2 (tptr (Tstruct _SequenceChannel noattr)))
                          (Tstruct _SequenceChannel noattr)) _volumeScale
                        tfloat)
                      (Ebinop Osub
                        (Econst_float (Float.of_bits (Int64.repr 4607182418800017408)) tdouble)
                        (Ebinop Odiv (Ecast (Etempvar _arg2 tschar) tfloat)
                          (Econst_float (Float.of_bits (Int64.repr 4638637247447433216)) tdouble)
                          tdouble) tdouble)))))
              Sskip))
          (Sset _bits
            (Ebinop Oshr (Etempvar _bits tuint)
              (Econst_int (Int.repr 2) tint) tuint))))
      (Sset _i
        (Ecast
          (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
            tint) tuchar)))))
|}.

Definition f_seq_player_lower_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_fadeDuration, tushort) ::
                (_percentage, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tvolatile tschar)) :: nil);
  fn_body :=
(Sifthenelse (Ebinop Oeq (Etempvar _player tuchar)
               (Econst_int (Int.repr 0) tint) tint)
  (Ssequence
    (Sassign (Evar _sLowerBackgroundMusicVolume tuchar)
      (Econst_int (Int.repr 1) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Etempvar _fadeDuration tushort) :: nil)))
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef
          (Ebinop Oadd
            (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
            (Etempvar _player tuchar)
            (tptr (Tstruct _SequencePlayer noattr)))
          (Tstruct _SequencePlayer noattr)) _enabled (tvolatile tschar)))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 (tvolatile tschar))
                   (Econst_int (Int.repr 1) tint) tint)
      (Scall None
        (Evar _seq_player_fade_to_percentage_of_volume (Tfunction
                                                         (tint :: tushort ::
                                                          tuchar :: nil)
                                                         tvoid cc_default))
        ((Etempvar _player tuchar) :: (Etempvar _fadeDuration tushort) ::
         (Etempvar _percentage tuchar) :: nil))
      Sskip)))
|}.

Definition f_seq_player_unlower_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, (tvolatile tschar)) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sLowerBackgroundMusicVolume tuchar)
    (Econst_int (Int.repr 0) tint))
  (Sifthenelse (Ebinop Oeq (Etempvar _player tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Etempvar _player tuchar)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _state tuchar))
      (Sifthenelse (Ebinop One (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 1) tint) tint)
        (Scall None
          (Evar _begin_background_music_fade (Tfunction (tushort :: nil)
                                               tuchar cc_default))
          ((Etempvar _fadeDuration tushort) :: nil))
        Sskip))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Etempvar _player tuchar)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _enabled (tvolatile tschar)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 (tvolatile tschar))
                     (Econst_int (Int.repr 1) tint) tint)
        (Scall None
          (Evar _seq_player_fade_to_normal_volume (Tfunction
                                                    (tint :: tushort :: nil)
                                                    tvoid cc_default))
          ((Etempvar _player tuchar) :: (Etempvar _fadeDuration tushort) ::
           nil))
        Sskip))))
|}.

Definition f_begin_background_music_fade := {|
  fn_return := tuchar;
  fn_callconv := cc_default;
  fn_params := ((_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetVolume, tuchar) :: (_maxTargetVolume, tuchar) ::
               (_t'5, (tvolatile tschar)) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'17, tuchar) ::
               (_t'16, tuchar) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tuchar) :: (_t'12, tuchar) :: (_t'11, tuchar) ::
               (_t'10, tuchar) :: (_t'9, tuchar) :: (_t'8, tushort) ::
               (_t'7, tuchar) :: (_t'6, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _targetVolume (Ecast (Econst_int (Int.repr 255) tint) tuchar))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'16 (Evar _sCurrentBackgroundMusicSeqId tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'16 tuchar)
                       (Econst_int (Int.repr 255) tint) tint)
          (Sset _t'1 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'17 (Evar _sCurrentBackgroundMusicSeqId tuchar))
            (Sset _t'1
              (Ecast
                (Ebinop Oeq (Etempvar _t'17 tuchar)
                  (Econst_int (Int.repr 26) tint) tint) tbool)))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 255) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _volume tfloat))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'15 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                         tint)
            (Sset _t'2 (Ecast (Etempvar _fadeDuration tushort) tbool))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sset _t'14
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _fadeVolume tfloat))
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _SequencePlayer noattr)))
                  (Tstruct _SequencePlayer noattr)) _volume tfloat)
              (Etempvar _t'14 tfloat)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'12 (Evar _sBackgroundMusicTargetVolume tuchar))
          (Sifthenelse (Ebinop One (Etempvar _t'12 tuchar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'13 (Evar _sBackgroundMusicTargetVolume tuchar))
              (Sset _targetVolume
                (Ecast
                  (Ebinop Oand (Etempvar _t'13 tuchar)
                    (Econst_int (Int.repr 127) tint) tint) tuchar)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _sBackgroundMusicMaxTargetVolume tuchar))
            (Sifthenelse (Ebinop One (Etempvar _t'10 tuchar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'11 (Evar _sBackgroundMusicMaxTargetVolume tuchar))
                  (Sset _maxTargetVolume
                    (Ecast
                      (Ebinop Oand (Etempvar _t'11 tuchar)
                        (Econst_int (Int.repr 127) tint) tint) tuchar)))
                (Sifthenelse (Ebinop Ogt (Etempvar _targetVolume tuchar)
                               (Etempvar _maxTargetVolume tuchar) tint)
                  (Sset _targetVolume
                    (Ecast (Etempvar _maxTargetVolume tuchar) tuchar))
                  Sskip))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'9 (Evar _sLowerBackgroundMusicVolume tuchar))
                (Sifthenelse (Etempvar _t'9 tuchar)
                  (Sset _t'3
                    (Ecast
                      (Ebinop Ogt (Etempvar _targetVolume tuchar)
                        (Econst_int (Int.repr 40) tint) tint) tbool))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'3 tint)
                (Sset _targetVolume
                  (Ecast (Econst_int (Int.repr 40) tint) tuchar))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Evar _sSoundBanksThatLowerBackgroundMusic tushort))
                  (Sifthenelse (Ebinop One (Etempvar _t'8 tushort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _t'4
                      (Ecast
                        (Ebinop Ogt (Etempvar _targetVolume tuchar)
                          (Econst_int (Int.repr 20) tint) tint) tbool))
                    (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Sset _targetVolume
                    (Ecast (Econst_int (Int.repr 20) tint) tuchar))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                          (Econst_int (Int.repr 0) tint)
                          (tptr (Tstruct _SequencePlayer noattr)))
                        (Tstruct _SequencePlayer noattr)) _enabled
                      (tvolatile tschar)))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'5 (tvolatile tschar))
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Sifthenelse (Ebinop One (Etempvar _targetVolume tuchar)
                                   (Econst_int (Int.repr 255) tint) tint)
                      (Scall None
                        (Evar _seq_player_fade_to_target_volume (Tfunction
                                                                  (tint ::
                                                                   tushort ::
                                                                   tuchar ::
                                                                   nil) tvoid
                                                                  cc_default))
                        ((Econst_int (Int.repr 0) tint) ::
                         (Etempvar _fadeDuration tushort) ::
                         (Etempvar _targetVolume tuchar) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Evar _sCurrentBackgroundMusicSeqId tuchar))
                          (Ssequence
                            (Sset _t'7
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sBackgroundMusicDefaultVolume (tarray tuchar 35))
                                  (Etempvar _t'6 tuchar) (tptr tuchar))
                                tuchar))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr (Tstruct _SequencePlayer noattr)))
                                  (Tstruct _SequencePlayer noattr)) _volume
                                tfloat)
                              (Ebinop Odiv (Etempvar _t'7 tuchar)
                                (Econst_single (Float32.of_bits (Int.repr 1123942400)) tfloat)
                                tfloat))))
                        (Scall None
                          (Evar _seq_player_fade_to_normal_volume (Tfunction
                                                                    (tint ::
                                                                    tushort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                          ((Econst_int (Int.repr 0) tint) ::
                           (Etempvar _fadeDuration tushort) :: nil))))
                    Sskip))
                (Sreturn (Some (Etempvar _targetVolume tuchar)))))))))))
|}.

Definition f_set_audio_muted := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_muted, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 3) tint) tint)
        Sskip
        Sbreak)
      (Sassign
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Etempvar _i tuchar) (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _muted tschar)
        (Etempvar _muted tuchar)))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_sound_init := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: (_j, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
    (Sloop
      (Ssequence
        (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                       (Econst_int (Int.repr 10) tint) tint)
          Sskip
          Sbreak)
        (Ssequence
          (Ssequence
            (Sset _j (Ecast (Econst_int (Int.repr 0) tint) tuchar))
            (Sloop
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _j tuchar)
                               (Econst_int (Int.repr 40) tint) tint)
                  Sskip
                  Sbreak)
                (Sassign
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                            (Etempvar _i tuchar)
                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                        (Etempvar _j tuchar)
                        (tptr (Tstruct _SoundCharacteristics noattr)))
                      (Tstruct _SoundCharacteristics noattr)) _soundStatus
                    tuchar) (Econst_int (Int.repr 0) tint)))
              (Sset _j
                (Ecast
                  (Ebinop Oadd (Etempvar _j tuchar)
                    (Econst_int (Int.repr 1) tint) tint) tuchar))))
          (Ssequence
            (Ssequence
              (Sset _j (Ecast (Econst_int (Int.repr 0) tint) tuchar))
              (Sloop
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _j tuchar)
                                 (Econst_int (Int.repr 1) tint) tint)
                    Sskip
                    Sbreak)
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                            (Etempvar _i tuchar) (tptr (tarray tuchar 1)))
                          (tarray tuchar 1)) (Etempvar _j tuchar)
                        (tptr tuchar)) tuchar)
                    (Econst_int (Int.repr 255) tint)))
                (Sset _j
                  (Ecast
                    (Ebinop Oadd (Etempvar _j tuchar)
                      (Econst_int (Int.repr 1) tint) tint) tuchar))))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBankUsedListBack (tarray tuchar 10))
                    (Etempvar _i tuchar) (tptr tuchar)) tuchar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBankFreeListFront (tarray tuchar 10))
                      (Etempvar _i tuchar) (tptr tuchar)) tuchar)
                  (Econst_int (Int.repr 1) tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _sNumSoundsInBank (tarray tuchar 10))
                      (Etempvar _i tuchar) (tptr tuchar)) tuchar)
                  (Econst_int (Int.repr 0) tint)))))))
      (Sset _i
        (Ecast
          (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
            tint) tuchar))))
  (Ssequence
    (Ssequence
      (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                         (Econst_int (Int.repr 10) tint) tint)
            Sskip
            Sbreak)
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                        (Etempvar _i tuchar)
                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _SoundCharacteristics noattr)))
                  (Tstruct _SoundCharacteristics noattr)) _prev tuchar)
              (Econst_int (Int.repr 255) tint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _i tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Econst_int (Int.repr 0) tint)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _next tuchar)
                (Econst_int (Int.repr 255) tint))
              (Ssequence
                (Ssequence
                  (Sset _j (Ecast (Econst_int (Int.repr 1) tint) tuchar))
                  (Sloop
                    (Ssequence
                      (Sifthenelse (Ebinop Olt (Etempvar _j tuchar)
                                     (Ebinop Osub
                                       (Econst_int (Int.repr 40) tint)
                                       (Econst_int (Int.repr 1) tint) tint)
                                     tint)
                        Sskip
                        Sbreak)
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                    (Etempvar _i tuchar)
                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                (Etempvar _j tuchar)
                                (tptr (Tstruct _SoundCharacteristics noattr)))
                              (Tstruct _SoundCharacteristics noattr)) _prev
                            tuchar)
                          (Ebinop Osub (Etempvar _j tuchar)
                            (Econst_int (Int.repr 1) tint) tint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Ebinop Oadd
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                                    (Etempvar _i tuchar)
                                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                                (Etempvar _j tuchar)
                                (tptr (Tstruct _SoundCharacteristics noattr)))
                              (Tstruct _SoundCharacteristics noattr)) _next
                            tuchar)
                          (Ebinop Oadd (Etempvar _j tuchar)
                            (Econst_int (Int.repr 1) tint) tint))))
                    (Sset _j
                      (Ecast
                        (Ebinop Oadd (Etempvar _j tuchar)
                          (Econst_int (Int.repr 1) tint) tint) tuchar))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                              (Etempvar _i tuchar)
                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                          (Etempvar _j tuchar)
                          (tptr (Tstruct _SoundCharacteristics noattr)))
                        (Tstruct _SoundCharacteristics noattr)) _prev tuchar)
                    (Ebinop Osub (Etempvar _j tuchar)
                      (Econst_int (Int.repr 1) tint) tint))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                              (Etempvar _i tuchar)
                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                          (Etempvar _j tuchar)
                          (tptr (Tstruct _SoundCharacteristics noattr)))
                        (Tstruct _SoundCharacteristics noattr)) _next tuchar)
                    (Econst_int (Int.repr 255) tint)))))))
        (Sset _i
          (Ecast
            (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
              tint) tuchar))))
    (Ssequence
      (Ssequence
        (Sset _j (Ecast (Econst_int (Int.repr 0) tint) tuchar))
        (Sloop
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _j tuchar)
                           (Econst_int (Int.repr 3) tint) tint)
              Sskip
              Sbreak)
            (Ssequence
              (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
              (Sloop
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                                 (Econst_int (Int.repr 16) tint) tint)
                    Sskip
                    Sbreak)
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _D_80360928 (tarray (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16) 3))
                              (Etempvar _j tuchar)
                              (tptr (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16)))
                            (tarray (Tstruct _ChannelVolumeScaleFade noattr) 16))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _ChannelVolumeScaleFade noattr)))
                        (Tstruct _ChannelVolumeScaleFade noattr))
                      _remainingFrames tushort)
                    (Econst_int (Int.repr 0) tint)))
                (Sset _i
                  (Ecast
                    (Ebinop Oadd (Etempvar _i tuchar)
                      (Econst_int (Int.repr 1) tint) tint) tuchar)))))
          (Sset _j
            (Ecast
              (Ebinop Oadd (Etempvar _j tuchar)
                (Econst_int (Int.repr 1) tint) tint) tuchar))))
      (Ssequence
        (Ssequence
          (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                             (Econst_int (Int.repr 6) tint) tint)
                Sskip
                Sbreak)
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                      (Etempvar _i tuchar)
                      (tptr (Tstruct _SequenceQueueItem noattr)))
                    (Tstruct _SequenceQueueItem noattr)) _priority tuchar)
                (Econst_int (Int.repr 0) tint)))
            (Sset _i
              (Ecast
                (Ebinop Oadd (Etempvar _i tuchar)
                  (Econst_int (Int.repr 1) tint) tint) tuchar))))
        (Ssequence
          (Scall None
            (Evar _sound_banks_enable (Tfunction (tuchar :: tushort :: nil)
                                        tvoid cc_default))
            ((Econst_int (Int.repr 2) tint) ::
             (Econst_int (Int.repr 65535) tint) :: nil))
          (Ssequence
            (Sassign (Evar _sUnused80332118 tushort)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sassign (Evar _sBackgroundMusicTargetVolume tuchar)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign (Evar _sLowerBackgroundMusicVolume tuchar)
                  (Econst_int (Int.repr 0) tint))
                (Ssequence
                  (Sassign
                    (Evar _sSoundBanksThatLowerBackgroundMusic tushort)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sassign (Evar _sUnused80332114 tuchar)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Sassign (Evar _sCurrentBackgroundMusicSeqId tuchar)
                        (Econst_int (Int.repr 255) tint))
                      (Ssequence
                        (Sassign (Evar _gSoundMode tschar)
                          (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Sassign (Evar _sBackgroundMusicQueueSize tuchar)
                            (Econst_int (Int.repr 0) tint))
                          (Ssequence
                            (Sassign
                              (Evar _sBackgroundMusicMaxTargetVolume tuchar)
                              (Econst_int (Int.repr 0) tint))
                            (Ssequence
                              (Sassign (Evar _D_80332120 tuchar)
                                (Econst_int (Int.repr 0) tint))
                              (Ssequence
                                (Sassign (Evar _D_80332124 tuchar)
                                  (Econst_int (Int.repr 0) tint))
                                (Ssequence
                                  (Sassign
                                    (Evar _sNumProcessedSoundRequests tuchar)
                                    (Econst_int (Int.repr 0) tint))
                                  (Sassign (Evar _sSoundRequestCount tuchar)
                                    (Econst_int (Int.repr 0) tint)))))))))))))))))))
|}.

Definition f_get_currently_playing_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_numPlayingSounds, (tptr tuchar)) ::
                (_numSoundsInBank, (tptr tuchar)) ::
                (_soundId, (tptr tuchar)) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: (_count, tuchar) :: (_t'6, tuchar) ::
               (_t'5, tuchar) :: (_t'4, tuchar) :: (_t'3, tuint) ::
               (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _count (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Ssequence
      (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
      (Sloop
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ebinop Oadd
                  (Evar _sMaxChannelsForSoundBank (tarray tuchar 10))
                  (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
            (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                           (Etempvar _t'6 tuchar) tint)
              Sskip
              Sbreak))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                      (Etempvar _bank tuchar) (tptr (tarray tuchar 1)))
                    (tarray tuchar 1)) (Etempvar _i tuchar) (tptr tuchar))
                tuchar))
            (Sifthenelse (Ebinop One (Etempvar _t'5 tuchar)
                           (Econst_int (Int.repr 255) tint) tint)
              (Sset _count
                (Ecast
                  (Ebinop Oadd (Etempvar _count tuchar)
                    (Econst_int (Int.repr 1) tint) tint) tuchar))
              Sskip)))
        (Sset _i
          (Ecast
            (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
              tint) tuchar))))
    (Ssequence
      (Sassign (Ederef (Etempvar _numPlayingSounds (tptr tuchar)) tuchar)
        (Etempvar _count tuchar))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd (Evar _sNumSoundsInBank (tarray tuchar 10))
                (Etempvar _bank tuchar) (tptr tuchar)) tuchar))
          (Sassign (Ederef (Etempvar _numSoundsInBank (tptr tuchar)) tuchar)
            (Etempvar _t'4 tuchar)))
        (Ssequence
          (Sset _t'1
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                    (Etempvar _bank tuchar) (tptr (tarray tuchar 1)))
                  (tarray tuchar 1)) (Econst_int (Int.repr 0) tint)
                (tptr tuchar)) tuchar))
          (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                         (Econst_int (Int.repr 255) tint) tint)
            (Ssequence
              (Sset _t'2
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sCurrentSound (tarray (tarray tuchar 1) 10))
                        (Etempvar _bank tuchar) (tptr (tarray tuchar 1)))
                      (tarray tuchar 1)) (Econst_int (Int.repr 0) tint)
                    (tptr tuchar)) tuchar))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                            (Etempvar _bank tuchar)
                            (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                          (tarray (Tstruct _SoundCharacteristics noattr) 40))
                        (Etempvar _t'2 tuchar)
                        (tptr (Tstruct _SoundCharacteristics noattr)))
                      (Tstruct _SoundCharacteristics noattr)) _soundBits
                    tuint))
                (Sassign (Ederef (Etempvar _soundId (tptr tuchar)) tuchar)
                  (Ecast
                    (Ebinop Oshr (Etempvar _t'3 tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuchar))))
            (Sassign (Ederef (Etempvar _soundId (tptr tuchar)) tuchar)
              (Econst_int (Int.repr 255) tint))))))))
|}.

Definition f_stop_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundBits, tuint) :: (_pos, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_bank, tuchar) :: (_soundIndex, tuchar) :: (_t'1, tint) ::
               (_t'5, tuchar) :: (_t'4, (tptr tfloat)) :: (_t'3, tuint) ::
               (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _bank
    (Ecast
      (Ebinop Oshr
        (Ebinop Oand (Etempvar _soundBits tuint)
          (Econst_int (Int.repr (-268435456)) tuint) tuint)
        (Econst_int (Int.repr 28) tint) tuint) tuchar))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef
            (Ebinop Oadd
              (Ederef
                (Ebinop Oadd
                  (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                  (Etempvar _bank tuchar)
                  (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                (tarray (Tstruct _SoundCharacteristics noattr) 40))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SoundCharacteristics noattr)))
            (Tstruct _SoundCharacteristics noattr)) _next tuchar))
      (Sset _soundIndex (Ecast (Etempvar _t'5 tuchar) tuchar)))
    (Swhile
      (Ebinop One (Etempvar _soundIndex tuchar)
        (Econst_int (Int.repr 255) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _soundIndex tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _soundBits tuint))
          (Sifthenelse (Ebinop Oeq
                         (Ecast
                           (Ebinop Oshr (Etempvar _soundBits tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tushort)
                         (Ecast
                           (Ebinop Oshr (Etempvar _t'3 tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tushort)
                         tint)
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _bank tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Etempvar _soundIndex tuchar)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _x (tptr tfloat)))
              (Sset _t'1
                (Ecast
                  (Ebinop Oeq (Etempvar _t'4 (tptr tfloat))
                    (Etempvar _pos (tptr tfloat)) tint) tbool)))
            (Sset _t'1 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Scall None
              (Evar _update_background_music_after_sound (Tfunction
                                                           (tuchar ::
                                                            tuchar :: nil)
                                                           tvoid cc_default))
              ((Etempvar _bank tuchar) :: (Etempvar _soundIndex tuchar) ::
               nil))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _bank tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Etempvar _soundIndex tuchar)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _soundBits tuint)
                (Econst_int (Int.repr 0) tint))
              (Sset _soundIndex
                (Ecast (Econst_int (Int.repr 255) tint) tuchar))))
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                        (Etempvar _bank tuchar)
                        (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                      (tarray (Tstruct _SoundCharacteristics noattr) 40))
                    (Etempvar _soundIndex tuchar)
                    (tptr (Tstruct _SoundCharacteristics noattr)))
                  (Tstruct _SoundCharacteristics noattr)) _next tuchar))
            (Sset _soundIndex (Ecast (Etempvar _t'2 tuchar) tuchar))))))))
|}.

Definition f_stop_sounds_from_source := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_pos, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_bank, tuchar) :: (_soundIndex, tuchar) :: (_t'3, tuchar) ::
               (_t'2, (tptr tfloat)) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _bank (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _bank tuchar)
                     (Econst_int (Int.repr 10) tint) tint)
        Sskip
        Sbreak)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _next tuchar))
          (Sset _soundIndex (Ecast (Etempvar _t'3 tuchar) tuchar)))
        (Swhile
          (Ebinop One (Etempvar _soundIndex tuchar)
            (Econst_int (Int.repr 255) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _bank tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Etempvar _soundIndex tuchar)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _x (tptr tfloat)))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'2 (tptr tfloat))
                             (Etempvar _pos (tptr tfloat)) tint)
                (Ssequence
                  (Scall None
                    (Evar _update_background_music_after_sound (Tfunction
                                                                 (tuchar ::
                                                                  tuchar ::
                                                                  nil) tvoid
                                                                 cc_default))
                    ((Etempvar _bank tuchar) ::
                     (Etempvar _soundIndex tuchar) :: nil))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                              (Etempvar _bank tuchar)
                              (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                            (tarray (Tstruct _SoundCharacteristics noattr) 40))
                          (Etempvar _soundIndex tuchar)
                          (tptr (Tstruct _SoundCharacteristics noattr)))
                        (Tstruct _SoundCharacteristics noattr)) _soundBits
                      tuint) (Econst_int (Int.repr 0) tint)))
                Sskip))
            (Ssequence
              (Sset _t'1
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                          (Etempvar _bank tuchar)
                          (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                        (tarray (Tstruct _SoundCharacteristics noattr) 40))
                      (Etempvar _soundIndex tuchar)
                      (tptr (Tstruct _SoundCharacteristics noattr)))
                    (Tstruct _SoundCharacteristics noattr)) _next tuchar))
              (Sset _soundIndex (Ecast (Etempvar _t'1 tuchar) tuchar)))))))
    (Sset _bank
      (Ecast
        (Ebinop Oadd (Etempvar _bank tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_stop_sounds_in_bank := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_soundIndex, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef
          (Ebinop Oadd
            (Ederef
              (Ebinop Oadd
                (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                (Etempvar _bank tuchar)
                (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
              (tarray (Tstruct _SoundCharacteristics noattr) 40))
            (Econst_int (Int.repr 0) tint)
            (tptr (Tstruct _SoundCharacteristics noattr)))
          (Tstruct _SoundCharacteristics noattr)) _next tuchar))
    (Sset _soundIndex (Ecast (Etempvar _t'2 tuchar) tuchar)))
  (Swhile
    (Ebinop One (Etempvar _soundIndex tuchar)
      (Econst_int (Int.repr 255) tint) tint)
    (Ssequence
      (Scall None
        (Evar _update_background_music_after_sound (Tfunction
                                                     (tuchar :: tuchar ::
                                                      nil) tvoid cc_default))
        ((Etempvar _bank tuchar) :: (Etempvar _soundIndex tuchar) :: nil))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Ederef
                  (Ebinop Oadd
                    (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                    (Etempvar _bank tuchar)
                    (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                  (tarray (Tstruct _SoundCharacteristics noattr) 40))
                (Etempvar _soundIndex tuchar)
                (tptr (Tstruct _SoundCharacteristics noattr)))
              (Tstruct _SoundCharacteristics noattr)) _soundBits tuint)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sSoundBanks (tarray (tarray (Tstruct _SoundCharacteristics noattr) 40) 10))
                      (Etempvar _bank tuchar)
                      (tptr (tarray (Tstruct _SoundCharacteristics noattr) 40)))
                    (tarray (Tstruct _SoundCharacteristics noattr) 40))
                  (Etempvar _soundIndex tuchar)
                  (tptr (Tstruct _SoundCharacteristics noattr)))
                (Tstruct _SoundCharacteristics noattr)) _next tuchar))
          (Sset _soundIndex (Ecast (Etempvar _t'1 tuchar) tuchar)))))))
|}.

Definition f_stop_sounds_in_continuous_banks := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stop_sounds_in_bank (Tfunction (tuchar :: nil) tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _stop_sounds_in_bank (Tfunction (tuchar :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 4) tint) :: nil))
    (Scall None
      (Evar _stop_sounds_in_bank (Tfunction (tuchar :: nil) tvoid cc_default))
      ((Econst_int (Int.repr 6) tint) :: nil))))
|}.

Definition f_sound_banks_disable := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_bankMask, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 10) tint) tint)
        Sskip
        Sbreak)
      (Ssequence
        (Sifthenelse (Ebinop Oand (Etempvar _bankMask tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _sSoundBankDisabled (tarray tuchar 16))
                (Etempvar _i tuchar) (tptr tuchar)) tuchar)
            (Econst_int (Int.repr 1) tint))
          Sskip)
        (Sset _bankMask
          (Ecast
            (Ebinop Oshr (Etempvar _bankMask tushort)
              (Econst_int (Int.repr 1) tint) tint) tushort))))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_disable_all_sequence_players := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 3) tint) tint)
        Sskip
        Sbreak)
      (Scall None
        (Evar _sequence_player_disable (Tfunction
                                         ((tptr (Tstruct _SequencePlayer noattr)) ::
                                          nil) tvoid cc_default))
        ((Ebinop Oadd
           (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
           (Etempvar _i tuchar) (tptr (Tstruct _SequencePlayer noattr))) ::
         nil)))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_sound_banks_enable := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_bankMask, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Sloop
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                     (Econst_int (Int.repr 10) tint) tint)
        Sskip
        Sbreak)
      (Ssequence
        (Sifthenelse (Ebinop Oand (Etempvar _bankMask tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Sassign
            (Ederef
              (Ebinop Oadd (Evar _sSoundBankDisabled (tarray tuchar 16))
                (Etempvar _i tuchar) (tptr tuchar)) tuchar)
            (Econst_int (Int.repr 0) tint))
          Sskip)
        (Sset _bankMask
          (Ecast
            (Ebinop Oshr (Etempvar _bankMask tushort)
              (Econst_int (Int.repr 1) tint) tint) tushort))))
    (Sset _i
      (Ecast
        (Ebinop Oadd (Etempvar _i tuchar) (Econst_int (Int.repr 1) tint)
          tint) tuchar))))
|}.

Definition f_unused_803209D8 := {|
  fn_return := tuchar;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_channelIndex, tuchar) ::
                (_arg2, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_ret, tuchar) ::
               (_t'2, (tptr (Tstruct _SequenceChannel noattr))) ::
               (_t'1, (tptr (Tstruct _SequenceChannel noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _ret (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                  (Etempvar _player tuchar)
                  (tptr (Tstruct _SequencePlayer noattr)))
                (Tstruct _SequencePlayer noattr)) _channels
              (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
            (Etempvar _channelIndex tuchar)
            (tptr (tptr (Tstruct _SequenceChannel noattr))))
          (tptr (Tstruct _SequenceChannel noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'1 (tptr (Tstruct _SequenceChannel noattr)))
                     (Eaddrof
                       (Evar _gSequenceChannelNone (Tstruct _SequenceChannel noattr))
                       (tptr (Tstruct _SequenceChannel noattr))) tint)
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Ebinop Oadd
                        (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                        (Etempvar _player tuchar)
                        (tptr (Tstruct _SequencePlayer noattr)))
                      (Tstruct _SequencePlayer noattr)) _channels
                    (tarray (tptr (Tstruct _SequenceChannel noattr)) 16))
                  (Etempvar _channelIndex tuchar)
                  (tptr (tptr (Tstruct _SequenceChannel noattr))))
                (tptr (Tstruct _SequenceChannel noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _t'2 (tptr (Tstruct _SequenceChannel noattr)))
                  (Tstruct _SequenceChannel noattr)) _stopSomething2 tschar)
              (Etempvar _arg2 tuchar)))
          (Sset _ret (Ecast (Etempvar _arg2 tuchar) tuchar)))
        Sskip))
    (Sreturn (Some (Etempvar _ret tuchar)))))
|}.

Definition f_set_sound_moving_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_bank, tuchar) :: (_speed, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign
  (Ederef
    (Ebinop Oadd (Evar _sSoundMovingSpeed (tarray tuchar 10))
      (Etempvar _bank tuchar) (tptr tuchar)) tuchar)
  (Etempvar _speed tuchar))
|}.

Definition f_play_dialog_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_dialogID, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_speaker, tuchar) :: (_t'2, tuchar) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oge (Etempvar _dialogID tuchar)
                 (Econst_int (Int.repr 170) tint) tint)
    (Sset _dialogID (Ecast (Econst_int (Int.repr 0) tint) tuchar))
    Sskip)
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd (Evar _sDialogSpeaker (tarray tuchar 170))
            (Etempvar _dialogID tuchar) (tptr tuchar)) tuchar))
      (Sset _speaker (Ecast (Etempvar _t'2 tuchar) tuchar)))
    (Sifthenelse (Ebinop One (Etempvar _speaker tuchar)
                   (Econst_int (Int.repr 255) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Ederef
              (Ebinop Oadd (Evar _sDialogSpeakerVoice (tarray tint 15))
                (Etempvar _speaker tuchar) (tptr tint)) tint))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Etempvar _t'1 tint) ::
             (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil)))
        (Sifthenelse (Ebinop Oeq (Etempvar _speaker tuchar)
                       (Econst_int (Int.repr 2) tint) tint)
          (Scall None
            (Evar _seq_player_play_sequence (Tfunction
                                              (tuchar :: tuchar :: tushort ::
                                               nil) tvoid cc_default))
            ((Econst_int (Int.repr 1) tint) ::
             (Econst_int (Int.repr 16) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          Sskip))
      Sskip)))
|}.

Definition f_play_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_player, tuchar) :: (_seqArgs, tushort) ::
                (_fadeTimer, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_seqId, tuchar) :: (_priority, tuchar) :: (_i, tuchar) ::
               (_foundIndex, tuchar) :: (_t'1, (tvolatile tschar)) ::
               (_t'12, tuchar) :: (_t'11, tuchar) :: (_t'10, tuchar) ::
               (_t'9, tuchar) :: (_t'8, tuchar) :: (_t'7, tuchar) ::
               (_t'6, tuchar) :: (_t'5, tuchar) :: (_t'4, tuchar) ::
               (_t'3, tuchar) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _seqId
    (Ecast
      (Ebinop Oand (Etempvar _seqArgs tushort)
        (Econst_int (Int.repr 255) tint) tint) tuchar))
  (Ssequence
    (Sset _priority
      (Ecast
        (Ebinop Oshr (Etempvar _seqArgs tushort)
          (Econst_int (Int.repr 8) tint) tint) tuchar))
    (Ssequence
      (Sset _foundIndex (Ecast (Econst_int (Int.repr 0) tint) tuchar))
      (Ssequence
        (Sifthenelse (Ebinop One (Etempvar _player tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Scall None
              (Evar _seq_player_play_sequence (Tfunction
                                                (tuchar :: tuchar ::
                                                 tushort :: nil) tvoid
                                                cc_default))
              ((Etempvar _player tuchar) :: (Etempvar _seqId tuchar) ::
               (Etempvar _fadeTimer tushort) :: nil))
            (Sreturn None))
          Sskip)
        (Ssequence
          (Ssequence
            (Sset _t'12 (Evar _sBackgroundMusicQueueSize tuchar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tuchar)
                           (Econst_int (Int.repr 6) tint) tint)
              (Sreturn None)
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
              (Sloop
                (Ssequence
                  (Ssequence
                    (Sset _t'11 (Evar _sBackgroundMusicQueueSize tuchar))
                    (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                                   (Etempvar _t'11 tuchar) tint)
                      Sskip
                      Sbreak))
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                            (Etempvar _i tuchar)
                            (tptr (Tstruct _SequenceQueueItem noattr)))
                          (Tstruct _SequenceQueueItem noattr)) _seqId tuchar))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuchar)
                                   (Etempvar _seqId tuchar) tint)
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _i tuchar)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Scall None
                            (Evar _seq_player_play_sequence (Tfunction
                                                              (tuchar ::
                                                               tuchar ::
                                                               tushort ::
                                                               nil) tvoid
                                                              cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Etempvar _seqId tuchar) ::
                             (Etempvar _fadeTimer tushort) :: nil))
                          (Ssequence
                            (Sset _t'1
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr (Tstruct _SequencePlayer noattr)))
                                  (Tstruct _SequencePlayer noattr)) _enabled
                                (tvolatile tschar)))
                            (Sifthenelse (Eunop Onotbool
                                           (Etempvar _t'1 (tvolatile tschar))
                                           tint)
                              (Ssequence
                                (Sset _t'10
                                  (Efield
                                    (Ederef
                                      (Ebinop Oadd
                                        (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                        (Econst_int (Int.repr 0) tint)
                                        (tptr (Tstruct _SequenceQueueItem noattr)))
                                      (Tstruct _SequenceQueueItem noattr))
                                    _seqId tuchar))
                                (Scall None
                                  (Evar _stop_background_music (Tfunction
                                                                 (tushort ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Etempvar _t'10 tuchar) :: nil)))
                              Sskip)))
                        (Sreturn None))
                      Sskip)))
                (Sset _i
                  (Ecast
                    (Ebinop Oadd (Etempvar _i tuchar)
                      (Econst_int (Int.repr 1) tint) tint) tuchar))))
            (Ssequence
              (Ssequence
                (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
                (Sloop
                  (Ssequence
                    (Ssequence
                      (Sset _t'8 (Evar _sBackgroundMusicQueueSize tuchar))
                      (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                                     (Etempvar _t'8 tuchar) tint)
                        Sskip
                        Sbreak))
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                              (Etempvar _i tuchar)
                              (tptr (Tstruct _SequenceQueueItem noattr)))
                            (Tstruct _SequenceQueueItem noattr)) _priority
                          tuchar))
                      (Sifthenelse (Ebinop Ole (Etempvar _t'6 tuchar)
                                     (Etempvar _priority tuchar) tint)
                        (Ssequence
                          (Sset _foundIndex
                            (Ecast (Etempvar _i tuchar) tuchar))
                          (Ssequence
                            (Sset _t'7
                              (Evar _sBackgroundMusicQueueSize tuchar))
                            (Sset _i (Ecast (Etempvar _t'7 tuchar) tuchar))))
                        Sskip)))
                  (Sset _i
                    (Ecast
                      (Ebinop Oadd (Etempvar _i tuchar)
                        (Econst_int (Int.repr 1) tint) tint) tuchar))))
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _foundIndex tuchar)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Scall None
                      (Evar _seq_player_play_sequence (Tfunction
                                                        (tuchar :: tuchar ::
                                                         tushort :: nil)
                                                        tvoid cc_default))
                      ((Econst_int (Int.repr 0) tint) ::
                       (Etempvar _seqId tuchar) ::
                       (Etempvar _fadeTimer tushort) :: nil))
                    (Ssequence
                      (Sset _t'5 (Evar _sBackgroundMusicQueueSize tuchar))
                      (Sassign (Evar _sBackgroundMusicQueueSize tuchar)
                        (Ebinop Oadd (Etempvar _t'5 tuchar)
                          (Econst_int (Int.repr 1) tint) tint))))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'4 (Evar _sBackgroundMusicQueueSize tuchar))
                      (Sset _i
                        (Ecast
                          (Ebinop Osub (Etempvar _t'4 tuchar)
                            (Econst_int (Int.repr 1) tint) tint) tuchar)))
                    (Sloop
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _i tuchar)
                                       (Etempvar _foundIndex tuchar) tint)
                          Sskip
                          Sbreak)
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                    (Ebinop Osub (Etempvar _i tuchar)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (tptr (Tstruct _SequenceQueueItem noattr)))
                                  (Tstruct _SequenceQueueItem noattr))
                                _priority tuchar))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                    (Etempvar _i tuchar)
                                    (tptr (Tstruct _SequenceQueueItem noattr)))
                                  (Tstruct _SequenceQueueItem noattr))
                                _priority tuchar) (Etempvar _t'3 tuchar)))
                          (Ssequence
                            (Sset _t'2
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                    (Ebinop Osub (Etempvar _i tuchar)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (tptr (Tstruct _SequenceQueueItem noattr)))
                                  (Tstruct _SequenceQueueItem noattr)) _seqId
                                tuchar))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                    (Etempvar _i tuchar)
                                    (tptr (Tstruct _SequenceQueueItem noattr)))
                                  (Tstruct _SequenceQueueItem noattr)) _seqId
                                tuchar) (Etempvar _t'2 tuchar)))))
                      (Sset _i
                        (Ecast
                          (Ebinop Osub (Etempvar _i tuchar)
                            (Econst_int (Int.repr 1) tint) tint) tuchar))))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                            (Etempvar _foundIndex tuchar)
                            (tptr (Tstruct _SequenceQueueItem noattr)))
                          (Tstruct _SequenceQueueItem noattr)) _priority
                        tuchar) (Etempvar _priority tuchar))
                    (Sassign
                      (Efield
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                            (Etempvar _foundIndex tuchar)
                            (tptr (Tstruct _SequenceQueueItem noattr)))
                          (Tstruct _SequenceQueueItem noattr)) _seqId tuchar)
                      (Etempvar _seqId tuchar))))))))))))
|}.

Definition f_stop_background_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_seqId, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_foundIndex, tuchar) :: (_i, tuchar) :: (_t'11, tuchar) ::
               (_t'10, tuchar) :: (_t'9, tuchar) :: (_t'8, tuchar) ::
               (_t'7, tuchar) :: (_t'6, tuchar) :: (_t'5, tuchar) ::
               (_t'4, tuchar) :: (_t'3, tuchar) :: (_t'2, tuchar) ::
               (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11 (Evar _sBackgroundMusicQueueSize tuchar))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tuchar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'10 (Evar _sBackgroundMusicQueueSize tuchar))
      (Sset _foundIndex (Ecast (Etempvar _t'10 tuchar) tuchar)))
    (Ssequence
      (Ssequence
        (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
        (Sloop
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _sBackgroundMusicQueueSize tuchar))
              (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                             (Etempvar _t'9 tuchar) tint)
                Sskip
                Sbreak))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Ebinop Oadd
                      (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                      (Etempvar _i tuchar)
                      (tptr (Tstruct _SequenceQueueItem noattr)))
                    (Tstruct _SequenceQueueItem noattr)) _seqId tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuchar)
                             (Ecast
                               (Ebinop Oand (Etempvar _seqId tushort)
                                 (Econst_int (Int.repr 255) tint) tint)
                               tuchar) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'8 (Evar _sBackgroundMusicQueueSize tuchar))
                    (Sassign (Evar _sBackgroundMusicQueueSize tuchar)
                      (Ebinop Osub (Etempvar _t'8 tuchar)
                        (Econst_int (Int.repr 1) tint) tint)))
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _i tuchar)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'6 (Evar _sBackgroundMusicQueueSize tuchar))
                        (Sifthenelse (Ebinop One (Etempvar _t'6 tuchar)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr (Tstruct _SequenceQueueItem noattr)))
                                  (Tstruct _SequenceQueueItem noattr)) _seqId
                                tuchar))
                            (Scall None
                              (Evar _seq_player_play_sequence (Tfunction
                                                                (tuchar ::
                                                                 tuchar ::
                                                                 tushort ::
                                                                 nil) tvoid
                                                                cc_default))
                              ((Econst_int (Int.repr 0) tint) ::
                               (Etempvar _t'7 tuchar) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))
                          (Scall None
                            (Evar _seq_player_fade_out (Tfunction
                                                         (tuchar ::
                                                          tushort :: nil)
                                                         tvoid cc_default))
                            ((Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 20) tint) :: nil))))
                      Sskip)
                    (Ssequence
                      (Sset _foundIndex (Ecast (Etempvar _i tuchar) tuchar))
                      (Ssequence
                        (Sset _t'5 (Evar _sBackgroundMusicQueueSize tuchar))
                        (Sset _i (Ecast (Etempvar _t'5 tuchar) tuchar))))))
                Sskip)))
          (Sset _i
            (Ecast
              (Ebinop Oadd (Etempvar _i tuchar)
                (Econst_int (Int.repr 1) tint) tint) tuchar))))
      (Ssequence
        (Ssequence
          (Sset _i (Ecast (Etempvar _foundIndex tuchar) tuchar))
          (Sloop
            (Ssequence
              (Ssequence
                (Sset _t'3 (Evar _sBackgroundMusicQueueSize tuchar))
                (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                               (Etempvar _t'3 tuchar) tint)
                  Sskip
                  Sbreak))
              (Ssequence
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                          (Ebinop Oadd (Etempvar _i tuchar)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr (Tstruct _SequenceQueueItem noattr)))
                        (Tstruct _SequenceQueueItem noattr)) _priority
                      tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _SequenceQueueItem noattr)))
                        (Tstruct _SequenceQueueItem noattr)) _priority
                      tuchar) (Etempvar _t'2 tuchar)))
                (Ssequence
                  (Sset _t'1
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                          (Ebinop Oadd (Etempvar _i tuchar)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr (Tstruct _SequenceQueueItem noattr)))
                        (Tstruct _SequenceQueueItem noattr)) _seqId tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                          (Etempvar _i tuchar)
                          (tptr (Tstruct _SequenceQueueItem noattr)))
                        (Tstruct _SequenceQueueItem noattr)) _seqId tuchar)
                    (Etempvar _t'1 tuchar)))))
            (Sset _i
              (Ecast
                (Ebinop Oadd (Etempvar _i tuchar)
                  (Econst_int (Int.repr 1) tint) tint) tuchar))))
        (Sassign
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                (Etempvar _i tuchar)
                (tptr (Tstruct _SequenceQueueItem noattr)))
              (Tstruct _SequenceQueueItem noattr)) _priority tuchar)
          (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_fadeout_background_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_seqId, tushort) :: (_fadeOut, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tuchar) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2 (Evar _sBackgroundMusicQueueSize tuchar))
    (Sifthenelse (Ebinop One (Etempvar _t'2 tuchar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SequenceQueueItem noattr)))
              (Tstruct _SequenceQueueItem noattr)) _seqId tuchar))
        (Sset _t'1
          (Ecast
            (Ebinop Oeq (Etempvar _t'3 tuchar)
              (Ecast
                (Ebinop Oand (Etempvar _seqId tushort)
                  (Econst_int (Int.repr 255) tint) tint) tuchar) tint) tbool)))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Scall None
      (Evar _seq_player_fade_out (Tfunction (tuchar :: tushort :: nil) tvoid
                                   cc_default))
      ((Econst_int (Int.repr 0) tint) :: (Etempvar _fadeOut tushort) :: nil))
    Sskip))
|}.

Definition f_drop_queued_background_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sBackgroundMusicQueueSize tuchar))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Sassign (Evar _sBackgroundMusicQueueSize tuchar)
      (Econst_int (Int.repr 1) tint))
    Sskip))
|}.

Definition f_get_current_background_music := {|
  fn_return := tushort;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _sBackgroundMusicQueueSize tuchar))
    (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _SequenceQueueItem noattr)))
              (Tstruct _SequenceQueueItem noattr)) _priority tuchar))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _sBackgroundMusicQueue (tarray (Tstruct _SequenceQueueItem noattr) 6))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _SequenceQueueItem noattr)))
                (Tstruct _SequenceQueueItem noattr)) _seqId tuchar))
          (Sreturn (Some (Ebinop Oadd
                           (Ebinop Oshl (Etempvar _t'2 tuchar)
                             (Econst_int (Int.repr 8) tint) tint)
                           (Etempvar _t'3 tuchar) tint)))))
      Sskip))
  (Sreturn (Some (Eunop Oneg (Econst_int (Int.repr 1) tint) tint))))
|}.

Definition f_func_80320ED8 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, (tvolatile tschar)) ::
               (_t'10, tuchar) :: (_t'9, tuchar) :: (_t'8, tuchar) ::
               (_t'7, tuchar) :: (_t'6, tuchar) :: (_t'5, tuchar) ::
               (_t'4, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Econst_int (Int.repr 1) tint)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _enabled (tvolatile tschar)))
      (Sifthenelse (Etempvar _t'1 (tvolatile tschar))
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'10 (Evar _sBackgroundMusicMaxTargetVolume tuchar))
          (Sset _t'2
            (Ecast
              (Ebinop Oeq (Etempvar _t'10 tuchar)
                (Econst_int (Int.repr 0) tint) tint) tbool)))))
    (Sifthenelse (Etempvar _t'2 tint) (Sreturn None) Sskip))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Scall None
        (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                             cc_default))
        ((Econst_int (Int.repr 50) tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'7 (Evar _sBackgroundMusicTargetVolume tuchar))
          (Sifthenelse (Ebinop One (Etempvar _t'7 tuchar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'8 (Evar _D_80332120 tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tuchar)
                             (Econst_int (Int.repr 19) tint) tint)
                (Sset _t'3 (Ecast (Econst_int (Int.repr 1) tint) tbool))
                (Ssequence
                  (Ssequence
                    (Sset _t'9 (Evar _D_80332120 tuchar))
                    (Sset _t'3
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'9 tuchar)
                          (Econst_int (Int.repr 11) tint) tint) tbool)))
                  (Sset _t'3 (Ecast (Etempvar _t'3 tint) tbool)))))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Sset _t'6 (Evar _D_80332120 tuchar))
              (Scall None
                (Evar _seq_player_play_sequence (Tfunction
                                                  (tuchar :: tuchar ::
                                                   tushort :: nil) tvoid
                                                  cc_default))
                ((Econst_int (Int.repr 1) tint) :: (Etempvar _t'6 tuchar) ::
                 (Econst_int (Int.repr 1) tint) :: nil)))
            (Ssequence
              (Sset _t'4 (Evar _D_80332124 tuchar))
              (Sifthenelse (Ebinop One (Etempvar _t'4 tuchar)
                             (Econst_int (Int.repr 255) tint) tint)
                (Ssequence
                  (Sset _t'5 (Evar _D_80332124 tuchar))
                  (Scall None
                    (Evar _seq_player_fade_to_target_volume (Tfunction
                                                              (tint ::
                                                               tushort ::
                                                               tuchar :: nil)
                                                              tvoid
                                                              cc_default))
                    ((Econst_int (Int.repr 1) tint) ::
                     (Econst_int (Int.repr 1) tint) ::
                     (Etempvar _t'5 tuchar) :: nil)))
                Sskip)))
          Sskip)))))
|}.

Definition f_play_secondary_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_seqId, tuchar) :: (_bgMusicVolume, tuchar) ::
                (_volume, tuchar) :: (_fadeTimer, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_dummy, tuint) :: (_t'1, tint) :: (_t'4, tuchar) ::
               (_t'3, tuchar) :: (_t'2, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sUnused80332118 tushort) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _sCurrentBackgroundMusicSeqId tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tuchar)
                       (Econst_int (Int.repr 255) tint) tint)
          (Sset _t'1 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'4 (Evar _sCurrentBackgroundMusicSeqId tuchar))
            (Sset _t'1
              (Ecast
                (Ebinop Oeq (Etempvar _t'4 tuchar)
                  (Econst_int (Int.repr 2) tint) tint) tbool)))))
      (Sifthenelse (Etempvar _t'1 tint) (Sreturn None) Sskip))
    (Ssequence
      (Sset _t'2 (Evar _sBackgroundMusicTargetVolume tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sassign (Evar _sBackgroundMusicTargetVolume tuchar)
            (Ebinop Oadd (Etempvar _bgMusicVolume tuchar)
              (Econst_int (Int.repr 128) tint) tint))
          (Ssequence
            (Scall None
              (Evar _begin_background_music_fade (Tfunction (tushort :: nil)
                                                   tuchar cc_default))
              ((Etempvar _fadeTimer tushort) :: nil))
            (Ssequence
              (Scall None
                (Evar _seq_player_play_sequence (Tfunction
                                                  (tuchar :: tuchar ::
                                                   tushort :: nil) tvoid
                                                  cc_default))
                ((Econst_int (Int.repr 1) tint) ::
                 (Etempvar _seqId tuchar) ::
                 (Ebinop Oshr (Etempvar _fadeTimer tushort)
                   (Econst_int (Int.repr 1) tint) tint) :: nil))
              (Ssequence
                (Sifthenelse (Ebinop Olt (Etempvar _volume tuchar)
                               (Econst_int (Int.repr 128) tint) tint)
                  (Scall None
                    (Evar _seq_player_fade_to_target_volume (Tfunction
                                                              (tint ::
                                                               tushort ::
                                                               tuchar :: nil)
                                                              tvoid
                                                              cc_default))
                    ((Econst_int (Int.repr 1) tint) ::
                     (Etempvar _fadeTimer tushort) ::
                     (Etempvar _volume tuchar) :: nil))
                  Sskip)
                (Ssequence
                  (Sassign (Evar _D_80332124 tuchar)
                    (Etempvar _volume tuchar))
                  (Sassign (Evar _D_80332120 tuchar)
                    (Etempvar _seqId tuchar)))))))
        (Sifthenelse (Ebinop One (Etempvar _volume tuchar)
                       (Econst_int (Int.repr 255) tint) tint)
          (Ssequence
            (Sassign (Evar _sBackgroundMusicTargetVolume tuchar)
              (Ebinop Oadd (Etempvar _bgMusicVolume tuchar)
                (Econst_int (Int.repr 128) tint) tint))
            (Ssequence
              (Scall None
                (Evar _begin_background_music_fade (Tfunction
                                                     (tushort :: nil) tuchar
                                                     cc_default))
                ((Etempvar _fadeTimer tushort) :: nil))
              (Ssequence
                (Scall None
                  (Evar _seq_player_fade_to_target_volume (Tfunction
                                                            (tint ::
                                                             tushort ::
                                                             tuchar :: nil)
                                                            tvoid cc_default))
                  ((Econst_int (Int.repr 1) tint) ::
                   (Etempvar _fadeTimer tushort) ::
                   (Etempvar _volume tuchar) :: nil))
                (Sassign (Evar _D_80332124 tuchar) (Etempvar _volume tuchar)))))
          Sskip)))))
|}.

Definition f_func_80321080 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fadeTimer, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sBackgroundMusicTargetVolume tuchar))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sassign (Evar _sBackgroundMusicTargetVolume tuchar)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign (Evar _D_80332120 tuchar) (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign (Evar _D_80332124 tuchar) (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Scall None
              (Evar _begin_background_music_fade (Tfunction (tushort :: nil)
                                                   tuchar cc_default))
              ((Etempvar _fadeTimer tushort) :: nil))
            (Scall None
              (Evar _seq_player_fade_out (Tfunction
                                           (tuchar :: tushort :: nil) tvoid
                                           cc_default))
              ((Econst_int (Int.repr 1) tint) ::
               (Etempvar _fadeTimer tushort) :: nil))))))
    Sskip))
|}.

Definition f_func_803210D4 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fadeDuration, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tuchar) :: (_t'2, (tvolatile tschar)) ::
               (_t'1, (tvolatile tschar)) :: (_t'3, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3 (Evar _sHasStartedFadeOut tuchar))
    (Sifthenelse (Etempvar _t'3 tuchar) (Sreturn None) Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SequencePlayer noattr)))
            (Tstruct _SequencePlayer noattr)) _enabled (tvolatile tschar)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 (tvolatile tschar))
                     (Econst_int (Int.repr 1) tint) tint)
        (Scall None
          (Evar _seq_player_fade_to_zero_volume (Tfunction
                                                  (tint :: tushort :: nil)
                                                  tvoid cc_default))
          ((Econst_int (Int.repr 0) tint) ::
           (Etempvar _fadeDuration tushort) :: nil))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gSequencePlayers (tarray (Tstruct _SequencePlayer noattr) 3))
                (Econst_int (Int.repr 1) tint)
                (tptr (Tstruct _SequencePlayer noattr)))
              (Tstruct _SequencePlayer noattr)) _enabled (tvolatile tschar)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 (tvolatile tschar))
                       (Econst_int (Int.repr 1) tint) tint)
          (Scall None
            (Evar _seq_player_fade_to_zero_volume (Tfunction
                                                    (tint :: tushort :: nil)
                                                    tvoid cc_default))
            ((Econst_int (Int.repr 1) tint) ::
             (Etempvar _fadeDuration tushort) :: nil))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _i (Ecast (Econst_int (Int.repr 0) tint) tuchar))
          (Sloop
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _i tuchar)
                             (Econst_int (Int.repr 10) tint) tint)
                Sskip
                Sbreak)
              (Sifthenelse (Ebinop One (Etempvar _i tuchar)
                             (Econst_int (Int.repr 7) tint) tint)
                (Scall None
                  (Evar _fade_channel_volume_scale (Tfunction
                                                     (tuchar :: tuchar ::
                                                      tuchar :: tushort ::
                                                      nil) tvoid cc_default))
                  ((Econst_int (Int.repr 2) tint) :: (Etempvar _i tuchar) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Ebinop Odiv (Etempvar _fadeDuration tushort)
                     (Econst_int (Int.repr 16) tint) tint) :: nil))
                Sskip))
            (Sset _i
              (Ecast
                (Ebinop Oadd (Etempvar _i tuchar)
                  (Econst_int (Int.repr 1) tint) tint) tuchar))))
        (Sassign (Evar _sHasStartedFadeOut tuchar)
          (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_play_course_clear := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 1) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 0) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_play_peachs_jingle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 29) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 0) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_play_puzzle_jingle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 27) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 20) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_play_star_fanfare := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 18) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 20) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_play_power_star_jingle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Eunop Onotbool (Etempvar _arg0 tuchar) tint)
    (Sassign (Evar _sBackgroundMusicTargetVolume tuchar)
      (Econst_int (Int.repr 0) tint))
    Sskip)
  (Ssequence
    (Scall None
      (Evar _seq_player_play_sequence (Tfunction
                                        (tuchar :: tuchar :: tushort :: nil)
                                        tvoid cc_default))
      ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 21) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
        (Ebinop Oor (Econst_int (Int.repr 128) tint)
          (Econst_int (Int.repr 20) tint) tint))
      (Scall None
        (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                             cc_default))
        ((Econst_int (Int.repr 50) tint) :: nil)))))
|}.

Definition f_play_race_fanfare := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 20) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 20) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_play_toads_jingle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_play_sequence (Tfunction
                                      (tuchar :: tuchar :: tushort :: nil)
                                      tvoid cc_default))
    ((Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 28) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Sassign (Evar _sBackgroundMusicMaxTargetVolume tuchar)
      (Ebinop Oor (Econst_int (Int.repr 128) tint)
        (Econst_int (Int.repr 20) tint) tint))
    (Scall None
      (Evar _begin_background_music_fade (Tfunction (tushort :: nil) tuchar
                                           cc_default))
      ((Econst_int (Int.repr 50) tint) :: nil))))
|}.

Definition f_sound_reset := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_presetId, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sGameLoopTicked tint) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Scall None
      (Evar _disable_all_sequence_players (Tfunction nil tvoid cc_default))
      nil)
    (Ssequence
      (Scall None (Evar _sound_init (Tfunction nil tvoid cc_default)) nil)
      (Ssequence
        (Scall None
          (Evar _audio_reset_session (Tfunction
                                       ((tptr (Tstruct _AudioSessionSettings noattr)) ::
                                        nil) tvoid cc_default))
          ((Ebinop Oadd
             (Evar _gAudioSessionPresets (tarray (Tstruct _AudioSessionSettings noattr) 18))
             (Etempvar _presetId tuchar)
             (tptr (Tstruct _AudioSessionSettings noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _osWritebackDCacheAll (Tfunction nil tvoid cc_default))
            nil)
          (Ssequence
            (Sifthenelse (Ebinop One (Etempvar _presetId tuchar)
                           (Econst_int (Int.repr 7) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _preload_sequence (Tfunction (tuint :: tuchar :: nil)
                                            tvoid cc_default))
                  ((Econst_int (Int.repr 27) tint) ::
                   (Ebinop Oor (Econst_int (Int.repr 2) tint)
                     (Econst_int (Int.repr 1) tint) tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _preload_sequence (Tfunction
                                              (tuint :: tuchar :: nil) tvoid
                                              cc_default))
                    ((Econst_int (Int.repr 29) tint) ::
                     (Ebinop Oor (Econst_int (Int.repr 2) tint)
                       (Econst_int (Int.repr 1) tint) tint) :: nil))
                  (Scall None
                    (Evar _preload_sequence (Tfunction
                                              (tuint :: tuchar :: nil) tvoid
                                              cc_default))
                    ((Econst_int (Int.repr 21) tint) ::
                     (Ebinop Oor (Econst_int (Int.repr 2) tint)
                       (Econst_int (Int.repr 1) tint) tint) :: nil))))
              Sskip)
            (Ssequence
              (Scall None
                (Evar _seq_player_play_sequence (Tfunction
                                                  (tuchar :: tuchar ::
                                                   tushort :: nil) tvoid
                                                  cc_default))
                ((Econst_int (Int.repr 2) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'2 (Evar _D_80332108 tuchar))
                  (Sassign (Evar _D_80332108 tuchar)
                    (Ebinop Oadd
                      (Ebinop Oand (Etempvar _t'2 tuchar)
                        (Econst_int (Int.repr 240) tint) tint)
                      (Etempvar _presetId tuchar) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'1 (Evar _D_80332108 tuchar))
                    (Sassign (Evar _gSoundMode tschar)
                      (Ebinop Oshr (Etempvar _t'1 tuchar)
                        (Econst_int (Int.repr 4) tint) tint)))
                  (Sassign (Evar _sHasStartedFadeOut tuchar)
                    (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_audio_set_sound_mode := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMode, tuchar) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1 (Evar _D_80332108 tuchar))
    (Sassign (Evar _D_80332108 tuchar)
      (Ebinop Oadd
        (Ebinop Oand (Etempvar _t'1 tuchar) (Econst_int (Int.repr 15) tint)
          tint)
        (Ebinop Oshl (Etempvar _soundMode tuchar)
          (Econst_int (Int.repr 4) tint) tint) tint)))
  (Sassign (Evar _gSoundMode tschar) (Etempvar _soundMode tuchar)))
|}.

Definition f_unused_80321460 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tint) :: (_arg1, tint) :: (_arg2, tint) ::
                (_arg3, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
|}.

Definition f_unused_80321474 := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg0, tint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
Sskip
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
 Composite _Animation Struct
   (Member_plain _flags tshort :: Member_plain _animYTransDivisor tshort ::
    Member_plain _startFrame tshort :: Member_plain _loopStart tshort ::
    Member_plain _loopEnd tshort :: Member_plain _unusedBoneCount tshort ::
    Member_plain _values (tptr tshort) ::
    Member_plain _index (tptr tushort) :: Member_plain _length tuint :: nil)
   noattr ::
 Composite _GraphNode Struct
   (Member_plain _type tshort :: Member_plain _flags tshort ::
    Member_plain _prev (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _parent (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _children (tptr (Tstruct _GraphNode noattr)) :: nil)
   noattr ::
 Composite _AnimInfo Struct
   (Member_plain _animID tshort :: Member_plain _animYTrans tshort ::
    Member_plain _curAnim (tptr (Tstruct _Animation noattr)) ::
    Member_plain _animFrame tshort :: Member_plain _animTimer tushort ::
    Member_plain _animFrameAccelAssist tint ::
    Member_plain _animAccel tint :: nil)
   noattr ::
 Composite _GraphNodeObject Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _sharedChild (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _angle (tarray tshort 3) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _scale (tarray tfloat 3) ::
    Member_plain _animInfo (Tstruct _AnimInfo noattr) ::
    Member_plain _unk4C (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _throwMatrix (tptr (tarray (tarray tfloat 4) 4)) ::
    Member_plain _cameraToObject (tarray tfloat 3) :: nil)
   noattr ::
 Composite _ObjectNode Struct
   (Member_plain _gfx (Tstruct _GraphNodeObject noattr) ::
    Member_plain _next (tptr (Tstruct _ObjectNode noattr)) ::
    Member_plain _prev (tptr (Tstruct _ObjectNode noattr)) :: nil)
   noattr ::
 Composite __727 Union
   (Member_plain _asU32 (tarray tuint 80) ::
    Member_plain _asS32 (tarray tint 80) ::
    Member_plain _asS16 (tarray (tarray tshort 2) 80) ::
    Member_plain _asF32 (tarray tfloat 80) ::
    Member_plain _asS16P (tarray (tptr tshort) 80) ::
    Member_plain _asS32P (tarray (tptr tint) 80) ::
    Member_plain _asAnims
      (tarray (tptr (tptr (Tstruct _Animation noattr))) 80) ::
    Member_plain _asWaypoint (tarray (tptr (Tstruct _Waypoint noattr)) 80) ::
    Member_plain _asChainSegment
      (tarray (tptr (Tstruct _ChainSegment noattr)) 80) ::
    Member_plain _asObject (tarray (tptr (Tstruct _Object noattr)) 80) ::
    Member_plain _asSurface (tarray (tptr (Tstruct _Surface noattr)) 80) ::
    Member_plain _asVoidPtr (tarray (tptr tvoid) 80) ::
    Member_plain _asConstVoidPtr (tarray (tptr tvoid) 80) :: nil)
   noattr ::
 Composite _Object Struct
   (Member_plain _header (Tstruct _ObjectNode noattr) ::
    Member_plain _parentObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _prevObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _collidedObjInteractTypes tuint ::
    Member_plain _activeFlags tshort ::
    Member_plain _numCollidedObjs tshort ::
    Member_plain _collidedObjs (tarray (tptr (Tstruct _Object noattr)) 4) ::
    Member_plain _rawData (Tunion __727 noattr) ::
    Member_plain _unused1 tuint ::
    Member_plain _curBhvCommand (tptr tuint) ::
    Member_plain _bhvStackIndex tuint ::
    Member_plain _bhvStack (tarray tuint 8) ::
    Member_plain _bhvDelayTimer tshort ::
    Member_plain _respawnInfoType tshort ::
    Member_plain _hitboxRadius tfloat :: Member_plain _hitboxHeight tfloat ::
    Member_plain _hurtboxRadius tfloat ::
    Member_plain _hurtboxHeight tfloat ::
    Member_plain _hitboxDownOffset tfloat ::
    Member_plain _behavior (tptr tuint) :: Member_plain _unused2 tuint ::
    Member_plain _platform (tptr (Tstruct _Object noattr)) ::
    Member_plain _collisionData (tptr tvoid) ::
    Member_plain _transform (tarray (tarray tfloat 4) 4) ::
    Member_plain _respawnInfo (tptr tvoid) :: nil)
   noattr ::
 Composite _Waypoint Struct
   (Member_plain _flags tshort :: Member_plain _pos (tarray tshort 3) :: nil)
   noattr ::
 Composite __732 Struct
   (Member_plain _x tfloat :: Member_plain _y tfloat ::
    Member_plain _z tfloat :: nil)
   noattr ::
 Composite _Surface Struct
   (Member_plain _type tshort :: Member_plain _force tshort ::
    Member_plain _flags tschar :: Member_plain _room tschar ::
    Member_plain _lowerY tshort :: Member_plain _upperY tshort ::
    Member_plain _vertex1 (tarray tshort 3) ::
    Member_plain _vertex2 (tarray tshort 3) ::
    Member_plain _vertex3 (tarray tshort 3) ::
    Member_plain _normal (Tstruct __732 noattr) ::
    Member_plain _originOffset tfloat ::
    Member_plain _object (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _MarioBodyState Struct
   (Member_plain _action tuint :: Member_plain _capState tschar ::
    Member_plain _eyeState tschar :: Member_plain _handState tschar ::
    Member_plain _wingFlutter tschar :: Member_plain _modelState tshort ::
    Member_plain _grabPos tschar :: Member_plain _punchState tuchar ::
    Member_plain _torsoAngle (tarray tshort 3) ::
    Member_plain _headAngle (tarray tshort 3) ::
    Member_plain _heldObjLastPosition (tarray tfloat 3) ::
    Member_plain _filler (tarray tuchar 4) :: nil)
   noattr ::
 Composite _MarioState Struct
   (Member_plain _unk00 tushort :: Member_plain _input tushort ::
    Member_plain _flags tuint :: Member_plain _particleFlags tuint ::
    Member_plain _action tuint :: Member_plain _prevAction tuint ::
    Member_plain _terrainSoundAddend tuint ::
    Member_plain _actionState tushort :: Member_plain _actionTimer tushort ::
    Member_plain _actionArg tuint :: Member_plain _intendedMag tfloat ::
    Member_plain _intendedYaw tshort :: Member_plain _invincTimer tshort ::
    Member_plain _framesSinceA tuchar :: Member_plain _framesSinceB tuchar ::
    Member_plain _wallKickTimer tuchar ::
    Member_plain _doubleJumpTimer tuchar ::
    Member_plain _faceAngle (tarray tshort 3) ::
    Member_plain _angleVel (tarray tshort 3) ::
    Member_plain _slideYaw tshort :: Member_plain _twirlYaw tshort ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _vel (tarray tfloat 3) :: Member_plain _forwardVel tfloat ::
    Member_plain _slideVelX tfloat :: Member_plain _slideVelZ tfloat ::
    Member_plain _wall (tptr (Tstruct _Surface noattr)) ::
    Member_plain _ceil (tptr (Tstruct _Surface noattr)) ::
    Member_plain _floor (tptr (Tstruct _Surface noattr)) ::
    Member_plain _ceilHeight tfloat :: Member_plain _floorHeight tfloat ::
    Member_plain _floorAngle tshort :: Member_plain _waterLevel tshort ::
    Member_plain _interactObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _heldObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _usedObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _riddenObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _marioObj (tptr (Tstruct _Object noattr)) ::
    Member_plain _spawnInfo (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _area (tptr (Tstruct _Area noattr)) ::
    Member_plain _statusForCamera (tptr (Tstruct _PlayerCameraState noattr)) ::
    Member_plain _marioBodyState (tptr (Tstruct _MarioBodyState noattr)) ::
    Member_plain _controller (tptr (Tstruct _Controller noattr)) ::
    Member_plain _animList (tptr (Tstruct _DmaHandlerList noattr)) ::
    Member_plain _collidedObjInteractTypes tuint ::
    Member_plain _numCoins tshort :: Member_plain _numStars tshort ::
    Member_plain _numKeys tschar :: Member_plain _numLives tschar ::
    Member_plain _health tshort :: Member_plain _unkB0 tshort ::
    Member_plain _hurtCounter tuchar :: Member_plain _healCounter tuchar ::
    Member_plain _squishTimer tuchar ::
    Member_plain _fadeWarpOpacity tuchar :: Member_plain _capTimer tushort ::
    Member_plain _prevNumStarsForDialog tshort ::
    Member_plain _peakHeight tfloat :: Member_plain _quicksandDepth tfloat ::
    Member_plain _gettingBlownGravity tfloat :: nil)
   noattr ::
 Composite __977 Union
   (Member_plain _value (tptr tvoid) :: Member_plain _count tint :: nil)
   noattr ::
 Composite _AudioListItem Struct
   (Member_plain _prev (tptr (Tstruct _AudioListItem noattr)) ::
    Member_plain _next (tptr (Tstruct _AudioListItem noattr)) ::
    Member_plain _u (Tunion __977 noattr) ::
    Member_plain _pool (tptr (Tstruct _NotePool noattr)) :: nil)
   noattr ::
 Composite _NotePool Struct
   (Member_plain _disabled (Tstruct _AudioListItem noattr) ::
    Member_plain _decaying (Tstruct _AudioListItem noattr) ::
    Member_plain _releasing (Tstruct _AudioListItem noattr) ::
    Member_plain _active (Tstruct _AudioListItem noattr) :: nil)
   noattr ::
 Composite _VibratoState Struct
   (Member_plain _seqChannel (tptr (Tstruct _SequenceChannel noattr)) ::
    Member_plain _time tuint :: Member_plain _curve (tptr tschar) ::
    Member_plain _active tuchar :: Member_plain _rate tushort ::
    Member_plain _extent tushort :: Member_plain _rateChangeTimer tushort ::
    Member_plain _extentChangeTimer tushort :: Member_plain _delay tushort ::
    nil)
   noattr ::
 Composite _Portamento Struct
   (Member_plain _mode tuchar :: Member_plain _cur tfloat ::
    Member_plain _speed tfloat :: Member_plain _extent tfloat :: nil)
   noattr ::
 Composite _AdsrEnvelope Struct
   (Member_plain _delay tshort :: Member_plain _arg tshort :: nil)
   noattr ::
 Composite _AdpcmLoop Struct
   (Member_plain _start tuint :: Member_plain _end tuint ::
    Member_plain _count tuint :: Member_plain _pad tuint ::
    Member_plain _state (tarray tshort 16) :: nil)
   noattr ::
 Composite _AdpcmBook Struct
   (Member_plain _order tint :: Member_plain _npredictors tint ::
    Member_plain _book (tarray tshort 1) :: nil)
   noattr ::
 Composite _AudioBankSample Struct
   (Member_plain _unused tuchar :: Member_plain _loaded tuchar ::
    Member_plain _sampleAddr (tptr tuchar) ::
    Member_plain _loop (tptr (Tstruct _AdpcmLoop noattr)) ::
    Member_plain _book (tptr (Tstruct _AdpcmBook noattr)) ::
    Member_plain _sampleSize tuint :: nil)
   noattr ::
 Composite _AudioBankSound Struct
   (Member_plain _sample (tptr (Tstruct _AudioBankSample noattr)) ::
    Member_plain _tuning tfloat :: nil)
   noattr ::
 Composite _Instrument Struct
   (Member_plain _loaded tuchar :: Member_plain _normalRangeLo tuchar ::
    Member_plain _normalRangeHi tuchar :: Member_plain _releaseRate tuchar ::
    Member_plain _envelope (tptr (Tstruct _AdsrEnvelope noattr)) ::
    Member_plain _lowNotesSound (Tstruct _AudioBankSound noattr) ::
    Member_plain _normalNotesSound (Tstruct _AudioBankSound noattr) ::
    Member_plain _highNotesSound (Tstruct _AudioBankSound noattr) :: nil)
   noattr ::
 Composite _Drum Struct
   (Member_plain _releaseRate tuchar :: Member_plain _pan tuchar ::
    Member_plain _loaded tuchar ::
    Member_plain _sound (Tstruct _AudioBankSound noattr) ::
    Member_plain _envelope (tptr (Tstruct _AdsrEnvelope noattr)) :: nil)
   noattr ::
 Composite _AudioBank Struct
   (Member_plain _drums (tptr (tptr (Tstruct _Drum noattr))) ::
    Member_plain _instruments (tarray (tptr (Tstruct _Instrument noattr)) 1) ::
    nil)
   noattr ::
 Composite _M64ScriptState Struct
   (Member_plain _pc (tptr tuchar) ::
    Member_plain _stack (tarray (tptr tuchar) 4) ::
    Member_plain _remLoopIters (tarray tuchar 4) ::
    Member_plain _depth tuchar :: nil)
   noattr ::
 Composite _SequencePlayer Struct
   (Member_bitfield _enabled I8 Unsigned
      {| attr_volatile := true; attr_alignas := None |} 1 false ::
    Member_bitfield _finished I8 Unsigned noattr 1 false ::
    Member_bitfield _muted I8 Unsigned noattr 1 false ::
    Member_bitfield _seqDmaInProgress I8 Unsigned noattr 1 false ::
    Member_bitfield _bankDmaInProgress I8 Unsigned noattr 1 false ::
    Member_plain _seqVariation tschar :: Member_plain _state tuchar ::
    Member_plain _noteAllocPolicy tuchar ::
    Member_plain _muteBehavior tuchar :: Member_plain _seqId tuchar ::
    Member_plain _defaultBank (tarray tuchar 1) ::
    Member_plain _loadingBankId tuchar ::
    Member_plain _loadingBankNumInstruments tuchar ::
    Member_plain _loadingBankNumDrums tuchar ::
    Member_plain _tempo tushort :: Member_plain _tempoAcc tushort ::
    Member_plain _fadeRemainingFrames tushort ::
    Member_plain _transposition tshort :: Member_plain _delay tushort ::
    Member_plain _seqData (tptr tuchar) :: Member_plain _fadeVolume tfloat ::
    Member_plain _fadeVelocity tfloat :: Member_plain _volume tfloat ::
    Member_plain _muteVolumeScale tfloat ::
    Member_plain _pad2 (tarray tuchar 4) ::
    Member_plain _channels
      (tarray (tptr (Tstruct _SequenceChannel noattr)) 16) ::
    Member_plain _scriptState (Tstruct _M64ScriptState noattr) ::
    Member_plain _shortNoteVelocityTable (tptr tuchar) ::
    Member_plain _shortNoteDurationTable (tptr tuchar) ::
    Member_plain _notePool (Tstruct _NotePool noattr) ::
    Member_plain _seqDmaMesgQueue (Tstruct _OSMesgQueue_s noattr) ::
    Member_plain _seqDmaMesg (tptr tvoid) ::
    Member_plain _seqDmaIoMesg (Tstruct __423 noattr) ::
    Member_plain _bankDmaMesgQueue (Tstruct _OSMesgQueue_s noattr) ::
    Member_plain _bankDmaMesg (tptr tvoid) ::
    Member_plain _bankDmaIoMesg (Tstruct __423 noattr) ::
    Member_plain _bankDmaCurrMemAddr (tptr tuchar) ::
    Member_plain _loadingBank (tptr (Tstruct _AudioBank noattr)) ::
    Member_plain _bankDmaCurrDevAddr tuint ::
    Member_plain _bankDmaRemaining tint :: nil)
   noattr ::
 Composite _AdsrSettings Struct
   (Member_plain _releaseRate tuchar :: Member_plain _sustain tushort ::
    Member_plain _envelope (tptr (Tstruct _AdsrEnvelope noattr)) :: nil)
   noattr ::
 Composite _AdsrState Struct
   (Member_plain _action tuchar :: Member_plain _state tuchar ::
    Member_plain _initial tshort :: Member_plain _target tshort ::
    Member_plain _current tshort :: Member_plain _envIndex tshort ::
    Member_plain _delay tshort :: Member_plain _sustain tshort ::
    Member_plain _fadeOutVel tshort :: Member_plain _velocity tint ::
    Member_plain _currentHiRes tint :: Member_plain _volOut (tptr tshort) ::
    Member_plain _envelope (tptr (Tstruct _AdsrEnvelope noattr)) :: nil)
   noattr ::
 Composite _NoteAttributes Struct
   (Member_plain _reverbVol tuchar :: Member_plain _freqScale tfloat ::
    Member_plain _velocity tfloat :: Member_plain _pan tfloat :: nil)
   noattr ::
 Composite _SequenceChannel Struct
   (Member_bitfield _enabled I8 Unsigned noattr 1 false ::
    Member_bitfield _finished I8 Unsigned noattr 1 false ::
    Member_bitfield _stopScript I8 Unsigned noattr 1 false ::
    Member_bitfield _stopSomething2 I8 Unsigned noattr 1 false ::
    Member_bitfield _hasInstrument I8 Unsigned noattr 1 false ::
    Member_bitfield _stereoHeadsetEffects I8 Unsigned noattr 1 false ::
    Member_bitfield _largeNotes I8 Unsigned noattr 1 false ::
    Member_bitfield _unused I8 Unsigned noattr 1 false ::
    Member_plain _noteAllocPolicy tuchar ::
    Member_plain _muteBehavior tuchar :: Member_plain _reverbVol tuchar ::
    Member_plain _notePriority tuchar :: Member_plain _bankId tuchar ::
    Member_plain _updatesPerFrameUnused tuchar ::
    Member_plain _vibratoRateStart tushort ::
    Member_plain _vibratoExtentStart tushort ::
    Member_plain _vibratoRateTarget tushort ::
    Member_plain _vibratoExtentTarget tushort ::
    Member_plain _vibratoRateChangeDelay tushort ::
    Member_plain _vibratoExtentChangeDelay tushort ::
    Member_plain _vibratoDelay tushort :: Member_plain _delay tushort ::
    Member_plain _instOrWave tshort :: Member_plain _transposition tshort ::
    Member_plain _volumeScale tfloat :: Member_plain _volume tfloat ::
    Member_plain _pan tfloat :: Member_plain _panChannelWeight tfloat ::
    Member_plain _freqScale tfloat ::
    Member_plain _dynTable (tptr (tarray (tarray tuchar 2) 0)) ::
    Member_plain _noteUnused (tptr (Tstruct _Note noattr)) ::
    Member_plain _layerUnused (tptr (Tstruct _SequenceChannelLayer noattr)) ::
    Member_plain _instrument (tptr (Tstruct _Instrument noattr)) ::
    Member_plain _seqPlayer (tptr (Tstruct _SequencePlayer noattr)) ::
    Member_plain _layers
      (tarray (tptr (Tstruct _SequenceChannelLayer noattr)) 4) ::
    Member_plain _soundScriptIO (tarray tschar 8) ::
    Member_plain _scriptState (Tstruct _M64ScriptState noattr) ::
    Member_plain _adsr (Tstruct _AdsrSettings noattr) ::
    Member_plain _notePool (Tstruct _NotePool noattr) :: nil)
   noattr ::
 Composite _SequenceChannelLayer Struct
   (Member_bitfield _enabled I8 Unsigned noattr 1 false ::
    Member_bitfield _finished I8 Unsigned noattr 1 false ::
    Member_bitfield _stopSomething I8 Unsigned noattr 1 false ::
    Member_bitfield _continuousNotes I8 Unsigned noattr 1 false ::
    Member_plain _status tuchar :: Member_plain _noteDuration tuchar ::
    Member_plain _portamentoTargetNote tuchar ::
    Member_plain _portamento (Tstruct _Portamento noattr) ::
    Member_plain _adsr (Tstruct _AdsrSettings noattr) ::
    Member_plain _portamentoTime tushort ::
    Member_plain _transposition tshort :: Member_plain _freqScale tfloat ::
    Member_plain _velocitySquare tfloat :: Member_plain _pan tfloat ::
    Member_plain _noteVelocity tfloat :: Member_plain _notePan tfloat ::
    Member_plain _noteFreqScale tfloat ::
    Member_plain _shortNoteDefaultPlayPercentage tshort ::
    Member_plain _playPercentage tshort :: Member_plain _delay tshort ::
    Member_plain _duration tshort :: Member_plain _delayUnused tshort ::
    Member_plain _note (tptr (Tstruct _Note noattr)) ::
    Member_plain _instrument (tptr (Tstruct _Instrument noattr)) ::
    Member_plain _sound (tptr (Tstruct _AudioBankSound noattr)) ::
    Member_plain _seqChannel (tptr (Tstruct _SequenceChannel noattr)) ::
    Member_plain _scriptState (Tstruct _M64ScriptState noattr) ::
    Member_plain _listItem (Tstruct _AudioListItem noattr) :: nil)
   noattr ::
 Composite _Note Struct
   (Member_bitfield _enabled I8 Unsigned noattr 1 false ::
    Member_bitfield _needsInit I8 Unsigned noattr 1 false ::
    Member_bitfield _restart I8 Unsigned noattr 1 false ::
    Member_bitfield _finished I8 Unsigned noattr 1 false ::
    Member_bitfield _envMixerNeedsInit I8 Unsigned noattr 1 false ::
    Member_bitfield _stereoStrongRight I8 Unsigned noattr 1 false ::
    Member_bitfield _stereoStrongLeft I8 Unsigned noattr 1 false ::
    Member_bitfield _stereoHeadsetEffects I8 Unsigned noattr 1 false ::
    Member_plain _usesHeadsetPanEffects tuchar ::
    Member_plain _unk2 tuchar :: Member_plain _sampleDmaIndex tuchar ::
    Member_plain _priority tuchar :: Member_plain _sampleCount tuchar ::
    Member_plain _instOrWave tuchar :: Member_plain _bankId tuchar ::
    Member_plain _adsrVolScale tshort ::
    Member_plain _pad1 (tarray tuchar 2) ::
    Member_plain _headsetPanRight tushort ::
    Member_plain _headsetPanLeft tushort ::
    Member_plain _prevHeadsetPanRight tushort ::
    Member_plain _prevHeadsetPanLeft tushort ::
    Member_plain _samplePosInt tint ::
    Member_plain _portamentoFreqScale tfloat ::
    Member_plain _vibratoFreqScale tfloat ::
    Member_plain _samplePosFrac tushort ::
    Member_plain _sound (tptr (Tstruct _AudioBankSound noattr)) ::
    Member_plain _prevParentLayer
      (tptr (Tstruct _SequenceChannelLayer noattr)) ::
    Member_plain _parentLayer (tptr (Tstruct _SequenceChannelLayer noattr)) ::
    Member_plain _wantedParentLayer
      (tptr (Tstruct _SequenceChannelLayer noattr)) ::
    Member_plain _synthesisBuffers
      (tptr (Tstruct _NoteSynthesisBuffers noattr)) ::
    Member_plain _frequency tfloat :: Member_plain _targetVolLeft tushort ::
    Member_plain _targetVolRight tushort :: Member_plain _reverbVol tuchar ::
    Member_plain _unused1 tuchar ::
    Member_plain _attributes (Tstruct _NoteAttributes noattr) ::
    Member_plain _adsr (Tstruct _AdsrState noattr) ::
    Member_plain _portamento (Tstruct _Portamento noattr) ::
    Member_plain _vibratoState (Tstruct _VibratoState noattr) ::
    Member_plain _curVolLeft tshort :: Member_plain _curVolRight tshort ::
    Member_plain _reverbVolShifted tshort :: Member_plain _unused2 tshort ::
    Member_plain _listItem (Tstruct _AudioListItem noattr) ::
    Member_plain _pad2 (tarray tuchar 12) :: nil)
   noattr ::
 Composite _NoteSynthesisBuffers Struct
   (Member_plain _adpcmdecState (tarray tshort 16) ::
    Member_plain _finalResampleState (tarray tshort 16) ::
    Member_plain _mixEnvelopeState (tarray tshort 40) ::
    Member_plain _panResampleState (tarray tshort 16) ::
    Member_plain _panSamplesBuffer (tarray tshort 32) ::
    Member_plain _dummyResampleState (tarray tshort 16) ::
    Member_plain _samples (tarray tshort 64) :: nil)
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
 Composite _GraphNodeRoot Struct
   (Member_plain _node (Tstruct _GraphNode noattr) ::
    Member_plain _areaIndex tuchar :: Member_plain _unk15 tschar ::
    Member_plain _x tshort :: Member_plain _y tshort ::
    Member_plain _width tshort :: Member_plain _height tshort ::
    Member_plain _numViews tshort ::
    Member_plain _views (tptr (tptr (Tstruct _GraphNode noattr))) :: nil)
   noattr ::
 Composite _PlayerCameraState Struct
   (Member_plain _action tuint :: Member_plain _pos (tarray tfloat 3) ::
    Member_plain _faceAngle (tarray tshort 3) ::
    Member_plain _headRotation (tarray tshort 3) ::
    Member_plain _unused tshort :: Member_plain _cameraEvent tshort ::
    Member_plain _usedObj (tptr (Tstruct _Object noattr)) :: nil)
   noattr ::
 Composite _Camera Struct
   (Member_plain _mode tuchar :: Member_plain _defMode tuchar ::
    Member_plain _yaw tshort :: Member_plain _focus (tarray tfloat 3) ::
    Member_plain _pos (tarray tfloat 3) ::
    Member_plain _unusedVec1 (tarray tfloat 3) ::
    Member_plain _areaCenX tfloat :: Member_plain _areaCenZ tfloat ::
    Member_plain _cutscene tuchar ::
    Member_plain _filler1 (tarray tuchar 8) ::
    Member_plain _nextYaw tshort ::
    Member_plain _filler2 (tarray tuchar 40) ::
    Member_plain _doorStatus tuchar :: Member_plain _areaCenY tfloat :: nil)
   noattr ::
 Composite _WarpNode Struct
   (Member_plain _id tuchar :: Member_plain _destLevel tuchar ::
    Member_plain _destArea tuchar :: Member_plain _destNode tuchar :: nil)
   noattr ::
 Composite _ObjectWarpNode Struct
   (Member_plain _node (Tstruct _WarpNode noattr) ::
    Member_plain _object (tptr (Tstruct _Object noattr)) ::
    Member_plain _next (tptr (Tstruct _ObjectWarpNode noattr)) :: nil)
   noattr ::
 Composite _InstantWarp Struct
   (Member_plain _id tuchar :: Member_plain _area tuchar ::
    Member_plain _displacement (tarray tshort 3) :: nil)
   noattr ::
 Composite _SpawnInfo Struct
   (Member_plain _startPos (tarray tshort 3) ::
    Member_plain _startAngle (tarray tshort 3) ::
    Member_plain _areaIndex tschar :: Member_plain _activeAreaIndex tschar ::
    Member_plain _behaviorArg tuint ::
    Member_plain _behaviorScript (tptr tvoid) ::
    Member_plain _model (tptr (Tstruct _GraphNode noattr)) ::
    Member_plain _next (tptr (Tstruct _SpawnInfo noattr)) :: nil)
   noattr ::
 Composite _UnusedArea28 Struct
   (Member_plain _unk00 tshort :: Member_plain _unk02 tshort ::
    Member_plain _unk04 tshort :: Member_plain _unk06 tshort ::
    Member_plain _unk08 tshort :: nil)
   noattr ::
 Composite _Whirlpool Struct
   (Member_plain _pos (tarray tshort 3) :: Member_plain _strength tshort ::
    nil)
   noattr ::
 Composite _Area Struct
   (Member_plain _index tschar :: Member_plain _flags tschar ::
    Member_plain _terrainType tushort ::
    Member_plain _unk04 (tptr (Tstruct _GraphNodeRoot noattr)) ::
    Member_plain _terrainData (tptr tshort) ::
    Member_plain _surfaceRooms (tptr tschar) ::
    Member_plain _macroObjects (tptr tshort) ::
    Member_plain _warpNodes (tptr (Tstruct _ObjectWarpNode noattr)) ::
    Member_plain _paintingWarpNodes (tptr (Tstruct _WarpNode noattr)) ::
    Member_plain _instantWarps (tptr (Tstruct _InstantWarp noattr)) ::
    Member_plain _objectSpawnInfos (tptr (Tstruct _SpawnInfo noattr)) ::
    Member_plain _camera (tptr (Tstruct _Camera noattr)) ::
    Member_plain _unused (tptr (Tstruct _UnusedArea28 noattr)) ::
    Member_plain _whirlpools (tarray (tptr (Tstruct _Whirlpool noattr)) 2) ::
    Member_plain _dialog (tarray tuchar 2) ::
    Member_plain _musicParam tushort :: Member_plain _musicParam2 tushort ::
    nil)
   noattr ::
 Composite _Sound Struct
   (Member_plain _soundBits tint :: Member_plain _position (tptr tfloat) ::
    nil)
   noattr ::
 Composite _ChannelVolumeScaleFade Struct
   (Member_plain _velocity tfloat :: Member_plain _target tuchar ::
    Member_plain _current tfloat :: Member_plain _remainingFrames tushort ::
    nil)
   noattr ::
 Composite _SoundCharacteristics Struct
   (Member_plain _x (tptr tfloat) :: Member_plain _y (tptr tfloat) ::
    Member_plain _z (tptr tfloat) :: Member_plain _distance tfloat ::
    Member_plain _priority tuint :: Member_plain _soundBits tuint ::
    Member_plain _soundStatus tuchar :: Member_plain _freshness tuchar ::
    Member_plain _prev tuchar :: Member_plain _next tuchar :: nil)
   noattr ::
 Composite _SequenceQueueItem Struct
   (Member_plain _seqId tuchar :: Member_plain _priority tuchar :: nil)
   noattr ::
 Composite _MusicDynamic Struct
   (Member_plain _bits1 tshort :: Member_plain _volScale1 tushort ::
    Member_plain _dur1 tshort :: Member_plain _bits2 tshort ::
    Member_plain _volScale2 tushort :: Member_plain _dur2 tshort :: nil)
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_rspF3DBootStart, Gvar v_rspF3DBootStart) ::
 (_rspF3DBootEnd, Gvar v_rspF3DBootEnd) ::
 (_rspAspMainStart, Gvar v_rspAspMainStart) ::
 (_rspAspMainDataStart, Gvar v_rspAspMainDataStart) ::
 (_rspAspMainDataEnd, Gvar v_rspAspMainDataEnd) ::
 (_osWritebackDCacheAll,
   Gfun(External (EF_external "osWritebackDCacheAll"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_osAiGetLength,
   Gfun(External (EF_external "osAiGetLength"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_osAiSetNextBuffer,
   Gfun(External (EF_external "osAiSetNextBuffer"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tvoid) :: tuint :: nil) tint
     cc_default)) ::
 (_audio_reset_session,
   Gfun(External (EF_external "audio_reset_session"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _AudioSessionSettings noattr)) :: nil) tvoid
     cc_default)) :: (_gSequencePlayers, Gvar v_gSequencePlayers) ::
 (_gSequenceChannelNone, Gvar v_gSequenceChannelNone) ::
 (_gSamplesPerFrameTarget, Gvar v_gSamplesPerFrameTarget) ::
 (_gMinAiBufferLength, Gvar v_gMinAiBufferLength) ::
 (_gSoundMode, Gvar v_gSoundMode) ::
 (_decrease_sample_dma_ttls,
   Gfun(External (EF_external "decrease_sample_dma_ttls"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_preload_sequence,
   Gfun(External (EF_external "preload_sequence"
                   (mksignature (AST.Xint :: AST.Xint8unsigned :: nil)
                     AST.Xvoid cc_default)) (tuint :: tuchar :: nil) tvoid
     cc_default)) ::
 (_load_sequence,
   Gfun(External (EF_external "load_sequence"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default)) (tuint :: tuint :: tint :: nil)
     tvoid cc_default)) ::
 (_gAudioSessionPresets, Gvar v_gAudioSessionPresets) ::
 (_gAudioLoadLock, Gvar v_gAudioLoadLock) ::
 (_gAudioFrameCount, Gvar v_gAudioFrameCount) ::
 (_gCurrAudioFrameDmaCount, Gvar v_gCurrAudioFrameDmaCount) ::
 (_gAudioTaskIndex, Gvar v_gAudioTaskIndex) ::
 (_gCurrAiBufferIndex, Gvar v_gCurrAiBufferIndex) ::
 (_gAudioCmdBuffers, Gvar v_gAudioCmdBuffers) ::
 (_gAudioCmd, Gvar v_gAudioCmd) :: (_gAudioTask, Gvar v_gAudioTask) ::
 (_gAudioTasks, Gvar v_gAudioTasks) :: (_gAiBuffers, Gvar v_gAiBuffers) ::
 (_gAiBufferLengths, Gvar v_gAiBufferLengths) ::
 (_sequence_player_disable,
   Gfun(External (EF_external "sequence_player_disable"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _SequencePlayer noattr)) :: nil) tvoid cc_default)) ::
 (_gAudioRandom, Gvar v_gAudioRandom) ::
 (_gAudioSPTaskYieldBuffer, Gvar v_gAudioSPTaskYieldBuffer) ::
 (_synthesis_execute,
   Gfun(External (EF_external "synthesis_execute"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xptr cc_default))
     ((tptr tulong) :: (tptr tint) :: (tptr tshort) :: tint :: nil)
     (tptr tulong) cc_default)) :: (_gMarioStates, Gvar v_gMarioStates) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_gMarioCurrentRoom, Gvar v_gMarioCurrentRoom) ::
 (_gAudioErrorFlags, Gvar v_gAudioErrorFlags) ::
 (_sGameLoopTicked, Gvar v_sGameLoopTicked) ::
 (_sDialogSpeaker, Gvar v_sDialogSpeaker) ::
 (_sDialogSpeakerVoice, Gvar v_sDialogSpeakerVoice) ::
 (_sNumProcessedSoundRequests, Gvar v_sNumProcessedSoundRequests) ::
 (_sSoundRequestCount, Gvar v_sSoundRequestCount) ::
 (_sDynBBH, Gvar v_sDynBBH) :: (_sDynDDD, Gvar v_sDynDDD) ::
 (_sDynJRB, Gvar v_sDynJRB) :: (_sDynWDW, Gvar v_sDynWDW) ::
 (_sDynHMC, Gvar v_sDynHMC) :: (_sDynUnk38, Gvar v_sDynUnk38) ::
 (_sDynNone, Gvar v_sDynNone) ::
 (_sCurrentMusicDynamic, Gvar v_sCurrentMusicDynamic) ::
 (_sBackgroundMusicForDynamics, Gvar v_sBackgroundMusicForDynamics) ::
 (_sLevelDynamics, Gvar v_sLevelDynamics) ::
 (_sMusicDynamics, Gvar v_sMusicDynamics) ::
 (_sLevelAreaReverbs, Gvar v_sLevelAreaReverbs) ::
 (_sLevelAcousticReaches, Gvar v_sLevelAcousticReaches) ::
 (_sBackgroundMusicDefaultVolume, Gvar v_sBackgroundMusicDefaultVolume) ::
 (_sCurrentBackgroundMusicSeqId, Gvar v_sCurrentBackgroundMusicSeqId) ::
 (_sMusicDynamicDelay, Gvar v_sMusicDynamicDelay) ::
 (_sSoundBankUsedListBack, Gvar v_sSoundBankUsedListBack) ::
 (_sSoundBankFreeListFront, Gvar v_sSoundBankFreeListFront) ::
 (_sNumSoundsInBank, Gvar v_sNumSoundsInBank) ::
 (_sMaxChannelsForSoundBank, Gvar v_sMaxChannelsForSoundBank) ::
 (_sNumSoundsPerBank, Gvar v_sNumSoundsPerBank) ::
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_sUnusedSoundArgs, Gvar v_sUnusedSoundArgs) ::
 (_sSoundBankDisabled, Gvar v_sSoundBankDisabled) ::
 (_D_80332108, Gvar v_D_80332108) ::
 (_sHasStartedFadeOut, Gvar v_sHasStartedFadeOut) ::
 (_sSoundBanksThatLowerBackgroundMusic, Gvar v_sSoundBanksThatLowerBackgroundMusic) ::
 (_sUnused80332114, Gvar v_sUnused80332114) ::
 (_sUnused80332118, Gvar v_sUnused80332118) ::
 (_sBackgroundMusicMaxTargetVolume, Gvar v_sBackgroundMusicMaxTargetVolume) ::
 (_D_80332120, Gvar v_D_80332120) :: (_D_80332124, Gvar v_D_80332124) ::
 (_sBackgroundMusicQueueSize, Gvar v_sBackgroundMusicQueueSize) ::
 (_gCurrAiBuffer, Gvar v_gCurrAiBuffer) ::
 (_sSoundRequests, Gvar v_sSoundRequests) ::
 (_D_80360928, Gvar v_D_80360928) ::
 (_sUsedChannelsForSoundBank, Gvar v_sUsedChannelsForSoundBank) ::
 (_sCurrentSound, Gvar v_sCurrentSound) ::
 (_sSoundBanks, Gvar v_sSoundBanks) ::
 (_sSoundMovingSpeed, Gvar v_sSoundMovingSpeed) ::
 (_sBackgroundMusicTargetVolume, Gvar v_sBackgroundMusicTargetVolume) ::
 (_sLowerBackgroundMusicVolume, Gvar v_sLowerBackgroundMusicVolume) ::
 (_sBackgroundMusicQueue, Gvar v_sBackgroundMusicQueue) ::
 (_seq_player_fade_to_zero_volume, Gfun(Internal f_seq_player_fade_to_zero_volume)) ::
 (_func_8031D690, Gfun(Internal f_func_8031D690)) ::
 (_seq_player_fade_to_percentage_of_volume, Gfun(Internal f_seq_player_fade_to_percentage_of_volume)) ::
 (_seq_player_fade_to_normal_volume, Gfun(Internal f_seq_player_fade_to_normal_volume)) ::
 (_seq_player_fade_to_target_volume, Gfun(Internal f_seq_player_fade_to_target_volume)) ::
 (_create_next_audio_frame_task, Gfun(Internal f_create_next_audio_frame_task)) ::
 (_play_sound, Gfun(Internal f_play_sound)) ::
 (_process_sound_request, Gfun(Internal f_process_sound_request)) ::
 (_process_all_sound_requests, Gfun(Internal f_process_all_sound_requests)) ::
 (_delete_sound_from_bank, Gfun(Internal f_delete_sound_from_bank)) ::
 (_update_background_music_after_sound, Gfun(Internal f_update_background_music_after_sound)) ::
 (_select_current_sounds, Gfun(Internal f_select_current_sounds)) ::
 (_get_sound_pan, Gfun(Internal f_get_sound_pan)) ::
 (_get_sound_volume, Gfun(Internal f_get_sound_volume)) ::
 (_get_sound_freq_scale, Gfun(Internal f_get_sound_freq_scale)) ::
 (_get_sound_reverb, Gfun(Internal f_get_sound_reverb)) ::
 (_noop_8031EEC8, Gfun(Internal f_noop_8031EEC8)) ::
 (_audio_signal_game_loop_tick, Gfun(Internal f_audio_signal_game_loop_tick)) ::
 (_update_game_sound, Gfun(Internal f_update_game_sound)) ::
 (_seq_player_play_sequence, Gfun(Internal f_seq_player_play_sequence)) ::
 (_seq_player_fade_out, Gfun(Internal f_seq_player_fade_out)) ::
 (_fade_volume_scale, Gfun(Internal f_fade_volume_scale)) ::
 (_fade_channel_volume_scale, Gfun(Internal f_fade_channel_volume_scale)) ::
 (_func_8031F96C, Gfun(Internal f_func_8031F96C)) ::
 (_process_level_music_dynamics, Gfun(Internal f_process_level_music_dynamics)) ::
 (_unused_8031FED0, Gfun(Internal f_unused_8031FED0)) ::
 (_seq_player_lower_volume, Gfun(Internal f_seq_player_lower_volume)) ::
 (_seq_player_unlower_volume, Gfun(Internal f_seq_player_unlower_volume)) ::
 (_begin_background_music_fade, Gfun(Internal f_begin_background_music_fade)) ::
 (_set_audio_muted, Gfun(Internal f_set_audio_muted)) ::
 (_sound_init, Gfun(Internal f_sound_init)) ::
 (_get_currently_playing_sound, Gfun(Internal f_get_currently_playing_sound)) ::
 (_stop_sound, Gfun(Internal f_stop_sound)) ::
 (_stop_sounds_from_source, Gfun(Internal f_stop_sounds_from_source)) ::
 (_stop_sounds_in_bank, Gfun(Internal f_stop_sounds_in_bank)) ::
 (_stop_sounds_in_continuous_banks, Gfun(Internal f_stop_sounds_in_continuous_banks)) ::
 (_sound_banks_disable, Gfun(Internal f_sound_banks_disable)) ::
 (_disable_all_sequence_players, Gfun(Internal f_disable_all_sequence_players)) ::
 (_sound_banks_enable, Gfun(Internal f_sound_banks_enable)) ::
 (_unused_803209D8, Gfun(Internal f_unused_803209D8)) ::
 (_set_sound_moving_speed, Gfun(Internal f_set_sound_moving_speed)) ::
 (_play_dialog_sound, Gfun(Internal f_play_dialog_sound)) ::
 (_play_music, Gfun(Internal f_play_music)) ::
 (_stop_background_music, Gfun(Internal f_stop_background_music)) ::
 (_fadeout_background_music, Gfun(Internal f_fadeout_background_music)) ::
 (_drop_queued_background_music, Gfun(Internal f_drop_queued_background_music)) ::
 (_get_current_background_music, Gfun(Internal f_get_current_background_music)) ::
 (_func_80320ED8, Gfun(Internal f_func_80320ED8)) ::
 (_play_secondary_music, Gfun(Internal f_play_secondary_music)) ::
 (_func_80321080, Gfun(Internal f_func_80321080)) ::
 (_func_803210D4, Gfun(Internal f_func_803210D4)) ::
 (_play_course_clear, Gfun(Internal f_play_course_clear)) ::
 (_play_peachs_jingle, Gfun(Internal f_play_peachs_jingle)) ::
 (_play_puzzle_jingle, Gfun(Internal f_play_puzzle_jingle)) ::
 (_play_star_fanfare, Gfun(Internal f_play_star_fanfare)) ::
 (_play_power_star_jingle, Gfun(Internal f_play_power_star_jingle)) ::
 (_play_race_fanfare, Gfun(Internal f_play_race_fanfare)) ::
 (_play_toads_jingle, Gfun(Internal f_play_toads_jingle)) ::
 (_sound_reset, Gfun(Internal f_sound_reset)) ::
 (_audio_set_sound_mode, Gfun(Internal f_audio_set_sound_mode)) ::
 (_unused_80321460, Gfun(Internal f_unused_80321460)) ::
 (_unused_80321474, Gfun(Internal f_unused_80321474)) :: nil).

Definition public_idents : list ident :=
(_unused_80321474 :: _unused_80321460 :: _audio_set_sound_mode ::
 _sound_reset :: _play_toads_jingle :: _play_race_fanfare ::
 _play_power_star_jingle :: _play_star_fanfare :: _play_puzzle_jingle ::
 _play_peachs_jingle :: _play_course_clear :: _func_803210D4 ::
 _func_80321080 :: _play_secondary_music :: _func_80320ED8 ::
 _get_current_background_music :: _drop_queued_background_music ::
 _fadeout_background_music :: _stop_background_music :: _play_music ::
 _play_dialog_sound :: _set_sound_moving_speed :: _unused_803209D8 ::
 _sound_banks_enable :: _sound_banks_disable ::
 _stop_sounds_in_continuous_banks :: _stop_sounds_from_source ::
 _stop_sound :: _get_currently_playing_sound :: _sound_init ::
 _set_audio_muted :: _seq_player_unlower_volume ::
 _seq_player_lower_volume :: _unused_8031FED0 ::
 _process_level_music_dynamics :: _fade_volume_scale ::
 _seq_player_fade_out :: _audio_signal_game_loop_tick :: _play_sound ::
 _create_next_audio_frame_task :: _sBackgroundMusicQueue ::
 _sBackgroundMusicTargetVolume :: _sSoundMovingSpeed :: _sSoundBanks ::
 _sCurrentSound :: _sUsedChannelsForSoundBank :: _D_80360928 ::
 _sSoundRequests :: _gCurrAiBuffer :: _sBackgroundMusicQueueSize ::
 _D_80332124 :: _D_80332120 :: _sBackgroundMusicMaxTargetVolume ::
 _sUnused80332118 :: _sUnused80332114 ::
 _sSoundBanksThatLowerBackgroundMusic :: _sHasStartedFadeOut ::
 _D_80332108 :: _sSoundBankDisabled :: _sUnusedSoundArgs ::
 _gGlobalSoundSource :: _sNumSoundsPerBank :: _sMaxChannelsForSoundBank ::
 _sNumSoundsInBank :: _sSoundBankFreeListFront :: _sSoundBankUsedListBack ::
 _sMusicDynamicDelay :: _sCurrentBackgroundMusicSeqId ::
 _sBackgroundMusicDefaultVolume :: _sLevelAcousticReaches ::
 _sLevelAreaReverbs :: _sMusicDynamics :: _sLevelDynamics ::
 _sBackgroundMusicForDynamics :: _sCurrentMusicDynamic :: _sDynNone ::
 _sDynUnk38 :: _sDynHMC :: _sDynWDW :: _sDynJRB :: _sDynDDD :: _sDynBBH ::
 _sSoundRequestCount :: _sNumProcessedSoundRequests ::
 _sDialogSpeakerVoice :: _sDialogSpeaker :: _sGameLoopTicked ::
 _gAudioErrorFlags :: _gMarioCurrentRoom :: _gCurrLevelNum ::
 _gCurrAreaIndex :: _gMarioStates :: _synthesis_execute ::
 _gAudioSPTaskYieldBuffer :: _gAudioRandom :: _sequence_player_disable ::
 _gAiBufferLengths :: _gAiBuffers :: _gAudioTasks :: _gAudioTask ::
 _gAudioCmd :: _gAudioCmdBuffers :: _gCurrAiBufferIndex ::
 _gAudioTaskIndex :: _gCurrAudioFrameDmaCount :: _gAudioFrameCount ::
 _gAudioLoadLock :: _gAudioSessionPresets :: _load_sequence ::
 _preload_sequence :: _decrease_sample_dma_ttls :: _gSoundMode ::
 _gMinAiBufferLength :: _gSamplesPerFrameTarget :: _gSequenceChannelNone ::
 _gSequencePlayers :: _audio_reset_session :: _osAiSetNextBuffer ::
 _osAiGetLength :: _osWritebackDCacheAll :: _rspAspMainDataEnd ::
 _rspAspMainDataStart :: _rspAspMainStart :: _rspF3DBootEnd ::
 _rspF3DBootStart :: _sqrtf :: ___builtin_debug ::
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
