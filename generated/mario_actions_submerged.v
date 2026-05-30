(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_submerged.c
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
  Definition source_file := "vendor/sm64/src/game/mario_actions_submerged.c".
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
Definition _act_backward_water_kb : ident := $"act_backward_water_kb".
Definition _act_breaststroke : ident := $"act_breaststroke".
Definition _act_caught_in_whirlpool : ident := $"act_caught_in_whirlpool".
Definition _act_drowning : ident := $"act_drowning".
Definition _act_flutter_kick : ident := $"act_flutter_kick".
Definition _act_forward_water_kb : ident := $"act_forward_water_kb".
Definition _act_hold_breaststroke : ident := $"act_hold_breaststroke".
Definition _act_hold_flutter_kick : ident := $"act_hold_flutter_kick".
Definition _act_hold_metal_water_fall_land : ident := $"act_hold_metal_water_fall_land".
Definition _act_hold_metal_water_falling : ident := $"act_hold_metal_water_falling".
Definition _act_hold_metal_water_jump : ident := $"act_hold_metal_water_jump".
Definition _act_hold_metal_water_jump_land : ident := $"act_hold_metal_water_jump_land".
Definition _act_hold_metal_water_standing : ident := $"act_hold_metal_water_standing".
Definition _act_hold_metal_water_walking : ident := $"act_hold_metal_water_walking".
Definition _act_hold_swimming_end : ident := $"act_hold_swimming_end".
Definition _act_hold_water_action_end : ident := $"act_hold_water_action_end".
Definition _act_hold_water_idle : ident := $"act_hold_water_idle".
Definition _act_metal_water_fall_land : ident := $"act_metal_water_fall_land".
Definition _act_metal_water_falling : ident := $"act_metal_water_falling".
Definition _act_metal_water_jump : ident := $"act_metal_water_jump".
Definition _act_metal_water_jump_land : ident := $"act_metal_water_jump_land".
Definition _act_metal_water_standing : ident := $"act_metal_water_standing".
Definition _act_metal_water_walking : ident := $"act_metal_water_walking".
Definition _act_swimming_end : ident := $"act_swimming_end".
Definition _act_water_action_end : ident := $"act_water_action_end".
Definition _act_water_death : ident := $"act_water_death".
Definition _act_water_idle : ident := $"act_water_idle".
Definition _act_water_plunge : ident := $"act_water_plunge".
Definition _act_water_punch : ident := $"act_water_punch".
Definition _act_water_shell_swimming : ident := $"act_water_shell_swimming".
Definition _act_water_shocked : ident := $"act_water_shocked".
Definition _act_water_throw : ident := $"act_water_throw".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _angle : ident := $"angle".
Definition _angleChange : ident := $"angleChange".
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
Definition _apply_water_current : ident := $"apply_water_current".
Definition _approach_f32 : ident := $"approach_f32".
Definition _approach_s32 : ident := $"approach_s32".
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _arg : ident := $"arg".
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
Definition _atSurface : ident := $"atSurface".
Definition _atan2s : ident := $"atan2s".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvKoopaShellUnderwater : ident := $"bhvKoopaShellUnderwater".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bufTarget : ident := $"bufTarget".
Definition _buoyancy : ident := $"buoyancy".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _cancel : ident := $"cancel".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_common_submerged_cancels : ident := $"check_common_submerged_cancels".
Definition _check_water_grab : ident := $"check_water_grab".
Definition _check_water_jump : ident := $"check_water_jump".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _common_idle_step : ident := $"common_idle_step".
Definition _common_swimming_step : ident := $"common_swimming_step".
Definition _common_water_knockback_step : ident := $"common_water_knockback_step".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _cosAngleChange : ident := $"cosAngleChange".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _currentAngle : ident := $"currentAngle".
Definition _currentSpeed : ident := $"currentSpeed".
Definition _cutscene : ident := $"cutscene".
Definition _dAngleToObject : ident := $"dAngleToObject".
Definition _decelThreshold : ident := $"decelThreshold".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _distance : ident := $"distance".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _dx : ident := $"dx".
Definition _dy : ident := $"dy".
Definition _dz : ident := $"dz".
Definition _endAction : ident := $"endAction".
Definition _endVSpeed : ident := $"endVSpeed".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_slope : ident := $"find_floor_slope".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _floorPitch : ident := $"floorPitch".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gCurrAreaIndex : ident := $"gCurrAreaIndex".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gSineTable : ident := $"gSineTable".
Definition _get_buoyancy : ident := $"get_buoyancy".
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
Definition _i : ident := $"i".
Definition _id : ident := $"id".
Definition _index : ident := $"index".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedDYaw : ident := $"intendedDYaw".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_frame : ident := $"is_anim_past_frame".
Definition _landing : ident := $"landing".
Definition _lateralDist : ident := $"lateralDist".
Definition _length : ident := $"length".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_execute_submerged_action : ident := $"mario_execute_submerged_action".
Definition _mario_get_collided_object : ident := $"mario_get_collided_object".
Definition _mario_grab_used_object : ident := $"mario_grab_used_object".
Definition _mario_throw_held_object : ident := $"mario_throw_held_object".
Definition _maxSpeed : ident := $"maxSpeed".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _newDistance : ident := $"newDistance".
Definition _next : ident := $"next".
Definition _nextPos : ident := $"nextPos".
Definition _nextY : ident := $"nextY".
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
Definition _particleFlag : ident := $"particleFlag".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_air_step : ident := $"perform_air_step".
Definition _perform_ground_step : ident := $"perform_ground_step".
Definition _perform_water_full_step : ident := $"perform_water_full_step".
Definition _perform_water_step : ident := $"perform_water_step".
Definition _pitchToWhirlpool : ident := $"pitchToWhirlpool".
Definition _pitchVel : ident := $"pitchVel".
Definition _platform : ident := $"platform".
Definition _play_metal_water_jumping_sound : ident := $"play_metal_water_jumping_sound".
Definition _play_metal_water_walking_sound : ident := $"play_metal_water_walking_sound".
Definition _play_shell_music : ident := $"play_shell_music".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _play_swimming_noise : ident := $"play_swimming_noise".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _probe : ident := $"probe".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _reset_bob_variables : ident := $"reset_bob_variables".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _sBobHeight : ident := $"sBobHeight".
Definition _sBobIncrement : ident := $"sBobIncrement".
Definition _sBobTimer : ident := $"sBobTimer".
Definition _sSwimStrength : ident := $"sSwimStrength".
Definition _sWasAtSurface : ident := $"sWasAtSurface".
Definition _sWaterCurrentSpeeds : ident := $"sWaterCurrentSpeeds".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_anim_to_frame : ident := $"set_anim_to_frame".
Definition _set_camera_shake_from_hit : ident := $"set_camera_shake_from_hit".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_anim_with_accel : ident := $"set_mario_anim_with_accel".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_swimming_at_surface_particles : ident := $"set_swimming_at_surface_particles".
Definition _sharedChild : ident := $"sharedChild".
Definition _sinAngleChange : ident := $"sinAngleChange".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _stateFlags : ident := $"stateFlags".
Definition _stationary_slow_down : ident := $"stationary_slow_down".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _step : ident := $"step".
Definition _stepResult : ident := $"stepResult".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_and_set_height_to_floor : ident := $"stop_and_set_height_to_floor".
Definition _stop_shell_music : ident := $"stop_shell_music".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _surface_swim_bob : ident := $"surface_swim_bob".
Definition _swimStrength : ident := $"swimStrength".
Definition _swimming_near_surface : ident := $"swimming_near_surface".
Definition _targetPitch : ident := $"targetPitch".
Definition _targetYawVel : ident := $"targetYawVel".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _transition_submerged_to_walking : ident := $"transition_submerged_to_walking".
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
Definition _update_metal_water_jump_speed : ident := $"update_metal_water_jump_speed".
Definition _update_metal_water_walking_speed : ident := $"update_metal_water_walking_speed".
Definition _update_swimming_pitch : ident := $"update_swimming_pitch".
Definition _update_swimming_speed : ident := $"update_swimming_speed".
Definition _update_swimming_yaw : ident := $"update_swimming_yaw".
Definition _update_water_pitch : ident := $"update_water_pitch".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _val : ident := $"val".
Definition _val04 : ident := $"val04".
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
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _waterSurface : ident := $"waterSurface".
Definition _whirlpool : ident := $"whirlpool".
Definition _whirlpoolRadius : ident := $"whirlpoolRadius".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _yawToWhirlpool : ident := $"yawToWhirlpool".
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
Definition _t'4 : ident := 131%positive.
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
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

Definition v_gCurrentArea := {|
  gvar_info := (tptr (Tstruct _Area noattr));
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

Definition v_bhvKoopaShellUnderwater := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_sWasAtSurface := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 0) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSwimStrength := {|
  gvar_info := tshort;
  gvar_init := (Init_int16 (Int.repr 160) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sWaterCurrentSpeeds := {|
  gvar_info := (tarray tshort 4);
  gvar_init := (Init_int16 (Int.repr 28) :: Init_int16 (Int.repr 12) ::
                Init_int16 (Int.repr 8) :: Init_int16 (Int.repr 4) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBobTimer := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBobIncrement := {|
  gvar_info := tshort;
  gvar_init := (Init_space 2 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBobHeight := {|
  gvar_info := tfloat;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_set_swimming_at_surface_particles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_particleFlag, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_atSurface, tshort) :: (_t'5, tshort) :: (_t'4, tfloat) ::
               (_t'3, tuint) :: (_t'2, (tptr (Tstruct _Object noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
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
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sset _atSurface
        (Ecast
          (Ebinop Oge (Etempvar _t'4 tfloat)
            (Ebinop Osub (Etempvar _t'5 tshort)
              (Econst_int (Int.repr 130) tint) tint) tint) tshort))))
  (Ssequence
    (Sifthenelse (Etempvar _atSurface tshort)
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint)
            (Ebinop Oor (Etempvar _t'3 tuint) (Etempvar _particleFlag tuint)
              tuint)))
        (Ssequence
          (Sset _t'1 (Evar _sWasAtSurface tshort))
          (Sifthenelse (Ebinop Oxor (Etempvar _atSurface tshort)
                         (Etempvar _t'1 tshort) tint)
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
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
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 49) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 96) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            Sskip)))
      Sskip)
    (Sassign (Evar _sWasAtSurface tshort) (Etempvar _atSurface tshort))))
|}.

Definition f_swimming_near_surface := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tfloat) :: (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sreturn (Some (Econst_int (Int.repr 0) tint)))
      Sskip))
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _waterLevel tshort))
    (Ssequence
      (Sset _t'2
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sreturn (Some (Ebinop Olt
                       (Ebinop Osub
                         (Ebinop Osub (Etempvar _t'1 tshort)
                           (Econst_int (Int.repr 80) tint) tint)
                         (Etempvar _t'2 tfloat) tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                       tint))))))
|}.

Definition f_get_buoyancy := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_buoyancy, tfloat) :: (_t'1, tint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _buoyancy (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                     (Econst_int (Int.repr 4) tint) tuint)
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 17) tint) tint) tuint)
            (Sset _buoyancy
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                tfloat))
            (Sset _buoyancy
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1099956224)) tfloat)
                tfloat))))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _swimming_near_surface (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'1 tint)
            (Sset _buoyancy
              (Econst_single (Float32.of_bits (Int.repr 1067450368)) tfloat))
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'3 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 10) tint) tint) tuint)
                             tint)
                (Sset _buoyancy
                  (Eunop Oneg
                    (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                    tfloat))
                Sskip))))))
    (Sreturn (Some (Etempvar _buoyancy tfloat)))))
|}.

