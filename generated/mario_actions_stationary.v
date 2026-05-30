(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_stationary.c
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
  Definition source_file := "vendor/sm64/src/game/mario_actions_stationary.c".
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
Definition _act_air_throw_land : ident := $"act_air_throw_land".
Definition _act_backflip_land_stop : ident := $"act_backflip_land_stop".
Definition _act_braking_stop : ident := $"act_braking_stop".
Definition _act_butt_slide_stop : ident := $"act_butt_slide_stop".
Definition _act_coughing : ident := $"act_coughing".
Definition _act_crouching : ident := $"act_crouching".
Definition _act_double_jump_land_stop : ident := $"act_double_jump_land_stop".
Definition _act_first_person : ident := $"act_first_person".
Definition _act_freefall_land_stop : ident := $"act_freefall_land_stop".
Definition _act_ground_pound_land : ident := $"act_ground_pound_land".
Definition _act_hold_butt_slide_stop : ident := $"act_hold_butt_slide_stop".
Definition _act_hold_freefall_land_stop : ident := $"act_hold_freefall_land_stop".
Definition _act_hold_heavy_idle : ident := $"act_hold_heavy_idle".
Definition _act_hold_idle : ident := $"act_hold_idle".
Definition _act_hold_jump_land_stop : ident := $"act_hold_jump_land_stop".
Definition _act_hold_panting_unused : ident := $"act_hold_panting_unused".
Definition _act_idle : ident := $"act_idle".
Definition _act_in_quicksand : ident := $"act_in_quicksand".
Definition _act_jump_land_stop : ident := $"act_jump_land_stop".
Definition _act_lava_boost_land : ident := $"act_lava_boost_land".
Definition _act_long_jump_land_stop : ident := $"act_long_jump_land_stop".
Definition _act_panting : ident := $"act_panting".
Definition _act_shivering : ident := $"act_shivering".
Definition _act_shockwave_bounce : ident := $"act_shockwave_bounce".
Definition _act_side_flip_land_stop : ident := $"act_side_flip_land_stop".
Definition _act_sleeping : ident := $"act_sleeping".
Definition _act_slide_kick_slide_stop : ident := $"act_slide_kick_slide_stop".
Definition _act_standing_against_wall : ident := $"act_standing_against_wall".
Definition _act_start_crawling : ident := $"act_start_crawling".
Definition _act_start_crouching : ident := $"act_start_crouching".
Definition _act_start_sleeping : ident := $"act_start_sleeping".
Definition _act_stop_crawling : ident := $"act_stop_crawling".
Definition _act_stop_crouching : ident := $"act_stop_crouching".
Definition _act_triple_jump_land_stop : ident := $"act_triple_jump_land_stop".
Definition _act_twirl_land : ident := $"act_twirl_land".
Definition _act_waking_up : ident := $"act_waking_up".
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
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _arg1 : ident := $"arg1".
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
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvJumpingBox : ident := $"bhvJumpingBox".
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
Definition _check_common_action_exits : ident := $"check_common_action_exits".
Definition _check_common_hold_action_exits : ident := $"check_common_hold_action_exits".
Definition _check_common_hold_idle_cancels : ident := $"check_common_hold_idle_cancels".
Definition _check_common_idle_cancels : ident := $"check_common_idle_cancels".
Definition _check_common_landing_cancels : ident := $"check_common_landing_cancels".
Definition _check_common_stationary_cancels : ident := $"check_common_stationary_cancels".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _defMode : ident := $"defMode".
Definition _deltaYOfFloorBehindMario : ident := $"deltaYOfFloorBehindMario".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
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
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gSineTable : ident := $"gSineTable".
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
Definition _hurt_and_set_mario_action : ident := $"hurt_and_set_mario_action".
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
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _landing_step : ident := $"landing_step".
Definition _length : ident := $"length".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _load_level_init_text : ident := $"load_level_init_text".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _lower_background_noise : ident := $"lower_background_noise".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_drop_held_object : ident := $"mario_drop_held_object".
Definition _mario_execute_stationary_action : ident := $"mario_execute_stationary_action".
Definition _mario_push_off_steep_floor : ident := $"mario_push_off_steep_floor".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_throw_held_object : ident := $"mario_throw_held_object".
Definition _mario_update_quicksand : ident := $"mario_update_quicksand".
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
Definition _platform : ident := $"platform".
Definition _play_anim_sound : ident := $"play_anim_sound".
Definition _play_mario_heavy_landing_sound : ident := $"play_mario_heavy_landing_sound".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _raise_background_noise : ident := $"raise_background_noise".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_camera_mode : ident := $"set_camera_mode".
Definition _set_jump_from_landing : ident := $"set_jump_from_landing".
Definition _set_jumping_action : ident := $"set_jumping_action".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _sound : ident := $"sound".
Definition _sp18 : ident := $"sp18".
Definition _sp1A : ident := $"sp1A".
Definition _sp1C : ident := $"sp1C".
Definition _sp1E : ident := $"sp1E".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _stationary_ground_step : ident := $"stationary_ground_step".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_sound : ident := $"stop_sound".
Definition _stopping_step : ident := $"stopping_step".
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
Definition _unusedVec1 : ident := $"unusedVec1".
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
Definition _t'5 : ident := 132%positive.
Definition _t'6 : ident := 133%positive.
Definition _t'7 : ident := 134%positive.
Definition _t'8 : ident := 135%positive.
Definition _t'9 : ident := 136%positive.

Definition v_gCurrSaveFileNum := {|
  gvar_info := tshort;
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

Definition v_bhvJumpingBox := {|
  gvar_info := (tarray tuint 0);
  gvar_init := nil;
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gSineTable := {|
  gvar_info := (tarray tfloat 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_check_common_idle_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'9, tuint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tuint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tushort) :: (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tshort) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tushort) ::
               nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_drop_held_object (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'19
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Ssequence
        (Sset _t'20
          (Efield
            (Efield
              (Ederef (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
            tfloat))
        (Sifthenelse (Ebinop Olt (Etempvar _t'20 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1049997758)) tfloat)
                       tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _mario_push_off_steep_floor (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779404) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                       (Econst_int (Int.repr 1024) tint) tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131622) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'17
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_jumping_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tint
                                            cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 50333824) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'16
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                           (Econst_int (Int.repr 4) tint) tint)
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
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                             (Econst_int (Int.repr 8) tint) tint)
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 80) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'5 tuint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                               (Econst_int (Int.repr 16) tint) tint)
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 201327143) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'6 tuint))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
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
                            tshort) (Ecast (Etempvar _t'13 tshort) tshort)))
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 67109952) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'7 tuint)))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                                   (Econst_int (Int.repr 8192) tint) tint)
                      (Ssequence
                        (Scall (Some _t'8)
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 8389504) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'8 tuint))))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                                     (Econst_int (Int.repr 16384) tint) tint)
                        (Ssequence
                          (Scall (Some _t'9)
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 201359905) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Sreturn (Some (Etempvar _t'9 tuint))))
                        Sskip))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_check_common_hold_idle_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'9, tint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'24, tfloat) ::
               (_t'23, (tptr (Tstruct _Surface noattr))) :: (_t'22, tuint) ::
               (_t'21, (tptr (Tstruct _Object noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tuint) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, tushort) :: (_t'16, tushort) :: (_t'15, tushort) ::
               (_t'14, tushort) :: (_t'13, tshort) :: (_t'12, tushort) ::
               (_t'11, tushort) :: (_t'10, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'23
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floor
        (tptr (Tstruct _Surface noattr))))
    (Ssequence
      (Sset _t'24
        (Efield
          (Efield
            (Ederef (Etempvar _t'23 (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
          tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'24 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1049997758)) tfloat)
                     tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _mario_push_off_steep_floor (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779425) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'19
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asU32 (tarray tuint 80)) (Econst_int (Int.repr 66) tint)
              (tptr tuint)) tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'19 tuint)
                       (Econst_int (Int.repr 64) tint) tuint)
          (Ssequence
            (Ssequence
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _heldObj
                  (tptr (Tstruct _Object noattr))))
              (Ssequence
                (Sset _t'21
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _heldObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'22
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'21 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asU32 (tarray tuint 80))
                        (Econst_int (Int.repr 66) tint) (tptr tuint)) tuint)
                    (Ecast
                      (Ebinop Oand (Etempvar _t'22 tuint)
                        (Eunop Onotint (Econst_int (Int.repr 64) tint) tint)
                        tuint) tint)))))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 903) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint)))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'17
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                       (Econst_int (Int.repr 1024) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131622) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_jumping_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tint
                                            cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 50333856) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'15
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                           (Econst_int (Int.repr 4) tint) tint)
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16779425) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'5 tuint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                             (Econst_int (Int.repr 8) tint) tint)
                (Ssequence
                  (Scall (Some _t'6)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 81) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'6 tuint))))
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
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _intendedYaw
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
                          tshort) (Ecast (Etempvar _t'13 tshort) tshort)))
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 1090) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'7 tuint)))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'11
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                                 (Econst_int (Int.repr 8192) tint) tint)
                    (Ssequence
                      (Scall (Some _t'8)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr (-2147482232)) tuint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'8 tuint))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                                   (Econst_int (Int.repr 16384) tint) tint)
                      (Ssequence
                        (Scall (Some _t'9)
                          (Evar _drop_and_set_mario_action (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tuint ::
                                                              tuint :: nil)
                                                             tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 201359905) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'9 tint))))
                      Sskip))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_idle := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_deltaYOfFloorBehindMario, tfloat) :: (_t'12, tint) ::
               (_t'11, tushort) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tfloat) :: (_t'7, tuint) :: (_t'6, tuint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'27, tfloat) ::
               (_t'26, tushort) :: (_t'25, tshort) :: (_t'24, tuint) ::
               (_t'23, tushort) :: (_t'22, (tptr (Tstruct _Area noattr))) ::
               (_t'21, tushort) :: (_t'20, tushort) :: (_t'19, tushort) ::
               (_t'18, tfloat) :: (_t'17, tschar) ::
               (_t'16, (tptr (Tstruct _Surface noattr))) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'27
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
    (Sifthenelse (Ebinop Ogt (Etempvar _t'27 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                   tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131597) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'26
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'26 tushort)
                     (Econst_int (Int.repr 256) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 205521418) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'24
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionArg tuint))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'24 tuint)
                           (Econst_int (Int.repr 1) tint) tuint) tint)
            (Ssequence
              (Sset _t'25
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _health tshort))
              (Sset _t'4
                (Ecast
                  (Ebinop Olt (Etempvar _t'25 tshort)
                    (Econst_int (Int.repr 768) tint) tint) tbool)))
            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521413) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _check_common_idle_cancels (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'5 tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'21 tushort)
                           (Econst_int (Int.repr 3) tint) tint)
              (Ssequence
                (Sset _t'22
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _area
                    (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'23
                    (Efield
                      (Ederef (Etempvar _t'22 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _terrainType tushort))
                  (Sifthenelse (Ebinop Oeq
                                 (Ebinop Oand (Etempvar _t'23 tushort)
                                   (Econst_int (Int.repr 7) tint) tint)
                                 (Econst_int (Int.repr 2) tint) tint)
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 205521419) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'6 tuint))))
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 205521410) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'7 tuint)))))))
              Sskip))
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
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 126) tint) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort))
                    (Sswitch (Etempvar _t'20 tushort)
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
                                                            tint :: nil)
                                                           tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 196) tint) :: nil))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_animation (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tint :: nil)
                                                             tshort
                                                             cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 197) tint) :: nil))
                              Sbreak)
                            LSnil)))))
                  (Ssequence
                    (Scall (Some _t'12)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'12 tint)
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'19
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionState
                                tushort))
                            (Sset _t'11
                              (Ecast
                                (Ebinop Oadd (Etempvar _t'19 tushort)
                                  (Econst_int (Int.repr 1) tint) tint)
                                tushort)))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _actionState
                              tushort) (Etempvar _t'11 tushort)))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'11 tushort)
                                       (Econst_int (Int.repr 3) tint) tint)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'8)
                                (Evar _find_floor_height_relative_polar 
                                (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tshort :: tfloat :: nil) tfloat
                                  cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 32768) tint) tint) ::
                                 (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
                                 nil))
                              (Ssequence
                                (Sset _t'18
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Sset _deltaYOfFloorBehindMario
                                  (Ebinop Osub (Etempvar _t'18 tfloat)
                                    (Etempvar _t'8 tfloat) tfloat))))
                            (Ssequence
                              (Ssequence
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _deltaYOfFloorBehindMario tfloat)
                                               (Eunop Oneg
                                                 (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                                                 tfloat) tint)
                                  (Sset _t'9 (Econst_int (Int.repr 1) tint))
                                  (Sset _t'9
                                    (Ecast
                                      (Ebinop Olt
                                        (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                                        (Etempvar _deltaYOfFloorBehindMario tfloat)
                                        tint) tbool)))
                                (Sifthenelse (Etempvar _t'9 tint)
                                  (Sset _t'10 (Econst_int (Int.repr 1) tint))
                                  (Ssequence
                                    (Sset _t'16
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _floor
                                        (tptr (Tstruct _Surface noattr))))
                                    (Ssequence
                                      (Sset _t'17
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'16 (tptr (Tstruct _Surface noattr)))
                                            (Tstruct _Surface noattr)) _flags
                                          tschar))
                                      (Sset _t'10
                                        (Ecast
                                          (Ebinop Oand
                                            (Etempvar _t'17 tschar)
                                            (Ebinop Oshl
                                              (Econst_int (Int.repr 1) tint)
                                              (Econst_int (Int.repr 0) tint)
                                              tint) tint) tbool))))))
                              (Sifthenelse (Etempvar _t'10 tint)
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _actionState tushort)
                                  (Econst_int (Int.repr 0) tint))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
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
                                      (Ebinop Oadd (Etempvar _t'15 tushort)
                                        (Econst_int (Int.repr 1) tint) tint)))
                                  (Ssequence
                                    (Sset _t'14
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _actionTimer tushort))
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _t'14 tushort)
                                                   (Econst_int (Int.repr 10) tint)
                                                   tint)
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _actionState tushort)
                                        (Econst_int (Int.repr 0) tint))
                                      Sskip))))))
                          Sskip))
                      Sskip)))))
            (Ssequence
              (Scall None
                (Evar _stationary_ground_step (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_play_anim_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_actionState, tuint) :: (_animFrame, tint) ::
                (_sound, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tushort) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionState tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                   (Etempvar _actionState tuint) tint)
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
                    (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animFrame tshort))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _t'5 tshort) (Etempvar _animFrame tint)
                tint) tbool))))
      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
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
        ((Etempvar _sound tuint) ::
         (Efield
           (Efield
             (Efield
               (Ederef (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                 (Tstruct _Object noattr)) _header
               (Tstruct _ObjectNode noattr)) _gfx
             (Tstruct _GraphNodeObject noattr)) _cameraToObject
           (tarray tfloat 3)) :: nil)))
    Sskip))
