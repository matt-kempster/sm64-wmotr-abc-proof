(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/sound_init.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -include pipeline/proof_n64.h (+ __stringlit_ -> __stringlit_sound_init_)
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
  Definition source_file := "vendor/sm64/src/game/sound_init.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _CreditsEntry : ident := $"CreditsEntry".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _OSMesgQueue_s : ident := $"OSMesgQueue_s".
Definition _OSThread_s : ident := $"OSThread_s".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _Painting : ident := $"Painting".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SPTask : ident := $"SPTask".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _VblankHandler : ident := $"VblankHandler".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __248 : ident := $"_anon_07a69785bc06".
Definition __249 : ident := $"_anon_a9a983b34860".
Definition __251 : ident := $"_anon_4f5eb5534ceb".
Definition __253 : ident := $"_anon_f4fa7cbf403d".
Definition __317 : ident := $"_anon_ae165a813d32".
Definition __319 : ident := $"_anon_e4bae3b10b78".
Definition __356 : ident := $"_anon_eb33296dc4e6".
Definition __358 : ident := $"_anon_e6e5dd5b5d1f".
Definition __469 : ident := $"_anon_492449ad5917".
Definition __510 : ident := $"_anon_b68c7cd607b8".
Definition __512 : ident := $"_anon_cc23475d879a".
Definition __514 : ident := $"_anon_582ea1ea7a16".
Definition __516 : ident := $"_anon_1f056269c846".
Definition __518 : ident := $"_anon_e728cafb3139_0".
Definition __520 : ident := $"_anon_e728cafb3139_1".
Definition __522 : ident := $"_anon_082533b0d3da".
Definition __524 : ident := $"_anon_326d1d817e71".
Definition __526 : ident := $"_anon_93f6c6d42751".
Definition __528 : ident := $"_anon_7fe8a69a4b23".
Definition __530 : ident := $"_anon_4f0efebcc12b".
Definition __532 : ident := $"_anon_aa3f148f9bf1".
Definition __534 : ident := $"_anon_336f2d3e0b53".
Definition __536 : ident := $"_anon_5b5ce0cbc558".
Definition __538 : ident := $"_anon_f17a035c1639".
Definition __547 : ident := $"_anon_50f496f0a47e".
Definition __549 : ident := $"_anon_56e646c222b2".
Definition __764 : ident := $"_anon_2a845cdd6eb9".
Definition __769 : ident := $"_anon_7dce1c6c6ad3".
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
Definition _a : ident := $"a".
Definition _a0 : ident := $"a0".
Definition _a1 : ident := $"a1".
Definition _a2 : ident := $"a2".
Definition _a3 : ident := $"a3".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _addr : ident := $"addr".
Definition _alpha : ident := $"alpha".
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
Definition _audio_game_loop_tick : ident := $"audio_game_loop_tick".
Definition _audio_init : ident := $"audio_init".
Definition _audio_set_sound_mode : ident := $"audio_set_sound_mode".
Definition _audio_signal_game_loop_tick : ident := $"audio_signal_game_loop_tick".
Definition _b : ident := $"b".
Definition _badvaddr : ident := $"badvaddr".
Definition _base : ident := $"base".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
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
Definition _children : ident := $"children".
Definition _cmd : ident := $"cmd".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _color : ident := $"color".
Definition _context : ident := $"context".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _create_next_audio_frame_task : ident := $"create_next_audio_frame_task".
Definition _cs : ident := $"cs".
Definition _ct : ident := $"ct".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currFloor : ident := $"currFloor".
Definition _currRippleMag : ident := $"currRippleMag".
Definition _currRippleRate : ident := $"currRippleRate".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _data : ident := $"data".
Definition _data_ptr : ident := $"data_ptr".
Definition _data_size : ident := $"data_size".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _disable_background_sound : ident := $"disable_background_sound".
Definition _dispatch_audio_sptask : ident := $"dispatch_audio_sptask".
Definition _dispersionFactor : ident := $"dispersionFactor".
Definition _displacement : ident := $"displacement".
Definition _dma : ident := $"dma".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dram : ident := $"dram".
Definition _dram_stack : ident := $"dram_stack".
Definition _dram_stack_size : ident := $"dram_stack_size".
Definition _enable_background_sound : ident := $"enable_background_sound".
Definition _entryDispersionFactor : ident := $"entryDispersionFactor".
Definition _entryRippleDecay : ident := $"entryRippleDecay".
Definition _entryRippleMag : ident := $"entryRippleMag".
Definition _entryRippleRate : ident := $"entryRippleRate".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _f : ident := $"f".
Definition _f_even : ident := $"f_even".
Definition _f_odd : ident := $"f_odd".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeOutTime : ident := $"fadeOutTime".
Definition _fadeTimer : ident := $"fadeTimer".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fadeout_background_music : ident := $"fadeout_background_music".
Definition _fadeout_cap_music : ident := $"fadeout_cap_music".
Definition _fadeout_level_music : ident := $"fadeout_level_music".
Definition _fadeout_music : ident := $"fadeout_music".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _fillrect : ident := $"fillrect".
Definition _first : ident := $"first".
Definition _flag : ident := $"flag".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorEntered : ident := $"floorEntered".
Definition _floorHeight : ident := $"floorHeight".
Definition _fmt : ident := $"fmt".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _force_structure_alignment : ident := $"force_structure_alignment".
Definition _forwardVel : ident := $"forwardVel".
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
Definition _fullqueue : ident := $"fullqueue".
Definition _func_80321080 : ident := $"func_80321080".
Definition _func_803210D4 : ident := $"func_803210D4".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrCreditsEntry : ident := $"gCurrCreditsEntry".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gMarioState : ident := $"gMarioState".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gNeverEnteredCastle : ident := $"gNeverEnteredCastle".
Definition _gResetTimer : ident := $"gResetTimer".
Definition _gRipplingPainting : ident := $"gRipplingPainting".
Definition _gVec3fZero : ident := $"gVec3fZero".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _gp : ident := $"gp".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heldObj : ident := $"heldObj".
Definition _heldObjLastPosition : ident := $"heldObjLastPosition".
Definition _hi : ident := $"hi".
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _id : ident := $"id".
Definition _imageCount : ident := $"imageCount".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _lastFloor : ident := $"lastFloor".
Definition _len : ident := $"len".
Definition _length : ident := $"length".
Definition _levelNum : ident := $"levelNum".
Definition _line : ident := $"line".
Definition _lo : ident := $"lo".
Definition _loadtile : ident := $"loadtile".
Definition _loadtlut : ident := $"loadtlut".
Definition _lodscale : ident := $"lodscale".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _lower_background_noise : ident := $"lower_background_noise".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioAngle : ident := $"marioAngle".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioIsUnder : ident := $"marioIsUnder".
Definition _marioObj : ident := $"marioObj".
Definition _marioPos : ident := $"marioPos".
Definition _marioWasUnder : ident := $"marioWasUnder".
Definition _marioWentUnder : ident := $"marioWentUnder".
Definition _masks : ident := $"masks".
Definition _maskt : ident := $"maskt".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _ms : ident := $"ms".
Definition _msg : ident := $"msg".
Definition _msgCount : ident := $"msgCount".
Definition _msgqueue : ident := $"msgqueue".
Definition _mt : ident := $"mt".
Definition _mtqueue : ident := $"mtqueue".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _muxs0 : ident := $"muxs0".
Definition _muxs1 : ident := $"muxs1".
Definition _mw_index : ident := $"mw_index".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _normalDisplayList : ident := $"normalDisplayList".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _number : ident := $"number".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _on : ident := $"on".
Definition _originOffset : ident := $"originOffset".
Definition _osCreateMesgQueue : ident := $"osCreateMesgQueue".
Definition _osRecvMesg : ident := $"osRecvMesg".
Definition _output_buff : ident := $"output_buff".
Definition _output_buff_size : ident := $"output_buff_size".
Definition _pad : ident := $"pad".
Definition _pad0 : ident := $"pad0".
Definition _pad1 : ident := $"pad1".
Definition _pad2 : ident := $"pad2".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _palette : ident := $"palette".
Definition _par : ident := $"par".
Definition _param : ident := $"param".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _passiveDispersionFactor : ident := $"passiveDispersionFactor".
Definition _passiveRippleDecay : ident := $"passiveRippleDecay".
Definition _passiveRippleMag : ident := $"passiveRippleMag".
Definition _passiveRippleRate : ident := $"passiveRippleRate".
Definition _pc : ident := $"pc".
Definition _peakHeight : ident := $"peakHeight".
Definition _perspnorm : ident := $"perspnorm".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_cap_music : ident := $"play_cap_music".
Definition _play_cutscene_music : ident := $"play_cutscene_music".
Definition _play_infinite_stairs_music : ident := $"play_infinite_stairs_music".
Definition _play_menu_sounds : ident := $"play_menu_sounds".
Definition _play_menu_sounds_extra : ident := $"play_menu_sounds_extra".
Definition _play_music : ident := $"play_music".
Definition _play_painting_eject_sound : ident := $"play_painting_eject_sound".
Definition _play_secondary_music : ident := $"play_secondary_music".
Definition _play_shell_music : ident := $"play_shell_music".
Definition _play_sound : ident := $"play_sound".
Definition _popmtx : ident := $"popmtx".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _prim_level : ident := $"prim_level".
Definition _prim_min_level : ident := $"prim_min_level".
Definition _priority : ident := $"priority".
Definition _profiler_log_thread4_time : ident := $"profiler_log_thread4_time".
Definition _punchState : ident := $"punchState".
Definition _queue : ident := $"queue".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _ra : ident := $"ra".
Definition _raise_background_noise : ident := $"raise_background_noise".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _rcp : ident := $"rcp".
Definition _reset_volume : ident := $"reset_volume".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _rippleDecay : ident := $"rippleDecay".
Definition _rippleDisplayList : ident := $"rippleDisplayList".
Definition _rippleTimer : ident := $"rippleTimer".
Definition _rippleTrigger : ident := $"rippleTrigger".
Definition _rippleX : ident := $"rippleX".
Definition _rippleY : ident := $"rippleY".
Definition _room : ident := $"room".
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
Definition _sBgMusicDisabled : ident := $"sBgMusicDisabled".
Definition _sCurrentCapMusic : ident := $"sCurrentCapMusic".
Definition _sCurrentMusic : ident := $"sCurrentMusic".
Definition _sCurrentShellMusic : ident := $"sCurrentShellMusic".
Definition _sMenuSoundsExtra : ident := $"sMenuSoundsExtra".
Definition _sMusicVolume : ident := $"sMusicVolume".
Definition _sPaintingEjectSoundPlayed : ident := $"sPaintingEjectSoundPlayed".
Definition _sPlayingInfiniteStairs : ident := $"sPlayingInfiniteStairs".
Definition _sSoundMenuModeToSoundMode : ident := $"sSoundMenuModeToSoundMode".
Definition _sSoundMesgBuf : ident := $"sSoundMesgBuf".
Definition _sSoundMesgQueue : ident := $"sSoundMesgQueue".
Definition _sSoundVblankHandler : ident := $"sSoundVblankHandler".
Definition _scale : ident := $"scale".
Definition _segment : ident := $"segment".
Definition _seqArgs : ident := $"seqArgs".
Definition _seq_player_fade_out : ident := $"seq_player_fade_out".
Definition _seq_player_lower_volume : ident := $"seq_player_lower_volume".
Definition _seq_player_unlower_volume : ident := $"seq_player_unlower_volume".
Definition _set_audio_muted : ident := $"set_audio_muted".
Definition _set_background_music : ident := $"set_background_music".
Definition _set_sound_mode : ident := $"set_sound_mode".
Definition _set_vblank_handler : ident := $"set_vblank_handler".
Definition _setcolor : ident := $"setcolor".
Definition _setcombine : ident := $"setcombine".
Definition _setimg : ident := $"setimg".
Definition _setothermodeH : ident := $"setothermodeH".
Definition _setothermodeL : ident := $"setothermodeL".
Definition _settile : ident := $"settile".
Definition _settilesize : ident := $"settilesize".
Definition _sft : ident := $"sft".
Definition _sh : ident := $"sh".
Definition _sharedChild : ident := $"sharedChild".
Definition _shifts : ident := $"shifts".
Definition _shiftt : ident := $"shiftt".
Definition _shouldPlay : ident := $"shouldPlay".
Definition _siz : ident := $"siz".
Definition _size : ident := $"size".
Definition _sl : ident := $"sl".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _soundMenuFlags : ident := $"soundMenuFlags".
Definition _soundMode : ident := $"soundMode".
Definition _sound_banks_disable : ident := $"sound_banks_disable".
Definition _sound_banks_enable : ident := $"sound_banks_enable".
Definition _sound_init : ident := $"sound_init".
Definition _sound_reset : ident := $"sound_reset".
Definition _sp : ident := $"sp".
Definition _spTask : ident := $"spTask".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _sr : ident := $"sr".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _state : ident := $"state".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_background_music : ident := $"stop_background_music".
Definition _stop_cap_music : ident := $"stop_cap_music".
Definition _stop_shell_music : ident := $"stop_shell_music".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
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
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _texture : ident := $"texture".
Definition _textureArray : ident := $"textureArray".
Definition _textureHeight : ident := $"textureHeight".
Definition _textureMaps : ident := $"textureMaps".
Definition _textureType : ident := $"textureType".
Definition _textureWidth : ident := $"textureWidth".
Definition _th : ident := $"th".
Definition _thprof : ident := $"thprof".
Definition _thread4_sound : ident := $"thread4_sound".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tile : ident := $"tile".
Definition _time : ident := $"time".
Definition _tl : ident := $"tl".
Definition _tlnext : ident := $"tlnext".
Definition _tmem : ident := $"tmem".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _tri : ident := $"tri".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
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
Definition _unk0C : ident := $"unk0C".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unused80339DC0 : ident := $"unused80339DC0".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _v : ident := $"v".
Definition _v0 : ident := $"v0".
Definition _v1 : ident := $"v1".
Definition _validCount : ident := $"validCount".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _w0 : ident := $"w0".
Definition _w1 : ident := $"w1".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _wd : ident := $"wd".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _words : ident := $"words".
Definition _x : ident := $"x".
Definition _x0 : ident := $"x0".
Definition _x0frac : ident := $"x0frac".
Definition _x1 : ident := $"x1".
Definition _x1frac : ident := $"x1frac".
Definition _y : ident := $"y".
Definition _y0 : ident := $"y0".
Definition _y0frac : ident := $"y0frac".
Definition _y1 : ident := $"y1".
Definition _y1frac : ident := $"y1frac".
Definition _yaw : ident := $"yaw".
Definition _yield_data_ptr : ident := $"yield_data_ptr".
Definition _yield_data_size : ident := $"yield_data_size".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'11 : ident := 138%positive.
Definition _t'12 : ident := 139%positive.
Definition _t'13 : ident := 140%positive.
Definition _t'14 : ident := 141%positive.
Definition _t'15 : ident := 142%positive.
Definition _t'2 : ident := 129%positive.
Definition _t'3 : ident := 130%positive.
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gVec3fZero := {|
  gvar_info := (tarray tfloat 3);
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

Definition v_gGlobalSoundSource := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrCreditsEntry := {|
  gvar_info := (tptr (Tstruct _CreditsEntry noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 1);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioState := {|
  gvar_info := (tptr (Tstruct _MarioState noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gNeverEnteredCastle := {|
  gvar_info := tschar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gResetTimer := {|
  gvar_info := tschar;
  gvar_init := (Init_space 1 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gRipplingPainting := {|
  gvar_info := (tptr (Tstruct _Painting noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused80339DC0 := {|
  gvar_info := (tarray tfloat 3);
  gvar_init := (Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundMesgQueue := {|
  gvar_info := (Tstruct _OSMesgQueue_s noattr);
  gvar_init := (Init_space 24 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundMesgBuf := {|
  gvar_info := (tarray (tptr tvoid) 1);
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundVblankHandler := {|
  gvar_info := (Tstruct _VblankHandler noattr);
  gvar_init := (Init_space 8 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMusicVolume := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBgMusicDisabled := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentMusic := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 65535) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentShellMusic := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 65535) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sCurrentCapMusic := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 65535) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPlayingInfiniteStairs := {|
  gvar_info := tuchar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSoundMenuModeToSoundMode := {|
  gvar_info := (tarray tshort 3);
  gvar_init := (Init_int16 (Int.repr 0) :: Init_int16 (Int.repr 3) ::
                Init_int16 (Int.repr 1) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sMenuSoundsExtra := {|
  gvar_info := (tarray tuint 36);
  gvar_init := (Init_int32 (Int.repr 335544321) ::
                Init_int32 (Int.repr 335609857) ::
                Init_int32 (Int.repr 335675393) ::
                Init_int32 (Int.repr 335740929) ::
                Init_int32 (Int.repr 335806465) ::
                Init_int32 (Int.repr 335872001) ::
                Init_int32 (Int.repr 335937537) ::
                Init_int32 (Int.repr 336592897) ::
                Init_int32 (Int.repr 336756737) ::
                Init_int32 (Int.repr 336658433) ::
                Init_int32 (Int.repr 336855041) ::
                Init_int32 (Int.repr 337641473) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 1074462721) ::
                Init_int32 (Int.repr 1074528257) ::
                Init_int32 (Int.repr 1074397185) ::
                Init_int32 (Int.repr 1073741825) ::
                Init_int32 (Int.repr 1073807361) ::
                Init_int32 (Int.repr 1073872897) ::
                Init_int32 (Int.repr 1090715649) ::
                Init_int32 (Int.repr 1074003969) ::
                Init_int32 (Int.repr 1074266113) ::
                Init_int32 (Int.repr 1074069505) ::
                Init_int32 (Int.repr 1074331649) ::
                Init_int32 (Int.repr 1610612737) ::
                Init_int32 (Int.repr 488185857) ::
                Init_int32 (Int.repr 1610776577) ::
                Init_int32 (Int.repr 1610825729) ::
                Init_int32 (Int.repr 1611677697) ::
                Init_int32 (Int.repr (-1873657855)) ::
                Init_int32 (Int.repr (-2142224383)) ::
                Init_int32 (Int.repr 1347502081) ::
                Init_int32 (Int.repr 1074266113) ::
                Init_int32 (Int.repr 1610891265) ::
                Init_int32 (Int.repr 1610907649) ::
                Init_int32 (Int.repr 1074593793) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sPaintingEjectSoundPlayed := {|
  gvar_info := tschar;
  gvar_init := (Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_reset_volume := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign (Evar _sMusicVolume tuchar) (Econst_int (Int.repr 0) tint))
|}.

Definition f_lower_background_noise := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _a tint)
    (LScons (Some 1)
      (Ssequence
        (Scall None
          (Evar _set_audio_muted (Tfunction (tuchar :: nil) tvoid cc_default))
          ((Econst_int (Int.repr 1) tint) :: nil))
        Sbreak)
      (LScons (Some 2)
        (Ssequence
          (Scall None
            (Evar _seq_player_lower_volume (Tfunction
                                             (tuchar :: tushort :: tuchar ::
                                              nil) tvoid cc_default))
            ((Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 60) tint) ::
             (Econst_int (Int.repr 40) tint) :: nil))
          Sbreak)
        LSnil)))
  (Ssequence
    (Sset _t'1 (Evar _sMusicVolume tuchar))
    (Sassign (Evar _sMusicVolume tuchar)
      (Ebinop Oor (Etempvar _t'1 tuchar) (Etempvar _a tint) tint))))
|}.

Definition f_raise_background_noise := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _a tint)
    (LScons (Some 1)
      (Ssequence
        (Scall None
          (Evar _set_audio_muted (Tfunction (tuchar :: nil) tvoid cc_default))
          ((Econst_int (Int.repr 0) tint) :: nil))
        Sbreak)
      (LScons (Some 2)
        (Ssequence
          (Scall None
            (Evar _seq_player_unlower_volume (Tfunction
                                               (tuchar :: tushort :: nil)
                                               tvoid cc_default))
            ((Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 60) tint) :: nil))
          Sbreak)
        LSnil)))
  (Ssequence
    (Sset _t'1 (Evar _sMusicVolume tuchar))
    (Sassign (Evar _sMusicVolume tuchar)
      (Ebinop Oand (Etempvar _t'1 tuchar)
        (Eunop Onotint (Etempvar _a tint) tint) tint))))
|}.

Definition f_disable_background_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sBgMusicDisabled tuchar))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sassign (Evar _sBgMusicDisabled tuchar)
        (Econst_int (Int.repr 1) tint))
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
         nil)))
    Sskip))
|}.

Definition f_enable_background_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sBgMusicDisabled tuchar))
  (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 1) tint) tint)
    (Ssequence
      (Sassign (Evar _sBgMusicDisabled tuchar)
        (Econst_int (Int.repr 0) tint))
      (Scall None
        (Evar _sound_banks_enable (Tfunction (tuchar :: tushort :: nil) tvoid
                                    cc_default))
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
         nil)))
    Sskip))
|}.

Definition f_set_sound_mode := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMode, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Sifthenelse (Ebinop Olt (Etempvar _soundMode tushort)
               (Econst_int (Int.repr 3) tint) tint)
  (Ssequence
    (Sset _t'1
      (Ederef
        (Ebinop Oadd (Evar _sSoundMenuModeToSoundMode (tarray tshort 3))
          (Etempvar _soundMode tushort) (tptr tshort)) tshort))
    (Scall None
      (Evar _audio_set_sound_mode (Tfunction (tuchar :: nil) tvoid
                                    cc_default))
      ((Etempvar _t'1 tshort) :: nil)))
  Sskip)
|}.

Definition f_play_menu_sounds := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_soundMenuFlags, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                 (Econst_int (Int.repr 1) tint) tint)
    (Scall None
      (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                          cc_default))
      ((Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 10) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Econst_int (Int.repr 128) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
    (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                   (Econst_int (Int.repr 2) tint) tint)
      (Scall None
        (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                            cc_default))
        ((Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 11) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Econst_int (Int.repr 128) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
      (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 12) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Econst_int (Int.repr 128) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
        (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 7) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 8) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
          (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                         (Econst_int (Int.repr 16) tint) tint)
            (Scall None
              (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                  tvoid cc_default))
              ((Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 7) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 8) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 0) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
            (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                           (Econst_int (Int.repr 32) tint) tint)
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 7) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 9) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
              (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                             (Econst_int (Int.repr 64) tint) tint)
                (Scall None
                  (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                      tvoid cc_default))
                  ((Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 7) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 6) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                               (Econst_int (Int.repr 128) tint) tint)
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 7) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 7) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                  Sskip))))))))
  (Sifthenelse (Ebinop Oand (Etempvar _soundMenuFlags tshort)
                 (Econst_int (Int.repr 256) tint) tint)
    (Scall None
      (Evar _play_menu_sounds_extra (Tfunction (tint :: (tptr tvoid) :: nil)
                                      tvoid cc_default))
      ((Econst_int (Int.repr 20) tint) ::
       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil))
    Sskip))