Definition f_perform_water_full_step := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_nextPos, (tptr tfloat)) :: nil);
  fn_vars := ((_ceil, (tptr (Tstruct _Surface noattr))) ::
              (_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_wall, (tptr (Tstruct _Surface noattr))) ::
               (_ceilHeight, tfloat) :: (_floorHeight, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _Surface noattr))) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Surface noattr))) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Surface noattr))) ::
               (_t'4, tfloat) :: nil);
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
       (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
       (Econst_single (Float32.of_bits (Int.repr 1121714176)) tfloat) :: nil))
    (Sset _wall (Etempvar _t'1 (tptr (Tstruct _Surface noattr)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Ederef
            (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'15
            (Ederef
              (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'16
              (Ederef
                (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Scall (Some _t'2)
              (Evar _find_floor (Tfunction
                                  (tfloat :: tfloat :: tfloat ::
                                   (tptr (tptr (Tstruct _Surface noattr))) ::
                                   nil) tfloat cc_default))
              ((Etempvar _t'14 tfloat) :: (Etempvar _t'15 tfloat) ::
               (Etempvar _t'16 tfloat) ::
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
          (Sset _t'13 (Evar _floor (tptr (Tstruct _Surface noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'13 (tptr (Tstruct _Surface noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Sreturn (Some (Econst_int (Int.repr 3) tint)))
            Sskip))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Oge (Etempvar _t'4 tfloat)
                         (Etempvar _floorHeight tfloat) tint)
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Oge
                               (Ebinop Osub (Etempvar _ceilHeight tfloat)
                                 (Etempvar _t'11 tfloat) tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                               tint)
                  (Ssequence
                    (Scall None
                      (Evar _vec3f_copy (Tfunction
                                          ((tptr tfloat) :: (tptr tfloat) ::
                                           nil) (tptr tvoid) cc_default))
                      ((Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) ::
                       (Etempvar _nextPos (tptr tfloat)) :: nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Evar _floor (tptr (Tstruct _Surface noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floor
                            (tptr (Tstruct _Surface noattr)))
                          (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floorHeight
                            tfloat) (Etempvar _floorHeight tfloat))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Sreturn (Some (Econst_int (Int.repr 4) tint)))
                          (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
                  Sskip))
              (Ssequence
                (Sifthenelse (Ebinop Olt
                               (Ebinop Osub (Etempvar _ceilHeight tfloat)
                                 (Etempvar _floorHeight tfloat) tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                               tint)
                  (Sreturn (Some (Econst_int (Int.repr 3) tint)))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                          (Econst_int (Int.repr 0) tint) (tptr tfloat))
                        tfloat))
                    (Ssequence
                      (Sset _t'10
                        (Ederef
                          (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Scall None
                        (Evar _vec3f_set (Tfunction
                                           ((tptr tfloat) :: tfloat ::
                                            tfloat :: tfloat :: nil)
                                           (tptr tvoid) cc_default))
                        ((Efield
                           (Ederef
                             (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                             (Tstruct _MarioState noattr)) _pos
                           (tarray tfloat 3)) :: (Etempvar _t'9 tfloat) ::
                         (Ebinop Osub (Etempvar _ceilHeight tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                           tfloat) :: (Etempvar _t'10 tfloat) :: nil))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Evar _floor (tptr (Tstruct _Surface noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr)))
                        (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floorHeight
                          tfloat) (Etempvar _floorHeight tfloat))
                      (Sreturn (Some (Econst_int (Int.repr 2) tint))))))))
            (Ssequence
              (Sifthenelse (Ebinop Olt
                             (Ebinop Osub (Etempvar _ceilHeight tfloat)
                               (Etempvar _floorHeight tfloat) tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                             tint)
                (Sreturn (Some (Econst_int (Int.repr 3) tint)))
                Sskip)
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd (Etempvar _nextPos (tptr tfloat))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat))
                    (Scall None
                      (Evar _vec3f_set (Tfunction
                                         ((tptr tfloat) :: tfloat ::
                                          tfloat :: tfloat :: nil)
                                         (tptr tvoid) cc_default))
                      ((Efield
                         (Ederef
                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                           (Tstruct _MarioState noattr)) _pos
                         (tarray tfloat 3)) :: (Etempvar _t'6 tfloat) ::
                       (Etempvar _floorHeight tfloat) ::
                       (Etempvar _t'7 tfloat) :: nil))))
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
                          (Tstruct _MarioState noattr)) _floorHeight tfloat)
                      (Etempvar _floorHeight tfloat))
                    (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))))))
|}.

Definition f_apply_water_current := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_step, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_i, tint) :: (_whirlpoolRadius, tfloat) ::
               (_currentAngle, tshort) :: (_currentSpeed, tfloat) ::
               (_whirlpool, (tptr (Tstruct _Whirlpool noattr))) ::
               (_strength, tfloat) :: (_dx, tfloat) :: (_dy, tfloat) ::
               (_dz, tfloat) :: (_lateralDist, tfloat) ::
               (_distance, tfloat) :: (_pitchToWhirlpool, tshort) ::
               (_yawToWhirlpool, tshort) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: (_t'37, tshort) ::
               (_t'36, (tptr (Tstruct _Surface noattr))) ::
               (_t'35, tshort) :: (_t'34, tshort) ::
               (_t'33, (tptr (Tstruct _Surface noattr))) ::
               (_t'32, tfloat) :: (_t'31, tfloat) :: (_t'30, tfloat) ::
               (_t'29, tfloat) :: (_t'28, tshort) ::
               (_t'27, (tptr (Tstruct _Surface noattr))) ::
               (_t'26, (tptr (Tstruct _Area noattr))) :: (_t'25, tfloat) ::
               (_t'24, tshort) :: (_t'23, tfloat) :: (_t'22, tshort) ::
               (_t'21, tfloat) :: (_t'20, tshort) :: (_t'19, tshort) ::
               (_t'18, tshort) :: (_t'17, tshort) :: (_t'16, tshort) ::
               (_t'15, tshort) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _whirlpoolRadius
    (Econst_single (Float32.of_bits (Int.repr 1157234688)) tfloat))
  (Ssequence
    (Ssequence
      (Sset _t'27
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Ssequence
        (Sset _t'28
          (Efield
            (Ederef (Etempvar _t'27 (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _type tshort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'28 tshort)
                       (Econst_int (Int.repr 14) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'36
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'37
                  (Efield
                    (Ederef (Etempvar _t'36 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _force tshort))
                (Sset _currentAngle
                  (Ecast
                    (Ebinop Oshl (Etempvar _t'37 tshort)
                      (Econst_int (Int.repr 8) tint) tint) tshort))))
            (Ssequence
              (Ssequence
                (Sset _t'33
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _floor
                    (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'34
                    (Efield
                      (Ederef
                        (Etempvar _t'33 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _force tshort))
                  (Ssequence
                    (Sset _t'35
                      (Ederef
                        (Ebinop Oadd
                          (Evar _sWaterCurrentSpeeds (tarray tshort 4))
                          (Ebinop Oshr (Etempvar _t'34 tshort)
                            (Econst_int (Int.repr 8) tint) tint)
                          (tptr tshort)) tshort))
                    (Sset _currentSpeed
                      (Ecast (Etempvar _t'35 tshort) tfloat)))))
              (Ssequence
                (Ssequence
                  (Sset _t'31
                    (Ederef
                      (Ebinop Oadd (Etempvar _step (tptr tfloat))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'32
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _currentAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _step (tptr tfloat))
                          (Econst_int (Int.repr 0) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Oadd (Etempvar _t'31 tfloat)
                        (Ebinop Omul (Etempvar _currentSpeed tfloat)
                          (Etempvar _t'32 tfloat) tfloat) tfloat))))
                (Ssequence
                  (Sset _t'29
                    (Ederef
                      (Ebinop Oadd (Etempvar _step (tptr tfloat))
                        (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'30
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _currentAngle tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _step (tptr tfloat))
                          (Econst_int (Int.repr 2) tint) (tptr tfloat))
                        tfloat)
                      (Ebinop Oadd (Etempvar _t'29 tfloat)
                        (Ebinop Omul (Etempvar _currentSpeed tfloat)
                          (Etempvar _t'30 tfloat) tfloat) tfloat)))))))
          Sskip)))
    (Ssequence
      (Sset _i (Econst_int (Int.repr 0) tint))
      (Sloop
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _i tint)
                         (Econst_int (Int.repr 2) tint) tint)
            Sskip
            Sbreak)
          (Ssequence
            (Ssequence
              (Sset _t'26 (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
              (Sset _whirlpool
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef (Etempvar _t'26 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _whirlpools
                      (tarray (tptr (Tstruct _Whirlpool noattr)) 2))
                    (Etempvar _i tint)
                    (tptr (tptr (Tstruct _Whirlpool noattr))))
                  (tptr (Tstruct _Whirlpool noattr)))))
            (Sifthenelse (Ebinop One
                           (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                           (Ecast (Econst_int (Int.repr 0) tint)
                             (tptr tvoid)) tint)
              (Ssequence
                (Sset _strength
                  (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                (Ssequence
                  (Ssequence
                    (Sset _t'24
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                              (Tstruct _Whirlpool noattr)) _pos
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'25
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat))
                      (Sset _dx
                        (Ebinop Osub (Etempvar _t'24 tshort)
                          (Etempvar _t'25 tfloat) tfloat))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'22
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                (Tstruct _Whirlpool noattr)) _pos
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Ssequence
                        (Sset _t'23
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sset _dy
                          (Ebinop Osub (Etempvar _t'22 tshort)
                            (Etempvar _t'23 tfloat) tfloat))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'20
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                  (Tstruct _Whirlpool noattr)) _pos
                                (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'21
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat))
                          (Sset _dz
                            (Ebinop Osub (Etempvar _t'20 tshort)
                              (Etempvar _t'21 tfloat) tfloat))))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'1)
                            (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                           cc_default))
                            ((Ebinop Oadd
                               (Ebinop Omul (Etempvar _dx tfloat)
                                 (Etempvar _dx tfloat) tfloat)
                               (Ebinop Omul (Etempvar _dz tfloat)
                                 (Etempvar _dz tfloat) tfloat) tfloat) ::
                             nil))
                          (Sset _lateralDist (Etempvar _t'1 tfloat)))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'2)
                              (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                             cc_default))
                              ((Ebinop Oadd
                                 (Ebinop Omul (Etempvar _lateralDist tfloat)
                                   (Etempvar _lateralDist tfloat) tfloat)
                                 (Ebinop Omul (Etempvar _dy tfloat)
                                   (Etempvar _dy tfloat) tfloat) tfloat) ::
                               nil))
                            (Sset _distance (Etempvar _t'2 tfloat)))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'3)
                                (Evar _atan2s (Tfunction
                                                (tfloat :: tfloat :: nil)
                                                tshort cc_default))
                                ((Etempvar _lateralDist tfloat) ::
                                 (Etempvar _dy tfloat) :: nil))
                              (Sset _pitchToWhirlpool
                                (Ecast (Etempvar _t'3 tshort) tshort)))
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'4)
                                  (Evar _atan2s (Tfunction
                                                  (tfloat :: tfloat :: nil)
                                                  tshort cc_default))
                                  ((Etempvar _dz tfloat) ::
                                   (Etempvar _dx tfloat) :: nil))
                                (Sset _yawToWhirlpool
                                  (Ecast (Etempvar _t'4 tshort) tshort)))
                              (Ssequence
                                (Sset _yawToWhirlpool
                                  (Ecast
                                    (Ebinop Osub
                                      (Etempvar _yawToWhirlpool tshort)
                                      (Ecast
                                        (Ebinop Odiv
                                          (Ebinop Omul
                                            (Econst_int (Int.repr 8192) tint)
                                            (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                                            tfloat)
                                          (Ebinop Oadd
                                            (Etempvar _distance tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                                            tfloat) tfloat) tshort) tint)
                                    tshort))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
                                      (Efield
                                        (Ederef
                                          (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                          (Tstruct _Whirlpool noattr))
                                        _strength tshort))
                                    (Sifthenelse (Ebinop Oge
                                                   (Etempvar _t'15 tshort)
                                                   (Econst_int (Int.repr 0) tint)
                                                   tint)
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'18
                                              (Evar _gCurrLevelNum tshort))
                                            (Sifthenelse (Ebinop Oeq
                                                           (Etempvar _t'18 tshort)
                                                           (Econst_int (Int.repr 23) tint)
                                                           tint)
                                              (Ssequence
                                                (Sset _t'19
                                                  (Evar _gCurrAreaIndex tshort))
                                                (Sset _t'5
                                                  (Ecast
                                                    (Ebinop Oeq
                                                      (Etempvar _t'19 tshort)
                                                      (Econst_int (Int.repr 2) tint)
                                                      tint) tbool)))
                                              (Sset _t'5
                                                (Econst_int (Int.repr 0) tint))))
                                          (Sifthenelse (Etempvar _t'5 tint)
                                            (Sset _whirlpoolRadius
                                              (Econst_single (Float32.of_bits (Int.repr 1165623296)) tfloat))
                                            Sskip))
                                        (Ssequence
                                          (Sifthenelse (Ebinop Oge
                                                         (Etempvar _distance tfloat)
                                                         (Econst_single (Float32.of_bits (Int.repr 1104150528)) tfloat)
                                                         tint)
                                            (Sset _t'6
                                              (Ecast
                                                (Ebinop Olt
                                                  (Etempvar _distance tfloat)
                                                  (Etempvar _whirlpoolRadius tfloat)
                                                  tint) tbool))
                                            (Sset _t'6
                                              (Econst_int (Int.repr 0) tint)))
                                          (Sifthenelse (Etempvar _t'6 tint)
                                            (Ssequence
                                              (Sset _t'17
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                                    (Tstruct _Whirlpool noattr))
                                                  _strength tshort))
                                              (Sset _strength
                                                (Ebinop Omul
                                                  (Etempvar _t'17 tshort)
                                                  (Ebinop Osub
                                                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                                    (Ebinop Odiv
                                                      (Etempvar _distance tfloat)
                                                      (Etempvar _whirlpoolRadius tfloat)
                                                      tfloat) tfloat) tfloat)))
                                            Sskip)))
                                      (Sifthenelse (Ebinop Olt
                                                     (Etempvar _distance tfloat)
                                                     (Econst_single (Float32.of_bits (Int.repr 1157234688)) tfloat)
                                                     tint)
                                        (Ssequence
                                          (Sset _t'16
                                            (Efield
                                              (Ederef
                                                (Etempvar _whirlpool (tptr (Tstruct _Whirlpool noattr)))
                                                (Tstruct _Whirlpool noattr))
                                              _strength tshort))
                                          (Sset _strength
                                            (Ebinop Omul
                                              (Etempvar _t'16 tshort)
                                              (Ebinop Osub
                                                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                                (Ebinop Odiv
                                                  (Etempvar _distance tfloat)
                                                  (Econst_single (Float32.of_bits (Int.repr 1157234688)) tfloat)
                                                  tfloat) tfloat) tfloat)))
                                        Sskip)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'12
                                        (Ederef
                                          (Ebinop Oadd
                                            (Etempvar _step (tptr tfloat))
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr tfloat)) tfloat))
                                      (Ssequence
                                        (Sset _t'13
                                          (Ederef
                                            (Ebinop Oadd
                                              (Ebinop Oadd
                                                (Evar _gSineTable (tarray tfloat 0))
                                                (Econst_int (Int.repr 1024) tint)
                                                (tptr tfloat))
                                              (Ebinop Oshr
                                                (Ecast
                                                  (Etempvar _pitchToWhirlpool tshort)
                                                  tushort)
                                                (Econst_int (Int.repr 4) tint)
                                                tint) (tptr tfloat)) tfloat))
                                        (Ssequence
                                          (Sset _t'14
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gSineTable (tarray tfloat 0))
                                                (Ebinop Oshr
                                                  (Ecast
                                                    (Etempvar _yawToWhirlpool tshort)
                                                    tushort)
                                                  (Econst_int (Int.repr 4) tint)
                                                  tint) (tptr tfloat))
                                              tfloat))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _step (tptr tfloat))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tfloat)) tfloat)
                                            (Ebinop Oadd
                                              (Etempvar _t'12 tfloat)
                                              (Ebinop Omul
                                                (Ebinop Omul
                                                  (Etempvar _strength tfloat)
                                                  (Etempvar _t'13 tfloat)
                                                  tfloat)
                                                (Etempvar _t'14 tfloat)
                                                tfloat) tfloat)))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'10
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _step (tptr tfloat))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tfloat)) tfloat))
                                        (Ssequence
                                          (Sset _t'11
                                            (Ederef
                                              (Ebinop Oadd
                                                (Evar _gSineTable (tarray tfloat 0))
                                                (Ebinop Oshr
                                                  (Ecast
                                                    (Etempvar _pitchToWhirlpool tshort)
                                                    tushort)
                                                  (Econst_int (Int.repr 4) tint)
                                                  tint) (tptr tfloat))
                                              tfloat))
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Etempvar _step (tptr tfloat))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tfloat)) tfloat)
                                            (Ebinop Oadd
                                              (Etempvar _t'10 tfloat)
                                              (Ebinop Omul
                                                (Etempvar _strength tfloat)
                                                (Etempvar _t'11 tfloat)
                                                tfloat) tfloat))))
                                      (Ssequence
                                        (Sset _t'7
                                          (Ederef
                                            (Ebinop Oadd
                                              (Etempvar _step (tptr tfloat))
                                              (Econst_int (Int.repr 2) tint)
                                              (tptr tfloat)) tfloat))
                                        (Ssequence
                                          (Sset _t'8
                                            (Ederef
                                              (Ebinop Oadd
                                                (Ebinop Oadd
                                                  (Evar _gSineTable (tarray tfloat 0))
                                                  (Econst_int (Int.repr 1024) tint)
                                                  (tptr tfloat))
                                                (Ebinop Oshr
                                                  (Ecast
                                                    (Etempvar _pitchToWhirlpool tshort)
                                                    tushort)
                                                  (Econst_int (Int.repr 4) tint)
                                                  tint) (tptr tfloat))
                                              tfloat))
                                          (Ssequence
                                            (Sset _t'9
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Ebinop Oadd
                                                    (Evar _gSineTable (tarray tfloat 0))
                                                    (Econst_int (Int.repr 1024) tint)
                                                    (tptr tfloat))
                                                  (Ebinop Oshr
                                                    (Ecast
                                                      (Etempvar _yawToWhirlpool tshort)
                                                      tushort)
                                                    (Econst_int (Int.repr 4) tint)
                                                    tint) (tptr tfloat))
                                                tfloat))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Etempvar _step (tptr tfloat))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tfloat)) tfloat)
                                              (Ebinop Oadd
                                                (Etempvar _t'7 tfloat)
                                                (Ebinop Omul
                                                  (Ebinop Omul
                                                    (Etempvar _strength tfloat)
                                                    (Etempvar _t'8 tfloat)
                                                    tfloat)
                                                  (Etempvar _t'9 tfloat)
                                                  tfloat) tfloat)))))))))))))))))
              Sskip)))
        (Sset _i
          (Ebinop Oadd (Etempvar _i tint) (Econst_int (Int.repr 1) tint)
            tint))))))
|}.

Definition f_perform_water_step := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) ::
              (_nextPos, (tarray tfloat 3)) :: (_step, (tarray tfloat 3)) ::
              nil);
  fn_temps := ((_stepResult, tuint) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'1, tuint) :: (_t'14, tuint) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tfloat) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Scall None
      (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                          (tptr tvoid) cc_default))
      ((Evar _step (tarray tfloat 3)) ::
       (Efield
         (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
           (Tstruct _MarioState noattr)) _vel (tarray tfloat 3)) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 13) tint) tint) tuint)
          (Scall None
            (Evar _apply_water_current (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          (tptr tfloat) :: nil) tvoid
                                         cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Evar _step (tarray tfloat 3)) :: nil))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'13
              (Ederef
                (Ebinop Oadd (Evar _step (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'12 tfloat) (Etempvar _t'13 tfloat)
                tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd (Evar _step (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sassign
                (Ederef
                  (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                (Ebinop Oadd (Etempvar _t'10 tfloat) (Etempvar _t'11 tfloat)
                  tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd (Evar _step (tarray tfloat 3))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                      (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
                  (Ebinop Oadd (Etempvar _t'8 tfloat) (Etempvar _t'9 tfloat)
                    tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _waterLevel tshort))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                                 (Ebinop Osub (Etempvar _t'6 tshort)
                                   (Econst_int (Int.repr 80) tint) tint)
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _waterLevel
                            tshort))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd (Evar _nextPos (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Osub (Etempvar _t'7 tshort)
                            (Econst_int (Int.repr 80) tint) tint)))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
                    Sskip)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _perform_water_full_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      (tptr tfloat) :: nil)
                                                     tuint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Evar _nextPos (tarray tfloat 3)) :: nil))
                  (Sset _stepResult (Etempvar _t'1 tuint)))
                (Ssequence
                  (Scall None
                    (Evar _vec3f_copy (Tfunction
                                        ((tptr tfloat) :: (tptr tfloat) ::
                                         nil) (tptr tvoid) cc_default))
                    ((Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _pos
                       (tarray tfloat 3)) ::
                     (Efield
                       (Ederef
                         (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                         (Tstruct _MarioState noattr)) _pos
                       (tarray tfloat 3)) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'2
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
                        (Sset _t'3
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
                          (Sset _t'4
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort))
                          (Scall None
                            (Evar _vec3s_set (Tfunction
                                               ((tptr tshort) :: tshort ::
                                                tshort :: tshort :: nil)
                                               (tptr tvoid) cc_default))
                            ((Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr)) _angle
                               (tarray tshort 3)) ::
                             (Eunop Oneg (Etempvar _t'2 tshort) tint) ::
                             (Etempvar _t'3 tshort) ::
                             (Etempvar _t'4 tshort) :: nil)))))
                    (Sreturn (Some (Etempvar _stepResult tuint)))))))))))))
|}.

Definition f_update_water_pitch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tfloat) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Efield
                  (Ederef
                    (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _angle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _pos
                  (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Ebinop Oshr (Ecast (Etempvar _t'7 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _angle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr (Ecast (Etempvar _t'9 tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat)
                    (Ebinop Oadd (Etempvar _t'6 tfloat)
                      (Ebinop Omul
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                          (Etempvar _t'8 tfloat) tfloat)
                        (Etempvar _t'10 tfloat) tfloat) tfloat)))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _angle
                (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
              (tptr tshort)) tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'3 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort)
              (Ebinop Odiv
                (Ebinop Omul (Etempvar _t'4 tshort)
                  (Econst_int (Int.repr 6) tint) tint)
                (Econst_int (Int.repr 10) tint) tint)))
          Sskip))
      (Ssequence
        (Sset _t'1
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _angle
                (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
              (tptr tshort)) tshort))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'2
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort)
              (Ebinop Odiv
                (Ebinop Omul (Etempvar _t'2 tshort)
                  (Econst_int (Int.repr 10) tint) tint)
                (Econst_int (Int.repr 8) tint) tint)))
          Sskip)))))
|}.

Definition f_stationary_slow_down := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_buoyancy, tfloat) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tshort) ::
               (_t'16, tshort) :: (_t'15, tfloat) :: (_t'14, tshort) ::
               (_t'13, tfloat) :: (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_buoyancy (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: nil)
                            tfloat cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sset _buoyancy (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'2)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'19 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
               nil)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'2 tfloat)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'3)
                (Evar _approach_f32 (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       tfloat :: nil) tfloat cc_default))
                ((Etempvar _t'18 tfloat) :: (Etempvar _buoyancy tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                 nil)))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'3 tfloat)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Scall (Some _t'4)
                  (Evar _approach_s32 (Tfunction
                                        (tint :: tint :: tint :: tint :: nil)
                                        tint cc_default))
                  ((Etempvar _t'17 tshort) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 512) tint) ::
                   (Econst_int (Int.repr 512) tint) :: nil)))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort) (Etempvar _t'4 tint)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tshort)) tshort))
                  (Scall (Some _t'5)
                    (Evar _approach_s32 (Tfunction
                                          (tint :: tint :: tint :: tint ::
                                           nil) tint cc_default))
                    ((Etempvar _t'16 tshort) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 256) tint) ::
                     (Econst_int (Int.repr 256) tint) :: nil)))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                      (tptr tshort)) tshort) (Etempvar _t'5 tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'13
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'12 tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Ssequence
                        (Sset _t'14
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
                          (Sset _t'15
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'14 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 0) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Omul
                              (Ebinop Omul (Etempvar _t'11 tfloat)
                                (Etempvar _t'13 tfloat) tfloat)
                              (Etempvar _t'15 tfloat) tfloat)))))))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'7 tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Ssequence
                        (Sset _t'9
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
                          (Sset _t'10
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'9 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Omul
                              (Ebinop Omul (Etempvar _t'6 tfloat)
                                (Etempvar _t'8 tfloat) tfloat)
                              (Etempvar _t'10 tfloat) tfloat)))))))))))))))
|}.

Definition f_update_swimming_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_decelThreshold, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_buoyancy, tfloat) :: (_maxSpeed, tfloat) ::
               (_t'1, tfloat) :: (_t'20, tfloat) :: (_t'19, tuint) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tfloat) :: (_t'11, tshort) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tshort) :: (_t'4, tfloat) ::
               (_t'3, tshort) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_buoyancy (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: nil)
                            tfloat cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sset _buoyancy (Etempvar _t'1 tfloat)))
  (Ssequence
    (Sset _maxSpeed
      (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat))
    (Ssequence
      (Ssequence
        (Sset _t'19
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'19 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 9) tint) tint) tuint)
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Ebinop Osub (Etempvar _t'20 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                tfloat)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'18
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'18 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                         tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'17 tfloat)
                           (Etempvar _maxSpeed tfloat) tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Etempvar _maxSpeed tfloat))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'15 tfloat)
                             (Etempvar _decelThreshold tfloat) tint)
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Osub (Etempvar _t'16 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Ssequence
                  (Sset _t'11
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _t'11 tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'13
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
                        (Sset _t'14
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'13 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Omul
                            (Ebinop Omul (Etempvar _t'10 tfloat)
                              (Etempvar _t'12 tfloat) tfloat)
                            (Etempvar _t'14 tfloat) tfloat)))))))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'8
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'8 tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Oadd
                          (Ebinop Omul (Etempvar _t'7 tfloat)
                            (Etempvar _t'9 tfloat) tfloat)
                          (Etempvar _buoyancy tfloat) tfloat)))))
                (Ssequence
                  (Sset _t'2
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'3
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'4
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'3 tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Ssequence
                        (Sset _t'5
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
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'5 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 2) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Omul
                              (Ebinop Omul (Etempvar _t'2 tfloat)
                                (Etempvar _t'4 tfloat) tfloat)
                              (Etempvar _t'6 tfloat) tfloat)))))))))))))))
|}.

Definition f_update_swimming_yaw := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetYawVel, tshort) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'17, tfloat) ::
               (_t'16, (tptr (Tstruct _Controller noattr))) ::
               (_t'15, tshort) :: (_t'14, tshort) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _controller
        (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _t'16 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _stickX tfloat))
      (Sset _targetYawVel
        (Ecast
          (Eunop Oneg
            (Ecast
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                (Etempvar _t'17 tfloat) tfloat) tshort) tint) tshort))))
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _targetYawVel tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'12
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'12 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'15 tshort)
                  (Econst_int (Int.repr 64) tint) tint)))
            (Ssequence
              (Sset _t'14
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tshort)
                             (Econst_int (Int.repr 16) tint) tint)
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort) (Econst_int (Int.repr 16) tint))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Scall (Some _t'1)
                (Evar _approach_s32 (Tfunction
                                      (tint :: tint :: tint :: tint :: nil)
                                      tint cc_default))
                ((Etempvar _t'13 tshort) ::
                 (Etempvar _targetYawVel tshort) ::
                 (Econst_int (Int.repr 16) tint) ::
                 (Econst_int (Int.repr 32) tint) :: nil)))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort) (Etempvar _t'1 tint)))))
      (Sifthenelse (Ebinop Olt (Etempvar _targetYawVel tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'8
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort)
                  (Ebinop Osub (Etempvar _t'11 tshort)
                    (Econst_int (Int.repr 64) tint) tint)))
              (Ssequence
                (Sset _t'10
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'10 tshort)
                               (Eunop Oneg (Econst_int (Int.repr 16) tint)
                                 tint) tint)
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _angleVel
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Eunop Oneg (Econst_int (Int.repr 16) tint) tint))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Scall (Some _t'2)
                  (Evar _approach_s32 (Tfunction
                                        (tint :: tint :: tint :: tint :: nil)
                                        tint cc_default))
                  ((Etempvar _t'9 tshort) ::
                   (Etempvar _targetYawVel tshort) ::
                   (Econst_int (Int.repr 32) tint) ::
                   (Econst_int (Int.repr 16) tint) :: nil)))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort) (Etempvar _t'2 tint)))))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Scall (Some _t'3)
              (Evar _approach_s32 (Tfunction
                                    (tint :: tint :: tint :: tint :: nil)
                                    tint cc_default))
              ((Etempvar _t'7 tshort) :: (Econst_int (Int.repr 0) tint) ::
               (Econst_int (Int.repr 64) tint) ::
               (Econst_int (Int.repr 64) tint) :: nil)))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort) (Etempvar _t'3 tint)))))
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
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'5 tshort) (Etempvar _t'6 tshort) tint))))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
          (Ebinop Omul (Eunop Oneg (Etempvar _t'4 tshort) tint)
            (Econst_int (Int.repr 8) tint) tint))))))
|}.

Definition f_update_swimming_pitch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetPitch, tshort) :: (_pitchVel, tshort) ::
               (_t'2, tshort) :: (_t'1, tshort) :: (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _Controller noattr))) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _controller
        (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _t'8 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _stickY tfloat))
      (Sset _targetPitch
        (Ecast
          (Eunop Oneg
            (Ecast
              (Ebinop Omul
                (Econst_single (Float32.of_bits (Int.repr 1132199936)) tfloat)
                (Etempvar _t'9 tfloat) tfloat) tshort) tint) tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'7 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _pitchVel (Ecast (Econst_int (Int.repr 256) tint) tshort))
        (Sset _pitchVel (Ecast (Econst_int (Int.repr 512) tint) tshort))))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'3 tshort)
                     (Etempvar _targetPitch tshort) tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oadd (Etempvar _t'6 tshort)
                    (Etempvar _pitchVel tshort) tint) tshort)))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort) (Etempvar _t'1 tshort)))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tshort)
                         (Etempvar _targetPitch tshort) tint)
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort) (Etempvar _targetPitch tshort))
            Sskip))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tshort)
                         (Etempvar _targetPitch tshort) tint)
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort))
                  (Sset _t'2
                    (Ecast
                      (Ebinop Osub (Etempvar _t'5 tshort)
                        (Etempvar _pitchVel tshort) tint) tshort)))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort) (Etempvar _t'2 tshort)))
              (Sifthenelse (Ebinop Olt (Etempvar _t'2 tshort)
                             (Etempvar _targetPitch tshort) tint)
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort) (Etempvar _targetPitch tshort))
                Sskip))
            Sskip))))))
|}.

Definition f_common_idle_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_arg, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_val, (tptr tshort)) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'7, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioBodyState
        (tptr (Tstruct _MarioBodyState noattr))))
    (Sset _val
      (Ebinop Oadd
        (Efield
          (Ederef (Etempvar _t'7 (tptr (Tstruct _MarioBodyState noattr)))
            (Tstruct _MarioBodyState noattr)) _headAngle (tarray tshort 3))
        (Econst_int (Int.repr 0) tint) (tptr tshort))))
  (Ssequence
    (Scall None
      (Evar _update_swimming_yaw (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_swimming_pitch (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_swimming_speed (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
           nil))
        (Ssequence
          (Scall None
            (Evar _perform_water_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _update_water_pitch (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tshort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Ederef (Etempvar _val (tptr tshort)) tshort))
                      (Ssequence
                        (Sset _t'6
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Scall (Some _t'1)
                          (Evar _approach_s32 (Tfunction
                                                (tint :: tint :: tint ::
                                                 tint :: nil) tint
                                                cc_default))
                          ((Etempvar _t'5 tshort) ::
                           (Ebinop Odiv (Etempvar _t'6 tshort)
                             (Econst_int (Int.repr 2) tint) tint) ::
                           (Econst_int (Int.repr 128) tint) ::
                           (Econst_int (Int.repr 512) tint) :: nil))))
                    (Sassign (Ederef (Etempvar _val (tptr tshort)) tshort)
                      (Etempvar _t'1 tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Ederef (Etempvar _val (tptr tshort)) tshort))
                      (Scall (Some _t'2)
                        (Evar _approach_s32 (Tfunction
                                              (tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
                        ((Etempvar _t'4 tshort) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 512) tint) ::
                         (Econst_int (Int.repr 512) tint) :: nil)))
                    (Sassign (Ederef (Etempvar _val (tptr tshort)) tshort)
                      (Etempvar _t'2 tint)))))
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _arg tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _animation tint) :: nil))
                  (Scall None
                    (Evar _set_mario_anim_with_accel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: tint :: nil)
                                                       tshort cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _animation tint) :: (Etempvar _arg tint) ::
                     nil)))
                (Scall None
                  (Evar _set_swimming_at_surface_particles (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint :: nil)
                                                             tvoid
                                                             cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 7) tint) tint) :: nil))))))))))
|}.

Definition f_act_water_idle := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'7, tuint) :: (_t'6, tushort) ::
               (_t'5, tushort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _val (Econst_int (Int.repr 65536) tint))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                     (Econst_int (Int.repr 4) tint) tuint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17140) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315809) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315792) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'4 tshort)
                           (Eunop Oneg (Econst_int (Int.repr 4096) tint)
                             tint) tint)
              (Sset _val (Econst_int (Int.repr 196608) tint))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _common_idle_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tint :: tint :: nil) tvoid
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 178) tint) :: (Etempvar _val tuint) ::
               nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_water_idle := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'9, tuint) :: (_t'8, tint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17141) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'8
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'8 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532992) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315808) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315795) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _common_idle_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 164) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_water_action_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'7, tuint) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17140) tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 805315809) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315792) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _common_idle_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 173) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'4)
              (Evar _is_anim_at_end (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'4 tint)
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 939532992) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_water_action_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'12, tuint) :: (_t'11, tint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'12 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17141) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'11 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532992) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315808) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315795) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sset _t'5 (Ecast (Econst_int (Int.repr 162) tint) tint))
                (Sset _t'5 (Ecast (Econst_int (Int.repr 163) tint) tint))))
            (Scall None
              (Evar _common_idle_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tint :: tint :: nil) tvoid
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _t'5 tint) :: (Econst_int (Int.repr 0) tint) :: nil)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'6)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'6 tint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 939532993) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_reset_bob_variables := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _sBobTimer tshort) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign (Evar _sBobIncrement tshort) (Econst_int (Int.repr 2048) tint))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sassign (Evar _sBobHeight tfloat)
        (Ebinop Oadd
          (Ebinop Odiv (Etempvar _t'1 tshort)
            (Econst_single (Float32.of_bits (Int.repr 1132462080)) tfloat)
            tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
          tfloat)))))
