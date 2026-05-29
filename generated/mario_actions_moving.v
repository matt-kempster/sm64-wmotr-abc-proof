(* ======================================================================
   GENERATED FILE -- DO NOT EDIT.
   Produced by: pipeline/clightgen.sh
   From source: vendor/sm64/src/game/mario_actions_moving.c
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
  Definition source_file := "vendor/sm64/src/game/mario_actions_moving.c".
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
Definition _LandingAction : ident := $"LandingAction".
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
Definition _aPressedAction : ident := $"aPressedAction".
Definition _accel : ident := $"accel".
Definition _act_backflip_land : ident := $"act_backflip_land".
Definition _act_backward_ground_kb : ident := $"act_backward_ground_kb".
Definition _act_braking : ident := $"act_braking".
Definition _act_burning_ground : ident := $"act_burning_ground".
Definition _act_butt_slide : ident := $"act_butt_slide".
Definition _act_crawling : ident := $"act_crawling".
Definition _act_crouch_slide : ident := $"act_crouch_slide".
Definition _act_death_exit_land : ident := $"act_death_exit_land".
Definition _act_decelerating : ident := $"act_decelerating".
Definition _act_dive_slide : ident := $"act_dive_slide".
Definition _act_double_jump_land : ident := $"act_double_jump_land".
Definition _act_finish_turning_around : ident := $"act_finish_turning_around".
Definition _act_forward_ground_kb : ident := $"act_forward_ground_kb".
Definition _act_freefall_land : ident := $"act_freefall_land".
Definition _act_ground_bonk : ident := $"act_ground_bonk".
Definition _act_hard_backward_ground_kb : ident := $"act_hard_backward_ground_kb".
Definition _act_hard_forward_ground_kb : ident := $"act_hard_forward_ground_kb".
Definition _act_hold_butt_slide : ident := $"act_hold_butt_slide".
Definition _act_hold_decelerating : ident := $"act_hold_decelerating".
Definition _act_hold_freefall_land : ident := $"act_hold_freefall_land".
Definition _act_hold_heavy_walking : ident := $"act_hold_heavy_walking".
Definition _act_hold_jump_land : ident := $"act_hold_jump_land".
Definition _act_hold_quicksand_jump_land : ident := $"act_hold_quicksand_jump_land".
Definition _act_hold_stomach_slide : ident := $"act_hold_stomach_slide".
Definition _act_hold_walking : ident := $"act_hold_walking".
Definition _act_jump_land : ident := $"act_jump_land".
Definition _act_long_jump_land : ident := $"act_long_jump_land".
Definition _act_move_punching : ident := $"act_move_punching".
Definition _act_quicksand_jump_land : ident := $"act_quicksand_jump_land".
Definition _act_riding_shell_ground : ident := $"act_riding_shell_ground".
Definition _act_side_flip_land : ident := $"act_side_flip_land".
Definition _act_slide_kick_slide : ident := $"act_slide_kick_slide".
Definition _act_soft_backward_ground_kb : ident := $"act_soft_backward_ground_kb".
Definition _act_soft_forward_ground_kb : ident := $"act_soft_forward_ground_kb".
Definition _act_stomach_slide : ident := $"act_stomach_slide".
Definition _act_triple_jump_land : ident := $"act_triple_jump_land".
Definition _act_turning_around : ident := $"act_turning_around".
Definition _act_walking : ident := $"act_walking".
Definition _action : ident := $"action".
Definition _actionArg : ident := $"actionArg".
Definition _actionState : ident := $"actionState".
Definition _actionTimer : ident := $"actionTimer".
Definition _activeAreaIndex : ident := $"activeAreaIndex".
Definition _activeFlags : ident := $"activeFlags".
Definition _adjust_sound_for_speed : ident := $"adjust_sound_for_speed".
Definition _airAction : ident := $"airAction".
Definition _align_with_floor : ident := $"align_with_floor".
Definition _analog_stick_held_back : ident := $"analog_stick_held_back".
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
Definition _anim_and_audio_for_heavy_walk : ident := $"anim_and_audio_for_heavy_walk".
Definition _anim_and_audio_for_hold_walk : ident := $"anim_and_audio_for_hold_walk".
Definition _anim_and_audio_for_walk : ident := $"anim_and_audio_for_walk".
Definition _animation : ident := $"animation".
Definition _animation1 : ident := $"animation1".
Definition _animation2 : ident := $"animation2".
Definition _apply_landing_accel : ident := $"apply_landing_accel".
Definition _apply_slope_accel : ident := $"apply_slope_accel".
Definition _apply_slope_decel : ident := $"apply_slope_decel".
Definition _approach_f32 : ident := $"approach_f32".
Definition _approach_s32 : ident := $"approach_s32".
Definition _area : ident := $"area".
Definition _areaCenX : ident := $"areaCenX".
Definition _areaCenY : ident := $"areaCenY".
Definition _areaCenZ : ident := $"areaCenZ".
Definition _areaIndex : ident := $"areaIndex".
Definition _arg2 : ident := $"arg2".
Definition _arg3 : ident := $"arg3".
Definition _arg4 : ident := $"arg4".
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
Definition _begin_braking_action : ident := $"begin_braking_action".
Definition _begin_walking_action : ident := $"begin_walking_action".
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
Definition _check_common_moving_cancels : ident := $"check_common_moving_cancels".
Definition _check_ground_dive_or_punch : ident := $"check_ground_dive_or_punch".
Definition _check_ledge_climb_down : ident := $"check_ledge_climb_down".
Definition _children : ident := $"children".
Definition _collidedObjInteractTypes : ident := $"collidedObjInteractTypes".
Definition _collidedObjs : ident := $"collidedObjs".
Definition _collisionData : ident := $"collisionData".
Definition _common_ground_knockback_action : ident := $"common_ground_knockback_action".
Definition _common_landing_action : ident := $"common_landing_action".
Definition _common_landing_cancels : ident := $"common_landing_cancels".
Definition _common_slide_action : ident := $"common_slide_action".
Definition _common_slide_action_with_jump : ident := $"common_slide_action_with_jump".
Definition _controller : ident := $"controller".
Definition _controllerData : ident := $"controllerData".
Definition _count : ident := $"count".
Definition _curAnim : ident := $"curAnim".
Definition _curBhvCommand : ident := $"curBhvCommand".
Definition _currentAddr : ident := $"currentAddr".
Definition _cutscene : ident := $"cutscene".
Definition _dWallAngle : ident := $"dWallAngle".
Definition _dYaw : ident := $"dYaw".
Definition _decel : ident := $"decel".
Definition _decelCoef : ident := $"decelCoef".
Definition _defMode : ident := $"defMode".
Definition _destArea : ident := $"destArea".
Definition _destLevel : ident := $"destLevel".
Definition _destNode : ident := $"destNode".
Definition _dialog : ident := $"dialog".
Definition _displacement : ident := $"displacement".
Definition _dmaTable : ident := $"dmaTable".
Definition _doorStatus : ident := $"doorStatus".
Definition _doubleJumpTimer : ident := $"doubleJumpTimer".
Definition _drop_and_set_mario_action : ident := $"drop_and_set_mario_action".
Definition _dx : ident := $"dx".
Definition _dz : ident := $"dz".
Definition _endAction : ident := $"endAction".
Definition _errnum : ident := $"errnum".
Definition _eyeState : ident := $"eyeState".
Definition _faceAngle : ident := $"faceAngle".
Definition _facingDYaw : ident := $"facingDYaw".
Definition _fadeWarpOpacity : ident := $"fadeWarpOpacity".
Definition _fastAction : ident := $"fastAction".
Definition _filler : ident := $"filler".
Definition _filler1 : ident := $"filler1".
Definition _filler2 : ident := $"filler2".
Definition _find_floor : ident := $"find_floor".
Definition _find_floor_slope : ident := $"find_floor_slope".
Definition _find_wall_collisions : ident := $"find_wall_collisions".
Definition _flags : ident := $"flags".
Definition _floor : ident := $"floor".
Definition _floorAngle : ident := $"floorAngle".
Definition _floorDYaw : ident := $"floorDYaw".
Definition _floorHeight : ident := $"floorHeight".
Definition _focus : ident := $"focus".
Definition _force : ident := $"force".
Definition _forward : ident := $"forward".
Definition _forwardVel : ident := $"forwardVel".
Definition _frame1 : ident := $"frame1".
Definition _frame2 : ident := $"frame2".
Definition _framesSinceA : ident := $"framesSinceA".
Definition _framesSinceB : ident := $"framesSinceB".
Definition _frictionFactor : ident := $"frictionFactor".
Definition _gSineTable : ident := $"gSineTable".
Definition _gWaterSurfacePseudoFloor : ident := $"gWaterSurfacePseudoFloor".
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
Definition _intendedDYaw : ident := $"intendedDYaw".
Definition _intendedMag : ident := $"intendedMag".
Definition _intendedYaw : ident := $"intendedYaw".
Definition _interactObj : ident := $"interactObj".
Definition _invincTimer : ident := $"invincTimer".
Definition _is_anim_at_end : ident := $"is_anim_at_end".
Definition _is_anim_past_frame : ident := $"is_anim_past_frame".
Definition _jumpAction : ident := $"jumpAction".
Definition _landingAction : ident := $"landingAction".
Definition _length : ident := $"length".
Definition _loopEnd : ident := $"loopEnd".
Definition _loopStart : ident := $"loopStart".
Definition _lossFactor : ident := $"lossFactor".
Definition _lowerY : ident := $"lowerY".
Definition _m : ident := $"m".
Definition _macroObjects : ident := $"macroObjects".
Definition _main : ident := $"main".
Definition _marioBodyState : ident := $"marioBodyState".
Definition _marioObj : ident := $"marioObj".
Definition _mario_bonk_reflection : ident := $"mario_bonk_reflection".
Definition _mario_check_object_grab : ident := $"mario_check_object_grab".
Definition _mario_drop_held_object : ident := $"mario_drop_held_object".
Definition _mario_execute_moving_action : ident := $"mario_execute_moving_action".
Definition _mario_facing_downhill : ident := $"mario_facing_downhill".
Definition _mario_floor_is_slippery : ident := $"mario_floor_is_slippery".
Definition _mario_floor_is_slope : ident := $"mario_floor_is_slope".
Definition _mario_get_floor_class : ident := $"mario_get_floor_class".
Definition _mario_grab_used_object : ident := $"mario_grab_used_object".
Definition _mario_push_off_steep_floor : ident := $"mario_push_off_steep_floor".
Definition _mario_set_forward_vel : ident := $"mario_set_forward_vel".
Definition _mario_stop_riding_object : ident := $"mario_stop_riding_object".
Definition _mario_update_moving_sand : ident := $"mario_update_moving_sand".
Definition _mario_update_punch_sequence : ident := $"mario_update_punch_sequence".
Definition _mario_update_quicksand : ident := $"mario_update_quicksand".
Definition _mario_update_windy_ground : ident := $"mario_update_windy_ground".
Definition _maxTargetSpeed : ident := $"maxTargetSpeed".
Definition _mode : ident := $"mode".
Definition _model : ident := $"model".
Definition _modelState : ident := $"modelState".
Definition _movedDistance : ident := $"movedDistance".
Definition _movingBackward : ident := $"movingBackward".
Definition _mtxf_align_terrain_triangle : ident := $"mtxf_align_terrain_triangle".
Definition _musicParam : ident := $"musicParam".
Definition _musicParam2 : ident := $"musicParam2".
Definition _newFacingDYaw : ident := $"newFacingDYaw".
Definition _newSpeed : ident := $"newSpeed".
Definition _next : ident := $"next".
Definition _nextYaw : ident := $"nextYaw".
Definition _node : ident := $"node".
Definition _normal : ident := $"normal".
Definition _normalY : ident := $"normalY".
Definition _numCoins : ident := $"numCoins".
Definition _numCollidedObjs : ident := $"numCollidedObjs".
Definition _numFrames : ident := $"numFrames".
Definition _numKeys : ident := $"numKeys".
Definition _numLives : ident := $"numLives".
Definition _numStars : ident := $"numStars".
Definition _numViews : ident := $"numViews".
Definition _numWalls : ident := $"numWalls".
Definition _object : ident := $"object".
Definition _objectSpawnInfos : ident := $"objectSpawnInfos".
Definition _offFloorAction : ident := $"offFloorAction".
Definition _offset : ident := $"offset".
Definition _offsetY : ident := $"offsetY".
Definition _oldSpeed : ident := $"oldSpeed".
Definition _originOffset : ident := $"originOffset".
Definition _paintingWarpNodes : ident := $"paintingWarpNodes".
Definition _parent : ident := $"parent".
Definition _parentObj : ident := $"parentObj".
Definition _particleFlags : ident := $"particleFlags".
Definition _peakHeight : ident := $"peakHeight".
Definition _perform_ground_step : ident := $"perform_ground_step".
Definition _pitch : ident := $"pitch".
Definition _platform : ident := $"platform".
Definition _play_mario_heavy_landing_sound_once : ident := $"play_mario_heavy_landing_sound_once".
Definition _play_mario_jump_sound : ident := $"play_mario_jump_sound".
Definition _play_mario_landing_sound : ident := $"play_mario_landing_sound".
Definition _play_mario_landing_sound_once : ident := $"play_mario_landing_sound_once".
Definition _play_sound : ident := $"play_sound".
Definition _play_sound_and_spawn_particles : ident := $"play_sound_and_spawn_particles".
Definition _play_sound_if_no_flag : ident := $"play_sound_if_no_flag".
Definition _play_step_sound : ident := $"play_step_sound".
Definition _pos : ident := $"pos".
Definition _prev : ident := $"prev".
Definition _prevAction : ident := $"prevAction".
Definition _prevNumStarsForDialog : ident := $"prevNumStarsForDialog".
Definition _prevObj : ident := $"prevObj".
Definition _punchState : ident := $"punchState".
Definition _push_or_sidle_wall : ident := $"push_or_sidle_wall".
Definition _quicksandDepth : ident := $"quicksandDepth".
Definition _quicksand_jump_land_action : ident := $"quicksand_jump_land_action".
Definition _radius : ident := $"radius".
Definition _rawData : ident := $"rawData".
Definition _rawStickX : ident := $"rawStickX".
Definition _rawStickY : ident := $"rawStickY".
Definition _respawnInfo : ident := $"respawnInfo".
Definition _respawnInfoType : ident := $"respawnInfoType".
Definition _riddenObj : ident := $"riddenObj".
Definition _room : ident := $"room".
Definition _sBackflipLandAction : ident := $"sBackflipLandAction".
Definition _sDoubleJumpLandAction : ident := $"sDoubleJumpLandAction".
Definition _sFloorAlignMatrix : ident := $"sFloorAlignMatrix".
Definition _sFreefallLandAction : ident := $"sFreefallLandAction".
Definition _sHoldFreefallLandAction : ident := $"sHoldFreefallLandAction".
Definition _sHoldJumpLandAction : ident := $"sHoldJumpLandAction".
Definition _sJumpLandAction : ident := $"sJumpLandAction".
Definition _sLongJumpLandAction : ident := $"sLongJumpLandAction".
Definition _sSideFlipLandAction : ident := $"sSideFlipLandAction".
Definition _sTripleJumpLandAction : ident := $"sTripleJumpLandAction".
Definition _scale : ident := $"scale".
Definition _segmented_to_virtual : ident := $"segmented_to_virtual".
Definition _setAPressAction : ident := $"setAPressAction".
Definition _set_jump_from_landing : ident := $"set_jump_from_landing".
Definition _set_jumping_action : ident := $"set_jumping_action".
Definition _set_mario_action : ident := $"set_mario_action".
Definition _set_mario_anim_with_accel : ident := $"set_mario_anim_with_accel".
Definition _set_mario_animation : ident := $"set_mario_animation".
Definition _set_triple_jump_action : ident := $"set_triple_jump_action".
Definition _set_water_plunge_action : ident := $"set_water_plunge_action".
Definition _sharedChild : ident := $"sharedChild".
Definition _should_begin_sliding : ident := $"should_begin_sliding".
Definition _sideward : ident := $"sideward".
Definition _size : ident := $"size".
Definition _slideAction : ident := $"slideAction".
Definition _slideLevel : ident := $"slideLevel".
Definition _slideSpeed : ident := $"slideSpeed".
Definition _slideVelX : ident := $"slideVelX".
Definition _slideVelZ : ident := $"slideVelZ".
Definition _slideYaw : ident := $"slideYaw".
Definition _slide_bonk : ident := $"slide_bonk".
Definition _slopeAccel : ident := $"slopeAccel".
Definition _slopeAngle : ident := $"slopeAngle".
Definition _slopeClass : ident := $"slopeClass".
Definition _slowAction : ident := $"slowAction".
Definition _spawnInfo : ident := $"spawnInfo".
Definition _sqrtf : ident := $"sqrtf".
Definition _squishTimer : ident := $"squishTimer".
Definition _srcAddr : ident := $"srcAddr".
Definition _startAngle : ident := $"startAngle".
Definition _startFrame : ident := $"startFrame".
Definition _startPos : ident := $"startPos".
Definition _startYaw : ident := $"startYaw".
Definition _status : ident := $"status".
Definition _statusData : ident := $"statusData".
Definition _statusForCamera : ident := $"statusForCamera".
Definition _steepness : ident := $"steepness".
Definition _stepResult : ident := $"stepResult".
Definition _stickMag : ident := $"stickMag".
Definition _stickX : ident := $"stickX".
Definition _stickY : ident := $"stickY".
Definition _stick_x : ident := $"stick_x".
Definition _stick_y : ident := $"stick_y".
Definition _stomach_slide_action : ident := $"stomach_slide_action".
Definition _stopAction : ident := $"stopAction".
Definition _stopSpeed : ident := $"stopSpeed".
Definition _stopped : ident := $"stopped".
Definition _strength : ident := $"strength".
Definition _surfaceRooms : ident := $"surfaceRooms".
Definition _targetPitch : ident := $"targetPitch".
Definition _targetSpeed : ident := $"targetSpeed".
Definition _terrainData : ident := $"terrainData".
Definition _terrainSoundAddend : ident := $"terrainSoundAddend".
Definition _terrainType : ident := $"terrainType".
Definition _throwMatrix : ident := $"throwMatrix".
Definition _tilt_body_butt_slide : ident := $"tilt_body_butt_slide".
Definition _tilt_body_ground_shell : ident := $"tilt_body_ground_shell".
Definition _tilt_body_running : ident := $"tilt_body_running".
Definition _tilt_body_walking : ident := $"tilt_body_walking".
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
Definition _update_decelerating_speed : ident := $"update_decelerating_speed".
Definition _update_shell_speed : ident := $"update_shell_speed".
Definition _update_sliding : ident := $"update_sliding".
Definition _update_sliding_angle : ident := $"update_sliding_angle".
Definition _update_walking_speed : ident := $"update_walking_speed".
Definition _upperY : ident := $"upperY".
Definition _usedObj : ident := $"usedObj".
Definition _val00 : ident := $"val00".
Definition _val02 : ident := $"val02".
Definition _val04 : ident := $"val04".
Definition _val08 : ident := $"val08".
Definition _val0C : ident := $"val0C".
Definition _val14 : ident := $"val14".
Definition _values : ident := $"values".
Definition _vec3f_copy : ident := $"vec3f_copy".
Definition _vel : ident := $"vel".
Definition _vertex1 : ident := $"vertex1".
Definition _vertex2 : ident := $"vertex2".
Definition _vertex3 : ident := $"vertex3".
Definition _verySteepAction : ident := $"verySteepAction".
Definition _views : ident := $"views".
Definition _wall : ident := $"wall".
Definition _wallAngle : ident := $"wallAngle".
Definition _wallCols : ident := $"wallCols".
Definition _wallDYaw : ident := $"wallDYaw".
Definition _wallKickTimer : ident := $"wallKickTimer".
Definition _walls : ident := $"walls".
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

Definition v_gWaterSurfacePseudoFloor := {|
  gvar_info := (Tstruct _Surface noattr);
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

Definition v_sJumpLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 201327152) ::
                Init_int32 (Int.repr 50333825) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sFreefallLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 201327154) ::
                Init_int32 (Int.repr 50333825) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sSideFlipLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 201327155) ::
                Init_int32 (Int.repr 50333825) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sHoldJumpLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779425) ::
                Init_int32 (Int.repr 134218292) ::
                Init_int32 (Int.repr 50333856) ::
                Init_int32 (Int.repr 16779425) :: Init_int32 (Int.repr 81) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sHoldFreefallLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779425) ::
                Init_int32 (Int.repr 134218293) ::
                Init_int32 (Int.repr 50333856) ::
                Init_int32 (Int.repr 16779425) :: Init_int32 (Int.repr 81) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sLongJumpLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 6) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 134218299) ::
                Init_int32 (Int.repr 50333832) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sDoubleJumpLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 5) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 201327153) ::
                Init_int32 (Int.repr 50333824) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sTripleJumpLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 0) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 134218298) :: Init_int32 (Int.repr 0) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sBackflipLandAction := {|
  gvar_info := (Tstruct _LandingAction noattr);
  gvar_init := (Init_int16 (Int.repr 4) :: Init_int16 (Int.repr 0) ::
                Init_int32 (Int.repr 16779404) ::
                Init_int32 (Int.repr 134218287) ::
                Init_int32 (Int.repr 16779395) ::
                Init_int32 (Int.repr 16779404) :: Init_int32 (Int.repr 80) ::
                nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition v_sFloorAlignMatrix := {|
  gvar_info := (tarray (tarray (tarray tfloat 4) 4) 2);
  gvar_init := (Init_space 128 :: nil);
  gvar_readonly := false;
  gvar_volatile := false
|}.

Definition f_tilt_body_running := {|
  fn_return := tshort;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_pitch, tshort) :: (_t'1, tshort) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _find_floor_slope (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tshort :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 0) tint) :: nil))
    (Sset _pitch (Ecast (Etempvar _t'1 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _forwardVel tfloat))
      (Sset _pitch
        (Ecast
          (Ebinop Odiv
            (Ebinop Omul (Etempvar _pitch tshort) (Etempvar _t'2 tfloat)
              tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1109393408)) tfloat)
            tfloat) tshort)))
    (Sreturn (Some (Eunop Oneg (Etempvar _pitch tshort) tint)))))
|}.

Definition f_play_step_sound := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_frame1, tshort) :: (_frame2, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'10, tshort) :: (_t'9, (tptr (Tstruct _Object noattr))) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tshort) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: (_t'5, tfloat) ::
               (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _is_anim_past_frame (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tshort :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _frame1 tshort) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sset _t'2 (Econst_int (Int.repr 1) tint))
      (Ssequence
        (Scall (Some _t'3)
          (Evar _is_anim_past_frame (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tshort :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _frame2 tshort) :: nil))
        (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))))
  (Sifthenelse (Etempvar _t'2 tint)
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _flags tuint))
      (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                     (Econst_int (Int.repr 4) tint) tuint)
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'10
              (Efield
                (Efield
                  (Efield
                    (Efield
                      (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                        (Tstruct _Object noattr)) _header
                      (Tstruct _ObjectNode noattr)) _gfx
                    (Tstruct _GraphNodeObject noattr)) _animInfo
                  (Tstruct _AnimInfo noattr)) _animID tshort))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tshort)
                           (Econst_int (Int.repr 146) tint) tint)
              (Scall None
                (Evar _play_sound_and_spawn_particles (Tfunction
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
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 47) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 144) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Scall None
                (Evar _play_sound_and_spawn_particles (Tfunction
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
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 42) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 144) tint) tuint)
                         (Econst_int (Int.repr 8) tint) tuint) tuint)
                     (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
                       (Econst_int (Int.repr 128) tint) tint) tuint)
                   (Econst_int (Int.repr 1) tint) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil)))))
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                         tint)
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
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 28) tint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 46) tint) tuint)
                           (Econst_int (Int.repr 16) tint) tuint) tuint)
                       (Ebinop Oshl
                         (Ecast (Econst_int (Int.repr 0) tint) tuint)
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
                      (Tstruct _AnimInfo noattr)) _animID tshort))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
                               (Econst_int (Int.repr 146) tint) tint)
                  (Scall None
                    (Evar _play_sound_and_spawn_particles (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
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
                               (Ecast (Econst_int (Int.repr 32) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 33554432) tint)
                             (Econst_int (Int.repr 67108864) tint) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Scall None
                    (Evar _play_sound_and_spawn_particles (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             tuint ::
                                                             tuint :: nil)
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
                               (Ecast (Econst_int (Int.repr 16) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Ebinop Oor
                           (Ebinop Oor (Econst_int (Int.repr 33554432) tint)
                             (Econst_int (Int.repr 67108864) tint) tint)
                           (Econst_int (Int.repr 128) tint) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Econst_int (Int.repr 0) tint) :: nil)))))))))
    Sskip))
|}.