|}.

Definition f_play_painting_eject_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'6, tschar) ::
               (_t'5, (tptr (Tstruct _Painting noattr))) ::
               (_t'4, (tptr (Tstruct _Painting noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4 (Evar _gRipplingPainting (tptr (Tstruct _Painting noattr))))
    (Sifthenelse (Ebinop One
                   (Etempvar _t'4 (tptr (Tstruct _Painting noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Ssequence
        (Sset _t'5
          (Evar _gRipplingPainting (tptr (Tstruct _Painting noattr))))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _Painting noattr)))
                (Tstruct _Painting noattr)) _state tschar))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'6 tschar)
                (Econst_int (Int.repr 2) tint) tint) tbool))))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sPaintingEjectSoundPlayed tschar))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'2 tschar) tint)
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef
                  (Ebinop Oadd
                    (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                  tvoid cc_default))
              ((Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 3) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 40) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 0) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor
                     (Ebinop Oor (Econst_int (Int.repr 16777216) tint)
                       (Econst_int (Int.repr 134217728) tint) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          Sskip))
      (Sassign (Evar _sPaintingEjectSoundPlayed tschar)
        (Econst_int (Int.repr 1) tint)))
    (Sassign (Evar _sPaintingEjectSoundPlayed tschar)
      (Econst_int (Int.repr 0) tint))))