|}.

Definition f_surface_swim_bob := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'15, tshort) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'13 (Evar _sBobIncrement tshort))
        (Sifthenelse (Ebinop One (Etempvar _t'13 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _waterLevel tshort))
              (Sset _t'2
                (Ecast
                  (Ebinop Ogt (Etempvar _t'14 tfloat)
                    (Ebinop Osub (Etempvar _t'15 tshort)
                      (Econst_int (Int.repr 85) tint) tint) tint) tbool))))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'12
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Sset _t'3
            (Ecast
              (Ebinop Oge (Etempvar _t'12 tshort)
                (Econst_int (Int.repr 0) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'10 (Evar _sBobTimer tshort))
            (Ssequence
              (Sset _t'11 (Evar _sBobIncrement tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oadd (Etempvar _t'10 tshort)
                    (Etempvar _t'11 tshort) tint) tshort))))
          (Sassign (Evar _sBobTimer tshort) (Etempvar _t'1 tshort)))
        (Sifthenelse (Ebinop Oge (Etempvar _t'1 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
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
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'7 (Evar _sBobHeight tfloat))
                    (Ssequence
                      (Sset _t'8 (Evar _sBobTimer tshort))
                      (Ssequence
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'8 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Oadd (Etempvar _t'6 tfloat)
                            (Ebinop Omul (Etempvar _t'7 tfloat)
                              (Etempvar _t'9 tfloat) tfloat) tfloat))))))))
            (Sreturn None))
          Sskip))
      Sskip))
  (Sassign (Evar _sBobIncrement tshort) (Econst_int (Int.repr 0) tint)))
|}.

Definition f_common_swimming_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_swimStrength, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorPitch, tshort) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_t'3, tint) :: (_t'2, tshort) :: (_t'1, tuint) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Controller noattr))) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Scall None
      (Evar _update_swimming_yaw (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_swimming_pitch (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_swimming_speed (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Odiv (Etempvar _swimStrength tshort)
             (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
             tfloat) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _perform_water_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sswitch (Etempvar _t'1 tuint)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _find_floor_slope (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tshort :: nil) tshort
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Eunop Oneg (Econst_int (Int.repr 32768) tint) tint) ::
                       nil))
                    (Sset _floorPitch
                      (Ecast (Eunop Oneg (Etempvar _t'2 tshort) tint) tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'16
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'16 tshort)
                                     (Etempvar _floorPitch tshort) tint)
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort) (Etempvar _floorPitch tshort))
                        Sskip))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tshort)
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 12288) tint)
                                       tint) tint)
                        (Ssequence
                          (Sset _t'15
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
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
                            (Ebinop Osub (Etempvar _t'15 tshort)
                              (Econst_int (Int.repr 256) tint) tint)))
                        Sskip))
                    Sbreak)
                  (LScons (Some 4)
                    (Ssequence
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _controller
                            (tptr (Tstruct _Controller noattr))))
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _t'7 (tptr (Tstruct _Controller noattr)))
                                (Tstruct _Controller noattr)) _stickY tfloat))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                         tint)
                            (Ssequence
                              (Sset _t'9
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _faceAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort))
                              (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tshort)
                                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                             tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'13
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tshort)) tshort))
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
                                      (Ebinop Oadd (Etempvar _t'13 tshort)
                                        (Econst_int (Int.repr 512) tint)
                                        tint)))
                                  (Ssequence
                                    (Sset _t'12
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tshort)) tshort))
                                    (Sifthenelse (Ebinop Ogt
                                                   (Etempvar _t'12 tshort)
                                                   (Econst_int (Int.repr 16128) tint)
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
                                        (Econst_int (Int.repr 16128) tint))
                                      Sskip)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'11
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tshort)) tshort))
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
                                      (Ebinop Osub (Etempvar _t'11 tshort)
                                        (Econst_int (Int.repr 512) tint)
                                        tint)))
                                  (Ssequence
                                    (Sset _t'10
                                      (Ederef
                                        (Ebinop Oadd
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _faceAngle (tarray tshort 3))
                                          (Econst_int (Int.repr 0) tint)
                                          (tptr tshort)) tshort))
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _t'10 tshort)
                                                   (Eunop Oneg
                                                     (Econst_int (Int.repr 16128) tint)
                                                     tint) tint)
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
                                        (Eunop Oneg
                                          (Econst_int (Int.repr 16128) tint)
                                          tint))
                                      Sskip)))))
                            Sskip)))
                      Sbreak)
                    LSnil)))))
          (Ssequence
            (Scall None
              (Evar _update_water_pitch (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Ssequence
                    (Sset _t'6
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _headAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Scall (Some _t'3)
                      (Evar _approach_s32 (Tfunction
                                            (tint :: tint :: tint :: tint ::
                                             nil) tint cc_default))
                      ((Etempvar _t'6 tshort) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 512) tint) ::
                       (Econst_int (Int.repr 512) tint) :: nil))))
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _headAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort) (Etempvar _t'3 tint))))
              (Ssequence
                (Scall None
                  (Evar _surface_swim_bob (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Scall None
                  (Evar _set_swimming_at_surface_particles (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint :: nil)
                                                             tvoid
                                                             cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                     (Econst_int (Int.repr 10) tint) tint) :: nil))))))))))
