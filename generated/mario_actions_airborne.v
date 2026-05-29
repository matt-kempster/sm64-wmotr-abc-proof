(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_airborne.c
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
  Definition source_file := "vendor/sm64/src/game/mario_actions_airborne.c".
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
Definition _act_air_hit_wall : ident := $"act_air_hit_wall".
Definition _act_air_throw : ident := $"act_air_throw".
Definition _act_backflip : ident := $"act_backflip".
Definition _act_backward_air_kb : ident := $"act_backward_air_kb".
Definition _act_backward_rollout : ident := $"act_backward_rollout".
Definition _act_burning_fall : ident := $"act_burning_fall".
Definition _act_burning_jump : ident := $"act_burning_jump".
Definition _act_butt_slide_air : ident := $"act_butt_slide_air".
Definition _act_crazy_box_bounce : ident := $"act_crazy_box_bounce".
Definition _act_dive : ident := $"act_dive".
Definition _act_double_jump : ident := $"act_double_jump".
Definition _act_flying : ident := $"act_flying".
Definition _act_flying_triple_jump : ident := $"act_flying_triple_jump".
Definition _act_forward_air_kb : ident := $"act_forward_air_kb".
Definition _act_forward_rollout : ident := $"act_forward_rollout".
Definition _act_freefall : ident := $"act_freefall".
Definition _act_getting_blown : ident := $"act_getting_blown".
Definition _act_ground_pound : ident := $"act_ground_pound".
Definition _act_hard_backward_air_kb : ident := $"act_hard_backward_air_kb".
Definition _act_hard_forward_air_kb : ident := $"act_hard_forward_air_kb".
Definition _act_hold_butt_slide_air : ident := $"act_hold_butt_slide_air".
Definition _act_hold_freefall : ident := $"act_hold_freefall".
Definition _act_hold_jump : ident := $"act_hold_jump".
Definition _act_hold_water_jump : ident := $"act_hold_water_jump".
Definition _act_jump : ident := $"act_jump".
Definition _act_jump_kick : ident := $"act_jump_kick".
Definition _act_lava_boost : ident := $"act_lava_boost".
Definition _act_long_jump : ident := $"act_long_jump".
Definition _act_riding_hoot : ident := $"act_riding_hoot".
Definition _act_riding_shell_air : ident := $"act_riding_shell_air".
Definition _act_shot_from_cannon : ident := $"act_shot_from_cannon".
Definition _act_side_flip : ident := $"act_side_flip".
Definition _act_slide_kick : ident := $"act_slide_kick".
Definition _act_soft_bonk : ident := $"act_soft_bonk".
Definition _act_special_triple_jump : ident := $"act_special_triple_jump".
Definition _act_steep_jump : ident := $"act_steep_jump".
Definition _act_thrown_backward : ident := $"act_thrown_backward".
Definition _act_thrown_forward : ident := $"act_thrown_forward".
Definition _act_top_of_pole_jump : ident := $"act_top_of_pole_jump".
Definition _act_triple_jump : ident := $"act_triple_jump".
Definition _act_twirling : ident := $"act_twirling".
Definition _act_vertical_wind : ident := $"act_vertical_wind".
Definition _act_wall_kick_air : ident := $"act_wall_kick_air".
Definition _act_water_jump : ident := $"act_water_jump".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _adjust_sound_for_speed : ident := $"adjust_sound_for_speed".
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
Definition _approach_f32 : ident := $"approach_f32".
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
Definition _atan2s : ident := $"atan2s".
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
Definition _cancel : ident := $"cancel".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _check_common_airborne_cancels : ident := $"check_common_airborne_cancels".
Definition _check_fall_damage : ident := $"check_fall_damage".
Definition _check_fall_damage_or_get_stuck : ident := $"check_fall_damage_or_get_stuck".
Definition _check_horizontal_wind : ident := $"check_horizontal_wind".
Definition _check_kick_or_dive_in_air : ident := $"check_kick_or_dive_in_air".
Definition _check_wall_kick : ident := $"check_wall_kick".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _common_air_action_step : ident := $"common_air_action_step".
Definition _common_air_knockback_step : ident := $"common_air_knockback_step".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _damageHeight : ident := $"damageHeight".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _dragThreshold : ident := $"dragThreshold".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fallHeight : ident := $"fallHeight".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardVel : ident := $"forwardVel".
Definition _frame1 : ident := $"frame1".
Definition _frame2 : ident := $"frame2".
Definition _frame3 : ident := $"frame3".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gSineTable : ident := $"gSineTable".
Definition _gSpecialTripleJump : ident := $"gSpecialTripleJump".
Definition _gettingBlownGravity : ident := $"gettingBlownGravity".
Definition _gfx : ident := $"gfx".
Definition _grabPos : ident := $"grabPos".
Definition _handState : ident := $"handState".
Definition _hardFallAction : ident := $"hardFallAction".
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
Definition _intendedDYaw : ident := $"intendedDYaw".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _landAction : ident := $"landAction".
Definition _lava_boost_on_wall : ident := $"lava_boost_on_wall".
Definition _length : ident := $"length".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _load_level_init_text : ident := $"load_level_init_text".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_blow_off_cap : ident := $"mario_blow_off_cap".
Definition _mario_bonk_reflection : ident := $"mario_bonk_reflection".
Definition _mario_check_object_grab : ident := $"mario_check_object_grab".
Definition _mario_drop_held_object : ident := $"mario_drop_held_object".
Definition _mario_execute_airborne_action : ident := $"mario_execute_airborne_action".
Definition _mario_floor_is_slippery : ident := $"mario_floor_is_slippery".
Definition _mario_grab_used_object : ident := $"mario_grab_used_object".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_throw_held_object : ident := $"mario_throw_held_object".
Definition _minSpeed : ident := $"minSpeed".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
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
Definition _perform_air_step : ident := $"perform_air_step".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_far_fall_sound : ident := $"play_far_fall_sound".
Definition _play_flip_sounds : ident := $"play_flip_sounds".
Definition _play_knockback_sound : ident := $"play_knockback_sound".
Definition _play_mario_heavy_landing_sound : ident := $"play_mario_heavy_landing_sound".
Definition _play_mario_jump_sound : ident := $"play_mario_jump_sound".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_mario_sound : ident := $"play_mario_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _pushAngle : ident := $"pushAngle".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _scale : ident := $"scale".
Definition _set_anim_to_frame : ident := $"set_anim_to_frame".
Definition _set_camera_mode : ident := $"set_camera_mode".
Definition _set_camera_shake_from_hit : ident := $"set_camera_shake_from_hit".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _should_get_stuck_in_ground : ident := $"should_get_stuck_in_ground".
Definition _sidewaysSpeed : ident := $"sidewaysSpeed".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _speed : ident := $"speed".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPitch : ident := $"startPitch".
Definition _startPos : ident := $"startPos".
Definition _startTwirlYaw : ident := $"startTwirlYaw".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stepArg : ident := $"stepArg".
Definition _stepResult : ident := $"stepResult".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _targetPitchVel : ident := $"targetPitchVel".
Definition _targetYawVel : ident := $"targetYawVel".
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
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _update_air_with_turn : ident := $"update_air_with_turn".
Definition _update_air_without_turn : ident := $"update_air_without_turn".
Definition _update_flying : ident := $"update_flying".
Definition _update_flying_pitch : ident := $"update_flying_pitch".
Definition _update_flying_yaw : ident := $"update_flying_yaw".
Definition _update_lava_boost_or_twirling : ident := $"update_lava_boost_or_twirling".
Definition _update_mario_sound_and_camera : ident := $"update_mario_sound_and_camera".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
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
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yOffset : ident := $"yOffset".
Definition _yaw : ident := $"yaw".
Definition _yawVelTarget : ident := $"yawVelTarget".
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
Definition _t'68 : ident := 195%positive.
Definition _t'69 : ident := 196%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'70 : ident := 197%positive.
Definition _t'71 : ident := 198%positive.
Definition _t'72 : ident := 199%positive.
Definition _t'73 : ident := 200%positive.
Definition _t'74 : ident := 201%positive.
Definition _t'75 : ident := 202%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gAudioRandom := {|
  gvar_info := tuint;
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

Definition v_gGlobalTimer := {|
  gvar_info := tuint;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gSpecialTripleJump := {|
  gvar_info := tuchar;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_play_flip_sounds := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_frame1, tshort) :: (_frame2, tshort) ::
                (_frame3, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Sset _animFrame
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _animInfo
          (Tstruct _AnimInfo noattr)) _animFrame tshort)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Etempvar _frame1 tshort) tint)
        (Sset _t'1 (Econst_int (Int.repr 1) tint))
        (Sset _t'1
          (Ecast
            (Ebinop Oeq (Etempvar _animFrame tint) (Etempvar _frame2 tshort)
              tint) tbool)))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Sset _t'2
          (Ecast
            (Ebinop Oeq (Etempvar _animFrame tint) (Etempvar _frame3 tshort)
              tint) tbool))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Sset _t'3
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
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 55) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
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
      Sskip)))
|}.

Definition f_play_far_fall_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_action, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'8, tuint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _action
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _action tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 17) tint) tint) tuint) tint)
          (Sset _t'1
            (Ecast
              (Ebinop One (Etempvar _action tuint)
                (Econst_int (Int.repr 276826276) tint) tint) tbool))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Sset _t'2
            (Ecast
              (Ebinop One (Etempvar _action tuint)
                (Econst_int (Int.repr 277350553) tint) tint) tbool))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sset _t'3
            (Ecast
              (Eunop Onotbool
                (Ebinop Oand (Etempvar _t'8 tuint)
                  (Econst_int (Int.repr 262144) tint) tuint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _peakHeight tfloat))
        (Ssequence
          (Sset _t'5
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Ogt
                         (Ebinop Osub (Etempvar _t'4 tfloat)
                           (Etempvar _t'5 tfloat) tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1150271488)) tfloat)
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'7
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
                             (Ecast (Econst_int (Int.repr 2) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 16) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 192) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil)))
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
                    (Econst_int (Int.repr 262144) tint) tuint))))
            Sskip)))
      Sskip)))
|}.

Definition f_play_knockback_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ole (Etempvar _t'3 tfloat)
                       (Eunop Oneg
                         (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat)
                         tfloat) tint)
          (Sset _t'1 (Ecast (Econst_int (Int.repr 1) tint) tbool))
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Oge (Etempvar _t'4 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat)
                    tint) tbool)))
            (Sset _t'1 (Ecast (Etempvar _t'1 tint) tbool)))))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
  (Sifthenelse (Etempvar _t'1 tint)
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 48) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 5) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))))
|}.

Definition f_lava_boost_on_wall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tfloat) :: (_t'9, (tptr (Tstruct _Surface noattr))) ::
               (_t'8, tfloat) :: (_t'7, tuint) :: (_t'6, tuchar) ::
               (_t'5, tuint) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _wall
          (tptr (Tstruct _Surface noattr))))
      (Ssequence
        (Sset _t'10
          (Efield
            (Efield
              (Ederef (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _z
            tfloat))
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _wall
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'12
              (Efield
                (Efield
                  (Ederef (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _normal
                  (Tstruct __670 noattr)) _x tfloat))
            (Scall (Some _t'1)
              (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                              cc_default))
              ((Etempvar _t'10 tfloat) :: (Etempvar _t'12 tfloat) :: nil))))))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
      (Etempvar _t'1 tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'8 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                     tint)
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat))
        Sskip))
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
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                             (Econst_int (Int.repr 16) tint) tuint)
                (Sset _t'2 (Ecast (Econst_int (Int.repr 12) tint) tint))
                (Sset _t'2 (Ecast (Econst_int (Int.repr 18) tint) tint))))
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _hurtCounter tuchar))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _hurtCounter tuchar)
                (Ebinop Oadd (Etempvar _t'6 tuchar) (Etempvar _t'2 tint)
                  tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'4
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
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 2) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 20) tint) tuint)
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
                   (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Scall None
            (Evar _update_mario_sound_and_camera (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16910519) tint) ::
               (Econst_int (Int.repr 1) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint)))))))))
|}.