|}.

Definition f_play_infinite_stairs_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_shouldPlay, tuchar) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, tschar) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) ::
               (_t'9, (tptr (Tstruct _MarioState noattr))) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) ::
               (_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _MarioState noattr))) ::
               (_t'4, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _shouldPlay (Ecast (Econst_int (Int.repr 0) tint) tuchar))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'14 (Evar _gCurrLevelNum tshort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tshort)
                         (Econst_int (Int.repr 6) tint) tint)
            (Ssequence
              (Sset _t'15 (Evar _gCurrAreaIndex tshort))
              (Sset _t'2
                (Ecast
                  (Ebinop Oeq (Etempvar _t'15 tshort)
                    (Econst_int (Int.repr 2) tint) tint) tbool)))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Ssequence
            (Sset _t'12
              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef
                    (Etempvar _t'12 (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _numStars tshort))
              (Sset _t'3
                (Ecast
                  (Ebinop Olt (Etempvar _t'13 tshort)
                    (Econst_int (Int.repr 70) tint) tint) tbool))))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Sset _t'9
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _floor
                        (tptr (Tstruct _Surface noattr))))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                            (Tstruct _Surface noattr)) _room tschar))
                      (Sset _t'1
                        (Ecast
                          (Ebinop Oeq (Etempvar _t'11 tschar)
                            (Econst_int (Int.repr 6) tint) tint) tbool)))))
                (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'5
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _t'5 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                      (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'6 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1159643136)) tfloat)
                               tint)
                  (Sset _shouldPlay
                    (Ecast (Econst_int (Int.repr 1) tint) tuchar))
                  Sskip)))
            Sskip))
        Sskip))
    (Ssequence
      (Sset _t'4 (Evar _sPlayingInfiniteStairs tuchar))
      (Sifthenelse (Ebinop Oxor (Etempvar _t'4 tuchar)
                     (Etempvar _shouldPlay tuchar) tint)
        (Ssequence
          (Sassign (Evar _sPlayingInfiniteStairs tuchar)
            (Etempvar _shouldPlay tuchar))
          (Sifthenelse (Etempvar _shouldPlay tuchar)
            (Scall None
              (Evar _play_secondary_music (Tfunction
                                            (tuchar :: tuchar :: tuchar ::
                                             tushort :: nil) tvoid
                                            cc_default))
              ((Econst_int (Int.repr 24) tint) ::
               (Econst_int (Int.repr 0) tint) ::
               (Econst_int (Int.repr 255) tint) ::
               (Econst_int (Int.repr 1000) tint) :: nil))
            (Scall None
              (Evar _func_80321080 (Tfunction (tushort :: nil) tvoid
                                     cc_default))
              ((Econst_int (Int.repr 500) tint) :: nil))))
        Sskip))))
