(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_automatic.c
   clightgen:   The CompCert CompCert AST generator, version 3.15
   Flags:       -normalize -nostdinc -fstruct-passing -Ivendor/sm64/include -Ivendor/sm64/build/us -Ivendor/sm64/build/us/include -Ivendor/sm64/src -Ivendor/sm64 -Ivendor/sm64/include/libc -DVERSION_US=1 -DF3DEX_GBI_2=1 -DF3DEX_GBI_SHARED=1 -D_FINALROM=1 -DTARGET_N64=1 -DNON_MATCHING=1 -DAVOID_UB=1 -D_LANGUAGE_C=1
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
  Definition arch := "x86".
  Definition model := "64".
  Definition abi := "standard".
  Definition bitsize := 64.
  Definition big_endian := false.
  Definition source_file := "vendor/sm64/src/game/mario_actions_automatic.c".
  Definition normalized := true.
End Info.

Definition _AnimInfo : ident := $"AnimInfo".
Definition _Animation : ident := $"Animation".
Definition _Area : ident := $"Area".
Definition _Camera : ident := $"Camera".
Definition _ChainSegment : ident := $"ChainSegment".
Definition _Controller : ident := $"Controller".
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
Definition __218 : ident := $"_218".
Definition __220 : ident := $"_220".
Definition __665 : ident := $"_665".
Definition __670 : ident := $"_670".
Definition ___builtin_ais_annot : ident := $"__builtin_ais_annot".
Definition ___builtin_annot : ident := $"__builtin_annot".
Definition ___builtin_annot_intval : ident := $"__builtin_annot_intval".
Definition ___builtin_bswap : ident := $"__builtin_bswap".
Definition ___builtin_bswap16 : ident := $"__builtin_bswap16".
Definition ___builtin_bswap32 : ident := $"__builtin_bswap32".
Definition ___builtin_bswap64 : ident := $"__builtin_bswap64".
Definition ___builtin_clz : ident := $"__builtin_clz".
Definition ___builtin_clzl : ident := $"__builtin_clzl".
Definition ___builtin_clzll : ident := $"__builtin_clzll".
Definition ___builtin_ctz : ident := $"__builtin_ctz".
Definition ___builtin_ctzl : ident := $"__builtin_ctzl".
Definition ___builtin_ctzll : ident := $"__builtin_ctzll".
Definition ___builtin_debug : ident := $"__builtin_debug".
Definition ___builtin_expect : ident := $"__builtin_expect".
Definition ___builtin_fabs : ident := $"__builtin_fabs".
Definition ___builtin_fabsf : ident := $"__builtin_fabsf".
Definition ___builtin_fmadd : ident := $"__builtin_fmadd".
Definition ___builtin_fmax : ident := $"__builtin_fmax".
Definition ___builtin_fmin : ident := $"__builtin_fmin".
Definition ___builtin_fmsub : ident := $"__builtin_fmsub".
Definition ___builtin_fnmadd : ident := $"__builtin_fnmadd".
Definition ___builtin_fnmsub : ident := $"__builtin_fnmsub".
Definition ___builtin_fsqrt : ident := $"__builtin_fsqrt".
Definition ___builtin_membar : ident := $"__builtin_membar".
Definition ___builtin_memcpy_aligned : ident := $"__builtin_memcpy_aligned".
Definition ___builtin_read16_reversed : ident := $"__builtin_read16_reversed".
Definition ___builtin_read32_reversed : ident := $"__builtin_read32_reversed".
Definition ___builtin_sel : ident := $"__builtin_sel".
Definition ___builtin_sqrt : ident := $"__builtin_sqrt".
Definition ___builtin_unreachable : ident := $"__builtin_unreachable".
Definition ___builtin_va_arg : ident := $"__builtin_va_arg".
Definition ___builtin_va_copy : ident := $"__builtin_va_copy".
Definition ___builtin_va_end : ident := $"__builtin_va_end".
Definition ___builtin_va_start : ident := $"__builtin_va_start".
Definition ___builtin_write16_reversed : ident := $"__builtin_write16_reversed".
Definition ___builtin_write32_reversed : ident := $"__builtin_write32_reversed".
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
Definition _act_climbing_pole : ident := $"act_climbing_pole".
Definition _act_grab_pole_fast : ident := $"act_grab_pole_fast".
Definition _act_grab_pole_slow : ident := $"act_grab_pole_slow".
Definition _act_grabbed : ident := $"act_grabbed".
Definition _act_hang_moving : ident := $"act_hang_moving".
Definition _act_hanging : ident := $"act_hanging".
Definition _act_holding_pole : ident := $"act_holding_pole".
Definition _act_in_cannon : ident := $"act_in_cannon".
Definition _act_ledge_climb_down : ident := $"act_ledge_climb_down".
Definition _act_ledge_climb_fast : ident := $"act_ledge_climb_fast".
Definition _act_ledge_climb_slow : ident := $"act_ledge_climb_slow".
Definition _act_ledge_grab : ident := $"act_ledge_grab".
Definition _act_start_hanging : ident := $"act_start_hanging".
Definition _act_top_of_pole : ident := $"act_top_of_pole".
Definition _act_top_of_pole_transition : ident := $"act_top_of_pole_transition".
Definition _act_tornado_twirling : ident := $"act_tornado_twirling".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _add_tree_leaf_particles : ident := $"add_tree_leaf_particles".
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
Definition _animation : ident := $"animation".
Definition _approach_s32 : ident := $"approach_s32".
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
Definition _b : ident := $"b".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvGiantPole : ident := $"bhvGiantPole".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bhvTree : ident := $"bhvTree".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraAngle : ident := $"cameraAngle".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _cancel : ident := $"cancel".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _ceilOffset : ident := $"ceilOffset".
Definition _check_common_action_exits : ident := $"check_common_action_exits".
Definition _check_common_automatic_cancels : ident := $"check_common_automatic_cancels".
Definition _children : ident := $"children".
Definition _climb_up_ledge : ident := $"climb_up_ledge".
Definition _collided : ident := $"collided".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _cosAngleVel : ident := $"cosAngleVel".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dx : ident := $"dx".
Definition _dz : ident := $"dz".
Definition _endAction : ident := $"endAction".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _f32_find_wall_collision : ident := $"f32_find_wall_collision".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_height_relative_polar : ident := $"find_floor_height_relative_polar".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gSineTable : ident := $"gSineTable".
Definition _gVec3fZero : ident := $"gVec3fZero".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _hasSpaceForMario : ident := $"hasSpaceForMario".
Definition _headAngle : ident := $"headAngle".
Definition _headRotation : ident := $"headRotation".
Definition _header : ident := $"header".
Definition _healCounter : ident := $"healCounter".
Definition _health : ident := $"health".
Definition _height : ident := $"height".
Definition _heightAboveFloor : ident := $"heightAboveFloor".
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
Definition _intendedDYaw : ident := $"intendedDYaw".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isOnTree : ident := $"isOnTree".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _is_anim_past_frame : ident := $"is_anim_past_frame".
Definition _leafHeight : ident := $"leafHeight".
Definition _length : ident := $"length".
Definition _let_go_of_ledge : ident := $"let_go_of_ledge".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_execute_automatic_action : ident := $"mario_execute_automatic_action".
Definition _maxSpeed : ident := $"maxSpeed".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _next : ident := $"next".
Definition _nextPos : ident := $"nextPos".
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
Definition _offsetY : ident := $"offsetY".
Definition _originOffset : ident := $"originOffset".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_hanging_step : ident := $"perform_hanging_step".
Definition _platform : ident := $"platform".
Definition _play_climbing_sounds : ident := $"play_climbing_sounds".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _poleBehavior : ident := $"poleBehavior".
Definition _poleTop : ident := $"poleTop".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _prevTwirlYaw : ident := $"prevTwirlYaw".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _return_mario_anim_y_translation : ident := $"return_mario_anim_y_translation".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_anim_with_accel : ident := $"set_mario_anim_with_accel".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_pole_position : ident := $"set_pole_position".
Definition _set_sound_moving_speed : ident := $"set_sound_moving_speed".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _sinAngleVel : ident := $"sinAngleVel".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sp24 : ident := $"sp24".
Definition _sp4 : ident := $"sp4".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFacePitch : ident := $"startFacePitch".
Definition _startFaceYaw : ident := $"startFaceYaw".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stepResult : ident := $"stepResult".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_and_set_height_to_floor : ident := $"stop_and_set_height_to_floor".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _thrown : ident := $"thrown".
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
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _update_hang_moving : ident := $"update_hang_moving".
Definition _update_hang_stationary : ident := $"update_hang_stationary".
Definition _update_ledge_climb : ident := $"update_ledge_climb".
Definition _update_ledge_climb_camera : ident := $"update_ledge_climb_camera".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_find_ceil : ident := $"vec3f_find_ceil".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _virtual_to_segmented : ident := $"virtual_to_segmented".
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
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_bhvGiantPole := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_bhvTree := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gVec3fZero := {|
  gvar_info := (tarray tfloat 3);
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

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_add_tree_leaf_particles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_leafHeight, tfloat) :: (_t'1, (tptr tvoid)) ::
               (_t'7, tshort) :: (_t'6, tuint) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, (tptr tuint)) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'1)
    (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil) (tptr tvoid)
                                  cc_default))
    ((Evar _bhvTree (tarray tuint 0)) :: nil))
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _behavior (tptr tuint)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 (tptr tuint))
                     (Etempvar _t'1 (tptr tvoid)) tint)
        (Ssequence
          (Ssequence
            (Sset _t'7 (Evar _gCurrLevelNum tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
                           (Econst_int (Int.repr 8) tint) tint)
              (Sset _leafHeight
                (Econst_single (Float32.of_bits (Int.repr 1132068864)) tfloat))
              (Sset _leafHeight
                (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floorHeight tfloat))
              (Sifthenelse (Ebinop Ogt
                             (Ebinop Osub (Etempvar _t'4 tfloat)
                               (Etempvar _t'5 tfloat) tfloat)
                             (Etempvar _leafHeight tfloat) tint)
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _particleFlags tuint))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _particleFlags tuint)
                    (Ebinop Oor (Etempvar _t'6 tuint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 13) tint) tint) tuint)))
                Sskip))))
        Sskip))))
|}.

Definition f_play_climbing_sounds := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: (_b, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_isOnTree, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, (tptr tvoid)) ::
               (_t'8, (tptr tuint)) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Evar _bhvTree (tarray tuint 0)) :: nil))
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _behavior (tptr tuint)))
        (Sset _isOnTree
          (Ebinop Oeq (Etempvar _t'8 (tptr tuint))
            (Etempvar _t'1 (tptr tvoid)) tint)))))
  (Sifthenelse (Ebinop Oeq (Etempvar _b tint) (Econst_int (Int.repr 1) tint)
                 tint)
    (Ssequence
      (Scall (Some _t'3)
        (Evar _is_anim_past_frame (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tshort :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 1) tint) :: nil))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Sifthenelse (Etempvar _isOnTree tint)
            (Sset _t'2
              (Ecast
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 28) tint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 58) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 128) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint)
                    (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                      (Econst_int (Int.repr 128) tint) tint) tuint)
                  (Econst_int (Int.repr 1) tint) tuint) tuint))
            (Sset _t'2
              (Ecast
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 28) tint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 65) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 128) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint)
                    (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                      (Econst_int (Int.repr 128) tint) tint) tuint)
                  (Econst_int (Int.repr 1) tint) tuint) tuint)))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                  tvoid cc_default))
              ((Etempvar _t'2 tuint) ::
               (Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil))))
        Sskip))
    (Ssequence
      (Sifthenelse (Etempvar _isOnTree tint)
        (Sset _t'4
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oshl (Ecast (Econst_int (Int.repr 1) tint) tuint)
                      (Econst_int (Int.repr 28) tint) tuint)
                    (Ebinop Oshl
                      (Ecast (Econst_int (Int.repr 18) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint)
                (Econst_int (Int.repr 67108864) tint) tuint)
              (Econst_int (Int.repr 1) tint) tuint) tuint))
        (Sset _t'4
          (Ecast
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oshl (Ecast (Econst_int (Int.repr 1) tint) tuint)
                      (Econst_int (Int.repr 28) tint) tuint)
                    (Ebinop Oshl
                      (Ecast (Econst_int (Int.repr 17) tint) tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 8) tint) tuint) tuint)
                (Econst_int (Int.repr 67108864) tint) tuint)
              (Econst_int (Int.repr 1) tint) tuint) tuint)))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Etempvar _t'4 tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil))))))
|}.