|}.

Definition f_play_swimming_noise := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tshort) :: (_t'1, tint) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
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
        (Efield
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _animFrame tshort))
      (Sset _animFrame (Ecast (Etempvar _t'4 tshort) tshort))))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _t'1 (Econst_int (Int.repr 1) tint))
      (Sset _t'1
        (Ecast
          (Ebinop Oeq (Etempvar _animFrame tshort)
            (Econst_int (Int.repr 12) tint) tint) tbool)))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 52) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      Sskip)))
|}.

Definition f_check_water_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_probe, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'11, tfloat) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Controller noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Sset _probe
      (Ecast
        (Ebinop Oadd (Etempvar _t'11 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
          tfloat) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _waterLevel tshort))
              (Sifthenelse (Ebinop Oge (Etempvar _probe tint)
                             (Ebinop Osub (Etempvar _t'9 tshort)
                               (Econst_int (Int.repr 80) tint) tint) tint)
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort))
                  (Sset _t'3
                    (Ecast
                      (Ebinop Oge (Etempvar _t'10 tshort)
                        (Econst_int (Int.repr 0) tint) tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _t'7 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickY tfloat))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Olt (Etempvar _t'8 tfloat)
                        (Eunop Oneg
                          (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                          tfloat) tint) tbool))))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Scall None
                (Evar _vec3s_set (Tfunction
                                   ((tptr tshort) :: tshort :: tshort ::
                                    tshort :: nil) (tptr tvoid) cc_default))
                ((Efield
                   (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                     (Tstruct _MarioState noattr)) _angleVel
                   (tarray tshort 3)) :: (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
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
                  (Econst_single (Float32.of_bits (Int.repr 1115160576)) tfloat))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _heldObj
                      (tptr (Tstruct _Object noattr))))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Ssequence
                      (Scall (Some _t'1)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 16779401) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'1 tuint))))
                    (Ssequence
                      (Scall (Some _t'2)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 16779427) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'2 tuint))))))))
            Sskip))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_breaststroke := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tuint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tushort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'25, tuint) ::
               (_t'24, tuint) :: (_t'23, tushort) :: (_t'22, tushort) ::
               (_t'21, tfloat) :: (_t'20, tushort) :: (_t'19, tfloat) ::
               (_t'18, tushort) :: (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tshort) :: (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tushort) :: (_t'9, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'25
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'25 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sassign (Evar _sSwimStrength tshort) (Econst_int (Int.repr 160) tint))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'24
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'24 tuint)
                     (Econst_int (Int.repr 4) tint) tuint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17140) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'23
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'23 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315809) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'22
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sset _t'4
                (Ecast
                  (Ebinop Oadd (Etempvar _t'22 tushort)
                    (Econst_int (Int.repr 1) tint) tint) tushort)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Etempvar _t'4 tushort)))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                         (Econst_int (Int.repr 14) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315794) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'5)
              (Evar _check_water_jump (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'5 tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Olt (Etempvar _t'20 tushort)
                             (Econst_int (Int.repr 6) tint) tint)
                (Ssequence
                  (Sset _t'21
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Oadd (Etempvar _t'21 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'18 tushort)
                               (Econst_int (Int.repr 9) tint) tint)
                  (Ssequence
                    (Sset _t'19
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Oadd (Etempvar _t'19 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
                        tfloat)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'13 tushort)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'16
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'16 tushort)
                                         (Econst_int (Int.repr 6) tint) tint)
                            (Ssequence
                              (Sset _t'17
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort))
                              (Sset _t'6
                                (Ecast
                                  (Ebinop Oand (Etempvar _t'17 tushort)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tbool)))
                            (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'6 tint)
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort) (Econst_int (Int.repr 1) tint))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'14
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tushort)
                                         (Econst_int (Int.repr 9) tint) tint)
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionState tushort))
                              (Sset _t'7
                                (Ecast
                                  (Ebinop Oeq (Etempvar _t'15 tushort)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tbool)))
                            (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'7 tint)
                          (Ssequence
                            (Scall None
                              (Evar _set_anim_to_frame (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tshort :: nil)
                                                         tvoid cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionState tushort)
                                (Econst_int (Int.repr 0) tint))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _actionTimer tushort)
                                  (Econst_int (Int.repr 1) tint))
                                (Sassign (Evar _sSwimStrength tshort)
                                  (Econst_int (Int.repr 160) tint)))))
                          Sskip)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'12 (Evar _sSwimStrength tshort))
                            (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tshort)
                                           (Econst_int (Int.repr 160) tint)
                                           tint)
                              (Sset _t'8
                                (Ecast
                                  (Ebinop Oor
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
                                              (Econst_int (Int.repr 51) tint)
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
                                    (Econst_int (Int.repr 1) tint) tuint)
                                  tuint))
                              (Sset _t'8
                                (Ecast
                                  (Ebinop Oor
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
                                              (Econst_int (Int.repr 71) tint)
                                              tuint)
                                            (Econst_int (Int.repr 16) tint)
                                            tuint) tuint)
                                        (Ebinop Oshl
                                          (Ecast
                                            (Econst_int (Int.repr 160) tint)
                                            tuint)
                                          (Econst_int (Int.repr 8) tint)
                                          tuint) tuint)
                                      (Ebinop Oor
                                        (Econst_int (Int.repr 67108864) tint)
                                        (Econst_int (Int.repr 128) tint)
                                        tint) tuint)
                                    (Econst_int (Int.repr 1) tint) tuint)
                                  tuint))))
                          (Ssequence
                            (Sset _t'11
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Etempvar _t'8 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil))))
                        (Scall None
                          (Evar _reset_bob_variables (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil)))
                      Sskip))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 170) tint) :: nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'9 (Evar _sSwimStrength tshort))
                        (Scall None
                          (Evar _common_swimming_step (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tshort :: nil) tvoid
                                                        cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _t'9 tshort) :: nil)))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_act_swimming_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tint) :: (_t'6, tuint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'19, tuint) :: (_t'18, tushort) ::
               (_t'17, tushort) :: (_t'16, tushort) :: (_t'15, tushort) ::
               (_t'14, tshort) :: (_t'13, tushort) :: (_t'12, tshort) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tfloat) ::
               (_t'8, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'19 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17140) tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 805315809) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'17
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oge (Etempvar _t'17 tushort)
                       (Econst_int (Int.repr 15) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315266) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _check_water_jump (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'4 tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                             (Econst_int (Int.repr 128) tint) tint)
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sset _t'7
                    (Ecast
                      (Ebinop Oge (Etempvar _t'16 tushort)
                        (Econst_int (Int.repr 7) tint) tint) tbool)))
                (Sset _t'7 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'7 tint)
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                                   (Econst_int (Int.repr 7) tint) tint)
                      (Ssequence
                        (Sset _t'14 (Evar _sSwimStrength tshort))
                        (Sset _t'5
                          (Ecast
                            (Ebinop Olt (Etempvar _t'14 tshort)
                              (Econst_int (Int.repr 280) tint) tint) tbool)))
                      (Sset _t'5 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Sset _t'12 (Evar _sSwimStrength tshort))
                      (Sassign (Evar _sSwimStrength tshort)
                        (Ebinop Oadd (Etempvar _t'12 tshort)
                          (Econst_int (Int.repr 10) tint) tint)))
                    Sskip))
                (Ssequence
                  (Scall (Some _t'6)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 805315792) tint) ::
                     (Econst_int (Int.repr 1) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'6 tuint)))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'11 tushort)
                             (Econst_int (Int.repr 7) tint) tint)
                (Sassign (Evar _sSwimStrength tshort)
                  (Econst_int (Int.repr 160) tint))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'10 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Osub (Etempvar _t'9 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat)
                      tfloat)))
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 171) tint) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8 (Evar _sSwimStrength tshort))
                      (Scall None
                        (Evar _common_swimming_step (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tshort :: nil) tvoid
                                                      cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _t'8 tshort) :: nil)))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_flutter_kick := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tfloat) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'14, tuint) ::
               (_t'13, tushort) :: (_t'12, tshort) :: (_t'11, tushort) ::
               (_t'10, tshort) :: (_t'9, tushort) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'14 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17140) tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 805315809) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
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
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'12 (Evar _sSwimStrength tshort))
                    (Sset _t'3
                      (Ecast
                        (Ebinop Olt (Etempvar _t'12 tshort)
                          (Econst_int (Int.repr 280) tint) tint) tbool)))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'3 tint)
                (Ssequence
                  (Sset _t'10 (Evar _sSwimStrength tshort))
                  (Sassign (Evar _sSwimStrength tshort)
                    (Ebinop Oadd (Etempvar _t'10 tshort)
                      (Econst_int (Int.repr 10) tint) tint)))
                Sskip))
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315793) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'5)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'8 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1041865114)) tfloat) ::
               nil)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'5 tfloat)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sassign (Evar _sSwimStrength tshort)
              (Econst_int (Int.repr 160) tint))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'7 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1096810496)) tfloat)
                               tint)
                  (Ssequence
                    (Scall None
                      (Evar _play_swimming_noise (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 172) tint) :: nil)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'6 (Evar _sSwimStrength tshort))
                  (Scall None
                    (Evar _common_swimming_step (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tshort :: nil) tvoid
                                                  cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'6 tshort) :: nil)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_hold_breaststroke := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tuint) :: (_t'4, tushort) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'24, tuint) ::
               (_t'23, tint) :: (_t'22, (tptr (Tstruct _Object noattr))) ::
               (_t'21, tushort) :: (_t'20, tushort) :: (_t'19, tfloat) ::
               (_t'18, tushort) :: (_t'17, tfloat) :: (_t'16, tushort) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tushort) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'24
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'24 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17141) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'22
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'23
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'23 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532992) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'4
              (Ecast
                (Ebinop Oadd (Etempvar _t'21 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'4 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 17) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315797) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'20
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'20 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'5)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315808) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'5 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'6)
              (Evar _check_water_jump (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'6 tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Olt (Etempvar _t'18 tushort)
                             (Econst_int (Int.repr 6) tint) tint)
                (Ssequence
                  (Sset _t'19
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Oadd (Etempvar _t'19 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'16 tushort)
                               (Econst_int (Int.repr 9) tint) tint)
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Oadd (Etempvar _t'17 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
                        tfloat)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'11 tushort)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'14
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'14 tushort)
                                         (Econst_int (Int.repr 6) tint) tint)
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort))
                              (Sset _t'7
                                (Ecast
                                  (Ebinop Oand (Etempvar _t'15 tushort)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  tbool)))
                            (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'7 tint)
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort) (Econst_int (Int.repr 1) tint))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                                         (Econst_int (Int.repr 9) tint) tint)
                            (Ssequence
                              (Sset _t'13
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionState tushort))
                              (Sset _t'8
                                (Ecast
                                  (Ebinop Oeq (Etempvar _t'13 tushort)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tbool)))
                            (Sset _t'8 (Econst_int (Int.repr 0) tint))))
                        (Sifthenelse (Etempvar _t'8 tint)
                          (Ssequence
                            (Scall None
                              (Evar _set_anim_to_frame (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tshort :: nil)
                                                         tvoid cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionState tushort)
                                (Econst_int (Int.repr 0) tint))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionTimer tushort)
                                (Econst_int (Int.repr 1) tint))))
                          Sskip)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Scall None
                            (Evar _play_sound (Tfunction
                                                (tint :: (tptr tfloat) ::
                                                 nil) tvoid cc_default))
                            ((Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 51) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 128) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        (Scall None
                          (Evar _reset_bob_variables (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil)))
                      Sskip))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 159) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _common_swimming_step (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tshort :: nil) tvoid
                                                      cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 160) tint) :: nil))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_act_hold_swimming_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tint) :: (_t'6, tuint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'16, tuint) :: (_t'15, tint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tushort) :: (_t'12, tushort) :: (_t'11, tushort) ::
               (_t'10, tushort) :: (_t'9, tushort) :: (_t'8, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'16 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17141) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'15
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'15 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532992) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'13
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sifthenelse (Ebinop Oge (Etempvar _t'13 tushort)
                       (Econst_int (Int.repr 15) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315267) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315808) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'5)
              (Evar _check_water_jump (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'5 tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                               (Econst_int (Int.repr 128) tint) tint)
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sset _t'7
                      (Ecast
                        (Ebinop Oge (Etempvar _t'11 tushort)
                          (Econst_int (Int.repr 7) tint) tint) tbool)))
                  (Sset _t'7 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'7 tint)
                (Ssequence
                  (Scall (Some _t'6)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 805315795) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'6 tuint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'9 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Osub (Etempvar _t'8 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat)
                      tfloat)))
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 160) tint) :: nil))
                  (Ssequence
                    (Scall None
                      (Evar _common_swimming_step (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tshort :: nil) tvoid
                                                    cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 160) tint) :: nil))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_hold_flutter_kick := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tfloat) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'12, tuint) ::
               (_t'11, tint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'12 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 17141) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'11
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'11 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532992) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 805315808) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'8 tushort)
                           (Econst_int (Int.repr 128) tint) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 805315796) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Scall (Some _t'5)
                (Evar _approach_f32 (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       tfloat :: nil) tfloat cc_default))
                ((Etempvar _t'7 tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1041865114)) tfloat) ::
                 nil)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Etempvar _t'5 tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'6 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1096810496)) tfloat)
                             tint)
                (Ssequence
                  (Scall None
                    (Evar _play_swimming_noise (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 161) tint) :: nil)))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _common_swimming_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tshort :: nil) tvoid
                                              cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 160) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_water_shell_swimming := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tfloat) :: (_t'3, tushort) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'9 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532992) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 805315808) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Ebinop Oadd (Etempvar _t'3 tushort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 240) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 22) tint) tint)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr)))
                (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
              (Ssequence
                (Scall None
                  (Evar _stop_shell_music (Tfunction nil tvoid cc_default))
                  nil)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 805315794) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'4)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'5 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
               nil)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'4 tfloat)))
        (Ssequence
          (Scall None
            (Evar _play_swimming_noise (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 161) tint) :: nil))
            (Ssequence
              (Scall None
                (Evar _common_swimming_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tshort :: nil) tvoid
                                              cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 300) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_check_water_grab := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_object, (tptr (Tstruct _Object noattr))) :: (_dx, tfloat) ::
               (_dz, tfloat) :: (_dAngleToObject, tshort) :: (_t'3, tint) ::
               (_t'2, tshort) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, tuint) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
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
          (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
            (Tstruct _Object noattr)) _collidedObjInteractTypes tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 1) tint) tint) tuint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _mario_get_collided_object (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: nil)
                                                 (tptr (Tstruct _Object noattr))
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                 (Econst_int (Int.repr 1) tint) tint) :: nil))
            (Sset _object (Etempvar _t'1 (tptr (Tstruct _Object noattr)))))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _object (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                    (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                      (Econst_int (Int.repr 0) tint) tint) (tptr tfloat))
                  tfloat))
              (Ssequence
                (Sset _t'11
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Sset _dx
                  (Ebinop Osub (Etempvar _t'10 tfloat)
                    (Etempvar _t'11 tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _object (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                      (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                        (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat))
                  (Sset _dz
                    (Ebinop Osub (Etempvar _t'8 tfloat)
                      (Etempvar _t'9 tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Etempvar _dz tfloat) :: (Etempvar _dx tfloat) :: nil))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Sset _dAngleToObject
                      (Ecast
                        (Ebinop Osub (Etempvar _t'2 tshort)
                          (Etempvar _t'7 tshort) tint) tshort))))
                (Ssequence
                  (Sifthenelse (Ebinop Oge (Etempvar _dAngleToObject tshort)
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 10922) tint) tint)
                                 tint)
                    (Sset _t'3
                      (Ecast
                        (Ebinop Ole (Etempvar _dAngleToObject tshort)
                          (Econst_int (Int.repr 10922) tint) tint) tbool))
                    (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'3 tint)
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _usedObj
                          (tptr (Tstruct _Object noattr)))
                        (Etempvar _object (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Scall None
                          (Evar _mario_grab_used_object (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _marioBodyState
                                (tptr (Tstruct _MarioBodyState noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr)) _grabPos
                                tschar) (Econst_int (Int.repr 1) tint)))
                          (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
                    Sskip))))))
        Sskip)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_water_throw := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tushort) :: (_t'1, tint) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _update_swimming_yaw (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) :: nil)
                                 tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _update_swimming_pitch (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_swimming_speed (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
         nil))
      (Ssequence
        (Scall None
          (Evar _perform_water_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _update_water_pitch (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 177) tint) :: nil))
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
                           (Ecast (Econst_int (Int.repr 51) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 65536) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioBodyState
                        (tptr (Tstruct _MarioBodyState noattr))))
                    (Ssequence
                      (Sset _t'6
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _headAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort))
                      (Scall (Some _t'1)
                        (Evar _approach_s32 (Tfunction
                                              (tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
                        ((Etempvar _t'6 tshort) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 512) tint) ::
                         (Econst_int (Int.repr 512) tint) :: nil))))
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioBodyState
                        (tptr (Tstruct _MarioBodyState noattr))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _headAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort) (Etempvar _t'1 tint))))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort)
                        (Ebinop Oadd (Etempvar _t'2 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                                   (Econst_int (Int.repr 5) tint) tint)
                      (Scall None
                        (Evar _mario_throw_held_object (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _is_anim_at_end (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sifthenelse (Etempvar _t'3 tint)
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 939532992) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sskip))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_water_punch := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, (tptr tvoid)) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'10, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'9, (tptr tuint)) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Sifthenelse (Ebinop Olt (Etempvar _t'13 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1088421888)) tfloat)
                   tint)
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat)
          (Ebinop Oadd (Etempvar _t'14 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
            tfloat)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _update_swimming_yaw (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_swimming_pitch (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_swimming_speed (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
           nil))
        (Ssequence
          (Scall None
            (Evar _perform_water_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _update_water_pitch (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _t'11 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _headAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Scall (Some _t'1)
                      (Evar _approach_s32 (Tfunction
                                            (tint :: tint :: tint :: tint ::
                                             nil) tint cc_default))
                      ((Etempvar _t'12 tshort) ::
                       (Econst_int (Int.repr 0) tint) ::
                       (Econst_int (Int.repr 512) tint) ::
                       (Econst_int (Int.repr 512) tint) :: nil))))
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'10 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _headAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort) (Etempvar _t'1 tint))))
              (Ssequence
                (Scall None
                  (Evar _play_sound_if_no_flag (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil)
                                                 tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 51) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Econst_int (Int.repr 65536) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sswitch (Etempvar _t'7 tushort)
                      (LScons (Some 0)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 176) tint) :: nil))
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'3)
                                (Evar _is_anim_at_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sifthenelse (Etempvar _t'3 tint)
                                (Ssequence
                                  (Scall (Some _t'2)
                                    (Evar _check_water_grab (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort)
                                    (Ebinop Oadd (Etempvar _t'2 tint)
                                      (Econst_int (Int.repr 1) tint) tint)))
                                Sskip))
                            Sbreak))
                        (LScons (Some 1)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_animation (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 175) tint) :: nil))
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'4)
                                  (Evar _is_anim_at_end (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sifthenelse (Etempvar _t'4 tint)
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 805315266) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sskip))
                              Sbreak))
                          (LScons (Some 2)
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_animation (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tint :: nil)
                                                             tshort
                                                             cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 174) tint) :: nil))
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'6)
                                    (Evar _is_anim_at_end (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sifthenelse (Etempvar _t'6 tint)
                                    (Ssequence
                                      (Scall (Some _t'5)
                                        (Evar _segmented_to_virtual (Tfunction
                                                                    ((tptr tvoid) ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                        ((Evar _bhvKoopaShellUnderwater (tarray tuint 0)) ::
                                         nil))
                                      (Ssequence
                                        (Sset _t'8
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _heldObj
                                            (tptr (Tstruct _Object noattr))))
                                        (Ssequence
                                          (Sset _t'9
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                                (Tstruct _Object noattr))
                                              _behavior (tptr tuint)))
                                          (Sifthenelse (Ebinop Oeq
                                                         (Etempvar _t'9 (tptr tuint))
                                                         (Etempvar _t'5 (tptr tvoid))
                                                         tint)
                                            (Ssequence
                                              (Scall None
                                                (Evar _play_shell_music 
                                                (Tfunction nil tvoid
                                                  cc_default)) nil)
                                              (Scall None
                                                (Evar _set_mario_action 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 (Econst_int (Int.repr 805315798) tint) ::
                                                 (Econst_int (Int.repr 0) tint) ::
                                                 nil)))
                                            (Scall None
                                              (Evar _set_mario_action 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               (Econst_int (Int.repr 805315267) tint) ::
                                               (Econst_int (Int.repr 1) tint) ::
                                               nil))))))
                                    Sskip))
                                Sbreak))
                            LSnil)))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_common_water_knockback_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_endAction, tuint) :: (_arg3, tint) ::
                nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tuint) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_slow_down (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _perform_water_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _animation tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioBodyState
              (tptr (Tstruct _MarioBodyState noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _headAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Scall (Some _t'2)
            (Evar _is_anim_at_end (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sifthenelse (Ebinop Ogt (Etempvar _arg3 tint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _invincTimer tshort)
                  (Econst_int (Int.repr 30) tint))
                Sskip)
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'3 tshort)
                                 (Econst_int (Int.repr 256) tint) tint)
                    (Sset _t'1 (Ecast (Etempvar _endAction tuint) tuint))
                    (Sset _t'1
                      (Ecast (Econst_int (Int.repr 805319367) tint) tuint))))
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 0) tint) ::
                   nil))))
            Sskip))))))
