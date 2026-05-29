(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario.c
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
  Definition source_file := "vendor/sm64/src/game/mario.c".
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
Definition _HudDisplay : ident := $"HudDisplay".
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
Definition _WallCollisionData : ident := $"WallCollisionData".
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
Definition ___stringlit_1 : ident := $"__stringlit_1".
Definition ___stringlit_2 : ident := $"__stringlit_2".
Definition ___stringlit_3 : ident := $"__stringlit_3".
Definition _absForwardVel : ident := $"absForwardVel".
Definition _accel : ident := $"accel".
Definition _acceleratedFrame : ident := $"acceleratedFrame".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionSound : ident := $"actionSound".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _adjust_sound_for_speed : ident := $"adjust_sound_for_speed".
Definition _angle : ident := $"angle".
Definition _angleFromMario : ident := $"angleFromMario".
Definition _angleTemp : ident := $"angleTemp".
Definition _angleVel : ident := $"angleVel".
Definition _anim : ident := $"anim".
Definition _animAccel : ident := $"animAccel".
Definition _animFrame : ident := $"animFrame".
Definition _animFrameAccelAssist : ident := $"animFrameAccelAssist".
Definition _animID : ident := $"animID".
Definition _animIndex : ident := $"animIndex".
Definition _animInfo : ident := $"animInfo".
Definition _animList : ident := $"animList".
Definition _animTimer : ident := $"animTimer".
Definition _animValues : ident := $"animValues".
Definition _animYTrans : ident := $"animYTrans".
Definition _animYTransDivisor : ident := $"animYTransDivisor".
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
Definition _backwardFloorY : ident := $"backwardFloorY".
Definition _backwardYDelta : ident := $"backwardYDelta".
Definition _behavior : ident := $"behavior".
Definition _behaviorArg : ident := $"behaviorArg".
Definition _behaviorScript : ident := $"behaviorScript".
Definition _bhvDelayTimer : ident := $"bhvDelayTimer".
Definition _bhvNormalCap : ident := $"bhvNormalCap".
Definition _bhvStack : ident := $"bhvStack".
Definition _bhvStackIndex : ident := $"bhvStackIndex".
Definition _bodyState : ident := $"bodyState".
Definition _bufTarget : ident := $"bufTarget".
Definition _button : ident := $"button".
Definition _buttonDown : ident := $"buttonDown".
Definition _buttonPressed : ident := $"buttonPressed".
Definition _c : ident := $"c".
Definition _camPreset : ident := $"camPreset".
Definition _camera : ident := $"camera".
Definition _cameraEvent : ident := $"cameraEvent".
Definition _cameraToObject : ident := $"cameraToObject".
Definition _capObject : ident := $"capObject".
Definition _capPos : ident := $"capPos".
Definition _capState : ident := $"capState".
Definition _capTimer : ident := $"capTimer".
Definition _ceil : ident := $"ceil".
Definition _ceilHeight : ident := $"ceilHeight".
Definition _ceilToFloorDist : ident := $"ceilToFloorDist".
Definition _check_common_action_exits : ident := $"check_common_action_exits".
Definition _check_common_hold_action_exits : ident := $"check_common_hold_action_exits".
Definition _children : ident := $"children".
Definition _coins : ident := $"coins".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currAction : ident := $"currAction".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _debug_print_speed_action_normal : ident := $"debug_print_speed_action_normal".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _distFromMario : ident := $"distFromMario".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _dx : ident := $"dx".
Definition _dz : ident := $"dz".
Definition _errnum : ident := $"errnum".
Definition _execute_mario_action : ident := $"execute_mario_action".
Definition _eyeState : ident := $"eyeState".
Definition _f32_find_wall_collision : ident := $"f32_find_wall_collision".
Definition _faceAngle : ident := $"faceAngle".
Definition _faceAngleTemp : ident := $"faceAngleTemp".
Definition _faceAngleYaw : ident := $"faceAngleYaw".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fadeout_cap_music : ident := $"fadeout_cap_music".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_ceil : ident := $"find_ceil".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_height_relative_polar : ident := $"find_floor_height_relative_polar".
Definition _find_floor_slope : ident := $"find_floor_slope".
Definition _find_mario_anim_flags_and_translation : ident := $"find_mario_anim_flags_and_translation".
Definition _find_poison_gas_level : ident := $"find_poison_gas_level".
Definition _find_wall_collisions : ident := $"find_wall_collisions".
Definition _find_water_level : ident := $"find_water_level".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorClass : ident := $"floorClass".
Definition _floorHeight : ident := $"floorHeight".
Definition _floorSoundType : ident := $"floorSoundType".
Definition _floorType : ident := $"floorType".
Definition _floorY : ident := $"floorY".
Definition _floor_nY : ident := $"floor_nY".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forwardFloorY : ident := $"forwardFloorY".
Definition _forwardVel : ident := $"forwardVel".
Definition _forwardYDelta : ident := $"forwardYDelta".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _gAudioRandom : ident := $"gAudioRandom".
Definition _gBodyStates : ident := $"gBodyStates".
Definition _gCameraMovementFlags : ident := $"gCameraMovementFlags".
Definition _gControllers : ident := $"gControllers".
Definition _gCurrLevelNum : ident := $"gCurrLevelNum".
Definition _gCurrSaveFileNum : ident := $"gCurrSaveFileNum".
Definition _gCurrentArea : ident := $"gCurrentArea".
Definition _gDebugLevelSelect : ident := $"gDebugLevelSelect".
Definition _gGlobalSoundSource : ident := $"gGlobalSoundSource".
Definition _gGlobalTimer : ident := $"gGlobalTimer".
Definition _gHudDisplay : ident := $"gHudDisplay".
Definition _gMarioAnimsBuf : ident := $"gMarioAnimsBuf".
Definition _gMarioObject : ident := $"gMarioObject".
Definition _gMarioSpawnInfo : ident := $"gMarioSpawnInfo".
Definition _gMarioState : ident := $"gMarioState".
Definition _gPlayerCameraState : ident := $"gPlayerCameraState".
Definition _gPlayerSpawnInfos : ident := $"gPlayerSpawnInfos".
Definition _gShowDebugText : ident := $"gShowDebugText".
Definition _gSineTable : ident := $"gSineTable".
Definition _gasLevel : ident := $"gasLevel".
Definition _geo_update_animation_frame : ident := $"geo_update_animation_frame".
Definition _get_additive_y_vel_for_jumps : ident := $"get_additive_y_vel_for_jumps".
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
Definition _heightBelowWater : ident := $"heightBelowWater".
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
Definition _inLoop : ident := $"inLoop".
Definition _index : ident := $"index".
Definition _init_mario : ident := $"init_mario".
Definition _init_mario_from_save_file : ident := $"init_mario_from_save_file".
Definition _initialVelY : ident := $"initialVelY".
Definition _input : ident := $"input".
Definition _instantWarps : ident := $"instantWarps".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _isPastFrame : ident := $"isPastFrame".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_end : ident := $"is_anim_past_end".
Definition _is_anim_past_frame : ident := $"is_anim_past_frame".
Definition _keys : ident := $"keys".
Definition _length : ident := $"length".
Definition _level_trigger_warp : ident := $"level_trigger_warp".
Definition _lives : ident := $"lives".
Definition _load_patchable_table : ident := $"load_patchable_table".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _mag : ident := $"mag".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _marioSound : ident := $"marioSound".
Definition _mario_execute_airborne_action : ident := $"mario_execute_airborne_action".
Definition _mario_execute_automatic_action : ident := $"mario_execute_automatic_action".
Definition _mario_execute_cutscene_action : ident := $"mario_execute_cutscene_action".
Definition _mario_execute_moving_action : ident := $"mario_execute_moving_action".
Definition _mario_execute_object_action : ident := $"mario_execute_object_action".
Definition _mario_execute_stationary_action : ident := $"mario_execute_stationary_action".
Definition _mario_execute_submerged_action : ident := $"mario_execute_submerged_action".
Definition _mario_facing_downhill : ident := $"mario_facing_downhill".
Definition _mario_floor_is_slippery : ident := $"mario_floor_is_slippery".
Definition _mario_floor_is_slope : ident := $"mario_floor_is_slope".
Definition _mario_floor_is_steep : ident := $"mario_floor_is_steep".
Definition _mario_get_floor_class : ident := $"mario_get_floor_class".
Definition _mario_get_terrain_sound_addend : ident := $"mario_get_terrain_sound_addend".
Definition _mario_handle_special_floors : ident := $"mario_handle_special_floors".
Definition _mario_process_interactions : ident := $"mario_process_interactions".
Definition _mario_reset_bodystate : ident := $"mario_reset_bodystate".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_stop_riding_and_holding : ident := $"mario_stop_riding_and_holding".
Definition _mario_update_hitbox_and_cap_model : ident := $"mario_update_hitbox_and_cap_model".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _multiplier : ident := $"multiplier".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normY : ident := $"normY".
Definition _normal : ident := $"normal".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _numWalls : ident := $"numWalls".
Definition _o : ident := $"o".
Definition _obj : ident := $"obj".
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
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_infinite_stairs_music : ident := $"play_infinite_stairs_music".
Definition _play_mario_action_sound : ident := $"play_mario_action_sound".
Definition _play_mario_heavy_landing_sound : ident := $"play_mario_heavy_landing_sound".
Definition _play_mario_heavy_landing_sound_once : ident := $"play_mario_heavy_landing_sound_once".
Definition _play_mario_jump_sound : ident := $"play_mario_jump_sound".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_mario_landing_sound_once : ident := $"play_mario_landing_sound_once".
Definition _play_mario_sound : ident := $"play_mario_sound".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_and_spawn_particles : ident := $"play_sound_and_spawn_particles".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _pos : ident := $"pos".
Definition _posX : ident := $"posX".
Definition _posY : ident := $"posY".
Definition _posZ : ident := $"posZ".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _print_text_fmt_int : ident := $"print_text_fmt_int".
Definition _punchState : ident := $"punchState".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _radius : ident := $"radius".
Definition _raise_background_noise : ident := $"raise_background_noise".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _resolve_and_return_wall_collisions : ident := $"resolve_and_return_wall_collisions".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _result : ident := $"result".
Definition _ret : ident := $"ret".
Definition _retrieve_animation_index : ident := $"retrieve_animation_index".
Definition _return_mario_anim_y_translation : ident := $"return_mario_anim_y_translation".
Definition _riddenObj : ident := $"riddenObj".
Definition _roll : ident := $"roll".
Definition _room : ident := $"room".
Definition _s : ident := $"s".
Definition _sCapFlickerFrames : ident := $"sCapFlickerFrames".
Definition _sSquishScaleOverTime : ident := $"sSquishScaleOverTime".
Definition _sTerrainSounds : ident := $"sTerrainSounds".
Definition _save_file_get_cap_pos : ident := $"save_file_get_cap_pos".
Definition _save_file_get_flags : ident := $"save_file_get_flags".
Definition _save_file_get_total_star_count : ident := $"save_file_get_total_star_count".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _set_anim_to_frame : ident := $"set_anim_to_frame".
Definition _set_camera_mode : ident := $"set_camera_mode".
Definition _set_jump_from_landing : ident := $"set_jump_from_landing".
Definition _set_jumping_action : ident := $"set_jumping_action".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_action_airborne : ident := $"set_mario_action_airborne".
Definition _set_mario_action_cutscene : ident := $"set_mario_action_cutscene".
Definition _set_mario_action_moving : ident := $"set_mario_action_moving".
Definition _set_mario_action_submerged : ident := $"set_mario_action_submerged".
Definition _set_mario_anim_with_accel : ident := $"set_mario_anim_with_accel".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_mario_y_vel_based_on_fspeed : ident := $"set_mario_y_vel_based_on_fspeed".
Definition _set_sound_moving_speed : ident := $"set_sound_moving_speed".
Definition _set_steep_jump_action : ident := $"set_steep_jump_action".
Definition _set_submerged_cam_preset_and_spawn_bubbles : ident := $"set_submerged_cam_preset_and_spawn_bubbles".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _sink_mario_in_quicksand : ident := $"sink_mario_in_quicksand".
Definition _size : ident := $"size".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _soundBits : ident := $"soundBits".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _spawn_object : ident := $"spawn_object".
Definition _spawn_wind_particles : ident := $"spawn_wind_particles".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _squish_mario_model : ident := $"squish_mario_model".
Definition _srcAddr : ident := $"srcAddr".
Definition _stars : ident := $"stars".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _steepness : ident := $"steepness".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stop_cap_music : ident := $"stop_cap_music".
Definition _strength : ident := $"strength".
Definition _stub_mario_step_1 : ident := $"stub_mario_step_1".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _targetAnim : ident := $"targetAnim".
Definition _targetAnimID : ident := $"targetAnimID".
Definition _terrainData : ident := $"terrainData".
Definition _terrainIsSnow : ident := $"terrainIsSnow".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _timer : ident := $"timer".
Definition _torsoAngle : ident := $"torsoAngle".
Definition _transform : ident := $"transform".
Definition _transition_submerged_to_walking : ident := $"transition_submerged_to_walking".
Definition _translation : ident := $"translation".
Definition _turnYaw : ident := $"turnYaw".
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
Definition _unused80339F10 : ident := $"unused80339F10".
Definition _unused80339F1C : ident := $"unused80339F1C".
Definition _unusedBoneCount : ident := $"unusedBoneCount".
Definition _unusedVec1 : ident := $"unusedVec1".
Definition _update_and_return_cap_flags : ident := $"update_and_return_cap_flags".
Definition _update_mario_button_inputs : ident := $"update_mario_button_inputs".
Definition _update_mario_geometry_inputs : ident := $"update_mario_geometry_inputs".
Definition _update_mario_health : ident := $"update_mario_health".
Definition _update_mario_info_for_cam : ident := $"update_mario_info_for_cam".
Definition _update_mario_inputs : ident := $"update_mario_inputs".
Definition _update_mario_joystick_inputs : ident := $"update_mario_joystick_inputs".
Definition _update_mario_pos_for_anim : ident := $"update_mario_pos_for_anim".
Definition _update_mario_sound_and_camera : ident := $"update_mario_sound_and_camera".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vec3f_find_ceil : ident := $"vec3f_find_ceil".
Definition _vec3f_set : ident := $"vec3f_set".
Definition _vec3s_copy : ident := $"vec3s_copy".
Definition _vec3s_set : ident := $"vec3s_set".
Definition _vec3s_to_vec3f : ident := $"vec3s_to_vec3f".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _views : ident := $"views".
Definition _wall : ident := $"wall".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _walls : ident := $"walls".
Definition _warpNodes : ident := $"warpNodes".
Definition _waterLevel : ident := $"waterLevel".
Definition _waveParticleType : ident := $"waveParticleType".
Definition _wedges : ident := $"wedges".
Definition _whirlpools : ident := $"whirlpools".
Definition _width : ident := $"width".
Definition _wingFlutter : ident := $"wingFlutter".
Definition _x : ident := $"x".
Definition _y : ident := $"y".
Definition _yaw : ident := $"yaw".
Definition _yawOffset : ident := $"yawOffset".
Definition _z : ident := $"z".
Definition _t'1 : ident := 128%positive.
Definition _t'10 : ident := 137%positive.
Definition _t'100 : ident := 227%positive.
Definition _t'101 : ident := 228%positive.
Definition _t'102 : ident := 229%positive.
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

Definition v___stringlit_3 := {|
  gvar_info := (tarray tschar 7);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 84) ::
                Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 120) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_2 := {|
  gvar_info := (tarray tschar 7);
  gvar_init := (Init_int8 (Int.repr 83) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 68) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v___stringlit_1 := {|
  gvar_info := (tarray tschar 7);
  gvar_init := (Init_int8 (Int.repr 65) :: Init_int8 (Int.repr 78) ::
                Init_int8 (Int.repr 71) :: Init_int8 (Int.repr 32) ::
                Init_int8 (Int.repr 37) :: Init_int8 (Int.repr 100) ::
                Init_int8 (Int.repr 0) :: nil);
  gvar_readonly := true;
  gvar_volatile := false
|}.

Definition v_gPlayerCameraState := {|
  gvar_info := (tarray (Tstruct _PlayerCameraState noattr) 2);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gCameraMovementFlags := {|
  gvar_info := tshort;
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gPlayerSpawnInfos := {|
  gvar_info := (tarray (Tstruct _SpawnInfo noattr) 0);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioSpawnInfo := {|
  gvar_info := (tptr (Tstruct _SpawnInfo noattr));
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

Definition v_gCurrSaveFileNum := {|
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

Definition v_bhvNormalCap := {|
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

Definition v_gControllers := {|
  gvar_info := (tarray (Tstruct _Controller noattr) 3);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gMarioAnimsBuf := {|
  gvar_info := (Tstruct _DmaHandlerList noattr);
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

Definition v_gMarioState := {|
  gvar_info := (tptr (Tstruct _MarioState noattr));
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gHudDisplay := {|
  gvar_info := (Tstruct _HudDisplay noattr);
  gvar_init := nil;
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_gDebugLevelSelect := {|
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

Definition v_gBodyStates := {|
  gvar_info := (tarray (Tstruct _MarioBodyState noattr) 2);
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

Definition v_unused80339F10 := {|
  gvar_info := tuint;
  gvar_init := (Init_space 4 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_unused80339F1C := {|
  gvar_info := (tarray tuchar 20);
  gvar_init := (Init_space 20 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_is_anim_at_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Animation noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _o
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'1
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _animInfo
          (Tstruct _AnimInfo noattr)) _animFrame tshort))
    (Ssequence
      (Sset _t'2
        (Efield
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _curAnim
          (tptr (Tstruct _Animation noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _Animation noattr)))
              (Tstruct _Animation noattr)) _loopEnd tshort))
        (Sreturn (Some (Ebinop Oeq
                         (Ebinop Oadd (Etempvar _t'1 tshort)
                           (Econst_int (Int.repr 1) tint) tint)
                         (Etempvar _t'3 tshort) tint)))))))
|}.

Definition f_is_anim_past_end := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) :: (_t'3, tshort) ::
               (_t'2, (tptr (Tstruct _Animation noattr))) ::
               (_t'1, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _o
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _t'1
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _animInfo
          (Tstruct _AnimInfo noattr)) _animFrame tshort))
    (Ssequence
      (Sset _t'2
        (Efield
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) _curAnim
          (tptr (Tstruct _Animation noattr))))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _t'2 (tptr (Tstruct _Animation noattr)))
              (Tstruct _Animation noattr)) _loopEnd tshort))
        (Sreturn (Some (Ebinop Oge (Etempvar _t'1 tshort)
                         (Ebinop Osub (Etempvar _t'3 tshort)
                           (Econst_int (Int.repr 2) tint) tint) tint)))))))
|}.

Definition f_set_mario_animation := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_targetAnimID, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) ::
               (_targetAnim, (tptr (Tstruct _Animation noattr))) ::
               (_t'1, tint) ::
               (_t'13, (tptr (Tstruct _DmaHandlerList noattr))) ::
               (_t'12, (tptr (Tstruct _DmaHandlerList noattr))) ::
               (_t'11, (tptr tshort)) :: (_t'10, (tptr tushort)) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _o
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _animList
          (tptr (Tstruct _DmaHandlerList noattr))))
      (Sset _targetAnim
        (Efield
          (Ederef (Etempvar _t'13 (tptr (Tstruct _DmaHandlerList noattr)))
            (Tstruct _DmaHandlerList noattr)) _bufTarget (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _animList
              (tptr (Tstruct _DmaHandlerList noattr))))
          (Scall (Some _t'1)
            (Evar _load_patchable_table (Tfunction
                                          ((tptr (Tstruct _DmaHandlerList noattr)) ::
                                           tint :: nil) tint cc_default))
            ((Etempvar _t'12 (tptr (Tstruct _DmaHandlerList noattr))) ::
             (Etempvar _targetAnimID tint) :: nil)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _values (tptr tshort)))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _values (tptr tshort))
                (Ecast
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                          (tptr tuchar))
                        (Ecast (Etempvar _t'11 (tptr tshort)) tuint)
                        (tptr tuchar)) tuint)
                    (Econst_int (Int.repr 536870911) tint) tuint)
                  (tptr tvoid))))
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _index (tptr tushort)))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _index (tptr tushort))
                (Ecast
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                          (tptr tuchar))
                        (Ecast (Etempvar _t'10 (tptr tushort)) tuint)
                        (tptr tuchar)) tuint)
                    (Econst_int (Int.repr 536870911) tint) tuint)
                  (tptr tvoid)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animID tshort))
          (Sifthenelse (Ebinop One (Etempvar _t'3 tshort)
                         (Etempvar _targetAnimID tint) tint)
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animID tshort)
                (Etempvar _targetAnimID tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _curAnim
                    (tptr (Tstruct _Animation noattr)))
                  (Etempvar _targetAnim (tptr (Tstruct _Animation noattr))))
                (Ssequence
                  (Sassign
                    (Efield
                      (Efield
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _o (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _animInfo
                        (Tstruct _AnimInfo noattr)) _animAccel tint)
                    (Econst_int (Int.repr 0) tint))
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _unkB0 tshort))
                      (Sassign
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _o (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _animYTrans tshort)
                        (Etempvar _t'9 tshort)))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _flags tshort))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'4 tshort)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     tint)
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                (Tstruct _Animation noattr)) _startFrame
                              tshort))
                          (Sassign
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _o (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _animFrame tshort) (Etempvar _t'8 tshort)))
                        (Ssequence
                          (Sset _t'5
                            (Efield
                              (Ederef
                                (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                (Tstruct _Animation noattr)) _flags tshort))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'5 tshort)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) tint)
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                    (Tstruct _Animation noattr)) _startFrame
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _o (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animFrame tshort)
                                (Ebinop Oadd (Etempvar _t'7 tshort)
                                  (Econst_int (Int.repr 1) tint) tint)))
                            (Ssequence
                              (Sset _t'6
                                (Efield
                                  (Ederef
                                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                    (Tstruct _Animation noattr)) _startFrame
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _o (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animFrame tshort)
                                (Ebinop Osub (Etempvar _t'6 tshort)
                                  (Econst_int (Int.repr 1) tint) tint)))))))))))
            Sskip))
        (Ssequence
          (Sset _t'2
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animFrame tshort))
          (Sreturn (Some (Etempvar _t'2 tshort))))))))
|}.

Definition f_set_mario_anim_with_accel := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_targetAnimID, tint) :: (_accel, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) ::
               (_targetAnim, (tptr (Tstruct _Animation noattr))) ::
               (_t'1, tint) ::
               (_t'14, (tptr (Tstruct _DmaHandlerList noattr))) ::
               (_t'13, (tptr (Tstruct _DmaHandlerList noattr))) ::
               (_t'12, (tptr tshort)) :: (_t'11, (tptr tushort)) ::
               (_t'10, tshort) :: (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, tshort) :: (_t'6, tshort) :: (_t'5, tshort) ::
               (_t'4, tint) :: (_t'3, tshort) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _o
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _animList
          (tptr (Tstruct _DmaHandlerList noattr))))
      (Sset _targetAnim
        (Efield
          (Ederef (Etempvar _t'14 (tptr (Tstruct _DmaHandlerList noattr)))
            (Tstruct _DmaHandlerList noattr)) _bufTarget (tptr tvoid))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _animList
              (tptr (Tstruct _DmaHandlerList noattr))))
          (Scall (Some _t'1)
            (Evar _load_patchable_table (Tfunction
                                          ((tptr (Tstruct _DmaHandlerList noattr)) ::
                                           tint :: nil) tint cc_default))
            ((Etempvar _t'13 (tptr (Tstruct _DmaHandlerList noattr))) ::
             (Etempvar _targetAnimID tint) :: nil)))
        (Sifthenelse (Etempvar _t'1 tint)
          (Ssequence
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _values (tptr tshort)))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _values (tptr tshort))
                (Ecast
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                          (tptr tuchar))
                        (Ecast (Etempvar _t'12 (tptr tshort)) tuint)
                        (tptr tuchar)) tuint)
                    (Econst_int (Int.repr 536870911) tint) tuint)
                  (tptr tvoid))))
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _index (tptr tushort)))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _index (tptr tushort))
                (Ecast
                  (Ebinop Oand
                    (Ecast
                      (Ebinop Oadd
                        (Ecast
                          (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                          (tptr tuchar))
                        (Ecast (Etempvar _t'11 (tptr tushort)) tuint)
                        (tptr tuchar)) tuint)
                    (Econst_int (Int.repr 536870911) tint) tuint)
                  (tptr tvoid)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animID tshort))
          (Sifthenelse (Ebinop One (Etempvar _t'3 tshort)
                         (Etempvar _targetAnimID tint) tint)
            (Ssequence
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animID tshort)
                (Etempvar _targetAnimID tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Efield
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _o (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _header
                          (Tstruct _ObjectNode noattr)) _gfx
                        (Tstruct _GraphNodeObject noattr)) _animInfo
                      (Tstruct _AnimInfo noattr)) _curAnim
                    (tptr (Tstruct _Animation noattr)))
                  (Etempvar _targetAnim (tptr (Tstruct _Animation noattr))))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _unkB0 tshort))
                    (Sassign
                      (Efield
                        (Efield
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _o (tptr (Tstruct _Object noattr)))
                                (Tstruct _Object noattr)) _header
                              (Tstruct _ObjectNode noattr)) _gfx
                            (Tstruct _GraphNodeObject noattr)) _animInfo
                          (Tstruct _AnimInfo noattr)) _animYTrans tshort)
                      (Etempvar _t'10 tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'5
                        (Efield
                          (Ederef
                            (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                            (Tstruct _Animation noattr)) _flags tshort))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'5 tshort)
                                     (Ebinop Oshl
                                       (Econst_int (Int.repr 1) tint)
                                       (Econst_int (Int.repr 2) tint) tint)
                                     tint)
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                (Tstruct _Animation noattr)) _startFrame
                              tshort))
                          (Sassign
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _o (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr))
                                _animInfo (Tstruct _AnimInfo noattr))
                              _animFrameAccelAssist tint)
                            (Ebinop Oshl (Etempvar _t'9 tshort)
                              (Econst_int (Int.repr 16) tint) tint)))
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                (Tstruct _Animation noattr)) _flags tshort))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tshort)
                                         (Ebinop Oshl
                                           (Econst_int (Int.repr 1) tint)
                                           (Econst_int (Int.repr 1) tint)
                                           tint) tint)
                            (Ssequence
                              (Sset _t'8
                                (Efield
                                  (Ederef
                                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                    (Tstruct _Animation noattr)) _startFrame
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _o (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animFrameAccelAssist tint)
                                (Ebinop Oadd
                                  (Ebinop Oshl (Etempvar _t'8 tshort)
                                    (Econst_int (Int.repr 16) tint) tint)
                                  (Etempvar _accel tint) tint)))
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _targetAnim (tptr (Tstruct _Animation noattr)))
                                    (Tstruct _Animation noattr)) _startFrame
                                  tshort))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _o (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animFrameAccelAssist tint)
                                (Ebinop Osub
                                  (Ebinop Oshl (Etempvar _t'7 tshort)
                                    (Econst_int (Int.repr 16) tint) tint)
                                  (Etempvar _accel tint) tint)))))))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _o (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                          tint))
                      (Sassign
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _o (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _animInfo
                            (Tstruct _AnimInfo noattr)) _animFrame tshort)
                        (Ebinop Oshr (Etempvar _t'4 tint)
                          (Econst_int (Int.repr 16) tint) tint)))))))
            Sskip))
        (Ssequence
          (Sassign
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animAccel tint)
            (Etempvar _accel tint))
          (Ssequence
            (Sset _t'2
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animFrame tshort))
            (Sreturn (Some (Etempvar _t'2 tshort)))))))))
|}.

Definition f_set_anim_to_frame := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animFrame, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_animInfo, (tptr (Tstruct _AnimInfo noattr))) ::
               (_curAnim, (tptr (Tstruct _Animation noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tshort) :: (_t'2, tshort) ::
               (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Sset _animInfo
      (Eaddrof
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _animInfo
          (Tstruct _AnimInfo noattr)) (tptr (Tstruct _AnimInfo noattr)))))
  (Ssequence
    (Sset _curAnim
      (Efield
        (Ederef (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
          (Tstruct _AnimInfo noattr)) _curAnim
        (tptr (Tstruct _Animation noattr))))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
            (Tstruct _AnimInfo noattr)) _animAccel tint))
      (Sifthenelse (Ebinop One (Etempvar _t'1 tint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                (Tstruct _Animation noattr)) _flags tshort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'3 tshort)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 1) tint) tint) tint)
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef
                    (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animAccel tint))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animFrameAccelAssist tint)
                (Ebinop Oadd
                  (Ebinop Oshl (Etempvar _animFrame tshort)
                    (Econst_int (Int.repr 16) tint) tint)
                  (Etempvar _t'5 tint) tint)))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animAccel tint))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                    (Tstruct _AnimInfo noattr)) _animFrameAccelAssist tint)
                (Ebinop Osub
                  (Ebinop Oshl (Etempvar _animFrame tshort)
                    (Econst_int (Int.repr 16) tint) tint)
                  (Etempvar _t'4 tint) tint)))))
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                (Tstruct _Animation noattr)) _flags tshort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'2 tshort)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 1) tint) tint) tint)
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                  (Tstruct _AnimInfo noattr)) _animFrame tshort)
              (Ebinop Oadd (Etempvar _animFrame tshort)
                (Econst_int (Int.repr 1) tint) tint))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                  (Tstruct _AnimInfo noattr)) _animFrame tshort)
              (Ebinop Osub (Etempvar _animFrame tshort)
                (Econst_int (Int.repr 1) tint) tint))))))))