|}.

Definition f_set_background_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a, tushort) :: (_seqArgs, tushort) ::
                (_fadeTimer, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'6, tushort) ::
               (_t'5, tschar) ::
               (_t'4, (tptr (Tstruct _CreditsEntry noattr))) ::
               (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5 (Evar _gResetTimer tschar))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tschar)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'6 (Evar _sCurrentMusic tushort))
        (Sset _t'2
          (Ecast
            (Ebinop One (Etempvar _seqArgs tushort) (Etempvar _t'6 tushort)
              tint) tbool)))
      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Evar _gCurrCreditsEntry (tptr (Tstruct _CreditsEntry noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'4 (tptr (Tstruct _CreditsEntry noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Scall None
            (Evar _sound_reset (Tfunction (tuchar :: nil) tvoid cc_default))
            ((Econst_int (Int.repr 7) tint) :: nil))
          (Scall None
            (Evar _sound_reset (Tfunction (tuchar :: nil) tvoid cc_default))
            ((Etempvar _a tushort) :: nil))))
      (Ssequence
        (Ssequence
          (Sset _t'3 (Evar _gNeverEnteredCastle tschar))
          (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tschar) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Sset _t'1
              (Ecast
                (Ebinop One (Etempvar _seqArgs tushort)
                  (Econst_int (Int.repr 4) tint) tint) tbool))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Scall None
              (Evar _play_music (Tfunction
                                  (tuchar :: tushort :: tushort :: nil) tvoid
                                  cc_default))
              ((Econst_int (Int.repr 0) tint) ::
               (Etempvar _seqArgs tushort) :: (Etempvar _fadeTimer tshort) ::
               nil))
            (Sassign (Evar _sCurrentMusic tushort)
              (Etempvar _seqArgs tushort)))
          Sskip)))
    Sskip))