Definition f_check_fall_damage := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_hardFallAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_fallHeight, tfloat) :: (_damageHeight, tfloat) ::
               (_t'6, tint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tushort) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _Surface noattr))) :: (_t'14, tuint) ::
               (_t'13, tuint) :: (_t'12, tuchar) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tuint) ::
               (_t'9, tuchar) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _peakHeight tfloat))
    (Ssequence
      (Sset _t'19
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sset _fallHeight
        (Ebinop Osub (Etempvar _t'18 tfloat) (Etempvar _t'19 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tushort)
                     (Econst_int (Int.repr 8390825) tint) tint)
        (Sset _damageHeight
          (Econst_single (Float32.of_bits (Int.repr 1142292480)) tfloat))
        (Sset _damageHeight
          (Econst_single (Float32.of_bits (Int.repr 1150271488)) tfloat))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop One (Etempvar _t'14 tuint)
                         (Econst_int (Int.repr 276826276) tint) tint)
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _t'15 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _type tshort))
                (Sset _t'6
                  (Ecast
                    (Ebinop One (Etempvar _t'16 tshort)
                      (Econst_int (Int.repr 1) tint) tint) tbool))))
            (Sset _t'6 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'6 tint)
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'7 tfloat)
                           (Eunop Oneg
                             (Econst_single (Float32.of_bits (Int.repr 1113325568)) tfloat)
                             tfloat) tint)
              (Sifthenelse (Ebinop Ogt (Etempvar _fallHeight tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1161527296)) tfloat)
                             tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _flags tuint))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'13 tuint)
                                     (Econst_int (Int.repr 16) tint) tuint)
                        (Sset _t'1
                          (Ecast (Econst_int (Int.repr 16) tint) tint))
                        (Sset _t'1
                          (Ecast (Econst_int (Int.repr 24) tint) tint))))
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _hurtCounter
                          tuchar))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _hurtCounter
                          tuchar)
                        (Ebinop Oadd (Etempvar _t'12 tuchar)
                          (Etempvar _t'1 tint) tint))))
                  (Ssequence
                    (Scall None
                      (Evar _set_camera_shake_from_hit (Tfunction
                                                         (tshort :: nil)
                                                         tvoid cc_default))
                      ((Econst_int (Int.repr 9) tint) :: nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'11
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
                                     (Ecast (Econst_int (Int.repr 2) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 10) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 255) tint)
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
                                   (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _drop_and_set_mario_action (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint ::
                                                              tuint :: nil)
                                                             tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _hardFallAction tuint) ::
                           (Econst_int (Int.repr 4) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'2 tint)))))))
                (Ssequence
                  (Sifthenelse (Ebinop Ogt (Etempvar _fallHeight tfloat)
                                 (Etempvar _damageHeight tfloat) tint)
                    (Ssequence
                      (Scall (Some _t'5)
                        (Evar _mario_floor_is_slippery (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tuint
                                                         cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _t'4
                        (Ecast (Eunop Onotbool (Etempvar _t'5 tuint) tint)
                          tbool)))
                    (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _flags tuint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'10 tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint)
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 8) tint) tint))
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 12) tint) tint))))
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _hurtCounter
                              tuchar))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _hurtCounter
                              tuchar)
                            (Ebinop Oadd (Etempvar _t'9 tuchar)
                              (Etempvar _t'3 tint) tint))))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _squishTimer
                            tuchar) (Econst_int (Int.repr 30) tint))
                        (Ssequence
                          (Scall None
                            (Evar _set_camera_shake_from_hit (Tfunction
                                                               (tshort ::
                                                                nil) tvoid
                                                               cc_default))
                            ((Econst_int (Int.repr 9) tint) :: nil))
                          (Ssequence
                            (Sset _t'8
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
                                           (Econst_int (Int.repr 10) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 255) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil))))))
                    Sskip)))
              Sskip))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_check_kick_or_dive_in_air := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tint) :: (_t'4, tfloat) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1105199104)) tfloat)
                           tint)
              (Sset _t'1 (Ecast (Econst_int (Int.repr 25692298) tint) tint))
              (Sset _t'1 (Ecast (Econst_int (Int.repr 25168044) tint) tint))))
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'1 tint) :: (Econst_int (Int.repr 0) tint) :: nil)))
        (Sreturn (Some (Etempvar _t'2 tuint))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_should_get_stuck_in_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_terrainType, tuint) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_flags, tint) :: (_type, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Area noattr))) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _terrainType tushort))
      (Sset _terrainType
        (Ebinop Oand (Etempvar _t'11 tushort) (Econst_int (Int.repr 7) tint)
          tint))))
  (Ssequence
    (Sset _floor
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floor
        (tptr (Tstruct _Surface noattr))))
    (Ssequence
      (Sset _flags
        (Efield
          (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
            (Tstruct _Surface noattr)) _flags tschar))
      (Ssequence
        (Sset _type
          (Efield
            (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _type tshort))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop One
                               (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Sifthenelse (Ebinop Oeq (Etempvar _terrainType tuint)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Sset _t'3 (Ecast (Econst_int (Int.repr 1) tint) tbool))
                    (Ssequence
                      (Sset _t'3
                        (Ecast
                          (Ebinop Oeq (Etempvar _terrainType tuint)
                            (Econst_int (Int.repr 3) tint) tint) tbool))
                      (Sset _t'3 (Ecast (Etempvar _t'3 tint) tbool))))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Sset _t'4
                    (Ecast
                      (Ebinop One (Etempvar _type tint)
                        (Econst_int (Int.repr 1) tint) tint) tbool))
                  (Sset _t'4 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'4 tint)
                (Sifthenelse (Ebinop One (Etempvar _type tint)
                               (Econst_int (Int.repr 48) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Ebinop Oge (Etempvar _type tint)
                                     (Econst_int (Int.repr 53) tint) tint)
                        (Sset _t'6
                          (Ecast
                            (Ebinop Ole (Etempvar _type tint)
                              (Econst_int (Int.repr 55) tint) tint) tbool))
                        (Sset _t'6 (Econst_int (Int.repr 0) tint)))
                      (Sset _t'5
                        (Ecast (Eunop Onotbool (Etempvar _t'6 tint) tint)
                          tbool)))
                    (Sset _t'5 (Ecast (Etempvar _t'5 tint) tbool)))
                  (Sset _t'5 (Ecast (Econst_int (Int.repr 0) tint) tbool)))
                (Sset _t'5 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'5 tint)
              (Ssequence
                (Ssequence
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _flags tint)
                                   (Econst_int (Int.repr 1) tint) tint) tint)
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _peakHeight tfloat))
                      (Ssequence
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sset _t'1
                          (Ecast
                            (Ebinop Ogt
                              (Ebinop Osub (Etempvar _t'8 tfloat)
                                (Etempvar _t'9 tfloat) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1148846080)) tfloat)
                              tint) tbool))))
                    (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                              (Tstruct _Surface noattr)) _normal
                            (Tstruct __670 noattr)) _y tfloat))
                      (Sset _t'2
                        (Ecast
                          (Ebinop Oge (Etempvar _t'7 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1063105495)) tfloat)
                            tint) tbool)))
                    (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                  Sskip))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_check_fall_damage_or_get_stuck := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_hardFallAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _should_get_stuck_in_ground (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Ssequence
          (Sset _t'4
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
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 2) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 11) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 208) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
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
              (Ebinop Oor (Etempvar _t'3 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 16) tint) tint) tuint)))
          (Ssequence
            (Scall None
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131900) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
      Sskip))
  (Ssequence
    (Scall (Some _t'2)
      (Evar _check_fall_damage (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _hardFallAction tuint) :: nil))
    (Sreturn (Some (Etempvar _t'2 tint)))))
|}.

Definition f_check_horizontal_wind := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floor, (tptr (Tstruct _Surface noattr))) ::
               (_speed, tfloat) :: (_pushAngle, tshort) :: (_t'2, tshort) ::
               (_t'1, tfloat) :: (_t'21, tshort) :: (_t'20, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tfloat) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _floor
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _floor
      (tptr (Tstruct _Surface noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
            (Tstruct _Surface noattr)) _type tshort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tshort)
                     (Econst_int (Int.repr 44) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _force tshort))
            (Sset _pushAngle
              (Ecast
                (Ebinop Oshl (Etempvar _t'21 tshort)
                  (Econst_int (Int.repr 8) tint) tint) tshort)))
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _slideVelX tfloat))
              (Ssequence
                (Sset _t'20
                  (Ederef
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Ebinop Oshr
                        (Ecast (Etempvar _pushAngle tshort) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelX tfloat)
                  (Ebinop Oadd (Etempvar _t'19 tfloat)
                    (Ebinop Omul
                      (Econst_single (Float32.of_bits (Int.repr 1067030938)) tfloat)
                      (Etempvar _t'20 tfloat) tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                (Ssequence
                  (Sset _t'18
                    (Ederef
                      (Ebinop Oadd
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                        (Ebinop Oshr
                          (Ecast (Etempvar _pushAngle tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                    (Ebinop Oadd (Etempvar _t'17 tfloat)
                      (Ebinop Omul
                        (Econst_single (Float32.of_bits (Int.repr 1067030938)) tfloat)
                        (Etempvar _t'18 tfloat) tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelX tfloat))
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelX tfloat))
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelZ
                            tfloat))
                        (Ssequence
                          (Sset _t'16
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelZ
                              tfloat))
                          (Scall (Some _t'1)
                            (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                           cc_default))
                            ((Ebinop Oadd
                               (Ebinop Omul (Etempvar _t'13 tfloat)
                                 (Etempvar _t'14 tfloat) tfloat)
                               (Ebinop Omul (Etempvar _t'15 tfloat)
                                 (Etempvar _t'16 tfloat) tfloat) tfloat) ::
                             nil))))))
                  (Sset _speed (Etempvar _t'1 tfloat)))
                (Ssequence
                  (Sifthenelse (Ebinop Ogt (Etempvar _speed tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                                 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat)
                          (Ebinop Odiv
                            (Ebinop Omul (Etempvar _t'12 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                              tfloat) (Etempvar _speed tfloat) tfloat)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelZ
                              tfloat))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelZ
                              tfloat)
                            (Ebinop Odiv
                              (Ebinop Omul (Etempvar _t'11 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                                tfloat) (Etempvar _speed tfloat) tfloat)))
                        (Sset _speed
                          (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))))
                    (Sifthenelse (Ebinop Ogt (Etempvar _speed tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                   tint)
                      (Sset _speed
                        (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
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
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 0) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'10 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelZ
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 2) tint) (tptr tfloat))
                            tfloat) (Etempvar _t'9 tfloat)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'7
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelZ
                                tfloat))
                            (Ssequence
                              (Sset _t'8
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _slideVelX
                                  tfloat))
                              (Scall (Some _t'2)
                                (Evar _atan2s (Tfunction
                                                (tfloat :: tfloat :: nil)
                                                tshort cc_default))
                                ((Etempvar _t'7 tfloat) ::
                                 (Etempvar _t'8 tfloat) :: nil))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideYaw
                              tshort) (Etempvar _t'2 tshort)))
                        (Ssequence
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
                            (Ssequence
                              (Sset _t'5
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _slideYaw
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
                                        (Ecast
                                          (Ebinop Osub (Etempvar _t'4 tshort)
                                            (Etempvar _t'5 tshort) tint)
                                          tushort)
                                        (Econst_int (Int.repr 4) tint) tint)
                                      (tptr tfloat)) tfloat))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _forwardVel tfloat)
                                  (Ebinop Omul (Etempvar _speed tfloat)
                                    (Etempvar _t'6 tfloat) tfloat)))))
                          (Sreturn (Some (Econst_int (Int.repr 1) tint))))))))))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_update_air_with_turn := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_dragThreshold, tfloat) :: (_intendedDYaw, tshort) ::
               (_intendedMag, tfloat) :: (_t'5, tint) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'25, tuint) :: (_t'24, tfloat) :: (_t'23, tshort) ::
               (_t'22, tshort) :: (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tshort) ::
               (_t'16, tushort) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tshort) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tshort) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall (Some _t'5)
    (Evar _check_horizontal_wind (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Sifthenelse (Eunop Onotbool (Etempvar _t'5 tint) tint)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'25
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'25 tuint)
                         (Econst_int (Int.repr 50333832) tint) tint)
            (Sset _t'1
              (Ecast
                (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                tfloat))
            (Sset _t'1
              (Ecast
                (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                tfloat))))
        (Sset _dragThreshold (Etempvar _t'1 tfloat)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'24
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'2)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'24 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
               nil)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'2 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'22
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedYaw tshort))
                  (Ssequence
                    (Sset _t'23
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
                        (Ebinop Osub (Etempvar _t'22 tshort)
                          (Etempvar _t'23 tshort) tint) tshort))))
                (Ssequence
                  (Ssequence
                    (Sset _t'21
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedMag tfloat))
                    (Sset _intendedMag
                      (Ebinop Odiv (Etempvar _t'21 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                        tfloat)))
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
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Econst_int (Int.repr 1024) tint)
                                (tptr tfloat))
                              (Ebinop Oshr
                                (Ecast (Etempvar _intendedDYaw tshort)
                                  tushort) (Econst_int (Int.repr 4) tint)
                                tint) (tptr tfloat)) tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat)
                          (Ebinop Oadd (Etempvar _t'19 tfloat)
                            (Ebinop Omul
                              (Ebinop Omul
                                (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
                                (Etempvar _t'20 tfloat) tfloat)
                              (Etempvar _intendedMag tfloat) tfloat) tfloat))))
                    (Ssequence
                      (Sset _t'17
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
                        (Sset _t'18
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _intendedDYaw tshort)
                                  tushort) (Econst_int (Int.repr 4) tint)
                                tint) (tptr tfloat)) tfloat))
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
                          (Ebinop Oadd (Etempvar _t'17 tshort)
                            (Ebinop Omul
                              (Ebinop Omul
                                (Econst_single (Float32.of_bits (Int.repr 1140850688)) tfloat)
                                (Etempvar _t'18 tfloat) tfloat)
                              (Etempvar _intendedMag tfloat) tfloat) tfloat)))))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tfloat)
                             (Etempvar _dragThreshold tfloat) tint)
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Osub (Etempvar _t'15 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                      tfloat)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                               (Eunop Oneg
                                 (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                 tfloat) tint)
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Oadd (Etempvar _t'13 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                        tfloat)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Ssequence
                        (Sset _t'10
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
                          (Sset _t'11
                            (Ederef
                              (Ebinop Oadd
                                (Evar _gSineTable (tarray tfloat 0))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'10 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sset _t'3
                            (Ecast
                              (Ebinop Omul (Etempvar _t'9 tfloat)
                                (Etempvar _t'11 tfloat) tfloat) tfloat)))))
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
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'8
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'7 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sset _t'4
                            (Ecast
                              (Ebinop Omul (Etempvar _t'6 tfloat)
                                (Etempvar _t'8 tfloat) tfloat) tfloat)))))
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
                        (tptr tfloat)) tfloat) (Etempvar _t'4 tfloat)))))))))
    Sskip))
|}.

Definition f_update_air_without_turn := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sidewaysSpeed, tfloat) :: (_dragThreshold, tfloat) ::
               (_intendedDYaw, tshort) :: (_intendedMag, tfloat) ::
               (_t'3, tint) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'30, tuint) :: (_t'29, tfloat) :: (_t'28, tshort) ::
               (_t'27, tshort) :: (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, tfloat) :: (_t'23, tfloat) :: (_t'22, tushort) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tshort) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tshort) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tshort) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _sidewaysSpeed (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
  (Ssequence
    (Scall (Some _t'3)
      (Evar _check_horizontal_wind (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'30
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'30 tuint)
                           (Econst_int (Int.repr 50333832) tint) tint)
              (Sset _t'1
                (Ecast
                  (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                  tfloat))
              (Sset _t'1
                (Ecast
                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                  tfloat))))
          (Sset _dragThreshold (Etempvar _t'1 tfloat)))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'29
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Scall (Some _t'2)
                (Evar _approach_f32 (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       tfloat :: nil) tfloat cc_default))
                ((Etempvar _t'29 tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
                 nil)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Etempvar _t'2 tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'22
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'22 tushort)
                             (Econst_int (Int.repr 1) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedYaw tshort))
                    (Ssequence
                      (Sset _t'28
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sset _intendedDYaw
                        (Ecast
                          (Ebinop Osub (Etempvar _t'27 tshort)
                            (Etempvar _t'28 tshort) tint) tshort))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'26
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _intendedMag
                          tfloat))
                      (Sset _intendedMag
                        (Ebinop Odiv (Etempvar _t'26 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                          tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'24
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Ssequence
                          (Sset _t'25
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _intendedDYaw tshort)
                                    tushort) (Econst_int (Int.repr 4) tint)
                                  tint) (tptr tfloat)) tfloat))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'24 tfloat)
                              (Ebinop Omul
                                (Ebinop Omul (Etempvar _intendedMag tfloat)
                                  (Etempvar _t'25 tfloat) tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
                                tfloat) tfloat))))
                      (Ssequence
                        (Sset _t'23
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _intendedDYaw tshort)
                                  tushort) (Econst_int (Int.repr 4) tint)
                                tint) (tptr tfloat)) tfloat))
                        (Sset _sidewaysSpeed
                          (Ebinop Omul
                            (Ebinop Omul (Etempvar _intendedMag tfloat)
                              (Etempvar _t'23 tfloat) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                            tfloat))))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'20 tfloat)
                               (Etempvar _dragThreshold tfloat) tint)
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
                      (Ebinop Osub (Etempvar _t'21 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                        tfloat)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'18 tfloat)
                                 (Eunop Oneg
                                   (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                   tfloat) tint)
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
                          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                          tfloat)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'15
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Ssequence
                      (Sset _t'16
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
                        (Sset _t'17
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _t'16 tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat)
                          (Ebinop Omul (Etempvar _t'15 tfloat)
                            (Etempvar _t'17 tfloat) tfloat)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Econst_int (Int.repr 1024) tint)
                                  (tptr tfloat))
                                (Ebinop Oshr
                                  (Ecast (Etempvar _t'13 tshort) tushort)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (tptr tfloat)) tfloat))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelZ
                              tfloat)
                            (Ebinop Omul (Etempvar _t'12 tfloat)
                              (Etempvar _t'14 tfloat) tfloat)))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat))
                        (Ssequence
                          (Sset _t'10
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
                            (Sset _t'11
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
                                  (Ebinop Oshr
                                    (Ecast
                                      (Ebinop Oadd (Etempvar _t'10 tshort)
                                        (Econst_int (Int.repr 16384) tint)
                                        tint) tushort)
                                    (Econst_int (Int.repr 4) tint) tint)
                                  (tptr tfloat)) tfloat))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelX
                                tfloat)
                              (Ebinop Oadd (Etempvar _t'9 tfloat)
                                (Ebinop Omul (Etempvar _sidewaysSpeed tfloat)
                                  (Etempvar _t'11 tfloat) tfloat) tfloat)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelZ
                              tfloat))
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
                                        (Ebinop Oadd (Etempvar _t'7 tshort)
                                          (Econst_int (Int.repr 16384) tint)
                                          tint) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _slideVelZ
                                  tfloat)
                                (Ebinop Oadd (Etempvar _t'6 tfloat)
                                  (Ebinop Omul
                                    (Etempvar _sidewaysSpeed tfloat)
                                    (Etempvar _t'8 tfloat) tfloat) tfloat)))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'5
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelX
                                tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _vel
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tfloat)) tfloat)
                              (Etempvar _t'5 tfloat)))
                          (Ssequence
                            (Sset _t'4
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelZ
                                tfloat))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _vel
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tfloat)) tfloat)
                              (Etempvar _t'4 tfloat)))))))))))))
      Sskip)))
|}.

Definition f_update_lava_boost_or_twirling := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_intendedDYaw, tshort) :: (_intendedMag, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: (_t'21, tshort) ::
               (_t'20, tshort) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tfloat) :: (_t'16, tfloat) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tushort) ::
               (_t'8, tfloat) :: (_t'7, tshort) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tshort) :: (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'20
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedYaw tshort))
          (Ssequence
            (Sset _t'21
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _intendedDYaw
              (Ecast
                (Ebinop Osub (Etempvar _t'20 tshort) (Etempvar _t'21 tshort)
                  tint) tshort))))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedMag tfloat))
            (Sset _intendedMag
              (Ebinop Odiv (Etempvar _t'19 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                tfloat)))
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
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                      (Ebinop Oshr
                        (Ecast (Etempvar _intendedDYaw tshort) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Ebinop Oadd (Etempvar _t'17 tfloat)
                    (Ebinop Omul (Etempvar _t'18 tfloat)
                      (Etempvar _intendedMag tfloat) tfloat) tfloat))))
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
                (Ssequence
                  (Sset _t'16
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr
                          (Ecast (Etempvar _intendedDYaw tshort) tushort)
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
                    (Ebinop Oadd (Etempvar _t'15 tshort)
                      (Ebinop Omul
                        (Ebinop Omul (Etempvar _t'16 tfloat)
                          (Etempvar _intendedMag tfloat) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1149239296)) tfloat)
                        tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
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
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
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
                          (Ebinop Oadd (Etempvar _t'14 tshort)
                            (Econst_int (Int.repr 32768) tint) tint)))
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat)
                          (Ebinop Omul (Etempvar _t'13 tfloat)
                            (Eunop Oneg
                              (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                              tfloat) tfloat))))
                    Sskip))
                (Ssequence
                  (Sset _t'10
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'10 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                 tint)
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat)
                        (Ebinop Osub (Etempvar _t'11 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                          tfloat)))
                    Sskip)))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Ebinop Oshr (Ecast (Etempvar _t'7 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Omul (Etempvar _t'6 tfloat) (Etempvar _t'8 tfloat)
                    tfloat) tfloat)))))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _slideVelX tfloat)
          (Etempvar _t'1 tfloat)))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
        (Etempvar _t'1 tfloat)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'4 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _t'2
                (Ecast
                  (Ebinop Omul (Etempvar _t'3 tfloat) (Etempvar _t'5 tfloat)
                    tfloat) tfloat)))))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _slideVelZ tfloat)
          (Etempvar _t'2 tfloat)))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
        (Etempvar _t'2 tfloat)))))
|}.

Definition f_update_flying_yaw := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetYawVel, tshort) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'18, tfloat) :: (_t'17, tfloat) ::
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
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sset _targetYawVel
          (Ecast
            (Eunop Oneg
              (Ecast
                (Ebinop Omul (Etempvar _t'17 tfloat)
                  (Ebinop Odiv (Etempvar _t'18 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                    tfloat) tfloat) tshort) tint) tshort)))))
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
          (Ebinop Omul (Econst_int (Int.repr 20) tint)
            (Eunop Oneg (Etempvar _t'4 tshort) tint) tint))))))
|}.

Definition f_update_flying_pitch := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_targetPitchVel, tshort) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Controller noattr))) ::
               (_t'12, tshort) :: (_t'11, tshort) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'13
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _controller
        (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _t'13 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _stickY tfloat))
      (Ssequence
        (Sset _t'15
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sset _targetPitchVel
          (Ecast
            (Eunop Oneg
              (Ecast
                (Ebinop Omul (Etempvar _t'14 tfloat)
                  (Ebinop Odiv (Etempvar _t'15 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
                    tfloat) tfloat) tshort) tint) tshort)))))
  (Sifthenelse (Ebinop Ogt (Etempvar _targetPitchVel tshort)
                 (Econst_int (Int.repr 0) tint) tint)
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
            (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'9 tshort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort)
              (Ebinop Oadd (Etempvar _t'12 tshort)
                (Econst_int (Int.repr 64) tint) tint)))
          (Ssequence
            (Sset _t'11
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'11 tshort)
                           (Econst_int (Int.repr 32) tint) tint)
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort) (Econst_int (Int.repr 32) tint))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort))
            (Scall (Some _t'1)
              (Evar _approach_s32 (Tfunction
                                    (tint :: tint :: tint :: tint :: nil)
                                    tint cc_default))
              ((Etempvar _t'10 tshort) ::
               (Etempvar _targetPitchVel tshort) ::
               (Econst_int (Int.repr 32) tint) ::
               (Econst_int (Int.repr 64) tint) :: nil)))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort) (Etempvar _t'1 tint)))))
    (Sifthenelse (Ebinop Olt (Etempvar _targetPitchVel tshort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'5
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tshort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort)
                (Ebinop Osub (Etempvar _t'8 tshort)
                  (Econst_int (Int.repr 64) tint) tint)))
            (Ssequence
              (Sset _t'7
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Sifthenelse (Ebinop Olt (Etempvar _t'7 tshort)
                             (Eunop Oneg (Econst_int (Int.repr 32) tint)
                               tint) tint)
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _angleVel
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort)
                  (Eunop Oneg (Econst_int (Int.repr 32) tint) tint))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                    (tptr tshort)) tshort))
              (Scall (Some _t'2)
                (Evar _approach_s32 (Tfunction
                                      (tint :: tint :: tint :: tint :: nil)
                                      tint cc_default))
                ((Etempvar _t'6 tshort) ::
                 (Etempvar _targetPitchVel tshort) ::
                 (Econst_int (Int.repr 64) tint) ::
                 (Econst_int (Int.repr 32) tint) :: nil)))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort) (Etempvar _t'2 tint)))))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Scall (Some _t'3)
            (Evar _approach_s32 (Tfunction
                                  (tint :: tint :: tint :: tint :: nil) tint
                                  cc_default))
            ((Etempvar _t'4 tshort) :: (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 64) tint) ::
             (Econst_int (Int.repr 64) tint) :: nil)))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
              (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort)
          (Etempvar _t'3 tint))))))
|}.

Definition f_update_flying := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'32, tshort) :: (_t'31, tfloat) :: (_t'30, tfloat) ::
               (_t'29, tshort) :: (_t'28, tfloat) :: (_t'27, tfloat) ::
               (_t'26, tfloat) :: (_t'25, tshort) :: (_t'24, tfloat) ::
               (_t'23, tshort) :: (_t'22, tshort) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tshort) :: (_t'18, tshort) ::
               (_t'17, tshort) :: (_t'16, tshort) :: (_t'15, tfloat) ::
               (_t'14, tshort) :: (_t'13, tfloat) :: (_t'12, tshort) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tshort) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: (_t'4, tshort) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _update_flying_pitch (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) :: nil)
                                 tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _update_flying_yaw (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) :: nil)
                                 tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'31
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Ssequence
          (Sset _t'32
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Ebinop Osub (Etempvar _t'31 tfloat)
              (Ebinop Oadd
                (Ebinop Omul
                  (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                  (Ebinop Odiv (Ecast (Etempvar _t'32 tshort) tfloat)
                    (Econst_int (Int.repr 16384) tint) tfloat) tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat)
                tfloat) tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'28
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Ssequence
            (Sset _t'29
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Ssequence
              (Sset _t'30
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _t'29 tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Ebinop Osub (Etempvar _t'28 tfloat)
                  (Ebinop Omul
                    (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                    (Ebinop Osub
                      (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                      (Etempvar _t'30 tfloat) tfloat) tfloat) tfloat)))))
        (Ssequence
          (Ssequence
            (Sset _t'27
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'27 tfloat)
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
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'20 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'25
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort))
                  (Ssequence
                    (Sset _t'26
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'25 tshort)
                        (Ebinop Omul
                          (Ebinop Osub (Etempvar _t'26 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                            tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1086324736)) tfloat)
                          tfloat) tfloat))))
                (Ssequence
                  (Sset _t'21
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'21 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                 tint)
                    (Ssequence
                      (Sset _t'23
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
                        (Sset _t'24
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
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
                          (Ebinop Oadd (Etempvar _t'23 tshort)
                            (Ebinop Omul
                              (Ebinop Osub (Etempvar _t'24 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                              tfloat) tfloat))))
                    (Ssequence
                      (Sset _t'22
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
                        (Ebinop Osub (Etempvar _t'22 tshort)
                          (Econst_int (Int.repr 1024) tint) tint)))))))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Ssequence
                  (Sset _t'19
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _angleVel
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Oadd (Etempvar _t'18 tshort)
                      (Etempvar _t'19 tshort) tint))))
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
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'17 tshort)
                                 (Econst_int (Int.repr 10922) tint) tint)
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort)
                      (Econst_int (Int.repr 10922) tint))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'16 tshort)
                                   (Eunop Oneg
                                     (Econst_int (Int.repr 10922) tint) tint)
                                   tint)
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
                        (Eunop Oneg (Econst_int (Int.repr 10922) tint) tint))
                      Sskip))
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
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort))
                        (Ssequence
                          (Sset _t'13
                            (Ederef
                              (Ebinop Oadd
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
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
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort))
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
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tfloat)) tfloat)
                                (Ebinop Omul
                                  (Ebinop Omul (Etempvar _t'11 tfloat)
                                    (Etempvar _t'13 tfloat) tfloat)
                                  (Etempvar _t'15 tfloat) tfloat)))))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Ssequence
                          (Sset _t'9
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
                            (Sset _t'10
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _gSineTable (tarray tfloat 0))
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
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Omul (Etempvar _t'8 tfloat)
                                (Etempvar _t'10 tfloat) tfloat)))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'3
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat))
                          (Ssequence
                            (Sset _t'4
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
                              (Sset _t'5
                                (Ederef
                                  (Ebinop Oadd
                                    (Ebinop Oadd
                                      (Evar _gSineTable (tarray tfloat 0))
                                      (Econst_int (Int.repr 1024) tint)
                                      (tptr tfloat))
                                    (Ebinop Oshr
                                      (Ecast (Etempvar _t'4 tshort) tushort)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    (tptr tfloat)) tfloat))
                              (Ssequence
                                (Sset _t'6
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
                                  (Sset _t'7
                                    (Ederef
                                      (Ebinop Oadd
                                        (Ebinop Oadd
                                          (Evar _gSineTable (tarray tfloat 0))
                                          (Econst_int (Int.repr 1024) tint)
                                          (tptr tfloat))
                                        (Ebinop Oshr
                                          (Ecast (Etempvar _t'6 tshort)
                                            tushort)
                                          (Econst_int (Int.repr 4) tint)
                                          tint) (tptr tfloat)) tfloat))
                                  (Sassign
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _vel (tarray tfloat 3))
                                        (Econst_int (Int.repr 2) tint)
                                        (tptr tfloat)) tfloat)
                                    (Ebinop Omul
                                      (Ebinop Omul (Etempvar _t'3 tfloat)
                                        (Etempvar _t'5 tfloat) tfloat)
                                      (Etempvar _t'7 tfloat) tfloat)))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'2
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
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelX
                                tfloat) (Etempvar _t'2 tfloat)))
                          (Ssequence
                            (Sset _t'1
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
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelZ
                                tfloat) (Etempvar _t'1 tfloat))))))))))))))))
|}.

Definition f_common_air_action_step := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_landAction, tuint) :: (_animation, tint) ::
                (_stepArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_stepResult, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'10, tshort) :: (_t'9, tfloat) ::
               (_t'8, tuint) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tfloat) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _update_air_without_turn (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _perform_air_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _stepArg tuint) :: nil))
      (Sset _stepResult (Etempvar _t'1 tint)))
    (Ssequence
      (Sswitch (Etempvar _stepResult tuint)
        (LScons (Some 0)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _animation tint) :: nil))
            Sbreak)
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: nil) tint
                                                          cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 132192) tint) :: nil))
                (Sifthenelse (Eunop Onotbool (Etempvar _t'2 tint) tint)
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _landAction tuint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sskip))
              Sbreak)
            (LScons (Some 2)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _animation tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                   tint)
                      (Ssequence
                        (Scall None
                          (Evar _mario_bonk_reflection (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tuint :: nil) tvoid
                                                         cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'10
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort))
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
                              (Ebinop Oadd (Etempvar _t'10 tshort)
                                (Econst_int (Int.repr 32768) tint) tint)))
                          (Ssequence
                            (Sset _t'5
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _wall
                                (tptr (Tstruct _Surface noattr))))
                            (Sifthenelse (Ebinop One
                                           (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 2215) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'9
                                    (Ederef
                                      (Ebinop Oadd
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _vel (tarray tfloat 3))
                                        (Econst_int (Int.repr 1) tint)
                                        (tptr tfloat)) tfloat))
                                  (Sifthenelse (Ebinop Ogt
                                                 (Etempvar _t'9 tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                 tint)
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
                                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                    Sskip))
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Sifthenelse (Ebinop Oge
                                                 (Etempvar _t'6 tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 1108869120)) tfloat)
                                                 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'8
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
                                          (Ebinop Oor (Etempvar _t'8 tuint)
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 1) tint)
                                              tint) tuint)))
                                      (Scall None
                                        (Evar _set_mario_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tuint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 16910512) tint) ::
                                         (Econst_int (Int.repr 0) tint) ::
                                         nil)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'7
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _forwardVel tfloat))
                                        (Sifthenelse (Ebinop Ogt
                                                       (Etempvar _t'7 tfloat)
                                                       (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                                       tint)
                                          (Scall None
                                            (Evar _mario_set_forward_vel 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tfloat :: nil) tvoid
                                              cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             (Eunop Oneg
                                               (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                               tfloat) :: nil))
                                          Sskip))
                                      (Ssequence
                                        (Scall (Some _t'3)
                                          (Evar _set_mario_action (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    tuint ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           (Econst_int (Int.repr 16910518) tint) ::
                                           (Econst_int (Int.repr 0) tint) ::
                                           nil))
                                        (Sreturn (Some (Etempvar _t'3 tuint))))))))))))
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                         nil))))
                  Sbreak))
              (LScons (Some 3)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 51) tint) :: nil))
                  (Ssequence
                    (Scall None
                      (Evar _drop_and_set_mario_action (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tuint :: tuint ::
                                                          nil) tint
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 134218571) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak))
                (LScons (Some 4)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 136315720) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))))))
      (Sreturn (Some (Etempvar _stepResult tuint))))))
|}.

Definition f_act_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tint) :: (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_kick_or_dive_in_air (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
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
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _common_air_action_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tint :: tuint :: nil)
                                          tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67110000) tint) ::
           (Econst_int (Int.repr 77) tint) ::
           (Ebinop Oor (Econst_int (Int.repr 1) tint)
             (Econst_int (Int.repr 2) tint) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_double_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animation, tint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'5, tfloat) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                     tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 80) tint) tint))
        (Sset _t'1 (Ecast (Econst_int (Int.repr 76) tint) tint))))
    (Sset _animation (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _check_kick_or_dive_in_air (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
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
        (Scall None
          (Evar _play_mario_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 3) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) :: nil))
        (Ssequence
          (Scall None
            (Evar _common_air_action_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tint :: tuint :: nil)
                                            tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 67110002) tint) ::
             (Etempvar _animation tint) ::
             (Ebinop Oor (Econst_int (Int.repr 1) tint)
               (Econst_int (Int.repr 2) tint) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_triple_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'6, tuchar) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6 (Evar _gSpecialTripleJump tuchar))
    (Sifthenelse (Etempvar _t'6 tuchar)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 50333871) tint) ::
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
                     (Econst_int (Int.repr 8192) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 25692298) tint) ::
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
        (Scall None
          (Evar _play_mario_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _common_air_action_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tint :: tuint :: nil)
                                            tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 67110008) tint) ::
             (Econst_int (Int.repr 193) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _play_flip_sounds (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tshort :: tshort :: tshort :: nil)
                                        tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 2) tint) ::
               (Econst_int (Int.repr 8) tint) ::
               (Econst_int (Int.repr 20) tint) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_backflip := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 32768) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 8390825) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Scall None
        (Evar _common_air_action_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tint :: tuint :: nil) tuint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 67110010) tint) ::
         (Econst_int (Int.repr 4) tint) :: (Econst_int (Int.repr 0) tint) ::
         nil))
      (Ssequence
        (Scall None
          (Evar _play_flip_sounds (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tshort :: tshort :: tshort :: nil) tvoid
                                    cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 2) tint) ::
           (Econst_int (Int.repr 3) tint) ::
           (Econst_int (Int.repr 17) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_freefall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animation, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'5, tushort) :: (_t'4, tushort) :: (_t'3, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 25692298) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
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
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionArg tuint))
        (Sswitch (Etempvar _t'3 tuint)
          (LScons (Some 0)
            (Ssequence
              (Sset _animation (Econst_int (Int.repr 86) tint))
              Sbreak)
            (LScons (Some 1)
              (Ssequence
                (Sset _animation (Econst_int (Int.repr 144) tint))
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Sset _animation (Econst_int (Int.repr 83) tint))
                  Sbreak)
                LSnil)))))
      (Ssequence
        (Scall None
          (Evar _common_air_action_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tint :: tuint :: nil)
                                          tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67110001) tint) ::
           (Etempvar _animation tint) :: (Econst_int (Int.repr 1) tint) ::
           nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_hold_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'10, tint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
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
                (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'10 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _heldObj
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
                        (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                    (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
              (Sset _t'3
                (Ecast
                  (Eunop Onotbool
                    (Ebinop Oand (Etempvar _t'8 tuint)
                      (Econst_int (Int.repr 16) tint) tuint) tint) tbool))))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr (-2097149781)) tuint) ::
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
                       (Econst_int (Int.repr 32768) tint) tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 8390825) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _play_mario_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Ssequence
          (Scall None
            (Evar _common_air_action_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tint :: tuint :: nil)
                                            tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1140) tint) ::
             (Econst_int (Int.repr 65) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_freefall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animation, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'11, tuint) ::
               (_t'10, tint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tuint) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tushort) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _animation (Econst_int (Int.repr 67) tint))
      (Sset _animation (Econst_int (Int.repr 68) tint))))
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
                  (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779404) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
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
                          (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                      (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                (Sset _t'3
                  (Ecast
                    (Eunop Onotbool
                      (Ebinop Oand (Etempvar _t'8 tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tint) tbool))))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr (-2097149781)) tuint) ::
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
                         (Econst_int (Int.repr 32768) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _drop_and_set_mario_action (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: tuint :: nil)
                                                   tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 8390825) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _common_air_action_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tint :: tuint :: nil)
                                            tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1141) tint) ::
             (Etempvar _animation tint) :: (Econst_int (Int.repr 1) tint) ::
             nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_side_flip := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 25692298) tint) ::
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
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'3)
            (Evar _common_air_action_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tint :: tuint :: nil)
                                            tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 67110003) tint) ::
             (Econst_int (Int.repr 191) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sifthenelse (Ebinop One (Etempvar _t'3 tuint)
                         (Econst_int (Int.repr 3) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
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
                            (Efield
                              (Ederef
                                (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _angle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _angle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Oadd (Etempvar _t'9 tshort)
                      (Econst_int (Int.repr 32768) tint) tint)))))
            Sskip))
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
                             (Econst_int (Int.repr 6) tint) tint)
                (Ssequence
                  (Sset _t'6
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
                               (Ecast (Econst_int (Int.repr 90) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                Sskip)))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_wall_kick_air := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tuint) :: (_t'4, tushort) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 25692298) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
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
      (Scall None
        (Evar _play_mario_jump_sound (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _common_air_action_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tint :: tuint :: nil)
                                          tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67110000) tint) ::
           (Econst_int (Int.repr 203) tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_long_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animation, tint) :: (_t'1, tint) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tushort) ::
               (_t'4, tshort) :: (_t'3, (tptr (Tstruct _Surface noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'7
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
            (tptr tint)) tint))
      (Sifthenelse (Eunop Onotbool (Etempvar _t'7 tint) tint)
        (Sset _animation (Econst_int (Int.repr 19) tint))
        (Sset _animation (Econst_int (Int.repr 20) tint)))))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                           (Econst_int (Int.repr 56) tint) tint)
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oeq (Etempvar _t'5 tushort)
                      (Econst_int (Int.repr 0) tint) tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
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
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 12) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
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
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort)
              (Econst_int (Int.repr 1) tint)))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _common_air_action_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tint :: tuint :: nil)
                                          tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 1145) tint) :: (Etempvar _animation tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_riding_shell_air := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_mario_sound (Tfunction
                              ((tptr (Tstruct _MarioState noattr)) :: tint ::
                               tint :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Ebinop Oor
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 0) tint) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 74) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_air_without_turn (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'1 tint)
            (LScons (Some 1)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 545326150) tint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                     nil))
                  Sbreak)
                (LScons (Some 6)
                  (Ssequence
                    (Scall None
                      (Evar _lava_boost_on_wall (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  LSnil)))))
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
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'4
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat)
                  (Ebinop Oadd (Etempvar _t'4 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat)
                    tfloat)))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_twirling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_startTwirlYaw, tshort) :: (_yawVelTarget, tshort) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'16, tshort) :: (_t'15, tushort) ::
               (_t'14, tshort) :: (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, tuint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _twirlYaw tshort))
    (Sset _startTwirlYaw (Ecast (Etempvar _t'16 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'15
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                     (Econst_int (Int.repr 128) tint) tint)
        (Sset _yawVelTarget (Ecast (Econst_int (Int.repr 8192) tint) tshort))
        (Sset _yawVelTarget (Ecast (Econst_int (Int.repr 6144) tint) tshort))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _angleVel
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort))
          (Scall (Some _t'1)
            (Evar _approach_s32 (Tfunction
                                  (tint :: tint :: tint :: tint :: nil) tint
                                  cc_default))
            ((Etempvar _t'14 tshort) :: (Etempvar _yawVelTarget tshort) ::
             (Econst_int (Int.repr 512) tint) ::
             (Econst_int (Int.repr 512) tint) :: nil)))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
          (Etempvar _t'1 tint)))
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _twirlYaw tshort))
          (Ssequence
            (Sset _t'13
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _angleVel
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _twirlYaw tshort)
              (Ebinop Oadd (Etempvar _t'12 tshort) (Etempvar _t'13 tshort)
                tint))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tuint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sset _t'2 (Ecast (Econst_int (Int.repr 149) tint) tint))
                (Sset _t'2 (Ecast (Econst_int (Int.repr 148) tint) tint))))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _t'2 tint) :: nil)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _is_anim_past_end (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'3 tint)
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionArg tuint)
                  (Econst_int (Int.repr 1) tint))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _twirlYaw tshort))
                (Sifthenelse (Ebinop Ogt (Etempvar _startTwirlYaw tshort)
                               (Etempvar _t'9 tshort) tint)
                  (Ssequence
                    (Sset _t'10
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
                                 (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                 (Econst_int (Int.repr 28) tint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 56) tint)
                                   tuint) (Econst_int (Int.repr 16) tint)
                                 tuint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) ::
                       (Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil)))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _update_lava_boost_or_twirling (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _perform_air_step (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: nil) tint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sswitch (Etempvar _t'4 tint)
                      (LScons (Some 1)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 411042360) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sbreak)
                        (LScons (Some 2)
                          (Ssequence
                            (Scall None
                              (Evar _mario_bonk_reflection (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint :: nil)
                                                             tvoid
                                                             cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 6)
                            (Ssequence
                              (Scall None
                                (Evar _lava_boost_on_wall (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              Sbreak)
                            LSnil)))))
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
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'7
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 1) tint) (tptr tshort))
                              tshort))
                          (Ssequence
                            (Sset _t'8
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _twirlYaw
                                tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _angle (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort)
                              (Ebinop Oadd (Etempvar _t'7 tshort)
                                (Etempvar _t'8 tshort) tint))))))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_dive := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'21, tuint) ::
               (_t'20, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'19, tuint) :: (_t'18, tshort) :: (_t'17, tfloat) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'21
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'21 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 53) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 3) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) :: nil))
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 0) tint) :: nil))))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 136) tint) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _mario_check_object_grab (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'1 tuint)
          (Ssequence
            (Scall None
              (Evar _mario_grab_used_object (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'20
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioBodyState
                    (tptr (Tstruct _MarioBodyState noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'20 (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _grabPos tschar)
                  (Econst_int (Int.repr 1) tint)))
              (Ssequence
                (Sset _t'19
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sifthenelse (Ebinop One (Etempvar _t'19 tuint)
                               (Econst_int (Int.repr 25692298) tint) tint)
                  (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                  Sskip))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _update_air_without_turn (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'2 tint)
              (LScons (Some 0)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'17
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'17 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                     tint)
                        (Ssequence
                          (Sset _t'18
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _faceAngle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
                          (Sset _t'3
                            (Ecast
                              (Ebinop Ogt (Etempvar _t'18 tshort)
                                (Eunop Oneg
                                  (Econst_int (Int.repr 10922) tint) tint)
                                tint) tbool)))
                        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'3 tint)
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
                            (Ebinop Osub (Etempvar _t'16 tshort)
                              (Econst_int (Int.repr 512) tint) tint)))
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
                          (Sifthenelse (Ebinop Olt (Etempvar _t'15 tshort)
                                         (Eunop Oneg
                                           (Econst_int (Int.repr 10922) tint)
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
                              (Eunop Oneg (Econst_int (Int.repr 10922) tint)
                                tint))
                            Sskip)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioObj
                          (tptr (Tstruct _Object noattr))))
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
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _angle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Eunop Oneg (Etempvar _t'14 tshort) tint))))
                    Sbreak))
                (LScons (Some 1)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'5)
                          (Evar _should_get_stuck_in_ground (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sifthenelse (Etempvar _t'5 tint)
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
                            (Sset _t'6
                              (Ecast
                                (Ebinop Oeq (Etempvar _t'12 tshort)
                                  (Eunop Oneg
                                    (Econst_int (Int.repr 10922) tint) tint)
                                  tint) tbool)))
                          (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                      (Sifthenelse (Etempvar _t'6 tint)
                        (Ssequence
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
                                           (Econst_int (Int.repr 11) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 208) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Ebinop Oor
                                     (Econst_int (Int.repr 67108864) tint)
                                     (Econst_int (Int.repr 128) tint) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'10
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
                                (Ebinop Oor (Etempvar _t'10 tuint)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 16) tint) tint)
                                  tuint)))
                            (Scall None
                              (Evar _drop_and_set_mario_action (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tuint ::
                                                                  tuint ::
                                                                  nil) tint
                                                                 cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 131898) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))))
                        (Ssequence
                          (Scall (Some _t'4)
                            (Evar _check_fall_damage (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: nil) tint
                                                       cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 132193) tint) :: nil))
                          (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint)
                                         tint)
                            (Ssequence
                              (Sset _t'9
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _heldObj
                                  (tptr (Tstruct _Object noattr))))
                              (Sifthenelse (Ebinop Oeq
                                             (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               (tptr tvoid)) tint)
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 8914006) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))
                                (Scall None
                                  (Evar _set_mario_action (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
                                                            tuint cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 901) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))))
                            Sskip))))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 0) tint))
                      Sbreak))
                  (LScons (Some 2)
                    (Ssequence
                      (Scall None
                        (Evar _mario_bonk_reflection (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 1) tint) :: nil))
                      (Ssequence
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _faceAngle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Ssequence
                            (Sset _t'8
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _vel
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
                                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
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
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                              Sskip))
                          (Ssequence
                            (Ssequence
                              (Sset _t'7
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
                                (Ebinop Oor (Etempvar _t'7 tuint)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint)))
                            (Ssequence
                              (Scall None
                                (Evar _drop_and_set_mario_action (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    tuint ::
                                                                    nil) tint
                                                                   cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 16910512) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sbreak)))))
                    (LScons (Some 6)
                      (Ssequence
                        (Scall None
                          (Evar _lava_boost_on_wall (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        Sbreak)
                      LSnil))))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_air_throw := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tushort) ::
               (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sset _t'1
          (Ecast
            (Ebinop Oadd (Etempvar _t'4 tushort)
              (Econst_int (Int.repr 1) tint) tint) tushort)))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Etempvar _t'1 tushort)))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tushort)
                   (Econst_int (Int.repr 4) tint) tint)
      (Scall None
        (Evar _mario_throw_held_object (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 7) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 82) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_air_without_turn (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'2 tint)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint :: nil)
                                                              tint
                                                              cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 132192) tint) :: nil))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint)
                        (Econst_int (Int.repr (-2147481034)) tuint))
                      Sskip))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_water_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'12, tfloat) :: (_t'11, tuchar) ::
               (_t'10, (tptr (Tstruct _Camera noattr))) ::
               (_t'9, (tptr (Tstruct _Area noattr))) ::
               (_t'8, (tptr (Tstruct _Camera noattr))) ::
               (_t'7, (tptr (Tstruct _Area noattr))) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _Camera noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, (tptr (Tstruct _Camera noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat)
                   tint)
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat) ::
         nil))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 50) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
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
          (Scall (Some _t'1)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sswitch (Etempvar _t'1 tint)
            (LScons (Some 1)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 67110000) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _area
                        (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr))))
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _area
                            (tptr (Tstruct _Area noattr))))
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _camera
                              (tptr (Tstruct _Camera noattr))))
                          (Ssequence
                            (Sset _t'11
                              (Efield
                                (Ederef
                                  (Etempvar _t'10 (tptr (Tstruct _Camera noattr)))
                                  (Tstruct _Camera noattr)) _defMode tuchar))
                            (Scall None
                              (Evar _set_camera_mode (Tfunction
                                                       ((tptr (Tstruct _Camera noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _t'8 (tptr (Tstruct _Camera noattr))) ::
                               (Etempvar _t'11 tuchar) ::
                               (Econst_int (Int.repr 1) tint) :: nil)))))))
                  Sbreak))
              (LScons (Some 2)
                (Ssequence
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat) ::
                     nil))
                  Sbreak)
                (LScons (Some 3)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 51) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 134218571) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'2
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _area
                              (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'3
                              (Efield
                                (Ederef
                                  (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _camera
                                (tptr (Tstruct _Camera noattr))))
                            (Ssequence
                              (Sset _t'4
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _area
                                  (tptr (Tstruct _Area noattr))))
                              (Ssequence
                                (Sset _t'5
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                                      (Tstruct _Area noattr)) _camera
                                    (tptr (Tstruct _Camera noattr))))
                                (Ssequence
                                  (Sset _t'6
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'5 (tptr (Tstruct _Camera noattr)))
                                        (Tstruct _Camera noattr)) _defMode
                                      tuchar))
                                  (Scall None
                                    (Evar _set_camera_mode (Tfunction
                                                             ((tptr (Tstruct _Camera noattr)) ::
                                                              tshort ::
                                                              tshort :: nil)
                                                             tvoid
                                                             cc_default))
                                    ((Etempvar _t'3 (tptr (Tstruct _Camera noattr))) ::
                                     (Etempvar _t'6 tuchar) ::
                                     (Econst_int (Int.repr 1) tint) :: nil)))))))
                        Sbreak)))
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil))))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_hold_water_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'10, tint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tfloat) ::
               (_t'7, tuchar) :: (_t'6, (tptr (Tstruct _Camera noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, (tptr (Tstruct _Camera noattr))) ::
               (_t'3, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
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
                (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'10 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'8 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat)
                     tint)
        (Scall None
          (Evar _mario_set_forward_vel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat) ::
           nil))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 50) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
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
            (Scall (Some _t'2)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'2 tint)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1140) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'3
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _area
                          (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Ederef
                              (Etempvar _t'3 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Ssequence
                          (Sset _t'5
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _area
                              (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'6
                              (Efield
                                (Ederef
                                  (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _camera
                                (tptr (Tstruct _Camera noattr))))
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _t'6 (tptr (Tstruct _Camera noattr)))
                                    (Tstruct _Camera noattr)) _defMode
                                  tuchar))
                              (Scall None
                                (Evar _set_camera_mode (Tfunction
                                                         ((tptr (Tstruct _Camera noattr)) ::
                                                          tshort :: tshort ::
                                                          nil) tvoid
                                                         cc_default))
                                ((Etempvar _t'4 (tptr (Tstruct _Camera noattr))) ::
                                 (Etempvar _t'7 tuchar) ::
                                 (Econst_int (Int.repr 1) tint) :: nil)))))))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_steep_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'10, tushort) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tint) ::
               (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 25692298) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Scall None
          (Evar _mario_set_forward_vel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Omul
             (Econst_single (Float32.of_bits (Int.repr 1065017672)) tfloat)
             (Etempvar _t'9 tfloat) tfloat) :: nil)))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'2 tint)
            (LScons (Some 1)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint :: nil)
                                                            tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 132192) tint) :: nil))
                  (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint) tint)
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'8 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                         tint)
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 80) tint) tint))
                            (Sset _t'3
                              (Ecast (Econst_int (Int.repr 67110000) tint)
                                tint))))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _t'3 tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))
                    Sskip))
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                     nil))
                  Sbreak)
                (LScons (Some 6)
                  (Ssequence
                    (Scall None
                      (Evar _lava_boost_on_wall (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  LSnil)))))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 77) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _angle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort) (Etempvar _t'7 tint)))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_ground_pound := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_stepResult, tuint) :: (_yOffset, tfloat) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'26, tushort) :: (_t'25, tfloat) :: (_t'24, tfloat) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tushort) :: (_t'19, tuint) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tshort) ::
               (_t'13, (tptr (Tstruct _Animation noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tushort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tfloat) :: (_t'6, tuint) ::
               (_t'5, tushort) :: nil);
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
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
               (Econst_int (Int.repr 28) tint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 53) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 65536) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'20 tushort)
                           (Econst_int (Int.repr 10) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'26
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sset _yOffset
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 20) tint)
                        (Ebinop Omul (Econst_int (Int.repr 2) tint)
                          (Etempvar _t'26 tushort) tint) tint) tfloat)))
                (Ssequence
                  (Sset _t'21
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'22
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _ceilHeight tfloat))
                    (Sifthenelse (Ebinop Olt
                                   (Ebinop Oadd
                                     (Ebinop Oadd (Etempvar _t'21 tfloat)
                                       (Etempvar _yOffset tfloat) tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                     tfloat) (Etempvar _t'22 tfloat) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'25
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _pos
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat)
                            (Ebinop Oadd (Etempvar _t'25 tfloat)
                              (Etempvar _yOffset tfloat) tfloat)))
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
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _peakHeight
                                tfloat) (Etempvar _t'24 tfloat)))
                          (Ssequence
                            (Sset _t'23
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
                                       (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr)) _pos
                                 (tarray tfloat 3)) ::
                               (Efield
                                 (Ederef
                                   (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                   (Tstruct _MarioState noattr)) _pos
                                 (tarray tfloat 3)) :: nil)))))
                      Sskip))))
              Sskip))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                tfloat))
            (Ssequence
              (Scall None
                (Evar _mario_set_forward_vel (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tfloat :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'19
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'19 tuint)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Sset _t'1
                        (Ecast (Econst_int (Int.repr 60) tint) tint))
                      (Sset _t'1
                        (Ecast (Econst_int (Int.repr 59) tint) tint))))
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'1 tint) :: nil)))
                (Ssequence
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tushort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'18
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
                                     (Ecast (Econst_int (Int.repr 55) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
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
                                   (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'16
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
                        (Ebinop Oadd (Etempvar _t'16 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort))
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'13
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _curAnim (tptr (Tstruct _Animation noattr))))
                          (Ssequence
                            (Sset _t'14
                              (Efield
                                (Ederef
                                  (Etempvar _t'13 (tptr (Tstruct _Animation noattr)))
                                  (Tstruct _Animation noattr)) _loopEnd
                                tshort))
                            (Sifthenelse (Ebinop Oge (Etempvar _t'11 tushort)
                                           (Ebinop Oadd
                                             (Etempvar _t'14 tshort)
                                             (Econst_int (Int.repr 4) tint)
                                             tint) tint)
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
                                                 (Econst_int (Int.repr 2) tint)
                                                 tuint)
                                               (Econst_int (Int.repr 28) tint)
                                               tuint)
                                             (Ebinop Oshl
                                               (Ecast
                                                 (Econst_int (Int.repr 34) tint)
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
                                       (Econst_int (Int.repr 1) tint) tuint) ::
                                     (Efield
                                       (Efield
                                         (Efield
                                           (Ederef
                                             (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                                             (Tstruct _Object noattr))
                                           _header
                                           (Tstruct _ObjectNode noattr)) _gfx
                                         (Tstruct _GraphNodeObject noattr))
                                       _cameraToObject (tarray tfloat 3)) ::
                                     nil)))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _actionState tushort)
                                  (Econst_int (Int.repr 1) tint)))
                              Sskip)))))))))))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 61) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _perform_air_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sset _stepResult (Etempvar _t'2 tint)))
            (Sifthenelse (Ebinop Oeq (Etempvar _stepResult tuint)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _should_get_stuck_in_ground (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'4 tint)
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
                                              (tint :: (tptr tfloat) :: nil)
                                              tvoid cc_default))
                          ((Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 2) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 11) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 208) tint)
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
                      (Ssequence
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
                                (Econst_int (Int.repr 16) tint) tint) tuint)))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 131899) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))
                    (Ssequence
                      (Scall None
                        (Evar _play_mario_heavy_landing_sound (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 nil) tvoid
                                                                cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 28) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 96) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 128) tint)
                                   tuint) (Econst_int (Int.repr 8) tint)
                                 tuint) tuint)
                             (Ebinop Oor
                               (Econst_int (Int.repr 67108864) tint)
                               (Econst_int (Int.repr 128) tint) tint) tuint)
                           (Econst_int (Int.repr 1) tint) tuint) :: nil))
                      (Ssequence
                        (Scall (Some _t'3)
                          (Evar _check_fall_damage (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: nil) tint
                                                     cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 132192) tint) :: nil))
                        (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint)
                                       tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'8
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
                                (Ebinop Oor (Etempvar _t'8 tuint)
                                  (Ebinop Oor
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 16) tint) tint)
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 4) tint) tint)
                                    tint) tuint)))
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 8389180) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))
                          Sskip)))))
                (Scall None
                  (Evar _set_camera_shake_from_hit (Tfunction (tshort :: nil)
                                                     tvoid cc_default))
                  ((Econst_int (Int.repr 2) tint) :: nil)))
              (Sifthenelse (Ebinop Oeq (Etempvar _stepResult tuint)
                             (Econst_int (Int.repr 2) tint) tint)
                (Ssequence
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Eunop Oneg
                       (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                       tfloat) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Ogt (Etempvar _t'7 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                     tint)
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
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                        Sskip))
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
                              (Econst_int (Int.repr 1) tint) tint) tuint)))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 16910512) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil)))))
                Sskip))))))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_burning_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'13, tuint) :: (_t'12, tfloat) :: (_t'11, tuint) ::
               (_t'10, tuint) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tint) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tshort) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tuint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _t'1 (Ecast (Econst_int (Int.repr 0) tint) tint))
        (Sset _t'1
          (Ecast (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint))))
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: (Etempvar _t'1 tint) ::
       nil)))
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'12 tfloat) :: nil)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _perform_air_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tint)
                       (Econst_int (Int.repr 1) tint) tint)
          (Ssequence
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
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 132169) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tuint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sset _t'3 (Ecast (Econst_int (Int.repr 77) tint) tint))
              (Sset _t'3 (Ecast (Econst_int (Int.repr 41) tint) tint))))
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'3 tint) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'10 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 11) tint) tint) tuint)))
          (Ssequence
            (Ssequence
              (Sset _t'9
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
                           (Ecast (Econst_int (Int.repr 1) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 16) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Econst_int (Int.repr 67108864) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
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
                          (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _rawData
                              (Tunion __665 noattr)) _asS32 (tarray tint 80))
                          (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                      (Ebinop Oadd (Etempvar _t'8 tint)
                        (Econst_int (Int.repr 3) tint) tint)))))
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort)
                    (Ebinop Osub (Etempvar _t'5 tshort)
                      (Econst_int (Int.repr 10) tint) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _health tshort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'4 tshort)
                                   (Econst_int (Int.repr 256) tint) tint)
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _health tshort)
                        (Econst_int (Int.repr 255) tint))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_burning_fall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'8, tfloat) :: (_t'7, tuint) ::
               (_t'6, tint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Scall None
      (Evar _mario_set_forward_vel (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tfloat :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _t'8 tfloat) :: nil)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _perform_air_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
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
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 132169) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 86) tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint)
            (Ebinop Oor (Etempvar _t'7 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 11) tint) tint) tuint)))
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
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                  (Ebinop Oadd (Etempvar _t'6 tint)
                    (Econst_int (Int.repr 3) tint) tint)))))
          (Ssequence
            (Ssequence
              (Sset _t'3
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _health tshort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _health tshort)
                (Ebinop Osub (Etempvar _t'3 tshort)
                  (Econst_int (Int.repr 10) tint) tint)))
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'2 tshort)
                               (Econst_int (Int.repr 256) tint) tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort)
                    (Econst_int (Int.repr 255) tint))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_crazy_box_bounce := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_minSpeed, tfloat) :: (_t'3, tshort) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'14, tuint) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tfloat) ::
               (_t'11, tushort) :: (_t'10, tuint) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, tuint) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sswitch (Etempvar _t'14 tuint)
            (LScons (Some 0)
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
                  (Econst_single (Float32.of_bits (Int.repr 1110704128)) tfloat))
                (Ssequence
                  (Sset _minSpeed
                    (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))
                  Sbreak))
              (LScons (Some 1)
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
                    (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat))
                  (Ssequence
                    (Sset _minSpeed
                      (Econst_single (Float32.of_bits (Int.repr 1108344832)) tfloat))
                    Sbreak))
                (LScons (Some 2)
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
                      (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat))
                    (Ssequence
                      (Sset _minSpeed
                        (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
                      Sbreak))
                  LSnil)))))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _minSpeed tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1109393408)) tfloat)
                           tint)
              (Sset _t'1
                (Ecast
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oshl
                            (Ecast (Econst_int (Int.repr 3) tint) tuint)
                            (Econst_int (Int.repr 28) tint) tuint)
                          (Ebinop Oshl
                            (Ecast (Econst_int (Int.repr 108) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 64) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint)
                      (Econst_int (Int.repr 128) tint) tuint)
                    (Econst_int (Int.repr 1) tint) tuint) tuint))
              (Sset _t'1
                (Ecast
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oshl
                            (Ecast (Econst_int (Int.repr 3) tint) tuint)
                            (Econst_int (Int.repr 28) tint) tuint)
                          (Ebinop Oshl
                            (Ecast (Econst_int (Int.repr 109) tint) tuint)
                            (Econst_int (Int.repr 16) tint) tuint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 64) tint) tuint)
                          (Econst_int (Int.repr 8) tint) tuint) tuint)
                      (Econst_int (Int.repr 128) tint) tuint)
                    (Econst_int (Int.repr 1) tint) tuint) tuint)))
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Etempvar _t'1 tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil))))
          (Ssequence
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                             (Etempvar _minSpeed tfloat) tint)
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _minSpeed tfloat) :: nil))
                Sskip))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Econst_int (Int.repr 1) tint)))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 136) tint) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_air_without_turn (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'2 tint)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'8 tuint)
                                   (Econst_int (Int.repr 2) tint) tint)
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 2222) tint) ::
                           (Ebinop Oadd (Etempvar _t'10 tuint)
                             (Econst_int (Int.repr 1) tint) tuint) :: nil)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'9
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
                                      (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
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
                            (Ecast (Econst_int (Int.repr 0) tint)
                              (tptr tvoid)))
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 9176147) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
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
                        (Ebinop Oor (Etempvar _t'7 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 16) tint) tint) tuint)))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_bonk_reflection (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil)))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Scall (Some _t'3)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Etempvar _t'5 tfloat) ::
                     (Eunop Oneg (Etempvar _t'6 tfloat) tfloat) :: nil))))
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
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
                          (Tstruct _GraphNodeObject noattr)) _angle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort) (Etempvar _t'3 tshort))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_common_air_knockback_step := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_landAction, tuint) :: (_hardFallAction, tuint) ::
                (_animation, tint) :: (_speed, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_stepResult, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuchar) :: (_t'5, tuint) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_set_forward_vel (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tfloat :: nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _speed tfloat) :: nil))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _perform_air_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Sset _stepResult (Etempvar _t'1 tint)))
    (Ssequence
      (Sswitch (Etempvar _stepResult tuint)
        (LScons (Some 0)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _animation tint) :: nil))
            Sbreak)
          (LScons (Some 1)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: nil) tint
                                                          cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _hardFallAction tuint) :: nil))
                (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuint)
                                     (Econst_int (Int.repr 16910525) tint)
                                     tint)
                        (Sset _t'2 (Econst_int (Int.repr 1) tint))
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _action tuint))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Oeq (Etempvar _t'8 tuint)
                                (Econst_int (Int.repr 16910526) tint) tint)
                              tbool)))))
                    (Sifthenelse (Etempvar _t'2 tint)
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _hurtCounter
                            tuchar))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _landAction tuint) ::
                           (Etempvar _t'6 tuchar) :: nil)))
                      (Ssequence
                        (Sset _t'5
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint))
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _landAction tuint) ::
                           (Etempvar _t'5 tuint) :: nil)))))
                  Sskip))
              Sbreak)
            (LScons (Some 2)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 2) tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _mario_bonk_reflection (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Ogt (Etempvar _t'4 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                     tint)
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
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                        Sskip))
                    (Ssequence
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Eunop Oneg (Etempvar _speed tfloat) tfloat) :: nil))
                      Sbreak))))
              (LScons (Some 6)
                (Ssequence
                  (Scall None
                    (Evar _lava_boost_on_wall (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                LSnil)))))
      (Sreturn (Some (Etempvar _stepResult tuint))))))