Definition f_set_pole_position := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_offsetY, tfloat) :: nil);
  fn_vars := ((_filler, (tarray tuchar 12)) ::
              (_floor, (tptr (Tstruct _Surface noattr))) ::
              (_ceil, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_ceilHeight, tfloat) ::
               (_collided, tint) :: (_result, tint) :: (_poleTop, tfloat) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'38, tfloat) ::
               (_t'37, (tptr (Tstruct _Object noattr))) :: (_t'36, tfloat) ::
               (_t'35, tfloat) :: (_t'34, (tptr (Tstruct _Object noattr))) ::
               (_t'33, tfloat) :: (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, tfloat) :: (_t'30, tfloat) ::
               (_t'29, (tptr (Tstruct _Object noattr))) :: (_t'28, tfloat) ::
               (_t'27, tfloat) :: (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tfloat) ::
               (_t'22, tfloat) :: (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _Object noattr))) :: (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tshort) ::
               (_t'7, tint) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'37
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'38
          (Efield
            (Ederef (Etempvar _t'37 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _hitboxHeight tfloat))
        (Sset _poleTop
          (Ebinop Osub (Etempvar _t'38 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
            tfloat))))
    (Ssequence
      (Sset _marioObj
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'36
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                (Econst_int (Int.repr 34) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'36 tfloat)
                         (Etempvar _poleTop tfloat) tint)
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Econst_int (Int.repr 34) tint) (tptr tfloat)) tfloat)
              (Etempvar _poleTop tfloat))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'34
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'35
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'34 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                (Etempvar _t'35 tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'32
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'33
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                      (tptr tfloat)) tfloat) (Etempvar _t'33 tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'29
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _usedObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'30
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'29 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                          (Econst_int (Int.repr 1) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'31
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 34) tint) (tptr tfloat))
                        tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat)
                      (Ebinop Oadd
                        (Ebinop Oadd (Etempvar _t'30 tfloat)
                          (Etempvar _t'31 tfloat) tfloat)
                        (Etempvar _offsetY tfloat) tfloat)))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _f32_find_wall_collision (Tfunction
                                                     ((tptr tfloat) ::
                                                      (tptr tfloat) ::
                                                      (tptr tfloat) ::
                                                      tfloat :: tfloat ::
                                                      nil) tint cc_default))
                    ((Ebinop Oadd
                       (Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                       (tptr tfloat)) ::
                     (Ebinop Oadd
                       (Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                       (tptr tfloat)) ::
                     (Ebinop Oadd
                       (Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                       (tptr tfloat)) ::
                     (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
                     nil))
                  (Sset _collided (Etempvar _t'1 tint)))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _f32_find_wall_collision (Tfunction
                                                       ((tptr tfloat) ::
                                                        (tptr tfloat) ::
                                                        (tptr tfloat) ::
                                                        tfloat :: tfloat ::
                                                        nil) tint cc_default))
                      ((Ebinop Oadd
                         (Efield
                           (Ederef
                             (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                             (Tstruct _MarioState noattr)) _pos
                           (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                         (tptr tfloat)) ::
                       (Ebinop Oadd
                         (Efield
                           (Ederef
                             (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                             (Tstruct _MarioState noattr)) _pos
                           (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                         (tptr tfloat)) ::
                       (Ebinop Oadd
                         (Efield
                           (Ederef
                             (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                             (Tstruct _MarioState noattr)) _pos
                           (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                         (tptr tfloat)) ::
                       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                       (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat) ::
                       nil))
                    (Sset _collided
                      (Ebinop Oor (Etempvar _collided tint)
                        (Etempvar _t'2 tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'28
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Scall (Some _t'3)
                          (Evar _vec3f_find_ceil (Tfunction
                                                   ((tptr tfloat) ::
                                                    tfloat ::
                                                    (tptr (tptr (Tstruct _Surface noattr))) ::
                                                    nil) tfloat cc_default))
                          ((Efield
                             (Ederef
                               (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                               (Tstruct _MarioState noattr)) _pos
                             (tarray tfloat 3)) :: (Etempvar _t'28 tfloat) ::
                           (Eaddrof
                             (Evar _ceil (tptr (Tstruct _Surface noattr)))
                             (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))
                      (Sset _ceilHeight (Etempvar _t'3 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'24
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sifthenelse (Ebinop Ogt (Etempvar _t'24 tfloat)
                                       (Ebinop Osub
                                         (Etempvar _ceilHeight tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                         tfloat) tint)
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Osub (Etempvar _ceilHeight tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                tfloat))
                            (Ssequence
                              (Sset _t'25
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'26
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _usedObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'27
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asF32 (tarray tfloat 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 6) tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asF32 (tarray tfloat 80))
                                        (Econst_int (Int.repr 34) tint)
                                        (tptr tfloat)) tfloat)
                                    (Ebinop Osub (Etempvar _t'25 tfloat)
                                      (Etempvar _t'27 tfloat) tfloat))))))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'21
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat))
                            (Ssequence
                              (Sset _t'22
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 1) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'23
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat))
                                (Scall (Some _t'4)
                                  (Evar _find_floor (Tfunction
                                                      (tfloat :: tfloat ::
                                                       tfloat ::
                                                       (tptr (tptr (Tstruct _Surface noattr))) ::
                                                       nil) tfloat
                                                      cc_default))
                                  ((Etempvar _t'21 tfloat) ::
                                   (Etempvar _t'22 tfloat) ::
                                   (Etempvar _t'23 tfloat) ::
                                   (Eaddrof
                                     (Evar _floor (tptr (Tstruct _Surface noattr)))
                                     (tptr (tptr (Tstruct _Surface noattr)))) ::
                                   nil)))))
                          (Sset _floorHeight (Etempvar _t'4 tfloat)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'12
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                                           (Etempvar _floorHeight tfloat)
                                           tint)
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat)
                                  (Etempvar _floorHeight tfloat))
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 205521409) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Sset _result
                                    (Econst_int (Int.repr 1) tint))))
                              (Ssequence
                                (Sset _t'13
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asF32 (tarray tfloat 80))
                                      (Econst_int (Int.repr 34) tint)
                                      (tptr tfloat)) tfloat))
                                (Ssequence
                                  (Sset _t'14
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _usedObj
                                      (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'15
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr))
                                        _hitboxDownOffset tfloat))
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _t'13 tfloat)
                                                   (Eunop Oneg
                                                     (Etempvar _t'15 tfloat)
                                                     tfloat) tint)
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'17
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _usedObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Ssequence
                                            (Sset _t'18
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                                        (Tstruct _Object noattr))
                                                      _rawData
                                                      (Tunion __665 noattr))
                                                    _asF32
                                                    (tarray tfloat 80))
                                                  (Ebinop Oadd
                                                    (Econst_int (Int.repr 6) tint)
                                                    (Econst_int (Int.repr 1) tint)
                                                    tint) (tptr tfloat))
                                                tfloat))
                                            (Ssequence
                                              (Sset _t'19
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _usedObj
                                                  (tptr (Tstruct _Object noattr))))
                                              (Ssequence
                                                (Sset _t'20
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _hitboxDownOffset tfloat))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _pos
                                                        (tarray tfloat 3))
                                                      (Econst_int (Int.repr 1) tint)
                                                      (tptr tfloat)) tfloat)
                                                  (Ebinop Osub
                                                    (Etempvar _t'18 tfloat)
                                                    (Etempvar _t'20 tfloat)
                                                    tfloat))))))
                                        (Ssequence
                                          (Scall None
                                            (Evar _set_mario_action (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    tuint ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             (Econst_int (Int.repr 16779404) tint) ::
                                             (Econst_int (Int.repr 0) tint) ::
                                             nil))
                                          (Sset _result
                                            (Econst_int (Int.repr 2) tint))))
                                      (Sifthenelse (Etempvar _collided tint)
                                        (Ssequence
                                          (Sset _t'16
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _pos (tarray tfloat 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tfloat)) tfloat))
                                          (Sifthenelse (Ebinop Ogt
                                                         (Etempvar _t'16 tfloat)
                                                         (Ebinop Oadd
                                                           (Etempvar _floorHeight tfloat)
                                                           (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                                           tfloat) tint)
                                            (Ssequence
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _forwardVel tfloat)
                                                (Eunop Oneg
                                                  (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                                                  tfloat))
                                              (Ssequence
                                                (Scall None
                                                  (Evar _set_mario_action 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   (Econst_int (Int.repr 16910518) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil))
                                                (Sset _result
                                                  (Econst_int (Int.repr 2) tint))))
                                            (Ssequence
                                              (Scall None
                                                (Evar _set_mario_action 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 (Econst_int (Int.repr 205521409) tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 nil))
                                              (Sset _result
                                                (Econst_int (Int.repr 1) tint)))))
                                        Sskip)))))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Scall None
                                (Evar _vec3f_copy (Tfunction
                                                    ((tptr tfloat) ::
                                                     (tptr tfloat) :: nil)
                                                    (tptr tvoid) cc_default))
                                ((Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr)) _pos
                                   (tarray tfloat 3)) ::
                                 (Efield
                                   (Ederef
                                     (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                     (Tstruct _MarioState noattr)) _pos
                                   (tarray tfloat 3)) :: nil)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'5
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _usedObj
                                      (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'7
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asS32 (tarray tint 80))
                                          (Ebinop Oadd
                                            (Econst_int (Int.repr 15) tint)
                                            (Econst_int (Int.repr 0) tint)
                                            tint) (tptr tint)) tint))
                                    (Ssequence
                                      (Sset _t'8
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _faceAngle (tarray tshort 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tshort)) tshort))
                                      (Ssequence
                                        (Sset _t'9
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _usedObj
                                            (tptr (Tstruct _Object noattr))))
                                        (Ssequence
                                          (Sset _t'10
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _rawData
                                                    (Tunion __665 noattr))
                                                  _asS32 (tarray tint 80))
                                                (Ebinop Oadd
                                                  (Econst_int (Int.repr 15) tint)
                                                  (Econst_int (Int.repr 2) tint)
                                                  tint) (tptr tint)) tint))
                                          (Scall None
                                            (Evar _vec3s_set (Tfunction
                                                               ((tptr tshort) ::
                                                                tshort ::
                                                                tshort ::
                                                                tshort ::
                                                                nil)
                                                               (tptr tvoid)
                                                               cc_default))
                                            ((Efield
                                               (Efield
                                                 (Efield
                                                   (Ederef
                                                     (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                                     (Tstruct _Object noattr))
                                                   _header
                                                   (Tstruct _ObjectNode noattr))
                                                 _gfx
                                                 (Tstruct _GraphNodeObject noattr))
                                               _angle (tarray tshort 3)) ::
                                             (Etempvar _t'7 tint) ::
                                             (Etempvar _t'8 tshort) ::
                                             (Etempvar _t'10 tint) :: nil))))))))
                              (Sreturn (Some (Etempvar _result tint))))))))))))))))))
|}.