|}.

Definition f_fadeout_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fadeOutTime, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _func_803210D4 (Tfunction (tushort :: nil) tvoid cc_default))
    ((Etempvar _fadeOutTime tshort) :: nil))
  (Ssequence
    (Sassign (Evar _sCurrentMusic tushort)
      (Econst_int (Int.repr 65535) tint))
    (Ssequence
      (Sassign (Evar _sCurrentShellMusic tushort)
        (Econst_int (Int.repr 65535) tint))
      (Sassign (Evar _sCurrentCapMusic tushort)
        (Econst_int (Int.repr 65535) tint)))))
|}.

Definition f_fadeout_level_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_fadeTimer, tshort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _seq_player_fade_out (Tfunction (tuchar :: tushort :: nil) tvoid
                                 cc_default))
    ((Econst_int (Int.repr 0) tint) :: (Etempvar _fadeTimer tshort) :: nil))
  (Ssequence
    (Sassign (Evar _sCurrentMusic tushort)
      (Econst_int (Int.repr 65535) tint))
    (Ssequence
      (Sassign (Evar _sCurrentShellMusic tushort)
        (Econst_int (Int.repr 65535) tint))
      (Sassign (Evar _sCurrentCapMusic tushort)
        (Econst_int (Int.repr 65535) tint)))))
|}.

Definition f_play_cutscene_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_seqArgs, tushort) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_music (Tfunction (tuchar :: tushort :: tushort :: nil) tvoid
                        cc_default))
    ((Econst_int (Int.repr 0) tint) :: (Etempvar _seqArgs tushort) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Sassign (Evar _sCurrentMusic tushort) (Etempvar _seqArgs tushort)))
|}.

Definition f_play_shell_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_music (Tfunction (tuchar :: tushort :: tushort :: nil) tvoid
                        cc_default))
    ((Econst_int (Int.repr 0) tint) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oshl (Econst_int (Int.repr 4) tint)
           (Econst_int (Int.repr 8) tint) tint)
         (Econst_int (Int.repr 14) tint) tint)
       (Econst_int (Int.repr 128) tint) tint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Sassign (Evar _sCurrentShellMusic tushort)
    (Ebinop Oor
      (Ebinop Oor
        (Ebinop Oshl (Econst_int (Int.repr 4) tint)
          (Econst_int (Int.repr 8) tint) tint)
        (Econst_int (Int.repr 14) tint) tint)
      (Econst_int (Int.repr 128) tint) tint)))
