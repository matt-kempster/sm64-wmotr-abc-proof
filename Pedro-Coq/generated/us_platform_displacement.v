(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Decomp revision: 9921382a68bb0c865e5e45eb594d9c64db59b1af
   Game version:    VERSION_US
   Source:          src/game/platform_displacement.c
   Generator:       The CompCert CompCert AST generator, version 3.15
   Flags:           -normalize -nostdinc -fstruct-passing -Ibuild/pinned-sm64/include -Ibuild/pinned-sm64/src -Ibuild/pinned-sm64/src/game -Ibuild/pinned-sm64 -Ibuild/pinned-sm64/include/libc -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1 -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1
   Link hygiene:    private __stringlit_N atoms prefixed with us_platform_displacement
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
  Definition source_file := "build/pinned-sm64/src/game/platform_displacement.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
Definition _D_8032FEC0 : ident := $"D_8032FEC0".
Definition _DmaHandlerList : ident := $"DmaHandlerList".
Definition _DmaTable : ident := $"DmaTable".
Definition _GraphNode : ident := $"GraphNode".
Definition _GraphNodeObject : ident := $"GraphNodeObject".
Definition _GraphNodeRoot : ident := $"GraphNodeRoot".
Definition _InstantWarp : ident := $"InstantWarp".
Definition _MarioBodyState : ident := $"MarioBodyState".
Definition _MarioState : ident := $"MarioState".
Definition _Object : ident := $"Object".
Definition _ObjectNode : ident := $"ObjectNode".
Definition _ObjectWarpNode : ident := $"ObjectWarpNode".
Definition _OffsetSizePair : ident := $"OffsetSizePair".
Definition _PlayerCameraState : ident := $"PlayerCameraState".
Definition _SpawnInfo : ident := $"SpawnInfo".
Definition _Surface : ident := $"Surface".
Definition _UnusedArea28 : ident := $"UnusedArea28".
Definition _WarpNode : ident := $"WarpNode".
Definition _Waypoint : ident := $"Waypoint".
Definition _Whirlpool : ident := $"Whirlpool".
Definition __317 : ident := $"_317".
Definition __319 : ident := $"_319".
Definition __764 : ident := $"_764".
Definition __769 : ident := $"_769".
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
Definition _absf : ident := $"absf".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
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
Definition _apply_mario_platform_displacement : ident := $"apply_mario_platform_displacement".
Definition _apply_platform_displacement : ident := $"apply_platform_displacement".
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
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
Definition _awayFromFloor : ident := $"awayFromFloor".
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
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _children : ident := $"children".
Definition _clear_mario_platform : ident := $"clear_mario_platform".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _currentObjectOffset : ident := $"currentObjectOffset".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displaceMatrix : ident := $"displaceMatrix".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_floor : ident := $"find_floor".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCurrentObject : ident := $"gCurrentObject".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioPlatform : ident := $"gMarioPlatform".
Definition _gMarioStates : ident := $"gMarioStates".
Definition _gTimeStopState : ident := $"gTimeStopState".
Definition _get_mario_pos : ident := $"get_mario_pos".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
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
Definition _hitboxDownOffset : ident := $"hitboxDownOffset".
Definition _hitboxHeight : ident := $"hitboxHeight".
Definition _hitboxRadius : ident := $"hitboxRadius".
Definition _hurtCounter : ident := $"hurtCounter".
Definition _hurtboxHeight : ident := $"hurtboxHeight".
Definition _hurtboxRadius : ident := $"hurtboxRadius".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isMario : ident := $"isMario".
Definition _length : ident := $"length".
Definition _linear_mtxf_mul_vec3f : ident := $"linear_mtxf_mul_vec3f".
Definition _linear_mtxf_transpose_mul_vec3f : ident := $"linear_mtxf_transpose_mul_vec3f".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _marioX : ident := $"marioX".
Definition _marioY : ident := $"marioY".
Definition _marioZ : ident := $"marioZ".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _mtxf_rotate_zxy_and_translate : ident := $"mtxf_rotate_zxy_and_translate".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _newObjectOffset : ident := $"newObjectOffset".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offset : ident := $"offset".
Definition _originOffset : ident := $"originOffset".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _platformPosX : ident := $"platformPosX".
Definition _platformPosY : ident := $"platformPosY".
Definition _platformPosZ : ident := $"platformPosZ".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _relativeOffset : ident := $"relativeOffset".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _rotation : ident := $"rotation".
Definition _scale : ident := $"scale".
Definition _set_mario_pos : ident := $"set_mario_pos".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _twirlYaw : ident := $"twirlYaw".
Definition _type : ident := $"type".
Definition _unk00 : ident := $"unk00".
Definition _unk02 : ident := $"unk02".
Definition _unk04 : ident := $"unk04".
Definition _unk06 : ident := $"unk06".
Definition _unk08 : ident := $"unk08".
Definition _unk15 : ident := $"unk15".
Definition _unk4C : ident := $"unk4C".
Definition _unkB0 : ident := $"unkB0".
Definition _unused : ident := $"unused".
Definition _unused1 : ident := $"unused1".
Definition _unused2 : ident := $"unused2".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedPitch : ident := $"unusedPitch".
Definition _unusedRoll : ident := $"unusedRoll".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _unusedYaw : ident := $"unusedYaw".
Definition _unused_8032FEC4 : ident := $"unused_8032FEC4".
Definition _update_mario_platform : ident := $"update_mario_platform".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _z : ident := $"z".
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
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gMarioStates := {|
  gvar_info := (tarray (Tstruct _MarioState noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gTimeStopState := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCurrentObject := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_D_8032FEC0 := {|
  gvar_info := tushort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused_8032FEC4 := {|
  gvar_info := (tarray tuint 4);
  gvar_init := (Init_int32 (Int.repr 0) :: Init_space 12 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioPlatform := {|
  gvar_info := (tptr (Tstruct _Object noattr));
  gvar_init := (Init_int32 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_update_mario_platform := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) ::
              (_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_marioX, tfloat) :: (_marioY, tfloat) :: (_marioZ, tfloat) ::
               (_floorHeight, tfloat) :: (_awayFromFloor, tuint) ::
               (_t'3, tint) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'17 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Sreturn None)
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'16 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
      (Sset _marioX
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asF32 (tarray tfloat 80))
            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
              (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'15 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
        (Sset _marioY
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'14 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
          (Sset _marioZ
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 2) tint) tint) (tptr tfloat)) tfloat)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _find_floor (Tfunction
                                  (tfloat :: tfloat :: tfloat ::
                                   (tptr (tptr (Tstruct _Surface noattr))) ::
                                   nil) tfloat cc_default))
              ((Etempvar _marioX tfloat) :: (Etempvar _marioY tfloat) ::
               (Etempvar _marioZ tfloat) ::
               (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                 (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
            (Sset _floorHeight (Etempvar _t'1 tfloat)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _absf (Tfunction (tfloat :: nil) tfloat cc_default))
                ((Ebinop Osub (Etempvar _marioY tfloat)
                   (Etempvar _floorHeight tfloat) tfloat) :: nil))
              (Sifthenelse (Ebinop Olt (Etempvar _t'2 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                             tint)
                (Sset _awayFromFloor (Econst_int (Int.repr 0) tint))
                (Sset _awayFromFloor (Econst_int (Int.repr 1) tint))))
            (Sswitch (Etempvar _awayFromFloor tuint)
              (LScons (Some 1)
                (Ssequence
                  (Sassign
                    (Evar _gMarioPlatform (tptr (Tstruct _Object noattr)))
                    (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _platform
                          (tptr (Tstruct _Object noattr)))
                        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))))
                    Sbreak))
                (LScons (Some 0)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Evar _floor (tptr (Tstruct _Surface noattr))))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Sset _t'11
                              (Evar _floor (tptr (Tstruct _Surface noattr))))
                            (Ssequence
                              (Sset _t'12
                                (Efield
                                  (Ederef
                                    (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _object
                                  (tptr (Tstruct _Object noattr))))
                              (Sset _t'3
                                (Ecast
                                  (Ebinop One
                                    (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                    (Ecast (Econst_int (Int.repr 0) tint)
                                      (tptr tvoid)) tint) tbool))))
                          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                      (Sifthenelse (Etempvar _t'3 tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'8
                              (Evar _floor (tptr (Tstruct _Surface noattr))))
                            (Ssequence
                              (Sset _t'9
                                (Efield
                                  (Ederef
                                    (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _object
                                  (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Evar _gMarioPlatform (tptr (Tstruct _Object noattr)))
                                (Etempvar _t'9 (tptr (Tstruct _Object noattr))))))
                          (Ssequence
                            (Sset _t'5
                              (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'6
                                (Evar _floor (tptr (Tstruct _Surface noattr))))
                              (Ssequence
                                (Sset _t'7
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _object
                                    (tptr (Tstruct _Object noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _platform
                                    (tptr (Tstruct _Object noattr)))
                                  (Etempvar _t'7 (tptr (Tstruct _Object noattr))))))))
                        (Ssequence
                          (Sassign
                            (Evar _gMarioPlatform (tptr (Tstruct _Object noattr)))
                            (Ecast (Econst_int (Int.repr 0) tint)
                              (tptr tvoid)))
                          (Ssequence
                            (Sset _t'4
                              (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _platform
                                (tptr (Tstruct _Object noattr)))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid)))))))
                    Sbreak)
                  LSnil)))))))))
|}.

Definition f_get_mario_pos := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, (tptr tfloat)) :: (_y, (tptr tfloat)) ::
                (_z, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
    (Sassign (Ederef (Etempvar _x (tptr tfloat)) tfloat)
      (Etempvar _t'3 tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sassign (Ederef (Etempvar _y (tptr tfloat)) tfloat)
        (Etempvar _t'2 tfloat)))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef
                (Ebinop Oadd
                  (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
      (Sassign (Ederef (Etempvar _z (tptr tfloat)) tfloat)
        (Etempvar _t'1 tfloat)))))
|}.

Definition f_set_mario_pos := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_x, tfloat) :: (_y, tfloat) :: (_z, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd
        (Efield
          (Ederef
            (Ebinop Oadd
              (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
    (Etempvar _x tfloat))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
      (Etempvar _y tfloat))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef
              (Ebinop Oadd
                (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
      (Etempvar _z tfloat))))
|}.

Definition f_apply_platform_displacement := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_isMario, tuint) ::
                (_platform, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := ((_x, tfloat) :: (_y, tfloat) :: (_z, tfloat) ::
              (_currentObjectOffset, (tarray tfloat 3)) ::
              (_relativeOffset, (tarray tfloat 3)) ::
              (_newObjectOffset, (tarray tfloat 3)) ::
              (_rotation, (tarray tshort 3)) ::
              (_displaceMatrix, (tarray (tarray tfloat 4) 4)) :: nil);
  fn_temps := ((_platformPosX, tfloat) :: (_platformPosY, tfloat) ::
               (_platformPosZ, tfloat) :: (_unusedPitch, tshort) ::
               (_unusedRoll, tshort) :: (_unusedYaw, tshort) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'47, tint) ::
               (_t'46, tint) :: (_t'45, tint) :: (_t'44, tfloat) ::
               (_t'43, (tptr (Tstruct _Object noattr))) :: (_t'42, tfloat) ::
               (_t'41, (tptr (Tstruct _Object noattr))) :: (_t'40, tfloat) ::
               (_t'39, (tptr (Tstruct _Object noattr))) :: (_t'38, tfloat) ::
               (_t'37, tfloat) :: (_t'36, tfloat) :: (_t'35, tfloat) ::
               (_t'34, tshort) :: (_t'33, tshort) :: (_t'32, tshort) ::
               (_t'31, tshort) :: (_t'30, tshort) :: (_t'29, tint) ::
               (_t'28, tshort) :: (_t'27, tshort) :: (_t'26, tfloat) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tint) ::
               (_t'22, tint) :: (_t'21, tint) :: (_t'20, tint) ::
               (_t'19, tint) :: (_t'18, tint) :: (_t'17, tint) ::
               (_t'16, tint) :: (_t'15, tint) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'47
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _platform (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 35) tint)
          (tptr tint)) tint))
    (Sassign
      (Ederef
        (Ebinop Oadd (Evar _rotation (tarray tshort 3))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
      (Etempvar _t'47 tint)))
  (Ssequence
    (Ssequence
      (Sset _t'46
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _platform (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 36) tint)
            (tptr tint)) tint))
      (Sassign
        (Ederef
          (Ebinop Oadd (Evar _rotation (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Etempvar _t'46 tint)))
    (Ssequence
      (Ssequence
        (Sset _t'45
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _platform (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __764 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 37) tint)
              (tptr tint)) tint))
        (Sassign
          (Ederef
            (Ebinop Oadd (Evar _rotation (tarray tshort 3))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
          (Etempvar _t'45 tint)))
      (Ssequence
        (Sifthenelse (Etempvar _isMario tuint)
          (Ssequence
            (Sassign (Evar _D_8032FEC0 tushort)
              (Econst_int (Int.repr 0) tint))
            (Scall None
              (Evar _get_mario_pos (Tfunction
                                     ((tptr tfloat) :: (tptr tfloat) ::
                                      (tptr tfloat) :: nil) tvoid cc_default))
              ((Eaddrof (Evar _x tfloat) (tptr tfloat)) ::
               (Eaddrof (Evar _y tfloat) (tptr tfloat)) ::
               (Eaddrof (Evar _z tfloat) (tptr tfloat)) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'43
                (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'44
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'43 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign (Evar _x tfloat) (Etempvar _t'44 tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'41
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'42
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'41 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign (Evar _y tfloat) (Etempvar _t'42 tfloat))))
              (Ssequence
                (Sset _t'39
                  (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'40
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'39 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign (Evar _z tfloat) (Etempvar _t'40 tfloat)))))))
        (Ssequence
          (Ssequence
            (Sset _t'37 (Evar _x tfloat))
            (Ssequence
              (Sset _t'38
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _platform (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 9) tint) (tptr tfloat)) tfloat))
              (Sassign (Evar _x tfloat)
                (Ebinop Oadd (Etempvar _t'37 tfloat) (Etempvar _t'38 tfloat)
                  tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'35 (Evar _z tfloat))
              (Ssequence
                (Sset _t'36
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _platform (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __764 noattr)) _asF32 (tarray tfloat 80))
                      (Econst_int (Int.repr 11) tint) (tptr tfloat)) tfloat))
                (Sassign (Evar _z tfloat)
                  (Ebinop Oadd (Etempvar _t'35 tfloat)
                    (Etempvar _t'36 tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'33
                      (Ederef
                        (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort))
                    (Sifthenelse (Ebinop One (Etempvar _t'33 tshort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Sset _t'1 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'34
                          (Ederef
                            (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Sset _t'1
                          (Ecast
                            (Ebinop One (Etempvar _t'34 tshort)
                              (Econst_int (Int.repr 0) tint) tint) tbool)))))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Sset _t'2 (Econst_int (Int.repr 1) tint))
                    (Ssequence
                      (Sset _t'32
                        (Ederef
                          (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort))
                      (Sset _t'2
                        (Ecast
                          (Ebinop One (Etempvar _t'32 tshort)
                            (Econst_int (Int.repr 0) tint) tint) tbool)))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'31
                        (Ederef
                          (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Sset _unusedPitch
                        (Ecast (Etempvar _t'31 tshort) tshort)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'30
                          (Ederef
                            (Ebinop Oadd (Evar _rotation (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort))
                        (Sset _unusedRoll
                          (Ecast (Etempvar _t'30 tshort) tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'29
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __764 noattr)) _asS32
                                  (tarray tint 80))
                                (Ebinop Oadd (Econst_int (Int.repr 18) tint)
                                  (Econst_int (Int.repr 1) tint) tint)
                                (tptr tint)) tint))
                          (Sset _unusedYaw
                            (Ecast (Etempvar _t'29 tint) tshort)))
                        (Ssequence
                          (Sifthenelse (Etempvar _isMario tuint)
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
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tshort)) tshort))
                              (Ssequence
                                (Sset _t'28
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _rotation (tarray tshort 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _gMarioStates (tarray (Tstruct _MarioState noattr) 0))
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _faceAngle (tarray tshort 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort)
                                  (Ebinop Oadd (Etempvar _t'27 tshort)
                                    (Etempvar _t'28 tshort) tint))))
                            Sskip)
                          (Ssequence
                            (Sset _platformPosX
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __764 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                    (Econst_int (Int.repr 0) tint) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _platformPosY
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __764 noattr)) _asF32
                                      (tarray tfloat 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _platformPosZ
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __764 noattr))
                                        _asF32 (tarray tfloat 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 6) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'26 (Evar _x tfloat))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _currentObjectOffset (tarray tfloat 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tfloat)) tfloat)
                                      (Ebinop Osub (Etempvar _t'26 tfloat)
                                        (Etempvar _platformPosX tfloat)
                                        tfloat)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'25 (Evar _y tfloat))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Evar _currentObjectOffset (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat)
                                        (Ebinop Osub (Etempvar _t'25 tfloat)
                                          (Etempvar _platformPosY tfloat)
                                          tfloat)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'24 (Evar _z tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _currentObjectOffset (tarray tfloat 3))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tfloat)) tfloat)
                                          (Ebinop Osub
                                            (Etempvar _t'24 tfloat)
                                            (Etempvar _platformPosZ tfloat)
                                            tfloat)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'22
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _rawData
                                                    (Tunion __764 noattr))
                                                  _asS32 (tarray tint 80))
                                                (Ebinop Oadd
                                                  (Econst_int (Int.repr 18) tint)
                                                  (Econst_int (Int.repr 0) tint)
                                                  tint) (tptr tint)) tint))
                                          (Ssequence
                                            (Sset _t'23
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _rawData
                                                      (Tunion __764 noattr))
                                                    _asS32 (tarray tint 80))
                                                  (Econst_int (Int.repr 35) tint)
                                                  (tptr tint)) tint))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _rotation (tarray tshort 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tshort)) tshort)
                                              (Ebinop Osub
                                                (Etempvar _t'22 tint)
                                                (Etempvar _t'23 tint) tint))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'20
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _rawData
                                                      (Tunion __764 noattr))
                                                    _asS32 (tarray tint 80))
                                                  (Ebinop Oadd
                                                    (Econst_int (Int.repr 18) tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) (tptr tint)) tint))
                                            (Ssequence
                                              (Sset _t'21
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _rawData
                                                        (Tunion __764 noattr))
                                                      _asS32
                                                      (tarray tint 80))
                                                    (Econst_int (Int.repr 36) tint)
                                                    (tptr tint)) tint))
                                              (Sassign
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Evar _rotation (tarray tshort 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tshort)) tshort)
                                                (Ebinop Osub
                                                  (Etempvar _t'20 tint)
                                                  (Etempvar _t'21 tint) tint))))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'18
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _rawData
                                                        (Tunion __764 noattr))
                                                      _asS32
                                                      (tarray tint 80))
                                                    (Ebinop Oadd
                                                      (Econst_int (Int.repr 18) tint)
                                                      (Econst_int (Int.repr 2) tint)
                                                      tint) (tptr tint))
                                                  tint))
                                              (Ssequence
                                                (Sset _t'19
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _rawData
                                                          (Tunion __764 noattr))
                                                        _asS32
                                                        (tarray tint 80))
                                                      (Econst_int (Int.repr 37) tint)
                                                      (tptr tint)) tint))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Evar _rotation (tarray tshort 3))
                                                      (Econst_int (Int.repr 2) tint)
                                                      (tptr tshort)) tshort)
                                                  (Ebinop Osub
                                                    (Etempvar _t'18 tint)
                                                    (Etempvar _t'19 tint)
                                                    tint))))
                                            (Ssequence
                                              (Scall None
                                                (Evar _mtxf_rotate_zxy_and_translate
                                                (Tfunction
                                                  ((tptr (tarray tfloat 4)) ::
                                                   (tptr tfloat) ::
                                                   (tptr tshort) :: nil)
                                                  tvoid cc_default))
                                                ((Evar _displaceMatrix (tarray (tarray tfloat 4) 4)) ::
                                                 (Evar _currentObjectOffset (tarray tfloat 3)) ::
                                                 (Evar _rotation (tarray tshort 3)) ::
                                                 nil))
                                              (Ssequence
                                                (Scall None
                                                  (Evar _linear_mtxf_transpose_mul_vec3f
                                                  (Tfunction
                                                    ((tptr (tarray tfloat 4)) ::
                                                     (tptr tfloat) ::
                                                     (tptr tfloat) :: nil)
                                                    tvoid cc_default))
                                                  ((Evar _displaceMatrix (tarray (tarray tfloat 4) 4)) ::
                                                   (Evar _relativeOffset (tarray tfloat 3)) ::
                                                   (Evar _currentObjectOffset (tarray tfloat 3)) ::
                                                   nil))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'17
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                                (Tstruct _Object noattr))
                                                              _rawData
                                                              (Tunion __764 noattr))
                                                            _asS32
                                                            (tarray tint 80))
                                                          (Ebinop Oadd
                                                            (Econst_int (Int.repr 18) tint)
                                                            (Econst_int (Int.repr 0) tint)
                                                            tint)
                                                          (tptr tint)) tint))
                                                    (Sassign
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _rotation (tarray tshort 3))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr tshort))
                                                        tshort)
                                                      (Etempvar _t'17 tint)))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'16
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                                  (Tstruct _Object noattr))
                                                                _rawData
                                                                (Tunion __764 noattr))
                                                              _asS32
                                                              (tarray tint 80))
                                                            (Ebinop Oadd
                                                              (Econst_int (Int.repr 18) tint)
                                                              (Econst_int (Int.repr 1) tint)
                                                              tint)
                                                            (tptr tint))
                                                          tint))
                                                      (Sassign
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Evar _rotation (tarray tshort 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tshort))
                                                          tshort)
                                                        (Etempvar _t'16 tint)))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Sset _t'15
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _platform (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                  _rawData
                                                                  (Tunion __764 noattr))
                                                                _asS32
                                                                (tarray tint 80))
                                                              (Ebinop Oadd
                                                                (Econst_int (Int.repr 18) tint)
                                                                (Econst_int (Int.repr 2) tint)
                                                                tint)
                                                              (tptr tint))
                                                            tint))
                                                        (Sassign
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Evar _rotation (tarray tshort 3))
                                                              (Econst_int (Int.repr 2) tint)
                                                              (tptr tshort))
                                                            tshort)
                                                          (Etempvar _t'15 tint)))
                                                      (Ssequence
                                                        (Scall None
                                                          (Evar _mtxf_rotate_zxy_and_translate
                                                          (Tfunction
                                                            ((tptr (tarray tfloat 4)) ::
                                                             (tptr tfloat) ::
                                                             (tptr tshort) ::
                                                             nil) tvoid
                                                            cc_default))
                                                          ((Evar _displaceMatrix (tarray (tarray tfloat 4) 4)) ::
                                                           (Evar _currentObjectOffset (tarray tfloat 3)) ::
                                                           (Evar _rotation (tarray tshort 3)) ::
                                                           nil))
                                                        (Ssequence
                                                          (Scall None
                                                            (Evar _linear_mtxf_mul_vec3f
                                                            (Tfunction
                                                              ((tptr (tarray tfloat 4)) ::
                                                               (tptr tfloat) ::
                                                               (tptr tfloat) ::
                                                               nil) tvoid
                                                              cc_default))
                                                            ((Evar _displaceMatrix (tarray (tarray tfloat 4) 4)) ::
                                                             (Evar _newObjectOffset (tarray tfloat 3)) ::
                                                             (Evar _relativeOffset (tarray tfloat 3)) ::
                                                             nil))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'14
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Evar _newObjectOffset (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tfloat))
                                                                  tfloat))
                                                              (Sassign
                                                                (Evar _x tfloat)
                                                                (Ebinop Oadd
                                                                  (Etempvar _platformPosX tfloat)
                                                                  (Etempvar _t'14 tfloat)
                                                                  tfloat)))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'13
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _newObjectOffset (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tfloat))
                                                                    tfloat))
                                                                (Sassign
                                                                  (Evar _y tfloat)
                                                                  (Ebinop Oadd
                                                                    (Etempvar _platformPosY tfloat)
                                                                    (Etempvar _t'13 tfloat)
                                                                    tfloat)))
                                                              (Ssequence
                                                                (Sset _t'12
                                                                  (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _newObjectOffset (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tfloat))
                                                                    tfloat))
                                                                (Sassign
                                                                  (Evar _z tfloat)
                                                                  (Ebinop Oadd
                                                                    (Etempvar _platformPosZ tfloat)
                                                                    (Etempvar _t'12 tfloat)
                                                                    tfloat)))))))))))))))))))))))))
                  Sskip))
              (Sifthenelse (Etempvar _isMario tuint)
                (Ssequence
                  (Sset _t'9 (Evar _x tfloat))
                  (Ssequence
                    (Sset _t'10 (Evar _y tfloat))
                    (Ssequence
                      (Sset _t'11 (Evar _z tfloat))
                      (Scall None
                        (Evar _set_mario_pos (Tfunction
                                               (tfloat :: tfloat :: tfloat ::
                                                nil) tvoid cc_default))
                        ((Etempvar _t'9 tfloat) :: (Etempvar _t'10 tfloat) ::
                         (Etempvar _t'11 tfloat) :: nil)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'8 (Evar _x tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __764 noattr)) _asF32
                              (tarray tfloat 80))
                            (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                              (Econst_int (Int.repr 0) tint) tint)
                            (tptr tfloat)) tfloat) (Etempvar _t'8 tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'6 (Evar _y tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asF32
                                (tarray tfloat 80))
                              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 1) tint) tint)
                              (tptr tfloat)) tfloat) (Etempvar _t'6 tfloat))))
                    (Ssequence
                      (Sset _t'3
                        (Evar _gCurrentObject (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'4 (Evar _z tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __764 noattr)) _asF32
                                (tarray tfloat 80))
                              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                (Econst_int (Int.repr 2) tint) tint)
                              (tptr tfloat)) tfloat) (Etempvar _t'4 tfloat))))))))))))))
|}.

Definition f_apply_mario_platform_displacement := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_platform, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _platform (Evar _gMarioPlatform (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3 (Evar _gTimeStopState tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'3 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 6) tint) tint) tuint) tint)
          (Ssequence
            (Sset _t'4 (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
            (Sset _t'1
              (Ecast
                (Ebinop One (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
                tbool)))
          (Sset _t'1 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _t'2
          (Ecast
            (Ebinop One (Etempvar _platform (tptr (Tstruct _Object noattr)))
              (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
            tbool))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Scall None
        (Evar _apply_platform_displacement (Tfunction
                                             (tuint ::
                                              (tptr (Tstruct _Object noattr)) ::
                                              nil) tvoid cc_default))
        ((Econst_int (Int.repr 1) tint) ::
         (Etempvar _platform (tptr (Tstruct _Object noattr))) :: nil))
      Sskip)))
|}.

Definition f_clear_mario_platform := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Sassign (Evar _gMarioPlatform (tptr (Tstruct _Object noattr)))
  (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
|}.

Definition composites : list composite_definition :=
(Composite __317 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __319 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __317 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __319 noattr)) :: nil)
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
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
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
 (_mtxf_rotate_zxy_and_translate,
   Gfun(External (EF_external "mtxf_rotate_zxy_and_translate"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tshort) :: nil)
     tvoid cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_gMarioStates, Gvar v_gMarioStates) ::
 (_linear_mtxf_mul_vec3f,
   Gfun(External (EF_external "linear_mtxf_mul_vec3f"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tfloat) :: nil)
     tvoid cc_default)) ::
 (_linear_mtxf_transpose_mul_vec3f,
   Gfun(External (EF_external "linear_mtxf_transpose_mul_vec3f"
                   (mksignature (AST.Xptr :: AST.Xptr :: AST.Xptr :: nil)
                     AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: (tptr tfloat) :: nil)
     tvoid cc_default)) ::
 (_absf,
   Gfun(External (EF_external "absf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_gTimeStopState, Gvar v_gTimeStopState) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_gCurrentObject, Gvar v_gCurrentObject) ::
 (_D_8032FEC0, Gvar v_D_8032FEC0) ::
 (_unused_8032FEC4, Gvar v_unused_8032FEC4) ::
 (_gMarioPlatform, Gvar v_gMarioPlatform) ::
 (_update_mario_platform, Gfun(Internal f_update_mario_platform)) ::
 (_get_mario_pos, Gfun(Internal f_get_mario_pos)) ::
 (_set_mario_pos, Gfun(Internal f_set_mario_pos)) ::
 (_apply_platform_displacement, Gfun(Internal f_apply_platform_displacement)) ::
 (_apply_mario_platform_displacement, Gfun(Internal f_apply_mario_platform_displacement)) ::
 (_clear_mario_platform, Gfun(Internal f_clear_mario_platform)) :: nil).

Definition public_idents : list ident :=
(_clear_mario_platform :: _apply_mario_platform_displacement ::
 _apply_platform_displacement :: _set_mario_pos :: _get_mario_pos ::
 _update_mario_platform :: _gMarioPlatform :: _unused_8032FEC4 ::
 _D_8032FEC0 :: _gCurrentObject :: _gMarioObject :: _gTimeStopState ::
 _absf :: _linear_mtxf_transpose_mul_vec3f :: _linear_mtxf_mul_vec3f ::
 _gMarioStates :: _find_floor :: _mtxf_rotate_zxy_and_translate ::
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