Definition f_act_holding_pole := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_poleTop, tfloat) :: (_poleBehavior, (tptr tuint)) ::
               (_t'9, tint) :: (_t'8, (tptr tvoid)) :: (_t'7, tint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, (tptr tvoid)) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'41, tshort) :: (_t'40, tushort) :: (_t'39, tshort) ::
               (_t'38, tushort) :: (_t'37, tfloat) ::
               (_t'36, (tptr (Tstruct _Object noattr))) ::
               (_t'35, (tptr tuint)) ::
               (_t'34, (tptr (Tstruct _Object noattr))) :: (_t'33, tfloat) ::
               (_t'32, tfloat) ::
               (_t'31, (tptr (Tstruct _Controller noattr))) ::
               (_t'30, tfloat) ::
               (_t'29, (tptr (Tstruct _Controller noattr))) ::
               (_t'28, tfloat) ::
               (_t'27, (tptr (Tstruct _Controller noattr))) ::
               (_t'26, tint) :: (_t'25, tint) :: (_t'24, tint) ::
               (_t'23, tshort) :: (_t'22, tint) :: (_t'21, tfloat) ::
               (_t'20, tuint) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, (tptr tuint)) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tint) ::
               (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Controller noattr))) ::
               (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'40
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'40 tushort)
                       (Econst_int (Int.repr 32768) tint) tint)
          (Sset _t'2 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'41
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _health tshort))
            (Sset _t'2
              (Ecast
                (Ebinop Olt (Etempvar _t'41 tshort)
                  (Econst_int (Int.repr 256) tint) tint) tbool)))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Scall None
            (Evar _add_tree_leaf_particles (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                tfloat))
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16910518) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'1 tuint))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'38
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'38 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall None
              (Evar _add_tree_leaf_particles (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'39
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort)
                  (Ebinop Oadd (Etempvar _t'39 tshort)
                    (Econst_int (Int.repr 32768) tint) tint)))
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 50333830) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'3 tuint))))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'29
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _controller
              (tptr (Tstruct _Controller noattr))))
          (Ssequence
            (Sset _t'30
              (Efield
                (Ederef (Etempvar _t'29 (tptr (Tstruct _Controller noattr)))
                  (Tstruct _Controller noattr)) _stickY tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'30 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                           tint)
              (Ssequence
                (Ssequence
                  (Sset _t'36
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _usedObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'37
                      (Efield
                        (Ederef
                          (Etempvar _t'36 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _hitboxHeight tfloat))
                    (Sset _poleTop
                      (Ebinop Osub (Etempvar _t'37 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'34
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'35
                          (Efield
                            (Ederef
                              (Etempvar _t'34 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _behavior
                            (tptr tuint)))
                        (Scall (Some _t'4)
                          (Evar _virtual_to_segmented (Tfunction
                                                        (tuint ::
                                                         (tptr tvoid) :: nil)
                                                        (tptr tvoid)
                                                        cc_default))
                          ((Econst_int (Int.repr 19) tint) ::
                           (Etempvar _t'35 (tptr tuint)) :: nil))))
                    (Sset _poleBehavior (Etempvar _t'4 (tptr tvoid))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'33
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asF32
                              (tarray tfloat 80))
                            (Econst_int (Int.repr 34) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'33 tfloat)
                                     (Ebinop Osub (Etempvar _poleTop tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                                       tfloat) tint)
                        (Ssequence
                          (Scall (Some _t'5)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 1049411) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'5 tuint))))
                        Sskip))
                    (Ssequence
                      (Sifthenelse (Ebinop One
                                     (Etempvar _poleBehavior (tptr tuint))
                                     (Evar _bhvGiantPole (tarray tuint 0))
                                     tint)
                        (Ssequence
                          (Sset _t'31
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _controller
                              (tptr (Tstruct _Controller noattr))))
                          (Ssequence
                            (Sset _t'32
                              (Efield
                                (Ederef
                                  (Etempvar _t'31 (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr)) _stickY
                                tfloat))
                            (Sset _t'7
                              (Ecast
                                (Ebinop Ogt (Etempvar _t'32 tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                                  tint) tbool))))
                        (Sset _t'7 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'7 tint)
                        (Ssequence
                          (Scall (Some _t'6)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 1049412) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'6 tuint))))
                        Sskip)))))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _controller
                (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Etempvar _t'10 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _stickY tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'11 tfloat)
                             (Eunop Oneg
                               (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                               tfloat) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'26
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
                    (Ssequence
                      (Sset _t'27
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _controller
                          (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _t'27 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickY tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 33) tint) (tptr tint))
                            tint)
                          (Ebinop Osub (Etempvar _t'26 tint)
                            (Ebinop Omul (Etempvar _t'28 tfloat)
                              (Econst_int (Int.repr 2) tint) tfloat) tfloat)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'25
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asS32
                              (tarray tint 80))
                            (Econst_int (Int.repr 33) tint) (tptr tint))
                          tint))
                      (Sifthenelse (Ebinop Ogt (Etempvar _t'25 tint)
                                     (Econst_int (Int.repr 4096) tint) tint)
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 33) tint) (tptr tint))
                            tint) (Econst_int (Int.repr 4096) tint))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'23
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'24
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort)
                            (Ebinop Oadd (Etempvar _t'23 tshort)
                              (Etempvar _t'24 tint) tint))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'21
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asF32
                                  (tarray tfloat 80))
                                (Econst_int (Int.repr 34) tint)
                                (tptr tfloat)) tfloat))
                          (Ssequence
                            (Sset _t'22
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Econst_int (Int.repr 34) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Osub (Etempvar _t'21 tfloat)
                                (Ebinop Odiv (Etempvar _t'22 tint)
                                  (Econst_int (Int.repr 256) tint) tint)
                                tfloat))))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'8)
                              (Evar _segmented_to_virtual (Tfunction
                                                            ((tptr tvoid) ::
                                                             nil)
                                                            (tptr tvoid)
                                                            cc_default))
                              ((Evar _bhvTree (tarray tuint 0)) :: nil))
                            (Ssequence
                              (Sset _t'16
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _usedObj
                                  (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'17
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _behavior
                                    (tptr tuint)))
                                (Sifthenelse (Ebinop Oeq
                                               (Etempvar _t'17 (tptr tuint))
                                               (Etempvar _t'8 (tptr tvoid))
                                               tint)
                                  (Ssequence
                                    (Sset _t'18
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _pos (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat))
                                    (Ssequence
                                      (Sset _t'19
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _floorHeight tfloat))
                                      (Sifthenelse (Ebinop Ogt
                                                     (Ebinop Osub
                                                       (Etempvar _t'18 tfloat)
                                                       (Etempvar _t'19 tfloat)
                                                       tfloat)
                                                     (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                     tint)
                                        (Ssequence
                                          (Sset _t'20
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _particleFlags tuint))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _particleFlags tuint)
                                            (Ebinop Oor
                                              (Etempvar _t'20 tuint)
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 13) tint)
                                                tint) tuint)))
                                        Sskip)))
                                  Sskip))))
                          (Ssequence
                            (Scall None
                              (Evar _play_climbing_sounds (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 2) tint) :: nil))
                            (Ssequence
                              (Sset _t'15
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 33) tint)
                                    (tptr tint)) tint))
                              (Scall None
                                (Evar _set_sound_moving_speed (Tfunction
                                                                (tuchar ::
                                                                 tuchar ::
                                                                 nil) tvoid
                                                                cc_default))
                                ((Econst_int (Int.repr 1) tint) ::
                                 (Ebinop Omul
                                   (Ebinop Odiv (Etempvar _t'15 tint)
                                     (Econst_int (Int.repr 256) tint) tint)
                                   (Econst_int (Int.repr 2) tint) tint) ::
                                 nil)))))))))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 33) tint) (tptr tint)) tint)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _controller
                          (tptr (Tstruct _Controller noattr))))
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _t'13 (tptr (Tstruct _Controller noattr)))
                              (Tstruct _Controller noattr)) _stickX tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort)
                          (Ebinop Osub (Etempvar _t'12 tshort)
                            (Ebinop Omul (Etempvar _t'14 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                              tfloat) tfloat)))))))))
          (Ssequence
            (Ssequence
              (Scall (Some _t'9)
                (Evar _set_pole_position (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tfloat :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 nil))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 13) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_climbing_pole := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp24, tint) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_cameraAngle, tshort) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'19, tshort) :: (_t'18, (tptr (Tstruct _Camera noattr))) ::
               (_t'17, (tptr (Tstruct _Area noattr))) :: (_t'16, tshort) ::
               (_t'15, tshort) :: (_t'14, tushort) :: (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Controller noattr))) ::
               (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Controller noattr))) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _Controller noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _area
          (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _t'17 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _camera
            (tptr (Tstruct _Camera noattr))))
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _t'18 (tptr (Tstruct _Camera noattr)))
                (Tstruct _Camera noattr)) _yaw tshort))
          (Sset _cameraAngle (Ecast (Etempvar _t'19 tshort) tshort)))))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _health tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'16 tshort)
                       (Econst_int (Int.repr 256) tint) tint)
          (Ssequence
            (Scall None
              (Evar _add_tree_leaf_particles (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Eunop Oneg
                  (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                  tfloat))
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16910518) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'1 tuint))))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall None
                (Evar _add_tree_leaf_particles (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Oadd (Etempvar _t'15 tshort)
                      (Econst_int (Int.repr 32768) tint) tint)))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 50333830) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'2 tuint))))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _controller
                (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef
                    (Etempvar _t'12 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _stickY tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'13 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                             tint)
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 135267136) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tuint))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Econst_int (Int.repr 34) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _t'10 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickY tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat)
                    (Ebinop Oadd (Etempvar _t'9 tfloat)
                      (Ebinop Odiv (Etempvar _t'11 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                        tfloat) tfloat)))))
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 33) tint) (tptr tint)) tint)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Scall (Some _t'4)
                      (Evar _approach_s32 (Tfunction
                                            (tint :: tint :: tint :: tint ::
                                             nil) tint cc_default))
                      ((Ecast
                         (Ebinop Osub (Etempvar _cameraAngle tshort)
                           (Etempvar _t'8 tshort) tint) tshort) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 1024) tint) ::
                       (Econst_int (Int.repr 1024) tint) :: nil)))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Osub (Etempvar _cameraAngle tshort)
                      (Etempvar _t'4 tint) tint)))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _set_pole_position (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tint
                                                 cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tint)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _controller
                              (tptr (Tstruct _Controller noattr))))
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Etempvar _t'6 (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr)) _stickY
                                tfloat))
                            (Sset _sp24
                              (Ecast
                                (Ebinop Omul
                                  (Ebinop Odiv (Etempvar _t'7 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                    tfloat)
                                  (Econst_int (Int.repr 65536) tint) tfloat)
                                tint))))
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_anim_with_accel (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tint ::
                                                                tint :: nil)
                                                               tshort
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 5) tint) ::
                             (Etempvar _sp24 tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _add_tree_leaf_particles (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Scall None
                              (Evar _play_climbing_sounds (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tint :: nil)
                                                            tvoid cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 1) tint) :: nil)))))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_grab_pole_slow := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_sound_if_no_flag (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 131072) tint) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _set_pole_position (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tfloat :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 6) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'1 tint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 135267136) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Scall None
              (Evar _add_tree_leaf_particles (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_grab_pole_fast := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'6, tint) ::
               (_t'5, tshort) :: (_t'4, tint) :: (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Scall None
      (Evar _play_sound_if_no_flag (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'5 tshort) (Etempvar _t'6 tint) tint))))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 33) tint) (tptr tint)) tint)
            (Ebinop Odiv
              (Ebinop Omul (Etempvar _t'4 tint)
                (Econst_int (Int.repr 8) tint) tint)
              (Econst_int (Int.repr 10) tint) tint)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_pole_position (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 33) tint) (tptr tint)) tint))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tint)
                                 (Econst_int (Int.repr 2048) tint) tint)
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 7) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 8) tint) :: nil))
                      (Ssequence
                        (Scall (Some _t'1)
                          (Evar _is_anim_at_end (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'1 tint)
                          (Ssequence
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint)
                              (Econst_int (Int.repr 0) tint))
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 135267136) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))
                          Sskip)))))
                (Scall None
                  (Evar _add_tree_leaf_particles (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_top_of_pole_transition := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tshort) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Efield
              (Ederef (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
            _asS32 (tarray tint 80)) (Econst_int (Int.repr 33) tint)
          (tptr tint)) tint) (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tuint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 11) tint) :: nil))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'2 tint)
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1049413) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'1 tuint))))
                Sskip)))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 12) tint) :: nil))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _animFrame tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 135267136) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'3 tuint))))
                  Sskip))))))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _return_mario_anim_y_translation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Scall None
            (Evar _set_pole_position (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'4 tshort) :: nil)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_top_of_pole := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'3, tshort) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'9, tushort) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Controller noattr))) ::
               (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _Controller noattr))) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 50333837) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _controller
            (tptr (Tstruct _Controller noattr))))
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _t'7 (tptr (Tstruct _Controller noattr)))
                (Tstruct _Controller noattr)) _stickY tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'8 tfloat)
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                           tfloat) tint)
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 1049412) tint) ::
                 (Econst_int (Int.repr 1) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _controller
                (tptr (Tstruct _Controller noattr))))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _t'5 (tptr (Tstruct _Controller noattr)))
                    (Tstruct _Controller noattr)) _stickX tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Osub (Etempvar _t'4 tshort)
                  (Ebinop Omul (Etempvar _t'6 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                    tfloat) tfloat)))))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 9) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _return_mario_anim_y_translation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tshort
                                                         cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Scall None
                (Evar _set_pole_position (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tfloat :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _t'3 tshort) :: nil)))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_perform_hanging_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_nextPos, (tptr tfloat)) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) ::
              (_ceil, (tptr (Tstruct _Surface noattr))) ::
              (_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_ceilHeight, tfloat) :: (_floorHeight, tfloat) ::
               (_ceilOffset, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _Surface noattr))) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Surface noattr))) ::
               (_t'4, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _resolve_and_return_wall_collisions (Tfunction
                                                  ((tptr tfloat) :: tfloat ::
                                                   tfloat :: nil)
                                                  (tptr (Tstruct _Surface noattr))
                                                  cc_default))
      ((Etempvar _nextPos (tptr tfloat)) ::
       (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
       (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) :: nil))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _wall
        (tptr (Tstruct _Surface noattr)))
      (Etempvar _t'1 (tptr (Tstruct _Surface noattr)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'13
            (Ederef
              (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Scall (Some _t'2)
              (Evar _find_floor (Tfunction
                                  (tfloat :: tfloat :: tfloat ::
                                   (tptr (tptr (Tstruct _Surface noattr))) ::
                                   nil) tfloat cc_default))
              ((Etempvar _t'12 tfloat) :: (Etempvar _t'13 tfloat) ::
               (Etempvar _t'14 tfloat) ::
               (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                 (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
      (Sset _floorHeight (Etempvar _t'2 tfloat)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _vec3f_find_ceil (Tfunction
                                   ((tptr tfloat) :: tfloat ::
                                    (tptr (tptr (Tstruct _Surface noattr))) ::
                                    nil) tfloat cc_default))
          ((Etempvar _nextPos (tptr tfloat)) ::
           (Etempvar _floorHeight tfloat) ::
           (Eaddrof (Evar _ceil (tptr (Tstruct _Surface noattr)))
             (tptr (tptr (Tstruct _Surface noattr)))) :: nil))
        (Sset _ceilHeight (Etempvar _t'3 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'11 (Evar _floor (tptr (Tstruct _Surface noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _ceil (tptr (Tstruct _Surface noattr))))
            (Sifthenelse (Ebinop Oeq
                           (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Sreturn (Some (Econst_int (Int.repr 2) tint)))
              Sskip))
          (Ssequence
            (Sifthenelse (Ebinop Ole
                           (Ebinop Osub (Etempvar _ceilHeight tfloat)
                             (Etempvar _floorHeight tfloat) tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                           tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip)
            (Ssequence
              (Ssequence
                (Sset _t'8 (Evar _ceil (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _type tshort))
                  (Sifthenelse (Ebinop One (Etempvar _t'9 tshort)
                                 (Econst_int (Int.repr 5) tint) tint)
                    (Sreturn (Some (Econst_int (Int.repr 2) tint)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                  (Sset _ceilOffset
                    (Ebinop Osub (Etempvar _ceilHeight tfloat)
                      (Ebinop Oadd (Etempvar _t'7 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                        tfloat) tfloat)))
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _ceilOffset tfloat)
                                 (Eunop Oneg
                                   (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                                   tfloat) tint)
                    (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                    Sskip)
                  (Ssequence
                    (Sifthenelse (Ebinop Ogt (Etempvar _ceilOffset tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                                   tint)
                      (Sreturn (Some (Econst_int (Int.repr 2) tint)))
                      Sskip)
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _ceilHeight
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Osub (Etempvar _t'6 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                            tfloat)))
                      (Ssequence
                        (Scall None
                          (Evar _vec3f_copy (Tfunction
                                              ((tptr tfloat) ::
                                               (tptr tfloat) :: nil)
                                              (tptr tvoid) cc_default))
                          ((Efield
                             (Ederef
                               (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                               (Tstruct _MarioState noattr)) _pos
                             (tarray tfloat 3)) ::
                           (Etempvar _nextPos (tptr tfloat)) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Evar _floor (tptr (Tstruct _Surface noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _floor
                                (tptr (Tstruct _Surface noattr)))
                              (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))))
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _floorHeight
                                tfloat) (Etempvar _floorHeight tfloat))
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
                                  (Evar _ceil (tptr (Tstruct _Surface noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _ceil
                                    (tptr (Tstruct _Surface noattr)))
                                  (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _ceilHeight tfloat)
                                  (Etempvar _ceilHeight tfloat))
                                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))))))
|}.

Definition f_update_hang_moving := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_nextPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_stepResult, tint) :: (_maxSpeed, tfloat) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'28, tfloat) :: (_t'27, tfloat) ::
               (_t'26, tshort) :: (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, tshort) :: (_t'22, tfloat) :: (_t'21, tshort) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tshort) ::
               (_t'17, tfloat) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tshort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _maxSpeed
    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat))
  (Ssequence
    (Ssequence
      (Sset _t'28
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat)
        (Ebinop Oadd (Etempvar _t'28 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
          tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'27
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'27 tfloat)
                       (Etempvar _maxSpeed tfloat) tint)
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _maxSpeed tfloat))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'25
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedYaw tshort))
            (Ssequence
              (Sset _t'26
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Scall (Some _t'1)
                (Evar _approach_s32 (Tfunction
                                      (tint :: tint :: tint :: tint :: nil)
                                      tint cc_default))
                ((Ecast
                   (Ebinop Osub (Etempvar _t'25 tshort)
                     (Etempvar _t'26 tshort) tint) tshort) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 2048) tint) ::
                 (Econst_int (Int.repr 2048) tint) :: nil))))
          (Ssequence
            (Sset _t'24
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedYaw tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort)
              (Ebinop Osub (Etempvar _t'24 tshort) (Etempvar _t'1 tint) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'23
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _slideYaw tshort)
              (Etempvar _t'23 tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Ssequence
                (Sset _t'21
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'22
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr (Ecast (Etempvar _t'21 tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelX tfloat)
                    (Ebinop Omul (Etempvar _t'20 tfloat)
                      (Etempvar _t'22 tfloat) tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Ssequence
                  (Sset _t'18
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'19
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _t'18 tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                      (Ebinop Omul (Etempvar _t'17 tfloat)
                        (Etempvar _t'19 tfloat) tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelX tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat) (Etempvar _t'16 tfloat)))
                (Ssequence
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                  (Ssequence
                    (Ssequence
                      (Sset _t'15
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'15 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'11
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat))
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _ceil
                              (tptr (Tstruct _Surface noattr))))
                          (Ssequence
                            (Sset _t'13
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _normal
                                  (Tstruct __670 noattr)) _y tfloat))
                            (Ssequence
                              (Sset _t'14
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _vel
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _nextPos (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Ebinop Osub (Etempvar _t'11 tfloat)
                                  (Ebinop Omul (Etempvar _t'13 tfloat)
                                    (Etempvar _t'14 tfloat) tfloat) tfloat))))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Ssequence
                            (Sset _t'8
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _ceil
                                (tptr (Tstruct _Surface noattr))))
                            (Ssequence
                              (Sset _t'9
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _normal
                                    (Tstruct __670 noattr)) _y tfloat))
                              (Ssequence
                                (Sset _t'10
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _vel
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _nextPos (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Osub (Etempvar _t'7 tfloat)
                                    (Ebinop Omul (Etempvar _t'9 tfloat)
                                      (Etempvar _t'10 tfloat) tfloat) tfloat))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _nextPos (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Etempvar _t'6 tfloat)))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'2)
                                (Evar _perform_hanging_step (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               (tptr tfloat) ::
                                                               nil) tint
                                                              cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Evar _nextPos (tarray tfloat 3)) :: nil))
                              (Sset _stepResult (Etempvar _t'2 tint)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'5
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Scall None
                                  (Evar _vec3f_copy (Tfunction
                                                      ((tptr tfloat) ::
                                                       (tptr tfloat) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                                  ((Efield
                                     (Efield
                                       (Efield
                                         (Ederef
                                           (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                           (Tstruct _Object noattr)) _header
                                         (Tstruct _ObjectNode noattr)) _gfx
                                       (Tstruct _GraphNodeObject noattr))
                                     _pos (tarray tfloat 3)) ::
                                   (Efield
                                     (Ederef
                                       (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                       (Tstruct _MarioState noattr)) _pos
                                     (tarray tfloat 3)) :: nil)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'3
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _marioObj
                                      (tptr (Tstruct _Object noattr))))
                                  (Ssequence
                                    (Sset _t'4
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort))
                                    (Scall None
                                      (Evar _vec3s_set (Tfunction
                                                         ((tptr tshort) ::
                                                          tshort :: tshort ::
                                                          tshort :: nil)
                                                         (tptr tvoid)
                                                         cc_default))
                                      ((Efield
                                         (Efield
                                           (Efield
                                             (Ederef
                                               (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                               (Tstruct _Object noattr))
                                             _header
                                             (Tstruct _ObjectNode noattr))
                                           _gfx
                                           (Tstruct _GraphNodeObject noattr))
                                         _angle (tarray tshort 3)) ::
                                       (Econst_int (Int.repr 0) tint) ::
                                       (Etempvar _t'4 tshort) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))))
                                (Sreturn (Some (Etempvar _stepResult tint)))))))))))))))))))
|}.

Definition f_update_hang_stationary := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tfloat) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _forwardVel tfloat)
    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _slideVelX tfloat)
      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _slideVelZ tfloat)
        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _ceilHeight tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Ebinop Osub (Etempvar _t'2 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
              tfloat)))
        (Ssequence
          (Scall None
            (Evar _vec3f_copy (Tfunction
                                ((tptr tfloat) :: (tptr tfloat) :: nil)
                                (tptr tvoid) cc_default))
            ((Efield
               (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                 (Tstruct _MarioState noattr)) _vel (tarray tfloat 3)) ::
             (Evar _gVec3fZero (tarray tfloat 3)) :: nil))
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
               (Efield
                 (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                   (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
               nil))))))))
|}.

Definition f_act_start_hanging := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tuint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'13, tushort) :: (_t'12, tushort) :: (_t'11, tushort) ::
               (_t'10, tushort) :: (_t'9, tushort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort)
      (Ebinop Oadd (Etempvar _t'13 tushort) (Econst_int (Int.repr 1) tint)
        tint)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'2
              (Ecast
                (Ebinop Oge (Etempvar _t'12 tushort)
                  (Econst_int (Int.repr 31) tint) tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 2097993) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'10 tushort)
                         (Econst_int (Int.repr 128) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779404) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                         (Econst_int (Int.repr 32768) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 8390825) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _ceil
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _type tshort))
              (Sifthenelse (Ebinop One (Etempvar _t'8 tshort)
                             (Econst_int (Int.repr 5) tint) tint)
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 16779404) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'5 tuint))))
                Sskip)))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 53) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _play_sound_if_no_flag (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 45) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 160) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 65536) tint) :: nil))
              (Ssequence
                (Scall None
                  (Evar _update_hang_stationary (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'6 tint)
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 2097993) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_hanging := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'11, tuint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) :: (_t'5, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 2098506) tint) ::
             (Etempvar _t'11 tuint) :: nil)))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 128) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                       (Econst_int (Int.repr 32768) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 8390825) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _ceil
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sifthenelse (Ebinop One (Etempvar _t'7 tshort)
                           (Econst_int (Int.repr 5) tint) tint)
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16779404) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'4 tuint))))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                           (Econst_int (Int.repr 1) tint) tuint)
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 198) tint) :: nil))
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 199) tint) :: nil))))
          (Ssequence
            (Scall None
              (Evar _update_hang_stationary (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hang_moving := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'17, tushort) :: (_t'16, tushort) :: (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _Surface noattr))) :: (_t'13, tuint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'17
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'17 tushort)
                     (Econst_int (Int.repr 128) tint) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 16779404) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                     (Econst_int (Int.repr 32768) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 8390825) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _ceil
            (tptr (Tstruct _Surface noattr))))
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _t'14 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _type tshort))
          (Sifthenelse (Ebinop One (Etempvar _t'15 tshort)
                         (Econst_int (Int.repr 5) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16779404) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'13 tuint)
                         (Econst_int (Int.repr 1) tint) tuint)
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 92) tint) :: nil))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 93) tint) :: nil))))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animFrame tshort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tshort)
                             (Econst_int (Int.repr 12) tint) tint)
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 45) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 160) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                Sskip)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'5)
                (Evar _is_anim_past_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'5 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint)
                      (Ebinop Oxor (Etempvar _t'9 tuint)
                        (Econst_int (Int.repr 1) tint) tuint)))
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                                   (Econst_int (Int.repr 32) tint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionArg
                              tuint))
                          (Scall (Some _t'4)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 2097993) tint) ::
                             (Etempvar _t'8 tuint) :: nil)))
                        (Sreturn (Some (Etempvar _t'4 tuint))))
                      Sskip)))
                Sskip))
            (Ssequence
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _update_hang_moving (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tint)
                               (Econst_int (Int.repr 2) tint) tint)
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 16779404) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_let_go_of_ledge := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) :: (_t'2, tuint) :: (_t'1, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Ederef
      (Ebinop Oadd
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
        (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat)
      (Eunop Oneg
        (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
        tfloat))
    (Ssequence
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'12
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'13
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _t'12 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Osub (Etempvar _t'11 tfloat)
                (Ebinop Omul
                  (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                  (Etempvar _t'13 tfloat) tfloat) tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'9
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'10
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'9 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                (Ebinop Osub (Etempvar _t'8 tfloat)
                  (Ebinop Omul
                    (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                    (Etempvar _t'10 tfloat) tfloat) tfloat)))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat))
                  (Scall (Some _t'1)
                    (Evar _find_floor (Tfunction
                                        (tfloat :: tfloat :: tfloat ::
                                         (tptr (tptr (Tstruct _Surface noattr))) ::
                                         nil) tfloat cc_default))
                    ((Etempvar _t'5 tfloat) :: (Etempvar _t'6 tfloat) ::
                     (Etempvar _t'7 tfloat) ::
                     (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                       (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
            (Sset _floorHeight (Etempvar _t'1 tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _floorHeight tfloat)
                             (Ebinop Osub (Etempvar _t'3 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                               tfloat) tint)
                (Ssequence
                  (Sset _t'4
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Ebinop Osub (Etempvar _t'4 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                      tfloat)))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat) (Etempvar _floorHeight tfloat))))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16910518) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint))))))))))
|}.

Definition f_climb_up_ledge := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tfloat) :: (_t'6, tshort) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _set_mario_animation (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tint :: nil) tshort cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 195) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'6
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'7
            (Ederef
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Ebinop Oshr (Ecast (Etempvar _t'6 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
            (Ebinop Oadd (Etempvar _t'5 tfloat)
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1096810496)) tfloat)
                (Etempvar _t'7 tfloat) tfloat) tfloat)))))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                  (Ebinop Oshr (Ecast (Etempvar _t'3 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'2 tfloat)
                (Ebinop Omul
                  (Econst_single (Float32.of_bits (Int.repr 1096810496)) tfloat)
                  (Etempvar _t'4 tfloat) tfloat) tfloat)))))
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _vec3f_copy (Tfunction
                              ((tptr tfloat) :: (tptr tfloat) :: nil)
                              (tptr tvoid) cc_default))
          ((Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil))))))
|}.

Definition f_update_ledge_climb_camera := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp4, tfloat) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tfloat) :: (_t'11, tshort) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'8, tfloat) :: (_t'7, tshort) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'2, tushort) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Olt (Etempvar _t'13 tushort)
                   (Econst_int (Int.repr 14) tint) tint)
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sset _sp4 (Ecast (Etempvar _t'14 tushort) tfloat)))
      (Sset _sp4
        (Econst_single (Float32.of_bits (Int.repr 1096810496)) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _statusForCamera
          (tptr (Tstruct _PlayerCameraState noattr))))
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'11
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _t'11 tshort) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _t'9 (tptr (Tstruct _PlayerCameraState noattr)))
                      (Tstruct _PlayerCameraState noattr)) _pos
                    (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'10 tfloat)
                (Ebinop Omul (Etempvar _sp4 tfloat) (Etempvar _t'12 tfloat)
                  tfloat) tfloat))))))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _statusForCamera
            (tptr (Tstruct _PlayerCameraState noattr))))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'7 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _t'5 (tptr (Tstruct _PlayerCameraState noattr)))
                        (Tstruct _PlayerCameraState noattr)) _pos
                      (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                    (tptr tfloat)) tfloat)
                (Ebinop Oadd (Etempvar _t'6 tfloat)
                  (Ebinop Omul (Etempvar _sp4 tfloat) (Etempvar _t'8 tfloat)
                    tfloat) tfloat))))))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _statusForCamera
              (tptr (Tstruct _PlayerCameraState noattr))))
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _t'3 (tptr (Tstruct _PlayerCameraState noattr)))
                      (Tstruct _PlayerCameraState noattr)) _pos
                    (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tfloat)) tfloat) (Etempvar _t'4 tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Ebinop Oadd (Etempvar _t'2 tushort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Sset _t'1
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint)
              (Ebinop Oor (Etempvar _t'1 tuint)
                (Econst_int (Int.repr 33554432) tint) tuint))))))))