|}.

Definition f_stop_shell_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sCurrentShellMusic tushort))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tushort)
                 (Econst_int (Int.repr 65535) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sCurrentShellMusic tushort))
        (Scall None
          (Evar _stop_background_music (Tfunction (tushort :: nil) tvoid
                                         cc_default))
          ((Etempvar _t'2 tushort) :: nil)))
      (Sassign (Evar _sCurrentShellMusic tushort)
        (Econst_int (Int.repr 65535) tint)))
    Sskip))
|}.

Definition f_play_cap_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_seqArgs, tushort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tushort) :: (_t'3, tushort) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_music (Tfunction (tuchar :: tushort :: tushort :: nil) tvoid
                        cc_default))
    ((Econst_int (Int.repr 0) tint) :: (Etempvar _seqArgs tushort) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _sCurrentCapMusic tushort))
        (Sifthenelse (Ebinop One (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 65535) tint) tint)
          (Ssequence
            (Sset _t'4 (Evar _sCurrentCapMusic tushort))
            (Sset _t'1
              (Ecast
                (Ebinop One (Etempvar _t'4 tushort)
                  (Etempvar _seqArgs tushort) tint) tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Sset _t'2 (Evar _sCurrentCapMusic tushort))
          (Scall None
            (Evar _stop_background_music (Tfunction (tushort :: nil) tvoid
                                           cc_default))
            ((Etempvar _t'2 tushort) :: nil)))
        Sskip))
    (Sassign (Evar _sCurrentCapMusic tushort) (Etempvar _seqArgs tushort))))
|}.

Definition f_fadeout_cap_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sCurrentCapMusic tushort))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tushort)
                 (Econst_int (Int.repr 65535) tint) tint)
    (Ssequence
      (Sset _t'2 (Evar _sCurrentCapMusic tushort))
      (Scall None
        (Evar _fadeout_background_music (Tfunction
                                          (tushort :: tushort :: nil) tvoid
                                          cc_default))
        ((Etempvar _t'2 tushort) :: (Econst_int (Int.repr 600) tint) :: nil)))
    Sskip))
|}.

Definition f_stop_cap_music := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'2, tushort) :: (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1 (Evar _sCurrentCapMusic tushort))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tushort)
                 (Econst_int (Int.repr 65535) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'2 (Evar _sCurrentCapMusic tushort))
        (Scall None
          (Evar _stop_background_music (Tfunction (tushort :: nil) tvoid
                                         cc_default))
          ((Etempvar _t'2 tushort) :: nil)))
      (Sassign (Evar _sCurrentCapMusic tushort)
        (Econst_int (Int.repr 65535) tint)))
    Sskip))
|}.

Definition f_play_menu_sounds_extra := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_a, tint) :: (_b, (tptr tvoid)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Ederef
      (Ebinop Oadd (Evar _sMenuSoundsExtra (tarray tuint 36))
        (Etempvar _a tint) (tptr tuint)) tuint))
  (Scall None
    (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                        cc_default))
    ((Etempvar _t'1 tuint) :: (Etempvar _b (tptr tvoid)) :: nil)))
|}.

Definition f_audio_game_loop_tick := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Scall None
  (Evar _audio_signal_game_loop_tick (Tfunction nil tvoid cc_default)) nil)
|}.