|}.

Definition f_is_anim_past_frame := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animFrame, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_isPastFrame, tint) :: (_acceleratedFrame, tint) ::
               (_animInfo, (tptr (Tstruct _AnimInfo noattr))) ::
               (_curAnim, (tptr (Tstruct _Animation noattr))) ::
               (_t'2, tint) :: (_t'1, tint) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tint) ::
               (_t'12, tint) :: (_t'11, tint) :: (_t'10, tint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _acceleratedFrame
    (Ebinop Oshl (Etempvar _animFrame tshort) (Econst_int (Int.repr 16) tint)
      tint))
  (Ssequence
    (Ssequence
      (Sset _t'14
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Sset _animInfo
        (Eaddrof
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _t'14 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _animInfo
            (Tstruct _AnimInfo noattr)) (tptr (Tstruct _AnimInfo noattr)))))
    (Ssequence
      (Sset _curAnim
        (Efield
          (Ederef (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
            (Tstruct _AnimInfo noattr)) _curAnim
          (tptr (Tstruct _Animation noattr))))
      (Ssequence
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                (Tstruct _AnimInfo noattr)) _animAccel tint))
          (Sifthenelse (Ebinop One (Etempvar _t'3 tint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef
                    (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _flags tshort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'7 tshort)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 1) tint) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Efield
                        (Ederef
                          (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                          (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                        tint))
                    (Sifthenelse (Ebinop Ogt (Etempvar _t'11 tint)
                                   (Etempvar _acceleratedFrame tint) tint)
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                              (Tstruct _AnimInfo noattr))
                            _animFrameAccelAssist tint))
                        (Ssequence
                          (Sset _t'13
                            (Efield
                              (Ederef
                                (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                                (Tstruct _AnimInfo noattr)) _animAccel tint))
                          (Sset _t'1
                            (Ecast
                              (Ebinop Oge (Etempvar _acceleratedFrame tint)
                                (Ebinop Osub (Etempvar _t'12 tint)
                                  (Etempvar _t'13 tint) tint) tint) tbool))))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                  (Sset _isPastFrame (Etempvar _t'1 tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'8
                      (Efield
                        (Ederef
                          (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                          (Tstruct _AnimInfo noattr)) _animFrameAccelAssist
                        tint))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'8 tint)
                                   (Etempvar _acceleratedFrame tint) tint)
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                              (Tstruct _AnimInfo noattr))
                            _animFrameAccelAssist tint))
                        (Ssequence
                          (Sset _t'10
                            (Efield
                              (Ederef
                                (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                                (Tstruct _AnimInfo noattr)) _animAccel tint))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Ole (Etempvar _acceleratedFrame tint)
                                (Ebinop Oadd (Etempvar _t'9 tint)
                                  (Etempvar _t'10 tint) tint) tint) tbool))))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint))))
                  (Sset _isPastFrame (Etempvar _t'2 tint)))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef
                    (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                    (Tstruct _Animation noattr)) _flags tshort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'4 tshort)
                             (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                               (Econst_int (Int.repr 1) tint) tint) tint)
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sset _isPastFrame
                    (Ebinop Oeq (Etempvar _t'6 tshort)
                      (Ebinop Oadd (Etempvar _animFrame tshort)
                        (Econst_int (Int.repr 1) tint) tint) tint)))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _animInfo (tptr (Tstruct _AnimInfo noattr)))
                        (Tstruct _AnimInfo noattr)) _animFrame tshort))
                  (Sset _isPastFrame
                    (Ebinop Oeq
                      (Ebinop Oadd (Etempvar _t'5 tshort)
                        (Econst_int (Int.repr 1) tint) tint)
                      (Etempvar _animFrame tshort) tint)))))))
        (Sreturn (Some (Etempvar _isPastFrame tint)))))))
|}.

Definition f_find_mario_anim_flags_and_translation := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_obj, (tptr (Tstruct _Object noattr))) :: (_yaw, tint) ::
                (_translation, (tptr tshort)) :: nil);
  fn_vars := ((_animIndex, (tptr tushort)) :: nil);
  fn_temps := ((_dx, tfloat) :: (_dz, tfloat) ::
               (_curAnim, (tptr (Tstruct _Animation noattr))) ::
               (_animFrame, tshort) :: (_animValues, (tptr tshort)) ::
               (_s, tfloat) :: (_c, tfloat) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, (tptr tvoid)) ::
               (_t'2, (tptr tvoid)) :: (_t'1, tshort) ::
               (_t'15, (tptr (Tstruct _Animation noattr))) ::
               (_t'14, (tptr tushort)) :: (_t'13, (tptr tshort)) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'15
      (Efield
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _animInfo
          (Tstruct _AnimInfo noattr)) _curAnim
        (tptr (Tstruct _Animation noattr))))
    (Sset _curAnim
      (Ecast (Etempvar _t'15 (tptr (Tstruct _Animation noattr)))
        (tptr tvoid))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _geo_update_animation_frame (Tfunction
                                            ((tptr (Tstruct _AnimInfo noattr)) ::
                                             (tptr tint) :: nil) tshort
                                            cc_default))
        ((Eaddrof
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _obj (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _animInfo
             (Tstruct _AnimInfo noattr)) (tptr (Tstruct _AnimInfo noattr))) ::
         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)) :: nil))
      (Sset _animFrame (Ecast (Etempvar _t'1 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                (Tstruct _Animation noattr)) _index (tptr tushort)))
          (Scall (Some _t'2)
            (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                          (tptr tvoid) cc_default))
            ((Ecast (Etempvar _t'14 (tptr tushort)) (tptr tvoid)) :: nil)))
        (Sassign (Evar _animIndex (tptr tushort))
          (Etempvar _t'2 (tptr tvoid))))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef
                  (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                  (Tstruct _Animation noattr)) _values (tptr tshort)))
            (Scall (Some _t'3)
              (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                            (tptr tvoid) cc_default))
              ((Ecast (Etempvar _t'13 (tptr tshort)) (tptr tvoid)) :: nil)))
          (Sset _animValues (Etempvar _t'3 (tptr tvoid))))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Ederef
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Ebinop Oshr (Ecast (Etempvar _yaw tint) tushort)
                    (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                tfloat))
            (Sset _s (Ecast (Etempvar _t'12 tfloat) tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Ederef
                  (Ebinop Oadd
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                    (Ebinop Oshr (Ecast (Etempvar _yaw tint) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sset _c (Ecast (Etempvar _t'11 tfloat) tfloat)))
            (Ssequence
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _retrieve_animation_index (Tfunction
                                                    (tint ::
                                                     (tptr (tptr tushort)) ::
                                                     nil) tint cc_default))
                  ((Etempvar _animFrame tshort) ::
                   (Eaddrof (Evar _animIndex (tptr tushort))
                     (tptr (tptr tushort))) :: nil))
                (Ssequence
                  (Sset _t'10
                    (Ederef
                      (Ebinop Oadd (Etempvar _animValues (tptr tshort))
                        (Etempvar _t'4 tint) (tptr tshort)) tshort))
                  (Sset _dx
                    (Ebinop Odiv (Etempvar _t'10 tshort)
                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                      tfloat))))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _retrieve_animation_index (Tfunction
                                                      (tint ::
                                                       (tptr (tptr tushort)) ::
                                                       nil) tint cc_default))
                    ((Etempvar _animFrame tshort) ::
                     (Eaddrof (Evar _animIndex (tptr tushort))
                       (tptr (tptr tushort))) :: nil))
                  (Ssequence
                    (Sset _t'9
                      (Ederef
                        (Ebinop Oadd (Etempvar _animValues (tptr tshort))
                          (Etempvar _t'5 tint) (tptr tshort)) tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _translation (tptr tshort))
                          (Econst_int (Int.repr 1) tint) (tptr tshort))
                        tshort)
                      (Ebinop Odiv (Etempvar _t'9 tshort)
                        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _retrieve_animation_index (Tfunction
                                                        (tint ::
                                                         (tptr (tptr tushort)) ::
                                                         nil) tint
                                                        cc_default))
                      ((Etempvar _animFrame tshort) ::
                       (Eaddrof (Evar _animIndex (tptr tushort))
                         (tptr (tptr tushort))) :: nil))
                    (Ssequence
                      (Sset _t'8
                        (Ederef
                          (Ebinop Oadd (Etempvar _animValues (tptr tshort))
                            (Etempvar _t'6 tint) (tptr tshort)) tshort))
                      (Sset _dz
                        (Ebinop Odiv (Etempvar _t'8 tshort)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat))))
                  (Ssequence
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _translation (tptr tshort))
                          (Econst_int (Int.repr 0) tint) (tptr tshort))
                        tshort)
                      (Ebinop Oadd
                        (Ebinop Omul (Etempvar _dx tfloat)
                          (Etempvar _c tfloat) tfloat)
                        (Ebinop Omul (Etempvar _dz tfloat)
                          (Etempvar _s tfloat) tfloat) tfloat))
                    (Ssequence
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _translation (tptr tshort))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort)
                        (Ebinop Oadd
                          (Ebinop Omul
                            (Eunop Oneg (Etempvar _dx tfloat) tfloat)
                            (Etempvar _s tfloat) tfloat)
                          (Ebinop Omul (Etempvar _dz tfloat)
                            (Etempvar _c tfloat) tfloat) tfloat))
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _curAnim (tptr (Tstruct _Animation noattr)))
                              (Tstruct _Animation noattr)) _flags tshort))
                        (Sreturn (Some (Etempvar _t'7 tshort)))))))))))))))
|}.

Definition f_update_mario_pos_for_anim := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_translation, (tarray tshort 3)) :: nil);
  fn_temps := ((_flags, tshort) :: (_t'1, tshort) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tshort) :: (_t'4, tfloat) ::
               (_t'3, tshort) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
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
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Scall (Some _t'1)
          (Evar _find_mario_anim_flags_and_translation (Tfunction
                                                         ((tptr (Tstruct _Object noattr)) ::
                                                          tint ::
                                                          (tptr tshort) ::
                                                          nil) tshort
                                                         cc_default))
          ((Etempvar _t'8 (tptr (Tstruct _Object noattr))) ::
           (Etempvar _t'9 tshort) :: (Evar _translation (tarray tshort 3)) ::
           nil))))
    (Sset _flags (Ecast (Etempvar _t'1 tshort) tshort)))
  (Ssequence
    (Sifthenelse (Ebinop Oand (Etempvar _flags tshort)
                   (Ebinop Oor
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 3) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 6) tint) tint) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd (Evar _translation (tarray tshort 3))
                  (Econst_int (Int.repr 0) tint) (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'6 tfloat)
                (Ecast (Etempvar _t'7 tshort) tfloat) tfloat))))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'5
              (Ederef
                (Ebinop Oadd (Evar _translation (tarray tshort 3))
                  (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
              (Ebinop Oadd (Etempvar _t'4 tfloat)
                (Ecast (Etempvar _t'5 tshort) tfloat) tfloat)))))
      Sskip)
    (Sifthenelse (Ebinop Oand (Etempvar _flags tshort)
                   (Ebinop Oor
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 4) tint) tint)
                     (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                       (Econst_int (Int.repr 6) tint) tint) tint) tint)
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
            (Ederef
              (Ebinop Oadd (Evar _translation (tarray tshort 3))
                (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Ebinop Oadd (Etempvar _t'2 tfloat)
              (Ecast (Etempvar _t'3 tshort) tfloat) tfloat))))
      Sskip)))
|}.

Definition f_return_mario_anim_y_translation := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_translation, (tarray tshort 3)) :: nil);
  fn_temps := ((_t'2, (tptr (Tstruct _Object noattr))) :: (_t'1, tshort) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Scall None
      (Evar _find_mario_anim_flags_and_translation (Tfunction
                                                     ((tptr (Tstruct _Object noattr)) ::
                                                      tint ::
                                                      (tptr tshort) :: nil)
                                                     tshort cc_default))
      ((Etempvar _t'2 (tptr (Tstruct _Object noattr))) ::
       (Econst_int (Int.repr 0) tint) ::
       (Evar _translation (tarray tshort 3)) :: nil)))
  (Ssequence
    (Sset _t'1
      (Ederef
        (Ebinop Oadd (Evar _translation (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Sreturn (Some (Etempvar _t'1 tshort)))))
|}.

Definition f_play_sound_if_no_flag := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: (_flags, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, (tptr (Tstruct _Object noattr))) :: (_t'2, tuint) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _t'1 tuint) (Etempvar _flags tuint)
                   tuint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Etempvar _soundBits tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'2 tuint) (Etempvar _flags tuint) tuint))))
    Sskip))
|}.

Definition f_play_mario_jump_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, (tptr (Tstruct _Object noattr))) :: (_t'6, tuint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _t'1 tuint)
                   (Econst_int (Int.repr 131072) tint) tuint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tuint)
                       (Econst_int (Int.repr 16779394) tint) tint)
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
                             (Ecast (Econst_int (Int.repr 43) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint)
                   (Ebinop Oshl
                     (Ebinop Omod (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 5) tint) tuint)
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
          (Ssequence
            (Sset _t'4 (Evar _gAudioRandom tuint))
            (Ssequence
              (Sset _t'5
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
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 128) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                         (Econst_int (Int.repr 128) tint) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint)
                   (Ebinop Oshl
                     (Ebinop Omod (Etempvar _t'4 tuint)
                       (Econst_int (Int.repr 3) tint) tuint)
                     (Econst_int (Int.repr 16) tint) tuint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil))))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'2 tuint)
            (Econst_int (Int.repr 131072) tint) tuint))))
    Sskip))
|}.

Definition f_adjust_sound_for_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_absForwardVel, tint) :: (_t'2, tint) :: (_t'1, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                     tint)
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sset _t'1 (Ecast (Etempvar _t'5 tfloat) tfloat)))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sset _t'1
            (Ecast (Eunop Oneg (Etempvar _t'4 tfloat) tfloat) tfloat)))))
    (Sset _absForwardVel (Ecast (Etempvar _t'1 tfloat) tint)))
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _absForwardVel tint)
                   (Econst_int (Int.repr 100) tint) tint)
      (Sset _t'2 (Ecast (Econst_int (Int.repr 100) tint) tint))
      (Sset _t'2 (Ecast (Etempvar _absForwardVel tint) tint)))
    (Scall None
      (Evar _set_sound_moving_speed (Tfunction (tuchar :: tuchar :: nil)
                                      tvoid cc_default))
      ((Econst_int (Int.repr 1) tint) :: (Etempvar _t'2 tint) :: nil))))
|}.

Definition f_play_sound_and_spawn_particles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: (_waveParticleType, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'13, tuint) ::
               (_t'12, tuint) :: (_t'11, tuint) :: (_t'10, tuint) ::
               (_t'9, tuint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuint)
                   (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                     (Econst_int (Int.repr 16) tint) tint) tint)
      (Sifthenelse (Ebinop One (Etempvar _waveParticleType tuint)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'13
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint)
            (Ebinop Oor (Etempvar _t'13 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 12) tint) tint) tuint)))
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _particleFlags tuint)
            (Ebinop Oor (Etempvar _t'12 tuint)
              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                (Econst_int (Int.repr 8) tint) tint) tuint))))
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tuint)
                       (Ebinop Oshl (Econst_int (Int.repr 7) tint)
                         (Econst_int (Int.repr 16) tint) tint) tint)
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _particleFlags tuint)
              (Ebinop Oor (Etempvar _t'11 tuint)
                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                  (Econst_int (Int.repr 15) tint) tint) tuint)))
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 5) tint)
                             (Econst_int (Int.repr 16) tint) tint) tint)
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
                      (Econst_int (Int.repr 14) tint) tint) tuint)))
              Sskip))))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tuint)
                       (Econst_int (Int.repr 4) tint) tuint)
          (Sset _t'1 (Econst_int (Int.repr 1) tint))
          (Sset _t'1
            (Ecast
              (Ebinop Oeq (Etempvar _soundBits tuint)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 28) tint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 67) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 128) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint)
                    (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                      (Econst_int (Int.repr 128) tint) tint) tuint)
                  (Econst_int (Int.repr 1) tint) tuint) tint) tbool))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Sset _t'2
          (Ecast
            (Ebinop Oeq (Etempvar _soundBits tuint)
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 2) tint) tuint)
                        (Econst_int (Int.repr 28) tint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 31) tint) tuint)
                        (Econst_int (Int.repr 16) tint) tuint) tuint)
                    (Ebinop Oshl
                      (Ecast (Econst_int (Int.repr 128) tint) tuint)
                      (Econst_int (Int.repr 8) tint) tuint) tuint)
                  (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                    (Econst_int (Int.repr 128) tint) tint) tuint)
                (Econst_int (Int.repr 1) tint) tuint) tint) tbool))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Etempvar _soundBits tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil)))
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                                cc_default))
            ((Ebinop Oadd (Etempvar _t'3 tuint) (Etempvar _soundBits tuint)
               tuint) ::
             (Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _cameraToObject
               (tarray tfloat 3)) :: nil)))))))
|}.

Definition f_play_mario_action_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: (_waveParticleType, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Sifthenelse (Eunop Onotbool
                 (Ebinop Oand (Etempvar _t'1 tuint)
                   (Econst_int (Int.repr 65536) tint) tuint) tint)
    (Ssequence
      (Scall None
        (Evar _play_sound_and_spawn_particles (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tvoid
                                                cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _soundBits tuint) :: (Etempvar _waveParticleType tuint) ::
         nil))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint)
          (Ebinop Oor (Etempvar _t'2 tuint)
            (Econst_int (Int.repr 65536) tint) tuint))))
    Sskip))
|}.

Definition f_play_mario_landing_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 41) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint))
      (Sset _t'1 (Ecast (Etempvar _soundBits tuint) tuint))))
  (Scall None
    (Evar _play_sound_and_spawn_particles (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tvoid
                                            cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 1) tint) :: nil)))
|}.

Definition f_play_mario_landing_sound_once := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 41) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint))
      (Sset _t'1 (Ecast (Etempvar _soundBits tuint) tuint))))
  (Scall None
    (Evar _play_mario_action_sound (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 1) tint) :: nil)))
|}.

Definition f_play_mario_heavy_landing_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 43) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint))
      (Sset _t'1 (Ecast (Etempvar _soundBits tuint) tuint))))
  (Scall None
    (Evar _play_sound_and_spawn_particles (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tvoid
                                            cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 1) tint) :: nil)))
|}.

Definition f_play_mario_heavy_landing_sound_once := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_soundBits, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                   (Econst_int (Int.repr 4) tint) tuint)
      (Sset _t'1
        (Ecast
          (Ebinop Oor
            (Ebinop Oor
              (Ebinop Oor
                (Ebinop Oor
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                    (Econst_int (Int.repr 28) tint) tuint)
                  (Ebinop Oshl (Ecast (Econst_int (Int.repr 43) tint) tuint)
                    (Econst_int (Int.repr 16) tint) tuint) tuint)
                (Ebinop Oshl (Ecast (Econst_int (Int.repr 144) tint) tuint)
                  (Econst_int (Int.repr 8) tint) tuint) tuint)
              (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                (Econst_int (Int.repr 128) tint) tint) tuint)
            (Econst_int (Int.repr 1) tint) tuint) tuint))
      (Sset _t'1 (Ecast (Etempvar _soundBits tuint) tuint))))
  (Scall None
    (Evar _play_mario_action_sound (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Etempvar _t'1 tuint) :: (Econst_int (Int.repr 1) tint) :: nil)))
|}.

Definition f_play_mario_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_actionSound, tint) :: (_marioSound, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Ebinop Oeq (Etempvar _actionSound tint)
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 128) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'2 tuint)
                       (Econst_int (Int.repr 4) tint) tuint)
          (Sset _t'1
            (Ecast
              (Ecast
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 28) tint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 40) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 144) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint)
                    (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                      (Econst_int (Int.repr 128) tint) tint) tuint)
                  (Econst_int (Int.repr 1) tint) tuint) tint) tint))
          (Sset _t'1
            (Ecast
              (Ecast
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor
                      (Ebinop Oor
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 28) tint) tuint)
                        (Ebinop Oshl
                          (Ecast (Econst_int (Int.repr 0) tint) tuint)
                          (Econst_int (Int.repr 16) tint) tuint) tuint)
                      (Ebinop Oshl
                        (Ecast (Econst_int (Int.repr 128) tint) tuint)
                        (Econst_int (Int.repr 8) tint) tuint) tuint)
                    (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                      (Econst_int (Int.repr 128) tint) tint) tuint)
                  (Econst_int (Int.repr 1) tint) tuint) tint) tint))))
      (Scall None
        (Evar _play_mario_action_sound (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tuint :: tuint :: nil) tvoid
                                         cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _t'1 tint) :: (Econst_int (Int.repr 1) tint) :: nil)))
    (Scall None
      (Evar _play_sound_if_no_flag (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tvoid
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _actionSound tint) :: (Econst_int (Int.repr 65536) tint) ::
       nil)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _marioSound tint)
                   (Econst_int (Int.repr 0) tint) tint)
      (Scall None
        (Evar _play_mario_jump_sound (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      Sskip)
    (Sifthenelse (Ebinop One (Etempvar _marioSound tint)
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) tint)
      (Scall None
        (Evar _play_sound_if_no_flag (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tuint :: tuint :: nil) tvoid
                                       cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _marioSound tint) ::
         (Econst_int (Int.repr 131072) tint) :: nil))
      Sskip)))
|}.

Definition f_mario_set_forward_vel := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_forwardVel, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tshort) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _forwardVel tfloat)
    (Etempvar _forwardVel tfloat))
  (Ssequence
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
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _slideVelX tfloat)
            (Ebinop Omul (Etempvar _t'7 tfloat) (Etempvar _t'8 tfloat)
              tfloat)))))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Ssequence
          (Sset _t'4
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _t'3 tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _slideVelZ tfloat)
              (Ebinop Omul (Etempvar _t'4 tfloat) (Etempvar _t'5 tfloat)
                tfloat)))))
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _slideVelX tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
            (Ecast (Etempvar _t'2 tfloat) tfloat)))
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _slideVelZ tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat)
            (Ecast (Etempvar _t'1 tfloat) tfloat)))))))
|}.

Definition f_mario_get_floor_class := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorClass, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'10, tushort) :: (_t'9, (tptr (Tstruct _Area noattr))) ::
               (_t'8, tshort) :: (_t'7, (tptr (Tstruct _Surface noattr))) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _Surface noattr))) :: (_t'3, tuint) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _terrainType tushort))
      (Sifthenelse (Ebinop Oeq
                     (Ebinop Oand (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 7) tint) tint)
                     (Econst_int (Int.repr 6) tint) tint)
        (Sset _floorClass (Econst_int (Int.repr 19) tint))
        (Sset _floorClass (Econst_int (Int.repr 0) tint)))))
  (Ssequence
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sswitch (Etempvar _t'8 tshort)
              (LScons (Some 21)
                Sskip
                (LScons (Some 55)
                  Sskip
                  (LScons (Some 122)
                    (Ssequence
                      (Sset _floorClass (Econst_int (Int.repr 21) tint))
                      Sbreak)
                    (LScons (Some 20)
                      Sskip
                      (LScons (Some 42)
                        Sskip
                        (LScons (Some 53)
                          Sskip
                          (LScons (Some 121)
                            (Ssequence
                              (Sset _floorClass
                                (Econst_int (Int.repr 20) tint))
                              Sbreak)
                            (LScons (Some 19)
                              Sskip
                              (LScons (Some 46)
                                Sskip
                                (LScons (Some 54)
                                  Sskip
                                  (LScons (Some 115)
                                    Sskip
                                    (LScons (Some 116)
                                      Sskip
                                      (LScons (Some 117)
                                        Sskip
                                        (LScons (Some 120)
                                          (Ssequence
                                            (Sset _floorClass
                                              (Econst_int (Int.repr 19) tint))
                                            Sbreak)
                                          LSnil)))))))))))))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _action tuint))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tuint)
                           (Econst_int (Int.repr 67142728) tint) tint)
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _floor
                    (tptr (Tstruct _Surface noattr))))
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'4 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _normal
                        (Tstruct __670 noattr)) _y tfloat))
                  (Sset _t'1
                    (Ecast
                      (Ebinop Ogt (Etempvar _t'5 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                        tint) tbool))))
              (Sset _t'1 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'1 tint)
            (Sset _t'2
              (Ecast
                (Ebinop Oeq (Etempvar _floorClass tint)
                  (Econst_int (Int.repr 0) tint) tint) tbool))
            (Sset _t'2 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'2 tint)
          (Sset _floorClass (Econst_int (Int.repr 21) tint))
          Sskip))
      (Sreturn (Some (Etempvar _floorClass tint))))))
|}.

Definition v_sTerrainSounds := {|
  gvar_info := (tarray (tarray tschar 6) 7);
  gvar_init := (Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 0) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 1) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 5) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 7) :: Init_int8 (Int.repr 7) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 4) :: Init_int8 (Int.repr 4) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 0) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 1) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 6) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 3) :: Init_int8 (Int.repr 3) ::
                Init_int8 (Int.repr 6) :: Init_int8 (Int.repr 6) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_mario_get_terrain_sound_addend := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorSoundType, tshort) :: (_terrainType, tshort) ::
               (_ret, tint) :: (_floorType, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'10, tushort) ::
               (_t'9, (tptr (Tstruct _Area noattr))) ::
               (_t'8, (tptr (Tstruct _Surface noattr))) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tshort) :: (_t'4, tschar) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _t'9 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _terrainType tushort))
      (Sset _terrainType
        (Ecast
          (Ebinop Oand (Etempvar _t'10 tushort)
            (Econst_int (Int.repr 7) tint) tint) tshort))))
  (Ssequence
    (Sset _ret
      (Ebinop Oshl (Econst_int (Int.repr 0) tint)
        (Econst_int (Int.repr 16) tint) tint))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floor
            (tptr (Tstruct _Surface noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Ssequence
              (Sset _t'8
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Sset _floorType
                (Efield
                  (Ederef (Etempvar _t'8 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _type tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'5 (Evar _gCurrLevelNum tshort))
                (Sifthenelse (Ebinop One (Etempvar _t'5 tshort)
                               (Econst_int (Int.repr 22) tint) tint)
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _floorHeight tfloat))
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _waterLevel tshort))
                      (Sset _t'2
                        (Ecast
                          (Ebinop Olt (Etempvar _t'6 tfloat)
                            (Ebinop Osub (Etempvar _t'7 tshort)
                              (Econst_int (Int.repr 10) tint) tint) tint)
                          tbool))))
                  (Sset _t'2 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'2 tint)
                (Sset _ret
                  (Ebinop Oshl (Econst_int (Int.repr 2) tint)
                    (Econst_int (Int.repr 16) tint) tint))
                (Ssequence
                  (Sifthenelse (Ebinop Oge (Etempvar _floorType tint)
                                 (Econst_int (Int.repr 33) tint) tint)
                    (Sset _t'1
                      (Ecast
                        (Ebinop Olt (Etempvar _floorType tint)
                          (Econst_int (Int.repr 40) tint) tint) tbool))
                    (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Sset _ret
                      (Ebinop Oshl (Econst_int (Int.repr 7) tint)
                        (Econst_int (Int.repr 16) tint) tint))
                    (Ssequence
                      (Sswitch (Etempvar _floorType tint)
                        (LScons None
                          (Ssequence
                            (Sset _floorSoundType
                              (Ecast (Econst_int (Int.repr 0) tint) tshort))
                            Sbreak)
                          (LScons (Some 21)
                            Sskip
                            (LScons (Some 48)
                              Sskip
                              (LScons (Some 55)
                                Sskip
                                (LScons (Some 122)
                                  (Ssequence
                                    (Sset _floorSoundType
                                      (Ecast (Econst_int (Int.repr 1) tint)
                                        tshort))
                                    Sbreak)
                                  (LScons (Some 20)
                                    Sskip
                                    (LScons (Some 53)
                                      Sskip
                                      (LScons (Some 121)
                                        (Ssequence
                                          (Sset _floorSoundType
                                            (Ecast
                                              (Econst_int (Int.repr 2) tint)
                                              tshort))
                                          Sbreak)
                                        (LScons (Some 19)
                                          Sskip
                                          (LScons (Some 46)
                                            Sskip
                                            (LScons (Some 54)
                                              Sskip
                                              (LScons (Some 115)
                                                Sskip
                                                (LScons (Some 116)
                                                  Sskip
                                                  (LScons (Some 117)
                                                    Sskip
                                                    (LScons (Some 120)
                                                      (Ssequence
                                                        (Sset _floorSoundType
                                                          (Ecast
                                                            (Econst_int (Int.repr 3) tint)
                                                            tshort))
                                                        Sbreak)
                                                      (LScons (Some 41)
                                                        (Ssequence
                                                          (Sset _floorSoundType
                                                            (Ecast
                                                              (Econst_int (Int.repr 4) tint)
                                                              tshort))
                                                          Sbreak)
                                                        (LScons (Some 42)
                                                          (Ssequence
                                                            (Sset _floorSoundType
                                                              (Ecast
                                                                (Econst_int (Int.repr 5) tint)
                                                                tshort))
                                                            Sbreak)
                                                          LSnil))))))))))))))))))
                      (Ssequence
                        (Sset _t'4
                          (Ederef
                            (Ebinop Oadd
                              (Ederef
                                (Ebinop Oadd
                                  (Evar _sTerrainSounds (tarray (tarray tschar 6) 7))
                                  (Etempvar _terrainType tshort)
                                  (tptr (tarray tschar 6)))
                                (tarray tschar 6))
                              (Etempvar _floorSoundType tshort)
                              (tptr tschar)) tschar))
                        (Sset _ret
                          (Ebinop Oshl (Etempvar _t'4 tschar)
                            (Econst_int (Int.repr 16) tint) tint)))))))))
          Sskip))
      (Sreturn (Some (Etempvar _ret tint))))))