|}.

Definition f_update_ledge_climb := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_endAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stop_and_set_height_to_floor (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animation tint) :: nil))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _is_anim_at_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Ssequence
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _endAction tuint) :: (Econst_int (Int.repr 0) tint) ::
             nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _endAction tuint)
                         (Econst_int (Int.repr 205521409) tint) tint)
            (Scall None
              (Evar _climb_up_ledge (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            Sskip))
        Sskip))))
|}.

Definition f_act_ledge_grab := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_heightAboveFloor, tfloat) :: (_intendedDYaw, tshort) ::
               (_hasSpaceForMario, tint) :: (_t'13, tint) ::
               (_t'12, tuint) :: (_t'11, tfloat) :: (_t'10, tint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tuint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'32, tshort) :: (_t'31, tshort) :: (_t'30, tfloat) ::
               (_t'29, tfloat) :: (_t'28, tushort) :: (_t'27, tushort) ::
               (_t'26, tfloat) ::
               (_t'25, (tptr (Tstruct _Surface noattr))) ::
               (_t'24, tushort) :: (_t'23, tushort) :: (_t'22, tuint) ::
               (_t'21, tuchar) :: (_t'20, tint) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tushort) :: (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, tfloat) :: (_t'14, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'31
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedYaw tshort))
    (Ssequence
      (Sset _t'32
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _intendedDYaw
        (Ecast
          (Ebinop Osub (Etempvar _t'31 tshort) (Etempvar _t'32 tshort) tint)
          tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _ceilHeight tfloat))
      (Ssequence
        (Sset _t'30
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floorHeight tfloat))
        (Sset _hasSpaceForMario
          (Ebinop Oge
            (Ebinop Osub (Etempvar _t'29 tfloat) (Etempvar _t'30 tfloat)
              tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
            tint))))
    (Ssequence
      (Ssequence
        (Sset _t'27
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'27 tushort)
                       (Econst_int (Int.repr 10) tint) tint)
          (Ssequence
            (Sset _t'28
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Ebinop Oadd (Etempvar _t'28 tushort)
                (Econst_int (Int.repr 1) tint) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'25
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'26
              (Efield
                (Efield
                  (Ederef (Etempvar _t'25 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _normal
                  (Tstruct __670 noattr)) _y tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'26 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1063781322)) tfloat)
                           tint)
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _let_go_of_ledge (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sreturn (Some (Etempvar _t'1 tint))))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'24
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'24 tushort)
                           (Ebinop Oor (Econst_int (Int.repr 32768) tint)
                             (Econst_int (Int.repr 4) tint) tint) tint)
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _let_go_of_ledge (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sreturn (Some (Etempvar _t'2 tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'23
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'23 tushort)
                               (Econst_int (Int.repr 2) tint) tint)
                  (Sset _t'4 (Ecast (Etempvar _hasSpaceForMario tint) tbool))
                  (Sset _t'4 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'4 tint)
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1359) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tuint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                               (Econst_int (Int.repr 1024) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'19
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioObj
                          (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'20
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 43) tint) (tptr tint))
                            tint))
                        (Sifthenelse (Ebinop Oand (Etempvar _t'20 tint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 1) tint) tint)
                                       tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'22
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _flags
                                  tuint))
                              (Sifthenelse (Ebinop Oand
                                             (Etempvar _t'22 tuint)
                                             (Econst_int (Int.repr 16) tint)
                                             tuint)
                                (Sset _t'5
                                  (Ecast (Econst_int (Int.repr 12) tint)
                                    tint))
                                (Sset _t'5
                                  (Ecast (Econst_int (Int.repr 18) tint)
                                    tint))))
                            (Ssequence
                              (Sset _t'21
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _hurtCounter tuchar))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _hurtCounter tuchar)
                                (Ebinop Oadd (Etempvar _t'21 tuchar)
                                  (Etempvar _t'5 tint) tint))))
                          Sskip)))
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _let_go_of_ledge (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sreturn (Some (Etempvar _t'6 tint)))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'16 tushort)
                                   (Econst_int (Int.repr 10) tint) tint)
                      (Ssequence
                        (Sset _t'17
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _input tushort))
                        (Sset _t'10
                          (Ecast
                            (Ebinop Oand (Etempvar _t'17 tushort)
                              (Econst_int (Int.repr 1) tint) tint) tbool)))
                      (Sset _t'10 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'10 tint)
                    (Ssequence
                      (Sifthenelse (Ebinop Oge
                                     (Etempvar _intendedDYaw tshort)
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 16384) tint)
                                       tint) tint)
                        (Sset _t'9
                          (Ecast
                            (Ebinop Ole (Etempvar _intendedDYaw tshort)
                              (Econst_int (Int.repr 16384) tint) tint) tbool))
                        (Sset _t'9 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'9 tint)
                        (Sifthenelse (Etempvar _hasSpaceForMario tint)
                          (Ssequence
                            (Scall (Some _t'7)
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 1356) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Sreturn (Some (Etempvar _t'7 tuint))))
                          Sskip)
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _let_go_of_ledge (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sreturn (Some (Etempvar _t'8 tint))))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'11)
                      (Evar _find_floor_height_relative_polar (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tshort ::
                                                                 tfloat ::
                                                                 nil) tfloat
                                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Eunop Oneg (Econst_int (Int.repr 32768) tint) tint) ::
                       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                       nil))
                    (Ssequence
                      (Sset _t'15
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sset _heightAboveFloor
                        (Ebinop Osub (Etempvar _t'15 tfloat)
                          (Etempvar _t'11 tfloat) tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Etempvar _hasSpaceForMario tint)
                        (Sset _t'13
                          (Ecast
                            (Ebinop Olt (Etempvar _heightAboveFloor tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                              tint) tbool))
                        (Sset _t'13 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'13 tint)
                        (Ssequence
                          (Scall (Some _t'12)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 1359) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'12 tuint))))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tuint)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Scall None
                            (Evar _play_sound_if_no_flag (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tuint :: tuint ::
                                                            nil) tvoid
                                                           cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 2) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 8) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 192) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Econst_int (Int.repr 131072) tint) :: nil))
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _stop_and_set_height_to_floor (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tvoid
                                                                cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 51) tint) :: nil))
                          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))
|}.

Definition f_act_ledge_climb_slow := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tushort) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 4) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _let_go_of_ledge (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oge (Etempvar _t'7 tushort)
                       (Econst_int (Int.repr 28) tint) tint)
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oand (Etempvar _t'8 tushort)
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 2) tint) tint)
                      (Econst_int (Int.repr 4) tint) tint)
                    (Econst_int (Int.repr 8) tint) tint) tint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall None
            (Evar _climb_up_ledge (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall (Some _t'2)
              (Evar _check_common_action_exits (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint)))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 10) tint) tint)
          (Scall None
            (Evar _play_sound_if_no_flag (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: tuint :: nil) tvoid
                                           cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 2) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 9) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Econst_int (Int.repr 131072) tint) :: nil))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _update_ledge_climb (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tuint :: nil) tvoid
                                      cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 0) tint) ::
           (Econst_int (Int.repr 205521409) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _update_ledge_climb_camera (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _animFrame tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                               (Econst_int (Int.repr 17) tint) tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint)
                    (Econst_int (Int.repr 1357) tint))
                  Sskip)))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_ledge_climb_down := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 4) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _let_go_of_ledge (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_sound_if_no_flag (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_ledge_climb (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 28) tint) ::
         (Econst_int (Int.repr 134218571) tint) :: nil))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint)
          (Econst_int (Int.repr 1) tint))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_ledge_climb_fast := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tushort) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 4) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _let_go_of_ledge (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_sound_if_no_flag (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 19) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 208) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_ledge_climb (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 52) tint) ::
         (Econst_int (Int.repr 205521409) tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tshort)
                           (Econst_int (Int.repr 8) tint) tint)
              (Scall None
                (Evar _play_mario_landing_sound (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: nil) tvoid
                                                  cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 8) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) :: nil))
              Sskip)))
        (Ssequence
          (Scall None
            (Evar _update_ledge_climb_camera (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_grabbed := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_thrown, tint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'10, tint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tint) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               (_t'4, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'4
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'4 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 2) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'10
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint))
              (Sset _thrown
                (Ebinop Oeq
                  (Ebinop Oand (Etempvar _t'10 tint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 6) tint) tint) tint)
                  (Econst_int (Int.repr 0) tint) tint))))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _usedObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                        (Econst_int (Int.repr 1) tint) tint) (tptr tint))
                    tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort) (Etempvar _t'8 tint))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _vec3f_copy (Tfunction
                                      ((tptr tfloat) :: (tptr tfloat) :: nil)
                                      (tptr tvoid) cc_default))
                  ((Efield
                     (Ederef
                       (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                       (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _pos
                     (tarray tfloat 3)) :: nil)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                   tint)
                      (Sset _t'1
                        (Ecast (Econst_int (Int.repr 16910525) tint) tint))
                      (Sset _t'1
                        (Ecast (Econst_int (Int.repr 16910526) tint) tint))))
                  (Scall (Some _t'2)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'1 tint) :: (Etempvar _thrown tint) :: nil)))
                (Sreturn (Some (Etempvar _t'2 tuint)))))))
        Sskip)))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 88) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_in_cannon := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_startFacePitch, tshort) :: (_startFaceYaw, tshort) ::
               (_t'1, tint) :: (_t'67, tshort) :: (_t'66, tshort) ::
               (_t'65, tshort) :: (_t'64, (tptr (Tstruct _Object noattr))) ::
               (_t'63, (tptr (Tstruct _Object noattr))) ::
               (_t'62, (tptr (Tstruct _Object noattr))) ::
               (_t'61, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'60, (tptr (Tstruct _Object noattr))) ::
               (_t'59, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'58, tfloat) :: (_t'57, (tptr (Tstruct _Object noattr))) ::
               (_t'56, tfloat) :: (_t'55, (tptr (Tstruct _Object noattr))) ::
               (_t'54, tfloat) :: (_t'53, (tptr (Tstruct _Object noattr))) ::
               (_t'52, tint) :: (_t'51, (tptr (Tstruct _Object noattr))) ::
               (_t'50, tint) :: (_t'49, (tptr (Tstruct _Object noattr))) ::
               (_t'48, tint) :: (_t'47, (tptr (Tstruct _Object noattr))) ::
               (_t'46, tint) :: (_t'45, (tptr (Tstruct _Object noattr))) ::
               (_t'44, tfloat) ::
               (_t'43, (tptr (Tstruct _Controller noattr))) ::
               (_t'42, tshort) :: (_t'41, tfloat) ::
               (_t'40, (tptr (Tstruct _Controller noattr))) ::
               (_t'39, tint) :: (_t'38, tshort) :: (_t'37, tshort) ::
               (_t'36, tint) :: (_t'35, tint) :: (_t'34, tint) ::
               (_t'33, tint) :: (_t'32, tfloat) :: (_t'31, tshort) ::
               (_t'30, tfloat) :: (_t'29, tshort) :: (_t'28, tfloat) ::
               (_t'27, tshort) :: (_t'26, tfloat) :: (_t'25, tshort) ::
               (_t'24, tfloat) :: (_t'23, tfloat) :: (_t'22, tshort) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tshort) ::
               (_t'18, tfloat) :: (_t'17, tshort) :: (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tshort) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tushort) :: (_t'5, tushort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'67
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sset _startFacePitch (Ecast (Etempvar _t'67 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Sset _t'66
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _startFaceYaw (Ecast (Etempvar _t'66 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sswitch (Etempvar _t'5 tushort)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'63
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'64
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'65
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'64 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort))
                      (Sassign
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'63 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oand (Etempvar _t'65 tshort)
                          (Eunop Onotint
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 0) tint) tint) tint)
                          tint)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'62
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _usedObj
                        (tptr (Tstruct _Object noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'62 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 15) tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'61
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _statusForCamera
                          (tptr (Tstruct _PlayerCameraState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'61 (tptr (Tstruct _PlayerCameraState noattr)))
                            (Tstruct _PlayerCameraState noattr)) _cameraEvent
                          tshort) (Econst_int (Int.repr 1) tint)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'59
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _statusForCamera
                            (tptr (Tstruct _PlayerCameraState noattr))))
                        (Ssequence
                          (Sset _t'60
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _usedObj
                              (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'59 (tptr (Tstruct _PlayerCameraState noattr)))
                                (Tstruct _PlayerCameraState noattr)) _usedObj
                              (tptr (Tstruct _Object noattr)))
                            (Etempvar _t'60 (tptr (Tstruct _Object noattr))))))
                      (Ssequence
                        (Scall None
                          (Evar _vec3f_set (Tfunction
                                             ((tptr tfloat) :: tfloat ::
                                              tfloat :: tfloat :: nil)
                                             (tptr tvoid) cc_default))
                          ((Efield
                             (Ederef
                               (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                               (Tstruct _MarioState noattr)) _vel
                             (tarray tfloat 3)) ::
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'57
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _usedObj
                                (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'58
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'57 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asF32
                                      (tarray tfloat 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _pos
                                      (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Etempvar _t'58 tfloat))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'55
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _usedObj
                                  (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'56
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'55 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asF32 (tarray tfloat 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 6) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Oadd (Etempvar _t'56 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1135542272)) tfloat)
                                    tfloat))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'53
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _usedObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'54
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'53 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asF32 (tarray tfloat 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 6) tint)
                                          (Econst_int (Int.repr 2) tint)
                                          tint) (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _pos (tarray tfloat 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat)
                                    (Etempvar _t'54 tfloat))))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _forwardVel tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                (Ssequence
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort)
                                    (Econst_int (Int.repr 1) tint))
                                  Sbreak))))))))))
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Sset _t'45
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _usedObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'46
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'45 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asS32
                              (tarray tint 80))
                            (Econst_int (Int.repr 49) tint) (tptr tint))
                          tint))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'46 tint)
                                     (Econst_int (Int.repr 1) tint) tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'51
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _usedObj
                                (tptr (Tstruct _Object noattr))))
                            (Ssequence
                              (Sset _t'52
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'51 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 15) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    (tptr tint)) tint))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort)
                                (Etempvar _t'52 tint))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'49
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _usedObj
                                  (tptr (Tstruct _Object noattr))))
                              (Ssequence
                                (Sset _t'50
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'49 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 15) tint)
                                        (Econst_int (Int.repr 1) tint) tint)
                                      (tptr tint)) tint))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _faceAngle (tarray tshort 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort)
                                  (Etempvar _t'50 tint))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'47
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _usedObj
                                    (tptr (Tstruct _Object noattr))))
                                (Ssequence
                                  (Sset _t'48
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'47 (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asS32 (tarray tint 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 15) tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) (tptr tint)) tint))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 33) tint)
                                        (tptr tint)) tint)
                                    (Etempvar _t'48 tint))))
                              (Ssequence
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 34) tint)
                                      (tptr tint)) tint)
                                  (Econst_int (Int.repr 0) tint))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _actionState tushort)
                                  (Econst_int (Int.repr 2) tint))))))
                        Sskip)))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Sset _t'42
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _t'43
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _controller
                            (tptr (Tstruct _Controller noattr))))
                        (Ssequence
                          (Sset _t'44
                            (Efield
                              (Ederef
                                (Etempvar _t'43 (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _stickY tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort)
                            (Ebinop Osub (Etempvar _t'42 tshort)
                              (Ecast
                                (Ebinop Omul (Etempvar _t'44 tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                  tfloat) tshort) tint)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'39
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 34) tint) (tptr tint))
                            tint))
                        (Ssequence
                          (Sset _t'40
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _controller
                              (tptr (Tstruct _Controller noattr))))
                          (Ssequence
                            (Sset _t'41
                              (Efield
                                (Ederef
                                  (Etempvar _t'40 (tptr (Tstruct _Controller noattr)))
                                  (Tstruct _Controller noattr)) _stickX
                                tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 34) tint)
                                  (tptr tint)) tint)
                              (Ebinop Osub (Etempvar _t'39 tint)
                                (Ecast
                                  (Ebinop Omul (Etempvar _t'41 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                    tfloat) tshort) tint)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'38
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'38 tshort)
                                         (Econst_int (Int.repr 14563) tint)
                                         tint)
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tshort)) tshort)
                              (Econst_int (Int.repr 14563) tint))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Sset _t'37
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tshort)) tshort))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'37 tshort)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort)
                                (Econst_int (Int.repr 0) tint))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Sset _t'36
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asS32
                                      (tarray tint 80))
                                    (Econst_int (Int.repr 34) tint)
                                    (tptr tint)) tint))
                              (Sifthenelse (Ebinop Ogt (Etempvar _t'36 tint)
                                             (Econst_int (Int.repr 16384) tint)
                                             tint)
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 34) tint)
                                      (tptr tint)) tint)
                                  (Econst_int (Int.repr 16384) tint))
                                Sskip))
                            (Ssequence
                              (Ssequence
                                (Sset _t'35
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asS32 (tarray tint 80))
                                      (Econst_int (Int.repr 34) tint)
                                      (tptr tint)) tint))
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _t'35 tint)
                                               (Eunop Oneg
                                                 (Econst_int (Int.repr 16384) tint)
                                                 tint) tint)
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 34) tint)
                                        (tptr tint)) tint)
                                    (Eunop Oneg
                                      (Econst_int (Int.repr 16384) tint)
                                      tint))
                                  Sskip))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'33
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asS32 (tarray tint 80))
                                        (Econst_int (Int.repr 33) tint)
                                        (tptr tint)) tint))
                                  (Ssequence
                                    (Sset _t'34
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asS32 (tarray tint 80))
                                          (Econst_int (Int.repr 34) tint)
                                          (tptr tint)) tint))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tshort)) tshort)
                                      (Ebinop Oadd (Etempvar _t'33 tint)
                                        (Etempvar _t'34 tint) tint))))
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _input
                                      tushort))
                                  (Sifthenelse (Ebinop Oand
                                                 (Etempvar _t'6 tushort)
                                                 (Econst_int (Int.repr 2) tint)
                                                 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'31
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _faceAngle (tarray tshort 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort))
                                        (Ssequence
                                          (Sset _t'32
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ebinop Oadd
                                                  (Evar _gSineTable (tarray tfloat 0))
                                                  (Econst_int (Int.repr 1024) tint)
                                                  (tptr tfloat))
                                                (Ebinop Oshr
                                                  (Ecast
                                                    (Etempvar _t'31 tshort)
                                                    tushort)
                                                  (Econst_int (Int.repr 4) tint)
                                                  tint) (tptr tfloat))
                                              tfloat))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _forwardVel tfloat)
                                            (Ebinop Omul
                                              (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                              (Etempvar _t'32 tfloat) tfloat))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'29
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _faceAngle
                                                  (tarray tshort 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tshort)) tshort))
                                          (Ssequence
                                            (Sset _t'30
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _gSineTable (tarray tfloat 0))
                                                  (Ebinop Oshr
                                                    (Ecast
                                                      (Etempvar _t'29 tshort)
                                                      tushort)
                                                    (Econst_int (Int.repr 4) tint)
                                                    tint) (tptr tfloat))
                                                tfloat))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _vel (tarray tfloat 3))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr tfloat)) tfloat)
                                              (Ebinop Omul
                                                (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                (Etempvar _t'30 tfloat)
                                                tfloat))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'24
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _pos (tarray tfloat 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'25
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _faceAngle
                                                      (tarray tshort 3))
                                                    (Econst_int (Int.repr 0) tint)
                                                    (tptr tshort)) tshort))
                                              (Ssequence
                                                (Sset _t'26
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Ebinop Oadd
                                                        (Evar _gSineTable (tarray tfloat 0))
                                                        (Econst_int (Int.repr 1024) tint)
                                                        (tptr tfloat))
                                                      (Ebinop Oshr
                                                        (Ecast
                                                          (Etempvar _t'25 tshort)
                                                          tushort)
                                                        (Econst_int (Int.repr 4) tint)
                                                        tint) (tptr tfloat))
                                                    tfloat))
                                                (Ssequence
                                                  (Sset _t'27
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _faceAngle
                                                          (tarray tshort 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Ssequence
                                                    (Sset _t'28
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Evar _gSineTable (tarray tfloat 0))
                                                          (Ebinop Oshr
                                                            (Ecast
                                                              (Etempvar _t'27 tshort)
                                                              tushort)
                                                            (Econst_int (Int.repr 4) tint)
                                                            tint)
                                                          (tptr tfloat))
                                                        tfloat))
                                                    (Sassign
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _pos
                                                            (tarray tfloat 3))
                                                          (Econst_int (Int.repr 0) tint)
                                                          (tptr tfloat))
                                                        tfloat)
                                                      (Ebinop Oadd
                                                        (Etempvar _t'24 tfloat)
                                                        (Ebinop Omul
                                                          (Ebinop Omul
                                                            (Econst_single (Float32.of_bits (Int.repr 1123024896)) tfloat)
                                                            (Etempvar _t'26 tfloat)
                                                            tfloat)
                                                          (Etempvar _t'28 tfloat)
                                                          tfloat) tfloat)))))))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'21
                                                (Ederef
                                                  (Ebinop Oadd
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _pos (tarray tfloat 3))
                                                    (Econst_int (Int.repr 1) tint)
                                                    (tptr tfloat)) tfloat))
                                              (Ssequence
                                                (Sset _t'22
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _faceAngle
                                                        (tarray tshort 3))
                                                      (Econst_int (Int.repr 0) tint)
                                                      (tptr tshort)) tshort))
                                                (Ssequence
                                                  (Sset _t'23
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _gSineTable (tarray tfloat 0))
                                                        (Ebinop Oshr
                                                          (Ecast
                                                            (Etempvar _t'22 tshort)
                                                            tushort)
                                                          (Econst_int (Int.repr 4) tint)
                                                          tint)
                                                        (tptr tfloat))
                                                      tfloat))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _pos
                                                          (tarray tfloat 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tfloat))
                                                      tfloat)
                                                    (Ebinop Oadd
                                                      (Etempvar _t'21 tfloat)
                                                      (Ebinop Omul
                                                        (Econst_single (Float32.of_bits (Int.repr 1123024896)) tfloat)
                                                        (Etempvar _t'23 tfloat)
                                                        tfloat) tfloat)))))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'16
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _pos
                                                        (tarray tfloat 3))
                                                      (Econst_int (Int.repr 2) tint)
                                                      (tptr tfloat)) tfloat))
                                                (Ssequence
                                                  (Sset _t'17
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _faceAngle
                                                          (tarray tshort 3))
                                                        (Econst_int (Int.repr 0) tint)
                                                        (tptr tshort))
                                                      tshort))
                                                  (Ssequence
                                                    (Sset _t'18
                                                      (Ederef
                                                        (Ebinop Oadd
                                                          (Ebinop Oadd
                                                            (Evar _gSineTable (tarray tfloat 0))
                                                            (Econst_int (Int.repr 1024) tint)
                                                            (tptr tfloat))
                                                          (Ebinop Oshr
                                                            (Ecast
                                                              (Etempvar _t'17 tshort)
                                                              tushort)
                                                            (Econst_int (Int.repr 4) tint)
                                                            tint)
                                                          (tptr tfloat))
                                                        tfloat))
                                                    (Ssequence
                                                      (Sset _t'19
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _faceAngle
                                                              (tarray tshort 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tshort))
                                                          tshort))
                                                      (Ssequence
                                                        (Sset _t'20
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Ebinop Oadd
                                                                (Evar _gSineTable (tarray tfloat 0))
                                                                (Econst_int (Int.repr 1024) tint)
                                                                (tptr tfloat))
                                                              (Ebinop Oshr
                                                                (Ecast
                                                                  (Etempvar _t'19 tshort)
                                                                  tushort)
                                                                (Econst_int (Int.repr 4) tint)
                                                                tint)
                                                              (tptr tfloat))
                                                            tfloat))
                                                        (Sassign
                                                          (Ederef
                                                            (Ebinop Oadd
                                                              (Efield
                                                                (Ederef
                                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                                  (Tstruct _MarioState noattr))
                                                                _pos
                                                                (tarray tfloat 3))
                                                              (Econst_int (Int.repr 2) tint)
                                                              (tptr tfloat))
                                                            tfloat)
                                                          (Ebinop Oadd
                                                            (Etempvar _t'16 tfloat)
                                                            (Ebinop Omul
                                                              (Ebinop Omul
                                                                (Econst_single (Float32.of_bits (Int.repr 1123024896)) tfloat)
                                                                (Etempvar _t'18 tfloat)
                                                                tfloat)
                                                              (Etempvar _t'20 tfloat)
                                                              tfloat) tfloat)))))))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'15
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _marioObj
                                                      (tptr (Tstruct _Object noattr))))
                                                  (Scall None
                                                    (Evar _play_sound 
                                                    (Tfunction
                                                      (tint ::
                                                       (tptr tfloat) :: nil)
                                                      tvoid cc_default))
                                                    ((Ebinop Oor
                                                       (Ebinop Oor
                                                         (Ebinop Oor
                                                           (Ebinop Oor
                                                             (Ebinop Oshl
                                                               (Ecast
                                                                 (Econst_int (Int.repr 0) tint)
                                                                 tuint)
                                                               (Econst_int (Int.repr 28) tint)
                                                               tuint)
                                                             (Ebinop Oshl
                                                               (Ecast
                                                                 (Econst_int (Int.repr 86) tint)
                                                                 tuint)
                                                               (Econst_int (Int.repr 16) tint)
                                                               tuint) tuint)
                                                           (Ebinop Oshl
                                                             (Ecast
                                                               (Econst_int (Int.repr 128) tint)
                                                               tuint)
                                                             (Econst_int (Int.repr 8) tint)
                                                             tuint) tuint)
                                                         (Ebinop Oor
                                                           (Econst_int (Int.repr 67108864) tint)
                                                           (Econst_int (Int.repr 128) tint)
                                                           tint) tuint)
                                                       (Econst_int (Int.repr 1) tint)
                                                       tuint) ::
                                                     (Efield
                                                       (Efield
                                                         (Efield
                                                           (Ederef
                                                             (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                                             (Tstruct _Object noattr))
                                                           _header
                                                           (Tstruct _ObjectNode noattr))
                                                         _gfx
                                                         (Tstruct _GraphNodeObject noattr))
                                                       _cameraToObject
                                                       (tarray tfloat 3)) ::
                                                     nil)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'14
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _marioObj
                                                        (tptr (Tstruct _Object noattr))))
                                                    (Scall None
                                                      (Evar _play_sound 
                                                      (Tfunction
                                                        (tint ::
                                                         (tptr tfloat) ::
                                                         nil) tvoid
                                                        cc_default))
                                                      ((Ebinop Oor
                                                         (Ebinop Oor
                                                           (Ebinop Oor
                                                             (Ebinop Oor
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 5) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 28) tint)
                                                                 tuint)
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 26) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 16) tint)
                                                                 tuint)
                                                               tuint)
                                                             (Ebinop Oshl
                                                               (Ecast
                                                                 (Econst_int (Int.repr 80) tint)
                                                                 tuint)
                                                               (Econst_int (Int.repr 8) tint)
                                                               tuint) tuint)
                                                           (Econst_int (Int.repr 128) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tuint) ::
                                                       (Efield
                                                         (Efield
                                                           (Efield
                                                             (Ederef
                                                               (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                                               (Tstruct _Object noattr))
                                                             _header
                                                             (Tstruct _ObjectNode noattr))
                                                           _gfx
                                                           (Tstruct _GraphNodeObject noattr))
                                                         _cameraToObject
                                                         (tarray tfloat 3)) ::
                                                       nil)))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'11
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _marioObj
                                                          (tptr (Tstruct _Object noattr))))
                                                      (Ssequence
                                                        (Sset _t'12
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _marioObj
                                                            (tptr (Tstruct _Object noattr))))
                                                        (Ssequence
                                                          (Sset _t'13
                                                            (Efield
                                                              (Efield
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                  _gfx
                                                                  (Tstruct _GraphNodeObject noattr))
                                                                _node
                                                                (Tstruct _GraphNode noattr))
                                                              _flags tshort))
                                                          (Sassign
                                                            (Efield
                                                              (Efield
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                  _gfx
                                                                  (Tstruct _GraphNodeObject noattr))
                                                                _node
                                                                (Tstruct _GraphNode noattr))
                                                              _flags tshort)
                                                            (Ebinop Oor
                                                              (Etempvar _t'13 tshort)
                                                              (Ebinop Oshl
                                                                (Econst_int (Int.repr 1) tint)
                                                                (Econst_int (Int.repr 0) tint)
                                                                tint) tint)))))
                                                    (Ssequence
                                                      (Scall None
                                                        (Evar _set_mario_action 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         (Econst_int (Int.repr 8915096) tint) ::
                                                         (Econst_int (Int.repr 0) tint) ::
                                                         nil))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'10
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _usedObj
                                                              (tptr (Tstruct _Object noattr))))
                                                          (Sassign
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Efield
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                  _asS32
                                                                  (tarray tint 80))
                                                                (Econst_int (Int.repr 49) tint)
                                                                (tptr tint))
                                                              tint)
                                                            (Econst_int (Int.repr 2) tint)))
                                                        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'8
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _faceAngle (tarray tshort 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tshort)) tshort))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'8 tshort)
                                                       (Etempvar _startFacePitch tshort)
                                                       tint)
                                          (Sset _t'1
                                            (Econst_int (Int.repr 1) tint))
                                          (Ssequence
                                            (Sset _t'9
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _faceAngle
                                                    (tarray tshort 3))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr tshort)) tshort))
                                            (Sset _t'1
                                              (Ecast
                                                (Ebinop One
                                                  (Etempvar _t'9 tshort)
                                                  (Etempvar _startFaceYaw tshort)
                                                  tint) tbool)))))
                                      (Sifthenelse (Etempvar _t'1 tint)
                                        (Ssequence
                                          (Sset _t'7
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _marioObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Scall None
                                            (Evar _play_sound (Tfunction
                                                                (tint ::
                                                                 (tptr tfloat) ::
                                                                 nil) tvoid
                                                                cc_default))
                                            ((Ebinop Oor
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
                                                         (Econst_int (Int.repr 25) tint)
                                                         tuint)
                                                       (Econst_int (Int.repr 16) tint)
                                                       tuint) tuint)
                                                   (Ebinop Oshl
                                                     (Ecast
                                                       (Econst_int (Int.repr 32) tint)
                                                       tuint)
                                                     (Econst_int (Int.repr 8) tint)
                                                     tuint) tuint)
                                                 (Ebinop Oor
                                                   (Ebinop Oor
                                                     (Econst_int (Int.repr 16777216) tint)
                                                     (Econst_int (Int.repr 67108864) tint)
                                                     tint)
                                                   (Econst_int (Int.repr 134217728) tint)
                                                   tint) tuint)
                                               (Econst_int (Int.repr 1) tint)
                                               tuint) ::
                                             (Efield
                                               (Efield
                                                 (Efield
                                                   (Ederef
                                                     (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                                     (Tstruct _Object noattr))
                                                   _header
                                                   (Tstruct _ObjectNode noattr))
                                                 _gfx
                                                 (Tstruct _GraphNodeObject noattr))
                                               _cameraToObject
                                               (tarray tfloat 3)) :: nil)))
                                        Sskip)))))))))))
                  LSnil)))))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Efield
                   (Efield
                     (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3)) ::
               (Efield
                 (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                   (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
               nil)))
          (Ssequence
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'3
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Scall None
                  (Evar _vec3s_set (Tfunction
                                     ((tptr tshort) :: tshort :: tshort ::
                                      tshort :: nil) (tptr tvoid) cc_default))
                  ((Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _angle
                     (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
                   (Etempvar _t'3 tshort) ::
                   (Econst_int (Int.repr 0) tint) :: nil))))
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 136) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_tornado_twirling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) ::
              (_nextPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_sinAngleVel, tfloat) :: (_cosAngleVel, tfloat) ::
               (_floorHeight, tfloat) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_usedObj, (tptr (Tstruct _Object noattr))) ::
               (_prevTwirlYaw, tshort) :: (_dx, tfloat) :: (_dz, tfloat) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tfloat) ::
               (_t'2, tuint) :: (_t'1, tfloat) :: (_t'46, tshort) ::
               (_t'45, tfloat) :: (_t'44, tfloat) :: (_t'43, tfloat) ::
               (_t'42, tfloat) :: (_t'41, tfloat) :: (_t'40, tfloat) ::
               (_t'39, tfloat) :: (_t'38, tfloat) :: (_t'37, tfloat) ::
               (_t'36, tfloat) :: (_t'35, tfloat) :: (_t'34, tshort) ::
               (_t'33, tshort) :: (_t'32, tint) :: (_t'31, tint) ::
               (_t'30, tshort) :: (_t'29, tshort) :: (_t'28, tint) ::
               (_t'27, tint) :: (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, tfloat) :: (_t'23, tfloat) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) ::
               (_t'14, (tptr (Tstruct _Surface noattr))) ::
               (_t'13, tushort) :: (_t'12, tuint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _usedObj
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'46
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _twirlYaw tshort))
        (Sset _prevTwirlYaw (Ecast (Etempvar _t'46 tshort) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'44
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'45
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                tfloat))
            (Sset _dx
              (Ebinop Omul
                (Ebinop Osub (Etempvar _t'44 tfloat) (Etempvar _t'45 tfloat)
                  tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat)
                tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'42
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'43
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _dz
                (Ebinop Omul
                  (Ebinop Osub (Etempvar _t'42 tfloat)
                    (Etempvar _t'43 tfloat) tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat)
                  tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'40
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'40 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'41
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'41 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'38
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asF32
                            (tarray tfloat 80))
                          (Econst_int (Int.repr 34) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'39
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sset _t'1
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'38 tfloat)
                            (Etempvar _t'39 tfloat) tfloat) tfloat))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat) (Etempvar _t'1 tfloat)))
                (Sifthenelse (Ebinop Olt (Etempvar _t'1 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                               tint)
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'35
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                        (Econst_int (Int.repr 34) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'36
                      (Efield
                        (Ederef
                          (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _hitboxHeight tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'35 tfloat)
                                   (Etempvar _t'36 tfloat) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'37
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'37 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                         tint)
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _vel
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat))
                            Sskip))
                        (Ssequence
                          (Scall (Some _t'2)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 276826276) tint) ::
                             (Econst_int (Int.repr 1) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'2 tuint)))))
                      Sskip)))
                (Ssequence
                  (Ssequence
                    (Sset _t'33
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _angleVel
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'33 tshort)
                                   (Econst_int (Int.repr 12288) tint) tint)
                      (Ssequence
                        (Sset _t'34
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _angleVel
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _angleVel
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort)
                          (Ebinop Oadd (Etempvar _t'34 tshort)
                            (Econst_int (Int.repr 256) tint) tint)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'31
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _rawData
                                (Tunion __665 noattr)) _asS32
                              (tarray tint 80))
                            (Econst_int (Int.repr 33) tint) (tptr tint))
                          tint))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'31 tint)
                                     (Econst_int (Int.repr 4096) tint) tint)
                        (Ssequence
                          (Sset _t'32
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint)
                            (Ebinop Oadd (Etempvar _t'32 tint)
                              (Econst_int (Int.repr 256) tint) tint)))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'29
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _twirlYaw tshort))
                        (Ssequence
                          (Sset _t'30
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _angleVel
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _twirlYaw
                              tshort)
                            (Ebinop Oadd (Etempvar _t'29 tshort)
                              (Etempvar _t'30 tshort) tint))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'28
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 33) tint) (tptr tint))
                              tint))
                          (Sset _sinAngleVel
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'28 tint) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'27
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asS32
                                    (tarray tint 80))
                                  (Econst_int (Int.repr 33) tint)
                                  (tptr tint)) tint))
                            (Sset _cosAngleVel
                              (Ederef
                                (Ebinop Oadd
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Econst_int (Int.repr 1024) tint)
                                    (tptr tfloat))
                                  (Ebinop Oshr
                                    (Ecast (Etempvar _t'27 tint) tushort)
                                    (Econst_int (Int.repr 4) tint) tint)
                                  (tptr tfloat)) tfloat)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'26
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asF32
                                      (tarray tfloat 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _nextPos (tarray tfloat 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Ebinop Oadd
                                  (Ebinop Oadd (Etempvar _t'26 tfloat)
                                    (Ebinop Omul (Etempvar _dx tfloat)
                                      (Etempvar _cosAngleVel tfloat) tfloat)
                                    tfloat)
                                  (Ebinop Omul (Etempvar _dz tfloat)
                                    (Etempvar _sinAngleVel tfloat) tfloat)
                                  tfloat)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'25
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr))
                                          _rawData (Tunion __665 noattr))
                                        _asF32 (tarray tfloat 80))
                                      (Ebinop Oadd
                                        (Econst_int (Int.repr 6) tint)
                                        (Econst_int (Int.repr 2) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Ederef
                                    (Ebinop Oadd
                                      (Evar _nextPos (tarray tfloat 3))
                                      (Econst_int (Int.repr 2) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Oadd
                                    (Ebinop Osub (Etempvar _t'25 tfloat)
                                      (Ebinop Omul (Etempvar _dx tfloat)
                                        (Etempvar _sinAngleVel tfloat)
                                        tfloat) tfloat)
                                    (Ebinop Omul (Etempvar _dz tfloat)
                                      (Etempvar _cosAngleVel tfloat) tfloat)
                                    tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'23
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _usedObj (tptr (Tstruct _Object noattr)))
                                              (Tstruct _Object noattr))
                                            _rawData (Tunion __665 noattr))
                                          _asF32 (tarray tfloat 80))
                                        (Ebinop Oadd
                                          (Econst_int (Int.repr 6) tint)
                                          (Econst_int (Int.repr 1) tint)
                                          tint) (tptr tfloat)) tfloat))
                                  (Ssequence
                                    (Sset _t'24
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _rawData (Tunion __665 noattr))
                                            _asF32 (tarray tfloat 80))
                                          (Econst_int (Int.repr 34) tint)
                                          (tptr tfloat)) tfloat))
                                    (Sassign
                                      (Ederef
                                        (Ebinop Oadd
                                          (Evar _nextPos (tarray tfloat 3))
                                          (Econst_int (Int.repr 1) tint)
                                          (tptr tfloat)) tfloat)
                                      (Ebinop Oadd (Etempvar _t'23 tfloat)
                                        (Etempvar _t'24 tfloat) tfloat))))
                                (Ssequence
                                  (Scall None
                                    (Evar _f32_find_wall_collision (Tfunction
                                                                    ((tptr tfloat) ::
                                                                    (tptr tfloat) ::
                                                                    (tptr tfloat) ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    nil) tint
                                                                    cc_default))
                                    ((Ebinop Oadd
                                       (Evar _nextPos (tarray tfloat 3))
                                       (Econst_int (Int.repr 0) tint)
                                       (tptr tfloat)) ::
                                     (Ebinop Oadd
                                       (Evar _nextPos (tarray tfloat 3))
                                       (Econst_int (Int.repr 1) tint)
                                       (tptr tfloat)) ::
                                     (Ebinop Oadd
                                       (Evar _nextPos (tarray tfloat 3))
                                       (Econst_int (Int.repr 2) tint)
                                       (tptr tfloat)) ::
                                     (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
                                     (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
                                     nil))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'20
                                          (Ederef
                                            (Ebinop Oadd
                                              (Evar _nextPos (tarray tfloat 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tfloat)) tfloat))
                                        (Ssequence
                                          (Sset _t'21
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _nextPos (tarray tfloat 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tfloat)) tfloat))
                                          (Ssequence
                                            (Sset _t'22
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _nextPos (tarray tfloat 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Scall (Some _t'3)
                                              (Evar _find_floor (Tfunction
                                                                  (tfloat ::
                                                                   tfloat ::
                                                                   tfloat ::
                                                                   (tptr (tptr (Tstruct _Surface noattr))) ::
                                                                   nil)
                                                                  tfloat
                                                                  cc_default))
                                              ((Etempvar _t'20 tfloat) ::
                                               (Etempvar _t'21 tfloat) ::
                                               (Etempvar _t'22 tfloat) ::
                                               (Eaddrof
                                                 (Evar _floor (tptr (Tstruct _Surface noattr)))
                                                 (tptr (tptr (Tstruct _Surface noattr)))) ::
                                               nil)))))
                                      (Sset _floorHeight
                                        (Etempvar _t'3 tfloat)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'14
                                          (Evar _floor (tptr (Tstruct _Surface noattr))))
                                        (Sifthenelse (Ebinop One
                                                       (Etempvar _t'14 (tptr (Tstruct _Surface noattr)))
                                                       (Ecast
                                                         (Econst_int (Int.repr 0) tint)
                                                         (tptr tvoid)) tint)
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'19
                                                (Evar _floor (tptr (Tstruct _Surface noattr))))
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _floor
                                                  (tptr (Tstruct _Surface noattr)))
                                                (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))))
                                            (Ssequence
                                              (Sassign
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _floorHeight tfloat)
                                                (Etempvar _floorHeight tfloat))
                                              (Scall None
                                                (Evar _vec3f_copy (Tfunction
                                                                    ((tptr tfloat) ::
                                                                    (tptr tfloat) ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                                ((Efield
                                                   (Ederef
                                                     (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                     (Tstruct _MarioState noattr))
                                                   _pos (tarray tfloat 3)) ::
                                                 (Evar _nextPos (tarray tfloat 3)) ::
                                                 nil))))
                                          (Ssequence
                                            (Sset _t'15
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _nextPos (tarray tfloat 3))
                                                  (Econst_int (Int.repr 1) tint)
                                                  (tptr tfloat)) tfloat))
                                            (Ssequence
                                              (Sset _t'16
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _floorHeight tfloat))
                                              (Sifthenelse (Ebinop Oge
                                                             (Etempvar _t'15 tfloat)
                                                             (Etempvar _t'16 tfloat)
                                                             tint)
                                                (Ssequence
                                                  (Sset _t'18
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Evar _nextPos (tarray tfloat 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tfloat))
                                                      tfloat))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _pos
                                                          (tarray tfloat 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tfloat))
                                                      tfloat)
                                                    (Etempvar _t'18 tfloat)))
                                                (Ssequence
                                                  (Sset _t'17
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _floorHeight tfloat))
                                                  (Sassign
                                                    (Ederef
                                                      (Ebinop Oadd
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _pos
                                                          (tarray tfloat 3))
                                                        (Econst_int (Int.repr 1) tint)
                                                        (tptr tfloat))
                                                      tfloat)
                                                    (Etempvar _t'17 tfloat))))))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'13
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _actionTimer tushort))
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _actionTimer tushort)
                                            (Ebinop Oadd
                                              (Etempvar _t'13 tushort)
                                              (Econst_int (Int.repr 1) tint)
                                              tint)))
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'12
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _actionArg tuint))
                                              (Sifthenelse (Ebinop Oeq
                                                             (Etempvar _t'12 tuint)
                                                             (Econst_int (Int.repr 0) tint)
                                                             tint)
                                                (Sset _t'4
                                                  (Ecast
                                                    (Econst_int (Int.repr 149) tint)
                                                    tint))
                                                (Sset _t'4
                                                  (Ecast
                                                    (Econst_int (Int.repr 148) tint)
                                                    tint))))
                                            (Scall None
                                              (Evar _set_mario_animation 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               (Etempvar _t'4 tint) :: nil)))
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'5)
                                                (Evar _is_anim_past_end 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sifthenelse (Etempvar _t'5 tint)
                                                (Sassign
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _actionArg tuint)
                                                  (Econst_int (Int.repr 1) tint))
                                                Sskip))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'10
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _twirlYaw tshort))
                                                (Sifthenelse (Ebinop Ogt
                                                               (Etempvar _prevTwirlYaw tshort)
                                                               (Etempvar _t'10 tshort)
                                                               tint)
                                                  (Ssequence
                                                    (Sset _t'11
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _marioObj
                                                        (tptr (Tstruct _Object noattr))))
                                                    (Scall None
                                                      (Evar _play_sound 
                                                      (Tfunction
                                                        (tint ::
                                                         (tptr tfloat) ::
                                                         nil) tvoid
                                                        cc_default))
                                                      ((Ebinop Oor
                                                         (Ebinop Oor
                                                           (Ebinop Oor
                                                             (Ebinop Oor
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 0) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 28) tint)
                                                                 tuint)
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 56) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 16) tint)
                                                                 tuint)
                                                               tuint)
                                                             (Ebinop Oshl
                                                               (Ecast
                                                                 (Econst_int (Int.repr 128) tint)
                                                                 tuint)
                                                               (Econst_int (Int.repr 8) tint)
                                                               tuint) tuint)
                                                           (Ebinop Oor
                                                             (Econst_int (Int.repr 67108864) tint)
                                                             (Econst_int (Int.repr 128) tint)
                                                             tint) tuint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tuint) ::
                                                       (Efield
                                                         (Efield
                                                           (Efield
                                                             (Ederef
                                                               (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                                               (Tstruct _Object noattr))
                                                             _header
                                                             (Tstruct _ObjectNode noattr))
                                                           _gfx
                                                           (Tstruct _GraphNodeObject noattr))
                                                         _cameraToObject
                                                         (tarray tfloat 3)) ::
                                                       nil)))
                                                  Sskip))
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'9
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _marioObj
                                                      (tptr (Tstruct _Object noattr))))
                                                  (Scall None
                                                    (Evar _vec3f_copy 
                                                    (Tfunction
                                                      ((tptr tfloat) ::
                                                       (tptr tfloat) :: nil)
                                                      (tptr tvoid)
                                                      cc_default))
                                                    ((Efield
                                                       (Efield
                                                         (Efield
                                                           (Ederef
                                                             (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                                             (Tstruct _Object noattr))
                                                           _header
                                                           (Tstruct _ObjectNode noattr))
                                                         _gfx
                                                         (Tstruct _GraphNodeObject noattr))
                                                       _pos
                                                       (tarray tfloat 3)) ::
                                                     (Efield
                                                       (Ederef
                                                         (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                         (Tstruct _MarioState noattr))
                                                       _pos
                                                       (tarray tfloat 3)) ::
                                                     nil)))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'6
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _marioObj
                                                        (tptr (Tstruct _Object noattr))))
                                                    (Ssequence
                                                      (Sset _t'7
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _faceAngle
                                                              (tarray tshort 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tshort))
                                                          tshort))
                                                      (Ssequence
                                                        (Sset _t'8
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _twirlYaw tshort))
                                                        (Scall None
                                                          (Evar _vec3s_set 
                                                          (Tfunction
                                                            ((tptr tshort) ::
                                                             tshort ::
                                                             tshort ::
                                                             tshort :: nil)
                                                            (tptr tvoid)
                                                            cc_default))
                                                          ((Efield
                                                             (Efield
                                                               (Efield
                                                                 (Ederef
                                                                   (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                                                   (Tstruct _Object noattr))
                                                                 _header
                                                                 (Tstruct _ObjectNode noattr))
                                                               _gfx
                                                               (Tstruct _GraphNodeObject noattr))
                                                             _angle
                                                             (tarray tshort 3)) ::
                                                           (Econst_int (Int.repr 0) tint) ::
                                                           (Ebinop Oadd
                                                             (Etempvar _t'7 tshort)
                                                             (Etempvar _t'8 tshort)
                                                             tint) ::
                                                           (Econst_int (Int.repr 0) tint) ::
                                                           nil)))))
                                                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))))))))))))))