Definition f_align_with_floor := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tfloat) :: (_t'4, tshort) :: (_t'3, tushort) ::
               (_t'2, tushort) :: (_t'1, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'5
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floorHeight tfloat))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
      (Etempvar _t'5 tfloat)))
  (Ssequence
    (Ssequence
      (Sset _t'3
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _unk00 tushort))
      (Ssequence
        (Sset _t'4
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Scall None
          (Evar _mtxf_align_terrain_triangle (Tfunction
                                               ((tptr (tarray tfloat 4)) ::
                                                (tptr tfloat) :: tshort ::
                                                tfloat :: nil) tvoid
                                               cc_default))
          ((Ederef
             (Ebinop Oadd
               (Evar _sFloorAlignMatrix (tarray (tarray (tarray tfloat 4) 4) 2))
               (Etempvar _t'3 tushort) (tptr (tarray (tarray tfloat 4) 4)))
             (tarray (tarray tfloat 4) 4)) ::
           (Efield
             (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
               (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) ::
           (Etempvar _t'4 tshort) ::
           (Econst_single (Float32.of_bits (Int.repr 1109393408)) tfloat) ::
           nil))))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _unk00 tushort))
        (Sassign
          (Efield
            (Efield
              (Efield
                (Ederef (Etempvar _t'1 (tptr (Tstruct _Object noattr)))
                  (Tstruct _Object noattr)) _header
                (Tstruct _ObjectNode noattr)) _gfx
              (Tstruct _GraphNodeObject noattr)) _throwMatrix
            (tptr (tarray (tarray tfloat 4) 4)))
          (Ebinop Oadd
            (Evar _sFloorAlignMatrix (tarray (tarray (tarray tfloat 4) 4) 2))
            (Etempvar _t'2 tushort) (tptr (tarray (tarray tfloat 4) 4))))))))
|}.

Definition f_begin_walking_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_forwardVel, tfloat) :: (_action, tuint) ::
                (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tuint) :: (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedYaw tshort))
    (Sassign
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort)
      (Etempvar _t'2 tshort)))
  (Ssequence
    (Scall None
      (Evar _mario_set_forward_vel (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tfloat :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Etempvar _forwardVel tfloat) :: nil))
    (Ssequence
      (Scall (Some _t'1)
        (Evar _set_mario_action (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: tuint :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _action tuint) :: (Etempvar _actionArg tuint) :: nil))
      (Sreturn (Some (Etempvar _t'1 tuint))))))
|}.

Definition f_check_ledge_climb_down := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_wallCols, (Tstruct _WallCollisionData noattr)) ::
              (_floor, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_temps := ((_floorHeight, tfloat) ::
               (_wall, (tptr (Tstruct _Surface noattr))) ::
               (_wallAngle, tshort) :: (_wallDYaw, tshort) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tshort) ::
               (_t'1, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, (tptr (Tstruct _Surface noattr))) ::
               (_t'14, tshort) :: (_t'13, tfloat) :: (_t'12, tfloat) ::
               (_t'11, tshort) :: (_t'10, tfloat) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'6
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _forwardVel tfloat))
  (Sifthenelse (Ebinop Olt (Etempvar _t'6 tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                 tint)
    (Ssequence
      (Ssequence
        (Sset _t'22
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
              (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
        (Sassign
          (Efield (Evar _wallCols (Tstruct _WallCollisionData noattr)) _x
            tfloat) (Etempvar _t'22 tfloat)))
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Efield (Evar _wallCols (Tstruct _WallCollisionData noattr)) _y
              tfloat) (Etempvar _t'21 tfloat)))
        (Ssequence
          (Ssequence
            (Sset _t'20
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
                  (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
            (Sassign
              (Efield (Evar _wallCols (Tstruct _WallCollisionData noattr)) _z
                tfloat) (Etempvar _t'20 tfloat)))
          (Ssequence
            (Sassign
              (Efield (Evar _wallCols (Tstruct _WallCollisionData noattr))
                _radius tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat))
            (Ssequence
              (Sassign
                (Efield (Evar _wallCols (Tstruct _WallCollisionData noattr))
                  _offsetY tfloat)
                (Eunop Oneg
                  (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                  tfloat))
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _find_wall_collisions (Tfunction
                                                ((tptr (Tstruct _WallCollisionData noattr)) ::
                                                 nil) tint cc_default))
                  ((Eaddrof
                     (Evar _wallCols (Tstruct _WallCollisionData noattr))
                     (tptr (Tstruct _WallCollisionData noattr))) :: nil))
                (Sifthenelse (Ebinop One (Etempvar _t'5 tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'17
                          (Efield
                            (Evar _wallCols (Tstruct _WallCollisionData noattr))
                            _x tfloat))
                        (Ssequence
                          (Sset _t'18
                            (Efield
                              (Evar _wallCols (Tstruct _WallCollisionData noattr))
                              _y tfloat))
                          (Ssequence
                            (Sset _t'19
                              (Efield
                                (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                _z tfloat))
                            (Scall (Some _t'1)
                              (Evar _find_floor (Tfunction
                                                  (tfloat :: tfloat ::
                                                   tfloat ::
                                                   (tptr (tptr (Tstruct _Surface noattr))) ::
                                                   nil) tfloat cc_default))
                              ((Etempvar _t'17 tfloat) ::
                               (Etempvar _t'18 tfloat) ::
                               (Etempvar _t'19 tfloat) ::
                               (Eaddrof
                                 (Evar _floor (tptr (Tstruct _Surface noattr)))
                                 (tptr (tptr (Tstruct _Surface noattr)))) ::
                               nil)))))
                      (Sset _floorHeight (Etempvar _t'1 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sset _t'15
                          (Evar _floor (tptr (Tstruct _Surface noattr))))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _t'15 (tptr (Tstruct _Surface noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Sset _t'16
                              (Efield
                                (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                _y tfloat))
                            (Sset _t'4
                              (Ecast
                                (Ebinop Ogt
                                  (Ebinop Osub (Etempvar _t'16 tfloat)
                                    (Etempvar _floorHeight tfloat) tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1126170624)) tfloat)
                                  tint) tbool)))
                          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
                      (Sifthenelse (Etempvar _t'4 tint)
                        (Ssequence
                          (Ssequence
                            (Sset _t'14
                              (Efield
                                (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                _numWalls tshort))
                            (Sset _wall
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                    _walls
                                    (tarray (tptr (Tstruct _Surface noattr)) 4))
                                  (Ebinop Osub (Etempvar _t'14 tshort)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  (tptr (tptr (Tstruct _Surface noattr))))
                                (tptr (Tstruct _Surface noattr)))))
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'12
                                  (Efield
                                    (Efield
                                      (Ederef
                                        (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                        (Tstruct _Surface noattr)) _normal
                                      (Tstruct __670 noattr)) _z tfloat))
                                (Ssequence
                                  (Sset _t'13
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __670 noattr)) _x tfloat))
                                  (Scall (Some _t'2)
                                    (Evar _atan2s (Tfunction
                                                    (tfloat :: tfloat :: nil)
                                                    tshort cc_default))
                                    ((Etempvar _t'12 tfloat) ::
                                     (Etempvar _t'13 tfloat) :: nil))))
                              (Sset _wallAngle
                                (Ecast (Etempvar _t'2 tshort) tshort)))
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
                                      (Econst_int (Int.repr 1) tint)
                                      (tptr tshort)) tshort))
                                (Sset _wallDYaw
                                  (Ecast
                                    (Ebinop Osub (Etempvar _wallAngle tshort)
                                      (Etempvar _t'11 tshort) tint) tshort)))
                              (Ssequence
                                (Sifthenelse (Ebinop Ogt
                                               (Etempvar _wallDYaw tshort)
                                               (Eunop Oneg
                                                 (Econst_int (Int.repr 16384) tint)
                                                 tint) tint)
                                  (Sset _t'3
                                    (Ecast
                                      (Ebinop Olt (Etempvar _wallDYaw tshort)
                                        (Econst_int (Int.repr 16384) tint)
                                        tint) tbool))
                                  (Sset _t'3 (Econst_int (Int.repr 0) tint)))
                                (Sifthenelse (Etempvar _t'3 tint)
                                  (Ssequence
                                    (Ssequence
                                      (Sset _t'9
                                        (Efield
                                          (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                          _x tfloat))
                                      (Ssequence
                                        (Sset _t'10
                                          (Efield
                                            (Efield
                                              (Ederef
                                                (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                                (Tstruct _Surface noattr))
                                              _normal (Tstruct __670 noattr))
                                            _x tfloat))
                                        (Sassign
                                          (Ederef
                                            (Ebinop Oadd
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _pos (tarray tfloat 3))
                                              (Econst_int (Int.repr 0) tint)
                                              (tptr tfloat)) tfloat)
                                          (Ebinop Osub (Etempvar _t'9 tfloat)
                                            (Ebinop Omul
                                              (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                              (Etempvar _t'10 tfloat) tfloat)
                                            tfloat))))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'7
                                          (Efield
                                            (Evar _wallCols (Tstruct _WallCollisionData noattr))
                                            _z tfloat))
                                        (Ssequence
                                          (Sset _t'8
                                            (Efield
                                              (Efield
                                                (Ederef
                                                  (Etempvar _wall (tptr (Tstruct _Surface noattr)))
                                                  (Tstruct _Surface noattr))
                                                _normal
                                                (Tstruct __670 noattr)) _z
                                              tfloat))
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
                                            (Ebinop Osub
                                              (Etempvar _t'7 tfloat)
                                              (Ebinop Omul
                                                (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                                                (Etempvar _t'8 tfloat)
                                                tfloat) tfloat))))
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
                                          (Sassign
                                            (Ederef
                                              (Ebinop Oadd
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _faceAngle
                                                  (tarray tshort 3))
                                                (Econst_int (Int.repr 1) tint)
                                                (tptr tshort)) tshort)
                                            (Ebinop Oadd
                                              (Etempvar _wallAngle tshort)
                                              (Econst_int (Int.repr 32768) tint)
                                              tint))
                                          (Ssequence
                                            (Scall None
                                              (Evar _set_mario_action 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               (Econst_int (Int.repr 1358) tint) ::
                                               (Econst_int (Int.repr 0) tint) ::
                                               nil))
                                            (Scall None
                                              (Evar _set_mario_animation 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: nil) tshort
                                                cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               (Econst_int (Int.repr 28) tint) ::
                                               nil)))))))
                                  Sskip)))))
                        Sskip)))
                  Sskip)))))))
    Sskip))
|}.

Definition f_slide_bonk := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_fastAction, tuint) :: (_slowAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _t'1
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _forwardVel tfloat))
  (Sifthenelse (Ebinop Ogt (Etempvar _t'1 tfloat)
                 (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                 tint)
    (Ssequence
      (Scall None
        (Evar _mario_bonk_reflection (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 1) tint) :: nil))
      (Scall None
        (Evar _drop_and_set_mario_action (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tuint :: tuint :: nil) tint
                                           cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _fastAction tuint) :: (Econst_int (Int.repr 0) tint) ::
         nil)))
    (Ssequence
      (Scall None
        (Evar _mario_set_forward_vel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
      (Scall None
        (Evar _set_mario_action (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tuint :: tuint :: nil) tuint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _slowAction tuint) :: (Econst_int (Int.repr 0) tint) ::
         nil)))))
|}.

Definition f_set_triple_jump_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_action, tuint) :: (_actionArg, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'5, tfloat) :: (_t'4, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _flags tuint))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tuint)
                   (Econst_int (Int.repr 8) tint) tuint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 50333844) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'5 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat)
                       tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 16779394) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 50333824) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))))))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_update_sliding_angle := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_accel, tfloat) :: (_lossFactor, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_newFacingDYaw, tint) :: (_facingDYaw, tshort) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_slopeAngle, tshort) :: (_steepness, tfloat) ::
               (_normalY, tfloat) :: (_t'13, tint) :: (_t'12, tfloat) ::
               (_t'11, tint) :: (_t'10, tint) :: (_t'9, tint) ::
               (_t'8, tint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tshort) ::
               (_t'2, tfloat) :: (_t'1, tshort) :: (_t'42, tfloat) ::
               (_t'41, tfloat) :: (_t'40, tfloat) :: (_t'39, tfloat) ::
               (_t'38, tfloat) :: (_t'37, tfloat) :: (_t'36, tfloat) ::
               (_t'35, tfloat) :: (_t'34, tfloat) :: (_t'33, tfloat) ::
               (_t'32, tfloat) :: (_t'31, tfloat) :: (_t'30, tfloat) ::
               (_t'29, tfloat) :: (_t'28, tshort) :: (_t'27, tshort) ::
               (_t'26, tshort) :: (_t'25, tfloat) :: (_t'24, tfloat) ::
               (_t'23, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tfloat) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tfloat) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _floor
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _floor
      (tptr (Tstruct _Surface noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'41
          (Efield
            (Efield
              (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _z
            tfloat))
        (Ssequence
          (Sset _t'42
            (Efield
              (Efield
                (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr))
              _x tfloat))
          (Scall (Some _t'1)
            (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil) tshort
                            cc_default))
            ((Etempvar _t'41 tfloat) :: (Etempvar _t'42 tfloat) :: nil))))
      (Sset _slopeAngle (Ecast (Etempvar _t'1 tshort) tshort)))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'37
            (Efield
              (Efield
                (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr))
              _x tfloat))
          (Ssequence
            (Sset _t'38
              (Efield
                (Efield
                  (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _normal
                  (Tstruct __670 noattr)) _x tfloat))
            (Ssequence
              (Sset _t'39
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _z tfloat))
              (Ssequence
                (Sset _t'40
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _z tfloat))
                (Scall (Some _t'2)
                  (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
                  ((Ebinop Oadd
                     (Ebinop Omul (Etempvar _t'37 tfloat)
                       (Etempvar _t'38 tfloat) tfloat)
                     (Ebinop Omul (Etempvar _t'39 tfloat)
                       (Etempvar _t'40 tfloat) tfloat) tfloat) :: nil))))))
        (Sset _steepness (Etempvar _t'2 tfloat)))
      (Ssequence
        (Sset _normalY
          (Efield
            (Efield
              (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
            tfloat))
        (Ssequence
          (Ssequence
            (Sset _t'35
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _slideVelX tfloat))
            (Ssequence
              (Sset _t'36
                (Ederef
                  (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                    (Ebinop Oshr
                      (Ecast (Etempvar _slopeAngle tshort) tushort)
                      (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                  tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _slideVelX tfloat)
                (Ebinop Oadd (Etempvar _t'35 tfloat)
                  (Ebinop Omul
                    (Ebinop Omul (Etempvar _accel tfloat)
                      (Etempvar _steepness tfloat) tfloat)
                    (Etempvar _t'36 tfloat) tfloat) tfloat))))
          (Ssequence
            (Ssequence
              (Sset _t'33
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _slideVelZ tfloat))
              (Ssequence
                (Sset _t'34
                  (Ederef
                    (Ebinop Oadd
                      (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                        (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                      (Ebinop Oshr
                        (Ecast (Etempvar _slopeAngle tshort) tushort)
                        (Econst_int (Int.repr 4) tint) tint) (tptr tfloat))
                    tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                  (Ebinop Oadd (Etempvar _t'33 tfloat)
                    (Ebinop Omul
                      (Ebinop Omul (Etempvar _accel tfloat)
                        (Etempvar _steepness tfloat) tfloat)
                      (Etempvar _t'34 tfloat) tfloat) tfloat))))
            (Ssequence
              (Ssequence
                (Sset _t'32
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelX tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _slideVelX tfloat)
                  (Ebinop Omul (Etempvar _t'32 tfloat)
                    (Etempvar _lossFactor tfloat) tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'31
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                    (Ebinop Omul (Etempvar _t'31 tfloat)
                      (Etempvar _lossFactor tfloat) tfloat)))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'29
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                      (Ssequence
                        (Sset _t'30
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat))
                        (Scall (Some _t'3)
                          (Evar _atan2s (Tfunction (tfloat :: tfloat :: nil)
                                          tshort cc_default))
                          ((Etempvar _t'29 tfloat) ::
                           (Etempvar _t'30 tfloat) :: nil))))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideYaw tshort)
                      (Etempvar _t'3 tshort)))
                  (Ssequence
                    (Ssequence
                      (Sset _t'27
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
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideYaw tshort))
                        (Sset _facingDYaw
                          (Ecast
                            (Ebinop Osub (Etempvar _t'27 tshort)
                              (Etempvar _t'28 tshort) tint) tshort))))
                    (Ssequence
                      (Sset _newFacingDYaw (Etempvar _facingDYaw tshort))
                      (Ssequence
                        (Ssequence
                          (Sifthenelse (Ebinop Ogt
                                         (Etempvar _newFacingDYaw tint)
                                         (Econst_int (Int.repr 0) tint) tint)
                            (Sset _t'11
                              (Ecast
                                (Ebinop Ole (Etempvar _newFacingDYaw tint)
                                  (Econst_int (Int.repr 16384) tint) tint)
                                tbool))
                            (Sset _t'11 (Econst_int (Int.repr 0) tint)))
                          (Sifthenelse (Etempvar _t'11 tint)
                            (Ssequence
                              (Ssequence
                                (Sset _t'4
                                  (Ecast
                                    (Ebinop Osub
                                      (Etempvar _newFacingDYaw tint)
                                      (Econst_int (Int.repr 512) tint) tint)
                                    tint))
                                (Sset _newFacingDYaw (Etempvar _t'4 tint)))
                              (Sifthenelse (Ebinop Olt (Etempvar _t'4 tint)
                                             (Econst_int (Int.repr 0) tint)
                                             tint)
                                (Sset _newFacingDYaw
                                  (Econst_int (Int.repr 0) tint))
                                Sskip))
                            (Ssequence
                              (Sifthenelse (Ebinop Ogt
                                             (Etempvar _newFacingDYaw tint)
                                             (Eunop Oneg
                                               (Econst_int (Int.repr 16384) tint)
                                               tint) tint)
                                (Sset _t'10
                                  (Ecast
                                    (Ebinop Olt
                                      (Etempvar _newFacingDYaw tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    tbool))
                                (Sset _t'10 (Econst_int (Int.repr 0) tint)))
                              (Sifthenelse (Etempvar _t'10 tint)
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'5
                                      (Ecast
                                        (Ebinop Oadd
                                          (Etempvar _newFacingDYaw tint)
                                          (Econst_int (Int.repr 512) tint)
                                          tint) tint))
                                    (Sset _newFacingDYaw
                                      (Etempvar _t'5 tint)))
                                  (Sifthenelse (Ebinop Ogt
                                                 (Etempvar _t'5 tint)
                                                 (Econst_int (Int.repr 0) tint)
                                                 tint)
                                    (Sset _newFacingDYaw
                                      (Econst_int (Int.repr 0) tint))
                                    Sskip))
                                (Ssequence
                                  (Sifthenelse (Ebinop Ogt
                                                 (Etempvar _newFacingDYaw tint)
                                                 (Econst_int (Int.repr 16384) tint)
                                                 tint)
                                    (Sset _t'9
                                      (Ecast
                                        (Ebinop Olt
                                          (Etempvar _newFacingDYaw tint)
                                          (Econst_int (Int.repr 32768) tint)
                                          tint) tbool))
                                    (Sset _t'9
                                      (Econst_int (Int.repr 0) tint)))
                                  (Sifthenelse (Etempvar _t'9 tint)
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'6
                                          (Ecast
                                            (Ebinop Oadd
                                              (Etempvar _newFacingDYaw tint)
                                              (Econst_int (Int.repr 512) tint)
                                              tint) tint))
                                        (Sset _newFacingDYaw
                                          (Etempvar _t'6 tint)))
                                      (Sifthenelse (Ebinop Ogt
                                                     (Etempvar _t'6 tint)
                                                     (Econst_int (Int.repr 32768) tint)
                                                     tint)
                                        (Sset _newFacingDYaw
                                          (Econst_int (Int.repr 32768) tint))
                                        Sskip))
                                    (Ssequence
                                      (Sifthenelse (Ebinop Ogt
                                                     (Etempvar _newFacingDYaw tint)
                                                     (Eunop Oneg
                                                       (Econst_int (Int.repr 32768) tint)
                                                       tint) tint)
                                        (Sset _t'8
                                          (Ecast
                                            (Ebinop Olt
                                              (Etempvar _newFacingDYaw tint)
                                              (Eunop Oneg
                                                (Econst_int (Int.repr 16384) tint)
                                                tint) tint) tbool))
                                        (Sset _t'8
                                          (Econst_int (Int.repr 0) tint)))
                                      (Sifthenelse (Etempvar _t'8 tint)
                                        (Ssequence
                                          (Ssequence
                                            (Sset _t'7
                                              (Ecast
                                                (Ebinop Osub
                                                  (Etempvar _newFacingDYaw tint)
                                                  (Econst_int (Int.repr 512) tint)
                                                  tint) tint))
                                            (Sset _newFacingDYaw
                                              (Etempvar _t'7 tint)))
                                          (Sifthenelse (Ebinop Olt
                                                         (Etempvar _t'7 tint)
                                                         (Eunop Oneg
                                                           (Econst_int (Int.repr 32768) tint)
                                                           tint) tint)
                                            (Sset _newFacingDYaw
                                              (Eunop Oneg
                                                (Econst_int (Int.repr 32768) tint)
                                                tint))
                                            Sskip))
                                        Sskip))))))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'26
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideYaw
                                tshort))
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
                              (Ebinop Oadd (Etempvar _t'26 tshort)
                                (Etempvar _newFacingDYaw tint) tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'25
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
                                (Etempvar _t'25 tfloat)))
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
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'24
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _slideVelZ tfloat))
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
                                    (Etempvar _t'24 tfloat)))
                                (Ssequence
                                  (Scall None
                                    (Evar _mario_update_moving_sand (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil)
                                                                    tuint
                                                                    cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Ssequence
                                    (Scall None
                                      (Evar _mario_update_windy_ground 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tuint cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'20
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _slideVelX tfloat))
                                          (Ssequence
                                            (Sset _t'21
                                              (Efield
                                                (Ederef
                                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                  (Tstruct _MarioState noattr))
                                                _slideVelX tfloat))
                                            (Ssequence
                                              (Sset _t'22
                                                (Efield
                                                  (Ederef
                                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                    (Tstruct _MarioState noattr))
                                                  _slideVelZ tfloat))
                                              (Ssequence
                                                (Sset _t'23
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _slideVelZ tfloat))
                                                (Scall (Some _t'12)
                                                  (Evar _sqrtf (Tfunction
                                                                 (tfloat ::
                                                                  nil) tfloat
                                                                 cc_default))
                                                  ((Ebinop Oadd
                                                     (Ebinop Omul
                                                       (Etempvar _t'20 tfloat)
                                                       (Etempvar _t'21 tfloat)
                                                       tfloat)
                                                     (Ebinop Omul
                                                       (Etempvar _t'22 tfloat)
                                                       (Etempvar _t'23 tfloat)
                                                       tfloat) tfloat) ::
                                                   nil))))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _forwardVel tfloat)
                                          (Etempvar _t'12 tfloat)))
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'15
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _forwardVel tfloat))
                                          (Sifthenelse (Ebinop Ogt
                                                         (Etempvar _t'15 tfloat)
                                                         (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                         tint)
                                            (Ssequence
                                              (Ssequence
                                                (Sset _t'18
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _slideVelX tfloat))
                                                (Ssequence
                                                  (Sset _t'19
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
                                                      _slideVelX tfloat)
                                                    (Ebinop Odiv
                                                      (Ebinop Omul
                                                        (Etempvar _t'18 tfloat)
                                                        (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                        tfloat)
                                                      (Etempvar _t'19 tfloat)
                                                      tfloat))))
                                              (Ssequence
                                                (Sset _t'16
                                                  (Efield
                                                    (Ederef
                                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                      (Tstruct _MarioState noattr))
                                                    _slideVelZ tfloat))
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
                                                      _slideVelZ tfloat)
                                                    (Ebinop Odiv
                                                      (Ebinop Omul
                                                        (Etempvar _t'16 tfloat)
                                                        (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                                                        tfloat)
                                                      (Etempvar _t'17 tfloat)
                                                      tfloat)))))
                                            Sskip))
                                        (Ssequence
                                          (Sifthenelse (Ebinop Olt
                                                         (Etempvar _newFacingDYaw tint)
                                                         (Eunop Oneg
                                                           (Econst_int (Int.repr 16384) tint)
                                                           tint) tint)
                                            (Sset _t'13
                                              (Econst_int (Int.repr 1) tint))
                                            (Sset _t'13
                                              (Ecast
                                                (Ebinop Ogt
                                                  (Etempvar _newFacingDYaw tint)
                                                  (Econst_int (Int.repr 16384) tint)
                                                  tint) tbool)))
                                          (Sifthenelse (Etempvar _t'13 tint)
                                            (Ssequence
                                              (Sset _t'14
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
                                                (Ebinop Omul
                                                  (Etempvar _t'14 tfloat)
                                                  (Eunop Oneg
                                                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                                    tfloat) tfloat)))
                                            Sskip))))))))))))))))))))))
|}.

Definition f_update_sliding := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_stopSpeed, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_lossFactor, tfloat) :: (_accel, tfloat) ::
               (_oldSpeed, tfloat) :: (_newSpeed, tfloat) ::
               (_stopped, tint) :: (_intendedDYaw, tshort) ::
               (_forward, tfloat) :: (_sideward, tfloat) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'33, tshort) :: (_t'32, tshort) :: (_t'31, tfloat) ::
               (_t'30, tfloat) :: (_t'29, tfloat) :: (_t'28, tfloat) ::
               (_t'27, tfloat) :: (_t'26, tfloat) :: (_t'25, tfloat) ::
               (_t'24, tfloat) :: (_t'23, tfloat) :: (_t'22, tfloat) ::
               (_t'21, tfloat) :: (_t'20, tfloat) :: (_t'19, tfloat) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _stopped (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Sset _t'32
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _intendedYaw tshort))
      (Ssequence
        (Sset _t'33
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _slideYaw tshort))
        (Sset _intendedDYaw
          (Ecast
            (Ebinop Osub (Etempvar _t'32 tshort) (Etempvar _t'33 tshort)
              tint) tshort))))
    (Ssequence
      (Sset _forward
        (Ederef
          (Ebinop Oadd
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Econst_int (Int.repr 1024) tint) (tptr tfloat))
            (Ebinop Oshr (Ecast (Etempvar _intendedDYaw tshort) tushort)
              (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _sideward
          (Ederef
            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
              (Ebinop Oshr (Ecast (Etempvar _intendedDYaw tshort) tushort)
                (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
        (Ssequence
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _forward tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Ssequence
                (Sset _t'31
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sset _t'1
                  (Ecast
                    (Ebinop Oge (Etempvar _t'31 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                      tint) tbool)))
              (Sset _t'1 (Econst_int (Int.repr 0) tint)))
            (Sifthenelse (Etempvar _t'1 tint)
              (Ssequence
                (Sset _t'30
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sset _forward
                  (Ebinop Omul (Etempvar _forward tfloat)
                    (Ebinop Oadd
                      (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                      (Ebinop Odiv
                        (Ebinop Omul
                          (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                          (Etempvar _t'30 tfloat) tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1120403456)) tfloat)
                        tfloat) tfloat) tfloat)))
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
                    (Sset _accel
                      (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat))
                    (Ssequence
                      (Ssequence
                        (Sset _t'29
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedMag
                            tfloat))
                        (Sset _lossFactor
                          (Ebinop Oadd
                            (Ebinop Omul
                              (Ebinop Omul
                                (Ebinop Odiv (Etempvar _t'29 tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                  tfloat) (Etempvar _forward tfloat) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1017370378)) tfloat)
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065017672)) tfloat)
                            tfloat)))
                      Sbreak))
                  (LScons (Some 20)
                    (Ssequence
                      (Sset _accel
                        (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat))
                      (Ssequence
                        (Ssequence
                          (Sset _t'28
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _intendedMag
                              tfloat))
                          (Sset _lossFactor
                            (Ebinop Oadd
                              (Ebinop Omul
                                (Ebinop Omul
                                  (Ebinop Odiv (Etempvar _t'28 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                    tfloat) (Etempvar _forward tfloat)
                                  tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1017370378)) tfloat)
                                tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1064682127)) tfloat)
                              tfloat)))
                        Sbreak))
                    (LScons None
                      (Ssequence
                        (Sset _accel
                          (Econst_single (Float32.of_bits (Int.repr 1088421888)) tfloat))
                        (Ssequence
                          (Ssequence
                            (Sset _t'27
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _intendedMag
                                tfloat))
                            (Sset _lossFactor
                              (Ebinop Oadd
                                (Ebinop Omul
                                  (Ebinop Omul
                                    (Ebinop Odiv (Etempvar _t'27 tfloat)
                                      (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                      tfloat) (Etempvar _forward tfloat)
                                    tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1017370378)) tfloat)
                                  tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1064011039)) tfloat)
                                tfloat)))
                          Sbreak))
                      (LScons (Some 21)
                        (Ssequence
                          (Sset _accel
                            (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat))
                          (Ssequence
                            (Ssequence
                              (Sset _t'26
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _intendedMag tfloat))
                              (Sset _lossFactor
                                (Ebinop Oadd
                                  (Ebinop Omul
                                    (Ebinop Omul
                                      (Ebinop Odiv (Etempvar _t'26 tfloat)
                                        (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                        tfloat) (Etempvar _forward tfloat)
                                      tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1017370378)) tfloat)
                                    tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1064011039)) tfloat)
                                  tfloat)))
                            Sbreak))
                        LSnil))))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'22
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelX tfloat))
                  (Ssequence
                    (Sset _t'23
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelX tfloat))
                    (Ssequence
                      (Sset _t'24
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                      (Ssequence
                        (Sset _t'25
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelZ
                            tfloat))
                        (Scall (Some _t'3)
                          (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat
                                         cc_default))
                          ((Ebinop Oadd
                             (Ebinop Omul (Etempvar _t'22 tfloat)
                               (Etempvar _t'23 tfloat) tfloat)
                             (Ebinop Omul (Etempvar _t'24 tfloat)
                               (Etempvar _t'25 tfloat) tfloat) tfloat) ::
                           nil))))))
                (Sset _oldSpeed (Etempvar _t'3 tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'19
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _slideVelX tfloat))
                  (Ssequence
                    (Sset _t'20
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                    (Ssequence
                      (Sset _t'21
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _intendedMag
                          tfloat))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelX tfloat)
                        (Ebinop Oadd (Etempvar _t'19 tfloat)
                          (Ebinop Omul
                            (Ebinop Omul
                              (Ebinop Omul (Etempvar _t'20 tfloat)
                                (Ebinop Odiv (Etempvar _t'21 tfloat)
                                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                  tfloat) tfloat) (Etempvar _sideward tfloat)
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1028443341)) tfloat)
                            tfloat) tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'16
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelZ tfloat))
                    (Ssequence
                      (Sset _t'17
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelX tfloat))
                      (Ssequence
                        (Sset _t'18
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedMag
                            tfloat))
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelZ
                            tfloat)
                          (Ebinop Osub (Etempvar _t'16 tfloat)
                            (Ebinop Omul
                              (Ebinop Omul
                                (Ebinop Omul (Etempvar _t'17 tfloat)
                                  (Ebinop Odiv (Etempvar _t'18 tfloat)
                                    (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                                    tfloat) tfloat)
                                (Etempvar _sideward tfloat) tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1028443341)) tfloat)
                              tfloat) tfloat)))))
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _slideVelX
                            tfloat))
                        (Ssequence
                          (Sset _t'13
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _slideVelX
                              tfloat))
                          (Ssequence
                            (Sset _t'14
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _slideVelZ
                                tfloat))
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _slideVelZ
                                  tfloat))
                              (Scall (Some _t'4)
                                (Evar _sqrtf (Tfunction (tfloat :: nil)
                                               tfloat cc_default))
                                ((Ebinop Oadd
                                   (Ebinop Omul (Etempvar _t'12 tfloat)
                                     (Etempvar _t'13 tfloat) tfloat)
                                   (Ebinop Omul (Etempvar _t'14 tfloat)
                                     (Etempvar _t'15 tfloat) tfloat) tfloat) ::
                                 nil))))))
                      (Sset _newSpeed (Etempvar _t'4 tfloat)))
                    (Ssequence
                      (Ssequence
                        (Sifthenelse (Ebinop Ogt (Etempvar _oldSpeed tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                       tint)
                          (Sset _t'5
                            (Ecast
                              (Ebinop Ogt (Etempvar _newSpeed tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                tint) tbool))
                          (Sset _t'5 (Econst_int (Int.repr 0) tint)))
                        (Sifthenelse (Etempvar _t'5 tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'11
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
                                  (Ebinop Omul (Etempvar _t'11 tfloat)
                                    (Etempvar _oldSpeed tfloat) tfloat)
                                  (Etempvar _newSpeed tfloat) tfloat)))
                            (Ssequence
                              (Sset _t'10
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
                                  (Ebinop Omul (Etempvar _t'10 tfloat)
                                    (Etempvar _oldSpeed tfloat) tfloat)
                                  (Etempvar _newSpeed tfloat) tfloat))))
                          Sskip))
                      (Ssequence
                        (Scall None
                          (Evar _update_sliding_angle (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tfloat :: tfloat ::
                                                         nil) tvoid
                                                        cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Etempvar _accel tfloat) ::
                           (Etempvar _lossFactor tfloat) :: nil))
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'6)
                                (Evar _mario_floor_is_slope (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sifthenelse (Eunop Onotbool
                                             (Etempvar _t'6 tint) tint)
                                (Ssequence
                                  (Sset _t'8
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Ssequence
                                    (Sset _t'9
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _forwardVel tfloat))
                                    (Sset _t'7
                                      (Ecast
                                        (Ebinop Olt
                                          (Ebinop Omul (Etempvar _t'8 tfloat)
                                            (Etempvar _t'9 tfloat) tfloat)
                                          (Ebinop Omul
                                            (Etempvar _stopSpeed tfloat)
                                            (Etempvar _stopSpeed tfloat)
                                            tfloat) tint) tbool))))
                                (Sset _t'7 (Econst_int (Int.repr 0) tint))))
                            (Sifthenelse (Etempvar _t'7 tint)
                              (Ssequence
                                (Scall None
                                  (Evar _mario_set_forward_vel (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tfloat ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                                   nil))
                                (Sset _stopped
                                  (Econst_int (Int.repr 1) tint)))
                              Sskip))
                          (Sreturn (Some (Etempvar _stopped tint))))))))))))))))
|}.

Definition f_apply_slope_accel := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_slopeAccel, tfloat) ::
               (_floor, (tptr (Tstruct _Surface noattr))) ::
               (_steepness, tfloat) :: (_normalY, tfloat) ::
               (_floorDYaw, tshort) :: (_slopeClass, tshort) ::
               (_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tfloat) :: (_t'24, tfloat) ::
               (_t'23, tfloat) :: (_t'22, tfloat) :: (_t'21, tfloat) ::
               (_t'20, tshort) :: (_t'19, tshort) :: (_t'18, tuint) ::
               (_t'17, tuint) :: (_t'16, tfloat) :: (_t'15, tfloat) ::
               (_t'14, tshort) :: (_t'13, tfloat) :: (_t'12, tshort) ::
               (_t'11, tfloat) :: (_t'10, tfloat) :: (_t'9, tshort) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _floor
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _floor
      (tptr (Tstruct _Surface noattr))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'21
          (Efield
            (Efield
              (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _x
            tfloat))
        (Ssequence
          (Sset _t'22
            (Efield
              (Efield
                (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr))
              _x tfloat))
          (Ssequence
            (Sset _t'23
              (Efield
                (Efield
                  (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _normal
                  (Tstruct __670 noattr)) _z tfloat))
            (Ssequence
              (Sset _t'24
                (Efield
                  (Efield
                    (Ederef
                      (Etempvar _floor (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _normal
                    (Tstruct __670 noattr)) _z tfloat))
              (Scall (Some _t'1)
                (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
                ((Ebinop Oadd
                   (Ebinop Omul (Etempvar _t'21 tfloat)
                     (Etempvar _t'22 tfloat) tfloat)
                   (Ebinop Omul (Etempvar _t'23 tfloat)
                     (Etempvar _t'24 tfloat) tfloat) tfloat) :: nil))))))
      (Sset _steepness (Etempvar _t'1 tfloat)))
    (Ssequence
      (Sset _normalY
        (Efield
          (Efield
            (Ederef (Etempvar _floor (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
          tfloat))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floorAngle tshort))
          (Ssequence
            (Sset _t'20
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort))
            (Sset _floorDYaw
              (Ecast
                (Ebinop Osub (Etempvar _t'19 tshort) (Etempvar _t'20 tshort)
                  tint) tshort))))
        (Ssequence
          (Ssequence
            (Scall (Some _t'5)
              (Evar _mario_floor_is_slope (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Etempvar _t'5 tint)
              (Ssequence
                (Sset _slopeClass
                  (Ecast (Econst_int (Int.repr 0) tint) tshort))
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'17
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _action tuint))
                      (Sifthenelse (Ebinop One (Etempvar _t'17 tuint)
                                     (Econst_int (Int.repr 132196) tint)
                                     tint)
                        (Ssequence
                          (Sset _t'18
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _action tuint))
                          (Sset _t'3
                            (Ecast
                              (Ebinop One (Etempvar _t'18 tuint)
                                (Econst_int (Int.repr 132197) tint) tint)
                              tbool)))
                        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
                    (Sifthenelse (Etempvar _t'3 tint)
                      (Ssequence
                        (Scall (Some _t'2)
                          (Evar _mario_get_floor_class (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          nil) tint
                                                         cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _slopeClass
                          (Ecast (Etempvar _t'2 tint) tshort)))
                      Sskip))
                  (Ssequence
                    (Sswitch (Etempvar _slopeClass tshort)
                      (LScons (Some 19)
                        (Ssequence
                          (Sset _slopeAccel
                            (Econst_single (Float32.of_bits (Int.repr 1084856730)) tfloat))
                          Sbreak)
                        (LScons (Some 20)
                          (Ssequence
                            (Sset _slopeAccel
                              (Econst_single (Float32.of_bits (Int.repr 1076677837)) tfloat))
                            Sbreak)
                          (LScons None
                            (Ssequence
                              (Sset _slopeAccel
                                (Econst_single (Float32.of_bits (Int.repr 1071225242)) tfloat))
                              Sbreak)
                            (LScons (Some 21)
                              (Ssequence
                                (Sset _slopeAccel
                                  (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                                Sbreak)
                              LSnil)))))
                    (Ssequence
                      (Sifthenelse (Ebinop Ogt (Etempvar _floorDYaw tshort)
                                     (Eunop Oneg
                                       (Econst_int (Int.repr 16384) tint)
                                       tint) tint)
                        (Sset _t'4
                          (Ecast
                            (Ebinop Olt (Etempvar _floorDYaw tshort)
                              (Econst_int (Int.repr 16384) tint) tint) tbool))
                        (Sset _t'4 (Econst_int (Int.repr 0) tint)))
                      (Sifthenelse (Etempvar _t'4 tint)
                        (Ssequence
                          (Sset _t'16
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
                            (Ebinop Oadd (Etempvar _t'16 tfloat)
                              (Ebinop Omul (Etempvar _slopeAccel tfloat)
                                (Etempvar _steepness tfloat) tfloat) tfloat)))
                        (Ssequence
                          (Sset _t'15
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
                            (Ebinop Osub (Etempvar _t'15 tfloat)
                              (Ebinop Omul (Etempvar _slopeAccel tfloat)
                                (Etempvar _steepness tfloat) tfloat) tfloat))))))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _faceAngle
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _slideYaw tshort)
                (Etempvar _t'14 tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
                      (Ederef
                        (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                          (Ebinop Oshr
                            (Ecast (Etempvar _t'12 tshort) tushort)
                            (Econst_int (Int.repr 4) tint) tint)
                          (tptr tfloat)) tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _slideVelX tfloat)
                      (Ebinop Omul (Etempvar _t'11 tfloat)
                        (Etempvar _t'13 tfloat) tfloat)))))
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
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Ssequence
                      (Sset _t'10
                        (Ederef
                          (Ebinop Oadd
                            (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                              (Econst_int (Int.repr 1024) tint)
                              (tptr tfloat))
                            (Ebinop Oshr
                              (Ecast (Etempvar _t'9 tshort) tushort)
                              (Econst_int (Int.repr 4) tint) tint)
                            (tptr tfloat)) tfloat))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _slideVelZ tfloat)
                        (Ebinop Omul (Etempvar _t'8 tfloat)
                          (Etempvar _t'10 tfloat) tfloat)))))
                (Ssequence
                  (Ssequence
                    (Sset _t'7
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
                          (tptr tfloat)) tfloat) (Etempvar _t'7 tfloat)))
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
                        (Sset _t'6
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
                            tfloat) (Etempvar _t'6 tfloat)))
                      (Ssequence
                        (Scall None
                          (Evar _mario_update_moving_sand (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tuint
                                                            cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Scall None
                          (Evar _mario_update_windy_ground (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tuint
                                                             cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))))))))))))))
|}.

Definition f_apply_landing_accel := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_frictionFactor, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_stopped, tint) :: (_t'1, tint) :: (_t'4, tfloat) ::
               (_t'3, tfloat) :: (_t'2, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _stopped (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Scall None
      (Evar _apply_slope_accel (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) :: nil)
                                 tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _mario_floor_is_slope (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Eunop Onotbool (Etempvar _t'1 tint) tint)
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Ebinop Omul (Etempvar _t'4 tfloat)
                  (Etempvar _frictionFactor tfloat) tfloat)))
            (Ssequence
              (Sset _t'2
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Ssequence
                (Sset _t'3
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Olt
                               (Ebinop Omul (Etempvar _t'2 tfloat)
                                 (Etempvar _t'3 tfloat) tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                               tint)
                  (Ssequence
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil))
                    (Sset _stopped (Econst_int (Int.repr 1) tint)))
                  Sskip))))
          Sskip))
      (Sreturn (Some (Etempvar _stopped tint))))))
|}.

Definition f_update_shell_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_maxTargetSpeed, tfloat) :: (_targetSpeed, tfloat) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'23, tshort) ::
               (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _Surface noattr))) ::
               (_t'20, tshort) :: (_t'19, tfloat) :: (_t'18, tshort) ::
               (_t'17, (tptr (Tstruct _Surface noattr))) ::
               (_t'16, (tptr (Tstruct _Surface noattr))) ::
               (_t'15, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) :: (_t'8, tfloat) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tshort) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'19
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floorHeight tfloat))
    (Ssequence
      (Sset _t'20
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'19 tfloat)
                     (Etempvar _t'20 tshort) tint)
        (Ssequence
          (Ssequence
            (Sset _t'23
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _waterLevel tshort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorHeight tfloat)
              (Etempvar _t'23 tshort)))
          (Ssequence
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr)))
              (Eaddrof
                (Evar _gWaterSurfacePseudoFloor (Tstruct _Surface noattr))
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'21
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'22
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _waterLevel tshort))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _t'21 (tptr (Tstruct _Surface noattr)))
                      (Tstruct _Surface noattr)) _originOffset tfloat)
                  (Etempvar _t'22 tshort))))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _floor
            (tptr (Tstruct _Surface noattr))))
        (Sifthenelse (Ebinop One
                       (Etempvar _t'16 (tptr (Tstruct _Surface noattr)))
                       (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                       tint)
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floor
                (tptr (Tstruct _Surface noattr))))
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef (Etempvar _t'17 (tptr (Tstruct _Surface noattr)))
                    (Tstruct _Surface noattr)) _type tshort))
              (Sset _t'1
                (Ecast
                  (Ebinop Oeq (Etempvar _t'18 tshort)
                    (Econst_int (Int.repr 9) tint) tint) tbool))))
          (Sset _t'1 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sset _maxTargetSpeed
          (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
        (Sset _maxTargetSpeed
          (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat))))
    (Ssequence
      (Ssequence
        (Sset _t'15
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Sset _targetSpeed
          (Ebinop Omul (Etempvar _t'15 tfloat)
            (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
            tfloat)))
      (Ssequence
        (Sifthenelse (Ebinop Ogt (Etempvar _targetSpeed tfloat)
                       (Etempvar _maxTargetSpeed tfloat) tint)
          (Sset _targetSpeed (Etempvar _maxTargetSpeed tfloat))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _targetSpeed tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                         tint)
            (Sset _targetSpeed
              (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat))
            Sskip)
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ole (Etempvar _t'7 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                             tint)
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Ebinop Oadd (Etempvar _t'14 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                      tfloat)))
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sifthenelse (Ebinop Ole (Etempvar _t'8 tfloat)
                                 (Etempvar _targetSpeed tfloat) tint)
                    (Ssequence
                      (Sset _t'12
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
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
                          (Ebinop Oadd (Etempvar _t'12 tfloat)
                            (Ebinop Osub
                              (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                              (Ebinop Odiv (Etempvar _t'13 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1114112000)) tfloat)
                                tfloat) tfloat) tfloat))))
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _floor
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'10
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __670 noattr)) _y tfloat))
                        (Sifthenelse (Ebinop Oge (Etempvar _t'10 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat)
                                       tint)
                          (Ssequence
                            (Sset _t'11
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
                              (Ebinop Osub (Etempvar _t'11 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                                tfloat)))
                          Sskip)))))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat)
                               tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1115684864)) tfloat))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'4
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedYaw tshort))
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
                      (Scall (Some _t'2)
                        (Evar _approach_s32 (Tfunction
                                              (tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
                        ((Ecast
                           (Ebinop Osub (Etempvar _t'4 tshort)
                             (Etempvar _t'5 tshort) tint) tshort) ::
                         (Econst_int (Int.repr 0) tint) ::
                         (Econst_int (Int.repr 2048) tint) ::
                         (Econst_int (Int.repr 2048) tint) :: nil))))
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedYaw tshort))
                    (Sassign
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort)
                      (Ebinop Osub (Etempvar _t'3 tshort)
                        (Etempvar _t'2 tint) tint))))
                (Scall None
                  (Evar _apply_slope_accel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))))))))))
|}.

Definition f_apply_slope_decel := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_decelCoef, tfloat) :: nil);
  fn_vars := nil;
  fn_temps := ((_decel, tfloat) :: (_stopped, tint) :: (_t'3, tfloat) ::
               (_t'2, tfloat) :: (_t'1, tint) :: (_t'4, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _stopped (Econst_int (Int.repr 0) tint))
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
            (Sset _decel
              (Ebinop Omul (Etempvar _decelCoef tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1045220557)) tfloat)
                tfloat))
            Sbreak)
          (LScons (Some 20)
            (Ssequence
              (Sset _decel
                (Ebinop Omul (Etempvar _decelCoef tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1060320051)) tfloat)
                  tfloat))
              Sbreak)
            (LScons None
              (Ssequence
                (Sset _decel
                  (Ebinop Omul (Etempvar _decelCoef tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                    tfloat))
                Sbreak)
              (LScons (Some 21)
                (Ssequence
                  (Sset _decel
                    (Ebinop Omul (Etempvar _decelCoef tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                      tfloat))
                  Sbreak)
                LSnil))))))
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'4
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Scall (Some _t'2)
                (Evar _approach_f32 (Tfunction
                                      (tfloat :: tfloat :: tfloat ::
                                       tfloat :: nil) tfloat cc_default))
                ((Etempvar _t'4 tfloat) ::
                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                 (Etempvar _decel tfloat) :: (Etempvar _decel tfloat) :: nil)))
            (Sset _t'3 (Ecast (Etempvar _t'2 tfloat) tfloat)))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat)
            (Etempvar _t'3 tfloat)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                       tint)
          (Sset _stopped (Econst_int (Int.repr 1) tint))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _apply_slope_accel (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _stopped tint)))))))
|}.

Definition f_update_decelerating_speed := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_stopped, tint) :: (_t'2, tfloat) :: (_t'1, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _stopped (Econst_int (Int.repr 0) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Scall (Some _t'1)
              (Evar _approach_f32 (Tfunction
                                    (tfloat :: tfloat :: tfloat :: tfloat ::
                                     nil) tfloat cc_default))
              ((Etempvar _t'4 tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
               (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
               nil)))
          (Sset _t'2 (Ecast (Etempvar _t'1 tfloat) tfloat)))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat)
          (Etempvar _t'2 tfloat)))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'2 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                     tint)
        (Sset _stopped (Econst_int (Int.repr 1) tint))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Scall None
          (Evar _mario_set_forward_vel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _t'3 tfloat) :: nil)))
      (Ssequence
        (Scall None
          (Evar _mario_update_moving_sand (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Scall None
            (Evar _mario_update_windy_ground (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sreturn (Some (Etempvar _stopped tint))))))))
|}.

Definition f_update_walking_speed := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_maxTargetSpeed, tfloat) :: (_targetSpeed, tfloat) ::
               (_t'3, tint) :: (_t'2, tfloat) :: (_t'1, tint) ::
               (_t'22, tshort) ::
               (_t'21, (tptr (Tstruct _Surface noattr))) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, tfloat) :: (_t'18, tfloat) :: (_t'17, tfloat) ::
               (_t'16, tfloat) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tfloat) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, (tptr (Tstruct _Surface noattr))) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tfloat) :: (_t'6, tshort) ::
               (_t'5, tshort) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'20
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _floor
          (tptr (Tstruct _Surface noattr))))
      (Sifthenelse (Ebinop One
                     (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
                     (Ecast (Econst_int (Int.repr 0) tint) (tptr tvoid))
                     tint)
        (Ssequence
          (Sset _t'21
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _floor
              (tptr (Tstruct _Surface noattr))))
          (Ssequence
            (Sset _t'22
              (Efield
                (Ederef (Etempvar _t'21 (tptr (Tstruct _Surface noattr)))
                  (Tstruct _Surface noattr)) _type tshort))
            (Sset _t'1
              (Ecast
                (Ebinop Oeq (Etempvar _t'22 tshort)
                  (Econst_int (Int.repr 9) tint) tint) tbool))))
        (Sset _t'1 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sset _maxTargetSpeed
        (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat))
      (Sset _maxTargetSpeed
        (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat))))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'18
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Sifthenelse (Ebinop Olt (Etempvar _t'18 tfloat)
                       (Etempvar _maxTargetSpeed tfloat) tint)
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedMag tfloat))
            (Sset _t'2 (Ecast (Etempvar _t'19 tfloat) tfloat)))
          (Sset _t'2 (Ecast (Etempvar _maxTargetSpeed tfloat) tfloat))))
      (Sset _targetSpeed (Etempvar _t'2 tfloat)))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'16 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                       tint)
          (Ssequence
            (Sset _t'17
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
            (Sset _targetSpeed
              (Ecast
                (Ebinop Omul (Etempvar _targetSpeed tfloat)
                  (Ebinop Odiv
                    (Econst_float (Float.of_bits (Int64.repr 4618722892845154304)) tdouble)
                    (Etempvar _t'17 tfloat) tdouble) tdouble) tfloat)))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'8
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Ole (Etempvar _t'8 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                         tint)
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Ebinop Oadd (Etempvar _t'15 tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                  tfloat)))
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ole (Etempvar _t'9 tfloat)
                             (Etempvar _targetSpeed tfloat) tint)
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Ssequence
                    (Sset _t'14
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
                        (Ebinop Osub
                          (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat)
                          (Ebinop Odiv (Etempvar _t'14 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1110179840)) tfloat)
                            tfloat) tfloat) tfloat))))
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
                    (Sifthenelse (Ebinop Oge (Etempvar _t'11 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat)
                                   tint)
                      (Ssequence
                        (Sset _t'12
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
                          (Ebinop Osub (Etempvar _t'12 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                            tfloat)))
                      Sskip)))))))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'7 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                           tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
              Sskip))
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'5
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedYaw tshort))
                (Ssequence
                  (Sset _t'6
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _faceAngle
                          (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                        (tptr tshort)) tshort))
                  (Scall (Some _t'3)
                    (Evar _approach_s32 (Tfunction
                                          (tint :: tint :: tint :: tint ::
                                           nil) tint cc_default))
                    ((Ecast
                       (Ebinop Osub (Etempvar _t'5 tshort)
                         (Etempvar _t'6 tshort) tint) tshort) ::
                     (Econst_int (Int.repr 0) tint) ::
                     (Econst_int (Int.repr 2048) tint) ::
                     (Econst_int (Int.repr 2048) tint) :: nil))))
              (Ssequence
                (Sset _t'4
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedYaw tshort))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _faceAngle
                        (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                      (tptr tshort)) tshort)
                  (Ebinop Osub (Etempvar _t'4 tshort) (Etempvar _t'3 tint)
                    tint))))
            (Scall None
              (Evar _apply_slope_accel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))))))))
|}.

Definition f_should_begin_sliding := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_slideLevel, tint) :: (_movingBackward, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'7, tushort) :: (_t'6, (tptr (Tstruct _Area noattr))) ::
               (_t'5, tfloat) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 8) tint) tint)
      (Ssequence
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
                  (Tstruct _Area noattr)) _terrainType tushort))
            (Sset _slideLevel
              (Ebinop Oeq
                (Ebinop Oand (Etempvar _t'7 tushort)
                  (Econst_int (Int.repr 7) tint) tint)
                (Econst_int (Int.repr 6) tint) tint))))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sset _movingBackward
              (Ebinop Ole (Etempvar _t'5 tfloat)
                (Eunop Oneg
                  (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                  tfloat) tint)))
          (Ssequence
            (Ssequence
              (Sifthenelse (Etempvar _slideLevel tint)
                (Sset _t'1 (Econst_int (Int.repr 1) tint))
                (Sset _t'1 (Ecast (Etempvar _movingBackward tint) tbool)))
              (Sifthenelse (Etempvar _t'1 tint)
                (Sset _t'2 (Econst_int (Int.repr 1) tint))
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _mario_facing_downhill (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tint
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sset _t'2 (Ecast (Etempvar _t'3 tint) tbool)))))
            (Sifthenelse (Etempvar _t'2 tint)
              (Sreturn (Some (Econst_int (Int.repr 1) tint)))
              Sskip))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_analog_stick_held_back := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_intendedDYaw, tshort) :: (_t'1, tint) :: (_t'3, tshort) ::
               (_t'2, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'2
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedYaw tshort))
    (Ssequence
      (Sset _t'3
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _intendedDYaw
        (Ecast
          (Ebinop Osub (Etempvar _t'2 tshort) (Etempvar _t'3 tshort) tint)
          tshort))))
  (Ssequence
    (Sifthenelse (Ebinop Olt (Etempvar _intendedDYaw tshort)
                   (Eunop Oneg (Econst_int (Int.repr 18204) tint) tint) tint)
      (Sset _t'1 (Econst_int (Int.repr 1) tint))
      (Sset _t'1
        (Ecast
          (Ebinop Ogt (Etempvar _intendedDYaw tshort)
            (Econst_int (Int.repr 18204) tint) tint) tbool)))
    (Sreturn (Some (Etempvar _t'1 tint)))))
|}.

Definition f_check_ground_dive_or_punch := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_filler, (tarray tuchar 4)) :: nil);
  fn_temps := ((_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'7, tfloat) ::
               (_t'6, (tptr (Tstruct _Controller noattr))) ::
               (_t'5, tfloat) :: (_t'4, tushort) :: nil);
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
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1105723392)) tfloat)
                           tint)
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _controller
                    (tptr (Tstruct _Controller noattr))))
                (Ssequence
                  (Sset _t'7
                    (Efield
                      (Ederef
                        (Etempvar _t'6 (tptr (Tstruct _Controller noattr)))
                        (Tstruct _Controller noattr)) _stickMag tfloat))
                  (Sset _t'2
                    (Ecast
                      (Ebinop Ogt (Etempvar _t'7 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                        tint) tbool))))
              (Sset _t'2 (Econst_int (Int.repr 0) tint))))
          (Sifthenelse (Etempvar _t'2 tint)
            (Ssequence
              (Sassign
                (Ederef
                  (Ebinop Oadd
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                    (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1101004800)) tfloat))
              (Ssequence
                (Scall (Some _t'1)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 25692298) tint) ::
                   (Econst_int (Int.repr 1) tint) :: nil))
                (Sreturn (Some (Etempvar _t'1 tuint)))))
            Sskip))
        (Ssequence
          (Scall (Some _t'3)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 8389719) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'3 tuint)))))
      Sskip))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_begin_braking_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tuint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tuint) :: (_t'9, tuint) :: (_t'8, tushort) ::
               (_t'7, tfloat) :: (_t'6, (tptr (Tstruct _Surface noattr))) ::
               (_t'5, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _mario_drop_held_object (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'8
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort))
      (Sifthenelse (Ebinop Oeq (Etempvar _t'8 tushort)
                     (Econst_int (Int.repr 1) tint) tint)
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionArg tuint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _faceAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                  (tptr tshort)) tshort) (Etempvar _t'9 tuint)))
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521417) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint)))))
        Sskip))
    (Ssequence
      (Ssequence
        (Ssequence
          (Sset _t'5
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                         tint)
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _floor
                  (tptr (Tstruct _Surface noattr))))
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Efield
                      (Ederef
                        (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                        (Tstruct _Surface noattr)) _normal
                      (Tstruct __670 noattr)) _y tfloat))
                (Sset _t'3
                  (Ecast
                    (Ebinop Oge (Etempvar _t'7 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1043452116)) tfloat)
                      tint) tbool))))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 67109957) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Scall (Some _t'4)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 67109962) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'4 tuint)))))))
|}.

Definition f_anim_and_audio_for_walk := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val14, tint) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_val0C, tint) :: (_targetPitch, tshort) ::
               (_val04, tfloat) :: (_t'6, tint) :: (_t'5, tshort) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tfloat) :: (_t'14, tfloat) :: (_t'13, tfloat) ::
               (_t'12, tfloat) :: (_t'11, tfloat) :: (_t'10, tushort) ::
               (_t'9, tfloat) :: (_t'8, tint) :: (_t'7, tint) :: nil);
  fn_body :=
(Ssequence
  (Sset _marioObj
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioObj
      (tptr (Tstruct _Object noattr))))
  (Ssequence
    (Sset _val0C (Econst_int (Int.repr 1) tint))
    (Ssequence
      (Sset _targetPitch (Ecast (Econst_int (Int.repr 0) tint) tshort))
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _intendedMag tfloat))
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'11 tfloat)
                             (Etempvar _t'12 tfloat) tint)
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedMag tfloat))
                  (Sset _t'1 (Ecast (Etempvar _t'14 tfloat) tfloat)))
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sset _t'1 (Ecast (Etempvar _t'13 tfloat) tfloat))))))
          (Sset _val04 (Etempvar _t'1 tfloat)))
        (Ssequence
          (Sifthenelse (Ebinop Olt (Etempvar _val04 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                         tint)
            (Sset _val04
              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat))
            Sskip)
          (Ssequence
            (Ssequence
              (Sset _t'9
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                             tint)
                (Ssequence
                  (Sset _val14
                    (Ecast
                      (Ebinop Omul
                        (Ebinop Odiv (Etempvar _val04 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                          tfloat) (Econst_int (Int.repr 65536) tint) tfloat)
                      tint))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_anim_with_accel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: tint ::
                                                          nil) tshort
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 120) tint) ::
                       (Etempvar _val14 tint) :: nil))
                    (Ssequence
                      (Scall None
                        (Evar _play_step_sound (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tshort :: tshort :: nil)
                                                 tvoid cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 19) tint) ::
                         (Econst_int (Int.repr 93) tint) :: nil))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort) (Econst_int (Int.repr 0) tint)))))
                (Swhile
                  (Etempvar _val0C tint)
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort))
                    (Sswitch (Etempvar _t'10 tushort)
                      (LScons (Some 0)
                        (Ssequence
                          (Sifthenelse (Ebinop Ogt (Etempvar _val04 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                         tint)
                            (Sassign
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _actionTimer
                                tushort) (Econst_int (Int.repr 2) tint))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'2
                                    (Ecast
                                      (Ecast
                                        (Ebinop Omul
                                          (Ebinop Odiv
                                            (Etempvar _val04 tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                            tfloat)
                                          (Econst_int (Int.repr 65536) tint)
                                          tfloat) tint) tint))
                                  (Sset _val14 (Etempvar _t'2 tint)))
                                (Sifthenelse (Ebinop Olt (Etempvar _t'2 tint)
                                               (Econst_int (Int.repr 4096) tint)
                                               tint)
                                  (Sset _val14
                                    (Econst_int (Int.repr 4096) tint))
                                  Sskip))
                              (Ssequence
                                (Scall None
                                  (Evar _set_mario_anim_with_accel (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tint ::
                                                                    tint ::
                                                                    nil)
                                                                    tshort
                                                                    cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 202) tint) ::
                                   (Etempvar _val14 tint) :: nil))
                                (Ssequence
                                  (Scall None
                                    (Evar _play_step_sound (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tshort ::
                                                              tshort :: nil)
                                                             tvoid
                                                             cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 7) tint) ::
                                     (Econst_int (Int.repr 22) tint) :: nil))
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'3)
                                        (Evar _is_anim_past_frame (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tshort ::
                                                                    nil) tint
                                                                    cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 23) tint) ::
                                         nil))
                                      (Sifthenelse (Etempvar _t'3 tint)
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _actionTimer tushort)
                                          (Econst_int (Int.repr 2) tint))
                                        Sskip))
                                    (Sset _val0C
                                      (Econst_int (Int.repr 0) tint)))))))
                          Sbreak)
                        (LScons (Some 1)
                          (Ssequence
                            (Sifthenelse (Ebinop Ogt (Etempvar _val04 tfloat)
                                           (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                           tint)
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _actionTimer tushort)
                                (Econst_int (Int.repr 2) tint))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'4
                                      (Ecast
                                        (Ecast
                                          (Ebinop Omul
                                            (Etempvar _val04 tfloat)
                                            (Econst_int (Int.repr 65536) tint)
                                            tfloat) tint) tint))
                                    (Sset _val14 (Etempvar _t'4 tint)))
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _t'4 tint)
                                                 (Econst_int (Int.repr 4096) tint)
                                                 tint)
                                    (Sset _val14
                                      (Econst_int (Int.repr 4096) tint))
                                    Sskip))
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_anim_with_accel 
                                    (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tint :: tint :: nil) tshort
                                      cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 146) tint) ::
                                     (Etempvar _val14 tint) :: nil))
                                  (Ssequence
                                    (Scall None
                                      (Evar _play_step_sound (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tshort ::
                                                                tshort ::
                                                                nil) tvoid
                                                               cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 14) tint) ::
                                       (Econst_int (Int.repr 72) tint) ::
                                       nil))
                                    (Sset _val0C
                                      (Econst_int (Int.repr 0) tint))))))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Sifthenelse (Ebinop Olt
                                             (Etempvar _val04 tfloat)
                                             (Econst_single (Float32.of_bits (Int.repr 1084227584)) tfloat)
                                             tint)
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _actionTimer tushort)
                                  (Econst_int (Int.repr 1) tint))
                                (Sifthenelse (Ebinop Ogt
                                               (Etempvar _val04 tfloat)
                                               (Econst_single (Float32.of_bits (Int.repr 1102053376)) tfloat)
                                               tint)
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionTimer tushort)
                                    (Econst_int (Int.repr 3) tint))
                                  (Ssequence
                                    (Sset _val14
                                      (Ecast
                                        (Ebinop Omul
                                          (Ebinop Odiv
                                            (Etempvar _val04 tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                            tfloat)
                                          (Econst_int (Int.repr 65536) tint)
                                          tfloat) tint))
                                    (Ssequence
                                      (Scall None
                                        (Evar _set_mario_anim_with_accel 
                                        (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tint :: tint :: nil) tshort
                                          cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 72) tint) ::
                                         (Etempvar _val14 tint) :: nil))
                                      (Ssequence
                                        (Scall None
                                          (Evar _play_step_sound (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           (Econst_int (Int.repr 10) tint) ::
                                           (Econst_int (Int.repr 49) tint) ::
                                           nil))
                                        (Sset _val0C
                                          (Econst_int (Int.repr 0) tint)))))))
                              Sbreak)
                            (LScons (Some 3)
                              (Ssequence
                                (Sifthenelse (Ebinop Olt
                                               (Etempvar _val04 tfloat)
                                               (Econst_single (Float32.of_bits (Int.repr 1099956224)) tfloat)
                                               tint)
                                  (Sassign
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _actionTimer tushort)
                                    (Econst_int (Int.repr 2) tint))
                                  (Ssequence
                                    (Sset _val14
                                      (Ecast
                                        (Ebinop Omul
                                          (Ebinop Odiv
                                            (Etempvar _val04 tfloat)
                                            (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                            tfloat)
                                          (Econst_int (Int.repr 65536) tint)
                                          tfloat) tint))
                                    (Ssequence
                                      (Scall None
                                        (Evar _set_mario_anim_with_accel 
                                        (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tint :: tint :: nil) tshort
                                          cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Econst_int (Int.repr 114) tint) ::
                                         (Etempvar _val14 tint) :: nil))
                                      (Ssequence
                                        (Scall None
                                          (Evar _play_step_sound (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tshort ::
                                                                    tshort ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           (Econst_int (Int.repr 9) tint) ::
                                           (Econst_int (Int.repr 45) tint) ::
                                           nil))
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'5)
                                              (Evar _tilt_body_running 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tshort cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _targetPitch
                                              (Ecast (Etempvar _t'5 tshort)
                                                tshort)))
                                          (Sset _val0C
                                            (Econst_int (Int.repr 0) tint)))))))
                                Sbreak)
                              LSnil)))))))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Ederef
                      (Ebinop Oadd
                        (Efield
                          (Efield
                            (Ederef
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _rawData
                            (Tunion __665 noattr)) _asS32 (tarray tint 80))
                        (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
                  (Scall (Some _t'6)
                    (Evar _approach_s32 (Tfunction
                                          (tint :: tint :: tint :: tint ::
                                           nil) tint cc_default))
                    ((Etempvar _t'8 tint) ::
                     (Etempvar _targetPitch tshort) ::
                     (Econst_int (Int.repr 2048) tint) ::
                     (Econst_int (Int.repr 2048) tint) :: nil)))
                (Sassign
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                            (Tstruct _Object noattr)) _rawData
                          (Tunion __665 noattr)) _asS32 (tarray tint 80))
                      (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
                  (Ecast (Etempvar _t'6 tint) tshort)))
              (Ssequence
                (Sset _t'7
                  (Ederef
                    (Ebinop Oadd
                      (Efield
                        (Efield
                          (Ederef
                            (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
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
                              (Etempvar _marioObj (tptr (Tstruct _Object noattr)))
                              (Tstruct _Object noattr)) _header
                            (Tstruct _ObjectNode noattr)) _gfx
                          (Tstruct _GraphNodeObject noattr)) _angle
                        (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                      (tptr tshort)) tshort) (Etempvar _t'7 tint))))))))))
|}.

Definition f_anim_and_audio_for_hold_walk := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val0C, tint) :: (_val08, tint) :: (_val04, tfloat) ::
               (_t'1, tfloat) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tfloat) :: (_t'3, tfloat) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Sset _val08 (Econst_int (Int.repr 1) tint))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'3
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'3 tfloat)
                         (Etempvar _t'4 tfloat) tint)
            (Ssequence
              (Sset _t'6
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _intendedMag tfloat))
              (Sset _t'1 (Ecast (Etempvar _t'6 tfloat) tfloat)))
            (Ssequence
              (Sset _t'5
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sset _t'1 (Ecast (Etempvar _t'5 tfloat) tfloat))))))
      (Sset _val04 (Etempvar _t'1 tfloat)))
    (Ssequence
      (Sifthenelse (Ebinop Olt (Etempvar _val04 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                     tint)
        (Sset _val04
          (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat))
        Sskip)
      (Swhile
        (Etempvar _val08 tint)
        (Ssequence
          (Sset _t'2
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sswitch (Etempvar _t'2 tushort)
            (LScons (Some 0)
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _val04 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1086324736)) tfloat)
                               tint)
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _actionTimer tushort)
                    (Econst_int (Int.repr 1) tint))
                  (Ssequence
                    (Sset _val0C
                      (Ecast
                        (Ebinop Omul (Etempvar _val04 tfloat)
                          (Econst_int (Int.repr 65536) tint) tfloat) tint))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_anim_with_accel (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: tint ::
                                                            nil) tshort
                                                           cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 24) tint) ::
                         (Etempvar _val0C tint) :: nil))
                      (Ssequence
                        (Scall None
                          (Evar _play_step_sound (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tshort :: tshort :: nil)
                                                   tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 12) tint) ::
                           (Econst_int (Int.repr 62) tint) :: nil))
                        (Sset _val08 (Econst_int (Int.repr 0) tint))))))
                Sbreak)
              (LScons (Some 1)
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _val04 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1077936128)) tfloat)
                                 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionTimer tushort)
                      (Econst_int (Int.repr 0) tint))
                    (Sifthenelse (Ebinop Ogt (Etempvar _val04 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1093664768)) tfloat)
                                   tint)
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort) (Econst_int (Int.repr 2) tint))
                      (Ssequence
                        (Sset _val0C
                          (Ecast
                            (Ebinop Omul (Etempvar _val04 tfloat)
                              (Econst_int (Int.repr 65536) tint) tfloat)
                            tint))
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_anim_with_accel (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tint ::
                                                                tint :: nil)
                                                               tshort
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 22) tint) ::
                             (Etempvar _val0C tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _play_step_sound (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 12) tint) ::
                               (Econst_int (Int.repr 62) tint) :: nil))
                            (Sset _val08 (Econst_int (Int.repr 0) tint)))))))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Sifthenelse (Ebinop Olt (Etempvar _val04 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                                   tint)
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort) (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _val0C
                          (Ecast
                            (Ebinop Omul
                              (Ebinop Odiv (Etempvar _val04 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                                tfloat) (Econst_int (Int.repr 65536) tint)
                              tfloat) tint))
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_anim_with_accel (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tint ::
                                                                tint :: nil)
                                                               tshort
                                                               cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 23) tint) ::
                             (Etempvar _val0C tint) :: nil))
                          (Ssequence
                            (Scall None
                              (Evar _play_step_sound (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 10) tint) ::
                               (Econst_int (Int.repr 49) tint) :: nil))
                            (Sset _val08 (Econst_int (Int.repr 0) tint))))))
                    Sbreak)
                  LSnil)))))))))
|}.

Definition f_anim_and_audio_for_heavy_walk := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val04, tint) :: (_t'1, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'1
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _intendedMag tfloat))
    (Sset _val04
      (Ecast
        (Ebinop Omul (Etempvar _t'1 tfloat)
          (Econst_int (Int.repr 65536) tint) tfloat) tint)))
  (Ssequence
    (Scall None
      (Evar _set_mario_anim_with_accel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: tint :: nil) tshort
                                         cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 187) tint) :: (Etempvar _val04 tint) :: nil))
    (Scall None
      (Evar _play_step_sound (Tfunction
                               ((tptr (Tstruct _MarioState noattr)) ::
                                tshort :: tshort :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 26) tint) :: (Econst_int (Int.repr 79) tint) ::
       nil))))
|}.

Definition f_push_or_sidle_wall := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_startPos, (tptr tfloat)) :: nil);
  fn_vars := nil;
  fn_temps := ((_wallAngle, tshort) :: (_dWallAngle, tshort) ::
               (_dx, tfloat) :: (_dz, tfloat) :: (_movedDistance, tfloat) ::
               (_val04, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tshort) :: (_t'2, tshort) :: (_t'1, tfloat) ::
               (_t'25, tfloat) :: (_t'24, tfloat) :: (_t'23, tfloat) ::
               (_t'22, tfloat) :: (_t'21, tfloat) :: (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tfloat) ::
               (_t'17, (tptr (Tstruct _Surface noattr))) ::
               (_t'16, tshort) ::
               (_t'15, (tptr (Tstruct _Surface noattr))) ::
               (_t'14, (tptr (Tstruct _Surface noattr))) :: (_t'13, tuint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuint) ::
               (_t'10, tuint) :: (_t'9, tshort) ::
               (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, (tptr (Tstruct _Object noattr))) ::
               (_t'6, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'24
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
          (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
    (Ssequence
      (Sset _t'25
        (Ederef
          (Ebinop Oadd (Etempvar _startPos (tptr tfloat))
            (Econst_int (Int.repr 0) tint) (tptr tfloat)) tfloat))
      (Sset _dx
        (Ebinop Osub (Etempvar _t'24 tfloat) (Etempvar _t'25 tfloat) tfloat))))
  (Ssequence
    (Ssequence
      (Sset _t'22
        (Ederef
          (Ebinop Oadd
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _pos (tarray tfloat 3))
            (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
      (Ssequence
        (Sset _t'23
          (Ederef
            (Ebinop Oadd (Etempvar _startPos (tptr tfloat))
              (Econst_int (Int.repr 2) tint) (tptr tfloat)) tfloat))
        (Sset _dz
          (Ebinop Osub (Etempvar _t'22 tfloat) (Etempvar _t'23 tfloat)
            tfloat))))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _sqrtf (Tfunction (tfloat :: nil) tfloat cc_default))
          ((Ebinop Oadd
             (Ebinop Omul (Etempvar _dx tfloat) (Etempvar _dx tfloat) tfloat)
             (Ebinop Omul (Etempvar _dz tfloat) (Etempvar _dz tfloat) tfloat)
             tfloat) :: nil))
        (Sset _movedDistance (Etempvar _t'1 tfloat)))
      (Ssequence
        (Sset _val04
          (Ecast
            (Ebinop Omul
              (Ebinop Omul (Etempvar _movedDistance tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                tfloat) (Econst_int (Int.repr 65536) tint) tfloat) tint))
        (Ssequence
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'21 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1086324736)) tfloat)
                           tint)
              (Scall None
                (Evar _mario_set_forward_vel (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tfloat :: nil) tvoid
                                               cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 1086324736)) tfloat) ::
                 nil))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'15
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _wall
                  (tptr (Tstruct _Surface noattr))))
              (Sifthenelse (Ebinop One
                             (Etempvar _t'15 (tptr (Tstruct _Surface noattr)))
                             (Ecast (Econst_int (Int.repr 0) tint)
                               (tptr tvoid)) tint)
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'17
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _wall
                          (tptr (Tstruct _Surface noattr))))
                      (Ssequence
                        (Sset _t'18
                          (Efield
                            (Efield
                              (Ederef
                                (Etempvar _t'17 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _normal
                              (Tstruct __670 noattr)) _z tfloat))
                        (Ssequence
                          (Sset _t'19
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _wall
                              (tptr (Tstruct _Surface noattr))))
                          (Ssequence
                            (Sset _t'20
                              (Efield
                                (Efield
                                  (Ederef
                                    (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))
                                    (Tstruct _Surface noattr)) _normal
                                  (Tstruct __670 noattr)) _x tfloat))
                            (Scall (Some _t'2)
                              (Evar _atan2s (Tfunction
                                              (tfloat :: tfloat :: nil)
                                              tshort cc_default))
                              ((Etempvar _t'18 tfloat) ::
                               (Etempvar _t'20 tfloat) :: nil))))))
                    (Sset _wallAngle (Ecast (Etempvar _t'2 tshort) tshort)))
                  (Ssequence
                    (Sset _t'16
                      (Ederef
                        (Ebinop Oadd
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _faceAngle
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
                    (Sset _dWallAngle
                      (Ecast
                        (Ebinop Osub (Etempvar _wallAngle tshort)
                          (Etempvar _t'16 tshort) tint) tshort))))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _wall
                      (tptr (Tstruct _Surface noattr))))
                  (Sifthenelse (Ebinop Oeq
                                 (Etempvar _t'14 (tptr (Tstruct _Surface noattr)))
                                 (Ecast (Econst_int (Int.repr 0) tint)
                                   (tptr tvoid)) tint)
                    (Sset _t'4 (Econst_int (Int.repr 1) tint))
                    (Sset _t'4
                      (Ecast
                        (Ebinop Ole (Etempvar _dWallAngle tshort)
                          (Eunop Oneg (Econst_int (Int.repr 29128) tint)
                            tint) tint) tbool))))
                (Sifthenelse (Etempvar _t'4 tint)
                  (Sset _t'5 (Econst_int (Int.repr 1) tint))
                  (Sset _t'5
                    (Ecast
                      (Ebinop Oge (Etempvar _dWallAngle tshort)
                        (Econst_int (Int.repr 29128) tint) tint) tbool))))
              (Sifthenelse (Etempvar _t'5 tint)
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
                      (Ebinop Oor (Etempvar _t'13 tuint)
                        (Econst_int (Int.repr (-2147483648)) tuint) tuint)))
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_animation (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tint :: nil) tshort
                                                   cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 108) tint) :: nil))
                    (Scall None
                      (Evar _play_step_sound (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tshort :: tshort :: nil)
                                               tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 6) tint) ::
                       (Econst_int (Int.repr 18) tint) :: nil))))
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _dWallAngle tshort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Scall None
                      (Evar _set_mario_anim_with_accel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: tint ::
                                                          nil) tshort
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 128) tint) ::
                       (Etempvar _val04 tint) :: nil))
                    (Scall None
                      (Evar _set_mario_anim_with_accel (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: tint ::
                                                          nil) tshort
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 127) tint) ::
                       (Etempvar _val04 tint) :: nil)))
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
                        (Sifthenelse (Ebinop Olt (Etempvar _t'9 tshort)
                                       (Econst_int (Int.repr 20) tint) tint)
                          (Ssequence
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _terrainSoundAddend tuint))
                              (Ssequence
                                (Sset _t'12
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Scall None
                                  (Evar _play_sound (Tfunction
                                                      (tint ::
                                                       (tptr tfloat) :: nil)
                                                      tvoid cc_default))
                                  ((Ebinop Oadd
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
                                                 (Econst_int (Int.repr 0) tint)
                                                 tuint)
                                               (Econst_int (Int.repr 16) tint)
                                               tuint) tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               tuint)
                                             (Econst_int (Int.repr 8) tint)
                                             tuint) tuint)
                                         (Econst_int (Int.repr 67108864) tint)
                                         tuint)
                                       (Econst_int (Int.repr 1) tint) tuint)
                                     (Etempvar _t'11 tuint) tuint) ::
                                   (Efield
                                     (Efield
                                       (Efield
                                         (Ederef
                                           (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                           (Tstruct _Object noattr)) _header
                                         (Tstruct _ObjectNode noattr)) _gfx
                                       (Tstruct _GraphNodeObject noattr))
                                     _cameraToObject (tarray tfloat 3)) ::
                                   nil))))
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
                                    (Econst_int (Int.repr 0) tint) tint)
                                  tuint))))
                          Sskip)))
                    (Ssequence
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionState
                          tushort) (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sassign
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _actionArg tuint)
                          (Ebinop Oadd (Etempvar _wallAngle tshort)
                            (Econst_int (Int.repr 32768) tint) tint))
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
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'7 (tptr (Tstruct _Object noattr)))
                                          (Tstruct _Object noattr)) _header
                                        (Tstruct _ObjectNode noattr)) _gfx
                                      (Tstruct _GraphNodeObject noattr))
                                    _angle (tarray tshort 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tshort)) tshort)
                              (Ebinop Oadd (Etempvar _wallAngle tshort)
                                (Econst_int (Int.repr 32768) tint) tint)))
                          (Ssequence
                            (Scall (Some _t'3)
                              (Evar _find_floor_slope (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tshort :: nil)
                                                        tshort cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 16384) tint) :: nil))
                            (Ssequence
                              (Sset _t'6
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
                                            (Etempvar _t'6 (tptr (Tstruct _Object noattr)))
                                            (Tstruct _Object noattr)) _header
                                          (Tstruct _ObjectNode noattr)) _gfx
                                        (Tstruct _GraphNodeObject noattr))
                                      _angle (tarray tshort 3))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tshort)) tshort)
                                (Etempvar _t'3 tshort)))))))))))))))))
|}.