|}.

Definition f_resolve_and_return_wall_collisions := {|
  fn_return := (tptr (Tstruct _Surface noattr));
  fn_callconv := cc_default;
  fn_params := ((_pos, (tptr tfloat)) :: (_offset, tfloat) ::
                (_radius, tfloat) :: nil);
  fn_vars := ((_collisionData, (Tstruct _WallCollisionData noattr)) :: nil);
  fn_temps := ((_wall, (tptr (Tstruct _Surface noattr))) :: (_t'1, tint) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tshort) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _wall (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid)))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Etempvar _pos (tptr tfloat))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Sassign
        (Efield (Evar _collisionData (Tstruct _WallCollisionData noattr)) _x
          tfloat) (Etempvar _t'8 tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd (Etempvar _pos (tptr tfloat))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Efield (Evar _collisionData (Tstruct _WallCollisionData noattr))
            _y tfloat) (Etempvar _t'7 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Efield (Evar _collisionData (Tstruct _WallCollisionData noattr))
              _z tfloat) (Etempvar _t'6 tfloat)))
        (Ssequence
          (Sassign
            (Efield (Evar _collisionData (Tstruct _WallCollisionData noattr))
              _radius tfloat) (Etempvar _radius tfloat))
          (Ssequence
            (Sassign
              (Efield
                (Evar _collisionData (Tstruct _WallCollisionData noattr))
                _offsetY tfloat) (Etempvar _offset tfloat))
            (Ssequence
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _find_wall_collisions (Tfunction
                                                ((tptr (Tstruct _WallCollisionData noattr)) ::
                                                 nil) tint cc_default))
                  ((Eaddrof
                     (Evar _collisionData (Tstruct _WallCollisionData noattr))
                     (tptr (Tstruct _WallCollisionData noattr))) :: nil))
                (Sifthenelse (Etempvar _t'1 tint)
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Evar _collisionData (Tstruct _WallCollisionData noattr))
                        _numWalls tshort))
                    (Sset _wall
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Evar _collisionData (Tstruct _WallCollisionData noattr))
                            _walls
                            (tarray (tptr (Tstruct _Surface noattr)) 4))
                          (Ebinop Osub (Etempvar _t'5 tshort)
                            (Econst_int (Int.repr 1) tint) tint)
                          (tptr (tptr (Tstruct _Surface noattr))))
                        (tptr (Tstruct _Surface noattr)))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Efield
                      (Evar _collisionData (Tstruct _WallCollisionData noattr))
                      _x tfloat))
                  (Sassign
                    (Ederef
                      (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                        (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat)
                    (Etempvar _t'4 tfloat)))
                (Ssequence
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Evar _collisionData (Tstruct _WallCollisionData noattr))
                        _y tfloat))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                          (Econst_int (Int.repr 1) tint) (tptr tfloat))
                        tfloat) (Etempvar _t'3 tfloat)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'2
                        (Efield
                          (Evar _collisionData (Tstruct _WallCollisionData noattr))
                          _z tfloat))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd (Etempvar _pos (tptr tfloat))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat) (Etempvar _t'2 tfloat)))
                    (Sreturn (Some (Etempvar _wall (tptr (Tstruct _Surface noattr)))))))))))))))
|}.

Definition f_vec3f_find_ceil := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_pos, (tptr tfloat)) :: (_height, tfloat) ::
                (_ceil, (tptr (tptr (Tstruct _Surface noattr)))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'1, tfloat) :: (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Ederef
        (Ebinop Oadd (Etempvar _pos (tptr tfloat))
          (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd (Etempvar _pos (tptr tfloat))
            (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
      (Scall (Some _t'1)
        (Evar _find_ceil (Tfunction
                           (tfloat :: tfloat :: tfloat ::
                            (tptr (tptr (Tstruct _Surface noattr))) :: nil)
                           tfloat cc_default))
        ((Etempvar _t'2 tfloat) ::
         (Ebinop Oadd (Etempvar _height tfloat)
           (Econst_single (Float32.of_bits (Int.repr 1117782016)) tfloat)
           tfloat) :: (Etempvar _t'3 tfloat) ::
         (Etempvar _ceil (tptr (tptr (Tstruct _Surface noattr)))) :: nil))))
  (Sreturn (Some (Etempvar _t'1 tfloat))))
|}.

Definition f_mario_facing_downhill := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_turnYaw, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_faceAngleYaw, tshort) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'5, tshort) :: (_t'4, tfloat) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Sset _faceAngleYaw (Ecast (Etempvar _t'5 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Etempvar _turnYaw tint)
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sset _t'1
            (Ecast
              (Ebinop Olt (Etempvar _t'4 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) tint)
              tbool)))
        (Sset _t'1 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _faceAngleYaw
          (Ecast
            (Ebinop Oadd (Etempvar _faceAngleYaw tshort)
              (Econst_int (Int.repr 32768) tint) tint) tshort))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floorAngle tshort))
        (Sset _faceAngleYaw
          (Ecast
            (Ebinop Osub (Etempvar _t'3 tshort)
              (Etempvar _faceAngleYaw tshort) tint) tshort)))
      (Ssequence
        (Sifthenelse (Ebinop Olt
                       (Eunop Oneg (Econst_int (Int.repr 16384) tint) tint)
                       (Etempvar _faceAngleYaw tshort) tint)
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _faceAngleYaw tshort)
                (Econst_int (Int.repr 16384) tint) tint) tbool))
          (Sset _t'2 (Econst_int (Int.repr 0) tint)))
        (Sreturn (Some (Etempvar _t'2 tint)))))))
|}.

Definition f_mario_floor_is_slippery := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_normY, tfloat) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Surface noattr))) ::
               (_t'6, tushort) :: (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, tfloat) :: (_t'3, (tptr (Tstruct _Surface noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _area
          (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _terrainType tushort))
        (Sifthenelse (Ebinop Oeq
                       (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 7) tint) tint)
                       (Econst_int (Int.repr 6) tint) tint)
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _y tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Olt (Etempvar _t'8 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1065350661)) tfloat)
                    tint) tbool))))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _mario_get_floor_class (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sswitch (Etempvar _t'2 tint)
        (LScons (Some 19)
          (Ssequence
            (Sset _normY
              (Econst_single (Float32.of_bits (Int.repr 1065098332)) tfloat))
            Sbreak)
          (LScons (Some 20)
            (Ssequence
              (Sset _normY
                (Econst_single (Float32.of_bits (Int.repr 1064341426)) tfloat))
              Sbreak)
            (LScons None
              (Ssequence
                (Sset _normY
                  (Econst_single (Float32.of_bits (Int.repr 1061796627)) tfloat))
                Sbreak)
              (LScons (Some 21)
                (Ssequence
                  (Sset _normY
                    (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                  Sbreak)
                LSnil))))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
            tfloat))
        (Sreturn (Some (Ebinop Ole (Etempvar _t'4 tfloat)
                         (Etempvar _normY tfloat) tint)))))))
|}.

Definition f_mario_floor_is_slope := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_normY, tfloat) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Surface noattr))) ::
               (_t'6, tushort) :: (_t'5, (tptr (Tstruct _Area noattr))) ::
               (_t'4, tfloat) :: (_t'3, (tptr (Tstruct _Surface noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _area
          (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _terrainType tushort))
        (Sifthenelse (Ebinop Oeq
                       (Ebinop Oand (Etempvar _t'6 tushort)
                         (Econst_int (Int.repr 7) tint) tint)
                       (Econst_int (Int.repr 6) tint) tint)
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'8
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _y tfloat))
              (Sset _t'1
                (Ecast
                  (Ebinop Olt (Etempvar _t'8 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1065350661)) tfloat)
                    tint) tbool))))
          (Sset _t'1 (Econst_int (Int.repr 0) tint)))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _mario_get_floor_class (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sswitch (Etempvar _t'2 tint)
        (LScons (Some 19)
          (Ssequence
            (Sset _normY
              (Econst_single (Float32.of_bits (Int.repr 1065289374)) tfloat))
            Sbreak)
          (LScons (Some 20)
            (Ssequence
              (Sset _normY
                (Econst_single (Float32.of_bits (Int.repr 1065098332)) tfloat))
              Sbreak)
            (LScons None
              (Ssequence
                (Sset _normY
                  (Econst_single (Float32.of_bits (Int.repr 1064781546)) tfloat))
                Sbreak)
              (LScons (Some 21)
                (Ssequence
                  (Sset _normY
                    (Econst_single (Float32.of_bits (Int.repr 1064341426)) tfloat))
                  Sbreak)
                LSnil))))))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Ssequence
        (Sset _t'4
          (Efield
            (Efield
              (Ederef (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
            tfloat))
        (Sreturn (Some (Ebinop Ole (Etempvar _t'4 tfloat)
                         (Etempvar _normY tfloat) tint)))))))
|}.

Definition f_mario_floor_is_steep := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_normY, tfloat) :: (_result, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'4, tfloat) ::
               (_t'3, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _result (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _mario_facing_downhill (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 0) tint) :: nil))
      (Sifthenelse (Eunop Onotbool (Etempvar _t'2 tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _mario_get_floor_class (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sswitch (Etempvar _t'1 tint)
              (LScons (Some 19)
                (Ssequence
                  (Sset _normY
                    (Econst_single (Float32.of_bits (Int.repr 1064781546)) tfloat))
                  Sbreak)
                (LScons (Some 20)
                  (Ssequence
                    (Sset _normY
                      (Econst_single (Float32.of_bits (Int.repr 1064341426)) tfloat))
                    Sbreak)
                  (LScons None
                    (Ssequence
                      (Sset _normY
                        (Econst_single (Float32.of_bits (Int.repr 1063105495)) tfloat))
                      Sbreak)
                    (LScons (Some 21)
                      (Ssequence
                        (Sset _normY
                          (Econst_single (Float32.of_bits (Int.repr 1063105495)) tfloat))
                        Sbreak)
                      LSnil))))))
          (Ssequence
            (Sset _t'3
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'3 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _y tfloat))
              (Sset _result
                (Ebinop Ole (Etempvar _t'4 tfloat) (Etempvar _normY tfloat)
                  tint)))))
        Sskip))
    (Sreturn (Some (Etempvar _result tint)))))
|}.

Definition f_find_floor_height_relative_polar := {|
  fn_return := tfloat;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_angleFromMario, tshort) :: (_distFromMario, tfloat) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorY, tfloat) :: (_y, tfloat) :: (_x, tfloat) ::
               (_t'1, tfloat) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tshort) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'7
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Ssequence
      (Sset _t'8
        (Ederef
          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
            (Ebinop Oshr
              (Ecast
                (Ebinop Oadd (Etempvar _t'7 tshort)
                  (Etempvar _angleFromMario tshort) tint) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Sset _y
        (Ebinop Omul (Etempvar _t'8 tfloat) (Etempvar _distFromMario tfloat)
          tfloat))))
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
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Econst_int (Int.repr 1024) tint) (tptr tfloat))
              (Ebinop Oshr
                (Ecast
                  (Ebinop Oadd (Etempvar _t'5 tshort)
                    (Etempvar _angleFromMario tshort) tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Sset _x
          (Ebinop Omul (Etempvar _t'6 tfloat)
            (Etempvar _distFromMario tfloat) tfloat))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'2
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'3
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'4
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'1)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Ebinop Oadd (Etempvar _t'2 tfloat) (Etempvar _y tfloat)
                   tfloat) ::
                 (Ebinop Oadd (Etempvar _t'3 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                   tfloat) ::
                 (Ebinop Oadd (Etempvar _t'4 tfloat) (Etempvar _x tfloat)
                   tfloat) ::
                 (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
        (Sset _floorY (Etempvar _t'1 tfloat)))
      (Sreturn (Some (Etempvar _floorY tfloat))))))
|}.

Definition f_find_floor_slope := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_yawOffset, tshort) :: nil);
  fn_vars := ((_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_forwardFloorY, tfloat) :: (_backwardFloorY, tfloat) ::
               (_forwardYDelta, tfloat) :: (_backwardYDelta, tfloat) ::
               (_result, tshort) :: (_x, tfloat) :: (_z, tfloat) ::
               (_t'4, tshort) :: (_t'3, tshort) :: (_t'2, tfloat) ::
               (_t'1, tfloat) :: (_t'16, tfloat) :: (_t'15, tshort) ::
               (_t'14, tfloat) :: (_t'13, tshort) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'15
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Ssequence
      (Sset _t'16
        (Ederef
          (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
            (Ebinop Oshr
              (Ecast
                (Ebinop Oadd (Etempvar _t'15 tshort)
                  (Etempvar _yawOffset tshort) tint) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Sset _x
        (Ebinop Omul (Etempvar _t'16 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
          tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'13
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Ssequence
        (Sset _t'14
          (Ederef
            (Ebinop Oadd
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Econst_int (Int.repr 1024) tint) (tptr tfloat))
              (Ebinop Oshr
                (Ecast
                  (Ebinop Oadd (Etempvar _t'13 tshort)
                    (Etempvar _yawOffset tshort) tint) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Sset _z
          (Ebinop Omul (Etempvar _t'14 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
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
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'12
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'1)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Ebinop Oadd (Etempvar _t'10 tfloat) (Etempvar _x tfloat)
                   tfloat) ::
                 (Ebinop Oadd (Etempvar _t'11 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                   tfloat) ::
                 (Ebinop Oadd (Etempvar _t'12 tfloat) (Etempvar _z tfloat)
                   tfloat) ::
                 (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
        (Sset _forwardFloorY (Etempvar _t'1 tfloat)))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'8
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
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
                (Scall (Some _t'2)
                  (Evar _find_floor (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       (tptr (tptr (Tstruct _Surface noattr))) ::
                                       nil) tfloat cc_default))
                  ((Ebinop Osub (Etempvar _t'7 tfloat) (Etempvar _x tfloat)
                     tfloat) ::
                   (Ebinop Oadd (Etempvar _t'8 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                     tfloat) ::
                   (Ebinop Osub (Etempvar _t'9 tfloat) (Etempvar _z tfloat)
                     tfloat) ::
                   (Eaddrof (Evar _floor (tptr (Tstruct _Surface noattr)))
                     (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
          (Sset _backwardFloorY (Etempvar _t'2 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'6
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Sset _forwardYDelta
              (Ebinop Osub (Etempvar _forwardFloorY tfloat)
                (Etempvar _t'6 tfloat) tfloat)))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Sset _backwardYDelta
                (Ebinop Osub (Etempvar _t'5 tfloat)
                  (Etempvar _backwardFloorY tfloat) tfloat)))
            (Ssequence
              (Sifthenelse (Ebinop Olt
                             (Ebinop Omul (Etempvar _forwardYDelta tfloat)
                               (Etempvar _forwardYDelta tfloat) tfloat)
                             (Ebinop Omul (Etempvar _backwardYDelta tfloat)
                               (Etempvar _backwardYDelta tfloat) tfloat)
                             tint)
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
                     (Etempvar _forwardYDelta tfloat) :: nil))
                  (Sset _result (Ecast (Etempvar _t'3 tshort) tshort)))
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat) ::
                     (Etempvar _backwardYDelta tfloat) :: nil))
                  (Sset _result (Ecast (Etempvar _t'4 tshort) tshort))))
              (Sreturn (Some (Etempvar _result tshort))))))))))
|}.

Definition f_update_mario_sound_and_camera := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_action, tuint) :: (_camPreset, tint) :: (_t'1, tint) ::
               (_t'11, (tptr (Tstruct _Camera noattr))) ::
               (_t'10, (tptr (Tstruct _Area noattr))) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Camera noattr))) ::
               (_t'7, (tptr (Tstruct _Area noattr))) :: (_t'6, tuchar) ::
               (_t'5, (tptr (Tstruct _Camera noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, (tptr (Tstruct _Camera noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _action
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _area
          (tptr (Tstruct _Area noattr))))
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef (Etempvar _t'10 (tptr (Tstruct _Area noattr)))
              (Tstruct _Area noattr)) _camera
            (tptr (Tstruct _Camera noattr))))
        (Sset _camPreset
          (Efield
            (Ederef (Etempvar _t'11 (tptr (Tstruct _Camera noattr)))
              (Tstruct _Camera noattr)) _mode tuchar))))
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                     (Econst_int (Int.repr 201327143) tint) tint)
        (Ssequence
          (Scall None
            (Evar _raise_background_noise (Tfunction (tint :: nil) tvoid
                                            cc_default))
            ((Econst_int (Int.repr 2) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'9 (Evar _gCameraMovementFlags tshort))
              (Sassign (Evar _gCameraMovementFlags tshort)
                (Ebinop Oand (Etempvar _t'9 tshort)
                  (Eunop Onotint (Econst_int (Int.repr 8192) tint) tint)
                  tint)))
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _area
                  (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _t'7 (tptr (Tstruct _Area noattr)))
                      (Tstruct _Area noattr)) _camera
                    (tptr (Tstruct _Camera noattr))))
                (Scall None
                  (Evar _set_camera_mode (Tfunction
                                           ((tptr (Tstruct _Camera noattr)) ::
                                            tshort :: tshort :: nil) tvoid
                                           cc_default))
                  ((Etempvar _t'8 (tptr (Tstruct _Camera noattr))) ::
                   (Eunop Oneg (Econst_int (Int.repr 1) tint) tint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))))))
        (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                       (Econst_int (Int.repr 201327107) tint) tint)
          (Scall None
            (Evar _raise_background_noise (Tfunction (tint :: nil) tvoid
                                            cc_default))
            ((Econst_int (Int.repr 2) tint) :: nil))
          Sskip))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _action tuint)
                       (Ebinop Oor
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 13) tint) tint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 14) tint) tint) tint) tuint)
                     tint)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _camPreset tint)
                         (Econst_int (Int.repr 3) tint) tint)
            (Sset _t'1 (Econst_int (Int.repr 1) tint))
            (Sset _t'1
              (Ecast
                (Ebinop Oeq (Etempvar _camPreset tint)
                  (Econst_int (Int.repr 8) tint) tint) tbool)))
          (Sifthenelse (Etempvar _t'1 tint)
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _area
                  (tptr (Tstruct _Area noattr))))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
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
                        (Ederef (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
                          (Tstruct _Area noattr)) _camera
                        (tptr (Tstruct _Camera noattr))))
                    (Ssequence
                      (Sset _t'6
                        (Efield
                          (Ederef
                            (Etempvar _t'5 (tptr (Tstruct _Camera noattr)))
                            (Tstruct _Camera noattr)) _defMode tuchar))
                      (Scall None
                        (Evar _set_camera_mode (Tfunction
                                                 ((tptr (Tstruct _Camera noattr)) ::
                                                  tshort :: tshort :: nil)
                                                 tvoid cc_default))
                        ((Etempvar _t'3 (tptr (Tstruct _Camera noattr))) ::
                         (Etempvar _t'6 tuchar) ::
                         (Econst_int (Int.repr 1) tint) :: nil)))))))
            Sskip))
        Sskip))))
|}.

Definition f_set_steep_jump_action := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_angleTemp, tshort) :: (_faceAngleTemp, tshort) ::
               (_y, tfloat) :: (_x, tfloat) :: (_t'2, tshort) ::
               (_t'1, tfloat) :: (_t'11, tshort) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tshort) ::
               (_t'8, tshort) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tfloat) :: nil);
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
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Ederef (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
              _asS32 (tarray tint 80)) (Econst_int (Int.repr 34) tint)
            (tptr tint)) tint) (Etempvar _t'11 tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                     tint)
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorAngle tshort))
            (Sset _angleTemp
              (Ecast
                (Ebinop Oadd (Etempvar _t'9 tshort)
                  (Econst_int (Int.repr 32768) tint) tint) tshort)))
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
              (Sset _faceAngleTemp
                (Ecast
                  (Ebinop Osub (Etempvar _t'8 tshort)
                    (Etempvar _angleTemp tshort) tint) tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Ederef
                    (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                      (Ebinop Oshr
                        (Ecast (Etempvar _faceAngleTemp tshort) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sset _y
                    (Ebinop Omul (Etempvar _t'6 tfloat)
                      (Etempvar _t'7 tfloat) tfloat))))
              (Ssequence
                (Ssequence
                  (Sset _t'4
                    (Ederef
                      (Ebinop Oadd
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                        (Ebinop Oshr
                          (Ecast (Etempvar _faceAngleTemp tshort) tushort)
                          (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                      tfloat))
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sset _x
                      (Ebinop Omul
                        (Ebinop Omul (Etempvar _t'4 tfloat)
                          (Etempvar _t'5 tfloat) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1061158912)) tfloat)
                        tfloat))))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'1)
                      (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                     cc_default))
                      ((Ebinop Oadd
                         (Ebinop Omul (Etempvar _y tfloat)
                           (Etempvar _y tfloat) tfloat)
                         (Ebinop Omul (Etempvar _x tfloat)
                           (Etempvar _x tfloat) tfloat) tfloat) :: nil))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Etempvar _t'1 tfloat)))
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                      tshort cc_default))
                      ((Etempvar _x tfloat) :: (Etempvar _y tfloat) :: nil))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'2 tshort)
                        (Etempvar _angleTemp tshort) tint))))))))
        Sskip))
    (Scall None
      (Evar _drop_and_set_mario_action (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tuint :: tuint :: nil) tint
                                         cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 50333829) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil))))
|}.

Definition f_set_mario_y_vel_based_on_fspeed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_initialVelY, tfloat) :: (_multiplier, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tuchar) :: (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _get_additive_y_vel_for_jumps (Tfunction nil tfloat cc_default))
      nil)
    (Ssequence
      (Sset _t'6
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
        (Ebinop Oadd
          (Ebinop Oadd (Etempvar _initialVelY tfloat) (Etempvar _t'1 tfloat)
            tfloat)
          (Ebinop Omul (Etempvar _t'6 tfloat) (Etempvar _multiplier tfloat)
            tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _squishTimer tuchar))
      (Sifthenelse (Ebinop One (Etempvar _t'4 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Sset _t'2 (Econst_int (Int.repr 1) tint))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
          (Sset _t'2
            (Ecast
              (Ebinop Ogt (Etempvar _t'5 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                tint) tbool)))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Sset _t'3
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Ebinop Omul (Etempvar _t'3 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
            tfloat)))
      Sskip)))
|}.

Definition f_set_mario_action_airborne := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_forwardVel, tfloat) :: (_t'5, tfloat) :: (_t'4, tint) ::
               (_t'3, tfloat) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'23, tfloat) :: (_t'22, tuchar) :: (_t'21, tfloat) ::
               (_t'20, (tptr (Tstruct _Object noattr))) :: (_t'19, tfloat) ::
               (_t'18, (tptr (Tstruct _Object noattr))) :: (_t'17, tfloat) ::
               (_t'16, tfloat) :: (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _Object noattr))) :: (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _squishTimer tuchar))
        (Sifthenelse (Ebinop One (Etempvar _t'22 tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sset _t'1 (Econst_int (Int.repr 1) tint))
          (Ssequence
            (Sset _t'23
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
            (Sset _t'1
              (Ecast
                (Ebinop Oge (Etempvar _t'23 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                  tint) tbool)))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                       (Econst_int (Int.repr 50333825) tint) tint)
          (Sset _t'2 (Ecast (Econst_int (Int.repr 1) tint) tbool))
          (Ssequence
            (Sset _t'2
              (Ecast
                (Ebinop Oeq (Etempvar _action tuint)
                  (Econst_int (Int.repr 276826276) tint) tint) tbool))
            (Sset _t'2 (Ecast (Etempvar _t'2 tint) tbool))))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Sset _action (Econst_int (Int.repr 50333824) tint))
      Sskip))
  (Ssequence
    (Sswitch (Etempvar _action tuint)
      (LScons (Some 50333825)
        (Ssequence
          (Scall None
            (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: tfloat ::
                                                      nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 1112539136)) tfloat) ::
             (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
             nil))
          (Ssequence
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Ebinop Omul (Etempvar _t'21 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                  tfloat)))
            Sbreak))
        (LScons (Some 16779395)
          (Ssequence
            (Ssequence
              (Sset _t'20
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioObj
                  (tptr (Tstruct _Object noattr))))
              (Sassign
                (Efield
                  (Efield
                    (Efield
                      (Efield
                        (Ederef
                          (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _header
                        (Tstruct _ObjectNode noattr)) _gfx
                      (Tstruct _GraphNodeObject noattr)) _animInfo
                    (Tstruct _AnimInfo noattr)) _animID tshort)
                (Eunop Oneg (Econst_int (Int.repr 1) tint) tint)))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Eunop Oneg
                  (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                  tfloat))
              (Ssequence
                (Scall None
                  (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tfloat ::
                                                            tfloat :: nil)
                                                           tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1115160576)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                   nil))
                Sbreak)))
          (LScons (Some 16779394)
            (Ssequence
              (Scall None
                (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tfloat :: tfloat ::
                                                          nil) tvoid
                                                         cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 1116340224)) tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 nil))
              (Ssequence
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
                    (Ebinop Omul (Etempvar _t'19 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                      tfloat)))
                Sbreak))
            (LScons (Some 50333844)
              (Ssequence
                (Scall None
                  (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tfloat ::
                                                            tfloat :: nil)
                                                           tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1118044160)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                   nil))
                Sbreak)
              (LScons (Some 16779401)
                Sskip
                (LScons (Some 16779427)
                  (Ssequence
                    (Sifthenelse (Ebinop Oeq (Etempvar _actionArg tuint)
                                   (Econst_int (Int.repr 0) tint) tint)
                      (Scall None
                        (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tfloat ::
                                                                  tfloat ::
                                                                  nil) tvoid
                                                                 cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat) ::
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                         nil))
                      Sskip)
                    Sbreak)
                  (LScons (Some 16910516)
                    (Ssequence
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
                        (Econst_single (Float32.of_bits (Int.repr 1107034112)) tfloat))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat))
                        Sbreak))
                    (LScons (Some 42010778)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_y_vel_based_on_fspeed (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat) ::
                           (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
                           nil))
                        Sbreak)
                      (LScons (Some 50333824)
                        Sskip
                        (LScons (Some 50333856)
                          (Ssequence
                            (Ssequence
                              (Sset _t'18
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _marioObj
                                  (tptr (Tstruct _Object noattr))))
                              (Sassign
                                (Efield
                                  (Efield
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _animInfo (Tstruct _AnimInfo noattr))
                                  _animID tshort)
                                (Eunop Oneg (Econst_int (Int.repr 1) tint)
                                  tint)))
                            (Ssequence
                              (Scall None
                                (Evar _set_mario_y_vel_based_on_fspeed 
                                (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tfloat :: tfloat :: nil) tvoid cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat) ::
                                 (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
                                 nil))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'17
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat)
                                    (Ebinop Omul (Etempvar _t'17 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                                      tfloat)))
                                Sbreak)))
                          (LScons (Some 50333830)
                            Sskip
                            (LScons (Some 50333837)
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_y_vel_based_on_fspeed 
                                  (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tfloat :: tfloat :: nil) tvoid
                                    cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_single (Float32.of_bits (Int.repr 1115160576)) tfloat) ::
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                                   nil))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'16
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _forwardVel tfloat))
                                    (Sifthenelse (Ebinop Olt
                                                   (Etempvar _t'16 tfloat)
                                                   (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                                                   tint)
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _forwardVel tfloat)
                                        (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat))
                                      Sskip))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _wallKickTimer tuchar)
                                      (Econst_int (Int.repr 0) tint))
                                    Sbreak)))
                              (LScons (Some 16779399)
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_y_vel_based_on_fspeed 
                                    (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tfloat :: tfloat :: nil) tvoid
                                      cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_single (Float32.of_bits (Int.repr 1115160576)) tfloat) ::
                                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                                     nil))
                                  (Ssequence
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _forwardVel tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'15
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _intendedYaw tshort))
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
                                          (Etempvar _t'15 tshort)))
                                      Sbreak)))
                                (LScons (Some 50333829)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'14
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _marioObj
                                          (tptr (Tstruct _Object noattr))))
                                      (Sassign
                                        (Efield
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
                                            _animInfo
                                            (Tstruct _AnimInfo noattr))
                                          _animID tshort)
                                        (Eunop Oneg
                                          (Econst_int (Int.repr 1) tint)
                                          tint)))
                                    (Ssequence
                                      (Scall None
                                        (Evar _set_mario_y_vel_based_on_fspeed 
                                        (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tfloat :: tfloat :: nil) tvoid
                                          cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_single (Float32.of_bits (Int.repr 1109917696)) tfloat) ::
                                         (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
                                         nil))
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
                                          (Eunop Oneg
                                            (Econst_int (Int.repr 8192) tint)
                                            tint))
                                        Sbreak)))
                                  (LScons (Some 16910519)
                                    (Ssequence
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
                                        (Econst_single (Float32.of_bits (Int.repr 1118306304)) tfloat))
                                      (Ssequence
                                        (Sifthenelse (Ebinop Oeq
                                                       (Etempvar _actionArg tuint)
                                                       (Econst_int (Int.repr 0) tint)
                                                       tint)
                                          (Sassign
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _forwardVel tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                          Sskip)
                                        Sbreak))
                                    (LScons (Some 25692298)
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'13
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _forwardVel tfloat))
                                              (Sset _t'3
                                                (Ecast
                                                  (Ebinop Oadd
                                                    (Etempvar _t'13 tfloat)
                                                    (Econst_single (Float32.of_bits (Int.repr 1097859072)) tfloat)
                                                    tfloat) tfloat)))
                                            (Sset _forwardVel
                                              (Etempvar _t'3 tfloat)))
                                          (Sifthenelse (Ebinop Ogt
                                                         (Etempvar _t'3 tfloat)
                                                         (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                                                         tint)
                                            (Sset _forwardVel
                                              (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
                                            Sskip))
                                        (Ssequence
                                          (Scall None
                                            (Evar _mario_set_forward_vel 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tfloat :: nil) tvoid
                                              cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             (Etempvar _forwardVel tfloat) ::
                                             nil))
                                          Sbreak))
                                      (LScons (Some 50333832)
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'12
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _marioObj
                                                (tptr (Tstruct _Object noattr))))
                                            (Sassign
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
                                                  _animInfo
                                                  (Tstruct _AnimInfo noattr))
                                                _animID tshort)
                                              (Eunop Oneg
                                                (Econst_int (Int.repr 1) tint)
                                                tint)))
                                          (Ssequence
                                            (Scall None
                                              (Evar _set_mario_y_vel_based_on_fspeed 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tfloat :: tfloat :: nil)
                                                tvoid cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
                                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                                               nil))
                                            (Ssequence
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'11
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _forwardVel tfloat))
                                                  (Sifthenelse (Ebinop Ogt
                                                                 (Etempvar _t'11 tfloat)
                                                                 (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                                                 tint)
                                                    (Sset _t'4
                                                      (Ecast
                                                        (Econst_int (Int.repr 0) tint)
                                                        tint))
                                                    (Sset _t'4
                                                      (Ecast
                                                        (Econst_int (Int.repr 1) tint)
                                                        tint))))
                                                (Ssequence
                                                  (Sset _t'10
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _marioObj
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
                                                        (Econst_int (Int.repr 34) tint)
                                                        (tptr tint)) tint)
                                                    (Etempvar _t'4 tint))))
                                              (Ssequence
                                                (Ssequence
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'9
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                            (Tstruct _MarioState noattr))
                                                          _forwardVel tfloat))
                                                      (Sset _t'5
                                                        (Ecast
                                                          (Ebinop Omul
                                                            (Etempvar _t'9 tfloat)
                                                            (Econst_single (Float32.of_bits (Int.repr 1069547520)) tfloat)
                                                            tfloat) tfloat)))
                                                    (Sassign
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _forwardVel tfloat)
                                                      (Etempvar _t'5 tfloat)))
                                                  (Sifthenelse (Ebinop Ogt
                                                                 (Etempvar _t'5 tfloat)
                                                                 (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                                                                 tint)
                                                    (Sassign
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _forwardVel tfloat)
                                                      (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
                                                    Sskip))
                                                Sbreak))))
                                        (LScons (Some 25168042)
                                          (Ssequence
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
                                              (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'8
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _forwardVel tfloat))
                                                (Sifthenelse (Ebinop Olt
                                                               (Etempvar _t'8 tfloat)
                                                               (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                                               tint)
                                                  (Sassign
                                                    (Efield
                                                      (Ederef
                                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                        (Tstruct _MarioState noattr))
                                                      _forwardVel tfloat)
                                                    (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))
                                                  Sskip))
                                              Sbreak))
                                          (LScons (Some 25168044)
                                            (Ssequence
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
                                                (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat))
                                              Sbreak)
                                            LSnil))))))))))))))))))))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _peakHeight tfloat)
          (Etempvar _t'7 tfloat)))
      (Ssequence
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
              (Econst_int (Int.repr 256) tint) tuint)))
        (Sreturn (Some (Etempvar _action tuint)))))))