|}.

Definition f_check_common_automatic_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tshort) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'2 tfloat)
                     (Ebinop Osub (Etempvar _t'3 tshort)
                       (Econst_int (Int.repr 100) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_water_plunge_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_mario_execute_automatic_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'18, tint) :: (_t'17, tint) ::
               (_t'16, tint) :: (_t'15, tint) :: (_t'14, tint) ::
               (_t'13, tint) :: (_t'12, tint) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'19, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_automatic_cancels (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
    (Ssequence
      (Ssequence
        (Sset _t'19
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sswitch (Etempvar _t'19 tuint)
          (LScons (Some 135267136)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _act_holding_pole (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'2 tint)))
              Sbreak)
            (LScons (Some 1049409)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _act_grab_pole_slow (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'3 tint)))
                Sbreak)
              (LScons (Some 1049410)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _act_grab_pole_fast (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'4 tint)))
                  Sbreak)
                (LScons (Some 1049411)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'5)
                        (Evar _act_climbing_pole (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'5 tint)))
                    Sbreak)
                  (LScons (Some 1049412)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'6)
                          (Evar _act_top_of_pole_transition (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'6 tint)))
                      Sbreak)
                    (LScons (Some 1049413)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'7)
                            (Evar _act_top_of_pole (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'7 tint)))
                        Sbreak)
                      (LScons (Some 136315720)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'8)
                              (Evar _act_start_hanging (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tint
                                                         cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'8 tint)))
                          Sbreak)
                        (LScons (Some 2097993)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'9)
                                (Evar _act_hanging (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'9 tint)))
                            Sbreak)
                          (LScons (Some 2098506)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'10)
                                  (Evar _act_hang_moving (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tint
                                                           cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'10 tint)))
                              Sbreak)
                            (LScons (Some 134218571)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'11)
                                    (Evar _act_ledge_grab (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'11 tint)))
                                Sbreak)
                              (LScons (Some 1356)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'12)
                                      (Evar _act_ledge_climb_slow (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'12 tint)))
                                  Sbreak)
                                (LScons (Some 1357)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'13)
                                        (Evar _act_ledge_climb_slow (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'13 tint)))
                                    Sbreak)
                                  (LScons (Some 1358)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'14)
                                          (Evar _act_ledge_climb_down 
                                          (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'14 tint)))
                                      Sbreak)
                                    (LScons (Some 1359)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'15)
                                            (Evar _act_ledge_climb_fast 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'15 tint)))
                                        Sbreak)
                                      (LScons (Some 131952)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'16)
                                              (Evar _act_grabbed (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                   cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'16 tint)))
                                          Sbreak)
                                        (LScons (Some 4977)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'17)
                                                (Evar _act_in_cannon 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'17 tint)))
                                            Sbreak)
                                          (LScons (Some 268567410)
                                            (Ssequence
                                              (Ssequence
                                                (Scall (Some _t'18)
                                                  (Evar _act_tornado_twirling 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   nil))
                                                (Sset _cancel
                                                  (Etempvar _t'18 tint)))
                                              Sbreak)
                                            LSnil)))))))))))))))))))
      (Sreturn (Some (Etempvar _cancel tint))))))
|}.

Definition composites : list composite_definition :=
(Composite __218 Struct
   (Member_plain _type tushort :: Member_plain _status tuchar ::
    Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite __220 Struct
   (Member_plain _button tushort :: Member_plain _stick_x tschar ::
    Member_plain _stick_y tschar :: Member_plain _errnum tuchar :: nil)
   noattr ::
 Composite _Controller Struct
   (Member_plain _rawStickX tshort :: Member_plain _rawStickY tshort ::
    Member_plain _stickX tfloat :: Member_plain _stickY tfloat ::
    Member_plain _stickMag tfloat :: Member_plain _buttonDown tushort ::
    Member_plain _buttonPressed tushort ::
    Member_plain _statusData (tptr (Tstruct __218 noattr)) ::
    Member_plain _controllerData (tptr (Tstruct __220 noattr)) :: nil)
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
 Composite __665 Union
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
    Member_plain _rawData (Tunion __665 noattr) ::
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
 Composite __670 Struct
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
    Member_plain _normal (Tstruct __670 noattr) ::
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
                   (mksignature (AST.Xptr :: AST.Xlong :: nil) AST.Xptr
                     cc_default)) ((tptr tvoid) :: tulong :: nil)
     (tptr tvoid) cc_default)) ::
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
     ((tptr tschar) :: nil) tvoid
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
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
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
                   (mksignature (AST.Xlong :: nil) AST.Xint cc_default))
     (tulong :: nil) tint cc_default)) ::
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
                     (AST.Xptr :: AST.Xptr :: AST.Xlong :: AST.Xlong :: nil)
                     AST.Xvoid cc_default))
     ((tptr tvoid) :: (tptr tvoid) :: tulong :: tulong :: nil) tvoid
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
     ((tptr tschar) :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (___builtin_annot_intval,
   Gfun(External (EF_builtin "__builtin_annot_intval"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default)) ((tptr tschar) :: tint :: nil) tint
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
                   (mksignature (AST.Xlong :: AST.Xlong :: nil) AST.Xlong
                     cc_default)) (tlong :: tlong :: nil) tlong cc_default)) ::
 (___builtin_fmax,
   Gfun(External (EF_builtin "__builtin_fmax"
                   (mksignature (AST.Xfloat :: AST.Xfloat :: nil) AST.Xfloat
                     cc_default)) (tdouble :: tdouble :: nil) tdouble
     cc_default)) ::
 (___builtin_fmin,
   Gfun(External (EF_builtin "__builtin_fmin"
                   (mksignature (AST.Xfloat :: AST.Xfloat :: nil) AST.Xfloat
                     cc_default)) (tdouble :: tdouble :: nil) tdouble
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
 (___builtin_debug,
   Gfun(External (EF_external "__builtin_debug"
                   (mksignature (AST.Xint :: nil) AST.Xvoid
                     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|}))
     (tint :: nil) tvoid
     {|cc_vararg:=(Some 1); cc_unproto:=false; cc_structret:=false|})) ::
 (_bhvGiantPole, Gvar v_bhvGiantPole) :: (_bhvTree, Gvar v_bhvTree) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_set_sound_moving_speed,
   Gfun(External (EF_external "set_sound_moving_speed"
                   (mksignature
                     (AST.Xint8unsigned :: AST.Xint8unsigned :: nil)
                     AST.Xvoid cc_default)) (tuchar :: tuchar :: nil) tvoid
     cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_virtual_to_segmented,
   Gfun(External (EF_external "virtual_to_segmented"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) (tuint :: (tptr tvoid) :: nil) (tptr tvoid)
     cc_default)) :: (_gVec3fZero, Gvar v_gVec3fZero) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_is_anim_at_end,
   Gfun(External (EF_external "is_anim_at_end"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_is_anim_past_end,
   Gfun(External (EF_external "is_anim_past_end"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_mario_animation,
   Gfun(External (EF_external "set_mario_animation"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
 (_set_mario_anim_with_accel,
   Gfun(External (EF_external "set_mario_anim_with_accel"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: tint :: nil) tshort
     cc_default)) ::
 (_is_anim_past_frame,
   Gfun(External (EF_external "is_anim_past_frame"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tint cc_default)) ::
 (_return_mario_anim_y_translation,
   Gfun(External (EF_external "return_mario_anim_y_translation"
                   (mksignature (AST.Xptr :: nil) AST.Xint16signed
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tshort cc_default)) ::
 (_play_sound_if_no_flag,
   Gfun(External (EF_external "play_sound_if_no_flag"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_play_mario_landing_sound,
   Gfun(External (EF_external "play_mario_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_resolve_and_return_wall_collisions,
   Gfun(External (EF_external "resolve_and_return_wall_collisions"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: tfloat :: tfloat :: nil)
     (tptr (Tstruct _Surface noattr)) cc_default)) ::
 (_vec3f_find_ceil,
   Gfun(External (EF_external "vec3f_find_ceil"
                   (mksignature (AST.Xptr :: AST.Xsingle :: AST.Xptr :: nil)
                     AST.Xsingle cc_default))
     ((tptr tfloat) :: tfloat :: (tptr (tptr (Tstruct _Surface noattr))) ::
      nil) tfloat cc_default)) ::
 (_find_floor_height_relative_polar,
   Gfun(External (EF_external "find_floor_height_relative_polar"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: tfloat :: nil) tfloat
     cc_default)) ::
 (_set_mario_action,
   Gfun(External (EF_external "set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tuint
     cc_default)) ::
 (_check_common_action_exits,
   Gfun(External (EF_external "check_common_action_exits"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_stop_and_set_height_to_floor,
   Gfun(External (EF_external "stop_and_set_height_to_floor"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_gSineTable, Gvar v_gSineTable) ::
 (_vec3f_copy,
   Gfun(External (EF_external "vec3f_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tfloat) :: nil)
     (tptr tvoid) cc_default)) ::
 (_vec3f_set,
   Gfun(External (EF_external "vec3f_set"
                   (mksignature
                     (AST.Xptr :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xptr cc_default))
     ((tptr tfloat) :: tfloat :: tfloat :: tfloat :: nil) (tptr tvoid)
     cc_default)) ::
 (_vec3s_set,
   Gfun(External (EF_external "vec3s_set"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xptr cc_default))
     ((tptr tshort) :: tshort :: tshort :: tshort :: nil) (tptr tvoid)
     cc_default)) ::
 (_approach_s32,
   Gfun(External (EF_external "approach_s32"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     (tint :: tint :: tint :: tint :: nil) tint cc_default)) ::
 (_f32_find_wall_collision,
   Gfun(External (EF_external "f32_find_wall_collision"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xint cc_default))
     ((tptr tfloat) :: (tptr tfloat) :: (tptr tfloat) :: tfloat :: tfloat ::
      nil) tint cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_add_tree_leaf_particles, Gfun(Internal f_add_tree_leaf_particles)) ::
 (_play_climbing_sounds, Gfun(Internal f_play_climbing_sounds)) ::
 (_set_pole_position, Gfun(Internal f_set_pole_position)) ::
 (_act_holding_pole, Gfun(Internal f_act_holding_pole)) ::
 (_act_climbing_pole, Gfun(Internal f_act_climbing_pole)) ::
 (_act_grab_pole_slow, Gfun(Internal f_act_grab_pole_slow)) ::
 (_act_grab_pole_fast, Gfun(Internal f_act_grab_pole_fast)) ::
 (_act_top_of_pole_transition, Gfun(Internal f_act_top_of_pole_transition)) ::
 (_act_top_of_pole, Gfun(Internal f_act_top_of_pole)) ::
 (_perform_hanging_step, Gfun(Internal f_perform_hanging_step)) ::
 (_update_hang_moving, Gfun(Internal f_update_hang_moving)) ::
 (_update_hang_stationary, Gfun(Internal f_update_hang_stationary)) ::
 (_act_start_hanging, Gfun(Internal f_act_start_hanging)) ::
 (_act_hanging, Gfun(Internal f_act_hanging)) ::
 (_act_hang_moving, Gfun(Internal f_act_hang_moving)) ::
 (_let_go_of_ledge, Gfun(Internal f_let_go_of_ledge)) ::
 (_climb_up_ledge, Gfun(Internal f_climb_up_ledge)) ::
 (_update_ledge_climb_camera, Gfun(Internal f_update_ledge_climb_camera)) ::
 (_update_ledge_climb, Gfun(Internal f_update_ledge_climb)) ::
 (_act_ledge_grab, Gfun(Internal f_act_ledge_grab)) ::
 (_act_ledge_climb_slow, Gfun(Internal f_act_ledge_climb_slow)) ::
 (_act_ledge_climb_down, Gfun(Internal f_act_ledge_climb_down)) ::
 (_act_ledge_climb_fast, Gfun(Internal f_act_ledge_climb_fast)) ::
 (_act_grabbed, Gfun(Internal f_act_grabbed)) ::
 (_act_in_cannon, Gfun(Internal f_act_in_cannon)) ::
 (_act_tornado_twirling, Gfun(Internal f_act_tornado_twirling)) ::
 (_check_common_automatic_cancels, Gfun(Internal f_check_common_automatic_cancels)) ::
 (_mario_execute_automatic_action, Gfun(Internal f_mario_execute_automatic_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_automatic_action :: _check_common_automatic_cancels ::
 _act_tornado_twirling :: _act_in_cannon :: _act_grabbed ::
 _act_ledge_climb_fast :: _act_ledge_climb_down :: _act_ledge_climb_slow ::
 _act_ledge_grab :: _update_ledge_climb :: _update_ledge_climb_camera ::
 _climb_up_ledge :: _let_go_of_ledge :: _act_hang_moving :: _act_hanging ::
 _act_start_hanging :: _update_hang_stationary :: _update_hang_moving ::
 _perform_hanging_step :: _act_top_of_pole :: _act_top_of_pole_transition ::
 _act_grab_pole_fast :: _act_grab_pole_slow :: _act_climbing_pole ::
 _act_holding_pole :: _set_pole_position :: _play_climbing_sounds ::
 _add_tree_leaf_particles :: _find_floor :: _f32_find_wall_collision ::
 _approach_s32 :: _vec3s_set :: _vec3f_set :: _vec3f_copy :: _gSineTable ::
 _stop_and_set_height_to_floor :: _set_water_plunge_action ::
 _check_common_action_exits :: _set_mario_action ::
 _find_floor_height_relative_polar :: _vec3f_find_ceil ::
 _resolve_and_return_wall_collisions :: _play_mario_landing_sound ::
 _play_sound_if_no_flag :: _return_mario_anim_y_translation ::
 _is_anim_past_frame :: _set_mario_anim_with_accel :: _set_mario_animation ::
 _is_anim_past_end :: _is_anim_at_end :: _gCurrLevelNum :: _gVec3fZero ::
 _virtual_to_segmented :: _segmented_to_virtual :: _set_sound_moving_speed ::
 _play_sound :: _bhvTree :: _bhvGiantPole :: ___builtin_debug ::
 ___builtin_write32_reversed :: ___builtin_write16_reversed ::
 ___builtin_read32_reversed :: ___builtin_read16_reversed ::
 ___builtin_fnmsub :: ___builtin_fnmadd :: ___builtin_fmsub ::
 ___builtin_fmadd :: ___builtin_fmin :: ___builtin_fmax ::
 ___builtin_expect :: ___builtin_unreachable :: ___builtin_va_end ::
 ___builtin_va_copy :: ___builtin_va_arg :: ___builtin_va_start ::
 ___builtin_membar :: ___builtin_annot_intval :: ___builtin_annot ::
 ___builtin_sel :: ___builtin_memcpy_aligned :: ___builtin_sqrt ::
 ___builtin_fsqrt :: ___builtin_fabsf :: ___builtin_fabs ::
 ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz :: ___builtin_clzll ::
 ___builtin_clzl :: ___builtin_clz :: ___builtin_bswap16 ::
 ___builtin_bswap32 :: ___builtin_bswap :: ___builtin_bswap64 ::
 ___builtin_ais_annot :: ___compcert_i64_umulh :: ___compcert_i64_smulh ::
 ___compcert_i64_sar :: ___compcert_i64_shr :: ___compcert_i64_shl ::
 ___compcert_i64_umod :: ___compcert_i64_smod :: ___compcert_i64_udiv ::
 ___compcert_i64_sdiv :: ___compcert_i64_utof :: ___compcert_i64_stof ::
 ___compcert_i64_utod :: ___compcert_i64_stod :: ___compcert_i64_dtou ::
 ___compcert_i64_dtos :: ___compcert_va_composite ::
 ___compcert_va_float64 :: ___compcert_va_int64 :: ___compcert_va_int32 ::
 nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