Definition f_thread4_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_arg, (tptr tvoid)) :: nil);
  fn_vars := ((_msg, (tptr tvoid)) :: nil);
  fn_temps := ((_spTask, (tptr (Tstruct _SPTask noattr))) ::
               (_t'1, (tptr (Tstruct _SPTask noattr))) :: (_t'2, tschar) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None (Evar _audio_init (Tfunction nil tvoid cc_default)) nil)
  (Ssequence
    (Scall None (Evar _sound_init (Tfunction nil tvoid cc_default)) nil)
    (Ssequence
      (Scall None
        (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                            (tptr tvoid) cc_default))
        ((Evar _unused80339DC0 (tarray tfloat 3)) ::
         (Evar _gVec3fZero (tarray tfloat 3)) :: nil))
      (Ssequence
        (Scall None
          (Evar _osCreateMesgQueue (Tfunction
                                     ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                      (tptr (tptr tvoid)) :: tint :: nil)
                                     tvoid cc_default))
          ((Eaddrof (Evar _sSoundMesgQueue (Tstruct _OSMesgQueue_s noattr))
             (tptr (Tstruct _OSMesgQueue_s noattr))) ::
           (Evar _sSoundMesgBuf (tarray (tptr tvoid) 1)) ::
           (Ecast
             (Ebinop Odiv (Esizeof (tarray (tptr tvoid) 1) tuint)
               (Esizeof (tptr tvoid) tuint) tuint) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_vblank_handler (Tfunction
                                        (tint ::
                                         (tptr (Tstruct _VblankHandler noattr)) ::
                                         (tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                         (tptr (tptr tvoid)) :: nil) tvoid
                                        cc_default))
            ((Econst_int (Int.repr 1) tint) ::
             (Eaddrof
               (Evar _sSoundVblankHandler (Tstruct _VblankHandler noattr))
               (tptr (Tstruct _VblankHandler noattr))) ::
             (Eaddrof (Evar _sSoundMesgQueue (Tstruct _OSMesgQueue_s noattr))
               (tptr (Tstruct _OSMesgQueue_s noattr))) ::
             (Ecast (Econst_int (Int.repr 512) tint) (tptr tvoid)) :: nil))
          (Sloop
            (Ssequence
              Sskip
              (Ssequence
                (Scall None
                  (Evar _osRecvMesg (Tfunction
                                      ((tptr (Tstruct _OSMesgQueue_s noattr)) ::
                                       (tptr (tptr tvoid)) :: tint :: nil)
                                      tint cc_default))
                  ((Eaddrof
                     (Evar _sSoundMesgQueue (Tstruct _OSMesgQueue_s noattr))
                     (tptr (Tstruct _OSMesgQueue_s noattr))) ::
                   (Eaddrof (Evar _msg (tptr tvoid)) (tptr (tptr tvoid))) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                (Ssequence
                  (Sset _t'2 (Evar _gResetTimer tschar))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'2 tschar)
                                 (Econst_int (Int.repr 25) tint) tint)
                    (Ssequence
                      (Scall None
                        (Evar _profiler_log_thread4_time (Tfunction nil tvoid
                                                           cc_default)) nil)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'1)
                            (Evar _create_next_audio_frame_task (Tfunction
                                                                  nil
                                                                  (tptr (Tstruct _SPTask noattr))
                                                                  cc_default))
                            nil)
                          (Sset _spTask
                            (Etempvar _t'1 (tptr (Tstruct _SPTask noattr)))))
                        (Ssequence
                          (Sifthenelse (Ebinop One
                                         (Etempvar _spTask (tptr (Tstruct _SPTask noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Scall None
                              (Evar _dispatch_audio_sptask (Tfunction
                                                             ((tptr (Tstruct _SPTask noattr)) ::
                                                              nil) tvoid
                                                             cc_default))
                              ((Etempvar _spTask (tptr (Tstruct _SPTask noattr))) ::
                               nil))
                            Sskip)
                          (Scall None
                            (Evar _profiler_log_thread4_time (Tfunction nil
                                                               tvoid
                                                               cc_default))
                            nil))))
                    Sskip))))
            Sskip))))))
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
 Composite __764 Union
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
    Member_plain _rawData (Tunion __764 noattr) ::
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
 Composite __769 Struct
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
    Member_plain _normal (Tstruct __769 noattr) ::
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
 Composite _CreditsEntry Struct
   (Member_plain _levelNum tuchar :: Member_plain _areaIndex tuchar ::
    Member_plain _unk02 tuchar :: Member_plain _marioAngle tschar ::
    Member_plain _marioPos (tarray tshort 3) ::
    Member_plain _unk0C (tptr (tptr tuchar)) :: nil)
   noattr ::
 Composite _Painting Struct
   (Member_plain _id tshort :: Member_plain _imageCount tschar ::
    Member_plain _textureType tschar :: Member_plain _lastFloor tschar ::
    Member_plain _currFloor tschar :: Member_plain _floorEntered tschar ::
    Member_plain _state tschar :: Member_plain _pitch tfloat ::
    Member_plain _yaw tfloat :: Member_plain _posX tfloat ::
    Member_plain _posY tfloat :: Member_plain _posZ tfloat ::
    Member_plain _currRippleMag tfloat ::
    Member_plain _passiveRippleMag tfloat ::
    Member_plain _entryRippleMag tfloat ::
    Member_plain _rippleDecay tfloat ::
    Member_plain _passiveRippleDecay tfloat ::
    Member_plain _entryRippleDecay tfloat ::
    Member_plain _currRippleRate tfloat ::
    Member_plain _passiveRippleRate tfloat ::
    Member_plain _entryRippleRate tfloat ::
    Member_plain _dispersionFactor tfloat ::
    Member_plain _passiveDispersionFactor tfloat ::
    Member_plain _entryDispersionFactor tfloat ::
    Member_plain _rippleTimer tfloat :: Member_plain _rippleX tfloat ::
    Member_plain _rippleY tfloat ::
    Member_plain _normalDisplayList (tptr (Tunion __549 noattr)) ::
    Member_plain _textureMaps (tptr (tptr tshort)) ::
    Member_plain _textureArray (tptr (tptr tuchar)) ::
    Member_plain _textureWidth tshort ::
    Member_plain _textureHeight tshort ::
    Member_plain _rippleDisplayList (tptr (Tunion __549 noattr)) ::
    Member_plain _rippleTrigger tschar :: Member_plain _alpha tuchar ::
    Member_plain _marioWasUnder tschar ::
    Member_plain _marioIsUnder tschar ::
    Member_plain _marioWentUnder tschar :: Member_plain _size tfloat :: nil)
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
      tint :: nil) tint cc_default)) :: (_gVec3fZero, Gvar v_gVec3fZero) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_create_next_audio_frame_task,
   Gfun(External (EF_external "create_next_audio_frame_task"
                   (mksignature nil AST.Xptr cc_default)) nil
     (tptr (Tstruct _SPTask noattr)) cc_default)) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_audio_signal_game_loop_tick,
   Gfun(External (EF_external "audio_signal_game_loop_tick"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_seq_player_fade_out,
   Gfun(External (EF_external "seq_player_fade_out"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_seq_player_lower_volume,
   Gfun(External (EF_external "seq_player_lower_volume"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned ::
                      AST.Xint8unsigned :: nil) AST.Xvoid cc_default))
     (tuchar :: tushort :: tuchar :: nil) tvoid cc_default)) ::
 (_seq_player_unlower_volume,
   Gfun(External (EF_external "seq_player_unlower_volume"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_set_audio_muted,
   Gfun(External (EF_external "set_audio_muted"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xvoid
                     cc_default)) (tuchar :: nil) tvoid cc_default)) ::
 (_sound_init,
   Gfun(External (EF_external "sound_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_sound_banks_disable,
   Gfun(External (EF_external "sound_banks_disable"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_sound_banks_enable,
   Gfun(External (EF_external "sound_banks_enable"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tushort :: nil) tvoid
     cc_default)) ::
 (_play_music,
   Gfun(External (EF_external "play_music"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint16unsigned ::
                      AST.Xint16unsigned :: nil) AST.Xvoid cc_default))
     (tuchar :: tushort :: tushort :: nil) tvoid cc_default)) ::
 (_stop_background_music,
   Gfun(External (EF_external "stop_background_music"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_fadeout_background_music,
   Gfun(External (EF_external "fadeout_background_music"
                   (mksignature
                     (AST.Xint16unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default)) (tushort :: tushort :: nil) tvoid
     cc_default)) ::
 (_play_secondary_music,
   Gfun(External (EF_external "play_secondary_music"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint8unsigned ::
                      AST.Xint8unsigned :: AST.Xint16unsigned :: nil)
                     AST.Xvoid cc_default))
     (tuchar :: tuchar :: tuchar :: tushort :: nil) tvoid cc_default)) ::
 (_func_80321080,
   Gfun(External (EF_external "func_80321080"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_func_803210D4,
   Gfun(External (EF_external "func_803210D4"
                   (mksignature (AST.Xint16unsigned :: nil) AST.Xvoid
                     cc_default)) (tushort :: nil) tvoid cc_default)) ::
 (_sound_reset,
   Gfun(External (EF_external "sound_reset"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xvoid
                     cc_default)) (tuchar :: nil) tvoid cc_default)) ::
 (_audio_set_sound_mode,
   Gfun(External (EF_external "audio_set_sound_mode"
                   (mksignature (AST.Xint8unsigned :: nil) AST.Xvoid
                     cc_default)) (tuchar :: nil) tvoid cc_default)) ::
 (_audio_init,
   Gfun(External (EF_external "audio_init"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_vec3f_copy,
   Gfun(External (EF_external "vec3f_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tfloat) :: nil)
     (tptr tvoid) cc_default)) ::
 (_gCurrCreditsEntry, Gvar v_gCurrCreditsEntry) ::
 (_gMarioStates, Gvar v_gMarioStates) ::
 (_gMarioState, Gvar v_gMarioState) ::
 (_gNeverEnteredCastle, Gvar v_gNeverEnteredCastle) ::
 (_gResetTimer, Gvar v_gResetTimer) ::
 (_set_vblank_handler,
   Gfun(External (EF_external "set_vblank_handler"
                   (mksignature
                     (AST.Xint :: AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     (tint :: (tptr (Tstruct _VblankHandler noattr)) ::
      (tptr (Tstruct _OSMesgQueue_s noattr)) :: (tptr (tptr tvoid)) :: nil)
     tvoid cc_default)) ::
 (_dispatch_audio_sptask,
   Gfun(External (EF_external "dispatch_audio_sptask"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _SPTask noattr)) :: nil) tvoid cc_default)) ::
 (_gRipplingPainting, Gvar v_gRipplingPainting) ::
 (_profiler_log_thread4_time,
   Gfun(External (EF_external "profiler_log_thread4_time"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_unused80339DC0, Gvar v_unused80339DC0) ::
 (_sSoundMesgQueue, Gvar v_sSoundMesgQueue) ::
 (_sSoundMesgBuf, Gvar v_sSoundMesgBuf) ::
 (_sSoundVblankHandler, Gvar v_sSoundVblankHandler) ::
 (_sMusicVolume, Gvar v_sMusicVolume) ::
 (_sBgMusicDisabled, Gvar v_sBgMusicDisabled) ::
 (_sCurrentMusic, Gvar v_sCurrentMusic) ::
 (_sCurrentShellMusic, Gvar v_sCurrentShellMusic) ::
 (_sCurrentCapMusic, Gvar v_sCurrentCapMusic) ::
 (_sPlayingInfiniteStairs, Gvar v_sPlayingInfiniteStairs) ::
 (_sSoundMenuModeToSoundMode, Gvar v_sSoundMenuModeToSoundMode) ::
 (_sMenuSoundsExtra, Gvar v_sMenuSoundsExtra) ::
 (_sPaintingEjectSoundPlayed, Gvar v_sPaintingEjectSoundPlayed) ::
 (_reset_volume, Gfun(Internal f_reset_volume)) ::
 (_lower_background_noise, Gfun(Internal f_lower_background_noise)) ::
 (_raise_background_noise, Gfun(Internal f_raise_background_noise)) ::
 (_disable_background_sound, Gfun(Internal f_disable_background_sound)) ::
 (_enable_background_sound, Gfun(Internal f_enable_background_sound)) ::
 (_set_sound_mode, Gfun(Internal f_set_sound_mode)) ::
 (_play_menu_sounds, Gfun(Internal f_play_menu_sounds)) ::
 (_play_painting_eject_sound, Gfun(Internal f_play_painting_eject_sound)) ::
 (_play_infinite_stairs_music, Gfun(Internal f_play_infinite_stairs_music)) ::
 (_set_background_music, Gfun(Internal f_set_background_music)) ::
 (_fadeout_music, Gfun(Internal f_fadeout_music)) ::
 (_fadeout_level_music, Gfun(Internal f_fadeout_level_music)) ::
 (_play_cutscene_music, Gfun(Internal f_play_cutscene_music)) ::
 (_play_shell_music, Gfun(Internal f_play_shell_music)) ::
 (_stop_shell_music, Gfun(Internal f_stop_shell_music)) ::
 (_play_cap_music, Gfun(Internal f_play_cap_music)) ::
 (_fadeout_cap_music, Gfun(Internal f_fadeout_cap_music)) ::
 (_stop_cap_music, Gfun(Internal f_stop_cap_music)) ::
 (_play_menu_sounds_extra, Gfun(Internal f_play_menu_sounds_extra)) ::
 (_audio_game_loop_tick, Gfun(Internal f_audio_game_loop_tick)) ::
 (_thread4_sound, Gfun(Internal f_thread4_sound)) :: nil).

Definition public_idents : list ident :=
(_thread4_sound :: _audio_game_loop_tick :: _play_menu_sounds_extra ::
 _stop_cap_music :: _fadeout_cap_music :: _play_cap_music ::
 _stop_shell_music :: _play_shell_music :: _play_cutscene_music ::
 _fadeout_level_music :: _fadeout_music :: _set_background_music ::
 _play_infinite_stairs_music :: _play_painting_eject_sound ::
 _play_menu_sounds :: _set_sound_mode :: _enable_background_sound ::
 _disable_background_sound :: _raise_background_noise ::
 _lower_background_noise :: _reset_volume :: _profiler_log_thread4_time ::
 _gRipplingPainting :: _dispatch_audio_sptask :: _set_vblank_handler ::
 _gResetTimer :: _gNeverEnteredCastle :: _gMarioState :: _gMarioStates ::
 _gCurrCreditsEntry :: _vec3f_copy :: _audio_init :: _audio_set_sound_mode ::
 _sound_reset :: _func_803210D4 :: _func_80321080 :: _play_secondary_music ::
 _fadeout_background_music :: _stop_background_music :: _play_music ::
 _sound_banks_enable :: _sound_banks_disable :: _sound_init ::
 _set_audio_muted :: _seq_player_unlower_volume ::
 _seq_player_lower_volume :: _seq_player_fade_out ::
 _audio_signal_game_loop_tick :: _play_sound ::
 _create_next_audio_frame_task :: _gGlobalSoundSource :: _gCurrLevelNum ::
 _gCurrAreaIndex :: _gVec3fZero :: _osRecvMesg :: _osCreateMesgQueue ::
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