Definition f_tilt_body_walking := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_startYaw, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_val0C, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_animID, tshort) :: (_dYaw, tshort) :: (_val02, tshort) ::
               (_val00, tshort) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tshort) ::
               (_t'7, tfloat) :: (_t'6, tfloat) :: (_t'5, tshort) ::
               (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sset _val0C
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioBodyState
      (tptr (Tstruct _MarioBodyState noattr))))
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
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'10
            (Efield
              (Efield
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _header
                    (Tstruct _ObjectNode noattr)) _gfx
                  (Tstruct _GraphNodeObject noattr)) _animInfo
                (Tstruct _AnimInfo noattr)) _animID tshort))
          (Sset _animID (Ecast (Etempvar _t'10 tshort) tshort))))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _animID tshort)
                       (Econst_int (Int.repr 72) tint) tint)
          (Sset _t'3 (Econst_int (Int.repr 1) tint))
          (Sset _t'3
            (Ecast
              (Ebinop Oeq (Etempvar _animID tshort)
                (Econst_int (Int.repr 114) tint) tint) tbool)))
        (Sifthenelse (Etempvar _t'3 tint)
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
              (Sset _dYaw
                (Ecast
                  (Ebinop Osub (Etempvar _t'8 tshort)
                    (Etempvar _startYaw tshort) tint) tshort)))
            (Ssequence
              (Ssequence
                (Sset _t'7
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sset _val02
                  (Ecast
                    (Eunop Oneg
                      (Ecast
                        (Ebinop Odiv
                          (Ebinop Omul (Etempvar _dYaw tshort)
                            (Etempvar _t'7 tfloat) tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat)
                          tfloat) tshort) tint) tshort)))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Sset _val00
                    (Ecast
                      (Ecast
                        (Ebinop Omul (Etempvar _t'6 tfloat)
                          (Econst_single (Float32.of_bits (Int.repr 1126825984)) tfloat)
                          tfloat) tshort) tshort)))
                (Ssequence
                  (Sifthenelse (Ebinop Ogt (Etempvar _val02 tshort)
                                 (Econst_int (Int.repr 5461) tint) tint)
                    (Sset _val02
                      (Ecast (Econst_int (Int.repr 5461) tint) tshort))
                    Sskip)
                  (Ssequence
                    (Sifthenelse (Ebinop Olt (Etempvar _val02 tshort)
                                   (Eunop Oneg
                                     (Econst_int (Int.repr 5461) tint) tint)
                                   tint)
                      (Sset _val02
                        (Ecast
                          (Eunop Oneg (Econst_int (Int.repr 5461) tint) tint)
                          tshort))
                      Sskip)
                    (Ssequence
                      (Sifthenelse (Ebinop Ogt (Etempvar _val00 tshort)
                                     (Econst_int (Int.repr 5461) tint) tint)
                        (Sset _val00
                          (Ecast (Econst_int (Int.repr 5461) tint) tshort))
                        Sskip)
                      (Ssequence
                        (Sifthenelse (Ebinop Olt (Etempvar _val00 tshort)
                                       (Econst_int (Int.repr 0) tint) tint)
                          (Sset _val00
                            (Ecast (Econst_int (Int.repr 0) tint) tshort))
                          Sskip)
                        (Ssequence
                          (Ssequence
                            (Ssequence
                              (Sset _t'5
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                        (Tstruct _MarioBodyState noattr))
                                      _torsoAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 2) tint)
                                    (tptr tshort)) tshort))
                              (Scall (Some _t'1)
                                (Evar _approach_s32 (Tfunction
                                                      (tint :: tint ::
                                                       tint :: tint :: nil)
                                                      tint cc_default))
                                ((Etempvar _t'5 tshort) ::
                                 (Etempvar _val02 tshort) ::
                                 (Econst_int (Int.repr 1024) tint) ::
                                 (Econst_int (Int.repr 1024) tint) :: nil)))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                      (Tstruct _MarioBodyState noattr))
                                    _torsoAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'1 tint)))
                          (Ssequence
                            (Ssequence
                              (Sset _t'4
                                (Ederef
                                  (Ebinop Oadd
                                    (Efield
                                      (Ederef
                                        (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                        (Tstruct _MarioBodyState noattr))
                                      _torsoAngle (tarray tshort 3))
                                    (Econst_int (Int.repr 0) tint)
                                    (tptr tshort)) tshort))
                              (Scall (Some _t'2)
                                (Evar _approach_s32 (Tfunction
                                                      (tint :: tint ::
                                                       tint :: tint :: nil)
                                                      tint cc_default))
                                ((Etempvar _t'4 tshort) ::
                                 (Etempvar _val00 tshort) ::
                                 (Econst_int (Int.repr 1024) tint) ::
                                 (Econst_int (Int.repr 1024) tint) :: nil)))
                            (Sassign
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                      (Tstruct _MarioBodyState noattr))
                                    _torsoAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 0) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'2 tint)))))))))))
          (Ssequence
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _torsoAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                  (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint))
            (Sassign
              (Ederef
                (Ebinop Oadd
                  (Efield
                    (Ederef
                      (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                      (Tstruct _MarioBodyState noattr)) _torsoAngle
                    (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                  (tptr tshort)) tshort) (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_tilt_body_ground_shell := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_startYaw, tshort) :: nil);
  fn_vars := nil;
  fn_temps := ((_val0C, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_marioObj, (tptr (Tstruct _Object noattr))) ::
               (_dYaw, tshort) :: (_val04, tshort) :: (_val02, tshort) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'10, tshort) ::
               (_t'9, tfloat) :: (_t'8, tfloat) :: (_t'7, tshort) ::
               (_t'6, tshort) :: (_t'5, tshort) :: (_t'4, tshort) ::
               (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Sset _val0C
    (Efield
      (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
        (Tstruct _MarioState noattr)) _marioBodyState
      (tptr (Tstruct _MarioBodyState noattr))))
  (Ssequence
    (Sset _marioObj
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _marioObj
        (tptr (Tstruct _Object noattr))))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Ederef
            (Ebinop Oadd
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
              (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
        (Sset _dYaw
          (Ecast
            (Ebinop Osub (Etempvar _t'10 tshort) (Etempvar _startYaw tshort)
              tint) tshort)))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sset _val04
            (Ecast
              (Eunop Oneg
                (Ecast
                  (Ebinop Odiv
                    (Ebinop Omul (Etempvar _dYaw tshort)
                      (Etempvar _t'9 tfloat) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1094713344)) tfloat)
                    tfloat) tshort) tint) tshort)))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sset _val02
              (Ecast
                (Ecast
                  (Ebinop Omul (Etempvar _t'8 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1126825984)) tfloat)
                    tfloat) tshort) tshort)))
          (Ssequence
            (Sifthenelse (Ebinop Ogt (Etempvar _val04 tshort)
                           (Econst_int (Int.repr 6144) tint) tint)
              (Sset _val04 (Ecast (Econst_int (Int.repr 6144) tint) tshort))
              Sskip)
            (Ssequence
              (Sifthenelse (Ebinop Olt (Etempvar _val04 tshort)
                             (Eunop Oneg (Econst_int (Int.repr 6144) tint)
                               tint) tint)
                (Sset _val04
                  (Ecast (Eunop Oneg (Econst_int (Int.repr 6144) tint) tint)
                    tshort))
                Sskip)
              (Ssequence
                (Sifthenelse (Ebinop Ogt (Etempvar _val02 tshort)
                               (Econst_int (Int.repr 4096) tint) tint)
                  (Sset _val02
                    (Ecast (Econst_int (Int.repr 4096) tint) tshort))
                  Sskip)
                (Ssequence
                  (Sifthenelse (Ebinop Olt (Etempvar _val02 tshort)
                                 (Econst_int (Int.repr 0) tint) tint)
                    (Sset _val02
                      (Ecast (Econst_int (Int.repr 0) tint) tshort))
                    Sskip)
                  (Ssequence
                    (Ssequence
                      (Ssequence
                        (Sset _t'7
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _torsoAngle (tarray tshort 3))
                              (Econst_int (Int.repr 2) tint) (tptr tshort))
                            tshort))
                        (Scall (Some _t'1)
                          (Evar _approach_s32 (Tfunction
                                                (tint :: tint :: tint ::
                                                 tint :: nil) tint
                                                cc_default))
                          ((Etempvar _t'7 tshort) ::
                           (Etempvar _val04 tshort) ::
                           (Econst_int (Int.repr 512) tint) ::
                           (Econst_int (Int.repr 512) tint) :: nil)))
                      (Sassign
                        (Ederef
                          (Ebinop Oadd
                            (Efield
                              (Ederef
                                (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                (Tstruct _MarioBodyState noattr)) _torsoAngle
                              (tarray tshort 3))
                            (Econst_int (Int.repr 2) tint) (tptr tshort))
                          tshort) (Etempvar _t'1 tint)))
                    (Ssequence
                      (Ssequence
                        (Ssequence
                          (Sset _t'6
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _torsoAngle (tarray tshort 3))
                                (Econst_int (Int.repr 0) tint) (tptr tshort))
                              tshort))
                          (Scall (Some _t'2)
                            (Evar _approach_s32 (Tfunction
                                                  (tint :: tint :: tint ::
                                                   tint :: nil) tint
                                                  cc_default))
                            ((Etempvar _t'6 tshort) ::
                             (Etempvar _val02 tshort) ::
                             (Econst_int (Int.repr 512) tint) ::
                             (Econst_int (Int.repr 512) tint) :: nil)))
                        (Sassign
                          (Ederef
                            (Ebinop Oadd
                              (Efield
                                (Ederef
                                  (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                  (Tstruct _MarioBodyState noattr))
                                _torsoAngle (tarray tshort 3))
                              (Econst_int (Int.repr 0) tint) (tptr tshort))
                            tshort) (Etempvar _t'2 tint)))
                      (Ssequence
                        (Ssequence
                          (Sset _t'5
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _torsoAngle (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort))
                          (Sassign
                            (Ederef
                              (Ebinop Oadd
                                (Efield
                                  (Ederef
                                    (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                    (Tstruct _MarioBodyState noattr))
                                  _headAngle (tarray tshort 3))
                                (Econst_int (Int.repr 2) tint) (tptr tshort))
                              tshort)
                            (Eunop Oneg (Etempvar _t'5 tshort) tint)))
                        (Ssequence
                          (Ssequence
                            (Sset _t'4
                              (Ederef
                                (Ebinop Oadd
                                  (Efield
                                    (Ederef
                                      (Etempvar _val0C (tptr (Tstruct _MarioBodyState noattr)))
                                      (Tstruct _MarioBodyState noattr))
                                    _torsoAngle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
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
                                      (Tstruct _GraphNodeObject noattr))
                                    _angle (tarray tshort 3))
                                  (Econst_int (Int.repr 2) tint)
                                  (tptr tshort)) tshort)
                              (Etempvar _t'4 tshort)))
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
                                      (Tstruct _GraphNodeObject noattr)) _pos
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat))
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
                                    (tarray tfloat 3))
                                  (Econst_int (Int.repr 1) tint)
                                  (tptr tfloat)) tfloat)
                              (Ebinop Oadd (Etempvar _t'3 tfloat)
                                (Econst_single (Float32.of_bits (Int.repr 1110704128)) tfloat)
                                tfloat))))))))))))))))
|}.

Definition f_act_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := ((_startPos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_startYaw, tshort) :: (_t'11, tint) :: (_t'10, tuint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tuint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'20, tshort) :: (_t'19, tushort) :: (_t'18, tushort) ::
               (_t'17, tushort) :: (_t'16, tfloat) :: (_t'15, tushort) ::
               (_t'14, tuint) :: (_t'13, tfloat) :: (_t'12, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Sset _startYaw (Ecast (Etempvar _t'20 tshort) tshort)))
  (Ssequence
    (Scall None
      (Evar _mario_drop_held_object (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'2)
          (Evar _should_begin_sliding (Tfunction
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
               (Econst_int (Int.repr 80) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'19 tushort)
                         (Econst_int (Int.repr 16) tint) tint)
            (Ssequence
              (Scall (Some _t'3)
                (Evar _begin_braking_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Etempvar _t'3 tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'18
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _set_jump_from_landing (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sreturn (Some (Etempvar _t'4 tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Scall (Some _t'5)
                (Evar _check_ground_dive_or_punch (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'5 tint)
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                               (Econst_int (Int.repr 32) tint) tint)
                  (Ssequence
                    (Scall (Some _t'6)
                      (Evar _begin_braking_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sreturn (Some (Etempvar _t'6 tint))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'8)
                      (Evar _analog_stick_held_back (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'8 tint)
                      (Ssequence
                        (Sset _t'16
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sset _t'9
                          (Ecast
                            (Ebinop Oge (Etempvar _t'16 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                              tint) tbool)))
                      (Sset _t'9 (Econst_int (Int.repr 0) tint))))
                  (Sifthenelse (Etempvar _t'9 tint)
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 1091) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'7 tuint))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'15
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _input tushort))
                    (Sifthenelse (Ebinop Oand (Etempvar _t'15 tushort)
                                   (Econst_int (Int.repr 32768) tint) tint)
                      (Ssequence
                        (Scall (Some _t'10)
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 75531353) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        (Sreturn (Some (Etempvar _t'10 tuint))))
                      Sskip))
                  (Ssequence
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _actionState tushort)
                      (Econst_int (Int.repr 0) tint))
                    (Ssequence
                      (Scall None
                        (Evar _vec3f_copy (Tfunction
                                            ((tptr tfloat) ::
                                             (tptr tfloat) :: nil)
                                            (tptr tvoid) cc_default))
                        ((Evar _startPos (tarray tfloat 3)) ::
                         (Efield
                           (Ederef
                             (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                             (Tstruct _MarioState noattr)) _pos
                           (tarray tfloat 3)) :: nil))
                      (Ssequence
                        (Scall None
                          (Evar _update_walking_speed (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tvoid
                                                        cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'11)
                              (Evar _perform_ground_step (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            nil) tint
                                                           cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sswitch (Etempvar _t'11 tint)
                              (LScons (Some 0)
                                (Ssequence
                                  (Scall None
                                    (Evar _set_mario_action (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               tuint ::
                                                               tuint :: nil)
                                                              tuint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_int (Int.repr 16779404) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil))
                                  (Ssequence
                                    (Scall None
                                      (Evar _set_mario_animation (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tint ::
                                                                    nil)
                                                                   tshort
                                                                   cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 86) tint) ::
                                       nil))
                                    Sbreak))
                                (LScons (Some 1)
                                  (Ssequence
                                    (Scall None
                                      (Evar _anim_and_audio_for_walk 
                                      (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Ssequence
                                      (Ssequence
                                        (Sset _t'12
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _intendedMag tfloat))
                                        (Ssequence
                                          (Sset _t'13
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _forwardVel tfloat))
                                          (Sifthenelse (Ebinop Ogt
                                                         (Ebinop Osub
                                                           (Etempvar _t'12 tfloat)
                                                           (Etempvar _t'13 tfloat)
                                                           tfloat)
                                                         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                                         tint)
                                            (Ssequence
                                              (Sset _t'14
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
                                                  (Etempvar _t'14 tuint)
                                                  (Ebinop Oshl
                                                    (Econst_int (Int.repr 1) tint)
                                                    (Econst_int (Int.repr 0) tint)
                                                    tint) tuint)))
                                            Sskip)))
                                      Sbreak))
                                  (LScons (Some 2)
                                    (Ssequence
                                      (Scall None
                                        (Evar _push_or_sidle_wall (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    (tptr tfloat) ::
                                                                    nil)
                                                                    tvoid
                                                                    cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         (Evar _startPos (tarray tfloat 3)) ::
                                         nil))
                                      (Ssequence
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _actionTimer tushort)
                                          (Econst_int (Int.repr 0) tint))
                                        Sbreak))
                                    LSnil)))))
                          (Ssequence
                            (Scall None
                              (Evar _check_ledge_climb_down (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Ssequence
                              (Scall None
                                (Evar _tilt_body_walking (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tshort :: nil)
                                                           tvoid cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Etempvar _startYaw tshort) :: nil))
                              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))))
|}.

Definition f_act_move_punching := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tfloat) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'11, tushort) :: (_t'10, tushort) :: (_t'9, tfloat) ::
               (_t'8, tfloat) :: (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'2)
      (Evar _should_begin_sliding (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 80) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionState tushort))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 0) tint) tint)
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sset _t'4
              (Ecast
                (Ebinop Oand (Etempvar _t'11 tushort)
                  (Econst_int (Int.repr 128) tint) tint) tbool)))
          (Sset _t'4 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 25168044) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'3 tuint))))
        Sskip))
    (Ssequence
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionState tushort)
        (Econst_int (Int.repr 1) tint))
      (Ssequence
        (Scall None
          (Evar _mario_update_punch_sequence (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Oge (Etempvar _t'8 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Scall None
                (Evar _apply_slope_decel (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tfloat :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat) ::
                 nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _forwardVel tfloat))
                      (Sset _t'5
                        (Ecast
                          (Ebinop Oadd (Etempvar _t'9 tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                            tfloat) tfloat)))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Etempvar _t'5 tfloat)))
                  (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                 tint)
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))
                    Sskip))
                (Scall None
                  (Evar _apply_slope_accel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil)))))
          (Ssequence
            (Ssequence
              (Scall (Some _t'6)
                (Evar _perform_ground_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sswitch (Etempvar _t'6 tint)
                (LScons (Some 0)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16779404) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 1)
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
                              (Econst_int (Int.repr 0) tint) tint) tuint)))
                      Sbreak)
                    LSnil))))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_act_hold_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'10, tint) :: (_t'9, tint) :: (_t'8, tuint) ::
               (_t'7, tint) :: (_t'6, tuint) :: (_t'5, tint) ::
               (_t'4, tuint) :: (_t'3, tint) :: (_t'2, (tptr tvoid)) ::
               (_t'1, tuint) :: (_t'23, (tptr tuint)) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tint) ::
               (_t'20, (tptr (Tstruct _Object noattr))) ::
               (_t'19, tushort) :: (_t'18, tushort) :: (_t'17, tushort) ::
               (_t'16, tushort) :: (_t'15, tfloat) :: (_t'14, tfloat) ::
               (_t'13, tuint) :: (_t'12, tfloat) :: (_t'11, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'2)
      (Evar _segmented_to_virtual (Tfunction ((tptr tvoid) :: nil)
                                    (tptr tvoid) cc_default))
      ((Evar _bhvJumpingBox (tarray tuint 0)) :: nil))
    (Ssequence
      (Sset _t'22
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _heldObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'23
          (Efield
            (Ederef (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
              (Tstruct _Object noattr)) _behavior (tptr tuint)))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'23 (tptr tuint))
                       (Etempvar _t'2 (tptr tvoid)) tint)
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
      (Sset _t'20
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'21
          (Ederef
            (Ebinop Oadd
              (Efield
                (Efield
                  (Ederef (Etempvar _t'20 (tptr (Tstruct _Object noattr)))
                    (Tstruct _Object noattr)) _rawData (Tunion __665 noattr))
                _asS32 (tarray tint 80)) (Econst_int (Int.repr 43) tint)
              (tptr tint)) tint))
        (Sifthenelse (Ebinop Oand (Etempvar _t'21 tint)
                       (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                         (Econst_int (Int.repr 3) tint) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 67109952) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'5)
          (Evar _should_begin_sliding (Tfunction
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
               (Econst_int (Int.repr 81) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'19
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'19 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'6)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr (-2147482232)) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'6 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'18
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Scall (Some _t'7)
                  (Evar _set_jumping_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tint
                                              cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 50333856) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'7 tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'17
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                             (Econst_int (Int.repr 32) tint) tint)
                (Ssequence
                  (Scall (Some _t'8)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 1099) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'8 tuint))))
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
                    (Scall (Some _t'9)
                      (Evar _drop_and_set_mario_action (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tuint :: tuint ::
                                                          nil) tint
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 75531353) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'9 tint))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'15
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedMag tfloat))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _intendedMag tfloat)
                    (Ebinop Omul (Etempvar _t'15 tfloat)
                      (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                      tfloat)))
                (Ssequence
                  (Scall None
                    (Evar _update_walking_speed (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'10)
                        (Evar _perform_ground_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sswitch (Etempvar _t'10 tint)
                        (LScons (Some 0)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 16779425) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Ssequence
                                (Sset _t'14
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr))
                                    _forwardVel tfloat))
                                (Sifthenelse (Ebinop Ogt
                                               (Etempvar _t'14 tfloat)
                                               (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                               tint)
                                  (Scall None
                                    (Evar _mario_set_forward_vel (Tfunction
                                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                                    tfloat ::
                                                                    nil)
                                                                   tvoid
                                                                   cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat) ::
                                     nil))
                                  Sskip))
                              Sbreak)
                            LSnil))))
                    (Ssequence
                      (Scall None
                        (Evar _anim_and_audio_for_hold_walk (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tvoid
                                                              cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Ssequence
                        (Ssequence
                          (Sset _t'11
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _intendedMag
                              tfloat))
                          (Ssequence
                            (Sset _t'12
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat))
                            (Sifthenelse (Ebinop Ogt
                                           (Ebinop Osub
                                             (Ebinop Omul
                                               (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                                               (Etempvar _t'11 tfloat)
                                               tfloat)
                                             (Etempvar _t'12 tfloat) tfloat)
                                           (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                           tint)
                              (Ssequence
                                (Sset _t'13
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
                                  (Ebinop Oor (Etempvar _t'13 tuint)
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    tuint)))
                              Sskip)))
                        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))
|}.

Definition f_act_hold_heavy_walking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'9, tushort) ::
               (_t'8, tushort) :: (_t'7, tfloat) :: (_t'6, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 8192) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr (-2147482231)) tuint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'3)
        (Evar _should_begin_sliding (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 80) tint) ::
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
                       (Econst_int (Int.repr 32) tint) tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 134218248) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedMag tfloat))
          (Sassign
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _intendedMag tfloat)
            (Ebinop Omul (Etempvar _t'7 tfloat)
              (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat)
              tfloat)))
        (Ssequence
          (Scall None
            (Evar _update_walking_speed (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           nil) tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Ssequence
            (Ssequence
              (Scall (Some _t'5)
                (Evar _perform_ground_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sswitch (Etempvar _t'5 tint)
                (LScons (Some 0)
                  (Ssequence
                    (Scall None
                      (Evar _drop_and_set_mario_action (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tuint :: tuint ::
                                                          nil) tint
                                                         cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 16779404) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Ssequence
                        (Sset _t'6
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sifthenelse (Ebinop Ogt (Etempvar _t'6 tfloat)
                                       (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                       tint)
                          (Scall None
                            (Evar _mario_set_forward_vel (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tfloat :: nil)
                                                           tvoid cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
                             nil))
                          Sskip))
                      Sbreak)
                    LSnil))))
            (Ssequence
              (Scall None
                (Evar _anim_and_audio_for_heavy_walk (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tvoid
                                                       cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_turning_around := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'9, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tuint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'18, tushort) :: (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tuint) ::
               (_t'13, tuint) :: (_t'12, tfloat) :: (_t'11, tfloat) ::
               (_t'10, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                   (Econst_int (Int.repr 8) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 80) tint) ::
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
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_jumping_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tint
                                        cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779399) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'16
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                       (Econst_int (Int.repr 32) tint) tint)
          (Ssequence
            (Scall (Some _t'3)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 67109957) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _analog_stick_held_back (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Eunop Onotbool (Etempvar _t'5 tint) tint)
            (Ssequence
              (Scall (Some _t'4)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 67109952) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'7)
              (Evar _apply_slope_decel (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tfloat :: nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
               nil))
            (Sifthenelse (Etempvar _t'7 tint)
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _begin_walking_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tfloat :: tuint :: tuint ::
                                                 nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat) ::
                   (Econst_int (Int.repr 1092) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'6 tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
              (Ssequence
                (Sset _t'15
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
                               (Ecast (Econst_int (Int.repr 1) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 67108864) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint)
                     (Etempvar _t'14 tuint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil))))
            (Ssequence
              (Scall None
                (Evar _adjust_sound_for_speed (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'8)
                    (Evar _perform_ground_step (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sswitch (Etempvar _t'8 tint)
                    (LScons (Some 0)
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 16779404) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak)
                      (LScons (Some 1)
                        (Ssequence
                          (Ssequence
                            (Sset _t'13
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
                              (Ebinop Oor (Etempvar _t'13 tuint)
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 0) tint) tint) tuint)))
                          Sbreak)
                        LSnil))))
                (Ssequence
                  (Ssequence
                    (Sset _t'10
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'10 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 1099956224)) tfloat)
                                   tint)
                      (Scall None
                        (Evar _set_mario_animation (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: nil) tshort
                                                     cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 188) tint) :: nil))
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_animation (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tint :: nil) tshort
                                                       cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 189) tint) :: nil))
                        (Ssequence
                          (Scall (Some _t'9)
                            (Evar _is_anim_at_end (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sifthenelse (Etempvar _t'9 tint)
                            (Ssequence
                              (Sset _t'11
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr)) _forwardVel
                                  tfloat))
                              (Sifthenelse (Ebinop Ogt
                                             (Etempvar _t'11 tfloat)
                                             (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                             tint)
                                (Ssequence
                                  (Sset _t'12
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _forwardVel tfloat))
                                  (Scall None
                                    (Evar _begin_walking_action (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   tfloat ::
                                                                   tuint ::
                                                                   tuint ::
                                                                   nil) tint
                                                                  cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     (Eunop Oneg (Etempvar _t'12 tfloat)
                                       tfloat) ::
                                     (Econst_int (Int.repr 67109952) tint) ::
                                     (Econst_int (Int.repr 0) tint) :: nil)))
                                (Scall None
                                  (Evar _begin_walking_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tfloat ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tint
                                                                cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat) ::
                                   (Econst_int (Int.repr 67109952) tint) ::
                                   (Econst_int (Int.repr 0) tint) :: nil))))
                            Sskip)))))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_finish_turning_around := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'4, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tuint) :: (_t'9, tushort) :: (_t'8, tushort) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Object noattr))) ::
               (_t'5, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'9
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'9 tushort)
                   (Econst_int (Int.repr 8) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 80) tint) ::
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
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_jumping_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tint
                                        cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 16779399) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _update_walking_speed (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 189) tint) :: nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _perform_ground_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                           (Econst_int (Int.repr 0) tint) tint)
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 16779404) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              Sskip))
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
                   (Econst_int (Int.repr 67109952) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
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
                            (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                          (tptr tshort)) tshort))
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
                          (tptr tshort)) tshort)
                      (Ebinop Oadd (Etempvar _t'7 tshort)
                        (Econst_int (Int.repr 32768) tint) tint)))))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_braking := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'12, tushort) :: (_t'11, tushort) :: (_t'10, tushort) ::
               (_t'9, tuint) :: (_t'8, (tptr (Tstruct _Object noattr))) ::
               (_t'7, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'11
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'11 tushort)
                       (Econst_int (Int.repr 16) tint) tint) tint)
        (Ssequence
          (Sset _t'12
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sset _t'2
            (Ecast
              (Ebinop Oand (Etempvar _t'12 tushort)
                (Ebinop Oor
                  (Ebinop Oor
                    (Ebinop Oor (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 2) tint) tint)
                    (Econst_int (Int.repr 4) tint) tint)
                  (Econst_int (Int.repr 8) tint) tint) tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _check_common_action_exits (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'4)
        (Evar _apply_slope_decel (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tfloat :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'4 tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 201327165) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'3 tuint))))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Scall (Some _t'5)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 8389719) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'5 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'6)
            (Evar _perform_ground_step (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sswitch (Etempvar _t'6 tint)
            (LScons (Some 0)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16779404) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sbreak)
              (LScons (Some 1)
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
                          (Econst_int (Int.repr 0) tint) tint) tuint)))
                  Sbreak)
                (LScons (Some 2)
                  (Ssequence
                    (Scall None
                      (Evar _slide_bonk (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tvoid
                                          cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 132194) tint) ::
                       (Econst_int (Int.repr 201327165) tint) :: nil))
                    Sbreak)
                  LSnil)))))
        (Ssequence
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
            (Ssequence
              (Sset _t'8
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
                             (Ecast (Econst_int (Int.repr 1) tint) tuint)
                             (Econst_int (Int.repr 28) tint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 16) tint) tuint) tuint)
                         (Ebinop Oshl
                           (Ecast (Econst_int (Int.repr 0) tint) tuint)
                           (Econst_int (Int.repr 8) tint) tuint) tuint)
                       (Econst_int (Int.repr 67108864) tint) tuint)
                     (Econst_int (Int.repr 1) tint) tuint)
                   (Etempvar _t'7 tuint) tuint) ::
                 (Efield
                   (Efield
                     (Efield
                       (Ederef
                         (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                         (Tstruct _Object noattr)) _header
                       (Tstruct _ObjectNode noattr)) _gfx
                     (Tstruct _GraphNodeObject noattr)) _cameraToObject
                   (tarray tfloat 3)) :: nil))))
          (Ssequence
            (Scall None
              (Evar _adjust_sound_for_speed (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 15) tint) :: nil))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_decelerating := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val0C, tint) :: (_slopeClass, tshort) :: (_t'11, tint) ::
               (_t'10, tint) :: (_t'9, tint) :: (_t'8, tuint) ::
               (_t'7, tuint) :: (_t'6, tuint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'19, tushort) :: (_t'18, tushort) ::
               (_t'17, tushort) :: (_t'16, tushort) ::
               (_t'15, (tptr (Tstruct _Object noattr))) :: (_t'14, tuint) ::
               (_t'13, tuint) :: (_t'12, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _mario_get_floor_class (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sset _slopeClass (Ecast (Etempvar _t'1 tint) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'16
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'16 tushort)
                       (Econst_int (Int.repr 16) tint) tint) tint)
        (Ssequence
          (Ssequence
            (Scall (Some _t'3)
              (Evar _should_begin_sliding (Tfunction
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
                   (Econst_int (Int.repr 80) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'2 tuint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'19 tushort)
                             (Econst_int (Int.repr 2) tint) tint)
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _set_jump_from_landing (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sreturn (Some (Etempvar _t'4 tint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Scall (Some _t'5)
                  (Evar _check_ground_dive_or_punch (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Etempvar _t'5 tint)
                  (Sreturn (Some (Econst_int (Int.repr 1) tint)))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Sset _t'18
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 67109952) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'6 tuint))))
                    Sskip))
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                                 (Econst_int (Int.repr 32768) tint) tint)
                    (Ssequence
                      (Scall (Some _t'7)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 75531353) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'7 tuint))))
                    Sskip))))))
        Sskip))
    (Ssequence
      (Ssequence
        (Scall (Some _t'9)
          (Evar _update_decelerating_speed (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'9 tint)
          (Ssequence
            (Scall (Some _t'8)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 205521409) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'8 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'10)
            (Evar _perform_ground_step (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sswitch (Etempvar _t'10 tint)
            (LScons (Some 0)
              (Ssequence
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 16779404) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sbreak)
              (LScons (Some 2)
                (Ssequence
                  (Sifthenelse (Ebinop Oeq (Etempvar _slopeClass tshort)
                                 (Econst_int (Int.repr 19) tint) tint)
                    (Scall None
                      (Evar _mario_bonk_reflection (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tuint :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 1) tint) :: nil))
                    (Scall None
                      (Evar _mario_set_forward_vel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tfloat :: nil) tvoid
                                                     cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                       nil)))
                  Sbreak)
                LSnil))))
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _slopeClass tshort)
                         (Econst_int (Int.repr 19) tint) tint)
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 195) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'14
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _terrainSoundAddend
                      tuint))
                  (Ssequence
                    (Sset _t'15
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _marioObj
                        (tptr (Tstruct _Object noattr))))
                    (Scall None
                      (Evar _play_sound (Tfunction
                                          (tint :: (tptr tfloat) :: nil)
                                          tvoid cc_default))
                      ((Ebinop Oadd
                         (Ebinop Oor
                           (Ebinop Oor
                             (Ebinop Oor
                               (Ebinop Oor
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 1) tint)
                                     tuint) (Econst_int (Int.repr 28) tint)
                                   tuint)
                                 (Ebinop Oshl
                                   (Ecast (Econst_int (Int.repr 0) tint)
                                     tuint) (Econst_int (Int.repr 16) tint)
                                   tuint) tuint)
                               (Ebinop Oshl
                                 (Ecast (Econst_int (Int.repr 0) tint) tuint)
                                 (Econst_int (Int.repr 8) tint) tuint) tuint)
                             (Econst_int (Int.repr 67108864) tint) tuint)
                           (Econst_int (Int.repr 1) tint) tuint)
                         (Etempvar _t'14 tuint) tuint) ::
                       (Efield
                         (Efield
                           (Efield
                             (Ederef
                               (Etempvar _t'15 (tptr (Tstruct _Object noattr)))
                               (Tstruct _Object noattr)) _header
                             (Tstruct _ObjectNode noattr)) _gfx
                           (Tstruct _GraphNodeObject noattr)) _cameraToObject
                         (tarray tfloat 3)) :: nil))))
                (Ssequence
                  (Scall None
                    (Evar _adjust_sound_for_speed (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Sset _t'13
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _particleFlags tuint)
                      (Ebinop Oor (Etempvar _t'13 tuint)
                        (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                          (Econst_int (Int.repr 0) tint) tint) tuint))))))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sset _t'11
                      (Ecast
                        (Ecast
                          (Ebinop Omul
                            (Ebinop Odiv (Etempvar _t'12 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                              tfloat) (Econst_int (Int.repr 65536) tint)
                            tfloat) tint) tint)))
                  (Sset _val0C (Etempvar _t'11 tint)))
                (Sifthenelse (Ebinop Olt (Etempvar _t'11 tint)
                               (Econst_int (Int.repr 4096) tint) tint)
                  (Sset _val0C (Econst_int (Int.repr 4096) tint))
                  Sskip))
              (Ssequence
                (Scall None
                  (Evar _set_mario_anim_with_accel (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      tint :: tint :: nil)
                                                     tshort cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 72) tint) ::
                   (Etempvar _val0C tint) :: nil))
                (Scall None
                  (Evar _play_step_sound (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tshort :: tshort :: nil) tvoid
                                           cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 10) tint) ::
                   (Econst_int (Int.repr 49) tint) :: nil)))))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_act_hold_decelerating := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val0C, tint) :: (_slopeClass, tshort) :: (_t'12, tint) ::
               (_t'11, tint) :: (_t'10, tint) :: (_t'9, tuint) ::
               (_t'8, tuint) :: (_t'7, tint) :: (_t'6, tint) ::
               (_t'5, tuint) :: (_t'4, tint) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'23, tint) ::
               (_t'22, (tptr (Tstruct _Object noattr))) ::
               (_t'21, tushort) :: (_t'20, tushort) :: (_t'19, tushort) ::
               (_t'18, tushort) :: (_t'17, tfloat) ::
               (_t'16, (tptr (Tstruct _Object noattr))) :: (_t'15, tuint) ::
               (_t'14, tuint) :: (_t'13, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _mario_get_floor_class (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sset _slopeClass (Ecast (Etempvar _t'1 tint) tshort)))
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
               (Econst_int (Int.repr 67109952) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'4)
          (Evar _should_begin_sliding (Tfunction
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
               (Econst_int (Int.repr 81) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'3 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'21
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'21 tushort)
                         (Econst_int (Int.repr 8192) tint) tint)
            (Ssequence
              (Scall (Some _t'5)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr (-2147482232)) tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'5 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'20
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'20 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _set_jumping_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tint
                                              cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 50333856) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'6 tint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'19
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'19 tushort)
                             (Econst_int (Int.repr 32768) tint) tint)
                (Ssequence
                  (Scall (Some _t'7)
                    (Evar _drop_and_set_mario_action (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: tuint ::
                                                        nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 75531353) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'7 tint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'18
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _input tushort))
                (Sifthenelse (Ebinop Oand (Etempvar _t'18 tushort)
                               (Econst_int (Int.repr 1) tint) tint)
                  (Ssequence
                    (Scall (Some _t'8)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 1090) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'8 tuint))))
                  Sskip))
              (Ssequence
                (Ssequence
                  (Scall (Some _t'10)
                    (Evar _update_decelerating_speed (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sifthenelse (Etempvar _t'10 tint)
                    (Ssequence
                      (Scall (Some _t'9)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 134218247) tint) ::
                         (Econst_int (Int.repr 0) tint) :: nil))
                      (Sreturn (Some (Etempvar _t'9 tuint))))
                    Sskip))
                (Ssequence
                  (Ssequence
                    (Sset _t'17
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedMag tfloat))
                    (Sassign
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _intendedMag tfloat)
                      (Ebinop Omul (Etempvar _t'17 tfloat)
                        (Econst_single (Float32.of_bits (Int.repr 1053609165)) tfloat)
                        tfloat)))
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'11)
                        (Evar _perform_ground_step (Tfunction
                                                     ((tptr (Tstruct _MarioState noattr)) ::
                                                      nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sswitch (Etempvar _t'11 tint)
                        (LScons (Some 0)
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 16779425) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak)
                          (LScons (Some 2)
                            (Ssequence
                              (Sifthenelse (Ebinop Oeq
                                             (Etempvar _slopeClass tshort)
                                             (Econst_int (Int.repr 19) tint)
                                             tint)
                                (Scall None
                                  (Evar _mario_bonk_reflection (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tuint ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_int (Int.repr 1) tint) :: nil))
                                (Scall None
                                  (Evar _mario_set_forward_vel (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tfloat ::
                                                                  nil) tvoid
                                                                 cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) ::
                                   nil)))
                              Sbreak)
                            LSnil))))
                    (Ssequence
                      (Sifthenelse (Ebinop Oeq (Etempvar _slopeClass tshort)
                                     (Econst_int (Int.repr 19) tint) tint)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_animation (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tint :: nil) tshort
                                                         cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 63) tint) :: nil))
                          (Ssequence
                            (Ssequence
                              (Sset _t'15
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _terrainSoundAddend tuint))
                              (Ssequence
                                (Sset _t'16
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _marioObj
                                    (tptr (Tstruct _Object noattr))))
                                (Scall None
                                  (Evar _play_sound (Tfunction
                                                      (tint ::
                                                       (tptr tfloat) :: nil)
                                                      tvoid cc_default))
                                  ((Ebinop Oadd
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
                                                 (Econst_int (Int.repr 0) tint)
                                                 tuint)
                                               (Econst_int (Int.repr 16) tint)
                                               tuint) tuint)
                                           (Ebinop Oshl
                                             (Ecast
                                               (Econst_int (Int.repr 0) tint)
                                               tuint)
                                             (Econst_int (Int.repr 8) tint)
                                             tuint) tuint)
                                         (Econst_int (Int.repr 67108864) tint)
                                         tuint)
                                       (Econst_int (Int.repr 1) tint) tuint)
                                     (Etempvar _t'15 tuint) tuint) ::
                                   (Efield
                                     (Efield
                                       (Efield
                                         (Ederef
                                           (Etempvar _t'16 (tptr (Tstruct _Object noattr)))
                                           (Tstruct _Object noattr)) _header
                                         (Tstruct _ObjectNode noattr)) _gfx
                                       (Tstruct _GraphNodeObject noattr))
                                     _cameraToObject (tarray tfloat 3)) ::
                                   nil))))
                            (Ssequence
                              (Scall None
                                (Evar _adjust_sound_for_speed (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tvoid
                                                                cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Ssequence
                                (Sset _t'14
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
                                  (Ebinop Oor (Etempvar _t'14 tuint)
                                    (Ebinop Oshl
                                      (Econst_int (Int.repr 1) tint)
                                      (Econst_int (Int.repr 0) tint) tint)
                                    tuint))))))
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
                                (Sset _t'12
                                  (Ecast
                                    (Ecast
                                      (Ebinop Omul (Etempvar _t'13 tfloat)
                                        (Econst_int (Int.repr 65536) tint)
                                        tfloat) tint) tint)))
                              (Sset _val0C (Etempvar _t'12 tint)))
                            (Sifthenelse (Ebinop Olt (Etempvar _t'12 tint)
                                           (Econst_int (Int.repr 4096) tint)
                                           tint)
                              (Sset _val0C (Econst_int (Int.repr 4096) tint))
                              Sskip))
                          (Ssequence
                            (Scall None
                              (Evar _set_mario_anim_with_accel (Tfunction
                                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                                  tint ::
                                                                  tint ::
                                                                  nil) tshort
                                                                 cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 22) tint) ::
                               (Etempvar _val0C tint) :: nil))
                            (Scall None
                              (Evar _play_step_sound (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tshort :: tshort ::
                                                        nil) tvoid
                                                       cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 12) tint) ::
                               (Econst_int (Int.repr 62) tint) :: nil)))))
                      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))
|}.

Definition f_act_riding_shell_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_startYaw, tshort) :: (_t'5, tuint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'18, tshort) :: (_t'17, tushort) :: (_t'16, tfloat) ::
               (_t'15, tushort) :: (_t'14, tuint) :: (_t'13, tuint) ::
               (_t'12, (tptr (Tstruct _Object noattr))) :: (_t'11, tuint) ::
               (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, (tptr (Tstruct _Object noattr))) :: (_t'8, tuint) ::
               (_t'7, tshort) :: (_t'6, (tptr (Tstruct _Surface noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'18
      (Ederef
        (Ebinop Oadd
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
          (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
    (Sset _startYaw (Ecast (Etempvar _t'18 tshort) tshort)))
  (Ssequence
    (Ssequence
      (Sset _t'17
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Ebinop Oand (Etempvar _t'17 tushort)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 42010778) tint) ::
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
                       (Econst_int (Int.repr 32768) tint) tint)
          (Ssequence
            (Scall None
              (Evar _mario_stop_riding_object (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Ssequence
              (Ssequence
                (Sset _t'16
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Olt (Etempvar _t'16 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat)
                               tint)
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 1103101952)) tfloat) ::
                     nil))
                  Sskip))
              (Ssequence
                (Scall (Some _t'2)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 75531353) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'2 tuint))))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _update_shell_speed (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Ssequence
          (Ssequence
            (Ssequence
              (Sset _t'14
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionArg tuint))
              (Sifthenelse (Ebinop Oeq (Etempvar _t'14 tuint)
                             (Econst_int (Int.repr 0) tint) tint)
                (Sset _t'3 (Ecast (Econst_int (Int.repr 109) tint) tint))
                (Sset _t'3 (Ecast (Econst_int (Int.repr 71) tint) tint))))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _t'3 tint) :: nil)))
          (Ssequence
            (Ssequence
              (Scall (Some _t'4)
                (Evar _perform_ground_step (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sswitch (Etempvar _t'4 tint)
                (LScons (Some 0)
                  (Ssequence
                    (Scall None
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 8456347) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    Sbreak)
                  (LScons (Some 2)
                    (Ssequence
                      (Scall None
                        (Evar _mario_stop_riding_object (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Ssequence
                        (Ssequence
                          (Ssequence
                            (Sset _t'13
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _flags tuint))
                            (Sifthenelse (Ebinop Oand (Etempvar _t'13 tuint)
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
                                    (Econst_int (Int.repr 1) tint) tuint)
                                  tuint))
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
                                    (Econst_int (Int.repr 1) tint) tuint)
                                  tuint))))
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
                              ((Etempvar _t'5 tuint) ::
                               (Efield
                                 (Efield
                                   (Efield
                                     (Ederef
                                       (Etempvar _t'12 (tptr (Tstruct _Object noattr)))
                                       (Tstruct _Object noattr)) _header
                                     (Tstruct _ObjectNode noattr)) _gfx
                                   (Tstruct _GraphNodeObject noattr))
                                 _cameraToObject (tarray tfloat 3)) :: nil))))
                        (Ssequence
                          (Ssequence
                            (Sset _t'11
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
                              (Ebinop Oor (Etempvar _t'11 tuint)
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
                               (Econst_int (Int.repr 132194) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil))
                            Sbreak))))
                    LSnil))))
            (Ssequence
              (Scall None
                (Evar _tilt_body_ground_shell (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tshort :: nil) tvoid
                                                cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _startYaw tshort) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'6
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floor
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'7
                      (Efield
                        (Ederef
                          (Etempvar _t'6 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _type tshort))
                    (Sifthenelse (Ebinop Oeq (Etempvar _t'7 tshort)
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
                                     (Ecast (Econst_int (Int.repr 1) tint)
                                       tuint) (Econst_int (Int.repr 28) tint)
                                     tuint)
                                   (Ebinop Oshl
                                     (Ecast (Econst_int (Int.repr 40) tint)
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
                      (Ssequence
                        (Sset _t'8
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr))
                            _terrainSoundAddend tuint))
                        (Ssequence
                          (Sset _t'9
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
                                           (Econst_int (Int.repr 1) tint)
                                           tuint)
                                         (Econst_int (Int.repr 28) tint)
                                         tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 32) tint)
                                           tuint)
                                         (Econst_int (Int.repr 16) tint)
                                         tuint) tuint)
                                     (Ebinop Oshl
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         tuint)
                                       (Econst_int (Int.repr 8) tint) tuint)
                                     tuint)
                                   (Econst_int (Int.repr 67108864) tint)
                                   tuint) (Econst_int (Int.repr 1) tint)
                                 tuint) (Etempvar _t'8 tuint) tuint) ::
                             (Efield
                               (Efield
                                 (Efield
                                   (Ederef
                                     (Etempvar _t'9 (tptr (Tstruct _Object noattr)))
                                     (Tstruct _Object noattr)) _header
                                   (Tstruct _ObjectNode noattr)) _gfx
                                 (Tstruct _GraphNodeObject noattr))
                               _cameraToObject (tarray tfloat 3)) :: nil)))))))
                (Ssequence
                  (Scall None
                    (Evar _adjust_sound_for_speed (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))
|}.

Definition f_act_crawling := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_val04, tint) :: (_t'8, tint) :: (_t'7, tuint) ::
               (_t'6, tuint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tuint) :: (_t'2, tint) :: (_t'1, tuint) ::
               (_t'15, tushort) :: (_t'14, tushort) :: (_t'13, tushort) ::
               (_t'12, tushort) :: (_t'11, tfloat) :: (_t'10, tfloat) ::
               (_t'9, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'2)
      (Evar _should_begin_sliding (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sifthenelse (Etempvar _t'2 tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 80) tint) ::
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
                     (Econst_int (Int.repr 16) tint) tint)
        (Ssequence
          (Scall (Some _t'3)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 201359908) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'3 tuint))))
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
            (Scall (Some _t'4)
              (Evar _set_jumping_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tint
                                          cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 50333824) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'5)
            (Evar _check_ground_dive_or_punch (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'5 tint)
            (Sreturn (Some (Econst_int (Int.repr 1) tint)))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                           (Econst_int (Int.repr 32) tint) tint)
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 201359908) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'6 tuint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'12
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Eunop Onotbool
                             (Ebinop Oand (Etempvar _t'12 tushort)
                               (Econst_int (Int.repr 16384) tint) tint) tint)
                (Ssequence
                  (Scall (Some _t'7)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 201359908) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'7 tuint))))
                Sskip))
            (Ssequence
              (Ssequence
                (Sset _t'11
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedMag tfloat))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _intendedMag tfloat)
                  (Ebinop Omul (Etempvar _t'11 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat)
                    tfloat)))
              (Ssequence
                (Scall None
                  (Evar _update_walking_speed (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'8)
                      (Evar _perform_ground_step (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sswitch (Etempvar _t'8 tint)
                      (LScons (Some 0)
                        (Ssequence
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 16779404) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          Sbreak)
                        (LScons (Some 2)
                          (Ssequence
                            (Sset _t'10
                              (Efield
                                (Ederef
                                  (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                  (Tstruct _MarioState noattr)) _forwardVel
                                tfloat))
                            (Sifthenelse (Ebinop Ogt (Etempvar _t'10 tfloat)
                                           (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                                           tint)
                              (Scall None
                                (Evar _mario_set_forward_vel (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                tfloat ::
                                                                nil) tvoid
                                                               cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat) ::
                                 nil))
                              Sskip))
                          (LScons (Some 1)
                            (Ssequence
                              (Scall None
                                (Evar _align_with_floor (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tvoid
                                                          cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              Sbreak)
                            LSnil)))))
                  (Ssequence
                    (Ssequence
                      (Sset _t'9
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _intendedMag
                          tfloat))
                      (Sset _val04
                        (Ecast
                          (Ebinop Omul
                            (Ebinop Omul (Etempvar _t'9 tfloat)
                              (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                              tfloat) (Econst_int (Int.repr 65536) tint)
                            tfloat) tint)))
                    (Ssequence
                      (Scall None
                        (Evar _set_mario_anim_with_accel (Tfunction
                                                           ((tptr (Tstruct _MarioState noattr)) ::
                                                            tint :: tint ::
                                                            nil) tshort
                                                           cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 153) tint) ::
                         (Etempvar _val04 tint) :: nil))
                      (Ssequence
                        (Scall None
                          (Evar _play_step_sound (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tshort :: tshort :: nil)
                                                   tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 26) tint) ::
                           (Econst_int (Int.repr 79) tint) :: nil))
                        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))))))))
|}.

Definition f_act_burning_ground := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'6, tint) :: (_t'5, tint) :: (_t'4, tfloat) ::
               (_t'3, tuint) :: (_t'2, tuint) :: (_t'1, tuint) ::
               (_t'28, tushort) :: (_t'27, tint) ::
               (_t'26, (tptr (Tstruct _Object noattr))) ::
               (_t'25, (tptr (Tstruct _Object noattr))) :: (_t'24, tint) ::
               (_t'23, (tptr (Tstruct _Object noattr))) ::
               (_t'22, (tptr (Tstruct _Object noattr))) :: (_t'21, tfloat) ::
               (_t'20, tshort) :: (_t'19, tfloat) :: (_t'18, tfloat) ::
               (_t'17, tfloat) :: (_t'16, tshort) :: (_t'15, tshort) ::
               (_t'14, tshort) :: (_t'13, tushort) :: (_t'12, tfloat) ::
               (_t'11, tuint) :: (_t'10, (tptr (Tstruct _Object noattr))) ::
               (_t'9, tshort) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'28
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'28 tushort)
                   (Econst_int (Int.repr 2) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 16910516) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'25
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioObj
          (tptr (Tstruct _Object noattr))))
      (Ssequence
        (Sset _t'26
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Ssequence
          (Sset _t'27
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Efield
                    (Ederef (Etempvar _t'25 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 34) tint) (tptr tint)) tint)
            (Ebinop Oadd (Etempvar _t'27 tint) (Econst_int (Int.repr 2) tint)
              tint)))))
    (Ssequence
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
                    (Ederef (Etempvar _t'23 (tptr (Tstruct _Object noattr)))
                      (Tstruct _Object noattr)) _rawData
                    (Tunion __665 noattr)) _asS32 (tarray tint 80))
                (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'24 tint)
                         (Econst_int (Int.repr 160) tint) tint)
            (Ssequence
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 67109952) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'2 tuint))))
            Sskip)))
      (Ssequence
        (Ssequence
          (Sset _t'20
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _waterLevel tshort))
          (Ssequence
            (Sset _t'21
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _floorHeight tfloat))
            (Sifthenelse (Ebinop Ogt
                           (Ebinop Osub (Etempvar _t'20 tshort)
                             (Etempvar _t'21 tfloat) tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                           tint)
              (Ssequence
                (Ssequence
                  (Sset _t'22
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
                               (Ecast (Econst_int (Int.repr 3) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 3) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 128) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 128) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint) ::
                     (Efield
                       (Efield
                         (Efield
                           (Ederef
                             (Etempvar _t'22 (tptr (Tstruct _Object noattr)))
                             (Tstruct _Object noattr)) _header
                           (Tstruct _ObjectNode noattr)) _gfx
                         (Tstruct _GraphNodeObject noattr)) _cameraToObject
                       (tarray tfloat 3)) :: nil)))
                (Ssequence
                  (Scall (Some _t'3)
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 67109952) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'3 tuint)))))
              Sskip)))
        (Ssequence
          (Ssequence
            (Sset _t'19
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'19 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat)
                           tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat))
              Sskip))
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sifthenelse (Ebinop Ogt (Etempvar _t'18 tfloat)
                             (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat)
                             tint)
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1111490560)) tfloat))
                Sskip))
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'17
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _forwardVel tfloat))
                  (Scall (Some _t'4)
                    (Evar _approach_f32 (Tfunction
                                          (tfloat :: tfloat :: tfloat ::
                                           tfloat :: nil) tfloat cc_default))
                    ((Etempvar _t'17 tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat) ::
                     (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
                     nil)))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat)
                  (Etempvar _t'4 tfloat)))
              (Ssequence
                (Ssequence
                  (Sset _t'13
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _input tushort))
                  (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                                 (Econst_int (Int.repr 1) tint) tint)
                    (Ssequence
                      (Ssequence
                        (Sset _t'15
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _intendedYaw
                            tshort))
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
                          (Scall (Some _t'5)
                            (Evar _approach_s32 (Tfunction
                                                  (tint :: tint :: tint ::
                                                   tint :: nil) tint
                                                  cc_default))
                            ((Ecast
                               (Ebinop Osub (Etempvar _t'15 tshort)
                                 (Etempvar _t'16 tshort) tint) tshort) ::
                             (Econst_int (Int.repr 0) tint) ::
                             (Econst_int (Int.repr 1536) tint) ::
                             (Econst_int (Int.repr 1536) tint) :: nil))))
                      (Ssequence
                        (Sset _t'14
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
                            tshort)
                          (Ebinop Osub (Etempvar _t'14 tshort)
                            (Etempvar _t'5 tint) tint))))
                    Sskip))
                (Ssequence
                  (Scall None
                    (Evar _apply_slope_accel (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tvoid cc_default))
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
                      (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tint)
                                     (Econst_int (Int.repr 0) tint) tint)
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 16910517) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sskip))
                    (Ssequence
                      (Ssequence
                        (Sset _t'12
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Scall None
                          (Evar _set_mario_anim_with_accel (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              tint :: tint ::
                                                              nil) tshort
                                                             cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 114) tint) ::
                           (Ecast
                             (Ebinop Omul
                               (Ebinop Odiv (Etempvar _t'12 tfloat)
                                 (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat)
                                 tfloat) (Econst_int (Int.repr 65536) tint)
                               tfloat) tint) :: nil)))
                      (Ssequence
                        (Scall None
                          (Evar _play_step_sound (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tshort :: tshort :: nil)
                                                   tvoid cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 9) tint) ::
                           (Econst_int (Int.repr 45) tint) :: nil))
                        (Ssequence
                          (Ssequence
                            (Sset _t'11
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
                              (Ebinop Oor (Etempvar _t'11 tuint)
                                (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                  (Econst_int (Int.repr 11) tint) tint)
                                tuint)))
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
                                           (Ecast
                                             (Econst_int (Int.repr 1) tint)
                                             tuint)
                                           (Econst_int (Int.repr 28) tint)
                                           tuint)
                                         (Ebinop Oshl
                                           (Ecast
                                             (Econst_int (Int.repr 16) tint)
                                             tuint)
                                           (Econst_int (Int.repr 16) tint)
                                           tuint) tuint)
                                       (Ebinop Oshl
                                         (Ecast
                                           (Econst_int (Int.repr 0) tint)
                                           tuint)
                                         (Econst_int (Int.repr 8) tint)
                                         tuint) tuint)
                                     (Econst_int (Int.repr 67108864) tint)
                                     tuint) (Econst_int (Int.repr 1) tint)
                                   tuint) ::
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
                                      (Tstruct _MarioState noattr)) _health
                                    tshort))
                                (Sassign
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _health
                                    tshort)
                                  (Ebinop Osub (Etempvar _t'9 tshort)
                                    (Econst_int (Int.repr 10) tint) tint)))
                              (Ssequence
                                (Ssequence
                                  (Sset _t'8
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr)) _health
                                      tshort))
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _t'8 tshort)
                                                 (Econst_int (Int.repr 256) tint)
                                                 tint)
                                    (Scall None
                                      (Evar _set_mario_action (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 tuint ::
                                                                 tuint ::
                                                                 nil) tuint
                                                                cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       (Econst_int (Int.repr 135953) tint) ::
                                       (Econst_int (Int.repr 0) tint) :: nil))
                                    Sskip))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'7
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _marioBodyState
                                        (tptr (Tstruct _MarioBodyState noattr))))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'7 (tptr (Tstruct _MarioBodyState noattr)))
                                          (Tstruct _MarioBodyState noattr))
                                        _eyeState tschar)
                                      (Econst_int (Int.repr 8) tint)))
                                  (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))))))))))))
|}.

Definition f_tilt_body_butt_slide := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_intendedDYaw, tshort) :: (_t'8, tshort) :: (_t'7, tshort) ::
               (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, (tptr (Tstruct _MarioBodyState noattr))) ::
               (_t'3, tfloat) :: (_t'2, tfloat) ::
               (_t'1, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
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
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _faceAngle (tarray tshort 3))
            (Econst_int (Int.repr 1) tint) (tptr tshort)) tshort))
      (Sset _intendedDYaw
        (Ecast
          (Ebinop Osub (Etempvar _t'7 tshort) (Etempvar _t'8 tshort) tint)
          tshort))))
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioBodyState
          (tptr (Tstruct _MarioBodyState noattr))))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Ssequence
          (Sset _t'6
            (Ederef
              (Ebinop Oadd
                (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                  (Econst_int (Int.repr 1024) tint) (tptr tfloat))
                (Ebinop Oshr (Ecast (Etempvar _intendedDYaw tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _t'4 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _torsoAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 0) tint)
                (tptr tshort)) tshort)
            (Ecast
              (Ebinop Omul
                (Ebinop Odiv
                  (Ebinop Omul
                    (Econst_single (Float32.of_bits (Int.repr 1168812715)) tfloat)
                    (Etempvar _t'5 tfloat) tfloat)
                  (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                  tfloat) (Etempvar _t'6 tfloat) tfloat) tint)))))
    (Ssequence
      (Sset _t'1
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _marioBodyState
          (tptr (Tstruct _MarioBodyState noattr))))
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _intendedMag tfloat))
        (Ssequence
          (Sset _t'3
            (Ederef
              (Ebinop Oadd (Evar _gSineTable (tarray tfloat 0))
                (Ebinop Oshr (Ecast (Etempvar _intendedDYaw tshort) tushort)
                  (Econst_int (Int.repr 4) tint) tint) (tptr tfloat)) tfloat))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef
                    (Etempvar _t'1 (tptr (Tstruct _MarioBodyState noattr)))
                    (Tstruct _MarioBodyState noattr)) _torsoAngle
                  (tarray tshort 3)) (Econst_int (Int.repr 2) tint)
                (tptr tshort)) tshort)
            (Ecast
              (Eunop Oneg
                (Ebinop Omul
                  (Ebinop Odiv
                    (Ebinop Omul
                      (Econst_single (Float32.of_bits (Int.repr 1168812715)) tfloat)
                      (Etempvar _t'2 tfloat) tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                    tfloat) (Etempvar _t'3 tfloat) tfloat) tfloat) tint)))))))
|}.

Definition f_common_slide_action := {|
  fn_return := tvoid;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_endAction, tuint) :: (_airAction, tuint) ::
                (_animation, tint) :: nil);
  fn_vars := ((_pos, (tarray tfloat 3)) :: nil);
  fn_temps := ((_wallAngle, tshort) :: (_slideSpeed, tfloat) ::
               (_t'8, tuint) :: (_t'7, tfloat) :: (_t'6, tfloat) ::
               (_t'5, tfloat) :: (_t'4, tfloat) :: (_t'3, tshort) ::
               (_t'2, tint) :: (_t'1, tint) ::
               (_t'30, (tptr (Tstruct _Object noattr))) :: (_t'29, tuint) ::
               (_t'28, tfloat) :: (_t'27, tfloat) ::
               (_t'26, (tptr (Tstruct _Object noattr))) :: (_t'25, tuint) ::
               (_t'24, tuint) :: (_t'23, tfloat) :: (_t'22, tfloat) ::
               (_t'21, (tptr (Tstruct _Surface noattr))) ::
               (_t'20, tfloat) ::
               (_t'19, (tptr (Tstruct _Surface noattr))) ::
               (_t'18, tfloat) :: (_t'17, tfloat) :: (_t'16, tfloat) ::
               (_t'15, tfloat) :: (_t'14, tshort) :: (_t'13, tfloat) ::
               (_t'12, tshort) :: (_t'11, tfloat) :: (_t'10, tshort) ::
               (_t'9, (tptr (Tstruct _Surface noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _vec3f_copy (Tfunction ((tptr tfloat) :: (tptr tfloat) :: nil)
                        (tptr tvoid) cc_default))
    ((Evar _pos (tarray tfloat 3)) ::
     (Efield
       (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
         (Tstruct _MarioState noattr)) _pos (tarray tfloat 3)) :: nil))
  (Ssequence
    (Ssequence
      (Sset _t'29
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
      (Ssequence
        (Sset _t'30
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _marioObj
            (tptr (Tstruct _Object noattr))))
        (Scall None
          (Evar _play_sound (Tfunction (tint :: (tptr tfloat) :: nil) tvoid
                              cc_default))
          ((Ebinop Oadd
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oor
                   (Ebinop Oor
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 1) tint) tuint)
                       (Econst_int (Int.repr 28) tint) tuint)
                     (Ebinop Oshl
                       (Ecast (Econst_int (Int.repr 0) tint) tuint)
                       (Econst_int (Int.repr 16) tint) tuint) tuint)
                   (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                     (Econst_int (Int.repr 8) tint) tuint) tuint)
                 (Econst_int (Int.repr 67108864) tint) tuint)
               (Econst_int (Int.repr 1) tint) tuint) (Etempvar _t'29 tuint)
             tuint) ::
           (Efield
             (Efield
               (Efield
                 (Ederef (Etempvar _t'30 (tptr (Tstruct _Object noattr)))
                   (Tstruct _Object noattr)) _header
                 (Tstruct _ObjectNode noattr)) _gfx
               (Tstruct _GraphNodeObject noattr)) _cameraToObject
             (tarray tfloat 3)) :: nil))))
    (Ssequence
      (Scall None
        (Evar _adjust_sound_for_speed (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Ssequence
        (Scall (Some _t'1)
          (Evar _perform_ground_step (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sswitch (Etempvar _t'1 tint)
          (LScons (Some 0)
            (Ssequence
              (Scall None
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _airAction tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Ssequence
                (Ssequence
                  (Ssequence
                    (Sset _t'27
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Olt (Etempvar _t'27 tfloat)
                                   (Eunop Oneg
                                     (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                                     tfloat) tint)
                      (Sset _t'2 (Econst_int (Int.repr 1) tint))
                      (Ssequence
                        (Sset _t'28
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _forwardVel
                            tfloat))
                        (Sset _t'2
                          (Ecast
                            (Ebinop Olt
                              (Econst_single (Float32.of_bits (Int.repr 1112014848)) tfloat)
                              (Etempvar _t'28 tfloat) tint) tbool)))))
                  (Sifthenelse (Etempvar _t'2 tint)
                    (Ssequence
                      (Sset _t'26
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
                                   (Ecast (Econst_int (Int.repr 3) tint)
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
                                 (Etempvar _t'26 (tptr (Tstruct _Object noattr)))
                                 (Tstruct _Object noattr)) _header
                               (Tstruct _ObjectNode noattr)) _gfx
                             (Tstruct _GraphNodeObject noattr))
                           _cameraToObject (tarray tfloat 3)) :: nil)))
                    Sskip))
                Sbreak))
            (LScons (Some 1)
              (Ssequence
                (Scall None
                  (Evar _set_mario_animation (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tint :: nil) tshort
                                               cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _animation tint) :: nil))
                (Ssequence
                  (Scall None
                    (Evar _align_with_floor (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tvoid cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Ssequence
                    (Ssequence
                      (Sset _t'25
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
                        (Ebinop Oor (Etempvar _t'25 tuint)
                          (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                            (Econst_int (Int.repr 0) tint) tint) tuint)))
                    Sbreak)))
              (LScons (Some 2)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'8)
                      (Evar _mario_floor_is_slippery (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        nil) tuint
                                                       cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Eunop Onotbool (Etempvar _t'8 tuint) tint)
                      (Ssequence
                        (Ssequence
                          (Sset _t'23
                            (Efield
                              (Ederef
                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                (Tstruct _MarioState noattr)) _forwardVel
                              tfloat))
                          (Sifthenelse (Ebinop Ogt (Etempvar _t'23 tfloat)
                                         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                                         tint)
                            (Ssequence
                              (Sset _t'24
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
                                (Ebinop Oor (Etempvar _t'24 tuint)
                                  (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                                    (Econst_int (Int.repr 1) tint) tint)
                                  tuint)))
                            Sskip))
                        (Scall None
                          (Evar _slide_bonk (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tvoid
                                              cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 132198) tint) ::
                           (Etempvar _endAction tuint) :: nil)))
                      (Ssequence
                        (Sset _t'9
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _wall
                            (tptr (Tstruct _Surface noattr))))
                        (Sifthenelse (Ebinop One
                                       (Etempvar _t'9 (tptr (Tstruct _Surface noattr)))
                                       (Ecast (Econst_int (Int.repr 0) tint)
                                         (tptr tvoid)) tint)
                          (Ssequence
                            (Ssequence
                              (Ssequence
                                (Sset _t'19
                                  (Efield
                                    (Ederef
                                      (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                      (Tstruct _MarioState noattr)) _wall
                                    (tptr (Tstruct _Surface noattr))))
                                (Ssequence
                                  (Sset _t'20
                                    (Efield
                                      (Efield
                                        (Ederef
                                          (Etempvar _t'19 (tptr (Tstruct _Surface noattr)))
                                          (Tstruct _Surface noattr)) _normal
                                        (Tstruct __670 noattr)) _z tfloat))
                                  (Ssequence
                                    (Sset _t'21
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr)) _wall
                                        (tptr (Tstruct _Surface noattr))))
                                    (Ssequence
                                      (Sset _t'22
                                        (Efield
                                          (Efield
                                            (Ederef
                                              (Etempvar _t'21 (tptr (Tstruct _Surface noattr)))
                                              (Tstruct _Surface noattr))
                                            _normal (Tstruct __670 noattr))
                                          _x tfloat))
                                      (Scall (Some _t'3)
                                        (Evar _atan2s (Tfunction
                                                        (tfloat :: tfloat ::
                                                         nil) tshort
                                                        cc_default))
                                        ((Etempvar _t'20 tfloat) ::
                                         (Etempvar _t'22 tfloat) :: nil))))))
                              (Sset _wallAngle
                                (Ecast (Etempvar _t'3 tshort) tshort)))
                            (Ssequence
                              (Ssequence
                                (Ssequence
                                  (Sset _t'15
                                    (Efield
                                      (Ederef
                                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                        (Tstruct _MarioState noattr))
                                      _slideVelX tfloat))
                                  (Ssequence
                                    (Sset _t'16
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _slideVelX tfloat))
                                    (Ssequence
                                      (Sset _t'17
                                        (Efield
                                          (Ederef
                                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                            (Tstruct _MarioState noattr))
                                          _slideVelZ tfloat))
                                      (Ssequence
                                        (Sset _t'18
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _slideVelZ tfloat))
                                        (Scall (Some _t'4)
                                          (Evar _sqrtf (Tfunction
                                                         (tfloat :: nil)
                                                         tfloat cc_default))
                                          ((Ebinop Oadd
                                             (Ebinop Omul
                                               (Etempvar _t'15 tfloat)
                                               (Etempvar _t'16 tfloat)
                                               tfloat)
                                             (Ebinop Omul
                                               (Etempvar _t'17 tfloat)
                                               (Etempvar _t'18 tfloat)
                                               tfloat) tfloat) :: nil))))))
                                (Sset _slideSpeed (Etempvar _t'4 tfloat)))
                              (Ssequence
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'5
                                      (Ecast
                                        (Ebinop Omul
                                          (Etempvar _slideSpeed tfloat)
                                          (Econst_float (Float.of_bits (Int64.repr 4606281698874543309)) tdouble)
                                          tdouble) tfloat))
                                    (Sset _slideSpeed (Etempvar _t'5 tfloat)))
                                  (Sifthenelse (Ebinop Olt
                                                 (Etempvar _t'5 tfloat)
                                                 (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat)
                                                 tint)
                                    (Sset _slideSpeed
                                      (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat))
                                    Sskip))
                                (Ssequence
                                  (Ssequence
                                    (Sset _t'14
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _slideYaw tshort))
                                    (Sassign
                                      (Efield
                                        (Ederef
                                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                          (Tstruct _MarioState noattr))
                                        _slideYaw tshort)
                                      (Ebinop Oadd
                                        (Ebinop Osub
                                          (Etempvar _wallAngle tshort)
                                          (Ecast
                                            (Ebinop Osub
                                              (Etempvar _t'14 tshort)
                                              (Etempvar _wallAngle tshort)
                                              tint) tshort) tint)
                                        (Econst_int (Int.repr 32768) tint)
                                        tint)))
                                  (Ssequence
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'12
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _slideYaw tshort))
                                          (Ssequence
                                            (Sset _t'13
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Evar _gSineTable (tarray tfloat 0))
                                                  (Ebinop Oshr
                                                    (Ecast
                                                      (Etempvar _t'12 tshort)
                                                      tushort)
                                                    (Econst_int (Int.repr 4) tint)
                                                    tint) (tptr tfloat))
                                                tfloat))
                                            (Sset _t'6
                                              (Ecast
                                                (Ebinop Omul
                                                  (Etempvar _slideSpeed tfloat)
                                                  (Etempvar _t'13 tfloat)
                                                  tfloat) tfloat))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _slideVelX tfloat)
                                          (Etempvar _t'6 tfloat)))
                                      (Sassign
                                        (Ederef
                                          (Ebinop Oadd
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _vel (tarray tfloat 3))
                                            (Econst_int (Int.repr 0) tint)
                                            (tptr tfloat)) tfloat)
                                        (Etempvar _t'6 tfloat)))
                                    (Ssequence
                                      (Ssequence
                                        (Ssequence
                                          (Sset _t'10
                                            (Efield
                                              (Ederef
                                                (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                                (Tstruct _MarioState noattr))
                                              _slideYaw tshort))
                                          (Ssequence
                                            (Sset _t'11
                                              (Ederef
                                                (Ebinop Oadd
                                                  (Ebinop Oadd
                                                    (Evar _gSineTable (tarray tfloat 0))
                                                    (Econst_int (Int.repr 1024) tint)
                                                    (tptr tfloat))
                                                  (Ebinop Oshr
                                                    (Ecast
                                                      (Etempvar _t'10 tshort)
                                                      tushort)
                                                    (Econst_int (Int.repr 4) tint)
                                                    tint) (tptr tfloat))
                                                tfloat))
                                            (Sset _t'7
                                              (Ecast
                                                (Ebinop Omul
                                                  (Etempvar _slideSpeed tfloat)
                                                  (Etempvar _t'11 tfloat)
                                                  tfloat) tfloat))))
                                        (Sassign
                                          (Efield
                                            (Ederef
                                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                              (Tstruct _MarioState noattr))
                                            _slideVelZ tfloat)
                                          (Etempvar _t'7 tfloat)))
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
                                        (Etempvar _t'7 tfloat))))))))
                          Sskip))))
                  (Ssequence
                    (Scall None
                      (Evar _align_with_floor (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    Sbreak))
                LSnil))))))))
|}.

Definition f_common_slide_action_with_jump := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_stopAction, tuint) :: (_jumpAction, tuint) ::
                (_airAction, tuint) :: (_animation, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'4
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'4 tushort)
                   (Econst_int (Int.repr 5) tint) tint)
      (Ssequence
        (Sset _t'6
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'6 tushort)
                       (Econst_int (Int.repr 2) tint) tint)
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_jumping_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tint
                                          cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _jumpAction tuint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'1 tint))))
          Sskip))
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'5 tushort) (Econst_int (Int.repr 1) tint)
            tint)))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'3)
        (Evar _update_sliding (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tfloat :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'3 tint)
        (Ssequence
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _stopAction tuint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'2 tuint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _common_slide_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: tint :: nil) tvoid
                                     cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _stopAction tuint) :: (Etempvar _airAction tuint) ::
         (Etempvar _animation tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_butt_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _common_slide_action_with_jump (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: tuint :: tuint ::
                                              tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 201327166) tint) ::
       (Econst_int (Int.repr 50333824) tint) ::
       (Econst_int (Int.repr 50333838) tint) ::
       (Econst_int (Int.repr 145) tint) :: nil))
    (Sset _cancel (Etempvar _t'1 tint)))
  (Ssequence
    (Scall None
      (Evar _tilt_body_butt_slide (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
    (Sreturn (Some (Etempvar _cancel tint)))))
|}.

Definition f_act_hold_butt_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'2, tint) :: (_t'1, tint) ::
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
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 8651858) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _common_slide_action_with_jump (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: tuint ::
                                                tint :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 134218815) tint) ::
         (Econst_int (Int.repr 50333856) tint) ::
         (Econst_int (Int.repr 16779426) tint) ::
         (Econst_int (Int.repr 69) tint) :: nil))
      (Sset _cancel (Etempvar _t'2 tint)))
    (Ssequence
      (Scall None
        (Evar _tilt_body_butt_slide (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sreturn (Some (Etempvar _cancel tint))))))
|}.

Definition f_act_crouch_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'7, tint) :: (_t'6, tuint) ::
               (_t'5, tint) :: (_t'4, tuint) :: (_t'3, tuint) ::
               (_t'2, tint) :: (_t'1, tuint) :: (_t'16, tushort) ::
               (_t'15, tushort) :: (_t'14, tfloat) :: (_t'13, tushort) ::
               (_t'12, tushort) :: (_t'11, tfloat) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'16
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                   (Econst_int (Int.repr 8) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 8651858) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tuint))))
      Sskip))
  (Ssequence
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionTimer tushort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'12 tushort)
                     (Econst_int (Int.repr 30) tint) tint)
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
            (Sset _t'13
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'13 tushort)
                           (Econst_int (Int.repr 2) tint) tint)
              (Ssequence
                (Sset _t'14
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Ogt (Etempvar _t'14 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                               tint)
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _set_jumping_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Econst_int (Int.repr 50333832) tint) ::
                       (Econst_int (Int.repr 0) tint) :: nil))
                    (Sreturn (Some (Etempvar _t'2 tint))))
                  Sskip))
              Sskip)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'10
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 8192) tint) tint)
          (Ssequence
            (Sset _t'11
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Oge (Etempvar _t'11 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1092616192)) tfloat)
                           tint)
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 25168042) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'3 tuint))))
              (Ssequence
                (Scall (Some _t'4)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 8389719) tint) ::
                   (Econst_int (Int.repr 9) tint) :: nil))
                (Sreturn (Some (Etempvar _t'4 tuint))))))
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
              (Scall (Some _t'5)
                (Evar _set_jumping_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tint
                                            cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 50333824) tint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'5 tint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Sset _t'8
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                           (Econst_int (Int.repr 16) tint) tint)
              (Ssequence
                (Scall (Some _t'6)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 67109957) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                (Sreturn (Some (Etempvar _t'6 tuint))))
              Sskip))
          (Ssequence
            (Ssequence
              (Scall (Some _t'7)
                (Evar _common_slide_action_with_jump (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: tuint ::
                                                        tuint :: tint :: nil)
                                                       tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 201359904) tint) ::
                 (Econst_int (Int.repr 50333824) tint) ::
                 (Econst_int (Int.repr 16779404) tint) ::
                 (Econst_int (Int.repr 151) tint) :: nil))
              (Sset _cancel (Etempvar _t'7 tint)))
            (Sreturn (Some (Etempvar _cancel tint)))))))))
|}.

Definition f_act_slide_kick_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tint) :: (_t'11, tushort) ::
               (_t'10, tfloat) :: (_t'9, tuint) ::
               (_t'8, (tptr (Tstruct _Object noattr))) :: (_t'7, tuint) ::
               (_t'6, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                   (Econst_int (Int.repr 2) tint) tint)
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_jumping_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tint
                                      cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 16779430) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        (Sreturn (Some (Etempvar _t'1 tint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _set_mario_animation (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tint :: nil) tshort cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 140) tint) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Scall (Some _t'3)
            (Evar _is_anim_at_end (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'3 tint)
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _forwardVel tfloat))
              (Sset _t'4
                (Ecast
                  (Ebinop Olt (Etempvar _t'10 tfloat)
                    (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                    tint) tbool)))
            (Sset _t'4 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'4 tint)
          (Ssequence
            (Scall (Some _t'2)
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 134218277) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Scall None
          (Evar _update_sliding (Tfunction
                                  ((tptr (Tstruct _MarioState noattr)) ::
                                   tfloat :: nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat) ::
           nil))
        (Ssequence
          (Ssequence
            (Scall (Some _t'5)
              (Evar _perform_ground_step (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            nil) tint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Sswitch (Etempvar _t'5 tint)
              (LScons (Some 0)
                (Ssequence
                  (Scall None
                    (Evar _set_mario_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tuint :: tuint :: nil) tuint
                                              cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 16779404) tint) ::
                     (Econst_int (Int.repr 2) tint) :: nil))
                  Sbreak)
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
                              (Econst_int (Int.repr 1) tint) tint) tuint)))
                      (Ssequence
                        (Scall None
                          (Evar _set_mario_action (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     tuint :: tuint :: nil)
                                                    tuint cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           (Econst_int (Int.repr 132194) tint) ::
                           (Econst_int (Int.repr 0) tint) :: nil))
                        Sbreak)))
                  LSnil))))
          (Ssequence
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _terrainSoundAddend tuint))
              (Ssequence
                (Sset _t'8
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
                               (Ecast (Econst_int (Int.repr 1) tint) tuint)
                               (Econst_int (Int.repr 28) tint) tuint)
                             (Ebinop Oshl
                               (Ecast (Econst_int (Int.repr 0) tint) tuint)
                               (Econst_int (Int.repr 16) tint) tuint) tuint)
                           (Ebinop Oshl
                             (Ecast (Econst_int (Int.repr 0) tint) tuint)
                             (Econst_int (Int.repr 8) tint) tuint) tuint)
                         (Econst_int (Int.repr 67108864) tint) tuint)
                       (Econst_int (Int.repr 1) tint) tuint)
                     (Etempvar _t'7 tuint) tuint) ::
                   (Efield
                     (Efield
                       (Efield
                         (Ederef
                           (Etempvar _t'8 (tptr (Tstruct _Object noattr)))
                           (Tstruct _Object noattr)) _header
                         (Tstruct _ObjectNode noattr)) _gfx
                       (Tstruct _GraphNodeObject noattr)) _cameraToObject
                     (tarray tfloat 3)) :: nil))))
            (Ssequence
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint)
                  (Ebinop Oor (Etempvar _t'6 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 0) tint) tint) tuint)))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_stomach_slide_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_stopAction, tuint) :: (_airAction, tuint) ::
                (_animation, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'10, tushort) ::
               (_t'9, tushort) :: (_t'8, tfloat) :: (_t'7, tushort) ::
               (_t'6, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _actionTimer tushort))
    (Sifthenelse (Ebinop Oeq (Etempvar _t'6 tushort)
                   (Econst_int (Int.repr 5) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'9 tushort)
                           (Econst_int (Int.repr 8) tint) tint) tint)
            (Ssequence
              (Sset _t'10
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sset _t'3
                (Ecast
                  (Ebinop Oand (Etempvar _t'10 tushort)
                    (Ebinop Oor (Econst_int (Int.repr 2) tint)
                      (Econst_int (Int.repr 8192) tint) tint) tint) tbool)))
            (Sset _t'3 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'8
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Oge (Etempvar _t'8 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                               tint)
                  (Sset _t'1
                    (Ecast (Econst_int (Int.repr 16779430) tint) tint))
                  (Sset _t'1
                    (Ecast (Econst_int (Int.repr 16779437) tint) tint))))
              (Scall (Some _t'2)
                (Evar _drop_and_set_mario_action (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: tuint :: nil)
                                                   tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _t'1 tint) :: (Econst_int (Int.repr 0) tint) ::
                 nil)))
            (Sreturn (Some (Etempvar _t'2 tint))))
          Sskip))
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _actionTimer tushort)
          (Ebinop Oadd (Etempvar _t'7 tushort) (Econst_int (Int.repr 1) tint)
            tint)))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'5)
        (Evar _update_sliding (Tfunction
                                ((tptr (Tstruct _MarioState noattr)) ::
                                 tfloat :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1082130432)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'5 tint)
        (Ssequence
          (Scall (Some _t'4)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _stopAction tuint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'4 tuint))))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _common_slide_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: tint :: nil) tvoid
                                     cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Etempvar _stopAction tuint) :: (Etempvar _airAction tuint) ::
         (Etempvar _animation tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_stomach_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _stomach_slide_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: tint :: nil) tint
                                    cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 902) tint) ::
       (Econst_int (Int.repr 16779404) tint) ::
       (Econst_int (Int.repr 137) tint) :: nil))
    (Sset _cancel (Etempvar _t'1 tint)))
  (Sreturn (Some (Etempvar _cancel tint))))
|}.

Definition f_act_hold_stomach_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'2, tint) :: (_t'1, tint) ::
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
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 9176147) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _stomach_slide_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: tint :: nil) tint
                                      cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 901) tint) ::
         (Econst_int (Int.repr 16779425) tint) ::
         (Econst_int (Int.repr 137) tint) :: nil))
      (Sset _cancel (Etempvar _t'2 tint)))
    (Sreturn (Some (Etempvar _cancel tint)))))
|}.

Definition f_act_dive_slide := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'7, tuint) :: (_t'6, tint) :: (_t'5, tint) ::
               (_t'4, tint) :: (_t'3, tint) :: (_t'2, tuint) ::
               (_t'1, tint) :: (_t'11, tushort) :: (_t'10, tushort) ::
               (_t'9, tfloat) ::
               (_t'8, (tptr (Tstruct _MarioBodyState noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'10
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _input tushort))
      (Sifthenelse (Eunop Onotbool
                     (Ebinop Oand (Etempvar _t'10 tushort)
                       (Econst_int (Int.repr 8) tint) tint) tint)
        (Ssequence
          (Sset _t'11
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sset _t'3
            (Ecast
              (Ebinop Oand (Etempvar _t'11 tushort)
                (Ebinop Oor (Econst_int (Int.repr 2) tint)
                  (Econst_int (Int.repr 8192) tint) tint) tint) tbool)))
        (Sset _t'3 (Econst_int (Int.repr 0) tint))))
    (Sifthenelse (Etempvar _t'3 tint)
      (Ssequence
        (Ssequence
          (Ssequence
            (Sset _t'9
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat))
            (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                           tint)
              (Sset _t'1 (Ecast (Econst_int (Int.repr 16779430) tint) tint))
              (Sset _t'1 (Ecast (Econst_int (Int.repr 16779437) tint) tint))))
          (Scall (Some _t'2)
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'1 tint) :: (Econst_int (Int.repr 0) tint) :: nil)))
        (Sreturn (Some (Etempvar _t'2 tuint))))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _play_mario_landing_sound_once (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tuint :: nil) tvoid cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 24) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Ssequence
        (Ssequence
          (Scall (Some _t'4)
            (Evar _update_sliding (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tfloat :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 1090519040)) tfloat) ::
             nil))
          (Sifthenelse (Etempvar _t'4 tint)
            (Ssequence
              (Scall (Some _t'6)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sset _t'5 (Ecast (Etempvar _t'6 tint) tbool)))
            (Sset _t'5 (Econst_int (Int.repr 0) tint))))
        (Sifthenelse (Etempvar _t'5 tint)
          (Ssequence
            (Scall None
              (Evar _mario_set_forward_vel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tvoid
                                             cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat) :: nil))
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 902) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil)))
          Sskip))
      (Ssequence
        (Ssequence
          (Scall (Some _t'7)
            (Evar _mario_check_object_grab (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tuint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
          (Sifthenelse (Etempvar _t'7 tuint)
            (Ssequence
              (Scall None
                (Evar _mario_grab_used_object (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tvoid cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Ssequence
                (Ssequence
                  (Sset _t'8
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _marioBodyState
                      (tptr (Tstruct _MarioBodyState noattr))))
                  (Sassign
                    (Efield
                      (Ederef
                        (Etempvar _t'8 (tptr (Tstruct _MarioBodyState noattr)))
                        (Tstruct _MarioBodyState noattr)) _grabPos tschar)
                    (Econst_int (Int.repr 1) tint)))
                (Sreturn (Some (Econst_int (Int.repr 1) tint)))))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _common_slide_action (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tuint :: tuint :: tint :: nil)
                                         tvoid cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 902) tint) ::
             (Econst_int (Int.repr 16779404) tint) ::
             (Econst_int (Int.repr 136) tint) :: nil))
          (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))
|}.

Definition f_common_ground_knockback_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tint) :: (_arg2, tint) :: (_arg3, tint) ::
                (_arg4, tint) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tshort) :: (_t'8, tfloat) :: (_t'7, tfloat) ::
               (_t'6, tfloat) :: (_t'5, tfloat) :: (_t'4, tshort) :: nil);
  fn_body :=
(Ssequence
  (Sifthenelse (Etempvar _arg3 tint)
    (Scall None
      (Evar _play_mario_heavy_landing_sound_once (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: nil) tvoid
                                                   cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 24) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    Sskip)
  (Ssequence
    (Sifthenelse (Ebinop Ogt (Etempvar _arg4 tint)
                   (Econst_int (Int.repr 0) tint) tint)
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 10) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 255) tint) tuint)
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
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 11) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 208) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) ::
         (Econst_int (Int.repr 131072) tint) :: nil)))
    (Ssequence
      (Ssequence
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Ogt (Etempvar _t'8 tfloat)
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
          (Sset _t'7
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Olt (Etempvar _t'7 tfloat)
                         (Eunop Oneg
                           (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                           tfloat) tint)
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _forwardVel tfloat)
              (Eunop Oneg
                (Econst_single (Float32.of_bits (Int.repr 1107296256)) tfloat)
                tfloat))
            Sskip))
        (Ssequence
          (Ssequence
            (Scall (Some _t'1)
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _animation tint) :: nil))
            (Sset _animFrame (Etempvar _t'1 tshort)))
          (Ssequence
            (Sifthenelse (Ebinop Olt (Etempvar _animFrame tint)
                           (Etempvar _arg2 tint) tint)
              (Scall None
                (Evar _apply_landing_accel (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tfloat :: nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_single (Float32.of_bits (Int.repr 1063675494)) tfloat) ::
                 nil))
              (Ssequence
                (Sset _t'6
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _forwardVel tfloat))
                (Sifthenelse (Ebinop Oge (Etempvar _t'6 tfloat)
                               (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                               tint)
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat) ::
                     nil))
                  (Scall None
                    (Evar _mario_set_forward_vel (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tfloat :: nil) tvoid
                                                   cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Eunop Oneg
                       (Econst_single (Float32.of_bits (Int.repr 1036831949)) tfloat)
                       tfloat) :: nil)))))
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _perform_ground_step (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                               (Econst_int (Int.repr 0) tint) tint)
                  (Ssequence
                    (Sset _t'5
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _forwardVel tfloat))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'5 tfloat)
                                   (Econst_single (Float32.of_bits (Int.repr 0)) tfloat)
                                   tint)
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 16910513) tint) ::
                         (Etempvar _arg4 tint) :: nil))
                      (Scall None
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Econst_int (Int.repr 16910512) tint) ::
                         (Etempvar _arg4 tint) :: nil))))
                  (Ssequence
                    (Scall (Some _t'2)
                      (Evar _is_anim_at_end (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sifthenelse (Etempvar _t'2 tint)
                      (Ssequence
                        (Sset _t'4
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _health tshort))
                        (Sifthenelse (Ebinop Olt (Etempvar _t'4 tshort)
                                       (Econst_int (Int.repr 256) tint) tint)
                          (Scall None
                            (Evar _set_mario_action (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       tuint :: tuint :: nil)
                                                      tuint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             (Econst_int (Int.repr 135953) tint) ::
                             (Econst_int (Int.repr 0) tint) :: nil))
                          (Ssequence
                            (Sifthenelse (Ebinop Ogt (Etempvar _arg4 tint)
                                           (Econst_int (Int.repr 0) tint)
                                           tint)
                              (Sassign
                                (Efield
                                  (Ederef
                                    (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                                    (Tstruct _MarioState noattr))
                                  _invincTimer tshort)
                                (Econst_int (Int.repr 30) tint))
                              Sskip)
                            (Scall None
                              (Evar _set_mario_action (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         tuint :: tuint ::
                                                         nil) tuint
                                                        cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               (Econst_int (Int.repr 205521409) tint) ::
                               (Econst_int (Int.repr 0) tint) :: nil)))))
                      Sskip))))
              (Sreturn (Some (Etempvar _animFrame tint))))))))))
|}.

Definition f_act_hard_backward_ground_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'3, tint) :: (_t'2, tint) ::
               (_t'1, tint) :: (_t'7, tuint) :: (_t'6, tshort) ::
               (_t'5, tuint) :: (_t'4, (tptr (Tstruct _Object noattr))) ::
               nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'7
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Scall (Some _t'1)
        (Evar _common_ground_knockback_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: tint :: tint ::
                                                 tint :: nil) tint
                                                cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 1) tint) :: (Econst_int (Int.repr 43) tint) ::
         (Econst_int (Int.repr 1) tint) :: (Etempvar _t'7 tuint) :: nil)))
    (Sset _animFrame (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Econst_int (Int.repr 43) tint) tint)
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _health tshort))
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _t'6 tshort)
                (Econst_int (Int.repr 256) tint) tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'2 tint)
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 135958) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        Sskip))
    (Ssequence
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                       (Econst_int (Int.repr 54) tint) tint)
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _prevAction tuint))
            (Sset _t'3
              (Ecast
                (Ebinop Oeq (Etempvar _t'5 tuint)
                  (Econst_int (Int.repr 6444) tint) tint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint)))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Sset _t'4
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
                         (Ecast (Econst_int (Int.repr 32) tint) tuint)
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
                     (Ederef (Etempvar _t'4 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          Sskip))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                       (Econst_int (Int.repr 69) tint) tint)
          (Scall None
            (Evar _play_mario_landing_sound_once (Tfunction
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
          Sskip)
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_hard_forward_ground_kb := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'4, tuint) :: (_t'3, tshort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'4
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Scall (Some _t'1)
        (Evar _common_ground_knockback_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: tint :: tint ::
                                                 tint :: nil) tint
                                                cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 44) tint) ::
         (Econst_int (Int.repr 21) tint) :: (Econst_int (Int.repr 1) tint) ::
         (Etempvar _t'4 tuint) :: nil)))
    (Sset _animFrame (Etempvar _t'1 tint)))
  (Ssequence
    (Ssequence
      (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                     (Econst_int (Int.repr 23) tint) tint)
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _health tshort))
          (Sset _t'2
            (Ecast
              (Ebinop Olt (Etempvar _t'3 tshort)
                (Econst_int (Int.repr 256) tint) tint) tbool)))
        (Sset _t'2 (Econst_int (Int.repr 0) tint)))
      (Sifthenelse (Etempvar _t'2 tint)
        (Scall None
          (Evar _set_mario_action (Tfunction
                                    ((tptr (Tstruct _MarioState noattr)) ::
                                     tuint :: tuint :: nil) tuint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 135957) tint) ::
           (Econst_int (Int.repr 0) tint) :: nil))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_backward_ground_kb := {|
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
      (Evar _common_ground_knockback_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 123) tint) :: (Econst_int (Int.repr 22) tint) ::
       (Econst_int (Int.repr 1) tint) :: (Etempvar _t'1 tuint) :: nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_forward_ground_kb := {|
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
      (Evar _common_ground_knockback_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 124) tint) :: (Econst_int (Int.repr 20) tint) ::
       (Econst_int (Int.repr 1) tint) :: (Etempvar _t'1 tuint) :: nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_soft_backward_ground_kb := {|
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
      (Evar _common_ground_knockback_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 116) tint) ::
       (Econst_int (Int.repr 100) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Etempvar _t'1 tuint) :: nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_soft_forward_ground_kb := {|
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
      (Evar _common_ground_knockback_action (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               tint :: tint :: tint ::
                                               tint :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 117) tint) ::
       (Econst_int (Int.repr 100) tint) :: (Econst_int (Int.repr 0) tint) ::
       (Etempvar _t'1 tuint) :: nil)))
  (Sreturn (Some (Econst_int (Int.repr 0) tint))))
|}.

Definition f_act_ground_bonk := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'1, tint) :: (_t'2, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Ssequence
      (Sset _t'2
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _actionArg tuint))
      (Scall (Some _t'1)
        (Evar _common_ground_knockback_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tint :: tint :: tint ::
                                                 tint :: nil) tint
                                                cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 138) tint) ::
         (Econst_int (Int.repr 32) tint) :: (Econst_int (Int.repr 1) tint) ::
         (Etempvar _t'2 tuint) :: nil)))
    (Sset _animFrame (Etempvar _t'1 tint)))
  (Ssequence
    (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                   (Econst_int (Int.repr 32) tint) tint)
      (Scall None
        (Evar _play_mario_landing_sound (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: nil) tvoid cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oor
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                   (Econst_int (Int.repr 28) tint) tuint)
                 (Ebinop Oshl (Ecast (Econst_int (Int.repr 8) tint) tuint)
                   (Econst_int (Int.repr 16) tint) tuint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
                 (Econst_int (Int.repr 8) tint) tuint) tuint)
             (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
               (Econst_int (Int.repr 128) tint) tint) tuint)
           (Econst_int (Int.repr 1) tint) tuint) :: nil))
      Sskip)
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_death_exit_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_animFrame, tint) :: (_t'2, tint) :: (_t'1, tshort) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Scall None
    (Evar _apply_landing_accel (Tfunction
                                 ((tptr (Tstruct _MarioState noattr)) ::
                                  tfloat :: nil) tint cc_default))
    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
     (Econst_single (Float32.of_bits (Int.repr 1063675494)) tfloat) :: nil))
  (Ssequence
    (Scall None
      (Evar _play_mario_heavy_landing_sound_once (Tfunction
                                                   ((tptr (Tstruct _MarioState noattr)) ::
                                                    tuint :: nil) tvoid
                                                   cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Ebinop Oor
         (Ebinop Oor
           (Ebinop Oor
             (Ebinop Oor
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 0) tint) tuint)
                 (Econst_int (Int.repr 28) tint) tuint)
               (Ebinop Oshl (Ecast (Econst_int (Int.repr 24) tint) tuint)
                 (Econst_int (Int.repr 16) tint) tuint) tuint)
             (Ebinop Oshl (Ecast (Econst_int (Int.repr 128) tint) tuint)
               (Econst_int (Int.repr 8) tint) tuint) tuint)
           (Ebinop Oor (Econst_int (Int.repr 67108864) tint)
             (Econst_int (Int.repr 128) tint) tint) tuint)
         (Econst_int (Int.repr 1) tint) tuint) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'1)
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 1) tint) :: nil))
        (Sset _animFrame (Etempvar _t'1 tshort)))
      (Ssequence
        (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                       (Econst_int (Int.repr 54) tint) tint)
          (Ssequence
            (Sset _t'3
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
                         (Ecast (Econst_int (Int.repr 32) tint) tuint)
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
                     (Ederef (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                       (Tstruct _Object noattr)) _header
                     (Tstruct _ObjectNode noattr)) _gfx
                   (Tstruct _GraphNodeObject noattr)) _cameraToObject
                 (tarray tfloat 3)) :: nil)))
          Sskip)
        (Ssequence
          (Sifthenelse (Ebinop Oeq (Etempvar _animFrame tint)
                         (Econst_int (Int.repr 68) tint) tint)
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
            Sskip)
          (Ssequence
            (Ssequence
              (Scall (Some _t'2)
                (Evar _is_anim_at_end (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
              (Sifthenelse (Etempvar _t'2 tint)
                (Scall None
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Econst_int (Int.repr 205521409) tint) ::
                   (Econst_int (Int.repr 0) tint) :: nil))
                Sskip))
            (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))))
|}.

Definition f_common_landing_action := {|
  fn_return := tuint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation, tshort) :: (_airAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_stepResult, tuint) :: (_t'2, tint) :: (_t'1, tint) ::
               (_t'12, tfloat) :: (_t'11, tushort) :: (_t'10, tuint) ::
               (_t'9, tfloat) :: (_t'8, tshort) ::
               (_t'7, (tptr (Tstruct _Surface noattr))) :: (_t'6, tshort) ::
               (_t'5, (tptr (Tstruct _Surface noattr))) :: (_t'4, tushort) ::
               (_t'3, tfloat) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'11
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                   (Econst_int (Int.repr 1) tint) tint)
      (Scall None
        (Evar _apply_landing_accel (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tfloat :: nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_single (Float32.of_bits (Int.repr 1065017672)) tfloat) ::
         nil))
      (Ssequence
        (Sset _t'12
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _forwardVel tfloat))
        (Sifthenelse (Ebinop Oge (Etempvar _t'12 tfloat)
                       (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                       tint)
          (Scall None
            (Evar _apply_slope_decel (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tfloat :: nil) tint cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_single (Float32.of_bits (Int.repr 1073741824)) tfloat) ::
             nil))
          (Sassign
            (Ederef
              (Ebinop Oadd
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _vel (tarray tfloat 3))
                (Econst_int (Int.repr 1) tint) (tptr tfloat)) tfloat)
            (Econst_single (Float32.of_bits (Int.repr 0)) tfloat))))))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _perform_ground_step (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      nil) tint cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
      (Sset _stepResult (Etempvar _t'1 tint)))
    (Ssequence
      (Sswitch (Etempvar _stepResult tuint)
        (LScons (Some 0)
          (Ssequence
            (Scall None
              (Evar _set_mario_action (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         tuint :: tuint :: nil) tuint
                                        cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _airAction tuint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            Sbreak)
          (LScons (Some 2)
            (Ssequence
              (Scall None
                (Evar _set_mario_animation (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              tint :: nil) tshort cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Econst_int (Int.repr 108) tint) :: nil))
              Sbreak)
            LSnil)))
      (Ssequence
        (Ssequence
          (Sset _t'9
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _forwardVel tfloat))
          (Sifthenelse (Ebinop Ogt (Etempvar _t'9 tfloat)
                         (Econst_single (Float32.of_bits (Int.repr 1098907648)) tfloat)
                         tint)
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
                    (Econst_int (Int.repr 0) tint) tint) tuint)))
            Sskip))
        (Ssequence
          (Scall None
            (Evar _set_mario_animation (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tint :: nil) tshort cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _animation tshort) :: nil))
          (Ssequence
            (Scall None
              (Evar _play_mario_landing_sound_once (Tfunction
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
            (Ssequence
              (Ssequence
                (Ssequence
                  (Sset _t'5
                    (Efield
                      (Ederef
                        (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                        (Tstruct _MarioState noattr)) _floor
                      (tptr (Tstruct _Surface noattr))))
                  (Ssequence
                    (Sset _t'6
                      (Efield
                        (Ederef
                          (Etempvar _t'5 (tptr (Tstruct _Surface noattr)))
                          (Tstruct _Surface noattr)) _type tshort))
                    (Sifthenelse (Ebinop Oge (Etempvar _t'6 tshort)
                                   (Econst_int (Int.repr 33) tint) tint)
                      (Ssequence
                        (Sset _t'7
                          (Efield
                            (Ederef
                              (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                              (Tstruct _MarioState noattr)) _floor
                            (tptr (Tstruct _Surface noattr))))
                        (Ssequence
                          (Sset _t'8
                            (Efield
                              (Ederef
                                (Etempvar _t'7 (tptr (Tstruct _Surface noattr)))
                                (Tstruct _Surface noattr)) _type tshort))
                          (Sset _t'2
                            (Ecast
                              (Ebinop Ole (Etempvar _t'8 tshort)
                                (Econst_int (Int.repr 39) tint) tint) tbool))))
                      (Sset _t'2 (Econst_int (Int.repr 0) tint)))))
                (Sifthenelse (Etempvar _t'2 tint)
                  (Ssequence
                    (Sset _t'3
                      (Efield
                        (Ederef
                          (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                          (Tstruct _MarioState noattr)) _quicksandDepth
                        tfloat))
                    (Ssequence
                      (Sset _t'4
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _actionTimer
                          tushort))
                      (Sassign
                        (Efield
                          (Ederef
                            (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                            (Tstruct _MarioState noattr)) _quicksandDepth
                          tfloat)
                        (Ebinop Oadd (Etempvar _t'3 tfloat)
                          (Ebinop Osub
                            (Ebinop Omul
                              (Ebinop Osub (Econst_int (Int.repr 4) tint)
                                (Etempvar _t'4 tushort) tint)
                              (Econst_single (Float32.of_bits (Int.repr 1080033280)) tfloat)
                              tfloat)
                            (Econst_single (Float32.of_bits (Int.repr 1056964608)) tfloat)
                            tfloat) tfloat))))
                  Sskip))
              (Sreturn (Some (Etempvar _stepResult tuint))))))))))
|}.

Definition f_common_landing_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_landingAction, (tptr (Tstruct _LandingAction noattr))) ::
                (_setAPressAction,
                 (tptr (Tfunction
                         ((tptr (Tstruct _MarioState noattr)) :: tuint ::
                          tuint :: nil) tint cc_default))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'8, tuint) :: (_t'7, tint) :: (_t'6, tushort) ::
               (_t'5, tuint) :: (_t'4, tuint) :: (_t'3, tint) ::
               (_t'2, tuint) :: (_t'1, tuint) :: (_t'22, tuint) ::
               (_t'21, tfloat) ::
               (_t'20, (tptr (Tstruct _Surface noattr))) ::
               (_t'19, tshort) :: (_t'18, tuint) :: (_t'17, tuint) ::
               (_t'16, tushort) :: (_t'15, tushort) :: (_t'14, tuint) ::
               (_t'13, tshort) :: (_t'12, tuint) :: (_t'11, tushort) ::
               (_t'10, tuint) :: (_t'9, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'20
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _floor
        (tptr (Tstruct _Surface noattr))))
    (Ssequence
      (Sset _t'21
        (Efield
          (Efield
            (Ederef (Etempvar _t'20 (tptr (Tstruct _Surface noattr)))
              (Tstruct _Surface noattr)) _normal (Tstruct __670 noattr)) _y
          tfloat))
      (Sifthenelse (Ebinop Olt (Etempvar _t'21 tfloat)
                     (Econst_single (Float32.of_bits (Int.repr 1049997758)) tfloat)
                     tint)
        (Ssequence
          (Ssequence
            (Sset _t'22
              (Efield
                (Ederef
                  (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                  (Tstruct _LandingAction noattr)) _verySteepAction tuint))
            (Scall (Some _t'1)
              (Evar _mario_push_off_steep_floor (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _t'22 tuint) :: (Econst_int (Int.repr 0) tint) ::
               nil)))
          (Sreturn (Some (Etempvar _t'1 tuint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Sset _t'19
        (Efield
          (Ederef
            (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
            (Tstruct _LandingAction noattr)) _unk02 tshort))
      (Sassign
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _doubleJumpTimer tuchar)
        (Etempvar _t'19 tshort)))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _should_begin_sliding (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Etempvar _t'3 tint)
          (Ssequence
            (Ssequence
              (Sset _t'18
                (Efield
                  (Ederef
                    (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                    (Tstruct _LandingAction noattr)) _slideAction tuint))
              (Scall (Some _t'2)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _t'18 tuint) :: (Econst_int (Int.repr 0) tint) ::
                 nil)))
            (Sreturn (Some (Etempvar _t'2 tuint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'16
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _input tushort))
          (Sifthenelse (Ebinop Oand (Etempvar _t'16 tushort)
                         (Econst_int (Int.repr 16) tint) tint)
            (Ssequence
              (Ssequence
                (Sset _t'17
                  (Efield
                    (Ederef
                      (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                      (Tstruct _LandingAction noattr)) _endAction tuint))
                (Scall (Some _t'4)
                  (Evar _set_mario_action (Tfunction
                                            ((tptr (Tstruct _MarioState noattr)) ::
                                             tuint :: tuint :: nil) tuint
                                            cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                   (Etempvar _t'17 tuint) ::
                   (Econst_int (Int.repr 0) tint) :: nil)))
              (Sreturn (Some (Etempvar _t'4 tuint))))
            Sskip))
        (Ssequence
          (Ssequence
            (Ssequence
              (Ssequence
                (Sset _t'15
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _actionTimer tushort))
                (Sset _t'6
                  (Ecast
                    (Ebinop Oadd (Etempvar _t'15 tushort)
                      (Econst_int (Int.repr 1) tint) tint) tushort)))
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _actionTimer tushort)
                (Etempvar _t'6 tushort)))
            (Ssequence
              (Sset _t'13
                (Efield
                  (Ederef
                    (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                    (Tstruct _LandingAction noattr)) _numFrames tshort))
              (Sifthenelse (Ebinop Oge (Etempvar _t'6 tushort)
                             (Etempvar _t'13 tshort) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'14
                      (Efield
                        (Ederef
                          (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                          (Tstruct _LandingAction noattr)) _endAction tuint))
                    (Scall (Some _t'5)
                      (Evar _set_mario_action (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 tuint :: tuint :: nil) tuint
                                                cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _t'14 tuint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Sreturn (Some (Etempvar _t'5 tuint))))
                Sskip)))
          (Ssequence
            (Ssequence
              (Sset _t'11
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sifthenelse (Ebinop Oand (Etempvar _t'11 tushort)
                             (Econst_int (Int.repr 2) tint) tint)
                (Ssequence
                  (Ssequence
                    (Sset _t'12
                      (Efield
                        (Ederef
                          (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                          (Tstruct _LandingAction noattr)) _aPressedAction
                        tuint))
                    (Scall (Some _t'7)
                      (Etempvar _setAPressAction (tptr (Tfunction
                                                         ((tptr (Tstruct _MarioState noattr)) ::
                                                          tuint :: tuint ::
                                                          nil) tint
                                                         cc_default)))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       (Etempvar _t'12 tuint) ::
                       (Econst_int (Int.repr 0) tint) :: nil)))
                  (Sreturn (Some (Etempvar _t'7 tint))))
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
                    (Ssequence
                      (Sset _t'10
                        (Efield
                          (Ederef
                            (Etempvar _landingAction (tptr (Tstruct _LandingAction noattr)))
                            (Tstruct _LandingAction noattr)) _offFloorAction
                          tuint))
                      (Scall (Some _t'8)
                        (Evar _set_mario_action (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   tuint :: tuint :: nil)
                                                  tuint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         (Etempvar _t'10 tuint) ::
                         (Econst_int (Int.repr 0) tint) :: nil)))
                    (Sreturn (Some (Etempvar _t'8 tuint))))
                  Sskip))
              (Sreturn (Some (Econst_int (Int.repr 0) tint))))))))))
|}.

Definition f_act_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _common_landing_cancels (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       (tptr (Tstruct _LandingAction noattr)) ::
                                       (tptr (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default)) :: nil) tint
                                      cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Eaddrof (Evar _sJumpLandAction (Tstruct _LandingAction noattr))
         (tptr (Tstruct _LandingAction noattr))) ::
       (Evar _set_jumping_action (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tint cc_default)) ::
       nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _common_landing_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tshort :: tuint :: nil) tuint
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 78) tint) ::
       (Econst_int (Int.repr 16779404) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_freefall_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _common_landing_cancels (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       (tptr (Tstruct _LandingAction noattr)) ::
                                       (tptr (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default)) :: nil) tint
                                      cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Eaddrof (Evar _sFreefallLandAction (Tstruct _LandingAction noattr))
         (tptr (Tstruct _LandingAction noattr))) ::
       (Evar _set_jumping_action (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tint cc_default)) ::
       nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _common_landing_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tshort :: tuint :: nil) tuint
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 87) tint) ::
       (Econst_int (Int.repr 16779404) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_side_flip_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tuint) :: (_t'1, tint) :: (_t'5, tshort) ::
               (_t'4, (tptr (Tstruct _Object noattr))) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _common_landing_cancels (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       (tptr (Tstruct _LandingAction noattr)) ::
                                       (tptr (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default)) :: nil) tint
                                      cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Eaddrof (Evar _sSideFlipLandAction (Tstruct _LandingAction noattr))
         (tptr (Tstruct _LandingAction noattr))) ::
       (Evar _set_jumping_action (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tuint :: tuint :: nil) tint cc_default)) ::
       nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _common_landing_action (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tshort :: tuint :: nil) tuint
                                       cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 190) tint) ::
         (Econst_int (Int.repr 16779404) tint) :: nil))
      (Sifthenelse (Ebinop One (Etempvar _t'2 tuint)
                     (Econst_int (Int.repr 2) tint) tint)
        (Ssequence
          (Sset _t'3
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _marioObj
              (tptr (Tstruct _Object noattr))))
          (Ssequence
            (Sset _t'4
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _marioObj
                (tptr (Tstruct _Object noattr))))
            (Ssequence
              (Sset _t'5
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
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort))
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
                      (tarray tshort 3)) (Econst_int (Int.repr 1) tint)
                    (tptr tshort)) tshort)
                (Ebinop Oadd (Etempvar _t'5 tshort)
                  (Econst_int (Int.repr 32768) tint) tint)))))
        Sskip))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_hold_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
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
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 201327152) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _common_landing_cancels (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _LandingAction noattr)) ::
                                         (tptr (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default)) :: nil) tint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eaddrof (Evar _sHoldJumpLandAction (Tstruct _LandingAction noattr))
           (tptr (Tstruct _LandingAction noattr))) ::
         (Evar _set_jumping_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tint cc_default)) ::
         nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _common_landing_action (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tshort :: tuint :: nil) tuint
                                       cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 64) tint) ::
         (Econst_int (Int.repr 16779425) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_hold_freefall_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
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
                       (Econst_int (Int.repr 3) tint) tint) tint)
        (Ssequence
          (Scall (Some _t'1)
            (Evar _drop_and_set_mario_action (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Econst_int (Int.repr 201327154) tint) ::
             (Econst_int (Int.repr 0) tint) :: nil))
          (Sreturn (Some (Etempvar _t'1 tint))))
        Sskip)))
  (Ssequence
    (Ssequence
      (Scall (Some _t'2)
        (Evar _common_landing_cancels (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _LandingAction noattr)) ::
                                         (tptr (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default)) :: nil) tint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eaddrof
           (Evar _sHoldFreefallLandAction (Tstruct _LandingAction noattr))
           (tptr (Tstruct _LandingAction noattr))) ::
         (Evar _set_jumping_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tint cc_default)) ::
         nil))
      (Sifthenelse (Etempvar _t'2 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Scall None
        (Evar _common_landing_action (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tshort :: tuint :: nil) tuint
                                       cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Econst_int (Int.repr 66) tint) ::
         (Econst_int (Int.repr 16779425) tint) :: nil))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_long_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'2, tint) :: (_t'1, tint) :: (_t'7, tushort) ::
               (_t'6, tushort) :: (_t'5, tushort) :: (_t'4, tint) ::
               (_t'3, (tptr (Tstruct _Object noattr))) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'6
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'6 tushort)
                     (Econst_int (Int.repr 16384) tint) tint) tint)
      (Ssequence
        (Sset _t'7
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort)
          (Ebinop Oand (Etempvar _t'7 tushort)
            (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _common_landing_cancels (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _LandingAction noattr)) ::
                                         (tptr (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default)) :: nil) tint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eaddrof (Evar _sLongJumpLandAction (Tstruct _LandingAction noattr))
           (tptr (Tstruct _LandingAction noattr))) ::
         (Evar _set_jumping_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tint cc_default)) ::
         nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'5
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'5 tushort)
                         (Econst_int (Int.repr 1) tint) tint) tint)
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
                       (Ecast (Econst_int (Int.repr 19) tint) tuint)
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
                        (Ederef
                          (Etempvar _t'3 (tptr (Tstruct _Object noattr)))
                          (Tstruct _Object noattr)) _rawData
                        (Tunion __665 noattr)) _asS32 (tarray tint 80))
                    (Econst_int (Int.repr 34) tint) (tptr tint)) tint))
              (Sifthenelse (Eunop Onotbool (Etempvar _t'4 tint) tint)
                (Sset _t'2 (Ecast (Econst_int (Int.repr 17) tint) tint))
                (Sset _t'2 (Ecast (Econst_int (Int.repr 18) tint) tint)))))
          (Scall None
            (Evar _common_landing_action (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tshort :: tuint :: nil) tuint
                                           cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _t'2 tint) :: (Econst_int (Int.repr 16779404) tint) ::
             nil)))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_double_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _common_landing_cancels (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       (tptr (Tstruct _LandingAction noattr)) ::
                                       (tptr (Tfunction
                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                tuint :: tuint :: nil) tint
                                               cc_default)) :: nil) tint
                                      cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Eaddrof (Evar _sDoubleJumpLandAction (Tstruct _LandingAction noattr))
         (tptr (Tstruct _LandingAction noattr))) ::
       (Evar _set_triple_jump_action (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tuint :: tuint :: nil) tint
                                       cc_default)) :: nil))
    (Sifthenelse (Etempvar _t'1 tint)
      (Sreturn (Some (Econst_int (Int.repr 1) tint)))
      Sskip))
  (Ssequence
    (Scall None
      (Evar _common_landing_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tshort :: tuint :: nil) tuint
                                     cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 75) tint) ::
       (Econst_int (Int.repr 16779404) tint) :: nil))
    (Sreturn (Some (Econst_int (Int.repr 0) tint)))))
|}.

Definition f_act_triple_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'3, tushort) :: (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
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
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _common_landing_cancels (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _LandingAction noattr)) ::
                                         (tptr (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default)) :: nil) tint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eaddrof
           (Evar _sTripleJumpLandAction (Tstruct _LandingAction noattr))
           (tptr (Tstruct _LandingAction noattr))) ::
         (Evar _set_jumping_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tint cc_default)) ::
         nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'2 tushort)
                         (Econst_int (Int.repr 1) tint) tint) tint)
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
                       (Ecast (Econst_int (Int.repr 17) tint) tuint)
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
          (Evar _common_landing_action (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tshort :: tuint :: nil) tuint
                                         cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 192) tint) ::
           (Econst_int (Int.repr 16779404) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_act_backflip_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'1, tint) :: (_t'4, tushort) :: (_t'3, tushort) ::
               (_t'2, tushort) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Sset _t'3
      (Efield
        (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
          (Tstruct _MarioState noattr)) _input tushort))
    (Sifthenelse (Eunop Onotbool
                   (Ebinop Oand (Etempvar _t'3 tushort)
                     (Econst_int (Int.repr 16384) tint) tint) tint)
      (Ssequence
        (Sset _t'4
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sassign
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort)
          (Ebinop Oand (Etempvar _t'4 tushort)
            (Eunop Onotint (Econst_int (Int.repr 2) tint) tint) tint)))
      Sskip))
  (Ssequence
    (Ssequence
      (Scall (Some _t'1)
        (Evar _common_landing_cancels (Tfunction
                                        ((tptr (Tstruct _MarioState noattr)) ::
                                         (tptr (Tstruct _LandingAction noattr)) ::
                                         (tptr (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default)) :: nil) tint
                                        cc_default))
        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
         (Eaddrof (Evar _sBackflipLandAction (Tstruct _LandingAction noattr))
           (tptr (Tstruct _LandingAction noattr))) ::
         (Evar _set_jumping_action (Tfunction
                                     ((tptr (Tstruct _MarioState noattr)) ::
                                      tuint :: tuint :: nil) tint cc_default)) ::
         nil))
      (Sifthenelse (Etempvar _t'1 tint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'2
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'2 tushort)
                         (Econst_int (Int.repr 1) tint) tint) tint)
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
                       (Ecast (Econst_int (Int.repr 17) tint) tuint)
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
          (Evar _common_landing_action (Tfunction
                                         ((tptr (Tstruct _MarioState noattr)) ::
                                          tshort :: tuint :: nil) tuint
                                         cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Econst_int (Int.repr 192) tint) ::
           (Econst_int (Int.repr 16779404) tint) :: nil))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_quicksand_jump_land_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) ::
                (_animation1, tint) :: (_animation2, tint) ::
                (_endAction, tuint) :: (_airAction, tuint) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'3, tint) :: (_t'2, tushort) :: (_t'1, tuint) ::
               (_t'7, tushort) :: (_t'6, tfloat) :: (_t'5, tfloat) ::
               (_t'4, tushort) :: nil);
  fn_body :=
(Ssequence
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
        (Ebinop Oadd (Etempvar _t'2 tushort) (Econst_int (Int.repr 1) tint)
          tint)))
    (Sifthenelse (Ebinop Olt (Etempvar _t'2 tushort)
                   (Econst_int (Int.repr 6) tint) tint)
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
          (Ssequence
            (Sset _t'7
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _actionTimer tushort))
            (Sassign
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
              (Ebinop Osub (Etempvar _t'6 tfloat)
                (Ebinop Omul
                  (Ebinop Osub (Econst_int (Int.repr 7) tint)
                    (Etempvar _t'7 tushort) tint)
                  (Econst_single (Float32.of_bits (Int.repr 1061997773)) tfloat)
                  tfloat) tfloat))))
        (Ssequence
          (Ssequence
            (Sset _t'5
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _quicksandDepth tfloat))
            (Sifthenelse (Ebinop Olt (Etempvar _t'5 tfloat)
                           (Econst_single (Float32.of_bits (Int.repr 1065353216)) tfloat)
                           tint)
              (Sassign
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _quicksandDepth tfloat)
                (Econst_single (Float32.of_bits (Int.repr 1066192077)) tfloat))
              Sskip))
          (Ssequence
            (Scall None
              (Evar _play_mario_jump_sound (Tfunction
                                             ((tptr (Tstruct _MarioState noattr)) ::
                                              nil) tvoid cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
            (Scall None
              (Evar _set_mario_animation (Tfunction
                                           ((tptr (Tstruct _MarioState noattr)) ::
                                            tint :: nil) tshort cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Etempvar _animation1 tint) :: nil)))))
      (Ssequence
        (Ssequence
          (Sset _t'4
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _actionTimer tushort))
          (Sifthenelse (Ebinop Oge (Etempvar _t'4 tushort)
                         (Econst_int (Int.repr 13) tint) tint)
            (Ssequence
              (Scall (Some _t'1)
                (Evar _set_mario_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tuint :: tuint :: nil) tuint
                                          cc_default))
                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                 (Etempvar _endAction tuint) ::
                 (Econst_int (Int.repr 0) tint) :: nil))
              (Sreturn (Some (Etempvar _t'1 tuint))))
            Sskip))
        (Scall None
          (Evar _set_mario_animation (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        tint :: nil) tshort cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
           (Etempvar _animation2 tint) :: nil)))))
  (Ssequence
    (Scall None
      (Evar _apply_landing_accel (Tfunction
                                   ((tptr (Tstruct _MarioState noattr)) ::
                                    tfloat :: nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_single (Float32.of_bits (Int.repr 1064514355)) tfloat) :: nil))
    (Ssequence
      (Ssequence
        (Scall (Some _t'3)
          (Evar _perform_ground_step (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
        (Sifthenelse (Ebinop Oeq (Etempvar _t'3 tint)
                       (Econst_int (Int.repr 0) tint) tint)
          (Scall None
            (Evar _set_mario_action (Tfunction
                                      ((tptr (Tstruct _MarioState noattr)) ::
                                       tuint :: tuint :: nil) tuint
                                      cc_default))
            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
             (Etempvar _airAction tuint) :: (Econst_int (Int.repr 0) tint) ::
             nil))
          Sskip))
      (Sreturn (Some (Econst_int (Int.repr 0) tint))))))
|}.

Definition f_act_quicksand_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _quicksand_jump_land_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tint :: tint :: tuint :: tuint ::
                                           nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 77) tint) :: (Econst_int (Int.repr 78) tint) ::
       (Econst_int (Int.repr 201327152) tint) ::
       (Econst_int (Int.repr 16779404) tint) :: nil))
    (Sset _cancel (Etempvar _t'1 tint)))
  (Sreturn (Some (Etempvar _cancel tint))))
|}.

Definition f_act_hold_quicksand_jump_land := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'1, tint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _quicksand_jump_land_action (Tfunction
                                          ((tptr (Tstruct _MarioState noattr)) ::
                                           tint :: tint :: tuint :: tuint ::
                                           nil) tint cc_default))
      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
       (Econst_int (Int.repr 65) tint) :: (Econst_int (Int.repr 64) tint) ::
       (Econst_int (Int.repr 134218292) tint) ::
       (Econst_int (Int.repr 16779425) tint) :: nil))
    (Sset _cancel (Etempvar _t'1 tint)))
  (Sreturn (Some (Etempvar _cancel tint))))
|}.

Definition f_check_common_moving_cancels := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_t'5, tint) :: (_t'4, tint) :: (_t'3, tint) ::
               (_t'2, tint) :: (_t'1, tint) :: (_t'12, tshort) ::
               (_t'11, tfloat) :: (_t'10, tushort) :: (_t'9, tuint) ::
               (_t'8, tushort) :: (_t'7, tshort) :: (_t'6, tuint) :: nil);
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
    (Ssequence
      (Sset _t'12
        (Efield
          (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
            (Tstruct _MarioState noattr)) _waterLevel tshort))
      (Sifthenelse (Ebinop Olt (Etempvar _t'11 tfloat)
                     (Ebinop Osub (Etempvar _t'12 tshort)
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
      (Ssequence
        (Sset _t'9
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sifthenelse (Eunop Onotbool
                       (Ebinop Oand (Etempvar _t'9 tuint)
                         (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                           (Econst_int (Int.repr 17) tint) tint) tuint) tint)
          (Ssequence
            (Sset _t'10
              (Efield
                (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                  (Tstruct _MarioState noattr)) _input tushort))
            (Sset _t'3
              (Ecast
                (Ebinop Oand (Etempvar _t'10 tushort)
                  (Econst_int (Int.repr 1024) tint) tint) tbool)))
          (Sset _t'3 (Econst_int (Int.repr 0) tint))))
      (Sifthenelse (Etempvar _t'3 tint)
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
        (Sset _t'8
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _input tushort))
        (Sifthenelse (Ebinop Oand (Etempvar _t'8 tushort)
                       (Econst_int (Int.repr 64) tint) tint)
          (Ssequence
            (Scall (Some _t'4)
              (Evar _drop_and_set_mario_action (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  tuint :: tuint :: nil) tint
                                                 cc_default))
              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
               (Econst_int (Int.repr 131897) tint) ::
               (Econst_int (Int.repr 0) tint) :: nil))
            (Sreturn (Some (Etempvar _t'4 tint))))
          Sskip))
      (Ssequence
        (Ssequence
          (Sset _t'6
            (Efield
              (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                (Tstruct _MarioState noattr)) _action tuint))
          (Sifthenelse (Eunop Onotbool
                         (Ebinop Oand (Etempvar _t'6 tuint)
                           (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                             (Econst_int (Int.repr 17) tint) tint) tuint)
                         tint)
            (Ssequence
              (Sset _t'7
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _health tshort))
              (Sifthenelse (Ebinop Olt (Etempvar _t'7 tshort)
                             (Econst_int (Int.repr 256) tint) tint)
                (Ssequence
                  (Scall (Some _t'5)
                    (Evar _drop_and_set_mario_action (Tfunction
                                                       ((tptr (Tstruct _MarioState noattr)) ::
                                                        tuint :: tuint ::
                                                        nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     (Econst_int (Int.repr 135953) tint) ::
                     (Econst_int (Int.repr 0) tint) :: nil))
                  (Sreturn (Some (Etempvar _t'5 tint))))
                Sskip))
            Sskip))
        (Sreturn (Some (Econst_int (Int.repr 0) tint)))))))
|}.

Definition f_mario_execute_moving_action := {|
  fn_return := tint;
  fn_callconv := cc_default;
  fn_params := ((_m, (tptr (Tstruct _MarioState noattr))) :: nil);
  fn_vars := nil;
  fn_temps := ((_cancel, tint) :: (_t'41, tint) :: (_t'40, tint) ::
               (_t'39, tint) :: (_t'38, tint) :: (_t'37, tint) ::
               (_t'36, tint) :: (_t'35, tint) :: (_t'34, tint) ::
               (_t'33, tint) :: (_t'32, tint) :: (_t'31, tint) ::
               (_t'30, tint) :: (_t'29, tint) :: (_t'28, tint) ::
               (_t'27, tint) :: (_t'26, tint) :: (_t'25, tint) ::
               (_t'24, tint) :: (_t'23, tint) :: (_t'22, tint) ::
               (_t'21, tint) :: (_t'20, tint) :: (_t'19, tint) ::
               (_t'18, tint) :: (_t'17, tint) :: (_t'16, tint) ::
               (_t'15, tint) :: (_t'14, tint) :: (_t'13, tint) ::
               (_t'12, tint) :: (_t'11, tint) :: (_t'10, tint) ::
               (_t'9, tint) :: (_t'8, tint) :: (_t'7, tint) ::
               (_t'6, tint) :: (_t'5, tint) :: (_t'4, tint) ::
               (_t'3, tint) :: (_t'2, tuint) :: (_t'1, tint) ::
               (_t'45, tuint) :: (_t'44, tushort) :: (_t'43, tuint) ::
               (_t'42, tuint) :: nil);
  fn_body :=
(Ssequence
  (Ssequence
    (Scall (Some _t'1)
      (Evar _check_common_moving_cancels (Tfunction
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
         (Econst_single (Float32.of_bits (Int.repr 1048576000)) tfloat) ::
         nil))
      (Sifthenelse (Etempvar _t'2 tuint)
        (Sreturn (Some (Econst_int (Int.repr 1) tint)))
        Sskip))
    (Ssequence
      (Ssequence
        (Sset _t'45
          (Efield
            (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
              (Tstruct _MarioState noattr)) _action tuint))
        (Sswitch (Etempvar _t'45 tuint)
          (LScons (Some 67109952)
            (Ssequence
              (Ssequence
                (Scall (Some _t'3)
                  (Evar _act_walking (Tfunction
                                       ((tptr (Tstruct _MarioState noattr)) ::
                                        nil) tint cc_default))
                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) :: nil))
                (Sset _cancel (Etempvar _t'3 tint)))
              Sbreak)
            (LScons (Some 1090)
              (Ssequence
                (Ssequence
                  (Scall (Some _t'4)
                    (Evar _act_hold_walking (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                     nil))
                  (Sset _cancel (Etempvar _t'4 tint)))
                Sbreak)
              (LScons (Some 1095)
                (Ssequence
                  (Ssequence
                    (Scall (Some _t'5)
                      (Evar _act_hold_heavy_walking (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                       nil))
                    (Sset _cancel (Etempvar _t'5 tint)))
                  Sbreak)
                (LScons (Some 1091)
                  (Ssequence
                    (Ssequence
                      (Scall (Some _t'6)
                        (Evar _act_turning_around (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                         nil))
                      (Sset _cancel (Etempvar _t'6 tint)))
                    Sbreak)
                  (LScons (Some 1092)
                    (Ssequence
                      (Ssequence
                        (Scall (Some _t'7)
                          (Evar _act_finish_turning_around (Tfunction
                                                             ((tptr (Tstruct _MarioState noattr)) ::
                                                              nil) tint
                                                             cc_default))
                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                           nil))
                        (Sset _cancel (Etempvar _t'7 tint)))
                      Sbreak)
                    (LScons (Some 67109957)
                      (Ssequence
                        (Ssequence
                          (Scall (Some _t'8)
                            (Evar _act_braking (Tfunction
                                                 ((tptr (Tstruct _MarioState noattr)) ::
                                                  nil) tint cc_default))
                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                             nil))
                          (Sset _cancel (Etempvar _t'8 tint)))
                        Sbreak)
                      (LScons (Some 545326150)
                        (Ssequence
                          (Ssequence
                            (Scall (Some _t'9)
                              (Evar _act_riding_shell_ground (Tfunction
                                                               ((tptr (Tstruct _MarioState noattr)) ::
                                                                nil) tint
                                                               cc_default))
                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                               nil))
                            (Sset _cancel (Etempvar _t'9 tint)))
                          Sbreak)
                        (LScons (Some 67142728)
                          (Ssequence
                            (Ssequence
                              (Scall (Some _t'10)
                                (Evar _act_crawling (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                 nil))
                              (Sset _cancel (Etempvar _t'10 tint)))
                            Sbreak)
                          (LScons (Some 132169)
                            (Ssequence
                              (Ssequence
                                (Scall (Some _t'11)
                                  (Evar _act_burning_ground (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                   nil))
                                (Sset _cancel (Etempvar _t'11 tint)))
                              Sbreak)
                            (LScons (Some 67109962)
                              (Ssequence
                                (Ssequence
                                  (Scall (Some _t'12)
                                    (Evar _act_decelerating (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                     nil))
                                  (Sset _cancel (Etempvar _t'12 tint)))
                                Sbreak)
                              (LScons (Some 1099)
                                (Ssequence
                                  (Ssequence
                                    (Scall (Some _t'13)
                                      (Evar _act_hold_decelerating (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                       nil))
                                    (Sset _cancel (Etempvar _t'13 tint)))
                                  Sbreak)
                                (LScons (Some 8651858)
                                  (Ssequence
                                    (Ssequence
                                      (Scall (Some _t'14)
                                        (Evar _act_butt_slide (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                         nil))
                                      (Sset _cancel (Etempvar _t'14 tint)))
                                    Sbreak)
                                  (LScons (Some 9176147)
                                    (Ssequence
                                      (Ssequence
                                        (Scall (Some _t'15)
                                          (Evar _act_stomach_slide (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                           nil))
                                        (Sset _cancel (Etempvar _t'15 tint)))
                                      Sbreak)
                                    (LScons (Some 8651860)
                                      (Ssequence
                                        (Ssequence
                                          (Scall (Some _t'16)
                                            (Evar _act_hold_butt_slide 
                                            (Tfunction
                                              ((tptr (Tstruct _MarioState noattr)) ::
                                               nil) tint cc_default))
                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                             nil))
                                          (Sset _cancel
                                            (Etempvar _t'16 tint)))
                                        Sbreak)
                                      (LScons (Some 9176149)
                                        (Ssequence
                                          (Ssequence
                                            (Scall (Some _t'17)
                                              (Evar _act_hold_stomach_slide 
                                              (Tfunction
                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                 nil) tint cc_default))
                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                               nil))
                                            (Sset _cancel
                                              (Etempvar _t'17 tint)))
                                          Sbreak)
                                        (LScons (Some 8914006)
                                          (Ssequence
                                            (Ssequence
                                              (Scall (Some _t'18)
                                                (Evar _act_dive_slide 
                                                (Tfunction
                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                   nil) tint cc_default))
                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                 nil))
                                              (Sset _cancel
                                                (Etempvar _t'18 tint)))
                                            Sbreak)
                                          (LScons (Some 8389719)
                                            (Ssequence
                                              (Ssequence
                                                (Scall (Some _t'19)
                                                  (Evar _act_move_punching 
                                                  (Tfunction
                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                     nil) tint cc_default))
                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                   nil))
                                                (Sset _cancel
                                                  (Etempvar _t'19 tint)))
                                              Sbreak)
                                            (LScons (Some 75531353)
                                              (Ssequence
                                                (Ssequence
                                                  (Scall (Some _t'20)
                                                    (Evar _act_crouch_slide 
                                                    (Tfunction
                                                      ((tptr (Tstruct _MarioState noattr)) ::
                                                       nil) tint cc_default))
                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                     nil))
                                                  (Sset _cancel
                                                    (Etempvar _t'20 tint)))
                                                Sbreak)
                                              (LScons (Some 8389722)
                                                (Ssequence
                                                  (Ssequence
                                                    (Scall (Some _t'21)
                                                      (Evar _act_slide_kick_slide 
                                                      (Tfunction
                                                        ((tptr (Tstruct _MarioState noattr)) ::
                                                         nil) tint
                                                        cc_default))
                                                      ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                       nil))
                                                    (Sset _cancel
                                                      (Etempvar _t'21 tint)))
                                                  Sbreak)
                                                (LScons (Some 132192)
                                                  (Ssequence
                                                    (Ssequence
                                                      (Scall (Some _t'22)
                                                        (Evar _act_hard_backward_ground_kb 
                                                        (Tfunction
                                                          ((tptr (Tstruct _MarioState noattr)) ::
                                                           nil) tint
                                                          cc_default))
                                                        ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                         nil))
                                                      (Sset _cancel
                                                        (Etempvar _t'22 tint)))
                                                    Sbreak)
                                                  (LScons (Some 132193)
                                                    (Ssequence
                                                      (Ssequence
                                                        (Scall (Some _t'23)
                                                          (Evar _act_hard_forward_ground_kb 
                                                          (Tfunction
                                                            ((tptr (Tstruct _MarioState noattr)) ::
                                                             nil) tint
                                                            cc_default))
                                                          ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                           nil))
                                                        (Sset _cancel
                                                          (Etempvar _t'23 tint)))
                                                      Sbreak)
                                                    (LScons (Some 132194)
                                                      (Ssequence
                                                        (Ssequence
                                                          (Scall (Some _t'24)
                                                            (Evar _act_backward_ground_kb 
                                                            (Tfunction
                                                              ((tptr (Tstruct _MarioState noattr)) ::
                                                               nil) tint
                                                              cc_default))
                                                            ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                             nil))
                                                          (Sset _cancel
                                                            (Etempvar _t'24 tint)))
                                                        Sbreak)
                                                      (LScons (Some 132195)
                                                        (Ssequence
                                                          (Ssequence
                                                            (Scall (Some _t'25)
                                                              (Evar _act_forward_ground_kb 
                                                              (Tfunction
                                                                ((tptr (Tstruct _MarioState noattr)) ::
                                                                 nil) tint
                                                                cc_default))
                                                              ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                               nil))
                                                            (Sset _cancel
                                                              (Etempvar _t'25 tint)))
                                                          Sbreak)
                                                        (LScons (Some 132196)
                                                          (Ssequence
                                                            (Ssequence
                                                              (Scall (Some _t'26)
                                                                (Evar _act_soft_backward_ground_kb 
                                                                (Tfunction
                                                                  ((tptr (Tstruct _MarioState noattr)) ::
                                                                   nil) tint
                                                                  cc_default))
                                                                ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                 nil))
                                                              (Sset _cancel
                                                                (Etempvar _t'26 tint)))
                                                            Sbreak)
                                                          (LScons (Some 132197)
                                                            (Ssequence
                                                              (Ssequence
                                                                (Scall (Some _t'27)
                                                                  (Evar _act_soft_forward_ground_kb 
                                                                  (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                  ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                   nil))
                                                                (Sset _cancel
                                                                  (Etempvar _t'27 tint)))
                                                              Sbreak)
                                                            (LScons (Some 132198)
                                                              (Ssequence
                                                                (Ssequence
                                                                  (Scall (Some _t'28)
                                                                    (Evar _act_ground_bonk 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                  (Sset _cancel
                                                                    (Etempvar _t'28 tint)))
                                                                Sbreak)
                                                              (LScons (Some 132199)
                                                                (Ssequence
                                                                  (Ssequence
                                                                    (Scall (Some _t'29)
                                                                    (Evar _act_death_exit_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'29 tint)))
                                                                  Sbreak)
                                                                (LScons (Some 67110000)
                                                                  (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'30)
                                                                    (Evar _act_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'30 tint)))
                                                                    Sbreak)
                                                                  (LScons (Some 67110001)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'31)
                                                                    (Evar _act_freefall_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'31 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 67110002)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'32)
                                                                    (Evar _act_double_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'32 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 67110003)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'33)
                                                                    (Evar _act_side_flip_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'33 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1140)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'34)
                                                                    (Evar _act_hold_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'34 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1141)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'35)
                                                                    (Evar _act_hold_freefall_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'35 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 67110008)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'36)
                                                                    (Evar _act_triple_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'36 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 67110010)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'37)
                                                                    (Evar _act_backflip_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'37 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1142)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'38)
                                                                    (Evar _act_quicksand_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'38 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1143)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'39)
                                                                    (Evar _act_hold_quicksand_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'39 tint)))
                                                                    Sbreak)
                                                                    (LScons (Some 1145)
                                                                    (Ssequence
                                                                    (Ssequence
                                                                    (Scall (Some _t'40)
                                                                    (Evar _act_long_jump_land 
                                                                    (Tfunction
                                                                    ((tptr (Tstruct _MarioState noattr)) ::
                                                                    nil) tint
                                                                    cc_default))
                                                                    ((Etempvar _m (tptr (Tstruct _MarioState noattr))) ::
                                                                    nil))
                                                                    (Sset _cancel
                                                                    (Etempvar _t'40 tint)))
                                                                    Sbreak)
                                                                    LSnil))))))))))))))))))))))))))))))))))))))))
      (Ssequence
        (Ssequence
          (Sifthenelse (Eunop Onotbool (Etempvar _cancel tint) tint)
            (Ssequence
              (Sset _t'44
                (Efield
                  (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                    (Tstruct _MarioState noattr)) _input tushort))
              (Sset _t'41
                (Ecast
                  (Ebinop Oand (Etempvar _t'44 tushort)
                    (Econst_int (Int.repr 512) tint) tint) tbool)))
            (Sset _t'41 (Econst_int (Int.repr 0) tint)))
          (Sifthenelse (Etempvar _t'41 tint)
            (Ssequence
              (Ssequence
                (Sset _t'43
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint)
                  (Ebinop Oor (Etempvar _t'43 tuint)
                    (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                      (Econst_int (Int.repr 10) tint) tint) tuint)))
              (Ssequence
                (Sset _t'42
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint))
                (Sassign
                  (Efield
                    (Ederef (Etempvar _m (tptr (Tstruct _MarioState noattr)))
                      (Tstruct _MarioState noattr)) _particleFlags tuint)
                  (Ebinop Oand (Etempvar _t'42 tuint)
                    (Eunop Onotint
                      (Ebinop Oshl (Econst_int (Int.repr 1) tint)
                        (Econst_int (Int.repr 0) tint) tint) tint) tuint))))
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
 Composite _WallCollisionData Struct
   (Member_plain _x tfloat :: Member_plain _y tfloat ::
    Member_plain _z tfloat :: Member_plain _offsetY tfloat ::
    Member_plain _radius tfloat :: Member_plain _filler (tarray tuchar 2) ::
    Member_plain _numWalls tshort ::
    Member_plain _walls (tarray (tptr (Tstruct _Surface noattr)) 4) :: nil)
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
 Composite _LandingAction Struct
   (Member_plain _numFrames tshort :: Member_plain _unk02 tshort ::
    Member_plain _verySteepAction tuint :: Member_plain _endAction tuint ::
    Member_plain _aPressedAction tuint ::
    Member_plain _offFloorAction tuint :: Member_plain _slideAction tuint ::
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
 (_play_mario_jump_sound,
   Gfun(External (EF_external "play_mario_jump_sound"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_adjust_sound_for_speed,
   Gfun(External (EF_external "adjust_sound_for_speed"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_play_sound_and_spawn_particles,
   Gfun(External (EF_external "play_sound_and_spawn_particles"
                   (mksignature (AST.Xptr :: AST.Xint :: AST.Xint :: nil)
                     AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: tuint :: nil) tvoid
     cc_default)) ::
 (_play_mario_landing_sound,
   Gfun(External (EF_external "play_mario_landing_sound"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_landing_sound_once,
   Gfun(External (EF_external "play_mario_landing_sound_once"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_play_mario_heavy_landing_sound_once,
   Gfun(External (EF_external "play_mario_heavy_landing_sound_once"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
 (_mario_set_forward_vel,
   Gfun(External (EF_external "mario_set_forward_vel"
                   (mksignature (AST.Xptr :: AST.Xsingle :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tfloat :: nil) tvoid
     cc_default)) ::
 (_mario_get_floor_class,
   Gfun(External (EF_external "mario_get_floor_class"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_mario_facing_downhill,
   Gfun(External (EF_external "mario_facing_downhill"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xint
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tint :: nil) tint cc_default)) ::
 (_mario_floor_is_slippery,
   Gfun(External (EF_external "mario_floor_is_slippery"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_mario_floor_is_slope,
   Gfun(External (EF_external "mario_floor_is_slope"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
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
 (_check_common_action_exits,
   Gfun(External (EF_external "check_common_action_exits"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_set_water_plunge_action,
   Gfun(External (EF_external "set_water_plunge_action"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
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
 (_mtxf_align_terrain_triangle,
   Gfun(External (EF_external "mtxf_align_terrain_triangle"
                   (mksignature
                     (AST.Xptr :: AST.Xptr :: AST.Xint16signed ::
                      AST.Xsingle :: nil) AST.Xvoid cc_default))
     ((tptr (tarray tfloat 4)) :: (tptr tfloat) :: tshort :: tfloat :: nil)
     tvoid cc_default)) ::
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
 (_find_wall_collisions,
   Gfun(External (EF_external "find_wall_collisions"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _WallCollisionData noattr)) :: nil) tint cc_default)) ::
 (_find_floor,
   Gfun(External (EF_external "find_floor"
                   (mksignature
                     (AST.Xsingle :: AST.Xsingle :: AST.Xsingle ::
                      AST.Xptr :: nil) AST.Xsingle cc_default))
     (tfloat :: tfloat :: tfloat ::
      (tptr (tptr (Tstruct _Surface noattr))) :: nil) tfloat cc_default)) ::
 (_gWaterSurfacePseudoFloor, Gvar v_gWaterSurfacePseudoFloor) ::
 (_mario_bonk_reflection,
   Gfun(External (EF_external "mario_bonk_reflection"
                   (mksignature (AST.Xptr :: AST.Xint :: nil) AST.Xvoid
                     cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: tuint :: nil) tvoid cc_default)) ::
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
 (_mario_update_moving_sand,
   Gfun(External (EF_external "mario_update_moving_sand"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_mario_update_windy_ground,
   Gfun(External (EF_external "mario_update_windy_ground"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_perform_ground_step,
   Gfun(External (EF_external "perform_ground_step"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_segmented_to_virtual,
   Gfun(External (EF_external "segmented_to_virtual"
                   (mksignature (AST.Xptr :: nil) AST.Xptr cc_default))
     ((tptr tvoid) :: nil) (tptr tvoid) cc_default)) ::
 (_mario_stop_riding_object,
   Gfun(External (EF_external "mario_stop_riding_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_grab_used_object,
   Gfun(External (EF_external "mario_grab_used_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_drop_held_object,
   Gfun(External (EF_external "mario_drop_held_object"
                   (mksignature (AST.Xptr :: nil) AST.Xvoid cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tvoid cc_default)) ::
 (_mario_check_object_grab,
   Gfun(External (EF_external "mario_check_object_grab"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tuint cc_default)) ::
 (_mario_update_punch_sequence,
   Gfun(External (EF_external "mario_update_punch_sequence"
                   (mksignature (AST.Xptr :: nil) AST.Xint cc_default))
     ((tptr (Tstruct _MarioState noattr)) :: nil) tint cc_default)) ::
 (_bhvJumpingBox, Gvar v_bhvJumpingBox) ::
 (_sJumpLandAction, Gvar v_sJumpLandAction) ::
 (_sFreefallLandAction, Gvar v_sFreefallLandAction) ::
 (_sSideFlipLandAction, Gvar v_sSideFlipLandAction) ::
 (_sHoldJumpLandAction, Gvar v_sHoldJumpLandAction) ::
 (_sHoldFreefallLandAction, Gvar v_sHoldFreefallLandAction) ::
 (_sLongJumpLandAction, Gvar v_sLongJumpLandAction) ::
 (_sDoubleJumpLandAction, Gvar v_sDoubleJumpLandAction) ::
 (_sTripleJumpLandAction, Gvar v_sTripleJumpLandAction) ::
 (_sBackflipLandAction, Gvar v_sBackflipLandAction) ::
 (_sFloorAlignMatrix, Gvar v_sFloorAlignMatrix) ::
 (_tilt_body_running, Gfun(Internal f_tilt_body_running)) ::
 (_play_step_sound, Gfun(Internal f_play_step_sound)) ::
 (_align_with_floor, Gfun(Internal f_align_with_floor)) ::
 (_begin_walking_action, Gfun(Internal f_begin_walking_action)) ::
 (_check_ledge_climb_down, Gfun(Internal f_check_ledge_climb_down)) ::
 (_slide_bonk, Gfun(Internal f_slide_bonk)) ::
 (_set_triple_jump_action, Gfun(Internal f_set_triple_jump_action)) ::
 (_update_sliding_angle, Gfun(Internal f_update_sliding_angle)) ::
 (_update_sliding, Gfun(Internal f_update_sliding)) ::
 (_apply_slope_accel, Gfun(Internal f_apply_slope_accel)) ::
 (_apply_landing_accel, Gfun(Internal f_apply_landing_accel)) ::
 (_update_shell_speed, Gfun(Internal f_update_shell_speed)) ::
 (_apply_slope_decel, Gfun(Internal f_apply_slope_decel)) ::
 (_update_decelerating_speed, Gfun(Internal f_update_decelerating_speed)) ::
 (_update_walking_speed, Gfun(Internal f_update_walking_speed)) ::
 (_should_begin_sliding, Gfun(Internal f_should_begin_sliding)) ::
 (_analog_stick_held_back, Gfun(Internal f_analog_stick_held_back)) ::
 (_check_ground_dive_or_punch, Gfun(Internal f_check_ground_dive_or_punch)) ::
 (_begin_braking_action, Gfun(Internal f_begin_braking_action)) ::
 (_anim_and_audio_for_walk, Gfun(Internal f_anim_and_audio_for_walk)) ::
 (_anim_and_audio_for_hold_walk, Gfun(Internal f_anim_and_audio_for_hold_walk)) ::
 (_anim_and_audio_for_heavy_walk, Gfun(Internal f_anim_and_audio_for_heavy_walk)) ::
 (_push_or_sidle_wall, Gfun(Internal f_push_or_sidle_wall)) ::
 (_tilt_body_walking, Gfun(Internal f_tilt_body_walking)) ::
 (_tilt_body_ground_shell, Gfun(Internal f_tilt_body_ground_shell)) ::
 (_act_walking, Gfun(Internal f_act_walking)) ::
 (_act_move_punching, Gfun(Internal f_act_move_punching)) ::
 (_act_hold_walking, Gfun(Internal f_act_hold_walking)) ::
 (_act_hold_heavy_walking, Gfun(Internal f_act_hold_heavy_walking)) ::
 (_act_turning_around, Gfun(Internal f_act_turning_around)) ::
 (_act_finish_turning_around, Gfun(Internal f_act_finish_turning_around)) ::
 (_act_braking, Gfun(Internal f_act_braking)) ::
 (_act_decelerating, Gfun(Internal f_act_decelerating)) ::
 (_act_hold_decelerating, Gfun(Internal f_act_hold_decelerating)) ::
 (_act_riding_shell_ground, Gfun(Internal f_act_riding_shell_ground)) ::
 (_act_crawling, Gfun(Internal f_act_crawling)) ::
 (_act_burning_ground, Gfun(Internal f_act_burning_ground)) ::
 (_tilt_body_butt_slide, Gfun(Internal f_tilt_body_butt_slide)) ::
 (_common_slide_action, Gfun(Internal f_common_slide_action)) ::
 (_common_slide_action_with_jump, Gfun(Internal f_common_slide_action_with_jump)) ::
 (_act_butt_slide, Gfun(Internal f_act_butt_slide)) ::
 (_act_hold_butt_slide, Gfun(Internal f_act_hold_butt_slide)) ::
 (_act_crouch_slide, Gfun(Internal f_act_crouch_slide)) ::
 (_act_slide_kick_slide, Gfun(Internal f_act_slide_kick_slide)) ::
 (_stomach_slide_action, Gfun(Internal f_stomach_slide_action)) ::
 (_act_stomach_slide, Gfun(Internal f_act_stomach_slide)) ::
 (_act_hold_stomach_slide, Gfun(Internal f_act_hold_stomach_slide)) ::
 (_act_dive_slide, Gfun(Internal f_act_dive_slide)) ::
 (_common_ground_knockback_action, Gfun(Internal f_common_ground_knockback_action)) ::
 (_act_hard_backward_ground_kb, Gfun(Internal f_act_hard_backward_ground_kb)) ::
 (_act_hard_forward_ground_kb, Gfun(Internal f_act_hard_forward_ground_kb)) ::
 (_act_backward_ground_kb, Gfun(Internal f_act_backward_ground_kb)) ::
 (_act_forward_ground_kb, Gfun(Internal f_act_forward_ground_kb)) ::
 (_act_soft_backward_ground_kb, Gfun(Internal f_act_soft_backward_ground_kb)) ::
 (_act_soft_forward_ground_kb, Gfun(Internal f_act_soft_forward_ground_kb)) ::
 (_act_ground_bonk, Gfun(Internal f_act_ground_bonk)) ::
 (_act_death_exit_land, Gfun(Internal f_act_death_exit_land)) ::
 (_common_landing_action, Gfun(Internal f_common_landing_action)) ::
 (_common_landing_cancels, Gfun(Internal f_common_landing_cancels)) ::
 (_act_jump_land, Gfun(Internal f_act_jump_land)) ::
 (_act_freefall_land, Gfun(Internal f_act_freefall_land)) ::
 (_act_side_flip_land, Gfun(Internal f_act_side_flip_land)) ::
 (_act_hold_jump_land, Gfun(Internal f_act_hold_jump_land)) ::
 (_act_hold_freefall_land, Gfun(Internal f_act_hold_freefall_land)) ::
 (_act_long_jump_land, Gfun(Internal f_act_long_jump_land)) ::
 (_act_double_jump_land, Gfun(Internal f_act_double_jump_land)) ::
 (_act_triple_jump_land, Gfun(Internal f_act_triple_jump_land)) ::
 (_act_backflip_land, Gfun(Internal f_act_backflip_land)) ::
 (_quicksand_jump_land_action, Gfun(Internal f_quicksand_jump_land_action)) ::
 (_act_quicksand_jump_land, Gfun(Internal f_act_quicksand_jump_land)) ::
 (_act_hold_quicksand_jump_land, Gfun(Internal f_act_hold_quicksand_jump_land)) ::
 (_check_common_moving_cancels, Gfun(Internal f_check_common_moving_cancels)) ::
 (_mario_execute_moving_action, Gfun(Internal f_mario_execute_moving_action)) ::
 nil).

Definition public_idents : list ident :=
(_mario_execute_moving_action :: _check_common_moving_cancels ::
 _act_hold_quicksand_jump_land :: _act_quicksand_jump_land ::
 _quicksand_jump_land_action :: _act_backflip_land ::
 _act_triple_jump_land :: _act_double_jump_land :: _act_long_jump_land ::
 _act_hold_freefall_land :: _act_hold_jump_land :: _act_side_flip_land ::
 _act_freefall_land :: _act_jump_land :: _common_landing_cancels ::
 _common_landing_action :: _act_death_exit_land :: _act_ground_bonk ::
 _act_soft_forward_ground_kb :: _act_soft_backward_ground_kb ::
 _act_forward_ground_kb :: _act_backward_ground_kb ::
 _act_hard_forward_ground_kb :: _act_hard_backward_ground_kb ::
 _common_ground_knockback_action :: _act_dive_slide ::
 _act_hold_stomach_slide :: _act_stomach_slide :: _stomach_slide_action ::
 _act_slide_kick_slide :: _act_crouch_slide :: _act_hold_butt_slide ::
 _act_butt_slide :: _common_slide_action_with_jump :: _common_slide_action ::
 _tilt_body_butt_slide :: _act_burning_ground :: _act_crawling ::
 _act_riding_shell_ground :: _act_hold_decelerating :: _act_decelerating ::
 _act_braking :: _act_finish_turning_around :: _act_turning_around ::
 _act_hold_heavy_walking :: _act_hold_walking :: _act_move_punching ::
 _act_walking :: _tilt_body_ground_shell :: _tilt_body_walking ::
 _push_or_sidle_wall :: _anim_and_audio_for_heavy_walk ::
 _anim_and_audio_for_hold_walk :: _anim_and_audio_for_walk ::
 _begin_braking_action :: _check_ground_dive_or_punch ::
 _analog_stick_held_back :: _should_begin_sliding :: _update_walking_speed ::
 _update_decelerating_speed :: _apply_slope_decel :: _update_shell_speed ::
 _apply_landing_accel :: _apply_slope_accel :: _update_sliding ::
 _update_sliding_angle :: _set_triple_jump_action :: _slide_bonk ::
 _check_ledge_climb_down :: _begin_walking_action :: _align_with_floor ::
 _play_step_sound :: _tilt_body_running :: _sFloorAlignMatrix ::
 _sBackflipLandAction :: _sTripleJumpLandAction :: _sDoubleJumpLandAction ::
 _sLongJumpLandAction :: _sHoldFreefallLandAction :: _sHoldJumpLandAction ::
 _sSideFlipLandAction :: _sFreefallLandAction :: _sJumpLandAction ::
 _bhvJumpingBox :: _mario_update_punch_sequence ::
 _mario_check_object_grab :: _mario_drop_held_object ::
 _mario_grab_used_object :: _mario_stop_riding_object ::
 _segmented_to_virtual :: _perform_ground_step ::
 _mario_update_windy_ground :: _mario_update_moving_sand ::
 _mario_push_off_steep_floor :: _mario_update_quicksand ::
 _mario_bonk_reflection :: _gWaterSurfacePseudoFloor :: _find_floor ::
 _find_wall_collisions :: _atan2s :: _approach_f32 :: _approach_s32 ::
 _mtxf_align_terrain_triangle :: _vec3f_copy :: _gSineTable :: _play_sound ::
 _set_water_plunge_action :: _check_common_action_exits ::
 _drop_and_set_mario_action :: _set_jumping_action ::
 _set_jump_from_landing :: _set_mario_action :: _find_floor_slope ::
 _mario_floor_is_slope :: _mario_floor_is_slippery ::
 _mario_facing_downhill :: _mario_get_floor_class ::
 _mario_set_forward_vel :: _play_mario_heavy_landing_sound_once ::
 _play_mario_landing_sound_once :: _play_mario_landing_sound ::
 _play_sound_and_spawn_particles :: _adjust_sound_for_speed ::
 _play_mario_jump_sound :: _play_sound_if_no_flag :: _is_anim_past_frame ::
 _set_mario_anim_with_accel :: _set_mario_animation :: _is_anim_at_end ::
 _sqrtf :: ___builtin_debug :: ___builtin_write32_reversed ::
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