|}.

Definition f_set_mario_action_moving := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_floorClass, tshort) :: (_forwardVel, tfloat) ::
               (_mag, tfloat) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tfloat) ::
               (_t'1, tint) :: (_t'9, tfloat) :: (_t'8, tfloat) ::
               (_t'7, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _mario_get_floor_class (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sset _floorClass (Ecast (Etempvar _t'1 tint) tshort)))
  (Ssequence
    (Sset _forwardVel
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedMag tfloat))
          (Sifthenelse (Ebinop Ole (Etempvar _t'8 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                         tint)
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _intendedMag tfloat))
              (Sset _t'2 (Ecast (Etempvar _t'9 tfloat) tfloat)))
            (Sset _t'2
              (Ecast
                (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                tfloat))))
        (Sset _mag (Etempvar _t'2 tfloat)))
      (Ssequence
        (Sswitch (Etempvar _action tuint)
          (LScons (Some 67109952)
            (Ssequence
              (Sifthenelse (Ebinop One (Etempvar _floorClass tshort)
                             (Econst_int (Int.repr 19) tint) tint)
                (Ssequence
                  (Sifthenelse (Ebinop Ole
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 (Etempvar _forwardVel tfloat) tint)
                    (Sset _t'3
                      (Ecast
                        (Ebinop Olt (Etempvar _forwardVel tfloat)
                          (Etempvar _mag tfloat) tint) tbool))
                    (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'3 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Etempvar _mag tfloat))
                    Sskip))
                Sskip)
              (Ssequence
                (Ssequence
                  (Sset _t'7
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
                            (Ederef
                              (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                    (Econst_int (Int.repr 0) tint)))
                Sbreak))
            (LScons (Some 1090)
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Ole
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 (Etempvar _forwardVel tfloat) tint)
                    (Sset _t'4
                      (Ecast
                        (Ebinop Olt (Etempvar _forwardVel tfloat)
                          (Ebinop Odiv (Etempvar _mag tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                            tfloat) tint) tbool))
                    (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Ebinop Odiv (Etempvar _mag tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                        tfloat))
                    Sskip))
                Sbreak)
              (LScons (Some 80)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _mario_facing_downhill (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tint
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sifthenelse (Etempvar _t'5 tint)
                      (Sset _action (Econst_int (Int.repr 8651858) tint))
                      (Sset _action (Econst_int (Int.repr 9176147) tint))))
                  Sbreak)
                (LScons (Some 81)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _mario_facing_downhill (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tint
                                                       cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sifthenelse (Etempvar _t'6 tint)
                        (Sset _action (Econst_int (Int.repr 8651860) tint))
                        (Sset _action (Econst_int (Int.repr 9176149) tint))))
                    Sbreak)
                  LSnil)))))
        (Sreturn (Some (Etempvar _action tuint)))))))
|}.

Definition f_set_mario_action_submerged := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _action tuint)
                   (Econst_int (Int.repr 17656) tint) tint)
      (Sset _t'1 (Econst_int (Int.repr 1) tint))
      (Sset _t'1
        (Ecast
          (Ebinop Oeq (Etempvar _action tuint)
            (Econst_int (Int.repr 17657) tint) tint) tbool)))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))
      Sskip))
  (Sreturn (Some (Etempvar _action tuint))))
|}.

Definition f_set_mario_action_cutscene := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := nil;
  fn_body :=
(Ssequence
  (Sswitch (Etempvar _action tuint)
    (LScons (Some 6435)
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1112539136)) tfloat))
        Sbreak)
      (LScons (Some 6404)
        (Ssequence
          (Scall None
            (Evar _mario_set_forward_vel (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tfloat :: nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
          Sbreak)
        (LScons (Some 6436)
          (Ssequence
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
               nil))
            Sbreak)
          (LScons (Some 6443)
            Sskip
            (LScons (Some 6444)
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
                  (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat))
                Sbreak)
              LSnil))))))
  (Sreturn (Some (Etempvar _action tuint))))
|}.

Definition f_set_mario_action := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'8, tuint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sswitch (Ebinop Oand (Etempvar _action tuint)
             (Econst_int (Int.repr 448) tint) tuint)
    (LScons (Some 64)
      (Ssequence
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action_moving (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: nil) tuint
                                             cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))
          (Sset _action (Etempvar _t'1 tuint)))
        Sbreak)
      (LScons (Some 128)
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action_airborne (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil)
                                                 tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _action tuint) :: (Etempvar _actionArg tuint) ::
               nil))
            (Sset _action (Etempvar _t'2 tuint)))
          Sbreak)
        (LScons (Some 192)
          (Ssequence
            (Ssequence
              (Scall (Some _t'3)
                (Evar _set_mario_action_submerged (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _action tuint) :: (Etempvar _actionArg tuint) ::
                 nil))
              (Sset _action (Etempvar _t'3 tuint)))
            Sbreak)
          (LScons (Some 256)
            (Ssequence
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _set_mario_action_cutscene (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: tuint :: nil)
                                                     tuint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _action tuint) :: (Etempvar _actionArg tuint) ::
                   nil))
                (Sset _action (Etempvar _t'4 tuint)))
              Sbreak)
            LSnil)))))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint)
        (Ebinop Oand (Etempvar _t'8 tuint)
          (Eunop Onotint
            (Ebinop Oor (Econst_int (Int.repr 65536) tint)
              (Econst_int (Int.repr 131072) tint) tint) tint) tuint)))
    (Ssequence
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'6 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 11) tint) tint) tuint) tint)
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _flags tuint)
              (Ebinop Oand (Etempvar _t'7 tuint)
                (Eunop Onotint (Econst_int (Int.repr 262144) tint) tint)
                tuint)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _prevAction tuint)
            (Etempvar _t'5 tuint)))
        (Ssequence
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint)
            (Etempvar _action tuint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint)
              (Etempvar _actionArg tuint))
            (Ssequence
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionState tushort)
                (Econst_int (Int.repr 0) tint))
              (Ssequence
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort)
                  (Econst_int (Int.repr 0) tint))
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))))))))))
|}.

Definition f_set_jump_from_landing := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, tfloat) :: (_t'9, tuchar) :: (_t'8, tuchar) ::
               (_t'7, tfloat) :: (_t'6, tuint) :: (_t'5, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
    (Sifthenelse (Ebinop Oge (Etempvar _t'10 tfloat)
                   (Econst_single (Float32.of_bits (Int.repr 1093664768)) tfloat)
                   tint)
      (Ssequence
        (Sset _t'11
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _heldObj
            (tptr (Tstruct _Object noattr))))
        (Sifthenelse (Ebinop Oeq
                       (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 1142) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 1143) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'4)
        (Evar _mario_floor_is_steep (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'4 tint)
        (Scall None
          (Evar _set_steep_jump_action (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _doubleJumpTimer tuchar))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tuchar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Sset _t'3 (Econst_int (Int.repr 1) tint))
              (Ssequence
                (Sset _t'9
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar))
                (Sset _t'3
                  (Ecast
                    (Ebinop One (Etempvar _t'9 tuchar)
                      (Econst_int (Int.repr 0) tint) tint) tbool)))))
          (Sifthenelse (Etempvar _t'3 tint)
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 50333824) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _prevAction tuint))
              (Sswitch (Etempvar _t'5 tuint)
                (LScons (Some 67110000)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 50333825) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 67110001)
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 50333825) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      Sbreak)
                    (LScons (Some 201327155)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 50333825) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak)
                      (LScons (Some 67110002)
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'6 tuint)
                                           (Econst_int (Int.repr 8) tint)
                                           tuint)
                              (Scall None
                                (Evar _set_mario_action (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           tuint :: tuint ::
                                                           nil) tuint
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_int (Int.repr 50333844) tint) ::
                                 (Econst_int (Int.repr 0) tint) :: nil))
                              (Ssequence
                                (Sset _t'7
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _forwardVel tfloat))
                                (Sifthenelse (Ebinop Ogt
                                               (Etempvar _t'7 tfloat)
                                               (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                               tint)
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 16779394) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 50333824) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))))))
                          Sbreak)
                        (LScons None
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 50333824) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          LSnil)))))))))))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _doubleJumpTimer tuchar)
        (Econst_int (Int.repr 0) tint))
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_set_jumping_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_currAction, tuint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _currAction
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
      (Sifthenelse (Ebinop Oge (Etempvar _t'4 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1093664768)) tfloat)
                     tint)
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _heldObj
              (tptr (Tstruct _Object noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 1142) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'1 tuint))))
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 1143) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _mario_floor_is_steep (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'3 tint)
          (Scall None
            (Evar _set_steep_jump_action (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))))
      (Sreturn (Some (Econst_int (Int.repr 1) tint))))))
|}.

Definition f_drop_and_set_mario_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_stop_riding_and_holding (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_action (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tuint :: tuint :: nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))
    (Sreturn (Some (Etempvar _t'1 tuint)))))
|}.

Definition f_hurt_and_set_mario_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) ::
                (_hurtCounter, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _hurtCounter tuchar)
    (Etempvar _hurtCounter tshort))
  (Ssequence
    (Scall (Some _t'1)
      (Evar _set_mario_action (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tuint :: tuint :: nil) tuint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))
    (Sreturn (Some (Etempvar _t'1 tuint)))))
|}.

Definition f_check_common_action_exits := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
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
                   (Econst_int (Int.repr 2) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 50333824) tint) ::
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
               (Econst_int (Int.repr 67109952) tint) ::
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
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_check_common_hold_action_exits := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tuint) :: (_t'2, tuint) ::
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
                   (Econst_int (Int.repr 2) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 50333856) tint) ::
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
                     (Econst_int (Int.repr 4) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779425) tint) ::
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
               (Econst_int (Int.repr 1090) tint) ::
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
                         (Econst_int (Int.repr 8) tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 81) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_transition_submerged_to_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tuint) :: (_t'8, tuchar) ::
               (_t'7, (tptr (Tstruct _Camera noattr))) ::
               (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, (tptr (Tstruct _Camera noattr))) ::
               (_t'4, (tptr (Tstruct _Area noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _area (tptr (Tstruct _Area noattr))))
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _t'4 (tptr (Tstruct _Area noattr)))
            (Tstruct _Area noattr)) _camera (tptr (Tstruct _Camera noattr))))
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _area
            (tptr (Tstruct _Area noattr))))
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _t'6 (tptr (Tstruct _Area noattr)))
                (Tstruct _Area noattr)) _camera
              (tptr (Tstruct _Camera noattr))))
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _t'7 (tptr (Tstruct _Camera noattr)))
                  (Tstruct _Camera noattr)) _defMode tuchar))
            (Scall None
              (Evar _set_camera_mode (Tfunction
                                       ((tptr (Tstruct _Camera noattr)) ::
                                        tshort :: tshort :: nil) tvoid
                                       cc_default))
              ((Etempvar _t'5 (tptr (Tstruct _Camera noattr))) ::
               (Etempvar _t'8 tuchar) :: (Econst_int (Int.repr 1) tint) ::
               nil)))))))
  (Ssequence
    (Scall None
      (Evar _vec3s_set (Tfunction
                         ((tptr tshort) :: tshort :: tshort :: tshort :: nil)
                         (tptr tvoid) cc_default))
      ((Efield
         (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
           (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3)) ::
       (Econst_int (Int.repr 0) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Sifthenelse (Ebinop Oeq
                     (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 67109952) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 1090) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))))))
|}.

Definition f_set_water_plunge_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tshort) :: (_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _Camera noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) :: (_t'4, tuchar) ::
               (_t'3, (tptr (Tstruct _Camera noattr))) ::
               (_t'2, (tptr (Tstruct _Area noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'10
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat))
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _forwardVel tfloat)
      (Ebinop Odiv (Etempvar _t'10 tfloat)
        (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
        tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'9
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Sassign
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
        (Ebinop Odiv (Etempvar _t'9 tfloat)
          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
          tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _waterLevel tshort))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Ebinop Osub (Etempvar _t'8 tshort)
            (Econst_int (Int.repr 100) tint) tint)))
      (Ssequence
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 2) tint) (tptr tshort)) tshort)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Scall None
            (Evar _vec3s_set (Tfunction
                               ((tptr tshort) :: tshort :: tshort ::
                                tshort :: nil) (tptr tvoid) cc_default))
            ((Efield
               (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                 (Tstruct _MarioState noattr)) _angleVel (tarray tshort 3)) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'7 tuint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 19) tint) tint) tuint)
                             tint)
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'2
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _area
                    (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef (Etempvar _t'2 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _camera
                      (tptr (Tstruct _Camera noattr))))
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Camera noattr)))
                          (Tstruct _Camera noattr)) _mode tuchar))
                    (Sifthenelse (Ebinop One (Etempvar _t'4 tuchar)
                                   (Econst_int (Int.repr 8) tint) tint)
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
                          (Scall None
                            (Evar _set_camera_mode (Tfunction
                                                     ((tptr (Tstruct _Camera noattr)) ::
                                                      tshort :: tshort ::
                                                      nil) tvoid cc_default))
                            ((Etempvar _t'6 (tptr (Tstruct _Camera noattr))) ::
                             (Econst_int (Int.repr 8) tint) ::
                             (Econst_int (Int.repr 1) tint) :: nil))))
                      Sskip))))
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 805315298) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'1 tuint)))))))))))
|}.

Definition v_sSquishScaleOverTime := {|
  gvar_info := (tarray tuchar 16);
  gvar_init := (Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 50) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 60) ::
                Init_int8 (Int.repr 70) :: Init_int8 (Int.repr 80) ::
                Init_int8 (Int.repr 80) :: Init_int8 (Int.repr 60) ::
                Init_int8 (Int.repr 40) :: Init_int8 (Int.repr 20) ::
                Init_int8 (Int.repr 20) :: Init_int8 (Int.repr 30) ::
                Init_int8 (Int.repr 50) :: Init_int8 (Int.repr 60) ::
                Init_int8 (Int.repr 60) :: Init_int8 (Int.repr 40) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_squish_mario_model := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tuchar) ::
               (_t'14, tuchar) :: (_t'13, tuchar) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuchar) ::
               (_t'10, tuchar) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tuchar) ::
               (_t'4, (tptr (Tstruct _Object noattr))) :: (_t'3, tuchar) ::
               (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _squishTimer tuchar))
  (Sifthenelse (Ebinop One (Etempvar _t'1 tuchar)
                 (Econst_int (Int.repr 255) tint) tint)
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _squishTimer tuchar))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tuchar)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Scall None
            (Evar _vec3f_set (Tfunction
                               ((tptr tfloat) :: tfloat :: tfloat ::
                                tfloat :: nil) (tptr tvoid) cc_default))
            ((Efield
               (Efield
                 (Efield
                   (Ederef (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                     (Tstruct _Object noattr)) _header
                   (Tstruct _ObjectNode noattr)) _gfx
                 (Tstruct _GraphNodeObject noattr)) _scale (tarray tfloat 3)) ::
             (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
             (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
             (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
             nil)))
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _squishTimer tuchar))
          (Sifthenelse (Ebinop Ole (Etempvar _t'3 tuchar)
                         (Econst_int (Int.repr 16) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar)
                  (Ebinop Osub (Etempvar _t'15 tuchar)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
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
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _squishTimer tuchar))
                    (Ssequence
                      (Sset _t'14
                        (Ederef
                          (Ebinop Oadd
                            (Evar _sSquishScaleOverTime (tarray tuchar 16))
                            (Ebinop Osub (Econst_int (Int.repr 15) tint)
                              (Etempvar _t'13 tuchar) tint) (tptr tuchar))
                          tuchar))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                    (Tstruct _Object noattr)) _header
                                  (Tstruct _ObjectNode noattr)) _gfx
                                (Tstruct _GraphNodeObject noattr)) _scale
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 1) tint) (tptr tfloat))
                          tfloat)
                        (Ebinop Osub
                          (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                          (Ebinop Odiv
                            (Ebinop Omul (Etempvar _t'14 tuchar)
                              (Econst_single (Float32.of_bits (Int.repr 1058642330)) tfloat)
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                            tfloat) tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _squishTimer
                          tuchar))
                      (Ssequence
                        (Sset _t'11
                          (Ederef
                            (Ebinop Oadd
                              (Evar _sSquishScaleOverTime (tarray tuchar 16))
                              (Ebinop Osub (Econst_int (Int.repr 15) tint)
                                (Etempvar _t'10 tuchar) tint) (tptr tuchar))
                            tuchar))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _scale
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat)
                          (Ebinop Oadd
                            (Ebinop Odiv
                              (Ebinop Omul (Etempvar _t'11 tuchar)
                                (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                                tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                            tfloat)))))
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
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
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _scale
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 0) tint) (tptr tfloat))
                            tfloat))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _scale
                                (tarray tfloat 3))
                              (Econst_int (Int.repr 2) tint) (tptr tfloat))
                            tfloat) (Etempvar _t'8 tfloat))))))))
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _squishTimer tuchar)
                  (Ebinop Osub (Etempvar _t'5 tuchar)
                    (Econst_int (Int.repr 1) tint) tint)))
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Scall None
                  (Evar _vec3f_set (Tfunction
                                     ((tptr tfloat) :: tfloat :: tfloat ::
                                      tfloat :: nil) (tptr tvoid) cc_default))
                  ((Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _scale
                     (tarray tfloat 3)) ::
                   (Econst_single (Float32.of_bits (Int.repr 1068708659)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat) ::
                   (Econst_single (Float32.of_bits (Int.repr 1068708659)) tfloat) ::
                   nil))))))))
    Sskip))
|}.

Definition f_debug_print_speed_action_normal := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_steepness, tfloat) :: (_floor_nY, tfloat) ::
               (_t'2, tshort) :: (_t'1, tfloat) :: (_t'14, tfloat) ::
               (_t'13, (tptr (Tstruct _Surface noattr))) ::
               (_t'12, tfloat) ::
               (_t'11, (tptr (Tstruct _Surface noattr))) ::
               (_t'10, tfloat) :: (_t'9, (tptr (Tstruct _Surface noattr))) ::
               (_t'8, tfloat) :: (_t'7, (tptr (Tstruct _Surface noattr))) ::
               (_t'6, (tptr (Tstruct _Surface noattr))) :: (_t'5, tfloat) ::
               (_t'4, tuint) :: (_t'3, tschar) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'3 (Evar _gShowDebugText tschar))
  (Sifthenelse (Etempvar _t'3 tschar)
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'8
              (Efield
                (Efield
                  (Ederef (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _normal
                  (Tstruct __670 noattr)) _x tfloat))
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _x tfloat))
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
                          (Tstruct __670 noattr)) _z tfloat))
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'14
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'13 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __670 noattr)) _z tfloat))
                        (Scall (Some _t'1)
                          (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                         cc_default))
                          ((Ebinop Oadd
                             (Ebinop Omul (Etempvar _t'8 tfloat)
                               (Etempvar _t'10 tfloat) tfloat)
                             (Ebinop Omul (Etempvar _t'12 tfloat)
                               (Etempvar _t'14 tfloat) tfloat) tfloat) ::
                           nil))))))))))
        (Sset _steepness (Etempvar _t'1 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Sset _floor_nY
            (Efield
              (Efield
                (Ederef (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr))
              _y tfloat)))
        (Ssequence
          (Ssequence
            (Scall (Some _t'2)
              (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                              cc_default))
              ((Etempvar _floor_nY tfloat) :: (Etempvar _steepness tfloat) ::
               nil))
            (Scall None
              (Evar _print_text_fmt_int (Tfunction
                                          (tint :: tint :: (tptr tschar) ::
                                           tint :: nil) tvoid cc_default))
              ((Econst_int (Int.repr 210) tint) ::
               (Econst_int (Int.repr 88) tint) ::
               (Evar ___stringlit_1 (tarray tschar 7)) ::
               (Ebinop Odiv
                 (Ebinop Omul (Etempvar _t'2 tshort)
                   (Econst_single (Float32.of_bits (Int.repr 1127481344)) tfloat)
                   tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 1191182336)) tfloat)
                 tfloat) :: nil)))
          (Ssequence
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Scall None
                (Evar _print_text_fmt_int (Tfunction
                                            (tint :: tint :: (tptr tschar) ::
                                             tint :: nil) tvoid cc_default))
                ((Econst_int (Int.repr 210) tint) ::
                 (Econst_int (Int.repr 72) tint) ::
                 (Evar ___stringlit_2 (tarray tschar 7)) ::
                 (Etempvar _t'5 tfloat) :: nil)))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _action tuint))
              (Scall None
                (Evar _print_text_fmt_int (Tfunction
                                            (tint :: tint :: (tptr tschar) ::
                                             tint :: nil) tvoid cc_default))
                ((Econst_int (Int.repr 210) tint) ::
                 (Econst_int (Int.repr 56) tint) ::
                 (Evar ___stringlit_3 (tarray tschar 7)) ::
                 (Ebinop Oand (Etempvar _t'4 tuint)
                   (Econst_int (Int.repr 511) tint) tuint) :: nil)))))))
    Sskip))
|}.

Definition f_update_mario_button_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'22, tushort) :: (_t'21, tushort) ::
               (_t'20, (tptr (Tstruct _Controller noattr))) ::
               (_t'19, tushort) :: (_t'18, tushort) ::
               (_t'17, (tptr (Tstruct _Controller noattr))) ::
               (_t'16, tushort) :: (_t'15, tushort) ::
               (_t'14, (tptr (Tstruct _Controller noattr))) ::
               (_t'13, tushort) :: (_t'12, tushort) ::
               (_t'11, (tptr (Tstruct _Controller noattr))) ::
               (_t'10, tushort) :: (_t'9, tushort) ::
               (_t'8, (tptr (Tstruct _Controller noattr))) ::
               (_t'7, tuchar) :: (_t'6, tuchar) :: (_t'5, tuchar) ::
               (_t'4, tushort) :: (_t'3, tuchar) :: (_t'2, tuchar) ::
               (_t'1, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _controller
        (tptr (Tstruct _Controller noattr))))
    (Ssequence
      (Sset _t'21
        (Efield
          (Ederef (Etempvar _t'20 (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _buttonPressed tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'21 tushort)
                     (Econst_int (Int.repr 32768) tint) tint)
        (Ssequence
          (Sset _t'22
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort)
            (Ebinop Oor (Etempvar _t'22 tushort)
              (Econst_int (Int.repr 2) tint) tint)))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _controller
          (tptr (Tstruct _Controller noattr))))
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _t'17 (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _buttonDown tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                       (Econst_int (Int.repr 32768) tint) tint)
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort)
              (Ebinop Oor (Etempvar _t'19 tushort)
                (Econst_int (Int.repr 128) tint) tint)))
          Sskip)))
    (Ssequence
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _squishTimer tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _controller
                  (tptr (Tstruct _Controller noattr))))
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef
                      (Etempvar _t'14 (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _buttonPressed tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                               (Econst_int (Int.repr 16384) tint) tint)
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort)
                      (Ebinop Oor (Etempvar _t'16 tushort)
                        (Econst_int (Int.repr 8192) tint) tint)))
                  Sskip)))
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'12
                    (Efield
                      (Ederef
                        (Etempvar _t'11 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _buttonDown tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'12 tushort)
                                 (Econst_int (Int.repr 8192) tint) tint)
                    (Ssequence
                      (Sset _t'13
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort)
                        (Ebinop Oor (Etempvar _t'13 tushort)
                          (Econst_int (Int.repr 16384) tint) tint)))
                    Sskip)))
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _t'8 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _buttonPressed tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                                 (Econst_int (Int.repr 8192) tint) tint)
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort)
                        (Ebinop Oor (Etempvar _t'10 tushort)
                          (Econst_int (Int.repr 32768) tint) tint)))
                    Sskip)))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                         (Econst_int (Int.repr 2) tint) tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _framesSinceA tuchar)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _framesSinceA tuchar))
              (Sifthenelse (Ebinop Olt (Etempvar _t'5 tuchar)
                             (Econst_int (Int.repr 255) tint) tint)
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _framesSinceA tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _framesSinceA tuchar)
                    (Ebinop Oadd (Etempvar _t'6 tuchar)
                      (Econst_int (Int.repr 1) tint) tint)))
                Sskip))))
        (Ssequence
          (Sset _t'1
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'1 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _framesSinceB tuchar)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _framesSinceB tuchar))
              (Sifthenelse (Ebinop Olt (Etempvar _t'2 tuchar)
                             (Econst_int (Int.repr 255) tint) tint)
                (Ssequence
                  (Sset _t'3
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _framesSinceB tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _framesSinceB tuchar)
                    (Ebinop Oadd (Etempvar _t'3 tuchar)
                      (Econst_int (Int.repr 1) tint) tint)))
                Sskip))))))))