|}.

Definition f_act_start_sleeping := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tshort) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'21, tfloat) ::
               (_t'20, tushort) ::
               (_t'19, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'18, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'17, tushort) :: (_t'16, tuint) :: (_t'15, tushort) ::
               (_t'14, tushort) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_idle_cancels (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'21
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'21 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                     tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131597) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'20 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 201327107) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'17
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Sswitch (Etempvar _t'17 tushort)
            (LScons (Some 0)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 129) tint) :: nil))
                  (Sset _animFrame (Etempvar _t'4 tshort)))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 130) tint) :: nil))
                    (Sset _animFrame (Etempvar _t'5 tshort)))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 131) tint) :: nil))
                      (Sset _animFrame (Etempvar _t'6 tshort)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'19
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioBodyState
                            (tptr (Tstruct _MarioBodyState noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'19 (tptr (Tstruct _MarioBodyState noattr)))
                              (Tstruct _MarioBodyState noattr)) _eyeState
                            tschar) (Econst_int (Int.repr 2) tint)))
                      Sbreak))
                  (LScons (Some 3)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 132) tint) :: nil))
                        (Sset _animFrame (Etempvar _t'7 tshort)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'18
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _marioBodyState
                              (tptr (Tstruct _MarioBodyState noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'18 (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _eyeState
                              tschar) (Econst_int (Int.repr 2) tint)))
                        Sbreak))
                    LSnil))))))
        (Ssequence
          (Scall None
            (Evar _play_anim_sound (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tint :: tuint :: nil) tvoid
                                     cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1) tint) ::
             (Econst_int (Int.repr 41) tint) ::
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 0) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 63) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl
                     (Ecast (Econst_int (Int.repr 128) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                   (Econst_int (Int.repr 128) tint) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) :: nil))
          (Ssequence
            (Scall None
              (Evar _play_anim_sound (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tuint :: tint :: tuint :: nil) tvoid
                                       cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 1) tint) ::
               (Econst_int (Int.repr 49) tint) ::
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 63) tint) tuint)
                         (Econst_int (Int.repr 16) tint) tuint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 8) tint) tuint) tuint)
                   (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                     (Econst_int (Int.repr 128) tint) tint) tuint)
                 (Econst_int (Int.repr 1) tint) tuint) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _terrainSoundAddend
                    tuint))
                (Scall None
                  (Evar _play_anim_sound (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: tint :: tuint :: nil)
                                           tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 3) tint) ::
                   (Econst_int (Int.repr 15) tint) ::
                   (Ebinop Oadd (Etempvar _t'16 tuint)
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 24) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) tuint) :: nil)))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'8)
                    (Evar _is_anim_at_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'8 tint)
                    (Ssequence
                      (Sset _t'15
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
                        (Ebinop Oadd (Etempvar _t'15 tushort)
                          (Econst_int (Int.repr 1) tint) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'14
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort))
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tushort)
                                     (Econst_int (Int.repr 2) tint) tint)
                        (Sset _t'9
                          (Ecast
                            (Ebinop Oeq (Etempvar _animFrame tint)
                              (Eunop Oneg (Econst_int (Int.repr 1) tint)
                                tint) tint) tbool))
                        (Sset _t'9 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'9 tint)
                      (Ssequence
                        (Sset _t'13
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
                                     (Ecast (Econst_int (Int.repr 13) tint)
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
                                   (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr))
                             _cameraToObject (tarray tfloat 3)) :: nil)))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionState
                            tushort))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tushort)
                                       (Econst_int (Int.repr 1) tint) tint)
                          (Sset _t'10
                            (Ecast
                              (Ebinop Oeq (Etempvar _animFrame tint)
                                (Eunop Oneg (Econst_int (Int.repr 1) tint)
                                  tint) tint) tbool))
                          (Sset _t'10 (Econst_int (Int.repr 0) tint))))
                      (Sifthenelse (Etempvar _t'10 tint)
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
                                       (Ecast (Econst_int (Int.repr 2) tint)
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
                                     (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))
                        Sskip))
                    (Ssequence
                      (Scall None
                        (Evar _stationary_ground_step (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_act_sleeping := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'10, tshort) :: (_t'9, tint) ::
               (_t'8, tshort) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tshort) :: (_t'4, tfloat) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'25, tushort) ::
               (_t'24, tushort) :: (_t'23, tushort) :: (_t'22, tfloat) ::
               (_t'21, tushort) :: (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'18, tushort) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _Object noattr))) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tushort) :: (_t'11, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'24
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'24 tushort)
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 2) tint) tint)
                               (Econst_int (Int.repr 4) tint) tint)
                             (Econst_int (Int.repr 8) tint) tint)
                           (Econst_int (Int.repr 16) tint) tint)
                         (Econst_int (Int.repr 1024) tint) tint)
                       (Econst_int (Int.repr 8192) tint) tint)
                     (Econst_int (Int.repr 32768) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'25
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionState tushort))
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 201327108) tint) ::
             (Etempvar _t'25 tushort) :: nil)))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'22
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'22 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                     tint)
        (Ssequence
          (Ssequence
            (Sset _t'23
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort))
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 201327108) tint) ::
               (Etempvar _t'23 tushort) :: nil)))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'4)
          (Evar _find_floor_height_relative_polar (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tshort :: tfloat :: nil)
                                                    tfloat cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Eunop Oneg (Econst_int (Int.repr 32768) tint) tint) ::
           (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
           nil))
        (Ssequence
          (Sset _t'20
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sifthenelse (Ebinop Ogt
                         (Ebinop Osub (Etempvar _t'20 tfloat)
                           (Etempvar _t'4 tfloat) tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'21
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionState tushort))
                (Scall (Some _t'3)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 201327108) tint) ::
                   (Etempvar _t'21 tushort) :: nil)))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioBodyState
              (tptr (Tstruct _MarioBodyState noattr))))
          (Sassign
            (Efield
              (Ederef
                (Etempvar _t'19 (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _eyeState tschar)
            (Econst_int (Int.repr 3) tint)))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sswitch (Etempvar _t'11 tushort)
                (LScons (Some 0)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'5)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 133) tint) :: nil))
                      (Sset _animFrame (Etempvar _t'5 tshort)))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                                       (Eunop Oneg
                                         (Econst_int (Int.repr 1) tint) tint)
                                       tint)
                          (Ssequence
                            (Sset _t'18
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionTimer
                                tushort))
                            (Sset _t'6
                              (Ecast
                                (Eunop Onotbool (Etempvar _t'18 tushort)
                                  tint) tbool)))
                          (Sset _t'6 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'6 tint)
                          (Scall None
                            (Evar _lower_background_noise (Tfunction
                                                            (tint :: nil)
                                                            tvoid cc_default))
                            ((Econst_int (Int.repr 2) tint) :: nil))
                          Sskip))
                      (Ssequence
                        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                          (Ssequence
                            (Sset _t'17
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
                                           (Econst_int (Int.repr 14) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
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
                                       (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil)))
                          Sskip)
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                                         (Econst_int (Int.repr 20) tint)
                                         tint)
                            (Ssequence
                              (Sset _t'16
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
                                             (Econst_int (Int.repr 15) tint)
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
                                         (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            Sskip)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'7)
                                (Evar _is_anim_at_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sifthenelse (Etempvar _t'7 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'15
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
                                      (Ebinop Oadd (Etempvar _t'15 tushort)
                                        (Econst_int (Int.repr 1) tint) tint)))
                                  (Ssequence
                                    (Sset _t'13
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _actionTimer tushort))
                                    (Sifthenelse (Ebinop Ogt
                                                   (Etempvar _t'13 tushort)
                                                   (Econst_int (Int.repr 45) tint)
                                                   tint)
                                      (Ssequence
                                        (Sset _t'14
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
                                          (Ebinop Oadd
                                            (Etempvar _t'14 tushort)
                                            (Econst_int (Int.repr 1) tint)
                                            tint)))
                                      Sskip)))
                                Sskip))
                            Sbreak)))))
                  (LScons (Some 1)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'8)
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 134) tint) :: nil))
                        (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tshort)
                                       (Econst_int (Int.repr 18) tint) tint)
                          (Scall None
                            (Evar _play_mario_heavy_landing_sound (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tuint ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 28) tint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 24) tint)
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
                             nil))
                          Sskip))
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'9)
                            (Evar _is_anim_at_end (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sifthenelse (Etempvar _t'9 tint)
                            (Ssequence
                              (Sset _t'12
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
                                (Ebinop Oadd (Etempvar _t'12 tushort)
                                  (Econst_int (Int.repr 1) tint) tint)))
                            Sskip))
                        Sbreak))
                    (LScons (Some 2)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'10)
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 135) tint) :: nil))
                          (Sset _animFrame (Etempvar _t'10 tshort)))
                        (Ssequence
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
                                       (Ecast (Econst_int (Int.repr 53) tint)
                                         tuint)
                                       (Econst_int (Int.repr 16) tint) tuint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 255) tint)
                                       tuint) (Econst_int (Int.repr 8) tint)
                                     tuint) tuint)
                                 (Ebinop Oor
                                   (Econst_int (Int.repr 67108864) tint)
                                   (Econst_int (Int.repr 128) tint) tint)
                                 tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                             (Econst_int (Int.repr 65536) tint) :: nil))
                          Sbreak))
                      LSnil)))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_waking_up := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'12
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Eunop Onotbool (Etempvar _t'12 tushort) tint)
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _stop_sound (Tfunction (tuint :: (tptr tfloat) :: nil)
                                tvoid cc_default))
            ((Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 2) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 14) tint) tuint)
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
                   (Ederef (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))
        (Ssequence
          (Ssequence
            (Sset _t'14
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Scall None
              (Evar _stop_sound (Tfunction (tuint :: (tptr tfloat) :: nil)
                                  tvoid cc_default))
              ((Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 2) tint) tuint)
                         (Econst_int (Int.repr 28) tint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 15) tint) tuint)
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
                     (Ederef (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Scall None
                (Evar _stop_sound (Tfunction (tuint :: (tptr tfloat) :: nil)
                                    tvoid cc_default))
                ((Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 2) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 53) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 255) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            (Scall None
              (Evar _raise_background_noise (Tfunction (tint :: nil) tvoid
                                              cc_default))
              ((Econst_int (Int.repr 2) tint) :: nil)))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
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
                       (Econst_int (Int.repr 4) tint) tint)
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
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 80) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort)
              (Ebinop Oadd (Etempvar _t'8 tushort)
                (Econst_int (Int.repr 1) tint) tint)))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'7 tushort)
                             (Econst_int (Int.repr 20) tint) tint)
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 205521409) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'4 tuint))))
                Sskip))
            (Ssequence
              (Scall None
                (Evar _stationary_ground_step (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionArg tuint))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'6 tuint) tint)
                      (Sset _t'5
                        (Ecast (Econst_int (Int.repr 200) tint) tint))
                      (Sset _t'5
                        (Ecast (Econst_int (Int.repr 201) tint) tint))))
                  (Scall None
                    (Evar _set_mario_animation (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tint :: nil) tshort
                                                 cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Etempvar _t'5 tint) :: nil)))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_shivering := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tshort) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tshort) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'19, tushort) ::
               (_t'18, tushort) :: (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, tuint) :: (_t'14, (tptr (Tstruct _Object noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _Object noattr))) ::
               (_t'11, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'19 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Sset _t'17
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oor
                                     (Ebinop Oor
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     (Econst_int (Int.repr 4) tint) tint)
                                   (Econst_int (Int.repr 8) tint) tint)
                                 (Econst_int (Int.repr 16) tint) tint)
                               (Econst_int (Int.repr 1024) tint) tint)
                             (Econst_int (Int.repr 8192) tint) tint)
                           (Econst_int (Int.repr 32768) tint) tint) tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort)
              (Econst_int (Int.repr 2) tint))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort))
              (Sswitch (Etempvar _t'11 tushort)
                (LScons (Some 0)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'4)
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 25) tint) :: nil))
                      (Sset _animFrame (Etempvar _t'4 tshort)))
                    (Ssequence
                      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                                     (Econst_int (Int.repr 49) tint) tint)
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
                                  (Econst_int (Int.repr 17) tint) tint)
                                tuint)))
                          (Ssequence
                            (Sset _t'14
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
                                           (Econst_int (Int.repr 22) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast
                                         (Econst_int (Int.repr 128) tint)
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
                                       (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil))))
                        Sskip)
                      (Ssequence
                        (Ssequence
                          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                                         (Econst_int (Int.repr 7) tint) tint)
                            (Sset _t'5 (Econst_int (Int.repr 1) tint))
                            (Sset _t'5
                              (Ecast
                                (Ebinop Oeq (Etempvar _animFrame tint)
                                  (Econst_int (Int.repr 81) tint) tint)
                                tbool)))
                          (Sifthenelse (Etempvar _t'5 tint)
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
                                             (Econst_int (Int.repr 0) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 44) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Econst_int (Int.repr 33554432) tint)
                                         (Econst_int (Int.repr 67108864) tint)
                                         tint)
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
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'6)
                              (Evar _is_anim_past_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sifthenelse (Etempvar _t'6 tint)
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionState tushort)
                                (Econst_int (Int.repr 1) tint))
                              Sskip))
                          Sbreak))))
                  (LScons (Some 1)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 27) tint) :: nil))
                        (Sset _animFrame (Etempvar _t'7 tshort)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sifthenelse (Ebinop Oeq
                                           (Etempvar _animFrame tint)
                                           (Econst_int (Int.repr 9) tint)
                                           tint)
                              (Sset _t'8 (Econst_int (Int.repr 1) tint))
                              (Sset _t'8
                                (Ecast
                                  (Ebinop Oeq (Etempvar _animFrame tint)
                                    (Econst_int (Int.repr 25) tint) tint)
                                  tbool)))
                            (Sifthenelse (Etempvar _t'8 tint)
                              (Sset _t'9 (Econst_int (Int.repr 1) tint))
                              (Sset _t'9
                                (Ecast
                                  (Ebinop Oeq (Etempvar _animFrame tint)
                                    (Econst_int (Int.repr 44) tint) tint)
                                  tbool))))
                          (Sifthenelse (Etempvar _t'9 tint)
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
                                             (Econst_int (Int.repr 44) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Ebinop Oor
                                       (Ebinop Oor
                                         (Econst_int (Int.repr 33554432) tint)
                                         (Econst_int (Int.repr 67108864) tint)
                                         tint)
                                       (Econst_int (Int.repr 128) tint) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
                                 (Efield
                                   (Efield
                                     (Efield
                                       (Ederef
                                         (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                         (Tstruct _Object noattr)) _header
                                       (Tstruct _ObjectNode noattr)) _gfx
                                     (Tstruct _GraphNodeObject noattr))
                                   _cameraToObject (tarray tfloat 3)) :: nil)))
                            Sskip))
                        Sbreak))
                    (LScons (Some 2)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 26) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'10)
                              (Evar _is_anim_past_end (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sifthenelse (Etempvar _t'10 tint)
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 205521409) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              Sskip))
                          Sbreak))
                      LSnil)))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_coughing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tshort) :: (_t'1, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_idle_cancels (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _stationary_ground_step (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 48) tint) :: nil))
        (Sset _animFrame (Etempvar _t'2 tshort)))
      (Ssequence
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                         (Econst_int (Int.repr 25) tint) tint)
            (Sset _t'3 (Econst_int (Int.repr 1) tint))
            (Sset _t'3
              (Ecast
                (Ebinop Oeq (Etempvar _animFrame tint)
                  (Econst_int (Int.repr 35) tint) tint) tbool)))
          (Sifthenelse (Etempvar _t'3 tint)
            (Ssequence
              (Sset _t'8
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
                           (Ecast (Econst_int (Int.repr 29) tint) tuint)
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
                         (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                           (Econst_int (Int.repr 50) tint) tint)
              (Sset _t'4 (Econst_int (Int.repr 1) tint))
              (Sset _t'4
                (Ecast
                  (Ebinop Oeq (Etempvar _animFrame tint)
                    (Econst_int (Int.repr 58) tint) tint) tbool)))
            (Sifthenelse (Etempvar _t'4 tint)
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
                             (Ecast (Econst_int (Int.repr 28) tint) tuint)
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
                           (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil)))
              Sskip))
          (Ssequence
            (Ssequence
              (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                             (Econst_int (Int.repr 71) tint) tint)
                (Sset _t'5 (Econst_int (Int.repr 1) tint))
                (Sset _t'5
                  (Ecast
                    (Ebinop Oeq (Etempvar _animFrame tint)
                      (Econst_int (Int.repr 80) tint) tint) tbool)))
              (Sifthenelse (Etempvar _t'5 tint)
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
                               (Ecast (Econst_int (Int.repr 2) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 27) tint) tuint)
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
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_idle := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tuint) ::
               (_t'10, (tptr tuint)) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tint) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tfloat) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'2)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Eaddrof (Evar _bhvJumpingBox (tarray tuint 0))
         (tptr (tarray tuint 0))) :: nil))
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _behavior (tptr tuint)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'2 (tptr tvoid))
                       (Etempvar _t'10 (tptr tuint)) tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 2222) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))
          Sskip))))
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
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521409) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                       tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131597) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _check_common_hold_idle_cancels (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'5 tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
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

Definition f_act_hold_heavy_idle := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tuint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 1095) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
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
                (Scall (Some _t'5)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr (-2147482231)) tuint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'5 tuint))))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _stationary_ground_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 125) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_standing_against_wall := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tushort) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'8
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 2) tint) tint)
                         (Econst_int (Int.repr 4) tint) tint)
                       (Econst_int (Int.repr 8) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _check_common_action_exits (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 16) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 201327143) tint) ::
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
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 8389504) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 126) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _stationary_ground_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_in_quicksand := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tuint) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
    (Sifthenelse (Ebinop Olt (Etempvar _t'4 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat)
                   tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 205521409) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _check_common_idle_cancels (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1116471296)) tfloat)
                       tint)
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 118) tint) :: nil))
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 119) tint) :: nil))))
      (Ssequence
        (Scall None
          (Evar _stationary_ground_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_crouching := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tuint) :: (_t'7, tuint) :: (_t'6, tuint) ::
               (_t'5, tuint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'16, tushort) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tushort) ::
               (_t'9, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'15
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_jumping_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tint
                                        cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779395) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'14
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'14 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
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
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 80) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                           (Econst_int (Int.repr 16) tint) tint)
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 201359906) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'5 tuint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'11 tushort)
                               (Econst_int (Int.repr 16384) tint) tint) tint)
                (Ssequence
                  (Scall (Some _t'6)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 201359906) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'6 tuint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                               (Econst_int (Int.repr 1) tint) tint)
                  (Ssequence
                    (Scall (Some _t'7)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 201359907) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'7 tuint))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                                 (Econst_int (Int.repr 8192) tint) tint)
                    (Ssequence
                      (Scall (Some _t'8)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 8389504) tint) ::
                         (Econst_int (Int.repr 9) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'8 tuint))))
                    Sskip))
                (Ssequence
                  (Scall None
                    (Evar _stationary_ground_step (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 152) tint) :: nil))
                    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))
|}.

Definition f_act_panting := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tshort) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'9, tushort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _health tshort))
      (Sifthenelse (Ebinop Oge (Etempvar _t'8 tshort)
                     (Econst_int (Int.repr 1280) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 205521409) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _check_common_idle_cancels (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'3 tint)
          (Sreturn (Some (Econst_int (Int.repr 1) tint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 186) tint) :: nil))
          (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                         (Econst_int (Int.repr 1) tint) tint)
            (Ssequence
              (Sset _t'6 (Evar _gAudioRandom tuint))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil)
                                      tvoid cc_default))
                  ((Ebinop Oadd
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 2) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 24) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint)
                     (Ebinop Oshl
                       (Ebinop Omod (Etempvar _t'6 tuint)
                         (Econst_int (Int.repr 3) tuint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
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
                (Econst_int (Int.repr 2) tint)))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_panting_unused := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
               (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
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
             (Econst_int (Int.repr 205521413) tint) ::
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
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _health tshort))
        (Sifthenelse (Ebinop Oge (Etempvar _t'6 tshort)
                       (Econst_int (Int.repr 1280) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 134218247) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _check_common_hold_idle_cancels (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'4 tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 186) tint) :: nil))
          (Ssequence
            (Scall None
              (Evar _stationary_ground_step (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
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
                  (Econst_int (Int.repr 2) tint)))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_stopping_step := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animID, tint) :: (_action, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_ground_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _animID tint) :: nil))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _is_anim_at_end (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) :: nil)
                                tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _action tuint) :: (Econst_int (Int.repr 0) tint) :: nil))
        Sskip))))