|}.

Definition f_check_wall_kick := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'7, tuchar) :: (_t'6, tushort) :: (_t'5, tuint) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _wallKickTimer tuchar))
            (Sset _t'2
              (Ecast
                (Ebinop One (Etempvar _t'7 tuchar)
                  (Econst_int (Int.repr 0) tint) tint) tbool)))
          (Sset _t'2 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'2 tint)
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _prevAction tuint))
          (Sset _t'3
            (Ecast
              (Ebinop Oeq (Etempvar _t'5 tuint)
                (Econst_int (Int.repr 2215) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
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
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _faceAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                (tptr tshort)) tshort)
            (Ebinop Oadd (Etempvar _t'4 tshort)
              (Econst_int (Int.repr 32768) tint) tint)))
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 50333830) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint)))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_backward_air_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_wall_kick (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) :: nil)
                               tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_knockback_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _common_air_knockback_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: tuint :: tint ::
                                            tfloat :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 132194) tint) ::
         (Econst_int (Int.repr 132192) tint) ::
         (Econst_int (Int.repr 2) tint) ::
         (Eunop Oneg
           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
           tfloat) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_forward_air_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_wall_kick (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) :: nil)
                               tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_knockback_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Scall None
        (Evar _common_air_knockback_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: tuint :: tint ::
                                            tfloat :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 132195) tint) ::
         (Econst_int (Int.repr 132193) tint) ::
         (Econst_int (Int.repr 45) tint) ::
         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
         nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_hard_backward_air_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_knockback_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _common_air_knockback_step (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tuint :: tuint :: tint :: tfloat ::
                                          nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 132192) tint) ::
       (Econst_int (Int.repr 132192) tint) ::
       (Econst_int (Int.repr 2) tint) ::
       (Eunop Oneg
         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
         tfloat) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_hard_forward_air_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_knockback_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _common_air_knockback_step (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tuint :: tuint :: tint :: tfloat ::
                                          nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 132193) tint) ::
       (Econst_int (Int.repr 132193) tint) ::
       (Econst_int (Int.repr 45) tint) ::
       (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_thrown_backward := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_landAction, tuint) :: (_t'3, tuint) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop One (Etempvar _t'3 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _landAction (Econst_int (Int.repr 132192) tint))
      (Sset _landAction (Econst_int (Int.repr 132194) tint))))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 16) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Scall None
          (Evar _common_air_knockback_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: tint ::
                                              tfloat :: nil) tuint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _landAction tuint) ::
           (Econst_int (Int.repr 132192) tint) ::
           (Econst_int (Int.repr 2) tint) :: (Etempvar _t'2 tfloat) :: nil)))
      (Ssequence
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Ebinop Omul (Etempvar _t'1 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1065017672)) tfloat)
              tfloat)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_thrown_forward := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_pitch, tshort) :: (_landAction, tuint) :: (_t'2, tuint) ::
               (_t'1, tshort) :: (_t'8, tuint) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tfloat) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionArg tuint))
    (Sifthenelse (Ebinop One (Etempvar _t'8 tuint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Sset _landAction (Econst_int (Int.repr 132193) tint))
      (Sset _landAction (Econst_int (Int.repr 132195) tint))))
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
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 16) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 192) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 131072) tint) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Scall (Some _t'2)
            (Evar _common_air_knockback_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: tint ::
                                                tfloat :: nil) tuint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _landAction tuint) ::
             (Econst_int (Int.repr 132193) tint) ::
             (Econst_int (Int.repr 45) tint) :: (Etempvar _t'7 tfloat) ::
             nil)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Scall (Some _t'1)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Etempvar _t'5 tfloat) ::
                     (Eunop Oneg (Etempvar _t'6 tfloat) tfloat) :: nil))))
              (Sset _pitch (Ecast (Etempvar _t'1 tshort) tshort)))
            (Ssequence
              (Sifthenelse (Ebinop Ogt (Etempvar _pitch tshort)
                             (Econst_int (Int.repr 6144) tint) tint)
                (Sset _pitch
                  (Ecast (Econst_int (Int.repr 6144) tint) tshort))
                Sskip)
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
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
                          (Tstruct _GraphNodeObject noattr)) _angle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort)
                  (Ebinop Oadd (Etempvar _pitch tshort)
                    (Econst_int (Int.repr 6144) tint) tint)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Ebinop Omul (Etempvar _t'3 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1065017672)) tfloat)
              tfloat)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_soft_bonk := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_wall_kick (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) :: nil)
                               tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_knockback_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Scall None
          (Evar _common_air_knockback_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: tint ::
                                              tfloat :: nil) tuint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67110001) tint) ::
           (Econst_int (Int.repr 132192) tint) ::
           (Econst_int (Int.repr 86) tint) :: (Etempvar _t'2 tfloat) :: nil)))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_getting_blown := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tushort) :: (_t'1, tint) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tfloat)
                       (Eunop Oneg
                         (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat)
                         tfloat) tint)
          (Ssequence
            (Sset _t'15
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Ebinop Osub (Etempvar _t'15 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1086324736)) tfloat)
                tfloat)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort)
            (Econst_int (Int.repr 1) tint))))
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'12 tfloat)
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                           tfloat) tint)
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Ebinop Oadd (Etempvar _t'13 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                  tfloat)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'10
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'10 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _gettingBlownGravity
                    tfloat))
                (Sset _t'1
                  (Ecast
                    (Ebinop Olt (Etempvar _t'11 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                      tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _gettingBlownGravity
                  tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _gettingBlownGravity
                  tfloat)
                (Ebinop Oadd (Etempvar _t'9 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1028443341)) tfloat)
                  tfloat)))
            Sskip)))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _t'2
            (Ecast
              (Ebinop Oadd (Etempvar _t'7 tushort)
                (Econst_int (Int.repr 1) tint) tint) tushort)))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Etempvar _t'2 tushort)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tushort)
                     (Econst_int (Int.repr 20) tint) tint)
        (Scall None
          (Evar _mario_blow_off_cap (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) ::
           nil))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Scall None
          (Evar _mario_set_forward_vel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _t'6 tfloat) :: nil)))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 2) tint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'3 tint)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 16910515) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 45) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _mario_bonk_reflection (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
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
                              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Sset _t'4
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat))
                            (Scall None
                              (Evar _mario_set_forward_vel (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tfloat :: nil)
                                                             tvoid
                                                             cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Eunop Oneg (Etempvar _t'4 tfloat) tfloat) ::
                               nil)))
                          Sbreak))))
                  LSnil))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_air_hit_wall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tshort) :: (_t'4, tushort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tushort) :: (_t'12, tshort) :: (_t'11, tushort) ::
               (_t'10, tfloat) :: (_t'9, tuint) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'14
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _heldObj
        (tptr (Tstruct _Object noattr))))
    (Sifthenelse (Ebinop One (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                   (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) tint)
      (Scall None
        (Evar _mario_drop_held_object (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _t'4
            (Ecast
              (Ebinop Oadd (Etempvar _t'13 tushort)
                (Econst_int (Int.repr 1) tint) tint) tushort)))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Etempvar _t'4 tushort)))
      (Sifthenelse (Ebinop Ole (Etempvar _t'4 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1112539136)) tfloat))
              (Ssequence
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
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort)
                    (Ebinop Oadd (Etempvar _t'12 tshort)
                      (Econst_int (Int.repr 32768) tint) tint)))
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 50333830) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'1 tuint))))))
            Sskip))
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Oge (Etempvar _t'6 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1108869120)) tfloat)
                         tint)
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _wallKickTimer tuchar)
                (Econst_int (Int.repr 5) tint))
              (Ssequence
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'10 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
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
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'9 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)))
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16910512) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'2 tuint)))))))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _wallKickTimer tuchar)
                (Econst_int (Int.repr 5) tint))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
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
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'7 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                   tint)
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                           tfloat) :: nil))
                      Sskip))
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16910518) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'3 tuint)))))))))))
    (Ssequence
      (Scall (Some _t'5)
        (Evar _set_mario_animation (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tint :: nil) tshort cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 204) tint) :: nil))
      (Sreturn (Some (Etempvar _t'5 tshort))))))
|}.

Definition f_act_forward_rollout := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tshort) ::
               (_t'1, tint) :: (_t'8, tushort) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort)
          (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_air_without_turn (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'1 tint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Scall (Some _t'2)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 111) tint) :: nil))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tshort)
                                     (Econst_int (Int.repr 4) tint) tint)
                        (Ssequence
                          (Sset _t'7
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
                                       (Ecast (Econst_int (Int.repr 55) tint)
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
                                     (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sskip))
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 86) tint) :: nil))))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 201327154) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
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
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) :: nil))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil))))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                             (Econst_int (Int.repr 1) tint) tint)
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _is_anim_past_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _t'3 (Ecast (Etempvar _t'4 tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 2) tint))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_backward_rollout := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tshort) :: (_t'1, tint) ::
               (_t'9, tushort) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tushort) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort)
          (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Scall None
        (Evar _update_air_without_turn (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'1 tint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Scall (Some _t'2)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 112) tint) :: nil))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tshort)
                                     (Econst_int (Int.repr 4) tint) tint)
                        (Ssequence
                          (Sset _t'8
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
                                       (Ecast (Econst_int (Int.repr 55) tint)
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
                                     (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sskip))
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 86) tint) :: nil))))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 201327154) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
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
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) :: nil))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil))
                    Sbreak)
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil))))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                             (Econst_int (Int.repr 1) tint) tint)
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
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animFrame tshort))
                    (Sset _t'3
                      (Ecast
                        (Ebinop Oeq (Etempvar _t'6 tshort)
                          (Econst_int (Int.repr 2) tint) tint) tbool))))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 2) tint))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_butt_slide_air := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tushort) :: (_t'1, tuint) ::
               (_t'16, tushort) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tushort) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _t'2
            (Ecast
              (Ebinop Oadd (Etempvar _t'16 tushort)
                (Econst_int (Int.repr 1) tint) tint) tushort)))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Etempvar _t'2 tushort)))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tushort)
                     (Econst_int (Int.repr 30) tint) tint)
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
                  (Tstruct _MarioState noattr)) _floorHeight tfloat))
            (Sset _t'3
              (Ecast
                (Ebinop Ogt
                  (Ebinop Osub (Etempvar _t'14 tfloat)
                    (Etempvar _t'15 tfloat) tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                  tint) tbool))))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 16779404) tint) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _update_air_with_turn (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
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
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'13
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Sset _t'5
                          (Ecast
                            (Ebinop Olt (Etempvar _t'13 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                              tint) tbool)))
                      (Sset _t'5 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'5 tint)
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'10 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __670 noattr)) _y tfloat))
                        (Sset _t'6
                          (Ecast
                            (Ebinop Oge (Etempvar _t'11 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1065098332)) tfloat)
                              tint) tbool))))
                    (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'6 tint)
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
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
                        (Ebinop Odiv
                          (Eunop Oneg (Etempvar _t'9 tfloat) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                          tfloat)))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Econst_int (Int.repr 1) tint)))
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 8651858) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))))
              (Ssequence
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
                Sbreak))
            (LScons (Some 2)
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
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
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'7 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 1) tint) tint) tuint)))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16910512) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)))
              (LScons (Some 6)
                (Ssequence
                  (Scall None
                    (Evar _lava_boost_on_wall (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  Sbreak)
                LSnil)))))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 145) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_hold_butt_slide_air := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tushort) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'19, tint) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, tushort) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tushort) :: (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'19
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'19 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779425) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oadd (Etempvar _t'17 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'3 tushort)))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 30) tint) tint)
          (Ssequence
            (Sset _t'15
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'16
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floorHeight tfloat))
              (Sset _t'4
                (Ecast
                  (Ebinop Ogt
                    (Ebinop Osub (Etempvar _t'15 tfloat)
                      (Etempvar _t'16 tfloat) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                    tint) tbool))))
          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779425) tint) ::
             (Econst_int (Int.repr 1) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _update_air_with_turn (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
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
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sset _t'14
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sset _t'6
                            (Ecast
                              (Ebinop Olt (Etempvar _t'14 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                tint) tbool)))
                        (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'6 tint)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floor
                            (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'12
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _normal
                                (Tstruct __670 noattr)) _y tfloat))
                          (Sset _t'7
                            (Ecast
                              (Ebinop Oge (Etempvar _t'12 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1065098332)) tfloat)
                                tint) tbool))))
                      (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'7 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
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
                          (Ebinop Odiv
                            (Eunop Oneg (Etempvar _t'10 tfloat) tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                            tfloat)))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort) (Econst_int (Int.repr 1) tint)))
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 8651860) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))))
                (Ssequence
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
                  Sbreak))
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                   tint)
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
                        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                      Sskip))
                  (Ssequence
                    (Scall None
                      (Evar _mario_drop_held_object (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
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
                          (Ebinop Oor (Etempvar _t'8 tuint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)))
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 16910512) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak))))
                (LScons (Some 6)
                  (Ssequence
                    (Scall None
                      (Evar _lava_boost_on_wall (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  LSnil)))))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 69) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_lava_boost := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tfloat) ::
               (_t'28, tfloat) :: (_t'27, tushort) :: (_t'26, tuint) ::
               (_t'25, tuchar) :: (_t'24, tuint) ::
               (_t'23, (tptr (Tstruct _Object noattr))) :: (_t'22, tfloat) ::
               (_t'21, tushort) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tushort) :: (_t'17, tshort) ::
               (_t'16, (tptr (Tstruct _Surface noattr))) :: (_t'15, tuint) ::
               (_t'14, tushort) :: (_t'13, (tptr (Tstruct _Area noattr))) ::
               (_t'12, tfloat) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tushort) ::
               (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
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
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 20) tint) tuint)
               (Econst_int (Int.repr 16) tint) tuint) tuint)
           (Ebinop Oshl (Ecast (Econst_int (Int.repr 160) tint) tuint)
             (Econst_int (Int.repr 8) tint) tuint) tuint)
         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
           (Econst_int (Int.repr 128) tint) tint) tuint)
       (Econst_int (Int.repr 1) tint) tuint) ::
     (Econst_int (Int.repr 131072) tint) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'27
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'27 tushort)
                       (Econst_int (Int.repr 1) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'28
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'1)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'28 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1051931443)) tfloat) ::
               nil)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'1 tfloat)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _update_lava_boost_or_twirling (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'2)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'2 tint)
            (LScons (Some 1)
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floor
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _t'16 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _type tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'17 tshort)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 0) tint))
                        (Ssequence
                          (Ssequence
                            (Sset _t'24
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sifthenelse (Eunop Onotbool
                                           (Ebinop Oand
                                             (Etempvar _t'24 tuint)
                                             (Econst_int (Int.repr 4) tint)
                                             tuint) tint)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'26
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _flags
                                      tuint))
                                  (Sifthenelse (Ebinop Oand
                                                 (Etempvar _t'26 tuint)
                                                 (Econst_int (Int.repr 16) tint)
                                                 tuint)
                                    (Sset _t'3
                                      (Ecast (Econst_int (Int.repr 12) tint)
                                        tint))
                                    (Sset _t'3
                                      (Ecast (Econst_int (Int.repr 18) tint)
                                        tint))))
                                (Ssequence
                                  (Sset _t'25
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
                                    (Ebinop Oadd (Etempvar _t'25 tuchar)
                                      (Etempvar _t'3 tint) tint))))
                              Sskip))
                          (Ssequence
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
                              (Econst_single (Float32.of_bits (Int.repr 1118306304)) tfloat))
                            (Ssequence
                              (Sset _t'23
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
                                             (Econst_int (Int.repr 20) tint)
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
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil))))))
                      (Ssequence
                        (Scall None
                          (Evar _play_mario_heavy_landing_sound (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tuint ::
                                                                   nil) tvoid
                                                                  cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 0) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 24) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 128) tint)
                                     tuint) (Econst_int (Int.repr 8) tint)
                                   tuint) tuint)
                               (Ebinop Oor
                                 (Econst_int (Int.repr 67108864) tint)
                                 (Econst_int (Int.repr 128) tint) tint)
                               tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'21
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'21 tushort)
                                           (Econst_int (Int.repr 2) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'22
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _vel
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Sset _t'4
                                  (Ecast
                                    (Ebinop Olt (Etempvar _t'22 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                      tint) tbool)))
                              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                          (Sifthenelse (Etempvar _t'4 tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'20
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _vel
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
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
                                  (Ebinop Omul
                                    (Eunop Oneg (Etempvar _t'20 tfloat)
                                      tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                                    tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'19
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Scall None
                                    (Evar _mario_set_forward_vel (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tfloat ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Ebinop Omul (Etempvar _t'19 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                                       tfloat) :: nil)))
                                (Ssequence
                                  (Sset _t'18
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionState tushort)
                                    (Ebinop Oadd (Etempvar _t'18 tushort)
                                      (Econst_int (Int.repr 1) tint) tint)))))
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 134218297) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))))))))
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Scall None
                    (Evar _mario_bonk_reflection (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sbreak)
                (LScons (Some 6)
                  (Ssequence
                    (Scall None
                      (Evar _lava_boost_on_wall (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak)
                  LSnil)))))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 41) tint) :: nil))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'14
                      (Efield
                        (Ederef
                          (Etempvar _t'13 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _terrainType tushort))
                    (Sifthenelse (Ebinop One
                                   (Ebinop Oand (Etempvar _t'14 tushort)
                                     (Econst_int (Int.repr 7) tint) tint)
                                   (Econst_int (Int.repr 2) tint) tint)
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _flags tuint))
                        (Sset _t'5
                          (Ecast
                            (Eunop Onotbool
                              (Ebinop Oand (Etempvar _t'15 tuint)
                                (Econst_int (Int.repr 4) tint) tuint) tint)
                            tbool)))
                      (Sset _t'5 (Econst_int (Int.repr 0) tint)))))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Ssequence
                    (Sset _t'12
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _t'6
                      (Ecast
                        (Ebinop Ogt (Etempvar _t'12 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                          tint) tbool)))
                  (Sset _t'6 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'6 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'11 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 11) tint) tint) tuint)))
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Ssequence
                        (Sset _t'10
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
                                     (Ecast (Econst_int (Int.repr 1) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 16) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 8) tint)
                                   tuint) tuint)
                               (Econst_int (Int.repr 67108864) tint) tuint)
                             (Econst_int (Int.repr 1) tint) tuint) ::
                           (Efield
                             (Efield
                               (Efield
                                 (Ederef
                                   (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      Sskip)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'8 tshort)
                               (Econst_int (Int.repr 256) tint) tint)
                  (Scall None
                    (Evar _level_trigger_warp (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 18) tint) :: nil))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'7 (tptr (Tstruct _MarioBodyState noattr)))
                        (Tstruct _MarioBodyState noattr)) _eyeState tschar)
                    (Econst_int (Int.repr 8) tint)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_slide_kick := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tint) :: (_t'6, tshort) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tushort) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'24, tushort) :: (_t'23, tushort) ::
               (_t'22, tushort) :: (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, tushort) :: (_t'12, tfloat) :: (_t'11, tushort) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'23
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'23 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'24
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'24 tushort)
                (Econst_int (Int.repr 0) tint) tint) tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Scall None
          (Evar _play_mario_sound (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tint :: tint :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) ::
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                     (Econst_int (Int.repr 28) tint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 3) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                   (Econst_int (Int.repr 8) tint) tuint) tuint)
               (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                 (Econst_int (Int.repr 128) tint) tint) tuint)
             (Econst_int (Int.repr 1) tint) tuint) :: nil))
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 140) tint) :: nil)))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'22
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oadd (Etempvar _t'22 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'3 tushort)))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 30) tint) tint)
          (Ssequence
            (Sset _t'20
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floorHeight tfloat))
              (Sset _t'4
                (Ecast
                  (Ebinop Ogt
                    (Ebinop Osub (Etempvar _t'20 tfloat)
                      (Etempvar _t'21 tfloat) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1140457472)) tfloat)
                    tint) tbool))))
          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 2) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _update_air_without_turn (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'5 tint)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionState tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'13 tushort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'18
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat))
                          (Ssequence
                            (Sset _t'19
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _vel
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
                            (Scall (Some _t'6)
                              (Evar _atan2s (Tfunction
                                              (tfloat :: tfloat :: nil)
                                              tshort cc_default))
                              ((Etempvar _t'18 tfloat) ::
                               (Eunop Oneg (Etempvar _t'19 tfloat) tfloat) ::
                               nil))))
                        (Ssequence
                          (Sset _t'17
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort) (Etempvar _t'6 tshort))))
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'15
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'15 tshort)
                                         (Econst_int (Int.repr 6144) tint)
                                         tint)
                            (Ssequence
                              (Sset _t'16
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Efield
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr)) _header
                                          (Tstruct _ObjectNode noattr)) _gfx
                                        (Tstruct _GraphNodeObject noattr))
                                      _angle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort)
                                (Econst_int (Int.repr 6144) tint)))
                            Sskip))))
                    Sskip))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Ssequence
                          (Sset _t'12
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sset _t'7
                            (Ecast
                              (Ebinop Olt (Etempvar _t'12 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                tint) tbool)))
                        (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'7 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'10
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
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
                            (Ebinop Odiv
                              (Eunop Oneg (Etempvar _t'10 tfloat) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                              tfloat)))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort) (Econst_int (Int.repr 1) tint))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort) (Econst_int (Int.repr 0) tint))))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 8389722) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))))
                  (Ssequence
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
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) :: nil))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _vel
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                     tint)
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
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
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
                          (Ebinop Oor (Etempvar _t'8 tuint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 1) tint) tint) tuint)))
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 16910512) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak)))
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil))))))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_jump_kick := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tushort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                   (Econst_int (Int.repr 0) tint) tint)
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
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 31) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
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
            (Sassign
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animID tshort)
              (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 79) tint) :: nil))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort)
              (Econst_int (Int.repr 1) tint)))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Sset _animFrame
        (Efield
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _animFrame tshort)))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioBodyState
              (tptr (Tstruct _MarioBodyState noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'5 (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _punchState tuchar)
            (Ebinop Oor
              (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                (Econst_int (Int.repr 6) tint) tint)
              (Econst_int (Int.repr 6) tint) tint)))
        Sskip)
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oge (Etempvar _animFrame tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Sset _t'1
              (Ecast
                (Ebinop Olt (Etempvar _animFrame tint)
                  (Econst_int (Int.repr 8) tint) tint) tbool))
            (Sset _t'1 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint)
                (Ebinop Oor (Etempvar _t'4 tuint)
                  (Econst_int (Int.repr 2097152) tint) tuint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _update_air_without_turn (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _perform_air_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sswitch (Etempvar _t'2 tint)
                (LScons (Some 1)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'3)
                        (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 nil) tint
                                                                cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 132192) tint) :: nil))
                      (Sifthenelse (Eunop Onotbool (Etempvar _t'3 tint) tint)
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 67110001) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sskip))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                         nil))
                      Sbreak)
                    LSnil))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_shot_from_cannon := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tfloat) :: (_t'3, tint) :: (_t'2, tshort) ::
               (_t'1, tint) ::
               (_t'30, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'29, tuchar) :: (_t'28, (tptr (Tstruct _Camera noattr))) ::
               (_t'27, (tptr (Tstruct _Area noattr))) :: (_t'26, tfloat) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tshort) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tuchar) ::
               (_t'20, (tptr (Tstruct _Camera noattr))) ::
               (_t'19, (tptr (Tstruct _Area noattr))) ::
               (_t'18, (tptr (Tstruct _Camera noattr))) ::
               (_t'17, (tptr (Tstruct _Area noattr))) :: (_t'16, tfloat) ::
               (_t'15, tuint) :: (_t'14, tuchar) ::
               (_t'13, (tptr (Tstruct _Camera noattr))) ::
               (_t'12, (tptr (Tstruct _Area noattr))) ::
               (_t'11, (tptr (Tstruct _Camera noattr))) ::
               (_t'10, (tptr (Tstruct _Area noattr))) :: (_t'9, tfloat) ::
               (_t'8, tuint) :: (_t'7, tfloat) :: (_t'6, tuint) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'27
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'28
        (Efield
          (Ederef (Etempvar _t'27 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _camera (tptr (Tstruct _Camera noattr))))
      (Ssequence
        (Sset _t'29
          (Efield
            (Ederef (Etempvar _t'28 (tptr (Tstruct _Camera noattr)))
              (Tstruct _Camera noattr)) _mode tuchar))
        (Sifthenelse (Ebinop One (Etempvar _t'29 tuchar)
                       (Econst_int (Int.repr 3) tint) tint)
          (Ssequence
            (Sset _t'30
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _statusForCamera
                (tptr (Tstruct _PlayerCameraState noattr))))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _t'30 (tptr (Tstruct _PlayerCameraState noattr)))
                  (Tstruct _PlayerCameraState noattr)) _cameraEvent tshort)
              (Econst_int (Int.repr 2) tint)))
          Sskip))))
  (Ssequence
    (Ssequence
      (Sset _t'26
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'26 tfloat) :: nil)))
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 131072) tint) :: nil))
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _perform_air_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sswitch (Etempvar _t'1 tint)
            (LScons (Some 0)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 21) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'24
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Ssequence
                        (Sset _t'25
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _vel
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 1) tint) (tptr tfloat))
                            tfloat))
                        (Scall (Some _t'2)
                          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                          tshort cc_default))
                          ((Etempvar _t'24 tfloat) ::
                           (Etempvar _t'25 tfloat) :: nil))))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort) (Etempvar _t'2 tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'22
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _marioObj
                          (tptr (Tstruct _Object noattr))))
                      (Ssequence
                        (Sset _t'23
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
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _angle
                                (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort)
                          (Eunop Oneg (Etempvar _t'23 tshort) tint))))
                    Sbreak)))
              (LScons (Some 1)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 8914006) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tshort)) tshort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Ssequence
                        (Sset _t'17
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _area
                            (tptr (Tstruct _Area noattr))))
                        (Ssequence
                          (Sset _t'18
                            (Efield
                              (Ederef
                                (Etempvar _t'17 (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _camera
                              (tptr (Tstruct _Camera noattr))))
                          (Ssequence
                            (Sset _t'19
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _area
                                (tptr (Tstruct _Area noattr))))
                            (Ssequence
                              (Sset _t'20
                                (Efield
                                  (Ederef
                                    (Etempvar _t'19 (tptr (Tstruct _Area noattr)))
                                    (Tstruct _Area noattr)) _camera
                                  (tptr (Tstruct _Camera noattr))))
                              (Ssequence
                                (Sset _t'21
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'20 (tptr (Tstruct _Camera noattr)))
                                      (Tstruct _Camera noattr)) _defMode
                                    tuchar))
                                (Scall None
                                  (Evar _set_camera_mode (Tfunction
                                                           ((tptr (Tstruct _Camera noattr)) ::
                                                            tshort ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                                  ((Etempvar _t'18 (tptr (Tstruct _Camera noattr))) ::
                                   (Etempvar _t'21 tuchar) ::
                                   (Econst_int (Int.repr 1) tint) :: nil)))))))
                      Sbreak)))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Eunop Oneg
                         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                         tfloat) :: nil))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _faceAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 0) tint) (tptr tshort))
                          tshort) (Econst_int (Int.repr 0) tint))
                      (Ssequence
                        (Ssequence
                          (Sset _t'16
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _vel
                                  (tarray tfloat 3))
                                (Econst_int (Int.repr 1) tint) (tptr tfloat))
                              tfloat))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
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
                              (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Sset _t'15
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
                              (Ebinop Oor (Etempvar _t'15 tuint)
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 1) tint) tint) tuint)))
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 16910512) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            (Ssequence
                              (Ssequence
                                (Sset _t'10
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _area
                                    (tptr (Tstruct _Area noattr))))
                                (Ssequence
                                  (Sset _t'11
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
                                        (Tstruct _Area noattr)) _camera
                                      (tptr (Tstruct _Camera noattr))))
                                  (Ssequence
                                    (Sset _t'12
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _area
                                        (tptr (Tstruct _Area noattr))))
                                    (Ssequence
                                      (Sset _t'13
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'12 (tptr (Tstruct _Area noattr)))
                                            (Tstruct _Area noattr)) _camera
                                          (tptr (Tstruct _Camera noattr))))
                                      (Ssequence
                                        (Sset _t'14
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'13 (tptr (Tstruct _Camera noattr)))
                                              (Tstruct _Camera noattr))
                                            _defMode tuchar))
                                        (Scall None
                                          (Evar _set_camera_mode (Tfunction
                                                                   ((tptr (Tstruct _Camera noattr)) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                          ((Etempvar _t'11 (tptr (Tstruct _Camera noattr))) ::
                                           (Etempvar _t'14 tuchar) ::
                                           (Econst_int (Int.repr 1) tint) ::
                                           nil)))))))
                              Sbreak))))))
                  (LScons (Some 6)
                    (Ssequence
                      (Scall None
                        (Evar _lava_boost_on_wall (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      Sbreak)
                    LSnil))))))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sifthenelse (Ebinop Oand (Etempvar _t'8 tuint)
                             (Econst_int (Int.repr 8) tint) tuint)
                (Ssequence
                  (Sset _t'9
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _vel
                          (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tfloat)) tfloat))
                  (Sset _t'3
                    (Ecast
                      (Ebinop Olt (Etempvar _t'9 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                        tint) tbool)))
                (Sset _t'3 (Econst_int (Int.repr 0) tint))))
            (Sifthenelse (Etempvar _t'3 tint)
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 277350553) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Osub (Etempvar _t'7 tfloat)
                        (Econst_float (Float.of_bits (Int64.repr 4587366580439587226)) tdouble)
                        tdouble) tfloat)))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Etempvar _t'4 tfloat)))
              (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                             tint)
                (Scall None
                  (Evar _mario_set_forward_vel (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tfloat :: nil) tvoid
                                                 cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
                   nil))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _vel
                        (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tfloat)) tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                               tint)
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
                          (Econst_int (Int.repr 0) tint) tint) tuint)))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_flying := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_startPitch, tshort) :: (_t'9, tint) :: (_t'8, tint) ::
               (_t'7, tint) :: (_t'6, tushort) :: (_t'5, tuint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'75, tshort) :: (_t'74, tuchar) ::
               (_t'73, (tptr (Tstruct _Camera noattr))) ::
               (_t'72, (tptr (Tstruct _Area noattr))) ::
               (_t'71, (tptr (Tstruct _Camera noattr))) ::
               (_t'70, (tptr (Tstruct _Area noattr))) :: (_t'69, tuchar) ::
               (_t'68, (tptr (Tstruct _Camera noattr))) ::
               (_t'67, (tptr (Tstruct _Area noattr))) :: (_t'66, tushort) ::
               (_t'65, tuchar) :: (_t'64, (tptr (Tstruct _Camera noattr))) ::
               (_t'63, (tptr (Tstruct _Area noattr))) ::
               (_t'62, (tptr (Tstruct _Camera noattr))) ::
               (_t'61, (tptr (Tstruct _Area noattr))) :: (_t'60, tuchar) ::
               (_t'59, (tptr (Tstruct _Camera noattr))) ::
               (_t'58, (tptr (Tstruct _Area noattr))) :: (_t'57, tuint) ::
               (_t'56, (tptr (Tstruct _Camera noattr))) ::
               (_t'55, (tptr (Tstruct _Area noattr))) :: (_t'54, tuchar) ::
               (_t'53, (tptr (Tstruct _Camera noattr))) ::
               (_t'52, (tptr (Tstruct _Area noattr))) ::
               (_t'51, (tptr (Tstruct _Object noattr))) :: (_t'50, tshort) ::
               (_t'49, (tptr (Tstruct _Object noattr))) :: (_t'48, tuint) ::
               (_t'47, tuint) :: (_t'46, tushort) :: (_t'45, tshort) ::
               (_t'44, (tptr (Tstruct _Object noattr))) :: (_t'43, tshort) ::
               (_t'42, (tptr (Tstruct _Object noattr))) :: (_t'41, tuchar) ::
               (_t'40, (tptr (Tstruct _Camera noattr))) ::
               (_t'39, (tptr (Tstruct _Area noattr))) ::
               (_t'38, (tptr (Tstruct _Camera noattr))) ::
               (_t'37, (tptr (Tstruct _Area noattr))) :: (_t'36, tfloat) ::
               (_t'35, tuint) :: (_t'34, (tptr (Tstruct _Object noattr))) ::
               (_t'33, tuint) :: (_t'32, tuchar) ::
               (_t'31, (tptr (Tstruct _Camera noattr))) ::
               (_t'30, (tptr (Tstruct _Area noattr))) ::
               (_t'29, (tptr (Tstruct _Camera noattr))) ::
               (_t'28, (tptr (Tstruct _Area noattr))) ::
               (_t'27, (tptr (Tstruct _Object noattr))) ::
               (_t'26, tushort) :: (_t'25, tshort) :: (_t'24, tshort) ::
               (_t'23, tshort) :: (_t'22, (tptr (Tstruct _Object noattr))) ::
               (_t'21, tshort) :: (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tfloat) :: (_t'17, tshort) :: (_t'16, tuint) ::
               (_t'15, tshort) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'75
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
    (Sset _startPitch (Ecast (Etempvar _t'75 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'66
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'66 tushort)
                     (Econst_int (Int.repr 32768) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'67
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _area
                (tptr (Tstruct _Area noattr))))
            (Ssequence
              (Sset _t'68
                (Efield
                  (Ederef (Etempvar _t'67 (tptr (Tstruct _Area noattr)))
                    (Tstruct _Area noattr)) _camera
                  (tptr (Tstruct _Camera noattr))))
              (Ssequence
                (Sset _t'69
                  (Efield
                    (Ederef (Etempvar _t'68 (tptr (Tstruct _Camera noattr)))
                      (Tstruct _Camera noattr)) _mode tuchar))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'69 tuchar)
                               (Econst_int (Int.repr 3) tint) tint)
                  (Ssequence
                    (Sset _t'70
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _area
                        (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'71
                        (Efield
                          (Ederef
                            (Etempvar _t'70 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr))))
                      (Ssequence
                        (Sset _t'72
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _area
                            (tptr (Tstruct _Area noattr))))
                        (Ssequence
                          (Sset _t'73
                            (Efield
                              (Ederef
                                (Etempvar _t'72 (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _camera
                              (tptr (Tstruct _Camera noattr))))
                          (Ssequence
                            (Sset _t'74
                              (Efield
                                (Ederef
                                  (Etempvar _t'73 (tptr (Tstruct _Camera noattr)))
                                  (Tstruct _Camera noattr)) _defMode tuchar))
                            (Scall None
                              (Evar _set_camera_mode (Tfunction
                                                       ((tptr (Tstruct _Camera noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _t'71 (tptr (Tstruct _Camera noattr))) ::
                               (Etempvar _t'74 tuchar) ::
                               (Econst_int (Int.repr 1) tint) :: nil)))))))
                  Sskip))))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 8390825) tint) ::
               (Econst_int (Int.repr 1) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint)))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'57
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'57 tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'58
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _area
                  (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'59
                  (Efield
                    (Ederef (Etempvar _t'58 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _camera
                    (tptr (Tstruct _Camera noattr))))
                (Ssequence
                  (Sset _t'60
                    (Efield
                      (Ederef
                        (Etempvar _t'59 (tptr (Tstruct _Camera noattr)))
                        (Tstruct _Camera noattr)) _mode tuchar))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'60 tuchar)
                                 (Econst_int (Int.repr 3) tint) tint)
                    (Ssequence
                      (Sset _t'61
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _area
                          (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'62
                          (Efield
                            (Ederef
                              (Etempvar _t'61 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Ssequence
                          (Sset _t'63
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _area
                              (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'64
                              (Efield
                                (Ederef
                                  (Etempvar _t'63 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _camera
                                (tptr (Tstruct _Camera noattr))))
                            (Ssequence
                              (Sset _t'65
                                (Efield
                                  (Ederef
                                    (Etempvar _t'64 (tptr (Tstruct _Camera noattr)))
                                    (Tstruct _Camera noattr)) _defMode
                                  tuchar))
                              (Scall None
                                (Evar _set_camera_mode (Tfunction
                                                         ((tptr (Tstruct _Camera noattr)) ::
                                                          tshort :: tshort ::
                                                          nil) tvoid
                                                         cc_default))
                                ((Etempvar _t'62 (tptr (Tstruct _Camera noattr))) ::
                                 (Etempvar _t'65 tuchar) ::
                                 (Econst_int (Int.repr 1) tint) :: nil)))))))
                    Sskip))))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16779404) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'52
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _area
              (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'53
              (Efield
                (Ederef (Etempvar _t'52 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _camera
                (tptr (Tstruct _Camera noattr))))
            (Ssequence
              (Sset _t'54
                (Efield
                  (Ederef (Etempvar _t'53 (tptr (Tstruct _Camera noattr)))
                    (Tstruct _Camera noattr)) _mode tuchar))
              (Sifthenelse (Ebinop One (Etempvar _t'54 tuchar)
                             (Econst_int (Int.repr 3) tint) tint)
                (Ssequence
                  (Sset _t'55
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'56
                      (Efield
                        (Ederef
                          (Etempvar _t'55 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Scall None
                      (Evar _set_camera_mode (Tfunction
                                               ((tptr (Tstruct _Camera noattr)) ::
                                                tshort :: tshort :: nil)
                                               tvoid cc_default))
                      ((Etempvar _t'56 (tptr (Tstruct _Camera noattr))) ::
                       (Econst_int (Int.repr 3) tint) ::
                       (Econst_int (Int.repr 1) tint) :: nil))))
                Sskip))))
        (Ssequence
          (Ssequence
            (Sset _t'46
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'46 tushort)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'48
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionArg tuint))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'48 tuint)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 91) tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 207) tint) :: nil))
                      (Ssequence
                        (Sset _t'49
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'50
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'49 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _animFrame tshort))
                          (Sifthenelse (Ebinop Oeq (Etempvar _t'50 tshort)
                                         (Econst_int (Int.repr 1) tint) tint)
                            (Ssequence
                              (Sset _t'51
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
                                             (Econst_int (Int.repr 0) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 55) tint)
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
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'51 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            Sskip))))))
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _is_anim_at_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'3 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'47
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'47 tuint)
                                       (Econst_int (Int.repr 2) tint) tint)
                          (Ssequence
                            (Scall None
                              (Evar _load_level_init_text (Tfunction
                                                            (tuint :: nil)
                                                            tvoid cc_default))
                              ((Econst_int (Int.repr 0) tint) :: nil))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionArg
                                tuint) (Econst_int (Int.repr 1) tint)))
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 42) tint) :: nil))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint))))
                    Sskip)))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _update_flying (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _perform_air_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sswitch (Etempvar _t'4 tint)
                  (LScons (Some 0)
                    (Ssequence
                      (Ssequence
                        (Sset _t'44
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'45
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
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'44 (tptr (Tstruct _Object noattr)))
                                        (Tstruct _Object noattr)) _header
                                      (Tstruct _ObjectNode noattr)) _gfx
                                    (Tstruct _GraphNodeObject noattr)) _angle
                                  (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort)
                            (Eunop Oneg (Etempvar _t'45 tshort) tint))))
                      (Ssequence
                        (Ssequence
                          (Sset _t'42
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioObj
                              (tptr (Tstruct _Object noattr))))
                          (Ssequence
                            (Sset _t'43
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _faceAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'42 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _angle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'43 tshort))))
                        (Ssequence
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionTimer
                              tushort) (Econst_int (Int.repr 0) tint))
                          Sbreak)))
                    (LScons (Some 1)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 8914006) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 136) tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _set_anim_to_frame (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tshort :: nil)
                                                         tvoid cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 7) tint) :: nil))
                            (Ssequence
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
                              (Ssequence
                                (Ssequence
                                  (Sset _t'37
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _area
                                      (tptr (Tstruct _Area noattr))))
                                  (Ssequence
                                    (Sset _t'38
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'37 (tptr (Tstruct _Area noattr)))
                                          (Tstruct _Area noattr)) _camera
                                        (tptr (Tstruct _Camera noattr))))
                                    (Ssequence
                                      (Sset _t'39
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _area
                                          (tptr (Tstruct _Area noattr))))
                                      (Ssequence
                                        (Sset _t'40
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'39 (tptr (Tstruct _Area noattr)))
                                              (Tstruct _Area noattr)) _camera
                                            (tptr (Tstruct _Camera noattr))))
                                        (Ssequence
                                          (Sset _t'41
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'40 (tptr (Tstruct _Camera noattr)))
                                                (Tstruct _Camera noattr))
                                              _defMode tuchar))
                                          (Scall None
                                            (Evar _set_camera_mode (Tfunction
                                                                    ((tptr (Tstruct _Camera noattr)) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                            ((Etempvar _t'38 (tptr (Tstruct _Camera noattr))) ::
                                             (Etempvar _t'41 tuchar) ::
                                             (Econst_int (Int.repr 1) tint) ::
                                             nil)))))))
                                Sbreak)))))
                      (LScons (Some 2)
                        (Ssequence
                          (Ssequence
                            (Sset _t'19
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _wall
                                (tptr (Tstruct _Surface noattr))))
                            (Sifthenelse (Ebinop One
                                           (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))
                                           (Ecast
                                             (Econst_int (Int.repr 0) tint)
                                             (tptr tvoid)) tint)
                              (Ssequence
                                (Scall None
                                  (Evar _mario_set_forward_vel (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tfloat ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Eunop Oneg
                                     (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                     tfloat) :: nil))
                                (Ssequence
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
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'36
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _vel (tarray tfloat 3))
                                            (Econst_int (Int.repr 1) tint)
                                            (tptr tfloat)) tfloat))
                                      (Sifthenelse (Ebinop Ogt
                                                     (Etempvar _t'36 tfloat)
                                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                     tint)
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
                                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                        Sskip))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'35
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _flags tuint))
                                          (Sifthenelse (Ebinop Oand
                                                         (Etempvar _t'35 tuint)
                                                         (Econst_int (Int.repr 4) tint)
                                                         tuint)
                                            (Sset _t'5
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
                                                            (Econst_int (Int.repr 66) tint)
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
                                                  tuint) tuint))
                                            (Sset _t'5
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
                                                            (Econst_int (Int.repr 69) tint)
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
                                                  (Econst_int (Int.repr 1) tint)
                                                  tuint) tuint))))
                                        (Ssequence
                                          (Sset _t'34
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
                                            ((Etempvar _t'5 tuint) ::
                                             (Efield
                                               (Efield
                                                 (Efield
                                                   (Ederef
                                                     (Etempvar _t'34 (tptr (Tstruct _Object noattr)))
                                                     (Tstruct _Object noattr))
                                                   _header
                                                   (Tstruct _ObjectNode noattr))
                                                 _gfx
                                                 (Tstruct _GraphNodeObject noattr))
                                               _cameraToObject
                                               (tarray tfloat 3)) :: nil))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'33
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
                                              (Etempvar _t'33 tuint)
                                              (Ebinop Oshl
                                                (Econst_int (Int.repr 1) tint)
                                                (Econst_int (Int.repr 1) tint)
                                                tint) tuint)))
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
                                             (Econst_int (Int.repr 16910512) tint) ::
                                             (Econst_int (Int.repr 0) tint) ::
                                             nil))
                                          (Ssequence
                                            (Sset _t'28
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _area
                                                (tptr (Tstruct _Area noattr))))
                                            (Ssequence
                                              (Sset _t'29
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'28 (tptr (Tstruct _Area noattr)))
                                                    (Tstruct _Area noattr))
                                                  _camera
                                                  (tptr (Tstruct _Camera noattr))))
                                              (Ssequence
                                                (Sset _t'30
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _area
                                                    (tptr (Tstruct _Area noattr))))
                                                (Ssequence
                                                  (Sset _t'31
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _t'30 (tptr (Tstruct _Area noattr)))
                                                        (Tstruct _Area noattr))
                                                      _camera
                                                      (tptr (Tstruct _Camera noattr))))
                                                  (Ssequence
                                                    (Sset _t'32
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'31 (tptr (Tstruct _Camera noattr)))
                                                          (Tstruct _Camera noattr))
                                                        _defMode tuchar))
                                                    (Scall None
                                                      (Evar _set_camera_mode 
                                                      (Tfunction
                                                        ((tptr (Tstruct _Camera noattr)) ::
                                                         tshort :: tshort ::
                                                         nil) tvoid
                                                        cc_default))
                                                      ((Etempvar _t'29 (tptr (Tstruct _Camera noattr))) ::
                                                       (Etempvar _t'32 tuchar) ::
                                                       (Econst_int (Int.repr 1) tint) ::
                                                       nil)))))))))))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'6
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
                                      (Ebinop Oadd (Etempvar _t'6 tushort)
                                        (Econst_int (Int.repr 1) tint) tint)))
                                  (Sifthenelse (Ebinop Oeq
                                                 (Etempvar _t'6 tushort)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint)
                                    (Ssequence
                                      (Sset _t'27
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
                                                     (Econst_int (Int.repr 0) tint)
                                                     tuint)
                                                   (Econst_int (Int.repr 28) tint)
                                                   tuint)
                                                 (Ebinop Oshl
                                                   (Ecast
                                                     (Econst_int (Int.repr 68) tint)
                                                     tuint)
                                                   (Econst_int (Int.repr 16) tint)
                                                   tuint) tuint)
                                               (Ebinop Oshl
                                                 (Ecast
                                                   (Econst_int (Int.repr 192) tint)
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
                                                 (Etempvar _t'27 (tptr (Tstruct _Object noattr)))
                                                 (Tstruct _Object noattr))
                                               _header
                                               (Tstruct _ObjectNode noattr))
                                             _gfx
                                             (Tstruct _GraphNodeObject noattr))
                                           _cameraToObject (tarray tfloat 3)) ::
                                         nil)))
                                    Sskip))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'26
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _actionTimer tushort))
                                    (Sifthenelse (Ebinop Oeq
                                                   (Etempvar _t'26 tushort)
                                                   (Econst_int (Int.repr 30) tint)
                                                   tint)
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _actionTimer tushort)
                                        (Econst_int (Int.repr 0) tint))
                                      Sskip))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'25
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
                                        (Ebinop Osub (Etempvar _t'25 tshort)
                                          (Econst_int (Int.repr 512) tint)
                                          tint)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'24
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
                                                       (Etempvar _t'24 tshort)
                                                       (Eunop Oneg
                                                         (Econst_int (Int.repr 10922) tint)
                                                         tint) tint)
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _faceAngle
                                                  (tarray tshort 3))
                                                (Econst_int (Int.repr 0) tint)
                                                (tptr tshort)) tshort)
                                            (Eunop Oneg
                                              (Econst_int (Int.repr 10922) tint)
                                              tint))
                                          Sskip))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'22
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _marioObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Ssequence
                                            (Sset _t'23
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
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _header
                                                        (Tstruct _ObjectNode noattr))
                                                      _gfx
                                                      (Tstruct _GraphNodeObject noattr))
                                                    _angle (tarray tshort 3))
                                                  (Econst_int (Int.repr 0) tint)
                                                  (tptr tshort)) tshort)
                                              (Eunop Oneg
                                                (Etempvar _t'23 tshort) tint))))
                                        (Ssequence
                                          (Sset _t'20
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _marioObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Ssequence
                                            (Sset _t'21
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _faceAngle
                                                    (tarray tshort 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tshort)) tshort))
                                            (Sassign
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Efield
                                                    (Efield
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                                          (Tstruct _Object noattr))
                                                        _header
                                                        (Tstruct _ObjectNode noattr))
                                                      _gfx
                                                      (Tstruct _GraphNodeObject noattr))
                                                    _angle (tarray tshort 3))
                                                  (Econst_int (Int.repr 2) tint)
                                                  (tptr tshort)) tshort)
                                              (Etempvar _t'21 tshort)))))))))))
                          Sbreak)
                        (LScons (Some 6)
                          (Ssequence
                            (Scall None
                              (Evar _lava_boost_on_wall (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            Sbreak)
                          LSnil))))))
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
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'17 tshort)
                                   (Econst_int (Int.repr 2048) tint) tint)
                      (Ssequence
                        (Sset _t'18
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sset _t'7
                          (Ecast
                            (Ebinop Oge (Etempvar _t'18 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                              tint) tbool)))
                      (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'7 tint)
                    (Ssequence
                      (Sset _t'16
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
                        (Ebinop Oor (Etempvar _t'16 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 0) tint) tint) tuint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Ebinop Ole (Etempvar _startPitch tshort)
                                     (Econst_int (Int.repr 0) tint) tint)
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
                          (Sset _t'8
                            (Ecast
                              (Ebinop Ogt (Etempvar _t'15 tshort)
                                (Econst_int (Int.repr 0) tint) tint) tbool)))
                        (Sset _t'8 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'8 tint)
                        (Ssequence
                          (Sset _t'14
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat))
                          (Sset _t'9
                            (Ecast
                              (Ebinop Oge (Etempvar _t'14 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                                tint) tbool)))
                        (Sset _t'9 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'9 tint)
                      (Ssequence
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
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 86) tint)
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
                                     (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        (Ssequence
                          (Sset _t'11 (Evar _gAudioRandom tuint))
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _marioObj
                                (tptr (Tstruct _Object noattr))))
                            (Scall None
                              (Evar _play_sound (Tfunction
                                                  (tint :: (tptr tfloat) ::
                                                   nil) tvoid cc_default))
                              ((Ebinop Oadd
                                 (Ebinop Oor
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
                                             (Econst_int (Int.repr 43) tint)
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
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ebinop Omod (Etempvar _t'11 tuint)
                                     (Econst_int (Int.repr 5) tint) tuint)
                                   (Econst_int (Int.repr 16) tint) tuint)
                                 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))))
                      Sskip))
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
                                            (tint :: (tptr tfloat) :: nil)
                                            tvoid cc_default))
                        ((Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 1) tint)
                                     tuint) (Econst_int (Int.repr 28) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 23) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                 (Econst_int (Int.repr 8) tint) tuint) tuint)
                             (Econst_int (Int.repr 67108864) tint) tuint)
                           (Econst_int (Int.repr 1) tint) tuint) ::
                         (Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    (Ssequence
                      (Scall None
                        (Evar _adjust_sound_for_speed (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_act_riding_hoot := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'24, tint) :: (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, tushort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) :: (_t'20, tuint) ::
               (_t'19, (tptr (Tstruct _Object noattr))) :: (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Object noattr))) :: (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Object noattr))) :: (_t'12, tint) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tushort) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, tshort) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'22
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'22 tushort)
                       (Econst_int (Int.repr 128) tint) tint) tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'23
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'24
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint))
            (Sset _t'2
              (Ecast
                (Ebinop Oand (Etempvar _t'24 tint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 7) tint) tint) tint) tbool))))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _usedObj
              (tptr (Tstruct _Object noattr))))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 43) tint) (tptr tint)) tint)
            (Econst_int (Int.repr 0) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'20 (Evar _gGlobalTimer tuint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                (Etempvar _t'20 tuint))))
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
                         (Ecast (Econst_int (Int.repr 2) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 5) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) ::
               (Econst_int (Int.repr 131072) tint) :: nil))
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16779404) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'1 tuint)))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _usedObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'18
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asF32 (tarray tfloat 80))
              (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                (Econst_int (Int.repr 0) tint) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
          (Etempvar _t'18 tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'15
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _usedObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'16
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                  (Econst_int (Int.repr 1) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Ebinop Osub (Etempvar _t'16 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1119420416)) tfloat)
              tfloat))))
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _usedObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asF32 (tarray tfloat 80))
                  (Ebinop Oadd (Econst_int (Int.repr 6) tint)
                    (Econst_int (Int.repr 2) tint) tint) (tptr tfloat))
                tfloat))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
              (Etempvar _t'14 tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _usedObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'12
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Ebinop Oadd (Econst_int (Int.repr 15) tint)
                      (Econst_int (Int.repr 1) tint) tint) (tptr tint)) tint))
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Osub (Econst_int (Int.repr 16384) tint)
                  (Etempvar _t'12 tint) tint))))
          (Ssequence
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 53) tint) :: nil))
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 43) tint) :: nil))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort) (Econst_int (Int.repr 1) tint)))
                      Sskip)))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _vec3f_set (Tfunction
                                   ((tptr tfloat) :: tfloat :: tfloat ::
                                    tfloat :: nil) (tptr tvoid) cc_default))
                ((Efield
                   (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                     (Tstruct _MarioState noattr)) _vel (tarray tfloat 3)) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 nil))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat))
                      (Ssequence
                        (Sset _t'9
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _pos
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 2) tint) (tptr tfloat))
                            tfloat))
                        (Scall None
                          (Evar _vec3f_set (Tfunction
                                             ((tptr tfloat) :: tfloat ::
                                              tfloat :: tfloat :: nil)
                                             (tptr tvoid) cc_default))
                          ((Efield
                             (Efield
                               (Efield
                                 (Ederef
                                   (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr)) _pos
                             (tarray tfloat 3)) :: (Etempvar _t'7 tfloat) ::
                           (Etempvar _t'8 tfloat) ::
                           (Etempvar _t'9 tfloat) :: nil))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
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
                      (Scall None
                        (Evar _vec3s_set (Tfunction
                                           ((tptr tshort) :: tshort ::
                                            tshort :: tshort :: nil)
                                           (tptr tvoid) cc_default))
                        ((Efield
                           (Efield
                             (Efield
                               (Ederef
                                 (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr)) _angle
                           (tarray tshort 3)) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Ebinop Osub (Econst_int (Int.repr 16384) tint)
                           (Etempvar _t'5 tshort) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_flying_triple_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tushort) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'38, tuchar) ::
               (_t'37, (tptr (Tstruct _Camera noattr))) ::
               (_t'36, (tptr (Tstruct _Area noattr))) ::
               (_t'35, (tptr (Tstruct _Camera noattr))) ::
               (_t'34, (tptr (Tstruct _Area noattr))) :: (_t'33, tuchar) ::
               (_t'32, (tptr (Tstruct _Camera noattr))) ::
               (_t'31, (tptr (Tstruct _Area noattr))) :: (_t'30, tushort) ::
               (_t'29, tushort) ::
               (_t'28, (tptr (Tstruct _Object noattr))) :: (_t'27, tshort) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, tushort) :: (_t'24, tshort) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, tushort) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Camera noattr))) ::
               (_t'19, (tptr (Tstruct _Area noattr))) :: (_t'18, tuchar) ::
               (_t'17, (tptr (Tstruct _Camera noattr))) ::
               (_t'16, (tptr (Tstruct _Area noattr))) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _Camera noattr))) ::
               (_t'11, (tptr (Tstruct _Area noattr))) ::
               (_t'10, (tptr (Tstruct _Camera noattr))) ::
               (_t'9, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'29
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'29 tushort)
                   (Ebinop Oor (Econst_int (Int.repr 8192) tint)
                     (Econst_int (Int.repr 32768) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'31
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _area
              (tptr (Tstruct _Area noattr))))
          (Ssequence
            (Sset _t'32
              (Efield
                (Ederef (Etempvar _t'31 (tptr (Tstruct _Area noattr)))
                  (Tstruct _Area noattr)) _camera
                (tptr (Tstruct _Camera noattr))))
            (Ssequence
              (Sset _t'33
                (Efield
                  (Ederef (Etempvar _t'32 (tptr (Tstruct _Camera noattr)))
                    (Tstruct _Camera noattr)) _mode tuchar))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'33 tuchar)
                             (Econst_int (Int.repr 3) tint) tint)
                (Ssequence
                  (Sset _t'34
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'35
                      (Efield
                        (Ederef
                          (Etempvar _t'34 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Ssequence
                      (Sset _t'36
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _area
                          (tptr (Tstruct _Area noattr))))
                      (Ssequence
                        (Sset _t'37
                          (Efield
                            (Ederef
                              (Etempvar _t'36 (tptr (Tstruct _Area noattr)))
                              (Tstruct _Area noattr)) _camera
                            (tptr (Tstruct _Camera noattr))))
                        (Ssequence
                          (Sset _t'38
                            (Efield
                              (Ederef
                                (Etempvar _t'37 (tptr (Tstruct _Camera noattr)))
                                (Tstruct _Camera noattr)) _defMode tuchar))
                          (Scall None
                            (Evar _set_camera_mode (Tfunction
                                                     ((tptr (Tstruct _Camera noattr)) ::
                                                      tshort :: tshort ::
                                                      nil) tvoid cc_default))
                            ((Etempvar _t'35 (tptr (Tstruct _Camera noattr))) ::
                             (Etempvar _t'38 tuchar) ::
                             (Econst_int (Int.repr 1) tint) :: nil)))))))
                Sskip))))
        (Ssequence
          (Sset _t'30
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'30 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 25692298) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'1 tuint))))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 8390825) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint)))))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_sound (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'25
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'25 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 208) tint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'26
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'27
                    (Efield
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _animInfo
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'27 tshort)
                                 (Econst_int (Int.repr 7) tint) tint)
                    (Ssequence
                      (Sset _t'28
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
                                   (Ecast (Econst_int (Int.repr 55) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 128) tint)
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
                                 (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    Sskip)))
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _is_anim_past_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 111) tint) :: nil))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Econst_int (Int.repr 1) tint)))
                  Sskip))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'22
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'22 tushort)
                           (Econst_int (Int.repr 1) tint) tint)
              (Ssequence
                (Sset _t'23
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'24
                    (Efield
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _animInfo
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sset _t'4
                    (Ecast
                      (Ebinop Oeq (Etempvar _t'24 tshort)
                        (Econst_int (Int.repr 1) tint) tint) tbool))))
              (Sset _t'4 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Sset _t'21
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
                           (Ecast (Econst_int (Int.repr 55) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'14
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'14 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                           tint)
              (Ssequence
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _t'16 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Ssequence
                      (Sset _t'18
                        (Efield
                          (Ederef
                            (Etempvar _t'17 (tptr (Tstruct _Camera noattr)))
                            (Tstruct _Camera noattr)) _mode tuchar))
                      (Sifthenelse (Ebinop One (Etempvar _t'18 tuchar)
                                     (Econst_int (Int.repr 3) tint) tint)
                        (Ssequence
                          (Sset _t'19
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _area
                              (tptr (Tstruct _Area noattr))))
                          (Ssequence
                            (Sset _t'20
                              (Efield
                                (Ederef
                                  (Etempvar _t'19 (tptr (Tstruct _Area noattr)))
                                  (Tstruct _Area noattr)) _camera
                                (tptr (Tstruct _Camera noattr))))
                            (Scall None
                              (Evar _set_camera_mode (Tfunction
                                                       ((tptr (Tstruct _Camera noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _t'20 (tptr (Tstruct _Camera noattr))) ::
                               (Econst_int (Int.repr 3) tint) ::
                               (Econst_int (Int.repr 1) tint) :: nil))))
                        Sskip))))
                (Ssequence
                  (Ssequence
                    (Sset _t'15
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'15 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                   tint)
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat) ::
                         nil))
                      Sskip))
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 277350553) tint) ::
                     (Econst_int (Int.repr 1) tint) :: nil))))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Ebinop Oadd (Etempvar _t'5 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tushort)
                               (Econst_int (Int.repr 10) tint) tint)
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _area
                        (tptr (Tstruct _Area noattr))))
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _t'11 (tptr (Tstruct _Area noattr)))
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr))))
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _t'12 (tptr (Tstruct _Camera noattr)))
                              (Tstruct _Camera noattr)) _mode tuchar))
                        (Sset _t'6
                          (Ecast
                            (Ebinop One (Etempvar _t'13 tuchar)
                              (Econst_int (Int.repr 3) tint) tint) tbool)))))
                  (Sset _t'6 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'6 tint)
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Scall None
                      (Evar _set_camera_mode (Tfunction
                                               ((tptr (Tstruct _Camera noattr)) ::
                                                tshort :: tshort :: nil)
                                               tvoid cc_default))
                      ((Etempvar _t'10 (tptr (Tstruct _Camera noattr))) ::
                       (Econst_int (Int.repr 3) tint) ::
                       (Econst_int (Int.repr 1) tint) :: nil))))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _update_air_without_turn (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'7)
                    (Evar _perform_air_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sswitch (Etempvar _t'7 tint)
                    (LScons (Some 1)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _check_fall_damage_or_get_stuck (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    nil) tint
                                                                    cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 132192) tint) :: nil))
                          (Sifthenelse (Eunop Onotbool (Etempvar _t'8 tint)
                                         tint)
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 67110002) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sskip))
                        Sbreak)
                      (LScons (Some 2)
                        (Ssequence
                          (Scall None
                            (Evar _mario_bonk_reflection (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tuint :: nil)
                                                           tvoid cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sbreak)
                        (LScons (Some 6)
                          (Ssequence
                            (Scall None
                              (Evar _lava_boost_on_wall (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            Sbreak)
                          LSnil)))))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_top_of_pole_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Scall None
    (Evar _play_mario_jump_sound (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _common_air_action_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tint :: tuint :: nil) tuint
                                      cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 67110001) tint) ::
       (Econst_int (Int.repr 10) tint) :: (Econst_int (Int.repr 1) tint) ::
       nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_vertical_wind := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_intendedDYaw, tshort) :: (_intendedMag, tfloat) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'13, tshort) ::
               (_t'12, tshort) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
               (_t'6, tfloat) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tfloat) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedYaw tshort))
    (Ssequence
      (Sset _t'13
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _intendedDYaw
        (Ecast
          (Ebinop Osub (Etempvar _t'12 tshort) (Etempvar _t'13 tshort) tint)
          tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _intendedMag tfloat))
      (Sset _intendedMag
        (Ebinop Odiv (Etempvar _t'11 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
          tfloat)))
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 12) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 131072) tint) :: nil))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tushort)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 207) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animFrame tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tshort)
                                   (Econst_int (Int.repr 1) tint) tint)
                      (Ssequence
                        (Sset _t'10
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
                                     (Ecast (Econst_int (Int.repr 55) tint)
                                       tuint) (Econst_int (Int.repr 16) tint)
                                     tuint) tuint)
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
                      Sskip)))
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _is_anim_past_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Econst_int (Int.repr 1) tint))
                    Sskip))))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 21) tint) :: nil))))
        (Ssequence
          (Scall None
            (Evar _update_air_without_turn (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _perform_air_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sswitch (Etempvar _t'2 tint)
                (LScons (Some 1)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 8914006) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Scall None
                        (Evar _mario_set_forward_vel (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tfloat :: nil) tvoid
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                           tfloat) :: nil))
                      Sbreak)
                    LSnil))))
            (Ssequence
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
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                        (Ebinop Oshr
                          (Ecast (Etempvar _intendedDYaw tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _angle
                          (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tshort)) tshort)
                    (Ecast
                      (Ebinop Omul
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1170210816)) tfloat)
                          (Etempvar _intendedMag tfloat) tfloat)
                        (Etempvar _t'6 tfloat) tfloat) tshort))))
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
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _angle
                            (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tshort)) tshort)
                      (Ecast
                        (Ebinop Omul
                          (Ebinop Omul
                            (Eunop Oneg
                              (Econst_single (Float32.of_bits (Int.repr 1166016512)) tfloat)
                              tfloat) (Etempvar _intendedMag tfloat) tfloat)
                          (Etempvar _t'4 tfloat) tfloat) tshort))))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_special_triple_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tshort) :: (_t'4, tushort) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tfloat) ::
               (_t'9, tushort) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 25692298) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
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
      (Scall None
        (Evar _play_mario_sound (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 2) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 4) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) :: nil))
      (Ssequence
        (Scall None
          (Evar _update_air_without_turn (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _perform_air_step (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sswitch (Etempvar _t'3 tint)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort)
                        (Ebinop Oadd (Etempvar _t'4 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                                   (Econst_int (Int.repr 0) tint) tint)
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
                        (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 201327154) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))))
                  (Ssequence
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
                                 (Econst_int (Int.repr 16) tint) tuint)
                               tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 128) tint) tuint)
                               (Econst_int (Int.repr 8) tint) tuint) tuint)
                           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                             (Econst_int (Int.repr 128) tint) tint) tuint)
                         (Econst_int (Int.repr 1) tint) tuint) :: nil))
                    Sbreak))
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _mario_bonk_reflection (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 1) tint) :: nil))
                    Sbreak)
                  LSnil))))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Sset _t'6 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _vel
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Sset _t'6
                      (Ecast
                        (Ebinop Ogt (Etempvar _t'10 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                          tint) tbool)))))
              (Sifthenelse (Etempvar _t'6 tint)
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 111) tint) :: nil))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'5 tshort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Ssequence
                      (Sset _t'8
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
                                   (Ecast (Econst_int (Int.repr 55) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 128) tint)
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
                                 (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    Sskip))
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 86) tint) :: nil))))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint)
                  (Ebinop Oor (Etempvar _t'7 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 3) tint) tint) tuint)))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_check_common_airborne_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'10, tshort) :: (_t'9, tfloat) ::
               (_t'8, tushort) :: (_t'7, tuint) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'9 tfloat)
                     (Ebinop Osub (Etempvar _t'10 tshort)
                       (Econst_int (Int.repr 100) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_water_plunge_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 64) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131897) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tshort)
                           (Econst_int (Int.repr 56) tint) tint)
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _action tuint))
                (Sset _t'4
                  (Ecast
                    (Ebinop Oand (Etempvar _t'7 tuint)
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 24) tint) tint) tuint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint)))))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 268961948) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip))
      (Ssequence
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
          (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_mario_execute_airborne_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tuint) :: (_t'45, tint) :: (_t'44, tint) ::
               (_t'43, tint) :: (_t'42, tint) :: (_t'41, tint) ::
               (_t'40, tint) :: (_t'39, tint) :: (_t'38, tint) ::
               (_t'37, tint) :: (_t'36, tint) :: (_t'35, tint) ::
               (_t'34, tint) :: (_t'33, tint) :: (_t'32, tint) ::
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
               (_t'1, tint) :: (_t'46, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_airborne_cancels (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_far_fall_sound (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Sset _t'46
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sswitch (Etempvar _t'46 tuint)
          (LScons (Some 50333824)
            (Ssequence
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _act_jump (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'2 tint)))
              Sbreak)
            (LScons (Some 50333825)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _act_double_jump (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'3 tint)))
                Sbreak)
              (LScons (Some 16779404)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'4)
                      (Evar _act_freefall (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'4 tint)))
                  Sbreak)
                (LScons (Some 50333856)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'5)
                        (Evar _act_hold_jump (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'5 tint)))
                    Sbreak)
                  (LScons (Some 16779425)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'6)
                          (Evar _act_hold_freefall (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'6 tint)))
                      Sbreak)
                    (LScons (Some 16779399)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'7)
                            (Evar _act_side_flip (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'7 tint)))
                        Sbreak)
                      (LScons (Some 50333830)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'8)
                              (Evar _act_wall_kick_air (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tint
                                                         cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'8 tint)))
                          Sbreak)
                        (LScons (Some 276826276)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'9)
                                (Evar _act_twirling (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'9 tint)))
                            Sbreak)
                          (LScons (Some 16779401)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'10)
                                  (Evar _act_water_jump (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'10 tint)))
                              Sbreak)
                            (LScons (Some 16779427)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'11)
                                    (Evar _act_hold_water_jump (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tint
                                                                 cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'11 tint)))
                                Sbreak)
                              (LScons (Some 50333829)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'12)
                                      (Evar _act_steep_jump (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'12 tint)))
                                  Sbreak)
                                (LScons (Some 16910516)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'13)
                                        (Evar _act_burning_jump (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'13 tint)))
                                    Sbreak)
                                  (LScons (Some 16910517)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'14)
                                          (Evar _act_burning_fall (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'14 tint)))
                                      Sbreak)
                                    (LScons (Some 16779394)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'15)
                                            (Evar _act_triple_jump (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'15 tint)))
                                        Sbreak)
                                      (LScons (Some 16779395)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'16)
                                              (Evar _act_backflip (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'16 tint)))
                                          Sbreak)
                                        (LScons (Some 50333832)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'17)
                                                (Evar _act_long_jump 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'17 tint)))
                                            Sbreak)
                                          (LScons (Some 42010778)
                                            Sskip
                                            (LScons (Some 8456347)
                                              (Ssequence
                                                (Ssequence
                                                  (Scall (Some _t'18)
                                                    (Evar _act_riding_shell_air 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     nil))
                                                  (Sset _cancel
                                                    (Etempvar _t'18 tint)))
                                                Sbreak)
                                              (LScons (Some 25692298)
                                                (Ssequence
                                                  (Ssequence
                                                    (Scall (Some _t'19)
                                                      (Evar _act_dive 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                       nil))
                                                    (Sset _cancel
                                                      (Etempvar _t'19 tint)))
                                                  Sbreak)
                                                (LScons (Some 2197817515)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Scall (Some _t'20)
                                                        (Evar _act_air_throw 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         nil))
                                                      (Sset _cancel
                                                        (Etempvar _t'20 tint)))
                                                    Sbreak)
                                                  (LScons (Some 16910512)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Scall (Some _t'21)
                                                          (Evar _act_backward_air_kb 
                                                          (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                           nil))
                                                        (Sset _cancel
                                                          (Etempvar _t'21 tint)))
                                                      Sbreak)
                                                    (LScons (Some 16910513)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Scall (Some _t'22)
                                                            (Evar _act_forward_air_kb 
                                                            (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                             nil))
                                                          (Sset _cancel
                                                            (Etempvar _t'22 tint)))
                                                        Sbreak)
                                                      (LScons (Some 16910514)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Scall (Some _t'23)
                                                              (Evar _act_hard_forward_air_kb 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                               nil))
                                                            (Sset _cancel
                                                              (Etempvar _t'23 tint)))
                                                          Sbreak)
                                                        (LScons (Some 16910515)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Scall (Some _t'24)
                                                                (Evar _act_hard_backward_air_kb 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                 nil))
                                                              (Sset _cancel
                                                                (Etempvar _t'24 tint)))
                                                            Sbreak)
                                                          (LScons (Some 16910518)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'25)
                                                                  (Evar _act_soft_bonk 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                   nil))
                                                                (Sset _cancel
                                                                  (Etempvar _t'25 tint)))
                                                              Sbreak)
                                                            (LScons (Some 2215)
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'26)
                                                                    (Evar _act_air_hit_wall 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                  (Sset _cancel
                                                                    (Etempvar _t'26 tint)))
                                                                Sbreak)
                                                              (LScons (Some 16779430)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'27)
                                                                    (Evar _act_forward_rollout 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'27 tint)))
                                                                  Sbreak)
                                                                (LScons (Some 8915096)
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'28)
                                                                    (Evar _act_shot_from_cannon 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'28 tint)))
                                                                    Sbreak)
                                                                  (LScons (Some 50333838)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'29)
                                                                    (Evar _act_butt_slide_air 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'29 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16779426)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'30)
                                                                    (Evar _act_hold_butt_slide_air 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'30 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16910519)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'31)
                                                                    (Evar _act_lava_boost 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'31 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16910520)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'32)
                                                                    (Evar _act_getting_blown 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'32 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16779437)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'33)
                                                                    (Evar _act_backward_rollout 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'33 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 2222)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'34)
                                                                    (Evar _act_crazy_box_bounce 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'34 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 50333871)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'35)
                                                                    (Evar _act_special_triple_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'35 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 8390825)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'36)
                                                                    (Evar _act_ground_pound 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'36 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16910525)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'37)
                                                                    (Evar _act_thrown_forward 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'37 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 16910526)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'38)
                                                                    (Evar _act_thrown_backward 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'38 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 50333844)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'39)
                                                                    (Evar _act_flying_triple_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'39 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 25168042)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'40)
                                                                    (Evar _act_slide_kick 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'40 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 25168044)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'41)
                                                                    (Evar _act_jump_kick 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'41 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 277350553)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'42)
                                                                    (Evar _act_flying 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'42 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1192)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'43)
                                                                    (Evar _act_riding_hoot 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'43 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 50333837)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'44)
                                                                    (Evar _act_top_of_pole_jump 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'44 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 268961948)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'45)
                                                                    (Evar _act_vertical_wind 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'45 tint)))
                                                                    Sbreak)
                                                                    LSnil)))))))))))))))))))))))))))))))))))))))))))))))
      (Sreturn (Some (Etempvar _cancel tuint))))))
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
 (_set_camera_shake_from_hit,
   Gfun(External (EF_external "set_camera_shake_from_hit"
                   (mksignature (AST.Xint16signed :: nil) AST.Xvoid
                     cc_default)) (tshort :: nil) tvoid cc_default)) ::
 (_set_camera_mode,
   Gfun(External (EF_external "set_camera_mode"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) :: (_gAudioRandom, Gvar v_gAudioRandom) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) :: (_gSineTable, Gvar v_gSineTable) ::
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
     tshort cc_default)) :: (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_mario_grab_used_object,
   Gfun(External (EF_external "mario_grab_used_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_drop_held_object,
   Gfun(External (EF_external "mario_drop_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_throw_held_object,
   Gfun(External (EF_external "mario_throw_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_blow_off_cap,
   Gfun(External (EF_external "mario_blow_off_cap"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_mario_check_object_grab,
   Gfun(External (EF_external "mario_check_object_grab"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_load_level_init_text,
   Gfun(External (EF_external "load_level_init_text"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tuint :: nil) tvoid cc_default)) ::
 (_level_trigger_warp,
   Gfun(External (EF_external "level_trigger_warp"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
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
 (_set_anim_to_frame,
   Gfun(External (EF_external "set_anim_to_frame"
                   (mksignature (AST.Xptr :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: nil) tvoid
     cc_default)) ::
 (_play_sound_if_no_flag,
   Gfun(External (EF_external "play_sound_if_no_flag"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_play_mario_jump_sound,
   Gfun(External (EF_external "play_mario_jump_sound"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_adjust_sound_for_speed,
   Gfun(External (EF_external "adjust_sound_for_speed"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_play_mario_landing_sound,
   Gfun(External (EF_external "play_mario_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_heavy_landing_sound,
   Gfun(External (EF_external "play_mario_heavy_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_sound,
   Gfun(External (EF_external "play_mario_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: tint :: nil) tvoid
     cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_mario_floor_is_slippery,
   Gfun(External (EF_external "mario_floor_is_slippery"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_update_mario_sound_and_camera,
   Gfun(External (EF_external "update_mario_sound_and_camera"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
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
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_bonk_reflection,
   Gfun(External (EF_external "mario_bonk_reflection"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_perform_air_step,
   Gfun(External (EF_external "perform_air_step"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tint cc_default)) ::
 (_gSpecialTripleJump, Gvar v_gSpecialTripleJump) ::
 (_play_flip_sounds, Gfun(Internal f_play_flip_sounds)) ::
 (_play_far_fall_sound, Gfun(Internal f_play_far_fall_sound)) ::
 (_play_knockback_sound, Gfun(Internal f_play_knockback_sound)) ::
 (_lava_boost_on_wall, Gfun(Internal f_lava_boost_on_wall)) ::
 (_check_fall_damage, Gfun(Internal f_check_fall_damage)) ::
 (_check_kick_or_dive_in_air, Gfun(Internal f_check_kick_or_dive_in_air)) ::
 (_should_get_stuck_in_ground, Gfun(Internal f_should_get_stuck_in_ground)) ::
 (_check_fall_damage_or_get_stuck, Gfun(Internal f_check_fall_damage_or_get_stuck)) ::
 (_check_horizontal_wind, Gfun(Internal f_check_horizontal_wind)) ::
 (_update_air_with_turn, Gfun(Internal f_update_air_with_turn)) ::
 (_update_air_without_turn, Gfun(Internal f_update_air_without_turn)) ::
 (_update_lava_boost_or_twirling, Gfun(Internal f_update_lava_boost_or_twirling)) ::
 (_update_flying_yaw, Gfun(Internal f_update_flying_yaw)) ::
 (_update_flying_pitch, Gfun(Internal f_update_flying_pitch)) ::
 (_update_flying, Gfun(Internal f_update_flying)) ::
 (_common_air_action_step, Gfun(Internal f_common_air_action_step)) ::
 (_act_jump, Gfun(Internal f_act_jump)) ::
 (_act_double_jump, Gfun(Internal f_act_double_jump)) ::
 (_act_triple_jump, Gfun(Internal f_act_triple_jump)) ::
 (_act_backflip, Gfun(Internal f_act_backflip)) ::
 (_act_freefall, Gfun(Internal f_act_freefall)) ::
 (_act_hold_jump, Gfun(Internal f_act_hold_jump)) ::
 (_act_hold_freefall, Gfun(Internal f_act_hold_freefall)) ::
 (_act_side_flip, Gfun(Internal f_act_side_flip)) ::
 (_act_wall_kick_air, Gfun(Internal f_act_wall_kick_air)) ::
 (_act_long_jump, Gfun(Internal f_act_long_jump)) ::
 (_act_riding_shell_air, Gfun(Internal f_act_riding_shell_air)) ::
 (_act_twirling, Gfun(Internal f_act_twirling)) ::
 (_act_dive, Gfun(Internal f_act_dive)) ::
 (_act_air_throw, Gfun(Internal f_act_air_throw)) ::
 (_act_water_jump, Gfun(Internal f_act_water_jump)) ::
 (_act_hold_water_jump, Gfun(Internal f_act_hold_water_jump)) ::
 (_act_steep_jump, Gfun(Internal f_act_steep_jump)) ::
 (_act_ground_pound, Gfun(Internal f_act_ground_pound)) ::
 (_act_burning_jump, Gfun(Internal f_act_burning_jump)) ::
 (_act_burning_fall, Gfun(Internal f_act_burning_fall)) ::
 (_act_crazy_box_bounce, Gfun(Internal f_act_crazy_box_bounce)) ::
 (_common_air_knockback_step, Gfun(Internal f_common_air_knockback_step)) ::
 (_check_wall_kick, Gfun(Internal f_check_wall_kick)) ::
 (_act_backward_air_kb, Gfun(Internal f_act_backward_air_kb)) ::
 (_act_forward_air_kb, Gfun(Internal f_act_forward_air_kb)) ::
 (_act_hard_backward_air_kb, Gfun(Internal f_act_hard_backward_air_kb)) ::
 (_act_hard_forward_air_kb, Gfun(Internal f_act_hard_forward_air_kb)) ::
 (_act_thrown_backward, Gfun(Internal f_act_thrown_backward)) ::
 (_act_thrown_forward, Gfun(Internal f_act_thrown_forward)) ::
 (_act_soft_bonk, Gfun(Internal f_act_soft_bonk)) ::
 (_act_getting_blown, Gfun(Internal f_act_getting_blown)) ::
 (_act_air_hit_wall, Gfun(Internal f_act_air_hit_wall)) ::
 (_act_forward_rollout, Gfun(Internal f_act_forward_rollout)) ::
 (_act_backward_rollout, Gfun(Internal f_act_backward_rollout)) ::
 (_act_butt_slide_air, Gfun(Internal f_act_butt_slide_air)) ::
 (_act_hold_butt_slide_air, Gfun(Internal f_act_hold_butt_slide_air)) ::
 (_act_lava_boost, Gfun(Internal f_act_lava_boost)) ::
 (_act_slide_kick, Gfun(Internal f_act_slide_kick)) ::
 (_act_jump_kick, Gfun(Internal f_act_jump_kick)) ::
 (_act_shot_from_cannon, Gfun(Internal f_act_shot_from_cannon)) ::
 (_act_flying, Gfun(Internal f_act_flying)) ::
 (_act_riding_hoot, Gfun(Internal f_act_riding_hoot)) ::
 (_act_flying_triple_jump, Gfun(Internal f_act_flying_triple_jump)) ::
 (_act_top_of_pole_jump, Gfun(Internal f_act_top_of_pole_jump)) ::
 (_act_vertical_wind, Gfun(Internal f_act_vertical_wind)) ::
 (_act_special_triple_jump, Gfun(Internal f_act_special_triple_jump)) ::
 (_check_common_airborne_cancels, Gfun(Internal f_check_common_airborne_cancels)) ::
 (_mario_execute_airborne_action, Gfun(Internal f_mario_execute_airborne_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_airborne_action :: _check_common_airborne_cancels ::
 _act_special_triple_jump :: _act_vertical_wind :: _act_top_of_pole_jump ::
 _act_flying_triple_jump :: _act_riding_hoot :: _act_flying ::
 _act_shot_from_cannon :: _act_jump_kick :: _act_slide_kick ::
 _act_lava_boost :: _act_hold_butt_slide_air :: _act_butt_slide_air ::
 _act_backward_rollout :: _act_forward_rollout :: _act_air_hit_wall ::
 _act_getting_blown :: _act_soft_bonk :: _act_thrown_forward ::
 _act_thrown_backward :: _act_hard_forward_air_kb ::
 _act_hard_backward_air_kb :: _act_forward_air_kb :: _act_backward_air_kb ::
 _check_wall_kick :: _common_air_knockback_step :: _act_crazy_box_bounce ::
 _act_burning_fall :: _act_burning_jump :: _act_ground_pound ::
 _act_steep_jump :: _act_hold_water_jump :: _act_water_jump ::
 _act_air_throw :: _act_dive :: _act_twirling :: _act_riding_shell_air ::
 _act_long_jump :: _act_wall_kick_air :: _act_side_flip ::
 _act_hold_freefall :: _act_hold_jump :: _act_freefall :: _act_backflip ::
 _act_triple_jump :: _act_double_jump :: _act_jump ::
 _common_air_action_step :: _update_flying :: _update_flying_pitch ::
 _update_flying_yaw :: _update_lava_boost_or_twirling ::
 _update_air_without_turn :: _update_air_with_turn ::
 _check_horizontal_wind :: _check_fall_damage_or_get_stuck ::
 _should_get_stuck_in_ground :: _check_kick_or_dive_in_air ::
 _check_fall_damage :: _lava_boost_on_wall :: _play_knockback_sound ::
 _play_far_fall_sound :: _play_flip_sounds :: _gSpecialTripleJump ::
 _perform_air_step :: _mario_bonk_reflection :: _set_water_plunge_action ::
 _drop_and_set_mario_action :: _set_mario_action ::
 _update_mario_sound_and_camera :: _mario_floor_is_slippery ::
 _mario_set_forward_vel :: _play_mario_sound ::
 _play_mario_heavy_landing_sound :: _play_mario_landing_sound ::
 _adjust_sound_for_speed :: _play_mario_jump_sound ::
 _play_sound_if_no_flag :: _set_anim_to_frame :: _set_mario_animation ::
 _is_anim_past_end :: _is_anim_at_end :: _level_trigger_warp ::
 _load_level_init_text :: _mario_check_object_grab :: _mario_blow_off_cap ::
 _mario_throw_held_object :: _mario_drop_held_object ::
 _mario_grab_used_object :: _gGlobalTimer :: _atan2s :: _approach_f32 ::
 _approach_s32 :: _vec3s_set :: _vec3f_set :: _vec3f_copy :: _gSineTable ::
 _play_sound :: _gAudioRandom :: _set_camera_mode ::
 _set_camera_shake_from_hit :: _sqrtf :: ___builtin_debug ::
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