|}.

Definition f_update_mario_joystick_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_controller, (tptr (Tstruct _Controller noattr))) ::
               (_mag, tfloat) :: (_t'1, tshort) :: (_t'12, tfloat) ::
               (_t'11, tfloat) :: (_t'10, tuchar) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Camera noattr))) ::
               (_t'5, (tptr (Tstruct _Area noattr))) :: (_t'4, tushort) ::
               (_t'3, tshort) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _controller
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _controller
      (tptr (Tstruct _Controller noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _controller (tptr (Tstruct _Controller noattr)))
            (Tstruct _Controller noattr)) _stickMag tfloat))
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef
              (Etempvar _controller (tptr (Tstruct _Controller noattr)))
              (Tstruct _Controller noattr)) _stickMag tfloat))
        (Sset _mag
          (Ebinop Omul
            (Ebinop Omul
              (Ebinop Odiv (Etempvar _t'11 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
                tfloat)
              (Ebinop Odiv (Etempvar _t'12 tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
                tfloat) tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _squishTimer tuchar))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tuchar)
                       (Econst_int (Int.repr 0) tint) tint)
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedMag tfloat)
            (Ebinop Odiv (Etempvar _mag tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
              tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedMag tfloat)
            (Ebinop Odiv (Etempvar _mag tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
              tfloat))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'2 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                       tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef
                      (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                      (Tstruct _Controller noattr)) _stickY tfloat))
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _controller (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickX tfloat))
                  (Scall (Some _t'1)
                    (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                                    cc_default))
                    ((Eunop Oneg (Etempvar _t'8 tfloat) tfloat) ::
                     (Etempvar _t'9 tfloat) :: nil))))
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _area
                    (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef (Etempvar _t'5 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _camera
                      (tptr (Tstruct _Camera noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _Camera noattr)))
                          (Tstruct _Camera noattr)) _yaw tshort))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedYaw tshort)
                      (Ebinop Oadd (Etempvar _t'1 tshort)
                        (Etempvar _t'7 tshort) tint))))))
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort)
                (Ebinop Oor (Etempvar _t'4 tushort)
                  (Econst_int (Int.repr 1) tint) tint))))
          (Ssequence
            (Sset _t'3
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
                  (Tstruct _MarioState noattr)) _intendedYaw tshort)
              (Etempvar _t'3 tshort))))))))
|}.

Definition f_update_mario_geometry_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_gasLevel, tfloat) :: (_ceilToFloorDist, tfloat) ::
               (_t'11, tint) :: (_t'10, tint) :: (_t'9, tuint) ::
               (_t'8, tint) :: (_t'7, tuint) :: (_t'6, tshort) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: (_t'48, tfloat) ::
               (_t'47, tfloat) :: (_t'46, tfloat) ::
               (_t'45, (tptr (Tstruct _Object noattr))) :: (_t'44, tfloat) ::
               (_t'43, tfloat) :: (_t'42, tfloat) ::
               (_t'41, (tptr (Tstruct _Surface noattr))) ::
               (_t'40, tfloat) :: (_t'39, tfloat) :: (_t'38, tfloat) ::
               (_t'37, tfloat) :: (_t'36, tfloat) :: (_t'35, tfloat) ::
               (_t'34, (tptr (Tstruct _Surface noattr))) ::
               (_t'33, tfloat) ::
               (_t'32, (tptr (Tstruct _Surface noattr))) ::
               (_t'31, tshort) :: (_t'30, tfloat) :: (_t'29, tushort) ::
               (_t'28, tschar) ::
               (_t'27, (tptr (Tstruct _Surface noattr))) ::
               (_t'26, (tptr (Tstruct _Surface noattr))) ::
               (_t'25, tschar) ::
               (_t'24, (tptr (Tstruct _Surface noattr))) ::
               (_t'23, tfloat) :: (_t'22, tfloat) :: (_t'21, tushort) ::
               (_t'20, tushort) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tushort) :: (_t'16, tshort) :: (_t'15, tfloat) ::
               (_t'14, tushort) :: (_t'13, tfloat) ::
               (_t'12, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _f32_find_wall_collision (Tfunction
                                     ((tptr tfloat) :: (tptr tfloat) ::
                                      (tptr tfloat) :: tfloat :: tfloat ::
                                      nil) tint cc_default))
    ((Ebinop Oadd
       (Efield
         (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
           (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
       (Econst_int (Int.repr 0) tint) (tptr tfloat)) ::
     (Ebinop Oadd
       (Efield
         (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
           (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
       (Econst_int (Int.repr 1) tint) (tptr tfloat)) ::
     (Ebinop Oadd
       (Efield
         (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
           (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
       (Econst_int (Int.repr 2) tint) (tptr tfloat)) ::
     (Econst_single (Float32.of_bits (Int.repr 1114636288)) tfloat) ::
     (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat) :: nil))
  (Ssequence
    (Scall None
      (Evar _f32_find_wall_collision (Tfunction
                                       ((tptr tfloat) :: (tptr tfloat) ::
                                        (tptr tfloat) :: tfloat :: tfloat ::
                                        nil) tint cc_default))
      ((Ebinop Oadd
         (Efield
           (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
             (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
         (Econst_int (Int.repr 0) tint) (tptr tfloat)) ::
       (Ebinop Oadd
         (Efield
           (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
             (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
         (Econst_int (Int.repr 1) tint) (tptr tfloat)) ::
       (Ebinop Oadd
         (Efield
           (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
             (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
         (Econst_int (Int.repr 2) tint) (tptr tfloat)) ::
       (Econst_single (Float32.of_bits (Int.repr 1106247680)) tfloat) ::
       (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'46
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
          (Ssequence
            (Sset _t'47
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
            (Ssequence
              (Sset _t'48
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                    (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
              (Scall (Some _t'1)
                (Evar _find_floor (Tfunction
                                    (tfloat :: tfloat :: tfloat ::
                                     (tptr (tptr (Tstruct _Surface noattr))) ::
                                     nil) tfloat cc_default))
                ((Etempvar _t'46 tfloat) :: (Etempvar _t'47 tfloat) ::
                 (Etempvar _t'48 tfloat) ::
                 (Eaddrof
                   (Efield
                     (Ederef
                       (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                       (Tstruct _MarioState noattr)) _floor
                     (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floorHeight tfloat)
          (Etempvar _t'1 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'41
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Sifthenelse (Ebinop Oeq
                         (Etempvar _t'41 (tptr (Tstruct _Surface noattr)))
                         (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                         tint)
            (Ssequence
              (Ssequence
                (Sset _t'45
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
                           (Etempvar _t'45 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _pos
                     (tarray tfloat 3)) :: nil)))
              (Ssequence
                (Ssequence
                  (Sset _t'42
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'43
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tfloat)) tfloat))
                    (Ssequence
                      (Sset _t'44
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _pos
                              (tarray tfloat 3))
                            (Econst_int (Int.repr 2) tint) (tptr tfloat))
                          tfloat))
                      (Scall (Some _t'2)
                        (Evar _find_floor (Tfunction
                                            (tfloat :: tfloat :: tfloat ::
                                             (tptr (tptr (Tstruct _Surface noattr))) ::
                                             nil) tfloat cc_default))
                        ((Etempvar _t'42 tfloat) ::
                         (Etempvar _t'43 tfloat) ::
                         (Etempvar _t'44 tfloat) ::
                         (Eaddrof
                           (Efield
                             (Ederef
                               (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                               (Tstruct _MarioState noattr)) _floor
                             (tptr (Tstruct _Surface noattr)))
                           (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _floorHeight tfloat)
                  (Etempvar _t'2 tfloat))))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'40
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floorHeight tfloat))
              (Scall (Some _t'3)
                (Evar _vec3f_find_ceil (Tfunction
                                         ((tptr tfloat) :: tfloat ::
                                          (tptr (tptr (Tstruct _Surface noattr))) ::
                                          nil) tfloat cc_default))
                ((Efield
                   (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                     (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
                 (Etempvar _t'40 tfloat) ::
                 (Eaddrof
                   (Efield
                     (Ederef
                       (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                       (Tstruct _MarioState noattr)) _ceil
                     (tptr (Tstruct _Surface noattr)))
                   (tptr (tptr (Tstruct _Surface noattr)))) :: nil)))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _ceilHeight tfloat)
              (Etempvar _t'3 tfloat)))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'38
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _pos
                        (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tfloat)) tfloat))
                (Ssequence
                  (Sset _t'39
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                        (tptr tfloat)) tfloat))
                  (Scall (Some _t'4)
                    (Evar _find_poison_gas_level (Tfunction
                                                   (tfloat :: tfloat :: nil)
                                                   tfloat cc_default))
                    ((Etempvar _t'38 tfloat) :: (Etempvar _t'39 tfloat) ::
                     nil))))
              (Sset _gasLevel (Etempvar _t'4 tfloat)))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'36
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _pos
                          (tarray tfloat 3)) (Econst_int (Int.repr 0) tint)
                        (tptr tfloat)) tfloat))
                  (Ssequence
                    (Sset _t'37
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _pos
                            (tarray tfloat 3)) (Econst_int (Int.repr 2) tint)
                          (tptr tfloat)) tfloat))
                    (Scall (Some _t'5)
                      (Evar _find_water_level (Tfunction
                                                (tfloat :: tfloat :: nil)
                                                tfloat cc_default))
                      ((Etempvar _t'36 tfloat) :: (Etempvar _t'37 tfloat) ::
                       nil))))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _waterLevel tshort)
                  (Etempvar _t'5 tfloat)))
              (Ssequence
                (Sset _t'12
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _floor
                    (tptr (Tstruct _Surface noattr))))
                (Sifthenelse (Ebinop One
                               (Etempvar _t'12 (tptr (Tstruct _Surface noattr)))
                               (Ecast (Econst_int (Int.repr 0) tint)
                                 (tptr tvoid)) tint)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'32
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floor
                            (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'33
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'32 (tptr (Tstruct _Surface noattr)))
                                  (Tstruct _Surface noattr)) _normal
                                (Tstruct __670 noattr)) _z tfloat))
                          (Ssequence
                            (Sset _t'34
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _floor
                                (tptr (Tstruct _Surface noattr))))
                            (Ssequence
                              (Sset _t'35
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'34 (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _normal
                                    (Tstruct __670 noattr)) _x tfloat))
                              (Scall (Some _t'6)
                                (Evar _atan2s (Tfunction
                                                (tfloat :: tfloat :: nil)
                                                tshort cc_default))
                                ((Etempvar _t'33 tfloat) ::
                                 (Etempvar _t'35 tfloat) :: nil))))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floorAngle tshort)
                        (Etempvar _t'6 tshort)))
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _mario_get_terrain_sound_addend (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tuint
                                                                  cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr))
                            _terrainSoundAddend tuint) (Etempvar _t'7 tuint)))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'30
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
                              (Sset _t'31
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _waterLevel
                                  tshort))
                              (Sifthenelse (Ebinop Ogt
                                             (Etempvar _t'30 tfloat)
                                             (Ebinop Osub
                                               (Etempvar _t'31 tshort)
                                               (Econst_int (Int.repr 40) tint)
                                               tint) tint)
                                (Ssequence
                                  (Scall (Some _t'9)
                                    (Evar _mario_floor_is_slippery (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _t'8
                                    (Ecast (Etempvar _t'9 tuint) tbool)))
                                (Sset _t'8 (Econst_int (Int.repr 0) tint)))))
                          (Sifthenelse (Etempvar _t'8 tint)
                            (Ssequence
                              (Sset _t'29
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort)
                                (Ebinop Oor (Etempvar _t'29 tushort)
                                  (Econst_int (Int.repr 8) tint) tint)))
                            Sskip))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'24
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _floor
                                  (tptr (Tstruct _Surface noattr))))
                              (Ssequence
                                (Sset _t'25
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'24 (tptr (Tstruct _Surface noattr)))
                                      (Tstruct _Surface noattr)) _flags
                                    tschar))
                                (Sifthenelse (Ebinop Oand
                                               (Etempvar _t'25 tschar)
                                               (Ebinop Oshl
                                                 (Econst_int (Int.repr 1) tint)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint) tint)
                                  (Sset _t'11 (Econst_int (Int.repr 1) tint))
                                  (Ssequence
                                    (Sset _t'26
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _ceil
                                        (tptr (Tstruct _Surface noattr))))
                                    (Sifthenelse (Etempvar _t'26 (tptr (Tstruct _Surface noattr)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'27
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _ceil
                                              (tptr (Tstruct _Surface noattr))))
                                          (Ssequence
                                            (Sset _t'28
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'27 (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _flags tschar))
                                            (Sset _t'11
                                              (Ecast
                                                (Ebinop Oand
                                                  (Etempvar _t'28 tschar)
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tint) tint) tbool))))
                                        (Sset _t'11
                                          (Ecast (Etempvar _t'11 tint) tbool)))
                                      (Sset _t'11
                                        (Ecast (Econst_int (Int.repr 0) tint)
                                          tbool)))))))
                            (Sifthenelse (Etempvar _t'11 tint)
                              (Ssequence
                                (Ssequence
                                  (Sset _t'22
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _ceilHeight tfloat))
                                  (Ssequence
                                    (Sset _t'23
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _floorHeight tfloat))
                                    (Sset _ceilToFloorDist
                                      (Ebinop Osub (Etempvar _t'22 tfloat)
                                        (Etempvar _t'23 tfloat) tfloat))))
                                (Ssequence
                                  (Sifthenelse (Ebinop Ole
                                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                                 (Etempvar _ceilToFloorDist tfloat)
                                                 tint)
                                    (Sset _t'10
                                      (Ecast
                                        (Ebinop Ole
                                          (Etempvar _ceilToFloorDist tfloat)
                                          (Econst_single (Float32.of_bits (Int.repr 1125515264)) tfloat)
                                          tint) tbool))
                                    (Sset _t'10
                                      (Econst_int (Int.repr 0) tint)))
                                  (Sifthenelse (Etempvar _t'10 tint)
                                    (Ssequence
                                      (Sset _t'21
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _input tushort))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _input tushort)
                                        (Ebinop Oor (Etempvar _t'21 tushort)
                                          (Econst_int (Int.repr 64) tint)
                                          tint)))
                                    Sskip)))
                              Sskip))
                          (Ssequence
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
                              (Ssequence
                                (Sset _t'19
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _floorHeight tfloat))
                                (Sifthenelse (Ebinop Ogt
                                               (Etempvar _t'18 tfloat)
                                               (Ebinop Oadd
                                                 (Etempvar _t'19 tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                 tfloat) tint)
                                  (Ssequence
                                    (Sset _t'20
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _input tushort))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _input tushort)
                                      (Ebinop Oor (Etempvar _t'20 tushort)
                                        (Econst_int (Int.repr 4) tint) tint)))
                                  Sskip)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'15
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
                                  (Sset _t'16
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _waterLevel tshort))
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _t'15 tfloat)
                                                 (Ebinop Osub
                                                   (Etempvar _t'16 tshort)
                                                   (Econst_int (Int.repr 10) tint)
                                                   tint) tint)
                                    (Ssequence
                                      (Sset _t'17
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _input tushort))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _input tushort)
                                        (Ebinop Oor (Etempvar _t'17 tushort)
                                          (Econst_int (Int.repr 512) tint)
                                          tint)))
                                    Sskip)))
                              (Ssequence
                                (Sset _t'13
                                  (Ederef
                                    (Ebinop Oadd
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _pos
                                        (tarray tfloat 3))
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tfloat)) tfloat))
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _t'13 tfloat)
                                               (Ebinop Osub
                                                 (Etempvar _gasLevel tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                 tfloat) tint)
                                  (Ssequence
                                    (Sset _t'14
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _input tushort))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _input tushort)
                                      (Ebinop Oor (Etempvar _t'14 tushort)
                                        (Econst_int (Int.repr 256) tint)
                                        tint)))
                                  Sskip))))))))
                  (Scall None
                    (Evar _level_trigger_warp (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 18) tint) :: nil)))))))))))
|}.

Definition f_update_mario_inputs := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'16, tuint) :: (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, tuint) :: (_t'13, tushort) :: (_t'12, tshort) ::
               (_t'11, tuint) :: (_t'10, tshort) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tushort) :: (_t'6, tint) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: (_t'4, tuchar) ::
               (_t'3, tuchar) :: (_t'2, tuchar) :: (_t'1, tuchar) :: nil);
  fn_body :=
(Ssequence
  (Sassign
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _particleFlags tuint)
    (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort)
      (Econst_int (Int.repr 0) tint))
    (Ssequence
      (Ssequence
        (Sset _t'15
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _collidedObjInteractTypes tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _collidedObjInteractTypes
              tuint) (Etempvar _t'16 tuint))))
      (Ssequence
        (Ssequence
          (Sset _t'14
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _flags tuint)
            (Ebinop Oand (Etempvar _t'14 tuint)
              (Econst_int (Int.repr 16777215) tint) tuint)))
        (Ssequence
          (Scall None
            (Evar _update_mario_button_inputs (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Scall None
              (Evar _update_mario_joystick_inputs (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _update_mario_geometry_inputs (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Scall None
                  (Evar _debug_print_speed_action_normal (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Sset _t'10 (Evar _gCameraMovementFlags tshort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'10 tshort)
                                   (Econst_int (Int.repr 8192) tint) tint)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sifthenelse (Ebinop Oand (Etempvar _t'11 tuint)
                                       (Ebinop Oshl
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 26) tint)
                                         tint) tuint)
                          (Ssequence
                            (Sset _t'13
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _input
                                tushort))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _input
                                tushort)
                              (Ebinop Oor (Etempvar _t'13 tushort)
                                (Econst_int (Int.repr 16) tint) tint)))
                          (Ssequence
                            (Sset _t'12 (Evar _gCameraMovementFlags tshort))
                            (Sassign (Evar _gCameraMovementFlags tshort)
                              (Ebinop Oand (Etempvar _t'12 tshort)
                                (Eunop Onotint
                                  (Econst_int (Int.repr 8192) tint) tint)
                                tint)))))
                      Sskip))
                  (Ssequence
                    (Ssequence
                      (Sset _t'8
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _input tushort))
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand (Etempvar _t'8 tushort)
                                       (Ebinop Oor
                                         (Econst_int (Int.repr 1) tint)
                                         (Econst_int (Int.repr 2) tint) tint)
                                       tint) tint)
                        (Ssequence
                          (Sset _t'9
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _input tushort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _input tushort)
                            (Ebinop Oor (Etempvar _t'9 tushort)
                              (Econst_int (Int.repr 32) tint) tint)))
                        Sskip))
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
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'5 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _rawData
                                    (Tunion __665 noattr)) _asS32
                                  (tarray tint 80))
                                (Econst_int (Int.repr 43) tint) (tptr tint))
                              tint))
                          (Sifthenelse (Ebinop Oand (Etempvar _t'6 tint)
                                         (Ebinop Oor
                                           (Ebinop Oor
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 0) tint)
                                               tint)
                                             (Ebinop Oshl
                                               (Econst_int (Int.repr 1) tint)
                                               (Econst_int (Int.repr 1) tint)
                                               tint) tint)
                                           (Ebinop Oshl
                                             (Econst_int (Int.repr 1) tint)
                                             (Econst_int (Int.repr 4) tint)
                                             tint) tint) tint)
                            (Ssequence
                              (Sset _t'7
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _input
                                  tushort)
                                (Ebinop Oor (Etempvar _t'7 tushort)
                                  (Econst_int (Int.repr 1024) tint) tint)))
                            Sskip)))
                      (Ssequence
                        (Scall None
                          (Evar _stub_mario_step_1 (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'3
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _wallKickTimer tuchar))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tuchar)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'4
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _wallKickTimer tuchar))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _wallKickTimer tuchar)
                                  (Ebinop Osub (Etempvar _t'4 tuchar)
                                    (Econst_int (Int.repr 1) tint) tint)))
                              Sskip))
                          (Ssequence
                            (Sset _t'1
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _doubleJumpTimer tuchar))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tuchar)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Ssequence
                                (Sset _t'2
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _doubleJumpTimer tuchar))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _doubleJumpTimer tuchar)
                                  (Ebinop Osub (Etempvar _t'2 tuchar)
                                    (Econst_int (Int.repr 1) tint) tint)))
                              Sskip)))))))))))))))
|}.

Definition f_set_submerged_cam_preset_and_spawn_bubbles := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_heightBelowWater, tfloat) :: (_camPreset, tshort) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'21, tfloat) :: (_t'20, tshort) :: (_t'19, tuchar) ::
               (_t'18, (tptr (Tstruct _Camera noattr))) ::
               (_t'17, (tptr (Tstruct _Area noattr))) ::
               (_t'16, (tptr (Tstruct _Camera noattr))) ::
               (_t'15, (tptr (Tstruct _Area noattr))) ::
               (_t'14, (tptr (Tstruct _Camera noattr))) ::
               (_t'13, (tptr (Tstruct _Area noattr))) ::
               (_t'12, (tptr (Tstruct _Camera noattr))) ::
               (_t'11, (tptr (Tstruct _Area noattr))) :: (_t'10, tshort) ::
               (_t'9, tshort) :: (_t'8, tfloat) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tuint) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'4
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _action tuint))
  (Sifthenelse (Ebinop Oeq
                 (Ebinop Oand (Etempvar _t'4 tuint)
                   (Econst_int (Int.repr 448) tint) tuint)
                 (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                   (Econst_int (Int.repr 6) tint) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'20
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _waterLevel tshort))
        (Ssequence
          (Sset _t'21
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sset _heightBelowWater
            (Ebinop Osub
              (Ecast
                (Ebinop Osub (Etempvar _t'20 tshort)
                  (Econst_int (Int.repr 80) tint) tint) tfloat)
              (Etempvar _t'21 tfloat) tfloat))))
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
                    (Tstruct _Camera noattr)) _mode tuchar))
              (Sset _camPreset (Ecast (Etempvar _t'19 tuchar) tshort)))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Ebinop Oand (Etempvar _t'5 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 14) tint) tint) tuint)
            (Sifthenelse (Ebinop One (Etempvar _camPreset tshort)
                           (Econst_int (Int.repr 4) tint) tint)
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _area
                    (tptr (Tstruct _Area noattr))))
                (Ssequence
                  (Sset _t'16
                    (Efield
                      (Ederef (Etempvar _t'15 (tptr (Tstruct _Area noattr)))
                        (Tstruct _Area noattr)) _camera
                      (tptr (Tstruct _Camera noattr))))
                  (Scall None
                    (Evar _set_camera_mode (Tfunction
                                             ((tptr (Tstruct _Camera noattr)) ::
                                              tshort :: tshort :: nil) tvoid
                                             cc_default))
                    ((Etempvar _t'16 (tptr (Tstruct _Camera noattr))) ::
                     (Econst_int (Int.repr 4) tint) ::
                     (Econst_int (Int.repr 1) tint) :: nil))))
              Sskip)
            (Ssequence
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _heightBelowWater tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1145569280)) tfloat)
                               tint)
                  (Sset _t'1
                    (Ecast
                      (Ebinop One (Etempvar _camPreset tshort)
                        (Econst_int (Int.repr 3) tint) tint) tbool))
                  (Sset _t'1 (Econst_int (Int.repr 0) tint)))
                (Sifthenelse (Etempvar _t'1 tint)
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
                            (Tstruct _Area noattr)) _camera
                          (tptr (Tstruct _Camera noattr))))
                      (Scall None
                        (Evar _set_camera_mode (Tfunction
                                                 ((tptr (Tstruct _Camera noattr)) ::
                                                  tshort :: tshort :: nil)
                                                 tvoid cc_default))
                        ((Etempvar _t'14 (tptr (Tstruct _Camera noattr))) ::
                         (Econst_int (Int.repr 3) tint) ::
                         (Econst_int (Int.repr 1) tint) :: nil))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sifthenelse (Ebinop Olt
                                 (Etempvar _heightBelowWater tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1137180672)) tfloat)
                                 tint)
                    (Sset _t'2
                      (Ecast
                        (Ebinop One (Etempvar _camPreset tshort)
                          (Econst_int (Int.repr 8) tint) tint) tbool))
                    (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                  (Sifthenelse (Etempvar _t'2 tint)
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
                        (Scall None
                          (Evar _set_camera_mode (Tfunction
                                                   ((tptr (Tstruct _Camera noattr)) ::
                                                    tshort :: tshort :: nil)
                                                   tvoid cc_default))
                          ((Etempvar _t'12 (tptr (Tstruct _Camera noattr))) ::
                           (Econst_int (Int.repr 8) tint) ::
                           (Econst_int (Int.repr 1) tint) :: nil))))
                    Sskip))
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Eunop Onotbool
                                 (Ebinop Oand (Etempvar _t'6 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 12) tint) tint)
                                   tuint) tint)
                    (Ssequence
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
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _waterLevel
                              tshort))
                          (Sifthenelse (Ebinop Olt (Etempvar _t'8 tfloat)
                                         (Ecast
                                           (Ebinop Osub
                                             (Etempvar _t'9 tshort)
                                             (Econst_int (Int.repr 160) tint)
                                             tint) tfloat) tint)
                            (Sset _t'3 (Econst_int (Int.repr 1) tint))
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
                              (Sset _t'3
                                (Ecast
                                  (Ebinop Olt (Etempvar _t'10 tshort)
                                    (Eunop Oneg
                                      (Econst_int (Int.repr 2048) tint) tint)
                                    tint) tbool))))))
                      (Sifthenelse (Etempvar _t'3 tint)
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
                                (Econst_int (Int.repr 5) tint) tint) tuint)))
                        Sskip))
                    Sskip))))))))
    Sskip))
|}.