|}.

Definition f_act_braking_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: (_t'7, tushort) ::
               (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 8389504) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Eunop Onotbool
                           (Ebinop Oand (Etempvar _t'6 tushort)
                             (Econst_int (Int.repr 16) tint) tint) tint)
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sset _t'5
                  (Ecast
                    (Ebinop Oand (Etempvar _t'7 tushort)
                      (Ebinop Oor
                        (Ebinop Oor
                          (Ebinop Oor (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 2) tint) tint)
                          (Econst_int (Int.repr 4) tint) tint)
                        (Econst_int (Int.repr 8) tint) tint) tint) tbool)))
              (Sset _t'5 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'5 tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _check_common_action_exits (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Etempvar _t'4 tint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stopping_step (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: tuint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16) tint) ::
             (Econst_int (Int.repr 205521409) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_butt_slide_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tuint) :: (_t'6, tushort) ::
               (_t'5, tushort) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
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
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 2) tint) tint)
                         (Econst_int (Int.repr 4) tint) tint)
                       (Econst_int (Int.repr 8) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _check_common_action_exits (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _stopping_step (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) ::
                                tint :: tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 143) tint) ::
         (Econst_int (Int.repr 205521409) tint) :: nil))
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
            (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tshort)
                           (Econst_int (Int.repr 6) tint) tint)
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
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_hold_butt_slide_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
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
             (Econst_int (Int.repr 205521409) tint) ::
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
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 2) tint) tint)
                           (Econst_int (Int.repr 4) tint) tint)
                         (Econst_int (Int.repr 8) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _check_common_hold_action_exits (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
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
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr (-2147482232)) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stopping_step (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: tuint :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 70) tint) ::
             (Econst_int (Int.repr 134218247) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_slide_kick_slide_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'4, tushort) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _drop_and_set_mario_action (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tint
                                             cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'3 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _stopping_step (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) ::
                                tint :: tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 141) tint) ::
         (Econst_int (Int.repr 201359904) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_start_crouching := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_jumping_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tint
                                          cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779395) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 80) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 151) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _is_anim_past_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 201359904) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_stop_crouching := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_jumping_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tint
                                          cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779395) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 80) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 150) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _is_anim_past_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 205521409) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_start_crawling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 16) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 201359906) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                       (Econst_int (Int.repr 1024) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131622) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 80) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _stationary_ground_step (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 155) tint) :: nil))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _is_anim_past_end (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 67142728) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_stop_crawling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'7, tushort) :: (_t'6, tushort) ::
               (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 8) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _stationary_ground_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 154) tint) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'4)
                (Evar _is_anim_past_end (Tfunction
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
                   (Econst_int (Int.repr 201359904) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_shockwave_bounce := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp1E, tshort) :: (_sp18, tfloat) :: (_t'4, tushort) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'20, tint) :: (_t'19, (tptr (Tstruct _Object noattr))) ::
               (_t'18, tint) :: (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, tushort) :: (_t'15, tushort) :: (_t'14, tushort) ::
               (_t'13, tushort) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Sset _t'20
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'19 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
            (tptr tint)) tint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'20 tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 4) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _hurt_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: tshort ::
                                                nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131896) tint) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 4) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'16 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'17
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'18
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 43) tint) (tptr tint)) tint))
            (Sifthenelse (Ebinop Oand (Etempvar _t'18 tint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 1) tint) tint) tint)
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _hurt_and_set_mario_action (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: tuint ::
                                                      tshort :: nil) tint
                                                     cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 132194) tint) ::
                   (Econst_int (Int.repr 0) tint) ::
                   (Econst_int (Int.repr 12) tint) :: nil))
                (Sreturn (Some (Etempvar _t'2 tint))))
              Sskip)))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'15
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'4
              (Ecast
                (Ebinop Oadd (Etempvar _t'15 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'4 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 48) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521409) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sset _sp1E
            (Ecast
              (Ebinop Oshl
                (Ebinop Omod (Etempvar _t'14 tushort)
                  (Econst_int (Int.repr 16) tint) tint)
                (Econst_int (Int.repr 12) tint) tint) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _sp18
              (Ecast
                (Ebinop Oadd
                  (Ebinop Omul
                    (Ecast
                      (Ebinop Osub (Econst_int (Int.repr 6) tint)
                        (Ebinop Odiv (Etempvar _t'13 tushort)
                          (Econst_int (Int.repr 8) tint) tint) tint) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                    tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                  tfloat) tfloat)))
          (Ssequence
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 0) tint) :: nil))
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
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Ebinop Oshr (Ecast (Etempvar _sp1E tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'8 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
                    (Ssequence
                      (Sset _t'11
                        (Ederef
                          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                            (Ebinop Oshr
                              (Ecast (Etempvar _sp1E tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floorHeight
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
                          (Ebinop Oadd
                            (Ebinop Omul (Etempvar _t'11 tfloat)
                              (Etempvar _sp18 tfloat) tfloat)
                            (Etempvar _t'12 tfloat) tfloat))))
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floorHeight
                          tfloat))
                      (Ssequence
                        (Sset _t'10
                          (Ederef
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Ebinop Oshr
                                (Ecast (Etempvar _sp1E tshort) tushort)
                                (Econst_int (Int.repr 4) tint) tint)
                              (tptr tfloat)) tfloat))
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
                          (Ebinop Osub (Etempvar _t'9 tfloat)
                            (Ebinop Omul (Etempvar _t'10 tfloat)
                              (Etempvar _sp18 tfloat) tfloat) tfloat))))))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _vec3f_copy (Tfunction
                                          ((tptr tfloat) :: (tptr tfloat) ::
                                           nil) (tptr tvoid) cc_default))
                      ((Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
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
                                   (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                   (Tstruct _Object noattr)) _header
                                 (Tstruct _ObjectNode noattr)) _gfx
                               (Tstruct _GraphNodeObject noattr)) _angle
                             (tarray tshort 3)) ::
                           (Econst_int (Int.repr 0) tint) ::
                           (Etempvar _t'6 tshort) ::
                           (Econst_int (Int.repr 0) tint) :: nil))))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 14) tint) :: nil))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_landing_step := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: (_arg1, tint) ::
                (_action, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _stationary_ground_step (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _arg1 tint) :: nil))
    (Ssequence
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
               (Etempvar _action tuint) :: (Econst_int (Int.repr 0) tint) ::
               nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_check_common_landing_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tuint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
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
             (Econst_int (Int.repr 205521409) tint) ::
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
          (Sifthenelse (Eunop Onotbool (Etempvar _action tuint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_jump_from_landing (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Etempvar _t'3 tint))))
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_jumping_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tint
                                            cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _action tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tint)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 2) tint) tint)
                             (Econst_int (Int.repr 4) tint) tint)
                           (Econst_int (Int.repr 8) tint) tint) tint)
            (Ssequence
              (Scall (Some _t'5)
                (Evar _check_common_action_exits (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Etempvar _t'5 tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'7 tushort)
                           (Econst_int (Int.repr 8192) tint) tint)
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 8389504) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'6 tuint))))
              Sskip))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_jump_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_landing_cancels (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _landing_step (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: tint ::
                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 78) tint) ::
       (Econst_int (Int.repr 205521409) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_double_jump_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_landing_cancels (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _landing_step (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: tint ::
                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 75) tint) ::
       (Econst_int (Int.repr 205521409) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_side_flip_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) ::
               (_t'2, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_landing_cancels (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _landing_step (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: tint ::
                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 190) tint) ::
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
                          (Etempvar _t'2 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _angle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort)
              (Ebinop Oadd (Etempvar _t'4 tshort)
                (Econst_int (Int.repr 32768) tint) tint)))))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_freefall_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_landing_cancels (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _landing_step (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: tint ::
                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 87) tint) ::
       (Econst_int (Int.repr 205521409) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_triple_jump_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_landing_cancels (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 50333824) tint) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _landing_step (Tfunction
                            ((tptr (Tstruct _MarioState noattr)) :: tint ::
                             tuint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 192) tint) ::
       (Econst_int (Int.repr 205521409) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_backflip_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tushort) ::
               (_t'3, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'4 tushort)
                       (Econst_int (Int.repr 16384) tint) tint) tint)
        (Sset _t'1 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'6
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sset _t'1
              (Ecast
                (Ebinop Oge (Etempvar _t'6 tshort)
                  (Econst_int (Int.repr 6) tint) tint) tbool))))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort)
          (Ebinop Oand (Etempvar _t'3 tushort)
            (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _check_common_landing_cancels (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 16779395) tint) :: nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _landing_step (Tfunction
                              ((tptr (Tstruct _MarioState noattr)) :: tint ::
                               tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 192) tint) ::
         (Econst_int (Int.repr 205521409) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_lava_boost_land := {|
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
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort)
      (Ebinop Oand (Etempvar _t'2 tushort)
        (Eunop Onotint
          (Ebinop Oor (Econst_int (Int.repr 16) tint)
            (Econst_int (Int.repr 8192) tint) tint) tint) tint)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _check_common_landing_cancels (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _landing_step (Tfunction
                              ((tptr (Tstruct _MarioState noattr)) :: tint ::
                               tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 40) tint) ::
         (Econst_int (Int.repr 205521409) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_long_jump_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'5, tushort) ::
               (_t'4, tint) :: (_t'3, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort)
      (Ebinop Oand (Etempvar _t'5 tushort)
        (Eunop Onotint (Econst_int (Int.repr 8192) tint) tint) tint)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _check_common_landing_cancels (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 50333824) tint) :: nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
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
                        (Tstruct _Object noattr)) _rawData
                      (Tunion __665 noattr)) _asS32 (tarray tint 80))
                  (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
            (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint) tint)
              (Sset _t'2 (Ecast (Econst_int (Int.repr 17) tint) tint))
              (Sset _t'2 (Ecast (Econst_int (Int.repr 18) tint) tint)))))
        (Scall None
          (Evar _landing_step (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tuint :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _t'2 tint) :: (Econst_int (Int.repr 201359904) tint) ::
           nil)))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_hold_jump_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
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
             (Econst_int (Int.repr 205521409) tint) ::
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
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 2) tint) tint)
                           (Econst_int (Int.repr 4) tint) tint)
                         (Econst_int (Int.repr 8) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _check_common_hold_action_exits (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
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
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr (-2147482232)) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _landing_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 64) tint) ::
             (Econst_int (Int.repr 134218247) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_freefall_land_stop := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'9, tint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tushort) ::
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
             (Econst_int (Int.repr 205521409) tint) ::
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
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 2) tint) tint)
                           (Econst_int (Int.repr 4) tint) tint)
                         (Econst_int (Int.repr 8) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _check_common_hold_action_exits (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
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
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr (-2147482232)) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _landing_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 66) tint) ::
             (Econst_int (Int.repr 134218247) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_air_throw_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tushort) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 1024) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 131622) tint) ::
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
                     (Econst_int (Int.repr 4) tint) tint)
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
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oadd (Etempvar _t'4 tushort)
                  (Econst_int (Int.repr 1) tint) tint) tushort)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort)
            (Etempvar _t'3 tushort)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
          (Scall None
            (Evar _mario_throw_held_object (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _landing_step (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tint :: tuint :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 82) tint) ::
           (Econst_int (Int.repr 205521409) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_twirl_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'18, tushort) :: (_t'17, tushort) ::
               (_t'16, tshort) :: (_t'15, tshort) :: (_t'14, tshort) ::
               (_t'13, tshort) :: (_t'12, tshort) :: (_t'11, tshort) ::
               (_t'10, tshort) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort)
    (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _t'18
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'17
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
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
        (Scall None
          (Evar _stationary_ground_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 147) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'12
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _angleVel
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'12 tshort)
                             (Econst_int (Int.repr 0) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'16
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
                      (Ebinop Osub (Etempvar _t'16 tshort)
                        (Econst_int (Int.repr 1024) tint) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'15
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _angleVel
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort))
                      (Sifthenelse (Ebinop Olt (Etempvar _t'15 tshort)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _angleVel
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort) (Econst_int (Int.repr 0) tint))
                        Sskip))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _twirlYaw tshort))
                      (Ssequence
                        (Sset _t'14
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
                              (Tstruct _MarioState noattr)) _twirlYaw tshort)
                          (Ebinop Oadd (Etempvar _t'13 tshort)
                            (Etempvar _t'14 tshort) tint))))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioObj
                      (tptr (Tstruct _Object noattr))))
                  (Ssequence
                    (Sset _t'10
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _angle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'11
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _twirlYaw tshort))
                      (Sassign
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
                              (tarray tshort 3))
                            (Econst_int (Int.repr 1) tint) (tptr tshort))
                          tshort)
                        (Ebinop Oadd (Etempvar _t'10 tshort)
                          (Etempvar _t'11 tshort) tint))))))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'3)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Sset _t'7
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _angleVel
                                (tarray tshort 3))
                              (Econst_int (Int.repr 1) tint) (tptr tshort))
                            tshort))
                        (Sset _t'4
                          (Ecast
                            (Ebinop Oeq (Etempvar _t'7 tshort)
                              (Econst_int (Int.repr 0) tint) tint) tbool)))
                      (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
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
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _twirlYaw
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
                            (Ebinop Oadd (Etempvar _t'5 tshort)
                              (Etempvar _t'6 tshort) tint))))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 205521409) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil)))
                    Sskip))
                (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))
|}.

Definition f_act_ground_pound_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _actionState tushort)
    (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                     (Econst_int (Int.repr 1024) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 131622) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'5 tushort)
                       (Econst_int (Int.repr 4) tint) tint)
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
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 8651858) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'3 tuint))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _landing_step (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tint :: tuint :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 58) tint) ::
             (Econst_int (Int.repr 201327166) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_first_person := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_sp1C, tint) :: (_sp1A, tshort) :: (_sp18, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'20, tushort) ::
               (_t'19, (tptr (Tstruct _Camera noattr))) ::
               (_t'18, (tptr (Tstruct _Area noattr))) :: (_t'17, tushort) ::
               (_t'16, (tptr (Tstruct _Camera noattr))) ::
               (_t'15, (tptr (Tstruct _Area noattr))) :: (_t'14, tushort) ::
               (_t'13, tshort) :: (_t'12, tshort) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _PlayerCameraState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sset _sp1C
      (Ebinop One
        (Ebinop Oand (Etempvar _t'20 tushort)
          (Ebinop Oor
            (Ebinop Oor (Econst_int (Int.repr 4) tint)
              (Econst_int (Int.repr 8) tint) tint)
            (Econst_int (Int.repr 1024) tint) tint) tint)
        (Econst_int (Int.repr 0) tint) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Scall None
            (Evar _lower_background_noise (Tfunction (tint :: nil) tvoid
                                            cc_default))
            ((Econst_int (Int.repr 2) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _area
                  (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'19
                  (Efield
                    (Ederef (Etempvar _t'18 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _camera
                    (tptr (Tstruct _Camera noattr))))
                (Scall None
                  (Evar _set_camera_mode (Tfunction
                                           ((tptr (Tstruct _Camera noattr)) ::
                                            tshort :: tshort :: nil) tvoid
                                           cc_default))
                  ((Etempvar _t'19 (tptr (Tstruct _Camera noattr))) ::
                   (Econst_int (Int.repr 6) tint) ::
                   (Econst_int (Int.repr 16) tint) :: nil))))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionState tushort)
              (Econst_int (Int.repr 1) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Eunop Onotbool
                           (Ebinop Oand (Etempvar _t'17 tushort)
                             (Econst_int (Int.repr 16) tint) tint) tint)
              (Sset _t'2 (Econst_int (Int.repr 1) tint))
              (Sset _t'2 (Ecast (Etempvar _sp1C tint) tbool))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Scall None
                (Evar _raise_background_noise (Tfunction (tint :: nil) tvoid
                                                cc_default))
                ((Econst_int (Int.repr 2) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _area
                      (tptr (Tstruct _Area noattr))))
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef
                          (Etempvar _t'15 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Scall None
                      (Evar _set_camera_mode (Tfunction
                                               ((tptr (Tstruct _Camera noattr)) ::
                                                tshort :: tshort :: nil)
                                               tvoid cc_default))
                      ((Etempvar _t'16 (tptr (Tstruct _Camera noattr))) ::
                       (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) ::
                       (Econst_int (Int.repr 1) tint) :: nil))))
                (Ssequence
                  (Scall (Some _t'1)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 205521409) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'1 tuint))))))
            Sskip))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _t'11 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'12 tshort)
                           (Econst_int (Int.repr 47) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'13 (Evar _gCurrSaveFileNum tshort))
                  (Scall (Some _t'5)
                    (Evar _save_file_get_total_star_count (Tfunction
                                                            (tint :: tint ::
                                                             tint :: nil)
                                                            tint cc_default))
                    ((Ebinop Osub (Etempvar _t'13 tshort)
                       (Econst_int (Int.repr 1) tint) tint) ::
                     (Ebinop Osub (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 1) tint) tint) ::
                     (Ebinop Osub (Econst_int (Int.repr 25) tint)
                       (Econst_int (Int.repr 1) tint) tint) :: nil)))
                (Sset _t'4
                  (Ecast
                    (Ebinop Oge (Etempvar _t'5 tint)
                      (Econst_int (Int.repr 10) tint) tint) tbool)))
              (Sset _t'4 (Econst_int (Int.repr 0) tint)))))
        (Sifthenelse (Etempvar _t'4 tint)
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
                        (Ederef
                          (Etempvar _t'9 (tptr (Tstruct _PlayerCameraState noattr)))
                          (Tstruct _PlayerCameraState noattr)) _headRotation
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort))
                (Sset _sp1A (Ecast (Etempvar _t'10 tshort) tshort))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _statusForCamera
                    (tptr (Tstruct _PlayerCameraState noattr))))
                (Ssequence
                  (Sset _t'7
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _t'6 (tptr (Tstruct _PlayerCameraState noattr)))
                            (Tstruct _PlayerCameraState noattr))
                          _headRotation (tarray tshort 3))
                        (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
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
                    (Sset _sp18
                      (Ecast
                        (Ebinop Oadd
                          (Ebinop Odiv
                            (Ebinop Omul (Etempvar _t'7 tshort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (Econst_int (Int.repr 3) tint) tint)
                          (Etempvar _t'8 tshort) tint) tshort)))))
              (Ssequence
                (Sifthenelse (Ebinop Oeq (Etempvar _sp1A tshort)
                               (Eunop Oneg (Econst_int (Int.repr 6144) tint)
                                 tint) tint)
                  (Sifthenelse (Ebinop Olt (Etempvar _sp18 tshort)
                                 (Eunop Oneg
                                   (Econst_int (Int.repr 28671) tint) tint)
                                 tint)
                    (Sset _t'3 (Ecast (Econst_int (Int.repr 1) tint) tbool))
                    (Ssequence
                      (Sset _t'3
                        (Ecast
                          (Ebinop Oge (Etempvar _sp18 tshort)
                            (Econst_int (Int.repr 28672) tint) tint) tbool))
                      (Sset _t'3 (Ecast (Etempvar _t'3 tint) tbool))))
                  (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'3 tint)
                  (Scall None
                    (Evar _level_trigger_warp (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1) tint) :: nil))
                  Sskip))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _stationary_ground_step (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 194) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_check_common_stationary_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'9, tuint) :: (_t'8, tshort) :: (_t'7, tfloat) ::
               (_t'6, tushort) :: (_t'5, tshort) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'7 tfloat)
                     (Ebinop Osub (Etempvar _t'8 tshort)
                       (Econst_int (Int.repr 100) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                           (Econst_int (Int.repr 4901) tint) tint)
              (Scall None
                (Evar _load_level_init_text (Tfunction (tuint :: nil) tvoid
                                              cc_default))
                ((Econst_int (Int.repr 0) tint) :: nil))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _update_mario_sound_and_camera (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_water_plunge_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Etempvar _t'1 tint))))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                     (Econst_int (Int.repr 64) tint) tint)
        (Ssequence
          (Scall None
            (Evar _update_mario_sound_and_camera (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall (Some _t'2)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131897) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint)))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop One (Etempvar _t'4 tuint)
                       (Econst_int (Int.repr 131598) tint) tint)
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _health tshort))
            (Sifthenelse (Ebinop Olt (Etempvar _t'5 tshort)
                           (Econst_int (Int.repr 256) tint) tint)
              (Ssequence
                (Scall None
                  (Evar _update_mario_sound_and_camera (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tvoid
                                                         cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _drop_and_set_mario_action (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: tuint ::
                                                        nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 135953) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tint)))))
              Sskip))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_mario_execute_stationary_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'39, tint) :: (_t'38, tint) ::
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
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'42, tuint) :: (_t'41, tushort) ::
               (_t'40, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_stationary_cancels (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _mario_update_quicksand (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tfloat :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'2 tuint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'42
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sswitch (Etempvar _t'42 tuint)
          (LScons (Some 205521409)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _act_idle (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'3 tint)))
              Sbreak)
            (LScons (Some 205521410)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _act_start_sleeping (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'4 tint)))
                Sbreak)
              (LScons (Some 201327107)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _act_sleeping (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'5 tint)))
                  Sbreak)
                (LScons (Some 201327108)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _act_waking_up (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'6 tint)))
                    Sbreak)
                  (LScons (Some 205521413)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _act_panting (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'7 tint)))
                      Sbreak)
                    (LScons (Some 134218246)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _act_hold_panting_unused (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'8 tint)))
                        Sbreak)
                      (LScons (Some 134218247)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'9)
                              (Evar _act_hold_idle (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'9 tint)))
                          Sbreak)
                        (LScons (Some 134218248)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'10)
                                (Evar _act_hold_heavy_idle (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'10 tint)))
                            Sbreak)
                          (LScons (Some 131597)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'11)
                                  (Evar _act_in_quicksand (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'11 tint)))
                              Sbreak)
                            (LScons (Some 205521417)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'12)
                                    (Evar _act_standing_against_wall 
                                    (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'12 tint)))
                                Sbreak)
                              (LScons (Some 205521418)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'13)
                                      (Evar _act_coughing (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'13 tint)))
                                  Sbreak)
                                (LScons (Some 205521419)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'14)
                                        (Evar _act_shivering (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tint
                                                               cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'14 tint)))
                                    Sbreak)
                                  (LScons (Some 201359904)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'15)
                                          (Evar _act_crouching (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tint
                                                                 cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'15 tint)))
                                      Sbreak)
                                    (LScons (Some 201359905)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'16)
                                            (Evar _act_start_crouching 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'16 tint)))
                                        Sbreak)
                                      (LScons (Some 201359906)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'17)
                                              (Evar _act_stop_crouching 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'17 tint)))
                                          Sbreak)
                                        (LScons (Some 201359907)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'18)
                                                (Evar _act_start_crawling 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'18 tint)))
                                            Sbreak)
                                          (LScons (Some 201359908)
                                            (Ssequence
                                              (Ssequence
                                                (Scall (Some _t'19)
                                                  (Evar _act_stop_crawling 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   nil))
                                                (Sset _cancel
                                                  (Etempvar _t'19 tint)))
                                              Sbreak)
                                            (LScons (Some 134218277)
                                              (Ssequence
                                                (Ssequence
                                                  (Scall (Some _t'20)
                                                    (Evar _act_slide_kick_slide_stop 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     nil))
                                                  (Sset _cancel
                                                    (Etempvar _t'20 tint)))
                                                Sbreak)
                                              (LScons (Some 131622)
                                                (Ssequence
                                                  (Ssequence
                                                    (Scall (Some _t'21)
                                                      (Evar _act_shockwave_bounce 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                       nil))
                                                    (Sset _cancel
                                                      (Etempvar _t'21 tint)))
                                                  Sbreak)
                                                (LScons (Some 201327143)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Scall (Some _t'22)
                                                        (Evar _act_first_person 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         nil))
                                                      (Sset _cancel
                                                        (Etempvar _t'22 tint)))
                                                    Sbreak)
                                                  (LScons (Some 201327152)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Scall (Some _t'23)
                                                          (Evar _act_jump_land_stop 
                                                          (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                           nil))
                                                        (Sset _cancel
                                                          (Etempvar _t'23 tint)))
                                                      Sbreak)
                                                    (LScons (Some 201327153)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Scall (Some _t'24)
                                                            (Evar _act_double_jump_land_stop 
                                                            (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                             nil))
                                                          (Sset _cancel
                                                            (Etempvar _t'24 tint)))
                                                        Sbreak)
                                                      (LScons (Some 201327154)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Scall (Some _t'25)
                                                              (Evar _act_freefall_land_stop 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                               nil))
                                                            (Sset _cancel
                                                              (Etempvar _t'25 tint)))
                                                          Sbreak)
                                                        (LScons (Some 201327155)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Scall (Some _t'26)
                                                                (Evar _act_side_flip_land_stop 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                 nil))
                                                              (Sset _cancel
                                                                (Etempvar _t'26 tint)))
                                                            Sbreak)
                                                          (LScons (Some 134218292)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'27)
                                                                  (Evar _act_hold_jump_land_stop 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                   nil))
                                                                (Sset _cancel
                                                                  (Etempvar _t'27 tint)))
                                                              Sbreak)
                                                            (LScons (Some 134218293)
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'28)
                                                                    (Evar _act_hold_freefall_land_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                  (Sset _cancel
                                                                    (Etempvar _t'28 tint)))
                                                                Sbreak)
                                                              (LScons (Some 2147486262)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'29)
                                                                    (Evar _act_air_throw_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'29 tint)))
                                                                  Sbreak)
                                                                (LScons (Some 134218297)
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'30)
                                                                    (Evar _act_lava_boost_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'30 tint)))
                                                                    Sbreak)
                                                                  (LScons (Some 411042360)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'31)
                                                                    (Evar _act_twirl_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'31 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 134218298)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'32)
                                                                    (Evar _act_triple_jump_land_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'32 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 134218287)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'33)
                                                                    (Evar _act_backflip_land_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'33 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 134218299)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'34)
                                                                    (Evar _act_long_jump_land_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'34 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 8389180)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'35)
                                                                    (Evar _act_ground_pound_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'35 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 201327165)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'36)
                                                                    (Evar _act_braking_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'36 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 201327166)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'37)
                                                                    (Evar _act_butt_slide_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'37 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 134218815)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'38)
                                                                    (Evar _act_hold_butt_slide_stop 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'38 tint)))
                                                                    Sbreak)
                                                                    LSnil))))))))))))))))))))))))))))))))))))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Eunop Onotbool (Etempvar _cancel tint) tint)
            (Ssequence
              (Sset _t'41
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sset _t'39
                (Ecast
                  (Ebinop Oand (Etempvar _t'41 tushort)
                    (Econst_int (Int.repr 512) tint) tint) tbool)))
            (Sset _t'39 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'39 tint)
            (Ssequence
              (Sset _t'40
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _particleFlags tuint)
                (Ebinop Oor (Etempvar _t'40 tuint)
                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                    (Econst_int (Int.repr 7) tint) tint) tuint)))
            Sskip))
        (Sreturn (Some (Etempvar _cancel tint)))))))
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
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_set_camera_mode,
   Gfun(External (EF_external "set_camera_mode"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) :: (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gAudioRandom, Gvar v_gAudioRandom) ::
 (_play_sound,
   Gfun(External (EF_external "play_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tint :: (tptr tfloat) :: nil) tvoid
     cc_default)) ::
 (_stop_sound,
   Gfun(External (EF_external "stop_sound"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xvoid
                     cc_default)) (tuint :: (tptr tfloat) :: nil) tvoid
     cc_default)) :: (_bhvJumpingBox, Gvar v_bhvJumpingBox) ::
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
 (_mario_drop_held_object,
   Gfun(External (EF_external "mario_drop_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_throw_held_object,
   Gfun(External (EF_external "mario_throw_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
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
 (_play_mario_heavy_landing_sound,
   Gfun(External (EF_external "play_mario_heavy_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_find_floor_height_relative_polar,
   Gfun(External (EF_external "find_floor_height_relative_polar"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tshort :: tfloat :: nil) tfloat
     cc_default)) ::
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
 (_set_jump_from_landing,
   Gfun(External (EF_external "set_jump_from_landing"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_jumping_action,
   Gfun(External (EF_external "set_jumping_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tint
     cc_default)) ::
 (_drop_and_set_mario_action,
   Gfun(External (EF_external "drop_and_set_mario_action"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tint
     cc_default)) ::
 (_hurt_and_set_mario_action,
   Gfun(External (EF_external "hurt_and_set_mario_action"
                   (mksignature
                     (AST.Xptr :: AST.Xint :: AST.Xint :: AST.Xint16signed ::
                      nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: tshort :: nil)
     tint cc_default)) ::
 (_check_common_action_exits,
   Gfun(External (EF_external "check_common_action_exits"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_check_common_hold_action_exits,
   Gfun(External (EF_external "check_common_hold_action_exits"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_update_quicksand,
   Gfun(External (EF_external "mario_update_quicksand"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tuint
     cc_default)) ::
 (_mario_push_off_steep_floor,
   Gfun(External (EF_external "mario_push_off_steep_floor"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tuint
     cc_default)) ::
 (_stationary_ground_step,
   Gfun(External (EF_external "stationary_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_save_file_get_total_star_count,
   Gfun(External (EF_external "save_file_get_total_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tint :: tint :: tint :: nil) tint
     cc_default)) ::
 (_raise_background_noise,
   Gfun(External (EF_external "raise_background_noise"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_lower_background_noise,
   Gfun(External (EF_external "lower_background_noise"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_check_common_idle_cancels, Gfun(Internal f_check_common_idle_cancels)) ::
 (_check_common_hold_idle_cancels, Gfun(Internal f_check_common_hold_idle_cancels)) ::
 (_act_idle, Gfun(Internal f_act_idle)) ::
 (_play_anim_sound, Gfun(Internal f_play_anim_sound)) ::
 (_act_start_sleeping, Gfun(Internal f_act_start_sleeping)) ::
 (_act_sleeping, Gfun(Internal f_act_sleeping)) ::
 (_act_waking_up, Gfun(Internal f_act_waking_up)) ::
 (_act_shivering, Gfun(Internal f_act_shivering)) ::
 (_act_coughing, Gfun(Internal f_act_coughing)) ::
 (_act_hold_idle, Gfun(Internal f_act_hold_idle)) ::
 (_act_hold_heavy_idle, Gfun(Internal f_act_hold_heavy_idle)) ::
 (_act_standing_against_wall, Gfun(Internal f_act_standing_against_wall)) ::
 (_act_in_quicksand, Gfun(Internal f_act_in_quicksand)) ::
 (_act_crouching, Gfun(Internal f_act_crouching)) ::
 (_act_panting, Gfun(Internal f_act_panting)) ::
 (_act_hold_panting_unused, Gfun(Internal f_act_hold_panting_unused)) ::
 (_stopping_step, Gfun(Internal f_stopping_step)) ::
 (_act_braking_stop, Gfun(Internal f_act_braking_stop)) ::
 (_act_butt_slide_stop, Gfun(Internal f_act_butt_slide_stop)) ::
 (_act_hold_butt_slide_stop, Gfun(Internal f_act_hold_butt_slide_stop)) ::
 (_act_slide_kick_slide_stop, Gfun(Internal f_act_slide_kick_slide_stop)) ::
 (_act_start_crouching, Gfun(Internal f_act_start_crouching)) ::
 (_act_stop_crouching, Gfun(Internal f_act_stop_crouching)) ::
 (_act_start_crawling, Gfun(Internal f_act_start_crawling)) ::
 (_act_stop_crawling, Gfun(Internal f_act_stop_crawling)) ::
 (_act_shockwave_bounce, Gfun(Internal f_act_shockwave_bounce)) ::
 (_landing_step, Gfun(Internal f_landing_step)) ::
 (_check_common_landing_cancels, Gfun(Internal f_check_common_landing_cancels)) ::
 (_act_jump_land_stop, Gfun(Internal f_act_jump_land_stop)) ::
 (_act_double_jump_land_stop, Gfun(Internal f_act_double_jump_land_stop)) ::
 (_act_side_flip_land_stop, Gfun(Internal f_act_side_flip_land_stop)) ::
 (_act_freefall_land_stop, Gfun(Internal f_act_freefall_land_stop)) ::
 (_act_triple_jump_land_stop, Gfun(Internal f_act_triple_jump_land_stop)) ::
 (_act_backflip_land_stop, Gfun(Internal f_act_backflip_land_stop)) ::
 (_act_lava_boost_land, Gfun(Internal f_act_lava_boost_land)) ::
 (_act_long_jump_land_stop, Gfun(Internal f_act_long_jump_land_stop)) ::
 (_act_hold_jump_land_stop, Gfun(Internal f_act_hold_jump_land_stop)) ::
 (_act_hold_freefall_land_stop, Gfun(Internal f_act_hold_freefall_land_stop)) ::
 (_act_air_throw_land, Gfun(Internal f_act_air_throw_land)) ::
 (_act_twirl_land, Gfun(Internal f_act_twirl_land)) ::
 (_act_ground_pound_land, Gfun(Internal f_act_ground_pound_land)) ::
 (_act_first_person, Gfun(Internal f_act_first_person)) ::
 (_check_common_stationary_cancels, Gfun(Internal f_check_common_stationary_cancels)) ::
 (_mario_execute_stationary_action, Gfun(Internal f_mario_execute_stationary_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_stationary_action :: _check_common_stationary_cancels ::
 _act_first_person :: _act_ground_pound_land :: _act_twirl_land ::
 _act_air_throw_land :: _act_hold_freefall_land_stop ::
 _act_hold_jump_land_stop :: _act_long_jump_land_stop ::
 _act_lava_boost_land :: _act_backflip_land_stop ::
 _act_triple_jump_land_stop :: _act_freefall_land_stop ::
 _act_side_flip_land_stop :: _act_double_jump_land_stop ::
 _act_jump_land_stop :: _check_common_landing_cancels :: _landing_step ::
 _act_shockwave_bounce :: _act_stop_crawling :: _act_start_crawling ::
 _act_stop_crouching :: _act_start_crouching :: _act_slide_kick_slide_stop ::
 _act_hold_butt_slide_stop :: _act_butt_slide_stop :: _act_braking_stop ::
 _stopping_step :: _act_hold_panting_unused :: _act_panting ::
 _act_crouching :: _act_in_quicksand :: _act_standing_against_wall ::
 _act_hold_heavy_idle :: _act_hold_idle :: _act_coughing :: _act_shivering ::
 _act_waking_up :: _act_sleeping :: _act_start_sleeping ::
 _play_anim_sound :: _act_idle :: _check_common_hold_idle_cancels ::
 _check_common_idle_cancels :: _lower_background_noise ::
 _raise_background_noise :: _save_file_get_total_star_count ::
 _stationary_ground_step :: _mario_push_off_steep_floor ::
 _mario_update_quicksand :: _set_water_plunge_action ::
 _check_common_hold_action_exits :: _check_common_action_exits ::
 _hurt_and_set_mario_action :: _drop_and_set_mario_action ::
 _set_jumping_action :: _set_jump_from_landing :: _set_mario_action ::
 _update_mario_sound_and_camera :: _find_floor_height_relative_polar ::
 _mario_set_forward_vel :: _play_mario_heavy_landing_sound ::
 _play_mario_landing_sound :: _play_sound_if_no_flag ::
 _set_mario_animation :: _is_anim_past_end :: _is_anim_at_end ::
 _level_trigger_warp :: _load_level_init_text :: _mario_throw_held_object ::
 _mario_drop_held_object :: _vec3s_set :: _vec3f_set :: _vec3f_copy ::
 _gSineTable :: _bhvJumpingBox :: _stop_sound :: _play_sound ::
 _gAudioRandom :: _gCurrSaveFileNum :: _set_camera_mode ::
 _segmented_to_virtual :: ___builtin_debug :: ___builtin_write32_reversed ::
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