|}.

Definition f_act_backward_water_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Scall None
      (Evar _common_water_knockback_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: tuint :: tint :: nil)
                                           tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 158) tint) ::
       (Econst_int (Int.repr 939532992) tint) :: (Etempvar _t'1 tuint) ::
       nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_forward_water_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Scall None
      (Evar _common_water_knockback_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: tuint :: tint :: nil)
                                           tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 168) tint) ::
       (Econst_int (Int.repr 939532992) tint) :: (Etempvar _t'1 tuint) ::
       nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_water_shocked := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
               (_t'6, tuint) :: (_t'5, tshort) :: (_t'4, tushort) ::
               (_t'3, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
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
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 16) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Scall None
        (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                            cc_default))
        ((Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 1) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 22) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Econst_int (Int.repr 67108864) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))
    (Ssequence
      (Scall None
        (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil) tvoid
                                           cc_default))
        ((Econst_int (Int.repr 10) tint) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 122) tint) :: nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Ebinop Oadd (Etempvar _t'7 tushort)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _flags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _flags tuint)
                  (Ebinop Oor (Etempvar _t'6 tuint)
                    (Econst_int (Int.repr 64) tint) tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Oge (Etempvar _t'4 tushort)
                           (Econst_int (Int.repr 6) tint) tint)
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _invincTimer tshort)
                  (Econst_int (Int.repr 30) tint))
                (Ssequence
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _health tshort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'5 tshort)
                                   (Econst_int (Int.repr 256) tint) tint)
                      (Sset _t'2
                        (Ecast (Econst_int (Int.repr 805319367) tint) tint))
                      (Sset _t'2
                        (Ecast (Econst_int (Int.repr 939532992) tint) tint))))
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'2 tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _stationary_slow_down (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _perform_water_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tuint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'3 (tptr (Tstruct _MarioBodyState noattr)))
                            (Tstruct _MarioBodyState noattr)) _headAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort)
                    (Econst_int (Int.repr 0) tint)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_drowning := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, tshort) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sswitch (Etempvar _t'2 tushort)
      (LScons (Some 0)
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 165) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _eyeState tschar)
                (Econst_int (Int.repr 2) tint)))
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _is_anim_at_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort)
                    (Econst_int (Int.repr 1) tint))
                  Sskip))
              Sbreak)))
        (LScons (Some 1)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 166) tint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioBodyState
                    (tptr (Tstruct _MarioBodyState noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _eyeState tschar)
                  (Econst_int (Int.repr 8) tint)))
              (Ssequence
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animFrame tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                                   (Econst_int (Int.repr 30) tint) tint)
                      (Scall None
                        (Evar _level_trigger_warp (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tint :: nil) tshort
                                                    cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 18) tint) :: nil))
                      Sskip)))
                Sbreak)))
          LSnil))))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 35) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 240) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 65536) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _stationary_slow_down (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _perform_water_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_water_death := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tshort) ::
               (_t'2, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_slow_down (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _perform_water_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioBodyState
            (tptr (Tstruct _MarioBodyState noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _MarioBodyState noattr)))
              (Tstruct _MarioBodyState noattr)) _eyeState tschar)
          (Econst_int (Int.repr 8) tint)))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 167) tint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 167) tint) :: nil))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tshort)
                           (Econst_int (Int.repr 35) tint) tint)
              (Scall None
                (Evar _level_trigger_warp (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 18) tint) :: nil))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_water_plunge := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_stepResult, tuint) :: (_stateFlags, tint) ::
               (_endVSpeed, tfloat) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tushort) :: (_t'17, tuint) :: (_t'16, tuint) ::
               (_t'15, tushort) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tuint) :: (_t'9, tushort) ::
               (_t'8, tfloat) :: (_t'7, tushort) :: (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _heldObj
        (tptr (Tstruct _Object noattr))))
    (Sset _stateFlags
      (Ebinop One (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
        (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _swimming_near_surface (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _endVSpeed
          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
        (Sset _endVSpeed
          (Eunop Oneg
            (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'16 tuint)
                       (Econst_int (Int.repr 4) tint) tuint)
          (Sset _stateFlags
            (Ebinop Oor (Etempvar _stateFlags tint)
              (Econst_int (Int.repr 4) tint) tint))
          (Ssequence
            (Ssequence
              (Sset _t'17
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _prevAction tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'17 tuint)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 19) tint) tint) tuint)
                (Sset _t'2 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sset _t'2
                    (Ecast
                      (Ebinop Oand (Etempvar _t'18 tushort)
                        (Econst_int (Int.repr 128) tint) tint) tbool)))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Sset _stateFlags
                (Ebinop Oor (Etempvar _stateFlags tint)
                  (Econst_int (Int.repr 2) tint) tint))
              Sskip))))
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Ebinop Oadd (Etempvar _t'15 tushort)
              (Econst_int (Int.repr 1) tint) tint)))
        (Ssequence
          (Scall None
            (Evar _stationary_slow_down (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _perform_water_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tuint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _stepResult (Etempvar _t'3 tuint)))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioObj
                          (tptr (Tstruct _Object noattr))))
                      (Scall None
                        (Evar _play_sound (Tfunction
                                            (tint :: (tptr tfloat) :: nil)
                                            tvoid cc_default))
                        ((Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 28) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 48) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 192) tint)
                                   tuint) (Econst_int (Int.repr 8) tint)
                                 tuint) tuint)
                             (Ebinop Oor
                               (Econst_int (Int.repr 67108864) tint)
                               (Econst_int (Int.repr 128) tint) tint) tuint)
                           (Econst_int (Int.repr 1) tint) tuint) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _peakHeight
                            tfloat))
                        (Ssequence
                          (Sset _t'12
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sifthenelse (Ebinop Ogt
                                         (Ebinop Osub (Etempvar _t'11 tfloat)
                                           (Etempvar _t'12 tfloat) tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1150271488)) tfloat)
                                         tint)
                            (Ssequence
                              (Sset _t'13
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Scall None
                                (Evar _play_sound (Tfunction
                                                    (tint :: (tptr tfloat) ::
                                                     nil) tvoid cc_default))
                                ((Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 2) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 17) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 240) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Ebinop Oor
                                       (Econst_int (Int.repr 67108864) tint)
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            Sskip)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _particleFlags
                              tuint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _particleFlags
                              tuint)
                            (Ebinop Oor (Etempvar _t'10 tuint)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 6) tint) tint) tuint)))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint)))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _stepResult tuint)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Sset _t'4 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'8
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sset _t'4
                          (Ecast
                            (Ebinop Oge (Etempvar _t'8 tfloat)
                              (Etempvar _endVSpeed tfloat) tint) tbool))))
                    (Sifthenelse (Etempvar _t'4 tint)
                      (Sset _t'5 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionTimer
                            tushort))
                        (Sset _t'5
                          (Ecast
                            (Ebinop Ogt (Etempvar _t'7 tushort)
                              (Econst_int (Int.repr 20) tint) tint) tbool)))))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Sswitch (Etempvar _stateFlags tint)
                        (LScons (Some 0)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 805315266) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 1)
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 805315267) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sbreak)
                            (LScons (Some 2)
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 805315794) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                Sbreak)
                              (LScons (Some 3)
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 805315797) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  Sbreak)
                                (LScons (Some 4)
                                  (Ssequence
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 17140) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    Sbreak)
                                  (LScons (Some 5)
                                    (Ssequence
                                      (Scall None
                                        (Evar _set_mario_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tuint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 17141) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil))
                                      Sbreak)
                                    LSnil)))))))
                      (Sassign (Evar _sBobIncrement tshort)
                        (Econst_int (Int.repr 0) tint)))
                    Sskip))
                (Ssequence
                  (Sswitch (Etempvar _stateFlags tint)
                    (LScons (Some 0)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 173) tint) :: nil))
                        Sbreak)
                      (LScons (Some 1)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 162) tint) :: nil))
                          Sbreak)
                        (LScons (Some 2)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_animation (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 172) tint) :: nil))
                            Sbreak)
                          (LScons (Some 3)
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_animation (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tint :: nil)
                                                             tshort
                                                             cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 161) tint) :: nil))
                              Sbreak)
                            (LScons (Some 4)
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_animation (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tint :: nil)
                                                               tshort
                                                               cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 86) tint) :: nil))
                                Sbreak)
                              (LScons (Some 5)
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_animation (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tint ::
                                                                  nil) tshort
                                                                 cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 67) tint) :: nil))
                                  Sbreak)
                                LSnil)))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _particleFlags
                          tuint))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _particleFlags
                          tuint)
                        (Ebinop Oor (Etempvar _t'6 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 9) tint) tint) tuint)))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_caught_in_whirlpool := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sinAngleChange, tfloat) :: (_cosAngleChange, tfloat) ::
               (_newDistance, tfloat) :: (_angleChange, tshort) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_whirlpool, (tptr (Tstruct _Object noattr))) ::
               (_dx, tfloat) :: (_dz, tfloat) :: (_distance, tfloat) ::
               (_t'5, tshort) :: (_t'4, tfloat) :: (_t'3, tushort) ::
               (_t'2, tint) :: (_t'1, tfloat) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tshort) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
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
    (Sset _whirlpool
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _usedObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'21
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Sset _t'22
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _whirlpool (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
          (Sset _dx
            (Ebinop Osub (Etempvar _t'21 tfloat) (Etempvar _t'22 tfloat)
              tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'20
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _whirlpool (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat))
            (Sset _dz
              (Ebinop Osub (Etempvar _t'19 tfloat) (Etempvar _t'20 tfloat)
                tfloat))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
              ((Ebinop Oadd
                 (Ebinop Omul (Etempvar _dx tfloat) (Etempvar _dx tfloat)
                   tfloat)
                 (Ebinop Omul (Etempvar _dz tfloat) (Etempvar _dz tfloat)
                   tfloat) tfloat) :: nil))
            (Sset _distance (Etempvar _t'1 tfloat)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'17
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
                    (Sset _t'18
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _t'4
                      (Ecast
                        (Ebinop Oadd (Etempvar _t'17 tfloat)
                          (Etempvar _t'18 tfloat) tfloat) tfloat))))
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
                  (Etempvar _t'4 tfloat)))
              (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                             tint)
                (Ssequence
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
                  (Ssequence
                    (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1098960077)) tfloat)
                                   tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort)
                            (Ebinop Oadd (Etempvar _t'3 tushort)
                              (Econst_int (Int.repr 1) tint) tint)))
                        (Sset _t'2
                          (Ecast
                            (Ebinop Oeq (Etempvar _t'3 tushort)
                              (Econst_int (Int.repr 16) tint) tint) tbool)))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                    (Sifthenelse (Etempvar _t'2 tint)
                      (Scall None
                        (Evar _level_trigger_warp (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tint :: nil) tshort
                                                    cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 18) tint) :: nil))
                      Sskip)))
                Sskip))
            (Ssequence
              (Sifthenelse (Ebinop Ole (Etempvar _distance tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat)
                             tint)
                (Ssequence
                  (Sset _newDistance
                    (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat))
                  (Sset _angleChange
                    (Ecast (Econst_int (Int.repr 6144) tint) tshort)))
                (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1132462080)) tfloat)
                               tint)
                  (Ssequence
                    (Sset _newDistance
                      (Ebinop Osub (Etempvar _distance tfloat)
                        (Ebinop Osub
                          (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat)
                          (Ebinop Odiv (Etempvar _distance tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                            tfloat) tfloat) tfloat))
                    (Sset _angleChange
                      (Ecast
                        (Ecast
                          (Ebinop Osub (Econst_int (Int.repr 7168) tint)
                            (Ebinop Omul (Etempvar _distance tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                              tfloat) tfloat) tshort) tshort)))
                  (Ssequence
                    (Sset _newDistance
                      (Ebinop Osub (Etempvar _distance tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat))
                    (Sset _angleChange
                      (Ecast (Econst_int (Int.repr 2048) tint) tshort)))))
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
                  (Ebinop Odiv
                    (Eunop Oneg
                      (Econst_single (Float32.of_bits (Int.repr 1142947840)) tfloat)
                      tfloat)
                    (Ebinop Oadd (Etempvar _newDistance tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                      tfloat) tfloat))
                (Ssequence
                  (Sset _sinAngleChange
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast (Etempvar _angleChange tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _cosAngleChange
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _angleChange tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sifthenelse (Ebinop Olt (Etempvar _distance tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                     tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'15
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
                              (Sset _t'16
                                (Ederef
                                  (Ebinop Oadd
                                    (Evar _gSineTable (tarray tfloat 0))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'15 tshort) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sset _dx
                                (Ebinop Omul (Etempvar _newDistance tfloat)
                                  (Etempvar _t'16 tfloat) tfloat))))
                          (Ssequence
                            (Sset _t'13
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
                              (Sset _t'14
                                (Ederef
                                  (Ebinop Oadd
                                    (Ebinop Oadd
                                      (Evar _gSineTable (tarray tfloat 0))
                                      (Econst_int (Int.repr 1024) tint)
                                      (tptr tfloat))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'13 tshort) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sset _dz
                                (Ebinop Omul (Etempvar _newDistance tfloat)
                                  (Etempvar _t'14 tfloat) tfloat)))))
                        (Ssequence
                          (Sset _dx
                            (Ebinop Omul (Etempvar _dx tfloat)
                              (Ebinop Odiv (Etempvar _newDistance tfloat)
                                (Etempvar _distance tfloat) tfloat) tfloat))
                          (Sset _dz
                            (Ebinop Omul (Etempvar _dz tfloat)
                              (Ebinop Odiv (Etempvar _newDistance tfloat)
                                (Etempvar _distance tfloat) tfloat) tfloat))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'12
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _whirlpool (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asF32
                                  (tarray tfloat 80))
                                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
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
                                (Econst_int (Int.repr 0) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd
                              (Ebinop Oadd (Etempvar _t'12 tfloat)
                                (Ebinop Omul (Etempvar _dx tfloat)
                                  (Etempvar _cosAngleChange tfloat) tfloat)
                                tfloat)
                              (Ebinop Omul (Etempvar _dz tfloat)
                                (Etempvar _sinAngleChange tfloat) tfloat)
                              tfloat)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'11
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _whirlpool (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _rawData
                                      (Tunion __665 noattr)) _asF32
                                    (tarray tfloat 80))
                                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                                    (Econst_int (Int.repr 2) tint) tint)
                                  (tptr tfloat)) tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Oadd
                                (Ebinop Osub (Etempvar _t'11 tfloat)
                                  (Ebinop Omul (Etempvar _dx tfloat)
                                    (Etempvar _sinAngleChange tfloat) tfloat)
                                  tfloat)
                                (Ebinop Omul (Etempvar _dz tfloat)
                                  (Etempvar _cosAngleChange tfloat) tfloat)
                                tfloat)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'9
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _whirlpool (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _rawData
                                        (Tunion __665 noattr)) _asF32
                                      (tarray tfloat 80))
                                    (Ebinop Oadd
                                      (Econst_int (Int.repr 6) tint)
                                      (Econst_int (Int.repr 1) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'10
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
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat)
                                  (Ebinop Oadd (Etempvar _t'9 tfloat)
                                    (Etempvar _t'10 tfloat) tfloat))))
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'5)
                                  (Evar _atan2s (Tfunction
                                                  (tfloat :: tfloat :: nil)
                                                  tshort cc_default))
                                  ((Etempvar _dz tfloat) ::
                                   (Etempvar _dx tfloat) :: nil))
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
                                  (Ebinop Oadd (Etempvar _t'5 tshort)
                                    (Econst_int (Int.repr 32768) tint) tint)))
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_animation (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tint :: nil)
                                                               tshort
                                                               cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 86) tint) :: nil))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'8
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _marioObj
                                        (tptr (Tstruct _Object noattr))))
                                    (Scall None
                                      (Evar _vec3f_copy (Tfunction
                                                          ((tptr tfloat) ::
                                                           (tptr tfloat) ::
                                                           nil) (tptr tvoid)
                                                          cc_default))
                                      ((Efield
                                         (Efield
                                           (Efield
                                             (Ederef
                                               (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                               (Tstruct _Object noattr))
                                             _header
                                             (Tstruct _ObjectNode noattr))
                                           _gfx
                                           (Tstruct _GraphNodeObject noattr))
                                         _pos (tarray tfloat 3)) ::
                                       (Efield
                                         (Ederef
                                           (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                           (Tstruct _MarioState noattr)) _pos
                                         (tarray tfloat 3)) :: nil)))
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
                                                _faceAngle (tarray tshort 3))
                                              (Econst_int (Int.repr 1) tint)
                                              (tptr tshort)) tshort))
                                        (Scall None
                                          (Evar _vec3s_set (Tfunction
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
                                             _angle (tarray tshort 3)) ::
                                           (Econst_int (Int.repr 0) tint) ::
                                           (Etempvar _t'7 tshort) ::
                                           (Econst_int (Int.repr 0) tint) ::
                                           nil))))
                                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))))))))
|}.

Definition f_play_metal_water_jumping_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_landing, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'3, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'2 tuint)
                     (Econst_int (Int.repr 65536) tint) tuint) tint)
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint)
          (Ebinop Oor (Etempvar _t'3 tuint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 16) tint) tint) tuint)))
      Sskip))
  (Ssequence
    (Sifthenelse (Etempvar _landing tuint)
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 81) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint))
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 80) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint)))
    (Scall None
      (Evar _play_sound_if_no_flag (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 65536) tint) :: nil))))