Definition f_update_mario_health := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_terrainIsSnow, tint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'33, tuint) :: (_t'32, tushort) ::
               (_t'31, tschar) :: (_t'30, tuint) :: (_t'29, tshort) ::
               (_t'28, tuint) :: (_t'27, tuint) :: (_t'26, tushort) ::
               (_t'25, (tptr (Tstruct _Area noattr))) :: (_t'24, tshort) ::
               (_t'23, tfloat) :: (_t'22, tshort) :: (_t'21, tshort) ::
               (_t'20, tschar) :: (_t'19, tuchar) :: (_t'18, tuchar) ::
               (_t'17, tshort) :: (_t'16, tuchar) :: (_t'15, tuchar) ::
               (_t'14, tshort) :: (_t'13, tuchar) :: (_t'12, tuchar) ::
               (_t'11, tshort) :: (_t'10, tshort) :: (_t'9, tshort) ::
               (_t'8, tuint) :: (_t'7, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'7
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _health tshort))
  (Sifthenelse (Ebinop Oge (Etempvar _t'7 tshort)
                 (Econst_int (Int.repr 256) tint) tint)
    (Ssequence
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _healCounter tuchar))
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _hurtCounter tuchar))
          (Sifthenelse (Ebinop Oeq
                         (Ebinop Oor (Ecast (Etempvar _t'18 tuchar) tuint)
                           (Ecast (Etempvar _t'19 tuchar) tuint) tuint)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'32
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'32 tushort)
                               (Econst_int (Int.repr 256) tint) tint)
                  (Ssequence
                    (Sset _t'33
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sset _t'5
                      (Ecast
                        (Eunop Onotbool
                          (Ebinop Oand (Etempvar _t'33 tuint)
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 12) tint) tint) tuint)
                          tint) tbool)))
                  (Sset _t'5 (Econst_int (Int.repr 0) tint))))
              (Sifthenelse (Etempvar _t'5 tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'30
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _flags tuint))
                    (Sifthenelse (Eunop Onotbool
                                   (Ebinop Oand (Etempvar _t'30 tuint)
                                     (Econst_int (Int.repr 4) tint) tuint)
                                   tint)
                      (Ssequence
                        (Sset _t'31 (Evar _gDebugLevelSelect tschar))
                        (Sset _t'1
                          (Ecast
                            (Eunop Onotbool (Etempvar _t'31 tschar) tint)
                            tbool)))
                      (Sset _t'1 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'1 tint)
                    (Ssequence
                      (Sset _t'29
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _health tshort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _health tshort)
                        (Ebinop Osub (Etempvar _t'29 tshort)
                          (Econst_int (Int.repr 4) tint) tint)))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'27 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 13) tint) tint)
                                   tuint)
                      (Ssequence
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _action tuint))
                        (Sset _t'4
                          (Ecast
                            (Eunop Onotbool
                              (Ebinop Oand (Etempvar _t'28 tuint)
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 12) tint) tint)
                                tuint) tint) tbool)))
                      (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'25
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _area
                            (tptr (Tstruct _Area noattr))))
                        (Ssequence
                          (Sset _t'26
                            (Efield
                              (Ederef
                                (Etempvar _t'25 (tptr (Tstruct _Area noattr)))
                                (Tstruct _Area noattr)) _terrainType tushort))
                          (Sset _terrainIsSnow
                            (Ebinop Oeq
                              (Ebinop Oand (Etempvar _t'26 tushort)
                                (Econst_int (Int.repr 7) tint) tint)
                              (Econst_int (Int.repr 2) tint) tint))))
                      (Ssequence
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
                          (Ssequence
                            (Sset _t'24
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _waterLevel
                                tshort))
                            (Sifthenelse (Ebinop Oge (Etempvar _t'23 tfloat)
                                           (Ebinop Osub
                                             (Etempvar _t'24 tshort)
                                             (Econst_int (Int.repr 140) tint)
                                             tint) tint)
                              (Sset _t'3
                                (Ecast
                                  (Eunop Onotbool
                                    (Etempvar _terrainIsSnow tint) tint)
                                  tbool))
                              (Sset _t'3 (Econst_int (Int.repr 0) tint)))))
                        (Sifthenelse (Etempvar _t'3 tint)
                          (Ssequence
                            (Sset _t'22
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _health
                                tshort))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _health
                                tshort)
                              (Ebinop Oadd (Etempvar _t'22 tshort)
                                (Econst_int (Int.repr 26) tint) tint)))
                          (Ssequence
                            (Sset _t'20 (Evar _gDebugLevelSelect tschar))
                            (Sifthenelse (Eunop Onotbool
                                           (Etempvar _t'20 tschar) tint)
                              (Ssequence
                                (Sifthenelse (Etempvar _terrainIsSnow tint)
                                  (Sset _t'2
                                    (Ecast (Econst_int (Int.repr 3) tint)
                                      tint))
                                  (Sset _t'2
                                    (Ecast (Econst_int (Int.repr 1) tint)
                                      tint)))
                                (Ssequence
                                  (Sset _t'21
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _health
                                      tshort))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _health
                                      tshort)
                                    (Ebinop Osub (Etempvar _t'21 tshort)
                                      (Etempvar _t'2 tint) tint))))
                              Sskip)))))
                    Sskip))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'15
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _healCounter tuchar))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'15 tuchar)
                         (Econst_int (Int.repr 0) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort)
                  (Ebinop Oadd (Etempvar _t'17 tshort)
                    (Econst_int (Int.repr 64) tint) tint)))
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _healCounter tuchar))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _healCounter tuchar)
                  (Ebinop Osub (Etempvar _t'16 tuchar)
                    (Econst_int (Int.repr 1) tint) tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'12
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _hurtCounter tuchar))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'12 tuchar)
                           (Econst_int (Int.repr 0) tint) tint)
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort)
                    (Ebinop Osub (Etempvar _t'14 tshort)
                      (Econst_int (Int.repr 64) tint) tint)))
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _hurtCounter tuchar))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _hurtCounter tuchar)
                    (Ebinop Osub (Etempvar _t'13 tuchar)
                      (Econst_int (Int.repr 1) tint) tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _health tshort))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'11 tshort)
                             (Econst_int (Int.repr 2176) tint) tint)
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort)
                  (Econst_int (Int.repr 2176) tint))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _health tshort))
                (Sifthenelse (Ebinop Olt (Etempvar _t'10 tshort)
                               (Econst_int (Int.repr 256) tint) tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _health tshort)
                    (Econst_int (Int.repr 255) tint))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _action tuint))
                  (Sifthenelse (Ebinop Oeq
                                 (Ebinop Oand (Etempvar _t'8 tuint)
                                   (Econst_int (Int.repr 448) tint) tuint)
                                 (Ebinop Oshl (Econst_int (Int.repr 3) tint)
                                   (Econst_int (Int.repr 6) tint) tint) tint)
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _health tshort))
                      (Sset _t'6
                        (Ecast
                          (Ebinop Olt (Etempvar _t'9 tshort)
                            (Econst_int (Int.repr 768) tint) tint) tbool)))
                    (Sset _t'6 (Econst_int (Int.repr 0) tint))))
                (Sifthenelse (Etempvar _t'6 tint)
                  (Scall None
                    (Evar _play_sound (Tfunction
                                        (tint :: (tptr tfloat) :: nil) tvoid
                                        cc_default))
                    ((Ebinop Oor
                       (Ebinop Oor
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 1) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 24) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                           (Econst_int (Int.repr 134217728) tint) tint)
                         tuint) (Econst_int (Int.repr 1) tint) tuint) ::
                     (Evar _gGlobalSoundSource (tarray tfloat 3)) :: nil))
                  Sskip)))))))
    Sskip))
|}.

Definition f_update_mario_info_for_cam := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tuint) ::
               (_t'6, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'5, tuint) ::
               (_t'4, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'3, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'2, (tptr (Tstruct _PlayerCameraState noattr))) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioBodyState
        (tptr (Tstruct _MarioBodyState noattr))))
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _action tuint))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'6 (tptr (Tstruct _MarioBodyState noattr)))
            (Tstruct _MarioBodyState noattr)) _action tuint)
        (Etempvar _t'7 tuint))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _statusForCamera
          (tptr (Tstruct _PlayerCameraState noattr))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sassign
          (Efield
            (Ederef
              (Etempvar _t'4 (tptr (Tstruct _PlayerCameraState noattr)))
              (Tstruct _PlayerCameraState noattr)) _action tuint)
          (Etempvar _t'5 tuint))))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _statusForCamera
            (tptr (Tstruct _PlayerCameraState noattr))))
        (Scall None
          (Evar _vec3s_copy (Tfunction
                              ((tptr tshort) :: (tptr tshort) :: nil)
                              (tptr tvoid) cc_default))
          ((Efield
             (Ederef
               (Etempvar _t'3 (tptr (Tstruct _PlayerCameraState noattr)))
               (Tstruct _PlayerCameraState noattr)) _faceAngle
             (tarray tshort 3)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3)) ::
           nil)))
      (Ssequence
        (Sset _t'1
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _flags tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'1 tuint)
                         (Econst_int (Int.repr 33554432) tint) tuint) tint)
          (Ssequence
            (Sset _t'2
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _statusForCamera
                (tptr (Tstruct _PlayerCameraState noattr))))
            (Scall None
              (Evar _vec3f_copy (Tfunction
                                  ((tptr tfloat) :: (tptr tfloat) :: nil)
                                  (tptr tvoid) cc_default))
              ((Efield
                 (Ederef
                   (Etempvar _t'2 (tptr (Tstruct _PlayerCameraState noattr)))
                   (Tstruct _PlayerCameraState noattr)) _pos
                 (tarray tfloat 3)) ::
               (Efield
                 (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                   (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
               nil)))
          Sskip)))))
|}.

Definition f_mario_reset_bodystate := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'1, tuint) :: nil);
  fn_body :=
(Ssequence
  (Sset _bodyState
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioBodyState
      (tptr (Tstruct _MarioBodyState noattr))))
  (Ssequence
    (Sassign
      (Efield
        (Ederef (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
          (Tstruct _MarioBodyState noattr)) _capState tschar)
      (Econst_int (Int.repr 1) tint))
    (Ssequence
      (Sassign
        (Efield
          (Ederef
            (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
            (Tstruct _MarioBodyState noattr)) _eyeState tschar)
        (Econst_int (Int.repr 0) tint))
      (Ssequence
        (Sassign
          (Efield
            (Ederef
              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
              (Tstruct _MarioBodyState noattr)) _handState tschar)
          (Econst_int (Int.repr 0) tint))
        (Ssequence
          (Sassign
            (Efield
              (Ederef
                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                (Tstruct _MarioBodyState noattr)) _modelState tshort)
            (Econst_int (Int.repr 0) tint))
          (Ssequence
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _wingFlutter tschar)
              (Econst_int (Int.repr 0) tint))
            (Ssequence
              (Sset _t'1
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _flags tuint)
                (Ebinop Oand (Etempvar _t'1 tuint)
                  (Eunop Onotint (Econst_int (Int.repr 64) tint) tint) tuint)))))))))
|}.

Definition f_sink_mario_in_quicksand := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_o, (tptr (Tstruct _Object noattr))) :: (_t'7, tfloat) ::
               (_t'6, tfloat) ::
               (_t'5, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'4, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'3, (tptr (tarray (tarray tfloat 4) 4))) ::
               (_t'2, tfloat) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _o
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Efield
            (Efield
              (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                (Tstruct _Object noattr)) _header
              (Tstruct _ObjectNode noattr)) _gfx
            (Tstruct _GraphNodeObject noattr)) _throwMatrix
          (tptr (tarray (tarray tfloat 4) 4))))
      (Sifthenelse (Etempvar _t'3 (tptr (tarray (tarray tfloat 4) 4)))
        (Ssequence
          (Sset _t'4
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _throwMatrix
              (tptr (tarray (tarray tfloat 4) 4))))
          (Ssequence
            (Sset _t'5
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _throwMatrix
                (tptr (tarray (tarray tfloat 4) 4))))
            (Ssequence
              (Sset _t'6
                (Ederef
                  (Ebinop Oadd
                    (Ederef
                      (Ebinop Oadd
                        (Ederef
                          (Etempvar _t'5 (tptr (tarray (tarray tfloat 4) 4)))
                          (tarray (tarray tfloat 4) 4))
                        (Econst_int (Int.repr 3) tint)
                        (tptr (tarray tfloat 4))) (tarray tfloat 4))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Ederef
                        (Ebinop Oadd
                          (Ederef
                            (Etempvar _t'4 (tptr (tarray (tarray tfloat 4) 4)))
                            (tarray (tarray tfloat 4) 4))
                          (Econst_int (Int.repr 3) tint)
                          (tptr (tarray tfloat 4))) (tarray tfloat 4))
                      (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                  (Ebinop Osub (Etempvar _t'6 tfloat) (Etempvar _t'7 tfloat)
                    tfloat))))))
        Sskip))
    (Ssequence
      (Sset _t'1
        (Ederef
          (Ebinop Oadd
            (Efield
              (Efield
                (Efield
                  (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _header
                  (Tstruct _ObjectNode noattr)) _gfx
                (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
        (Sassign
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _o (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
          (Ebinop Osub (Etempvar _t'1 tfloat) (Etempvar _t'2 tfloat) tfloat))))))
|}.

Definition v_sCapFlickerFrames := {|
  gvar_info := tulong;
  gvar_init := (Init_int64 (Int64.repr 4919132088078521685) :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_update_and_return_cap_flags := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_flags, tuint) :: (_action, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tuint) ::
               (_t'12, tuint) :: (_t'11, tuint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tulong) :: (_t'7, tushort) ::
               (_t'6, tushort) :: (_t'5, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _flags
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _flags tuint))
  (Ssequence
    (Ssequence
      (Sset _t'5
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _capTimer tushort))
      (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tushort)
                     (Econst_int (Int.repr 0) tint) tint)
        (Ssequence
          (Sset _action
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _capTimer tushort))
                (Sifthenelse (Ebinop Ole (Etempvar _t'15 tushort)
                               (Econst_int (Int.repr 60) tint) tint)
                  (Sset _t'1 (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Ssequence
                      (Sifthenelse (Ebinop One (Etempvar _action tuint)
                                     (Econst_int (Int.repr 536875781) tint)
                                     tint)
                        (Sset _t'2
                          (Ecast
                            (Ebinop One (Etempvar _action tuint)
                              (Econst_int (Int.repr 536875782) tint) tint)
                            tbool))
                        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'2 tint)
                        (Sset _t'3
                          (Ecast
                            (Ebinop One (Etempvar _action tuint)
                              (Econst_int (Int.repr 4872) tint) tint) tbool))
                        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Sset _t'1
                          (Ecast
                            (Ebinop One (Etempvar _action tuint)
                              (Econst_int (Int.repr 4977) tint) tint) tbool))
                        (Sset _t'1 (Ecast (Etempvar _t'1 tint) tbool)))
                      (Sset _t'1
                        (Ecast (Econst_int (Int.repr 0) tint) tbool))))))
              (Sifthenelse (Etempvar _t'1 tint)
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _capTimer tushort))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _capTimer tushort)
                    (Ebinop Osub (Etempvar _t'14 tushort)
                      (Econst_int (Int.repr 1) tint) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'10
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _capTimer tushort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Scall None
                      (Evar _stop_cap_music (Tfunction nil tvoid cc_default))
                      nil)
                    (Ssequence
                      (Ssequence
                        (Sset _t'13
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _flags tuint))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _flags tuint)
                          (Ebinop Oand (Etempvar _t'13 tuint)
                            (Eunop Onotint
                              (Ebinop Oor
                                (Ebinop Oor (Econst_int (Int.repr 2) tint)
                                  (Econst_int (Int.repr 4) tint) tint)
                                (Econst_int (Int.repr 8) tint) tint) tint)
                            tuint)))
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _flags tuint))
                        (Sifthenelse (Eunop Onotbool
                                       (Ebinop Oand (Etempvar _t'11 tuint)
                                         (Ebinop Oor
                                           (Econst_int (Int.repr 1) tint)
                                           (Ebinop Oor
                                             (Ebinop Oor
                                               (Econst_int (Int.repr 2) tint)
                                               (Econst_int (Int.repr 4) tint)
                                               tint)
                                             (Econst_int (Int.repr 8) tint)
                                             tint) tint) tuint) tint)
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint)
                              (Ebinop Oand (Etempvar _t'12 tuint)
                                (Eunop Onotint
                                  (Econst_int (Int.repr 16) tint) tint)
                                tuint)))
                          Sskip))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'9
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _capTimer tushort))
                  (Sifthenelse (Ebinop Oeq (Etempvar _t'9 tushort)
                                 (Econst_int (Int.repr 60) tint) tint)
                    (Scall None
                      (Evar _fadeout_cap_music (Tfunction nil tvoid
                                                 cc_default)) nil)
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _capTimer tushort))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'6 tushort)
                                   (Econst_int (Int.repr 64) tint) tint)
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _capTimer
                            tushort))
                        (Ssequence
                          (Sset _t'8 (Evar _sCapFlickerFrames tulong))
                          (Sset _t'4
                            (Ecast
                              (Ebinop Oand
                                (Ebinop Oshl
                                  (Econst_long (Int64.repr 1) tulong)
                                  (Etempvar _t'7 tushort) tulong)
                                (Etempvar _t'8 tulong) tulong) tbool))))
                      (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'4 tint)
                    (Ssequence
                      (Sset _flags
                        (Ebinop Oand (Etempvar _flags tuint)
                          (Eunop Onotint
                            (Ebinop Oor
                              (Ebinop Oor (Econst_int (Int.repr 2) tint)
                                (Econst_int (Int.repr 4) tint) tint)
                              (Econst_int (Int.repr 8) tint) tint) tint)
                          tuint))
                      (Sifthenelse (Eunop Onotbool
                                     (Ebinop Oand (Etempvar _flags tuint)
                                       (Ebinop Oor
                                         (Econst_int (Int.repr 1) tint)
                                         (Ebinop Oor
                                           (Ebinop Oor
                                             (Econst_int (Int.repr 2) tint)
                                             (Econst_int (Int.repr 4) tint)
                                             tint)
                                           (Econst_int (Int.repr 8) tint)
                                           tint) tint) tuint) tint)
                        (Sset _flags
                          (Ebinop Oand (Etempvar _flags tuint)
                            (Eunop Onotint (Econst_int (Int.repr 16) tint)
                              tint) tuint))
                        Sskip))
                    Sskip))))))
        Sskip))
    (Sreturn (Some (Etempvar _flags tuint)))))
|}.

Definition f_mario_update_hitbox_and_cap_model := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_bodyState, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_flags, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'20, tshort) :: (_t'19, tshort) ::
               (_t'18, tuint) :: (_t'17, tshort) :: (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _Object noattr))) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _Object noattr))) :: (_t'9, tuint) ::
               (_t'8, tuchar) :: (_t'7, tuint) :: (_t'6, tshort) ::
               (_t'5, tuchar) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _bodyState
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioBodyState
      (tptr (Tstruct _MarioBodyState noattr))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _update_and_return_cap_flags (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sset _flags (Etempvar _t'1 tuint)))
    (Ssequence
      (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                     (Econst_int (Int.repr 2) tint) tint)
        (Sassign
          (Efield
            (Ederef
              (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
              (Tstruct _MarioBodyState noattr)) _modelState tshort)
          (Econst_int (Int.repr 384) tint))
        Sskip)
      (Ssequence
        (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                       (Econst_int (Int.repr 4) tint) tint)
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef
                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _modelState tshort))
            (Sassign
              (Efield
                (Ederef
                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                  (Tstruct _MarioBodyState noattr)) _modelState tshort)
              (Ebinop Oor (Etempvar _t'20 tshort)
                (Econst_int (Int.repr 512) tint) tint)))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                         (Econst_int (Int.repr 64) tint) tint)
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef
                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _modelState tshort))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _modelState tshort)
                (Ebinop Oor (Etempvar _t'19 tshort)
                  (Econst_int (Int.repr 512) tint) tint)))
            Sskip)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _invincTimer tshort))
                (Sifthenelse (Ebinop Oge (Etempvar _t'17 tshort)
                               (Econst_int (Int.repr 3) tint) tint)
                  (Ssequence
                    (Sset _t'18 (Evar _gGlobalTimer tuint))
                    (Sset _t'2
                      (Ecast
                        (Ebinop Oand (Etempvar _t'18 tuint)
                          (Econst_int (Int.repr 1) tint) tuint) tbool)))
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
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'14
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Ssequence
                          (Sset _t'16
                            (Efield
                              (Efield
                                (Efield
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
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
                                      (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                      (Tstruct _Object noattr)) _header
                                    (Tstruct _ObjectNode noattr)) _gfx
                                  (Tstruct _GraphNodeObject noattr)) _node
                                (Tstruct _GraphNode noattr)) _flags tshort)
                            (Ebinop Oor (Etempvar _t'16 tshort)
                              (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                (Econst_int (Int.repr 4) tint) tint) tint)))))))
                Sskip))
            (Ssequence
              (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                             (Econst_int (Int.repr 32) tint) tint)
                (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                               (Econst_int (Int.repr 8) tint) tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                        (Tstruct _MarioBodyState noattr)) _handState tschar)
                    (Econst_int (Int.repr 4) tint))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                        (Tstruct _MarioBodyState noattr)) _handState tschar)
                    (Econst_int (Int.repr 3) tint)))
                Sskip)
              (Ssequence
                (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                               (Econst_int (Int.repr 16) tint) tint)
                  (Sifthenelse (Ebinop Oand (Etempvar _flags tint)
                                 (Econst_int (Int.repr 8) tint) tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _capState tschar)
                      (Econst_int (Int.repr 2) tint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                          (Tstruct _MarioBodyState noattr)) _capState tschar)
                      (Econst_int (Int.repr 0) tint)))
                  Sskip)
                (Ssequence
                  (Ssequence
                    (Sset _t'9
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _action tuint))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tuint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 15) tint) tint)
                                   tuint)
                      (Ssequence
                        (Sset _t'11
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'11 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _hitboxHeight tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _marioObj
                            (tptr (Tstruct _Object noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'10 (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _hitboxHeight tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'7
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _flags tuint))
                      (Sifthenelse (Ebinop Oand (Etempvar _t'7 tuint)
                                     (Econst_int (Int.repr 128) tint) tuint)
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr))
                              _fadeWarpOpacity tuchar))
                          (Sset _t'3
                            (Ecast
                              (Ebinop One (Etempvar _t'8 tuchar)
                                (Econst_int (Int.repr 255) tint) tint) tbool)))
                        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Efield
                              (Ederef
                                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _modelState
                              tshort))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _modelState
                              tshort)
                            (Ebinop Oand (Etempvar _t'6 tshort)
                              (Eunop Onotint (Econst_int (Int.repr 255) tint)
                                tint) tint)))
                        (Ssequence
                          (Sset _t'4
                            (Efield
                              (Ederef
                                (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _modelState
                              tshort))
                          (Ssequence
                            (Sset _t'5
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr))
                                _fadeWarpOpacity tuchar))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _bodyState (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _modelState tshort)
                              (Ebinop Oor (Etempvar _t'4 tshort)
                                (Ebinop Oor (Econst_int (Int.repr 256) tint)
                                  (Etempvar _t'5 tuchar) tint) tint)))))
                      Sskip)))))))))))
|}.

Definition f_execute_mario_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_o, (tptr (Tstruct _Object noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_inLoop, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'52, tshort) ::
               (_t'51, (tptr (Tstruct _Object noattr))) ::
               (_t'50, (tptr (Tstruct _MarioState noattr))) ::
               (_t'49, (tptr (Tstruct _Object noattr))) ::
               (_t'48, (tptr (Tstruct _MarioState noattr))) ::
               (_t'47, (tptr (Tstruct _MarioState noattr))) ::
               (_t'46, (tptr (Tstruct _MarioState noattr))) ::
               (_t'45, (tptr (Tstruct _MarioState noattr))) ::
               (_t'44, (tptr (Tstruct _MarioState noattr))) ::
               (_t'43, (tptr (Tstruct _Surface noattr))) ::
               (_t'42, (tptr (Tstruct _MarioState noattr))) ::
               (_t'41, (tptr (Tstruct _MarioState noattr))) ::
               (_t'40, (tptr (Tstruct _MarioState noattr))) ::
               (_t'39, (tptr (Tstruct _MarioState noattr))) ::
               (_t'38, (tptr (Tstruct _MarioState noattr))) ::
               (_t'37, (tptr (Tstruct _MarioState noattr))) ::
               (_t'36, (tptr (Tstruct _MarioState noattr))) ::
               (_t'35, (tptr (Tstruct _MarioState noattr))) ::
               (_t'34, tuint) ::
               (_t'33, (tptr (Tstruct _MarioState noattr))) ::
               (_t'32, (tptr (Tstruct _MarioState noattr))) ::
               (_t'31, (tptr (Tstruct _MarioState noattr))) ::
               (_t'30, (tptr (Tstruct _MarioState noattr))) ::
               (_t'29, (tptr (Tstruct _MarioState noattr))) ::
               (_t'28, (tptr (Tstruct _MarioState noattr))) ::
               (_t'27, (tptr (Tstruct _MarioState noattr))) ::
               (_t'26, tshort) ::
               (_t'25, (tptr (Tstruct _Surface noattr))) ::
               (_t'24, (tptr (Tstruct _MarioState noattr))) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, (tptr (Tstruct _MarioState noattr))) ::
               (_t'21, tshort) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, (tptr (Tstruct _Object noattr))) ::
               (_t'17, (tptr (Tstruct _MarioState noattr))) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _Surface noattr))) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Sset _inLoop (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Sset _t'8 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _t'8 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Etempvar _t'9 tuint)
          (Ssequence
            (Ssequence
              (Sset _t'48
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Ssequence
                (Sset _t'49
                  (Efield
                    (Ederef
                      (Etempvar _t'48 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _marioObj
                    (tptr (Tstruct _Object noattr))))
                (Ssequence
                  (Sset _t'50
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Ssequence
                    (Sset _t'51
                      (Efield
                        (Ederef
                          (Etempvar _t'50 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Ssequence
                      (Sset _t'52
                        (Efield
                          (Efield
                            (Efield
                              (Efield
                                (Ederef
                                  (Etempvar _t'51 (tptr (Tstruct _Object noattr)))
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
                                  (Etempvar _t'49 (tptr (Tstruct _Object noattr)))
                                  (Tstruct _Object noattr)) _header
                                (Tstruct _ObjectNode noattr)) _gfx
                              (Tstruct _GraphNodeObject noattr)) _node
                            (Tstruct _GraphNode noattr)) _flags tshort)
                        (Ebinop Oand (Etempvar _t'52 tshort)
                          (Eunop Onotint
                            (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                              (Econst_int (Int.repr 4) tint) tint) tint)
                          tint)))))))
            (Ssequence
              (Ssequence
                (Sset _t'47
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Scall None
                  (Evar _mario_reset_bodystate (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                  ((Etempvar _t'47 (tptr (Tstruct _MarioState noattr))) ::
                   nil)))
              (Ssequence
                (Ssequence
                  (Sset _t'46
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Scall None
                    (Evar _update_mario_inputs (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tvoid cc_default))
                    ((Etempvar _t'46 (tptr (Tstruct _MarioState noattr))) ::
                     nil)))
                (Ssequence
                  (Ssequence
                    (Sset _t'45
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Scall None
                      (Evar _mario_handle_special_floors (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tvoid
                                                           cc_default))
                      ((Etempvar _t'45 (tptr (Tstruct _MarioState noattr))) ::
                       nil)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'44
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Scall None
                        (Evar _mario_process_interactions (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tvoid
                                                            cc_default))
                        ((Etempvar _t'44 (tptr (Tstruct _MarioState noattr))) ::
                         nil)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'42
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Ssequence
                          (Sset _t'43
                            (Efield
                              (Ederef
                                (Etempvar _t'42 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _floor
                              (tptr (Tstruct _Surface noattr))))
                          (Sifthenelse (Ebinop Oeq
                                         (Etempvar _t'43 (tptr (Tstruct _Surface noattr)))
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           (tptr tvoid)) tint)
                            (Sreturn (Some (Econst_int (Int.repr 0) tint)))
                            Sskip)))
                      (Ssequence
                        (Swhile
                          (Etempvar _inLoop tint)
                          (Ssequence
                            (Sset _t'33
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Ssequence
                              (Sset _t'34
                                (Efield
                                  (Ederef
                                    (Etempvar _t'33 (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _action
                                  tuint))
                              (Sswitch (Ebinop Oand (Etempvar _t'34 tuint)
                                         (Econst_int (Int.repr 448) tint)
                                         tuint)
                                (LScons (Some 0)
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'41
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Scall (Some _t'1)
                                          (Evar _mario_execute_stationary_action 
                                          (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
                                          ((Etempvar _t'41 (tptr (Tstruct _MarioState noattr))) ::
                                           nil)))
                                      (Sset _inLoop (Etempvar _t'1 tint)))
                                    Sbreak)
                                  (LScons (Some 64)
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'40
                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                          (Scall (Some _t'2)
                                            (Evar _mario_execute_moving_action 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                                            ((Etempvar _t'40 (tptr (Tstruct _MarioState noattr))) ::
                                             nil)))
                                        (Sset _inLoop (Etempvar _t'2 tint)))
                                      Sbreak)
                                    (LScons (Some 128)
                                      (Ssequence
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'39
                                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                            (Scall (Some _t'3)
                                              (Evar _mario_execute_airborne_action 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                                              ((Etempvar _t'39 (tptr (Tstruct _MarioState noattr))) ::
                                               nil)))
                                          (Sset _inLoop (Etempvar _t'3 tint)))
                                        Sbreak)
                                      (LScons (Some 192)
                                        (Ssequence
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'38
                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                              (Scall (Some _t'4)
                                                (Evar _mario_execute_submerged_action 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _t'38 (tptr (Tstruct _MarioState noattr))) ::
                                                 nil)))
                                            (Sset _inLoop
                                              (Etempvar _t'4 tint)))
                                          Sbreak)
                                        (LScons (Some 256)
                                          (Ssequence
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'37
                                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                (Scall (Some _t'5)
                                                  (Evar _mario_execute_cutscene_action 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _t'37 (tptr (Tstruct _MarioState noattr))) ::
                                                   nil)))
                                              (Sset _inLoop
                                                (Etempvar _t'5 tint)))
                                            Sbreak)
                                          (LScons (Some 320)
                                            (Ssequence
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'36
                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                  (Scall (Some _t'6)
                                                    (Evar _mario_execute_automatic_action 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _t'36 (tptr (Tstruct _MarioState noattr))) ::
                                                     nil)))
                                                (Sset _inLoop
                                                  (Etempvar _t'6 tint)))
                                              Sbreak)
                                            (LScons (Some 384)
                                              (Ssequence
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'35
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Scall (Some _t'7)
                                                      (Evar _mario_execute_object_action 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _t'35 (tptr (Tstruct _MarioState noattr))) ::
                                                       nil)))
                                                  (Sset _inLoop
                                                    (Etempvar _t'7 tint)))
                                                Sbreak)
                                              LSnil)))))))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'32
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Scall None
                              (Evar _sink_mario_in_quicksand (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tvoid
                                                               cc_default))
                              ((Etempvar _t'32 (tptr (Tstruct _MarioState noattr))) ::
                               nil)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'31
                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                              (Scall None
                                (Evar _squish_mario_model (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tvoid
                                                            cc_default))
                                ((Etempvar _t'31 (tptr (Tstruct _MarioState noattr))) ::
                                 nil)))
                            (Ssequence
                              (Ssequence
                                (Sset _t'30
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Scall None
                                  (Evar _set_submerged_cam_preset_and_spawn_bubbles 
                                  (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
                                  ((Etempvar _t'30 (tptr (Tstruct _MarioState noattr))) ::
                                   nil)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'29
                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                  (Scall None
                                    (Evar _update_mario_health (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  nil) tvoid
                                                                 cc_default))
                                    ((Etempvar _t'29 (tptr (Tstruct _MarioState noattr))) ::
                                     nil)))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'28
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Scall None
                                      (Evar _update_mario_info_for_cam 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
                                      ((Etempvar _t'28 (tptr (Tstruct _MarioState noattr))) ::
                                       nil)))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'27
                                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                      (Scall None
                                        (Evar _mario_update_hitbox_and_cap_model 
                                        (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
                                        ((Etempvar _t'27 (tptr (Tstruct _MarioState noattr))) ::
                                         nil)))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'19
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Ssequence
                                          (Sset _t'20
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'19 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _floor
                                              (tptr (Tstruct _Surface noattr))))
                                          (Ssequence
                                            (Sset _t'21
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _type tshort))
                                            (Sifthenelse (Ebinop Oeq
                                                           (Etempvar _t'21 tshort)
                                                           (Econst_int (Int.repr 44) tint)
                                                           tint)
                                              (Ssequence
                                                (Ssequence
                                                  (Sset _t'24
                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                  (Ssequence
                                                    (Sset _t'25
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'24 (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _floor
                                                        (tptr (Tstruct _Surface noattr))))
                                                    (Ssequence
                                                      (Sset _t'26
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'25 (tptr (Tstruct _Surface noattr)))
                                                            (Tstruct _Surface noattr))
                                                          _force tshort))
                                                      (Scall None
                                                        (Evar _spawn_wind_particles 
                                                        (Tfunction
                                                          (tshort ::
                                                           tshort :: nil)
                                                          tvoid cc_default))
                                                        ((Econst_int (Int.repr 0) tint) ::
                                                         (Ebinop Oshl
                                                           (Etempvar _t'26 tshort)
                                                           (Econst_int (Int.repr 8) tint)
                                                           tint) :: nil)))))
                                                (Ssequence
                                                  (Sset _t'22
                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                  (Ssequence
                                                    (Sset _t'23
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'22 (tptr (Tstruct _MarioState noattr)))
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
                                                                   (Econst_int (Int.repr 4) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 28) tint)
                                                                 tuint)
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 16) tint)
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
                                                           (Econst_int (Int.repr 0) tint)
                                                           tuint)
                                                         (Econst_int (Int.repr 1) tint)
                                                         tuint) ::
                                                       (Efield
                                                         (Efield
                                                           (Efield
                                                             (Ederef
                                                               (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                                                               (Tstruct _Object noattr))
                                                             _header
                                                             (Tstruct _ObjectNode noattr))
                                                           _gfx
                                                           (Tstruct _GraphNodeObject noattr))
                                                         _cameraToObject
                                                         (tarray tfloat 3)) ::
                                                       nil)))))
                                              Sskip))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'14
                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                          (Ssequence
                                            (Sset _t'15
                                              (Efield
                                                (Ederef
                                                  (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _floor
                                                (tptr (Tstruct _Surface noattr))))
                                            (Ssequence
                                              (Sset _t'16
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'15 (tptr (Tstruct _Surface noattr)))
                                                    (Tstruct _Surface noattr))
                                                  _type tshort))
                                              (Sifthenelse (Ebinop Oeq
                                                             (Etempvar _t'16 tshort)
                                                             (Econst_int (Int.repr 56) tint)
                                                             tint)
                                                (Ssequence
                                                  (Scall None
                                                    (Evar _spawn_wind_particles 
                                                    (Tfunction
                                                      (tshort :: tshort ::
                                                       nil) tvoid cc_default))
                                                    ((Econst_int (Int.repr 1) tint) ::
                                                     (Econst_int (Int.repr 0) tint) ::
                                                     nil))
                                                  (Ssequence
                                                    (Sset _t'17
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Ssequence
                                                      (Sset _t'18
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'17 (tptr (Tstruct _MarioState noattr)))
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
                                                                    (Econst_int (Int.repr 4) tint)
                                                                    tuint)
                                                                   (Econst_int (Int.repr 28) tint)
                                                                   tuint)
                                                                 (Ebinop Oshl
                                                                   (Ecast
                                                                    (Econst_int (Int.repr 16) tint)
                                                                    tuint)
                                                                   (Econst_int (Int.repr 16) tint)
                                                                   tuint)
                                                                 tuint)
                                                               (Ebinop Oshl
                                                                 (Ecast
                                                                   (Econst_int (Int.repr 128) tint)
                                                                   tuint)
                                                                 (Econst_int (Int.repr 8) tint)
                                                                 tuint)
                                                               tuint)
                                                             (Econst_int (Int.repr 0) tint)
                                                             tuint)
                                                           (Econst_int (Int.repr 1) tint)
                                                           tuint) ::
                                                         (Efield
                                                           (Efield
                                                             (Efield
                                                               (Ederef
                                                                 (Etempvar _t'18 (tptr (Tstruct _Object noattr)))
                                                                 (Tstruct _Object noattr))
                                                               _header
                                                               (Tstruct _ObjectNode noattr))
                                                             _gfx
                                                             (Tstruct _GraphNodeObject noattr))
                                                           _cameraToObject
                                                           (tarray tfloat 3)) ::
                                                         nil)))))
                                                Sskip))))
                                        (Ssequence
                                          (Scall None
                                            (Evar _play_infinite_stairs_music 
                                            (Tfunction nil tvoid cc_default))
                                            nil)
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'12
                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                              (Ssequence
                                                (Sset _t'13
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'12 (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _marioObj
                                                    (tptr (Tstruct _Object noattr))))
                                                (Sassign
                                                  (Ederef
                                                    (Ebinop Oadd
                                                      (Efield
                                                        (Efield
                                                          (Ederef
                                                            (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                                            (Tstruct _Object noattr))
                                                          _rawData
                                                          (Tunion __665 noattr))
                                                        _asS32
                                                        (tarray tint 80))
                                                      (Econst_int (Int.repr 43) tint)
                                                      (tptr tint)) tint)
                                                  (Econst_int (Int.repr 0) tint))))
                                            (Ssequence
                                              (Sset _t'10
                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                              (Ssequence
                                                (Sset _t'11
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _particleFlags tuint))
                                                (Sreturn (Some (Etempvar _t'11 tuint))))))))))))))))))))))
          Sskip)))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_init_mario := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := ((_capPos, (tarray tshort 3)) :: nil);
  fn_temps := ((_capObject, (tptr (Tstruct _Object noattr))) ::
               (_t'6, tint) :: (_t'5, (tptr (Tstruct _Object noattr))) ::
               (_t'4, tint) :: (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, tuint) ::
               (_t'102, (tptr (Tstruct _MarioState noattr))) ::
               (_t'101, (tptr (Tstruct _MarioState noattr))) ::
               (_t'100, (tptr (Tstruct _MarioState noattr))) ::
               (_t'99, (tptr (Tstruct _MarioState noattr))) ::
               (_t'98, (tptr (Tstruct _MarioState noattr))) ::
               (_t'97, (tptr (Tstruct _MarioState noattr))) ::
               (_t'96, (tptr (Tstruct _MarioState noattr))) ::
               (_t'95, (tptr (Tstruct _MarioState noattr))) ::
               (_t'94, (tptr (Tstruct _MarioState noattr))) ::
               (_t'93, (tptr (Tstruct _MarioState noattr))) ::
               (_t'92, (tptr (Tstruct _MarioState noattr))) ::
               (_t'91, (tptr (Tstruct _MarioState noattr))) ::
               (_t'90, (tptr (Tstruct _MarioState noattr))) ::
               (_t'89, (tptr (Tstruct _MarioState noattr))) ::
               (_t'88, (tptr (Tstruct _MarioState noattr))) ::
               (_t'87, tshort) ::
               (_t'86, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'85, tshort) ::
               (_t'84, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'83, (tptr (Tstruct _MarioState noattr))) ::
               (_t'82, (tptr (Tstruct _Area noattr))) ::
               (_t'81, (tptr (Tstruct _MarioState noattr))) ::
               (_t'80, (tptr (Tstruct _Object noattr))) ::
               (_t'79, (tptr (Tstruct _MarioState noattr))) ::
               (_t'78, (tptr (Tstruct _Object noattr))) ::
               (_t'77, (tptr (Tstruct _MarioState noattr))) ::
               (_t'76, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'75, (tptr (Tstruct _MarioState noattr))) ::
               (_t'74, (tptr (Tstruct _MarioState noattr))) ::
               (_t'73, (tptr (Tstruct _SpawnInfo noattr))) ::
               (_t'72, (tptr (Tstruct _MarioState noattr))) ::
               (_t'71, (tptr (Tstruct _MarioState noattr))) ::
               (_t'70, (tptr (Tstruct _MarioState noattr))) ::
               (_t'69, tfloat) ::
               (_t'68, (tptr (Tstruct _MarioState noattr))) ::
               (_t'67, tfloat) ::
               (_t'66, (tptr (Tstruct _MarioState noattr))) ::
               (_t'65, tfloat) ::
               (_t'64, (tptr (Tstruct _MarioState noattr))) ::
               (_t'63, (tptr (Tstruct _MarioState noattr))) ::
               (_t'62, tfloat) ::
               (_t'61, (tptr (Tstruct _MarioState noattr))) ::
               (_t'60, (tptr (Tstruct _MarioState noattr))) ::
               (_t'59, tfloat) ::
               (_t'58, (tptr (Tstruct _MarioState noattr))) ::
               (_t'57, tfloat) ::
               (_t'56, (tptr (Tstruct _MarioState noattr))) ::
               (_t'55, tfloat) ::
               (_t'54, (tptr (Tstruct _MarioState noattr))) ::
               (_t'53, (tptr (Tstruct _Object noattr))) ::
               (_t'52, (tptr (Tstruct _MarioState noattr))) ::
               (_t'51, tshort) ::
               (_t'50, (tptr (Tstruct _MarioState noattr))) ::
               (_t'49, tfloat) ::
               (_t'48, (tptr (Tstruct _MarioState noattr))) ::
               (_t'47, (tptr (Tstruct _MarioState noattr))) ::
               (_t'46, (tptr (Tstruct _MarioState noattr))) ::
               (_t'45, (tptr (Tstruct _MarioState noattr))) ::
               (_t'44, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'43, (tptr (Tstruct _MarioState noattr))) ::
               (_t'42, tfloat) ::
               (_t'41, (tptr (Tstruct _MarioState noattr))) ::
               (_t'40, (tptr (Tstruct _Object noattr))) ::
               (_t'39, (tptr (Tstruct _MarioState noattr))) ::
               (_t'38, tfloat) ::
               (_t'37, (tptr (Tstruct _MarioState noattr))) ::
               (_t'36, (tptr (Tstruct _Object noattr))) ::
               (_t'35, (tptr (Tstruct _MarioState noattr))) ::
               (_t'34, tfloat) ::
               (_t'33, (tptr (Tstruct _MarioState noattr))) ::
               (_t'32, (tptr (Tstruct _Object noattr))) ::
               (_t'31, (tptr (Tstruct _MarioState noattr))) ::
               (_t'30, tshort) ::
               (_t'29, (tptr (Tstruct _MarioState noattr))) ::
               (_t'28, (tptr (Tstruct _Object noattr))) ::
               (_t'27, (tptr (Tstruct _MarioState noattr))) ::
               (_t'26, tshort) ::
               (_t'25, (tptr (Tstruct _MarioState noattr))) ::
               (_t'24, (tptr (Tstruct _Object noattr))) ::
               (_t'23, (tptr (Tstruct _MarioState noattr))) ::
               (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _MarioState noattr))) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, (tptr (Tstruct _MarioState noattr))) ::
               (_t'17, (tptr (Tstruct _Object noattr))) ::
               (_t'16, (tptr (Tstruct _MarioState noattr))) ::
               (_t'15, tshort) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, (tptr (Tstruct _Object noattr))) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, (tptr (Tstruct _Object noattr))) ::
               (_t'10, (tptr (Tstruct _MarioState noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) :: (_t'7, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sassign (Evar _unused80339F10 tuint) (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'102 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'102 (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort)
        (Econst_int (Int.repr 0) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'101 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'101 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _framesSinceA tuchar)
          (Econst_int (Int.repr 255) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'100
            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'100 (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _framesSinceB tuchar)
            (Econst_int (Int.repr 255) tint)))
        (Ssequence
          (Ssequence
            (Sset _t'99
              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'99 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _invincTimer tshort)
              (Econst_int (Int.repr 0) tint)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'1)
                (Evar _save_file_get_flags (Tfunction nil tuint cc_default))
                nil)
              (Sifthenelse (Ebinop Oand (Etempvar _t'1 tuint)
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oor
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 16) tint) tint)
                                   (Ebinop Oshl
                                     (Econst_int (Int.repr 1) tint)
                                     (Econst_int (Int.repr 17) tint) tint)
                                   tint)
                                 (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                   (Econst_int (Int.repr 18) tint) tint)
                                 tint)
                               (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                 (Econst_int (Int.repr 19) tint) tint) tint)
                             tuint)
                (Ssequence
                  (Sset _t'98
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'98 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _flags tuint)
                    (Econst_int (Int.repr 0) tint)))
                (Ssequence
                  (Sset _t'97
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'97 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _flags tuint)
                    (Ebinop Oor (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 16) tint) tint)))))
            (Ssequence
              (Ssequence
                (Sset _t'96
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'96 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'95
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'95 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _squishTimer tuchar)
                    (Econst_int (Int.repr 0) tint)))
                (Ssequence
                  (Ssequence
                    (Sset _t'94
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'94 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _hurtCounter tuchar)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'93
                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _t'93 (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _healCounter
                          tuchar) (Econst_int (Int.repr 0) tint)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'92
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'92 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _capTimer
                            tushort) (Econst_int (Int.repr 0) tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'91
                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'91 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _quicksandDepth
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'90
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'90 (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _heldObj
                                (tptr (Tstruct _Object noattr)))
                              (Ecast (Econst_int (Int.repr 0) tint)
                                (tptr tvoid))))
                          (Ssequence
                            (Ssequence
                              (Sset _t'89
                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _t'89 (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _riddenObj
                                  (tptr (Tstruct _Object noattr)))
                                (Ecast (Econst_int (Int.repr 0) tint)
                                  (tptr tvoid))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'88
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'88 (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _usedObj
                                    (tptr (Tstruct _Object noattr)))
                                  (Ecast (Econst_int (Int.repr 0) tint)
                                    (tptr tvoid))))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'84
                                      (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                                    (Ssequence
                                      (Sset _t'85
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'84 (tptr (Tstruct _SpawnInfo noattr)))
                                                (Tstruct _SpawnInfo noattr))
                                              _startPos (tarray tshort 3))
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr tshort)) tshort))
                                      (Ssequence
                                        (Sset _t'86
                                          (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                                        (Ssequence
                                          (Sset _t'87
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _t'86 (tptr (Tstruct _SpawnInfo noattr)))
                                                    (Tstruct _SpawnInfo noattr))
                                                  _startPos
                                                  (tarray tshort 3))
                                                (Econst_int (Int.repr 2) tint)
                                                (tptr tshort)) tshort))
                                          (Scall (Some _t'2)
                                            (Evar _find_water_level (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                            ((Etempvar _t'85 tshort) ::
                                             (Etempvar _t'87 tshort) :: nil))))))
                                  (Ssequence
                                    (Sset _t'83
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'83 (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _waterLevel tshort)
                                      (Etempvar _t'2 tfloat))))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'81
                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                    (Ssequence
                                      (Sset _t'82
                                        (Evar _gCurrentArea (tptr (Tstruct _Area noattr))))
                                      (Sassign
                                        (Efield
                                          (Ederef
                                            (Etempvar _t'81 (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _area
                                          (tptr (Tstruct _Area noattr)))
                                        (Etempvar _t'82 (tptr (Tstruct _Area noattr))))))
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'79
                                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                      (Ssequence
                                        (Sset _t'80
                                          (Evar _gMarioObject (tptr (Tstruct _Object noattr))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'79 (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _marioObj
                                            (tptr (Tstruct _Object noattr)))
                                          (Etempvar _t'80 (tptr (Tstruct _Object noattr))))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'77
                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                        (Ssequence
                                          (Sset _t'78
                                            (Efield
                                              (Ederef
                                                (Etempvar _t'77 (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _marioObj
                                              (tptr (Tstruct _Object noattr))))
                                          (Sassign
                                            (Efield
                                              (Efield
                                                (Efield
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _t'78 (tptr (Tstruct _Object noattr)))
                                                      (Tstruct _Object noattr))
                                                    _header
                                                    (Tstruct _ObjectNode noattr))
                                                  _gfx
                                                  (Tstruct _GraphNodeObject noattr))
                                                _animInfo
                                                (Tstruct _AnimInfo noattr))
                                              _animID tshort)
                                            (Eunop Oneg
                                              (Econst_int (Int.repr 1) tint)
                                              tint))))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'75
                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                          (Ssequence
                                            (Sset _t'76
                                              (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                                            (Scall None
                                              (Evar _vec3s_copy (Tfunction
                                                                  ((tptr tshort) ::
                                                                   (tptr tshort) ::
                                                                   nil)
                                                                  (tptr tvoid)
                                                                  cc_default))
                                              ((Efield
                                                 (Ederef
                                                   (Etempvar _t'75 (tptr (Tstruct _MarioState noattr)))
                                                   (Tstruct _MarioState noattr))
                                                 _faceAngle
                                                 (tarray tshort 3)) ::
                                               (Efield
                                                 (Ederef
                                                   (Etempvar _t'76 (tptr (Tstruct _SpawnInfo noattr)))
                                                   (Tstruct _SpawnInfo noattr))
                                                 _startAngle
                                                 (tarray tshort 3)) :: nil))))
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'74
                                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
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
                                                 (Ederef
                                                   (Etempvar _t'74 (tptr (Tstruct _MarioState noattr)))
                                                   (Tstruct _MarioState noattr))
                                                 _angleVel (tarray tshort 3)) ::
                                               (Econst_int (Int.repr 0) tint) ::
                                               (Econst_int (Int.repr 0) tint) ::
                                               (Econst_int (Int.repr 0) tint) ::
                                               nil)))
                                          (Ssequence
                                            (Ssequence
                                              (Sset _t'72
                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                              (Ssequence
                                                (Sset _t'73
                                                  (Evar _gMarioSpawnInfo (tptr (Tstruct _SpawnInfo noattr))))
                                                (Scall None
                                                  (Evar _vec3s_to_vec3f 
                                                  (Tfunction
                                                    ((tptr tfloat) ::
                                                     (tptr tshort) :: nil)
                                                    (tptr tvoid) cc_default))
                                                  ((Efield
                                                     (Ederef
                                                       (Etempvar _t'72 (tptr (Tstruct _MarioState noattr)))
                                                       (Tstruct _MarioState noattr))
                                                     _pos (tarray tfloat 3)) ::
                                                   (Efield
                                                     (Ederef
                                                       (Etempvar _t'73 (tptr (Tstruct _SpawnInfo noattr)))
                                                       (Tstruct _SpawnInfo noattr))
                                                     _startPos
                                                     (tarray tshort 3)) ::
                                                   nil))))
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'71
                                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                (Scall None
                                                  (Evar _vec3f_set (Tfunction
                                                                    ((tptr tfloat) ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                                  ((Efield
                                                     (Ederef
                                                       (Etempvar _t'71 (tptr (Tstruct _MarioState noattr)))
                                                       (Tstruct _MarioState noattr))
                                                     _vel (tarray tfloat 3)) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   (Econst_int (Int.repr 0) tint) ::
                                                   nil)))
                                              (Ssequence
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'64
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Ssequence
                                                      (Sset _t'65
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _t'64 (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _pos
                                                              (tarray tfloat 3))
                                                            (Econst_int (Int.repr 0) tint)
                                                            (tptr tfloat))
                                                          tfloat))
                                                      (Ssequence
                                                        (Sset _t'66
                                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                        (Ssequence
                                                          (Sset _t'67
                                                            (Ederef
                                                              (Ebinop Oadd
                                                                (Efield
                                                                  (Ederef
                                                                    (Etempvar _t'66 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                  _pos
                                                                  (tarray tfloat 3))
                                                                (Econst_int (Int.repr 1) tint)
                                                                (tptr tfloat))
                                                              tfloat))
                                                          (Ssequence
                                                            (Sset _t'68
                                                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                            (Ssequence
                                                              (Sset _t'69
                                                                (Ederef
                                                                  (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'68 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tfloat))
                                                                  tfloat))
                                                              (Ssequence
                                                                (Sset _t'70
                                                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                (Scall (Some _t'3)
                                                                  (Evar _find_floor 
                                                                  (Tfunction
                                                                    (tfloat ::
                                                                    tfloat ::
                                                                    tfloat ::
                                                                    (tptr (tptr (Tstruct _Surface noattr))) ::
                                                                    nil)
                                                                    tfloat
                                                                    cc_default))
                                                                  ((Etempvar _t'65 tfloat) ::
                                                                   (Etempvar _t'67 tfloat) ::
                                                                   (Etempvar _t'69 tfloat) ::
                                                                   (Eaddrof
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'70 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _floor
                                                                    (tptr (Tstruct _Surface noattr)))
                                                                    (tptr (tptr (Tstruct _Surface noattr)))) ::
                                                                   nil)))))))))
                                                  (Ssequence
                                                    (Sset _t'63
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Sassign
                                                      (Efield
                                                        (Ederef
                                                          (Etempvar _t'63 (tptr (Tstruct _MarioState noattr)))
                                                          (Tstruct _MarioState noattr))
                                                        _floorHeight tfloat)
                                                      (Etempvar _t'3 tfloat))))
                                                (Ssequence
                                                  (Ssequence
                                                    (Sset _t'56
                                                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                    (Ssequence
                                                      (Sset _t'57
                                                        (Ederef
                                                          (Ebinop Oadd
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _t'56 (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _pos
                                                              (tarray tfloat 3))
                                                            (Econst_int (Int.repr 1) tint)
                                                            (tptr tfloat))
                                                          tfloat))
                                                      (Ssequence
                                                        (Sset _t'58
                                                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                        (Ssequence
                                                          (Sset _t'59
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _t'58 (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _floorHeight
                                                              tfloat))
                                                          (Sifthenelse 
                                                            (Ebinop Olt
                                                              (Etempvar _t'57 tfloat)
                                                              (Etempvar _t'59 tfloat)
                                                              tint)
                                                            (Ssequence
                                                              (Sset _t'60
                                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                              (Ssequence
                                                                (Sset _t'61
                                                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                (Ssequence
                                                                  (Sset _t'62
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'61 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _floorHeight
                                                                    tfloat))
                                                                  (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'60 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'62 tfloat)))))
                                                            Sskip)))))
                                                  (Ssequence
                                                    (Ssequence
                                                      (Sset _t'52
                                                        (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                      (Ssequence
                                                        (Sset _t'53
                                                          (Efield
                                                            (Ederef
                                                              (Etempvar _t'52 (tptr (Tstruct _MarioState noattr)))
                                                              (Tstruct _MarioState noattr))
                                                            _marioObj
                                                            (tptr (Tstruct _Object noattr))))
                                                        (Ssequence
                                                          (Sset _t'54
                                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                          (Ssequence
                                                            (Sset _t'55
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'54 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tfloat))
                                                                tfloat))
                                                            (Sassign
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'53 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tfloat))
                                                                tfloat)
                                                              (Etempvar _t'55 tfloat))))))
                                                    (Ssequence
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'48
                                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                          (Ssequence
                                                            (Sset _t'49
                                                              (Ederef
                                                                (Ebinop Oadd
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'48 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                  (Econst_int (Int.repr 1) tint)
                                                                  (tptr tfloat))
                                                                tfloat))
                                                            (Ssequence
                                                              (Sset _t'50
                                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                              (Ssequence
                                                                (Sset _t'51
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'50 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _waterLevel
                                                                    tshort))
                                                                (Sifthenelse 
                                                                  (Ebinop Ole
                                                                    (Etempvar _t'49 tfloat)
                                                                    (Ebinop Osub
                                                                    (Etempvar _t'51 tshort)
                                                                    (Econst_int (Int.repr 100) tint)
                                                                    tint)
                                                                    tint)
                                                                  (Sset _t'4
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 939532992) tint)
                                                                    tint))
                                                                  (Sset _t'4
                                                                    (Ecast
                                                                    (Econst_int (Int.repr 205521409) tint)
                                                                    tint)))))))
                                                        (Ssequence
                                                          (Sset _t'47
                                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                          (Sassign
                                                            (Efield
                                                              (Ederef
                                                                (Etempvar _t'47 (tptr (Tstruct _MarioState noattr)))
                                                                (Tstruct _MarioState noattr))
                                                              _action tuint)
                                                            (Etempvar _t'4 tint))))
                                                      (Ssequence
                                                        (Ssequence
                                                          (Sset _t'46
                                                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                          (Scall None
                                                            (Evar _mario_reset_bodystate 
                                                            (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                                                            ((Etempvar _t'46 (tptr (Tstruct _MarioState noattr))) ::
                                                             nil)))
                                                        (Ssequence
                                                          (Ssequence
                                                            (Sset _t'45
                                                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                            (Scall None
                                                              (Evar _update_mario_info_for_cam 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tvoid
                                                                cc_default))
                                                              ((Etempvar _t'45 (tptr (Tstruct _MarioState noattr))) ::
                                                               nil)))
                                                          (Ssequence
                                                            (Ssequence
                                                              (Sset _t'43
                                                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                              (Ssequence
                                                                (Sset _t'44
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'43 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioBodyState
                                                                    (tptr (Tstruct _MarioBodyState noattr))))
                                                                (Sassign
                                                                  (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'44 (tptr (Tstruct _MarioBodyState noattr)))
                                                                    (Tstruct _MarioBodyState noattr))
                                                                    _punchState
                                                                    tuchar)
                                                                  (Econst_int (Int.repr 0) tint))))
                                                            (Ssequence
                                                              (Ssequence
                                                                (Sset _t'39
                                                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                (Ssequence
                                                                  (Sset _t'40
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'39 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                  (Ssequence
                                                                    (Sset _t'41
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'42
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'41 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tfloat))
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'40 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'42 tfloat))))))
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Sset _t'35
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                  (Ssequence
                                                                    (Sset _t'36
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'35 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'37
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'38
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'37 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tfloat))
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'36 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'38 tfloat))))))
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Sset _t'31
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'32
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'31 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'33
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'34
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'33 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tfloat))
                                                                    tfloat))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'32 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'34 tfloat))))))
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'27
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'28
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'27 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'29
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'30
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'29 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _faceAngle
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'28 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (tptr tint))
                                                                    tint)
                                                                    (Etempvar _t'30 tshort))))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'23
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'24
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'23 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'25
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'26
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'25 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _faceAngle
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'24 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tint))
                                                                    tint)
                                                                    (Etempvar _t'26 tshort))))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'19
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'20
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'19 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'21
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'22
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'21 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _faceAngle
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    (tptr tint))
                                                                    tint)
                                                                    (Etempvar _t'22 tshort))))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'16
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'17
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'16 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'18
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Scall None
                                                                    (Evar _vec3f_copy 
                                                                    (Tfunction
                                                                    ((tptr tfloat) ::
                                                                    (tptr tfloat) ::
                                                                    nil)
                                                                    (tptr tvoid)
                                                                    cc_default))
                                                                    ((Efield
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'17 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _pos
                                                                    (tarray tfloat 3)) ::
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'18 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _pos
                                                                    (tarray tfloat 3)) ::
                                                                    nil)))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'12
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'13
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'12 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'14
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'15
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _faceAngle
                                                                    (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Scall None
                                                                    (Evar _vec3s_set 
                                                                    (Tfunction
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
                                                                    (Etempvar _t'13 (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _header
                                                                    (Tstruct _ObjectNode noattr))
                                                                    _gfx
                                                                    (Tstruct _GraphNodeObject noattr))
                                                                    _angle
                                                                    (tarray tshort 3)) ::
                                                                    (Econst_int (Int.repr 0) tint) ::
                                                                    (Etempvar _t'15 tshort) ::
                                                                    (Econst_int (Int.repr 0) tint) ::
                                                                    nil))))))
                                                                    (Ssequence
                                                                    (Scall (Some _t'6)
                                                                    (Evar _save_file_get_cap_pos 
                                                                    (Tfunction
                                                                    ((tptr tshort) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Evar _capPos (tarray tshort 3)) ::
                                                                    nil))
                                                                    (Sifthenelse (Etempvar _t'6 tint)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'10
                                                                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                                                    (Ssequence
                                                                    (Sset _t'11
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _t'10 (tptr (Tstruct _MarioState noattr)))
                                                                    (Tstruct _MarioState noattr))
                                                                    _marioObj
                                                                    (tptr (Tstruct _Object noattr))))
                                                                    (Scall (Some _t'5)
                                                                    (Evar _spawn_object 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _Object noattr)) ::
                                                                    tint ::
                                                                    (tptr tuint) ::
                                                                    nil)
                                                                    (tptr (Tstruct _Object noattr))
                                                                    cc_default))
                                                                    ((Etempvar _t'11 (tptr (Tstruct _Object noattr))) ::
                                                                    (Econst_int (Int.repr 136) tint) ::
                                                                    (Evar _bhvNormalCap (tarray tuint 0)) ::
                                                                    nil))))
                                                                    (Sset _capObject
                                                                    (Etempvar _t'5 (tptr (Tstruct _Object noattr)))))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'9
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _capPos (tarray tshort 3))
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 0) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'9 tshort)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'8
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _capPos (tarray tshort 3))
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'8 tshort)))
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Sset _t'7
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Evar _capPos (tarray tshort 3))
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    (tptr tshort))
                                                                    tshort))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asF32
                                                                    (tarray tfloat 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 6) tint)
                                                                    (Econst_int (Int.repr 2) tint)
                                                                    tint)
                                                                    (tptr tfloat))
                                                                    tfloat)
                                                                    (Etempvar _t'7 tshort)))
                                                                    (Ssequence
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                    (Econst_int (Int.repr 12) tint)
                                                                    (tptr tint))
                                                                    tint)
                                                                    (Econst_int (Int.repr 0) tint))
                                                                    (Sassign
                                                                    (Ederef
                                                                    (Ebinop Oadd
                                                                    (Efield
                                                                    (Efield
                                                                    (Ederef
                                                                    (Etempvar _capObject (tptr (Tstruct _Object noattr)))
                                                                    (Tstruct _Object noattr))
                                                                    _rawData
                                                                    (Tunion __665 noattr))
                                                                    _asS32
                                                                    (tarray tint 80))
                                                                    (Ebinop Oadd
                                                                    (Econst_int (Int.repr 15) tint)
                                                                    (Econst_int (Int.repr 1) tint)
                                                                    tint)
                                                                    (tptr tint))
                                                                    tint)
                                                                    (Econst_int (Int.repr 0) tint)))))))
                                                                    Sskip))))))))))))))))))))))))))))))))))))))))
|}.

Definition f_init_mario_from_save_file := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := nil;
  fn_vars := nil;
  fn_temps := ((_t'1, tint) ::
               (_t'19, (tptr (Tstruct _MarioState noattr))) ::
               (_t'18, (tptr (Tstruct _MarioState noattr))) ::
               (_t'17, (tptr (Tstruct _MarioState noattr))) ::
               (_t'16, (tptr (Tstruct _MarioState noattr))) ::
               (_t'15, (tptr (Tstruct _MarioState noattr))) ::
               (_t'14, (tptr (Tstruct _MarioState noattr))) ::
               (_t'13, (tptr (Tstruct _MarioState noattr))) ::
               (_t'12, (tptr (Tstruct _MarioState noattr))) ::
               (_t'11, (tptr (Tstruct _MarioState noattr))) ::
               (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _MarioState noattr))) ::
               (_t'8, (tptr (Tstruct _MarioState noattr))) ::
               (_t'7, (tptr (Tstruct _MarioState noattr))) ::
               (_t'6, (tptr (Tstruct _MarioState noattr))) ::
               (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _MarioState noattr))) ::
               (_t'3, (tptr (Tstruct _MarioState noattr))) ::
               (_t'2, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
    (Sassign
      (Efield
        (Ederef (Etempvar _t'19 (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _unk00 tushort)
      (Econst_int (Int.repr 0) tint)))
  (Ssequence
    (Ssequence
      (Sset _t'18 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
      (Sassign
        (Efield
          (Ederef (Etempvar _t'18 (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint)
        (Econst_int (Int.repr 0) tint)))
    (Ssequence
      (Ssequence
        (Sset _t'17 (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
        (Sassign
          (Efield
            (Ederef (Etempvar _t'17 (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint)
          (Econst_int (Int.repr 0) tint)))
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
          (Sassign
            (Efield
              (Ederef (Etempvar _t'16 (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _spawnInfo
              (tptr (Tstruct _SpawnInfo noattr)))
            (Ebinop Oadd
              (Evar _gPlayerSpawnInfos (tarray (Tstruct _SpawnInfo noattr) 0))
              (Econst_int (Int.repr 0) tint)
              (tptr (Tstruct _SpawnInfo noattr)))))
        (Ssequence
          (Ssequence
            (Sset _t'15
              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
            (Sassign
              (Efield
                (Ederef (Etempvar _t'15 (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _statusForCamera
                (tptr (Tstruct _PlayerCameraState noattr)))
              (Ebinop Oadd
                (Evar _gPlayerCameraState (tarray (Tstruct _PlayerCameraState noattr) 2))
                (Econst_int (Int.repr 0) tint)
                (tptr (Tstruct _PlayerCameraState noattr)))))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
              (Sassign
                (Efield
                  (Ederef
                    (Etempvar _t'14 (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _marioBodyState
                  (tptr (Tstruct _MarioBodyState noattr)))
                (Ebinop Oadd
                  (Evar _gBodyStates (tarray (Tstruct _MarioBodyState noattr) 2))
                  (Econst_int (Int.repr 0) tint)
                  (tptr (Tstruct _MarioBodyState noattr)))))
            (Ssequence
              (Ssequence
                (Sset _t'13
                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                (Sassign
                  (Efield
                    (Ederef
                      (Etempvar _t'13 (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr)))
                  (Ebinop Oadd
                    (Evar _gControllers (tarray (Tstruct _Controller noattr) 3))
                    (Econst_int (Int.repr 0) tint)
                    (tptr (Tstruct _Controller noattr)))))
              (Ssequence
                (Ssequence
                  (Sset _t'12
                    (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'12 (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _animList
                      (tptr (Tstruct _DmaHandlerList noattr)))
                    (Eaddrof
                      (Evar _gMarioAnimsBuf (Tstruct _DmaHandlerList noattr))
                      (tptr (Tstruct _DmaHandlerList noattr)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'11
                      (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _t'11 (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _numCoins tshort)
                      (Econst_int (Int.repr 0) tint)))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'10 (Evar _gCurrSaveFileNum tshort))
                        (Scall (Some _t'1)
                          (Evar _save_file_get_total_star_count (Tfunction
                                                                  (tint ::
                                                                   tint ::
                                                                   tint ::
                                                                   nil) tint
                                                                  cc_default))
                          ((Ebinop Osub (Etempvar _t'10 tshort)
                             (Econst_int (Int.repr 1) tint) tint) ::
                           (Ebinop Osub (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 1) tint) tint) ::
                           (Ebinop Osub (Econst_int (Int.repr 25) tint)
                             (Econst_int (Int.repr 1) tint) tint) :: nil)))
                      (Ssequence
                        (Sset _t'9
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'9 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _numStars tshort)
                          (Etempvar _t'1 tint))))
                    (Ssequence
                      (Ssequence
                        (Sset _t'8
                          (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _t'8 (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _numKeys tschar)
                          (Econst_int (Int.repr 0) tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'7
                            (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                          (Sassign
                            (Efield
                              (Ederef
                                (Etempvar _t'7 (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _numLives
                              tschar) (Econst_int (Int.repr 4) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'6
                              (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _t'6 (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _health
                                tshort) (Econst_int (Int.repr 2176) tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'3
                                (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                              (Ssequence
                                (Sset _t'4
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Ssequence
                                  (Sset _t'5
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'4 (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _numStars tshort))
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _t'3 (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _prevNumStarsForDialog tshort)
                                    (Etempvar _t'5 tshort)))))
                            (Ssequence
                              (Ssequence
                                (Sset _t'2
                                  (Evar _gMarioState (tptr (Tstruct _MarioState noattr))))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _t'2 (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _unkB0
                                    tshort) (Econst_int (Int.repr 189) tint)))
                              (Ssequence
                                (Sassign
                                  (Efield
                                    (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                    _coins tshort)
                                  (Econst_int (Int.repr 0) tint))
                                (Sassign
                                  (Efield
                                    (Evar _gHudDisplay (Tstruct _HudDisplay noattr))
                                    _wedges tshort)
                                  (Econst_int (Int.repr 8) tint))))))))))))))))))
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
   noattr ::
 Composite _WallCollisionData Struct
   (Member_plain _x tfloat :: Member_plain _y tfloat ::
    Member_plain _z tfloat :: Member_plain _offsetY tfloat ::
    Member_plain _radius tfloat :: Member_plain _filler (tarray tuchar 2) ::
    Member_plain _numWalls tshort ::
    Member_plain _walls (tarray (tptr (Tstruct _Surface noattr)) 4) :: nil)
   noattr ::
 Composite _HudDisplay Struct
   (Member_plain _lives tshort :: Member_plain _coins tshort ::
    Member_plain _stars tshort :: Member_plain _wedges tshort ::
    Member_plain _keys tshort :: Member_plain _flags tshort ::
    Member_plain _timer tushort :: nil)
   noattr ::
 Composite _ChainSegment Struct
   (Member_plain _posX tfloat :: Member_plain _posY tfloat ::
    Member_plain _posZ tfloat :: Member_plain _pitch tshort ::
    Member_plain _yaw tshort :: Member_plain _roll tshort :: nil)
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
     cc_default)) :: (___stringlit_3, Gvar v___stringlit_3) ::
 (___stringlit_2, Gvar v___stringlit_2) ::
 (___stringlit_1, Gvar v___stringlit_1) ::
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
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_load_patchable_table,
   Gfun(External (EF_external "load_patchable_table"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _DmaHandlerList noattr)) :: tint :: nil) tint
     cc_default)) ::
 (_retrieve_animation_index,
   Gfun(External (EF_external "retrieve_animation_index"
                   (mksignature (AST.Xint :: AST.Xptr :: nil) AST.Xint
                     cc_default)) (tint :: (tptr (tptr tushort)) :: nil) tint
     cc_default)) ::
 (_geo_update_animation_frame,
   Gfun(External (EF_external "geo_update_animation_frame"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _AnimInfo noattr)) :: (tptr tint) :: nil) tshort
     cc_default)) :: (_gPlayerCameraState, Gvar v_gPlayerCameraState) ::
 (_gCameraMovementFlags, Gvar v_gCameraMovementFlags) ::
 (_set_camera_mode,
   Gfun(External (EF_external "set_camera_mode"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _Camera noattr)) :: tshort :: tshort :: nil) tvoid
     cc_default)) :: (_gPlayerSpawnInfos, Gvar v_gPlayerSpawnInfos) ::
 (_gMarioSpawnInfo, Gvar v_gMarioSpawnInfo) ::
 (_gCurrentArea, Gvar v_gCurrentArea) ::
 (_gCurrSaveFileNum, Gvar v_gCurrSaveFileNum) ::
 (_gCurrLevelNum, Gvar v_gCurrLevelNum) ::
 (_gGlobalSoundSource, Gvar v_gGlobalSoundSource) ::
 (_gAudioRandom, Gvar v_gAudioRandom) ::
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
 (_spawn_wind_particles,
   Gfun(External (EF_external "spawn_wind_particles"
                   (mksignature (AST.Xint16signed :: AST.Xint16signed :: nil)
                     AST.Xvoid cc_default)) (tshort :: tshort :: nil) tvoid
     cc_default)) :: (_bhvNormalCap, Gvar v_bhvNormalCap) ::
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
 (_vec3s_copy,
   Gfun(External (EF_external "vec3s_copy"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tshort) :: (tptr tshort) :: nil)
     (tptr tvoid) cc_default)) ::
 (_vec3s_set,
   Gfun(External (EF_external "vec3s_set"
                   (mksignature
                     (AST.Xptr :: AST.Xint16signed :: AST.Xint16signed ::
                      AST.Xint16signed :: nil) AST.Xptr cc_default))
     ((tptr tshort) :: tshort :: tshort :: tshort :: nil) (tptr tvoid)
     cc_default)) ::
 (_vec3s_to_vec3f,
   Gfun(External (EF_external "vec3s_to_vec3f"
                   (mksignature (AST.Xptr :: AST.Xptr :: nil) AST.Xptr
                     cc_default)) ((tptr tfloat) :: (tptr tshort) :: nil)
     (tptr tvoid) cc_default)) ::
 (_atan2s,
   Gfun(External (EF_external "atan2s"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xint16signed cc_default)) (tfloat :: tfloat :: nil)
     tshort cc_default)) ::
 (_f32_find_wall_collision,
   Gfun(External (EF_external "f32_find_wall_collision"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xptr :: AST.Xsingle ::
                      AST.Xsingle :: nil) AST.Xint cc_default))
     ((tptr tfloat) :: (tptr tfloat) :: (tptr tfloat) :: tfloat :: tfloat ::
      nil) tint cc_default)) ::
 (_find_wall_collisions,
   Gfun(External (EF_external "find_wall_collisions"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _WallCollisionData noattr)) :: nil) tint cc_default)) ::
 (_find_ceil,
   Gfun(External (EF_external "find_ceil"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_find_water_level,
   Gfun(External (EF_external "find_water_level"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default)) (tfloat :: tfloat :: nil)
     tfloat cc_default)) ::
 (_find_poison_gas_level,
   Gfun(External (EF_external "find_poison_gas_level"
                   (mksignature (AST.Xsingle :: AST.Xsingle :: nil)
                     AST.Xsingle cc_default)) (tfloat :: tfloat :: nil)
     tfloat cc_default)) :: (_gControllers, Gvar v_gControllers) ::
 (_gMarioAnimsBuf, Gvar v_gMarioAnimsBuf) ::
 (_gGlobalTimer, Gvar v_gGlobalTimer) ::
 (_mario_stop_riding_and_holding,
   Gfun(External (EF_external "mario_stop_riding_and_holding"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_process_interactions,
   Gfun(External (EF_external "mario_process_interactions"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_handle_special_floors,
   Gfun(External (EF_external "mario_handle_special_floors"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_gMarioState, Gvar v_gMarioState) :: (_gHudDisplay, Gvar v_gHudDisplay) ::
 (_level_trigger_warp,
   Gfun(External (EF_external "level_trigger_warp"
                   (mksignature (AST.Xptr :: AST.Xint :: nil)
                     AST.Xint16signed cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tshort cc_default)) ::
 (_gDebugLevelSelect, Gvar v_gDebugLevelSelect) ::
 (_gShowDebugText, Gvar v_gShowDebugText) ::
 (_mario_execute_airborne_action,
   Gfun(External (EF_external "mario_execute_airborne_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_automatic_action,
   Gfun(External (EF_external "mario_execute_automatic_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_cutscene_action,
   Gfun(External (EF_external "mario_execute_cutscene_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_moving_action,
   Gfun(External (EF_external "mario_execute_moving_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_object_action,
   Gfun(External (EF_external "mario_execute_object_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_stationary_action,
   Gfun(External (EF_external "mario_execute_stationary_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_execute_submerged_action,
   Gfun(External (EF_external "mario_execute_submerged_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_gBodyStates, Gvar v_gBodyStates) ::
 (_get_additive_y_vel_for_jumps,
   Gfun(External (EF_external "get_additive_y_vel_for_jumps"
                   (mksignature nil AST.Xsingle cc_default)) nil tfloat
     cc_default)) ::
 (_stub_mario_step_1,
   Gfun(External (EF_external "stub_mario_step_1"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_spawn_object,
   Gfun(External (EF_external "spawn_object"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xptr :: nil)
                     AST.Xptr cc_default))
     ((tptr (Tstruct _Object noattr)) :: tint :: (tptr tuint) :: nil)
     (tptr (Tstruct _Object noattr)) cc_default)) ::
 (_gMarioObject, Gvar v_gMarioObject) ::
 (_print_text_fmt_int,
   Gfun(External (EF_external "print_text_fmt_int"
                   (mksignature
                     (AST.Xint :: AST.Xint :: AST.Xptr :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     (tint :: tint :: (tptr tschar) :: tint :: nil) tvoid cc_default)) ::
 (_save_file_get_total_star_count,
   Gfun(External (EF_external "save_file_get_total_star_count"
                   (mksignature (AST.Xint :: AST.Xint :: AST.Xint :: nil)
                     AST.Xint cc_default)) (tint :: tint :: tint :: nil) tint
     cc_default)) ::
 (_save_file_get_flags,
   Gfun(External (EF_external "save_file_get_flags"
                   (mksignature nil AST.Xint cc_default)) nil tuint
     cc_default)) ::
 (_save_file_get_cap_pos,
   Gfun(External (EF_external "save_file_get_cap_pos"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr tshort) :: nil) tint cc_default)) ::
 (_raise_background_noise,
   Gfun(External (EF_external "raise_background_noise"
                   (mksignature (AST.Xint :: nil) AST.Xvoid cc_default))
     (tint :: nil) tvoid cc_default)) ::
 (_play_infinite_stairs_music,
   Gfun(External (EF_external "play_infinite_stairs_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_fadeout_cap_music,
   Gfun(External (EF_external "fadeout_cap_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) ::
 (_stop_cap_music,
   Gfun(External (EF_external "stop_cap_music"
                   (mksignature nil AST.Xvoid cc_default)) nil tvoid
     cc_default)) :: (_unused80339F10, Gvar v_unused80339F10) ::
 (_unused80339F1C, Gvar v_unused80339F1C) ::
 (_is_anim_at_end, Gfun(Internal f_is_anim_at_end)) ::
 (_is_anim_past_end, Gfun(Internal f_is_anim_past_end)) ::
 (_set_mario_animation, Gfun(Internal f_set_mario_animation)) ::
 (_set_mario_anim_with_accel, Gfun(Internal f_set_mario_anim_with_accel)) ::
 (_set_anim_to_frame, Gfun(Internal f_set_anim_to_frame)) ::
 (_is_anim_past_frame, Gfun(Internal f_is_anim_past_frame)) ::
 (_find_mario_anim_flags_and_translation, Gfun(Internal f_find_mario_anim_flags_and_translation)) ::
 (_update_mario_pos_for_anim, Gfun(Internal f_update_mario_pos_for_anim)) ::
 (_return_mario_anim_y_translation, Gfun(Internal f_return_mario_anim_y_translation)) ::
 (_play_sound_if_no_flag, Gfun(Internal f_play_sound_if_no_flag)) ::
 (_play_mario_jump_sound, Gfun(Internal f_play_mario_jump_sound)) ::
 (_adjust_sound_for_speed, Gfun(Internal f_adjust_sound_for_speed)) ::
 (_play_sound_and_spawn_particles, Gfun(Internal f_play_sound_and_spawn_particles)) ::
 (_play_mario_action_sound, Gfun(Internal f_play_mario_action_sound)) ::
 (_play_mario_landing_sound, Gfun(Internal f_play_mario_landing_sound)) ::
 (_play_mario_landing_sound_once, Gfun(Internal f_play_mario_landing_sound_once)) ::
 (_play_mario_heavy_landing_sound, Gfun(Internal f_play_mario_heavy_landing_sound)) ::
 (_play_mario_heavy_landing_sound_once, Gfun(Internal f_play_mario_heavy_landing_sound_once)) ::
 (_play_mario_sound, Gfun(Internal f_play_mario_sound)) ::
 (_mario_set_forward_vel, Gfun(Internal f_mario_set_forward_vel)) ::
 (_mario_get_floor_class, Gfun(Internal f_mario_get_floor_class)) ::
 (_sTerrainSounds, Gvar v_sTerrainSounds) ::
 (_mario_get_terrain_sound_addend, Gfun(Internal f_mario_get_terrain_sound_addend)) ::
 (_resolve_and_return_wall_collisions, Gfun(Internal f_resolve_and_return_wall_collisions)) ::
 (_vec3f_find_ceil, Gfun(Internal f_vec3f_find_ceil)) ::
 (_mario_facing_downhill, Gfun(Internal f_mario_facing_downhill)) ::
 (_mario_floor_is_slippery, Gfun(Internal f_mario_floor_is_slippery)) ::
 (_mario_floor_is_slope, Gfun(Internal f_mario_floor_is_slope)) ::
 (_mario_floor_is_steep, Gfun(Internal f_mario_floor_is_steep)) ::
 (_find_floor_height_relative_polar, Gfun(Internal f_find_floor_height_relative_polar)) ::
 (_find_floor_slope, Gfun(Internal f_find_floor_slope)) ::
 (_update_mario_sound_and_camera, Gfun(Internal f_update_mario_sound_and_camera)) ::
 (_set_steep_jump_action, Gfun(Internal f_set_steep_jump_action)) ::
 (_set_mario_y_vel_based_on_fspeed, Gfun(Internal f_set_mario_y_vel_based_on_fspeed)) ::
 (_set_mario_action_airborne, Gfun(Internal f_set_mario_action_airborne)) ::
 (_set_mario_action_moving, Gfun(Internal f_set_mario_action_moving)) ::
 (_set_mario_action_submerged, Gfun(Internal f_set_mario_action_submerged)) ::
 (_set_mario_action_cutscene, Gfun(Internal f_set_mario_action_cutscene)) ::
 (_set_mario_action, Gfun(Internal f_set_mario_action)) ::
 (_set_jump_from_landing, Gfun(Internal f_set_jump_from_landing)) ::
 (_set_jumping_action, Gfun(Internal f_set_jumping_action)) ::
 (_drop_and_set_mario_action, Gfun(Internal f_drop_and_set_mario_action)) ::
 (_hurt_and_set_mario_action, Gfun(Internal f_hurt_and_set_mario_action)) ::
 (_check_common_action_exits, Gfun(Internal f_check_common_action_exits)) ::
 (_check_common_hold_action_exits, Gfun(Internal f_check_common_hold_action_exits)) ::
 (_transition_submerged_to_walking, Gfun(Internal f_transition_submerged_to_walking)) ::
 (_set_water_plunge_action, Gfun(Internal f_set_water_plunge_action)) ::
 (_sSquishScaleOverTime, Gvar v_sSquishScaleOverTime) ::
 (_squish_mario_model, Gfun(Internal f_squish_mario_model)) ::
 (_debug_print_speed_action_normal, Gfun(Internal f_debug_print_speed_action_normal)) ::
 (_update_mario_button_inputs, Gfun(Internal f_update_mario_button_inputs)) ::
 (_update_mario_joystick_inputs, Gfun(Internal f_update_mario_joystick_inputs)) ::
 (_update_mario_geometry_inputs, Gfun(Internal f_update_mario_geometry_inputs)) ::
 (_update_mario_inputs, Gfun(Internal f_update_mario_inputs)) ::
 (_set_submerged_cam_preset_and_spawn_bubbles, Gfun(Internal f_set_submerged_cam_preset_and_spawn_bubbles)) ::
 (_update_mario_health, Gfun(Internal f_update_mario_health)) ::
 (_update_mario_info_for_cam, Gfun(Internal f_update_mario_info_for_cam)) ::
 (_mario_reset_bodystate, Gfun(Internal f_mario_reset_bodystate)) ::
 (_sink_mario_in_quicksand, Gfun(Internal f_sink_mario_in_quicksand)) ::
 (_sCapFlickerFrames, Gvar v_sCapFlickerFrames) ::
 (_update_and_return_cap_flags, Gfun(Internal f_update_and_return_cap_flags)) ::
 (_mario_update_hitbox_and_cap_model, Gfun(Internal f_mario_update_hitbox_and_cap_model)) ::
 (_execute_mario_action, Gfun(Internal f_execute_mario_action)) ::
 (_init_mario, Gfun(Internal f_init_mario)) ::
 (_init_mario_from_save_file, Gfun(Internal f_init_mario_from_save_file)) ::
 nil).

Definition public_idents : list ident :=
(_init_mario_from_save_file :: _init_mario :: _execute_mario_action ::
 _mario_update_hitbox_and_cap_model :: _update_and_return_cap_flags ::
 _sCapFlickerFrames :: _sink_mario_in_quicksand :: _mario_reset_bodystate ::
 _update_mario_info_for_cam :: _update_mario_health ::
 _set_submerged_cam_preset_and_spawn_bubbles :: _update_mario_inputs ::
 _update_mario_geometry_inputs :: _update_mario_joystick_inputs ::
 _update_mario_button_inputs :: _debug_print_speed_action_normal ::
 _squish_mario_model :: _sSquishScaleOverTime :: _set_water_plunge_action ::
 _transition_submerged_to_walking :: _check_common_hold_action_exits ::
 _check_common_action_exits :: _hurt_and_set_mario_action ::
 _drop_and_set_mario_action :: _set_jumping_action ::
 _set_jump_from_landing :: _set_mario_action :: _set_steep_jump_action ::
 _update_mario_sound_and_camera :: _find_floor_slope ::
 _find_floor_height_relative_polar :: _mario_floor_is_steep ::
 _mario_floor_is_slope :: _mario_floor_is_slippery ::
 _mario_facing_downhill :: _vec3f_find_ceil ::
 _resolve_and_return_wall_collisions :: _mario_get_terrain_sound_addend ::
 _sTerrainSounds :: _mario_get_floor_class :: _mario_set_forward_vel ::
 _play_mario_sound :: _play_mario_heavy_landing_sound_once ::
 _play_mario_heavy_landing_sound :: _play_mario_landing_sound_once ::
 _play_mario_landing_sound :: _play_mario_action_sound ::
 _play_sound_and_spawn_particles :: _adjust_sound_for_speed ::
 _play_mario_jump_sound :: _play_sound_if_no_flag ::
 _return_mario_anim_y_translation :: _update_mario_pos_for_anim ::
 _find_mario_anim_flags_and_translation :: _is_anim_past_frame ::
 _set_anim_to_frame :: _set_mario_anim_with_accel :: _set_mario_animation ::
 _is_anim_past_end :: _is_anim_at_end :: _unused80339F1C ::
 _unused80339F10 :: _stop_cap_music :: _fadeout_cap_music ::
 _play_infinite_stairs_music :: _raise_background_noise ::
 _save_file_get_cap_pos :: _save_file_get_flags ::
 _save_file_get_total_star_count :: _print_text_fmt_int :: _gMarioObject ::
 _spawn_object :: _stub_mario_step_1 :: _get_additive_y_vel_for_jumps ::
 _gBodyStates :: _mario_execute_submerged_action ::
 _mario_execute_stationary_action :: _mario_execute_object_action ::
 _mario_execute_moving_action :: _mario_execute_cutscene_action ::
 _mario_execute_automatic_action :: _mario_execute_airborne_action ::
 _gShowDebugText :: _gDebugLevelSelect :: _level_trigger_warp ::
 _gHudDisplay :: _gMarioState :: _mario_handle_special_floors ::
 _mario_process_interactions :: _mario_stop_riding_and_holding ::
 _gGlobalTimer :: _gMarioAnimsBuf :: _gControllers ::
 _find_poison_gas_level :: _find_water_level :: _find_floor :: _find_ceil ::
 _find_wall_collisions :: _f32_find_wall_collision :: _atan2s ::
 _vec3s_to_vec3f :: _vec3s_set :: _vec3s_copy :: _vec3f_set :: _vec3f_copy ::
 _gSineTable :: _bhvNormalCap :: _spawn_wind_particles ::
 _set_sound_moving_speed :: _play_sound :: _gAudioRandom ::
 _gGlobalSoundSource :: _gCurrLevelNum :: _gCurrSaveFileNum ::
 _gCurrentArea :: _gMarioSpawnInfo :: _gPlayerSpawnInfos ::
 _set_camera_mode :: _gCameraMovementFlags :: _gPlayerCameraState ::
 _geo_update_animation_frame :: _retrieve_animation_index ::
 _load_patchable_table :: _segmented_to_virtual :: _sqrtf ::
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