|}.

Definition f_play_metal_water_walking_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _is_anim_past_frame (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tshort :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 10) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sset _t'2 (Econst_int (Int.repr 1) tint))
      (Ssequence
        (Scall (Some _t'3)
          (Evar _is_anim_past_frame (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tshort :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 49) tint) :: nil))
        (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 82) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _particleFlags tuint)
          (Ebinop Oor (Etempvar _t'4 tuint)
            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
              (Econst_int (Int.repr 0) tint) tint) tuint))))
    Sskip))
|}.

Definition f_update_metal_water_walking_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val, tfloat) :: (_t'1, tint) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) ::
               (_t'16, (tptr (Tstruct _Surface noattr))) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tshort) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'22
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedMag tfloat))
    (Sset _val
      (Ebinop Odiv (Etempvar _t'22 tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
        tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sifthenelse (Ebinop Ole (Etempvar _t'14 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                     tint)
        (Ssequence
          (Sset _t'21
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Ebinop Oadd (Etempvar _t'21 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
              tfloat)))
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Ole (Etempvar _t'15 tfloat)
                         (Etempvar _val tfloat) tint)
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Ebinop Oadd (Etempvar _t'19 tfloat)
                    (Ebinop Osub
                      (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                      (Ebinop Odiv (Etempvar _t'20 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1110179840)) tfloat)
                        tfloat) tfloat) tfloat))))
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'16 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _y tfloat))
                (Sifthenelse (Ebinop Oge (Etempvar _t'17 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat)
                               tint)
                  (Ssequence
                    (Sset _t'18
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Osub (Etempvar _t'18 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                        tfloat)))
                  Sskip)))))))
    (Ssequence
      (Ssequence
        (Sset _t'13
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'13 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                       tint)
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedYaw tshort))
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
              (Scall (Some _t'1)
                (Evar _approach_s32 (Tfunction
                                      (tint :: tint :: tint :: tint :: nil)
                                      tint cc_default))
                ((Ecast
                   (Ebinop Osub (Etempvar _t'11 tshort)
                     (Etempvar _t'12 tshort) tint) tshort) ::
                 (Econst_int (Int.repr 0) tint) ::
                 (Econst_int (Int.repr 2048) tint) ::
                 (Econst_int (Int.repr 2048) tint) :: nil))))
          (Ssequence
            (Sset _t'10
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
              (Ebinop Osub (Etempvar _t'10 tshort) (Etempvar _t'1 tint) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Ebinop Oshr (Ecast (Etempvar _t'8 tshort) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelX tfloat)
                  (Ebinop Omul (Etempvar _t'7 tfloat) (Etempvar _t'9 tfloat)
                    tfloat)))))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                        (Ebinop Oshr (Ecast (Etempvar _t'5 tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                    (Ebinop Omul (Etempvar _t'4 tfloat)
                      (Etempvar _t'6 tfloat) tfloat)))))
            (Ssequence
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelX tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _vel
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat) (Etempvar _t'3 tfloat)))
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
                  (Sset _t'2
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
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat) (Etempvar _t'2 tfloat)))))))))))
|}.

Definition f_update_metal_water_jump_speed := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_nextY, tfloat) :: (_waterSurface, tfloat) ::
               (_intendedDYaw, tshort) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'27, tfloat) ::
               (_t'26, tfloat) :: (_t'25, tshort) :: (_t'24, tfloat) ::
               (_t'23, tfloat) :: (_t'22, tshort) :: (_t'21, tshort) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tshort) :: (_t'16, tfloat) :: (_t'15, tushort) ::
               (_t'14, tfloat) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tshort) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'26
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'27
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sset _nextY
        (Ebinop Oadd (Etempvar _t'26 tfloat) (Etempvar _t'27 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sset _waterSurface
        (Ecast
          (Ebinop Osub (Etempvar _t'25 tshort)
            (Econst_int (Int.repr 100) tint) tint) tfloat)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'23
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'23 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                         tint)
            (Ssequence
              (Sset _t'24
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Ogt (Etempvar _t'24 tfloat)
                    (Etempvar _waterSurface tfloat) tint) tbool)))
            (Sset _t'1 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'21
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedYaw tshort))
                (Ssequence
                  (Sset _t'22
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sset _intendedDYaw
                    (Ecast
                      (Ebinop Osub (Etempvar _t'21 tshort)
                        (Etempvar _t'22 tshort) tint) tshort))))
              (Ssequence
                (Ssequence
                  (Sset _t'19
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'20
                      (Ederef
                        (Ebinop Oadd
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                          (Ebinop Oshr
                            (Ecast (Etempvar _intendedDYaw tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Oadd (Etempvar _t'19 tfloat)
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                          (Etempvar _t'20 tfloat) tfloat) tfloat))))
                (Ssequence
                  (Sset _t'17
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'18
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _intendedDYaw tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'17 tshort)
                        (Ebinop Omul (Econst_int (Int.repr 512) tint)
                          (Etempvar _t'18 tfloat) tfloat) tfloat))))))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Scall (Some _t'2)
                  (Evar _approach_f32 (Tfunction
                                        (tfloat :: tfloat :: tfloat ::
                                         tfloat :: nil) tfloat cc_default))
                  ((Etempvar _t'16 tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
                   nil)))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Etempvar _t'2 tfloat)))))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'13 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                           tint)
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Ebinop Osub (Etempvar _t'14 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                    tfloat)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'11 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Oadd (Etempvar _t'12 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Ssequence
                      (Sset _t'9
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
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'9 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sset _t'3
                          (Ecast
                            (Ebinop Omul (Etempvar _t'8 tfloat)
                              (Etempvar _t'10 tfloat) tfloat) tfloat)))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelX tfloat)
                    (Etempvar _t'3 tfloat)))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _vel
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat) (Etempvar _t'3 tfloat)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Ssequence
                        (Sset _t'6
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
                          (Sset _t'7
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'6 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sset _t'4
                            (Ecast
                              (Ebinop Omul (Etempvar _t'5 tfloat)
                                (Etempvar _t'7 tfloat) tfloat) tfloat)))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                      (Etempvar _t'4 tfloat)))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat) (Etempvar _t'4 tfloat)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_metal_water_standing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tushort) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'14, tuint) :: (_t'13, tushort) :: (_t'12, tushort) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tuint) ::
               (_t'8, tshort) :: (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'14 tuint)
                     (Econst_int (Int.repr 4) tint) tuint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 939532992) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17656) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17650) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sswitch (Etempvar _t'11 tushort)
            (LScons (Some 0)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 195) tint) :: nil))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 196) tint) :: nil))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 197) tint) :: nil))
                    Sbreak)
                  LSnil)))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'4 tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sset _t'6
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'10 tushort)
                            (Econst_int (Int.repr 1) tint) tint) tushort)))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Etempvar _t'6 tushort)))
                  (Sset _t'5
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'6 tushort)
                        (Econst_int (Int.repr 3) tint) tint) tbool)))
                (Sset _t'5 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'5 tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 0) tint))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _stop_and_set_height_to_floor (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _waterLevel tshort))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'7 tfloat)
                                 (Ebinop Osub (Etempvar _t'8 tshort)
                                   (Econst_int (Int.repr 150) tint) tint)
                                 tint)
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _particleFlags
                          tuint))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _particleFlags
                          tuint)
                        (Ebinop Oor (Etempvar _t'9 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 7) tint) tint) tuint)))
                    Sskip)))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_hold_metal_water_standing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'9 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 134234864) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'7 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532993) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17657) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 17651) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
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
               (Econst_int (Int.repr 63) tint) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_metal_water_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val04, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'11, tuint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'11 tuint)
                     (Econst_int (Int.repr 4) tint) tuint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 939532992) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                     (Econst_int (Int.repr 16) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 134234864) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17656) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                         (Econst_int (Int.repr 32) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 134234864) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sset _t'5
                  (Ecast
                    (Ecast
                      (Ebinop Omul
                        (Ebinop Odiv (Etempvar _t'7 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) (Econst_int (Int.repr 65536) tint) tfloat)
                      tint) tint)))
              (Sset _val04 (Etempvar _t'5 tint)))
            (Sifthenelse (Ebinop Olt (Etempvar _t'5 tint)
                           (Econst_int (Int.repr 4096) tint) tint)
              (Sset _val04 (Econst_int (Int.repr 4096) tint))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _set_mario_anim_with_accel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: tint :: nil) tshort
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 72) tint) :: (Etempvar _val04 tint) ::
               nil))
            (Ssequence
              (Scall None
                (Evar _play_metal_water_walking_sound (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Scall None
                  (Evar _update_metal_water_walking_speed (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tvoid
                                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _perform_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sswitch (Etempvar _t'6 tint)
                      (LScons (Some 0)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 17140) tint) ::
                             (Econst_int (Int.repr 1) tint) :: nil))
                          Sbreak)
                        (LScons (Some 2)
                          (Ssequence
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                            Sbreak)
                          LSnil))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_hold_metal_water_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val04, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'13, tint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuint) ::
               (_t'10, tushort) :: (_t'9, tushort) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'13
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17650) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'11 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532993) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17657) tint) ::
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
                         (Econst_int (Int.repr 32) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 134234865) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedMag tfloat))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedMag tfloat)
              (Ebinop Omul (Etempvar _t'8 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                tfloat)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sset _t'5
                    (Ecast
                      (Ecast
                        (Ebinop Omul
                          (Ebinop Odiv (Etempvar _t'7 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                            tfloat) (Econst_int (Int.repr 65536) tint)
                          tfloat) tint) tint)))
                (Sset _val04 (Etempvar _t'5 tint)))
              (Sifthenelse (Ebinop Olt (Etempvar _t'5 tint)
                             (Econst_int (Int.repr 4096) tint) tint)
                (Sset _val04 (Econst_int (Int.repr 4096) tint))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _set_mario_anim_with_accel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: tint :: nil)
                                                   tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 23) tint) :: (Etempvar _val04 tint) ::
                 nil))
              (Ssequence
                (Scall None
                  (Evar _play_metal_water_walking_sound (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _update_metal_water_walking_speed (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _perform_ground_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sswitch (Etempvar _t'6 tint)
                        (LScons (Some 0)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 17141) tint) ::
                               (Econst_int (Int.repr 1) tint) :: nil))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _forwardVel
                                  tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                              Sbreak)
                            LSnil))))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_metal_water_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'5 tuint)
                     (Econst_int (Int.repr 4) tint) tuint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 939532992) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'3)
        (Evar _update_metal_water_jump_speed (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779401) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _play_metal_water_jumping_sound (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: nil) tvoid
                                                cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 77) tint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'4)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'4 tint)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 17658) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                    Sbreak)
                  LSnil))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_metal_water_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'8, tint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17140) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532993) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'4)
          (Evar _update_metal_water_jump_speed (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779427) tint) ::
               (Econst_int (Int.repr 1) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _play_metal_water_jumping_sound (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: nil) tvoid
                                                  cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 65) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'5)
                (Evar _perform_air_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sswitch (Etempvar _t'5 tint)
                (LScons (Some 1)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 17659) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                      Sbreak)
                    LSnil))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_metal_water_falling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'10, tuint) :: (_t'9, tfloat) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tushort) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'10 tuint)
                     (Econst_int (Int.repr 4) tint) tuint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 939532992) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedYaw tshort))
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
              (Ssequence
                (Sset _t'9
                  (Ederef
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Ebinop Oshr
                        (Ecast
                          (Ebinop Osub (Etempvar _t'7 tshort)
                            (Etempvar _t'8 tshort) tint) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort)
                  (Ebinop Oadd (Etempvar _t'6 tshort)
                    (Ebinop Omul (Econst_int (Int.repr 1024) tint)
                      (Etempvar _t'9 tfloat) tfloat) tfloat))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _t'2 (Ecast (Econst_int (Int.repr 86) tint) tint))
            (Sset _t'2 (Ecast (Econst_int (Int.repr 169) tint) tint))))
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _t'2 tint) :: nil)))
      (Ssequence
        (Scall None
          (Evar _stationary_slow_down (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _perform_water_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                           (Econst_int (Int.repr 1) tint) tuint)
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 17142) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_metal_water_falling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'11, tint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tuint) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'11
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'11 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 17140) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'9 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532993) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _intendedYaw tshort))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast
                            (Ebinop Osub (Etempvar _t'6 tshort)
                              (Etempvar _t'7 tshort) tint) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Oadd (Etempvar _t'5 tshort)
                      (Ebinop Omul (Econst_int (Int.repr 1024) tint)
                        (Etempvar _t'8 tfloat) tfloat) tfloat))))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _stationary_slow_down (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _perform_water_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tuint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Ebinop Oand (Etempvar _t'3 tuint)
                             (Econst_int (Int.repr 1) tint) tuint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 17143) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_metal_water_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'6, tuint) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_metal_water_jumping_sound (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532992) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17650) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
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
             (Econst_int (Int.repr 78) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'4 tint)
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 134234864) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tuint))))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_metal_water_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_metal_water_jumping_sound (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'9 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 134234864) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'7 tuint)
                         (Econst_int (Int.repr 4) tint) tuint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532993) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 17651) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
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
               (Econst_int (Int.repr 64) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _is_anim_at_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 134234865) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'4 tuint))))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_metal_water_fall_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'6, tuint) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_metal_water_jumping_sound (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 4) tint) tuint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 939532992) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 17650) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
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
             (Econst_int (Int.repr 87) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'4 tint)
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 134234864) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tuint))))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_metal_water_fall_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_metal_water_jumping_sound (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_int (Int.repr 1) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'9
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'9 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 134234864) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'7 tuint)
                         (Econst_int (Int.repr 4) tint) tuint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 939532993) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 17651) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
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
               (Econst_int (Int.repr 66) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _is_anim_at_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 134234865) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'4 tuint))))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_check_common_submerged_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'13, tshort) :: (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tuint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tfloat) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tuint) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tfloat)
                     (Ebinop Osub (Etempvar _t'7 tshort)
                       (Econst_int (Int.repr 80) tint) tint) tint)
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _waterLevel tshort))
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorHeight tfloat))
            (Sifthenelse (Ebinop Ogt
                           (Ebinop Osub (Etempvar _t'8 tshort)
                             (Econst_int (Int.repr 80) tint) tint)
                           (Etempvar _t'9 tfloat) tint)
              (Ssequence
                (Sset _t'13
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _waterLevel tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat)
                  (Ebinop Osub (Etempvar _t'13 tshort)
                    (Econst_int (Int.repr 80) tint) tint)))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tuint)
                                   (Econst_int (Int.repr 805315798) tint)
                                   tint)
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _heldObj
                            (tptr (Tstruct _Object noattr))))
                        (Sset _t'1
                          (Ecast
                            (Ebinop One
                              (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid)) tint) tbool)))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _heldObj
                            (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _rawData
                                  (Tunion __665 noattr)) _asS32
                                (tarray tint 80))
                              (Econst_int (Int.repr 43) tint) (tptr tint))
                            tint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 22) tint) tint)))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _heldObj
                            (tptr (Tstruct _Object noattr)))
                          (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
                        (Scall None
                          (Evar _stop_shell_music (Tfunction nil tvoid
                                                    cc_default)) nil)))
                    Sskip))
                (Ssequence
                  (Scall (Some _t'2)
                    (Evar _transition_submerged_to_walking (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sreturn (Some (Etempvar _t'2 tint))))))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _health tshort))
        (Sifthenelse (Ebinop Olt (Etempvar _t'4 tshort)
                       (Econst_int (Int.repr 256) tint) tint)
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sset _t'3
              (Ecast
                (Eunop Onotbool
                  (Ebinop Oand (Etempvar _t'5 tuint)
                    (Ebinop Oor
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 12) tint) tint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 17) tint) tint) tint) tuint)
                  tint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 805319364) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_mario_execute_submerged_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'33, tint) :: (_t'32, tint) ::
               (_t'31, tint) :: (_t'30, tint) :: (_t'29, tint) ::
               (_t'28, tint) :: (_t'27, tint) :: (_t'26, tint) ::
               (_t'25, tint) :: (_t'24, tint) :: (_t'23, tint) ::
               (_t'22, tint) :: (_t'21, tint) :: (_t'20, tint) ::
               (_t'19, tint) :: (_t'18, tint) :: (_t'17, tint) ::
               (_t'16, tint) :: (_t'15, tint) :: (_t'14, tint) ::
               (_t'13, tint) :: (_t'12, tint) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) ::
               (_t'36, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'35, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'34, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_submerged_cancels (Tfunction
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
        (Sset _t'36
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioBodyState
            (tptr (Tstruct _MarioBodyState noattr))))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef
                  (Etempvar _t'36 (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _headAngle
                (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
              (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'35
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioBodyState
              (tptr (Tstruct _MarioBodyState noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _t'35 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _headAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'34
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sswitch (Etempvar _t'34 tuint)
              (LScons (Some 939532992)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _act_water_idle (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'2 tint)))
                  Sbreak)
                (LScons (Some 939532993)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _act_hold_water_idle (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'3 tint)))
                    Sbreak)
                  (LScons (Some 805315266)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'4)
                          (Evar _act_water_action_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'4 tint)))
                      Sbreak)
                    (LScons (Some 805315267)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'5)
                            (Evar _act_hold_water_action_end (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tint
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'5 tint)))
                        Sbreak)
                      (LScons (Some 805319364)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _act_drowning (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'6 tint)))
                          Sbreak)
                        (LScons (Some 805446341)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'7)
                                (Evar _act_backward_water_kb (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tint
                                                               cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'7 tint)))
                            Sbreak)
                          (LScons (Some 805446342)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'8)
                                  (Evar _act_forward_water_kb (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'8 tint)))
                              Sbreak)
                            (LScons (Some 805319367)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'9)
                                    (Evar _act_water_death (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'9 tint)))
                                Sbreak)
                              (LScons (Some 805446344)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'10)
                                      (Evar _act_water_shocked (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tint
                                                                 cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'10 tint)))
                                  Sbreak)
                                (LScons (Some 805315792)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'11)
                                        (Evar _act_breaststroke (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'11 tint)))
                                    Sbreak)
                                  (LScons (Some 805315793)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'12)
                                          (Evar _act_swimming_end (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'12 tint)))
                                      Sbreak)
                                    (LScons (Some 805315794)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'13)
                                            (Evar _act_flutter_kick (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'13 tint)))
                                        Sbreak)
                                      (LScons (Some 805315795)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'14)
                                              (Evar _act_hold_breaststroke 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'14 tint)))
                                          Sbreak)
                                        (LScons (Some 805315796)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'15)
                                                (Evar _act_hold_swimming_end 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'15 tint)))
                                            Sbreak)
                                          (LScons (Some 805315797)
                                            (Ssequence
                                              (Ssequence
                                                (Scall (Some _t'16)
                                                  (Evar _act_hold_flutter_kick 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   nil))
                                                (Sset _cancel
                                                  (Etempvar _t'16 tint)))
                                              Sbreak)
                                            (LScons (Some 805315798)
                                              (Ssequence
                                                (Ssequence
                                                  (Scall (Some _t'17)
                                                    (Evar _act_water_shell_swimming 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     nil))
                                                  (Sset _cancel
                                                    (Etempvar _t'17 tint)))
                                                Sbreak)
                                              (LScons (Some 805315808)
                                                (Ssequence
                                                  (Ssequence
                                                    (Scall (Some _t'18)
                                                      (Evar _act_water_throw 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                       nil))
                                                    (Sset _cancel
                                                      (Etempvar _t'18 tint)))
                                                  Sbreak)
                                                (LScons (Some 805315809)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Scall (Some _t'19)
                                                        (Evar _act_water_punch 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         nil))
                                                      (Sset _cancel
                                                        (Etempvar _t'19 tint)))
                                                    Sbreak)
                                                  (LScons (Some 805315298)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Scall (Some _t'20)
                                                          (Evar _act_water_plunge 
                                                          (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                           nil))
                                                        (Sset _cancel
                                                          (Etempvar _t'20 tint)))
                                                      Sbreak)
                                                    (LScons (Some 805446371)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Scall (Some _t'21)
                                                            (Evar _act_caught_in_whirlpool 
                                                            (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                             nil))
                                                          (Sset _cancel
                                                            (Etempvar _t'21 tint)))
                                                        Sbreak)
                                                      (LScons (Some 134234864)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Scall (Some _t'22)
                                                              (Evar _act_metal_water_standing 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                               nil))
                                                            (Sset _cancel
                                                              (Etempvar _t'22 tint)))
                                                          Sbreak)
                                                        (LScons (Some 17650)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Scall (Some _t'23)
                                                                (Evar _act_metal_water_walking 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                 nil))
                                                              (Sset _cancel
                                                                (Etempvar _t'23 tint)))
                                                            Sbreak)
                                                          (LScons (Some 17140)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'24)
                                                                  (Evar _act_metal_water_falling 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                   nil))
                                                                (Sset _cancel
                                                                  (Etempvar _t'24 tint)))
                                                              Sbreak)
                                                            (LScons (Some 17142)
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'25)
                                                                    (Evar _act_metal_water_fall_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                  (Sset _cancel
                                                                    (Etempvar _t'25 tint)))
                                                                Sbreak)
                                                              (LScons (Some 17656)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'26)
                                                                    (Evar _act_metal_water_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'26 tint)))
                                                                  Sbreak)
                                                                (LScons (Some 17658)
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'27)
                                                                    (Evar _act_metal_water_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'27 tint)))
                                                                    Sbreak)
                                                                  (LScons (Some 134234865)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'28)
                                                                    (Evar _act_hold_metal_water_standing 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'28 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 17651)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'29)
                                                                    (Evar _act_hold_metal_water_walking 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'29 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 17141)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'30)
                                                                    (Evar _act_hold_metal_water_falling 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'30 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 17143)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'31)
                                                                    (Evar _act_hold_metal_water_fall_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'31 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 17657)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'32)
                                                                    (Evar _act_hold_metal_water_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'32 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 17659)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'33)
                                                                    (Evar _act_hold_metal_water_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'33 tint)))
                                                                    Sbreak)
                                                                    LSnil))))))))))))))))))))))))))))))))))
          (Sreturn (Some (Etempvar _cancel tint))))))))
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
 (_sqrtf,
   Gfun(External (EF_external "sqrtf"
                   (mksignature (AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: nil) tfloat cc_default)) ::
 (_level_trigger_warp,
   Gfun(External (EF_external "level_trigger_warp"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
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
 (_approach_f32,
   Gfun(External (EF_external "approach_f32"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat :: tfloat :: nil) tfloat cc_default)) ::
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
 (_set_camera_shake_from_hit,
   Gfun(External (EF_external "set_camera_shake_from_hit"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_gCurrAreaIndex, Gvar v_gCurrAreaIndex) ::
 (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_play_shell_music,
   Gfun(External (EF_external "play_shell_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stop_shell_music,
   Gfun(External (EF_external "stop_shell_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_mario_grab_used_object,
   Gfun(External (EF_external "mario_grab_used_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_throw_held_object,
   Gfun(External (EF_external "mario_throw_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_get_collided_object,
   Gfun(External (EF_external "mario_get_collided_object"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xptr
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_is_anim_at_end,
   Gfun(External (EF_external "is_anim_at_end"
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
 (_set_anim_to_frame,
   Gfun(External (EF_external "set_anim_to_frame"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tvoid
     cc_default)) ::
 (_is_anim_past_frame,
   Gfun(External (EF_external "is_anim_past_frame"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tint cc_default)) ::
 (_play_sound_if_no_flag,
   Gfun(External (EF_external "play_sound_if_no_flag"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
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
 (_find_floor_slope,
   Gfun(External (EF_external "find_floor_slope"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tshort
     cc_default)) ::
 (_set_mario_action,
   Gfun(External (EF_external "set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tuint
     cc_default)) ::
 (_drop_and_set_mario_action,
   Gfun(External (EF_external "drop_and_set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tint
     cc_default)) ::
 (_transition_submerged_to_walking,
   Gfun(External (EF_external "transition_submerged_to_walking"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_stop_and_set_height_to_floor,
   Gfun(External (EF_external "stop_and_set_height_to_floor"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_perform_ground_step,
   Gfun(External (EF_external "perform_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_perform_air_step,
   Gfun(External (EF_external "perform_air_step"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tint cc_default)) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_bhvKoopaShellUnderwater, Gvar v_bhvKoopaShellUnderwater) ::
 (_sWasAtSurface, Gvar v_sWasAtSurface) ::
 (_sSwimStrength, Gvar v_sSwimStrength) ::
 (_sWaterCurrentSpeeds, Gvar v_sWaterCurrentSpeeds) ::
 (_sBobTimer, Gvar v_sBobTimer) :: (_sBobIncrement, Gvar v_sBobIncrement) ::
 (_sBobHeight, Gvar v_sBobHeight) ::
 (_set_swimming_at_surface_particles, Gfun(Internal f_set_swimming_at_surface_particles)) ::
 (_swimming_near_surface, Gfun(Internal f_swimming_near_surface)) ::
 (_get_buoyancy, Gfun(Internal f_get_buoyancy)) ::
 (_perform_water_full_step, Gfun(Internal f_perform_water_full_step)) ::
 (_apply_water_current, Gfun(Internal f_apply_water_current)) ::
 (_perform_water_step, Gfun(Internal f_perform_water_step)) ::
 (_update_water_pitch, Gfun(Internal f_update_water_pitch)) ::
 (_stationary_slow_down, Gfun(Internal f_stationary_slow_down)) ::
 (_update_swimming_speed, Gfun(Internal f_update_swimming_speed)) ::
 (_update_swimming_yaw, Gfun(Internal f_update_swimming_yaw)) ::
 (_update_swimming_pitch, Gfun(Internal f_update_swimming_pitch)) ::
 (_common_idle_step, Gfun(Internal f_common_idle_step)) ::
 (_act_water_idle, Gfun(Internal f_act_water_idle)) ::
 (_act_hold_water_idle, Gfun(Internal f_act_hold_water_idle)) ::
 (_act_water_action_end, Gfun(Internal f_act_water_action_end)) ::
 (_act_hold_water_action_end, Gfun(Internal f_act_hold_water_action_end)) ::
 (_reset_bob_variables, Gfun(Internal f_reset_bob_variables)) ::
 (_surface_swim_bob, Gfun(Internal f_surface_swim_bob)) ::
 (_common_swimming_step, Gfun(Internal f_common_swimming_step)) ::
 (_play_swimming_noise, Gfun(Internal f_play_swimming_noise)) ::
 (_check_water_jump, Gfun(Internal f_check_water_jump)) ::
 (_act_breaststroke, Gfun(Internal f_act_breaststroke)) ::
 (_act_swimming_end, Gfun(Internal f_act_swimming_end)) ::
 (_act_flutter_kick, Gfun(Internal f_act_flutter_kick)) ::
 (_act_hold_breaststroke, Gfun(Internal f_act_hold_breaststroke)) ::
 (_act_hold_swimming_end, Gfun(Internal f_act_hold_swimming_end)) ::
 (_act_hold_flutter_kick, Gfun(Internal f_act_hold_flutter_kick)) ::
 (_act_water_shell_swimming, Gfun(Internal f_act_water_shell_swimming)) ::
 (_check_water_grab, Gfun(Internal f_check_water_grab)) ::
 (_act_water_throw, Gfun(Internal f_act_water_throw)) ::
 (_act_water_punch, Gfun(Internal f_act_water_punch)) ::
 (_common_water_knockback_step, Gfun(Internal f_common_water_knockback_step)) ::
 (_act_backward_water_kb, Gfun(Internal f_act_backward_water_kb)) ::
 (_act_forward_water_kb, Gfun(Internal f_act_forward_water_kb)) ::
 (_act_water_shocked, Gfun(Internal f_act_water_shocked)) ::
 (_act_drowning, Gfun(Internal f_act_drowning)) ::
 (_act_water_death, Gfun(Internal f_act_water_death)) ::
 (_act_water_plunge, Gfun(Internal f_act_water_plunge)) ::
 (_act_caught_in_whirlpool, Gfun(Internal f_act_caught_in_whirlpool)) ::
 (_play_metal_water_jumping_sound, Gfun(Internal f_play_metal_water_jumping_sound)) ::
 (_play_metal_water_walking_sound, Gfun(Internal f_play_metal_water_walking_sound)) ::
 (_update_metal_water_walking_speed, Gfun(Internal f_update_metal_water_walking_speed)) ::
 (_update_metal_water_jump_speed, Gfun(Internal f_update_metal_water_jump_speed)) ::
 (_act_metal_water_standing, Gfun(Internal f_act_metal_water_standing)) ::
 (_act_hold_metal_water_standing, Gfun(Internal f_act_hold_metal_water_standing)) ::
 (_act_metal_water_walking, Gfun(Internal f_act_metal_water_walking)) ::
 (_act_hold_metal_water_walking, Gfun(Internal f_act_hold_metal_water_walking)) ::
 (_act_metal_water_jump, Gfun(Internal f_act_metal_water_jump)) ::
 (_act_hold_metal_water_jump, Gfun(Internal f_act_hold_metal_water_jump)) ::
 (_act_metal_water_falling, Gfun(Internal f_act_metal_water_falling)) ::
 (_act_hold_metal_water_falling, Gfun(Internal f_act_hold_metal_water_falling)) ::
 (_act_metal_water_jump_land, Gfun(Internal f_act_metal_water_jump_land)) ::
 (_act_hold_metal_water_jump_land, Gfun(Internal f_act_hold_metal_water_jump_land)) ::
 (_act_metal_water_fall_land, Gfun(Internal f_act_metal_water_fall_land)) ::
 (_act_hold_metal_water_fall_land, Gfun(Internal f_act_hold_metal_water_fall_land)) ::
 (_check_common_submerged_cancels, Gfun(Internal f_check_common_submerged_cancels)) ::
 (_mario_execute_submerged_action, Gfun(Internal f_mario_execute_submerged_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_submerged_action :: _bhvKoopaShellUnderwater ::
 _play_sound :: _perform_air_step :: _perform_ground_step ::
 _stop_and_set_height_to_floor :: _transition_submerged_to_walking ::
 _drop_and_set_mario_action :: _set_mario_action :: _find_floor_slope ::
 _vec3f_find_ceil :: _resolve_and_return_wall_collisions ::
 _play_sound_if_no_flag :: _is_anim_past_frame :: _set_anim_to_frame ::
 _set_mario_anim_with_accel :: _set_mario_animation :: _is_anim_at_end ::
 _mario_get_collided_object :: _mario_throw_held_object ::
 _mario_grab_used_object :: _find_floor :: _stop_shell_music ::
 _play_shell_music :: _gCurrLevelNum :: _gCurrentArea :: _gCurrAreaIndex ::
 _set_camera_shake_from_hit :: _atan2s :: _approach_f32 :: _approach_s32 ::
 _vec3s_set :: _vec3f_set :: _vec3f_copy :: _gSineTable ::
 _segmented_to_virtual :: _level_trigger_warp :: _sqrtf ::
 ___builtin_debug :: ___builtin_write32_reversed ::
 ___builtin_write16_reversed :: ___builtin_read32_reversed ::
 ___builtin_read16_reversed :: ___builtin_fnmsub :: ___builtin_fnmadd ::
 ___builtin_fmsub :: ___builtin_fmadd :: ___builtin_fmin ::
 ___builtin_fmax :: ___builtin_expect :: ___builtin_unreachable ::
 ___builtin_va_end :: ___builtin_va_copy :: ___builtin_va_arg ::
 ___builtin_va_start :: ___builtin_membar :: ___builtin_annot_intval ::
 ___builtin_annot :: ___builtin_sel :: ___builtin_memcpy_aligned ::
 ___builtin_sqrt :: ___builtin_fsqrt :: ___builtin_fabsf ::
 ___builtin_fabs :: ___builtin_ctzll :: ___builtin_ctzl :: ___builtin_ctz ::
 ___builtin_clzll :: ___builtin_clzl :: ___builtin_clz ::
 ___builtin_bswap16 :: ___builtin_bswap32 :: ___builtin_bswap ::
 ___builtin_bswap64 :: ___builtin_ais_annot :: ___compcert_i64_umulh ::
 ___compcert_i64_smulh :: ___compcert_i64_sar :: ___compcert_i64_shr ::
 ___compcert_i64_shl :: ___compcert_i64_umod :: ___compcert_i64_smod ::
 ___compcert_i64_udiv :: ___compcert_i64_sdiv :: ___compcert_i64_utof ::
 ___compcert_i64_stof :: ___compcert_i64_utod :: ___compcert_i64_stod ::
 ___compcert_i64_dtou :: ___compcert_i64_dtos :: ___compcert_va_composite ::
 ___compcert_va_float64 :: ___compcert_va_int64 :: ___compcert_va_int32 ::
 nil).

Definition prog : Clight.program := 
  mkprogram composites global_definitions public_idents _main Logic.I.


